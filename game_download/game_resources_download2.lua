--- 遊戲資源下載

local game_resources_download = {
    m_filesDataTab = nil,
    gameVerion = nil,
    m_donwload_index_lable = nil,
    m_download_size_lable = nil,
    m_file_name_lable = nil,
    m_callBackFunc = nil,
    m_downloadFileCount = nil,
    m_downloadCfgRef = nil,
    m_configVerTable = nil,
    m_configOldTable = nil,
    m_downloadCfgTab = nil,
    m_downloadCfgCount = nil,
    m_progress_node = nil,
    m_progress_bar = nil,
    m_luaFileDownloadFlag = nil,
    m_download_node = nil,
    m_restart_node = nil,
    m_restart_label = nil,
    m_dTotalSize = nil,
    m_dTempCurrSize = nil,
    m_dCurrSize = nil,
    m_networkSpeedScheduler = nil,
    m_tempSecondSize = nil,
    m_downloadType = nil,
    m_openTime = nil,
    game_loading = nil,
    loading_layer = nil,
    m_anim_node = nil,
    m_loading_tips_label = nil,
}

local teaKey = getGameTeaKey()

local errorTab = string_helper.game_resources_download.errorTab

--[[--
  銷毀對像
]]
function game_resources_download.destroy(self)
    -- body
    self.m_filesDataTab = nil;
    self.gameVerion = nil;
    self.m_donwload_index_lable = nil;
    self.m_download_size_lable = nil;
    self.m_file_name_lable = nil;
    self.m_callBackFunc = nil;
    self.m_downloadFileCount = nil;
    self.m_downloadCfgRef = nil;
    self.m_configVerTable = nil;
    self.m_configOldTable = nil;
    self.m_downloadCfgTab = nil;
    self.m_downloadCfgCount = nil;
    self.m_progress_node = nil;
    self.m_progress_bar = nil;
    self.m_luaFileDownloadFlag = nil;
    self.m_download_node = nil;
    self.m_restart_node = nil;
    self.m_restart_label = nil;
    self.m_dTotalSize = nil;
    self.m_dTempCurrSize = nil;
    self.m_dCurrSize = nil;
    self.m_networkSpeedScheduler = nil;
    self.m_tempSecondSize = nil;
    self.m_downloadType = nil;
    self.m_openTime = nil;
    self.game_loading = nil;
    self.loading_layer = nil;
    self.m_anim_node = nil;
    self.m_loading_tips_label = nil;
    cclog("-----------------game_resources_download destroy-----------------");
end
--[[--
  通過ccbi創建ui
]]
function game_resources_download.createUi(self)
     -- body
    local function onMainBtnClick( target,event )
          -- body
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then--退出
            game:exit();
        end
    end
    self.m_ccbNode = luaCCBNode:create();
    self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    self.m_ccbNode:openCCBFile("ccb/ui_game_resources_download.ccbi");
    self.m_donwload_index_lable = tolua.cast(self.m_ccbNode:objectForName("m_donwload_index_lable"), "CCLabelTTF");
    self.m_download_size_lable = tolua.cast(self.m_ccbNode:objectForName("m_download_size_lable"), "CCLabelTTF");
    self.m_file_name_lable = tolua.cast(self.m_ccbNode:objectForName("m_file_name_lable"), "CCLabelTTF");
    self.m_progress_node = tolua.cast(self.m_ccbNode:objectForName("m_progress_node"), "CCNode");
    self.m_file_name_lable:setString(tostring(string_config.m_download_cfg));
    self.m_donwload_index_lable:setString("");
    self.m_download_size_lable:setString("");
    self.m_download_node = self.m_ccbNode:nodeForName("m_download_node")
    self.m_restart_node = self.m_ccbNode:nodeForName("m_restart_node")
    self.m_restart_label = self.m_ccbNode:labelTTFForName("m_restart_label")
    self.m_download_node:setVisible(true);
    self.m_restart_node:setVisible(false);

    self.loading_layer = self.m_ccbNode:layerForName("loading_layer")
    self.loading_layer:setVisible(false)
    self.m_anim_node = self.m_ccbNode:nodeForName("m_anim_node")
    self.m_loading_tips_label = self.m_ccbNode:labelTTFForName("m_loading_tips_label")

    -- local screenSize =  CCDirector:sharedDirector():getWinSize()
    -- local m_login_bg = CCSprite:create("ccbResources/dl_login_bg.jpg")
    -- if m_login_bg then
    --     -- m_login_bg:setPosition( self.m_ccbNode:getContentSize().width * 0.5,  self.m_ccbNode:getContentSize().height * 0.5 )
    --     local winSize = m_login_bg:getContentSize()
    --     local login_super_hero_title = CCSprite:create("ccbResources/login_super_hero_title.png")

    --     if login_super_hero_title then
    --         login_super_hero_title:setScale( 0.8 )
    --         login_super_hero_title:setPosition(ccp(winSize.width*-0.25 + screenSize.width * 0.5  ,winSize.height*0.85))
    --         self.m_ccbNode:addChild(login_super_hero_title)
    --         -- local anim_dengluye = game_util:createUniversalAnim({animFile = "anim_dengluye",rhythm = 1.0,loopFlag = true,animCallFunc = nil,endCallFunc = nil});
    --         -- if anim_dengluye then
    --         --     anim_dengluye:setAnchorPoint(ccp(0.02,0.11))
    --         --     anim_dengluye:setScale(2)
    --         --     login_super_hero_title:addChild(anim_dengluye,-1,1000)
    --         -- end
    --     end
    --     local anim_monkeylight = game_util:createUniversalAnim({animFile = "anim_monkeylight",rhythm = 2.0,loopFlag = true,animCallFunc = nil,endCallFunc = nil});
    --     if anim_monkeylight then
    --         anim_monkeylight:setPosition(ccp(winSize.width*0.7,winSize.height*0.4))
    --         self.m_ccbNode:addChild(anim_monkeylight,1)
    --     end
    -- end

    -- self.m_progress_bar = ExtProgressBar:createWithFrameName("public_skillExpBigBg.png","public_skillExpBig.png",self.m_progress_node:getContentSize())
    self.m_progress_bar = ExtProgressTime:createWithFrameName("cjjs_jindutiao_1.png","cjjs_jindutiao.png")
    self.m_progress_bar:setCurValue(0,false);
    self.m_progress_node:addChild(self.m_progress_bar);
    return self.m_ccbNode;
