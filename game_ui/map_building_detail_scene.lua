---  建筑详细

local map_building_detail_scene = {
    m_cityId = nil,
    m_buildingId = nil,
    m_next_step = nil,
    m_fight_list_count = nil,
    m_checkpoint_name_label = nil,
    m_checkpoint_label = nil,
    m_background_node = nil,
    m_move_ndoe = nil,
    m_backgroundup_node = nil,
    m_card_anim_tab = nil,
    m_card_anim_dfd_tab = nil,
    m_battleData = nil,
    m_formation_layer = nil,

    m_building_node = nil,
    m_building_name = nil,
    m_introduction_label = nil,
    m_building_detal_layer = nil,
    m_reward_label = nil,

    m_ccbNode = nil,        -- 场景ui前景
    m_ccbParent1 = nil,     -- 场景背景远景1
    m_ccbParent2 = nil,     -- 场景背景远景2
    m_ccbParentSize = nil,  -- 单个背景场景尺寸
    m_ccbParentUp1 = nil,     -- 场景背景远景1
    m_ccbParentUp2 = nil,     -- 场景背景远景2
    m_stageTableData = nil,
    m_advance_btn = nil,
    m_bgMusic = nil,
    m_autoFlag = nil,
    m_points_layer = nil,
    m_auto_battle_btn = nil,
    m_touchCardTab = nil,
    m_backgroundName = nil,
    m_formation_btn = nil,
    m_back_btn = nil,
};

--[[--
    销毁
]]
function map_building_detail_scene.destroy(self)
    -- body
    cclog("-----------------map_building_detail_scene destroy-----------------");
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ccbResources/ui_battle_xian.plist");
    self.m_cityId = nil;
    self.m_buildingId = nil;
    -- self.m_next_step = nil;
    self.m_fight_list_count = nil;
    self.m_checkpoint_name_label = nil;
    self.m_checkpoint_label = nil;
    self.m_background_node = nil;
    self.m_move_ndoe = nil;
    self.m_backgroundup_node = nil;
    self.m_card_anim_tab = nil;
    self.m_card_anim_dfd_tab = nil;
    if self.m_battleData ~= nil then
        self.m_battleData:delete();
        self.m_battleData = nil;
    end

    self.m_building_node = nil;
    self.m_building_name = nil;
    self.m_introduction_label = nil;
    self.m_building_detal_layer = nil;
    self.m_reward_label = nil;
    self.m_stageTableData = nil;
    self.m_advance_btn = nil;
    self.m_autoFlag = nil;
    self.m_points_layer = nil;
    self.m_auto_battle_btn = nil;
    self.m_touchCardTab = nil;
    self.m_backgroundName = nil;
    self.m_formation_btn = nil;
    self.m_back_btn = nil;
end
--[[--
    返回
]]
function map_building_detail_scene.back(self,type)
        game_scene:enterGameUi("game_small_map_scene",{buildingId = self.m_buildingId});
        self:destroy();
        self.m_next_step = 0;
end
--[[--
    进入战斗场景
]]
function map_building_detail_scene.enterBattleScene(self)
    local loadNode  --加载黑色节点
    if self.m_next_step == -1 or self.m_next_step >= self.m_fight_list_count then
        require("game_ui.game_pop_up_box").showAlertView(string_config.m_map_title_battle_over);
        return;
    end
    local isBlackAll = false--是否整个场景都变黑
    local responseMethod = function(tag,gameData)
        if(gameData == nil) then
            --[[--local runEnd = function()
            end
            self.m_ccbNode:registerAnimFunc(runEnd)
            self.m_ccbNode:runAnimations("outer_anim_1")
            game_scene:runPropertyBarAnim("outer_anim")]]--
            return 
        end
        game_scene:removeGuidePop();
        local has_battled = gameData:getNodeWithKey("data"):getNodeWithKey("has_battled"):toInt();
        cclog("responseMethod --------------------------------" .. has_battled)
        if has_battled == 1 then
            local function animEndCallFunc()
                game_guide_controller:gameGuide("send","1",8);                
                game_util:writeBattleData(gameData:getFormatBuffer())
                game_data:setBattleType("map_building_detail_scene");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData,cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,stageTableData=self.m_stageTableData,backGroundName = self.m_backgroundName});
                self:destroy();
            end
            if self.m_autoFlag == false then
                animEndCallFunc();
                game_scene:runPropertyBarAnim("outer_anim")
            else
                self:autoBattleCallFunc(gameData);
            end
        end
    end
    local m_tag = nil
    local tempGameData = nil
    local isuiRunOut = false
    --运行界面动画
    local uiRunOut = function()
        --创建加载黑影
        if(not isuiRunOut) then
            isuiRunOut = true
        else
            return 
        end
        local params = {};
        params.city = self.m_cityId;
        params.building = self.m_buildingId;
        params.step_n = self.m_next_step;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_recapture"), http_request_method.GET, params,"private_city_recapture",true,true,true)
    end
    uiRunOut();
    game_data:setUserStatusDataBackup();
