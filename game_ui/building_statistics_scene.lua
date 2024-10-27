---  建筑统计ui 

local building_statistics_scene = {
    m_statistucs_list_bg = nil,
    m_building_list_bg = nil,
    m_pop_ui = nil,
    m_showStatistucsTable = nil,
    m_popJsonData = nil,
};
--[[--
    销毁ui
]]
function building_statistics_scene.destroy(self)
    -- body
    cclog("-----------------building_statistics_scene destroy-----------------");
    self.m_statistucs_list_bg = nil;
    self.m_building_list_bg = nil;
    self.m_pop_ui = nil;
    self.m_showStatistucsTable = nil;
    if self.m_popJsonData ~= nil then
        self.m_popJsonData:delete();
        self.m_popJsonData = nil;
    end
end
--[[--
    返回
]]
function building_statistics_scene.back(self,type)

	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function building_statistics_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        elseif btnTag == 2 then--排序

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_building_statistics.ccbi");
    self.m_statistucs_list_bg = tolua.cast(ccbNode:objectForName("m_statistucs_list_bg"), "CCNode");--
    self.m_building_list_bg = tolua.cast(ccbNode:objectForName("m_building_list_bg"), "CCNode");--
    return ccbNode;
end

--[[--
    创建统计列表
]]
function building_statistics_scene.createStatistucsTableView(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #self.m_showStatistucsTable;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("jztj_kuang2.png");
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_building_statistics_top_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = cell:getChildByTag(10);
            local itemData = self.m_showStatistucsTable[index+1];
            if ccbNode and itemData then
                tolua.cast(ccbNode:objectForName("m_type_label"),"CCLabelTTF"):setString(itemData.name);
                tolua.cast(ccbNode:objectForName("m_msg_1_label"),"CCLabelTTF"):setString(itemData.showMsg1);
                tolua.cast(ccbNode:objectForName("m_msg_2_label"),"CCLabelTTF"):setString(itemData.showMsg2);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if self.m_pop_ui == nil then
                self.m_pop_ui = self:createPop(self.m_showStatistucsTable[index+1]);
                game_scene:getPopContainer():addChild(self.m_pop_ui);
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建中立地图统计列表
]]
function building_statistics_scene.createBuildingTableView(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = 10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("jztj_kuang1.png");
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_building_statistics_bottom_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建弹出框列表
]]
function building_statistics_scene.createPopTableView(self,viewSize,jsonData)
    if jsonData == nil then
        return;
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = jsonData:getNodeCount();
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("jztj_kuang1.png");
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_building_statistics_pop_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local itemData = jsonData:getNodeAt(index-1);
            local ccbNode = cell:getChildByTag(10);
            if ccbNode and itemData then
                cclog("createPopTableView ======================" .. itemData:getKey());
                local building_mine_item = getConfig("building_mine"):getNodeWithKey(itemData:getKey());
                if building_mine_item ~= nil then
                    -- local image = building_mine_item:getNodeWithKey("image"):toStr();
                    tolua.cast(ccbNode:objectForName("m_name_label"),"CCLabelTTF"):setString(building_mine_item:getNodeWithKey("building_name"):toStr());
                    local produce = building_mine_item:getNodeWithKey("produce");
                    if produce ~= nil then
                        tolua.cast(ccbNode:objectForName("m_add_label"),"CCLabelTTF"):setString("+" .. produce:toStr());
                    else
                        local levelup = building_mine_item:getNodeWithKey("levelup");
                        if levelup ~= nil then
                            tolua.cast(ccbNode:objectForName("m_add_label"),"CCLabelTTF"):setString("+" .. levelup:toStr());
                        else
                            tolua.cast(ccbNode:objectForName("m_add_label"),"CCLabelTTF"):setString("+0");
                        end
                    end 
                end
                tolua.cast(ccbNode:objectForName("m_num_label"),"CCLabelTTF"):setString("×" .. itemData:toStr());
            end

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建弹出框
]]
function building_statistics_scene.createPop(self,itemData)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        if self.m_pop_ui then--关闭
            self.m_pop_ui:removeFromParentAndCleanup(true);
            self.m_pop_ui = nil;
            if self.m_popJsonData ~= nil then
                self.m_popJsonData:delete();
                self.m_popJsonData = nil;
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_building_statistics_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    local m_building_list_bg = tolua.cast(ccbNode:objectForName("m_building_list_bg"), "CCNode");
    if self.m_popJsonData ~= nil then
        self.m_popJsonData:delete();
    end
    self.m_popJsonData = util_json:new(json.encode(itemData.jsonItemData));
    local tableView = self:createPopTableView(m_building_list_bg:getContentSize(),self.m_popJsonData);
    tableView:setDefaultTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_building_list_bg:addChild(tableView);


    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷行ui
]]
function building_statistics_scene.refreshUi(self)
    self.m_showStatistucsTable = {};
    local building_ability = game_data:getBuildingAbilityData();
    local private_building = game_data:getPrivateBuildingData();
    local resourceData = game_data:getResourceData();
    for typeName,private_building_item in pairs(private_building) do
        if game_util:getTableLen(private_building_item) > 0 then
            local tempTable = {};
            tempTable.type = typeName;
            if typeName == "food" then
                tempTable.name=string_helper.building_statistics_scene.food;
                tempTable.showMsg1 = string_helper.building_statistics_scene.showMsg1
                tempTable.showMsg2 = tostring(resourceData.food_ability*60) .. string_helper.building_statistics_scene.hour
            elseif typeName == "metal" then
                tempTable.name=string_helper.building_statistics_scene.metal;
                tempTable.showMsg1 = string_helper.building_statistics_scene.showMsg1
                tempTable.showMsg2 = tostring(resourceData.metal_ability*60) .. string_helper.building_statistics_scene.hour
            elseif typeName == "energy" then
                tempTable.name=string_helper.building_statistics_scene.energy;
                tempTable.showMsg1 = string_helper.building_statistics_scene.showMsg1
                tempTable.showMsg2 = tostring(resourceData.energy_ability*60) .. string_helper.building_statistics_scene.hour
            elseif typeName == "harbor" then
                tempTable.name=string_helper.building_statistics_scene.harbor;
                tempTable.showMsg1 = string_helper.building_statistics_scene.level
                tempTable.showMsg2 = "Lv." .. building_ability.harbor_ability
            elseif typeName == "laboratory" then
                tempTable.name=string_helper.building_statistics_scene.laboratory;
                tempTable.showMsg1 = string_helper.building_statistics_scene.level
                tempTable.showMsg2 = "Lv." .. building_ability.laboratory_ability
            elseif typeName == "school" then
                tempTable.name=string_helper.building_statistics_scene.school;
                tempTable.showMsg1 = string_helper.building_statistics_scene.level
                tempTable.showMsg2 = "Lv." .. building_ability.school_ability
            elseif typeName == "factory" then
                tempTable.name=string_helper.building_statistics_scene.factory;
                tempTable.showMsg1 = string_helper.building_statistics_scene.level
                tempTable.showMsg2 = "Lv." .. building_ability.factory_ability
            elseif typeName == "hospital" then
                tempTable.name=string_helper.building_statistics_scene.hospital;
                tempTable.showMsg1 = string_helper.building_statistics_scene.level
                tempTable.showMsg2 = "Lv." .. building_ability.hospital_ability
            end
            tempTable.jsonItemData = private_building_item;
            self.m_showStatistucsTable[#self.m_showStatistucsTable+1] = tempTable;
        end
    end

    self.m_statistucs_list_bg:removeAllChildrenWithCleanup(true);
    self.m_building_list_bg:removeAllChildrenWithCleanup(true);
    self.m_statistucs_list_bg:addChild(self:createStatistucsTableView(self.m_statistucs_list_bg:getContentSize()));
    self.m_building_list_bg:addChild(self:createBuildingTableView(self.m_building_list_bg:getContentSize()));
end

--[[--
    初始化
]]
function building_statistics_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function building_statistics_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return building_statistics_scene;