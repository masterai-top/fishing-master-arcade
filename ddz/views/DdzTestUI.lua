local UIBase = require_ex("ui.base.UIbase")
local M = class("DdzTestUI", UIBase)
local SPAN = 50
local pokeData = 
{
	310,410,510,610,710,810,910,1010,1110,1210,1310,1410,1610,
	320,420,520,620,720,820,920,1020,1120,1220,1320,1420,1620,
	330,430,530,630,730,830,930,1030,1130,1230,1330,1430,1630,
	340,440,540,640,740,840,940,1040,1140,1240,1340,1440,1640,
	2100,2200
}

function M:ctor()
	UIBase.ctor(self)
	self:init()
end

function M:init()
	self._BindWidget = {
		["pan_touch"] = {handle = handlerSafe(self, self.onTouchBg)},

		["pan_select"] = {},
		["pan_select/card_1"] = {key = "temp_card", hide = true},

		["pan_other"] = {},
		["pan_other/btn_ok"] = {handle=handlerSafe(self, self.onSure)},
		["pan_other/btn_clear_go"] = {handle=handlerSafe(self, self.onClearGo)},
		["pan_other/btn_exit"] = {handle=handlerSafe(self, self.onClose)},
		["pan_other/btn_clear_hand"] = {handle=handlerSafe(self, self.onClearHand)},
		["pan_other/btn_deal"] = {handle=handlerSafe(self, self.onRandomDealPoke)},

		["pan_my"] = {},
		["pan_my/btn_test"] = {handle = handlerSafe(self, self.onTest)},
		["pan_my/btn_next"] = {handle = handlerSafe(self, self.onNext)},
	}
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/ddz/ddz_test.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._stage = 0
    self._curX = 0
    self._otherPoke = {}
    self._myPoke = {}
    self._map = {}
    self._curIdx = 0
    self._allSelect = {}
    self:showPoke()
    self._widgets.pan_my:addTouchEventListener(handlerSafe(self, self.onTouchHandPoke))
end

function M:onTouchBg()
	self:unselectPokes()
end

function M:onTouchHandPoke(sender, eventType)
	local localPos
	if eventType == ccui.TouchEventType.began then
		local pt = sender:getTouchBeganPosition()
        localPos = sender:convertToNodeSpace(pt)
        self._beginPos = localPos

	elseif eventType == ccui.TouchEventType.moved then
		local pt = sender:getTouchMovePosition()
        localPos = sender:convertToNodeSpace(pt)

	elseif eventType == ccui.TouchEventType.ended
	or eventType == ccui.TouchEventType.canceled then
		local pt = sender:getTouchEndPosition()
        localPos = sender:convertToNodeSpace(pt)
	end

	local selectIdx = self:checkSelectPokes(localPos)

	if eventType == ccui.TouchEventType.ended
		or eventType == ccui.TouchEventType.canceled then
		for k, _ in pairs(selectIdx) do
			self._myPoke[k]:setColor(cc.c3b(255, 255, 255))
		end
		-- 判断之前有没提起的牌，如有 现在选中的牌全部提起
		local checkHaveSel = false
		for _, poke in ipairs(self._myPoke) do
			if poke:isSelected() then
				checkHaveSel = true
				break
			end
		end

		if checkHaveSel then
			for k, _ in pairs(selectIdx) do
				if self._myPoke[k]:isSelected() then
					self._myPoke[k]:setSelected(false)
				else
					self._myPoke[k]:setSelected(true)
				end
			end
		else
			-- 这里需要做个顺子的判断
			local pokeData, map = {}, {}
			local count,value = 1
			for k, _ in pairs(selectIdx) do
				value = self._myPoke[k]:getClientCardValue()
				table.insert(pokeData, value)
				map[count] = k
				count = count + 1
			end
			
			local ret1 = Game.ddzRule:findSequenceFromPokes(pokeData)
			local ret2 = Game.ddzRule:findLianduiFromPokes(pokeData)
			local ret3 = Game.ddzRule:findFeijiFromPokes(pokeData)

			local ret
			if #ret1>#ret2/2 and #ret1>#ret3 then
				ret = ret1
			elseif #ret2/2>#ret1 and #ret2/2>#ret3 then
				ret = ret2
			else
				ret = ret3
			end
			if Assist.isEmpty(ret) then
				for k, _ in pairs(selectIdx) do
					if self._myPoke[k]:isSelected() then
						self._myPoke[k]:setSelected(false)
					else
						self._myPoke[k]:setSelected(true)
					end
				end
			else
				self:unselectPokes()
				for _, v in ipairs(ret) do 
					local idx = map[v]
					self._myPoke[idx]:setSelected(true)
				end
			end
		end
	end
