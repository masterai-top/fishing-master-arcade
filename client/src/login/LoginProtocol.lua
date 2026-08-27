-- proto_10_login.hrl

slg_cmd.login = {
	["gate"]		= {10000, "s2c_select_server"},		-- 连接Gate服获取游戏服
	["login"]		= {10001, "s2c_account_login"},		-- 登入游戏服
	["logout"]		= {10007, "s2c_account_logout"},	-- 登出游戏服
	["heartBeat"]	= {10008, "s2c_heart_beat"},		-- 心跳
	["upkeepTips"]	= {10009, "s2c_svr_count_down"},	-- 服务器维护提示
}

---------------------------------------------------------

slg_protocol["c2s_select_server"] = {
[1] = {name = "agent", type = "", unit = 1},
[2] = {name = "account_id", type = "", unit = 1},
[3] = {name = "token", type = "", unit = 1},
}

slg_protocol["s2c_select_server"] = {
[1] = {name = "ip", type = "", unit = 1},
[2] = {name = "port", type = "", unit = 1},
[3] = {name = "timestamp", type = "", unit = 1},
[4] = {name = "token", type = "", unit = 1},
[5] = {name = "code", type = "", unit = 1},
}

slg_protocol["c2s_account_login"] = {
[1] = {name = "tick", type = "", unit = 1},
[2] = {name = "sign", type = "", unit = 1},
[3] = {name = "version", type = "", unit = 1},
[4] = {name = "agent", type = "", unit = 1},
[5] = {name = "account_id", type = "", unit = 1},
[6] = {name = "accname", type = "", unit = 1},
[7] = {name = "nick", type = "", unit = 1},
[8] = {name = "facelook", type = "", unit = 1},
[9] = {name = "channel", type = "", unit = 1},
[10] = {name = "device", type = "", unit = 1},
[11] = {name = "did", type = "", unit = 1},
[12] = {name = "timestamp", type = "", unit = 1},
[13] = {name = "token", type = "", unit = 1},
[14] = {name = "sdk_id", type = "", unit = 1},
[15] = {name = "union_id", type = "", unit = 1},
[16] = {name = "open_id", type = "", unit = 1},
[17] = {name = "phone", type = "", unit = 1},
}

slg_protocol["s2c_account_login"] = {
[1] = {name = "reason", type = "", unit = 1},
[2] = {name = "tick", type = "", unit = 1},
[3] = {name = "uid", type = "", unit = 1},
}

slg_protocol["c2s_account_register"] = {
[1] = {name = "version", type = "", unit = 1},
[2] = {name = "type", type = "", unit = 1},
[3] = {name = "reg_name", type = "", unit = 1},
[4] = {name = "password", type = "", unit = 1},
[5] = {name = "code", type = "", unit = 1},
[6] = {name = "device", type = "", unit = 1},
[7] = {name = "did", type = "", unit = 1},
}

slg_protocol["s2c_account_register"] = {
[1] = {name = "reason", type = "", unit = 1},
}

slg_protocol["c2s_account_logout"] = {
[1] = {name = "reason", type = "", unit = 1},
}

slg_protocol["s2c_account_logout"] = {
[1] = {name = "code", type = "", unit = 1},
}

slg_protocol["c2s_heart_beat"] = {
[1] = {name = "syc", type = "", unit = 1},
}

slg_protocol["s2c_heart_beat"] = {
[1] = {name = "timestamp", type = "", unit = 1},
[2] = {name = "syc", type = "", unit = 1},
}

slg_protocol["s2c_svr_count_down"] = {
[1] = {name = "times", type = "", unit = 1},
}