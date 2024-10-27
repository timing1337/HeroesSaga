
---  能晶培养 

local game_hero_culture_scene = {
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_attr_label_tab = nil,
    m_list_view_bg = nil,
    m_list_view_bg2 = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_attr_node = nil,
    m_maxCrystalLv = nil,
    m_selIndexTab = nil,
    m_selHeroDataBackup = nil,
    m_curPage = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_cost_crystal_label = nil,
    m_crystal_total_label = nil,
    m_needFood = nil,
    m_needCrystal = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_guildNode = nil,
    m_levelUpValue = nil,
    m_cultureLevelTab = nil,
    m_culture_sel_spr = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_back_btn = nil,
    curr_need_food = nil,
    curr_need_crystal = nil,
    m_can_up_flag = nil,
    m_openType = nil,
    m_selHeroData = nil,
    m_status = nil,
    m_crystal_total_label_2 = nil,
    m_curr_need_crystal_2 = nil,
    m_needCrystal_2 = nil,
    m_cost_crystal_label_2 = nil,
    m_need_level = nil,
    high_node = nil,
};
--[[--
    销毁ui
]]
function game_hero_culture_scene.destroy(self)
    -- body
    cclog("-----------------game_hero_culture_scene destroy-----------------");
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_attr_label_tab = nil;
    self.m_list_view_bg = nil;
    self.m_list_view_bg2 = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_attr_node = nil;
    self.m_maxCrystalLv = nil;
    self.m_selIndexTab = nil;
    self.m_selHeroDataBackup = nil;
    self.m_curPage = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_cost_crystal_label = nil;
    self.m_crystal_total_label = nil;
    self.m_needFood = nil;
    self.m_needCrystal = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_guildNode = nil;
    self.m_levelUpValue = nil;
    self.m_cultureLevelTab = nil;
    self.m_culture_sel_spr = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_back_btn = nil;
    self.curr_need_food = nil;
    self.curr_need_crystal = nil;
    self.m_can_up_flag = nil;
    self.m_openType = nil;
    self.m_selHeroData = nil;
    self.m_status = nil;
    self.m_crystal_total_label_2 = nil;
    self.m_curr_need_crystal_2 = nil;
    self.m_needCrystal_2 = nil;
    self.m_cost_crystal_label_2 = nil;
    self.m_need_level = nil;
    self.high_node = nil;
end

local typeTable = {
    {type="hp",typeName=string_helper.game_hero_culture_scene.hp,dataKey="hp_crystal",bg_img = "njgz_shengming_up.png",lv = 1,cfgKey1="need_crstal_hp",cfgKey2 = "add_hp"},
    {type="patk",typeName=string_helper.game_hero_culture_scene.patk,dataKey="patk_crystal",bg_img = "njgz_wugong_up.png",lv = 1,cfgKey1="need_crstal_patk",cfgKey2 = "add_patk"},
    {type="matk",typeName=string_helper.game_hero_culture_scene.matk,dataKey="matk_crystal",bg_img = "njgz_mogong_up.png",lv = 1,cfgKey1="need_crstal_matk",cfgKey2 = "add_matk"},
    {type="def",typeName=string_helper.game_hero_culture_scene.def,dataKey="def_crystal",bg_img = "njgz_fangyu_up.png",lv = 1,cfgKey1="need_crstal_def",cfgKey2 = "add_def"},
    {type="speed",typeName=string_helper.game_hero_culture_scene.speed,dataKey="speed_crystal",bg_img = "njgz_sudu_up.png",lv = 1,cfgKey1="need_crstal_speed",cfgKey2 = "add_speed"},
};

--[[--
    返回
]]
function game_hero_culture_scene.back(self,backType)
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
    self:onSureFunc(callBackFunc);
