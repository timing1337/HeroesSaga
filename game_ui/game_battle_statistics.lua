---  战斗结算

local game_battle_statistics = {
    m_cityId = nil,
    m_buildingId = nil,
    m_next_step = nil,
};
--[[--
    销毁
]]
function game_battle_statistics.destroy(self)
    -- body
    cclog("-----------------game_battle_statistics destroy-----------------");
    self.m_cityId = nil;
    self.m_buildingId = nil;
    self.m_next_step = nil;
end
--[[--
    返回
]]
function game_battle_statistics.back(self,type)
    local function responseMethod(tag,gameData)
        game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
        if (self.m_cityId ~= nil and self.m_buildingId ~= nil) and self.m_next_step ~= -1 then
            game_scene:enterGameUi("map_building_detail_scene",{cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,gameData = gameData});
        else
            game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,recoverBuildingId = self.m_buildingId});
        end
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = self.m_cityId},"private_city_open")
end
--[[--
    读取ccbi创建ui
]]
function game_battle_statistics.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        self:back();
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_battle_statistics.ccbi");
    local m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")

    local m_9sprite_bg = ccbNode:scale9SpriteForName("m_9sprite_bg")
    local px,py = m_9sprite_bg:getPosition();
    local temp9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_count02.png");
    temp9Sprite:setContentSize(m_9sprite_bg:getContentSize());
    temp9Sprite:ignoreAnchorPointForPosition(true);
    temp9Sprite:setPosition(ccp(px,py));
    m_9sprite_bg:getParent():addChild(temp9Sprite);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_battle_statistics.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_battle_statistics.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cityId = t_params.cityId;
    self.m_buildingId = t_params.buildingId;
    self.m_next_step = t_params.next_step;
end

--[[--
    创建ui入口并且初始化数据
]]
function game_battle_statistics.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_battle_statistics;