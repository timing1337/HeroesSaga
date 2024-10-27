---  技能强化

local skills_strengthen_scene = {
    m_skill_layer = nil,--技能父节点
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_currentSkillTable = nil,
    m_material_id_table = nil,
    m_autoSelectFlag = nil,
    m_canStrengthenFlag = nil,
    m_upSkillLevelTable = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_hero_bg_btn = nil,
    m_material_node_tab = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_material_node = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needFood = nil,
    m_curPage = nil,
    m_curPageMaterial = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selSkillDataBackupTab = nil,
    m_selFilterCardSortIndex = nil,
    m_status = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_guildNode = nil,
    m_quick_sel_btn = nil,
    m_showHeroTable = nil,
    m_auto_add_btn = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
    m_up_skill_index = nil,
    m_skillBackupData = nil,
    m_select_sprite = nil,
    m_openType = nil,
    m_sell_id = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_firstCanStrengthenIndex = nil,
};
--[[--
    销毁ui
]]
function skills_strengthen_scene.destroy(self)
    -- body
    cclog("-----------------skills_strengthen_scene destroy-----------------");
    self.m_skill_layer = nil;
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_currentSkillTable = nil;
    self.m_material_id_table = nil;
    self.m_autoSelectFlag = nil;
    self.m_canStrengthenFlag = nil;
    self.m_upSkillLevelTable = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_hero_bg_btn = nil;
    self.m_material_node_tab = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_material_node = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needFood = nil;
    self.m_curPage = nil;
    self.m_curPageMaterial = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selSkillDataBackupTab = nil;
    self.m_selFilterCardSortIndex = nil;
    self.m_status = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_guildNode = nil;
    self.m_quick_sel_btn = nil;
    self.m_showHeroTable = nil;
    self.m_auto_add_btn = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
    self.m_up_skill_index = nil;
    self.m_skillBackupData = nil;
    self.m_select_sprite = nil;
    self.m_openType = nil;
    self.m_sell_id = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_firstCanStrengthenIndex = nil;
end

--[[--
    返回
]]
function skills_strengthen_scene.back(self,backType)
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
function skills_strengthen_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        -- elseif btnTag == 2 then--材料
            -- if self.m_selHeroId then
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
                local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
                game_data:cardsSortByTypeName(selSort);
                self:refreshCardTableView();
            elseif self.m_showType == 2 then
                self:refreshFilterCardTableView();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_skills_strengthen.ccbi");
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
    local title61 = ccbNode:labelTTFForName("title61");
    title61:setString(string_helper.ccb.title61)
    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1");
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2");
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3");
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4");
    m_table_tab_label_1:setString(string_helper.ccb.file8);
    m_table_tab_label_2:setString(string_helper.ccb.file9);
    m_table_tab_label_3:setString(string_helper.ccb.file10);
    m_table_tab_label_4:setString(string_helper.ccb.file11);
    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file12)
    game_util:setCCControlButtonTitle(self.m_auto_add_btn,string_helper.ccb.file13)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_select_sprite = ccbNode:scale9SpriteForName("select_sprite")

    self.m_select_sprite:runAction(game_util:createRepeatForeverFade())

    local m_material_node,m_mate_tips = nil,nil;
    for i=1,6 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    self:initSkillLayerTouch(self.m_skill_layer);
    self.m_ccbNode = ccbNode
    game_util:createScrollViewTips2(self.m_scroll_view_tips,{"jnsj_miaoshu.png","jnsj_miaoshu_2.png"});--,"jnsj_miaoshu_1.png"

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
function skills_strengthen_scene.autoSelectMaterial(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text});
        return;
    end
    self.m_material_id_table = {};
    if self.m_showType ~= 2 then
        self.m_showType = 2;
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:filterMaterialData();
    end
    -- local len = math.min(#self.m_showHeroTable,6)
    -- for i=1,len do
    --     local heroId = self.m_showHeroTable[i];
    --     table.insert(self.m_material_id_table,heroId);
    -- end
    local tempIdTab1,tempIdTab2,tempIdTab3 = {},{},{}
    for i=#self.m_showHeroTable,1,-1 do
        local heroId = self.m_showHeroTable[i];
        local _,heroCfg = game_data:getCardDataById(tostring(heroId));
        local quality = heroCfg:getNodeWithKey("quality"):toInt();
        -- if quality < 3 then
        --     table.insert(self.m_material_id_table,heroId);
        --     if #self.m_material_id_table >= 6 then
        --         break;
        --     end
        -- end
        if quality == 0 then
            if #tempIdTab1 < 6 then
                table.insert(tempIdTab1,heroId);
            end
        elseif quality == 1 then
            if #tempIdTab2 < 6 then
                table.insert(tempIdTab2,heroId);
            end
        elseif quality == 2 then
            if #tempIdTab3 < 6 then
                table.insert(tempIdTab3,heroId);
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
        local id = game_guide_controller:getIdByTeam("3");
        if id == 303 then
            game_guide_controller:gameGuide("show","3",306,{tempNode = self.m_ok_btn})
        else
            local id = game_guide_controller:getIdByTeam("6");
            if id == 601 then
                game_guide_controller:gameGuide("show","6",601,{tempNode = self.m_ok_btn})
            end
        end
    else
        game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text2})
    end
