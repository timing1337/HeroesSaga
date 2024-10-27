---  城市地图

local game_pirate_map = {
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
function game_pirate_map.destroy(self)
    cclog("-----------------game_pirate_map destroy-----------------");
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
end
function map_info_data:get_bb_cloud( x,y )
    -- body
    local function get_id( tx,ty )
        -- body
        -- 得到遮挡信息
        if(tx<0)then
            tx=-1;
        end
        if(tx>=self.w)then
            tx = self.w;
        end
        if(ty<0)then
            ty=-1;
        end
        if(ty>=self.h)then
            ty=self.h;
        end

        if(ty<0 or ty>=self.h or tx<0 or tx>=self.w)then
            local theY = 0
            local theX = 0
            for i=-1,1 do
                theY = ty+i;
                if(theY>=0 and theY<self.h)then
                    for j=-1,1 do
                        theX = tx+j;
                        if(theX>=0 and theX<self.w)then
                            if(self.data[theY*self.w+theX+1]==1)then
                                return 0;
                            end
                        end
                    end
                end
            end
            return -1;
        end
        local temp = self.data[ty*self.w+tx+1];
        if(temp==2)then
            return 0;
        -- elseif(temp==0)then
        --     return -1;
        end
        return temp;
    end
    -- 调整传入参数边界范围
    if x>=self.w then
        x = self.w-1;
    end
    if x<0 then
        x = 0;
    end
    if y>=self.h then
        y = self.h-1;
    end
    if y<0 then
        y = 0;
    end
    -- 如果为0时当前块的云雾状态
    local lt_md = get_id(x-1,y-1);    -- left top
    local t_md  = get_id(x,y-1);      -- top
    local rt_md = get_id(x+1,y-1);    -- right top
    local l_md  = get_id(x-1,y);      -- left
    local r_md  = get_id(x+1,y);      -- right
    local lb_md = get_id(x-1,y+1);    -- left bottom
    local b_md  = get_id(x,y+1);      -- bottom
    local rb_md = get_id(x+1,y+1);    -- right bottom

    local temp = "";
    local md = get_id(x,y);
    if(md==1)then
        return temp;
    end
    if(md<0)then
        return "bb_shi.png";
    end
    if(lt_md<0 and t_md<0 and l_md<0 and rb_md>=0)then
        temp = "bb_up.png";
    elseif(l_md<0 and lb_md<0 and b_md<0 and rt_md>=0)then
        temp = "bb_left.png";
    elseif(b_md<0 and rb_md<0 and r_md<0 and lt_md>=0)then
        temp = "bb_down.png";
    elseif(r_md<0 and rt_md<0 and t_md<0 and lb_md>=0)then
        temp = "bb_right.png";
    elseif(l_md<0 and t_md>=0 and b_md>=0 and r_md>=0)then
        temp = "bb_left_up.png";
    elseif(t_md<0 and l_md>=0 and r_md>=0 and b_md>=0)then
        temp = "bb_right_up.png";
    elseif(r_md<0 and t_md>=0 and b_md>=0 and l_md>=0)then
        temp = "bb_right_down.png";
    elseif(b_md<0 and l_md>=0 and r_md>=0 and r_md>=0)then
        temp = "bb_left_down.png";
    end
    return temp;
end

function map_info_data:get_earth_fog( x,y )
    -- body
    local function get_id( tx,ty )
        -- body
        -- 得到遮挡信息
        if(tx<0)then
            tx=-1;
        end
        if(tx>=self.w)then
            tx = self.w;
        end
        if(ty<0)then
            ty=-1;
        end
        if(ty>=self.h)then
            ty=self.h;
        end

        if(ty<0 or ty>=self.h or tx<0 or tx>=self.w)then
            local theY = 0
            local theX = 0
            for i=-1,1 do
                theY = ty+i;
                if(theY>=0 and theY<self.h)then
                    for j=-1,1 do
                        theX = tx+j;
                        if(theX>=0 and theX<self.w)then
                            if(self.data[theY*self.w+theX+1]==1)then
                                return 0;
                            end
                        end
                    end
                end
            end
            return -1;
        end
        local temp = self.data[ty*self.w+tx+1];
        if temp>=2 then
            temp = 0;
        end
        return temp;
    end
    -- 调整传入参数边界范围
    if x>=self.w then
        x = self.w-1;
    end
    if x<0 then
        x = 0;
    end
    if y>=self.h then
        y = self.h-1;
    end
    if y<0 then
        y = 0;
    end
        -- 检查当前块的状态
    md = get_id(x,y);
    if md==1 then
        local temp = {'','','','',
                    '','','','',
                    '','','','',
                    '','','','',}
        return temp;
    elseif md==0 then
        local temp = {'huise.png','huise.png','huise.png','huise.png',
                        'huise.png','huise.png','huise.png','huise.png',
                        'huise.png','huise.png','huise.png','huise.png',
                        'huise.png','huise.png','huise.png','huise.png',
                    }
        return temp;
    elseif md==-1 then
        local temp = {'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png'}
        return temp;
    end

end
--[[--
    返回
]]
function game_pirate_map.back(self,type)
    -- local function responseMethod(tag,gameData)
    --     game_scene:enterGameUi("game_activity",{gameData = gameData})
    --     self:destroy()
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_map.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 101 then--查看队伍
            game_scene:addPop("game_pirate_team_pop",{alignment = self.alignment,total_hp = self.total_hp,leftHeals = self.leftHeals,die = self.die,hp_heal_percent = self.hp_heal_percent,treasure = self.treasure})
        elseif btnTag == 100 then--恢复血量
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.total_hp_rate = data:getNodeWithKey("total_hp_rate"):toInt()
                self.total_hp = json.decode(data:getNodeWithKey("total_hp"):getFormatBuffer())
                self.heal_times = data:getNodeWithKey("heal_times"):toInt()
                self:refreshLabel()
            end
            local params = {}
            params.treasure = self.treasure
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_recover_hp"), http_request_method.GET, params,"search_treasure_recover_hp")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_pirate_map.ccbi");
    
    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.m_scroll_view = ccbNode:scrollViewForName("m_scroll_view")
    self.name_label = ccbNode:labelTTFForName("name_label")
    self.complete_text = ccbNode:labelTTFForName("complete_text")
    --属性加成
    local title115 = ccbNode:labelTTFForName("title115");
    title115:setString(string_helper.ccb.title115);
    self.life_buff = ccbNode:labelBMFontForName("life_buff")
    self.patt_buff = ccbNode:labelBMFontForName("patt_buff")
    self.matt_buff = ccbNode:labelBMFontForName("matt_buff")
    self.def_buff = ccbNode:labelBMFontForName("def_buff")
    self.speed_buff = ccbNode:labelBMFontForName("speed_buff")
    --
    self.life_label = ccbNode:labelBMFontForName("life_label")
    self.life_node = ccbNode:nodeForName("life_node")
    self.recover_label = ccbNode:labelBMFontForName("recover_label")
    self.percent_label = ccbNode:labelBMFontForName("percent_label")

    self.tips_label = ccbNode:labelTTFForName("tips_label")
    local btn_continue = ccbNode:controlButtonForName("btn_continue");
    game_util:setCCControlButtonTitle(btn_continue,string_helper.ccb.file41);
    --添加地图
    local testLayer = CCLayer:create();
    root_map_node:addChild(testLayer);
    -- local tmx = "map_" .. tostring(self.city) .. ".tmx";--取配置读地图
    --根据Id取地图
    local mapCfg = getConfig(game_config_field.treasure)
    local itemCfg = mapCfg:getNodeWithKey(tostring(self.treasure))
    local map_id = itemCfg:getNodeWithKey("map_id"):toInt()
    local tmx = "pirate_map_" .. map_id
    cclog(" map_main_story_cfg_item  tmx === " .. tmx);
    if tmx == "" then
        self.m_tiledMap = CCTMXTiledMap:create("building_img/map_10001.tmx")
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
    -- self.m_mapLayer:setPosition(- self.m_mapSize.width*0.5 * self.m_mapScale + self.m_visibleSize.width - self.m_tiledW * 0.5 , - self.m_mapSize.height * self.m_mapScale + self.m_visibleSize.height);
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
    self.m_playerAnimNode = game_util:createOwnRoleAnim();
    self.m_buildingNatchNode = CCNode:create()
    self.m_mapLayer:addChild(self.m_buildingNatchNode)
    if self.m_playerAnimNode then
        self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
        self.m_buildingNatchNode:addChild(self.m_playerAnimNode,1000,1000)
        self.m_playerAnimNode:setPosition(ccp(self.m_mapSize.width*0.5,self.m_mapSize.height*0.5))
    end

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
                -- local start_cx, start_cy = self.m_mapLayer:getPosition();
                -- local cx , cy = start_cx + x - touchPoint.x,start_cy + y - touchPoint.y;
                -- self:resetMapPosition(cx,cy);
                
                local landItem =self.m_landItemTab[selectBuilding:getTag()].landItem
                local landItemOpenType = landItem[1]
                local buildingId = tonumber(landItem[2]);
                local buildingIconName = landItem[3]
                cclog("selectBuilding ================= " .. tostring(selectBuilding) .. " ; landItemOpenType = " .. landItemOpenType .. " ; buildingId = " .. buildingId)
                if (landItemOpenType == 1 or landItemOpenType == 2) and buildingId > 0 and self.m_buildingClickFlag == false then 
                    self.m_buildingClickFlag = true;
                    game_util:spriteOnClickAnim({
                    tempSpr = selectBuilding,
                    listener =  function()
                        cclog("building onclick --------buildingId =" .. tostring(buildingId) .. " ; buildingIconName=" .. buildingIconName);
                        self:buildingOnClick(buildingId,selectBuilding,landItemOpenType);
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

            self.m_mapLayer:setScale(self.m_mapScale);
            local cx,cy = self.m_mapLayer:getPosition();
            self:resetMapPosition(cx,cy);
            distance = dis;
        end
    end
    --挖宝完成   或者  死亡
    if self.m_tGameData.curt_regain == 100 then--完全收复展示动画
        self.winType = "win"
        self.m_recover_node = self:createBuildingRecoverAnim();
        game_scene:getPopContainer():addChild(self.m_recover_node,10,10);
    elseif self.total_hp_rate <= 0 then--失败直接弹板
        self.winType = "lose"
        self:createBuildingRecoverPop();
        --失败弹框要求选择直接结束还是求求帮助
        -- local association_id = game_data:getUserStatusDataByKey("association_id");
        -- if association_id == 0 then
        --     self:createBuildingRecoverPop();
        -- else
        --     --弹出让其选择的
        -- end
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
    提示可以救援
]]
function game_pirate_map.showHelp(self)
    game_scene:addPop("game_pirate_result_pop",{regain_reward = self.m_tGameData.regain_reward,curt_regain = self.m_tGameData.curt_regain});
