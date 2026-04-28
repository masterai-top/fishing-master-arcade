local M = class("BrnnCom")

local TAG = "brnn"

local OFF_LINE = false

addGlobalEvent(TAG,"BankerListChange")           --添加监听事件
addGlobalEvent(TAG,"UpBanker")                   --上庄
addGlobalEvent(TAG,"DownBanker")                 --下庄
addGlobalEvent(TAG,"ResultInfo")                 --结算信息推送
addGlobalEvent(TAG,"CardInfo")
addGlobalEvent(TAG,"BankerChange")               --换庄
addGlobalEvent(TAG,"KickOut")                    --踢出
addGlobalEvent(TAG,"GoldChange")
addGlobalEvent(TAG,"MSGBROADCAST")               --消息广播

function M:ctor()
    netCom.ignoreWaitTipCMD(slg_cmd.brnn.nn_leave[1])
    self:init()
end

function M:init()
    local args = {}
    args.timeCounter = {}
    for k=0,4 do
        table.insert(args.timeCounter,NnstateConfig[k].timelong/1000)
    end
    Game.betMng:setParameters(args, true)

    self._DB = Game.brnnDB
    self._betUI = nil
end

function M:reset()
    self:init()
    self._DB:init()
end

function M:reqEnterGame(func_id)
    netCom.send({func_id}, slg_cmd.brnn.nn_enter[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86000 s2c_nn_enter")
        end
        if info.ret_code == 0 then
            Game.brnnDB:setFuncId(func_id)
            print("func_id:"..func_id)
            local args = {}
            args.timeCounter = {}
            for k=0,4 do
                table.insert(args.timeCounter,NnstateConfig[k].timelong/1000)
            end
            Game.betMng:setParameters(args, true)
            self._betUI = require_ex("games.brnn.views.BrnnUI").new()
            self._betUI:addToScene()
        else
            self:onExit()
            Game:enterScene(ENUM.SCENCE.PLATFORM)
            if info.cd > 0 then
                local gameName = SubgameConfig.name(func_id) or ""
                Game:tipMsg(string.format(Config.localize("entergame_tips"),info.cd,gameName))
            else
                Game:tipError(info.ret_code)
            end
        end
    end,function()
        Game:enterScene(ENUM.SCENCE.PLATFORM)
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
    end)
end

function M:reqExitGame(cb)
    netCom.send({}, slg_cmd.brnn.nn_leave[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86001 s2c_nn_leave")
        end
        self:_onExit(pack,info)
        if type(cb) == "function" then
            cb()
        end
    end,function()
        Game:dispatchCustomEvent(GEvent(TAG,"KickOut"),0)
        self:onExit()
    end)
end

function M:_onExit(_,info)
    if info.ret_code == 0 or info.ret_code == 82012 then
        Game:dispatchCustomEvent(GEvent(TAG,"KickOut"),info.ret_code)
        self:onExit()
    else
        Game:tipError(info.ret_code)
    end
end 

function M:onExit()
    self:reset()
    Game.betMng:betStop()
end

--押注
function M:reqBet(area,num,callback)
    netCom.send({area,num}, slg_cmd.brnn.nn_bet[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86002 s2c_nn_bet")
        end
        dump(info,"86002 s2c_nn_bet")
        if info.ret_code == 0 then
            if callback then
                callback(area,num)
            end
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--获取上庄列表
function M:reqGetBankerList(cb)
    netCom.send({}, slg_cmd.brnn.nn_banker_list[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86003 s2c_nn_banker_list")
        end
        self:onGetBankerList(_,info)
        if cb then
            cb()
        end
    end)
end

function M:onGetBankerList(pack,info)
    if OFF_LINE then
        dump(info,"86003 s2c_nn_banker_list")
    end
    if self._DB:background() then return end
    self._DB:setBankerList(info.banker_list)
    --事件推送
    Game:dispatchCustomEvent(GEvent("brnn","BankerListChange"))
end

--上庄
function M:reqGoToBank(gold_num,cb)
    netCom.send({gold_num}, slg_cmd.brnn.nn_goto_bank[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86004 s2c_nn_goto_bank")
        end
        if info.ret_code == 0 then
            Game.brnnDB:setInBankerQueue(true)
            Game:dispatchCustomEvent(GEvent("brnn","UpBanker"))
            if cb then
                cb()
            end
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--下庄
function M:reqCancelBank()
    netCom.send({}, slg_cmd.brnn.nn_cancel_bank[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86014 s2c_nn_cancel_bank")
        end
        if info.ret_code == 0 then
            Game.brnnDB:setInBankerQueue(false)
            Game:dispatchCustomEvent(GEvent("brnn","DownBanker"))
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--胜负走势
function M:reqHistory(cb)
    netCom.send({}, slg_cmd.brnn.nn_history[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86005 s2c_nn_history")
        end
        self._DB:setHistoryList(info.history_list)
        if cb then
            cb()
        end
    end)
end

--请求坐下
function M:reqSitDown(sitno)
    netCom.send({sitno}, slg_cmd.brnn.nn_sitdown[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86006 s2c_nn_sitdown")
        end
        if info.ret_code == 0 then
            self._DB:setSitDown(true)
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--起立
function M:reqStand(sitno)
    netCom.send({sitno}, slg_cmd.brnn.nn_standup[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86016 s2c_nn_standup")
        end
        if info.ret_code == 0 then
            self._DB:setSitDown(false)
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--玩家列表
function M:reqPlayerList(cb)
    netCom.send({}, slg_cmd.brnn.nn_player_list[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86008 s2c_nn_player_list")
        end
        self._DB:setPlayerList(info.player_list)
        if cb then
            cb()
        end
    end,function()
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
    end)
end

--上座玩家列表回调
function M:onGetSitList(pack,info)
    if OFF_LINE then
        dump(info,"86007 s2c_nn_sit_list")
    end
    if self._DB:background() then return end
    self._DB:setSitList(info.sit_list)
    if self._betUI then
        self._betUI:refreshSeatView()
    end
end

--下注列表回调
function M:onGetBetList(pack,info)
    if OFF_LINE then
        dump(info,"86009 s2c_nn_bet_list")
    end
    if self._DB:background() then return end
    self._DB:setCurBetList(info)
    if self._betUI then
        self._betUI:handleBetList(info)
    end
end

--房间信息
function M:onGetRoomInfo(pack,info)
    if OFF_LINE then
        dump(info,"86010 s2c_nn_room_info")
    end
    if self._DB:background() then return end
    self._DB:setBankerInfo(info.banker)
    self._DB:setAreaList(info.area_list)
    if self._betUI then
        self._betUI:updateRoomInfo()
    end
end

--房间状态  0:开始阶段 1:下注阶段 2:发牌阶段 3:开牌阶段 4:结算阶段
function M:onGetRoomState(pack,info)
    if OFF_LINE then
        dump(info,"86011 onGetRoomState")
    end
    if self._DB:background() then return end
    Game.betMng:changeStateIdx(info.state+1,true,math.ceil(info.lefttime/1000))
end

--开牌信息
function M:onGetCardList(pack,info)
    if OFF_LINE then
        dump(info,"86012 s2c_nn_card_list")
    end
    if self._DB:background() then return end
    self._DB:setCardInfo(info.card_list)
    -- Game:dispatchCustomEvent(GEvent(TAG,"CardInfo"))
end

--结算
function M:onGetResultInfo(pack,info)
    if OFF_LINE then
        dump(info,"86013 s2c_nn_settlement")
    end
    if self._DB:background() then return end
    self._DB:setResultInfo(info)
    -- Game:dispatchCustomEvent(GEvent(TAG,"ResultInfo"))
end

--奖池
function M:onGetRewardPool(pack,info)
    dump(info,"86015 s2c_nn_reward_pool")
end

--庄家变化
function M:onBankerChange(pack,info)
    if OFF_LINE then
        dump(info,"86017 s2c_nn_banker_change")
    end
    if self._DB:background() then return end
    local bankerInfo = self._DB:getBankerInfo()
    self._DB:setBankerInfo(info.banker)
    Game:dispatchCustomEvent(GEvent(TAG,"BankerChange"))
    if bankerInfo == nil or bankerInfo.player.uid~=info.banker.player.uid then
        self._DB:setBankerChange(true)
    end
end

--奖池开奖
function M:onReward(pack,info)
    if OFF_LINE then
        dump(info,"86018 s2c_nn_reward")
    end
    if self._DB:background() then return end
    self._DB:setJackpotReward(info)
end

--调试
function M:onJackpotDebug(pack,info)
    if OFF_LINE  then
        dump(info,"86019 s2c_nn_debug")
    end
    if self._DB:background() then return end
	Game.brnnDB:setDebugInfo(info)
    if self._betUI then
        self._betUI:showDebugInfo()
    end
end

--奖池变化
function M:onJackpotChange(pack,info)
    if OFF_LINE then
        dump(info,"86020 s2c_nn_jackpot")
    end
    if self._DB:background() then return end
    Game.brnnDB:setJackpot(info.jackpot)
    -- if self._betUI then
    --     self._betUI:updateJackpot(info.jackpot)
    -- end
end

--金币变化
function M:onGoldChange(pack,info)
    if OFF_LINE then
        dump(info,"86021 s2c_nn_item_change")
    end
    if self._DB:background() then return end
    Game.brnnDB:setCurGold(info.gold)
    Game:dispatchCustomEvent(GEvent(TAG,"GoldChange"))
    if self._betUI then
        self._betUI:updateMyGold(info.gold)
    end
end

--强制换庄
function M:onForceBankerChange(pack,info)
    if OFF_LINE then
        dump(info,"86022 s2c_nn_force_cancel_bank")
    end
    if self._DB:background() then return end
    if info.ret_code == 0 then
        if self._DB:isBanker() then
            Game:tipMsg(Config.localize("brnn_banker_exit"))
        else
            Game.brnnDB:setInBankerQueue(false)
            Game:tipMsg(Config.localize("brnn_banker_exitlist"))
        end
    elseif info.ret_code == 1 then
        Game:tipMsg(Config.localize("brnn_banker_exitauto"))
    end
end

function M:reqJackpotInfo(cb)
    netCom.send({}, slg_cmd.brnn.nn_reward_info[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86023 s2c_nn_reward_info")
        end
        self._DB:setJackpotInfo(info)
        if cb then
            cb()
        end
    end)
end

function M:reqSyncData(cb)
    netCom.send({},slg_cmd.brnn.nn_sync_data[1], function(pack,info)
        if OFF_LINE then
            dump(info,"86024 s2c_nn_sync_data")
        end
        if info.ret_code == 0 then
            if cb then
                cb()
            end
        else
            if info.ret_code == -1 then
                Game:dispatchCustomEvent(GEvent(TAG,"KickOut"),info.ret_code)
                self:onExit()
            end
            Game:tipMsg(info.ret_code)
        end
    end,function()
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
    end)
end

--输赢达到一定时弹提示
function M:onTips(pack,info)
    if self._DB:background() then return end
    if OFF_LINE then
        dump(info,"86025")
    end
    Game:tipError(info.ret_code)
end

--申请补庄
function M:reqAddBanker()
    netCom.send({},slg_cmd.brnn.nn_add[1],function(pack,info)
        if info.ret_code == 0 then

        else
            Game:tipError(info.ret_code)
        end
    end)
end

--互动表情聊天
function M:reqMagicEmoji(param)
    netCom.send({param.pos,param.role_id,param.msg,param.iconId},slg_cmd.brnn.nn_chat[1])
end

--聊天回复
function M:onReplyChat(pack,info)
    if OFF_LINE then
        dump(info,slg_cmd.brnn.nn_chat[2])
    end
    if info.ret_code == 0 then

    else
        Game:tipError(info.ret_code)
    end
end

--广播聊天
function M:onReplyMsg(pack,info)
    if OFF_LINE then
        dump(info,slg_cmd.brnn.nn_msg[2])
    end
    Game:dispatchCustomEvent(GEvent(TAG,"MSGBROADCAST"),info)
end

--充值界面
function M:openRecharge()
    Game:doPluginAPI("enter","shop")
end

--设置界面
function M:onSettingUI()
    local ui = require_ex("games.brnn.views.BrnnSettingUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

--规则帮助界面
function M:onRuleUI()
    local ui = require_ex("games.brnn.views.BrnnRuleUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

--打开个人信息
function M:onPlayerInfo(uid,gray)
    Game:doPluginAPI("send","playerDetail",uid,nil,function(player_info)
        excFuncSafe(self,"openPlayerInfo",player_info,gray)
    end)
end

function M:openPlayerInfo(player_info,gray)
    local ui = require_ex("games.brnn.views.BrnnInforUI").new(player_info,gray)
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

--打开奖池信息
function M:onBtnJackpot()
    Game.brnnCom:reqJackpotInfo(function()
        excFuncSafe(self,"openJackpotInfoUI")
    end)
end

function M:openJackpotInfoUI()
    local ui = require_ex("games.brnn.views.BrnnJackpotInfoUI").new()
    ui:addToScene(ENUM.UI_Z.DIALOG)
end

function M:openJackpotUI(cb)
    return require_ex("games.brnn.views.BrnnJackpotUI").new(cb)
end

function M:openResultUI(timeleft)
    return require_ex("games.brnn.views.BrnnResultUI").new(timeleft)
end

function M:openPlayerListUI()
    require_ex("games.brnn.views.BrnnPlayerListUI").new():addToScene()
end

function M:openBankerListUI()
    require_ex("games.brnn.views.BrnnBankerListUI").new():addToScene()
end

function M:openRecordUI()
    require_ex("games.brnn.views.BrnnRecordUI").new():addToScene()
end

return M:new()
