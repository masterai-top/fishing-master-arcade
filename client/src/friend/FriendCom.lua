--[[ 
好友相关逻辑（交互和响应） 
]]

local M = class("FriendCom")
local _TAG = "FRIEND"

function M:ctor()
    self:init()
end

function M:init()

end

---------------------------------------------
-- 请求数据
function M:queryData(callback)
	netCom.send({0}, slg_cmd.friend.getData[1], function(pack, info)
		dump(info, _TAG)
        Game.friendDB:setFriendList(info.list)
        if type(callback) == "function" then
        	callback()
        end
    end)
end

function M:queryMessage(callback)
	netCom.send({0}, slg_cmd.friend.read[1], function(pack, info)
		dump(info, _TAG)
        if callback then
        	callback()
        end
    end)
end

function M:queryApply(callback)
	netCom.send({0}, slg_cmd.friend.reqList[1], function(pack, info)
		dump(info, _TAG)
        Game.friendDB:setApplyList(info.list)
        if callback then
        	callback()
        end
    end)
end

---------------------------------------------
-- 获取数据回调
function M:onGetData(pack, info)
	dump(info, _TAG)
	Game.friendDB:updFriendList(info.list)
end

function M:onGetMessage(pack, info)
	dump(info, _TAG)
	Game.friendDB:updMessageList(info.msg)
end

function M:onGetApply(pack, info)
	dump(info, _TAG)
	Game.friendDB:updApplyList(info.list)
end

---------------------------------------------
-- 交互
function M:onAddFriend(fid, callback)
	if DEBUG_OFFLINE then
		if callback then
			callback()
		end
		return
	end
	netCom.send({fid}, slg_cmd.friend.add[1], function(pack, info)
		dump(info, _TAG)
		if checknumber(info.code) == 0 then
			if callback then
				callback()
			end
			Game:tipMsg(Config.localize("add_friend_ok"))
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

function M:onDelFriend(fid, callback)
	if DEBUG_OFFLINE then
		Game.friendDB:delFriendById(fid)
		if callback then
			callback()
		end
		return
	end
	netCom.send({fid}, slg_cmd.friend.del[1], function(pack, info)
		if checknumber(info.code) == 0 then
			if callback then
				callback()
			end
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

function M:onDelMessage(fid, time, callback)
	Game.friendDB:delMessageById(fid, time)
	if callback then
		callback()
	end
end

function M:onApply(uid, pass, callback)
	if DEBUG_OFFLINE then
		if pass == FriendApply.accept then
			local v = Game.friendDB:getApplyById(uid)
			v.type = 0
			Game.friendDB:addFriend(table.newclone(v))
		end
		Game.friendDB:delApplyById(uid)
		if callback then
			callback()
		end
		return
	end
	netCom.send({uid, pass}, slg_cmd.friend.apply[1], function(pack, info)
		if checknumber(info.code) == 0 then
			Game.friendDB:delApplyById(uid)
			if callback then
				callback()
			end
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

function M:onChat(uid, msg)
	if DEBUG_OFFLINE then
		return
	end
	netCom.send({uid, msg}, slg_cmd.friend.chat[1], function(pack, info)
		if checknumber(info.code) == 0 then
			Game.friendDB:delApplyById(uid)
			if callback then
				callback()
			end
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

function M:onViewDetail(uid, callback)
	if DEBUG_OFFLINE then
		local v = Game.friendDB:getFriendById(uid)
		if callback then
			callback(v)
		end
		return
	end
	netCom.send({uid, msg}, slg_cmd.friend.chat[1], function(pack, info)
		if checknumber(info.code) == 0 then
			if callback then
				callback(info)
			end
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

function M:onRecommend(callback)
	if DEBUG_OFFLINE then
		if callback then
			callback()
		end
		return
	end
	netCom.send({}, slg_cmd.friend.recommend[1], function(pack, info)
		dump(info, _TAG)
		if checknumber(info.code) == 0 then
			Game.friendDB:setRecommendList(info.lists)
			if callback then
				callback()
			end
		else
			Game:tipError(checknumber(info.retcode or info.code))
		end
    end)
end

return M:new()
