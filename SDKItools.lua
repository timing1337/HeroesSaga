
local SDKItools = {}

local SDK_CLASS_NAME = "SDKItools"
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

    SDKItools.addCallback() 添加回调处理函数
]]
function SDKItools.init()
    if sdk then return end

    local sdk_ = {callbacks = {}}
    sdk = sdk_
    local function callback(event)
        print("## SDKItools CALLBACK, event %s", tostring(event))
        -- table.foreach(sdk.callbacks,print)
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
function SDKItools.cleanup()
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
    SDKItools.addCallback("mycallback", callback)

]]
function SDKItools.addCallback(name, callback)
    sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function SDKItools.removeCallback(name)
    sdk.callbacks[name] = nil
end

--[[--

普通登录

]]
function SDKItools.login()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "login")
end
--[[--

注销

]]
function SDKItools.logout()
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout")
end
--[[--

弹出确定对话框
    state:0代表普通弹出对话框 1代表重新登录游戏框
]]
function SDKItools.messageBox(messageInfo,messageState)
    return luaoc.callStaticMethod(SDK_CLASS_NAME, "messageBox",{message = messageInfo,state = messageState})
end

--[[--

判断用户登录状态
    
]]
function SDKItools.isLogined()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
    assert(ok, string.format("SDKItools.isLogined() - call API failure, error code: %s", tostring(ret)))
    return ret
end

--[[--

获得已登录用户的信息

返回值是一个表格，包括：

-   sdk_userId
-   sdk_userName
-   sdk_sessionId
]]
function SDKItools.getUserinfo()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
    assert(ok, string.format("SDKItools.getUserinfo() - call API failure, error code: %s", tostring(ret)))
    return ret
end
--[[--

进入平台中心

]]
function SDKItools.enterPlatform()
    onEnterPlatform()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterPlatform")
    if not ok then onLeavePlatform() end
    assert(ok, string.format("SDKItools.enterPlatform() - call API failure, error code: %s", tostring(ret)))
end
--[[--

支付
-   orderIdCom 订单号
-   amount 金钱的数量
]]
function SDKItools.setPayViewAmount(orderIdCom,amount, description)
    onEnterPlatform()
    local args = {}
    args["orderIdCom"] = orderIdCom
    args["amount"] = amount
    args["description"] = description
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "setPayViewAmount", args)
    if not ok then onLeavePlatform() end
    return ret
end

function SDKItools.localNotification(message, delay)
    assert(type(message) == "string", format("SDKItools.localNotification() - invalid message %s", tostring(message)))
    assert(type(delay) == "number" and delay > 0, format("SDKItools.localNotification() - invalid delay %s", tostring(delay)))
    local args = {message = message, delay = delay}
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "localNotification", args)
    assert(ok, string.format("SDKItools.localNotification() - call API failure, error code: %s", tostring(ret)))
end

function SDKItools.cleanLocalNotification()
    local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "cleanLocalNotification", args)
    assert(ok, string.format("SDKItools.cleanLocalNotification() - call API failure, error code: %s", tostring(ret)))
end

return SDKItools
