---  建筑详细

local map_building_detail_pop = {
    m_cityId = nil,
    m_buildingId = nil,
    m_next_step = nil,
    m_fight_list_count = nil,
    m_card_anim_tab = nil,

    m_building_node = nil,
    m_building_name = nil,
    m_introduction_label = nil,
    m_stageTableData = nil,
    m_popUi = nil,
    m_root_layer = nil,
    m_points_layer = nil,
    m_explore_btn = nil,
    m_close_btn = nil,
    m_callFunc = nil,
    m_landItemOpenType = nil,
    m_no_reward_label = nil,
    m_rewardNodeTab = nil,
    m_reward_node = nil,
    m_fight_cost_label = nil,
    m_lock_label = nil,
    m_auto_battle_btn = nil,
    m_ui_node = nil,
    m_detail_btn = nil,
    m_fight_count_label = nil,
    m_list_view_bg = nil,
    m_opemDetailFlag = nil,
    m_surplus_label = nil,
    m_enemy_tab = nil,
    m_combat_label = nil,
    m_backgroundName = nil,
};
--[[--
    销毁
]]
function map_building_detail_pop.destroy(self)
    -- body
    cclog("-----------------map_building_detail_pop destroy-----------------");
    self.m_cityId = nil;
    self.m_buildingId = nil;
    self.m_next_step = nil;
    self.m_fight_list_count = nil;
    self.m_card_anim_tab = nil;

    self.m_building_node = nil;
    self.m_building_name = nil;
    self.m_introduction_label = nil;
    self.m_stageTableData = nil;
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_explore_btn = nil;
    self.m_root_layer = nil;
    self.m_points_layer = nil;
    self.m_explore_btn = nil;
    self.m_close_btn = nil;
    self.m_callFunc = nil;
    self.m_landItemOpenType = nil;
    self.m_no_reward_label = nil;
    self.m_rewardNodeTab = nil;
    self.m_reward_node = nil;
    self.m_fight_cost_label = nil;
    self.m_lock_label = nil;
    self.m_auto_battle_btn = nil;
    self.m_ui_node = nil;
    self.m_detail_btn = nil;
    self.m_fight_count_label = nil;
    self.m_list_view_bg = nil;
    self.m_opemDetailFlag = nil;
    self.m_surplus_label = nil;
    self.m_enemy_tab = nil;
    self.m_combat_label = nil;
    self.m_backgroundName = nil;
end

--[[--
    返回
]]
function map_building_detail_pop.back(self,type)
    game_scene:removePopByName("map_building_detail_pop");
end
--[[--
    进入战斗场景
]]
function map_building_detail_pop.enterBattleScene(self)
    if self.m_next_step == -1 or self.m_next_step >= self.m_fight_list_count then
        require("game_ui.game_pop_up_box").showAlertView(string_config.m_map_title_battle_over);
        return;
    end
    local responseMethod = function(tag,gameData)
        local has_battled = gameData:getNodeWithKey("data"):getNodeWithKey("has_battled"):toInt();
        -- print("------------ get battle back data is --------------------------")
        -- print(gameData:getNodeWithKey("data"):getFormatBuffer())
        cclog("responseMethod --------------------------------" .. has_battled)
        if has_battled == 1 then
            game_data:setBattleType("map_building_detail_scene");
            local t_param = {gameData = gameData,cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,stageTableData=self.m_stageTableData,backGroundName = self.m_backgroundName}
            game_scene:enterGameUi("game_battle_scene",t_param)
            game_util:writeBattleData(gameData:getFormatBuffer())
            self:destroy();
        end
    end
    local params = {};
    params.city = self.m_cityId;
    params.building = self.m_buildingId;
    params.step_n = self.m_next_step;
    if game_data:getMapType() == "hard" then
        local chapter = game_data:getChapterByStage(self.m_cityId)
        print("   chapter id  ============   ", chapter)
        params.chapter = chapter
    end

    print("params.city = self.m_cityId; =========== game_data:getMapType()  ", params.city ,  game_data:getMapType() )
    if game_data:getMapType() == "hard" then
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("city_hard_recapture"), http_request_method.GET, params,"city_hard_recapture")
    else
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_recapture"), http_request_method.GET, params,"private_city_recapture")
    end




    game_data:setUserStatusDataBackup();
