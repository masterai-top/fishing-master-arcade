-- 普通规则(非赖子)
local M = class("DdzRule")
local DdzUtils = require_ex("games.ddz.models.DdzUtils").new()
local DdzPX = require_ex("games.ddz.models.DdzCheckPX")
-- 魔数用于特定判断
local MAGIC_NUM = 30
-- 中式英语先用着，暂时没有国际化的要求
--[[
--自定义牌值对应
3->3
4->4
5->5
6->6
7->7
8->8
9->9
10->10
J->11
Q->12
K->13
A->14
2->16
SMALL_JOKER -> 21
BIG_JOKER   -> 22
--]]

cc.exports.PaiXing = {
	TYPE_NONE 		= 0, 	-- 不符合任何一种牌型
    WANG_ZHA 		= 1, 	-- 火箭
    ZHA_DAN 		= 2, 	-- 炸弹
    DAN_ZHANG 		= 3, 	-- 单张
    DUI_ZI 			= 4, 	-- 对子
    SAN_ZHANG 		= 5, 	-- 三张
    SAN_DAI_YI 		= 6, 	-- 三带一
    SAN_DAI_ER 		= 7, 	-- 三带二
    SHUN_ZI 		= 8, 	-- 顺子
    LIAN_DUI 		= 9, 	-- 连对
    FEI_JI 			= 10, 	-- 飞机(3顺)
    FEI_JI_WITH_ONE = 11, 	-- 飞机带单张
    FEI_JI_WITH_TWO = 12, 	-- 飞机带对子
    SI_DAI_ER 		= 13, 	-- 四带两单牌
    SI_DAI_ER_DUI 	= 14, 	-- 四带两对子
}

cc.exports.BIG_JOKER = 22
cc.exports.SMALL_JOKER = 21
cc.exports.ACE = 14
cc.exports.TWO = 16

function M:ctor()
	self:init()
end

function M:init()
	self:clear()
end

function M:clear()
	self._autoSelect = {}			-- 智能选牌
	self._commonSelect = {}			-- 通用选牌
	-- 存储牌值(重复牌值只保留一个)
	self._danZhang = {}  	--单张
	self._duiZi = {}		--对子
	self._sanZhang = {}		--三张
	self._wangZha = {}		--王炸
	self._zhaDan = {}		--炸弹
	self._shunZi = {}		--顺子
	self._lianDui = {}		--连对
	self._feiJi = {}		--飞机
end
------------------------------------------------------------
--@pokesData 从小到大已排序的牌数据
function M:getPokeType(pokesData)
	if Assist.isEmpty(pokesData) then return PaiXing.TYPE_NONE end

	local pokeNum = #pokesData
	if pokeNum == 1 then
		return PaiXing.DAN_ZHANG
	elseif pokeNum == 2 then
		if DdzPX:checkDuiZi(pokesData) then
			return PaiXing.DUI_ZI
		end

		if DdzPX:checkWangZha(pokesData) then
			return PaiXing.WANG_ZHA
		end
	elseif pokeNum == 3 then
		if DdzPX:checkSanZhang(pokesData) then
			return PaiXing.SAN_ZHANG
		end
	elseif pokeNum == 4 then
		if DdzPX:checkSanZhangWithOne(pokesData) then
			return PaiXing.SAN_DAI_YI
		end

		if DdzPX:checkZhaDan(pokesData) then
			return PaiXing.ZHA_DAN
		end
	else
		if DdzPX:checkSanZhangWithTwo(pokesData) then
			return PaiXing.SAN_DAI_ER
		end

		if DdzPX:checkShunZi(pokesData) then
			return PaiXing.SHUN_ZI
		end

		if DdzPX:checkSiDaiEr(pokesData) then
			return PaiXing.SI_DAI_ER
		end

		if DdzPX:checkLianDui(pokesData) then
			return PaiXing.LIAN_DUI
		end

		if DdzPX:checkSiDaiErDui(pokesData) then
			return PaiXing.SI_DAI_ER_DUI
		end

		if DdzPX:checkFeiJi(pokesData) then
			return PaiXing.FEI_JI
		end

		if DdzPX:checkFeiJiWithOne(pokesData) then
			return PaiXing.FEI_JI_WITH_ONE
		end

		if DdzPX:checkFeiJiWithTwo(pokesData) then
			return PaiXing.FEI_JI_WITH_TWO
		end
	end
	return PaiXing.TYPE_NONE
end

