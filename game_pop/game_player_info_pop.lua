--- 编队信息 

local game_player_info_pop = {
   m_params = nil,
   m_progress_bg = nil,
   m_stageTab = nil,
   m_label_roleName = nil,
   m_label_guildName = nil,
   m_combat_label = nil,
   m_node_roleHead = nil,
   m_selLeftIndex = nil,
   m_selRightIndex = nil,
   m_table_tab_btns = nil,

   m_player_data = nil,
   m_scroll_rightboard = nil,

   m_boss_icons = nil,
   m_node_iconboard1 = nil,
   m_node_iconboard2 = nil,
   m_node_iconboard3 = nil,
   m_fate_node = nil,
   m_fate_label = nil,
   m_show_fate_type = nil,
   m_sel_index = nil,
   m_skill_layer = nil,
   m_add_friend_btn = nil,
   m_add_guild_btn = nil,
   m_uid = nil,
   m_name = nil,
   m_label_uid = nil,
   isFriend = nil,
   m_enterType = nil,
   m_curshow_9hero_info = nil,  -- 出战阵型之外的其他阵型
    m_tempTeamData = nil,
   m_tempFriendData = nil,
    m_tempEquipPosData = nil,
    m_tempGemPosData = nil,
   m_tempDestinyData = nil,
   m_tempAssEquipPosData = nil,
   m_node_baoshiinfo = nil,

};

--[[--
    销毁
]]
function game_player_info_pop.destroy(self)
    -- body
    cclog("-----------------game_player_info_pop destroy-----------------");
    self.m_params = nil;
    self.m_progress_bg = nil;
    self.m_stageTab = nil;
    self.m_label_roleName = nil;
    self.m_label_guildName = nil;
    self.m_combat_label = nil;
    self.m_node_roleHead = nil;
    self.m_selLeftIndex = nil;
    self.m_selRightIndex = nil;
    self.m_table_tab_btn_= nil;
    self.m_player_data = nil;
    self.m_scroll_rightboard = nil;
    self.m_boss_icons = nil;
    self.m_node_iconboard1 = nil;
    self.m_node_iconboard2 = nil;
    self.m_node_iconboard3 = nil;
    self.m_fate_node = nil;
    self.m_fate_label = nil;
    self.m_show_fate_type = nil;
    self.m_sel_index = nil;
    self.m_skill_layer= nil;
    self.m_add_friend_btn = nil;
    self.m_add_guild_btn = nil;
    self.m_uid = nil;
    self.m_name = nil;
    self.m_label_uid = nil;
    self.isFriend = nil;
    self.m_enterType = nil;
    self.m_curshow_9hero_info = nil;
    self.m_tempTeamData = nil;
    self.m_tempFriendData = nil;
    self.m_tempEquipPosData = nil;
    self.m_tempGemPosData = nil;
    self.m_tempDestinyData = nil;
    self.m_tempAssEquipPosData = nil;
    self.m_node_baoshiinfo = nil
end
--[[--
    返回
]]
function game_player_info_pop.back(self,type)
        -- local function endCallFunc()
        --     self:destroy();
        -- end
        -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    game_scene:removePopByName("game_player_info_pop");
end