end
--[[
    创建loading动画
]]
function game_resources_download.createLoadingAnim(self)
    self.loading_layer:setVisible(true)
    local aninFile = "monkey";
    local loadingCfg = getConfig(game_config_field.updating)
    local loadingtipsCfg = getConfig(game_config_field.updating_tips)
    local loadingCount = loadingCfg:getNodeCount()
    -- local level = game_data:getUserStatusDataByKey("level") or 1;
    local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local level = math.random(1,loadingCount)--从里面随机取一个
    if loadingCfg and loadingtipsCfg then
    local loadingItemCfg = loadingCfg:getNodeWithKey(tostring(level));
        if loadingItemCfg then
            local loading_animition = loadingItemCfg:getNodeWithKey("updating_animation");
            -- local anim_count = loading_animition:getNodeCount();
            -- if anim_count > 0 then
            --     aninFile = loading_animition:getNodeAt(math.random(0,anim_count-1)):toStr();
            -- end
            if loading_animition then
                aninFile = loading_animition:toStr()
            end
            local loadingtips = loadingItemCfg:getNodeWithKey("updating_tips");
            local loadingtips_count = loadingtips:getNodeCount();
            if loadingtips_count > 0 then
                local loadingtipsItemCfg = loadingtipsCfg:getNodeWithKey(loadingtips:getNodeAt(math.random(0,loadingtips_count-1)):toStr());
                if loadingtipsItemCfg then
                    self.m_loading_tips_label:setString(loadingtipsItemCfg:getNodeWithKey("tips_detail"):toStr());
                end
            end
        end
    end
    self.m_loading_tips_label:setVisible(true);
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local animNode = game_util:createAnimSequence(aninFile,0,nil,nil);
    if animNode then
        local function animEnd(animNode,theId,lableName)
            if lableName == anim_label_name_cfg.daiji then
                animNode:playSection(anim_label_name_cfg.gongji1);
            elseif lableName == anim_label_name_cfg.gongji1 then
                animNode:playSection(anim_label_name_cfg.gongji2);
            elseif lableName == anim_label_name_cfg.gongji2 then
                -- animNode:playSection(anim_label_name_cfg.daiji);
                self:createLoadingAnim()
            end
        end
        animNode:registerScriptTapHandler(animEnd);
        animNode:playSection(anim_label_name_cfg.daiji);
        animNode:setRhythm(1);
        animNode:setAnchorPoint(ccp(0.5,0));
        self.m_anim_node:addChild(animNode);
    end
end
--[[--
  獲取下載配置的列表
]]
function game_resources_download.startCfg(self)
        self.m_downloadType = 1;
        self.m_file_name_lable:setString(string_helper.game_resources_download.load_config);
        local function barAnimEnd(barNode,curValue,maxValue)
          if curValue == maxValue and self.m_downloadCfgRef == 0 then
            cclog("no config download --------------------------");
            self:downloadConfigEnd();
          end
        end
        self.m_progress_bar:registerScriptBarHandler(barAnimEnd);
        self.game_loading = require("game_ui.game_loading");
        self.game_loading.show();
        cclog("writablePath ===" .. writablePath);
        local function responseMethod(tag,gameData,contentLength,status,new_config_version)
            self.game_loading.close();
            if gameData == nil or gameData:isEmpty() then
                game_util:closeAlertView();
                local t_params =
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self:startCfg();
                        game_util:closeAlertView();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_config.m_re_conn,       --可缺省
                    text = string_config.m_net_req_failed,      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);

                -- require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
                return;
            elseif gameData:getNodeWithKey("game_config_version") ~= nil then
                CCUserDefault:sharedUserDefault():setStringForKey("all_config_version",new_config_version or "");
                local cfgVersionData = gameData:getNodeWithKey("game_config_version");
                local game_config_version_str = cfgVersionData:getFormatBuffer()
                -- local fullpath = writablePath .. "config/game_config_version.config";
                -- local ret = util.writeFile(fullpath,game_config_version_str);

                --讀取老的配置文件
                local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("config/game_config_version.config");

                print("fileFullPath === ", fileFullPath , " end")

                local readData = util.readFile(fileFullPath)
                if readData then
                    self.m_configOldTable = json.decode(readData) or {}
                    -- cclog("readData ======== " .. json.encode(self.m_configOldTable))
                else
                    cclog("read game_config_version failed !")
                end
                --當前配置文件
                self.m_configVerTable = json.decode(game_config_version_str) or {};
                local verValue = nil;
                self.m_downloadCfgTab = {};
                local index = 1;
                for configName,configVer in pairs(self.m_configVerTable) do
                    configName = tostring(configName)
                    verValue = self.m_configOldTable[configName]
                    if verValue == nil then
                        self.m_downloadCfgTab[index] = configName
                        index = index + 1;
                    else
                        -- cclog("configVer ==" .. configVer .. " ; verValue = " .. verValue .. " ; configName = " .. configName .. " ; cfg ver = " .. tostring(self.m_configOldTable[configName]));
                        local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("config/" .. configName .. ".config");
                        if configVer ~= verValue or (not util.fileIsExist(fileFullPath)) then
                            self.m_downloadCfgTab[index] = configName
                            index = index + 1;
                        end
                    end
                end
                self.m_downloadCfgRef = #self.m_downloadCfgTab;
                self.m_downloadCfgCount = self.m_downloadCfgRef;
                if #self.m_downloadCfgTab == 0 then
                    self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true,1);
                else
                    CCHttpClient:getInstance():setTimeoutForRead(40);
                    self.m_progress_bar:setMaxValue(self.m_downloadCfgCount);
                    self.m_progress_bar:setCurValue(0,false);
                    self:downloadConfigData(self.m_downloadCfgTab[1]);
                end
            else
                require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
            end
        end
        local params = {};
        if game_data.getServerId then
            params.server_id = game_data:getServerId();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("loading"), http_request_method.GET, params,"loading",false,true)
