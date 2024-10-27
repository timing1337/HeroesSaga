---  gvg地图
local game_gvg_war = {
    m_tGameData = nil,
    property_add = nil,
    treasure = nil,
    city = nil,
    heal_times = nil,
    total_hp = nil,
    alignment = nil,
    die = nil,
    city = nil,
    recapture_log = nil,
    regain_reward = nil,
    total_hp_rate = nil,
    tips_label = nil,
    winType = nil,

    home_left_time = nil,
    home_att_flag = nil,

    guild_att_name = nil,
    guild_def_name = nil,
    map_node = nil,
    att_num = nil,
    def_num = nil,
    bar_node = nil,
    left_time_node = nil,
    map_sprite = nil,
    m_ccbNode = nil,
    sort = nil,

    all_morale_node = nil,
    self_morale_node = nil,
    all_morale = nil,
    self_morale = nil,
    all_morale_lv =  nil,
    self_morale_lv = nil,
    all_morale_detail = nil,
    self_morale_detail = nil,
    reward_node1 = nil,
    reward_node2 = nil,
    occupy_index = nil,
    inspire_index = nil,

    m_cityAutoRaidsScheduler = nil,
    m_auto_time = nil,
    netFlag = nil,
    open_flag = nil,
    combat = nil,
    m_combat_label = nil,
    m_combatNumberChangeNode = nil,
    backCombat = nil,
    m_progress_bg = nil,
    m_progress_bar = nil,
    pro_gress_node = nil,
    m_stageTab = nil,
};
--[[--
    销毁
]]
function game_gvg_war.destroy(self)
    cclog("-----------------game_gvg_war destroy-----------------");
    self.m_tGameData = nil;
    self.property_add = nil;
    self.treasure = nil;
    self.city = nil;
    self.heal_times = nil;
    self.total_hp = nil;
    self.alignment = nil;
    self.die = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.regain_reward = nil;
    self.total_hp_rate = nil;
    self.tips_label = nil;
    self.winType = nil;

    self.home_left_time = nil;
    self.home_att_flag = nil;--是否可以打主家的flag

    --------------
    self.guild_att_name = nil;
    self.guild_def_name = nil;
    self.map_node = nil;
    self.att_num = nil;
    self.def_num = nil;
    self.bar_node = nil;
    self.left_time_node = nil;
    self.map_sprite = nil;
    self.m_ccbNode = nil;
    self.sort = nil;

    self.all_morale_node = nil;
    self.self_morale_node = nil;
    self.all_morale = nil;
    self.self_morale = nil;
    self.all_morale_lv =  nil;
    self.self_morale_lv = nil;
    self.all_morale_detail = nil;
    self.self_morale_detail = nil;
    self.reward_node1 = nil;
    self.reward_node2 = nil;
    self.occupy_index = nil;
    self.inspire_index = nil;
    self.combat = nil;

    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
    self.netFlag = nil;
    self.open_flag = nil;
    self.m_auto_time = nil;
    self.m_combat_label = nil;
    self.m_combatNumberChangeNode = nil;
    self.backCombat = nil;
    self.m_progress_bg = nil;
    self.m_progress_bar = nil;
    self.pro_gress_node = nil;
    self.m_stageTab = nil;
