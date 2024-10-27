---  登陆界面

local game_login_scene = {
    m_account_server_node = nil,
    m_server_node = nil,
    m_tableView = nil,
    m_username = nil,
    m_passwrod = nil,
    m_login_btn = nil,
    m_server_btn = nil,
    m_selServerIndex = nil,
    m_account_btn = nil,
    m_list_view_bg = nil,
    m_server_icon = nil,
    m_tel_num = nil,
    m_serverListReTurn = nil,
    m_requestCount = nil,
    m_root_layer = nil,
    m_needBindAccount = nil,
    m_checkLoginNum = 0 ,
    m_showSerListBoard = nil,
    m_lastSelectServerCell = nil,
    m_lastSelectServerIndex = nil,
    m_ccbNode = nil,
    m_showSerViewNode = nil,
    m_lastHeight = nil,
    m_lastTableView = nil,
    m_lastLoginTitle= nil,
    m_curPage = nil,
};
--[[--
    销毁
]]
function game_login_scene.destroy(self)
    -- body
    cclog("-----------------game_login_scene destroy-----------------");
    self.m_account_server_node = nil;
    self.m_server_node = nil;
    self.m_tableView = nil;
    self.m_username = nil;
    self.m_passwrod = nil;
    self.m_login_btn = nil;
    self.m_server_btn = nil;
    self.m_selServerIndex = nil;
    self.m_account_btn = nil;
    self.m_list_view_bg = nil;
    self.m_server_icon = nil;
    self.m_tel_num = nil;
    self.m_serverListReTurn = nil;
    self.m_requestCount = nil;
    self.m_root_layer = nil;
    self.m_needBindAccount = nil;
    self.m_checkLoginNum = 0 ;
    self.m_showSerListBoard = nil;
    self.m_lastSelectServerCell = nil;
    self.m_lastSelectServerIndex = nil;
    self.m_ccbNode = nil;
    self.m_showSerViewNode = nil;
    self.m_lastHeight = nil;
    self.m_lastTableView = nil;
    self.m_lastLoginTitle = nil;
    self.m_curPage = nil;
end


local platform_channel = ""
if util_system.getPlatformChannel then
    platform_channel = tostring(util_system:getPlatformChannel()); -- 平台渠道号
end

-- 'flag': 0,  # 0, 1, 2, 3,热橙 新绿 满红 空闲，，，
-- 老服， 新服， 维护， 空闲
local serverIconTab = {"cjjs_re_icon.png","cjjs_xin_icon.png","cjjs_wei_icon.png","cjjs_jian_icon.png"};

--[[--
    返回
]]
function game_login_scene.back(self,type)
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_login_scene.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");  
    local ccbNode = luaCCBNode:create();
    local function Login91()
        if PLATFORM.isLogined() then
            if game_data_statistics then
                game_data_statistics:loginGame({username = self.m_username})
            end
            self:enterGame();
        else
            PLATFORM.login()
        end
    end
    local function LoginPP(  )
        -- body
        if PP_CLASS:sharedInstance():isLogin() then
            if game_data_statistics then
                game_data_statistics:loginGame({username = self.m_username})
            end
            self:enterGame();
        else
            PP_CLASS:sharedInstance():showLogin();
        end
    end
    local function LoginItools()
        if PLATFORM_ITOOLS.isLogined() then
            if game_data_statistics then
                game_data_statistics:loginGame({username = self.m_username})
            end
            self:enterGame()
        else
            PLATFORM_ITOOLS.login()
        end
    end
    local function LoginCmge()
       if PLATFORM_CMGE.isLogined() then
            if game_data_statistics then
                game_data_statistics:loginGame({username = self.m_username})
            end
            self:enterGame()
        else
            PLATFORM_CMGE.login()
        end 
    end
    local function LoginCmgeApp()
       if PLATFORM_CMGE_APP.isLogined() then
            if game_data_statistics then
                game_data_statistics:loginGame({username = self.m_username})
            end
            self:enterGame()
        else
            PLATFORM_CMGE_APP.login()
        end 
    end

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--帐号
            local function callBackFunc()
                self:refreshUi();
                self:enterGame();
            end
            game_scene:addPop("account_login_pop",{callBackFunc = callBackFunc});
        elseif btnTag == 2 then--服务器
            self.m_account_server_node:setVisible(false);
            -- self.m_server_node:setVisible(true);
            -- self.m_tableView:setTouchEnabled(true);
            self.m_showSerViewNode:setVisible(true)
            local winSize = CCDirector:sharedDirector():getWinSize();
            self.m_showSerViewNode:setPosition(winSize.width * 0.5, winSize.height * 0.5)
            -- cclog2(user_token, "user_token =======  ")
            if self.m_lastLoginTitle and user_token ~= nil and user_token ~= "" then
                self.m_lastLoginTitle:setString(string_helper.game_login_scene.login_server)
            elseif self.m_lastLoginTitle then
                self.m_lastLoginTitle:setString(string_helper.game_login_scene.login_server)
            end
            local a, b = self:getRecommendServiceID() 
            print("recommend service id is   ", a, " and ", b, " end")

        elseif btnTag == 3 then--user_token登陆
            local platform = getPlatForm()
            if platform == "91" then
                Login91()
            elseif(platform == "pp")then
                LoginPP();
            elseif platform == "itools" then
                LoginItools()
            elseif platform == "cmge" then
                LoginCmge()
            elseif platform == "cmgeapp" then
                LoginCmgeApp()
            elseif platform == "platformCommon" then
                local function checkLogin(table)
                    if table["isLogined"] then
                        if game_data_statistics then
                            game_data_statistics:loginGame({username = self.m_username})
                        end
                        self:enterGame()
                    else
                        self:loginPlatFormCommon()    
                    end
                end
                require("shared.native_helper").checkLogin(checkLogin)
            else
                if game_data_statistics then
                    game_data_statistics:loginGame({username = self.m_username})
                end
                self:enterGame();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_login.ccbi");
    self.m_account_server_node = ccbNode:nodeForName("m_account_server_node")
    self.m_server_node = ccbNode:nodeForName("m_server_node")
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_login_btn = ccbNode:controlButtonForName("m_login_btn")
    self.m_server_btn = ccbNode:controlButtonForName("m_server_btn")
    self.m_account_btn = ccbNode:controlButtonForName("m_account_btn")
    self.m_server_icon = ccbNode:spriteForName("m_server_icon")

    self.m_ccbNode = ccbNode
    self.m_showSerViewNode = self:addShowServerListView()

    self.m_server_icon:setVisible(false);
    local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    m_tips_label:setVisible(false);
    local x,y = self.m_login_btn:getPosition()
    local platform = getPlatForm()
    if platform == "91" or platform == "pp" or platform == "itools" or platform == "cmge" or platform == "cmgeapp" then
        self.m_account_btn:setVisible(false)
        self.m_login_btn:setPosition(ccp(x,y+20))
    elseif platform == "platformCommon" then
        self.m_login_btn:setPosition(ccp(x,y+20))
        self.m_account_btn:setVisible(false);

        local function logoutResult(table)
            local m_shared = 0;
            function tick( dt )
              CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
              if game_data_statistics then
                    game_data_statistics:logoutGame()
                end
                game_scene:setVisibleBroadcastNode(false);
                game:resourcesDownload();
            end
            m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false)
        end
        require("shared.native_helper").listenBroadCast("userlogOut", logoutResult)

    end

    self.m_account_server_node:setVisible(true);
    self.m_server_node:setVisible(false);
    
    self.m_username = CCUserDefault:sharedUserDefault():getStringForKey("username");
    --self.m_passwrod = CCUserDefault:sharedUserDefault():getStringForKey("passwrod");
    cclog("self.m_username =========== " .. tostring(self.m_username));

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY + 1,true);
    local animFlag = false
    -- local m_login_bg = ccbNode:spriteForName("m_login_bg")

    -- local dl_login_bg2 = CCSprite:create("ccbResources/dl_login_bg2.jpg")
    -- if m_login_bg and dl_login_bg2 then
    --     local winSize = m_login_bg:getContentSize()
    --     local login_super_hero_title = CCSprite:create("ccbResources/login_super_hero_title.png")
    --     if login_super_hero_title then
    --         login_super_hero_title:setScale( 0.8 )
    --         login_super_hero_title:setPosition(ccp(winSize.width*0.25,winSize.height*0.85))
    --         m_login_bg:addChild(login_super_hero_title)
    --         login_super_hero_title:setOpacity(0)
    --         local function callBackFunc( node )
    --             -- local anim_dengluye = game_util:createUniversalAnim({animFile = "anim_dengluye",rhythm = 1.0,loopFlag = true,animCallFunc = nil,endCallFunc = nil});
    --             -- if anim_dengluye then
    --             --     anim_dengluye:setAnchorPoint(ccp(0.02,0.11))
    --             --     anim_dengluye:setScale(2)
    --             --     -- login_super_hero_title:addChild(anim_dengluye,-1,1000)
    --             -- end
    --         end
    --         local function animCallFunc(animNode, theId,theLabelName)
    --             animNode:getParent():removeFromParentAndCleanup(true);
    --             dl_login_bg2:removeFromParentAndCleanup(true)
    --             local anim_monkeylight = game_util:createUniversalAnim({animFile = "anim_monkeylight",rhythm = 2.0,loopFlag = true,animCallFunc = nil,endCallFunc = nil});
    --             if anim_monkeylight then
    --                 anim_monkeylight:setPosition(ccp(winSize.width*0.7,winSize.height*0.4))
    --                 m_login_bg:addChild(anim_monkeylight,1)
    --             end
    --             self:animEndCallBackFunc()
    --             self.m_root_layer:setTouchEnabled(false)
    --         end
    --         local function anchorCallFunc(animNode , mId , strValue)
    --             local arr = CCArray:create();
    --             arr:addObject(CCEaseIn:create(CCFadeIn:create(1),5));
    --             arr:addObject(CCCallFuncN:create(callBackFunc));
    --             login_super_hero_title:runAction(CCSequence:create(arr));
    --         end
    --         local anim_denglu = game_util:createUniversalAnim({animFile = "anim_denglu",rhythm = 1.0,loopFlag = false,animCallFunc = animCallFunc,endCallFunc = nil});
    --         if anim_denglu then
    --             animFlag = true
    --             self.m_root_layer:setTouchEnabled(true)
    --             dl_login_bg2:setPosition(ccp(winSize.width*0.5,winSize.height*0.5))
    --             ccbNode:addChild(dl_login_bg2)
    --             anim_denglu:registerScriptAnchor(anchorCallFunc);
    --             anim_denglu:setPosition(ccp(winSize.width*0.5,winSize.height*0.5))
    --             anim_denglu:setAnchorPoint(ccp(0.5,0.5))
    --             ccbNode:addChild(anim_denglu,1,1000)
    --         end
    --     end
    -- end
    if not animFlag then
        self:animEndCallBackFunc()
    end
    return ccbNode;
