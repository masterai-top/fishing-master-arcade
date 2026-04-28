
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnPlayerListUI", UIBase)

--一页显示的个数
local PAGE_COUNT = 12

function M:ctor()
	self.funcKey = "BrnnPlayerListUI"
    self.effDark = true
    self._totalPage = 0

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/btn_close"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/list"] = {key="playerPage"},
        ["bg/txt_page"] = {key="txt_page"},
        ["temp_role"] = {key="temp_role"},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_player_list.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._widgets.temp_role:setVisible(false)
    --local temp_role = self._widgets.temp_role
    local playerList = Game.brnnDB:getPlayerList()
    if playerList == nil then
        Log.D("playerList is nil")
        return
    end
    local len = #playerList
    local page = math.ceil(len/PAGE_COUNT)
    self._widgets.txt_page:setString(string.format("1/%d",page))
    self._totalPage = page

    --查找自己,将自己放在第一位置，其余按金币排序
    local uid = Game:doPluginAPI("get","playerUid")
    local idx = 0
    for k,v in ipairs(playerList) do
        if v.uid == uid then
            idx = k
            break
        end
    end
    local myInfo = playerList[idx]
    table.remove(playerList,idx)
    table.sort(playerList,function(a,b)
        return a.gold > b.gold
    end)
    table.insert(playerList,1,myInfo)

    local playerPage = self._widgets.playerPage
    local pageSize = playerPage:getContentSize()
    for i=1,page do
        local layout = ccui.Layout:create()
        layout:setContentSize(pageSize)
        self:handlePage(layout,i,playerList)
        playerPage:addPage(layout)
    end

    --注册事件
    playerPage:addEventListener(function(sender,event)
        if event==ccui.PageViewEventType.turning then
            self:onScroll(sender,event)
        end
    end)
end

--处理一页显示 每行3个每列4个
function M:handlePage(layout,pageCount,playerList)
    local temp_role = self._widgets.temp_role
    local layoutSize = layout:getContentSize()
    local roleSize = temp_role:getContentSize()
    local initX = (layoutSize.width-roleSize.width*3)/4
    local intervalX = initX + roleSize.width
    local initY = (layoutSize.height-roleSize.height*4)/5
    local intervalY = initY + roleSize.height
    local beginIdx = (pageCount-1)*PAGE_COUNT+1
    local lastIdx = math.min(#playerList,pageCount*PAGE_COUNT)

    local count = 0
    local curX = initX
    local curY = layoutSize.height-initY
    for i=beginIdx,lastIdx do
        local item = temp_role:clone()
        local playerData = playerList[i]
        self:handleItem(item,playerData)
        bindClickFunc(item,function()
            Game.brnnCom:onPlayerInfo(playerData.uid,true)
        end)
        item:setPosition(cc.p(curX,curY))
        layout:addChild(item)
        curX = curX + intervalX
        count = count + 1
        if count == 3 then
            count = 0
            curX = initX
            curY = curY - intervalY
        end
    end
end

function M:handleItem(item,data)
    item:setVisible(true)
    item:setAnchorPoint(cc.p(0,1.0))
    local img_head = item:getChildByName("img_head")
    local txt_name = item:getChildByName("txt_name")
    local txt_coin = item:getChildByName("txt_coin")
    local txt_vip = item:getChildByName("txt_vip")
    local img_coin = item:getChildByName("img_coin")
    local img_jade = item:getChildByName("img_jade")
    Game:doPluginAPI("set","headIcon",img_head,data.iconId)
    txt_name:setString(data.name)
    Assist.checkTTF(txt_name)
    txt_vip:setString("VIP"..data.vipLv)
    txt_vip:setVisible(Game:funcIsOpen("vip"))
    txt_coin:setString(tostring(Number.measure(data.gold)))
    if Game.brnnDB:isBulletRoom() then
        img_coin:setVisible(false)
        img_jade:setVisible(true)
    else
        img_coin:setVisible(true)
        img_jade:setVisible(false)
    end
end

--滚动
function M:onScroll(sender)
    local idx = sender:getCurrentPageIndex()
    self._widgets.txt_page:setString(string.format("%d/%d",idx+1,self._totalPage))
end

return M