end

--[[--
    创建建筑的item
]]
function map_building_detail_pop.createBuildingItems(self,points_layer)
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
    local fight_list = buildingCfgData:getNodeWithKey("fight_list");
    if fight_list and not fight_list:isEmpty() and fight_list:getNodeCount() > 0 then
        local fight_list_count = fight_list:getNodeCount();
        self.m_fight_list_count = fight_list_count;
        local bgSize = points_layer:getContentSize();
        local itemWidth = bgSize.width / (fight_list_count + 1);
        local fightItem = nil;
        local fightItemSpr = nil;
        local fightItemName = nil;
        for i=1,fight_list_count do
            fightItem = fight_list:getNodeAt(i - 1);
            -- fightItemSpr = CCSprite:createWithSpriteFrameName("public_meixuanzhong.png");
            -- fightItemSpr:setPosition(itemWidth*i,bgSize.height*0.5);
            -- points_layer:addChild(fightItemSpr);
            -- fightItemName = CCLabelTTF:create(fightItem:getNodeAt(0):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,12);
            -- fightItemName:setPosition(itemWidth*i,bgSize.height*0.1);
            -- fightItemName:setColor(ccc3(255,127,0));
            -- points_layer:addChild(fightItemName);
            if self.m_next_step ~= -1 then
                if i-1 < self.m_next_step then
                    -- fightItemSpr:setColor(ccc3(255,0,0));
                elseif i-1 > self.m_next_step then
                    -- fightItemSpr:setColor(ccc3(255,255,255));
                else
                    -- fightItemSpr:setColor(ccc3(0,255,0));
                    local stageName = fightItem:getNodeAt(0):toStr();
                    self.m_stageTableData.name = stageName
                end
            end
        end
        self.m_stageTableData.step = self.m_next_step+1;
        self.m_stageTableData.totalStep = fight_list_count;
    end
