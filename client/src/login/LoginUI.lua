--[[
登录主界面
]]
local UIBase = require_ex("ui.base.UIBase")
local M = class("LoginUI", UIBase)

local Actor = require_ex("ui.base.Actor")
local SpineTitle = {res = "gameres/general/spine/loading2/dt_loading1", ani = "1"}
-- 本地版本号 Key
local VerKey = "res_ver_"..GAME_FRAME_ID
-- 登录冷却
local LoginCD = 2

function M:ctor()
    self.funcKey = "login"

    UIBase.ctor(self)
    self:init()
end

function M:registerListenEvent()
    self:listenCustomEvent(cc.EVENT_COME_TO_FOREGROUND, handler(self, self.onComeToForeGround))

    if Game:funcIsOpen("sdk") then
        self:listenCustomEvent(GEvent("LOGIN_ERR_EVENT"), handler(self, self.startThirdSDKLogin))
        self:listenCustomEvent(GEvent("GAME_ON_LOGOUT_EVENT"), handler(self, self.startThirdSDKLogin))
        self:listenCustomEvent(GEvent(self.funcKey, "SDK_LOGIN"), handler(self, self.onLoginCallback))
    end
    self:listenCustomEvent(GEvent("UPD_NOTICE_ENABLE"), handler(self, self.openNotice))
end

function M:init()
    self._BindWidget = {
        ["img_bg"] = {},
        ["bg"] = {key = "img_bg"},
        ["node_spine"] = {},
        ["img_logo"] = {key = "img_logo"},
        ["panel"] = {},
        ["panel/buttonPanel"] = {key = "btnPanel"},
        ["panel/btnSDK"] = {key = "btnSDK", handle = handler(self, self.onSDKLogin)},
        ["panel/buttonPanel/btn1"] = {key = "btnMaiMai", handle = handler(self, self.onMaiMaiLoginClicked)},
        ["panel/buttonPanel/btn2"] = {key = "btnQQ", handle = handler(self, self.onQQLoginClicked), hide = true},
        ["panel/buttonPanel/btn3"] = {key = "btnQuick", handle = handler(self, self.onGuestLoginClicked)},
        ["panel/buttonPanel/btn4"] = {key = "btnWeChat", handle = handler(self, self.onWeChatLoginClicked), hide = true},
        ["btn_exit"] = {handle = handler(self, self.onClose)},
        ["btn_servier"] = {handle = handler(self, self.onServerHandler)},
        ["btn_notice"] = {handle = handler(self, self.onUpdateNotice)},
        ["btn_repair"] = {handle = handler(self, self.onRepair)},
        ["panel_agreement"] = {},
        ["panel_agreement/cb_agree"] = {key = "cb_agree"},
        ["panel_agreement/txt_copy"] = {handle = handler(self, self.onAgreement)},

        ["Panel_1"] = {key = "bottomPanel"},
        ["Panel_1/txt"] = {key = "txt_tip"},

        ["warnTips"] = {},
        ["notifyTips"] = {},
        ["verTips"] = {},
        ["txt_opsig"] = {handle = handler(self, self.onCopyUDID)},

        -- 服务器列表（测试）
        ["panel_server"] = {key = "panel_server"},
        ["panel_server/btn_server"] = {key = "btn_server", handle = handler(self, self.onServerList)},
        ["panel_server/list_server"] = {key = "lv_server"},

        ["temp_server"] = {},
    }

    self._loginCD = nil
    self.sdkLoging = nil

    self:initViews()
end

