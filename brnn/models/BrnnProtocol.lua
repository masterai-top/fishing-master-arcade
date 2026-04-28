-- proto_86_nn.hrl

---------------------------------------------------------

slg_protocol["s2c_nn_card_list"] = {
[1] = {name = "card_list", type = "proto_card_info", unit = 2},
}

slg_protocol["s2c_nn_settlement"] = {
[1] = {name = "num", type = "", unit = 1},
[2] = {name = "banker", type = "proto_settle_info", unit = 1},
[3] = {name = "maxWin", type = "proto_settle_info", unit = 2},
[4] = {name = "seat_list", type = "proto_settle_info", unit = 2},
[5] = {name = "area_win", type = "", unit = 2},
[6] = {name = "water", type = "", unit = 1},
}

slg_protocol["proto_history_info"] = {
[1] = {name = "result", type = "", unit = 2},
}

slg_protocol["s2c_nn_enter"] = {
[1] = {name = "ret_code", type = "", unit = 1},
[2] = {name = "cd", type = "", unit = 1},
}

slg_protocol["s2c_nn_bet_list"] = {
[1] = {name = "mine_bet", type = "", unit = 2},
[2] = {name = "total_bet", type = "", unit = 2},
[3] = {name = "bet_list", type = "proto_bet_info", unit = 2},
}

slg_protocol["s2c_nn_sit_list"] = {
[1] = {name = "sit_list", type = "proto_seat_info", unit = 2},
}

slg_protocol["s2c_nn_chat"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_nn_standup"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_nn_goto_bank"] = {
[1] = {name = "num", type = "", unit = 1},
}

slg_protocol["s2c_nn_banker_list"] = {
[1] = {name = "banker_list", type = "proto_banker_info", unit = 2},
}

slg_protocol["c2s_nn_player_list"] = {
}

slg_protocol["s2c_nn_item_change"] = {
[1] = {name = "gold", type = "", unit = 1},
}

slg_protocol["s2c_nn_room_info"] = {
[1] = {name = "banker", type = "proto_banker_info", unit = 1},
[2] = {name = "area_list", type = "proto_area_info", unit = 2},
}

slg_protocol["s2c_nn_leave"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_nn_cancel_bank"] = {
}

slg_protocol["proto_bet_info"] = {
[1] = {name = "role_id", type = "", unit = 1},
[2] = {name = "bet_num", type = "", unit = 1},
[3] = {name = "area_id", type = "", unit = 1},
}

slg_protocol["s2c_nn_jackpot"] = {
[1] = {name = "jackpot", type = "", unit = 1},
}

slg_protocol["s2c_nn_reward_info"] = {
[1] = {name = "prize_num", type = "", unit = 1},
[2] = {name = "bonus", type = "", unit = 1},
[3] = {name = "winner", type = "proto_settle_info", unit = 1},
}

slg_protocol["proto_card_info"] = {
[1] = {name = "card_list", type = "", unit = 2},
[2] = {name = "card_type", type = "", unit = 1},
[3] = {name = "rate", type = "", unit = 1},
}

slg_protocol["s2c_nn_reward"] = {
[1] = {name = "total_reward", type = "", unit = 1},
[2] = {name = "mine_reward", type = "", unit = 1},
[3] = {name = "max_reward", type = "proto_settle_info", unit = 2},
}

slg_protocol["proto_player_info"] = {
[1] = {name = "uid", type = "", unit = 1},
[2] = {name = "name", type = "", unit = 1},
[3] = {name = "iconId", type = "", unit = 1},
[4] = {name = "vipLv", type = "", unit = 1},
[5] = {name = "gold", type = "", unit = 1},
}

slg_protocol["s2c_nn_msg"] = {
[1] = {name = "msg", type = "", unit = 1},
[2] = {name = "iconId", type = "", unit = 1},
[3] = {name = "sender", type = "", unit = 1},
[4] = {name = "to", type = "", unit = 1},
[5] = {name = "senderId", type = "", unit = 1},
}

slg_protocol["s2c_nn_reward_pool"] = {
[1] = {name = "num", type = "", unit = 1},
}

slg_protocol["c2s_nn_banker_list"] = {
}

