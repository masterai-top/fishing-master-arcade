-- 检测斗地主牌型，获取对应牌的牌型
local M = class("DdzCheckPX")
local DdzUtils = require_ex("games.ddz.models.DdzUtils").new()
------------------------------------------------------------
--检测牌型函数
--pokesData: {3,4,5,6,7,7,7,7,8,9,12,12,12,13,13,13,16,16,21,22}
function M:checkDuiZi(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	return (pokeNum == 2) and (pokesData[1] == pokesData[2])
end

--王炸
function M:checkWangZha(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	local mapTb = DdzUtils:getValueCountMap(pokesData)
	return (pokeNum == 2) and mapTb[SMALL_JOKER] and mapTb[BIG_JOKER]
end

--三张
function M:checkSanZhang(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum == 3 then
		return (pokesData[1]==pokesData[2]) and (pokesData[2]==pokesData[3])
	end
	return false
end

--三带一
function M:checkSanZhangWithOne(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum == 4 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		for _, count in pairs(mapTb) do
			if count == 3 then
				return true
			end
		end
	end
	return false
end

--三带二
function M:checkSanZhangWithTwo(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum == 5 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		for pokeValue, count in pairs(mapTb) do
			if count == 3 then
				mapTb[pokesData] = nil
				for pokeValue, count in pairs(mapTb) do
					if count == 2 then
						return true
					end
				end
				break
			end
		end
	end
	return false
end

--除王炸外的炸弹
function M:checkZhaDan(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum == 4 then
		return (pokesData[1]==pokesData[2]) and (pokesData[2]==pokesData[3]) and (pokesData[3]==pokesData[4])
	end
	return false
end

--顺子
function M:checkShunZi(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum >= 5 then
		return DdzUtils:checkSequence(pokesData)
	end
	return false
end

--连对
function M:checkLianDui(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum<6 or pokeNum%2~=0 then return false end
	local mapTb = DdzUtils:getValueCountMap(pokesData)
	local checkTb = {}
	for pokeValue, count in pairs(mapTb) do
		if count ~= 2 then return false end
		table.insert(checkTb, pokeValue)
	end
	table.sort(checkTb)
	return DdzUtils:checkSequence(checkTb)
end

--飞机
function M:checkFeiJi(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum>=6 and pokeNum%3 == 0 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		local checkTb = {}
		for pokeValue, count in pairs(mapTb) do
			if count ~= 3 then return false end
			table.insert(checkTb, pokeValue)
		end
		table.sort(checkTb)
		return #checkTb==pokeNum/3 and DdzUtils:checkSequence(checkTb)
	end
	return false
end

--飞机带翅膀 N个连续的三带一
function M:checkFeiJiWithOne(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum>=8 and pokeNum%4 == 0 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		local checkTb = {}
		for pokeValue, count in pairs(mapTb) do
			if count >= 3 then
				table.insert(checkTb, pokeValue)
			end
		end
		table.sort(checkTb)
		local len = #checkTb
		if len == pokeNum/4 then
			return DdzUtils:checkSequence(checkTb)
		elseif len > pokeNum/4 then
			local last = table.remove(checkTb)
			if DdzUtils:checkSequence(checkTb) then
				return true
			else
				table.insert(checkTb, last)
				table.remove(checkTb, 1)
				return DdzUtils:checkSequence(checkTb)
			end
		end
	end
	return false
end

--飞机带翅膀 N个连续的三带两对
function M:checkFeiJiWithTwo(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	local pokeNum = #pokesData
	if pokeNum>=10 and pokeNum%5 == 0 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		local checkTb = {}
		for pokeValue, count in pairs(mapTb) do
			if count == 3 then
				table.insert(checkTb,pokeValue)
			elseif count == 1 then
				return false
			end
		end
		table.sort(checkTb)
		return #checkTb==pokeNum/5 and DdzUtils:checkSequence(checkTb)
	end
	return false
end

--四带二
function M:checkSiDaiEr(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	if #pokesData == 6 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		for k, v in pairs(mapTb) do
			if v == 4 then return true end
		end
	end
	return false
end

--四带两对
function M:checkSiDaiErDui(pokesData)
	if Assist.isEmpty(pokesData) or type(pokesData) ~= "table" then return false end
	if #pokesData == 8 then
		local mapTb = DdzUtils:getValueCountMap(pokesData)
		local findBomb = false
		for k, v in pairs(mapTb) do
			if v == 4 then 
				mapTb[k] = nil 
				findBomb = true
				break
			end
		end
		if findBomb then
			for k, v in pairs(mapTb) do
				if v%2~=0 then
					return false
				end
			end
			return true
		end
	end
	return false
end

return M