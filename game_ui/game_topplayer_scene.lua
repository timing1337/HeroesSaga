--- 编队信息 

local game_topplayer_scene = {
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

   m_topplayer_data = nil,
   m_scroll_rightboard = nil,

   m_boss_icons = nil,
   m_node_iconboard1 = nil,
   m_node_iconboard2 = nil,
   m_fate_node = nil,
   m_fate_label = nil,
   m_node_iconboard3 = nil,
   m_label_maxhit = nil,
   m_show_fate_type = nil,
   m_sel_index = nil,
   m_skill_layer = nil,
   m_rewardTips = nil,


   m_node_guide_playerinfo = nil,
   m_node_guide_playerattr = nil,
   m_node_guide_playerformat = nil,
};

--[[--
    销毁
]]
function game_topplayer_scene.destroy(self)
    -- body
    cclog("-----------------game_topplayer_scene destroy-----------------");
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
    self.m_node_iconboard2 = nil;
    self.m_fate_node = nil;
    self.m_fate_label = nil;
    self.m_label_maxhit = nil;
    self.m_show_fate_type = nil;
    self.m_sel_index = nil;
    self.m_skill_layer= nil;
    self.m_rewardTips = nil;


   self.m_node_guide_playerinfo = nil;
   self.m_node_guide_playerattr = nil;
   self.m_node_guide_playerformat = nil;
end
--[[--
    返回
]]
function game_topplayer_scene.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end

