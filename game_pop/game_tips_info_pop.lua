---  介绍、tip、info等

local game_tips_info_pop = {
    m_node_listbg = nil,
    m_tGameData = nil,
    search_treasure = nil,
    m_notice_key = nil,
};
--[[--
    销毁ui
]]
function game_tips_info_pop.destroy(self)
    -- body
    cclog("----------------- game_tips_info_pop destroy-----------------"); 
    self.m_node_listbg = nil;
    self.m_tGameData = nil;
    self.search_treasure = nil;
    self.m_notice_key = nil;
end
--[[--
    返回
]]
function game_tips_info_pop.back(self)
    game_scene:removePopByName("game_tips_info_pop");
    -- self.endFunc()
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_tips_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    -- local function onBtnClick( target,event )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    --     -- print("press button tag is ", btnTag)
    --     if btnTag == 1 then -- 关闭
    --         self:back()
    --     end
    -- end

    -- ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_info_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local activity_open_label = ccbNode:labelBMFontForName("activity_open_label")
    local content_label = ccbNode:labelTTFForName("content_label")

    -- local activeCfg = getConfig(game_config_field.active_cfg)
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( tostring(self.m_notice_key) )
    local des = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    content_label:setString(des)
    -- local open_time_word = itemCfg:getNodeWithKey("open_time_word"):toStr()
    -- activity_open_label:setString(open_time_word)

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        elseif eventType == "ended" then
            self:back()
        end 
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_tips_info_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_tips_info_pop.init(self,t_params)
    t_params = t_params or {}
    self.endFunc = t_params.endFunc
    -- cclog2(t_params, "t_params  ====  ")
    self.m_notice_key = t_params.notice_key or "117"
end
--[[--
    创建ui入口并初始化数据
]]
function game_tips_info_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_tips_info_pop