---  游戏设置

local game_setting_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_music_spr = nil,
    m_sound_spr = nil,
    m_music_bar_node = nil,
    m_sound_bar_node = nil,
    m_music_btn = nil,
    m_sound_btn = nil,
    m_musicSlider = nil,
    m_soundSlider = nil,
    m_musicFlag = nil,
    m_soundFlag = nil,
    m_temp_btn = nil,
};
--[[--
    销毁
]]
function game_setting_pop.destroy(self)
    -- body
    cclog("-----------------game_setting_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_left_btn = nil;
    self.m_right_btn = nil;
    self.m_music_spr = nil;
    self.m_sound_spr = nil;
    self.m_music_bar_node = nil;
    self.m_sound_bar_node = nil;
    self.m_music_btn = nil;
    self.m_sound_btn = nil;
    self.m_musicSlider = nil;
    self.m_soundSlider = nil;
    self.m_musicFlag = nil;
    self.m_soundFlag = nil;
    self.m_temp_btn = nil;
    CCUserDefault:sharedUserDefault():flush();
end
--[[--
    返回
]]
function game_setting_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_setting_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_setting_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--绑定帐号
            -- self:back();
            -- local function callBackFunc()
                -- game_scene:removePopByName("account_register_pop")
            -- end
            -- game_scene:addPop("account_register_pop",{callBackFunc = callBackFunc});

            --退出游戏
            if getPlatFormExt() == "91android" then
                cclog("91android91android91android91android")
                require("shared.native_helper").exitGame()
            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                     require("shared.native_helper").platformExit(function()end);
                       --  关闭聊天
                        game_data:resetChatObserver()
                        exitGame();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = string_helper.game_setting_pop.certain,       --可缺省
                    text = string_helper.game_setting_pop.quit,      --可缺省
                    closeFlag = true,
                }
                game_util:openAlertView(t_params);
            end
        elseif btnTag == 3 then--重新登录
            --  关闭聊天
            game_data:resetChatObserver()
            if game_data_statistics then
                game_data_statistics:logoutGame()
            end
            if getPlatForm() == "cmge" then
                PLATFORM_CMGE.logout()
            elseif getPlatForm() == "cmgeapp" then
                PLATFORM_CMGE_APP.logout()
            end
            game_scene:setVisibleBroadcastNode(false);
            game:resourcesDownload();
            self:back();

            require("shared.native_helper").logOut(nil)
        elseif btnTag == 4 then--音乐按钮
            self:refreshMusic();
        elseif btnTag == 5 then--音效按钮
            self:refreshSound();
        elseif btnTag == 101 then--内测返还
            self:back();
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local products = json.decode(data:getNodeWithKey("products"):getFormatBuffer()) or {};
                local gameShopConfig = getConfig(game_config_field.charge);
                local tempStr = ""
                for k,v in pairs(products) do
                    local itemCfg = gameShopConfig:getNodeWithKey(tostring(k))
                    if itemCfg then
                        local price = itemCfg:getNodeWithKey("price"):toInt();
                        local name = itemCfg:getNodeWithKey("name"):toStr();
                        tempStr = tempStr .. string.format("%d元(%s)X%d，",price,name,v)
                    end
                end
                local tempText = "您在上次测试中，一共购买了 ：" .. tempStr .. "\n所有购买项双倍返还，周礼包及月礼包返还980钻石X2，您在所有的服务器中，只能领取一次删档测试充值返还,是否确定领取？"

                local t_params = 
                {
                    title = "内测返还",
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local coins = data:getNodeWithKey("coins"):toInt();
                            game_util:rewardTipsByDataTable({coin = coins});
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_get_pay_award"), http_request_method.GET, nil,"user_get_pay_award")
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                    end,
                    okBtnText = "领取",       --可缺省
                    text = tempText,      --可缺省
                }
                game_util:openAlertView(t_params);
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_watch_pay_award"), http_request_method.GET, nil,"user_watch_pay_award")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_setting.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_music_spr = ccbNode:spriteForName("m_music_spr")
    self.m_sound_spr = ccbNode:spriteForName("m_sound_spr")
    self.m_music_bar_node = ccbNode:nodeForName("m_music_bar_node")
    self.m_sound_bar_node = ccbNode:nodeForName("m_sound_bar_node")
    self.m_music_btn = ccbNode:controlButtonForName("m_music_btn")
    self.m_sound_btn = ccbNode:controlButtonForName("m_sound_btn")
    self.m_temp_btn = ccbNode:controlButtonForName("m_temp_btn")
    local set_label = ccbNode:labelTTFForName("set_label");
    set_label:setString(string_helper.ccb.file29);
    local function callFunc(event,target)
        local pSlider = tolua.cast(target,"CCControlSlider")
        local tag = pSlider:getTag();
        local value =  pSlider:getValue();
        if tag == 1 then
            if self.m_musicFlag == true then
                audio.setMusicVolume(value)
                CCUserDefault:sharedUserDefault():setFloatForKey("musicVolume",value)
            end
        elseif tag == 2 then
            if self.m_soundFlag == true then
                audio.setSoundsVolume(value)
                CCUserDefault:sharedUserDefault():setFloatForKey("soundsVolume",value)
            end
        end
    end
    self.m_musicSlider = CCControlSlider:create(CCSprite:createWithSpriteFrameName("o_public_inner.png"),CCSprite:createWithSpriteFrameName("o_public_outer.png"),CCSprite:createWithSpriteFrameName("public_barBtn.png"));
    self.m_musicSlider:setAnchorPoint(ccp(0.5, 0.5));
    self.m_musicSlider:setMinimumValue(0.0);
    self.m_musicSlider:setMaximumValue(1.0);
    self.m_musicSlider:setTag(1);
    self.m_musicSlider:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_musicSlider:addHandleOfControlEvent(callFunc,CCControlEventValueChanged);
    self.m_music_bar_node:addChild(self.m_musicSlider)

    self.m_soundSlider = CCControlSlider:create(CCSprite:createWithSpriteFrameName("o_public_inner.png"),CCSprite:createWithSpriteFrameName("o_public_outer.png"),CCSprite:createWithSpriteFrameName("public_barBtn.png"));
    self.m_soundSlider:setAnchorPoint(ccp(0.5, 0.5));
    self.m_soundSlider:setMinimumValue(0.0);
    self.m_soundSlider:setMaximumValue(1.0);
    self.m_soundSlider:setTag(2);
    self.m_soundSlider:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_soundSlider:addHandleOfControlEvent(callFunc,CCControlEventValueChanged);
    self.m_sound_bar_node:addChild(self.m_soundSlider)

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_music_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_sound_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_temp_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_temp_btn:setVisible(false)

    -- self.m_left_btn:setVisible(false)
    
    self.m_left_btn:setTitleForState(CCString:create(string_helper.game_setting_pop.quitGamge),CCControlStateNormal)
    local tempSize = self.m_left_btn:getParent():getContentSize();
    -- if getPlatForm() == "91" then
        self.m_left_btn:setVisible(false)
        self.m_right_btn:setPositionX(tempSize.width*0.5)
    -- else
    --     self.m_left_btn:setPositionX(tempSize.width*0.3)
    --     self.m_right_btn:setPositionX(tempSize.width*0.7)
    -- end

    -- game_util:setControlButtonTitleBMFont(self.m_music_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_sound_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_left_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_right_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_temp_btn)
    game_util:setCCControlButtonTitle(self.m_music_btn,string_helper.ccb.file24)
    game_util:setCCControlButtonTitle(self.m_sound_btn,string_helper.ccb.file25)
    game_util:setCCControlButtonTitle(self.m_left_btn,string_helper.ccb.file27)
    game_util:setCCControlButtonTitle(self.m_right_btn,string_helper.ccb.file28)
    game_util:setCCControlButtonTitle(self.m_temp_btn,string_helper.ccb.file26)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_setting_pop.refreshMusic(self)
    local musicFlag = CCUserDefault:sharedUserDefault():getBoolForKey("musicFlag")
    if musicFlag == nil then
        musicFlag = true;
    end
    if musicFlag then
        -- game_util:setCCControlButtonTitle(self.m_music_btn,"开启音乐")
        -- self.m_music_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_musicOff.png"));
        audio.pauseMusic();
        musicFlag = false;
        CCUserDefault:sharedUserDefault():setFloatForKey("musicVolume",0)
    else
        -- game_util:setCCControlButtonTitle(self.m_music_btn,"关闭音乐")
        -- self.m_music_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_musicOn.png"));
        audio.resumeMusic();
        musicFlag = true;
        CCUserDefault:sharedUserDefault():setFloatForKey("musicVolume",1)
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("musicFlag",musicFlag)
    CCUserDefault:sharedUserDefault():flush();
    if musicFlag == true then
        game_sound:playMusic("background_home",true);
    end
    self:refreshUi();
