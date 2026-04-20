local M = class("cell")
local Actor = require_ex("ui.base.Actor")
local spineList = {
	[1]={res="subgame/shuihu/spine/futou/shz_fu",ani="1",isLoop=false},
	[2]={res="subgame/shuihu/spine/qiang/shz_qiang",ani="1",isLoop=false},
	[3]={res="subgame/shuihu/spine/dao/shz_dao",ani="1",isLoop=false},
	[4]={res="subgame/shuihu/spine/luzhishen/shz_lu",ani="1",isLoop=false},
	[5]={res="subgame/shuihu/spine/linchong/shz_lin",ani="1",isLoop=false},
	[6]={res="subgame/shuihu/spine/songjiang/shz_sj",ani="1",isLoop=false},
	[7]={res="subgame/shuihu/spine/titianxindao/shz_ttxd",ani="1",isLoop=false},
	[8]={res="subgame/shuihu/spine/zhongyitang/shz_zyt",ani="1",isLoop=false},
	[9]={res="subgame/shuihu/spine/long/shz_shz",ani="1",isLoop=false},
}

local DUR_ONE = 0.3

function M:ctor(ctrl)
	self._ctrl = ctrl
	self._idx = ctrl:getTag() 		--索引值
	self:init()
end

function M:init()
	self:initData()
	self:initViews()
end

function M:initData()
	self._nodeSpine 	= self._ctrl:getChildByName("node_spine")
	self._imgIcon 		= self._ctrl:getChildByName("img_icon")
	self._lapaFrom 		= 1
	self._lapaTo		= 1
end

function M:initViews()
	
end

--中奖图标播放动画
function M:playAnim(idx,loop)
	if self._nodeSpine.__actor then
		self._nodeSpine.__actor:removeFromParent()
	end
	local spine = spineList[idx]
	loop = loop or false
	spine.isLoop = loop
	local actor = Actor:new(spine.res,spine)
	self._nodeSpine:addChild(actor)
	self._nodeSpine.__actor = actor
	actor._actor:registerSpineEventHandler(function()
		if self._nodeSpine.__actor then
			self._nodeSpine.__actor:setVisible(false)
		end
	end,sp.EventType.ANIMATION_COMPLETE)
end

--更换图片
function M:setIconImage(idx,icon)
	local real_icon = icon or self._imgIcon
	local str = "subgame/shuihu/icon/game_shz_icon_"..idx..".png"
	fitIconSize(real_icon,str)
end

function M:setIconVisible(visible)
	self._imgIcon:setVisible(visible)
end

function M:clear()
	self._ctrl:stopAllActions()
	self:setGray(false)

	if self._nodeSpine.__actor then
		self._nodeSpine.__actor:removeFromParent()
		self._nodeSpine.__actor = nil
	end
end

function M:showScrollAni(delayTime)
	self._imgIcon:stopAllActions()
	local size = self._imgIcon:getContentSize()
	self._imgIcon:setPosition(cc.p(size.width/2,size.height/2))
	self._imgIcon:setVisible(false)
	self._imgIcon:moveVec2(cc.p(0,4))
	self._imgIcon:runAction(cc.Sequence:create(
		cc.DelayTime:create(checknumber(delayTime)),
		cc.Show:create(),
		cc.EaseExponentialOut:create(cc.MoveBy:create(0.1,cc.p(0,-8))),
		cc.EaseExponentialIn:create(cc.MoveBy:create(0.1,cc.p(0,4)))
	))
end

function M:showStartAni(cb)
	self._imgIcon:stopAllActions()
	local size = self._imgIcon:getContentSize()
	self._imgIcon:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.2,cc.p(0,-450)),
		cc.Hide:create(),
		cc.CallFunc:create(function(node)
			self:setIconVisible(false)
			local resultData = Game.shuihuDB:getResultData()
			self:setIconImage(resultData[self._idx])
			local size = self._imgIcon:getContentSize()
			self._imgIcon:setPosition(cc.p(size.width/2,size.height/2))
		end)
	))
end

function M:setGray(flag)
	self._imgIcon:setGray(flag)
end

return M