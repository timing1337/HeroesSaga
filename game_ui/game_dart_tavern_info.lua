---  押镖酒馆  我的队伍
local game_dart_tavern_info = {
    m_team_table_node = nil,
    m_quit_btn = nil,
    m_disband_btn = nil,
    m_start_btn = nil,
    m_top_tips_label = nil,
    m_autoRefreshScheduler = nil,
    m_tickFlag = nil,
    m_auto_time = nil,
    m_identity = nil,
    m_back_btn = nil,
    m_node_chatmsg_board = nil,
    m_showChatData = nil,
    m_lastGameData = nil,
};
--[[--
    销毁ui
]]
function game_dart_tavern_info.destroy(self)
    cclog("----------------- game_dart_tavern_info destroy-----------------"); 
    game_data:removeChatLinster( "game_dart_tavern_info" )
    self.m_team_table_node = nil;
    self.m_quit_btn = nil;
    self.m_disband_btn = nil;
    self.m_start_btn = nil;
    self.m_top_tips_label = nil;
    if self.m_autoRefreshScheduler ~= nil then
        scheduler.unschedule(self.m_autoRefreshScheduler)
        self.m_autoRefreshScheduler = nil;
    end
    self.m_tickFlag = nil;
    self.m_auto_time = nil;
    self.m_identity = nil;
    self.m_back_btn = nil;
    self.m_node_chatmsg_board = nil;
    self.m_showChatData = nil;
    self.m_lastGameData = nil;
end
--[[--
    返回
]]
function game_dart_tavern_info.back(self)
    self.m_tickFlag = false;
    local function responseMethod(tag,gameData)
        self.m_tickFlag = true;
        if gameData == nil then return end
        game_scene:enterGameUi("game_dart_tavern",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_rob_index"), http_request_method.GET, nil,"escort_rob_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_tavern_info.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 11 then--解散
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:enterGameUi("game_dart_tavern",{gameData = gameData})
                game_data:updateChatRoom({ team_id = "" })
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_disband_rob_team"), http_request_method.GET, nil,"escort_disband_rob_team",true,true)
        elseif btnTag == 12 then--出发
            local vehicle_info = self.m_tGameData.vehicle_info or {}
            local member = vehicle_info.member or {}
            if #member < 3 then
                game_util:addMoveTips({text = string_helper.game_dart_tavern_info.text})
                return;
            end
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:enterGameUi("game_dart_route",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, {battle_on = 1},"escort_map_index",true,true)
        elseif btnTag == 13 then--队员退出
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_scene:enterGameUi("game_dart_tavern",{gameData = gameData})
                game_data:updateChatRoom({ team_id = "" })
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_quit_rob_team"), http_request_method.GET, nil,"escort_quit_rob_team",true,true)
        elseif btnTag == 14 then
            game_scene:addPop("ui_chat_pop", {enterType = 7, openType = 2})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_tavern_info1.ccbi");

    self.m_team_table_node = ccbNode:nodeForName("m_team_table_node")
    self.m_quit_btn = ccbNode:controlButtonForName("m_quit_btn")
    self.m_disband_btn = ccbNode:controlButtonForName("m_disband_btn")
    self.m_start_btn = ccbNode:controlButtonForName("m_start_btn")
    self.m_top_tips_label = ccbNode:labelTTFForName("m_top_tips_label")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")

    self.m_showChatData = {}
    local playerName = game_data:getUserStatusDataByKey("show_name") or ""
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    local members_info = vehicle_info.members_info or {}
    if member[1] == uid then
        table.insert(self.m_showChatData, {name = playerName, msg = string_helper.game_dart_tavern_info.creat_team})
        for i= 2, #member do
            if members_info[ member[i] ] then
                table.insert(self.m_showChatData, {name = members_info[ member[i] ].name , msg = string_helper.game_dart_tavern_info.add_team})
            end
        end
    else
        table.insert(self.m_showChatData, {name = playerName, msg = string_helper.game_dart_tavern_info.add_one_team})
    end


    self.m_node_chatmsg_board = ccbNode:nodeForName("m_node_chatmsg_board")    
    -- -- 初始化聊天框
    game_data:startChat()
    local reciveData = function ( chatData, state, kqgFlags )
        if kqgFlags["team"] == true then
            if chatData then
                table.insert(self.m_showChatData, {name = chatData.user, msg = chatData.smpleMsg, playersign = true})
            end
            self:refreshChatUI()
        end
    end

    local m_chatObserver = game_data:getChatObserver()  
    m_chatObserver:registerOneLinster( reciveData, "game_dart_tavern_info" )      
    self:refreshChatUI()

    game_data:updateChatRoom({ team_id = member[1] })

    return ccbNode;
end


function game_dart_tavern_info.refreshChatUI( self )
    self.m_node_chatmsg_board:removeAllChildrenWithCleanup(true)
    local newTableView = self:createChatView( self.m_node_chatmsg_board:getContentSize() )
    if newTableView then
        self.m_node_chatmsg_board:addChild(newTableView)
    end
end

function game_dart_tavern_info.createChatView( self, viewSize )
    local tempNode = CCNode:create()
    tempNode:setContentSize(viewSize)
    local scrollview = CCScrollView:create(viewSize, CCNode:create())
    local container = scrollview:getContainer();
    container:removeAllChildrenWithCleanup(true);

    for i=1,10 do
        if #self.m_showChatData > 4 then
            table.remove(self.m_showChatData, 1)
        else
            break
        end
    end
    local showData = self.m_showChatData or {}
    local totalHeight = 0
    local chatMsgLabelTab = {}
    -- showData = {{name = "小虎子123", msg = "加入了队伍"}, {name = "二虎子123", msg = "加入了队伍"}, {name = "队长 蓝精灵", msg = "来1W战力的"}}
    -- cclog2(showData, "showData  ======   ")
    for index=1,#showData do
        local itemData = showData[index];
        local msg = ""
        msg = msg .. "[color=ff00ff36]" .. tostring(itemData.name) .. ":[/color]  "
        local showMsg = ""
        if itemData.playersign then
            showMsg = msg .. "[color=fff0f0f0]" .. tostring(itemData.msg) .. "[/color]";
        else
            showMsg = msg .. "[color=ffffaa00]" .. tostring(itemData.msg) .. "[/color]";
        end
        local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,
            color = ccc3(255,255, 255),fontSize = 10})
        chatMsgLabel:setAnchorPoint(ccp(0, 0));
        scrollview:addChild(chatMsgLabel);
        chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY - 5);
        chatMsgLabel:setTag(index - 1);
        local label_size = chatMsgLabel:getContentSize()
        local line_height = label_size.height
        local tempHieght = line_height;
        totalHeight = totalHeight + tempHieght + 3;
        chatMsgLabelTab[index] = {label = chatMsgLabel,height = tempHieght};
    end
    local contentSize = CCSizeMake(viewSize.width, math.max(viewSize.height,totalHeight));
    -- cclog("viewSize.width = " .. viewSize.width .. " viewSize.height = " .. viewSize.height)
    -- cclog("contentSize.width = " .. contentSize.width .. " contentSize.height = " .. contentSize.height)
    scrollview:setContentSize(contentSize);
    if contentSize.height > viewSize.height then
        -- self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - contentSize.height));
        scrollview:setContentOffset(ccp(0, 0));
    end
    local tempHeight = 0;
    for index=1,#chatMsgLabelTab do
        local tempData = chatMsgLabelTab[index];
        tempHeight = tempHeight + tempData.height + 3;
        tempData.label:setPositionY(contentSize.height - tempHeight);
    end
    scrollview:setTouchEnabled(false)

    return scrollview 