------------------------------------------------------------
--简单查找适合牌型(提示)
--@pokesData  		自己牌数据
--@otherGoPokes  	当前回合最后出的牌
--return:对应pokesData的索引表,无则返回空表
function M:autoSelectPoke(pokesData, otherGoPokes)
	if Assist.isEmpty(pokesData) or Assist.isEmpty(otherGoPokes) then
		Log.E("ERROR: pokesData or otherGoPokes is empty")
		return
	end

	local ret = {}
	local otherPokeInfo = self:createPokeInfo(otherGoPokes)
	if otherPokeInfo then
		local pokeType = otherPokeInfo.poke_t
		if pokeType == PaiXing.WANG_ZHA then --打出王炸直接返回
			self._autoSelect = {}
			self._commonSelect = {}
			return
		end

		self:analysePoke(pokesData)
		-- 无炸弹且牌数不足
		if #self._zhaDan==0 and #self._wangZha==0 and #pokesData<otherPokeInfo.poke_n then
			self._autoSelect = {}
			self._commonSelect = {}
			return
		end

		if pokeType == PaiXing.DAN_ZHANG then
			self:selectDanZhang(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.DUI_ZI then
			self:selectDuiZi(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.SAN_ZHANG then
			self:selectSanZhang(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.SAN_DAI_YI then
			self:selectSanZhangWithOne(pokesData, otherPokeInfo)
		
		elseif pokeType == PaiXing.SAN_DAI_ER then
			self:selectSanZhangWithTwo(pokesData, otherPokeInfo)
		
		elseif pokeType == PaiXing.SI_DAI_ER then
			self:selectSiDaiEr(pokesData, otherPokeInfo)
		
		elseif pokeType == PaiXing.SI_DAI_ER_DUI then
			self:selectSiDaiErDui(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.FEI_JI then
			self:selectFeiJi(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.FEI_JI_WITH_ONE then
			self:selectFeiJiWithOne(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.FEI_JI_WITH_TWO then
			self:selectFeiJiWithTwo(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.SHUN_ZI then
			self:selectShunZi(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.LIAN_DUI then
			self:selectLianDui(pokesData, otherPokeInfo)

		elseif pokeType == PaiXing.ZHA_DAN then
			self:selectBomb(pokesData, otherPokeInfo)
		end
	end
end

--创建别人出牌的类型数据信息
--return table
--poke_t 	：牌型
--poke_n	: 牌长
--poke_v 	: 对应类型的关键起始数据
function M:createPokeInfo(otherGoPokes)
	table.sort(otherGoPokes)
	local ret = {}
	local pokeType = self:getPokeType(otherGoPokes)
	print("pokeType:", pokeType)
	if pokeType == PaiXing.DAN_ZHANG 
		or pokeType == PaiXing.DUI_ZI 
		or pokeType == PaiXing.SAN_ZHANG 
		or pokeType == PaiXing.ZHA_DAN
		or pokeType == PaiXing.WAGN_ZHA
		or pokeType == PaiXing.SHUN_ZI
		or pokeType == PaiXing.LIAN_DUI
		or pokeType == PaiXing.FEI_JI then
		ret.poke_v = otherGoPokes[1]

	elseif pokeType == PaiXing.SAN_DAI_YI 
		or pokeType == PaiXing.SAN_DAI_ER then
		local mapTb = DdzUtils:getValueCountMap(otherGoPokes)
		for _, v in ipairs(otherGoPokes) do
			if mapTb[v] == 3 then
				ret.poke_v = v
				break
			end
		end
	
	elseif pokeType == PaiXing.SI_DAI_ER
		or pokeType == PaiXing.SI_DAI_ER_DUI then
		local mapTb = DdzUtils:getValueCountMap(otherGoPokes)
		local max = 0
		for _, v in ipairs(otherGoPokes) do
			if mapTb[v] == 4 then
				if v>max then
					max = v
				end
			end
		end
		ret.poke_v = max
	elseif pokeType == PaiXing.FEI_JI_WITH_ONE then
		local t = {}
		local mapTb = DdzUtils:getValueCountMap(otherGoPokes)
		local i = 1
		while i<=#otherGoPokes do
			if(mapTb[otherGoPokes[i]]>=3) then
				table.insert(t, otherGoPokes[i])
				i = i + mapTb[otherGoPokes[i]]
			else
				i = i + 1
			end
		end
 		table.sort(t)
 		local len = #otherGoPokes/4
 		if #t == len then
 			ret.poke_v = t[1]
 		else
 			if DdzUtils:checkSequence(t) then
 				ret.poke_v = t[1]
 			else
 				-- 有炸弹组合的飞机扰乱视线
				local tmp = table.remove(t)
				if DdzUtils:checkSequence(t) then
					ret.poke_v = t[1]
				else
					ret.poke_v = t[2]
				end
 			end
 		end
	elseif pokeType == PaiXing.FEI_JI_WITH_TWO then
		local t = {}
		local mapTb = DdzUtils:getValueCountMap(otherGoPokes)
		local i = 1
		while i<=#otherGoPokes do
			if(mapTb[otherGoPokes[i]]>=3) then
				table.insert(t, otherGoPokes[i])
				i = i + mapTb[otherGoPokes[i]]
			else
				i = i + 1
			end
		end
 		table.sort(t)
 		local len = #otherGoPokes/5
 		if #t == len then
 			ret.poke_v = t[1]
 		else
 			if DdzUtils:checkSequence(t) then
 				if mapTb[t[1]]==3 then
					ret.poke_v = t[1]
				else -- [8,8,8,8,9,9,9,10,10,10]
					ret.poke_v = t[2]
				end
 			else
 				-- 有炸弹组合的飞机扰乱视线
				local tmp = table.remove(t)
				if DdzUtils:checkSequence(t) then
					ret.poke_v = t[1]
				else
					ret.poke_v = t[2]
				end
 			end
 		end
	end
	ret.poke_n = #otherGoPokes
	ret.poke_t = pokeType
	return ret
end

-- 检测两手牌的情况，一手炸弹一手其他
function M:checkBombFirst(pokesData, otherPokeInfo)
	local bombFirst = false
	local mapNumTb = DdzUtils:getValueCountMap(pokesData)
	local tmp = {}
	if mapNumTb[SMALL_JOKER]==1 and mapNumTb[BIG_JOKER]==1 then
		for _, v in ipairs(pokesData) do
			if v<SMALL_JOKER then
				table.insert(tmp, v)
			end
		end
	else
		for v, num in pairs(mapNumTb) do
			if num==4 then
				for _, vv in ipairs(pokesData) do
					if vv~=v then
						table.insert(tmp, vv)
					end
				end
				break
			end
		end
	end
	local pokeType = self:getPokeType(tmp)
	if pokeType~=PaiXing.TYPE_NONE and pokeType~=otherPokeInfo.poke_t then
		bombFirst = true
	end
	return bombFirst
end

--otherPokeInfo table
--pokeType  ：牌型
--pokeNum	: 牌长
--pokeValue : 对应类型的关键起始数据

--select 函数 针对别人出的牌获取能打出的牌,不做传参的类型判断了

--返回能选择的单牌集合
--@param pokesData 扑克牌数据
--@param otherPokeInfo 别人打出牌的信息 (牌型 长度 值)
--@param withoutBomb 选牌过滤炸弹
--@param canDuplicate 选牌可重复
function M:selectDanZhang(pokesData, otherPokeInfo, withoutBomb, canDuplicate)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local recordMap = {}
	for _, v in ipairs(self._danZhang) do
		if v > value then
			table.insert(self._autoSelect, {mapIdxTb[v]})
			recordMap[v] = 1
		end
	end

	local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

	-- 长顺子
	for _, v in ipairs(self._shunZi) do
		if #v>5 then
			if v[1]>value and (recordMap[v[1]]==nil) then
				recordMap[v[1]] = 1
				table.insert(self._commonSelect, {mapIdxTb[v[1]]})
			end
			if v[#v]>value and (recordMap[v[#v]]==nil) then
				recordMap[v[#v]] = 1
				table.insert(self._commonSelect, {mapIdxTb[v[#v]]})
			end
		end
	end

	-- 单张从对子里面查找，如果对子能跟顺子组合，则取出单张
	for _, v in ipairs(self._duiZi) do
		if (v>value) and (recordMap[v]==nil) then
			for _, vv in ipairs(self._shunZi) do
				if #vv>=4 and ((v==vv[1]-1) or (v==vv[#vv]+1)) then
					table.insert(self._commonSelect, {mapIdxTb[v]})
					recordMap[v] = 1
				end
			end
		end
	end

	-- 对子
	for _, v in ipairs(self._duiZi) do
		if (v>value) and (recordMap[v]==nil) then
			table.insert(self._commonSelect, {mapIdxTb[v]})
			if canDuplicate then
				table.insert(self._commonSelect, {mapIdxTb[v]+1})
			end
			recordMap[v] = 1
		end
	end

	-- 三张
	for _, v in ipairs(self._sanZhang) do
		if (v>value) and (recordMap[v]==nil)  then
			table.insert(self._commonSelect, {mapIdxTb[v]})
			if canDuplicate then
				table.insert(self._commonSelect, {mapIdxTb[v]+1})
				table.insert(self._commonSelect, {mapIdxTb[v]+2})
			end
			recordMap[v] = 1
		end
	end

	-- 飞机
	for _, v in ipairs(self._feiJi) do
		for _, vv in ipairs(v) do
			if (vv>value) and (recordMap[vv]==nil)  then
				table.insert(self._commonSelect, {mapIdxTb[vv]})
				if canDuplicate then 
					table.insert(self._commonSelect, {mapIdxTb[vv]+1})
					table.insert(self._commonSelect, {mapIdxTb[vv]+2})
				end
				recordMap[vv] = 1
			end
		end
	end

	-- 连对
	for _, v in ipairs(self._lianDui) do
		for _, vv in ipairs(v) do
			if (vv>value) and (recordMap[vv]==nil) then
				table.insert(self._commonSelect, {mapIdxTb[vv]})
				if canDuplicate then
					table.insert(self._commonSelect, {mapIdxTb[vv]+1})
				end
				recordMap[vv] = 1
			end
		end
	end

	-- 顺子
	for _, v in ipairs(self._shunZi) do
		for _, vv in ipairs(v) do
			if (vv>value) and (recordMap[vv]==nil) then
				table.insert(self._commonSelect, {mapIdxTb[vv]})
				recordMap[vv] = 1
			end
		end
	end

	-- 通用查找顺序
	if not withoutBomb then
		if bombFirst then
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, 1, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, 1, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		else
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		end
	end

	-- 炸弹
	for _, v in ipairs(self._zhaDan) do
		if v>value then
			local idx = mapIdxTb[v]
			table.insert(self._commonSelect, {idx})
			if canDuplicate then
				table.insert(self._commonSelect, {idx+1})
				table.insert(self._commonSelect, {idx+2})
				table.insert(self._commonSelect, {idx+3})
			end
		end
	end

	-- 王炸
	if #self._wangZha>0 then
		table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER]})
		table.insert(self._commonSelect, {mapIdxTb[BIG_JOKER]})
	end
end

--@param pokesData 扑克牌数据
--@param otherPokeInfo 别人打出牌的信息 (牌型 长度 值)
--@param withoutBomb 选牌过滤炸弹
--@param canDuplicate 选牌可重复
function M:selectDuiZi(pokesData, otherPokeInfo, withoutBomb, canDuplicate)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local recordMap = {}
	for _, v in ipairs(self._duiZi) do
		if v > value then
			table.insert(self._autoSelect, {mapIdxTb[v],mapIdxTb[v]+1})
			recordMap[v] = 1
		end
	end

	local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

	-- 从三张连顺子里面查找
	for _, v in ipairs(self._sanZhang) do
		if (v>value) and (recordMap[v]==nil) then
			for _, vv in ipairs(self._shunZi) do
				if (v==vv[1]-1) or (v==vv[#vv]+1) then
					table.insert(self._commonSelect, {mapIdxTb[v],mapIdxTb[v]+1})
					recordMap[v] = 1
				end
			end
		end
	end

	-- 连对
	for _, v in ipairs(self._lianDui) do
		for _, vv in ipairs(v) do
			if (vv>value) and (recordMap[vv]==nil) then
				table.insert(self._commonSelect, {mapIdxTb[vv],mapIdxTb[vv]+1})
				recordMap[vv] = 1
			end
		end
	end

	-- 三张
	for _, v in ipairs(self._sanZhang) do
		if (v>value) and (recordMap[v]==nil) then
			table.insert(self._commonSelect, {mapIdxTb[v], mapIdxTb[v]+1})
			recordMap[v] = 1
		end
	end

	-- 飞机
	for _, v in ipairs(self._feiJi) do
		for _, vv in ipairs(v) do
			if (vv>value) and (recordMap[vv]==nil) then
				table.insert(self._commonSelect, {mapIdxTb[vv],mapIdxTb[vv]+1})
				recordMap[vv] = 1
			end
		end
	end

	-- 顺子和单张
	local data = {}
	for _, v in ipairs(self._shunZi) do
		data = table.mergeList(data, v)
	end
	data = table.mergeList(data, self._danZhang)
	if not Assist.isEmpty(data) then
		table.sort(data)
		local mapNumTb = DdzUtils:getValueCountMap(data)
		for _, v in ipairs(data) do
			if v>value and recordMap[v]==nil and mapNumTb[v] >= 2 then
				table.insert(self._commonSelect, {mapIdxTb[v], mapIdxTb[v]+1})
				recordMap[v] = 1
			end
		end
	end

	-- 通用查找顺序
	if not withoutBomb then
		if bombFirst then
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, 1, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, 1, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		else
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		end
	end

	-- 炸弹
	for _, v in ipairs(self._zhaDan) do
		if (v>value) and (recordMap[v]==nil) then
			table.insert(self._commonSelect, {mapIdxTb[v], mapIdxTb[v]+1})
			if canDuplicate then
				table.insert(self._commonSelect, {mapIdxTb[v]+2, mapIdxTb[v]+3})
			end
			recordMap[v] = 1
		end 
	end
end

function M:selectShunZi(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local len = otherPokeInfo.poke_n
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	--最大的顺子
	if value+len-1 == ACE then
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else 
		local recordMap = {}
		-- 先判断长度相等的顺子
		for _, v in ipairs(self._shunZi) do
			if #v==len and v[1]>value then
				local tmp = {}
				for _, vv in ipairs(v) do
					table.insert(tmp, mapIdxTb[vv])
				end
				recordMap[tmp[1]] = 1
				table.insert(self._autoSelect, tmp)
			end
			-- 拆分长顺子
			if #v-len>=5 then
				if v[1]>value then
					local tmp = {}
					for i=1, len do
						table.insert(tmp, mapIdxTb[v[i]])
					end
					recordMap[tmp[1]] = 1
					table.insert(self._autoSelect, tmp)
				end
				if v[#v-len+1]>value then
					local tmp = {}
					for i=#v-len+1, #v do
						table.insert(tmp, mapIdxTb[v[i]])
					end
					recordMap[tmp[1]] = 1
					table.insert(self._autoSelect, tmp)
				end
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		-- 通用查找顺子
		local ret, tmp, idx = {}, {}, value+1
		local maxV = ACE + 1 - len
		while idx <= maxV do
			for j=idx, idx+len-1 do
				if mapIdxTb[j] then
					table.insert(tmp, mapIdxTb[j])
				else
					tmp = {}
					idx = j + 1
					break
				end
			end
			if not Assist.isEmpty(tmp) and #tmp==len then
				if recordMap[tmp[1]] == nil then
					table.insert(self._commonSelect, tmp)
				end
				tmp = {}
				idx = idx + 1
			end
		end

		
		if bombFirst then
			local tmpBomb = self:getBomb(mapIdxTb, true)
			self._commonSelect = table.mergeList(tmpBomb, self._commonSelect)
		else
			local tmpBomb = self:getBomb(mapIdxTb)
			self._commonSelect = table.mergeList(self._commonSelect, tmpBomb)
		end
	end
end

function M:selectLianDui(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local len = otherPokeInfo.poke_n/2
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value+len-1 == ACE then --最大的连对
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else 
		local recordMap = {}
		-- 检测连对
		for _, v in ipairs(self._lianDui) do
			if #v == len and v[1]>value then
				local tmp = {}
				for _, vv in ipairs(v) do
					table.insert(tmp, mapIdxTb[vv])
					table.insert(tmp, mapIdxTb[vv]+1)
				end
				recordMap[tmp[1]] = 1
				table.insert(self._autoSelect, tmp)
			end
			if #v>=3+len then
				local tmp = {}
				if v[1]>value then
					for i=1, len do
						table.insert(tmp, mapIdxTb[v[i]])
						table.insert(tmp, mapIdxTb[v[i]]+1)
					end
					recordMap[tmp[1]] = 1
					table.insert(self._autoSelect, tmp)
				end
				tmp = {}
				if v[#v-len+1]>value then
					for i=#v-len+1, #v do
						table.insert(tmp, mapIdxTb[v[i]])
						table.insert(tmp, mapIdxTb[v[i]]+1)
					end
					recordMap[tmp[1]] = 1
					table.insert(self._autoSelect, tmp)
				end
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		local lianduiBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local tmp, idx = {}, value+1
		local maxV = ACE + 1 - len
		while idx<=maxV do
			for j=idx, idx+len-1 do
				if mapIdxTb[j] and mapNumTb[j]>=2 then
					table.insert(tmp, mapIdxTb[j])
					table.insert(tmp, mapIdxTb[j]+1)
				else
					idx = j + 1
					tmp = {}
					break
				end
			end
			if not Assist.isEmpty(tmp) and #tmp==len*2 then
				if recordMap[tmp[1]] == nil then
					local useBomb = false
					for _, v in ipairs(tmp) do
						if mapNumTb[v] == 4 then
							useBomb = true
							break
						end
					end
					if useBomb then
						table.insert(lianduiBomb, tmp)
					else
						table.insert(self._commonSelect, tmp)
					end
					recordMap[tmp[1]] = 1
				end
				tmp = {}
				idx = idx + 1
			end
		end

		
		if bombFirst then
			local tmpBomb = self:getBomb(mapIdxTb,true)
			self._commonSelect = table.mergeList(tmpBomb, self._commonSelect)
		else
			local tmpBomb = self:getBomb(mapIdxTb)
			self._commonSelect = table.mergeList(self._commonSelect, tmpBomb)
		end
		-- 拆炸弹放最后面
		self._commonSelect = table.mergeList(self._commonSelect, lianduiBomb)
	end
end

function M:selectSanZhang(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value == TWO then
		-- 炸弹
		for _, v in ipairs(self._zhaDan) do
			local idx = mapIdxTb[v]
			table.insert(self._commonSelect, {idx, idx+1, idx+2, idx+3})
		end

		-- 王炸
		if #self._wangZha>0 then
			table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
		end
	else
		local recordMap = {}
		for _, v in ipairs(self._sanZhang) do
			if v>value then
				local idx = mapIdxTb[v]
				table.insert(self._autoSelect, {idx, idx+1, idx+2})
				recordMap[v] = 1
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		-- 遍历所有三张
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local idx= 1
		local pokeLen = #pokesData
		while idx<=pokeLen do
			if pokesData[idx]>value and mapNumTb[pokesData[idx]]==3 then
				if recordMap[pokesData[idx]] == nil then
					table.insert(self._commonSelect,{idx, idx+1, idx+2})
					recordMap[pokesData[idx]] = 1
				end
				idx = idx + mapNumTb[pokesData[idx]]
			else
				idx = idx + 1
			end
		end

		if bombFirst then
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, 1, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, 1, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		else
			-- 炸弹
			for _, v in ipairs(self._zhaDan) do
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, {idx, idx+1, idx+2, idx+3})
			end

			-- 王炸
			if #self._wangZha>0 then
				table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
			end
		end

		-- 从炸弹里面拆三张
		for _, v in ipairs(self._zhaDan) do
			if v>value then
				local idx = mapIdxTb[v]
				table.insert(self._commonSelect, {idx, idx+1, idx+2})
			end
		end
	end
end

-- 三张带单张
function M:selectSanZhangWithOne(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value == TWO then
		-- 炸弹
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else
		local recordMap = {}
		local sanZhangSelect = {}
		for _, v in ipairs(self._sanZhang) do
			if v>value then
				local idx = mapIdxTb[v]
				if #self._danZhang > 0 then
					local danZhang = self._danZhang[1]
					table.insert(self._autoSelect, {idx, idx+1, idx+2, mapIdxTb[danZhang]})
				else
					table.insert(sanZhangSelect, {idx, idx+1, idx+2})
				end
				recordMap[idx] = 1
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		-- 炸弹
		local tmpBomb = self:getBomb(mapIdxTb)

		-- 遍历所有三张
		local sanZhangBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local idx = 1
		local pokeLen = #pokesData
		while idx<=pokeLen do
			if pokesData[idx]>value and mapNumTb[pokesData[idx]]>=3 then
				if recordMap[idx] == nil then
					if mapNumTb[pokesData[idx]] == 3 then
						table.insert(sanZhangSelect,{idx, idx+1, idx+2})
					else
						table.insert(sanZhangBomb, {idx, idx+1, idx+2})
					end
					recordMap[idx] = 1
				end
				idx = idx + mapNumTb[pokesData[idx]]
			else
				idx = idx + 1
			end
		end
		local sanZhangAutoSelect = table.newclone(self._autoSelect)
		local function _getSanDaiYiSelect(sanZhangSelect, pokesData, splitFromBomb)
			local removeIdx = {}
			local bombInsertFirst = false
			for k, v in ipairs(sanZhangSelect) do
				local tmpData = table.newclone(pokesData)
				for kk, idx in ipairs(v) do
					tmpData[idx] = MAGIC_NUM + kk*2
				end
				self:analysePoke(tmpData)
				self:selectDanZhang(tmpData, {poke_v=2}, true)
				-- 因为魔数必定有autoselect
				-- 移除autoselect中的魔数
				local tmp, noFind = {}, true
				for _, vv in ipairs(self._autoSelect) do
					if tmpData[vv[1]] < MAGIC_NUM then
						table.insert(tmp, vv[1])
						break
					end
				end
				if not Assist.isEmpty(tmp) then
					if splitFromBomb then
						if pokesData[v[1]] == pokesData[tmp[1]] then
							if #tmp>1 then
								noFind = false
								table.insert(v, tmp[2])
							end
						else
							noFind = false
							table.insert(v, tmp[1])
						end
					else
						noFind = false
						table.insert(v, tmp[1])
					end
				end
				if noFind then
					local tmp = {}
					for _, vv in ipairs(self._commonSelect) do
						table.insert(tmp, vv[1])
					end
					if not Assist.isEmpty(tmp) then
						if splitFromBomb then
							table.insert(v, tmp[1])
						else
							for _, bombV in ipairs(self._zhaDan) do
								if bombV == pokesData[tmp[1]] then
									bombInsertFirst = true
								end
							end
							if #self._wangZha>0 and (pokesData[tmp[1]]==BIG_JOKER or pokesData[tmp[1]]==SMALL_JOKER) then
								bombInsertFirst = true
							end
							table.insert(v, tmp[1])
						end
					else
						table.insert(removeIdx,k)
					end
				end
			end
			table.sort(removeIdx,function(a,b)return a>b end)
			for _, idx in ipairs(removeIdx) do
				table.remove(sanZhangSelect, idx)
			end
			return sanZhangSelect, bombInsertFirst
		end
		local ret
		local szSelect, bombInsertFirst = _getSanDaiYiSelect(sanZhangSelect, pokesData)
		if bombInsertFirst or bombFirst then
			if bombFirst then
				tmpBomb = self:getBomb(mapIdxTb, true)
			end
			ret = table.mergeList(tmpBomb, szSelect)
		else
			ret = table.mergeList(szSelect, tmpBomb)
		end
		szSelect, bombInsertFirst = _getSanDaiYiSelect(sanZhangBomb, pokesData, true)
		self._commonSelect = table.mergeList(ret, szSelect)
		self._autoSelect = sanZhangAutoSelect
	end
end

-- 三张带一对
function M:selectSanZhangWithTwo(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value == TWO then
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else
		local recordMap = {}
		local sanZhangCommonSelect = {}
		for _, v in ipairs(self._sanZhang) do
			if v>value then
				local idx = mapIdxTb[v]
				if #self._duiZi>0 then
					local duiZi = self._duiZi[1]
					table.insert(self._autoSelect, {idx, idx+1, idx+2, mapIdxTb[duiZi], mapIdxTb[duiZi]+1})
				else
					table.insert(sanZhangCommonSelect, {idx, idx+1, idx+2})
				end
				recordMap[idx] = 1
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		-- 炸弹
		local tmpBomb = self:getBomb(mapIdxTb)

		-- 遍历所有三张
		local sanZhangBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local idx= 1
		local pokeLen = #pokesData
		while idx<=pokeLen do
			if pokesData[idx]>value and mapNumTb[pokesData[idx]]>=3 then
				if recordMap[idx] == nil then
					if mapNumTb[pokesData[idx]] == 3 then
						table.insert(sanZhangCommonSelect,{idx, idx+1, idx+2})
					else
						table.insert(sanZhangBomb, {idx, idx+1, idx+2})
					end
					recordMap[idx] = 1
				end
				idx = idx + mapNumTb[pokesData[idx]]
			else
				idx = idx + 1
			end
		end

		local sanZhangAutoSelect = table.newclone(self._autoSelect)
		local function _getSanDaiErSelect(sanZhangTb, pokesData, splitFromBomb)
			local bombInsertFirst = false
			local removeIdx = {}
			for k, v in ipairs(sanZhangTb) do
				local tmpData = table.newclone(pokesData)
				for kk, idx in ipairs(v) do
					tmpData[idx] = MAGIC_NUM + kk*2
				end
				self:analysePoke(tmpData)
				self:selectDuiZi(tmpData, {poke_v=2}, true)
				-- 因为魔数必定有autoselect
				-- 移除autoselect中的魔数
				local tmp, noFind = {}, true
				for _, vv in ipairs(self._autoSelect) do
					if tmpData[vv[1]] < MAGIC_NUM then
						table.insert(tmp, vv[1])
						table.insert(tmp, vv[2])
						break
					end
				end
				if not Assist.isEmpty(tmp) then
					noFind = false
					table.insert(v, tmp[1])
					table.insert(v, tmp[2])
				end
				if noFind then
					local tmp = {}
					for _, vv in ipairs(self._commonSelect) do
						table.insert(tmp, vv[1])
						table.insert(tmp, vv[2])
						break
					end
					if not Assist.isEmpty(tmp) then
						table.insert(v, tmp[1])
						table.insert(v, tmp[2])
						if not splitFromBomb then
							for _, bombV in ipairs(self._zhaDan) do
								if bombV == pokesData[tmp[1]] then
									bombInsertFirst = true
								end
							end
						end
					else
						table.insert(removeIdx,k)
					end
				end
			end
			table.sort(removeIdx,function(a,b)return a>b end)
			for _, idx in ipairs(removeIdx) do
				table.remove(sanZhangTb, idx)
			end
			return sanZhangTb, bombInsertFirst
		end
		local ret
		local sanZhangTb, bombInsertFirst = _getSanDaiErSelect(sanZhangCommonSelect, pokesData)
		if bombInsertFirst or bombFirst then
			if bombFirst then
				tmpBomb = self:getBomb(mapIdxTb, true)
			end
			ret = table.mergeList(tmpBomb, sanZhangTb)
		else
			ret = table.mergeList(sanZhangTb, tmpBomb)
		end
		sanZhangTb, bombInsertFirst = _getSanDaiErSelect(sanZhangBomb, pokesData, true)
		self._commonSelect = table.mergeList(ret, sanZhangTb)
		self._autoSelect = sanZhangAutoSelect
	end
end

function M:getBomb(mapIdxTb, wangZhaFirst)
	local ret = {}
	for _, v in ipairs(self._zhaDan) do
		local idx = mapIdxTb[v]
		table.insert(ret, {idx, idx+1, idx+2, idx+3})
	end

	if #self._wangZha>0 then
		if wangZhaFirst then
			table.insert(ret, 1, {mapIdxTb[SMALL_JOKER], mapIdxTb[BIG_JOKER]})
		else
			table.insert(ret, {mapIdxTb[SMALL_JOKER], mapIdxTb[BIG_JOKER]})
		end
	end
	return ret
end

--寻找炸弹 炸弹不主动提起
function M:selectBomb(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	for _, v in ipairs(self._zhaDan) do
		if v > value then
			local idx = mapIdxTb[v]
			table.insert(self._commonSelect, {idx, idx+1, idx+2, idx+3})
		end
	end

	if #self._wangZha>0 then
		table.insert(self._commonSelect, {mapIdxTb[SMALL_JOKER],mapIdxTb[BIG_JOKER]})
	end
end

-- 四带两单张
function M:selectSiDaiEr(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local mapNumTb = DdzUtils:getValueCountMap(pokesData)
	local bombInsertFirst = false
	local DAN_ZHANG_NUM = 2
	-- 炸弹
	local tmpBomb = self:getBomb(mapIdxTb)
	
	if #self._danZhang >= DAN_ZHANG_NUM then
		for _, v in ipairs(self._zhaDan) do
			if v > value then
				local idx = mapIdxTb[v]
				local tmp = {idx, idx+1, idx+2, idx+3}
				table.insert(tmp, mapIdxTb[self._danZhang[1]])
				table.insert(tmp, mapIdxTb[self._danZhang[2]])
				table.insert(self._autoSelect, tmp)
			end
		end
		self._commonSelect = {}
	else
		local ret = {}
		local removeIdx = {}
		for _, v in ipairs(self._zhaDan) do
			if v > value then
				local idx = mapIdxTb[v]
				table.insert(ret, {idx, idx+1, idx+2, idx+3})
			end
		end
		for k, v in ipairs(ret) do
			local tmpData = table.newclone(pokesData)
			for kk, idx in ipairs(v) do
				tmpData[idx] = MAGIC_NUM + kk*2
			end
			self:analysePoke(tmpData)
			self:selectDanZhang(tmpData, {poke_v=2}, true, true)
			local tmp, noSatisfy = {}, true
			for _, vv in ipairs(self._autoSelect) do
				if tmpData[vv[1]] < MAGIC_NUM then
					table.insert(tmp, vv[1])
				end
			end
			local count = 0
			for _, idx in ipairs(tmp) do
				table.insert(v, idx)
				count = count + 1
				if count == DAN_ZHANG_NUM then
					noSatisfy = false
					break
				end
			end
			if noSatisfy then
				local need = DAN_ZHANG_NUM - count
				local tmp = {}
				for _, vv in ipairs(self._commonSelect) do
					table.insert(tmp, vv[1])
				end
				for _, idx in ipairs(tmp) do
					if #self._wangZha>0 and (pokesData[idx]==SMALL_JOKER or pokesData[idx]==BIG_JOKER) then
						bombInsertFirst = true
					end
					for _, bombV in ipairs(self._zhaDan) do
						if bombV == pokesData[idx] then
							bombInsertFirst = true
							break
						end
					end
					table.insert(v, idx)
					need = need - 1
					if need == 0 then
						break
					end
				end
				if need > 0 then
					table.insert(removeIdx, k)
				end
			end
		end
		table.sort(removeIdx,function(a,b)return a>b end)
		for _, idx in ipairs(removeIdx) do
			table.remove(ret, idx)
		end
		self._autoSelect = {}
		self._commonSelect = ret
	end
	local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)
	if bombInsertFirst or bombFirst then
		if bombFirst then
			tmpBomb = self:getBomb(mapIdxTb, true)
		end
		self._commonSelect = table.mergeList(tmpBomb, self._commonSelect)
	else
		self._commonSelect = table.mergeList(self._commonSelect, tmpBomb)
	end
end

--四带两对
function M:selectSiDaiErDui(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local mapNumTb = DdzUtils:getValueCountMap(pokesData)
	local bombInsertFirst = false
	local DUI_ZI_NUM = 2
	-- 炸弹
	local tmpBomb = self:getBomb(mapIdxTb)
	if #self._duiZi >= DUI_ZI_NUM then
		for _, v in ipairs(self._zhaDan) do
			if v > value then
				local idx = mapIdxTb[v]
				local tmp = {idx, idx+1, idx+2, idx+3}
				table.insert(tmp, mapIdxTb[self._duiZi[1]])
				table.insert(tmp, mapIdxTb[self._duiZi[1]]+1)
				table.insert(tmp, mapIdxTb[self._duiZi[2]])
				table.insert(tmp, mapIdxTb[self._duiZi[2]]+1)
				table.insert(self._autoSelect, tmp)
			end
		end
		self._commonSelect = {}
	else
		local ret = {}
		local removeIdx = {}
		
		for _, v in ipairs(self._zhaDan) do
			if v > value then
				local idx = mapIdxTb[v]
				table.insert(ret, {idx, idx+1, idx+2, idx+3})
			end
		end
		for k, v in ipairs(ret) do
			local tmpData = table.newclone(pokesData)
			for kk, idx in ipairs(v) do
				tmpData[idx] = MAGIC_NUM + kk*2
			end
			self:analysePoke(tmpData)
			self:selectDuiZi(tmpData, {poke_v=2}, true, true)
			local tmp, noSatisfy = {}, true
			for _, vv in ipairs(self._autoSelect) do
				if tmpData[vv[1]] < MAGIC_NUM then
					table.insert(tmp, vv)
				end
			end
			local count = 0
			for _, idxTb in ipairs(tmp) do
				table.insert(v, idxTb[1])
				table.insert(v, idxTb[2])
				count = count + 1
				if count == DUI_ZI_NUM then
					noSatisfy = false
					break
				end
			end
			if noSatisfy then
				local need = DUI_ZI_NUM - count
				for _, vv in ipairs(self._commonSelect) do
					table.insert(v, vv[1])
					table.insert(v, vv[2])
					for _, bombV in ipairs(self._zhaDan) do
						if pokesData[vv[1]] == bombV then
							bombInsertFirst = true
							break
						end
					end
					need = need - 1
					if need == 0 then
						break
					end
				end
				if need > 0 then
					table.insert(removeIdx, k)
				end
			end
		end
		table.sort(removeIdx,function(a,b)return a>b end)
		for _, idx in ipairs(removeIdx) do
			table.remove(ret, idx)
		end
		self._commonSelect = ret
		self._autoSelect = {}
	end
	local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)
	if bombInsertFirst or bombFirst then
		if bombFirst then
			tmpBomb = self:getBomb(mapIdxTb, true)
		end
		self._commonSelect = table.mergeList(tmpBomb, self._commonSelect)
	else
		self._commonSelect = table.mergeList(self._commonSelect, tmpBomb)
	end
end

function M:selectFeiJi(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local len = otherPokeInfo.poke_n/3
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value+len-1 == ACE then
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else
		local recordMap = {}
		for _, v in ipairs(self._feiJi) do
			if (#v == len) and (v[1]>value) then
				local tmp = {}
				for _, vv in ipairs(v) do
					table.insert(tmp, mapIdxTb[vv])
					table.insert(tmp, mapIdxTb[vv]+1)
					table.insert(tmp, mapIdxTb[vv]+2)
				end
				table.insert(self._autoSelect, tmp)
				recordMap[tmp[1]] = 1
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)
		self._commonSelect = {}
		local feijiBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local tmp, idx = {}, value+1
		local maxV = ACE + 1 - len
		while idx<=maxV do
			for j=idx, idx+len-1 do
				if mapIdxTb[j] and mapNumTb[j]>=3 then
					table.insert(tmp, mapIdxTb[j])
					table.insert(tmp, mapIdxTb[j]+1)
					table.insert(tmp, mapIdxTb[j]+2)
				else
					idx = j + 1
					tmp = {}
					break
				end
			end
			if not Assist.isEmpty(tmp) and #tmp==len*3 then
				if recordMap[tmp[1]] == nil then
					local useBomb = false
					for _, v in ipairs(tmp) do
						if mapNumTb[v] == 4 then
							useBomb = true
							break
						end
					end
					if useBomb then
						table.insert(feijiBomb, tmp)
					else
						table.insert(self._commonSelect, tmp)
					end
					recordMap[tmp[1]] = 1
				end
				tmp = {}
				idx = idx + 1
			end
		end

		local ret
		if bombFirst then
			local tmpBomb = self:getBomb(mapIdxTb, true)
			ret = table.mergeList(tmpBomb, self._commonSelect)
		else
			local tmpBomb = self:getBomb(mapIdxTb)
			ret = table.mergeList(self._commonSelect, tmpBomb)
		end
		self._commonSelect = table.mergeList(ret, feijiBomb)
	end
end

function M:selectFeiJiWithOne(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local len = otherPokeInfo.poke_n/4
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value+len-1 == ACE then
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else
		local recordMap = {}
		local feiJiCommonSelect = {}
		for _, v in ipairs(self._feiJi) do
			if (#v == len) and (v[1]>value) and (#self._danZhang>=len) then
				local tmp = {}
				if #self._danZhang>=len then
					for k, vv in ipairs(v) do
						table.insert(tmp, mapIdxTb[vv])
						table.insert(tmp, mapIdxTb[vv]+1)
						table.insert(tmp, mapIdxTb[vv]+2)
					end
					for i=1,len do
						table.insert(tmp, mapIdxTb[self._danZhang[i]])
					end
					table.insert(self._autoSelect, tmp)
				else
					for k, vv in ipairs(v) do
						table.insert(tmp, mapIdxTb[vv])
						table.insert(tmp, mapIdxTb[vv]+1)
						table.insert(tmp, mapIdxTb[vv]+2)
					end
					table.insert(feiJiCommonSelect, tmp)
				end
				recordMap[tmp[1]] = 1
			end
		end

		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)
		local tmpBomb = self:getBomb(mapIdxTb)

		local feijiBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local tmp, idx = {}, value+1
		local maxV = ACE + 1 - len
		while idx<=maxV do
			for j=idx, idx+len-1 do
				if mapIdxTb[j] and mapNumTb[j]>=3 then
					table.insert(tmp, mapIdxTb[j])
					table.insert(tmp, mapIdxTb[j]+1)
					table.insert(tmp, mapIdxTb[j]+2)
				else
					idx = j + 1
					tmp = {}
					break
				end
			end
			if not Assist.isEmpty(tmp) and #tmp==len*3 then
				if recordMap[tmp[1]] == nil then
					local useBomb = false
					for _, v in ipairs(tmp) do
						if mapNumTb[v] == 4 then
							useBomb = true
							break
						end
					end
					if useBomb then
						table.insert(feijiBomb, tmp)
					else
						table.insert(feiJiCommonSelect, tmp)
					end
					recordMap[tmp[1]] = 1
				end
				tmp = {}
				idx = idx + 1
			end
		end

		local feiJiAutoSelect = table.newclone(self._autoSelect)
		local function _getFeiJiWithOneSelect(feiJiTb, pokesData, splitFromBomb)
			local removeIdx = {}
			local bombInsertFirst = false
			for k, v in ipairs(feiJiTb) do
				local tmpData = table.newclone(pokesData)
				for kk, idx in ipairs(v) do
					tmpData[idx] = MAGIC_NUM + kk*2
				end
				self:analysePoke(tmpData)
				self:selectDanZhang(tmpData, {poke_v=2}, true, true)
				-- 因为魔数必定有autoselect
				-- 移除autoselect中的魔数
				local tmp, noSatisfy = {}, true
				for _, vv in ipairs(self._autoSelect) do
					if tmpData[vv[1]] < MAGIC_NUM then
						table.insert(tmp, vv[1])
					end
				end
				local count = 0
				for _, idx in ipairs(tmp) do
					if not splitFromBomb then
						for _, bombV in ipairs(self._zhaDan) do
							if bombV == pokesData[idx] then
								bombInsertFirst = true
								break
							end
						end
						if #self._wangZha>0 then
							if pokesData[idx]==SMALL_JOKER or pokesData[idx]==BIG_JOKER then
								bombInsertFirst = true
							end
						end
					end
					table.insert(v, idx)
					count = count + 1
					if count == len then
						noSatisfy = false
						break
					end
				end
				if noSatisfy then
					local need = len - count
					local tmp = {}
					for _, vv in ipairs(self._commonSelect) do
						table.insert(tmp, vv[1])
					end
					for _, idx in ipairs(tmp) do
						if not splitFromBomb then
							for _, bombV in ipairs(self._zhaDan) do
								if bombV == pokesData[idx] then
									bombInsertFirst = true
									break
								end
							end
							if #self._wangZha>0 then
								if pokesData[idx]==SMALL_JOKER or pokesData[idx]==BIG_JOKER then
									bombInsertFirst = true
								end
							end
						end
						table.insert(v, idx)
						need = need - 1
						if need == 0 then
							break
						end
					end
					if need > 0 then
						table.insert(removeIdx, k)
					end
				end
			end
			table.sort(removeIdx,function(a,b)return a>b end)
			for _, idx in ipairs(removeIdx) do
				table.remove(feiJiTb, idx)
			end
			return feiJiTb, bombInsertFirst
		end
		local ret
		local feiJiTb, bombInsertFirst = _getFeiJiWithOneSelect(feiJiCommonSelect, pokesData)
		if bombInsertFirst or bombFirst then
			if bombFirst then
				tmpBomb = self:getBomb(mapIdxTb, true)
			end
			ret = table.mergeList(tmpBomb, feiJiTb)
		else
			ret = table.mergeList(feiJiTb, tmpBomb)
		end
		feiJiTb, bombInsertFirst = _getFeiJiWithOneSelect(feijiBomb, pokesData, true)
		self._commonSelect = table.mergeList(ret, feiJiTb)
		self._autoSelect = feiJiAutoSelect
	end
end

function M:selectFeiJiWithTwo(pokesData, otherPokeInfo)
	local value = otherPokeInfo.poke_v
	local len = otherPokeInfo.poke_n/5
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	if value+len-1 == ACE then
		self._commonSelect = self:getBomb(mapIdxTb)
		self._autoSelect = {}
	else
		local recordMap = {}
		local feiJiCommonSelect = {}
		for _, v in ipairs(self._feiJi) do
			if (#v == len) and (v[1]>value) then
				local tmp = {}
				if #self._duiZi>=len then
					for k, vv in ipairs(v) do
						table.insert(tmp, mapIdxTb[vv])
						table.insert(tmp, mapIdxTb[vv]+1)
						table.insert(tmp, mapIdxTb[vv]+2)
					end
					for i=1, len do
						table.insert(tmp, mapIdxTb[self._duiZi[i]])
						table.insert(tmp, mapIdxTb[self._duiZi[i]]+1)
					end
					table.insert(self._autoSelect, tmp)
				else
					for k, vv in ipairs(v) do
						table.insert(tmp, mapIdxTb[vv])
						table.insert(tmp, mapIdxTb[vv]+1)
						table.insert(tmp, mapIdxTb[vv]+2)
					end
					table.insert(feiJiCommonSelect, tmp)
				end
				recordMap[tmp[1]] = 1
			end
		end

		local tmpBomb = self:getBomb(mapIdxTb)
		local bombFirst = self:checkBombFirst(pokesData, otherPokeInfo)

		local feijiBomb = {}
		local mapNumTb = DdzUtils:getValueCountMap(pokesData)
		local tmp, idx = {}, value+1
		local maxV = ACE + 1 - len
		while idx<=maxV do
			for j=idx, idx+len-1 do
				if mapIdxTb[j] and mapNumTb[j]>=3 then
					table.insert(tmp, mapIdxTb[j])
					table.insert(tmp, mapIdxTb[j]+1)
					table.insert(tmp, mapIdxTb[j]+2)
				else
					idx = j + 1
					tmp = {}
					break
				end
			end
			if not Assist.isEmpty(tmp) and #tmp==len*3 then
				if recordMap[tmp[1]] == nil then
					local useBomb = false
					for _, v in ipairs(tmp) do
						if mapNumTb[v] == 4 then
							useBomb = true
							break
						end
					end
					if useBomb then
						table.insert(feijiBomb, tmp)
					else
						table.insert(feiJiCommonSelect, tmp)
					end
					recordMap[tmp[1]] = 1
				end
				tmp = {}
				idx = idx + 1
			end
		end
		
		local feiJiAutoSelect = table.newclone(self._autoSelect)
		local function _getFeijiWithTwoSelect(feiJiTb, pokesData, splitFromBomb)
			local removeIdx = {}
			local bombInsertFirst = false
			for k, v in ipairs(feiJiTb) do
				local tmpData = table.newclone(pokesData)
				for kk, idx in ipairs(v) do
					tmpData[idx] = MAGIC_NUM + kk*2
				end
				self:analysePoke(tmpData)
				self:selectDuiZi(tmpData, {poke_v=2}, true, true)
				-- 因为魔数必定有autoselect
				-- 移除autoselect中的魔数
				local tmp, noSatisfy = {}, true
				for _, vv in ipairs(self._autoSelect) do
					if tmpData[vv[1]] < MAGIC_NUM then
						table.insert(tmp, vv)
					end
				end
				local count = 0
				for _, idxTb in ipairs(tmp) do
					if not splitFromBomb then
						for _, bombV in ipairs(self._zhaDan) do
							if bombV == pokesData[idxTb[1]] then
								bombInsertFirst = true
								break
							end
						end
					end
					table.insert(v, idxTb[1])
					table.insert(v, idxTb[2])
					count = count + 1
					if count == len then
						noSatisfy = false
						break
					end
				end
				if noSatisfy then
					local need = len - count
					local tmp = {}
					for _, vv in ipairs(self._commonSelect) do
						table.insert(tmp, vv)
					end
					for _, idxTb in ipairs(tmp) do
						if not splitFromBomb then
							for _, bombV in ipairs(self._zhaDan) do
								if bombV == pokesData[idxTb[1]] then
									bombInsertFirst = true
									break
								end
							end
						end
						table.insert(v, idxTb[1])
						table.insert(v, idxTb[2])
						need = need - 1
						if need == 0 then
							break
						end
					end
					if need > 0 then
						table.insert(removeIdx, k)
					end
				end
			end
			table.sort(removeIdx,function(a,b)return a>b end)
			for _, idx in ipairs(removeIdx) do
				table.remove(feiJiTb, idx)
			end
			return feiJiTb, bombInsertFirst
		end
		local ret 
		local feiJiTb, bombInsertFirst = _getFeijiWithTwoSelect(feiJiCommonSelect, pokesData)
		if bombInsertFirst or bombFirst then
			if bombFirst then
				tmpBomb = self:getBomb(mapIdxTb, true)
			end
			ret = table.mergeList(tmpBomb, feiJiTb)
		else
			ret = table.mergeList(feiJiTb, tmpBomb)
		end
		feiJiTb, bombInsertFirst = _getFeijiWithTwoSelect(feijiBomb, pokesData, true)
		self._commonSelect = table.mergeList(ret, feiJiTb)
		self._autoSelect = feiJiAutoSelect
	end
end

--从牌堆中找出最长的顺子,并返回索引表
function M:findSequenceFromPokes(pokesData)
	if Assist.isEmpty(pokesData) then return {} end
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local tb = {}
	for k, _ in pairs(mapIdxTb) do
		table.insert(tb,k)
	end
	table.sort(tb)

	local len, maxLen, endIndex = 0, 0, 0
	local start = tb[1]
	for k, v in ipairs(tb) do
		if v == start then
			start = start + 1
			len = len + 1
		else
			if len > maxLen then
				maxLen = len
				endIndex = k - 1
			end
			start = v + 1
			len = 1
		end
	end
	if len > maxLen then 
		maxLen = len
		endIndex = #tb
	end

	local ret = {}
	if maxLen >= 5 then
		for i=endIndex-maxLen+1, endIndex do
			table.insert(ret, mapIdxTb[tb[i]])
		end
	end
	return ret
end

--从牌堆中找出最长的连对,并返回索引表
function M:findLianduiFromPokes(pokesData)
	if Assist.isEmpty(pokesData) then return {} end
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local mapNumTb = DdzUtils:getValueCountMap(pokesData)
	local tb = {}
	for k, _ in pairs(mapIdxTb) do
		table.insert(tb,k)
	end
	table.sort(tb)
	local len, maxLen, endIndex = 0, 0, 0
	local start = tb[1]
	for k, v in ipairs(tb) do
		if v == start and checknumber(mapNumTb[v])>=2 then
			start = start + 1
			len = len + 1
		else
			if len > maxLen then
				maxLen = len
				endIndex = k - 1
			end
			if checknumber(mapNumTb[v])>=2 then
				len = 1
			else
				len = 0
			end
			start = v + 1
		end
	end
	if len > maxLen then 
		maxLen = len
		endIndex = #tb
	end
	local ret = {}
	if maxLen>=3 then
		for i=endIndex-maxLen+1, endIndex do
			table.insert(ret, mapIdxTb[tb[i]])
			table.insert(ret, mapIdxTb[tb[i]]+1)
		end
	end
	return ret
end

function M:findFeijiFromPokes(pokesData)
	if Assist.isEmpty(pokesData) then return {} end
	local mapIdxTb = DdzUtils:getValueIdxMap(pokesData)
	local mapNumTb = DdzUtils:getValueCountMap(pokesData)
	local tb = {}
	for k, _ in pairs(mapIdxTb) do
		table.insert(tb,k)
	end
	table.sort(tb)
	local len, maxLen, endIndex = 0, 0, 0
	local start = tb[1]
	for k, v in ipairs(tb) do
		if v == start and checknumber(mapNumTb[v])>=3 then
			start = start + 1
			len = len + 1
		else
			if len > maxLen then
				maxLen = len
				endIndex = k - 1
			end
			if checknumber(mapNumTb[v])>=3 then
				len = 1
			else
				len = 0
			end
			start = v + 1
		end
	end
	if len > maxLen then 
		maxLen = len
		endIndex = #tb
	end
	local ret = {}
	local recordMap = {}
	if maxLen>=2 then
		for i=endIndex-maxLen+1, endIndex do
			local v = tb[i]
			table.insert(ret, mapIdxTb[v])
			table.insert(ret, mapIdxTb[v]+1)
			table.insert(ret, mapIdxTb[v]+2)
			mapNumTb[v] = mapNumTb[v] - 3
			recordMap[v] = 1
		end
		local pokeLen = #pokesData
		if pokeLen>=maxLen*5 then --检测对子和单张
			local count = 0
			local tmp = {}
			-- 检测对子
			local i = 1
			while i<pokeLen do
				local v = pokesData[i]
				if recordMap[v]==nil then
					if mapNumTb[v]>=2 and mapNumTb[v]<=3 then
						table.insert(tmp, mapIdxTb[v])
						table.insert(tmp, mapIdxTb[v]+1)
						count = count + 1
					elseif mapNumTb[v] == 4 then
						count = count + 1
						table.insert(tmp, mapIdxTb[v])
						table.insert(tmp, mapIdxTb[v]+1)
						if count < maxLen then
							count = count + 1
							table.insert(tmp, mapIdxTb[v]+2)
							table.insert(tmp, mapIdxTb[v]+3)
						end
					end
					if count == maxLen then
						break
					end
					i = i + mapNumTb[v]
				else
					i = i + 1
				end
			end
			if count == maxLen then
				ret = table.mergeList(ret, tmp)
			else
				local tmp = {}
				local count = 0
				local i = 1
				while i<=pokeLen do
					local v = pokesData[i]
					if recordMap[v]==nil then
						if mapNumTb[v]>0 then
							for j=1, mapNumTb[v] do
								table.insert(tmp, mapIdxTb[v]+j-1)
								count = count + 1
								if count == maxLen then
									break
								end
							end
						end
						i = i + mapNumTb[v]
						if count == maxLen then
							ret = table.mergeList(ret, tmp)
							break
						end
					else
						i = i + 1
					end
				end
			end
		elseif pokeLen>=maxLen*4 then -- 检测单张
			local count = 0
			local tmp = {}
			local i = 1
			while i<=pokeLen do
				local v = pokesData[i]
				if recordMap[v]==nil then
					if mapNumTb[v]>0 then
						for j=1, mapNumTb[v] do
							table.insert(tmp, mapIdxTb[v]+j-1)
							count = count + 1
							if count == maxLen then
								break
							end
						end
						i = i + mapNumTb[v]
					end
					
					if count == maxLen then
						ret = table.mergeList(ret, tmp)
						break
					end
				else
					i = i + 1
				end
			end
		end
	end
	return ret
end
------------------------------------------------------------
-- 智能选牌
function M:getWangZha(mapNumTb)
	-- 分解王炸
	local ret = {}
	if mapNumTb[BIG_JOKER] and mapNumTb[SMALL_JOKER] then
		mapNumTb[BIG_JOKER] = 0
		mapNumTb[SMALL_JOKER] = 0
		table.insert(ret, {SMALL_JOKER, BIG_JOKER})
	end
	return ret
end

function M:getZhaDan(mapNumTb)
	-- 分解炸弹
	local ret = {}
	for pokeV, num in pairs(mapNumTb) do
		if num == 4 then
			table.insert(ret, pokeV)
			mapNumTb[pokeV] = 0
		end
	end
	table.sort(ret)
	return ret
end

function M:getFeiJi(mapNumTb)
	-- 飞机
	local ret = {}
	local pokeArray = DdzUtils:getKeysArray(mapNumTb)
	table.sort(pokeArray)
	local start, count = pokeArray[1], 0
	local tmp = {}
	for k, v in ipairs(pokeArray) do
		if start == v and checknumber(mapNumTb[v]) == 3 then
			start = start + 1
			count = count + 1
		else
			if count >= 2 then
				for i=count, 1, -1 do
					table.insert(tmp, start-i)
					mapNumTb[start-i] = 0
				end
				table.insert(ret, tmp)
			end
			tmp = {}
			start = v + 1
			if checknumber(mapNumTb[v]) == 3 then
				count = 1
			else
				count = 0
			end
		end
	end
	if count >= 2 then
		for i=count, 1, -1 do
			table.insert(tmp, start-i)
			mapNumTb[start-i] = 0
		end
		table.insert(ret, tmp)
	end
	return ret
end

function M:getSanZhang(mapNumTb)
	-- 三张
	local ret = {}
	for k,v in pairs(mapNumTb) do
		if v == 3 then
			table.insert(ret, k)
			mapNumTb[k] = 0
		end
	end
	table.sort(ret)
	return ret
end

-- 组合五顺子
function M:getWuShunZi(mapNumTb, useSanZhang)
	local ret = {}
	local pokeArray = DdzUtils:getKeysArray(mapNumTb)
	if useSanZhang then
		-- 三张与单牌是否能组成顺子
		for k, v in ipairs(self._sanZhang) do
			table.insert(pokeArray, v)
			mapNumTb[v] = 3
		end
	end
	table.sort(pokeArray)
	local start, count = pokeArray[1], 0
	local tmp = {}

	while true do
		for k, v in ipairs(pokeArray) do
			if start == v and mapNumTb[v]>0 then
				start = start + 1
				count = count + 1
			else
				start = v + 1
				if mapNumTb[v]>0 then
					count = 1
				else
					count = 0
				end
			end
			if count == 5 then
				break
			end
		end
		if count == 5 then
			tmp = {}
			for i=count, 1, -1 do
				table.insert(tmp, start-i)
				mapNumTb[start-i] = mapNumTb[start-i] - 1
				if useSanZhang then
					-- 检测顺子中是否使用了三张，有则移除三张中的值
					for k , v in ipairs(self._sanZhang) do
						if v == start-i then
							table.remove(self._sanZhang, k)
							break
						end
					end
				end
			end
			table.insert(ret, tmp)
			start = pokeArray[1]
			count = 0
		else
			break
		end
	end
	if useSanZhang then
		-- 重置
		for k, v in ipairs(self._sanZhang) do
			mapNumTb[v] = 0
		end
	end
	return ret
end

function M:connectShunZi(shun_zi)
	-- 顺子之间拼接
	if Assist.isEmpty(shun_zi) then return {} end
	table.sort(shun_zi, function(a,b)return a[1]<b[1] end)
	if #shun_zi==1 or shun_zi[1][1]>5 then return shun_zi end
	local mapTb = {}
	local removeIdx = {}
	for k, v in ipairs(shun_zi) do
		if mapTb[v[1]] == nil then
			mapTb[v[1]] = {}
			mapTb[v[1]].idx = k
			mapTb[v[1]].len = #v
		end
	end
	for k, t in pairs(mapTb) do
		if mapTb[k+t.len] then
			local idx1 = t.idx
			local idx2 = mapTb[k+t.len].idx
			for _, v in ipairs(shun_zi[idx2]) do
				table.insert(shun_zi[idx1], v)
			end
			table.insert(removeIdx, idx2)
		end
	end
	table.sort(removeIdx, function(a,b)return a>b end)
	for _, idx in ipairs(removeIdx) do
		table.remove(shun_zi, idx)
	end
	return shun_zi
end

function M:getShunZi(mapNumTb)
	local ret1 = self:getWuShunZi(mapNumTb)
	local ret2 = self:getWuShunZi(mapNumTb, true)
	local ret = table.mergeList(ret1, ret2)
	

	-- 顺子扩展
	local nextV = 0
	for _, shunzi in ipairs(ret) do
		while shunzi[1] > 3 do
			nextV = shunzi[1] - 1
			if checknumber(mapNumTb[nextV]) > 0 then --存在
				table.insert(shunzi, 1, nextV)
				mapNumTb[nextV] = mapNumTb[nextV] - 1
			elseif checknumber(mapNumTb[nextV-1])==1 then
				-- 查找是否三张里面有nextV
				local lose = true
				for k, v in ipairs(self._sanZhang) do
					if v == nextV then
						table.remove(self._sanZhang, k)
						table.insert(shunzi, 1, nextV)
						table.insert(shunzi, 1, nextV-1)
						mapNumTb[nextV] = 2
						mapNumTb[nextV-1] = mapNumTb[nextV-1] - 1
						lose = false
						break
					end
				end
				if lose then
					local flag = true 
					while flag do
						flag = false
						-- 末尾是三张且顺子长度大于5，还原这个三张
						if mapNumTb[shunzi[#shunzi]] == 2 and #shunzi>5 then
							table.insert(self._sanZhang, shunzi[#shunzi])
							table.sort(self._sanZhang)
							mapNumTb[shunzi[#shunzi]] = 0
							table.remove(shunzi)
							flag = true
						end
					end
					break
				end
			else
				local flag = true
				while flag do
					flag = false
					-- 末尾是三张且顺子长度大于5，还原这个三张
					if mapNumTb[shunzi[1]] == 2 and #shunzi>5 then
						table.insert(self._sanZhang, shunzi[1])
						table.sort(self._sanZhang)
						mapNumTb[shunzi[1]] = 0
						table.remove(shunzi, 1)
						flag = true
					end
				end
				break
			end
		end
		while shunzi[#shunzi] < ACE do
			nextV = shunzi[#shunzi] + 1
			if checknumber(mapNumTb[nextV]) > 0 then --存在
				table.insert(shunzi,nextV)
				mapNumTb[nextV] = mapNumTb[nextV] - 1
			elseif checknumber(mapNumTb[nextV+1])==1 then 
				-- 查找是否三张里面有nextV
				local lose = true
				for k, v in ipairs(self._sanZhang) do
					if v == nextV then
						table.remove(self._sanZhang, k)
						table.insert(shunzi,nextV)
						table.insert(shunzi,nextV+1)
						mapNumTb[nextV] = 2
						mapNumTb[nextV+1] = mapNumTb[nextV+1] - 1
						lose = false
						break
					end
				end
				if lose then
					local flag = true
					while flag do
						flag = false
						-- 开头是三张且顺子长度大于5，还原这个三张
						if mapNumTb[shunzi[1]] == 2 and #shunzi>5 then
							table.insert(self._sanZhang, shunzi[1])
							table.sort(self._sanZhang)
							mapNumTb[shunzi[1]] = 0
							table.remove(shunzi, 1)
							flag = true
						end
					end
					break
				end
			else
				local flag = true
				while flag do
					flag = false
					-- 开头是三张且顺子长度大于5，还原这个三张
					if mapNumTb[shunzi[#shunzi]] == 2 and #shunzi>5 then
						table.insert(self._sanZhang, shunzi[#shunzi])
						table.sort(self._sanZhang)
						mapNumTb[shunzi[#shunzi]] = 0
						table.remove(shunzi)
						flag = true
					end
				end
				break
			end
		end
	end

	-- 如果顺子中对子以上的个数超过了自身长度的一半，则删除这个顺子
	local flag = true
	while flag do
		flag = false
		local removeIdx = {}
		for k, v in ipairs(ret) do
			local count = 0
			for _, vv in ipairs(v) do
				if mapNumTb[vv]>0 then
					count = count + 1
				end
				if count >= #v/2 then
					-- 先把两边的对子去除，看剩余能否组成顺子
					local len = #v
					while (not Assist.isEmpty(v)) and mapNumTb[v[1]]>0 do
						mapNumTb[v[1]] = mapNumTb[v[1]] + 1
						table.remove(v, 1)
						count = count - 1
					end
					while (not Assist.isEmpty(v)) and mapNumTb[v[#v]]>0 do
						mapNumTb[v[#v]] = mapNumTb[v[#v]] + 1
						table.remove(v)
						count = count - 1
					end
					if #v<5 or count>=#v/2 then
						table.insert(removeIdx, k)
						flag = true
					end
					break
				end
			end
		end
		table.sort(removeIdx, function(a,b)return a>b end)
		for _, idx in ipairs(removeIdx) do
			local tb = table.remove(ret, idx)
			for _, v in ipairs(tb) do
				mapNumTb[v] = mapNumTb[v] + 1
				if mapNumTb[v] == 3 then
					table.insert(self._sanZhang, v)
					table.sort(self._sanZhang)
					mapNumTb[v] = 0
				end
			end
		end
	end

	-- 拆出来的单张有可能组成顺子
	-- AAKKQJ1010109876
	for _, shunzi in ipairs(ret) do
		while shunzi[1] > 3 do
			nextV = shunzi[1] - 1
			if checknumber(mapNumTb[nextV]) == 1 then
				table.insert(shunzi, 1, nextV)
				mapNumTb[nextV] = 0
			else
				break
			end
		end

		while shunzi[#shunzi]< ACE do
			nextV = shunzi[#shunzi] + 1
			if checknumber(mapNumTb[nextV]) == 1 then
				table.insert(shunzi, nextV)
				mapNumTb[nextV] = 0
			else
				break
			end
		end
	end
	-- AAKKQJ101010987766 AAKKQJ1010987766这种没在考虑范围内

	-- 看顺子跟顺子能否拼接
	ret = self:connectShunZi(ret)

	-- 初始值小的在前面
	-- 先比较初始值，再比较长度 ???两个同样的顺子表排序居然没报错，可能内部比较了表地址
	table.sort(ret,function(a, b)
		if a[1] < b[1] then
			return true
		elseif a[1] > b[1] then
			return false
		else
			if #a < #b then 
				return true
			elseif #a > #b then
				return false
			end
		end
	end)
	return ret
end

function M:getLianDuiFromShunZi(mapNumTb)
	-- 检测顺子中是否有连对
	-- 手牌最多只有四组顺子（20张牌）
	local ret = {}
	local shunZiNum = #self._shunZi
	if shunZiNum > 1 then
		local tmp, count = {}, 1
		local recordShunZi = {}
		while count <= shunZiNum do
			if DdzUtils:checkSeqSame(self._shunZi[count],self._shunZi[count+1]) then
				table.insert(ret, self._shunZi[count])
				count = count + 2
				tmp = {}
			else
				table.insert(recordShunZi, self._shunZi[count])
				count = count + 1
			end
		end
		-- 移除组成连对的顺子
		self._shunZi = recordShunZi
	end

	return ret
end

-- {{3,4,5},{11,12,13}}
function M:getLianDui(mapNumTb)
	local lianDui = self:getLianDuiFromShunZi(mapNumTb)

	local function _handleLianDui(pokeArray)
		local ret = false
		-- 检测剩余牌是否有连对
		table.sort(pokeArray)
		local start, count = pokeArray[1], 0
		local tmp = {}
		for k, v in ipairs(pokeArray) do
			if start == v and mapNumTb[v] >= 2 then
				start = start + 1
				count = count + 1
			else
				if count >= 3 then
					ret = true
					for j=count, 1, -1 do
						table.insert(tmp, start-j)
						mapNumTb[start-j] = mapNumTb[start-j] - 2
					end
					table.insert(lianDui, tmp)
					tmp = {}
				end
				start = v + 1
				if mapNumTb[v] >= 2 then
					count = 1
				else
					count = 0
				end
			end
		end
		if count >= 3 then
			ret = true
			for j=count, 1, -1 do
				table.insert(tmp, start-j)
				mapNumTb[start-j] = mapNumTb[start-j] - 2
			end
			table.insert(lianDui, tmp)
		end
		return ret
	end
	
	local pokeArray = DdzUtils:getKeysArray(mapNumTb)
	_handleLianDui(pokeArray)

	-- 刷新后检测与三张连接
	-- pokeArray = DdzUtils:getKeysArray(mapNumTb)
	-- -- 检测剩余牌与三张匹配是否有连对,不存在两个三张搭配一对组连对的情况
	-- if #pokeArray >= 4 then
	-- 	local recordTb = {}
	-- 	for k, v in ipairs(self._sanZhang) do
	-- 		local cloneTb = table.newclone(pokeArray)
	-- 		table.insert(cloneTb, v)
	-- 		mapNumTb[v] = 3
	-- 		if not _handleLianDui(cloneTb) then
	-- 			table.insert(recordTb, v)
	-- 			mapNumTb[v] = 0
	-- 		end
	-- 	end
	-- 	self._sanZhang = recordTb
	-- end

	-- 检测连对中是否有可以还原回三张的牌
	for k, v in ipairs(lianDui) do
		-- 先还原大的牌
		if #v >= 4 then
			if mapNumTb[v[#v]] == 1 then
				mapNumTb[v[#v]] = 0
				table.insert(self._sanZhang, v[#v])
				table.remove(v)
				table.remove(v)
			end
		end
		if #v >= 4 then
			if mapNumTb[v[1]] == 1 then
				mapNumTb[v[1]] = 0
				table.insert(self._sanZhang, v[1])
				table.remove(v, 1)
				table.remove(v, 1)
			end
		end
	end
	return lianDui
end

function M:getDuiZi(mapNumTb)
	local ret = {}
	for k, v in pairs(mapNumTb) do
		if v == 2 then
			table.insert(ret, k)
		end
	end
	-- 从顺子中查找, 能凑成对子则移除顺子中的牌
	local removeIdx = {}
	local shunziIdx = {}
	for k, v in ipairs(self._shunZi) do
		for i=1, #v - 5 do
			if mapNumTb[v[i]] == 1 then
				mapNumTb[v[i]] = 0
				table.insert(ret, v[i])
				table.insert(removeIdx, i)
			else
				break
			end
		end
		
		for i=#v, 6, -1 do
			if mapNumTb[v[i]] == 1 then
				mapNumTb[v[i]] = 0
				table.insert(ret, v[i])
				table.insert(removeIdx, i)
			else
				break
			end
		end
		table.sort(removeIdx, function(a,b)return a>b end)
		for _, idx in ipairs(removeIdx) do
			table.remove(v, idx)
		end
		removeIdx = {}
	end

	self._shunZi = self:connectShunZi(self._shunZi)

	table.sort(ret)
	local start = ret[1]
	local len = 0
	local tmp = {}
	local tmpLianDui = {}
    for _, v in ipairs(ret) do
        if start == v then
            start = start + 1
            len = len + 1
            table.insert(tmp, v)
        else
        	if len>=3 then
            	tmpLianDui = {}
            	for j=len, 1, -1 do
            		table.insert(tmpLianDui, start-j)
            		table.remove(tmp)
            	end
            	table.insert(self._lianDui, tmpLianDui)
            end
            len = 1
            start = v + 1
            table.insert(tmp, v)
        end
    end
    if len>=3 then
    	tmpLianDui = {}
    	for j=len, 1, -1 do
    		table.insert(tmpLianDui, start-j)
    		table.remove(tmp)
    	end
    	table.insert(self._lianDui, tmpLianDui)
    end
    ret = tmp
	return ret
end

function M:getDanZhang(mapNumTb)
	local ret = {}
	for k, v in pairs(mapNumTb) do
		if v == 1 then
			table.insert(ret, k)
		end
	end

	table.sort(ret)
	return ret
end

function M:getAutoselect()
	return self._autoSelect
end

function M:getCommonSelect()
	return self._commonSelect
end

function M:getAllSelect()
	return table.mergeList(self._autoSelect, self._commonSelect)
end

-- 拆牌
function M:analysePoke(pokesData)
	self:clear()	--后期可做优化

	local mapNumTb = DdzUtils:getValueCountMap(pokesData)

	-- mapNumTb会不断改变
	self._wangZha = self:getWangZha(mapNumTb)

	self._zhaDan = self:getZhaDan(mapNumTb)

	self._feiJi = self:getFeiJi(mapNumTb)

	self._sanZhang = self:getSanZhang(mapNumTb)

	self._shunZi = self:getShunZi(mapNumTb)

	self._lianDui = self:getLianDui(mapNumTb)

	self._duiZi = self:getDuiZi(mapNumTb)

	self._danZhang = self:getDanZhang(mapNumTb)

	-- dump(pokesData, "原始牌")
	-- dump(self._wangZha, "self._wangZha")
	-- dump(self._zhaDan, "self._zhaDan")
	-- dump(self._feiJi, "self._feiJi")
	-- dump(self._sanZhang, "self._sanZhang")
	-- dump(self._shunZi, "self._shunZi")
	-- dump(self._lianDui, "self._lianDui")
	-- dump(self._duiZi, "self._duiZi")
	-- dump(self._danZhang, "self._danZhang")
end
------------------------------------------------------------


function M:testDataMonitor()
	local pokesData = {5,6,7,7,8,9,10,10,11,11,13,13,13}
	self:autoSelectPoke(pokesData, {8})

	self:printPokeCombo(pokesData)
end

function M:printPokeCombo(pokesData)
	print("_autoSelect")
	for _, v in ipairs(self._autoSelect) do
		for _, vv in ipairs(v) do
			print(pokesData[vv])
		end
		print("------------------------------")
	end

	print("_commonSelect")
	for _, v in ipairs(self._commonSelect) do
		for _, vv in ipairs(v) do
			print(pokesData[vv])
		end
		print("------------------------------")
	end
end

return M:new()