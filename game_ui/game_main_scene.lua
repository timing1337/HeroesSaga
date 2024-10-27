-- 主场景

local game_main_scene = {
    m_ccbNode = nil,
    m_subordinateMenuPop = nil,
    m_resourcesAnimTable = nil,
    m_bottom_btn_node = nil,
    m_right_btn_node = nil,
    m_top_btn_node = nil,
    m_top_btn_node2 = nil,
    m_btnShowFlag = nil,
    m_gainResTime = nil,

    m_formation_btn = nil,
    m_shop_btn = nil,
    m_partner_btn = nil,
    m_chat_btn = nil,
    m_backpack_btn = nil,
    m_more_btn = nil,
    m_reward_btn = nil,
    m_activity_btn = nil,
    m_kfhd_activity_btn = nil;  -- 开服活动
    m_do_something_btn = nil, -- 消息提示按钮
    m_conbtn_levelgift = nil,  -- 等级礼包按钮
    m_ranking_btn = nil,
    m_battle_btn = nil,
    m_announcement_btn = nil,
    m_conbtn_challenge = nil,
    m_team_layer = nil,
    m_teamNodeTab = nil,
    m_combat_label = nil,
    m_gift_btn = nil,--领奖按钮
    m_firstFlag = nil,
    m_chat_node = nil,
    m_battle_btn_bg = nil,
    m_tipsAnimTab = nil,
    m_social_btn = nil,
    m_get_flag = nil,
    m_pp_btn = nil,
    m_pp_btn2 = nil,
    m_task_btn = nil,
    m_guild_btn = nil,
    m_leader_skill_btn = nil,
    m_gacha_btn = nil,
    m_pay_btn = nil,
    m_conbtn_vipshow_btn = nil,
    m_daily_task_btn = nil,
    m_award_btn = nil,
    m_conbtn_limit_score_btn = nil,
    m_limit_btn = nil,
    m_conbtn_secreary = nil,
    m_tshowDoSthParams = {},  --消息提醒参数
    m_lucky_turntable_btn = nil,
    m_dragon_ball_btn = nil,
    m_hot_active_btn = nil,
    m_king_btn = nil,
    m_rank_btn = nil,

    m_show_chatNode = nil,
    m_show_chatMsg = nil,
    m_fristOpenPop = nil,
    m_sky_star_btn = nil,
    m_conbtn_fuli = nil,
    m_gvg_btn = nil,
    m_kaifu_chongzhi_btn = nil,
    m_btn_firecup = nil,
    -- 聊天
    m_chat_ccbNode = nil,
    ui_node_chatboard = nil,
    m_showChatData = nil,

};
--[[--
    销毁
]]
function game_main_scene.destroy(self)
    -- body
    cclog("-----------------game_main_scene destroy-----------------");
    game_data:removeChatLinster( "game_main_scene" )
    self.m_ccbNode = nil;
    self.m_subordinateMenuPop = nil;
    self.m_resourcesAnimTable = nil;
    self.m_bottom_btn_node = nil;
    self.m_right_btn_node = nil;
    self.m_top_btn_node = nil;
    self.m_top_btn_node2 = nil;
    -- self.m_btnShowFlag = nil;

    self.m_formation_btn = nil;
    self.m_shop_btn = nil;
    self.m_partner_btn = nil;
    self.m_chat_btn = nil;
    self.m_backpack_btn = nil;
    self.m_more_btn = nil;
    self.m_reward_btn = nil;
    self.m_activity_btn = nil;
    self.m_kfhd_activity_btn = nil;
    self.m_do_something_btn = nil;
    self.m_ranking_btn = nil;
    self.m_battle_btn = nil;
    self.m_announcement_btn = nil;
    self.m_team_layer = nil;
    self.m_teamNodeTab = nil;
    self.m_combat_label = nil;
    self.m_gift_btn = nil;
    self.m_firstFlag = nil;
    self.m_chat_node = nil;
    self.m_battle_btn_bg = nil;
    self.m_tipsAnimTab = nil;
    self.m_social_btn = nil;
    self.m_get_flag = nil;
    self.m_pp_btn = nil;
    self.m_pp_btn2 = nil;
    self.m_task_btn = nil;
    self.m_guild_btn = nil;
    self.m_leader_skill_btn = nil;
    self.m_gacha_btn = nil;
    self.m_pay_btn = nil;
    self.m_conbtn_vipshow_btn = nil;
    self.m_daily_task_btn = nil;
    self.m_award_btn = nil;
    self.m_tshowDoSthParams = nil;
    self.m_conbtn_levelgift = nil;
    self.m_conbtn_limit_score_btn = nil;
    self.m_limit_btn = nil;
    self.m_conbtn_secreary = nil;
    self.m_conbtn_challenge =nil;
    self.m_lucky_turntable_btn = nil;
    self.m_dragon_ball_btn = nil;
    self.m_hot_active_btn = nil;
    self.m_king_btn = nil;
    self.m_rank_btn = nil;

    self.m_show_chatNode = nil;
    self.m_show_chatMsg = nil;
    self.m_fristOpenPop = nil;
    self.m_sky_star_btn = nil;
    self.m_conbtn_fuli = nil;
    self.m_gvg_btn = nil;
    self.m_kaifu_chongzhi_btn = nil;
    self.m_btn_firecup = nil;
    self.ui_node_chatboard = nil;
    self.m_showChatData = nil;
    self.m_chat_ccbNode = nil;
end
--[[--
    返回
]]
function game_main_scene.back(self,type)
    game_data:removeChatLinster( "game_main_scene" )
	self:destroy();