end
--[[--
    读取ccbi创建ui
]]
function map_building_detail_pop.createUi(self)    
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        game_scene:removeGuidePop();
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --关闭
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                self.m_callFunc("close");
            end
            self:back();
        elseif btnTag == 2 then --探索
            if game_data.getGuideProcess and game_data:getGuideProcess() == "first_battle_mine" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(22) end -- 点击探索 步骤22
            end
            -- self:enterBattleScene();
            -- if self.m_landItemOpenType ~= 2 then
            --     local level = game_data:getUserStatusDataByKey("level") or 1;
            --     if level < 10 then
            --         game_util:addMoveTips({text = string_config.m_re_battle_lock_msg});
            --         return;
            --     end
            -- end
            local function okFunc()
                -- if self.m_callFunc and type(self.m_callFunc) == "function" then
                --     self.m_callFunc("battle");
                -- end
                self:enterBattleScene();
                self.m_callFunc("refresh");
                -- self:back();
                -- game_scene:removeAllPop();
            end

            local action_point = game_data:getUserStatusDataByKey("action_point") or 0
            local mapConfig = getConfig(game_config_field.map_title_detail);
            local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
            if buildingCfgData then
                local fight_list_count = buildingCfgData:getNodeWithKey("fight_list"):getNodeCount();
                local need_action_point = fight_list_count * buildingCfgData:getNodeWithKey("action_point"):toInt();
                cclog("action_point ========" .. action_point .. " ; need_action_point ==" .. need_action_point)
                if need_action_point > action_point then
                    -- local text = string.format(string_config.m_action_point_tips,fight_list_count,need_action_point);
                    -- local t_params = 
                    -- {
                    --     title = string_config.m_title_prompt,
                    --     okBtnCallBack = function(target,event)
                    --         game_util:closeAlertView();
                    --         okFunc();
                    --     end,   --可缺省
                    --     okBtnText = string_config.m_btn_sure,       --可缺省
                    --     cancelBtnText = string_config.m_btn_cancel,
                    --     text = text,      --可缺省
                    --     onlyOneBtn = false,
                    --     touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    -- }
                    -- game_util:openAlertView(t_params)
                    --换成统一的提示
                    local t_params = 
                    {
                        m_openType = 3,
                        m_call_func = function()
                            self.m_callFunc("tips");
                        end
                    }
                    game_scene:addPop("game_normal_tips_pop",t_params)
                else
                    -- if game_data:getAvailableCardBackpackNum() < 5 then
                    --     -- local function callBackFunc()
                    --     --     okFunc();
                    --     -- end
                    --     -- game_scene:addPop("game_tips_pop",{callBackFunc = callBackFunc})
                    --     --换成统一的提示
                    --     local t_params = 
                    --     {
                    --         m_openType = 1,
                    --         m_call_func = function()
                    --             self.m_callFunc("tips");
                    --         end
                    --     }
                    --     game_scene:addPop("game_normal_tips_pop",t_params)
                    -- elseif game_data:getAvailableEquipBackpackNum() < 5 then
                    --     local t_params = 
                    --     {
                    --         m_openType = 2,
                    --         m_call_func = function()
                    --             self.m_callFunc("tips");
                    --         end
                    --     }
                    --     game_scene:addPop("game_normal_tips_pop",t_params)
                    -- else
                        okFunc();
                    -- end
                end
            else
                -- if game_data:getAvailableCardBackpackNum() < 5 then
                --     -- local function callBackFunc()
                --     --     okFunc();
                --     -- end
                --     -- game_scene:addPop("game_tips_pop",{callBackFunc = callBackFunc})
                --     --换成统一的提示
                --     local t_params = 
                --     {
                --         m_openType = 1,
                --         m_call_func = function()
                --             self.m_callFunc("tips");
                --         end
                --     }
                --     game_scene:addPop("game_normal_tips_pop",t_params)
                -- elseif game_data:getAvailableEquipBackpackNum() < 5 then
                --     local t_params = 
                --     {
                --         m_openType = 2,
                --         m_call_func = function()
                --             self.m_callFunc("tips");
                --         end
                --     }
                --     game_scene:addPop("game_normal_tips_pop",t_params)
                -- else
                    okFunc();
                -- end
                
            end
        elseif btnTag == 3 then --自动探索
            -- local level = game_data:getUserStatusDataByKey("level") or 1;
            -- if level < 10 then
            --     game_util:addMoveTips({text = string_config.m_re_battle_lock_msg});
            --     return;
            -- end
            local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
            if vipLevel < 2 then
                game_util:addMoveTips({text = string_helper.map_building_detail_pop.vip2Tips});
                return;
            end
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                self.m_callFunc("autoBattle");
            end
            self:back();
        elseif btnTag == 4 then --详细
            if self.m_opemDetailFlag == false then
                ccbNode:runAnimations("detail_anim")
                self:refreshRewardList();
                self.m_opemDetailFlag = true;
            else
                ccbNode:runAnimations("default_anim")
                self.m_opemDetailFlag = false;
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_map_building_detail_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_explore_btn = ccbNode:controlButtonForName("m_explore_btn")
    game_util:setCCControlButtonTitle(self.m_explore_btn,string_helper.ccb.title171)
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_points_layer = ccbNode:layerForName("m_points_layer")

    self.m_building_node = ccbNode:nodeForName("m_building_node");
    self.m_building_name = ccbNode:labelTTFForName("m_building_name");
    self.m_introduction_label = ccbNode:labelTTFForName("m_introduction_label");
    self.m_fight_cost_label = ccbNode:labelTTFForName("m_fight_cost_label");
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_no_reward_label = ccbNode:labelTTFForName("m_no_reward_label")
    self.m_lock_label = ccbNode:labelTTFForName("m_lock_label")
    self.m_reward_node:setVisible(false);
    self.m_no_reward_label:setVisible(false);
    self.m_auto_battle_btn = ccbNode:controlButtonForName("m_auto_battle_btn")
    game_util:setCCControlButtonTitle(self.m_auto_battle_btn,string_helper.ccb.title172)
    self.m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
    game_util:setCCControlButtonTitle(self.m_detail_btn,string_helper.ccb.title169)
    self.m_detail_btn:setVisible(false);
    self.m_fight_count_label = ccbNode:labelTTFForName("m_fight_count_label")
    self.m_surplus_label = ccbNode:labelTTFForName("m_surplus_label")
    self.m_ui_node = ccbNode:nodeForName("m_ui_node");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg");
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    local  title170 = ccbNode:labelTTFForName("title170");
    title170:setString(string_helper.ccb.title170)
    local reward_icon,reward_label;
    for i=1,4 do
        reward_icon = ccbNode:spriteForName("m_reward_icon_" .. i);
        reward_label = ccbNode:labelTTFForName("m_reward_label_" .. i);
        reward_icon:setVisible(false);
        reward_label:setVisible(false);
        self.m_rewardNodeTab[#self.m_rewardNodeTab+1] = {reward_icon = reward_icon, reward_label = reward_label}
    end

    local tempSize = self.m_ui_node:getContentSize();

    -- 扫荡按钮
    if game_data:isViewOpenByID(107) then
        self.m_landItemOpenType = self.m_landItemOpenType
    else
        self.m_landItemOpenType = 2
    end

    if self.m_landItemOpenType == 2 then
        -- game_util:setCCControlButtonTitle(self.m_explore_btn,string_config.m_explore);
        self.m_auto_battle_btn:setVisible(false);
        self.m_explore_btn:setPositionX(tempSize.width*0.5)
    else
        -- game_util:setCCControlButtonTitle(self.m_explore_btn,string_config.m_re_explore);
        -- local level = game_data:getUserStatusDataByKey("level") or 1;
        -- if level < 10 then
        local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
        if vipLevel < 2 then
            -- game_util:setCCControlButtonBackground(self.m_explore_btn,"public_neiniu_1.png");
            -- self.m_explore_btn:setEnabled(false)
            -- self.m_lock_label:setString(tostring(string_config.m_re_battle_lock_msg));
            -- self.m_auto_battle_btn:setVisible(false);
            -- self.m_explore_btn:setPositionX(tempSize.width*0.75)
            game_util:setCCControlButtonBackground(self.m_auto_battle_btn,"public_neiniu_1.png");
            -- self.m_auto_battle_btn:setEnabled(false)
        else
            -- self.m_auto_battle_btn:setVisible(true);
            -- self.m_lock_label:setString("");
        end
    end
    game_util:setControlButtonTitleBMFont(self.m_explore_btn)
    game_util:setControlButtonTitleBMFont(self.m_auto_battle_btn)

    self.m_explore_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_auto_battle_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_detail_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- if self.m_callFunc and type(self.m_callFunc) == "function" then
            --     self.m_callFunc("close");
            -- end
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- self:initLayerTouch(self.m_points_layer);   -- 换了一个展示奖励的方法 

    -- local function animEndCallFunc(animName)
    --     game_guide_controller:gameGuide("show","1",7,{tempNode = self.m_explore_btn});
    -- end
    -- ccbNode:registerAnimFunc(animEndCallFunc)
    game_guide_controller:gameGuide("show","1",7,{tempNode = self.m_explore_btn});
    local id = game_guide_controller:getIdByTeam("1");
    if id == 27 and self.m_landItemOpenType == 2 and self.m_cityId == "101" then
        game_scene:addGuidePop({tempNode = self.m_explore_btn})
    end
    ccbNode:runAnimations("enter_anim")
    return ccbNode;
end


--[[--
    根据触摸位置 展示奖励   -- 不用了
]]
function map_building_detail_pop.initLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        touchBeginPoint = {x = x, y = y}
        -- realPos = self.m_reward_node:getParent():convertToNodeSpace(ccp(x,y));
        -- if self.m_reward_node:isVisible() == false or self.m_reward_node:boundingBox():containsPoint(realPos) == false then
        --     -- if self.m_callFunc and type(self.m_callFunc) == "function" then
        --     --     self.m_callFunc("close");
        --     -- end
        --     -- self:back();
        --     return false;
        -- end
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        realPos = self.m_reward_node:convertToNodeSpace(ccp(x,y));
        for i = 1,4 do
            tempItem = self.m_rewardNodeTab[i].reward_icon
            if tempItem:boundingBox():containsPoint(realPos) and self.m_rewardNodeTab[i].tipsText then
                --换成通用物品显示
                if self.m_rewardNodeTab[i].sortTab then
                    game_util:lookItemDetal(self.m_rewardNodeTab[i].sortTab)
                else
                    game_util:addMoveTips({text = self.m_rewardNodeTab[i].tipsText});
                end
            end
        end
        if not touchMoveFlag then
            for k,v in pairs(self.m_enemy_tab) do
                realPos = v.parentNode:convertToNodeSpace(ccp(x,y));
                if v.node and v.node:boundingBox():containsPoint(realPos) then
                    cclog("v.itemCfg =============== " .. tostring(v.itemCfg))
                    game_scene:addPop("game_enemy_info_pop",{itemCfg = v.itemCfg,pos = ccp(x,y)})
                end
            end
        end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
    formation_layer:setTouchEnabled(true)
end

--[[
    奖励列表
]]
function map_building_detail_pop.createRewardTable(self, viewSize, rewardList)
    rewardList = rewardList or {}
    -- cclog2(rewardList, "rewardList ==== ")
    function onBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local itemData = rewardList[btnTag + 1]
        if itemData then
            game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.totalItem = #rewardList;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local itemArgCount = itemGift and itemGift:getNodeCount() or 4
            local icon,name,count = game_util:getRewardByItem(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
                -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
                -- button:setAnchorPoint(ccp(0.5,0.5))
                -- button:setPosition( node:getContentSize().width * 0.5, node:getContentSize().height * 0.5 )
                -- button:setOpacity(0)
                -- node:addChild(button)
                -- button:setTag( index )
                local countStr = string_helper.map_building_detail_pop.lowPro
                if itemArgCount < 4 and count then
                    countStr = "×" .. tostring(count)
                end
                local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 10})
                label_count:setAnchorPoint(ccp(0.5,0.5))
                label_count:setPosition(ccp(0,-20))
                node:addChild(label_count,20)
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = rewardList[index + 1]
            if itemData then
                game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    return TableViewHelper:create(params);
