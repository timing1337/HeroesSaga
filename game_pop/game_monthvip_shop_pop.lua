---  月卡商城

local game_monthvip_shop_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_idTab = nil,
    m_shopItemIdTab = nil,
    m_shopData = nil,
    m_isMonthVIP = nil,
    m_lastTableViewPosY = nil,
    m_tableView = nil,
    m_data = nil,
    m_lable_refretime = nil,
    m_actionNode = nil,
    m_enterUiTime = nil,
};
--[[--
    销毁ui
]]
function game_monthvip_shop_pop.destroy(self)
    -- body
    cclog("----------------- game_monthvip_shop_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;
    self.m_shopItemIdTab = nil;
    self.m_shopData = nil;
    self.m_isMonthVIP = nil;
    self.m_lastTableViewPosY = nil;
    self.m_tableView = nil;
    self.m_data = nil;
    self.m_lable_refretime = nil;
    self.m_actionNode = nil;
    self.m_enterUiTime = nil;
end
--[[--
    返回
]]
function game_monthvip_shop_pop.back(self,backType)
    game_scene:removePopByName("game_monthvip_shop_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_monthvip_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then  -- 去月卡商城
            self:back()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_monthvip_shop_pop.ccbi");

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then return true;  end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    local m_conbtn_shop = ccbNode:controlButtonForName("m_conbtn_shop")
    m_conbtn_shop:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3)
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3);
    self.m_list_view_bg = ccbNode:nodeForName("m_node_showitems")
    self.m_lable_refretime = ccbNode:labelTTFForName("m_lable_refretime")
    local title149 = ccbNode:labelTTFForName("title149");
    local title150 = ccbNode:labelTTFForName("title150");
    local title151 = ccbNode:labelTTFForName("title151");
    local title1505 = ccbNode:labelTTFForName("title1505");
    title149:setString(string_helper.ccb.title149);
    title150:setString(string_helper.ccb.title150);
    title1505:setString(string_helper.ccb.title1505);
    title151:setString(string_helper.ccb.title151);
    self.m_actionNode = CCNode:create()
    ccbNode:addChild(self.m_actionNode)
    self.m_enterUiTime = os.time();
    return ccbNode;
end

--[[--
    创建购买道具列表
]]
function game_monthvip_shop_pop.createTableView(self,viewSize)

    local shopData = self.m_data.shop or {}
    local showData = {}
    for k,v in pairs(shopData) do
        if type(v) == "table" and v.need_value then
            table.insert(showData, {key = k, data = v})
        end
    end
    -- cclog2(showData, "showData   ===  ")
    local function onCellBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local shopId = showData[btnTag + 1].key
            function buyfun( )
                local function responseMethod(tag,gameData)
                    if gameData then
                        game_data_statistics:buyItem({shopId = shopId,count = 1})
                        local data = gameData:getNodeWithKey("data");
                        -- cclog("data = " .. data:getFormatBuffer())   
                        -- game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
                        -- cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
                        if data then
                             self.m_data = json.decode( data:getFormatBuffer())
                        end
                        self.m_enterUiTime = os.time();
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    end
                    self:refreshUi();
                end
                local params = {};
                params.shop_id = shopId;
                params.count = 1;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("card_shop_buy"), http_request_method.GET, params,"card_shop_buy", true, true)
            end
            if self.m_isMonthVIP then
                buyfun()
            else
                game_scene:addPop("ui_monthvip_shop_novip_pop", {itemData = showData[btnTag + 1].data , endCallFunc = buyfun})
            end
    end

    local onBtnCilck = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag, "onBtnCilck  btnTag  ===  ")
        local itemData = showData[btnTag + 1] and showData[btnTag + 1].data or {}
        game_util:lookItemDetal( itemData.shop_reward and itemData.shop_reward[1]  or {})
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 3
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index)
        local cell = tableView:dequeueCell()
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_monthvip_shop_item.ccbi");
            ccbNode:controlButtonForName("m_conbtn_buy"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-3)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_buy_btn = ccbNode:controlButtonForName("m_conbtn_buy");
            game_util:setCCControlButtonTitle(m_buy_btn,string_helper.ccb.title153)
            m_buy_btn:setTag(index);
            local m_title_label = ccbNode:labelTTFForName("m_label_itemname")
            local m_cost_label = ccbNode:labelTTFForName("m_label_perprice")
            local m_label_curprice = ccbNode:labelTTFForName("m_label_curprice")
            local m_buy_flag = ccbNode:labelBMFontForName("m_buy_flag")
            if m_buy_flag then m_buy_flag:setString( string_helper.ccb.file78 ) end
            local m_imgNode = ccbNode:nodeForName("m_node_showicon")
            m_imgNode:removeAllChildrenWithCleanup(true);
            m_title_label:setString("")
            m_cost_label:setString("0")
            m_label_curprice:setString("0")

            local itemData = showData[index + 1].data
            if self.m_data.bought[showData[index + 1].key] then
                game_util:setCCControlButtonEnabled(m_buy_btn, false)
                game_util:setCCControlButtonTitle(m_buy_btn, string_helper.game_monthvip_shop_pop.buyed)
            else
                game_util:setCCControlButtonEnabled(m_buy_btn, true)
                game_util:setCCControlButtonTitle(m_buy_btn, string_helper.game_monthvip_shop_pop.buy)
            end
            if itemData then
                m_cost_label:setString(tostring(itemData.show_value))
                m_label_curprice:setString(tostring(itemData.need_value))
                local reward = itemData.shop_reward or {}
                if #reward > 0 then
                    -- cclog2(reward[1], "reward[1]   ===  ")
                    local icon,name,count = game_util:getRewardByItemTable(reward[1])
                    if icon then
                        icon:setPosition( ccp(m_imgNode:getContentSize().width * 0.5, m_imgNode:getContentSize().height * 0.5) )
                        icon:setScale(1)
                        m_imgNode:addChild(icon)

                        if count then
                            local m_num_label = game_util:createLabelBMFont({text = "x" .. tostring(count)})
                            m_num_label:setAnchorPoint( ccp(0.5, 0.5) )
                            m_num_label:setPosition( icon:getContentSize().width * 0.5, -5 )
                            icon:addChild( m_num_label, 10 )
                        end
                        if name then
                            m_title_label:setString(tostring(name))
                        end
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
                        button:setOpacity(0)
                        icon:addChild(button)
                        button:setTag(index)
                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_monthvip_shop_pop.refreshTableView(self)
    if self.m_tableView then
        self.m_lastTableViewPosY = self.m_tableView:getContentOffset().y
    end

    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    -- 重置位置
    if self.m_lastTableViewPosY then
        local contentSize = self.m_tableView:getContentSize()
        self.m_lastTableViewPosY = math.max(-1 * contentSize.height, self.m_lastTableViewPosY)
        self.m_tableView:setContentOffset(ccp(0, math.min(self.m_lastTableViewPosY, 0) ));
    end