end
--[[--
    读取cbbi 创建ui
]]
function game_main_scene.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/new_main_add_res.plist")
    local today = os.date("*t")
    cclog("today == " .. json.encode(today))
    local winSize = CCDirector:sharedDirector():getWinSize();
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:mainBtnOnClick(btnTag, tagNode);
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_main.ccbi");
    self.m_ccbNode = ccbNode;
    self.m_bottom_btn_node = ccbNode:nodeForName("m_bottom_btn_node")
    self.m_right_btn_node = ccbNode:nodeForName("m_right_btn_node")
    self.m_top_btn_node = ccbNode:nodeForName("m_top_btn_node")
    self.m_top_btn_node2 = ccbNode:nodeForName("m_top_btn_node2")
    self.m_chat_node = ccbNode:nodeForName("m_chat_node")
    self.m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
    self.m_partner_btn = ccbNode:controlButtonForName("m_partner_btn")
    self.m_chat_btn = ccbNode:controlButtonForName("m_chat_btn")
    self.m_backpack_btn = ccbNode:controlButtonForName("m_backpack_btn")
    -- self.m_more_btn = ccbNode:controlButtonForName("m_more_btn")
    -- self.m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")
    -- self.m_conbtn_challenge = ccbNode:controlButtonForName("m_conbtn_challenge")
    self.m_activity_btn = ccbNode:controlButtonForName("m_activity_btn")
    self.m_do_something_btn = ccbNode:controlButtonForName("m_conbtn_dosth")  -- 消息提示按钮
    self.m_conbtn_levelgift = ccbNode:controlButtonForName("m_conbtn_levelgift")  -- 消息提示按钮
    self.m_ranking_btn = ccbNode:controlButtonForName("m_ranking_btn")

    self.m_battle_btn = ccbNode:controlButtonForName("m_battle_btn")
    if self.m_battle_btn then
        self.m_battle_btn:setPreferredSize(CCSizeMake(58, 34))
    end
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_combat_label:setVisible(false);
    local pX,pY = self.m_combat_label:getPosition();
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setPosition(ccp(pX, pY));
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    self.m_combat_label:getParent():addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    -- self.m_gift_btn = ccbNode:controlButtonForName("m_gift_btn")
    -- self.m_announcement_btn = ccbNode:controlButtonForName("m_announcement_btn")
    -- self.m_award_btn = ccbNode:controlButtonForName("m_award_btn")
    self.m_social_btn = ccbNode:controlButtonForName("m_social_btn")
    self.m_pp_btn = ccbNode:controlButtonForName("m_pp_btn")
    self.m_pp_btn2 = ccbNode:controlButtonForName("m_pp_btn2")
    self.m_task_btn = ccbNode:controlButtonForName("m_task_btn")
    self.m_guild_btn = ccbNode:controlButtonForName("m_guild_btn")
    self.m_leader_skill_btn = ccbNode:controlButtonForName("m_leader_skill_btn")
    self.m_gacha_btn = ccbNode:controlButtonForName("m_gacha_btn")
    -- self.m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")
    -- self.m_conbtn_secreary = ccbNode:controlButtonForName("m_conbtn_secreary")
    self.m_rank_btn = ccbNode:controlButtonForName("m_rank_btn")--新排行榜
    self.m_conbtn_fuli = ccbNode:controlButtonForName("m_conbtn_fuli")

    if getPlatForm() == "pp" then
        self.m_pp_btn:setVisible(true);
    elseif getPlatForm() == "itools" then
        -- game_util:setCCControlButtonBackground(self.m_pp_btn,"main_itools_icon.png")
        self.m_pp_btn:setVisible(false);
    elseif  getPlatForm() == "platformCommon" then
        self.m_pp_btn:setVisible(false);
        local function needShowSDKBtnResult(table)
            -- body
            if table["needShow"] then
                self.m_pp_btn:setVisible(true);
                if table["icon"] ~= nil then
                    game_util:setCCControlButtonBackground(self.m_pp_btn, table["icon"])
                end
            end
            if table["needShow"] then
                            --监听用户中心的注销事件
            end
        end
        require("shared.native_helper").needShowSDKBtn(needShowSDKBtnResult)
        
        local function logoutResult(table)
            local m_shared = 0;
            function tick( dt )
              CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
              if game_data_statistics then
                    game_data_statistics:logoutGame()
                end
                game_scene:setVisibleBroadcastNode(false);
                game:resourcesDownload();
            end
            m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0 , false)
        end
        require("shared.native_helper").listenBroadCast("userlogOut", logoutResult)
    else
        self.m_pp_btn:setVisible(false);
    end

    if getPlatForm() == "pp" then
        self.m_pp_btn2:setVisible(true);
    else
        self.m_pp_btn2:setVisible(false);
    end

    self.m_battle_btn_bg = ccbNode:spriteForName("m_battle_btn_bg")
    local animArr = CCArray:create();
    -- animArr:addObject(CCRotateBy:create(3,-360));
    animArr:addObject(CCScaleTo:create(1,0.9));
    animArr:addObject(CCScaleTo:create(1,1.0));
    self.m_battle_btn_bg:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    -- cclog("self.m_battle_btn_bg ==== " .. tostring(self.m_battle_btn_bg))
    -- local m_snatch_btn_bg = ccbNode:spriteForName("m_snatch_btn_bg")
    -- local animArr = CCArray:create();
    -- -- animArr:addObject(CCRotateBy:create(3,-360));
    -- animArr:addObject(CCScaleTo:create(1,0.9));
    -- animArr:addObject(CCScaleTo:create(1,1.0));
    -- m_snatch_btn_bg:runAction(CCRepeatForever:create(CCSequence:create(animArr)))

    -- self:setBottomBtnSort();
    -- self:setRightBtnSort();
    self.m_team_layer = ccbNode:layerForName("m_team_layer")
    self:initLayerTouch(self.m_team_layer);
    local tempSpri = nil;
    for i=1,5 do
        tempSpri = ccbNode:spriteForName("m_team_bg_" .. i)
        self.m_teamNodeTab[i] = tempSpri;
    end
    game_button_open:setButtonShow(self.m_ranking_btn,200,1);

    local function timeOverCallFun(label,type)
        label:setTime(180)
        local function responseMethod(tag,response)

        end
        network.sendHttpRequestNoLoading(responseMethod,game_url.getUrlForKey("user_main_page"), http_request_method.GET, nil,"user_main_page")
    end
    local timeLabel = game_util:createCountdownLabel(180,timeOverCallFun,8,1)
    timeLabel:setVisible(false);
    ccbNode:addChild(timeLabel,10,10)

    -- -- 初始化聊天框
    game_data:startChat()
    self.m_showChatData = {}
    local reciveData = function ( chatData, state, kqgFlags )
    --     self:reciveChatData( chatData , state)
        -- cclog2(chatData, " revive data  =====  ")
        state = state or {}
        if chatData and not state["ui_chat_pop"] and kqgFlags[ "friend" ] == true then
            -- self.m_showChatData[#self.m_showChatData + 1] = chatData
            local myuid = game_data:getUserStatusDataByKey("uid")
            if myuid ~= chatData.uid then
                self:refreshChatUI()
            end
        end
    end
    local m_chatObserver = game_data:getChatObserver()  
    m_chatObserver:registerOneLinster( reciveData, "game_main_scene" )          

    local chatNode = self:createAChatWindow()
    self.m_chat_node:addChild(chatNode)
    chatNode:setPositionY(48)
    self.m_chat_node:setVisible(true)

    self:openDoorActivity();

    game_data:updateChatRoom({ domain = "", world = true })
    return ccbNode;
end

function game_main_scene.openDoorActivity(self)
    --状态  0. 未开放, 1.未开启, 2.准备状态, 3. 可以进入状态, 4. 已进入状态
    local open_door = game_data:getAlertsDataByKey("open_door") or 0
    if open_door > 0 then
        local function onBtnCilck( event,target )
            -- local tagNode = tolua.cast(target, "CCNode");
            -- local btnTag = tagNode:getTag();
            if open_door < 3 then
                local function responseMethod(tag,gameData)
                    game_scene:addPop("open_door_activity",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_door_index"), http_request_method.GET, nil,"open_door_index")
            elseif open_door == 3 then
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("open_door_first_battle");
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_door_battle"), http_request_method.GET, {},"open_door_battle")
            else
                game_scene:enterGameUi("open_door_main_scene")
            end
        end
        local m_bg_sprite = self.m_ccbNode:spriteForName("m_bg_sprite")
        local rocket_image = CCSprite:create("ccbResources/rocket_image.png")
        if rocket_image and m_bg_sprite then
            local tempSize = m_bg_sprite:getContentSize();
            local btnImg = rocket_image:displayFrame();
            local btn = CCControlButton:create(CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,16),CCScale9Sprite:createWithSpriteFrame(btnImg));
            btn:setPreferredSize(btnImg:getRect().size);
            btn:addHandleOfControlEvent(onBtnCilck,CCControlEventTouchUpInside);
            btn:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.65));
            btn:setTouchPriority(2);
            m_bg_sprite:addChild(btn)
        end
    end
end

--[[
    创建聊天小窗口
]]
function game_main_scene.createAChatWindow( self )
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if btnTag == 10 then -- 关闭
            game_scene:addPop("ui_chat_pop", {openType = 3});
            -- game_scene:enterGameUi("game_first_opening",{});
            -- game_util:addMoveTips({text = "暂未开放！"});
            -- self.m_show_chatNode:setVisible(false)
            self.m_chat_btn:removeChildByTag(888, true)
            self.m_chat_ccbNode:runAnimations("goout")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_chat_node.ccbi")
    self.m_chat_ccbNode = ccbNode
    self.ui_node_chatboard = ccbNode:nodeForName("ui_node_chatboard")
    local m_conbtn_bg = ccbNode:controlButtonForName("m_conbtn_bg")
    m_conbtn_bg:setOpacity(200);
    return ccbNode
end


function game_main_scene.refreshChatUI( self )
    self.ui_node_chatboard:removeAllChildrenWithCleanup(true)
    local newTableView = self:createChatView( self.ui_node_chatboard:getContentSize() )
    if newTableView then
        self.ui_node_chatboard:addChild(newTableView)
    end
    cclog2(newTableView, "newTableView  ==  ")
end

function game_main_scene.createChatView( self, viewSize )
    local tempNode = CCNode:create()
    tempNode:setContentSize(viewSize)
    local scrollview = CCScrollView:create(viewSize, CCNode:create())
    local container = scrollview:getContainer();
    container:removeAllChildrenWithCleanup(true);

    for i=1,10 do
        if #self.m_showChatData > 2 then
            table.remove(self.m_showChatData, 1)
        else
            break
        end
    end
    local showData = self.m_showChatData or {}
    local totalHeight = 0
    local chatMsgLabelTab = {}

    local lastFriendChatData = game_data:getChatObserver():getLastFriendChatMessage()

    cclog2(lastFriendChatData, "lastFriendChatData  ======   ")

    local strLen = function ( str )
        local _, count = string.gsub(str, "[^\128-\193]", "")
        return count
    end

    local function chsize(char)
        if not char then
            print("not char")
            return 0
        elseif char > 240 then
            return 4, 1
        elseif char > 225 then
            return 3, 1
        elseif char > 192 then
            return 2, 1
        else
            return 1, 0.5
        end
    end

    local strSub = function (str, startChar, numChars)
        local startIndex = 1
        while startChar > 1 and numChars > 0 do
            local char = string.byte(str, startIndex)
            startIndex = startIndex + chsize(char)
            startChar = startChar - 1
        end

        local currentIndex = startIndex
        while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            local x1, x2 = chsize(char)
            currentIndex = currentIndex + x1
            numChars = numChars - x2
        end
        return str:sub(startIndex, currentIndex - 1)
    end


    local showData = {lastFriendChatData}
    cclog2(showData, "showData  ======   ")
    for index=1,#showData do
        local itemData = showData[index];
        local msg = ""
        if itemData.kqgFlag == "friend" then
            msg = msg .. "[color=ffff00ff]\\[私聊\\]" .. tostring(itemData.user) .. ":[/color] \n"
        end
        local smpleMsg = tostring(itemData.smpleMsg)
        cclog2(strLen(smpleMsg), "strLen  =======  ")
        if strLen(smpleMsg) > 10  then
            smpleMsg = tostring(strSub(smpleMsg, 1, 10)) .. "……"
        end

        local showMsg = msg .. "[color=fff0f0f0]" .. tostring(smpleMsg) .. "[/color]";
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
    cclog("viewSize.width = " .. viewSize.width .. " viewSize.height = " .. viewSize.height)
    cclog("contentSize.width = " .. contentSize.width .. " contentSize.height = " .. contentSize.height)
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

    if #showData > 0 then        
        self.m_chat_ccbNode:runAnimations("comein")
    end
    scrollview:setTouchEnabled(false)
    do return scrollview end
end

--[[--
    创建一个button
]]
function game_main_scene.createAMainButton( self, posx, onBtnCilck, spriteName, tag)
    local button = game_util:createCCControlButton(spriteName,"",onBtnCilck)
    button:setPosition(ccp(posx,22))
    button:setTag(tag)
    -- button:setVisible(false)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY+130);
    self.m_top_btn_node2:addChild(button)
    return button