end

--[[--
    确定强化
]]
function skills_strengthen_scene.onSureFunc(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text3});
        return;
    end
    if self.m_canStrengthenFlag == false then
        game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text4});
        return;
    end
    local function sendRequest()
        self.m_selSkillDataBackupTab = util.table_new(self.m_upSkillLevelTable);
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            end
            self:responseSuccess();
        end
        --major=100&metal=101&
        local params = "major=" .. self.m_selHeroId .. "&pos=" .. self.m_up_skill_index
        table.foreach(self.m_material_id_table,function(k,v)
            params = params .. "&metal=" .. v;
        end);
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_skill_levelup"), http_request_method.GET, params,"cards_card_skill_levelup",true,true)
    end

    local function okFunc()
        if #self.m_material_id_table == 0 then
            game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text5});
        else
            local tempData = game_data:getCardDataById(self.m_selHeroId)
            if tempData and tempData["s_" .. self.m_up_skill_index] then 
                self.m_skillBackupData = util.table_new(tempData["s_" .. self.m_up_skill_index]);
            end
            self.m_root_layer:setTouchEnabled(true);
            sendRequest();
        end
    end
    if self.m_is_notice ~= 0 then
        local openType = 4
        if self.m_is_notice == 1 then --使用进阶的
            openType = 4
        elseif self.m_is_notice == 2 then --使用高级的作为材料
            openType = 5
        elseif self.m_is_notice == 3 then --使用紫色以上的作为材料
            openType = 6
        end
        local params = {}
        params.m_openType = openType
        params.hero_id = self.m_sell_id
        params.okBtnCallBack = function()
            game_scene:removePopByName("game_special_tips_pop")
            okFunc();
        end
        game_scene:addPop("game_special_tips_pop",params)
    else
        okFunc();
    end
end

--[[--
    
]]
function skills_strengthen_scene.responseSuccess(self)
    game_scene:removeGuidePop();
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_success")
        self.m_material_id_table = {};
        self.m_is_notice = 0;
        self:refreshUi();
        self:successAnim();
        self.m_ccbNode:addChild(game_util:animSuccessCCBAnim(nil,"strengthen_success"));
        local id = game_guide_controller:getIdByTeam("3");
        if id == 306 then
            game_guide_controller:gameGuide("send","3",306);
            self:gameGuide("drama","3",307)
        else
            local id = game_guide_controller:getIdByTeam("6");
            if id == 601 then
                self:gameGuide("drama","6",605)
            end
        end
        if self.m_skillBackupData then
            local cardData,heroCfg = game_data:getCardDataById(self.m_selHeroId);
            if cardData then
                local skillData = cardData["s_" .. self.m_up_skill_index];
                if skillData then
                    if skillData.lv > self.m_skillBackupData.lv then
                        game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = self.m_up_skill_index,backupData = self.m_skillBackupData})
                    end
                end
            end
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
function skills_strengthen_scene.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--
    强化成功后播放的动画效果
]]
function skills_strengthen_scene.successAnim(self)
    local function animFunc(skillExpBar,expBarAdd,lvLabel,currentLevel,totalLevel,oldPercentage)
        expBarAdd:setVisible(false);
        local percentage = expBarAdd:getPercentage();
        local function runAnim(index)
            lvLabel:setString("Lv." .. currentLevel);
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

    for k,v in pairs(self.m_upSkillLevelTable) do
        local currentLevel = self.m_selSkillDataBackupTab[k].level;
        local oldPercentage = self.m_selSkillDataBackupTab[k].percentage;
        animFunc(v.skillExpBar,v.expBarAdd,v.lvLabel,currentLevel,v.level,oldPercentage)
    end
