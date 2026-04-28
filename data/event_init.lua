--[[
全局事件（监听者模式）
]]

-- 保留已经定义的事件名称，兼容旧版
-- 使用 addGlobalEvent/setGlobalEvent 接口添加新的事件名称
local G_Event = {
    NET_PACKET_TIME_OUT = "NET_PACKET_TIME_OUT",
    NET_RECV_PACKET = "NET_RECV_PACKET",
    NET_READY_RECONNECT = "NET_READY_RECONNECT",
    NET_HB_CHECK = "NET_HB_CHECK",
    NET_STATE_CHANGE = "NET_STATE_CHANGE",
    LOGIN_ERR_EVENT = "LOGIN_ERR_EVENT",
    GAME_BEFORE_LOGOUT_EVENT = "GAME_BEFORE_LOGOUT_EVENT",
    GAME_ON_LOGOUT_EVENT = "GAME_ON_LOGOUT_EVENT",
    GAME_PREPARE_FINISH = "GAME_PREPARE_FINISH",
    GAME_MONEY_MODIFY_EVENT = "GAME_MONEY_MODIFY_EVENT",
    GAME_SEX_MODIFY_EVENT = "GAME_SEX_MODIFY_EVENT",
    GAME_NICK_MODIFY_EVENT = "GAME_NICK_MODIFY_EVENT",
    GAME_LV_MODIFY_EVENT = "GAME_LV_MODIFY_EVENT",
    GAME_PERSON_MODIFY_IMG = "GAME_PERSON_MODIFY_IMG",
    GAME_RED_POINT_EVENT = "GAME_RED_POINT_EVENT",
    GAME_PERSON_MODIFY_FIRTRECHARGE = "GAME_PERSON_MODIFY_FIRTRECHARGE",
    GAME_PERSON_MODIFY_GUIDEGIFT = "GAME_PERSON_MODIFY_GUIDEGIFT",
	GAME_PERSON_MODIFY_VIP = "GAME_PERSON_MODIFY_VIP",
    CHANGE_SCENE_EVENT = "CHANGE_SCENE_EVENT",
    SYSTEM_LIMIT_ERROR = "SYSTEM_LIMIT_ERROR",
    ON_AGENT_BIND = "ON_AGENT_BIND",
    ON_PUBLIC_BIND = "ON_PUBLIC_BIND",
    ON_BAG_DATA_UPDATE = "ON_BAG_DATA_UPDATE",
    ON_XCOIN_CHANGE = "ON_XCOIN_CHANGE",
    ON_DIAMOND_CHANGE = "ON_DIAMOND_CHANGE",
    ON_LOTTERY_CHANGE = "ON_LOTTERY_CHANGE",
    ON_JADE_CHANGE = "ON_JADE_CHANGE",
    ON_INGOT_CHANGE = "ON_INGOT_CHANGE",
    ON_VIP_CHANGE = "ON_VIP_CHANGE",
    ON_VIP_EXP_CHANGE = "ON_VIP_EXP_CHANGE",
    CHAT_MARQUEE = "CHAT_MARQUEE",
    CHAT_NORMAL = "CHAT_NORMAL",
    ACTIVITY_UPDATE = "ACTIVITY_UPDATE",
    FISH_UPDATE = "FISH_UPDATE",
    MOREGAME_STATE_CHANGE = "MOREGAME_STATE_CHANGE",
    ON_DIY_HEAD_PICK = "ON_DIY_HEAD_PICK",
    ON_DIY_HEAD_UPLOAD = "ON_DIY_HEAD_UPLOAD",
    ON_SAVE_PHOTOS_ALBUM = "ON_SAVE_PHOTOS_ALBUM",
    ON_MYSTERAL_UPDATE = "ON_MYSTERAL_UPDATE",
    UI_ORIENTION_CHANGE = "UI_ORIENTION_CHANGE",
    GAME_LOST_PROTECTION = "GAME_LOST_PROTECTION",
    TASK_CHANGE = "TASK_CHANGE",
    TASK_DONE = "TASK_DONE",
    TASK_FINISH = "TASK_FINISH",
    ON_REDRESS_CHANGE = "ON_REDRESS_CHANGE",
    ON_RECHARGE_FINISH = "ON_RECHARGE_FINISH",
    ENTER_WEEK_HAPPY = "ENTER_WEEK_HAPPY",
    ACCELERATION_CHANGE = "ACCELERATION_CHANGE",
    FISH_DO_CHANGE_ROOM = "FISH_DO_CHANGE_ROOM",
    ON_SERVER_GLOBAL_RELOAD = "ON_SERVER_GLOBAL_RELOAD",
    ON_SERVER_GLOBAL_TIPS = "ON_SERVER_GLOBAL_TIPS",
    ON_SERVER_KICK_OUT_GAME = "ON_SERVER_KICK_OUT_GAME",
	
	--兼容追龙和全民(七天乐)
	GAME_PERSON_MODIFY_TMGIFT = "GAME_PERSON_MODIFY_TMGIFT",
	CLEAN_RED_POINT = "CLEAN_RED_POINT",
}


--[[
添加全局事件
@param func     string      功能模块
@param key      string/nil  关键字
@param value    string/nil  事件名称
@usage
    addGlobalEvent("bag", "update", "event_bag_update")
    addGlobalEvent("bag", "update")
    addGlobalEvent("bag_update")
]]
local function _addGlobalEvent(func, key, value)
    local k = func
    if key then
        k = string.format("%s_%s", k, key)
    end
    value = value or k
    
    G_Event[string.upper(k)] = string.upper(value)
end

--[[
获取全局事件
@param func     string      功能模块
@param key      string/nil  关键字
@return string
]]
local function _getGlobalEvent(func, key)
    local k = func
    if key then
        k = string.format("%s_%s", k, key)
    end
    return G_Event[string.upper(k)]
end

---------------------------------------------
-- 接口类全局化
cc.exports.addGlobalEvent = _addGlobalEvent
cc.exports.setGlobalEvent = _addGlobalEvent
cc.exports.GEvent = _getGlobalEvent