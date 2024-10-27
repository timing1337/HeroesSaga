---游戏全局模块
-- @module game
require "game_version_config";

function cclog(...)
    print(...)
end

local lfs = lfs;

if lfs then
    function os.existsDir(path)
        return util_system:isDirectoryExist(path);
    end
     
    function os.mkdir(path)
        if not os.existsDir(path) then
            return lfs.mkdir(path)
        end
        return true
    end
     
    function os.rmdir(path)
        local tempPath = string.sub(path,string.len(path))
        if tempPath ~= "/" then
            path = path .. "/"
        end
        if os.existsDir(path) then
            cclog("os.rmdir:", path)
            local function _rmdir(path)
                local iter, dir_obj = lfs.dir(path)
                while true do
                    local dir = iter(dir_obj)
                    if dir == nil then break end
                    if dir ~= "." and dir ~= ".." then
                        local curDir = path..dir
                        local mode = lfs.attributes(curDir, "mode") 
                        if mode == "directory" then
                            _rmdir(curDir.."/")
                        elseif mode == "file" then
                            os.remove(curDir)
                            -- cclog("remove file = " .. curDir)
                        end
                    end
                end
                local succ, des = os.remove(path)
                if des then cclog(des) end
                return succ
            end
            _rmdir(path)
        else
            cclog("dir not found os.rmdir:", path)
        end
        return true
    end
end

local sharedDirector = CCDirector:sharedDirector();

local game = {
    requestCount = 0,
    platform = "",
    initFlag = false,
    prgressLabel = nil,
};

--- 游戏入口
function game.startup(self)
    self:runDefaultScene();
    -- local temp = require("like_oo.oo_controlBase");
    -- temp:openView("test");
    -- return;
    self:init();
    --解压
end

--- 游戏初始化
function game.init(self)
    local init = CCUserDefault:sharedUserDefault():getBoolForKey("init");
    cclog("game init ============" ..tostring(init));
    if init == nil or init == false then
        self:loadLua();
        CCUserDefault:sharedUserDefault():setFloatForKey("musicVolume",1);
        CCUserDefault:sharedUserDefault():setFloatForKey("soundsVolume",1);
        CCUserDefault:sharedUserDefault():setBoolForKey("musicFlag",true)
        CCUserDefault:sharedUserDefault():setBoolForKey("soundFlag",true)
        CCUserDefault:sharedUserDefault():setStringForKey("gameClientVerion",tostring(CLIENT_VERSION));--client version
        audio.setMusicVolume(1)
        audio.setSoundsVolume(1)
        -- local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("config/game_config_version.config");
        -- local readData = util.readFile(fileFullPath)
        -- if readData then
        --     local game_config_version_tab = json.decode(readData) or {}
        --     for k,v in pairs(game_config_version_tab) do
        --         CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(k),tonumber(v));
        --     end
        -- end
        CCUserDefault:sharedUserDefault():setBoolForKey("init",true);
        CCUserDefault:sharedUserDefault():flush();
        self:enterGameScene();
        game_util:registerScriptApplication();
    else
        self.initFlag = true;
        local function setAudio()
            local musicVolume = CCUserDefault:sharedUserDefault():getFloatForKey("musicVolume")
            if musicVolume ~= nil then
                audio.setMusicVolume(musicVolume)
            end
            local soundsVolume = CCUserDefault:sharedUserDefault():getFloatForKey("soundsVolume")
            if soundsVolume ~= nil then
                audio.setSoundsVolume(soundsVolume)
            end
            local musicFlag = CCUserDefault:sharedUserDefault():getBoolForKey("musicFlag")
            if not (musicFlag == nil or musicFlag == true) then
                audio.pauseMusic();
            end
            local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
            if not (soundFlag == nil or soundFlag == true) then
                audio.pauseAllSounds();
            end
            game_util:registerScriptApplication();
        end
        local gameClientVerion = CCUserDefault:sharedUserDefault():getStringForKey("gameClientVerion") or ""
        cclog("oldClientVerion = " .. tostring(gameClientVerion) .. " ; newClientVerion = " .. tostring(CLIENT_VERSION));
        if gameClientVerion ~= tostring(CLIENT_VERSION) then--覆盖更新,删除老版本下载的资源
            CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",tostring(CSJ_FILES_UPDATE_VERION or ""))
            local writablePath = CCFileUtils:sharedFileUtils():getWritablePath()
            if lfs then
                local reCfg1 = os.rmdir(writablePath .. "config")
                local reRes1 = os.rmdir(writablePath .. "Resources")
                local reLua1 = os.rmdir(writablePath .. "lua")
                local reSound1 = os.rmdir(writablePath .. "sound")
                local reSound1 = os.rmdir(writablePath .. "temp")
                cclog("reCfg1 = " .. tostring(reCfg1) .. " ; reRes1 = " .. tostring(reRes1) .. " ; reLua1 = " .. tostring(reLua1) .. " ; reSound1 = " .. tostring(reSound1))
            else
                local reCfg1 = util_file:RemoveFolder(writablePath .. "config")--此方法在android没用，需要用os.rmdir
                local reRes1 = util_file:RemoveFolder(writablePath .. "Resources")
                local reLua1 = util_file:RemoveFolder(writablePath .. "lua")
                local reSound1 = util_file:RemoveFolder(writablePath .. "sound")
                local reSound1 = util_file:RemoveFolder(writablePath .. "temp")
            end

            CCFileUtils:sharedFileUtils():purgeCachedEntries();
            local m_shared = 0;
            function tick( dt )
                sharedDirector:getScheduler():unscheduleScriptEntry(m_shared)
                util_file:CreateFolder(writablePath .. "config");
                CCUserDefault:sharedUserDefault():setStringForKey("gameClientVerion",tostring(CLIENT_VERSION));
                CCUserDefault:sharedUserDefault():flush();
                self:loadLua();
                setAudio();
                self:enterGameScene();
            end
            m_shared = sharedDirector:getScheduler():scheduleScriptFunc(tick, 1, false)
        else
            self:loadLua();
            setAudio();
            self:enterGameScene();            
        end
    end
    
