--[[
押注开奖类型游戏管理类
]]

local M = class("BetManager")

local schedulerIns = cc.Director:getInstance():getScheduler()

-- 游戏状态
BetState = {
    waitbet = 1,    -- 等待下注
    betting = 2,    -- 下注
    waitlot = 3,    -- 等待摇奖
    lottery = 4,    -- 摇奖（过程展示）
    reward  = 5,    -- 奖励
}
cc.exports.BetStateStr = {
    [BetState.waitbet] = "anim_title_banker_wait",
    [BetState.betting] = "bet_start",
    [BetState.waitlot] = "anim_title_banker_wait",
    [BetState.lottery] = "yao_jiang",
    [BetState.reward]  = "jie_suan",
}

-- 添加全局事件
addGlobalEvent("BET", "STATE_CHANGE")
addGlobalEvent("BET", "TIME_CHANGE")

function M:ctor()
    self:init()
end

function M:init()
    self._driver = 0 -- 驱动方式 [0 服务端驱动 1 Mng驱动 2 表现层驱动]
    self._stateIdx = 1
    self._state = 0
    -- 倒计时 (-1表示不使用倒计时)
    self._timeCounter = {-1,-1,-1,-1,-1}
    self._timeLeft = nil
    self._timeInv = 1.0
    -- 执行状态列表 (状态可选可重，顺序可变)
    self._stateList = {1,2,3,4,5}
end

--[[
设置游戏参数
@param params           table   参数列表
@param startImmediate   boolean 是否立即开始游戏循环
]]
function M:setParameters(params, startImmediate)
    if params.stateList then
        self._stateList = params.stateList
    end
    if params.timeCounter then
        for k,v in pairs(params.timeCounter) do
            self._timeCounter[self._stateList[k]] = v
        end
    end
    if params.timeLeft then
        self._timeLeft = params.timeLeft
    end
    if params.timeInv then
        self._timeInv = params.timeInv
    end
    if params.stateIdx then
        self._stateIdx = Number.max(1, params.stateIdx)
        self._state = self._stateList[self._stateIdx]
    end
    if params.driver then
        self._driver = params.driver
    end
    if startImmediate then
        self:betStart()
    end
end

--[[
下注筹码图标
@param chip     number  押注
@return string
]]
function getChipIcon(chip)
    if ChipIconConfig then
        return ChipIconConfig.icon(chip or 100)
    end
end

---------------------------------------
-- 游戏流程（逻辑）
function M:betStart()
    self:setState(self._stateList[self._stateIdx])
end

function M:betStop()
    if self._schedulerTC then
        schedulerIns:unscheduleScriptEntry(self._schedulerTC)
        self._schedulerTC = nil
    end
    self:init()
end

function M:betPause()
    
end

function M:betResume()
    
end

function M:updateTime(dt)
    self._timeLeft = Number.max(0, checknumber(self._timeLeft) - dt)

    Game:dispatchCustomEvent(GEvent("BET", "TIME_CHANGE"), {state=self._state, timeleft=self._timeLeft})

    if self._timeLeft == 0 and self._driver == 1 then
        self._timeLeft = 0
        self._stateIdx = self._stateIdx + 1
        if self._stateIdx > #self._stateList then
            self._stateIdx = 1
        end
        self:changeState(self._stateList[self._stateIdx])
    end
end

---------------------------------------
-- 游戏信息
function M:getTimeLeft()
    return checknumber(self._timeLeft)
end

function M:setTimeLeft(left)
    self._timeLeft = left
end

function M:getDriver()
    return self._driver
end

function M:setDriver(driver)
    self._driver = driver
end

---------------------------------------
-- 游戏状态
function M:getState(state)
    return self._state
end
function M:getStateByIdx(index)
    return self._stateList[index]
end
function M:setState(state)
    self:changeState(state, true, true)
end

function M:preState(unschedule)
    if unschedule and self._schedulerTC then
        schedulerIns:unscheduleScriptEntry(self._schedulerTC)
        self._schedulerTC = nil
    end
    self._stateIdx = self._stateIdx - 1
    if self._stateIdx < 1 then
        self._stateIdx = #self._stateList
    end
    self:changeState(self._stateList[self._stateIdx])
end

function M:nextState(unschedule)
    if unschedule and self._schedulerTC then
        schedulerIns:unscheduleScriptEntry(self._schedulerTC)
        self._schedulerTC = nil
    end
    self._stateIdx = self._stateIdx + 1
    if self._stateIdx > #self._stateList then
        self._stateIdx = 1
    end
    self:changeState(self._stateList[self._stateIdx])
end

--[[
通过状态索引改变状态
@see changeState
@param stateIdx         number  状态索引
@param force            boolean 强制切换状态
@param ignoreResetTime  boolean 不重置倒计时
]]
function M:changeStateIdx(stateIdx, force, ignoreResetTime)
    if self._stateList[stateIdx] then
        if force or self._state ~= self._stateList[stateIdx] then
            self._stateIdx = stateIdx
        end
        self:changeState(self._stateList[stateIdx], force, ignoreResetTime)
    end
end

--[[
改变状态
强制改变状态或者当前状态不是目标状态时才执行
@param state            number  状态
@param force            boolean 强制切换状态
@param ignoreResetTime  boolean 不重置倒计时
]]
function M:changeState(state, force, ignoreResetTime)
    if force or self._state ~= state then
        if self._schedulerTC then
            schedulerIns:unscheduleScriptEntry(self._schedulerTC)
            self._schedulerTC = nil
        end
        self._state = state
        if type(ignoreResetTime) == "number" then
            self._timeLeft = ignoreResetTime
        elseif not ignoreResetTime or not self._timeLeft then
            self._timeLeft = self._timeCounter[self._state]
        end
        Game:dispatchCustomEvent(GEvent("BET", "STATE_CHANGE"), {state=self._state, timeleft=self._timeLeft})
        if self._timeLeft == -1 and self._schedulerTC then
            schedulerIns:unscheduleScriptEntry(self._schedulerTC)
            self._schedulerTC = nil
        elseif not self._schedulerTC then
            Game:dispatchCustomEvent(GEvent("BET", "TIME_CHANGE"), {state=self._state, timeleft=self._timeLeft})
            self._schedulerTC = schedulerIns:scheduleScriptFunc(handler(self, self.updateTime), self._timeInv, false)
        end
    end
end

---------------------------------------
--[[
获取指定状态的持续时长（剩余时长）
@param state        number      状态
@param timestamp    number/nil  剩余时长
@return 持续时长（剩余时长）
]]
function M:getStateDuration(state, timestamp)
    local dur = self._timeCounter[state]
    if timestamp then
        local curTime = Timer:getCurTimeStamp()
        dur = Number.min(dur, Number.floor(timestamp - curTime))
        self._timeLeft = Number.min(self._timeLeft, dur)
        if dur < 12 then
            dur = self._timeCounter[state]
        end
    end
    return dur, self._timeLeft
end

return M:new()
