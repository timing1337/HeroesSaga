--- 装备进化
local equip_evolution = {
    m_anim_node = nil,--动画节点
    m_selEquipId = nil,--选中的heroid
    m_ok_btn = nil,
    m_canStrengthenFlag = nil,
    m_tips_spr_1 = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_back_btn = nil,
    m_level_label = nil,
    m_ability1_label = nil,
    m_ability2_label = nil,
    m_level_new_label = nil,
    m_ability1_new_label = nil,
    m_ability2_new_label = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_ability1_new_label_2 = nil,
    m_ability2_new_label_2 = nil,
    m_ability1_name_label_2 = nil,
    m_ability2_name_label_2 = nil,
    m_ability1_label_2 = nil,
    m_ability2_label_2 = nil,
    m_material_layer = nil,
    m_material_node_tab = nil,
    m_materialDataTable = nil,
    m_curPage = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_selFilterSortType = nil,
    m_cost_metal_label = nil,
    m_metal_total_label = nil,
    m_selEquipDataTab = nil,
    m_status = nil,
    m_selSortIndex = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_shop_btn = nil,
};
--[[--
    销毁ui
]]
function equip_evolution.destroy(self)
    -- body
    cclog("-----------------equip_evolution destroy-----------------");
    self.m_anim_node = nil;
    self.m_selEquipId = nil;
    self.m_ok_btn = nil;
    self.m_canStrengthenFlag = nil;
    self.m_tips_spr_1 = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_back_btn = nil;
    self.m_level_label = nil;
    self.m_ability1_label = nil;
    self.m_ability2_label = nil;
    self.m_level_new_label = nil;
    self.m_ability1_new_label = nil;
    self.m_ability2_new_label = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_ability1_new_label_2 = nil;
    self.m_ability2_new_label_2 = nil;
    self.m_ability1_name_label_2 = nil;
    self.m_ability2_name_label_2 = nil;
    self.m_ability1_label_2 = nil;
    self.m_ability2_label_2 = nil;
    self.m_material_layer = nil;
    self.m_material_node_tab = nil;
    self.m_materialDataTable = nil;
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_selFilterSortType = nil;
    self.m_cost_metal_label = nil;
    self.m_metal_total_label = nil;
    self.m_selEquipDataTab = nil;
    self.m_status = nil;
    self.m_selSortIndex = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_shop_btn = nil;
end

--[[--
    返回
]]
function equip_evolution.back(self,backType)
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
function equip_evolution.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then--开始进阶
            self:onSureFunc();
        elseif btnTag == 102 then--精炼商城
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_metal_shop_scene",{gameData = gameData,openType = "game_hero_breakthrough"});
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open_metal_shop"), http_request_method.GET, {},"shop_open_metal_shop")
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            cclog("btnCallBack ===========btnTag===" .. btnTag)
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:equipSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equipment_evolution.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
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
    self.m_ability1_new_label_2 = ccbNode:labelTTFForName("m_ability1_new_label_2")
    self.m_ability2_new_label_2 = ccbNode:labelTTFForName("m_ability2_new_label_2")
    self.m_ability1_name_label_2 = ccbNode:labelTTFForName("m_ability1_name_label_2")
    self.m_ability2_name_label_2 = ccbNode:labelTTFForName("m_ability2_name_label_2")
    self.m_ability1_label_2 = ccbNode:labelTTFForName("m_ability1_label_2")
    self.m_ability2_label_2 = ccbNode:labelTTFForName("m_ability2_label_2")
    self.m_ability1_name_label:setString(string_helper.ccb.file67);
    self.m_ability1_name_label_2:setString(string_helper.ccb.file68);
    self.m_ability2_name_label:setString(string_helper.ccb.file65);
    self.m_ability2_name_label_2:setString(string_helper.ccb.file66);
    self.m_material_layer = ccbNode:layerForName("m_material_layer")
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label")
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label")

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
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_shop_btn)
    game_util:setCCControlButtonTitle(self.m_shop_btn,string_helper.ccb.text158)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text159)
    self.m_ccbNode = ccbNode
    self:initMaterialLayerTouch(self.m_material_layer);

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
    text2:setString(string_helper.ccb.text153)
    return ccbNode;
end

