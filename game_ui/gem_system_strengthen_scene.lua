---  宝石强化

local gem_system_strengthen_scene = {
    m_skill_layer = nil,--技能父节点
    m_anim_node = nil,--动画节点
    m_selGemId = nil,--选中的heroid
    m_ok_btn = nil,
    m_currentSkillTable = nil,
    m_material_id_table = nil,
    m_autoSelectFlag = nil,
    m_canStrengthenFlag = nil,
    m_upGemLevelTable = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_hero_bg_btn = nil,
    m_material_node_tab = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_material_node = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needMetal = nil,
    m_curPage = nil,
    m_curPageMaterial = nil,
    m_cost_metal_label = nil,
    m_metal_total_label = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selGemDataBackupTab = nil,
    m_selFilterCardSortIndex = nil,
    m_status = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_guildNode = nil,
    m_quick_sel_btn = nil,
    m_showDataTable = nil,
    m_auto_add_btn = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
    m_skillBackupData = nil,
    m_openType = nil,
    m_sell_id = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_level_label_1 = nil,
    m_level_label_2 = nil,
    m_exp_bar_bg = nil,
    m_up_detail_label = nil,
};
--[[--
    销毁ui
]]
function gem_system_strengthen_scene.destroy(self)
    -- body
    cclog("-----------------gem_system_strengthen_scene destroy-----------------");
    self.m_skill_layer = nil;
    self.m_anim_node = nil;
    self.m_selGemId = nil;
    self.m_ok_btn = nil;
    self.m_currentSkillTable = nil;
    self.m_material_id_table = nil;
    self.m_autoSelectFlag = nil;
    self.m_canStrengthenFlag = nil;
    self.m_upGemLevelTable = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_hero_bg_btn = nil;
    self.m_material_node_tab = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_material_node = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needMetal = nil;
    self.m_curPage = nil;
    self.m_curPageMaterial = nil;
    self.m_cost_metal_label = nil;
    self.m_metal_total_label = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selGemDataBackupTab = nil;
    self.m_selFilterCardSortIndex = nil;
    self.m_status = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_guildNode = nil;
    self.m_quick_sel_btn = nil;
    self.m_showDataTable = nil;
    self.m_auto_add_btn = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
    self.m_skillBackupData = nil;
    self.m_openType = nil;
    self.m_sell_id = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_level_label_1 = nil;
    self.m_level_label_2 = nil;
    self.m_exp_bar_bg = nil;
    self.m_up_detail_label = nil;
end