end


--[[--
    技能层
]]
function skills_strengthen_scene.initSkillLayerTouch(self,formation_layer)
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
                game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = tag,posNode = tempItem})
            else
                local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
                if cardData then
                    local skillItem = cardData["s_" .. tag]
                    if self.m_upSkillLevelTable[tostring(skillItem.s)] then
                        if self.m_up_skill_index ~= tag then
                            self:setSelectPos(tag)
                            self.m_up_skill_index = tag;
                            self:setGainExp();
                        else
                            game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = tag,posNode = tempItem})
                        end
                    else
                        game_scene:addPop("skills_activation_pop",{selHeroId=self.m_selHeroId,posIndex = tag,posNode = tempItem})
                    end
                end
            end
        end
        tempItem = nil;
        tag = nil;
        realPos = self.m_material_node:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            if v.m_material_node:boundingBox():containsPoint(realPos) then
                cclog("m_material_node click ==== " .. k)
                if self.m_selHeroId then
                    if self.m_showType == 1 then
                        self:refreshByType(2);
                    else
                        if self.m_material_id_table[k] ~= nil then
                            table.remove(self.m_material_id_table,k);
                            self:refreshMaterial();
                            self:setGainExp();
                            self:refreshFilterCardTableView();
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
function skills_strengthen_scene.refreshMaterial(self)
    local tempHeadIcon = nil;
    local m_material_node,m_mate_tips = nil,nil;
    local tempSize = nil;
    for index=1,#self.m_material_node_tab do
        m_material_node = self.m_material_node_tab[index].m_material_node;
        m_mate_tips = self.m_material_node_tab[index].m_mate_tips;
        m_material_node:removeAllChildrenWithCleanup(true);
        if self.m_material_id_table[index] ~= nil then
            local card_id = tostring(self.m_material_id_table[index])
            local cardData,cardCfg = game_data:getCardDataById(card_id)
            tempHeadIcon = game_util:createCardIconByCfg(cardCfg);
            if tempHeadIcon then
                tempSize = m_material_node:getContentSize();
                tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                m_material_node:addChild(tempHeadIcon,10,10);
            end
            m_mate_tips:setVisible(false);
        else
            m_mate_tips:setVisible(true);
            if self.m_selHeroId ~= nil then

            end
        end
    end
end