--[[--

]]
function equip_evolution.onSureFunc(self)
    if self.m_selEquipId == nil then
        game_util:addMoveTips({text = string_helper.equip_evolution.text1});
        return;
    end
    if self.m_status == 1 then
        game_util:addMoveTips({text = string_helper.equip_evolution.text2});
        return;
    end
    if self.m_status == 2 then
        game_util:addMoveTips({text = string_helper.equip_evolution.text3});
        return;
    end
    local requestCode = 0;
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            end
            self:responseSuccess();
        end
        --equip_id = 
        local params = {};
        params.equip_id = self.m_selEquipId;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_evolution"), http_request_method.GET, params,"equip_evolution",true,true)
    end
    sendRequest();
end

--[[--
    
]]
function equip_evolution.responseSuccess(self)
    local endFlag = false;
    local function responseEndFunc()
        if endFlag == true then return end
        endFlag = true;
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_over")
        self:refreshUi();
        game_util:addMoveTips({text = string_helper.equip_evolution.text4});
    end
    local rempveIndex = game_util:getTableLen(self.m_materialDataTable);
    local materialCount = rempveIndex;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,3 do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        if self.m_materialDataTable[i] then 
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
                            self.m_ccbNode:runAnimations("success_anim")
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
                responseEndFunc();
            end
        else

        end
    end

end