--[[--
    返回
]]
function gem_system_strengthen_scene.back(self,backType)
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
        elseif self.m_openType == "game_small_map_scene" then
            local function responseMethod(tag,gameData)
                game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                game_scene:enterGameUi("game_small_map_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
        else
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        end
    end
end
--[[--
    读取ccbi创建ui
]]
function gem_system_strengthen_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        -- elseif btnTag == 2 then--材料
            -- if self.m_selGemId then
            --     self:refreshByType(2);
            -- end
        elseif btnTag == 3 then--重新选择
            if self.m_showType ~= 1 then
                self:refreshByType(1);
            end
        elseif btnTag == 101 then--开始强化
            if self.need_food == true then
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 5,
                    m_call_func = function()
                        self:refreshTips();
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                self:onSureFunc();
            end
        elseif btnTag == 102 then--自动选择
            self:autoSelectMaterial();
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            self:refreshSortTabBtn(btnTag - 200);
            if self.m_showType == 1 then
                local selSort = tostring(GEM_SORT_TAB[btnTag - 200].sortType);
                game_data:gemSortByTypeName(selSort);
                self:refreshGemTableView();
            elseif self.m_showType == 2 then
                self:refreshFilterGemTableView();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_gem_system_strengthen.ccbi");
    --英雄相关
    self.m_skill_layer = ccbNode:layerColorForName("m_skill_layer")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_hero_bg_btn = ccbNode:controlButtonForName("m_hero_bg_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_quick_sel_btn = ccbNode:controlButtonForName("m_quick_sel_btn")
    self.m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")

    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label")
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")

    self.m_level_label_1 = ccbNode:labelTTFForName("m_level_label_1")
    self.m_level_label_2 = ccbNode:labelTTFForName("m_level_label_2")
    self.m_exp_bar_bg = ccbNode:spriteForName("m_exp_bar_bg")
    self.m_up_detail_label = ccbNode:labelTTFForName("m_up_detail_label")

    local m_material_node,m_mate_tips = nil,nil;
    for i=1,6 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    self:initSkillLayerTouch(self.m_skill_layer);
    self.m_ccbNode = ccbNode
    -- game_util:createScrollViewTips2(self.m_scroll_view_tips,{"jnsj_miaoshu.png","jnsj_miaoshu_2.png"});--,"jnsj_miaoshu_1.png"

    local m_combat_node = ccbNode:nodeForName("m_combat_node");
    self.m_combatNumberChangeNode = game_util:createExtNumberChangeNode({labelType = 2});
    self.m_combatNumberChangeNode:setAnchorPoint(ccp(0, 0.5));
    -- self.m_combatNumberChangeNode:setScale(0.75);
    m_combat_node:addChild(self.m_combatNumberChangeNode);
    self.m_combatNumberChangeNode:setCurValue(0,false);

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    自动选择材料
]]
function gem_system_strengthen_scene.autoSelectMaterial(self)
    if self.m_selGemId == nil then
        game_util:addMoveTips({text = string_helper.gem_system_strengthen_scene.text});
        return;
    end
    self.m_material_id_table = {};
    if self.m_showType ~= 2 then
        self.m_showType = 2;
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:filterMaterialData();
    end
    local tempIdTab1,tempIdTab2,tempIdTab3 = {},{},{}
    for i=#self.m_showDataTable,1,-1 do
        local tempId = self.m_showDataTable[i];
        local _,itemCfg = game_data:getGemDataById(tostring(tempId));
        local quality = itemCfg:getNodeWithKey("quality"):toInt();
        if quality == 0 then
            if #tempIdTab1 < 6 then
                table.insert(tempIdTab1,tempId);
            end
        elseif quality == 1 then
            if #tempIdTab2 < 6 then
                table.insert(tempIdTab2,tempId);
            end
        elseif quality == 2 then
            if #tempIdTab3 < 6 then
                table.insert(tempIdTab3,tempId);
            end
        end
    end
    if #tempIdTab1 > 0 then
        self.m_material_id_table = util.table_copy(tempIdTab1)
    else
        if #tempIdTab2 > 0 then
            self.m_material_id_table = util.table_copy(tempIdTab2)
        else
            if #tempIdTab3 > 0 then
                self.m_material_id_table = util.table_copy(tempIdTab3)
            end
        end
    end

    self:refreshMaterial();
    self:setGainExp();
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    -- local _,containerPosY = self.m_tableView:getContainer():getPosition()
    -- cclog("containerPosY === " .. containerPosY)
    -- if containerPosY < 0 then
    --     self.m_tableView:setContentOffset(ccp(0,0))
    -- end
    if #self.m_material_id_table > 0 then

    else
        game_util:addMoveTips({text = string_helper.gem_system_strengthen_scene.text2})
    end
end

