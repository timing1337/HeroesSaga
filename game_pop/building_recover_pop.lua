---  建筑收复弹出框

local building_recover_pop = {
    m_popUi = nil,
    m_callFunc = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_ok_btn = nil,
    m_building_name = nil,
    m_recoverBuildingId = nil,
    m_reward_node = nil,
    m_other_reward_node = nil,
    m_building_node = nil,
    m_reward = nil,
    m_rewardNodeTab = nil,
    m_no_reward_label = nil,
    m_no_extra_reward_label = nil,
    m_extra_icon_node = nil,
    m_title_label = nil,
};

local reward_icon_tab = {reward_food = "public_icon_food2.png",reward_metal = "public_icon_metal2.png",reward_energy = "public_icon_energy2.png",reward_crystal = "public_icon_crystal2.png"};

--[[--
    销毁
]]
function building_recover_pop.destroy(self)
    -- body
    cclog("-----------------building_recover_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_callFunc = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_ok_btn = nil;
    self.m_building_name = nil;
    self.m_recoverBuildingId = nil;
    self.m_reward_node = nil;
    self.m_other_reward_node = nil;
    self.m_building_node = nil;
    self.m_reward = nil;
    self.m_rewardNodeTab = nil;
    self.m_no_reward_label = nil;
    self.m_no_extra_reward_label = nil;
    self.m_extra_icon_node = nil;
    self.m_title_label = nil;
end
--[[--
    返回
]]
function building_recover_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
--     self:destroy();
    game_scene:removePopByName("building_recover_pop");
end
--[[--
    读取ccbi创建ui
]]
function building_recover_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--确定
            local id = game_guide_controller:getCurrentId();
            if id == 11 or id == 29 then
                if id == 11 then
                    game_guide_controller:gameGuide("send","1",11);
                end
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("map_world_scene",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
            else
                self:back();
                game_scene:removeAllPop();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_building_recover_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_building_name = ccbNode:labelTTFForName("m_building_name")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_other_reward_node = ccbNode:nodeForName("m_other_reward_node")
    self.m_building_node = ccbNode:nodeForName("m_building_node")
    self.m_no_reward_label = ccbNode:labelTTFForName("m_no_reward_label")
    self.m_no_extra_reward_label = ccbNode:labelTTFForName("m_no_extra_reward_label")
    self.m_extra_icon_node = ccbNode:nodeForName("m_extra_icon_node")
    self.m_no_reward_label:setVisible(false)
    self.m_no_extra_reward_label:setVisible(false)
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    if game_data:getReMapBattleFlag() then
        self.m_title_label:setString(string_helper.building_recover_pop.recoverReward);
    else
        self.m_title_label:setString(string_helper.building_recover_pop.coverReward);
    end
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local reward_icon,reward_label;
    for i=1,3 do
        reward_icon = ccbNode:spriteForName("m_reward_icon_" .. i);
        reward_label = ccbNode:labelTTFForName("m_reward_label_" .. i);
        reward_icon:setVisible(false);
        reward_label:setVisible(false);
        self.m_rewardNodeTab[#self.m_rewardNodeTab+1] = {reward_icon = reward_icon, reward_label = reward_label}
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    local id = game_guide_controller:getCurrentId();
    if id == 8 or id == 10 then
        game_guide_controller:gameGuide("show","1",11,{tempNode = self.m_ok_btn})
    elseif id == 29 then
        game_guide_controller:gameGuide("show","2",29,{tempNode = self.m_ok_btn})
    end
    return ccbNode;
end
--[[--

]]
function building_recover_pop.setRewardValue(self,tempIndex,value,reward_type)
    local reward_icon = self.m_rewardNodeTab[tempIndex].reward_icon
    local reward_label = self.m_rewardNodeTab[tempIndex].reward_label
    reward_icon:setVisible(true)
    reward_label:setVisible(true)
    reward_label:setString("×" .. value)
    -- local reward_icon_size = reward_icon:getContentSize();
    -- local temp_reward_icon = CCSprite:createWithSpriteFrameName(reward_icon_tab[reward_type])
    -- temp_reward_icon:setPosition(ccp(reward_icon_size.width*0.5,reward_icon_size.height*0.5))
    -- reward_icon:addChild(temp_reward_icon);
    reward_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(reward_icon_tab[reward_type]));
    reward_icon:setScale(0.75)
end

--[[--
    刷新ui

        "reward": {
            "action_point": 0, 
            "food": 0, 
            "energy": 100, 
            "equip": [], 
            "coin": 0, 
            "dirt_silver": 0, 
            "crystal": 100, 
            "dirt_gold": 0, 
            "metal": 0, 
            "item": [], 
            "cards": [
                "100-1393819936-PPATl8"
            ]
        }
]]
function building_recover_pop.refreshUi(self)
    self.m_extra_icon_node:removeAllChildrenWithCleanup(true);
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_recoverBuildingId));
    if buildingCfgData ~= nil then
        self.m_building_name:setString(buildingCfgData:getNodeWithKey("title_name"):toStr());
        local buildingIconName = buildingCfgData:getNodeWithKey("title_img"):toStr();
        local firstValue,_ = string.find(buildingIconName,".png");
        local buildingSpr = CCSprite:create("building_img/" .. buildingIconName .. (firstValue == nil and ".png" or ""));
        local buildingSize = buildingSpr:getContentSize();
        local scale = math.min(buildingSize.width~=0 and 75/buildingSize.width or 1,buildingSize.height~=0 and 75/buildingSize.height or 1);
        buildingSpr:setScale(scale);
        self.m_building_node:addChild(buildingSpr);
    end
    local tempIndex = 0;
    if self.m_reward.food and self.m_reward.food ~= 0 then
        tempIndex = tempIndex+1;
        self:setRewardValue(tempIndex,self.m_reward.food,"reward_food");
    end
    if self.m_reward.metal and self.m_reward.metal ~= 0 then
        tempIndex = tempIndex+1;
        self:setRewardValue(tempIndex,self.m_reward.metal,"reward_metal");
    end
    if self.m_reward.energy and self.m_reward.energy ~= 0 then
        tempIndex = tempIndex+1;
        self:setRewardValue(tempIndex,self.m_reward.energy,"reward_energy");
    end
    if self.m_reward.crystal and self.m_reward.crystal ~= 0 and tempIndex < 3 then
         tempIndex = tempIndex+1;
        self:setRewardValue(tempIndex,self.m_reward.crystal,"reward_crystal");
    end
    if tempIndex == 0 then
        self.m_no_reward_label:setVisible(true)
    end
    -- self.m_no_extra_reward_label:setVisible(true)
    -- tempIndex = 1;
    -- if tempIndex == 1 then
    --     self.m_no_extra_reward_label:setString("无")
    -- end
end

--[[--
    初始化
]]
function building_recover_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callFunc = t_params.callFunc;
    self.m_recoverBuildingId = t_params.recoverBuildingId;
    self.m_reward = t_params.reward or {};
    self.m_rewardNodeTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function building_recover_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return building_recover_pop;