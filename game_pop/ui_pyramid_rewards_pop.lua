---  金字塔每层奖励信息弹出框
cclog2 = cclog2 or function() end
local ui_pyramid_rewards_pop = {
    m_root_layer = nil,
    m_node_rewards = nil,
    m_curLevel_reward = nil,
    m_showLevel = nil,
};
--[[--
    销毁ui
]]
function ui_pyramid_rewards_pop.destroy(self)
    -- body
    cclog("----------------- ui_pyramid_rewards_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_node_rewards = nil;
    self.m_curLevel_reward = nil;
    self.m_showLevel = nil;
end
--[[--
    返回
]]
function ui_pyramid_rewards_pop.back(self,backType)
    game_scene:removePopByName("ui_pyramid_rewards_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_pyramid_rewards_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then  -- 进入本层

        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_reward_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_root_layer:setTouchEnabled(true);

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_node_rewards:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_rewards:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    self.m_root_layer:setTouchEnabled(true);

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    local layer = CCLayer:create()
    layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    layer:setTouchEnabled(true);
    self.m_root_layer:addChild(layer)

    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);
    self.m_node_rewards = ccbNode:nodeForName("m_node_rewards")
    return ccbNode;
end


--[[
    创建横奖励列表
]]
function ui_pyramid_rewards_pop.createTableView( self, viewBoard, rewardList )
    if not rewardList then return end
    local showData = rewardList
    local viewSize = viewBoard:getContentSize()
    -- cclog2(rewardList, "rewardList ==== ")
    function onBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local itemData = rewardList[btnTag + 1]
        if itemData then
            game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
        end
    end
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    if tempCount < 4 then 
        params.column = math.max(tempCount, 1)
    end
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-7;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)

                if icon and count then
                    countStr = "×" .. tostring(count)
                    local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5,0.5))
                    label_count:setPosition(ccp(0,-20))
                    node:addChild(label_count,20)
                end

                local node = icon:getChildByTag(1)
                if node then
                    node:setVisible(false)
                end
                local iconSize = icon:getContentSize()
                local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                if sprBoard then
                    sprBoard:setPosition(iconSize.width * 0.5, iconSize.height * 0.6)
                    icon:addChild(sprBoard, 20, 20)
                end
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showData[index + 1]
            if itemData then
                game_util:lookItemDetal(itemData)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    local tableView =  TableViewHelper:create(params);
    if tableView then
        viewBoard:addChild(tableView)
    end
end


--[[--
    刷新ui
]]
function ui_pyramid_rewards_pop.refreshUi(self)




    self.m_node_rewards:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView( self.m_node_rewards, self.m_curLevel_reward)
    if tableView then
        self.m_node_rewards:addChild(tableView)
    end
end
--[[--
    初始化
]]
function ui_pyramid_rewards_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_showLevel = t_params.showLevel


    local pyramid_level_cfg = getConfig(game_config_field.pyramid_level)    
    local curLevel = self.m_showLevel
    local curLevelCfg = pyramid_level_cfg:getNodeWithKey(tostring(curLevel))
    local reward = curLevelCfg and curLevelCfg:getNodeWithKey("reward_show")
    -- cclog2(curLevel, "curLevel  ====  ")
    -- cclog2(pyramid_level_cfg, "pyramid_level_cfg  ====  ")
    -- cclog2(curLevelCfg, "curLevelCfg  ====  ")
    -- cclog2(reward, "reward  ====  ")
    self.m_curLevel_reward = reward and json.decode(reward:getFormatBuffer()) or {}
end
--[[--
    创建ui入口并初始化数据
]]
function ui_pyramid_rewards_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_pyramid_rewards_pop;