end
--[[--
    读取ccbi创建ui
]]
function game_hero_culture_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then--开始改造
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = string_helper.game_hero_culture_scene.text});
                return;
            end
            if self.m_selIndexTab[1] == nil then
                game_util:addMoveTips({text = string_helper.game_hero_culture_scene.text2});
                return;
            end
            self:refreshHeroAttr(self.m_selHeroId,true);
            local id = game_guide_controller:getIdByTeam("15");
            if id == 1504 then
                game_scene:removeGuidePop();
                self:gameGuide("drama","15",1505)
            end
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
            game_data:cardsSortByTypeName(selSort);
            self:refreshSortTabBtn(btnTag - 200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local function onCultureBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 20 and btnTag < 26 then
            self:onSureFunc();
            if self.m_selIndexTab[1] ~= btnTag - 20 then
                self.m_status = 0;
                self.m_levelUpValue = 0;
                self.m_selIndexTab[1] = btnTag - 20;
                self:refreshHeroAttr(self.m_selHeroId);
                self:refreshTips();
                self.m_culture_sel_spr:setVisible(true);
                local pX,pY = tagNode:getPosition();
                self.m_culture_sel_spr:setPosition(ccp(pX,pY));
                local id = game_guide_controller:getIdByTeam("15");
                if id == 1503 then
                    game_guide_controller:gameGuide("show","15",1504,{tempNode = self.m_ok_btn})
                    game_guide_controller:gameGuide("send","15",1504);
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onCultureBtnClick",onCultureBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_culture.ccbi");

    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_list_view_bg2 = ccbNode:layerForName("m_list_view_bg2")
    self.m_attr_node = ccbNode:nodeForName("m_attr_node")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_cost_crystal_label = ccbNode:labelBMFontForName("m_cost_crystal_label")
    self.m_crystal_total_label = ccbNode:labelBMFontForName("m_crystal_total_label")
    self.m_crystal_total_label_2 = ccbNode:labelBMFontForName("m_crystal_total_label_2")
    self.m_cost_crystal_label_2 = ccbNode:labelBMFontForName("m_cost_crystal_label_2")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_culture_sel_spr = ccbNode:spriteForName("m_culture_sel_spr")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.high_node = ccbNode:nodeForName("high_node")
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    local tempLabel = nil;
    for i=1,1 do
        tempLabel = ccbNode:labelTTFForName("m_life_label_" .. i);
        self.m_attr_label_tab.hp[i] = tempLabel
        tempLabel = ccbNode:labelTTFForName("m_physical_atk_label_" .. i);
        self.m_attr_label_tab.patk[i] = tempLabel
        tempLabel = ccbNode:labelTTFForName("m_magic_atk_label_" .. i);
        self.m_attr_label_tab.matk[i] = tempLabel
        tempLabel = ccbNode:labelTTFForName("m_def_label_" .. i);
        self.m_attr_label_tab.def[i] = tempLabel
        tempLabel = ccbNode:labelTTFForName("m_speed_label_" .. i);
        self.m_attr_label_tab.speed[i] = tempLabel
    end
    for i=1,5 do
        self.m_cultureLevelTab[i] = ccbNode:labelTTFForName("m_culture_level_" .. i);
    end
    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    -- local function onTouch(eventType, x, y)
    --     if eventType == "began" then
    --         return true;--intercept event
    --     end
    -- end
    -- self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    -- self.m_root_layer:setTouchEnabled(false);
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    -- game_util:createScrollViewTips2(self.m_scroll_view_tips,{"njgz_wenzi.png","njgz_wenzi_1.png"});

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text83)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text84)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text85)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text86)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text234)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text235)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text236)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text237)
    local text5 = ccbNode:labelTTFForName("text5")
    text5:setString(string_helper.ccb.text238)
    local text6 = ccbNode:labelTTFForName("text6")
    text6:setString(string_helper.ccb.text239)
    local text7 = ccbNode:labelTTFForName("text7")
    text7:setString(string_helper.ccb.text240)
    local text8 = ccbNode:labelTTFForName("text8")
    text8:setString(string_helper.ccb.text241)
    local text9 = ccbNode:labelTTFForName("text9")
    text9:setString(string_helper.ccb.text242)

    self.high_node:setVisible(game_data:isViewOpenByID( 204 ))
    
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text243)
    return ccbNode;
