--- 金字塔悬赏任务

local ui_pyramid_offerreward_pop = {
    m_node_task_board = nil,
    m_label_challangetimes = nil,
    m_label_refresh_cost = nil,

    m_label_free = nil,
    m_sprite_cost = nil,
    m_refresh_cost = nil,
    m_max_challanges = nil,
    m_taskList = nil,
    m_gameData = nil,
};

--[[--
    销毁ui
]]
function ui_pyramid_offerreward_pop.destroy(self)
    -- body
    cclog("-----------------ui_pyramid_offerreward_pop destroy-----------------");
    self.m_node_task_board = nil;
    self.m_label_challangetimes = nil;
    self.m_label_refresh_cost = nil;

    self.m_label_free = nil;
    self.m_sprite_cost = nil;
    self.m_refresh_cost = nil;
    self.m_max_challanges = nil;
    self.m_taskList = nil;
    self.m_gameData = nil;
end
--[[--
    返回
]]
function ui_pyramid_offerreward_pop.back(self,backType)
    game_scene:removePopByName("ui_pyramid_offerreward_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_pyramid_offerreward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "cleck btn tag == ")
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then

            local callRefreshFun = function (  )
                local function responseMethod(tag,gameData)
                    self:refreshData(gameData)
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("refresh_pyramid_wanted"), http_request_method.GET, params,"refresh_pyramid_wanted")
            end
            local msg = string_helper.ui_pyramid_offerreward_pop.refreshWanted
            if self.m_gameData.free_refresh_time ~= 0 then
                msg = string.format(string_helper.ui_pyramid_offerreward_pop.costRefresh,tostring(self.m_refresh_cost))
            end
            if game_util:getTableLen(self.m_gameData.wanted_done) > 0 then

                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        callRefreshFun()
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = string_helper.ui_pyramid_offerreward_pop.tips .. tostring(msg),      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                }
                game_util:openAlertView(t_params)

            elseif self.m_gameData.free_refresh_time == 0 then
                callRefreshFun()
            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        callRefreshFun()
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text =  tostring(msg),      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-12,
                }
                game_util:openAlertView(t_params)
            end





        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_offerreward_pop.ccbi");

    self.m_node_task_board = ccbNode:nodeForName("m_node_task_board")
    self.m_label_challangetimes = ccbNode:labelTTFForName("m_label_challangetimes")
    self.m_label_refresh_cost = ccbNode:labelTTFForName("m_label_refresh_cost")
    self.m_label_free = ccbNode:labelTTFForName("m_label_free")
    self.m_sprite_cost = ccbNode:spriteForName("m_sprite_cost")
    local  title101 = ccbNode:labelTTFForName("title101");
    title101:setString(string_helper.ccb.title101);


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);

    local tableViewTouchLayer = CCLayer:create()
    m_root_layer:addChild(tableViewTouchLayer)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_node_task_board:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_task_board:boundingBox():containsPoint(realPos) then
                return false
            else
                return true
            end
        end
    end
    tableViewTouchLayer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 12,true);
    tableViewTouchLayer:setTouchEnabled(true);


    -- 关闭按钮
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close");
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    -- 刷新按钮
    local m_conbtn_refresh = ccbNode:controlButtonForName("m_conbtn_refresh");
    m_conbtn_refresh:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);

    return ccbNode;
end


