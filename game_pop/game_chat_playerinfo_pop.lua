---  ui模版

local game_chat_playerinfo_pop = {
    m_root_layer = nil,

    m_player_data = nil,
    m_gameData = nil,

    m_name = nil,
    m_association_name = nil,
    m_uid = nil,
    m_combat = nil,
    m_level = nil,

    m_backChatFun = nil,

    m_playerInfo = nil,
    m_node_avatarboard = nil,

};
--[[--
    销毁ui
]]
function game_chat_playerinfo_pop.destroy(self)
    -- body
    cclog("----------------- game_chat_playerinfo_pop destroy-----------------");  
    self.m_root_layer = nil;
    self.m_player_data = nil;

    self.m_gameData = nil;

    self.m_name = nil;
    self.m_association_name = nil;
    self.m_uid = nil;
    self.m_combat = nil;
    self.m_level = nil;

    self.m_backChatFun = nil;
    self.m_node_avatarboard = nil;
    self.m_playerInfo = nil;
end
--[[--
    返回
]]
function game_chat_playerinfo_pop.back(self,backType)
    game_scene:removePopByName("game_chat_playerinfo_pop");
	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_chat_playerinfo_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2( btnTag, "btnTag   ====  ")
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 1001 then  -- 查看信息
            -- game_scene:addPop("game_player_info_pop",{gameData = self.m_gameData})

            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop", {gameData = gameData})
            end
            local params = {};
            params.uid = self.m_uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
        elseif btnTag == 1002 then  -- 私聊
            if type(self.m_backChatFun) == "function" then
                self.m_backChatFun(self.m_uid, self.m_name)
            end
            self:back()
        elseif btnTag == 1003 then  -- 加为好友
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local msg = string_config:getTextByKeyAndReplaceOne("friend_send_add_friedn_tips", "PLAYER", self.m_name)
                game_util:addMoveTips({text = msg});
            end
            local params = {};
            params.target_id = self.m_uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_apply_friend"), http_request_method.GET, params,"friend_apply_friend")
        elseif btnTag == 1004 then  -- 联盟邀请
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local msg = string_config:getTextByKeyAndReplaceOne("guild_send_invite_tips", "PLAYER", self.m_name or "对方")
                game_util:addMoveTips({text = msg});
            end
            local params = {};
            params.target_id = self.m_uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_chat_playerinfo.ccbi");



    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 8,true);
    m_root_layer:setTouchEnabled(true);

    local btnTitles = {string_helper.game_chat_playerinfo_pop.btnTitles1, string_helper.game_chat_playerinfo_pop.btnTitles2, string_helper.game_chat_playerinfo_pop.btnTitles3, string_helper.game_chat_playerinfo_pop.btnTitles4}
    for i=1,4 do
        local btn = ccbNode:controlButtonForName("m_conbtn_btn" .. i)
        if btn then
            btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);
            game_util:setCCControlButtonTitle(btn, btnTitles[i])
        end
        local myuid =  game_data:getUserStatusDataByKey("uid")
        if tostring(myuid) == tostring(self.m_uid) then
            if i == 1 then 
                btn:setPositionX(btn:getParent():getContentSize().width * 0.5)
                btn:setPositionY(btn:getParent():getContentSize().height * 0.4)
            elseif i > 1 then
                btn:setVisible(false)
            end
        end
    end

    -- 头像
    local avatarID = self.m_playerInfo.avatarID
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
        if self.m_playerInfo.vip and self.m_playerInfo.vip > 0 then
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

    local m_node_avatarboard = ccbNode:nodeForName("m_node_avatarboard")
    if avatar then
        avatar:setScale(0.9)
        avatar:setPositionX(m_node_avatarboard:getContentSize().width * 0.5)
        avatar:setPositionY(m_node_avatarboard:getContentSize().height * 0.5)
        m_node_avatarboard:addChild(avatar)
    end

    -- 重置按钮出米优先级 防止被阻止
    local m_close_btn = ccbNode:controlButtonForName("m_closeBtn");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);


      -- 人物等级
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_level_" .. i)
        if label then 
            label:setString(tostring(self.m_level or "??"))
        end
    end
    -- 昵称
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_name_" .. i)
        if label then 
            label:setString(self.m_name or "")
        end
    end

    -- 联盟信息
    for i=1,2 do
        local label = ccbNode:labelTTFForName("m_label_guildname" .. i)
        if label then 
            label:setString( self.m_association_name or "" )
        end
    end

    -- vip 信息
    local m_vip_label = ccbNode:labelTTFForName("m_vip_label")
    local m_vip_node = ccbNode:labelTTFForName("m_vip_node")
    if game_data:isViewOpenByID(101) and self.m_playerInfo.vip  > 0 then
        m_vip_node:setVisible(true)
        m_vip_label:setString("VIP")
    else
        m_vip_node:setVisible(false)
    end

    local m_combat_label = ccbNode:labelBMFontForName("top")
    if m_combat_label then 
        m_combat_label:setString(tostring( self.m_combat or 0))
    end

    local m_conbtn_btn5 = ccbNode:controlButtonForName("m_conbtn_btn5")
    game_util:setCCControlButtonTitle(m_conbtn_btn5,string_helper.ccb.text106)
    local m_conbtn_btn6 = ccbNode:controlButtonForName("m_conbtn_btn6")
    game_util:setCCControlButtonTitle(m_conbtn_btn6,string_helper.ccb.text107)
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_chat_playerinfo_pop.refreshUi(self)
    


end
--[[--
    初始化
]]
function game_chat_playerinfo_pop.init(self,t_params)
    t_params = t_params or {}
    -- print("game_chat_playerinfo_pop   - data is ", t_params.gameData:getFormatBuffer())
    -- print_lua_table(t_params, 10)

    self.m_gameData = t_params.gameData

    local data = self.m_gameData:getNodeWithKey("data")
    self.m_name = data:getNodeWithKey("name") and data:getNodeWithKey("name"):toStr() or ""
    self.m_association_name = data:getNodeWithKey("association_name") and data:getNodeWithKey("association_name"):toStr() or ""
    self.m_uid = data:getNodeWithKey("uid") and data:getNodeWithKey("uid"):toStr() or nil
    self.m_combat = data:getNodeWithKey("combat") and data:getNodeWithKey("combat"):toInt() or 0
    self.m_level = data:getNodeWithKey("level") and data:getNodeWithKey("level"):toInt() or 0


    self.m_backChatFun = t_params.backChatFun

    self.m_playerInfo = t_params.playerInfo

    self.m_playerInfo.vip = self.m_playerInfo.vip or 0

end

--[[--
    创建ui入口并初始化数据
]]
function game_chat_playerinfo_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_chat_playerinfo_pop;
