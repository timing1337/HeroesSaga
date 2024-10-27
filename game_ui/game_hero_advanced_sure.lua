---  英雄进阶 

local game_hero_advanced_sure = {
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_attr_label_tab = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_attr_node = nil,
    m_maxCrystalLv = nil,
    m_selHeroDataBackup = nil,
    m_material_id_table = nil,
    m_material_node_tab = nil,
    m_material_node = nil,
    m_evo_food = nil,
    m_status = nil,
    m_curPage = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_auto_add_btn = nil,
    m_selFilterCardSortIndex = nil,
    m_selHeroTab = nil,
    m_selHeroData = nil,
    m_popUi = nil,
    m_level_label_1 = nil,
    m_level_label_2 = nil,
    m_mate_tips = nil,
    m_attrValueTab = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_showHeroTable = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
    m_needMaterialCount = nil,
    m_skill_icon_bg = nil,
    m_skill_up_label = nil,
    m_progress_bar_bg = nil,
    m_progress_bar = nil,
    m_stage_spr_1 = nil,
    m_stage_spr_2 = nil,
    m_stage_look_btn_1 = nil,
    m_stage_look_btn_2 = nil,
    m_change_skill_data = nil,
    m_degreeTab = nil,
    m_lookAttrTab = nil,
    m_guildNode = nil,
    m_evo_lv_label = nil,
    m_up_attr_btn = nil,
    m_warning_label = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_addAttrTab = nil,
    m_atrrChangedType = nil,
    m_player_level_label = nil,
};
--[[--
    销毁ui
]]
function game_hero_advanced_sure.destroy(self)
    -- body
    cclog("-----------------game_hero_advanced_sure destroy-----------------");
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_attr_label_tab = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_attr_node = nil;
    self.m_maxCrystalLv = nil;
    self.m_selHeroDataBackup = nil;
    self.m_material_id_table = nil;
    self.m_material_node_tab = nil;
    self.m_material_node = nil;
    self.m_evo_food = nil;
    self.m_status = nil;
    self.m_curPage = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_auto_add_btn = nil;
    self.m_selFilterCardSortIndex = nil;
    self.m_selHeroTab = nil;
    self.m_selHeroData = nil;
    self.m_popUi = nil;
    self.m_level_label_1 = nil;
    self.m_level_label_2 = nil;
    self.m_attrValueTab = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_showHeroTable = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
    self.m_needMaterialCount = nil;
    self.m_skill_icon_bg = nil;
    self.m_skill_up_label = nil;
    self.m_progress_bar_bg = nil;
    self.m_progress_bar = nil;
    self.m_stage_spr_1 = nil;
    self.m_stage_spr_2 = nil;
    self.m_stage_look_btn_1 = nil;
    self.m_stage_look_btn_2 = nil;
    self.m_change_skill_data = nil;
    self.m_degreeTab = nil;
    self.m_lookAttrTab = nil;
    self.m_guildNode = nil;
    self.m_evo_lv_label = nil;
    self.m_up_attr_btn = nil;
    self.m_warning_label = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_addAttrTab = nil;
    self.m_atrrChangedType = nil;
    self.m_player_level_label = nil;
end

--[[--
    返回
]]
function game_hero_advanced_sure.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_hero_advanced_sure.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--材料
            if self.m_selHeroId then
                self:refreshByType(2);
            end
        elseif btnTag == 3 then--重新选择
            if self.m_showType ~= 1 then
                self:refreshByType(1);
            end
        elseif btnTag == 4 then
            if self.m_change_skill_data then
                game_scene:addPop("skills_activation_pop",{skillData=self.m_change_skill_data})
            end
        elseif btnTag == 101 then--开始进阶
            self:onSureFunc();
        elseif btnTag == 102 then--自动选择
            self:autoSelectMaterial();
        elseif btnTag == 103 then--查看进阶
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text});
                return;
            end
            game_scene:addPop("game_hero_evo_look_pop",{selHeroId = self.m_selHeroId})
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
    ccbNode:openCCBFile("ccb/ui_hero_advanced_sure2.ccbi");

    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_material_node = ccbNode:layerForName("m_material_node")
    self.m_attr_node = ccbNode:nodeForName("m_attr_node")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")
    self.m_level_label_1 = ccbNode:labelTTFForName("m_level_label_1");
    self.m_level_label_2 = ccbNode:labelTTFForName("m_level_label_2");
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")
    self.m_evo_lv_label = ccbNode:labelTTFForName("m_evo_lv_label");
    self.m_warning_label = ccbNode:labelTTFForName("m_warning_label");
    self.m_player_level_label = ccbNode:labelTTFForName("m_player_level_label");

    self.m_skill_icon_bg = ccbNode:spriteForName("m_skill_icon_bg")
    self.m_skill_up_label = ccbNode:labelTTFForName("m_skill_up_label");
    self.m_progress_bar_bg = ccbNode:nodeForName("m_progress_bar_bg")
    local bar = ExtProgressBar:createWithFrameName("hbjj_jindutiao.png","hbjj_jindutiao_1.png",self.m_progress_bar_bg:getContentSize());
    self.m_progress_bar_bg:addChild(bar);
    local function barAnimEnd(extBar)
        if extBar:getCurValue() >= extBar:getMaxValue() then
            bar:setCurValue(0,false);
        end
    end
    bar:registerScriptBarHandler(barAnimEnd);
    self.m_progress_bar = bar;
    self.m_stage_spr_1 = ccbNode:spriteForName("m_stage_spr_1")
    self.m_stage_spr_2 = ccbNode:spriteForName("m_stage_spr_2")
    self.m_stage_look_btn_1 = ccbNode:controlButtonForName("m_stage_look_btn_1")
    self.m_stage_look_btn_2 = ccbNode:controlButtonForName("m_stage_look_btn_2")
    self.m_up_attr_btn = ccbNode:controlButtonForName("m_up_attr_btn")
    self.m_up_attr_btn:setOpacity(0);

    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    local m_attr_label,m_value_label = nil;
    for i=1,4 do
        m_attr_label = ccbNode:labelTTFForName("m_attr_label_" .. i);
        m_value_label = ccbNode:labelTTFForName("m_value_label_" .. i);
        self.m_attr_label_tab[i] = {m_attr_label = m_attr_label,m_value_label = m_value_label}
    end
    local m_material_node,m_mate_tips = nil,nil;
    for i=1,6 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips}
    end
    self:initMaterialLayerTouch(self.m_material_node);
    self.m_ccbNode = ccbNode
    -- game_util:createScrollViewTips2(self.m_scroll_view_tips,{"hbjj_miaoshu.png","hbjj_miaoshu_1.png","hbjj_miaoshu_2.png","hbjj_miaoshu_3.png"});
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

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text83)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text84)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text85)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text86)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text222)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text223)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text224)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text225)
    local text5 = ccbNode:labelTTFForName("text5")
    text5:setString(string_helper.ccb.text226)

    local m_look_evo_btn = ccbNode:controlButtonForName("m_look_evo_btn")
    game_util:setCCControlButtonTitle(m_look_evo_btn,string_helper.ccb.text227)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text228)
    game_util:setCCControlButtonTitle(self.m_auto_add_btn,string_helper.ccb.text229)
    return ccbNode;
