--- 中立地图

local game_neutral_map = {
    m_tGameData = nil,
    m_title_label = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_showNeutralTab = nil,
    m_enterTime = nil,
};
--[[--
    销毁ui
]]
function game_neutral_map.destroy(self)
    -- body
    cclog("-----------------game_neutral_map destroy-----------------");
    self.m_tGameData = nil;
    self.m_title_label = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_showNeutralTab = nil;
    self.m_enterTime = nil;
end
--[[--
    返回
]]
function game_neutral_map.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_map.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        self:back();
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_neutral_map_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    return ccbNode;
end

--[[--
    创建中立列表
]]
function game_neutral_map.createTableView(self,viewSize)
    local function timeEndFunc(label,type)
        if label:getParent() then
            label:getParent():setVisible(false);
        end
    end

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local middle_map = getConfig(game_config_field.middle_map);
    local cityData = self.m_tGameData.city;
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #self.m_showNeutralTab;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_game_neutral_map_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local city_id = self.m_showNeutralTab[index+1]
            local itemCfg = middle_map:getNodeWithKey(city_id);
            local itemData = cityData[city_id]
            if itemCfg and ccbNode then
                local m_city_name_label = ccbNode:labelTTFForName("m_city_name_label")
                local m_time_node = ccbNode:nodeForName("m_time_node")
                local m_icon_bg = ccbNode:spriteForName("m_icon_bg")
                local m_bg_spr = ccbNode:spriteForName("m_bg_spr")
                m_icon_bg:removeAllChildrenWithCleanup(true);
                local m_time_label = ccbNode:labelTTFForName("m_time_label")
                m_time_label:setVisible(false);
                local banner = itemCfg:getNodeWithKey("banner");
                if banner then
                    banner = game_util:getResName(banner:toStr());
                    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(banner .. ".png");
                    if tempSpriteFrame then
                        m_bg_spr:setDisplayFrame(tempSpriteFrame);
                    end
                end
                m_city_name_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                local expire = itemData.expire - (os.time() - self.m_enterTime)
                if expire > 0 then
                    m_time_node:setVisible(true);
                    local tempNode = m_time_node:getChildByTag(5);
                    local countdownLabel = nil;
                    if tempNode then
                        countdownLabel = tolua.cast(tempNode,"ExtCountdownLabel");
                    else
                        countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
                        countdownLabel:setColor(ccc3(255,255,0))
                        local pX,pY = m_time_label:getPosition();
                        countdownLabel:setPosition(ccp(pX,pY))
                        m_time_node:addChild(countdownLabel,0,5)
                    end
                    countdownLabel:setTime(expire)
                    local tempSize = m_icon_bg:getContentSize();
                    local roleId = game_data:getUserStatusDataByKey("role")
                    local tempIcon = game_util:createPlayerIconByRoleId(roleId)
                    if tempIcon then
                        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                        m_icon_bg:addChild(tempIcon,-1,10)
                    end
                else
                    m_time_node:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local city_id = self.m_showNeutralTab[index+1]
            local function responseMethod(tag,gameData)
                game_data:setSelNeutralCityDataByJsonData(gameData:getNodeWithKey("data"));
                local public_city_rate = gameData:getNodeWithKey("data"):getNodeWithKey("public_city_rate"):toInt()
                local public_city_update_left = gameData:getNodeWithKey("data"):getNodeWithKey("public_city_update_left"):toInt()
                local dominate_fail = json.decode(gameData:getNodeWithKey("data"):getNodeWithKey("dominate_fail"):getFormatBuffer())
                game_scene:enterGameUi("game_neutral_city_map",{gameData = gameData,city_id = city_id,public_city_update_left = public_city_update_left,public_city_rate = public_city_rate,dominate_fail = dominate_fail});
                self:destroy();
            end
            -- 公共地图，打开城市 city_id=10001
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_open"), http_request_method.GET, {city_id = city_id},"public_city_open")
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_neutral_map.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function game_neutral_map.init(self,t_params)
    t_params = t_params or {};
    -- body
    local gameData = t_params.gameData
    if gameData ~= nil and tolua.type(gameData) == "util_json" then
        self.m_tGameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    self.m_showNeutralTab = {};
    local city = self.m_tGameData.city or {};
    for k,v in pairs(city) do
        self.m_showNeutralTab[#self.m_showNeutralTab + 1] = k
    end
    local function sortFunc(dataOne,dataTwo)
        return tonumber(dataOne) > tonumber(dataTwo);
    end
    table.sort(self.m_showNeutralTab);
    self.m_enterTime = os.time();
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_map.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    -- 无主之地 drama
    local id = game_guide_controller:getIdByTeam("20");
    if id == 2001 then
        game_guide_controller:gameGuide("drama","20",2001)
    end

    return scene;
end

return game_neutral_map;