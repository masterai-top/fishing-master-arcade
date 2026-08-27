--[[ 
设置相关数据 
]]

local M = class("SetDB")

local KeyMusic = "volm"
local KeyEffect = "vole"
local KeyModel = "eff_model"

local EffModel = {
    SD = 1,
    HD = 2,
}

function M:ctor()
    self:init()
    -- Game:registerLogoutReset(self, handler(self, self.init))
end

function M:init()
    self._volume = Game.localDB:getFloatForKey(KeyMusic, 1)
    self._effectvolume = Game.localDB:getFloatForKey(KeyEffect, 1)
    self._effModel = Game.localDB:getIntegerForKey(KeyModel, 0)
    if self._effModel == 0 then
        if LOW_MACHINE then
            self._effModel = EffModel.SD
        else
            self._effModel = EffModel.HD
        end
        Game.localDB:setIntegerForKey(KeyModel, self._effModel)
    else
        LOW_MACHINE = (self._effModel==EffModel.SD)
    end

    self:setEffectsVolume(self._effectvolume)
    self:setVolume(self._volume, device.platform=="ios")

    self._redPoint = false
end

----------------------------------
-- 接口
function M:getEffectsVolume()
    return self._effectvolume
end

function M:setEffectsVolume(v)
    self._effectvolume = v
    Game.localDB:setFloatForKey(KeyEffect, v)
    Audio.setEffectVolume(v)
end

function M:getVolume()
    return self._volume
end

function M:setVolume(v, fakeSilent)
    self._volume = v
    Game.localDB:setFloatForKey(KeyMusic, v)
    if v == 0 and fakeSilent then
        v = 0.1
    end
    Audio.setMusicVolume(v)
end

function M:getEffModel()
    return self._effModel
end

function M:setEffModel(v)
    self._effModel = v
    Game.localDB:setIntegerForKey(KeyModel, v)
    LOW_MACHINE = (self._effModel==EffModel.SD)
end

----------------------------------
-- 红点
function M:setRedPoint(rp)
    if type(rp) == "boolean" then
        self._redPoint = rp
    else
        self._redPoint = false
    end
    Game:dispatchCustomEvent(GEvent("GAME_RED_POINT_EVENT"), {key="set", show=self._redPoint})
end

function M:getRedPoint()
    return self._redPoint
end

----------------------------------
-- 单机数据模拟
function M:testDataMonitor()
    
end

return M:new()
