---  跨服金字塔
cclog2 = cclog2 or function() end
local game_pyramid_scene = {
    m_label_cuttimes = nil,
    m_node_rewardboard = nil,
    m_blabel_wintimes = nil,
    m_blabel_beattack = nil,
    m_node_moraleboard = nil,
    m_blabel_morale = nil,
    m_lebel_level1 = nil,
    m_lebel_level2 = nil, 
    m_label_titleinfo = nil,
    m_progress_morale = nil,
    m_curLevel_reward = nil,
    m_node_screen = nil,
    m_lable_guwucost = nil,
    m_node_screen2 = nil,

    m_curShowScreenInfo = nil,
    m_spr_rewardtitle = nil,
    m_node_noreward = nil,
    m_label_rewardtips = nil,
    m_node_myroleboard = nil,
    m_scale9spr_rewardboard = nil,
    m_scroll_msgBoard = nil,
    m_node_broadcastboard = nil,
}

--[[--
    销毁ui
]]
function game_pyramid_scene.destroy(self)
    -- body
    cclog("----------------- game_pyramid_scene destroy-----------------"); 
    self.m_label_cuttimes = nil;
    self.m_node_rewardboard = nil;
    self.m_blabel_wintimes = nil;
    self.m_blabel_beattack = nil;
    self.m_node_moraleboard = nil;
    self.m_blabel_morale = nil;
    self.m_lebel_level1 = nil;
    self.m_lebel_level2 = nil; 
    self.m_label_titleinfo = nil;
    self.m_progress_morale = nil;
    self.m_curLevel_reward = nil;
    self.m_node_screen = nil;
    self.m_lable_guwucost = nil;
    self.m_node_screen2 = nil;
    self.m_curShowScreenInfo = nil;
    self.m_spr_rewardtitle = nil;
    self.m_node_noreward = nil;
    self.m_label_rewardtips = nil;
    self.m_node_myroleboard = nil;
    self.m_scale9spr_rewardboard = nil;
    self.m_scroll_msgBoard = nil;
    self.m_node_broadcastboard = nil;
end
--[[--
    返回
]]
function game_pyramid_scene.back(self,backType)
    game_scene:enterGameUi("open_door_main_scene",{});
