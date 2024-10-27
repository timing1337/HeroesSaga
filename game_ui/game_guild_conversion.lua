---  公会兑换

local game_guild_conversion = {
    m_formation_layer = nil,
    m_integration_label = nil,
    m_list_view_bg = nil,
    m_intro_label = nil,
    m_guildShopTable = nil,
    m_selType = nil,
    m_selItemId = nil,
    m_typeBtnTab = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_tab_btn_4 = nil,
    m_building_lv_label = nil,
};
--[[--
    销毁ui
]]
function game_guild_conversion.destroy(self)
    -- body
    cclog("-----------------game_guild_conversion destroy-----------------");
    self.m_formation_layer = nil;
    self.m_integration_label = nil;
    self.m_list_view_bg = nil;
    self.m_intro_label = nil;
    self.m_guildShopTable = nil;
    self.m_selType = nil;
    self.m_selItemId = nil;
    self.m_typeBtnTab = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_tab_btn_4 = nil;
    self.m_building_lv_label = nil;
end
--[[--
    返回
]]
function game_guild_conversion.back(self,backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_guild_conversion.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then-- 信息
            game_scene:enterGameUi("game_guild_main",{gameData = nil});
            self:destroy();
        elseif btnTag == 3 then-- 开发
            game_scene:enterGameUi("game_guild_develop",{gameData = nil,jobType=self.m_jobType});
            self:destroy();
        elseif btnTag == 4 then-- 兑换

        elseif btnTag == 5 then-- 排行
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_data:setGuildListDataByJsonData(data:getNodeWithKey("guild_list"));
                game_scene:enterGameUi("game_guild_ranking",{gameData = nil});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_all"), http_request_method.GET, nil,"association_guild_all")
        elseif btnTag == 11 then
            if self.m_selItemId == nil then return end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                local tGameData = game_data:getSelGuildData();
                tGameData.guild.score = data:getNodeWithKey("score"):toInt();
                self.m_integration_label:setString(tGameData.guild.score);
                if self.m_selType == 1 then
                    game_data:updateMoreCardDataByJsonData(data:getNodeWithKey("cards"));
                elseif self.m_selType == 2 then
                    game_data:updateMoreEquipDataByJsonData(data:getNodeWithKey("equip"));
                elseif self.m_selType == 3 then

                end
            end
            -- 兑换物品 commodity_id＝商品id
            local params = {};
            params.commodity_id=self.m_selItemId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_buy_commodity"), http_request_method.GET, params,"association_buy_commodity")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    local function onTypeBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if self.m_selType and self.m_typeBtnTab[self.m_selType] then
            self.m_typeBtnTab[self.m_selType]:setEnabled(true)
            self.m_typeBtnTab[self.m_selType]:setSelected(false)
        end
        self:refreshTableView(btnTag);
        tagNode:setEnabled(false)
        tagNode:setSelected(true)
    end
    ccbNode:registerFunctionWithFuncName("onTypeBtnClick",onTypeBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_conversion.ccbi");
    self.m_integration_label = tolua.cast(ccbNode:objectForName("m_integration_label"), "CCLabelTTF");--
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");--
    self.m_intro_label = tolua.cast(ccbNode:objectForName("m_intro_label"), "CCLabelTTF");--
    for i=1,3 do
        self.m_typeBtnTab[#self.m_typeBtnTab+1] = ccbNode:controlButtonForName("m_type_btn_" .. i)
    end
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_4 = ccbNode:controlButtonForName("m_tab_btn_4");
    self.m_building_lv_label = ccbNode:labelTTFForName("m_building_lv_label");
    self.m_tab_btn_3:setHighlighted(true);
    self.m_tab_btn_3:setEnabled(false);
    return ccbNode;
end

--[[--
    创建道具列表
]]
function game_guild_conversion.createTableView(self,viewSize,itemType)
    local guildShop = self.m_guildShopTable[itemType] or {};
    local guild_shop_cfg = getConfig(game_config_field.guild_shop);
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = #guildShop;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_guild_conversion_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,1,1)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(1),"luaCCBNode")
            local m_top_label = ccbNode:labelTTFForName("m_top_label")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_bottom_label = ccbNode:labelTTFForName("m_bottom_label")
            m_icon_node:removeAllChildrenWithCleanup(true)

            local itemData = guild_shop_cfg:getNodeWithKey(guildShop[index+1]);
            if itemData then
                local item_id = itemData:getNodeWithKey("item_id"):toStr();
                if itemType == 1 then--卡牌
                    local itemCfg = getConfig(game_config_field.character_detail):getNodeWithKey(item_id);
                    if itemCfg then
                        m_icon_node:addChild(game_util:createIconByName(itemCfg:getNodeWithKey("img"):toStr()));
                        m_top_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                    end
                elseif itemType == 2 then--装备
                    local itemCfg = getConfig(game_config_field.equip):getNodeWithKey(item_id);
                    if itemCfg then
                        m_icon_node:addChild(game_util:createEquipIcon(itemCfg));
                        m_top_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                    end
                elseif itemType == 3 then--道具
                    m_top_label:setString(string_helper.game_guild_conversion.prop);
                end
                m_bottom_label:setString(string_helper.game_guild_conversion.intergral .. itemData:getNodeWithKey("need_point"):toStr());
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = guild_shop_cfg:getNodeWithKey(guildShop[index+1]);
            if itemData then
                local item_id = itemData:getNodeWithKey("item_id"):toStr();
                self.m_selItemId = guildShop[index+1];
                if itemType == 1 then--卡牌
                    local itemCfg = getConfig(game_config_field.character_detail):getNodeWithKey(item_id);
                    if itemCfg then
                        self.m_intro_label:setString(itemCfg:getNodeWithKey("story"):toStr());
                    end
                elseif itemType == 2 then--装备
                    local itemCfg = getConfig(game_config_field.equip):getNodeWithKey(item_id);
                    if itemCfg then
                        self.m_intro_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                    end
                elseif itemType == 3 then--道具

                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_guild_conversion.refreshTableView(self,itemType)
    self.m_selType = itemType;
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize(),itemType);
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_intro_label:setString("");
    self.m_selItemId = nil;
end

--[[--
    刷新ui
]]
function game_guild_conversion.refreshUi(self)
    if self.m_selType and self.m_typeBtnTab[self.m_selType] then
        self.m_typeBtnTab[self.m_selType]:setEnabled(false)
        self.m_typeBtnTab[self.m_selType]:setSelected(true)
    end
    self:refreshTableView(self.m_selType);
    local tGameData = game_data:getSelGuildData();
    local guild = tGameData.guild;
    self.m_integration_label:setString(guild.score);
end
--[[--
    初始化
]]
function game_guild_conversion.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_guildShopTable = {{},{},{}};
    local guild_shop_cfg = getConfig(game_config_field.guild_shop);
    local guild_shop_cfg_count = guild_shop_cfg:getNodeCount();
    local itemDataCfg = nil;
    local itemType = nil;
    for i=1,guild_shop_cfg_count do
        itemDataCfg = guild_shop_cfg:getNodeAt(i-1);
        itemType = itemDataCfg:getNodeWithKey("type"):toInt();
        table.insert(self.m_guildShopTable[itemType],itemDataCfg:getKey());
    end
    self.m_selType = 1;
    self.m_typeBtnTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_conversion.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_conversion;