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

    m_last_select_levelCell = nil,

    m_level_tableView = nil,

    m_morale_progerssBar = nil,
    m_node_pyramidnode = nil,
    m_curSelectLevel = nil,

    m_curFloorPlayerData = nil,
    m_label_morale = nil,
    m_cur_foor = nil,
    m_blabel_curlevelname = nil,
    m_label_mylevelname = nil,
    m_node_battleinfoboard = nil,  -- 战报信息动作板
    m_node_battlemsgboard = nil, -- msg信息板
    m_spr_levelfightstate = nil,  -- 本层战斗状态
    m_battleData = nil,
    m_scroll_msgBoard = nil,
    m_node_broadcastboard = nil,
    m_willShowData = nil,
    m_curSelPos = nil,
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
    self.m_pyramidData = nil;
    self.m_last_select_levelCell = nil;
    self.m_level_tableView = nil;
    self.m_morale_progerssBar = nil;
    self.m_node_pyramidnode = nil;
    self.m_curSelectLevel = nil;
    self.m_curFloorPlayerData = nil;
    self.m_label_morale = nil;
    self.m_cur_foor = nil;
    self.m_blabel_curlevelname = nil;
    self.m_label_mylevelname = nil;
    self.m_node_battleinfoboard = nil;  
    self.m_node_battlemsgboard = nil;
    self.m_spr_levelfightstate = nil;
    self.m_battleData = nil;
    self.m_scroll_msgBoard = nil;
    self.m_node_broadcastboard = nil;
    self.m_willShowData = nil;
    self.m_curSelPos = nil;
