
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnResultUI", UIBase)
local Actor = require_ex("ui.base.Actor")

local SpineWin = {res="subgame/brnn/spine/js1/brnn_js1",ani="win",isLoop=false}
local SpineLose = {res="subgame/brnn/spine/js2/brnn_js2",ani="lose",isLoop=false}
local SpinePj = {res="subgame/brnn/spine/js2/brnn_js2",ani="pj",isLoop=false}

local DEFAULT_IMG = "subgame/brnn/board/avt_cattle.png"

local BANKER_LIMIT = GameLimitConfig.value(47)

function M:ctor(timeleft)
	self.funcKey = "BrnnResultUI"
    self.effDark = true
    self.effRipple = true
    self.timeleft = timeleft

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handler(self,self.onBackClicked)},
        ["btn_close"] = {key="btn_close",handle=handler(self,self.onBackClicked)},
        ["txt_jackpot"] = {},
        ["img_bg_win"] = {},
        ["img_bg_fail"] = {},
        ["panel_myinfo/txt_get_coin"] = {key="txt_my_win"},
        ["panel_myinfo/txt_lose_coin"] = {key="txt_my_lose"},
        ["panel_myinfo/img_head"] = {key="img_my_head"},
        ["panel_myinfo/txt_vip"] = {key="txt_my_vip"},
        ["panel_banker/txt_coin"] = {key="txt_banker_coin"},
        ["panel_banker/txt_name"] = {key="txt_banker_name"},
        ["panel_banker/img_head"] = {key="img_banker_head"},
        ["panel_banker/txt_vip"] = {key="txt_banker_vip"},
        ["panel_player_1"] = {},
        ["panel_player_2"] = {},
        ["node_spine"] = {},
        ["pan"] = {},
        ["pan/btn_addbanker"] = {handle=handler(self,self.onBtnAddBanker)},
        ["pan/btn_close"] = {key="banker_close",handle=handler(self,self.onClose)},
        ["pan/img_tips"] = {key="img_tips"},
    }
    self:initViews()
    self:scheduleUpdate()
end

function M:updateFunc(dt)
    self.timeleft = self.timeleft-dt
    local curTimeleft = Number.ceil(self.timeleft)
    if curTimeleft == 0 then
        self:unscheduleUpdate()
        self:onClose()
    else
        local txt = self._widgets.btn_close:getChildByName("txt")
        txt:setString(string.format("继续(%d)",curTimeleft))
        txt = self._widgets.banker_close:getChildByName("txt")
        txt:setString(string.format("继续(%d)",curTimeleft))
    end
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_result.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    if AppName == "xgame" or AppName == "zgame" then
        local txt = self._widgets.img_tips:getChildByName("txt")
        local str = txt:getString()
        txt:setString(string.format(str,Number.measure(BANKER_LIMIT),Number.measure(BANKER_LIMIT)))
    end
    self:updateView()
end

function M:checkAddBanker()
    local bankerInfo = Game.brnnDB:getBankerInfo()
    local realBankerCoin = bankerInfo.num
    local ret = false
    local gold = Game.brnnDB:getCurGold()
    if bankerInfo.banker_round<5 and realBankerCoin<BANKER_LIMIT 
        and gold>=BANKER_LIMIT and (not Game.brnnDB:bankerReadyDown()) then
        ret = true
    end
    return ret
end

function M:updateView()
    local resultInfo = Game.brnnDB:getResultInfo()
    if resultInfo then
        self:initMyInfo(resultInfo.num)
        self:initBankerInfo(resultInfo.banker) --庄家金额发生变化
        if Game.brnnDB:isBanker() then
            if self:checkAddBanker() then
                self._widgets.btn_close:setVisible(false)
                self._widgets.pan:setVisible(true)
                local txt = self._widgets.banker_close:getChildByName("txt")
                txt:setString(string.format("继续(%d)",self.timeleft))
            else
                self._widgets.btn_close:setVisible(true)
                self._widgets.pan:setVisible(false)
                local txt = self._widgets.btn_close:getChildByName("txt")
                txt:setString(string.format("继续(%d)",self.timeleft))
            end
        else
            self._widgets.btn_close:setVisible(true)
            self._widgets.pan:setVisible(false)
            local txt = self._widgets.btn_close:getChildByName("txt")
            txt:setString(string.format("继续(%d)",self.timeleft))
        end

        local myUid = Game:doPluginAPI("get","playerUid")
        local winInfo = {}
        for _,v in ipairs(resultInfo.maxWin) do
            if myUid ~= v.uid then
                table.insert(winInfo,v)
            end
        end

        for i=1,2 do
            local panel_player = self._widgets["panel_player_"..i]
            self:handleItem(panel_player,winInfo[i])
        end

        local str = string.format(Config.localize("brnn_tips7"),Number.measure(resultInfo.water))
        if Game.brnnDB:isBulletRoom() then
            str = string.format(Config.localize("brnn_tips8"),Number.measure(resultInfo.water))
            self._widgets.txt_jackpot:setVisible(false)
        end
        self._widgets.txt_jackpot:setString(str)
    end