--[[--
    属性英雄信息
]]
function skills_strengthen_scene.refreshHeroInfo(self,heroId)
    self.m_canStrengthenFlag = false;
    self.m_status = 0;
    self.m_selHeroId = heroId;
    local tempNode = nil;
    for i=1,6 do
        tempNode = self.m_skill_layer:getChildByTag(i);
        if tempNode then
            tempNode:removeAllChildrenWithCleanup(true);
        end
    end
    self.m_currentSkillTable = {};
    self.m_upSkillLevelTable = {};
    self.m_anim_node:removeAllChildrenWithCleanup(true);
	if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local skill_detail_cfg = getConfig(game_config_field.skill_detail);
        local skill_levelup_cfg = getConfig(game_config_field.skill_levelup);
        local skillJsonData = nil;
        local skillItem = nil;
        for i=1,3 do
            skillItem = cardData["s_" .. i]
            if skillItem and skillItem.s ~= 0 then
                local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
                cclog("skillItem.s ==================================" .. skillItem.s);
                skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                if skillJsonData then
                    local icon_size = skill_icon_spr_bg:getContentSize();
                    self.m_canStrengthenFlag = true;
                    self.m_currentSkillTable[i] = skillJsonData;
                    local skill_icon_spr = game_util:createSkillIconByCfg(skillJsonData,skillItem.avail)
                    if skill_icon_spr then
                        skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
                        skill_icon_spr_bg:addChild(skill_icon_spr);
                    end

                    -- 'avail': 1   # 0表示未解锁，1表示解锁未激活，2表示激活
                    if skillItem.avail == 2 then
                        local maxExp = 100;
                        local skill_levelup_item_cfg = skill_levelup_cfg:getNodeWithKey(tostring(skillItem.lv))
                        local skill_quality = skillJsonData:getNodeWithKey("skill_quality"):toInt();
                        if skill_levelup_item_cfg then
                            local tempCount = skill_levelup_item_cfg:getNodeCount();
                            if skill_quality < tempCount then
                                maxExp = skill_levelup_item_cfg:getNodeAt(skill_quality):toInt();
                            end
                        end
                        local public_exp_img = CCSprite:createWithSpriteFrameName("public_exp_img.png");
                        public_exp_img:setPosition(ccp(icon_size.width*1.4,icon_size.height*0.3));
                        skill_icon_spr_bg:addChild(public_exp_img)
                        maxExp = (maxExp == 0 and 100 or maxExp)
                        local expBg = CCSprite:createWithSpriteFrameName("jnsj_jingyantiao_2.png");
                        local expBgSize = expBg:getContentSize();
                        expBg:setPosition(ccp(icon_size.width*2.4,icon_size.height*0.3));
                        skill_icon_spr_bg:addChild(expBg,1,1);
                        local percentage = math.min(100,100*skillItem.exp/maxExp);
                        cclog(" skillItem.exp ====" .. skillItem.exp .. " ; maxExp ==========" .. maxExp .. " ; percentage ==" .. percentage)
                        local expBarAdd = game_util:createProgressTimer({fileName = "jnsj_jingyantiao_1.png",percentage = percentage})
                        expBarAdd:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
                        expBg:addChild(expBarAdd,1,1);
                        local bar = game_util:createProgressTimer({fileName = "jnsj_jingyantiao.png",percentage = percentage})
                        bar:setPosition(ccp(expBgSize.width*0.5,expBgSize.height*0.5));
                        expBg:addChild(bar,2,2);
                        -- bar:runAction(CCProgressTo:create(0.1,percentage));
                        local lvLabel = game_util:createLabelTTF({text = "Lv." .. skillItem.lv,color = ccc3(255,255,255),fontSize = 14});
                        lvLabel:setPosition(ccp(icon_size.width*2,icon_size.height*0.7));
                        skill_icon_spr_bg:addChild(lvLabel,10,10);
                        local addExpLabel = game_util:createLabelTTF({text = "",color = ccc3(255,255,255),fontSize = 10});
                        addExpLabel:setPosition(ccp(icon_size.width*2.4,icon_size.height*0.1));
                        skill_icon_spr_bg:addChild(addExpLabel,11,11);

                        -- local tempLabel = game_util:createLabelTTF({text = skillJsonData:getNodeWithKey("skill_name"):toStr(),color = ccc3(255,255,255),fontSize = 10});
                        -- tempLabel:setPosition(ccp(icon_size.width*0.5,-icon_size.height*0.375));
                        -- skill_icon_spr_bg:addChild(tempLabel,10,11);
                        self.m_upSkillLevelTable[tostring(skillItem.s)] = {index = i,level = skillItem.lv,exp = skillItem.exp,addExp = 0,expBarAdd = expBarAdd,skillExpBar = bar,maxExp = maxExp,lvLabel = lvLabel,addExpLabel=addExpLabel,nameLabel = tempLabel,percentage = percentage};
                    else
                        local lock_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png");
                        lock_icon_spr:setPosition(icon_size.width*0.5,icon_size.height*0.5);
                        skill_icon_spr_bg:addChild(lock_icon_spr,5,5);
                    end
                end
            end
        end
	end
    self:refreshTips();