end
--[[--
    返回
]]
function game_pyramid_tower_scene.back(self,backType)

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

        elseif btnTag == 401 then
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
                if gameData then
                    game_util:addMoveTips({text = string_helper.game_pyramid_tower_scene.cost_success})
                    self:refreshData(gameData)
                    self:refreMyInfo()
                end
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
                text = string_helper.game_pyramid_tower_scene.cost .. payValue .. string_helper.game_pyramid_tower_scene.diamond_side,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-5,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 402 then
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
                game_util:addMoveTips({text = string_helper.game_pyramid_tower_scene.energize_success})
                self:refreshData(gameData)
                self:refreMyInfo()
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
                text = string_helper.game_pyramid_tower_scene.cost .. payValue .. string_helper.game_pyramid_tower_scene.diamond_energize,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-5,
            }
            game_util:openAlertView(t_params)  
        elseif btnTag == 801 then
            -- local myFloor = self.m_gameData.floor 
            -- if myFloor == 0 then 
            --     myFloor = 20 
            -- end
            -- self.m_curSelectLevel = myFloor
            -- self:refreshUi()
            -- self:refreshLevelCellPos()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_pyramid_tower_scene", {gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, nil,"pyramid_go_fight")
        elseif btnTag == 802 then  -- 查看战报
            -- game_scene:addPop("ui_pyramid_battleover_pop", {gameData = self.m_battleData})
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_pyramid_battleinfo_pop", {gameData = gameData, enterType = "game_pyramid_tower_scene"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_battle_log"), http_request_method.GET, nil,"pyramid_battle_log")
        elseif btnTag == 1001 then   -- 快速爬塔


            local function responseMethod(tag,gameData)
                if not gameData then return end
                local data = gameData:getNodeWithKey("data") or nil
                if data then
                    -- game_util:addMoveTips({text = "你秒杀了对手~~~~~~~~~"})
                    self.m_curSelectLevel = data:getNodeWithKey("upper_floor") and data:getNodeWithKey("upper_floor"):toInt() or self.m_curSelectLevel
                    self:refreshData( gameData )
                    -- self:refreshLevelContent()
                    self:refreshUi()
                    self:refreshLevelCellPos()
                end
            end

            local pyramid_cfg = getConfig(game_config_field.pyramid)
            -- cclog2(pyramid_cfg, "pyramid_cfg   ===   ")
            if not pyramid_cfg then return end
            local tempCount = pyramid_cfg:getNodeCount()
            local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
            local addQuickCostCfg = tempCfg and tempCfg:getNodeWithKey("pay_sweep")
            if not addQuickCostCfg then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_quick_floor"), http_request_method.GET, nil,"pyramid_quick_floor")
                return
            end

            local payValue = 50 
            if addQuickCostCfg:nodeType() == util_json.EArray then
                local price_index = math.min(self.m_gameData.buy_quick_times + 1, addQuickCostCfg:getNodeCount())
                local priceCfg = addQuickCostCfg:getNodeAt(math.max(0, price_index - 1))
                if not priceCfg then return end
                payValue = priceCfg:toInt()
            elseif addQuickCostCfg:nodeType() == util_json.ENumber then
                payValue = addQuickCostCfg:toInt()
            end


            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_quick_floor"), http_request_method.GET, nil,"pyramid_quick_floor")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = string_helper.game_pyramid_tower_scene.cost .. payValue .. string_helper.game_pyramid_tower_scene.diamond_speed,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-5,
            }
            game_util:openAlertView(t_params)  

        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_tower.ccbi");
    self.m_node_levellistboard = ccbNode:nodeForName("m_node_levellistboard")
    self.m_node_playersboard = ccbNode:nodeForName("m_node_playersboard")
    self.m_label_lasttimes = ccbNode:labelTTFForName("m_label_lasttimes")
    self.m_node_moraleboard = ccbNode:nodeForName("m_node_moraleboard")
    self.m_node_pyramidnode = ccbNode:nodeForName("m_node_pyramidnode")
    self.m_label_morale = ccbNode:labelTTFForName("m_label_morale")
    self.m_blabel_curlevelname = ccbNode:labelBMFontForName("m_blabel_curlevelname")
    self.m_label_mylevelname = ccbNode:labelTTFForName("m_label_mylevelname")
    self.m_node_battleinfoboard = ccbNode:nodeForName("m_node_battleinfoboard")
    self.m_node_battlemsgboard = ccbNode:nodeForName("m_node_battlemsgboard")
    self.m_spr_levelfightstate = ccbNode:spriteForName("m_spr_levelfightstate")
    self.m_scroll_msgBoard = ccbNode:scrollViewForName("m_scroll_msgBoard")
    self.m_node_broadcastboard = ccbNode:nodeForName("m_node_broadcastboard")
    if self.m_node_broadcastboard then self.m_node_broadcastboard:setVisible(false) end

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

    resetBtnTouchPriority(ccbNode, "m_btn_quick_floor", GLOBAL_TOUCH_PRIORITY - 6)
    local m_btn_quick_floor = ccbNode:controlButtonForName("m_btn_quick_floor")

    if m_btn_quick_floor and self.m_gameData.can_quick_floor == true then
        m_btn_quick_floor:setVisible(true)
    elseif m_btn_quick_floor then
        m_btn_quick_floor:setVisible(false)
    end

    -- 创建 购买次数 刷
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
    csl:setPercentage(0)
    local cslBoardSize = self.m_node_moraleboard:getContentSize()
    csl:setPosition(cslBoardSize.width * 0.5, cslBoardSize.height * 0.5)
    csl:setAnchorPoint(ccp(0.5,0.5))
    self.m_node_moraleboard:removeAllChildrenWithCleanup(true)
    self.m_node_moraleboard:addChild(csl)
    self.m_morale_progerssBar = csl
    sprBg:setPosition(cslBoardSize.width * 0.5, cslBoardSize.height * 0.5)
    self.m_node_moraleboard:addChild(sprBg, -1)

    local beganPos = nil
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        local realPosList = self.m_node_playersboard:getParent():convertToNodeSpace(ccp(x,y));
        local flagList = self.m_node_playersboard:boundingBox():containsPoint(realPosList) 

        local realPosList = self.m_node_levellistboard:getParent():convertToNodeSpace(ccp(x,y));
        local flagLevelList = self.m_node_levellistboard:boundingBox():containsPoint(realPosList) 
        if eventType == "began" and not flagList and not flagLevelList then
            return true;
        end

    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 6,true);
    self.m_root_layer:setTouchEnabled(true);


    if self.m_battleData and self.m_battleData.is_win == true then
        local perFloor = self.m_battleData.before_floor or 0
        local curFloor = self.m_battleData.battle_floor or 0
        if perFloor == 0 then perFloor = 21 end
        if curFloor == 0 then curFloor = 21 end
        if curFloor < perFloor then
            game_scene:addPop("ui_pyramid_battleover_pop", {gameData = self.m_battleData})
        end
    end
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
        local showLevel = btnTag + 1
        game_scene:addPop("ui_pyramid_rewards_pop", {showLevel = showLevel})
    end
    local showData = self.m_levelInfo
    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
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
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local itemData = showData[index + 1]
                local m_btn_info = ccbNode:controlButtonForName("m_btn_lookreward")   -- 查看信息按钮
                local m_blabel_levelname = ccbNode:labelBMFontForName("m_blabel_levelname")  -- 本层名字
                local m_blabel_playernum = ccbNode:labelBMFontForName("m_blabel_playernum")  -- 本层人数
                local m_spr_levelsign = ccbNode:spriteForName("m_spr_levelsign")    -- 本层标记 敌人/悬赏 人所在层数标志
                local m_node_lucksign = ccbNode:nodeForName("m_node_lucksign")  -- 幸运位层数标志
                local m_spr_levelfightstate = ccbNode:spriteForName("m_spr_levelfightstate")  -- 层数可供打标志
                local m_spr_board = ccbNode:nodeForName("m_spr_board")
                local m_node_levelsign = ccbNode:nodeForName("m_node_levelsign")
                m_node_levelsign:setVisible(false)
                m_node_lucksign:setVisible(false)
                -- cell选中 分选中底图效果
                if index + 1 == self.m_curSelectLevel then
                    self.m_last_select_levelCell = cell
                    self:refreshOneLevelCellState( cell , true, index)
                else
                    self:refreshOneLevelCellState( cell , false, index)
                end
                -- 层数
                local level = game_util:convertNum2Chinese( index + 1)
                local levelName = string_helper.game_pyramid_tower_scene.di .. tostring(level) .. string_helper.game_pyramid_tower_scene.cen
                m_blabel_levelname:setString(levelName)
                if self.m_gameData.floor == index + 1 then
                    m_blabel_levelname:setFntFile("pyramid_yellow_fnt.fnt")
                else
                    m_blabel_levelname:setFntFile("pyramid_blue_fnt.fnt")
                end
                -- 本层玩家人数/本层最大人数
                local levelData = itemData.levelData
                local cur_player_num = itemData.cur_player_num
                local player_num = levelData.player_num 
                local msg = tostring(cur_player_num) .. "/" .. player_num
                m_blabel_playernum:setString( msg )
                -- 查看本层奖励信息按钮
                if m_btn_info then 
                    m_btn_info:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                    m_btn_info:setTag(index) 
                    -- m_btn_info:setOpacity(150)
                    -- m_btn_info:setScale(0.75)
                end
                local enemyList = self.m_gameData.floor_enemy and self.m_gameData.floor_enemy[tostring(index + 1)] or {enemy_list = {}}
                local level_wanted_list = self.m_gameData.floor_extra_people and self.m_gameData.floor_extra_people[tostring(index + 1)] or {}

                -- 仇人位置显示
                if level_wanted_list.extra_people and #level_wanted_list.extra_people > 0 then
                    m_node_levelsign:setVisible(true)
                    game_util:setSpriteDisplayBySpriteFrameName(m_spr_levelsign, "ui_pyramid_n_tongji.png")
                elseif enemyList.enemy_list  and #enemyList.enemy_list > 0 then
                    m_node_levelsign:setVisible(true)
                    game_util:setSpriteDisplayBySpriteFrameName(m_spr_levelsign, "ui_pyramid_chousha.png")
                else
                    m_node_levelsign:setVisible(false)
                end
                -- 幸运层数显示
                if self.m_gameData.lucky_floor == index + 1 then
                    m_node_lucksign:setVisible(true)
                    m_node_levelsign:setVisible(false)
                end

                -- 可供打标志
                -- 当前层数状态
                local stateSpriteFrameName = {"ui_pyramid_n_mypos2.png", "ui_pyramid_n_kegongda.png", "ui_pyramid_n_bukegongda.png"}
                local stateSprName = nil
                local levelState = string_helper.game_pyramid_tower_scene.levelState
                local myLevel = self.m_gameData.floor
                if myLevel == 0 then myLevel = 21 end
                if index + 1 < myLevel - 1 then
                    stateSprName = stateSpriteFrameName[3]
                    m_spr_board:setColor(ccc3(125,125,125))
                elseif index + 1  == myLevel then
                    stateSprName = stateSpriteFrameName[1]
                    m_spr_board:setColor(ccc3(255,255,255))
                else 
                    stateSprName = stateSpriteFrameName[2]
                    m_spr_board:setColor(ccc3(255,255,255))
                end
                game_util:setSpriteDisplayBySpriteFrameName(m_spr_levelfightstate, stateSprName)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            cclog2("click table cell index === " .. tostring(index))
            if index + 1 ~= self.m_curSelectLevel then
                self:refreshOneLevelCellState(self.m_last_select_levelCell, false, index)
                self.m_last_select_levelCell = cell
                self:refreshOneLevelCellState( cell , true, index)
                self.m_curSelectLevel = index + 1

                local level = self.m_curSelectLevel
                local function responseMethod(tag,gameData)
                    self.m_curSelectLevel = level
                    self:refreshData(gameData)
                    self:refreshLevelContent()
                end
                local params = {}
                params.floor = level
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, params,"pyramid_go_fight")
            end
        end
    end
    local tableView = TableViewHelper:create(params)
    if tableView then
        tableView:setScrollBarVisible(false);
    end
    return tableView
