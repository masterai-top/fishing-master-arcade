--[[
登录界面
]]
local UIBase = require_ex("ui.base.UIBase")
local M = class("LoginAcntUI", UIBase)

--local UITextFieldEx = require_ex("lib.UITextFieldEx")

function M:ctor()
    self.effDark = true
    self.effRipple = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
    self._BindWidget = {
        ["panel_touch"] = {handle = handler(self, self.onClose)},
        ["panel/tf_acnt"] = {key = "tf_acnt"},
        ["panel/tf_psw"] = {key = "tf_psw"},
        ["panel/btn_login"] = {handle = handler(self, self.onLogin)},
        ["panel/btn_register"] = {handle = handler(self, self.onRegister)},
    }

    self:initViews()
end

function M:initViews()
    local uiNode = createCsbNode("ui/login/login_acnt.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    setTFPlaceColor(self._widgets.tf_acnt, ENUM.DEFAULT.PLACEHOLDER)
    setTFPlaceColor(self._widgets.tf_psw, ENUM.DEFAULT.PLACEHOLDER)
    self._widgets.tf_acnt:setString(Platform.getUdid())
end

function M:onLogin()
    local udid = self._widgets.tf_acnt:getString()
    if Assist.isEmpty(udid) then
        Game:tipMsg("用户名不能为空")
    else
        Game.localDB:setStringForKey("deviceid", udid)
        self:doLogin()
    end
end

function M:doLogin()
    Game.loginCom:checkServerStatus(Game.loginDB:getUid(), function ()
        Game.loginCom:onVisitorLogin(function(msg)
            if msg == "error" then
                Game:tipMsg("登录失败")
            else
                Game.loginDB:setVisitor()
                Game:initNetWork()
            end
        end)
    end)
end

function M:onRegister()
    local args = {
        sTip = "清除用户记录，注册新账号",
        fCallBack1 = function()
            Game.localDB:deleteValueForKey("deviceid")
            Game.loginDB:deleteSaved(1)
            Game.loginDB:initFromLocalDB()
            self:performWithDelay(handler(self, self.doLogin), 0.5)
        end,
    }
    showConfirmTip(args)
end

return M
