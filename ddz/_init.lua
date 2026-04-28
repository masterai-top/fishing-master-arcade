--[[
小游戏大厅接口文件，归属主框架
]]

local funcId = 1074		
local funcKey = "ddz"

Game:registerSceneEntry(funcId, string.format("games.%s.GameEntry", funcKey))

local function _checkLimit()
	local limitCannon = SubgameConfig.cannon(funcId)
	local limitCoin = SubgameConfig.coin(funcId)
	local info = Game:doPluginAPI("get","quickInfo")
    local lv = info and info.lv or 1
	local cannon = BYCannonLevelConfig.cannon_multiple(lv)
	local coin = Game:doPluginAPI("get","playerCoin")
	if checknumber(cannon) < limitCannon[1] then
		return true,limitCannon[2]
	end
	if coin < limitCoin[1] then
		return true,limitCoin[2]
	end
	return false
end

local function _checkDownload()
	return not Game:isPluginExist(funcId)
end

local function _download()
	local url = string.gsub(CDN_HOST, "platform", device.platform)
	local urlRES = string.gsub(CDN_HOST_RES, "platform", device.platform)
	local args = string.format("%s/%s.zip", AppName, funcKey)
	Game.httpCom:requestUpdatePkg(funcKey, url..args, urlRES..args)
end

local function _enterPlugin()
	if _checkDownload() then
		Game:tipMsg(Config.localize("need_download"), 3)
	elseif _checkLimit() then
		Game:tipMsg(Config.localize("condi_limit"))
	else
	    Game:enterScene(funcId)
	end
end

Game:registerAPI("enter", funcKey, function(sender)
	_enterPlugin()
end)

local apiList = {
	{"checkLimit", 		funcKey, 		_checkLimit},
	{"checkDownload", 	funcKey, 		_checkDownload},
	{"download", 		funcKey, 		_download},
}
Game:registerAPIList(apiList)
