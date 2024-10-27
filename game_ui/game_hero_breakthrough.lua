---  英雄转生

local game_hero_breakthrough = {
    m_anim_node = nil,--动画节点
    m_anim_node_2 = nil,
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_sel_btn_2 = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_selHeroDataBackup = nil,
    m_material_node_tab = nil,
    m_material_node = nil,
    m_status = nil,
    m_curPage = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_ccbNode = nil,
    m_root_layer = nil,
    m_auto_add_btn = nil,
    m_selFilterCardSortIndex = nil,
    m_selHeroTab = nil,
    m_selHeroData = nil,
    m_mate_tips = nil,
    m_attrValueTab = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
    m_needMaterialCount = nil,
    m_guildNode = nil,
    m_combatNumberChangeNode = nil,
    m_tempCombatValue = nil,
    m_story_label_1 = nil,
    m_story_label_2 = nil,
    m_materialDataTable = nil,
    m_breakNeedLevel = nil,
    m_breakMessage = nil,
    m_card_bre_value = nil,
    m_card_cfg_id = nil,
    m_break_sel_spr = nil,
    m_maxLevelTips = nil,
    m_shop_btn = nil,
};


--[[--
    销毁ui
]]
function game_hero_breakthrough.destroy(self)
    -- body
    cclog("-----------------game_hero_breakthrough destroy-----------------");
    self.m_anim_node = nil;
    self.m_anim_node_2 = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_sel_btn_2 = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_selHeroDataBackup = nil;
    self.m_material_node_tab = nil;
    self.m_material_node = nil;
    self.m_status = nil;
    self.m_curPage = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_auto_add_btn = nil;
    self.m_selFilterCardSortIndex = nil;
    self.m_selHeroTab = nil;
    self.m_selHeroData = nil;
    self.m_attrValueTab = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
    self.m_needMaterialCount = nil;
    self.m_guildNode = nil;
    self.m_combatNumberChangeNode = nil;
    self.m_tempCombatValue = nil;
    self.m_story_label_1 = nil;
    self.m_story_label_2 = nil;
    self.m_materialDataTable = nil;
    self.m_breakNeedLevel = nil;
    self.m_breakMessage = nil;
    self.m_card_bre_value = nil;
    self.m_card_cfg_id = nil;
    self.m_break_sel_spr = nil;
    self.m_maxLevelTips = nil;
    self.m_shop_btn = nil;
end

--[[--
    返回
]]
function game_hero_breakthrough.back(self,backType)
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
function game_hero_breakthrough.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--材料
        elseif btnTag == 3 then--重新选择
        elseif btnTag == 4 then
        elseif btnTag == 101 then--开始转生
            self:onSureFunc();
        elseif btnTag == 102 then--材料商店
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_offering_sacrifices_shop",{gameData = gameData,openType = "game_hero_breakthrough"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("sacrifice_open_shop"), http_request_method.GET, nil,"sacrifice_open_shop")
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            self:refreshSortTabBtn(btnTag - 200);
            if self.m_showType == 1 then
                local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
                game_data:cardsSortByTypeName(selSort);
                self:refreshCardTableView();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_breakthrough.ccbi");

    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node_2 = ccbNode:nodeForName("m_anim_node_2")
    self.m_anim_node:setScale(0.9);
    self.m_anim_node_2:setScale(0.9);
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_shop_btn = ccbNode:controlButtonForName("m_shop_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_sel_btn_2 = ccbNode:controlButtonForName("m_sel_btn_2")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_material_node = ccbNode:layerForName("m_material_node")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")
    self.m_break_sel_spr = ccbNode:spriteForName("m_break_sel_spr")
    -- self.m_break_sel_spr:setVisible(false);
    -- self.m_break_sel_spr:runAction(game_util:createRepeatForeverFade())
    self.m_maxLevelTips = ccbNode:labelTTFForName("m_max_break_tips_label")
    
    local m_storr_node_1 = ccbNode:nodeForName("m_storr_node_1")
    local m_storr_node_2 = ccbNode:nodeForName("m_storr_node_2")
    self.m_story_label_1 = game_util:createRichLabelTTF({text = "",dimensions = m_storr_node_1:getContentSize(),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
    self.m_story_label_1:setAnchorPoint(ccp(0, 0))
    m_storr_node_1:addChild(self.m_story_label_1)
    self.m_story_label_2 = game_util:createRichLabelTTF({text = "",dimensions = m_storr_node_2:getContentSize(),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})     
    self.m_story_label_2:setAnchorPoint(ccp(0, 0))
    m_storr_node_2:addChild(self.m_story_label_2)
    game_util:setCCControlButtonTitle(self.m_shop_btn,string_helper.ccb.file14)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file15)
    -- game_util:setControlButtonTitleBMFont(self.m_shop_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    local m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label,parentNode = nil;
    for i=1,4 do
        m_material_node = ccbNode:spriteForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_mate_cost_label = ccbNode:labelTTFForName("m_mate_cost_label_" .. i)
        m_mate_total_label = ccbNode:labelTTFForName("m_mate_total_label_" .. i)
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_mate_cost_label = m_mate_cost_label,m_mate_total_label = m_mate_total_label,parentNode = parentNode}
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
    text2:setString(string_helper.ccb.text230)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text231)
    return ccbNode;
