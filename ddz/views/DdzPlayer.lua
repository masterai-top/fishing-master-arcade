local M = class("DdzPlayer")
local Actor = require_ex("ui.base.Actor")
local DdzUtils = require_ex("games.ddz.models.DdzUtils").new()
local IMG_TIPS = {
	[0] = "subgame/ddz/front/game_ddz_af_8.png", -- 不叫
	[1] = "subgame/ddz/front/game_ddz_af_9.png", -- 1分
	[2] = "subgame/ddz/front/game_ddz_af_10.png", -- 2分
	[3] = "subgame/ddz/front/game_ddz_af_11.png", -- 3分
}
local IMG_PASS = "subgame/ddz/front/game_ddz_af_7.png" -- 不出
local SpinePolice = {res="subgame/ddz/spine/baojingqi/ddz_bjq", ani="1"}
local SpineNz = {res="subgame/ddz/spine/naozhong/ddz_nz", ani="1"}
local SpineLd = {res="subgame/ddz/spine/liandui/ddz_ld2", ani="1", isLoop=false}
local SpineFj = {res="subgame/ddz/spine/feiji/ddz_fj2", ani="1", isLoop=false}
local SpineSz = {res="subgame/ddz/spine/shunzi/ddz_sz2", ani="1", isLoop=false}
local POKE_SCALE = {0.8, 0.66, 0.66}
local NAOZHONG_SCALE = {1.0, 0.74, 0.74}

function M:ctor(controlUI, clientPos)
	self._ctrl = controlUI
	self._clientPos = clientPos
	
	self:init()
end

function M:init()
	self._BindWidget = {
		["pan_jf"] = {hide = true},
		["pan_jf/img_fen"] = {key = "img_fen"}, -- 也用于不出牌显示

		["pan_nz/txt"] = {key = "txt_countdown"},
		["pan_nz/nz_spine"] = {key = "nz_spine"},

		["pan_poke"] = {},

		["pan_show_poke"] = {},

		["pan_num"] = {},

		["pan_score"] = {hide = true},
		["pan_score/pan_win"] = {key = "pan_win"},
		["pan_score/pan_win/txt_win"] = {key = "txt_win"},
		["pan_score/pan_lose"] = {key = "pan_lose"},
		["pan_score/pan_lose/txt_lose"] = {key = "txt_lose"},

		["pan_name"] = {hide = true},

		["pan_coin"] = {hide = true},

		["node_police"] = {},
	}

	self:initData()
	self:initViews()
end

function M:initData()
	self._widgets = {}
	self._curGoPoke = {}		-- 当前已打出的牌
	self._resultPoke = {}		-- 游戏结束时的手牌
	self._tickCount = 0			-- 倒计时值
	self._tick = 0				-- 定时器计时秒
	self._canCountDown = false  -- 是否开始倒计时
	self._pokeNum = 0			-- 牌数
	self._isBanker = false		-- 是否庄家
	self._myTurn = false		-- 是否自身轮次
	self._passCard = false		-- 是否过牌
	self._nzAni = nil 			-- 闹钟特效
	self._nick = ""				-- 昵称
	self._coin = 0				-- 拥有金币
	self._svrPos = 0
	self._uid = -1
end

function M:initViews()
	bindWidgetList(self._ctrl, self._BindWidget, self._widgets)
	self._nzAni = Actor:new(SpineNz.res, SpineNz)
	self._widgets.nz_spine:addChild(self._nzAni)
	self._nzAni:setVisible(false)
	self._nzAni:setScale(NAOZHONG_SCALE[self._clientPos]) 			
end

function M:setBaseInfo(playerInfo)
	self._uid = playerInfo.uid
	self._svrPos = playerInfo.pos
	self._coin = playerInfo.coin
	self._nick = playerInfo.name
	self._robot = playerInfo.robot
	self:showName()
	self:showCoin()
end

function M:showName()
	if self._widgets.pan_name and (not self._robot) then
		self._widgets.pan_name:setVisible(true)
		local txt_name = self._widgets.pan_name:getChildByName("txt_name")
		txt_name:setString(self._nick)
	end 
