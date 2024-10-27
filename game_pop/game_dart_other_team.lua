--- 其他队伍详情
local game_dart_other_team = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
  
};

--[[--
    销毁
]]
function game_dart_other_team.destroy(self)
    -- body
    cclog("-----------------game_dart_other_team destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    
end


--[[--
    返回
]]
function game_dart_other_team.back(self,type)
    game_scene:removePopByName("game_dart_other_team");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_dart_other_team.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--解散队伍
            local function responseMethod(tag,gameData)
                -- cclog2(gameData:getNodeWithKey("data"))
                local identity = gameData:getNodeWithKey("data"):getNodeWithKey("identity"):toInt()--0是无对1是队长2是队员
                if identity == 0 then
                    game_scene:enterGameUi("game_dart_main",{gameData = gameData});
                else
                    game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,identity = identity})
                end
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_disband_goods_team"), http_request_method.GET, nil,"escort_disband_goods_team")
        elseif btnTag == 3 then--起航
            local function responseMethod(tag,gameData)
                -- cclog2(gameData:getNodeWithKey("data"))
                game_scene:enterGameUi("game_dart_route",{gameData = gameData})
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_start_sail"), http_request_method.GET, nil,"escort_start_sail")
        elseif btnTag == 4 then--买buff
            local function responseMethod(tag,gameData)
                -- cclog2(gameData:getNodeWithKey("data"))
                if gameData ~= nil and tolua.type(gameData) == "util_json" then
                    local data = gameData:getNodeWithKey("data");
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                    self:refreshUi()
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_refresh_vehicle_buff"), http_request_method.GET, nil,"escort_refresh_vehicle_buff")
        elseif btnTag == 10 then--加入队伍   查看货物
            local function responseMethod(tag,gameData)
                self:back()
                game_scene:addPop("game_dart_goods",{gameData = gameData,enterType = "join",captain_uid = self.captain_uid})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_my_goods"), http_request_method.GET, nil,"escort_my_goods")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_other_team.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local refresh_btn = ccbNode:controlButtonForName("refresh_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    local hire_npc_btn = ccbNode:controlButtonForName("hire_npc_btn")
    self.team_node = ccbNode:nodeForName("team_node")

    hire_npc_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.ship_type_spr = ccbNode:spriteForName("ship_type_spr")

    local team_info = self.m_tGameData.team_info
    local teamPlayerCount = game_util:getTableLen(team_info)
    if teamPlayerCount < 3 then
        hire_npc_btn:setVisible(true)
    else
        hire_npc_btn:setVisible(false)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    队伍信息
]]
function game_dart_other_team.createTavernTable(self,viewSize)
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100

        local function responseMethod(tag,gameData)
            
        end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
    end
    local team_info = self.m_tGameData.team_info
    local team_id = {}
    for k,v in pairs(team_info) do
        table.insert(team_id,k)
    end
    local tabCount = game_util:getTableLen(team_info)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_dart_team_info_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local name_label = ccbNode:labelTTFForName("name_label")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local m_icon = ccbNode:nodeForName("m_icon")
            local m_kick_btn = ccbNode:controlButtonForName("m_kick_btn")

            -- m_kick_btn:setTag(101 + index)
            local itemData = team_info[tostring(team_id[index+1])]
            -- cclog2(itemData,"itemData")
            local goods = {}
            if game_util:getTableLen(itemData.goods) > 0 then
                goods = itemData.goods.goods[1]
            end
            local name = itemData.name
            local combat = itemData.combat

            local icon,goods_name,count = game_util:getRewardByItemTable(goods)
            if icon then
                icon:setScale(0.8)
                icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
                m_icon:addChild(icon)
                if count then
                    local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                    countLabel:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5-15))
                    icon:addChild(countLabel,10)
                end
            end
            name_label:setString(name)
            m_combat_label:setString(tostring(combat))
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
    刷新ui
]]
function game_dart_other_team.refreshUi(self)
    self.team_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createTavernTable(self.team_node:getContentSize())
    tempTable:setScrollBarVisible(false)
    self.team_node:addChild(tempTable,10)

    local buff_sort = self.m_tGameData.buff_sort
    local buff_sort_item = BUFF_SORT_IMG[buff_sort+1]
    if buff_sort_item then
        local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.title)
        self.ship_type_spr:setDisplayFrame(tempDisplayFrame);
    end

end
--[[--
    初始化
]]
function game_dart_other_team.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
    self.goods_id = t_params.goods_id
    self.goods_info = t_params.goods_info
    self.captain_uid = t_params.captain_uid
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_other_team.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_other_team;