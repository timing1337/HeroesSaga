---  押镖我的队伍
local game_dart_my_team = {
    m_team_table_node = nil,
    m_quit_btn = nil,
    m_disband_btn = nil,
    m_start_btn = nil,
    m_top_tips_label = nil,
    m_ship_tips_label = nil,
    m_ship_sprite = nil,
    m_ship_title = nil,
    m_auto_start_tips_label = nil,
    m_auto_start_sel = nil,
    m_item_count_label = nil,
    m_free_time_label = nil,
    m_cost_tips_label = nil,
    m_auto_start_btn = nil,
    m_openType = nil,
    m_back_btn = nil,
    m_autoRefreshScheduler = nil,
    m_tickFlag = nil,
    m_auto_time = nil,
    m_auto_start_ndoe = nil,
    m_leader_node = nil,
    m_des_node = nil,
    m_ship_type_icon = nil,
    m_node_chatmsg_board = nil,
    m_showChatData = nil,
    m_lastGameData = nil,
};
--[[--
    销毁ui
]]
function game_dart_my_team.destroy(self)
    cclog("----------------- game_dart_my_team destroy-----------------"); 
    game_data:removeChatLinster( "game_dart_my_team" )
    self.m_team_table_node = nil;
    self.m_quit_btn = nil;
    self.m_disband_btn = nil;
    self.m_start_btn = nil;
    self.m_top_tips_label = nil;
    self.m_ship_tips_label = nil;
    self.m_ship_sprite = nil;
    self.m_ship_title = nil;
    self.m_auto_start_tips_label = nil;
    self.m_auto_start_sel = nil;
    self.m_item_count_label = nil;
    self.m_free_time_label = nil;
    self.m_cost_tips_label = nil;
    self.m_auto_start_btn = nil;
    self.m_openType = nil;
    self.m_back_btn = nil;
    if self.m_autoRefreshScheduler ~= nil then
        scheduler.unschedule(self.m_autoRefreshScheduler)
        self.m_autoRefreshScheduler = nil;
    end
    self.m_tickFlag = nil;
    self.m_auto_time = nil;
    self.m_auto_start_ndoe = nil;
    self.m_leader_node = nil;
    self.m_des_node = nil;
    self.m_ship_type_icon = nil;
    self.m_node_chatmsg_board = nil;
    self.m_showChatData = nil;
    self.m_lastGameData = nil;
end

