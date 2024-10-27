---  星云图
local game_dart_galaxy = {
    m_location = nil,
    tips_label2 = nil,
};
--[[--
    销毁ui
]]
function game_dart_galaxy.destroy(self)
    cclog("----------------- game_dart_galaxy destroy-----------------"); 
    self.m_location = nil;
    self.tips_label2 = nil;
end
--[[--
    返回
]]
function game_dart_galaxy.back(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_dart_route",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, nil,"escort_map_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_galaxy.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--返回
            self:back()
        elseif btnTag == 3 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_open_map"), http_request_method.GET, nil,"escort_open_map")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_galaxy.ccbi");

    self.tips_label = ccbNode:labelTTFForName("tips_label")
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- local map_id = self.m_tGameData.map_id
        -- if btnTag == map_id then
        --     self:back()
        -- else
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_route",{gameData = gameData})
            end
            local prarms = {map_id = btnTag}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, prarms,"escort_map_index")
        -- end
    end
    for i=1,11 do
        local m_location = ccbNode:spriteForName("m_location_" .. i)
        local m_location_label = ccbNode:labelTTFForName("m_location_label_" .. i)
        local m_name_label = ccbNode:labelTTFForName("m_name_label_" .. i)
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setTag(i)
        button:setOpacity(0)
        -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
        button:setAnchorPoint(ccp(0.5,0.5))
        m_location:addChild(button);
        self.m_location[i] = {m_location = m_location,m_location_label = m_location_label,m_name_label = m_name_label,button = button}
    end
    self.tips_label2 = ccbNode:labelTTFForName("tips_label2")
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_dart_galaxy.refreshUi(self)
    local map_id = self.m_tGameData.map_id
    local map_num = self.m_tGameData.map_num or {}
    for i=1,11 do
        local m_location = self.m_location[i].m_location
        local m_location_label = self.m_location[i].m_location_label
        local m_name_label = self.m_location[i].m_name_label
        local button = self.m_location[i].button
        if map_id == i then
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_down.png")
            if tempSpriteFrame then
                m_location:setDisplayFrame(tempSpriteFrame);
            end
        end
        local shipCount = map_num[tostring(i)] or 0
        m_location_label:setString(shipCount .. string_helper.game_dart_galaxy.boat)
        m_name_label:setString(string_helper.game_dart_galaxy.di .. i .. string_helper.game_dart_galaxy.channel)
        if shipCount < 1 then
            button:setTouchEnabled(false)
            m_location:setColor(ccc3(200,200,200))
        else
            button:setTouchEnabled(true)
            m_location:setColor(ccc3(255,255,255))
        end
    end
    local vehicle_status = self.m_tGameData.vehicle_status or 0 -- 0无货船，1货船正在运输，2货船运输完成
    if vehicle_status == 1 then
        local arrive_time = self.m_tGameData.arrive_time or 0
        local identity = self.m_tGameData.identity or 0
        if identity ~= 0 and arrive_time > 0 then
            self.tips_label2:setString(string_helper.game_dart_galaxy.text1 .. tostring(game_util:formatTime2(arrive_time)) .. string_helper.game_dart_galaxy.text2)
        else
            self.tips_label2:setString(string_helper.game_dart_galaxy.text3)
        end
    elseif vehicle_status == 2 then
        self.tips_label2:setString(string_helper.game_dart_galaxy.text4)
    else
        self.tips_label2:setString(string_helper.game_dart_galaxy.text5)
    end
end
--[[--
    初始化
]]
function game_dart_galaxy.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
    self.m_location = {}
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_galaxy.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_galaxy