--[[--
    读取ccbi创建ui
]]
function game_player_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == ", btnTag)
        if btnTag == 1 then
          self:back()
        elseif btnTag == 102 then
            if self.m_uid then
                local function responseMethod(tag,gameData)
                    -- cclog2(gameData, "gameData  ====  ")
                    game_util:addMoveTips({text = string_helper.game_player_info_pop.applyInfo});
                end
                local params = {};
                params.target_id = self.m_uid;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_apply_friend"), http_request_method.GET, params,"friend_apply_friend")
            end
        elseif btnTag == 103 then
            if self.m_uid then
                local function responseMethod(tag,gameData)
                    -- cclog2(gameData, "gameData  ====  ")
                    local msg = string_config:getTextByKeyAndReplaceOne("guild_send_invite_tips", "PLAYER", self.m_name or string_helper.game_player_info_pop.other)
                    game_util:addMoveTips({text = msg});
                end
                local params = {};
                params.target_id = self.m_uid;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
            end

        elseif btnTag == 11 then

        elseif btnTag == 1001 then  -- 阵型
            self.m_selLeftIndex = 1
            self:refreshUi()
        elseif btnTag == 1002 then   -- 助威
            self.m_selLeftIndex = 2
            self:refreshUi()
        elseif btnTag == 1003 then   -- 命运
            self.m_selLeftIndex = 3
            self:refreshUi()
        elseif btnTag == 1004 then  -- 装备
            self.m_selRightIndex = 4
            self:refreshUi()
        elseif btnTag == 1005 then   -- 属性
            self.m_selRightIndex = 5
            self:refreshUi()
        else
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_newplayer_info_scene.ccbi");

    self.m_node_roleHead = ccbNode:nodeForName("m_node_roleHead")
    self.m_label_roleName = ccbNode:labelTTFForName("m_label_roleName")
    self.m_label_guildName = ccbNode:labelTTFForName("m_label_guildName")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_node_iconboard1 = ccbNode:nodeForName("m_node_iconboard1")
    self.m_node_iconboard2 = ccbNode:nodeForName("m_node_iconboard2")
    self.m_node_iconboard3 = ccbNode:nodeForName("m_node_iconboard3")
    self.m_add_friend_btn = ccbNode:controlButtonForName("m_add_friend_btn")
    self.m_add_guild_btn = ccbNode:controlButtonForName("m_add_guild_btn")
    self.m_label_uid = ccbNode:labelTTFForName("m_label_uid")
    self.m_node_baoshiinfo = ccbNode:nodeForName("m_node_baoshiinfo")

    local m_label_nameTitle = ccbNode:labelTTFForName("m_label_nameTitle");
    local m_label_guildTitle = ccbNode:labelTTFForName("m_label_guildTitle");
    m_label_nameTitle:setString(string_helper.ccb.file31);
    m_label_guildTitle:setString(string_helper.ccb.file32);
    local m_table_tab_label_1 = ccbNode:labelTTFForName("m_table_tab_label_1");
    local m_table_tab_label_2 = ccbNode:labelTTFForName("m_table_tab_label_2");
    local m_table_tab_label_3 = ccbNode:labelTTFForName("m_table_tab_label_3");
    local m_table_tab_label_4 = ccbNode:labelTTFForName("m_table_tab_label_4");
    local m_table_tab_label_5 = ccbNode:labelTTFForName("m_table_tab_label_5");
    m_table_tab_label_1:setString(string_helper.ccb.file33);
    m_table_tab_label_2:setString(string_helper.ccb.file34);
    m_table_tab_label_3:setString(string_helper.ccb.file74);
    m_table_tab_label_4:setString(string_helper.ccb.file35);
    m_table_tab_label_5:setString(string_helper.ccb.file36);
    local title50 = ccbNode:labelTTFForName("title50");
    local title51 = ccbNode:labelTTFForName("title51");
    local title52 = ccbNode:labelTTFForName("title52");
    title51:setString(string_helper.ccb.title51);
    title50:setString(string_helper.ccb.title50);
    title52:setString(string_helper.ccb.title52);

    if not game_data:isViewOpenByID(130) then   -- 宝石
        local m_node_baoshiinfo = ccbNode:nodeForName("m_node_baoshiinfo")
        if m_node_baoshiinfo then
            m_node_baoshiinfo:setVisible(false)
        end
        local ui_node_equipinfo = ccbNode:nodeForName("m_node_equipinfo")
        if ui_node_equipinfo then
            ui_node_equipinfo:setPositionY( m_node_baoshiinfo:getPositionY() - 20)
        end
    end

    if not game_data:isViewOpenByID(44) then  -- 转生
        local ui_node_zhuanshenginfo = ccbNode:nodeForName("m_node_zhuanshenginfo")
        if ui_node_zhuanshenginfo then
            ui_node_zhuanshenginfo:setVisible(false)
            local ui_node_equipinfo = ccbNode:nodeForName("m_node_equipinfo")
            if ui_node_equipinfo then
                ui_node_equipinfo:setPositionY( ui_node_zhuanshenginfo:getPositionY())
            end
        end
    end

    self.m_label_uid:setString(string_helper.game_player_info_pop.userId .. (self.m_uid or ""))


    self.m_break_icons = {}
    for i=1,5 do
        self.m_break_icons[i] = ccbNode:spriteForName("m_break_icon_" .. i)
    end
    
    self.m_sprite_stones = {}
    for i=1,4 do
        self.m_sprite_stones[i] = ccbNode:spriteForName("m_sprite_stone_" .. i)
    end

    self.m_sprite_equips = {}
    for i=1,4 do
        self.m_sprite_equips[i] = ccbNode:spriteForName("m_sprite_equip_" .. i)
    end

    self.m_table_tab_btns = {}
    for i=1, 5 do
        self.m_table_tab_btns[i] = ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
    end
    self.m_scroll_rightboard = ccbNode:scrollViewForName("m_scroll_rightboard")
    self.m_scroll_rightboard:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)

    self.m_boss_icons = {}
    for i=1,9 do
        self.m_boss_icons[i] = ccbNode:nodeForName("m_sprite_icon" .. i)
        j = i + 10
        self.m_boss_icons[j] = ccbNode:nodeForName("m_sprite_icon" .. j)
    end


    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local function onTouch(eventType, x, y)
    if eventType == "began" then
        -- self:back();
        return true;--intercept event
    end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9,true);
    self.m_root_layer:setTouchEnabled(true);

    
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    for i=1,5 do
        local btn = ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        if btn then btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11) end
    end
    self.m_add_friend_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_add_guild_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    game_util:setControlButtonTitleBMFont(self.m_add_guild_btn)
    game_util:setControlButtonTitleBMFont(self.m_add_friend_btn)

    game_util:setCCControlButtonTitle(self.m_add_guild_btn,string_helper.ccb.file75)
    game_util:setCCControlButtonTitle(self.m_add_friend_btn,string_helper.ccb.file76)


    if tostring(self.m_uid) == tostring(game_data:getUserStatusDataByKey("uid"))  or self.m_enterType == 2 then  -- 自己
        self.m_add_friend_btn:setVisible(false);
        self.m_add_guild_btn:setVisible(false);
    else
        local posX = self.m_add_guild_btn:getPositionX()

        if self.m_params.boss_data and self.m_params.boss_data.user and self.m_params.boss_data.user.association_id == 0 then  -- 无工会
            if self.isFriend then
                posX = self.m_add_guild_btn:getParent():getContentSize().width * 0.56
                self.m_add_guild_btn:setPositionX( posX )
            else
                posX = self.m_add_friend_btn:getPositionX()
            end
        else
            posX = self.m_add_friend_btn:getParent():getContentSize().width * 0.56
            self.m_add_guild_btn:setVisible(false)
        end
        if not self.isFriend then
            self.m_add_friend_btn:setPositionX( posX )
            self.m_add_friend_btn:setVisible(true)
        else
            self.m_add_friend_btn:setVisible(false)
        end
    end 

        --- 左侧按钮 根据命运是否显示调整按钮
    local posys = {
        {0.5},
        {0.52, 0.28},
        {0.55, 0.38, 0.22}
    }

    local posy = posys[2]
    if game_data:isViewOpenByID( 202 ) then
        posy = posys[3]
    end

    for i=1, 3 do
        local m_table_tab_btn = ccbNode:nodeForName("m_table_tab_btn_" .. i)
        local m_table_tab_label = ccbNode:nodeForName("m_table_tab_label_" .. i)
        if posy[i] then
            m_table_tab_label:setVisible(true)
            m_table_tab_label:setVisible(true)
            local parentNode = m_table_tab_label:getParent()
            m_table_tab_label:setPositionY( parentNode:getContentSize().height * posy[i] )
            m_table_tab_btn:setPositionY( parentNode:getContentSize().height * posy[i] )
        else
            m_table_tab_label:setVisible(false)
            m_table_tab_label:setVisible(false)
        end
    end
  
    self:updateTopPlayerBaseInfo()
    return ccbNode;
