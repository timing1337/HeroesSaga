---  中立城市地图

local game_neutral_city_map = {
    m_tiledW = nil,                     -- 小块的像素宽
    m_tiledH = nil,                     -- 小块的像素高
    m_mapSize = nil,
    m_realMapSize = nil,                -- 城市矩形size
    m_realMapSizeStartPos = nil,
    m_realMapSizeEndPos = nil,
    m_mapLayer = nil,
    m_tiledMap = nil,                   -- 地表层
    m_buildingNatchNode = nil,          -- 建筑层
    m_fogNatchNode = nil,               -- 建筑迷雾
    m_fogBatchNodeForTiled = nil,       -- 地表迷雾
    m_buildingTable = nil,
    m_mapScale = 1.0,
    m_visibleSize = nil,
    m_landItemCountX = nil,             -- 地图大格子宽（4＊4）
    m_landItemCountY = nil,             -- 地图大格子高
    m_selBuildingId = nil,
    m_selCityId = nil,
    m_recoverBuildingId = nil;
    m_touchRef = nil;
    m_buildingClickFlag = nil,
    m_tempMapPostion = nil,
    m_landItemTab = nil,
    m_battle_point = nil,
    m_name_label = nil,
    m_time_label = nil,
    m_reward_node_1 = nil,
    m_reward_label_1 = nil,
    m_reward_node_2 = nil,
    m_reward_label_2 = nil,
    m_enterTime = nil,
    m_no_reward_label = nil,
    public_city_rate = nil,
    time_laebel = nil,
    public_city_update_left = nil,
    dominate_fail = nil,
};

local building_offset = require("building_offset");

--[[--
    销毁
]]
function game_neutral_city_map.destroy(self)
    cclog("-----------------game_neutral_city_map destroy-----------------");
    self.m_tiledW = nil;
    self.m_tiledH = nil;
    self.m_mapSize = nil;
    self.m_realMapSize = nil;
    self.m_realMapSizeStartPos = nil;
    self.m_realMapSizeEndPos = nil;
    self.m_mapLayer = nil;
    self.m_tiledMap = nil;
    self.m_buildingNatchNode = nil;
    self.m_buildingTable = nil;
    self.m_mapScale = 1.0;
    self.m_visibleSize = nil;
    self.m_landItemCountX = nil;
    self.m_landItemCountY = nil;
    self.m_selBuildingId = nil;
    self.m_selCityId = nil;
    self.m_recoverBuildingId = nil;
    self.m_touchRef = nil;
    self.m_buildingClickFlag = nil;
    self.m_landItemTab = nil;

    self.m_battle_point = nil;
    self.m_name_label = nil;
    self.m_time_label = nil;
    self.m_reward_node_1 = nil;
    self.m_reward_label_1 = nil;
    self.m_reward_node_2 = nil;
    self.m_reward_label_2 = nil;
    self.m_enterTime = nil;
    self.m_no_reward_label = nil;
    self.public_city_rate = nil;
    self.time_laebel = nil;
    self.public_city_update_left = nil;
    self.dominate_fail = nil;
end

--[[--
    返回
]]
function game_neutral_city_map.back(self,type)
    -- local function endCallFunc()
    --     self.m_tempMapPostion = nil;
    --     self:destroy();
    -- end
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    --返回到列表
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_neutral_map",{gameData = gameData});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_index"), http_request_method.GET, nil,"public_city_index")
end

