---  转盘奖励

local game_lucky_turntable_reward_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_ok_btn = nil,
    m_openType = nil,
    m_callBackFunc = nil,
    m_version = nil,
};
--[[--
    销毁ui
]]
function game_lucky_turntable_reward_pop.destroy(self)
    -- body
    cclog("----------------- game_lucky_turntable_reward_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_ok_btn = nil;
    self.m_openType = nil;
    self.m_callBackFunc = nil;
    self.m_version = nil;
end
--[[--
    返回
]]
function game_lucky_turntable_reward_pop.back(self,backType)
    game_scene:removePopByName("game_lucky_turntable_reward_pop");
end
--[[--
    读取ccbi创建ui
    icon_box4.png
]]
function game_lucky_turntable_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then--
            self:back()
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_lucky_turntable_reward_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title198)

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_list_view_bg:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_list_view_bg:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_list_view_bg:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_list_view_bg:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_lucky_turntable_reward_pop.createTableView(self,viewSize)
    local roulette_rank_reward_cfg = getConfig(game_config_field.roulette_rank_reward)
    local tempCount = roulette_rank_reward_cfg:getNodeCount();
    local showData = {};
    for i=1,tempCount do
        local itemCfg = roulette_rank_reward_cfg:getNodeAt(i - 1);
        if itemCfg and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_version then
            table.insert(showData,itemCfg:getKey());
        end
    end
    table.sort(showData,function(data1,data2) return tonumber(data1)<tonumber(data2) end)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.6));
            ccbNode:openCCBFile("ccb/ui_active_limit_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local reward_label = ccbNode:labelTTFForName("reward_label");
            local reward_node = ccbNode:nodeForName("reward_node");
            local itemCfg = roulette_rank_reward_cfg:getNodeWithKey(showData[index+1]);
            local rank = itemCfg:getNodeWithKey("rank")
            local rankUp = rank:getNodeAt(0):toInt()
            local rankDown = rank:getNodeAt(1):toInt()
            if rankUp == rankDown then
                reward_label:setString(string_helper.game_lucky_turntable_reward_pop.di .. rankUp .. string_helper.game_lucky_turntable_reward_pop.ming)
            else
                reward_label:setString(string_helper.game_lucky_turntable_reward_pop.di .. rankUp .. "-" .. rankDown .. string_helper.game_lucky_turntable_reward_pop.ming)
            end
            reward_node:removeAllChildrenWithCleanup(true);
            local rank_reward = itemCfg:getNodeWithKey("rank_reward")
            local tempTableView = self:createTableView2(itemSize,json.decode(rank_reward:getFormatBuffer()));
            tempTableView:ignoreAnchorPointForPosition(false);
            tempTableView:setAnchorPoint(ccp(0.5,0.5));
            reward_node:addChild(tempTableView)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建列表
]]
function game_lucky_turntable_reward_pop.createTableView2(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    params.column = 5; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    if tempCount > 4 then
        params.viewSize = viewSize;
    else
        params.column = tempCount; --列
        params.viewSize = CCSizeMake(tempCount * itemSize.width, viewSize.height);
    end
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                icon:setScale(0.65);
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(250,180,0),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_lucky_turntable_reward_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function game_lucky_turntable_reward_pop.refreshUi(self)
    self:refreshTableView();
end
--[[--
    初始化
]]
function game_lucky_turntable_reward_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_tGameData = t_params.gameData or {};
    self.m_openType = t_params.openType or 1;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_version =  t_params.version or 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_lucky_turntable_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_lucky_turntable_reward_pop;
