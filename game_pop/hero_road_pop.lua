--- 英雄之路弹出框

local hero_road_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_fight_list_bg = nil,
    m_reward_node = nil,
    m_name_label = nil,
    m_anim_node = nil,
    m_ccbNode = nil,
    m_hero_chapter_key = nil,
    m_starCount = nil,
    m_callFunc = nil,
    m_count_label = nil,
    m_exp_label = nil,
    m_fight_cost_label = nil,
};
--[[--
    销毁ui
]]
function hero_road_pop.destroy(self)
    -- body
    cclog("-----------------hero_road_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_fight_list_bg = nil;
    self.m_reward_node = nil;
    self.m_name_label = nil;
    self.m_anim_node = nil;
    self.m_ccbNode = nil;
    self.m_hero_chapter_key = nil;
    self.m_starCount = nil;
    self.m_callFunc = nil;
    self.m_count_label = nil;
    self.m_exp_label = nil;
    self.m_fight_cost_label = nil;
end

local difficultiesIconTab = {"yxzl_jiandan.png","yxzl_putong.png","yxzl_kunnan.png"}

--[[--
    返回
]]
function hero_road_pop.back(self,backType)
    game_scene:removePopByName("hero_road_pop");
end
--[[--
    读取ccbi创建ui
]]
function hero_road_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_road_pop.ccbi");

    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_fight_list_bg = ccbNode:nodeForName("m_fight_list_bg")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_count_label = ccbNode:labelTTFForName("m_count_label")
    self.m_exp_label = ccbNode:labelTTFForName("m_exp_label")
    self.m_fight_cost_label = ccbNode:labelTTFForName("m_fight_cost_label")

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_root_layer = ccbNode:layerColorForName("m_root_layer")
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

--[[--
    创建列表
]]
function hero_road_pop.createTableView(self,viewSize)
    local mapWorldData = game_data:getMapWorldData();
    local hero_road = mapWorldData.hero_road or {};
    local hero_done = mapWorldData.hero_done or {};
    local item_hero_road = hero_road[tostring(self.m_hero_chapter_key)] or {}
    local active_done_status = item_hero_road.active_done_status or {}

    local hero_chapter_cfg = getConfig(game_config_field.hero_chapter)
    local itemCfg = hero_chapter_cfg:getNodeWithKey(tostring(self.m_hero_chapter_key))
    local active_detail = itemCfg:getNodeWithKey("active_detail")
    local tempCount = active_detail:getNodeCount();
    local active_detail_cfg = getConfig(game_config_field.active_detail)

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tempIndex = btnTag < 1000 and btnTag or btnTag - 1000;
        local active_detail_key = active_detail:getNodeAt(tempIndex):toStr();
        local itemCfg = active_detail_cfg:getNodeWithKey(active_detail_key)
        local need_action_point = itemCfg:getNodeWithKey("action_point"):toInt();
        local action_point = game_data:getUserStatusDataByKey("action_point") or 0
        if need_action_point > action_point then
            local t_params = 
            {
                m_openType = 3,
                m_call_func = function()
                    if self.m_callFunc then
                        self.m_callFunc();
                    end
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
            return;
        end
        if btnTag < 1000 then
            local active_detail_key = active_detail:getNodeAt(btnTag):toStr();
            local function responseMethod(tag,gameData)
                if(gameData == nil) then
                    return 
                end
                game_scene:removeGuidePop();
                game_scene:runPropertyBarAnim("outer_anim")
                game_data:setBattleType("hero_road_pop");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=self.m_stageTableData,backGroundName = self.m_backgroundName});
            end
            local params = {};
            params.chapter = tostring(self.m_hero_chapter_key);
            params.active_id = active_detail_key;
            params.step_n = 0;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_fight"), http_request_method.GET, params,"active_fight",true,true,true)
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = math.min(3,tempCount);
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY - 6;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_hero_road_pop_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_explore_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local m_explore_btn = ccbNode:controlButtonForName("m_explore_btn")
            local m_reward_node = ccbNode:nodeForName("m_reward_node")
            m_explore_btn:setTag(index);
            game_util:setCCControlButtonTitle(m_explore_btn,string_helper.ccb.text57)
            local active_detail_key = active_detail:getNodeAt(index):toStr();
            local itemCfg = active_detail_cfg:getNodeWithKey(active_detail_key)
            local combat_need = itemCfg:getNodeWithKey("combat_need"):toInt();
            m_combat_label:setScale(0.75);
            m_combat_label:setString(combat_need)
            local reward_first_base = itemCfg:getNodeWithKey("reward_first_base")
            local reward_first_rate = itemCfg:getNodeWithKey("reward_first_rate")
            local reward_sweep_base = itemCfg:getNodeWithKey("reward_sweep_base")
            local reward_sweep_rate = itemCfg:getNodeWithKey("reward_sweep_rate")
            local totalCount = hero_done[active_detail_key] or 0;
            local tempReward = nil;
            if totalCount > 0 then
                tempReward = json.decode(reward_sweep_base:getFormatBuffer()) or {};
                local reward_first_rate_tab = json.decode(reward_sweep_rate:getFormatBuffer()) or {};
                for k,v in pairs(reward_first_rate_tab) do
                    if v[1] > 0 then
                        table.insert(tempReward,v);
                    end
                end
            else
                tempReward = json.decode(reward_first_base:getFormatBuffer()) or {};
                local reward_first_rate_tab = json.decode(reward_first_rate:getFormatBuffer()) or {};
                for k,v in pairs(reward_first_rate_tab) do
                    if v[1] > 0 then
                        table.insert(tempReward,v);
                    end
                end
            end
            local tempView = self:createItemRewardTableView(m_reward_node:getContentSize(),tempReward,itemCfg);
            m_reward_node:addChild(tempView);

            if self.m_starCount >= index then
                game_util:setCCControlButtonEnabled(m_explore_btn,true);
                m_explore_btn:setTitleColorForState(ccc3(255, 255, 255),CCControlStateNormal);
            else
                game_util:setCCControlButtonEnabled(m_explore_btn,false);
                m_explore_btn:setTitleColorForState(ccc3(155, 155, 155),CCControlStateDisabled);
            end
            local m_star_node = ccbNode:nodeForName("m_star_node")
            m_star_node:setPositionX(7*(3 - index))
            for i=1,3 do
                local m_start_icon = ccbNode:spriteForName("m_star_icon_" .. i)
                if (index + 1) >= i then
                    m_start_icon:setVisible(true);
                    if self.m_starCount >= (index + 1) then
                        m_start_icon:setColor(ccc3(255, 255, 255))
                    else
                        m_start_icon:setColor(ccc3(81, 81, 81)) 
                    end
                else
                    m_start_icon:setVisible(false);
                end
            end
        end
        return cell;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建列表
]]
function hero_road_pop.createItemRewardTableView(self,viewSize,rewardTab,itemCfg)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = 1;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.viewSize = viewSize;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local boss_resource = itemCfg:getNodeWithKey("boss_resource"):toStr();
            local back_resource = itemCfg:getNodeWithKey("back_resource"):toInt();
            local itemIcon = game_util:createIconByName(boss_resource);
            if itemIcon then
                itemIcon:setScale(0.75);
                itemIcon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                cell:addChild(itemIcon);
                game_util:addIconQualityBgByQuality(itemIcon,back_resource);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- game_util:lookItemDetal(rewardTab[index+1]);
            game_scene:addPop("game_superillustration_showreward_pop", {reward_data = rewardTab })
        end
    end
    return TableViewHelper:create(params);
