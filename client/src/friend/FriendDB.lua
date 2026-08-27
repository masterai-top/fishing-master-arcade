--[[ 
好友相关数据 
]]

local M = class("FriendDB")

-- 列表栏目
cc.exports.FriendTab = {
    friend = 1,
    message = 2,
    apply = 3,
    search = 4,
}
-- 回复类型
cc.exports.FriendApply = {
    accept = 0,
    refuse = 1,
}
-- 聊天信息容量
local MSG_CAPACITY = 50

function M:ctor()
    self:init()
    Game:registerLogoutReset(self, handler(self, self.init))
end

function M:init()
    self._friendList = {}
    self._messageList = {}
    self._applyList = {}
    self._recommendList = {}
    self._redPoint = false
    self._redPointList = {false, false, false, false}
end

--[[
获取不同栏目的数据
@param tabIdx 	number 	栏目
@return table
]]
function M:getList(tabIdx)
	if not tabIdx or tabIdx == FriendTab.friend then
        return self:getFriendList()
    elseif tabIdx == FriendTab.message then
    	return self:getMessageList()
    elseif tabIdx == FriendTab.apply then
        return self:getApplyList()
    end
end

----------------------------------
-- 好友操作接口
function M:setFriendList(lst)
    self._friendList = lst or {}
    self:sortFriendList()
end

function M:updFriendList(list)
	local t
	for _, v in ipairs(list) do
		t = self:getFriendById(v.pid)
		if not t then
			self:addFriend(v)
		else
			table.merge(t, v)
		end
	end
	self:sortFriendList()
end

function M:getFriendList()
    return self._friendList
end

function M:getFriendCount()
    return #self._friendList
end

