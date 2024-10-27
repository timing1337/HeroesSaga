--- 聊天

--[[--
第一次连接后，服务器返回所保存的世界消息，以及系统消息，玩家对应工会消息，以及针对玩家的好友消息
第一次，
    {kqgFlag=first,uid="",association_id="",show_name=""}
数据格式 ： world－世界  guild－工会  friend－好友 system－系统 guild_war-世界争霸
    {kqgFlag="word",show_name="玩家名字",uid="玩家id",inputStr="输入的内容",data=数据表,association_id="工会id",sendToUid = "对象uid",sendToName = "对象名字"}	
]]

local ui_chat_pop = {
	m_ccbNode = nil,			-- 
	m_editNode = nil,			-- 输入框
	m_socket = nil,
	m_msg = nil,
	m_maxMsg = nil,
	m_curMsg = nil,
	m_curFlag =nil,				-- 分类标记 ， world,世界  guild,工会  friend,好友
	m_conectOk = nil,
	m_tempData = nil,
	m_root_layer = nil,
    m_itemBtn = nil,
    m_closeBtn = nil,
    m_chatBtnPress = nil,
    m_scroll_view = nil,
    m_card_btn = nil,
    m_equip_btn = nil,
    m_voice_btn = nil,
    m_item_btn = nil,
    m_share_btn = nil;
    m_showDataTab = nil,
    m_list_view_bg = nil,
    m_editUserChanged = nil,
    m_popUi = nil,
    m_sendToName = nil,
    m_ownUID = nil,
    m_share_btn_layer = nil,
    m_openType = nil,
    m_sendToUid = nil,
    m_node_myicon = nil,
    m_node_chatother_board = nil,
    m_node_inputchat_board = nil,

    m_chatState = nil,
    m_chatOtherInfo = nil,

    m_chatObserver = nil,

    m_comeInChatFriendInfo = nil,

    m_avatarID = nil,

    m_friendChatSign = nil,

    m_editNodeBoard = nil,
    enterType = nil,
    m_msg_showtop = nil,
    m_last_tableview_y = nil,
    m_last_show_msgindex = nil,


    m_curShowMsgType = nil,
    m_curShowMsgIndex = nil,
    m_allWorldMsg = nil,
    m_oneChatCellSize = nil,

    m_chat_types = nil,
    m_sort_id = nil,

    m_last_msgIndex = nil,

    m_cur_showType = nil,

    m_sign_table = nil,
    m_history_table = nil,
    m_cur_chat_table = nil,
    m_offset_number = nil;
    m_refreshUI = nil,
    m_menu_items = nil,
    m_last_msgNumbers = nil,
}

function ui_chat_pop:destroy(  )
    cclog("-----------------ui_chat_pop destroy-----------------");
    -- body
    game_data:removeChatLinster( "ui_chat_pop" )
    if self.m_chatObserver  then
        self.m_chatObserver:setChatState("not_ui_chat_pop")
        self.m_chatObserver:removeOneLinster( "ui_chat_pop" )
    end
    self.m_ccbNode = nil;
    self.m_msg = nil;
    self.m_maxMsg = nil;
    self.m_curMsg = nil;
    self.m_curFlag = nil;
    self.m_conectOk = nil;
    self.m_root_layer = nil;
    self.m_itemBtn = nil;
    self.m_closeBtn = nil;
    self.m_chatBtnPress = nil;
    self.m_scroll_view = nil;
    self.m_showDataTab = nil;
    self.m_list_view_bg = nil;
    self.m_editUserChanged = nil;
    self.m_popUi = nil;
    self.m_sendToName = nil;
    self.m_ownUID = nil;
    self.m_share_btn_layer = nil;
    self.m_tempData = nil;
    self.m_openType = nil;
    self.m_sendToUid = nil;
    self.m_node_myicon = nil;
    self.m_node_chatother_board = nil;
    self.m_node_inputchat_board = nil;
    self.m_chatState = nil;
    self.m_chatOtherInfo = nil;
    self.m_chatObserver = nil;
    self.m_avatarID = nil;
    self.m_comeInChatFriendInfo = nil;
    self.m_editNodeBoard = nil;

    self.m_friendChatSign = nil;
    self.enterType = nil;
    self.m_msg_showtop = nil;
    self.m_last_tableview_y = nil;
    self.m_last_show_msgindex = nil;
    self.m_curShowMsgType = nil;
    self.m_curShowMsgIndex = nil;
    self.m_oneChatCellSize = nil;

    self.m_tableView = nil;

    self.m_chat_types = nil;
    self.m_menu_items = nil;
    self.m_sort_id = nil;
    self.m_last_msgIndex = nil;

    self.m_cur_showType = nil;
    self.m_sign_table = nil;
    self.m_offset_number = nil;
    self.m_cur_chat_table = nil;
    self.m_refreshUI = nil;
    self.m_last_msgNumbers = nil;
    cclog("-----------------ui_chat_pop destroy-----------------2");
end

local topMenuTab = {{title = string_helper.ui_chat_pop.topMenuTab1,type=1},{title = string_helper.ui_chat_pop.topMenuTab2,type=1},{title = string_helper.ui_chat_pop.topMenuTab3,type=1}}
local shieldKeywordTab = string_helper.ui_chat_pop.shieldKeywordTab


local tttype = {
        type1 = {{sort = 1, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}},
        type2 = {{sort = 1, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}, {sort = 4, flag = "guild_war"}},
        type3 = {{sort = 5, flag = "world"}, {sort = 2, flag = "guild"}, {sort = 3, flag = "friend"}},
        type4 = {{sort = 6, flag = "escort"}, {sort = 3, flag = "friend"}},
        type5 = {{sort = 7, flag = "rob"}, {sort = 3, flag = "friend"}},
        type6 = {{sort = 6, flag = "escort"}, {sort = 8, flag = "team"}, {sort = 3, flag = "friend"}},
        type7 = {{sort = 7, flag = "rob"}, {sort = 8, flag = "team"}, {sort = 3, flag = "friend"}},
    }

local tabPosYs = {
    pos1 = {72},
    pos2 = {70, 38},
    pos3 = {72, 39, 6},
    pos4 = {75, 50, 25, 1},
}

local typeTitles = string_helper.ui_chat_pop.typeTitles

local tipsFlag = 
{
    friend = { friend = true, world = true},
    guild = { guild = true, world = true},
}


local menuType = 
{
    type1 = {{item = "card" }, { item = "equip"}, {item = "share"} , {item = "voice"} },
    type2 = {{item = "card" }, { item = "equip"}, {item = "share"} , {item = "voice"} },
    type3 = {{item = "card" }, { item = "equip"}, {item = "share"} , {item = "voice"} },
    type4 = {{item = "card" }, { item = "equip"}, {item = "share"} , {item = "voice"} },
    type5 = {{item = "card" }, { item = "equip"}, {item = "share"} , {item = "voice"} },
    type6 = {{item = "voice"}, { item = "invite" }},
    type7 = {{item = "voice"}, { item = "invite" }},
}

local menuTitles = string_helper.ui_chat_pop.menuTitles

--[[--
    初始化
]]
function ui_chat_pop.back( self )
    -- assert(false)
    if self.m_chatObserver  then
        self.m_chatObserver:setChatState("not_ui_chat_pop")
        self.m_chatObserver:removeOneLinster( "ui_chat_pop" )
    end
    game_data:removeChatLinster( "ui_chat_pop" )
    
    if self.enterType == 2 then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外围战布阵开启
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                --布阵的话进入布阵界面
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公会战战中   布阵
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing")
            elseif sort == 2 then--外围战战争开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--内城布阵开始
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公会战战中   布阵
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing")
            elseif sort == 4 then--内城战开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公会战未开启
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                -- game_scene:addPop("game_gvg_end_pop",{callFunc = nil,enterType = "win"})
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
    else
        game_scene:removePopByName("ui_chat_pop");
        self:destroy()
    end