end

-- 根据滑动位置选牌
function M:checkSelectPokes(localPos)
	local selectIdx = {}
	local maxX = Number.max(localPos.x, self._beginPos.x)
    local minX = Number.min(localPos.x, self._beginPos.x)
    local maxY = Number.max(localPos.y, self._beginPos.y)
	for k, poke in ipairs(self._myPoke) do
		local rect = poke:getBoundingBox()

		if maxY<=rect.y+rect.height then
			local pokeRectMinX = rect.x
	        local pokeRectMaxX = rect.x + SPAN
	        if (pokeRectMinX >= minX and pokeRectMinX <= maxX)
	            or (pokeRectMaxX >= minX and pokeRectMaxX <= maxX) then
	            selectIdx[k] = true
	        end
	    end

		if k~=1 then
			rect.width = SPAN
		end
		if cc.rectContainsPoint(rect, localPos) then
			selectIdx[k] = true
		end
		if selectIdx[k] == nil then
			poke:setColor(cc.c3b(255, 255, 255))
		else
			poke:setColor(cc.c3b(159, 168, 176))
		end
	end
	return selectIdx
end

function M:showPoke()
	local temp_card, card = self._widgets.temp_card
	local x, y, gapX, gapY = 48, 170, 90, -50
	for k, v in ipairs(pokeData) do
		card = temp_card:clone()
		card:setVisible(true)
		self:handleCardItem(card, v)
		self._widgets.pan_select:addChild(card)
		card:setPosition(cc.p(x,y))
		bindClickFunc(card, handlerSafe(self, self.onSelectPokeTouch))
		if k%13 == 0 then
			y = y + gapY
			x = 48
		else
			x = x + gapX
		end
	end
end

function M:handleCardItem(cardItem, card_v)
	cardItem:setTag(card_v)
	local img_size = cardItem:getChildByName("img_size")
	local img_color = cardItem:getChildByName("img_color")
	local img_small_joker = cardItem:getChildByName("img_small_joker")
	local img_big_joker = cardItem:getChildByName("img_big_joker")
	local value = Number.floor(card_v/100)
	local color = Number.floor(card_v/10) - value*10

	fitIconSize(img_color, DdzPokeConfig.res(color))
	if value == 21 then
		img_small_joker:setVisible(true)
		img_big_joker:setVisible(false)
		img_size:setVisible(false)
		img_color:setVisible(false)
	elseif value == 22 then
		img_big_joker:setVisible(true)
		img_small_joker:setVisible(false)
		img_size:setVisible(false)
		img_color:setVisible(false)
	else
		local idx = value*10 + color
		fitIconSize(img_size, DdzPokeConfig.res(idx))
		img_small_joker:setVisible(false)
		img_big_joker:setVisible(false)
		img_color:setVisible(true)
		img_size:setVisible(true)
	end
end

