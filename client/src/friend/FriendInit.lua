--[[
好友入口文件
]]

local FriendUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--
-- if not FriendConfig then loadConfig("FriendConfig") end
require_ex "ui.friend.FriendProtocol"

--[[ 创建类全局DB和Com对象 ]]--
Game.friendDB = require_ex("ui.friend.FriendDB")
Game.friendCom = require_ex("ui.friend.FriendCom")

--[[ 注册入口函数 ]]--
Game:registerAPI("enter", "friend", function()
	local tabIdx
	if Game.friendDB:getFriendCount() == 0 then
		tabIdx = FriendTab.search
	end
    require_ex("ui.friend.FriendUI").new(tabIdx):addToScene()
end)

--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
    {"get",     "friendList",       handler(Game.friendDB, Game.friendDB.getFriendList)},
    {"get",     "friend",       	handler(Game.friendDB, Game.friendDB.getFriendById)},
    {"add",     "friend",       	handler(Game.friendCom, Game.friendCom.onAddFriend)},
    {"check",   "friend",       	handler(Game.friendDB, Game.friendDB.checkApply)},
    {"get",   	"friendApply",      handler(Game.friendDB, Game.friendDB.getApplyList)},

    {"send",   	"friendApply",      handler(Game.friendCom, Game.friendCom.onApply)},
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.friend)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
	{slg_cmd.friend.updData[1],    handler(Game.friendCom, Game.friendCom.onGetData)},
	{slg_cmd.friend.read[1],       handler(Game.friendCom, Game.friendCom.onGetMessage)},
	{slg_cmd.friend.del[1],        handler(Game.friendDB, Game.friendDB.delFriendById)},
	{slg_cmd.friend.updList[1],    handler(Game.friendCom, Game.friendCom.onGetApply)},
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
	function()
        Game.friendCom:queryData(handler(Game, Game.prepareNext))
    end,
    function()
    	Game.friendDB:getMsgFromLocal()
        Game.friendCom:queryMessage(handler(Game, Game.prepareNext))
    end,
    function()
        Game.friendCom:queryApply(handler(Game, Game.prepareNext))
    end,
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or FriendUtilTest then
    Game.friendDB:testDataMonitor()
end