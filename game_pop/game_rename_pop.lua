---  修改名字

local game_rename_pop = {
    m_popUi = nil,
    m_closeCallBack = nil,
    m_editBox = nil,
    m_anim_node = nil,
};
--[[--
    销毁ui
]]
function game_rename_pop.destroy(self)
    -- body
    cclog("-----------------game_rename_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_closeCallBack = nil;
    self.m_editBox = nil;
    self.m_anim_node = nil;
end
--[[--
    返回
]]
function game_rename_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    if self.m_closeCallBack and type(self.m_closeCallBack) == "function" then
        self.m_closeCallBack();
    end
    -- self:destroy();
    game_scene:removePopByName("game_rename_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_rename_pop.createUi(self)
    math.randomseed(os.time());    
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            local editText = self.m_editBox:getText();
            local playerName = util.url_encode(editText)
            if playerName == nil or playerName == "" then
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnText = string_config.m_re_input,       --可缺省
                    text = string_config.m_no_input_name,      --可缺省
                }
                game_util:openAlertView(t_params);
                return;
            end
            local function responseMethod(tag,gameData)
                -- if device_platform == "android" then
                    require("shared.native_helper").getUserName(playerName)
                -- end
                self:back();
            end
            --
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_rename"), http_request_method.GET, {show_name=playerName},"user_rename")
        elseif btnTag == 3 then--随机
            self:randomName();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_rename_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    m_edit_bg_node:setOpacity(0);
    local m_title_label = ccbNode:labelTTFForName("m_title_label")
    m_title_label:setString(string_config.m_input_role_name)
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    local m_random_btn = ccbNode:controlButtonForName("m_random_btn")

    game_util:setCCControlButtonTitle(m_ok_btn,string_config.m_btn_sure);
    game_util:setCCControlButtonTitle(m_random_btn,string_config.m_random);
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_random_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local id = game_guide_controller:getCurrentId();
    if id == 3 then
        m_close_btn:setVisible(false)
    end

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            editText = edit:getText();
            edit:setFontColor(ccc3(0,0,0));
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = m_edit_bg_node:getContentSize(),maxLength = 14});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_edit_bg_node:addChild(self.m_editBox);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    self:randomName();
    return ccbNode;
end

--[[--
    
]]
function game_rename_pop.randomName(self)
    local random_first_name = getConfig(game_config_field.random_first_name)
    local random_first_count = random_first_name:getNodeCount();
    local random_last_name = getConfig(game_config_field.random_last_name)
    local random_last_count = random_last_name:getNodeCount();

    local first_name = "";
    if random_first_count > 0 then
        first_name = random_first_name:getNodeAt(math.random(1,random_first_count) - 1):toStr();
    end
    local last_name = "";
    if random_last_count > 0 then
        last_name = random_last_name:getNodeAt(math.random(1,random_last_count) - 1):toStr();
    end
    local editText = first_name .. last_name;
    self.m_editBox:setText(editText)
    self.m_editBox:setFontColor(ccc3(139,0,0));
end

--[[--
    刷新ui
]]
function game_rename_pop.refreshUi(self)
    local tempImg = game_util:createOwnBigImg();
    if tempImg then
        self.m_anim_node:addChild(tempImg);
    end
end
--[[--
    初始化
]]
function game_rename_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_closeCallBack = t_params.closeCallBack;
end

--[[--
    创建ui入口并初始化数据
]]
function game_rename_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_rename_pop;