end
--[[--
    读取ccbi创建ui
]]
function game_pyramid_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "pyramid index onMainBtnClick press button tag is ")
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 301 then -- 仇人
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_enemylist_scene", {gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_show_enemys"), http_request_method.GET, nil,"enemy_show_enemys")
        elseif btnTag == 302 then -- 战绩
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_pyramid_battleinfo_pop", {gameData = gameData, enterType = "game_pyramid_scene"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_battle_log"), http_request_method.GET, nil,"pyramid_battle_log")
        elseif btnTag == 303 then -- 鼓舞士气
            local pyramid_cfg = getConfig(game_config_field.pyramid)
            -- cclog2(pyramid_cfg, "pyramid_cfg   ===   ")
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            local addMoraleCostCfg = tempCfg and tempCfg:getNodeWithKey("pay_add_morale")
            if not addMoraleCostCfg then return end
            local payValue = 50 
            if addMoraleCostCfg:nodeType() == util_json.EArray then
                local price_index = math.min(self.m_gameData.buy_morale_times + 1, addMoraleCostCfg:getNodeCount())
                local priceCfg = addMoraleCostCfg:getNodeAt(math.max(0, price_index - 1))
                if not priceCfg then return end
                payValue = priceCfg:toInt()
            elseif addMoraleCostCfg:nodeType() == util_json.ENumber then
                payValue = addMoraleCostCfg:toInt()
            end
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = string_helper.game_pyramid_scene.energize_success})
                self:refreshData(gameData)
                self:refreshUi()
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_get_up_morale"), http_request_method.GET, nil,"pyramid_get_up_morale")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = string_helper.game_pyramid_scene.cost .. payValue .. string_helper.game_pyramid_scene.diamond_energize,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 304 then -- 去战斗
            local function responseMethod(tag,gameData)
                -- cclog2(gameData, "gameData   =====    ")
                game_scene:enterGameUi("game_pyramid_tower_scene", {gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, nil,"pyramid_go_fight")
        elseif btnTag == 305 then -- 详情

            self:newan()
        elseif btnTag == 306 then  -- 悬赏任务
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_pyramid_offerreward_pop", {gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_wanted_index"), http_request_method.GET, nil,"pyramid_wanted_index")
        elseif btnTag == 401 then -- 购买挑战次数  
            local pyramid_cfg = getConfig(game_config_field.pyramid)
            -- cclog2(pyramid_cfg, "pyramid_cfg   ===   ")
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            local addTimesCostCfg = tempCfg and tempCfg:getNodeWithKey("pay_add_time")
            if not addTimesCostCfg then return end

            local payValue = 50 
            if addTimesCostCfg:nodeType() == util_json.EArray then
                local price_index = math.min(self.m_gameData.buy_times + 1, addTimesCostCfg:getNodeCount())
                local priceCfg = addTimesCostCfg:getNodeAt(math.max(0, price_index - 1))
                if not priceCfg then return end
                payValue = priceCfg:toInt()
            elseif addTimesCostCfg:nodeType() == util_json.ENumber then
                payValue = addTimesCostCfg:toInt()
            end

            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = string_helper.game_pyramid_scene.cost_success})
                self:refreshData(gameData)
                self:refreshUi()
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_buy_challenge_times"), http_request_method.GET, nil,"pyramid_buy_challenge_times")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = string_helper.game_pyramid_scene.cost .. payValue .. string_helper.game_pyramid_scene.diamond_side,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_scene.ccbi");
    self.m_label_cuttimes = ccbNode:labelTTFForName("m_label_lasttimes")
    self.m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")
    self.m_blabel_wintimes = ccbNode:labelBMFontForName("m_blabel_wintimes")
    self.m_blabel_beattack = ccbNode:labelBMFontForName("m_blabel_beattack")
    self.m_node_moraleboard = ccbNode:nodeForName("m_node_moraleboard")
    self.m_lebel_level1 = ccbNode:labelTTFForName("m_lebel_level1")
    self.m_lebel_level2 = ccbNode:labelTTFForName("m_lebel_level2")
    self.m_blabel_morale = ccbNode:labelBMFontForName("m_blabel_morale")
    self.m_node_screen = ccbNode:nodeForName("m_node_screen1")
    self.m_lable_guwucost = ccbNode:labelTTFForName("m_lable_guwucost")
    self.m_node_screen2 = ccbNode:nodeForName("m_node_screen2")
    self.m_spr_rewardtitle = ccbNode:spriteForName("m_spr_rewardtitle")
    self.m_node_noreward = ccbNode:nodeForName("m_node_noreward")
    self.m_label_rewardtips = ccbNode:labelTTFForName("m_label_rewardtips")
    self.m_node_myroleboard = ccbNode:nodeForName("m_node_myroleboard")
    self.m_scale9spr_rewardboard = ccbNode:scale9SpriteForName("m_scale9spr_rewardboard")
    self.m_scale9spr_rewardboard:setOpacity(155)
    self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
    self.m_node_broadcastboard = ccbNode:nodeForName("m_node_broadcastboard")
    if self.m_node_broadcastboard then self.m_node_broadcastboard:setVisible(false) end

    -- 初始化玩家头像

    local roleBoardSize = self.m_node_myroleboard:getContentSize()
    local scrollView = CCScrollView:create(roleBoardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(false)
    local role = game_data:getUserStatusDataByKey("role")
    local role_half = game_util:createRoleBigImgHalf(role)
    role_half:setAnchorPoint(ccp(0.5, 0.3))
    local scale = roleBoardSize.width / role_half:getContentSize().width * 1.2
    role_half:setPositionX(roleBoardSize.width * 0.5)
    -- role_half:setPositionX(roleBoardSize.height * 0.5)
    role_half:setScale(scale)
    scrollView:getContainer():addChild(role_half, 10)
    self.m_node_myroleboard:addChild(scrollView)

    -- 设置奖励提示
    self.m_label_rewardtips:setString(tostring(self.m_pyramidData.show_banner or ""))

    -- -- 重置按钮出米优先级 防止被阻止
    -- function resetBtnTouchPriority( ccbNode, btnName, touchPriority )
    --     if not ccbNode then return end
    --     local btn = ccbNode:controlButtonForName(btnName)
    --     if btn then
    --         btn:setTouchPriority( touchPriority )
    --     end
    -- end
    -- resetBtnTouchPriority(ccbNode, "m_back_btn", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_detail", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_chouren", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_battleinfo", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_battleinfo", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_guwu", GLOBAL_TOUCH_PRIORITY - 3)
    -- resetBtnTouchPriority(ccbNode, "m_btn_figth", GLOBAL_TOUCH_PRIORITY - 3)

    -- 创建 购买次数 刷新挑战倒计时按钮
    local onBtnCilck = function ( event, target )
        onMainBtnClick(target, event)
    end
    local addOneBtn = function ( parent, tag, onBtnCilck, touchPriority )
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setPreferredSize(parent:getContentSize())
        button:setAnchorPoint(ccp(0,0))
        button:setOpacity(0)
        parent:addChild(button)
        button:setTag(tag)
        button:setTouchPriority(touchPriority)
    end
    local m_node_addtimes = ccbNode:nodeForName("m_node_addtimes")
    addOneBtn(m_node_addtimes, 401, onBtnCilck, GLOBAL_TOUCH_PRIORITY - 3)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/open_door_cloister_res.plist")

    -- 创建士气进度条
    local m_node_moraleboard = ccbNode:nodeForName("m_node_moraleboard")
    m_node_moraleboard:removeAllChildrenWithCleanup(true)
    local barSize = m_node_moraleboard:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("xjhl_xuetiao2.png", "xjhl_xuetiao.png");
    -- bar:setPosition( 0, bar:getContentSize().height * 0.5)
    bar:setScaleX(0.9)
    m_node_moraleboard:addChild(bar, 1)
    bar:setMaxValue(self.m_pyramidData.morale or 0)
    bar:setCurValue(0,false)
    bar:setCurValue(50,true)
    self.m_progress_morale = bar



    self:newan()
    return ccbNode;
end


--[[
    刷新士气信息
]]
function game_pyramid_scene.refreshInfo( self )
    local pyramid_cfg = getConfig(game_config_field.pyramid)
    -- 士气
    local lastVal = self.m_progress_morale:getCurValue()
    local curVal = self.m_gameData.morale

    self.m_progress_morale:setMaxValue(self.m_pyramidData.morale)
    self.m_progress_morale:setCurValue(lastVal,false)
    self.m_progress_morale:setCurValue(curVal,true)
    local moraleMsg = tostring(curVal) .. "%"
    self.m_blabel_morale:setString(moraleMsg)

    -- 鼓舞士气
    local pyramid_cfg = getConfig(game_config_field.pyramid)
    -- cclog2(pyramid_cfg, "pyramid_cfg   ===   ")
    if pyramid_cfg then
        local tempCount = pyramid_cfg:getNodeCount()
        local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
        local addMoraleCostCfg = tempCfg and tempCfg:getNodeWithKey("pay_add_morale")
        if addMoraleCostCfg then
            local payValue = 50 
            if addMoraleCostCfg:nodeType() == util_json.EArray then
                local price_index = math.min(self.m_gameData.buy_morale_times + 1, addMoraleCostCfg:getNodeCount())
                local priceCfg = addMoraleCostCfg:getNodeAt(math.max(0, price_index - 1))
                if not priceCfg then return end
                payValue = priceCfg:toInt()
            elseif addMoraleCostCfg:nodeType() == util_json.ENumber then
                payValue = addMoraleCostCfg:toInt()
            end
            self.m_lable_guwucost:setString(tostring(payValue))
        end
    end


    -- 层数信息
    local levelMsg = ""
    local posMsg = ""
    if self.m_gameData.floor == 0 then
        levelMsg = string_helper.game_pyramid_scene.not_send
    else
        levelMsg = tostring(self.m_gameData.floor or 20) .. string_helper.game_pyramid_scene.cen
        posMsg = tostring(self.m_gameData.pos) .. string_helper.game_pyramid_scene.num
    end
    self.m_lebel_level1:setString(levelMsg)
    self.m_lebel_level2:setString(posMsg)

    -- 胜利信息
    self.m_blabel_wintimes:setString(tostring(self.m_gameData.win_times or 0))
    self.m_blabel_beattack:setString(tostring(self.m_gameData.attack_times or 0))

    -- 挑战信息
    local challenge_times = self.m_pyramidData.challenge_times or 0
    local lastTimes = self.m_gameData.challenge_times
    local  msg = tostring(lastTimes) .. "/" .. tostring(challenge_times)
    self.m_label_cuttimes:setString(tostring(msg))

    --
    local titleFrameName = ""
    if self.m_gameData.floor == 0 then
        self.m_node_noreward:setVisible(true)
        -- titleFrameName = "ui_pyramid_n_xinyunjiangli.png"
    else
        -- titleFrameName = "ui_pyramid_n_yuj.png"
        self.m_node_noreward:setVisible(false)
    end
    -- local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(titleFrameName)
    -- if tempFrame and self.m_spr_rewardtitle then
    --     self.m_spr_rewardtitle:setDisplayFrame(tempFrame)
    -- end
end

--[[ 
    挑战信息
]]
function game_pyramid_scene.refreshChallangeInfo( self )
    -- body
end


--[[
    创建进度条
]]
function game_pyramid_scene.createOneProgressNode( self )





end



--[[--
    创建列表
]]
function game_pyramid_scene.addRewardTableView( self, viewBoard )
    if not viewBoard then return end
    local viewSize = viewBoard:getContentSize()

    local leftArrow = CCSprite:createWithSpriteFrameName("pb_jiantou.png")
    leftArrow:setScale(0.5)
    leftArrow:setFlipX(true)
    leftArrow:setPosition(ccp(0,viewSize.height*0.6));
    viewBoard:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("pb_jiantou.png")
    rightArrow:setScale(0.5)
    rightArrow:setPosition(ccp(viewSize.width -5,viewSize.height*0.6));
    viewBoard:addChild(rightArrow)

    leftArrow:setVisible(false)
    rightArrow:setVisible(false)


    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    local showData = self.m_curLevel_reward 
    -- cclog2(showData, "showData === ")
    local itemCount = #showData
    local params = {};
    params.viewSize = CCSizeMake(viewSize.width - 10, viewSize.height);
    params.row = 1;
    params.column = 3;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 5;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.showPoint = false
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData);
            if icon then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(itemSize.width * 0.5, itemSize.height * 0.6)
                cell:addChild(icon,10,10)

                local node = icon:getChildByTag(1)
                if node then
                    node:setVisible(false)
                end

                if count then
                    local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count)})
                    local iconSize = icon:getContentSize()
                    blabelCount:setPosition(iconSize.width * 0.5, itemSize.height * -0.2)
                    blabelCount:setColor(ccc3(0, 255, 0))
                    icon:addChild(blabelCount, 11)
                end
                local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                if sprBoard then
                    sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.6)
                    cell:addChild(sprBoard, 20, 20)
                end
            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "moved" then
            cclog("cell move   ------   ")

        elseif eventType == "ended" then
            cclog2("click table cell index === " .. tostring(index))
            local itemData = showData[index + 1]
            game_util:lookItemDetal(itemData or {})
        end
    end
    
    params.pageChangedCallFunc = function(totalPage,curPage)
        if curPage == 1 then
            leftArrow:setVisible(false)
        else
            leftArrow:setVisible(true)
        end
        if curPage < totalPage then
            rightArrow:setVisible(true)
        else
            rightArrow:setVisible(false)
        end
    end

    local tableView = TableViewHelper:createGallery2(params)
    if tableView then
        viewBoard:addChild(tableView)
    end