end


--[[--
    自动战斗
]]
function map_building_detail_scene.autoBattleCallFunc(self,battleData)
    local data = battleData:getNodeWithKey("data")
    local is_recaptured = data:getNodeWithKey("is_recaptured"):toBool();
    local battle = data:getNodeWithKey("battle");
    local battle_result = battle:getNodeWithKey("winer"):toInt();

    if battle_result < 5 then
        for i = 1,#self.m_card_anim_tab do 
            self.m_card_anim_tab[i]:release()
        end
        for i = 1,#self.m_card_anim_dfd_tab do
            self.m_card_anim_dfd_tab[i]:release()
        end
        local data = battleData:getNodeWithKey("data");
        local extra_rewards_json = data:getNodeWithKey("extra_rewards")
        local rewards_json = data:getNodeWithKey("rewards")
        local rewards,extra_rewards;
        if rewards_json then
            rewards = json.decode(rewards_json:getFormatBuffer())
        end
        if extra_rewards_json then
            extra_rewards = json.decode(extra_rewards_json:getFormatBuffer());
        end
        self.m_next_step = self.m_next_step + 1;
        if self.m_next_step >= self.m_fight_list_count then
            local function responseMethod(tag,gameData)
                game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                if not game_data:getReMapBattleFlag() then
                    game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,recoverBuildingId = self.m_buildingId,buildingId = self.m_buildingId,is_recaptured = is_recaptured,rewards=rewards,extra_rewards=extra_rewards});
                else
                    game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,recoverBuildingId = self.m_buildingId,buildingId = self.m_buildingId,is_recaptured = is_recaptured});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = self.m_cityId},"private_city_open")
        else
            self:refreshUi();
        end
    end
end

--[[--
    创建建筑的item
]]
function map_building_detail_scene.createBuildingItems(self,points_layer)
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
            if self.m_next_step ~= -1 then
                if i-1 < self.m_next_step then
                    -- fightItemSpr:setColor(ccc3(255,0,0));
                elseif i-1 > self.m_next_step then
                    -- fightItemSpr:setColor(ccc3(255,255,255));
                else
                    -- fightItemSpr:setColor(ccc3(0,255,0));
                    local stageName = fightItem:getNodeAt(0):toStr();
                    self.m_checkpoint_name_label:setString(stageName .. " " .. (self.m_next_step+1) .. "/" .. fight_list_count);
                    self.m_stageTableData.name = stageName
                end
            end
        end
        self.m_checkpoint_label:setString((self.m_next_step+1) .. "/" .. fight_list_count );
        self.m_checkpoint_label:setVisible(false);
        self.m_stageTableData.step = self.m_next_step+1;
        self.m_stageTableData.totalStep = fight_list_count;
    end
