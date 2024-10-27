---  能晶摘除

local removal_crystal_scene = {
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_attr_label_tab = nil,
    m_list_view_bg = nil,
    m_list_view_bg2 = nil,
    m_sel_btn = nil,
    m_showType = nil,
    m_selListItem = nil,
    m_attr_node = nil,
    m_maxCrystalLv = nil,
    m_selIndex = nil,
    m_selHeroDataBackup = nil,
    m_crystal_total = nil,
    m_cost_str = nil,
    m_curPage = nil,
    m_cost_food_label = nil,
    m_food_total_label = nil,
    m_crystal_total_label = nil,
    m_gain_crystal_label = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_cultureLevelTab = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
};
--[[--
    销毁ui
]]
function removal_crystal_scene.destroy(self)
    -- body
    cclog("-----------------removal_crystal_scene destroy-----------------");
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_attr_label_tab = nil;
    self.m_list_view_bg = nil;
    self.m_list_view_bg2 = nil;
    self.m_sel_btn = nil;
    self.m_showType = nil;
    self.m_selListItem = nil;
    self.m_attr_node = nil;
    self.m_maxCrystalLv = nil;
    self.m_selIndex = nil;
    self.m_selHeroDataBackup = nil;
    self.m_crystal_total = nil;
    self.m_cost_str = nil;
    self.m_curPage = nil;
    self.m_cost_food_label = nil;
    self.m_food_total_label = nil;
    self.m_crystal_total_label = nil;
    self.m_gain_crystal_label = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_cultureLevelTab = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
end

local typeTable = {
    {type="hp",typeName=string_helper.removal_crystal_scene.hp,dataKey="hp_crystal",bg_img = "njzc_shengming_down.png",lv = 1,cfgKey1="need_crstal_hp",cfgKey2 = "add_hp"},
    {type="patk",typeName=string_helper.removal_crystal_scene.patk,dataKey="patk_crystal",bg_img = "njzc_wugong_down.png",lv = 1,cfgKey1="need_crstal_patk",cfgKey2 = "add_patk"},
    {type="matk",typeName=string_helper.removal_crystal_scene.matk,dataKey="matk_crystal",bg_img = "njzc_mogong_down.png",lv = 1,cfgKey1="need_crstal_matk",cfgKey2 = "add_matk"},
    {type="def",typeName=string_helper.removal_crystal_scene.def,dataKey="def_crystal",bg_img = "njzc_fangyu_down.png",lv = 1,cfgKey1="need_crstal_def",cfgKey2 = "add_def"},
    {type="speed",typeName=string_helper.removal_crystal_scene.speed,dataKey="speed_crystal",bg_img = "njzc_sudu_down.png",lv = 1,cfgKey1="need_crstal_speed",cfgKey2 = "add_speed"},
};

--[[--
    返回
]]
function removal_crystal_scene.back(self,backType)
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
function removal_crystal_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then--开始改造
            if self.m_selHeroId == nil then
                game_util:addMoveTips({text = string_helper.removal_crystal_scene.text});
                return;
            end
            self:onSureFunc();
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
            game_data:cardsSortByTypeName(selSort);
            self:refreshSortTabBtn(btnTag - 200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_removal_crystal.ccbi");

    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_list_view_bg2 = ccbNode:layerForName("m_list_view_bg2")
    self.m_attr_node = ccbNode:nodeForName("m_attr_node")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_crystal_total_label = ccbNode:labelBMFontForName("m_crystal_total_label")
    self.m_gain_crystal_label = ccbNode:labelBMFontForName("m_gain_crystal_label")
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    local title93 = ccbNode:labelTTFForName("title93");
    local title94 = ccbNode:labelTTFForName("title94");
    local title95 = ccbNode:labelTTFForName("title95");
    local title96 = ccbNode:labelTTFForName("title96");
    local title97 = ccbNode:labelTTFForName("title97");
    local title98 = ccbNode:labelTTFForName("title98");
    local title99 = ccbNode:labelTTFForName("title99");
    title93:setString(string_helper.ccb.title93);
    title94:setString(string_helper.ccb.title94);
    title95:setString(string_helper.ccb.title95);
    title96:setString(string_helper.ccb.title96);
    title97:setString(string_helper.ccb.title97);
    title98:setString(string_helper.ccb.title98);
    title99:setString(string_helper.ccb.title99);
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title100)
    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
    game_util:setControlButtonTitleBMFont(self.m_ok_btn)

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
    return ccbNode;
end