end

--[[--
    获得基础经验值表
]]
function skills_strengthen_scene.setGainExp(self)
    for k,v in pairs(self.m_upSkillLevelTable) do
        v.addExp = 0;
    end
    local cardData = nil;
    local character_base_cfg = getConfig(game_config_field.character_base);
    local character_base_rate_cfg = getConfig(game_config_field.character_base_rate);
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_base_item = nil;
    local character_base_rate_item = nil;
    local itemCfg = nil;
    local eaten_skill_exp = nil;
    local eaten_skill_exp_rate = nil;
    local skillId = nil;
    local totalBaseExp = 0;
    local baseExp = 0;
    self.m_needFood = 0;
    local is_notice = nil;
    self.m_is_notice = 0;
    -- table.foreach(self.m_material_id_table,function(k,v)
    for i=1,#self.m_material_id_table do
        local v = self.m_material_id_table[i]
        cardData,itemCfg = game_data:getCardDataById(tostring(v));
        character_base_item = character_base_cfg:getNodeWithKey(tostring(cardData.lv));
        -- cclog("type = " .. itemCfg:getNodeWithKey("type"):toStr() .. " ; id = " .. tostring(v));
        character_base_rate_item = character_base_rate_cfg:getNodeWithKey(itemCfg:getNodeWithKey("type"):toStr());
        eaten_skill_exp = character_base_item:getNodeWithKey("eaten_skill_exp"):toInt();
        eaten_skill_exp_rate = character_base_rate_item:getNodeWithKey("eaten_skill_exp_rate"):toFloat();
        -- cclog("eaten_skill_exp ======" .. eaten_skill_exp .. " ; eaten_skill_exp_rate == " .. eaten_skill_exp_rate);
        baseExp = eaten_skill_exp*eaten_skill_exp_rate;
        totalBaseExp = totalBaseExp + baseExp;
        self.m_needFood = self.m_needFood + character_base_item:getNodeWithKey("skill_strengthen_food"):toInt() * character_base_rate_item:getNodeWithKey("skill_strengthen_food_rate"):toFloat();
        for i=1,3 do
            skillId = cardData["s_" .. i].s
            if skillId ~= 0 then
                if self.m_upSkillLevelTable[tostring(skillId)] ~= nil then--技能存在
                    self.m_upSkillLevelTable[tostring(skillId)].addExp = self.m_upSkillLevelTable[tostring(skillId)].addExp + baseExp;
                    -- cclog("skillId = " .. skillId .. " exist --------------------------addExp = " .. self.m_upSkillLevelTable[tostring(skillId)].addExp);
                end
            end
        end
        -- is_notice = itemCfg:getNodeWithKey("is_notice"):toInt();
        -- if is_notice ~= 0 and is_notice > self.m_is_notice then
        --     self.m_is_notice = is_notice;
        -- end
        local advance_step = cardData.step -- 进阶层数
        local lv = cardData.lv  --等级
        local quality = cardData.quality --品质
        if self.m_is_notice == 0 then
            self.m_sell_id = cardData.id
            if advance_step > 0 and quality >= 3 then
                self.m_is_notice = 1
            elseif lv >= 10 then
                self.m_is_notice = 2
            elseif quality >= 3 then
                self.m_is_notice = 3
            end
        end
    end
    cclog("print  -------------------------------totalBaseExp = " .. totalBaseExp .. " ; self.m_up_skill_index ==" .. self.m_up_skill_index);
    local skillCount = 0;
    table.foreach(self.m_upSkillLevelTable,function(k,v)
        skillCount = skillCount + 1;
    end)
    
    if skillCount ~= 0 then
        local multiple = 1;
        -- if skillCount == 2 then
        --     multiple = 1.2;
        -- elseif skillCount == 3 then
        --     multiple = 1.5;
        -- end
        local addExp = 0--totalBaseExp*multiple / skillCount;
        for k,v in pairs(self.m_upSkillLevelTable) do
            if v.index == self.m_up_skill_index then
                addExp = totalBaseExp*multiple
                addExp = v.addExp + addExp;
            else
                addExp = 0;
            end
            cclog("k ==================" .. k  .. " ; addExp = " .. addExp .. " ; exp = " .. v.exp .. " ; maxExp = " .. v.maxExp .. " ; index = " .. v.index);
            local percentage = math.min(100,100*(addExp+v.exp)/v.maxExp)
            local currPercentage = v.expBarAdd:getPercentage();
            if currPercentage < 100 then
                v.expBarAdd:runAction(CCProgressTo:create(0.1,percentage));
                -- v.expBarAdd:setPercentage(math.min(100,100*(addExp+v.exp)/v.maxExp));
            elseif currPercentage == 100 and percentage < 100 then
                v.expBarAdd:runAction(CCProgressFromTo:create(0.1,100,percentage));
            end
            local addLevel,_ = self:getLevelUpValue(k,v.level,addExp+v.exp);
            -- cclog("addLevel ========================" .. addLevel);
            game_util:labelChangedRepeatForeverFade(v.lvLabel,"Lv." .. v.level,"Lv." .. (v.level+addLevel));
            if addExp == 0 then
                v.addExpLabel:setString("");
            else
                v.addExpLabel:setString("+" .. math.floor(addExp));
            end
        end
    else

    end
    self:refreshTips();
end


--[[--
    
]]
function skills_strengthen_scene.getLevelUpValue(self,skillId,currentLevel,totalExp)
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);
    local skill_levelup_cfg = getConfig(game_config_field.skill_levelup);
    local maxLv = skill_levelup_cfg:getNodeCount();
    local skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(skillId));
    if skillJsonData == nil then return 0 end
    local skill_quality = skillJsonData:getNodeWithKey("skill_quality"):toInt();
    local addLevel = 0;
    local percentage = 0;
    local isMaxFlag = false;
    local function checkValue()
        local upToLv = currentLevel + addLevel;
        local skill_levelup_item_cfg = skill_levelup_cfg:getNodeWithKey(tostring(upToLv))
        if skill_levelup_item_cfg then
            local tempCount = skill_levelup_item_cfg:getNodeCount();
            local maxExp = 0;
            if skill_quality < tempCount then
                maxExp = skill_levelup_item_cfg:getNodeAt(skill_quality):toInt();
            end
            if maxExp ~= 0 then
                if totalExp >= maxExp then
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
    return addLevel,percentage,isMaxFlag;
