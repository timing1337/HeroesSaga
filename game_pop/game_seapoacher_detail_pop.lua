---  海贼王藏宝活动详情

local game_seapoacher_detail_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_node_view_ranking = nil,
    m_tGameData = nil,
    m_ccbNode = nil,
    m_title_sprite = nil,
    m_show_ranking = nil,
};
--[[--
    销毁ui
]]
function game_seapoacher_detail_pop.destroy(self)
    -- body
    cclog("----------------- game_seapoacher_detail_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_node_view_ranking = nil;
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.m_title_sprite = nil;
    self.m_show_ranking = nil;
end
--[[--
    返回
]]
function game_seapoacher_detail_pop.back(self,backType)
    game_scene:removePopByName("game_seapoacher_detail_pop");
end
--[[--
    读取ccbi创建ui
    icon_box4.png
]]
function game_seapoacher_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then--
            self:back()
        elseif btnTag == 11 or btnTag == 12 then
            self:refreshTabByType(btnTag - 10);
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_seapoacher_detail_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    self.m_node_view_ranking = ccbNode:layerForName("m_node_view_ranking")
    self.m_title_sprite = ccbNode:spriteForName("m_title_sprite")

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_node_view_ranking:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_view_ranking:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_node_view_ranking:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_node_view_ranking:setTouchEnabled(true);
    for i=1,2 do
        local tempBtn = ccbNode:controlButtonForName("m_tab_btn_" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
        end
    end
    self.m_ccbNode = ccbNode;

    m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    game_util:setCCControlButtonTitle(m_tab_btn_1,string_helper.ccb.file80)
    game_util:setCCControlButtonTitle(m_tab_btn_2,string_helper.ccb.file81)
    return ccbNode;
end

--[[--
    创建列表
]]
function game_seapoacher_detail_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_new_rank.plist");
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local rank_info = self.m_tGameData.rank_info or {}
    local rank_info_ids = {};
    for k,v in pairs(rank_info) do
        table.insert(rank_info_ids,k)
    end
    table.sort(rank_info_ids,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 1 -- 列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #rank_info_ids
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:openCCBFile("ccb/ui_game_seapoacher_rank_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = rank_info[rank_info_ids[index+1]]
            local rank_number = ccbNode:labelBMFontForName("rank_number")
            local fight_point_label = ccbNode:labelBMFontForName("fight_point_label")
            local top_icon = ccbNode:spriteForName("top_icon");
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            rank_number:setString(tostring(index+1))
            fight_point_label:setString(tostring(itemData.score))
            local tempNameLabel = ccbNode:labelTTFForName("m_user_label")
            tempNameLabel:setString(tostring(itemData.name))
            local m_reward_layer = ccbNode:layerForName("m_reward_layer")
            m_reward_layer:removeAllChildrenWithCleanup(true);
            local reward = self:getRankReward(index+1);
            local tempTableView = self:createRewardTableView(m_reward_layer:getContentSize(),reward);
            m_reward_layer:addChild(tempTableView)
            if index < 3 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1])
                if tempSpriteFrame then
                    top_icon:setDisplayFrame(tempSpriteFrame)
                end
                m_sprite9_cellbg:setColor(colorTab[index+1])
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            -- game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

function game_seapoacher_detail_pop.getRankReward(self,rankValue)
    local one_piece_rank_reward_cfg = getConfig(game_config_field.one_piece_rank_reward)
    local tempCount = one_piece_rank_reward_cfg:getNodeCount();
    local rewardTab = nil;
    for i=1,tempCount do
        local itemCfg = one_piece_rank_reward_cfg:getNodeAt(i-1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.version) then
            local rank = itemCfg:getNodeWithKey("rank")
            local rankUp = rank:getNodeAt(0):toInt();
            local rankDown = rank:getNodeAt(1):toInt();
            if rankValue >= rankUp and rankValue <= rankDown then
                local rank_reward = itemCfg:getNodeWithKey("rank_reward")
                rewardTab = json.decode(rank_reward:getFormatBuffer()) or {}
            end
        end
    end
    return rewardTab;
end

--[[--
    创建列表
]]
function game_seapoacher_detail_pop.createRewardTableView(self,viewSize,rewardTab)
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
                local tempLabel = game_util:createLabelTTF({text = "×" .. tostring(count),color = ccc3(255,255,255),fontSize = 8});
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

--[[--
    刷新
]]
function game_seapoacher_detail_pop.refreshTableView(self)
    self.m_node_view_ranking:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_node_view_ranking:getContentSize());
    self.m_node_view_ranking:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function game_seapoacher_detail_pop.refreshTab1(self)
    local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_seapoacher_active.png")
    if spriteFrame then
        self.m_title_sprite:setDisplayFrame(spriteFrame)
    end
    self.m_node_view_ranking:removeAllChildrenWithCleanup(true);
    local labelsize = self.m_node_view_ranking:getContentSize();
    local scrollView = CCScrollView:create(labelsize);
    scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    self.m_node_view_ranking:addChild(scrollView,2,2);
    scrollView:getContainer():removeAllChildrenWithCleanup(true);

    -- 活动详情
    local activeCfg = getConfig(game_config_field.one_piece)
    local acitve_cfg = activeCfg:getNodeWithKey(tostring(self.m_tGameData.version))
    local active_msg = acitve_cfg and acitve_cfg:getNodeWithKey("notice") and acitve_cfg:getNodeWithKey("notice"):toStr() or ""
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "136" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local fate_detail_label = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(labelsize.width, 0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192)})
    fate_detail_label:setAnchorPoint(ccp(0, 0));
    scrollView:addChild(fate_detail_label)
    local contentSize = fate_detail_label:getContentSize();
    scrollView:setContentSize(CCSizeMake(contentSize.width, math.max(contentSize.height,labelsize.height)));
    if contentSize.height < labelsize.height then
        fate_detail_label:setPosition(ccp(0, labelsize.height - contentSize.height));
        scrollView:setContentOffset(ccp(0, 0),false)
    else
        scrollView:setContentOffset(ccp(0, labelsize.height - contentSize.height),false)
    end
end

--[[--
    刷新ui
]]
function game_seapoacher_detail_pop.refreshTab2(self)
    local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("details_ranking.png")
    if spriteFrame then
        self.m_title_sprite:setDisplayFrame(spriteFrame)
    end
    self:refreshTableView();
end

--[[--
    刷新ui
]]
function game_seapoacher_detail_pop.refreshTabByType(self,typeValue)
    for i=1,2 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        if tempBtn and i == typeValue then
            tempBtn:setColor(ccc3(255, 255, 255));
            tempBtn:setEnabled(false);
        elseif tempBtn then
            tempBtn:setColor(ccc3(155, 155, 155));
            tempBtn:setEnabled(true);
        end
    end
    if typeValue == 1 then
        self:refreshTab1();
    elseif typeValue == 2 then
        self:refreshTab2();
    end
end

--[[--
    刷新ui
]]
function game_seapoacher_detail_pop.refreshUi(self)
    local show_ranking = self.m_show_ranking
    for i=1,2 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        if tempBtn then
            tempBtn:setVisible(show_ranking == 1)
        end
    end
    if show_ranking ~= 1 then
        self:refreshTabByType(1);
    else
        self:refreshTabByType(2);
    end
end
--[[--
    初始化
]]
function game_seapoacher_detail_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_show_ranking = t_params.show_ranking or 0
end
--[[--
    创建ui入口并初始化数据
]]
function game_seapoacher_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_seapoacher_detail_pop;
