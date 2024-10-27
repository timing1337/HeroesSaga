--- 帐号注册

local account_register_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_root_layer = nil,
    m_user_name_bg = nil,
    m_passwrod_bg = nil,
    m_re_passwrod_bg = nil,
    m_close_btn = nil,
    m_cancel_btn = nil,
    m_ok_btn = nil,
    m_username = nil,
    m_passwrod = nil,
    m_rePasswrod = nil,
    m_callBackFunc = nil,
    m_registerType = nil,
    m_title_spr = nil,
};
--[[--
    销毁
]]
function account_register_pop.destroy(self)
    -- body
    cclog("-----------------account_register_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_root_layer = nil;
    self.m_user_name_bg = nil;
    self.m_passwrod_bg = nil;
    self.m_re_passwrod_bg = nil;
    self.m_close_btn = nil;
    self.m_cancel_btn = nil;
    self.m_ok_btn = nil;
    self.m_username = nil;
    self.m_passwrod = nil;
    self.m_rePasswrod = nil;
    self.m_callBackFunc = nil;
    self.m_registerType = nil;
    self.m_title_spr = nil;
end
--[[--
    返回
]]
function account_register_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("account_register_pop");
end
--[[--
    读取ccbi创建ui
]]
function account_register_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--取消
            self:back();
        elseif btnTag == 3 then--确定
            if self.m_username == "" or self.m_passwrod == "" or self.m_rePasswrod == "" then
                game_util:addMoveTips({text = string_helper.account_register_pop.inputAS});
                return;                
            end
            if self.m_passwrod ~= self.m_rePasswrod then
                game_util:addMoveTips({text = string_helper.account_register_pop.twiceTip});
                return;     
            end

            --用户注册
            local function responseMethod(tag,gameData)
                local return_code = gameData:getNodeWithKey("status"):toInt();
                if return_code == 0 then 
                    local uid = gameData:getNodeWithKey("data"):getNodeWithKey("uid");
                    if uid == nil then
                        uid = ""
                    else
                        uid = uid:toStr()
                    end
                    cclog("gameData ==" .. json.encode(gameData:getNodeWithKey("data"):getFormatBuffer()));
                    user_token = uid
                    -- CCUserDefault:sharedUserDefault():setStringForKey("user_token", user_token);
                    cclog(user_token..'=============uid=============')
                    CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                    CCUserDefault:sharedUserDefault():setStringForKey("passwrod",self.m_passwrod);
                    CCUserDefault:sharedUserDefault():flush();
                    if game_data_statistics then
                        game_data_statistics:loginGame({username = self.m_username})
                    end
                    local server_list = gameData:getNodeWithKey("data"):getNodeWithKey("server_list")
                    game_data:setServerDataByJsonData(server_list)
                    if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
                        self.m_callBackFunc();
                    end
                    -- self:back()
                end
            end
            local params = {}
            if self.m_registerType == 1 then
                params.old_account = CCUserDefault:sharedUserDefault():getStringForKey("username")
            end
            params.account = util.url_encode(self.m_username);
            params.passwd = util.url_encode(self.m_passwrod);
            -- self.m_username = edit:getText();
            local tempCanUse = util_system:checkNoASCII(self.m_username);
            print(tempCanUse);
            if(not tempCanUse)then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_register_pop.illeageText);
                return;
            end

            local tempCanUsePass = util_system:checkNoASCII(self.m_passwrod);
            if(not tempCanUsePass)then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_register_pop.illeageSecret);
                return;
            end
            local tempLen1 = string.len(self.m_username)
            if tempLen1 < 6 or tempLen1 > 20 then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_register_pop.accountLimit);
                return;
            end
            local tempLen2 = string.len(self.m_passwrod)
            if tempLen2 < 6 or tempLen2 > 20 then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_register_pop.secretLimit);
                return;
            end
            master_url = SERVER_LIST_URL_NET;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_register"), http_request_method.GET, params,"user_register");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_account_register_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_user_name_bg = ccbNode:nodeForName("m_user_name_bg")
    self.m_passwrod_bg = ccbNode:nodeForName("m_passwrod_bg")
    self.m_re_passwrod_bg = ccbNode:nodeForName("m_re_passwrod_bg")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_cancel_btn = ccbNode:controlButtonForName("m_cancel_btn")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_title_spr = ccbNode:spriteForName("m_title_spr")
    game_util:setControlButtonTitleBMFont(self.m_cancel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    self.m_username = CCUserDefault:sharedUserDefault():getStringForKey("username");
    if(self.m_username~=nil and string.find(self.m_username,"fake_account")~=nil)then
        self.m_username = nil;
    end
    self.m_passwrod = CCUserDefault:sharedUserDefault():getStringForKey("passwrod");

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("yock --- editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_username = edit:getText();
            -- local tempCanUse = util_system:checkNoASCII(self.m_username);
            -- if(not tempCanUse)then
            --     require("game_ui.game_pop_up_box").showAlertView("使用了非法字符,请使用英文,下划线,以及数字");
            -- end
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_user_name_bg:getContentSize(),placeHolder="",maxLength = 20});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_user_name_bg:addChild(editBox);
    -- if(self.m_username)then
    --     editBox:setText(self.m_username);
    -- end

    local function editBoxTextEventHandle2(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_passwrod = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle2,size = self.m_passwrod_bg:getContentSize(),placeHolder="",maxLength = 20});
    editBox:setInputFlag(kEditBoxInputFlagPassword);
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_passwrod_bg:addChild(editBox);
    -- if(self.m_passwrod)then
    --     editBox:setText(self.m_passwrod);
    -- end

    local function editBoxTextEventHandle3(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_rePasswrod = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle3,size = self.m_re_passwrod_bg:getContentSize(),placeHolder="",maxLength = 20});
    editBox:setInputFlag(kEditBoxInputFlagPassword);
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_re_passwrod_bg:addChild(editBox);

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_cancel_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
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
function account_register_pop.refreshUi(self)
    if self.m_registerType == 1 then
        self.m_title_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_zhanghaobangding.png"));
    elseif self.m_registerType == 2 then
        self.m_title_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_zhanghaozhuce.png"));
    end
end

--[[--
    初始化
]]
function account_register_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_username = "";
    self.m_passwrod = "";
    self.m_rePasswrod = "";
    self.m_callBackFunc = t_params.callBackFunc
    self.m_registerType = t_params.registerType or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function account_register_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return account_register_pop;