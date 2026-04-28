--[[
枚举代码中要用的硬编码
]]

ENUM = {}

ENUM.ITEM_ID = {
    COIN            = 10010001,
    DIAMOND         = 10010002,
    LOTTERY	        = 10010003,
    RMB             = 10010004,
    SCORE           = 10010008,
    INGOT           = 10010017,
    RED_ENVELOP     = 20040001,  
    RED_DOT         = 20040002,
    LOCK            = 20030001,
    ICE             = 20030002,
    RAGE            = 20030003,
    SUMMON          = 20030005,
    BUGLE           = 20030007,
    RAGE_FREE       = 20030008,
    LASER           = 0,
    ENERGY          = 20070003,
    MISSILE1        = 20010001,
    MISSILE2        = 20010002,
    MISSILE3        = 20010003,
    MISSILE4        = 20010004,
    ENCHANCE        = 20070001,
    HORN            = 20060001,
	EXCHANGE_CMD    = 20070004,
    BOTTLE          = 20090001,
    UNION_EXP       = 40010001,
    UNION_CONTR     = 40010002,
    JADE            = 10010012,     -- 玉石
    BULLET          = 10010014,
    RED_PACK        = 70010001,     -- ho
    BATTLE_AXE      = 20100001,     -- 亡灵战斧
}

ENUM.ITEM_TYPE = {
    BULLET          = 2001,
    BOX             = 2002,
    HORN            = 2006,
    CANNON          = 2005,
    POISON_GAS      = 5001,
}

ENUM.EXCHANGE_ID = {
    MISSILE         = 25,
}

ENUM.ROOM_ID = {
    FIELD           = {2,3,4,6,2,2,7},
    HUNT            = 5,
    FREE_MATCH      = 101,
    ENTIRE          = 102,
    GRAND_PRIX      = 103,
}

-- 商城道具ID
ENUM.SHOP_ID = {
    ONEYUAN         = 101,  -- 1元礼包
    GUIDEGIFT       = 102,  -- 新人豪礼
    GOUP            = 103,  -- 直升礼包
    HUNT            = 104,  -- 猎魔礼包
    GOUP_MAX        = 108,  -- 直升礼包5000倍(全民独有)
    MONTHCARD       = 207,  -- 月卡
    NOBILITY        = 401,  -- 贵族礼包
    FIRSTRECHARGE   = 501,  -- 首充礼包
    HSXY_WISH_ONE   = 801,  -- 海神许愿一次
    HSXY_WISH_FIVE  = 802,  -- 海神许愿五次
    GOUP_USE_ID     = 20100002,   -- 直升礼包的背包使用ID
}
if ShopItemKeyConfig then
    local func = ShopItemKeyConfig.shopId
    if device.platform == "ios" then
        func = ShopItemKeyConfig.shopId_ios
    end
    for k, _ in pairs(ENUM.SHOP_ID) do
        local id = func(k)
        if id then
            ENUM.SHOP_ID[k] = id
        end
    end
end


-- 破产补偿
ENUM.REDRESS_ID = 100001
-- 炮倍
ENUM.CANNON_SEP_MULTI = 1000
-- 狂暴皮肤
ENUM.RAGE_SKIN_ID = 3000001


----------------------------------------
-- 前后端协议号
ENUM.CMD = {
    SERVER_INFO     = 10000,
    SERVER_LOGIN    = 10001,
    HEART_BEAT      = 10008,
}

