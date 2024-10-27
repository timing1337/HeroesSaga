---  城市地图

local game_small_map_scene = {
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
    m_recoverBuildingId = nil;
    m_touchRef = nil;
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
    m_mapGuideID = nil,
    m_guideBuildingID = nil,
};

local building_offset = require("building_offset");

local map_info_data = {
    w = 0,
    h = 0,
    data = nil,
}

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

function map_info_data:get_fog( x,y )
    -- data
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
        if(ty>=self.w)then
            ty=self.w;
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
                            if(self.data[theY*self.w+theX+1]>0)then
                                return 0;
                            end
                        end
                    end
                end
            end
            return -1;
        end
        local temp = self.data[ty*self.w+tx+1];
        if temp==0 then
            temp = -1;
        elseif temp==2 then
            temp = 1;
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
    elseif md==-1 then
        local temp = {'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png'}
        return temp;
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
    local temp = {'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png',
                    'shi.png','shi.png','shi.png','shi.png'}
    if (lt_md==-1 or l_md==-1 or t_md==-1) then             -- 上角
        temp[1],temp[2],temp[5],temp[6] = 'shi.png','shi.png','shi.png','shi.png';
    end
    if (t_md==-1 or rt_md==-1 or r_md==-1) then             -- 右角
        temp[3], temp[4], temp[7], temp[8] = 'shi.png','shi.png','shi.png','shi.png';
    end
    if (l_md==-1 or lb_md==-1 or b_md==-1) then             -- 左角
        temp[9], temp[10], temp[13], temp[14] = 'shi.png','shi.png','shi.png','shi.png';
    end
    if (b_md==-1 or rb_md==-1 or r_md==-1) then             -- 下角
        temp[11], temp[12], temp[15], temp[16] = 'shi.png','shi.png','shi.png','shi.png';
    end
    if (l_md==1 and t_md==1) then                                       -- 上角
        temp[1] = 'bt1_down.png';
        temp[2] = 'bt2_left_down.png';
        temp[5] = 'bt2_right_down.png';
        temp[6] = 'shi1_down.png';
    elseif (l_md==1 and t_md==0) then
        temp[1] , temp[5] = 'bt2_right_down.png','bt2_right_down.png';
        temp[2] , temp[6] = 'shi2_right_down.png','shi2_right_down.png';
    elseif (l_md==0 and t_md==1) then
        temp[1] , temp[2] = 'bt2_left_down.png','bt2_left_down.png';
        temp[5] , temp[6] = 'shi2_left_down.png','shi2_left_down.png';
    elseif (l_md==0 and t_md==0 and lt_md==1) then
        temp[1] = 'bt3_down.png';
        temp[2] = 'shi2_right_down.png';
        temp[5] = 'shi2_left_down.png';
        temp[6] = 'shi3_down.png';
    end

    if (t_md==1 and r_md==1) then                                       -- 右角
        temp[3] = 'bt2_left_down.png';
        temp[4] = 'bt1_left.png';
        temp[7] = 'shi1_left.png';
        temp[8] = 'bt2_left_up.png';
    elseif (t_md==1 and r_md==0) then
        temp[3] , temp[4] = 'bt2_left_down.png','bt2_left_down.png';
        temp[7] , temp[8] = 'shi2_left_down.png','shi2_left_down.png';
    elseif (t_md==0 and r_md==1) then
        temp[3] , temp[7] = 'shi2_left_up.png','shi2_left_up.png';
        temp[4] , temp[8] = 'bt2_left_up.png','bt2_left_up.png';
    elseif (t_md==0 and r_md==0 and rt_md==1) then
        temp[3] = 'shi2_left_up.png';
        temp[4] = 'bt3_left.png';
        temp[7] = 'shi3_left.png';
        temp[8] = 'shi2_left_down.png';
    end

    if (r_md==1 and b_md==1) then                                       -- 下角
        temp[11] = 'shi1_up.png';
        temp[12] = 'bt2_left_up.png';
        temp[15] = 'bt2_right_up.png';
        temp[16] = 'bt1_up.png';
    elseif (r_md==1 and b_md==0) then
        temp[11] , temp[15] = 'shi2_left_up.png','shi2_left_up.png';
        temp[12] , temp[16] = 'bt2_left_up.png','bt2_left_up.png';
    elseif (r_md==0 and b_md==1) then
        temp[11] , temp[12] = 'shi2_right_up.png','shi2_right_up.png';
        temp[15] , temp[16] = 'bt2_right_up.png','bt2_right_up.png';
    elseif (r_md==0 and b_md==0 and rb_md==1) then
        temp[11] = 'shi3_up.png';
        temp[12] = 'shi2_right_up.png';
        temp[15] = 'shi2_left_up.png';
        temp[16] = 'bt3_up.png';
    end

    if (b_md==1 and l_md==1) then                                       -- 左角
        temp[9] = 'bt2_right_down.png';
        temp[10] = 'shi1_right.png';
        temp[13] = 'bt1_right.png';
        temp[14] = 'bt2_right_up.png';
    elseif (b_md==1 and l_md==0) then
        temp[9] , temp[10] = 'shi2_right_up.png','shi2_right_up.png';
        temp[13] , temp[14] = 'bt2_right_up.png','bt2_right_up.png';
    elseif (b_md==0 and l_md==1) then
        temp[9] , temp[13] = 'bt2_right_down.png','bt2_right_down.png';
        temp[10] , temp[14] = 'shi2_right_down.png','shi2_right_down.png';
    elseif (b_md==0 and l_md==0 and lb_md==1) then
        temp[9] = 'shi2_right_up.png';
        temp[10] = 'shi3_right.png';
        temp[13] = 'bt3_right.png';
        temp[14] = 'shi2_right_down.png';
    end
    return temp;
end

--[[--
    销毁
]]
function game_small_map_scene.destroy(self)
    cclog("-----------------game_small_map_scene destroy-----------------");
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
    self.m_maskLayer = nil;
    self.m_mask_node = nil;
    self.m_selCityId = nil;
    self.m_recoverBuildingId = nil;
    self.m_touchRef = nil;
    self.m_progress_rate_label = nil;
    self.m_recover_node = nil;
    self.m_recover_anim_over = nil;
    self.m_buildingClickFlag = nil;
    self.m_scroll_view = nil;
    self.m_playerAnimNode = nil;
    self.m_guideBuilding = nil;
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
    self.m_mapGuideID = nil;
end

--[[--
    返回
]]
function game_small_map_scene.back(self,type)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("map_world_scene",{gameData = gameData});
        self:destroy();
        self.m_tempMapPostion = nil;
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
end

