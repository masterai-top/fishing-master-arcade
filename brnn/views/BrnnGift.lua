
local BrnnGift = class("BrnnGift")
--local interval = 0.8
local posTable = {
    {x=100,y=200},
    {x=1100,y=566},
    {x=150,y=560},
}

local faceList  = {
    {
        json= "subgame/brnn/spine/mofabiaoqing/fanqie/brnn_tomato.json",
        atlas = "subgame/brnn/spine/mofabiaoqing/fanqie/brnn_tomato.atlas",
    },
    {
        json= "subgame/brnn/spine/mofabiaoqing/jiqiang/brnn_shoot.json",
        atlas = "subgame/brnn/spine/mofabiaoqing/jiqiang/brnn_shoot.atlas",
    },
    {
        json= "subgame/brnn/spine/mofabiaoqing/meigui/brnn_rose.json",
        atlas = "subgame/brnn/spine/mofabiaoqing/meigui/brnn_rose.atlas",
    },
    {
        json= "subgame/brnn/spine/mofabiaoqing/shuitong/brnn_pail.json",
        atlas = "subgame/brnn/spine/mofabiaoqing/shuitong/brnn_pail.atlas",
    },
     {
        json= "subgame/brnn/spine/mofabiaoqing/zhadan/brnn_bomb.json",
        atlas = "subgame/brnn/spine/mofabiaoqing/zhadan/brnn_bomb.atlas",
    },
}

function BrnnGift:ctor(ctrl)
    self:init(ctrl)
end

function BrnnGift:init(ctrl)
    self.m_interval = 0
    self._playUI = ctrl
    if self._playUI and self._playUI.getPlayerPos then
        posTable = self._playUI:getPlayerPos()
    end
end

function BrnnGift:getPlayUI()
    return self._playUI
end

function BrnnGift:initSpine(info)
    local fileUtils = cc.FileUtils:getInstance()
    if  not info or
        not info.iconId or 
        not faceList[info.iconId] or
        not faceList[info.iconId].json or 
        not faceList[info.iconId].atlas or 
        not fileUtils:isFileExist(faceList[info.iconId].json) or 
        not fileUtils:isFileExist(faceList[info.iconId].atlas) then
        print("json or atlas is null")
        return 
    end

    local myUid = Game:doPluginAPI("get","playerUid")
    if myUid == info.senderId then
        info.sender = 8
    elseif Game.brnnDB:checkBanker(info.senderId) then
        info.sender = 7
    end
    
    if info.iconId ==1 then
        self:initRenFanqie(info)
    elseif info.iconId ==2 then
        self:initJiqiang(info)
    elseif info.iconId ==3 then
        self:initMeigui(info)
    elseif info.iconId ==4 then
        self:initShuitong(info)
    elseif info.iconId ==5 then
        self:initZhadan(info)
    end
end

