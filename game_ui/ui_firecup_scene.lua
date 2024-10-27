---  火焰杯: 霍格沃茨
local ui_firecup_scene = {
   m_label_titleinfo = nil,   -- 标题信息 -- 每日xx点将抽取……
   m_label_countdtitle = nil,   -- 抽奖倒计时标题
   m_node_showitemboard = nil,  -- 显示契约版
   m_node_rewardnode = nil,     -- 奖励板
   m_node_firecup = nil,    -- 火焰杯版
   m_label_firecountd_title = nil,    -- Fire倒计时标题
   m_label_lastzuanshi = nil,   -- 钻石存量
   m_label_myscore = nil,   -- 契约积分

   m_node_rewardnode = nil,     -- 奖励底板
   m_node_rewards = nil,    -- 奖励
   m_rewardbox_stageTab = nil, 
   m_rewardTips = nil,
   m_rewardProgress_bar = nil, 
   m_spr_jidutiaback = nil,
   m_cupProgress = nil,
   m_spr_fire = nil,
   m_tGameData = nil,
   m_maxFireScore = nil,
   m_rewardInfo = nil,
   m_spr_cup = nil,
   m_node_firsttips = nil,  -- 提示
   m_first_tips_show = nil,
   m_titleInfo = nil,
   m_cupInfo = nil,
   m_spr_firestate = nil,

   m_buyContractLimit = nil,  -- 购买契约限制  同一时间只能选中一种
   m_rewardCostTab = nil, -- 奖励分数
   m_score_rewardTab = nil,
   m_contract_tab = nil,
};

--[[--
    销毁ui
]]
function ui_firecup_scene.destroy(self)
    -- body
    cclog("-----------------ui_firecup_scene destroy-----------------");   
    self.m_label_titleinfo = nil;
    self.m_label_countdtitle = nil;
    self.m_node_showitemboard = nil;
    self.m_node_rewardnode = nil;
    self.m_node_firecup = nil;
    self.m_label_firecountd_title = nil;
    self.m_label_lastzuanshi = nil;
    self.m_label_myscore = nil;
    self.m_node_rewards = nil;
    self.m_node_rewardnode = nil;
    self.m_rewardTips = nil;
    self.m_rewardProgress_bar = nil;
    self.m_spr_jidutiaback = nil;
    self.m_cupProgress = nil;
    self.m_spr_fire = nil;
    self.m_tGameData = nil;
    self.m_maxFireScore = nil;
    self.m_rewardInfo = nil;
    self.m_spr_cup = nil;
    self.m_node_firsttips = nil;
    self.m_first_tips_show = nil;
    self.m_titleInfo = nil;
    self.m_cupInfo = nil;
    self.m_spr_firestate = nil;
    self.m_buyContractLimit = nil;
    self.m_rewardCostTab = nil;
    self.m_score_rewardTab = nil;
    self.m_contract_tab = nil;