--[[--
    初始化地图
]]
function game_small_map_scene.initMap(self)
    local smallItemCount = 4;
    -- body
    local earthLayer = self.m_tiledMap:layerNamed("earth"); 
    self.m_landItemCountX = 0;          -- 4*4大格子宽
    self.m_landItemCountY = 0;          -- 4*4大格子高
    local gameData = game_data:getSelCityData();
    local landData = gameData["land"]

    if self.m_isHard_allRegain and gameData["land"] then
        for i,v in ipairs(gameData["land"]) do
            for j,vj in ipairs(v) do
                gameData["land"][i][j][1] = 1
            end
        end
    end

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
        -- body
        -- cclog('------------get_value(%f,%f)',x,y);
        if(x<0 or x>=landDataXCount or y<0 or y>=self.m_landItemCountY)then
            return -1;
        end
        local temp =  landData:getNodeAt(y):getNodeAt(x):getNodeAt(0):toInt();
        -- cclog('----------%d',temp);
        return temp;
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("roadblock.plist");
    for i=1,self.m_landItemCountY do
        landDataX = landData[i]
        landDataXCount = #landDataX
        self.m_landItemCountX = math.max(landDataXCount,self.m_landItemCountX);
        for j=1,landDataXCount do
            landItem = landDataX[j];
            -- cclog(" i =================" .. i .. " ; j ==============" .. j);
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
                    -- mapItem:setColor(ccc3(0,255,0));
                    if buildingIconName ~= nil and buildingIconName ~= "" then
                        self:createBuilding(earthLayer,ccp((j-1)*smallItemCount,(i-1)*smallItemCount),buildingIconName,landItem,buildingId,landItemOpenType);
                    end
                end
            end
            --[[--
            -- 添加围栏
            if landItemOpenType == 1 then
                local tmeps = nil;
                local x = 0;
                local y = 0;
                local roadblock = nil;
                if(get_value(j-2,i-1) ~= 1)then     --左上有栏杆
                    mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount,(i-1)*smallItemCount+1));
                    if mapItem then
                    roadblock = "left" .. tostring(math.random(6)) .. ".png";
                    temps = CCSprite:createWithSpriteFrameName(roadblock);
                    x,y = mapItem:getPosition();
                    -- x = x+self.m_tiledW/2
                    y = y+self.m_tiledH/2
                    temps:setPosition(ccp(x,y));
                    self.m_buildingNatchNode:addChild(temps,-y,0);
                    end
                end
                if(get_value(j-1,i-2) ~= 1)then     --右上有栏杆
                    mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+1,(i-1)*smallItemCount));
                    if mapItem then
                    roadblock = "right" .. tostring(math.random(6)) .. ".png";
                    temps = CCSprite:createWithSpriteFrameName(roadblock);
                    x,y = mapItem:getPosition();
                    x = x+self.m_tiledW
                    y = y+self.m_tiledH/2
                    temps:setPosition(ccp(x,y));
                    self.m_buildingNatchNode:addChild(temps,-y,0);
                    end
                end
                if(get_value(j-1,i) ~= 1)then       --左下有栏杆
                    mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+1,(i-1)*smallItemCount+3));
                    if mapItem then
                    roadblock = "right" .. tostring(math.random(6)) .. ".png";
                    temps = CCSprite:createWithSpriteFrameName(roadblock);
                    x,y = mapItem:getPosition();
                    x = x+self.m_tiledW/2
                    -- y = y+self.m_tiledH/2
                    temps:setPosition(ccp(x,y));
                    self.m_buildingNatchNode:addChild(temps,-y,0);
                    end
                end
                if(get_value(j,i-1) ~= 1)then       --右下有栏杆
                    mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+3,(i-1)*smallItemCount+1));
                    if mapItem then
                    roadblock = "left" .. tostring(math.random(6)) .. ".png";
                    temps = CCSprite:createWithSpriteFrameName(roadblock);
                    x,y = mapItem:getPosition();
                    x = x+self.m_tiledW/2
                    -- y = y+self.m_tiledH/2
                    temps:setPosition(ccp(x,y));
                    self.m_buildingNatchNode:addChild(temps,-y,0);
                    end
                end
            end
            ]]
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
    -- local mm = require "shared.util";
    -- mm.printf(map_info_data.data);
    -- 云层
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("fog.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bb_cloud.plist");
    -- local m_fogNatchNode = CCSpriteBatchNode:create("fog.png");
    -- self.m_mapLayer:addChild(m_fogNatchNode);
    local ptx,pty = 0,0;
    local sprint = nil;
    local img = nil;
    local imgname = nil;
    cclog("map info data w:" .. tostring(map_info_data.w) .. 'h:' .. tostring(map_info_data.h));
    for i=1 , map_info_data.h do
        for j=1,map_info_data.w do
            -- 建筑物迷雾
            -- img = map_info_data:get_fog(j-1,i-1);
            -- for dv=1,16 do
            --     imgname = img[dv];
            --     if(imgname ~= '')then
            --         mapItem = earthLayer:tileAt(ccp((j-1)*smallItemCount+math.floor((dv-1)%4),(i-1)*smallItemCount+math.floor((dv-1)/4)));
            --         if(mapItem~=nil)then
            --             ptx,pty = mapItem:getPosition();
            --             sprint = CCSprite:createWithSpriteFrameName(imgname);
            --             sprint:setColor(ccc3(0,0,0));
            --             sprint:setPosition(ccp(ptx+self.m_tiledW*0.5,pty+self.m_tiledH*0.5));
            --             self.m_fogNatchNode:addChild(sprint);
            --         end
            --     end
            -- end
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

    cclog("self.m_landItemCountX ===" .. self.m_landItemCountX .. " ; self.m_landItemCountY = " .. self.m_landItemCountY);
    -- local removeFlag = false;
    -- for i=1,20 do
    --     if i <= self.m_landItemCountX then
    --         removeFlag = false;
    --     else
    --         removeFlag = true;
    --     end
    --     for j=1,20 do
    --         if removeFlag or ((not removeFlag) and j > self.m_landItemCountY) then
    --             earthLayer:removeTileAt(ccp(i-1,j-1));
    --          end
    --     end
    -- end
    local value = self.m_landItemCountX*smallItemCount + self.m_landItemCountY*smallItemCount;
    self.m_realMapSize = CCSizeMake(value*self.m_tiledW*0.5,value*self.m_tiledH*0.5);
    cclog("self.m_realMapSize width = " .. self.m_realMapSize.width .. " height = " .. self.m_realMapSize.height);

    self.m_realMapSizeEndPos = ccp((-self.m_mapSize.width*0.5 - self.m_tiledW*0.5*value*0.5) * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    cclog("self.m_realMapSizeEndPos  x==" .. self.m_realMapSizeEndPos.x .. " ; y ==" .. self.m_realMapSizeEndPos.y);
    self.m_realMapSizeStartPos = ccp((self.m_realMapSizeEndPos.x + self.m_realMapSize.width) * self.m_mapScale,(self.m_realMapSizeEndPos.y + self.m_realMapSize.height) * self.m_mapScale);
    cclog("self.m_realMapSizeStartPos  x==" .. self.m_realMapSizeStartPos.x .. " ; y ==" .. self.m_realMapSizeStartPos.y);
    cclog("self.m_visibleSize  width==" .. self.m_visibleSize.width .. " ; height ==" .. self.m_visibleSize.height);
    if self.m_tempMapPostion then
        self.m_mapLayer:setPosition(self.m_tempMapPostion);
    end
    self.m_scroll_view:setContentSize(self.m_realMapSize);
end

--[[--
    创建建筑的方法
]]
function game_small_map_scene.createBuilding(self,earthLayer,pos,buildingIconName,landItem,buildingId,landItemOpenType)
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
            -- building_icon = game_util:createImpactAnim(buildingIconName,1.0)
            building_icon = CCSprite:create("icon/" .. buildingIconName .. ".png");
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
        if(landItemOpenType ~= 1) and not self.m_isHard_allRegain then       -- 建筑物阴影
            building_icon:setColor(ccc3(70,70,70));
            -- print("建筑物阴影  === landItemOpenType   === ", landItemOpenType)
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
        local mapConfig = getConfig(game_config_field.map_title_detail);
        local buildingCfgData = mapConfig:getNodeWithKey(tostring(buildingId));
        if buildingCfgData and buildingId > 0 then
            local time = 0.75 + 0.05*math.random(0,3)
            if landItemOpenType == 2 then
                local loot_show = buildingCfgData:getNodeWithKey("loot_show"):toStr();
                if loot_show == "" then
                    loot_show = "jiaozhan";
                end
                -- local impactAnim = game_util:createImpactAnim(loot_show,1.0)
                local impactAnim = CCSprite:create("icon/i_build_" .. loot_show .. ".png");
                if impactAnim then
                    local pX,pY = buildsize.width/2,buildsize.height/2+20;--building_icon:getPosition();
                    impactAnim:setPosition(ccp(pX,pY));
                    impactAnim:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveTo:create(time,ccp(pX,pY)),CCMoveTo:create(time,ccp(pX,pY+5)))));
                    building_icon:addChild(impactAnim,100,100);
                end
                if self.m_guideBuilding == nil then
                    self.m_guideBuildingID = tostring(buildingId)
                    self.m_guideBuilding = building_icon;
                else
                    if self.m_guideBuilding:getPositionY() > building_icon:getPositionY() then
                        self.m_guideBuildingID = tostring(buildingId)
                        self.m_guideBuilding = building_icon;
                    end
                end
            elseif landItemOpenType == 1 then--再次战斗的奖励
                local after_show = buildingCfgData:getNodeWithKey("after_show"):toStr();
                if after_show ~= "" then
                    -- local impactAnim = game_util:createImpactAnim(after_show,1.0)
                    local impactAnim = CCSprite:create("icon/i_build_" .. after_show .. ".png");
                    if impactAnim then
                        local pX,pY = buildsize.width/2,buildsize.height/2+20;--building_icon:getPosition();
                        impactAnim:setPosition(ccp(pX,pY));
                        impactAnim:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveTo:create(time,ccp(pX,pY)),CCMoveTo:create(time,ccp(pX,pY+5)))));
                        building_icon:addChild(impactAnim,101,101);
                    end
                end
            end
            if self.m_recoverBuildingId == tostring(buildingId) and game_data:getReMapBattleFlag() == false then
                local animFile = "anim_jianzhu_faguang1";
                local title_x = buildingCfgData:getNodeWithKey("title_x"):toInt();
                local title_y = buildingCfgData:getNodeWithKey("title_y"):toInt();
                if title_x == 1 and title_y == 2 then
                    animFile = "anim_jianzhu_faguang2";
                elseif title_x == 2 and title_y == 1 then
                    animFile = "anim_jianzhu_faguang3";
                elseif title_x == 2 and title_y == 2 then
                    animFile = "anim_jianzhu_faguang4";
                end
                local function callBackFunc()
                    if game_data:getMapType() ~= "normal" then
                        return;
                    end
                    -- building_icon:setOpacity(255);
                    local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
                    if tempParticle then
                        local function particleMoveEndCallFunc()
                            cclog("tempParticle particleMoveEndCallFunc --------------------------")
                        end
                        local tempX,tempY = self.m_mapLayer:getPosition();
                        local pX = realPos.x + buildsize.width*0.5 + tempX
                        local pY = realPos.y + buildsize.height*0.5 + tempY
                        game_util:addMoveAndRemoveAction({node = tempParticle,startPos = ccp(pX, pY),endNode = self.m_achieve_btn,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                        game_scene:getPopContainer():addChild(tempParticle)
                    end
                end
                local tempAnim = game_util:createEffectAnimCallBack(animFile,1.0,false,callBackFunc);
                cclog("self.m_recoverBuildingId ===== " .. tostring(self.m_recoverBuildingId) .. " ; tempAnim == " .. tostring(tempAnim))
                if tempAnim then
                    game_sound:playUiSound("jianzhu")
                    tempAnim:setAnchorPoint(ccp(0.5,0));
                    tempAnim:setPositionX(buildsize.width*0.5);
                    building_icon:addChild(tempAnim)
                    -- building_icon:setOpacity(0);
                end
            end
        end
        self.m_buildingTable[pos.x .. "-" .. pos.y] = {building_icon=building_icon,fileName = tempName};
        if buildingId < 0 then
            building_icon:setColor(ccc3(155,155,155));
        end
    end
end

function game_small_map_scene.resetPlayerAnimPosition(self,pos)
    if self.m_playerAnimNode then
        self.m_playerAnimNode:setPosition(ccp(pos.x + self.m_tiledW,pos.y + self.m_tiledH));
        self.m_mapLayer:setPosition(ccp(-pos.x+self.m_visibleSize.width*0.5,-pos.y+self.m_visibleSize.height*0.5));
    end
end


--[[--
    重置地图的位置
]]
function game_small_map_scene.resetMapPosition(self,cx,cy)
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
function game_small_map_scene.createUi(self)
    -- body
    local data = game_data:getSelCityData();
    if self.m_isHard_allRegain and data["land"] then
        for i,v in ipairs(data["land"]) do
            -- data["land"][i][1] = 1
            for j,vj in ipairs(v) do
                data["land"][i][j][1] = 1
            end
        end
    end

    self.m_selCityId = tostring(data.city);
    game_data:setSelCityId(self.m_selCityId);
    game_data:setDataByKeyAndValue("ToAdjustBuildLastStep", nil)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            if game_data.getGuideProcess and game_data:getGuideProcess() == "first_battle_mine" then
               if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(27) end -- 点击返回世界地图 步骤27
            end
            self:back();
        elseif btnTag == 2 then --宝箱 
            --宝箱 city=
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data");
            --     local tempData = game_data:getSelCityData();
            --     local curt_regain = tempData.curt_regain
            --     local function callBackFunc()
            --         if self.m_rate_anim then
            --             self.m_rate_anim:removeFromParentAndCleanup(true);
            --             self.m_rate_anim = nil;
            --         end
            --     end
            --     game_scene:addPop("game_treasure_chest_pop",{parentNode = game_scene:getPopContainer(),cityId = self.m_selCityId,curt_regain = curt_regain,gameData=gameData,callBackFunc=callBackFunc})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gift_curt_city_gift"), http_request_method.GET, {city=self.m_selCityId},"gift_curt_city_gift")

            local function responseMethod(tag,gameData)
                -- cclog("reward_index data = " .. gameData:getNodeWithKey("data"):getFormatBuffer());
                game_scene:enterGameUi("game_offer",{gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())})
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, {},"reward_index");  
        elseif btnTag == 4 then --返回基地
            self:back();
        elseif btnTag == 5 then--世界成就
            local function responseMethod(tag,gameData)
                game_scene:addPop("word_achieve_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_score"), http_request_method.GET, nil,"private_city_world_score")
        elseif btnTag == 11 then --撤退
            self:back();
        elseif btnTag == 12 then --背包
            game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "game_small_map_scene",showIndex= 1});
            self:destroy();
        elseif btnTag == 13 then --队伍
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_small_map_scene"});
            self:destroy();
        elseif btnTag == 100 then--装备
            game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_small_map_scene",showIndex= 1});
            self:destroy();
        elseif btnTag == 1033 then
            print("show tips ------")
            if self.m_doSthFun then self.m_doSthFun() end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_small_map.ccbi");
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    local root_map_node = tolua.cast(ccbNode:objectForName("root_map_node"), "CCNode");
    self.m_mask_node = tolua.cast(ccbNode:objectForName("m_mask_node"), "CCNode");
    self.m_scroll_view = ccbNode:scrollViewForName("m_scroll_view")
    self.m_progress_rate_label = tolua.cast(ccbNode:objectForName("m_progress_rate_label"), "CCLabelTTF");
    self.m_rate_btn = ccbNode:controlButtonForName("m_rate_btn")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_achieve_btn = ccbNode:controlButtonForName("m_achieve_btn")
    self.m_conbtn_dosth = ccbNode:controlButtonForName("m_conbtn_dosth")
    
    if game_data:getCurrChapterTypeName() == "difficult" then
        self.m_achieve_btn:setVisible(false);
    else
        local expBar = ExtProgressTime:createWithFrameName("public_diban.png","public_tili.png");
        expBar:setScale(0.6);
        local tempSize = self.m_achieve_btn:getContentSize();
        expBar:setPosition(ccp(0, -tempSize.height*0.15));
        self.m_achieve_btn:addChild(expBar);
        game_util:setWordAchieve(self.m_achieve_btn,expBar,data.world_level,data.world_score);
    end

    local city = game_data:getSelCityId()
    -- cclog("city == " .. city)
    if tostring(city) == "101" or tostring(city) == "100" or game_data:getCurrChapterTypeName() == "difficult" then
        self.m_rate_btn:setVisible(false)
    else
        local wanted = data.wanted or 0;
        if wanted == 1 then
            game_util:addTipsAnimByType(self.m_rate_btn,11);
        end
    end
    -- local curt_gift_count = #data.curt_gift
    -- if curt_gift_count > 0 then
    --     self.m_rate_anim = game_util:addTipsAnimByType(self.m_rate_btn,2);
    -- end
    local curt_regain = data.curt_regain or 0
    if curt_regain then
        self.m_progress_rate_label:setString(curt_regain .. "%");
        if curt_regain == 100 and self.m_recoverBuildingId and game_data:getReMapBattleFlag() == false or self.m_isHard_allRegain then
            self.m_recover_node = self:createBuildingRecoverAnim();
            -- ccbNode:addChild(self.m_recover_node);
            game_scene:getPopContainer():addChild(self.m_recover_node,10,10);
            if game_data_statistics then
                game_data_statistics:recoverCity({cityId = self.m_selCityId})
            end
        else
            self:createBuildingRecoverPop();
        end
    end
	local testLayer = CCLayer:create();
    root_map_node:addChild(testLayer);
    -- self.m_scroll_view:addChild(testLayer)
    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(self.m_selCityId)):toStr();
    local map_main_story_cfg_item = map_main_story_cfg:getNodeWithKey(cityOrderId);
    local tmx = map_main_story_cfg_item:getNodeWithKey("tmx"):toStr();
    cclog(" map_main_story_cfg_item  tmx === " .. tmx);
    if tmx == "" then
        self.m_tiledMap = CCTMXTiledMap:create("building_img/sinjiapo.tmx")
    else
        self.m_tiledMap = CCTMXTiledMap:create("building_img/" .. tmx)
    end
    if self.m_tiledMap == nil then
        game_util:addMoveTips({text = string.format(string_helper.game_small_map_scene.map_file,tostring(tmx))});
        return ccbNode;
    end
    local scaleFactor = display.contentScaleFactor;
    -- cclog("getMapSize width  = " .. self.m_tiledMap:getMapSize().width .. " ; height = " .. self.m_tiledMap:getMapSize().height);
    -- cclog("getTileSize width  = " .. self.m_tiledMap:getTileSize().width .. " ; height = " .. self.m_tiledMap:getTileSize().height);
    self.m_tiledW = self.m_tiledMap:getTileSize().width/scaleFactor;
    self.m_tiledH = self.m_tiledMap:getTileSize().height/scaleFactor;
    cclog("self.m_tiledW = " .. self.m_tiledW .. " ; self.m_tiledH = " .. self.m_tiledH );
    self.m_mapSize = CCSizeMake(self.m_tiledMap:getMapSize().width*self.m_tiledW,self.m_tiledMap:getMapSize().height*self.m_tiledH);
    self.m_realMapSizeStartPos = ccp(0,0);
    self.m_realMapSizeEndPos = ccp(- self.m_mapSize.width * self.m_mapScale,- self.m_mapSize.height * self.m_mapScale);
    cclog("self.m_mapSize width = " .. self.m_mapSize.width .. "; height = " .. self.m_mapSize.height);
    local earthLayer = self.m_tiledMap:layerNamed("earth");
    
    self.m_visibleSize = CCDirector:sharedDirector():getVisibleSize();
	self.m_mapLayer = CCLayerColor:create(ccc4(0,0,0,255),self.m_mapSize.width,self.m_mapSize.height*2);
    self.m_mapLayer:ignoreAnchorPointForPosition(false);
    self.m_mapLayer:setAnchorPoint(ccp(0,0));
	testLayer:addChild(self.m_mapLayer);
    self.m_mapLayer:setPosition(- self.m_mapSize.width*0.5 * self.m_mapScale + self.m_visibleSize.width - self.m_tiledW *0.5 , - self.m_mapSize.height * self.m_mapScale + self.m_visibleSize.height);

    -- self.m_mapLayer:setPosition(0,0);
    cclog("self.m_mapLayer init pos x = " .. (- self.m_mapSize.width*0.5 + self.m_visibleSize.width*0.5) .. " ; y = " .. - self.m_mapSize.height + self.m_visibleSize.height);
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

    -- 外围迷雾
    tempDic = CCDictionary:createWithContentsOfFile("da_yun.plist");
    tempTName = tolua.cast(tempDic:objectForKey("metadata"),"CCDictionary"):valueForKey("realTextureFileName"):getCString();
    self.m_cloudLayer = CCSpriteBatchNode:create(tempTName);
    self.m_mapLayer:addChild(self.m_cloudLayer);

    self.m_buildingNatchNode = CCNode:create()--CCSpriteBatchNode:create("building_icon-hd.pvr.ccz")
    self.m_mapLayer:addChild(self.m_buildingNatchNode)

    self.m_mapLayer:setScale(self.m_mapScale);

    self.m_playerAnimNode = game_util:createOwnRoleAnim();
    if self.m_playerAnimNode then
        self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
        self.m_buildingNatchNode:addChild(self.m_playerAnimNode,1000,1000)
    end

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
                local landItem =self.m_landItemTab[selectBuilding:getTag()].landItem
                local landItemOpenType = landItem[1]
                -- if self.m_isDifficult == "yes" and landItemOpenType == 1 then
                if self.m_isHard_allRegain or (game_data:getMapType() == "hard" and landItemOpenType == 1) then
                    return;
                end
                local buildingId = tonumber(landItem[2]);
                local buildingIconName = landItem[3]
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
    testLayer:registerScriptTouchHandler(onTouch,false,2,true)--多点触摸
    testLayer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    
]]
function game_small_map_scene.createBuildingRecoverPop( self )
    if self.m_reward and self.m_recoverBuildingId then
        -- game_scene:addPop("building_recover_pop",{reward = self.m_reward,recoverBuildingId = self.m_recoverBuildingId})
        game_util:rewardTipsByDataTable(self.m_reward);
    end
