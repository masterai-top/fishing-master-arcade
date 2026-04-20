local UIBase = require_ex("ui.base.UIBase")
local M = class("ShuihuSetUI",UIBase)

function M:ctor()
	self.effDark = true
	self.effRipple = true
	UIBase.ctor(self)
	self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
		["bg/pan_sound/img_sound_on"] = {key="img_sound_on",tag=1,handle=handlerSafe(self,self.onSoundSwitch)},
		["bg/pan_sound/img_sound_off"] = {key="img_sound_off",tag=2,handle=handlerSafe(self,self.onSoundSwitch)},
	}
	self:initViews()
end


function M:initViews()
	local uiNode = createCsbNode("subgame/shuihu/shuihu_set.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode
    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self:showView()
end

function M:showView()
    local sound = Game.setDB:getEffectsVolume()
    if sound > 0 then
    	self._widgets.img_sound_on:setVisible(true)
    	self._widgets.img_sound_off:setVisible(false)
    else
    	self._widgets.img_sound_on:setVisible(false)
    	self._widgets.img_sound_off:setVisible(true)
    end
end

function M:onSoundSwitch(sender)
	local tag = sender:getTag()
	if tag == 1 then --关闭
		Game.setDB:setEffectsVolume(0)
		--有音效用到底层接口，需手动关闭
		Game.shuihuDB:releaseSoundHandle()
		self._widgets.img_sound_off:setVisible(true)
		self._widgets.img_sound_on:setVisible(false)
	else
		Game.setDB:setEffectsVolume(1)
		self._widgets.img_sound_off:setVisible(false)
		self._widgets.img_sound_on:setVisible(true)
	end
end

return M