end

--[[
    主按钮点击
]]
function game_main_scene.mainBtnOnClick( self, btnTag, tagNode )
    if btnTag == 1 then --去战斗
        if type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "third_enter_main_scene" then
            if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(39)  --[[第一次点击战斗 步骤39]] end
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    elseif btnTag == 2 then--聊天
        game_scene:addPop("ui_chat_pop");
        -- -- game_scene:enterGameUi("game_first_opening",{});
        -- -- game_util:addMoveTips({text = "暂未开放！"});
        -- -- self.m_show_chatNode:setVisible(false)
        self.m_chat_btn:removeChildByTag(888, true)
    elseif btnTag == 3 then--公告
        game_scene:addPop("annoucement_pop");
        -- game_scene:addPop("game_announcement_pop",{typeName = "announcement"});
    elseif btnTag == 4 then--抢夺
        game_scene:addPop("game_function_pop",{typeName = "snatch",posNode = tagNode})
    elseif btnTag == 11 then--阵型
        if type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "second_enter_main_scene" then
            if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(35)  --[[第一次点击阵型 步骤35]] end
        elseif type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "guide_second" then
            if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(47)   --[[完成剧情30步 -- 步骤47]] end
        end
        -- CCNative:openURL("http://baidu.com");
        -- CCNative:createAlert("tt","ttt","sure");
        -- CCNative:addAlertButton("dd");
        -- CCNative:showAlertLua(function(tParams) cclog("============================" .. tParams.buttonIndex .. " ; tParams.action = " .. tParams.action) end);
        game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
        self:destroy();
    elseif btnTag == 12 then--伙伴
        game_scene:addPop("game_function_pop",{typeName = "partner",posNode = tagNode})
    elseif btnTag == 13 then--装备z
        if type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "guide_second_start_2_35" then
            if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(52)   --[[新手引导35步 -- 步骤52]] end
        end
        game_scene:addPop("game_function_pop",{typeName = "backpack",posNode = tagNode})
    elseif btnTag == 14 then--社交
        game_scene:addPop("game_function_pop",{typeName = "social",posNode = tagNode})
    elseif btnTag == 15 then--商店
        game_scene:addPop("game_function_pop",{typeName = "shop",posNode = tagNode})
    elseif btnTag == 16 then--功能
        game_scene:addPop("game_function_pop",{typeName = "func",posNode = tagNode})
    elseif btnTag == 21 then--gacha
        if type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "first_enter_main_scene" then
            if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(30)  --[[第一次点击伙伴招募 步骤30]] end
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
    elseif btnTag == 22 then--英雄技能
        game_scene:addPop("game_function_pop",{typeName = "heroInfo",posNode = tagNode})
    elseif btnTag == 23 then--道具
        game_scene:enterGameUi("items_scene",{gameData = nil});
    elseif btnTag == 31 then--竞技场
        if not game_button_open:checkButtonOpen(200) then
            return;
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
    elseif btnTag == 32 then--活动
        --先联网再进入
        local function responseMethod(tag,gameData)
            -- game_scene:enterGameUi("game_activity",{gameData = gameData})
            game_scene:addPop("game_activity_new_pop",{gameData = gameData})
            -- self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    elseif btnTag == 1033 then--消息提醒
        if self.m_tshowDoSthParams and self.m_tshowDoSthParams.showType then
        else
            self:refreshDoSomethingBtn()
            return 
        end
        if self.m_tshowDoSthParams.showType == "gongneng" then
            game_data:addOneNewButtonByBtnID(self.m_tshowDoSthParams.data)
        elseif self.m_tshowDoSthParams.showType == "shencundakaoyan" then
            self:showLiveActiveTips("shencundakaoyan", game_data.m_talreadyTips[self.m_tshowDoSthParams.showType].data)
        elseif game_data.m_talreadyTips[self.m_tshowDoSthParams.showType] then
                game_data.m_talreadyTips[self.m_tshowDoSthParams.showType].isShow = true
        end
       if self.m_tshowDoSthParams.showType == "gongneng" and (self.m_tshowDoSthParams.data == 108 or self.m_tshowDoSthParams.data == 109 )then

            local chapterID_index = {}
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog("activity data=="..data:getFormatBuffer())
                local others = data:getNodeWithKey("index");--有的即开启
                others_index = json.decode(others:getFormatBuffer())
                for i=1,others:getNodeCount() do
                    local indexItem = others:getNodeAt(i-1)
                    local index_key = indexItem:getKey()
                    table.insert(chapterID_index,tonumber(index_key))
                end
                game_scene:addPop("game_do_something_pop", {gameData = self.m_tshowDoSthParams, activityData = chapterID_index})
                self:refreshDoSomethingBtn();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        else
            game_scene:addPop("game_do_something_pop", {gameData = self.m_tshowDoSthParams})
            self:refreshDoSomethingBtn();
        end
    elseif btnTag == 1034 then  -- 等级礼包
        local popRemoveFun = function ()
            -- print("  self:refreshUi()  ")
           self:refreshUi()
        end
       game_scene:addPop("game_limitgift_pop", {gameData = game_data:getAlertsDataByKey("level_gift"), popRemFun = popRemoveFun});
    elseif btnTag == 41 then --每日任务  日常领奖
        function shopOpenResponseMethod(tag,gameData)
            -- game_scene:enterGameUi("game_daily_wanted",{gameData = gameData})
            -- self:destroy();
            game_scene:addPop("game_daily_wanted",{gameData = gameData})
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, {},"reward_index")
    elseif btnTag == 35 then --任务
        if game_data:getAlertsDataByKey("diary") and game_data:getAlertsDataByKey("diary") > 0 then
            function responseMethod(tag,gameData)
                game_scene:addPop("game_daily_task_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_diary_index"), http_request_method.GET, {},"reward_diary_index")
        elseif game_data:getAlertsDataByKey("reward") == true then
            function shopOpenResponseMethod(tag,gameData)
                -- game_scene:enterGameUi("game_daily_wanted",{gameData = gameData})
                -- self:destroy();
                game_scene:addPop("game_daily_wanted",{gameData = gameData})
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, {},"reward_index")
        else
            function responseMethod(tag,gameData)
                game_scene:addPop("game_daily_task_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_diary_index"), http_request_method.GET, {},"reward_diary_index")
        end
    elseif btnTag == 8082 then--新排行榜
        function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_new_rank",{gameData = gameData})
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rank_combat"), http_request_method.GET, {},"rank_combat",true,true)
    elseif btnTag == 10061 then--小秘书
    elseif btnTag == 10067 then -- 福利
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_fuli_activity_scene",{awardData = gameData, screenShoot = screenShoot})
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_once_index"), http_request_method.GET, nil,"reward_once_index",true,true)
    elseif btnTag == 100 then--pp
        if getPlatForm() == "pp" then
            PP_CLASS:sharedInstance():showCenter();
        elseif getPlatForm() == "itools" then
            PLATFORM_ITOOLS.enterPlatform()
        elseif getPlatForm() == "platformCommon" then
            local function showResult(table)
                -- body
                if table["needShow"] then
                    require("shared.native_helper").enterUserCenter()
                end
            end
            require("shared.native_helper").needShowSDKBtn(showResult)
        end
    elseif btnTag == 101 then--pp论坛独有后加专享唯一跳转按钮
        local updataUrl = "http://bbs.996.com/forum-cjyx-1.html" 
        util_system:openUrlOutside(updataUrl);
    end