end
--[[--
    创建收复动画
]]
function game_small_map_scene.createBuildingRecoverAnim( self )
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
            local id = game_guide_controller:getCurrentId();
            cclog("id ============= " .. id .. " ; self.m_back_btn == " .. tostring(self.m_back_btn))
            if id == 7 or id == 8 or id == 10 then
                game_guide_controller:gameGuide("show","1",11,{tempNode = self.m_back_btn})
                game_guide_controller:gameGuide("send","1",11);
            elseif id == 28 then
                game_guide_controller:gameGuide("show","2",29,{tempNode = self.m_back_btn})
            end
        end
    end

    local function playAnimEnd(animName)
        self.m_recover_anim_over = true;
        removeRecoverNode();
    end
    ccbNode:registerAnimFunc(playAnimEnd);
    ccbNode:runAnimations("recover_anim");
    local function onTouch(eventType, x, y)
        -- if self.m_recover_anim_over == false then
        --     return true;
        -- end
        if eventType == "began" then
            removeRecoverNode();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    ccbNode:runAnimations("recover_anim");
    return ccbNode;
end

--[[--
    创建云层
]]
function game_small_map_scene.createCloudLayer( self )
    -- body
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("da_yun.plist");
    -- local cloudLayer = CCLayer:create();        -- 云层
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
    cclog("-------------云地块大小------" .. tostring(self.m_landItemCountX) .. "  " .. tostring(self.m_landItemCountY));
    for i=1,self.m_landItemCountY do
        tempItem = earthLayer:tileAt(ccp(0,(i-1)*smallItemCount+2));
        if tempItem ~= nil then

            tempx,tempy = tempItem:getPosition();
            tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
            tempsprite:setColor(ccc3(0,0,0));
            tempsprite:runAction(create_action(tempx,tempy));
            tempsprite:setPosition(ccp(tempx,tempy));
            self.m_cloudLayer:addChild(tempsprite);
            tempItem = earthLayer:tileAt(ccp(self.m_landItemCountX*smallItemCount-1,(i-1)*smallItemCount+2));
            if tempItem ~= nil then
                tempx,tempy = tempItem:getPosition();
                tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
                tempsprite:setColor(ccc3(0,0,0));
                tempsprite:setFlipX(true);
                tempsprite:setFlipY(true);
                tempsprite:runAction(create_action(tempx,tempy));
                tempsprite:setPosition(ccp(tempx,tempy));
                self.m_cloudLayer:addChild(tempsprite);
            end
        end
    end

    for i=1,self.m_landItemCountX do
        tempItem = earthLayer:tileAt(ccp((i-1)*smallItemCount+2,0));
        -- tempItem = earthLayer:tileAt(ccp(i,i));
        if tempItem ~= nil then
            tempx,tempy = tempItem:getPosition();
            tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
            tempsprite:setColor(ccc3(0,0,0));
            tempsprite:runAction(create_action(tempx,tempy));
            tempsprite:setFlipX(true);
            tempsprite:setPosition(ccp(tempx,tempy));
            self.m_cloudLayer:addChild(tempsprite);
            tempItem = earthLayer:tileAt(ccp((i-1)*smallItemCount+2,self.m_landItemCountY*smallItemCount-1));
            if tempItem ~= nil then
                tempx,tempy = tempItem:getPosition();
                tempsprite = CCSprite:createWithSpriteFrameName("big_yun1.png");
                tempsprite:setColor(ccc3(0,0,0));
                tempsprite:runAction(create_action(tempx,tempy));
                tempsprite:setFlipY(true);
                tempsprite:setPosition(ccp(tempx,tempy));
                self.m_cloudLayer:addChild(tempsprite);
            end
        else
            cclog("---------------这里他妈的没有-------" .. tostring(i));
        end
    end
    -- self.m_mapLayer:addChild(cloudLayer);
