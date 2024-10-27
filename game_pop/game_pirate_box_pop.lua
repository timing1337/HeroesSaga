--- 开启宝箱
local game_pirate_box_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    selectTable = nil,--选择宝箱的数组

    m_explore_btn = nil,
    table_node = nil,

    m_callFunc = nil,
    building = nil,
    city = nil,
    recapture_log = nil,
    treasure = nil,
    gameData = nil,
};

--[[--
    销毁
]]
function game_pirate_box_pop.destroy(self)
    cclog("-----------------game_pirate_box_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.selectTable = nil;

    self.m_explore_btn = nil;
    self.table_node = nil;

    self.m_callFunc = nil;
    self.building = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.treasure = nil;
    self.gameData = nil;
end
--[[--
    返回
]]
function game_pirate_box_pop.back(self,type)
    if closeType == "normal" then
        game_scene:removePopByName("game_pirate_buff_pop");
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_pirate_map",{gameData = gameData,reward = self.reward})
            self:destroy();
        end
        local params = {}
        params.treasure = self.treasure
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
    end
end
function game_pirate_box_pop.backWithReward(self)
    local function responseMethod(tag,gameData)
        local testReward = self.reward or {}
        game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
        game_util:rewardTipsByDataTable(testReward);
        self:destroy();
    end
    local params = {}
    params.treasure = self.treasure
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_box_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                self.m_callFunc("close");
            end
            self:back("normal")
        elseif btnTag == 2 then--确定+返回
            if game_util:getTableLen(self.selectTable) == 0 then
                game_util:addMoveTips({text = string_config.pirate_box_tip})
            else
                local function responseMethod(tag,gameData)
                    if gameData then
                        local data = gameData:getNodeWithKey("data");
                        -- local reward = data:getNodeWithKey("reward");
                        -- game_util:rewardTipsByJsonData(reward);
                        self.reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer())
                        if self.reward then--有奖励才返回
                            self:backWithReward()
                        end
                        -- self:back();
                    end
                end
                local gift_idx = ""
                for i=1,4 do
                    local test = self.selectTable[i]
                    if test then
                        gift_idx = gift_idx .. tostring(i-1) .. "-"
                    end
                end
                local params = {};
                params.building = self.building
                params.city = self.city
                params.treasure = self.treasure
                params.gift_idx = gift_idx
                cclog2(params,"params")
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_add_gifts"), http_request_method.GET, params,"search_treasure_add_gifts",true,true)
            end
        elseif btnTag == 101 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pirate_box.ccbi");
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    self.m_explore_btn = ccbNode:controlButtonForName("m_explore_btn")
    game_util:setCCControlButtonTitle(self.m_explore_btn,string_helper.ccb.title126)
    self.m_explore_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-16)
    game_util:setControlButtonTitleBMFont(self.m_explore_btn)

    self.table_node = ccbNode:nodeForName("table_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[

]]
function game_pirate_box_pop.createTableView( self,viewSize )
    local function onMainBtnClick(target,event)

    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    local giftCount = game_util:getTableLen(self.gameData.gifts)
    params.column = math.min(giftCount,4); --列
    params.totalItem = giftCount
    local selectTableLen = game_util:getTableLen(self.selectTable)
    params.showPoint = false
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-16;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local rewardList = self.gameData.gifts
    local moneyCfg = getConfig(game_config_field.pay):getNodeWithKey("20"):getNodeWithKey("coin")
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_pirate_box_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
            local money_node = ccbNode:nodeForName("money_node")
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local cd_node = ccbNode:nodeForName("cd_node")
            local m_node = ccbNode:nodeForName("m_node")

            local itemData = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemData)

            if icon then
                m_node:removeAllChildrenWithCleanup(true)
                m_node:addChild(icon)
            end
            if name then
                m_name_label:setString(name)
            end
            if count then
                m_limit_label:setString("×" .. count)
            end
            selectTableLen = math.min(selectTableLen,3)
            local money = moneyCfg:getNodeAt(selectTableLen):toInt()
            m_cost_label:setString(money)
            local showFlag = self.selectTable[index+1]
            if showFlag then
                cd_node:setVisible(true)
                money_node:setVisible(false)
            else
                cd_node:setVisible(false)
                money_node:setVisible(true)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.selectTable[index+1] then
                self.selectTable[index+1] = nil
            else
                self.selectTable[index+1] = 1
            end
            self:refreshUi()
        end
    end
    return TableViewHelper:createGallery3(params);
end
--[[--
    刷新ui
]]
function game_pirate_box_pop.refreshUi(self)
    self.table_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.table_node:getContentSize());
    self.table_node:addChild(tableViewTemp);
    -- self.m_num_label:setString(tostring(game_data:getUserStatusDataByKey("coin") or 0));
end

--[[--
    初始化
]]
function game_pirate_box_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callFunc = t_params.callFunc;
    self.building = t_params.buildingId 
    self.m_landItemOpenType = t_params.landItemOpenType or 1;
    self.city = t_params.city
    self.recapture_log = t_params.recapture_log
    self.treasure = t_params.treasure
    self.gameData = t_params.gameData

    self.selectTable = {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_box_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_box_pop;