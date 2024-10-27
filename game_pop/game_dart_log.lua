--- 查看日志
local game_dart_log = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_logType = nil,
    m_list_view_node = nil,
};

--[[--
    销毁
]]
function game_dart_log.destroy(self)
    -- body
    cclog("-----------------game_dart_log destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_logType = nil;
    self.m_list_view_node = nil;
end
--[[--
    返回
]]
function game_dart_log.back(self,type)
    game_scene:removePopByName("game_dart_log");
end
--[[--
    读取ccbi创建ui
]]
function game_dart_log.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_log_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    信息
]]
function game_dart_log.createLogTable(self,viewSize)
    local showData = self.m_tGameData.msg_list or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = #showData;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_dart_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(index)
            local m_time_label = ccbNode:labelTTFForName("m_time_label")
            local m_detail_node_1 = ccbNode:nodeForName("m_detail_node_1")
            local m_detail_node_2 = ccbNode:nodeForName("m_detail_node_2")
            m_detail_node_1:removeAllChildrenWithCleanup(true)
            m_detail_node_2:removeAllChildrenWithCleanup(true)
            m_look_btn:setVisible(false)
            local dimensions = m_detail_node_2:getContentSize();
            local detail_label = game_util:createRichLabelTTF({text = showData[index+1],dimensions = dimensions,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)})
            detail_label:setAnchorPoint(ccp(0,0))
            m_detail_node_2:addChild(detail_label)
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
    信息
]]
function game_dart_log.createBattleLogTable(self,viewSize)
    local showData = self.m_tGameData.battle_log_list or {}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod(tag,gameData)
            self:back();
            game_scene:addPop("game_dart_battle_result",{gameData = gameData})
        end
        local params = {key=showData[btnTag+1].key}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_battle_log"), http_request_method.GET, params,"escort_battle_log")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = #showData;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        end
        if cell then
            local itemData = showData[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(index)
            local m_time_label = ccbNode:labelTTFForName("m_time_label")
            local m_detail_node_1 = ccbNode:nodeForName("m_detail_node_1")
            local m_detail_node_2 = ccbNode:nodeForName("m_detail_node_2")
            m_detail_node_1:removeAllChildrenWithCleanup(true)
            m_detail_node_2:removeAllChildrenWithCleanup(true)
            m_look_btn:setVisible(itemData.sort == 1)
            if itemData.sort == 1 then
                local dimensions = m_detail_node_1:getContentSize();
                local detail_label = game_util:createRichLabelTTF({text = tostring(itemData.msg),dimensions = dimensions,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)})
                detail_label:setAnchorPoint(ccp(0,0))
                m_detail_node_1:addChild(detail_label)
            else
                local dimensions = m_detail_node_2:getContentSize();
                local detail_label = game_util:createRichLabelTTF({text = tostring(itemData.msg),dimensions = dimensions,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)})
                detail_label:setAnchorPoint(ccp(0,0))
                m_detail_node_2:addChild(detail_label)
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
    刷新ui
]]
function game_dart_log.refreshUi(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true)
    local tempTable = nil;
    if self.m_logType == "battle_log" then
        tempTable = self:createBattleLogTable(self.m_list_view_node:getContentSize())
    elseif self.m_logType == "msg_log" then
        tempTable = self:createLogTable(self.m_list_view_node:getContentSize())
    end
    self.m_list_view_node:addChild(tempTable,10)
end
--[[--
    初始化
]]
function game_dart_log.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_logType = t_params.logType or ""
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_log.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_log;