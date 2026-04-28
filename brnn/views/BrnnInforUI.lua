local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnInforUI", UIBase)

function M:ctor(player_info,gray)
	self.funcKey = "BrnnInforUI"
    self.effDark = true
    self.effRipple = true
    UIBase.ctor(self)
    self._playerInfo = player_info
    self._playerId = player_info.pid or player_info.uid
    self._gray = gray
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/btn_ok"] = {handle=handlerSafe(self,self.onClose)},
        ["btn_close"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/pan_info/img_head"] = {key="img_head"},
        ["bg/pan_info/txt_name"] = {key="txt_name"},
        ["bg/pan_info/txt_id"] = {key="txt_id"},
        ["bg/pan_info/txt_sign"] = {key="txt_sign"},
        ["bg/pan_info/txt_vip"] = {key="txt_vip"},
        ["bg/pan_info/txt_coin"] = {key="txt_coin"},
        ["bg/pan_info/img_coin"] = {key="img_coin"},
        ["bg/pan_info/img_jade"] = {key="img_jade"},
        ["bg/pan_info/txt_desc"] = {key = "txt_desc",hide=true},
        ["bg/emoji_1"] = {key = "emoji_1",tag=1,handle=handler(self,self.onEmoji)},
        ["bg/emoji_2"] = {key = "emoji_2",tag=2,handle=handler(self,self.onEmoji)},
        ["bg/emoji_3"] = {key = "emoji_3",tag=3,handle=handler(self,self.onEmoji)},
        ["bg/emoji_4"] = {key = "emoji_4",tag=4,handle=handler(self,self.onEmoji)},
        ["bg/emoji_5"] = {key = "emoji_5",tag=5,handle=handler(self,self.onEmoji)},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_infor.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    Game:doPluginAPI("set","headIcon",self._widgets.img_head, self._playerInfo.facelook)
    self._widgets.txt_name:setString(self._playerInfo.nick)
    Assist.checkTTF(self._widgets.txt_name)
    
    self._widgets.txt_id:setString("ID:"..self._playerId)
    self._widgets.txt_sign:setString(Game:filterSensitive(self._playerInfo.feel))
    Assist.checkTTF(self._widgets.txt_sign)
    self._widgets.txt_vip:setString("VIP"..self._playerInfo.vip)
    self._widgets.txt_vip:setVisible(Game:funcIsOpen("vip"))
    local myUid = Game:doPluginAPI("get","playerUid")
    if Game.brnnDB:isBulletRoom() then
        self._widgets.img_coin:setVisible(false)
        self._widgets.img_jade:setVisible(true)
        if myUid == self._playerId then
            local coin = Game.brnnDB:getCurGold()
            self._widgets.txt_coin:setString(coin)
        else
            self._widgets.txt_coin:setString(self._playerInfo.jade)
        end
    else
        self._widgets.img_coin:setVisible(true)
        self._widgets.img_jade:setVisible(false)
        if myUid == self._playerId then
            local coin = Game.brnnDB:getCurGold()
            self._widgets.txt_coin:setString(coin)
        else
            self._widgets.txt_coin:setString(self._playerInfo.coin)
        end
    end

    if self._playerId == myUid or self._gray then
        for i=1,5 do
            self._widgets["emoji_"..i]:setEnabled(false)
            self._widgets["emoji_"..i]:setGray(true)
        end
    end

    local str = self._widgets.txt_desc:getString()
    local strLimit = Game.brnnDB:getMagicLimit()
    if strLimit then
        self._widgets.txt_desc:setVisible(true)
        self._widgets.txt_desc:setString(string.format(str,strLimit))
    end
end

function M:onEmoji(sender)
    sender:setTouchEnabled(false)
    local tag = sender:getTag()
    local param = {}
    
    if Game.brnnDB:checkBanker(self._playerId) then
        param.pos = 7
    else
        param.pos = Game.brnnDB:getSeatIdxByUid(self._playerId)
    end
    if param.pos == -1 then
        Game:tipError(86000024)
    else
        param.iconId = tag
        param.msg = ""
        param.role_id = self._playerId
        Game.brnnCom:reqMagicEmoji(param)
    end
    self:onClose()
end

return M