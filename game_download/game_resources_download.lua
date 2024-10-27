--- 游戏资源下载

local game_resources_download = {
	 httpclient = nil,
	 filesData = nil,
	 gameVerion = nil,
	 m_donwload_index_lable = nil,
	 m_download_size_lable = nil,
	 m_file_name_lable = nil,
   m_callBackFunc = nil,
   m_downloadFileCount = nil,
    m_downloadCfgRef = nil;
    m_configVerTable = nil;
    m_downloadCfgTab = nil;
    m_downloadCfgCount = nil;
    m_progress_node = nil;
    m_progress_bar = nil;
}

function game_resources_download.destroy(self)
   -- body
   if(self.httpclient ~= nil) then
      self.httpclient:http_close() 
      self.httpclient:delete()
      self.httpclient = nil;
   end
   if(self.filesData ~= nil) then
      self.filesData:delete()
      self.filesData = nil;
   end
   self.gameVerion = nil;
   self.m_donwload_index_lable = nil;
   self.m_download_size_lable = nil;
   self.m_file_name_lable = nil;
   self.m_callBackFunc = nil;
   self.m_downloadFileCount = nil;
    self.m_downloadCfgRef = nil;
    self.m_configVerTable = nil;
    self.m_downloadCfgTab = nil;
    self.m_downloadCfgCount = nil;
    self.m_progress_node = nil;
    self.m_progress_bar = nil;
   cclog("-----------------game_resources_download destroy-----------------");
end

function game_resources_download.createUi(self)
	 -- body
	 local function onMainBtnClick( target,event )
		  -- body
		local tagNode = tolua.cast(target, "CCNode");
      local btnTag = tagNode:getTag();
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

   self.m_progress_bar = ExtProgressBar:createWithFrameName("public_skillExpBigBg.png","public_skillExpBig.png",self.m_progress_node:getContentSize())
   self.m_progress_bar:setCurValue(0,false);
   self.m_progress_node:addChild(self.m_progress_bar);
	 return self.m_ccbNode;
end

-------------------------------------------------- 配置下载 --------------------------------------------------
function game_resources_download.startCfg(self)
    local function barAnimEnd(barNode,curValue,maxValue)
      if curValue == maxValue then
        cclog("no config download --------------------------");
        self:downloadConfigEnd();
      end
    end
    self.m_progress_bar:registerScriptBarHandler(barAnimEnd);

    -- local init = CCUserDefault:sharedUserDefault():getBoolForKey("init");
    -- cclog("game_resources_download init ============" ..tostring(init));
    -- if init == nil or init == false then   
    --     CCUserDefault:sharedUserDefault():setBoolForKey("init",true);
    --     CCUserDefault:sharedUserDefault():flush();
    --     self.m_downloadCfgRef = 1;
    --     self:downloadConfigData();
    -- else
        cclog("writablePath ===" .. writablePath);
        local function responseMethod(tag,gameData)
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
                }
                game_util:openAlertView(t_params);

                -- require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
                return;
            elseif gameData:getNodeWithKey("game_config_version") ~= nil then
                local cfgVersionData = gameData:getNodeWithKey("game_config_version");
                self.m_configVerTable = json.decode(cfgVersionData:getFormatBuffer());
                local verCfg = getConfig("game_config_version");
                local writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
                -- if verCfg == nil then
                --     -- self.m_downloadCfgRef = 1;
                --     -- self:downloadConfigData();
                --     local cfgCount = cfgVersionData:getNodeCount();
                --     self.m_downloadCfgRef = cfgCount;
                --     if cfgCount == 0 then
                --         self:downloadConfigEnd();
                --     else
                --         for i=1,cfgCount do
                --             self:downloadConfigData(cfgVersionData:getNodeAt(i -1):getKey());
                --         end
                --     end
                -- else
                    local cfgCount = cfgVersionData:getNodeCount();
                    local cfgItemData = nil;
                    local configName = nil;
                    local verValue = nil;
                    self.m_downloadCfgTab = {};
                    local index = 1;
                    for i=1,cfgCount do
                        cfgItemData = cfgVersionData:getNodeAt(i -1);
                        configName = cfgItemData:getKey();
                        verValue = CCUserDefault:sharedUserDefault():getIntegerForKey(tostring(configName))

                        if verValue == nil then
                            self.m_downloadCfgTab[index] = configName
                            index = index + 1;
                        else
                            -- cclog("cfgItemData:toInt() ==" .. cfgItemData:toInt() .. " ; verValue = " .. verValue .. " ; configName = " .. configName);
                            if cfgItemData:toInt() ~= verValue or (not util.fileIsExist(writablePath .. configName .. ".config")) then
                                self.m_downloadCfgTab[index] = configName
                                index = index + 1;
                            end
                        end
                    end
                    self.m_downloadCfgRef = #self.m_downloadCfgTab;
                    self.m_downloadCfgCount = self.m_downloadCfgRef;
                    if #self.m_downloadCfgTab == 0 then
                        self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true);
                    else
                        -- for k=1,#self.m_downloadCfgTab do
                            -- cclog("download config  configName ===" .. self.m_downloadCfgTab[k]);
                            -- self:downloadConfigData(self.m_downloadCfgTab[k]);
                        -- end
                        self.m_progress_bar:setMaxValue(self.m_downloadCfgCount);
                        self.m_progress_bar:setCurValue(0,false);
                        self:downloadConfigData(self.m_downloadCfgTab[1]);
                    end
                -- end
            else
                require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("loading"), http_request_method.GET, nil,"loading",false,true)
    -- end