end
--[[--
    返回
]]
function ui_firecup_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function ui_firecup_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "ui_firecup_scene main btn click and btn tag === ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then   -- 我的契约
            local function responseMethod(tag,gameData)
                self:refreshData(gameData)
                self:refreshUi()
                game_scene:addPop("ui_firecup_minereward_pop", { contractList = self.m_tGameData.contract, page_sort_count = self.m_tGameData.page_sort_count})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_get_back_sort_num"), http_request_method.GET, nil,"magic_school_get_back_sort_num")
        elseif btnTag == 102 then   -- 幸运契约
            local function responseMethod(tag,gameData)
                self:refreshData(gameData)
                self:refreshUi()
                game_scene:addPop("ui_firecup_rewarddetail_pop", { luck_contractList = self.m_tGameData.lucky_contract, coin_bigreward = self.m_tGameData.cost_big_reward, version = self.m_tGameData.version})
            
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_lucky_contract"), http_request_method.GET, nil,"magic_school_lucky_contract")
        elseif btnTag == 103 then   -- 活动详情
            game_scene:addPop("ui_firecup_detail_pop", {m_contract_tab = self.m_contract_tab, version = self.m_tGameData.version})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_firecup_scene.ccbi");
    self.m_label_titleinfo = ccbNode:labelTTFForName("m_label_titleinfo");
    self.m_label_countdtitle = ccbNode:labelTTFForName("m_label_countdtitle");
    self.m_node_showitemboard = ccbNode:nodeForName("m_node_showitemboard");
    self.m_node_rewardnode = ccbNode:nodeForName("m_node_rewardnode");
    self.m_node_firecup = ccbNode:nodeForName("m_node_firecup");
    self.m_label_firecountd_title = ccbNode:labelTTFForName("m_label_firecountd_title");
    self.m_label_lastzuanshi = ccbNode:labelTTFForName("m_label_lastzuanshi");
    self.m_label_myscore = ccbNode:labelTTFForName("m_label_myscore");
    self.m_node_rewardnode = ccbNode:nodeForName("m_node_rewardnode")
    self.m_spr_jidutiaback = ccbNode:spriteForName("m_spr_jidutiaback")
    self.m_spr_fire = ccbNode:spriteForName("m_spr_fire")
    self.m_node_firsttips = ccbNode:nodeForName("m_node_firsttips")
    self.m_spr_cup = ccbNode:spriteForName("m_spr_cup")
    self.m_spr_firestate = ccbNode:spriteForName("m_spr_firestate")
    self.m_node_rewards = {}
    for i=1, 4 do
        self.m_node_rewards["rewardnode" .. tostring(i)] = ccbNode:nodeForName("m_node_reward" .. tostring(i))
    end

    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end

    --- 创建奖励条
    self:createRewardInfo()

    -- 创建火焰杯

    -- 进度条
    local cupSize = CCSizeMake(100, 127)
    local bar = ExtProgressTime:createWithFrameName("ui_firecup_huoyanbeikong.png","ui_firecup_h1.png");
    bar:setPosition(ccp(cupSize.width*0.5, 0))
    bar:setAnchorPoint(ccp(0,0.5))
    bar:setRotation(-90)
    bar:setCurValue(50,true);
    self.m_node_firecup:addChild(bar,-1);
    self.m_cupProgress = bar

    -- self.m_spr_fire:setVisible(false)
    local pX,pY = self.m_spr_fire:getPosition();
    local animArr = CCArray:create();
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY)),CCTintTo:create(1,175,175,175)))
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY)),CCTintTo:create(1,255,255,255)))
    -- animArr:addObject(CCTintTo:create(1,175,175,175))
    -- animArr:addObject(CCTintTo:create(1,255,255,255))
    self.m_spr_fire:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    self:createFirstTips()
    -- local tempNode = CCNode:create()
    -- ccbNode:addChild(tempNode)
    -- schedule(tempNode, function (  )
    --         local function responseMethod(tag,gameData)
    --         -- cclog2(gameData, "magic_school_open_contract responseMethod  ==== btnTag  ")
    --         self:refreshData( gameData )
    --         -- 飘奖励
    --         local data = gameData and gameData:getNodeWithKey("data")
    --         local rewards = data and data:getNodeWithKey("reward")
    --         game_util:rewardTipsByDataTable(rewards and json.decode(rewards:getFormatBuffer()) or {})
    --         self:refreshUi()
    --          end
    --     local params = {contract_id = 1}
    --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_open_contract"), http_request_method.GET, params,"magic_school_open_contract")
   
    -- end, 0.5)
    return ccbNode;
end