--[[--
    金字塔悬赏任务列表
]]
function ui_pyramid_offerreward_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_chouren_res.plist");
    local showData = self.m_taskList or {}
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();

        local index = 0
        local canReward = false
        if btnTag >= 10000 and btnTag < 20000 then
            index = btnTag - 10000
            canReward = true
        elseif btnTag >= 20000 then
            index = btnTag - 20000
        else
            return 
        end
        local itemCfg = showData[index + 1]
        if canReward == true then
            local taskIndex = itemCfg and itemCfg:getKey()
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self:refreshData(gameData)
                self:refreshUi()
            end
            local params = {}
            params.wanted_id = taskIndex
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("get_wanted_reward"), http_request_method.GET, params,"get_wanted_reward")
        elseif itemCfg then
            local sort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
            local target_date = itemCfg:getNodeWithKey("target_date") and itemCfg:getNodeWithKey("target_date"):toInt() or 0
            local target_data1 = itemCfg:getNodeWithKey("target_data1") and itemCfg:getNodeWithKey("target_data1"):toInt() or 0
            local showLevelInfo = nil
            local floor = nil
            if sort == 1 then
                showLevelInfo = {floor = target_date, pos = target_data1}
                floor = target_date
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_pyramid_tower_scene", {gameData = gameData, showLevelInfo = showLevelInfo })
            end
            local params = {}
            params.floor = floor
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, params,"pyramid_go_fight")
        end
    end

    local itemCount = #showData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    params.totalItem = itemCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_pyramid_offerreward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));          
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local itemCfg = showData[index + 1]
                local m_node_tasktitle = ccbNode:nodeForName("m_node_tasktitle")   -- 任务信息
                local m_label_progress_value = ccbNode:labelTTFForName("m_label_progress_value")  -- 任务进度值
                local m_node_progress_barboard = ccbNode:nodeForName("m_node_progress_barboard")  -- 任务进度条
                local m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")    -- 奖励
                local m_btn_dosth = ccbNode:controlButtonForName("m_btn_dosth")  -- 按钮
                game_util:setCCControlButtonTitle(m_btn_dosth,string_helper.ccb.title102)
                m_btn_dosth:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)

                -- 奖励信息
                local reward_cfg = itemCfg:getNodeWithKey("reward")
                m_node_rewardboard:removeAllChildrenWithCleanup(true)
                self:createHoroRewardTableView(m_node_rewardboard, reward_cfg)

                -- 奖励标题
                m_node_tasktitle:removeAllChildrenWithCleanup(true)
                local story = itemCfg:getNodeWithKey("story") and itemCfg:getNodeWithKey("story"):toStr() or ""
                local target_date = itemCfg:getNodeWithKey("target_date") and itemCfg:getNodeWithKey("target_date"):toInt() or 0
                local target_data1 = itemCfg:getNodeWithKey("target_data1") and itemCfg:getNodeWithKey("target_data1"):toInt() or 0
                story = string.gsub( story, "X", target_date, 1)
                story = string.gsub( story, "X", target_data1, 1)
                local titleMsgRLabel = game_util:createRichLabelTTF({text = story,textAlignment = kCCTextAlignmentCenter,color = ccc3(121, 236, 236)})
                titleMsgRLabel:setAnchorPoint(ccp(0.5, 0.5))
                m_node_tasktitle:addChild(titleMsgRLabel)
                local board_size = m_node_tasktitle:getContentSize()
                titleMsgRLabel:setPosition( ccp(board_size.width * .5, board_size.height * .5) )

                -- 进度计算
                local maxValue = 1
                local curValue = 0
                local progressMsg = ""
                local sort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
                if sort == 1 then
                    maxValue = 1
                elseif sort == 2 then
                    maxValue = target_date
                    curValue = self.m_gameData.wanted_attack_times or 0
                elseif sort == 3 then
                    maxValue = target_date
                    curValue = self.m_gameData.hold_time or 0
                else
                    maxValue = 1
                end

                if game_util:valueInTeam(sort , self.m_gameData.wanted_done) then
                -- if game_util:valueInTeam(itemCfg:getKey() , self.m_gameData.wanted_done) then
                    curValue = maxValue
                end

                -- 进度值
                m_node_progress_barboard:removeAllChildrenWithCleanup(true)
                local barBoardSize = m_node_progress_barboard:getContentSize()
                local bar = ExtProgressTime:createWithFrameName("pb_alpha0_1X1.png", "ui_chouren_valuebar.png")
                bar:setPosition(ccp(barBoardSize.width * 0.5, barBoardSize.height * 0.5))
                bar:setAnchorPoint(ccp(0.5, 0.5))
                m_node_progress_barboard:addChild(bar)
                bar:setMaxValue(maxValue)
                -- bar:setCurValue(curHatred, false)
                bar:setCurValue(curValue, false)
                -- 进度值
                m_label_progress_value:setString(tostring(curValue) .. "/" .. tostring(maxValue))

                -- 完成情况
                if game_util:valueInTeam(sort , self.m_gameData.wanted_done) then
                -- if game_util:valueInTeam(itemCfg:getKey() , self.m_gameData.wanted_done) then
                    game_util:setCCControlButtonBackground(m_btn_dosth, "ui_pyramid_reward_lingjiang.png")
                    m_btn_dosth:setTag(index + 10000)
                else
                    game_util:setCCControlButtonBackground(m_btn_dosth, "ui_pyramid_reward_qianwang.png")
                    m_btn_dosth:setTag(index + 20000)
                end


                local maxTimes = self.m_gameData.max_challenge_times or 5
                local curUseTimes = self.m_gameData.wanted_challenge_times or 5
                if curUseTimes >= maxTimes and m_btn_dosth then
                    m_btn_dosth:setVisible(false)
                end
            end
        end
        cell:setTag(1001 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    -- local tableView = 
    return TableViewHelper:create(params);
end


--[[
    创建横奖励列表
]]
function ui_pyramid_offerreward_pop.createHoroRewardTableView( self, viewBoard, rewardList )
    if not rewardList then return end
    local viewSize = viewBoard:getContentSize()
    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.15)
    leftArrow:setPosition(ccp(-5,viewSize.height*0.5));
    viewBoard:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.15)
    rightArrow:setPosition(ccp(viewSize.width + 5,viewSize.height*0.5));
    viewBoard:addChild(rightArrow)

    leftArrow:setVisible(false)
    rightArrow:setVisible(false)

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
    local tempCount = rewardList:getNodeCount()
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3; --列
    if tempCount < 2 then params.column = 1 end
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    params.showPoint = false
    params.showPageIndex = 1
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
            local itemGift = rewardList:getNodeAt(index)
            local icon,name,count = game_util:getRewardByItem(itemGift)
            if icon then

                local bgnode = icon:getChildByTag(1)
                if bgnode then
                    bgnode:setVisible(false)
                end
                local iconSize = icon:getContentSize()
                local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                if sprBoard then
                    sprBoard:setPosition(iconSize.width * 0.5, iconSize.height * 0.5)
                    icon:addChild(sprBoard, 20, 20)
                end

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
            end
            node:setScale(0.8)
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = rewardList:getNodeAt(index)
            if itemData then
                game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        if curPage == 1 then
            leftArrow:setVisible(false)
        else
            leftArrow:setVisible(true)
        end
        if curPage < totalPage then
            rightArrow:setVisible(true)
        else
            rightArrow:setVisible(false)
        end
    end
    local tableView =  TableViewHelper:createGallery2(params);
    if tableView then
        viewBoard:addChild(tableView)
    end
