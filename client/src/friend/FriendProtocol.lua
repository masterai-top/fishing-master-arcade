-- [[ proto_15_friend.hrl ]] --

slg_cmd.friend = {
	["add"]     	= {15000, "s2c_add_friend_req"},	-- 申请加好友
	["apply"]		= {15001, "s2c_add_friend_rep"},	-- 回复申请
	["updData"]     = {15002, "s2c_friend_update"},		-- 好友信息更新
	["chat"]     	= {15003, "s2c_send_private_msg"},	-- 发私信
	["read"]     	= {15004, "s2c_get_private_msg"},	-- 读私信
	["del"]     	= {15005, "s2c_rm_friend"},			-- 删除好友
	["reqList"]     = {15006, "s2c_get_req_list"},		-- 申请列表
	["getData"]     = {15007, "s2c_get_friend_list"},	-- 好友列表
	["updList"]     = {15008, "s2c_req_list_update"},	-- 申请列表更新
	["recommend"]	= {15009, "s2c_recommend_list"},	-- 推荐列表
}

---------------------------------------------------------

slg_protocol["c2s_add_friend_req"] = {
[1] = {name = "pid", type = "", unit = 1},
}

slg_protocol["s2c_add_friend_req"] = {
[1] = {name = "code", type = "", unit = 1},
}

slg_protocol["c2s_add_friend_rep"] = {
[1] = {name = "pid", type = "", unit = 1},
[2] = {name = "pass", type = "", unit = 1},
}

slg_protocol["s2c_add_friend_rep"] = {
[1] = {name = "code", type = "", unit = 1},
}

slg_protocol["proto_friend_data"] = {
[1] = {name = "pid", type = "", unit = 1},
[2] = {name = "nick", type = "", unit = 1},
[3] = {name = "online", type = "", unit = 1},
[4] = {name = "other", type = "", unit = 1},
[5] = {name = "facelook", type = "", unit = 1},
}

slg_protocol["s2c_friend_update"] = {
[1] = {name = "list", type = "proto_friend_data", unit = 2},
}

slg_protocol["proto_private_msg"] = {
[1] = {name = "pid", type = "", unit = 1},
[2] = {name = "nick", type = "", unit = 1},
[3] = {name = "facelook", type = "", unit = 1},
[4] = {name = "msg", type = "", unit = 1},
[5] = {name = "send_time", type = "", unit = 1},
}

slg_protocol["c2s_send_private_msg"] = {
[1] = {name = "to_id", type = "", unit = 1},
[2] = {name = "msg", type = "", unit = 1},
}

slg_protocol["s2c_send_private_msg"] = {
[1] = {name = "code", type = "", unit = 1},
}

slg_protocol["c2s_get_private_msg"] = {
}

slg_protocol["s2c_get_private_msg"] = {
[1] = {name = "msg", type = "proto_private_msg", unit = 2},
}

slg_protocol["c2s_rm_friend"] = {
[1] = {name = "del_id", type = "", unit = 1},
}

slg_protocol["s2c_rm_friend"] = {
[1] = {name = "code", type = "", unit = 1},
[2] = {name = "del_id", type = "", unit = 1},
}

slg_protocol["proto_req_data"] = {
[1] = {name = "pid", type = "", unit = 1},
[2] = {name = "nick", type = "", unit = 1},
[3] = {name = "facelook", type = "", unit = 1},
[4] = {name = "online", type = "", unit = 1},
}

slg_protocol["c2s_get_req_list"] = {
[1] = {name = "pid", type = "", unit = 1},
}

slg_protocol["s2c_get_req_list"] = {
[1] = {name = "list", type = "proto_req_data", unit = 2},
}

slg_protocol["c2s_get_friend_list"] = {
[1] = {name = "pid", type = "", unit = 1},
}

slg_protocol["s2c_get_friend_list"] = {
[1] = {name = "list", type = "proto_friend_data", unit = 2},
}

slg_protocol["s2c_req_list_update"] = {
[1] = {name = "list", type = "proto_req_data", unit = 2},
}

slg_protocol["proto_recommend_data"] = {
[1] = {name = "uid", type = "", unit = 1},
[2] = {name = "nick", type = "", unit = 1},
[3] = {name = "icon", type = "", unit = 1},
[4] = {name = "gold", type = "", unit = 1},
[5] = {name = "online", type = "", unit = 1},
}

slg_protocol["c2s_recommend_list"] = {
}

slg_protocol["s2c_recommend_list"] = {
[1] = {name = "lists", type = "proto_recommend_data", unit = 2},
}