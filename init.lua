--- 游戏公共类初始化

math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

if type(DEBUG) ~= "number" then DEBUG = 1 end
require("shared.debug");
require("shared.extern");

--[[--
 	define global module
 	json
 	AudioEngine
 	TableViewHelper
 	display
 	network
 	audio
 	EventProtocol
 	util
 	transition
 	scheduler
]]
device = {platform = "",model = ""}

local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()
if target == kTargetWindows then
    device.platform = "windows"
elseif target == kTargetMacOS then
    device.platform = "mac"
elseif target == kTargetAndroid then
    device.platform = "android"
elseif target == kTargetIphone or target == kTargetIpad then
    device.platform = "ios"
    if target == kTargetIphone then
        device.model = "iphone"
    else
        device.model = "ipad"
    end
end


json 			= require("shared.json");
-- AudioEngine     = require("AudioEngine");
TableViewHelper = require("shared.TableViewHelper");
display         = require("shared.display");
network         = require("shared.network");
audio           = require("shared.audio");
EventProtocol   = require("shared.EventProtocol");
util            = require("shared.util");
transition 		= require("shared.transition");
scheduler  		= require("shared.scheduler");
if getPlatForm() == "91" then
	PLATFORM = require("SDKNdCom");
elseif( getPlatForm() == "pp" )then
	PLATFORM_LOGIN = false;
elseif getPlatForm() == "itools" then
	PLATFORM_ITOOLS = require("SDKItools");
elseif getPlatForm() == "cmge" then
	PLATFORM_CMGE = require("SDKCmge");
elseif getPlatForm() == "cmgeapp" then
	PLATFORM_CMGE_APP = require("SDKCmgeApp");
end
if device.platform == "ios" then
	-- DATA_EYE = require("DataEye");
end
--cclog("package.path = " .. package.path);
cclog("DEBUG = " .. tostring(DEBUG));

local timeCount = 0
local function checkMemory(dt)
    collectgarbage("collect");
    timeCount = timeCount + dt
    local used = tonumber(collectgarbage("count"))
    CCLuaLog(string.format("[LUA] MEMORY USED: %0.2f KB, UPTIME: %04.2fs", used, timeCount))
end
if DEBUG > 1 then
    CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(checkMemory, 5.0, false)
end

DOWNLOAD_RESOURCES = 1;

--[[--
	avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
]] 
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)