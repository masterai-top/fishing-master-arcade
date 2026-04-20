--[[ 
shuihu相关逻辑（交互和响应） 
]]

local M = class("ShuihuCom")

local _TAG = "shuihu"

-- 添加全局事件
addGlobalEvent(_TAG, "START_SCROLL")
addGlobalEvent(_TAG, "KickOut_shz")
addGlobalEvent(_TAG, "TURN_FAILURE")
addGlobalEvent(_TAG, "LAPA_END_EVENT")
addGlobalEvent(_TAG, "DEBUG_INFO")

function M:ctor()
    self:init()
end

function M:init()
    netCom.ignoreWaitTipCMD(slg_cmd.shuihu.shz_leave[1])
end

function M:onEnter()
	if DEBUG_OFFLINE then
        self:onEnterGame()
        return
    end

	netCom.send({}, slg_cmd.shuihu.shz_enter[1], function(pack, info)
        if checknumber(info.ret) == 0 then
            self:onEnterGame()
        else
            Game:enterScene(ENUM.SCENCE.PLATFORM)
            Game:tipError(info.ret)
        end
		
    end,function()
        Game:enterScene(ENUM.SCENCE.PLATFORM)
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
    end)
end

function M:onEnterGame()
    local ui = require_ex("games.shuihu.view.ShuihuMainUI").new()
    ui:addToScene()
end

function M:reqExitGame()
    if DEBUG_OFFLINE then 
        Game:dispatchCustomEvent(GEvent(_TAG,"KickOut_shz"),0)
        self:reset()
        return
    end
    netCom.send({},slg_cmd.shuihu.shz_leave[1],function(pack,info)

        end,function()
        Game:dispatchCustomEvent(GEvent(_TAG,"KickOut_shz"),0)
        self:reset() 
    end)
end

function M:onExitGame(pack,info)
    dump(info,"onExitGame")
    if checknumber(info.ret) >= 0 then
        Game:dispatchCustomEvent(GEvent(_TAG,"KickOut_shz"),info.ret)
        self:reset() 
    end
end

function M:reqResultData(bet_num)
    if DEBUG_OFFLINE then
        return
    end
    netCom.send({bet_num},slg_cmd.shuihu.shz_result[1],function(pack,info)
        dump(info,"reqResultData")
        if info.ret == 0 then
            Game.shuihuDB:setWinCount(info.win)
            Game.shuihuDB:setResultData(info.icon_list)
            Game.shuihuDB:setBigWin(info.big_win > 0)
            Game:dispatchCustomEvent(GEvent(_TAG, "START_SCROLL"), info)
        else
            Game:tipError(info.ret)
            Game:dispatchCustomEvent(GEvent(_TAG, "TURN_FAILURE"), info)  
        end
    end)
end

function M:reqRecordData(callback)
    if DEBUG_OFFLINE then
        return
    end
    netCom.send({},slg_cmd.shuihu.shz_rank[1],function(pack,info)
        dump(info,"reqRecordData")
        Game.shuihuDB:setRecordData(info.data)
        if callback then
            callback()
        end
    end)
end

function M:reset()
    self:init()
    Game.shuihuDB:init()
end

function M:onDebugInfo(_,info)
    dump(info)
    Game.shuihuDB:setDebugInfo(info.data)
    Game:dispatchCustomEvent(GEvent(_TAG, "DEBUG_INFO"))
end
-----------------------界面接口-----------------------
function M:openRuleUI()
    local ui = require_ex("games.shuihu.view.ShuihuRuleUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

function M:openSetUI()
    local ui = require_ex("games.shuihu.view.ShuihuSetUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

function M:openRecordUI()
    local ui = require_ex("games.shuihu.view.ShuihuRecordUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

return M:new()