--[[--
    确定强化
]]
function gem_system_strengthen_scene.onSureFunc(self)
    if self.m_selGemId == nil then
        game_util:addMoveTips({text = string_helper.gem_system_strengthen_scene.text4});
        return;
    end
    local function sendRequest()
        self.m_selGemDataBackupTab = util.table_new(self.m_upGemLevelTable);
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            end
            self:responseSuccess();
        end
        --参数 gem_id    element_id=&element_id=&element_id=
        local params = "gem_id=" .. self.m_selGemId
        table.foreach(self.m_material_id_table,function(k,v)
            params = params .. "&element_id=" .. v;
        end);
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gem_upgrade"), http_request_method.GET, params,"gem_upgrade",true,true)
    end

    local function okFunc()
        if #self.m_material_id_table == 0 then
            game_util:addMoveTips({text = string_helper.gem_system_strengthen_scene.text3});
        else
            local tempData = game_data:getCardDataById(self.m_selGemId)
            self.m_skillBackupData = util.table_new(tempData);
            self.m_root_layer:setTouchEnabled(true);
            sendRequest();
        end
    end
    -- if self.m_is_notice ~= 0 then
    --     local openType = 4
    --     if self.m_is_notice == 1 then --使用进阶的
    --         openType = 4
    --     elseif self.m_is_notice == 2 then --使用高级的作为材料
    --         openType = 5
    --     elseif self.m_is_notice == 3 then --使用蓝色以上的作为材料
    --         openType = 6
    --     end
    --     local params = {}
    --     params.m_openType = openType
    --     params.hero_id = self.m_sell_id
    --     params.okBtnCallBack = function()
    --         game_scene:removePopByName("game_special_tips_pop")
    --         okFunc();
    --     end
    --     game_scene:addPop("game_special_tips_pop",params)
    -- else
        okFunc();
    -- end
end

--[[--
    
]]
function gem_system_strengthen_scene.responseSuccess(self)
    game_scene:removeGuidePop();
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_success")
        self.m_material_id_table = {};
        self.m_is_notice = 0;
        self:refreshUi();
        self:successAnim();
        self.m_ccbNode:addChild(game_util:animSuccessCCBAnim(nil,"strengthen_success"));
        if self.m_skillBackupData then
            
        end
    end
    local rempveIndex = #self.m_material_id_table
    local materialCount = rempveIndex;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,6 do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        if i <= materialCount then 
            local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
            if mAnimNode then
                local function onAnimSectionEnd(animNode, theId,theLabelName)
                    if theLabelName == "impact1" then
                        animNode:playSection("impact2");
                        local tempNode = m_material_node:getChildByTag(10)
                        if tempNode then
                            tempNode:setVisible(false);
                        end
                    else
                        mAnimNode:removeFromParentAndCleanup(true);
                        rempveIndex = rempveIndex - 1;
                        if rempveIndex == 0 then
                            responseEndFunc();
                            -- self.m_ccbNode:runAnimations("success_anim")
                        end
                    end
                end
                mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                mAnimNode:playSection("impact1");
                local tempSize = m_material_node:getContentSize();
                mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(mAnimNode,100,100);
                local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
                if tempParticle then
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_material_node,endNode = self.m_sel_btn,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                    game_scene:getPopContainer():addChild(tempParticle)
                end
            else
                rempveIndex = rempveIndex - 1;
                if rempveIndex == 0 then
                    responseEndFunc();
                    -- self.m_ccbNode:runAnimations("success_anim")
                end
            end
        else
            
        end
    end
end

