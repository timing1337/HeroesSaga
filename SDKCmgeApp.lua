
local SDKCmgeApp = {}

local SDK_CLASS_NAME = "SDKCmgeApp"
local sdk = nil 

local luaoc = require("luaoc")

local function onEnterPlatform()
    CCDirector:sharedDirector():pause()
end

local function onLeavePlatform()
    CCDirector:sharedDirector():resume()
end


--[[--

初始化

初始化完成后，可以使用：

    SDKCmgeApp.addCallback() 添加回调处理函数
]]
function SDKCmgeApp.init()
    if sdk then return end

    local sdk_ = {callbacks = {}}
    sdk = sdk_
    local function callback(event)
        print("## SDKCmgeApp CALLBACK, event %s", tostring(event))
        for name, callback in pairs(sdk.callbacks) do
            if name == event then
                callback(event)
            end
        end
        onLeavePlatform()
    end
    luaoc.callStaticMethod(SDK_CLASS_NAME, "registerScriptHandler", {listener = callback})
end

--[[--

清理

]]
function SDKCmgeApp.cleanup()
    sdk.callbacks = {}
    luaoc.callStaticMethod(SDK_CLASS_NAME, "unregisterScriptHandler")
end

--[[--

添加指定名称回调处理函数

用法:

    local function callback(event)
        print(event)
    end

    -- 回调函数名称用于区分不同场合使用的回调函数，removeCallback() 也需要使用同样的名称才能移除回调函数
    SDKCmgeApp.addCallback("mycallback", callback)

]]
function SDKCmgeApp.addCallback(name, callback)
    sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function SDKCmgeApp.removeCallback(name)
    sdk.callbacks[name] = nil
end

--[[--

普通登录

]]
function SDKCmgeApp.login()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "login")
end

--[[--

注销登录

]]
function SDKCmgeApp.logout()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout")
end
--[[--

弹出确定对话框
    state:0代表普通弹出对话框 1代表重新登录游戏框
]]
function SDKCmgeApp.messageBox(messageInfo,messageState)
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "messageBox",{message = messageInfo,state = messageState})
end

--[[--

判断用户登录状态
    
]]
function SDKCmgeApp.isLogined()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
    assert(ok, string.format("SDKCmgeApp.isLogined() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

获得已登录用户的信息

返回值是一个table，包括：

-   sdk_userId
-   sdk_userName
-   sdk_keyId

]]
function SDKCmgeApp.getUserinfo()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
    assert(ok, string.format("SDKCmgeApp.getUserinfo() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

支付
--serverId 服务器id
--roleName 玩家id
--rechargeAmount 数量

]]
function SDKCmgeApp.enterRechargeCenterView(serverId,roleName,rechargeAmount)
    onEnterPlatform()
    local args = {}
    args["serverId"] = tostring(serverId)
    args["roleName"] = tostring(roleName)
    args["rechargeAmount"] = tostring(rechargeAmount)
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterRechargeCenterView", args)
    if not ok then onLeavePlatform() end
    return ret
end

function SDKCmgeApp.localNotification(message, delay)
    assert(type(message) == "string", format("SDKCmgeApp.localNotification() - invalid message %s", tostring(message)))
    assert(type(delay) == "number" and delay > 0, format("SDKCmgeApp.localNotification() - invalid delay %s", tostring(delay)))
    local args = {message = message, delay = delay}
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "localNotification", args)
    assert(ok, string.format("SDKCmgeApp.localNotification() - call API failure, error code: %s", tostring(ret)))
end

function SDKCmgeApp.cleanLocalNotification()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "cleanLocalNotification", args)
    assert(ok, string.format("SDKCmgeApp.cleanLocalNotification() - call API failure, error code: %s", tostring(ret)))
end

return SDKCmgeApp