function M:initViews()
    local uiNode = createCsbNode("ui/login/loginFront.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    local crEnable = Game:funcIsOpen("copyright")
    if SkinsConfig and Platform.getAppName and crEnable then
        -- SkinsConfig中配置马甲信息
        -- copyright 填空 不显示版号信息和版本信息
        local appName = Platform.getAppName()
        local skinCfg = SkinsConfig[appName] or SkinsConfig["捕鱼圣手"]
        if skinCfg then
            if Assist.isEmpty(skinCfg.copyright) then
                self._widgets.notifyTips:setVisible(false)
                if self._widgets.verTips then
                    self._widgets.verTips:setVisible(false)
                end
            else
                local tip = ""
                if skinCfg.AO and Game:funcIsOpen("AO") then      
                    tip = string.format(Config.localize("login_copyright_info_AO"),
                            skinCfg.copyright, skinCfg.publisher, skinCfg.ISBN, skinCfg.AQ, skinCfg.AO)
                else
                    tip = string.format(Config.localize("login_copyright_info"),
                            skinCfg.copyright, skinCfg.publisher, skinCfg.ISBN, skinCfg.AQ)
                end
                self._widgets.notifyTips:setString(tip)
                self._widgets.notifyTips:setVisible(true)
            end
            fitIconSize(self._widgets.img_logo, skinCfg.logo)

        elseif Platform.isCRPackage() then
            self._widgets.notifyTips:setVisible(false)
        end
    else
        self._widgets.notifyTips:setVisible(crEnable)
    end

    -- 开发模式添加选服功能
    if DEVELOP_MODE or CHEAT_TOKEN then
        local serverList = Game.loginDB:getServerList()
        local savedServer, savedSPort = Game.loginDB:getDefaultServerAndPort()
        if self._widgets.panel_server then
            for i, v in ipairs(serverList) do
                local text = v.desc
                if device.platform == "windows" then
                    text = string.format("%s:%s[%i] -- %s", v.host, v.port, v.tcp_ver, text)
                end
                local btn_svr = self._widgets.temp_server:clone()
                btn_svr:setTitleText(text)
                btn_svr:setTag(i)
                bindClickFunc(btn_svr, handler(self, self.onServer))

                btn_svr:setVisible(true)
                self._widgets.lv_server:pushBackCustomItem(btn_svr)

                if savedServer == tostring(v.host) and savedSPort == tonumber(v.port) then
                    S_HOST = cc.LuaCHelper:theHelper():getHostIP(v.host)
                    S_PORT = v.port
                    S_TCPV = v.tcp_ver
                    self._widgets.btn_server:setTitleText(text)
                    Game.loginDB:setServer(v)
                end
            end
        end
    end

    -- keep loading animation
    local mainScene = display.getRunningScene():getChildByTag(-666)
    if mainScene and mainScene.cmdLayer then
        self._widgets.img_bg:setVisible(false)
        if self._widgets.img_logo then
            self._widgets.img_logo:setVisible(false)
        end
    else
        if self._widgets.img_logo then
            if FuncListKeyConfig.state("logo") == 1 then
                if SkinsConfig and Platform.getAppName then
                    local appName = Platform.getAppName()
                    local skinCfg = SkinsConfig[appName] or SkinsConfig["捕鱼圣手"]
                    fitIconSize(self._widgets.img_logo, skinCfg.logo)
                end
                self._widgets.img_logo:setVisible(true)
            else
                self._widgets.img_logo:setVisible(false)
            end
        end
        if SpineTitle and self._widgets.node_spine then
            local size = self._widgets.node_spine:getContentSize()
            SpineTitle.x = size.width / 2
            SpineTitle.y = size.height / 2
            local spine = Actor:new(SpineTitle.res, SpineTitle)
            self._widgets.node_spine:addChild(spine)
            adaptNode(self._widgets.node_spine, -666, nil, CC_DESIGN_RESOLUTION)
        end
    end

    -- 游戏区
    if not Assist.isEmpty(OP_SIG) then
        local tmp = OP_SIG
        for cl in string.gmatch(tmp, "<%w+>$") do
            OP_AGENT_CODE = string.sub(cl, 2, -2)
            OP_SIG = string.gsub(OP_SIG, cl, "")
        end
    end
    if self._widgets.txt_opsig and not Assist.isEmpty(OP_SIG) 
        and OP_SIG ~= "android" and OP_SIG ~= "ios" then
        self._widgets.txt_opsig:setString(OP_SIG)
        self._widgets.txt_opsig:setVisible(true)
    end

    -- 剪贴板邀请码
    if Assist.isEmpty(OP_AGENT_CODE) then
        OP_AGENT_CODE = Sdk.getInviteCode()
        Log.I("OP_AGENT_CODE = ", OP_AGENT_CODE, "TEST")
    end

    -- 版本号
    if self._widgets.verTips then
        local appVer = Platform.getAppVersion()
        local resVer = Game.localDB:getStringForKey(VerKey)
        if Assist.isEmpty(appVer) then
            appVer = GAME_VERSION or "1.00.00"
        end
        if Assist.isEmpty(resVer) then
            resVer = GAME_VERSION or appVer
        end
        self._widgets.verTips:setString(resVer.."|"..appVer)
    end
    self:checkFuncOpen()

    if device.platform ~= "windows" and Game:funcIsOpen("sdk") then
        self._widgets.panel:setVisible(false)
        self:performWithDelay(function()
            self:startThirdSDKLogin()
        end, 0.5)
    else
        self:startCommonLogin()
    end
end

function M:onEnter()
    UIBase.onEnter(self)
    if not DEBUG_OFFLINE then
        Game.connectHandler:stopHeartBeat()
    end
    Audio.playSoundConfig(self)

    if device.platform == "ios" then
        -- bugfix
        local vol = Game:doPluginAPI("get", "volume")
        if vol == 0 then
            self:performWithDelay(function ()
                Game:doPluginAPI("set", "volume", 0)
            end, 0.3)
        end
    end

    Game:hideCapture()
    Game:unlockTouch()
    Game.enterFromField = nil
    Game.tipEvent = nil
	Game.isfirstPetGuideTips = nil

    if FuncListKeyConfig.state("skin", 0) == 0 then
        Game:purgeUnused(nil, true)
    end
    Game.uiManager:removeLayer("MarqueeUI")

    if COLLISION_PHYSIC then
        if not Game:funcIsOpen("collision_physic") or not display.getRunningScene():getPhysicsWorld() then
            COLLISION_PHYSIC = nil
        end
        Log.I("COLLISION_PHYSIC", tostring(COLLISION_PHYSIC), "GAME")
    end
end

function M:onComeToForeGround()
    Game:checkGameUpd(true)
end

function M:checkFuncOpen()
    if self._widgets.panel_server then
        self._widgets.panel_server:setVisible(DEVELOP_MODE or not Assist.isEmpty(CHEAT_TOKEN))
    end
    if self._widgets.btn_notice then
        self._widgets.btn_notice:setVisible(NoticeList ~= nil)
    end
    if self._widgets.btn_repair then
        --@since 2.20.00
        self._widgets.btn_repair:setVisible(CMD_VERSION and CMD_VERSION > "2.20.00")
    end

    self._widgets.btnMaiMai:setVisible(Game:funcIsOpen("MMLogin"))
    self._widgets.btnQuick:setVisible(Game:funcIsOpen("KSLogin"))
    self._widgets.btnWeChat:setVisible(Game:funcIsOpen("WXLogin"))
    self._widgets.btnQQ:setVisible(Game:funcIsOpen("QQLogin"))
    self._widgets.btn_servier:setVisible(Game:funcIsOpen("service"))
    if Platform.isCRPackage() then
        self._widgets.btn_servier:setVisible(false)
        self._widgets.btn_exit:setVisible(false)
    end

    -- 重排四个登录入口
    local Gaps = {0, 80, 40, 15}
    local list = {}
    if self._widgets.btnMaiMai:isVisible() then
        table.insert(list, self._widgets.btnMaiMai)
    end
    if self._widgets.btnQuick:isVisible() then
        table.insert(list, self._widgets.btnQuick)
    end
    if self._widgets.btnWeChat:isVisible() then
        table.insert(list, self._widgets.btnWeChat)
    end
    if self._widgets.btnQQ:isVisible() then
        table.insert(list, self._widgets.btnQQ)
    end
    Assist.alignWidgets(list, Gaps[#list])
end

-------------------------------
--[[
第三方登录
]]
function M:startThirdSDKLogin(event)
    if not Game:funcIsOpen("sdk") then return end
    if event and event.data and event.data.reconnect then return end
    self._widgets.panel:setVisible(true)
    local isThirdSDK = Sdk.isThirdSDK()
    self._widgets.btnPanel:setVisible(not isThirdSDK)
    self._widgets.btnSDK:setVisible(isThirdSDK)

    Game.uiManager:hideLoading()
    
    if Game.loginDB and not Game.loginDB:ignoreAutoLogin() then
        if Sdk.AUTO_LOGIN or isThirdSDK then
            self:onSDKLogin(Sdk.AUTO_LOGIN)
        elseif not isThirdSDK and self._widgets.btnMaiMai:isVisible() then
            Sdk.showLoginView()
        end
    end
end

--[[
服务器停服更新公告
]]
function M:openNotice(errCode)
    if self._widgets.btn_notice then
        self._widgets.btn_notice:setVisible(true)
    end

    if errCode then
        local cfgData = Config.getConfigValue(MsgConfig, errCode) or {}
        local tip = cfgData.text or tostring(errCode)
        self._widgets.txt_tip:setString(tip)
    end
end

---------------------------------------------
-- 交互及回调
function M:onClose()
    Game:exitGame()
end

function M:onServerHandler()
    Game:doPluginAPI("enter", "OpenService")
end

function M:onLoginCallback(event)
    local data = event.data or {}
    local msg = data.msg or ""

    if msg == "sdk" then
        self:setSDKLoging(true)

    elseif msg == "login" then
        Game:initNetWork()
        self._widgets.btnSDK:setVisible(false)

    elseif msg == "error" then
        local tipSDKLogin = data.tip
        if tipSDKLogin == nil then
            tipSDKLogin = true
        end
        self:resetLoginCD(tipSDKLogin)
    end
end

function M:checkAgreement(ignoreTip)
    local agree = not self._widgets.cb_agree or self._widgets.cb_agree:isSelected()
    if not agree and not ignoreTip then
        Game:tipMsg(Config.localize("agreement_tip"))
    end
    return agree
end

--[[
自动登录
@discarded
]]
function M:autoLogin()

end

function M:startCommonLogin()
    if not self:checkAgreement() then return end
    local acnt = Game.loginDB:getVisitor()
    if Game.loginDB:getAccountState() == AcntState.Guest then
        if string.len(acnt) > 13 then
            acnt = string.sub(acnt, 1, 12) .. "..."
        end
    end
    local str = string.format("%s %s", acnt, Config.localize("curr_login"))
    self._widgets.txt_tip:setString(str)

    if Sdk.AUTO_LOGIN then
        Sdk.AUTO_LOGIN = false

        self._widgets.panel:setVisible(true)
        self._widgets.btnPanel:setVisible(false)
        self._widgets.bottomPanel:setVisible(true)

        if DEBUG_OFFLINE then
            Game:onLoginFinished({tick = os.time()})
            return
        end
        if CHEAT_TOKEN then
            Game:initNetWork()
        else
            self:autoLogin()
        end
    else
        self._widgets.panel:setVisible(true)
        self._widgets.btnPanel:setVisible(true)
        self._widgets.bottomPanel:setVisible(false)
    end
end

function M:onGuestLoginClicked()
    if not self:checkAgreement() then return end
    if self._loginCD or self.sdkLoging then return end
    self:startLoginCD()

    if Game:funcIsOpen("sdk") and Sdk.isMMChanel() then
        Sdk.openTouristLoginUI()
    else
        if not Game:funcIsOpen("loading") then
            Game:showWaitUI(Config.localize("curr_login"), true)
        end
        Game.loginCom:checkServerStatus(Game.loginDB:getUid(), function ()
            Game.loginCom:onVisitorLogin(function(msg)
                if msg == "error" then
                    self:onChangeAcntClicked()
                else
                    Game.loginDB:setVisitor()
                    Game:initNetWork()
                end
            end)
        end)
    end
end

function M:onMaiMaiLoginClicked()
    if not self:checkAgreement() then return end
    if self._loginCD or self.sdkLoging then return end
    self:startLoginCD()

    if Sdk.isMMChanel() then
        Sdk.openNormalLoginUI()
    elseif device.platform == "windows" then
        require_ex("ui.login.LoginAcntUI").new():addToScene()
	else
		Game:tipMsg(Config.localize("coming_soon"))
    end
end

function M:onWeChatLoginClicked()
    if not self:checkAgreement() then return end
    if self._loginCD or self.sdkLoging then return end
    self:startLoginCD()

    if Sdk.isMMChanel() then
        Sdk.openWeChatLoginUI()
    else
        local unitTest = require_ex("util.unit_test").new()
        unitTest:testRapid()
    end
end

function M:onQQLoginClicked()
    if not self:checkAgreement() then return end
    if self._loginCD or self.sdkLoging then return end
    self:startLoginCD()

    if Sdk.isMMChanel() then
        Sdk.openQqLoginUI()
    else
        if not Game:funcIsOpen("loading") then
            Game:showWaitUI(Config.localize("curr_login"), true)
        end
        Game:initNetWork()
    end
end

function M:onSDKLogin(is_auto)
    if not self:checkAgreement() then return end
    if self._loginCD or self.sdkLoging then return end
    self:startLoginCD()

    Log.I("===onSDKLogin not is_auto=== open third", self.funcKey)
    if type(is_auto) == "boolean" and is_auto then
        Sdk.login()
    else
        Sdk.showThirdLoginDialog()
    end
    if Sdk.IS_LOGOUT then
        Log.I("===onSDKLogin is logout===", self.funcKey)
        Sdk.IS_LOGOUT = false
        Sdk.showLoginView()
    end
end

function M:onChangeAcntClicked()
    self:stopAllActions()
    self._widgets.bottomPanel:setVisible(false)
    if not Sdk.isThirdSDK() then
        self._widgets.btnPanel:setVisible(true)
    end
end

function M:onUpdateNotice()
    Game.loginCom:openNotice(true)
end

function M:onAgreement()
    Game.loginCom:openAgreement(true)
end

--[[
修复客户端
]]
function M:onRepair()
    local args = {
        sTip = Config.localize("repair_tip"),
        fCallBack1 = function()
            Game:showWaitUI(Config.localize("repair_tip_wait"), true)
            self:performWithDelay(handler(self, self.doRepair), 0.5)
        end,
    }
    showConfirmTip(args)
end

function M:doRepair()
    if not __cmd then
        require("cmd.CMDMonitor")
    end
    if __cmd then
        __cmd:executeCMD(CMD.cc_subgame)
        __cmd:executeCMD(CMD.cc_mainframe)
        Game:destroyWaitUI()

        -- 版本兼容
        local apiVer = Platform.getAppVersion(true)
        if apiVer < "2.73.00" and apiVer >= "2.70.00" then
            Platform.doReStartGame("", 0.1)
            return
        end
        
        Game:tipMsg(Config.localize("repair_success"), 1.5, function()
            if device.platform == "android" then
                Platform.doReStartGame("", 0.1)
            else
                Game:restart(true)
            end
        end)
    else
        Game:destroyWaitUI()
        Game:tipMsg(Config.localize("repair_fail"), 3)
    end
end

--------------------------------
-- 选服（测试）
function M:onServerList()
    local v = self._widgets.lv_server:isVisible()
    self._widgets.lv_server:setVisible(not v)
end

function M:onServer(sender)
    local idx = sender:getTag()
    local v = Game.loginDB:getServerList()[idx]
    local text = v.desc
    if device.platform == "windows" then
        text = string.format("%s:%s[%i] -- %s", v.host, v.port, v.tcp_ver, text)
    end
    self._widgets.btn_server:setTitleText(text)
    S_HOST = v.host
    S_PORT = v.port
    S_TCPV = v.tcp_ver
    if string.find(S_HOST, "c") then
        ChangeServer(S_HOST)
    end
    Game.loginDB:setServer(v)
    Game.loginDB:saveServerIdToLocal(S_HOST, S_PORT)

    self._widgets.lv_server:setVisible(false)
end

--------------------------------
-- 登录CD
function M:startLoginCD()
    self:stopAllActions()
    self._loginCD = true
    self:performWithDelay(function()
        self._loginCD = nil
    end, LoginCD)
end

function M:setSDKLoging(loging)
    self.sdkLoging = loging
    if self.sdkLoging then
        self._widgets.btnPanel:setVisible(false)
        self._widgets.btnSDK:setVisible(false)
    else
        self:resetLoginCD()
    end
end

function M:resetLoginCD(tipSDKLogin)
    self:stopAllActions()
    self._loginCD = nil
    self.sdkLoging = nil

    if not Game:funcIsOpen("sdk") then return end

    if device.platform ~= "windows" then
        local isThirdSDK = Sdk.isThirdSDK()
        self._widgets.btnPanel:setVisible(not isThirdSDK)
        self._widgets.btnSDK:setVisible(isThirdSDK)
    end

    if tipSDKLogin and Sdk.isMMChanel() then
        Sdk.logout()
        self:performWithDelay(function()
            if isThirdSDK then -- FIXME isThirdSDK undefine
                Sdk.showThirdLoginDialog()
            else
                Sdk.openNormalLoginUI()
            end
        end, 1)
    end
end

--[[
复制UDID
@test
]]
function M:onCopyUDID(sender)
    sender:stopAllActions()

    self._udidCount = checknumber(self._udidCount) + 1
    if self._udidCount > 5 then
        self._udidCount = 0
        if device.platform == "android" or device.platform == "ios" then
            Platform.copyToClipboard(Platform.getUdid())
        else
            Game:tipMsg(Platform.getUdid())
        end
    else
        sender:performWithDelay(handler(self, self.clearUDID), 0.5)
    end
end

function M:clearUDID()
    self._udidCount = 0
end

return M
