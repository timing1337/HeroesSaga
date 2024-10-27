--- 学校训练选择 

local game_school_select_scene = {
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_material_id_table = nil,
    m_tips_label = nil,
    m_hero_bg_btn = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_needMoney = nil,
    m_back_btn_1 = nil,
    m_back_btn_2 = nil,
    m_cost_str = nil,
    m_time_btn = nil,
    m_type_btn = nil,
    m_exp_label = nil,
    m_level_label = nil,
    m_posIndex = nil,
    m_train_type = nil,
    m_train_time = nil,
    m_root_layer = nil,
    m_sort_btn = nil,
    m_cost_node = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_cost_gold_label = nil,
    m_gold_total_label = nil,
    m_typeList = nil,
    m_timeList = nil,
    m_npc_img = nil,
    m_guildNode = nil,
};
--[[--
    销毁ui
]]
function game_school_select_scene.destroy(self)
    -- body
    cclog("-----------------game_school_select_scene destroy-----------------");
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_material_id_table = nil;
    self.m_tips_label = nil;
    self.m_hero_bg_btn = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_needMoney = nil;
    self.m_back_btn_1 = nil;
    self.m_back_btn_2 = nil;
    self.m_cost_str = nil;
    self.m_time_btn = nil;
    self.m_type_btn = nil;
    self.m_exp_label = nil;
    self.m_level_label = nil;
    self.m_posIndex = nil;
    self.m_train_type = nil;
    self.m_train_time = nil;
    self.m_root_layer = nil;
    self.m_sort_btn = nil;
    self.m_cost_node = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_cost_gold_label = nil;
    self.m_gold_total_label = nil;
    self.m_typeList = nil;
    self.m_timeList = nil;
    self.m_npc_img = nil;
    self.m_guildNode = nil;
end
--[[--
    返回
]]
function game_school_select_scene.back(self,backType)
    if backType == "back" then
        game_scene:enterGameUi("game_school_scene",{gameData = nil});
        self:destroy();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_school_select_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 2 then--返回
            self:refreshByType(1);
        elseif btnTag == 11 then--排序
                local function btnCallBack(btnTag)
                    cclog("btnCallBack =====1======btnTag===" .. btnTag)
                    local selSortType = CARD_SORT_TAB[btnTag].sortType;
                    game_data:cardsSortByTypeName(selSortType);
                    self:refreshCardTableView();
                end
                local selSortType = game_data:getCardSortType();--
                game_scene:addPop("game_sort_pop",{btnTitleTab = CARD_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = selSortType})

        elseif btnTag == 12 then--开始重置
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = string_helper.game_school_select_scene.select_card});
                return;
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_school_scene",{gameData = gameData});
                self:destroy();
            end
            local params = {};
            params.stove_key = "stove_" .. self.m_posIndex;
            params.train_type = self.m_train_type;
            params.train_time = self.m_train_time;
            params.card_id = self.m_selHeroId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_train"), http_request_method.GET, params,"school_train")
        elseif btnTag == 13 then--确定选择
            if self.m_selHeroId then
                self:refreshByType(2);
            end
        elseif btnTag == 21 then
            if self.m_timeList == nil and self.m_typeList == nil then
                self:createTimeList();
            end
        elseif btnTag == 22 then
            if self.m_timeList == nil and self.m_typeList == nil then
                self:createTypeList();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_school_select.ccbi");
    local m_formation_layer = ccbNode:layerColorForName("m_formation_layer")

    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_hero_bg_btn = ccbNode:controlButtonForName("m_hero_bg_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_back_btn_1 = ccbNode:controlButtonForName("m_back_btn_1")
    self.m_back_btn_2 = ccbNode:controlButtonForName("m_back_btn_2")
    self.m_time_btn = ccbNode:controlButtonForName("m_time_btn")
    self.m_type_btn = ccbNode:controlButtonForName("m_type_btn")
    self.m_exp_label = ccbNode:labelTTFForName("m_exp_label");
    self.m_level_label = ccbNode:labelTTFForName("m_level_label");
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_cost_node = ccbNode:nodeForName("m_cost_node")
    self.m_cost_food_label = ccbNode:labelTTFForName("m_cost_food_label");
    self.m_food_total_label = ccbNode:labelTTFForName("m_food_total_label");
    self.m_cost_gold_label = ccbNode:labelTTFForName("m_cost_gold_label");
    self.m_gold_total_label = ccbNode:labelTTFForName("m_gold_total_label");
    self.m_npc_img = ccbNode:spriteForName("m_npc_img")
    game_util:setNpcImg(self.m_npc_img,true);

    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,1,false);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end