end


--[[--
  獲取下載配置的列表
  打包前獲取配置專用
]]
function game_resources_download.startCfg2(self)
        self.m_downloadType = 1;
        self.m_file_name_lable:setString(string_helper.game_resources_download.load_config);
        local function barAnimEnd(barNode,curValue,maxValue)
          if curValue == maxValue and self.m_downloadCfgRef == 0 then
            cclog("no config download --------------------------");
            self:downloadConfigEnd();
          end
        end
        self.m_progress_bar:registerScriptBarHandler(barAnimEnd);
        game_loading = require("game_ui.game_loading");
        game_loading.show({opacity = 1});
        cclog("writablePath ===" .. writablePath);
        local function responseMethod(tag,gameData,contentLength,status,new_config_version)
            game_loading.close();
            if gameData == nil or gameData:isEmpty() then
                game_util:closeAlertView();
                local t_params =
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self:startCfg2();
                        game_util:closeAlertView();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_config.m_re_conn,       --可缺省
                    text = string_config.m_net_req_failed,      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);

                -- require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
                return;
            else
                local data = gameData:getNodeWithKey("data")
                new_config_version = data:getNodeWithKey("all_config_version")
                if new_config_version then
                    new_config_version = new_config_version:toStr();
                else
                    new_config_version = "";
                end
                CCUserDefault:sharedUserDefault():setStringForKey("all_config_version",new_config_version or "");
                local cfgVersionData = data:getNodeWithKey("game_config_version");
                local game_config_version_str = cfgVersionData:getFormatBuffer()
                -- local fullpath = writablePath .. "config/game_config_version.config";
                -- local ret = util.writeFile(fullpath,game_config_version_str);

                --讀取老的配置文件
                local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("config/game_config_version.config");
                local readData = util.readFile(fileFullPath)
                if readData then
                    self.m_configOldTable = json.decode(readData) or {}
                    -- cclog("readData ======== " .. json.encode(self.m_configOldTable))
                else
                    cclog("read game_config_version failed !")
                end
                --當前配置文件
                self.m_configVerTable = json.decode(game_config_version_str) or {};
                local verValue = nil;
                self.m_downloadCfgTab = {};
                local index = 1;
                for configName,configVer in pairs(self.m_configVerTable) do
                    configName = tostring(configName)
                    verValue = self.m_configOldTable[configName]
                    if verValue == nil then
                        self.m_downloadCfgTab[index] = configName
                        index = index + 1;
                    else
                        -- cclog("configVer ==" .. configVer .. " ; verValue = " .. verValue .. " ; configName = " .. configName .. " ; cfg ver = " .. tostring(self.m_configOldTable[configName]));
                        local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("config/" .. configName .. ".config");
                        if configVer ~= verValue or (not util.fileIsExist(fileFullPath)) then
                            self.m_downloadCfgTab[index] = configName
                            index = index + 1;
                        end
                    end
                end
                self.m_downloadCfgRef = #self.m_downloadCfgTab;
                self.m_downloadCfgCount = self.m_downloadCfgRef;
                if #self.m_downloadCfgTab == 0 then
                    self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true,1);
                else
                    CCHttpClient:getInstance():setTimeoutForRead(40);
                    self.m_progress_bar:setMaxValue(self.m_downloadCfgCount);
                    self.m_progress_bar:setCurValue(0,false);
                    self:downloadConfigData(self.m_downloadCfgTab[1]);
                end
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("loading_for_test"), http_request_method.GET, nil,"loading_for_test",false,true)
end