--[[--

]]
function removal_crystal_scene.onSureFunc(self)
    if self.m_crystal_total == 0 then
        game_util:addMoveTips({text = string_helper.removal_crystal_scene.text2});
        return;
    end
    if self.m_selHeroId == nil then
        game_util:addMoveTips({text = string_helper.removal_crystal_scene.choose_hero});
        return;
    end
    local requestCode = 0;
    local cardData,_ = game_data:getCardDataById(tostring(self.m_selHeroId));
    self.m_selHeroDataBackup = util.table_new(cardData);
    local function sendRequest()
        local function responseMethod(tag,gameData)
            game_sound:playUiSound("crystal_remove")
            game_util:addMoveTips({text = string_helper.removal_crystal_scene.del_success});
            -- local cardData,_ = game_data:getCardDataById(tostring(self.m_selHeroId));                
            -- game_scene:addPop("game_hero_info_pop",{tGameData = cardData,heroDataBackup = self.m_selHeroDataBackup,openType=2})
            self:refreshHeroInfo(self.m_selHeroId);

        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("laboratory_wash_down"), http_request_method.GET,{card_id = self.m_selHeroId},"laboratory_wash_down")
    end
    sendRequest();
end

--[[--
    属性英雄信息
]]
function removal_crystal_scene.refreshHeroInfo(self,heroId)
    self.m_selHeroId = heroId;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
	if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);

        local starCount = cardData.star
        local character_strengthen = getConfig("character_strengthen");
        local character_strengthen_count = character_strengthen:getNodeCount();
        local crystal_item = nil;
        for i=1,character_strengthen_count do
            crystal_item = character_strengthen:getNodeAt(i-1);
            if crystal_item:getNodeWithKey("need_star"):toInt() == starCount then
                self.m_maxCrystalLv = math.max(self.m_maxCrystalLv,tonumber(crystal_item:getKey()));
            end
        end
        self:refreshHeroAttr(heroId,1);
    else
        self:refreshTips();
	end
end


