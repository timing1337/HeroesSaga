---  虫洞航线
local game_dart_route = {
    m_autoRefreshScheduler = nil,
    m_tickFlag = nil,
    m_auto_time = nil,
    m_route_scroll_view = nil,
    m_transShipTable = nil,
    m_teamUidTab = nil,
    m_list_view_bg = nil,
    m_ship_list_view_node = nil,
    m_list_view_btn = nil,
    m_arrow_sprite = nil,
    m_new_battle_label = nil,
    m_clickFlag = nil,
};
--[[--
    销毁ui
]]
function game_dart_route.destroy(self)
    cclog("----------------- game_dart_route destroy-----------------"); 
    if self.m_autoRefreshScheduler ~= nil then
        scheduler.unschedule(self.m_autoRefreshScheduler)
        self.m_autoRefreshScheduler = nil;
    end
    self.m_tickFlag = nil;
    self.m_auto_time = nil;
    self.m_route_scroll_view = nil;
    self.m_transShipTable = nil;
    self.m_teamUidTab = nil;
    self.m_list_view_bg = nil;
    self.m_ship_list_view_node = nil;
    self.m_list_view_btn = nil;
    self.m_arrow_sprite = nil;
    self.m_new_battle_label = nil;
    self.m_clickFlag = nil;
