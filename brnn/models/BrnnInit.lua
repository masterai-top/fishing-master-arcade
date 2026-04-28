--[[
百人牛牛入口文件
]]

local BrnnUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--
if not NiuConfig then loadConfig("NiuConfig") end
if not NnstateConfig then loadConfig("NnstateConfig") end
if not GameLimitConfig then loadConfig("GameLimitConfig") end

require_ex "games.brnn.models.BrnnProtocol"
--[[ 创建类全局DB和Com对象 ]]--
if Game.betMng then
	Game.betMng:betStop()
else
	Game.betMng = require_ex("data.BetManager")
end

if not Game.brnnDB then
	Game.brnnDB = require_ex("games.brnn.models.BrnnDB")
end
if not Game.brnnCom then
	Game.brnnCom = require_ex("games.brnn.models.BrnnCom")
end
Game.brnnCom:reset()

--[[ 注册入口函数 ]]--
Game:registerAPI("game", "brnn", function (cb)
	Game.brnnCom:reqEnterGame(cb)
end)


--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
    -- {"get",		"subgameData",		handlerSafe(Game.subgameDB, Game.subgameDB.getData)},
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.brnn)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
	{slg_cmd.brnn.nn_sit_list[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetSitList)},
	{slg_cmd.brnn.nn_bet_list[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetBetList)},
	{slg_cmd.brnn.nn_room_info[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetRoomInfo)},
	{slg_cmd.brnn.nn_state_change[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetRoomState)},
	{slg_cmd.brnn.nn_card_list[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetCardList)},
	{slg_cmd.brnn.nn_settlement[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetResultInfo)},
	{slg_cmd.brnn.nn_reward_pool[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetRewardPool)},
	{slg_cmd.brnn.nn_banker_list[1], handlerSafe(Game.brnnCom,Game.brnnCom.onGetBankerList)},
	{slg_cmd.brnn.nn_banker_change[1],handlerSafe(Game.brnnCom,Game.brnnCom.onBankerChange)},
	{slg_cmd.brnn.nn_reward[1],handlerSafe(Game.brnnCom,Game.brnnCom.onReward)},
	{slg_cmd.brnn.nn_debug[1],handlerSafe(Game.brnnCom,Game.brnnCom.onJackpotDebug)},
	{slg_cmd.brnn.nn_jackpot[1],handlerSafe(Game.brnnCom,Game.brnnCom.onJackpotChange)},
	{slg_cmd.brnn.nn_item_change[1],handlerSafe(Game.brnnCom,Game.brnnCom.onGoldChange)},
	{slg_cmd.brnn.nn_force_cancel_bank[1],handlerSafe(Game.brnnCom,Game.brnnCom.onForceBankerChange)},
	{slg_cmd.brnn.nn_leave[1],handlerSafe(Game.brnnCom,Game.brnnCom._onExit)},
	{slg_cmd.brnn.nn_tips[1],handlerSafe(Game.brnnCom,Game.brnnCom.onTips)},
	{slg_cmd.brnn.nn_chat[1],handlerSafe(Game.brnnCom,Game.brnnCom.onReplyChat)},
	{slg_cmd.brnn.nn_msg[1],handlerSafe(Game.brnnCom,Game.brnnCom.onReplyMsg)},
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
	-- function ()
    --     Game.subgameCom:queryData(handlerSafe(Game, Game.prepareNext))
    -- end,
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or BrnnUtilTest then
    Game.brnnDB:testDataMonitor()
end