end


--[[--
    更新玩家基本信息
]]
function game_player_info_pop.updateTopPlayerBaseInfo( self )
    
    local role = 1  -- 头像
    local name = string_config:getTextByKey("m_topplayer_unnowname")  -- 公会
    local guild = string_config:getTextByKey("m_topplayer_noguild")   -- 昵称

    if self.m_params.boss_data and self.m_params.boss_data.user then
        role = self.m_params.boss_data.user.role
    end
    local selfHalf = game_util:createRoleBigImgHalf(role)
    selfHalf:setAnchorPoint(ccp(0.5, 0))
    local scale = self.m_node_roleHead:getContentSize().width / selfHalf:getContentSize().width * 1.5
    selfHalf:setPositionX(self.m_node_roleHead:getContentSize().width  * 0.5)
    selfHalf:setScale(scale)
    self.m_node_roleHead:addChild(selfHalf, 10)
    -- self.m_node_roleHead:getParent():reorderChild(m_node_showh, 11)
    
    if self.m_params.boss_data and self.m_params.boss_data.user then
        name = self.m_params.boss_data.user.name or name
        if self.m_params.boss_data.user.association_name and self.m_params.boss_data.user.association_name ~= "" then
            guild = self.m_params.boss_data.user.association_name 
        end
    end
    if self.m_label_roleName then
        self.m_label_roleName:setString(name)
    end
    if self.m_label_guildName then
        self.m_label_guildName:setString(guild)
    end
    if self.m_combat_label then
        self.m_combat_label:setString(tostring(self.m_params.boss_data.user and self.m_params.boss_data.user.combat or 0))
    end
end