end


--[[
    详情
]]
function game_pyramid_scene.newan( self )
    local viewSize = self.m_node_screen:getContentSize()
    self.m_node_screen2:stopAllActions()
    self.m_node_screen:stopAllActions()
    self.m_node_screen:removeChildByTag(998, true)
    self.m_node_screen2:removeAllChildrenWithCleanup(true)
    if self.m_curShowScreenInfo then
        self.m_curShowScreenInfo = false
    else
        self.m_curShowScreenInfo = true
    end
    local isFull = self.m_curShowScreenInfo

    local bgNode = CCNode:create()
    bgNode:setContentSize(viewSize)
    self.m_node_screen:addChild(bgNode,2,998);
    

    local time = 0.5
  
    -- scrollView:setTouchEnabled(false)
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("pb_back3.png")

    if isFull then
        tempBg:setContentSize(CCSizeMake(viewSize.width , viewSize.height * 1))
    else
        tempBg:setContentSize(CCSizeMake(viewSize.width , viewSize.height * 0.3))
    end

    tempBg:setPosition(viewSize.width * 0.5, 0)
    tempBg:setAnchorPoint(ccp(0.5, 0))
    bgNode:addChild(tempBg)

    -- tempBg:setScaleY(0.3)

    -- local heighline = CCSprite:createWithSpriteFrameName("pb_line.png")
    -- heighline:setScale(1.3)
    -- heighline:setAnchorPoint(ccp(0.5, 0.3))
    -- heighline:setPosition(viewSize.width * 0.5, 0)
    -- bgNode:addChild(heighline)


    local sprTitle = CCSprite:createWithSpriteFrameName("ui_pyramid_n_huodongxiangq.png")
    sprTitle:setPosition(viewSize.width * 0.5, viewSize.height * 0.2 + sprTitle:getContentSize().height * 0.5  + 5 )
    bgNode:addChild(sprTitle)


    if isFull then
        -- local scalTo1 = CCScaleTo:create(time, 1, 1)
        -- tempBg:runAction(scalTo1)
        -- tempBg:setScaleY(1)

        -- local moveTo = CCMoveTo:create(time, ccp(viewSize.width * 0.5, viewSize.height * 0.9 + sprTitle:getContentSize().height * 0.5  ) )
        -- sprTitle:runAction(moveTo)

        -- local moveTo = CCMoveTo:create(time, ccp(viewSize.width * 0.5, -5))
        -- tempBg:runAction(moveTo)
        -- tempBg:setPosition(ccp(viewSize.width * 0.5, -5))
        sprTitle:setPosition(ccp(viewSize.width * 0.5, viewSize.height * 0.9 + sprTitle:getContentSize().height * 0.5 - 5  ))
    end

    -- local lineMoveEnd = function (  )
    --     heighline:removeFromParentAndCleanup(true)
    -- end
    -- local animArr = CCArray:create();
    -- animArr:addObject(CCMoveBy:create(time , ccp(0, viewSize.height)));
    -- -- animArr:addObject(CCDelayTime:create(0.1));
    -- animArr:addObject(CCScaleTo:create(0.1, 0, 1));
    -- animArr:addObject(CCCallFunc:create(lineMoveEnd));
    -- heighline:runAction(CCSequence:create(animArr));



        local screen2Size = self.m_node_screen2:getContentSize()
        -- local tempNode = CCNode:create()
        local msgViewSize = nil
        if isFull then
            msgViewSize = screen2Size
        else
            msgViewSize = CCSizeMake(screen2Size.width, screen2Size.height * 0.1 + 7)
        end
        local scrollView = CCScrollView:create(msgViewSize)
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:getContainer():removeAllChildrenWithCleanup(true)
        scrollView:setTouchEnabled(false)

        local msg = string_helper.game_pyramid_scene.msg
        -- if isFull then
            local activeCfg = getConfig(game_config_field.notice_active)
            local itemCfg = activeCfg:getNodeWithKey( "144" )
            msg = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or msg
        -- end
            -- sprTitle:runAction(CCEaseIn:create(CCMoveTo:create(0.5,ccp(screen2Size.width * 0.5, screen2Size.height * 0.8)),2))

        -- local richInfo = game_util:createRichLabelTTF({text = msg, 
        --     dimensions = CCSizeMake(screen2Size.width, 0), textAlignment = kCCTextAlignmentLeft,
        -- verticalTextAlignment = kCCVerticalTextAlignmentCenter})
        -- richInfo:setAnchorPoint(ccp(0.5,1))
        -- richInfo:setPosition(ccp(screen2Size.width * 0.5, 0))
        -- -- tempNode:addChild(richInfo)
        -- -- richInfo:runAction(CCEaseIn:create(CCMoveTo:create(0.5,ccp(screen2Size.width * 0.5, screen2Size.height * 0.7)),2))

        -- local tempSize = richInfo:getContentSize()
        -- richInfo:setPosition(ccp(0, screen2Size.height))
        -- scrollView:setContentSize(CCSizeMake(screen2Size.width + 15, tempSize.height))

        -- -- sprTitle:setPositionY(height - 10)
        -- -- richInfo:setPosition(ccp(screen2Size.width * 0.5, height - 10 ))
        -- -- scrollView:setContentSize(endSize)
        -- -- scrollView:getContainer():addChild(tempNode)
        -- -- scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
        -- scrollView:setContentOffset( ccp(0,  -screen2Size.height ), false)
        -- -- scrollView:setContentOffset( ccp(0,  0), true)
        -- scrollView:setContentOffset(ccp(0, screen2Size.height - tempSize.height), true)
        -- self.m_node_screen2:addChild(scrollView)

        local node, msgLabel = self:createScrollLabel(CCSizeMake(msgViewSize.width, msgViewSize.height - 5), {text = msg}, GLOBAL_TOUCH_PRIORITY - 2)
        if node then self.m_node_screen2:addChild(node) end
        -- if isFull and msgLabel then
        --     msgLabel:setPosition(ccp(0, - msgViewSize.height + 10))
        --     local moveTop = CCMoveTo:create(time, ccp(0, 0))
        --     msgLabel:runAction(moveTop)
        -- end


    -- local animArr = CCArray:create();
    -- animArr:addObject(CCDelayTime:create(0.7));
    -- animArr:addObject(CCCallFuncN:create(endFun));
    -- self.m_node_screen2:runAction(CCSequence:create(animArr));
