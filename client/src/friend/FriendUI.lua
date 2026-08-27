--[[
好友主界面
]]

local UIBase = require_ex("ui.base.UIBase")
local M = class("FriendUI", UIBase)

-- 栏目数量
local TabNum = 4
-- 一次性初始化列表数量
local InitCount = 8
-- 推荐冷却时间
local RecommendCD = 3
-- 单次显示推荐数量限制
local RecommendLimit = 6
-- 文本输入框占位颜色
local PlaceholdColor = "#9ec3ff"

--[[
@param tabIdx   number  初始栏目
]]
function M:ctor(tabIdx)
    self.funcKey = "friend"
    self.effRipple = true
    
    UIBase.ctor(self)
    self:init(tabIdx)
end

function M:init(tabIdx)
    self._BindWidget = {
        ["panel"] = {},
        ["panel_touch"] = {handle = handler(self, self.onClose)},
        ["panel/btnClose"] = {handle = handler(self, self.onClose)},
        ["panel/lv"] = {key = "lv_list"},

        ["panel/cb1"] = {key = "cb_tab1"},
        ["panel/cb2"] = {key = "cb_tab2"},
        ["panel/cb3"] = {key = "cb_tab3"},
        ["panel/cb4"] = {key = "cb_tab4"},

        ["panel_search"] = {},
        ["panel_search/TextField_searchid"] = {key = "tf_searchID"},
        ["panel_search/Button_search"] = {key = "btn_search", handle = handler(self, self.onSearch)},
        ["panel_search/btn_recommend"] = {key = "btn_recommend", handle = handler(self, self.onRecommend)},
        ["panel_search/lv_recommend"] = {key = "lv_recommend"},

        ["panel_count"] = {},
        ["panel_count/text_count"] = {key = "text_count"},

        ["panel_empty"] = {},

        ["item1"] = {},
        ["item2"] = {},
        ["item3"] = {},
        ["temp_recommend"] = {},
    }

    self._tab = {}
    self._currTab = tabIdx or 1
    self._listData = {}
    self._initIdx = 1
    self._recommendBtn = {}

    self:initViews()
end