end

function M:initMyInfo(num)
    local txt_my_win = self._widgets.txt_my_win
    local txt_my_lose = self._widgets.txt_my_lose
    local img_my_head = self._widgets.img_my_head
    local txt_my_vip = self._widgets.txt_my_vip
    Game:doPluginAPI("set","headIcon",img_my_head)
    local vipLv = Game:doPluginAPI("get","playerVIP")
    txt_my_vip:setString("VIP"..vipLv)
    txt_my_vip:setVisible(Game:funcIsOpen("vip"))
    if num > 0 then
        txt_my_win:setVisible(true)
        txt_my_win:setString("+"..Number.measure(num))
        txt_my_lose:setVisible(false)
        self._widgets.img_bg_win:setVisible(true)
        self._widgets.img_bg_fail:setVisible(false)
        local actor = Actor:new(SpineWin.res,SpineWin)
        self._widgets.node_spine:addChild(actor)
        Audio.playSoundConfig(self, "win")
    else
        txt_my_win:setVisible(false)
        txt_my_lose:setVisible(true)
        self._widgets.img_bg_win:setVisible(false)
        self._widgets.img_bg_fail:setVisible(true)
        
        if num == 0 then
            txt_my_lose:setString("0")
            local actor = Actor:new(SpinePj.res,SpinePj)
            self._widgets.node_spine:addChild(actor)
            Audio.playSoundConfig(self, "ping")
        else
            txt_my_lose:setString("-"..Number.measure(Number.abs(num)))
            local actor = Actor:new(SpineLose.res,SpineLose)
            self._widgets.node_spine:addChild(actor)
            Audio.playSoundConfig(self, "lose")
        end
    end
end

function M:initBankerInfo(bankerInfo)
    local txt_banker_name = self._widgets.txt_banker_name
    local txt_banker_coin = self._widgets.txt_banker_coin
    local img_banker_head = self._widgets.img_banker_head
    local txt_banker_vip = self._widgets.txt_banker_vip
    if bankerInfo.uid == 0 then 
        txt_banker_name:setString("系统庄")
        img_banker_head:loadTexture(DEFAULT_IMG,1)
        txt_banker_vip:setVisible(false)
    else
        txt_banker_name:setString(String.toFixed(bankerInfo.name,5))
        Assist.checkTTF(txt_banker_name)
        Game:doPluginAPI("set","headIcon",img_banker_head,bankerInfo.iconId)
        txt_banker_vip:setVisible(true)
        txt_banker_vip:setString("VIP"..bankerInfo.vipLv)
        txt_banker_vip:setVisible(Game:funcIsOpen("vip"))
    end
    if bankerInfo.num >= 0 then
        txt_banker_coin:setString("+"..Number.measure(bankerInfo.num))
    else
        txt_banker_coin:setString("-"..Number.measure(Number.abs(bankerInfo.num)))
    end
    --即时刷新庄家金币
    if not Game.brnnDB:isSystemBanker() then
        local curBankerInfo = Game.brnnDB:getBankerInfo()
        curBankerInfo.num = Number.max(0,curBankerInfo.num + bankerInfo.num)
        Game:dispatchCustomEvent(GEvent("brnn","BankerChange"))
    end
end

function M:handleItem(item,itemData)
    if itemData == nil then
        item:setVisible(false)
    else
        local txt_coin = item:getChildByName("txt_coin")
        local img_head = item:getChildByName("img_head")
        local txt_vip = item:getChildByName("txt_vip")
        local txt_name = item:getChildByName("txt_name")
        if itemData.num >= 0 then
            txt_coin:setString("+"..Number.measure(itemData.num))
        else
            txt_coin:setString("-"..Number.measure(Number.abs(itemData.num)))
        end
        Game:doPluginAPI("set","headIcon",img_head,itemData.iconId)
        txt_vip:setString("VIP"..itemData.vipLv)
        txt_vip:setVisible(Game:funcIsOpen("vip"))
        txt_name:setString(String.toFixed(itemData.name,5))
        Assist.checkTTF(txt_name)
    end
end

--补庄
function M:onBtnAddBanker()
    Game.brnnCom:reqAddBanker()
    self._widgets.btn_close:setVisible(true)
    self._widgets.pan:setVisible(false)
end

function M:onBackClicked()
    if self.onClose then
        self:onClose()
    end
end

return M