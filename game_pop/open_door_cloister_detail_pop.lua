---  开门活动 回廊详细弹出框

local open_door_cloister_detail_pop = {
    m_list_view_1 = nil,
    m_list_view_2 = nil,
    m_list_view_3 = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_step_label = nil,
    m_name_label = nil,
    m_battle_btn = nil,
    m_node_1 = nil,
    m_node_2 = nil,
    m_tGameData = nil,
    m_stageId = nil,
    m_tips_label_1 = nil,
    m_tips_label_2 = nil,
    m_sel_sort = nil,
    m_callBackFunc = nil,
    log_node = nil,
    log_table_node = nil,
    sort = nil,
    log_list = nil,
};
--[[--
    销毁ui
]]
function open_door_cloister_detail_pop.destroy(self)
    -- body
    cclog("-----------------open_door_cloister_detail_pop destroy-----------------");
    self.m_list_view_1 = nil;
    self.m_list_view_2 = nil;
    self.m_list_view_3 = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_step_label = nil;
    self.m_name_label = nil;
    self.m_battle_btn = nil;
    self.m_node_1 = nil;
    self.m_node_2 = nil;
    self.m_tGameData = nil;
    self.m_stageId = nil;
    self.m_tips_label_1 = nil;
    self.m_tips_label_2 = nil;
    self.m_sel_sort = nil;
    self.m_callBackFunc = nil;
    self.log_node = nil;
    self.log_table_node = nil;
    self.sort = nil;
    self.log_list = nil;
end
--[[--
    返回
]]
function open_door_cloister_detail_pop.back(self,backType)
    game_scene:removePopByName("open_door_cloister_detail_pop");
