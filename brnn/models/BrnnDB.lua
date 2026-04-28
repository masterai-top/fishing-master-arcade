local M = class("BrnnDB")

function M:ctor()
	self._funcId = 1020
    self:init()
end

function M:init()
	self._uid = Game:doPluginAPI("get","playerUid")
	self._bankerList = nil		--上庄队列
    self._playerList = nil		--玩家列表
    self._sitList = nil			--在座玩家
    self._bankerInfo = nil		--庄家信息
    self._areaList = nil		--
    self._historyList = nil		--历史走势
    self._chipList = nil		--可选筹码列表
    self._sitDown = false		--是否坐下
    self._cardInfo = nil		--开牌信息
    self._inBankerQueue = false
    self._resultInfo = nil		--结算数据
    self._jackpot = 0			--奖池数据记录
    self._curGold = -1
    self._curBetList = nil 
    self._bankerChange = false 	--庄家变换操作
    self._jackpotInfo = nil		--奖池信息
    self._jackpotReward = nil	--奖池奖励
    self._haveJackpotReward = false
    self._debugInfo = nil
    self._background = false
    self._beginDownBanker = false
    self._serverTipCode = 0		--服务端推送的输赢信息编码
    self._serverKickOutStatus = false
    self:refreshChipList()
end

--开局重置信息
function M:resetDataNext()
	self._bankerChange = false
	self._haveJackpotReward = false
	self._jackpotInfo = nil
	self._cardInfo = nil
end

--上庄列表
function M:setBankerList(banker_list)
	self._bankerList = banker_list
end

function M:getBankerList()
	return self._bankerList
end

--在座玩家列表
function M:setSitList(sit_list)
	self._sitList = sit_list
end

function M:getSitList()
	return self._sitList
end

function M:getPlayerBySeat(seatIdx)
	local player
	for _,v in ipairs(self._sitList or {}) do
		if v.sitno == seatIdx then
			player = v.player
			break
		end
	end
	return player
end

function M:getSeatIdxByUid(uid)
	local seatIdx = -1 			--其他人的位置
	for _,v in ipairs(self._sitList or {}) do
		if v.player.uid == uid then
			seatIdx = v.sitno
			break
		end
	end
	return seatIdx
end

function M:checkBanker(uid)
	local ret = false
	if self._bankerInfo then
		ret = self._bankerInfo.player.uid == uid
	end
	return ret
end

--玩家列表
function M:setPlayerList(player_list)
	self._playerList = player_list
end

function M:getPlayerList()
	return self._playerList
end

--当前庄家信息
function M:setBankerInfo(banker_info)
	self._bankerInfo = banker_info
	if banker_info.player.uid == self._uid then
		self._inBankerQueue = false
	end
end

function M:getBankerInfo()
	return self._bankerInfo
end

--区域下注情况
function M:setAreaList(area_list)
	self._areaList = area_list
end

function M:getAreaList()
	return self._areaList
end

--胜负走势
function M:setHistoryList(history_list)
	self._historyList = history_list
end

function M:getHistoryList()
	return self._historyList
end

--判断自己是否是庄家
function M:isBanker()
	local ret = false
	if self._bankerInfo then
		ret = self._uid == (self._bankerInfo.player.uid)
	end
	return ret
end

--判断是否在上庄队列
function M:isInBankerQueue()
	return self._inBankerQueue
end

function M:setInBankerQueue(flag)
	self._inBankerQueue = flag
end

--刷新押注列表
function M:refreshChipList()
	local coin = self:getCurGold()
	local bet_list = BetLimitConfig.chip_list(self._funcId)

	for _,v in ipairs(bet_list or {}) do
		local min = v[1] or 0
		local max = v[2] or -1
		if coin >= min and (coin <= max or max == -1) then --防止coin为0时报错
			self:setChipList(v[3])
			break
		end
	end
end

--筹码列表
function M:setChipList(info)
	if info then
		self._chipList = {}
		for i,v in ipairs(info) do
			self._chipList[i] = v
		end
	end
end

function M:getChipList(idx)
    if idx then
        return self._chipList[idx] or 0
    else
        return self._chipList
    end
end

--坐下状态
function M:setSitDown(flag)
	self._sitDown = flag
end

function M:sitDown()
	return self._sitDown
end

--牌信息存储
function M:setCardInfo(cardList)
	--调整顺序 庄家牌在前 其余在后
	local info = cardList[5]
	table.remove(cardList,5)
	table.insert(cardList,1,info)
	self._cardList = cardList
end

function M:getCardInfo()
	return self._cardList
end

--结算信息
function M:setResultInfo(info)
	self._resultInfo = info
end

function M:getResultInfo()
	return self._resultInfo
end

--奖池
function M:setJackpot(num)
	self._jackpot = num
end

function M:getJackpot()
	return self._jackpot
end

--当前金币
function M:setCurGold(gold)
	self._curGold = gold
end

