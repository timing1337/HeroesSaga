---  基金

local fund_activation_scene = {
    m_tGameData = nil,
    m_ccbNode = nil,
    m_left_time_node = nil,
    m_screenShoot = nil,
    m_showIdTab = nil,
    m_select_spr = nil,
    m_reward_node_tab = nil,
    m_day_label = nil,
};

--[[--
    销毁ui
]]
function fund_activation_scene.destroy(self)
    -- body
    cclog("-----------------fund_activation_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.m_left_time_node = nil;
    self.m_screenShoot = nil;
    self.m_showIdTab = nil;
    self.m_select_spr = nil;
    self.m_reward_node_tab = nil;
    self.m_day_label = nil;
end

local titleSpriteImgNameTab = {"fund_final_reward.png","fund_first_day.png","fund_second_day.png","fund_third_day.png",
                                "fund_fourth_day.png","fund_fifth_day.png","fund_sixth_day.png","fund_seventh_day.png"}

--[[--
    返回
]]
function fund_activation_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function fund_activation_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--详情
            game_scene:addPop("fund_explain_pop", {showIdTab = self.m_showIdTab})
        elseif btnTag >= 11 and btnTag <= 13 then--基金
            local tempTag = btnTag - 10;
            local selFundId = self.m_showIdTab[tempTag] 
            if selFundId == nil then
                return;
            end
            function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                local reward = self.m_tGameData.reward or {}
                game_util:rewardTipsByDataTable(reward);
                self:refreshUi();
            end
            local params = {};
            params.id = selFundId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("foundation_withdraw"), http_request_method.GET, params,"foundation_withdraw")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_fund_activation.ccbi");
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
    self.m_day_label = ccbNode:labelTTFForName("m_day_label")
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end
    self:initLayerTouch(m_root_layer)
    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text181)
    return ccbNode;
end

--[[--
  
]]
function fund_activation_scene.initLayerTouch(self,formation_layer)
    local realPos = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        touchBeginPoint = {x = x, y = y}
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        if not touchMoveFlag then
            for k,v in pairs(self.m_reward_node_tab) do
                realPos = v.icon:getParent():convertToNodeSpace(ccp(x,y));
                if v.icon:boundingBox():containsPoint(realPos) then
                    game_util:lookItemDetal(v.reward)
                    break;
                end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+130)
    formation_layer:setTouchEnabled(true)
end

--[[
    倒计时
]]
function fund_activation_scene.setCountdownTime(self)
    -- local countdownTime = 10000;
    -- self.m_left_time_node:removeAllChildrenWithCleanup(true)
    -- local function timeEndFunc()
    --    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    --    local tipsLabel = game_util:createLabelTTF({text = "已结束",color = ccc3(0,255,0),fontSize = 10});
    --     tipsLabel:setAnchorPoint(ccp(0.5,0.5))
    --     self.m_left_time_node:addChild(tipsLabel,10,12)
    -- end
    
    -- if countdownTime > 0 then
    --     local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
    --     countdownLabel:setColor(ccc3(0, 255, 0))
    --     countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    --     self.m_left_time_node:addChild(countdownLabel,10,10)
    -- else
    --     timeEndFunc();
    -- end
    local distance_day = self.m_tGameData.distance_day or 7
    self.m_day_label:setString(tostring(distance_day) .. string_helper.fund_activation_scene.day)
end

local rewardPosTab = {
    {{0.5,0.9},{0.8,0.8},{0.85,0.6},{0.65,0.45},{0.35,0.45},{0.15,0.6},{0.2,0.8}},
    {{0.2,0.8},{0.5,0.9},{0.8,0.8},{0.85,0.6},{0.65,0.45},{0.35,0.45},{0.15,0.6}},
    {{0.15,0.6},{0.2,0.8},{0.5,0.9},{0.8,0.8},{0.85,0.6},{0.65,0.45},{0.35,0.45}},
    {{0.35,0.45},{0.15,0.6},{0.2,0.8},{0.5,0.9},{0.8,0.8},{0.85,0.6},{0.65,0.45}},
    {{0.65,0.45},{0.35,0.45},{0.15,0.6},{0.2,0.8},{0.5,0.9},{0.8,0.8},{0.85,0.6}},
    {{0.85,0.6},{0.65,0.45},{0.35,0.45},{0.15,0.6},{0.2,0.8},{0.5,0.9},{0.8,0.8}},
    {{0.8,0.8},{0.85,0.6},{0.65,0.45},{0.35,0.45},{0.15,0.6},{0.2,0.8},{0.5,0.9}},
}

