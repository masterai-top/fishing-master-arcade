
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnRuleUI", UIBase)

function M:ctor()
	self.funcKey = "BrnnRuleUI"
    self.effDark = true
    self.effRipple = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["btn_1"] = {handle=handlerSafe(self,self.onNormalRule)},
        ["btn_2"] = {handle=handlerSafe(self,self.onSpecialRule)},
        ["panel_center/ScrollView_rule_1"] = {key="rule_1"},
        ["panel_center/ScrollView_rule_2"] = {key="rule_2"},
        ["panel_center/btn_close"] = {handle=handlerSafe(self,self.onClose)},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_rule.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._widgets.btn_1:setEnabled(false)
    local txt_normal = self._widgets.btn_1:getChildByName("txt_normal")
    local txt_disabled = self._widgets.btn_1:getChildByName("txt_disabled")
    txt_normal:setVisible(false)
    txt_disabled:setVisible(true) 
    self._widgets.rule_1:setVisible(true)
    self._widgets.rule_2:setVisible(false)
    if AppName == "qgame" then
        self._widgets.btn_2:setVisible(false)
    end
end

function M:onNormalRule(sender)
    sender:setEnabled(false)
    local txt_normal = sender:getChildByName("txt_normal")
    local txt_disabled = sender:getChildByName("txt_disabled")
    txt_normal:setVisible(false)
    txt_disabled:setVisible(true)
    self._widgets.btn_2:setEnabled(true)
    txt_normal = self._widgets.btn_2:getChildByName("txt_normal")
    txt_disabled = self._widgets.btn_2:getChildByName("txt_disabled")
    txt_normal:setVisible(true)
    txt_disabled:setVisible(false)
    self._widgets.rule_1:setVisible(true)
    self._widgets.rule_2:setVisible(false)
end

function M:onSpecialRule(sender)
    sender:setEnabled(false)
    local txt_normal = sender:getChildByName("txt_normal")
    local txt_disabled = sender:getChildByName("txt_disabled")
    txt_normal:setVisible(false)
    txt_disabled:setVisible(true)
    self._widgets.btn_1:setEnabled(true)
    txt_normal = self._widgets.btn_1:getChildByName("txt_normal")
    txt_disabled = self._widgets.btn_1:getChildByName("txt_disabled")
    txt_normal:setVisible(true)
    txt_disabled:setVisible(false)
    self._widgets.rule_1:setVisible(false)
    self._widgets.rule_2:setVisible(true)
    if Game.brnnDB:isBulletRoom() then
        local panel = self._widgets.rule_2:getChildByName("Panel_t")
        panel:getChildByName("Image_9_0"):setVisible(false)
    end
end

return M