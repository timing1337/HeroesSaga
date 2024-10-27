--- 游戏加载动画

local game_loading = {};

--create loading layer
--[[--
    创建加载ui
]]
function game_loading.create(paramTable)
    if paramTable == nil then paramTable = {} end
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    if paramTable.opacity == nil or type(paramTable.opacity) ~= "number" then
        paramTable.opacity = 200;
    end
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_game_loading.ccbi");
    local m_root_node = ccbNode:layerForName("m_root_node")
    local m_color_layer = ccbNode:layerColorForName("m_color_layer")
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    local m_loading_tips_label = ccbNode:labelTTFForName("m_loading_tips_label")
    m_loading_tips_label:setVisible(false);
    m_color_layer:setOpacity(paramTable.opacity)
    if paramTable.opacity ~= 0 then
        -- local mAnimNode = game_util:createEffectAnim("loading2",1,true)
        -- mAnimNode:setPosition(ccp(visibleSize.width*0.5,visibleSize.height*0.25));
        -- m_root_node:addChild(mAnimNode)
        local aninFile = "ailisi";
        local loadingCfg = getConfig(game_config_field.loading)
        local loadingtipsCfg = getConfig(game_config_field.loadingtips)
        local level = game_data:getUserStatusDataByKey("level") or 1;
        if loadingCfg and loadingtipsCfg then
        local loadingItemCfg = loadingCfg:getNodeWithKey(tostring(level));
            if loadingItemCfg then
                local loading_animition = loadingItemCfg:getNodeWithKey("loading_animition");
                local anim_count = loading_animition:getNodeCount();
                if anim_count > 0 then
                    aninFile = loading_animition:getNodeAt(math.random(0,anim_count-1)):toStr();
                end
                local loadingtips = loadingItemCfg:getNodeWithKey("loadingtips");
                local loadingtips_count = loadingtips:getNodeCount();
                if loadingtips_count > 0 then
                    local loadingtipsItemCfg = loadingtipsCfg:getNodeWithKey(loadingtips:getNodeAt(math.random(0,loadingtips_count-1)):toStr());
                    if loadingtipsItemCfg then
                        m_loading_tips_label:setString(loadingtipsItemCfg:getNodeWithKey("tips_detail"):toStr());
                    end
                end
            end
        end
        m_loading_tips_label:setVisible(true);
        m_anim_node:removeAllChildrenWithCleanup(true);
        local animNode = game_util:createAnimSequence(aninFile,0,nil,nil);
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
            m_anim_node:addChild(animNode);
        end
    else
        ccbNode:runAnimations("no_anim")
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_node:registerScriptTouchHandler(onTouch,false,-1000,true);
    m_root_node:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    显示加载
]]
function game_loading.show(paramTable)
    paramTable = paramTable or {};
    local currentScene = paramTable.currentScene;
    if currentScene == nil then
        currentScene = game_scene:getGameScene();
    end
    if currentScene == nil then return end
    if currentScene:getChildByTag(100) == nil then
        currentScene:addChild(game_loading.create(paramTable),100,100);
    end
end
--[[--
    关闭加载
]]
function game_loading.close()
    local currentScene = game_scene:getGameScene();
    if currentScene == nil then return end
    if currentScene:getChildByTag(100) ~= nil then
        currentScene:removeChildByTag(100,true);
    end
end

return game_loading;