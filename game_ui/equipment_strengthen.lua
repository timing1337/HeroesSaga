--- 装备强化

local equipment_strengthen = {
    m_anim_node = nil,--动画节点
    m_selEquipId = nil,--选中的heroid
    m_ok_btn = nil,
    m_canStrengthenFlag = nil,
    m_tips_spr_1 = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needMoney = nil,
    m_back_btn = nil,
    m_level_label = nil,
    m_ability1_label = nil,
    m_ability2_label = nil,
    m_level_new_label = nil,
    m_ability1_new_label = nil,
    m_ability2_new_label = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_curPage = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selFilterSortType = nil,
    m_cost_metal_label = nil,
    m_metal_total_label = nil,
    m_selEquipDataTab = nil,
    m_guildNode = nil,
    m_upFlag = nil,
    m_levelUpValue = nil,
    m_cost_metal = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    curr_need_metal = nil,
    m_itemFirstShowFlag = nil,
    m_realLevelUpValue = nil,
    m_openType = nil,
    m_tableView = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_quick_ok_btn = nil,
    m_material_node_tab = nil,
    m_material_layer = nil,
    m_bottom_node = nil,
};

--[[--
    销毁ui
]]
function equipment_strengthen.destroy(self)
    -- body
    cclog("-----------------equipment_strengthen destroy-----------------");
    self.m_anim_node = nil;
    self.m_selEquipId = nil;
    self.m_ok_btn = nil;
    self.m_canStrengthenFlag = nil;
    self.m_tips_spr_1 = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needMoney = nil;
    self.m_back_btn = nil;
    self.m_level_label = nil;
    self.m_ability1_label = nil;
    self.m_ability2_label = nil;
    self.m_level_new_label = nil;
    self.m_ability1_new_label = nil;
    self.m_ability2_new_label = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selFilterSortType = nil;
    self.m_cost_metal_label = nil;
    self.m_metal_total_label = nil;
    self.m_selEquipDataTab = nil;
    self.m_guildNode = nil;
    self.m_upFlag = nil;
    self.m_levelUpValue = nil;
    self.m_cost_metal = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.curr_need_metal = nil;
    self.m_itemFirstShowFlag = nil;
    self.m_realLevelUpValue = nil;
    self.m_openType = nil;
    self.m_tableView = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_quick_ok_btn = nil;
    self.m_material_node_tab = nil;
    self.m_material_layer = nil;
    self.m_bottom_node = nil;
end

--[[--
    返回
]]
function equipment_strengthen.back(self,backType)
    local function callBackFunc()
        if backType == "back" then
            local battleType = game_data:getBattleType();
            if self.m_openType == "game_battle_scene" and battleType == "map_building_detail_scene" then
                local function responseMethod(tag,gameData)
                    game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                    game_scene:enterGameUi("map_building_detail_scene",{cityId = game_data:getSelCityId(),buildingId = game_data:getSelBuildingId(),gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
            elseif self.m_openType == "game_battle_scene" and battleType == "active_map_building_detail_scene" then
                local activeChapterId = game_data:getSelActiveDataByKey("activeChapterId")
                local activeId = game_data:getSelActiveDataByKey("activeId");
                local nextStep = game_data:getSelActiveDataByKey("nextStep");
                game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = activeChapterId,activeId = activeId,next_step = nextStep});
            else
                local function endCallFunc()
                    self:destroy();
                end
                game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
            end
        end
    end
    self:onSureFunc2(callBackFunc);
