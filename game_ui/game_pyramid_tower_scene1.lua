---  跨服金字塔
cclog2 = cclog2 or function() end
local game_pyramid_tower_scene = {
    m_label_lasttimes = nil,
    m_node_countdown = nil,
    m_node_rewardboard = nil,
    m_blabel_wintimes = nil,
    m_blabel_beattack = nil,
    m_node_moraleboard = nil,
    m_levelInfo = nil,
    m_pyramidData = nil,
    m_cur_select_level = nil,

    m_last_select_levelCell = nil,

    m_level_tableView = nil,

    m_morale_progerssBar = nil,
    m_pyramidNode = nil,
    m_pyramidMoveFlag = nil,
    m_node_pyramidnode = nil,
    m_node_leftnodes = nil,
    m_node_rightnodes = nil,
    m_label_levelpenums = nil,
    m_blabellevel_names = nil,
    m_curLevelGroup = nil,
    m_curSelectLevel = nil,
    m_node_levelNodeboards = nil,
    m_node_leftinfos = nil,
    m_node_rightinfos = nil,

    m_curFloorPlayerData = nil,
    m_label_morale = nil,
    m_cur_foor = nil,
    m_blabel_curlevelname = nil,
    m_label_mylevelname = nil,
    m_node_battleinfoboard = nil,  -- 战报信息动作板
    m_node_battlemsgboard = nil, -- msg信息板
    m_spr_levelfightstate = nil,  -- 本层战斗状态
    m_node_canfighnode = nil,
}

--[[--
    销毁ui
]]
function game_pyramid_tower_scene.destroy(self)
    -- body
    cclog("----------------- game_pyramid_tower_scene destroy-----------------"); 
    self.m_label_lasttimes = nil;
    self.m_node_countdown = nil;
    self.m_node_rewardboard = nil;
    self.m_blabel_wintimes = nil;
    self.m_blabel_beattack = nil;
    self.m_node_moraleboard = nil;
    self.m_levelInfo = nil;
    self.m_cur_select_level = nil;
    self.m_pyramidData = nil;
    self.m_last_select_levelCell = nil;
    self.m_level_tableView = nil;
    self.m_morale_progerssBar = nil;
    self.m_pyramidNode = nil;
    self.m_pyramidMoveFlag = nil;
    self.m_node_pyramidnode = nil;
    self.m_node_leftnodes = nil;
    self.m_node_rightnodes = nil;
    self.m_label_levelpenums = nil;
    self.m_node_levelNodeboards = nil;
    self.m_blabellevel_names = nil;
    self.m_curSelectLevel = nil;
    self.m_curLevelGroup = nil;
    self.m_node_rightinfos = nil;
    self.m_node_leftinfos = nil;
    self.m_curFloorPlayerData = nil;
    self.m_label_morale = nil;
    self.m_cur_foor = nil;
    self.m_blabel_curlevelname = nil;
    self.m_label_mylevelname = nil;
    self.m_node_battleinfoboard = nil;  
    self.m_node_battlemsgboard = nil;
    self.m_spr_levelfightstate = nil;
    self.m_node_canfighnode = nil;
