---  中立地图建筑详细

local game_neutral_building_detail_pop = {
    m_root_layer = nil,
    m_cityId = nil,
    m_buildingId = nil,
    m_popUi = nil,
    m_building_node = nil,
    m_building_name = nil,
    m_introduction_label = nil,
    m_player_icon_bg = nil,
    m_player_name = nil,
    m_guild_name_label = nil,
    m_reward_node_1 = nil,
    m_reward_label_1 = nil,
    m_reward_node_2 = nil,
    m_reward_label_2 = nil,
    m_time_label = nil,
    m_count_label = nil,
    m_close_btn = nil,
    m_occupied_btn = nil,
    m_plunder_btn = nil,
    
    m_ccbNode = nil,        -- 场景ui前景
    m_stageTableData = nil,
    m_buildingDetailTableData = nil,
    m_buildingTableData = nil,
    m_openType = nil,
    m_next_step = nil,
    m_enterTime = nil,
    m_is_plunder = nil,
};
--[[--
    销毁
]]
function game_neutral_building_detail_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_building_detail_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_cityId = nil;
    self.m_buildingId = nil;
    self.m_popUi = nil;
    self.m_building_node = nil;
    self.m_building_name = nil;
    self.m_introduction_label = nil;
    
    self.m_player_icon_bg = nil;
    self.m_player_name = nil;
    self.m_guild_name_label = nil;
    self.m_reward_node_1 = nil;
    self.m_reward_label_1 = nil;
    self.m_reward_node_2 = nil;
    self.m_reward_label_2 = nil;
    self.m_time_label = nil;
    self.m_count_label = nil;
    self.m_close_btn = nil;
    self.m_occupied_btn = nil;
    self.m_plunder_btn = nil;
    self.m_ccbNode = nil;
    self.m_stageTableData = nil;
    self.m_buildingDetailTableData = nil;
    self.m_buildingTableData = nil;
    self.m_openType = nil;
    self.m_next_step = nil;
    self.m_enterTime = nil;
    self.m_is_plunder = nil;
end
--[[--
    返回
]]
function game_neutral_building_detail_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_neutral_building_detail_pop");
end
--[[--
    进入战斗场景
]]
function game_neutral_building_detail_pop.enterBattleScene(self)
    local function responseMethod(tag,gameData)
        if gameData:getNodeWithKey("data"):getNodeWithKey("battle"):getNodeWithKey("no_fight"):toInt() == 1 then return end
        local has_battled = 1;
        if has_battled == 1 then
                game_data:setSelNeutralBuildingId(self.m_buildingId);
                game_data:setBattleType("game_neutral_building_detail_pop");
                local middle_building_mine = getConfig(game_config_field.middle_building_mine)
                local buildingCfgData = middle_building_mine:getNodeWithKey(tostring(self.m_buildingTableData.c_id));
                local background = buildingCfgData:getNodeWithKey("background"):toStr();
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,stageTableData=self.m_stageTableData,backGroundName = background});
        end
    end
    local params = {};
    params.city_id = self.m_cityId;
    params.building_id = self.m_buildingId;
    params.is_plunder = self.m_is_plunder;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_attack"), http_request_method.GET, params,"public_city_attack")
end

