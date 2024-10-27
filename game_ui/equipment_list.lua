--- 装备列表 

local equipment_list = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_posIndex = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_openType = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_ok_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_showIndex = nil,
    m_material_id_table = nil,
    m_sell_node = nil,
    m_gain_value_label = nil,
    m_is_notice = nil,
    m_popUi = nil,
    m_gain_icon = nil,
    m_num_label = nil,
    m_sell_btn = nil,
    m_ccbNode = nil,
    m_func_btn = nil,
};
--[[--
    销毁ui
]]
function equipment_list.destroy(self)
    -- body
    cclog("-----------------equipment_list destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_posIndex = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_openType = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_ok_btn = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_showIndex = nil;
    self.m_material_id_table = nil;
    self.m_sell_node = nil;
    self.m_gain_value_label = nil;
    self.m_is_notice = nil;
    self.m_popUi = nil;
    self.m_gain_icon = nil;
    self.m_num_label = nil;
    self.m_sell_btn = nil;
    self.m_ccbNode = nil;
    self.m_func_btn = nil;
end

--[[--
    返回
]]
function equipment_list.back(self,type)
    game_data:resetNewEquipIdTab();
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
function equipment_list.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            else
                self:back();
            end
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local selSort = tostring(EQUIP_SORT_TAB[btnTag].sortType);
                self:refreshEquipTableView(selSort);
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = EQUIP_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = self.m_selSort})
        elseif btnTag == 3 then--贩卖
            self:onSureFunc();
        elseif btnTag == 4 then--一键贩卖
            local function callBackFunc()
                self.m_material_id_table = {};
                self:refreshTabBtn();
            end
            game_scene:addPop("game_sell_pop",{showType = 2,callBackFunc = callBackFunc})
        elseif btnTag == 11 then--
            self.m_ccbNode:runAnimations("anim_1")
            self.m_showIndex = 1;
            self:refreshTabBtn();
        elseif btnTag == 12 then--
            self.m_func_btn:setVisible(false)
            self.m_ccbNode:runAnimations("anim_2")
            self.m_showIndex = 2;
            self:refreshTabBtn();
        elseif btnTag == 101 then--查看道具
            game_scene:enterGameUi("items_scene");
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list_new.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
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
    game_util:setCCControlButtonTitle(self.m_func_btn,string_helper.ccb.file20)
    --game_util:setControlButtonTitleBMFont(self.m_sell_btn)
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    --game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file16)
    game_util:setCCControlButtonTitle(self.m_sell_btn,string_helper.ccb.file17)
    self.m_gain_icon = ccbNode:spriteForName("m_gain_icon")
    self.m_gain_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_metal.png"));
    local function animEndFunc(animName)
        if animName == "anim_2" then
            self.m_func_btn:setVisible(false)
        else
            self.m_func_btn:setVisible(true)
        end
    end
    ccbNode:registerAnimFunc(animEndFunc)
    self.m_ccbNode = ccbNode;
    if self.m_showIndex == 2 then
        self.m_func_btn:setVisible(false)
        self.m_ccbNode:runAnimations("anim_2")
    else
        self.m_func_btn:setVisible(true)
    end
    return ccbNode;
end

--[[--

]]
function equipment_list.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end


--[[--

]]
function equipment_list.onSureFunc(self)
    if #self.m_material_id_table == 0 then
        game_util:addMoveTips({text = string_helper.equipment_list.text});
        return;
    end

    local function sendRequest()
        local function responseMethod(tag,gameData)
            self.m_material_id_table = {};
            self:refreshTabBtn();
            self:removePop();
            local sell_metal = gameData:getNodeWithKey("data"):getNodeWithKey("sell_metal"):toInt();
            game_util:rewardTipsByDataTable({metal = sell_metal});
        end
        --  equip= 
        local params = "";
        table.foreach(self.m_material_id_table,function(k,v)
            params = params .. "equip=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_sell"), http_request_method.POST, params,"equip_sell");
    end
    sendRequest();
end