end

--[[--
    商店刷新
]]
function game_monthvip_shop_pop.refreshShopItems( self )
    local function responseMethod(tag,gameData)
        if gameData and gameData:getNodeWithKey("data") then
            self.m_data = json.decode( gameData:getNodeWithKey("data"):getFormatBuffer())
            self.m_enterUiTime = os.time();
        end
        self:refreshUi();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("card_shop_open"), http_request_method.GET, nil,"card_shop_open")
end

--[[--
    刷新ui
]]
function game_monthvip_shop_pop.refreshUi(self)
    self:refreshTableView();
    local lastTime = self.m_data.expire
    if lastTime and lastTime > -1 then
        if lastTime == 0 then
            self:refreshShopItems()
        else
            local function timeEndFunc2(label,type)
                self:refreshShopItems()
            end
            local day = 3600 * 24
            function coutdown( time )
                time = time or 0
                local timeText = ""
                local day = math.floor(time/86400)
                if day > 0 then timeText = timeText .. day .. string_helper.game_monthvip_shop_pop.day end
                time = time - 86400 * day
                local hour = math.floor(time/3600)
                if hour > 0 then timeText = timeText .. hour .. string_helper.game_monthvip_shop_pop.hour end
                local m = math.floor(math.floor(time%3600)/ 60)
                -- if m >0 then timeText = timeText .. string.format("%2d",m) .. ":" end
                -- local s = math.floor(time % 60)
                -- timeText = timeText .. string.format("%2d",s) .. "  "
                timeText = timeText .. string.format(string_helper.game_monthvip_shop_pop.refreshTime, m)
                self.m_lable_refretime:setString(timeText or "")
            end

            local time = lastTime - (os.time() - self.m_enterUiTime)
            if time > 1 then 
                coutdown(time)
            else
                timeEndFunc2()
                self.m_actionNode:stopAllActions()
            end

           
            schedule(self.m_actionNode , function ()
                local time = lastTime - (os.time() - self.m_enterUiTime)
                if time > 1 then 
                    coutdown(time)
                else
                    self.m_actionNode:stopAllActions()
                    timeEndFunc2()
                end
            end, 1)
        end
    end
end
--[[--
    初始化
]]
function game_monthvip_shop_pop.init(self,t_params)
    t_params = t_params or {}

    local data = t_params.gameData and t_params.gameData:getNodeWithKey("data") or nil
    self.m_data = data and json.decode(data:getFormatBuffer()) or {}
    self.m_isMonthVIP = t_params.isMonthVIP

end
--[[--
    创建ui入口并初始化数据
]]
function game_monthvip_shop_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_monthvip_shop_pop;