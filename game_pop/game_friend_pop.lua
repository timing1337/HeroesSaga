---  好友 

local game_friend_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_search_node = nil,
    m_edit_bg_node = nil,
    m_search_btn = nil,
    m_close_btn = nil,
    m_search_list_view_bg = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_showIndex = nil,
    m_tFriendData = nil,
    m_tMessagesData = nil,
    m_tSearchData = nil,
    m_searchUID = nil,
};

local friendMenuTab = {{title = string_helper.game_friend_pop.lk_player,type=1},{title = string_helper.game_friend_pop.tc,type=1},{title = string_helper.game_friend_pop.lt,type=1},{title = string_helper.game_friend_pop.del,type=2}}
local messageMenuTab = {{title = string_helper.game_friend_pop.add_friend,type=1},{title = string_helper.game_friend_pop.lk_player,type=1},{title = string_helper.game_friend_pop.del_msg,type=1},{title = string_helper.game_friend_pop.must_del,type=2}}
local searchMenuTab = {{title = string_helper.game_friend_pop.add_friend,type=1},{title = string_helper.game_friend_pop.lk_player,type=1}}

--[[--
    销毁
]]
function game_friend_pop.destroy(self)
    -- body
    cclog("-----------------game_friend_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_search_node = nil;
    self.m_edit_bg_node = nil;
    self.m_search_btn = nil;
    self.m_close_btn = nil;
    self.m_search_list_view_bg = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_showIndex = nil;
    self.m_tFriendData = nil;
    self.m_tMessagesData = nil;
    self.m_tSearchData = nil;
    self.m_searchUID = nil;
end
--[[--
    返回
]]
function game_friend_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_friend_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_friend_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 or btnTag == 3 or btnTag == 4 then--
            self.m_showIndex = btnTag - 1;
            self:refreshTabBtn();
        end
    end
    local function onSearchBtnClick( target,event )
        if self.m_searchUID and self.m_searchUID ~= "" then
            -- cclog("self.m_searchUID ========" .. self.m_searchUID)
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local user = data:getNodeWithKey("user");
                self.m_tSearchData.data = json.decode(user:getFormatBuffer()) or {}
                self:refreshTab3();
            end
            --target_id
            local params = {};
            params.target_id = tostring(util.url_encode(self.m_searchUID));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_search"), http_request_method.GET, params,"friend_search")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:registerFunctionWithFuncName("onSearchBtnClick",onSearchBtnClick);
    ccbNode:openCCBFile("ccb/ui_friend_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_search_node = ccbNode:nodeForName("m_search_node")
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    self.m_search_btn = ccbNode:controlButtonForName("m_search_btn");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_search_list_view_bg = ccbNode:layerForName("m_search_list_view_bg")

    self.m_edit_bg_node:setOpacity(0);
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_searchUID = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder=string_helper.game_friend_pop.put});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_edit_bg_node:addChild(editBox);

    self.m_search_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建好友列表
]]
function game_friend_pop.lookPlayerInfo(self,uid)
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_player_info_pop",{gameData = gameData})
    end
    local params = {};
    params.uid = uid;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
end

--[[--
    创建好友列表
]]
function game_friend_pop.createFriendTableView(self,viewSize)
    local tGameData = self.m_tFriendData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        if tag == 1 then--查看玩家
            local itemData = tGameData[selIndex+1];
            self:lookPlayerInfo(itemData.uid);
        elseif tag == 2 then--切磋
            local function responseMethod(tag,gameData)
                game_data:setBattleType("friend_pk");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local itemData = tGameData[selIndex+1];
            local params = {};
            params.target_id = itemData.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_battle"), http_request_method.GET, params,"friend_battle")
        elseif tag == 3 then--聊天
        elseif tag == 4 then--删除
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                local data = gameData:getNodeWithKey("data");
                local friends = data:getNodeWithKey("friends");
                self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
                self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
                self.m_list_view_bg:addChild(tableViewTemp);
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local itemData = tGameData[selIndex+1];
                    local params = {};
                    params.target_id = itemData.uid;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_remove_friend"), http_request_method.GET, params,"friend_remove_friend")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_helper.game_friend_pop.del_friend,       --可缺省
                text = string_helper.game_friend_pop.qd_del_fr,      --可缺省
            }
            game_util:openAlertView(t_params);
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_friend_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_player_icon");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_player_label = ccbNode:labelTTFForName("m_player_label")
                local m_online_icon = ccbNode:spriteForName("m_online_icon");
                local m_guild_icon = ccbNode:spriteForName("m_guild_icon");
                local m_guild_label = ccbNode:labelTTFForName("m_guild_label")
                local m_combat_label = ccbNode:labelTTFForName("m_combat_label")
                -- print("itemData =========== " .. tostring(itemData.level) .. " ; m_level_label " .. tostring(tolua.type(m_level_label)));
                m_level_label:setString(tostring(itemData.level))
                m_rank_label:setString(tostring(index+1))
                m_player_label:setString(tostring(itemData.name));
                m_combat_label:setString(tostring(itemData.combat));
                if itemData.online then
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_on.png"))
                else
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_off.png"))
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            local px,py = cell:getPosition();
            local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
            selIndex = index;
            game_scene:addPop("game_menu_pop",{menuTab = friendMenuTab,pos = pos,callFunc = menuPopCallFunc});
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_friend_pop.refreshTab1(self)
    self.m_search_node:setVisible(false)
    self.m_list_view_bg:setVisible(true);
    if self.m_tFriendData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tFriendData.init = true;
            local data = gameData:getNodeWithKey("data");
            local friends = data:getNodeWithKey("friends");
            self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_friends"), http_request_method.GET, nil,"friend_friends")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createFriendTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);
    end
