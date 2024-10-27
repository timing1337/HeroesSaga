---  gvg地图
local game_gvg_map = {
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
    m_cloudBatchNode = nil,             -- 更改后建筑迷雾
    m_cloudLayer = nil,                 -- 外围迷雾
    m_buildingTable = nil,
    m_mapScale = 1.0,
    m_visibleSize = nil,
    m_landItemCountX = nil,             -- 地图大格子宽（4＊4）
    m_landItemCountY = nil,             -- 地图大格子高
    m_selBuildingId = nil,
    m_maskLayer = nil,
    m_mask_node = nil,
    m_selCityId = nil,
    m_recoverBuildingId = nil,
    m_touchRef = nil,
    m_progress_rate_label = nil,
    m_recover_node = nil,
    m_recover_anim_over = nil,
    m_buildingClickFlag = nil,
    m_tempMapPostion = nil,
    m_scroll_view = nil,
    m_playerAnimNode = nil,
    m_guideBuilding = nil,
    m_bgMusic = nil,
    m_moveFlag = nil,
    m_reward = nil,
    m_rate_btn = nil,
    m_rate_anim = nil,
    m_ccbNode = nil,
    m_landItemTab = nil,
    m_autoFlag = nil,
    m_back_btn = nil,
    m_open_building_id = nil,

    m_current_sweep = nil,

    isShowDoSthTips = nil,
    m_conbtn_dosth = nil,
    m_doSthFun = nil,
    showDataTips = nil,
    m_isHard_allRegain = nil,
    m_achieve_btn = nil,
    property_add = nil,

    name_label = nil,
    complete_text = nil,
    life_buff = nil,
    patt_buff = nil,
    matt_buff = nil,
    def_buff = nil,
    speed_buff = nil,
    life_label = nil,
    life_node = nil,
    recover_label = nil,
    percent_label = nil,

    callBackFunc = nil,
    reward = nil,
    tipText = nil,

    m_tGameData = nil,
    property_add = nil,
    treasure = nil,
    city = nil,
    heal_times = nil,
    total_hp = nil,
    alignment = nil,
    die = nil,
    city = nil,
    recapture_log = nil,
    regain_reward = nil,
    total_hp_rate = nil,
    tips_label = nil,
    winType = nil,

    home_left_time = nil,
    home_att_flag = nil,
};

local building_offset = require("building_offset");

local map_info_data = {
    w = 0,
    h = 0,
    data = nil,
}
--[[--
    销毁
]]
function game_gvg_map.destroy(self)
    cclog("-----------------game_gvg_map destroy-----------------");
    self.m_tiledW = nil;
    self.m_tiledH = nil;
    self.m_mapSize = nil;
    self.m_realMapSize = nil;
    self.m_realMapSizeStartPos = nil;
    self.m_realMapSizeEndPos = nil;
    self.m_mapLayer = nil;
    self.m_tiledMap = nil;
    self.m_buildingNatchNode = nil;
    self.m_fogNatchNode = nil;
    self.m_fogBatchNodeForTiled = nil;
    self.m_cloudBatchNode = nil;
    self.m_cloudLayer = nil;
    self.m_buildingTable = nil;
    self.m_mapScale = 1.0;
    self.m_visibleSize = nil;
    self.m_landItemCountX = nil;
    self.m_landItemCountY = nil;
    self.m_selBuildingId = nil;
    self.m_maskLayer = nil;
    self.m_mask_node = nil;
    self.m_selCityId = nil;
    self.m_recoverBuildingId = nil;
    self.m_touchRef = nil;
    self.m_progress_rate_label = nil;
    self.m_recover_node = nil;
    self.m_recover_anim_over = nil;
    self.m_buildingClickFlag = nil;
    -- self.m_tempMapPostion = nil;   ---该值记录位置，不销毁
    self.m_scroll_view = nil;
    self.m_playerAnimNode = nil;
    self.m_guideBuilding = nil;
    self.m_bgMusic = nil;
    self.m_moveFlag = nil;
    self.m_reward = nil;
    self.m_rate_btn = nil;
    self.m_rate_anim = nil;
    self.m_ccbNode = nil;
    self.m_landItemTab = nil;
    self.m_autoFlag = nil;
    self.m_back_btn = nil;
    self.m_open_building_id = nil;
    self.m_current_sweep = nil;
    self.isShowDoSthTips = nil;
    self.m_conbtn_dosth = nil;
    self.m_doSthFun = nil;
    self.showDataTips = nil;
    self.m_isHard_allRegain = nil;
    self.m_achieve_btn = nil;
    self.property_add = nil;

    --🈹--
    self.name_label = nil;
    self.complete_text = nil;
    self.life_buff = nil;
    self.patt_buff = nil;
    self.matt_buff = nil;
    self.def_buff = nil;
    self.speed_buff = nil;
    self.life_label = nil;
    self.life_node = nil;
    self.recover_label = nil;
    self.percent_label = nil;

    self.callBackFunc = nil;
    self.reward = nil;
    self.tipText = nil;

    self.m_tGameData = nil;
    self.property_add = nil;
    self.treasure = nil;
    self.city = nil;
    self.heal_times = nil;
    self.total_hp = nil;
    self.alignment = nil;
    self.die = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.regain_reward = nil;
    self.total_hp_rate = nil;
    self.tips_label = nil;
    self.winType = nil;

    self.home_left_time = nil;
    self.home_att_flag = nil;--是否可以打主家的flag