--[[--
    读取ccbi创建ui
]]
function game_topplayer_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == ", btnTag)
        if btnTag == 1 then
          self:back()
        elseif btnTag == 11 then

        elseif btnTag == 1001 then  -- 阵型
            self.m_selLeftIndex = 1
            self:refreshUi()

        elseif btnTag == 1002 then   -- 助威
            self.m_selLeftIndex = 2
            self:refreshUi()

        elseif btnTag == 1003 then  -- 装备
            self.m_selRightIndex = 3
            self:refreshUi()

        elseif btnTag == 1004 then   -- 属性
            self.m_selRightIndex = 4
            self:refreshUi()

        elseif btnTag == 301 then--调到阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_topplayer_scene"});
            self:destroy();


        elseif btnTag == 201 then--战报
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                if not data then return end
                local messages = data:getNodeWithKey("messages")
                if not messages then return end
                local tempData = {};
                local count = messages:getNodeCount();
                for i=1,count do
                    tempData[#tempData + 1] = json.decode( messages:getNodeAt(i - 1):getFormatBuffer())
                end

                local name = string_config:getTextByKey("m_topplayer_unnowname")
                if self.m_params.boss_data and self.m_params.boss_data.user then
                    name = self.m_params.boss_data.user.name or name
                end
                game_scene:addPop("ui_topbatter_info_pop",{log_info = tempData,openType = "ui_topbatter_info_pop", top_name = name })
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("playerboss_log"), http_request_method.GET, nil,"playerboss_log")  
        elseif btnTag == 303 then -- 战斗
            local responseMethod = function(tag,gameData)
                if(gameData == nil) then
                    return 
                end
                local has_battled = 1;
                cclog("responseMethod --------------------------------" .. has_battled)
                if has_battled == 1 then
                    local function animEndCallFunc()
                        -- game_util:writeBattleData(gameData:getFormatBuffer())
                        game_data:setBattleType("game_topplayer_scene_fight");
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                        self:destroy();
                    end
                    animEndCallFunc();
                    game_scene:runPropertyBarAnim("outer_anim")
                end
            end
            local m_tag = nil
            local isuiRunOut = false
            --运行界面动画
            local uiRunOut = function()
                --创建加载黑影
                if(not isuiRunOut) then
                    isuiRunOut = true
                else
                    return 
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("playerboss_fight"), http_request_method.GET, nil,"playerboss_fight",true,true,true)
            end  
            uiRunOut();
            game_data:setUserStatusDataBackup();

        elseif btnTag == 2008 then
            game_scene:addPop("game_active_limit_detail_pop",{openType = "game_topplayer_scene"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_topplayer_scene.ccbi");

    self.m_node_roleHead = ccbNode:nodeForName("m_node_roleHead")
    self.m_label_roleName = ccbNode:labelTTFForName("m_label_roleName")
    self.m_label_guildName = ccbNode:labelTTFForName("m_label_guildName")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_node_iconboard1 = ccbNode:nodeForName("m_node_iconboard1")
    self.m_node_iconboard2 = ccbNode:nodeForName("m_node_iconboard2")
    self.m_node_iconboard3 = ccbNode:nodeForName("m_node_iconboard3")
   self.m_node_guide_playerinfo = ccbNode:nodeForName("m_node_guide_playerinfo");
   self.m_node_guide_playerattr = ccbNode:nodeForName("m_node_guide_playerattr");
   self.m_node_guide_playerformat = ccbNode:nodeForName("m_node_guide_playerformat");
   local m_label_nameTitle = ccbNode:labelTTFForName("m_label_nameTitle");
   local m_label_guildTitle = ccbNode:labelTTFForName("m_label_guildTitle");
   m_label_nameTitle:setString(string_helper.ccb.file31);
   m_label_guildTitle:setString(string_helper.ccb.file32);
   local m_table_tab_label_1 = ccbNode:labelTTFForName("m_table_tab_label_1");
   local m_table_tab_label_2 = ccbNode:labelTTFForName("m_table_tab_label_2");
   local m_table_tab_label_3 = ccbNode:labelTTFForName("m_table_tab_label_3");
   local m_table_tab_label_4 = ccbNode:labelTTFForName("m_table_tab_label_4");
   m_table_tab_label_1:setString(string_helper.ccb.file33);
   m_table_tab_label_2:setString(string_helper.ccb.file34);
   m_table_tab_label_3:setString(string_helper.ccb.file35);
   m_table_tab_label_4:setString(string_helper.ccb.file36);
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
            ui_node_equipinfo:setPositionY( m_node_baoshiinfo:getPositionY() )
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

    self.m_label_maxhit = ccbNode:labelTTFForName("m_label_maxhit")
    self.m_label_maxhit:setString(tostring(self.m_params.max_hurt or 0 ))

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
    for i=1, 4 do
        self.m_table_tab_btns[i] = ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
    end
    self.m_scroll_rightboard = ccbNode:scrollViewForName("m_scroll_rightboard")

    self.m_boss_icons = {}
    for i=1,9 do
        self.m_boss_icons[i] = ccbNode:nodeForName("m_sprite_icon" .. i)
        j = i + 10
        self.m_boss_icons[j] = ccbNode:nodeForName("m_sprite_icon" .. j)
    end


    -- self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    -- local function onTouch(eventType, x, y)
    -- if eventType == "began" then
    --     -- self:back();
    --     return true;--intercept event
    -- end
    -- end
    -- self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-4,true);
    -- self.m_root_layer:setTouchEnabled(true);

    local m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
    local m_conbtn_battleinfo = ccbNode:controlButtonForName("m_conbtn_battleinfo")
    local m_battle_btn = ccbNode:controlButtonForName("m_battle_btn")
    m_formation_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    m_conbtn_battleinfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);
    m_battle_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5);

    -- 奖励进度条
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_daily_task_res.plist")
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local index = btnTag - 10000
        local reward = self.m_params.award_status or {}
        if reward[tostring(index)] == 1 then -- 奖励可以领取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local info = json.decode(data:getFormatBuffer())
                game_util:rewardTipsByJsonData(data:getNodeWithKey("award"));
                self.m_params.award_status = info.award_status
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("playerboss_award"), http_request_method.GET, {award_id = index},"playerboss_award")
        else
            self:createRewardTipsPop( self.m_stageTab[index].boxAnim, index )
        end
        local bout = self.m_params.bout

    end

    self.m_progress_bg = ccbNode:nodeForName("m_progress_bg")
    local barSize = self.m_progress_bg:getContentSize();
    local bar = ExtProgressBar:createWithFrameName("mrrw_progress_1.png","mrrw_progress_2.png",barSize);
    -- bar:setPositionY( - barSize.height * 0.5)
    bar:setCurValue(0,false);
    self.m_progress_bg:addChild(bar, -1);
    self.m_progress_bar = bar;

    self.m_stageTab = {}
    local animTab = {"anim_ui_baoxiang1", "anim_ui_baoxiang2", "anim_ui_baoxiang3"};
    for i=1,3 do
        local m_stage = ccbNode:spriteForName("m_sprite_stage" .. i)
        cclog2(m_stage, "m_stage  ====   ")
        local tempSize = m_stage:getContentSize();
        local tempAnim = self:createBoxAnim(animTab[i])
        tempAnim:setPosition(ccp(tempSize.width*0.5, tempSize.height*2));
        tempAnim:setTag(i);
        m_stage:addChild(tempAnim, 1)
        self.m_stageTab[i] = {m_stage = m_stage,boxAnim = tempAnim,openFlag = false}


        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setPosition(ccp(tempSize.width*0.5, tempSize.height*2))
        button:setOpacity(0)
        m_stage:addChild(button)
        button:setTag(10000 + i)
    end

    self:updateTopPlayerBaseInfo()
    return ccbNode;
