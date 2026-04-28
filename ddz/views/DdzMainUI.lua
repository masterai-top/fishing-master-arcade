local UIBase = require_ex("ui.base.UIBase")
local Actor = require_ex("ui.base.Actor")
local Player = require_ex("games.ddz.views.DdzPlayer")
local M = class("DdzMainUI", UIBase)

local _TAG = "ddz"
local SOUND_TAG = "DDZUI"
local SPAN = 60

local BEI_SHU_SCALE = {0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.56, 0.52, 0.48, 0.43}

local SpineList = {
	{res = "subgame/ddz/spine/feiji/ddz_fj", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/huojian/ddz_hj", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/liandui/ddz_ld", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/shunzi/ddz_sz", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/zhadan/ddz_zd", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/chuntian/ddz_ct", ani = "1", isLoop = false},
	{res = "subgame/ddz/spine/dengdaipeizhuo/ddz_ddpz", ani = "1"},
}

function M:ctor()
	UIBase.ctor(self)
	self:init()
end

function M:init()
	self._BindWidget = {
		["pan_bg"] = {key = "pan_bg"},
		["pan_touch"] = {key = "pan_touch", handle = handlerSafe(self, self.onTouchBg)},

		["node_spine"] = {},

		["pan_top/img_title"] = {key = "img_title"},
		["pan_top/img_desc"] = {key = "img_desc"},
		["pan_top/txt_rate"] = {key = "txt_rate"},
		["pan_top/pos_1"] = {key = "pos_1"},
		["pan_top/pos_2"] = {key = "pos_2"},
		["pan_top/pos_3"] = {key = "pos_3"},
		["pan_top/pan_di"] = {key = "pan_di", hide=true},
		["pan_top/pan_di/card_1"] = {key = "card_1"},
		["pan_top/pan_di/card_2"] = {key = "card_2"},
		["pan_top/pan_di/card_3"] = {key = "card_3"},

		["player_1"] = {},
		["player_2"] = {},
		["player_3"] = {},

		["pan_jiaofen"] = {},
		["pan_jiaofen/btn_bujiao"] = {key = "btn_bujiao", handle = handlerSafe(self, self.onBuJiao)},
		["pan_jiaofen/btn_yifen"] = {key = "btn_yifen", tag = 1, handle = handlerSafe(self, self.onJiaoFen)},
		["pan_jiaofen/btn_liangfen"] = {key = "btn_liangfen", tag = 2, handle = handlerSafe(self, self.onJiaoFen)},
		["pan_jiaofen/btn_sanfen"] = {key = "btn_sanfen", tag = 3, handle = handlerSafe(self, self.onJiaoFen)},
	
		["pan_operator"] = {},
		["pan_operator/btn_pass"] = {key = "btn_pass", handle = handlerSafe(self, self.onPass)},
		["pan_operator/btn_tips"] = {key = "btn_tips", handle = handlerSafe(self, self.onTipsGoPoke)},
		["pan_operator/btn_go"] = {key = "btn_go", handle = handlerSafe(self, self.onGoPoke)},
		["pan_operator/btn_yaobuqi"] = {key = "btn_yaobuqi", hide=true, handle = handlerSafe(self, self.onPass)},

		["pan_hand_poke"] = {key = "pan_hand_poke"},

		["pan_mask"] = {},
		["pan_mask/btn_cancel"] = {key = "btn_cancel", handle = handlerSafe(self, self.onCancelTrustee)},

		["pan_result"] = {},
		["pan_result/btn_back"] = {key = "btn_back", handle = handlerSafe(self, self.onBack)},
		["pan_result/btn_again"] = {key = "btn_again", handle = handlerSafe(self, self.onPlayGameAgain)},

		["pan_tips"] = {hide = true},
		["pan_tips/img_1"] = {key = "img_1"}, -- 牌型不合理
		["pan_tips/img_2"] = {key = "img_2"}, -- 没牌大过上家

		["temp_poke"] = {}
	}
	self:initData()
	self:initViews()
end

function M:initData()
	self._playerList = {}		-- 玩家集合
	self._bankerCardList = {}	-- 地主牌
	self._handPoke = {}			-- 手牌
	self._curTipIdx = 0			-- 当前提示索引
	self._lastOtherGoPoke = {} 	-- 判断自身出牌的上手牌
	self._firstRound = true 	-- 第一回合

	self._jfFirst = true 		-- 首轮叫分
	self._cpFirst = true 		-- 首轮出牌

	self._debugPoke2 = {}		-- 测试用
	self._debugPoke3 = {}		-- 测试用
end

function M:initViews()
	local uiNode = createCsbNode("subgame/ddz/ddz_main.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._ddzBg = require_ex("games.ddz.views.DdzBgUI").new(self)
    self._ddzBg:showAllFarmer()
    self._ddzBg:hideRechargeBtn()
    self:initPlayers()
    self:scheduleUpdate()
    self:adjustMarquee()
    self:initBeiShu()
    self._widgets.pan_hand_poke:addTouchEventListener(handlerSafe(self, self.onTouchHandPoke))
    if Game.ddzDB:isReconnect() then
    	self:onRebuildRoom()
    else
    	self:showMatchPlayer()
    end
    self:handleDebugInfo()
end

function M:onEnter()
	UIBase.onEnter(self)
	if Game.ddzDB:isReconnect() then
	    Audio.stopAllSounds()
	    Audio.playSoundConfig("DDZUI", "bgm")
	end
end

function M:registerListenEvent()
	self:listenCustomEvent(GEvent(_TAG, "deal_card"), handlerSafe(self, self.handleDealCard))
	self:listenCustomEvent(GEvent(_TAG, "call"), handlerSafe(self, self.handleCallScore))
	self:listenCustomEvent(GEvent(_TAG, "out_cards"), handlerSafe(self, self.handleOutCards))
	self:listenCustomEvent(GEvent(_TAG, "define_banker"), handlerSafe(self, self.handleDefineBanker))
	self:listenCustomEvent(GEvent(_TAG, "pass_card"), handlerSafe(self, self.handlePassCard))
	self:listenCustomEvent(GEvent(_TAG, "cancel_trustee"), handlerSafe(self, self.handleCancelTrustee))
	self:listenCustomEvent(GEvent(_TAG, "trustee"), handlerSafe(self, self.handleTrustee))
	self:listenCustomEvent(GEvent(_TAG, "turn"), handlerSafe(self, self.handleTurn))
	self:listenCustomEvent(GEvent(_TAG, "settlement"), handlerSafe(self, self.handleSettlement))
	self:listenCustomEvent(GEvent(_TAG, "debug_info"), handlerSafe(self, self.handleDebugInfo))
	self:listenCustomEvent(GEvent(_TAG, "bei_shu"), handlerSafe(self, self.updateBeiShu))
	self:listenCustomEvent(GEvent(_TAG, "countdown_finish"), handlerSafe(self, self.onCountdownFinish))
	self:listenCustomEvent(GEvent(_TAG, "sync_data"), handlerSafe(self, self.onRebuildRoom))
    self:listenCustomEvent(GEvent(_TAG, "exit_game"), handlerSafe(self, self.handleExitGame))
    self:listenCustomEvent(GEvent(_TAG, "touch_bg"), handlerSafe(self, self.onTouchBg))
    self:listenCustomEvent(cc.EVENT_COME_TO_FOREGROUND, handlerSafe(self, self.onComeToForeGround))
    self:listenCustomEvent(cc.EVENT_COME_TO_BACKGROUND, handlerSafe(self, self.onComeToBackGround))
end

function M:adjustMarquee()
	local pos = cc.p(display.width/2, 3000)
	Game:doPluginAPI("move", "marquee", pos)
end

-- 倒计时
function M:updateFunc(dt)
	for _, player in ipairs(self._playerList) do
		player:updateFunc(dt)
	end
end

function M:initPlayers()
	for i=1,3 do
		local player = Player.new(self._widgets["player_"..i], i)
		table.insert(self._playerList, player)
	end
end

-- 匹配玩家特效
function M:showMatchPlayer()
	local actor = Actor:new(SpineList[7].res, SpineList[7])
	self._widgets.node_spine:addChild(actor)
	self._ddpzActor = actor
end

function M:hideMatchPlayer()
	if not Assist.isEmpty(self._ddpzActor) then
		self._ddpzActor:removeFromParent(true)
		self._ddpzActor = nil
	end
end

function M:onTouchBg()
	-- 点击背景重置选好的牌
	self:unselectPokes()
	self._curTipIdx = 0
	if self._playerList[1]:isMyTurn() and 
		self._widgets.pan_operator:isVisible() and
		self._widgets.btn_yaobuqi:isVisible() then
		self:onPass()
	end
end

-- 取消选牌
function M:unselectPokes()
	for _, poke in ipairs(self._handPoke) do
		poke:unselected()
	end
	self:changeYellowBtnEnabled(self._widgets.btn_go, false)
end

function M:onTouchHandPoke(sender, eventType)
	local pt, localPos
	if eventType == ccui.TouchEventType.began then
		pt = sender:getTouchBeganPosition()
        localPos = sender:convertToNodeSpace(pt)
        self._beginPos = localPos

	elseif eventType == ccui.TouchEventType.moved then
		pt = sender:getTouchMovePosition()
        localPos = sender:convertToNodeSpace(pt)

	elseif eventType == ccui.TouchEventType.ended
	or eventType == ccui.TouchEventType.canceled then
		pt = sender:getTouchEndPosition()
        localPos = sender:convertToNodeSpace(pt)
	end

	local selectIdx = self:checkSelectPokes(localPos)
	if eventType == ccui.TouchEventType.ended
		or eventType == ccui.TouchEventType.canceled then
		if Assist.isEmpty(selectIdx) then
			self:unselectPokes()
		else
			for k, _ in pairs(selectIdx) do
				self._handPoke[k]:setColor(cc.c3b(255, 255, 255))
			end

			-- 判断之前有没提起的牌，如有 现在选中的牌全部提起
			local checkHaveSel = false
			for _, poke in ipairs(self._handPoke) do
				if poke:isSelected() then
					checkHaveSel = true
					break
				end
			end

			if checkHaveSel then
				for k, _ in pairs(selectIdx) do
					if self._handPoke[k]:isSelected() then
						self._handPoke[k]:setSelected(false)
					else
						self._handPoke[k]:setSelected(true)
					end
				end
			else
				-- 这里需要做个顺子的判断
				local pokeData, map = {}, {}
				local count,value = 1
				for k, _ in pairs(selectIdx) do
					value = self._handPoke[k]:getClientCardValue()
					table.insert(pokeData, value)
					map[count] = k
					count = count + 1
				end
				
				local ret1 = Game.ddzRule:findSequenceFromPokes(pokeData)
				local ret2 = Game.ddzRule:findLianduiFromPokes(pokeData)
				local ret3 = Game.ddzRule:findFeijiFromPokes(pokeData)
				local ret
				if #ret1>#ret2/2 and #ret1>#ret3 then
					ret = ret1
				elseif #ret2/2>#ret1 and #ret2/2>#ret3 then
					ret = ret2
				else
					ret = ret3
				end
				if Assist.isEmpty(ret) then
					for k, _ in pairs(selectIdx) do
						if self._handPoke[k]:isSelected() then
							self._handPoke[k]:setSelected(false)
						else
							self._handPoke[k]:setSelected(true)
						end
					end
				else
					self:unselectPokes()
					for _, v in ipairs(ret) do 
						local idx = map[v]
						self._handPoke[idx]:setSelected(true)
					end
				end
			end
			self:showBtnGoEnabled()
		end
	end
end

-- 根据滑动位置选牌
function M:checkSelectPokes(localPos)
	local selectIdx = {}
	local maxX = Number.max(localPos.x, self._beginPos.x)
    local minX = Number.min(localPos.x, self._beginPos.x)
    local maxY = Number.max(localPos.y, self._beginPos.y)
	for k, poke in ipairs(self._handPoke) do
		local rect = poke:getBoundingBox()

		-- 判断滑动区域牌选中
		if maxY<=rect.y+rect.height then
			local pokeRectMinX = rect.x
	        local pokeRectMaxX = rect.x + SPAN
	        if (pokeRectMinX >= minX and pokeRectMinX <= maxX)
	            or (pokeRectMaxX >= minX and pokeRectMaxX <= maxX) then
	            selectIdx[k] = true
	        end
	    end

	    -- 最外面的牌选中区域宽度为全部
		if k~=1 then
			rect.width = SPAN
		end

		-- 当前选中哪张牌
		if cc.rectContainsPoint(rect, localPos) then
			selectIdx[k] = true
		end

		if selectIdx[k] == nil then
			poke:setColor(cc.c3b(255, 255, 255))
		else
			poke:setColor(cc.c3b(159, 168, 176))
		end
	end
	return selectIdx
end
-------------------------------------------------------------------
-- 发牌
function M:handleDealCard()
	-- 隐藏匹配特效
	self:hideMatchPlayer()
	-- 叫分流局则清除底牌重新来过(如果有)
	self:clearBankerCardList()
	-- 重新发牌取消托管
	Game.ddzDB:setTuoguan(false)
	self._widgets.pan_mask:setVisible(false)
	-- 隐藏之前的叫分(如果有)
	local playersInfo = Game.ddzDB:getPlayersInfo()
	for idx, player in ipairs(self._playerList) do
		local info = playersInfo[idx].player_base_info or playersInfo[idx]
		player:setBaseInfo(info)
		player:hideJiaoFen()
		player:resetPokeNum()
	end
	-- 清理之前的牌(如果有)
	self:clearHandPoke()

	self._jfFirst = true

	-- 发牌时手牌区域不可点击
	self._widgets.pan_hand_poke:setTouchEnabled(false)

	local originPokesData = table.newclone(Game.ddzDB:getOriginPokesData())
	for _, v in ipairs(originPokesData) do
		local poke = Game.ddzDB:getCardFromPool(v, self._widgets.pan_hand_poke)
		table.insert(self._handPoke, poke)
	end
	self:adjustHandPokePos()

	-- 发牌动画
	local function _dealPokeAni(poke, delayTime, cb)
		local seq = {
			cc.DelayTime:create(delayTime),
			cc.Show:create(),
			cc.EaseBackOut:create(cc.MoveBy:create(0.15, cc.p(-10, 0))),
			cc.CallFunc:create(function()
				Audio.playSoundConfig(SOUND_TAG, "fapai")
				for _, player in ipairs(self._playerList) do
					player:addDealPokeNum()
				end
			end),
			cc.EaseBackOut:create(cc.MoveBy:create(0.15, ccp(10, 0))),
		}
		poke:runAction(transition.sequence(seq))
	end
	local delayTime = 0
	for i=#self._handPoke, 1, -1 do
		self._handPoke[i]:setVisible(false)
		_dealPokeAni(self._handPoke[i], delayTime)
		delayTime = delayTime + 0.1
	end

	-- 发完牌后排序显示
	self:performWithDelay(function()
		table.sort(originPokesData)
		local function _moveAndBack(idx, poke)
			local moveOffsetX = (idx-8)*SPAN
			local seq = {
				cc.MoveBy:create(0.2, cc.p(moveOffsetX, 0)),
				cc.CallFunc:create(function(node)
					node:changeValue(originPokesData[idx])
				end),
				cc.MoveBy:create(0.2, cc.p(-moveOffsetX, 0))
			}
			poke:runAction(transition.sequence(seq))
		end
		for k, poke in ipairs(self._handPoke) do
			_moveAndBack(k, poke)
		end

		-- 显示三张地主牌,手牌区域可点击
		self:performWithDelay(function()
			self:playBankerCardAni()
			self._widgets.pan_hand_poke:setTouchEnabled(true)
			
		end, 0.6)
	end, delayTime+0.3)
end

-- 三张底牌动画，从中间向两边散开
function M:playBankerCardAni()
	local function _getPoke(parent)
		local poke = Game.ddzDB:getCardFromPool(310,parent)
		poke:setAnchorPoint(cc.p(0.5, 0.5))
		poke:setScale(0.8)
		poke:showMask()
		return poke
	end
	local pos1X = self._widgets.pos_1:getPositionX()
	local pos2X = self._widgets.pos_2:getPositionX()
	local poke1 = _getPoke(self._widgets.pos_1)
	poke1:setPosition(cc.p(pos2X-pos1X, 0))
	table.insert(self._bankerCardList, poke1)

	local poke2 = _getPoke(self._widgets.pos_2)
	poke2:setPosition(cc.p(0, 0))
	table.insert(self._bankerCardList, poke2)

	local poke3 = _getPoke(self._widgets.pos_3)
	poke3:setPosition(cc.p(pos1X-pos2X, 0))
	table.insert(self._bankerCardList, poke3)

	poke1:runAction(cc.MoveBy:create(0.2, cc.p(pos1X-pos2X, 0)))
	poke3:runAction(cc.MoveBy:create(0.2, cc.p(pos2X-pos1X, 0)))
end

-- 翻牌
function M:flodPoke(poke, delay)
	local seq = {
		cc.DelayTime:create(checknumber(delay)),
        cc.OrbitCamera:create(0.2, 1, 0, 0, -90, 0, 0),
        cc.CallFunc:create(function (node)
        	Audio.playSoundConfig(SOUND_TAG, "fanpai")
            node:hideMask()
        end),
        cc.OrbitCamera:create(0.2, 1, 0, -90, -90, 0, 0),
    }
    poke:runAction(transition.sequence(seq))
end

-- 调整手牌位置
function M:adjustHandPokePos()
	local gapX = SPAN
	local pokeSize = self._handPoke[1]:getBoundingBox()
	local handPokeSize = self._widgets.pan_hand_poke:getContentSize()
	local allLength = pokeSize.width+gapX*(#self._handPoke-1)
	-- 显示适配
	if allLength >= (display.width-40) then
		gapX = Number.floor((display.width-40-pokeSize.width)/(#self._handPoke-1))
	end
	local x = (handPokeSize.width+pokeSize.width+gapX*(#self._handPoke-1))/2 - pokeSize.width
	for k, onePoke in ipairs(self._handPoke) do
		onePoke:unselected()
		onePoke:setPosition(x, -6)
		onePoke:setLocalZOrder(1000-k)
		x = x - gapX
	end
end

-- 叫分
function M:handleCallScore(event)
	self._jfFirst = false
	local data = event.data
	local clientPos = Game.ddzDB:convertToClientPos(data.call_player)
	self._playerList[clientPos]:handleBeforeAction()
	self:playScoreSound(data.score)
	self._widgets.pan_jiaofen:setVisible(false)
	self:performWithDelay(function()
		self._playerList[clientPos]:handleCallScore(data)
	end, 0.1)
end

-- 叫分音效
function M:playScoreSound(score)
	if score == 0 then
		Audio.playSoundConfig(SOUND_TAG, "bu_jiao")
	elseif score == 1 then
		Audio.playSoundConfig(SOUND_TAG, "yi_fen")
	elseif score == 2 then
		Audio.playSoundConfig(SOUND_TAG, "liang_fen")
	elseif score == 3 then
		Audio.playSoundConfig(SOUND_TAG, "san_fen")
	end
end

-- 出牌
function M:handleOutCards(event)
	self._cpFirst = false
	local data = event.data
	local clientPos = Game.ddzDB:convertToClientPos(data.out_card_player)
	if clientPos == 1 then -- 清理手牌存储数据
		local newPokeList, mapPoke = {}, {}
		for _, v in ipairs(data.card_data) do
			mapPoke[v] = true
		end
		for _, poke in ipairs(self._handPoke) do
			local cardV = poke:getSvrCardValue()
			if mapPoke[cardV] then
				Game.ddzDB:pushCardPool(poke)
			else
				table.insert(newPokeList, poke)
			end
		end
		self._handPoke = newPokeList
		if not Assist.isEmpty(self._handPoke) then
			self:adjustHandPokePos()
		end
		self._lastOtherGoPoke = {}
	else
		self._lastOtherGoPoke = {}
		table.sort(data.card_data)
		for _, v in ipairs(data.card_data) do
			table.insert(self._lastOtherGoPoke, Number.floor(v/100))
		end
	end

	self._playerList[clientPos]:handleBeforeAction()
	self:performWithDelay(function ()
		self._playerList[clientPos]:handleGoPoke(data)
		Audio.playSoundConfig(SOUND_TAG, "poke_down")
	end, 0.1)

	-- 刷新顶部地主牌打勾显示
	self:updateBankerCardOccur(data.banker_out)

	-- 特殊牌型特效显示
	self:showPokeSoundAndEffect(clientPos, data.card_data)
	self._widgets.pan_operator:setVisible(false)
end

function M:checkOtherPassCard(clientPos)
	local pass = true
	for cltpos, player in ipairs(self._playerList) do
		if clientPos~=cltpos then
			if not player:isPassCard() then
				pass = false
				break
			end
		end
	end
	return pass
end

function M:checkSelectOriginSound(clientPos)
	local checkPassCard = self:checkOtherPassCard(clientPos)
	local random = Number.random(0, 1)
	local ret = false
	if checkPassCard or random==0 or self._firstRound then
		ret = true
	end
	self._firstRound = false
	return ret
end

function M:playPokeSound(pokeInfo, clientPos)
	local soundName = "bigger"
	if pokeInfo.poke_t == PaiXing.DAN_ZHANG then
		soundName = string.format("single_%d", pokeInfo.poke_v)
	elseif pokeInfo.poke_t == PaiXing.DUI_ZI then
		soundName = string.format("double_%d", pokeInfo.poke_v)
	elseif pokeInfo.poke_t == PaiXing.SAN_ZHANG then
		if self:checkSelectOriginSound(clientPos) then
			soundName = string.format("three_%d", pokeInfo.poke_v)
		end
	elseif pokeInfo.poke_t == PaiXing.SAN_DAI_YI then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "three_with_one"
		end
	elseif pokeInfo.poke_t == PaiXing.SAN_DAI_ER then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "three_with_pair"
		end
	elseif pokeInfo.poke_t == PaiXing.SI_DAI_ER then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "si_dai_er"
		end
	elseif pokeInfo.poke_t == PaiXing.SI_DAI_ER_DUI then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "si_dai_liang_dui"
		end
	elseif pokeInfo.poke_t == PaiXing.WANG_ZHA then
		soundName = "huojian"
	elseif pokeInfo.poke_t == PaiXing.ZHA_DAN then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "zhadan"
		end
	elseif pokeInfo.poke_t == PaiXing.SHUN_ZI then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "shunzi"
		end
	elseif pokeInfo.poke_t == PaiXing.FEI_JI or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_ONE 
		or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_TWO then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "airplane"
		end
	elseif pokeInfo.poke_t == PaiXing.LIAN_DUI then
		if self:checkSelectOriginSound(clientPos) then
			soundName = "liandui"
		end
	end
	Audio.playSoundConfig(SOUND_TAG, soundName)
end

function M:showPokeSoundAndEffect(clientPos, card_data)
	-- 检测牌型，特效处理
	local pokeData = {}
	for _, v in ipairs(card_data) do
		table.insert(pokeData, Number.floor(v/100))
	end
	local pokeInfo,actor = Game.ddzRule:createPokeInfo(pokeData)
	self:playPokeSound(pokeInfo, clientPos)
	if clientPos == 1 then
		if pokeInfo.poke_t == PaiXing.SHUN_ZI then
			actor = Actor:new(SpineList[4].res, SpineList[4])
			Audio.playSoundConfig(SOUND_TAG, "effect_shun_zi")
		elseif pokeInfo.poke_t == PaiXing.FEI_JI or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_ONE 
			or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_TWO then
			actor = Actor:new(SpineList[1].res, SpineList[1])
			Audio.playSoundConfig(SOUND_TAG, "effect_airplane")
		elseif pokeInfo.poke_t == PaiXing.LIAN_DUI then
			actor = Actor:new(SpineList[3].res, SpineList[3])
			Audio.playSoundConfig(SOUND_TAG, "effect_lian_dui")
		end
	end
	if pokeInfo.poke_t == PaiXing.WANG_ZHA then
		actor = Actor:new(SpineList[2].res, SpineList[2])
		Audio.playSoundConfig(SOUND_TAG, "effect_huo_jian")
	elseif pokeInfo.poke_t == PaiXing.ZHA_DAN then
		actor = Actor:new(SpineList[5].res, SpineList[5])
		Audio.playSoundConfig(SOUND_TAG, "effect_zha_dan")
		self:performWithDelay(function()
			Audio.playSoundConfig(SOUND_TAG, "effect_bomb")
		end, 0.2)
	end
	if actor then
		self._widgets.node_spine:addChild(actor)
		local displayNode = actor:getDisplayNode()
		displayNode:registerSpineEventHandler(function(event)
			self:performWithDelay(function()
				actor:removeFromParent()
			end,0.1)
		end,sp.EventType.ANIMATION_COMPLETE)
	end
end

-- 更新顶部三张底牌和底分倍数信息
function M:updateTopInfo()
	local bankerInfo = Game.ddzDB:getBankerInfo()
	self._widgets.img_title:setVisible(false)
	self._widgets.pan_di:setVisible(true)
	for k, v in ipairs(bankerInfo.banker_card) do
		self:handleSmallCard(self._widgets["card_"..k], v)
	end
	self:updateBeiShu()
end

function M:initBeiShu()
	local baseScore = Game.ddzDB:getBaseScore()
	local str = string.format("%dx1",baseScore)
	local len = string.len(str)
	local scale = BEI_SHU_SCALE[len] or BEI_SHU_SCALE[#BEI_SHU_SCALE]
	self._widgets.txt_rate:setString(str)
	self._widgets.txt_rate:setScale(scale)
	self._widgets.txt_rate:setVisible(true)
	self._widgets.img_desc:setVisible(false)
end

function M:updateBeiShu()
	-- 倍数显示
	local bankerInfo = Game.ddzDB:getBankerInfo()
	local baseScore = Game.ddzDB:getBaseScore()
	local beishu = Game.ddzDB:getBeishu()
	local strTxt = string.format("%dx%d", baseScore,bankerInfo.banker_score*beishu)
	local len = string.len(strTxt)
	local scale = BEI_SHU_SCALE[len] or BEI_SHU_SCALE[#BEI_SHU_SCALE]
	self._widgets.txt_rate:setString(strTxt)
	self._widgets.txt_rate:setScale(scale)
	self._widgets.txt_rate:setVisible(true)
	self._widgets.img_desc:setVisible(false)
end

-- 确定庄家
function M:handleDefineBanker(event)
	local bankerInfo = Game.ddzDB:getBankerInfo()
	local banker_card = bankerInfo.banker_card
	-- 翻牌动画
	local delay = 0.1
	for k, v in ipairs(self._bankerCardList) do
		v:reverseCardValue(banker_card[k])
		self:flodPoke(v, delay)
		delay = delay + 0.4
	end
	self:performWithDelay(function()
		local function _pokeAni(k, poke)
			poke:setAnchorPoint(cc.p(0.5, 0.5))
			local card_world_pos = getWorldCenterPos(self._widgets["card_"..k])
			local card_local_pos = self._widgets["pos_"..k]:convertToNodeSpace(card_world_pos)
			local moveTo = cc.MoveTo:create(0.3, card_local_pos)
			local scaleTo = cc.ScaleTo:create(0.25, 0.01)
			local spawn = cc.Spawn:create(moveTo, scaleTo)
			local seq = {
				spawn,
				cc.Hide:create(),
				cc.CallFunc:create(function(node)
					-- OrbitCamera动作lua层无法使用setAdditionalTransform清理，故直接销毁
					node:removeFromParent(true)
				end)
			}
			poke:runAction(transition.sequence(seq))
		end
		-- 底牌飞向
		for k, v in ipairs(self._bankerCardList) do
			_pokeAni(k, v)
		end
		self._bankerCardList = {}
		self:performWithDelay(function()
			local clientPos = Game.ddzDB:convertToClientPos(bankerInfo.banker_player)
			if clientPos == 1 then
				-- 插牌 重整牌型
				local originPokes = Game.ddzDB:getOriginPokesData()
				local threeMap, poke = {}
				for k, v in ipairs(bankerInfo.banker_card) do
					poke = Game.ddzDB:getCardFromPool(v, self._widgets.pan_hand_poke)
					table.insert(self._handPoke, poke)
					table.insert(originPokes, v)
					threeMap[v] = true
				end
				Game.ddzDB:setOriginPokesData(originPokes)
				table.sort(originPokes)
				for k, v in ipairs(originPokes) do
					self._handPoke[k]:changeValue(v)
				end
				self:adjustHandPokePos()
				for _, v in ipairs(self._handPoke) do
					local value = v:getSvrCardValue()
					if threeMap[value] and not v:isSelected() then
						v:setSelected(true)
					end
				end
				self:performWithDelay(function()
					for _, v in ipairs(self._handPoke) do
						if v:isSelected() then
							v:playUnselectedAni()
						end
					end
				end, 0.5)
			end
			-- 更新牌数
			self._playerList[clientPos]:updatePokeNum(-3)
			-- 确定庄家
			Audio.playSoundConfig(SOUND_TAG, "dizhu")
			self._ddzBg:ensureLandlord(clientPos)
			-- 设置玩家信息
			for _, player in ipairs(self._playerList) do
				player:updatePokeNum(0)
				player:hideJiaoFen()
				player:setBanker(clientPos)
			end
			self:updateTopInfo()
		end, 0.3)
	end, delay+0.2)
end

-- 顶部的三个小牌
function M:handleSmallCard(cardItem, card_v)
	cardItem:setTag(card_v)
	local img_size = cardItem:getChildByName("img_size")
	local img_color = cardItem:getChildByName("img_color")
	local img_occur = cardItem:getChildByName("img_occur")
	local img_small_joker = cardItem:getChildByName("img_small_joker")
	local img_big_joker = cardItem:getChildByName("img_big_joker")
	local value = Number.floor(card_v/100)
	local color = Number.floor(card_v/10) - value*10

	img_occur:setVisible(false)
	if value == 21 then
		img_small_joker:setVisible(true)
		img_big_joker:setVisible(false)
		img_size:setVisible(false)
		img_color:setVisible(false)
	elseif value == 22 then
		img_big_joker:setVisible(true)
		img_small_joker:setVisible(false)
		img_size:setVisible(false)
		img_color:setVisible(false)
	else
		local idx = value*10 + color
		fitIconSize(img_size, DdzPokeConfig.res(idx))
		fitIconSize(img_color, DdzPokeConfig.res(color))
		img_small_joker:setVisible(false)
		img_big_joker:setVisible(false)
		img_color:setVisible(true)
		img_size:setVisible(true)
	end
end

function M:updateBankerCardOccur(data)
	local mapOccur = {}
	for _, v in ipairs(data) do
		mapOccur[v] = true
	end
	for i=1, 3 do
		local cardItem = self._widgets["card_"..i]
		if mapOccur[cardItem:getTag()] then
			local img_occur = cardItem:getChildByName("img_occur")
			img_occur:setVisible(true)
		end
	end
end

-- 过牌
function M:handlePassCard(event)
	local data = event.data
	local clientPos = Game.ddzDB:convertToClientPos(data.pass_player)
	self._playerList[clientPos]:handleBeforeAction()
	local v = Number.random(1,2)
	Audio.playSoundConfig(SOUND_TAG, string.format("pass_%d",v))
	self._widgets.pan_operator:setVisible(false)
	self:performWithDelay(function()
		self._playerList[clientPos]:handlePass()
	end,0.1)
end

-- 取消托管
function M:handleCancelTrustee(event)
	self._widgets.pan_mask:setVisible(false)
	if self._playerList[1]:isMyTurn() then
		self._playerList[1]:showCountdown()
		local gameState = Game.ddzDB:getGameState()
		if gameState == 0 then
			self._widgets.pan_operator:setVisible(true)
			local allSelect = Game.ddzRule:getAllSelect()
			if Assist.isEmpty(allSelect) and not Assist.isEmpty(self._lastOtherGoPoke) then
				self._widgets.pan_tips:setVisible(true)
				self._widgets.pan_tips:setTouchEnabled(true)
				self._widgets.img_1:setVisible(false)
				self._widgets.img_2:setVisible(true)
				if #self._handPoke == 1 then
					self._widgets.pan_operator:setVisible(false)
					self._playerList[1]:handleBeforeAction()
					self:onPass()
				end
			else
				-- local pokeData = {}
				-- for _, poke in ipairs(self._handPoke) do
				-- 	table.insert(pokeData, poke:getClientCardValue())
				-- end
				-- self._curTipIdx = 1
				-- local tip = allSelect[1]
				-- local otherPokeInfo = Game.ddzRule:createPokeInfo(self._lastOtherGoPoke)
				-- if Game.ddzRule:checkBombFirst(pokeData, otherPokeInfo) then
				-- 	for _, idx in ipairs(tip) do
				-- 		self._handPoke[idx]:setSelected(true)
				-- 	end
				-- else
				-- 	local checkPx = {}
				-- 	for _, idx in ipairs(tip) do
				-- 		table.insert(checkPx, self._handPoke[idx]:getClientCardValue())
				-- 	end
				-- 	local pokeType = Game.ddzRule:getPokeType(checkPx)
				-- 	if pokeType ~= PaiXing.WANG_ZHA and pokeType ~= PaiXing.ZHA_DAN then
				-- 		for _, idx in ipairs(tip) do
				-- 			self._handPoke[idx]:setSelected(true)
				-- 		end
				-- 	end
				-- end
				if #self._handPoke == 1 then
					self:unselectPokes()
					self._widgets.pan_operator:setVisible(false)
					self._playerList[1]:handleBeforeAction()
					self:onGoPoke(true)
				end
			end
			self:showBtnGoEnabled()
		elseif gameState == 2 then
			self._widgets.pan_jiaofen:setVisible(true)
		end
	end
end

-- 托管
function M:handleTrustee(event)
	if Game.ddzDB:isTuoguan() then
		self:unselectPokes()
		self._widgets.pan_mask:setVisible(true)
	else
		local data = event.data
		local clientPos = Game.ddzDB:convertToClientPos(data.trustee_player)
		-- 显示托管
	end
end

function M:changeYellowBtnEnabled(btn, enabled)
	local txt = btn:getChildByName("txt")
	btn:setEnabled(enabled)
	if enabled then
		txt:enableOutline(Assist.colorFromString("#cb6114"),2)
	else
		txt:enableOutline(Assist.colorFromString("#676074"),2)
	end
end

function M:changeBlueBtnEnabled(btn, enabled)
	local txt = btn:getChildByName("txt")
	btn:setEnabled(enabled)
	if enabled then
		txt:enableOutline(Assist.colorFromString("#1a72bd"),2)
	else
		txt:enableOutline(Assist.colorFromString("#676074"),2)
	end
end

-- 判断有牌提起使出牌可点击
function M:showBtnGoEnabled()
	if self._widgets.pan_operator:isVisible() then
		local haveSelect = false
		for _, v in ipairs(self._handPoke) do
			if v:isSelected() then
				haveSelect = true
				break
			end
		end
		if haveSelect then
			self:changeYellowBtnEnabled(self._widgets.btn_go, true)
		else
			self:changeYellowBtnEnabled(self._widgets.btn_go, false)
		end
	end
end

-- 轮次
function M:handleTurn(event)
	local data = event.data
	local cltPos = Game.ddzDB:convertToClientPos(data.pos)
	local playerInfo = Game.ddzDB:getPlayersInfo()
	local curPlayer = playerInfo[cltPos]
	local delayTime = 0.3
	if not curPlayer.robot then
		local state = Game.ddzDB:getGameState()
		if self._jfFirst and state==2 then
			delayTime = 3
		end
		if self._cpFirst and state==0 then
			delayTime = 3
		end
	end
	self:performWithDelay(function()
		-- 如果上两家均过牌，则隐藏他们的不出提示
		local data = event.data
		if data.time<=0 then return end
		local clientPos = Game.ddzDB:convertToClientPos(data.pos)
		local allPass = true
		for cltpos, player in ipairs(self._playerList) do
			if cltpos~=clientPos then
				if not player:isPassCard() then
					allPass = false
					break
				end
			end
		end
		if allPass then
			for cltpos, player in ipairs(self._playerList) do
				if cltpos~=clientPos then
					player:hideJiaoFen()
				end
			end
		end

		for _, player in ipairs(self._playerList) do
			player:handleTurn(data, delayTime)
		end

		-- 检测是否是自己的轮次
		local clientPos = Game.ddzDB:convertToClientPos(data.pos)
		local isTuoguan = Game.ddzDB:isTuoguan()
		if clientPos == 1 then
			self._curTipIdx = 0
			local gameState = Game.ddzDB:getGameState()
			if gameState == 0 then -- 出牌中
				if isTuoguan then
					self._widgets.pan_operator:setVisible(false)
				else
					self._widgets.pan_operator:setVisible(true)
				end
				-- 判断是否有其他人出牌
				if Assist.isEmpty(self._lastOtherGoPoke) then
					self:changeYellowBtnEnabled(self._widgets.btn_tips, false)
					self:changeBlueBtnEnabled(self._widgets.btn_pass, false)
					self._widgets.btn_tips:setVisible(true)
					self._widgets.btn_pass:setVisible(true)
					self._widgets.btn_go:setVisible(true)
					self._widgets.btn_yaobuqi:setVisible(false)
					self._widgets.pan_tips:setVisible(false)
					-- 最后一张牌特殊处理
					if #self._handPoke == 1 and (not isTuoguan) then
						self._playerList[1]:handleBeforeAction()
						self._widgets.pan_operator:setVisible(false)
						self:onGoPoke(true)
					end
				else
					self:changeYellowBtnEnabled(self._widgets.btn_tips, true)
					self:changeBlueBtnEnabled(self._widgets.btn_pass, true)

					-- 判断智能选牌 
					local pokeData = {}
					for _, poke in ipairs(self._handPoke) do
						table.insert(pokeData, poke:getClientCardValue())
					end
					Game.ddzRule:autoSelectPoke(pokeData, self._lastOtherGoPoke)
					-- self:unselectPokes()
					local allSelect = Game.ddzRule:getAllSelect()
					if Assist.isEmpty(allSelect) then
						self:unselectPokes()
						self:changeYellowBtnEnabled(self._widgets.btn_tips, false)
						self._widgets.btn_tips:setVisible(false)
						self._widgets.btn_pass:setVisible(false)
						self._widgets.btn_go:setVisible(false)
						self._widgets.btn_yaobuqi:setVisible(true)
						if not isTuoguan then
							self._widgets.pan_tips:setVisible(true)
							self._widgets.pan_tips:setTouchEnabled(true)
							self._widgets.img_1:setVisible(false)
							self._widgets.img_2:setVisible(true)
							
							if #self._handPoke == 1 then
								self._widgets.pan_operator:setVisible(false)
								self._playerList[1]:handleBeforeAction()
								self:onPass()
							end
						end
					else
						self._widgets.btn_tips:setVisible(true)
						self._widgets.btn_pass:setVisible(true)
						self._widgets.btn_go:setVisible(true)
						self._widgets.btn_yaobuqi:setVisible(false)
						self._widgets.pan_tips:setVisible(false)
						if not isTuoguan then
							-- self._curTipIdx = 1
							-- local tip = allSelect[1]
							-- local otherPokeInfo = Game.ddzRule:createPokeInfo(self._lastOtherGoPoke)
							-- if Game.ddzRule:checkBombFirst(pokeData, otherPokeInfo) then
							-- 	for _, idx in ipairs(tip) do
							-- 		self._handPoke[idx]:setSelected(true)
							-- 	end
							-- else
							-- 	local checkPx = {}
							-- 	for _, idx in ipairs(tip) do
							-- 		table.insert(checkPx, self._handPoke[idx]:getClientCardValue())
							-- 	end
							-- 	local pokeType = Game.ddzRule:getPokeType(checkPx)
							-- 	if pokeType ~= PaiXing.WANG_ZHA and pokeType ~= PaiXing.ZHA_DAN then
							-- 		for _, idx in ipairs(tip) do
							-- 			self._handPoke[idx]:setSelected(true)
							-- 		end
							-- 	end
							-- end
							if #self._handPoke == 1 then
								self:unselectPokes()
								self._widgets.pan_operator:setVisible(false)
								self._playerList[1]:handleBeforeAction()
								self:onGoPoke(true)
							end
						end
					end
				end
				self:showBtnGoEnabled()
			elseif gameState == 2 then -- 叫分
				if Game.ddzDB:isTuoguan() then
					self._widgets.pan_jiaofen:setVisible(false)
				else
					self._widgets.pan_jiaofen:setVisible(true)
				end
				local curCallScore = Game.ddzDB:getCurCallScore()
				print("-------------------------------------")
				print("curCallScore:", curCallScore)
				print("-------------------------------------")
				self:changeYellowBtnEnabled(self._widgets.btn_yifen, curCallScore<1)
				self:changeYellowBtnEnabled(self._widgets.btn_liangfen, curCallScore<2)
				self:changeYellowBtnEnabled(self._widgets.btn_sanfen, curCallScore<3)
			end
		else
			self._widgets.pan_operator:setVisible(false)
			self._widgets.pan_jiaofen:setVisible(false)
			self._widgets.pan_tips:setVisible(false)
		end
	end, delayTime)
end

-- 玩家倒计时结束
function M:onCountdownFinish(event)
	local clientPos = event.data
	if clientPos == 1 then
		local gameState = Game.ddzDB:getGameState()
		if gameState == 0 then
			self._widgets.pan_operator:setVisible(false)
		elseif gameState == 2 then
			self._widgets.pan_jiaofen:setVisible(false)
		end
	end
end

-- 结算
function M:handleSettlement(event)
	self._widgets.pan_mask:setVisible(false)
	self._widgets.pan_tips:setVisible(false)
	self._widgets.pan_operator:setVisible(false)
	local data = Game.ddzDB:getSettlement()
	local dealyTime = 0.5
	if data.spring > 0 then
		dealyTime = 1.0
		local actor = Actor:new(SpineList[6].res, SpineList[6])
		self._widgets.node_spine:addChild(actor)
		actor._actor:registerSpineEventHandler(function(event)
			self:performWithDelay(function()
				actor:removeFromParent()
			end,0.1)
		end,sp.EventType.ANIMATION_COMPLETE)
		Audio.playSoundConfig(SOUND_TAG, "spring")
		Audio.playSoundConfig(SOUND_TAG, "effect_spring")
	end
	self:performWithDelay(function()
		self._widgets.pan_result:setVisible(true)
		self:clearHandPoke()
		local result = data.result
		local bankerPos = 0
		local bankerWin = false
		for pos, player in ipairs(self._playerList) do
			if player:isBanker() then
				bankerPos = Game.ddzDB:convertToSvrPos(pos)
				break
			end
		end
		for _, info in ipairs(result) do
			if info.pos == bankerPos then
				bankerWin = info.gold>=0
				break
			end
		end
		for _, player in ipairs(self._playerList) do
			player:handleSettlement(data.result, bankerWin)
		end
	end, dealyTime)
end

-- 调试信息
function M:handleDebugInfo()
	local msg = Game.ddzDB:getDebugInfo()
	if not Assist.isEmpty(msg) then
		local card_info = msg.card_info
		for _, v in ipairs(card_info) do
			local cltPos = Game.ddzDB:convertToClientPos(v.pos)
			if cltPos>1 then
				self:showDebugPoke(cltPos, v.card_list)
			end
		end
	end
end

function M:showDebugPoke(pos, pokesData)
	if pos == 2 then
		table.sort(pokesData)
		for _, v in ipairs(self._debugPoke2) do
			v:removeFromParent()
		end
		self._debugPoke2 = {}
	elseif pos == 3 then
		table.sort(pokesData, function(a,b)return a>b end)
		for _, v in ipairs(self._debugPoke3) do
			v:removeFromParent()
		end
		self._debugPoke3 = {}
	end
	if not self._playerList[pos]._robot then return end
	local posTb = {[3] = {x=50, y=450}, [2]={x=display.width-50, y=450}}
	local count = 1
	for k, v in ipairs(pokesData) do
		local item = self._widgets.card_1:clone()
		self:handleSmallCard(item, v)
		self._rootNode:addChild(item)
		
		if pos == 2 then
			item:setLocalZOrder(1000-k)
			item:setPosition(posTb[pos].x-(k-1)*30, posTb[pos].y)
			table.insert(self._debugPoke2, item)
		elseif pos == 3 then
			item:setPosition(posTb[pos].x+(k-1)*30, posTb[pos].y)
			table.insert(self._debugPoke3, item)
		end
	end
end

function M:handleExitGame()
	self:reset()
	self:destroy()
	Game:enterScene(ENUM.SCENCE.PLATFORM)
end

-- 重建房间
function M:onRebuildRoom(event)
	if not Assist.isEmpty(event) then -- 96016返回才有值
		local state = event.data
		if state == 1 then return end  -- 匹配中
		if state == 3 then self:onBack() end  -- 结算
		if state == -1 then self:handleExitGame() end -- 踢出
	end
	self._jfFirst = false
	self._cpFirst = false
	self:hideMatchPlayer()
	self._widgets.pan_hand_poke:setTouchEnabled(true)
	self._widgets.pan_mask:setVisible(false)
	local gameState = Game.ddzDB:getGameState()
	if gameState == 0 then -- 游戏中
		self:resetPlayerList()
		
		-- 确定庄家
		local bankerInfo = Game.ddzDB:getBankerInfo()
		local bankerClientPos = Game.ddzDB:convertToClientPos(bankerInfo.banker_player)
		self._ddzBg:ensureLandlord(bankerClientPos, true)
		for _, player in ipairs(self._playerList) do
			player:setBanker(bankerClientPos)
		end

		-- 更新底牌和倍数 放在确定庄家后
		self:updateTopInfo()
		-- 更新打勾
		local banker_out = Game.ddzDB:getBankerOut()
		self:updateBankerCardOccur(banker_out)

		-- 重建手牌
		self:rebuildHandPoke()
		-- 更新出牌  更新牌数显示
		local playersInfo = Game.ddzDB:getPlayersInfo()
		local lastGoPoke = {}
		local tmp = {}
		local curSeat = Game.ddzDB:getCurSeat()
		for k, v in ipairs(playersInfo) do
			self._playerList[k]:setBaseInfo(v.player_base_info)
			if Assist.isEmpty(v.cur_card_list) then -- 不出或者没出牌
				if k==curSeat then
					self._playerList[k]:handlePass()
				end
			else
				local data = {}
				data.card_data = v.cur_card_list
				data.count = v.cur_count
				data.out_card_player = v.player_base_info.pos
				self._playerList[k]:handleGoPoke(data,true)
				for _, v in ipairs(v.cur_card_list) do
					table.insert(tmp, Number.floor(v/100))
				end
				lastGoPoke[k] = tmp
				tmp = {}
			end
			self._playerList[k]:setPokeNum(v.poke_num)
		end
		local lastSeat = curSeat-1
		if lastSeat==0 then lastSeat=3 end
		local nextSeat = curSeat+1
		if nextSeat==4 then nextSeat=1 end
		if lastGoPoke[nextSeat] and lastGoPoke[lastSeat]==nil then
			self._playerList[lastSeat]:handlePass()
		end
		self._lastOtherGoPoke = lastGoPoke[3] or lastGoPoke[2]
	elseif gameState == 2 then -- 叫分
		self:resetPlayerList()
		self:showBankerCard()
		-- 更新叫分 牌数显示
		local playersInfo = Game.ddzDB:getPlayersInfo()
		for k, v in ipairs(playersInfo) do
			self._playerList[k]:setBaseInfo(v.player_base_info)
			local data = {}
			if v.call_score>=0 then
				data.score = v.call_score
				data.call_player = v.player_base_info.pos
				self._playerList[k]:handleCallScore(data)
			end
			self._playerList[k]:setPokeNum(v.poke_num)
		end
		-- 重建手牌
		self:rebuildHandPoke()
	end
end

function M:rebuildHandPoke()
	self:clearHandPoke()
	local originPokesData = Game.ddzDB:getOriginPokesData()
	table.sort(originPokesData)
	for _, v in ipairs(originPokesData) do
		local poke = Game.ddzDB:getCardFromPool(v, self._widgets.pan_hand_poke)
		table.insert(self._handPoke, poke)
	end
	self:adjustHandPokePos()
end

function M:showBankerCard()
	self:clearBankerCardList()
	local function _getPoke(parent)
		local poke = Game.ddzDB:getCardFromPool(310,parent)
		poke:setAnchorPoint(cc.p(0.5, 0.5))
		poke:setScale(0.8)
		poke:showMask()
		return poke
	end
	local pos1X = self._widgets.pos_1:getPositionX()
	local pos2X = self._widgets.pos_2:getPositionX()
	local poke1 = _getPoke(self._widgets.pos_1)
	poke1:setPosition(cc.p(0, 0))
	table.insert(self._bankerCardList, poke1)

	local poke2 = _getPoke(self._widgets.pos_2)
	poke2:setPosition(cc.p(0, 0))
	table.insert(self._bankerCardList, poke2)

	local poke3 = _getPoke(self._widgets.pos_3)
	poke3:setPosition(cc.p(0, 0))
	table.insert(self._bankerCardList, poke3)
end

function M:onComeToForeGround()
	if self._background then
		self:stopAllActions()
		self:clearBankerCardList()
		self._background = false
		Game.ddzDB:setBackground(false)
		self._widgets.pan_jiaofen:setVisible(false)
		self._widgets.pan_operator:setVisible(false)
		self._widgets.pan_tips:setVisible(false)
		Game.ddzCom:reqSyncData()
	end
end

function M:onComeToBackGround()
	if not self._background then
        self._background = true
        Game:destroyWaitUI()
        Game.ddzDB:setBackground(true)
    end
end
-------------------------------------------------------------------
-- 按钮响应

-- 叫分：不叫
function M:onBuJiao(sender)
	setTouchCD(sender,0.5)
	Game.ddzCom:reqCall(0)
end

function M:onJiaoFen(sender)
	setTouchCD(sender,0.5)
	local score = sender:getTag()
	Game.ddzCom:reqCall(score)
end

-- 不出
function M:onPass(sender)
	setTouchCD(sender,0.5)
	self:unselectPokes()
	self._widgets.pan_tips:setVisible(false)
	self._widgets.pan_operator:setVisible(false)
	local mySvrPos = Game.ddzDB:convertToSvrPos(1)
	Game.ddzCom:reqPass(mySvrPos)
end

-- 提示
function M:onTipsGoPoke()
	local selectTips = Game.ddzRule:getAllSelect()
	if not Assist.isEmpty(selectTips) then
		self:unselectPokes()
		self._curTipIdx = self._curTipIdx + 1
		if self._curTipIdx > #selectTips then
			self._curTipIdx = self._curTipIdx - #selectTips
		end

		local selectWay = selectTips[self._curTipIdx]
		for _, idx in ipairs(selectWay or {}) do
			self._handPoke[idx]:setSelected(true)
		end
		self:changeYellowBtnEnabled(self._widgets.btn_go, true)
	end
end

-- 出牌
function M:onGoPoke(sender)
	local pokeData = {}
	local ret = {}
	if type(sender) == "boolean" then
		table.insert(pokeData, self._handPoke[1]:getSvrCardValue())
		table.insert(ret, self._handPoke[1]:getClientCardValue())
	else
		setTouchCD(sender, 0.5)
		for _, v in ipairs(self._handPoke) do
			if v:isSelected() then
				table.insert(pokeData, v:getSvrCardValue())
				table.insert(ret, v:getClientCardValue())
			end
		end
	end
	local function _blinkNode(tipNode)
		local seq = {
			cc.FadeTo:create(0.5, 188),
			cc.FadeTo:create(0.5, 255)
		}
		local blink = cc.Repeat:create(transition.sequence(seq),2)
		local seq2 = {
			blink,
			cc.CallFunc:create(function(node)
				self._widgets.pan_tips:setVisible(false)
				node:setOpacity(255)
			end)
		}
		tipNode:runAction(transition.sequence(seq2))
	end
	local mySvrPos = Game.ddzDB:convertToSvrPos(1)
	if Assist.isEmpty(self._lastOtherGoPoke) then
		local myPokeInfo = Game.ddzRule:createPokeInfo(ret)
		if myPokeInfo.poke_t == PaiXing.TYPE_NONE then
			self._widgets.pan_tips:setVisible(true)
			self._widgets.pan_tips:setTouchEnabled(false)
			self._widgets.img_1:setVisible(true)
			self._widgets.img_2:setVisible(false)
			_blinkNode(self._widgets.img_1)
			return
		end
	else
		local otherPokeInfo = Game.ddzRule:createPokeInfo(self._lastOtherGoPoke)
		local myPokeInfo = Game.ddzRule:createPokeInfo(ret)
		if myPokeInfo.poke_t == PaiXing.TYPE_NONE 
			or (myPokeInfo.poke_t==otherPokeInfo.poke_t and (myPokeInfo.poke_v<=otherPokeInfo.poke_v or myPokeInfo.poke_n~=otherPokeInfo.poke_n))
			or (myPokeInfo.poke_t~=otherPokeInfo.poke_t and myPokeInfo.poke_t~=PaiXing.WANG_ZHA and myPokeInfo.poke_t~=PaiXing.ZHA_DAN) then
			self._widgets.pan_tips:setVisible(true)
			self._widgets.pan_tips:setTouchEnabled(false)
			self._widgets.img_1:setVisible(true)
			self._widgets.img_2:setVisible(false)
			_blinkNode(self._widgets.img_1)
			return
		end
	end
	self._widgets.pan_tips:setVisible(false)
	Game.ddzCom:reqOutCards(#pokeData, pokeData, mySvrPos)
end

-- 取消托管
function M:onCancelTrustee()
	Audio.playSoundConfig(SOUND_TAG, "cancel")
	Game.ddzCom:reqCancelTrustee()
end

-- 返回游戏
function M:onBack()
	local coin = Game:doPluginAPI("get", "playerCoin")
	local limitCoin = SubgameConfig.coin(1074)
	if coin<limitCoin[1] then
		self:onClose()
	else
		Game.ddzCom:openReadyUI()
		self:reset()
		self:destroy()
	end
end

-- 再玩一局
function M:onPlayGameAgain()
	local baseScore = Game.ddzDB:getBaseScore()
	-- 检测金币是否足够
	local coin = Game:doPluginAPI("get", "playerCoin")
	local baseScoreTb
	local bet_list = BetLimitConfig.chip_list(1074)
	for _, v in ipairs(bet_list or {}) do
		local min = v[1] or 0
		local max = v[2] or -1
		if coin>=min and (coin<=max or max==-1) then
			baseScoreTb = v[3]
			break
		end
	end
	if Assist.isEmpty(baseScoreTb) then
		local param = {
			sTip = Config.localize("ddz_lack_of_coin"),
			sBtnName1 = "补充",
			sBtnName2 = "我再想想",
			fCallBack1 = function()
				Game:doPluginAPI("enter", "shop", nil, nil, function()
					excFuncSafe(self, "onBack")
				end)
			end,
			fCallBack2 = function()
				excFuncSafe(self, "onClose")
			end,
			justClose = true
		}
		showConfirmTip(param)
	else
		-- 升场
		if baseScoreTb[1]>baseScore then
			local param = {
				sTip = Config.localize("ddz_upgrade"),
				sBtnName1 = "马上去",
				sBtnName2 = "不去了",
				fCallBack1 = function()
					excFuncSafe(self, "playGame", baseScoreTb[1])
				end,
				fCallBack2 = function()
					excFuncSafe(self, "onBack")
				end,
				justClose = true
			}
			showConfirmTip(param)
		-- 降场
		elseif baseScoreTb[#baseScoreTb]<baseScore then
			local param = {
				sTip = Config.localize("ddz_lack_of_coin"),
				sBtnName1 = "补充",
				sBtnName2 = "默默降级",
				fCallBack1 = function()
					Game:doPluginAPI("enter", "shop", nil, nil, function()
						excFuncSafe(self, "onBack")
					end)
				end,
				fCallBack2 = function()
					excFuncSafe(self, "playGame", baseScoreTb[#baseScoreTb])
				end,
				justClose = true
			}
			showConfirmTip(param)
		else
			self:playGame(baseScore)
		end
	end
end

function M:playGame(baseScore)
	Game.ddzDB:setBaseScore(baseScore)
	self:reset()
	self:showMatchPlayer()
	self:initBeiShu()
	Game.ddzCom:reqStartGame(baseScore)
end

------------------------------------------------------
function M:clearTopInfo()
	self._widgets.img_title:setVisible(true)
	self._widgets.img_desc:setVisible(true)
	self._widgets.pan_di:setVisible(false)
	self._widgets.txt_rate:setVisible(false)
	self:initBeiShu()
end

-- 庄家牌全部销毁
function M:clearBankerCardList()
	for _, poke in ipairs(self._bankerCardList) do
		poke:removeFromParent()
	end
	self._bankerCardList = {}
end

function M:clearHandPoke()
	for _, poke in ipairs(self._handPoke) do
		Game.ddzDB:pushCardPool(poke)
	end
	self._handPoke = {}
end

function M:resetPlayerList()
	for _, player in ipairs(self._playerList) do
		player:reset()
	end
end

function M:reset()
	self._lastOtherGoPoke = {}
	self._firstRound = true
	self._jfFirst = true
	self._cpFirst = true
	self._widgets.pan_jiaofen:setVisible(false)
	self._widgets.pan_operator:setVisible(false)
	self._widgets.pan_result:setVisible(false)

	self._ddzBg:showAllFarmer()
	self:resetPlayerList()
	self:clearHandPoke()
	self:clearTopInfo()
	self:clearBankerCardList()
	Game.ddzDB:reset()
end

function M:onClose()
	self._ddzBg:onExitGame()
end

return M