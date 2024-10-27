---  英雄列表  

local game_hero_list = {
    m_list_view_bg = nil,
    m_selSortType = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_curPage2 = nil,
    m_ok_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_showIndex = nil,
    m_material_id_table = nil,
    m_sell_node = nil,
    m_gain_value_label = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_num_label = nil,
    m_sell_btn = nil,
    m_ccbNode = nil,
    m_openType = nil,
    m_func_btn = nil,
    m_sell_id = nil,
};
--[[--
    销毁
]]
function game_hero_list.destroy(self)
    -- body
    cclog("-----------------game_hero_list destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_selSortType = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_curPage2 = nil;
    self.m_ok_btn = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_showIndex = nil;
    self.m_material_id_table = nil;
    self.m_sell_node = nil;
    self.m_gain_value_label = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_num_label = nil;
    self.m_sell_btn = nil;
    self.m_ccbNode = nil;
    self.m_openType = nil;
    self.m_sell_id = nil;
    self.m_func_btn = nil;
end

--[[--
    返回
]]
function game_hero_list.back(self,type)
    game_data:resetNewCardIdTab();
    if self.m_openType == "game_small_map_scene" then
        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_small_map_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
    elseif self.m_openType == "map_building_detail_scene" then
        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("map_building_detail_scene",{cityId = game_data:getSelCityId(),buildingId = game_data:getSelBuildingId(),gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
    elseif self.m_openType == "active_map_building_detail_scene" then
        local activeChapterId = game_data:getSelActiveDataByKey("activeChapterId")
        local activeId = game_data:getSelActiveDataByKey("activeId");
        local nextStep = game_data:getSelActiveDataByKey("nextStep");
        game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = activeChapterId,activeId = activeId,next_step = nextStep});
    elseif self.m_openType == "game_neutral_city_map" then
        local city_id = game_data:getSelNeutralCityId();
        local function responseMethod(tag,gameData)
            game_data:setSelNeutralCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_neutral_city_map",{gameData = gameData,city_id = city_id});
            self:destroy();
        end
        -- 公共地图，打开城市 city_id=10001
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_open"), http_request_method.GET, {city_id = city_id},"public_city_open")
    elseif self.m_openType == "game_activity_live" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
            game_scene:enterGameUi("game_activity_live",{liveData = live_data})
            game_util:rewardTipsByDataTable(reward);
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    elseif self.m_openType == "game_pirate_precious" then
        game_scene:enterGameUi("game_pirate_precious",{})
        self:destroy();
    elseif self.m_openType == "map_world_scene" then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_hero_list.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            else
                self:back();
            end
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                self.m_selSortType = CARD_SORT_TAB[btnTag].sortType;
                game_data:cardsSortByTypeName(self.m_selSortType);
                self:refreshUi();
            end
            local selSortType = game_data:getCardSortType();
            game_scene:addPop("game_sort_pop",{btnTitleTab = CARD_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = selSortType})
        elseif btnTag == 3 then--贩卖
            self:onSureFunc();
        elseif btnTag == 4 then--一键贩卖
            local function callBackFunc()
                self.m_material_id_table = {};
                self:refreshTabBtn();
            end
            game_scene:addPop("game_sell_pop",{showType = 1,callBackFunc = callBackFunc})
        elseif btnTag == 11 then--
            self.m_ccbNode:runAnimations("anim_1")
            self.m_showIndex = 1;
            self:refreshTabBtn();
        elseif btnTag == 12 then--
            self.m_ccbNode:runAnimations("anim_2")
            self.m_showIndex = 2;
            self:refreshTabBtn();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list_new.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_sell_node = ccbNode:nodeForName("m_sell_node")
    self.m_gain_value_label = ccbNode:labelBMFontForName("m_gain_value_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.m_title_label:setString("")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1")
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")

    game_util:setCCControlButtonTitle(self.m_tab_btn_1,string_helper.ccb.text248)
    game_util:setCCControlButtonTitle(self.m_tab_btn_2,string_helper.ccb.text249)
    self.m_sell_btn = ccbNode:controlButtonForName("m_sell_btn")
    self.m_func_btn = ccbNode:controlButtonForName("m_func_btn")
    self.m_func_btn:setVisible(false);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file16)
    game_util:setCCControlButtonTitle(self.m_sell_btn,string_helper.ccb.file17)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_sell_btn)
    -- if self.m_openType ~= ""  then
    --     game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png")
    -- end
    self.m_ccbNode = ccbNode;
    if self.m_showIndex == 2 then
        self.m_ccbNode:runAnimations("anim_2")
    end
    return ccbNode;