end


--[[--
    刷新奖励列表
]]
function map_building_detail_pop.refreshRewardList(self)
    local childrenCount = self.m_list_view_bg:getChildrenCount();
    if childrenCount > 0 then
        return;
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
    if buildingCfgData == nil then
        return;
    end
    -- local enemy_detail_cfg = getConfig(game_config_field.enemy_detail);
    -- local map_fight_cfg = getConfig(game_config_field.map_fight)
    local map_fight_and_enemy = game_data:getDataByKey("map_fight_and_enemy") or {}
    local map_fight_cfg = map_fight_and_enemy.map_fight or {}
    local enemy_detail_cfg = map_fight_and_enemy.enemy_detail or {}
    local fight_list = buildingCfgData:getNodeWithKey("fight_list")
    local tempCount = fight_list:getNodeCount()
    local viewSize = self.m_list_view_bg:getContentSize();

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    local scrollView = CCScrollView:create(viewSize);
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    local contentSize = CCSizeMake(itemSize.width,itemSize.height*tempCount)
    scrollView:setContentSize(contentSize);
    scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
    self.m_list_view_bg:addChild(scrollView);
    for index=1,tempCount do
        local cell = CCNode:create();
        local spriteLand = CCSprite:createWithSpriteFrameName("public_biaoqian3.png")
        spriteLand:setAnchorPoint(ccp(0, 1));
        spriteLand:setPosition(ccp(0,itemSize.height));
        cell:addChild(spriteLand,1,1)
        local tempLabel = game_util:createLabelTTF({text = string.format(string_helper.map_building_detail_pop.scene,index),color = ccc3(250,180,0),fontSize = 10});
        tempLabel:setAnchorPoint(ccp(0, 1));
        tempLabel:setPosition(ccp(10,itemSize.height*0.975));
        cell:addChild(tempLabel,2,2);
        cell:setPosition(ccp(0, contentSize.height-itemSize.height*index))
        local itemCfg = fight_list:getNodeAt(index-1)
        local map_fight_item_cfg = map_fight_cfg[itemCfg:getNodeAt(1):toStr()]
        if map_fight_item_cfg then
            local positionItem,idCount,tempIcon
            local posIndex = 0;
            for i=1,5 do
                positionItem = map_fight_item_cfg["position" .. i] or {}
                idCount = #positionItem
                if idCount > 0 then
                    -- local enemy_detail_item_cfg = enemy_detail_cfg:getNodeWithKey(positionItem:getNodeAt(0):toStr())
                    -- local enemy_detail_item_cfg = game_util:getEnemyCfgByStageIdAndEnemyId(nil,positionItem:getNodeAt(0):toStr())
                    local enemy_detail_item_cfg = enemy_detail_cfg[tostring(positionItem[1])]
                    if enemy_detail_item_cfg then
                        local tempIcon = game_util:createIconByName(tostring(enemy_detail_item_cfg.img))
                        if tempIcon then
                            tempIcon:setScale(0.6);
                            tempIcon:setPosition(ccp(itemSize.width*0.175*(posIndex+1), itemSize.height*0.4))
                            cell:addChild(tempIcon);
                            self.m_enemy_tab[tostring(tempIcon)] = {node = tempIcon,itemCfg = enemy_detail_item_cfg,parentNode = cell}
                        end
                    end
                    posIndex = posIndex + 1;
                end
            end
        end
        scrollView:addChild(cell)
    end
    scrollView:setContentOffset(ccp(0,viewSize.height - contentSize.height))
