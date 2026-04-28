local M = class("DdzPoke", ccui.Layout)

local POKE_BG = "subgame/ddz/poke/game_ddz_poker_1.png"

local MASK_BG = "subgame/ddz/poke/game_ddz_poker_2.png"

local WIN_FLAG = "subgame/ddz/board/game_ddz_bg_9.png"

local WIDTH = 172
local HEIGHT = 218
local MOVE_Y = 26

function M:ctor()
	self:init()
end

function M:init()
	-- 默认初始化值
	self._clientCardValue = 0	-- 客户端牌值
	self._color = 1   			-- 花色 1->方块 2->梅花 3->红桃 4->黑桃
	self._svrCardValue = 0		-- 服务端牌值

	self._smallColorImg = nil	-- 小花色图
	self._bigColorImg = nil		-- 大花色图
	self._valueImg = nil		-- 牌值图
	self._maskImg = nil			-- 背面底图

	self._selected = false		-- 选中
	self._playAni = false

	self:setContentSize(cc.size(WIDTH,HEIGHT))
	self:setCascadeColorEnabled(true)
	self:setCascadeOpacityEnabled(true)
	self:setClippingEnabled(false)
	self:setBackGroundColorOpacity(102)
end

function M:changeValue(card_v)
	self._svrCardValue = card_v
	self._clientCardValue = Number.floor(card_v/100)
	self._color = Number.floor(card_v/10) - self._clientCardValue*10
	self:setBackGroundImage(POKE_BG, 1)
	if self._clientCardValue < 20 then
		if self._smallColorImg then
			fitIconSize(self._smallColorImg, DdzPokeConfig.res(self._color))
		else
			self._smallColorImg = ccui.ImageView:create(DdzPokeConfig.res(self._color),1):addTo(self)
			self._smallColorImg:setScale(0.3)
		end
		self._smallColorImg:setPosition(cc.p(28,144))
		self._smallColorImg:setVisible(true)

		if self._bigColorImg  then
			fitIconSize(self._bigColorImg, DdzPokeConfig.res(self._color))
		else
			self._bigColorImg = ccui.ImageView:create(DdzPokeConfig.res(self._color),1):addTo(self)
		end
		self._bigColorImg:setPosition(cc.p(114,64))

		local v = self._clientCardValue*10 + self._color
		local value_res = DdzPokeConfig.res(v)
		if self._valueImg then
			fitIconSize(self._valueImg, value_res)
		else
			self._valueImg = ccui.ImageView:create(value_res, 1):addTo(self)
		end
		self._valueImg:setPosition(cc.p(28, 184))
	else
		-- 大小王特殊处理
		if self._smallColorImg then
			self._smallColorImg:setVisible(false)
		end

		local colorMap = {[21]=5, [22]=6}
		if self._bigColorImg then
			fitIconSize(self._bigColorImg, DdzPokeConfig.res(colorMap[self._clientCardValue]))
		else
			self._bigColorImg = ccui.ImageView:create(DdzPokeConfig.res(colorMap[self._clientCardValue]), 1):addTo(self)
		end
		self._bigColorImg:setPosition(104,88)

		if self._valueImg then
			fitIconSize(self._valueImg, DdzPokeConfig.res(self._clientCardValue))
		else
			self._valueImg = ccui.ImageView:create(DdzPokeConfig.res(self._clientCardValue), 1):addTo(self)
		end
		self._valueImg:setPosition(25,109)
	end
end

function M:setSelected(selected)
	if not self._playAni then
		self._selected = selected
		if selected then
			self:moveVec2(cc.p(0, MOVE_Y))
		else
			self:moveVec2(cc.p(0, -MOVE_Y))
		end
	end
end

function M:isSelected()
	return self._selected
end

function M:unselected()
	if not self._playAni then
		if self:isSelected() then
			self:setSelected(false)
		end
	end
end

function M:reset()
	self._playAni = false
	self:unselected()
	self:hideWinFlag()
	self:hideMask()
	self:setAnchorPoint(cc.p(0, 0))
	self:setScale(1.0)
	self:setColor(cc.c3b(255, 255, 255))
end

function M:showWinFlag()
	if self._winFlag == nil then
		self._winFlag = ccui.ImageView:create(WIN_FLAG, 1):addTo(self)
		self._winFlag:setPosition(126,171)
	end
end

function M:hideWinFlag()
	if self._winFlag then
		self._winFlag:removeFromParent(true)
		self._winFlag = nil
	end
end

-- 设置值并翻转
function M:reverseCardValue(card_v)
	self:changeValue(card_v)
	if self._clientCardValue < 20 then
		self._smallColorImg:setPosition(144,144)
		self._valueImg:setPosition(144,184)
		self._valueImg:setFlippedX(true)
		self._bigColorImg:setPosition(60,64)
	else
		self._bigColorImg:setPosition(66,90)
		self._valueImg:setPosition(148,109)
		self._valueImg:setFlippedX(true)
	end
end

-- 显示背景牌
function M:showMask()
	if self._maskImg == nil then
		self._maskImg = ccui.ImageView:create(MASK_BG, 1):addTo(self, 100)
		self._maskImg:setPosition(WIDTH/2, HEIGHT/2)
	end
end

function M:hideMask()
	if self._maskImg then
		self._maskImg:removeFromParent(true)
		self._maskImg = nil
	end
end

-- 服务端原始值
function M:getSvrCardValue()
	return self._svrCardValue
end

-- 客户端解析值
function M:getClientCardValue()
	return self._clientCardValue
end

-- 
function M:playUnselectedAni()
	if self._selected then
		self._playAni = true
		local seq = {
			cc.MoveBy:create(0.5, cc.p(0, -MOVE_Y)),
			cc.CallFunc:create(function()
				self._selected = false
				self._playAni = false
			end)
		}
		self:runAction(transition.sequence(seq))
	end
end

return M