end
--[[
    活动按钮点击
]]
function game_main_scene.activeBtnOnClick( self, btnTag )
    if btnTag == 10063 then
        -- 挑战
        function shopOpenResponseMethod(tag,gameData)
            game_scene:addPop("game_challange_pop",{gameData = gameData})
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("battle_challenge_info"), http_request_method.GET, {},"battle_challenge_info")
   elseif btnTag == 10064 then     
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_lucky_turntable",{gameData = gameData})
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("roulette_index"), http_request_method.GET, {},"roulette_index")
    elseif btnTag == 10065 then  -- 龙珠
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("dragon_ball_scene",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_active_index"), http_request_method.GET, {all_open = 1},"super_active_index",true,true)
    elseif btnTag == 8080 then  -- 热门活动
        function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_charge_active",{gameData = gameData})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_active_show"), http_request_method.GET, {},"active_active_show")
    elseif btnTag == 8081 then  -- 赛亚人归来
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_saiya_active",{gameData = gameData,screenShoot = screenShoot})
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_active_index"), http_request_method.GET, {rich_open = 1},"super_active_index",true,true)
    elseif btnTag == 8083 then--公会战
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外围战布阵开启
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
            elseif sort == 2 then--外围战战争开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--内城布阵开始
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
            elseif sort == 4 then--内城战开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公会战未开启
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
    elseif btnTag == 10066 then
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_sky_star",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("bandit_index"), http_request_method.GET, nil,"bandit_index",true,true)
    elseif btnTag == 10068 then--中秋
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("mid_autumn_scene",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_group_index"), http_request_method.GET, nil,"active_group_index",true,true)
    elseif btnTag == 10069 then--中秋
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
       local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("mid_autumn_group_buy_scene",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_group_active_index"), http_request_method.GET, nil,"active_group_active_index",true,true)
    elseif btnTag == 10070 then--福利基金
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data")
                local mail_mark = data:getNodeWithKey("mail_mark"):toBool();
                if mail_mark == true then
                    if self.m_fund_btn then
                        self.m_fund_btn:setVisible(false);
                    end
                    game_util:addMoveTips({text = string_helper.game_main_scene.text})
                else
                    local bought_funds = data:getNodeWithKey("bought_funds")
                    if bought_funds and bought_funds:getNodeCount() > 0 then
                        game_scene:enterGameUi("fund_activation_scene",{gameData = gameData,screenShoot = screenShoot});
                    else
                        game_scene:enterGameUi("fund_main_scene",{gameData = gameData,screenShoot = screenShoot});
                    end
                end
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("foundation_show_available_funds"), http_request_method.GET, nil,"foundation_show_available_funds",true,true)
    elseif btnTag == 10111 then--充值好礼   开服活动
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_open_rechrage",{gameData = gameData,screenShoot = screenShoot})
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_active_recharge_index"), http_request_method.GET, {},"server_active_recharge_index",true,true);
    elseif btnTag == 10112 then--限时伙伴   开服活动
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_active_limit",{gameData = gameData,open_type = 2})
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_limit_hero_index"), http_request_method.GET, {},"server_limit_hero_index")
    elseif btnTag == 11111 then --新服商城
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_shop_new_scene",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release()
        end
        local params = {}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_shop_show"), http_request_method.GET, params,"server_shop_show",true,true);
    elseif btnTag == 11112 then -- 新服兑换活动
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_exchange_newServer",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("show_server_exchange_options"), http_request_method.GET, {},"show_server_exchange_options")
    elseif btnTag == 10071 then--开服转盘
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_lucky_turntable_server",{gameData = gameData})
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_roulette_index"), http_request_method.GET, {},"server_roulette_index")
    elseif btnTag == 10072 then--开服漫天星
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_sky_star_server",{gameData = gameData,screenShoot = screenShoot});
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_bandit_index"), http_request_method.GET, nil,"server_bandit_index",true,true)
    elseif btnTag == 10073 then--开服基金
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data")
                local mail_mark = data:getNodeWithKey("mail_mark"):toBool();
                if mail_mark == true then
                    if self.m_server_fund_btn then
                        self.m_server_fund_btn:setVisible(false);
                    end
                    game_util:addMoveTips({text = string_helper.game_main_scene.text})
                else
                    local bought_funds = data:getNodeWithKey("bought_funds")
                    if bought_funds and bought_funds:getNodeCount() > 0 then
                        game_scene:enterGameUi("fund_activation_server_scene",{gameData = gameData,screenShoot = screenShoot});
                    else
                        game_scene:enterGameUi("fund_main_server_scene",{gameData = gameData,screenShoot = screenShoot});
                    end
                end
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_foundation_show_available_funds"), http_request_method.GET, nil,"server_foundation_show_available_funds",true,true)
    elseif btnTag == 10074 then--寻宝
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_seapoacher",{gameData = gameData,screenShoot = screenShoot});
        end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_index"), http_request_method.GET, nil,"one_piece_index",true,true)
    elseif btnTag == 10075 then
        local screenShoot = game_util:createScreenShoot();
        screenShoot:retain();
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("ui_firecup_scene", { gameData = gameData, screenShoot = screenShoot})
            end
            screenShoot:release();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_index"), http_request_method.GET, nil,"magic_school_index",true,true)
    elseif btnTag == 500 then-- 消费计划
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_payplan_pop",{ gameData = gameData, turnUICallFun = function (  )
            self:destroy();
        end})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_guide_isbuy"), http_request_method.GET, {},"vip_guide_isbuy")
    elseif btnTag == 501 then
        game_scene:addPop("game_vipguide_pop",{})
    elseif btnTag == 60 then--限时神将
        function shopOpenResponseMethod(tag,gameData)
            -- game_scene:addPop("game_active_limit_pop",{gameData = gameData})
            game_scene:enterGameUi("game_active_limit",{gameData = gameData})
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("get_reward_gacha"), http_request_method.GET, {},"get_reward_gacha")
    elseif btnTag == 61 then--限时积分
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_active_limitscore",{gameData = gameData})
            -- game_scene:addPop("game_active_limitscore_pop",{gameData = gameData})
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("integration_index"), http_request_method.GET, {},"integration_index")
    elseif btnTag == 1032 then--开服活动
        function responseMethod(tag,gameData)
            game_scene:addPop("game_opening_pop",{gameData = gameData, callFun =  function()
                    game_scene:enterGameUi("game_main_scene",{gameData = nil});
                end})
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_kfhd_index"), http_request_method.GET, {},"active_kfhd_index")
    end
end



--[[--
    功能按钮
]]
function game_main_scene.setBottomBtnSort(self)
    -- local items = self.m_bottom_btn_node:getChildren();
    -- local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    -- if items then
    --     local itemCount = items:count();
    --     local btn = nil;
    --     local posIndex = 0;
    --     for i = 1,itemCount do
    --         btn = tolua.cast(items:objectAtIndex(i - 1),"CCControlButton");
    --         if btn:isVisible() then
    --             local btnSize = btn:getContentSize();
    --             btn:setPositionX(visibleSize.width - btnSize.width*(1.7 + 1.15*posIndex));
    --             posIndex = posIndex + 1;
    --         end
    --     end
    -- end
end

--[[--
    功能按钮
]]
function game_main_scene.setRightBtnSort(self)
    -- local items = self.m_right_btn_node:getChildren();
    -- local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    -- if items then
    --     local itemCount = items:count();
    --     local btn = nil;
    --     local posIndex = 0;
    --     for i = 1,itemCount do
    --         btn = tolua.cast(items:objectAtIndex(i - 1),"CCControlButton");
    --         if btn:isVisible() then
    --             local btnSize = btn:getContentSize();
    --             btn:setPositionY(btnSize.height*(1.5 + 1.1*posIndex));
    --             posIndex = posIndex + 1;
    --         end
    --     end
    -- end
end
--[[--
    通过阵型下标创建卡牌动画
]]
function game_main_scene.createCardAnimByPosIndex(self,posIndex)
    local animNode = nil;

    local heroData,heroCfg = game_data:getTeamCardDataByPos(posIndex)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
            local headBg = CCSprite:createWithSpriteFrameName("public_hengtiao.png");
            headBg:setOpacity(155);
            headBg:setPosition(ccp(itemSize.width*0.5,itemSize.height + 15));
            animNode:addChild(headBg)
            --改 ---------- 2 --------------- 直接不顯示等級上限
            -- local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max,TYPE_FACE_TABLE.Arial_BoldMT,10);
            --最大等級修改為用戶等級
            local userMaxLevel = game_data:getUserStatusDataByKey("level")
            --幾張不能進階的卡最大等級是1
            local is_evo = heroCfg:getNodeWithKey("is_evo")
            local maxLevel = userMaxLevel
            if is_evo and is_evo:toInt() == 0 then
                maxLevel = 1
            end
            -- local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. maxLevel,TYPE_FACE_TABLE.Arial_BoldMT,10);
            local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv,TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 - 40,itemSize.height + 15));
            --改為居中
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 40,itemSize.height + 15));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)
            -- local tempLabel = CCLabelTTF:create(heroCfg:getNodeWithKey("name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 + 50,95));
            -- tempLabel:setAnchorPoint(ccp(1,0.5));
            -- animNode:addChild(tempLabel,100,100)
            -- game_util:setHeroNameColorByQuality(tempLabel,heroCfg);
            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 40,itemSize.height + 15));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            end
        end
    end
    return animNode;
end

--[[--
    触摸
]]
function game_main_scene.initLayerTouch(self,touch_layer)
    local tempItem,selItem,realPos
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        realPos = self.m_team_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_teamNodeTab) do
            tempItem = v
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                break;
            end
        end
        return true
    end
    local function onTouchMoved(x, y)
    end
    local function onTouchEnded(x, y)
        realPos = self.m_team_layer:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            -- cclog("on click -----------------------------" .. selItem:getTag())
            local heroData,heroCfg = game_data:getTeamCardDataByPos(selItem:getTag())
            if heroData and heroCfg then
                local function callBack(typeName)
                    typeName = typeName or ""
                    if typeName == "refresh" then
                        self:refreshTeamLayer();
                    end
                end
                game_scene:addPop("game_hero_info_pop",{tGameData = heroData,openType = 1,callBack = callBack})
            end
        end
        tempItem = nil;
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+140,false)
    touch_layer:setTouchEnabled(true)
