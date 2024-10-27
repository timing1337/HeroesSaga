--- 开门活动 回廊详细

local open_door_cloister_detail = {
    m_close_btn = nil,
    m_ok_btn = nil,
    m_list_view_node = nil,
    m_blessing_list_node = nil,
    m_item_list_node = nil,
    m_score_label = nil,
    m_record_label = nil,
    m_life_percent_label = nil,
    m_progress_bar = nil,
    m_tGameData = nil,
    m_ccbNode = nil,
    last_layer = nil,
    enterFlag = nil,
};
--[[--
    销毁
]]
function open_door_cloister_detail.destroy(self)
    -- body
    cclog("-----------------open_door_cloister_detail destroy-----------------");
    self.m_close_btn = nil;
    self.m_ok_btn = nil;
    self.m_list_view_node = nil;
    self.m_blessing_list_node = nil;
    self.m_item_list_node = nil;
    self.m_score_label = nil;
    self.m_record_label = nil;
    self.m_life_percent_label = nil;
    self.m_progress_bar = nil;
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.enterFlag = nil;
end
--[[--
    返回
]]
function open_door_cloister_detail.back(self,type)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("open_door_cloister",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_index"), http_request_method.GET, nil,"maze_index")
end
--[[--
    读取ccbi创建ui
]]
function open_door_cloister_detail.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 10 then--阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="cloister"});
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_door_cloister_detail.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_blessing_list_node = ccbNode:nodeForName("m_blessing_list_node");
    self.m_item_list_node = ccbNode:nodeForName("m_item_list_node");
    self.m_score_label = ccbNode:labelTTFForName("m_score_label");
    self.m_record_label = ccbNode:labelBMFontForName("m_record_label");
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node");
    self.m_life_percent_label = ccbNode:labelTTFForName("m_life_percent_label")
    self.life_icon = ccbNode:spriteForName("life_icon")
    local m_life_bar_bg = ccbNode:nodeForName("m_life_bar_bg")
    local barSize = m_life_bar_bg:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("xjhl_xuetiao2.png","xjhl_xuetiao.png");
    bar:setCurValue(0,false);
    m_life_bar_bg:addChild(bar);
    self.m_progress_bar = bar;
    self.m_ccbNode = ccbNode;

    local animName = "enter_anim"
    local function animCallFunc(animName)
        ccbNode:runAnimations(animName)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    --失败动画
    local maze = self.m_tGameData.maze or {}
    local total_hp_rate = maze.total_hp_rate or 0
    -- 下一层动画
    if total_hp_rate <= 0 then
        game_scene:addPop("open_door_cloister_result_pop",{winFlag = "lose", maze = self.m_tGameData.maze,lastScore = self.lastScore})
    elseif self.isNext == true then
        game_scene:addPop("open_door_cloister_result_pop",{winFlag = "win",maze = self.m_tGameData.maze,lastScore = self.lastScore})
    end
    --第一次动画
    if self.enterFlag == 12 then
        game_scene:addPop("open_door_cloister_first_pop",{})
    end
    return ccbNode;
end

function open_door_cloister_detail.createTableView(self,viewSize)
    local maze = self.m_tGameData.maze or {}
    local builded = maze.builded or {}
    local layer = maze.layer or 1
    local maze_mine_cfg = getConfig(game_config_field.maze_mine)
    local maze_mine_cfg_item = maze_mine_cfg:getNodeWithKey(tostring(layer))
    local maze_stage_cfg = getConfig(game_config_field.maze_stage)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 9;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_open_door_cloister_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_flag_label = ccbNode:labelTTFForName("m_flag_label")
            local ready_sprite = ccbNode:spriteForName("ready_sprite")
            local door_sprite = ccbNode:spriteForName("door_sprite")
            local m_node = ccbNode:nodeForName("m_node")
            m_node:removeAllChildrenWithCleanup(true);
            m_flag_label:setVisible(false);
            ready_sprite:setVisible(false)
            local itemCfg = maze_mine_cfg_item:getNodeWithKey("stage" .. (index+1))
            if itemCfg then
                local buildingId = itemCfg:toStr();
                if game_util:valueInTeam(buildingId,builded) then
                    -- m_flag_label:setVisible(true);
                    ready_sprite:setVisible(true)
                end
                local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(buildingId);
                if maze_stage_cfg_item then
                    local name = maze_stage_cfg_item:getNodeWithKey("name"):toStr();
                    m_name_label:setString(name);
                    local tempIcon = game_util:createIconByName(maze_stage_cfg_item:getNodeWithKey("icon"):toStr());
                    if tempIcon then
                        tempIcon:setScale(0.75);
                        m_node:addChild(tempIcon)
                    end
                end
            end
            if index == 0 then
                door_sprite:setVisible(true)
            else
                door_sprite:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            self:tableViewOnClick(index,maze_mine_cfg_item,builded)
        end
    end
    return TableViewHelper:create(params);
