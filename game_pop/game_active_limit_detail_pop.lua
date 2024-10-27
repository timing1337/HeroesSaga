--- 活动详细

local game_active_limit_detail_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    title_label = nil,
    content_label = nil,
    award_node = nil,
    m_reward_btn = nil, 
    fuken_node = nil,
    content_node = nil,
    show_node = nil,
    text_scroll = nil,
    m_enterType = nil,
    m_openType = nil,
    callBackFunc = nil,
    m_cfgKey = nil,
};
--[[--
    销毁
]]
function game_active_limit_detail_pop.destroy(self)
    -- body
    cclog("-----------------game_active_limit_detail_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.title_label = nil;
    self.content_label = nil;
    self.award_node = nil;
    self.m_reward_btn = nil;
    self.fuken_node = nil;
    self.content_node = nil;
    self.show_node = nil;
    self.text_scroll = nil;
    m_enterType = nil;
    self.m_openType = nil;
    self.callBackFunc = nil;
    self.m_cfgKey = nil;
end
--[[--
    返回
]]
function game_active_limit_detail_pop.back(self,type)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_active_limit_detail_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_active_limit_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_limit_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    self.content_node = ccbNode:nodeForName("content_node")
    local detail_label = ccbNode:labelTTFForName("detail_label")
    detail_label:setVisible(false)

    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    内容列表
]]
function game_active_limit_detail_pop.createContentTable(self,viewSize)
    local contentText = "";
    if self.m_openMsg then
        contentText = self.m_openMsg
    elseif self.m_openType == "game_lucky_turntable" then
        local roulette_cfg = getConfig(game_config_field.roulette)
        local roulette_cfg_item = roulette_cfg:getNodeWithKey(tostring(self.m_enterType))
        if roulette_cfg_item then
            contentText = roulette_cfg_item:getNodeWithKey("instruction"):toStr();
        end
    elseif self.m_openType == "game_lucky_turntable_server" then
        local roulette_cfg = getConfig(game_config_field.server_roulette)
        local roulette_cfg_item = roulette_cfg:getNodeWithKey(tostring(self.m_enterType))
        if roulette_cfg_item then
            contentText = roulette_cfg_item:getNodeWithKey("instruction"):toStr();
        end
    elseif self.m_openType == "game_topplayer_scene" then
        contentText = string_helper.game_active_limit_detail_pop.topPlayer
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "119" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    elseif self.m_openType == "game_offering_sacrifices" then
        contentText = string_helper.game_active_limit_detail_pop.sacrifice
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "118" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    elseif self.m_openType == "map_world_scene" then
        contentText = string_helper.game_active_limit_detail_pop.heroRoad
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "123" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    elseif self.m_openType == "game_sky_star" then
        contentText = string_helper.game_active_limit_detail_pop.diamond
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "124" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "130" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    elseif self.m_openType == "equip_enchanting" then
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "132" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    elseif self.m_openType == "gem_system_synthesis" then
        local activeCfg = getConfig(game_config_field.notice_active)
        local itemCfg = activeCfg:getNodeWithKey( "134" )
        contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
        
    elseif self.m_cfgKey ~= nil then
        local activeCfg = getConfig(game_config_field.server_inreview)
        local itemCfg = activeCfg:getNodeWithKey( tostring(self.m_cfgKey) )
        contentText = itemCfg and itemCfg:getNodeWithKey("story") and itemCfg:getNodeWithKey("story"):toStr() or string_helper.game_active_limit_detail_pop.defaultText
    else
        local key = self.m_enterType or "110"
        local detailCfg = getConfig(game_config_field.notice_active);
        local detailCfgTab = json.decode(detailCfg:getFormatBuffer())
        local itemCfg = detailCfgTab[tostring(key)]
        contentText = itemCfg and itemCfg.word or ""

    end
    -- local tempLabel = game_util:createLabelTTF({text = contentText,color = ccc3(255,255,255),fontSize = 12})
    -- tempLabel:setDimensions(CCSizeMake(210,0))
    -- tempLabel:setAnchorPoint(ccp(0,0))
    -- tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    -- tempLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(210,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(210,tempSize.height))
    -- if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    -- end
    self.text_scroll:addChild(tempLabel)
end

--[[--
    刷新ui
]]
function game_active_limit_detail_pop.refreshUi(self)
    self:createContentTable(self.content_node:getContentSize())
end
--[[--
    初始化
]]
function game_active_limit_detail_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_enterType = t_params.enterType or "110"
    self.m_openType = t_params.openType or "";
    self.m_openMsg = t_params.openMsg or nil
    self.callBackFunc = t_params.callBackFunc
    self.m_cfgKey = t_params.cfgKey;
end
--[[--
    创建ui入口并初始化数据
]]
function game_active_limit_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_active_limit_detail_pop.callBackFunc(self)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc();
    end
end

return game_active_limit_detail_pop;