end



--[[
    队伍信息
]]
function game_dart_tavern_info.createTavernTable(self,viewSize)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local members_info = vehicle_info.members_info
    local member = vehicle_info.member or {}
    local tabCount = #member;
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        if btnTag < 10000 then
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            local prarms = {team_uid = member[btnTag+1]}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_kick_rob_team"), http_request_method.GET, prarms,"escort_kick_rob_team",true,true)
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6
    params.totalItem = 3;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_tavern_info_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_team_node = ccbNode:nodeForName("m_team_node")
            local m_team_node2 = ccbNode:nodeForName("m_team_node2")
            local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
            local m_look_good_btn = ccbNode:controlButtonForName("m_look_good_btn")
            m_look_good_btn:setVisible(false);
            if index < tabCount then
                m_team_node:setVisible(true);
                m_team_node2:setVisible(false);
                local title_sprite = ccbNode:spriteForName("title_sprite")
                local name_label = ccbNode:labelTTFForName("name_label")
                local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
                local m_item_bg_spri = ccbNode:scale9SpriteForName("m_item_bg_spri")
                local tempSpriteFrame = nil;
                if index == 0 then
                    tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pb_ditiao3.png")
                else
                    tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pb_ditiao1.png")
                end
                if tempSpriteFrame then
                    m_item_bg_spri:setSpriteFrame(tempSpriteFrame)
                    m_item_bg_spri:setPreferredSize(CCSizeMake(285,55))
                end
                local m_icon = ccbNode:nodeForName("m_icon")
                local m_kick_btn = ccbNode:controlButtonForName("m_kick_btn")
                m_kick_btn:setTag(index);
                m_icon:removeAllChildrenWithCleanup(true);
                local tempUid = tostring(member[index+1])
                local itemData = members_info[tempUid] or {}
                m_kick_btn:setVisible(self.m_identity == 1 and index ~= 0)
                title_sprite:setVisible(member[1] == tempUid)
                name_label:setString(tostring(itemData.name) .. "(Lv." .. tostring(itemData.level) .. ")");
                m_combat_label:setString(string_helper.game_dart_tavern_info.combat .. tostring(itemData.combat));
            else
                m_team_node:setVisible(false);
                m_team_node2:setVisible(true);
                -- if self.m_identity == 1 then
                --     m_tips_label:setString("雇佣NPC");
                -- else
                    m_tips_label:setString(string_helper.game_dart_tavern_info.wait_man_join);
                -- end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- if self.m_identity == 1 and index >= tabCount then--雇佣NPC    
            --     self.m_tickFlag = false;
            --     local function responseMethod(tag,gameData)
            --         self.m_tickFlag = true;
            --         if gameData == nil then return end
            --         local data = gameData:getNodeWithKey("data");
            --         self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            --         self:refreshUi()
            --     end
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_employ"), http_request_method.GET, nil,"escort_employ",true,true)
            -- end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_dart_tavern_info.autoRefreshUi(self)
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local battle_on = vehicle_info.battle_on or 0
    if battle_on == 1 then--发起抢劫战斗之后不需要刷新了
        self.m_tickFlag = false;
        return;
    end
    self.m_tickFlag = false;
    local function responseMethod(tag,gameData,contentLength,status)
        if gameData == nil then 
            if status == "-9" or status == "-10" then
                game_util:closeAlertView();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self:back()
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config:getTextByKey("m_btn_sure"),       --可缺省
                    text = string_helper.game_dart_tavern_info.text2,      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);
            else
                self.m_tickFlag = true;
            end
            return 
        end
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self:refreshUi()
        local vehicle_info = self.m_tGameData.vehicle_info or {}
        local member = vehicle_info.member or {}
        local battle_on = vehicle_info.battle_on or 0
        local uid = game_data:getUserStatusDataByKey("uid") or ""

        if game_util:valueInTeam(uid,member) then
            if battle_on ~= 0 then
                local function responseMethod(tag,gameData)
                    self.m_tickFlag = true;
                    if gameData == nil then return end
                    game_scene:enterGameUi("game_dart_route",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, nil,"escort_map_index",true,true)
            else
                self.m_tickFlag = true;
            end
        else
            game_util:closeAlertView();
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self:back()
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config:getTextByKey("m_btn_sure"),       --可缺省
                text = string_helper.game_dart_tavern_info.text3,      --可缺省
                closeFlag = false,
            }
            game_util:openAlertView(t_params);
        end
    end
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, {captain_uid = member[1]},"escort_check_my_rob_team",false,true)
end

