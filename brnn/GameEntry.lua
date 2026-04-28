--[[
子游戏入口，归属子游戏
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("GameEntry", UIBase)

function M:ctor(funcId)
	self._funcId = funcId or GAME_MAIN_ID
	self._funcKey = FuncListConfig.key(self._funcId)
	
	UIBase.ctor(self)
	self:init()
end

function M:onEnter()
	self.super.onEnter(self)
	Game:doPluginAPI("update","subgame",self._funcId,handlerSafe(self,self.onEnterSuccess))
end
function M:onExit()
	self.super.onExit(self)
end

-------------------------------------------------------------
-- @override
--[[
初始化
]]
function M:init()
	self._version 	= "2.21.30"
	self._csb		= ""
end

--[[
进入成功回调
]]
function M:onEnterSuccess()
	local func_id
	if Game.brnnDB then --在重置之前获取之前的func_id
		func_id = Game.brnnDB:getFuncId()
	end
	local initLua = string.format("games.%s.models.%sInit", self._funcKey, string.ucfirst(self._funcKey))
	require_ex(initLua)
	if Game.fieldId == 0 then
		Game:doPluginAPI("game", self._funcKey,self._funcId)
	elseif Game.fieldId == ENUM.GAME.BRNN then
		Game:doPluginAPI("game", self._funcKey,1055)
	else
		if func_id then
			Game:doPluginAPI("game", self._funcKey,func_id)
		end
	end
	Game.fieldId = nil
end

return M
