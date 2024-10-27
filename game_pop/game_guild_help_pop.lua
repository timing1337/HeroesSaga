--- 公会救护车

local game_guild_help_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    game_data = nil,
    
    btn_1 = nil,
    btn_2 = nil,
    table_node = nil,
    cd_label = nil,
    left_label = nil,
    cd_node = nil,

    max_times = nil,
    rescue_log = nil,
    rescue_info = nil,
    tabIndex = nil,
};

--[[--
    销毁
]]
function game_guild_help_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_help_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.game_data = nil;
    
    self.btn_1 = nil;
    self.btn_2 = nil;
    self.table_node = nil;
    self.cd_label = nil;
    self.left_label = nil;
    self.cd_node = nil;

    self.max_times = nil;
    self.rescue_log = nil;
    self.rescue_info = nil;
    self.tabIndex = nil;
end
--[[--
    返回
]]
function game_guild_help_pop.back(self,type)
    game_scene:removePopByName("game_guild_help_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_guild_help_pop.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--求救信息
            self.tabIndex = 1
            self:refreshUi()
        elseif btnTag == 3 then--救援记录
            self.tabIndex = 2
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_help_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    self.btn_1 = ccbNode:controlButtonForName("btn_1")
    self.btn_2 = ccbNode:controlButtonForName("btn_2")
    self.table_node = ccbNode:nodeForName("table_node")
    self.cd_label = ccbNode:labelTTFForName("cd_label")
    self.left_label = ccbNode:labelTTFForName("left_label")
    self.cd_node = ccbNode:nodeForName("cd_node")

    self.btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    self.m_ccbNode = ccbNode;

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text210)
    self.cd_label:setString(string_helper.ccb.text209)
    return ccbNode;
end
--[[
    
]]
function game_guild_help_pop.createTableView(self,viewSize)
    local pirateCfg = getConfig(game_config_field.treasure)
    
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        local index = btnTag - 100
        local itemData = self.rescue_info[index+1]

            if itemData.activities == "wanted" then
                local function responseMethod(tag,gameData)
                    cclog2(gameData, "help_recapture gameData ===  ")
                    local data = gameData:getNodeWithKey("data")
                    local cd_status = data:getNodeWithKey("cd_status"):toInt()
                    if cd_status == 1 then
                        local tipText = data:getNodeWithKey("text"):toStr()
                        game_util:addMoveTips({text = tipText})
                    else
                        game_data:setBattleType("help_recapture");
                        --传背景图
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData, backGroundName=nil});
                    end
                end
                local params = {}
                params.uid = itemData.uid
                params.help_time = itemData.help_time
                params.enemy_id = itemData.enemy_id
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wanted_help_fight"), http_request_method.GET, params,"wanted_help_fight")
            else
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local cd_status = data:getNodeWithKey("cd_status"):toInt()
                    if cd_status == 1 then
                        local tipText = data:getNodeWithKey("text"):toStr()
                        game_util:addMoveTips({text = tipText})
                    else
                        game_data:setBattleType("help_recapture");
                        local data = gameData:getNodeWithKey("data")
                        local stageTableData = {name = string_helper.game_guild_help_pop.jy,step = 0,totalStep = 1}
                        --传背景图
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=nil});
                    end
                end
                local params = {}
                params.help_uid = itemData.uid
                params.help_time = itemData.help_time
                params.step_n = 0
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_help_recapture"), http_request_method.GET, params,"search_treasure_help_recapture")
            end
    end

    local tableCount = game_util:getTableLen(self.rescue_info)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tableCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_guild_help_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_go_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local head_node = ccbNode:nodeForName("head_node")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local left_time_node = ccbNode:nodeForName("left_time_node")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local com_label = ccbNode:labelTTFForName("com_label")
            local m_go_btn = ccbNode:controlButtonForName("m_go_btn")
            m_go_btn:setTag(100+index)

            game_util:setControlButtonTitleBMFont(m_go_btn)

            local itemData = self.rescue_info[index+1]
            local icon = game_util:createPlayerIconByRoleId(tostring(itemData.role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(itemData.role));
            if icon then
                head_node:removeAllChildrenWithCleanup(true)
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            local function timeOverFunc(label,type)
                
            end
            left_time_node:removeAllChildrenWithCleanup(true)
            local timeOverLabel = game_util:createCountdownLabel(itemData.rem_time,timeOverFunc,8,2)
            timeOverLabel:setColor(ccc3(12,249,6))
            timeOverLabel:setAnchorPoint(ccp(0.5,0.5))
            left_time_node:addChild(timeOverLabel,10,10)

            if itemData.activities == "wanted" then
                com_label:setString(string_helper.game_guild_help_pop.tj_jy)
            else
                local itemCfg = pirateCfg:getNodeWithKey(tostring(itemData.treasure))
                local mapName = itemCfg:getNodeWithKey("name"):toStr()
                com_label:setString(mapName .. string_helper.game_guild_help_pop.outed .. itemData.regain .. "%")
            end
            m_name_label:setString(itemData.name)
            m_combat_label:setString(itemData.combat)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        end
    end
    return TableViewHelper:create(params);
end
function game_guild_help_pop.createTableView2(self,viewSize)
    local tableCount = game_util:getTableLen(self.rescue_log)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tableCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_guild_help_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local head_node = ccbNode:nodeForName("head_node")
            local text_label = ccbNode:labelTTFForName("text_label")

            text_label:setString(self.rescue_log[index+1].msg)
            
            local icon = game_util:createPlayerIconByRoleId(tostring(self.rescue_log[index+1].role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(self.rescue_log[index+1].role));
            if icon then
                head_node:removeAllChildrenWithCleanup(true)
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        end
    end
    return TableViewHelper:create(params);
end
--[[
    救援信息
]]
function game_guild_help_pop.refreshTab1(self)
    self.table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.table_node:getContentSize());
    self.table_node:addChild(self.m_tableView);
end
--[[
    救援记录
]]
function game_guild_help_pop.refreshTab2(self)
    self.table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView2(self.table_node:getContentSize());
    self.table_node:addChild(self.m_tableView);
end
--[[--
    刷新ui
]]
function game_guild_help_pop.refreshUi(self)
    if self.tabIndex == 1 then
        self:refreshTab1()
    else
        self:refreshTab2()
    end
    local leftTime = self.game_data.max_times - self.game_data.rescue_times
    self.left_label:setString(string_helper.ccb.file55 .. leftTime .. "/" .. self.game_data.max_times)

    local function timeOverFunc(label,type)
                
    end
    self.cd_node:removeAllChildrenWithCleanup(true)
    local timeOverLabel = game_util:createCountdownLabel(self.game_data.cd,timeOverFunc,8,2)
    timeOverLabel:setAnchorPoint(ccp(0,0.5))
    self.cd_node:addChild(timeOverLabel,10,10)
end

--[[--
    初始化
]]
function game_guild_help_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.game_data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        -- cclog("self.game_data = " .. json.encode(self.game_data))
        self.max_times = self.game_data.max_times
        self.rescue_log = self.game_data.rescue_log
        self.rescue_info = self.game_data.rescue_info
    end
    self.tabIndex = 1
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_help_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_help_pop;