--[[--
    移除弹出框
]]
function gem_system_strengthen_scene.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--
    强化成功后播放的动画效果
]]
function gem_system_strengthen_scene.successAnim(self)
    local function animFunc(skillExpBar,expBarAdd,lvLabel,currentLevel,totalLevel,oldPercentage)
        expBarAdd:setVisible(false);
        local percentage = expBarAdd:getPercentage();
        local function runAnim(index)
            lvLabel:setString("" .. currentLevel);
            if currentLevel >= totalLevel then
                local function endCallFun( node )
                    expBarAdd:setVisible(true);
                    local animArr = CCArray:create();
                    -- animArr:addObject(CCFadeTo:create(2,255));
                    -- animArr:addObject(CCFadeTo:create(2,0));
                    animArr:addObject(CCBlink:create(2,2));
                    expBarAdd:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
                end
                local arr = CCArray:create();
                if index == 1 then
                    arr:addObject(CCProgressFromTo:create(1,oldPercentage,percentage));
                else
                    arr:addObject(CCProgressFromTo:create(1,0,percentage));
                end
                arr:addObject(CCCallFuncN:create(endCallFun));
                skillExpBar:runAction(CCSequence:create(arr));
            else
                local function endCallFun( node )
                    currentLevel = currentLevel + 1;
                    runAnim(2);
                end
                local arr = CCArray:create();
                if index == 1 then
                    arr:addObject(CCProgressFromTo:create(1,oldPercentage,100));
                else
                    arr:addObject(CCProgressFromTo:create(1,0,100));
                end
                arr:addObject(CCCallFuncN:create(endCallFun));
                skillExpBar:runAction(CCSequence:create(arr));
            end
        end
        runAnim(1);
    end

    for k,v in pairs(self.m_upGemLevelTable) do
        local currentLevel = self.m_selGemDataBackupTab[k].level;
        local oldPercentage = self.m_selGemDataBackupTab[k].percentage;
        animFunc(v.skillExpBar,v.expBarAdd,v.lvLabel,currentLevel,v.level,oldPercentage)
    end
end


--[[--
    技能层
]]
function gem_system_strengthen_scene.initSkillLayerTouch(self,formation_layer)
    local items = formation_layer:getChildren();
    local itemCount = items:count();
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local touchBeginTime = 0;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        touchBeginTime = os.time();
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for i = 1,itemCount do
            tempItem = tolua.cast(items:objectAtIndex(i - 1),"CCSprite");
            if tempItem:boundingBox():containsPoint(realPos) then
                tag = tempItem:getTag();
                if tag < 4 and self.m_currentSkillTable[i] ~= nil then
                else
                    tempItem = nil;
                end
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        cclog("initSkillLayerTouch onTouchEnded --")
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if tempItem and tempItem:boundingBox():containsPoint(realPos) and tag and tag < 4 then
            local offsetTime = os.time() - touchBeginTime
            if offsetTime > 1 then
            else
            end
        end
        tempItem = nil;
        tag = nil;
        realPos = self.m_material_node:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            if v.m_material_node:boundingBox():containsPoint(realPos) then
                cclog("m_material_node click ==== " .. k)
                if self.m_selGemId then
                    if self.m_showType == 1 then
                        self:refreshByType(2);
                    else
                        if self.m_material_id_table[k] ~= nil then
                            table.remove(self.m_material_id_table,k);
                            self:refreshMaterial();
                            self:setGainExp();
                            self:refreshFilterGemTableView();
                        end
                    end
                end
                break;
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


--[[--
    刷新材料列表
]]
function gem_system_strengthen_scene.refreshMaterial(self)
    local tempHeadIcon = nil;
    local m_material_node,m_mate_tips = nil,nil;
    local tempSize = nil;
    for index=1,#self.m_material_node_tab do
        m_material_node = self.m_material_node_tab[index].m_material_node;
        m_mate_tips = self.m_material_node_tab[index].m_mate_tips;
        m_material_node:removeAllChildrenWithCleanup(true);
        if self.m_material_id_table[index] ~= nil then
            local tempId = tostring(self.m_material_id_table[index])
            local _,itemCfg = game_data:getGemDataById(tempId)
            tempHeadIcon = game_util:createGemIconByCfg(itemCfg);
            if tempHeadIcon then
                tempSize = m_material_node:getContentSize();
                tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(tempHeadIcon,10,10);
            end
            m_mate_tips:setVisible(false);
        else
            m_mate_tips:setVisible(true);
            if self.m_selGemId ~= nil then

            end
        end
    end
end

