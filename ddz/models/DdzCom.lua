local M = class("DdzCom")
local _TAG = "ddz"

addGlobalEvent(_TAG, "exit_game")
addGlobalEvent(_TAG, "deal_card")
addGlobalEvent(_TAG, "call")
addGlobalEvent(_TAG, 'out_cards')
addGlobalEvent(_TAG, "define_banker")
addGlobalEvent(_TAG, "pass_card")
addGlobalEvent(_TAG, "cancel_trustee")
addGlobalEvent(_TAG, "trustee")
addGlobalEvent(_TAG, "turn")
addGlobalEvent(_TAG, "settlement")
addGlobalEvent(_TAG, "debug_info")
addGlobalEvent(_TAG, "sync_data")
addGlobalEvent(_TAG, "bei_shu")
addGlobalEvent(_TAG, "countdown_finish")
addGlobalEvent(_TAG, "touch_bg")

local function _buildTag(proto)
	return proto[1].." "..proto[2] 
end

function M:ctor()

end

function M:reqEnterRoom()
	if Game.DdzUtilTest then
		self:openReadyUI()
		return
	end
	netCom.send({}, slg_cmd.ddz.ddz_enter[1], function(pack, info)
		dump(info,  _buildTag(slg_cmd.ddz.ddz_enter))
		if info.ret_code == 0 then
			if Game.ddzDB:isReconnect() then
				self:openMainUI()
			else
				self:openReadyUI()
			end
		else
			Game:tipError(info.ret_code)
		end
	end, 
	function()
		Game:enterScene(ENUM.SCENCE.PLATFORM)
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
	end)
end

function M:reqStartGame(baseScore, cb)
	if Game.DdzUtilTest then 
		self:openMainUI()
		return 
	end
	netCom.send({baseScore}, slg_cmd.ddz.ddz_start[1], function(pack, info)
		dump(info, _buildTag(slg_cmd.ddz.ddz_start))
		if info.ret_code == 0 then
			Game.ddzDB:setBaseScore(baseScore)
			
			if type(cb) == "function" then
				cb(info)
			end
		else
			Game:tipError(info.ret_code)
		end
	end)
end

function M:reqExitGame()
	netCom.send({}, slg_cmd.ddz.ddz_leave[1])
end

-- 叫分
function M:reqCall(score)
	netCom.send({score}, slg_cmd.ddz.ddz_call[1])
end

-- 不出牌
function M:reqPass(pos)
	netCom.send({pos}, slg_cmd.ddz.ddz_pass_card[1])
end

-- 取消托管
function M:reqCancelTrustee()
	netCom.send({}, slg_cmd.ddz.ddz_cancel_trustee[1], function(pack, info)
		dump(info, _buildTag(slg_cmd.ddz.ddz_cancel_trustee))
		if info.ret_code == 0 then
			Game.ddzDB:setTuoguan(false)
			Game:dispatchCustomEvent(GEvent(_TAG, "cancel_trustee"))
		else
			Game:tipError(info.ret_code)
		end
	end)
end

-- 出牌
function M:reqOutCards(card_num, card_data, pos)
	netCom.send({card_num, card_num, card_data, pos}, slg_cmd.ddz.ddz_out_cards[1])
end

-- 同步数据
function M:reqSyncData()
	netCom.send({}, slg_cmd.ddz.ddz_sync[1], function(pack, info)
		if info.ret_code == 0 then
			dump(info, _buildTag(slg_cmd.ddz.ddz_sync))
			Game.ddzDB:setTuoguan(false)
			Game:dispatchCustomEvent(GEvent(_TAG, "sync_data"), info.state)
		else
			Game:tipError(info.ret_code)
		end
	end,function()
        Game:tipMsg(Config.localize("login_is_long_time_norsp"))
    end)
end

function M:onLeaveNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_leave))
	if info.ret_code == 0 then
		Game:dispatchCustomEvent(GEvent(_TAG, "exit_game"))
	else
		Game:tipError(info.ret_code)
	end
end

function M:onDispatchCardNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_dispatch_cards))
	if Game.ddzDB:background() then return end
	Game.ddzDB:setOriginPokesData(info.card_data)
	Game.ddzDB:setGameState(2)
	Game:dispatchCustomEvent(GEvent(_TAG, "deal_card"))
end

function M:onCallNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_call))
	if Game.ddzDB:background() then return end
	if info.ret_code == 0 then
		Game.ddzDB:setCallInfo(info)
		Game:dispatchCustomEvent(GEvent(_TAG, "call"), info)
	else
		Game:tipError(info.ret_code)
	end
end

function M:onOutCardsNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_out_cards))
	if Game.ddzDB:background() then return end
	if info.ret_code == 0 then
		Game.ddzDB:setBankerOut(info.banker_out)
		Game:dispatchCustomEvent(GEvent(_TAG, "out_cards"), info)
	else
		Game:tipError(info.ret_code)
	end
end

function M:onBankerInfoNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_banker_info))
	if Game.ddzDB:background() then return end
	Game.ddzDB:setBankerInfo(info)
	Game.ddzDB:setGameState(0)
	Game:dispatchCustomEvent(GEvent(_TAG, "define_banker"))
end

function M:onRoomInfoNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_room_info))
	Game.ddzDB:setRoomInfo(info)
	-- Game:dispatchCustomEvent(GEvent(_TAG, "reconnect_room_info"), info)
end

function M:onPassCardNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_pass_card))
	if Game.ddzDB:background() then return end
	if info.ret_code == 0 then
		Game:dispatchCustomEvent(GEvent(_TAG, "pass_card"), info)
	else
		Game:tipMsg(info.ret_code)
	end
end

function M:onTrusteeNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_trustee))
	if Game.ddzDB:background() then return end
	if Game.ddzDB:convertToClientPos(info.trustee_player) == 1 then
		Game.ddzDB:setTuoguan(true)
	end
	Game:dispatchCustomEvent(GEvent(_TAG, "trustee"), info)
end

function M:onTurnNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_turn))
	if Game.ddzDB:background() then return end
	Game:dispatchCustomEvent(GEvent(_TAG, "turn"), info)
end

function M:onSettlementNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_settlement))
	if Game.ddzDB:background() then return end
	Game.ddzDB:setSettlement(info)
	Game.ddzDB:setGameState(1)
	Game:dispatchCustomEvent(GEvent(_TAG, "settlement"))
end

function M:onDebugInfoNotify(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_debug))
	Game.ddzDB:setDebugInfo(info)
	Game:dispatchCustomEvent(GEvent(_TAG, "debug_info"))
end

function M:onBeishuUpdate(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_beishu))
	if Game.ddzDB:background() then return end
	Game.ddzDB:setBeishu(info.num)
	Game:dispatchCustomEvent(GEvent(_TAG, "bei_shu"))
end

function M:onSeatInfo(pack, info)
	dump(info, _buildTag(slg_cmd.ddz.ddz_seat_info))
	if Game.ddzDB:background() then return end
	Game.ddzDB:setPlayersInfo(info.seat_list)
end
-------------------------------------------------------------
-- 界面接口
function M:openMainUI()
	local ui = require_ex("games.ddz.views.DdzMainUI").new()
	ui:addToScene()
	return ui
end

function M:openReadyUI()
	local ui = require_ex("games.ddz.views.DdzReadyUI").new()
	ui:addToScene()
	return ui
end

return M:new()