--[[
设置主界面
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("SettingUI", UIBase)

--[[
@param csbFile      string  CSB文件
@param percentPad   number  进度条偏移
]]
function M:ctor(csbFile, percentPad)
    self._percentPad = checknumber(percentPad)

    self.funcKey = "set"
    self.effDark = true
    self.effRipple = true

    UIBase.ctor(self)
    self:init(csbFile)
end

function M:init(csbFile)
    self._BindWidget = {
        ["panelTouch"] = {handle = handler(self, self.onClose)},
        ["bg/img_yue_bg/Slider_yue"] = {key = "sld_music", handle = handler(self, self.onMusicChange)},
        ["bg/img_xiao/Slider_xiao"] = {key = "sld_effect", handle = handler(self, self.onEffectChange)},
        ["bg/btn_ESQ"] = {key = "btnESQ" , handle = handler(self , self.onESQClicked)},
        ["bg/btn_yingshi"] = {handle = handler(self, self.onPrivacy)},
        ["bg/btn_fuwu"] = {key = "txt_fuwu", handle = handler(self, self.onContract)},
        ["bg/btn_shengming"] = {handle = handler(self, self.onDeclaration)},

        ["bg/panel_model"] = {key = "panel_model"},
        ["bg/panel_model/cb_model1"] = {key = "cb_model1"},
        ["bg/panel_model/cb_model2"] = {key = "cb_model2"},
    }

    self:initViews(csbFile)
end

function M:initViews(csbFile)
    if not csbFile and (not Game:funcIsOpen("exchange") or FuncListKeyConfig.state("set")==2) then
        csbFile = "ui/setting/setting_noexc.csb"
    end
    local uiNode = createCsbNode(csbFile or "ui/setting/setting.csb")
    self:addChild(uiNode, 1)
	self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    -- 音乐
    local volume = Game.setDB:getVolume() * 100
    if volume == 100 then
        self._widgets.sld_music:setSelected(true)
        self._widgets.sld_music:setXData(75+self._percentPad)
    elseif volume == 0 then
        self._widgets.sld_music:setSelected(false)
        self._widgets.sld_music:setXData(25-self._percentPad)
    end
    -- 音效
    local effectvolume = Game.setDB:getEffectsVolume() * 100
    if effectvolume == 100 then
        self._widgets.sld_effect:setSelected(true)
        self._widgets.sld_effect:setXData(75+self._percentPad)
    elseif effectvolume == 0 then
        self._widgets.sld_effect:setSelected(false)
        self._widgets.sld_effect:setXData(25-self._percentPad)
    end
    -- 模式
    if self._widgets.panel_model and self._widgets.panel_model:isVisible() then
        local cbs = {self._widgets.cb_model1, self._widgets.cb_model2}
        local args = {default=Game.setDB:getEffModel(), clickCallback=handler(self, self.onChangeModel)}
        require_ex("lib.UIRadioGroupEx").new(cbs, args)
    end
end

----------------------------------------
-- 交互
function M:onESQClicked()
    Game:doPluginAPI("enter", "help")
end

function M:onGiftClicked()
    require_ex("ui.set.ExchangeGiftUI").new():addToScene()
end

function M:onMusicChange(event)
    local sender = event.target
    local bSelected = sender:isSelected()
    local volume = bSelected and 100 or 0
    Game.setDB:setVolume(volume / 100)
end

function M:onEffectChange(event)
    local sender = event.target
    local bSelected = sender:isSelected()
    local volume = bSelected and 100 or 0
    Game.setDB:setEffectsVolume(volume / 100)
end

function M:onChangeModel(tab)
    Game.setDB:setEffModel(tab)
end

-------------------------------------------
-- 隐私策略/服务协议/金币说明
function M:onPrivacy()
    Game.setCom:openWebView(WEB_PAGE_NAME.."privacy.html")
end

function M:onContract()
    Game.setCom:openWebView(WEB_PAGE_NAME.."service.html")
end

function M:onDeclaration()
    Game.setCom:openWebView(WEB_PAGE_NAME.."gold.html")
end

return M
