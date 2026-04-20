local UIBase = require_ex("ui.base.UIBase")
local M = class("ShuihuRuleUI",UIBase)
local MAX_PAGE = 3

function M:ctor()
	self.effDark = true
	self.effRipple = true
	UIBase.ctor(self)
	self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
		["panel_center/btn_left"] = {key="btn_left"},
		["panel_center/btn_right"] = {key="btn_right"},
		["panel_center/PageView"] = {key="PageView"},
		["panel_center/pan_rule_1"] = {key="pan_rule_1",hide=true},
		["panel_center/pan_rule_2"] = {key="pan_rule_2",hide=true},
		["panel_center/pan_rule_3"] = {key="pan_rule_3",hide=true},
		["panel_center/img_line_rule"] = {key="img_line_rule"},
		["panel_center/img_bet_rule"] = {key="img_bet_rule"},
	}
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/shuihu/shuihu_rule.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
	self:showView()
end

function M:showView()
	local pan_rule_1 = self._widgets.pan_rule_1:clone()
	local pan_rule_2 = self._widgets.pan_rule_2:clone()
	local pan_rule_3 = self._widgets.pan_rule_3:clone()
	local pageView = self._widgets.PageView
	pageView:removeAllItems()
	pageView:addPage(pan_rule_1)
	pageView:addPage(pan_rule_2)
	pageView:addPage(pan_rule_3)
	pan_rule_1:setVisible(true)
	pan_rule_2:setVisible(true)
	pan_rule_3:setVisible(true)
	local args = {
		leftBtn = self._widgets.btn_left,
		rightBtn = self._widgets.btn_right,
		turnCallback = handlerSafe(self,self.onChangePage),
		pageNum = MAX_PAGE,
	}
	self._newPageView = require_ex("lib.UIPageViewEx").new(pageView,args)
	self:onChangePage(0)
end

function M:onChangePage(idx)
	if MAX_PAGE-1 == idx then
		self._widgets.img_line_rule:setVisible(false)
		self._widgets.img_bet_rule:setVisible(true)
	else
		self._widgets.img_line_rule:setVisible(true)
		self._widgets.img_bet_rule:setVisible(false)
	end
end

return M