end
--[[--
    返回
]]
function game_dart_route.back(self)
    self.m_tickFlag = false
    local function responseMethod(tag,gameData)
        self.m_tickFlag = true;
        if gameData == nil then return end
        game_scene:enterGameUi("game_dart_main",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index",true,true)
end
--[[--
    读取ccbi创建ui
]]
function game_dart_route.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--战斗记录
            self.m_tickFlag = false
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:addPop("game_dart_log",{gameData = gameData,logType = "battle_log"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_battle_message"), http_request_method.GET, nil,"escort_battle_message",true,true)
        elseif btnTag == 3 then--情报
            self.m_tickFlag = false
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:addPop("game_dart_log",{gameData = gameData,logType = "msg_log"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_world_message"), http_request_method.GET, nil,"escort_world_message",true,true)
        elseif btnTag == 4 then--航线
            self.m_tickFlag = false
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:enterGameUi("game_dart_galaxy",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_open_map"), http_request_method.GET, nil,"escort_open_map",true,true)
        elseif btnTag == 5 then--货船列表
            local visible = self.m_ship_list_view_node:isVisible();
            self.m_list_view_bg:setVisible(not visible);
            self.m_ship_list_view_node:setVisible(not visible);
            if not visible then
                self.m_list_view_bg:setScaleY(0)
                self.m_list_view_bg:runAction(CCScaleTo:create(0.2,1,1))
                self.m_ship_list_view_node:setScaleY(0)
                self.m_ship_list_view_node:runAction(CCScaleTo:create(0.2,1,1))
            end
            self.m_arrow_sprite:setFlipY(not visible)
        elseif btnTag == 100 then--到达
            self:goodsArrive()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_route.ccbi");

    self.route_node = ccbNode:nodeForName("route_node")
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.tips_label2 = ccbNode:labelTTFForName("tips_label2")
    self.btn_arrive = ccbNode:controlButtonForName("btn_arrive")
    self.m_route_scroll_view = ccbNode:scrollViewForName("m_route_scroll_view")
    self.m_route_scroll_view:setTouchEnabled(false)
    self.m_route_scroll_view:setRotation(10)

    self.m_new_battle_label = ccbNode:labelBMFontForName("m_new_battle_label")
    self.m_list_view_bg = ccbNode:scale9SpriteForName("m_list_view_bg")
    self.m_ship_list_view_node = ccbNode:nodeForName("m_ship_list_view_node")
    self.m_list_view_btn = ccbNode:controlButtonForName("m_list_view_btn")
    self.m_arrow_sprite = ccbNode:spriteForName("m_arrow_sprite")
    self.m_list_view_btn:setOpacity(0)
    self.m_list_view_bg:setVisible(false);
    self.m_ship_list_view_node:setVisible(false);
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_clickFlag = true;
            local visible = self.m_ship_list_view_node:isVisible();
            local realPos = self.m_ship_list_view_node:getParent():convertToNodeSpace(ccp(x,y));
            if visible and self.m_ship_list_view_node:boundingBox():containsPoint(realPos) then
                self.m_clickFlag = false;
            end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,false);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    货物抵达
]]
function game_dart_route.goodsArrive(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_dart_main",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_arrive"), http_request_method.GET, nil,"escort_arrive")
end

--[[

]]
function game_dart_route.checkOtherTeamByUid(self,captain_uid)
    local params = {}
    params.captain_uid = tostring(captain_uid);
    self.m_tickFlag = false;
    local function responseMethod(tag,gameData)
        if gameData == nil then 
            self.m_tickFlag = true;
            return;
        end
        local function callBackFunc()
            self.m_tickFlag = true;
        end
        game_scene:addPop("game_dart_team_info",{gameData = gameData,callBackFunc = callBackFunc})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_other_team"), http_request_method.GET, params,"escort_check_other_team",true,true)
end

--[[
    创建可移动的飞船
]]
function game_dart_route.createMoveShip(self,pos)
    local serverTime = math.floor(game_data:getUserStatusDataByKey("server_time"))
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local tempSize = self.route_node:getContentSize()
    local distance = tempSize.width*0.5
    local vehicle_info = self.m_tGameData.vehicle_info
    local vehicleCount = #self.m_teamUidTab
    function onBtnCilck( event, target )
        if self.m_clickFlag == false then return end
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100
        self:checkOtherTeamByUid(self.m_teamUidTab[index])
    end
    for k,v in pairs(self.m_transShipTable) do
        if vehicle_info[k] == nil then
            v.ship:removeFromParentAndCleanup(true)
            self.m_transShipTable[k] = nil;
        end
    end 
    for i=1,vehicleCount do
        local captain_uid = tostring(self.m_teamUidTab[i])
        local itemVehicle = vehicle_info[captain_uid]
        local escort_time = math.floor(itemVehicle.escort_time)
        local arrive_time = math.floor(itemVehicle.arrive_time)
        --计算位置
        local needTime = arrive_time - escort_time
        local nowTime = serverTime - escort_time
        local rate = math.max(0,nowTime / needTime)
        if rate >= 1 then rate = 1 end
        local posX = rate * distance
        local posY = 150 + tempSize.height* 0.15 * ((i - 1) % 6)
        cclog(needTime,nowTime,posX,posY,distance)

        local transportShip = nil;
        local transShipItem = self.m_transShipTable[captain_uid]
        if transShipItem == nil then
            local buff_sort = itemVehicle.buff_sort or 0
            local buff_sort_item = BUFF_SORT_IMG[buff_sort+1]
            local ship_sprite_name = "dart_moto.png"
            local spoiler_img_name = "dart_moto_spoiler1.png"
            local ship_scale = 1
            if buff_sort_item then
                ship_sprite_name = buff_sort_item.ship;
                spoiler_img_name = buff_sort_item.spoiler;
                ship_scale = buff_sort_item.scale;
            end
            transportShip = CCSprite:createWithSpriteFrameName(ship_sprite_name)
            transportShip:setPosition(ccp(posX,posY))
            transportShip:setAnchorPoint(ccp(0,0))
            transportShip:setScale(ship_scale)
            local shipSize = transportShip:getContentSize();

            local dart_moto_spoiler = CCSprite:createWithSpriteFrameName(spoiler_img_name)
            dart_moto_spoiler:setRotation(20)
            dart_moto_spoiler:setPosition(ccp(shipSize.width*0.15,shipSize.height*0.7))
            local animArr = CCArray:create();
            animArr:addObject(CCFadeIn:create(0.5));
            animArr:addObject(CCFadeOut:create(0.5));
            dart_moto_spoiler:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
            transportShip:addChild(dart_moto_spoiler,-1)

            local button = game_util:createCCControlButton(ship_sprite_name,"",onBtnCilck)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY+130);
            button:setPosition(ccp(shipSize.width*0.5,shipSize.height*0.5))
            button:setOpacity(100)
            -- button:setScale(ship_scale)
            button:setZoomOnTouchDown(false)
            transportShip:addChild(button)
            button:setTag(100 + i)

            local members_info = itemVehicle.members_info or {}
            local goods = itemVehicle.goods or {}
            local members_goods = goods[uid] or {}
            if members_info[uid] and members_goods.goods ~= nil then--我在队伍中
                local dart_moto_spoiler = CCSprite:createWithSpriteFrameName("dart_down.png")
                if dart_moto_spoiler then
                    dart_moto_spoiler:setAnchorPoint(ccp(0.5,0));
                    dart_moto_spoiler:setPosition(ccp(shipSize.width*0.5,shipSize.height-10))
                    transportShip:addChild(dart_moto_spoiler)
                end
            end
            self.m_route_scroll_view:addChild(transportShip,-posY)
            self.m_transShipTable[captain_uid] = {ship = transportShip,ship_button = button}
        else
            transportShip = transShipItem.ship
            transShipItem.ship_button:setTag(100 + i)
        end
        transportShip:stopAllActions();
        transportShip:runAction(CCMoveTo:create(5,ccp(posX,posY)))
        -- if arrive_time < 0 then
        --     transportShip:setVisible(false)
        -- end
        -- local teamId = self.m_teamUidTab[i]
        -- if teamId == self.m_tGameData.uid then
        --    transportShip:setVisible(true) 
            -- if arrive_time < 0 then
            --     self.btn_arrive:setVisible(true)
            -- else
            --     self.btn_arrive:setVisible(false)
            -- end
        -- end
    end
end

--[[
    队伍信息
]]
function game_dart_route.createTavernTable(self,viewSize)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local tabCount = #self.m_teamUidTab;
    local function onCellBtnClick( target,event )
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+130
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_ship_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_ship_title = ccbNode:spriteForName("m_ship_title")
            local m_ship_sprite = ccbNode:spriteForName("m_ship_sprite")
            local m_good_quality = ccbNode:spriteForName("m_good_quality")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local tempUid = self.m_teamUidTab[index+1]
            local itemData = vehicle_info[tempUid] or {}
            local members_info = itemData.members_info
            local goods = itemData.goods or {}
            local member = itemData.member or {}
            local captain_data = members_info[tempUid] or {}
            m_name_label:setString(tostring(captain_data.name))
            local buff_sort = itemData.buff_sort or 0
            local buff_sort_item = BUFF_SORT_IMG[buff_sort+1]    
            if buff_sort_item then
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.title)
                if tempSpriteFrame then
                    m_ship_title:setDisplayFrame(tempSpriteFrame);
                end
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.ship)
                if tempSpriteFrame then
                    m_ship_sprite:setDisplayFrame(tempSpriteFrame);
                end
            end
            local tempNum = 0;
            local quality = 0;
            for k,v in pairs(goods) do
                if v.quality then
                    quality = quality + v.quality
                    tempNum = tempNum + 1;
                end
            end
            quality = math.floor(quality/math.max(1,tempNum))
            quality = math.min(6,math.max(1,quality))
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_goods_quality" .. quality .. ".png")
            if tempSpriteFrame then
                m_good_quality:setVisible(true)
                m_good_quality:setDisplayFrame(tempSpriteFrame);
            else
                m_good_quality:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local visible = self.m_ship_list_view_node:isVisible();
            if not visible then return end
            local tempUid = self.m_teamUidTab[index+1]
            self:checkOtherTeamByUid(tempUid)
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_dart_route.refreshTavernTable(self)
    self.m_ship_list_view_node:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTavernTable(self.m_ship_list_view_node:getContentSize());
    self.m_ship_list_view_node:addChild(tempTableView);