--[[--
  配置下載
]]
function game_resources_download.downloadConfigData(self,congfigName)
    local function responseMethod(tag,gameData,contentLength)
        self.m_dCurrSize = self.m_dCurrSize + contentLength;
        -- cclog("responseMethod ---" .. gameData:getFormatBuffer());
        -- cclog("tolua.type(gameData) = " .. tolua.type(gameData));
        if gameData == nil then
            cclog("on config data download ------------------tag = " .. tag);
            local game_pop_up_box = require("game_ui.game_pop_up_box")
            game_pop_up_box.close();
            local t_params =
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_pop_up_box.close();
                    self:downloadConfigData(self.m_downloadCfgTab[self.m_downloadCfgCount - self.m_downloadCfgRef + 1]);
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_pop_up_box.close();
                    exitGame();
                end,
                okBtnText = string_helper.game_resources_download.btnText,       --可缺省
                text = string_config.m_net_req_failed,      --可缺省
                closeFlag = false,
            }
            game_pop_up_box.show(t_params);
            return;
        else
          self.m_downloadCfgRef = self.m_downloadCfgRef - 1;
          local writablePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "config/";
          -- cclog("writablePath ===" .. writablePath);
          local fullpath = nil;
          local data = gameData:getNodeWithKey("data");
          local dataCount = data:getNodeCount();
          local dataItem = nil;
          local configName = nil;
          for i=1,dataCount do
              dataItem = data:getNodeAt(i - 1);
              configName = dataItem:getKey();
              fullpath = writablePath .. configName .. ".config";
              -- os.remove(fullpath);
              local tempText = dataItem:getFormatBuffer();
              if contentLength == 0 then
                  self.m_dCurrSize = self.m_dCurrSize + string.len(tempText);
              end
              local ret = util.writeFile(fullpath,tempText);
              -- local tempText = CCCrypto:encryptXXTEALua(tempText,string.len(tempText),teaKey,string.len(teaKey));
              -- fullpath = writablePath .. configName .. ".configtea";
              -- local ret = util.writeFile(fullpath,tempText);
              cclog("configName =====" .. configName .. "; save file ret = " .. tostring(ret) .. " ; string.len(tempText) ==== " .. string.len(tempText));
              deleteConfigData(configName)
              if self.m_configVerTable then
                  local tempValue = self.m_configVerTable[configName];
                  self.m_configOldTable[configName] = tempValue
                  local fullpath = writablePath .. "game_config_version.config";
                  local ret = util.writeFile(fullpath,json.encode(self.m_configOldTable));
              end
          end
        end
        cclog("m_downloadCfgRef ==============" .. self.m_downloadCfgRef)
        self.m_progress_bar:setCurValue(self.m_downloadCfgCount - self.m_downloadCfgRef,false);
        if self.m_downloadCfgRef == 0 then
            if self.m_configVerTable then
              CCHttpClient:getInstance():setTimeoutForRead(40);
                -- local fullpath = writablePath .. "game_config_version.config";
                -- local ret = util.writeFile(fullpath,json.encode(self.m_configOldTable));
                cclog("----------------save downloadConfig end------------------------")
            end
            self:downloadConfigEnd();
        else
          self.m_donwload_index_lable:setString(math.floor(((self.m_downloadCfgCount - self.m_downloadCfgRef + 1)  /  self.m_downloadCfgCount)*100) .. "%")
          self:downloadConfigData(self.m_downloadCfgTab[self.m_downloadCfgCount - self.m_downloadCfgRef + 1]);
        end
    end
     -- 最後還可以接受2個參數
     -- loadingFlag : boolean 是否有loading
     -- retrunFlag  : boolean 網絡成功與否，都返回
     -- 返回的結果參考network 中的network.httpRequestCallback方法
    if congfigName == nil or congfigName == "" then
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("all_config"), http_request_method.GET, nil,"all_config",false,true)
    else
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("all_config"), http_request_method.GET, {config_name = congfigName},"config_" .. congfigName,false,true)
    end
end

function game_resources_download.downloadConfigEnd(self)
    CCUserDefault:sharedUserDefault():flush();
    if DOWNLOAD_RESOURCES == 0 then
        if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
            self.m_callBackFunc();
        end
        self:destroy();
    else
        self:getUpdataFileList()
    end
end

--[[--
  獲取更新的資源列表
]]
function game_resources_download.getUpdataFileList(self)
    self.m_filesDataTab = {};
    local function barAnimEnd(barNode,curValue,maxValue)
        -- if curValue == maxValue then
        --     self:downUpdateFilesEnd();
        -- end
    end
    local gameVerion = CCUserDefault:sharedUserDefault():getStringForKey("GameVerion");
    cclog('--------- local lua version '..gameVerion)
    --for test
    if(gameVerion == "") then
        gameVerion = CSJ_FILES_UPDATE_VERION
    end
    -- gameVerion = "e62cdabbba674aa26a0bb4d4d358b3cb5b1ead4c";
    self.m_progress_bar:registerScriptBarHandler(barAnimEnd);
    self.m_progress_bar:setMaxValue(100);
    self.m_progress_bar:setCurValue(0,false);
    game_loading = require("game_ui.game_loading");
    game_loading.show();
    local function sendRequest()
        local function responseMethod(tag,response)
            game_loading.close();
            if response:isSucceed()==false then--請求失敗
                local game_pop_up_box = require("game_ui.game_pop_up_box")
                local t_params =
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_pop_up_box.close();
                        self:getUpdataFileList();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_pop_up_box.close();
                        exitGame();
                    end,
                    okBtnText = string_helper.game_resources_download.okBtnText2,       --可缺省
                    text = string_config.m_net_req_failed,      --可缺省
                    closeFlag = false,
                }
                game_pop_up_box.show(t_params);
                return;
            end
            local buffer = response:getResponseDataBuffer();
            local filesData = util_json:new(buffer);
            if filesData and (not filesData:isEmpty()) then
                local data = filesData:getNodeWithKey("data");
                self.gameVerion = data:getNodeWithKey("current_version"):toStr()
                self.m_filesDataTab = json.decode(data:getNodeWithKey("different_files"):getFormatBuffer()) or {};
                self.m_downloadFileCount = #self.m_filesDataTab;
                cclog("count->"..self.m_downloadFileCount)
                if self.m_downloadFileCount == 0 then
                    CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",self.gameVerion)
                    CCUserDefault:sharedUserDefault():flush();
                    -- self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true);
                    self:downUpdateFilesEnd();
                else

                    -- self.m_donwload_index_lable:setString("0/" .. self.m_downloadFileCount)
                    self.m_donwload_index_lable:setString("0%")
                    self.m_progress_bar:setMaxValue(self.m_downloadFileCount);
                    self.m_progress_bar:setCurValue(0,false);
                    os.remove(writablePath .. "temp/update_" .. gameVerion .. ".zip");
                    local m_shared = 0;
                    function tick( dt )
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared)
                        -- self:downUpdateFiles()
                        self:downUpdateFiles2();
                    end
                    m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.5, false)
                    -- local game_pop_up_box = require("game_ui.game_pop_up_box")
                    -- local t_params =
                    -- {
                    --     title = string_config.m_title_prompt,
                    --     okBtnCallBack = function(target,event)
                    --         game_pop_up_box.close();
                    --         self:downUpdateFiles()
                    --     end,   --可缺省
                    --     closeCallBack = function(target,event)
                    --         game_pop_up_box.close();
                    --         exitGame();
                    --     end,
                    --     okBtnText = "更新",       --可缺省
                    --     text = string.format("有%d個資源需要更新，確定更新嗎？",self.m_downloadFileCount),      --可缺省
                    --     closeFlag = false,
                    -- }
                    -- game_pop_up_box.show(t_params);
                  end
            else
               -- self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true);
               self:downUpdateFilesEnd();
            end
        end
        local httpReq = CCHttpRequest:new()
        cclog("Resource url =" .. lua_ver_url .. "/" .. gameVerion .. ".json")
        httpReq:setUrl(lua_ver_url .. "/" .. gameVerion .. ".json")
        -- local username = CCUserDefault:sharedUserDefault():getStringForKey("username");
        -- httpReq:setUrl(lua_ver_url .. "/?version="..gameVerion .. "&client_version=".. CLIENT_VERSION .. "&username=" .. tostring(username))
        httpReq:registerScriptTapHandler(responseMethod)
        httpReq:setRequestType(0)
        httpReq:setTag("getDownloadFiles")
        CCHttpClient:getInstance():send(httpReq)
        httpReq:release()
    end
    sendRequest();
    self.m_donwload_index_lable:setString("")
    self.m_file_name_lable:setString(tostring(string_config.m_download_res));
    self.m_downloadType = -1;