end

--[[--
    过虑材料数据材料
]]
function skills_strengthen_scene.filterMaterialData(self)
    local character_ID = -1;
    local heroData = nil;
    local itemConfig = nil;
    local selHeroStar = 0;
    local selQuality = 0;
    local skillItem = nil;
    local skillId = nil;
    local currentSkillTable = {};

    if self.m_selHeroId ~= nil then
        heroData,itemConfig = game_data:getCardDataById(tostring(self.m_selHeroId));
        selHeroStar = heroData.star
        character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
        for i=1,3 do
            skillItem = heroData["s_" .. i]
            skillId = skillItem.s
            if skillId and skillId ~= 0 and skillItem.avail == 2 then
                if self.m_selSkillIndex == nil then
                    currentSkillTable[skillId]=i;
                else
                    if i == self.m_selSkillIndex then
                        currentSkillTable[skillId]=i;
                    end
                end
            end
        end
    end

    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    for key,heroData in pairs(cardsDataTable) do
        if key ~= tostring(self.m_selHeroId) and not game_data:heroInTeamById(key) and not game_data:heroInAssistantById(key) and not game_util:getCardLockFlag(heroData) then
            itemConfig = character_detail:getNodeWithKey(heroData.c_id);
            showHeroTable[#showHeroTable+1] = heroData.id;
        end
    end
    game_data:cardsSortByTypeNameWithTable(CARD_SORT_TAB[self.m_selFilterCardSortIndex].sortType,showHeroTable);
    self.m_showHeroTable = showHeroTable;
end

--[[--
    创建筛选的列表
]]
function skills_strengthen_scene.createFilterTableView(self,viewSize)
    self.m_guildNode = nil;
    self.m_selListItem = nil;
    local showHeroTable = self.m_showHeroTable or {};
    local cardsCount = #showHeroTable;
    if cardsCount == 0 then
        self.m_no_material_tips:setVisible(true);
    end
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount--totalItem;
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
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData,_ = game_data:getCardDataById(showHeroTable[cardsCount - index]);
                if itemData then
                    local heroId = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell) .. " ; cell:getUserData() = " .. tolua.type(cell:getUserData()));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
                local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                local itemData,_ = game_data:getCardDataById(showHeroTable[cardsCount - index]);
                local heroId = tostring(itemData.id);
                local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
                if flag and k ~= nil then
                    -- cclog("remove select material hero id ==========" .. heroId);
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                    sprite_back_alpha:setVisible(false);
                    self:refreshMaterial();
                    self:setGainExp();
                else
                    if #self.m_material_id_table < 6 then
                        -- cclog("add select material hero id ==========" .. heroId);
                        table.insert(self.m_material_id_table,heroId);
                        m_sel_img:setVisible(true);
                        sprite_back_alpha:setVisible(true);
                        self:refreshMaterial();
                        self:setGainExp();
                    end
                end
                -- print("---------------------------------m_material_id_table-----start");
                -- table.foreach(self.m_material_id_table,print);
                -- print("--------------------------------m_material_id_table------end");
        elseif eventType == "longClick" and cell then
            local itemData = showHeroTable[cardsCount - index].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshFilterCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
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
function skills_strengthen_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local id = game_guide_controller:getIdByTeam("3");
    local moveFlag = true
    local guideFlag = false
    if id == 302 then
        params.itemActionFlag = false;
        moveFlag = false
        guideFlag = true
    else
        local id = game_guide_controller:getIdByTeam("6");
        if id == 601 then
            params.itemActionFlag = false;
            moveFlag = false
            guideFlag = true
        else
            params.itemActionFlag = true;
        end
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData, itemConfig = game_data:getCardDataByIndex(index+1);
                if itemData then
                    local card_id = itemData.id;

                    local character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();                
                    if not self.m_firstCanStrengthenIndex and character_ID ~= 1000 and character_ID ~= 1001 and character_ID ~= 1002 then
                        self.m_firstCanStrengthenIndex = index
                        if self.m_guildNode == nil then
                            cell:setContentSize(itemSize);
                            self.m_guildNode = cell;
                        end
                    end
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    if self.m_selHeroId and self.m_selHeroId == card_id then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemConfig = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_selHeroId == nil or self.m_selHeroId ~= card_id then
                local character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
                if character_ID == 1000 or character_ID == 1001 or character_ID == 1002 then
                    game_util:addMoveTips({text = string_helper.skills_strengthen_scene.text6});
                    return;
                end
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_up_skill_index = 1;
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                self:refreshMaterial();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
                self:setSelectPos(1)
                local id = game_guide_controller:getIdByTeam("3");
                if id == 302 then
                    game_guide_controller:gameGuide("show","3",303,{tempNode = self.m_auto_add_btn})
                else
                    local id = game_guide_controller:getIdByTeam("6");
                    if id == 601 then
                        game_guide_controller:gameGuide("show","6",601,{tempNode = self.m_auto_add_btn})
                    end
                end
                if guideFlag then
                    if self.m_tableView then self.m_tableView:setMoveFlag(true) end
                end
            end
        elseif eventType == "longClick" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    local tableView = TableViewHelper:create(params);

    if guideFlag then  -- 开始新手引导
        if tableView and self.m_firstCanStrengthenIndex then
            local y = tableView:getContentOffset().y
            tableView:setContentOffset(ccp(0, y + itemSize.height * self.m_firstCanStrengthenIndex), false)
        end
        if tableView then
            tableView:setMoveFlag( moveFlag )
        end
    end
    return tableView