end
--[[--
    初始化地图
]]
function game_pirate_map.initMap(self)
    local smallItemCount = 4;
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    self.m_landItemCountX = 0;          -- 4*4大格子宽
    self.m_landItemCountY = 0;          -- 4*4大格子高
    -- local gameData = game_data:getSelCityData();
    local gameData = self.m_tGameData
    local landData = gameData["land"]

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
    for i=1,self.m_landItemCountY do
        landDataX = landData[i]
        landDataXCount = #landDataX
        self.m_landItemCountX = math.max(landDataXCount,self.m_landItemCountX);
        for j=1,landDataXCount do
            landItem = landDataX[j];
            mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount,(i-1)*smallItemCount));
            --[1表示拥有/0表示可见/-1表示迷雾,建筑id,建筑图片id,是否为建筑占地的第一格]
            landItemOpenType = landItem[1]
            buildingId = tonumber(landItem[2])-- -1为起始点
            buildingIconName = landItem[3];
            tempFlag = landItem[4];
            if mapItem ~= nil and (tempFlag == 0 or buildingId == 100000 or buildingId == 99999) then
                if landItemOpenType == -1 then -- 迷雾
                    -- mapItem:setColor(ccc3(0,0,0));    -- 调整颜色
                elseif landItemOpenType == 0 or landItemOpenType == 2 then -- 可见
                    -- mapItem:setColor(ccc3(0,0,0));
                    if buildingIconName ~= nil and buildingIconName ~= "" then
                        self:createBuilding(earthLayer,ccp((j-1)*smallItemCount ,(i-1)*smallItemCount),buildingIconName,landItem,buildingId,landItemOpenType);
                    end
                elseif landItemOpenType == 1 then --拥有
                    if buildingId == 100000 then
                        buildingIconName = "yingdi";
                    elseif buildingId == 99999 then
                        buildingIconName = "crashfly";
                    end
                    if buildingIconName ~= nil and buildingIconName ~= "" then
                        self:createBuilding(earthLayer,ccp((j-1)*smallItemCount,(i-1)*smallItemCount),buildingIconName,landItem,buildingId,landItemOpenType);
                    end
                end
            end
        end
    end

    -- 数组
    map_info_data.w = self.m_landItemCountX;
    map_info_data.h = self.m_landItemCountY;
    map_info_data.data = {};
    for i=1,map_info_data.h do
        local tempx = #landDataX
        local tempvd = landData[i]
        for j=1, map_info_data.w do
            local index = (i-1)*map_info_data.w+(j-1)+1;
            if(j>tempx)then
                map_info_data.data[index] = -1;
                break;
            end
            templd = tempvd[j]
            map_info_data.data[index] = templd[1]
        end
    end
    -- 云层
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("fog.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bb_cloud.plist");
    local ptx,pty = 0,0;
    local sprint = nil;
    local img = nil;
    local imgname = nil;
    cclog("map info data w:" .. tostring(map_info_data.w) .. 'h:' .. tostring(map_info_data.h));
    for i=1 , map_info_data.h do
        for j=1,map_info_data.w do
            -- 改版建筑物迷雾
            img = map_info_data:get_bb_cloud(j-1,i-1);
            if(img ~= "")then
                mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+math.floor(smallItemCount/2),(i-1)*smallItemCount+math.floor(smallItemCount/2)));
                if(mapItem~=nil)then
                    ptx,pty = mapItem:getPosition();
                    sprite = CCSprite:createWithSpriteFrameName(img);
                    sprite:setPosition(ccp(ptx+self.m_tiledW*0.5,pty+self.m_tiledH*0.5));
                    sprite:setColor(ccc3(0,0,0));
                    -- if not self.m_isHard_allRegain then
                        self.m_cloudBatchNode:addChild(sprite);
                    -- end
                end
            end
            -- 地表迷雾
            img = map_info_data:get_earth_fog(j-1,i-1);
            for dv=1,16 do
                imgname = img[dv];
                if(imgname ~= '')then
                    mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+math.floor((dv-1)%4),(i-1)*smallItemCount+math.floor((dv-1)/4)));
                    if mapItem~=nil then
                        ptx,pty = mapItem:getPosition();
                        sprint = CCSprite:createWithSpriteFrameName(imgname);
                        sprint:setColor(ccc3(0,0,0));
                        sprint:setPosition(ccp(ptx+self.m_tiledW*0.5,pty+self.m_tiledH*0.5));
                        if not self.m_isHard_allRegain then
                            self.m_fogBatchNodeForTiled:addChild(sprint);
                        end
                    end
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
--[[--
    --完全收复后添加胜利弹板
]]
function game_pirate_map.createBuildingRecoverPop( self )
    game_scene:addPop("game_pirate_result_pop",{regain_reward = self.m_tGameData.regain_reward,curt_regain = self.m_tGameData.curt_regain,winType = self.winType});