end

--- 游戏退出
function game.exit(self)
    if deleteConfigData ~= nil and type(deleteConfigData) == "function" then
        deleteConfigData();
    end
    exitGame();
end

function game.loadLua(self)
    string_helper = require("string_helper")
    require("init")
    require("game_config")
    game_url = require("game_url_config");
    string_config = require("string_config")
    game_util = require("game_util");
    game_scene = require("game_scene")
    battle_effect_offset = require("skill_effect.battle_effect_offset")
    game_data = require("game_data");
    game_guide_controller = require("controller.game_guide_controller");
    game_sound = require("game_sound");
    game_button_open = require("game_button_open");
    game_data_statistics = require("game_data_statistics");
    game_sound:loadAllSound();--loading all sound
    if device then
        self.platform = device.platform or ""
    end
    device_platform = self.platform;
    local gvcFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("game_version_config2.lua");
    if util.fileIsExist(gvcFileFullPath) and (SERVER_LIST_URL_NET == "http://119.81.219.41/en_pub/" or SERVER_LIST_URL_NET == "http://23.91.98.172/pub_abroad_en_3/") then
         require("game_version_config2")
    end
end
function game.createLoadAnim(self)
    local winSize = CCDirector:sharedDirector():getWinSize();
    local viewSize = CCSizeMake(winSize.width,winSize.height)
    local tempNode = CCNode:create();
    tempNode:setAnchorPoint(ccp(0.5,0.5))
    local tempLayer = CCLayerColor:create(ccc4(0,0,0, 150), viewSize.width*2, viewSize.height*2);
    tempNode:setContentSize(viewSize);
    tempNode:addChild(tempLayer,1,1);

    local aninFile = "sasuke";
    -- local loadingCfg = getConfig(game_config_field.updating)
    -- local loadingtipsCfg = getConfig(game_config_field.updating_tips)
    -- local loadingCount = loadingCfg:getNodeCount()
    -- local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    -- local level = math.random(1,loadingCount)--从里面随机取一个
    -- if loadingCfg and loadingtipsCfg then
    -- local loadingItemCfg = loadingCfg:getNodeWithKey(tostring(level));
    --     if loadingItemCfg then
    --         local loading_animition = loadingItemCfg:getNodeWithKey("updating_animation");
    --         if loading_animition then
    --             aninFile = loading_animition:toStr()
    --         end
    --     end
    -- end
    local lastAnim = tempNode:getChildByTag(10)
    if lastAnim then
        lastAnim:removeFromParentAndCleanup(true)
    end
    local animNode = game_util:createAnimSequence(aninFile,0,nil,nil);
    if animNode then
        animNode:setRhythm(1);
        animNode:setAnchorPoint(ccp(0.5,0.5));
        animNode:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5))
        tempNode:addChild(animNode,10,10);
    end
    return tempNode
