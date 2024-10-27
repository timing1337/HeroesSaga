--- 开门活动

local open_door_map = {
    m_ccbNode = nil,
    m_close_btn = nil,
    m_open_time_label = nil,
};
--[[--
    销毁
]]
function open_door_map.destroy(self)
    -- body
    cclog("-----------------open_door_map destroy-----------------");
    self.m_ccbNode = nil;
    self.m_close_btn = nil;
    self.m_open_time_label = nil;
end
--[[--
    返回
]]
function open_door_map.back(self,type)
    game_scene:enterGameUi("open_door_main_scene")
end
--[[--
    读取ccbi创建ui
]]
function open_door_map.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag > 10 and btnTag < 14 then
            if btnTag == 11 then--跳转到银河舰队
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_main",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
            elseif btnTag == 13 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("open_door_cloister",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_index"), http_request_method.GET, nil,"maze_index")
            else
                local function responseMethod(tag,gameData)
                    if gameData then
                        game_scene:enterGameUi("game_pyramid_scene",{gameData = gameData,screenShoot = screenShoot, openData = {}});
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_index"), http_request_method.GET, nil,"pyramid_index")  
                -- self:refreshActivityDetail(btnTag - 10);
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_door_map.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_open_time_label = ccbNode:labelTTFForName("m_open_time_label")
    local escort_opentime_cfg = getConfig(game_config_field.escort_opentime)
    local openDes = string_helper.open_door_map.open_time;
    local tempCount = escort_opentime_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = escort_opentime_cfg:getNodeAt(i-1)
        local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
        local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
        openDes = openDes .. start_time .. "-" .. end_time;
        if i ~= tempCount then
            openDes = openDes .. "\n"
        end
    end
    self.m_open_time_label:setString(openDes)
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function open_door_map.refreshUi(self)

end

--[[--
    初始化
]]
function open_door_map.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_map.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return open_door_map;