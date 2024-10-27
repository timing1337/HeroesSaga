---  避难所 

local game_refuge_scene = {
    m_skill_layer = nil,--技能父节点
    m_anim_node = nil,--动画节点
    m_talent_skill_story_label,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_posIconTab = nil,
    m_building_lv_label = nil,
};
--[[--
    销毁
]]
function game_refuge_scene.destroy(self)
    -- body
    cclog("-----------------game_refuge_scene destroy-----------------");
    self.m_skill_layer = nil;
    self.m_anim_node = nil;
    self.m_talent_skill_story_label = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_posIconTab = nil;
    self.m_building_lv_label = nil;
end
--[[--
    返回
]]
function game_refuge_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_refuge_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--技能
        elseif btnTag == 3 then--修炼
            game_scene:enterGameUi("skills_practice_scene",{gameData = nil});
            self:destroy();
        elseif btnTag == 4 then--技能替换
            game_scene:enterGameUi("skills_replacement_scene",{gameData = nil});
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_refuge.ccbi");
    
    self.m_skill_layer = ccbNode:layerColorForName("m_skill_layer")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_talent_skill_story_label = ccbNode:labelTTFForName("m_talent_skill_story_label")
    self.m_building_lv_label = ccbNode:labelTTFForName("m_building_lv_label")

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_tab_btn_1:setHighlighted(true);
    self.m_tab_btn_1:setEnabled(false);
    self:initSkillsTouch(self.m_skill_layer);

    local tempTab = nil;
    local tempNode = nil;
    for i=1,3 do
        tempTab = {};
        tempNode = tolua.cast(self.m_skill_layer:getChildByTag(i),"CCSprite");
        tempTab.parentNode = tempNode;
        tempTab[1] = tolua.cast(tempNode:getChildByTag(1),"CCSprite");
        tempTab[2] = tolua.cast(tempNode:getChildByTag(2),"CCLabelTTF");
        tempTab[3] = tolua.cast(tempNode:getChildByTag(3),"CCLabelTTF");
        tempTab[4] = tolua.cast(tempNode:getChildByTag(3),"CCLabelTTF");
        self.m_posIconTab[i] = tempTab;
    end
    return ccbNode;
end

--[[--
    技能触摸层
]]
function game_refuge_scene.initSkillsTouch(self,formation_layer)
    local leaderSkillConfig = getConfig(game_config_field.leader_skill);
    local tGameData = game_data:getHarborData();
    local skillData = tGameData.skill;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local tempItem = nil;
    local realPos = nil;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)

    end
    
    local function onTouchEnded(x, y)
        for endTag = 1,#self.m_posIconTab do
            realPos = self.m_posIconTab[endTag].parentNode:convertToNodeSpace(ccp(x,y));
            tempItem = self.m_posIconTab[endTag][1];
            if tempItem:boundingBox():containsPoint(realPos) then
                local skillId = tGameData["skill_" .. endTag]
                cclog("endTag ====" .. tostring(endTag) .. " ; skillId ==" .. tostring(skillId));
                game_scene:enterGameUi("skills_replacement_scene",{gameData = nil,selPosIndex = endTag});
                self:destroy();
                break;
            end
        end
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1)
    formation_layer:setTouchEnabled(true)
end

--[[--
    refresh skill
]]
function game_refuge_scene.refreshSkill(self)
    local leaderSkillConfig = getConfig(game_config_field.leader_skill);
    local tGameData = game_data:getHarborData();
    local skillData = tGameData.skill;
    local skillId = nil;
    local skillItem = nil;
    local skillCfgItem = nil;
    local skill_icon_spr_bg = nil;
    local skillLv = nil;
    for i=1,3 do
        skillId = tGameData["skill_" .. i]
        if skillId and skillId ~= 0 then
            skillCfgItem = leaderSkillConfig:getNodeWithKey(tostring(skillId));
            skillItem = tolua.cast(self.m_skill_layer:getChildByTag(i),"CCNode")
            skillLv = skillData[tostring(skillId)];
            if skillCfgItem and skillItem and skillLv then
                skill_icon_spr_bg = tolua.cast(skillItem:getChildByTag(1),"CCSprite");
                skill_icon_spr_bg:removeAllChildrenWithCleanup(true);
                local skill_icon_spr_bg_size = skill_icon_spr_bg:getContentSize();
                local skill_icon_spr = game_util:createIconByName(skillCfgItem:getNodeWithKey("icon"):toStr());
                if skill_icon_spr then
                    skill_icon_spr:setPosition(ccp(skill_icon_spr_bg_size.width*0.5,skill_icon_spr_bg_size.height*0.5));
                    skill_icon_spr_bg:addChild(skill_icon_spr);
                end
                tolua.cast(skillItem:getChildByTag(2),"CCLabelTTF"):setString(skillCfgItem:getNodeWithKey("name"):toStr());--name
                tolua.cast(skillItem:getChildByTag(3),"CCLabelTTF"):setString("Lv." .. skillLv);
                local story = game_util:formatSkillStory(skillCfgItem,skillLv);
                tolua.cast(skillItem:getChildByTag(4),"CCLabelTTF"):setString(story);
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_refuge_scene.refreshUi(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local animNode = game_util:createIdelAnim("ailisi",0,nil,nil);
    animNode:setAnchorPoint(ccp(0.5,0));
    self.m_anim_node:addChild(animNode);
    self:refreshSkill();
    self.m_building_lv_label:setString("");
end
--[[--
    初始化
]]
function game_refuge_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setHarborDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
    self.m_posIconTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_refuge_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_refuge_scene;