--[[
    创建提示
]]
function ui_firecup_scene.createFirstTips( self )
    local viewSize = self.m_node_firsttips:getContentSize()
    local scrollView = CCScrollView:create(viewSize);
    scrollView:setDirection(kCCScrollViewDirectionHorizontal);
    self.m_node_firsttips:addChild(scrollView,2,2);

    local tempNode = CCNode:create()
    tempNode:setContentSize(viewSize)
    scrollView:getContainer():addChild(tempNode)
    scrollView:setTouchEnabled(false)

    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_9_32X32.png")
    tempBg:setPreferredSize(CCSizeMake(viewSize.width - 10, viewSize.height))
    tempBg:setAnchorPoint(ccp(0.5, 0.5))
    tempBg:setPosition(viewSize.width * 0.5, viewSize.height * 0.5)
    tempNode:addChild(tempBg)

    local msg = self.m_cupInfo or string_helper.ui_firecup_scene.text
    local labelSize = CCSizeMake(viewSize.width * 0.8 , 0)
    local richLabel = game_util:createRichLabelTTF({text = msg,dimensions = labelSize,textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255, 255, 255),fontSize = 10})
    richLabel:setAnchorPoint(ccp(0.5, 1))
    richLabel:setPosition(ccp( viewSize.width * 0.5 + 1,  viewSize.height - 4))
    tempNode:addChild(richLabel,10,10)

    function moveEndCallFun(  )
        -- scrollView:removeFromParentAndCleanup(true)
        -- self.m_node_firsttips:removeAllChildrenWithCleanup(true)
        self.m_first_tips_show = false
    end
    function moveFun( time, showEnd )
        if showEnd == true then
            tempNode:stopAllActions()
            local animArr = CCArray:create();
            animArr:addObject(CCMoveBy:create(0.8, ccp(viewSize.width + 10, 0)))
            animArr:addObject(CCCallFunc:create(moveEndCallFun));
            local sequence = CCSequence:create(animArr)
            tempNode:runAction(sequence);
            return 
        end
        tempNode:stopAllActions()
        time = time or 1
        tempNode:setPosition(2, 0)
        self.m_first_tips_show = true
        local animArr = CCArray:create();
        animArr:addObject(CCDelayTime:create(time));
        animArr:addObject(CCMoveBy:create(0.8, ccp(viewSize.width + 10, 0)))
        animArr:addObject(CCCallFunc:create(moveEndCallFun));
        local sequence = CCSequence:create(animArr)
        tempNode:runAction(sequence);
    end
    moveFun()
    local onBtnCilck = function (  )
        if self.m_first_tips_show == true then 
            moveFun(0, true)
        else
            moveFun(3)
        end
    end
    local btnSize = self.m_node_firecup:getContentSize()
    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
    button:setPreferredSize(CCSizeMake(btnSize.width , btnSize.height * 0.5 ))
    button:setAnchorPoint(ccp(0.5, 0))
    button:setOpacity(0)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    button:setPosition(btnSize.width * 0.5, 0)
    self.m_spr_cup:getParent():addChild(button)
end


--[[
    刷新抽奖倒计时
]]
function ui_firecup_scene.refreshLuckDrawTime( self )
    local luckTime = self.m_tGameData.time_count_down or -1

    -- if luckTime > 0 then
    --     local timeDate = os.date("*t", luckTime)
    --     local hour = timeDate.hour
    local title_info = self.m_titleInfo or ""
    -- end
    self.m_label_titleinfo:setString(tostring(title_info))
        
    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    
    self.m_label_countdtitle:setString(string_helper.ccb.file84)
    if luckTime >= serTime then
        function timeDownFun(  )
            self:countDownTimeEnd()
        end
        self.m_label_countdtitle:removeAllChildrenWithCleanup(true)
        self.m_label_countdtitle:setFontSize(10)
        local tempCountTime = math.max(1, luckTime - serTime)
        if serTime >= luckTime then
            cclog2( "ui_firecup_scene luck time been down ")
        end
        local lastTimeLabel = game_util:createCountdownLabel(tempCountTime, timeDownFun, 10, 1)
        lastTimeLabel:setAnchorPoint(ccp(0, 0.5))
        lastTimeLabel:setPositionY(self.m_label_countdtitle:getContentSize().height * 0.5)
        lastTimeLabel:setPositionX(self.m_label_countdtitle:getContentSize().width)
        lastTimeLabel:setVisible(true)
        self.m_label_countdtitle:addChild(lastTimeLabel)
    else
        self.m_label_countdtitle:setVisible(false)
    end
end

--[[
    刷新契约信息
]]
function ui_firecup_scene.refreshQiYue( self )
    self.m_node_showitemboard:removeAllChildrenWithCleanup(true)
    local newTableView = self:createQiYueTableView(self.m_node_showitemboard:getContentSize())
    if newTableView then
        self.m_node_showitemboard:addChild(newTableView)
    end
end