end

function game_login_scene.animEndCallBackFunc(self)
    self:loginNoCommon()
    local platform = getPlatForm()
    if platform == "91" then
        if PLATFORM.isLogined() then
            self:accountServerList();
        else
            self.m_server_btn:setVisible(false)
            PLATFORM.login()
        end
    elseif platform == "itools" then
        if PLATFORM_ITOOLS.isLogined() then
            self:accountServerList();
        else
            self.m_server_btn:setVisible(false)
            PLATFORM_ITOOLS.login()
        end
    elseif platform == "cmge" then
        if PLATFORM_CMGE.isLogined() then
            self:accountServerList();
        else
            local m_shared = 0;
            function tick( dt )
                scheduler.unschedule(m_shared)
                PLATFORM_CMGE.login()
            end
            m_shared = scheduler.schedule(tick, 0, false)
            self.m_server_btn:setVisible(false)
        end
    elseif platform == "cmgeapp" then
        if PLATFORM_CMGE_APP.isLogined() then
            self:accountServerList();
        else
            local m_shared = 0;
            function tick( dt )
                scheduler.unschedule(m_shared)
                PLATFORM_CMGE_APP.login()
            end
            m_shared = scheduler.schedule(tick, 0, false)
            self.m_server_btn:setVisible(false)
        end
    elseif platform == "platformCommon"  then
        local function checkLogin(table)
            if table["isLogined"] then
                self:accountServerList();
            else
                self.m_server_btn:setVisible(false)
                self:loginPlatFormCommon()    
                local sdkFirstLoginInit = CCUserDefault:sharedUserDefault():getBoolForKey("sdkFirstLoginInit");
                if game_data_statistics and (sdkFirstLoginInit == nil or sdkFirstLoginInit == false) then
                    game_data_statistics:event({eventId = "login_event",label = "sdkFirstLoginInit"})
                    CCUserDefault:sharedUserDefault():setBoolForKey("sdkFirstLoginInit",true);
                    CCUserDefault:sharedUserDefault():flush();
                end
            end
        end
        require("shared.native_helper").checkLogin(checkLogin)
    elseif platform == "pp"  then
        self.m_root_layer:setTouchEnabled(true);
    else
        if self.m_username == "" then
           self:newAccount();
        else
            self:accountServerList();
        end
    end
end