end

--[[
    刷新一个 level cell 的选中 非选中状态
]]
function game_pyramid_tower_scene.refreshOneLevelCellState( self, cell, isSelect , index)
    if not cell then return end
    local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
    if ccbNode then
        local m_spr_board = ccbNode:spriteForName("m_spr_board")  -- 选中效果

        if isSelect then
            -- m_scale9_front:setVisible(true)
            -- game_util:setSpriteDisplayBySpriteFrameName(m_spr_board, "ui_pyramid_n_BIANSE.png")
            -- m_spr_board:setColor(ccc3(255,255,255))

            local selSpr = CCSprite:createWithSpriteFrameName("ui_pyramid_n_BIANSE.png")
            if selSpr then
                selSpr:setAnchorPoint(ccp(0,0))
                m_spr_board:addChild( selSpr )
            end

        else
            -- m_scale9_front:setVisible(false)
            -- game_util:setSpriteDisplayBySpriteFrameName(m_spr_board, "ui_pyramid_n_BANZI.png")
            m_spr_board:removeAllChildrenWithCleanup(true)
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
    if self.m_curSelectLevel > 4  then 
        local offy = (self.m_curSelectLevel + 1) / 4 * bg_height - view_height
        self.m_level_tableView:setContentOffset(ccp(0, math.min(offy, 0 ) ), true)
    end