end

function game_resources_download.downloadConfigData(self,congfigName)
    local function responseMethod(tag,gameData)
        -- cclog("responseMethod ---" .. gameData:getFormatBuffer());
        -- cclog("tolua.type(gameData) = " .. tolua.type(gameData));
        if gameData == nil then
            cclog("on config data download ------------------tag = " .. tag);
        else
          local writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
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
              local ret = util.writeFile(fullpath,dataItem:getFormatBuffer());
              cclog("configName =====" .. configName .. "; save file ret = " .. tostring(ret));
              if self.m_configVerTable then
                  CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(configName),self.m_configVerTable[configName] or 1);
                  CCUserDefault:sharedUserDefault():flush();
              end
          end
        end
        self.m_downloadCfgRef = self.m_downloadCfgRef - 1;
        cclog("m_downloadCfgRef ==============" .. self.m_downloadCfgRef)
        self.m_progress_bar:setCurValue(self.m_downloadCfgCount - self.m_downloadCfgRef,true);
        if self.m_downloadCfgRef == 0 then
            if self.m_configVerTable then
                local fullpath = writablePath .. "game_config_version.config";
                local ret = util.writeFile(fullpath,json.encode(self.m_configVerTable));
                cclog("----------------save downloadConfig end------------------------")
            end
            self:downloadConfigEnd();
        else
          self.m_donwload_index_lable:setString((self.m_downloadCfgCount - self.m_downloadCfgRef + 1) .. "/" .. self.m_downloadCfgCount)
          self:downloadConfigData(self.m_downloadCfgTab[self.m_downloadCfgCount - self.m_downloadCfgRef + 1]);
        end
    end
     -- 最后还可以接受2个参数
     -- loadingFlag : boolean 是否有loading
     -- retrunFlag  : boolean 网络成功与否，都返回
     -- 返回的结果参考network 中的network.httpRequestCallback方法
    if congfigName == nil or congfigName == "" then
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("all_config"), http_request_method.GET, nil,"all_config",false,true)
    else
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("all_config"), http_request_method.GET, {config_name = congfigName},"config_" .. congfigName,false,true)
    end
end

function game_resources_download.downloadConfigEnd(self)
    if DOWNLOAD_RESOURCES == 0 then
        if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
            self.m_callBackFunc();
        end
        self:destroy();
    else
        self:getUpdataFileList()
    end
end

