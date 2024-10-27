module(..., package.seeall)
require "shared.json"

--通用平台接口
function sendMessage(name, table, callback)
    -- body
    local temp = table or {}
    local param = json.encode(temp)
    cclog("...........sendMessage:...........name: %s", name)
    if callback ~= nil then
        local function response(str)
            -- cclog("-------- name:%s, respnse message:%s ---------", name , str)
            local data = json.decode(str, 0)
            callback(data)
        end
        if NDKHelper then
            NDKHelper:sendMessageToNative(name, param, response)
        else
            callback("none");
        end
    else
        if NDKHelper then
            NDKHelper:sendMessageToNative(name, param, nil)
        end
    end
end
--初始化过程
function init(callback)
    sendMessage("init", nil, callback)
end
--初始化
function sdkInit(callback)
   sendMessage("sdkInit", nil, callback) 
end
--登录
function logIn(callback)
    -- body
    sendMessage("logIn", nil, callback)
end
-- 进入游戏主页面
function enterMainGame()
    sendMessage("enterMainGame", nil,nil)
end
--传递用户信息
function sendInfoToPlatForm(table)
    -- body
    sendMessage("sendInfo", table, nil)
end
--传递登陆结果 
function logInResult(table)
    -- body
    sendMessage("logInResult", table, nil)
end
--注销
function logOut(callback)
    -- body
    sendMessage("logOut", nil, callback)
end
--是否已登录
function checkLogin(callback)
    sendMessage("isLogined", nil, callback)
end
--登录后
function onLogin(username)
   local temp = {}
   temp.username = username
   sendMessage("onLogin",temp) 
end
--显示浮动按钮
function showFloatBar()
   sendMessage("showFloatBar",nil)  
end
--注销后
function onLogout()
   sendMessage("onLogin",nil) 
end
--退出游戏   个别平台需要做特殊操作
function exitGame()
   sendMessage("exitGame",nil) 
end
--级别变后
function onUserLevelChanged(level)
   local temp = {}
   temp.level = level
   sendMessage("onUserLevelChanged",temp)
end
--获得创建的角色名
function getUserName(name)
   local temp = {}
   temp.name = name
   sendMessage("getUserName",temp)
end
--开始支付
function onCharge(params,paymentType)
    local temp = {}
    temp.order = params.order
    temp.productId = params.productId
    temp.productPrice = params.productPrice
    temp.currencyType = params.currencyType
    temp.paymentType = paymentType
    sendMessage("onCharge",temp)
end
--设置服务器
function setGameServer(server)
    local temp = {}
    temp.server = server
    sendMessage("setGameServer",temp) 
end
--支付成功
function paySuccess(order)
    local temp = {}
    temp.order = order
    sendMessage("paySuccess",temp)
end

function platformExit(callback)
    sendMessage("platformExit", nil, callback) 
end
--购买
function buyProduct(item, callback)
    -- body
    sendMessage("buyProduct", item, callback)
end

--用于bi统计
function biRecord(event, table)
    -- body
    local temp = {}
    temp.event = event
    temp.data = table or {}

    sendMessage("biRecord", temp, nil)  
end

--获取当前接入平台名称
function platformName(callback)
    -- body
    local temp = {}
    sendMessage("platformName", temp, callback)
end

function needShowSDKBtn(callback)
    -- body
    local temp = {}
    sendMessage("needShowSDKBtn", temp, callback)
end

--进入个人中心
function enterUserCenter()
    -- body
    local temp = {}
    sendMessage("enterUserCenter", temp, nil)
end

function listenBroadCast(name, callback)
    -- body
    if name == nil then
        return
    end
    if NDKHelper then
        NDKHelper:listenNativeMessage(name, callback)
    end
end

--登录后
function createNewRole(username, serverID)
   local temp = {}
   temp.username = username
   temp.serverID = serverID
   sendMessage("createrRole",temp, nil) 
end