end
--[[--
    读取ccbi创建ui
]]
function map_building_detail_scene.createUi(self)
    game_scene:runPropertyBarAnim("outer_anim")
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function callBackFunc()
            if btnTag == 2 then --宝箱 
            elseif btnTag == 3 then --功能
            elseif btnTag == 11 then --撤退
                if self.m_next_step == 0 or game_data:getReMapBattleFlag() == false then
                    self:back();
                    return;
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self:back();
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    text = string_config.m_retreat_warning,      --可缺省
                }
                game_util:openAlertView(t_params);
            elseif btnTag == 12 then --背包
                game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "map_building_detail_scene",showIndex = 1});
                self:destroy();
            elseif btnTag == 13 then --队伍
                game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="map_building_detail_scene"});
                self:destroy();
            elseif btnTag == 14 then--自动战斗
                self.m_autoFlag = true;
                self:enterBattleScene();
            elseif btnTag == 100 then--装备
                game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "map_building_detail_scene",showIndex= 1});
                self:destroy();
            end
        end
        self:sendChangedData(callBackFunc);
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local function onNormalBtnClick( target,event ) --向前
        local function callBackFunc()
            self.m_autoFlag = false;
            self:enterBattleScene();
        end
        self:sendChangedData(callBackFunc);
    end
    ccbNode:registerFunctionWithFuncName("onNormalBtnClick",onNormalBtnClick);
    ccbNode:openCCBFile("ccb/ui_map_building_detail.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")
    self:initAdjustmentFormationTouch(self.m_formation_layer);
    self.m_points_layer = ccbNode:layerForName("m_points_layer")
    --local m_normal_node = ccbNode:nodeForName("m_normal_node")
    self.m_checkpoint_name_label = ccbNode:labelTTFForName("m_checkpoint_name_label");
    self.m_checkpoint_label = ccbNode:labelTTFForName("m_checkpoint_label");
    self.m_background_node = ccbNode:nodeForName("m_background_node");
    -- self.m_move_ndoe = ccbNode:nodeForName("m_move_ndoe");
    self.m_backgroundup_node = ccbNode:nodeForName("m_backgroundup_node");

    self.m_building_node = ccbNode:nodeForName("m_building_node");
    self.m_building_name = ccbNode:labelTTFForName("m_building_name");
    self.m_introduction_label = ccbNode:labelTTFForName("m_introduction_label");
    --self.m_building_detal_layer = ccbNode:layerColorForName("m_building_detal_layer");
    self.m_reward_label = ccbNode:labelTTFForName("m_reward_label");
    self.m_advance_btn = ccbNode:controlButtonForName("m_advance_btn");
    self.m_auto_battle_btn = ccbNode:controlButtonForName("m_auto_battle_btn");
    self.m_formation_btn = ccbNode:controlButtonForName("m_formation_btn");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn");

    if game_guide_controller:getFormationGuideIndex() == 1 then
        game_guide_controller:setFormationGuideIndex(2);
        game_scene:addGuidePop({tempNode = self.m_formation_btn})
    end
    self.m_auto_battle_btn:setVisible(false);
    self.m_ccbNode = ccbNode;
    game_guide_controller:gameGuide("show","1",8,{tempNode = self.m_advance_btn})
    -- self:initLayerTouch(self.m_points_layer);
    self.m_advance_btn:setOpacity(0);
    local mAnimNode = game_util:createUniversalAnim({animFile = "anim_fight",actionName = "impact",loopFlag = true});
    if mAnimNode then
        local pX,pY = self.m_advance_btn:getPosition();
        mAnimNode:setPosition(ccp(pX, pY))
        self.m_advance_btn:getParent():addChild(mAnimNode,1000,1000);
    end
    return ccbNode;
end