end
--[[--
    读取ccbi创建ui
]]
function equipment_strengthen.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if game_data.getGuideProcess and game_data:getGuideProcess() == "guide_second_start_2_39" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(56) end -- 新手引导39  点击返回  -- 步骤56
                if game_data.setGuideProcess then game_data:setGuideProcess("guide_statistics_end") end
            end
            self:back("back");
        elseif btnTag == 101 then--开始强化
            local id = game_guide_controller:getCurrentId();
            if id == 38 then
                if game_util and game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(55) end  -- 新手引导3步 点击强化 -- 步骤55
                self:refreshEquipInfo(self.m_selEquipId,true);
                self:gameGuide("drama","2",39)
            else
                -- 不要间隔
                -- self.m_root_layer:setTouchEnabled(true);
                -- local m_shared = 0;
                -- function tick( dt )
                --     self.m_root_layer:setTouchEnabled(false);
                --     scheduler.unschedule(m_shared)
                -- end
                -- m_shared = scheduler.schedule(tick, 0.33, false)
                self:refreshEquipInfo(self.m_selEquipId,true);
            end
        elseif btnTag == 102 then--一键强化
            local function responseMethod(tag,gameData)
                if gameData == nil then
                    self.m_levelUpValue = 0;
                    self.m_realLevelUpValue = 0;
                    return;
                end
                local data = gameData:getNodeWithKey("data")
                game_data:setFactoryDataByJsonData(data);
                self:refreshTips()
                self:refreshEquipTableView()
                self:refreshCombatLabel();

                --播放动画
                self:broadcardAnim(data)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("all_equip_levelup_auto"), http_request_method.GET, {},"all_equip_levelup_auto",true,true)
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            cclog("btnCallBack ===========btnTag===" .. btnTag)
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:equipSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equipment_strengthen.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_level_label = ccbNode:labelTTFForName("m_level_label")
    self.m_ability1_label = ccbNode:labelTTFForName("m_ability1_label")
    self.m_ability2_label = ccbNode:labelTTFForName("m_ability2_label")
    self.m_level_new_label = ccbNode:labelTTFForName("m_level_new_label")
    self.m_ability1_new_label = ccbNode:labelTTFForName("m_ability1_new_label")
    self.m_ability2_new_label = ccbNode:labelTTFForName("m_ability2_new_label")
    self.m_ability1_name_label = ccbNode:labelTTFForName("m_ability1_name_label")
    self.m_ability2_name_label = ccbNode:labelTTFForName("m_ability2_name_label")
    self.m_ability1_name_label:setString(string_helper.ccb.file64);
    self.m_ability2_name_label:setString(string_helper.ccb.file63);
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label")
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label")

    self.m_quick_ok_btn = ccbNode:controlButtonForName("m_quick_ok_btn")--一键强化

    local m_mate_tips = nil;
    local m_material_node,m_mate_cost_label,m_mate_total_label,parentNode = nil;
    for i=1,3 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_mate_cost_label = ccbNode:labelTTFForName("m_mate_cost_label_" .. i)
        m_mate_total_label = ccbNode:labelTTFForName("m_mate_total_label_" .. i)
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_mate_cost_label = m_mate_cost_label,m_mate_total_label = m_mate_total_label,parentNode = parentNode}
    end

    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    --game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    --game_util:setControlButtonTitleBMFont(self.m_quick_ok_btn)

    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text16)
    game_util:setCCControlButtonTitle(self.m_quick_ok_btn,string_helper.ccb.text162)

    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    game_util:createScrollViewTips2(self.m_scroll_view_tips,{"zb_miaoshu.png","zb_miaoshu_1.png"});
    local m_combat_node = ccbNode:nodeForName("m_combat_node");
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);
    self.m_material_layer = ccbNode:layerForName("m_material_layer")
    self:initMaterialLayerTouch(self.m_material_layer);
    self.m_bottom_node = ccbNode:nodeForName("m_bottom_node")
    self.m_material_layer:setVisible(false)
    self.m_bottom_node:setPositionY(90)

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text137)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text138)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text139)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text140)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text152)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text160)
    return ccbNode;
end

--[[--
    
]]
function equipment_strengthen.initMaterialLayerTouch(self,formation_layer)
    local touchMoveFlag = nil;
    local touchBeginPoint = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        touchMoveFlag = false;
        touchBeginPoint = {x = x,y = y}
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        if touchMoveFlag == false then
            local realPos = formation_layer:convertToNodeSpace(ccp(x,y));
            for k,v in pairs(self.m_material_node_tab) do
                local tempItem = v.parentNode;
                if tempItem:boundingBox():containsPoint(realPos) then
                    local tag =  v.m_material_node:getTag();
                    cclog("on click btn ================ tag = " .. tag)
                    if tempData then
                        if tempData.materialType == 6 then
                            game_scene:addPop("game_item_info_pop",{itemId = tempData.materialId,openType = 2})
                        elseif tempData.materialType == 7 then
                            local equipData = {lv = 1,c_id = tempData.materialId,id = -1,pos = -1}
                            game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                        end
                    end
                    break;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end

