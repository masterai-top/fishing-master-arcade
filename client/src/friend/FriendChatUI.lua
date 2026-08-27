--[[
好友聊天界面
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("FriendChatUI", UIBase)

function M:ctor(info)
    UIBase.ctor(self)
    self:init(info)
end

function M:init(info)
    self._BindWidget = {
        ["panel_touch"] = {handle = handler(self, self.onClose)},
        ["panel/txtName"] = {key = "txt_name"},
        ["panel/tfContent"] = {key = "tf_msg"},
        ["panel/btnSend"] = {handle = handler(self, self.onSend)},
    }

    self._friendId = info.pid
    self._friendName = info.nick

    self:initViews()
end

function M:initViews()
    local uiNode = createCsbNode("ui/friend/writeMsg.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    self._widgets.txt_name:setString(Config.localize("friend_receiver")..self._friendName)
    self._widgets.tf_msg:setString("")
end

-------------------------------
-- 交互
function M:onSend()
    local msg = self._widgets.tf_msg:getString()
    if Assist.isEmpty(msg) then
        Game:tipMsg(Config.localize("content_null"))
    elseif Game:checkSensitive(msg) then
        Game:tipMsg(Config.localize("minggan_reinput"))
    else
        Game.friendCom:onChat(self._friendId, msg)
        self:onClose()
    end
end

return M
