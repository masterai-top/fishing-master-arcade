
local UIBase = require_ex("ui.base.UIBase")
local M = class("BrnnRecordUI", UIBase)

function M:ctor()
	self.funcKey = "BrnnRecordUI"
    -- self.effDark = true
    -- self.effRipple = true

    UIBase.ctor(self)
    self:init()
end

function M:init()
	self._BindWidget = {
        ["panel_touch"] = {handle=handlerSafe(self,self.onClose)},
        ["bg/resultList"] = {key="resultList"},
        ["bg/temp_item"] = {key="temp_item"},
        ["bg/txt_1"] = {key="txt_1"},
        ["bg/txt_2"] = {key="txt_2"},
        ["bg/txt_3"] = {key="txt_3"},
        ["bg/txt_4"] = {key="txt_4"},
    }
    self:initViews()
end

function M:initViews()
	local uiNode = createCsbNode("subgame/brnn/brnn_record.csb")
    self:addChild(uiNode, 1)
    self._rootNode = uiNode

    bindWidgetList(uiNode, self._BindWidget, self._widgets)
    self._widgets.temp_item:setVisible(false)

    self:updateView()
end

--胜率
function M:updateRate(recordList)
    local countList = {0,0,0,0}
    for _,v in ipairs(recordList) do
        for idx,rate in ipairs(v.result) do
            if rate > 0 then
                countList[idx] = checknumber(countList[idx]) + 1
            end
        end
    end
    local len = #recordList
    local rate
    local round = math.round
    for k,v in ipairs(countList) do
        rate = round(v/len*100)
        self._widgets["txt_"..k]:setString(rate.."%")
    end
end

function M:updateView()
    local resultList = self._widgets.resultList
    resultList:removeAllItems()

    local recordList = Game.brnnDB:getHistoryList()
    if not Assist.isEmpty(recordList) then
        self:updateRate(recordList)
        local item
        local len = #recordList
        for i=#recordList,1,-1 do
            item = self._widgets.temp_item:clone()
            self:handleItem(item,recordList[i].result,i==len)
            resultList:pushBackCustomItem(item)
        end
    end
    resultList:jumpToTop()
end

function M:handleItem(item,itemData,isNew)
    item:setVisible(true)
    local imgIcon1 = item:getChildByName("imgIcon1")
    local imgIcon2 = item:getChildByName("imgIcon2")
    local imgIcon3 = item:getChildByName("imgIcon3")
    local imgIcon4 = item:getChildByName("imgIcon4")
    local img_new = item:getChildByName("img_new")

    imgIcon1:setEnabled(itemData[1]==1)
    imgIcon2:setEnabled(itemData[2]==1)
    imgIcon3:setEnabled(itemData[3]==1)
    imgIcon4:setEnabled(itemData[4]==1)
    if isNew then
        img_new:setVisible(true)
        Game:doEffectAPI(EffType.blink,img_new,50,255,0.8)
    else
        img_new:setVisible(false)
    end
end

return M