--[[--
     右侧信息的滑动栏
]]
function game_player_info_pop.initRightContentInfo( self, index )

    self.m_scroll_rightboard:getContainer():removeAllChildrenWithCleanup(true)

    local ccbNode = luaCCBNode:create();
    local roleIndex_use = index

    local cardData,cardCfg = self:getCardDataByPos( roleIndex_use )

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "btnTag === ")
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_playerinfo_item4.ccbi");

    local skillsIcon = {}
    for i=1, 3 do
        skillsIcon[i] = ccbNode:spriteForName("m_skill_" .. i)
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local roleIndex = math.floor(btnTag % 10000 )
        roleIndex = math.floor(roleIndex / 100)
        local index = math.floor(btnTag %100)

        print(roleIndex, " ", roleIndex, " roleIndex ====  ")

        if btnTag > 20000 and btnTag < 30000 then
            local index = btnTag - 20000
            self:initRightContentInfo( index )
        elseif btnTag >50000 and btnTag < 60000 then  -- 转生信息
            self:showBreakInfo( roleIndex, index)

        elseif btnTag >60000 and btnTag < 70000 then -- 装备信息
            self:showEquipInfo( roleIndex, index)
        elseif btnTag >70000 and btnTag < 80000 then  -- 技能信息
            self:showSkillInfo( roleIndex, index)
        elseif btnTag >= 80000 and btnTag < 90000 then
            self:initRightContentInfo(roleIndex)
        elseif btnTag >= 90000 then
            self:showGemInfo( roleIndex, index)
        end
    end

    local m_fate_node = ccbNode:nodeForName("m_fate_node")
    local m_node_fate = ccbNode:nodeForName("m_node_fate")
    local m_life_label = ccbNode:labelBMFontForName("m_life_label")
    local m_physical_atk_label = ccbNode:labelBMFontForName("m_physical_atk_label")
    local m_magic_atk_label = ccbNode:labelBMFontForName("m_magic_atk_label")
    local m_def_label = ccbNode:labelBMFontForName("m_def_label")
    local m_speed_label = ccbNode:labelBMFontForName("m_speed_label")
    local m_skill_layer = ccbNode:layerForName("m_skill_layer")
    local m_node_title_fate = ccbNode:nodeForName("m_node_title_fate")
    local m_node_fumo = ccbNode:nodeForName("m_node_fumo")  -- 附魔属性
    local m_label_cardLevel = ccbNode:labelTTFForName("m_label_cardLevel")
    local title104 = ccbNode:labelTTFForName("title104");
    local title105 = ccbNode:labelTTFForName("title105");
    local title106 = ccbNode:labelTTFForName("title106");
    title106:setString(string_helper.ccb.title106);
    title105:setString(string_helper.ccb.title105);
    title104:setString(string_helper.ccb.title104);
    m_label_cardLevel:setVisible(false)

    if cardData and cardCfg then
        m_life_label:setString(cardData.hp or "---" );
        m_physical_atk_label:setString(cardData.patk or "---");
        m_magic_atk_label:setString(cardData.matk or "---");
        m_def_label:setString(cardData.def or "---");
        m_speed_label:setString(cardData.speed or "---");


        -- m_label_cardLevel:setString(cardData.lv .. "/" .. cardData.level_max);
        m_label_cardLevel:setString(cardData.lv);
        m_label_cardLevel:setVisible(true)

        local chainTab = game_util:cardChainByCfg(cardCfg,cardData.id, self.m_player_data)
        self.m_chainTab = chainTab;
        if #chainTab > 0 then
            local showStr = ""
            local nameStr = "";
            for i=1,#chainTab do
                showStr = showStr .. chainTab[i].detail .. "\n"
            end
            local labelsize = CCSizeMake(m_fate_node:getContentSize().width , 0);
            local m_fate_label = game_util:createRichLabelTTF({text = showStr,dimensions = labelsize,
                    textAlignment = kCCTextAlignmentLeft,
                verticalTextAlignment = nil,color = ccc3(221,221,192)})
            m_fate_label:setAnchorPoint(ccp(0.5, 0.5));
            m_fate_label:setPosition(ccp(labelsize.width * 0.5 + 5, m_fate_label:getContentSize().height * 0.5 - 5))
            local new_lab_size = m_fate_label:getContentSize()
            m_node_fate:setContentSize(new_lab_size)
            m_fate_node:setContentSize(CCSizeMake(labelsize.width, new_lab_size.height + 10))
            m_node_fate:addChild(m_fate_label)
            m_node_fate:setAnchorPoint(ccp(0.5,0))
            m_node_fate:setPositionY(0)
            m_node_title_fate:setPositionY(new_lab_size.height + 10)
        else
        end
        for i=1,3 do
             local skill = cardData["s_" .. i]
            local m_skill_icon_bg = skillsIcon[i];
            local tempSize = m_skill_icon_bg:getContentSize();
            local aminFlag = true;
            if skill then
                local tempIcon = game_util:createSkillIconByCid(skill.s, skill.avail)
                if tempIcon then
                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                    m_skill_icon_bg:addChild(tempIcon);
                    self:createTouchButton(onBtnCilck, tempIcon, 70000 + i + roleIndex_use * 100)
                end
            end
        end
        local tempNode = nil;
        -- 装备信息
        for i=1,4 do
            tempNode = self.m_sprite_equips[i]
            if tempNode then
                tempNode:removeAllChildrenWithCleanup(true);
            end
            tempNode = self.m_sprite_stones[i]
            if tempNode then
                tempNode:removeAllChildrenWithCleanup(true);
            end
        end
        if cardData and self.m_selLeftIndex == 1 or self.m_selLeftIndex == 2 then
            -- local equipPosData = self.m_tempEquipPosData[index]
            local equipPosData = self:getPosEquip(index)
            -- cclog2(equipPosData, "equipPosData  =====   ")
            if equipPosData then
                if equipPosData then
                    local noUseEquipCountTab = self.m_player_data:getNoUseEquipCountTab();
                    for i=1,4 do
                        tempNode = self.m_sprite_equips[i]  
                        if tempNode then
                            local tempNodeSize = tempNode:getContentSize();
                            local id = equipPosData[i];
                            if id and id ~= "0" then
                                local equipItemData,equipItemCfg = self.m_player_data:getEquipDataById(tostring(id));
                                local equipIcon = game_util:createEquipIcon(equipItemCfg);
                                if equipIcon then
                                    equipIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                                    tempNode:addChild(equipIcon,10,10)
                                    self:createTouchButton(onBtnCilck, tempNode, 60000 + i + roleIndex_use * 100)

                                    local sl =  equipItemData.st_lv or 0
                                    if sl > 0 then
                                        -- 星星标志
                                        local star = CCSprite:createWithSpriteFrameName("public_equip_star.png");
                                        star:setPositionY(tempNode:getContentSize().height)
                                        tempNode:addChild(star, 20)
                                        local labelG = game_util:createLabelTTF({text = tostring(sl), fontSize = 12, color = ccc3(255, 255, 0)})
                                        labelG:setAnchorPoint(ccp(0,0.5))
                                        labelG:setPosition(ccp(star:getContentSize().width * 1.2, star:getContentSize().height * 0.5))
                                        star:addChild(labelG)
                                    end

                                    local  lv = equipItemData.lv or 1
                                    local labelL = game_util:createLabelTTF({text = "+" .. lv, fontSize = 12, color = ccc3(0, 255, 0)})
                                    labelL:setAnchorPoint(ccp(0.5, 1))
                                    labelL:setPosition(ccp(equipIcon:getContentSize().width * 0.5, -2))
                                    equipIcon:addChild(labelL)

                                end
                            end
                        end
                    end
                end
            end

            if self.m_selLeftIndex == 1 then
                local gemPosData = self.m_tempGemPosData[index]
                if gemPosData then
                    for i=1,4 do
                        tempNode = self.m_sprite_stones[i] 
                        if tempNode then
                            local tempNodeSize = tempNode:getContentSize();
                            local id = gemPosData[i];
                            if id and tostring(id) ~= "0" then
                                local tempIcon,gemName = game_util:createGemIconByCid(id);
                                if tempIcon then
                                    tempIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                                    tempNode:addChild(tempIcon,10,10)
                                    self:createTouchButton(onBtnCilck, tempNode, 90000 + i + roleIndex_use * 100)
                                end
                                -- if gemName then
                                --     local tempLabel = game_util:createLabelTTF({text = gemName,color = ccc3(250,255,0),fontSize = 16});
                                --     tempLabel:setPosition(ccp(tempNodeSize.width*0.5,-tempNodeSize.height*0.15))
                                --     tempNode:addChild(tempLabel,11,11)
                                -- end
                            end
                        end
                    end
                end
            end
            if self.m_node_baoshiinfo then self.m_node_baoshiinfo:setVisible(self.m_selLeftIndex == 1) end
        end

        local bre = cardData.bre or 0
        for i=1,5 do
            local tempNode = self.m_break_icons[i]
            if tempNode then
                tempNode:removeAllChildrenWithCleanup(true)
                if bre >= i then
                    tempNode:setColor(ccc3(255, 255, 255))
                else
                    tempNode:setColor(ccc3(155, 155, 155))
                end
                local tempSize = tempNode:getContentSize()
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                button:setOpacity(0)
                tempNode:addChild(button)
                button:setTag(50000 + i + roleIndex_use * 100)
            end
        end

        -- 附魔属性
        local abilityTab = game_util:getOtherCardAttrValueByCardId(index, cardData, self.m_player_data)
        abilityTab = abilityTab or {}
        for k,v in pairs(COMBAT_ABILITY_TABLE.card) do
            local f_id = COMBAT_ABILITY_TABLE.card_evo[k] or ""
            local evo_tab = PUBLIC_ABILITY_TABLE["ability_" .. tostring(f_id)] or {}
            local icon_spr = ccbNode:spriteForName("m_spr_f_sign" .. tostring(k)) 
            local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( evo_tab.icon );
            if icon_spr then
                if tempDisplayFrame then
                    icon_spr:setDisplayFrame( tempDisplayFrame )
                end
            end
            local tempLabel = ccbNode:labelBMFontForName("m_label_fomo" .. tostring(k)) 
            local value1 = abilityTab[v] or 0
            if tempLabel then
                tempLabel:setString(tostring(value1));
            else

            end
        end
    else
        m_life_label:setString("---");
        m_physical_atk_label:setString("---");
        m_magic_atk_label:setString("---");
        m_def_label:setString("---");
        m_speed_label:setString("---");
    end

    local height = 0
    local m_node_normal = ccbNode:nodeForName("m_node_normal")   -- 普通属性
    height = height + m_node_normal:getContentSize().height
    local m_skill_node = ccbNode:nodeForName("m_skill_node")  -- 技能
    height = height + m_skill_node:getContentSize().height

    if game_data:isViewOpenByID( 130 ) then
        height = height + m_node_fumo:getContentSize().height
        m_node_fumo:setVisible(true)
        if self.m_node_baoshiinfo then self.m_node_baoshiinfo:setVisible( self.m_selLeftIndex == 1 ) end
    else
        m_node_fumo:setVisible(false)
        if self.m_node_baoshiinfo then self.m_node_baoshiinfo:setVisible( false ) end
    end

    height = height + m_fate_node:getContentSize().height
    height = height + 8
    local newSize = CCSizeMake(ccbNode:getContentSize().width, height)
    ccbNode:setContentSize(newSize)


    local y = height - 8
    m_node_normal:setAnchorPoint(ccp(0,1))
    m_node_normal:setPositionY( y )
    y = y - m_node_normal:getContentSize().height

    if game_data:isViewOpenByID( 130 ) then
        m_node_fumo:setAnchorPoint(ccp(0,1))
        m_node_fumo:setPositionY(y)
        y = y - m_node_fumo:getContentSize().height
    end
    m_fate_node:setAnchorPoint(ccp(0,1))
    m_fate_node:setPositionY(y)
    y = y - m_fate_node:getContentSize().height
    y = y -10
    m_skill_node:setAnchorPoint(ccp(0,1))
    m_skill_node:setPositionY(y)
    y = y - m_skill_node:getContentSize().height

    local sNode = ccbNode
    self.showInfoNode = sNode;
    self.m_scroll_rightboard:getContainer():addChild(self.showInfoNode)
    local itemSize = CCSizeMake(sNode:getContentSize().width , sNode:getContentSize().height)
    self.m_scroll_rightboard:setContentSize(sNode:getContentSize())
    sNode:setPositionY(0)
    local offsetY = itemSize.height - self.m_scroll_rightboard:getViewSize().height
    self.m_scroll_rightboard:setContentOffset(ccp(0, -offsetY), false)