--[[--
    初始化地图
]]
function game_neutral_city_map.initMap(self)
    local smallItemCount = 4;
    -- body
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    self.m_landItemCountX = 0;          -- 4*4大格子宽
    self.m_landItemCountY = 0;          -- 4*4大格子高
    local tempGameData = game_data:getSelNeutralCityData();
    local landData = tempGameData["map"];
    self.m_landItemCountY = #landData
    local landDataXCount = nil;
    local landDataX = nil;
    local landItem = nil;
    local mapItem = nil;
    local buildingId = nil;
    local buildingIconName = nil;
    local tempItemTypeName = nil;
    local is_head,j,c_id = nil;
    math.randomseed(os.time());
    local map_title_detail = getConfig(game_config_field.map_title_detail);
    local map_title_detail_item = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("roadblock.plist");
    for i=1,self.m_landItemCountY do
        landDataX = landData[i]
        landDataXCount = game_util:getTableLen(landDataX);
        self.m_landItemCountX = math.max(landDataXCount,self.m_landItemCountX);
        for k,landItem in pairs(landDataX) do
            i = landItem.y;
            j = landItem.x;
            -- cclog(" i =================" .. i .. " ; j ==============" .. j);
            mapItem = earthLayer:tileAt(ccp((j)*smallItemCount,(i)*smallItemCount));
            --[1表示拥有/0表示可见/-1表示迷雾,建筑id,建筑图片id,是否为建筑占地的第一格]
            buildingId = tonumber(landItem["id"])
            tempItemTypeName = landItem["type"]
            is_head = landItem["is_head"]
            c_id = tonumber(landItem["c_id"])
            if c_id < 0 then
                buildingId = - buildingId;
                c_id = - c_id;
            end
            -- cclog("buildingId ====================" .. tostring(buildingId) .. " ; tempItemTypeName ==" .. tempItemTypeName .. " ; is_head ==" .. is_head);
            buildingIconName = nil;
            if is_head == 0 then
                if tempItemTypeName == "mine" then
                    buildingIconName = getConfig(game_config_field.middle_building_mine):getNodeWithKey(tostring(c_id)):getNodeWithKey("image"):toStr();
                elseif tempItemTypeName == "resource" then
                    buildingIconName = getConfig(game_config_field.middle_building_mine):getNodeWithKey(tostring(c_id)):getNodeWithKey("img"):toStr();
                end
                if mapItem ~= nil and buildingIconName ~= nil then
                    self:createBuilding(earthLayer,ccp((j)*smallItemCount,(i)*smallItemCount),buildingIconName,landItem,buildingId);
                end
            end
        end
    end

    cclog("self.m_landItemCountX ===" .. self.m_landItemCountX .. " ; self.m_landItemCountY = " .. self.m_landItemCountY);
    local value = self.m_landItemCountX*smallItemCount + self.m_landItemCountY*smallItemCount;
    self.m_realMapSize = CCSizeMake(value*self.m_tiledW*0.5,value*self.m_tiledH*0.5);
    cclog("self.m_realMapSize width = " .. self.m_realMapSize.width .. " height = " .. self.m_realMapSize.height);

    -- self.m_realMapSizeEndPos = ccp((-self.m_mapSize.width*0.5 - self.m_tiledW*0.5*value*0.5) * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    cclog("self.m_realMapSizeEndPos  x==" .. self.m_realMapSizeEndPos.x .. " ; y ==" .. self.m_realMapSizeEndPos.y);
    -- self.m_realMapSizeStartPos = ccp((self.m_realMapSizeEndPos.x + self.m_realMapSize.width) * self.m_mapScale,(self.m_realMapSizeEndPos.y + self.m_realMapSize.height) * self.m_mapScale);
    cclog("self.m_realMapSizeStartPos  x==" .. self.m_realMapSizeStartPos.x .. " ; y ==" .. self.m_realMapSizeStartPos.y);
    cclog("self.m_visibleSize  width==" .. self.m_visibleSize.width .. " ; height ==" .. self.m_visibleSize.height);
    -- self.m_mapLayer:setPosition(ccp(self.m_realMapSizeStartPos.x - self.m_realMapSize.width*0.5,self.m_realMapSizeStartPos.y));
    if self.m_tempMapPostion then
        self.m_mapLayer:setPosition(self.m_tempMapPostion);
    end
end

--[[--
    创建建筑的方法
]]
function game_neutral_city_map.createBuilding(self,earthLayer,pos,buildingIconName,landItem,buildingId)
    if earthLayer == nil or self.m_buildingNatchNode == nil then return end;
    local mapItem = earthLayer:tileAt(pos);
    if mapItem then
        local tempName = nil;
        local tempBuildingIconName = buildingIconName;
        local firstValue,_ = string.find(buildingIconName,".swf.sam");
        local building_icon = nil;              -- 建筑图标
        local buildsize = nil;                  -- 建筑尺寸
        if firstValue then
            buildingIconName = string.sub(buildingIconName,0,firstValue-1);
            building_icon = game_util:createImpactAnim(buildingIconName,1.0)
        else
            local firstValue,_ = string.find(buildingIconName,".png");
            if firstValue then
                buildingIconName = string.sub(buildingIconName,0,firstValue-1);
            end
            tempName = "building_img/" .. buildingIconName .. ".png";
            building_icon = CCSprite:create(tempName);
        end
        if building_icon == nil then return end
        buildsize = building_icon:getContentSize();
        building_icon:ignoreAnchorPointForPosition(true);
        -- building_icon:setAnchorPoint(ccp(0.5,0));
        self.m_landItemTab[buildingId] = landItem
        local buiding_pos = earthLayer:positionAt(pos);
        -- cclog("buildingIconName ====================" .. buildingIconName);
        local offset = building_offset[buildingIconName];
        if offset ~= nil then
            building_icon:setPosition(ccp(buiding_pos.x + self.m_tiledW*0.5  - offset[1]/2,buiding_pos.y - self.m_tiledH - offset[2]/2));
        else
            building_icon:setPosition(ccp(buiding_pos.x - self.m_tiledW*1,buiding_pos.y - self.m_tiledH*2.5));
        end
        self.m_buildingNatchNode:addChild(building_icon,-building_icon:getPositionY(),buildingId);
        if not firstValue then
            self.m_buildingTable[pos.x .. "-" .. pos.y] = {building_icon=building_icon,fileName = tempName};
        end
        if buildingId < 0 then
            building_icon:setColor(ccc3(155,155,155));
        end
        local buildsize = building_icon:getContentSize();
        local owner = landItem.owner or {};
        local own_time = landItem.own_time;
        local tempNode = CCNode:create();
        tempNode:setContentSize(buildsize);
        local tempTime = own_time - (os.time() - self.m_enterTime)
        if #owner > 0 and tempTime > 0 then
            local owner_info_item = landItem.owner_info[owner[1]];
            if owner_info_item then
                local tempBg = CCSprite:createWithSpriteFrameName("public_hengtiao.png")
                tempBg:setPosition(ccp(buildsize.width/2 + 20,buildsize.height/2+40));
                tempNode:addChild(tempBg)

                local tempBg = CCSprite:createWithSpriteFrameName("public_hengtiao.png")
                tempBg:setPosition(ccp(buildsize.width/2 + 20,buildsize.height/2+20));
                tempNode:addChild(tempBg)

                local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_hengtiao.png")
                tempBg:setPosition(ccp(buildsize.width/2 + 20,buildsize.height/2));
                tempNode:addChild(tempBg)

                -- local tempLabel = game_util:createLabelTTF({text = owner_info_item.name,color = ccc3(250,180,0),fontSize = 16});
                -- tempLabel:setPosition(ccp(buildsize.width/2,buildsize.height/2+20));
                -- tempNode:addChild(tempLabel);
                local tempIcon = game_util:createPlayerIconByRoleId(owner_info_item.role)
                -- cclog("tempIcon ===================== " .. tostring(tempIcon))
                if tempIcon then
                    local player_icon_bg = CCSprite:createWithSpriteFrameName("public_faguang.png");
                    local player_icon_bg_size = player_icon_bg:getContentSize();
                    tempIcon:setPosition(ccp(player_icon_bg_size.width*0.5,player_icon_bg_size.height*0.5))
                    player_icon_bg:addChild(tempIcon,-1,10)
                    player_icon_bg:setPosition(ccp(buildsize.width/2 - 40,buildsize.height/2+20));
                    tempNode:addChild(player_icon_bg);
                end
                local function timeEndFunc(label,type)
                    label:getParent():removeFromParentAndCleanup(true);
                end

                --加战斗力的条子
                local combatBackIcon = CCScale9Sprite:createWithSpriteFrameName("zldt_combat_back.png")
                combatBackIcon:setPreferredSize(CCSizeMake(150, 17));
                combatBackIcon:setPosition(ccp(buildsize.width/2,buildsize.height/2-15));
                tempNode:addChild(combatBackIcon)

                local combatIcon = CCSprite:createWithSpriteFrameName("zldt_combat_label.png")
                combatIcon:setPosition(ccp(buildsize.width/2-40,buildsize.height/2-15));
                tempNode:addChild(combatIcon)

                --战斗力
                local combatValue = owner_info_item.combat or 0
                local combat = game_util:createLabelBMFont({fnt = "yellow_image_text.fnt",text = combatValue})
                combat:setScale(0.9)
                combat:setPosition(ccp(buildsize.width/2 + 24,buildsize.height/2-15));
                tempNode:addChild(combat)

                local countdownLabel = game_util:createCountdownLabel(tempTime,timeEndFunc,8);
                countdownLabel:setColor(ccc3(255,255,0))
                countdownLabel:setPosition(ccp(buildsize.width/2 + 25,buildsize.height/2+40));
                tempNode:addChild(countdownLabel)

                local nameLabel = game_util:createLabelTTF({text = owner_info_item.name,color = ccc3(250,180,0),fontSize = 12});
                nameLabel:setPosition(ccp(buildsize.width/2 + 25,buildsize.height/2+20));
                tempNode:addChild(nameLabel)

                local nameLabel = game_util:createLabelTTF({text = owner_info_item.association_name,color = ccc3(250,180,0),fontSize = 12});
                nameLabel:setPosition(ccp(buildsize.width/2 + 25,buildsize.height/2));
                tempNode:addChild(nameLabel)
            end
            building_icon:addChild(tempNode);
        end
    end
end

--[[--
    重置地图的位置
]]
function game_neutral_city_map.resetMapPosition(self,cx,cy)
    -- --判断边界
    -- if self.m_visibleSize.width > self.m_realMapSize.width * self.m_mapScale then
    --     if cx < (self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5) then
    --         cx = self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5;
    --     end
    --     if cx > self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5 then
    --         cx = self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5;
    --     end
    -- else
    --     if cx < (self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5) then
    --         cx = self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5;
    --     end
    --     if cx > self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0.5 then
    --         cx = self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0.5;
    --     end
    -- end
    -- if self.m_visibleSize.height > self.m_realMapSize.height * self.m_mapScale then
    --     if cy < (self.m_realMapSizeEndPos.y + self.m_realMapSize.height* self.m_mapScale - self.m_visibleSize.height*0.5) then
    --         cy = self.m_realMapSizeEndPos.y + self.m_realMapSize.height* self.m_mapScale - self.m_visibleSize.height*0.5;
    --     end
    --     if cy > self.m_realMapSizeEndPos.y + self.m_visibleSize.height then
    --         cy = self.m_realMapSizeEndPos.y + self.m_visibleSize.height;
    --     end
    -- else
    --     if cy < (self.m_realMapSizeEndPos.y + self.m_visibleSize.height*0.5) then
    --         cy = self.m_realMapSizeEndPos.y + self.m_visibleSize.height*0.5;
    --     end
    --     if cy > self.m_realMapSizeStartPos.y then
    --         cy = self.m_realMapSizeStartPos.y;
    --     end
    -- end
    -- self.m_tempMapPostion = ccp(cx,cy)
    -- self.m_mapLayer:setPosition(self.m_tempMapPostion);

    if self.m_visibleSize.width > self.m_realMapSize.width * self.m_mapScale then
        if cx < (self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5) then
            cx = self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5;
        end
        if cx > self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5 then
            cx = self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5;
        end
    else
        if cx < (self.m_realMapSizeEndPos.x + self.m_visibleSize.width + self.m_tiledW*4) then
            cx = self.m_realMapSizeEndPos.x + self.m_visibleSize.width + self.m_tiledW*4;
        end
        if cx > self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0 - self.m_tiledW*2 then
            cx = self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0 - self.m_tiledW*2
        end
    end
    if self.m_visibleSize.height > self.m_realMapSize.height * self.m_mapScale then
        if cy < (self.m_realMapSizeEndPos.y + self.m_realMapSize.height* self.m_mapScale - self.m_visibleSize.height*0.5) then
            cy = self.m_realMapSizeEndPos.y + self.m_realMapSize.height* self.m_mapScale - self.m_visibleSize.height*0.5;
        end
        if cy > self.m_realMapSizeEndPos.y + self.m_visibleSize.height then
            cy = self.m_realMapSizeEndPos.y + self.m_visibleSize.height;
        end
    else
        if cy < (self.m_realMapSizeEndPos.y + self.m_visibleSize.height) then
            cy = self.m_realMapSizeEndPos.y + self.m_visibleSize.height;
        end
        if cy > self.m_realMapSizeStartPos.y then
            cy = self.m_realMapSizeStartPos.y;
        end
    end
    self.m_tempMapPostion = ccp(cx,cy)
    self.m_mapLayer:setPosition(self.m_tempMapPostion);
end

--[[--
    读取ccbi创建ui
]]
function game_neutral_city_map.createUi(self)
    -- body
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("building_icon.plist");
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 2 then --宝箱 
            --宝箱 city=
        elseif btnTag == 3 then --探索
            --攻击接口 city_id=10001&building_id=1001
            local function responseMethod(tag,gameData)
                if gameData:getNodeWithKey("data"):getNodeWithKey("battle"):getNodeWithKey("no_fight"):toInt() == 1 then return end
                game_data:setSelNeutralBuildingId(self.m_selBuildingId);
                game_data:setBattleType("game_neutral_city_map");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local params = {};
            params.city_id = self.m_selCityId;
            params.building_id = self.m_selBuildingId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_attack"), http_request_method.GET, params,"public_city_attack")
        elseif btnTag == 4 then --返回基地
            self:back();
        elseif btnTag == 11 then --撤退
            self:back();
        elseif btnTag == 12 then --背包
            game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "game_neutral_city_map",showIndex= 1});
            self:destroy();
        elseif btnTag == 13 then --队伍
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_neutral_city_map"});
            self:destroy();
        elseif btnTag == 100 then--装备
            game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_neutral_city_map",showIndex= 1});
            self:destroy();
        elseif btnTag == 201 then--战报
            local function responseMethod(tag,gameData)
                game_data:setSelNeutralBuildingId(self.m_selBuildingId);
                local data = gameData:getNodeWithKey("data")
                local rob_log = json.decode(data:getNodeWithKey("rob_log"):getFormatBuffer())
                game_scene:addPop("ui_batter_info_pop",{log_info = rob_log,openType = 3});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_rob_log"), http_request_method.GET, nil,"public_city_rob_log")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_neutral_city_map.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.m_battle_point = ccbNode:labelTTFForName("m_battle_point");
    self.m_name_label = ccbNode:labelTTFForName("m_name_label");
    self.m_time_label = ccbNode:labelTTFForName("m_time_label");
    self.m_reward_node_1 = ccbNode:spriteForName("m_reward_node_1");
    self.m_reward_label_1 = ccbNode:labelTTFForName("m_reward_label_1");
    self.m_reward_node_2 = ccbNode:spriteForName("m_reward_node_2");
    self.m_reward_label_2 = ccbNode:labelTTFForName("m_reward_label_2");
    self.m_no_reward_label = ccbNode:labelTTFForName("m_no_reward_label");

    self.m_no_reward_label:setString( string_helper.game_neutral_city_map.wu)

    self.time_laebel = ccbNode:nodeForName("time_laebel")

    local testLayer = CCLayer:create();
    root_map_node:addChild(testLayer);

    local middle_map = getConfig(game_config_field.middle_map);
    local itemItemCfg = middle_map:getNodeWithKey(self.m_selCityId)
    local earth_name = itemItemCfg:getNodeWithKey("earth_name"):toStr();
    cclog("earth_name ============================" .. tostring(earth_name))
    if earth_name and earth_name ~= "" then
        self.m_tiledMap = CCTMXTiledMap:create("building_img/" .. earth_name .. ".tmx")
    else
        self.m_tiledMap = CCTMXTiledMap:create("building_img/testTiledMap.tmx")
    end
    if self.m_tiledMap == nil then
        game_util:addMoveTips({text = string.format(string_helper.game_neutral_city_map.text,tostring(earth_name))});
        return ccbNode;
    end
    local scaleFactor = display.contentScaleFactor;
    -- cclog("getMapSize width  = " .. self.m_tiledMap:getMapSize().width .. " ; height = " .. self.m_tiledMap:getMapSize().height);
    -- cclog("getTileSize width  = " .. self.m_tiledMap:getTileSize().width .. " ; height = " .. self.m_tiledMap:getTileSize().height);
    self.m_tiledW = self.m_tiledMap:getTileSize().width/scaleFactor;
    self.m_tiledH = self.m_tiledMap:getTileSize().height/scaleFactor;
    cclog("self.m_tiledW = " .. self.m_tiledW .. " ; self.m_tiledH = " .. self.m_tiledH );
    self.m_mapSize = CCSizeMake(self.m_tiledMap:getMapSize().width*self.m_tiledW,self.m_tiledMap:getMapSize().height*self.m_tiledH);
    -- self.m_realMapSizeStartPos = ccp(0,0);
    -- self.m_realMapSizeEndPos = ccp(- self.m_mapSize.width * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    self.m_realMapSizeStartPos = ccp(- self.m_mapSize.width * self.m_mapScale*0.25,- self.m_mapSize.height * self.m_mapScale*0.25);
    self.m_realMapSizeEndPos = ccp(- self.m_mapSize.width * self.m_mapScale*0.75,- self.m_mapSize.height * self.m_mapScale*0.75);
    cclog("self.m_mapSize width = " .. self.m_mapSize.width .. "; height = " .. self.m_mapSize.height);
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    
    self.m_visibleSize = CCDirector:sharedDirector():getVisibleSize();
    self.m_mapLayer = CCLayerColor:create(ccc4(0,0,0,255),self.m_mapSize.width,self.m_mapSize.height*2);
    self.m_mapLayer:ignoreAnchorPointForPosition(false);
    self.m_mapLayer:setAnchorPoint(ccp(0,0));
    testLayer:addChild(self.m_mapLayer);
    -- self.m_mapLayer:setPosition(- self.m_mapSize.width*0.5 * self.m_mapScale + self.m_visibleSize.width - self.m_tiledW *0.5 , - self.m_mapSize.height * self.m_mapScale + self.m_visibleSize.height);
    self.m_mapLayer:setPosition(- self.m_mapSize.width*0.5 * self.m_mapScale + self.m_visibleSize.width*0.5, - self.m_mapSize.height * self.m_mapScale*0.5 + self.m_visibleSize.height*0.5);
    -- self.m_mapLayer:setPosition(0,0);
    cclog("self.m_mapLayer init pos x = " .. (- self.m_mapSize.width*0.5 + self.m_visibleSize.width*0.5) .. " ; y = " .. - self.m_mapSize.height + self.m_visibleSize.height);
    self.m_mapLayer:addChild(self.m_tiledMap);

    -- 地表迷雾
    self.m_fogBatchNodeForTiled = CCSpriteBatchNode:create("fog.png");
    self.m_mapLayer:addChild(self.m_fogBatchNodeForTiled);


    self.m_buildingNatchNode = CCNode:create()--CCSpriteBatchNode:create("building_icon-hd.pvr.ccz")
    self.m_mapLayer:addChild(self.m_buildingNatchNode)

    -- 建筑迷雾
    self.m_fogNatchNode = CCSpriteBatchNode:create("fog.png");
    self.m_mapLayer:addChild(self.m_fogNatchNode);

    self.m_mapLayer:setScale(self.m_mapScale);


    -- handing touch events
    local touchBeginPoint = nil
    local touchPoint = nil
    local function onTouchBegan(x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        return true
    end

    local function onTouchMoved(x, y)
        if touchPoint then
            local start_cx, start_cy = self.m_mapLayer:getPosition();
            local cx , cy = start_cx + x - touchPoint.x,start_cy + y - touchPoint.y;
            self:resetMapPosition(cx,cy);
            touchPoint = {x = x, y = y}
        end
    end

    local function onTouchEnded(x, y)
        if touchBeginPoint == nil then return end
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) < 5 and self.m_buildingClickFlag == false then
            local cx,cy = self.m_mapLayer:getPosition();
            local selectBuilding = nil;
            local alpha = -1;
            local tempBuilding = nil;
            for k,v in pairs(self.m_buildingTable) do
                tempBuilding = v.building_icon;
                if tempBuilding:boundingBox():containsPoint(ccp(x - cx,y - cy)) then
                    if tempBuilding:getTag() > 0 then
                        if v.fileName then
                            local tempPos = tempBuilding:convertToNodeSpace(ccp(x,y));
                            local tempSize = tempBuilding:getContentSize();
                            alpha = getImageAlphaByFileNameAndPoint(v.fileName,ccp(tempPos.x*display.contentScaleFactor,(tempSize.height - tempPos.y)*display.contentScaleFactor))
                            cclog("alpha ====================" .. tostring(alpha) .. "display.contentScaleFactor ==" .. display.contentScaleFactor)
                        end
                        if alpha ~= 0 then
                            if selectBuilding == nil then
                                selectBuilding = tempBuilding;
                            else
                                if tempBuilding:getZOrder() > selectBuilding:getZOrder() then
                                    selectBuilding = tempBuilding;
                                end
                            end
                            cclog(" k ++++++++++++++++++++++++++ " .. k)
                        end
                    end
                end
            end
            if selectBuilding ~= nil then
                local buildingId = selectBuilding:getTag()
                local itemData = self.m_landItemTab[buildingId]
                if itemData and buildingId > 0 and self.m_buildingClickFlag == false then
                    self.m_buildingClickFlag = true;
                    game_util:spriteOnClickAnim({
                    tempSpr = selectBuilding,
                    listener =  function()
                        -- cclog("building onclick --------buildingId =" .. tostring(buildingId));
                        self:buildingOnClickRequestInfo(itemData,selectBuilding);
                        -- self.m_buildingClickFlag = false;
                    end,
                    });
                end
            end
        end
        touchBeginPoint = nil
        touchPoint = nil
    end
    
    local distance = nil;
    local function onScale(touches)
        if table.getn(touches) == 6 then
            local dis = ccpDistance(ccp(touches[1],touches[2]),ccp(touches[4],touches[5]));
            if distance == nil then 
                distance = dis; 
                return;
            end
            if dis > distance then
                self.m_mapScale = self.m_mapScale + 0.005;
            elseif dis < distance then
                self.m_mapScale = self.m_mapScale - 0.005;
            end
            if self.m_mapScale < 0.3 then
                self.m_mapScale = 0.3
            elseif self.m_mapScale > 1.0 then
                self.m_mapScale = 1.0
            end

            -- cclog("onScale ---------------- dis = " .. dis .. ";self.m_mapScale = " .. self.m_mapScale);
            self.m_mapLayer:setScale(self.m_mapScale);
            local cx,cy = self.m_mapLayer:getPosition();
            self:resetMapPosition(cx,cy);
            distance = dis;
        end
    end
    local function onTouch(eventType, x, y)
        -- cclog("began ---------------------------------" .. self.m_touchRef .. "; eventType = " .. eventType);
        if eventType == "began" then
            self.m_touchRef = self.m_touchRef + 1;
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            self.m_touchRef = self.m_touchRef - 1;
            return onTouchEnded(x, y)
        end
    end
    -- local multiTouchCount = 0;
    -- local function onTouch(eventType, touches)
    --     cclog("eventType ======================" .. eventType);
    --     if eventType == "began" then
    --         cclog("began multiTouchCount--1---" .. tostring(multiTouchCount));
    --         multiTouchCount = multiTouchCount + table.getn(touches) / 3;
    --         cclog("began multiTouchCount--2---" .. tostring(multiTouchCount));
    --         if multiTouchCount == 1 then
    --             -- for k,v in pairs(touches) do
    --             --     cclog("touches k = " .. tostring(k) .. " ; v = " .. tostring(v));
    --             -- end
    --             return onTouchBegan(touches[1], touches[2])
    --         elseif multiTouchCount == 2 then
    --             distance = nil;
    --         end
    --     elseif eventType == "moved" then
    --         if multiTouchCount == 1 then
    --             cclog("moved = " .. tostring(touches));
    --             return onTouchMoved(touches[1], touches[2])
    --         elseif multiTouchCount == 2 then
    --             cclog("table.getn(touches) = " .. table.getn(touches));
    --             -- return onScale(touches);
    --         end
    --     else
    --         if multiTouchCount == 1 then
    --             cclog("onTouchEnded = " .. tostring(touches));
    --             multiTouchCount = multiTouchCount - table.getn(touches) / 3;
    --             return onTouchEnded(touches[1], touches[2])
    --         end
    --         multiTouchCount = multiTouchCount - table.getn(touches) / 3;
    --     end
    -- end
    --被夺弹板
    if self.dominate_fail then
        if game_util:getTableLen(self.dominate_fail) > 0 then
            local function callFunc()--复仇
               local function responseMethod(tag,gameData)
                game_scene:removePopByName("game_neutral_result_pop");    
                if gameData:getNodeWithKey("data"):getNodeWithKey("battle"):getNodeWithKey("no_fight"):toInt() == 1 then return end
                    game_data:setSelNeutralBuildingId(self.m_selBuildingId);
                    game_data:setBattleType("game_neutral_city_map");
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                    self:destroy();
                end
                local params = {};
                params.city_id = self.dominate_fail.city;
                params.building_id = self.dominate_fail.building;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_attack"), http_request_method.GET, params,"public_city_attack")
            end
            game_scene:addPop("game_neutral_result_pop",{callFunc = callFunc,building = self.dominate_fail.building,city = self.dominate_fail.city,name = self.dominate_fail.name,content = self.dominate_fail.content})
        end
    end
    testLayer:registerScriptTouchHandler(onTouch,false,1,true)--多点触摸
    testLayer:setTouchEnabled(true)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text192)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text193)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text194)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text195)
    return ccbNode;