end
--[[--
  下載資源
]]
function game_resources_download.downUpdateFiles(self)
    cclog("!dsfdjsfkldjsfkldjsklfdsklj")
   self:createLoadingAnim()
   local index = 0
   local function getFilePath(str)
        local length = 0
        for i = 1,#str do
             if(string.sub(str,i,i) == "/") then
                length = i
             end
      end
      --cclog("length->"..length)
      return string.sub(str,0,length)
   end
   local totalSize = 0
   local currDownloadSize = 0;
   local table = self.m_filesDataTab or {};
   cclog("ExtDownloadClient:getInstance():setTimeoutForConnect ------------")
   ExtDownloadClient:getInstance():setTimeoutForConnect(10)
   ExtDownloadClient:getInstance():setTimeoutForRead(360)
   local function startGetFile()
      --cclog("startGetFile"..index)

        if(index > #table - 1) then--下載完成
            CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",self.gameVerion)
            CCUserDefault:sharedUserDefault():flush();
            cclog("file count->"..index)
            self:downUpdateFilesEnd();
         return
      end
      local function recieveEnd(tag,response,dTotalSize,dCurrSize)
          local typeName = tolua.type(response)
          if typeName == "DownloadResponse" then
              if response:isSucceed() == false or response:getResponseCode() ~= 200 then
                  cclog("download faied = " .. response:getDownloadRequest():getUrl());
                  local text = string_config.m_net_req_failed;
                  if response:getResponseCode() == 404 then
                    text = string_helper.game_resources_download.errorTab.errorDownFileNotFound.text
                  end
                  local game_pop_up_box = require("game_ui.game_pop_up_box")
                  local t_params =
                  {
                      title = string_config.m_title_prompt,
                      okBtnCallBack = function(target,event)
                          game_pop_up_box.close();
                          startGetFile();
                      end,   --可缺省
                      closeCallBack = function(target,event)
                          game_pop_up_box.close();
                          exitGame();
                      end,
                      okBtnText = string_helper.game_resources_download.btnText,       --可缺省
                      text = text,      --可缺省
                      closeFlag = false,
                  }
                  game_pop_up_box.show(t_params);
              else
                  cclog("download success = " .. response:getDownloadRequest():getUrl());
                  index = index + 1
                  self.m_progress_bar:setCurValue(index,true);
                  startGetFile();
              end
          elseif typeName == "DownloadRequest" then
            if dTotalSize ~= 0 and dCurrSize ~= 0 then
                totalSize = dTotalSize;
                currDownloadSize = math.max(dCurrSize - currDownloadSize,0)
                self.m_dCurrSize = self.m_dCurrSize + currDownloadSize;
                --cclog("tag == " .. tag .." ; dTotalSize === " .. tostring(dTotalSize) .. ";dCurrSize ===" .. tostring(dCurrSize) .. " ; self.m_dCurrSize == " .. self.m_dCurrSize);
                currDownloadSize = dCurrSize;
            end
          end
      end
      local fileName = table[index+1]
      local request = DownloadRequest:new();
      request:setUrl(lua_url .. "/"..fileName);
      request:registerScriptTapHandler(recieveEnd);
      request:setSavePath(CCFileUtils:sharedFileUtils():getWritablePath()..fileName);
      ExtDownloadClient:getInstance():downloadRes(request);
       -- cclog("getWritablePath:"..CCFileUtils:sharedFileUtils():getWritablePath())
      totalSize = 0
      currDownloadSize = 0;
      -- cclog(lua_url .. "/"..fileName);
      self.m_donwload_index_lable:setString(math.floor(100*(index+1)/self.m_downloadFileCount) .. "%")
      local tempFileName = fileName
      local firstValue,_ = string.find(tempFileName,".lua");
      if firstValue then
          tempFileName = string.sub(tempFileName,0,firstValue-1);
          self.m_luaFileDownloadFlag = true;
      end
        -- self.m_file_name_lable:setString(tostring(tempFileName))
        --cclog("download ret:"..ret)
   end
   startGetFile()
end

--[[--
  下載資源
]]
function game_resources_download.downUpdateFiles2(self)
    cclog("33333333333333333333")
    self:createLoadingAnim()
    -- http://127.0.0.1/updater/update.zip
    -- lua_url = "http://127.0.0.1"
    -- local downloadFileTab = {"temp/update.zip"}
    -- http://down.joygame.cn/cjyx/temp/updater0.2.98.zip
    -- lua_url = "http://down.joygame.cn/cjyx"
    -- local downloadFileTab = {"temp/updater0.2.98.zip"}
    local downloadFileTab = self.m_filesDataTab or {}
    local totalCount = #downloadFileTab;
    if totalCount < 0 then
        self:downUpdateFilesEnd();
    end
    local index = 0
    local totalSize = 0
    local currDownloadSize = 0;
    cclog("ExtDownloadClient:getInstance():setTimeoutForConnect ------------")
    ExtDownloadClient:getInstance():setTimeoutForConnect(10)
    ExtDownloadClient:getInstance():setTimeoutForRead(180)
    local function startGetFile()
        --cclog("startGetFile"..index)
        if(index > totalCount - 1) then--下載完成
            CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",self.gameVerion)
            CCUserDefault:sharedUserDefault():flush();
            cclog("downUpdateFiles2 file count->"..index)
            self.m_luaFileDownloadFlag = true;
            self:downUpdateFilesEnd();
            return
        end
        local fileName = downloadFileTab[index+1]
        local request = DownloadRequest:new();
        cclog("download url = " .. lua_url .. "/"..fileName);
        request:setUrl(lua_url .. "/"..fileName);
        request:setSavePath(CCFileUtils:sharedFileUtils():getWritablePath()..fileName);
        ExtDownloadClient:getInstance():downloadRes(request);
        totalSize = 0
        currDownloadSize = 0;
    end

  local function recieveEnd(event, value, value2,value3)
        local stateValue = tostring(value)
        if event == "success" then
            index = index + 1
            startGetFile();
            cclog("event == " .. event .. " ; stateValue == " .. stateValue)
        elseif event == "error" then
            local text = string_config.m_net_req_failed;
            local btnText = string_helper.game_resources_download.btnText;
            local tempTab = errorTab[stateValue];
            if tempTab then
                text =  tempTab.text;
                btnText =  tempTab.btnText;
            end
            local game_pop_up_box = require("game_ui.game_pop_up_box")
            local t_params =
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_pop_up_box.close();
                    startGetFile();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_pop_up_box.close();
                    exitGame();
                end,
                okBtnText = btnText,       --可缺省
                text = text,      --可缺省
                closeFlag = false,
            }
            game_pop_up_box.show(t_params);
            if stateValue == "errorUncompress" and value2 and value2 ~= 0 then--解压报错给后端发报错code
               local function responseMethod(tag,response)
                    if response:isSucceed()==false then--请求失败
                        return;
                    end
                end
                local username = CCUserDefault:sharedUserDefault():getStringForKey("username");
                local httpReq = CCHttpRequest:new()
                httpReq:setUrl("http://pub.kaiqigu.net/genesisandroidios/crash/?upZipErrorCode=".. tostring(value2) .. "&username=" .. tostring(username))
                httpReq:registerScriptTapHandler(responseMethod)
                httpReq:setRequestType(0)
                httpReq:setTag("errorUncompress")
                CCHttpClient:getInstance():send(httpReq)
                httpReq:release()
            end
        elseif event == "downloadProgress" or event == "uncompressProgress" then
            -- self.m_donwload_index_lable:setString(stateValue .. "%")
            -- self.m_donwload_index_lable:setString(tostring(value3) .. "/" .. tostring(value2))
            self.m_donwload_index_lable:setString(string.format("%0.2f",100*value3/value2) .. "% (" .. totalCount .. "/" .. (index + 1) .. ")")
            value = value3 or value;
            self.m_progress_bar:setCurValue(value,false);
            currDownloadSize = math.max(value3 - currDownloadSize,0)
            self.m_dCurrSize = self.m_dCurrSize + currDownloadSize;
            currDownloadSize = value3;
        elseif event == "state" then
            if stateValue == "downloadStart" then
                value2 = value2 or 100;
                self.m_progress_bar:setMaxValue(value2);
                self.m_file_name_lable:setString(string_helper.game_resources_download.downRes);
                self.m_progress_bar:setCurValue(0,false);
                self.m_downloadType = 2;
            elseif stateValue == "uncompressStart" then
                value2 = value2 or 100;
                self.m_progress_bar:setMaxValue(value2);
                self.m_file_name_lable:setString(string_helper.game_resources_download.unZipRes);
                self.m_progress_bar:setCurValue(0,false);
                self.m_downloadType = 3;
            elseif stateValue == "uncompressDone" then
                self.m_file_name_lable:setString(string_helper.game_resources_download.unZipCom);
            end
            cclog("event == " .. event .. " ; stateValue == " .. stateValue)
        end
  end
   ExtDownloadClient:getInstance():registerScriptHandler(recieveEnd);
   startGetFile()