--[[
    一键强化动画
]]
function equipment_strengthen.broadcardAnim(self,data)
    local _client_cache_update = data:getNodeWithKey("_client_cache_update")
    local equip = _client_cache_update:getNodeWithKey("equip")
    local _equip = equip:getNodeWithKey("_equip")
    local update = _equip:getNodeWithKey("update")
    game_scene:addPop("equip_streng_anim_pop",{equipData = json.decode(update:getFormatBuffer())});
end
--[[--

]]
function equipment_strengthen.onSureFunc2(self,callBackFunc)
    if self.m_selEquipId == nil or self.m_realLevelUpValue <= 0 or self.m_itemFirstShowFlag == true then
        if callBackFunc then
            callBackFunc();
        end
        return;
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_levelUpValue = 0;
                self.m_realLevelUpValue = 0;
                -- self:refreshEquipInfo(self.m_selEquipId);
                return;
            end
            if callBackFunc then
                callBackFunc();
            end
            local data = gameData:getNodeWithKey("data")
            game_data:setFactoryDataByJsonData(data);
            self.m_upFlag = true;
            -- self:refreshUi();
            -- game_sound:playUiSound("up_success")
            self:refreshSortTabBtn(self.m_selSortIndex);
            self:refreshByType(self.m_showType);
            game_scene:removeGuidePop();
            self:refreshCombatLabel();
        end
        --magor=升级装备背包id lvs=需要升的等级
        local params = {}
        params.magor = self.m_selEquipId
        params.lvs = self.m_realLevelUpValue
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("factory_equip_levelup"), http_request_method.GET, params,"factory_equip_levelup",true,true)
    end
    sendRequest();
end