end

--[[--
    自动选择材料
]]
function game_hero_advanced_sure.autoSelectMaterial(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text});
        return;
    end
    if self.m_showType ~= 2 then
        self.m_showType = 2;
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:filterMaterialData();
    end
    local itemData,itemConfig = game_data:getCardDataById(tostring(self.m_selHeroId));
    local needStep = 0;
    local selQuality = 0;
    local c_id = "0";
    if itemConfig then
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
        needStep = itemData.step
        c_id = itemConfig:getKey()
    end
    self.m_material_id_table = {};
    local material_id_tab1,material_id_tab2,material_id_tab3,material_id_tab4,material_id_tab5,material_id_tab6 = {},{},{},{},{},{}
    for i=#self.m_showHeroTable,1,-1 do
        local heroId = self.m_showHeroTable[i];
        local itemData,itemCfg = game_data:getCardDataById(tostring(heroId));
        if itemData and itemCfg then
            local character_ID2 = itemCfg:getNodeWithKey("character_ID"):toInt();
            local lockFlag = game_util:getCardUserLockFlag(itemData);
            -- if lockFlag == false and not(character_ID2 == 1000 or character_ID2 == 1001) then
            --     table.insert(self.m_material_id_table,heroId);
            --     if #self.m_material_id_table >= self.m_needMaterialCount then
            --         break;
            --     end
            -- end
            if lockFlag == false then
                if character_ID2 == 1000 then--万能紫卡
                    table.insert(material_id_tab1,heroId);
                elseif character_ID2 == 1001 then--万能橙卡
                    table.insert(material_id_tab2,heroId);
                elseif character_ID2 == 1002 then--万能红卡
                    table.insert(material_id_tab4,heroId);
                elseif character_ID2 == 1003 then--万能金卡
                    table.insert(material_id_tab5,heroId);
                elseif c_id ~= itemCfg:getKey() then--复制体
                    table.insert(material_id_tab6,heroId);
                else
                    table.insert(material_id_tab3,heroId);
                end
            end
        end
    end
    if needStep < 23 then
        for i=1,math.min(self.m_needMaterialCount,#material_id_tab6) do
            table.insert(self.m_material_id_table,material_id_tab6[i]);
        end
        if selQuality <= 3 then
            local tempCount = #self.m_material_id_table
            if tempCount < self.m_needMaterialCount then
                for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab1 + tempCount) do
                    table.insert(self.m_material_id_table,material_id_tab1[i - tempCount]);
                end
            end
            local tempCount = #self.m_material_id_table
            if tempCount < self.m_needMaterialCount then
                for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab3 + tempCount) do
                    table.insert(self.m_material_id_table,material_id_tab3[i - tempCount]);
                end
            end
            local tempCount = #self.m_material_id_table
            if tempCount < self.m_needMaterialCount then
                for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab2 + tempCount) do
                    table.insert(self.m_material_id_table,material_id_tab2[i - tempCount]);
                end
            end
        elseif selQuality == 4 then
            if needStep < 4 then
                local tempCount = #self.m_material_id_table
                if tempCount < self.m_needMaterialCount then
                    for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab2 + tempCount) do
                        table.insert(self.m_material_id_table,material_id_tab2[i - tempCount]);
                    end
                end
                local tempCount = #self.m_material_id_table
                if tempCount < self.m_needMaterialCount then
                    for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab3 + tempCount) do
                        table.insert(self.m_material_id_table,material_id_tab3[i - tempCount]);
                    end
                end
            else
                local tempCount = #self.m_material_id_table
                if tempCount < self.m_needMaterialCount then
                    for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab3 + tempCount) do
                        table.insert(self.m_material_id_table,material_id_tab3[i - tempCount]);
                    end
                end
                local tempCount = #self.m_material_id_table
                if tempCount < self.m_needMaterialCount then
                    for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab4 + tempCount) do
                        table.insert(self.m_material_id_table,material_id_tab4[i - tempCount]);
                    end
                end
            end
        else
            local tempCount = #self.m_material_id_table
            if tempCount < self.m_needMaterialCount then
                for i=tempCount+1,math.min(self.m_needMaterialCount,#material_id_tab3 + tempCount) do
                    table.insert(self.m_material_id_table,material_id_tab3[i - tempCount]);
                end
            end
        end
    else
        for i=1,math.min(self.m_needMaterialCount,#material_id_tab5) do
            table.insert(self.m_material_id_table,material_id_tab5[i]);
        end
        local tempCount = #self.m_material_id_table
        if tempCount < self.m_needMaterialCount then
            for i=tempCount+1,math.min(self.m_needMaterialCount,tempCount + #material_id_tab3) do
                table.insert(self.m_material_id_table,material_id_tab3[i - tempCount]);
            end
        end
    end
    self:refreshMaterial();
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    local _,containerPosY = self.m_tableView:getContainer():getPosition()
    cclog("containerPosY === " .. containerPosY)
    if containerPosY < 0 then
        self.m_tableView:setContentOffset(ccp(0,0))
    end
    self:refreshTips();
    if #self.m_material_id_table > 0 then
        local id = game_guide_controller:getIdByTeam("5");
        if id == 508 then
            game_guide_controller:gameGuide("show","5",509,{tempNode = self.m_ok_btn})
        end
    end
end

--[[--

]]
function game_hero_advanced_sure.onSureFunc(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text});
        return;
    end
    if #self.m_material_id_table ~= self.m_needMaterialCount then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text2});
        return;
    end
    if self.m_status == 0 then

    elseif self.m_status == 1 then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text3});
        return;
    elseif self.m_status == 2 then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text4});
        return;
    elseif self.m_status == 3 then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text5});
        return;
    elseif self.m_status == 4 then
        game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text6});
        return;
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            end
            local reward = gameData:getNodeWithKey("data"):getNodeWithKey("reward")
            if reward then
                game_util:rewardTipsByJsonData(reward);
            end
            self:responseSuccess();
        end
        -- major=主卡id&metal=材料卡id
        local params = "major=" .. self.m_selHeroId
        for k,v in pairs(self.m_material_id_table) do
            params = params .. "&metal=" .. v; 
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_evolution"), http_request_method.GET, params,"cards_card_evolution",true,true)
    end
    
    for i=1,#self.m_material_id_table do
        local heroId = self.m_material_id_table[i]
        local cardData,heroCfg = game_data:getCardDataById(heroId);

        local advance_step = cardData.step -- 进阶层数
        local lv = cardData.lv  --等级
        local quality = cardData.quality
        if advance_step >= 1 and quality >= 2 then
            local sliver_min,gold_min,sliver_max,gold_max = game_util:getDirValueById(heroId)
            local params = {}
            params.m_openType = 7
            params.hero_id = heroId
            params.sliver_dir_basis = sliver_min .. "-" .. sliver_max
            params.gold_dir_basis = gold_min .. "-" .. gold_max
            params.okBtnCallBack = function()
                game_scene:removePopByName("game_special_tips_pop")
                self.m_root_layer:setTouchEnabled(true);
                sendRequest();
            end
            game_scene:addPop("game_special_tips_pop",params)
            break;
        elseif lv >= 10 then
            local params = {}
            params.m_openType = 8
            params.hero_id = heroId
            params.okBtnCallBack = function()
                game_scene:removePopByName("game_special_tips_pop")
                self.m_root_layer:setTouchEnabled(true);
                sendRequest();
            end
            game_scene:addPop("game_special_tips_pop",params)
            break;
        else
            self.m_root_layer:setTouchEnabled(true);
            sendRequest();
            break;
        end
    end