--[[--
    刷新ui
]]
function game_school_select_scene.createTypeList(self)
    if self.m_typeList then return end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_whiteBg.png");
    local viewSize = CCSizeMake(100,185);
    bgSpr:setPreferredSize(viewSize);
    local scrollView = CCScrollView:create(viewSize);
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    scrollView:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    bgSpr:addChild(scrollView);
    local arrow = CCSprite:createWithSpriteFrameName("public_whiteTriangle.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,viewSize.height + 7));
    arrow:setRotation(90);
    bgSpr:addChild(arrow);

    local menu = CCMenu:create();
    menu:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    menu:ignoreAnchorPointForPosition(true);
    menu:setPosition(ccp(0,0));
    menu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4);
    scrollView:addChild(menu);
    local function menuCallback(tag,pMenuItem)
        self.m_train_type = tag;
        self:refreshHeroInfo(self.m_selHeroId);
        self.m_typeList:removeFromParentAndCleanup(true);
        self.m_typeList = nil;
    end
    local character_train_rate_config = getConfig("character_train_rate");
    local itemCfg = nil;
    for index=1,5 do
        itemCfg = character_train_rate_config:getNodeWithKey(tostring(index));
        local normalSprite = CCSprite:createWithSpriteFrameName("public_btnGreen.png");
        -- normalSprite:setOpacity(0);
        local menuItemSize = normalSprite:getContentSize();
        local text = game_util:createLabel({text = itemCfg:getNodeWithKey("exp_rate"):toStr() .."%",fnt="btn_text_character.fnt"});
        text:setPosition(ccp(menuItemSize.width*0.5,menuItemSize.height*0.5));
        text:setColor(ccc3(255,255,255));
        normalSprite:addChild(text);
        local normalSpriteSel = CCSprite:createWithSpriteFrameName("public_btnGreenDown.png");
        local textSel = game_util:createLabel({text = itemCfg:getNodeWithKey("exp_rate"):toStr() .."%",fnt="btn_text_character.fnt"});
        textSel:setPosition(ccp(menuItemSize.width*0.5,menuItemSize.height*0.5));
        textSel:setColor(ccc3(255,0,0));
        normalSpriteSel:addChild(textSel);
        local menuItem = CCMenuItemSprite:create(normalSprite,normalSpriteSel);
        menuItem:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.95 - viewSize.height*0.18* (index - 0.5)));
        menuItem:registerScriptTapHandler(menuCallback)
        -- menuItem:setScale(0.5);
        menu:addChild(menuItem,1,index);
        if index == self.m_train_type then
            menuItem:setEnabled(false);
            menuItem:selected();
        end
    end
    local px,py = self.m_type_btn:getPosition();
    local m_btn_size = self.m_type_btn:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,1));
    local pos = self.m_type_btn:getParent():convertToWorldSpace(ccp(px,py-m_btn_size.height));
    bgSpr:setPosition(pos);
    self.m_typeList = CCLayer:create();
    self.m_typeList:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_typeList then
                self.m_typeList:removeFromParentAndCleanup(true);
                self.m_typeList = nil;
            end
            return true;--intercept event
        end
    end
    self.m_typeList:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_typeList:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_typeList);
end

