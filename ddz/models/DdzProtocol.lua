-- E:\fishGame\Proto\proto_96_doudizhu.hrl

---------------------------------------------------------

slg_protocol["proto_ddz_player"] = {
{name = "uid", type = "", unit = 1},
{name = "pos", type = "", unit = 1},
{name = "coin", type = "", unit = 1},
{name = "name", type = "", unit = 1},
{name = "robot", type = "", unit = 1},
}

slg_protocol["proto_ddz_seat"] = {
{name = "player_base_info", type = "proto_ddz_player", unit = 1},
{name = "cur_count", type = "", unit = 1},
{name = "cur_card_list", type = "", unit = 2},
{name = "poke_num", type = "", unit = 1},
{name = "call_score", type = "", unit = 1},
}

slg_protocol["proto_ddz_result"] = {
{name = "pos", type = "", unit = 1},
{name = "gold", type = "", unit = 1},
{name = "card_list", type = "", unit = 2},
}

slg_protocol["proto_ddz_debug"] = {
{name = "pos", type = "", unit = 1},
{name = "card_list", type = "", unit = 2},
}

slg_protocol["c2s_ddz_enter"] = {
}

slg_protocol["s2c_ddz_enter"] = {
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_ddz_start"] = {
{name = "baseScore", type = "", unit = 1},
}

slg_protocol["s2c_ddz_start"] = {
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_ddz_leave"] = {
}

slg_protocol["s2c_ddz_leave"] = {
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_ddz_seat_info"] = {
{name = "seat_list", type = "proto_ddz_player", unit = 2},
}

slg_protocol["s2c_ddz_dispatch_cards"] = {
{name = "card_data", type = "", unit = 2},
{name = "cur_seat", type = "", unit = 1},
}

slg_protocol["c2s_ddz_call"] = {
{name = "score", type = "", unit = 1},
}

slg_protocol["s2c_ddz_call"] = {
{name = "score", type = "", unit = 1},
{name = "call_player", type = "", unit = 1},
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_ddz_out_cards"] = {
{name = "count", type = "", unit = 1},
{name = "card_data", type = "", unit = 2},
{name = "pos", type = "", unit = 1},
}

slg_protocol["s2c_ddz_out_cards"] = {
{name = "count", type = "", unit = 1},
{name = "card_data", type = "", unit = 2},
{name = "out_card_player", type = "", unit = 1},
{name = "banker_out", type = "", unit = 2},
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_ddz_banker_info"] = {
{name = "banker_score", type = "", unit = 1},
{name = "banker_card", type = "", unit = 2},
{name = "banker_player", type = "", unit = 1},
}

slg_protocol["s2c_ddz_beishu"] = {
{name = "num", type = "", unit = 1},
}

slg_protocol["s2c_ddz_room_info"] = {
{name = "score", type = "", unit = 1},
{name = "seat_list", type = "proto_ddz_seat", unit = 2},
{name = "card_list", type = "", unit = 2},
{name = "cur_seat", type = "", unit = 1},
{name = "state", type = "", unit = 1},
{name = "banker_out", type = "", unit = 2},
{name = "banker_score", type = "", unit = 1},
{name = "banker_card", type = "", unit = 2},
{name = "banker_player", type = "", unit = 1},
{name = "num", type = "", unit = 1},
}

slg_protocol["c2s_ddz_pass_card"] = {
{name = "pos", type = "", unit = 1},
}

slg_protocol["s2c_ddz_pass_card"] = {
{name = "pass_player", type = "", unit = 1},
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_ddz_trustee"] = {
{name = "trustee_player", type = "", unit = 1},
}

slg_protocol["s2c_ddz_turn"] = {
{name = "pos", type = "", unit = 1},
{name = "time", type = "", unit = 1},
}

slg_protocol["c2s_ddz_cancel_trustee"] = {
}

slg_protocol["s2c_ddz_cancel_trustee"] = {
{name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_ddz_settlement"] = {
{name = "result", type = "proto_ddz_result", unit = 2},
{name = "spring", type = "", unit = 1},
}

slg_protocol["c2s_ddz_sync"] = {
}

slg_protocol["s2c_ddz_sync"] = {
{name = "ret_code", type = "", unit = 1},
{name = "state", type = "", unit = 1},
}

slg_protocol["s2c_ddz_debug"] = {
{name = "card_info", type = "proto_ddz_debug", unit = 2},
}

---------------------------------------------------------

slg_cmd.ddz = {
	["ddz_enter"] = {96001, "s2c_ddz_enter"},
	["ddz_start"] = {96002, "s2c_ddz_start"},
	["ddz_leave"] = {96003, "s2c_ddz_leave"},
	["ddz_seat_info"] = {96014, "s2c_ddz_seat_info"},
	["ddz_dispatch_cards"] = {96004, "s2c_ddz_dispatch_cards"},
	["ddz_call"] = {96005, "s2c_ddz_call"},
	["ddz_out_cards"] = {96006, "s2c_ddz_out_cards"},
	["ddz_banker_info"] = {96007, "s2c_ddz_banker_info"},
	["ddz_beishu"] = {96013, "s2c_ddz_beishu"},
	["ddz_room_info"] = {96008, "s2c_ddz_room_info"},
	["ddz_pass_card"] = {96009, "s2c_ddz_pass_card"},
	["ddz_trustee"] = {96010, "s2c_ddz_trustee"},
	["ddz_turn"] = {96011, "s2c_ddz_turn"},
	["ddz_cancel_trustee"] = {96012, "s2c_ddz_cancel_trustee"},
	["ddz_settlement"] = {96015, "s2c_ddz_settlement"},
	["ddz_sync"] = {96016, "s2c_ddz_sync"},
	["ddz_debug"] = {96017, "s2c_ddz_debug"},
}