end

--[[--
    刷新奖励状态
]]
function game_topplayer_scene.refreshAwardStutas( self )
    local bout = self.m_params.bout 
    local award_status = self.m_params.award_status

    local index = 1
    for i=1,3 do
        if award_status[tostring(i)] ~= 0 then index = i end
        local boxAnim = self.m_stageTab[i].boxAnim
        if boxAnim then
            if award_status[tostring(i)] == 1 then -- 奖励可领
                boxAnim:playSection("daiji2")
            elseif award_status[tostring(i)] == 2 then
                boxAnim:playSection("daiji3")
            elseif award_status[tostring(i)] == 0 then
                boxAnim:playSection("daiji1")

            end
        end
    end
    self.m_progress_bar:setCurValue(50 * (index - 1) ,false);
end


--[[--
    奖励弹出框
]]
function game_topplayer_scene.createRewardTipsPop(self,clickNode, reward_index)
    if self.m_rewardTips then return end
    local tag = clickNode:getTag();
    local reward_cfg = getConfig(game_config_field.player_boss)
    -- cclog("diaryscore_cfg = " .. diaryscore_cfg:getFormatBuffer())
    local reward_item_cfg = reward_cfg:getNodeWithKey(tostring(reward_index))
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if reward_item_cfg then
        local reward = reward_item_cfg:getNodeWithKey("reward")
        if reward then
            local rewardCount = reward:getNodeCount();
            cclog("rewardCount===== " .. rewardCount)
            rewardHeight = 30*rewardCount
            reardNode:setContentSize(CCSizeMake(100, rewardHeight))
            for i=1,rewardCount do
                local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                -- cclog("icon == " .. tostring(icon) .. " name = " .. tostring(icon))
                if icon then
                    icon:setScale(0.5);
                    icon:setPosition(ccp(30, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(icon)
                end
                if name then
                    local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                    tempLabel:setPosition(ccp(80, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(tempLabel)
                end
            end
        end
    end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_pop_box_back.png");
    local viewSize = CCSizeMake(130,30 + rewardHeight);
    bgSpr:setPreferredSize(viewSize);
    -- local scrollView = CCScrollView:create(viewSize);
    -- scrollView:setDirection(kCCScrollViewDirectionVertical);
    -- scrollView:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    -- scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    -- bgSpr:addChild(scrollView);
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    local titleLabel = game_util:createLabelTTF({text = string_helper.game_topplayer_scene.reward,color = ccc3(250,180,0),fontSize = 14});
    titleLabel:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleLabel)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
    if reward_index == 1 then
        arrow:setPositionX(viewSize.width*0.15);
        bgSpr:setPositionX(pos.x + bgSpr:getContentSize().width * 0.4);
    end
    self.m_rewardTips = CCLayer:create();
    self.m_rewardTips:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_rewardTips then
                self.m_rewardTips:removeFromParentAndCleanup(true);
                self.m_rewardTips = nil;
            end
            return true;--intercept event
        end
    end
    self.m_rewardTips:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_rewardTips:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_rewardTips);
end

--[[--
     右侧信息的滑动栏
]]
function game_topplayer_scene.initRightContentInfo( self, index )

    self.m_scroll_rightboard:getContainer():removeAllChildrenWithCleanup(true)

    local ccbNode = luaCCBNode:create();
    local roleIndex_use = index

    local cardData,cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(index);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(index);
    end

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
    local title104 = ccbNode:labelTTFForName("title104");
    local title105 = ccbNode:labelTTFForName("title105");
    local title106 = ccbNode:labelTTFForName("title106");
    title106:setString(string_helper.ccb.title106);
    title105:setString(string_helper.ccb.title105);
    title104:setString(string_helper.ccb.title104);
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

        local chainTab = game_util:cardChainByCfg(cardCfg,cardData.id, self.m_topplayer_data)
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
        if cardData and self.m_selLeftIndex == 1 then
            local equipPosData = self.m_tempEquipPosData[index]
            if equipPosData then
                if equipPosData then
                    local noUseEquipCountTab = self.m_topplayer_data:getNoUseEquipCountTab();
                    for i=1,4 do
                        tempNode = self.m_sprite_equips[i]  
                        if tempNode then
                            local tempNodeSize = tempNode:getContentSize();
                            local id = equipPosData[i];
                            if id and id ~= "0" then
                                local equipItemData,equipItemCfg = self.m_topplayer_data:getEquipDataById(tostring(id));
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
        for k,v in pairs(COMBAT_ABILITY_TABLE.card) do
            local f_id = COMBAT_ABILITY_TABLE.card_evo[k] or ""
            local evo_tab = PUBLIC_ABILITY_TABLE["ability_" .. tostring(f_id)] or {}
            local icon_spr = ccbNode:spriteForName("m_spr_f_sign" .. tostring(k)) 
            cclog2(evo_tab , "evo_tab  ========= ")
            local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( evo_tab.icon );
            cclog2(tempDisplayFrame , "tempDisplayFrame  ========= ")
            if icon_spr then
                if tempDisplayFrame then
                    icon_spr:setDisplayFrame( tempDisplayFrame )
                end
            end

            local tempLabel = ccbNode:labelTTFForName("m_label_fomo" .. tostring(k)) 
            cclog2(tempLabel , "tempLabel  ======  ")
            local value1 = cardData[v] or 0
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
    else
        m_node_fumo:setVisible(false)
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
function game_topplayer_scene.showEquipInfo( self, roleIndex, index)
    local cardData,cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(roleIndex);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(roleIndex);
    end
    local tempEquipId = self:getPosEquipId(roleIndex, index);
    local itemData = self.m_topplayer_data:getEquipDataById(tempEquipId)
    game_scene:addPop("game_equip_info_pop",{tGameData = itemData,posEquipData = 
        self.m_tempEquipPosData[roleIndex],openType=4, equipData = self.m_topplayer_data:getEquipData()});    

end

--[[--
    显示转生信息
]]
function game_topplayer_scene.showBreakInfo( self, roleIndex, index )
    local cardData,cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(roleIndex);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(roleIndex);
    end
    if cardData and cardCfg then
        game_scene:addPop("hero_breakthrough_detail_pop",{cardCfgId = cardData.c_id,
        breValue = cardData.bre or 0 ,selBreValue = index})
    end
                    
end

--[[--
    显示技能信息
]]
function game_topplayer_scene.showSkillInfo( self, roleIndex, index )
    local cardData,cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(roleIndex);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(roleIndex);
    end
    local skill = cardData["s_" .. index]
    game_scene:addPop("skills_activation_pop",{skillData = skill, selHeroId=cardData.c_id ,posIndex = index}) 
end

--[[--
    显示装备信息
]]
function game_topplayer_scene.showGemInfo( self, roleIndex, index)
    if self.m_tempGemPosData[roleIndex] then
        local tempGemId = self.m_tempGemPosData[roleIndex][index]
        if tempGemId ~= "0" then
            game_scene:addPop("gem_system_info_pop",{tGameData = {count = 1,c_id = tempGemId},callBack = nil, openType=4});
        end
    end  
end

--[[--
    获得位置上的装备ID
]]
function game_topplayer_scene.getPosEquipId(self,equipPos,equipType)
    local tempEquipId = 0;
    if self.m_tempEquipPosData[equipPos] then
        tempEquipId = self.m_tempEquipPosData[equipPos][equipType]
    end
    return tempEquipId;
end

--[[--
    创建一个接受触摸时间的button
]]
function game_topplayer_scene.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    parent:addChild(button)
    button:setTag(tag)
end

--[[--
    更新boss人物头像
]]
function game_topplayer_scene.initBossRole( self )
    for i=1,10 do
        local cardData,cardCfg = self:getTeamCardDataByPos(index);
        if cardData and cardCfg then
            -- self.m_boss_icons[k]

        end
    end
end

--[[--
    更新boss头像
]]
function game_topplayer_scene.updateTopPlayerBaseInfo( self )
    -- 头像

    local role = 1
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
    

    -- 昵称  -- 公会
    local name = string_config:getTextByKey("m_topplayer_unnowname")
    local guild = string_config:getTextByKey("m_topplayer_noguild")
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
    刷新左侧标签属性  阵型1/助威2  装备3/属性4
]] 
function game_topplayer_scene.refreshTabBtn(self)
    local tempBtn = nil;
    local tempNode = nil;
    for i=1,2 do
        tempBtn = self.m_table_tab_btns[i]
        tempBtn:setHighlighted(self.m_selLeftIndex == i);
        tempBtn:setEnabled(self.m_selLeftIndex ~= i);
        tempNode = self["m_node_iconboard" .. i]
        tempNode:setVisible(self.m_selLeftIndex == i)
    end

    for i=3, 4 do
        tempBtn = self.m_table_tab_btns[i]
        tempBtn:setHighlighted(self.m_selRightIndex == i);
        tempBtn:setEnabled(self.m_selRightIndex ~= i);
        if self.m_selRightIndex == 3 then
            self.m_node_iconboard3:setVisible(true)
            self.m_scroll_rightboard:setVisible(false)
        elseif self.m_selRightIndex == 4 then
            self.m_node_iconboard3:setVisible(false)
            self.m_scroll_rightboard:setVisible(true)
        end
    end