end
--[[--
    返回
]]
function game_pyramid_tower_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_pyramid_tower_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local pyramidMove = nil
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "pyramid index onMainBtnClick press button tag is ")
        if btnTag == 1 then -- 关闭
            -- self:back()
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_pyramid_scene",{gameData = gameData,screenShoot = screenShoot, openData = {}});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_index"), http_request_method.GET, nil,"pyramid_index")        
        
        elseif btnTag == 2 then -- 右边按钮

        elseif btnTag > 600 and btnTag < 604 then
            -- 查看选中层玩家
            local level = math.max(self.m_curLevelGroup - 1, 0) * 3 + btnTag - 600
            local function responseMethod(tag,gameData)
                self.m_curSelectLevel = level
                self:refreshData(gameData)
                self:refreshUi()
            end
            local params = {}
            params.floor = level
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, params,"pyramid_go_fight")
        elseif btnTag > 500 and btnTag < 504 then
            local showLevel = (self.m_curLevelGroup - 1) * 3 + (btnTag - 500)
            game_scene:addPop("ui_pyramid_rewards_pop", {showLevel = showLevel})
        elseif btnTag == 401 then
            local pyramid_cfg = getConfig(game_config_field.pyramid)
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            if not tempCfg then return end
            local addMoraleCost = tempCfg:getNodeWithKey("pay_add_morale"):toInt()
            local pyramid_cfg = getConfig(game_config_field.pyramid)
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            if not tempCfg then return end
            local addTimesCost = tempCfg:getNodeWithKey("pay_add_time"):toInt()
            local payValue = addTimesCost
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = "购买挑战次数成功~"})
                game_util:closeAlertView();
                self:refreshData(gameData)
                self:refreshUi()
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_buy_challenge_times"), http_request_method.GET, nil,"pyramid_buy_challenge_times")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "是否花费" .. payValue .. "钻石购买挑战次数？",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-5,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 402 then
            local pyramid_cfg = getConfig(game_config_field.pyramid)
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            if not tempCfg then return end
            local addMoraleCost = tempCfg:getNodeWithKey("pay_add_morale"):toInt()
            local payValue = addMoraleCost
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = "鼓舞士气成功成功~"})
                game_util:closeAlertView();
                self:refreshData(gameData)
                self:refreshUi()
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_get_up_morale"), http_request_method.GET, nil,"pyramid_get_up_morale")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = "是否花费" .. payValue .. "钻石购鼓舞士气？",      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-5,
            }
            game_util:openAlertView(t_params)  
        elseif btnTag == 801 then
            local myFloor = self.m_gameData.floor 
            if myFloor == 0 then 
                myFloor = 20 
            end
            local myLevelGroup = math.ceil(myFloor / 3)
            local curGroup = self.m_curLevelGroup
            self.m_curLevelGroup = myLevelGroup
            self.m_curSelectLevel = myFloor
            if type(pyramidMove) == "function" then
                if curGroup < myLevelGroup then
                    pyramidMove(1, false, false, true)
                elseif curGroup > myLevelGroup then
                    pyramidMove(1, true, false, true)
                else
                end
            end
            self:refreshUi()
        elseif btnTag == 802 then  -- 查看战报
            -- self.m_node_battleinfoboard:stopAllActions()
            -- self.m_node_battleinfoboard:setScale(0)
            -- local animArr = CCArray:create();
            -- animArr:addObject(CCScaleTo:create(0.5, 1, 1));
            -- animArr:addObject(CCDelayTime:create(2));
            -- animArr:addObject(CCScaleTo:create(0.5, 0, 0));
            -- self.m_node_battleinfoboard:runAction(CCSequence:create(animArr));
            game_scene:addPop("ui_pyramid_battleinfo_pop")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_tower.ccbi");
    self.m_node_levellistboard = ccbNode:nodeForName("m_node_levellistboard")
    self.m_node_playersboard = ccbNode:nodeForName("m_node_playersboard")
    self.m_label_lasttimes = ccbNode:labelTTFForName("m_label_lasttimes")
    self.m_node_moraleboard = ccbNode:nodeForName("m_node_moraleboard")
    self.m_node_pyramidnode = ccbNode:nodeForName("m_node_pyramidnode")
    self.m_node_leftnodes = ccbNode:nodeForName("m_node_leftnodes")
    self.m_node_rightnodes = ccbNode:nodeForName("m_node_rightnodes")
    self.m_label_morale = ccbNode:labelTTFForName("m_label_morale")
    self.m_blabel_curlevelname = ccbNode:labelBMFontForName("m_blabel_curlevelname")
    self.m_label_mylevelname = ccbNode:labelTTFForName("m_label_mylevelname")
    self.m_node_battleinfoboard = ccbNode:nodeForName("m_node_battleinfoboard")
    self.m_node_battlemsgboard = ccbNode:nodeForName("m_node_battlemsgboard")
    self.m_spr_levelfightstate = ccbNode:spriteForName("m_spr_levelfightstate")
    self.m_node_canfighnode = ccbNode:nodeForName("m_node_canfighnode")

    local mAnimNode = game_util:createSortNode("sanjiao.swf.sam", 0, "sanjiao.plist");
    if mAnimNode then
        local sanjiaSize = self.m_node_pyramidnode:getContentSize()
        mAnimNode:setPosition(ccp(sanjiaSize.width * 0.5, sanjiaSize.height * 0.5))
        self.m_node_pyramidnode:addChild(mAnimNode)
        self.m_pyramidNode = mAnimNode
    end

    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    -- 重置按钮出米优先级 防止被阻止
    function resetBtnTouchPriority( ccbNode, btnName, touchPriority )
        if not ccbNode then return end
        local btn = ccbNode:controlButtonForName(btnName)
        if btn then
            btn:setTouchPriority( touchPriority )
        end
    end
    resetBtnTouchPriority(ccbNode, "m_btn_close", GLOBAL_TOUCH_PRIORITY - 6)
    resetBtnTouchPriority(ccbNode, "m_btn_goBackMyPos", GLOBAL_TOUCH_PRIORITY - 6)
    resetBtnTouchPriority(ccbNode, "m_btn_battleInfo", GLOBAL_TOUCH_PRIORITY - 6)

    -- 创建 购买次数 刷新挑战倒计时按钮
    local onBtnCilck = function ( event, target )
        onMainBtnClick(target, event)
    end
    local addOneBtn = function ( parent, tag, onBtnCilck, touchPriority )
        if not parent then return end
        local button = game_util:createCCControlButton("pb_alpha0_1X1.png","",onBtnCilck)
        button:setPreferredSize(parent:getContentSize())
        button:setAnchorPoint(ccp(0,0))
        button:setOpacity(0)
        parent:addChild(button, -1)
        button:setTag(tag)
        button:setTouchPriority(touchPriority)
        return button
    end
    local m_node_addtimes = ccbNode:nodeForName("m_node_addtimes")
    addOneBtn(m_node_addtimes, 401, onBtnCilck, GLOBAL_TOUCH_PRIORITY - 6)
    local m_node_addmorale = ccbNode:nodeForName("m_node_addmorale")
    addOneBtn(m_node_addmorale, 402, onBtnCilck, GLOBAL_TOUCH_PRIORITY - 6)

    -- 士气进度条
    local sprBg = CCSprite:createWithSpriteFrameName("ui_pyramid_n_jindu1.png")
    local fBg = CCSprite:createWithSpriteFrameName("ui_pyramid_n_jindu2.png")
    local tBg = CCSprite:create()

    local csl = CCProgressTimer:create(fBg)
    csl:setType(kCCProgressTimerTypeRadial)
    -- csl:setMaximumValue(100)
    -- csl:setMinimumValue(0)
    csl:setPercentage(0)
    local cslBoardSize = self.m_node_moraleboard:getContentSize()
    csl:setPosition(cslBoardSize.width * 0.5, cslBoardSize.height * 0.5)
    csl:setAnchorPoint(ccp(0.5,0.5))
    self.m_node_moraleboard:removeAllChildrenWithCleanup(true)
    self.m_node_moraleboard:addChild(csl)
    self.m_morale_progerssBar = csl

    sprBg:setPosition(cslBoardSize.width * 0.5, cslBoardSize.height * 0.5)
    self.m_node_moraleboard:addChild(sprBg, -1)

    -- 金字塔层数信息
    for i=1, 3 do
        resetBtnTouchPriority(ccbNode, "m_btn_otherinfo" .. tostring(i), GLOBAL_TOUCH_PRIORITY - 6)
    end

    self.m_label_levelpenums = {}
    for i=1, 3 do
        self.m_label_levelpenums["label" .. i] = ccbNode:labelTTFForName("m_label_levelpenum" .. tostring(i))
    end

    self.m_node_levelNodeboards = {}
    -- 第几层版
    for i=1, 3 do
        local tempNode = ccbNode:nodeForName("m_node_levelNodeboard" .. tostring(i))
        addOneBtn(tempNode, 600 + i, onBtnCilck, GLOBAL_TOUCH_PRIORITY - 6)
        local tempNode1 = ccbNode:nodeForName("m_node_pybtn" .. tostring(i))
        addOneBtn(tempNode1, 600 + i, onBtnCilck, GLOBAL_TOUCH_PRIORITY - 6)
    end

    self.m_blabellevel_names = {}
    for i=1, 3 do
        self.m_blabellevel_names["blabel" .. i] = ccbNode:labelBMFontForName("m_blabellevel_name" .. tostring(i))
    end
    self.m_node_leftinfos = {}
    self.m_node_rightinfos = {}
    for i=1, 3 do
        self.m_node_rightinfos["node" .. i] = ccbNode:labelBMFontForName("m_node_rightinfo" .. tostring(i))
        self.m_node_leftinfos["node" .. i] = ccbNode:labelBMFontForName("m_node_leftinfo" .. tostring(i))
    end

    pyramidMove = function( rhythm, xFlag, first, moveEnd, moveEndFun )
        if self.m_pyramidMoveFlag == false then
            return
        end
        if not first then
            if not moveEnd then
                local maxGroup = math.ceil(#self.m_levelInfo / 3)
                if not xFlag and self.m_curLevelGroup < maxGroup then
                    self.m_curLevelGroup = self.m_curLevelGroup + 1
                elseif xFlag and self.m_curLevelGroup > 1 then
                    self.m_curLevelGroup = self.m_curLevelGroup - 1
                elseif xFlag then
                    game_util:addMoveTips({text = " 这已经是最高层了 "})
                    return
                elseif not xFlag then
                    game_util:addMoveTips({text = " 这已经是最低层了 "})
                    return
                end
            else

            end
        end

        local fadeOutTime = 0.2
        local fadeInTime = 0.2
        -- local otherTime = math.max(rhythm - fadeInTime - fadeOutTime, 0)
        local otherTime = 0.2
        local animArr = CCArray:create();
        animArr:addObject(CCFadeOut:create(fadeOutTime));
        animArr:addObject(CCDelayTime:create(otherTime));
        animArr:addObject(CCFadeIn:create(fadeInTime));
        self.m_node_rightnodes:runAction(CCSequence:create(animArr));

        local animArr = CCArray:create();
        animArr:addObject(CCFadeOut:create(fadeOutTime));
        animArr:addObject(CCDelayTime:create(otherTime));
        animArr:addObject(CCFadeIn:create(fadeInTime));
        self.m_node_leftnodes:runAction(CCSequence:create(animArr));

        self:refreshUi()

        self.m_pyramidNode:setFlipX(xFlag)
        local function onAnimSectionEnd(animNode, theId,theLabelName)
            self.m_pyramidMoveFlag = true
        end
        if self.m_pyramidNode then
            self.m_pyramidMoveFlag = false
            self.m_pyramidNode:registerScriptTapHandler(onAnimSectionEnd)
            self.m_pyramidNode:playSection("impact");
            self.m_pyramidNode:setRhythm(rhythm);
        end
    end

    pyramidMove(1, false, true)
    
    local beganPos = nil
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        local realPos = self.m_node_pyramidnode:getParent():convertToNodeSpace(ccp(x,y));
        local flag = self.m_node_pyramidnode:boundingBox():containsPoint(realPos) 
        local realPosList = self.m_node_playersboard:getParent():convertToNodeSpace(ccp(x,y));
        local flagList = self.m_node_playersboard:boundingBox():containsPoint(realPosList) 
        -- print(eventType, x, y, "eventType, x, y   =====  ")
        -- cclog2(flag, "eventType, x, y   =====  ")
        if eventType == "began" and flag then 
            beganPos = {x = x, y = y}
            return true;  
        elseif eventType == "began" and not flagList then
            return true;
        elseif eventType == "moved" and flag then
            if not beganPos then
                beganPos = {x = x, y = y}
            -- elseif beganPos and flag == false then
            end
        elseif eventType == "ended" then
            -- cclog2(beganPos, "beganPos   ====   ")
            local endPos = {x = x, y = y}
            if beganPos then
                -- cclog2(endPos.x - beganPos.x, "endPos.x - beganPos.x   =====   ")
                if endPos.x - beganPos.x < -15 then
                    pyramidMove(1, false)
                elseif endPos.x - beganPos.x > 15 then
                    pyramidMove(1, true)
                end
                beganPos = nil
            end
        end

    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建金字塔层数列表列表
]]
function game_pyramid_tower_scene.creatLevelTableView( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")

    end
    local showData = self.m_levelInfo
    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 5;
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
            ccbNode:openCCBFile("ccb/ui_pyramid_level_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.55, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local itemData = showData[index + 1]
                local m_btn_info = ccbNode:controlButtonForName("m_btn_info")   -- 查看信息按钮
                local m_blabel_levelname = ccbNode:labelBMFontForName("m_blabel_levelname")  -- 本层名字
                local m_label_playernum = ccbNode:labelTTFForName("m_label_playernum")  -- 本层人数
                local m_label_lastplace = ccbNode:labelTTFForName("m_label_lastplace")  -- 剩余位置
                local m_scale9_front = ccbNode:nodeForName("m_scale9_front")  -- 选中效果
                local m_scale9_normal = ccbNode:nodeForName("m_scale9_normal") -- cell 底板

                if index + 1 == self.m_cur_select_level then
                    self.m_last_select_levelCell = cell
                    self:refreshOneLevelCellState( cell , true)
                else
                    self:refreshOneLevelCellState( cell , false)
                end



                local level = self:convertNum2Chinese( index + 1)
                local levelName = "第" .. tostring(level) .. "层"

                m_blabel_levelname:setString(levelName)


                local levelData = itemData.levelData
                local cur_player_num = itemData.cur_player_num
                local player_num = levelData.player_num 
                local msg = tostring(cur_player_num) .. "/" .. player_num
                m_label_playernum:setString( msg )



                if m_btn_info then m_btn_info:setTag(index) end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            cclog2("click table cell index === " .. tostring(index))
            if index + 1 ~= self.m_cur_select_level then
                self:refreshOneLevelCellState(self.m_last_select_levelCell, false)
                self.m_last_select_levelCell = cell
                self:refreshOneLevelCellState( cell , true)
                self.m_cur_select_level = index + 1
            end
        end
    end
    return TableViewHelper:create(params)
end

--[[
    刷新一个 level cell 的选中 非选中状态
]]
function game_pyramid_tower_scene.refreshOneLevelCellState( self, cell, isSelect )
    if not cell then return end
    local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
    if ccbNode then
        local m_scale9_front = ccbNode:nodeForName("m_scale9_front")  -- 选中效果
        if isSelect then
            m_scale9_front:setVisible(true)
        else
            m_scale9_front:setVisible(false)
        end
    end 
end

--[[
    定位自己所在的层
]]
function game_pyramid_tower_scene.refreshLevelCellPos( self )
    if not self.m_level_tableView then return end

    local bg_height = self.m_level_tableView:getViewSize().height
    local view_height = self.m_level_tableView:getContentSize().height
    if self.m_cur_select_level > 3  then 
        local offy = (self.m_cur_select_level + 1) / 3 * bg_height - view_height
        self.m_level_tableView:setContentOffset(ccp(0, math.min(offy, 0 ) ), true)
    end
end

--[[
    数字转换成中文数字
]]
function game_pyramid_tower_scene.convertNum2Chinese( self, num )
    if num == 0 then return "零" end     -- 直接返回
    local chineseCodes = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
    local chineseUnit = {"", "十", "百", "千", "万", "十万", "百万", "千万", "亿", "十亿", "百亿", "千亿", "万亿"}
    local strnum = tostring(num)
    local conv = function( pos, cur )
        if cur == "0" then return "零" end
        return chineseCodes[tonumber(cur)] .. chineseUnit[tonumber(pos)]
    end

    local fore_word  = ""
    local perstrnum = strnum
    for i=1, string.len(strnum) do
         local cur = string.sub(perstrnum, -1, -1)
         perstrnum = string.sub(perstrnum, 1, -2)
         if cur then
            local oneWord = conv(i , cur )
            if oneWord ~= "零" or fore_word ~= "" then  -- 最后一位不会为零
                fore_word = oneWord .. fore_word 
            end
         end
         srtt = string.gsub(fore_word, "零零", "零")  -- 两个零 替换成一个零
    end
    if num > 9 and num < 20 then
        srtt = string.gsub(fore_word, "一", "", 1)  -- 两个零 替换成一个零
    end

    return srtt
end


--[[--
    创建金字塔玩家列表列表
]]
function game_pyramid_tower_scene.creatPlayersTableView( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    local showData = self.m_curFloorPlayerData or {}
    -- cclog2(showData, "showData    ===   ")
    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 2;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
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
            ccbNode:openCCBFile("ccb/ui_pyramid_player_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 

                local itemData = showData[index + 1]
                local m_node_playerinfo1 = ccbNode:nodeForName("m_node_playerinfo1")
                local m_node_playerinfo2 = ccbNode:nodeForName("m_node_playerinfo2")
                local m_node_quicksign = ccbNode:nodeForName("m_node_quicksign")
                local m_node_chousha = ccbNode:nodeForName("m_node_chousha")  -- 仇杀标记
                local m_node_nameboard = ccbNode:nodeForName("m_node_nameboard")
                local m_label_playername = ccbNode:labelTTFForName("m_label_playername")  -- 玩家名字
                local m_blabel_place = ccbNode:labelBMFontForName("m_blabel_place")  -- 位置
                local m_node_lucksign = ccbNode:nodeForName("m_node_lucksign")  -- 幸运位置标记
                local m_node_playericon1 = ccbNode:nodeForName("m_node_playericon1")  -- 玩家头像板
                local m_node_playericon2 = ccbNode:nodeForName("m_node_playericon2")  -- 玩家头像板
                local m_node_playersign = ccbNode:nodeForName("m_node_playersign")
                local m_sprite_palyerchouren = ccbNode:spriteForName("m_sprite_palyerchouren")
                local m_sprite_palyernpc = ccbNode:spriteForName("m_sprite_palyernpc")
                local m_node_my_place = ccbNode:nodeForName("m_node_my_place")  -- 我的位置
                m_sprite_palyernpc:setVisible(true)
                m_sprite_palyerchouren:setVisible(false)
                m_node_playersign:setVisible(false)
                m_node_lucksign:setVisible(false)
                m_node_playerinfo1:setVisible(false)
                m_node_playerinfo2:setVisible(false)
                m_node_quicksign:setVisible(false)

                -- 位置
                local pos = itemData.pos
                m_blabel_place:setString(tostring(pos))


                local playerData = itemData.data
                -- 玩家标记
                local uid = playerData.uid
                if string.find(tostring(uid), "robot") then
                    m_node_playersign:setVisible(true)
                    m_sprite_palyernpc:setVisible(true)
                elseif playerData.chouren then
                    m_node_playersign:setVisible(true)
                    m_sprite_palyerchouren:setVisible(true)
                else
                    m_node_playersign:setVisible(false)
                end
                if tostring(uid) == game_data:getUserStatusDataByKey("uid") then  -- 我的位置标记
                    m_node_my_place:setVisible(true)
                    m_node_nameboard:setVisible(false)
                else
                    m_node_my_place:setVisible(false)
                    m_node_nameboard:setVisible(true)
                end


                local playerIconBoard = nil
                -- 显示
                if itemData.key == "quick" then
                    m_node_quicksign:setVisible(true)
                    m_blabel_place:setVisible(false)
                    m_node_playersign:setVisible(false)
                    m_node_nameboard:setVisible(false)
                elseif itemData.key == "luck" then
                    m_node_lucksign:setVisible(true)
                    m_node_playerinfo1:setVisible(true)
                    playerIconBoard = m_node_playericon1
                elseif itemData.key == "normal" then
                    m_node_playerinfo2:setVisible(true)
                    playerIconBoard = m_node_playericon2
                end


                if playerIconBoard then
                    playerIconBoard:removeAllChildrenWithCleanup(true)
                    if playerData then
                        local iconBoardSize = playerIconBoard:getContentSize()
                        local role =  playerData.role or math.random(1, 5) 
                        local name = playerData.name or ""
                        local pos = pla
                        m_label_playername:setString(name)
                        local tempNode = game_util:createRoleBigImgHalf(role)
                        tempNode:setAnchorPoint(ccp(0.5,0))
                        tempNode:setPositionX(iconBoardSize.width * 0.5)
                        tempNode:setScale(0.5) 
                        playerIconBoard:addChild(tempNode, 1, 998)
                    end
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            -- cclog2("click table cell index === " .. tostring(index))
            local itemData = showData[index + 1]
            if itemData.key == "quick" then


            end 

            -- 这个位置是自己
            local myUid = game_data:getUserStatusDataByKey("uid")
            if tostring(itemData.data.uid) == tostring(myUid) then
                game_util:addMoveTips("不能再抢占自己的位置了")
                return
            end

            local pyramidInfo = {}
            pyramidInfo.lookFloor = self.m_curSelectLevel
            pyramidInfo.myFloor = self.m_gameData.floor

            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_small_playerinfo_pop", {gameData = gameData, playerInfo = itemData, pyramidInfo = pyramidInfo })
            end
            local params = {floor = pyramidInfo.lookFloor, pos = itemData.pos, uid = itemData.data.uid}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_user_info"), http_request_method.GET, params,"pyramid_user_info")
        end
    end
    local tableView = TableViewHelper:create(params)
    if itemCount <= 2 then
        tableView:setMoveFlag(false)
        tableView:setScrollBarVisible(false)
    end
    return tableView
end

--[[
    刷新层数信息
]]
function game_pyramid_tower_scene.refreLevelInfo( self )
    -- 更新人数信息
    local group = self.m_curLevelGroup 
    local startlevel = 3 * (group - 1) 
    for i=1, 3 do
        local level = startlevel + i
        cclog2(level, "level   ===    ")
        local levelData = self.m_levelInfo[ level ] 
        local label =  self.m_label_levelpenums["label" .. tostring(i)]
        local blabel =  self.m_blabellevel_names["blabel" .. tostring(i)]
        local leftNode = self.m_node_leftinfos["node" .. tostring(i)]
        local rightNode = self.m_node_rightinfos["node" .. tostring(i)]
        if levelData then
            if label then
                local  curNum = levelData.cur_player_num
                local maxNum = levelData.levelData.player_num
                label:setString(tostring(curNum) .. "/" .. tostring(maxNum))
            end
            if blabel then
                local msg = self:convertNum2Chinese(level)
                blabel:setString(tostring("第" .. tostring(msg) .. "层"))

                if level == self.m_curSelectLevel then
                    blabel:setFntFile("pyramid_orign_fnt.fnt")
                else
                    blabel:setFntFile("pyramid_blue_fnt.fnt")
                end
            end
            if rightNode then
                rightNode:setVisible(true)
            end
            if leftNode then
                leftNode:setVisible(true)
            end
        else
            if rightNode then
                rightNode:setVisible(false)
            end
            if leftNode then
                leftNode:setVisible(false)
            end
        end
    end
end


--[[--
    刷新ui
]]
function game_pyramid_tower_scene.refreshUi( self )
    -- -- 金字塔层数列表
    --  self.m_node_levellistboard:removeAllChildrenWithCleanup(true)
    --  self.m_level_tableView = nil
    --  local levelTabelView = self:creatLevelTableView( self.m_node_levellistboard:getContentSize() )
    --  if levelTabelView then
    --     self.m_node_levellistboard:addChild(levelTabelView)
    --     self.m_level_tableView = levelTabelView
    --  end

    -- 当前层数
    local levelName = self:convertNum2Chinese( self.m_curSelectLevel )
    local levelInfo = "第" .. tostring(levelName) .. "层"
    self.m_blabel_curlevelname:setString(levelInfo)
    -- 当前层数状态
    local stateSpriteFrameName = {"ui_pyramid_n_wodeceng.png", "ui_pyramid_n_kegongda.png", "ui_pyramid_n_bukegongda.png"}
    local stateSprName = nil
    local levelState = {"我所在的层", "可攻打", "不可攻打"}
    local myLevel = self.m_gameData.floor
    if myLevel == 0 then myLevel = 21 end
    if self.m_curSelectLevel + 1 < myLevel then
            stateSprName = stateSpriteFrameName[3]
    elseif self.m_curSelectLevel == myLevel then
        stateSprName = stateSpriteFrameName[1]
    else 
        stateSprName = stateSpriteFrameName[2]
    end

    local outEndFun = function ( )
        game_util:setSpriteDisplayBySpriteFrameName(self.m_spr_levelfightstate, stateSprName)
        self.m_spr_levelfightstate:setOpacity(0)
    end

    local scale_time = 0.2

    local animArr = CCArray:create();
    animArr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(scale_time),CCScaleTo:create(scale_time,2, 1.5)));
    animArr:addObject(CCDelayTime:create(scale_time));
    animArr:addObject(CCCallFuncN:create(outEndFun));
    animArr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(scale_time),CCScaleTo:create(scale_time,1, 1)));
    self.m_spr_levelfightstate:stopAllActions()
    self.m_spr_levelfightstate:runAction(CCSequence:create(animArr))

    -- 我所在层数名字
    local msg = ""
    if self.m_gameData.floor == 0 then
        msg = "未进入金字塔任何层"
    else
        local levelName = self:convertNum2Chinese( self.m_gameData.floor )
        msg = "第" .. tostring(levelName) .. "层"
    end
    self.m_label_mylevelname:setString(msg)

     


     -- 士气 
    local morale = self.m_gameData.morale or 0
    -- self.m_morale_progerssBar:setValue(morale)
    self.m_morale_progerssBar:setPercentage(morale)
    self.m_label_morale:setString(tostring(morale) .. "%")

    -- 挑战信息
    local challenge_times = self.m_pyramidData.challenge_times or 0
    local lastTimes = self.m_gameData.challenge_times
    local  msg = tostring(lastTimes) .. "/" .. tostring(challenge_times)
    self.m_label_lasttimes:setString(tostring(msg))

    -- 普通玩家列表
     self.m_node_playersboard:removeAllChildrenWithCleanup(true)
     local playersTabelView = self:creatPlayersTableView( self.m_node_playersboard:getContentSize() )
     if playersTabelView then
        self.m_node_playersboard:addChild(playersTabelView)
        local posY = playersTabelView:getContentOffset().y
        playersTabelView:setContentOffset(ccp(0 , -200), false)
        playersTabelView:setContentOffset(ccp(0 , posY), true)
     end


    self:refreLevelInfo()
