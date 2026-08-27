--[[
设置相关逻辑（交互和响应） 
]]

local M = class("SetCom")

function M:ctor()
    self:init()
end

function M:init()
    
end

--[[
打开WebView
@param 	url 	string 	URL
]]
function M:openWebView(url, effDark, csb)
    return require_ex("ui.set.WebViewUI").new(url, effDark, csb):addToScene()
end

return M:new()