end

--[[--
    刷新ui
]]
function game_dart_route.autoRefreshUi(self)
    self.m_tickFlag = false;
    local function responseMethod(tag,gameData)
        self.m_tickFlag = true;
        if gameData == nil then
            return;
        end
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        game_data:setDataByKeyAndValue("rob_num",self.m_tGameData.rob_num or 0);
        self:formatData();
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, nil,"escort_map_index",false,true)
end

--[[--
    刷新ui
]]
function game_dart_route.refreshUi(self)
    self:refreshTavernTable();
    local vehicle_status = self.m_tGameData.vehicle_status or 0 -- 0无货船，1货船正在运输，2货船运输完成
    if vehicle_status == 1 then
        local arrive_time = self.m_tGameData.arrive_time or 0
        local identity = self.m_tGameData.identity or 0
        if identity ~= 0 and arrive_time > 0 then
            self.tips_label2:setString(string_helper.game_dart_route.text1 .. tostring(game_util:formatTime2(arrive_time)) .. string_helper.game_dart_route.text2)
        else
            self.tips_label2:setString(string_helper.game_dart_route.text3)
        end
    elseif vehicle_status == 2 then
        self.tips_label2:setString(string_helper.game_dart_route.text4)
    else
        self.tips_label2:setString(string_helper.game_dart_route.text5)
    end
    self:createMoveShip()

    if self.m_autoRefreshScheduler == nil then
        function tick( dt )
            if self.m_list_view_bg:isVisible() then return end
            if self.m_tickFlag == false then return end
            if self.m_auto_time > 0 then
                self.m_auto_time = self.m_auto_time - 1;
            else
                self.m_auto_time = 5;
                self:autoRefreshUi();
            end
        end
        self.m_autoRefreshScheduler = scheduler.schedule(tick, 1, false)
    end
    local new_battle = self.m_tGameData.new_battle or 0 --0没有新战斗  1 有
    self.m_new_battle_label:setVisible(new_battle == 1)
end

function game_dart_route.formatData(self)
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    self.m_teamUidTab = {};
    for k,v in pairs(vehicle_info) do
        table.insert(self.m_teamUidTab,k)
    end
    table.sort(self.m_teamUidTab,function(data1,data2) return data1 < data2 end)
end

--[[--
    初始化
]]
function game_dart_route.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_dart3.plist");
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_tickFlag = true;
    self.m_auto_time = 5;
    game_data:setDataByKeyAndValue("rob_num",self.m_tGameData.rob_num or 0);--0人数不足，1已满
    self.m_transShipTable = {};
    self.m_teamUidTab = {};
    self:formatData();
    self.m_clickFlag = true;
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_route.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_route