end

--[[
    格式化数据
]]
function game_pyramid_tower_scene.formatData( self )
    self.m_levelInfo = {}
    local pyramid_level_cfg = getConfig(game_config_field.pyramid_level)
    local count = pyramid_level_cfg:getNodeCount()
    local floor_real_player_num = self.m_gameData.floor_real_player_num or {}
    for i=1,count do
        local oneLevel = pyramid_level_cfg:getNodeWithKey(tostring(i))
        if oneLevel then
            local levelData = json.decode(oneLevel:getFormatBuffer()) or {}
            local cur_player_num = floor_real_player_num[tostring(i)] or 0
            levelData.player_num = levelData.player_num or 1
            levelData.player_num = math.max(levelData.player_num, cur_player_num)
            table.insert(self.m_levelInfo, {levelData = levelData, cur_player_num = cur_player_num })
        end
    end
    local my_level = 5
    self.m_cur_select_level = my_level


    self.m_pyramidData = {}
    local pyramid_cfg = getConfig(game_config_field.pyramid)
    local nodeCount = pyramid_cfg and pyramid_cfg:getNodeCount() or 1
    local tempCfg = pyramid_cfg and pyramid_cfg:getNodeAt(nodeCount - 1 )
    self.m_pyramidData = tempCfg and json.decode(tempCfg:getFormatBuffer()) or {}

    self:refreshData(nil)