end


--[[--
    创建消息列表
]]
function game_friend_pop.createMessageTableView(self,viewSize)
    local tGameData = self.m_tMessagesData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        if tag == 1 then--添加好友
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                -- game_util:addMoveTips({text = "您成功添加" .. tostring(tGameData[selIndex+1].send_name) .. "为好友!"});
                game_util:addMoveTips({text = string_helper.game_friend_pop.sc_add_fr});
                local data = gameData:getNodeWithKey("data");
                local messages = data:getNodeWithKey("messages");
                if messages then
                    self.m_tMessagesData.data = json.decode(messages:getFormatBuffer()) or {}
                    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                    local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
                    self.m_list_view_bg:addChild(tableViewTemp);
                else
                    table.remove(self.m_tMessagesData.data,selIndex+1)
                    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                    local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
                    self.m_list_view_bg:addChild(tableViewTemp);
                end
                local friends = data:getNodeWithKey("friends");
                if friends then
                    self.m_tFriendData.init = true;
                    self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
                end
            end
            local itemData = tGameData[selIndex+1];
            local params = {};
            params.target_id = itemData.send_uid;
            params.message_id = itemData.id;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_add_friend"), http_request_method.GET, params,"friend_add_friend")
        elseif tag == 2 then--查看玩家
            local itemData = tGameData[selIndex+1];
            self:lookPlayerInfo(itemData.send_uid);
        elseif tag == 3 then--删除消息
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                local data = gameData:getNodeWithKey("data");
                local messages = data:getNodeWithKey("messages");
                self.m_tMessagesData.data = json.decode(messages:getFormatBuffer()) or {}
                self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
                self.m_list_view_bg:addChild(tableViewTemp);
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local itemData = tGameData[selIndex+1];
                    local params = {};
                    params.message_id = itemData.id;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_del_message"), http_request_method.GET, params,"friend_del_message")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_helper.game_friend_pop.del_msg,       --可缺省
                text = string_helper.game_friend_pop.qd_del_msg,      --可缺省
            }
            game_util:openAlertView(t_params);
        elseif tag == 4 then--全部删除
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                local data = gameData:getNodeWithKey("data");
                local messages = data:getNodeWithKey("messages");
                self.m_tMessagesData.data = json.decode(messages:getFormatBuffer()) or {}
                self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
                self.m_list_view_bg:addChild(tableViewTemp);
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local params = {};
                    params.message_all = "true";
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_del_message"), http_request_method.GET, params,"friend_del_message")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_helper.game_friend_pop.del_msg,       --可缺省
                text = string_helper.game_friend_pop.qd_del_msg,      --可缺省
            }
            game_util:openAlertView(t_params);
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_message_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_player_icon");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_msg_label = ccbNode:labelTTFForName("m_msg_label")
                local m_combat_label = ccbNode:labelTTFForName("m_combat_label")
                m_level_label:setString(tostring(itemData.level))
                m_rank_label:setString(tostring(index+1))
                m_msg_label:setString(tostring(itemData.content));
                m_combat_label:setString(tostring(itemData.combat));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
            local px,py = cell:getPosition();
            local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            game_scene:addPop("game_menu_pop",{menuTab = messageMenuTab,pos=pos,callFunc = menuPopCallFunc});
        end
    end
    return TableViewHelper:create(params);