end

function M:hideName()
	if self._widgets.pan_name then
		self._widgets.pan_name:setVisible(false)
		local txt_name = self._widgets.pan_name:getChildByName("txt_name")
		txt_name:setString("")
	end
end

function M:showCoin()
	if self._widgets.pan_coin and (not self._robot) then
		self._widgets.pan_coin:setVisible(true)
		local txt_coin = self._widgets.pan_coin:getChildByName("txt_coin")
		txt_coin:setString(Number.measure(self._coin))
	end
end

function M:hideCoin()
	if self._widgets.pan_coin then
		self._widgets.pan_coin:setVisible(false)
		local txt_coin = self._widgets.pan_coin:getChildByName("txt_coin")
		txt_coin:setString("")
	end
end

-- 叫分
function M:handleCallScore(data)
	fitIconSize(self._widgets.img_fen, IMG_TIPS[data.score])
	self._widgets.pan_jf:setVisible(true)
end

-- 操作前需处理的逻辑
function M:handleBeforeAction()
	self._canCountDown = false
	self._passCard = false
	self._widgets.pan_jf:setVisible(false)
	self._widgets.txt_countdown:setVisible(false)
	self._nzAni:setVisible(false)
end

-- 出牌
function M:handleGoPoke(data, reconnect)
	table.sort(data.card_data, function(a,b)return a>b end)
	-- 出牌
	local scale = POKE_SCALE[self._clientPos]
	self:clearGoPoke()
	for k, v in ipairs(data.card_data) do
		local card = Game.ddzDB:getCardFromPool(v, self._widgets.pan_poke)
		card:setScale(scale)
		table.insert(self._curGoPoke, card)
	end

	self:adjustGoPoke(data.card_data)
	local x, y = self:showGoPokesPos()
	if not reconnect then
		self:updatePokeNum(#data.card_data)
		self:showPokesEffect(x, y)
	end
end

function M:adjustGoPoke(card_data)
	-- 牌型摆放
	local pokeData = {}
	for _, v in ipairs(self._curGoPoke) do
		table.insert(pokeData, v:getClientCardValue())
	end
	local pokeType = Game.ddzRule:getPokeType(pokeData)
	local mapNumTb = DdzUtils:getValueCountMap(pokeData)
	local mapIdxTb = DdzUtils:getValueIdxMap(pokeData)
	local len = #card_data
	local main, rest, ret = {}, {}
	local i = 1
	if pokeType == PaiXing.SAN_ZHANG
		or pokeType == PaiXing.SAN_DAI_YI
		or pokeType == PaiXing.SAN_DAI_ER 
		or pokeType == PaiXing.FEI_JI 
		or pokeType == PaiXing.FEI_JI_WITH_ONE 
		or pokeType == PaiXing.FEI_JI_WITH_TWO then
		while i<=len do
			local num = mapNumTb[pokeData[i]]
			if num == 4 then
				table.insert(main, mapIdxTb[pokeData[i]])
				table.insert(main, mapIdxTb[pokeData[i]]+1)
				table.insert(main, mapIdxTb[pokeData[i]]+2)
				table.insert(rest, mapIdxTb[pokeData[i]]+3)
			elseif num == 3 then
				table.insert(main, mapIdxTb[pokeData[i]])
				table.insert(main, mapIdxTb[pokeData[i]]+1)
				table.insert(main, mapIdxTb[pokeData[i]]+2)
			elseif num == 2 then
				table.insert(rest, mapIdxTb[pokeData[i]])
				table.insert(rest, mapIdxTb[pokeData[i]]+1)
			elseif num == 1 then
				table.insert(rest, mapIdxTb[pokeData[i]])
			end
			i = i + num
		end
		ret = table.mergeList(main, rest)
		for k, idx in ipairs(ret) do
			self._curGoPoke[k]:changeValue(card_data[idx])
		end

	elseif pokeType == PaiXing.SI_DAI_ER 
		or pokeType == PaiXing.SI_DAI_ER_DUI then
		while i<=len do
			local num = mapNumTb[pokeData[i]]
			if num==4 then
				table.insert(main, mapIdxTb[pokeData[i]])
				table.insert(main, mapIdxTb[pokeData[i]]+1)
				table.insert(main, mapIdxTb[pokeData[i]]+2)
				table.insert(main, mapIdxTb[pokeData[i]]+3)
			elseif num == 2 then
				table.insert(rest, mapIdxTb[pokeData[i]])
				table.insert(rest, mapIdxTb[pokeData[i]]+1)
			elseif num == 1 then
				table.insert(rest, mapIdxTb[pokeData[i]])
			end
			i = i + num
		end
		ret = table.mergeList(main, rest)
		for k, idx in ipairs(ret) do
			self._curGoPoke[k]:changeValue(card_data[idx])
		end
	end
end

-- 展示出牌
function M:showGoPokesPos()
	local x, y = 0, 0
	local gapX, gapY = 30, -48
	local panPokeSize = self._widgets.pan_poke:getContentSize()
	local onePoke = self._curGoPoke[1]
	local pokeSize = onePoke:getBoundingBox()
	local centerX, centerY = 0, 0
	if self._clientPos == 1 then
		gapX = 40
		local allPokeLength = gapX*(#self._curGoPoke-1) + pokeSize.width
		x = (panPokeSize.width-allPokeLength)/2
		for k, poke in ipairs(self._curGoPoke) do
			poke:setPosition(x, 0)
			poke:setLocalZOrder(k)
			x = x + gapX
		end
		centerX = allPokeLength/2
		centerY = pokeSize.height/2
	elseif self._clientPos == 2 then
		x = panPokeSize.width - pokeSize.width
		local len = #self._curGoPoke
		local idx, count = 1, 0
		while idx<=len do
			local min = Number.min(idx+7, len)
			for i=min, idx, -1 do
				local poke = self._curGoPoke[i]
				poke:setPosition(x, y)
				x = x - gapX
				poke:setLocalZOrder(i+count*100)
			end
			idx = idx + 8
			count = count + 1
			y = y + gapY
			x = panPokeSize.width - pokeSize.width
		end
		if len>=8 then
			centerX = panPokeSize.width - (pokeSize.width+7*gapX)/2
			local layerNum = Number.ceil(len/8)
			centerY = (pokeSize.height+(layerNum-1)*gapY)/2
		else
			centerX = panPokeSize.width - (pokeSize.width+(len-1)*gapX)/2
			centerY = pokeSize.height/2
		end
	elseif self._clientPos == 3 then
		for idx, poke in ipairs(self._curGoPoke) do
			poke:setPosition(x,y)
			poke:setLocalZOrder(idx)
			x = x + gapX
			if idx%8 == 0 then
				y = y + gapY
				x = 0
			end
		end
		local len = #self._curGoPoke
		if len>=8 then
			centerX = (pokeSize.width+7*gapX)/2
			local layerNum = Number.ceil(len/8)
			centerY = (pokeSize.height+(layerNum-1)*gapY)/2
		else
			centerX = (pokeSize.width+(len-1)*gapX)/2
			centerY = pokeSize.height/2
		end
	end
	return centerX, centerY
end

function M:showPokesEffect(x, y)
	if self._clientPos ~= 1 then
		local pokesData = {}
		for _, poke in ipairs(self._curGoPoke) do
			table.insert(pokesData, poke:getClientCardValue())
		end
		local pokeInfo, actor = Game.ddzRule:createPokeInfo(pokesData)
		if pokeInfo.poke_t == PaiXing.SHUN_ZI then
			actor = Actor:new(SpineSz.res, SpineSz)
			Audio.playSoundConfig(SOUND_TAG, "effect_shun_zi")
		elseif pokeInfo.poke_t == PaiXing.FEI_JI or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_ONE 
			or pokeInfo.poke_t == PaiXing.FEI_JI_WITH_TWO then
			actor = Actor:new(SpineFj.res, SpineFj)
			Audio.playSoundConfig(SOUND_TAG, "effect_airplane")
		elseif pokeInfo.poke_t == PaiXing.LIAN_DUI then
			actor = Actor:new(SpineLd.res, SpineLd)
			Audio.playSoundConfig(SOUND_TAG, "effect_lian_dui")
		end
		if actor then
			local displayNode = actor:getDisplayNode()
			self._widgets.pan_poke:addChild(actor, 1000)
			actor:setPosition(x,y)
			displayNode:registerSpineEventHandler(function(event)
				self._ctrl:performWithDelay(function()
					actor:removeFromParent()
				end, 0.1)
			end,sp.EventType.ANIMATION_COMPLETE)
		end
	end
end

-- 清除出的牌
function M:clearGoPoke()
	-- 清除牌堆
	for _, v in ipairs(self._curGoPoke) do
		Game.ddzDB:pushCardPool(v)
	end
	self._curGoPoke = {}
end

function M:clearResultPoke()
	for _, v in ipairs(self._resultPoke) do
		Game.ddzDB:pushCardPool(v)
	end
	self._resultPoke = {}
end

function M:showPoliceAni()
	-- 报警器特效
	if Assist.isEmpty(self._policeActor) then
		local actor = Actor:new(SpinePolice.res, SpinePolice)
		self._widgets.node_police:addChild(actor)
		self._policeActor = actor
	end
end

-- 清除报警器特效
function M:clearPoliceAni()
	if not Assist.isEmpty(self._policeActor) then
		self._policeActor:removeFromParent()
		self._policeActor = nil
	end
end

function M:showPokeNum()
	if self._widgets.pan_num then
		self._widgets.pan_num:setVisible(true)
		local txt_num = self._widgets.pan_num:getChildByName("txt_num")
		txt_num:setString(tostring(self._pokeNum))
	end
end

function M:updatePokeNum(goPokeNum)
	self._pokeNum = Number.max(0, self._pokeNum-goPokeNum)
	self:showPokeNum()
	if self._pokeNum>0 and self._pokeNum <= 2 then
		self:showPoliceAni()
		Audio.playSoundConfig("DDZUI", string.format("police_%d", self._pokeNum))
	end

	if self._pokeNum == 0 then --打完牌
		self._curGoPoke[#self._curGoPoke]:showWinFlag()
	end
end

function M:setPokeNum(pokeNum)
	self._pokeNum = pokeNum
	self:showPokeNum()
	if self._pokeNum>0 and self._pokeNum <= 2 then
		self:showPoliceAni()
	end
end

function M:resetPokeNum()
	self._pokeNum = 0
	self:showPokeNum()
end

function M:addDealPokeNum()
	self._pokeNum = Number.min(self._pokeNum+1, 17)
	self:showPokeNum()
end

-- 过牌
function M:handlePass()
	fitIconSize(self._widgets.img_fen, IMG_PASS)
	self._widgets.pan_jf:setVisible(true)
	self:clearGoPoke()
	self._passCard = true
	self._tickCount = 0
end

function M:isPassCard()
	return self._passCard
end

-- 轮次 用于倒计时
function M:handleTurn(data, delayTime)
	local clientPos = Game.ddzDB:convertToClientPos(data.pos)
	if clientPos == self._clientPos then
		self:clearGoPoke()
		self:hideJiaoFen()
		self._tickCount = data.time - checknumber(delayTime)
		self._tick = 0
		self._myTurn = true
		self._passCard = false
		self._canCountDown = true
		if clientPos == 1 and Game.ddzDB:isTuoguan() then
			self._nzAni:setVisible(false)
			self._widgets.txt_countdown:setVisible(false)
		else
			self._nzAni:setVisible(true)
			self._widgets.txt_countdown:setVisible(true)
			self._widgets.txt_countdown:setString(tostring(Number.ceil(self._tickCount)))
			self._nzAni:changeAnimation("1", true)
		end
	else
		self._canCountDown = false
		self._myTurn = false
		self._widgets.txt_countdown:setVisible(false)
		self._nzAni:setVisible(false)
	end
end

-- 结算
function M:handleSettlement(data, bankerWin)
	self:clearPoliceAni()
	self:handleBeforeAction()
	-- 分数飘
	local svrPos = Game.ddzDB:convertToSvrPos(self._clientPos)
	for _, v in ipairs(data) do
		if v.pos == svrPos then
			local txt
			if v.gold > 0 then
				self._widgets.pan_win:setVisible(true)
				self._widgets.pan_lose:setVisible(false)
				txt = self._widgets.txt_win
				txt:setString("+"..v.gold)
				if self._clientPos == 1 then
					Audio.playSoundConfig("DDZUI", "win")
				end
			elseif v.gold == 0 then
				if self:isBanker() then
					if bankerWin then
						self._widgets.pan_win:setVisible(true)
						self._widgets.pan_lose:setVisible(false)
						txt = self._widgets.txt_win
						txt:setString("+0")
						if self._clientPos == 1 then
							Audio.playSoundConfig("DDZUI", "win")
						end
					else
						self._widgets.pan_win:setVisible(false)
						self._widgets.pan_lose:setVisible(true)
						txt = self._widgets.txt_lose
						txt:setString("-0")
						if self._clientPos == 1 then
							Audio.playSoundConfig("DDZUI", "lose")
						end	
					end
				else
					if bankerWin then
						self._widgets.pan_win:setVisible(false)
						self._widgets.pan_lose:setVisible(true)
						txt = self._widgets.txt_lose
						txt:setString("-0")
						if self._clientPos == 1 then
							Audio.playSoundConfig("DDZUI", "lose")
						end	
					else
						self._widgets.pan_win:setVisible(true)
						self._widgets.pan_lose:setVisible(false)
						txt = self._widgets.txt_win
						txt:setString("+0")
						if self._clientPos == 1 then
							Audio.playSoundConfig("DDZUI", "win")
						end
					end
				end
			else
				self._widgets.pan_win:setVisible(false)
				self._widgets.pan_lose:setVisible(true)
				txt = self._widgets.txt_lose
				txt:setString(tostring(v.gold))
				if self._clientPos == 1 then
					Audio.playSoundConfig("DDZUI", "lose")
				end
			end
			local seq = {
				cc.DelayTime:create(0.5),
				cc.Show:create(),
				cc.ScaleTo:create(0.2, 1.5),
				cc.ScaleTo:create(0.2, 1.3),
				cc.MoveBy:create(1.0, cc.p(0, 50)),
				cc.DelayTime:create(4.0),
				cc.Spawn:create(cc.FadeOut:create(0.2), cc.ScaleTo:create(0.2, 0.15)),
				cc.Hide:create(),
				cc.CallFunc:create(function(node)
					node:setScale(1.0)
					node:setOpacity(255)
					node:moveVec2(cc.p(0, -50))
				end)
			}
			self._widgets.pan_score:runAction(transition.sequence(seq))
			self:showResultPoke(v.card_list)
			self._coin = self._coin + v.gold
			self:showCoin()
			break
		end
	end
end

function M:showResultPoke(pokeData)
	if Assist.isEmpty(pokeData) then return end
	self:clearGoPoke()
	table.sort(pokeData, function(a, b)return a>b end)
	for _, v in ipairs(pokeData) do
		local poke = Game.ddzDB:getCardFromPool(v, self._widgets.pan_show_poke)
		table.insert(self._resultPoke, poke)
		poke:setScale(POKE_SCALE[self._clientPos])
	end

	local x, y = 0, 0
	local gapX, gapY = 30, -48
	local onePoke = self._resultPoke[1]
	local pokeSize = onePoke:getBoundingBox()
	local panPokeSize = self._widgets.pan_show_poke:getContentSize()
	if self._clientPos == 1 then
		gapX = 40
		local allPokeLength = gapX*(#self._resultPoke-1) + pokeSize.width
		x = (panPokeSize.width-allPokeLength)/2
		for k, poke in ipairs(self._resultPoke) do
			poke:setPosition(x, 0)
			poke:setLocalZOrder(k)
			x = x + gapX
		end
	elseif self._clientPos == 2 then
		x = panPokeSize.width - pokeSize.width
		local len = #self._resultPoke
		local idx,count = 1, 0
		while idx<=len do
			local min = Number.min(idx+7, len)
			for i=min, idx, -1 do
				local poke = self._resultPoke[i]
				poke:setPosition(x, y)
				x = x - gapX
				poke:setLocalZOrder(i+count*100)
			end
			idx = idx + 8
			count = count + 1
			y = y + gapY
			x = panPokeSize.width - pokeSize.width
		end
	elseif self._clientPos == 3 then
		for idx, poke in ipairs(self._resultPoke) do
			poke:setPosition(x,y)
			poke:setLocalZOrder(idx)
			x = x + gapX
			if idx%8 == 0 then
				y = y + gapY
				x = 0
			end
		end
	end
end

-- 清除上局残留,重置数据
function M:reset()
	self:clearGoPoke()
	self:clearResultPoke()
	self:clearPoliceAni()
	self:hideName()
	self:hideCoin()

	self._canCountDown = false
	self._widgets.pan_jf:setVisible(false)
	self._widgets.txt_countdown:setVisible(false)
	self._nzAni:setVisible(false)
	self._widgets.pan_score:setVisible(false)

	-- 不是所有玩家都有的结构
	if self._widgets.pan_num then
		self._widgets.pan_num:setVisible(false)
	end

	self._ctrl:stopAllActions()

	self._pokeNum = 0

	self._tick = 0

	self._isBanker = false

	self._myTurn = false

	self._passCard = false

	self._nick = ""
	
	self._coin = 0

	self._svrPos = 0

	self._uid = -1 --0是机器人

	self._robot = false
end

function M:showCountdown()
	if self._tickCount>0 then
		self._widgets.txt_countdown:setVisible(true)
		self._nzAni:setVisible(true)
		local state = self._nzAni:getState()
		if state == "2" then
			self._nzAni:changeAnimation("1", true)
		end
	end
end

function M:updateFunc(dt)
	if self._canCountDown then
		if self._tickCount>=0 then
			self._tick = self._tick + dt
			if self._tick >= 1 then
				self._tickCount = self._tickCount - 1
				self._tick = 0
				if self._tickCount>0 then
					if self._clientPos==1 and Game.ddzDB:isTuoguan() then
						self._widgets.txt_countdown:setVisible(false)
						self._nzAni:setVisible(false)
					else
						self._widgets.txt_countdown:setVisible(true)
						self._nzAni:setVisible(true)
						local state = self._nzAni:getState()
						
						if self._tickCount<=3 then
							if state == "1" then
								self._nzAni:changeAnimation("2", true)
							end
							if self._tickCount == 1 then
								Audio.playSoundConfig("DDZUI", "countdown_1")
							else
								Audio.playSoundConfig("DDZUI", "countdown_2")
							end
						else
							if state == "2" then
								self._nzAni:changeAnimation("1", true)
							end
						end
					end
				else
					self._widgets.txt_countdown:setVisible(false)
					self._nzAni:setVisible(false)
					Game:dispatchCustomEvent(GEvent("ddz", "countdown_finish"), self._clientPos)
				end
				self._widgets.txt_countdown:setString(tostring(Number.ceil(self._tickCount)))
			end
		else
			self._widgets.txt_countdown:setVisible(false)
			self._nzAni:setVisible(false)
			self._canCountDown = false
		end
	end
end

function M:hideJiaoFen()
	self._widgets.pan_jf:setVisible(false)
end

function M:setBanker(clientPos)
	self._isBanker = clientPos == self._clientPos
end

function M:isBanker()
	return self._isBanker
end

function M:isMyTurn()
	return self._myTurn and self._tickCount>0
end

return M