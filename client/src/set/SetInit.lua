--[[
设置入口文件
]]

local SetUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--
-- if not SetConfig then loadConfig("SetConfig") end
require_ex "ui.set.SetProtocol"

--[[ 创建类全局DB和Com对象 ]]--
Game.setDB = require_ex("ui.set.SetDB")
Game.setCom = require_ex("ui.set.SetCom")

--[[ 注册入口函数 ]]--
Game:registerAPI("enter", "set", function()
    require_ex("ui.set.SetUI").new():addToScene()
end)

--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
    {"open",		"webview",		handler(Game.setCom, Game.setCom.openWebView)},
    {"set",			"volume",		handler(Game.setDB, Game.setDB.setVolume)},
    {"get",			"volume",		handler(Game.setDB, Game.setDB.getVolume)},
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.set)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
	-- {slg_cmd.set.getData[1],		handler(Game.setCom, Game.setCom.onGetData)}
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
	-- function()
    --     Game.setCom:queryData(handler(Game, Game.prepareNext))
    -- end,
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or SetUtilTest then
     Game.setDB:testDataMonitor()
end