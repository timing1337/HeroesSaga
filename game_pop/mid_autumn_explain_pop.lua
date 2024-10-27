--- 中秋活动说明

local mid_autumn_explain_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_callBackFunc = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_story_label = nil,
    m_showDataTab = nil,
    m_scrollView = nil,
    m_tGameData = nil,
    m_own_rank_label = nil,
};
--[[--
    销毁
]]
function mid_autumn_explain_pop.destroy(self)
    -- body
    cclog("-----------------mid_autumn_explain_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_callBackFunc = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_story_label = nil;
    self.m_showDataTab = nil;
    self.m_scrollView = nil;
    self.m_tGameData = nil;
    self.m_own_rank_label = nil;
end
--[[--
    返回
]]
function mid_autumn_explain_pop.back(self,type)
    game_scene:removePopByName("mid_autumn_explain_pop");
end
--[[--
    读取ccbi创建ui
]]
function mid_autumn_explain_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_mid_autumn_explain.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_story_label = ccbNode:labelTTFForName("m_story_label")
    self.m_own_rank_label = ccbNode:labelTTFForName("m_own_rank_label")
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
function mid_autumn_explain_pop.createTabelView(self,viewSize)
    local group_rank_cfg = getConfig(game_config_field.group_rank)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #self.m_showDataTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_mid_autumn_explain_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_rank_label = ccbNode:labelBMFontForName("m_rank_label")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_cost_label = ccbNode:labelTTFForName("m_cost_label")
            local m_detail_label = ccbNode:labelTTFForName("m_detail_label")
            local title160 = ccbNode:labelTTFForName("title160");
            title160:setString(string_helper.ccb.title160);
            m_rank_label:setString(tostring(index+1))
            local tempData = self.m_showDataTab[index+1]
            local itemData = tempData.itemData
            local itemCfg = tempData.itemCfg
            m_name_label:setString(tostring(itemData.name))
            m_cost_label:setString(tostring(itemData.score))
            local diamond_off = itemCfg:getNodeWithKey("diamond_off"):toInt();
            local des = itemCfg:getNodeWithKey("des"):toStr();
            des = string.gsub(des,"num",tostring(diamond_off));
            m_detail_label:setString(des);
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

--[[
    刷新
]]
function mid_autumn_explain_pop.refreshTableView(self)
   self.m_list_view_bg:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTabelView(self.m_list_view_bg:getContentSize());
   self.m_list_view_bg:addChild(tempRewardTable,10,10)
end

--[[--
    刷新ui
]]
function mid_autumn_explain_pop.refreshUi(self)
    self:refreshTableView();
    -- 活动详情
    local activeCfg = getConfig(game_config_field.group_version)
    local itemCfg = activeCfg and activeCfg:getNodeWithKey(tostring(self.m_tGameData.version))
    local active_msg = itemCfg and itemCfg:getNodeWithKey("notice_1") and itemCfg:getNodeWithKey("notice_1"):toStr() or ""
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "127" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local viewSize = self.m_scrollView:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollView:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scrollView:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollView:addChild(tempLabel)
    local user_rank = self.m_tGameData.user_rank or 0
    self.m_own_rank_label:setString(string_helper.mid_autumn_explain_pop.myrank .. tostring(user_rank));
end

--[[--
    初始化
]]
function mid_autumn_explain_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_fromUi = t_params.fromUi;
    self.m_callBackFunc = t_params.callBackFunc;
    local ranks = self.m_tGameData.ranks or {}
    self.m_showDataTab = {}
    local group_rank_cfg = getConfig(game_config_field.group_rank)
    local tempCount = group_rank_cfg:getNodeCount();
    local rank_tab = {}
    for i=1, tempCount do
        local itemCfg = group_rank_cfg:getNodeAt(i - 1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.version) then
            table.insert(rank_tab, itemCfg:getKey())
        end
    end
    table.sort(rank_tab, function (data1, data2) return tonumber(data1) < tonumber(data2) end)
    for i=1,#ranks do
        local key = rank_tab[i]
        local itemCfg = group_rank_cfg:getNodeWithKey(tostring(key))
        if itemCfg then
            table.insert(self.m_showDataTab,{itemData = ranks[i],itemCfg = itemCfg,rank = i})
        end
    end
    table.sort(self.m_showDataTab,function(data1,data2) return tonumber(data1.rank) < tonumber(data2.rank) end)
end

--[[--
    创建ui入口并初始化数据
]]
function mid_autumn_explain_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return mid_autumn_explain_pop;