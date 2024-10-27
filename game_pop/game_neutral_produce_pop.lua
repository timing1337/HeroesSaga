--- 生产

local game_neutral_produce_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_ok_btn = nil,
    m_list_view_bg_1 = nil,
    m_list_view_bg_2 = nil,
    m_name_label = nil,
    m_time_label = nil,
    m_gain_label = nil,
    m_worker_icon_node = nil,
    m_work_detail_label = nil,
    m_refresh_btn = nil,
    m_cost_coin_label = nil,
    m_sel_seed_id = nil,
    m_map_id = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
};
--[[--
    销毁ui
]]
function game_neutral_produce_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_produce_pop destroy-----------------");
    self.m_root_layer = nil
    self.m_close_btn = nil
    self.m_ok_btn = nil
    self.m_list_view_bg_1 = nil
    self.m_list_view_bg_2 = nil
    self.m_name_label = nil
    self.m_time_label = nil
    self.m_gain_label = nil
    self.m_worker_icon_node = nil
    self.m_work_detail_label = nil
    self.m_refresh_btn = nil
    self.m_cost_coin_label = nil
    self.m_sel_seed_id = nil
    self.m_map_id = nil
    self.m_callBackFunc = nil
    self.m_tips_label = nil
end
--[[--
    返回
]]
function game_neutral_produce_pop.back(self,backType)
    game_scene:removePopByName("game_neutral_produce_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_produce_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--开始生产
            if self.m_map_id == nil then
                game_util:addMoveTips({text = string_helper.game_neutral_produce_pop.dataError})
                return
            end
            if self.m_sel_seed_id == nil then
                game_util:addMoveTips({text = string_helper.game_neutral_produce_pop.noSed})
                return
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("public_land_data",json.decode(data:getFormatBuffer()))
                game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
                self:back()
            end
            -- map_id=3&seed_id=1
            local params = {}
            params.map_id = self.m_map_id
            params.seed_id = self.m_sel_seed_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_sow_seed"), http_request_method.GET, params,"public_land_sow_seed")
        elseif btnTag == 3 then--工人刷新
            if self.m_map_id == nil then
                game_util:addMoveTips({text = string_helper.game_neutral_produce_pop.dataError})
                return
            end
            local function responseMethod(tag,gameData)
                game_util:addMoveTips({text = string_helper.game_neutral_produce_pop.refresh})
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("public_land_data",json.decode(data:getFormatBuffer()))
                game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
                self:refreshUi()
            end
            -- map_id=3&seed_id=1
            local params = {}
            params.map_id = self.m_map_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_refresh_worker"), http_request_method.GET, params,"public_land_refresh_worker")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_game_neutral_produce_pop.ccbi")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_list_view_bg_1 = ccbNode:nodeForName("m_list_view_bg_1")
    self.m_list_view_bg_2 = ccbNode:nodeForName("m_list_view_bg_2")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_gain_label = ccbNode:labelTTFForName("m_gain_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_worker_icon_node = ccbNode:nodeForName("m_worker_icon_node")
    self.m_work_detail_label = ccbNode:labelTTFForName("m_work_detail_label")
    self.m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    self.m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_cost_coin_label = ccbNode:labelTTFForName("m_cost_coin_label")
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    
]]
function game_neutral_produce_pop.refreshTabelView(self,viewParentNode,own_seed)
    local selTableViewCell = nil
    viewParentNode:removeAllChildrenWithCleanup(true)
    local seed_cfg = getConfig(game_config_field.seed)
    own_seed = own_seed or {}
    local showData = {}
    for k,v in pairs(own_seed) do
        if v > 0 then
            table.insert(showData,k)
        end
    end
    local showCount = #showData
    self.m_tips_label:setVisible(showCount == 0)
    self.m_sel_seed_id = showData[1]
    self:refreshSelectSeed(self.m_sel_seed_id)
    local params = {};
    local viewSize = viewParentNode:getContentSize()
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 2; --列
    params.direction = direction or kCCScrollViewDirectionVertical;
    params.totalItem = showCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local key = showData[index+1] or ""
            local count = own_seed[key] or 0
            local itemCfg = seed_cfg:getNodeWithKey(key)
            if itemCfg then
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr(),quality)
                if icon then
                    -- icon:setScale(0.65);
                    icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                    cell:addChild(icon)
                end
                if count then
                    local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(0,255,0),fontSize = 8});
                    tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5-20))
                    cell:addChild(tempLabel)
                end
            end
            if self.m_sel_seed_id == key then
                selTableViewCell = cell
                local selSprite = CCSprite:createWithSpriteFrameName("zldt_xuanzhong.png")
                selSprite:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                cell:addChild(selSprite,10,10)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- game_util:lookItemDetal(rewardTab[index+1])
            if selTableViewCell then
                selTableViewCell:removeChildByTag(10,true)
            end
            selTableViewCell = cell
            local key = showData[index+1]
            self.m_sel_seed_id = key
            local selSprite = CCSprite:createWithSpriteFrameName("zldt_xuanzhong.png")
            selSprite:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(selSprite,10,10)
            self:refreshSelectSeed(self.m_sel_seed_id)
        end
    end
    local tempView = TableViewHelper:create(params)
    viewParentNode:addChild(tempView)