--[[--
    返回
]]
function game_dart_my_team.back(self)
    if self.m_openType == "game_dart_main" then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_dart_main",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_dart_team_recruitment",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_team_index"), http_request_method.GET, nil,"escort_team_index")
        -- local function responseMethod(tag,gameData)
        --     game_scene:enterGameUi("game_dart_shop",{gameData = gameData});
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_shop_index"), http_request_method.GET, nil,"escort_shop_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_dart_my_team.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--详情
            game_scene:addPop("game_dart_ship_detail_pop")
        elseif btnTag == 3 then--自动起航
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                -- self.m_auto_start_sel:setVisible(not self.m_auto_start_sel:isVisible())
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            local prarms = {auto_start_sail = self.m_auto_start_sel:isVisible() and 0 or 1}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_auto_start_sail"), http_request_method.GET, prarms,"escort_auto_start_sail",true,true)
        elseif btnTag == 4 or btnTag == 5 then--升级  特殊升级
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                local data = gameData:getNodeWithKey("data");
                local buff_sort = self.m_tGameData.buff_sort or 0
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                local buff_sort2 = self.m_tGameData.buff_sort or 0
                cclog("buff_sort",buff_sort,buff_sort2)
                if buff_sort2 ~= buff_sort and buff_sort2 ~= 0 then
                    game_util:addMoveTips({text = string_helper.game_dart_my_team.boat_upgrade_success})
                else
                    game_util:addMoveTips({text = string_helper.game_dart_my_team.boat_upgrade_fail})
                end 
                self:refreshUi()
            end
            local prarms = {}
            if btnTag == 5 then
                prarms.item_id = "99000";
            else
                local buff_free_times = self.m_tGameData.buff_free_times or 0
                if buff_free_times <= 0 then
                    prarms.is_coin = 1--花费钻石
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_upgrade_vehicle_buff"), http_request_method.GET, prarms,"escort_upgrade_vehicle_buff",true,true)
        elseif btnTag == 11 then--解散
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_data:updateChatRoom({ team_id = "" })
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_disband_goods_team"), http_request_method.GET, nil,"escort_disband_goods_team",true,true)
        elseif btnTag == 12 then--出发
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_data:setDataByKeyAndValue("sel_dart_good",nil)
                game_scene:enterGameUi("game_dart_route",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_start_sail"), http_request_method.GET, nil,"escort_start_sail",true,true)
        elseif btnTag == 13 then--退出队伍
            self.m_tickFlag = false;
            local function responseMethod(tag,gameData)
                self.m_tickFlag = true;
                if gameData == nil then return end
                game_data:updateChatRoom({ team_id = "" })
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_quit_goods_team"), http_request_method.GET, nil,"escort_quit_goods_team",true,true)
        elseif btnTag == 14 then  -- 聊天
            game_scene:addPop("ui_chat_pop", {enterType = 6, openType = 2 })
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_myteam1.ccbi");

    self.m_team_table_node = ccbNode:nodeForName("m_team_table_node")
    self.m_quit_btn = ccbNode:controlButtonForName("m_quit_btn")
    self.m_disband_btn = ccbNode:controlButtonForName("m_disband_btn")
    self.m_start_btn = ccbNode:controlButtonForName("m_start_btn")


    self.m_top_tips_label = ccbNode:labelTTFForName("m_top_tips_label")
    self.m_ship_tips_label = ccbNode:labelTTFForName("m_ship_tips_label")
    self.m_ship_sprite = ccbNode:spriteForName("m_ship_sprite")
    self.m_ship_title = ccbNode:spriteForName("m_ship_title")
    self.m_auto_start_tips_label = ccbNode:labelTTFForName("m_auto_start_tips_label")
    self.m_auto_start_sel = ccbNode:spriteForName("m_auto_start_sel")
    self.m_item_count_label = ccbNode:labelTTFForName("m_item_count_label")
    self.m_free_time_label = ccbNode:labelTTFForName("m_free_time_label")
    self.m_cost_tips_label = ccbNode:labelTTFForName("m_cost_tips_label")
    self.m_auto_start_btn = ccbNode:controlButtonForName("m_auto_start_btn")
    self.m_auto_start_btn:setOpacity(0);
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_auto_start_ndoe = ccbNode:nodeForName("m_auto_start_ndoe")
    self.m_leader_node = ccbNode:nodeForName("m_leader_node")
    self.m_des_node = ccbNode:nodeForName("m_des_node")
    self.m_ship_type_icon = ccbNode:spriteForName("m_ship_type_icon")
    self.m_auto_start_ndoe:setVisible(false)
    game_util:setNodeUpAndDownMoveAction(self.m_ship_sprite)


    self.m_showChatData = {}
    local playerName = game_data:getUserStatusDataByKey("show_name") or ""
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    local members_info = vehicle_info.members_info or {}
    if member[1] == uid then
        table.insert(self.m_showChatData, {name = playerName, msg = string_helper.game_dart_my_team.creat_team})
        for i= 2, #member do
            if members_info[ member[i] ] then
                table.insert(self.m_showChatData, {name = members_info[ member[i] ].name , msg = string_helper.game_dart_my_team.add_team})
            end
        end
    else
        table.insert(self.m_showChatData, {name = playerName, msg = string_helper.game_dart_my_team.add_one_team})
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
    m_chatObserver:registerOneLinster( reciveData, "game_dart_my_team" )      
    self:refreshChatUI()

    game_data:updateChatRoom({ team_id = member[1] })

    return ccbNode;
end



function game_dart_my_team.refreshChatUI( self )
    self.m_node_chatmsg_board:removeAllChildrenWithCleanup(true)
    local newTableView = self:createChatView( self.m_node_chatmsg_board:getContentSize() )
    if newTableView then
        self.m_node_chatmsg_board:addChild(newTableView)
    end
end

function game_dart_my_team.createChatView( self, viewSize )
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
function game_dart_my_team.createTavernTable(self,viewSize)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local shop_coin_fresh_times = self.m_tGameData.shop_coin_fresh_times or 0
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local members_info = vehicle_info.members_info
    local goods = vehicle_info.goods or {}
    local member = vehicle_info.member or {}
    local tabCount = #member;
    local chatInfo = nil
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
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_kick_goods_team"), http_request_method.GET, prarms,"escort_kick_goods_team",true,true)
        else
            local tempUid = tostring(member[btnTag - 10000 + 1])
            local itemData = members_info[tempUid] or {}
            local playerGoods = goods[tempUid] or {}
            local tempGoods = playerGoods.goods or {}
            if #tempGoods > 0 then
                game_util:lookItemDetal(tempGoods[1])
            end
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
            ccbNode:openCCBFile("ccb/ui_dart_team_info_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_team_node = ccbNode:nodeForName("m_team_node")
            local m_team_node2 = ccbNode:nodeForName("m_team_node2")
            local m_team_node3 = ccbNode:nodeForName("m_team_node3")
            local m_look_good_btn = ccbNode:controlButtonForName("m_look_good_btn")
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
                m_look_good_btn:setTag(10000+index);
                m_icon:removeAllChildrenWithCleanup(true);
                local tempUid = tostring(member[index+1])
                local itemData = members_info[tempUid] or {}
                m_kick_btn:setVisible(self.m_identity == 1 and index ~= 0)
                title_sprite:setVisible(member[1] == tempUid)
                local playerGoods = goods[tempUid] or {}
                local tempGoods = playerGoods.goods or {}
                if #tempGoods > 0 then
                    local icon,goods_name,count = game_util:getRewardByItemTable(tempGoods[1])
                    if icon then
                        icon:setScale(0.8)
                        icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
                        m_icon:addChild(icon)
                        if count then
                            local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                            countLabel:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5-15))
                            icon:addChild(countLabel,10)
                        end
                    end
                end
                m_look_good_btn:setVisible(#tempGoods > 0);
                name_label:setString(tostring(itemData.name) .. "(Lv." .. tostring(itemData.level) .. ")");
                m_combat_label:setString(string_helper.game_dart_my_team.combat .. tostring(itemData.combat));
            else
                m_look_good_btn:setVisible(false);
                m_team_node:setVisible(false);
                if self.m_identity == 1 then
                    local m_cost_coin_label = ccbNode:labelTTFForName("m_cost_coin_label")
                    local canBuy,payValue = game_util:getCostCoinBuyTimes("24",shop_coin_fresh_times)
                    m_cost_coin_label:setString(tostring(payValue))
                    m_team_node2:setVisible(false);
                    m_team_node3:setVisible(true);
                else
                    m_team_node2:setVisible(true);
                    m_team_node3:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if self.m_identity == 1 and index >= tabCount then--雇佣NPC    
                self.m_tickFlag = false;
                local function responseMethod(tag,gameData)
                    self.m_tickFlag = true;
                    if gameData == nil then return end
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_employ"), http_request_method.GET, nil,"escort_employ",true,true)
            end
        end
    end
    return TableViewHelper:create(params);
end




--[[
    更新数据
]]
function game_dart_my_team.updateData( self )
    if not self.m_lastGameData then
         self.m_lastGameData = util.table_copy(self.m_tGameData)
         return
    end

    local lastGameData = self.m_lastGameData
    local vehicle_info = self.m_tGameData.vehicle_info or {}
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
                table.insert(self.m_showChatData, {name = one_player.name, msg = string_helper.game_dart_my_team.end_team})
            end
        end
    end

    for k,v in pairs( member ) do
        if not game_util:valueInTeam( v, last_member ) then
            local one_player = members_info[tostring(v)]
            if one_player then
                table.insert(self.m_showChatData, {name = one_player.name, msg = string_helper.game_dart_my_team.add_team})
            end
        end
    end
    self.m_lastGameData = util.table_copy(self.m_tGameData)
    self:refreshChatUI()
end




--[[--
    刷新ui
]]
function game_dart_my_team.autoRefreshUi(self)
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
                    text = string_helper.game_dart_my_team.text,      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);
            else
                self.m_tickFlag = true;
            end
            return;
        end
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self:refreshUi()
        local vehicle_info = self.m_tGameData.vehicle_info or {}
        local auto_start_sail = vehicle_info.auto_start_sail or 0 --自动1，不自动 0 
        local arrive_time = vehicle_info.arrive_time or 0
        local member = vehicle_info.member or {}
        local battle_on = vehicle_info.battle_on or 0
        local uid = game_data:getUserStatusDataByKey("uid") or ""

        -- if auto_start_sail == 1 and #member > 2 then
        --     local function responseMethod(tag,gameData)--起航
        --         self.m_tickFlag = true;
        --         if gameData == nil then return end
        --         game_scene:enterGameUi("game_dart_route",{gameData = gameData})
        --     end
        --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_start_sail"), http_request_method.GET, nil,"escort_start_sail",true,true)
        -- end

        local uid = game_data:getUserStatusDataByKey("uid") or ""
        --m_identity 0是无对1是队长2是队员
        if game_util:valueInTeam(uid,member) then
            if arrive_time > 0 then
                local function responseMethod(tag,gameData)
                    self.m_tickFlag = true;
                    if gameData == nil then return end
                    game_data:setDataByKeyAndValue("sel_dart_good",nil)
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
                text = string_helper.game_dart_my_team.text2,      --可缺省
                closeFlag = false,
            }
            game_util:openAlertView(t_params);
        end
    end
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    cclog("captain_uid ============ ",member[1])
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_team"), http_request_method.GET, {captain_uid = member[1]},"escort_check_my_team",false,true)
end

