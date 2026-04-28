--[[
押注游戏数据基类
]]

local M = class("BetDB")

function M:ctor()
    self:init()
end

function M:init()
    -- 状态(房间信息)
    self._state = 0
    -- 房间信息
    self._roomInfo = {}
    -- 庄家信息
    self._bankerInfo = {}
    -- 奖池ID
    self._pondId = 0
    -- 奖池信息
    self._pondList = {}

    -- 总下注信息
    self._allBetData = {} 
    -- 我的下注信息
    self._myBetData = {} 
    -- 保存我的下注信息
    self._savedBetData = {{},{}} 

    -- 参与玩家列表
    self._playerList = {} 
    -- 历史开奖记录
    self._record = {} 
    -- 历史记录容量
    self._recordCapacity = 10 

    -- 开奖信息
    self._rewardData = {} 
    -- 结算统计
    self._resultData = {} 
    -- 在座玩家赢取金币
    self._seatWinInfo = {} 
	self._myBetDataTemp = {[1] = 0,[2] = 0,[3] = 0,[4] = 0}
    
    -- 自定义关键字
    self._infoKey = {
        room_info       = "room_info",
        banker_info     = "banker_info",
        pond_list       = "pond_list",
        pond_list_idx   = "index",
        pond_list_val   = "value",
        all_bet         = "all_bet",
        my_bet          = "my_bet",
        saved_bet       = "saved_bet",
        player_list     = "player_list",
        player_list_idx = "pos",
        player_list_val = "seat_player",
        record_list     = "record_list",
        rec_list_val    = "value",
        reward_data     = "reward_data",
        result_data     = "result_data",
    }
end

--[[
设置游戏数据
]]
function M:setData(info)
    if info then
        self:setRoomInfo(info[self._infoKey.room_info])
        self:setBankerInfo(info[self._infoKey.banker_info])
        self:setPondData(info[self._infoKey.pond_list], self._infoKey.pond_list_idx, self._infoKey.pond_list_val)
        self:setAllBetData(info[self._infoKey.all_bet])
        self:setMyBetData(info[self._infoKey.my_bet])
        self:setPlayerList(info[self._infoKey.player_list], self._infoKey.player_list_idx, self._infoKey.player_list_val)
        self:setRecordList(info[self._infoKey.record_list], self._infoKey.rec_list_val)
        self:setRewardData(info[self._infoKey.reward_data])
        self:setResultData(info[self._infoKey.result_data])
    end
end

---------------------------------------
-- 房间信息
function M:setRoomInfo(info)
    if info then
        self._roomInfo = table.newclone(info)
    end
end

function M:updateRoomInfo(info)
    if info then
        table.merge(self._roomInfo, info)
    end
end

function M:getRoomInfo(info)
    return self._roomInfo
end

function M:getRoomLimit()
    -- override
end

---------------------------------------
-- 庄家信息
function M:setBankerInfo(info, uid)
    if info then
        if self._preBankerInfo then
            self._preBankerInfo = table.newclone(self._bankerInfo)
        else
            self._preBankerInfo = table.newclone(info)
        end
        self._bankerInfo = table.newclone(info)
        uid = uid or info.player_id
        if uid then
            if uid == Game:doPluginAPI("get", "playerUid") then
                self._myBetData.is_dealer = info.is_dealer or 1
                self._myBetData.is_apply = info.is_apply or 0
            else
                self._myBetData.is_dealer = 0
            end
        end
    end
end

function M:getBankerInfo(info)
    return self._bankerInfo
end

function M:getPreBankerInfo()
    return self._preBankerInfo
end

---------------------------------------
-- 玩家信息
function M:setPlayerList(info, idxKey, valKey)
    if info then
        self._playerList = {}
        if idxKey and valKey then
            for i,v in pairs(info) do
                self._playerList[v[idxKey]] = table.newclone(v[valKey])
            end
        else
            self._playerList = table.newclone(info)
        end
    end
end

function M:getPlayerList(idx)
    if idx then
        return self._playerList[idx]
    else
        return self._playerList
    end
end

