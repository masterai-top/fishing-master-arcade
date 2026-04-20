--[[
线对象集合
]]

local M = class("Line")

function M:ctor(_, lobby, ctrl)
    self._lobby = lobby
    self._controller = ctrl
    
    self:init()
end

function M:init( )

end


function M:setId(id)
    self._id = id
end

function M:getId()
    return self._id or 1
end

function M:getLine()
    return self._controller
end

function M:show( )
	self._controller:setVisible(true)
end

function M:hide( )
	self._controller:setVisible(false)
end

function M:runAnim()
    local seq = {
		cc.Show:create(),
		cc.DelayTime:create(0.5),
		cc.Hide:create(),
		cc.CallFunc:create(function()
			if self.line then
				self.line:setVisible(false)
			end
		end)
	} 
    self._controller:runAction(transition.sequence(seq))  
end


return M