function game_login_scene.loginNoCommon(self)
    local platform = getPlatForm()
    if platform == "91" then
        PLATFORM.showBar()
        PLATFORM.init()
        local function onLoginSuceeess()
            if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
            self.m_server_btn:setVisible(true)
            local userInfo = PLATFORM.getUserinfo()
            --拼出91_加loginUin
            self.m_username = "91_"..tostring(userInfo["uin"])
            CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
            CCUserDefault:sharedUserDefault():flush();
            self:accountServerList()
        end
        local function onNotLogined()
            if game_data_statistics then
                game_data_statistics:logoutGame();
            end
            if game_scene:getCurrentUiName() ~= "game_login_scene" then
                PLATFORM.messageBox(string_config:getTextByKey("m_exit_info"),1);
            end
        end
        local function onAlertClickExit()
            game:exit()
        end
        local function onAlertClickReLogin()
            game:exit()
        end
        --session过期
        local function onSessionInvalid()
            if game_scene:getCurrentUiName() ~= "game_login_scene" then
                PLATFORM.messageBox(string_config:getTextByKey("m_session_invalid"),2);
            end
        end
        PLATFORM.addCallback("SDKNDCOM_SESSION_INVALID",onSessionInvalid)
        PLATFORM.addCallback("SDKNDCOM_ALET_CLICK_EXIT",onAlertClickExit)
        PLATFORM.addCallback("SDKNDCOM_ALET_CLICK_RELOGIN",onAlertClickReLogin)
        PLATFORM.addCallback("SDKNDCOM_NOT_LOGINED",onNotLogined)
        PLATFORM.addCallback("SDKNDCOM_LOGINED",onLoginSuceeess)
    elseif(platform == "pp")then
        local m_shared = 0;
        function tick( dt )
            scheduler.unschedule(m_shared)
            if not PP_CLASS:sharedInstance():isLogin() then
                PP_CLASS:sharedInstance():showLogin();
            else
                self.m_root_layer:setTouchEnabled(false);
                self:accountServerList();
            end
        end
        m_shared = scheduler.schedule(tick, 1, false)

        local function PP_platform( flag , code , key )
            if self.m_root_layer then--修改
                self.m_root_layer:setTouchEnabled(false);
            end
            -- body
            if(flag == 'login')then             -- 登陆成功
                self.m_requestCount = self.m_requestCount + 1
                -- self.m_username = "PP_" .. PP_CLASS:sharedInstance():currentUserId();
                -- CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                -- CCUserDefault:sharedUserDefault():flush();
                -- self:accountServerList()
                --------------------   更新SDK  现在必须发送sessionid 从后端获得 UID --------------------
                --通过网络请求去取id
                local function onGetAuthUserId(tag, gameData)
                    if gameData then
                        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
                        PLATFORM_LOGIN = true;
                        local openid = gameData:getNodeWithKey("data"):getNodeWithKey("openid"):toStr()
                        --pp修改
                        local userId = PP_CLASS:sharedInstance():currentUserId(openid)
                        self.m_username = "PP_" .. tostring(userId)
                        CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                        CCUserDefault:sharedUserDefault():flush();
                        self:accountServerList()
                    else
                        local game_pop_up_box = require("game_ui.game_pop_up_box")
                        game_pop_up_box.close();
                        local t_params = 
                        {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                -- PP_platform();
                                game_pop_up_box.close();
                                --失败再次请求
                                local params = {};
                                params.session_id = key
                                params.channel = "pp"
                                if self.m_requestCount % 2 == 1 then
                                    master_url = SERVER_LIST_URL_NET;
                                else
                                    master_url = SERVER_LIST_URL_CN;
                                end 
                                network.sendHttpRequest(onGetAuthUserId, game_url.getUrlForKey("get_user_id"), http_request_method.GET, params,"get_user_id",true,true);
                            end,   --可缺省
                            closeCallBack = function(target,event)
                                game_pop_up_box.close();
                                game:exit();
                            end,
                            okBtnText = string_helper.game_login_scene.relink,       --可缺省
                            text = string_config.m_net_req_failed,      --可缺省
                            closeFlag = false,
                        }
                        game_pop_up_box.show(t_params);
                    end
                end
                local params = {};
                params.session_id = key
                params.channel = "pp"
                if self.m_requestCount % 2 == 1 then
                    master_url = SERVER_LIST_URL_NET;
                else
                    master_url = SERVER_LIST_URL_CN;
                end 
                network.sendHttpRequest(onGetAuthUserId, game_url.getUrlForKey("get_user_id"), http_request_method.GET, params,"get_user_id",true,true);
            elseif(flag == 'page_close')then    -- 页面关闭
                
            elseif(flag == 'web_close')then     -- web页面关闭

            elseif(flag == 'log_off')then       -- 注销回调
                if game_data_statistics then
                    game_data_statistics:logoutGame();
                end
                PLATFORM_LOGIN = false;
                if game_scene:getCurrentUiName() ~= "game_login_scene" then
                    game_scene:setVisibleBroadcastNode(false);
                    game:resourcesDownload();
                end
            elseif(flag == 'pay_result')then    -- 兑换购买回调
                if(code == 0)then
                    -- 购买成功
                    -- 用户uid
                    -- serverid
                    -- 商品配置id
                    -- os.time();
                    local function responseMethod(tag,gameData)
                        require("game_ui.ui_vip"):refreshVipData();
                        require("game_ui.game_activity"):reEnter()
                    end
                    network.sendHttpRequest( responseMethod , game_url.getUrlForKey("user_refresh") , http_request_method.GET , {} , "flush_user");
                    if game_data_statistics then
                        local billno = CCUserDefault:sharedUserDefault():getStringForKey("PP_BILL_NO")
                        -- print("billno.........................................."..tostring(billno))
                        game_data_statistics:paySuccess({order = billno})
                    end
                elseif(code == 4)then
                    -- pp余额不足
                    if game_data_statistics then
                        local billno = CCUserDefault:sharedUserDefault():getStringForKey("PP_BILL_NO")
                        -- print("billno.........................................."..tostring(billno))
                        game_data_statistics:payFailed({order = billno})
                    end
                else
                    -- 购买失败
                    if game_data_statistics then
                        local billno = CCUserDefault:sharedUserDefault():getStringForKey("PP_BILL_NO")
                        -- print("billno.........................................."..tostring(billno))
                        game_data_statistics:payFailed({order = billno})
                    end
                end
            elseif(flag == 'updata')then        -- 更新回调

            end
        end
        PP_CLASS:sharedInstance():registerScriptFunc(PP_platform);
    elseif platform == "itools" then
        PLATFORM_ITOOLS.init()
        local function onItoolsLoginSuccess()
            if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
            self.m_server_btn:setVisible(true)
            local userInfo = PLATFORM_ITOOLS.getUserinfo()
            --拼出itools_加loginUin
            self.m_username = "itools_"..tostring(userInfo["sdk_userId"])
            CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
            CCUserDefault:sharedUserDefault():flush();
            self:accountServerList()
        end
        PLATFORM_ITOOLS.addCallback("HX_NOTIFICATION_LOGIN_SUCCESS",onItoolsLoginSuccess)
        local function onItoolsLogOut()
            if game_scene:getCurrentUiName() ~= "game_login_scene" then
                -- PLATFORM_ITOOLS.messageBox(string_config:getTextByKey("m_session_invalid"),2);

            local m_shared = 0;
            function tick( dt )
              CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
              if game_data_statistics then
                    game_data_statistics:logoutGame()
                end
                game_scene:setVisibleBroadcastNode(false);
                game:resourcesDownload();
            end
            m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false)

            end
        end
        local function onAlertClickReLogin()
            game:exit()
        end
        PLATFORM_ITOOLS.addCallback("HX_NOTIFICATION_ALET_CLICK_RELOGIN",onAlertClickReLogin)
        PLATFORM_ITOOLS.addCallback("HX_NOTIFICATION_LOGOUT",onItoolsLogOut)
    elseif platform == "cmge" then
        PLATFORM_CMGE.init()
        local function onCmgeLoginSuccess()
            self.m_requestCount = self.m_requestCount + 1;
            self.m_server_btn:setVisible(true)
            local userInfo = PLATFORM_CMGE.getUserinfo()
            local authCode = userInfo["authCode"]

            --通过网络请求去取id
            local function onGetAuthUserId(tag, gameData)
                if gameData then
                    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
                    local openid = gameData:getNodeWithKey("data"):getNodeWithKey("openid"):toStr()
                    if gameData:getNodeWithKey("data"):getNodeWithKey("tel") then
                        local telNum = gameData:getNodeWithKey("data"):getNodeWithKey("tel"):toStr()
                        game_data:setPhoneNum(telNum)
                    end
                    --拼出cmge_加loginUin
                    self.m_username = "cmge_"..tostring(openid)
                    CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                    CCUserDefault:sharedUserDefault():flush();
                    self:accountServerList()
                else
                    local game_pop_up_box = require("game_ui.game_pop_up_box")
                    game_pop_up_box.close();
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            onCmgeLoginSuccess();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_pop_up_box.close();
                            PLATFORM_CMGE.logout()
                            game:exit();
                        end,
                        okBtnText = string_helper.game_login_scene.relink,       --可缺省
                        text = string_config.m_net_req_failed,      --可缺省
                        closeFlag = false,
                    }
                    game_pop_up_box.show(t_params);
                end
            end
            local params = {};
            params.code = authCode
            params.channel = "cmge"
            params.app_type = 0
            if self.m_requestCount % 2 == 1 then
                master_url = SERVER_LIST_URL_NET;
            else
                master_url = SERVER_LIST_URL_CN;
            end 
            network.sendHttpRequest(onGetAuthUserId, game_url.getUrlForKey("get_user_id"), http_request_method.GET, params,"get_user_id",true,true);
        end
        PLATFORM_CMGE.addCallback("CMGE_NOTIFICATION_LOGIN_SUCCESS",onCmgeLoginSuccess)
    elseif platform == "cmgeapp" then
        PLATFORM_CMGE_APP.init()
        local function onCmgeAppLoginSuccess()
            self.m_requestCount = self.m_requestCount + 1;
            self.m_server_btn:setVisible(true)
            local userInfo = PLATFORM_CMGE_APP.getUserinfo()
            local authCode = userInfo["authCode"]
            --通过网络请求去取id
            local function onGetAuthUserId(tag, gameData)
                if gameData then
                    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
                    local openid = gameData:getNodeWithKey("data"):getNodeWithKey("openid"):toStr()
                    if gameData:getNodeWithKey("data"):getNodeWithKey("tel") then
                        local telNum = gameData:getNodeWithKey("data"):getNodeWithKey("tel"):toStr()
                        game_data:setPhoneNum(telNum)
                    end
                    --拼出cmge_加loginUin
                    self.m_username = "cmgeapp_"..tostring(openid)
                    CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                    CCUserDefault:sharedUserDefault():flush();
                    self:accountServerList()
                else
                    local game_pop_up_box = require("game_ui.game_pop_up_box")
                    game_pop_up_box.close();
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            onCmgeAppLoginSuccess();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_pop_up_box.close();
                            PLATFORM_CMGE_APP.logout()
                            game:exit();
                        end,
                        okBtnText = string_helper.game_login_scene.relink,       --可缺省
                        text = string_config.m_net_req_failed,      --可缺省
                        closeFlag = false,
                    }
                    game_pop_up_box.show(t_params);
                end
            end
            local params = {};
            params.code = authCode;
            params.channel = "cmge"
            params.app_type = 1
            if self.m_requestCount % 2 == 1 then
                master_url = SERVER_LIST_URL_NET;
            else
                master_url = SERVER_LIST_URL_CN;
            end 
            network.sendHttpRequest(onGetAuthUserId, game_url.getUrlForKey("get_user_id"), http_request_method.GET, params,"get_user_id",true,true);
        end
        PLATFORM_CMGE_APP.addCallback("CMGE_NOTIFICATION_LOGIN_SUCCESS",onCmgeAppLoginSuccess)
    end