end

--[[--
    刷新
]]
function skills_strengthen_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新
]]
function skills_strengthen_scene.refreshFilterCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self:filterMaterialData();
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function skills_strengthen_scene.refreshSortTabBtn(self,sortIndex)
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
function skills_strengthen_scene.refreshByType(self,showType)
    self.m_no_material_tips:setVisible(false);
    self.m_showType = showType;
    if showType == 1 then
        self.m_material_id_table = {};
        self:refreshMaterial();
        self:setGainExp();
        -- self.m_ok_btn:setVisible(false);
        -- self.m_auto_add_btn:setVisible(true);
        self:refreshSortTabBtn(self.m_selSortIndex);
        self:refreshCardTableView();
    elseif showType == 2 then
        self:setGainExp();
        -- self.m_ok_btn:setVisible(true);
        -- self.m_auto_add_btn:setVisible(false);
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:refreshFilterCardTableView();
    end
    self:refreshTips(); 
end

--[[--
    刷新状态
]]
function skills_strengthen_scene.refreshTips(self)
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_showType == 1 then
        self.m_cost_food_label:setString("0");
        if self.m_selHeroId == nil then
            game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
            self.m_tips_spr_1:setVisible(true);

            self.m_select_sprite:setVisible(false);

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

            self.m_select_sprite:setVisible(true)
            self.m_tips_spr_2:setVisible(false);

            self.m_skill_layer:setVisible(true);
            for k,v in pairs(self.m_upSkillLevelTable) do
                v.addExpLabel:setString("");
                -- v.nameLabel:setVisible(true);
            end
            for i=1,6 do
                self.m_material_node_tab[i].m_mate_tips:runAction(game_util:createRepeatForeverFade())
            end
        end
    elseif self.m_showType == 2 then
        self.m_tips_spr_1:setVisible(false);
        self.m_select_sprite:setVisible(true)

        -- self.m_tips_spr_2:setVisible(false);
            self.m_tips_spr_2:setVisible(true);
        -- for k,v in pairs(self.m_upSkillLevelTable) do
        --     v.nameLabel:setVisible(false);
        -- end
    end
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
    game_util:setCostLable(self.m_cost_food_label,self.m_needFood,totalFood);
    if self.m_needFood > totalFood then
        self.need_food = true
    else
        self.need_food = false
    end