end

--[[--
    
]]
function game_hero_advanced_sure.responseSuccess(self)
    game_scene:removeGuidePop();
    local endFlag = false;
    local function responseEndFunc()
        if endFlag == true then return end
        self.m_root_layer:setTouchEnabled(false);
        endFlag = true;
        game_sound:playUiSound("evo_success")
        self:addAdvancedAnim();
        self.m_material_id_table = {};
        self.m_evo_food = 0;
        self:refreshByType(1);
        -- self.m_ccbNode:addChild(game_util:animSuccessCCBAnim(nil,"evolution_success"));
        local pX,pY = self.m_sel_btn:getPosition();
        local tempPos = self.m_sel_btn:getParent():convertToWorldSpace(ccp(pX,pY));
        local tempAnim = game_util:createUniversalAnim({animFile = "animi_hero_jinjie",rhythm = 1.0,loopFlag = false,animCallFunc = nil});
        if tempAnim then
            tempAnim:setPosition(tempPos)
            game_scene:getPopContainer():addChild(tempAnim,100)
        end
        local id = game_guide_controller:getIdByTeam("5");
        if id == 509 then
            game_guide_controller:gameGuide("send","5",509);
            -- self:gameGuide("drama","5",511);
        end
        self:refreshCombatLabel();
    end
    local removeIndex = #self.m_material_id_table
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,#self.m_material_id_table do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
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
                    removeIndex = removeIndex - 1;
                    if removeIndex == 0 then
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
            removeIndex = removeIndex - 1;
            if removeIndex == 0 then
                responseEndFunc();
                -- self.m_ccbNode:runAnimations("success_anim")
            end
        end
    end
    -- self.m_progress_bar:setCurValue(100,true);
    local posIndex = 1;
    for k,v in pairs(self.m_degreeTab) do
        if v == evo then
            posIndex = k;
            break;
        end
    end
    posIndex = math.min(posIndex,#self.m_degreeTab)
    self.m_progress_bar:setCurValue((posIndex/#self.m_degreeTab)*100,true,1);
end

--[[--
    材料层
]]
function game_hero_advanced_sure.initMaterialLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
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
function game_hero_advanced_sure.refreshMaterial(self)
    local material_node_size = self.m_material_node:getContentSize();
    local itemWidth = material_node_size.width/5
    local startX = material_node_size.width*0.5 - itemWidth*0.5*(self.m_needMaterialCount - 1)
    local tempHeadIcon = nil;
    local m_material_node,m_mate_tips = nil,nil;
    local tempSize = nil;
    for index=1,#self.m_material_node_tab do
        m_material_node = self.m_material_node_tab[index].m_material_node;
        m_mate_tips = self.m_material_node_tab[index].m_mate_tips;
        m_material_node:removeAllChildrenWithCleanup(true);
        if self.m_selHeroId then
            if index <= self.m_needMaterialCount then
                m_material_node:setPositionX(startX + itemWidth*(index - 1))
                m_mate_tips:setPositionX(startX + itemWidth*(index - 1))
                m_material_node:setVisible(true);
                if self.m_material_id_table[index] ~= nil  then
                    local card_id = tostring(self.m_material_id_table[index])
                    local _,cardCfg = game_data:getCardDataById(card_id)
                    tempHeadIcon = game_util:createCardIconByCfg(cardCfg)
                    if tempHeadIcon then
                        tempSize = m_material_node:getContentSize();
                        tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                        m_material_node:addChild(tempHeadIcon,10,10);
                    end
                    m_mate_tips:setVisible(false);
                else
                    local _,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
                    local tempHeadIcon = game_util:createIconByName(heroCfg:getNodeWithKey("img"):toStr())
                    if tempHeadIcon then
                        tempHeadIcon:setColor(ccc3(81,81,81));
                        tempSize = m_material_node:getContentSize();
                        tempHeadIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                        m_material_node:addChild(tempHeadIcon,10,10);
                    end
                    m_mate_tips:setVisible(true);
                end
            else
                m_material_node:setVisible(false);
                m_mate_tips:setVisible(false);
            end
        else
            m_material_node:removeAllChildrenWithCleanup(true);
            m_material_node:setVisible(true);
            m_mate_tips:setVisible(true);
        end
    end
end

--[[--

]]
function game_hero_advanced_sure.addAdvancedAnim(self)
    if self.m_popUi then return end
    local ccbNode = luaCCBNode:create();
    self.m_popUi = ccbNode;
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            ccbNode:removeFromParentAndCleanup(true);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_advanced_anim.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
    local tempNode = game_util:createHeroListItemByCCB(cardData);
    m_anim_node:addChild(tempNode,10,10);

    -- {typeName = "速度:",add_value = add_speed,attr = "speed",attr_value = 4}
    self.m_addAttrTab = self.m_addAttrTab or {};
    local tempCount = #self.m_addAttrTab
    for i=1,3 do
        local m_attr_icon = ccbNode:spriteForName("m_attr_icon_" .. i)
        local m_value_label1 = ccbNode:labelBMFontForName("m_value_label_" .. i)
        local m_value_label2 = ccbNode:labelBMFontForName("m_value_label_" .. i .. i)
        if i > tempCount then
            m_attr_icon:getParent():setVisible(false);
        else
            local itemData = self.m_addAttrTab[i]
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. itemData.attr_value].icon)
            if tempSpriteFrame then
                m_attr_icon:setDisplayFrame(tempSpriteFrame)
            end
            m_value_label1:setString(tostring(cardData[tostring(itemData.attr)] - itemData.add_value));
            m_value_label2:setString("+" .. tostring(itemData.add_value));
        end
    end
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg);--game_util:getEvolutionCfgByQuality(quality);
    local skill_detail_cfg = getConfig("skill_detail");
    if evolutionCfg then
        local evo = cardData.evo
        local evolutionItemCfg = evolutionCfg:getNodeWithKey(tostring(evo));
        if evolutionItemCfg then
            local story = evolutionItemCfg:getNodeWithKey("story")
            if story then
                story = story:toStr();
                for i=1,3 do
                    local firstValue,_ = string.find(story,"skill" .. i);
                    if firstValue then
                            local skillItem = cardData["s_" .. i];
                            if skillItem and skillItem.s ~= 0 then
                                local skillItemCfg = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                                if skillItemCfg then
                                    story = string.gsub(story,"skill" .. i,skillItemCfg:getNodeWithKey("skill_name"):toStr());
                                    m_tips_label:setString(story)
                                end
                            end
                        break;
                    end
                end
            end
        end
    end

    local m_skill_icon_bg = ccbNode:spriteForName("m_skill_icon_bg");
    local tempSize = m_skill_icon_bg:getContentSize();
    local aminFlag = true;
    if self.m_change_skill_data then
        local tempIcon = game_util:createSkillIconByCid(self.m_change_skill_data.s)
        if tempIcon then
            tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
            m_skill_icon_bg:addChild(tempIcon);
        end
    else
        cclog("self.m_atrrChangedType  ======== " .. tostring(self.m_atrrChangedType))
        if self.m_atrrChangedType == 1 then
            local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_shuxing.png")
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                m_skill_icon_bg:addChild(tempIcon);
            end
        elseif self.m_atrrChangedType == 2 then
            local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_dengji.png")
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                m_skill_icon_bg:addChild(tempIcon);
            end
        else
            aminFlag =false;
        end
    end

    local function playAnimEnd(animName)
        if animName == "start_anim" and aminFlag == true then
            ccbNode:runAnimations("icon_anim");
        elseif animName == "icon_anim" and aminFlag == true then
            local animFile = "anim_icon_disappear"
            local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
            if mAnimNode then
                local function onAnimSectionEnd(animNode, theId,theLabelName)
                    if theLabelName == "impact1" then
                        animNode:playSection("impact2");
                    else
                        mAnimNode:removeFromParentAndCleanup(true);
                    end
                end
                mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                mAnimNode:playSection("impact1");
                mAnimNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                mAnimNode:setScale(1.3);
                m_skill_icon_bg:addChild(mAnimNode,10,10);
            end
        end
    end
    ccbNode:registerAnimFunc(playAnimEnd);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_popUi then
                self.m_popUi:removeFromParentAndCleanup(true);
                self.m_popUi = nil;
            end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-100,true);
    m_root_layer:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_popUi,1000,1000);