end

--[[--
    显示装备信息
]]
function game_player_info_pop.showEquipInfo( self, roleIndex, index)
    local cardData,cardCfg = self:getCardDataByPos(roleIndex)
    local tempEquipId = self:getPosEquipId(roleIndex, index);
    local itemData = self.m_player_data:getEquipDataById(tempEquipId)
    local equipData = self:getEquipData(roleIndex)
    game_scene:addPop("game_equip_info_pop",{tGameData = itemData,posEquipData = equipData ,openType=4, equipData = self.m_player_data:getEquipData()});    
end

--[[--
    显示装备信息
]]
function game_player_info_pop.showGemInfo( self, roleIndex, index)
    if self.m_tempGemPosData[roleIndex] then
        local tempGemId = self.m_tempGemPosData[roleIndex][index]
        if tempGemId ~= "0" then
            game_scene:addPop("gem_system_info_pop",{tGameData = {count = 1,c_id = tempGemId},callBack = nil, openType=4});
        end
    end  
end

--[[--
    显示转生信息
]]
function game_player_info_pop.showBreakInfo( self, roleIndex, index )
    local cardData,cardCfg = self:getCardDataByPos(roleIndex)
    if cardData and cardCfg then
        game_scene:addPop("hero_breakthrough_detail_pop",{cardCfgId = cardData.c_id,
        breValue = cardData.bre or 0 ,selBreValue = index})
    end
                    
