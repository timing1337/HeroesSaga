--- 技能修炼弹出框

local skills_practice_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_skillId = nil,
    m_callBackFunc = nil,
    m_skillTotalLevel = nil,
    m_treeId = nil,
    m_treeTable = nil,
    m_node = nil,
    m_cost_node_1 = nil,
    m_cost_energy_label = nil,
    m_energy_total_label = nil,
    m_cost_gold_label = nil,
    m_gold_total_label = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_right_btn2 = nil,
    m_guildNode = nil,
    is_tips = nil,
};
--[[--
    销毁
]]
function skills_practice_pop.destroy(self)
    -- body
    cclog("-----------------skills_practice_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_skillId = nil;
    self.m_callBackFunc = nil;
    self.m_skillTotalLevel = nil;
    self.m_treeId = nil;
    self.m_treeTable = nil;
    self.m_node = nil;
    self.m_cost_node_1 = nil;
    self.m_cost_energy_label = nil;
    self.m_energy_total_label = nil;
    self.m_cost_gold_label = nil;
    self.m_gold_total_label = nil;
    self.m_left_btn = nil;
    self.m_right_btn = nil;
    self.m_right_btn2 = nil;
    self.m_guildNode = nil;
    self.is_tips = nil;
end
--[[--
    返回
]]
function skills_practice_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removeGuidePop();
    game_scene:removePopByName("skills_practice_pop");
end
--[[--
    读取ccbi创建ui
]]
function skills_practice_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag ==2 then--升到满级
            local function responseMethod(tag,gameData)
                game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                self:callBackFunc();
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_train"), http_request_method.GET,{skill = self.m_skillId,is_max = 1},"leader_skill_train")
        elseif btnTag ==3 then--升一级
            game_scene:removeGuidePop();
            local function responseMethod(tag,gameData)
                local id = game_guide_controller:getIdByTeam("13");
                if id == 1303 and self.m_guildNode then
                    game_guide_controller:gameGuide("send","13",1303)
                end
                game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                self:callBackFunc();
                self:back();
            end
            if self.is_tips == true then
                local t_params = 
                {
                    m_openType = 12,
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_train"), http_request_method.GET,{skill = self.m_skillId},"leader_skill_train")
            end
        elseif btnTag == 4 then--升满
            game_scene:removeGuidePop();
            local function responseMethod(tag,gameData)
                local id = game_guide_controller:getIdByTeam("13");
                if id == 1303 and self.m_guildNode then
                    game_guide_controller:gameGuide("send","13",1303)
                end
                game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                self:callBackFunc();
                self:back();
            end
            if self.is_tips == true then
                local t_params = 
                {
                    m_openType = 12,
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_train"), http_request_method.GET,{skill = self.m_skillId,is_max = 1},"leader_skill_train")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_skills_practice_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node = ccbNode:nodeForName("m_node")
    local m_name_label = ccbNode:labelBMFontForName("m_name_label")
    local m_level_label = ccbNode:labelBMFontForName("m_level_label")
    local m_story_label = ccbNode:labelTTFForName("m_story_label")
    local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_right_btn2 = ccbNode:controlButtonForName("m_right_btn2")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_skill_icon = ccbNode:spriteForName("m_skill_icon")
    local m_ready_time_label = ccbNode:labelBMFontForName("m_ready_time_label")
    local m_anger_consume_label = ccbNode:labelBMFontForName("m_anger_consume_label")
    local m_cool_time_label = ccbNode:labelBMFontForName("m_cool_time_label")
    local text1 = ccbNode:labelTTFForName("text1");
    local text2 = ccbNode:labelTTFForName("text2");
    local text3 = ccbNode:labelTTFForName("text3");
    text1:setString(string_helper.ccb.file37);
    text2:setString(string_helper.ccb.file38);
    text3:setString(string_helper.ccb.file39);
    self.m_cost_node_1 = ccbNode:nodeForName("m_cost_node_1")
    self.m_cost_energy_label = ccbNode:labelTTFForName("m_cost_energy_label")
    self.m_energy_total_label = ccbNode:labelTTFForName("m_energy_total_label")
    self.m_cost_gold_label = ccbNode:labelTTFForName("m_cost_gold_label")
    self.m_gold_total_label = ccbNode:labelTTFForName("m_gold_total_label")

    self.m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_right_btn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonTitle(self.m_right_btn,string_helper.ccb.title64)
    game_util:setCCControlButtonTitle(self.m_right_btn2,string_helper.ccb.title65)
    game_util:setCCControlButtonTitle(self.m_left_btn,string_helper.ccb.title666)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local tGameData = game_data:getHarborData();
    local skill = tGameData.available_skill
    local leaderSkillConfig = getConfig(game_config_field.leader_skill);
    local skillCfgItem = leaderSkillConfig:getNodeWithKey(tostring(self.m_skillId));
    m_name_label:setString(skillCfgItem:getNodeWithKey("name"):toStr());
    local story = skillCfgItem:getNodeWithKey("story"):toStr();
    local max_level = skillCfgItem:getNodeWithKey("max_level"):toInt();
    m_story_label:setString(story);

    m_ready_time_label:setString(skillCfgItem:getNodeWithKey("ready_time"):toStr() .. string_helper.skills_practice_pop.round);
    m_anger_consume_label:setString("100");
    m_cool_time_label:setString(skillCfgItem:getNodeWithKey("cd"):toStr() .. string_helper.skills_practice_pop.round);

    local skillIcon = nil;
    print("skillId ========================" .. self.m_skillId);
    local level = skill[tostring(self.m_skillId)]
    if level ~= nil then
        cclog("self.m_skillTotalLevel ================" .. self.m_skillTotalLevel);
        if self.m_skillTotalLevel < 1 then
            self.m_skillTotalLevel = 1;
        end
        m_level_label:setString("Lv." .. level .. "/" .. max_level);
        local time_need = 0;
        if level < max_level then
            self.m_left_btn:setVisible(false);
            self.m_right_btn:setVisible(true);
            -- self.m_right_btn2:setVisible(true);
            self.m_guildNode = self.m_right_btn;
            m_tips_label:setString("");
        else
            self.m_left_btn:setVisible(false);
            self.m_right_btn:setVisible(false);
            -- self.m_right_btn2:setVisible(false);
            m_tips_label:setString(string_helper.skills_practice_pop.maxLevel)
        end
        skillIcon = game_util:createLeaderSkillIconByCfg(skillCfgItem,self.m_treeId,true);
    else
        local openMsg = "";
        local tempSkillCfgItem = nil;
        for k,v in pairs(self.m_treeTable[tostring(self.m_skillId)].parentTable) do
            -- print("parent id =======================================" .. v.id)
            tempSkillCfgItem = leaderSkillConfig:getNodeWithKey(tostring(v.id));
            if k == 1 then
                openMsg = openMsg .. tempSkillCfgItem:getNodeWithKey("name"):toStr();
            else
                openMsg = openMsg ..  "、" .. tempSkillCfgItem:getNodeWithKey("name"):toStr();
            end
        end
        if openMsg ~= "" then
            openMsg = string.format(string_helper.skills_practice_pop.open,openMsg)
        else
            openMsg = string_helper.skills_practice_pop.defaultText
        end
        m_tips_label:setString(openMsg);
        m_level_label:setString("Lv.0" .. "/" .. max_level);
        self.m_left_btn:setVisible(false);
        self.m_right_btn:setVisible(false);
        -- self.m_right_btn2:setVisible(false);
        skillIcon = game_util:createLeaderSkillIconByCfg(skillCfgItem,self.m_treeId,false);
    end
    
    if skillIcon then
        m_skill_icon:setScale(0.8);
        local tempSize = m_skill_icon:getContentSize();
        skillIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
        m_skill_icon:addChild(skillIcon);
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function skills_practice_pop.refreshUi(self)
    cclog("self.m_treeId ===" .. tostring(self.m_treeId) .. " ; self.m_skillId = " .. tostring(self.m_skillId));
    local tGameData = game_data:getHarborData();
    local skill = tGameData.available_skill
    local level = skill[tostring(self.m_skillId)] or 0;
    local leader_skill_develop_cfg = getConfig(game_config_field.leader_skill_develop);
    local itemCfg = leader_skill_develop_cfg:getNodeWithKey(tostring(self.m_skillId))
    if itemCfg and level and level < 5 and level > -1 then
        local costStar = itemCfg:getNodeWithKey("star_" .. (level+1)):toInt();
        if costStar > 0 then
            local totalStar = game_data:getUserStatusDataByKey("star") or 0
            self.m_energy_total_label:setString(tostring(totalStar));
            game_util:setCostLable(self.m_cost_energy_label,costStar,totalStar);
            if costStar > totalStar then--星灵不足，提示
                self.is_tips = true
            end
        else
            self.m_cost_node_1:setVisible(false);
            self.is_tips = false
        end
    else
        self.m_cost_node_1:setVisible(false);
        self.m_left_btn:setVisible(false);
        self.m_right_btn:setVisible(false);
        -- self.m_right_btn2:setVisible(false);
    end
end

--[[--
    初始化
]]
function skills_practice_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_skillId = t_params.skillId;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_skillTotalLevel = t_params.skillTotalLevel or 0;
    self.m_treeId = t_params.treeId;
    self.m_treeTable = t_params.treeTable or {};
end

--[[--
    创建ui入口并初始化数据
]]
function skills_practice_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("13");
    if id == 1302 and self.m_guildNode then
        game_guide_controller:gameGuide("show","13",1303,{tempNode = self.m_guildNode})
    else
        game_scene:removeGuidePop();
    end
    return self.m_popUi;
end

--[[--
    回调方法
]]
function skills_practice_pop.callBackFunc(self,typeName,t_params)
    if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
        self.m_callBackFunc(typeName,t_params);
    end
end

return skills_practice_pop;