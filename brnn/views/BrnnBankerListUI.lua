
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnBankerListUI", UIBase)

local BankerMin = GameLimitConfig.value(20)
local BankerMax = GameLimitConfig.value(43)  

function M:ctor()
	self.funcKey = "BrnnBankerListUI"
    self.effDark = true
    -- self.effRipple = true
    self._idx = 0
    self._uid = Game:doPluginAPI("get","playerUid")
    self._realBankerMax = 0
    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        -- ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["bg"] = {},
        ["bg/btn_close"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/btn_banker"] = {key="btn_banker",handle=handlerSafe(self,self.onBtnBanker)},
        ["bg/list"] = {key="bankerListUI"},
        ["bg/txt_tips"] = {key="txt_tips"},
        ["temp_item"] = {key="temp_item"},
        ["bg_slider"] = {},
        ["bg_slider/txt_coin"] = {key="txt_coin"},
        ["bg_slider/slider"] = {key="slider"},
        ["bg_slider/btn"] = {handle=handlerSafe(self,self.onGoToBanker)},
        ["bg_slider/btn_close"] = {handle=handlerSafe(self,self.onCloseSlider)},
        ["bg_slider/img_coin"] = {key="img_coin"},
        ["bg_slider/img_jade"] = {key="img_jade"},
    }
    self:initViews()
end

function M:registerListenEvent()
    self:listenCustomEvent(GEvent("brnn","BankerListChange"),handlerSafe(self,self.updateView))
    self:listenCustomEvent(GEvent("brnn","GoldChange"),handlerSafe(self,self.onGoldChange))
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_banker_list.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    local txt_desc = string.format(Config.localize("brnn_banker_up_limit_tip"),Number.measure(BankerMin))
    setRichText(self._widgets.txt_tips,txt_desc)
    self._widgets.txt_coin:setString(tostring(Number.measure(BankerMin)))

    --滑动条九宫格设置
    self._widgets.slider:setScale9Enabled(true)
    self._widgets.slider:setCapInsets(cc.rect(24,16,21,9))
    self._widgets.slider:setCapInsetsBarRenderer(cc.rect(22,21,23,23))
    self._widgets.slider:addEventListener(function(sender,eventType)
        self:onSliderChange(sender,eventType)
    end)
    local playerCoin = Game.brnnDB:getCurGold()
    if playerCoin<BankerMin then
        self._widgets.slider:setEnabled(false)
    else
        self._widgets.slider:setEnabled(true)
    end

    self._realBankerMax = Number.min(playerCoin,BankerMax)

    self._widgets.bg_slider:setVisible(false)

    if Game.brnnDB:isBulletRoom() then
        self._widgets.img_coin:setVisible(false)
        self._widgets.img_jade:setVisible(true)
    else
        self._widgets.img_coin:setVisible(true)
        self._widgets.img_jade:setVisible(false)
    end

    self:updateView()
end

function M:updateView()
    self._idx = 0
    local bankerListUI = self._widgets.bankerListUI
    bankerListUI:removeAllItems()
    self._widgets.temp_item:setVisible(false)
    
    local bankerList = Game.brnnDB:getBankerList()
    if bankerList == nil then
        return
    end

    local item
    for k,v in ipairs(bankerList or {}) do
        item = self._widgets.temp_item:clone()
        item:setTag(k)
        self:handleItem(item,v)
        bankerListUI:pushBackCustomItem(item)
    end
    bankerListUI:jumpToTop()
    

    local btn_banker = self._widgets.btn_banker
    local txt_up = btn_banker:getChildByName("txt_up")
    local txt_down = btn_banker:getChildByName("txt_down")
    --判断是上庄还是下庄
    if self._idx == 0 then
        txt_up:setVisible(true)
        txt_down:setVisible(false)
    else
        txt_up:setVisible(false)
        txt_down:setVisible(true)
    end
end

function M:handleItem(item,itemData)
    item:setVisible(true)
    local img_head = item:getChildByName("img_head")
    local txt_name = item:getChildByName("txt_name")
    local txt_coin = item:getChildByName("txt_coin")
    local txt_vip = item:getChildByName("txt_vip")
    local img_coin = item:getChildByName("img_coin")
    local img_jade = item:getChildByName("img_jade")

    local playerInfo = itemData.player
    Game:doPluginAPI("set","headIcon",img_head,playerInfo.iconId)

    txt_name:setString(playerInfo.name)
    Assist.checkTTF(txt_name)

    txt_coin:setString(tostring(Number.measure(itemData.num)))

    txt_vip:setString("VIP"..playerInfo.vipLv)
    txt_vip:setVisible(Game:funcIsOpen("vip"))

    if playerInfo.uid == self._uid then
        self._idx = item:getTag()
    end

    if Game.brnnDB:isBulletRoom() then
        img_coin:setVisible(false)
        img_jade:setVisible(true)
    else
        img_coin:setVisible(true)
        img_jade:setVisible(false)
    end
end

function M:onSliderChange(sender,eventType)
    if eventType == 0 then
        local percent = sender:getPercent()
        local num = math.floor((self._realBankerMax-BankerMin)*percent/100)+BankerMin
        self._widgets.txt_coin:setString(Number.measure(num))
    end
end

function M:onGoldChange()
    local coin = Game.brnnDB:getCurGold()
    self._realBankerMax = Number.min(coin,BankerMax)
    self:onSliderChange(self._widgets.slider,0)
end

function M:onBtnBanker()
    if self._idx == 0 then      --上庄
        local myCoin = Game.brnnDB:getCurGold()
        if myCoin < BankerMin then
            if Game.brnnDB:isBulletRoom() then
                Game:tipMsg(string.format(Config.localize("brnn_tips2"),Number.measure(BankerMin)))
            else
                Game:tipMsg(string.format(Config.localize("brnn_tips1"),Number.measure(BankerMin)))
            end
        else
            self._widgets.bg:setVisible(false)
            self._widgets.bg_slider:setVisible(true)
        end
    else  --下庄
        Game.brnnCom:reqCancelBank()
    end
end

--上庄
function M:onGoToBanker()
    local percent = self._widgets.slider:getPercent()
    local num = math.floor((self._realBankerMax-BankerMin)*percent/100)+BankerMin
    
    Game.brnnCom:reqGoToBank(num,function()
        excFuncSafe(self,"onClose")
    end)
end

function M:onCloseSlider()
    self:onClose()
end

return M