--[[--
    刷新ui
]]
function fund_activation_scene.refreshUi(self)
    self.m_reward_node_tab = {};
    self:setCountdownTime();
    local distance_day = self.m_tGameData.distance_day or 7
    local reward_day = 7 - distance_day;
    local bought_funds = self.m_tGameData.bought_funds or {}
    local drawable_funds = self.m_tGameData.drawable_funds or {}
    for j=1,math.min(#self.m_showIdTab,3) do
        local m_fund_spr = self.m_ccbNode:spriteForName("m_fund_spr_" .. j)
        m_fund_spr:removeAllChildrenWithCleanup(true);
        local m_mask_layer = self.m_ccbNode:layerColorForName("m_mask_layer_" .. j)
        local m_get_btn = self.m_ccbNode:controlButtonForName("m_get_btn_" .. j)
        -- if game_util:valueInTeam(self.m_showIdTab[j],bought_funds) then
        if bought_funds[tostring(self.m_showIdTab[j])] and bought_funds[tostring(self.m_showIdTab[j])] < 9 then
            m_mask_layer:setVisible(false)
            local drawable_funds_item = drawable_funds[self.m_showIdTab[j]]
            if drawable_funds_item == nil then
                m_get_btn:setTouchEnabled(false)
                m_get_btn:setColor(ccc3(81, 81, 81))
            else
                m_get_btn:setTouchEnabled(true)
                m_get_btn:setColor(ccc3(255, 255, 255))
            end
        else
            m_mask_layer:setVisible(true)
            m_get_btn:setTouchEnabled(false)
            m_get_btn:setColor(ccc3(81, 81, 81))
        end
        local tempSize = m_fund_spr:getContentSize()
        local foundation_cfg = getConfig(game_config_field.foundation)
        local itemCfg = foundation_cfg:getNodeWithKey(self.m_showIdTab[j])
        local value1 = bought_funds[tostring(self.m_showIdTab[j])] or 1
        if value1 < 8 then
            local cur_day = math.min(value1,reward_day)
            local rewardPosTab = rewardPosTab[cur_day] or {}
            for i=1,math.min(#rewardPosTab,7) do
                local reward_show = itemCfg:getNodeWithKey("day" .. i)
                if reward_show:getNodeCount() > 0 then
                    local reward = json.decode(reward_show:getNodeAt(0):getFormatBuffer())
                    local icon,name,count = game_util:getRewardByItemTable(reward)
                    if icon then
                        icon:setPosition(ccp(tempSize.width*rewardPosTab[i][1], tempSize.height*rewardPosTab[i][2]-5))
                        local tempIconSize = icon:getContentSize()
                        if i == cur_day then
                            icon:setScale(0.75)
                        else
                            icon:setScale(0.5)
                        end
                        if i > reward_day then
                            icon:setColor(ccc3(81, 81, 81))
                        else
                            if i < value1 then
                                local fund_get_reward = CCSprite:createWithSpriteFrameName("fund_get_reward.png")
                                if fund_get_reward then
                                    fund_get_reward:setPosition(ccp(tempIconSize.width*0.5, tempIconSize.height*0.5))
                                    icon:addChild(fund_get_reward,10,10)
                                else
                                    local tempLabel = game_util:createLabelTTF({text = string_helper.fund_activation_scene.text,color = ccc3(255,0,0),fontSize = 14})
                                    tempLabel:setPosition(ccp(tempIconSize.width*0.5, tempIconSize.height*0.5))
                                    icon:addChild(tempLabel,10,10)
                                end
                            else
                                if i == cur_day then
                                    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_faguang.png");
                                    if tempBg then
                                        tempBg:setPreferredSize(CCSizeMake(tempIconSize.width*1.7, tempIconSize.height*1.7));
                                        tempBg:setPosition(ccp(tempIconSize.width*0.5, tempIconSize.height*0.5))
                                        icon:addChild(tempBg, 100, 100)
                                        tempBg:runAction(game_util:createRepeatForeverFade());
                                    end
                                end
                            end
                        end
                        m_fund_spr:addChild(icon)
                        table.insert(self.m_reward_node_tab,{icon = icon,reward = reward})
                        -- local tempLabel = game_util:createLabelTTF({text = "第" .. i .. "天",color = ccc3(0,255,0),fontSize = 16});
                        -- tempLabel:setPosition(ccp(tempIconSize.width*0.5, -tempIconSize.height*0.2))
                        -- icon:addChild(tempLabel,10,10);
                        local tempSprite = CCSprite:createWithSpriteFrameName(tostring(titleSpriteImgNameTab[i+1]));
                        if tempSprite then
                            tempSprite:setScale(0.75);
                            tempSprite:setPosition(ccp(tempIconSize.width*0.5, -tempIconSize.height*0.2))
                            icon:addChild(tempSprite,10,10);
                        end
                    end
                end
            end
        elseif value1 == 8 then            
            local reward_show = itemCfg:getNodeWithKey("reward_show") 
            if reward_show:getNodeCount() > 0 then
                local reward = json.decode(reward_show:getNodeAt(0):getFormatBuffer())
                local icon,name,count = game_util:getRewardByItemTable(reward)
                if icon then
                    icon:setScale(0.75)
                    icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.6))
                    m_fund_spr:addChild(icon)
                    local tempIconSize = icon:getContentSize()
                    -- local tempLabel = game_util:createLabelTTF({text = "最终大奖",color = ccc3(0,255,0),fontSize = 16});
                    -- tempLabel:setPosition(ccp(tempIconSize.width*0.5, -tempIconSize.height*0.25))
                    -- icon:addChild(tempLabel,10,10);
                    local tempSprite = CCSprite:createWithSpriteFrameName(tostring(titleSpriteImgNameTab[1]));
                    if tempSprite then
                        tempSprite:setPosition(ccp(tempIconSize.width*0.5, -tempIconSize.height*0.25))
                        icon:addChild(tempSprite,10,10);
                    end
                    table.insert(self.m_reward_node_tab,{icon = icon,reward = reward})
                end
            end
        end
    end
end

--[[--
    初始化
]]
function fund_activation_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_screenShoot = t_params.screenShoot;
    self.m_showIdTab = {}
    local foundation_cfg = getConfig(game_config_field.foundation)
    local tempCount = foundation_cfg:getNodeCount();
    for i=1, tempCount do
        local itemCfg = foundation_cfg:getNodeAt(i - 1)
        -- cclog2(itemCfg, "itemCfg ========  ")
        if itemCfg then
            -- cclog2(itemCfg:getNodeWithKey("version"):toInt(), "itemCfg:getNodeWithKey(version):toInt()   =====  ")
            if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.version) then
            -- if itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
                table.insert(self.m_showIdTab,itemCfg:getKey())
            end
        end
    end
    table.sort(self.m_showIdTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    self.m_reward_node_tab = {};
end


--[[--
    创建ui入口并初始化数据
]]
function fund_activation_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return fund_activation_scene;