end
function game.enterGameScene(self)
    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(1) end -- 成功打开游戏 步骤1
    game_scene:init();
    local background = CCSprite:create("ccbResources/dl_login_bg.jpg")
    local size = CCDirector:sharedDirector():getVisibleSize()
    background:setPosition(ccp(size.width/2,size.height/2))
    local backgroundSize = background:getContentSize();

    local animNode = self:createLoadAnim()
    animNode:setPosition(ccp(size.width/2,size.height/2))
    background:addChild(animNode,9,12)

    local ttf2 = CCLabelTTF:create("Extracting resources...","",16);
    ttf2:setColor(ccc3(255,255,255))
    ttf2:setPosition(ccp(backgroundSize.width/2,backgroundSize.height/4))
    background:addChild(ttf2,10,11);

    local ttf = CCLabelTTF:create("0/0","",16);
    ttf:setColor(ccc3(255,255,255))
    ttf:setPosition(ccp(backgroundSize.width/2,backgroundSize.height/4-20))
    background:addChild(ttf,10,10);
    self.prgressLabel = ttf
    game_scene:getGameContainer():addChild(background)
    local function initBack(table)
        if(table == "none")then
            game:getServerList();
        else
            if game_data_statistics and self.initFlag == false then
                game_data_statistics:endEvent({eventId = "sdk_event",label = "firstSdkInt"})
            end
            local success = table["init"]
            if success then
                print("---------------------- init success -------------------------")
                game:getServerList();
            end
        end
    end
    if getPlatForm() == "platformCommon" or getPlatForm() == "coolpay" then
        local function onSessionInvalid()
            local m_shared = 0;
            function tick( dt )
              CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
              local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = "confirm",       --可缺省
                    text = "Login abnormal,please exit the game to re-visit",      --可缺省
                }
                game_util:openAlertView(t_params);
            end
            m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false)
        end
        require("shared.native_helper").listenBroadCast("sessionInvalid",onSessionInvalid)
        require("shared.native_helper").sdkInit(initBack)
        if game_data_statistics and self.initFlag == false then
            game_data_statistics:beginEvent({eventId = "sdk_event",label = "firstSdkInt"})
        end
    else
        game:getServerList();
    end
end

--- 获取游戏服务器列表
function game.getServerList(self)
    self:enterMainScene();
end

--- 下载游戏资源
function game.resourcesDownload(self,t_param)
    t_param = t_param or {};
    if t_param.callBackFunc == nil then
        self:enterMainScene();
        return;
    end
    local function callBackFunc()
        cclog("-----------------------resourcesDownload end -----------------------")
        deleteConfigData();
        CCFileUtils:sharedFileUtils():purgeCachedEntries();
        -- util.reload("init")
        -- util.reload("game_config")
        -- util.reload("game_version_config")
        -- game_url = util.reload("game_url_config");
        -- string_config = util.reload("string_config")
        -- game_util = util.reload("game_util");
        -- game_scene = util.reload("game_scene")
        -- battle_effect_offset = util.reload("skill_effect.battle_effect_offset")
        -- game_data = util.reload("game_data");
        -- game_guide_controller = util.reload("controller.game_guide_controller");
        -- game_sound = util.reload("game_sound");
        -- game_button_open = util.reload("game_button_open");
        -- game_data_statistics = util.reload("game_data_statistics");
        -- self.platform = device.platform or ""
        -- device_platform = self.platform;
        -- game_sound:loadAllSound();--loading all sound
        -- game_scene:init();
        -- self:enterMainScene();
        if t_param.callBackFunc then
            t_param.callBackFunc();
        end
    end
    game_scene:runPropertyBarAnim("outer_anim")
    local game_resources_download = require("game_download.game_resources_download2");
    -- local game_resources_download = require("game_download.game_resources_download");
    game_scene:removeAllPop();
    game_scene:removeCurrentUi();
    game_scene:getGameContainer():addChild(game_resources_download:create({callBackFunc = callBackFunc}))

    game_resources_download:start();     
end

--[[
    
]]
function game.runDefaultScene(self)
    local tempScene = CCScene:create();
    local background = CCSprite:create("ccbResources/dl_login_bg.jpg")
    local size = sharedDirector:getVisibleSize()
    background:setPosition(ccp(size.width/2,size.height/2))
    tempScene:addChild(background);
    if sharedDirector:getRunningScene() then
        sharedDirector:replaceScene(tempScene)
    else
        sharedDirector:runWithScene(tempScene)
    end