end
--[[--
    
]]
function game_main_scene.refreshBtnStatus(self)
    for k,v in pairs(self.m_tipsAnimTab) do
        v:removeFromParentAndCleanup(true);
    end
    self.m_tipsAnimTab = {};

    -- 其他按钮
    self:setButtonState(self.m_gacha_btn, 12)  -- 伙伴招募
    -- self:setButtonState(self.m_guild_btn, 13)  -- 背包
    self:setButtonState(self.m_chat_btn, 14)  -- 聊天
    self:refreshTopButton();
    self:refreshActiveButton();

    if game_data:getAlertsDataByKey("gacha") then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_shop_btn,9);
    end

    if game_data:getNewCardFlag() then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_partner_btn,10);
    else
    	-- 训练完成， 英雄碎片兑换 -- 红点不再显示
        -- if game_data:getAlertsDataByKey("train_finish") or game_data:getAlertsDataByKey("exchange") == true then
        --     self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_partner_btn,9);
        -- end
    end
    if game_data:getOpenFormationAlertFlag() then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_formation_btn,9);
    end
    
    -- 世界boss 提醒活动按钮
    if game_data:getAlertsDataByKey("boss") then--活动
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_activity_btn,7);
    end
    local level = game_data:getUserStatusDataByKey("level") or 0
    -- 生存物资 提醒福利按钮
    if game_data:getAlertsDataByKey("active") == 1 and game_data:isViewOpenByID( 49 ) then--活动
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_conbtn_fuli, 18);
    else
        -- 月卡 提醒福利按钮
        if game_data:getAlertsDataByKey("month") and game_data:isViewOpenByID( 126 ) then--活动
            self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_conbtn_fuli, 18);
        else
            if level >= 3 then
                -- 签到奖励提示
                if game_data:getAlertsDataByKey("daily") == true and game_data:isViewOpenByID(9) then
                    self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_conbtn_fuli, 18);
                end
                if game_data:getAlertsDataByKey("once") == true and game_data:isViewOpenByID( 8 ) then--领奖   或在线领奖
                    self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_conbtn_fuli,18 );
                end
            end
        end
    end

    -- 装备兑换按钮红点不再显示 --
    if game_data:getNewEquipFlag() or game_data:getNewItemFlag() or game_data:getAlertsDataByKey("equip_exchange") == true then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_backpack_btn,10);
    end

    if game_data:getAlertsDataByKey("notify") then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_social_btn,9);
    end
    if game_data:getAlertsDataByKey("guild_gvg") then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_gvg_btn,7);
    end
    -- -- 精力 30   -- 统帅
    -- if game_button_open:getOpenFlagByBtnId(606) then
    --     local cmdr_energy = game_data:getUserStatusDataByKey("cmdr_energy") or 0
    --     if cmdr_energy >= 30 and game_data:updateShowTips("cmdr_energy" )  then  -- 精力已满
    --         self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_leader_skill_btn,9);
    --     elseif cmdr_energy < 30 then
    --         game_data:updateShowTips("cmdr_energy", "reset_show")
    --     end
    -- end

    -- 金币300 gacha
    local ogold = game_data:getUserStatusDataByKey("silver") or 0  -- 金币数量
    if game_data:isViewOpenByID(12) then
        if ogold >= 300 and game_data:updateShowTips("gold_enough" )  then  -- 可以金币招募了
            self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_gacha_btn,9);
            cclog2(ogold, "ogold   ====    ")
        elseif ogold < 300 then
            game_data:updateShowTips("gold_enough", "reset_show")
        end
    end


    -- 星灵 1000  -- 英雄技能
    if game_button_open:getOpenFlagByBtnId(605) then
        local totalStar = game_data:getUserStatusDataByKey("star") or 0
        if totalStar >= 1000  and game_data:updateShowTips("totalStar") then  -- 星灵 1000
            self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_leader_skill_btn,9);
        elseif totalStar < 1000  then
            game_data:updateShowTips("totalStar", "reset_show")
        end
    end

    -- mark do  -- 目前使用的是 活动的动画 应该是 开服活动
    -- 开服活动按钮动画尝试
    if game_data:getAlertsDataByKey("opening") and game_data:getAlertsDataByKey("opening") ~= "" then    --活动
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_kfhd_activity_btn, 7);
    end

    -- 每天第一次登陆 悬赏任务闪烁
    local tflag = false
    local sedata = game_data:getUserStatusDataByKey("server_time")
    local formatDate = os.date("*t", sedata)
    local time = os.date("%Y%m%d", sedata)
    local localSaveData = game_data:updateLocalData( "m_task_btn_date" )
    local itime = tonumber(time)
    local ilocaltime = tonumber(localSaveData) or 0
    if itime > ilocaltime then
        -- print("  -------------   time", itime)
        game_data:updateLocalData( "m_task_btn_date", tostring(itime + 1), true)
        tflag = true
    elseif itime == ilocaltime and formatDate.hour >= 16 then
        game_data:updateLocalData( "m_task_btn_date", tostring(itime + 1), true)
        tflag = true
    end

    if level >= 3 then
        -- reward 日常任务（悬赏）奖励
        -- diary  日常任务
        -- daily  签到
        if game_data:getAlertsDataByKey("reward") == true or ( game_data:getAlertsDataByKey("diary") and game_data:getAlertsDataByKey("diary") > 0)  or tflag then-- 任务
            self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_task_btn,12);
        elseif game_data:getAlertsDataByKey("reward") == nil and game_data:getAlertsDataByKey("diary") == nil then--
            self.m_task_btn:setVisible(false)
        end
    else
        self.m_task_btn:setVisible(false)
    end
    if not game_data:isViewOpenByID(4) then  -- 日常任务按钮隐藏
        self.m_task_btn:setVisible(false)
    end
    
    --热门活动
    if game_data:getAlertsDataByKey("active_show") == true then
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_hot_active_btn,16);
    end
end

local top_btn_name_tab = {{name="m_rank_btn",inReviewId=52},{name="m_ranking_btn",inReviewId=7},{name="m_activity_btn",inReviewId=6},{name="m_conbtn_fuli",inReviewId=3}}
--[[
    
]]
function game_main_scene.refreshTopButton( self )
    local posx = self.m_rank_btn:getPositionX()   -- 按钮x坐标
    for i=1,#top_btn_name_tab do
        local itemData = top_btn_name_tab[i]
        local tempBtn = self[itemData.name]
        if tempBtn then
            if game_data:isViewOpenByID(itemData.inReviewId) then
                tempBtn:setPositionX(posx)
                tempBtn:setVisible(true)
                posx = posx - 40
            else
                tempBtn:setVisible(false)
            end
        end
    end
end

local active_btn_name_tab = {
    "m_pay_btn",
    "m_conbtn_vipshow_btn",
    "m_kfhd_activity_btn",
    "m_limit_btn",
    "m_conbtn_limit_score_btn",
    "m_lucky_turntable_btn",
    "m_dragon_ball_btn",
    "m_king_btn",
    "m_hot_active_btn",
    "m_sky_star_btn",
    "m_gvg_btn",
    "m_mid_autumn_btn",
    "m_mid_autumn_buy_btn",
    "m_fund_btn",
    "m_xunbao_btn",
    "m_kaifu_chongzhi_btn",
    "m_kaifu_limit_hero_btn",
    "m_kaifu_newshop_btn",
    "m_kaifu_newExchange_btn",
    "m_server_lucky_turntable_btn",
    "m_server_sky_star_btn",
    "m_server_fund_btn",
}

