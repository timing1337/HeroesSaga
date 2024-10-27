---  每日悬赏
local game_daily_wanted = {
    reward_table_node = nil,
    select_table_node = nil,
    left_times_label = nil,
    free_times_label = nil,
    btn_give_up = nil,
    bar_node = nil,
    cost_label = nil,
    m_tGameData = nil,
    daily_id = nil,
    btn_refresh = nil,

    onGoing = nil,
    going_id = nil,
    goQuickEntryType = nil,

    story_message = nil,
    m_selectTaskData = nil,

    m_come_scene = nil,
};
--[[--
    销毁
]]
function game_daily_wanted.destroy(self)
    -- body
    cclog("-----------------game_daily_wanted destroy-----------------");
    self.reward_table_node = nil;
    self.select_table_node = nil;
    self.left_times_label = nil;
    self.free_times_label = nil;
    self.btn_give_up = nil;
    self.bar_node = nil;
    self.cost_label = nil;
    self.m_tGameData = nil;
    self.daily_id = nil;
    self.btn_refresh = nil;
    self.onGoing = nil;
    self.going_id = nil;
    
    self.goQuickEntryType = nil;
    self.story_message = nil;
    self.m_selectTaskData = nil;
end
--[[--
    返回
]]
function game_daily_wanted.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    -- game_scene:removePopByName("game_daily_wanted");
end
--[[--
    读取ccbi创建ui
]]
function game_daily_wanted.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 200 then--刷新
            local function responseMethod(tag,gameData)
                cclog("refresh_daily_task data = " .. gameData:getNodeWithKey("data"):getFormatBuffer());
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self.m_tGameData = temp.daily
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("refresh_daily_task"), http_request_method.GET, nil,"refresh_daily_task");  
        elseif btnTag == 100 then--放弃
            local function responseMethod(tag,gameData)
                cclog("inactivate_daily_task data = " .. gameData:getNodeWithKey("data"):getFormatBuffer());
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self.m_tGameData = temp.daily
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("inactivate_daily_task"), http_request_method.GET, {award_id = tostring(self.going_id)},"inactivate_daily_task");
        elseif btnTag == 3 then--切换tab
            function responseMethod(tag,gameData)
                game_scene:removePopByName("game_daily_wanted");
                game_scene:addPop("game_daily_task_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_diary_index"), http_request_method.GET, {},"reward_diary_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_daily_wanted.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.reward_table_node = ccbNode:nodeForName("reward_table_node")
    self.select_table_node = ccbNode:nodeForName("select_table_node")
    self.left_times_label = ccbNode:labelTTFForName("left_times_label")
    self.free_times_label = ccbNode:labelTTFForName("free_times_label")
    self.btn_give_up = ccbNode:controlButtonForName("btn_give_up")
    self.bar_node = ccbNode:nodeForName("bar_node")
    self.cost_label = ccbNode:labelTTFForName("cost_label")
    self.btn_refresh = ccbNode:controlButtonForName("btn_refresh")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    local m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    local m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3")

    game_util:setCCControlButtonTitle(m_tab_btn_2,string_helper.ccb.text117)
    game_util:setCCControlButtonTitle(m_tab_btn_3,string_helper.ccb.text118)

    m_tab_btn_3:setEnabled(false)

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.btn_give_up:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.btn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    --game_util:setControlButtonTitleBMFont(self.btn_give_up)
    game_util:setCCControlButtonTitle(self.btn_give_up,string_helper.ccb.file49);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text121)
    return ccbNode;
