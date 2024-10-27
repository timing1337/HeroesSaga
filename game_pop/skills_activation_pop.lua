---   技能信息和激活弹出框 

local skills_activation_pop = {
    m_popUi = nil,
    m_posIndex = nil,
    m_shwoActivation = nil,
    m_fromPage = nil,
    m_selHeroId = nil,
    m_callFunc = nil,
    m_openType = nil,
    m_projectStatus = nil,
    m_ok_btn = nil,
    m_tips_label = nil,
    m_skillData = nil,
    m_posNode = nil,
    m_pos = nil,
    m_upFlag = nil,
    m_skill_icon = nil,
    m_progress_node = nil,
    m_name_label = nil,
    m_level_label = nil,
    m_story_label = nil,
    m_arrow_spr = nil,
    m_rate_label = nil,
    m_cd_label = nil,
    m_backupData = nil,
    skillId = nil,
    skillLevel = nil,
};
--[[--
    销毁
]]
function skills_activation_pop.destroy(self)
    -- body
    cclog("-----------------skills_activation_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_posIndex = nil;
    self.m_shwoActivation = nil;
    self.m_fromPage = nil;
    self.m_selHeroId = nil;
    self.m_callFunc = nil;
    self.m_openType = nil;
    self.m_projectStatus = nil;
    self.m_ok_btn = nil;
    self.m_tips_label = nil;
    self.m_skillData = nil;
    self.m_posNode = nil;
    self.m_pos = nil;
    self.m_upFlag = nil;
    self.m_skill_icon = nil;
    self.m_progress_node = nil;
    self.m_name_label = nil;
    self.m_level_label = nil;
    self.m_story_label = nil;
    self.m_arrow_spr = nil;
    self.m_rate_label = nil;
    self.m_cd_label = nil;
    self.m_backupData = nil;
    self.skillId = nil;
    self.skillLevel = nil;
end
--[[--
    返回
]]
function skills_activation_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("skills_activation_pop");
end
--[[--
    读取ccbi创建ui
]]
function skills_activation_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--激活
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                if self.m_openType == "skills_reset_scene" then
                    self.m_projectStatus = self.m_callFunc(btnTag,self.m_posIndex);
                    self:refreshUi();
                elseif self.m_openType == "skills_inheritance_scene" then
                    self.m_callFunc(btnTag,self.m_posIndex);
                    self:back();
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_skills_activation_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    self.m_skill_icon = tolua.cast(ccbNode:objectForName("m_skill_icon"), "CCSprite");
    self.m_progress_node = ccbNode:nodeForName("m_progress_node")
    -- self.m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"), "CCLabelBMFont");
    self.m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"), "CCLabelTTF");
    self.m_level_label = tolua.cast(ccbNode:objectForName("m_level_label"), "CCLabelBMFont");
    self.m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"), "CCLabelTTF");
    self.m_ok_btn = tolua.cast(ccbNode:objectForName("m_ok_btn"), "CCControlButton");
    self.m_tips_label = tolua.cast(ccbNode:objectForName("m_tips_label"), "CCLabelTTF");
    self.m_arrow_spr = ccbNode:spriteForName("m_arrow_spr")
    self.m_rate_label = ccbNode:labelTTFForName("m_rate_label")
    self.m_cd_label = ccbNode:labelTTFForName("m_cd_label")
    local  file57 = ccbNode:labelTTFForName("file57");
    local file58 = ccbNode:labelTTFForName("file58");
    file57:setString(string_helper.ccb.file57);
    file58:setString(string_helper.ccb.file58);

    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-15,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function skills_activation_pop.refreshSkillDetail(self)
    local skillId = self.m_skillData.s;
    local skillLevel = self.m_skillData.lv;
    -- 'avail': 1   # 0表示未解锁，1表示解锁未激活，2表示激活
    local avail = self.m_skillData.avail;
    -- cclog("skillId ====================== " .. skillId);
    local skill_detail_cfg = getConfig("skill_detail")
    local skillCfg = skill_detail_cfg:getNodeWithKey(tostring(skillId));
    local icon_size = self.m_skill_icon:getContentSize();
    local skill_icon_spr = game_util:createSkillIconByCfg(skillCfg,avail)
    if skill_icon_spr then
        skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
        self.m_skill_icon:addChild(skill_icon_spr);
    end

    if avail ~= 2 then
        local lock_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png");
        -- lock_icon_spr:setOpacity(150);
        local icon_size = self.m_skill_icon:getContentSize();
        lock_icon_spr:setPosition(icon_size.width*0.5,icon_size.height*0.5);
        self.m_skill_icon:addChild(lock_icon_spr);
    end

    self.m_name_label:setString(skillCfg:getNodeWithKey("skill_name"):toStr());
    local quality = skillCfg:getNodeWithKey("skill_quality"):toInt();
    game_util:setLabelColorByQuality(self.m_name_label,quality)
    local evo_story = skillCfg:getNodeWithKey("evo_story")
    if evo_story then
        self.m_tips_label:setString(evo_story:toStr())
    end
    self.m_level_label:setString("Lv." .. skillLevel .. "/" .. skillCfg:getNodeWithKey("max_lv"):toStr());
    local skill_story = skillCfg:getNodeWithKey("skill_story"):toStr()
    local effect = skillCfg:getNodeWithKey("effect")
    if effect then
        local attr_effect = skillCfg:getNodeWithKey("attr_effect")
        attr_effect = attr_effect ~= nil and attr_effect:toFloat() or 0
        attr_effect = string.format("%.1f",attr_effect)
        skill_story = string.gsub(skill_story,"attr",tostring(attr_effect*100));
        effect = effect:toFloat();
        local effect_lvchange = skillCfg:getNodeWithKey("effect_lvchange"):toFloat();
        effect_lvchange = string.format("%.1f",effect_lvchange)
        local tempEffect = string.format("%.1f",effect + effect_lvchange*skillLevel)
        -- if self.m_backupData then
        --     local effectBackupValue = effect + effect_lvchange*self.m_backupData.lv;
        --     -- cclog("tempEffect ==== " .. tempEffect .. " ; effectBackupValue === " .. effectBackupValue)
        --     cclog("tempEffect == " .. tempEffect .. "   eff~~~ect == " .. effect .. "  effect_lvchange ==" .. effect_lvchange .. "       skillLevel == " .. skillLevel)
        --     skill_story = string.gsub(skill_story,"effect",tostring(tempEffect .. "(" .. (effect .. "+" .. effect_lvchange .. "*" .. skillLevel .. ")")));--对敌人造成140%+10%的物理伤害
        -- else
            skill_story = string.gsub(skill_story,"effect",tostring(tempEffect));
        -- end
        self.m_story_label:setString(skill_story);
    else
        self.m_story_label:setString(skill_story);
    end
    self.m_rate_label:setString(skillCfg:getNodeWithKey("rate"):toStr() .. "%");
    self.m_cd_label:setString(skillCfg:getNodeWithKey("cd"):toStr() .. string_helper.skills_activation_pop.round);
    local bar = ExtProgressTime:createWithFrameName("public_skillExpBigBg.png","public_skillExpBig.png");
    bar:addLabelBMFont(game_util:createLabel({text = ""}));
    bar:setAnchorPoint(ccp(0,0.5));
    self.m_progress_node:addChild(bar);
    local skill_levelup_cfg = getConfig(game_config_field.skill_levelup);
    local skill_levelup_item_cfg = skill_levelup_cfg:getNodeWithKey(tostring(skillLevel))
    if skill_levelup_item_cfg then
        local tempCount = skill_levelup_item_cfg:getNodeCount();
        if quality < tempCount then
            maxExp = skill_levelup_item_cfg:getNodeAt(quality):toInt();
            if maxExp > 0 then
                bar:setMaxValue(maxExp);
                bar:setCurValue(self.m_skillData.exp,false);
            end
        end
    end
end

--[[--
    刷新ui
]]
function skills_activation_pop.refreshSkillDetailByCardId(self)
    self.m_arrow_spr:setVisible(false);
    if self.m_posNode then
        local tempPos = self.m_posNode:getAnchorPointInPoints();
        -- cclog("tolua.type(tempPos) = " .. tolua.type(tempPos) .. tempPos.x .. " ; " .. tempPos.y);
        local posNodeSize = self.m_posNode:getContentSize();
        local px,py = self.m_posNode:getPosition();
        px,py = px - tempPos.x + posNodeSize.width*0.5,py - tempPos.y + posNodeSize.height*0.5
        self.m_pos = self.m_posNode:getParent():convertToWorldSpace(ccp(px,py));

        self.m_arrow_spr:setPositionX(self.m_pos.x);
    else
        self.m_arrow_spr:setVisible(false);        
    end
    self.m_ok_btn:setVisible(false);

    local cardData,heroCfg = game_data:getCardDataById(self.m_selHeroId);
    self.m_skillData = cardData["s_" .. self.m_posIndex];
    local skillId = self.m_skillData.s;

    self:refreshSkillDetail();

    if self.m_openType == "skills_reset_scene" then
        self.m_ok_btn:setVisible(true);
        self.m_tips_label:setVisible(false);
        if self.m_projectStatus == 0 then
            game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.skills_activation_pop.lifting);
        else
            game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.skills_activation_pop.saveSkill);
        end
    elseif self.m_openType == "skills_inheritance_scene" then
        if self.m_upFlag then
            self.m_ok_btn:setVisible(true);
            self.m_tips_label:setVisible(false);
            game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.skills_activation_pop.advanceSkill);
        else
            self.m_ok_btn:setVisible(false);
            self.m_tips_label:setVisible(true);
            self.m_tips_label:setString(string_helper.skills_activation_pop.advanceDeny)
        end
    end