--[[
    --活动
]]
function game_main_scene.refreshActiveButton( self )
    for k,v in pairs(active_btn_name_tab) do
        self[v] = nil;
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:activeBtnOnClick(btnTag);
    end
    self.m_top_btn_node2:removeAllChildrenWithCleanup(true);
    local posx = self.m_rank_btn:getPositionX()      -- 按钮x坐标

    local shopInfo = game_data:getShopData()
    local level = game_data:getUserStatusDataByKey("level") or 0
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    -- cclog2(game_data:getAlertsDataByKey("opening"), "opening ==== ")

    if game_data:isViewOpenByID(1) and (vipLevel < 1  or game_data:getAlertsDataByKey("opening") == 1) then
        self.m_conbtn_vipshow_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_chongzhihaoli.png", 501)
        posx = posx - 40
    else
        if game_data:isViewOpenByID(2) and shopInfo.guide_display then
            self.m_pay_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_xiaofeijihua.png", 500)
            posx = posx - 40
        end
    end

    local server_time = game_data:getUserStatusDataByKey("server_time")
    local sedata,_ = game_data:getServer()
    local open_time = -1;
    if sedata.open_time then
        open_time = sedata.open_time
    end

    local endFlag = false
    if open_time ~= -1 then
        local serDate = os.date("%Y%m%d", server_time) or 1
        local dayNum = game_data:getOpeningDayNum() or 14
        -- local curDay = "" .. serDate.year .. serDate.month .. serDate.day
        local endDate = os.date("%Y%m%d", sedata.open_time +  dayNum * 24 * 3600) or 0
        -- local endDay = "" .. endDate.year .. endDate.month .. endDate.day
        local nCurDay = tonumber(serDate)
        local nEndDay = tonumber(endDate)
        -- print(" opeing date : endDay == ", nEndDay, " curDay == ", nCurDay)
        if nCurDay>nEndDay then
            endFlag = true
        end
    end

    if game_data:isViewOpenByID(10) and level >= 3 and (open_time == -1 or not endFlag) then    -- 开服
        self.m_kfhd_activity_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_kaifuhuodong.png", 1032)
        posx = posx - 40
    end


    if level >= 10 and game_data:isViewOpenByID(123) then--公会战
        self.m_gvg_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_zhengba.png", 8083)
        posx = posx - 40
    end


    -- 活动开启开关  -----------------------------   active_inview id 

    if game_data:isViewOpenByID(112) or game_data:isViewOpenByID(113) then  -- 限时积分活动
        self.m_conbtn_limit_score_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_limitscore.png", 61)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(501) then  --热门活动   inview 117  新 active_inview  501
        self.m_hot_active_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_remen.png", 8080)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(502) then  -- 限时神将活动   inview 110 新 active_inview 502
        self.m_limit_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_xianshi.png", 60)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(503) then  -- 转盘活动  inview 114 新 active_inview 503
        self.m_lucky_turntable_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_lunpan.png", 10064)
        posx = posx - 40
    end
    if game_data:isActiveOpenByID(504) then  -- 神龙活动  inview 115 新 active_inview 503
        self.m_dragon_ball_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_shenlong.png", 10065)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(505) then  --赛亚人归来  inview 116  新 active_inview  505  
        self.m_king_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_king.png", 8081)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(506) then  -- 满天星活动 inview 124  新 active_inview 506
        self.m_sky_star_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_maintianxing.png", 10066 )
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(507) then  -- 中秋活动   inview 125  新 active_inview  507
        self.m_mid_autumn_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_zhongqiu.png", 10068)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(507) then  -- 中秋团购活动   inview 125  新 active_inview  507
        self.m_mid_autumn_buy_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_zhongqiutuangou.png", 10069)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(508) or game_data:getDataByKey("foundation_status") == true then  -- 福利基金  inview 127  新 active_inview  508 
        self.m_fund_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_jijin.png", 10070)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID(509) then  -- 寻宝活动   inview 125  新 active_inview  509
        self.m_xunbao_btn = self:createAMainButton( posx, onBtnCilck, "m_button_xunbao.png", 10074)
        posx = posx - 40
    end

    if game_data:isActiveOpenByID( 510 ) then -- 火焰杯  inview 141  新 active_inview 510
        self.m_btn_firecup = self:createAMainButton( posx, onBtnCilck, "m_button_c_firecup.png", 10075)
        posx = posx - 40
    end

    --开服活动 
    if game_data:isViewOpenByID(901) then  -- 开服 充值活动
        self.m_kaifu_chongzhi_btn = self:createAMainButton( posx, onBtnCilck, "m_button_c_chongzhihaoli.png", 10111)
        posx = posx - 40
    end
    
    if game_data:isViewOpenByID(904) then -- 开服 限时伙伴
        self.m_kaifu_limit_hero_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_xianshi.png", 10112)
        posx = posx - 40
    end

    if game_data:isViewOpenByID(902) then  -- 开服 新服商城
        self.m_kaifu_newshop_btn = self:createAMainButton( posx, onBtnCilck, "m_button_c_newShop.png", 11111)
        posx = posx - 40
    end
    if game_data:isViewOpenByID(903) then  -- 开服 新服兑换
        self.m_kaifu_newExchange_btn = self:createAMainButton( posx, onBtnCilck, "m_button_c_newExchange.png", 11112)
        posx = posx - 40
    end
    if game_data:isViewOpenByID(906) then  -- 开服转盘活动
        self.m_server_lucky_turntable_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_lunpan.png", 10071)
        posx = posx - 40
    end

    if game_data:isViewOpenByID(905) then  -- 满天星活动
        self.m_server_sky_star_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_maintianxing.png", 10072)
        posx = posx - 40
    end
    if game_data:isViewOpenByID(907) or game_data:getDataByKey("server_foundation_status") == true then  -- 开服福利基金
        self.m_server_fund_btn = self:createAMainButton( posx, onBtnCilck, "mbutton_m_jijin.png", 10073)
        posx = posx - 40
    end

end

function game_main_scene.setButtonState( self, button, buttonID )
    if not button then return end
    if game_data:isViewOpenByID(buttonID) then    
        -- button:setVisible(true)
    else
        button:setVisible(false)
    end
end


function game_main_scene.showAnnouncement(self)
    -- cclog2(self.m_fristOpenPop , "m_fristOpenPop  ====   ")
    if self.m_firstFlag == true then--第一次进入
        package.loaded["game_pop.game_function_pop"] = nil
        local id2 = game_guide_controller:getIdByTeam("1");
        if id2 > 1 then
            -- game_scene:addPop("game_announcement_pop",{typeName = "announcement"});
            local popEndCallFunc = function( )
                if not self:guideHelper() then

                    self:refreshDoSomethingBtn();           -- 刷新消息提示按钮的状态
                end
            end
            if (game_data:isViewOpenByID(11) ) then
                game_scene:addPop("annoucement_pop", {endCallFunc = popEndCallFunc});
            else
                popEndCallFunc()
            end
        end
    else 
        local id2 = game_guide_controller:getIdByTeam("1");
        if id2 > 1 then
            if self.m_fristOpenPop == "game_activity_new_pop" then
                --先联网再进入
                local function responseMethod(tag,gameData)
                    -- game_scene:enterGameUi("game_activity",{gameData = gameData})
                    game_scene:addPop("game_activity_new_pop",{gameData = gameData})
                    self.m_fristOpenPop = nil
                    -- self:destroy()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
            elseif self.m_fristOpenPop == "ui_chat_pop" then
                game_scene:addPop("ui_chat_pop")
                    self.m_fristOpenPop = nil
                self.m_chat_btn:removeChildByTag(888, true)
            else
                if not self:guideHelper() then
                    self:refreshDoSomethingBtn();           -- 刷新消息提示按钮的状态
                end
            end
        end
    end
end

--[[--
    刷新
]]
function game_main_scene.refreshTeamLayer(self)
    local tempNode;
    for i=1,5 do
        local animNode = self:createCardAnimByPosIndex(i);
        tempNode = self.m_teamNodeTab[i]
        if animNode and tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
            local tempSize = self.m_teamNodeTab[i]:getContentSize();
            animNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.13));
            tempNode:addChild(animNode,1,1);
        end
    end
end

--[[--
    刷新ui
]]
function game_main_scene.refreshUi(self)
    self:refreshBtnStatus();
    -- self:refreshDoSomethingBtn();           -- 刷新消息提示按钮的状态
    self:refreshLevelGiftBtn();

    local user_status = game_data:getUserStatusData();
    local action_point_rate = user_status.action_point_rate;
    local action_point_update_left = user_status.action_point_update_left;
    self:refreshTeamLayer();
    local combatValue = game_util:getCombatValue()
    -- self.m_combat_label:setString(tostring(combatValue));
    local tempCombatValue = game_data:getTempCombatValue();
    if tempCombatValue == 0 then
        self.m_combatNumberChangeNode:setCurValue(combatValue,false);
    else
        self.m_combatNumberChangeNode:setCurValue(tempCombatValue,false);
    end
    if tempCombatValue ~= 0 and combatValue ~= tempCombatValue and self.m_firstFlag == false then
        -- self.m_combat_label:setVisible(false);
        -- local function callBackFunc()
        --     self.m_combat_label:setVisible(true);
        -- end
        -- local anim_zhandouli = game_util:createEffectAnimCallBack("anim_zhandouli",1.0,false,callBackFunc);
        -- local pX,pY = self.m_combat_label:getPosition();
        -- anim_zhandouli:setPosition(ccp(pX + self.m_combat_label:getContentSize().width*0.5,pY))
        -- self.m_combat_label:getParent():addChild(anim_zhandouli);
        local changeValue = combatValue - tempCombatValue
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = combatValue,changeValue = changeValue});
    end
    game_data:setTempCombatValue(combatValue);
end

--[[--
    初始化
]]
function game_main_scene.init(self,t_params)
    -- cclog2(t_params, "t_params  ====   ")
    -- print_lua_table(t_params, 5)
    if luaCCBNode.addPublicResource then
        luaCCBNode:addPublicResource("ccbResources/public_res_add.plist");
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    t_params = t_params or {};
    -- game_sound:playMusic("background_home",true);
    self.m_resourcesAnimTable = {};
    self.m_btnShowFlag = self.m_btnShowFlag or true;
    self.m_teamNodeTab = {};
    self.m_firstFlag = t_params.firstFlag ~= nil and  t_params.firstFlag or false;
    self.m_tipsAnimTab = {};
    if self.m_firstFlag == true then
        public_config.action_rythm = 0.5
    end

    self.m_fristOpenPop = t_params.openPop

end