function map_building_detail_scene.sendChangedData(self,callBackFunc)
    if self.m_changeFlag == true or self.m_selFormationId ~= self.m_currentFormationId then
        local function responseMethod(tag,gameData)
            if gameData ~= nil then
                local data = gameData:getNodeWithKey("data");
                game_data:setTeamByJsonData(data:getNodeWithKey("alignment"));
                game_data:setFormationDataByJsonData(data:getNodeWithKey("formation"));
                game_data:setEquipPosDataByJsonData(data:getNodeWithKey("equip_pos"));
                game_data:setAssistantByJsonData(data:getNodeWithKey("assistant"));
                game_data:setGemPosDataByJsonData(data:getNodeWithKey("gem_pos"));
            end
            callBackFunc();
        end
        -- align_1=1_2&align_2=3_4
        local teamTable = game_data:getTeamData();
        local prarms = "align_1=";
        for k = 1,5 do
            if teamTable[k] == nil then
                prarms = prarms .. "-1" .. (k == 5 and "" or "_")
            else
                prarms = prarms .. teamTable[k] .. (k == 5 and "" or "_")
            end
        end
        prarms = prarms .. "&align_2="
        for k = 6,10 do
            if teamTable[k] == nil then
                prarms = prarms .. "-1" .. (k == 10 and "" or "_") 
            else
                prarms = prarms .. teamTable[k] .. (k == 10 and "" or "_") 
            end
        end 
        local equipPosData = game_data:getEquipPosData();
        for i=1,10 do
            cclog(" i ================= " .. i)
            table.foreach(equipPosData[tostring(i-1)],print)
            if i < 6 then
                prarms = prarms .. "&equip_1" .. i .. "="
            else
                prarms = prarms .. "&equip_2" .. (i-5) .. "="
            end
            for k,v in pairs(equipPosData[tostring(i-1)]) do
                prarms = prarms .. v .. (k == 4 and "" or "_")
            end
        end
        local gemPosData = game_data:getGemPosData();
        for i=1,10 do
            -- cclog(" i ================= " .. i)
            -- table.foreach(gemPosData[tostring(i-1)],print)
            if i < 6 then
                prarms = prarms .. "&gem_1" .. i .. "="
            else
                prarms = prarms .. "&gem_2" .. (i-5) .. "="
            end
            for k,v in pairs(gemPosData[tostring(i-1)]) do
                prarms = prarms .. v .. (k == 4 and "" or "_")
            end
        end
        prarms = prarms .. "&formation=" .. self.m_selFormationId;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_set_alignment"), http_request_method.GET, prarms,"cards_set_alignment")
    else
        callBackFunc();
    end
end

--[[--
    触摸
]]
function map_building_detail_scene.initLayerTouch(self,touch_layer)
    local tempItem,selItem,realPos,tag,selCardId;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        selCardId = nil;
        realPos = self.m_move_ndoe:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_touchCardTab) do
            tempItem = v.heroAnimNode
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                selCardId = v.cardId;
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        realPos = self.m_move_ndoe:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            cclog("heor on click -----------------------------")
            local itemData,_ = game_data:getCardDataById(selCardId);
            if itemData then
                local function callBack(typeName)
                    typeName = typeName or ""
                    if typeName == "refresh" then
                        
                    end
                end
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
            end
        end
        tempItem = nil;
        tag = nil;
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
    touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,false)
    touch_layer:setTouchEnabled(true)
end

local formationPosTab = {{key = "position_a",x = 0.33,y = 0.5 },
                         {key = "position_b",x = 0.28,y = 0.35},
                         {key = "position_c",x = 0.23,y = 0.2 },
                         {key = "position_d",x = 0.18, y = 0.5 },
                         {key = "position_e",x = 0.13,y = 0.35},
                         {key = "position_f",x = 0.08, y = 0.2 }};