end

--[[--
    创建云层
]]
function game_neutral_city_map.createCloudLayer( self )
    -- body
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("da_yun.plist");
    local cloudLayer = CCLayer:create();        -- 云层
    local tempItem = 0;
    local tempx = 0;
    local tempy = 0;
    local tempsprite = nil;
    local smallItemCount = 4;
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    local function create_action( x,y )
        -- body
        local rd = math.random(50);
        local action =  CCRepeat:create(CCSequence:createWithTwoActions(CCMoveTo:create(3+rd,ccp(x+rd,y+rd)),CCMoveTo:create(3+rd,ccp(x,y))),30+rd);
        return action;
    end
    -- local i=1
    for i=1,self.m_landItemCountY do
        tempItem = earthLayer:tileAt(ccp(0,(i-1)*smallItemCount+2));
        if tempItem ~= nil then
        tempx,tempy = tempItem:getPosition();
        tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
        tempsprite:runAction(create_action(tempx,tempy));
        tempsprite:setPosition(ccp(tempx,tempy));
        cloudLayer:addChild(tempsprite);
        tempItem = earthLayer:tileAt(ccp(self.m_landItemCountX*smallItemCount-1,(i-1)*smallItemCount+2));
        if tempItem ~= nil then
        tempx,tempy = tempItem:getPosition();
        tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
        tempsprite:setFlipX(true);
        tempsprite:setFlipY(true);
        tempsprite:runAction(create_action(tempx,tempy));
        tempsprite:setPosition(ccp(tempx,tempy));
        cloudLayer:addChild(tempsprite);
        end
        end
    end
    for i=1,self.m_landItemCountX do
        tempItem = earthLayer:tileAt(ccp((i-1)*smallItemCount+2,0));
        if tempItem ~= nil then
        tempx,tempy = tempItem:getPosition();
        tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
        tempsprite:runAction(create_action(tempx,tempy));
        tempsprite:setFlipX(true);
        tempsprite:setPosition(ccp(tempx,tempy));
        cloudLayer:addChild(tempsprite);
        tempItem = earthLayer:tileAt(ccp((i-1)*smallItemCount+2,self.m_landItemCountY*smallItemCount-1));
        if tempItem ~= nil then
        tempx,tempy = tempItem:getPosition();
        tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
        tempsprite:runAction(create_action(tempx,tempy));
        tempsprite:setFlipY(true);
        tempsprite:setPosition(ccp(tempx,tempy));
        cloudLayer:addChild(tempsprite);
        end
        end
    end
    self.m_mapLayer:addChild(cloudLayer);