--[[
    刷新活动信息
]]
local press_val = {0.21, 0.21, 0.34, 0.71, 0.93}
function ui_firecup_scene.refreshFirecupInfo( self )
    local max_score = self.m_maxFireScore
    local cur_score = self.m_tGameData.cost_storage or 0
    local last_zuanshi_info = ""
    self.m_spr_fire:setVisible(false)
    if max_score > 0 then
        self.m_cupProgress:setMaxValue(max_score)
        self.m_cupProgress:setCurValue(cur_score, false)
        last_zuanshi_info = last_zuanshi_info .. tostring(cur_score) .. "/" .. tostring(max_score)
        -- if max_score <= cur_score then
        --     self.m_spr_fire:setVisible(true)
        -- end
    end
    local qiyu_score = self.m_tGameData.point or 0

    -- 契约信息
    self.m_label_myscore:setString(tostring(qiyu_score))
    self.m_label_lastzuanshi:setString(tostring(last_zuanshi_info))

    local firestate_frame = nil
    -- fire 倒计时
    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    local nextTime = self.m_tGameData.time_fire_cup_count_down or 0
    self.m_label_firecountd_title:setString(string_helper.ui_firecup_scene.countdown)
    -- nextTime = serTime + 20
    if nextTime >= serTime then
        self.m_spr_fire:setVisible(true)
        local tempTime = math.max(1, nextTime - serTime)
        self.m_label_firecountd_title:removeAllChildrenWithCleanup(true)
        self.m_label_firecountd_title:setVisible(true)
        function timeDownFun(  )
            self:countDownTimeEnd()
        end
        local lastTimeLabel = game_util:createCountdownLabel(tempTime, timeDownFun, 10, 2)
        lastTimeLabel:setAnchorPoint(ccp(0, 0.5))
        lastTimeLabel:setPositionY(self.m_label_firecountd_title:getContentSize().height * 0.5)
        lastTimeLabel:setPositionX(self.m_label_firecountd_title:getContentSize().width + 2)
        lastTimeLabel:setVisible(true)
        self.m_label_firecountd_title:addChild(lastTimeLabel)
        firestate_frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_firecup_firestate.png")
    else
        self.m_label_firecountd_title:setVisible(false)
        firestate_frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_firecup_cunchuzhuangtai.png")
    end
    -- cclog2(self.m_spr_firestate, "m_spr_firestate   ====    ")
    -- cclog2(firestate_frame, "firestate_frame   ====    ")
    if self.m_spr_firestate and firestate_frame then
        self.m_spr_firestate:setDisplayFrame(firestate_frame)
    end
end

--[[
    倒计时结束
]]
function ui_firecup_scene.countDownTimeEnd( self )
    function responseMethod(tag,gameData)
        self:formatData( gameData )
        self:refreshUi()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_index"), http_request_method.GET, nil,"magic_school_index")
end

--[[-- 
    创建宝箱动画
]]
function ui_firecup_scene.createBoxAnim(self,animFile)
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