end

--[[--
    确定强化 无动画
]]
function game_hero_culture_scene.onSureFunc(self,callBackFunc)
    -- if #self.m_selIndexTab == 0 or self.m_selHeroId == nil or self.m_levelUpValue < 2 then
    if #self.m_selIndexTab == 0 or self.m_selHeroId == nil or self.m_levelUpValue < 1 then
        if callBackFunc then
            callBackFunc();
        end
        return
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self.m_status = 0;
            self.m_levelUpValue = 0;
            if gameData == nil then
                self:refreshHeroInfo(self.m_selHeroId);
                return;
            end
            game_scene:removeGuidePop();
            -- game_scene:getPopContainer():addChild(game_util:animSuccessCCBAnim(nil,"strengthen_success"));
            self:refreshHeroInfo(self.m_selHeroId);
            if callBackFunc then
                callBackFunc();
            end
        end
        -- card_id=1&type=def
        local params = "card_id=" .. self.m_selHeroId
        local itemData = typeTable[self.m_selIndexTab[1]];
        local selType = itemData.type;
        for i=1,self.m_levelUpValue do
            params = params .. "&type=" .. selType
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("laboratory_level_up"), http_request_method.GET, params,"laboratory_level_up",true,true)
    end
    sendRequest();
end

--[[--
    属性英雄信息
]]
function game_hero_culture_scene.refreshHeroInfo(self,heroId)
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
	if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local starCount = cardData.star
        local character_strengthen = getConfig("character_strengthen");
        local character_strengthen_count = character_strengthen:getNodeCount();
        -- local crystal_item = nil;
        -- for i=1,character_strengthen_count do
        --     crystal_item = character_strengthen:getNodeAt(i-1);
        --     if crystal_item:getNodeWithKey("need_star"):toInt() == starCount then
        --         self.m_maxCrystalLv = math.max(self.m_maxCrystalLv,tonumber(crystal_item:getKey()));
        --     end
        -- end
        -- local lv = cardData.lv
        -- if lv < 10 then
        --     self.m_maxCrystalLv = 0--character_strengthen_count;
        -- elseif lv < 20 then
        --     self.m_maxCrystalLv = 5
        -- elseif lv < 30 then
        --     self.m_maxCrystalLv = 10
        -- elseif lv < 40 then
        --     self.m_maxCrystalLv = 15
        -- else
        --     self.m_maxCrystalLv = 20
        -- end
        self.m_maxCrystalLv = character_strengthen_count;
        self:refreshHeroAttr(heroId);
    else
        self:refreshTips();
	end
end