--[[--
    刷新ui
]]
function map_building_detail_scene.refreshUi(self)
    for k,v in pairs(self.m_card_anim_tab) do
        v:release();
    end
    for k,v in pairs(self.m_card_anim_dfd_tab) do
        v:release();
    end
    self.m_card_anim_tab = {};
    self.m_card_anim_dfd_tab = {};
    self.m_touchCardTab = {};
    -- the changed by yock on 2014,4,1
    self:initTeamFormation(self.m_formation_layer);
    self.m_points_layer:removeAllChildrenWithCleanup(true);
    self.m_move_ndoe:removeAllChildrenWithCleanup(true);
    self:createBuildingItems(self.m_points_layer);
    local winSize = CCDirector:sharedDirector():getWinSize();
    local formationData = game_data:getFormationData();
    cclog("formationData.current ==" .. formationData.current);
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(formationData.current));
    local iValue = nil;
    local tempTag = 1;
    local tempIndex = 0;
    local lookIcon,tempNameBg,nameLabel,pX,pY;
    for i = 1,#formationPosTab do
        local formationPosTabItem = formationPosTab[i];
        local posNode = self.m_ccbNode:spriteForName("m_pos_" .. i)
        posNode:setAnchorPoint(ccp(0.5,0));
        pX,pY = winSize.width*formationPosTabItem.x,winSize.height*formationPosTabItem.y
        posNode:setAnchorPoint(ccp(0.5, 0));
        posNode:setPosition(ccp(pX,pY - 10))
    end
    -- local enemyCfg = getConfig(game_config_field.map_fight)
    local map_fight_and_enemy = game_data:getDataByKey("map_fight_and_enemy") or {}
    local enemyCfg = map_fight_and_enemy.map_fight or {}
    local enemy_detail_cfg = map_fight_and_enemy.enemy_detail or {}
    local mapTitleCfg = getConfig(game_config_field.map_title_detail)
    local buildingCfgData = mapTitleCfg:getNodeWithKey(tostring(self.m_buildingId))
    local index = "0"
    local fight_list = buildingCfgData:getNodeWithKey("fight_list")
    if fight_list and not fight_list:isEmpty() and fight_list:getNodeCount() > 0 then
        local fightItem = fight_list:getNodeAt(self.m_next_step)
        if fightItem then
            index = fightItem:getNodeAt(1):toStr()
        end
    end
    game_data:setCurrentFightId(index);
    --cclog("index->"..index)
    local mapEnemyCfg = enemyCfg[index]
    -- local enemy_detail_cfg = getConfig(game_config_field.enemy_detail);
    local animDefIndex = 1;
    if mapEnemyCfg then
        self.m_stageTableData.fight_boss = tostring(mapEnemyCfg.fight_boss)
        local formationId = mapEnemyCfg.formation_id
        itemCfg = formationConfig:getNodeWithKey(tostring(formationId));
        for i = 1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            local iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue > 0 then
                local position = mapEnemyCfg["position"..iValue] or {}
                local positionCount = #position
                cclog("positionCount ==================== " .. positionCount)
                if positionCount == 1 then
                    enemyIndex = tostring(position[1])
                    -- local heroCfg = enemy_detail_cfg:getNodeWithKey(enemyIndex);
                    -- local heroCfg = game_util:getEnemyCfgByStageIdAndEnemyId(nil,enemyIndex)
                    local heroCfg = enemy_detail_cfg[enemyIndex]
                    cclog("enemyIndex ==================== " .. enemyIndex)
                    if heroCfg then
                        local ainmFile = tostring(heroCfg.animation)
                        local animNode = game_util:createIdelAnim(ainmFile,0,nil,heroCfg);
                        animNode:setAnchorPoint(ccp(0.5,0));
                        animNode:setPosition(ccp(winSize.width * (1 - formationPosTabItem.x),winSize.height * formationPosTabItem.y))
                        animNode:setFlipX(true)
                        local function animEnd(animNode,theId,lableName)
                            animNode:playSection(lableName);
                        end
                        animNode:registerScriptTapHandler(animEnd);
                        self.m_move_ndoe:addChild(animNode);
                        cclog("enemyIndex->"..(enemyIndex + 99))
                        animDefIndex = animDefIndex + 1;
                    end
                elseif positionCount > 1 then
                    local animNode = game_util:createUnknowIdelAnim();
                    animNode:setAnchorPoint(ccp(0.5,0));
                    animNode:setPosition(ccp(winSize.width * (1 - formationPosTabItem.x),winSize.height * formationPosTabItem.y))
                    animNode:setFlipX(true)
                    self.m_move_ndoe:addChild(animNode);
                    animDefIndex = animDefIndex + 1;
                end
            end
        end
    else
        -- game_util:addMoveTips({text = "建筑id为" .. tostring(self.m_buildingId) .. "的fight_list配置错误"});
    end
end



--[[--
    
]]
function map_building_detail_scene.getTeamCardDataByPos(self,posIndex)
    return game_data:getCardDataById(self.m_tempTeamData[posIndex])
end
function map_building_detail_scene.createCardAnimByPosIndex(self,posIndex)
    local animNode = nil;
    local heroData,heroCfg = self:getTeamCardDataByPos(posIndex)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
        end
    end
    return animNode;