end

--[[--
    刷新
]]
function skills_strengthen_scene.refreshCombatLabel(self)
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
function skills_strengthen_scene.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshMaterial();
    self:setGainExp();
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function skills_strengthen_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_currentSkillTable = {};
    self.m_material_id_table = {};
    self.m_upSkillLevelTable = {};
    if t_params.material_id_table and type(t_params.material_id_table) == "table" then
        self.m_material_id_table = t_params.material_id_table;
    end
    self.m_material_node_tab = {};
    self.m_showType = 1;
    self.m_needFood = 0;
    self.m_selSkillDataBackupTab = {};
    self.m_selFilterCardSortIndex = 1;
    self.m_status = 0;
    self.m_is_notice = 0;
    self.m_showHeroTable = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.m_up_skill_index = 1;
    self.m_openType = t_params.openType or ""
    self.need_food = false
end

--[[--
    创建ui入口并初始化数据
]]
function skills_strengthen_scene.create(self,t_params)
    -- body
    game_data:addOneNewButtonByBtnID(503)   -- 已经了解了技能升级功能
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("3");
    if id == 302 then
        self:gameGuide("drama","3",302)
    else
        local id = game_guide_controller:getIdByTeam("6");
        if id == 601 and self.m_guildNode then
            game_guide_controller:gameGuide("show","6",601,{tempNode = self.m_guildNode})
        end
    end
    self:setSelectPos(1)
    return uiNode;
end
function skills_strengthen_scene.setSelectPos(self,tag)
    local tempSpri = self.m_skill_layer:getChildByTag(tag)
    local tempPosX,tempPosY = tempSpri:getPosition()
    local tempPos = tempSpri:getParent():convertToWorldSpace(ccp(tempPosX,tempPosY))
    self.m_select_sprite:setPosition(tempPos)
end
--[[
    新手引导
]]
function skills_strengthen_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "3" and id == 302 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","3",302,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "3" and id == 307 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","3",307);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "6" and id == 605 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","6",605);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return skills_strengthen_scene;