end

--[[--
    刷新ui
]]
function map_building_detail_pop.refreshUi(self)
    local tempRewardData = {}
    self.m_fight_cost_label:setString("");
    self.m_fight_count_label:setString("");
    self.m_points_layer:removeAllChildrenWithCleanup(true);
    self:createBuildingItems(self.m_points_layer);
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
    -- print(" buildingCfgData  ====  ")
    -- print(buildingCfgData:getFormatBuffer())
    self.m_reward_node:setVisible(true);
    if buildingCfgData ~= nil then
        self.m_backgroundName = game_util:getResName(buildingCfgData:getNodeWithKey("background"):toStr());
        -- cclog("self.m_backgroundName == " .. self.m_backgroundName)
        local fight_list_count = buildingCfgData:getNodeWithKey("fight_list"):getNodeCount();
        local action_point = buildingCfgData:getNodeWithKey("action_point"):toInt();
        -- self.m_fight_cost_label:setString(string.format(string_config.m_fight_cost_tips,fight_list_count,action_point));
        self.m_fight_cost_label:setString(action_point);
        self.m_fight_count_label:setString("×" .. fight_list_count);
        self.m_introduction_label:setString(buildingCfgData:getNodeWithKey("title_detail"):toStr());
        self.m_building_name:setString(buildingCfgData:getNodeWithKey("title_name"):toStr());
        local buildingIconName = buildingCfgData:getNodeWithKey("title_img"):toStr();
        local firstValue,_ = string.find(buildingIconName,".png");
        local buildingSpr = CCSprite:create("building_img/" .. buildingIconName .. (firstValue == nil and ".png" or ""));
        local buildingSize = buildingSpr:getContentSize();
        local scale = math.min(buildingSize.width~=0 and 120/buildingSize.width or 1,buildingSize.height~=0 and 120/buildingSize.height or 1);
        buildingSpr:setScale(scale);
        buildingSpr:setAnchorPoint(ccp(0.5, 0));
        buildingSpr:setPositionY(-30);
        self.m_building_node:addChild(buildingSpr);

        if self.m_landItemOpenType == 2 then--第一次
            self.m_surplus_label:setString("")
            -- cclog2(buildingCfgData, "buildingCfgData    ======= ")
            local reward_first_base = buildingCfgData:getNodeWithKey("reward_first_base")
            local reward_first_rate = buildingCfgData:getNodeWithKey("reward_first_rate")
            local tempCount = reward_first_base:getNodeCount();
            for i=1,tempCount do
                table.insert(tempRewardData, reward_first_base:getNodeAt(i-1))
            end
            local tempCount2 = reward_first_rate:getNodeCount();
            if tempCount2 > 0 and self.m_buildingId > 0 then
                for i = 1, tempCount2 - 1 do
                    table.insert(tempRewardData, reward_first_rate:getNodeAt(i-1))
                end                
            end

            if tempCount == 0 and tempCount2 == 0 then
                self.m_no_reward_label:setVisible(true);
            end
        elseif self.m_landItemOpenType == 1 then--再次探索
            local sweepLogData = game_data:getSelCitySweepLogData();
            local current_sweep = sweepLogData[tostring(self.m_buildingId)] or 0;
            local max_sweep = buildingCfgData:getNodeWithKey("max_sweep"):toInt();
            current_sweep = math.min(current_sweep,max_sweep)
            self.m_surplus_label:setString(string.format(string_helper.map_building_detail_pop.leftTimes,math.max(0,max_sweep-current_sweep)))
            
            local reward_sweep_base = buildingCfgData:getNodeWithKey("reward_sweep_base")
            local reward_sweep_rate = buildingCfgData:getNodeWithKey("reward_sweep_rate")

            local tempCount = reward_sweep_base:getNodeCount();
            for i=1,tempCount do
                table.insert(tempRewardData, reward_sweep_base:getNodeAt(i-1))
            end

            local tempCount2 = reward_sweep_rate:getNodeCount()
            if tempCount2 > 0 and self.m_buildingId > 0 then
                for i= 1, tempCount2 - 1 do
                    table.insert(tempRewardData, reward_sweep_rate:getNodeAt(i-1))
                end
            end
            if tempCount == 0 and tempCount2 == 0 then
                self.m_no_reward_label:setVisible(true);
            end
        end
    else
        self.m_surplus_label:setString(string_helper.map_building_detail_pop.leftZero)
    end

    -- cclog2(tempRewardData,  "tempRewardData       ======     ")

    -- self.m_reward_node:removeAllChildrenWithCleanup(true)
    local tview = self:createRewardTable(self.m_reward_node:getContentSize(), tempRewardData)
    self.m_reward_node:addChild(tview)