end

--[[--

]]
function game_hero_list.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--

]]
function game_hero_list.onSureFunc(self)
    if #self.m_material_id_table == 0 then
        game_util:addMoveTips({text = string_helper.game_hero_list.text});
        return;
    end

    local function sendRequest()
        local function responseMethod(tag,gameData)
            self.m_material_id_table = {};
            self:refreshTabBtn();
            local get_food = gameData:getNodeWithKey("data"):getNodeWithKey("get_food"):toInt();
            game_util:rewardTipsByDataTable({food = get_food});
        end
        local params = "";
        table.foreach(self.m_material_id_table,function(k,v)
            params = params .. "card_id=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_butcher"), http_request_method.POST, params,"cards_butcher");
    end
    if self.m_is_notice ~= 0 then
        local openType = 4
        if self.m_is_notice == 1 then --出售进阶的卡牌
            openType = 1
        elseif self.m_is_notice == 2 then --出售高等级的卡牌
            openType = 2
        elseif self.m_is_notice == 3 then --出售蓝卡以上
            openType = 3
        end
        local params = {}
        params.m_openType = openType
        params.hero_id = self.m_sell_id
        params.okBtnCallBack = function()
            game_scene:removePopByName("game_special_tips_pop")
            sendRequest();
        end
        game_scene:addPop("game_special_tips_pop",params)
    else
        sendRequest();
    end
end

