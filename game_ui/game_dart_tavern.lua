---  打劫酒馆
local game_dart_tavern = {
    m_table_node= nil,
    m_root_layer = nil,
    m_create_team_btn = nil,
    m_tips_label = nil,
    m_tips_label_2 = nil,
    m_refresh_btn = nil,
};
--[[--
    销毁ui
]]
function game_dart_tavern.destroy(self)
    cclog("----------------- game_dart_tavern destroy-----------------"); 
    self.m_table_node = nil;
    self.m_root_layer = nil;
    self.m_create_team_btn = nil;
    self.m_tips_label = nil;
    self.m_tips_label_2 = nil;
    self.m_refresh_btn = nil;
end

--[[--
    返回
]]
function game_dart_tavern.back(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_dart_main",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_tavern.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--创建队伍
            local rob_identity = self.m_tGameData.rob_identity or 0  --0无，1队长，2队员
            if rob_identity == 0 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_create_rob_team"), http_request_method.GET, nil,"escort_create_rob_team")
            else
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, nil,"escort_check_my_rob_team")
            end
        elseif btnTag == 3 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi();
                game_util:addMoveTips({text = string_helper.game_dart_tavern.refresh_success})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_rob_index"), http_request_method.GET, nil,"escort_rob_index")
        elseif btnTag == 11 then -- 聊天
            game_scene:addPop("ui_chat_pop", {enterType = 5, openType = 1})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_tavern.ccbi");
    self.m_table_node = ccbNode:nodeForName("m_table_node")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_create_team_btn = ccbNode:controlButtonForName("m_create_team_btn")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    self.m_refresh_btn:setVisible(true)
    return ccbNode;
end

--[[
    队伍信息
]]
function game_dart_tavern.createTeamInfoTable(self,viewSize)
    local teamInfoTable = self.m_tGameData.rob_info or {}
    local teamKey = {}
    for k,v in pairs(teamInfoTable) do
        table.insert(teamKey,k)
    end
    local tabCount = #teamKey;
    self.m_tips_label_2:setVisible(tabCount == 0);
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();
        local tempUid = tostring(teamKey[btnTag+1])
        local uid = game_data:getUserStatusDataByKey("uid") or ""
        local itemData = teamInfoTable[tempUid]
        if game_util:valueInTeam(uid,itemData.member) then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, nil,"escort_check_my_rob_team")
        else
            local params = {}
            params.captain_uid = tempUid
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                game_util:addMoveTips({text = string_helper.game_dart_tavern.add_team_success})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_join_rob_team"), http_request_method.GET, params,"escort_join_rob_team")
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_main_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_ship_sprite = ccbNode:spriteForName("m_ship_sprite")
            local m_ship_title = ccbNode:spriteForName("m_ship_title")
            m_ship_sprite:setOpacity(0);
            m_ship_title:setVisible(false)
            local itemData = teamInfoTable[tostring(teamKey[index+1])]
            local member = itemData.member
            local escort_time = itemData.escort_time

            local m_add_btn = ccbNode:controlButtonForName("m_add_btn")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_num_label = ccbNode:labelBMFontForName("m_num_label")
            local m_full_sprite = ccbNode:spriteForName("m_full_sprite")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local m_list_item_mask = ccbNode:scale9SpriteForName("m_list_item_mask")
            m_add_btn:setTag(index);
            m_add_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+9);

            local members_info = itemData.members_info or {}
            local role_id_table_count = #member;
            local totalCombat = 0;
            for i=1,role_id_table_count do
                local members_info_data = members_info[member[i]] or {}
                if i == 1 then
                    m_name_label:setString(tostring(members_info_data.name) .. "(Lv." .. tostring(members_info_data.level) .. ")");
                    -- local tempIcon = game_util:createPlayerIconByRoleId(members_info_data.role);
                    local tempIcon = game_util:createRoleBigImgHalf(tostring(members_info_data.role));
                    if tempIcon then
                        local tempSize = m_ship_sprite:getContentSize()
                        tempIcon:setAnchorPoint(ccp(0.5,0))
                        tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                        m_ship_sprite:setPositionY(5)
                        m_ship_sprite:setScale(0.7)
                        m_ship_sprite:addChild(tempIcon)
                    end
                end
                totalCombat = totalCombat + (members_info_data.combat or 0)
            end
            m_combat_label:setString(math.floor(totalCombat/role_id_table_count));
            m_num_label:setString(role_id_table_count .. "/3")
            if role_id_table_count < 3 then
                m_add_btn:setVisible(true)
                m_full_sprite:setVisible(false)
                m_list_item_mask:setVisible(false)
            else
                m_add_btn:setVisible(false)
                m_full_sprite:setVisible(true)
                m_list_item_mask:setVisible(true)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- local itemData = teamInfoTable[tostring(teamKey[index+1])]
            -- local captain_uid = teamKey[index+1]
            -- local params = {}
            -- params.captain_uid = captain_uid
            -- local function responseMethod(tag,gameData)
            --     game_scene:addPop("game_dart_other_team",{gameData = gameData,captain_uid = captain_uid})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_other_team"), http_request_method.GET, params,"escort_check_other_team")
        end
    end
    return TableViewHelper:createGallery3(params);
end
--[[--
    刷新ui
]]
function game_dart_tavern.refreshUi(self)
    self.m_table_node:removeAllChildrenWithCleanup(true)
    local teamTable = self:createTeamInfoTable(self.m_table_node:getContentSize())
    self.m_table_node:addChild(teamTable)
    local rob_identity = self.m_tGameData.rob_identity or 0  --0无，1队长，2队员
    if rob_identity == 0 then
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_chuangjianduiwu.png")
    else
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_myteam.png")
    end
end
--[[--
    初始化
]]
function game_dart_tavern.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self.vehicle_is_ready = self.m_tGameData.vehicle_is_ready or false
        else
            self.m_tGameData = t_params.gameData
        end
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_dart_tavern.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_tavern;