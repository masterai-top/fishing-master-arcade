--[[
登录注册

主要接口:
    getSavedAcntList -- 获取保存账号列表
    deleteSaved -- 删除已存账号
    setLoginInfo -- 设置当前登录账号信息
    getter/setter -- 账号，密码，记住密码，自动登录
]]

local M = class("LoginDB")
local _TAG = "LOGIN"

-- 账号类型
cc.exports.AcntState = {
    Guest = 0,
    General = 1,
    Mobile = 2
}

local DBUsrKey = "LoginSInfo"
local DBUsrLimit = 5
local DBLastServer = "last_sv"

function M:ctor()
    self:init()
    if Sdk.isMMChanel() then
        Game:registerLogoutReset(self, handler(self, self.init))
    end
end

function M:init(event)
    if event and event.data.reconnect then
        -- 重连不重置
        return
    end
    self._visitor = ""
    self._password = ""
    self._remPsw = 0
    self._autoLogin = 0
    self._savedIdx = 1
    self._sessionId = 0
    self._uid = 0

    self._msdkuid = ""
    self._openid = ""
    self._unionid = ""
    self._sdkPhone = ""
    self._shareUrl = nil
    self._shareIcon = nil
    self._shareImg = nil

    self._puid = 0
    self._deviceId = Platform.getUdid()
    self._isBinded = 1

    self._kicked = false
    self._account = ""
    self._acntName = self._account
    self._nickName = nil
    self._headUrl = nil

    self._loginToken = CHEAT_TOKEN
    self._loginAgent = SDK_AGENT_CFG.AGENT_MM
    self._loginSign = ""
    self._loginData = {}

    self._savedList = {}

    self:initFromLocalDB()
end

--[[
获取初始IP和端口
]]
function M:getDefaultServerAndPort()
    local localServer, localPort
    local defaultServer = tostring(Game.localDB:getStringForKey(DBLastServer))
    if defaultServer then
        local info = string.split(defaultServer, ":")
        localServer = info[1]
        localPort = tonumber(info[2])
    end
    if localServer and localPort then
        for _, serverInfo in ipairs(ServerDevConfig) do
            local host = cc.LuaCHelper:theHelper():getHostIP(serverInfo.host)
            if host == localServer and serverInfo.port == localPort then
                return serverInfo.host, serverInfo.port
            end
        end
    end
    if S_HOST and S_PORT then
        for _, serverInfo in ipairs(ServerDevConfig) do
            if tostring(serverInfo.host) == S_HOST and tonumber(serverInfo.port) == S_PORT then
                return S_HOST, S_PORT
            end
        end
    end
    if #ServerDevConfig > 0 then
       return ServerDevConfig[1].host, ServerDevConfig[1].port
    end
end

------------------------------------
-- 本地数据（可选服）
function M:setServer(data)
    self._server = data
end

function M:getServer()
    return self._server
end

function M:saveServerIdToLocal(server_id, server_port)
    Game.localDB:setStringForKey(DBLastServer, string.format("%s:%s", server_id, server_port))
end

function M:getServerList()
    return ServerDevConfig
end

-- 忽略后续SDK自动登录(进针对第三方联运渠道)
function M:ignoreAutoLogin()
    return not Assist.isEmpty(self._ignoreAutoLogin)
end

function M:setIgnoreAutoLogin(v)
    self._ignoreAutoLogin = v
end

