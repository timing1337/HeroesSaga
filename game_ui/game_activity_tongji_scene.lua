---  通缉令活动  -活动-通缉

local game_activity_tongji_scene = {
   m_label_fuhuo_times = nil,   -- 复活次数
   m_label_qiuzhu_times = nil,  -- 求助次数
   m_progress_bg = nil,      -- 领奖进度 底板
   m_progress_bar = nil, -- 进度条
   m_node_roleboards = nil,  -- tableView 底板
   m_gameData = nil,
   m_showData = nil,
}

--[[--
    销毁ui
]]
function game_activity_tongji_scene.destroy(self)
    -- body
    cclog("----------------- game_activity_tongji_scene destroy-----------------"); 
    self.m_label_fuhuo_times = nil;
    self.m_label_qiuzhu_times = nil;
    self.m_progress_bg = nil;
    self.m_node_roleboards = nil;
    self.m_gameData = nil;
    self.m_showData = nil;
end

--[[--
    返回
]]
function game_activity_tongji_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end

--[[--
    读取ccbi创建ui
]]
function game_activity_tongji_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2008 then  -- 求助
            game_scene:addPop("game_active_limit_detail_pop",{openType = "game_activity_tongji_scene"})   
        elseif btnTag == 2009 then  -- 活动详情
            if self.m_gameData.help_times == 0 then
                game_util:addMoveTips({text = string_helper.game_activity_tongji_scene.appeal_end})
                return
            end
            local function responseMethod(tag,gameData)
                -- cclog2(gameData, "gameData   ====   ")
                game_util:addMoveTips({text = string_helper.game_activity_tongji_scene.appeal_success})
                local data = gameData:getNodeWithKey("data")
                local help_times = data and data:getNodeWithKey("help_times"):toInt() or 0
                self.m_gameData.help_times = help_times
                self:refreshUi()
            end
            local enemyid = 1
            for i=1,4 do
                if not self.m_gameData.boxes_info.win_data[i] then
                    enemyid = i
                    break 
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wanted_wanted_help"), http_request_method.GET, {enemy_id = enemyid},"wanted_wanted_help")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_activity_tongji.ccbi");

    local m_node_mainboard = ccbNode:nodeForName("m_node_mainboard")
    local battleBg = CCSprite:create("battle_ground/back_travelinginegypt.jpg")
    battleBg:setPosition(m_node_mainboard:getContentSize().width * 0.5, m_node_mainboard:getContentSize().height * 0.5)
    m_node_mainboard:addChild(battleBg, - 10)

    self.m_label_fuhuo_times = ccbNode:labelTTFForName("m_label_fuhuo_times")
    self.m_label_qiuzhu_times = ccbNode:labelTTFForName("m_label_qiuzhu_times")
    self.m_progress_bg = ccbNode:nodeForName("m_progress_bg")
    self.m_node_roleboards = ccbNode:nodeForName("m_node_roleboards")

    -- 奖励进度条
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_daily_task_res.plist")
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        local index = btnTag - 10000
        local reward = self.m_gameData.boxes_info.win_data
        local get_reward = self.m_gameData.boxes_info.win_reward
        if self:getRewardStateByIndex(index) == 1 then -- 奖励可以领取
            -- do return end
            local function responseMethod(tag,gameData)
                -- cclog2(gameData, "reward   ==   gameData   ===  ")
                local data = gameData:getNodeWithKey("data")
                local info = json.decode(data:getFormatBuffer())
                self.m_gameData.boxes_info.win_reward = json.decode(data:getNodeWithKey("win_reward"):getFormatBuffer())
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                -- self.m_params.award_status = info.award_status
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wanted_wanted_award"), http_request_method.GET, {award_id = index},"wanted_wanted_award")
        else
            self:createRewardTipsPop( self.m_stageTab[index].boxAnim, index )
        end
    end

    local barSize = self.m_progress_bg:getContentSize();
    local bar = ExtProgressBar:createWithFrameName("mrrw_progress_1.png","mrrw_progress_2.png",barSize);
    -- bar:setPositionY( - barSize.height * 0.5)
    bar:setCurValue(0,false);
    self.m_progress_bg:addChild(bar, -1);
    self.m_progress_bar = bar;

    self.m_stageTab = {}
    local animTab = {"anim_ui_baoxiang1", "anim_ui_baoxiang2", "anim_ui_baoxiang2", "anim_ui_baoxiang3"};
    local nodeposX = {0, 0.33, 0.66, 1}
    for i=1,4 do
        local stage_node = CCSprite:create()
        local tempSize = self.m_progress_bg:getContentSize();
        local tempAnim = self:createBoxAnim(animTab[i])
        stage_node:setPosition(ccp(tempSize.width*nodeposX[i], tempSize.height*0.5));
        self.m_progress_bg:addChild( stage_node )
        tempAnim:setTag(i);
        stage_node:addChild(tempAnim, 1)
        self.m_stageTab[i] = {m_stage = stage_node,boxAnim = tempAnim,openFlag = false}


        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setOpacity(0)
        stage_node:addChild(button)
        button:setTag(10000 + i)
    end   
    return ccbNode;