end

function game_login_scene.loginPlatFormCommon(self)
    self.m_requestCount = self.m_requestCount + 1;
    local function loginCallback(table)
        if not table["result"] then
            local game_pop_up_box = require("game_ui.game_pop_up_box")
            game_pop_up_box.close();
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_pop_up_box.close();
                    self:loginPlatFormCommon();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_pop_up_box.close();
                    game:exit();
                end,
                okBtnText = string_helper.game_login_scene.relink,       --可缺省
                text = string_config.m_net_req_failed,      --可缺省
                closeFlag = false,
            }
            game_pop_up_box.show(t_params);
            return
        end
        local function onGetAuthUserId(tag, gameData)
            print("onGetAuthUserId............................")
            if gameData then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
                local firstGetUserIdSuccess = CCUserDefault:sharedUserDefault():getBoolForKey("firstGetUserIdSuccess");
                if game_data_statistics and (firstGetUserIdSuccess == nil or firstGetUserIdSuccess == false) then
                    game_data_statistics:event({eventId = "login_event",label = "firstGetUserIdSuccess"})
                    CCUserDefault:sharedUserDefault():setBoolForKey("firstGetUserIdSuccess",true);
                    CCUserDefault:sharedUserDefault():flush();
                end
                print("onGetAuthUserId.gameData")
                local openid = gameData:getNodeWithKey("data"):getNodeWithKey("openid"):toStr()
                --拼出cmge_加loginUin
                self.m_username = table["platform"].."_"..tostring(openid)
                CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                CCUserDefault:sharedUserDefault():flush();
                self:accountServerList()
                self.m_account_btn:setVisible(false);
                
                local temp = {}
                temp.openid = openid;
                if gameData:getNodeWithKey("data"):getNodeWithKey("access_token") ~= nil then
                    temp.sdkToken = gameData:getNodeWithKey("data"):getNodeWithKey("access_token"):toStr()
                end
                if gameData:getNodeWithKey("data"):getNodeWithKey("openname") ~= nil then
                    temp.openname = gameData:getNodeWithKey("data"):getNodeWithKey("openname"):toStr()
                end
                if gameData:getNodeWithKey("data"):getNodeWithKey("sdkuserid") ~= nil then
                    temp.sdkuserid = gameData:getNodeWithKey("data"):getNodeWithKey("sdkuserid"):toStr()
                end
                if gameData:getNodeWithKey("data"):getNodeWithKey("username") ~= nil then
                    temp.username = gameData:getNodeWithKey("data"):getNodeWithKey("username"):toStr()
                end
                if gameData:getNodeWithKey("data"):getNodeWithKey("code") ~= nil then
                    temp.code = gameData:getNodeWithKey("data"):getNodeWithKey("code"):toStr()
                end
                global_loginData = temp;
                if gameData:getNodeWithKey("data"):getNodeWithKey("tel") then
                    local telNum = gameData:getNodeWithKey("data"):getNodeWithKey("tel"):toStr()
                    game_data:setPhoneNum(telNum)
                end
                require("shared.native_helper").logInResult(temp)
            else
                local game_pop_up_box = require("game_ui.game_pop_up_box")
                game_pop_up_box.close();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_pop_up_box.close();
                        self:loginPlatFormCommon();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_pop_up_box.close();
                        game:exit();
                    end,
                    okBtnText = string_helper.game_login_scene.relink,       --可缺省
                    text = string_config.m_net_req_failed,      --可缺省
                    closeFlag = false,
                }
                game_pop_up_box.show(t_params);
                --掌阅验证失败重新获取
                if platform_channel == "zhangyue" then
                    if  self.m_checkLoginNum == 0 then
                        self.m_checkLoginNum = 1 ;
                        game_pop_up_box.close(t_params);
                        self:loginPlatFormCommon();
                    end
                end

            end
        end
        local function onLoginPlatForm()                
            local params = {};
            if table["sessionId"] ~= nil then
                params.session_id = table["sessionId"];
                local sdkFirstLoginSuccess = CCUserDefault:sharedUserDefault():getBoolForKey("sdkFirstLoginSuccess");
                if game_data_statistics and (sdkFirstLoginSuccess == nil or sdkFirstLoginSuccess == false) then
                    game_data_statistics:event({eventId = "login_event",label = "sdkFirstLoginSuccess"})
                    CCUserDefault:sharedUserDefault():setBoolForKey("sdkFirstLoginSuccess",true);
                    CCUserDefault:sharedUserDefault():flush();
                end
            end
            
            if table["nickName"] ~= nil then
                params.nickname = table["nickName"]
            end
            
            if table["userID"] ~= nil then
                params.user_id = table["userID"]
            end                

            if table["strMid"] ~= nil then
                m_id_7ku = table["strMid"]
            end
            if table["channel"] ~= nil then
                params.new_channel = table["channel"]
            end

            if table["productCode"] ~= nil then
                params.product_code = table["productCode"]
            end
            params.channel = table["platform"]
            if table["needverify"] then
                if self.m_requestCount % 2 == 1 then
                    master_url = SERVER_LIST_URL_NET;
                else
                    master_url = SERVER_LIST_URL_CN;
                end 
                network.sendHttpRequest(onGetAuthUserId, game_url.getUrlForKey("get_user_id"), http_request_method.GET, params,"get_user_id",true,true);
            else
                if getPlatFormExt() == "HuaWei" then
                    self.huawei_oldUid = table["platform"].."_"..tostring(table["old_account"])
                end
                --拼出平台号_加loginUin
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(2) end  -- SDK登录成功 步骤2
                self.m_username = table["platform"].."_"..tostring(table["userID"])
                CCUserDefault:sharedUserDefault():setStringForKey("username", self.m_username);
                CCUserDefault:sharedUserDefault():flush();
                self:accountServerList()
                self.m_account_btn:setVisible(false);
                -- end
            end

            _G.global_qiku = nil
            local qiku = {}
            qiku.openid = table["openid"]
            qiku.openkey = table["openkey"]
            qiku.pf = table["pf"]
            qiku.pfkey = table["pfkey"]
            qiku.pay_token = table["pay_token"]

            _G.global_qiku = qiku
        end
        local m_shared = 0;
        function tick( dt )
          CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
          onLoginPlatForm()
        end
        m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false)
    end
    require("shared.native_helper").logIn(loginCallback)
end

--[[
    创建一个服务器cell node
]]
function game_login_scene.createAServiceNode( self, name, level , iconName, nodeSize, isSelect)
    nodeSize = nodeSize or CCSizeMake(210, 32)
    local serviceNode = CCNode:create()
    serviceNode:setContentSize(nodeSize)

    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_lace.png")
    tempBg:setPreferredSize(CCSizeMake(nodeSize.width + 10, nodeSize.height))
    tempBg:setAnchorPoint(ccp(0.5, 0.5))
    tempBg:setPosition(serviceNode:getContentSize().width * 0.5, serviceNode:getContentSize().height * 0.5)
    serviceNode:addChild(tempBg)

    if isSelect then 
        local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_lace.png")
        tempBg:setPreferredSize(CCSizeMake(nodeSize.width + 10, nodeSize.height))
        tempBg:setAnchorPoint(ccp(0.5, 0.5))
        tempBg:setPosition(serviceNode:getContentSize().width * 0.5, serviceNode:getContentSize().height * 0.5)
        serviceNode:addChild(tempBg)
    end

    local serverIcon = CCSprite:createWithSpriteFrameName("cjjs_jian_icon.png")
    serverIcon:setScale(0.75);
    serverIcon:setPosition(ccp(nodeSize.width*0.1,nodeSize.height*0.5));
    serviceNode:addChild(serverIcon,2,2);

    if iconName then
        local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconName);
        if tempDisplayFrame then
            serverIcon:setDisplayFrame(tempDisplayFrame);
        end
        serverIcon:setVisible(true);
    else
        serverIcon:setVisible(false);
    end


    local textSerName = CCLabelTTF:create( tostring(name or ""),"Helvetica" ,16);
    textSerName:setAnchorPoint(ccp(0, 0.5))
    textSerName:setPosition(nodeSize.width*0.2, nodeSize.height*0.5);
    serviceNode:addChild(textSerName,10,10);

    local textLevel = CCLabelTTF:create( tostring(""), "Helvetica",12);
    textLevel:setAnchorPoint(ccp(0, 0.5))
    textLevel:setPosition(nodeSize.width * 0.8, nodeSize.height*0.5);
    serviceNode:addChild(textLevel,10,10);

    if level and level > 0 then
        local level = "[LV." .. tostring(level) .. "]" 
        textLevel:setString(tostring(level))
    end


    if isSelect then 
        textSerName:setColor(ccc3(255,215,0)) 
        textLevel:setColor(ccc3(255,215,0)) 
    end

    serviceNode:setScale(0.9)
    return serviceNode
