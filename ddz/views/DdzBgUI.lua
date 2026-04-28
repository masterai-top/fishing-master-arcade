local UIBase = require_ex("ui.base.UIBase")
local Actor = require_ex("ui.base.Actor")
local M = class("DdzBgUI", UIBase)

local SpineFarmer = {res = "subgame/ddz/spine/nongmin/ddz_nm", ani = "1"}
local SpineLandLord = {res = "subgame/ddz/spine/dizhu/ddz_dz", ani = "1"}
local SpineRenwuchuxian = {res = "subgame/ddz/spine/renwuchuxian/ddz_rwcx", ani = "1"}

local FARMER_TAG = 100
local LANDLORD_TAG = 200

function M:ctor(parent)
    self._ctrl = parent
    parent:addChild(self)
    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
		["panel_touch"] = {handle=handlerSafe(self, self.onTouchBg)},

        ["pan_role"] = {},
        ["pan_role/role_spine_1"] = {key = "role_spine_1"},
        ["pan_role/role_spine_2"] = {key = "role_spine_2"},
        ["pan_role/role_spine_3"] = {key = "role_spine_3"},

        ["pan_menu/img_menu_bg"] = {key = "img_menu_bg", hide = true},
        ["pan_menu/img_menu_bg/btn_exit"] = {handle = handlerSafe(self, self.onExitGame)},
        ["pan_menu/img_menu_bg/btn_set"] = {handle = handlerSafe(self, self.onOpenSetUI)},
        -- ["pan_menu/img_menu_bg/btn_help"] = {handle = handlerSafe(self, self.onOpenHelpUI)},

        ["pan_arrow"] = {handle = handlerSafe(self, self.onShowMenu)},
        ["pan_arrow/arrow_up"] = {key = "arrow_up", hide = true},
        ["pan_arrow/arrow_down"] = {key = "arrow_down"},

        ["pan_coin/txt_coin"] = {key = "txt_coin"},
        ["pan_coin/btn_shop"] = {key = "btn_shop", handle = handlerSafe(self, self.onOpenShopUI)},

        ["pan_name/txt_name"] = {key = "txt_name"},
    }
	self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/ddz/ddz_bg.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._roleSpine = {self._widgets.role_spine_1,self._widgets.role_spine_2,self._widgets.role_spine_3}
    self:updateCoin()

    local nick = Game:doPluginAPI("get", "playerName")
    self._widgets.txt_name:setString(nick)
end

function M:registerListenEvent()
    self:listenCustomEvent(GEvent("GAME_MONEY_MODIFY_EVENT"), handlerSafe(self,self.updateCoin))
end

function M:onTouchBg()
    Game:dispatchCustomEvent(GEvent("ddz", "touch_bg"))
end

function M:updateCoin()
    local myCoin = Game:doPluginAPI("get", "playerCoin")
    self._widgets.txt_coin:setString(Number.measure(myCoin))
end

function M:onShowMenu(sender)
    self:stopAllActions()
    local showList = self._widgets.arrow_down:isVisible()
    self._widgets.arrow_up:setVisible(showList)
    self._widgets.arrow_down:setVisible(not showList)
    if showList then
        self._widgets.img_menu_bg:setVisible(true)
        Game:doEffectAPI(EffType.slideIn, self._widgets.img_menu_bg, nil, EffDir.top, 302)
    else
        self._widgets.img_menu_bg:runAction(cc.MoveBy:create(0.3, cc.p(0, 302)))
    end

    if showList then
        -- 两秒后隐藏
        self:performWithDelay(function()
            self._widgets.img_menu_bg:runAction(cc.MoveBy:create(0.3, cc.p(0, 302)))
            self._widgets.arrow_up:setVisible(false)
            self._widgets.arrow_down:setVisible(true)
        end, 2.0)
    end
end

function M:onExitGame(sender)
    -- 发退出房间请求
    Game.ddzCom:reqExitGame()
end

function M:onOpenSetUI()
    require_ex("games.ddz.views.DdzSetUI").new():addToScene()
    self:onShowMenu()
end

-- function M:onOpenHelpUI()
--     --TODO 帮助界面
--     self:onShowMenu()
-- end

-- 进入商城
function M:onOpenShopUI()
    Game:doPluginAPI("enter", "shop")
end

-- 全部显示为农民
function M:showAllFarmer()
    local function _resume(node, delayTime)
        self:performWithDelay(function()
            node:setTimeScale(1.0)
        end, delayTime)
    end
    local farmerSpine, landlordSpine, displayNode
    for k, roleSpine in ipairs(self._roleSpine) do
        farmerSpine = roleSpine:getChildByTag(FARMER_TAG)
        if Assist.isEmpty(farmerSpine) then
            farmerSpine = Actor:new(SpineFarmer.res, SpineFarmer)
            farmerSpine:setTag(FARMER_TAG)
            roleSpine:addChild(farmerSpine)
            if k>1 then
                farmerSpine:setScale(0.9)
            end
            if k%2==1 then
                farmerSpine:setFlippedX(true)
            end
        else
            farmerSpine:setVisible(true)
        end
        displayNode = farmerSpine:getDisplayNode()
        displayNode:setTimeScale(1+k/5)
        _resume(displayNode,4.0)
        landlordSpine = roleSpine:getChildByTag(LANDLORD_TAG)
        if not Assist.isEmpty(landlordSpine) then
            landlordSpine:setVisible(false)
        end
    end
end

function M:showLandLord(clientPos)
    local landlordSpine = self._roleSpine[clientPos]:getChildByTag(LANDLORD_TAG)
    if Assist.isEmpty(landlordSpine) then
        landlordSpine = Actor:new(SpineLandLord.res, SpineLandLord)
        landlordSpine:setTag(LANDLORD_TAG)
        self._roleSpine[clientPos]:addChild(landlordSpine)
        if clientPos>1 then
            landlordSpine:setScale(0.9)
        end
        if clientPos%2==1 then
            landlordSpine:setFlippedX(true)
        end
    else
        landlordSpine:setVisible(true)
    end
end

-- 特定显示为庄家
function M:ensureLandlord(clientPos, reconnectd)
    local farmerSpine = self._roleSpine[clientPos]:getChildByTag(FARMER_TAG)
    farmerSpine:setVisible(false)

    if reconnectd then
        self:showLandLord(clientPos)
    else
        local actor = Actor:new(SpineRenwuchuxian.res, SpineRenwuchuxian)
        self._roleSpine[clientPos]:addChild(actor)
        actor:setPositionY(80)
        self:performWithDelay(function()
            self:showLandLord(clientPos)
            actor:removeFromParent(true)
        end, 0.4)
    end
end

-- 隐藏充值按钮
function M:hideRechargeBtn()
    self._widgets.btn_shop:setVisible(false)
end

return M