--[[--
    外部调用的创建ui方法
]]
function game_main_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    cclog("id ====================================" .. id)
    if id == 12 then
        self:gameGuide("drama","1",13);
    elseif id == 15 or id == 16 or id == 17 then
        self:gameGuide("drama","1",18);
    elseif id == 22 then
        self:gameGuide("drama","1",23);
    elseif id == 29 then--第二大步开始
        if game_data:getEquipGuideFlag() then
            self:gameGuide("drama","2",29);
        else
            self:gameGuide("drama","2",35);
        end
    elseif id == 33 or id == 34 then
        self:gameGuide("drama","2",35);
    -- elseif id == 50 then
    --     self:gameGuide("drama","3",51);
    else
        if id == 39 then
            -- self:gameGuide("show","2",39,{tempNode = self.m_battle_btn})
            game_guide_controller:gameGuide("send","2",39);
        end
        
        local id = game_guide_controller:getIdByTeam("3");
        if id == 302 then -- 技能升级
            self:gameGuide("show","3",302,{tempNode = self.m_partner_btn})
        else
            local id2 = game_guide_controller:getIdByTeam("5");
            if id2 == 502 then -- 碎片兑换
                self:gameGuide("show","5",502,{tempNode = self.m_partner_btn})
            elseif id2 == 505 then -- 伙伴进阶
                if game_data:getMaxLvCardFlag() == true then
                    game_guide_controller:gameGuide("send","5",505);
                    self:gameGuide("show","5",505,{tempNode = self.m_partner_btn})
                else
                    self:gameGuide("send","5",511);
                    self:showAnnouncement();
                end
            else
                local id = game_guide_controller:getIdByTeam("65");     -- 助威
                -- id = 6501
                if id == 6501 then
                    self:gameGuide("show","65", 6501,{tempNode = self.m_formation_btn})  
                else
                    local id = game_guide_controller:getIdByTeam("7");     -- 融合
                    -- id = 6501
                    -- if not adfadfas then
                    --     id = 700
                    -- else
                    --     id =
                    -- end
                    print("game_guide_controller:getIdByTeam(7)", id)
                    if (id ==701 or id ==705 ) and not game_data:isViewOpenByID(133) then
                        -- cclog2(id, "id == is not open ==========")
                        game_guide_controller:sendGuideData("7", 711)
                    elseif id == 701 then
                        -- adfadfas = true
                        self:gameGuide("drama","7", 701)  
                    elseif id == 705 then
                        self:gameGuide("drama","7", 705)  
                    else
                        self:showAnnouncement();  

                    end
                end
            end
        end
    end
    -- game_scene:addPop("game_error_pop",{errorStatus = "error_9"});
    -- self:chatTips()
    game_data:setMapType()   -- 重置地图类型
    if device.platform == "ios" and (getPlatFormExt() == "platform_EAGAMEBOX" or getPlatFormExt() == "platform_en_internation" or getPlatForm() == "cmgeapp") and game_data:isViewOpenByID( 42 ) then
        local luaoc = require("luaoc")
        luaoc.callStaticMethod("AppController", "addADDiAD", {})
    end

    return scene;
end

--[[--
    引导方法
]]
function game_main_scene.chatTips(self)
    -- 为聊天添加一个红点
    if self.m_chat_btn and self.m_chat_btn:getChildByTag(888) == nil then
        local ani = game_util:addTipsAnimByType(self.m_chat_btn,9);
        ani:setTag(888)
    end
    -- local delay = CCDelayTime:create(300)
    -- local callfunc = CCCallFunc:create(addPointForChatBtn)
    -- local sequence = CCSequence:createWithTwoActions(delay, callfunc)
    -- local action = CCRepeatForever:create(sequence)
    -- self.m_chat_btn:runAction(action)
end

--[[--
    消息提示
]]
function game_main_scene.refreshDoSomethingBtn(self)
    cclog2("game_main_scene  refresh DoSomething info ")
    local tips = require("game_do_tips")
    local tip = nil
    for k,v in pairs(tips) do
        -- print(k,json.encode(v))
        if v and v.enabled ~= false then
            if type(v.getDataFun) == "function" then
                local data = v.getDataFun()
                if type(v.isDataOKFun) == "function" then

                    if v.isOnlyOne and v.isDataOKFun( data ) then
                        tip = v
                        tip.data = v.getDataFun()
                    elseif v.isDataOKFun( data ) and game_main_scene.isCanShowTips(v.key, data, v.isMultiValue, v.isLocal) then
                        tip = v
                        tip.data = v.getDataFun()
                        break 
                    end
                end
            end
        end
    end

    self.m_do_something_btn:setPosition(-100, 125)  -- 将按钮移出屏幕
    self.m_do_something_btn:setVisible(false);   -- 提示按钮的隐藏

    if not tip then return end

    local params = {}
    params.showType = tip.key
    params.data = tip.getDataFun()


    if params.showType == "function" then
        if type(tip.showTipsEvent) == "function" then
            tip.showTipsEvent( tip.getDataFun() )
        else
            game_scene:addPop("game_do_something_pop", {gameData = params, activityData = chapterID_index})
        end
        if type(tip.showTipsEnd) == "function" then
            tip.showTipsEnd(params.data )
        end
    else
        local eventFun = function ( event, target)
            self.showTips(tip.key, tip.getDataFun(), tip.isMultiValue, tip.isLocal)
            game_scene:addPop("game_do_something_pop", {gameData = params, openType = "mainscene"})
            if type(tip.showTipsEnd) == "function" then
                tip.showTipsEnd(params.data )
            end
            self:refreshDoSomethingBtn()
        end

        self.m_do_something_btn:removeHandleOfControlEvent(CCControlEventTouchUpInside)
        self.m_do_something_btn:addHandleOfControlEvent(eventFun, CCControlEventTouchUpInside)
        self.m_do_something_btn:stopAllActions()
        self.m_do_something_btn:setVisible(true);   -- 提示按钮的显示
        self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_do_something_btn, 14);
        self.m_do_something_btn:setPositionX(-20)
        local moveBy = CCMoveBy:create(0.5, ccp(40, 0))
        self.m_do_something_btn:runAction(CCEaseBackIn:create(moveBy))
    end
end


function game_main_scene.isCanShowTips(key, data, isMultiValue, isLocal)
    if type(data) ~= "string" then data = tostring(data) end
    if not isLocal then
        if not game_data.m_talreadyTips then return false end
        if game_data.m_talreadyTips[key] then
            if isMultiValue then
                print(game_data.m_talreadyTips[key][data], "  game_data.m_talreadyTips[key][data]  ")
                -- print("data == ", data)
                return game_data.m_talreadyTips[key][data] ~= true 
            else
                return game_data.m_talreadyTips[key].data ~= data
            end
        end
        return true
    end
    if type(key) ~= "string" then assert(type(key) == "string") return false end
    local dayFlag = game_data:updateLocalData("DayFlag")
    if  dayFlag == "" then return true end
    if type(dayFlag) ~= "string" then return false end
    local flagTable = json.decode(dayFlag) 
    if not flagTable then return false end
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time = os.date("%Y%m%d", os.time())
    time = tostring(time)
    if not flagTable[time] then return true end
    local todayFlag = flagTable[time]
    if type(todayFlag) ~= "table" then return false end
    if not todayFlag[key] then return true end
    if isMultiValue then
        return todayFlag[key][data] ~= true 
    else
        return todayFlag[key].data ~= data
    end
    return false
end

function game_main_scene.showTips(key, data, isMultiValue, isLocal)
    if type(data) ~= "string" then data = tostring(data) end
    if not isLocal then
        if not game_data.m_talreadyTips then game_data.m_talreadyTips = {} end
        if not game_data.m_talreadyTips[key] then game_data.m_talreadyTips[key]= {} end
        if isMultiValue then
            game_data.m_talreadyTips[key][data] = true 
        else
            game_data.m_talreadyTips[key].data = data
        end
        return
    end
    if type(key) ~= "string" then assert(type(key) == "string") return false end
    local dayFlag = game_data:updateLocalData("DayFlag")
    local flagTable = {}
    if type(dayFlag) ~= "string" then  end
    if dayFlag == "" then 
        flagTable = {}
    else
        flagTable = json.decode(dayFlag) or flagTable
    end
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local time = os.date("%Y%m%d", os.time())
    time = tostring(time)
    if not flagTable[time] then 
        flagTable = {}
        flagTable[time] = {} 
    end
    local todayFlag = flagTable[time]
    if type(todayFlag) ~= "table" then todayFlag = {} end
    if isMultiValue then
        if not todayFlag[key] then todayFlag[key] = {} end
        todayFlag[key][data] = true 
    else
        todayFlag[key].data = data
    end
    flagTable[time] = todayFlag
    local info = json.encode(flagTable) or json.encode({})
    local dayFlag = game_data:updateLocalData("DayFlag", info)
    return false
end

function game_main_scene.isShowLiveActiveTips(self, key, data )
    -- do
    --     return false
    -- end
    if not key then assert(0) end
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local curdate = os.date("*t", server_time)
    local hour = curdate.hour

    local savedata = game_data:updateLocalData(key)
    -- print("shencundakaoyan  -- save data is ", savedata, tostring(savedata))
    if not savedata then return false end
    local save = json.decode(savedata)
    if not save then return false end
    if save.date ~= tostring( "" .. curdate.year .. curdate.month .. curdate.day  ) then return end
    for i,v in ipairs(save.data) do
        if v == data then 
            return true
        end
    end
    return true
end