end

function game_pyramid_scene.createScrollLabel( self, boardSize, params, touchPriority  )
    params = params or {}
    if not boardSize then return end
    local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(true)
    if touchPriority then scrollView:setTouchPriority(touchPriority ) end
    local text = params.text or ""
    local tempLabel = game_util:createRichLabelTTF({text = text,dimensions = CCSizeMake(boardSize.width  ,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    tempLabel:setAnchorPoint(ccp(0,0.99))
    tempLabel:setPosition(ccp(0, 0))
    scrollView:setContentSize(CCSizeMake(boardSize.width + 15, tempSize.height))
    scrollView:setContentOffset(ccp(0, boardSize.height - tempSize.height), false)
    scrollView:addChild(tempLabel, 0, 998)
    return scrollView, tempLabel
end


--[[
    刷新数据
]]
function game_pyramid_scene.refreshData( self, gameData )
    local tempData = {}
    if gameData then
        local data = gameData and gameData:getNodeWithKey("data")
        tempData = data and json.decode(data:getFormatBuffer()) or {}
    end
    if tempData.morale then
        self.m_gameData.morale = tempData.morale
    end
    if tempData.challenge_times then
        self.m_gameData.challenge_times = tempData.challenge_times
    end

    if tempData.pyramid_notice then
        self.m_gameData.pyramid_notice = tempData.pyramid_notice
    end

    if tempData.buy_times then
        self.m_gameData.buy_times = tempData.buy_times
    end

    if tempData.buy_morale_times then
        self.m_gameData.buy_morale_times = tempData.buy_morale_times
    end

    self.m_gameData.buy_morale_times = self.m_gameData.buy_morale_times or 0
    self.m_gameData.buy_times = self.m_gameData.buy_times or 0

    self.m_curLevel_reward = {}
    local pyramid_level_cfg = getConfig(game_config_field.pyramid_level)    
    local curLevel = self.m_gameData.floor
    if curLevel ~= 0 then
        local curLevelCfg = pyramid_level_cfg:getNodeWithKey(tostring(curLevel))
        local reward = curLevelCfg and curLevelCfg:getNodeWithKey("reward_show")
        -- cclog2(curLevel, "curLevel  ====  ")
        -- cclog2(pyramid_level_cfg, "pyramid_level_cfg  ====  ")
        -- cclog2(curLevelCfg, "curLevelCfg  ====  ")
        -- cclog2(reward, "reward  ====  ")
        self.m_curLevel_reward = reward and json.decode(reward:getFormatBuffer()) or {}
    else -- 显示幸运奖励
        self.m_curLevel_reward = {}
        -- local pyramid_lucky_cfg = getConfig(game_config_field.pyramid_lucky)
        -- local tempCount = pyramid_lucky_cfg:getNodeCount()
        -- for i=1, tempCount do
        --     local tempNode = pyramid_lucky_cfg:getNodeAt(i - 1)
        --     local reward = tempNode:getNodeWithKey("reward")
        --     local oneReward = json.decode(reward:getFormatBuffer())
        --     if oneReward then
        --         for k,v in pairs(oneReward) do
        --             table.insert(self.m_curLevel_reward, v)
        --         end
        --     end
        -- end
    end
end

--[[
    刷新消息
]]
function game_pyramid_scene.refreshBroadCastMsg( self )
    local msgTab = {}
    for k,v in pairs(self.m_gameData.pyramid_notice or {}) do
        if type(v) == "table" and v.msg then
            table.insert(msgTab, v.msg)
        end
    end
    if #msgTab > 0 and self.m_node_broadcastboard then
        game_util:createScrollViewTips(self.m_scroll_msgBoard, msgTab, true, 1, ccc3(200, 255,255), 8)
        self.m_node_broadcastboard:setVisible(true)
    elseif self.m_node_broadcastboard then
        self.m_node_broadcastboard:setVisible(false)
    end
end


--[[--
    刷新ui
]]
function game_pyramid_scene.refreshUi( self )
    self.m_node_rewardboard:removeAllChildrenWithCleanup(true)
    self:addRewardTableView( self.m_node_rewardboard )

    self:refreshInfo()
    self:refreshBroadCastMsg()
end

--[[
    格式化数据
]]
function game_pyramid_scene.formatData( self )
    self.m_pyramidData = {}
    local pyramid_cfg = getConfig(game_config_field.pyramid)
    local nodeCount = pyramid_cfg and pyramid_cfg:getNodeCount() or 1
    local tempCfg = pyramid_cfg and pyramid_cfg:getNodeAt(nodeCount - 1 )
    self.m_pyramidData = tempCfg and json.decode(tempCfg:getFormatBuffer()) or {}
    self:refreshData()
end

--[[--
    初始化
]]
function game_pyramid_scene.init(self,t_params)
    t_params = t_params or {}
    self.m_gameData = {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    -- self.m_gameData.floor = math.max(self.m_gameData.floor, 1)
    self:formatData()
    self.m_curShowScreenInfo = true
    
end
--[[--
    创建ui入口并初始化数据
]]
function game_pyramid_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_pyramid_scene