end
local autoRefreshTime = 5
--[[--
    返回
]]
function game_gvg_war.back(self,type)
    self.netFlag = true
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        -- require("like_oo.oo_controlBase"):openView("guild_join");
        game_scene:enterGameUi("game_main_scene",{gameData = nil});
        self:destroy();
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_war.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag222222 ===== " .. btnTag)
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 2 then--详情
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            game_scene:addPop("game_gvg_inspire_pop",{gameData = self.m_tGameData.inspire_log,callBackFunc = callBackFunc})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_battle_info"), http_request_method.GET, nil,"guild_gvg_battle_info")
        elseif btnTag == 3 then--刷新
            self:refreshData()
        elseif btnTag == 100 then--即时排名
            local function callBackFunc()
               self.open_flag = false
            end
            local function responseMethod(tag,gameData)
                self.open_flag = true
                game_scene:addPop("game_gvg_instant_rank_pop",{gameData = gameData,callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_show_log"), http_request_method.GET, nil,"guild_gvg_show_log")
        elseif btnTag == 201 then--高级鼓舞
            local function responseMethod(tag,gameData)
                if gameData then
                    self.netFlag = false
                    local data = gameData:getNodeWithKey("data");
                    local gvgData = data:getNodeWithKey("gvg")
                    self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                    game_util:addMoveTips({text = string_helper.game_gvg_war.text})
                    --加鼓舞动画
                    self.inspire_index = 1
                    self.combat = self.m_tGameData.combat
                    self:refreshUi()
                else
                    self.netFlag = false        
                end
            end
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_buy_guild_morale"), http_request_method.GET, nil,"guild_gvg_buy_guild_morale",true,true)
        elseif btnTag == 202 then--普通鼓舞
            local function responseMethod(tag,gameData)
                if gameData then
                    self.netFlag = false
                    local data = gameData:getNodeWithKey("data");
                    local gvgData = data:getNodeWithKey("gvg")
                    self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                    local success = data:getNodeWithKey("success"):toBool()
                    if success then
                        game_util:addMoveTips({text = string_helper.game_gvg_war.text})
                        --加鼓舞动画
                        self.inspire_index = 2
                    else
                        game_util:addMoveTips({text = string_helper.game_gvg_war.text2})
                    end
                    self.combat = self.m_tGameData.combat
                    self:refreshUi()
                else
                    self.netFlag = false       
                end
            end
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_buy_player_morale"), http_request_method.GET, nil,"guild_gvg_buy_player_morale",true,true)
        elseif btnTag == 555 then--聊天
            self.open_flag = true
            game_scene:addPop("ui_chat_pop",{enterType = 2});
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        if self.m_stageTab[btnTag].openFlag == true then--可领取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer())
                -- self:refreshUi()
                self:refreshData()
                game_util:rewardTipsByDataTable(reward);
            end
            local params = {}
            params.reward_id = btnTag
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_fight_reward"), http_request_method.GET, params,"guild_fight_reward")
        else--显示奖励
            self:createRewardTipsPop(tagNode)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_citys_war.ccbi");
    
    
    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name") 
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")

    self.bar_node = ccbNode:nodeForName("bar_node")
    self.left_time_node = ccbNode:nodeForName("left_time_node")

    self.att_num = ccbNode:labelTTFForName("att_num")
    self.def_num = ccbNode:labelTTFForName("def_num")

    --阵营
    -- self.def_camp = ccbNode:spriteForName("def_camp")
    -- self.att_camp = ccbNode:spriteForName("att_camp")
    
    self.map_node = ccbNode:nodeForName("map_node")--地图按钮
    self.map_sprite = ccbNode:spriteForName("map_sprite")--地图底图
    
    self.log_node = ccbNode:nodeForName("log_node")
    self.log_node:removeAllChildrenWithCleanup(true)
    self.log_node:setVisible(false)
    --准备用的node
    self.perpare_node = ccbNode:nodeForName("perpare_node")
    self.perpare_node:setVisible(true)
    -------
    self.all_morale_node = ccbNode:nodeForName("all_morale_node")
    self.self_morale_node = ccbNode:nodeForName("self_morale_node")
    self.all_morale = ccbNode:labelTTFForName("all_morale")
    self.self_morale = ccbNode:labelTTFForName("self_morale")
    self.all_morale_lv = ccbNode:labelTTFForName("all_morale_lv")
    self.self_morale_lv = ccbNode:labelTTFForName("self_morale_lv")
    self.all_morale_detail = ccbNode:labelTTFForName("all_morale_detail")
    self.self_morale_detail = ccbNode:labelTTFForName("self_morale_detail")
    self.reward_node1 = ccbNode:nodeForName("reward_node1")
    self.reward_node2 = ccbNode:nodeForName("reward_node2")
    self.cost_label1 = ccbNode:labelTTFForName("cost_label1")
    self.cost_label2 = ccbNode:labelTTFForName("cost_label2")

    self.left_time_1 = ccbNode:labelTTFForName("left_time_1")
    self.left_time_2 = ccbNode:labelTTFForName("left_time_2")
    self.pro_gress_node = ccbNode:nodeForName("pro_gress_node")
    self.pro_gress_node:setVisible(true)

    self.m_progress_bg = ccbNode:nodeForName("m_progress_bg")
    local barSize = self.m_progress_bg:getContentSize();
    local bar = ExtProgressBar:createWithFrameName("gvg_progress_back.png","gvg_progress.png",barSize);
    bar:setCurValue(0,false);
    self.m_progress_bg:addChild(bar,10,10);
    self.m_progress_bar = bar

    local animTab = {"anim_ui_baoxiang1","anim_ui_baoxiang1","anim_ui_baoxiang2","anim_ui_baoxiang3","anim_ui_baoxiang3"};
    for i=1,5 do
        local tempAnim = self:createBoxAnim(animTab[i])
        local button = game_util:createCCControlButton("gvg_btn_detail.png","",onBtnCilck)
        local reward_point = ccbNode:labelBMFontForName("reward_point" .. i)
        button:setTag(i)
        button:setPosition(ccp(50*i, 12));
        button:setOpacity(0)
        self.m_progress_bg:addChild(button,12)
        tempAnim:setPosition(ccp(50*i, 12));
        tempAnim:setTag(i);
        self.m_progress_bg:addChild(tempAnim,11)
        self.m_stageTab[i] = {boxAnim = tempAnim,openFlag = false,reward_point = reward_point}
    end

    self.m_open_btn = ccbNode:controlButtonForName("m_open_btn")
    self.m_open_btn:setVisible(false)

    local att_tips_node = ccbNode:nodeForName("att_tips_node")
    local def_tips_node = ccbNode:nodeForName("def_tips_node")

    att_tips_node:setVisible(false)
    def_tips_node:setVisible(false)

    self.log_btn = ccbNode:controlButtonForName("log_btn")
    self.log_btn:setOpacity(0)
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.m_combat_label:setVisible(false)
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setScale(1.2)
    self.m_combatNumberChangeNode:setPosition(ccp(113, 14));
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    self.m_combat_label:getParent():addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);
    --提示信息
    self.att_tips_label = ccbNode:nodeForName("att_tips_label")

    local m_inspire = ccbNode:controlButtonForName("m_inspire")
    local m_inspire_er = ccbNode:controlButtonForName("m_inspire_er")
    local m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")

    m_inspire:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    m_inspire_er:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    m_detail_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    -- self.att_left_label = ccbNode:labelTTFForName("att_left_label")
    -------
    function tick( dt )
        if self.open_flag == false then
            self:setInfoLabel();
            if self.m_auto_time > 0 then
                self.m_auto_time = self.m_auto_time - 1;
            else
                if self.netFlag == false then
                    self.netFlag = true;
                    local function responseMethod(tag,gameData)
                        if gameData then
                            self.netFlag = false;
                            local data = gameData:getNodeWithKey("data")
                            local sort = data:getNodeWithKey("sort"):toInt()
                            if sort == 1 then--外围战布阵开启
                                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                                local data = gameData:getNodeWithKey("data");
                                local gvgData = data:getNodeWithKey("gvg")
                                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                                self:refreshUi()
                            elseif sort == 2 then--外围战战争开始
                                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
                                self:destroy()
                            elseif sort == 3 then--内城布阵开始
                                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                                local data = gameData:getNodeWithKey("data");
                                local gvgData = data:getNodeWithKey("gvg")
                                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                                self:refreshUi()
                            elseif sort == 4 then--内城战开始
                                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
                                self:destroy()
                            elseif sort == 5 then
                                
                            elseif sort == -1 then--公会战未开启
                                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                                self:destroy()
                            else
                                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
                                self:destroy()
                            end
                        else
                            self.netFlag = false;
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing",false,true)
                end
            end
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    奖励弹出框
]]
function game_gvg_war.createRewardTipsPop(self,clickNode)
    if self.m_rewardTips then return end
    local tag = clickNode:getTag();
    local buyCfg = getConfig(game_config_field.guild_fight_buy)
    local itemCfg = buyCfg:getNodeWithKey(tostring(tag))
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if itemCfg then
        local reward = itemCfg:getNodeWithKey("reward")
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
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    -- local titleLabel = game_util:createLabelTTF({text = "活跃度奖励",color = ccc3(250,180,0),fontSize = 14});
    local titleSprite = CCSprite:createWithSpriteFrameName("gvg_reward_label.png")
    titleSprite:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleSprite)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
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
function game_gvg_war.createBoxAnim(self,animFile)
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
local buttonInfo = {
    {pos = ccp(93,431),id = 1,size = 2},
    {pos = ccp(21,333),id = 2},
    {pos = ccp(265,457),id = 3},
    {pos = ccp(110,260),id = 4},
    {pos = ccp(239,316),id = 5},
    {pos = ccp(360,385),id = 6},
    {pos = ccp(44,159),id = 7},
    {pos = ccp(190,191),id = 8},
    {pos = ccp(301,237),id = 9},
    {pos = ccp(398,296),id = 10},
    {pos = ccp(526,353),id = 11},
    {pos = ccp(491,432),id = 12},
    {pos = ccp(181,97),id = 13},
    {pos = ccp(314,147),id = 14},
    {pos = ccp(443,211),id = 15},
    {pos = ccp(562,270),id = 16},
    {pos = ccp(393,46),id = 105},
    {pos = ccp(528,111),id = 104},
    {pos = ccp(648,180),id = 103},
    {pos = ccp(764,270),id = 102},
    {pos = ccp(743,53),id = 101,size = 2},
}
--[[
    初始化按钮位置
]]
function game_gvg_war.initMapButton(self)
    local lifePos = {
        {0},
        {-7,8},
        {-15,0,15},
        {-22,-7,8,23},
        {-30,-15,0,15,30},
    }
    local guild_fightCfg = getConfig(game_config_field.guild_fight)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)

        local cityData = self.m_tGameData.city
        local itemData = cityData[tostring(btnTag)]
        --根据当时的状态来判断是去请求哪一个
        local sort = itemData.sort
        local reboot = itemData.reboot

        local params = {}
        params.building_id = btnTag
        if reboot == 0 then--空地块，占领
            local function responseMethod(tag,gameData)
                if gameData then
                    self.netFlag = false
                    local data = gameData:getNodeWithKey("data");
                    local gvgData = data:getNodeWithKey("gvg")
                    local status = data:getNodeWithKey("status"):toInt()
                    if status == 1 then--自己已经占领了地块
                        local function responseMethodForKick(tag,gameData)
                            if gameData then
                                self.netFlag = false
                                local data = gameData:getNodeWithKey("data")
                                local gvgData = data:getNodeWithKey("gvg")
                                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                                self.occupy_index = btnTag
                                game_util:closeAlertView()
                                game_util:addMoveTips({text = string_helper.game_gvg_war.start_df})
                                self:refreshUi()
                            else
                                self.netFlag = false
                            end
                        end
                        local paramsForKick = {}
                        paramsForKick.building_id = btnTag
                        paramsForKick.force = 1
                        local t_params = 
                        {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                self.netFlag = true
                                network.sendHttpRequest(responseMethodForKick,game_url.getUrlForKey("guild_gvg_select_building"), http_request_method.GET, paramsForKick,"guild_gvg_select_building",true,true)
                            end,   --可缺省
                            okBtnText = string_config.m_btn_sure,       --可缺省
                            cancelBtnText = string_config.m_btn_cancel,
                            text = string_helper.game_gvg_war.text3,      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-10,
                        }
                        game_util:openAlertView(t_params)
                    else
                        game_util:addMoveTips({text = string_helper.game_gvg_war.start_df})
                        --播放动画   chuansong   zhanling    guwu
                        self.occupy_index = btnTag;
                    end
                    self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                    self:refreshUi()
                else
                    self.netFlag = false
                end
            end
            self.netFlag = true
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_select_building"), http_request_method.GET, params,"guild_gvg_select_building",true,true)
        else
            -- params.force = 0
            local function responseMethod(tag,gameData)
                if gameData then
                    self.netFlag = false
                    local function callFunc(callFuncData)
                        self.m_tGameData = callFuncData or {};
                       self:refreshUi()
                       game_util:addMoveTips({text = string_helper.game_gvg_war.del_success})
                    end
                    local data = gameData:getNodeWithKey("data");
                    local reboot = data:getNodeWithKey("reboot"):toInt()
                    if reboot == 1 or reboot == 2 then--人
                        self.open_flag = true
                        game_scene:addPop("game_gvg_enemy_pop",{gameData = gameData,buildingId = btnTag,enterType = "perpare",callFunc = callFunc})
                    elseif reboot == 3 then--怪
                        self.open_flag = true
                        game_scene:addPop("game_gvg_npc",{gameData = gameData,buildingId = btnTag,enterType = "perpare"})
                    elseif reboot == 0 then--空地块
                        -- game_util:addMoveTips({text = "占领成功"})
                    end
                else
                    self.netFlag = false
                end
            end
            if sort == 1 then
                self.netFlag = true
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_open_building"), http_request_method.GET, params,"guild_gvg_open_building",true,true)
            end
        end
    end
    self.map_node:removeAllChildrenWithCleanup(true)
    local cityData = self.m_tGameData.city
    for i=1,game_util:getTableLen(buttonInfo) do
        local btnPos = buttonInfo[i].pos
        local realPos = ccp(math.floor(btnPos.x/2),math.floor(btnPos.y/2))
        local size = buttonInfo[i].size
        local realSize = CCSizeMake(36,36)
        if size == 2 then
            realSize = CCSizeMake(51,51)
        end
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setPosition(realPos)
        button:setAnchorPoint(ccp(0,0))
        button:setPreferredSize(realSize)
        local id = buttonInfo[i].id
        button:setTag(id)
        button:setOpacity(0)
        self.map_node:addChild(button,10,id)

        --加建筑node来显示内容的
        local roleNode = CCNode:create()
        roleNode:setPosition(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5)
        roleNode:removeAllChildrenWithCleanup(true)

        self.map_node:addChild(roleNode,11,100+id)
        local itemData = cityData[tostring(id)]
        local sort = itemData.sort   --建筑物积分类型 1: 防守方占领, 2: 资源地块 3: 大资源块 
        if sort == 0 then

        elseif sort == 1 then--or sort == 2 or sort == 3 then--防守方
            local name = itemData.name
            local life = itemData.life
            local reboot = itemData.reboot--reboot: 0. 未知. 1. 人, 2. 机器人, 3.怪物    根据roboot来判断是否可占领

            local lifeBack = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png")
            lifeBack:setColor(ccc3(255,146,0))
            --底条
            lifeBack:setPreferredSize(CCSizeMake(70,13))
            lifeBack:setPosition(ccp(0,realSize.height/4))
            roleNode:addChild(lifeBack)
            --名字
            local nameLabel = game_util:createLabelTTF({text = name,color = ccc3(255,255,255),fontSize = 10});
            nameLabel:setPosition(ccp(0,realSize.height/4))
            roleNode:addChild(nameLabel)
            --血
            if sort == 1 then--显示血
                --根据
                -- createLifeIcon(roleNode,life)
                if reboot == 0 then--布阵时刻   空地块。加点击选择的动画
                    lifeBack:setVisible(false)
                    local spriteTip = CCSprite:createWithSpriteFrameName("gvg_select.png")
                    spriteTip:setPosition(ccp(0,realSize.height/4+10))
                    roleNode:addChild(spriteTip)
                    local animArr = CCArray:create();
                    animArr:addObject(CCMoveTo:create(1,ccp(0, realSize.height/4+12)))
                    animArr:addObject(CCMoveTo:create(1,ccp(0, realSize.height/4+8)))
                    spriteTip:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
                else
                    lifeBack:setVisible(true)
                    if life > 1 then
                        for i=1,life-1 do
                            local iconLife = CCSprite:createWithSpriteFrameName("gvg_icon_life.png")
                            iconLife:setPosition(ccp(lifePos[life-1][i],-5))
                            -- roleNode:addChild(iconLife)
                        end
                    end
                end
            else--显示   */*
                local itemCfg = guild_fightCfg:getNodeWithKey(tostring(id))
                local life_1 = itemCfg:getNodeWithKey("life_1"):toInt()
                local lifeLabel = game_util:createLabelTTF({text = life .. "/" .. life_1,color = ccc3(222,217,8),fontSize = 12});
                lifeLabel:setPosition(ccp(0,-5))
                roleNode:addChild(lifeLabel)
            end
        -- elseif sort == 2 then--资源点

        end
        --播放动画   chuansong   zhanling    guwu
        if self.occupy_index and self.occupy_index == id then
            local effect = game_util:createEffectAnim("chuansong",1.0)
            effect:setPosition(ccp(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5))
            self.map_node:addChild(effect,10)
            self.occupy_index = nil;
        end
    end
    if self.m_tGameData.sort == 1 then

    else
        local mapSprite = CCSprite:create("ccbResources/ui_gvg_inner_city_map.jpg")
        self.map_sprite:setDisplayFrame(mapSprite:displayFrame());
    end
end
--[[
    刷新数据
]]
function game_gvg_war.refreshData(self)
    local function responseMethod(tag,gameData)
        if gameData then
            self.netFlag = false
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外围战布阵开启
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                local data = gameData:getNodeWithKey("data");
                local gvgData = data:getNodeWithKey("gvg")
                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                self:refreshUi()
            elseif sort == 2 then--外围战战争开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--内城布阵开始
                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                local data = gameData:getNodeWithKey("data");
                local gvgData = data:getNodeWithKey("gvg")
                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                self:refreshUi()
            elseif sort == 4 then--内城战开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公会战未开启
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        else
            self.netFlag = false
        end
    end
    self.netFlag = true
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing",true,true)
end
--[[
    刷新label
]]
function game_gvg_war.refreshLabel(self)
    self.m_auto_time = 5
    -- self.guild_def_name:setString(self.m_tGameData.defender)
    -- self.guild_att_name:setString(self.m_tGameData.attacker)
    self.bar_node:removeAllChildrenWithCleanup(true)
    self.left_time_node:removeAllChildrenWithCleanup(true)
    --倒计时     准备倒计时，到0时刷新界面
    local function timeEndFunc()
        self:refreshData()
    end
    local countDownTime = self.m_tGameData.remainder_time + 2--延迟2秒来抵消不同服务器的延时
    local countdownLabel = game_util:createCountdownLabel(countDownTime,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setColor(ccc3(255,94,9))
    self.left_time_node:addChild(countdownLabel,10,10)
    if countDownTime <= 0 then
        timeEndFunc()
    end
    --进度条
    local att_score = self.m_tGameData.att_score
    local def_score = self.m_tGameData.def_score
    local max_value = att_score + def_score
    local now_value = def_score
    local bar = ExtProgressTime:createWithFrameName("gvg_att_hp.png","gvg_def_hp.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.bar_node:addChild(bar,-1,11)
    --
    self.att_num:setString(att_score)
    self.def_num:setString(def_score)

    self.att_tips_label:removeAllChildrenWithCleanup(true)
    local tipsSprite = CCSprite:createWithSpriteFrameName("gvg_befor_tip.png")
    self.att_tips_label:addChild(tipsSprite)
end
--[[
    刷新士气
]]
function game_gvg_war.refreshMorale(self)
    self.all_morale:setString(self.m_tGameData.guild_add .. "%")
    self.self_morale:setString(self.m_tGameData.player_add .. "%")
    self.all_morale_lv:setString("lv." .. self.m_tGameData.guild_lv)
    self.self_morale_lv:setString("lv." .. self.m_tGameData.player_lv)
    self.all_morale_detail:setString(string_helper.game_gvg_war.mel_add .. self.m_tGameData.guild_add .. "%")
    self.self_morale_detail:setString(string_helper.game_gvg_war.mel_add .. self.m_tGameData.player_add .. "%")
    -- self.left_time_1:setString( (10 - self.m_tGameData.cur_pay_count) .. "/10")
    self.left_time_2:setString( (10 - self.m_tGameData.cur_free_count) .. "/10")
    self.left_time_1:setString("")
    --
    self.reward_node1:removeAllChildrenWithCleanup(true)
    self.reward_node2:removeAllChildrenWithCleanup(true)
    self.all_morale_node:removeAllChildrenWithCleanup(true)
    self.self_morale_node:removeAllChildrenWithCleanup(true)

    local bar = ExtProgressBar:createWithFrameName("gvg_anger_up_back.png","gvg_anger_up.png",CCSizeMake(88,27));
    bar:setMaxValue(100);
    bar:setCurValue(self.m_tGameData.guild_add,false);
    bar:setRotation(-90)
    bar:setAnchorPoint(ccp(0.5,0.5))
    self.all_morale_node:addChild(bar)

    local bar2 = ExtProgressBar:createWithFrameName("gvg_anger_up_back.png","gvg_anger_up.png",CCSizeMake(88,27));
    bar2:setMaxValue(100);
    bar2:setCurValue(self.m_tGameData.player_add,false);
    bar2:setRotation(-90)
    bar2:setAnchorPoint(ccp(0.5,0.5))
    self.self_morale_node:addChild(bar2)

    --取钻石数
    local cur_buy_times = self.m_tGameData.cur_pay_count
    local payCfg = getConfig(game_config_field.pay)
    local itemCfg = payCfg:getNodeWithKey("22")
    local count = itemCfg:getNodeWithKey("coin"):getNodeCount()

    if cur_buy_times >= count - 1 then
        cur_buy_times = count - 1
    end
    if itemCfg then
        local coin = itemCfg:getNodeWithKey("coin"):getNodeAt(cur_buy_times):toInt()
        self.cost_label1:setString(coin .. string_helper.game_gvg_war.diamond)
    end
    local level = game_data:getUserStatusDataByKey("level")
    self.cost_label2:setString((level * 50) .. string_helper.game_gvg_war.food)
    --加动画
    if self.inspire_index > 0 then
        local effect = game_util:createEffectAnim("anim_guwu",1.0)
        if self.inspire_index == 1 then
            self.all_morale_node:addChild(effect)
            local effect2 = game_util:createEffectAnim("anim_guwu",1.0)
            self.self_morale_node:addChild(effect2)
            self.inspire_index = 0
        else
            self.self_morale_node:addChild(effect)
            self.inspire_index = 0
        end
    end
    self:refreshCombat()

    --进度条发奖
    local value = self.m_tGameData.cost or 0
    local buyCfg = getConfig(game_config_field.guild_fight_buy)
    local cfgCount = buyCfg:getNodeCount()
    for i=1,5 do
        local itemCfg = buyCfg:getNodeWithKey(tostring(i))
        local cost = itemCfg:getNodeWithKey("cost"):toInt()
        local boxAnim = self.m_stageTab[i].boxAnim
        self.m_stageTab[i].reward_point:setString(tostring(cost))
        self.m_stageTab[i].openFlag = false;
        -- if value > cost and 
        local tempFlag = game_util:valueInTeam(tostring(i),self.m_tGameData.guild_reward_log)
        if tempFlag == true then--已领取
            if boxAnim then
                boxAnim:playSection("daiji3")
            end
        else
            if value >= cost then
                boxAnim:playSection("daiji2")
                self.m_stageTab[i].openFlag = true;
            else
                boxAnim:playSection("daiji1")
            end
        end
    end
    local maxValue = buyCfg:getNodeWithKey(tostring(cfgCount)):getNodeWithKey("cost"):toInt()
    self.m_progress_bar:setCurValue(value*100/maxValue,false)
end
function game_gvg_war.refreshCombat(self)
    self.m_combat_label:setString(self.combat)
    --战斗力变化动画
    local tempCombatValue = self.combat
    local changeValue = tempCombatValue - self.backCombat
    game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    self.backCombat = self.combat
end
function game_gvg_war.setInfoLabel(self)
    cclog("00:0" .. self.m_auto_time)
end

--[[--
    刷新ui
]]
function game_gvg_war.refreshUi(self)
    self:refreshLabel()
    --初始化地图按钮
    self:initMapButton()
    self:refreshMorale()
end

--[[--
    初始化
]]
function game_gvg_war.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local gvgData = data:getNodeWithKey("gvg")
        self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
        self.sort = self.m_tGameData.sort
        self.combat = self.m_tGameData.combat--战斗力
        self.backCombat = self.combat
    else
        self.m_tGameData = {};
    end
    self.inspire_index = 0
    self.m_auto_time = autoRefreshTime;
    self.netFlag = false;
    self.open_flag = false;
    self.m_stageTab = {}
end

--[[--
    创建入口
]]
function game_gvg_war.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_gvg_war;