end
--[[--
    初始化编队信息
]]
function map_building_detail_scene.initTeamFormation(self,formation_layer)
    local level = game_data:getUserStatusDataByKey("level");
    local itemIcon = nil;
    local headIconSpr = nil;
    local tempLock = nil;
    local character_detail_cfg = getConfig("character_detail");
    local tempLockIndex,selLevel = -1,100;
    for i=1,6 do
        itemIcon = self.m_ccbNode:spriteForName("m_pos_" .. i)
        formation_layer:reorderChild(itemIcon,-1000 + (i - 1)%3)
        local headIconBgSize = itemIcon:getContentSize();
        headIconSpr = itemIcon:getChildByTag(1)
        if headIconSpr then
            headIconSpr:removeFromParentAndCleanup(true);
        end
        headIconSpr = itemIcon:getChildByTag(2)
        if headIconSpr then
            headIconSpr:removeFromParentAndCleanup(true);
        end
        tempLock = itemIcon:getChildByTag(10);
        if self.m_openTab[i] == 1 then
            tempLock:setVisible(false);
        else
            itemIcon:setVisible(false);
        end
        local animNode = self:createCardAnimByPosIndex(i)
        if animNode then
            animNode:setPosition(ccp(headIconBgSize.width*0.5,10));
            itemIcon:addChild(animNode,1,1);
        end
    end
end



--[[--
    初始化背景
]]
function map_building_detail_scene.createBackground( self,t_params )
    -- body
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
    local bgnameTemp = buildingCfgData:getNodeWithKey("background"):toStr();
    bgnameTemp = game_util:getResName(bgnameTemp);
    cclog("bgname =============== " .. bgnameTemp)
    self.m_backgroundName = bgnameTemp;
    local battleBg = CCSprite:create("battle_ground/"..bgnameTemp..".jpg")
    if battleBg == nil then
        bgnameTemp = "back_snow"--just for test
        battleBg = CCSprite:create("battle_ground/"..bgnameTemp..".jpg")
    end
    if battleBg == nil then
        battleBg = CCSprite:create("battle_ground/"..bgnameTemp..".png")
    end
    return battleBg;
end