end
--[[--
    读取ccbi创建ui
]]
function open_door_cloister_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then --挑战
            game_data:setDataByKeyAndValue("sel_maze_stage_id",self.m_stageId);
            if self.m_sel_sort == 1 then
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("open_door_cloister");
                    local lastScore = self.m_tGameData.maze.score
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData,isNext = true,lastScore = lastScore});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_open_next_layer"), http_request_method.GET, {stage_id = self.m_stageId},"maze_open_next_layer")
            elseif self.m_sel_sort == 2 then
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("open_door_cloister");
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_open_stage"), http_request_method.GET, {stage_id = self.m_stageId},"maze_open_stage")
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_open_door_cloister_detail_pop.ccbi");
    self.m_node_1 = ccbNode:nodeForName("m_node_1")
    self.m_node_2 = ccbNode:nodeForName("m_node_2")
    self.m_list_view_1 = ccbNode:nodeForName("m_list_view_1")
    self.m_list_view_2 = ccbNode:nodeForName("m_list_view_2")
    self.m_list_view_3 = ccbNode:nodeForName("m_list_view_3")
    self.m_step_label = ccbNode:labelTTFForName("m_step_label")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_tips_label_1 = ccbNode:labelTTFForName("m_tips_label_1")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")
    self.m_tips_label_2:setString("")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_battle_btn = ccbNode:controlButtonForName("m_battle_btn")
    self.log_node = ccbNode:nodeForName("log_node")
    self.log_table_node = ccbNode:nodeForName("log_table_node")
    self.log_node:setVisible(false)
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_battle_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    创建Log table
]]
function open_door_cloister_detail_pop.createLogTableView(self,viewSize)
    local icon_table = {"huilang_1st.png","huilang_2nd.png","huilang_3th.png"}
    local logData = self.log_list
    local params = {};
    local totalItem = game_util:getTableLen(logData)
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = math.min(totalItem,3); --列
    params.totalItem = totalItem
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_open_door_cloister_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local spr_pos = ccbNode:spriteForName("spr_pos")
            local icon_node = ccbNode:nodeForName("icon_node")
            local name_label = ccbNode:labelTTFForName("name_label")
            spr_pos:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon_table[index + 1]));
            icon_node:removeAllChildrenWithCleanup(true)
            local itemData = logData[index + 1]

            local logs = itemData.logs
            local name = logs.name
            local role = logs.role

            name_label:setString(name)
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            icon:setScale(0.5)
            icon_node:addChild(icon)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemListGameData = logData[index+1]
            local params = {}
            params.layer = self.m_tGameData.maze.layer
            params.uid = itemListGameData.uid
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop_new",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_get_user_info"), http_request_method.GET, params,"maze_get_user_info")
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建列表
]]
function open_door_cloister_detail_pop.createEnemyTableView(self,viewSize)
    local map_fight_and_enemy = game_data:getDataByKey("map_fight_and_enemy") or {}
    local map_fight_cfg = map_fight_and_enemy.map_fight or {}
    local enemy_detail_cfg = map_fight_and_enemy.enemy_detail or {}
    local map_fight_item_cfg = nil;
    for k,v in pairs(map_fight_cfg) do
        map_fight_item_cfg = v;
        break;
    end
    if map_fight_item_cfg == nil then return end
    local showData = {}
    for i=1,5 do
        local positionItem = map_fight_item_cfg["position" .. i] or {}
        local idCount = #positionItem
        if idCount > 0 then
            table.insert(showData,tostring(positionItem[1]))
        end
    end
    local totalItem = #showData
    self.m_tips_label_1:setVisible(totalItem == 0)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = math.min(totalItem,5); --列
    params.totalItem = totalItem
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local enemy_detail_item_cfg = enemy_detail_cfg[showData[index+1]]
            if enemy_detail_item_cfg then
                local tempIcon = game_util:createIconByName(tostring(enemy_detail_item_cfg.img))
                if tempIcon then
                    tempIcon:setScale(0.65);
                    tempIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                    cell:addChild(tempIcon);
                    local tempLabel = game_util:createLabelTTF({text = tostring(enemy_detail_item_cfg.enemy_name),color = ccc3(255,255,255),fontSize = 8});
                    tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                    cell:addChild(tempLabel)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local enemy_detail_item_cfg = enemy_detail_cfg[showData[index+1]]
            local x,y = item:getPosition();
            local realPos = item:getParent():convertToWorldSpace(ccp(x+itemSize.width*0.5,y+itemSize.height*0.5));
            game_scene:addPop("game_enemy_info_pop",{itemCfg = enemy_detail_item_cfg,pos = realPos})
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建奖励列表
]]
function open_door_cloister_detail_pop.createRewardTableView(self,viewSize)
    local maze_stage_cfg = getConfig(game_config_field.maze_stage)
    local maze_buff_cfg = getConfig(game_config_field.maze_buff)
    local maze_item_cfg = getConfig(game_config_field.maze_item)
    local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(tostring(self.m_stageId));
    local item = maze_stage_cfg_item:getNodeWithKey("item")
    local buff = maze_stage_cfg_item:getNodeWithKey("buff")
    local itemCount = item:getNodeCount()
    local buffCount = buff:getNodeCount()
    local showData = {}
    for i=1,buffCount do
        table.insert(showData,{1,buff:getNodeAt(i-1):toStr()})
    end
    for i=1,itemCount do
        table.insert(showData,{2,item:getNodeAt(i-1):toStr()})
    end
    local totalItem = #showData
    self.m_tips_label_2:setVisible(totalItem == 0)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = math.min(totalItem,5); --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local itemData = showData[index+1]
            local rewardType = itemData[1]
            local itemId = itemData[2]
            local itemCfg = nil
            if rewardType == 1 then
                itemCfg = maze_buff_cfg:getNodeWithKey(itemId);
            else
                itemCfg = maze_item_cfg:getNodeWithKey(itemId);
            end
            if itemCfg then
                local tempIcon = game_util:createMazeItemIconByCfg(itemCfg);
                if tempIcon then
                    tempIcon:setScale(0.75);
                    tempIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                    cell:addChild(tempIcon)
                end
                local tempLabel = game_util:createLabelTTF({text = itemCfg:getNodeWithKey("name"):toStr(),color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = showData[index+1]
            local rewardType = itemData[1]
            local itemId = itemData[2]
            --1变2  2变1
            rewardType = rewardType % 2 + 1
            game_scene:addPop("game_maze_item_pop",{itemData = {id = itemId},itemType = rewardType,openType = 2})
        end
    end
    return TableViewHelper:create(params);
end

function open_door_cloister_detail_pop.createTableView(self,viewSize)
    local maze_item_cfg = getConfig(game_config_field.maze_item)
    local maze_stage_cfg = getConfig(game_config_field.maze_stage)
    local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(tostring(self.m_stageId));
    local shop = maze_stage_cfg_item:getNodeWithKey("shop")
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = shop:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_open_door_cloister_detail_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_add_attr_label = ccbNode:labelTTFForName("m_add_attr_label")
            local m_cost_label = ccbNode:labelTTFForName("m_cost_label")
            local itemCfg = shop:getNodeAt(index)

            m_add_attr_label:setString(self:getTipsName(itemCfg))
            local maze_item_cfg_item = maze_item_cfg:getNodeWithKey("1")
            if maze_item_cfg_item then
                local value3 = itemCfg:getNodeAt(2):toInt();
                local name = maze_item_cfg_item:getNodeWithKey("name"):toStr();
                if value3 > 0 then
                    m_cost_label:setString(string_helper.open_door_cloister_detail_pop.cost .. name .. "×" .. value3)
                else
                    m_cost_label:setString("")
                end
            else
                m_cost_label:setString("");
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local gameData = json.decode(data:getFormatBuffer()) or {};
                local itemCfg = shop:getNodeAt(index)
                game_util:createMazeRewardTips(self.m_stageId,index);
                if self.m_callBackFunc then
                    self.m_callBackFunc({gameData = gameData})
                end
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_open_shop"), http_request_method.GET, {stage_id = self.m_stageId,pos = index},"maze_open_shop")
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function open_door_cloister_detail_pop.getTipsName(self,itemCfg)
    -- [类型，ID，价格]
    -- 类型：1BUFF，2道具，3回血，4回血量
    -- ID：当类型为1,2时表示ID，类型为3时表示回血百分比，类型4时表示回血的值
    -- 价格表示所需的maze_itemID为1的道具数量
    local maze_item_cfg = getConfig(game_config_field.maze_item)
    local maze_buff_cfg = getConfig(game_config_field.maze_buff)
    local name = "";
    local value1 = itemCfg:getNodeAt(0):toInt();
    local value2 = itemCfg:getNodeAt(1):toInt();
    if value1 == 1 then
        local maze_buff_cfg_item = maze_buff_cfg:getNodeWithKey(tostring(value2))
        if maze_buff_cfg_item then
            name = maze_buff_cfg_item:getNodeWithKey("name"):toStr();
        end
    elseif value1 == 2 then
        local maze_item_cfg_item = maze_item_cfg:getNodeWithKey(tostring(value2))
        if maze_item_cfg_item then
            name = maze_item_cfg_item:getNodeWithKey("name"):toStr()
        end
    elseif value1 == 3 then
        name = string_helper.open_door_cloister_detail_pop.hp .. value2 .. "%"
    elseif value1 == 4 then
        name = string_helper.open_door_cloister_detail_pop.hp .. value2
    end
    return name;
end

--[[--
    刷新
]]
function open_door_cloister_detail_pop.refreshEnemyTableView(self)
    self.m_list_view_1:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createEnemyTableView(self.m_list_view_1:getContentSize());
    self.m_list_view_1:addChild(tableViewTemp);
end

--[[--
    刷新
]]
function open_door_cloister_detail_pop.refreshRewardTableView(self)
    self.m_list_view_2:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTableView(self.m_list_view_2:getContentSize());
    self.m_list_view_2:addChild(tableViewTemp)
end


--[[--
    刷新
]]
function open_door_cloister_detail_pop.refreshTableView(self)
    self.m_list_view_3:removeAllChildrenWithCleanup(true);
    local tableView = self:createTableView(self.m_list_view_3:getContentSize());
    tableView:setScrollBarVisible(true);
    self.m_list_view_3:addChild(tableView,10,10);
end

function open_door_cloister_detail_pop.refreshLogTableView(self)
    self.log_table_node:removeAllChildrenWithCleanup(true)
    local logView = self:createLogTableView(self.log_table_node:getContentSize())
    self.log_table_node:addChild(logView,10,10)
end

function open_door_cloister_detail_pop.refreshNode1(self)
    self.m_node_1:setVisible(true)
    self.m_node_2:setVisible(false)
    self.m_list_view_3:removeAllChildrenWithCleanup(true);
    self:refreshEnemyTableView();
    self:refreshRewardTableView();
end

function open_door_cloister_detail_pop.refreshNode2(self)
    self.m_node_1:setVisible(false)
    self.m_node_2:setVisible(true)
    self.m_list_view_1:removeAllChildrenWithCleanup(true);
    self.m_list_view_2:removeAllChildrenWithCleanup(true);
    self:refreshTableView();
end

--[[--
    刷新ui
]]
function open_door_cloister_detail_pop.refreshUi(self)
    self.m_node_1:setVisible(false)
    self.m_node_2:setVisible(false)
    local maze_stage_cfg = getConfig(game_config_field.maze_stage)
    local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(tostring(self.m_stageId));
    local maze = self.m_tGameData.maze or {}
    local layer = maze.layer or 1
    self.m_step_label:setString(string.format(string_helper.open_door_cloister_detail_pop.layer,tostring(layer)))
    if maze_stage_cfg_item then
        self.m_name_label:setString(maze_stage_cfg_item:getNodeWithKey("name"):toStr())
        local sort = maze_stage_cfg_item:getNodeWithKey("sort"):toInt();
        self.m_sel_sort = sort;
        if sort ==1 or sort == 2 then
            self:refreshNode1();
        else
            self:refreshNode2();
        end
    end
    if self.sort == 1 then
        self.log_node:setVisible(true)
        self:refreshLogTableView()
    else
        self.log_node:setVisible(false)
    end
end
--[[--
    初始化
]]
function open_door_cloister_detail_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = t_params.gameData or {}
    self.m_stageId = t_params.stageId;
    self.sort = t_params.sort or 2
    self.log_list = t_params.log_list or {}
    self.m_callBackFunc = t_params.callBackFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_cloister_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return open_door_cloister_detail_pop;