end

--[[--
    
]]
function game_neutral_city_map.buildingOnClickRequestInfo(self,itemData,buildingSpr)
    local tempId = itemData["id"]
    local function responseMethod(tag,gameData)
        self.m_buildingClickFlag = false;
        if gameData then
            local buildingDetailTableData = json.decode(gameData:getNodeWithKey("data"):getNodeWithKey("building"):getFormatBuffer());
            game_scene:addPop("game_neutral_building_detail_pop",{buildingTableData = itemData,buildingDetailTableData = buildingDetailTableData,cityId = self.m_selCityId,buildingId = tempId});
        end
    end
    --建筑信息 city_id=10001&building_id=1001
    local params = {};
    params.city_id = self.m_selCityId;
    params.building_id = tempId;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_building_info"), http_request_method.GET, params,"public_city_building_info",true,true)
end

--[[--
    刷新ui
]]
function game_neutral_city_map.refreshUi(self)
    if self.m_tiledMap == nil then
        return;
    end
    self:initMap();
    self:createCloudLayer();
    local tempGameData = game_data:getSelNeutralCityData();
    -- tempGameData.point = 9
    -- self.public_city_rate = 10
    self.m_battle_point:setString(tostring(tempGameData.point) .. "/" .. tostring(tempGameData.max_point))
    if tempGameData.point < tempGameData.max_point then
        local function timeOverFunc(label,type)
            tempGameData.point = tempGameData.point + 1
            self.m_battle_point:setString(tostring(tempGameData.point) .. "/" .. tostring(tempGameData.max_point))
            label:setTime(3600)
            if tempGameData.point == tempGameData.max_point then
                label:removeFromParentAndCleanup(true)
            end
        end
        local timeOverLabel = game_util:createCountdownLabel(self.public_city_update_left,timeOverFunc,8,2)
        timeOverLabel:setAnchorPoint(ccp(0.5,0.5))
        timeOverLabel:setPosition(ccp(0,0))
        self.time_laebel:addChild(timeOverLabel,10,10)
    else
        local temp = self.time_laebel:getChildByTag(10)
        if temp then
            temp:removeFromParentAndCleanup(true)
        end
    end
    local own_city = tempGameData.own_city;
    local cityName = string_helper.game_neutral_city_map.wu

    local expire = own_city.expire
    local tempTime = expire - (os.time() - self.m_enterTime) 
    if tempTime > 0 then
        local function timeEndFunc(label,type)
            self.m_name_label:setString(string_helper.game_neutral_city_map.wu);
        end
        local countdownLabel = game_util:createCountdownLabel(tempTime,timeEndFunc,8);
        countdownLabel:setColor(ccc3(255,255,0))
        local pX,pY = self.m_time_label:getPosition();
        countdownLabel:setPosition(ccp(pX,pY));
        countdownLabel:setAnchorPoint(ccp(1, 0.5));
        self.m_time_label:getParent():addChild(countdownLabel)
        self.m_time_label:setVisible(false);

        local landItem = self.m_landItemTab[tonumber(own_city.own_building)] or {}
        local buildingCid = landItem.c_id;
        cclog("own_city.own_building===== " .. tostring(own_city.own_building) .. " ; buildingCid = " .. tostring(buildingCid))
        local middle_building_mine = getConfig(game_config_field.middle_building_mine)
        local buildingCfgData = middle_building_mine:getNodeWithKey(tostring(buildingCid));
        if buildingCfgData then
            self.m_no_reward_label:setVisible(false);
            cityName = buildingCfgData:getNodeWithKey("name"):toStr();
            local typeName = buildingCfgData:getNodeWithKey("type"):toStr();
            cclog("typeName ======================== " .. typeName)
            if typeName == "mine" then
                local reward_base = buildingCfgData:getNodeWithKey("reward_base")
                local awardCount = reward_base:getNodeCount();
                local posIndex = 1;
                if awardCount > 0 then
                    local m_award_node = self["m_reward_node_" .. posIndex]
                    local m_award_label = self["m_reward_label_" .. posIndex]
                    m_award_node:removeAllChildrenWithCleanup(true);
                    local icon,name = game_util:getRewardByItem(reward_base:getNodeAt(0),true);
                    if icon then
                        icon:setScale(0.3)
                        m_award_node:addChild(icon)
                    end
                    if name then
                        m_award_label:setString(name)
                    end
                    posIndex = posIndex + 1;
                end
                local reward_item = buildingCfgData:getNodeWithKey("reward_item")
                local awardCount = reward_item:getNodeCount();
                if awardCount > 0 then
                    local m_award_node = self["m_reward_node_" .. posIndex]
                    local m_award_label = self["m_reward_label_" .. posIndex]
                    m_award_node:removeAllChildrenWithCleanup(true);
                    local icon,name = game_util:getRewardByItem(reward_item:getNodeAt(0),true);
                    if icon then
                        icon:setScale(0.3)
                        m_award_node:addChild(icon)
                    end
                    if name then
                        m_award_label:setString(name)
                    end
                    posIndex = posIndex + 1;
                end
            elseif typeName == "resource" then
                local reward = buildingCfgData:getNodeWithKey("reward")
                local awardCount = reward:getNodeCount();
                for i=1,2 do
                    local m_award_node = self["m_reward_node_" .. i]
                    local m_award_label = self["m_reward_label_" .. i]
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                        m_award_node:setVisible(false);
                    else
                        local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                        cclog("icon === " .. tostring(icon) .. " name == " .. name);
                        if icon then
                            icon:setScale(0.3)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end                    
                end
            end
        end
    else
        self.m_time_label:setString("00:00:00")
        self.m_time_label:setVisible(true);
    end
    self.m_name_label:setString(cityName);
end
--[[--
    初始化
]]
function game_neutral_city_map.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selCityId = t_params.city_id;
    game_data:setSelNeutralCityId(t_params.city_id);
    self.m_touchRef = 0;
    self.m_recoverBuildingId = t_params.recoverBuildingId;
    self.public_city_rate = t_params.public_city_rate or 3600
    self.public_city_update_left = t_params.public_city_update_left or 3600
    self.m_buildingTable = {};
    self.m_buildingClickFlag = false;
    self.dominate_fail = t_params.dominate_fail
    cclog("self.dominate_fail = " .. json.encode(self.dominate_fail))
    self.m_landItemTab = {};
    -- game_sound:playMusic("background_home",true);
    self.m_enterTime = os.time();
end

--[[--
    创建入口
]]
function game_neutral_city_map.create(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_neutral_map_res.plist");
    -- body
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    if self.m_recoverBuildingId ~= nil then
        require("game_ui.game_pop_up_box").showAlertView(string_helper.game_neutral_city_map.build_sf .. tostring(self.m_recoverBuildingId));
    end
    return rootScene;
end

return game_neutral_city_map;