end

function game_pyramid_tower_scene.refreshData( self, gameData )
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

    if tempData.pos_info then
        self.m_gameData.pos_info = tempData.pos_info
    end

    local luckPos = self.m_gameData.lucky_situation or nil
    -- 选中层玩家信息
    local norPlayer = {}
    local luckPlayer = {}
    local quickPlayer = {}
    local myInfo = {}
    local myUid = game_data:getUserStatusDataByKey("uid")
    for i,v in pairs(self.m_gameData.pos_info) do
        if v.shortcut == 1 then  -- 快速通道
            table.insert(quickPlayer, {key = "quick", data = v, pos = i})
        elseif tostring(i) == tostring(luckPos) then
            table.insert(luckPlayer, 1, {key = "luck", data = v, pos = i})
        elseif tostring(v.uid) == tostring(myUid) then
            table.insert(myInfo, 1, {key = "normal", data = v, pos = i})
        else
            table.insert(norPlayer, {key = "normal", pos = i, data = v})
        end
    end

    local sortFun = function ( data1, data2 )
        return tonumber(data1.pos) < tonumber(data2.pos)
    end

    -- table.sort(norPlayer, sortFun)  -- 普通位置不排序
    table.sort(quickPlayer, sortFun)
    table.sort(luckPlayer, sortFun)
    table.sort(myInfo, sortFun)


    self.m_curFloorPlayerData = {}
    local insertTableFun = function ( appTable )
        for i,v in ipairs(appTable or {}) do
            table.insert(self.m_curFloorPlayerData, v)
        end
    end
    insertTableFun(luckPlayer)
    insertTableFun(quickPlayer)
    insertTableFun(myInfo)
    insertTableFun(norPlayer)

end


--[[--
    初始化
]]
function game_pyramid_tower_scene.init(self,t_params)
    t_params = t_params or {}
    self.m_screenShoot = t_params.screenShoot

    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self.m_gameData.floor = self.m_gameData.floor
    self.m_curSelectLevel = self.m_gameData.floor
    self.m_curLevelGroup  = math.ceil(self.m_curSelectLevel / 3) 
    cclog2(self.m_curLevelGroup, "self.m_curLevelGroup   ====   ")
    self:formatData()
end
--[[--
    创建ui入口并初始化数据
]]
function game_pyramid_tower_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    self:refreshLevelCellPos()
    return scene;
end

return game_pyramid_tower_scene