end

--[[--
    自动战斗
]]
function game_small_map_scene.autoBattleCallFunc(self)
    if self.m_autoFlag then return end
    local combatValue = game_util:getCombatValue();
    local action_point = game_data:getUserStatusDataByKey("action_point") or 0
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_selBuildingId));
    if buildingCfgData then
        -- local fight_num = buildingCfgData:getNodeWithKey("fight_num"):toInt();
        -- if combatValue < fight_num then
            -- game_util:addMoveTips({text = string.format(string_config.m_combat_is_not_enough,fight_num),colorType = "red"});
            -- return;
        -- end
        local fight_list_count = buildingCfgData:getNodeWithKey("fight_list"):getNodeCount();
        local tempValue = buildingCfgData:getNodeWithKey("action_point"):toInt();
        local need_action_point = fight_list_count * tempValue;
        cclog("action_point ========" .. action_point .. " ; need_action_point ==" .. need_action_point .. " ;fight_list_count ==" .. fight_list_count)

        local function battleFunc()
            local responseMethod = function(tag,gameData)
                if gameData == nil then
                    self.m_autoFlag = false;
                    return;
                end
                game_util:setPlayerPropertyByCCBAndTableData2(self.m_ccbNode)
                game_data:addSelCitySweepLogDataByBuildingId(self.m_selBuildingId);
                self.m_autoFlag = false;
                local function callFunc(btnTag)
                    cclog("btnTag ================== " .. btnTag);
                    if btnTag == 3 then
                        self:autoBattleCallFunc();
                    end
                end
                game_scene:addPop("auto_battle_over_pop",{gameData = gameData,callFunc = callFunc,returnType = returnType,buildingId = self.m_selBuildingId})
            end
            local params = {};
            params.city = self.m_selCityId;
            params.building = self.m_selBuildingId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_auto_recapture"), http_request_method.GET, params,"private_city_auto_recapture",true,true)
        end
        if need_action_point > action_point then
            -- game_util:addMoveTips({text = string_config.m_action_point_not_enough});
            --换成统一的提示
            local t_params = 
            {
                m_openType = 3,
                m_call_func = function()
                    game_util:setPlayerPropertyByCCBAndTableData2(self.m_ccbNode);
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        -- elseif game_data:getAvailableEquipBackpackNum() < 5 then
        --     local t_params = 
        --     {
        --         m_openType = 2,
        --     }
        --     game_scene:addPop("game_normal_tips_pop",t_params)
        -- elseif game_data:getAvailableCardBackpackNum() < 5 then
        --     local t_params = 
        --     {
        --         m_openType = 1,
        --     }
        --     game_scene:addPop("game_normal_tips_pop",t_params)
        else
            --取当前扫荡次数
            local sweepLogData = game_data:getSelCitySweepLogData();
            self.m_current_sweep = sweepLogData[tostring(self.m_selBuildingId)] or 0;
            -- cclog("self.m_current_sweep == " .. self.m_current_sweep)
            --取最大扫荡次数
            local mapConfig = getConfig(game_config_field.map_title_detail);
            local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_selBuildingId));
            local max_sweep = buildingCfgData:getNodeWithKey("max_sweep"):toInt();

            if max_sweep == self.m_current_sweep then--判断是否满足vip重置条件
                local vipCfg = getConfig(game_config_field.vip);
                local vipLevel = game_data:getVipLevel()
                local itemCfg = vipCfg:getNodeWithKey(tostring(vipLevel))
                local sweep_times = itemCfg:getNodeWithKey("sweep_times"):toInt()

                if sweep_times == 1 then
                    local function responseMethod(tag,gameData)
                        -- cclog("gameData == " .. gameData:getNodeWithKey("data"):getFormatBuffer())
                        --重置数据
                        game_data:setSweepLogData(self.m_selBuildingId,0)
                        -- local sweepLogData = game_data:getSelCitySweepLogData();
                        -- cclog("sweepLogData == " .. sweepLogData[tostring(self.m_selBuildingId)])
                        -- self.m_current_sweep = sweepLogData[tostring(self.m_selBuildingId)] or 0;
                        self.m_current_sweep = 0
                        -- cclog("self.m_current_sweep == " .. self.m_current_sweep)
                    end
                    local payCfg = getConfig(game_config_field.pay)
                    local payItem = payCfg:getNodeWithKey("11")
                    local coin = payItem:getNodeWithKey("coin"):getNodeAt(0):toInt()
                    local params = {}
                    params.city = tostring(self.m_selCityId)
                    params.building = tostring(self.m_selBuildingId)
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clear_sweep_log"), http_request_method.GET, params,"clear_sweep_log")
                            game_util:closeAlertView();
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       
                        text = string_helper.game_small_map_scene.cost .. coin .. string_helper.game_small_map_scene.diamond_side,      
                    }
                    game_util:openAlertView(t_params);
                else
                    game_util:addMoveTips({text = string_helper.game_small_map_scene.day_out});
                end
            else
                game_data:setUserStatusDataBackup();
                self.m_autoFlag = true;
                battleFunc();
            end
        end
    end