--[[--
    刷新ui
]]
function game_dart_my_team.refreshUi(self)
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
    self.m_start_btn:setVisible(leadFlag)
    self.m_disband_btn:setVisible(leadFlag)
    self.m_leader_node:setVisible(leadFlag)
    local teamMemberFlag = (self.m_identity == 2)
    self.m_quit_btn:setVisible(teamMemberFlag)
    if self.m_identity ~= 1 then
        self.m_des_node:setPositionY(50);
    end

    self.m_team_table_node:removeAllChildrenWithCleanup(true)
    local teamTable = self:createTavernTable(self.m_team_table_node:getContentSize())
    teamTable:setMoveFlag(false);
    teamTable:setScrollBarVisible(false);
    self.m_team_table_node:addChild(teamTable)

    local buff_free_times = self.m_tGameData.buff_free_times or 0
    if buff_free_times > 0 then
        self.m_free_time_label:setString(string_helper.game_dart_my_team.free .. tostring(buff_free_times) .. string_helper.game_dart_my_team.side)
    else
        local buff_coin_upgrade_times = self.m_tGameData.buff_coin_upgrade_times or 0
        local canBuy,payValue = game_util:getCostCoinBuyTimes("26",shop_coin_fresh_times)
        self.m_free_time_label:setString(tostring(payValue) .. string_helper.game_dart_my_team.diamond_side)
    end
    local item_num = self.m_tGameData.item_num or 0
    self.m_item_count_label:setString(string_helper.game_dart_my_team.prop_residue .. tostring(item_num))

    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local auto_start_sail = vehicle_info.auto_start_sail or 0 --自动1，不自动 0 
    self.m_auto_start_sel:setVisible(auto_start_sail == 1)

    local buff_sort = self.m_tGameData.buff_sort or 0
    local buff_sort_item = BUFF_SORT_IMG[buff_sort+1]    
    if buff_sort_item then
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.title)
        if tempSpriteFrame then
            self.m_ship_title:setDisplayFrame(tempSpriteFrame);
        end
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.ship)
        if tempSpriteFrame then
            self.m_ship_sprite:setDisplayFrame(tempSpriteFrame);
        end
        self.m_ship_sprite:setScale(buff_sort_item.scale)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.icon)
        if tempSpriteFrame then
            self.m_ship_type_icon:setDisplayFrame(tempSpriteFrame);
        end
        self.m_ship_tips_label:setString(tostring(buff_sort_item.des))
    end
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
--[[--
    初始化
]]
function game_dart_my_team.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self.vehicle_is_ready = self.m_tGameData.vehicle_is_ready or false
        else
            self.m_tGameData = t_params.gameData;
        end
    else
        self.m_tGameData = {};
    end
    self.m_openType = t_params.openType or ""
    self.m_tickFlag = true;
    self.m_auto_time = 5;
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_my_team.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_my_team