--[[--
    属性信息
]]
function gem_system_strengthen_scene.refreshGemInfo(self,tempId)
    self.m_canStrengthenFlag = false;
    self.m_status = 0;
    self.m_selGemId = tempId;
    local tempNode = nil;
    for i=1,1 do
        tempNode = self.m_skill_layer:getChildByTag(i);
        if tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
        end
    end
    self.m_currentSkillTable = {};
    self.m_upGemLevelTable = {};
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_up_detail_label:setString("none")
    self.m_exp_bar_bg:removeAllChildrenWithCleanup(true);
	if tempId ~= nil and tempId ~= "-1" then
        local itemData,itemCfg = game_data:getGemDataById(tostring(tempId));
        local ccbNode = game_util:createGemItemByCCB(itemData);
        self.m_anim_node:addChild(ccbNode,10,10);

        self.m_level_label_1:setString(itemData.lv)
        self.m_level_label_2:setString(itemData.lv)
        local gem_base_cfg = getConfig(game_config_field.gem_base);
        local gem_base_cfg_item = gem_base_cfg:getNodeWithKey(tostring(itemData.lv))
        if itemCfg then
            local lv_max = itemCfg:getNodeWithKey("lv_max"):toInt();
            if itemData.lv < lv_max then
                local quality = itemCfg:getNodeWithKey("quality"):toInt();
                local maxExp = gem_base_cfg_item:getNodeWithKey("quality" .. quality)
                if maxExp then
                    maxExp = maxExp:toInt();
                else
                    maxExp = 100;
                end
                local expBg = self.m_exp_bar_bg
                local expBgSize = expBg:getContentSize();
                local percentage = math.min(100,100*itemData.exp/maxExp);
                cclog(" itemData.exp ====" .. itemData.exp .. " ; maxExp ==========" .. maxExp .. " ; percentage ==" .. percentage)
                local expBarAdd = game_util:createProgressTimer({fileName = "jnsj_jingyantiao_1.png",percentage = percentage})
                expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
                expBg:addChild(expBarAdd,1,1);
                local bar = game_util:createProgressTimer({fileName = "jnsj_jingyantiao.png",percentage = percentage})
                bar:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
                expBg:addChild(bar,2,2);
                local addExpLabel = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 10});
                addExpLabel:setPosition(ccp(expBgSize.width*0.5,-expBgSize.height*0.5));
                expBg:addChild(addExpLabel,11,11);
                self.m_upGemLevelTable[tostring(tempId)] = {level = itemData.lv,exp = itemData.exp,addExp = 0,expBarAdd = expBarAdd,skillExpBar = bar,maxExp = maxExp,lvLabel = self.m_level_label_1,addExpLabel=addExpLabel,nameLabel = tempLabel,percentage = percentage};
            else
                game_util:addMoveTips({text = string_helper.gem_system_strengthen_scene.gem_top});
            end
        end
    else
        self.m_level_label_1:setString("---")
        self.m_level_label_2:setString("---")
	end
    self:refreshTips();
end