end

--[[--
    显示技能信息
]]
function game_player_info_pop.showSkillInfo( self, roleIndex, index )
    local cardData,cardCfg = self:getCardDataByPos(roleIndex)
    local skill = cardData["s_" .. index]
    game_scene:addPop("skills_activation_pop",{skillData = skill, selHeroId=cardData.c_id ,posIndex = index}) 
end

--[[
    获取某个阵型位置上的装备信息
]]
function game_player_info_pop.getPosEquip( self, equipPos )
    local equipData = {}
    if self.m_selLeftIndex == 1 then
        equipData = self.m_tempEquipPosData
    elseif self.m_selLeftIndex == 2  then
        equipData = self.m_tempAssEquipPosData
    end
    return equipData[equipPos];
end

--[[--
    获得位置上的装备ID
]]
function game_player_info_pop.getPosEquipId(self,equipPos,equipType)
    local tempEquipId = 0;
    local equipData = {}
    if self.m_selLeftIndex == 1 then
        equipData = self.m_tempEquipPosData
    elseif self.m_selLeftIndex == 2  then
        equipData = self.m_tempAssEquipPosData
    end
    if equipData[equipPos] then
        tempEquipId = equipData[equipPos][equipType]
    end
    return tempEquipId;
end

--[[--
    创建一个接受触摸事件的button
]]
function game_player_info_pop.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button)
    button:setTag(tag)
end