----------------------------------------
-- 错误码
ENUM.ERR_CODE = {
    SUCC                = 0,            -- 操作成功
    DIAMONDERRTIP       = 1,            -- 钻石不足
    EXCHANGE            = 17001,        -- 兑换道具不足
    UPKEEP              = 10007003,     -- 服务器维护
    KICK_OUT            = 10007002,     -- 封号
    LOGIN_OTHER         = 10007001,     -- 顶号/踢号
    LOGIN_OTHER2        = 10006,        -- 顶号/踢号
    LIMIT_CANNON        = 80006005,     -- 经典场炮倍不足
    LIMIT_CANNON2       = 80006006,     -- 特殊场炮倍不足
    HALL_STATE          = 88888,        -- 大厅状态变化
    ACTIVITY_EMPTY      = 28000001,     -- 当前没有活动
    RANK_OPEN_ERR_TIPS  = 28000002,     -- 排行榜等级未开放提示  
    FORGE_ERR_TIPS      = 80006004,     -- 锻造道具不足提示
    MASTER_ERR_TIPS     = 86001023,     -- 锻造强化石不足提示   
	BOSSEVENT_NOUSE_DT  = 8006007,      -- boss任务不能使用弹头
    PET_SUMMON_ERR_TIPS = 31006,        -- 宠物召唤失败
    INVENTORY_SHORTAGE  = 17000004,     -- 库存不足
	INVITER_RED_PACK_ERR = 11052006,    -- 邀请者红包异常提示
    LACK_OF_COIN        = 86000003,     -- 金币不足
    LACK_OF_COIN_ENTER_GAME = 22000003, -- 金币不足，不能进入游戏
    SGZZ_MAGIC_ERR      = 90000024,     -- 只能向扮演武将的玩家和帝王发表情
    HSXY_WITH_TIMES_LIMIT  = 91000002,  -- 海神许愿次数已达上限   
    LACK_OF_JADE        = 86001003,     -- 玉石不足即魔力不足
    IN_SUBGAME          = 23000,        -- 正在小游戏中
}
-- 错误事件
ENUM.ERR_EVENT = {
    RECHARGE            = 1,            -- 充值提示
    SHOP                = 2,            -- 跳转商城
    CONFIRM             = 3,            -- 确定弹窗
    WARNING             = 4,            -- 二次提醒(充值)
    BIND                = 5,            -- 需要绑定手机
    RECH_QUICK          = 6,            -- 快充
    GOUP_GIFT           = 7,            -- 直升礼包
    SHIPPING            = 8,            -- 收货地址
    NOTICE              = 9,            -- 经典场炮倍不足
    GLOBAL_TIP          = 11,           -- 全局提示
    GLOBAL_KICKOUT      = 12,           -- 全局被踢出
}

----------------------------------------
-- 场景ID
ENUM.SCENCE = {
    LOGO        = 1,
    LOGIN       = 2,
    PLATFORM    = 3,
    PLATEFORM   = 3, --保留错误命名，兼容旧版本
}

-- 子游戏（需要特殊处理的）
ENUM.GAME = {
    BRNN        = 1020,
    DTDB        = 1051,
    ELIMINATE   = 1053,
    SGZZ        = 1061,
    WZZJ        = 1066,
    ZZMJ        = 1070,
}

----------------------------------------
-- UI层级
ENUM.UI_Z = {
    SYSTOP  = 9000,
    SYSTIP  = 8000,
    TOP     = 3000,
    TIP     = 2000,
    MSG     = 1024,
    DIALOG  = 400,
    UI      = 100,
}

----------------------------------------
-- 默认资源
ENUM.DEFAULT = {
    FONT        = "gameres/fonts/simhei.ttf",
    SPINE       = {res="gameres/general/spine/upload/dt_jiazai", ani="1"},
    TOUCH       = {res="gameres/general/spine/guangquan/dt_gq", ani="1"},
    IMAGE       = "gameres/general/board/TouMing.png",
    TIMER       = "gameres/general/board/pn_bar_15.png",
    SCREENSHOT  = "gameres/general/bg/bg_pic_4.jpg",
    CAPTURE     = "screenshot.jpg",
    MASK_CIRCLE = "mask_avt.png",
    PLACEHOLDER = "#a7c9ff",
    SHADER      =   {
                        shadow = "shadow", -- 阴影
                    },
}