end

--[[--
    建筑点击的处理
]]
function game_small_map_scene.buildingOnClick(self,buildingId,buildingSpr,landItemOpenType)
    if self.m_guideBuilding then 
        if self.m_mapGuideID == 6 then
            if game_data.setGuideProcess then game_data:setGuideProcess("first_battle_mine") end
            if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(21) end -- 点击第一个建筑 步骤21
        else
            if self.m_guideBuildingID == "101001" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(42) end -- 点击地块 101001 步骤42
                if game_data.setGuideProcess then game_data:setGuideProcess("battle_101001") end
            elseif  self.m_guideBuildingID == "101002" then
                if game_data.setGuideProcess then  game_data:setGuideProcess("battle_101002") end
            end
        end
    end
    self.m_selBuildingId = buildingId;
    if buildingId == 100000 then--返回基地
        self:back();
    else
        if landItemOpenType == 1 then
            game_data:setReMapBattleFlag(true);
        else
            game_data:setReMapBattleFlag(false);
        end
        local function callFunc(callType)
            if callType == "battle" then
                local pX,pY = buildingSpr:getPosition();
                local function moveEndCallFunc()
                    self.m_buildingClickFlag = false;
                    game_scene:runPropertyBarAnim("outer_anim")
                    game_scene:enterGameUi("map_building_detail_scene",{cityId = self.m_selCityId,buildingId = self.m_selBuildingId,next_step = 0, bgMusic=self.m_bgMusic
                                                        });
                    self:destroy();
                end
                game_util:createBuildingPersonAnimMove(self.m_playerAnimNode,ccp(pX + self.m_tiledW,pY + self.m_tiledH),moveEndCallFunc);
            elseif callType == "refresh" then
                self.m_buildingClickFlag = false;
            elseif callType == "autoBattle" then
                self.m_buildingClickFlag = false;
                self:autoBattleCallFunc();
            elseif callType == "tips" then
                game_util:setPlayerPropertyByCCBAndTableData2(self.m_ccbNode);
            else
                self.m_buildingClickFlag = false;
            end
        end

        -- local function responseMethod(tag,gameData)
        --     if gameData == nil then
        --         self.m_buildingClickFlag = false;
        --         return;
        --     end
        --     local data = gameData:getNodeWithKey("data")
        --     game_data:setDataByKeyAndValue("map_fight_and_enemy",json.decode(data:getFormatBuffer()));
            game_scene:removeGuidePop();
            game_scene:addPop("map_building_detail_pop",{cityId = self.m_selCityId,buildingId = self.m_selBuildingId,next_step = 0,callFunc = callFunc,landItemOpenType = landItemOpenType,
             isHardCity = self.m_isDifficult})
        -- end
        -- local params = {};
        -- params.city = self.m_selCityId;
        -- params.building = self.m_selBuildingId;
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_map_fight_and_enemy"), http_request_method.GET, params,"private_city_map_fight_and_enemy",true,true)
    end