--[[--
    刷新ui
]]
function game_dart_tavern_info.refreshUi(self)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    --m_identity 0是无对1是队长2是队员
    if game_util:valueInTeam(uid,member) then
        if member[1] == uid then
            self.m_identity = 1;
        else
            self.m_identity = 2;
        end
    else
        self.m_identity = 0;
    end
    self.m_back_btn:setVisible(self.m_identity == 0)
    local leadFlag = (self.m_identity == 1)
    -- self.m_back_btn:setVisible(not leadFlag)
    self.m_start_btn:setVisible(leadFlag)
    self.m_disband_btn:setVisible(leadFlag)
    local teamMemberFlag = (self.m_identity == 2)
    self.m_quit_btn:setVisible(teamMemberFlag)

    self.m_team_table_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createTavernTable(self.m_team_table_node:getContentSize())
    tempTable:setMoveFlag(false);
    tempTable:setScrollBarVisible(false);
    self.m_team_table_node:addChild(tempTable)

    if self.m_autoRefreshScheduler == nil then
        function tick( dt )
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
    self:updateData()
end


--[[
    更新数据
]]
function game_dart_tavern_info.updateData( self )
    if not self.m_lastGameData then
         self.m_lastGameData = util.table_copy(self.m_tGameData)
         return
    end

    local lastGameData = self.m_lastGameData
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local auto_start_sail = vehicle_info.auto_start_sail or 0 --自动1，不自动 0 
    local member = vehicle_info.member or {}
    local arrive_time = vehicle_info.arrive_time or 0
    local members_info = vehicle_info.members_info or {}

    local last_vehicle_info = lastGameData.vehicle_info or {}
    local last_member = last_vehicle_info.member or {}
    local last_members_info = last_vehicle_info.members_info or {}

    for k,v in pairs( last_member ) do
        if not game_util:valueInTeam( v, member ) then
            local one_player = last_members_info[tostring(v)]
            if one_player then
                table.insert(self.m_showChatData, {name = one_player.name, msg = string_helper.game_dart_tavern_info.end_team})
            end
        end
    end

    for k,v in pairs( member ) do
        if not game_util:valueInTeam( v, last_member ) then
            local one_player = members_info[tostring(v)]
            if one_player then
                table.insert(self.m_showChatData, {name = one_player.name, msg = string_helper.game_dart_tavern_info.add_team

                    })
            end
        end
    end
    self.m_lastGameData = util.table_copy(self.m_tGameData)
    self:refreshChatUI()
end


--[[--
    初始化
]]
function game_dart_tavern_info.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_tickFlag = true;
    self.m_auto_time = 5;
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_tavern_info.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_tavern_info