end

--[[--

]]
function game_hero_breakthrough.onSureFunc(self)
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.game_hero_breakthrough.text});
        return;
    end
    cclog("self.m_status =========== " .. self.m_status)
    if self.m_status == 0 then

    elseif self.m_status == 1 then
        game_util:addMoveTips({text = string_helper.game_hero_breakthrough.text2});
        return;
    elseif self.m_status == 2 then
        game_util:addMoveTips({text = string.format(string_helper.game_hero_breakthrough.text3,self.m_breakNeedLevel)});
        return;
    elseif self.m_status == 3 then
        game_util:addMoveTips({text = string_helper.game_hero_breakthrough.text4});
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
        local params = "card_id=" .. self.m_selHeroId
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_card_break"), http_request_method.GET, params,"cards_card_break",true,true)
    end
    -- self:responseSuccess()
    if self.m_status == 4 then--消耗本类型卡牌
        game_util:closeAlertView();
        local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                game_util:closeAlertView();
                sendRequest();
            end,   --可缺省
            closeCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            okBtnText = string_config.m_btn_sure,       --可缺省
            cancelBtnText = string_config.m_btn_cancel,
            text = string_helper.game_hero_breakthrough.text5,      --可缺省
            onlyOneBtn = false,
        }
        game_util:openAlertView(t_params);
    else
        sendRequest();
    end
end