--[[--
    创建装备列表
]]
function equipment_list.createEquipTableView(self,viewSize,tableData)
    local equip_max = game_data:getUserStatusDataByKey("equip_max") or 0;
    local itemsCount = game_data:getEquipCount()
    self.m_num_label:setString(itemsCount .. "/" .. equip_max);
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local tempId = tableData[index+1]
                local itemData,itemCfg = game_data:getEquipDataById(tempId);
                game_util:setEquipItemInfoByTable(ccbNode,itemData);
                local m_new_icon = ccbNode:spriteForName("m_new_icon")
                if game_data:isNewEquipFlagById(tempId) then
                    m_new_icon:setVisible(true);
                else
                    m_new_icon:setVisible(false);
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- if self.m_openType == "game_function_pop" then return end
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            local tempId = tableData[index+1]
            local itemData,itemCfg = game_data:getEquipDataById(tempId);
            if self.m_itemOnClick then
                self.m_itemOnClick(tempId);
            else
                local function callBack(typeName,t_param)
                    if typeName == "unload" then
                        game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
                        self:destroy();
                    elseif typeName == "strengthen" then
                        game_scene:enterGameUi("equipment_strengthen",{gameData = nil});
                        self:destroy();
                    elseif typeName == "evolution" then
                        game_scene:enterGameUi("equip_evolution",{gameData = nil});
                        self:destroy();
                    end
                end
                local existFlag,cardName,posEquipData = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),tempId)
                if existFlag then
                    game_scene:addPop("game_equip_info_pop",{tGameData = itemData,callBack = callBack, openType=3,posEquipData=posEquipData});
                else
                    game_scene:addPop("game_equip_info_pop",{tGameData = itemData,callBack = callBack, openType=3});
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function equipment_list.refreshEquipTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    game_data:equipSortByTypeName(self.m_selSort)
    local equipData = game_data:getEquipIdTable();
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),equipData);
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    创建筛选的列表
]]
function equipment_list.createFilterTableView(self,viewSize)
    local equip_max = game_data:getUserStatusDataByKey("equip_max") or 0;
    local itemsCount = game_data:getEquipCount()
    self.m_num_label:setString(itemsCount .. "/" .. equip_max);
    -- self.m_num_label:setString("");
    local equipCfg = getConfig(game_config_field.equip);
    local equipsDataTable = game_data:getEquipData();
    local showDataTable = {};
    local itemCfg = nil;
    for key,itemData in pairs(equipsDataTable) do
        itemCfg = equipCfg:getNodeWithKey(itemData.c_id);
        local existFlag,cardName = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
        if itemCfg and not existFlag then
            showDataTable[#showDataTable+1] = {itemData = itemData,itemCfg = itemCfg}
        else
            cclog("------------------------ not in team -------------------" .. itemData.id)
        end
    end
    local function sortFunc(dataOne,dataTwo)
        return dataOne.itemCfg:getNodeWithKey("quality"):toInt() > dataTwo.itemCfg:getNodeWithKey("quality"):toInt();
    end
    table.sort(showDataTable,sortFunc)
    local itemsCount = #showDataTable;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = true;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local itemData = showDataTable[index+1].itemData;
                local itemCfg = showDataTable[index+1].itemCfg;
                local dataId = itemData.id;
                if ccbNode and itemData then
                    game_util:setEquipItemInfoByTable(ccbNode,itemData);
                    local flag,k = game_util:idInTableById(tostring(dataId),self.m_material_id_table)
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
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                local itemData = showDataTable[index+1].itemData;
                local dataId = tostring(itemData.id);
                local flag,k = game_util:idInTableById(dataId,self.m_material_id_table)
                if flag and k ~= nil then
                    -- cclog("remove select material hero id ==========" .. dataId);
                    table.remove(self.m_material_id_table,k);
                    m_sel_img:setVisible(false);
                else
                    -- cclog("add select material hero id ==========" .. dataId);
                    table.insert(self.m_material_id_table,dataId);
                    m_sel_img:setVisible(true);
                end
                self:refreshGainValue();
                -- print("---------------------------------m_material_id_table-----start");
                -- table.foreach(self.m_material_id_table,print);
                -- print("--------------------------------m_material_id_table------end");
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--

]]
function equipment_list.refreshGainValue(self)
    self.m_is_notice = 0;
    local equipCfg = getConfig(game_config_field.equip);
    local gainValue = 0;
    local itemData,itemCfg;
    table.foreach(self.m_material_id_table,function(k,v)
        itemData,itemCfg = game_data:getEquipDataById(tostring(v));
        if itemData and itemCfg then
            gainValue = gainValue + itemCfg:getNodeWithKey("sell_metal"):toInt();
        end
    end);
    cclog("self.m_is_notice ===============" .. self.m_is_notice)
    self.m_gain_value_label:setString(gainValue)
end


--[[--

]]
function equipment_list.refreshTab1(self)
    self.m_ok_btn:setVisible(false);
    self.m_sort_btn:setVisible(true);
    -- self.m_sell_node:setVisible(false);
    self:refreshEquipTableView(self.m_selSort);
end

--[[--

]]
function equipment_list.refreshTab2(self)
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
function equipment_list.refreshTabBtn(self)
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
function equipment_list.refreshUi(self)
    self:refreshTabBtn();
end
--[[--
    初始化
]]
function equipment_list.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = game_data:getEquipSortType();
    self.m_openType = t_params.openType or "";
    self.m_showIndex = t_params.showIndex or 1;
    self.m_material_id_table = {};
    self.m_is_notice = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function equipment_list.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return equipment_list;