end

--[[--
    阵型显示
]]
function game_topplayer_scene.updateFromation( self )

    local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},
      {key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};
    self.m_posIndex = -1;
    self.m_tempSelIndex = -1;
    self.m_tempTeamData = {};
    self.m_tempFriendData = {};
    self.m_tempEquipPosData = {};
    self.m_tempGemPosData = {};

    local formationData = self.m_topplayer_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    self.m_selFormationId = self.m_currentFormationId;

    local teamData = self.m_topplayer_data:getTeamData();
    local friendData = self.m_topplayer_data:getAssistant();
    local tempEquipPosData = self.m_topplayer_data:getEquipPosData()
    local tempGemPosData = self.m_topplayer_data:getGemPosData();
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
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempEquipPosData[i] = {"0","0","0","0"}
                self.m_tempGemPosData[i] = {"0","0","0","0"}
            end
        end
    end
    for i=6,8 do
        self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempEquipPosData[i+1] = util.table_copy(tempEquipPosData[tostring(i-1)]);
        self.m_tempGemPosData[i+1] = util.table_copy(tempGemPosData[tostring(i-1)]);
    end
    self.m_tempFriendData = friendData;
    local cardNumData = self.m_topplayer_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
end



--[[--
    初始化编队信息
]]
function game_topplayer_scene.initTeamFormation(self,formation_layer)

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
        local cardData,cardCfg = nil, nil
        if self.m_selLeftIndex == 1 then
           cardData,cardCfg = self:getTeamCardDataByPos(i);
        elseif self.m_selLeftIndex == 2 then
           cardData,cardCfg = self:getFriendCardDataByPos(i);
        end
        local k = i + (self.m_selLeftIndex - 1) * 10
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