end

--[[--
    刷新ui
]]
function game_small_map_scene.openBuildingDetailPop(self)
    if self.m_open_building_id then
        local itemData = self.m_landItemTab[tonumber(self.m_open_building_id)]
        if itemData then
            cclog("self.itemData ==------------- " .. tostring(itemData))
            local landItem =itemData.landItem
            local selectBuilding = itemData.building_icon;
            local landItemOpenType = landItem[1]
            local buildingId = tonumber(landItem[2]);
            local buildingIconName = landItem[3]
            cclog("landItemOpenType == " .. landItemOpenType .. "buildingId == " .. buildingId .. "self.m_buildingClickFlag" .. tostring(self.m_buildingClickFlag))
            if (landItemOpenType == 1 or landItemOpenType == 2) and buildingId > 0 and self.m_buildingClickFlag == false then 
                self.m_buildingClickFlag = true;
                self:buildingOnClick(buildingId,selectBuilding,landItemOpenType);
            end
        end

    end
end

--[[--
    刷新ui
]]
function game_small_map_scene.refreshUi(self)
    -- self:createCloudLayer();
    if self.m_tiledMap == nil then
        return;
    end
    self:initMap();
    self:createCloudLayer();
end
--[[--
    初始化
]]
function game_small_map_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_buildingTable = {};
    self.m_touchRef = 0;

    self.m_isHard_allRegain = nil
    if game_data:getMapType() == "hard" then
        if t_params.hard_recapture and t_params.hard_recapture >= 100 then
            self.m_isHard_allRegain = true
        end
    end

    self.m_open_building_id = t_params.open_building_id
    cclog("self.m_open_building_id ==------------- " .. tostring(self.m_open_building_id))
    -- local is_recaptured = t_params.is_recaptured or true;
    -- if is_recaptured == false then
        self.m_recoverBuildingId = t_params.recoverBuildingId;
    -- end
    self.m_buildingClickFlag = false;
    self.m_selBuildingId = tonumber(t_params.buildingId or -1);
    self.m_bgMusic = t_params.bgMusic or self.m_bgMusic;
    if self.m_bgMusic then
        game_sound:playMusic(self.m_bgMusic,true);
    end
    cclog("self.m_selBuildingId =================================" .. self.m_selBuildingId .. " ; self.m_recoverBuildingId == " .. tostring(self.m_recoverBuildingId))
    self.m_moveFlag = true;
    self.m_reward = t_params.reward
    self.m_landItemTab = {};
    self.m_autoFlag = false;

    if t_params.showDataTips then
        -- print("------- asdf t_params.showDataTips ")
        print_lua_table(t_params.showDataTips, 8)
        self.showDataTips = t_params.showDataTips
    end


    if t_params.isShowDoSthTips then
        self.isShowDoSthTips = true 
    end

    self.m_isDifficult = t_params.isDifficult
    print("t_params.isDifficult ====  ", t_params.isDifficult)
