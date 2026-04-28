--[[
配置表加载
]]

require_ex("config.ChannelConfig") --@discarded

-- 初始加载配置列表
local ConfigGroup = {
    "MsgConfig",
    "StringConfig",
    "BlockTxt",
    "SoundConfig",
    "ServerListConfig",
    "SystemLimitConfig",
    "SkinsConfig",
    "FuncListConfig",
    "ChannelNameConfig",
    "LOCBridgeConfig",
    "ShopItemsStatusConfig",
	"ShopItemKeyConfig",
}

local SkinFunc = {id=888, key="skin"} -- 马甲包
local FILE_EXT = { ".lua", ".luac" }
local fileIns = cc.FileUtils:getInstance()
local updPath = fileIns:getWritablePath().."/update/"

local function isFileExist(moduleName)
    for _, ext in ipairs(FILE_EXT) do
        local fileName = string.gsub(moduleName, "%.", "/")..ext
        if fileIns:isFileExist(fileName) then
            return true
        end
    end

    return false
end

--[[
分渠道加载配置表
@param name     string  配置表名称
]]
local function loadMarketConfig(name)
    if not Sdk then
        require_ex("config."..name)
    	return
    end

    local suffix = tostring(Sdk.getMarketId())
    local moduleName
    if ChannelConfig[suffix] then
        -- 有渠道的配置信息 @discarded
        moduleName = string.format("config.%s.%s", ChannelConfig[suffix].name, name)
    end
    
    if moduleName and isFileExist("res."..moduleName) then
        -- 有相应渠道的独立配置表
        require_ex(moduleName)
    else
        require_ex("config."..name)
    end
end

--[[
全局资源搜索路径
]]
function addSearchPath(p)
    if not p then return end
    fileIns:addSearchPath(string.format("res/%s/", p), true)
    fileIns:addSearchPath(string.format("%sres/%s/", updPath, p), true)
end

function removeSearchPath(p)
    if not p then return end
    local searchPaths = fileIns:getSearchPaths()
    for i = #searchPaths, 1, -1 do
        local v = searchPaths[i]
        if string.find(v, p) then
            table.remove(searchPaths, i)
        end
    end
    fileIns:setSearchPaths(searchPaths)
end

--[[
加载配置全局接口（分渠道）
@param string/nil   配置表名
]]
function loadConfig(cfg)
	if cfg then
		loadMarketConfig(cfg)
		return
	end
    for _, name in ipairs(ConfigGroup) do
        loadMarketConfig(name)
    end
end

loadConfig()

------------------------------------
-- 后台配置
function resetFuncList()
    if not Assist.isEmpty(FuncListServer) then
        local cfg
        for _, v in ipairs(FuncListServer) do
            cfg = FuncListConfig[v[1]]
            if cfg then
                cfg.state = v[2]
                if v[3] == 0 then
                    cfg.init_path = ""
                elseif v[3] == 1 and Assist.isEmpty(cfg.init_path) then
                    cfg.init_path = "1"
                end
            end
        end
    end
    -- 马甲包配置
    if checknumber(FuncListConfig.state(SkinFunc.id)) == 1 then
        if not FuncListSkinConfig then
            addSearchPath(SkinFunc.key)
            if isFileExist("config.FuncListSkinConfig") then
                loadConfig("FuncListSkinConfig")
            end
        end
        if FuncListSkinConfig then
            local ids = FuncListSkinConfig.getIds()
            for _, v in ipairs(ids) do
                if FuncListConfig[v] then
                    table.merge(FuncListConfig[v], FuncListSkinConfig[v])
                end
            end
        end
    else
        removeSearchPath(SkinFunc.key)
    end

    -- 配置表扩展（性能优化）
    FuncListKeyConfig = {}
    for _, v in pairs(FuncListConfig) do
    	if(type(v) ~= "function") then
    		FuncListKeyConfig[v.key] = v
    	end
    end

    FuncListKeyConfig.state = function(key, default)
        return FuncListKeyConfig[key] and FuncListKeyConfig[key].state or default or 1
    end
end

resetFuncList()
