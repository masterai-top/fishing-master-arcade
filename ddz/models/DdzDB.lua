local M = class("DdzDB")
local PLAYER_COUNT = 3
local POKE_COUNT = 52
local ddzPoke = require_ex("games.ddz.views.DdzPoke")

function M:ctor()
	self:init()
end

function M:init()
	self._baseScore = 0			-- 底分
	self._originPokesData = {}	-- 原始扑克数据
	self._settlement = {}		-- 结算信息
	self._debugInfo = nil		-- 调试信息
	self._reconnect = false		-- 是否重连
	self._gameState = -1	 	-- 游戏状态
	self._playersInfo = {}		-- 玩家数据信息
	self._svrPos = 0			-- 服务器位置
	self._bankerInfo = {} 		-- 庄家信息
	self._curCallScore = 0		-- 当前叫分
	self._beishu = 1			-- 当前倍数
	self._isTuoGuan = false		-- 是否托管
	self._bankerOut = {}		-- 三张地主牌已出的牌
	self._background = false
	self._curSeat = 0			-- 断线重连后判断显示用
	self._cardPoolQ = require("lib.Queue").new()
	self:createCardPool()
end

-- 重置数据
function M:reset()
	self._originPokesData = {}
	self._settlement = {}
	self._debugInfo = nil
	self._gameState = -1
	self._svrPos = 0			-- 服务器位置
	self._reconnect = false		-- 是否重连
	self._playersInfo = {}		-- 玩家数据信息
	self._bankerInfo = {} 		-- 庄家信息
	self._curCallScore = 0		-- 当前叫分
	self._beishu = 1			-- 当前倍数
	self._isTuoGuan = false		-- 是否托管
	self._bankerOut = {}		-- 三张地主牌已出的牌
	self._background = false
	self._curSeat = 0
end

-- 设置底注
function M:setBaseScore(baseScore)
	self._baseScore = baseScore
end

function M:getBaseScore()
	return self._baseScore
end

-- 原始数据
function M:setOriginPokesData(originPokesData)
	self._originPokesData = table.newclone(originPokesData)
end

function M:getOriginPokesData()
	return self._originPokesData
end

-- 重进时游戏状态
function M:setGameState(state)
	self._gameState = state
end

function M:getGameState()
	return self._gameState
end

-- 游戏是否重连
function M:isReconnect()
	return self._reconnect
end

-- 座位信息
function M:convertToSvrPos(clientPos)
	local pos = self._svrPos + clientPos - 1
	if pos <= PLAYER_COUNT then
		return pos
	else
		return pos-PLAYER_COUNT
	end
end

function M:convertToClientPos(svrPos)
	local pos = 0
	if svrPos >= self._svrPos then
		pos = svrPos - self._svrPos + 1
	else
		pos = svrPos + PLAYER_COUNT - self._svrPos + 1
	end
	return pos
end

function M:setPlayersInfo(seat_info)
	local uid = Game:doPluginAPI("get", "playerUid")
	for _, v in ipairs(seat_info) do
		local info = v.player_base_info or v
		if info.uid == uid then
			self._svrPos = info.pos
			break
		end
	end
	for _, v in ipairs(seat_info) do
		local info = v.player_base_info or v
		local clientPos = self:convertToClientPos(info.pos)
		self._playersInfo[clientPos] = v
	end
end

function M:getPlayersInfo()
	return self._playersInfo
end

function M:setRoomInfo(roomInfo)
	self._reconnect = true
	self._beishu = roomInfo.num
	self._baseScore = roomInfo.score
	self._bankerInfo.banker_card = roomInfo.banker_card
	table.sort(self._bankerInfo.banker_card)
	self._bankerInfo.banker_score = roomInfo.banker_score
	self._bankerInfo.banker_player = roomInfo.banker_player

	self:setPlayersInfo(roomInfo.seat_list)
	self:setOriginPokesData(roomInfo.card_list)
	self:setGameState(roomInfo.state)
	self:setBankerOut(roomInfo.banker_out)
	self:setCurSeat(roomInfo.cur_seat)
	self._curCallScore = 0
	for k, v in ipairs(roomInfo.seat_list) do
		self._curCallScore = Number.max(v.call_score, self._curCallScore)
	end
end

function M:setCurSeat(curSeat)
	self._curSeat = self:convertToClientPos(curSeat)
end

function M:getCurSeat()
	return self._curSeat
end

function M:setBankerOut(banker_out)
	self._bankerOut = banker_out
end

function M:getBankerOut()
	return self._bankerOut
end

-- 确定庄家信息
function M:setBankerInfo(bankerInfo)
	self._bankerInfo = bankerInfo
	table.sort(self._bankerInfo.banker_card)
end

function M:getBankerInfo()
	return self._bankerInfo
end

function M:setCallInfo(info)
	print("-------------setCallInfo------------")
	print("self._svrPos:",self._svrPos)
	if info.call_player ~= self._svrPos then
		self._curCallScore = Number.max(self._curCallScore, info.score)
	end
	print("self._curCallScore:", self._curCallScore)
	print("------------------------------------")
end

function M:getCurCallScore()
	return self._curCallScore
end

-- 结算信息
function M:setSettlement(settlementInfo)
	self._settlement = settlementInfo
end

function M:getSettlement()
	return self._settlement
end

function M:setBeishu(beishu)
	self._beishu = beishu
end

function M:getBeishu()
	return self._beishu
end

function M:setTuoguan(tuoguan)
	self._isTuoGuan = tuoguan
end

function M:isTuoguan()
	return self._isTuoGuan
end

-- 调试信息
function M:setDebugInfo(msg)
	self._debugInfo = msg
end

function M:getDebugInfo()
	return self._debugInfo
end

function M:setBackground(flag)
	self._background = flag
end

function M:background()
	return self._background
end
-------------------------------------------------
-- 纸牌池
function M:createCardPool()
	local card
	for i=1, POKE_COUNT do
		card = ddzPoke.new()
		card:retain()
		self._cardPoolQ:push(card)
	end
end

function M:pushCardPool(card)
	if not Assist.isEmpty(card) then
		card:reset()
		card:retain()
		card:setVisible(false)
		card:removeFromParent(true)
		self._cardPoolQ:push(card)
	end
end

function M:popCardFromPool()
	local card = self._cardPoolQ:pop()
	if Assist.isEmpty(card) then
		card = ddzPoke.new()
		card:retain()
	end
	card:setVisible(true)
	return card
end

function M:getCardFromPool(card_v, parent)
	local card = self:popCardFromPool()
	parent:addChild(card)
	card:release()
	card:changeValue(card_v)
	return card
end
----------------------------------
-- 单机数据模拟
function M:testDataMonitor()
	local pokeData = {310,320,330,340,410,420,430,510,520,640,710,1120,2100,2200}
	self:setOriginPokesData(pokeData)
end

return M:new()