end


--[[--
    
]]
function game_login_scene.newAccount(self)
    self.m_requestCount = self.m_requestCount + 1;
    local game_pop_up_box = require("game_ui.game_pop_up_box")
    local function errorFunc()
            game_pop_up_box.close();
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_pop_up_box.close();
                    self:newAccount();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_pop_up_box.close();
                    exitGame();
                end,
                okBtnText = string_helper.game_login_scene.relink,       --可缺省
                text = string_config.m_net_req_failed,      --可缺省
                closeFlag = false,
            }
            game_pop_up_box.show(t_params);
    end

        local function fakeAccontResponseMethod(tag,gameData)
            if gameData then
                self.m_username = gameData:getNodeWithKey("data"):getNodeWithKey("fake_account"):toStr();
                CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                CCUserDefault:sharedUserDefault():flush();
                cclog("fake_account ======== "..self.m_username);
                if gameData:getNodeWithKey("data"):getNodeWithKey("ks") then
                    mark_user_login_sid = gameData:getNodeWithKey("data"):getNodeWithKey("ks"):toStr()
                end
                local server_list = gameData:getNodeWithKey("data"):getNodeWithKey("server_list")
                game_data:setServerDataByJsonData(server_list)
                self:refreshUi()
            else
                errorFunc();
            end
        end
        -- 申请一个假的account
        --cclog("self.m_username =========== " .. tostring(self.m_username) .. " ; self.m_passwrod ===========" .. tostring(self.m_passwrod));
        if self.m_requestCount % 2 == 1 then
            master_url = SERVER_LIST_URL_NET;
        else
            master_url = SERVER_LIST_URL_CN;
        end 
        network.sendHttpRequest(fakeAccontResponseMethod,game_url.getUrlForKey("new_account"), http_request_method.GET, {},"new_account",true,true);

end

--[[--
    
]]
function game_login_scene.accountServerList(self)
    self.m_requestCount = self.m_requestCount + 1;
    local game_pop_up_box = require("game_ui.game_pop_up_box")
    local function errorFunc()
            game_pop_up_box.close();
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_pop_up_box.close();
                    self:accountServerList();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_pop_up_box.close();
                    exitGame();
                end,
                okBtnText = string_helper.game_login_scene.relink,       --可缺省
                text = string_config.m_net_req_failed,      --可缺省
                closeFlag = false,
            }
            game_pop_up_box.show(t_params);
    end
    local function userServerList( tag, gameData )
        if gameData then
            local firstGetServerListSuccess = CCUserDefault:sharedUserDefault():getBoolForKey("firstGetServerListSuccess");
            if game_data_statistics and (firstGetServerListSuccess == nil or firstGetServerListSuccess == false) then
                game_data_statistics:event({eventId = "login_event",label = "firstGetServerListSuccess"})
                CCUserDefault:sharedUserDefault():setBoolForKey("firstGetServerListSuccess",true);
                CCUserDefault:sharedUserDefault():flush();
            end
            -- 设置sid
            if gameData:getNodeWithKey("data"):getNodeWithKey("ks") then
                mark_user_login_sid = gameData:getNodeWithKey("data"):getNodeWithKey("ks"):toStr()
            end
            local server_list = gameData:getNodeWithKey("data"):getNodeWithKey("server_list")
            game_data:setServerDataByJsonData(server_list)
            self.m_serverListReTurn = true;
            local current_server = gameData:getNodeWithKey("data"):getNodeWithKey("current_server"):toStr()
            for i, v in pairs(game_data:getServerData()) do
                if v.server == current_server then
                    user_token = v.uid
                    game_data:setServerId(v.server);
                end
            end
            self:refreshUi()
        else
            errorFunc();
        end
    end
    local params = {};
    params.account = self.m_username;
    -- params.just_one = 1;
    if self.m_requestCount % 2 == 1 then
        master_url = SERVER_LIST_URL_NET;
    else
        master_url = SERVER_LIST_URL_CN;
    end 
    if getPlatFormExt() == "HuaWei" then
        params.old_account = self.huawei_oldUid
        network.sendHttpRequest(userServerList, game_url.getUrlForKey("user_server_list_huawei"), http_request_method.GET, params,"user_server_list_huawei",true,true);
    else
        network.sendHttpRequest(userServerList, game_url.getUrlForKey("user_server_list"), http_request_method.GET, params,"user_server_list",true,true);
    end
end

--[[--
    
]]
function game_login_scene.enterGame(self)
    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(4) end  -- 创建角色 步骤4
    local function enterGame()
        --记录选择的服务器
        local serverData,index = game_data:getServer()
        if serverData then
            if game_data_statistics then
                game_data_statistics:selectServer({server = serverData.server.."-"..serverData.server_name})
            end
        end
        cclog("------------------ enterGame -------------user_token = " .. tostring(user_token))
        if user_token == nil or user_token == "" then
            game_scene:enterGameUi("create_role_scene",{});
            -- game_scene:enterGameUi("game_first_opening",{});
        else
            local function endCallFunc(returnFlag)
                if returnFlag then
                    if game_data_statistics then
                        game_data_statistics:event({eventId = "user_token_event",label = "enterGame"})
                    end
                    if getPlatForm() == "cmge" and PLATFORM_CMGE then
                        if type(PLATFORM_CMGE.roleLogin) == "function" then
                            local server_data,sindex = game_data:getServer()
                            local serverId = server_data.server
                            local userData = game_data:getDataByKey("m_tUserStatusData") or {}
                            local sendInfo = {}
                            sendInfo.uid = tostring(userData.uid)
                            sendInfo.coin = tostring(userData.coin)
                            sendInfo.show_name = tostring(userData.show_name)
                            sendInfo.level = tostring(userData.level)
                            sendInfo.serverId = tostring(serverId)
                            PLATFORM_CMGE.roleLogin(sendInfo)
                        end
                    end
                    game_guide_controller:start();
                else
                    game_util:closeAlertView();
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            require("game_download.game_data_download"):start({endCallFunc = endCallFunc});
                            game_util:closeAlertView();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                            exitGame();
                        end,
                        -- okBtnText = "重新下载",       --可缺省
                        -- text = "数据下载失败，请重新下载！",      --可缺省
                        okBtnText = string_helper.game_login_scene.relink,       --可缺省
                        text = string_config.m_net_req_failed,      --可缺省
                        closeFlag = false,
                    }
                    game_util:openAlertView(t_params);
                end
            end
            local function responseMethod(tag,gameData)
                if gameData then
                    local data = gameData:getNodeWithKey("data");
                    mark_user_login_mk = data:getNodeWithKey("mk"):toStr();
                    require("game_download.game_data_download"):start({endCallFunc = endCallFunc});
                else
                    game_util:closeAlertView();
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            enterGame();
                            game_util:closeAlertView();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                            exitGame();
                        end,
                        -- okBtnText = "重新连接",       --可缺省
                        -- text = "请求数据失败，请重新再试！",      --可缺省
                        okBtnText = string_helper.game_login_scene.relink,       --可缺省
                        text = string_config.m_net_req_failed,      --可缺省
                        closeFlag = false,
                    }
                    game_util:openAlertView(t_params);
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mark_user_login"), http_request_method.GET, nil,"mark_user_login",true,true)
        end
    end
    game:resourcesDownload({callBackFunc = enterGame})