--[[--
    创建英雄列表
]]
function game_hero_list.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local card_max = game_data:getUserStatusDataByKey("card_max") or 0;
    local cardsCount = game_data:getCardsCount();
    self.m_num_label:setString(tostring(cardsCount) .. "/" .. tostring(card_max));
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
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
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    local m_new_icon = ccbNode:spriteForName("m_new_icon")
                    if game_data:isNewCardFlagById(itemData.id) then
                        m_new_icon:setVisible(true);
                    else
                        m_new_icon:setVisible(false);
                    end
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_itemOnClick then
                self.m_itemOnClick(card_id);
            else
                local function callBack(typeName)
                    typeName = typeName or ""
                    if typeName == "refresh" then
                        self:refreshUi();
                    end
                end
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--

]]
function game_hero_list.refreshTab1(self)
    self.m_ok_btn:setVisible(false);
    self.m_sort_btn:setVisible(true);
    -- self.m_sell_node:setVisible(false);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    创建筛选的列表
]]
function game_hero_list.createFilterTableView(self,viewSize)
    local card_max = game_data:getUserStatusDataByKey("card_max") or 0;
    local cardsCount = game_data:getCardsCount();
    self.m_num_label:setString(tostring(cardsCount) .. "/" .. tostring(card_max));
    
    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    local itemConfig = nil;
    for key,heroData in pairs(cardsDataTable) do
        if not game_data:heroInTeamById(key) and not game_util:getCardLockFlag(heroData) then
            itemConfig = character_detail:getNodeWithKey(heroData.c_id);
            showHeroTable[#showHeroTable+1] = {heroData = heroData,heroCfg = itemConfig}
        end
    end
    local heroCfg1,heroCfg2,quality1,quality2,character_ID1,character_ID2;
    local function sortFunc(dataOne,dataTwo)
        heroCfg1 = dataOne.heroCfg;
        heroCfg2 = dataTwo.heroCfg;
        quality1 = heroCfg1:getNodeWithKey("quality"):toInt();
        quality2 = heroCfg2:getNodeWithKey("quality"):toInt();
        if quality1 == quality2 then
            character_ID1 = heroCfg1:getNodeWithKey("character_ID"):toInt();
            character_ID2 = heroCfg2:getNodeWithKey("character_ID"):toInt();
            return character_ID1 > character_ID2;
        else
            return quality1 > quality2;
        end
    end
    table.sort(showHeroTable,sortFunc)
    local cardsCount = #showHeroTable;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage2;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.itemActionFlag = true;
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
                local itemData = showHeroTable[index+1].heroData;
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(true);
                    end
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                local itemData = showHeroTable[index+1].heroData;
                local heroId = tostring(itemData.id);
                local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
                if flag and k ~= nil then
                    -- cclog("remove select material hero id ==========" .. heroId);
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                else
                    -- cclog("add select material hero id ==========" .. heroId);
                    table.insert(self.m_material_id_table,heroId);
                    m_sel_img:setVisible(true);
                end
                self:refreshGainValue();
                -- print("---------------------------------m_material_id_table-----start");
                -- table.foreach(self.m_material_id_table,print);
                -- print("--------------------------------m_material_id_table------end");
        elseif eventType == "longClick" and item then
            local itemData = showHeroTable[index+1].heroData;
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshTab2();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage2 = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--

]]
function game_hero_list.refreshGainValue(self)
    self.m_is_notice = 0;
    local character_base_cfg = getConfig(game_config_field.character_base);
    local character_base_rate_cfg = getConfig(game_config_field.character_base_rate);
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local gainFood = 0;
    local itemData,itemCfg;
    local character_base_item = nil;
    local character_base_rate_item = nil;
    local is_notice = nil;
    -- table.foreach(self.m_material_id_table,function(k,v)
    for i=1,#self.m_material_id_table do
        local v = self.m_material_id_table[i]
        itemData,itemCfg = game_data:getCardDataById(tostring(v));
        if itemData and itemCfg then
            character_base_item = character_base_cfg:getNodeWithKey(tostring(itemData.lv));
            character_base_rate_item = character_base_rate_cfg:getNodeWithKey(itemCfg:getNodeWithKey("type"):toStr());
            gainFood = gainFood + character_base_item:getNodeWithKey("sell_food"):toInt() * character_base_rate_item:getNodeWithKey("sell_food_rate"):toFloat();
            -- is_notice = itemCfg:getNodeWithKey("is_notice"):toInt();
            -- if is_notice ~= 0 and is_notice > self.m_is_notice then
            --     self.m_is_notice = is_notice;
            -- end
            local advance_step = itemData.step -- 进阶层数
            local lv = itemData.lv  --等级
            local quality = itemData.quality --品质
            if advance_step > 0 and quality >= 3 then
                self.m_sell_id = itemData.id
                self.m_is_notice = 1
            elseif lv >= 10 then
                self.m_sell_id = itemData.id
                self.m_is_notice = 2
            elseif quality >= 3 then
                self.m_sell_id = itemData.id
                self.m_is_notice = 3
            end
        end
    end
    cclog("self.m_is_notice ===============" .. self.m_is_notice)
    self.m_gain_value_label:setString(gainFood)
end

--[[--

]]
function game_hero_list.refreshTab2(self)
    self.m_ok_btn:setVisible(true);
    self.m_sort_btn:setVisible(false);
    -- self.m_sell_node:setVisible(true);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createFilterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    self:refreshGainValue();
end

--[[--

]]
function game_hero_list.refreshTabBtn(self)
    local flag1 = self.m_showIndex == 1 and true or false
    local flag2 = self.m_showIndex == 2 and true or false
    self.m_tab_btn_1:setHighlighted(flag1);
    self.m_tab_btn_1:setEnabled(not flag1);
    self.m_tab_btn_2:setHighlighted(flag2);
    self.m_tab_btn_2:setEnabled(not flag2);
    if self.m_showIndex == 1 then
        self:refreshTab1();
    elseif self.m_showIndex == 2 then
        self:refreshTab2();
    end
end

--[[--
    刷新ui
]]
function game_hero_list.refreshUi(self)
    self:refreshTabBtn();
end


--[[--
    初始化
]]
function game_hero_list.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selSortType = "lv";
    self.m_showIndex = t_params.showIndex or 1;
    self.m_material_id_table = {};
    self.m_is_notice = 0;
    self.m_openType = t_params.openType or "";
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_list.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_hero_list;