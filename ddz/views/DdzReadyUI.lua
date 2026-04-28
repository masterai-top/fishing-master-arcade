local UIBase = require_ex("ui.base.UIBase")
local M = class("DdzReadyUI", UIBase)

local BaseScoreTb = {}

function M:ctor(controlUI)
    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
		["pan_center/txt_base_score"] = {key = "txt_base_score"},
		["pan_center/btn_add"] = {handle = handlerSafe(self, self.onAddBaseScore)},
		["pan_center/btn_reduce"] = {handle = handlerSafe(self, self.onReduceBaseScore)},
		["pan_center/btn_start"] = {handle = handlerSafe(self, self.onStartGame)},
		["pan_center/btn_test"] = {handle = handlerSafe(self, self.onTest), hide = true}
	}
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/ddz/ddz_ready.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._bgUI = require_ex("games.ddz.views.DdzBgUI").new(self)

    self:updateScoreSelect()
end

function M:registerListenEvent()
	self:listenCustomEvent(GEvent("ddz", "exit_game"), handlerSafe(self, self.handleExitGame))
    self:listenCustomEvent(GEvent("GAME_MONEY_MODIFY_EVENT"), handlerSafe(self,self.updateScoreSelect))
end

function M:onEnter()
	UIBase.onEnter(self)
    Audio.stopAllSounds()
    Audio.playSoundConfig("DDZUI", "bgm")
end

function M:initBetList()
	local coin = Game:doPluginAPI("get", "playerCoin")
	local bet_list = BetLimitConfig.chip_list(1074)
	for _, v in ipairs(bet_list or {}) do
		local min = v[1] or 0
		local max = v[2] or -1
		if coin>=min and (coin<=max or max==-1) then
			BaseScoreTb = v[3]
			break
		end
	end
end

function M:initBaseScore()
	if Assist.isEmpty(BaseScoreTb) then return end
	self._scoreIdx = #BaseScoreTb
	local baseScore = BaseScoreTb[#BaseScoreTb]
	self._widgets.txt_base_score:setString("x"..baseScore)
end

function M:updateScoreSelect()
	self:initBetList()
	self:initBaseScore()
end

function M:onReduceBaseScore()
	self._scoreIdx = self._scoreIdx - 1
	if self._scoreIdx == 0 then
		self._scoreIdx = #BaseScoreTb
	end
	self._widgets.txt_base_score:setString("x"..BaseScoreTb[self._scoreIdx])
end

function M:onAddBaseScore()
	self._scoreIdx = self._scoreIdx + 1
	if self._scoreIdx > #BaseScoreTb then
		self._scoreIdx = self._scoreIdx - #BaseScoreTb
	end
	self._widgets.txt_base_score:setString("x"..BaseScoreTb[self._scoreIdx])
end

function M:onStartGame(sender)
	-- 进入牌局
	setTouchCD(sender,1.0)
	local baseScore = BaseScoreTb[self._scoreIdx]
	Game.ddzCom:reqStartGame(baseScore, function(info)
		Game.ddzCom:openMainUI()
		self:destroy()
	end)
end

function M:onTest()
	require_ex("games.ddz.views.DdzTestUI").new():addToScene()
end

function M:onClose()
	self._bgUI:onExitGame()
end

function M:handleExitGame()
	self:destroy()
	Game:enterScene(ENUM.SCENCE.PLATFORM)
end

return M