end

--[[--
    刷新ui
]]
function skills_activation_pop.refreshSkillDetailByData(self)
    self:refreshSkillDetail();
    self.m_ok_btn:setVisible(false);
    self.m_tips_label:setVisible(true);
end

--[[--
    刷新ui
]]
function skills_activation_pop.lookSkillByCid(self)
    local skill_detail_cfg = getConfig("skill_detail")
    local skillCfg = skill_detail_cfg:getNodeWithKey(tostring(self.skillId));
    local icon_size = self.m_skill_icon:getContentSize();
    local skill_icon_spr = game_util:createSkillIconByCfg(skillCfg)
    if skill_icon_spr then
        skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
        self.m_skill_icon:addChild(skill_icon_spr);
    end
    self.m_name_label:setString(skillCfg:getNodeWithKey("skill_name"):toStr());
    local quality = skillCfg:getNodeWithKey("skill_quality"):toInt();
    game_util:setLabelColorByQuality(self.m_name_label,quality)

    self.m_level_label:setString("Lv." .. self.skillLevel .. "/" .. skillCfg:getNodeWithKey("max_lv"):toStr());
    local skill_story = skillCfg:getNodeWithKey("skill_story"):toStr()
    local effect = skillCfg:getNodeWithKey("effect")
    if effect then
        local attr_effect = skillCfg:getNodeWithKey("attr_effect")
        attr_effect = attr_effect ~= nil and attr_effect:toFloat() or 0
        attr_effect = string.format("%.1f",attr_effect)
        skill_story = string.gsub(skill_story,"attr",tostring(attr_effect*100));
        effect = effect:toFloat();
        local effect_lvchange = skillCfg:getNodeWithKey("effect_lvchange"):toFloat();
        local tempEffect = string.format("%.1f",effect + effect_lvchange*self.skillLevel)
        skill_story = string.gsub(skill_story,"effect",tostring(tempEffect));
        self.m_story_label:setString(skill_story);
    else
        self.m_story_label:setString(skill_story);
    end
    self.m_rate_label:setString(skillCfg:getNodeWithKey("rate"):toStr() .. "%");
    self.m_cd_label:setString(skillCfg:getNodeWithKey("cd"):toStr() .. string_helper.skills_activation_pop.round);
end

--[[--
    刷新ui
]]
function skills_activation_pop.refreshUi(self)
    if self.m_openType == "lookSkillByCid" then
        self:lookSkillByCid();
    else
        if self.m_skillData then
            self:refreshSkillDetailByData();
        else
            self:refreshSkillDetailByCardId();
        end
    end
end

--[[--
    初始化
]]
function skills_activation_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_shwoActivation = t_params.shwoActivation;
    self.m_fromPage = t_params.fromPage;
    self.m_posIndex = t_params.posIndex;
    self.m_callFunc = t_params.callFunc;
    self.m_openType = t_params.openType or "";
    self.m_projectStatus = t_params.projectStatus;
    self.m_posNode = t_params.posNode;
    self.m_upFlag = t_params.upFlag or false;
    self.m_skillData = t_params.skillData;
    self.m_backupData = t_params.backupData;
    self.skillId = t_params.skillId
    self.skillLevel = t_params.skillLevel
end

--[[--
    创建ui入口并初始化数据
]]
function skills_activation_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return skills_activation_pop;