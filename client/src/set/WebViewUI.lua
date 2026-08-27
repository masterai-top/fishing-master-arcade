--[[
WebView独立界面
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("WebViewUI", UIBase)

function M:ctor(url, effDark, csb)
    self._url = url
    self._csb = csb

    self.effDark = effDark
    self.effRipple = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
    self._BindWidget = {
        ["panel_touch"] = {handle = handler(self, self.onClose)},
        ["Panel/bnt_back"] = {key = "btn_back", handle = handler(self, self.onClose)},
        ["Panel/Panel"] = {key = "panel_web"}
    }

    self:initViews()
    self:performWithDelay(function()
        self:openWebView(self._url, self._widgets.panel_web)
    end, 0.3)
end

function M:initViews()
    local uiNode = createCsbNode(self._csb or "ui/setting/webview.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode
    
    bindWidgetList(uiNode, self._BindWidget, self._widgets)
end

--[[
隐藏关闭按钮
]]
function M:hideBackButton()
    if self._widgets.btn_back then
        self._widgets.btn_back:setVisible(false)
    end
end

----------------------------------
-- 交互
function M:onClose()
    if self._widgets.panel_web.webview then
        self._widgets.panel_web:removeSelf()
    end
    self:destroy()
    Game.webview = nil
end

return M