end

--[[
    创建奖励列表
]]
function hero_road_pop.createRewardTabelView(self,viewSize)
    local hero_chapter_cfg = getConfig(game_config_field.hero_chapter)
    local itemCfg = hero_chapter_cfg:getNodeWithKey(tostring(self.m_hero_chapter_key))
    local rewardTab = {};
    if itemCfg then
        local reward_show = itemCfg:getNodeWithKey("reward_show")
        rewardTab = json.decode(reward_show:getFormatBuffer());
    end
    -- local rewardTab = {{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000}};
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab;
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
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.15))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function hero_road_pop.refreshUi(self)
    self.m_fight_list_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_fight_list_bg:getContentSize());
    self.m_fight_list_bg:addChild(tableViewTemp);
    -- self.m_reward_node:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createRewardTabelView(self.m_reward_node:getContentSize());
    -- self.m_reward_node:addChild(tableViewTemp);
    local mapWorldData = game_data:getMapWorldData();
    local hero_road = mapWorldData.hero_road or {};
    local item_hero_road = hero_road[tostring(self.m_hero_chapter_key)] or {}

    local hero_chapter_cfg = getConfig(game_config_field.hero_chapter)
    local itemCfg = hero_chapter_cfg:getNodeWithKey(tostring(self.m_hero_chapter_key))
    if itemCfg then
        local banner = itemCfg:getNodeWithKey("banner"):toStr();
        -- local animNode = game_util:createImgByName("image_" .. banner,nil,nil,nil,nil,nil);
        -- if animNode then
        --     animNode:setAnchorPoint(ccp(0.5,0))
        --     animNode:setScale(0.8);
        --     self.m_anim_node:addChild(animNode);
        -- end
        local des = itemCfg:getNodeWithKey("des"):toStr();
        self.m_name_label:setString(des);
        local times = itemCfg:getNodeWithKey("times"):toInt();
        local cur_times = item_hero_road.cur_times or 0;
        self.m_count_label:setString(string_helper.hero_road_pop.leftTimes .. math.max(0,times - cur_times));
        local exp_role = itemCfg:getNodeWithKey("exp_role"):toInt();
        local exp_character = itemCfg:getNodeWithKey("exp_character"):toInt();
        self.m_exp_label:setString(string_helper.hero_road_pop.heroExp .. exp_role .. string_helper.hero_road_pop.cardExp .. exp_character);
        local action_point = itemCfg:getNodeWithKey("action_point"):toInt();
        self.m_fight_cost_label:setString(action_point);
    end
end
--[[--
    初始化
]]
function hero_road_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_hero_chapter_key = t_params.hero_chapter_key;
    self.m_starCount = t_params.starCount;
    self.m_callFunc = t_params.callFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function hero_road_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return hero_road_pop;