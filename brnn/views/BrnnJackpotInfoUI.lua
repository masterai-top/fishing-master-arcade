local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnJackpotInfoUI", UIBase)

function M:ctor()
	self.funcKey = "BrnnJackpotInfoUI"
    self.effDark = true
    self.effRipple = true
    self.tick = 0
    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["panel_center/scrollView"] = {key="scrollView"},
        ["panel_center/scrollView/Image_4/light_1"] = {key="light_1"},
        ["panel_center/scrollView/Image_4/light_2"] = {key="light_2"},
        ["panel_center/scrollView/Image_4/txt_jackpot"] = {key="txt_jackpot"},
        ["panel_center/scrollView/img_bg/pan/txt_count"] = {key="txt_count"},
        ["panel_center/scrollView/img_bg/pan/txt_total_reward"] = {key="txt_total_reward"},
        ["panel_center/scrollView/img_bg/img_head"] = {key="img_head"},
        ["panel_center/scrollView/img_bg/txt_name"] = {key="txt_name"},
        ["panel_center/scrollView/img_bg/txt_reward"] = {key="txt_reward"},
        ["panel_center/scrollView/img_bg/txt_vip"] = {key="txt_vip"},
        ["panel_center/btn_close"] = {handle=handlerSafe(self,self.onClose)}
    }
    self:initViews()
    self:scheduleUpdate()
end

function M:updateFunc(dt)
    self.tick = self.tick + dt
    local v = Number.floor(self.tick)
    if v%2 == 0 then
        self._widgets.light_1:setVisible(false)
        self._widgets.light_2:setVisible(true)
    else
        self._widgets.light_1:setVisible(true)
        self._widgets.light_2:setVisible(false)
    end
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_jackpot_info.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    
    local jackpotInfo = Game.brnnDB:getJackpotInfo()
    local num = Game.brnnDB:getJackpot()
    self._widgets.txt_count:setString(jackpotInfo.prize_num)
    self._widgets.txt_jackpot:setString(String.splitNumberBySymbol(num,3,","))
    self._widgets.txt_total_reward:setString(jackpotInfo.bonus)
    local winner = jackpotInfo.winner
    Game:doPluginAPI("set","headIcon",self._widgets.img_head,winner.iconId)
    self._widgets.txt_name:setString(String.toFixed(winner.name,10,""))
    Assist.checkTTF(self._widgets.txt_name)
    self._widgets.txt_reward:setString(winner.num)
    if winner.vipLv == 0 then
        self._widgets.txt_vip:setVisible(false)
    else
        self._widgets.txt_vip:setVisible(true)
    end
    self._widgets.txt_vip:setVisible(Game:funcIsOpen("vip"))
    self._widgets.txt_vip:setString("VIP"..winner.vipLv)
    self._widgets.scrollView:setScrollBarEnabled(false)
end

return M