--[[
    创建奖励信息
]]
function ui_firecup_scene.createRewardInfo( self )
    local barSize = self.m_node_rewardnode:getContentSize();
    local barsize = CCSizeMake(260, 8)
    local bar = ExtProgressBar:createWithFrameName("ui_firecup_0alpha.png", "ui_firecup_jindutiao1.png", barsize);
    bar:setPosition( 2, self.m_spr_jidutiaback:getContentSize().height * 0.5 - 4)
    self.m_spr_jidutiaback:addChild(bar, 1);
    self.m_rewardProgress_bar = bar;

    local contract_score_reward_cfg = getConfig(game_config_field.contract_score_reward)
    -- local nodeCount = contract_score_reward_cfg and contract_score_reward_cfg:getNodeCount() or 0
    -- local maxInfoNode = contract_score_reward_cfg and contract_score_reward_cfg:getNodeAt(nodeCount - 1)
    -- local maxCost = maxInfoNode and maxInfoNode:getNodeWithKey("cost"):toInt() or 100
    -- bar:setMaxValue(maxCost)
    -- bar:setCurValue(0,false);
    -- cclog2(self.m_score_rewardTab, "self.m_score_rewardTab = ========   ")
    local costTab = {}
    for i=1, #self.m_score_rewardTab do
        local itemCfg = contract_score_reward_cfg and contract_score_reward_cfg:getNodeWithKey( tostring(self.m_score_rewardTab[i]) )
        local cost = itemCfg:getNodeWithKey("cost") and itemCfg:getNodeWithKey("cost"):toInt()
        if cost then
            table.insert(costTab, cost)
        end
    end
    -- local sortFun = function ( data1, data2 )
    --     return tonumber(data1) < tonumber(data2)
    -- end
    -- table.sort(costTab, sortFun)
    self.m_rewardCostTab = costTab
    local maxCost = costTab[#costTab] or 100
    bar:setMaxValue(maxCost)
    bar:setCurValue(0,false);

    -- 奖励进度条
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_daily_task_res.plist")
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 10000
        if self.m_rewardInfo["reward" .. tostring(index)] == 1 then -- 奖励可以领取
            -- do return end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self:refreshData(gameData)
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_point_reward"), http_request_method.GET, {reward_id = index},"magic_school_point_reward")
        else
            self:createRewardTipsPop( self.m_rewardbox_stageTab[index].boxAnim, index )
        end
    end

    self.m_rewardbox_stageTab = {}
    local animTab = {"anim_ui_baoxiang3", "anim_ui_baoxiang3", "anim_ui_baoxiang3", "anim_ui_baoxiang3"};
    local nodeposX = {0.19, 0.41, 0.63, 0.85}
    for i=1,4 do
        local stage_node = CCSprite:create()
        local tempSize = self.m_node_rewardnode:getContentSize();
        local tempAnim = self:createBoxAnim(animTab[i])
        stage_node:setPosition(tempSize.width*nodeposX[i], tempSize.height*0.5);
        self.m_node_rewardnode:addChild( stage_node )
        tempAnim:setTag(i);
        stage_node:addChild(tempAnim, 1)
        stage_node:setScale(0.8)
        -- stage_node:setRotation(15)
        stage_node:setFlipX(true)
        self.m_rewardbox_stageTab[i] = {m_stage = stage_node,boxAnim = tempAnim,openFlag = false}

        local score = costTab[i]
        local scoreInfo = ""
        if score then
            scoreInfo = tostring(score)
        end
        local scoreLabel = game_util:createLabelTTF({text = scoreInfo,fontSize = 10})
        scoreLabel:setColor( ccc3(0, 255, 0) )
        scoreLabel:setPosition(tempSize.width*nodeposX[i], tempSize.height*0.15)
        self.m_node_rewardnode:addChild(scoreLabel)


        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setOpacity(0)
        stage_node:addChild(button)
        button:setTag(10000 + i)
    end   
end

--[[--
    奖励弹出框
]]
function ui_firecup_scene.createRewardTipsPop(self,clickNode, reward_index)
    if self.m_rewardTips then return end
    local tag = clickNode:getTag();
    local contract_score_reward_cfg = getConfig(game_config_field.contract_score_reward)
    -- cclog2(reward_cfg, "reward_cfg = =====  ")
    local rewardKye = self.m_score_rewardTab[ tonumber(reward_index) ]
    local reward_item_cfg = contract_score_reward_cfg:getNodeWithKey(tostring(rewardKye))
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if reward_item_cfg then
        local reward = reward_item_cfg:getNodeWithKey("reward")
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
    local titleLabel = game_util:createLabelTTF({text = string_helper.ui_firecup_scene.award,color = ccc3(250,180,0),fontSize = 14});
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


--[[
    刷新奖励信息
]]
function ui_firecup_scene.refreshRewardInfo( self )
    local qiyu_score = self.m_tGameData.point or 0
    local level = #self.m_rewardCostTab
    local maxScore = self.m_rewardCostTab[level]
    local scaleValue = {0.2, 0.45, 0.7, 1}
    local showQiyuValue = 0
    local perScore = qiyu_score
    local dValue = 0
    local dscale = 0
    for i,v in ipairs(self.m_rewardCostTab) do
        if qiyu_score < v then
            showQiyuValue = showQiyuValue + perScore / ( v - dValue ) * (scaleValue[i] - dscale ) * maxScore
            break
        else
            perScore = qiyu_score - v
            showQiyuValue = scaleValue[i] * maxScore
            dValue = v
            dscale = scaleValue[i]
        end
    end
    self.m_rewardProgress_bar:setCurValue(showQiyuValue, true)
    --     local curVaue = 0
    --     local m_shared = 0;
    --     function tick( dt )
    --         local qiyu_score = curVaue
    --         local level = #self.m_rewardCostTab
    --         local maxScore = self.m_rewardCostTab[level]
    --         local scaleValue = {0.2, 0.45, 0.7, 1}
    --         local showQiyuValue = 0
    --         local perScore = qiyu_score
    --         local dValue = 0
    --         local dscale = 0
    --         for i,v in ipairs(self.m_rewardCostTab) do
    --             if qiyu_score < v then
    --                 cclog2(perScore / ( v - dValue ), "perScore / self.m_rewardCostTab[i]   ====   ")
    --                 cclog2(scaleValue[i] * maxScore, "scaleValue[i] * maxScore   ====   ")
    --                 showQiyuValue = showQiyuValue + perScore / ( v - dValue ) * (scaleValue[i] - dscale ) * maxScore
    --                 break
    --             else
    --                 perScore = qiyu_score - v
    --                 showQiyuValue = scaleValue[i] * maxScore
    --                 dValue = v
    --                 dscale = scaleValue[i]
    --             end
    --         end
    -- cclog2(qiyu_score, "showQiyuValue   ===  ")
    -- cclog2(showQiyuValue, "showQiyuValue   ===  ")
    --         curVaue = curVaue + 20
    --         self.m_label_myscore:setString(tostring(qiyu_score))
    --         self.m_rewardProgress_bar:setCurValue(showQiyuValue, true)
    --     end
    --     m_shared = scheduler.schedule(tick, 0.1, false)
    for i=1, 4 do
        local rewardBoxInfo = self.m_rewardbox_stageTab[i] or {}
        local boxAnim = rewardBoxInfo.boxAnim
        if boxAnim then
            local rewardStatus = self.m_rewardInfo["reward" .. tostring(i)]
            if rewardStatus == 1 then
                boxAnim:playSection("daiji2")
            elseif rewardStatus == 2 then
                boxAnim:playSection("daiji3")
            else
                boxAnim:playSection("daiji1")
            end
        end
    end
end

--[[--
    刷新ui
]]
function ui_firecup_scene.refreshUi(self)
   self:refreshLuckDrawTime()
   self:refreshFirecupInfo()
   self:refreshQiYue()
   self:refreshRewardInfo()
end

--[[
    创建契约信息
]]
function ui_firecup_scene.createQiYueTableView( self, viewSize )
    local itemTitleSprName = {"ui_firecup_zhuangbeiqiyue.png", "ui_firecup_yingxiongqiyue.png", "ui_firecup_chengzhangqiyue.png"}
    local contract_detail_cfg = getConfig(game_config_field.contract_detail)
    local function onMainBtnClick( target,event )
        if self.m_buyContractLimit == false then
            return
        end
        self.m_buyContractLimit = false
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"createQiYueTableView  onMainBtnClick  btnTag  ==  ")
        local function responseMethod(tag,gameData)
            if gameData then
                -- cclog2(gameData, "magic_school_open_contract responseMethod  ==== btnTag  ")
                self:refreshData( gameData )
                -- 飘奖励
                local data = gameData and gameData:getNodeWithKey("data")
                local rewards = data and data:getNodeWithKey("reward")
                game_util:rewardTipsByDataTable(rewards and json.decode(rewards:getFormatBuffer()) or {})
                self:refreshUi()

                -- 钻石大奖
                local cost_big_reward_info = data and data:getNodeWithKey("cost_big_reward")
                if cost_big_reward_info then
                    local cost_big_reward_tab = cost_big_reward_info and json.decode(cost_big_reward_info:getFormatBuffer()) or {}
                    local reward = cost_big_reward_tab.cost_big_reward or {}
                    -- cclog2(reward, " cost coin_bigreward   reward   ====    ")
                    if #reward > 0 then
                        game_scene:addPop("ui_firecup_getdiamond_pop", {rewardInfo = cost_big_reward_tab})
                    end
                end
            end
            self.m_buyContractLimit = true
        end
        local params = {contract_id = btnTag + 1}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_open_contract"), http_request_method.GET, params,"magic_school_open_contract",true, true)
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag, " createQiYueTableView  onBtnCilck btnTag === ")
        local contract_key = self.m_contract_tab[ btnTag + 1]  
        local itemData = contract_detail_cfg:getNodeWithKey( tonumber(contract_key) )
        local rewards = itemData and itemData:getNodeWithKey("reward_show_final")
        local reward = rewards and rewards:getNodeAt(0)
        if reward then game_util:lookItemDetal(json.decode(reward:getFormatBuffer()) or {}) end
    end

    local nodeCount = #self.m_contract_tab
    local itemCount = nodeCount
    cclog2(itemCount, "showData count  ====    ")
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3;
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
            ccbNode:openCCBFile("ccb/ui_firecup_qiyue_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then 
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode") 
            local contract_key = self.m_contract_tab[ index + 1]  
            local itemData = contract_detail_cfg:getNodeWithKey( tonumber(contract_key) )
            if ccbNode and itemData then 
                local m_node_showitem = ccbNode:nodeForName("m_node_showitem")  -- 奖励展示板
                local m_blable_cost = ccbNode:labelBMFontForName("m_blable_cost")  -- 钻石数量显示
                local m_conbtn_xiangqing = ccbNode:controlButtonForName("m_conbtn_xiangqing")  -- 签订按钮
                local m_node_costboard = ccbNode:nodeForName("m_node_costboard")
                local m_node_costboard_free = ccbNode:nodeForName("m_node_costboard_free")
                m_conbtn_xiangqing:setTag(index)
                local m_spr_title = ccbNode:spriteForName("m_spr_title")
                -- 花费
                local cost = itemData:getNodeWithKey("coin") and itemData:getNodeWithKey("coin"):toInt() or 50
                local free_times = self.m_tGameData.free_times or {}
                if free_times[tostring(index + 1)] == 0 then  -- 免费
                    m_node_costboard:setVisible(false)
                    m_node_costboard_free:setVisible(true)
                else
                    m_node_costboard_free:setVisible(false)
                    m_node_costboard:setVisible(true)
                end
                m_blable_cost:setString(tostring(cost))
                -- 奖励
                m_node_showitem:removeAllChildrenWithCleanup(true)
                local rewards = itemData:getNodeWithKey("reward_show_final")
                local reward = rewards:getNodeAt(0)
                -- cclog2(reward , "reward   =====   ")
                local reward_icon,name,count = game_util:getRewardByItem(reward, true);
                if reward_icon then
                    local size = m_node_showitem:getContentSize()
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.8)
                    reward_icon:setPosition(size.width * 0.5, size.height * 0.5)
                    m_node_showitem:addChild(reward_icon,10,10)

                    if count then
                        local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count)})
                        blabelCount:setAnchorPoint(ccp(0, 0.5))
                        blabelCount:setPosition(reward_icon:getContentSize().width -2, 0)
                        reward_icon:addChild(blabelCount, 11)
                    end
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(size.width * 0.5, size.height * 0.5))
                    button:setOpacity(0)
                    m_node_showitem:addChild(button)
                    button:setTag(index)
                end

                -- 签约按钮
                if false then   -- 已经签订
                    m_conbtn_xiangqing:setEnabled(false)
                else
                    m_conbtn_xiangqing:setEnabled(true)
                end

                -- 标题
                local frameSprName = itemTitleSprName[index + 1] or ""
                local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameSprName)
                if tempFrame and m_spr_title then
                    m_spr_title:setDisplayFrame(tempFrame)
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
        end
    end
    local tableview = TableViewHelper:create(params)
    if itemCount <= 3 then
        tableview:setMoveFlag(false)
    end
    return tableview