end

--[[--
    创建金字塔玩家列表列表
]]
function game_pyramid_tower_scene.creatPlayersTableView( self, viewBoard )
    local viewSize = viewBoard:getContentSize()
    local leftArrow = CCSprite:createWithSpriteFrameName("pb_jiantou.png")
    leftArrow:setFlipX(true)
    leftArrow:setPosition(ccp(-4,viewSize.height*0.5));
    viewBoard:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("pb_jiantou.png")
    rightArrow:setPosition(ccp(viewSize.width + 1,viewSize.height*0.5));
    viewBoard:addChild(rightArrow)
    leftArrow:setVisible(false)
    rightArrow:setVisible(false)

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    local showData = self.m_curFloorPlayerData or {}
    -- cclog2(showData, "showData    ===   ")

    local trueViewSize = CCSizeMake(viewSize.width -5 , viewSize.height)

    local itemCount = #showData 
    local params = {};
    params.viewSize = trueViewSize ;
    params.row = 3;
    params.column = 3;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 2;
    local itemSize = CCSizeMake(trueViewSize.width / params.column, trueViewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.showPoint = false
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
                if index < params.column then
                    ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.55));
                else
                    ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
                end
                local itemData = showData[index + 1]
                local m_node_playerinfo1 = ccbNode:nodeForName("m_node_playerinfo1")
                local m_node_playerinfo2 = ccbNode:nodeForName("m_node_playerinfo2")
                local m_node_playerinfo3 = ccbNode:nodeForName("m_node_playerinfo3")
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
                local m_node_rewardcountdown = ccbNode:nodeForName("m_node_rewardcountdown")
                local m_node_guanxiao = ccbNode:nodeForName("m_node_guanxiao")
                local m_sprite_light = ccbNode:spriteForName("m_sprite_light")
                if m_sprite_light then m_sprite_light:setVisible(false) end
                m_node_guanxiao:setVisible(false)
                m_sprite_palyernpc:setVisible(true)
                m_sprite_palyerchouren:setVisible(false)
                m_node_playersign:setVisible(false)
                m_node_lucksign:setVisible(false)
                m_node_playerinfo1:setVisible(false)
                m_node_playerinfo2:setVisible(false)
                m_node_quicksign:setVisible(false)
                m_node_playerinfo3:setVisible(false)
                m_blabel_place:setVisible(false)
                m_node_my_place:setVisible(false)
                m_node_nameboard:setVisible(false)

                if itemData then
                    -- 位置
                    local pos = itemData.pos
                    m_blabel_place:setString(tostring(pos))
                    m_blabel_place:setVisible(true)

                    local playerData = itemData.data
                    -- 玩家标记
                    local uid = playerData.uid
                    if playerData.is_Wanted == true then  -- 悬赏的玩家
                        m_node_playersign:setVisible(true)
                        m_sprite_palyerchouren:setVisible(true)
                        m_sprite_palyernpc:setVisible(false)
                        game_util:setSpriteDisplayBySpriteFrameName(m_sprite_palyerchouren, "ui_pyramid_n_tongji.png")

                        if m_sprite_light then
                            -- 光效
                            m_sprite_light:stopAllActions()
                            m_node_guanxiao:setVisible(true)
                            m_sprite_light:setVisible(true)

                            local animArr = CCArray:create();
                            animArr:addObject(CCFadeOut:create(1));
                            animArr:addObject(CCFadeIn:create(1));
                            m_sprite_light:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
                        end
                    elseif string.find(tostring(uid), "robot") then
                        m_node_playersign:setVisible(true)
                        m_sprite_palyernpc:setVisible(true)
                        m_sprite_palyerchouren:setVisible(false)
                    elseif playerData.is_enemy == true then
                        m_node_playersign:setVisible(true)
                        m_sprite_palyerchouren:setVisible(true)
                        m_sprite_palyernpc:setVisible(false)
                        game_util:setSpriteDisplayBySpriteFrameName(m_sprite_palyerchouren, "ui_pyramid_chousha.png")
                    else
                        m_node_playersign:setVisible(false)
                    end
                    m_node_rewardcountdown:removeAllChildrenWithCleanup(true)
                    if tostring(uid) == game_data:getUserStatusDataByKey("uid") then  -- 我的位置标记
                        m_node_my_place:setVisible(true)
                        m_node_nameboard:setVisible(false)

                        local myLevel = self.m_levelInfo[ self.m_gameData.floor ] or {}
                        local levelData = myLevel.levelData or {}
                        local time = levelData.reward_time and tonumber(levelData.reward_time) or 10
                        if itemData.key ~= "quick" then
                            -- 我获得奖励的倒计时
                            local resetCountLabel = nil
                            local timeEndFunc = function (  )
                                if type(resetCountLabel) == "function" then
                                    resetCountLabel( 60 * time)
                                end
                            end
                            resetCountLabel = function ( dt )
                                dt = dt or 10
                                m_node_rewardcountdown:removeAllChildrenWithCleanup(true)
                                local countdownLabel = game_util:createCountdownLabel(tonumber(dt),timeEndFunc, 6);
                                countdownLabel:setAnchorPoint(ccp(0.5,0.5))
                                countdownLabel:setPosition(ccp(m_node_rewardcountdown:getContentSize().width * 0.5, m_node_rewardcountdown:getContentSize().height * 0.55))
                                countdownLabel:setScale(0.75)
                                m_node_rewardcountdown:addChild(countdownLabel)
                            end
                            
                            local hold_time = tonumber(playerData.hold_time)
                            local curTime = tonumber(game_data:getUserStatusDataByKey("server_time"))
                            -- cclog2(curTime, "curTime   =====   ")
                            -- cclog2(rewardTime, "rewardTime   =====   ")
                            local dtime1 = curTime - hold_time
                            local addTime = math.ceil(dtime1 / 600) * 600
                            local dtime = hold_time + addTime - curTime
                            local countTime = math.max(10, dtime )
                            resetCountLabel( countTime )
                        end
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
                        m_node_playersign:setVisible(false)
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
                            local tempNode = game_util:createIconByName("icon_player_role_" .. tostring(role) .. ".png")
                            if tempNode then
                                tempNode:setAnchorPoint(ccp(0.5,0.5))
                                tempNode:setPositionX(iconBoardSize.width * 0.5)
                                tempNode:setPositionY(iconBoardSize.height * 0.5)
                                tempNode:setScale(0.95) 
                                playerIconBoard:addChild(tempNode, 1, 998)
                            end
                        end
                    end

                else
                    m_node_playerinfo3:setVisible(true)
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            -- cclog2("click table cell index === " .. tostring(index))
            local itemData = showData[index + 1]
            if not itemData then 
                game_util:addMoveTips({ text = string_helper.game_pyramid_tower_scene.place_not_open})
                return 
            end
            if itemData.key == "quick" then
            end 
            -- 这个位置是自己
            local myUid = game_data:getUserStatusDataByKey("uid")
            if tostring(itemData.data.uid) == tostring(myUid) then
                game_util:addMoveTips({ text = string_helper.game_pyramid_tower_scene.not_me_place})
                return
            end


            local myFloor = tonumber(self.m_gameData.floor) or 0
            local curFloor = self.m_curSelectLevel
            local fightFun = function ( callBack )
                if myFloor == 0 then myFloor = 21 end
                if curFloor < myFloor - 1 then
                    game_util:addMoveTips({text = string_helper.game_pyramid_tower_scene.challage_player})
                    -- return
                end

                local function responseMethod(tag,gameData)
                    if not gameData then return end
                    local data = gameData:getNodeWithKey("data")
                    local is_secKill = data and data:getNodeWithKey("is_secKill"):toBool()
                    if is_secKill == true then
                        -- game_util:addMoveTips({text = "你秒杀了对手~~~~~~~~~"})
                        self.m_curSelectLevel = data:getNodeWithKey("upper_floor") and data:getNodeWithKey("upper_floor"):toInt() or self.m_curSelectLevel
                        self:refreshData( gameData )
                        -- self:refreshLevelContent()
                        self:refreshUi()
                        self:refreshLevelCellPos()
                        game_scene:addPop("ui_pyramid_seckill_pop", { enterFloor = self.m_gameData.floor })
                    else
                        game_data:setBattleType("game_pyramid_tower_scene");
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                        self:destroy();
                    end
                    if type(callBack) == "function" then
                        callBack()
                    end
                end
                local params = {};
                params.floor = curFloor;
                params.pos = itemData.pos
                params.uid = itemData.data.uid
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_pyramid_battle"), http_request_method.GET, params,"pyramid_pyramid_battle")
            end

            local pyramidCallFun = function ( call_name, callBack )
                if call_name == "fight" then

                    if self.m_gameData.challenge_times < 1 then
                       local pyramid_cfg = getConfig(game_config_field.pyramid)
                        -- cclog2(pyramid_cfg, "pyramid_cfg   ===   ")
                        if not pyramid_cfg then return end
                        local tempCount = pyramid_cfg:getNodeCount()
                        local tempCfg = pyramid_cfg:getNodeAt(tempCount - 1)
                        local addTimesCostCfg = tempCfg and tempCfg:getNodeWithKey("pay_add_time")
                        if not addTimesCostCfg then return end
                        local price_index = math.min(self.m_gameData.buy_times + 1, addTimesCostCfg:getNodeCount())
                        local priceCfg = addTimesCostCfg:getNodeAt(math.max(0, price_index - 1))
                        if not priceCfg then return end
                        local payValue = priceCfg:toInt()
                        local function responseMethod(tag,gameData)
                            if gameData then
                                game_util:addMoveTips({text = string_helper.game_pyramid_tower_scene.cost_success})
                                self:refreshData(gameData)
                                self:refreMyInfo()
                            end
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
                            text = string_helper.game_pyramid_tower_scene.text .. payValue .. string_helper.game_pyramid_tower_scene.diamond_side,      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-15,
                        }
                        game_util:openAlertView(t_params)
                        return
                    end
                    fightFun( callBack )
                end
            end

            local pyramidInfo = {}
            pyramidInfo.lookFloor = self.m_curSelectLevel
            pyramidInfo.myFloor = self.m_gameData.floor

            local function responseMethod(tag,gameData)
                local data = gameData and gameData:getNodeWithKey("data")
                if not data then return end
                local is_secKill = data:getNodeWithKey("is_secKill") and data:getNodeWithKey("is_secKill"):toBool() or false
                if is_secKill == true then
                    game_util:addMoveTips({text = string_helper.game_pyramid_tower_scene.text2})
                    self:refreshData( gameData )
                    self.m_curSelectLevel = data:getNodeWithKey("upper_floor") and data:getNodeWithKey("upper_floor"):toInt() or self.m_curSelectLevel
                    -- self:refreshLevelContent()
                    self:refreshUi()
                    self:refreshLevelCellPos()
                else
                    game_scene:addPop("ui_small_playerinfo_pop", {gameData = gameData, playerInfo = itemData, pyramidInfo = pyramidInfo, callFun = pyramidCallFun})
                end
            end
            local params = {floor = pyramidInfo.lookFloor, pos = itemData.pos, uid = itemData.data.uid}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_user_info"), http_request_method.GET, params,"pyramid_user_info")
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

    self.m_curSelPos = 3
    if self.m_curSelPos then
        local countIndex = math.ceil(self.m_curSelPos / (params.row * params.column))
        cclog2(countIndex, "countIndex  ====   ")
        params.showPageIndex = countIndex
        self.m_curSelPos = nil
    end


    local tableView = TableViewHelper:createGallery3(params)
    if itemCount <= 2 then
        tableView:setMoveFlag(false)
        tableView:setScrollBarVisible(false)
    end
    viewBoard:addChild(tableView)
    return tableView