function M:getCurGold()
	local gold = self._curGold
	if gold == -1 then
		if self:isBulletRoom() then
			gold = Game:doPluginAPI("get","playerJade")
		else
			gold = Game:doPluginAPI("get","playerCoin")
		end
	end
	return gold
end

--当前下注
function M:setCurBetList(bet_list)
	self._curBetList = bet_list
end

function M:getCurBetList()
	return self._curBetList
end

--庄家变换
function M:setBankerChange(flag)
	self._bankerChange = flag
end

function M:bankerChange()
	return self._bankerChange
end

--奖池信息
function M:setJackpotReward(info)
	self._jackpotReward = info
	self._haveJackpotReward = true
end

function M:getJackpotReward()
	return self._jackpotReward
end

function M:haveJackpotReward()
	return self._haveJackpotReward
end

function M:setJackpotInfo(info)
	self._jackpotInfo = info
end

function M:getJackpotInfo()
	return self._jackpotInfo
end

function M:isSystemBanker()
	local ret = true
	if self._bankerInfo then
		ret = self._bankerInfo.player.uid == 0 
	end
	return ret
end

--设置调试信息
function M:setDebugInfo(info)
	self._debugInfo = info
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

--庄家准备强制下庄
function M:setBankerReadyDown(flag)
	self._beginDownBanker = flag
end

function M:bankerReadyDown()
	return self._beginDownBanker
end

function M:setFuncId(func_id)
	self._funcId = func_id
	self:refreshChipList()
end

function M:getFuncId()
	return self._funcId
end

--弹头场
function M:isBulletRoom()
	return self._funcId == 1055
end

--金币场
function M:isCoinRoom()
	return self._funcId == 1020
end

function M:getMinBetCoin()
	local coin = GameLimitConfig.value(25)
	if self:isBulletRoom() then
		coin = GameLimitConfig.value(49)
	end
	return coin
end

--魔法表情发送限制
function M:getMagicLimit()
	local strLimit
	local gameLimit
	if self:isBulletRoom() then
		gameLimit = GameLimitConfig.value(51)
	elseif self:isCoinRoom() then
		gameLimit = GameLimitConfig.value(50)
	end
	if gameLimit[2]>0 then
		strLimit = gameLimit[2]..ItemsConfig.name(gameLimit[1])
	end
	return strLimit
end

function M:setServerTipsCode(tip_code)
	self._serverTipCode = tip_code
end

function M:getServerTipsCode()
	return self._serverTipCode
end

function M:setKickOutStatus(status)
	self._serverKickOutStatus = status
end

function M:getKickOutStatus()
	return self._serverKickOutStatus
end

--单元测试
function M:testDataMonitor()
	------------------------玩家列表--------------------
	local Count = 22
	local initUid = 10001000001
	local playerList = {}
	for _ =1,Count do
		local temp = {}
		temp.uid = initUid
		temp.name = self:generalRandomStr(6)
		temp.iconId = "10001"
		temp.vipLv = 0
		temp.gold = 10000
		table.insert(playerList,temp)
		initUid = initUid + 1
	end
	Game.brnnDB:setPlayerList(playerList)
	------------------------胜负走势--------------------
	local history_list = {{0,1,0,1},{1,1,1,1}}
	Game.brnnDB:setHistoryList(history_list)
	------------------------房间信息--------------------
	local roomInfo = {}
	local banker = {}
	banker.num = 20000000
	banker.player = {}
	banker.player.name = self:generalRandomStr(5)
	banker.player.uid = initUid
	banker.player.iconId = "10001"
	banker.player.gold = 100000000
	banker.player.vipLv = 5
	roomInfo.banker = banker
	roomInfo.area_list = {
		{area_id=0,mine_bet=100,total_bet=20100,bet_list={100,10000,10000}},
		{area_id=1,mine_bet=10000,total_bet=20000,bet_list={10000,10000}},
		{area_id=2,mine_bet=20000,total_bet=20000,bet_list={10000,10000}},
		{area_id=3,mine_bet=1000,total_bet=21000,bet_list={1000,10000,10000}},
	}
	Game.brnnCom:onGetRoomInfo(_,roomInfo)
	-----------------------上座列表---------------------
	local seatInfo = {}
	for i=1,6 do 
		local tmp = {}
		tmp.sitno = i
		tmp.player = {}
		tmp.player.name = self:generalRandomStr(5)
		tmp.player.uid = initUid
		tmp.player.iconId = "10001"
		tmp.player.gold = 100000000
		tmp.player.vipLv = 5
		table.insert(seatInfo,tmp)
	end
	self:setSitList(seatInfo)
	------------------------上庄列表----------------------
	self:setBankerList({banker})
end

local mrandom = math.random
--获取随机字符串
function M:generalRandomStr(length)
	local str = ""
	for _ =1,length do
		str = str..string.char(mrandom(97,122))
	end
	return str
end

return M:new()