--[[--
    技能层
]]
function equip_evolution.initMaterialLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_material_node_tab) do
            tempItem = v.parentNode;
            if tempItem:boundingBox():containsPoint(realPos) then
                tag =  v.m_material_node:getTag();
                if self.m_materialDataTable[tag] ~= nil then
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
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if tempItem and tempItem:boundingBox():containsPoint(realPos) then
            cclog("initSkillLayerTouch onTouchEnded ------- tag == " .. tag)
            local tempData = self.m_materialDataTable[tag];
            if tempData then
                if tempData.materialType == 6 then
                    game_scene:addPop("game_item_info_pop",{itemId = tempData.materialId,openType = 2})
                elseif tempData.materialType == 7 then
                    local equipData = {lv = 1,c_id = tempData.materialId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
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

--[[--
    装备属性信息
]]
function equip_evolution.refreshEquipInfo(self,equipId)
    self.m_materialDataTable = {};
    self.m_status = 0;
    self.m_canStrengthenFlag = false;
    self.m_selEquipId = equipId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    game_util:setCostLable(self.m_cost_metal_label,0,0);
    -- game_util:resetAttributeLable2(self.m_ability1_new_label);
    -- game_util:resetAttributeLable2(self.m_ability2_new_label);
    -- game_util:resetAttributeLable2(self.m_level_new_label);
    -- game_util:resetAttributeLable2(self.m_ability1_new_label_2);
    -- game_util:resetAttributeLable2(self.m_ability2_new_label_2);

	if equipId ~= nil and equipId ~= "-1" then
        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId);
        local attrName1,value1,attrName2,value2 = game_util:getEquipAttributeValue(itemCfg,itemData.lv);
        self.m_ability1_name_label:setString(string_helper.equip_evolution.text5 .. attrName1);
        self.m_ability2_name_label:setString(string_helper.equip_evolution.text5 .. attrName2);
        self.m_ability1_name_label_2:setString(attrName1 .. string_helper.equip_evolution.text6);
        self.m_ability2_name_label_2:setString(attrName2 .. string_helper.equip_evolution.text6);

        self.m_ability1_label:setString("+" .. itemCfg:getNodeWithKey("value1"):toInt());
        self.m_ability2_label:setString("+" .. itemCfg:getNodeWithKey("value2"):toInt());
        self.m_ability1_label_2:setString("+" .. itemCfg:getNodeWithKey("level_add1"):toInt());
        self.m_ability2_label_2:setString("+" .. itemCfg:getNodeWithKey("level_add2"):toInt());

        -- self.m_level_label:setString(tostring(itemData.lv));
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local quality = itemCfg:getNodeWithKey("quality"):toStr();
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1]
        if qualityTab then
            self.m_level_label:setString(tostring(qualityTab.name));
            self.m_level_label:setColor(qualityTab.color);
        end

        local evolution = itemCfg:getNodeWithKey("evolution"):toInt();
        if evolution ~= 0 then
            -- local equip_strongthen = getConfig(game_config_field.equip_strongthen);
            -- local equip_strongthen_count = equip_strongthen:getNodeCount();
            
            -- local costMetal = 0;
            -- local equip_strongthen_item,cost_coefficient
            -- for i=2,math.min(itemData.lv,equip_strongthen_count) do
            --     equip_strongthen_item = equip_strongthen:getNodeWithKey(tostring(i));
            --     cost_coefficient = equip_strongthen_item:getNodeWithKey("quality" .. tostring(quality)):toInt()*0.01;
            --     if cost_coefficient == nil then cost_coefficient = 1 end
            --     costMetal = costMetal + equip_strongthen_item:getNodeWithKey("metal"):toInt()*cost_coefficient;
            -- end
            -- cclog("costMetal =============== " .. costMetal);
            -- local tempLv = 1;
            -- local tempCost = 0;
            -- for i=2,equip_strongthen_count do
            --     equip_strongthen_item = equip_strongthen:getNodeWithKey(tostring(i));
            --     cost_coefficient = equip_strongthen_item:getNodeWithKey("quality" .. tostring(quality)):toInt()*0.01;
            --     if cost_coefficient == nil then cost_coefficient = 1 end
            --     tempCost = equip_strongthen_item:getNodeWithKey("metal"):toInt()*cost_coefficient;
            --     if costMetal >= tempCost then
            --         costMetal = costMetal - tempCost;
            --         tempLv = i;
            --     else
            --         break;
            --     end
            -- end
            -- cclog("tempLv ==================== " .. tempLv)
            -- tempLv = math.max(tempLv-5,1)
            -- self.m_level_new_label:setString(tempLv);
            
            local equip_cfg = getConfig(game_config_field.equip);
            local itemEvoCfg = equip_cfg:getNodeWithKey(tostring(evolution));
            -- local _,valueEvo1,_,valueEvo2 = game_util:getEquipAttributeValue(itemEvoCfg,tempLv);
            -- game_util:setAttributeLable2(self.m_level_new_label,0,tempLv,"");
            -- game_util:setAttributeLable2(self.m_ability1_new_label,value1,valueEvo1,"+");
            -- game_util:setAttributeLable2(self.m_ability2_new_label,value2,valueEvo2,"+");

            self.m_ability1_new_label:setString("+" .. itemEvoCfg:getNodeWithKey("value1"):toInt());
            self.m_ability2_new_label:setString("+" .. itemEvoCfg:getNodeWithKey("value2"):toInt());
            self.m_ability1_new_label_2:setString("+" .. itemEvoCfg:getNodeWithKey("level_add1"):toInt());
            self.m_ability2_new_label_2:setString("+" .. itemEvoCfg:getNodeWithKey("level_add2"):toInt());
            local quality = itemEvoCfg:getNodeWithKey("quality"):toStr();
            local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1]
            if qualityTab then
                self.m_level_new_label:setString(tostring(qualityTab.name));
                self.m_level_new_label:setColor(qualityTab.color);
            end

            local item_cfg = getConfig(game_config_field.item);

            local equip_evolution = getConfig(game_config_field.equip_evolution);
            local evolution_id = itemCfg:getNodeWithKey("evolution_id"):toStr();
            cclog("evolution_id ====================== " .. evolution_id)
            local equip_evolution_item = equip_evolution:getNodeWithKey(evolution_id);
            if equip_evolution_item then
                local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
                game_util:setCostLable(self.m_cost_metal_label,equip_evolution_item:getNodeWithKey("metal"):toInt(),totalMetal);
                local material_node_item,m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label
                local equip_material_item_cfg,tempCount = nil,nil
                local materialId,materialType = nil,nil
                for i=1,3 do
                    material_node_item = self.m_material_node_tab[i];
                    m_material_node = material_node_item.m_material_node
                    m_mate_tips = material_node_item.m_mate_tips
                    m_mate_cost_label = material_node_item.m_mate_cost_label
                    m_mate_total_label = material_node_item.m_mate_total_label
                    m_material_node:removeAllChildrenWithCleanup(true);
                    equip_material_item_cfg = equip_evolution_item:getNodeWithKey("equip_material_" .. i)
                    tempCount = equip_material_item_cfg:getNodeCount();
                    if tempCount > 0 then
                        m_mate_tips:setVisible(false);
                        m_mate_cost_label:getParent():setVisible(true);
                        local tempItemCfg = equip_material_item_cfg:getNodeAt(0);
                        materialType = tempItemCfg:getNodeAt(0):toInt();
                        materialId = tempItemCfg:getNodeAt(1):toStr();
                        local costCount = tempItemCfg:getNodeAt(2):toInt();
                        local count = 0;
                        local icon = nil;
                        if materialType == 6 then
                            count = game_data:getItemCountByCid(materialId);
                            icon = game_util:createItemIconByCid(materialId);
                        else
                            count = game_data:getEquipCountByCid(materialId,self.m_selEquipId);
                            icon = game_util:createEquipIconByCid(materialId);
                        end
                        if costCount > count then
                            self.m_status = 2;
                            m_mate_cost_label:setColor(ccc3(255, 0, 0))
                        else
                            m_mate_cost_label:setColor(ccc3(255, 255, 255));
                        end
                        m_mate_cost_label:setString(costCount);
                        m_mate_total_label:setString(count);
                        self.m_materialDataTable[i] = {count = count,materialId = materialId,materialType = materialType};
                        if icon then
                            local tempSize = m_material_node:getContentSize();
                            icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                            m_material_node:addChild(icon,10,10);
                            if costCount > count then
                                icon:setColor(ccc3(151,151,151));                        
                            end
                        end
                    else
                        -- m_mate_tips:setVisible(true);
                        -- m_mate_cost_label:setString("0");
                        -- m_mate_total_label:setString("0");
                        -- m_mate_cost_label:setColor(ccc3(255, 255, 255));
                        m_mate_cost_label:getParent():setVisible(false);
                    end
                end
            end
        else
            self.m_status = 1;
            local material_node_item,m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label
            for i=1,3 do
                material_node_item = self.m_material_node_tab[i];
                m_material_node = material_node_item.m_material_node
                m_mate_tips = material_node_item.m_mate_tips
                m_mate_cost_label = material_node_item.m_mate_cost_label
                m_mate_total_label = material_node_item.m_mate_total_label
                m_mate_tips:setVisible(true);
                m_material_node:removeAllChildrenWithCleanup(true);
                m_mate_cost_label:setString("0");
                m_mate_total_label:setString("0");
                m_mate_cost_label:setColor(ccc3(255, 255, 255));
                m_mate_cost_label:getParent():setVisible(true);
            end
            self.m_ability1_new_label:setString("---");
            self.m_ability2_new_label:setString("---");
            self.m_level_new_label:setString("---");
            self.m_ability1_new_label_2:setString("---");
            self.m_ability2_new_label_2:setString("---");
        end
	end
    self:refreshTips();