end

--[[--
    刷新
]]
function game_neutral_produce_pop.refreshSelectSeed(self,key)
    local seed_cfg = getConfig(game_config_field.seed)
    local itemCfg = seed_cfg:getNodeWithKey(tostring(key))
    if itemCfg then
        self.m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr())
        self.m_time_label:setString(game_util:formatTime(itemCfg:getNodeWithKey("time"):toInt()*60))
        local tempStr = ""
        local reward = itemCfg:getNodeWithKey("reward")
        local tempCount = reward:getNodeCount()
        for i=1,tempCount do
            local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),true)
            -- if i == tempCount then
            --     tempStr = tempStr .. name
            -- else
                tempStr = tempStr .. name .. "\n"
            -- end
        end
        self.m_gain_label:setString(tempStr .. string_helper.game_neutral_produce_pop.randomReward)
    end
end

--[[--
    刷新ui
]]
function game_neutral_produce_pop.refreshUi(self)
    self.m_worker_icon_node:removeAllChildrenWithCleanup(true)
    local gameData = game_data:getDataByKey("public_land_data") or {}
    self:refreshTabelView(self.m_list_view_bg_1,gameData.own_seed)
    local refresh_worker_times = gameData.refresh_worker_times or 0
    local canBuy,payValue = game_util:getCostCoinBuyTimes("27",refresh_worker_times)
    self.m_cost_coin_label:setString(tostring(payValue))
    local worker_cfg = getConfig(game_config_field.worker)
    local map = gameData.map or {}
    local itemData = map[tostring(self.m_map_id)]
    if itemData then
        local worker_id = itemData.worker_id or 0
        local worker_cfg_item = worker_cfg:getNodeWithKey(tostring(worker_id))
        local iconName,detailMsg,quality = "i_worker_default.png",string_helper.game_neutral_produce_pop.random,1
        if worker_cfg_item then
            quality = worker_cfg_item:getNodeWithKey("quality"):toInt()
            iconName = worker_cfg_item:getNodeWithKey("icon"):toStr()
            detailMsg = worker_cfg_item:getNodeWithKey("name"):toStr()
        end
        local icon = game_util:createIconByName(iconName,quality)
        if icon then
            icon:setScale(0.8)
            self.m_worker_icon_node:addChild(icon)
        end
        self.m_work_detail_label:setString(detailMsg)
    else
        self.m_work_detail_label:setString(string_helper.game_neutral_produce_pop.cfgError)
    end 
end
--[[--
    初始化
]]
function game_neutral_produce_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_map_id = t_params.map_id or ""
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_produce_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_neutral_produce_pop;