function M:addFriend(info)
	self._friendList[#self._friendList + 1] = info
end

function M:getFriendById(id)
	for _, v in ipairs(self._friendList) do
		if v.pid == id then
			return v
		end
	end
end

function M:delFriendById(id, info)
	if type(id) ~= "number" and info then
		id = info.del_id
	end
    for i, v in ipairs(self._friendList) do
        if v.pid == id then
            table.remove(self._friendList, i)
            return
        end
    end
end

function M:sortFriendList()
    table.sort(self._friendList, function(a, b)
        if a.online~=b.online then
            if a.online==1 then return true end
            if b.online==1 then return false end
        end
        return a.pid<b.pid
    end)
end

----------------------------------
-- 好友聊天接口
function M:setMessageList(lst)
    self._messageList = lst
end

function M:updMessageList(list)
	local now = Timer:getCurTimeStamp()
	local count, t, v = #list
	for i = count, 1, -1 do
		v = list[i]
		if not v.send_time then
			v.send_time = now
		end
		t = self:getMessageById(v.pid, v.send_time)
		if not t then
			self:addMessage(v)
		else
			table.merge(t, v)
		end
	end
	if not Assist.isEmpty(list) then
		self:setRedPoint(true, FriendTab.message)
	end
end

function M:getMessageList()
    return self._messageList
end

function M:addMessage(info)
	table.insert(self._messageList, 1, info)
	while #self._messageList > MSG_CAPACITY do
		table.remove(self._messageList)
	end
end

function M:getMessageById(id, time)
	if not time then return end
	for _, v in ipairs(self._messageList) do
		if v.pid == id and v.send_time == time then
			return v
		end
	end
end

function M:delMessageById(id, time)
    for i, v in ipairs(self._messageList) do
        if v.pid == id and v.send_time == time then
            table.remove(self._messageList, i)
            return
        end
    end
end

----------------------------------
-- 好友申请接口
function M:setApplyList(lst)
    self._applyList = lst
end

function M:updApplyList(list)
	local t
	for _, v in ipairs(list) do
		t = self:getApplyById(v.pid)
		if not t then
			self:addApply(v)
		else
			table.merge(t, v)
		end
	end
	if not Assist.isEmpty(list) then
		self:setRedPoint(true, FriendTab.apply)
	end
end

function M:getApplyList()
    return self._applyList
end

function M:addApply(info)
	table.insert(self._applyList, 1, info)
end

function M:getApplyById(id)
	for _, v in ipairs(self._applyList) do
		if v.pid == id then
			return v
		end
	end
end

function M:delApplyById(id)
    for i, v in ipairs(self._applyList) do
        if v.pid == id then
            table.remove(self._applyList, i)
            return
        end
    end
end

function M:checkApply()
	return not Assist.isEmpty(self._applyList)
end

----------------------------------
-- 好友推荐接口
function M:setRecommendList(lst)
    self._recommendList = lst
end

function M:updRecommendList(list)
	local t
	for _, v in ipairs(list) do
		t = self:getRecommendById(v.pid)
		if t then
			table.merge(t, v)
		end
	end
end

function M:getRecommendList()
    return self._recommendList
end

function M:getRecommendById(id)
	for _, v in ipairs(self._recommendList) do
		if v.uid == id then
			return v
		end
	end
end

----------------------------------
-- 聊天信息本地存储
function M:getMsgFromLocal()
	local uid = Game:doPluginAPI("get", "playerUid")
	local key = "fmsg_"..uid
	local content = Game.localDB:getStringForKey(key, "{}")
	self:setMessageList(String.toTable(content))
end

function M:saveMsgToLocal()
	local uid = Game:doPluginAPI("get", "playerUid")
	local key, content = "fmsg_"..uid, Table.toString(self._messageList)
	Game.localDB:setStringForKey(key, content)
end

----------------------------------
-- 红点
function M:setRedPoint(rp, tabIdx)
    if type(rp) == "boolean" then
        self._redPoint = rp
        if type(tabIdx) == "number" then
        	self._redPointList[tabIdx] = rp
        end
    else
        self._redPoint = false
        if type(tabIdx) == "number" then
        	self._redPointList[tabIdx] = false
        end
    end

    if not self._redPoint then
	    for _,v in ipairs(self._redPointList) do
	    	if v then
	    		self._redPoint = true
	    		break
	    	end
	    end
    end

    Game:dispatchCustomEvent(GEvent("GAME_RED_POINT_EVENT"), {key="friend", show=self._redPoint})
end

function M:getRedPoint()
    return self._redPoint
end

function M:getTabRedPoint(tabIdx)
    return self._redPointList[tabIdx]
end

----------------------------------
-- 单机数据模拟
function M:testDataMonitor()
	local function _simFriend_()
		return {
			type = 0,
			pid = Number.random(100000, 1000000),
			facelook = Number.random(10001, 10006),
			nick = String.random(8),
			sign = String.random(Number.random(10, 80)),
			online = Number.random(0, 1),
			other = Number.random(100, 1000),
			coin = Number.random(100000, 1000000),
			lottery = Number.random(0, 10000),
			vip = Number.random(0, 15),
		}
	end

	local function _simMessage_()
		return {
			pid = Number.random(100000, 1000000),
			facelook = Number.random(10001, 10006),
			nick = String.random(8),
			time = Timer:getCurTimeStamp() - Number.random(100, 10000),
			msg = String.random(80),
			chat = {},
		}
	end

	local function _simApply_()
		return {
			pid = Number.random(100000, 1000000),
			facelook = Number.random(10001, 10006),
			nick = String.random(8),
			online = Number.random(0, 1),
			other = Number.random(100, 1000),
		}
	end

	local list, count = {}, Number.random(-10, 50)
	if count > 0 then
		for i=1,count do
			list[i] = _simFriend_()
		end
	end
	self:setFriendList(list)

	list, count = {}, Number.random(-10, 50)
	if count > 0 then
		for i=1,count do
			list[i] = _simMessage_()
		end
	end
	self:setMessageList(list)

	list, count = {}, Number.random(-10, 50)
	if count > 0 then
		for i=1,count do
			list[i] = _simApply_()
		end
	end
	self:setApplyList(list)
end

return M:new()