end

--[[--
    创建入口
]]
function game_small_map_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("1");
    cclog("id ====================================" .. id)
    if id == 1 or id == 2 then
        self:gameGuide("drama","1",3)
    elseif id == 4 then
        self:gameGuide("drama","1",5)
    elseif id == 25 or id == 26 then
        self:gameGuide("drama","1",26)
    else
        if self.m_selCityId == "100" or self.m_selCityId == "101" then
            self:setMapPosByGuide(true);
        end
    end
    self:openBuildingDetailPop();
    self:setOriginMapPos();
    if game_data_statistics then
        game_data_statistics:enterCity({cityId = self.m_selCityId})
    end

    -- if self.isShowDoSthTips == true then
        self:showMainSceneTips()
    -- end
    return rootScene;
end
--[[
    设置地图坐标
]]
function game_small_map_scene.setOriginMapPos(self)
    if self.m_open_building_id then
        --获得进入的建筑
        local building_sprite = self.m_landItemTab[tonumber(self.m_open_building_id)].building_icon
        cclog("building_sprite == " .. tostring(building_sprite))
        if building_sprite then
            local mapItemX,mapItemY = building_sprite:getPosition();
            self.m_mapLayer:setPosition(ccp(-mapItemX+self.m_visibleSize.width*0.5,-mapItemY+self.m_visibleSize.height*0.5));
            local animArr = CCArray:create();
            animArr:addObject(CCTintTo:create(1.5,255,0,0))
            animArr:addObject(CCTintTo:create(1.5,255,255,255))
            building_sprite:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
        end
    end
end

--[[
   
]]
function game_small_map_scene.setMapPosByGuide(self,guideFlag,guide_team,guide_id)
    guideFlag = guideFlag == nil and false or guideFlag
    if self.m_guideBuilding then
        self.m_moveFlag = false;
            -- self:gameGuide("show","1",9,{tempNode = self.m_guideBuilding})
        local cx,cy = self.m_mapLayer:getPosition();
        -- cclog("1  cx ======= " .. cx .. " cy ========" .. cy) 
        local mapItemX,mapItemY = self.m_guideBuilding:getPosition();
        self.m_mapLayer:setPosition(ccp(-mapItemX+self.m_visibleSize.width*0.5,-mapItemY+self.m_visibleSize.height*0.5));
        -- self.m_mapLayer:setPosition(ccp(-self.m_realMapSize.width*0.5,-self.m_realMapSize.height*0.5));
        local buildingSize = self.m_guideBuilding:getContentSize();
        local cx,cy = self.m_mapLayer:getPosition();
        -- cclog("2  cx ======= " .. cx .. " cy ========" .. cy) 
        if guideFlag == true then
            game_scene:addGuidePop({startPos = ccp(mapItemX + cx,mapItemY + cy),size = buildingSize})
        else
            self:gameGuide("show",guide_team,guide_id,{startPos = ccp(mapItemX + cx,mapItemY + cy),size = buildingSize})
        end
    end
end

function game_small_map_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "show" then
        game_guide_controller:showGuide(guide_team,guide_id,t_params);
    elseif guideType == "send" then
        game_guide_controller:sendGuideData(guide_team,guide_id)
    elseif guideType == "drama" then
        if guide_team == "1" and id == 3 then
            local function endCallFunc()
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(18) end -- 完成drama1001（起名字之前的drama） 步骤18  
                local function closeCallBack()
                    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(19) end  -- 完成起名字 步骤19  
                    self:gameGuide("send","1",4)
                    self:gameGuide("drama","1",5)
                end
                game_scene:addPop("game_rename_pop",{closeCallBack = closeCallBack})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "1" and id == 5 then
            local function endCallFunc ()
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(20) end -- 完成drama1002（起名字之后的drama） 步骤20 
                self:gameGuide("send","1",5)
                if self.m_guideBuilding then
                    self:setMapPosByGuide(false,"1",6);
                    self.m_mapGuideID = 6
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "1" and id == 26 then
            local function endCallFunc()
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(41) end -- 进入二次战斗 完成drama1006 步骤41
                self:gameGuide("send","1",27)
                if self.m_guideBuilding then
                    self.m_mapGuideID = 27
                    self:setMapPosByGuide(false,"1",27);
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

