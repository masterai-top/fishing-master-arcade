--[[
登录入口文件
]]

local LoginUtilTest = false

--[[ 加载相关配置表和协议文件 ]]--
if (DEVELOP_MODE or CHEAT_TOKEN) and not ServerDevConfig then loadConfig("ServerDevConfig") end
require_ex "ui.login.LoginProtocol"

--[[ 创建类全局DB和Com对象 ]]--
Game.loginDB = require_ex("ui.login.LoginDB")
Game.loginCom = require_ex("ui.login.LoginCom")

--[[ 注册入口函数 ]]--
Game:registerAPI("enter", "login", function()
    
end)

--[[ 注册相关API,方便其他模块调用 ]]--
local apiList = {
    {"login",       "visitor",      handler(Game.loginCom, Game.loginCom.onVisitorLogin)},
    {"get",         "account",      handler(Game.loginDB, Game.loginDB.getAccount)},
    {"get",         "visitor",      handler(Game.loginDB, Game.loginDB.getVisitor)},
    {"upgrade",     "account",      handler(Game.loginCom, Game.loginCom.doBindMobile)},
    {"notice",      "update",       handler(Game.loginCom, Game.loginCom.openNotice)},
    {"notice",      "agreement",    handler(Game.loginCom, Game.loginCom.openAgreement)},
    {"check",       "kicked",       handler(Game.loginDB, Game.loginDB.getKicked)},

    {"set",         "shareUrl",     handler(Game.loginDB, Game.loginDB.setShareUrl)},
    {"get",         "shareUrl",     handler(Game.loginDB, Game.loginDB.getShareUrl)},
    {"set",         "shareIcon",    handler(Game.loginDB, Game.loginDB.setShareIcon)},
    {"get",         "shareIcon",    handler(Game.loginDB, Game.loginDB.getShareIcon)},
    {"get",         "shareImg",     handler(Game.loginDB, Game.loginDB.getShareImg)},
    
    {"set",         "loginInfo",    handler(Game.loginDB, Game.loginDB.setLoginInfo)},
    {"set",         "loginUid",     handler(Game.loginDB, Game.loginDB.setUid)},
    {"get",         "loginUid",     handler(Game.loginDB, Game.loginDB.getUid)},
    {"set",         "account",      handler(Game.loginDB, Game.loginDB.setAccount)},
    {"set",         "loginSign",    handler(Game.loginDB, Game.loginDB.setLoginSign)},
    {"set",         "nickName",     handler(Game.loginDB, Game.loginDB.setNickname)},
    {"set",         "headURL",      handler(Game.loginDB, Game.loginDB.setHeadUrl)},
    {"get",         "headURL",      handler(Game.loginDB, Game.loginDB.getHeadUrl)},

    {"login",       "out",          handler(Game.loginCom, Game.loginCom.onLogout)},
    {"login",       "sdk",          handler(Game.loginCom, Game.loginCom.onWakeupSDK)},
}
Game:registerAPIList(apiList)

--[[ 注册协议收包对应的解析表key ]]--
Game:registerParsePack(slg_cmd.login)

--[[ 注册协议收包对应的解析函数 ]]--
local pushCallbackList = {
    {slg_cmd.login.logout[1],       handler(Game.loginCom, Game.loginCom.onKickOut)},
    {slg_cmd.login.upkeepTips[1],   handler(Game.loginCom, Game.loginCom.onUpkeepTips)}
}
Game:registerPushMsg(pushCallbackList)

--[[ 注册进入大厅前需要执行的函数(获取相关数据) ]]--
local prepareList = {
    -- function()
    --     Game.loginCom:queryData(handler(Game, Game.prepareNext))
    -- end,
}
Game:registerPrepareList(prepareList)

--[[ 单机模式生成测试数据 ]]--
if DEBUG_OFFLINE or LoginUtilTest then
    Game.loginDB:testDataMonitor()
end