end

--[[--
    创建服务器列表
    'flag': 0,  # 0, 1, 2, 3, 空闲，新绿，满红，热橙
]]
function game_login_scene.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local selServer,selIndex = game_data:getServer();
    local serverData = game_data:getServerData();
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = #serverData
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local itemBg = CCSprite:createWithSpriteFrameName("cjjs_select2.png")
            -- itemBg:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(itemBg,1,1);
            local text = CCLabelTTF:create("","Arial-BoldMT",20);
            text:setPosition(itemSize.width*0.5,itemSize.height*0.5);
            cell:addChild(text,10,10);
            local serverIcon = CCSprite:createWithSpriteFrameName("cjjs_jian_icon.png")
            serverIcon:setScale(0.75);
            serverIcon:setPosition(ccp(itemSize.width*0.2,itemSize.height*0.5));
            cell:addChild(serverIcon,2,2);
        end
        if cell then
            local itemData = serverData[index+1];
            local text = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            -- text:setString((index+1) .. "区 " .. itemData.server_name .. "[uid:" .. itemData.uid .. "]");
            -- text:setString((itemData.sort_id+1) .. "区 " .. itemData.server_name);
            text:setString(tostring(itemData.server_name));
            if selIndex and selIndex == index + 1 then
                -- tolua.cast(cell:getChildByTag(1),"CCSprite"):setVisible(true);
                text:setColor(ccc3(255,215,0))
            else
                text:setColor(ccc3(255,255,255))
                -- tolua.cast(cell:getChildByTag(1),"CCSprite"):setVisible(false);
            end
            local serverIcon = tolua.cast(cell:getChildByTag(2),"CCSprite")
            local flag = itemData.flag or 0;
            local iconName = serverIconTab[flag+1]
            if iconName and iconName ~= "" then
                local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconName);
                if tempDisplayFrame then
                    serverIcon:setDisplayFrame(tempDisplayFrame);
                end
                serverIcon:setVisible(true);
            else
                serverIcon:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if eventType == "ended" and item and self.m_server_node:isVisible() then
            self.m_account_server_node:setVisible(true);
            self.m_server_node:setVisible(false);
            self.m_tableView:setTouchEnabled(false);
            self.m_selServerIndex = index + 1;
            game_data:setServerId(serverData[self.m_selServerIndex].server);
            self:refreshUi();
        end
    end
    local tempTableView = TableViewHelper:create(params);
    -- cclog("selIndex ===== " .. selIndex)
    local contentSize = tempTableView:getContentSize()
    if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
        tempTableView:setContentOffset(ccp(0,math.min(0,viewSize.height - contentSize.height + (selIndex - 1) * itemSize.height)))
    end
    return tempTableView;
end