function game_topplayer_scene.selIcon( self, index )

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



--[[--
    
]]
function game_topplayer_scene.getTeamCardDataByPos(self,posIndex)
    return  self.m_topplayer_data:getCardDataById(self.m_tempTeamData[posIndex])
end

--[[--
    获得卡牌配置以及数据
]]
function game_topplayer_scene:getFriendCardDataByPos( posIndex )
    -- body
    return self.m_topplayer_data:getCardDataById(self.m_tempFriendData[posIndex])
end

--[[-- 
    创建宝箱动画
]]
function game_topplayer_scene.createBoxAnim(self,animFile)
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
function game_topplayer_scene.refreshUi(self)
    self:refreshAwardStutas()
   self:refreshTabBtn()
   self:updateFromation()
   self:initTeamFormation()
   -- self:initRightContentInfo(3)
end

--[[--
    刷新奖励状态
]]
function game_topplayer_scene.refreshRewardStutas( self )
    local reward = self.m_params.award_status or {}
    local bout = self.m_params.bout

end



--[[--
    初始化
]]
function game_topplayer_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_show_fate_type = "short"
    self.m_topplayer_data = require("game_player_data")
    self.m_topplayer_data:init()

    -- cclog2(t_params, "t_params === ")
    local gameData = t_params.gameData
    self.m_params = {}
    if gameData and gameData:getNodeWithKey("data") then
        self.m_params = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
    end
    local data = gameData:getNodeWithKey("data")
    self.m_topplayer_data:updateCardsOpenByJsonData(data and data:getNodeWithKey("boss_data") or nil)
    self.m_selLeftIndex = 1
    self.m_selRightIndex = 3

end

--[[--
    获取卡片信息
]]
function game_topplayer_scene.getCardInfo( self, cardId )
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_topplayer_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    local id = game_guide_controller:getIdByTeam("69");
    cclog2(id , " id  =====  ")
    if id ~= 6906 then
        self:gameGuide("drama","69",id, t_params)
    end
    return scene;
end

function game_topplayer_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    cclog2(game_guide_controller:getGuideCompareFlag(guide_team,guide_id), "ame_guide_controller:getGuideCompareFlag(guide_team,guide_id)  === ")
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    cclog2(id , "id   ======   ")

 --    do 
    --     return 
    -- end
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "69" and id == 6901 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "69" and id == 6902 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_guide_playerinfo
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "69" and id == 6903 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_guide_playerformat 
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "69" and id == 6904 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id  , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_guide_playerattr
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "69" and id == 6905 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team,id + 1)
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end



return game_topplayer_scene;