--[[--
    装备属性信息
]]
function equipment_strengthen.refreshEquipInfo(self,equipId,addLvFlag)
    if addLvFlag == nil then addLvFlag = false end
    self.m_cost_metal = 0;
    self.m_canStrengthenFlag = false;
    self.m_selEquipId = equipId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    game_util:setCostLable(self.m_cost_metal_label,0,0);
	if equipId ~= nil and equipId ~= "-1" then
        local tempLevelUpValue = self.m_levelUpValue
        if addLvFlag then
            -- tempLevelUpValue = tempLevelUpValue + 1;
            self.m_itemFirstShowFlag = false;
        else
            self.m_itemFirstShowFlag = true;
            self.m_realLevelUpValue = 0;
        end
        local userLevel = game_data:getUserStatusDataByKey("level") or 1;
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        -- local ccbNode = game_util:createEquipItemByCCB(itemData);
        -- self.m_anim_node:addChild(ccbNode,10,10);
        local quality = itemCfg:getNodeWithKey("quality"):toStr();
        local equip_strongthen = getConfig(game_config_field.equip_strongthen);
        local max_level = math.min(equip_strongthen:getNodeCount(),userLevel)
        local level = itemData.lv
        local upLv = level+tempLevelUpValue+1;
        local errorFlag = false;
        if upLv > max_level then
            errorFlag = true;
            tempLevelUpValue = max_level - level;
            upLv = max_level;
            game_util:addMoveTips({text = string_config.m_equip_lv_is_max});
            self.curr_need_metal = 0
            local cost_metal = 0;
            if tempLevelUpValue > 0 then
                for i=level,upLv-1 do
                    local equip_strongthen_item = equip_strongthen:getNodeWithKey(tostring(i));
                    local cost_coefficient = equip_strongthen_item:getNodeWithKey("quality" .. tostring(quality)):toInt()*0.01;
                    if cost_coefficient == nil then cost_coefficient = 1 end
                    cost_metal = math.floor(cost_metal + equip_strongthen_item:getNodeWithKey("metal"):toInt()*cost_coefficient)
                end
            end
            self.m_cost_metal = cost_metal;
        else
            local cost_metal = 0;
            self.curr_need_metal = 0;
            cclog("level = " .. level .. " ; upLv == " .. upLv)
            for i=level,upLv-1 do
                local equip_strongthen_item = equip_strongthen:getNodeWithKey(tostring(i));
                local cost_coefficient = equip_strongthen_item:getNodeWithKey("quality" .. tostring(quality)):toInt()*0.01;
                if cost_coefficient == nil then cost_coefficient = 1 end
                cost_metal = math.floor(cost_metal + equip_strongthen_item:getNodeWithKey("metal"):toInt()*cost_coefficient)
                if i == upLv-1 then
                    self.curr_need_metal = math.floor(equip_strongthen_item:getNodeWithKey("metal"):toInt()*cost_coefficient)
                end
            end
            local totalMetal = game_data:getUserStatusDataByKey("metal") or 0;
            self.m_cost_metal = cost_metal;
            if cost_metal > totalMetal then
                if not errorFlag then
                    -- game_util:addMoveTips({text = string.format(string_config.m_metal_not_enough,self.curr_need_metal)});
                    --换成统一的提示
                    local t_params = 
                    {
                        m_openType = 6,
                        m_call_func = function()
                            self:refreshTips()
                        end
                    }
                    game_scene:addPop("game_normal_tips_pop",t_params)
                end
            else
                self.m_levelUpValue = math.min(max_level - level,upLv - level);
                if not self.m_itemFirstShowFlag then
                    game_sound:playUiSound("up_success")
                end
            end
            cclog("self.m_levelUpValue == " .. self.m_levelUpValue .. " ; tempLevelUpValue == " .. tempLevelUpValue)
        end
        local function setValueFunc()
            local tempLv = level+tempLevelUpValue
            self.m_realLevelUpValue = math.min(max_level - level,tempLevelUpValue);
            cclog("self.m_realLevelUpValue ====== " .. self.m_realLevelUpValue)
            local attrName1,value1,attrName2,value2 = game_util:getEquipAttributeValue(itemCfg,tempLv);
            self.m_ability1_name_label:setString(attrName1);
            self.m_ability2_name_label:setString(attrName2);
            self.m_ability1_label:setString("+" .. value1);
            self.m_ability2_label:setString("+" .. value2);
            self.m_level_label:setString(tostring(tempLv)); 
            local attrName12,value12,attrName22,value22 = game_util:getEquipAttributeValue(itemCfg,upLv);
            game_util:setAttributeLable2(self.m_ability1_new_label,value1,value12,"+");
            game_util:setAttributeLable2(self.m_ability2_new_label,value2,value22,"+");
            game_util:setAttributeLable2(self.m_level_new_label,tempLv,upLv,"");
            local tempItemData = util.table_copy(itemData)
            tempItemData.lv = tempLv;
            local ccbNode = game_util:createEquipItemByCCB(tempItemData);
            self.m_anim_node:addChild(ccbNode,10,10);
        end
        setValueFunc();
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
	end
    self:refreshTips();
end

--[[--
    创建装备列表
]]
function equipment_strengthen.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount--totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < itemsCount then
                local tempId = tableData[index+1]
                local itemData,itemCfg = game_data:getEquipDataById(tempId);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                if self.m_selEquipId and self.m_selEquipId == tempId then
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                    self.m_selListItem = cell;
                end
                local id = game_guide_controller:getCurrentId();
                if id == 37 and self.m_guildNode == nil then
                    cell:setContentSize(itemSize);
                    self.m_guildNode = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = tableData[index+1]
            if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                local function callBackFunc()
                    self.m_levelUpValue = 0;
                    if self.m_selListItem then
                        local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(false);
                    end
                    self.m_selListItem = cell;
                    self.m_selEquipId = tempId
                    self.m_upFlag = false;
                    self:refreshEquipInfo(self.m_selEquipId);
                    self:refreshByType(2);
                    -- if index%2 == 0 then
                    --     self.m_material_layer:setVisible(false)
                    --     self.m_bottom_node:setPositionY(90)
                    -- else
                    --     self.m_material_layer:setVisible(true)
                    --     self.m_bottom_node:setPositionY(55)
                    -- end
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                    local id = game_guide_controller:getCurrentId();
                    if id == 37 then
                        if game_util and game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(54) end  -- 新手引导37步 选择一个装备 -- 步骤54
                        game_guide_controller:gameGuide("show","2",38,{tempNode = self.m_ok_btn})
                    end
                end
                self:onSureFunc2(callBackFunc);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    local tempTableView = TableViewHelper:create(params);
    -- if self.m_selEquipId then
    --     local posIndex = -1;
    --     for i=1,itemsCount do
    --         if tableData[i] == tostring(self.m_selEquipId) then
    --             posIndex = i-1;
    --             break;
    --         end
    --     end
    --     cclog("posIndex ===== " .. posIndex)
    --     if posIndex ~= -1 then
    --         local contentSize = tempTableView:getContentSize()
    --         if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
    --             tempTableView:setContentOffset(ccp(0,math.min(viewSize.height - contentSize.height + posIndex * itemSize.height,0)))
    --         end
    --     end
    -- end
    return tempTableView