end

--[[--
    属性英雄信息
]]
function game_hero_advanced_sure.refreshHeroInfo(self,heroId)
    self.m_lookAttrTab = {};
    self.m_progress_bar:setCurValue(0,false);
    self.m_degreeTab = {};
    self.m_atrrChangedType = 0;
    self.m_change_skill_data = nil;
    self.m_needMaterialCount = 1;
    self.m_status = 0;
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_skill_icon_bg:removeAllChildrenWithCleanup(true)
    self.m_skill_up_label:setString(string_helper.game_hero_advanced_sure.wu);
    self.m_warning_label:setString(string_helper.game_hero_advanced_sure.text7);
    self.m_evo_food = 0;
    self.m_selHeroData = nil;
    self.m_stage_spr_1:setVisible(false)
    self.m_stage_spr_2:setVisible(false)
    self.m_stage_look_btn_1:setVisible(false)
    self.m_stage_look_btn_2:setVisible(false)
    for k,v in pairs(self.m_attr_label_tab) do
        v.m_attr_label:setString("---");
        v.m_value_label:setString("---");
        v.m_attr_label:setVisible(k ~= 4);
        v.m_value_label:setVisible(k ~= 4);
    end
	if heroId ~= nil and heroId ~= "-1" then
        self.m_tips_spr_1:setVisible(false);
        self.m_tips_spr_2:setVisible(false);
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        self.m_selHeroData = cardData;
        local card_lv = cardData.lv
        -- local level_max = cardData.level_max
        -- if card_lv >= level_max then
        -- else
        --     self.m_status = 1;--等级没达到最大级
        -- end
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local add_hp,add_patk,add_matk,add_def,add_speed = 0,0,0,0,0,0;
        local attrValue,attrIndex = 0,1;
        local quality = heroCfg:getNodeWithKey("quality"):toInt();
        local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg);--game_util:getEvolutionCfgByQuality(quality);
        if evolutionCfg then
            local level_max = cardData.level_max;
            self.m_level_label_1:setString("+" .. cardData.step);
            self.m_level_label_2:setString("+" .. cardData.step);
            local max_evo = evolutionCfg:getNodeCount();
            local evo = cardData.evo
            if evo > -1 and evo < (max_evo - 1) then
                --种族    0-人类    1-变种人   2-丧尸    3-变异生物  4-机械    5-吸血鬼
                local race = heroCfg:getNodeWithKey("race"):toInt();
                local evolutionItemCfg = evolutionCfg:getNodeWithKey(tostring(evo+1));
                local degree = evolutionItemCfg:getNodeWithKey("degree")
                self.m_degreeTab = json.decode(degree:getFormatBuffer()) or {};
                local degree_count = #self.m_degreeTab;
                cclog("degree_count ====================== " .. degree_count .. " ; evo == " .. evo)
                if degree_count == 2 then
                    self.m_stage_spr_1:setVisible(true)
                    self.m_stage_look_btn_1:setVisible(true)
                    local tempSize = self.m_progress_bar_bg:getContentSize();
                    self.m_stage_spr_1:setPositionX(tempSize.width*0.5);
                    self.m_stage_look_btn_1:setPositionX(tempSize.width*0.5);
                elseif degree_count > 2 then
                    self.m_stage_spr_1:setVisible(true)
                    self.m_stage_spr_2:setVisible(true)
                    self.m_stage_look_btn_1:setVisible(true)
                    self.m_stage_look_btn_2:setVisible(true)
                end

                local need_level = evolutionItemCfg:getNodeWithKey("need_level"):toInt();
                self.m_evo_lv_label:setString(need_level .. string_helper.game_hero_advanced_sure.need_level);
                if card_lv < need_level then
                    self.m_status = 1;--等级没达到最大级
                end
                local player_level = evolutionItemCfg:getNodeWithKey("player_level")
                player_level = player_level and player_level:toInt() or 0
                self.m_player_level_label:setString(player_level .. string_helper.game_hero_advanced_sure.need_level);
                 local level = game_data:getUserStatusDataByKey("level") or 0
                if level < player_level then
                    self.m_status = 4;--等级没达到最大级
                end
                local evolutionItemCfg1,evolutionItemCfg2 = nil,nil
                if degree_count == 1 then
                    evolutionItemCfg1 = evolutionCfg:getNodeWithKey(tostring(evo));
                    evolutionItemCfg2 = evolutionItemCfg;
                elseif degree_count >= 2 then
                    evolutionItemCfg1 = evolutionCfg:getNodeWithKey(tostring(self.m_degreeTab[1] - 1))
                    evolutionItemCfg2 = evolutionCfg:getNodeWithKey(tostring(self.m_degreeTab[degree_count]));
                    local posIndex = 0;
                    local tempCount = math.min(#self.m_degreeTab,3)
                    local tempEvo;
                    for i=1,tempCount do
                        tempEvo = self.m_degreeTab[i]
                        if tempEvo == evo then
                            posIndex = i;
                            game_util:setCCControlButtonBackground(self["m_stage_look_btn_" .. i],"hbjj_chakan.png");
                        elseif tempEvo < evo then
                            game_util:setCCControlButtonBackground(self["m_stage_look_btn_" .. i],"hbjj_chakan.png");
                        else
                            game_util:setCCControlButtonBackground(self["m_stage_look_btn_" .. i],"hbjj_chakan_1.png");
                        end
                        if i < tempCount then
                            local tempItemCfg1 = evolutionCfg:getNodeWithKey(tostring(tempEvo-1));
                            local tempItemCfg2 = evolutionCfg:getNodeWithKey(tostring(tempEvo));
                            if tempItemCfg1 == nil and tempItemCfg2 then
                                local attrType = tempItemCfg2:getNodeWithKey("type" .. race)
                                self.m_lookAttrTab[i] = json.decode(attrType:getFormatBuffer()) or {0,0,0,0,0};
                            elseif tempItemCfg1 and tempItemCfg2 then
                                local tempTab = {0,0,0,0,0}
                                local attrType1 = tempItemCfg1:getNodeWithKey("type" .. race)
                                local attrType2 = tempItemCfg2:getNodeWithKey("type" .. race)
                                for i=1,5 do
                                    tempTab[i] = attrType2:getNodeAt(i-1):toInt() - attrType1:getNodeAt(i-1):toInt()
                                end
                                self.m_lookAttrTab[i] = tempTab
                            else
                                self.m_lookAttrTab[i] = {0,0,0,0,0}
                            end
                        end
                    end
                    cclog("evo ======= " .. evo);
                    self.m_progress_bar:setCurValue((posIndex/#self.m_degreeTab)*100,false);
                end
                local tempSize = self.m_skill_icon_bg:getContentSize();
                if evolutionItemCfg1 and evolutionItemCfg2 then
                    -- local attrType = evolutionItemCfg2:getNodeWithKey("type" .. race)
                    local level_off = evolutionItemCfg2:getNodeWithKey("level_off"):toInt();
                    -- self.m_level_label_2:setString((card_lv - level_off) .. "/" .. evolutionItemCfg2:getNodeWithKey("maxlv"):toStr());  
                    if level_off > 0 then
                        self.m_warning_label:setString(string.format(string_helper.game_hero_advanced_sure.advanced_text,level_off))
                    end
                    self.m_level_label_2:setString("+" .. evolutionItemCfg2:getNodeWithKey("step"):toStr());                  
                    local maxlv = evolutionItemCfg2:getNodeWithKey("maxlv"):toInt();
                    cclog("maxlv =========== " .. maxlv .. " ; level_max == " .. level_max)
                    if maxlv > level_max then
                        self.m_atrrChangedType = 2;
                        local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_dengji.png")
                        if tempIcon then
                            tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                            self.m_skill_icon_bg:addChild(tempIcon);
                        end
                        self.m_skill_up_label:setString(string_helper.game_hero_advanced_sure.level_top .. (maxlv-level_max));
                    end
                    local skill1 = evolutionItemCfg1:getNodeWithKey("skill")
                    local skill2 = evolutionItemCfg2:getNodeWithKey("skill")
                    local skillIndex = -1;
                    local evoStep = -1;
                    for i=1,3 do
                        evoStep = skill2:getNodeAt(i-1):toInt()
                        if evoStep ~= skill1:getNodeAt(i-1):toInt() then
                            skillIndex = i;
                            break;
                        end
                    end
                    local skillItem = cardData["s_" .. skillIndex]
                    if skillItem then
                        self.m_change_skill_data = util.table_copy(skillItem);
                        if evoStep == 1 then
                            local tempIcon,skill_name = game_util:createSkillIconByCid(skillItem.s)
                            self.m_skill_up_label:setString(tostring(skill_name) .. string_helper.game_hero_advanced_sure.skill_open);
                            if tempIcon then
                                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                                self.m_skill_icon_bg:addChild(tempIcon);
                            end
                        elseif evoStep > 1 then
                            self.m_skill_up_label:setString(string_helper.game_hero_advanced_sure.skill_advanced);
                            local skill_detail_cfg = getConfig(game_config_field.skill_detail);
                            local itemCfg = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                            if itemCfg then
                                local is_evolution = itemCfg:getNodeWithKey("is_evolution"):toStr();
                                local skill_name = itemCfg:getNodeWithKey("skill_name"):toStr()
                                self.m_skill_up_label:setString(tostring(skill_name) .. string_helper.game_hero_advanced_sure.skill_advanced2);
                                self.m_change_skill_data.s = is_evolution
                                local tempIcon = game_util:createSkillIconByCid(is_evolution)
                                if tempIcon then
                                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                                    self.m_skill_icon_bg:addChild(tempIcon);
                                end
                            end
                        end
                    end
                    local attrType1 = evolutionItemCfg1:getNodeWithKey("type" .. race)
                    local attrType2 = evolutionItemCfg2:getNodeWithKey("type" .. race)
                    if attrType1 and attrType2 then
                        add_patk = attrType2:getNodeAt(0):toInt() - attrType1:getNodeAt(0):toInt()
                        add_matk = attrType2:getNodeAt(1):toInt() - attrType1:getNodeAt(1):toInt() 
                        add_def = attrType2:getNodeAt(2):toInt() - attrType1:getNodeAt(2):toInt()
                        add_speed = attrType2:getNodeAt(3):toInt() - attrType1:getNodeAt(3):toInt()
                        add_hp = attrType2:getNodeAt(4):toInt() - attrType1:getNodeAt(4):toInt()
                    end
                    local attrType11 = evolutionItemCfg1:getNodeWithKey("attr" .. race)
                    local attrType22 = evolutionItemCfg2:getNodeWithKey("attr" .. race)
                    if attrType11 and attrType22 then
                        for i=1,8 do
                            attrValue = attrType22:getNodeAt(i-1):toInt() - attrType11:getNodeAt(i-1):toInt()
                            if attrValue > 0 then
                                attrIndex = i;
                                break;
                            end
                        end
                    end
                    local all1 = evolutionItemCfg1:getNodeWithKey("all"):toFloat();
                    local all2 = evolutionItemCfg2:getNodeWithKey("all"):toFloat();
                    if all2 > all1 then
                        self.m_atrrChangedType = 1;
                        local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_shuxing.png")
                        if tempIcon then
                            tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                            self.m_skill_icon_bg:addChild(tempIcon);
                        end
                        self.m_skill_up_label:setString(string_helper.game_hero_advanced_sure.q_mel .. string.format("%.0f",(all2-all1)*100) .. "%");
                    end
                else
                    local attrType = evolutionItemCfg:getNodeWithKey("type" .. race)
                    -- 1：增加物攻  2：增加魔攻  3：增加防御  4：增加速度  5：增加生命
                    if attrType and attrType:getNodeCount() >= 5 then
                        add_patk = attrType:getNodeAt(0):toInt();
                        add_matk = attrType:getNodeAt(1):toInt();
                        add_def = attrType:getNodeAt(2):toInt();
                        add_speed = attrType:getNodeAt(3):toInt();
                        add_hp = attrType:getNodeAt(4):toInt();
                    end
                    local attrType2 = evolutionItemCfg:getNodeWithKey("attr" .. race)
                    if attrType2 then
                        for i=1,8 do
                            attrValue = attrType2:getNodeAt(i-1):toInt()
                            if attrValue > 0 then
                                attrIndex = i;
                                break;
                            end
                        end
                    end
                end
                local exp = evolutionItemCfg:getNodeWithKey("exp"):toInt();
                local needMaterialCount = math.min(math.floor(exp/10),6);
                self.m_needMaterialCount = needMaterialCount;
                cclog("needMaterialCount === " .. needMaterialCount)
                self.m_evo_food = heroCfg:getNodeWithKey("evo_food"):toInt();
            else
                self.m_evo_lv_label:setString("---");
                self.m_player_level_label:setString("---");
                self.m_status = 2;--最高阶
            end
        end
        self.m_addAttrTab = {};
        local posIndex = 1;
        -- 1:物攻 2:魔攻 3:防御 4:速度 5:生命
        if add_hp > 0 then
            self.m_attr_label_tab[posIndex].m_attr_label:setString(string_helper.game_hero_advanced_sure.hp);
            self.m_attr_label_tab[posIndex].m_value_label:setString("+" .. add_hp);
            posIndex = posIndex + 1;
            table.insert(self.m_addAttrTab,{typeName = string_helper.game_hero_advanced_sure.hp,add_value = add_hp,attr = "hp",attr_value = 5})
        end
        if add_patk > 0 then
            self.m_attr_label_tab[posIndex].m_attr_label:setString(string_helper.game_hero_advanced_sure.patk);
            self.m_attr_label_tab[posIndex].m_value_label:setString("+" .. add_patk);
            posIndex = posIndex + 1;
            table.insert(self.m_addAttrTab,{typeName = string_helper.game_hero_advanced_sure.patk,add_value = add_patk,attr = "patk",attr_value = 1})
        end
        if add_matk > 0 then
            self.m_attr_label_tab[posIndex].m_attr_label:setString(string_helper.game_hero_advanced_sure.matk);
            self.m_attr_label_tab[posIndex].m_value_label:setString("+" .. add_matk);
            posIndex = posIndex + 1;
            table.insert(self.m_addAttrTab,{typeName = string_helper.game_hero_advanced_sure.matk,add_value = add_matk,attr = "matk",attr_value = 2})
        end
        if add_def > 0 and posIndex < 4 then
            self.m_attr_label_tab[posIndex].m_attr_label:setString(string_helper.game_hero_advanced_sure.def);
            self.m_attr_label_tab[posIndex].m_value_label:setString("+" .. add_def);
            posIndex = posIndex + 1;
            table.insert(self.m_addAttrTab,{typeName = string_helper.game_hero_advanced_sure.def,add_value = add_def,attr = "def",attr_value = 3})
        end
        if add_speed > 0 and posIndex < 4 then
            self.m_attr_label_tab[posIndex].m_attr_label:setString(string_helper.game_hero_advanced_sure.speed);
            self.m_attr_label_tab[posIndex].m_value_label:setString("+" .. add_speed);
            posIndex = posIndex + 1;
            table.insert(self.m_addAttrTab,{typeName = string_helper.game_hero_advanced_sure.speed,add_value = add_speed,attr = "speed",attr_value = 4})
        end
        if attrValue > 0 then
            local attrTypeIndex = COMBAT_ABILITY_TABLE.card_evo[attrIndex]
            local m_attr_label = self.m_attr_label_tab[4].m_attr_label
            m_attr_label:setString(PUBLIC_ABILITY_TABLE["ability_" .. attrTypeIndex].name .. ":");
            local m_value_label = self.m_attr_label_tab[4].m_value_label
            m_value_label:setString("+" .. attrValue);
            m_attr_label:setVisible(true)
            m_value_label:setVisible(true)
        end
    else
        self.m_tips_spr_1:setVisible(true);
        self.m_tips_spr_2:setVisible(false);
        self.m_level_label_1:setString("---");
        self.m_level_label_2:setString("---");
        self.m_stage_spr_1:setVisible(false)
        self.m_stage_spr_2:setVisible(false)
        self.m_stage_look_btn_1:setVisible(false)
        self.m_stage_look_btn_2:setVisible(false)
        self.m_evo_lv_label:setString("---");
        self.m_player_level_label:setString("---");
	end
    self:refreshMaterial();
end

--[[--
    过虑材料数据材料
进阶材料  
+0-+4  uid一样  万能橙卡
+5-+7  uid一样  万能红卡
+8+14  uid一样  万能红卡  uid不一样，cid一样  材料卡品质 >= 本卡
+15-+23  uid一样  万能红卡
+24以上  uid一样  万能金卡
]]
function game_hero_advanced_sure.filterMaterialData(self)
    local character_ID,character_ID2,c_ID,c_ID2 = -1;
    local heroData = nil;
    local itemConfig = nil;
    local needStep = 0;
    local selQuality = 0;
    local heroQuality = 0
    if self.m_selHeroId ~= nil then
        heroData,itemConfig = game_data:getCardDataById(tostring(self.m_selHeroId));
        needStep = heroData.step
        character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
        c_ID = itemConfig:getKey()
        heroQuality = itemConfig:getNodeWithKey("quality") and itemConfig:getNodeWithKey("quality"):toInt() or heroQuality
    end
    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    local level_max,quality = nil;
    for key,heroData in pairs(cardsDataTable) do
        if key ~= tostring(self.m_selHeroId) and not game_data:heroInTeamById(key) and not game_data:heroInAssistantById(key) then
            itemConfig = character_detail:getNodeWithKey(heroData.c_id);
            character_ID2 = itemConfig:getNodeWithKey("character_ID"):toInt();
            c_ID2 = itemConfig:getKey();
            local cardQuality = itemConfig:getNodeWithKey("quality") and itemConfig:getNodeWithKey("quality"):toInt() or 8
            if needStep < 23 then
                if selQuality <= 3 then
                    if c_ID == c_ID2 or (character_ID2 == 1000 and needStep < 4) or (character_ID2 == 1001) then
                        showHeroTable[#showHeroTable+1] = heroData.id;
                    end
                elseif selQuality == 4 then
                    if c_ID == c_ID2 or (character_ID2 == 1001 and needStep < 4) or (character_ID2 == 1002 and needStep >= 4) then
                        showHeroTable[#showHeroTable+1] = heroData.id;
                    end
                else
                    if c_ID == c_ID2 then
                        showHeroTable[#showHeroTable+1] = heroData.id;
                    end
                end
                if needStep >= 7 and needStep < 14 and (character_ID == character_ID2 and c_ID ~= c_ID2) then
                    if cardQuality >= heroQuality then   -- 品质 >= 本卡 
                        showHeroTable[#showHeroTable+1] = heroData.id;
                    end
                end
            elseif needStep < 30 then
                if c_ID == c_ID2 or (character_ID2 == 1003 and selQuality >= 4) then
                    showHeroTable[#showHeroTable+1] = heroData.id;
                end
            else
                if (character_ID2 == 1003 and selQuality >= 4) then
                    showHeroTable[#showHeroTable+1] = heroData.id;
                end
            end
        end
    end
    game_data:cardsSortByTypeNameWithTable(CARD_SORT_TAB[self.m_selFilterCardSortIndex].sortType,showHeroTable);
    self.m_showHeroTable = showHeroTable;
end

--[[--
    创建筛选的列表
]]
function game_hero_advanced_sure.createFilterTableView(self,viewSize)
    self.m_selListItem = nil;
    self.m_guildNode = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

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
                local itemData,itemCfg = game_data:getCardDataById(showHeroTable[index+1]);
                if itemData and itemCfg then
                    local heroId = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
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
            local itemData,_ = game_data:getCardDataById(showHeroTable[index+1]);
            local heroId = tostring(itemData.id);
            local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
            if flag and k ~= nil then
                -- cclog("remove select material hero id ==========" .. heroId);
                table.remove(self.m_material_id_table,k);
                m_sel_img:setVisible(false);
                sprite_back_alpha:setVisible(false);
                self:refreshMaterial();
            else
                local selMaterialCount = #self.m_material_id_table
                if selMaterialCount < 6 and selMaterialCount < self.m_needMaterialCount then
                    -- cclog("add select material hero id ==========" .. heroId);
                    table.insert(self.m_material_id_table,heroId);
                    m_sel_img:setVisible(true);
                    sprite_back_alpha:setVisible(true);
                    self:refreshMaterial();
                end
            end
        elseif eventType == "longClick" and cell then
            local itemData = showHeroTable[index+1].heroData;
            local function callBack(typeName)
                typeName = typeName or "";
                if typeName == "refresh" then
                    self:refreshFilterCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
    end
    return TableViewHelper:create(params);
end

--[[--
    创建英雄列表
]]
function game_hero_advanced_sure.createTableView(self,viewSize)
    self.m_selListItem = nil;
    self.m_guildNode = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local id = game_guide_controller:getIdByTeam("5");
    if id == 505 then
        params.itemActionFlag = false;
    else
        params.itemActionFlag = true;
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
            cell:setTag(index);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData,itemCfg = game_data:getCardDataByIndex(index+1);--self.m_selHeroTab[index+1].heroData;
            if itemData then
                local card_id = itemData.id;
                game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                if self.m_selHeroId and self.m_selHeroId == card_id then
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(true);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(true);
                    self.m_selListItem = cell;
                end
                local m_team_img = ccbNode:spriteForName("sprite_chuzhan")
                local quality = itemCfg:getNodeWithKey("quality"):toInt();
                local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(itemCfg);--game_util:getEvolutionCfgByQuality(quality);
                local character_ID = itemCfg:getNodeWithKey("character_ID"):toInt()
                if evolutionCfg then
                    local max_evo = evolutionCfg:getNodeCount();
                    local evo = itemData.evo
                    -- cclog("evo === " .. evo .. " ; max_evo == " .. max_evo)
                    if evo > -1 and evo < (max_evo-1) then
                        local tempEvoItem = evolutionCfg:getNodeWithKey(tostring(evo+1))
                        -- local level_max = itemData.level_max
                        local need_level = tempEvoItem:getNodeWithKey("need_level"):toInt();
                        if itemData.lv < need_level then
                            m_team_img:setVisible(true);
                            m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_dengjibuzu.png"));
                        else
                            if self.m_guildNode == nil and character_ID == 38 then
                                cell:setContentSize(itemSize);
                                self.m_guildNode = cell;
                            end
                        end
                    else
                        m_team_img:setVisible(true);
                        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_zuigaojie.png"));
                    end
                else
                    local level_max = itemData.level_max
                    if itemData.lv < level_max then
                        m_team_img:setVisible(true);
                        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_dengjibuzu.png"));
                    else
                        if self.m_guildNode == nil and character_ID == 38 then
                            cell:setContentSize(itemSize);
                            self.m_guildNode = cell;
                        end
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
            local itemData,itemCfg = game_data:getCardDataByIndex(index+1);--self.m_selHeroTab[index+1].heroData,self.m_selHeroTab[index+1].heroCfg;
            local is_evo = itemCfg:getNodeWithKey("is_evo")
            if is_evo and is_evo:toInt() == 0 then
                game_util:addMoveTips({text = string_helper.game_hero_advanced_sure.text8});
                return;
            end
            local card_id = itemData.id;
            if self.m_selHeroId == nil or self.m_selHeroId ~= card_id then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                self:refreshTips();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);

                local id = game_guide_controller:getIdByTeam("5");
                if id == 507 then
                    game_guide_controller:gameGuide("show","5",508,{tempNode = self.m_auto_add_btn})
                end
            end
        elseif eventType == "longClick" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1);--self.m_selHeroTab[index+1].heroData
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
    return TableViewHelper:create(params);
end

--[[--

]]
function game_hero_advanced_sure.refreshSortTabBtn(self,sortIndex)
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
function game_hero_advanced_sure.refreshByType(self,showType)
    self.m_no_material_tips:setVisible(false);
    self.m_showType = showType;
    if showType == 1 then
        self.m_material_id_table = {};
        self:refreshHeroInfo(self.m_selHeroId);
        -- self.m_cost_food_label:setString("0");
        self:refreshSortTabBtn(self.m_selSortIndex);
        self:refreshCardTableView();
    elseif showType == 2 then
        self:refreshSortTabBtn(self.m_selFilterCardSortIndex);
        self:refreshFilterCardTableView();
    end
    self:refreshTips();
end

--[[--
    刷新状态
]]
function game_hero_advanced_sure.refreshTips(self)
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_showType == 1 then
        if self.m_selHeroId == nil then
            self.m_tips_spr_1:setVisible(true);
            self.m_tips_spr_2:setVisible(false);
            for i=1,math.min(self.m_needMaterialCount,6) do
                self.m_material_node_tab[i].m_mate_tips:stopAllActions();
                self.m_material_node_tab[i].m_mate_tips:setOpacity(255);
            end
            game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
            self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
            self.m_light_bg_1:runAction(game_util:createRepeatForeverFade())
        else
            self.m_tips_spr_1:setVisible(false);
            self.m_tips_spr_2:setVisible(false);
            for i=1,math.min(self.m_needMaterialCount,6) do
                self.m_material_node_tab[i].m_mate_tips:runAction(game_util:createRepeatForeverFade())
            end
        end
    elseif self.m_showType == 2 then
        self.m_tips_spr_1:setVisible(false);
        self.m_tips_spr_2:setVisible(false);
    end
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
    -- game_util:setCostLable(self.m_cost_food_label,self.m_evo_food,totalFood);
end

--[[--
    刷新
]]
function game_hero_advanced_sure.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    local id = game_guide_controller:getIdByTeam("5");
    if id == 505 then
        self.m_tableView:setMoveFlag(false)
        if self.m_guildNode then
            local index = self.m_guildNode:getTag();
            cclog("index ===== " .. index)
            local contentSize = self.m_tableView:getContentSize()
            local viewSize = self.m_tableView:getViewSize()
            local cellHeight = viewSize.height  / 5;--一个cell的高度
            if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
                self.m_tableView:setContentOffset(ccp(0,viewSize.height - contentSize.height + index * cellHeight))
            end
        end
    end
end

--[[--
    刷新
]]
function game_hero_advanced_sure.refreshFilterCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self:filterMaterialData();
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end
--[[--
    刷新
]]
function game_hero_advanced_sure.refreshCombatLabel(self)
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
function game_hero_advanced_sure.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function game_hero_advanced_sure.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_attr_label_tab = {};
    self.m_showType = 1;
    self.m_maxCrystalLv = 1;
    self.m_material_id_table = {};
    self.m_material_node_tab = {};
    self.m_evo_food = 0;
    self.m_status = 0;
    self.m_selFilterCardSortIndex = 1;
    self.m_selHeroTab = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.m_showHeroTable = {};
    self.m_needMaterialCount = 1;
    self.m_lookAttrTab = {};
    self.m_atrrChangedType = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_advanced_sure.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("5");
    if id == 505 then
        self:gameGuide("drama","5",506)
    end
    return uiNode;
end


--[[
    新手引导
]]
function game_hero_advanced_sure.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "5" and id == 506 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","5",507,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        -- elseif guide_team == "5" and id == 511 then
        --     local function endCallFunc()
        --         game_guide_controller:gameGuide("send","5",511);
        --     end
        --     t_params.guideType = "drama";
        --     t_params.endCallFunc = endCallFunc;
        --     game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end


return game_hero_advanced_sure;