--[[--
    刷新ui
]]
function game_school_select_scene.createTimeList(self)
    if self.m_timeList then return end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_whiteBg.png");
    local viewSize = CCSizeMake(100,185);
    bgSpr:setPreferredSize(viewSize);
    local scrollView = CCScrollView:create(viewSize);
    scrollView:setDirection(kCCScrollViewDirectionVertical);
    scrollView:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    bgSpr:addChild(scrollView);
    local arrow = CCSprite:createWithSpriteFrameName("public_whiteTriangle.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,viewSize.height + 7));
    arrow:setRotation(90);
    bgSpr:addChild(arrow);

    local menu = CCMenu:create();
    menu:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    menu:ignoreAnchorPointForPosition(true);
    menu:setPosition(ccp(0,0));
    menu:setTouchPriority(GLOBAL_TOUCH_PRIORITY-4);
    scrollView:addChild(menu);
    local function menuCallback(tag,pMenuItem)
        self.m_train_time = tag;
        self:refreshHeroInfo(self.m_selHeroId);
        self.m_timeList:removeFromParentAndCleanup(true);
        self.m_timeList = nil;
    end
    local character_train_time_config = getConfig("character_train_time");
    local itemCfg = nil;
    for index=1,5 do
        itemCfg = character_train_time_config:getNodeWithKey(tostring(index));
        local time_need = itemCfg:getNodeWithKey("time"):toInt()*3600;

        local normalSprite = CCSprite:createWithSpriteFrameName("public_btnGreen.png");
        -- normalSprite:setOpacity(0);
        local menuItemSize = normalSprite:getContentSize();
        local text = game_util:createLabel({text = game_util:formatTime(time_need),fnt="btn_text_character.fnt"});
        text:setPosition(ccp(menuItemSize.width*0.5,menuItemSize.height*0.5));
        text:setColor(ccc3(255,255,255));
        normalSprite:addChild(text);
        local normalSpriteSel = CCSprite:createWithSpriteFrameName("public_btnGreenDown.png");
        local textSel = game_util:createLabel({text = game_util:formatTime(time_need),fnt="btn_text_character.fnt"});
        textSel:setPosition(ccp(menuItemSize.width*0.5,menuItemSize.height*0.5));
        textSel:setColor(ccc3(255,0,0));
        normalSpriteSel:addChild(textSel);
        local menuItem = CCMenuItemSprite:create(normalSprite,normalSpriteSel);
        menuItem:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.95 - viewSize.height*0.18* (index - 0.5)));
        menuItem:registerScriptTapHandler(menuCallback)
        -- menuItem:setScale(0.5);
        menu:addChild(menuItem,1,index);
        if index == self.m_train_time then
            menuItem:setEnabled(false);
            menuItem:selected();
        end
    end
    local px,py = self.m_time_btn:getPosition();
    local m_btn_size = self.m_time_btn:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,1));
    local pos = self.m_time_btn:getParent():convertToWorldSpace(ccp(px,py-m_btn_size.height));
    bgSpr:setPosition(pos);
    self.m_timeList = CCLayer:create();
    self.m_timeList:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_timeList then
                self.m_timeList:removeFromParentAndCleanup(true);
                self.m_timeList = nil;
            end
            return true;--intercept event
        end
    end
    self.m_timeList:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_timeList:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_timeList);
end