function game_main_scene.showLiveActiveTips(self, key, data )
    if not key then assert(0) end
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local curdate = os.date("*t", server_time)
    local hour = curdate.hour
    local save = nil
    local savedata = game_data:updateLocalData(key)
    if not savedata then save = {} end
    if savedata then 
        save = json.decode(savedata) or {}
    end
    local today = "" .. curdate.year .. curdate.month .. curdate.day
    if save.date ~= today then save = {date = today, data = {}} end
    save.data[#save.data + 1] = today 
    -- print("shencundakaoyan  -- will save data is ", save, tostring(save), json.encode(save))
    game_data:updateLocalData(key, json.encode(save), true)
end




function game_main_scene.isAlreadyShowDataTips( key, oneDay, value)
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local curdate = os.date("*t", server_time)
    local hour = curdate.hour
end

function game_main_scene.refreshLevelGiftBtn(self)
    -- do 
    --     return 
    -- end
    self.m_conbtn_levelgift:setPosition(-100, self.m_do_something_btn:getPositionY() + 50)  -- 将按钮移出屏幕
    self.m_conbtn_levelgift:setVisible(false);   -- 提示按钮的隐藏

    if game_data:getAlertsDataByKey("level_gift") == nil or game_data:getAlertsDataByKey("level_gift") == false then        -- 条件达到 自动跳出限时购买选项
        return;
    end
    self.m_conbtn_levelgift:setVisible(true);   -- 提示按钮的显示
    self.m_tipsAnimTab[#self.m_tipsAnimTab+1] = game_util:addTipsAnimByType(self.m_conbtn_levelgift, 15);
    self.m_conbtn_levelgift:setPositionX(-20)
    local moveBy = CCMoveBy:create(0.5, ccp(40, 0))
    self.m_conbtn_levelgift:runAction(CCEaseBackIn:create(moveBy))

    local params = game_data:getAlertsDataByKey("level_gift")
    local time = nil
    if params and type(params) == "table" then 
        local minLevel = 9999
        for i,v in pairs(params) do
            if minLevel > tonumber(i) then
                minLevel = tonumber(i)
            end
        end
        time = params[tostring(minLevel)] or 1
    end
      -- 倒计时
    local function timeOverCallFun(label,type)
        local moveBy = CCMoveBy:create(0.5, ccp(-40, 0))
        self.m_conbtn_levelgift:runAction(CCEaseBackIn:create(moveBy))
        self.m_conbtn_levelgift:setVisible(false)
    end
    local offset = {{-0.5,0.5},{-0.5,-0.5},{0.5,-0.5},{0.5,0.5},{0,0},};
    local color = {ccc3(0,255,0),ccc3(0,0,0),ccc3(0,0,0),ccc3(0,0,0),ccc3(0,255,0),}
    local timeLabel = game_util:createCountdownLabel(tonumber(time) ,timeOverCallFun,8, 2)
    -- timeLabel:setFontSize(12.00)
    local size = self.m_conbtn_levelgift:getContentSize()
    timeLabel:setAnchorPoint(ccp( 0.5, 0.5 ))
    timeLabel:setPosition(size.width * 0.5, size.height * 0.5)
    self.m_conbtn_levelgift:addChild(timeLabel, 10000)
    timeLabel:setScale(14/12.0)
    timeLabel:setColor(ccc3(255, 255, 0))
end

function game_main_scene.isAlreadyShowDataTips(self, tipName, data )
    if game_data.m_talreadyTips[tipName] and game_data.m_talreadyTips[tipName].isShow == true then
        -- print("train data is --- ",game_data.m_talreadyTips[tipName].data, data)
        return game_data.m_talreadyTips[tipName].data ~= data
    end
    return true
end

function game_main_scene.isVipGiftUseful(self)
    local shopData = game_data:getShopData()
    local bought = shopData["vip_bought"]
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    for i=1,vipLevel + 1 do
        if bought[tostring(i)] ~= 1 then
            return true
        end
    end
    return false
end

function game_main_scene.getIsNewOpenButton(self)
    -- do
    --     return 108
    -- end
     -- 检查现在开启的功能 现在开启功能列表
    local curOpen = game_button_open:getOpenButtonIdList()
    local perOpen = game_data:getOpenButtonList()
    -- print("  per open is")
    -- print_lua_table(perOpen, 5)
    for i,v in pairs(curOpen) do
        -- print("open button is ",i, perOpen[i] ," == ", v)
        if v == true and perOpen[i] ~= true then
            -- print("-----------------------  find new gongneng ----------------------  gongneng id is ", i)
            return i
        end  
    end
    return nil
end

-- local force_guide = {}
-- local endfun = function ( guide_team )
--     game_guide_controller:showEndForceGuide(guide_team)
-- end
-- force_guide["10"] = {guide_team = "10", guide_id = 1001, game_main_scene = {"m_partner_btn"}, funBtnInfo = {key = "partner", btnID = 501} , guideEndfun = endfun}       -- 伙伴训练
-- force_guide["13"] = {guide_team = "13", guide_id = 1301, game_main_scene = {"m_leader_skill_btn"}, funBtnInfo =  {key = "heroInfo", btnID = 605} , guideEndfun = endfun}       -- 英雄技能
-- force_guide["14"] = {guide_team = "14", guide_id = 1401, game_main_scene = {"m_backpack_btn"}, funBtnInfo = {key = "backpack", btnID = 603} , guideEndfun = endfun}     -- 装备进阶
-- force_guide["15"] = {guide_team = "15", guide_id = 1501, game_main_scene = {"m_partner_btn"}, funBtnInfo = {key = "partner", btnID = 509} , guideEndfun = endfun}    -- 属性改造
-- force_guide["17"] = {guide_team = "17", guide_id = 1701, game_main_scene = {"m_battle_btn"}, map_world_scene = {"m_elite_levels_btn_2"} , guideEndfun = endfun}   -- 精英关卡
-- force_guide["18"] = {guide_team = "18", guide_id = 1801, game_main_scene = {"m_leader_skill_btn"}, funBtnInfo =  {key = "heroInfo", btnID = 606} , guideEndfun = endfun}      -- 统帅能力

function game_main_scene.forceGuideFun( self, forceInfo )
    if not forceInfo then return end
    local t_params = {}
    local finishOneStep = nil
    cclog2(forceInfo, "forceInfo === forceInfo")
    if forceInfo.game_main_scene.step then
        for i=1, forceInfo.game_main_scene.step do
            local thisStep = forceInfo.game_main_scene["step" .. tostring(i)] or {}
            if thisStep.state == false then
                t_params.tempNode = self[ thisStep.btn ]
                finishOneStep = function ( step )
                    thisStep.state = true
                    cclog2(forceInfo, "forceInfo === finishOneStep")
                end
                break
            end
        end
    else
        t_params.tempNode = self[ forceInfo.game_main_scene[1] ]
    end
    if not t_params.tempNode then return end
    t_params.clickCallFunc = function (  )
        -- cclog2("click")
        if type(finishOneStep) == "function" then finishOneStep() end
        game_scene:removeGuidePop()
    end
    t_params.skipFunc = function (  )
        if type(forceInfo.guideEndfun) == "function" then
            forceInfo.guideEndfun( forceInfo.guide_team )
        end
        -- game_data:setForceGuideInfo( nil )
    end
    game_scene:addGuidePop( t_params )
    game_data:setForceGuideInfo( forceInfo )

end

--[[
    检查时候需要新手引导
]]
function game_main_scene.guideHelper( self )
    local force_guide = game_data:getForceGuideInfo()
    if type(force_guide) == "table" and force_guide.game_main_scene then
        self:forceGuideFun( force_guide )
        return true
    else
        local  guidfun = function (  forceInfo )
            self:forceGuideFun( forceInfo )
        end
        return game_guide_controller:guideHelper( guidfun , "game_main_scene")
    end
    return false
end

--[[--
    引导方法
]]
function game_main_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "show" then
        game_guide_controller:showGuide(guide_team,guide_id,t_params);
    elseif guideType == "send" then
        game_guide_controller:sendGuideData(guide_team,guide_id)
    elseif guideType == "drama" then
        if guide_team == "1" and id == 13 then
            if type(game_data.setGuideProcess) == "function" then game_data:setGuideProcess("first_enter_main_scene") end
            local function endCallFunc()
                if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(29)  --[[完成drama1003 回到主页第一个drama 步骤29]] end
                self:gameGuide("send","1",13);
                self.m_bottom_btn_node:setPositionY(0);
                self.m_gacha_btn:setVisible(true);
                self:setBottomBtnSort();
                self:gameGuide("show","1",14,{tempNode = self.m_gacha_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "1" and id == 18 then
            if type(game_data.setGuideProcess) == "function" then game_data:setGuideProcess("second_enter_main_scene") end
            local function endCallFunc()
                if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(34)  --[[完成drama1004 回到主页 阵型drama 步骤34]] end
                self:gameGuide("send","1",18);
                self.m_bottom_btn_node:setPositionY(0);
                self.m_formation_btn:setVisible(true);
                self:setBottomBtnSort();
                self:gameGuide("show","1",19,{tempNode = self.m_formation_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "1" and id == 23 then
            if type(game_data.setGuideProcess) == "function" then game_data:setGuideProcess("third_enter_main_scene") end
            local function endCallFunc()
                self:gameGuide("send","1",23);
                self:gameGuide("show","1",24,{tempNode = self.m_battle_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "2" and id == 28 or id == 29 then
            if type(game_data.setGuideProcess) == "function" then game_data:setGuideProcess("guide_second") end
            local function endCallFunc()
                if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(46)   --[[完成剧情29步 -- 步骤46]] end
                -- self:gameGuide("send","2",29);
                self.m_bottom_btn_node:setPositionY(0);
                self.m_formation_btn:setVisible(true);
                self:setBottomBtnSort();
                self:gameGuide("show","2",30,{tempNode = self.m_formation_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "2" and id == 35 then
            if type(game_data.setGuideProcess) == "function" then game_data:setGuideProcess("guide_second_start_2_35") end
            local function endCallFunc()
                self:gameGuide("send","2",35);
                self:gameGuide("show","2",36,{tempNode = self.m_backpack_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "3" and id == 51 then
            local function endCallFunc()
                self:gameGuide("send","3",51);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "7" and id == 701 then
            local function endCallFunc()
                -- assert(false)
                self:gameGuide("show","7",702,{tempNode = self.m_conbtn_fuli})
                game_guide_controller:setGuideData("7",703);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "7" and id == 705 then
            local function endCallFunc()
                self:gameGuide("show", "7",705,{tempNode = self.m_shop_btn});
                game_guide_controller:setGuideData("7",706);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end



return game_main_scene;
