--[[
押注游戏控制基类

uidelegate:
    onEnter()           -- onEnterCallback()    -- 进入房间
    onExit()            -- onExitCallback()     -- 退出房间
    onBet()             -- onBetCallback()      -- 押注
]]

local M = class("BetCom")

function M:ctor()
    self:init()
end

function M:init()
    
end

---------------------------------------
-- 流程控制
function M:onEnter()
    
end

function M:onExit()
    Game.betMng:betStop()
    self:reset()
end

function M:onBet()
    -- override
end

return M
