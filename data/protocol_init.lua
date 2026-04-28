--[[
协议文件
协议分模块，这里只放模块加载前需要用到的协议
]]

slg_cmd = {}

slg_protocol = {}

slg_protocol["c2s_chat_gm"] = {
[1] = {name = "content", type = "", unit = 1},
}

slg_protocol["s2c_chat_gm"] = {
[1] = {name = "result", type = "", unit = 1},
}

slg_protocol["s2c_chat_broadcast"] = {
[1] = {name = "type", type = "", unit = 1},
[2] = {name = "goods_list", type = "proto_chat_goods_info", unit = 2},
[3] = {name = "content", type = "", unit = 1},
}

--proto_88_global.hrl
---------------------------------------------------------

slg_protocol["s2c_global_reload"] = {
[1] = {name = "gameid", type = "", unit = 1},
}

slg_protocol["s2c_global_tips"] = {
[1] = {name = "ret_code", type = "", unit = 1},
[2] = {name = "kickout", type = "", unit = 1},
}

slg_protocol["proto_game_info"] = {
[1] = {name = "gameid", type = "", unit = 1},
[2] = {name = "cd", type = "", unit = 1},
}

slg_protocol["c2s_global_gamecd"] = {
}

slg_protocol["s2c_global_gamecd"] = {
[1] = {name = "cd_list", type = "proto_game_info", unit = 2},
}

---------------------------------------------------------

slg_cmd.global = {
	["reload"] 		= {88000, "s2c_global_reload"},
	["tips"] 		= {88001, "s2c_global_tips"},
	["gamecd"] 		= {88002, "s2c_global_gamecd"},
}
