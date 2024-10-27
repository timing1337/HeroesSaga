--- 帐号登陆

local account_login_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_root_layer = nil,
    m_user_name_bg = nil,
    m_passwrod_bg = nil,
    m_close_btn = nil,
    m_register_btn = nil,
    m_login_btn = nil,
    m_username = nil,
    m_passwrod = nil,
    m_callBackFunc = nil,
};
--[[--
    销毁
]]
function account_login_pop.destroy(self)
    -- body
    cclog("-----------------account_login_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_root_layer = nil;
    self.m_user_name_bg = nil;
    self.m_passwrod_bg = nil;
    self.m_close_btn = nil;
    self.m_register_btn = nil;
    self.m_login_btn = nil;
    self.m_username = nil;
    self.m_passwrod = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function account_login_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("account_login_pop");
end
--[[--
    读取ccbi创建ui
]]
function account_login_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--注册
            self:playerRegister();
        elseif btnTag == 3 then--登录
            if self.m_username == "" or self.m_passwrod == "" then
                game_util:addMoveTips({text = string_helper.account_login_pop.loginTip});
                return;
            end
            
            --用户帐号登录
            local function responseMethod(tag,gameData)
                local return_code = gameData:getNodeWithKey("status"):toInt();
                if return_code == 0 then 
                    CCUserDefault:sharedUserDefault():setStringForKey("username",self.m_username);
                    CCUserDefault:sharedUserDefault():setStringForKey("passwrod",self.m_passwrod);
                    CCUserDefault:sharedUserDefault():flush();
                    if game_data_statistics then
                        game_data_statistics:loginGame({username = self.m_username})
                    end
                    local server_list = gameData:getNodeWithKey("data"):getNodeWithKey("server_list")
                    game_data:setServerDataByJsonData(server_list)
                    local current_server = gameData:getNodeWithKey("data"):getNodeWithKey("current_server"):toStr()
                    for i, v in pairs(game_data:getServerData()) do
                        if v.server == current_server then
                            user_token = v.uid
                            -- CCUserDefault:sharedUserDefault():setStringForKey("user_token", user_token)
                            -- CCUserDefault:sharedUserDefault():flush();
                        end
                    end
                    if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
                        self.m_callBackFunc();
                    end
                    -- self:back();
                end
            end
            local params = {}
            params.account = util.url_encode(self.m_username);
            params.passwd = util.url_encode(self.m_passwrod)
            local tempCanUse = util_system:checkNoASCII(self.m_username);
            print(tempCanUse);
            if(not tempCanUse)then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_login_pop.illeageText);
                return;
            end
            local tempCanUsePass = util_system:checkNoASCII(self.m_passwrod);
            if(not tempCanUsePass)then
                require("game_ui.game_pop_up_box").showAlertView(string_helper.account_login_pop.illeageSecret);
                return;
            end
            master_url = SERVER_LIST_URL_NET;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_login"), http_request_method.GET, params,"user_login")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_account_login_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_user_name_bg = ccbNode:nodeForName("m_user_name_bg")
    self.m_passwrod_bg = ccbNode:nodeForName("m_passwrod_bg")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_register_btn = ccbNode:controlButtonForName("m_register_btn")
    self.m_login_btn = ccbNode:controlButtonForName("m_login_btn")
    game_util:setControlButtonTitleBMFont(self.m_register_btn)
    game_util:setControlButtonTitleBMFont(self.m_login_btn)
    self.m_username = CCUserDefault:sharedUserDefault():getStringForKey("username");
    if(self.m_username~=nil and string.find(self.m_username,"fake_account")~=nil)then
        self.m_username = nil;
    end
    self.m_passwrod = CCUserDefault:sharedUserDefault():getStringForKey("passwrod");

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_username = edit:getText();
            -- local tempCanUse = util_system:checkNoASCII(self.m_username);
            -- if(not tempCanUse)then
            --     require("game_ui.game_pop_up_box").showAlertView("使用了非法字符,请使用英文,下划线,以及数字");
            -- end
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_user_name_bg:getContentSize(),placeHolder=""});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_user_name_bg:addChild(editBox);
    if(self.m_username)then
        editBox:setText(self.m_username);
    end

    local function editBoxTextEventHandle2(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_passwrod = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle2,size = self.m_passwrod_bg:getContentSize(),placeHolder=""});
    editBox:setInputFlag(kEditBoxInputFlagPassword);
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_passwrod_bg:addChild(editBox);
    if(self.m_passwrod)then
        editBox:setText(self.m_passwrod);
    end

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_register_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_login_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
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
    
]]
function account_login_pop.playerRegister(self)
    local username = CCUserDefault:sharedUserDefault():getStringForKey("username");
    local enterGameFlag = CCUserDefault:sharedUserDefault():getBoolForKey("enterGameFlag");
    if enterGameFlag == nil then enterGameFlag = false end
    cclog("username ==================== " .. tostring(username))
    if username and enterGameFlag == true then
        local firstValue,_ = string.find(tostring(username),"fake_account_");
        if firstValue then--有假帐号
                    local text = string_helper.account_login_pop.fakeAccount;
                    local t_params = 
                    {
                        title = string_helper.account_login_pop.regiestTip,
                        okBtnCallBack = function(target,event)
                            cclog("okBtnCallBack -------")
                            game_util:closeAlertView();
                            game_scene:addPop("account_register_pop",{callBackFunc = self.m_callBackFunc,registerType = 1});
                            self:back();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        cancelBtnCallBack = function(target,event)
                            cclog("cancelBtnCallBack -------")
                            game_util:closeAlertView();
                            self:playerRegisterOnSure(2);
                        end,
                        okBtnText = string_helper.account_login_pop.bindAccount,       --可缺省
                        cancelBtnText = string_helper.account_login_pop.regiestNew,
                        text = text,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
        else
            game_scene:addPop("account_register_pop",{callBackFunc = self.m_callBackFunc,registerType = 2});
            self:back();
        end
    else
        game_scene:addPop("account_register_pop",{callBackFunc = self.m_callBackFunc,registerType = 2});
        self:back();
    end
end

--[[--
    
]]
function account_login_pop.playerRegisterOnSure(self)
                    local text = string_helper.account_login_pop.regiestTip;
                    local t_params = 
                    {
                        title = string_helper.account_login_pop.regiestTitle,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            game_scene:addPop("account_register_pop",{callBackFunc = self.m_callBackFunc,registerType = 2});
                            self:back();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        cancelBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        okBtnText = string_helper.account_login_pop.continueRegiest,       --可缺省
                        cancelBtnText = string_helper.account_login_pop.giveUp,
                        text = text,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
end

--[[--
    刷新ui
]]
function account_login_pop.refreshUi(self)

end

--[[--
    初始化
]]
function account_login_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_username = "";
    self.m_passwrod = "";
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function account_login_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return account_login_pop;