local callToMainScene = function ()
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
end

local mainSceneTips = 
{
    -- open = {
    --     name = "开服活动", 
    --     infoTitle = "有奖励可以领取", 
    --     icon = {spriteName = "mbutton_m_kaifuhuodong", iconAnimateTag = 7}, 
    --     callFun = callToMainScene, 
    --     isOKFun = function ()  return game_data:getAlertsDataByKey("opening") and game_data:getAlertsDataByKey("opening") ~= ""  end  
    -- }, 
    -- {
    --     name = "日常任务", 
    --     infoTitle = "有奖励可以领取", 
    --     icon = {spriteName = "mbutton_m_kaifuhuodong", iconAnimateTag = 8}, 
    --     callFun = callToMainScene, 
    --     isOKFun = function ()  return game_data:getAlertsDataByKey("daily") and game_data:getAlertsDataByKey("daily") ~= ""  end  
    -- },
    day = {
        name = string_helper.game_small_map_scene.name1, 
        infoTitle = string_helper.game_small_map_scene.infoTitle, 
        icon = {spriteName = "mbutton_m_quest", iconAnimateTag = 12},
        callFun = callToMainScene, 
        isOKFun = function ()  return game_data:getAlertsDataByKey("reward") and game_data:getAlertsDataByKey("reward") ~= ""  end  ,
        checkName = "reward"
    },
    online = {
        name = string_helper.game_small_map_scene.name2, 
        infoTitle = string_helper.game_small_map_scene.infoTitle, 
        icon = {spriteName = "mbutton_m_fuli", iconAnimateTag = 5, resFramesName = "new_main_add_res.plist"}, 
        callFun = callToMainScene, 
        isOKFun = function ()  return game_data:getOnlineExpire() == 0   end  ,
        checkName = "online_award"

    },
    sign = {
        name = string_helper.game_small_map_scene.name3, 
        infoTitle = string_helper.game_small_map_scene.infoTitle, 
        icon = {spriteName = "mbutton_m_fuli", iconAnimateTag = 8, resFramesName = "new_main_add_res.plist"}, 
        callFun = callToMainScene, 
        isOKFun = function ()  return game_data:getAlertsDataByKey("daily")  end  
    },
    reward = {
        name = string_helper.game_small_map_scene.name4, 
        infoTitle = string_helper.game_small_map_scene.infoTitle, 
        icon = {spriteName = "mbutton_m_fuli", iconAnimateTag = 13, resFramesName = "new_main_add_res.plist"}, 
        callFun = callToMainScene, 
        isOKFun = function ()  return game_data:getAlertsDataByKey("once")  end  ,
        checkName = "once"
    },
}

do 
    -- 提示领奖
    if not game_data:isViewOpenByID(3) then
        mainSceneTips["reward"] = nil
    end

    -- 提示每日悬赏
    if not game_data:isViewOpenByID(4) then
        mainSceneTips["day"] = nil;
    end

    -- 提示 开服活动
    if not game_data:isViewOpenByID(10) then
        mainSceneTips["open"] = nil;
    end

    -- 提示 签到
    if not game_data:isViewOpenByID(9) then
        mainSceneTips["sign"] = nil;
    end

    -- 在线奖励
    if not game_data:isViewOpenByID(8) then
        mainSceneTips["online"] = nil;
    end


    -- 强制删掉在线领奖提示
    mainSceneTips["online"] = nil;

end

function game_small_map_scene.showMainSceneTips(self)

    if not self.m_conbtn_dosth then
        cclog("not found self.m_conbtn_dosth -- in game_small_map_scene")
        return
    end
    self.m_conbtn_dosth:setPosition(-100, 125)  -- 将按钮移出屏幕
    self.m_conbtn_dosth:setVisible(false);   -- 提示按钮的隐藏
    self.m_doSthFun = nil
    for k,v in pairs(mainSceneTips) do
        if v then
            -- print("self:getIsShowTipsByName( v.checkName, v.isOKFun )", self:getIsShowTipsByName( v.name, v.isOKFun ))
            if self:getIsShowTipsByName( v.checkName, v.isOKFun ) then  -- 条件达成
                -- print("find use tip ", v.name, v.infoTitle, v.icon.spriteName)
                self.m_conbtn_dosth:setVisible(true);   -- 提示按钮的显示
                game_util:addTipsAnimByType(self.m_conbtn_dosth, 14)
                self.m_conbtn_dosth:setPositionX(-20)
                local moveBy = CCMoveBy:create(0.5, ccp(40, 0))
                self.m_conbtn_dosth:runAction(CCEaseBackIn:create(moveBy))
                self.m_doSthFun = function ()
                    game_scene:addPop("game_do_something_pop", {gameData = {showType = "main_reward", showTitle = v.infoTitle, showInfo = v.name, iconData = {spriteName = v.icon.spriteName, 
                        resFramesName = v.icon.resFramesName, iconAnimateTag = v.icon.iconAnimateTag}, 
                        endCallFun =function ( )
                            -- print(" -------- game_small_map_scene ----- endCallFun", "---::::::::")
                            -- self:destroy()
                        end
                    }})
                end
                break
            end
        end
    end
end

function game_small_map_scene.getIsShowTipsByName( self, name, checkIsOKFun )
    -- if self.showDataTips then
    --     return self.showDataTips[name] ~= nil 


    local level = game_data:getUserStatusDataByKey("level")
    if level < 3 then
        return false
    end


        if self.showDataTips and self.showDataTips[name] == true then
            return true
        else
            return checkIsOKFun()
        end
    -- print("checkIsOKFun --- ", checkIsOKFun())
end

-- function game_small_map_scene.getMainSceneTips()
--     local function responseMethod(tag,gameData)
--         local data = gameData:getNodeWithKey("data");
--         cclog("game_main_scene data == " .. data:getFormatBuffer());
--         game_data:updateMainPageByJsonData(data);
--         game_scene:enterUi("game_main_scene",t_params,t_params2);  

--         game_scene:enterGameUi("game_small_map_scene",{});
--         self:destroy();  
--     end
--     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_main_page"), http_request_method.GET, nil,"user_main_page")
--     -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_online_award"), http_request_method.GET, nil,"user_online_award")
-- end

return game_small_map_scene;