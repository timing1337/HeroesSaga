require "shared.extern"

local guild_chat_pop_view = class("guildChatPopView",require("like_oo.oo_popBase"));

guild_chat_pop_view.m_ccb = nil;
guild_chat_pop_view.m_tab_btn = {};
guild_chat_pop_view.m_scroll_view = nil;
guild_chat_pop_view.m_editBg = nil;

guild_chat_pop_view.m_edit = nil;


--场景创建函数
function guild_chat_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onMainBtnClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- 201 战场
        -- 202 公会
        self:updataMsg(btnTag);
	end
	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onSend( target,event )
		-- body
		self:updataMsg(4,{m = self.m_edit:getText() , f = self.m_control:getFlag()},"guild_chat");
	end
	self.m_ccb:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onSend",onSend);
	self.m_ccb:openCCBFile("ccb/pop_guild_chat_pop.ccbi");

	for i=1,2 do
		-- 两个tab按钮
		self.m_tab_btn[i] = tolua.cast(self.m_ccb:objectForName("m_tab_btn_" .. tostring(i)),"CCControlButton");
	end

	-- 列表
	self.m_scroll_view = self.m_ccb:scrollViewForName("m_scroll_view");
	-- 输入框背景
	self.m_editBg = tolua.cast(self.m_ccb:objectForName("m_edit"),"CCNode");

    local m_tab_label_1 = self.m_ccb:labelBMFontForName("m_tab_label_1")
    m_tab_label_1:setString(string_helper.ccb.text5)

    local m_tab_label_2 = self.m_ccb:labelBMFontForName("m_tab_label_2")
    m_tab_label_1:setString(string_helper.ccb.text6)
	-- self.m_list_view = self:refreshScrollView();
	-- self.m_list_view_bg:addChild(self.m_list_view);

	local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            -- self.m_guildName = edit:getText();
        end
    end
    self.m_edit = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_editBg:getContentSize(),placeHolder=""});
    self.m_edit:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
	self.m_editBg:addChild(self.m_edit);

	self.m_rootView:addChild(self.m_ccb);


end

function guild_chat_pop_view:onEnter(  )
	-- body
	self:refreshScrollView();
end

function guild_chat_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

--[[--
    刷新
]]
function guild_chat_pop_view:refreshScrollView(  )
    local viewSize = self.m_scroll_view:getViewSize();
    local container = self.m_scroll_view:getContainer();
    container:removeAllChildrenWithCleanup(true);
    local showData = self.m_control:getShowData();

    local function menuItemClickFun(richLabel,menuItemTag,menuItem)
        local tag = richLabel:getTag();
        local itemData = showData[tag + 1]
        local clickTab = itemData.clickTab;
        local posIndex = menuItemTag - 524288 + 1;
        local tempData = clickTab[posIndex];
        if tempData then
            cclog("tempData.typeName == " .. tempData.typeName)
            if tempData.typeName == "card" then
                game_scene:addPop("game_hero_info_pop",{tGameData = tempData.data,openType = 3 , callBack = function ( ) cclog("返回聊天")end})
            elseif tempData.typeName == "equip" then
                game_scene:addPop("game_equip_info_pop",{tGameData = tempData.data});
            elseif tempData.typeName == "user" then
                local uid = tostring(tempData.data.uid)
                local function menuPopCallFunc(tempTag)
                    game_scene:removePopByName("game_menu_pop")
                    if tempTag == 1 then
                        local function responseMethod(tag,gameData)
                            game_scene:addPop("game_player_info_pop",{gameData = gameData})
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = uid},"user_info")
                    elseif tempTag == 2 then
                        if uid == self.m_ownUID then
                            game_util:addMoveTips({text = string_helper.guild_chat_pop.talkToMe});
                            return;
                        end
                        self.m_sendToName = tempData.data.name
                        self.m_editUserNode:setText(uid);
                        self:setSelectTabBtn(3);
                    elseif tempTag == 3 then
                        if uid == self.m_ownUID then
                            game_util:addMoveTips({text = string_helper.guild_chat_pop.addMe});
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
                    end
                end
                local px,py = menuItem:getPosition();
                local itemSize = menuItem:getContentSize();
                local pos = menuItem:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5 - 8));
                -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
                game_scene:addPop("game_menu_pop",{menuTab = topMenuTab,pos = pos,callFunc = menuPopCallFunc});
            end
        end
        cclog("menuItemClickFun menuItemTag === " .. menuItemTag .. " ; tag == " .. tag)
    end
    local totalHeight = 0;
    local chatMsgLabelTab = {};
    for index=1,#showData do
        local itemData = showData[index];
        local showMsg = itemData.user .. ":" .. itemData.content;
        
        local chatMsgLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = nil,textAlignment = nil,verticalTextAlignment = nil,color = ccc3(221,221,192),fontSize = 15})
        chatMsgLabel:setAnchorPoint(ccp(0, 0));
        chatMsgLabel:setHorizontalAlignment(kCCTextAlignmentLeft);
        self.m_scroll_view:addChild(chatMsgLabel);
        chatMsgLabel:registerScriptTapHandler(menuItemClickFun);
        chatMsgLabel:setLinkPriority(GLOBAL_TOUCH_PRIORITY);
        chatMsgLabel:setTag(index - 1);
        local label_size = chatMsgLabel:getContentSize()
        local line_height = label_size.height
        local with = label_size.width;
        local w = viewSize.width;
        local line = with%w == 0 and with/w or math.floor(with/w + 1);
        cclog("line ===== " .. line)
        local tempHieght = math.max(1,line) * line_height
        totalHeight = totalHeight + tempHieght + 3;
        chatMsgLabel:setDimensions(CCSizeMake(w, tempHieght))
        chatMsgLabelTab[index] = {label = chatMsgLabel,height = tempHieght};
    end

    
    local contentSize = CCSizeMake(viewSize.width, math.max(viewSize.height,totalHeight));
    cclog("viewSize.width = " .. viewSize.width .. " viewSize.height = " .. viewSize.height)
    cclog("contentSize.width = " .. contentSize.width .. " contentSize.height = " .. contentSize.height)
    self.m_scroll_view:setContentSize(contentSize);
    self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - contentSize.height));
    local tempHeight = 0;
    for index=1,#chatMsgLabelTab do
        local tempData = chatMsgLabelTab[index];
        tempHeight = tempHeight + tempData.height + 3;
        tempData.label:setPositionY(contentSize.height - tempHeight);
    end
end



return guild_chat_pop_view;