--[[--
    获得基础经验值表
]]
function gem_system_strengthen_scene.setGainExp(self)
    local gem_base_cfg = getConfig(game_config_field.gem_base);
    for k,v in pairs(self.m_upGemLevelTable) do
        v.addExp = 0;
    end
    local itemData,itemCfg = nil;
    local totalBaseExp = 0;
    self.m_needMetal = 0;
    self.m_is_notice = 0;
    -- -- table.foreach(self.m_material_id_table,function(k,v)
    for i=1,#self.m_material_id_table do
        local v = self.m_material_id_table[i]
        itemData,itemCfg = game_data:getGemDataById(tostring(v));
        local eaten_exp = itemCfg:getNodeWithKey("eaten_exp"):toInt();
        local quality = itemCfg:getNodeWithKey("quality"):toInt(); --品质
        local lv = itemData.lv  --等级
        local gem_base_cfg_item = gem_base_cfg:getNodeWithKey(tostring(lv-1))
        if gem_base_cfg_item then
            local expValue = gem_base_cfg_item:getNodeWithKey("quality" .. quality)
            if expValue then
                totalBaseExp = totalBaseExp + expValue:toInt();
            end
        end
        totalBaseExp = totalBaseExp + eaten_exp + itemData.exp;
        if self.m_is_notice == 0 then
            self.m_sell_id = itemData.id
            if quality >= 2 then
                self.m_is_notice = 1
            elseif lv >= 10 then
                self.m_is_notice = 2
            elseif quality >= 2 then
                self.m_is_notice = 3
            end
        end
    end
    cclog("print  -------------------------------totalBaseExp = " .. totalBaseExp);

    local addExp = totalBaseExp
    local k = tostring(self.m_selGemId);
    local v = self.m_upGemLevelTable[k]
    if v then
        cclog("k ==================" .. k  .. " ; addExp = " .. addExp .. " ; exp = " .. v.exp .. " ; maxExp = " .. v.maxExp);
        local percentage = math.min(100,100*(addExp+v.exp)/v.maxExp)
        local currPercentage = v.expBarAdd:getPercentage();
        if currPercentage < 100 then
            v.expBarAdd:runAction(CCProgressTo:create(0.1,percentage));
            -- v.expBarAdd:setPercentage(math.min(100,100*(addExp+v.exp)/v.maxExp));
        elseif currPercentage == 100 and percentage < 100 then
            v.expBarAdd:runAction(CCProgressFromTo:create(0.1,100,percentage));
        end
        local addLevel,_,_,attrValue = self:getLevelUpValue(k,v.level,addExp+v.exp);
        cclog("addLevel ========================" .. addLevel .. " ; attrValue = " .. attrValue);
        self.m_level_label_2:setString(v.level+addLevel)
        -- game_util:labelChangedRepeatForeverFade(v.lvLabel,"Lv." .. v.level,"Lv." .. (v.level+addLevel));
        if addExp == 0 then
            v.addExpLabel:setString("");
        else
            v.addExpLabel:setString("+" .. math.floor(addExp));
        end
        if attrValue > 0 then
            self.m_up_detail_label:setString("" .. attrValue);
        end
    end
    self:refreshTips();
end


--[[--
    
]]
function gem_system_strengthen_scene.getLevelUpValue(self,tempId,currentLevel,totalExp)
    local gemCfg = getConfig(game_config_field.gem);
    local gem_base_cfg = getConfig(game_config_field.gem_base);
    local itemData,itemCfg = game_data:getGemDataById(tostring(tempId));
    if itemCfg == nil then return 0 end
    local maxLv = itemCfg:getNodeWithKey("lv_max"):toInt();
    local quality = itemCfg:getNodeWithKey("quality"):toInt();
    local addLevel = 0;
    local percentage = 0;
    local isMaxFlag = false;
    local attrValue = 0;
    local function checkValue()
        local upToLv = currentLevel + addLevel;
        local levelup_item_cfg = gem_base_cfg:getNodeWithKey(tostring(upToLv))
        if levelup_item_cfg then
            local maxExp = 0;
            maxExp = levelup_item_cfg:getNodeWithKey("quality" .. quality):toInt();
            if maxExp ~= 0 then
                if totalExp >= maxExp then
                    self.m_needMetal = self.m_needMetal + levelup_item_cfg:getNodeWithKey("iron"):toInt();
                    attrValue = attrValue + itemCfg:getNodeWithKey("lv_add"):toInt();
                    if upToLv < maxLv then
                        addLevel = addLevel + 1;
                    else
                        isMaxFlag = true;
                    end
                    totalExp = totalExp - maxExp;
                    checkValue();
                else
                    percentage = 100*totalExp/maxExp
                end
            end
        end
    end
    checkValue();
    return addLevel,percentage,isMaxFlag,attrValue;
end

--[[--
    过虑材料数据材料
]]
function gem_system_strengthen_scene.filterMaterialData(self)
    local selItemData = nil;
    local itemConfig = nil;
    local selQuality = 0;

    if self.m_selGemId ~= nil then
        selItemData,itemConfig = game_data:getGemDataById(tostring(self.m_selGemId));
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
    end

    local gemCfg = getConfig(game_config_field.gem);
    local gemDataTable = game_data:getGemData();
    local showDataTable = {};
    for key,itemData in pairs(gemDataTable) do
        itemConfig = gemCfg:getNodeWithKey(itemData.c_id);
        local existFlag,_,_ = game_data:gemInGemPos(itemConfig:getNodeWithKey("career"):toInt(),key)
        if key ~= tostring(self.m_selGemId) and not existFlag then
            showDataTable[#showDataTable+1] = itemData.id;
        end
    end
    game_data:gemSortByTypeNameWithTable(GEM_SORT_TAB[self.m_selFilterCardSortIndex].sortType,showDataTable);
    self.m_showDataTable = showDataTable;
end

--[[--
    创建筛选的列表
]]
function gem_system_strengthen_scene.createFilterTableView(self,viewSize)
    self.m_guildNode = nil;
    self.m_selListItem = nil;
    local showDataTable = self.m_showDataTable or {};
    local showCount = #showDataTable;
    if showCount == 0 then
        self.m_no_material_tips:setVisible(true);
    end
    local totalItem = math.max(showCount%4 == 0 and showCount or math.floor(showCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = showCount--totalItem;
    params.showPageIndex = self.m_curPageMaterial;
    params.direction = kCCScrollViewDirectionVertical;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createGemItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < showCount then
                local itemData,_ = game_data:getGemDataById(showDataTable[showCount - index]);
                if itemData then
                    game_util:setGemItemInfoByTable2(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(true);
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell) .. " ; cell:getUserData() = " .. tolua.type(cell:getUserData()));
        if index >= showCount then return end;
        if eventType == "ended" and cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local itemData,_ = game_data:getGemDataById(showDataTable[showCount - index]);
            local tempId = tostring(itemData.id);
            local flag,k = game_util:idInTableById(tempId,self.m_material_id_table)
            if flag and k ~= nil then
                -- cclog("remove select material hero id ==========" .. tempId);
                table.remove(self.m_material_id_table,k);
                m_sel_img:setVisible(false);
                self:refreshMaterial();
                self:setGainExp();
            else
                if #self.m_material_id_table < 6 then
                    -- cclog("add select material hero id ==========" .. tempId);
                    table.insert(self.m_material_id_table,tempId);
                    m_sel_img:setVisible(true);
                    self:refreshMaterial();
                    self:setGainExp();
                end
            end
            -- print("---------------------------------m_material_id_table-----start");
            -- table.foreach(self.m_material_id_table,print);
            -- print("--------------------------------m_material_id_table------end");
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPageMaterial = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    创建英雄列表
]]
function gem_system_strengthen_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local showCount = game_data:getGemCount();
    cclog("showCount ================ " .. showCount)
    local totalItem = math.max(showCount%4 == 0 and showCount or math.floor(showCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = showCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createGemItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < showCount then
                local itemData,_ = game_data:getGemDataByIndex(index+1);
                if itemData then
                    local card_id = itemData.id;
                    game_util:setGemItemInfoByTable2(ccbNode,itemData);
                    if self.m_selGemId and self.m_selGemId == card_id then
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(true);
                        self.m_selListItem = cell;
                    end
                    if self.m_guildNode == nil and index == 0 then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= showCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemConfig = game_data:getGemDataByIndex(index+1);
            local tempId = itemData.id;
            if self.m_selGemId == nil or self.m_selGemId ~= tempId then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selGemId = tempId;
                self:refreshGemInfo(self.m_selGemId);
                self:refreshMaterial();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function gem_system_strengthen_scene.refreshGemTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新
]]
function gem_system_strengthen_scene.refreshFilterGemTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self:filterMaterialData();
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function gem_system_strengthen_scene.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    if self.m_showType == 1 then
        self.m_selSortIndex = sortIndex
        for i=1,4 do
            tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
            tempBtn:setHighlighted(self.m_selSortIndex == i);
            tempBtn:setEnabled(self.m_selSortIndex ~= i);
        end
    elseif self.m_showType == 2 then
        self.m_selFilterCardSortIndex = sortIndex
        for i=1,4 do
            tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
            tempBtn:setHighlighted(self.m_selFilterCardSortIndex == i);
            tempBtn:setEnabled(self.m_selFilterCardSortIndex ~= i);
        end
    end
end

--[[--
    刷新
]]
function gem_system_strengthen_scene.refreshByType(self,showType)
    self.m_no_material_tips:setVisible(false);
    self.m_showType = showType;
    if showType == 1 then
        self.m_material_id_table = {};
        self:refreshMaterial();
        self:setGainExp();
        -- self.m_ok_btn:setVisible(false);
        -- self.m_auto_add_btn:setVisible(true);
        self:refreshSortTabBtn(self.m_selSortIndex);
        self:refreshGemTableView();
    elseif showType == 2 then
        self:setGainExp();
        -- self.m_ok_btn:setVisible(true);
        -- self.m_auto_add_btn:setVisible(false);
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:refreshFilterGemTableView();
    end
    self:refreshTips(); 
end

--[[--
    刷新状态
]]
function gem_system_strengthen_scene.refreshTips(self)
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_showType == 1 then
        self.m_cost_metal_label:setString("0");
        if self.m_selGemId == nil then
            game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
            self.m_tips_spr_1:setVisible(true);

            self.m_tips_spr_2:setVisible(false);
            self.m_skill_layer:setVisible(false);
            for i=1,6 do
                self.m_material_node_tab[i].m_mate_tips:stopAllActions();
                self.m_material_node_tab[i].m_mate_tips:setOpacity(255);
            end
            self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
            self.m_light_bg_1:runAction(game_util:createRepeatForeverFade())


        else
            self.m_tips_spr_1:setVisible(false);
            self.m_tips_spr_2:setVisible(false);

            self.m_skill_layer:setVisible(true);
            for k,v in pairs(self.m_upGemLevelTable) do
                v.addExpLabel:setString("");
                -- v.nameLabel:setVisible(true);
            end
            for i=1,6 do
                self.m_material_node_tab[i].m_mate_tips:runAction(game_util:createRepeatForeverFade())
            end
        end
    elseif self.m_showType == 2 then
        self.m_tips_spr_1:setVisible(false);
        -- self.m_tips_spr_2:setVisible(false);
            self.m_tips_spr_2:setVisible(true);
        -- for k,v in pairs(self.m_upGemLevelTable) do
        --     v.nameLabel:setVisible(false);
        -- end
    end
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_metal_total_label:setString(value .. unit);
    game_util:setCostLable(self.m_cost_metal_label,self.m_needMetal,totalMetal);
    if self.m_needMetal > totalMetal then
        self.need_food = true
    else
        self.need_food = false
    end
end

--[[--
    刷新
]]
function gem_system_strengthen_scene.refreshCombatLabel(self)
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
function gem_system_strengthen_scene.refreshUi(self)
    self:refreshGemInfo(self.m_selGemId);
    self:refreshMaterial();
    -- self:setGainExp();
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function gem_system_strengthen_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selGemId = t_params.selGemId;
    self.m_currentSkillTable = {};
    self.m_material_id_table = {};
    self.m_upGemLevelTable = {};
    if t_params.material_id_table and type(t_params.material_id_table) == "table" then
        self.m_material_id_table = t_params.material_id_table;
    end
    self.m_material_node_tab = {};
    self.m_showType = 1;
    self.m_needMetal = 0;
    self.m_selGemDataBackupTab = {};
    self.m_selFilterCardSortIndex = 1;
    self.m_status = 0;
    self.m_is_notice = 0;
    self.m_showDataTable = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.m_openType = t_params.openType or ""
    self.need_food = false
end

--[[--
    创建ui入口并初始化数据
]]
function gem_system_strengthen_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return gem_system_strengthen_scene;