end

function open_door_cloister_detail.tableViewOnClick(self,index,maze_mine_cfg_item,builded)
    local itemCfg = maze_mine_cfg_item:getNodeWithKey("stage" .. (index+1))
    if itemCfg then
        local buildingId = itemCfg:toStr();
        if game_util:valueInTeam(buildingId,builded) then
            return true;
        end
        local maze_stage_cfg = getConfig(game_config_field.maze_stage)
        local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(itemCfg:toStr());
        if maze_stage_cfg_item then
            local sort = maze_stage_cfg_item:getNodeWithKey("sort"):toInt();
            local function callBackFunc(params)
                params = params or {}
                if params.gameData then
                    self.m_tGameData = params.gameData;
                end
                self:refreshUi();
            end
            if sort == 1 or sort == 2 then--有战斗需要请求后端数据
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local log_list = nil
                    if data:getNodeWithKey("log_list") then
                        log_list = json.decode(data:getNodeWithKey("log_list"):getFormatBuffer())
                    end
                    game_data:setDataByKeyAndValue("map_fight_and_enemy",json.decode(data:getFormatBuffer()));
                    game_scene:addPop("open_door_cloister_detail_pop",{gameData = self.m_tGameData,stageId = itemCfg:toStr(),callBackFunc = callBackFunc,sort = sort,log_list = log_list})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_map_fight_and_enemy"), http_request_method.GET, {stage_id = maze_stage_cfg_item:getKey()},"maze_map_fight_and_enemy")
            else
                local shop = maze_stage_cfg_item:getNodeWithKey("shop")
                local tempCount = shop:getNodeCount();
                if tempCount > 0 then
                    game_scene:addPop("open_door_cloister_detail_pop",{gameData = self.m_tGameData,stageId = itemCfg:toStr(),callBackFunc = callBackFunc})
                else--直接获得
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data");
                        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                        game_util:createMazeRewardTips(itemCfg:toStr());
                        self:refreshUi();
                    end
                    local params = {stage_id = maze_stage_cfg_item:getKey()}
                    -- if tempCount == 1 then
                    --     params.pos = 0;
                    -- end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_open_shop"), http_request_method.GET,params ,"maze_open_shop")
                end
            end
        end
    end
end