--[[--
    刷新左侧标签属性  阵型1/助威2/命运3  装备4/属性5
]] 
function game_player_info_pop.refreshTabBtn(self)
    local tempBtn = nil;
    local tempNode = nil;
    local board_id1 = {1, 2, 2}
    for i=1, 2 do
        tempNode = self["m_node_iconboard" .. i]
        if tempNode then
            tempNode:setVisible(false)
        end
    end
    for i=1, 3 do
        tempBtn = self.m_table_tab_btns[i]
        tempBtn:setHighlighted(self.m_selLeftIndex == i);
        tempBtn:setEnabled(self.m_selLeftIndex ~= i);
        -- tempNode = self["m_node_iconboard" .. board_id1[i]]
        -- tempNode:setVisible(self.m_selLeftIndex == i)
        if self.m_selLeftIndex == i then
            tempNode = self["m_node_iconboard" .. board_id1[i]]
            if tempNode then
                tempNode:setVisible(true)
            end
        end
    end


    for i=4, 5 do
        tempBtn = self.m_table_tab_btns[i]
        tempBtn:setHighlighted(self.m_selRightIndex == i);
        tempBtn:setEnabled(self.m_selRightIndex ~= i);
        if self.m_selRightIndex == 4 then
            self.m_node_iconboard3:setVisible(true)
            self.m_scroll_rightboard:setVisible(false)
        elseif self.m_selRightIndex == 5 then
            self.m_node_iconboard3:setVisible(false)
            self.m_scroll_rightboard:setVisible(true)
        end
    end
end

--[[--
    阵型显示
]]
function game_player_info_pop.updateFromation( self )

    local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},
      {key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};
    self.m_posIndex = -1;
    self.m_tempSelIndex = -1;
    self.m_tempTeamData = {};
    self.m_tempFriendData = {};
    self.m_tempEquipPosData = {};
    self.m_tempAssEquipPosData = {};  -- 助威装备信息
    self.m_tempGemPosData = {};
    self.m_tempDestinyData = {}

    local formationData = self.m_player_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    self.m_selFormationId = self.m_currentFormationId;

    local teamData = self.m_player_data:getTeamData();
    local friendData = self.m_player_data:getAssistant();
    local destinyData = self.m_player_data:getDestiny();
    local tempEquipPosData = self.m_player_data:getEquipPosData()
    local tempAssEquipPosData = self.m_player_data:getAssEquipPosData()
    -- cclog2(tempAssEquipPosData, "tempAssEquipPosData  ====   ")
    local tempGemPosData = self.m_player_data:getGemPosData();
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_selFormationId));
    local tempTag = 1;
    local iValue = nil;
    if itemCfg ~= nil then
        for i=1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue ~= 0 and tempTag < 7 then
                self.m_tempTeamData[i] = teamData[tempTag]
                self.m_tempEquipPosData[i] = util.table_copy(tempEquipPosData[tostring(tempTag-1)]);
                self.m_tempGemPosData[i] = util.table_copy(tempGemPosData[tostring(tempTag-1)]); 
                self.m_tempAssEquipPosData[i] = util.table_copy(tempAssEquipPosData[tostring(tempTag + 99)]);
                -- self.m_tempGemPosData[i] = util.table_copy(tempGemPosData[tostring(tempTag-1)]); 
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempEquipPosData[i] = {"0","0","0","0"}
                self.m_tempGemPosData[i] = {"0","0","0","0"}
                self.m_tempAssEquipPosData[i] = {"0","0","0","0"}
            end
        end
    end
    for i=6,8 do
        self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempEquipPosData[i+1] = util.table_copy(tempEquipPosData[tostring(i-1)]);
        self.m_tempGemPosData[i+1] = util.table_copy(tempGemPosData[tostring(i-1)]);
        self.m_tempAssEquipPosData[i+1] = util.table_copy(tempAssEquipPosData[tostring(i + 100)]);
    end
    self.m_tempFriendData = friendData;
    self.m_tempDestinyData = destinyData;
    local cardNumData = self.m_player_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
end



--[[--
    初始化编队信息
]]
function game_player_info_pop.initTeamFormation(self,formation_layer)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local index = btnTag - 20000
        self:initRightContentInfo( index )
        self:selIcon(index)

    end

    local character_detail_cfg = getConfig("character_detail");
    local flag = false
    for i=1,9 do
        -- local animNode,character_ID = self:createCardAnimByPosIndex(i)
        
        local cardData,cardCfg = self:getCardDataByPos( i )
        local k = i
        if self.m_selLeftIndex == 2 or self.m_selLeftIndex == 3 then
            k = 10 + i
        end

        self.m_boss_icons[i]:removeAllChildrenWithCleanup(true)
        self.m_boss_icons[k]:removeAllChildrenWithCleanup(true)
        if cardData and  cardCfg then
            if cardCfg then
                icon = game_util:createCardIconByCfg(cardCfg);

                if self.m_boss_icons[k] and icon then
                    icon:setPosition(self.m_boss_icons[k]:getContentSize().width * 0.5, self.m_boss_icons[k]:getContentSize().width * 0.5)
                    self.m_boss_icons[k]:addChild(icon, 10)

                    local name = game_util:getCardName( cardData, cardCfg)
                    cclog2(name, "name ===  ")
                    if name and name ~= "" then
                        local label = game_util:createLabelTTF({text = name, fontSize = 10})   
                        label:setPosition(self.m_boss_icons[k]:getContentSize().width * 0.5, - 2)
                        self.m_boss_icons[k]:addChild(label, 11)
                    end

                    local  tempSize = self.m_boss_icons[k]:getContentSize()
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    button:setOpacity(0)
                    self.m_boss_icons[k]:addChild(button)
                    button:setTag(20000 + i)
                    if not flag then
                        self:initRightContentInfo( i )
                        self:selIcon(i)
                        flag = true
                    end
                end

            end
        end
    end
    if not flag then
        self:initRightContentInfo( 1 )
        flag = true
    end

 