end

--[[--
    创建装备列表
]]
function equip_evolution.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local equipCfg = getConfig(game_config_field.equip);
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
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            local tempId = tableData[index+1]
            if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selEquipId = tostring(tempId)
                self:refreshEquipInfo(self.m_selEquipId);
                self:refreshTips();
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新列表
]]
function equip_evolution.refreshEquipTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--

]]
function equip_evolution.refreshSortTabBtn(self,sortIndex)
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
function equip_evolution.refreshByType(self,showType)
    cclog("refreshByType ==============" .. showType);
    self.m_showType = showType;
    if showType == 1 then
        self:refreshSortTabBtn(self.m_selSortIndex);
    elseif showType == 2 then

    end
    self:refreshTips();
end

--[[--
    刷新tips
]]
function equip_evolution.refreshTips(self)
    if self.m_selEquipId ~= nil then
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
    end
    if #self.m_selEquipDataTab == 0 then

    else

    end
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_metal_total_label:setString(tostring(value .. unit));
end

--[[--
    刷新
]]
function equip_evolution.refreshCombatLabel(self)
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
function equip_evolution.refreshUi(self)
    self:refreshEquipInfo(self.m_selEquipId);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function equip_evolution.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selEquipId = t_params.selEquipId;
    self.m_showType = 1;
    self.m_curPage = 1;
    self.m_material_node_tab = {};
    self.m_materialDataTable = {};
    self.m_selEquipDataTab = {};
    local selSort = game_data:getEquipSortType();
    for k,v in pairs(EQUIP_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function equip_evolution.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("14");
    if id == 1401 then
        game_guide_controller:gameGuide("drama","14",1401)
    end
    game_guide_controller:showEndForceGuide("14")
    return uiNode;
end

return equip_evolution;
