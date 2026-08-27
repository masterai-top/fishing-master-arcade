--[[
登录注册
]]

local M = class("LoginCom")
local _TAG = "LOGIN"

addGlobalEvent("UPD_NOTICE_ENABLE")
addGlobalEvent(_TAG, "SDK_LOGIN")
addGlobalEvent(_TAG, "UPKEEP_OUT")

function M:ctor()
    self:init()
end

function M:init()
    
end

--[[
停服更新公告
@param effDark      boolean     背景遮罩
@param hideClose    boolean     隐藏关闭按钮
]]
function M:openNotice(effDark, hideClose)
    local tipView = Game:doPluginAPI("open", "webview", UPDNOTICE_PAGE, effDark, "ui/login/notice.csb")
    if hideClose then
        tipView:hideBackButton()
    end
    Game:dispatchCustomEvent(GEvent("UPD_NOTICE_ENABLE"))
end

function M:closeNotice()
    local updateLayer = Game.uiManager:getLayer("UpdateNoticeUI")
    if updateLayer then
        updateLayer:destroy()
    end
    Game:dispatchCustomEvent(GEvent(_TAG, "NOTICE_CLOSE"))
end

--[[
用户协议
]]
function M:openAgreement(effDark, hideClose)
    local url = PHP_HOST.."notices/agreement"
    local tipView = Game:doPluginAPI("open", "webview", url, effDark, "ui/login/notice.csb")
    if hideClose then
        tipView:hideBackButton()
    end
end

--[[
异常登出（踢下线）
]]
function M:onKickOut(pack, info)
    dump(info, _TAG)

    Game.connectHandler:stopHeartBeat()
    Game.connectHandler:stopSchedule()
    netCom.closeNetWork(true)
    Game:destroyWaitUI()

    local reason = info.reason or info.code
    if reason == ENUM.ERR_CODE.KICK_OUT then
        -- 封号
        showConfirmTip({
            sTip = Config.localize("txt_server_ass"),
            sBtnName2 = Config.localize("exit"),
            fCallBack2 = function()
                Game:exitByGame(true)
            end,
        }, nil, ENUM.UI_Z.TIP)

    elseif reason == ENUM.ERR_CODE.LOGIN_OTHER or reason == ENUM.ERR_CODE.LOGIN_OTHER2 then
        -- 顶号被踢
        showConfirmTip({
            title = Config.localize("login_again_title"),
            sTip = Config.localize("login_again_tip"),
            sBtnName2 = Config.localize("exit"),
            fCallBack1 = function()
                self:onLogout()
            end,
            fCallBack2 = function()
                Game:exitByGame(true)
            end,
        }, nil, ENUM.UI_Z.TIP)

    elseif reason == ENUM.ERR_CODE.UPKEEP then
        -- 停服踢出
        Game:dispatchCustomEvent(GEvent(_TAG, "UPKEEP_OUT"))
        self:onLogout()
    end
end

--[[
登出，优先执行SDK登出
@param ignoreSdk        boolean     忽略SDK系统登出
@param ignoreAutoLogin  boolean     忽略后续SDK自动登录(进针对第三方联运渠道)
]]
function M:onLogout(ignoreSdk, ignoreAutoLogin)
    Log.I("==========onLogout==========", is_callback, _TAG)
    Game.loginDB:setIgnoreAutoLogin(ignoreAutoLogin)
    Game:dispatchCustomEvent(GEvent("GAME_BEFORE_LOGOUT_EVENT"))
    if not ignoreSdk and Game:funcIsOpen("sdk") and Sdk.isMMChanel() then
        Sdk.logout()
        return
    end
    self:doLogOut()
end

--[[
实际执行登出操作
]]
function M:doLogOut()
    Sdk.AUTO_LOGIN = false
    Sdk.IS_LOGOUT = true
    Game:doPluginAPI("clear", "player")
    Game.loginDB:initFromLocalDB()

    if Game:getSceneIdx() ~= ENUM.SCENCE.LOGIN then
        Game:performDelay(function()
            Game:enterScene(ENUM.SCENCE.LOGIN)
        end, 0.1)
    end

    local _callback_ = function()
        Log.I("logout", _TAG)
        Game:logOut()
        Sdk.reportGameData(5)
    end
    Game:performDelay(_callback_, 0.2)
end

--[[
游客登录/快速登录
]]
function M:onVisitorLogin(callback)
    local acnt = Platform.getUdid()
    Game.loginDB:setAccount(acnt)
    Game.loginDB:setAcntName(acnt)
    if callback then
        callback()
    else
        Game:initNetWork()
    end
end

