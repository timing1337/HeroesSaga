---  新竞技场
local ui_levelap_rank = {
    m_gameData = nil,
    m_rank_node= nil,
    m_rank_table_node = nil,
    m_index = nil,
    level_page = nil,
    combat_page = nil,
    change_flag_1 = nil,
    change_flag_2 = nil,
    count_1 = nil,
    count_2 = nil,
    lv_count = nil,
    combat_count = nil,
};
--[[--
    销毁ui
]]
function ui_levelap_rank.destroy(self)
    cclog("-----------------ui_levelap_rankdestroy-----------------");
    self.m_gameData = nil;
    --排行榜的控件
    self.m_rank_node = nil;
    self.m_rank_table_node = nil;
    self.m_index = nil;
    self.level_page = nil;
    self.combat_page = nil;
    self.change_flag_1 = nil;
    self.change_flag_2 = nil;
    self.count_1 = nil;
    self.count_2 = nil;
    self.lv_count = nil;
    self.combat_count = nil;
end
--[[--
    返回
]]
function ui_levelap_rank.back(self,backType)
    -- local function responseMethod(tag,gameData)
        -- local data = gameData:getNodeWithKey("data")
        -- local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
        game_scene:enterGameUi("game_main_scene")
        self:destroy()
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end
--[[--
    读取ccbi创建ui
]]
function ui_levelap_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 3 then         -- 等级排行榜
            self.m_index = 1
            self:refreshUi()
        elseif btnTag == 4 then         -- 战力排行榜
            self.m_index = 2
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_levelap_rank.ccbi");
    --排行榜的控件
    self.m_rank_node = ccbNode:nodeForName("m_arena_node_2");
    self.m_rank_table_node = ccbNode:nodeForName("rank_table_node");
    --战力排行榜
    self.btn_levelrank = ccbNode:controlButtonForName("m_tab_btn_2");       -- 等级排行按钮
    self.btn_aprank = ccbNode:controlButtonForName("m_tab_btn_3");          -- 战力排行按钮
    game_util:setCCControlButtonTitle(self.btn_levelrank,string_helper.ccb.title187);
    game_util:setCCControlButtonTitle(self.btn_aprank,string_helper.ccb.title188);
    return ccbNode;