end

--- 进入login
function game.enterMainScene(self)
    if device_platform == "ios" then
        game_data = util.reload("game_data");
        game_scene:enterGameUi("game_login_scene",{});
    else
        self:upZipFile();
    end
    -- --内存情况
    -- cclog("collectgarbage start " .. collectgarbage("count") / 1024 .. " M")
    -- --进行垃圾搜集
    -- collectgarbage("collect");
    -- cclog("collectgarbage end " .. collectgarbage("count") / 1024 .. " M")
end

function game.upZipFile(self)
    --在这里去创建一个资源在obb包里的sprite，若创建失败，则说明未解压或者老包更新，需要重新解压一下
    --为了防止更新问题，需要多次判断
    local zipTestSprite = CCSprite:create("battle_ground/back_alpineforest.jpg")--battle_ground
    local iconSprite = CCSprite:create("icon/e_c_armour3.png")--icon
    local buildSprite = CCSprite:create("building_img/mudi.png")--build_img
    local humenSprite = CCSprite:create("humen/icon_dracula1_b.png")--human
    local leadSprite = CCSprite:create("lead_skill_label/leader_buff_chainhealth.png")--lead_skill_label
    if zipTestSprite == nil or iconSprite == nil or buildSprite == nil or humenSprite == nil or leadSprite == nil then--需要解压
        CCUserDefault:sharedUserDefault():setBoolForKey("needUnZipFlag",true);
        CCUserDefault:sharedUserDefault():flush();
    else--不需要解压
        -- CCUserDefault:sharedUserDefault():setBoolForKey("needUnZipFlag",false);
        -- CCUserDefault:sharedUserDefault():flush(); 
    end
    local needUnZipFlag = CCUserDefault:sharedUserDefault():getBoolForKey("needUnZipFlag")
    cclog("needUnZipFlag ==== " .. tostring(needUnZipFlag))
    if needUnZipFlag == true then--需要解压
        local zipFilePath = CCUserDefault:sharedUserDefault():getStringForKey("zipFilePath")
        if zipFilePath then
            local function recieveEnd(event, value, value2,value3)
                local stateValue = tostring(value)
                cclog("event == " .. event .. " ; stateValue == " .. stateValue)
                if event == "success" then
                    cclog("event == " .. event .. " ; stateValue == " .. stateValue)
                elseif event == "error" then
                    if stateValue == "errorUncompress" and value2 and value2 ~= 0 then--解压报错给后端发报错code
                        cclog("errorUncompress error code = " .. value2)
                        --失败，要设置重新下载的flag
                        CCUserDefault:sharedUserDefault():setBoolForKey("needUnZipFlag",true);
                        CCUserDefault:sharedUserDefault():flush();
                    end
                elseif event == "downloadProgress" or event == "uncompressProgress" then
                    cclog("uncompressProgress === " .. tostring(value3) .. "/" .. tostring(value2))
                    if self.prgressLabel then
                        self.prgressLabel:setString(tostring(value3) .. "/" .. tostring(value2))
                    end
                elseif event == "state" then
                    if stateValue == "downloadStart" then

                    elseif stateValue == "uncompressStart" then

                    elseif stateValue == "uncompressDone" then
                        --解压之后设置flag
                        CCUserDefault:sharedUserDefault():setBoolForKey("needUnZipFlag",false);
                        --并且设置版本号的code
                        local tempCode = CCUserDefault:sharedUserDefault():getIntegerForKey("tempCode") or 0
                        CCUserDefault:sharedUserDefault():setIntegerForKey("gameVersionCode",tempCode);
                        --手动设置版本号     只要把安卓打包时的版本号写到最新即可，不用强设
                        -- local obbVersion = "t0.2.7"
                        -- CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",tostring(obbVersion or ""))
                        
                        CCUserDefault:sharedUserDefault():flush();
                        game_data = util.reload("game_data");
                        game_scene:enterGameUi("game_login_scene",{});
                        self.prgressLabel = nil;
                    end
                end
            end
            ExtDownloadClient:getInstance():registerScriptHandler(recieveEnd);
            cclog("zipFilePath == " .. zipFilePath)
            ExtDownloadClient:getInstance():upZipFileOnThread(zipFilePath,CCFileUtils:sharedFileUtils():getWritablePath(),false)
        end
    else
        game_data = util.reload("game_data");
        game_scene:enterGameUi("game_login_scene",{});
    end
end

return game;
