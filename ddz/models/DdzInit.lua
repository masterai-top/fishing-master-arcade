--[[
斗地主入口文件
]]

local DdzUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--

if not DdzPokeConfig then loadConfig("DdzPokeConfig") end
if not BetLimitConfig then loadConfig("BetLimitConfig") end
if not SubgameConfig then loadConfig("SubgameConfig") end

require_ex "games.ddz.models.DdzProtocol"
--[[ 创建类全局DB和Com对象 ]]--
Game.ddzDB = require_ex("games.ddz.models.DdzDB")
Game.ddzCom = require_ex("games.ddz.models.DdzCom")
Game.ddzRule = require_ex("games.ddz.models.DdzRule")
Game.DdzUtilTest = DdzUtilTest

--[[ 注册入口函数 ]]--
Game:registerAPI("game", "ddz", function ()
	--进入选房界面
	Game.ddzCom:reqEnterRoom()
end)


--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
    -- {"get",		"subgameData",		handlerSafe(Game.subgameDB, Game.subgameDB.getData)},
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.ddz)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
	{slg_cmd.ddz.ddz_leave[1],		handlerSafe(Game.ddzCom, Game.ddzCom.onLeaveNotify)},
	{slg_cmd.ddz.ddz_dispatch_cards[1], handlerSafe(Game.ddzCom, Game.ddzCom.onDispatchCardNotify)},
	{slg_cmd.ddz.ddz_call[1], 		handlerSafe(Game.ddzCom, Game.ddzCom.onCallNotify)},
	{slg_cmd.ddz.ddz_out_cards[1], 	handlerSafe(Game.ddzCom, Game.ddzCom.onOutCardsNotify)},
	{slg_cmd.ddz.ddz_banker_info[1], 	handlerSafe(Game.ddzCom, Game.ddzCom.onBankerInfoNotify)},
	{slg_cmd.ddz.ddz_room_info[1], 	handlerSafe(Game.ddzCom, Game.ddzCom.onRoomInfoNotify)},
	{slg_cmd.ddz.ddz_pass_card[1], 	handlerSafe(Game.ddzCom, Game.ddzCom.onPassCardNotify)},
	{slg_cmd.ddz.ddz_trustee[1], 	handlerSafe(Game.ddzCom, Game.ddzCom.onTrusteeNotify)},
	{slg_cmd.ddz.ddz_turn[1],	handlerSafe(Game.ddzCom, Game.ddzCom.onTurnNotify)},
	{slg_cmd.ddz.ddz_settlement[1], handlerSafe(Game.ddzCom, Game.ddzCom.onSettlementNotify)},
	{slg_cmd.ddz.ddz_debug[1],		handlerSafe(Game.ddzCom, Game.ddzCom.onDebugInfoNotify)},
	{slg_cmd.ddz.ddz_beishu[1],		handlerSafe(Game.ddzCom, Game.ddzCom.onBeishuUpdate)},
	{slg_cmd.ddz.ddz_seat_info[1],	handlerSafe(Game.ddzCom, Game.ddzCom.onSeatInfo)},
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
	
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or DdzUtilTest then
    Game.ddzDB:testDataMonitor()
end