--[[
格子对象集合
]]

local M = class("Player")

local Actor = require_ex("ui.base.Actor")

local iconList = {
	[1] = "subgame/shz/card/game_hyll_icon_",   --图标
	[0] = "subgame/shz/card/game_hyll_blurry_",   --模糊图标
}
local SpineItem = { res="subgame/shz/spine/hyll/by_hyll_1", ani= Shz_EffType.cardEff, isLoop = true}
--[[
对象
@param lobby userdata 大厅对象
@param ctrl  userdata 控制器
]]
function M:ctor(_, lobby, ctrl)
    self._lobby = lobby
    self._controller = ctrl
    self._controller:setCascadeOpacityEnabled(true)
    self:init()
end

function M:init()
    self._BindWidget = {
        ["img_win_1"] = {},
        ["img_win_2"] = {},
        ["img_blink"] = {},
        ["img_effect"]= {},
        ["img_icon"]  = {},
    }
 
    self._widgets = {}
    self:initViews()
end

function M:initViews()
    bindWidgetList(self._controller, self._BindWidget, self._widgets)
    self:itemDefaultType()
end

--[[
格子默认状态
]]
function M:itemDefaultType()
    self._widgets.img_win_1:setVisible(false)
    self._widgets.img_win_2:setVisible(false)
    self._widgets.img_blink:setVisible(false)
    self._widgets.img_effect:setVisible(false)
    --self:setSprite(1, 1)
    self:setScrollStatus(true)  --滚动状态默认true
end


--[[
    给格子唯一标示
    @param index number 标示
]]
function M:setId( index)
    self.id = index
end

--[[
    获取格子唯一标示
]]
function M:getId()
    return self.id
end

--[[
    设置格子滚动状态
]]
function M:setScrollStatus( b)
    self.scrollStatus = b
end

--[[
    获取格子滚动状态
]]
function M:getScrollStatus()
    return self.scrollStatus
end

--[[
    给格子设置图片
    @params spId  number 1.png
	@params type  number 1:正常图片  0：模糊图片
]]
function M:setSprite(spId, type)
    fitIconSize(self._widgets.img_icon, iconList[type]..spId .. ".png" )
end

function M:setDark(dark)
    if dark then
        self._controller:setOpacity(255/2)
    else
        self._controller:setOpacity(255)
    end
end

--[[
    格子特效
]]
function M:setAnim(aniId, isHide)
    if isHide then
        self._widgets.img_effect:setVisible(false)
        self._widgets.img_win_2:setVisible(false)
        if not Assist.isEmpty(self._widgets.__EFFITEM__) then
            self._widgets.__EFFITEM__:setVisible(false)
        end
        return
    end
    if Assist.isEmpty(self._widgets.__EFFITEM__) then
        self._widgets.__EFFITEM__ = Actor:new(SpineItem.res,SpineItem)
        self._widgets.img_effect:addChild(self._widgets.__EFFITEM__)
    end
    self._widgets.__EFFITEM__:changeAnimation(aniId, true, nil)
    self._widgets.__EFFITEM__:setVisible(true)
    self._widgets.img_effect:setVisible(true)
	-- self._widgets.img_blink:setVisible(true)
 --    local action = cc.RepeatForever:create(cc.RotateBy:create(1, 360))
 --    self._widgets.img_blink:runAction(action)
end

function M:clear()

end

return M