--[[--
    属性英雄信息
]]
function game_school_select_scene.refreshHeroInfo(self,heroId)
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    game_util:setCostLable(self.m_cost_food_label,0,0);
    game_util:setCostLable(self.m_cost_gold_label,0,0);
    local character_train = getConfig("character_train");
    local character_train_time_config = getConfig("character_train_time");
    local character_train_rate_config = getConfig("character_train_rate");
    if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));

        local needFood = 0;
        local needGold = 0;
        local percent = 0;
        local time_need = 0;
        local trainItem = character_train:getNodeWithKey(tostring(cardData.star));
        cclog("cardData.star ==" .. cardData.star .. " ; cardData.quality ===" .. cardData.quality)
        local extra_food_rate = 0;
        local realNeedFood = 0;
        if trainItem then
            local money = trainItem:getNodeAt(cardData.quality);
            if money then
                needFood = money:toInt();
            end
        end
        realNeedFood = needFood;
        local typeItem = character_train_rate_config:getNodeWithKey(tostring(self.m_train_type));
        if typeItem then
            percent = typeItem:getNodeWithKey("exp_rate"):toInt();
            game_util:setCCControlButtonTitle(self.m_type_btn,tostring(percent) .. "%")
            needGold = needGold + typeItem:getNodeWithKey("coin_cost"):toInt();
            extra_food_rate = typeItem:getNodeWithKey("extra_food_rate"):toInt();
            realNeedFood = realNeedFood + needFood * (extra_food_rate*0.01 + 1);
        end
        local timeItem = character_train_time_config:getNodeWithKey(tostring(self.m_train_time));
        
        if timeItem then
            time_need = timeItem:getNodeWithKey("time"):toInt()*60;
            game_util:setCCControlButtonTitle(self.m_time_btn,game_util:formatTime(time_need*60));
            needGold = needGold + timeItem:getNodeWithKey("coin_cost"):toInt();
            extra_food_rate = timeItem:getNodeWithKey("extra_food_rate"):toInt();
            realNeedFood = realNeedFood + needFood * (extra_food_rate*0.01 + 1);
        end
        
        local totalFood = game_data:getUserStatusDataByKey("food") or 0
        local totalGold = game_data:getUserStatusDataByKey("coin") or 0
        game_util:setCostLable(self.m_cost_food_label,realNeedFood,totalFood);
        game_util:setCostLable(self.m_cost_gold_label,needGold,totalGold);

        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local building_base_school = getConfig(game_config_field.role);
        local level = game_data:getUserStatusDataByKey("level") or 1;
        local schoolItem = building_base_school:getNodeWithKey(tostring(level));
        local gainExp = 0;
        if schoolItem then
            local get_exp_min = schoolItem:getNodeWithKey("get_exp_min");
            if get_exp_min then
                gainExp = time_need*get_exp_min:toInt()*percent*0.01
            end
        end
        self.m_exp_label:setString(string_helper.game_school_select_scene.msg .. tostring(gainExp));
        local addLevel,percentage = self:getLevelUpValua(cardData.lv,cardData.exp + gainExp);
        local level_max = cardData.level_max
        local toLevel = math.min(level_max,cardData.lv + addLevel);
        cclog("level_max ============ " .. level_max .. " ; toLevel ==== " .. toLevel .. " ; cardData.lv = " .. cardData.lv)
        if addLevel >= 0 and toLevel > cardData.lv then
            self.m_level_label:setString(string_helper.game_school_select_scene.level .. cardData.lv .. " -> " .. toLevel);
        else
            self.m_level_label:setString(string_helper.game_school_select_scene.level .. cardData.lv);
        end
    else
        self.m_exp_label:setString(string_helper.game_school_select_scene.msg1);
        self.m_level_label:setString("");
        local typeItem = character_train_rate_config:getNodeWithKey(tostring(self.m_train_type));
        if typeItem then
            local percent = typeItem:getNodeWithKey("exp_rate"):toInt();
            game_util:setCCControlButtonTitle(self.m_type_btn,tostring(percent) .. "%")
        end
        local timeItem = character_train_time_config:getNodeWithKey(tostring(self.m_train_time));
        
        if timeItem then
            local time_need = timeItem:getNodeWithKey("time"):toInt()*3600;
            game_util:setCCControlButtonTitle(self.m_time_btn,game_util:formatTime(time_need));
        end
	end
    self:refreshTips();
end

--[[--
    
]]
function game_school_select_scene.getLevelUpValua(self,currentLevel,totalExp)
    local character_base_cfg = getConfig(game_config_field.character_base);
    local character_base_item = nil;
    local addLevel = 0;
    local percentage = 0;
    local function checkValue()
        local character_base_item = character_base_cfg:getNodeWithKey(tostring(currentLevel + addLevel))
        if character_base_item then
            local maxExp = character_base_item:getNodeWithKey("exp"):toInt();
            if maxExp ~= 0 then
                if totalExp >= maxExp then
                    addLevel = addLevel + 1;
                    totalExp = totalExp - maxExp;
                    checkValue();
                else
                    percentage = 100*totalExp/maxExp
                end
            end
        end
    end
    checkValue();
    return addLevel,percentage;
