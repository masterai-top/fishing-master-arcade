--[[
兑换码
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("ExchangeGiftUI", UIBase)

local function _wordValidCheck(inputStr)
    local ValidTable = {
        UPPER = {65, 90},
        LOWER = {97, 122},
        NUM = {48, 57}
    }
    for i = 1, string.len(inputStr) do
        local wordByte = string.byte(inputStr, i)
        local check = false
        for _, v in pairs(ValidTable) do
            local start = v[1]
            local endNum = v[2]
            if wordByte >= start and wordByte <= endNum then
                check = true
            end
        end
        if check == false then
            return false
        end
    end
    return true
end

function M:ctor()
    UIBase.ctor(self)
    self:init()
end

function M:init()
    self._BindWidget = {
        ["btn_close"] = {handle = handler(self, self.onClose)},
        ["pan_bg/pan_cut/Button_1"] = {handle = handler(self, self.onGiftClicked)},
        ["pan_bg/pan_cut/TextField_1"] = {key = "txt_code"},
    }

    self:initViews()
end

function M:initViews()
    local uiNode = createCsbNode("ui/exchange/giftBag.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
end

function M:onGiftClicked()
    local code = self._widgets.txt_code:getString()
    if not _wordValidCheck(code) or string.utf8AllToEnglishLen(code) ~= 15 then 
        Game:tipMsg(Config.localize("gift_code_err")) 
        return 
    end

    Game.activityCom:onGetRewardCode(code, function(info)
        self:onClose()
        local rewards={}
        for _, v in ipairs(info.list) do
            table.insert(rewards, {item_id=v.id, num=v.num, desc=Config.localize("txt_gift_reward")})
        end
        Assist.showGetGoods(rewards)
    end)
end

return M
