--[[
小游戏大厅接口文件，归属主框架
]]

local funcId = 1020
local funcKey = "brnn"
local funcType = "bullet_brnn"
local funcIdMap = {
	[1020] = 1055
}

Game:registerSceneEntry(funcId, string.format("games.%s.GameEntry", funcKey))

local function _checkBulletLimit()
	local limitCannon = SubgameConfig.cannon(funcIdMap[funcId])
	local limitCoin = SubgameConfig.coin(funcIdMap[funcId])
	local info = Game:doPluginAPI("get","quickInfo")
	local lv = info and info.lv or 0
	local cannon = BYCannonLevelConfig.cannon_multiple(lv) or lv
	local jade = Game:doPluginAPI("get","playerJade")
	if checknumber(cannon) < limitCannon[1] then
		return true,limitCannon[2]
	end
	if jade < limitCoin[1] then
		Game:performDelay(function()
			Game:doPluginAPI("enter","exchangeJade")
		end,0.1)
		return true,limitCoin[2]
	end
	return false
end

local function _checkLimit(key)
	if key == nil then 		--金币场
		local limitCannon = SubgameConfig.cannon(funcId)
		local limitCoin = SubgameConfig.coin(funcId)
		local lv = Game:doPluginAPI("get","quickInfo").lv
		local cannon = BYCannonLevelConfig.cannon_multiple(lv) or lv
		local coin = Game:doPluginAPI("get","playerCoin")
		if checknumber(cannon) < limitCannon[1] then
			return true,limitCannon[2]
		end
		if coin < limitCoin[1] then
			return true,limitCoin[2]
		end
		return false
	elseif key == funcType then
		return _checkBulletLimit()
	end
end

local function _checkDownload()
	return not Game:isPluginExist(funcId)
end

local function _download()
	local url = string.gsub(CDN_HOST, "platform", device.platform)
	local urlRES = string.gsub(CDN_HOST, "platform", device.platform)
	local args = string.format("%s/%s.zip", AppName, funcKey)
	Game.httpCom:requestUpdatePkg(funcKey, url..args, urlRES..args)
end

local function _enterBulletPlugin(pendKey)
	if _checkDownload() then
		Game:tipMsg(Config.localize("need_download"), 3)
	elseif _checkBulletLimit() then
		Game:tipMsg(Config.localize("condi_limit"))
	else
		Game.fieldId = ENUM.GAME.BRNN
	    Game:enterScene(funcId, nil, pendKey)
	end
end

local function _enterPlugin(pendKey)
	if pendKey == nil then 		--金币场
		if _checkDownload() then
			Game:tipMsg(Config.localize("need_download"), 3)
		elseif _checkLimit() then
			Game:tipMsg(Config.localize("condi_limit"))
		else
			Game.fieldId = 0
		    Game:enterScene(funcId, nil, funcKey)
		end
	elseif pendKey == funcType then
		_enterBulletPlugin(pendKey)
	end
end

Game:registerAPI("enter", funcKey, function(pendKey)
	_enterPlugin(pendKey)
end)

Game:registerAPI("check", "pendent"..funcKey, function()
	local playerLv = Game:doPluginAPI("get","playerLv")
	return (FuncListKeyConfig.state(funcType) ~= 1) or (playerLv<checknumber(SubgameConfig.level(funcIdMap[funcId])))
end)

local apiList = {
	{"checkLimit", 		funcKey, 		_checkLimit},
	{"checkDownload", 	funcKey, 		_checkDownload},
	{"download", 		funcKey, 		_download},
}
Game:registerAPIList(apiList)
