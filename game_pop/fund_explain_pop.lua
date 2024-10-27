--- 基金活动说明

local fund_explain_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_callBackFunc = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_story_label = nil,
    m_showDataTab = nil,
    m_scrollView = nil,

    m_version = nil,
    m_showData = nil,
    m_showIdTab = nil,
};
--[[--
    销毁
]]
function fund_explain_pop.destroy(self)
    -- body
    cclog("-----------------fund_explain_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_callBackFunc = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_story_label = nil;
    self.m_showDataTab = nil;
    self.m_scrollView = nil;

    self.m_version = nil;
    self.m_showData = nil;
    self.m_showIdTab = nil;
end

local titleSpriteImgNameTab = {"fund_final_reward.png","fund_first_day.png","fund_second_day.png","fund_third_day.png",
                                "fund_fourth_day.png","fund_fifth_day.png","fund_sixth_day.png","fund_seventh_day.png"}

--[[--
    返回
]]
function fund_explain_pop.back(self,type)
    game_scene:removePopByName("fund_explain_pop");
end
--[[--
    读取ccbi创建ui
]]
function fund_explain_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_fund_explain.ccbi");
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
function fund_explain_pop.createTabelView(self,viewSize)
    local foundation_cfg = getConfig(game_config_field.foundation)
    local foundation_cfg_tab = json.decode(foundation_cfg:getFormatBuffer()) or {}
    -- local keyTab = {"1","2","3"}
    local keyTab = self.m_showIdTab
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 8;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_fund_explain_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
            local m_reward_layer = ccbNode:layerForName("m_reward_layer")
            m_reward_layer:removeAllChildrenWithCleanup(true);
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(titleSpriteImgNameTab[index+1]))
            if tempSpriteFrame then
                m_icon_spr:setDisplayFrame(tempSpriteFrame)
            end
            local reward = {}
            for i=1,#keyTab do
                local itemCfg = foundation_cfg_tab[keyTab[i]] or {}
                if itemCfg then
                    if index == 0 then
                        local reward_show = itemCfg.reward_show or {}
                        table.insert(reward,reward_show[1] or {})
                    else
                        local dayReward = itemCfg["day" .. index] or {}
                        table.insert(reward,dayReward[1] or {})
                    end
                end
            end
            local tempTableView = self:createTableView2(m_reward_layer:getContentSize(),reward,index);
            tempTableView:setMoveFlag(false)
            m_reward_layer:addChild(tempTableView)
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
function fund_explain_pop.createTableView2(self,viewSize,rewardTab,showIndex)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    -- if tempCount < 3 then
    --     params.column = tempCount; --列
    -- else
        params.column = 3; --列
    -- end
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
            local itemReward = rewardTab[index+1] 
            if itemReward and #itemReward > 0 then
                local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
                if icon then
                    if showIndex > 0 then
                        icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                        icon:setScale(0.5);
                    else
                        icon:setScale(0.65);
                        icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                    end
                    cell:addChild(icon)
                end
                if count then
                    local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(250,180,0),fontSize = 8});
                    tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.15))
                    cell:addChild(tempLabel)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if rewardTab[index+1] and #rewardTab[index+1] > 0 then
                game_util:lookItemDetal(rewardTab[index+1]);
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[
    刷新
]]
function fund_explain_pop.refreshTableView(self)
   self.m_list_view_bg:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.m_list_view_bg:getContentSize());
   self.m_list_view_bg:addChild(tempRewardTable,10,10)
end

--[[--
    刷新ui
]]
function fund_explain_pop.refreshUi(self)
    self:refreshTableView();
    -- 活动详情
    local foundation_cfg = getConfig(game_config_field.foundation)
    local active_msg = string_helper.fund_explain_pop.active_msg
    local tempMsg = ""
    for i,v in ipairs(self.m_showIdTab) do
        local itemCfg = foundation_cfg and foundation_cfg:getNodeWithKey( tostring(v) )
        if itemCfg and itemCfg:getNodeWithKey("notice") then
            tempMsg = itemCfg:getNodeWithKey("notice"):toStr()
            if string.len(tempMsg) > 0 then
                active_msg = tempMsg
                break
            end
        end
    end
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "129" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local viewSize = self.m_scrollView:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollView:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scrollView:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollView:addChild(tempLabel)
end

--[[--
    初始化
]]
function fund_explain_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_showIdTab = t_params.showIdTab or {}
    self.m_showDataTab = {}
end

--[[--
    创建ui入口并初始化数据
]]
function fund_explain_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return fund_explain_pop;