end

--[[
    格式化数据
]]
function ui_firecup_scene.formatData( self, gameData )
    if gameData and tolua.type(gameData) == "util_json" then
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    local contract_cfg = getConfig(game_config_field.contract)
    local tempCfg = contract_cfg and contract_cfg:getNodeWithKey(tostring(self.m_tGameData.version))
    local max_score_cfg = tempCfg and tempCfg:getNodeWithKey("fire_score")
    local max_score = max_score_cfg and max_score_cfg:toInt() or -1
    local title_info_cfg = tempCfg and tempCfg:getNodeWithKey("contract_des")
    self.m_titleInfo = title_info_cfg and title_info_cfg:toStr()


    local fire_des_cfg = tempCfg and tempCfg:getNodeWithKey("fire_des")
    self.m_cupInfo = fire_des_cfg and fire_des_cfg:toStr()

    self.m_maxFireScore = max_score
    self:refreshData(nil)
    -- local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    -- self.m_tGameData.time_fire_cup_count_down = serTime + 55555

    self.m_contract_tab = {}
    local contract_detail_cfg = getConfig(game_config_field.contract_detail)
    local contract_count = contract_detail_cfg:getNodeCount()
    for i=1, contract_count do
        local itemCfg = contract_detail_cfg:getNodeAt(i - 1)
        if itemCfg and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
            table.insert(self.m_contract_tab, itemCfg:getKey())
        end
    end
    local sortFun = function ( data1, data2 )
        return tonumber(data1) < tonumber(data2) 
    end
    table.sort(self.m_contract_tab, sortFun)