end

--[[--
    读取ccbi创建ui
]]
function ui_chat_pop.createUi(self)
    -- body
    self.m_ccbNode = luaCCBNode:create();
    local function onCancel(target,event)
        -- body
        self:back()
    end

    local function onOk(target,event)
        self.m_share_btn_layer:setVisible(false);
        local tempstr = self.m_editNode:getText();
        -- cclog2(tempstr, "tempstr  =====  ")
        local sendToUid = self.m_sendToUid;
        local function sendData()
            local tempData = nil
            local userStatusData = game_data:getUserStatusData();
            if(self.m_curFlag == 'world')then       -- 世界
                tempData = {kqgFlag = "world",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            elseif(self.m_curFlag == 'guild')then   -- 工会
                tempData = {kqgFlag = "guild",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData,association_id = userStatusData.association_id}
            elseif(self.m_curFlag == 'friend')then   -- 好友
                tempData = {kqgFlag = "friend",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData, sendToUid = self.m_chatOtherInfo.uid ,sendToName = self.m_chatOtherInfo.name}
            elseif (self.m_curFlag == 'guild_war') then  -- 世界争霸
                tempData = {kqgFlag = "guild_war",show_name = userStatusData.show_name,
                uid = userStatusData.uid,inputStr = tempstr,
                data = self.m_tempData, 
                guildName = game_data:updateGuildName()
            }
            elseif(self.m_curFlag == 'outdoor')then       -- 外域
                tempData = {kqgFlag = "outdoor",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            elseif(self.m_curFlag == 'escort')then       -- 押镖
                tempData = {kqgFlag = "escort",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            elseif(self.m_curFlag == 'rob')then       -- 打劫
                tempData = {kqgFlag = "rob",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            elseif (self.m_curFlag == 'team')then  -- 组队   
                tempData = {kqgFlag = "team" ,show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            else
                tempData = {kqgFlag = self.m_curFlag,show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = self.m_tempData}
            end
            
            if self.m_chatObserver:sendOneChat( tempData ) then
                self.m_editNode:setText("");
                self.m_tempData = {};
            end
        end
        -- cclog2(self.m_curFlag, "self.m_curFlag  ===   ")
        if self.m_curFlag == "friend" then
            if self.m_chatOtherInfo and self.m_chatOtherInfo.uid == nil or sendToUid == "" then
                game_util:addMoveTips({text = string_helper.ui_chat_pop.inputUid});
                return
            end
            if tempstr == nil or tempstr == "" then 
                self.m_tempData = {};
                game_util:addMoveTips({text = string_helper.ui_chat_pop.inputWord});
                return 
            end
            -- if self.m_editUserChanged == true then
            --     local function responseMethod(tag,gameData)
            --         self.m_editUserChanged = false;
            --         self.m_sendToName = gameData:getNodeWithKey("data"):getNodeWithKey("name"):toStr();
            --         cclog("self.m_sendToName ====== " .. self.m_sendToName)
            --     end 
            --     local params = {};
            --     params.uid = self.m_chatOtherInfo.uid;
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
            -- else
                sendData();
            -- end
        else
            if self.m_curFlag == "guild" or self.m_curFlag == "guild_war" then
                local association_id = game_data:getUserStatusDataByKey("association_id");
                if association_id == 0 then--无联盟
                    game_util:addMoveTips({text = string_helper.ui_chat_pop.guildTips});
                    return;
                end
            end
            if tempstr == nil or tempstr == "" then 
                self.m_tempData = {};
                game_util:addMoveTips({text = string_helper.ui_chat_pop.inputTips});
                return 
            end

            local level = game_data:getUserStatusDataByKey("level") or 0
            local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
            local tips_msg = string_helper.ui_chat_pop.level20
            if game_data:isViewOpenByID(101) then
                tips_msg = string_helper.ui_chat_pop.noVip .. tips_msg
            end
            if level < 20 and vipLevel < 1 then
                game_util:addMoveTips({text = tips_msg});
                return
            end
            sendData();
            game_data:updateChatTime(self.m_curFlag)
        end
    end


    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1001  then  -- 选择头像
            local endCallFun = function (  )
                self:refreshUi()
            end
            game_scene:addPop("ui_chat_showavatars_pop", {endCallFun = endCallFun})
        else
            self:setSelectTabBtn(btnTag - 200);
            self.m_share_btn_layer:setVisible(false);
        end
    end
    local function onBagCallBack( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self.m_share_btn_layer:setVisible(false);
        cclog2(btnTag, "btnTag == ")
        local menu_key = self.m_menu_items[ btnTag ] and self.m_menu_items[ btnTag ].item
        cclog2(menu_key, "menu_key == ")
        if menu_key == "card" then
            -- 卡牌
            self:addSelHeroUi();
        elseif menu_key == "equip" then
            -- 装备
            self:addSelEquipUi();
        elseif menu_key == "item" then
            -- 道具
            self:addSelItemUi();
        elseif  menu_key == "share"  then
            -- 分享
            self:addSelBattleInfoUi();
        elseif  menu_key == "invite"  then
            -- 邀请
            self:sendTeamInvite();
        elseif  menu_key == "voice"  then
            --语音
            local function voiceStart(table)
                print("lua voiceStart -------------------------")
                local voiceResult = table.voiceResult
                CCLuaLog(voiceResult)
                self.m_editNode:setText(voiceResult);
            end
            require("shared.voice_helper").voiceStart(voiceStart)
        end
    end
    local function itemBtnPress(target,event)
        self.m_share_btn_layer:setVisible(not self.m_share_btn_layer:isVisible())
    end
    self.m_ccbNode:registerFunctionWithFuncName("closeBtnPress",onCancel);
    self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    self.m_ccbNode:registerFunctionWithFuncName("chatBtnPress",onOk);
    self.m_ccbNode:registerFunctionWithFuncName("onBagCallBack",onBagCallBack);
    self.m_ccbNode:registerFunctionWithFuncName("itemBtnPress",itemBtnPress);
    self.m_ccbNode:openCCBFile("ccb/ui_chat2.ccbi");

    self.m_node_chatother_board = self.m_ccbNode:nodeForName("m_node_chatother_board")
    self.m_node_chatother_board:setVisible(false)
    self.m_node_inputchat_board = self.m_ccbNode:nodeForName("m_node_inputchat_board")

    local tempEditNode = self.m_ccbNode:nodeForName("m_edit")
    self.m_scroll_view = self.m_ccbNode:scrollViewForName("m_scroll_view")
    self.m_closeBtn = self.m_ccbNode:controlButtonForName("m_closeBtn")
    self.m_closeBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_chatBtnPress = self.m_ccbNode:controlButtonForName("m_chatBtnPress")
    self.m_chatBtnPress:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_itemBtn = self.m_ccbNode:controlButtonForName("m_itemBtn")
    self.m_itemBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    self.m_sign_table = {}
    local sortType = self.m_chat_types
    tabPosY = tabPosYs["pos" .. tostring(#sortType)]
    local m_node_tabboar = self.m_ccbNode:nodeForName("m_node_tabboar")
    local node, tempBtn = nil, nil
    for i=1,10 do
        local node = self.m_ccbNode:nodeForName("m_node_chat_tag" .. (i))
        if node and tabPosY[i] == nil then 
            node:setVisible(false)
        elseif node then
            local falg = sortType[i].flag
            node:setPositionY(m_node_tabboar:getContentSize().height * tabPosY[i] * 0.01)
            tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
            if tempBtn then 
                local title = typeTitles[falg]
                local m_tab_label = self.m_ccbNode:labelTTFForName("m_tab_label_" .. i)
                if m_tab_label then m_tab_label:setString(tostring(title)) end
                tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                self.m_sign_table[falg] = game_util:addTipsAnimByType(tempBtn ,9);
                if #sortType == 4 then
                    tempBtn:setPreferredSize(CCSizeMake(45, 48))
                end
                local tempSize = tempBtn:getContentSize()
                if self.m_sign_table[falg] then 
                    self.m_sign_table[falg]:setVisible(false) 
                    self.m_sign_table[falg]:setPosition( tempSize.width*0.2, tempSize.height*0.6)
                end
            end

        end
    end

    -- 输入选项按钮， 卡牌， 装备  道具 .... 
    local voice_btn = nil
    local menu_items = self.m_menu_items

    local posy = 17
    for i=1,10 do
        local node = self.m_ccbNode:controlButtonForName("m_conbtn_item" .. (i))
        if node and menu_items[i] then
            node:setVisible(true)
            node:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
            node:setPositionY(posy)
            posy = posy + 40
            game_util:setCCControlButtonTitle(node, tostring( menuTitles[ menu_items[i].item ] ) )
        elseif node then
            node:setVisible(false)
        end
    end

    self.m_share_btn_layer = self.m_ccbNode:layerForName("m_share_btn_layer")
    self.m_share_btn_layer:setVisible(false);
    self.m_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_list_view_bg = self.m_ccbNode:layerForName("m_list_view_bg")
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
        end
    end
    tempEditNode:removeAllChildrenWithCleanup(true);
    self.m_editNode = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = tempEditNode:getContentSize(),placeHolder=string_helper.ccb.file50,maxLength = 30});
    self.m_editNode:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    self.m_editNode:setOpacity(0)
    tempEditNode:addChild(self.m_editNode);

    self.m_editNodeBoard = tempEditNode

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_share_btn_layer:setVisible(false);
            return true;--intercept event
        end
    end
    self.m_root_layer = self.m_ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 4,true);
    self.m_root_layer:setTouchEnabled(true);
    


    -- 切换头像
    local m_conbtn_selectavatar = self.m_ccbNode:controlButtonForName("m_conbtn_selectavatar")
    m_conbtn_selectavatar:setOpacity(0)
    m_conbtn_selectavatar:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    
    game_data:startChat()
    local reciveData = function ( chatData, state, kqgFlags )
        -- cclog2(chatData , "chatData ======== ")
        self:putOut( chatData, kqgFlags )
    end
    self.m_chatObserver = game_data:getChatObserver()            
    self.m_chatObserver:registerOneLinster( reciveData, "ui_chat_pop" )
    self:setShowLabelContent()


    self:setSelectTabBtn(self.m_openType, self.m_comeInChatFriendInfo.uid, self.m_comeInChatFriendInfo.name)

    -- if self.m_curFlag ~= "friend" and (self.m_chatObserver:getFriendChatMessage()) > 0 then
    --     self:setSelectTabBtn(3)
    --     self.m_chatObserver:resetFriendChatSign()
    -- elseif self.m_curFlag == "friend" and self.m_comeInChatFriendInfo then
    --     self.m_chatObserver:resetFriendChatSign()
    --     self:setSelectTabBtn(3, self.m_comeInChatFriendInfo.uid, self.m_comeInChatFriendInfo.name)
    -- else
    --     self:setSelectTabBtn(self.m_openTab)
    --     -- self:setSelectTabBtn(self.m_openType)
    -- end

    
    self.m_chatObserver:setChatState("ui_chat_pop")
    self.m_chatObserver:updateState()

    local m_tab_label_1 = self.m_ccbNode:labelTTFForName("m_tab_label_1")
    m_tab_label_1:setString(string_helper.ccb.text94)
    local m_tab_label_2 = self.m_ccbNode:labelTTFForName("m_tab_label_2")
    m_tab_label_2:setString(string_helper.ccb.text95)
    local m_tab_label_3 = self.m_ccbNode:labelTTFForName("m_tab_label_3")
    m_tab_label_3:setString(string_helper.ccb.text96)
    local m_tab_label_4 = self.m_ccbNode:labelTTFForName("m_tab_label_4")
    m_tab_label_4:setString(string_helper.ccb.text97)
    return self.m_ccbNode;
end

--[[
    -- 私聊
]]
function ui_chat_pop.willChatWithOtherOne( self, uid, name )
    -- cclog2(uid, "uid  ===  ")
    -- cclog2(uid, "name  ===  ")
    self.m_chatOtherInfo = {uid = uid, name = name}
    self.m_curFlag = "friend"
    local size = self.m_node_inputchat_board:getContentSize()
    local lastY = self.m_node_inputchat_board:getPositionY()
    -- self.m_node_inputchat_board:setPositionY(size.height * 0.4)
    -- self.m_editNodeBoard:setPositionY(size.height * 0.5)
    self.m_node_chatother_board:setVisible(true)

    -- if tostring(uid) == tostring( game_data:getUserStatusDataByKey("uid") ) then
    --     name = string_helper.ui_chat_pop.me
    -- end
    local msg = string.format(string_helper.ui_chat_pop.talkTo,(name or "   "))
    for i=1, 2 do
        local labelName = self.m_ccbNode:labelTTFForName("m_label_chatother_" .. i)
        if labelName then
            labelName:setString(msg or "")
        end
    end
end

--[[
    -- 非私聊
]]
function ui_chat_pop.willChatWithOthers( self )
    local size = self.m_node_inputchat_board:getContentSize()
    -- self.m_node_inputchat_board:setPositionY(size.height * 0.5)
    -- self.m_editNodeBoard:setPositionY(size.height * 0.5)
    self.m_node_chatother_board:setVisible(false)
end

--[[--
    刷新ui
]]
function ui_chat_pop.refreshUi(self)
    self.m_node_myicon = self.m_ccbNode:nodeForName("m_node_myicon")
    local vip = game_data:getUserStatusDataByKey("vip") or 0
    local role = game_data:getUserStatusDataByKey("role") or 1

    local avatarID = game_data:updateLocalData("avatar_id")
    if avatarID == "" then
        local role = game_data:getUserStatusDataByKey("role")
        game_data:updateLocalData("avatar_id", tostring(role), true)
        avatarID = game_data:updateLocalData("avatar_id")
    end
    
    local avatar = self:createPlayerAvatar( avatarID, vip, self.m_node_myicon:getContentSize())
    avatar:setScale(0.8)
    avatar:setPosition(self.m_node_myicon:getContentSize().width * 0.5, self.m_node_myicon:getContentSize().height * 0.5)
    if avatar then
        self.m_node_myicon:addChild(avatar)
    end
end

--[[--

]]
function ui_chat_pop.setShowLabelContent(self, byNewChat)
    cclog2("")
    -- self.m_showDataTab = self:updatMsg() or {}; 
    self:updatMsg()
    self:refreshChatMsgView( byNewChat );
end

--[[--

]]
function ui_chat_pop.socketConnect(self)
    self.m_socket:cocos_connect(chat_ip,chat_port);
end

--[[--

]]
function ui_chat_pop.setSelectTabBtn(self,sortIndex,  uid, name)
    self.m_sort_id = sortIndex
    -- cclog2(sortIndex, "sortIndex  ======   ")
    local sortType = self.m_chat_types[sortIndex]
    -- cclog2(sortType, "setSelectTabBtn   +   sortType  ++++++  ")
    if not sortType then return end
    local sortT = sortType["sort"]
    local flag = sortType["flag"]
    local canChat = true

    -- cclog2(sortT, "sortType  ======  ")
        
    -- if self.m_openType == 5 and sortIndex == 1 then
    --     self:willChatWithOthers()
    -- else
    if sortT == 1 then
        cclog("-------------------onWorldCallBack");
        self:willChatWithOthers()
    elseif sortT == 2 then
        cclog("-------------------onGuildCallBack");
        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then--无联盟
            game_util:addMoveTips({text = string_helper.ui_chat_pop.guildTips});
            return
        end
        self:setShowLabelContent();
    elseif sortT == 3 then
        -- body
        cclog("-------------------onFriendCallBack");
        -- cclog2()
        if not uid or not name then
            local lastFriendChat = self.m_chatObserver:getLastFriendChatMessage()
            if lastFriendChat then
                local myuid = game_data:getUserStatusDataByKey("uid")
                if tostring(lastFriendChat.uid) ~= tostring(myuid) then
                    uid = lastFriendChat.uid
                    name = lastFriendChat.user
                else
                    uid = lastFriendChat.sendToUid
                    name = lastFriendChat.sendToName
                end
            else
                game_util:addMoveTips({text = string_helper.ui_chat_pop.whisper});
                return 
            end
        end
        self:willChatWithOtherOne( uid, name)
    elseif sortT == 4 then
        cclog("-------------------onGuildCallBack");
        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then--无联盟
            game_util:addMoveTips({text = string_helper.ui_chat_pop.guildTips});
            return
        end
    elseif sortT == 5 then  -- 外域世界
        self:willChatWithOthers()
    elseif sortT == 6 then  -- 押镖
        self:willChatWithOthers()
    elseif sortT == 7 then  -- 劫镖
        self:willChatWithOthers()
    end
    -- cclog2(self.m_curFlag, "self.m_curFlag ======  ")

    self.m_curFlag = flag;

    if self.m_sign_table[flag] then self.m_sign_table[flag]:setVisible(false) end

    self:refreshTabBtn(sortIndex)
    self:setShowLabelContent();

end

--[[
    和好友聊天
]]
function ui_chat_pop.chatWithFriend( self, uid, name )
    cclog("-------------------onFriendCallBack");
    if self.m_friendChatSign then
        self.m_friendChatSign:removeFromParentAndCleanup(true)
        self.m_friendChatSign = nil
    end
    if not uid or not name then
        local lastFriendChat = self.m_chatObserver:getLastFriendChatMessage()
        if lastFriendChat then
            local myuid = game_data:getUserStatusDataByKey("uid")
            if tostring(lastFriendChat.uid) ~= tostring(myuid) then
                uid = lastFriendChat.uid
                name = lastFriendChat.user
            else
                uid = lastFriendChat.sendToUid
                name = lastFriendChat.sendToName
            end
        else
            game_util:addMoveTips({text = string_helper.ui_chat_pop.whisper});
            return 
        end
    end
    self.m_curFlag = "friend";
    self:willChatWithOtherOne( uid, name)
    self:setShowLabelContent();
end

--[[
    和好友聊天
]]
function ui_chat_pop.chatWithFriend( self, uid, name )
    cclog("-------------------onFriendCallBack");
    if self.m_friendChatSign then
        self.m_friendChatSign:removeFromParentAndCleanup(true)
        self.m_friendChatSign = nil
    end
    if not uid or not name then
        local lastFriendChat = self.m_chatObserver:getLastFriendChatMessage()
        if lastFriendChat then
            local myuid = game_data:getUserStatusDataByKey("uid")
            if tostring(lastFriendChat.uid) ~= tostring(myuid) then
                uid = lastFriendChat.uid
                name = lastFriendChat.user
            else
                uid = lastFriendChat.sendToUid
                name = lastFriendChat.sendToName
            end
        else
            game_util:addMoveTips({text = string_helper.ui_chat_pop.whisper});
            return 
        end
    end
    self.m_curFlag = "friend";
    self:willChatWithOtherOne( uid, name)
    self:setShowLabelContent();
end



--[[
    聊天
]]
function ui_chat_pop.chatWithGuild( self )
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then--无联盟
        game_util:addMoveTips({text = string_helper.ui_chat_pop.guildTips});
        return false
    end
    return true
end

--[[--

]]
function ui_chat_pop.refreshTabBtn(self,sortIndex)
    local tempBtn = nil;
    self.m_last_msgNumbers = {}
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        tempBtn:setHighlighted(sortIndex == i);
        tempBtn:setEnabled(sortIndex ~= i);
    end
end

function ui_chat_pop:setButtonTitle(str)
    -- self.m_itemBtn:setTitleForState(CCString:create(str),1)
	-- btn:setTitleForState(CCString:create(str),0.1)
	-- btn:setTitleForState(CCString:create(str),0.01)
	-- btn:setTitleForState(CCString:create(str),0.001)
end

function ui_chat_pop:putOut( chatData, kqgFlags )
    -- cclog2(chatData, "ui_chat_pop:putOut  ======   ")
    -- cclog2(self.m_curFlag, "self.m_curFlag   =====   ")
    kqgFlags = kqgFlags or {}
    kqgFlags = util.table_copy(kqgFlags)
    -- cclog2(kqgFlags, "kqgFlags ======= " )
    local flag = kqgFlags[ self.m_curFlag ]
    if chatData then
        -- cclog2(kqgFlags, " per kqgFlags  ====  1 ")
        local tips = tipsFlag[ self.m_curFlag ] or {}
        for k,v in pairs(tips) do   -- 当前显示的标签 能包括哪几个标签里面的信息  例如，当前标签好友， 有好友消息时，世界标签不会有提示
            if k ~= self.m_curFlag then kqgFlags[k] = false end
        end
        -- cclog2(kqgFlags, "kqgFlags ======= " )
        -- cclog2(kqgFlags, "  kqgFlags  ====  2 ")
        -- 一般情况  当前标签不显示提示
        kqgFlags[ self.m_curFlag ] = false
        -- cclog2(kqgFlags, "  kqgFlags  ====  3 ")
        for k,v in pairs( self.m_sign_table ) do
            if v then 
                local showFlag = false
                if kqgFlags[ k ] == true then   --  标签应当有提示
                    showFlag = true   -- 显示提示
                else
                    showFlag = false  -- 隐藏提示
                end
                -- cclog2(showFlag, "showFlag  ====   ")
                v:setVisible( showFlag ) 
            end
        end
        if flag == true then 
            self:setShowLabelContent();
            -- self:updatMsg()
        end
    end
end



function ui_chat_pop:checkMsgContent( msg )
    
end

--[[--
    创建消息列表
]]
function ui_chat_pop.createTableView(self,viewSize)
    -- local showData = self.m_showDataTab and util.table_copy(self.m_showDataTab) or {};
    local showData = self.m_showDataTab
    local function menuItemClickFun(richLabel,menuItemTag)
        local tag = richLabel:getTag();
        local itemData = showData[tag + 1]
        local clickTab = itemData.clickTab;
        local posIndex = menuItemTag - 524288 + 1;
        cclog("menuItemClickFun menuItemTag === " .. menuItemTag .. " ; tag == " .. tag)
        if true then
            local tempData = clickTab[posIndex];
            if tempData then
                cclog("end == " .. tempData.typeName)
                if tempData.typeName == "card" then
                    game_scene:addPop("game_hero_info_pop",{tGameData = tempData.data,openType = 3 , callBack = function ( ) cclog(string_helper.ui_chat_pop.backChat)end})
                elseif tempData.typeName == "equip" then
                    game_scene:addPop("game_equip_info_pop",{tGameData = tempData.data});
                elseif tempData.typeName == "show" then
                    local function responseMethod(tag,gameData)
                        game_data:setBattleType("game_main_scene_chat_pop");
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                        self:back();
                    end
                    local tempkey = tempData.data;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
                elseif tempData.typeName == "dart_invite" then
                    -- game_util:addMoveTips({text = " 想要加入这个队伍呢 =====" .. tostring(tempData.data) });
                    self:addSharedTeam(itemData)
                elseif tempData.typeName == "like" then
                    game_util:addMoveTips({text = string_helper.ui_chat_pop.like});
                end
            end
        end
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local playerInfo = showData[btnTag + 1]
        if playerInfo then
            local backChatFun = function ( other_uid, other_name )
                local tag = self:getTabIdByFlag("friend", true) 
                if tag then
                    self:setSelectTabBtn(tag, other_uid, other_name)
                end
            end
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_chat_playerinfo_pop",{gameData = gameData, backChatFun = backChatFun, playerInfo = playerInfo})
            end
            local params = {};
            params.uid = playerInfo.uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
        end
    end


    local function onBagCallBack( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag + 1] 
        if itemData then
            local tempData = itemData.clickTab or {}
             for k,v in pairs(tempData) do
                if v.typeName == "dart_invite" then
                    -- game_util:addMoveTips({text = " 想要加入这个队伍呢 =====" .. tostring(v.data) });
                    self:addSharedTeam(itemData)
                    break
                end
            end
        end
    end

    cclog2(self.m_chatObserver:isCanRequestHistoruChatLog( self.m_curFlag ), "self.m_chatObserver:isCanRequestHistoruChatLog( self.m_curFlag )  =====   ")
    -- cclog2(showData[1], "showData[1] =====  ")
    if self.m_chatObserver:isCanRequestHistoruChatLog( self.m_curFlag ) == true then 
        if not showData[1] then  showData[1] = {msg_type = "top", msg = string_helper.ui_chat_pop.lookMore} end
        if showData[1].msg_type ~= "top" then
            table.insert(showData, 1, {msg_type = "top", msg = string_helper.ui_chat_pop.lookMore})
        end
    else
        if showData[1] and showData[1].msg_type == "top" then
            -- table.remove(showData, 1)
             showData[1].msg = string_helper.ui_chat_pop.noMore
        end
    end
    -- cclog2(showData, "showData ======= ")

    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_oneChatCellSize = itemSize
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onBagCallBack",onBagCallBack);
            ccbNode:openCCBFile("ccb/ui_chat_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            cell:addChild(ccbNode, 10, 10)



            local m_conbtn_otherevent = ccbNode:controlButtonForName("m_conbtn_otherevent")
            if m_conbtn_otherevent then
                m_conbtn_otherevent:setOpacity(200)
                m_conbtn_otherevent:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
                game_util:setCCControlButtonTitle(m_conbtn_otherevent,string_helper.ccb.text104)
            end

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            self:initChatCellInfo(ccbNode, index, showData , onBtnCilck , menuItemClickFun)
        end

        -- end
        -- if cell then
        --     cell:removeAllChildrenWithCleanup(true)
        --     local itemData = showData[index + 1];
        --     local showMsg = itemData.user .. ":" .. itemData.content;
        --     -- cclog("showMsg == " .. showMsg)
        --     local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,color = ccc3(221,221,192),fontSize = 15})
        --     chatMsgLabel:setAnchorPoint(ccp(0, 0));
        --     cell:addChild(chatMsgLabel);
        --     chatMsgLabel:registerScriptTapHandler(menuItemClickFun);
        --     chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY);
        --     chatMsgLabel:setTag(index);
        -- end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        -- cclog2(self.m_tableView:getContentOffset().y, "self.m_tableView:getContentOffset().y  =====  ")
        if self.m_sign_table[ self.m_curFlag ] then self.m_sign_table[ self.m_curFlag ]:setVisible(false) end
        if eventType == "ended" then
            local itemData = showData[index + 1] or {}
            -- cclog2(itemData, "itemData ======")

            if itemData.msg_type == "top" then
                -- self:updatMsg()
            --     -- self.m_curShowMsgType = "history"
                self.m_chatObserver:requestHistoryChatLog( self.m_curFlag )
                self:refreshChatMsgView( false )

            --     -- self.m_last_tableview_y = self.m_tableView:getContentOffset().y
            --     self:refreshChatMsgView()
            -- elseif self.m_refreshUI == true then 
            --     self:refreshChatMsgView()

            end
        end
    end
    return TableViewHelper:create(params);
end


--[[
    获取当前显示的条目index
]]
function ui_chat_pop.getCurMsgIndex( self )
    if not self.m_tableView then return nil end
    local offsetY = self.m_tableView:getContentOffset().y
    local viewSizeHeight = self.m_tableView:getViewSize().height
    local cSizeHeight = self.m_tableView:getContentSize().height
    local oneCellHeight = self.m_oneChatCellSize and self.m_oneChatCellSize.height or 50
    -- cclog2(oneCellHeight, "oneCellHeight  =====   ")
    -- cclog2(viewSizeHeight, "viewSizeHeight  =====   ")
    -- cclog2(cSizeHeight, "cSizeHeight  =====   ")
    -- cclog2(offsetY, "offsetY  =====   ")
    local roughCount = offsetY * -1.0 / oneCellHeight
    return math.floor(roughCount)
end


function ui_chat_pop.initChatCellInfo( self, ccbNode, cellIndex , showData, btnCallFun , menuItemClickFun)
    showData = showData or {}
    -- cclog2(cellIndex, "cellIndex   =======================   ")
    -- cclog2( #self.m_showDataTab, " #self.m_showDataTab  =====   ")
    if not ccbNode then return end
    ccbNode:setPositionY(ccbNode:getContentSize().height * 0.5)

    local itemData = showData[cellIndex + 1] or {}
    local m_scale9_linebottom = ccbNode:nodeForName("m_scale9_linebottom")
    local m_scale9_linetop = ccbNode:nodeForName("m_scale9_linetop")

    if cellIndex == 0 then
        m_scale9_linetop:setVisible(false)
        m_scale9_linebottom:setVisible(false)
    elseif cellIndex == #self.m_showDataTab - 1 then
        m_scale9_linetop:setVisible(false)
        m_scale9_linebottom:setVisible(true)
    else
        m_scale9_linetop:setVisible(true)
        m_scale9_linebottom:setVisible(true)
    end

    local m_label_date = ccbNode:labelTTFForName("m_label_date")
    if itemData.date and m_label_date then
        m_label_date:setVisible(true)
        m_label_date:setString(tostring(itemData.date))
    elseif m_label_date then
        m_label_date:setVisible(false)
    end 


    print(ccbNode:getPosition())
    -- cclog2("position     ============")
    local showMsg = itemData and (itemData.content or "") or "~~~~~~~~~";
    local vipLevel = itemData.vip or 0
    local m_msg_back_board1 = ccbNode:nodeForName("m_msg_back_board1")
    local m_msg_back_board2 = ccbNode:nodeForName("m_msg_back_board2")
    local m_msg_back_board3 = ccbNode:nodeForName("m_msg_back_board3")
    if m_msg_back_board3 then
        m_msg_back_board3:setVisible(false)
    end
    if itemData.msg_type == "top" then
        m_msg_back_board1:setVisible(false)
        m_msg_back_board2:setVisible(true)
        local m_label_moreinfo = ccbNode:labelTTFForName("m_label_moreinfo")
        if m_label_moreinfo then
            m_label_moreinfo:setString(tostring(itemData.msg))
        end
        return
    end

    m_msg_back_board1:setVisible(true)
    m_msg_back_board2:setVisible(false)

    -- cclog2(itemData, "itemData ======   ")

    if itemData.inviteFlag == true and m_msg_back_board3 then
        local uid = game_data:getUserStatusDataByKey("uid") or ""
        if tostring(itemData.uid) ~= tostring(uid) then
            m_msg_back_board3:setVisible(true)
        end
    end

    local m_node_avatarboard = ccbNode:nodeForName("m_node_avatarboard")
    local m_sprite_vipsign = ccbNode:spriteForName("m_sprite_vipsign")
    local m_node_msgboard = ccbNode:nodeForName("m_node_msgboard")
    local m_sprite_vipsignBottom = ccbNode:spriteForName("m_sprite_vipsignBottom")

    local m_other_nameboard = ccbNode:nodeForName("m_other_nameboard")
    m_other_nameboard:setVisible(false)


    local m_node_guildnameboard = ccbNode:nodeForName("m_node_guildnameboard")
    m_node_guildnameboard:setVisible(false)

    --
    if itemData.kqgFlag == "friend" then
        m_other_nameboard:setVisible(true)
        for i=1,2 do
            local label = ccbNode:labelTTFForName("m_label_othername_" .. i)
            local name = itemData.sendToName or ""
            if tostring(itemData.sendToUid) == tostring( game_data:getUserStatusDataByKey("uid") ) then
                name = string_helper.ui_chat_pop.me
            end
            local msg = name ~= "" and string.format(string_helper.ui_chat_pop.talkTo,name) or ""
            if label then
                label:setString(msg or "")
            end
        end
    end

    -- 工会战
    -- cclog2(itemData.kqgFlag, "itemData.kqgFlag  ===  ")
    if itemData.kqgFlag == "guild_war" then
        m_node_guildnameboard:setVisible(true)
        for i=1,2 do
            local label = ccbNode:labelTTFForName("m_label_guildname_" .. i)
            local msg = itemData.guildName or ""
            if label then
                label:setString(msg or "")
            end
        end
    end

    -- 时间
    local labelTime = ccbNode:labelTTFForName("m_label_time")
    local time = itemData.dsign and os.date("%H:%M", math.floor(tonumber(itemData.dsign))) or ""
    labelTime:setString(time)
    -- 人物等级
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_level_" .. i)
        if label then 
            label:setString(itemData.level  or "?")
        end
    end
    -- 昵称
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_name_" .. i)
        if label then 
            label:setString(itemData.user  or "")
            label:setColor(ccc3(0,255,0))
        end
    end


    m_node_msgboard:removeAllChildrenWithCleanup(true)
    if m_node_avatarboard:getChildByTag(998) then
        m_node_avatarboard:removeChildByTag(998,true)
    end 
    local size = m_node_msgboard:getContentSize()
    local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg or "",dimensions = CCSizeMake(size.width,0),
        textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentTop,color = ccc3(221,221,192),fontSize = 10})
    chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY - 6)
    chatMsgLabel:setAnchorPoint(ccp(0, 0.5));
    chatMsgLabel:setPositionY(size.height * 0.5)
    chatMsgLabel:registerScriptTapHandler(menuItemClickFun);
    m_node_msgboard:addChild(chatMsgLabel,0, cellIndex)

    -- 设置vip标志
    if game_data:isViewOpenByID(101) and vipLevel > 0 then
        m_sprite_vipsign:setVisible(true)
        m_sprite_vipsignBottom:setVisible(true)
    else 
        m_sprite_vipsign:setVisible(false)
        m_sprite_vipsignBottom:setVisible(false)
    end

    local asize = m_node_avatarboard:getContentSize()
    local avatar = self:createPlayerAvatar(itemData.avatarID, itemData.vip, asize)
    if avatar then
        avatar:setPosition(asize.width * 0.5, asize.height * 0.5)
        m_node_avatarboard:addChild(avatar, -1, 998)
        self:createAMainButton( avatar, btnCallFun, "public_weapon.png", cellIndex)
        avatar:setScale(0.7)
    end    

    local m_conbtn_otherevent = ccbNode:controlButtonForName("m_conbtn_otherevent")
    if m_conbtn_otherevent then
        m_conbtn_otherevent:setTag( cellIndex  )
    end

   

end

--[[--
    创建一个button
]]
function ui_chat_pop.createAMainButton( self, parent, onBtnCilck, spriteName, tag )
    local button = game_util:createCCControlButton(spriteName,"",onBtnCilck)
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPositionY(parent:getContentSize().height * 0.5)
    button:setPositionX(parent:getContentSize().width * 0.5)
    parent:addChild(button)
    button:setTag(tag)
    button:setOpacity(0)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    return button
end
function ui_chat_pop.createPlayerAvatar( self, avatarID, vipLevel, avatarSize )

    local face_cfg = getConfig(game_config_field.face_icon)
    local avatarName  = "icon_ironman.png"
    if face_cfg then
        local avatarInfo =  face_cfg:getNodeWithKey( tostring(avatarID) )
        avatarName = avatarInfo and avatarInfo:getNodeWithKey("icon") and avatarInfo:getNodeWithKey("icon"):toStr() 
    end

    local avatar = game_util:createIconByName(avatarName or "icon_ironman.png")
    local asize = avatarSize 
    if avatar then
        local qualityTab = HERO_QUALITY_COLOR_TABLE[4]
        if vipLevel and vipLevel > 0 then
            qualityTab = HERO_QUALITY_COLOR_TABLE[7]
        end 
        local tempIconSize = avatar:getContentSize();
        local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
        img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        avatar:addChild(img1,-1,1)
        local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
        img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        avatar:addChild(img2,1,2)
    end    
    return avatar
end



--[[--
    刷新
]]
function ui_chat_pop.refreshScrollView(self)
    local viewSize = self.m_scroll_view:getViewSize();
    local container = self.m_scroll_view:getContainer();
    container:removeAllChildrenWithCleanup(true);
    local showData = self.m_showDataTab or {};

    local function menuItemClickFun(richLabel,menuItemTag,menuItem)
        local tag = richLabel:getTag();
        local itemData = showData[tag + 1]
        local clickTab = itemData.clickTab;
        local posIndex = menuItemTag - 524288 + 1;
        local tempData = clickTab[posIndex];
        if tempData then
            cclog("tempData.typeName == " .. tempData.typeName)
            if tempData.typeName == "card" then
                game_scene:addPop("game_hero_info_pop",{tGameData = tempData.data,openType = 3 , callBack = function ( ) cclog(string_helper.ui_chat_pop.backChat)end})
            elseif tempData.typeName == "equip" then
                game_scene:addPop("game_equip_info_pop",{tGameData = tempData.data});
            elseif tempData.typeName == "user" then
                local uid = tostring(tempData.data.uid)
                local name = tostring(tempData.data.name)
                -- cclog2(tempData.data, "tempData.data  ===  ")
                local function menuPopCallFunc(tempTag)
                    game_scene:removePopByName("game_menu_pop")
                    if tempTag == 1 then
                        local function responseMethod(tag,gameData)
                            game_scene:addPop("game_player_info_pop",{gameData = gameData})
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = uid},"user_info")
                    elseif tempTag == 2 then
                        if uid == self.m_ownUID then
                            game_util:addMoveTips({text = string_helper.ui_chat_pop.talkToMe});
                            return;
                        end
                        self.m_sendToName = tempData.data.name
                        self.m_editUserNode:setText(uid);
                        local tag = self:getTabIdByFlag("friend", true) 
                        if tag then
                            self:setSelectTabBtn( tag );
                        end
                    elseif tempTag == 3 then
                        if uid == self.m_ownUID then
                            game_util:addMoveTips({text = string_helper.ui_chat_pop.addSelf});
                            return;
                        end
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local msg = string_config:getTextByKeyAndReplaceOne("friend_send_add_friedn_tips", "PLAYER", name)
                            game_util:addMoveTips({text = msg});
                        end
                        local params = {};
                        params.target_id = uid
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_apply_friend"), http_request_method.GET, params,"friend_apply_friend")
                    elseif tempTag == 4 then
                        if uid == self.m_ownUID then
                            game_util:addMoveTips({text = string_helper.ui_chat_pop.inviteDeny});
                            return;
                        end
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local msg = string_config:getTextByKeyAndReplaceOne("guild_send_invite_tips", "PLAYER", name or string_helper.ui_chat_pop.other)
                            game_util:addMoveTips({text = msg});
                        end
                        local params = {};
                        params.target_id = uid
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
                    end
                end
                local px,py = menuItem:getPosition();
                local itemSize = menuItem:getContentSize();
                local pos = menuItem:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5 - 8));
                -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
                if true then 
                    topMenuTab[#topMenuTab + 1] = {title = string_helper.ui_chat_pop.guildInvite,type=1}
                end
                game_scene:addPop("game_menu_pop",{menuTab = topMenuTab,pos = pos,callFunc = menuPopCallFunc});
                if true then 
                    topMenuTab[#topMenuTab] = nil
                end
            end
        end
        cclog("menuItemClickFun menuItemTag === " .. menuItemTag .. " ; tag == " .. tag)
    end
    local totalHeight = 0;
    local chatMsgLabelTab = {};
    for index=1,#showData do
        local itemData = showData[index];
        local showMsg = itemData.user .. ":" .. itemData.content;
        
        local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,
            color = ccc3(255,255,0),fontSize = 15})
        chatMsgLabel:setAnchorPoint(ccp(0, 0));
        -- chatMsgLabel:setHorizontalAlignment(kCCTextAlignmentLeft);
        self.m_scroll_view:addChild(chatMsgLabel);
        chatMsgLabel:registerScriptTapHandler(menuItemClickFun);
        chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY - 5);
        chatMsgLabel:setTag(index - 1);
        local label_size = chatMsgLabel:getContentSize()
        local line_height = label_size.height
        -- local with = label_size.width;
        -- local w = viewSize.width;
        -- local line = with%w == 0 and with/w or math.floor(with/w + 1);
        -- local tempHieght = math.max(1,line) * line_height
        -- if itemData.kqgFlag == "system" then
        --     tempHieght = line_height;
        -- end
        -- cclog("line ===== " .. line .. " ; line_height == " .. line_height .. " ; tempHieght == " .. tempHieght)
        local tempHieght = line_height;
        totalHeight = totalHeight + tempHieght + 3;
        -- chatMsgLabel:setDimensions(CCSizeMake(w, tempHieght))
        chatMsgLabelTab[index] = {label = chatMsgLabel,height = tempHieght};
    end

    
    local contentSize = CCSizeMake(viewSize.width, math.max(viewSize.height,totalHeight));
    cclog("viewSize.width = " .. viewSize.width .. " viewSize.height = " .. viewSize.height)
    cclog("contentSize.width = " .. contentSize.width .. " contentSize.height = " .. contentSize.height)
    self.m_scroll_view:setContentSize(contentSize);
    if contentSize.height > viewSize.height then
        -- self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - contentSize.height));
        self.m_scroll_view:setContentOffset(ccp(0, 0));
    end
    local tempHeight = 0;
    for index=1,#chatMsgLabelTab do
        local tempData = chatMsgLabelTab[index];
        tempHeight = tempHeight + tempData.height + 3;
        tempData.label:setPositionY(contentSize.height - tempHeight);
    end