function M:initViews()
    local uiNode = createCsbNode("ui/friend/main.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)

    if self._widgets.tf_searchID then
        setTFPlaceColor(self._widgets.tf_searchID, PlaceholdColor)
    end

    for i = 1, TabNum do
        local cb = self._widgets["cb_tab"..i]
        local args = {
            parent = self._rootNode,
            txtNormal = cb:getChildByName("txt"),
            txtSelected = cb:getChildByName("txtFocus"),
        }
        self._tab[i] = require_ex("lib.UICheckBoxEx").new(cb, args)

        local img_red = cb:getChildByName("Image_red")
        if img_red then
            img_red:setVisible(Game.friendDB:getTabRedPoint(i))
        end
    end

    local args = {default = self._currTab, clickCallback = handler(self, self.onTab)}
    require_ex("lib.UIRadioGroupEx").new(self._tab, args)

    self._widgets.lv_list:setScrollBarEnabled(true)
    sideScrollBar(self._widgets.lv_list)

    self:initTab()
end

--------------------------------------
-- 根据栏目填充右侧内容
function M:initTab(tabIdx)
    self:unscheduleUpdate()

    tabIdx = tabIdx or self._currTab

    Game.friendDB:setRedPoint(false, tabIdx)
    local cb = self._widgets["cb_tab"..tabIdx]
    local img_red = cb:getChildByName("Image_red")
    if img_red then
        img_red:setVisible(false)
    end

    self._widgets.lv_list:stopAllActions()
    self._widgets.lv_list:removeAllItems()
    if self._widgets.panel_search then
        self._widgets.panel_search:setVisible(false)
    end

    if tabIdx == FriendTab.search then
        -- 好友搜索
        self._widgets.tf_searchID:setString("")
        self._widgets.panel_search:setVisible(true)
        Game.friendCom:onRecommend(handler(self, self.updateRecommend))

        if self._widgets.panel_empty then
            self._widgets.panel_empty:setVisible(false)
        end
        return
    end

    local list = Game.friendDB:getList(tabIdx)
    if not list or #list == 0 then
        --数据为空
        if self._widgets.panel_empty then
            self._widgets.panel_empty:setVisible(true)
        end
        return
    end
    if self._widgets.panel_empty then
        self._widgets.panel_empty:setVisible(false)
    end

    self._listData = list
    local amount = #list
    local count = Number.min(amount, InitCount)
    for i=1,count do
        self:addItem(i)
    end

    if count < amount then
        self._initIdx = count + 1
        self:scheduleUpdate()
    end

    self._widgets.lv_list:jumpToTop()
end

function M:addItem(idx, tabIdx)
    idx = idx or self._initIdx
    tabIdx = tabIdx or self._currTab

    local v = self._listData[idx]
    local item = self._widgets["item"..tabIdx]:clone()
    local img_head, txt_name, btn_state, btn_del, btn_chat, txt_chat, txt_time, btn_accept, btn_refuse

    img_head = item:getChildByName("Image_head")
    txt_name = item:getChildByName("txtName")
    if tabIdx == FriendTab.friend then
        btn_state = item:getChildByName("btn_state")
        btn_del = item:getChildByName("btnDel")
        btn_chat = item:getChildByName("btnChat")
    elseif tabIdx == FriendTab.message then
        txt_chat = item:getChildByName("txtContent")
        txt_time = item:getChildByName("txtTime")
        btn_del = item:getChildByName("btnDel")
        btn_chat = item:getChildByName("btnChat")
    elseif tabIdx == FriendTab.apply then
        btn_state = item:getChildByName("btn_state")
        btn_accept = item:getChildByName("btnAccept")
        btn_refuse = item:getChildByName("btnRefuse")
    end

    Game:doPluginAPI("set", "headIcon",img_head, v.facelook)

    txt_name:setString(v.nick)
    Assist.checkTTF(txt_name)
    if btn_state then
        btn_state:setEnabled(v.online == 1)
    end
    if btn_del then
        btn_del.uData = v
        bindClickFunc(btn_del, handler(self, self.onDelete))
    end
    if btn_chat then
        if Game.friendDB:getFriendById(v.pid) then
            btn_chat.uData = v
            bindClickFunc(btn_chat, handler(self, self.onChat))
        else
            btn_chat:setEnabled(false)
        end
    end
    if txt_chat then
        txt_chat:setString(v.msg or "")
    end
    if txt_time then
        txt_time:setString(Timer:formatDateTime(v.send_time))
    end
    if btn_accept then
        btn_accept.uData = v
        bindClickFunc(btn_accept, handler(self, self.onAccept))
    end
    if btn_refuse then
        btn_refuse.uData = v
        bindClickFunc(btn_refuse, handler(self, self.onRefuse))
    end

    item.uData = v
    bindClickFunc(item, handler(self, self.onViewDetail))

    item:setVisible(true)
    self._widgets.lv_list:pushBackCustomItem(item)
end

function M:updateFunc()
    self:addItem()

    self._initIdx = self._initIdx + 1
    if self._initIdx > #self._listData then
        self:unscheduleUpdate()
    end
end

--[[
移除列表元素
]]
function M:removeItem(item)
    local idx = self._widgets.lv_list:getIndex(item)
    if idx >= 0 then
        self._widgets.lv_list:removeItem(idx)
        if #self._widgets.lv_list:getItems() == 0 and self._widgets.panel_empty then
            self._widgets.panel_empty:setVisible(true)
        end
    end
end

--[[
更新好友推荐
]]
function M:updateRecommend()
    self._widgets.lv_recommend:stopAllActions()
    self._widgets.lv_recommend:removeAllItems()
    self._recommendBtn = {}

    local data = Game.friendDB:getRecommendList()
    local cloneNode
    local BindWidget = {
        ["txt_name"] = {},
        ["txt_gold"] = {},
        ["img_head"] = {},
        ["img_online"] = {},
        ["img_offline"] = {},
        ["btn_add"] = {handle = handler(self, self.onAddFriend)},
    }
    
    for i, v in ipairs(data) do
        local idx = i % 2
        if idx == 0 then
            idx = 2
        end
        if not cloneNode or idx == 1 then
            cloneNode = self._widgets.temp_recommend:clone()
            cloneNode:setVisible(true)
            self._widgets.lv_recommend:pushBackCustomItem(cloneNode)
        end
        local item = cloneNode:getChildByName("person"..idx)
        local ws = {}
        bindWidgetList(item, BindWidget, ws)

        ws.txt_name:setString(String.toFixed(v.nick))
        Assist.checkTTF(ws.txt_name)
        ws.txt_gold:setString(v.gold)
        Game:doPluginAPI("set", "headIcon", ws.img_head, v.icon)
        ws.img_online:setVisible(v.online == 1)
        if ws.img_offline then
            ws.img_offline:setVisible(v.online ~= 1)
        end
        ws.btn_add:setTag(v.uid)
        self._recommendBtn[v.uid] = ws.btn_add

        item.uData = v
        bindClickFunc(item, handler(self, self.onViewDetail))

        item:setVisible(true)

        if RecommendLimit and i == RecommendLimit then
            break
        end
    end

    self._widgets.lv_recommend:jumpToTop()
end

----------------------------------
-- 交互
function M:onClose()
    Game.friendDB:saveMsgToLocal()
    self:destroy()
end

function M:onTab(tabIdx)
    if self._currTab ~= tabIdx then
        self._currTab = tabIdx
        self:initTab(tabIdx)
    end
end

function M:onDelete(sender)
    local v = sender.uData
    if self._currTab == FriendTab.friend then
        -- 删除好友
        showConfirmTip(Config.localize("friend_del_tip"), function()
            Game.friendCom:onDelFriend(v.pid, function()
                self:removeItem(sender:getParent())
            end)
        end)
    else
        -- 删除私信
        Game.friendCom:onDelMessage(v.pid, v.send_time, function()
            self:removeItem(sender:getParent())
        end)
    end
end

function M:onChat(sender)
    local v = sender.uData
    require_ex("ui.friend.FriendChatUI").new(v):addToScene()
end

function M:onAccept(sender)
    local v = sender.uData
    Game.friendCom:onApply(v.pid, FriendApply.accept, function()
        self:removeItem(sender:getParent())
        Game:tipMsg(Config.localize("friend_apply_accept"))
    end)
end

function M:onRefuse(sender)
    local v = sender.uData
    Game.friendCom:onApply(v.pid, FriendApply.refuse, function()
        self:removeItem(sender:getParent())
        Game:tipMsg(Config.localize("friend_apply_refuse"))
    end)
end

function M:onViewDetail(sender)
    local v = sender.uData
    if DEBUG_OFFLINE then
        Game:doPluginAPI("enter", "playerDetail", v)
        return
    end

    local uid = v.pid or v.uid
    local args
    if not Game.friendDB:getFriendById(uid) then
        args = {
            confirm_title = Config.localize("add_friend"),
            confirm_func = function(pid)
                Game.friendCom:onAddFriend(pid, function()
                    if self._recommendBtn[pid] then
                        self._recommendBtn[pid]:setVisible(false)
                    end
                end)
            end
        }
    end
    Game:doPluginAPI("send", "playerDetail", uid, args)
end

function M:onSearch()
    local txt = self._widgets.tf_searchID:getString()
    local uid = checknumber(txt)
    if uid == 0 then
        Game:tipMsg(Config.localize("friend_search_tip"))
        return
    end
    if DEBUG_OFFLINE then
        Game:tipMsg(Config.localize("friend_search_err"))
        return
    end

    local args = {
        confirm_title = Config.localize("add_friend"),
        confirm_func = function(pid)
            Game.friendCom:onAddFriend(pid, function()
                if self._recommendBtn[pid] then
                    self._recommendBtn[pid]:setVisible(false)
                end
            end)
        end
    }
    Game:doPluginAPI("send", "playerDetail", uid, args)
end

function M:onRecommend()
    if self._recommendCD then
        Game:tipMsg(Config.localize("recommend_cd"))
        return
    end
    self._recommendCD = true
    self:performWithDelay(function()
        self._recommendCD = nil
    end, RecommendCD)

    Game.friendCom:onRecommend(handler(self, self.updateRecommend))
end

function M:onAddFriend(sender)
    Game.friendCom:onAddFriend(sender:getTag(), function()
        sender:setVisible(false)
    end)
end

return M