--[[--
    初始化
]]
function map_building_detail_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cityId = t_params.cityId;
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
            -- self.m_next_step = recapture_log_item[#recapture_log_item] + 1;
            self.m_next_step = #recapture_log_item
        end
    end
    cclog("tostring(self.m_buildingId) =============" .. tostring(self.m_buildingId) .. "; self.m_next_step ==" .. self.m_next_step);
    self.m_card_anim_tab = {};
    self.m_card_anim_dfd_tab = {};
    self.m_stageTableData = {};
    self.m_bgMusic = t_params.bgMusic or self.m_bgMusic;
    cclog("self.m_bgMusic =============== " .. tostring(self.m_bgMusic))
    game_sound:playMusic(self.m_bgMusic,true);
    self.m_autoFlag = false;
    self.m_touchCardTab = {};


    self.m_changeFlag = false;
    self.m_tempTeamData = {};
    self.m_tempEquipPosData = {};
    self.m_tempGemPosData = {};

    local formationData = game_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    cclog("self.m_currentFormationId=====" .. self.m_currentFormationId);
    self.m_selFormationId = self.m_currentFormationId;

    local teamData = game_data:getTeamData();
    local tempEquipPosData = game_data:getEquipPosData()
    local tempGemPosData = game_data:getGemPosData();
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

    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
end

------------------------------------------------------------------------------------------------------------

function map_building_detail_scene.getExchangeTeamDataByTwoPosFlag(self,posIndex1,posIndex2)
    local cardNumData = game_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    local returnValue = 0;
    if self.m_openTab[posIndex1] == 0 or self.m_openTab[posIndex2] == 0 then
        returnValue = 5;
        game_util:addMoveTips({text = string_config:getTextByKey("m_team_pos_no_open")});
        return returnValue;
    end
    local count1,count2 = 0,0;
    local cardId = nil;
    for i=1,6 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count1 = count1 + 1;
        end
    end
    for i=7,9 do
        cardId = self.m_tempTeamData[i]
        if cardId ~= "-1" then
            count2 = count2 + 1;
        end
    end
    cclog("posIndex1 = " .. posIndex1 .. " ; posIndex2 = " .. posIndex2)
    if posIndex1 > 0 and posIndex1 < 10 and posIndex2 > 0 and posIndex2 < 10 then
        if posIndex1 < 7 and posIndex2 < 7 then--主站

            returnValue = 0;
        elseif posIndex1 > 6 and posIndex2 > 6 then--替补
            returnValue = 0;
        elseif posIndex1 > 6 and posIndex2 < 7 then--替补主站
            if self.m_tempTeamData[posIndex1] ~= "-1" and self.m_tempTeamData[posIndex2] == "-1" then
                count1 = count1 + 1;
                count2 = count2 - 1;
            end
        elseif posIndex1 < 7 and posIndex2 > 6 then--主站替补
            if self.m_tempTeamData[posIndex1] ~= "-1" and self.m_tempTeamData[posIndex2] == "-1" then
                count1 = count1 - 1;
                count2 = count2 + 1;
            end
        else
            returnValue = 1--
        end
    end
    
    if count1 ~= 0 then
        if count1 > maxCount1 or count1 > 5 then
            returnValue = 2;
            game_util:addMoveTips({text = string_config:getTextByKey("m_master_is_max")});
        elseif count2 > maxCount2 then
            returnValue = 3;
            game_util:addMoveTips({text = string_config:getTextByKey("m_substitute_is_max")});
        end
    else
        returnValue = 4;
        game_util:addMoveTips({text = string_config:getTextByKey("m_master_at_least_one")});
    end
    cclog("getExchangeTeamDataByTwoPosFlag == returnValue =" .. returnValue .. " ; count1 == " .. count1 .. " ; count2 = " .. count2)
    return returnValue;
end




function map_building_detail_scene.exchangeTeamDataByTwoPos(self,posIndex1,posIndex2)
    self.m_tempTeamData[posIndex1],self.m_tempTeamData[posIndex2] = self.m_tempTeamData[posIndex2],self.m_tempTeamData[posIndex1]
    self.m_tempEquipPosData[posIndex1],self.m_tempEquipPosData[posIndex2] = self.m_tempEquipPosData[posIndex2],self.m_tempEquipPosData[posIndex1]
    self.m_tempGemPosData[posIndex1],self.m_tempGemPosData[posIndex2] = self.m_tempGemPosData[posIndex2],self.m_tempGemPosData[posIndex1]
    self:setTeamFormationData();
end

function map_building_detail_scene.setTeamFormationData(self)
    local formationId = 1;
    local tempTeamData = {};
    local tempEquipPosData = {};
    local tempGemPosData = {};
    local emptyFlag = false;
    local tempCardId = nil;
    local tempEquipItem,tempGemItem = nil,nil;
    local tempCount = 1;
    for i=1,9 do
        tempCardId = self.m_tempTeamData[i]
        tempEquipItem = self.m_tempEquipPosData[i];
        tempGemItem = self.m_tempGemPosData[i];
        if i < 7 then
            if tempCardId == "-1" and emptyFlag == false then
                emptyFlag = true;
                formationId = i;
            else
                if tempCount < 6 then
                    tempTeamData[tempCount] = tempCardId
                    tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
                    tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
                    tempCount = tempCount + 1;
                end
            end
        else
            tempTeamData[tempCount] = tempCardId
            tempEquipPosData[tostring(tempCount-1)] = util.table_copy(tempEquipItem);
            tempGemPosData[tostring(tempCount-1)] = util.table_copy(tempGemItem);
            tempCount = tempCount + 1;
        end
    end

    for i=9,10 do
        tempTeamData[i] = "-1";
        tempEquipPosData[tostring(i-1)] = {"0","0","0","0"}
        tempGemPosData[tostring(i-1)] = {"0","0","0","0"}
    end
    -- table.foreach(tempTeamData,print)
    -- cclog("-------------- equip -----------------")
    -- for k,v in pairs(tempEquipPosData) do
    --     cclog("k ============ " .. k)
    --     table.foreach(v,print)
    -- end
    -- cclog("-------------- equip -----------------")
    cclog("formationId ================== " .. formationId)
    self.m_selFormationId = formationId;
    game_data:setTeamData(tempTeamData);
    game_data:setEquipPosData(tempEquipPosData);
    game_data:setGemPosData(tempGemPosData);
end

function map_building_detail_scene.initAdjustmentFormationTouch(self,formation_layer)
    local selItem = nil;
    local beganItem = nil;
    local endItem = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local realPos = nil;
    local tempPosIndex = nil;
    local function onTouchBegan(x, y)
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- CCTOUCHBEGAN event must return true
        for tag = 1,6 do
            beganItem = self.m_ccbNode:spriteForName("m_pos_" .. tag)
            if beganItem and beganItem:boundingBox():containsPoint(realPos) then
                tempPosIndex = tag;
                selItem = self:createCardAnimByPosIndex(tempPosIndex)
                if selItem == nil then break end
                local pX,pY = beganItem:getPosition();
                selItem:setPosition(ccp(pX,pY));
                -- selItem:setColor(ccc3(128,128,128));
                formation_layer:addChild(selItem,11,11);
                selItem:setVisible(false);
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        
        -- cclog("onTouchMoved: %0.2f, %0.2f", x - touchBeginPoint.x, y - touchBeginPoint.y)
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if selItem then
                realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                selItem:setPosition(realPos);
                selItem:setVisible(true);
            end
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        --cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        -- self:setPositionBg(self.m_posIndex,true);
        if not touchMoveFlag and tempPosIndex then
            -- self:addTeamHeroPop(tempPosIndex);
        end
        if selItem and touchMoveFlag then
            for endTag = 1,6 do
                endItem = self.m_ccbNode:spriteForName("m_pos_" .. endTag)
                if endItem and endItem:isVisible() and endItem:boundingBox():containsPoint(realPos) then
                    local beganTag = beganItem:getTag();
                    if endTag ~= beganTag and self:getExchangeTeamDataByTwoPosFlag(beganTag,endTag) == 0 then
                        cclog("exchange ----------beganTag = " .. beganTag .. " ; endTag = " .. endTag);
                        self:exchangeTeamDataByTwoPos(beganTag,endTag);
                        self.m_changeFlag = true;
                        local bgSize = endItem:getContentSize();
                        local headIconSpr = beganItem:getChildByTag(1)
                        if headIconSpr then
                            headIconSpr:removeFromParentAndCleanup(true)
                        end
                        local animNode = self:createCardAnimByPosIndex(beganTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,10));
                            beganItem:addChild(animNode,1,1)
                        --     self:setPositionBg(beganTag,true);
                        -- else
                        --     self:setPositionBg(beganTag,false);
                        end
                        local headIconSpr = endItem:getChildByTag(1)
                        if headIconSpr then
                            headIconSpr:removeFromParentAndCleanup(true)
                        end
                        local animNode = self:createCardAnimByPosIndex(endTag)
                        if animNode then
                            animNode:setPosition(ccp(bgSize.width*0.5,10));
                            endItem:addChild(animNode,1,1)
                        end
                        self.m_posIndex = endTag;

                    end
                    break;
                end
            end
        end
        if selItem then
            selItem:removeFromParentAndCleanup(true);
            selItem = nil;
        end
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
        tempPosIndex = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+131)
    formation_layer:setTouchEnabled(true)
end




-----------------------------------------------------------------------------------------------------------------------



--[[--
    创建ui入口并初始化数据
]]--
function map_building_detail_scene.create(self,t_params)
    game_scene:runPropertyBarAnim("outer_anim")
    self:init(t_params);
    local rootScene = CCScene:create();
    --载入进入战斗loading时需要的图片
    --CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_battle_xian.plist");
    ------------------------------
    local bgsp = self:createBackground();
    local winSize = CCDirector:sharedDirector():getWinSize();
    if(bgsp ~= nil)then
        bgsp:setPosition(ccp(winSize.width / 2,winSize.height / 2))
        rootScene:addChild(bgsp);
    end
    self.m_move_ndoe = CCNode:create();
    rootScene:addChild(self.m_move_ndoe);
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return map_building_detail_scene;