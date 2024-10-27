--- 龙珠活动说明

local dragon_ball_explain_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_callBackFunc = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_story_label = nil,
    m_showIdTab = nil,
    m_scrollView = nil,
    m_version = nil,
};
--[[--
    销毁
]]
function dragon_ball_explain_pop.destroy(self)
    -- body
    cclog("-----------------dragon_ball_explain_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_callBackFunc = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_story_label = nil;
    self.m_showIdTab = nil;
    self.m_scrollView = nil;
    self.m_version = nil;
end
--[[--
    返回
]]
function dragon_ball_explain_pop.back(self,type)
    game_scene:removePopByName("dragon_ball_explain_pop");
end
--[[--
    读取ccbi创建ui
]]
function dragon_ball_explain_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_dragon_ball_explain.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_story_label = ccbNode:labelTTFForName("m_story_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_scrollView = ccbNode:scrollViewForName("m_scrollView")
    self.m_scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_list_view_bg:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_list_view_bg:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_list_view_bg:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_list_view_bg:setTouchEnabled(true);
    return ccbNode;
end

--[[
    创建列表
]]
function dragon_ball_explain_pop.createTabelView(self,viewSize)
    local super_all_cfg = getConfig(game_config_field.super_all)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #self.m_showIdTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_dragon_ball_explain_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
            local m_name_spr = ccbNode:spriteForName("m_name_spr")
            local m_detail_label = ccbNode:labelTTFForName("m_detail_label")
            local m_reward_layer = ccbNode:layerForName("m_reward_layer")
            m_reward_layer:removeAllChildrenWithCleanup(true);
            local itemCfg = super_all_cfg:getNodeWithKey(self.m_showIdTab[index + 1])
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dragon_ball_icon_" .. (index+1) .. ".png")
            if tempSpriteFrame then
                m_icon_spr:setDisplayFrame(tempSpriteFrame)
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dragon_ball_wenzi_" .. (index+1) .. ".png")
            if tempSpriteFrame then
                m_name_spr:setDisplayFrame(tempSpriteFrame)
            end
            if itemCfg then
                local score = itemCfg:getNodeWithKey("score"):toInt();
                local base = itemCfg:getNodeWithKey("base"):toInt();
                m_detail_label:setString(string_helper.dragon_ball_explain_pop.needCoin .. score .. string_helper.dragon_ball_explain_pop.needCoin2);
                local reward = itemCfg:getNodeWithKey("reward");
                local tempTableView = self:createTableView2(m_reward_layer:getContentSize(),json.decode(reward:getFormatBuffer()));
                m_reward_layer:addChild(tempTableView)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end


--[[--
    创建列表
]]
function dragon_ball_explain_pop.createTableView2(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    if tempCount < 3 then
        params.column = tempCount; --列
    else
        params.column = 3; --列
    end
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.viewSize = viewSize;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
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
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                icon:setScale(0.65);
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(250,180,0),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
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

--[[
    刷新
]]
function dragon_ball_explain_pop.refreshTableView(self)
   self.m_list_view_bg:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.m_list_view_bg:getContentSize());
   self.m_list_view_bg:addChild(tempRewardTable,10,10)
end

--[[--
    刷新ui
]]
function dragon_ball_explain_pop.refreshUi(self)
    self:refreshTableView();
    -- 活动详情
    local super_active_cfg = getConfig(game_config_field.super_all)
    local tempCount = super_active_cfg and super_active_cfg:getNodeCount() or 0
    local active_tab = {}
    for i=1, tempCount do
        local itemCfg = super_active_cfg:getNodeAt(i - 1)
        -- cclog2(itemCfg:getKey(), " version  =====    " .. tostring(self.m_version))
        if game_util:compareItemCfgVersion(itemCfg, self.m_version) then
            table.insert(active_tab, itemCfg:getKey())
        end
    end
    table.sort(active_tab, function(data1, data2) return tonumber(data1) < tonumber(data2) end)
    -- cclog2(active_tab, "active_tab  ======    ")
    local active_msg = ""
    for i,v in ipairs(active_tab) do
        local tempCfg = super_active_cfg and super_active_cfg:getNodeWithKey(tostring(active_tab[i]))
        -- cclog2(tempCfg, "tempCfg  ======   ")
        active_msg = tempCfg and tempCfg:getNodeWithKey("notice") and tempCfg:getNodeWithKey("notice"):toStr() or ""
        if string.len(active_msg) > 0 then
            break
        end
    end
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "120" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local viewSize = self.m_scrollView:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollView:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scrollView:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollView:addChild(tempLabel)
end

--[[--
    初始化
]]
function dragon_ball_explain_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_version = t_params.version 
    self.m_showIdTab = {}
    local super_all_cfg = getConfig(game_config_field.super_all)
    local tempCount = super_all_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = super_all_cfg:getNodeAt(i - 1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_version ) then
            table.insert(self.m_showIdTab,itemCfg:getKey())
        end
    end
    table.sort(self.m_showIdTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
end

--[[--
    创建ui入口并初始化数据
]]
function dragon_ball_explain_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return dragon_ball_explain_pop;