--[[--
    创建服务器列表
    'flag': 0,  # 0, 1, 2, 3, 空闲，新绿，满红，热橙
]]
function game_login_scene.createTableView2(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local selServer,selIndex = game_data:getServer();
    local serverData = game_data:getServerData();
    local serNum = #serverData
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 2; --列
    params.showPoint = false --
    local curPage =  math.ceil(selIndex / 8)
    -- cclog2(curPage, "self.m_curPage   ====   ")
    self.m_curPage = curPage 
    -- cclog2(self.m_curPage, "self.m_curPage   ====   ")
    params.showPageIndex = self.m_curPage;
    params.totalItem = serNum
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local itemData = serverData[index+1];
            local flag = itemData.flag or 0;
            local name = itemData.server_name
            local iconName = serverIconTab[flag+1]
            local level = itemData.level or nil
            local isSelect = selIndex and selIndex == index + 1
            -- cclog2(itemData, "server itemData ================  ")
            local serNode = self:createAServiceNode(tostring(name), level, iconName, itemSize, isSelect )
            if index % 2 == 0 then
                serNode:setAnchorPoint(ccp(1, 0))
                serNode:setPositionX(itemSize.width - 10)
            else
                serNode:setAnchorPoint(ccp(0, 0))
                serNode:setPositionX(10)
            end 

            if isSelect then 
                self.m_lastSelectServerCell = cell
                self.m_lastSelectServerIndex = index
            end
            cell:addChild(serNode, 10, 10)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        -- if eventType == "ended" and index ~= self.m_lastSelectServerIndex then
        if eventType == "ended" then
            -- if item then 
            --     local node = tolua.cast(item:getChildByTag(10), "CCNode")
            --     local lableSerName = tolua.cast(node:getChildByTag(2), "CCLabelTTF")
            --     lableSerName:setColor(ccc3(255,215,0)) 
            -- end
            -- local lastCell = self.m_lastSelectServerCell
            -- if lastCell then
            --     local node = tolua.cast(lastCell:getChildByTag(10), "CCNode")
            --     local lableSerName = tolua.cast(node:getChildByTag(2), "CCLabelTTF")
            --     lableSerName:setColor(ccc3(255,215,0)) 
            -- end

            local winSize = CCDirector:sharedDirector():getWinSize()
            self.m_showSerViewNode:setVisible(false)
            self.m_showSerViewNode:setPosition(winSize.width * 2.5, winSize.height * 0.5)
            self.m_account_server_node:setVisible(true);


            -- self.m_offsetY = self.m_lastTableView:getContentOffset().y
            self.m_selServerIndex = index + 1;
            self.m_lastSelectServerCell = index
            self.m_lastSelectServerCell = item

            game_data:setServerId(serverData[self.m_selServerIndex].server);
            self:refreshUi();
        end
    end

    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_curPage = curPage;
    end
    local tempTableView = TableViewHelper:createGallery3(params);
    local pageLable = tempTableView:getChildByTag(100) 
    if pageLable then
        pageLable:setVisible(true)
        pageLable:setAnchorPoint(ccp(0.5, 1.05));
        pageLable:setPositionX(viewSize.width * 0.5)
    end
    -- cclog("selIndex ===== " .. selIndex)
    -- local contentSize = tempTableView:getContentSize()
    -- if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
    --     if self.m_offsetY then
    --         tempTableView:setContentOffset(ccp(0,math.min(0, self.m_offsetY )))
    --     else
    --         local offsetY = math.min(0,viewSize.height - contentSize.height + ((selIndex - 1 ) / 2  ) * itemSize.height)
    --         -- offsetY = math.max(offsetY, -1 * itemSize.height * ((#serverData + 1) / 2 ) + viewSize.height)
    --         cclog2(offsetY, "offsetY   ===   offsetY=====")
    --         tempTableView:setContentOffset(ccp(0, offsetY))
    --     end
    -- end
    return tempTableView;
end

--[[--
    创建服务器列表
    'flag': 0,  # 0, 1, 2, 3, 空闲，新绿，满红，热橙
]]
function game_login_scene.createTableView3(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local selServer,selIndex = game_data:getServer();
    local serverData = game_data:getServerData();
    local params = {};
    local column = 1
    local server1, server2 = self:getRecommendServiceID()
    local recoServer = {server1, server2}
    if #recoServer == 0 then return nil end
    column = #recoServer
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = column; --列
    params.totalItem = #recoServer
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local serIndex = recoServer[index + 1]
            local itemData = serverData[serIndex];
            local flag = itemData.flag or 0;
            local name = itemData.server_name
            local level = itemData.level or nil
            local iconName = serverIconTab[flag+1]
            local isSelect = selIndex and selIndex == serIndex
            -- cclog2(itemData, "server itemData ================  ")
            local serNode = self:createAServiceNode(tostring(name), level, iconName, itemSize, isSelect )
            if index % 2 == 0 then
                serNode:setAnchorPoint(ccp(1, 0))
                serNode:setPositionX(itemSize.width - 10)
            else
                serNode:setAnchorPoint(ccp(0, 0))
                serNode:setPositionX(10)
            end 
            cell:addChild(serNode, 10, 10)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if eventType == "ended" then
            local winSize = CCDirector:sharedDirector():getWinSize()
            self.m_showSerViewNode:setVisible(false)
            self.m_showSerViewNode:setPosition(winSize.width * 2.5, winSize.height * 0.5)
            self.m_account_server_node:setVisible(true);
            -- if index == 1 then
                self.m_offsetY = nil
            -- end
            local serIndex = recoServer[index + 1]
            game_data:setServerId(serverData[serIndex].server);
            self:refreshUi();

        end
    end
    local tempTableView = TableViewHelper:create(params);
    tempTableView:setMoveFlag(false)
    tempTableView:setScrollBarVisible(false)
    return tempTableView;
end

--[[--
    刷新ui
]]
function game_login_scene.refreshTableView(self)
    -- self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- local bgSize = self.m_list_view_bg:getContentSize();
    -- self.m_tableView = self:createTableView(bgSize);
    -- self.m_list_view_bg:addChild(self.m_tableView);

    self.m_showSerListBoard:removeAllChildrenWithCleanup(true)
    local serviceView = self:createTableView2(self.m_showSerListBoard:getContentSize())
    self.m_lastTableView = serviceView
    self.m_showSerListBoard:addChild(serviceView)

    self.m_node_curServerBoard:removeAllChildrenWithCleanup(true)
    local curServiceView = self:createTableView3(self.m_node_curServerBoard:getContentSize())
    if curServiceView then 
        self.m_curTableView = curServiceView
        self.m_node_curServerBoard:addChild(self.m_curTableView)
    end
end

function game_login_scene.addShowServerListView( self )
        local winSize = CCDirector:sharedDirector():getWinSize();
        local boareViewContentSize = CCSizeMake(440, 270)
        local function onBtnCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            self.m_showSerViewNode:setVisible(false)
            self.m_showSerViewNode:setPosition(winSize.width * 2.5, winSize.height * 0.5)
            self.m_account_server_node:setVisible(true);
        end

        local all_board = CCNode:create()
        all_board:setAnchorPoint(ccp(0.5, 0.5))
        all_board:setContentSize(boareViewContentSize)
        all_board:setPosition(winSize.width * 2.5, winSize.height * 0.5)
        self.m_ccbNode:addChild(all_board, 100, 978)

        do 
            local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_pop_bg.png")
            tempBg:setPreferredSize(boareViewContentSize)
            tempBg:setAnchorPoint(ccp(0.5, 0.5))
            tempBg:setPosition(boareViewContentSize.width * 0.5, boareViewContentSize.height * 0.5)
            all_board:addChild(tempBg)

            local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_pop_bg.png")
            tempBg:setPreferredSize(boareViewContentSize)
            tempBg:setAnchorPoint(ccp(0.5, 0.5))
            tempBg:setPosition(boareViewContentSize.width * 0.5, boareViewContentSize.height * 0.5)
            all_board:addChild(tempBg)
        end

        -------------------

        local titleBoardNode = CCNode:create()
        titleBoardNode:setContentSize(CCSizeMake(boareViewContentSize.width, 25))
        titleBoardNode:setAnchorPoint(ccp(0.5, 1))
        titleBoardNode:setPosition(boareViewContentSize.width * 0.5, boareViewContentSize.height - 10)
        all_board:addChild(titleBoardNode)
        do 
            local titleBoardScale9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png")
            titleBoardScale9Sprite:setPreferredSize(CCSizeMake(titleBoardNode:getContentSize().width * 0.8, 25))
            titleBoardScale9Sprite:setColor(ccc3(252, 142,  1))
            titleBoardScale9Sprite:setAnchorPoint(ccp(0.5, 0.5))
            titleBoardScale9Sprite:setPosition(titleBoardNode:getContentSize().width * 0.5, titleBoardNode:getContentSize().height * 0.5)
            titleBoardNode:addChild(titleBoardScale9Sprite)

            -- local titleLabelTTF = CCLabelTTF:create( "推荐服务器","Arial-BoldMT",12);
            local titleLabelTTF = CCLabelTTF:create( string_helper.game_login_scene.rd_server,"Arial-BoldMT",12);
            titleLabelTTF:setColor(ccc3(240,170,40))
            titleLabelTTF:setAnchorPoint(ccp(0.5, 0.5))
            titleLabelTTF:setPosition(titleBoardNode:getContentSize().width * 0.5, titleBoardNode:getContentSize().height * 0.5)
            titleBoardNode:addChild(titleLabelTTF)

            -- local titleLabelTTF = CCLabelTTF:create( "推荐服务器","Arial-BoldMT",12);
            -- titleLabelTTF:setColor(ccc3(240,170,40))
            -- titleLabelTTF:setAnchorPoint(ccp(0.5, 0.5))
            -- titleLabelTTF:setPosition(titleBoardNode:getContentSize().width * 0.5, titleBoardNode:getContentSize().height * 0.5)
            -- titleBoardNode:addChild(titleLabelTTF)
        end
        ------------
        local curInfoSize = CCSizeMake(440, 40)
        local curSerInfoBoardNode = CCNode:create()
        curSerInfoBoardNode:setContentSize(curInfoSize)
        curSerInfoBoardNode:setAnchorPoint(ccp(0.5, 1))
        curSerInfoBoardNode:setPosition(boareViewContentSize.width * 0.5, titleBoardNode:getPositionY() - titleBoardNode:getContentSize().height )
        all_board:addChild(curSerInfoBoardNode)
        do 
            local curSerInfoBoardScale9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_9_32X32.png")
            curSerInfoBoardScale9Sprite:setPreferredSize(CCSizeMake(415, curInfoSize.height ))
            curSerInfoBoardScale9Sprite:setAnchorPoint(ccp(0.5, 0.5))
            curSerInfoBoardScale9Sprite:setPosition(curSerInfoBoardNode:getContentSize().width * 0.5, curSerInfoBoardNode:getContentSize().height * 0.5)
            curSerInfoBoardNode:addChild(curSerInfoBoardScale9Sprite)

            -- local lastLoginSerTitle = CCLabelTTF:create( tostring("[推荐登录服务器]"), "Arial-BoldMT",12);
            -- lastLoginSerTitle:setAnchorPoint(ccp(0, 1))
            -- lastLoginSerTitle:setPosition(curSerInfoBoardNode:getContentSize().width * 0.05, curSerInfoBoardNode:getContentSize().height);
            -- lastLoginSerTitle:setColor(ccc3(242,171,117))
            -- curSerInfoBoardNode:addChild(lastLoginSerTitle);
            -- self.m_lastLoginTitle = lastLoginSerTitle

            local lastLoginSerBoard = CCNode:create()
            lastLoginSerBoard:setContentSize(CCSizeMake(400, 32))
            lastLoginSerBoard:setAnchorPoint(ccp(0.5, 0.5))
            lastLoginSerBoard:setPosition(curSerInfoBoardNode:getContentSize().width * 0.5, curSerInfoBoardNode:getContentSize().height * 0.5)
            curSerInfoBoardNode:addChild(lastLoginSerBoard)
            self.m_node_curServerBoard = lastLoginSerBoard 

            -- local button = game_util:createCCControlButton("cjjs_jian_icon.png","",onBtnCilck)
            -- button:setPreferredSize(self.m_node_curServerBoard:getContentSize())
            -- button:setAnchorPoint(ccp(0.5,1))
            -- button:setPosition(curSerInfoBoardNode:getContentSize().width * 0.5, lastLoginSerTitle:getPositionY() - lastLoginSerTitle:getContentSize().height - 5)
            -- button:setOpacity(0)
            -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
            -- curSerInfoBoardNode:addChild(button, 10)
        end

        -----------
        local allInfoSize = CCSizeMake(440, 195)
        local allSerInfoBoardNode = CCNode:create()
        allSerInfoBoardNode:setContentSize(allInfoSize)
        allSerInfoBoardNode:setAnchorPoint(ccp(0.5, 1))
        allSerInfoBoardNode:setPosition(boareViewContentSize.width * 0.5, curSerInfoBoardNode:getPositionY() - curSerInfoBoardNode:getContentSize().height - 4)
        all_board:addChild(allSerInfoBoardNode)



        local otherSerTitleNode = CCNode:create()
        otherSerTitleNode:setContentSize(CCSizeMake(440, 30))
        otherSerTitleNode:setAnchorPoint(ccp(0.5, 1))
        otherSerTitleNode:setPosition(allSerInfoBoardNode:getContentSize().width * 0.5, allSerInfoBoardNode:getContentSize().height - 2)
        allSerInfoBoardNode:addChild(otherSerTitleNode);

        do 
            local titleBoardScale9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png")
            titleBoardScale9Sprite:setPreferredSize(CCSizeMake(otherSerTitleNode:getContentSize().width * 0.7, 25))
            titleBoardScale9Sprite:setColor(ccc3(252, 142,  1))
            titleBoardScale9Sprite:setAnchorPoint(ccp(0.5, 0.5))
            titleBoardScale9Sprite:setPosition(otherSerTitleNode:getContentSize().width * 0.5, otherSerTitleNode:getContentSize().height * 0.5)
            otherSerTitleNode:addChild(titleBoardScale9Sprite)

            -- local allSerTitle = CCLabelTTF:create( "其他服务器","Arial-BoldMT",12);
            local allSerTitle = CCLabelTTF:create( string_helper.game_login_scene.other_server,"Arial-BoldMT",12);
            allSerTitle:setColor(ccc3(240,170,40))
            allSerTitle:setAnchorPoint(ccp(0.5, 0.5))
            allSerTitle:setPosition(otherSerTitleNode:getContentSize().width * 0.5, otherSerTitleNode:getContentSize().height * 0.5);
            otherSerTitleNode:addChild(allSerTitle);
        end

        local allServiceListBoardNode = CCNode:create()
        allServiceListBoardNode:setContentSize(CCSizeMake(430, 145))
        allServiceListBoardNode:setAnchorPoint(ccp(0.5, 1))
        allServiceListBoardNode:setPosition(allSerInfoBoardNode:getContentSize().width * 0.5, allSerInfoBoardNode:getContentSize().height - otherSerTitleNode:getContentSize().height)
        allSerInfoBoardNode:addChild(allServiceListBoardNode);

        local allSerInfoBoardScale9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_9_32X32.png")
        allSerInfoBoardScale9Sprite:setPreferredSize(CCSizeMake(410, allServiceListBoardNode:getContentSize().height - 5))
        allSerInfoBoardScale9Sprite:setAnchorPoint(ccp(0.5, 0.5))
        allSerInfoBoardScale9Sprite:setPosition(allServiceListBoardNode:getContentSize().width * 0.5, allServiceListBoardNode:getContentSize().height * 0.5)
        allServiceListBoardNode:addChild(allSerInfoBoardScale9Sprite)

        local showSerListBoard = CCNode:create()
        showSerListBoard:setContentSize(CCSizeMake(410, allServiceListBoardNode:getContentSize().height - 10))
        showSerListBoard:setAnchorPoint(ccp(0.5, 0.5))
        showSerListBoard:setPosition(allServiceListBoardNode:getContentSize().width * 0.5, allServiceListBoardNode:getContentSize().height * 0.5)
        allServiceListBoardNode:addChild(showSerListBoard);
        self.m_showSerListBoard = showSerListBoard

        return all_board
end


--[[--
    刷新ui
]]
function game_login_scene.refreshUi(self)
    local serverData = game_data:getServerData();
    if #serverData > 0 then
        local selServer,index = game_data:getServer();
        if selServer and index then
            self.m_selServerIndex = index;
        end
        -- cclog("json.encode(selServer) ==== " .. json.encode(selServer or {}))
        -- game_util:setCCControlButtonTitle(self.m_server_btn,(selServer.sort_id + 1) .. "区 " .. selServer.server_name .. "    点击选择");
        -- game_util:setCCControlButtonTitle(self.m_server_btn,tostring(selServer.server_name) .. "    点击选择");
        game_util:setCCControlButtonTitle(self.m_server_btn,tostring(selServer.server_name) .. string_helper.game_login_scene.click);
        local uid = selServer.uid or "";
        user_token = uid;
        -- CCUserDefault:sharedUserDefault():setStringForKey("user_token",uid);
        self.m_server_btn:setVisible(true);
        game_util:setSelectServerGameUrl();
        local flag = selServer.flag or 0;
        local iconName = serverIconTab[flag+1]
        local name = selServer.server_name
        -- self.m_node_curServerBoard:removeAllChildrenWithCleanup(true)
        -- local curService = self:createAServiceNode(tostring(name), 10, iconName, nil, true)
        -- curService:setAnchorPoint(ccp(0.5, 0.5))
        -- curService:setPosition(self.m_node_curServerBoard:getContentSize().width * 0.5, self.m_node_curServerBoard:getContentSize().height * 0.5)
        -- self.m_node_curServerBoard:addChild(curService)
        if iconName and iconName ~= "" then
            local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconName);
            if tempDisplayFrame then
                self.m_server_icon:setDisplayFrame(tempDisplayFrame);
            end
            self.m_server_icon:setVisible(true);
        else
            self.m_server_icon:setVisible(false);
        end
    else
        -- game_util:setCCControlButtonTitle(self.m_server_btn,"无服务器");
        game_util:setCCControlButtonTitle(self.m_server_btn,string_helper.game_login_scene.not_server);
        user_token = "";
        -- CCUserDefault:sharedUserDefault():setStringForKey("user_token","");
        self.m_server_btn:setVisible(false);
        self.m_server_icon:setVisible(false);
    end
    CCUserDefault:sharedUserDefault():flush();
    -- user_token = CCUserDefault:sharedUserDefault():getStringForKey("user_token");
    cclog("user_token ************************************" .. tostring(user_token))
    if user_token ~= nil and user_token ~= "" then
        -- game_util:setCCControlButtonTitle(self.m_login_btn,"进入游戏")
        game_util:setCCControlButtonBackground(self.m_login_btn,"cjjs_btnJinru.png","cjjs_btnJinru.png","cjjs_btnJinru.png");
    else
        -- game_util:setCCControlButtonTitle(self.m_login_btn,"创建角色")
        game_util:setCCControlButtonBackground(self.m_login_btn,"cjjs_btnChuangjianjuese.png","cjjs_btnChuangjianjuese.png","cjjs_btnChuangjianjuese.png");
    end

    self:refreshTableView();
end

--[[
    -- 如果没有角色：推荐两个最新的服务器
    -- 如果有1个角色：推荐有角色的服务器和最新的服务器
    -- 如果有2个（含）以上角色：推荐1个最近登录的服务器和除最近登录服务器外角色等级最高的服务器 
    ]]
function game_login_scene.getRecommendServiceID( self )
   local uid_server_level = {}
   local selServer,selIndex = game_data:getServer();
   local serverData = game_data:getServerData();
   -- cclog2(serverData, " get service id serverData  ==  ")
   if #serverData <= 0 then return nil, nil end-- 没有服务器列表
   if #serverData == 1 then return 1, nil end-- 只有一个服务器

   local firstServer = selIndex or nil
   local secondServer = nil

    for i,v in pairs(serverData) do
       if type(v) == "table" then
            if v.uid ~= "" then
                uid_server_level[#uid_server_level + 1] = {serverid = i, level = v.level or 0}
            end
       end
    end
    if #uid_server_level >= 2 then
        function sortServer( data1, data2 )
            return data1.level > data2.level
        end
        table.sort(uid_server_level, sortServer)
    end

    local userCount = #uid_server_level
    local serverCount = #serverData

    if userCount == 0 then
            return 1, 2
    end

    if selIndex == serverCount then
        recommendSever = serverCount - 1
    else
        recommendSever = serverCount
    end
    -- local recommendSever = ( selIndex == serverCount ) and serverCount - 1 or serverCount
    -- cclog2(uid_server_level, "uid_server_level   ====   ")
    if not selIndex then 
        if userCount >= 1 then
            return uid_server_level[1].serverid, uid_server_level[2] and uid_server_level[2].serverid or recommendSever
        else
            return serverCount, serverCount - 1
        end
    elseif uid_server_level[1] and uid_server_level[1].serverid == selIndex then 
        return selIndex, uid_server_level[2] and uid_server_level[2].serverid or recommendSever
    else
        return selIndex, uid_server_level[1] and uid_server_level[1].serverid or recommendSever
    end
    return nil, nil
end



--[[--
    初始化
]]
function game_login_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selServerIndex = 1;
    self.m_tel_num = ""
    -- game_sound:playMusic("background_germany")
    self.m_serverListReTurn = false;
    self.m_requestCount = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_login_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_login_scene;