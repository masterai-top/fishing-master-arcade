local UIBase = require_ex("ui.base.UIBase")
local M = class("ShuihuRecordUI",UIBase)

function M:ctor()
	self.effDark = true
	self.effRipple = true
	UIBase.ctor(self)
	self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
		["panel_center/list"] = {key="list"},
		["temp_item"] = {key="temp_item",hide=true},
	}
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/shuihu/shuihu_record.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
	self:showView()
end

function M:showView()
	local recordData = Game.shuihuDB:getRecordData()
	local temp_item = self._widgets.temp_item
	local item
	if recordData then
		self._widgets.list:removeAllItems()
		for _,v in ipairs(recordData) do
			item = temp_item:clone()
			self:handleItem(item,v)
			self._widgets.list:pushBackCustomItem(item)
		end
	end
end

function M:handleItem(item,v)
	item:setVisible(true)
	local txt_name = item:getChildByName("txt_name")
	local txt_multiple = item:getChildByName("txt_multiple")
	local txt_score = item:getChildByName("txt_score")
	local txt_time = item:getChildByName("txt_time")
	txt_name:setString(String.toFixed(v.nick,8))
	Assist.checkTTF(txt_name)
	txt_multiple:setString(v.multiple)
	txt_score:setString(v.win)
	txt_time:setString(Timer:formatDateTime(v.tt,"/", false, true))
end

return M