end

--[[
    观看战报
]]
function ui_pyramid_offerreward_pop.goToDoTask( self, battleKey )
    if not battleKey then return end
    local function responseMethod(tag,gameData)
        game_data:setBattleType( self.m_enterType );
        if gameData then
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            self:destroy();
        end
    end
    local tempkey = battleKey;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_battle_replay"), http_request_method.GET, {key = tempkey},"pyramid_battle_replay");
end


--[[--
    刷新ui
]]
function ui_pyramid_offerreward_pop.refreshUi(self)
    -- 任务列表
    self.m_node_task_board:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_node_task_board:getContentSize());
    self.m_node_task_board:addChild(tableViewTemp);

    --  其他信息： 刷新花费
    if self.m_gameData.free_refresh_time == 0 then  -- 免费刷新一次   
        self.m_label_refresh_cost:setString("")
        self.m_label_free:setString(string_helper.ui_pyramid_offerreward_pop.freeOne)
        self.m_sprite_cost:setVisible(false)
    else
        self.m_label_refresh_cost:setString(tostring(self.m_refresh_cost))
        self.m_label_free:setString("")
        self.m_sprite_cost:setVisible(true)
    end

    -- 挑战次数
    local maxTimes = self.m_gameData.max_challenge_times or 5
    local curUseTimes = self.m_gameData.wanted_challenge_times or 5
    if self.m_label_challangetimes then
        self.m_label_challangetimes:setString(   tostring( math.max(maxTimes - curUseTimes, 0)) .. "/" .. tostring(maxTimes))
    end

end

--[[
    格式化数据
]]
function ui_pyramid_offerreward_pop.formatData( self )
    local wanted_data = self.m_gameData.wanted_data or {}
    local pyramid_wanted_cfg = getConfig(game_config_field.pyramid_wanted)
    self.m_taskList = {}
    for k,v in pairs(wanted_data) do
        local itemCfg = pyramid_wanted_cfg and pyramid_wanted_cfg:getNodeWithKey(tostring(v))
        -- cclog2(itemCfg, "offer a reward " .. k .. " ==========  ")
        if itemCfg then
            table.insert(self.m_taskList, itemCfg)
        end
    end

    local sortFun = function ( data1, data2 )
        return tonumber(data1:getKey()) < tonumber(data2:getKey())
    end
    table.sort(self.m_taskList, sortFun)
    -- 更新花费
    self.m_refresh_cost = 20
    self.m_max_challanges = 5
    if pyramid_wanted_cfg and pyramid_wanted_cfg:getNodeCount() > 0 then
        local item = pyramid_wanted_cfg:getNodeAt(0)
        if item then
            self.m_refresh_cost = item:getNodeWithKey("refresh") and item:getNodeWithKey("refresh"):toInt() or 20
        end
    end
    -- 挑战次数

end

function ui_pyramid_offerreward_pop.refreshData( self, gameData )
    local tempData = {}
    if gameData then
        local data = gameData and gameData:getNodeWithKey("data")
        tempData = data and json.decode(data:getFormatBuffer()) or {}
    end

    for k,v in pairs(tempData) do
        if self.m_gameData[k] then
            self.m_gameData[k] = v
        end
    end
    self:formatData()
end


--[[--
    初始化
]]
function ui_pyramid_offerreward_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self:formatData()
end

--[[--
    创建ui入口并初始化数据
]]
function ui_pyramid_offerreward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_pyramid_offerreward_pop;