end
--[[--
    返回
]]
function game_gvg_map.back(self,type)
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        require("like_oo.oo_controlBase"):openView("guild_join");
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_map.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 2 then--详情
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_map_pop",{gameData = gameData,attacker = self.m_tGameData.attacker,defender = self.m_tGameData.defender})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_battle_info"), http_request_method.GET, nil,"guild_gvg_battle_info")
        elseif btnTag == 3 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local sort = data:getNodeWithKey("sort"):toInt()
                if sort == 3 then
                    local doing = data:getNodeWithKey("doing")
                    self.m_tGameData = json.decode(doing:getFormatBuffer()) or {};
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_map.ccbi");
    
    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.m_scroll_view = ccbNode:scrollViewForName("m_scroll_view")
    
    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name") 
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")

    self.bar_node = ccbNode:nodeForName("bar_node")
    self.left_time_node = ccbNode:nodeForName("left_time_node")

    self.att_num = ccbNode:labelTTFForName("att_num")
    self.def_num = ccbNode:labelTTFForName("def_num")

    --阵营
    self.def_camp = ccbNode:spriteForName("def_camp")
    self.att_camp = ccbNode:spriteForName("att_camp")
    --添加地图
    local testLayer = CCLayer:create();
    root_map_node:addChild(testLayer);
    -- local tmx = "map_" .. tostring(self.city) .. ".tmx";--取配置读地图
    local tmx = ""
    cclog(" map_main_story_cfg_item  tmx === " .. tmx);
    if tmx == "" then
        self.m_tiledMap = CCTMXTiledMap:create("building_img/gvg01.tmx")
    else
        self.m_tiledMap = CCTMXTiledMap:create("building_img/" .. tmx .. ".tmx")
    end
    if self.m_tiledMap == nil then
        -- game_util:addMoveTips({text = string.format("地图文件%s未找到！",tostring(tmx))});
        -- return ccbNode;
        --取不到取默认的
        self.m_tiledMap = CCTMXTiledMap:create("building_img/map_10001.tmx")
    end
    local scaleFactor = display.contentScaleFactor;
    self.m_tiledW = self.m_tiledMap:getTileSize().width/scaleFactor;
    self.m_tiledH = self.m_tiledMap:getTileSize().height/scaleFactor;
    self.m_mapSize = CCSizeMake(self.m_tiledMap:getMapSize().width*self.m_tiledW,self.m_tiledMap:getMapSize().height*self.m_tiledH);
    self.m_realMapSizeStartPos = ccp(0,0);
    self.m_realMapSizeEndPos = ccp(- self.m_mapSize.width * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    local earthLayer = self.m_tiledMap:layerNamed("earth");

    self.m_visibleSize = CCDirector:sharedDirector():getVisibleSize();
    self.m_mapLayer = CCLayerColor:create(ccc4(0,0,0,255),self.m_mapSize.width,self.m_mapSize.height*2);
    self.m_mapLayer:ignoreAnchorPointForPosition(false);
    self.m_mapLayer:setAnchorPoint(ccp(0,0));
    testLayer:addChild(self.m_mapLayer);
    self.m_mapLayer:setPosition(- self.m_mapSize.width*0.5 * self.m_mapScale + self.m_visibleSize.width - self.m_tiledW * 0.5 , - self.m_mapSize.height * self.m_mapScale + self.m_visibleSize.height);
    self.m_mapLayer:addChild(self.m_tiledMap);

    -- 地表迷雾
    local tempDic = CCDictionary:createWithContentsOfFile("fog.plist");
    local tempTName = tolua.cast(tempDic:objectForKey("metadata"),"CCDictionary"):valueForKey("realTextureFileName"):getCString();
    self.m_fogBatchNodeForTiled = CCSpriteBatchNode:create(tempTName);
    self.m_mapLayer:addChild(self.m_fogBatchNodeForTiled);

    -- 建筑迷雾
    self.m_fogNatchNode = CCSpriteBatchNode:create(tempTName);
    self.m_mapLayer:addChild(self.m_fogNatchNode);

    -- 改版建筑迷雾
    tempDic = CCDictionary:createWithContentsOfFile("bb_cloud.plist");
    tempTName = tolua.cast(tempDic:objectForKey("metadata"),"CCDictionary"):valueForKey("realTextureFileName"):getCString();
    self.m_cloudBatchNode = CCSpriteBatchNode:create(tempTName);
    self.m_mapLayer:addChild(self.m_cloudBatchNode);

    --主角
    -- self.m_playerAnimNode = game_util:createOwnRoleAnim();
    self.m_buildingNatchNode = CCNode:create()
    self.m_mapLayer:addChild(self.m_buildingNatchNode)
    -- if self.m_playerAnimNode then
    --     self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
    --     self.m_buildingNatchNode:addChild(self.m_playerAnimNode,1000,1000)
    --     self.m_playerAnimNode:setPosition(ccp(self.m_mapSize.width*0.5,self.m_mapSize.height*0.5))
    -- end

    -- self:resetPlayerAnimPosition(ccp(0,0))
    --触摸事件
    -- handing touch events
    local touchBeginPoint = nil
    local touchPoint = nil
    local function onTouchBegan(x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        return true
    end

    local function onTouchMoved(x, y)
        if touchPoint and self.m_moveFlag then
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
                            -- cclog("alpha ====================" .. tostring(alpha) .. "display.contentScaleFactor ==" .. display.contentScaleFactor)
                        end
                        if alpha ~= 0 then
                            if selectBuilding == nil then
                                selectBuilding = tempBuilding;
                            else
                                if tempBuilding:getZOrder() > selectBuilding:getZOrder() then
                                    selectBuilding = tempBuilding;
                                end
                            end
                        end
                    end
                end
            end
            if selectBuilding ~= nil then
                local landItemId = tostring(selectBuilding:getTag())
                local itemData = self.m_landItemTab[landItemId]
                if itemData then
                    local landItem = itemData.landItem
                    self:openBuildingDetail(landItem)--开启建筑详细
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

            self.m_mapLayer:setScale(self.m_mapScale);
            local cx,cy = self.m_mapLayer:getPosition();
            self:resetMapPosition(cx,cy);
            distance = dis;
        end
    end
    local function onTouch(eventType, x, y)
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
    testLayer:registerScriptTouchHandler(onTouch,false,2,true)--多点触摸
    testLayer:setTouchEnabled(true)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[
    开启建筑详细
]]
function game_gvg_map.openBuildingDetail(self,landItem)
    cclog2(landItem,"landItem")
    local landType = landItem.type 
    if landType == -1 then--点击无效果

    elseif landType == 2 then--主家，判断是否可以攻击的flag
        if self.home_att_flag == true then
            --类似世界boss接口

        else
            game_util:addMoveTips({text = string_helper.game_gvg_map.text})
        end
    else--请求接口，根据返回值进入不同的界面
        -- game_scene:addPop("game_gvg_enemy_pop",{})--敌人
        -- game_scene:addPop("game_gvg_npc",{})--npc
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local status = data:getNodeWithKey("status"):toInt()
            if status == 4 then--npc    和gvg_index的sort是一样的
                game_scene:addPop("game_gvg_npc",{gameData = gameData,buildingId = landItem.id,building_cid = landItem.c_id})
            elseif status == 1 then--人
                game_scene:addPop("game_gvg_enemy_pop",{gameData = gameData,buildingId = landItem.id,building_cid = landItem.c_id})
            else--空地块  直接刷新
                local data = gameData:getNodeWithKey("data")
                local doing = data:getNodeWithKey("doing")
                self.m_tGameData = json.decode(doing:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:addMoveTips({text = string_helper.game_gvg_map.text2})
            end
        end
        local params = {}
        params.building_id = landItem.id
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_open_building"), http_request_method.GET, params,"guild_gvg_open_building")
    end
end
--[[--
    初始化地图
]]
function game_gvg_map.initMap(self)
    local smallItemCount = 4;
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    self.m_landItemCountX = 0;          -- 4*4大格子宽
    self.m_landItemCountY = 0;          -- 4*4大格子高
    local gameData = self.m_tGameData
    local landData = gameData["citys"]
    self.m_landItemCountY = #landData;
    local landDataXCount = nil;
    local landDataX = nil;
    local landItem = nil;
    local mapItem = nil;
    local landItemOpenType = -1;
    local buildingId = nil;
    local buildingIconName = nil;
    local tempFlag = nil;
    math.randomseed(os.time());
    local function get_value( x,y )
        if(x<0 or x>=landDataXCount or y<0 or y>=self.m_landItemCountY)then
            return -1;
        end
        local temp =  landData:getNodeAt(y):getNodeAt(x):getNodeAt(0):toInt();
        return temp;
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("roadblock.plist");
    self.m_buildingNatchNode:removeAllChildrenWithCleanup(true)
    for i=1,self.m_landItemCountY do
        landDataX = landData[i]
        landDataXCount = #landDataX
        self.m_landItemCountX = math.max(landDataXCount,self.m_landItemCountX);
        for k,landItem in pairs(landDataX) do
            i = landItem.y;
            j = landItem.x;
            mapItem = earthLayer:tileAt(ccp((j)*smallItemCount,(i)*smallItemCount));
            --{"x":0,"id":"1001","y":0,"is_head":0,"owner":"h15016489","role":1,"type":1,"c_id":70001,"name":"","is_default":1}
            if mapItem ~= nil then
                local landType = landItem.type
                if landType ~= -1 then
                    self:createRoleBuilding(earthLayer,ccp((j)*smallItemCount,(i)*smallItemCount),landItem);
                end
            end
        end
    end
    local value = self.m_landItemCountX*smallItemCount + self.m_landItemCountY*smallItemCount;
    self.m_realMapSize = CCSizeMake(value*self.m_tiledW*0.5,value*self.m_tiledH*0.5);
    self.m_realMapSizeEndPos = ccp((-self.m_mapSize.width*0.5 - self.m_tiledW*0.5*value*0.5) * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    self.m_realMapSizeStartPos = ccp((self.m_realMapSizeEndPos.x + self.m_realMapSize.width) * self.m_mapScale,(self.m_realMapSizeEndPos.y + self.m_realMapSize.height) * self.m_mapScale);
    if self.m_tempMapPostion then
        self.m_mapLayer:setPosition(self.m_tempMapPostion);
    end
    self.m_scroll_view:setContentSize(self.m_realMapSize);
end
--[[
    创建role建筑
]]
function game_gvg_map.createRoleBuilding(self,earthLayer,pos,landItem)
    --landItem 
    --{"x":0,"id":"1001","y":0,"is_head":0,"owner":"h15016489","role":1,"type":1,"c_id":70001,"name":"","is_default":1}
    if earthLayer == nil or self.m_buildingNatchNode == nil then return end;
    local mapItem = earthLayer:tileAt(pos);
    if mapItem then
        local buiding_pos = earthLayer:positionAt(pos);
        local buildsize = nil;
        -- local building_icon = CCNode:create();              -- 建筑图标
        local building_icon = CCSprite:create("building_img/gvg_map_test.png");
        -- local building_icon = CCSprite:create("building_img/zlzhong.png");

        local dw = building_icon:getContentSize().width*0.5
        local dh = building_icon:getContentSize().height*0.5
        building_icon:removeAllChildrenWithCleanup(true)
        local tempName = nil;
        local offset = nil
        local is_head = landItem.is_head--填不填充建筑的标志
        --type: -1:无用, 0: 空地, 1: 防御方, 2: 主家, 3: 攻击方， 4：怪物
        local landType = landItem.type
        if landType == 1 or landType == 3 then--创建攻击方或者防守方的role  ICON
            local roleId = landItem.role
            local role_detail_cfg = getConfig(game_config_field.role_detail);
            local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))

            if itemCfg then
                animName = itemCfg:getNodeWithKey("animation"):toStr();
            else
                animName = "role_soldier";
            end
            local roleNode = game_util:createPlayerRoleAnim(animName,1);
            roleNode:setAnchorPoint(ccp(0.5,0))
            roleNode:setPosition(ccp(dw,dh))
            local personName = game_util:createLabelTTF({text = landItem.name,fontSize = 10});
            if landType == 1 then
                personName:setColor(ccc3(31,43,141))
            else
                personName:setColor(ccc3(178,24,26))
            end
            personName:setPosition(ccp(dw,dh-10))
            building_icon:addChild(roleNode,1,1)
            building_icon:addChild(personName,2,2)
        elseif landType == 0 then--空地块
            
        elseif landType == 2 then--主家
            local gvgCfg = getConfig(game_config_field.gvg_mine)
            local itemCfg = gvgCfg:getNodeWithKey(tostring(landItem.c_id))
            local image = itemCfg:getNodeWithKey("image"):toStr()
            tempName = "building_img/" .. image .. ".png";
            if is_head == 0 then
                local homeSprite = CCSprite:create(tempName);
                building_icon = homeSprite
                offset = building_offset[image];

                --添加倒计时
                local time = landItem.time
                cclog2(time,"time")
                if time > 0 then--倒计时
                    self.home_att_flag = false--倒计时，不可以打主家
                    local function timeEndFunc()
                        if self.home_left_time then
                            self.home_left_time:removeFromParentAndCleanup(true)
                            self.home_left_time = nil;
                            self.home_att_flag = true--重置，可以打主家
                        end
                    end
                    self.home_left_time = game_util:createCountdownLabel(time,timeEndFunc,8,1);
                    self.home_left_time:setPosition(ccp(building_icon:getContentSize().width*0.5,building_icon:getContentSize().height*0.5))
                    building_icon:addChild(self.home_left_time,10,10)
                else
                    self.home_att_flag = true--可以打主家
                end
            end
        elseif landType == 4 then--怪物
            --名字照用，role改成怪物图片
            local animFile = landItem.role
            local animNode = game_util:createIdelAnim(animFile)
            animNode:setAnchorPoint(ccp(0.5,0))
            animNode:setPosition(ccp(dw,dh))
            local animName = game_util:createLabelTTF({text = landItem.name,color = ccc3(10,10,10),fontSize = 10});
            animName:setPosition(ccp(dw,dh-10))
            building_icon:addChild(animNode,1,1)
            building_icon:addChild(animName,2,2)
        end
        if building_icon == nil then return end
        if is_head == 0 then
            -- offset = building_offset["zlzhong"];
            buildsize = building_icon:getContentSize();
            building_icon:ignoreAnchorPointForPosition(true);
            self.m_landItemTab[tostring(landItem.id)] = {landItem = landItem,building_icon = building_icon}
            -- building_icon = CCLayerColor:create(ccc4(255,0,0,150),buildsize.width,buildsize.height);
            if offset ~= nil then
                building_icon:setPosition(ccp(buiding_pos.x + self.m_tiledW*0.5  - offset[1]/2,buiding_pos.y - self.m_tiledH - offset[2]/2));
            else
                building_icon:setPosition(ccp(buiding_pos.x - self.m_tiledW*1,buiding_pos.y - self.m_tiledH*2.5));
            end
            --添加建筑
            self.m_buildingNatchNode:addChild(building_icon,-building_icon:getPositionY(),landItem.id);
            --添加触摸table列表
            self.m_buildingTable[pos.x .. "-" .. pos.y] = {building_icon=building_icon,fileName = tempName};
        end
    end
end
--[[--
    重置地图的位置
]]
function game_gvg_map.resetMapPosition(self,cx,cy)
    --判断边界
    if self.m_visibleSize.width > self.m_realMapSize.width * self.m_mapScale then
        if cx < (self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5) then
            cx = self.m_realMapSizeEndPos.x + self.m_realMapSize.width* self.m_mapScale - self.m_visibleSize.height*0.5;
        end
        if cx > self.m_realMapSizeEndPos.x  + self.m_realMapSize.width* self.m_mapScale + self.m_visibleSize.width*0.5 then
            cx = self.m_realMapSizeEndPos.x  + self.m_realMapSize.width* self.m_mapScale + self.m_visibleSize.width*0.5;
        end
    else
        if cx < (self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5) then
            cx = self.m_realMapSizeEndPos.x + self.m_visibleSize.width*0.5;
        end
        if cx > self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0.5 then
            cx = self.m_realMapSizeStartPos.x + self.m_visibleSize.width*0.5;
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
        if cy < (self.m_realMapSizeEndPos.y + self.m_visibleSize.height*0.5) then
            cy = self.m_realMapSizeEndPos.y + self.m_visibleSize.height*0.5;
        end
        if cy > self.m_realMapSizeStartPos.y + 69 then
            cy = self.m_realMapSizeStartPos.y + 69;
        end
    end
    self.m_tempMapPostion = ccp(cx,cy)
    self.m_mapLayer:setPosition(self.m_tempMapPostion);
end
--[[
    刷新label
]]
function game_gvg_map.refreshLabel(self)
    self.guild_def_name:setString(self.m_tGameData.defender)
    self.guild_att_name:setString(self.m_tGameData.attacker)

    self.bar_node:removeAllChildrenWithCleanup(true)
    self.left_time_node:removeAllChildrenWithCleanup(true)

    --倒计时
    local function timeEndFunc()

    end
    local countDownTime = self.m_tGameData.remaining_time
    local countdownLabel = game_util:createCountdownLabel(countDownTime,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setColor(ccc3(255,94,9))
    self.left_time_node:addChild(countdownLabel,10,10)
    --进度条
    local att_score = self.m_tGameData.attacker_score
    local def_score = self.m_tGameData.defender_score
    local max_value = att_score + def_score
    local now_value = def_score
    local bar = ExtProgressTime:createWithFrameName("gvg_att_hp.png","gvg_def_hp.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.bar_node:addChild(bar,-1,11)
    --
    self.att_num:setString(att_score)
    self.def_num:setString(def_score)

    local camp_flag = false
    if self.m_tGameData.owner_guild == 1 then--攻击方
        camp_flag = false
    else
        camp_flag = true
    end
    self.def_camp:setVisible(camp_flag)
    self.att_camp:setVisible(not camp_flag)
end

--[[--
    刷新ui
]]
function game_gvg_map.refreshUi(self)
    self:initMap();
    self:refreshLabel()
end
function game_gvg_map.resetPlayerAnimPosition(self,pos)
    if self.m_playerAnimNode then
        self.m_playerAnimNode:setPosition(ccp(pos.x + self.m_tiledW,pos.y + self.m_tiledH));
        self.m_mapLayer:setPosition(ccp(-pos.x+self.m_visibleSize.width*0.5,-pos.y+self.m_visibleSize.height*0.5));
    end
end
--[[--
    初始化
]]
function game_gvg_map.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingTable = {};
    self.m_touchRef = 0;
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local doing = data:getNodeWithKey("doing")
        self.m_tGameData = json.decode(doing:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_buildingClickFlag = false;
    self.m_moveFlag = true;
    self.m_landItemTab = {};
    self.callBackFunc = t_params.callBackFunc
end

--[[--
    创建入口
]]
function game_gvg_map.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_gvg_map;