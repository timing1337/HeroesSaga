--- 信息

local game_box_inside_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,
    m_look_flag = nil,
    m_table_view = nil,
    m_isBeganIn = nil,
    whatsIn = nil,
};

--[[--
    销毁
]]

function game_box_inside_pop.destroy(self)
    -- body
    cclog("-----------------game_box_inside_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.m_look_flag = nil;
    self.m_table_view = nil;
    self.m_isBeganIn = nil;
    self.whatsIn = nil;
    self.m_root_layer = nil;
end
--[[--
    返回
]]
function game_box_inside_pop.back(self,type)
    game_scene:removePopByName("game_box_inside_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_box_inside_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            -- self:back();
        elseif btnTag == 2 then

        elseif btnTag == 3 then
            -- self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_box_inside_pop.ccbi");
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    self.m_table_view = ccbNode:nodeForName("table_node");

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));
            self.m_isBeganIn = self.m_table_view:boundingBox():containsPoint(realPos)
            return true;
        elseif eventType == "ended" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            local isEndIn = self.m_table_view:boundingBox():containsPoint(realPos)
            if isEndIn == false and self.m_isBeganIn == false then
               self:back()
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-20,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[

]]--
function game_box_inside_pop.createTableView(self,viewSize)
    --宝箱道具ID
    local boxID = {7,8,9,20,21,22,23,27,28}
    --初级宝箱、中级、高级、伙伴A、B、C、救世主、统率、统率
    --对应whatInSide的ID
    local whatInId = {1,2,3,10,11,12,13,9,9}

    local changeTab = {}
    for i=1,#boxID do
        changeTab[boxID[i]] = whatInId[i]
    end
    local insideCfg = getConfig(game_config_field.whats_inside)
    local insideId = changeTab[self.m_itemId]
    local itemCfg = insideCfg:getNodeWithKey(tostring(insideId)):getNodeWithKey("whats_inside")
    cclog("itemCfg == " .. itemCfg:getFormatBuffer())
    local cardsCount = itemCfg:getNodeCount();
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 4; --列
    params.totalItem = cardsCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-21;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_box_inside_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_icon_spr = ccbNode:nodeForName("m_icon_spr");
            local m_title_label = ccbNode:labelTTFForName("m_title_label");
            local reward_sprite_4 = ccbNode:spriteForName("reward_sprite_4");
            local cellCfg = itemCfg:getNodeAt(index)
            local rewardTab = {}
            for i=1,3 do
                rewardTab[i] = cellCfg:getNodeAt(i-1):toInt()
            end
            local icon,name,count = game_util:getRewardByItemTable(rewardTab)
            if icon then
                -- m_icon_spr:setDisplayFrame(icon:displayFrame())
                m_icon_spr:removeAllChildrenWithCleanup(true)
                m_icon_spr:addChild(icon)
                m_title_label:setString(name)
            end
            local light_flag = cellCfg:getNodeAt(3):toInt()
            -- reward_sprite_4:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_faguang_2.png"))
            if light_flag == 0 then--发光
                reward_sprite_4:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_faguang_2.png"))
            else
                reward_sprite_4:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_faguang.png"))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)        
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[
    已知what inside 内容的列表
]]
function game_box_inside_pop.createWhatInSide(self,viewSize)
    local totalCount = game_util:getTableLen(self.whatsIn)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 4; --列
    params.totalItem = totalCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-21;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_box_inside_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_icon_spr = ccbNode:nodeForName("m_icon_spr");
            local m_title_label = ccbNode:labelTTFForName("m_title_label");
            local reward_sprite_4 = ccbNode:spriteForName("reward_sprite_4");
            local cellCfg = self.whatsIn[index+1]
            local rewardTab = {}
            for i=1,3 do
                rewardTab[i] = cellCfg[i]
            end
            local icon,name,count = game_util:getRewardByItemTable(rewardTab)
            if icon then
                m_icon_spr:removeAllChildrenWithCleanup(true)
                m_icon_spr:addChild(icon)
                m_title_label:setString(name)
            end
            local light_flag = cellCfg[4]
            if light_flag == 0 then--发光
                reward_sprite_4:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_faguang_2.png"))
            else
                reward_sprite_4:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_faguang.png"))
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)        
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_box_inside_pop.refreshUi(self)
    if self.m_openType == 1 then
        self.m_table_view:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_table_view:addChild(tableViewTemp,10,10);
    else
        self.m_table_view:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createWhatInSide(self.m_table_view:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_table_view:addChild(tableViewTemp,10,10);
    end
end

--[[--
    初始化
]]
function game_box_inside_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_itemId = t_params.itemId;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_openType = t_params.openType or 1;
    self.whatsIn = t_params.whatsIn
end

--[[--
    创建ui入口并初始化数据
]]
function game_box_inside_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    if self.m_itemId == nil then return end
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_box_inside_pop;