end

--[[
    刷新层数信息
]]
function game_pyramid_tower_scene.refreMyInfo( self )
    -- 更新人数信息
    
    -- 我所在层数名字
    local msg = ""
    if self.m_gameData.floor == 0 then
        msg = string_helper.game_pyramid_tower_scene.msg
    else
        local levelName = game_util:convertNum2Chinese( self.m_gameData.floor )
        msg = string_helper.game_pyramid_tower_scene.di .. tostring(levelName) .. string_helper.game_pyramid_tower_scene.cen
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


end

--[[
    刷新本层玩家信息
]]
function game_pyramid_tower_scene.refreshLevelContent( self )
     -- 当前层数
    local levelName = game_util:convertNum2Chinese( self.m_curSelectLevel )
    local levelInfo = string_helper.game_pyramid_tower_scene.di .. tostring(levelName) .. string_helper.game_pyramid_tower_scene.cen
    self.m_blabel_curlevelname:setString(levelInfo)
    -- 当前层数状态
    local stateSpriteFrameName = {"ui_pyramid_n_wodeceng.png", "ui_pyramid_n_kegongda.png", "ui_pyramid_n_bukegongda.png"}
    local stateSprName = nil
    local levelState = string_helper.game_pyramid_tower_scene.levelState
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


    -- 普通玩家列表
     self.m_node_playersboard:removeAllChildrenWithCleanup(true)
     local playersTabelView = self:creatPlayersTableView( self.m_node_playersboard )
     if playersTabelView then
        -- self.m_node_playersboard:addChild(playersTabelView)
     end