end
--[[--
    创建收复动画
]]
function game_pirate_map.createBuildingRecoverAnim( self )
    if self.m_recover_node ~= nil then
        return;
    end
    self.m_recover_anim_over = false;
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/anim_building_recover.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local function removeRecoverNode()
        if self.m_recover_node then
            self:createBuildingRecoverPop();
            self.m_recover_node:removeFromParentAndCleanup(true);
            self.m_recover_node = nil;
        end
    end

    local function playAnimEnd(animName)
        self.m_recover_anim_over = true;
        removeRecoverNode();
    end
    ccbNode:registerAnimFunc(playAnimEnd);
    ccbNode:runAnimations("recover_anim");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- if self.m_recover_anim_over == true then
            --     removeRecoverNode();
            -- end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    ccbNode:runAnimations("recover_anim");
    return ccbNode;
end
--[[--
    创建建筑的方法
]]
function game_pirate_map.createBuilding(self,earthLayer,pos,buildingIconName,landItem,buildingId,landItemOpenType)
    if earthLayer == nil or self.m_buildingNatchNode == nil then return end;
    local mapItem = earthLayer:tileAt(pos);

    if mapItem then
        local buiding_pos = earthLayer:positionAt(pos);
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
        self.m_landItemTab[buildingId] = {landItem = landItem,building_icon = building_icon}
        landItemOpenType = landItem[1];
        if(landItemOpenType ~= 1)then       -- 建筑物阴影
            building_icon:setColor(ccc3(70,70,70));
        end
        -- cclog("buildingIconName ====================" .. buildingIconName);
        local offset = building_offset[buildingIconName];
        local realPos = nil;
        if offset ~= nil then
            realPos = ccp(buiding_pos.x + self.m_tiledW*0.5  - offset[1]/2,buiding_pos.y - self.m_tiledH - offset[2]/2);
            building_icon:setPosition(realPos);
        else
            realPos = ccp(buiding_pos.x - self.m_tiledW*1,buiding_pos.y - self.m_tiledH*2.5);
            building_icon:setPosition(realPos);
        end
        self.m_buildingNatchNode:addChild(building_icon,-building_icon:getPositionY(),buildingId);
        if tempBuildingIconName == "yingdi" or tempBuildingIconName == "crashfly" then
            if self.m_selBuildingId == -1 then
                self:resetPlayerAnimPosition(realPos);
            end
        else
            if self.m_selBuildingId == buildingId then
                self:resetPlayerAnimPosition(realPos);
            end
        end
        self.m_buildingTable[pos.x .. "-" .. pos.y] = {building_icon=building_icon,fileName = tempName};
        --取配置显示浮标
        local mapCfg = getConfig(game_config_field.map_treasure_detail_battle)
        local buildCfg = mapCfg:getNodeWithKey(tostring(buildingId))
        if buildCfg and buildingId > 0 then
            if landItemOpenType == 2 then
                local loot_show = buildCfg:getNodeWithKey("loot_show"):toStr()
                cclog2(loot_show,"loot_show")
                if loot_show == "" then
                    loot_show = "jiaozhan";
                end
                local impactAnim = game_util:createImpactAnim(loot_show,1.0)
                if impactAnim then
                    local pX,pY = building_icon:getPosition();
                    impactAnim:setPosition(ccp(buildsize.width/2,buildsize.height/2+20));
                    building_icon:addChild(impactAnim,100,100);
                end
            end
        end
        if buildingId < 0 then
            building_icon:setColor(ccc3(155,155,155));
        end
    end