--[[--
    属性英雄信息
    0~9：不可以进行属性改造
    10~19：可以改造到5级
    20~29：可以改造到10级
    30~39：可以改造到15级
    40+：可以改造到20级
]]
function game_hero_culture_scene.refreshHeroAttr(self,heroId,addLvFlag)
    if addLvFlag == nil then addLvFlag = false end
    if heroId ~= nil and heroId ~= "-1" then
        if self.m_status == 1 then
            local t_params = 
            {
                m_openType = 5,
                m_call_func = function()
                    self.m_can_up_flag = true
                    self:refreshTips()
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
            return
        elseif self.m_status == 2 then
            local t_params = 
            {
                m_openType = 8,
                m_call_func = function()
                    self.m_can_up_flag = true
                    self:refreshTips()
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
            return
        elseif self.m_status == 3 then--高级能晶不足
            game_util:addMoveTips({text = string_helper.game_hero_culture_scene.text3})
            return
        elseif self.m_status == 4 then--没达到等级要求
            game_util:addMoveTips({text = string_helper.game_hero_culture_scene.text4 .. tostring(self.m_need_level) .. string_helper.game_hero_culture_scene.lv});
            return;
        end

        if self.m_levelUpValue == 0 and addLvFlag == false then
            self.m_levelUpValue = 0--1;
            self.m_can_up_flag = true;
        end
        local tempLevelUpValue = self.m_levelUpValue
        cclog("self.m_can_up_flag ======================= " .. tostring(self.m_can_up_flag))
        if addLvFlag and self.m_can_up_flag == true then
            tempLevelUpValue = tempLevelUpValue + 1;
        end
        local character_strengthen = getConfig("character_strengthen");
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local hp,patk,matk,def,speed = cardData.hp,cardData.patk,cardData.matk,cardData.def,cardData.speed
        local hp_crystal_lv,patk_crystal_lv,matk_crystal_lv,def_crystal_lv,speed_crystal_lv = cardData.hp_crystal,cardData.patk_crystal,cardData.matk_crystal,cardData.def_crystal,cardData.speed_crystal
        self.m_selHeroData = cardData;

        typeTable[1].lv=math.min(self.m_maxCrystalLv,hp_crystal_lv+tempLevelUpValue)
        typeTable[2].lv=math.min(self.m_maxCrystalLv,patk_crystal_lv+tempLevelUpValue)
        typeTable[3].lv=math.min(self.m_maxCrystalLv,matk_crystal_lv+tempLevelUpValue)
        typeTable[4].lv=math.min(self.m_maxCrystalLv,def_crystal_lv+tempLevelUpValue)
        typeTable[5].lv=math.min(self.m_maxCrystalLv,speed_crystal_lv+tempLevelUpValue)
        typeTable[1].lv1=hp_crystal_lv
        typeTable[2].lv1=patk_crystal_lv
        typeTable[3].lv1=matk_crystal_lv
        typeTable[4].lv1=def_crystal_lv
        typeTable[5].lv1=speed_crystal_lv

        -- cclog("self.m_maxCrystalLv ==="  .. self.m_maxCrystalLv)
        -- cclog("hp_crystal_lv ==="  .. hp_crystal_lv)
        -- cclog("patk_crystal_lv ==="  .. patk_crystal_lv)
        -- cclog("matk_crystal_lv ==="  .. matk_crystal_lv)
        -- cclog("def_crystal_lv ==="  .. def_crystal_lv)
        -- cclog("speed_crystal_lv ==="  .. speed_crystal_lv)

        local add_hp,add_patk,add_matk,add_def,add_speed = 0,0,0,0,0;
        local attrTab = {hp=0,patk=0,matk=0,def=0,speed=0};
        local hp_item_cfg = character_strengthen:getNodeWithKey(tostring(hp_crystal_lv));
        if hp_item_cfg then
            add_hp = hp_item_cfg:getNodeWithKey("add_hp"):toInt();
            attrTab.hp = add_hp;
        end
        local patk_item_cfg = character_strengthen:getNodeWithKey(tostring(patk_crystal_lv));
        if patk_item_cfg then
            add_patk = patk_item_cfg:getNodeWithKey("add_patk"):toInt();
            attrTab.patk = add_patk;
        end
        local matk_item_cfg = character_strengthen:getNodeWithKey(tostring(matk_crystal_lv));
        if matk_item_cfg then
            add_matk = matk_item_cfg:getNodeWithKey("add_matk"):toInt();
            attrTab.matk = add_matk;
        end
        local def_item_cfg = character_strengthen:getNodeWithKey(tostring(def_crystal_lv));
        if def_item_cfg then
            add_def = def_item_cfg:getNodeWithKey("add_def"):toInt();
            attrTab.def = add_def;
        end
        local speed_item_cfg = character_strengthen:getNodeWithKey(tostring(speed_crystal_lv));
        if speed_item_cfg then
            add_speed = speed_item_cfg:getNodeWithKey("add_speed"):toInt();
            attrTab.speed = add_speed;
        end
        local function setValueFunc()
            if self.m_can_up_flag == false then return end
            game_util:setAttributeLable2(self.m_attr_label_tab.hp[1],add_hp,add_hp,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.patk[1],add_patk,add_patk,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.matk[1],add_matk,add_matk,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.def[1],add_def,add_def,"+");
            game_util:setAttributeLable2(self.m_attr_label_tab.speed[1],add_speed,add_speed,"+");
        end
        local selIndex = self.m_selIndexTab[1]
        if selIndex then
            local need_food = 0;
            local need_crystal = 0;
            local need_crystal_2 = 0;
            self.curr_need_food = 0;
            self.curr_need_crystal = 0;
            self.m_curr_need_crystal_2 = 0;
            self.m_need_level = 0;
            local itemData = typeTable[selIndex];
            local typeName = itemData.type;
            local add_temp_value = -1;
            for lv=itemData.lv1+1,itemData.lv+1 do
                local crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                if crystal_item then
                    local need_level = crystal_item:getNodeWithKey("need_level")
                    if need_level then
                        self.m_need_level = need_level:toInt();
                    end
                    add_temp_value = crystal_item:getNodeWithKey(itemData.cfgKey2):toInt();
                    need_food = need_food + crystal_item:getNodeWithKey("need_food"):toInt();
                    local need_crstal = crystal_item:getNodeWithKey(itemData.cfgKey1);
                    if need_crstal then
                        local crystal_type = need_crstal:getNodeAt(0):toInt();
                        if crystal_type == 1 then
                            need_crystal = need_crystal + need_crstal:getNodeAt(1):toInt();
                        elseif crystal_type == 2 then
                            need_crystal_2 = need_crystal_2 + need_crstal:getNodeAt(1):toInt();
                        end
                    end
                    cclog("itemData.lv+1 ============== " .. (itemData.lv+1) .. " ; lv = " .. lv)
                    if lv == itemData.lv+1 then
                        self.curr_need_food = crystal_item:getNodeWithKey("need_food"):toInt();
                        if need_crstal then
                            local crystal_type = need_crstal:getNodeAt(0):toInt();
                            if crystal_type == 1 then
                                self.curr_need_crystal = need_crstal:getNodeAt(1):toInt();
                            elseif crystal_type == 2 then
                                self.m_curr_need_crystal_2 = need_crstal:getNodeAt(1):toInt();
                            end
                        end
                    end
                end
            end
            local function setValueFunc2()
                if self.m_can_up_flag == false then return end
                if add_temp_value ~= -1 then
                    game_util:setAttributeLable2(self.m_attr_label_tab[typeName][1],attrTab[typeName],add_temp_value,"+");
                end
            end
            -- self.m_levelUpValue = math.min(self.m_maxCrystalLv +1 - itemData.lv1,tempLevelUpValue);
            -- self.m_levelUpValue = math.min(self.m_maxCrystalLv - itemData.lv1,tempLevelUpValue);
            self.m_needFood = need_food;
            self.m_needCrystal = need_crystal;
            self.m_needCrystal_2 = need_crystal_2;
            local totalFood = (game_data:getUserStatusDataByKey("food") or 0)
            local totalCrystal = (game_data:getUserStatusDataByKey("crystal") or 0)
            local totalCrystal_2 = (game_data:getUserStatusDataByKey("adv_crystal") or 0)
            if (need_food - self.curr_need_food) > totalFood then
                self.m_can_up_flag = false;
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 5,
                    m_call_func = function()
                        self.m_can_up_flag = true
                        self:refreshTips()
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
                -- game_util:addMoveTips({text = string.format(string_config.m_food_not_enough,self.curr_need_food)});
            elseif need_crystal - self.curr_need_crystal > totalCrystal then
                self.m_can_up_flag = false;
                -- game_util:addMoveTips({text = string.format(string_config.m_crystal_not_enough,self.curr_need_crystal)});
                --换成统一提示
                local t_params = 
                {
                    m_openType = 8,
                    m_call_func = function()
                        self.m_can_up_flag = true
                        self:refreshTips()
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            elseif need_crystal_2 - self.m_curr_need_crystal_2 > totalCrystal_2 then
                game_util:addMoveTips({text = string_helper.game_hero_culture_scene.text5});
            else
                self.m_levelUpValue = math.min(self.m_maxCrystalLv - itemData.lv1,tempLevelUpValue);
                if tempLevelUpValue > (self.m_maxCrystalLv + 1 - itemData.lv1) then
                    game_util:addMoveTips({text = string_config.m_lv_is_max});
                end
                if tempLevelUpValue > 1 then
                    game_sound:playUiSound("up_success")
                end
            end
            cclog("self.m_levelUpValue ======== " .. self.m_levelUpValue .. " ;tempLevelUpValue == " .. tempLevelUpValue)
            setValueFunc();
            setValueFunc2();
        end
        self:refreshCultrueLevel();
    else
        self.m_needFood = 0;
        self.m_needCrystal = 0;
        self.curr_need_food = 0;
        self.curr_need_crystal = 0;
        local tempLabel = nil;
        for i=1,1 do
            game_util:resetAttributeLable2(self.m_attr_label_tab.hp[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.patk[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.matk[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.def[i]);
            game_util:resetAttributeLable2(self.m_attr_label_tab.speed[i]);
        end
    end
    self:refreshTips();
end

--[[--
    创建英雄列表
]]
function game_hero_culture_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount --totalItem;
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = true;
    -- params.direction = kCCScrollViewDirectionHorizontal;
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
                local itemData,itemCfg = game_data:getCardDataByIndex(index+1);
                if itemData and itemCfg then
                    local character_ID = itemCfg:getNodeWithKey("character_ID"):toInt()
                    local card_id = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    if self.m_selHeroId and self.m_selHeroId == card_id then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
                    end
                    if self.m_guildNode == nil and character_ID == 40 and index < 5 then
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
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_selHeroId == nil or self.m_selHeroId ~= card_id then
                local function callBackFunc()
                cclog("self.m_selListItem ===================" .. tostring(self.m_selListItem))
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_status = 0;
                self.m_levelUpValue = 0;
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
                local id = game_guide_controller:getIdByTeam("15");
                if id == 1502 then
                    game_guide_controller:gameGuide("show","15",1503,{tempNode = self.m_list_view_bg2:getChildByTag(22)})
                end
                end
                self:onSureFunc(callBackFunc);
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
    return TableViewHelper:create(params);
end

--[[--

]]
function game_hero_culture_scene.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
    self:refreshCardTableView()
end


--[[--
    刷新
]]
function game_hero_culture_scene.refreshByType(self,showType)
    self.m_showType = showType;
    if showType == 1 then
        self:refreshSortTabBtn(self.m_selSortIndex);
    end
    self:refreshTips();
end

--[[--
    刷新
    -- 0~9：不可以进行属性改造
    -- 10~19：可以改造到5级
    -- 20~29：可以改造到10级
    -- 30~39：可以改造到15级
    -- 40+：可以改造到20级
]]
function game_hero_culture_scene.refreshCultrueLevel(self)
    local character_strengthen = getConfig("character_strengthen");
    for i=1,5 do
        local itemData = typeTable[i];
        local m_level_label = self.m_cultureLevelTab[i]
        if self.m_selIndexTab[1] == i then
            if itemData.lv >= self.m_maxCrystalLv then-- itemData.lv >= 20
                m_level_label:setString("Lv.MAX")
            else
                m_level_label:setString("Lv." .. math.min(itemData.lv,self.m_maxCrystalLv));
                -- if itemData.lv >= self.m_maxCrystalLv and self.m_selHeroData then
                --     local lv = self.m_selHeroData.lv
                --     if lv < 10 then
                --         game_util:addMoveTips({text = "10级才能开启属性改造！"});
                --     elseif lv < 20 then
                --         game_util:addMoveTips({text = "20级增加属性改造等级上限！"});
                --     elseif lv < 30 then
                --         game_util:addMoveTips({text = "30级增加属性改造等级上限！"});
                --     elseif lv < 40 then
                --         game_util:addMoveTips({text = "40级增加属性改造等级上限！"});
                --     end
                -- end
            end
        else
            if itemData.lv1 >= self.m_maxCrystalLv then-- itemData.lv >= 20
                m_level_label:setString("Lv.MAX")
            else
                m_level_label:setString("Lv." .. math.min(itemData.lv1 or 0,self.m_maxCrystalLv));
            end
        end
    end
end

--[[--
    刷新
]]
function game_hero_culture_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    local id = game_guide_controller:getIdByTeam("15");
    if id == 1501 then
        self.m_tableView:setMoveFlag(false);
    end
end


--[[--
    刷新按钮状态
]]
function game_hero_culture_scene.refreshTips(self)
    self.m_status = 0;
    if self.m_showType == 1 then
        if self.m_selHeroId then
            self.m_tips_spr_1:setVisible(false);
            -- self.m_tips_spr_2:setVisible(false);
        else
            self.m_tips_spr_1:setVisible(true);
            -- self.m_tips_spr_2:setVisible(false);
        end
        local totalFood = (game_data:getUserStatusDataByKey("food") or 0) - self.m_needFood + self.curr_need_food
        cclog("self.m_needFood === " .. self.m_needFood .. " ; self.curr_need_food == " .. self.curr_need_food)
        local value,unit = game_util:formatValueToString(totalFood);
        self.m_food_total_label:setString(value .. unit);
        game_util:setCostLable(self.m_cost_food_label,self.curr_need_food,totalFood);
        local totalCrystal = (game_data:getUserStatusDataByKey("crystal") or 0) - self.m_needCrystal + self.curr_need_crystal
        cclog("self.m_needCrystal === " .. self.m_needCrystal .. " ; self.curr_need_crystal == " .. self.curr_need_crystal)
        local value,unit = game_util:formatValueToString(totalCrystal);
        self.m_crystal_total_label:setString(tostring(value .. unit))
        game_util:setCostLable(self.m_cost_crystal_label,self.curr_need_crystal,totalCrystal);
        local totalCrystal_2 = (game_data:getUserStatusDataByKey("adv_crystal") or 0) - self.m_needCrystal_2 + self.m_curr_need_crystal_2
        cclog("self.m_needCrystal_2 === " .. self.m_needCrystal_2 .. " ; self.m_curr_need_crystal_2 == " .. self.m_curr_need_crystal_2)
        local value,unit = game_util:formatValueToString(totalCrystal_2);
        self.m_crystal_total_label_2:setString(tostring(value .. unit))
        game_util:setCostLable(self.m_cost_crystal_label_2,self.m_curr_need_crystal_2,totalCrystal_2)

        if self.curr_need_food > totalFood then
            self.m_status = 1;
        elseif self.curr_need_crystal > totalCrystal then
            self.m_status = 2
        elseif self.m_curr_need_crystal_2 > totalCrystal_2 then
            self.m_status = 3
        else
            if self.m_selHeroData and self.m_selHeroData.lv < self.m_need_level then
                self.m_status = 4;--等级没达到要求
            end
        end
        cclog("self.m_can_up_flag ============= " .. tostring(self.m_can_up_flag))
    end
end

--[[--
    刷新ui
]]
function game_hero_culture_scene.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshByType(self.m_showType);
end
--[[--
    初始化
]]
function game_hero_culture_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_attr_label_tab = {hp={},matk={},patk={},def={},speed={}};
    self.m_showType = 1;
    self.m_maxCrystalLv = 1;
    self.m_selIndexTab = {};
    self.m_needFood = 0;
    self.m_needCrystal = 0;
    self.curr_need_food = 0;
    self.curr_need_crystal = 0;
    self.m_levelUpValue = 0;
    self.m_needCrystal_2 = 0;
    self.m_curr_need_crystal_2 = 0;
    self.m_cultureLevelTab = {};
    self.m_need_level = 0;
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
    self.m_openType = t_params.openType or ""
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_culture_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("15");
    if id == 1501 then
        self:gameGuide("drama","15",1502)
    end
    game_guide_controller:showEndForceGuide("15")
    return uiNode;
end

function game_hero_culture_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "15" and id == 1502 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","15",1502,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "15" and id == 1505 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","15",1506);
                game_guide_controller:gameGuide("show","15",1506,{tempNode = self.m_back_btn})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return game_hero_culture_scene;