end

--[[--
    刷新ui
]]
function game_setting_pop.refreshSound(self)
    local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
    if soundFlag == nil then
        soundFlag = true;
    end
    if soundFlag then
        -- game_util:setCCControlButtonTitle(self.m_sound_btn,"开启音效")
        -- self.m_sound_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_soundOff.png"));
        audio.pauseAllSounds();
        soundFlag = false;
        CCUserDefault:sharedUserDefault():setFloatForKey("soundsVolume",0)
    else
        -- game_util:setCCControlButtonTitle(self.m_sound_btn,"关闭音效")
        -- self.m_sound_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_soundOn.png"));
        audio.resumeAllSounds();
        soundFlag = true;
        CCUserDefault:sharedUserDefault():setFloatForKey("soundsVolume",1)
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("soundFlag",soundFlag)
    CCUserDefault:sharedUserDefault():flush();
    self:refreshUi();
end

--[[--
    刷新ui
]]
function game_setting_pop.refreshUi(self)
    local musicVolume = CCUserDefault:sharedUserDefault():getFloatForKey("musicVolume")
    if musicVolume == nil then
        musicVolume = audio.getMusicVolume()
        CCUserDefault:sharedUserDefault():setFloatForKey("musicVolume",musicVolume);
    end
    local soundsVolume = CCUserDefault:sharedUserDefault():getFloatForKey("soundsVolume")
    if soundsVolume == nil then
        soundsVolume = audio.getSoundsVolume()
        CCUserDefault:sharedUserDefault():setFloatForKey("soundsVolume",soundsVolume);
    end
    cclog("musicVolume ==" .. musicVolume .. " ; soundsVolume == " .. soundsVolume)
    self.m_musicSlider:setValue(musicVolume);
    audio.setMusicVolume(musicVolume)
    self.m_soundSlider:setValue(soundsVolume);
    audio.setSoundsVolume(soundsVolume)

    local musicFlag = CCUserDefault:sharedUserDefault():getBoolForKey("musicFlag")
    self.m_musicFlag = musicFlag
    if musicFlag == nil or musicFlag == true then
        game_util:setCCControlButtonTitle(self.m_music_btn,string_helper.game_setting_pop.closeMusic)
        self.m_music_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_musicOn.png"));
    else
        game_util:setCCControlButtonTitle(self.m_music_btn,string_helper.game_setting_pop.openMusic)
        self.m_music_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_musicOff.png"));
    end
    local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
    self.m_soundFlag = soundFlag;
    if soundFlag == nil or soundFlag == true then
        game_util:setCCControlButtonTitle(self.m_sound_btn,string_helper.game_setting_pop.closeEffect)
        self.m_sound_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_soundOn.png"));
    else
        game_util:setCCControlButtonTitle(self.m_sound_btn,string_helper.game_setting_pop.openEffect)
        self.m_sound_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_soundOff.png"));
    end   
    CCUserDefault:sharedUserDefault():flush();
end

--[[--
    初始化
]]
function game_setting_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
end

--[[--
    创建ui入口并初始化数据
]]
function game_setting_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_setting_pop;