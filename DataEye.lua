
local DataEye = {}

local CLASS_NAME = "DataEye"
local data_sdk = nil 

local luaoc = require("luaoc")

--[[--

初始化

初始化完成后，可以使用：

    DataEye.addCallback() 添加回调处理函数
]]
function DataEye.init()
    if data_sdk then return end

    local data_sdk_ = {callbacks = {}}
    data_sdk = data_sdk_
    local function callback(event)
        print("## DataEye CALLBACK, event %s", tostring(event))
        -- table.foreach(data_sdk.callbacks,print)
        for name, callback in pairs(data_sdk.callbacks) do
            if name == event then
                callback(event)
            end
        end
    end
    luaoc.callStaticMethod(CLASS_NAME, "registerScriptHandler", {listener = callback})
end

--[[--

清理

]]
function DataEye.cleanup()
    data_sdk.callbacks = {}
    luaoc.callStaticMethod(CLASS_NAME, "unregisterScriptHandler")
end

--[[--

添加指定名称回调处理函数

用法:

    local function callback(event)
        print(event)
    end

    -- 回调函数名称用于区分不同场合使用的回调函数，removeCallback() 也需要使用同样的名称才能移除回调函数
    DataEye.addCallback("mycallback", callback)

]]
function DataEye.addCallback(name, callback)
    data_sdk.callbacks[name] = callback
end

--[[--

删除指定名称的回调函数

]]
function DataEye.removeCallback(name)
    data_sdk.callbacks[name] = nil
end

--[[--

设置账户类型
    
]]
function DataEye.setAccountType()
    local args = {}
    args["accountType"] = 0
    if getPlatForm() == "91" then
        args["accountType"] = 5
    elseif getPlatForm() == "app store" then
        args["accountType"] = 1
    elseif getPlatForm() == "pp" then
        args["accountType"] = 11
    elseif getPlatForm() == "itools" then    
        args["accountType"] = 12
    elseif getPlatForm() == "cmge" then
        args["accountType"] = 13
    elseif getPlatForm() == "cmge" then
        args["accountType"] = 14
    end
    luaoc.callStaticMethod(CLASS_NAME, "setAccountType", args)
end

--[[--

设置服务器名
    
]]
function DataEye.setGameServer(lgameServer)
    local args = {}
    args["gameServer"] = lgameServer
    return luaoc.callStaticMethod(CLASS_NAME, "setGameServer", args)
end

--[[--

设置玩家等级记录
    
]]
function DataEye.setLevel(llevel)
    local args = {}
    args["level"] = llevel
    return luaoc.callStaticMethod(CLASS_NAME, "setLevel", args)
end

--[[--

普通登录记录

]]
function DataEye.login(laccountId)
    local args = {}
    args["accountId"] = laccountId
    luaoc.callStaticMethod(CLASS_NAME, "login", args)
    DataEye.setAccountType()
end
--[[--

注销记录

]]
function DataEye.logout()
    return luaoc.callStaticMethod(CLASS_NAME, "logout")
end
--[[--

支付开始时的记录

-   orderId 订单号
-   currencyAmount 金钱的数量
]]
function DataEye.onCharge(orderId,iapId,currencyAmount,currencyType,paymentType)
    local args = {}
    args["orderId"] = orderId
    args["iapId"] = iapId
    args["currencyAmount"] = currencyAmount
    args["currencyType"] = currencyType
    args["paymentType"] = paymentType
    return luaoc.callStaticMethod(CLASS_NAME, "onCharge", args)
end
--[[--

支付成功的记录

]]
function DataEye.onChargeSuccess(orderId)
    local args = {}
    args["orderId"] = orderId
    return luaoc.callStaticMethod(CLASS_NAME, "onChargeSuccess", args)
end

--[[--

支付成功的记录

-   orderId 订单号
-   currencyAmount 金钱的数量
]]
function DataEye.onChargeOnlySuccess(currencyAmount,currencyType,paymentType)
    local args = {}
    args["currencyAmount"] = currencyAmount
    args["currencyType"] = currencyType
    args["paymentType"] = paymentType
    return luaoc.callStaticMethod(CLASS_NAME, "onChargeOnlySuccess", args)
end

return DataEye