slg_protocol["s2c_nn_add"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["proto_settle_info"] = {
[1] = {name = "uid", type = "", unit = 1},
[2] = {name = "iconId", type = "", unit = 1},
[3] = {name = "name", type = "", unit = 1},
[4] = {name = "num", type = "", unit = 1},
[5] = {name = "vipLv", type = "", unit = 1},
[6] = {name = "area_bet", type = "", unit = 2},
}

slg_protocol["c2s_nn_standup"] = {
}

slg_protocol["s2c_nn_tips"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["proto_banker_info"] = {
[1] = {name = "player", type = "proto_player_info", unit = 1},
[2] = {name = "num", type = "", unit = 1},
[3] = {name = "banker_round", type = "", unit = 1},
}

slg_protocol["s2c_nn_force_cancel_bank"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_nn_sync_data"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_nn_sync_data"] = {
}

slg_protocol["c2s_nn_reward_info"] = {
}

slg_protocol["s2c_nn_debug"] = {
[1] = {name = "msg", type = "", unit = 1},
}

slg_protocol["proto_area_info"] = {
[1] = {name = "area_id", type = "", unit = 1},
[2] = {name = "mine_bet", type = "", unit = 1},
[3] = {name = "total_bet", type = "", unit = 1},
[4] = {name = "bet_list", type = "", unit = 2},
}

slg_protocol["s2c_nn_cancel_bank"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_nn_sitdown"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["s2c_nn_history"] = {
[1] = {name = "history_list", type = "proto_history_info", unit = 2},
}

slg_protocol["s2c_nn_bet"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_nn_bet"] = {
[1] = {name = "area_id", type = "", unit = 1},
[2] = {name = "num", type = "", unit = 1},
}

slg_protocol["s2c_nn_banker_change"] = {
[1] = {name = "banker", type = "proto_banker_info", unit = 1},
}

slg_protocol["c2s_nn_chat"] = {
[1] = {name = "pos", type = "", unit = 1},
[2] = {name = "role_id", type = "", unit = 1},
[3] = {name = "msg", type = "", unit = 1},
[4] = {name = "iconId", type = "", unit = 1},
}

slg_protocol["s2c_nn_player_list"] = {
[1] = {name = "player_list", type = "proto_player_info", unit = 2},
}

slg_protocol["proto_seat_info"] = {
[1] = {name = "sitno", type = "", unit = 1},
[2] = {name = "player", type = "proto_player_info", unit = 1},
}

slg_protocol["c2s_nn_enter"] = {
[1] = {name = "game_id", type = "", unit = 1},
}

slg_protocol["s2c_nn_state_change"] = {
[1] = {name = "state", type = "", unit = 1},
[2] = {name = "lefttime", type = "", unit = 1},
}

slg_protocol["s2c_nn_goto_bank"] = {
[1] = {name = "ret_code", type = "", unit = 1},
}

slg_protocol["c2s_nn_sitdown"] = {
[1] = {name = "sitno", type = "", unit = 1},
}

slg_protocol["c2s_nn_leave"] = {
}

slg_protocol["c2s_nn_add"] = {
}

slg_protocol["c2s_nn_history"] = {
}

---------------------------------------------------------

slg_cmd.brnn = {
	["nn_card_list"] = {86012, "s2c_nn_card_list"},
	["nn_settlement"] = {86013, "s2c_nn_settlement"},
	["nn_enter"] = {86000, "s2c_nn_enter"},
	["nn_bet_list"] = {86009, "s2c_nn_bet_list"},
	["nn_sit_list"] = {86007, "s2c_nn_sit_list"},
	["nn_chat"] = {86027, "s2c_nn_chat"},
	["nn_standup"] = {86016, "s2c_nn_standup"},
	["nn_banker_list"] = {86003, "s2c_nn_banker_list"},
	["nn_item_change"] = {86021, "s2c_nn_item_change"},
	["nn_room_info"] = {86010, "s2c_nn_room_info"},
	["nn_leave"] = {86001, "s2c_nn_leave"},
	["nn_jackpot"] = {86020, "s2c_nn_jackpot"},
	["nn_reward_info"] = {86023, "s2c_nn_reward_info"},
	["nn_reward"] = {86018, "s2c_nn_reward"},
	["nn_msg"] = {86028, "s2c_nn_msg"},
	["nn_reward_pool"] = {86015, "s2c_nn_reward_pool"},
	["nn_add"] = {86026, "s2c_nn_add"},
	["nn_tips"] = {86025, "s2c_nn_tips"},
	["nn_force_cancel_bank"] = {86022, "s2c_nn_force_cancel_bank"},
	["nn_sync_data"] = {86024, "s2c_nn_sync_data"},
	["nn_debug"] = {86019, "s2c_nn_debug"},
	["nn_cancel_bank"] = {86014, "s2c_nn_cancel_bank"},
	["nn_sitdown"] = {86006, "s2c_nn_sitdown"},
	["nn_history"] = {86005, "s2c_nn_history"},
	["nn_bet"] = {86002, "s2c_nn_bet"},
	["nn_banker_change"] = {86017, "s2c_nn_banker_change"},
	["nn_player_list"] = {86008, "s2c_nn_player_list"},
	["nn_state_change"] = {86011, "s2c_nn_state_change"},
	["nn_goto_bank"] = {86004, "s2c_nn_goto_bank"},
}