end

--[[--
    刷新列表
]]
function equipment_strengthen.refreshEquipTableView(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    local id = game_guide_controller:getCurrentId();
    if id == 37 and self.m_guildNode then
        game_guide_controller:gameGuide("show","2",37,{tempNode = self.m_guildNode})
        self.m_tableView:setMoveFlag(false);
    end
end

--[[--

]]
function equipment_strengthen.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
    self:refreshEquipTableView()
end

--[[--
    刷新
]]
function equipment_strengthen.refreshByType(self,showType)
    cclog("refreshByType ==============" .. showType);
    self.m_showType = showType;

    if #self.m_selEquipDataTab == 0 then

    else

    end
    self:refreshTips();
end

--[[--
    刷新tips
]]
function equipment_strengthen.refreshTips(self)
    local totalMetal = (game_data:getUserStatusDataByKey("metal") or 0) - self.m_cost_metal + self.curr_need_metal
    cclog("self.m_cost_metal === " .. self.m_cost_metal .. " ; self.curr_need_metal == " .. self.curr_need_metal)
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_metal_total_label:setString(tostring(value .. unit));
    game_util:setCostLable(self.m_cost_metal_label,self.curr_need_metal,totalMetal);
end

--[[--
    刷新
]]
function equipment_strengthen.refreshCombatLabel(self)
    if self.m_tempCombatValue == nil then
        self.m_tempCombatValue = game_util:getCombatValue()
        self.m_combatNumberChangeNode:setCurValue(self.m_tempCombatValue,false);
    else
        local tempCombatValue = game_util:getCombatValue();
        local changeValue = tempCombatValue - self.m_tempCombatValue
        self.m_tempCombatValue = tempCombatValue;
        game_util:combatChangedValueAnim({combatNode = self.m_combatNumberChangeNode,currentValue = tempCombatValue,changeValue = changeValue});
    end
end

--[[--
    刷新ui
]]
function equipment_strengthen.refreshUi(self)
    self:refreshEquipInfo(self.m_selEquipId);
    self:refreshSortTabBtn(self.m_selSortIndex);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function equipment_strengthen.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selEquipId = t_params.selEquipId;
    self.m_showType = 1;
    self.m_needMoney = 0;
    self.m_curPage = 1;
    self.m_selFilterSortType = "";
    self.m_selEquipDataTab = {};
    self.m_upFlag = false;
    self.m_levelUpValue = 0;
    self.m_cost_metal = 0;
    local selSort = game_data:getEquipSortType();
    for k,v in pairs(EQUIP_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.curr_need_metal = 0;
    self.m_itemFirstShowFlag = true;
    self.m_openType = t_params.openType or "";
    self.m_material_node_tab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function equipment_strengthen.create(self,t_params)
    
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

function equipment_strengthen.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "2" and id == 39 then
            if game_data and game_data.setGuideProcess then game_data:setGuideProcess("guide_second_start_2_39") end
            game_scene:removeGuidePop();
            local function endCallFunc()
                -- game_guide_controller:gameGuide("send","2",39);
                game_guide_controller:gameGuide("show","2",39,{tempNode = self.m_back_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return equipment_strengthen;
