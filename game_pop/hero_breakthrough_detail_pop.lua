---  突破信息

local hero_breakthrough_detail_pop = {
    m_popUi = nil,
    m_story_label_1 = nil,
    m_story_label_2 = nil,
    m_break_icon = nil,
    m_tips_label = nil,
    m_cardCfgId = nil,
    m_breValue = nil,
    m_selBreValue = nil,
    m_ccbNode = nil,
    m_title_label = nil,
    m_title_label_1 = nil,
    m_title_label_2 = nil,
};
--[[--
    销毁
]]
function hero_breakthrough_detail_pop.destroy(self)
    -- body
    cclog("-----------------hero_breakthrough_detail_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_story_label_1 = nil;
    self.m_story_label_2 = nil;
    self.m_break_icon = nil;
    self.m_tips_label = nil;
    self.m_cardCfgId = nil;
    self.m_breValue = nil;
    self.m_selBreValue = nil;
    self.m_ccbNode = nil;
    self.m_title_label = nil;
    self.m_title_label_1 = nil;
    self.m_title_label_2 = nil;
end


--[[--
    返回
]]
function hero_breakthrough_detail_pop.back(self,type)
    game_scene:removePopByName("hero_breakthrough_detail_pop");
end
--[[--
    读取ccbi创建ui
]]
function hero_breakthrough_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_breakthrough_detail_pop.ccbi");

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    m_root_layer:setTouchEnabled(true);

    local m_stroy_label_1 = ccbNode:nodeForName("m_stroy_label_1")
    local m_stroy_label_2 = ccbNode:nodeForName("m_stroy_label_2")
    self.m_story_label_1 = game_util:createRichLabelTTF({text = "ddd",dimensions = m_stroy_label_1:getContentSize(),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    self.m_story_label_1:setAnchorPoint(ccp(0, 0))
    m_stroy_label_1:addChild(self.m_story_label_1)
    self.m_story_label_2 = game_util:createRichLabelTTF({text = "ddd",dimensions = m_stroy_label_2:getContentSize(),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})     
    self.m_story_label_2:setAnchorPoint(ccp(0, 0))
    m_stroy_label_2:addChild(self.m_story_label_2)
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_title_label_1 = ccbNode:labelTTFForName("m_title_label_1")
    self.m_title_label_2 = ccbNode:labelTTFForName("m_title_label_2")
    self.m_break_icon = ccbNode:spriteForName("m_break_icon")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_ccbNode = ccbNode;

    self.m_title_label_1:setString(string_helper.ccb.text232)
    self.m_title_label_2:setString(string_helper.ccb.text233)
    return ccbNode;
end
--[[--
    刷新ui
]]
function hero_breakthrough_detail_pop.refreshUi(self)
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local itemCfg = character_detail_cfg:getNodeWithKey(tostring(self.m_cardCfgId));
    if itemCfg then
        local character_break_cfg = getConfig(game_config_field.character_break_new)
        local character_ID = itemCfg:getKey()--itemCfg:getNodeWithKey("character_ID"):toStr();
        local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("kpxq_break_" .. self.m_selBreValue .. ".png")
        if tempSpriteFrame then
            self.m_break_icon:setDisplayFrame(tempSpriteFrame);
        end
        local break_story = character_break_item:getNodeWithKey("break_story" .. self.m_selBreValue)
        if break_story then
            break_story = break_story:toStr();
        else
            break_story = string_helper.hero_breakthrough_detail_pop.none
        end
        local story_detail = character_break_item:getNodeWithKey("story_detail" .. self.m_selBreValue)
        if story_detail then
            story_detail = story_detail:toStr();
        else
            story_detail = string_helper.hero_breakthrough_detail_pop.none;
        end
        CCLuaLog("story_detail == " .. story_detail)
        CCLuaLog("none == " .. string_helper.hero_breakthrough_detail_pop.none)
        if story_detail ~= string_helper.hero_breakthrough_detail_pop.none and story_detail ~= "" then
            self.m_ccbNode:runAnimations("anim_1")
            self.m_story_label_1:setString(break_story);
            self.m_story_label_2:setString(story_detail);
        else
            self.m_ccbNode:runAnimations("anim_2")
            self.m_title_label_2:setString(string_helper.hero_breakthrough_detail_pop.strengthen)
            self.m_story_label_2:setString(break_story);
        end
        local tempStr = game_util:getBreakLevelDes(self.m_selBreValue)

        self.m_title_label:setString(tostring(tempStr) .. " " .. string_helper.hero_breakthrough_detail_pop.zhuan)
        -- self.m_title_label:setFontSize( 10)
        if self.m_selBreValue > self.m_breValue then--未开启
            local break_control_cfg = getConfig(game_config_field.break_control)
            local break_control_item = break_control_cfg:getNodeWithKey(tostring(self.m_selBreValue))
            if break_control_item then
                local need_level = break_control_item:getNodeWithKey("need_level"):toInt();
                self.m_tips_label:setString(string.format(string_helper.hero_breakthrough_detail_pop.zhuanInfo,need_level))
            end
            self.m_break_icon:setColor(ccc3(81, 81, 81))
        end
    end
end

--[[--
    初始化
]]
function hero_breakthrough_detail_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cardCfgId = t_params.cardCfgId
    self.m_breValue = t_params.breValue or 0;
    if self.m_breValue < 0 then
        self.m_breValue = 0;
    elseif self.m_breValue > 5 then
        -- self.m_breValue = 5;
    end
    self.m_selBreValue = t_params.selBreValue or 0;
    if self.m_selBreValue < 0 then
        self.m_selBreValue = 0;
    elseif self.m_selBreValue > 5 then
        -- self.m_selBreValue = 5;
    end
end

--[[--
    创建ui入口并初始化数据
]]
function hero_breakthrough_detail_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return hero_breakthrough_detail_pop;