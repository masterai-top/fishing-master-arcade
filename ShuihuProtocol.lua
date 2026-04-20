-- proto_89_shz.hrl

---------------------------------------------------------

slg_protocol["s2c_shz_result"] = {
[1] = {name = "ret", type = "", unit = 1},
[2] = {name = "win", type = "", unit = 1},
[3] = {name = "big_win", type = "", unit = 1},
[4] = {name = "icon_list", type = "", unit = 2},
}

slg_protocol["s2c_shz_enter"] = {
[1] = {name = "ret", type = "", unit = 1},
[2] = {name = "cd", type = "", unit = 1},
}

slg_protocol["c2s_shz_enter"] = {

}

slg_protocol["c2s_shz_rank"] = {
}

slg_protocol["proto_shz_rank_data"] = {
[1] = {name = "uid", type = "", unit = 1},
[2] = {name = "nick", type = "", unit = 1},
[3] = {name = "multiple", type = "", unit = 1},
[4] = {name = "win", type = "", unit = 1},
[5] = {name = "tt", type = "", unit = 1},
}

slg_protocol["s2c_shz_leave"] = {
[1] = {name = "ret", type = "", unit = 1},
}

slg_protocol["s2c_shz_rank"] = {
[1] = {name = "data", type = "proto_shz_rank_data", unit = 2},
}

slg_protocol["c2s_shz_leave"] = {
}

slg_protocol["c2s_shz_result"] = {
[1] = {name = "bet", type = "", unit = 1},
}

slg_protocol["s2c_shz_debug"] = {
[1] = {name = "data", type = "", unit = 1}
}
---------------------------------------------------------

slg_cmd.shuihu = {
	["shz_result"] = {89001, "s2c_shz_result"},
	["shz_enter"] = {89000, "s2c_shz_enter"},
	["shz_leave"] = {89002, "s2c_shz_leave"},
	["shz_rank"] = {89003, "s2c_shz_rank"},
	["shz_debug"] = {89004,"s2c_shz_debug"},
}