--[[--
    读取ccbi创建ui
]]
function game_neutral_building_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --关闭
            self:back();
        elseif btnTag == 2 then --占领
            local tempGameData = game_data:getSelNeutralCityData();
            local own_city = tempGameData.own_city;
            local expire = own_city.expire
            local tempTime = expire - (os.time() - self.m_enterTime) 
            if own_city.own_building ~= "" then
                if tempTime > 0 then
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            self.m_is_plunder = nil;
                            self:enterBattleScene();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                        end,
                        okBtnText = string_helper.game_neutral_building_detail_pop.certain,       --可缺省
                        text = string_helper.game_neutral_building_detail_pop.tips,      --可缺省
                    }
                    game_util:openAlertView(t_params);
                else
                    self.m_is_plunder = nil;
                    self:enterBattleScene();
                end
            else
                self.m_is_plunder = nil;
                self:enterBattleScene();
            end
        elseif btnTag == 3 then --掠夺
            self.m_is_plunder = 1;
            self:enterBattleScene();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_neutral_building_detail_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_building_node = ccbNode:nodeForName("m_building_node");
    self.m_building_name = ccbNode:labelTTFForName("m_building_name");
    self.m_introduction_label = ccbNode:labelTTFForName("m_introduction_label");
    self.m_player_icon_bg = ccbNode:spriteForName("m_player_icon_bg");
    self.m_player_name = ccbNode:labelTTFForName("m_player_name");
    self.m_guild_name_label = ccbNode:labelTTFForName("m_guild_name_label");
    self.m_reward_node_1 = ccbNode:spriteForName("m_reward_node_1");
    self.m_reward_label_1 = ccbNode:labelTTFForName("m_reward_label_1");
    self.m_reward_node_2 = ccbNode:spriteForName("m_reward_node_2");
    self.m_reward_label_2 = ccbNode:labelTTFForName("m_reward_label_2");
    self.m_time_label = ccbNode:labelTTFForName("m_time_label");
    self.m_count_label = ccbNode:labelTTFForName("m_count_label");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_occupied_btn = ccbNode:controlButtonForName("m_occupied_btn")
    self.m_plunder_btn = ccbNode:controlButtonForName("m_plunder_btn")
    self.m_ccbNode = ccbNode;
    if self.m_openType == 1 then
        ccbNode:runAnimations("enter_anim_1")
    elseif self.m_openType == 2 then
        ccbNode:runAnimations("enter_anim_2")
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_occupied_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonTitle(self.m_occupied_btn,string_helper.ccb.text190)
    game_util:setCCControlButtonTitle(self.m_plunder_btn,string_helper.ccb.text191)
    self.m_plunder_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text186)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text187)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text188)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text189)
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_neutral_building_detail_pop.refreshUi(self)
    local middle_building_mine = getConfig(game_config_field.middle_building_mine)
    local buildingCfgData = middle_building_mine:getNodeWithKey(tostring(self.m_buildingTableData.c_id));
    local tempItemTypeName = self.m_buildingTableData.type or "";
    local buildingIconName = nil;
    if buildingCfgData ~= nil then
        -- self.m_introduction_label:setString(buildingCfgData:getNodeWithKey("title_detail"):toStr());
        local gainFood = 0;
        if tempItemTypeName == "mine" then
            buildingIconName = buildingCfgData:getNodeWithKey("image"):toStr();
            local owner = self.m_buildingTableData.owner
            local owner_info = self.m_buildingTableData.owner_info;
            cclog("#owner ================= " .. #owner)
            if #owner > 0 then
                local owner_info_item = owner_info[tostring(owner[1])]
                if owner_info_item then
                    if game_data:getUserStatusDataByKey("uid") == owner_info_item.uid then
                        self.m_occupied_btn:setVisible(false);
                        self.m_plunder_btn:setVisible(false);
                    else
                        self.m_occupied_btn:setVisible(true);
                        self.m_plunder_btn:setVisible(true);
                    end
                    self.m_player_name:setString(tostring(owner_info_item.name));
                    local association_name = owner_info_item.association_name;
                    if association_name == nil or association_name == "" then
                        association_name = string_helper.game_neutral_building_detail_pop.none
                    end
                    self.m_guild_name_label:setString(tostring(association_name));
                    local tempIcon = game_util:createPlayerIconByRoleId(owner_info_item.role)
                    -- cclog("tempIcon ===================== " .. tostring(tempIcon))
                    if tempIcon then
                        local tempSize = self.m_player_icon_bg:getContentSize();
                        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                        self.m_player_icon_bg:addChild(tempIcon,-1,10)
                    end
                else
                    self.m_occupied_btn:setVisible(false);
                    self.m_plunder_btn:setVisible(true);
                    local tempSize = self.m_plunder_btn:getParent():getContentSize();
                    self.m_plunder_btn:setPositionX(tempSize.width*0.5)
                    self.m_player_name:setString(tostring(owner[1]));
                    self.m_guild_name_label:setString(string_helper.game_neutral_building_detail_pop.none);
                end

                local function timeEndFunc(label,type)
                    self.m_player_name:setString(string_helper.game_neutral_building_detail_pop.noOccupy);
                    self.m_guild_name_label:setString(string_helper.game_neutral_building_detail_pop.none);
                    self.m_player_icon_bg:removeAllChildrenWithCleanup(true);
                    self.m_player_icon_bg:setVisible(false);
                end
                local own_time = self.m_buildingDetailTableData.own_time
                local tempTime = own_time - (os.time() - self.m_enterTime)
                if own_time > 0 then
                    local countdownLabel = game_util:createCountdownLabel(tempTime,timeEndFunc,8);
                    countdownLabel:setColor(ccc3(255,255,0))
                    local pX,pY = self.m_time_label:getPosition();
                    countdownLabel:setPosition(ccp(pX,pY))
                    self.m_time_label:getParent():addChild(countdownLabel,0,5)
                    self.m_time_label:setVisible(false);
                else
                    self.m_player_name:setString(string_helper.game_neutral_building_detail_pop.noOccupy);
                    self.m_guild_name_label:setString(string_helper.game_neutral_building_detail_pop.none);
                    self.m_player_icon_bg:removeAllChildrenWithCleanup(true);
                    self.m_player_icon_bg:setVisible(false);
                end

            else
                self.m_occupied_btn:setVisible(true);
                self.m_plunder_btn:setVisible(false);
                local tempSize = self.m_plunder_btn:getParent():getContentSize();
                self.m_occupied_btn:setPositionX(tempSize.width*0.5)
                self.m_player_name:setString(string_helper.game_neutral_building_detail_pop.noOccupy);
                self.m_guild_name_label:setString(string_helper.game_neutral_building_detail_pop.none);
                self.m_player_icon_bg:setVisible(false);
            end
            local reward_base = buildingCfgData:getNodeWithKey("reward_base")
            local awardCount1 = reward_base:getNodeCount();
            local posIndex = 1;
            if awardCount1 > 0 then
                local m_award_node = self["m_reward_node_" .. posIndex]
                local m_award_label = self["m_reward_label_" .. posIndex]
                m_award_node:removeAllChildrenWithCleanup(true);
                local icon,name,count,rewardType = game_util:getRewardByItem(reward_base:getNodeAt(0),true);
                if rewardType == 1 then
                    gainFood = count*0.2;
                end
                if icon then
                    icon:setScale(0.3)
                    m_award_node:addChild(icon)
                end
                if name then
                    m_award_label:setString(name)
                end
                posIndex = posIndex + 1;
            end
            local reward_item = buildingCfgData:getNodeWithKey("reward_item")
            local awardCount2 = reward_item:getNodeCount();
            cclog("awardCount1 ===" .. awardCount1 .. " ; awardCount2 == " .. awardCount2)
            if awardCount2 > 0 then
                local m_award_node = self["m_reward_node_" .. posIndex]
                local m_award_label = self["m_reward_label_" .. posIndex]
                m_award_node:removeAllChildrenWithCleanup(true);
                local icon,name,count,rewardType = game_util:getRewardByItem(reward_item:getNodeAt(0),true);
                if rewardType == 1 then
                    gainFood = count*0.2;
                end
                if icon then
                    icon:setScale(0.3)
                    m_award_node:addChild(icon)
                end
                if name then
                    m_award_label:setString(name)
                end
                posIndex = posIndex + 1;
            end
            if (awardCount1 + awardCount2) == 1 then
                local m_award_node = self["m_reward_node_1"]
                local m_award_label = self["m_reward_label_1"]
                m_award_node:setPositionX(m_award_node:getPositionX() + 30)
                m_award_label:setPositionX(m_award_label:getPositionX() + 30)
            end
        elseif tempItemTypeName == "resource" then
            buildingIconName = buildingCfgData:getNodeWithKey("img"):toStr();
            self.m_occupied_btn:setVisible(false);
            self.m_plunder_btn:setVisible(true);
            local tempSize = self.m_plunder_btn:getParent():getContentSize();
            self.m_plunder_btn:setPositionX(tempSize.width*0.5)
            self.m_count_label:setString("0");
            self.m_reward_label_1:setString("10");
            self.m_reward_label_2:setString("10");
            local reward = buildingCfgData:getNodeWithKey("reward")
            local awardCount = reward:getNodeCount();
            for i=1,2 do
                local m_award_node = self["m_reward_node_" .. i]
                local m_award_label = self["m_reward_label_" .. i]
                m_award_node:removeAllChildrenWithCleanup(true);
                if awardCount == 1 then
                    m_award_node:setPositionX(m_award_node:getPositionX() + 30)
                    m_award_label:setPositionX(m_award_label:getPositionX() + 30)
                end
                if i > awardCount then
                    m_award_label:setString("")
                    m_award_node:setVisible(false);
                else
                    local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                    if icon then
                        icon:setScale(0.3)
                        m_award_node:addChild(icon)
                    end
                    if name then
                        m_award_label:setString(name)
                    end
                end                    
            end
        end
        self.m_building_name:setString(buildingCfgData:getNodeWithKey("name"):toStr());
        local firstValue,_ = string.find(buildingIconName,".png");
        local buildingSpr = CCSprite:create("building_img/" .. buildingIconName .. (firstValue == nil and ".png" or ""));
        if buildingSpr then
            local buildingSize = buildingSpr:getContentSize();
            local scale = math.min(buildingSize.width~=0 and 75/buildingSize.width or 1,buildingSize.height~=0 and 75/buildingSize.height or 1);
            buildingSpr:setScale(scale);
            self.m_building_node:addChild(buildingSpr);
        end
        self.m_count_label:setString(tostring(self.m_buildingDetailTableData.plunder) .. "/" .. tostring(self.m_buildingDetailTableData.max_plunder) .. string.format(string_helper.game_neutral_building_detail_pop.every_food,gainFood));
    else
        self.m_building_name:setString("");
        self.m_player_name:setString("");
        self.m_guild_name_label:setString("");
        self.m_reward_label_1:setString("");
        self.m_reward_label_2:setString("");
        self.m_time_label:setString("");
        self.m_count_label:setString("");
        self.m_occupied_btn:setVisible(false);
        self.m_plunder_btn:setVisible(false);
    end
end

--[[--
    初始化
]]
function game_neutral_building_detail_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cityId = t_params.cityId;
    self.m_buildingId = t_params.buildingId;
    cclog("tostring(self.m_buildingId) =============" .. tostring(self.m_buildingId));
    self.m_stageTableData = {};
    self.m_buildingDetailTableData = t_params.buildingDetailTableData;
    self.m_buildingTableData = t_params.buildingTableData;
    self.m_stageTableData.name = string_helper.game_neutral_building_detail_pop.neutralMap;
    self.m_stageTableData.step = 1;
    self.m_stageTableData.totalStep = 1;
    local typeName = self.m_buildingTableData.type or "";
    if typeName == "mine" then
        self.m_openType = 1;
    else
        self.m_openType = 2;
    end
    self.m_next_step = 1;
    self.m_enterTime = os.time();
    self.m_is_plunder = nil;
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_building_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_neutral_building_detail_pop;