end

--[[--
    初始化
]]
function map_building_detail_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cityId = tostring(t_params.cityId);
    self.m_isHardCity = t_params.isHardCity
    self.m_buildingId = t_params.buildingId;
    game_data:setSelBuildingId(self.m_buildingId);
    if t_params.next_step ~= nil then
        self.m_next_step = t_params.next_step;        
    end
    self.m_next_step = self.m_next_step or 0;
    if game_data:getReMapBattleFlag() == false then
        local selCityData = game_data:getSelCityData();
        local recapture_log = selCityData.recapture_log or {}
        local recapture_log_item = recapture_log[tostring(self.m_buildingId)] or {}
        if #recapture_log_item > 0 then
            self.m_next_step = recapture_log_item[#recapture_log_item] + 1;
        end
    end
    cclog("tostring(self.m_buildingId) =============" .. tostring(self.m_buildingId) .. "; self.m_next_step ==" .. self.m_next_step);
    self.m_card_anim_tab = {};
    self.m_stageTableData = {};
    self.m_callFunc = t_params.callFunc;
    self.m_landItemOpenType = t_params.landItemOpenType or 1;
    self.m_rewardNodeTab = {};
    self.m_opemDetailFlag = false;
    self.m_enemy_tab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function map_building_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return map_building_detail_pop;