--[[-- 
    初始化成功动画
]]
function game_hero_breakthrough.addAdvancedAnim(self)
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
    ccbNode:openCCBFile("ccb/ui_hero_breakthrough_anim.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
    local tempNode = game_util:createHeroListItemByCCB(cardData);
    m_anim_node:addChild(tempNode,10,10);

    -- {typeName = "速度:",add_value = add_speed,attr = "speed",attr_value = 4}
    self.m_addAttrTab = self.m_addAttrTab or {};
    cclog2(self.m_addAttrTab, "self.m_addAttrTab == ")
    local tempCount = #self.m_addAttrTab



    local m_title_label_1 = ccbNode:labelTTFForName("m_title_label_1")
    local name = game_util:getCardName( cardData, heroCfg)
    m_title_label_1:setString(name or "")
    -- local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);

    local m_storr_node_2 = ccbNode:nodeForName("m_stroy_label_2")
    local r_story_label_2 = game_util:createRichLabelTTF({text = "",dimensions = m_storr_node_2:getContentSize(),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})     
    r_story_label_2:setAnchorPoint(ccp(0, 0))
    m_storr_node_2:addChild(r_story_label_2)

    local level = cardData.bre or 0
    local tempSpriteFrame = nil
    if level > 5 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_moon_icon.png")
        level = level - 5
    end
    local t = 1
    for i=1,5 do
        local star = ccbNode:spriteForName("sprite_stare" .. i)
        if i <= level then
            if tempSpriteFrame then
                star:setDisplayFrame(tempSpriteFrame)
            end
            star:setScale(3)
            star:setPositionX(star:getPositionX() + 10) 
            star:setOpacity(0)
            local arrSp = CCArray:create()
            arrSp:addObject(CCScaleTo:create(0.15, 1))
            arrSp:addObject(CCMoveBy:create(0.2, ccp(-10, 0)))
            arrSp:addObject(CCFadeIn:create(0.1))
            local sp = CCSpawn:create(arrSp)
            local arr = CCArray:create();
            arr:addObject(CCDelayTime:create(t))
            -- arr:addObject(CCFadeTo:create(1, 1))
            arr:addObject(sp)
            local seq = CCSequence:create(arr)
            star:runAction(seq)
            t = t + 0.25
        else
            star:setVisible(fasle)
        end
    end

    local bk_value = cardData.bre or 0;
    local name_after = cardData.step < 1 and "" or ("+" .. cardData.step);
    local character_break_cfg = getConfig(game_config_field.character_break_new)
    local character_ID = cardData.c_id;--heroCfg:getNodeWithKey("character_ID"):toStr();
    local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
    local name_str = character_break_item:getNodeWithKey("name" .. (bk_value))
    -- if name_str then
    --     name_str = name_str:toStr();
    --     m_name_label:setString(name_str .. name_after)
    -- end
    local break_story = character_break_item:getNodeWithKey("break_story" .. (bk_value))
    if break_story then
        break_story = break_story:toStr();
    else
        break_story = ""
    end
    r_story_label_2:setString(break_story)


    local bre = cardData.bre or 1
    -- local bre =  1
    -- bre = math.min(bre, 3)
    local skill = cardData["s_" .. bre]
    local m_skill_icon_bg = ccbNode:spriteForName("m_skill_icon_bg");
    local tempSize = m_skill_icon_bg:getContentSize();
    local aminFlag = true;
    if skill then
        local tempIcon = game_util:createSkillIconByCid(skill.s, skill.avail)
        if tempIcon then
            tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
            m_skill_icon_bg:addChild(tempIcon);
        end
    else
        aminFlag =false;
    end




    local function playAnimEnd(animName)
        if animName == "start_anim" and aminFlag == true then
            ccbNode:runAnimations("icon_anim");
            m_skill_icon_bg:setVisible(true)
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
    转生成功 效果
]]
function game_hero_breakthrough.responseSuccess(self)
    game_scene:removeGuidePop();
    local endFlag = false;
    local function responseEndFunc()
        if endFlag == true then return end
        self.m_root_layer:setTouchEnabled(false);
        endFlag = true;
        game_sound:playUiSound("evo_success")
        self:refreshByType(1);
        self:addAdvancedAnim();
        local pX,pY = self.m_sel_btn:getPosition();
        local tempPos = self.m_sel_btn:getParent():convertToWorldSpace(ccp(pX,pY));
        local tempAnim = game_util:createUniversalAnim({animFile = "animi_hero_jinjie",rhythm = 1.0,loopFlag = false,animCallFunc = nil});
        if tempAnim then
            tempAnim:setScale(0.9);
            tempAnim:setPosition(tempPos)
            game_scene:getPopContainer():addChild(tempAnim,100)
        end
        local id = game_guide_controller:getIdByTeam("5");
        if id == 509 then
            game_guide_controller:gameGuide("send","5",509);
        end
        self:refreshCombatLabel();
    end
    local removeIndex = 4;--game_util:getTableLen(self.m_materialDataTable);
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,4 do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
        if self.m_materialDataTable[i] and mAnimNode then
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
            end
        end
    end
    -- local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
    -- if tempParticle then
    --     game_util:addMoveAndRemoveAction({node = tempParticle,startNode = self.m_sel_btn,endNode = self.m_sel_btn_2,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
    --     game_scene:getPopContainer():addChild(tempParticle)
    -- end
end

--[[--
    材料层
]]
function game_hero_breakthrough.initMaterialLayerTouch(self,formation_layer)
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
            if v.parentNode:isVisible() and v.parentNode:boundingBox():containsPoint(realPos) then
                cclog("m_material_node click ==== " .. k)
                local tempData = self.m_materialDataTable[k];
                if self.m_selHeroId and tempData then
                    if tempData.materialType == 6 then
                        game_scene:addPop("game_item_info_pop",{itemId = tempData.materialId,openType = 3})
                    elseif tempData.materialType == 5 then
                        game_scene:addPop("game_hero_info_pop",{cId = tostring(tempData.materialId),openType = 4})
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
--[[
    
]]
function game_hero_breakthrough.createBreakTable(self, viewSize, maxBreak,currentBreak)
    maxBreak = maxBreak or 5;
    currentBreak = currentBreak or 0;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    params.totalItem = maxBreak;
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
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_hero_breakthrough_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_break_icon = ccbNode:spriteForName("m_break_icon")
            local m_break_label = ccbNode:labelTTFForName("m_break_label")
            local m_break_sel_spr = ccbNode:spriteForName("m_break_sel_spr")
            -- m_break_sel_spr:setVisible(currentBreak == index)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("kpxq_break_" .. (index+1) .. ".png")
            if tempSpriteFrame then
                m_break_icon:setDisplayFrame(tempSpriteFrame);
            end
            local tempStr = game_util:getBreakLevelDes(index+1)
            -- m_break_label:setString(tostring(tempStr) .. string_helper.game_hero_breakthrough.zhuan)
            m_break_label:setString(tostring(tempStr))
            if index < currentBreak then
                m_break_icon:setColor(ccc3(255, 255, 255));
                m_break_label:setColor(ccc3(255, 255, 255));
            else
                m_break_icon:setColor(ccc3(81, 81, 81));
                m_break_label:setColor(ccc3(81, 81, 81));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_card_cfg_id and self.m_card_bre_value then
                game_scene:addPop("hero_breakthrough_detail_pop",{cardCfgId = self.m_card_cfg_id,breValue = self.m_card_bre_value,selBreValue = index+1})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    return TableViewHelper:create(params);
end

function game_hero_breakthrough.refreshBreakTable(self, maxBreak,currentBreak)
    local m_break_node = self.m_ccbNode:spriteForName("m_break_node")
    m_break_node:removeAllChildrenWithCleanup(true)
    local tempTableView = self:createBreakTable(m_break_node:getContentSize(), maxBreak,currentBreak)
    m_break_node:addChild(tempTableView)
end

--[[--
    属性英雄信息
]]
function game_hero_breakthrough.refreshHeroInfo(self,heroId)
    self.m_break_sel_spr:setVisible(false);
    self.m_materialDataTable = {};
    self.m_needMaterialCount = 1;
    self.m_status = 0;
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_anim_node_2:removeAllChildrenWithCleanup(true);
    self.m_selHeroData = nil;

	if heroId ~= nil and heroId ~= "-1" then
        self.m_tips_spr_1:setVisible(false);
        self.m_tips_spr_2:setVisible(false);
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        self.m_selHeroData = cardData;

        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);
        local level = cardData.lv or 0;
        local bk_value = cardData.bre or 0;
        local character_break_cfg = getConfig(game_config_field.character_break_new)
        local break_control_cfg = getConfig(game_config_field.break_control)

        local character_ID = cardData.c_id;--heroCfg:getNodeWithKey("character_ID"):toStr();
        local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
        local high_break = character_break_item:getNodeWithKey("high_break")
        high_break = high_break and high_break:toInt() or 5
        local bre = math.min(bk_value,high_break)
        self:refreshBreakTable(bre < 5 and 5 or high_break, bre);
        local break_control_item = break_control_cfg:getNodeWithKey(tostring(bk_value + 1))
        self.m_card_bre_value = bre;
        self.m_card_cfg_id = heroCfg:getKey();
        if (bre >= high_break) or break_control_item == nil then
            self.m_status = 1;--伙伴达到最大转生等级
            self.m_story_label_1:setString(string_helper.game_hero_breakthrough.wu);
            self.m_story_label_2:setString(string_helper.game_hero_breakthrough.wu);
        else
            local nextCardData = util.table_copy(cardData)--转生后的bre    会有特效变化
            nextCardData.bre = cardData.bre + 1
            -- local ccbNode = game_util:createHeroListItemByCCB(nextCardData);
            -- self.m_anim_node_2:addChild(ccbNode,10,10);
            -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
            -- local name_after = cardData.step < 1 and "" or ("+" .. cardData.step);
            -- local bre = bk_value + 1;
            -- for i=1,5 do
            --     local m_star_icon = ccbNode:spriteForName("m_star_icon_" .. i)
            --     if i < bre then
            --         m_star_icon:setVisible(true);
            --     elseif i == bre then
            --         m_star_icon:setVisible(true);
            --         game_util:createPulseAnmi("public_equip_star.png",m_star_icon)
            --     else
            --         m_star_icon:setVisible(false);
            --     end
            -- end
            -- local name_str = character_break_item:getNodeWithKey("name" .. (bk_value+1))
            -- if name_str then
            --     name_str = name_str:toStr();
            --     m_name_label:setString(name_str .. name_after)
            -- end
            local break_story = character_break_item:getNodeWithKey("break_story" .. (bk_value+1))
            if break_story then
                break_story = break_story:toStr();
            else
                break_story = string_helper.game_hero_breakthrough.wu
            end
            -- local story_detail = character_break_item:getNodeWithKey("story_detail" .. (bk_value+1))
            -- if story_detail then
            --     story_detail = story_detail:toStr();
            -- else
            --     story_detail = "无";
            -- end
            -- self.m_story_label_1:setString(break_story);
            self.m_story_label_2:setString(break_story);

            local material = character_break_item:getNodeWithKey("material" .. (bk_value+1))
            if material then
                local tempCount = material:getNodeCount();
                local material_node_size = self.m_material_node:getContentSize();
                local itemWidth = material_node_size.width/4
                local startX = material_node_size.width*0.5 - itemWidth*0.5*(tempCount - 1)

                local material_node_item,m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label
                local equip_material_item_cfg = nil,nil
                local materialId,materialType = nil,nil
                for i=1,4 do
                    material_node_item = self.m_material_node_tab[i];
                    material_node_item.parentNode:setPositionX(startX + itemWidth*(i - 1))
                    m_material_node = material_node_item.m_material_node
                    m_mate_tips = material_node_item.m_mate_tips
                    m_mate_cost_label = material_node_item.m_mate_cost_label
                    m_mate_total_label = material_node_item.m_mate_total_label
                    m_material_node:removeAllChildrenWithCleanup(true);
                    local material_item = material:getNodeAt(i-1)
                    if material_item then
                        m_mate_tips:setVisible(false);
                        m_mate_cost_label:getParent():setVisible(true);
                        materialType = material_item:getNodeAt(0):toInt();
                        materialId = material_item:getNodeAt(1):toStr();
                        local costCount = material_item:getNodeAt(2):toInt();
                        local count = 0;
                        local icon = nil;
                        if materialType == 6 then
                            count = game_data:getItemCountByCid(materialId);
                            icon = game_util:createItemIconByCid(materialId);
                        elseif materialType == 5 then
                            if self.m_status == 0 then
                                self.m_status = 4;--消耗本类型的卡牌
                            end
                            count = game_data:getCardCountByCid(materialId,self.m_selHeroId);
                            icon = game_util:createCardIconByCid(materialId);
                        end
                        if costCount > count then
                            self.m_status = 3;
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

            else
                cclog("no material")
                self.m_story_label_1:setString(string_helper.game_hero_breakthrough.wu);
                self.m_story_label_2:setString(string_helper.game_hero_breakthrough.wu);
            end
            local need_level = break_control_item:getNodeWithKey("need_level"):toInt();
            if level < need_level then--进阶等级不够，不能转生
                self.m_status = 2;
                self.m_breakNeedLevel = need_level;
            end
            self.m_story_label_1:setString(string_helper.game_hero_breakthrough.level .. need_level)
        end
    else
        self:refreshBreakTable(5, 0);
        self.m_tips_spr_1:setVisible(true);
        self.m_tips_spr_2:setVisible(false);   
        local material_node_item,m_material_node,m_mate_tips,m_mate_cost_label,m_mate_total_label
        for i=1,4 do
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
        self.m_story_label_1:setString(string_helper.game_hero_breakthrough.wu);
        self.m_story_label_2:setString(string_helper.game_hero_breakthrough.wu);
	end
    local flag = (self.m_status == 1)
    self.m_material_node:setVisible(not flag)
    game_util:setCCControlButtonEnabled(self.m_ok_btn,not flag)
    self.m_maxLevelTips:setVisible(flag)
end


--[[--
    创建英雄列表
]]
function game_hero_breakthrough.createTableView(self,viewSize)
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
            local itemData,itemCfg = game_data:getCardDataByIndex(index+1);
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
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemCfg = game_data:getCardDataByIndex(index+1);
            local character_break_cfg = getConfig(game_config_field.character_break_new)
            local character_ID = itemData.c_id;--itemCfg:getNodeWithKey("character_ID"):toStr();
            local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
            if character_break_item == nil then
                game_util:addMoveTips({text = string_helper.game_hero_breakthrough.text6});
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

                -- local id = game_guide_controller:getIdByTeam("5");
                -- if id == 507 then
                --     game_guide_controller:gameGuide("show","5",508,{tempNode = self.m_auto_add_btn})
                -- end
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
function game_hero_breakthrough.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    if self.m_showType == 1 then
        self.m_selSortIndex = sortIndex
        for i=1,4 do
            tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
            tempBtn:setHighlighted(self.m_selSortIndex == i);
            tempBtn:setEnabled(self.m_selSortIndex ~= i);
        end
    end
end

--[[--
    刷新
]]
function game_hero_breakthrough.refreshByType(self,showType)
    self.m_no_material_tips:setVisible(false);
    self.m_showType = showType;
    if showType == 1 then
        self:refreshHeroInfo(self.m_selHeroId);
        -- self.m_cost_food_label:setString("0");
        self:refreshSortTabBtn(self.m_selSortIndex);
        self:refreshCardTableView();
    end
    self:refreshTips();
end

--[[--
    刷新状态
]]
function game_hero_breakthrough.refreshTips(self)
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_showType == 1 then
        if self.m_selHeroId == nil then
            self.m_tips_spr_1:setVisible(true);
            self.m_tips_spr_2:setVisible(false);
            game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
            self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
            self.m_light_bg_1:runAction(game_util:createRepeatForeverFade())
        else
            self.m_tips_spr_1:setVisible(false);
            self.m_tips_spr_2:setVisible(false);
        end
    elseif self.m_showType == 2 then

    end
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
end

--[[--
    刷新
]]
function game_hero_breakthrough.refreshCardTableView(self)
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
function game_hero_breakthrough.refreshCombatLabel(self)
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
function game_hero_breakthrough.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshByType(self.m_showType);
    self:refreshCombatLabel();
end
--[[--
    初始化
]]
function game_hero_breakthrough.init(self,t_params)
    self.m_breakMessage = ""
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_showType = 1;
    self.m_material_node_tab = {};
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
    self.m_needMaterialCount = 1;
    self.m_materialDataTable = {};
    self.m_breakNeedLevel = 0;
    self.m_card_bre_value = nil;
    self.m_card_cfg_id = nil;
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_breakthrough.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    -- local id = game_guide_controller:getIdByTeam("5");
    -- if id == 505 then
    --     self:gameGuide("drama","5",506)
    -- end
    return uiNode;
end


--[[
    新手引导
]]
function game_hero_breakthrough.gameGuide(self,guideType,guide_team,guide_id,t_params)
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
        end
    end
end


return game_hero_breakthrough;
