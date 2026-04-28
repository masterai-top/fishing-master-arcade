--[[
网络状态逻辑管理
]]

local M = class("NetworkManager")

function M:ctor()
    self:registerEvent()
    self:init()
end

function M:init()
    self._heartSyc = {}
    self._timeOutCnt = 0
    self._isShowBigTips = false
    self._isNetBad = false
    self._isNetClosed = false
    self._recvData = false
end

function M:registerEvent()
    Game:addEventListenerWithFixedPriority(GEvent("NET_PACKET_TIME_OUT"), handler(self, self.onReqTimeout))
    Game:addEventListenerWithFixedPriority(GEvent("NET_RECV_PACKET"), handler(self, self.onRecvData))
    Game:addEventListenerWithFixedPriority(GEvent("NET_STATE_CHANGE"), handler(self, self.onNetStateChange))
end

----------------------------------------
-- 状态相关
function M:setNetBad(value, isClosed)
    if value == false then
        self._isNetBad = false
        self._isNetClosed = false
        self._recvData = false
    else
        self._isNetBad = value
        if isClosed == true then
            self._isNetClosed = true
        end
    end
end

function M:getNetBad()
    return self._isNetBad
end

function M:getIsNetClosed()
    return self._isNetClosed
end

function M:clearEnv()
    self._isShowBigTips = false
end

function M:clearSyc()
    self._heartSyc = {}
end

function M:checkNetworkState()
    if table.nums(self._heartSyc) > 0 then
        return
    end
    Game.connectHandler:sendHeartBeat(true)
end

function M:checkNetworkState()
    self:clearSyc()
    if netCom then
        netCom.sendHeartBeat()
    end
end

function M:isRecvData()
    return self._recvData
end

function M:setRecvData(v)
    self._recvData = v
end

--------------------------------------
-- 网络状态监听回调
function M:onReqTimeout(event)
    if netCom then
        local cmd = event.data.id or 0
        local seq = event.data.seq or 0
        local ss = os.time()
        local scene = Game:getScene()
        if scene.__action__ then return end
        if cmd == ENUM.CMD.HEART_BEAT then
            Game:destroyWaitUI()
            self:showConfirmTips()
            return
        end
        scene.__action__ = scene:performWithDelay(function()
            Game:destroyWaitUI()
            self:showConfirmTips()
            scene.__action__ = nil
        end, 7)
        Game:showWaitUI(string.format("%s[%i|%i]", Config.localize("svr_is_connecting"), cmd, seq))
        netCom.sendHeartBeat(function(info)
            Game:destroyWaitUI()
            if scene.__action__ then
                scene:stopAction(scene.__action__)
                scene.__action__ = nil
            end
            if not info then
                Game:showNetCloseTips()
            else
                local tip = string.format("%s[%i|%i]", Config.localize("net_is_not_good"), cmd, seq)
                local delay = os.time() - ss
                if delay > 2 then
                    tip = string.format('%s (%s")', tip, delay)
                end
                Game:tipMsg(tip)
            end
        end)
    else
        Game:tipMsg(Config.localize("login_is_long_time_norsp"), 3)
    end
end

function M:onRecvData(event)
    --local data = event.data
    --local id = data.id
    --local seq = data.seq

    if self._isShowBigTips then
        self:setNetBad(false)
        self._heartSyc = {}
        Game:destroyNetBadUI()

        self._isShowBigTips = false
    end
end

function M:onNetStateChange(event)
    -- todo 网络状态变化处理
end

--------------------------------------
--[[
网络异常提示对话框
@param tip  string  提示信息
]]
function M:showConfirmTips(tip)
    if Game:getScenceIdx() >= ENUM.SCENCE.PLATFORM then
        Game.networkMgr:setRecvData(false)
        showConfirmTip({
            sTip = tip or Config.localize("srv_rsp_longtime"),
            fCallBack1 = function()
                self:clearEnv()
                Game:closeNetWork()
            end,
            fCallBack2 = function()
                Game:doPluginAPI("login", "out")
            end,
            delay1 = 15,
            blankClose = false,
            sLayerName = "NetBad",
            fCheck2 = function()
                return self:isRecvData()
            end,
        }, nil, ENUM.UI_Z.SYSTOP)
    else
        Game:onLoginFail()
    end
end

return M.new()