end


--[[--

]]
function game_friend_pop.refreshTab2(self)
    self.m_search_node:setVisible(false)
    self.m_list_view_bg:setVisible(true);
    if self.m_tMessagesData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tMessagesData.init = true;
            local data = gameData:getNodeWithKey("data");
            local messages = data:getNodeWithKey("messages");
            self.m_tMessagesData.data = json.decode(messages:getFormatBuffer()) or {}
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_messages"), http_request_method.GET, nil,"friend_messages")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createMessageTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);
    end
end

--[[--
    创建好友列表
]]
function game_friend_pop.createSearchTableView(self,viewSize)
    local tGameData = self.m_tSearchData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        if tag == 1 then--添加好友
            local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_menu_pop")
                game_util:addMoveTips({text = string_helper.game_friend_pop.sc_add_fr});
                local data = gameData:getNodeWithKey("data");
                local friends = data:getNodeWithKey("friends");
                if friends then
                    self.m_tFriendData.init = true;
                    self.m_tFriendData.data = json.decode(friends:getFormatBuffer()) or {}
                end
            end
            local itemData = tGameData[selIndex+1];
            local params = {};
            params.target_id = itemData.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_add_friend"), http_request_method.GET, params,"friend_add_friend")
        elseif tag == 2 then--查看玩家
            local itemData = tGameData[selIndex+1];
            self:lookPlayerInfo(itemData.uid);
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_friend_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_rank_label = ccbNode:labelTTFForName("m_rank_label")
                local m_player_icon = ccbNode:spriteForName("m_player_icon");
                local m_level_label = ccbNode:labelTTFForName("m_level_label")
                local m_player_label = ccbNode:labelTTFForName("m_player_label")
                local m_online_icon = ccbNode:spriteForName("m_online_icon");
                local m_guild_icon = ccbNode:spriteForName("m_guild_icon");
                local m_guild_label = ccbNode:labelTTFForName("m_guild_label")
                local m_combat_label = ccbNode:labelTTFForName("m_combat_label")
                -- print("itemData =========== " .. tostring(itemData.level) .. " ; m_level_label " .. tostring(tolua.type(m_level_label)));
                m_level_label:setString(tostring(itemData.level))
                m_rank_label:setString(tostring(index+1))
                m_player_label:setString(tostring(itemData.name));
                m_combat_label:setString(tostring(itemData.combat));
                if itemData.online then
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_on.png"))
                else
                    m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_off.png"))
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
            local px,py = cell:getPosition();
            local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            game_scene:addPop("game_menu_pop",{menuTab = searchMenuTab,pos=pos,callFunc = menuPopCallFunc});
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_friend_pop.refreshTab3(self)
    self.m_search_node:setVisible(true)
    self.m_list_view_bg:setVisible(false);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_search_list_view_bg:removeAllChildrenWithCleanup(true);    
    local tableViewTemp = self:createSearchTableView(self.m_search_list_view_bg:getContentSize());
    self.m_search_list_view_bg:addChild(tableViewTemp);
end

--[[--

]]
function game_friend_pop.refreshTabBtn(self)
    local flag1 = self.m_showIndex == 1 and true or false
    local flag2 = self.m_showIndex == 2 and true or false
    local flag3 = self.m_showIndex == 3 and true or false
    self.m_tab_btn_1:setHighlighted(flag1);
    self.m_tab_btn_1:setEnabled(not flag1);
    self.m_tab_btn_2:setHighlighted(flag2);
    self.m_tab_btn_2:setEnabled(not flag2);
    self.m_tab_btn_3:setHighlighted(flag3);
    self.m_tab_btn_3:setEnabled(not flag3);
    if self.m_showIndex == 1 then
        self:refreshTab1();
    elseif self.m_showIndex == 2 then
        self:refreshTab2();
    elseif self.m_showIndex == 3 then
        self:refreshTab3();
    end
end

--[[--
    刷新ui
]]
function game_friend_pop.refreshUi(self)
    self:refreshTabBtn();    
end

--[[--
    初始化
]]
function game_friend_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_showIndex = t_params.showIndex or 1;
    self.m_tFriendData = {init = false,data = {}};
    self.m_tMessagesData = {init = false,data = {}}
    self.m_tSearchData = {init = false,data = {}}
end

--[[--
    创建ui入口并初始化数据
]]
function game_friend_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_friend_pop;