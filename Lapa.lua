--[[
拉霸机对象集合
]]

local M = class("Lapa")

local DUR_ONE = 0.3
local DURATION = 2
--[[
对象
list:listview滑块
]]
function M:ctor(_,list,idx)
    self._list = list   --拉霸机滑块
    self._from = 0		--拉霸机的开始
    self._to = 0		--拉霸机的结果
    self._idx = idx 	--索引第几个拉霸机
    self._amount = self._list:getChildrenCount()
    self._runner = self._list:getInnerContainer()
    self._uint = self._list:getItem(0)
    self._unitSize = self._uint:getContentSize().height
    self._totalSize = self._unitSize * self._amount
    self._maxDur = DURATION
    self:init()
end

function M:init()
    self._widgets = {}
    self:initViews()
end

function M:initViews()
	local item
	for i=0,self._amount-1 do
		item = self._list:getItem(i)
		if i==self._amount-1 then
			self:buildItems(item,9)
		else
			self:buildItems(item)
		end
	end
	self._list:jumpToBottom()
end

function M:buildItems(item,idx)
    item:setVisible(true)
    local img_icon = nil
    for i=1,3 do
        local idx = idx or Number.random(1,9)
        img_icon = item:getChildByName("img_icon_"..i)
        self:setItemIcon(img_icon,idx)
    end
end

--设置拉霸机中的图片
function M:setItemIcon(img_icon,idx)
    fitIconSize(img_icon,luckLineConfig.icon(idx))
end

function M:run(rewardData,delayTime)
	if Assist.isEmpty(rewardData) then return end
	
    --随机获取中奖位置，装填数据
    local rewardIdx = Game.ShzDB:getRewardIdx()
    if rewardIdx == -1 then
        rewardIdx = Game.ShzDB:createRewardIdx(self._amount,self._to)
    end
	self._from = self._to
	self._to = rewardIdx
	local item = self._list:getItem(self._to)
	local idx = self._idx
	for i=1,3 do
        local img_icon = item:getChildByName("img_icon_"..i)
        self:setItemIcon(img_icon,rewardData[idx])
        idx = idx + 5
    end

    self:startAction(delayTime)
end

--开始抽奖滚动
function M:startAction(delayTime)
	local seq = {
        cc.Place:create(cc.p(0,0)),
        cc.EaseExponentialIn:create(cc.MoveTo:create(0.1, cc.p(0, -self._unitSize*2))),
    }
    local runTurn = Number.ceil(self._maxDur / DUR_ONE)
    for i = 1, runTurn do
        seq[#seq+1] = cc.MoveTo:create(DUR_ONE, cc.p(0, self._unitSize-self._totalSize))
        seq[#seq+1] = cc.Place:create(cc.p(0, 0))
    end
    seq[#seq+1] = cc.EaseExponentialOut:create(cc.MoveTo:create(0.2+checknumber(delayTime), cc.p(0, -self._unitSize*(self._amount-self._to-1))))
    seq[#seq+1] = cc.CallFunc:create(function()
            self:endCallback()
        end)
    self._runner:runAction(transition.sequence(seq))
end

function M:endCallback()
    local param = {}
    param.idx = self._idx
    param.to = self._to
	Game:dispatchCustomEvent(GEvent("SHZ_LAPA_END_EVENT"),param)
end

--停止转动
function M:stop()
    if self._runner:getNumberOfRunningActions() > 0 then
        local x,y = self._runner:getPosition()
        local destY = -self._unitSize*(self._amount-self._to-1)
        self._runner:stopAllActions()
        local seq = {
            cc.EaseExponentialOut:create(cc.MoveTo:create(0.54,cc.p(0,-self._unitSize*(self._amount-self._to-1)))),
            cc.CallFunc:create(function(node)
                self:endCallback()
            end)
        }
        if (y-destY) < self._unitSize and (y-destY) > 0 then

        else
            table.insert(seq,1,cc.Place:create(cc.p(0, 0)))
        end
        self._runner:runAction(transition.sequence(seq))
    end
end

return M