end

--[[
    刷新数据
]]
function ui_firecup_scene.refreshData( self, gameData )

    local data = gameData and gameData:getNodeWithKey("data")
    local tempDataTab = data and json.decode(data:getFormatBuffer()) or {}

    -- 我的契约
    if tempDataTab.code then
        self.m_tGameData.contract = tempDataTab.code
    end
    if tempDataTab.contract then
        self.m_tGameData.contract = tempDataTab.contract
    end
    if tempDataTab.page_sort_count then
        self.m_tGameData.page_sort_count = tempDataTab.page_sort_count
    end         

    -- 积分
    if tempDataTab.point then
        self.m_tGameData.point = tempDataTab.point
    end
    -- 火焰杯时间
    if tempDataTab.time_fire_cup_count_down then
        self.m_tGameData.time_fire_cup_count_down = tempDataTab.time_fire_cup_count_down
    end
    -- 钻石存量
    if tempDataTab.cost_storage then
        self.m_tGameData.cost_storage = tempDataTab.cost_storage
    end
    -- 免费次数
    if tempDataTab.free_times then
        self.m_tGameData.free_times = tempDataTab.free_times
    end
    -- 可以领取的奖励
    if tempDataTab.receive_point_reward then
        self.m_tGameData.receive_point_reward = tempDataTab.receive_point_reward
    end
    -- 已经领取的奖励
    if tempDataTab.receive_reward then
        self.m_tGameData.receive_reward = tempDataTab.receive_reward
    end
    -- 钻石大奖
    if tempDataTab.cost_big_reward then
        self.m_tGameData.cost_big_reward = tempDataTab.cost_big_reward

    end
    -- 幸运契约
    if tempDataTab.lucky_contract then
        self.m_tGameData.lucky_contract = tempDataTab.lucky_contract
    end

    -- 奖励状态
    local curCanReward = self.m_tGameData.receive_point_reward or {}
    local alreadyReward = self.m_tGameData.receive_reward or {}
    local rewardInfo = {}
    for i,v in ipairs(curCanReward) do          -- 
        rewardInfo["reward" .. tostring(v)] = 1
    end
    for i,v in ipairs(alreadyReward) do
        rewardInfo["reward" .. tostring(v)] = 2
    end
    -- cclog2(rewardInfo, " rewardInfo === ")
    self.m_rewardInfo = rewardInfo

    self.m_score_rewardTab = {}


    local contract_score_reward_cfg = getConfig(game_config_field.contract_score_reward)
    local nodeCount = contract_score_reward_cfg and contract_score_reward_cfg:getNodeCount() or 0
    for i=1, nodeCount do
        local itemCfg = contract_score_reward_cfg and contract_score_reward_cfg:getNodeAt(i - 1)
        if itemCfg and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
            table.insert(self.m_score_rewardTab, itemCfg:getKey())
        end
    end
    local sortFun = function ( data1, data2 )
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(self.m_score_rewardTab, sortFun)
end

--[[--
    初始化
]]
function ui_firecup_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = {};
    self.m_screenShoot = t_params.screenShoot;
    self:formatData(t_params.gameData)
    self.m_buyContractLimit = true
end

--[[--
    创建ui入口并初始化数据
]]
function ui_firecup_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_firecup_scene;