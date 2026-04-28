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
	Game:doPluginAPI("update","subgame",self._funcId,handler(self,self.onEnterSuccess))
end

-------------------------------------------------------------
-- @override
--[[
初始化
]]
function M:init()
	self._version 	= "2.21.00"
	self._csb		= ""
end

--[[
进入成功回调
]]
function M:onEnterSuccess()
	local initLua = string.format("games.%s.models.%sInit", self._funcKey, string.ucfirst(self._funcKey))
	require_ex(initLua)
	Game:doPluginAPI("game", self._funcKey)
end

return M