--------------------------------------------------下载资源--------------------------------------------------
function game_resources_download.getUpdataFileList(self)
    local function barAnimEnd(barNode,curValue,maxValue)
      if curValue == maxValue then
        self:downUpdateFilesEnd();
      end
    end
    self.m_progress_bar:registerScriptBarHandler(barAnimEnd);
    self.m_progress_bar:setMaxValue(100);
    self.m_progress_bar:setCurValue(0,false);
  local function sendRequest()
    local function responseMethod(tag,response)
	      if response:isSucceed()==false then--请求失败
          require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
           return;
        end
        local buffer = response:getResponseDataBuffer();
        self.filesData = util_json:new(buffer);
        if self.filesData and (not self.filesData:isEmpty()) then
          local data = self.filesData:getNodeWithKey("data");
          self.gameVerion = data:getNodeWithKey("current_version"):toStr()
          self.m_downloadFileCount = data:getNodeWithKey("different_files"):getNodeCount()
          cclog("count->"..self.m_downloadFileCount)
          if self.m_downloadFileCount == 0 then
            CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",self.gameVerion)
            CCUserDefault:sharedUserDefault():flush();
            self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true);
          else
            self.m_progress_bar:setMaxValue(self.m_downloadFileCount);
            self.m_progress_bar:setCurValue(0,false);
            self:downUpdateFiles()
          end
        else
           self.m_progress_bar:setCurValue(self.m_progress_bar:getMaxValue(),true);
        end 
    end
    local httpReq = CCHttpRequest:new()
    self.gameVerion = CCUserDefault:sharedUserDefault():getStringForKey("GameVerion");
    cclog('--------- local lua version '..self.gameVerion)
    --for test
    if(self.gameVerion == "") then
        require "game_version_config"
        self.gameVerion = CSJ_FILES_UPDATE_VERION
    end
    -- self.gameVerion = "aa637456ad6a7067d3b8c8f37fe18f7a2d7f3b04";
    cclog("gameVerion->"..self.gameVerion)
    cclog(lua_ver_url .. "/?version="..self.gameVerion)
    httpReq:setUrl(lua_ver_url .. "/?version="..self.gameVerion)
    httpReq:registerScriptTapHandler(responseMethod)
    httpReq:setRequestType(0)
    httpReq:setTag("getDownloadFiles")
    CCHttpClient:getInstance():send(httpReq)
    httpReq:release()
  end
   sendRequest();
   self.m_file_name_lable:setString(tostring(string_config.m_download_res));
end

function game_resources_download.downUpdateFiles(self)
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
   self.httpclient = http_client:new();
   local data = self.filesData:getNodeWithKey("data")
   local table = data:getNodeWithKey("different_files")
   local function startGetFile()
   	  --cclog("startGetFile"..index)
	    self.httpclient:http_close()
	    if(index > table:getNodeCount() - 1) then--下载完成
	  	     CCUserDefault:sharedUserDefault():setStringForKey("GameVerion",self.gameVerion)
           CCUserDefault:sharedUserDefault():flush();
		       cclog("file count->"..index)
           self:downUpdateFilesEnd();
         return 
      end
      local function recieveEnd(obj,flag,size)
	        if(flag == 1) then--开始下载
		        --cclog("onStart")
		        local v = self.httpclient:getHeadWithKey("Content-Length");
            totalSize = math.floor(v/1024)
		        currDownloadSize = 0
		        self.m_download_size_lable:setString(currDownloadSize .. "/" .. totalSize)
		        --cclog("Content->"..v)
          elseif(flag == 2) then--继续接收
		        --cclog("onReceive")
		        currDownloadSize = math.floor((currDownloadSize + size)/1024)
		        self.m_download_size_lable:setString(currDownloadSize .. "/" .. totalSize)
	        elseif(flag == 3) then--接收完成
	  	      --cclog("onEnd")
		        local v = self.httpclient:getHeadWithKey("Content-Length");
            currDownloadSize = math.floor(v/1024)
		        self.m_download_size_lable:setString(currDownloadSize .. "/" .. totalSize)
            self.m_progress_bar:setCurValue(index,true);
		        startGetFile();
         end
      end
      self.httpclient:registerCallBackFunc(recieveEnd)
      self.m_donwload_index_lable:setString((index+1) .. "/" .. self.m_downloadFileCount)
      local fileName = table:getNodeAt(index):toStr()
      local pathName = getFilePath(fileName)
      self.httpclient:setDir(CCFileUtils:sharedFileUtils():getWritablePath()..pathName)
	   -- cclog("getWritablePath:"..CCFileUtils:sharedFileUtils():getWritablePath())
      totalSize = 0
      currDownloadSize = 0;
      cclog(lua_url .. "/"..fileName);
	    local ret = self.httpclient:http_connect(lua_url .. "/"..fileName) 
	    self.m_file_name_lable:setString(fileName)
	    --cclog("download ret:"..ret)
      index = index + 1
   end
   startGetFile()
end

function game_resources_download.downUpdateFilesEnd(self)
    cclog("------------- downUpdateFilesEnd ------------------")
    if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
        self.m_callBackFunc();
    end
    local m_shared = 0;
    function tick( dt )
      -- body
      cclog("------------- downUpdateFilesEnd ------------------ tick ")
      -- self:destroy();
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);

      if(self.httpclient ~= nil) then
        self.httpclient:http_close() 
        self.httpclient:delete()
        self.httpclient = nil;
      end
      if(self.filesData ~= nil) then
        self.filesData:delete()
        self.filesData = nil;
      end
    end
    m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false);

end

--[[--
    刷新ui
]]
function game_resources_download.start(self)
    self:startCfg();
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
end

--[[--
    创建ui入口并初始化数据
]]
function game_resources_download.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_resources_download;