end

--[[--
  資源下載完成
]]
function game_resources_download.downUpdateFilesEnd(self)
    cclog("------------- downUpdateFilesEnd ------------------")
    if self.m_networkSpeedScheduler ~= 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
        self.m_networkSpeedScheduler = 0;
    end
    if self.m_luaFileDownloadFlag == true then
            game:runDefaultScene();
            local m_shared = 0;
            function tick( dt )
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared)
                if zcReloadGame then
                    if deleteConfigData ~= nil and type(deleteConfigData) == "function" then
                        deleteConfigData();
                    end
                    CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
                    CCDirector:sharedDirector():purgeCachedData();
                    zcReloadGame:reloadGame();
                else
                    self.m_download_node:setVisible(false);
                    self.m_restart_node:setVisible(true);
                end
            end
            m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.1, false)
            return;
    else
        if luaCCBNode.addPublicResource then
            luaCCBNode:addPublicResource("ccbResources/public_res.plist");
            luaCCBNode:addPublicResource("ccbResources/other_public_res.plist");
            luaCCBNode:addPublicResource("ccbResources/ui_card_quality_bg_res.plist");
        end
    end
    self.loading_layer:setVisible(false)
    self.loading_layer:removeAllChildrenWithCleanup(true)
    if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
        self.m_callBackFunc();
    end
    -- self.game_loading.close()
    --清除动画
    -- if(not DOWNLOAD_BACKGROUND)then
    --     ExtDownloadClient:destroyInstance();
    -- end
    -- local m_shared = 0;
    -- function tick( dt )
      -- body
      -- self:destroy();
      -- CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
      -- if(DOWNLOAD_BACKGROUND)then
      --   self.downloadBackground(self);
      -- else
      --   -- if self.m_networkSpeedScheduler ~= 0 then
      --   --     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
      --   --     self.m_networkSpeedScheduler = 0;
      --   -- end
      --   self.backDownForConfig(self);
      -- end
    -- end
    -- m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false);
