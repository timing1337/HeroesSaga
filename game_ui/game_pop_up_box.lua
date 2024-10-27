---  通用弹出框

local game_pop_up_box = {};

--[[
    创建弹出框
]]
function game_pop_up_box.create(tableParams)
    tableParams = tableParams or {};
    if tableParams.onlyOneBtn == nil then
        tableParams.onlyOneBtn = true;
    end
    tableParams.touchPriority = tableParams.touchPriority or -10001
    local function defaultBtnCallback()
        game_pop_up_box.close();
    end
    if tableParams.okBtnCallBack == nil or type(tableParams.okBtnCallBack) ~= "function" then
        tableParams.okBtnCallBack = defaultBtnCallback;
    end
    if tableParams.cancelBtnCallBack == nil or type(tableParams.cancelBtnCallBack) ~= "function" then
        tableParams.cancelBtnCallBack = defaultBtnCallback;
    end
    if tableParams.closeCallBack == nil or type(tableParams.closeCallBack) ~= "function" then
        tableParams.closeCallBack = defaultBtnCallback;
    end

    if tableParams.okBtnText == nil or type(tableParams.okBtnText) ~= "string" then
        tableParams.okBtnText = string_config.m_btn_sure
    end
    if tableParams.cancelBtnText == nil or type(tableParams.cancelBtnText) ~= "string" then
        tableParams.cancelBtnText = string_config.m_btn_cancel
    end
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            tableParams.closeCallBack();
        elseif btnTag == 2 then
            tableParams.okBtnCallBack();
        elseif btnTag == 3 then
            tableParams.cancelBtnCallBack();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_title_label = ccbNode:labelBMFontForName("m_title_label")
    local m_text_label = ccbNode:labelTTFForName("m_text_label")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    local m_cancel_btn = ccbNode:controlButtonForName("m_cancel_btn");
    m_close_btn:setTouchPriority(tableParams.touchPriority - 1);
    m_ok_btn:setTouchPriority(tableParams.touchPriority - 1);
    m_cancel_btn:setTouchPriority(tableParams.touchPriority - 1);
    game_util:setCCControlButtonTitle(m_ok_btn,tableParams.okBtnText)
    game_util:setCCControlButtonTitle(m_cancel_btn,tableParams.cancelBtnText)
    if tableParams.btnUseTTF then

    else
        game_util:setControlButtonTitleBMFont(m_ok_btn)
        game_util:setControlButtonTitleBMFont(m_cancel_btn)
    end
    game_pop_up_box.m_ok_btn = m_ok_btn;
    game_pop_up_box.m_cancel_btn = m_cancel_btn;
    if tableParams.onlyOneBtn == true then
        m_cancel_btn:setVisible(false);
        local parentSize = m_ok_btn:getParent():getContentSize();
        m_ok_btn:setPositionX(parentSize.width*0.5);
    end
    local closeFlag = tableParams.closeFlag == nil and true or tableParams.closeFlag
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if closeFlag == true then
                tableParams.closeCallBack();
            end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,tableParams.touchPriority,true);
    m_root_layer:setTouchEnabled(true);

    tableParams.title = tableParams.title or string_config.m_title_prompt;
    m_title_label:setString(tableParams.title)
    tableParams.text = tableParams.text or string_config.m_operating_success;
    m_text_label:setString(tableParams.text)
    local m_anim_node = ccbNode:nodeForName("m_anim_node");
    local aninFile = "monkey";
    local loadingCfg = getConfig(game_config_field.loading)
    local level = game_data:getUserStatusDataByKey("level") or 1;
    if loadingCfg then
    local loadingItemCfg = loadingCfg:getNodeWithKey(tostring(level));
        if loadingItemCfg then
            local loading_animition = loadingItemCfg:getNodeWithKey("loading_animition");
            local anim_count = loading_animition:getNodeCount();
            if anim_count > 0 then
                aninFile = loading_animition:getNodeAt(math.random(0,anim_count-1)):toStr();
            end
        end
    end
    local animNode = game_util:createImgByName("image_" .. aninFile,0,nil,nil,1)
    if animNode then
        local animNodeSize = animNode:getContentSize();
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
    end
    return ccbNode;
end

--[[--
        local t_params = 
        {
            title = "标题",
            okBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
            cancelBtnCallBack = function(target,event) cclog("rightBtnCallBack") require("game_ui.game_pop_up_box").close(); end,   --可缺省
            okBtnText = "确定",       --可缺省
            cancelBtnText = "取消",
            text = "show message",      --可缺省
            onlyOneBtn = false,          --可缺省
        }
        require("game_ui.game_pop_up_box").show(t_params);
]]
function game_pop_up_box.show(tableParams)
    local currentScene = game_scene:getGameScene();
    assert(currentScene);
    if tableParams == nil then tableParams = {} end
    if currentScene:getChildByTag(101) == nil then
        currentScene:addChild(game_pop_up_box.create(tableParams),101,101);
    end
end
--[[--
    关闭弹出框
]]
function game_pop_up_box.close()
    local currentScene = game_scene:getGameScene();
    assert(currentScene);
    if currentScene:getChildByTag(101) ~= nil then
        currentScene:removeChildByTag(101,true);
    end
end
--[[--
    现在通用提示框
]]
function game_pop_up_box.showAlertView(message)
    if message == nil or type(message) ~= "string" then message = string_config.m_operating_success end
    local t_params = {title = string_config.m_title_prompt,okBtnText = string_config.m_btn_close,text = message}
    game_pop_up_box.show(t_params);
end

return game_pop_up_box;