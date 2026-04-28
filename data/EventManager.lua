--[[
监听管理
]]

local M = class("EventManager")

local function _isEmpty(obj)
    if not obj then return true end
    local tObj = type(obj)
    if tObj == "string" and obj == "" then return true end
    if tObj == "number" and obj == 0 then return true end
    if tObj == "table" and table.nums(obj) == 0 then return true end
    if tObj == "userdata" and tolua.isnull(obj) then return true end
    return false
end

local function _getTargetKey(target)
    return string.upper(tostring(target))
end

function M:ctor()
    self:init()
end

function M:init()
    self._event = {}
end

--[[
添加监听
@param eventName    string      事件名
@param target       class       监听者
@param listener     function    回调函数
]]
function M:addEventListener(eventName, target, listener)
    if _isEmpty(eventName) or _isEmpty(target) or _isEmpty(listener) then return end
    eventName = string.upper(eventName)
    if not self._event[eventName] then
        self._event[eventName] = {}
    end
    local key = _getTargetKey(target)
    if not self._event[eventName][key] then
        self._event[eventName][key] = {target=target, listener={listener}}
    else
        table.insert(self._event[eventName][key].listener, listener)
    end
end

--[[
派发事件
@param eventName    string      事件名
@param eventData    object      派发数据
]]
function M:dispatchEvent(eventName, eventData)
    eventName = string.upper(eventName)
    if self._event[eventName] then
        for _, v in pairs(self._event[eventName]) do
            if not _isEmpty(v.target) then
                for _, listener in ipairs(v.listener) do
                    listener({name=eventName, data=eventData})
                end
            end
        end
    end
end

----------------------------------------
-- 事件管理
function M:hasEvent(eventName)
    eventName = string.upper(eventName)
    return self._event[eventName]
end

function M:removeEvent(eventName, target)
    eventName = string.upper(eventName)
    if not target then
        self._event[eventName] = nil
    elseif self._event[eventName] then
        local key = _getTargetKey(target)
        self._event[eventName][key] = nil
    end
end

function M:removeEventByName(eventName)
    eventName = string.upper(eventName)
    self._event[eventName] = nil
end

function M:removeEventByTarget(target)
    if _isEmpty(target) then return end
    local key = _getTargetKey(target)
    for _, v in pairs(self._event) do
        v[key] = nil
    end
end

function M:removeAllEvent()
    self._event = {}
end

return M:new()
