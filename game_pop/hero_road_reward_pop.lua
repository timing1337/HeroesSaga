--- 英雄之路弹出框

local hero_road_reward_pop = {
    m_ccbNode = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_own_star_label = nil,
    m_callBackFunc = nil,
    m_gainRewardFlag = nil,
};
--[[--
    销毁ui
]]
function hero_road_reward_pop.destroy(self)
    -- body
    cclog("-----------------hero_road_reward_pop destroy-----------------");
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_own_star_label = nil;
    self.m_callBackFunc = nil;
    self.m_gainRewardFlag = nil;
end

--[[--
    返回
]]
function hero_road_reward_pop.back(self,backType)
    if self.m_gainRewardFlag == true then
        if self.m_callBackFunc then
            self.m_callBackFunc();
        end
    end
    game_scene:removePopByName("hero_road_reward_pop");
end
--[[--
    读取ccbi创建ui
]]
function hero_road_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_road_reward_pop.ccbi");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_root_layer = ccbNode:layerColorForName("m_root_layer")
    self.m_own_star_label = ccbNode:labelBMFontForName("m_own_star_label")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode
    return ccbNode;
end


--[[
    创建奖励列表
]]
function hero_road_reward_pop.createRewardTabelView(self,viewSize)
    local star_reward_cfg = getConfig(game_config_field.star_reward)
    local tempCount = star_reward_cfg:getNodeCount();
    local showDataTab = {}
    for i=1,tempCount do
        local itemCfg = star_reward_cfg:getNodeAt(i-1);
        table.insert(showDataTab, itemCfg:getKey());
    end
    local tonumber = tonumber;
    table.sort(showDataTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end);

    local mapWorldData = game_data:getMapWorldData();
    local star_reward_log = mapWorldData.star_reward_log or {};
    local hero_done = mapWorldData.hero_done or {};
    local totalStar = game_util:getTableLen(hero_done)
    self.m_own_star_label:setString("×" .. totalStar);
    -- local rewardTab = {{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000}};
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #showDataTab;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            -- local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],false)
            -- if icon then
            --     icon:setScale(0.65);
            --     icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
            --     cell:addChild(icon)
            -- end
            -- if count then
            --     local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
            --     tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.15))
            --     cell:addChild(tempLabel)
            -- end
            local itemCfg = star_reward_cfg:getNodeWithKey(showDataTab[index+1]);
            local star = itemCfg:getNodeWithKey("star"):toInt();
            local quality = itemCfg:getNodeWithKey("quality"):toInt();
            local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon,100,100)
                if totalStar >= star then--可领取
                    icon:setColor(ccc3(255, 255, 255))
                else
                    icon:setColor(ccc3(81, 81, 81))
                end
                game_util:addIconQualityBgByQuality(icon,quality);
            end
            local starIcon = CCSprite:createWithSpriteFrameName("public_equip_star.png")
            if starIcon then
                starIcon:setScale(0.75)
                starIcon:setPosition(ccp(itemSize.width*0.3, itemSize.height*0.15))
                cell:addChild(starIcon)
            end
            local tempLabel = game_util:createLabelBMFont({text = "×" .. star,color = ccc3(255,255,0),fontSize = 8});
            tempLabel:setPosition(ccp(itemSize.width*0.6, itemSize.height*0.15))
            cell:addChild(tempLabel)

            local getRewardIcon = CCSprite:createWithSpriteFrameName("yxzl_get_reward.png")
            if getRewardIcon then
                getRewardIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(getRewardIcon,1000,1000);
                local tempFlag = game_util:idInTableById(showDataTab[index+1],star_reward_log)
                if tempFlag then
                    getRewardIcon:setVisible(true);
                else
                    getRewardIcon:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- game_util:lookItemDetal(rewardTab[index+1])
            local reward_id = showDataTab[index+1];
            local itemCfg = star_reward_cfg:getNodeWithKey(reward_id);
            local reward = itemCfg:getNodeWithKey("reward");
            local tempFlag = game_util:idInTableById(reward_id,star_reward_log)
            if tempFlag then
                local tempReward = json.decode(reward:getFormatBuffer()) or {};
                game_scene:addPop("game_superillustration_showreward_pop", {reward_data = tempReward })
                return;
            end
            local star = itemCfg:getNodeWithKey("star"):toInt();
            if totalStar < star then--
                game_util:addMoveTips({text = string.format(string_helper.hero_road_reward_pop.needCollect,(star - totalStar))});
                local tempReward = json.decode(reward:getFormatBuffer()) or {};
                game_scene:addPop("game_superillustration_showreward_pop", {reward_data = tempReward })
                return;
            end
            local function responseMethod(tag,gameData)
                self.m_gainRewardFlag = true;
                table.insert(star_reward_log,reward_id);
                local getRewardIcon = cell:getChildByTag(1000);
                if getRewardIcon then
                    getRewardIcon:setVisible(true);
                    getRewardIcon:setScale(5);
                    local arr = CCArray:create();
                    arr:addObject(CCEaseIn:create(CCScaleTo:create(0.5, 0.9),5));
                    arr:addObject(CCScaleTo:create(0.2, 1.1));
                    arr:addObject(CCScaleTo:create(0.2, 1));
                    getRewardIcon:runAction(CCSequence:create(arr))
                end
                local tempIcon = tolua.cast(cell:getChildByTag(100), "CCSprite")
                if tempIcon then
                    tempIcon:setColor(ccc3(255, 255, 255));
                end
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
            end
            local params = {};
            params.reward_id = reward_id;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_hero_star_reward"), http_request_method.GET, params,"active_hero_star_reward")
        end
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    刷新ui
]]
function hero_road_reward_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTabelView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function hero_road_reward_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_gainRewardFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function hero_road_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return hero_road_reward_pop;