end

--[[--
    刷新
]]
function ui_chat_pop.refreshChatMsgView(self, byNewChat)
    if not byNewChat then  byNewChat = true end
    local offsetBlowY = self.m_tableView and self.m_tableView:getContentOffset().y or 0
    -- local index = self:getCurMsgIndex()
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView, 1, 997);
    cclog2(offsetBlowY, "offsetBlowY  ======   ")
    cclog2(self.m_offset_number, "self.m_offset_number   =====   ")
    -- cclog2(index, " cur msg  index  ======   ")

    if offsetBlowY > -3 * self.m_oneChatCellSize.height then
        game_util:setTableViewIndex( #self.m_showDataTab ,self.m_list_view_bg, 997, 4)
    elseif self.m_offset_number and self.m_offset_number > 0 then
        local offsetBlowY = offsetBlowY - self.m_oneChatCellSize.height * self.m_offset_number
        self.m_tableView:setContentOffset(ccp(0, offsetBlowY))
        if self.m_sign_table[ self.m_curFlag ] then self.m_sign_table[ self.m_curFlag ]:setVisible(true) end
        self.m_refreshUI = true
    else
        game_util:setTableViewIndex( #self.m_showDataTab ,self.m_list_view_bg, 997, 4)
    end
    self.m_oneChatCellSize.height = 0 
    local offsetBlowY = self.m_tableView and self.m_tableView:getContentOffset().y or 0
    -- offsetBlowY = math.min(offsetBlowY, self.m_list_view_bg:getContentSize().height - self.m_tableView:getViewSize().height)
    offsetBlowY = math.max(offsetBlowY, -1 * self.m_tableView:getViewSize().height)
    self.m_tableView:setContentOffset(ccp(0, offsetBlowY))

    -- elseif byNewChat then
    --     self.m_tableView:setContentOffset(ccp(0, offsetBlowY - self.m_oneChatCellSize.height))
    --     -- 添加新信息提醒
    -- else
        -- self.m_tableView:setContentOffset(ccp(0, offsetBlowY))
    -- end
end

function ui_chat_pop.updatMsg( self )
	-- body
    if not self.m_chatObserver then 
        return {}
    end
    local historyMsg, curMsg = self.m_chatObserver:getAllChats(self.m_curFlag);
    if not self.m_last_msgNumbers["cur"] or not self.m_last_msgNumbers["history"] then
        self.m_last_msgNumbers["cur"] = self.m_last_msgNumbers["cur"] or 0
        self.m_last_msgNumbers["history"] = self.m_last_msgNumbers["history"] or 0
        refreshFlag = true
    end
    -- cclog2(self.m_last_msgNumbers , "self.m_last_msgNumbers ======== ")
    self.m_offset_number = ( #curMsg - self.m_last_msgNumbers["cur"] )
    -- if #historyMsg < #self.m_history_table then
    --     self.m_offset_number = ( #curMsg - #self.m_cur_chat_table )
    -- else
    --     self.m_offset_number = ( #curMsg - #self.m_cur_chat_table )
    -- end

    local refreshFlag = false
    if self.m_last_msgNumbers["cur"] ~= #curMsg or self.m_last_msgNumbers["history"] ~= #historyMsg then
        refreshFlag = true
    end


    -- self.m_history_table = {}
    -- self.m_cur_chat_table = {}

    -- self.m_history_table = util.table_copy( historyMsg )
    -- self.m_cur_chat_table = util.table_copy( curMsg )
    if refreshFlag then
        self.m_showDataTab = {};
        for i,v in pairs( historyMsg or {} ) do
            if(type(v) == "table") then
                table.insert(self.m_showDataTab, util.table_copy(v))
            end
        end
        for i,v in pairs( curMsg or {} ) do
            if(type(v) == "table") then
                table.insert(self.m_showDataTab, util.table_copy(v))
            end
        end
        self.m_last_msgNumbers["cur"] = #curMsg 
        self.m_last_msgNumbers["history"] = #historyMsg

        for i=1, #self.m_showDataTab - 1 do
            local date1 = os.date("%Y-%m-%d", self.m_showDataTab[i].dsign)
            local date2 = os.date("%Y-%m-%d", self.m_showDataTab[i].dsign)
            if data1 ~= data2 then
                self.m_showDataTab[i + 1].date = date2
            end
        end
        -- if self.m_showDataTab[1] then
        --     self.m_showDataTab[1].date = os.date("%Y-%m-%d", self.m_showDataTab[1].dsign)
        -- end
    end
    -- if refreshFlag then
        -- self:refreshChatMsgView( byNewChat );
    -- end
    -- self:refreshChatMsgView( byNewChat );
    return new_table;
end


--[[--
    卡牌背包
]]
function ui_chat_pop.addSelHeroUi(self)
    local btnCallFunc = function( target,event )
        
    end
    local itemOnClick = function (id)
        if id then
        	local cardData,cardCfg = game_data:getCardDataById(id);
            local cardId = cardData.id;
            local name = cardCfg:getNodeWithKey("name"):toStr();
            if self.m_tempData[name] then return end
            local str = self.m_editNode:getText();
            str = str .. '&' .. name .. '&'
            local tempLen = self:utf8_length(str);
            cclog("tempLen == " .. tempLen .. " ; string.len(str) = " .. string.len(str))
            if tempLen > 20 then
                game_util:addMoveTips({text = string_helper.ui_chat_pop.charBeyond});
                return;
            end
            self.m_tempData[name] = {typeName = "card",data = cardData};
            self.m_editNode:setText(str);
        end
    end
    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick})
end

--[[--
    装备背包
]]
function ui_chat_pop.addSelEquipUi(self)
    local btnCallFunc = function( target,event )

    end
    local itemOnClick = function (id)
        if id then
        	local equipData,equipCfg = game_data:getEquipDataById(id);
            local name = equipCfg:getNodeWithKey("name"):toStr();
            if self.m_tempData[name] then return end
            local str = self.m_editNode:getText();
            str = str .. '&' .. name .. '&'
            local tempLen = self:utf8_length(str);
            cclog("tempLen == " .. tempLen .. " ; string.len(str) = " .. string.len(str))
            if tempLen > 20 then
                game_util:addMoveTips({text = string_helper.ui_chat_pop.charBeyond});
                return;
            end
            self.m_tempData[name] = {typeName = "equip",data = equipData};
            self.m_editNode:setText(str);
        end
    end
    game_scene:addPop("game_equip_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = true})
end

--[[--
    道具背包
]]
function ui_chat_pop.addSelItemUi(self)
    local btnCallFunc = function( target,event )

    end
    local itemOnClick = function (id)
        if id then

        end
    end
    game_scene:addPop("game_item_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick})
end

--[[--
    选择战报
]]
function ui_chat_pop.addSelBattleInfoUi(self)

        local function responseMethod(tag,gameData)
            -- game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            local tdata = gameData and json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
            game_scene:addPop("ui_batter_info_pop",{log_info = tdata.log,openType = 1, isShowShareBtn = "true"});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
end

--[[--
    发送组队邀请
]]
function ui_chat_pop.sendTeamInvite( self )
    local title = "干一票大的"
    if self.m_tempData[title] then return end
    local str = self.m_editNode:getText();
    str = str .. '&' .. title .. '&'
    local tempLen = self:utf8_length(str);
    cclog("tempLen == " .. tempLen .. " ; string.len(str) = " .. string.len(str))
    if tempLen > 20 then
        game_util:addMoveTips({text = string_helper.ui_chat_pop.charBeyond});
        return;
    end
    self.m_tempData[title] = {typeName = "dart_invite", data = "me_123456789" }
    self.m_editNode:setText(str);
end


-- do 
--     local chatOber = game_data:getChatObserver()
--     local show_name = game_data:getUserStatusDataByKey("show_name") or ""
--     local info = " " .. tostring(show_name) .. "击败了世界BOSS，恭喜他" .. "&like&"
--     local tt = {}
--     tt["like"] = {typeName = "like", data = "world_boss"}
--     local chatData = {kqgFlag = "system", inputStr = info , data = tt }
--     local flag =  chatOber:sendOneChat(chatData)

-- end

--[[
    加入队伍
]]
function ui_chat_pop.addSharedTeam( self, chatData )
    local tempUid = chatData.uid
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    -- if uid ~= tempUid then
        local params = {}
        params.captain_uid = tempUid
        if chatData.kqgFlag == "rob" then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                game_util:addMoveTips({text = string_helper.ui_chat_pop.addTeam})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_join_rob_team"), http_request_method.GET, params,"escort_join_rob_team")
        elseif chatData.kqgFlag == "escort" then
            local sel_dart_good = game_data:getDataByKey("sel_dart_good")
            if sel_dart_good then
                local params = {}
                params.goods_id = sel_dart_good.goodId
                params.captain_uid = tempUid
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,identity = 2})
                    game_util:addMoveTips({text = string_helper.ui_chat_pop.addTeam})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_join_goods_team"), http_request_method.GET, params,"escort_join_goods_team")
            end
        end
    -- end
end

--[[
    获取 falg相应的按钮id
]]
function ui_chat_pop.getTabIdByFlag( self, keyFlag, showTips )
    if keyFlag then 
        for k,v in pairs( self.m_chat_types  ) do
            if type(v) == "table" and v.flag == keyFlag then
                return k
            end
        end
    end
    if showTips then
        game_util:addMoveTips({text = string_helper.ui_chat_pop.ChatDeny})
    end
    return nil
end


function ui_chat_pop.utf8_length(self,str)
    local len = 0
    local pos = 1
    local length = string.len(str)
    while true do
        local char = string.sub(str, pos, pos)
        local b = string.byte(char)
        if b >= 128 then
            pos = pos + 3
        else pos = pos + 1
        end len = len + 1
        if pos > length
        then break
        end
    end
    return len
end

function ui_chat_pop.shieldKeywordFunc(self,str)
    for k,v in pairs(shieldKeywordTab) do
        str = string.gsub(str,tostring(v),"***");
    end
    return str;
end

function ui_chat_pop.init(self,t_params)
    t_params = t_params or {}; 
    self.m_editUserChanged = false;
    self.m_ownUID = game_data:getUserStatusDataByKey("uid");
    self.m_msg = {};
    self.m_maxMsg = 16;
    self.m_curMsg = 1;
    self.m_conectOk = false;
    self.m_tempData = {};
    self.m_cur_chat_table = {}
    self.m_history_table = {}
    self.m_showDataTab = {}

    self.m_openType = t_params.openType or 1;
    self.enterType = t_params.enterType or 1
    self.m_last_msgNumbers = {}

    self.m_comeInChatFriendInfo = {uid = t_params.friendUID , name = t_params.friendName }

    -- self.m_openType = 6
    self.m_chat_types = tttype[ "type" .. tostring(self.enterType) ] or {}
    self.m_menu_items = util.table_copy( menuType[ "type" .. tostring(self.enterType) ] ) or {}
    for k,v in pairs(self.m_menu_items) do
        if type(v) == "table" and  v.item == "voice" and not EXTHelper then
            table.remove(self.m_menu_items, k)
            break
        end
    end
end

function ui_chat_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end



return ui_chat_pop;