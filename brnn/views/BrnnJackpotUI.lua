
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnJackpotUI", UIBase)
local Actor = require_ex("ui.base.Actor")

local intervalH = 20

local SpineJackpot = {res="subgame/brnn/spine/jckj/brnn_jckj", ani="1",isLoop = false}
local SpineCoin = {res="subgame/brnn/spine/coin/brnn_coin", ani="1",isLoop=false}

function M:ctor(exitCb)
	self.funcKey = "BrnnJackpotUI"
    self.effDark = true
    self.effRipple = true
    self._step = 1
    self._delayTime = {0.5,2.0}
    self._exitCb = exitCb

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["panel_open"] = {},
        ["panel_open/node_spine"] = {key="node_spine"},
        ["panel_open/txt_coin"] = {key="txt_coin"},
        ["panel_result"] = {},
        ["panel_result/img_bg_fail"] = {key="img_bg_fail"},
        ["panel_result/img_bg_win"] = {key="img_bg_win"},
        ["panel_result/img_bg_win/panel_myinfo/txt_coin"] = {key="txt_my_coin"},
        ["panel_result/img_bg_win/panel_myinfo/img_head"] = {key="img_my_head"},
        ["panel_result/img_bg_win/panel_myinfo/txt_vip"] = {key="txt_my_vip"},
        ["temp_top"] = {},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_jackpot.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    
    local jackpotInfo = Game.brnnDB:getJackpotReward()
    if jackpotInfo then
        self._widgets.panel_result:setVisible(false)
        self._widgets.temp_top:setVisible(false)
        self._widgets.panel_open:setVisible(true)
        self._widgets.txt_coin:setString(jackpotInfo.total_reward)
        SpineJackpot.handle = {[sp.EventType.ANIMATION_COMPLETE] = function()
            if self and self.showJackpotResult and self._step == 1 then
                self:showJackpotResult()
            end
        end}
        local actor = Actor:new(SpineJackpot.res,SpineJackpot)
        self._widgets.node_spine:addChild(actor,2)

        actor = Actor:new(SpineCoin.res,SpineCoin)
        self._widgets.node_spine:addChild(actor,1)
    else
        self:onClose()
    end
end

function M:showJackpotResult()
    self._step = 2
    self._widgets.panel_open:setVisible(false)
    local jackpotInfo = Game.brnnDB:getJackpotReward()
    self._widgets.panel_result:setVisible(true)
    
    local vipLv = Game:doPluginAPI("get","playerVIP")
    self._widgets.txt_my_vip:setString("VIP"..vipLv)
    self._widgets.txt_my_vip:setVisible(Game:funcIsOpen("vip"))
    Game:doPluginAPI("set","headIcon",self._widgets.img_my_head)
    if jackpotInfo.mine_reward > 0 then
        self._widgets.txt_my_coin:setString("+"..Number.measure(jackpotInfo.mine_reward))
        self._widgets.img_bg_fail:setVisible(false)
        self._widgets.img_bg_win:setVisible(true)
    else
        self._widgets.img_bg_fail:setVisible(true)
        self._widgets.img_bg_win:setVisible(false)
        self._widgets.img_bg_fail:getChildByName("Image_11"):setVisible(false)
    end
    local plist = self._widgets.panel_result:getChildByName("plist")
    local n = table.maxn(jackpotInfo.max_reward)
    if n > 0 then
        local temp_top = self._widgets.temp_top
        local itemSize = temp_top:getContentSize()
        local plistSize = plist:getContentSize()
        --计算中奖人数的显示长度
        local length = (n-1)*intervalH + itemSize.width*n
        local x = -length/2 + plistSize.width/2 + itemSize.width/2
        for _,v in ipairs(jackpotInfo.max_reward) do
            local item = temp_top:clone()
            self:handleRewardItem(item,v)
            plist:addChild(item)
            item:setPosition(x,itemSize.height/2)
            x = x + itemSize.width+intervalH
        end  
    end
    Game:performDelay(function()
        if self and self.onClose then
            self:onClose()
        end
    end,self._delayTime[2])
end

function M:handleRewardItem(item,itemData)
    item:setVisible(true)
    local txt_coin = item:getChildByName("txt_coin")
    local txt_name = item:getChildByName("txt_name")
    local img_head = item:getChildByName("img_head")
    local txt_vip = item:getChildByName("txt_vip")
    txt_coin:setString("+"..Number.measure(itemData.num))
    txt_name:setString(String.toFixed(itemData.name,5))
    Assist.checkTTF(txt_name)
    Game:doPluginAPI("set","headIcon",img_head,itemData.iconId)
    txt_vip:setString("VIP"..itemData.vipLv)
    txt_vip:setVisible(Game:funcIsOpen("vip"))
end

function M:spineBannerCompleteLsn()
    Game:performDelay(handlerSafe(self,self.showJackpotResult),self._delayTime[1])
end

function M:onClose()
    if self._step == 1 then
        self:showJackpotResult()
    else
        if self._exitCb then
            self._exitCb()
        end
        self:destroy()
    end
end

return M