function M:onSelectPokeTouch(sender)
	local tag = sender:getTag()
	if self._map[tag] == nil then
		self._map[tag] = true
	else
		return
	end
	if self._stage == 1 then
		local poke = Game.ddzDB:getCardFromPool(tag, self._widgets.pan_other)
		table.insert(self._otherPoke, poke)
		poke:setScale(0.66)
		poke:setPosition(self._curX,0)

		self._curX = self._curX + SPAN
		local valueTb = {}
		for _, v in ipairs(self._otherPoke) do
			table.insert(valueTb, v:getSvrCardValue())
		end
		table.sort(valueTb, function(a,b)return a>b end)
		for k, v in ipairs(valueTb) do
			self._otherPoke[k]:setLocalZOrder(k)
			self._otherPoke[k]:changeValue(v)
		end
	else
		local poke = Game.ddzDB:getCardFromPool(tag, self._widgets.pan_my)
		table.insert(self._myPoke, 1, poke)
		poke:setPosition(self._curX,0)
		self._curX = self._curX + SPAN
		local valueTb = {}
		for _, v in ipairs(self._myPoke) do
			table.insert(valueTb, v:getSvrCardValue())
		end
		table.sort(valueTb)
		for k, v in ipairs(valueTb) do
			self._myPoke[k]:setLocalZOrder(1000-k)
			self._myPoke[k]:changeValue(v)
		end
	end
end

function M:onSure()
	self._stage = 1
	self._curX = 0
end

function M:onClearHand()
	self._stage = 0
	self._curX = 0
	self._curIdx = 0

	for _, v in ipairs(self._myPoke) do
		Game.ddzDB:pushCardPool(v)
		local card_v = v:getSvrCardValue()
		self._map[card_v] = nil
	end
	self._myPoke = {}
end

function M:onRandomDealPoke()
	self:onClearHand()
	local data = {}
	for _, v in ipairs(pokeData) do
		if self._map[v] == nil then
			table.insert(data, v)
		end
	end
	local ret = {}
	for i=1, 17 do
		local randomIdx = Number.random(i,#data)
		data[i], data[randomIdx] = data[randomIdx], data[i]
		table.insert(ret, data[i])
	end
	table.sort(ret, function(a,b)return a>b end)
	for k, v in ipairs(ret) do
		self._map[v] = true
		local poke = Game.ddzDB:getCardFromPool(v, self._widgets.pan_my)
		table.insert(self._myPoke, 1, poke)
		poke:setPosition(self._curX,0)
		poke:setLocalZOrder(k)
		self._curX = self._curX + SPAN
	end
	self:onSure()
end

function M:onClearGo()
	for _, v in ipairs(self._otherPoke) do
		local card_v = v:getSvrCardValue()
		self._map[card_v] = nil
		Game.ddzDB:pushCardPool(v)
	end
	self._otherPoke = {}

	self._stage = 1
	self._curX = 0
	self._curIdx = 0
	self:unselectPokes()
end

function M:onTest()
	local otherData = {}
	local myData = {}
	for _, v in ipairs(self._otherPoke) do
		table.insert(otherData, v:getClientCardValue())
	end
	for _, v in ipairs(self._myPoke) do
		table.insert(myData, v:getClientCardValue())
	end

	self:unselectPokes()
	Game.ddzRule:autoSelectPoke(myData, otherData)
	self._allSelect = Game.ddzRule:getAllSelect()
	if not Assist.isEmpty(self._allSelect) then
		self._curIdx = 1
		local way = self._allSelect[1]
		for _, v in ipairs(way) do
			self._myPoke[v]:setSelected(true)
		end
	end
	Game.ddzRule:printPokeCombo(myData)
end

function M:unselectPokes()
	for _, poke in ipairs(self._myPoke) do
		if poke:isSelected() then
			poke:setSelected(false)
		end
	end
end

function M:onClose()
	self:onClearHand()
	self:onClearGo()
	self:destroy()
end

function M:onNext()
	self:unselectPokes()
	local len = #self._allSelect
	if len>0 then
		self._curIdx = self._curIdx + 1
		if self._curIdx > len then
			self._curIdx = self._curIdx - len
		end
		local way = self._allSelect[self._curIdx]
		for _, v in ipairs(way) do
			self._myPoke[v]:setSelected(true)
		end
	end
end

return M