end

--[[--
    刷新ui
]]
function game_resources_download.start(self)
    self:startCfg();
    -- self:startCfg2();--打包前下載配置專用

    function tick( dt )
        local tempValue = self.m_dCurrSize - self.m_dTempCurrSize;
        -- tempValue = math.max(self.m_tempSecondSize,tempValue)
        self.m_tempSecondSize = tempValue;
        local speedValue = math.min(tempValue/1024,512);
        -- cclog("network speed ==================",speedValue)
        self.m_dTempCurrSize = self.m_dCurrSize;
        if self.m_downloadType == 1 and self.m_downloadCfgRef ~= 0 then
            self.m_file_name_lable:setString(string.format(string_helper.game_resources_download.downloadSpeed,speedValue))
        elseif self.m_downloadType == 2 then
            self.m_file_name_lable:setString(string.format(string_helper.game_resources_download.downloadSpeed,speedValue))
        elseif self.m_downloadType == 3 then
            self.m_file_name_lable:setString(string_helper.game_resources_download.unZipIng);
        end
    end
    self.m_networkSpeedScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false);
end

--[[--
    刷新ui
]]
function game_resources_download.refreshUi(self)

end
--[[--
    初始化
]]
function game_resources_download.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_downloadFileCount = 0;
    self.gameVerion = 0;
    self.m_downloadCfgRef = 0;
    self.m_downloadCfgTab = {};
    self.m_configOldTable = {};
    self.m_luaFileDownloadFlag = false;
    self.m_dTotalSize = 0;
    self.m_dCurrSize = 0;
    self.m_dTempCurrSize = 0;
    self.m_networkSpeedScheduler = 0;
    self.m_tempSecondSize = 0;
    self.m_downloadType = 0;
    self.m_openTime = os.time();
    self.m_filesDataTab = {};
end

--[[--
    創建ui入口並初始化數據
]]
function game_resources_download.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

--[[
    獲取後台加載資源列表
]]
function game_resources_download.getResList( self,t_params )
  -- body

end

