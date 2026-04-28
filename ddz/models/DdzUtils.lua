-- 斗地主通用函数
local M = class("DdzUtils")

--[[
转换为原值为键，原值个数为值的映射表
@param  array  table    数组
]]
function M:getValueCountMap(array)
    local ret = {}
    for k, v in ipairs(array) do
        if ret[v] == nil then
            ret[v] = 1
        else
            ret[v] = ret[v] + 1
        end
    end
    return ret
end


--[[
转换为原值为键，第一个值的索引为值的映射表
@param  array  table    数组 
]]
function M:getValueIdxMap(array)
	local ret = {}
	for k, v in ipairs(array) do
		if ret[v] == nil then
			ret[v] = k
		end
	end
	return ret
end

--[[
判断是否是值连续的数组
@param  array  table    数组 {1,2,3,4,5,6}
]]
function M:checkSequence(array)
    if Assist.isEmpty(array) then return false end
    local data = table.newclone(array)
    table.sort(data)
    local start = data[1]
    for _, v in ipairs(data) do
        if start == v then
            start = start + 1
        else
            return false
        end
    end
    return true
end


--[[
检测两个顺子相等
@param  array  seq1    数组 
@param  array  seq2    数组 
]]
function M:checkSeqSame(seq1,seq2)
	-- 空值不做比较
	if Assist.isEmpty(seq1) or Assist.isEmpty(seq2) then return false end
	local checkSeq1 = table.newclone(seq1)
	local checkSeq2 = table.newclone(seq2)
	table.sort(checkSeq1)
	table.sort(checkSeq2)
	for k, v in ipairs(checkSeq1) do
		if v ~= checkSeq2[k] then
			return false
		end
	end
	return #checkSeq1 == #checkSeq2
end

--[[
@param mapNumTb 映射表[poke value] = num
返回个数大于0的键表
]]
function M:getKeysArray(mapNumTb)
	local ret = {}
	for k, v in pairs(mapNumTb) do
		if v > 0 then
			table.insert(ret, k)
		end
	end
	return ret
end

return M