function BrnnGift:initRenFanqie(info)
    local skeletonNode = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    skeletonNode:setAnimation(0, "1", true)
    skeletonNode:addAnimation(0, "2", false,0.7)
    skeletonNode:setMix("1", "2",0)
    skeletonNode:registerSpineEventHandler(function (event)
        if event.animation == "2" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    self:InitSpineMove(skeletonNode,info,1.5,1.0,posTable)
end

function BrnnGift:initJiqiang(info)
    local skeletonNode = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    skeletonNode:setAnimation(0,"1",false)
    -- skeletonNode:setAnimation(0, "2", true)
    local fromPos = posTable[info.sender]
    local toPos = posTable[info.to]
    self._playUI:addChild(skeletonNode,ENUM.UI_Z.TOP)
    skeletonNode:setPosition(fromPos)
    skeletonNode:registerSpineEventHandler(function(event)
        if event.animation == "1" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)
        end
    end,sp.EventType.ANIMATION_COMPLETE)
    if info.sender>=4 and info.sender<=6  then --右边座位玩家
        skeletonNode:setScaleX(-1)
        local x = toPos.x-fromPos.x
        local y = toPos.y-fromPos.y
        local angle = -Number.atan2(y,x)/math.pi*180+180
        skeletonNode:setRotation(angle)
    elseif (info.sender>=1 and info.sender<=3) or (info.sender==8) then
        local x = toPos.x-fromPos.x
        local y = toPos.y-fromPos.y
        local angle = -Number.atan2(y,x)/math.pi*180
        skeletonNode:setRotation(angle)
    elseif info.sender == -1 or info.sender == 7 then  --未上座或者庄家
        if info.to>=1 and info.to<=3 then
            skeletonNode:setScaleX(-1)
            local x = toPos.x-fromPos.x
            local y = toPos.y-fromPos.y
            local angle = -Number.atan2(y,x)/math.pi*180+180
            skeletonNode:setRotation(angle)
        elseif info.to>=4 and info.to<=6 then
            local x = toPos.x-fromPos.x
            local y = toPos.y-fromPos.y
            local angle = -Number.atan2(y,x)/math.pi*180
            skeletonNode:setRotation(angle)
        elseif info.to == 7 then --庄家
            skeletonNode:setScaleX(-1)
            local x = toPos.x-fromPos.x
            local y = toPos.y-fromPos.y
            local angle = -Number.atan2(y,x)/math.pi*180+180
            skeletonNode:setRotation(angle)
        end
    end

    local skeletonNode2 = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    skeletonNode2:setAnimation(0,"3",false)
    self._playUI:addChild(skeletonNode2,ENUM.UI_Z.TOP)
    skeletonNode2:setPosition(toPos)
    skeletonNode2:registerSpineEventHandler(function(event)
        if event.animation == "3" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode2:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode2:runAction(seq)
        end
    end,sp.EventType.ANIMATION_COMPLETE)
end

function BrnnGift:initMeigui(info)
    local skeletonNode = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    skeletonNode:setAnimation(0, "1", true)
    skeletonNode:addAnimation(0, "2", false,0.8)
    skeletonNode:setMix("1", "2",0)
    skeletonNode:registerSpineEventHandler(function (event)
        if event.animation == "2" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    self:InitSpineMove(skeletonNode,info,1,1,posTable)
end

function BrnnGift:initShuitong(info)
    local skeletonNode = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    
    skeletonNode:setAnimation(0, "1", true)
    skeletonNode:addAnimation(0, "2", false, 0.8)
    skeletonNode:setMix("1", "2",0)
    skeletonNode:registerSpineEventHandler(function (event)
        if event.animation == "2" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    skeletonNode:registerSpineEventHandler(function (event)
        if event.animation == "2" then
            if info.to >=1 and info.to<=3 then
                skeletonNode:setScaleX(-1)
            end
        end
    end, sp.EventType.ANIMATION_START)
    self:InitSpineMove(skeletonNode,info,1,1,posTable)
end

function BrnnGift:initZhadan(info)
    local skeletonNode = sp.SkeletonAnimation:create(faceList[info.iconId].json,faceList[info.iconId].atlas , 1)
    skeletonNode:setAnimation(0, "1", true)
    skeletonNode:addAnimation(0, "2", false, 0.9)
    skeletonNode:setMix("1", "2",0)
    skeletonNode:registerSpineEventHandler(function (event)
        if event.animation == "2" then
            local bgDelay = cc.DelayTime:create(0.02)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)
        end
    end, sp.EventType.ANIMATION_END)
    self:InitSpineMove(skeletonNode,info,1,1,posTable)
end

function BrnnGift:InitSpineMove(skeletonNode,info,time,scale,posT)
    local playUI = self:getPlayUI()
    posT = posT or posTable
    -- dump(posT)
    local fromPos = ccp(posT[info.sender].x, posT[info.sender].y)
    local toPos = ccp(posT[info.to].x, posT[info.to].y)

    skeletonNode:setPosition(fromPos)
    skeletonNode:setScale(scale)
    playUI:addChild(skeletonNode,ENUM.UI_Z.TOP)

    local moveAction = cc.MoveTo:create(time, toPos)
    local moveActionOut = cc.EaseExponentialOut:create(moveAction)
    skeletonNode:runAction(moveActionOut)
end

return BrnnGift
