--[[
百人牛牛主界面
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnUI", UIBase)

local Actor = require_ex("ui.base.Actor")

local ChipsLimit = 50           --同个区域筹码最多个数
local CARD_PAD = 24             --牌间距
local BetInLimit = GameLimitConfig.value(30)/10000 --押注最大金额比例
local BRNN_SEAT_MAX = 6         --6个座位
local BRNN_AREA_COUNT = 4       --4个押注区 
local LOCAL_ZORDER = 1100
local DRAW_PANEL_ZORDER = 1200
local MAX_BANKER_COUNT = GameLimitConfig.value(23)
local MAX_BET_COIN = GameLimitConfig.value(45)
local MAX_JACKPOT_COIN = GameLimitConfig.value(32)
local MIN_BET_COIN = Game.brnnDB:getMinBetCoin()

local SpineSelect = {res="subgame/brnn/spine/cmxz/brnn_cmxz", ani="1"}
local SpineAreaWin = {res="subgame/brnn/spine/tzk/brnn_tzk", ani="2"}
local SpineJackpot = {res="subgame/brnn/spine/jc/brnn_jc",ani="2"}
local SpineSeat = {res="subgame/brnn/spine/txk/brnn_txk",ani="1"}
local SpineBiaoqing = {res="subgame/brnn/spine/biaoqing/dt_bq"}

local DEFAULT_IMG = "subgame/brnn/board/avt_cattle.png"

local TAG = "brnn"
local PerformKeyTb = {}

local allChipLists = {
    [1] = 100,
    [2] = 1000,
    [3] = 5000,
    [4] = 10000,
    [5] = 50000,
    [6] = 100000,
    [7] = 500000,
    [8] = 1000000,
}

--筹码数值对应的筹码图片
local chipIconMap = {
    [1]   = "subgame/brnn/icon/game_ps_bet_1.png",
    [2]   = "subgame/brnn/icon/game_ps_bet_2.png",
    [3]   = "subgame/brnn/icon/game_ps_bet_3.png",
    [4]   = "subgame/brnn/icon/game_ps_bet_4.png",
    [5]   = "subgame/brnn/icon/game_ps_bet_5.png",
    [6]   = "subgame/brnn/icon/game_ps_bet_6.png",
    [7]   = "subgame/brnn/icon/game_ps_bet_7.png",
    [8]   = "subgame/brnn/icon/game_ps_bet_8.png",
}

function M:ctor()
    self.funcKey = "Brnn"

    UIBase.ctor(self)
    self:init()
end

function M:init()
    self._BindWidget = {
        ["btn_back"] = {handle=handlerSafe(self,self.onExitMenu)},
        ["panel_desktop"] = {},
        ["panel_desktop/panel_jackpot"] = {key="panel_jackpot",handle=handlerSafe(self,self.onBtnJackpot)},
        ["panel_desktop/panel_jackpot/txt_coin"] = {key="txt_jackpot"},
        ["panel_desktop/panel_jackpot/img_coin"] = {key="img_jackpot_coin"},
        ["panel_desktop/panel_jackpot/img_jade"] = {key="img_jackpot_jade"},
        ["panel_desktop/panel_time"] = {key="panel_time"},
        ["panel_desktop/panel_bet_1"] = {key="panel_bet_1",tag=1},
        ["panel_desktop/panel_bet_2"] = {key="panel_bet_2",tag=2},
        ["panel_desktop/panel_bet_3"] = {key="panel_bet_3",tag=3},
        ["panel_desktop/panel_bet_4"] = {key="panel_bet_4",tag=4},
        ["panel_top/seat_banker"] = {key="seat_banker"},
        ["panel_top/seat_banker/img_head"] = {key="img_banker_head",handle=handlerSafe(self,self.onShowBankerInfo)},
        ["panel_top/seat_banker/txt_coin"] = {key="txt_banker_coin"},
        ["panel_top/seat_banker/txt_name"] = {key="txt_banker_name"},
        ["panel_top/seat_banker/txt_count"] = {key="txt_count"},
        ["panel_top/seat_banker/txt_win_coin"] = {key="txt_win_bcoin"},
        ["panel_top/seat_banker/txt_lose_coin"] = {key="txt_lose_bcoin"},
        ["panel_top/seat_banker/txt_vip"] = {key="txt_bvip"},
        ["panel_top/btn_banker"] = {key="btn_banker",handle=handlerSafe(self,self.onBtnBanker)},
        ["panel_top/card_banker"] = {key="card_banker"},
        ["panel_top/card_banker/panel_draw"] = {key="panel_banker_draw"},
        ["panel_seat/seat_1"] = {key="seat_1",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_seat/seat_2"] = {key="seat_2",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_seat/seat_3"] = {key="seat_3",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_seat/seat_4"] = {key="seat_4",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_seat/seat_5"] = {key="seat_5",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_seat/seat_6"] = {key="seat_6",handle=handlerSafe(self,self.onTouchSeat)},
        ["panel_bottom/btn_bet_1"] = {key="btn_bet_1",handle=handlerSafe(self,self.onBetSelected)},
        ["panel_bottom/btn_bet_2"] = {key="btn_bet_2",handle=handlerSafe(self,self.onBetSelected)},
        ["panel_bottom/btn_bet_3"] = {key="btn_bet_3",handle=handlerSafe(self,self.onBetSelected)},
        ["panel_bottom/btn_bet_4"] = {key="btn_bet_4",handle=handlerSafe(self,self.onBetSelected)},
        ["panel_bottom/img_select"] = {key="img_select"},
        ["panel_bottom/seat_my/img_head"] = {key="img_my_head",handle=handlerSafe(self,self.showEmojiView)},
        ["panel_bottom/seat_my/txt_name"] = {key="txt_my_name"},
        ["panel_bottom/seat_my/txt_coin"] = {key="txt_my_coin"},
        ["panel_bottom/seat_my/txt_win_coin"] = {key="txt_my_win_coin"},
        ["panel_bottom/seat_my/txt_lose_coin"] = {key="txt_my_lose_coin"},
        ["panel_bottom/seat_my/txt_vip"] = {key="txt_my_vip"},
        ["panel_bottom/seat_my/img_coin"] = {key="img_my_coin"},
        ["panel_bottom/seat_my/img_jade"] = {key="img_my_bowlder"},
        ["panel_bottom/btn_record"] = {key="btn_record",handle=handlerSafe(self,self.onBtnRecord)},
        ["panel_bottom/btn_other"] = {key="btn_other",handle=handlerSafe(self,self.onBtnOther)},
        ["panel_bottom/btn_recharge"] = {key="btn_recharge",handle=handlerSafe(self,self.onBtnRecharge)},
        ["panel_back/panel_exit"] = {key="panel_exit"},
        ["panel_back/panel_exit/btn_exit"] = {key="btn_exit",handle=handlerSafe(self,self.onClose)},
        ["panel_back/panel_exit/btn_setting"] = {handle=handlerSafe(self,self.onSettingUI)},
        ["panel_back/panel_exit/btn_help"] = {handle=handlerSafe(self,self.onRuleUI)},
        ["temp_fly_coin"] = {},
        ["temp_poke"] = {},
        ["temp_panel_draw"] = {},
        ["nodeMarquee"] = {},
        ["pan_mask"] = {key="pan_mask",hide=true,handle=handlerSafe(self,self.onHideEmojiView)},
        ["pan_emoji"] = {key="pan_emoji",hide=true,zorder=DRAW_PANEL_ZORDER+1},
    }

    self._SpineBanner = {
        bet_start = {res="subgame/brnn/spine/kstz/brnn_ksxz", zorder=100, x=display.cx, y=display.cy, isLoop=false, ani="ks",
                    handle = {
                        [sp.EventType.ANIMATION_COMPLETE] = handlerSafe(self, self.spineBannerCompleteLsn),
                    }},
        bet_stop = {res="subgame/brnn/spine/kstz/brnn_ksxz", zorder=100, x=display.cx, y=display.cy, isLoop=false, ani="tz",
                    handle = {
                        [sp.EventType.ANIMATION_COMPLETE] = handlerSafe(self, self.spineBannerCompleteLsn),
                    }},
        change_banker = {res="subgame/brnn/spine/kstz/brnn_ksxz", zorder=100, x=display.cx, y=display.cy, isLoop=false, ani="zj",
                    handle = {
                        [sp.EventType.ANIMATION_COMPLETE] = handlerSafe(self, self.spineBannerCompleteLsn),
                    }},
    }
    -- 存放桌面所有筹码
    self._allChips = {{},{},{},{}}
    self._chipPool = {}  --筹码池
    self._pokeCache = {}  --扑克牌缓存
    self._betQueue = {}   --押注队列 用于筹码动画
    self._spine = {}
    self._curBetIdx = 0
    self._drawPanel = {}    --牌型
    self._panBetArea = {}   --押注区域范围
    self._myBetTxt = {}     --我的押注文本记录
    self._allBetTxt = {}    --总的区域文本记录
    self._allPoke = {}      --牌集合
    self._tempDrawPanel = {}    --临时牌型panel存放
    self._canChangeLimit = false --充值可以改变最大下注金额
    self._panScore = {}
    local gold = Game.brnnDB:getCurGold()
    self._myChipLimit = Number.min(gold* BetInLimit,MAX_BET_COIN)
    self:initViews()
end

function M:onEnter()
    UIBase.onEnter(self)
    Audio.stopAllSounds()
    Audio.playSoundConfig(self)
end
function M:onExit()
    UIBase.onExit(self)
end

--事件监听
function M:registerListenEvent()
    self:listenCustomEvent(cc.EVENT_COME_TO_FOREGROUND, handlerSafe(self, self.onComeToForeGround))
    self:listenCustomEvent(cc.EVENT_COME_TO_BACKGROUND, handlerSafe(self, self.onComeToBackGround))
    self:listenCustomEvent(GEvent(TAG,"UpBanker"), handlerSafe(self,self.onBankerUp))
    self:listenCustomEvent(GEvent(TAG,"DownBanker"), handlerSafe(self,self.onBankerDown))
    self:listenCustomEvent(GEvent(TAG,"CardInfo"), handlerSafe(self,self.dealPoke))
    self:listenCustomEvent(GEvent(TAG,"BankerChange"), handlerSafe(self,self.onBankerChange))
    self:listenCustomEvent(GEvent(TAG,"KickOut"), handlerSafe(self,self.onKickOut))
    self:listenCustomEvent(GEvent(TAG,"MSGBROADCAST"), handlerSafe(self,self.onMsgBroadcast))
    self:listenCustomEvent(GEvent("BET","STATE_CHANGE"), handlerSafe(self, self.onStateChanged))
    self:listenCustomEvent(GEvent("BET","TIME_CHANGE"), handlerSafe(self, self.onTimeChanged))
    self:listenCustomEvent(GEvent("ON_RECHARGE_FINISH"), handlerSafe(self,self.onPayFinish))
    self:listenCustomEvent(GEvent("EXCHANGE","EXCHANGE_SUCCESS"), handlerSafe(self,self.onExchangeSuccess))
    self:listenCustomEvent(GEvent("ON_SERVER_GLOBAL_TIPS"), handlerSafe(self,self.onServerGlobalTips))
    self:listenCustomEvent(GEvent("ON_SERVER_GLOBAL_RELOAD"), handlerSafe(self,self.onReloadGame))
    self:listenCustomEvent(GEvent("ON_SERVER_KICK_OUT_GAME"), handlerSafe(self,self.onServerKickOutGame))
    self:listenCustomEvent(GEvent("ON_VIP_CHANGE"), handlerSafe(self,self.updateVip))
end

--开始下注 停止下注特效
function M:tipSpineBanner(key)
    if self._SpineBanner[key] then
        if not self._spine[key] then
            self._spine[key] = Actor:new(self._SpineBanner[key].res, self._SpineBanner[key])
            self:addChild(self._spine[key])
        else
            self._spine[key]:setVisible(true)
            self._spine[key]:changeAnimation(self._SpineBanner[key].ani, self._SpineBanner[key].isLoop, nil, true)
        end
    end
end

function M:spineBannerCompleteLsn()
    for _,v in pairs(self._spine) do
        v:setVisible(false)
    end
end

function M:initViews()
    local uiNode = createCsbNode("subgame/brnn/brnn_main.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    self._widgets.panel_time:setVisible(false)
    self._widgets.panel_exit:setVisible(false)

    for i=1,BRNN_SEAT_MAX do
        self._betQueue[i] = require("lib.Queue").new()
    end

    self:createChipPool()
    self:createPokeCache()
    self:initEffect()
    self:initMyInfo()
    self:initBetChips()
    self:initSeatView()
    self:initBankerView()
    self:initAreaView()
    self:initJackpot()
    self:initEmoji()
    --进房时已加载好数据
    self:refreshSeatView()
    self:updateRoomInfo()
    self:initBetListAni()
    self:showDebugInfo()

    --这里先同步状态
    local state = Game.betMng:getState()
    local event = {}
    event.data = {}
    event.data.state = state
    self:onStateChanged(event)
    --跑马灯
    self:adjustMarquee()
    self._brnnGift = require_ex("games.brnn.views.BrnnGift").new(self)
end

function M:adjustMarquee()
    -- 跑马灯位置偏移
    local nodeMarquee = self._widgets.nodeMarquee
    if nodeMarquee then
        local pos = cc.p(nodeMarquee:getPosition())
        Game:doPluginAPI("move", "marquee", pos)
    end
end

function M:initBetListAni()
    local betList = Game.brnnDB:getCurBetList()
    if betList then
        self:handleBetList(betList)
    end
end

--初始化一些桌面按钮特效
function M:initEffect()
    --筹码按钮特效
    local img_select = self._widgets.img_select
    img_select:setVisible(true)
    local node_spine = img_select:getChildByName("node_spine")
    local actor = Actor:new(SpineSelect.res,SpineSelect)
    node_spine:addChild(actor)
end

function M:initMyInfo()
    local name = Game:doPluginAPI("get","playerName")
    self._widgets.txt_my_name:setString(name)
    Assist.checkTTF(self._widgets.txt_my_name)
    Game:doPluginAPI("set","headIcon",self._widgets.img_my_head)
    local vipLv = Game:doPluginAPI("get","playerVIP")
    self._widgets.txt_my_vip:setString("VIP"..vipLv)
    self._widgets.txt_my_vip:setVisible(Game:funcIsOpen("vip"))
    if Game.brnnDB:isBulletRoom() then
        self._widgets.img_my_coin:setVisible(false)
        self._widgets.img_my_bowlder:setVisible(true)
        local coin = Game:doPluginAPI("get","playerJade")
        self._widgets.txt_my_coin:setString(Number.measure(coin))
        self._widgets.btn_recharge:setVisible(false)
    else
        local coin = Game:doPluginAPI("get","playerCoin")
        self._widgets.txt_my_coin:setString(Number.measure(coin))
        self._widgets.img_my_coin:setVisible(true)
        self._widgets.img_my_bowlder:setVisible(false)
    end
end 

--初始化座位显示
function M:initSeatView()
    local seat
    local node_spine,actor
    for i=1,BRNN_SEAT_MAX do
        seat = self._widgets["seat_"..i]
        if AppName == "qgame" then
            seat:setVisible(false)
        end
        seat:setTag(i)
        seat:getChildByName("img_head"):setVisible(false)
        seat:getChildByName("txt_name"):setVisible(false)
        seat:getChildByName("txt_tips"):setVisible(true)
        seat:getChildByName("img_stand"):setVisible(false)
        seat:getChildByName("txt_vip"):setVisible(false)
        node_spine = seat:getChildByName("node_spine")
        actor = Actor:new(SpineSeat.res)
        node_spine:addChild(actor)
        node_spine.__actor = actor
        actor:setVisible(false)
    end
end

--初始化庄家界面显示
function M:initBankerView()
    self._widgets.txt_banker_name:setString("系统庄")
    self._widgets.txt_banker_coin:setString("0")

    self._widgets.btn_banker:getChildByName("txt_up"):setVisible(true)
    self._widgets.btn_banker:getChildByName("txt_down"):setVisible(false)

    self._widgets.txt_count:setString("连庄次数")
    self._widgets.card_banker:getChildByName("panel_draw"):setVisible(false)

    self._widgets.txt_lose_bcoin:setVisible(false)
    self._widgets.txt_win_bcoin:setVisible(false)

    self._widgets.txt_bvip:setString("VIP0")
    self._widgets.txt_bvip:setVisible(Game:funcIsOpen("vip"))
end

--初始化押注区域显示
function M:initAreaView()
    local pan_bet, area, card, txt_allbet, txt_mybet, panel_area, drawPanel, node_spine, ani, score
    for i=1,BRNN_AREA_COUNT do
        pan_bet = self._widgets["panel_bet_"..i]
        area = pan_bet:getChildByName("area")
        area:setTag(i)
        bindClickFunc(area,handlerSafe(self,self.onTouchBet))
        node_spine = area:getChildByName("node_spine")
        ani = Actor:new(SpineAreaWin.res)
        node_spine:addChild(ani)
        node_spine.__ani = ani
        node_spine:setVisible(false)
        panel_area = area:getChildByName("panel_area")
        panel_area:setTag(i)
        self._panBetArea[i] = panel_area
        txt_allbet = area:getChildByName("txt_allbet")
        txt_allbet:setString("0")
        txt_allbet:setTag(0)
        self._allBetTxt[i] = txt_allbet
        txt_mybet = area:getChildByName("txt_mybet")
        txt_mybet.__curCoin = 0
        txt_mybet:setVisible(false)
        self._myBetTxt[i] = txt_mybet
        card = pan_bet:getChildByName("card")
        drawPanel = card:getChildByName("panel_draw")
        drawPanel:setVisible(false)
        self._drawPanel[i] = drawPanel
        score = pan_bet:getChildByName("score")
        score:setVisible(false)
        self._panScore[i] = score
    end
    self._drawPanel[0] = self._widgets.panel_banker_draw
end

--初始化奖池
function M:initJackpot()
    local jackpot = Game.brnnDB:getJackpot()
    self:updateJackpot(jackpot)
    local node_spine = self._widgets.panel_jackpot:getChildByName("node_spine")
    local actor = Actor:new(SpineJackpot.res)
    node_spine:addChild(actor)
    actor:setVisible(false)
    self.__jackpotActor = actor
    if Game.brnnDB:isBulletRoom() then
        self._widgets.panel_jackpot:setVisible(false)
        self._widgets.img_jackpot_coin:setVisible(false)
        self._widgets.img_jackpot_jade:setVisible(true)
    else
        self._widgets.img_jackpot_coin:setVisible(true)
        self._widgets.img_jackpot_jade:setVisible(false)
    end
end

--初始化表情包
function M:initEmoji()
    local emoji_count = 9
    if AppName ~= "xgame" then
        emoji_count = 12
    end
    local img_emoji
    for k=1,emoji_count do
        img_emoji = self._widgets.pan_emoji:getChildByName("emoji_"..k)
        img_emoji:setVisible(true)
        bindClickFunc(img_emoji,handlerSafe(self,self.onSendEmoji))
    end
end

--更新奖池
function M:updateJackpot(jackpot)
    if jackpot < 1000000000 then
        self._widgets.txt_jackpot:setString(Number.measure(jackpot,4))
    else
        self._widgets.txt_jackpot:setString(Number.measure(jackpot,8))
    end
end

--更新金币
function M:updateMyGold(myGold)
    local state = Game.betMng:getState()
    if self._canChangeLimit then
        if state == BetState.betting then
            local betCoin = 0
            for _,v in ipairs(self._myBetTxt or {}) do
                betCoin = v.__curCoin + betCoin
            end
            self._myChipLimit = math.floor((betCoin+myGold) * BetInLimit)-betCoin
            if self._myChipLimit > MAX_BET_COIN then
                self._myChipLimit = MAX_BET_COIN
            end
        else
            self._myChipLimit = Number.min(math.floor(myGold*BetInLimit),MAX_BET_COIN)
        end
        if self._canChangeLimit then
            self._canChangeLimit = false
        end
    elseif state~=BetState.betting then
        self._myChipLimit = Number.min(math.floor(myGold*BetInLimit),MAX_BET_COIN)
    end
    self._widgets.txt_my_coin:setString(tostring(Number.measure(myGold)))
    Game.brnnDB:refreshChipList()
    self:updateBetChips()
end

-- 状态更新
function M:onStateChanged(event)
    if event.data.state == BetState.waitbet then
        self:doStateWaitbet()
    elseif event.data.state == BetState.betting then
        self:doStateBetting()
    elseif event.data.state == BetState.lottery then
        self:doStateLottery()
    elseif event.data.state == BetState.waitlot then
        self:doStateWaitLottery()
    elseif event.data.state == BetState.reward then
        self:doStateReward()
    end
end

-- 计时器更新
function M:onTimeChanged(event)
    self:updateTimePanel(event.data.state, event.data.timeleft)
end

--倒计时
function M:updateTimePanel(state, timeleft)
    state = Game.betMng:getState()
    local panel_time = self._widgets.panel_time
    local txt_state = panel_time:getChildByName("txt_state")
    local txt_time = panel_time:getChildByName("txt_time")
    panel_time:setVisible(true)
    if state == BetState.waitbet then
        txt_state:setString("休息一下")
        txt_time:setString(timeleft)
    elseif state == BetState.betting then
        txt_state:setString("请下注")
        txt_time:setString(timeleft)
        if timeleft == 1 then
            Audio.playSoundConfig(self, "countdown2")
        elseif timeleft < 4 then
            Audio.playSoundConfig(self, "countdown")
        end
    else
        panel_time:setVisible(false)
    end
    
end

function M:clear()
    --重置状态
    for _,v in ipairs(self._allBetTxt) do
        v:setTag(0)
        v:setString("0")
    end

    for _,v in ipairs(self._myBetTxt) do
        v.__curCoin = 0
        v:setVisible(false)
    end

    self:resetPoke()

    for _,v in ipairs(self._panScore) do
        v:stopAllActions()
        v:setVisible(false)
    end

    for _,v in ipairs(self._tempDrawPanel) do
        v:removeFromParent()
    end
    self._tempDrawPanel = {}

    self:hideAreaWinEffect()

    self:removeAllChip()
    self:resetChipPool()
    for i=1,BRNN_SEAT_MAX do
        self._betQueue[i]:clear()
        local seat = self._widgets["seat_"..i]
        local node_spine = seat:getChildByName("node_spine")
        if node_spine.__actor then
            node_spine.__actor:setVisible(false)
        end
    end
end

----------- 状态控制接口 --------------
function M:doStateWaitbet()
    self:clear()

    if Game.brnnDB:bankerChange() then
        self:tipSpineBanner("change_banker")
    end

    if Game.brnnDB:bankerReadyDown() then
        if Game.brnnDB:isBanker() then
            Game.brnnCom:reqCancelBank()
        else --已经下庄就不管了
            Game.brnnDB:setBankerReadyDown(false)
        end
    end

    --重置
    Game.brnnDB:resetDataNext()

    if Game.brnnDB:isBanker() then
        Audio.playSoundConfig(self, "bgm2")
    else
        Audio.playSoundConfig(self)
    end
end

function M:doStateBetting()
    self:tipSpineBanner("bet_start")
    Audio.playSoundConfig(self, "betstart")
    local jackpot = Game.brnnDB:getJackpot()
    self:updateJackpot(jackpot)        --押注开始时刷新一下奖池
end

function M:doStateWaitLottery()
    self:tipSpineBanner("bet_stop")
    Audio.playSoundConfig(self, "betstop")
    self:syncPokeState(BetState.waitlot)
end

function M:doStateLottery()
    local timeLeft = Game.betMng:getTimeLeft()
    if timeLeft >= 2 then
        self:syncPokeState(BetState.lottery)
        local cardInfo = Game.brnnDB:getCardInfo()
        if cardInfo then
            self:openPoke(cardInfo)
        end
    else
        self:syncPokeState(BetState.reward)
    end
end

function M:doStateReward()
    self:syncPokeState(BetState.reward)
    self:onResultInfo()
end

--同步牌型
function M:syncPokeState(state)
    if #self._allPoke == 0 then
        if state == BetState.waitlot then
            self:dealPoke(true)
        else
            self:dealPoke()
        end
        if state == BetState.reward then
            local cardInfo = Game.brnnDB:getCardInfo()
            if cardInfo then
                local area_win = self:getAreaWin(cardInfo)
                local bankerType = 0
                local shouldSync = false
                for k,cards in ipairs(cardInfo) do
                    self:sortPoke(cards.card_list,cards.card_type)
                    if Assist.isEmpty(cards.card_list) then
                        shouldSync = true
                        break
                    end
                    for i,card in ipairs(cards.card_list) do
                        local color,size = self:getPokeColorAndSize(card)
                        local idx = (k-1)*5 + i
                        self:buildPoke(self._allPoke[idx],{color=color,size=size})
                        self._allPoke[idx]:setScaleX(-1)
                        self._allPoke[idx].bg:setVisible(false)
                        --押注区 牛1到牛牛的后两张牌上移
                        if k>1 and i>=4 and cards.card_type > 0 and cards.card_type<=10 then
                            self._allPoke[idx]:moveVec2(cc.p(0,10))
                        end
                    end
                    if k == 1 then
                        bankerType = cards.card_type
                    end
                    self:createDraw(k,cards.card_type,0.01,area_win[k])
                    self:showScore(k,cards.card_type,0.01,area_win[k],bankerType)
                end
                if shouldSync then
                    self:handleSync()
                end
            end
        end
    end
end

-- 押注筹码
function M:initBetChips()
    local chipList = Game.brnnDB:getChipList()
    local isBanker = Game.brnnDB:isBanker()
    local maxChipIdx = math.max(1, self._curBetIdx)
    local myCoin = Game.brnnDB:getCurGold()
    self._widgets.img_select:setVisible(true)
    for i=#chipList,1,-1 do
        local betWidget = self._widgets["btn_bet_"..i]
        if betWidget then
            local fnt_btnAdd = betWidget:getChildByName("fnt_btnAdd")
            betWidget:setVisible(true)
            betWidget:setTag(i)
            if myCoin < MIN_BET_COIN then
                maxChipIdx = 0
                self:setBetBtnEnabled(betWidget,false)
                self._widgets.img_select:setVisible(false)
            else
                if self._myChipLimit < chipList[i] then
                    if self._myChipLimit >= chipList[1] then
                        maxChipIdx = i - 1
                    else
                        self._widgets.img_select:setVisible(false)
                    end
                    self:setBetBtnEnabled(betWidget,false)
                else
                    self:setBetBtnEnabled(betWidget,true and isBanker==false)
                end
            end
            fnt_btnAdd:setString(Number.measure(chipList[i]))
        end
    end
    
    if isBanker then --先排除是否是庄
        self:changeBetChip(0)
        self._widgets.img_select:setVisible(false)
    elseif self._curBetIdx == 0 or self._curBetIdx > maxChipIdx then
        self:changeBetChip(maxChipIdx)
        -- local state = Game.betMng:getState()
        -- if maxChipIdx == 0 and self._myChipLimit>0 and state==BetState.betting then
        --     if Game.brnnDB:isBulletRoom() then
        --         Game:tipMsg("所剩玉石已无法押注")
        --     else
        --         Game:tipMsg("所剩金币已无法押注")
        --     end
        -- end
    else
        self:changeBetChip(math.max(1, self._curBetIdx), true)
    end
end

--刷新押注按钮状态
function M:updateBetChips()
    self:initBetChips()
end

function M:setBetBtnEnabled(btn,enabled)
    btn:setEnabled(enabled)
    local fnt_btnAdd = btn:getChildByName("fnt_btnAdd")
    local strColor = "#40474f"
    if enabled then
        strColor = "#1d5176"
    end
    local color = Assist.colorFromString(strColor)
    fnt_btnAdd:enableOutline(cc.c4b(color.r,color.g,color.b,255))
end

function M:changeBetChip(chipIdx, force)
    if not chipIdx or (self._curBetIdx == chipIdx and not force) then return end

    local chipList = Game.brnnDB:getChipList()
    local chipNode = self._widgets["btn_bet_"..chipIdx]
    if chipNode then
        local x,y = chipNode:getPosition()
        self._widgets.img_select:setPosition(cc.p(x,y))
        local fnt_btnAdd = self._widgets.img_select:getChildByName("fnt_btnAdd")
        fnt_btnAdd:setString(Number.measure(chipList[chipIdx]))
    end

    self._curBetIdx = chipIdx
end

--点击押注区
function M:onTouchBet(sender)
    local state = Game.betMng:getState()
    local playCoin = Game.brnnDB:getCurGold()
    --local chipList = Game.brnnDB:getChipList()
    if playCoin >= MIN_BET_COIN then
        local chipBetIdx = Number.max(self._curBetIdx,1)
        local betToIdx = sender:getTag()
        local chips = Game.brnnDB:getChipList(chipBetIdx)
        if state ~= BetState.betting then
            --为了获得服务器返回值显示信息
            Game.brnnCom:reqBet(betToIdx,chips)
            return
        end
        if playCoin >= chips then
            if self._myChipLimit >= chips then
                self._myChipLimit = self._myChipLimit - chips
                Game.brnnCom:reqBet(betToIdx,chips,handlerSafe(self,self.onBetCallback))
            else
                local idx = 0
                for i=chipBetIdx-1,1,-1 do
                    local curChips = Game.brnnDB:getChipList(i)
                    if self._myChipLimit >= curChips then
                        idx = i
                        self._myChipLimit = self._myChipLimit - curChips
                        Game.brnnCom:reqBet(betToIdx,curChips,handlerSafe(self,self.onBetCallback))
                        break
                    end
                end
                if idx == 0 then
                    Game.brnnCom:reqBet(betToIdx,chips)
                end
            end
        else
            if Game.brnnDB:isBulletRoom() then
                -- Game:doPluginAPI("enter", "exchangeJade",true)
            else
                Game.brnnCom:openRecharge()
            end
        end
    else
        if Game.brnnDB:isBulletRoom() then
            Game:tipMsg(string.format(Config.localize("brnn_tips4"),Number.measure(MIN_BET_COIN)),1.5)
            -- Game:doPluginAPI("enter", "exchangeJade",true)
        else
            Game:tipMsg(string.format(Config.localize("brnn_tips3"),Number.measure(MIN_BET_COIN)),1.5)
            Game.brnnCom:openRecharge()
        end
    end
end

--获取当前筹码按钮索引
function M:getChipIdx(chipNum)
    local chipList = Game.brnnDB:getChipList()
    local idx = 1
    for k,v in ipairs(chipList) do
        if chipNum == v then
            idx = k
            break
        end
    end
    return idx
end

--获取押注筹码在所有筹码中的位置类型
function M:getChipType(chipNum)
    local chipType = 1
    for k,v in ipairs(allChipLists) do
        if chipNum == v then
            chipType = k
            break
        end
    end
    return chipType
end

--下注回调
function M:onBetCallback(area,num)
    local chipIdx = self:getChipIdx(num)
    local chipType = self:getChipType(num)
    local betNode = self._widgets["btn_bet_"..chipIdx]
    local betArea = self._panBetArea[area]
    local chip = self:flyChip(betNode,betArea,num,0,chipType)
    self:insertToAllChip(self._allChips[area],chip)
    self:performWithDelay(function()
        Audio.playSoundConfig(self, "chip", nil, true)
    end,0.1)
    self:updateBetChips()
end

-- fly_type:其它玩家
function M:flyChip(fromNode, toNode, coin, delayTime, chipType, fly_type, is_slow)
    fly_type = fly_type or 0

    local size = fromNode:getContentSize()
    local fp = fromNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))

    local tp, intp = self:getFlyTargetPos(toNode)
    local moveTime = 0.3+math.floor(math.abs(fp.x-tp.x)/100)*0.05

    local imgChip = self:getChipFromPool()

    chipType = chipType or 1
    imgChip:loadTexture(chipIconMap[chipType],1)
    imgChip:setOpacity(255)
    imgChip.chipType = chipType
    imgChip:setVisible(false)
    imgChip:setPosition(fp)
    imgChip:setRotation(math.random(-60,60))

    local seq = {}
    table.insert(seq, cc.Show:create())

    if fly_type >= 1 and fly_type <= 4 then  --其他玩家飞金币
        local times = {0.2, 0.2, 0.2, 0.2}
        moveTime = times[fly_type]
        if dis and dis > 0 then
            moveTime = moveTime+(0.05)*dis
        end

        local mPos = cc.pMidpoint(fp, intp)
        local cPos = cc.pRotateByAngle(fp, mPos, -math.pi/2)
        cPos = cc.pMul(cPos, 0.5-0.08*(fly_type-1))

        local argPos = cc.pAdd(fp, cPos)

        local bezierCfg = {fp, argPos, intp}
        local bezierTo = cc.BezierTo:create(moveTime, bezierCfg)

        table.insert(seq, cc.EaseSineOut:create(bezierTo))

    elseif fly_type >= 10 and fly_type <= 80 then  --座位上的玩家飞金币
        moveTime = moveTime-0.2
        table.insert(seq, cc.EaseSineInOut:create(cc.MoveTo:create(moveTime, intp)))
    else
        table.insert(seq, cc.EaseSineInOut:create(cc.MoveTo:create(moveTime, intp)))
    end
    table.insert(seq,cc.ScaleTo:create(0.2,0.9))

    if delayTime then
        table.insert(seq, 1, cc.DelayTime:create(delayTime))
    end

    imgChip:runAction(transition.sequence(seq))

    return imgChip
end

function M:removeChip(fromArea, toNode, delay, all)
    if fromArea and self._allChips[fromArea] and #self._allChips[fromArea] >= 1 then
        delay = delay or 0.01
        local size = toNode:getContentSize()
        local tp = toNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        if all then
            for _, imgChip in ipairs(self._allChips[fromArea]) do
                local seq = {
                    cc.DelayTime:create(delay+Number.randomFloat(0.05, 0.2, 2)),
                    cc.JumpTo:create(0.5, tp, 50, 1),
                    cc.FadeOut:create(0.1),
                    cc.CallFunc:create(function()
                        imgChip._using = false
                        imgChip:setVisible(false)
                    end)
                }
                imgChip:runAction(transition.sequence(seq))
            end
            self._allChips[fromArea] = {}
        else
            local imgChip = table.remove(self._allChips[fromArea])
            local seq = {
                cc.DelayTime:create(delay+Number.randomFloat(0.05, 0.2, 2)),
                cc.JumpTo:create(0.5, tp, 50, 1),  
                cc.FadeOut:create(0.1),
                cc.CallFunc:create(function()
                    imgChip._using = false
                    imgChip:setVisible(false)
                end)
            }
            imgChip:runAction(transition.sequence(seq))
        end
    end
end

function M:removeAllChip()
    for i, seatChip in ipairs(self._allChips) do
        for _, chip in ipairs(seatChip) do
            if not tolua.isnull(chip) then
                chip:stopAllActions()   --防止后台切回前台时仍播筹码动画，直接同步数据显示了
                chip:setVisible(false)
                chip._using = false
            end
        end
        self._allChips[i] = {}
    end
end

--从筹码中取小的飞到奖池
function M:removeChipToJackpot(fromArea,delay)
    local jackpot = Game.brnnDB:getJackpot()
    if jackpot >= MAX_JACKPOT_COIN then  --达到奖池上限后不做筹码动画
        return
    end
    if Game.brnnDB:isBulletRoom() then
        return
    end
    if fromArea and self._allChips[fromArea] and #self._allChips[fromArea] >= 1 then
        delay = delay or 0.01
        local size = self._widgets.txt_jackpot:getContentSize()
        local tp = self._widgets.txt_jackpot:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        local idx = 1
        local minChipType = #allChipLists
        for k,v in ipairs(self._allChips[fromArea]) do
            if v.chipType<minChipType then
                minChipType = v.chipType
                idx = k
            end
        end
        local imgChip = table.remove(self._allChips[fromArea],idx)
        local seq = {
            cc.DelayTime:create(delay+Number.randomFloat(0.05, 0.2, 2)),
            cc.JumpTo:create(0.5, tp, 50, 1),  
            cc.FadeOut:create(0.1),
            cc.CallFunc:create(function()
                imgChip._using = false
                imgChip:setVisible(false)
            end)
        }
        imgChip:runAction(transition.sequence(seq))
    end
end

--点击座位
function M:onTouchSeat(sender)
    sender.touchTime = sender.touchTime or 0 -- 为了避免频繁点击,这里记录每个控件的上次点击时间
    local temp = os.time() - sender.touchTime
    if temp < 1 then
        -- 阻止1秒内多次点击
        return
    end
    sender.touchTime = os.time()
    local seatIdx = sender:getTag()
    local player = Game.brnnDB:getPlayerBySeat(seatIdx)
    if player and player.uid then
        local myUid = Game:doPluginAPI("get","playerUid")
        if player.uid == myUid then
            Game.brnnCom:reqStand(seatIdx)
        else
            --查看玩家信息
            self:onPlayerInfo(player.uid)
        end
        Audio.playSoundConfig("all","click")
    else
        if Game.brnnDB:isBanker() then
            Game:tipMsg("您是庄家,无法入座!")
        else
            Game.brnnCom:reqSitDown(seatIdx)
            if not (Game.brnnDB:sitDown()) then
                Audio.playSoundConfig(self,"enter")
            end
        end
    end
end

--展示庄家信息
function M:onShowBankerInfo()
    if not Game.brnnDB:isSystemBanker() then
        local bankerInfo = Game.brnnDB:getBankerInfo()
        self:onPlayerInfo(bankerInfo.player.uid)
    end
end

function M:onShowMyInfo()
    local uid = Game:doPluginAPI("get","playerUid")
    self:onPlayerInfo(uid)
end

--自己选择押注筹码
function M:onBetSelected(sender)
    self:changeBetChip(sender:getTag())
end

--获取各个玩家的位置
function M:getPlayerPos()
    local tb = {}
    local seat 
    for i=1,6 do
        seat = self._widgets["seat_"..i]
        local seatSize = seat:getContentSize()
        local pt = seat:convertToWorldSpace(cc.p(seatSize.width/2,seatSize.height/2))
        table.insert(tb,pt)
    end
    --庄家位置
    local bankerSize = self._widgets.img_banker_head:getContentSize()
    local bankerPt = self._widgets.img_banker_head:convertToWorldSpace(cc.p(bankerSize.width/2,bankerSize.height/2))
    table.insert(tb,bankerPt)

    --自己位置
    local headSize = self._widgets.img_my_head:getContentSize()
    local headPt = self._widgets.img_my_head:convertToWorldSpace(cc.p(headSize.width/2,headSize.height/2))
    table.insert(tb,headPt)

    --其他人位置
    local otherSize = self._widgets.btn_other:getContentSize()
    local otherPt = self._widgets.btn_other:convertToWorldSpace(cc.p(otherSize.width/2,otherSize.height/2))
    tb[-1] = otherPt

    return tb
end

--打开历史走势图
function M:onBtnRecord()
    local recordUI = Game.uiManager:getLayer("BrnnRecordUI")
    if recordUI == nil then
        Game.brnnCom:reqHistory(function()
            Game.brnnCom:openRecordUI()
        end)
    else
        recordUI:destroy()
    end
end

--打开其余玩家列表
function M:onBtnOther()
    Game.brnnCom:reqPlayerList(function()
        Game.brnnCom:openPlayerListUI()
    end)
end

--打开充值界面
function M:onBtnRecharge()
    if Game.brnnDB:isBulletRoom() then
        -- Game:doPluginAPI("enter", "exchangeJade",true)
    else
        Game.brnnCom:openRecharge()
    end
end

--更新在座玩家信息
function M:refreshSeatView()
    local sitList = Game.brnnDB:getSitList()
    if sitList then
        self:initSeatView()
        local seat
        local playerInfo
        local img_head
        local txt_name
        local img_stand
        local txt_vip
        local uid = Game:doPluginAPI("get","playerUid")
        for _,v in ipairs(sitList) do
            seat = self._widgets["seat_"..v.sitno]
            playerInfo = v.player
            img_head = seat:getChildByName("img_head")
            img_head:setVisible(true)
            Game:doPluginAPI("set","headIcon",img_head,playerInfo.iconId)
            seat:getChildByName("txt_tips"):setVisible(false)
            txt_name = seat:getChildByName("txt_name")
            txt_name:setVisible(true)
            txt_name:setString(playerInfo.name)
            Assist.checkTTF(txt_name)
            txt_vip = seat:getChildByName("txt_vip")
            txt_vip:setVisible(Game:funcIsOpen("vip"))
            txt_vip:setString("VIP"..playerInfo.vipLv)
            --只有自己坐下才有离座显示
            if playerInfo.uid == uid then
                img_stand = seat:getChildByName("img_stand")
                img_stand:setVisible(true)
                img_stand:setTag(seat:getTag())
                bindClickFunc(img_stand,handlerSafe(self,self.onStand))
            end
        end
    end
end

--离座
function M:onStand(sender)
    local sitno = sender:getTag()
    Game.brnnCom:reqStand(sitno)
    Audio.playSoundConfig("all","click")
end

--退出菜单
function M:onExitMenu()
    local panel_exit = self._widgets.panel_exit
    panel_exit:setVisible(not panel_exit:isVisible())
    if panel_exit:isVisible() then
        self:performWithDelay(function()
            panel_exit:setVisible(false)
        end,2.0)
    end
end

--上庄或者下庄
function M:onBtnBanker(sender)
    if Game.brnnDB:isBanker() then  --下庄
        local rate = GameLimitConfig.value(22)
        if rate == 0 then
            local param = {
                sTip = "本局游戏结束后下庄,是否确认下庄?",
                sBtnName1 = "确定下庄",
                sBtnName2 = "取消",
                fCallBack1 = function()
                    if Game.brnnDB:isBanker() then
                        Game.brnnDB:setBankerReadyDown(true)
                        sender:setEnabled(false)
                        local color = Assist.colorFromString("#40474f")
                        sender:getChildByName("txt_down"):enableOutline(cc.c4b(color.r,color.g,color.b,255))
                    else
                        Game:tipMsg("您已下庄")
                    end
                end,
                fCallBack2 = function()
                    Game.brnnDB:setBankerReadyDown(false)
                end
            }
            showConfirmTip(param)
        else
            local str = string.format(Config.localize("brnn_tips5"),tostring(Number.toFixed(rate/100)))
            if Game.brnnDB:isBulletRoom() then
                str = string.format(Config.localize("brnn_tips6"),tostring(Number.toFixed(rate/100)))
            end
            --手续费
            local param = {
                sTip = str,
                sBtnName1 = "确定下庄",
                sBtnName2 = "取消",
                fCallBack1 = function() 
                    if Game.brnnDB:isBanker() then
                        Game.brnnDB:setBankerReadyDown(true)
                        Game:tipMsg("本局游戏结束后下庄")
                        sender:setEnabled(false)
                        local color = Assist.colorFromString("#40474f")
                        sender:getChildByName("txt_down"):enableOutline(cc.c4b(color.r,color.g,color.b,255))
                    else
                        Game:tipMsg("您已下庄")
                    end
                end,
                fCallBack2 = function()
                    Game.brnnDB:setBankerReadyDown(false)
                end
            }
            showConfirmTip(param)
        end
    else --上庄
        Game.brnnCom:reqGetBankerList(function()
            Game.brnnCom:openBankerListUI()
        end)
    end
end

function M:onBankerUp()
    local btn_banker = self._widgets.btn_banker
    btn_banker:getChildByName("txt_up"):setVisible(false)
    btn_banker:getChildByName("txt_down"):setVisible(true)
    btn_banker:getChildByName("txt_down"):setString("上庄详情")
    Game:tipMsg("上庄成功")
end

function M:onBankerDown()
    local btn_banker = self._widgets.btn_banker
    btn_banker:getChildByName("txt_up"):setVisible(true)
    btn_banker:getChildByName("txt_down"):setVisible(false)
    local color = Assist.colorFromString("#BB7600")
    btn_banker:getChildByName("txt_down"):enableOutline(cc.c4b(color.r,color.g,color.b,255))
    btn_banker:setEnabled(true)
    Game:tipMsg(Config.localize("brnn_banker_down"))
    Game.brnnDB:setBankerReadyDown(false)
end

function M:checkPlaying()
    local flag = false
    for _,v in ipairs(self._myBetTxt) do
        if v.__curCoin > 0 then
            flag = true
            break
        end
    end
    return flag
end

--退出游戏
function M:onClose()
    self._widgets.panel_exit:setVisible(false)
    Audio.playSoundConfig("all", "back")
    local tipKey = "fish_exit_confirm"
    local params = {
        sTip = Config.localize(tipKey),
        sBtnName1 = Config.localize("que_ding"),
        sBtnName2 = Config.localize("qu_xiao"),
        fCallBack1 = function()
            Game.brnnCom:reqExitGame()
        end,
    }
    showComTip(params) 
end

--正常退出或踢出
function M:onKickOut(msg)
    self:destroy()
    Game:enterScene(ENUM.SCENCE.PLATFORM)
    if msg.data>0 then
        Game:tipError(msg.data)
    end
end

--uid获取座位号
function M:getSeatByPid(pid)
    if not pid or pid == Game:doPluginAPI("get","playerUid") then
        return nil
    end
    local playerList = Game.brnnDB:getSitList()
    for _,v in pairs(playerList or {}) do
        if v.player.uid == pid then
            return v.sitno
        end
    end
    return BRNN_SEAT_MAX+1        --其余不在座位上的人
end

function M:notifyAddBet(seatAreaInfo, delay)
    local player_id = seatAreaInfo.role_id
    local area = seatAreaInfo.area_id
    local seat = self:getSeatByPid(player_id) or 0
    if seat > BRNN_SEAT_MAX then return end
    local queue = self._betQueue[seat]
    if not queue then return end

    --此状态不飞金币
    local state = Game.betMng:getState()
    local timeleft = Game.betMng:getTimeLeft()
    if (state == BetState.reward) or (state == BetState.lottery and timeleft<10) then
        return
    end

    local addCoin = seatAreaInfo.bet_num

    if addCoin <= 0 then return end

    queue:push({id=player_id, coin=addCoin, time=0.02, area=area})
    local imgNode = self._widgets["seat_"..seat]
    if (not imgNode or imgNode.moving) then return end

    self:notifyFlyEffect(seat, delay) --开始进入递归函数 有多少个就飞多少次筹码
end

function M:notifyFlyEffect(seat, delay)
    local imgNode = self._widgets["seat_"..seat]
    if not imgNode then return end
    imgNode.moving = false

    local onCallback = function()
        local queue = self._betQueue[seat]
        local data = queue:pop()
        if not data then
            return
        end
        self:doFlyEffect(data)
    end
    if delay then
        local seq = {
            cc.DelayTime:create(delay),
            cc.CallFunc:create(onCallback),
        }
        imgNode.moving = true
        imgNode:runAction(transition.sequence(seq))
    else
        onCallback()
    end
end

--头像押注移动动画
local function showMoveAndBack(node, time, base, distance, is_right, callback)
    node:stopAllActions()
    node:setPosition(base)

    local onCallback = function()
        if callback then callback() end
    end
    local move_back0 = function()
        if is_right then
            local moveTo1 = cc.MoveTo:create(time+0.1, cc.p(base.x, base.y))
            local action1 = cc.EaseSineOut:create(moveTo1)
            node:runAction(cc.Sequence:create(action1, cc.CallFunc:create(onCallback)))
        else
            local moveTo1 = cc.MoveTo:create(time+0.1, cc.p(base.x, base.y))
            local action1 = cc.EaseSineOut:create(moveTo1)
            node:runAction(cc.Sequence:create(action1, cc.CallFunc:create(onCallback)))
        end
    end
    if is_right then
        local moveTo0 = cc.MoveTo:create(time, cc.p(base.x+distance, base.y))
        node:runAction(cc.Sequence:create(moveTo0, cc.CallFunc:create(move_back0)))
    else
        local moveTo0 = cc.MoveTo:create(time, cc.p(base.x-distance, base.y))
        node:runAction(cc.Sequence:create(moveTo0, cc.CallFunc:create(move_back0)))
    end
end

function M:doFlyEffect(data)
    local seat = self:getSeatByPid(data.id)
    if not seat then return end

    local imgNode = self._widgets["seat_"..seat]
    if not imgNode then return end

    local toNode = self._panBetArea[data.area]
    local coin = data.coin
    local chipType = #allChipLists
    while coin < checknumber(allChipLists[chipType]) do
        chipType = chipType - 1
    end
    chipType = math.max(1, chipType)

    local chip = self:flyChip(imgNode, toNode, nil, 0, chipType, 10*seat)
    chip.chipType = chipType
    self:insertToAllChip(self._allChips[data.area], chip)

    local base = cc.p(imgNode:getPosition())
    local onCallback = function()
        self:notifyFlyEffect(seat)
    end
    imgNode.moving = true

    showMoveAndBack(imgNode, data.time, base, 15, (seat < 4), onCallback)--头像框抖动一下
end

--回到前台
function M:onComeToForeGround()
    if self._background then
        self._background = false
        self:handleSync()
        Game.brnnDB:setBackground(false)
    end
end

--后台
function M:onComeToBackGround()
    if not self._background then
        self._background = true
        Game:destroyWaitUI()
        Game.brnnDB:setBackground(true)
    end
end

function M:handleSync()
    self:clear()
    self:resetPokeCache()
    self:stopAllActions()
    Game.brnnCom:reqSyncData()
end

--主界面结算信息
function M:onResultInfo()
    local info = Game.brnnDB:getResultInfo()
    if info then
        --显示区域胜利特效
        local area_win = info.area_win
        self:showAreaWinEffect(area_win)
        --筹码动画
        self:turnReward()
    end
end

--将押注金币转换成筹码组合
function M:getComboList(totalCoin)
    local comboTb = {}
    local chipList = Game.brnnDB:getChipList()
    for i=#chipList,1,-1 do
        while totalCoin > chipList[i] do
            totalCoin = totalCoin - chipList[i]
            table.insert(comboTb,chipList[i])
        end
    end
    return comboTb
end

--获取座位玩家对应区域押注金额记录
function M:getSeatBetInfo(seat_settle,area_id)
    local seatBetInfo = {}
    for _,v in ipairs(seat_settle) do
        local seat = self:getSeatByPid(v.uid)
        if seat and seat>0 and seat<=BRNN_SEAT_MAX and 
            v.area_bet and checknumber(v.area_bet[area_id])>0
            and v.num>0 then
            seatBetInfo[seat] = v.area_bet[area_id]
        end
    end
    return seatBetInfo
end

--结算筹码动画
function M:showRewardCoinAni(info,cb)
    local area_win = info.area_win
    local banker_lose = (info.banker) and (info.banker.num < 0)
    local all_lose = true
    local have_bet = false
    local have_bet_win = false      --下注区域赢
    local get_win = false
    local cardInfo = Game.brnnDB:getCardInfo()
    if cardInfo == nil then return end
    local rateInfo = {}
    for k,v in ipairs(cardInfo) do
        if k>1 then
            table.insert(rateInfo,v.rate)
        end
    end
    for k,v in ipairs(area_win) do
        if #self._allChips[k]>0 then
            have_bet = true
        end
        if v>0 then -- 赢
            if #self._allChips[k] > 0 then
                have_bet_win = true
            end
            local toNode = self._panBetArea[k]
            local count = #self._allChips[k]
            --庄家赔
            if count > 10 then
                for j=#self._allChips[k],1,-1 do
                    local chip = self:flyChip(self._widgets.img_banker_head, toNode, nil, Number.randomFloat(0.7, 0.9, 2), self._allChips[k][j].chipType)
                    self:insertToAllChip(self._allChips[k], chip,true)
                end
            else
                local chipTb = {}
                for _ =1,rateInfo[k] do
                    for kk, vv in ipairs(self._allChips[k]) do
                        table.insert(chipTb, vv)
                    end
                end
                for j=#chipTb,1,-1 do
                    local chip = self:flyChip(self._widgets.img_banker_head, toNode, nil, Number.randomFloat(0.7, 0.9, 2), chipTb[j].chipType)
                    self:insertToAllChip(self._allChips[k], chip,true)
                end
                chipTb = {}
            end

            --我赢
            if self._myBetTxt[k]:isVisible() and info.num>0 then
                get_win = true
                local j = math.max(1, math.random(2, #self._allChips[k]/10))
                while j > 0 do
                    self:removeChip(k, self._widgets.txt_my_coin, 1.5)
                    j = j - 1
                end
            end

            --在座玩家赢
            local seatBetInfo = self:getSeatBetInfo(info.seat_list,k)
            for seatIdx, _ in pairs(seatBetInfo) do
                get_win = true
                local j = math.max(1, math.random(2, #self._allChips[k]/10))
                while j > 0 do
                    self:removeChip(k, self._widgets["seat_"..seatIdx], 1.5)
                    j = j - 1
                end
            end

            if Game.brnnDB:isSystemBanker() then
                if get_win or banker_lose then
                    self:removeChipToJackpot(k,1.5)
                end
            else
                self:removeChipToJackpot(k,1.5)
            end

            --其余玩家
            self:removeChip(k, self._widgets.btn_other, 1.5, true)
            all_lose = false
            if not self._background and have_bet_win then
                --循环键值加k
                self:performWithDelay(function()
                    Audio.playSoundConfig(self,"chipdown",nil,true)
                end,1.5)
            end
        end
    end
    local delayTime = 2.0
    if all_lose then
        delayTime = 0.5
        if not Game.brnnDB:isSystemBanker() then --飞筹码到奖池
            for i=1,4 do
                self:removeChipToJackpot(i)
                self:removeChip(i, self._widgets.img_banker_head, nil, true)
            end
            if have_bet then
                Audio.playSoundConfig(self,"chipdown",nil,true)
                self:performWithDelay(handlerSafe(self,self.showJackpotAni),delayTime-0.2)
            end
        else
            for i=1, 4 do
                self:removeChip(i, self._widgets.img_banker_head, nil, true)
            end
            if have_bet then
                Audio.playSoundConfig(self,"chipdown",nil,true)
            end
        end
    else
        for i=1, 4 do
            self:removeChip(i, self._widgets.img_banker_head, nil, true)
        end
        if Game.brnnDB:isSystemBanker() then
            if get_win or banker_lose then
                Audio.playSoundConfig(self,"chipdown",nil,true)
                self:performWithDelay(handlerSafe(self,self.showJackpotAni),delayTime-0.2)
            end
        else
            if have_bet then
                Audio.playSoundConfig(self,"chipdown",nil,true)
                self:performWithDelay(handlerSafe(self,self.showJackpotAni),delayTime-0.2)
            end
        end
    end
    self:performWithDelay(function()
        if cb then
            cb()
        end
    end,delayTime)
end

--处理赔率输的情况
function M:handleRateLose(seat_list)
    local cardInfo = Game.brnnDB:getCardInfo()
    if cardInfo == nil then return end
    local rateInfo = {}
    for k,v in ipairs(cardInfo) do
        if k>1 then
            table.insert(rateInfo,v.rate)
        end
    end
    local rating = false
    for k,v in ipairs(rateInfo) do
        local coin = self._allBetTxt[k]:getTag()
        local chip
        if v<-1 and coin>0 then --倍率输
            local toNode = self._panBetArea[k]
            --其他玩家
            for j=#self._allChips[k],1,-1 do
                chip = self:flyChip(self._widgets.btn_other,toNode,nil,Number.randomFloat(0.05,0.1,2),self._allChips[k][j].chipType)
                self:insertToAllChip(self._allChips[k],chip,true)
            end

            --座位玩家
            local seatBetInfo = self:getSeatBetInfo(seat_list,k)
            for seatIdx,count in pairs(seatBetInfo) do
                local comboTb = self:getComboList(count)
                for _, coin1 in ipairs(comboTb) do
                    local chipType = self:getChipType(coin1)
                    chip = self:flyChip(self._widgets["seat_"..seatIdx],toNode,nil,Number.randomFloat(0.05, 0.1, 2), chipType)
                    self:insertToAllChip(self._allChips[k],chip,true)
                end
            end

            --自己赔
            if self._myBetTxt[k]:isVisible() then
                local count = self._myBetTxt[k].__curCoin
                local comboTb = self:getComboList(count)
                for _, coin1 in ipairs(comboTb) do
                    local idx = self:getChipIdx(coin1)
                    local chipType = self:getChipType(coin1)
                    chip = self:flyChip(self._widgets["btn_bet_"..idx],toNode,nil, Number.randomFloat(0.05, 0.1, 2), chipType)
                    self:insertToAllChip(self._allChips[k],chip,true)
                end
            end
            rating = true
        end
    end
    Audio.playSoundConfig(self, "chipdown")
    local delayTime = 0.05
    if rating then
       delayTime = 0.7
    end
    return delayTime
end

function M:turnReward(step)
    local curStep = step or 1
    local info = Game.brnnDB:getResultInfo()
    if curStep == 1 then
        local delayTime = self:handleRateLose(info.seat_list)
        self:performWithDelay(function()
            self:turnReward(curStep+1)
        end,delayTime)
    elseif curStep == 2 then
        self:showRewardCoinAni(info,function()
            if self and self.showSeatReward then
                --在座玩家的结算
                self:showSeatReward(info.seat_list)
                self:showMyReward(info.num)
                self:showBankerReward(info.banker.num)
                
                self:updateRecord()
                if self:checkPlaying() or Game.brnnDB:isBanker() then
                    local resultUI = self:getChildByName("BrnnResultUI")
                    if resultUI then
                        resultUI:updateView()
                    else
                        local timeLeft = Game.betMng:getTimeLeft()
                        if timeLeft > 0 then
                            if timeLeft > 3 then
                                timeLeft = 3
                            end
                            resultUI = self:openResultUI(timeLeft)
                        end
                    end
                    if resultUI then
                        resultUI.onClose = function()
                            resultUI:destroy()
                            --奖池发奖界面
                            local time = 0.0
                            if Game.brnnDB:haveJackpotReward() and Game.brnnDB:isCoinRoom() then
                                self:openJackpotRewardUI()
                                local jackpot = Game.brnnDB:getJackpot()
                                excFuncSafe(self,"updateJackpot",jackpot)
                                time = 3.0
                            end
                            self:performWithDelay(function()
                                local tip_code = Game.brnnDB:getServerTipsCode()
                                if tip_code > 0 then
                                    if Game.brnnDB:getKickOutStatus() then
                                        Game:tipError(tip_code, nil, handlerSafe(Game.brnnCom, Game.brnnCom.reqExitGame))
                                        Game.brnnDB:setKickOutStatus(false)
                                    else
                                        Game:tipError(tip_code)
                                    end
                                    Game.brnnDB:setServerTipsCode(0)
                                end
                            end,time)
                        end
                    end
                else
                    local time = 0.0
                    if Game.brnnDB:haveJackpotReward() and Game.brnnDB:isCoinRoom() then
                        self:openJackpotRewardUI(function()
                            --强制刷新改变状态
                            local timeLeft = Game.betMng:getTimeLeft()
                            local waitBetLeft = NnstateConfig.timelong(BetState.waitbet-1)/1000+timeLeft
                            Game.betMng:changeStateIdx(BetState.waitbet,true,waitBetLeft)
                        end)
                        local jackpot = Game.brnnDB:getJackpot()
                        excFuncSafe(self,"updateJackpot",jackpot)
                        time = 3.0
                    end
                    self:performWithDelay(function()
                        local tip_code = Game.brnnDB:getServerTipsCode()
                        if tip_code > 0 then
                            if Game.brnnDB:getKickOutStatus() then
                                Game:tipError(tip_code, nil, handlerSafe(Game.brnnCom, Game.brnnCom.reqExitGame))
                                Game.brnnDB:setKickOutStatus(false)
                            else
                                Game:tipError(tip_code)
                            end
                            Game.brnnDB:setServerTipsCode(0)
                        end
                    end,time)
                end
            end
        end)
    end
end

--显示奖池特效
function M:showJackpotAni()
    if self.__jackpotActor then
        self.__jackpotActor:setVisible(true)
        self.__jackpotActor:changeAnimation(SpineJackpot.ani,false,0)
        self:performWithDelay(function()
            if self.__jackpotActor then
                self.__jackpotActor:setVisible(false)
            end
        end,2.0)
        local jackpot = Game.brnnDB:getJackpot()
        if Game.brnnDB:haveJackpotReward() then
            local state = Game.betMng:getState()
            if state == BetState.reward then
                local jackpotReward = Game.brnnDB:getJackpotReward()
                self:updateJackpot(jackpot+jackpotReward.total_reward)
            end
        else
            self:updateJackpot(jackpot)
        end
    end
end

--显示结算区域动画
function M:showAreaWinEffect(area_win)
    for k,v in ipairs(area_win) do
        if v>0 then
            local pan_bet = self._widgets["panel_bet_"..k]
            local area = pan_bet:getChildByName("area")
            local node_spine = area:getChildByName("node_spine")
            node_spine.__ani:changeAnimation(SpineAreaWin.ani,true,0)
            node_spine:setVisible(true)
        end
    end
end 

--隐藏结算区域动画
function M:hideAreaWinEffect()
    for i=1,BRNN_AREA_COUNT do
        local pan_bet = self._widgets["panel_bet_"..i]
        local area = pan_bet:getChildByName("area")
        area:getChildByName("node_spine"):setVisible(false)
    end
end

--在座玩家的结算
function M:showSeatReward(seat_list)
    local seat
    local seatWidget
    local txt_win_coin,txt_lose_coin
    for _,v in ipairs(seat_list or {}) do
        seat = self:getSeatByPid(v.uid)
        if seat~=nil and seat<=BRNN_SEAT_MAX then
            seatWidget = self._widgets["seat_"..seat]
            if v.num > 0 then
                local node_spine = seatWidget:getChildByName("node_spine")
                node_spine.__actor:changeAnimation(SpineSeat.ani,false,0)
                node_spine.__actor:setVisible(true)
                txt_win_coin = seatWidget:getChildByName("txt_win_coin")
                txt_win_coin:setString(tostring("+"..Number.measure(v.num)))
                self:showRewardScoreAni(txt_win_coin,30)
            elseif v.num < 0 then
                txt_lose_coin = seatWidget:getChildByName("txt_lose_coin")
                txt_lose_coin:setString(tostring("-"..Number.measure(-v.num)))
                self:showRewardScoreAni(txt_lose_coin,30)
            end
        end
    end
end

function M:showMyReward(num)
    if num > 0 then
        self._widgets.txt_my_lose_coin:setVisible(false)
        self._widgets.txt_my_win_coin:setString(tostring("+"..Number.measure(num)))
        self:showRewardScoreAni(self._widgets.txt_my_win_coin,20)
    elseif num < 0 then
        self._widgets.txt_my_win_coin:setVisible(false)
        self._widgets.txt_my_lose_coin:setString(tostring("-"..Number.measure(Number.abs(num))))
        self:showRewardScoreAni(self._widgets.txt_my_lose_coin,20)
    end
end

function M:showBankerReward(num)
    if num > 0 then
        self._widgets.txt_win_bcoin:setVisible(false)
        self._widgets.txt_win_bcoin:setString(tostring("+"..Number.measure(num)))
        self:showRewardScoreAni(self._widgets.txt_win_bcoin,20)
    elseif num < 0 then
        self._widgets.txt_lose_bcoin:setVisible(false)
        self._widgets.txt_lose_bcoin:setString(tostring("-"..Number.measure(Number.abs(num))))
        self:showRewardScoreAni(self._widgets.txt_lose_bcoin,20)
    end
end

function M:showRewardScoreAni(widget, moveY)
    if widget == nil then return end
    widget:runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.MoveBy:create(0.4,cc.p(0,moveY)),
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function(node)
            node:moveVec2(cc.p(0,-moveY))
            node:setVisible(false)
        end)
        ))
end

--刷新房间数据(庄家信息和押注列表)，进入房间推送一次
function M:updateRoomInfo()
    self:updateBankerInfo()
    self:updateAreaView()
end

--庄家轮换
function M:onBankerChange()
    self:updateBankerInfo()
    self:updateBetChips()
end

--更新庄家信息
function M:updateBankerInfo()
    local bankerInfo = Game.brnnDB:getBankerInfo()
    if bankerInfo then
        local playerInfo = bankerInfo.player
        local txt_up = self._widgets.btn_banker:getChildByName("txt_up")
        local txt_down = self._widgets.btn_banker:getChildByName("txt_down")
        self._widgets.btn_banker:setEnabled(true)
        if playerInfo.uid == 0 then --系统庄
            self._widgets.txt_banker_coin:setVisible(false)
            self._widgets.txt_banker_name:setString("系统庄")
            Assist.checkTTF(self._widgets.txt_banker_name)
            self._widgets.txt_count:setVisible(false)
            fitIconSize(self._widgets.img_banker_head,DEFAULT_IMG)
            if Game.brnnDB:isInBankerQueue() then
                txt_up:setVisible(false)
                txt_down:setVisible(true)
                txt_down:setString("上庄详情")
            else
                txt_up:setString("我要上庄")
                txt_up:setVisible(true)
                txt_down:setVisible(false)
            end
            self._widgets.txt_bvip:setVisible(false)
        else
            local num = bankerInfo.num
            self._widgets.txt_banker_coin:setVisible(true)
            self._widgets.txt_banker_coin:setString(tostring(Number.measure(num)))
            self._widgets.txt_banker_name:setString(playerInfo.name)
            Assist.checkTTF(self._widgets.txt_banker_name)
            self._widgets.txt_count:setVisible(true)
            self._widgets.txt_count:setString("连庄次数:"..bankerInfo.banker_round.."/"..MAX_BANKER_COUNT)
            Game:doPluginAPI("set","headIcon",self._widgets.img_banker_head,playerInfo.iconId)
            self._widgets.txt_bvip:setVisible(Game:funcIsOpen("vip"))
            self._widgets.txt_bvip:setString("VIP"..bankerInfo.player.vipLv)
            local myUid = Game:doPluginAPI("get","playerUid")
            if playerInfo.uid == myUid then
                txt_up:setVisible(false)
                txt_down:setVisible(true)
                txt_down:setString("我要下庄")
            else
                if Game.brnnDB:isInBankerQueue() then
                    txt_up:setVisible(false)
                    txt_down:setVisible(true)
                    txt_down:setString("上庄详情")
                else
                    txt_up:setVisible(true)
                    txt_up:setString("我要上庄")
                    txt_down:setVisible(false)
                end
            end
        end
    end
end

--更新押注区界面
function M:updateAreaView()
    local area_list = Game.brnnDB:getAreaList()
    if area_list then
        local pan_bet
        local txt_allbet
        local txt_mybet
        for _,v in ipairs(area_list) do
            local areaIdx = v.area_id
            pan_bet = self._widgets["panel_bet_"..areaIdx]
            local area = pan_bet:getChildByName("area")
            txt_allbet = area:getChildByName("txt_allbet")
            txt_allbet:setString(Number.measure(v.total_bet))
            txt_allbet:setVisible(true)
            txt_mybet = area:getChildByName("txt_mybet")
            txt_mybet:setString(Number.measure(v.mine_bet))
            if v.mine_bet > 0 then
                txt_mybet:setVisible(true)
                self._myBetTxt[areaIdx].__curCoin = v.mine_bet
            end
            local pan_area = area:getChildByName("panel_area")
            pan_area:setTag(areaIdx)
            self:showAreaCoin(pan_area,v.bet_list)
        end
    end
end

--处理同步押注信息
function M:handleBetList(bet_info)
    self:playBetAni(bet_info.bet_list)
    self:updateMyBetCoin(bet_info.mine_bet)
    self:updateTotalBetCoin(bet_info.total_bet)
end

--所有人的押注动画
function M:playBetAni(bet_list)
    local otherBet = false
    for k,v in ipairs(bet_list) do
        local seat = self:getSeatByPid(v.role_id)
        if seat == nil then --自己
            --不做任何操作
        elseif seat == BRNN_SEAT_MAX+1 then
            otherBet = true
            --其他玩家筹码动画
            local chipType = self:getChipType(v.bet_num)
            local area = self._panBetArea[v.area_id]
            local chip = self:flyChip(self._widgets.btn_other,area,v.bet_num,(k%4*0.05),chipType,v.area)
            self:insertToAllChip(self._allChips[v.area_id],chip)
        else
            otherBet = true
            self:notifyAddBet(v,(k%4*0.05))
        end
    end
    if otherBet then
        self:performWithDelay(function()
            Audio.playSoundConfig(self,"chip",nil,true)
        end,0.1)
    end
end

--更新自己的区域押注
function M:updateMyBetCoin(mine_bet)
    for k,v in ipairs(mine_bet or {}) do
        self._myBetTxt[k].__curCoin = v
        self._myBetTxt[k]:setString(Number.measure(v))
        if v > 0 then
            self._myBetTxt[k]:setVisible(true)
        end
    end
end

--更新每个区域的下注总额
function M:updateTotalBetCoin(total_bet)
    for k,v in ipairs(total_bet or {}) do
        self._allBetTxt[k]:setTag(v)
        self._allBetTxt[k]:setString(Number.measure(v))
        self._allBetTxt[k]:setVisible(true)
    end
end

--显示当前区域筹码
function M:showAreaCoin(pan_area,bet_list)
    local chipType = 1
    local area_id = pan_area:getTag()
    for _,bet_coin in ipairs(bet_list) do
        for k,v in ipairs(allChipLists) do
            if v == bet_coin then
                chipType = k
                break
            end
        end
        local tp = self:getFlyTargetPos(pan_area)
        local chip = self:getChipFromPool()
        if chipIconMap[chipType] then
            chip:loadTexture(chipIconMap[chipType],1)
        end
        chip:setPosition(tp)
        chip:setVisible(true)
        chip.chipType = chipType
        self:insertToAllChip(self._allChips[area_id],chip)
    end
end

--随机选择筹码位置
function M:getFlyTargetPos(toNode)
    local size = toNode:getContentSize()
    local tp = toNode:convertToWorldSpace(cc.p(size.width/2, size.height/2))

    local l = math.random(-size.width*0.35, size.width*0.35)
    local h = math.random(-size.height*0.3, size.height*0.15)

    local intp = tp
    intp.x = intp.x + l
    intp.y = intp.y + h

    return tp, intp
end

--noUppperLimit：结算时筹码不判断上限而删除
function M:insertToAllChip(list, chip,noUpperLimit)
    table.insert(list, chip)
    if noUpperLimit then
        return
    end
    if ChipsLimit > 0 and #list > ChipsLimit then
        chip = table.remove(list, 1)
        chip._using = false
        chip:setVisible(false)
    end
end

-----------------筹码池-------------------------------
--创建普通筹码池
function M:createChipPool()
    local createCount = ChipsLimit*4*2
    for _ =1,createCount do
        local chip = self._widgets.temp_fly_coin:clone()
        self._rootNode:addChild(chip,LOCAL_ZORDER)
        chip._using = false
        chip:setVisible(false)
        table.insert(self._chipPool,chip)
    end
end

--从池中取出筹码
function M:getChipFromPool()
    local chip
    for _,v in ipairs(self._chipPool) do
        if v._using == false then
            chip = v
            break
        end
    end
    if chip == nil then
        chip = self._widgets.temp_fly_coin:clone()
        self._rootNode:addChild(chip,LOCAL_ZORDER)
        table.insert(self._chipPool,chip)
    else
        self._rootNode:reorderChild(chip,LOCAL_ZORDER)
    end
    chip:ignoreContentAdaptWithSize(true) --使用原图尺寸
    chip._using = true
    chip:setVisible(false)
    return chip
end

function M:resetChipPool()
    for _,chip in ipairs(self._chipPool) do
        chip._using = false
        chip:setVisible(false)
    end
end

-------------------扑克牌----------------------------------
--创建扑克牌
function M:createPokeCache()
    for _ =1,25 do
        local poke = self._widgets.temp_poke:clone()
        self._rootNode:addChild(poke)
        poke._using = false
        poke:setVisible(false)
        poke:getChildByName("back"):setVisible(true)
        table.insert(self._pokeCache,poke)
    end
end

function M:resetPokeCache()
    for _,v in ipairs(self._pokeCache) do
        v:removeFromParent()
    end
    self._pokeCache = {}
    self:createPokeCache()
end

--从缓存获取扑克牌
function M:getPokeFromCache()
    local poke
    for i=1,#self._pokeCache do
        poke = self._pokeCache[i]
        if poke._using == false then
            poke._using = true
            break
        end
    end
    return poke
end

--解析牌信息
function M:getPokeColorAndSize(pokeNum)
    local num = math.floor(pokeNum/10)
    local pokeColor = num%10
    local size = (num - pokeColor)/10
    return pokeColor,size
end

--排序，前三张牌构成牛,找出两张和为card_type的牌
function M:sortPoke(pokeList,card_type)
    table.sort(pokeList,function (a,b)
        return a<b
    end)
    local cloneTb = {}
    for _,v in ipairs(pokeList) do
        local _,size = self:getPokeColorAndSize(v)
        if size > 10 then
            table.insert(cloneTb,10)
        else
            table.insert(cloneTb,size)
        end
    end
    if card_type == 0 or card_type == 12 or card_type == 13 then
        
    elseif card_type == 11 then
        if cloneTb[1]~=cloneTb[2] then
            local v = pokeList[1]
            table.remove(pokeList,1)
            table.insert(pokeList,v)
        end
    else
        local checkTb = {}
        local idxTb = {}
        local len = table.maxn(pokeList)
        local find = false
        for i=1,len do
            if find then
                break
            end
            for j=i+1,len do
                local value = cloneTb[i] + cloneTb[j]
                if value==card_type or value==(card_type+10) then
                    checkTb[i] = pokeList[i]
                    checkTb[j] = pokeList[j]
                    table.insert(idxTb,j)
                    table.insert(idxTb,i)
                    find = true
                    break
                end
            end
        end
        --先移除大的索引值，不会改变小索引值内部的排序
        for _,v in ipairs(idxTb) do
            table.remove(pokeList,v)
        end
        for _,v in pairs(checkTb) do
            table.insert(pokeList,v)
        end
    end
    return pokeList
end

--发牌
function M:dealPoke(should_fly)
    local pt = self._widgets.panel_desktop:getWorldPosition()
    local poke
    for k=1,25 do
        poke = self:getPokeFromCache()
        poke:stopAllActions()
        table.insert(self._allPoke,poke)
        poke:setVisible(true)
        if should_fly then
            poke:setLocalZOrder(2000-k)
            poke:setPosition(cc.p(pt.x,pt.y+100-k))
            self:flyPoke(poke,k,k*0.05)
        else
            local targetPos = self:getPokeTargetPos(poke,k)
            poke:setLocalZOrder(1000+k)
            poke:setPosition(targetPos)
        end
    end
end

--idx:牌数组索引
--获取牌目标位置
function M:getPokeTargetPos(poke,idx)
    local pIdx = math.ceil(idx/5)
    local cIdx = idx - (pIdx-1)*5
    local pokeSize = poke:getContentSize()
    local panPoke
    local cardPad = CARD_PAD
    if pIdx == 1 then --庄家
        local card = self._widgets.card_banker
        panPoke = card:getChildByName("poke")
        cardPad = cardPad + 40
    else
        local panel_bet = self._widgets["panel_bet_"..(pIdx-1)]
        local card = panel_bet:getChildByName("card")
        panPoke = card:getChildByName("poke")
    end
    local pt = panPoke:getWorldPosition()
    local targetPos = cc.p(pt.x+cardPad*(cIdx-1)+pokeSize.width/2,pt.y+pokeSize.height/2)
    return targetPos
end

--飞牌动画
function M:flyPoke(poke,idx,delay)
    local seq = {}
    if delay then
        table.insert(seq,cc.DelayTime:create(delay))
    end
    local targetPos = self:getPokeTargetPos(poke,idx)
    local moveTo = cc.MoveTo:create(0.2,targetPos)
    table.insert(seq,moveTo)
    --显示效果
    table.insert(seq,cc.CallFunc:create(function(node)
        node:setLocalZOrder(1000+idx)
        if idx%5 == 1 then
            Audio.playSoundConfig(self,"deal",nil,true)
        end
    end))
    poke:runAction(transition.sequence(seq))
end

--根据牌型判断输赢
function M:getAreaWin(cardInfo)
    if cardInfo then
        local area_win = {}
        for i=2,#cardInfo do
            if cardInfo[i].rate > 0 then
                table.insert(area_win,1)
            else
                table.insert(area_win,0)
            end
        end
        --庄家放入一个0
        table.insert(area_win,1,0)
        return area_win
    end
end

--开牌
function M:openPoke(cardInfo)
    local idx
    local delayTime = 0
    local area_win = self:getAreaWin(cardInfo)
    local bankerType = 0
    local shouldSync = false
    for k,cards in ipairs(cardInfo) do
        self:sortPoke(cards.card_list,cards.card_type)
        if Assist.isEmpty(cards.card_list) then
            shouldSync = true
            break
        end
        for i,card in ipairs(cards.card_list) do
            local color,size = self:getPokeColorAndSize(card)
            idx = (k-1)*5 + i
            delayTime = delayTime + 0.05
            self:buildPoke(self._allPoke[idx],{color=color,size=size})
            self:foldPoke(self._allPoke[idx],delayTime,idx,function(node)
                if k>1 and cards.card_type>0 and cards.card_type<11 and i>=4 then
                    node:runAction(cc.MoveBy:create(0.1,cc.p(0,10)))
                end
            end)
        end
        if k==1 then
            bankerType = cards.card_type
        end
        delayTime = delayTime + 0.5
        self:createDraw(k,cards.card_type,delayTime-0.15,area_win[k])
        self:showScore(k,cards.card_type,delayTime-0.15,area_win[k],bankerType)
    end
    --检测到只有牌型没有牌，重新同步数据
    if shouldSync then
        self:handleSync()
    end
end

--翻牌
function M:foldPoke(poke,delay,idx,cb)
    if not poke or not poke.bg then return end
    local ZOrder = 1000+idx
    --这里重新设置下位置，防止后台切换回前台时消息太多，发牌动画还没播完
    poke:stopAllActions()
    local pt = self:getPokeTargetPos(poke,idx)
    poke:setLocalZOrder(ZOrder)
    poke:setPosition(pt)
    local seq = {
        cc.OrbitCamera:create(0.3, 1, 0, 0, -90, 0, 0),
        cc.CallFunc:create(function ()
            poke.bg:setVisible(false)
            poke:setLocalZOrder(ZOrder)
        end),
        cc.OrbitCamera:create(0.2, 1, 0, -90, -90, 0, 0),
        cc.CallFunc:create(function(node)
            if cb then
                cb(node)
            end
        end)
    }
    if delay then 
        table.insert(seq, 1, cc.DelayTime:create(delay))
    end
    poke:runAction(transition.sequence(seq))
end

function M:buildPoke(nPoke,v)
    if type(v) ~= "table" then
        v = {color = 1, size = 1}
    end
    local pokeViewStr = {"card_num", "type_small", "type_big", "bg_jqk"}
    local colorMap = {4,3,2,1}

    nPoke:setAnchorPoint(cc.p(0.5,0.5))
    nPoke.data = v
    nPoke.fg = nPoke
    nPoke.bg = nPoke:getChildByName("back")
    fitIconSize(nPoke.bg,"subgame/brnn/poke/BG2.png")
    nPoke.bg:setVisible(not v.show)
    local img_bg = nPoke:getChildByName("img_bg")
    fitIconSize(img_bg,"subgame/brnn/poke/BG1.png")
    for _, vStr in pairs(pokeViewStr) do
        local img = nPoke:getChildByName(vStr)
        local imgStr = "subgame/brnn/poke/"
        local colour = colorMap[v.color]
        if vStr == "type_small" then
            imgStr = imgStr.."HS1"..colour..".png"
        elseif vStr == "type_big" then
            imgStr = imgStr.."HS"..colour..".png"
            if v.size > 10 then
                img:setVisible(false)
            else
                img:setVisible(true)
            end
        elseif vStr == "card_num" then
            local color = "R"
            if colour == 1 or colour == 3 then
                color = "B"
            end
            local num = v.size
            imgStr = imgStr..color..num..".png"
        elseif vStr == "bg_jqk" then
            local num = v.size
            if num > 10 then
                local color = 8
                if colour == 1 or colour == 3 then
                    color = 5
                end
                imgStr = imgStr.."HS"..(color+num-11)..".png"
                img:setVisible(true)
            else
                imgStr = imgStr.."HS5.png"
                img:setVisible(false)
            end
        end
        fitIconSize(img, imgStr)
    end
    nPoke:setVisible(true)
    return nPoke
end

function M:resetPoke()
    for _,v in ipairs(self._allPoke or {}) do
        v:getChildByName("back"):setVisible(true)
        v:stopAllActions()
        v:setVisible(false)
        v._using = false
        v:setScaleX(1.0)
    end
    self._allPoke = {}
end

--桌面显示分数
function M:showScore(pIdx,v,delay,winFlag,bankerType)
    if pIdx == 1 then return end
    if Game.brnnDB:isBanker() then return end
    local areaId = pIdx-1
    local pan_bet = self._widgets["panel_bet_"..areaId]
    local score = pan_bet:getChildByName("score")
    local txt_win = score:getChildByName("txt_win")
    local txt_lose = score:getChildByName("txt_lose")
    local img_unbet = score:getChildByName("img_unbet")
    txt_win:setVisible(false)
    txt_lose:setVisible(false)
    img_unbet:setVisible(false)
    local cfg = NiuConfig[v]
    local myBetTxt = self._myBetTxt[areaId]
    if myBetTxt.__curCoin == 0 then
        img_unbet:setVisible(true)
    else
        if winFlag == 1 then
            local num = myBetTxt.__curCoin*cfg.times
            txt_win:setVisible(true)
            txt_win:setString("+"..Number.measure(num))
        else
            cfg = NiuConfig[bankerType]
            local num = myBetTxt.__curCoin*cfg.times 
            txt_lose:setVisible(true)
            txt_lose:setString("-"..Number.measure(num))
        end
    end
    local seq = {
        cc.DelayTime:create(delay),
        cc.Show:create(),
    }
    score:runAction(transition.sequence(seq))
end

--显示是牛几
function M:createDraw(pIdx, v, delay, winFlag)
    local drawPan = self._drawPanel[pIdx-1]
    if drawPan then
        local panel = self._widgets.temp_panel_draw:clone()
        local worldPos = drawPan:getWorldPosition()
        panel:setPosition(worldPos)
        panel:setVisible(false)
        self._rootNode:addChild(panel,DRAW_PANEL_ZORDER)
        table.insert(self._tempDrawPanel,panel)
        drawPan:setVisible(false)
        --local size = panel:getContentSize()
        local img_draw = panel:getChildByName("img_draw")
        img_draw:ignoreContentAdaptWithSize(true)
        local img_power = panel:getChildByName("img_power")
        local img_wuniu = panel:getChildByName("img_wuniu")
        local cfg = NiuConfig[v]
        if v == 0 then  --无牛
            img_wuniu:setVisible(true)
            img_power:setVisible(false)
            img_draw:setVisible(false)
            if delay then
                panel:setVisible(false)
                local seq = {
                    cc.DelayTime:create(delay),
                    cc.CallFunc:create(function () Audio.playSoundConfig(self, tostring(v)) end),
                    cc.Show:create(),
                }
                panel:runAction(transition.sequence(seq))
            end
            if pIdx == 1 then --庄家
                img_wuniu:loadTexture(cfg.bicon,1)
                panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_23.png",1)
            else
                if winFlag == 1 then
                    img_wuniu:loadTexture(cfg.icon,1)
                    panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_22.png",1)
                else
                    img_wuniu:loadTexture(cfg.grayIcon,1)
                    panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_20.png",1)
                end
            end
        else
            img_wuniu:setVisible(false)
            img_draw:setVisible(true)
            img_power:setVisible(true)
            if delay then
                local seq = {
                    cc.DelayTime:create(delay),
                    cc.CallFunc:create(function () Audio.playSoundConfig(self, tostring(v)) end),
                    cc.Show:create(),
                }
                panel:runAction(transition.sequence(seq))
            end
            if pIdx == 1 then
                img_draw:loadTexture(cfg.bicon,1)
                img_power:loadTexture(cfg.btimesIcon,1)
                if v<10 then
                    panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_23.png",1)
                else
                    panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_24.png",1)
                end
            else
                if winFlag == 1 then
                    img_draw:loadTexture(cfg.icon,1)
                    img_power:loadTexture(cfg.timesIcon,1)
                    if v<10 then
                        panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_22.png",1)
                    else
                        panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_24.png",1)
                    end
                else
                    img_draw:loadTexture(cfg.grayIcon,1)
                    img_power:loadTexture(cfg.graytimeIcon,1)
                    panel:setBackGroundImage("subgame/brnn/board/game_ps_bg_20.png",1)
                end
            end
        end
        return panel
    end
    return nil
end

function M:updateVip()
    local vipLv = Game:doPluginAPI("get","playerVIP")
    self._widgets.txt_my_vip:setString("VIP"..vipLv)
end
------------------------------------------------------------
--设置界面
function M:onSettingUI()
    self._widgets.panel_exit:setVisible(false)
    Game.brnnCom:onSettingUI()
end

--规则帮助界面
function M:onRuleUI()
    self._widgets.panel_exit:setVisible(false)
    Game.brnnCom:onRuleUI()
end

--打开个人信息
function M:onPlayerInfo(uid)
    Game.brnnCom:onPlayerInfo(uid)
end

--打开奖池信息
function M:onBtnJackpot()
    Game.brnnCom:onBtnJackpot()
end

function M:openJackpotInfoUI()
    Game.brnnCom:openJackpotInfoUI()
end

function M:onPayFinish()
    self._canChangeLimit = true
end

function M:onExchangeSuccess()
    self._canChangeLimit = true
end

--展示调试信息
function M:showDebugInfo()
    local info = Game.brnnDB:getDebugInfo()
    if info then
        local panel_time = self._widgets.panel_time
        local pt = panel_time:getWorldPosition()
        if self.__layout == nil then
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(700,100))
            self._rootNode:addChild(layout,LOCAL_ZORDER+1000)
            local label = ccui.Text:create(tostring(info.msg),"Arial",24)
            layout:addChild(label)
            label:setTextColor(cc.c3b(255,0,0))
            label:setPosition(cc.p(350,50))
            label:setName("label")
            layout:setPosition(cc.p(pt.x-700,pt.y+60))
            self.__layout = layout
        else
            self.__layout:getChildByName("label"):setString(tostring(info.msg))
        end
    end
end

function M:onMsgBroadcast(event)
    local data = event.data
    if data.iconId > 100 then --表情包
        self:showEmoji(data)
    else
        self._brnnGift:initSpine(data)
    end
end

function M:onSendEmoji(sender)
    local tag = sender:getTag() --cocos studio已写好
    local param = {}
    param.pos = -1
    param.role_id = -1
    param.msg = ""
    param.iconId = tag
    if Game.brnnDB:sitDown() or Game.brnnDB:isBanker() then
        Game.brnnCom:reqMagicEmoji(param)
    else
        Game:tipMsg(Config.localize("brnn_face_limit"))
    end
    self:onHideEmojiView()
end

function M:showEmoji(data)
    local sender = data.sender
    local seat
    if sender>=1 and sender <=6 then
        seat = self._widgets["seat_"..sender]
    elseif Game.brnnDB:checkBanker(data.senderId) then
        seat = self._widgets.seat_banker
    else
        Game:tipMsg(Config.localize("brnn_face_limit"))
    end
    if seat then
        local img_emoji = seat:getChildByName("img_emoji")
        img_emoji:stopAllActions()
        Game:doEffectAPI(EffType.bubble,img_emoji,0.1)
        local node_spine = img_emoji:getChildByName("emoji_spine")
        local ani = data.iconId%100
        local actor
        if node_spine.__biaoqingAni == nil then
            actor = Actor:new(SpineBiaoqing.res,SpineBiaoqing)
            actor:changeAnimation(tostring(ani),false,"0")
            node_spine:addChild(actor)
            node_spine.__biaoqingAni = actor
        else
            actor = node_spine.__biaoqingAni
            actor:changeAnimation(tostring(ani),false,"0")
        end
        if sender >=4 and sender <= 6 then
            actor:setScaleX(1)
        else
            actor:setScaleX(-1)
        end
        actor._actor:registerSpineEventHandler(function()
                img_emoji:stopAllActions()
                img_emoji:setVisible(false)
            end,sp.EventType.ANIMATION_COMPLETE)
    end
end

function M:onHideEmojiView()
    self._widgets.pan_mask:setVisible(false)
    self._widgets.pan_emoji:setVisible(false)
end

function M:showEmojiView()
    self._widgets.pan_emoji:setVisible(true)
    self._widgets.pan_mask:setVisible(true)
end

function M:onServerGlobalTips(event)
    local tip_code = event.data
    Game.brnnDB:setServerTipsCode(tip_code)
end

function M:onReloadGame()
    self:handleSync()
end

--输分退出游戏
function M:onServerKickOutGame()
    Game.brnnDB:setKickOutStatus(true)
end

--刷新胜负纪录
function M:updateRecord()
    local BrnnRecordUI = Game.uiManager:getLayer("BrnnRecordUI")
    if BrnnRecordUI then
        Game.brnnCom:reqHistory(function()
            excFuncSafe(BrnnRecordUI,"updateView")
        end)
    end
end

--打开结算界面
function M:openResultUI(timeleft)
    local resultUI = Game.brnnCom:openResultUI(timeleft)
    resultUI:setName("BrnnResultUI")
    self:addChild(resultUI,ENUM.UI_Z.DIALOG)
    return resultUI
end

--打开奖池开奖界面
function M:openJackpotRewardUI(cb)
    local ui = Game.brnnCom:openJackpotUI(cb)
    self:addChild(ui,ENUM.UI_Z.DIALOG)
    return ui
end

return M