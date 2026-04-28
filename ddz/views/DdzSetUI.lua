local UIBase = require_ex("ui.base.UIBase")
local M = class("DdzSetUI", UIBase)

function M:ctor()
	self.effDark = true
    self.effRipple = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle = handlerSafe(self, self.onClose)},
		["img_bg/btn_close"] = {handle = handlerSafe(self, self.onClose)},
		
		["img_bg/pan_music/img_on"] = {key = "img_music_on", tag = 1, handle = handlerSafe(self, self.onMusicSwitch)},
		["img_bg/pan_music/img_off"] = {key = "img_music_off", tag = 2, handle = handlerSafe(self, self.onMusicSwitch)},

		["img_bg/pan_sound/img_on"] = {key = "img_sound_on", tag = 1, handle = handlerSafe(self, self.onSoundSwitch)},
		["img_bg/pan_sound/img_off"] = {key = "img_sound_off", tag = 2, handle = handlerSafe(self, self.onSoundSwitch)},
	}
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/ddz/ddz_set.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    local volume = Game.setDB:getVolume()
    if volume > 0 then
    	self._widgets.img_music_on:setVisible(true)
    	self._widgets.img_music_off:setVisible(false)
    else
    	self._widgets.img_music_on:setVisible(false)
    	self._widgets.img_music_off:setVisible(true)
    end

    local sound = Game.setDB:getEffectsVolume()
    if sound > 0 then
    	self._widgets.img_sound_on:setVisible(true)
    	self._widgets.img_sound_off:setVisible(false)
    else
    	self._widgets.img_sound_on:setVisible(false)
    	self._widgets.img_sound_off:setVisible(true)
    end
end

function M:onMusicSwitch(sender)
	sender:setVisible(false)
	local tag = sender:getTag()
	if tag == 1 then  --禁音
		Game.setDB:setVolume(0)
		self._widgets.img_music_off:setVisible(true)
	else
		Game.setDB:setVolume(1)
		self._widgets.img_music_on:setVisible(true)
	end
end

function M:onSoundSwitch(sender)
	sender:setVisible(false)
	local tag = sender:getTag()
	if tag == 1 then
		Game.setDB:setEffectsVolume(0)
		self._widgets.img_sound_off:setVisible(true)
	else
		Game.setDB:setEffectsVolume(1)
		self._widgets.img_sound_on:setVisible(true)
	end
end

return M