function M:initFromLocalDB()
    -- 渠道分享信息
    local shareUrl = Game.localDB:getStringForKey("share_url", "")
    if not Assist.isEmpty(shareUrl) then
        self:setShareUrl(shareUrl)
        Game.localDB:setStringForKey("share_url", "")
    end
    local shareIcon = Game.localDB:getStringForKey("share_icon", "")
    if not Assist.isEmpty(shareIcon) then
        self:setShareIcon(shareIcon)
        Game.localDB:setStringForKey("share_icon", "")
    end
    -- 登录状态，上次登录没进入大厅则忽略自动登录
    self:setIgnoreAutoLogin(Game.localDB:getStringForKey("login_acnt"))

    self._savedList = {}
    if Game:funcIsOpen("sdk") and Sdk.isMMChanel() then
        return
    end
    for i = 1, DBUsrLimit do
        local info = Game.localDB:getStringForKey(DBUsrKey..i)
        if info and info ~= "" then
            self._savedList[#self._savedList + 1] = String.toTable(info)
        end
    end

    if CHEAT_TOKEN and #self._savedList == 0 then
        local uid = tostring(Number.random(10000000,99999999))
        self:setLoginInfo({acnt=uid, uid=uid}, true)
    else
        table.sort(self._savedList, function(a, b)
            return a.ltime > b.ltime
        end)
        self:setLoginInfo(self._savedList[self._savedIdx])
    end
end

--[[
获取保存账号列表
@param idx      number/nil 获取某个索引的或者全部的
@param setInfo  boolean/nil 获取某个索引信息的同时设置个人信息
]]
function M:getSavedAcntList(idx, setInfo)
    if not idx then
        return self._savedList
    else
        if setInfo then
            self:setLoginInfo(self._savedList[idx], nil, idx)
        end
        return self._savedList[idx]
    end
end

function M:addSaved()
    self._savedIdx = 1 --XXX: 只存一条记录
    local key, value, t
    local visitor = self:getVisitor()
    if self._savedList[self._savedIdx] and self._savedList[self._savedIdx].acnt == visitor then
        -- 更新
        key = self._savedList[self._savedIdx].key
        self._savedList[self._savedIdx].ltime = os.time()
        self._savedList[self._savedIdx].sign = self._loginSign
        value = Table.toString(self._savedList[self._savedIdx])
    else
        -- 添加
        if #self._savedList == DBUsrLimit then
            key = self._savedList[#self._savedList].key
        else
            key = DBUsrKey..(#self._savedList + 1)
        end
        t = {}
        t[#t+1] = string.format('key="%s"', key)
        t[#t+1] = string.format('uid="%s"', self._uid)
        t[#t+1] = string.format('msdkuid="%s"', self._msdkuid)
        t[#t+1] = string.format('openid="%s"', self._openid)
        t[#t+1] = string.format('unionid="%s"', self._unionid)
        t[#t+1] = string.format('acnt="%s"', visitor)
        t[#t+1] = string.format('psw="%s"', self._password)
        t[#t+1] = string.format('rem=%d', self._remPsw)
        t[#t+1] = string.format('auto=%d', self._autoLogin)
        t[#t+1] = string.format('agent=%d', self._loginAgent)
        t[#t+1] = string.format('sign="%s"', self._loginSign)
        t[#t+1] = string.format('ltime=%d', os.time())
        value = string.format("{%s}", table.concat(t, ","))
    end
    if key and value then
        Game.localDB:setStringForKey(key, value)
    end
end

--[[
删除某条账号记录
@param idx          number 索引
@param callback     function/nil 回调函数
]]
function M:deleteSaved(idx, callback)
    if self._savedList[idx] then
        Game.localDB:setStringForKey(self._savedList[idx].key, "")
        table.remove(self._savedList, idx)
        if callback then
            callback()
        end
    else
        if callback then
            callback(Config.localize("recorde_not"))
        else
            Game:tipMsg(Config.localize("recorde_not"), 1.5)
        end
    end
end

-------------------------------
-- 接口
function M:setLoginAgent(type)
    self._loginAgent = type
end

function M:getLoginAgent()
    return self._loginAgent
end

function M:setLoginSign(sign)
    self._loginSign = sign
end

function M:getLoginSign()
    return self._loginSign
end

function M:setLoginData(data)
    self._loginData = data
end

function M:getLoginData()
    return self._loginData
end

function M:setSessionId(sid)
    self._sessionId = sid
end

function M:getSessionId()
    return self._sessionId
end

function M:setUid(uid)
    self._uid = uid
end

function M:getUid()
    return self._uid
end

function M:setMSdkUid(uid)
    self._msdkuid = uid
end

function M:getMSdkUid()
    return self._msdkuid
end

function M:setOpenid(openid)
    self._openid = openid
end

function M:getOpenid()
    return self._openid
end

function M:setUnionId(uid)
    self._unionid = uid
end

function M:getUnionId()
    return self._unionid
end

function M:setSdkPhone(phone)
    self._sdkPhone = phone
end

function M:getSdkPhone()
    return self._sdkPhone
end

function M:setShareUrl(url)
    Log.I("ShareUrl:", url, _TAG)
    self._shareUrl = url
    if not Assist.isEmpty(self._shareUrl) and Assist.isEmpty(self._shareImg) then
        self._shareImg = "WEB"
    end
end

function M:getShareUrl()
    return self._shareUrl
end

function M:setShareIcon(icon)
    self._shareIcon = icon
end

function M:getShareIcon()
    return self._shareIcon
end

function M:setShareImg(img)
    self._shareImg = img
end

function M:getShareImg()
    return self._shareImg
end

function M:setAccount(acnt)
    self._account = acnt
end

function M:getAccount()
    return self._account or self._uid
end

function M:setVisitor(v)
    self._visitor = v or self._visitor
    if checknumber(DEBUG_SDKID) > 0 then 
        self._visitor = ChannelNameConfig.name(DEBUG_SDKID)
    end
end

function M:getVisitor()
    if Assist.isEmpty(self._visitor) then
        return self:getAccount()
    else
        return self._visitor
    end
end

function M:setAcntName(name)
    self._acntName = name
end

function M:getAcntName()
    return self._acntName
end

function M:setPassword(psw)
    self._password = psw
end

function M:getPassword()
    return self._password
end

function M:setRemPsw(rem)
    if type(rem) == "boolean" then
        rem = rem and 1 or 0
    end
    self._remPsw = rem
end

function M:getRemPsw()
    return self._remPsw == 1 and true or false
end

function M:setAutoLogin(auto)
    if type(auto) == "boolean" then
        auto = auto and 1 or 0
    end
    self._autoLogin = auto
end

function M:getAutoLogin()
    return self._autoLogin == 1 and true or false
end

function M:getDeviceId()
    return self._deviceId
end

function M:getToken()
    return CHEAT_TOKEN or self._loginToken
end

function M:setAccountType(ltype)
    self._acntType = ltype
end

function M:getAccountType()
    return self._acntType
end

function M:setBindedPhone(binded)
    self._isBinded = binded
end

function M:getAccountState()
    if self:isBindedPhone() then
        return AcntState.Mobile
    elseif Assist.isEmpty(self._password) and self._loginAgent == SDK_AGENT_CFG.AGENT_MM then
        return AcntState.Guest
    else
        return AcntState.General
    end
end

function M:isBindedPhone()
    return self._isBinded == 0
end

function M:lastLoginTime()
    if #self._savedList > 0 then
        return self._savedList[1].ltime
    end
end

function M:setPUid(puid)
    self._puid = puid
    if Platform.BuglyEnable then
        Platform.buglySetUserId(puid)
    end
end

function M:getPUid()
    return self._puid
end

function M:setNickname(nick)
    self._nickName = String.filterMarsChar(nick)
end

function M:getNickname()
    return self._nickName
end

function M:setHeadUrl(head)
    self._headUrl = head
end

function M:getHeadUrl()
    if Assist.isEmpty(self._headUrl) then
        return nil
    end
    return self._headUrl
end

function M:setKicked(k)
    self._kicked = k
end

function M:getKicked()
    return self._kicked
end

--[[
设置和保存账号记录
@param info         table/nil 账号信息（nil时为当前设置的信息）
@param save         boolean/nil 是否保存到数据库（登录时保存）
@param idx          number/nil 主动设置记录索引
]]
function M:setLoginInfo(info, save, idx)
    dump(info, _TAG)
    info = info or {}
    self._visitor = String.filterMarsChar(info.visitor) or self._visitor
    self._account = info.acnt or self._account
    self._acntName = info.name or info.acnt or self._acntName
    self._password = info.psw or self._password
    self._remPsw = info.rem or self._remPsw
    self._autoLogin = info.auto or self._autoLogin
    self._sessionId = info.sid or self._sessionId
    self._uid = info.uid or self._uid
    self._msdkuid = info.msdkuid or self._msdkuid
    self._openid = info.openid or self._openid
    self._unionid = info.unionid or self._unionid
    self._sdkPhone = info.phone or self._sdkPhone
    self._loginToken = info.token or self._loginToken
    self._loginSign = info.sign or info.token or self._loginSign
    self._loginAgent = info.agent or self._loginAgent
    self._loginData = info.data or self._loginData
    self._savedIdx = idx or self._savedIdx
    self._acntType = info.type or self._acntType
    self._isBinded = info.is_binding_phone or self._isBinded

    if info.nickName then
        self._nickName = String.toFixed(String.filterMarsChar(info.nickName), 12, "", "")
    end
    self._headUrl = info.headUrl or self._headUrl

    if info.channelId then
        Sdk.setMarketId(info.channelId)
    end
    if save and not (Game:funcIsOpen("sdk") and Sdk.isMMChanel()) then
        self:addSaved()
    end
end

return M:new()