function M:setPlayer(info, idx)
    if idx then
        if type(info) == "table" then
            self._playerList[idx] = table.newclone(info)
        else
            self._playerList[idx] = info
        end
    else
        if type(info) == "table" then
            self._playerList[#self._playerList + 1] = table.newclone(info)
        else
            self._playerList[#self._playerList + 1] = info
        end
    end
end

function M:getPlayer(uid)
    if uid then
        for k,v in pairs(self._playerList) do
            if v.uid == uid then
                return v
            end
        end
    end
end

---------------------------------------
-- 奖池信息
function M:setPondData(info, idxKey, valKey)
    if type(info) == "number" then
        self._pondId = info
    elseif type(info) == "table" then
        -- 从配置表获取奖池信息
        idxKey = idxKey or self._infoKey.pond_list_idx
        valKey = valKey or self._infoKey.pond_list_val
        self._pondList = {}
        for k,v in pairs(info) do
            self._pondList[v[idxKey] + 1] = v[valKey]
        end
    end
end

function M:getPondData()
    return self._pondId, self._pondList
end

---------------------------------------
-- 押注信息
function M:setAllBetData(info)
    if info then
        self._allBetData = table.newclone(info)
    end
end

function M:getAllBetData(idx)
    if idx then
        return self._allBetData[idx]
    else
        return self._allBetData
    end
end

function M:setMyBetData(info, withDealer, withApply)
    if info then
        if withDealer then
            withDealer = self._myBetData.is_dealer
        end
        if withApply then
            withApply = self._myBetData.is_apply
        end
        self._myBetData = table.newclone(info)
        self._myBetData.is_dealer = withDealer or self._myBetData.is_dealer
        self._myBetData.is_apply = withApply or self._myBetData.is_apply
    end
end

function M:getMyBetData()
    return self._myBetData
end

---------------------------------------
-- 结算信息
function M:getSeatWinInfo(pid)
    if pid then
        return self._seatWinInfo[pid]
    else
        return self._seatWinInfo
    end
end

function M:setSeatWinInfo(info, pid)
    if info then
        pid = pid or info.player_id
        local coin
        if pid == Game:doPluginAPI("get", "playerUid") then
            coin = Game:doPluginAPI("get", "playerCoin")
        else
            local player = self:getPlayer(pid)
            if player then
                coin = player.coin
            end
        end
        if coin then
            self._seatWinInfo[pid] = info.coin - coin
        end
    end
end

function M:setRecordCapacity(capacity)
    self._recordCapacity = capacity
end

function M:getRecordCapacity()
    return self._recordCapacity
end

function M:setRecordList(info, valKey)
    if info then
        self._record = {}
        for i,v in ipairs(info) do
            if type(v) == "table" then
                self._record[i] = v[valKey or self._infoKey.rec_list_val] or v
            else
                self._record[i] = v
            end
        end
    end
end

function M:getRecordList(idx)
    if idx then
        return self._record[idx]
    else
        return self._record
    end
end

function M:appendRecord(info, pushback)
    if pushback then
        if #self._record == self._recordCapacity then
            table.remove(self._record, 1)
        end
        table.insert(self._record, table.newclone(info))
    else
        if #self._record == self._recordCapacity then
            table.remove(self._record)
        end
        table.insert(self._record, 1, table.newclone(info))
    end
end

function M:setRewardData(info)
    if info then
        self._rewardData = table.newclone(info)
    end
end

function M:getRewardData(key)
    if key then
        return self._rewardData[key]
    else
        return self._rewardData
    end
end

function M:setResultData(info)
    if info then
        self._resultData = table.newclone(info)
    end
end

function M:getResultData()
    return self._resultData
end

function M:getSavedBet(idx)
    if idx then
        return self._savedBetData[1][idx]
    else
        return self._savedBetData[1]
    end
end

function M:getSavedBetCount(idx)
    idx = idx or 1
    local count = #self._savedBetData[idx]
    if count > 0 then
        count = 0
        for _, v in ipairs(self._savedBetData[idx]) do
            if checknumber(v.coin) > 0 then
                count = count + 1
            end
        end
    end
    return count
end

function M:appendSavedBet(info)
    if type(info) ~= "table" then return end
    local begin = #self._savedBetData[2] + 1
    local len = #info
    for i = 0, len - 1 do
        self._savedBetData[2][i + begin] = table.newclone(info[i + 1])
    end
end

function M:roleSavedBet()
    if #self._savedBetData[2] > 0 then
        self._savedBetData[1] = table.newclone(self._savedBetData[2])
        self._savedBetData[2] = {}
    end
end

function M:resetDataNext()
    self._allBetData = {} -- 总下注信息
    self._rewardData = {} -- 开奖信息
    self._resultData = {} -- 结算统计
    self._seatWinInfo = {} -- 结算统计
    self:setMyBetData({}, true, true) -- 我的下注信息
    self:roleSavedBet()
end

function M:setMyBetDataTemp(info)
    if info then
        self._myBetDataTemp[info[1].area] = self._myBetDataTemp[info[1].area] + info[1].coin
    end
end

function M:clearMyBetDataTemp(idx)
   if self._myBetDataTemp[idx] then
      self._myBetDataTemp[idx] = 0
   end
end

function M:getMyBetDataTemp()
    return self._myBetDataTemp
end

return M