end
--[[--
    重置地图的位置
]]
function game_pirate_map.resetMapPosition(self,cx,cy)
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

--[[--
    建筑点击的处理
]]
function game_pirate_map.buildingOnClick(self,buildingId,buildingSpr,landItemOpenType)
    self.m_selBuildingId = buildingId;
    if buildingId == 100000 then--返回基地
        self:back();
    else
        --landItemOpenType     2 是没打过可以打的    1是打过的    0是没打过不可打的
        if landItemOpenType == 1 then
            game_data:setRecoverFlag(true);
        else
            game_data:setRecoverFlag(false);
        end
        local function callFunc(callType)
            self.m_buildingClickFlag = false;
        end
        --取配置显示打开哪种
        local mapCfg = getConfig(game_config_field.map_treasure_detail_battle)
        local buildCfg = mapCfg:getNodeWithKey(tostring(buildingId))
        if buildCfg then
            local sort = buildCfg:getNodeWithKey("sort"):toInt()
            cclog2(sort,"sort")
            --1是npc    2是玩家  3是宝箱   4是BUFF
            local params = {}
            params.buildingId = self.m_selBuildingId
            params.callFunc = callFunc
            params.landItemOpenType = landItemOpenType
            params.city = self.city
            params.treasure = self.treasure
            if sort == 1 then
                --这里打开建筑
                local fight_list = buildCfg:getNodeWithKey("fight_list"):getNodeAt(0)
                cclog2(fight_list,"fight_list")
                local firstFight = fight_list:getNodeAt(1):toInt()
                cclog2(firstFight,"firstFight")
                params.recapture_log = self.recapture_log
                params.openType = "NPC"
                params.firstFight = firstFight
                local function responseMethod(tag,gameData)
                    self.m_buildingClickFlag = false;
                    if gameData then
                        params.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        game_scene:addPop("game_pirate_npc_pop",params)
                    else
                        self.m_buildingClickFlag = false;
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_map_fight_and_enemy"),http_request_method.GET,{building=self.m_selBuildingId,city = self.city,treasure = self.treasure},"search_treasure_map_fight_and_enemy",true,true)
            elseif sort == 2 then
                params.recapture_log = self.recapture_log
                local function responseMethod(tag,gameData)
                    self.m_buildingClickFlag = false;
                    if gameData == nil then
                        return;
                    end
                    params.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    params.openType = "PK"
                    game_scene:addPop("game_pirate_enemy_pop",params)
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_open_building"), http_request_method.GET, {building=self.m_selBuildingId,city = self.city,treasure = self.treasure},"search_treasure_open_building",true,true)
            elseif sort == 3 then--宝箱
                local function responseMethod(tag,gameData)
                    self.m_buildingClickFlag = false;
                    if gameData then
                        params.openType = "BOX"
                        params.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        game_scene:addPop("game_pirate_buff_pop",params)
                    else
                        self.m_buildingClickFlag = false;
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_open_building_gifts"), http_request_method.GET, {building=self.m_selBuildingId,city = self.city,treasure = self.treasure},"search_treasure_open_building_gifts",true,true)
            elseif sort == 4 then--BUFF
                local function responseMethod(tag,gameData)
                    self.m_buildingClickFlag = false;
                    if gameData then
                        params.openType = "BUFF"
                        params.gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        game_scene:addPop("game_pirate_buff_pop",params)
                    else
                        self.m_buildingClickFlag = false;
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_open_building_buff"), http_request_method.GET, {building=self.m_selBuildingId,city = self.city,treasure = self.treasure},"search_treasure_open_building_buff",true,true)
            end
        end
    end