--[[
唤起SDK界面
]]
function M:onWakeupSDK(agent, appid, parseTable)
    Log.I("========= Wakeup SDK =========", _TAG)
    Game:dispatchCustomEvent(GEvent(_TAG, "SDK_LOGIN"), {msg="sdk"})

    local function _callback_(info)
        if not Game or not Game.loginDB then return end
        if checknumber(info.ret_code) == 0 then
            info.acnt = info.uid
            info.psw = captcha
            info.rem = 1
            info.agent = agent
            info.data = {info.uid, info.msdkuid or "", ""}
            Game.loginDB:setLoginInfo(info, true, acntIdx)
            Game:dispatchCustomEvent(GEvent(_TAG, "SDK_LOGIN"), {msg="login"})
        else
            Game:tipError(info.ret_code or info.code)
            Game:dispatchCustomEvent(GEvent(_TAG, "SDK_LOGIN"), {msg="error", tip=false})
        end
    end

    local function _sdkLogin_()
        if Sdk.isMMChanel() then
            local info = {}
            if parseTable.nickName then 
                info.nickName = string.urldecode(parseTable.nickName) 
            end
            if parseTable.headUrl then 
                info.headUrl = string.urldecode(parseTable.headUrl) 
            end
            
            if not parseTable.uid then
                info.ret_code = -1
                Log.I("=======callback json data error===", _TAG)
            else
                info.ret_code = 0
                info.uid = tostring(parseTable.uid)
                info.msdkuid = parseTable.msdkuid
                info.openid = parseTable.openid
                info.unionid = parseTable.unionid
                info.phone = parseTable.phone
                info.token = parseTable.token
                info.sdkid = parseTable.sdkid
                info.visitor = parseTable.userName or parseTable.username or parseTable.nickName
                if parseTable.bind then
                    -- 绑定成功
                    if parseTable.bind == "1" then
                        info.is_binding_phone = 0
                    else
                        info.is_binding_phone = 1
                    end
                else
                    info.is_binding_phone = 0
                end
            end
            _callback_(info)
        end
    end

    if Assist.isEmpty(SERVER_STATE) or GAME_VERSION < "2.07.00" then
        _sdkLogin_()
    else
        local uid = parseTable.msdkuid
        if Assist.isEmpty(uid) then
            uid = parseTable.uid
        end
        self:checkServerStatus(uid, _sdkLogin_)
    end
end

---------------------------------------
-- 服务器状态检测
function M:checkServerStatus(uid, callback)
    local deviceId = Platform.getUdid()
    local version = Game.localDB:getStringForKey("res_ver_"..GAME_FRAME_ID)
    if Assist.isEmpty(version) then
        version = GAME_VERSION
    end
    local url, urlRES = SERVER_STATE
    if String.startWith(SERVER_STATE, "cdn_host") then
        url = string.gsub(SERVER_STATE, "cdn_host/", CDN_HOST or PHP_HOST)
        urlRES = string.gsub(SERVER_STATE, "cdn_host/", CDN_HOST_RES or PHP_HOST_RES)
    elseif String.startWith(SERVER_STATE, "php_host") then
        url = string.gsub(SERVER_STATE, "php_host/", PHP_HOST)
        urlRES = string.gsub(SERVER_STATE, "php_host/", PHP_HOST_RES)
    end
    local reqStr = string.format("?udid=%s&domain=%s&port=%i&opid=%s&version=%s&uid=%s", deviceId, DOMAIN_NAME, S_PORT, Sdk.getMarketId(), version, uid)

    local function _checkCallback_(recv)
        local t = json.decode(recv)
        if checknumber(t.status) == 0 then
            if callback then
                callback()
            end
        else
            -- 停服维护
            if t.msg then
                if t.vlimit then
                    Sdk.logout()
                    Game:restart(true)
                    return
                else
                    showConfirmTip({sTip=t.msg, btn2Hide=true}, nil, ENUM.UI_Z.TOP)
                end
            else
                if t.url then
                    UPDNOTICE_PAGE = t.url
                end
                Game:doPluginAPI("notice", "update", true)
            end

            Game.uiManager:hideLoading()
            Game:dispatchCustomEvent(GEvent(_TAG, "SDK_LOGIN"), {msg="error", tip=false})
        end
    end

    local function _checkFail_()
        if callback then
            callback()
        end
    end
    
    Game.httpCom:httpGet(url..reqStr, _checkCallback_, _checkFail_, urlRES..reqStr)
end

-- 服务器维护提示
function M:onUpkeepTips(pack, info)
    if info.times and info.times > 0 then
        require_ex("ui.common.UpkeepTipsUI").new(info.times):addToScene(ENUM.UI_Z.TOP+100)
    end
end

return M:new()