end
--[[--
    创建奖励列表
]]
function game_daily_wanted.createRewardTableView(self,viewSize)
    local scoreCfg = getConfig(game_config_field.dailyscore)
    local openTable = {}
    -- local tempTable = {5,10,15,25}
    local tempTable = {}
    for i=1,scoreCfg:getNodeCount() do
        local itemCfg = scoreCfg:getNodeAt(i-1)
        local itemKey = itemCfg:getKey()
        -- table.insert(tempTable2,itemKey)
        tempTable[i] = itemKey
    end
    local function sort(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(tempTable,sort)
    local dailyscore_done = self.m_tGameData.dailyscore_done
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag > 200 and btnTag < 210 then
            local index = btnTag - 200

            local function responseMethod(tag,gameData)
                cclog("daily_score_award data = " .. gameData:getNodeWithKey("data"):getFormatBuffer());
                game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                -- if gameData ~= nil and tolua.type(gameData) == "util_json" then
                --     local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                --     self.m_tGameData = temp.daily
                -- end
                local dailyscore_done = gameData:getNodeWithKey("data"):getNodeWithKey("dailyscore_done")
                self.m_tGameData.dailyscore_done = json.decode(dailyscore_done:getFormatBuffer())
                self:refreshUi()
            end
            local score = tempTable[index]
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_score_award"), http_request_method.GET, {score=tostring(score)},"daily_score_award");  
        elseif btnTag > 300 and btnTag < 310 then
            local index = btnTag - 301
            local div = math.floor(index / 2)
            local rem = math.floor(index % 2)
            local itemCfg = scoreCfg:getNodeWithKey(tostring(tempTable[div+1]))
            local mylevel = game_data:getUserStatusDataByKey("level") or 0
            local level1 = itemCfg:getNodeWithKey("level")
            local level2 = itemCfg:getNodeWithKey("level2")
            local level1Down = 0
            local level1Up = 100
            local level2Down = 0
            local level2Up = 100
            if level1 and level2 then
                level1Down = level1:getNodeAt(0):toInt()
                level1Up = level1:getNodeAt(1):toInt()
                level2Down = level2:getNodeAt(0):toInt()
                level2Up = level2:getNodeAt(1):toInt()
            end
            local itemTable = {}
            if level1Down <= mylevel and mylevel <= level1Up then
                itemTable = json.decode(itemCfg:getNodeWithKey("reward"):getNodeAt(rem):getFormatBuffer())
            elseif mylevel >= level2Down and mylevel <= level2Up then
                itemTable = json.decode(itemCfg:getNodeWithKey("reward2"):getNodeAt(rem):getFormatBuffer())
            end
            game_util:lookItemDetal(itemTable)
        end
    end
    for i=1,4 do
        local key_value = tonumber(tempTable[i])
        if self.m_tGameData.dailyscore >= key_value then
            openTable[i] = true
        else
            openTable[i] = false
        end
    end
    local mylevel = game_data:getUserStatusDataByKey("level") or 0
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = 4;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_daily_reward.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false)
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:setScale(0.8)
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("btn_get"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            ccbNode:controlButtonForName("look_btn_1"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            ccbNode:controlButtonForName("look_btn_2"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local btn_get = ccbNode:controlButtonForName("btn_get")
            local need_value = ccbNode:labelBMFontForName("need_value")
            local alpha_split = ccbNode:scale9SpriteForName("alpha_split")

            local lookBtn_1 = ccbNode:controlButtonForName("look_btn_1")
            local lookBtn_2 = ccbNode:controlButtonForName("look_btn_2")
            lookBtn_1:setOpacity(0)
            lookBtn_2:setOpacity(0)
            lookBtn_1:setTag(301 + index*2)
            lookBtn_2:setTag(302 + index*2)
            btn_get:setTag(201 + index)
            if index == 3 then
                alpha_split:setVisible(false)
            end
            need_value:setString(tempTable[index+1] .. string_helper.game_daily_wanted.score)
            need_value:setVisible(not openTable[index+1])
            btn_get:setVisible(openTable[index+1])

            if openTable[index+1] then
                game_util:createPulseAnmi("offer_get.png",btn_get);
            else
                btn_get:removeAllChildrenWithCleanup(true)
                btn_get:stopAllActions()
            end

            local itemCfg2 = scoreCfg:getNodeWithKey(tostring(tempTable[index+1]))
            local level1 = itemCfg2:getNodeWithKey("level")
            local level2 = itemCfg2:getNodeWithKey("level2")
            local level1Down = 0
            local level1Up = 100
            local level2Down = 0
            local level2Up = 100
            if level1 and level2 then
                level1Down = level1:getNodeAt(0):toInt()
                level1Up = level1:getNodeAt(1):toInt()
                level2Down = level2:getNodeAt(0):toInt()
                level2Up = level2:getNodeAt(1):toInt()
            end
            local reward = nil
            if level1Down <= mylevel and mylevel <= level1Up then
                reward = itemCfg2:getNodeWithKey("reward")
            elseif mylevel >= level2Down and mylevel <= level2Up then
                reward = itemCfg2:getNodeWithKey("reward2")
            end
            cclog2(reward)
            for i=1,2 do
                local sprite_icon = ccbNode:spriteForName("sprite_icon_" .. i)
                local count_label = ccbNode:labelBMFontForName("count_label_" .. i)
                local itemData = reward:getNodeAt(i-1)
                local icon,name,count = game_util:getRewardByItem(itemData,true);
                if icon then
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    icon:setScale(0.8)
                    sprite_icon:removeAllChildrenWithCleanup(true);
                    sprite_icon:addChild(icon)
                end
                if count then
                    count_label:setString("×"..count)
                end
            end
            if dailyscore_done then
                for i=1,#dailyscore_done do
                    if tostring(dailyscore_done[i]) == tostring(tempTable[index+1]) then
                        btn_get:removeAllChildrenWithCleanup(true)
                        btn_get:stopAllActions()
                        btn_get:setEnabled(false)
                        btn_get:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_get_reward.png"),CCControlStateDisabled)
                    end
                end
            end
        end
        cell:setTag(201 + index)
        return cell;
    end
    return TableViewHelper:create(params);
end
--[[--
    创建选择任务列表
]]
function game_daily_wanted.createSelectTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        cclog("btnTag1 = " .. btnTag)
        local index = btnTag - 100
        local result = self.m_tGameData.result[index]
        local id = result.id
        if self.onGoing == true then
            local status = result.status
            if status == 1 then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    cclog("select data = " .. data:getFormatBuffer())

                    game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        self.m_tGameData = temp.daily
                    end
                    self:refreshUi()
                end
                local params = {};
                params.award_id = tostring(self.going_id);
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_daily_award"), http_request_method.GET, params,"reward_daily_award")
            else
                
                print({"goQuickEntryType == ", self.goQuickEntryType})

                if self.goQuickEntryType then
                    self:quickEnter(self.goQuickEntryType)
                    self.goQuickEntryType = nil;
                end

            end
        else
            local function responseMethod(tag,gameData)
                cclog("activate_daily_task data = " .. gameData:getNodeWithKey("data"):getFormatBuffer());
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self.m_tGameData = temp.daily
                end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("activate_daily_task"), http_request_method.GET, {award_id=tostring(id)},"activate_daily_task");  
        end
    end
    local dailyCfg = getConfig(game_config_field.reward_daily)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = self.m_tGameData.length;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_daily_wanted_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:ignoreAnchorPointForPosition(false)
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("btn_accepted"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local job_name_label = ccbNode:labelTTFForName("job_name_label")
            local content_label = ccbNode:labelTTFForName("content_label")
            local reward_point_label = ccbNode:labelBMFontForName("reward_point_label")
            local progress_label = ccbNode:labelBMFontForName("progress_label")
            local btn_accepted = ccbNode:controlButtonForName("btn_accepted")
            -- game_util:setControlButtonTitleBMFont(btn_get)
            local sprite_1 = ccbNode:spriteForName("sprite_icon_1")
            local select_alpha = ccbNode:scale9SpriteForName("select_alpha")

            btn_accepted:setTag(101 + index)
            game_util:setCCControlButtonTitle(btn_accepted,string_helper.ccb.text122)

            local daily_id = self.m_tGameData.result[index+1].id 
            local itemCfg = dailyCfg:getNodeWithKey(tostring(daily_id))
            local target_name = itemCfg:getNodeWithKey("name"):toStr()
            local target_story = itemCfg:getNodeWithKey("story"):toStr()
            local target_data = itemCfg:getNodeWithKey("target_data"):getNodeAt(0):toInt()
            target_story = string.gsub(target_story,"num",tostring(target_data));
            local icon_name = itemCfg:getNodeWithKey("icon"):toStr()
            local reward_score = itemCfg:getNodeWithKey("reward_score"):toInt()

            local qtype = itemCfg:getNodeWithKey("target_sort"):toInt()  -- targe_sort 标志任务的种类
            -- print("target_story  == target_story ", target_story)

            job_name_label:setString(target_name)
            content_label:setString(target_story)
            local tempIcon = game_util:createIconByName(icon_name)
            if tempIcon then
                sprite_1:setDisplayFrame(tempIcon:displayFrame())
            end
            
            if self.onGoing == true then
                local result = self.m_tGameData.result[index+1]
                local avaible = result.avaible
                if avaible == 1 then
                    select_alpha:setVisible(false)
                    reward_point_label:setString("")
                    --正在进行中
                    -- local progress_bar = ExtProgressBar:createWithFrameName("o_public_skillExpBg.png","o_public_skillExp.png",CCSizeMake(50,10));
                    -- progress_bar:setAnchorPoint(ccp(0.5,0.5))
                    -- progress_bar:setPosition(ccp(20,0))
                    -- progress_bar:setMaxValue(result.need_value);
                    -- progress_bar:setCurValue(result.value,false);
                    -- reward_point_label:addChild(progress_bar,10)
                    progress_label:setString(result.value.."/"..result.need_value)
                    local status = result.status--判断是否可以领奖
                    btn_accepted:setEnabled(true)
                    if status == 1 then
                        btn_accepted:setEnabled(true)
                        title = CCString:create(tostring(string_helper.game_daily_wanted.getReward));
                        btn_accepted:setTitleForState(title,CCControlStateNormal)

                    else
                        -- btn_accepted:setEnabled(false)
                        --以后再做前往 现在只能领奖和接受
                        title = CCString:create(tostring(string_helper.game_daily_wanted.go));
                        btn_accepted:setTitleForState(title,CCControlStateNormal)
                    end

                    self.story_message = target_story
                    self.m_selectTaskData = json.decode(itemCfg and itemCfg:getFormatBuffer()) or nil
                    self.goQuickEntryType = qtype
                else
                    progress_label:setString("")
                    reward_point_label:setString(reward_score..string_helper.game_daily_wanted.score)
                    select_alpha:setVisible(true)
                    btn_accepted:setEnabled(false)
                    title = CCString:create(tostring(string_helper.game_daily_wanted.accept));
                    btn_accepted:setTitleForState(title,CCControlStateDisabled)
                end
            else
                progress_label:setString("")
                reward_point_label:setString(reward_score..string_helper.game_daily_wanted.score)
                select_alpha:setVisible(false)
                title = CCString:create(tostring(string_helper.game_daily_wanted.accept));
                btn_accepted:setTitleForState(title,CCControlStateNormal)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)

    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_daily_wanted.refreshUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist");
    local dailyscore = self.m_tGameData.dailyscore
    local bar = ExtProgressBar:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png",CCSizeMake(128,12));
    bar:setMaxValue(25);
    bar:setCurValue(dailyscore,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    self.bar_node:addChild(bar,10)
    local barTTF = CCLabelTTF:create(dailyscore.."/"..25,TYPE_FACE_TABLE.Arial_BoldMT,12);
    barTTF:setAnchorPoint(ccp(0.5,0.5))
    self.bar_node:addChild(barTTF,10)

    self.left_times_label:setString(string_helper.game_daily_wanted.leftTimes..(self.m_tGameData.done_limit - self.m_tGameData.done).."/"..self.m_tGameData.done_limit)
    if self.m_tGameData.free_daily_refresh > 0 then
        self.free_times_label:setString( string_helper.game_daily_wanted .refreshTime.. self.m_tGameData.free_daily_refresh .. string_helper.game_daily_wanted .refreshTime2)
    else
        self.free_times_label:setString(string_helper.game_daily_wanted .refreshCost)
    end
    self.btn_give_up:setVisible(false)
    -- self.cost_label:setVisible(true)
    self.btn_refresh:setVisible(true)
    self.onGoing = false
    for i=1,#self.m_tGameData.result do
        --有为1的则为开启
        local avaible = self.m_tGameData.result[i].avaible
        if avaible == 1 then
            self.btn_give_up:setVisible(true)
            -- self.cost_label:setVisible(false)
            self.btn_refresh:setVisible(false)
            self.onGoing = true
            self.going_id = self.m_tGameData.result[i].id
            cclog("self.going_id == " .. self.going_id)
            break
        end
    end

    local tableViewTemp = self:createRewardTableView(self.reward_table_node:getContentSize());
    tableViewTemp:setMoveFlag(false);
    tableViewTemp:setScrollBarVisible(false);
    self.reward_table_node:removeAllChildrenWithCleanup(true);
    self.reward_table_node:addChild(tableViewTemp);

    local tableViewTemp2 = self:createSelectTableView(self.select_table_node:getContentSize());
    tableViewTemp2:setScrollBarVisible(false);
    tableViewTemp2:setMoveFlag(false);
    self.select_table_node:removeAllChildrenWithCleanup(true);
    self.select_table_node:addChild(tableViewTemp2,10,10)
end

--[[--
    初始化
]]
function game_daily_wanted.init(self,t_params)
    t_params = t_params or {};

    self.m_come_scene = t_params.enter_scene or "task"

    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local temp = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp.daily
    end
    self.daily_id = 1
    cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
end

--[[--
    创建ui入口并初始化数据
]]
function game_daily_wanted.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

--[[--
    前往
]]
function game_daily_wanted.quickEnter(self, qetype)
    
    print("will quick entry qetype is ", qetype)

    if qetype == 23 then  -- 收复  -- 章节
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    
    elseif qetype == 24 then  -- 技能升级
            if not game_button_open:checkButtonOpen(503) then
                return;
            end
            game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil});
            elseif qetype == 28 then  -- 训练
            if not game_button_open:checkButtonOpen(501) then
                return;
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_school_new",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
    elseif qetype == 35 then      -- 装备强化
            if not game_button_open:checkButtonOpen(602) then
                return
            end
            game_scene:enterGameUi("equipment_strengthen",{gameData = nil})
    elseif qetype == 26 then  -- 卡牌进阶
            if not game_button_open:checkButtonOpen(502) then
                return
            end
            game_scene:enterGameUi("skills_inheritance_scene",{gameData = nil})
    elseif qetype == 27 then -- 属性改造
            if not game_button_open:checkButtonOpen(509) then
                return
            end
            game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData})
    elseif  game_util:isEqual(qetype, 57, 58, 59)  then  -- 开宝箱，转到道具
            game_scene:enterGameUi("items_scene",{gameData = nil});
    elseif game_util:isEqual(qetype, 47, 48) then  -- 招募 gacha
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
    elseif game_util:isEqual(qetype, 38, 39) then  -- 去竞技场
            if not game_button_open:checkButtonOpen(602) then
                return
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");-- 竞技场 完成 1-4 花园城市 后开启 第四关强制
     elseif qetype == 68 then
           game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
    elseif game_util:isEqual(qetype, 101, 102, 103, 104, 105, 106) then  -- 前往某个章节

        cclog2(self.m_selectTaskData, "m_selectTaskData === ")
        if not self.m_selectTaskData then return end
        local stage_id = nil
        local temp = nil
        if self.m_selectTaskData.target_sort == 100 then--跳到城市
            stage_id = self.m_selectTaskData.target_data[1]
        else--跳到城市且跳到板块
            temp = self.m_selectTaskData.target_data[1]
            cclog2(temp, "temp  ==  ")
            stage_id = string.sub(temp,1,3)
            cclog2(stage_id, "stage_id  ==  ")
        end

        local map_main_story = getConfig(game_config_field.map_main_story);
        local cityid_cityorderid = getConfig(game_config_field.cityid_cityorderid);

        local city_id = cityid_cityorderid:getNodeWithKey(tostring(stage_id)):toStr()
        cclog2(city_id, "city_id  ====  ")
        local main_story_item = map_main_story:getNodeWithKey(tostring(city_id));
        -- do return end
        -- 跳到城市
        -- local function responseMethod(tag,gameData)
        --     game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
        --     game_scene:enterGameUi("game_small_map_scene",{bgMusic = bgMusic,open_building_id = temp});
        --     self:destroy();
        -- end
        -- local params = {}
        -- params.city = tostring(stage_id);
        -- params.chapter = main_story_item:getNodeWithKey("stage_id"):toInt()
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open")


        -- 跳到章节 选中城市
        local chapter = main_story_item:getNodeWithKey("chapter") and main_story_item:getNodeWithKey("chapter"):toInt() or nil
        local index = main_story_item:getNodeWithKey("stage_id"):toInt()
        if chapter then
            -- print("parse successed ", chapter, index)
            -- 前往地图所在章节
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData, assign_city = index, assign_normal_chapter = chapter});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
        else -- 没能解析出地图位置 前往地图
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
        end
    elseif game_util:isEqual(qetype, 53) then  -- 前往 分解卡片
        game_scene:enterGameUi("game_card_split");
    end
end

return game_daily_wanted;
