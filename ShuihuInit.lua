--[[
水浒传入口文件
]]

local ShuihuUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--
-- if not luckLineConfig then loadConfig("luckLineConfig") end
if not LineRulesConfig then loadConfig("LineRulesConfig") end
require_ex "games.shuihu.models.ShuihuProtocol"

--[[ 创建类全局DB和Com对象 ]]--
if not Game.shuihuDB then
	Game.shuihuDB = require_ex("games.shuihu.models.ShuihuDB")
end
if not Game.shuihuCom then
	Game.shuihuCom = require_ex("games.shuihu.models.ShuihuCom")
end
Game.shuihuCom:reset()

--[[ 注册入口函数 ]]--
Game:registerAPI("game", "shuihu", function()
	Game.shuihuCom:onEnter()
end)

--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
   	
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.shuihu)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
	{slg_cmd.shuihu.shz_leave[1],handlerSafe(Game.shuihuCom,Game.shuihuCom.onExitGame)},
	{slg_cmd.shuihu.shz_debug[1],handlerSafe(Game.shuihuCom,Game.shuihuCom.onDebugInfo)}
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or ShuihuUtilTest then
    Game.shuihuDB:testDataMonitor()
end