end

--[[--
    刷新ui
]]
function game_pyramid_tower_scene.refreshUi( self )
    -- -- 金字塔层数列表
     self.m_node_levellistboard:removeAllChildrenWithCleanup(true)
     self.m_level_tableView = nil
     local levelTabelView = self:creatLevelTableView( self.m_node_levellistboard:getContentSize() )
     if levelTabelView then
        self.m_node_levellistboard:addChild(levelTabelView)
        self.m_level_tableView = levelTabelView
     end

    self:refreshLevelContent()
    self:refreMyInfo()
    self:refreshBroadCastMsg()
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

    self.m_pyramidData = {}
    local pyramid_cfg = getConfig(game_config_field.pyramid)
    local nodeCount = pyramid_cfg and pyramid_cfg:getNodeCount() or 1
    local tempCfg = pyramid_cfg and pyramid_cfg:getNodeAt(nodeCount - 1 )
    self.m_pyramidData = tempCfg and json.decode(tempCfg:getFormatBuffer()) or {}

    self:refreshData(nil)

end

--[[
    刷新消息
]]
function game_pyramid_tower_scene.refreshBroadCastMsg( self )
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

--[[
    根据请求返回值更新数据
]]
function game_pyramid_tower_scene.refreshData( self, gameData )
    local tempData = {}
    if gameData then
        local data = gameData and gameData:getNodeWithKey("data")
        tempData = data and json.decode(data:getFormatBuffer()) or {}
    end

    if tempData.floor_real_player_num then
        self.m_gameData.floor_real_player_num = tempData.floor_real_player_num
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
    if tempData.floor_enemy then
        self.m_gameData.floor_enemy = tempData.floor_enemy
    end

    if tempData.floor_extra_people then
        self.m_gameData.floor_extra_people = tempData.floor_extra_people
    end

    if tempData.buy_times then
        self.m_gameData.buy_times = tempData.buy_times
    end

    if tempData.buy_morale_times then
        self.m_gameData.buy_morale_times = tempData.buy_morale_times
    end

    if type(self.m_gameData.buy_quick_times) ~= "number" then
        self.m_gameData.buy_quick_times = 0
    end

    if tempData.buy_quick_times then
        self.m_gameData.buy_quick_times = tempData.buy_quick_times
    end

    if tempData.pyramid_notice then
        self.m_gameData.pyramid_notice = tempData.pyramid_notice
    end


    if tempData.upper_floor_data then
        self.m_gameData.pos_info = tempData.upper_floor_data
    end

    if tempData.battle_floor then
        self.m_gameData.floor = tempData.battle_floor
    end

    if tempData.battle_pos then
        self.m_gameData.pos = tempData.battle_pos
    end

    -- cclog2(self.m_gameData, "self.m_gameData")

    local luckPos = self.m_gameData.lucky_situation or nil

    -- 选中层敌人列表
    local level_enemy_list = self.m_gameData.floor_enemy and self.m_gameData.floor_enemy[tostring(self.m_curSelectLevel)] or {}
    local enemy_list = level_enemy_list.enemy_list or {}

    -- 选中层悬赏信息
    local level_wanted_list = self.m_gameData.floor_extra_people and self.m_gameData.floor_extra_people[tostring(self.m_curSelectLevel)] or {}
    local wanted_list = level_wanted_list.extra_people or {}

    -- 选中层玩家信息
    local norPlayer = {}
    local luckPlayer = {}
    local quickPlayer = {}
    local myInfo = {}
    local myUid = game_data:getUserStatusDataByKey("uid")
    for i,v in pairs(self.m_gameData.pos_info) do
        v.is_enemy = game_util:valueInTeam(v.uid, enemy_list)
        v.is_Wanted = game_util:valueInTeam(v.uid, wanted_list)
        if v.shortcut == 1 then  -- 快速通道
            if self.m_gameData.floor == self.m_curSelectLevel and tostring(self.m_gameData.pos) == tostring(i) then  -- 我自己在快速通道
                v.uid = myUid
            end
            table.insert(quickPlayer, {key = "quick", data = v, pos = i})
        elseif tostring(self.m_gameData.lucky_floor) == tostring(self.m_curSelectLevel)  and tostring(i) == tostring(luckPos) then
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

    for k,v in ipairs(self.m_curFloorPlayerData) do
        if self.m_willShowData and tostring(self.m_willShowData.pos) == tostring(v.pos) then
            self.m_curSelPos = k
        end
    end
    self.m_willShowData = nil
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
    if self.m_curSelectLevel == 0 then
        self.m_curSelectLevel = 20
    end

    if t_params.showLevelInfo then
        self.m_willShowData = t_params.showLevelInfo
        if t_params.showLevelInfo.floor then
            self.m_curSelectLevel = t_params.showLevelInfo.floor
        end
    end

    self.m_battleData = t_params.battleData
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
    -- self:refreshLevelContent()
    return scene;
end

return game_pyramid_tower_scene