end
--[[
    刷新label
]]
function game_pirate_map.refreshLabel(self)
    --地图名字
    local mapCfg = getConfig(game_config_field.treasure)
    local itemCfg = mapCfg:getNodeWithKey(tostring(self.treasure))
    local name = itemCfg:getNodeWithKey("name"):toStr()
    self.name_label:setString(name)
    --道具剩余数量
    local hp_heal_time = itemCfg:getNodeWithKey("hp_heal_time"):toInt()
    self.leftHeals = hp_heal_time-self.heal_times
    self.recover_label:setString("×" .. (hp_heal_time-self.heal_times))

    --每次恢复血量
    local hp_heal_percent = itemCfg:getNodeWithKey("hp_heal_percent"):toInt()
    self.hp_heal_percent = hp_heal_percent
    self.percent_label:setString(hp_heal_percent .. "%")

    --计算血量
    local max_hp = math.max(100,self.total_hp_rate)
    local cur_hp = self.total_hp_rate
    -- for k,v in pairs(self.total_hp) do
    --     max_hp = max_hp + v.max_hp
    --     cur_hp = cur_hp + v.cur_hp
    -- end
    -- local percent = math.floor((cur_hp / max_hp) * 100)
    self.life_label:setString(self.total_hp_rate .. "%")

    --血条
    local life_bar = self.life_node:getChildByTag(11)
    if life_bar then
        life_bar:removeFromParentAndCleanup(true)
    end
    local max_value = max_hp
    local now_value = cur_hp
    local bar = ExtProgressTime:createWithFrameName("pirate_life_1.png","pirate_life.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.life_node:addChild(bar,-1,11);

    self.complete_text:setString(string_helper.game_pirate_map.complate .. self.m_tGameData.curt_regain .. "%")
end

--[[--
    刷新ui
]]
function game_pirate_map.refreshUi(self)
    self:refreshProperty()
    self:initMap();
    self:refreshLabel()
    --奖励
    game_util:rewardTipsByDataTable(self.regain_reward);
    if self.callBackFunc then
        self.callBackFunc()
        self.callBackFunc = nil;
    end
    if self.reward then
        game_util:rewardTipsByDataTable(self.reward);
        self.reward = nil
    end
    if self.tipText then
        game_util:addMoveTips({text = self.tipText})
        self.tipText = nil;
    end
    local tips = self.m_tGameData.rewardTips or ""
    self.tips_label:setString(tips)
end
--[[
    刷新属性加成
]]
function game_pirate_map.refreshProperty(self)
    self.life_buff:setString((self.property_add.hp or 0) .. "%")
    self.patt_buff:setString((self.property_add.patk or 0) .. "%")
    self.matt_buff:setString((self.property_add.matk or 0) .. "%")
    self.def_buff:setString((self.property_add.def or 0) .. "%")
    self.speed_buff:setString((self.property_add.speed or 0) .. "%")
end
function game_pirate_map.resetPlayerAnimPosition(self,pos)
    if self.m_playerAnimNode then
        self.m_playerAnimNode:setPosition(ccp(pos.x + self.m_tiledW,pos.y + self.m_tiledH));
        self.m_mapLayer:setPosition(ccp(-pos.x+self.m_visibleSize.width*0.5,-pos.y+self.m_visibleSize.height*0.5));
    end
end
--[[
    刷新回调接口
    类似初始化数据
]]
function game_pirate_map.refreshData(self,t_params)
   t_params = t_params or {};
    self.m_buildingTable = {};
    self.m_touchRef = 0;
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.property_add = self.m_tGameData.property_add
        self.treasure = self.m_tGameData.treasure
        self.city = self.m_tGameData.city
        self.heal_times = self.m_tGameData.heal_times
        self.total_hp = self.m_tGameData.total_hp
        self.alignment = self.m_tGameData.alignment
        self.die = self.m_tGameData.die
        self.city = self.m_tGameData.city
        self.recapture_log = self.m_tGameData.recapture_log or {}
        self.regain_reward = self.m_tGameData.regain_reward or {}
        self.total_hp_rate = self.m_tGameData.total_hp_rate or 100
    else
        self.m_tGameData = {};
    end
    self.m_buildingClickFlag = false;
    self.m_moveFlag = true;
    self.m_landItemTab = {};
   self:refreshUi() 
end
--[[--
    初始化
]]
function game_pirate_map.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingTable = {};
    self.m_touchRef = 0;
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.property_add = self.m_tGameData.property_add
        self.treasure = self.m_tGameData.treasure
        self.city = self.m_tGameData.city
        self.heal_times = self.m_tGameData.heal_times
        self.total_hp = self.m_tGameData.total_hp
        self.alignment = self.m_tGameData.alignment
        self.die = self.m_tGameData.die
        self.recapture_log = self.m_tGameData.recapture_log or {}
        self.regain_reward = self.m_tGameData.regain_reward or {}
        self.total_hp_rate = self.m_tGameData.total_hp_rate or 100
        cclog2(self.total_hp_rate,"self.total_hp_rate")
    else
        self.m_tGameData = {};
    end
    self.m_buildingClickFlag = false;
    self.m_moveFlag = true;
    self.m_landItemTab = {};
    self.callBackFunc = t_params.callBackFunc
    self.reward = t_params.reward
    self.tipText = t_params.tipText
end

--[[--
    创建入口
]]
function game_pirate_map.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    -- self:openBuildingDetailPop();
    -- self:showMainSceneTips();
    return rootScene;
end
return game_pirate_map;