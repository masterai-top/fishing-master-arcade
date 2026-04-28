local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnSettingUI", UIBase)

function M:ctor()
	self.funcKey = "BrnnSettingUI"
    self.effDark = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/btn_close"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/txt_music/btn_selected"] = {key="btn_music_selected",tag=1,handle=handlerSafe(self,self.onMusic)},
        ["bg/txt_music/btn_unselected"] = {key="btn_music_unselected",tag=2,handle=handlerSafe(self,self.onMusic)},
        ["bg/txt_sound/btn_selected"] = {key="btn_sound_selected",tag=1,handle=handlerSafe(self,self.onSound)},
        ["bg/txt_sound/btn_unselected"] = {key="btn_sound_unselected",tag=2,handle=handlerSafe(self,self.onSound)},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_setting.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    local volume = Game.setDB:getVolume()
    if volume > 0 then
    	self._widgets.btn_music_selected:setVisible(true)
    	self._widgets.btn_music_unselected:setVisible(false)
    else
    	self._widgets.btn_music_selected:setVisible(false)
    	self._widgets.btn_music_unselected:setVisible(true)
    end

    local sound = Game.setDB:getEffectsVolume()
    if sound > 0 then
    	self._widgets.btn_sound_selected:setVisible(true)
    	self._widgets.btn_sound_unselected:setVisible(false)
    else
    	self._widgets.btn_sound_selected:setVisible(false)
    	self._widgets.btn_sound_unselected:setVisible(true)
    end
end

function M:onMusic(sender)
	sender:setVisible(false)
	local tag = sender:getTag()
	if tag == 1 then  --禁音
		Game.setDB:setVolume(0)
		self._widgets.btn_music_unselected:setVisible(true)
	else
		Game.setDB:setVolume(1)
		self._widgets.btn_music_selected:setVisible(true)
	end
end

function M:onSound(sender)
	sender:setVisible(false)
	local tag = sender:getTag()
	if tag == 1 then
		Game.setDB:setEffectsVolume(0)
		self._widgets.btn_sound_unselected:setVisible(true)
	else
		Game.setDB:setEffectsVolume(1)
		self._widgets.btn_sound_selected:setVisible(true)
	end
end

return M