end

--[[--
    创建列表
]]
function game_activity_tongji_scene.createTableViewTongji( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    -- local itemCount = #showData
    local itemCount = self.m_gameData.enemy_info.combat and #self.m_gameData.enemy_info.combat or 0
    cclog2(itemCount, "showData count  ====    ")
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_activity_tongji_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  

            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local m_node_xiezhu = ccbNode:nodeForName("m_node_xiezhu")
                local m_node_combat = ccbNode:nodeForName("m_node_combat")
                local m_scroll_role = ccbNode:scrollViewForName("m_scroll_role")
                local m_lable_pos = ccbNode:labelTTFForName("m_lable_pos")
                local m_blabel_combat = ccbNode:labelBMFontForName("m_blabel_combat")   -- 通缉者战斗力
                local m_label_rolename = ccbNode:labelTTFForName("m_label_rolename")  -- 通缉名字
                local m_label_roleservice = ccbNode:labelTTFForName("m_label_roleservice")  -- 通缉者的服务器
                local m_label_xiezhu_name = ccbNode:labelTTFForName("m_label_xiezhu_name")  -- 协助击杀名字

                local m_node_noevent = ccbNode:nodeForName("m_node_noevent")
                m_node_noevent:removeAllChildrenWithCleanup(true)
                local tempSize = m_node_noevent:getContentSize()
                local button = game_util:createCCControlButton("public_weapon.png","",function() end)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                button:setOpacity(0)
                button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                m_node_noevent:addChild(button)
                button:setPreferredSize(tempSize)

                local sprite_break = ccbNode:spriteForName("sprite_break")  -- 击破图片
                local m_sprite_board = ccbNode:spriteForName("m_sprite_board") -- 地板图片
                -- 位置信息
                m_lable_pos:setString(tostring(index + 1))


                -- 底下信息条 -- 战力/协助/无
                m_node_xiezhu:setVisible(false)
                m_node_combat:setVisible(false)

                -- 击破标志
                local award = self.m_gameData.boxes_info.win_data[index + 1]
                if not self.m_gameData.boxes_info.win_data[index + 1] then 
                    sprite_break:setVisible(false)
                    m_sprite_board:setColor(ccc3(255,255,255))
                    m_node_combat:setVisible(true)
                    m_blabel_combat:setString( tostring(self.m_gameData.enemy_info.combat[index + 1]) )
                else
                    sprite_break:setVisible(true)
                    m_sprite_board:setColor(ccc3(155,155,155))
                    
                    if self.m_gameData.help_enemy[tostring(index + 1)].uid ~= "" then
                        m_node_xiezhu:setVisible(true)
                        m_label_xiezhu_name:setString( tostring(self.m_gameData.help_enemy[tostring(index + 1)].name) )
                    end
                end

                -- local itemData = showData[index + 1] or {}
                local win = 1
                local roleid = 1
                local role = self.m_gameData.enemy_info.role[index + 1] or 1

                -- 通缉主角半身像显示
                m_scroll_role:getContainer():removeAllChildrenWithCleanup(true)
                m_scroll_role:setTouchEnabled(false)
                local tempSize = m_scroll_role:getViewSize()
                local role_half = game_util:createRoleBigImgHalf(role)
                role_half:setAnchorPoint(ccp(0.5, 0))
                local scale = tempSize.width / role_half:getContentSize().width * 1.4
                role_half:setPositionX(tempSize.width * 0.5)
                role_half:setScale(scale)
                m_scroll_role:getContainer():addChild(role_half, 10)
                -- 通缉角色名称

                m_label_rolename:setString(tostring(self.m_gameData.enemy_info.name[index + 1] or string_helper.game_activity_tongji_scene.mystical_man))
                -- 通缉角色服务器
                m_label_roleservice:setString(tostring( (self.m_gameData.enemy_info.server_name[index + 1] or 111 ) .. tring_helper.game_activity_tongji_scene.server))
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            cclog2("click table cell index === " .. tostring(index))
            -- 需要按照顺序打
            if self.m_gameData.boxes_info.win_data[index + 1] then
                game_util:addMoveTips({text = tring_helper.game_activity_tongji_scene.man_skill});
                return
            end
            if index > 0 then
                if not self.m_gameData.boxes_info.win_data[index] then
                    game_util:addMoveTips({text = tring_helper.game_activity_tongji_scene.last_man});
                    return
                end
            end

            local function responseMethod(tag,gameData)
                game_data:setBattleType("fight_tongji_role");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local params = {};
            params.enemy_id = index + 1;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wanted_wanted_fight"), http_request_method.GET, params,"wanted_wanted_fight")
        end
    end
    local tableview = TableViewHelper:create(params)
    if itemCount <= 5 then
        tableview:setMoveFlag(false)
    end
    return tableview
end

--[[--
    刷新ui
]]
function game_activity_tongji_scene.refreshUi(self)
    self.m_node_roleboards:removeAllChildrenWithCleanup( true )
    local tableview = self:createTableViewTongji( self.m_node_roleboards:getContentSize() )
    if tableview then
        self.m_node_roleboards:addChild( tableview )
    end

    self.m_label_fuhuo_times:setString(tostring(self.m_gameData.fail_times))
    self.m_label_qiuzhu_times:setString(tostring(self.m_gameData.help_times))
    self:refreshAwardStutas()
end

--[[--
    刷新奖励状态
]]
function game_activity_tongji_scene.refreshAwardStutas( self )
    local bout = self.m_gameData.boxes_info.win_reward
    local award_status = self.m_gameData.boxes_info.win_data

    local index = 0
    for i=1,4 do
        if self:getRewardStateByIndex(i) ~= 0 then index = i end
        local boxAnim = self.m_stageTab[i].boxAnim
        if boxAnim then
            if self:getRewardStateByIndex(i) == 1 then -- 奖励可领
                boxAnim:playSection("daiji2")
            elseif  self:getRewardStateByIndex(i) == 2 then
                boxAnim:playSection("daiji3")
            elseif self:getRewardStateByIndex(i) == 0 then
                boxAnim:playSection("daiji1")

            end
        end
    end
    self.m_progress_bar:setCurValue(33 * math.max(index - 1, 0) ,false);
end

--[[
    查看奖励状态
]]
function game_activity_tongji_scene.getRewardStateByIndex( self, index )
    local bout = self.m_gameData.boxes_info.win_reward
    local award_status = self.m_gameData.boxes_info.win_data
    local state = 0
    for i,v in ipairs(award_status) do
        if v == index then
            state = 1 
        end
    end

    for i,v in ipairs(bout) do
        if v == index then
            state = 2
        end
    end
    return state
end

--[[-- 
    创建宝箱动画
]]
function game_activity_tongji_scene.createBoxAnim(self,animFile)
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
    奖励弹出框
]]
function game_activity_tongji_scene.createRewardTipsPop(self,clickNode, reward_index)
    if self.m_rewardTips then return end
    local tag = clickNode:getTag();
    local reward_cfg = getConfig(game_config_field.deadandalive)
    -- cclog2(reward_cfg, "reward_cfg = =====  ")
    local reward_item_cfg = reward_cfg:getNodeWithKey(tostring(reward_index))
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if reward_item_cfg then
        local reward = reward_item_cfg:getNodeWithKey("award")
        if reward then
            local rewardCount = reward:getNodeCount();
            -- cclog("rewardCount===== " .. rewardCount)
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
    local titleLabel = game_util:createLabelTTF({text = tring_helper.game_activity_tongji_scene.reward,color = ccc3(250,180,0),fontSize = 14});
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
    格式化数据
]]
function game_activity_tongji_scene.formatData( self )
    self.m_showData = {}
    for i,v in ipairs(self.m_gameData.enemy_info.combat) do
        local info = {}
        info.name = self.m_gameData.enemy_info.name[i]
        info.server_name = self.m_gameData.enemy_info.server_name[i]
        info.combat = self.m_gameData.enemy_info.combat[i]
        self.m_showData[i] = info
    end
end

--[[--
    初始化
]]
function game_activity_tongji_scene.init(self,t_params)
    t_params = t_params or {}
    self.m_gameData = t_params.gameData:getNodeWithKey("data") and json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
    -- cclog2(self.m_gameData, "self.m_gameData  ===  ")
end
--[[--
    创建ui入口并初始化数据
]]
function game_activity_tongji_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_tongji_scene