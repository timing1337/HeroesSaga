---  押镖首页
local game_dart_main = {
    m_scroll_view_tips = nil,
    m_rank_node = nil,
    m_my_rank_label = nil,
    m_my_score_label = nil,
    m_top_tips_label = nil,
    m_bottom_tips_label = nil,
    m_time_label_1 = nil,
    m_time_label_2 = nil,
    m_rob_btn = nil,
    m_dart_btn = nil,
    m_detail_msg_bg = nil,
    m_detail_open_flag = nil,
    m_line_9sprite = nil,
};
--[[--
    销毁ui
]]
function game_dart_main.destroy(self)
    cclog("----------------- game_dart_main destroy-----------------"); 
    self.m_scroll_view_tips = nil;
    self.m_rank_node = nil;
    self.m_my_rank_label = nil;
    self.m_my_score_label = nil;
    self.m_top_tips_label = nil;
    self.m_bottom_tips_label = nil;
    self.m_time_label_1 = nil;
    self.m_time_label_2 = nil;
    self.m_rob_btn = nil;
    self.m_dart_btn = nil;
    self.m_detail_msg_bg = nil;
    self.m_detail_open_flag  = nil;
    self.m_line_9sprite = nil;
end
--[[--
    返回
]]
function game_dart_main.back(self)
    game_scene:enterGameUi("open_door_main_scene",{});
end
--[[--
    读取ccbi创建ui
]]
function game_dart_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--去打劫
            local rob_identity = self.m_tGameData.rob_identity or 0  --0无，1队长，2队员
            if rob_identity == 0 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_tavern",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_rob_index"), http_request_method.GET, nil,"escort_rob_index")
            else
                local battle_on = self.m_tGameData.battle_on or 0  --
                if battle_on == 0 then
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, nil,"escort_check_my_rob_team")
                else
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_route",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, nil,"escort_map_index")            
                end
            end
        elseif btnTag == 3 then--商店
            local vehicle_close = self.m_tGameData.vehicle_close or -1 --小于0关闭
            if vehicle_close < 0 then
                game_util:addMoveTips({text = string_helper.game_dart_main.text})
                return;
            end
            local is_sail = self.m_tGameData.is_sail or 0 --1出发 0没出发
            if is_sail == 1 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_route",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_map_index"), http_request_method.GET, nil,"escort_map_index")
            else
                local identity = self.m_tGameData.identity or 0  --0无，1队长，2队员
                if identity == 0 then
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_shop",{gameData = gameData});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_shop_index"), http_request_method.GET, nil,"escort_shop_index")
                else
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,openType = "game_dart_main"})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_team"), http_request_method.GET, nil,"escort_check_my_team")
                end
            end
        elseif btnTag == 4 then--仇人
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_enemylist_scene", {gameData = gameData,openType = "game_dart_main"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_show_enemys"), http_request_method.GET, nil,"enemy_show_enemys")
        elseif btnTag == 100 then--详情
            if self.m_detail_open_flag == true then
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(290,80))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(270,60))
            else
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(290,200))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(270,180))
            end
            self.m_detail_open_flag = not self.m_detail_open_flag;
            self:refreshActivityDetail();
        elseif btnTag == 101 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_point_shop",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_point_shop"), http_request_method.GET, nil,"escort_point_shop")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_main.ccbi");

    self.m_rank_node = ccbNode:nodeForName("m_rank_node")
    self.m_my_rank_label = ccbNode:labelTTFForName("m_my_rank_label")
    self.m_my_score_label = ccbNode:labelTTFForName("m_my_score_label")
    self.m_top_tips_label = ccbNode:labelTTFForName("m_top_tips_label")
    self.m_bottom_tips_label = ccbNode:labelTTFForName("m_bottom_tips_label")
    self.m_time_label_1 = ccbNode:labelTTFForName("m_time_label_1")
    self.m_time_label_2 = ccbNode:labelTTFForName("m_time_label_2")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    self.m_rob_btn = ccbNode:controlButtonForName("m_rob_btn")
    self.m_dart_btn = ccbNode:controlButtonForName("m_dart_btn")
    self.m_detail_msg_bg = ccbNode:scale9SpriteForName("m_detail_msg_bg")
    self.m_line_9sprite = ccbNode:scale9SpriteForName("m_line_9sprite")
    return ccbNode;
end

--[[
    排行榜
]]
function game_dart_main.createRankTable(self,viewSize)
    local rankTable = self.m_tGameData.rank_list
    local tabCount = game_util:getTableLen(rankTable)
    local rankId = {}
    for k,v in pairs(rankTable) do
        table.insert(rankId,k)
    end
    table.sort(rankId,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_dart_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rank = rankId[index+1]
            local itemData = rankTable[tostring(rank)]
            local name = itemData.name
            local point = itemData.point

            detail_label:setString(tostring(rank) .. "." .. name )
            detail_label_score:setString(tostring(point))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_dart_main.refreshActivityDetail(self)
    self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "147" )
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_dart_main.activity_wonderful
    local viewSize = self.m_scroll_view_tips:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(121,236,236),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scroll_view_tips:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view_tips:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view_tips:addChild(tempLabel)
end

--[[--
    刷新ui
]]
function game_dart_main.refreshUi(self)
    self.m_rank_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createRankTable(self.m_rank_node:getContentSize())
    self.m_rank_node:addChild(tempTable,10)

    local rankStr = string_helper.game_dart_main.zan_wu
    if self.m_tGameData.rank > -1 then
        rankStr = self.m_tGameData.rank
    end
    self.m_my_rank_label:setString(rankStr)
    self.m_my_score_label:setString(self.m_tGameData.point)

    local msg = self.m_tGameData.msg or ""
    local rob_free_times = self.m_tGameData.rob_free_times or 0 --剩余的抢劫次数
    local goods_free_times = self.m_tGameData.goods_free_times or 0 --剩余的运货次数
    self.m_time_label_1:setString(string_helper.game_dart_main.residue .. rob_free_times .. string_helper.game_dart_main.side)
    self.m_time_label_2:setString(string_helper.game_dart_main.residue .. goods_free_times ..string_helper.game_dart_main.side)

    local is_sail = self.m_tGameData.is_sail or 0 --是否开始运送货物了 1正在进行中
    if is_sail == 1 then
        self.m_line_9sprite:setVisible(true)
        local server_time = game_data:getUserStatusDataByKey("server_time") or 0
        local arrive_time = self.m_tGameData.arrive_time or 0
        self.m_bottom_tips_label:setString(string_helper.game_dart_main.text2 .. tostring(game_util:formatTime2(arrive_time)) .. string_helper.game_dart_main.text3)
    elseif is_sail == 2 then--在队中
        self.m_line_9sprite:setVisible(true)
        self.m_bottom_tips_label:setString(string_helper.game_dart_main.text4)
    else
        self.m_line_9sprite:setVisible(false)
        self.m_bottom_tips_label:setString("")
    end
    -- self.m_top_tips_label:setString("");
    -- self.m_bottom_tips_label:setString("");    
    self:refreshActivityDetail();
    local is_sail = self.m_tGameData.is_sail or 0 --1出发 0没出发
    local identity = self.m_tGameData.identity or 0  --0无，1队长，2队员
    if is_sail == 1 and identity ~= 0 then
        game_util:setCCControlButtonBackground(self.m_dart_btn,"dart_btn_wodehuochuan.png")
    else
        game_util:setCCControlButtonBackground(self.m_dart_btn,"dart_btn_quyunhuo.png")
    end
end
--[[--
    初始化
]]
function game_dart_main.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_detail_open_flag =false;
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_main