--[[--
    属性英雄信息
]]
function removal_crystal_scene.refreshHeroAttr(self,heroId,crystalType)
    self.m_cost_str = string_helper.removal_crystal_scene.m_cost_str;
    self.m_crystal_total = 0;
    if heroId ~= nil and heroId ~= "-1" then
        local character_strengthen = getConfig("character_strengthen");
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local hp,patk,matk,def,speed = cardData.hp,cardData.patk,cardData.matk,cardData.def,cardData.speed
        local hp_crystal_lv,patk_crystal_lv,matk_crystal_lv,def_crystal_lv,speed_crystal_lv = cardData.hp_crystal,cardData.patk_crystal,cardData.matk_crystal,cardData.def_crystal,cardData.speed_crystal
    
        typeTable[1].lv=math.min(self.m_maxCrystalLv,hp_crystal_lv+1)
        typeTable[2].lv=math.min(self.m_maxCrystalLv,patk_crystal_lv+1)
        typeTable[3].lv=math.min(self.m_maxCrystalLv,matk_crystal_lv+1)
        typeTable[4].lv=math.min(self.m_maxCrystalLv,def_crystal_lv+1)
        typeTable[5].lv=math.min(self.m_maxCrystalLv,speed_crystal_lv+1)

        cclog("self.m_maxCrystalLv ==="  .. self.m_maxCrystalLv)
        cclog("hp_crystal_lv ==="  .. hp_crystal_lv)
        cclog("patk_crystal_lv ==="  .. patk_crystal_lv)
        cclog("matk_crystal_lv ==="  .. matk_crystal_lv)
        cclog("def_crystal_lv ==="  .. def_crystal_lv)
        cclog("speed_crystal_lv ==="  .. speed_crystal_lv)

        self.m_cultureLevelTab[1]:setString("Lv." .. hp_crystal_lv)
        self.m_cultureLevelTab[2]:setString("Lv." .. patk_crystal_lv)
        self.m_cultureLevelTab[3]:setString("Lv." .. matk_crystal_lv)
        self.m_cultureLevelTab[4]:setString("Lv." .. def_crystal_lv)
        self.m_cultureLevelTab[5]:setString("Lv." .. speed_crystal_lv)

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

        game_util:setAttributeLable2(self.m_attr_label_tab.hp[1],add_hp+1,add_hp,"-");
        game_util:setAttributeLable2(self.m_attr_label_tab.patk[1],add_patk+1,add_patk,"-");
        game_util:setAttributeLable2(self.m_attr_label_tab.matk[1],add_matk+1,add_matk,"-");
        game_util:setAttributeLable2(self.m_attr_label_tab.def[1],add_def+1,add_def,"-");
        game_util:setAttributeLable2(self.m_attr_label_tab.speed[1],add_speed+1,add_speed,"-");

        if crystalType then
            local gain_patk_crystal,gain_matk_crystal,gain_def_crystal,gain_speed_crystal,gain_hp_crystal=0,0,0,0,0;
            local crystal_item = nil;
            local need_crstal = nil;
            if patk_crystal_lv > 0 then
                for lv=1,patk_crystal_lv do
                    crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                    if crystal_item ~= nil then
                        need_crstal = crystal_item:getNodeWithKey("need_crstal_patk");
                        gain_patk_crystal = gain_patk_crystal + need_crstal:getNodeAt(1):toInt();
                        cclog("gain_patk_crystal ======" .. gain_patk_crystal)
                    end
                end
            end
            if matk_crystal_lv > 0 then
                for lv=1,matk_crystal_lv do
                    crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                    if crystal_item ~= nil then
                        need_crstal = crystal_item:getNodeWithKey("need_crstal_matk");
                        gain_matk_crystal = gain_matk_crystal+ need_crstal:getNodeAt(1):toInt();
                        cclog("gain_matk_crystal ======" .. gain_matk_crystal)
                    end
                end
            end
            if def_crystal_lv > 0 then
                for lv=1,def_crystal_lv do
                    crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                    if crystal_item ~= nil then
                        need_crstal = crystal_item:getNodeWithKey("need_crstal_def");
                        gain_def_crystal = gain_def_crystal+ need_crstal:getNodeAt(1):toInt();
                        cclog("gain_def_crystal ======" .. gain_def_crystal)
                    end
                end
            end
            if speed_crystal_lv > 0 then
                for lv=1,speed_crystal_lv do
                    crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                    if crystal_item ~= nil then
                        need_crstal = crystal_item:getNodeWithKey("need_crstal_speed");
                        gain_speed_crystal = gain_speed_crystal+ need_crstal:getNodeAt(1):toInt();
                        cclog("gain_speed_crystal ======" .. gain_speed_crystal)
                    end
                end
            end
            if hp_crystal_lv > 0 then
                for lv=1,hp_crystal_lv do
                    crystal_item = character_strengthen:getNodeWithKey(tostring(lv));
                    if crystal_item ~= nil then
                        need_crstal = crystal_item:getNodeWithKey("need_crstal_hp");
                        gain_hp_crystal = gain_hp_crystal+ need_crstal:getNodeAt(1):toInt();
                    end
                end
            end
            self.m_crystal_total = gain_patk_crystal + gain_matk_crystal + gain_def_crystal + gain_speed_crystal + gain_hp_crystal;
            -- self.m_cost_str = "获得能晶：" .. self.m_crystal_total .. "\n消耗食物：" .. (self.m_crystal_total*200)
        end
    else
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
function removal_crystal_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
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
                local itemData,_ = game_data:getCardDataByIndex(index+1);
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
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
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
    刷新
]]
function removal_crystal_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function removal_crystal_scene.refreshSortTabBtn(self,sortIndex)
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
function removal_crystal_scene.refreshByType(self,showType)
    self.m_showType = showType;
    if showType == 1 then
        self:refreshSortTabBtn(self.m_selSortIndex);
    end
    self:refreshTips();
end


--[[--
    刷新状态
]]
function removal_crystal_scene.refreshTips(self)
    if self.m_showType == 1 then
        if self.m_selHeroId then
            self.m_tips_spr_1:setVisible(false);
        else
            self.m_tips_spr_1:setVisible(true);
        end
        local totalFood = game_data:getUserStatusDataByKey("food") or 0
        local value,unit = game_util:formatValueToString(totalFood);
        self.m_food_total_label:setString(value .. unit);
        game_util:setCostLable(self.m_cost_food_label,self.m_crystal_total*10,totalFood);
        self.m_gain_crystal_label:setString(tostring(self.m_crystal_total))
        local totalCrystal = game_data:getUserStatusDataByKey("crystal") or 0
        local value,unit = game_util:formatValueToString(totalCrystal);
        self.m_crystal_total_label:setString(tostring(value .. unit))
    end
end

--[[--
    刷新ui
]]
function removal_crystal_scene.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshByType(self.m_showType);
end
--[[--
    初始化
]]
function removal_crystal_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_selHeroId = t_params.selHeroId;
    self.m_attr_label_tab = {hp={},matk={},patk={},def={},speed={}};
    self.m_showType = 1;
    self.m_maxCrystalLv = 1;
    self.m_selIndex = 1;
    self.m_crystal_total = 0;
    self.m_cultureLevelTab = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
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
function removal_crystal_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return removal_crystal_scene;
