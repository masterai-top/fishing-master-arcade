--[[ 
Shuihu相关数据 
]]

local M = class("ShuihuDB")


function M:ctor()
    self:init()
end

--数据初始化
function M:init()
	--押倍数据
	self._betList = {
		10, 50, 100, 500, 1000, 5000, 10000
	}
	self._maxLineCount = 9		--线条总数
	self._maxIconCount = 9		--图片类型总数
	self._maxLightCount = 9		--灯总数
	self._maxCellCount = 15		--格子总数
	self._winCount = 0			--普通赢钱
	self._isBigWin = false		--大奖
	self._winLineList = {}		--中奖线条id集合
	self._winCombo = {}			--中奖组合
	self._recordData = nil
	self._lineRule = self:getLineRule()
	self._resultData = nil
	self._allWinIdx = 0			--全屏奖索引
	self._tipCode = 0
	self._soundHandle = {}		--缓存音效句柄
	self._debugInfo = nil		--调试数据		
end

function M:resetNextData()
end

function M:getMaxLineCount()
	return self._maxLineCount
end

function M:getBetList()
	return self._betList
end

function M:getMaxIconCount()
	return self._maxIconCount
end

function M:getMaxLightCount()
	return self._maxLightCount
end

function M:getMaxCellCount()
	return self._maxCellCount
end

function M:setWinCount(count)
    self._winCount = count
end

function M:getWinCount()
    return self._winCount
end

--检测三个值是否相等
local function checkThreeSame(a,b,c)
	local num1,num2,num3 = a,b,c
	local ret = false
	local LAIZI = 9
	if num1 == LAIZI then
		if num2 == LAIZI then
			ret = true
		else
			ret = (num2==num3) or (num3==LAIZI)
		end
	else
		if num2 == LAIZI then
			ret = (num1==num3) or (num3==LAIZI)
		else
			if num3 == LAIZI then
				ret = num1==num2
			else
				ret = (num1==num2) and (num2==num3)
			end
		end
	end
	return ret
end

--分析中奖线和图标
function M:analyseResultData(resultData)
	self._winLineList = {}
	self._winCombo = {}
	self._allWinIdx = 0
	local tempTb = {}
	--有限个数直接用数组显示出来
	for k,v in ipairs(self._lineRule) do
		local realNum
		if checkThreeSame(resultData[v[1]],resultData[v[2]],resultData[v[3]]) then
			table.insert(self._winLineList,k)
			table.insert(tempTb,v[1])
			table.insert(tempTb,v[2])
			table.insert(tempTb,v[3])
			realNum = resultData[v[1]]
			if realNum == 9 then
				if resultData[v[2]] == 9 then
					realNum = resultData[v[3]]
				else
					realNum = resultData[v[2]]
				end
			end

			for i=4,5 do
				if checkThreeSame(realNum,resultData[v[i-1]],resultData[v[i]]) then
					table.insert(tempTb,v[i])
				end
			end
			table.insert(self._winCombo,tempTb)
		end
		if realNum~=resultData[v[4]] and checkThreeSame(resultData[v[5]],resultData[v[4]],resultData[v[3]]) then
			table.insert(self._winLineList,k)
			tempTb = {}
			table.insert(tempTb,v[3])
			table.insert(tempTb,v[4])
			table.insert(tempTb,v[5])
			local realNum = resultData[v[5]]
			if realNum == 9 then
				if resultData[v[4]] == 9 then
					realNum = resultData[v[3]]
				else
					realNum = resultData[v[4]]
				end
			end
			for i=2,1,-1 do
				if checkThreeSame(realNum,resultData[v[i+1]],resultData[v[i]]) then
					table.insert(tempTb,v[i])
				end
			end
			table.insert(self._winCombo,tempTb)
		end
		tempTb = {}
	end
	self:checkAllWinIdx(resultData)
end

function M:checkAllWinIdx(resultData)
	--校验是否全屏相同，包括赖子
	local value = resultData[1]
	local ret = true
	for j=2,#resultData do
		if value == 9 then
			value = resultData[j]
		elseif resultData[j] ~= value and resultData[j]~=9 then
			ret = false
			break
		end
	end
	if ret then
		self._allWinIdx = value
	end
	return ret
end

function M:getAllWinIdx()
	return self._allWinIdx
end

--抽奖结果缓存
function M:setResultData(resultData)
	self._resultData = resultData
	self:analyseResultData(resultData)
end

function M:getResultData()
	return self._resultData
end

function M:getWinLineList()
	return self._winLineList
end

--中奖组合
function M:getWinCombo()
	return self._winCombo
end

function M:setBigWin(big_win)
	self._isBigWin = big_win
end

function M:haveBigWin()
	return self._isBigWin
end

function M:setRecordData(record_data)
	self._recordData = record_data
end

function M:getRecordData()
	return self._recordData
end

function M:getLineRule()
	if not LineRulesConfig then return end
    local cfg = {}
    local ids = LineRulesConfig.getIds()
    table.sort(ids,function(a,b)return a<b end)
    for k,v in ipairs(ids) do
    	cfg[v] = LineRulesConfig[v].universal
    end
    return cfg
end

function M:setServerTipCode(tip_code)
	self._tipCode = tip_code
end

function M:getServerTipCode()
	return self._tipCode
end

function M:addSoundHandle(handle)
	table.insert(self._soundHandle,handle)
end

function M:releaseSoundHandle()
	for _, handle in ipairs(self._soundHandle) do
		Audio.stopSound(handle)
	end
	self:clearSoundHandle()
end

function M:clearSoundHandle()
	self._soundHandle = {}
end

function M:setDebugInfo(debugInfo)
    self._debugInfo = debugInfo
end

function M:getDebugInfo()
    return self._debugInfo
end
----------------------------------
-- 单机数据模拟
function M:testDataMonitor()
	print("testDataMonitor~~~~~~~~~~~")
    -- local resultData = {1,9,2,1,2,4,4,2,3,1,2,9,6,7,5}
    -- print(self:checkAllWinIdx(resultData))
    -- resultData = {9,3,9,9,3,9,9,3,3,9,3,2,9,3,9}
    -- print(self:checkAllWinIdx(resultData))
    -- resultData = {9,3,9,9,3,9,9,3,3,9,3,3,9,3,9}
    -- print(self:checkAllWinIdx(resultData))

    local resultData = {3,3,3,2,2,4,4,4,5,5,6,6,6,7,7}
    self:analyseResultData(resultData)
    dump(self._winCombo)
end

return M:new()