end

--[[--
    创建英雄列表
]]
function game_school_select_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    self.m_selListItem = nil;
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = 2;
    -- params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,_ = game_data:getCardDataByIndex(index+1);
                if itemData then
                    local card_id = itemData.id;
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    if self.m_selHeroId and self.m_selHeroId == card_id then
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(true);
                        self.m_selListItem = cell;
                    end
                end
                if self.m_guildNode == nil and index == 0 then
                    cell:setContentSize(itemSize);
                    self.m_guildNode = cell;
                end
            else
                m_spr_bg_up:setVisible(true);
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
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                self:refreshByType(2);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                m_sel_img:setVisible(true);
                local id = game_guide_controller:getIdByTeam("11");
                if id == 85 then
                    game_guide_controller:gameGuide("show","11",86,{tempNode = self.m_ok_btn})
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
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新
]]
function game_school_select_scene.refreshByType(self,showType)
    self.m_showType = showType;
    if showType == 1 then
        self.m_material_id_table = {};
        self.m_back_btn_1:setVisible(true);
        self.m_back_btn_2:setVisible(false);
        self.m_anim_node:setVisible(false);
        self.m_sel_btn:setVisible(true);
        self.m_ok_btn:setVisible(false);
    elseif showType == 2 then
        self.m_back_btn_1:setVisible(true);
        self.m_back_btn_2:setVisible(false);
        self.m_anim_node:setVisible(true);
        self.m_sel_btn:setVisible(false);
        self.m_ok_btn:setVisible(true);
    end
    self:refreshTips();
end

--[[--
    刷新按钮状态
]]
function game_school_select_scene.refreshTips(self)
    if self.m_showType == 1 then
        self.m_cost_node:setVisible(false);
        self.m_tips_label:setVisible(true);
        -- if self.m_selHeroId == nil then
            self.m_tips_label:setString(string_helper.game_school_select_scene.text)
            self.m_sel_btn:setVisible(false);
        -- else
        --     local _,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
        --     local cardName = heroCfg:getNodeWithKey("name"):toStr();
        --     self.m_tips_label:setString("您确定选择" .. cardName .. "吗?")
        --     self.m_sel_btn:setVisible(true);
        -- end
    elseif self.m_showType == 2 then
        self.m_cost_node:setVisible(true);
        self.m_tips_label:setVisible(false);
        local totalFood = game_data:getUserStatusDataByKey("food") or 0
        self.m_food_total_label:setString(tostring(totalFood));
        local totalGold = game_data:getUserStatusDataByKey("coin") or 0
        self.m_gold_total_label:setString(tostring(totalGold));

        -- if self.m_selHeroId then
        --     self.m_tips_label:setString(tostring(self.m_cost_str));
        -- end
    end
end

--[[--
]]
function game_school_select_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    local id = game_guide_controller:getIdByTeam("11");
    if id == 84 then
        self.m_tableView:setTouchEnabled(false);
        game_guide_controller:gameGuide("show","11",85,{tempNode = self.m_guildNode})
    end
end

--[[--
    刷新ui
]]
function game_school_select_scene.refreshUi(self)
    self:refreshCardTableView();
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshByType(self.m_showType);
end
--[[--
    初始化
]]
function game_school_select_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_material_id_table = {};
    if t_params.material_id_table and type(t_params.material_id_table) == "table" then
        self.m_material_id_table = t_params.material_id_table;
    end
    self.m_showType = 1;
    self.m_needMoney = 0;
    self.m_cost_str = "";
    self.m_posIndex = t_params.posIndex;
    self.m_train_type = 1;
    self.m_train_time = 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_school_select_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return game_school_select_scene;