end

function game_player_info_pop.selIcon( self, index )

    for i=1,9 do
        if self.m_boss_icons[i] and self.m_boss_icons[i]:getChildByTag(100) then
            self.m_boss_icons[i]:removeChildByTag(100,true)
        end

        if self.m_boss_icons[i + 10] and self.m_boss_icons[i + 10]:getChildByTag(100) then
            self.m_boss_icons[i + 10]:removeChildByTag(100,true)
        end
    end

    do
        local size = self.m_boss_icons[index]:getContentSize()
        local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_light.png");
        tempBg:setPreferredSize(CCSizeMake(size.width*1.1, size.height*1.1));
        tempBg:setPosition(ccp(size.width*0.5, size.height*0.5))
        self.m_boss_icons[index]:addChild(tempBg, 100, 100)
        tempBg:runAction(game_util:createRepeatForeverFade());
    end

    do 
        index = index + 10
        local size = self.m_boss_icons[index]:getContentSize()
        local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_light.png");
        tempBg:setPreferredSize(CCSizeMake(size.width*1.1, size.height*1.1));
        tempBg:setPosition(ccp(size.width*0.5, size.height*0.5))
        self.m_boss_icons[index]:addChild(tempBg, 100, 100)
        tempBg:runAction(game_util:createRepeatForeverFade());
    end
end

--[[
    获取位置信息
]]
function game_player_info_pop.getCardDataByPos( self, posIndex, showType )
    showType = showType or self.m_selLeftIndex 
    local cardData, cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(posIndex);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(posIndex);
    elseif self.m_selLeftIndex == 3 then
       cardData,cardCfg = self:getDestinyCardDataByPos(posIndex);
    end
    return cardData, cardCfg
end

--[[--
    
]]
function game_player_info_pop.getTeamCardDataByPos(self,posIndex)
    return  self.m_player_data:getCardDataById(self.m_tempTeamData[posIndex])
end

--[[--
    获得卡牌配置以及数据
]]
function game_player_info_pop:getFriendCardDataByPos( posIndex )
    -- body
    return self.m_player_data:getCardDataById(self.m_tempFriendData[posIndex])
end

--[[--
    获取命运卡牌位置及数据
]]
function game_player_info_pop:getDestinyCardDataByPos( posIndex )
    -- body
    return self.m_player_data:getCardDataById(self.m_tempDestinyData[posIndex])
end

--[[-- 
    创建宝箱动画
]]
function game_player_info_pop.createBoxAnim(self,animFile)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if theLabelName == "daiji1" or theLabelName == "daiji2" or theLabelName == "daiji3" then
            animNode:playSection(theLabelName)
        elseif theLabelName == "dakai" then
            animNode:playSection("daiji3")
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("daiji1");
    return mAnimNode;
end

--[[--
    刷新ui
]]
function game_player_info_pop.refreshUi(self)
   self:refreshTabBtn()
   self:updateFromation()
   self:initTeamFormation()
   -- self:initRightContentInfo(3)
end

--[[--
    刷新奖励状态
]]
function game_player_info_pop.refreshRewardStutas( self )
    local reward = self.m_params.award_status or {}
    local bout = self.m_params.bout

end



--[[--
    初始化
]]
function game_player_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.isFriend = t_params.isFriend
    self.m_show_fate_type = "short"
    self.m_player_data = require("game_player_data")
    self.m_player_data:init()

    -- cclog2(t_params, "t_params === ")
    local gameData = t_params.gameData
    local data = gameData:getNodeWithKey("data")
    self.m_params = {}
    if data and data:getNodeWithKey("new_data") then
        self.m_params.boss_data = json.decode(data:getNodeWithKey("new_data"):getFormatBuffer()) or {}
    end
    local userdata = data:getNodeWithKey("new_data")
    self.m_player_data:updateCardsOpenByJsonData(userdata  or nil)
    self.m_selLeftIndex = 1
    self.m_selRightIndex = 4
    if self.m_params.boss_data and self.m_params.boss_data.user then
        self.m_uid = self.m_params.boss_data.user.uid
        self.m_name = self.m_params.boss_data.user.name
    end
    self.m_enterType = t_params.enterType or 0
end

--[[--
    获取卡片信息
]]
function game_player_info_pop.getCardInfo( self, cardId )
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_player_info_pop.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end


return game_player_info_pop;