--[[--
    刷新
]]
function open_door_cloister_detail.refreshTableView(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createTableView(self.m_list_view_node:getContentSize());
    tableView:setScrollBarVisible(false);
    tableView:setMoveFlag(false);
    self.m_list_view_node:addChild(tableView,10,10);
end

--[[--
    创建列表
]]
function open_door_cloister_detail.createItemTableView(self,viewSize)
    local maze_item_cfg = getConfig(game_config_field.maze_item)
    local maze = self.m_tGameData.maze or {}
    local items = maze.items or {}
    local showData = {}
    for k,v in pairs(items) do
        table.insert(showData,k)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
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
            local tempId = showData[index+1];
            local itemCfg = maze_item_cfg:getNodeWithKey(tostring(tempId))
            local count = items[tempId]
            local tempIcon = game_util:createMazeItemIconByCfg(itemCfg);
            if tempIcon then
                tempIcon:setScale(0.75);
                tempIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(tempIcon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local tempId = showData[index+1];
            local count = items[tempId]
            local function callBackFunc(params)
                params = params or {}
                if params.gameData then
                    self.m_tGameData = params.gameData;
                end
                self:refreshUi();
            end
            game_scene:addPop("game_maze_item_pop",{itemData = {id = tempId,count = count},itemType = 1,callBackFunc = callBackFunc})
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function open_door_cloister_detail.refreshItemTableView(self)
    self.m_item_list_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createItemTableView(self.m_item_list_node:getContentSize());
    tableView:setScrollBarVisible(false);
    self.m_item_list_node:addChild(tableView,10,10);
end

--[[--
    创建列表
]]
function open_door_cloister_detail.createBlessingTableView(self,viewSize)
    local maze_buff_cfg = getConfig(game_config_field.maze_buff)
    local maze = self.m_tGameData.maze or {}
    local buffs = maze.buffs or {}
    local showData = {}
    for k,v in pairs(buffs) do
        table.insert(showData,k)
    end
    local function sortfunction(data1,data2)
        -- return tonumber(data1) < tonumber(data2)
        local itemCfg1 = maze_buff_cfg:getNodeWithKey(data1)
        local itemCfg2 = maze_buff_cfg:getNodeWithKey(data2)
        local time_sort1 = itemCfg1:getNodeWithKey("time_sort"):toInt()
        local time_sort2 = itemCfg2:getNodeWithKey("time_sort"):toInt()
        time_sort1 = time_sort1 == 1 and 100 or time_sort1
        time_sort2 = time_sort2 == 1 and 100 or time_sort2
        return time_sort1 < time_sort2
    end
    table.sort(showData,sortfunction)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local maze_buff_cfg_item = maze_buff_cfg:getNodeWithKey(tostring(showData[index+1]))
            if maze_buff_cfg_item then
                local tempIcon = game_util:createIconByName(maze_buff_cfg_item:getNodeWithKey("icon"):toStr());
                if tempIcon then
                    tempIcon:setScale(0.75);
                    tempIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                    cell:addChild(tempIcon)
                end
                local rate = maze_buff_cfg_item:getNodeWithKey("rate"):toInt();
                local value = maze_buff_cfg_item:getNodeWithKey("value"):toStr();
                local tempStr = ""
                if rate == 1 then
                    tempStr = value;
                else
                    tempStr = value .. "%";
                end
                local tempLabel = game_util:createLabelTTF({text = tempStr,color = ccc3(255,255,255),fontSize = 10});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local tempId = showData[index+1]
            game_scene:addPop("game_maze_item_pop",{itemData = {id = tempId},itemType = 2})
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function open_door_cloister_detail.refreshBlessingTableView(self)
    self.m_blessing_list_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createBlessingTableView(self.m_blessing_list_node:getContentSize());
    -- tableView:setScrollBarVisible(false);
    self.m_blessing_list_node:addChild(tableView,10,10);
end

--[[--
    刷新ui
]]
function open_door_cloister_detail.refreshUi(self)
    self:refreshTableView();
    self:refreshItemTableView();
    self:refreshBlessingTableView();
    local maze = self.m_tGameData.maze or {}
    local layer = maze.layer or 1
    self.m_record_label:setString(tostring(layer))

    local score = maze.score or 0;
    self.m_score_label:setString(tostring(score))
    local total_hp_rate = maze.total_hp_rate or 0
    self.m_progress_bar:setCurValue(math.min(math.max(0,total_hp_rate),100),true);
    self.m_life_percent_label:setString(tostring(total_hp_rate) .. "%")

    if total_hp_rate > 50 then
        self.life_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xjhl_shengming3.png"));
    elseif total_hp_rate > 0 and total_hp_rate <= 50 then
        self.life_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xjhl_shengming2.png"));
    else
        self.life_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xjhl_shengming1.png"));
    end
end

--[[--
    初始化
]]
function open_door_cloister_detail.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        else
            self.m_tGameData = t_params.gameData;
        end
    else
        self.m_tGameData = {};
    end
    self.rewardFlag = t_params.rewardFlag or false
    cclog2(self.rewardFlag,"self.rewardFlag")
    self.isNext = t_params.isNext or false
    self.lastScore = t_params.lastScore
    self.enterFlag = t_params.enterFlag
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_cloister_detail.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local sel_maze_stage_id = game_data:getDataByKey("sel_maze_stage_id")
    if sel_maze_stage_id then
        if self.rewardFlag then
            game_util:createMazeRewardTips(sel_maze_stage_id);
            game_data:setDataByKeyAndValue("sel_maze_stage_id",nil);
        end
    end
    return scene;
end

return open_door_cloister_detail;