end
--[[
    创建竞技场排行榜列表
]]
function ui_levelap_rank.createRankTableView(self,viewSize, data)
    local rank_info = data
    -- print_lua_table(rank_info, 5)
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();        
        local index = btnTag - 1000
        local tempUid = rank_info[index].uid;
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_player_info_pop",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
    end
    local frame_name = {"arena_gold.png","arena_silver.png","arena_copper.png"}
    local fightCount = #rank_info;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local sb_name = {}
    local sb_guild = {}
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local user_rank_label = ccbNode:labelBMFontForName("rank_number");
            local user_name_label = ccbNode:labelTTFForName("m_user_label");
            local fight_count_label = ccbNode:labelBMFontForName("fight_point_label");
            local top_icon = ccbNode:spriteForName("top_icon");
            local guild_name_label = ccbNode:labelTTFForName("m_guild_label");

            local btn_look = ccbNode:controlButtonForName("btn_look")
            btn_look:setTag(1001 + index)
            btn_look:setOpacity(0)

            local user_info = rank_info[index + 1];
            user_rank_label:setString(tostring(index + 1));
            if index >= 0 and index < 3 then
                top_icon:setVisible(true);
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(frame_name[index + 1]))
                top_icon:setDisplayFrame(tempSpriteFrame);
            else
                top_icon:setVisible(false);
            end
            user_name_label:setString(tostring(user_info.name));
            local hightest_level = tonumber(user_info.rank)
            guild_name_label:setString(tostring(user_info.level or 0))  
            for i=1,4 do
                sb_name[i] = ccbNode:labelTTFForName("m_user_label_" .. i);
                sb_name[i]:setVisible(false);
                sb_guild[i] = ccbNode:labelTTFForName("m_guild_label_" .. i);
                sb_guild[i]:setVisible(false)  
            end
            local icon = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            fight_count_label:setString(tostring(user_info.combat));

            if self.m_index == 1 then--战斗力的
                if index == fightCount - 1 and self.combat_page < 4 then
                    local tipLabel = game_util:createLabelTTF({text = string_helper.ui_levelap_rank.down_refresh,color = ccc3(250,180,0),fontSize = 12});
                    tipLabel:setAnchorPoint(ccp(0.5,0.5))
                    tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                    cell:addChild(tipLabel,20,20)
                else
                    local tempNode = cell:getChildByTag(20)
                    if tempNode then
                        tempNode:removeFromParentAndCleanup(true)
                    end
                end
            else
                if index == fightCount - 1 and self.level_page < 4 then
                    local tipLabel = game_util:createLabelTTF({text = string_helper.ui_levelap_rank.down_refresh,color = ccc3(250,180,0),fontSize = 12});
                    tipLabel:setAnchorPoint(ccp(0.5,0.5))
                    tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                    cell:addChild(tipLabel,20,20)
                else
                    local tempNode = cell:getChildByTag(20)
                    if tempNode then
                        tempNode:removeFromParentAndCleanup(true)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
        elseif eventType == "refresh" and item then
            if self.m_index == 1 then--战斗力的
                self.combat_page = self.combat_page + 1
                local function responseMethod(tag,gameData)
                    local top = gameData:getNodeWithKey("data"):getNodeWithKey("top")
                    local combatData = json.decode(top:getFormatBuffer())
                    for i=1,#combatData do
                        table.insert(self.userCombat,combatData[i])
                    end
                    self.count_1 = gameData:getNodeWithKey("data"):getNodeWithKey("count"):toInt()
                    local function sortFunc(data1,data2)
                        return tonumber(data1.rank) < tonumber(data2.rank)
                    end
                    table.sort(self.userCombat, sortFunc)
                    if #combatData < 20 then
                        self.change_flag_1 = false
                    else
                        self.change_flag_1 = true
                    end
                    -- cclog("self.userCombat = " .. json.encode(self.userCombat))
                    self.combat_count = #self.userCombat
                    self:refreshUi()
                end
                if self.count_1 ~= self.combat_count then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rank_combat"), http_request_method.GET, {page = self.combat_page},"rank_combat")
                end
            else
                self.level_page = self.level_page + 1
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local levelData = json.decode(data:getFormatBuffer())
                    for i=1,#levelData.top do
                        table.insert(self.userLevel,levelData.top[i])
                    end
                    local function sortFunc(data1,data2)
                        return tonumber(data1.rank) < tonumber(data2.rank)
                    end
                    self.count_2 = levelData.count
                    table.sort(self.userLevel, sortFunc)
                    if #levelData.top < 20 then
                        self.change_flag_2 = false
                    else
                        self.change_flag_2 = true
                    end
                    self.lv_count = #self.userLevel
                    self:refreshUi()
                end
                if self.lv_count ~= self.count_2 then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rank_level"), http_request_method.GET, {page = self.level_page},"rank_level")
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新
]]
function ui_levelap_rank.refreshUi(self)
   local flag1 = self.m_index == 1 and true or false
    local flag2 = self.m_index == 2 and true or false

    self.btn_levelrank:setHighlighted(flag1);
    self.btn_levelrank:setEnabled(not flag1);
    self.btn_aprank:setHighlighted(flag2);
    self.btn_aprank:setEnabled(not flag2);
    if self.m_index == 1 then
        self:refreshTabByData(self.userCombat);
    else
        if self.userLevel == nil then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog("rank_level data = " .. data:getFormatBuffer())
                local levelData = json.decode(data:getFormatBuffer())
                self.userLevel = levelData.top
                self.count_2 = levelData.count
                local function sortFunc(data1,data2)
                    return tonumber(data1.rank) < tonumber(data2.rank)
                end
                table.sort(self.userLevel,sortFunc)
                self.lv_count = #self.userLevel
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rank_level"), http_request_method.GET, {page = self.level_page},"rank_level")
        else
            self:refreshTabByData(self.userLevel);
        end
    end
end
--[[
    刷新表2
]]
function ui_levelap_rank.refreshTabByData(self, data)
    self.m_rank_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createRankTableView(self.m_rank_table_node:getContentSize(), data)
    textTableTemp:setScrollBarVisible(false)
    self.m_rank_table_node:addChild(textTableTemp,10,10);

    if self.m_index == 1 then--定位战斗力table
        local com_index = math.min(self.combat_page * 20,self.combat_count - 4)
        -- if self.combat_page * 20 < self.combat_count then
        --     com_index = self.combat_page * 20
        -- else
        --     com_index = self.combat_page * 20 - 1
        -- end
        game_util:setTableViewIndex(com_index,self.m_rank_table_node,10,4)
    else--定位等级的
        local lv_index = math.min(self.level_page * 20,self.lv_count - 4)
        -- if self.change_flag_2 == true then
        --     lv_index = self.level_page * 20
        -- else
        --     lv_index = self.level_page * 20 - 1
        -- end
        game_util:setTableViewIndex(lv_index,self.m_rank_table_node,10,4)
    end
end
--[[--
    初始化
]]
function ui_levelap_rank.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        self.m_gameData = t_params.gameData
    end
    self.userCombat = self.m_gameData.top
    self.combat_count = #self.userCombat
     local function sortFunc(data1,data2)
        return tonumber(data1.rank) < tonumber(data2.rank)
    end
    table.sort( self.userCombat, sortFunc )
    self.m_index = 1
    self.level_page = 0
    self.combat_page = 0
    self.change_flag_1 = true
    self.change_flag_2 = true
end

--[[--
    创建ui入口并初始化数据
]]
function ui_levelap_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_levelap_rank;