--[[
    後台加載資源
]]
--[[
function game_resources_download.downloadBackground( self )
  -- body
   local totalSize = 0
   local currDownloadSize = 0;
   local fileTable = require("game_download.downloadBackground");
   local luaFile = CCFileUtils:sharedFileUtils():getWritablePath().."lua/game_download/downloadBackground.lua";
   local luaFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "lua/game_download/";
   util_file:CreateFolder(luaFilePath);
   -- local downloadTag = "";
   local function getFileName( )
      for k,v in pairs(fileTable) do
        if(v~=nil)then
          return k,v;
        end
      end
      return nil;
   end

   cclog("game_resources_download.downloadBackground ------------")
   ExtDownloadClient:getInstance():setTimeoutForConnect(10)
   ExtDownloadClient:getInstance():setTimeoutForRead(30)
   local function startGetFile()
      --cclog("startGetFile"..index)
      local index,fileName = getFileName();
      if(index == nil ) then--下載完成
           -- 全部文件下載完畢
           --  if self.m_networkSpeedScheduler ~= 0 then
           --      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
           --      self.m_networkSpeedScheduler = 0;
           --  end
           -- cclog("-------- loading file is over 1 " .. tostring(index) .. " " .. tostring(#fileTable));
           util.saveStringTable(luaFile,fileTable);
           -- ExtDownloadClient:destroyInstance();
           self.backDownForConfig(self);
         return
      end
      local function recieveEnd(tag,response,dTotalSize,dCurrSize)
          local typeName = tolua.type(response)
          if typeName == "DownloadResponse" then
              if response:getResponseCode() == 404 then
                cclog("download faied, service not have this resource  = " .. response:getDownloadRequest():getUrl());
                print("   this resource not have ","index", index, fileTable[index])
                  index = index + 1
                  local m_shared = 0;
                  function tick( dt )
                    -- body
                    -- print(" start  startGetFile --------")
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
                    startGetFile();
                  end
                  m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 5, false);

              elseif response:isSucceed() == false or response:getResponseCode() ~= 200  then
                cclog("download faied = " .. response:getDownloadRequest():getUrl(), "response:getResponseCode() = ", response:getResponseCode());
                local m_shared = 0;
                function tick( dt )
                  -- body
                  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
                  startGetFile();
                end
                m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 5 , false);
              else
                -- 下載成功
                cclog("download success = " .. response:getDownloadRequest():getUrl());
                fileTable[index] = nil;
                index = index + 1;
                util.saveStringTable(luaFile,fileTable);
                startGetFile();
              end
          elseif typeName == "DownloadRequest" then
              if dTotalSize ~= 0 and dCurrSize ~= 0 then
                  totalSize = dTotalSize;
                  currDownloadSize = math.max(dCurrSize - currDownloadSize,0)
                  self.m_dCurrSize = self.m_dCurrSize + currDownloadSize;
                  -- cclog("tag == " .. tag .. " ; dTotalSize === " .. tostring(dTotalSize) .. ";dCurrSize ===" .. tostring(dCurrSize) .. " ; self.m_dCurrSize == " .. self.m_dCurrSize);
                  currDownloadSize = dCurrSize;
                  -- downloadTag = tag;
              end
          end
      end


      local fileName = fileTable[index];
      local writeFileName = CCFileUtils:sharedFileUtils():getWritablePath()..fileName;
      while (index ~= nil) do
        if(not util.fileIsExist(writeFileName))then
          cclog("haven't file -------------- " .. writeFileName);
          break;
        end
        cclog("had file ------------- " .. writeFileName);
        fileTable[index] = nil;
        -- index = index+1;
        -- fileName = fileTable[index];
        index,fileName = getFileName();
        writeFileName = CCFileUtils:sharedFileUtils():getWritablePath()..fileName;
      end
      if(index == nil)then
        -- 全部文件下載完畢
        -- if self.m_networkSpeedScheduler ~= 0 then
        --     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
        --     self.m_networkSpeedScheduler = 0;
        -- end
        -- cclog("-------- loading file is over 2 " .. tostring(#fileTable));
        util.saveStringTable(luaFile,fileTable);
        -- ExtDownloadClient:destroyInstance();
        self.backDownForConfig(self);
        return;
      end

      local request = DownloadRequest:new();
      request:setUrl(lua_url .. "/"..fileName);
      request:registerScriptTapHandler(recieveEnd);
      request:setSavePath(writeFileName);
      -- request:setTag(fileName);
      cclog("------- be loading ----- " .. writeFileName);
      ExtDownloadClient:getInstance():downloadRes(request);
      totalSize = 0
      currDownloadSize = 0;
   end
   startGetFile()

end
]]
--[[
    後台下載配置指定資源
]]
--[[
function game_resources_download.backDownForConfig( self )
  -- body
  local configName = "update_config";
  local config = getConfig(configName);
  if(config==nil)then
    if self.m_networkSpeedScheduler ~= 0 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
        self.m_networkSpeedScheduler = 0;
    end
    cclog("-------- loading file is over 20 ");
    ExtDownloadClient:destroyInstance();
    return;
  end

  local downloadbuf = config:getFormatBuffer()

   local totalSize = 0
   local currDownloadSize = 0;
   local fileTable = json.decode(downloadbuf);

   local luaFile = CCFileUtils:sharedFileUtils():getWritablePath().."config/update_config.config";
   local luaFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "config";
   util_file:CreateFolder(luaFilePath);
   -- local downloadTag = "";
   local function getFileName( )
      for k,v in pairs(fileTable) do
        if(v~=nil)then
          return k,v;
        end
      end
      return nil;
   end

   cclog("game_resources_download.downloadBackground ------------")
   ExtDownloadClient:getInstance():setTimeoutForConnect(10)
   ExtDownloadClient:getInstance():setTimeoutForRead(30)
   local function startGetFile()
      --cclog("startGetFile"..index)
      local index,fileName = getFileName();
      if(index == nil ) then--下載完成
           -- 全部文件下載完畢
            if self.m_networkSpeedScheduler ~= 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
                self.m_networkSpeedScheduler = 0;
            end
           cclog("-------- loading file is over 1 " .. tostring(index) .. " " .. tostring(#fileTable));
           util.saveConfigTable(luaFile,fileTable);
           ExtDownloadClient:destroyInstance();
         return
      end
      local function recieveEnd(tag,response,dTotalSize,dCurrSize)
          local typeName = tolua.type(response)
          if typeName == "DownloadResponse" then
              if response:getResponseCode() == 404 then
                cclog("download faied, service not have this resource  = " .. response:getDownloadRequest():getUrl());
                print("   this resource not have ","index", index, fileTable[index])
                  index = index + 1
                  local m_shared = 0;
                  function tick( dt )
                    -- body
                    -- print(" start  startGetFile --------")
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
                    startGetFile();
                  end
                  m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 5, false);

              elseif response:isSucceed() == false or response:getResponseCode() ~= 200  then
                cclog("download faied = " .. response:getDownloadRequest():getUrl(), "response:getResponseCode() = ", response:getResponseCode());
                local m_shared = 0;
                function tick( dt )
                  -- body
                  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
                  startGetFile();
                end
                m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 5 , false);
              else
                -- 下載成功
                cclog("download success = " .. response:getDownloadRequest():getUrl());
                fileTable[index] = nil;
                index = index + 1;
                util.saveConfigTable(luaFile,fileTable);
                startGetFile();
              end
          elseif typeName == "DownloadRequest" then
              if dTotalSize ~= 0 and dCurrSize ~= 0 then
                  totalSize = dTotalSize;
                  currDownloadSize = math.max(dCurrSize - currDownloadSize,0)
                  self.m_dCurrSize = self.m_dCurrSize + currDownloadSize;
                  -- cclog("tag == " .. tag .. " ; dTotalSize === " .. tostring(dTotalSize) .. ";dCurrSize ===" .. tostring(dCurrSize) .. " ; self.m_dCurrSize == " .. self.m_dCurrSize);
                  currDownloadSize = dCurrSize;
                  -- downloadTag = tag;
              end
          end
      end


      local fileName = fileTable[index];
      local writeFileName = CCFileUtils:sharedFileUtils():getWritablePath()..fileName;
      while (index ~= nil) do
        if(not util.fileIsExist(writeFileName))then
          cclog("haven't file -------------- " .. writeFileName);
          break;
        end
        cclog("had file ------------- " .. writeFileName);
        fileTable[index] = nil;
        -- index = index+1;
        -- fileName = fileTable[index];
        index,fileName = getFileName();
        writeFileName = CCFileUtils:sharedFileUtils():getWritablePath()..fileName;
      end
      if(index == nil)then
        -- 全部文件下載完畢
        if self.m_networkSpeedScheduler ~= 0 then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_networkSpeedScheduler);
            self.m_networkSpeedScheduler = 0;
        end
        cclog("-------- loading file is over 2 " .. tostring(#fileTable));
        util.saveConfigTable(luaFile,fileTable);
        ExtDownloadClient:destroyInstance();
        return;
      end

      local request = DownloadRequest:new();
      request:setUrl(lua_url .. "/"..fileName);
      request:registerScriptTapHandler(recieveEnd);
      request:setSavePath(writeFileName);
      -- request:setTag(fileName);
      cclog("------- be loading ----- " .. writeFileName);
      ExtDownloadClient:getInstance():downloadRes(request);
      totalSize = 0
      currDownloadSize = 0;
   end
   startGetFile()


end
]]--
return game_resources_download;