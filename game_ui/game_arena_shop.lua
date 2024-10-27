---  竞技场购买

local game_arena_shop = {
    m_tGameData = nil,
    m_list_view_bg = nil,
    m_title_label = nil,
    m_num_label = nil,
    m_curPage = nil,
    m_shopItemIdTab = nil,
    buy_max_count = nil,
    already_count = nil,
    money_icon = nil,
    point = nil,
    m_root_layer = nil,
    m_moveFlag = nil,
    m_shopData = nil,
};

--[[--
    销毁ui
]]
function game_arena_shop.destroy(self)
    -- body
    cclog("-----------------game_arena_shop destroy-----------------");
    self.m_tGameData = nil;
    self.m_list_view_bg = nil;
    self.m_title_label = nil;
    self.m_num_label = nil;
    self.m_curPage = nil;
    self.m_shopItemIdTab = nil;
    self.buy_max_count = nil;
    self.already_count = nil;
    self.money_icon = nil;
    self.point = nil;
    self.m_root_layer = nil;
    self.m_moveFlag = nil;
    self.m_shopData = nil;
end
--[[--
    返回
]]
function game_arena_shop.back(self,backType)
    
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
end
--[[--
    读取ccbi创建ui
]]
function game_arena_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_shop.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.money_icon = ccbNode:spriteForName("money_icon");
    self.money_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_medal.png"))

    self.m_title_label:setString(string_helper.game_arena_shop.arena_buy)
    self.buy_max_count = 10;
    self.already_count = 1;

    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_moveFlag = false;
            touchBeginPoint = {x = x, y = y}
            return true;--intercept event
        elseif eventType == "moved" then
            if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
                self.m_moveFlag = true;
            end
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


--[[--
    创建竞技场购买
]]
function game_arena_shop.createTableView(self,viewSize)    
    cclog("!!!!!!!!!!")
    local arenaShopConfig = getConfig(game_config_field.arena_shop);
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local itemsCount = arenaShopConfig:getNodeCount()
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)

    local function onMainBtnClick(target,event)
        -- if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            cclog("btnTag == " .. btnTag) 
            local index = btnTag-101
            local gameShop = arenaShopConfig:getNodeAt(index)
            local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
            local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()
            if level >= down_limit and level <= up_limit then
                if(self.point<=0)then
                    game_util:addMoveTips({text = string_helper.game_arena_shop.text});
                    return;
                end
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    cclog("------buy----\n" .. data:getFormatBuffer());
                    self.point = data:getNodeWithKey("point"):toInt();
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    local exchange_log_tab = json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
                    for k,v in pairs(exchange_log_tab) do
                        self.m_exchange_log_tab[k] = v;
                    end
                    self:refreshUi()
                end
                local params = {};
                params.shop_id = gameShop:getKey()
                params.count = 1;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, params,"arena_exchange")
            else
                game_util:addMoveTips({text = string_helper.game_arena_shop.text2});
            end
        -- end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.showPoint = false;
    params.totalItem = totalItem;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_pk_buy_pop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local iCountText = tolua.cast(ccbNode:objectForName("m_count"),"CCLabelBMFont");
                local iIconNode = tolua.cast(ccbNode:objectForName("m_icon"),"CCLayer");
                local m_limit_label = tolua.cast(ccbNode:objectForName("m_limit_label"),"CCLabelBMFont");
                local m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"),"CCLabelBMFont");
                local btn_buy = tolua.cast(ccbNode:objectForName("m_buy_btn"),"CCControlButton")
                game_util:setCCControlButtonTitle(btn_buy,string_helper.ccb.title107)
                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local open_text = ccbNode:labelTTFForName("open_text")  
                -- if open_text then open_text:setString(string_helper.ccb.file77) end
                open_text:setString(string_helper.ccb.file77)
                local cd_node_2 = ccbNode:nodeForName("cd_node_2")
                m_name_label:setString("");

                local gameShop = arenaShopConfig:getNodeAt(index)
                -- cclog("gameShop == " .. gameShop:getFormatBuffer())
                local times = gameShop:getNodeWithKey("times"):toInt();
                
                local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
                local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()

                local shop_reward = gameShop:getNodeWithKey("shop_reward")
                iIconNode:removeAllChildrenWithCleanup(true);

                cd_node:setVisible(false)
                cd_node_2:setVisible(false)
                if shop_reward:getNodeCount() > 0 then
                    local icon,name,count = game_util:getRewardByItem(shop_reward:getNodeAt(0));
                    if icon then
                        local size = iIconNode:getContentSize();
                        icon:setPosition(ccp(size.width/2,size.height/2));
                        iIconNode:addChild(icon);
                    end
                    if name then
                        m_name_label:setString(name);
                        if times == -1 then
                            -- m_limit_label:setString("不限次");
                        else
                            local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
                            cclog2(exchange_log_item,"exchange_log_item")
                            if exchange_log_item then
                                -- m_limit_label:setString("兑换限制：" .. exchange_log_item.times .. "/" .. times);
                                m_name_label:setString(name .. "(" .. (times-exchange_log_item.times) .. ")")

                                if (times-exchange_log_item.times) == 0 then
                                    local refresh = gameShop:getNodeWithKey("refresh"):toInt()
                                    if refresh == 1 then--每天刷新
                                        cd_node:setVisible(true)
                                        m_cdTime:setString(string_helper.game_arena_shop.day_refresh)
                                        cd_node_2:setVisible(false)
                                    elseif refresh == 0 then--只能买一次
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(true)
                                    else
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(false)
                                    end
                                else
                                    cd_node:setVisible(false)
                                    cd_node_2:setVisible(false)
                                end
                            else
                                -- m_limit_label:setString("兑换限制：" .. "0/" .. times);
                                m_name_label:setString(name .. "(" .. times .. ")")
                            end
                        end
                    end
                    if count > 1 then
                        m_limit_label:setString("×" .. count)
                    else
                        m_limit_label:setString("") 
                    end
                end
                if level < down_limit or level > up_limit then
                    m_name_label:setString("lv." .. down_limit .. "~" .. "lv." .. up_limit .. string_helper.game_arena_shop.valid);
                end
                iCountText:setString(gameShop:getNodeWithKey("need_point"):toInt());
                btn_buy:setTag(101 + index)
            else
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            local gameShop = arenaShopConfig:getNodeAt(index)
            local shop_reward = gameShop:getNodeWithKey("shop_reward")
            local tempTable = json.decode(shop_reward:getNodeAt(0):getFormatBuffer())
            if tempTable then
                game_util:lookItemDetal(tempTable)
            end
            --[[
            -- self:onItemClick_buy(index,id);
            local gameShop = arenaShopConfig:getNodeAt(index)
            local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
            local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()
            cclog("down_limit == " .. down_limit)
            cclog("level = " .. level)
            if level >= down_limit and level <= up_limit then
                local times = gameShop:getNodeWithKey("times"):toInt();--总购买次数
                local alreadyBuy = 0
                if times == -1 then
                    alreadyBuy = 0;
                else
                    local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
                    if exchange_log_item then
                        alreadyBuy = exchange_log_item.times;
                    else
                        alreadyBuy = 0;
                    end
                end

                local t_params = 
                {
                    okBtnCallBack = function(count)
                        if self.m_popUi then
                            self.m_popUi:removeFromParentAndCleanup(true);
                            self.m_popUi = nil;
                        end
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data");
                            cclog("------buy----\n" .. data:getFormatBuffer());
                            self.point = data:getNodeWithKey("point"):toInt();
                            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                            local exchange_log_tab = json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
                            for k,v in pairs(exchange_log_tab) do
                                self.m_exchange_log_tab[k] = v;
                            end
                            self:refreshUi()
                        end
                        cclog("self.point = " ..self.point)
                        if(self.point<=0)then
                            game_util:addMoveTips({text = "缺少竞技点!"});
                            return;
                        end
                        local params = {};
                        params.shop_id = gameShop:getKey()
                        params.count = count;
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, params,"arena_exchange")
                    end,
                    shopItemId = gameShop:getKey(),
                    maxCount = times,--传最大和已买的数量即可
                    alreadyCount = alreadyBuy,--已
                    touchPriority = GLOBAL_TOUCH_PRIORITY,
                    enterType = "game_pk",
                }
                game_scene:addPop("game_shop_pop",t_params)
            else
                game_util:addMoveTips({text = "您的等级不能购买!"});
            end
            ]]--
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建竞技场购买
]]
function game_arena_shop.createTableView2(self,viewSize)    
    local showData = self.m_shopData
    local itemsCount = #showData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local function onMainBtnClick(target,event)
        -- if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            cclog("btnTag == " .. btnTag) 
            local index = btnTag-101
            -- local gameShop = arenaShopConfig:getNodeAt(index)
            local  gameShop = showData[index + 1]
            local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
            local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()
            if level >= down_limit and level <= up_limit then
                if(self.point<=0)then
                    game_util:addMoveTips({text = string_helper.game_arena_shop.text});
                    return;
                end
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    cclog("------buy----\n" .. data:getFormatBuffer());
                    self.point = data:getNodeWithKey("point"):toInt();
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    local exchange_log_tab = json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
                    for k,v in pairs(exchange_log_tab) do
                        self.m_exchange_log_tab[k] = v;
                    end
                    self:refreshUi()
                end
                local params = {};
                params.shop_id = gameShop:getKey()
                params.count = 1;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, params,"arena_exchange")
            else
                game_util:addMoveTips({text = string_helper.game_arena_shop.text2});
            end
        -- end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.showPoint = false;
    params.totalItem = totalItem;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_pk_buy_pop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local iCountText = tolua.cast(ccbNode:objectForName("m_count"),"CCLabelBMFont");
                local iIconNode = tolua.cast(ccbNode:objectForName("m_icon"),"CCLayer");
                local m_limit_label = tolua.cast(ccbNode:objectForName("m_limit_label"),"CCLabelBMFont");
                local m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"),"CCLabelBMFont");
                local btn_buy = tolua.cast(ccbNode:objectForName("m_buy_btn"),"CCControlButton")
                game_util:setCCControlButtonTitle(btn_buy,string_helper.ccb.title107)
                local cd_node = ccbNode:nodeForName("cd_node")
                local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                local cd_node_2 = ccbNode:nodeForName("cd_node_2")
                local open_text = ccbNode:labelTTFForName("open_text")
                if open_text then open_text:setString(string_helper.ccb.file77) end
                m_name_label:setString("");

                local gameShop = showData[index + 1]
                -- cclog("gameShop == " .. gameShop:getFormatBuffer())
                local times = gameShop:getNodeWithKey("times"):toInt();
                
                local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
                local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()

                local shop_reward = gameShop:getNodeWithKey("shop_reward")
                iIconNode:removeAllChildrenWithCleanup(true);

                cd_node:setVisible(false)
                cd_node_2:setVisible(false)
                if shop_reward:getNodeCount() > 0 then
                    local icon,name,count = game_util:getRewardByItem(shop_reward:getNodeAt(0));
                    if icon then
                        local size = iIconNode:getContentSize();
                        icon:setPosition(ccp(size.width/2,size.height/2));
                        iIconNode:addChild(icon);
                    end
                    if name then
                        m_name_label:setString(name);
                        if times == -1 then
                            -- m_limit_label:setString("不限次");
                        else
                            local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
                            cclog2(exchange_log_item,"exchange_log_item")
                            if exchange_log_item then
                                -- m_limit_label:setString("兑换限制：" .. exchange_log_item.times .. "/" .. times);
                                m_name_label:setString(name .. "(" .. (times-exchange_log_item.times) .. ")")

                                if (times-exchange_log_item.times) == 0 then
                                    local refresh = gameShop:getNodeWithKey("refresh"):toInt()
                                    if refresh == 1 then--每天刷新
                                        cd_node:setVisible(true)
                                        m_cdTime:setString(string_helper.game_arena_shop.day_refresh)
                                        cd_node_2:setVisible(false)
                                    elseif refresh == 0 then--只能买一次
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(true)
                                    else
                                        cd_node:setVisible(false)
                                        cd_node_2:setVisible(false)
                                    end
                                else
                                    cd_node:setVisible(false)
                                    cd_node_2:setVisible(false)
                                end
                            else
                                -- m_limit_label:setString("兑换限制：" .. "0/" .. times);
                                m_name_label:setString(name .. "(" .. times .. ")")
                            end
                        end
                    end
                    if count > 1 then
                        m_limit_label:setString("×" .. count)
                    else
                        m_limit_label:setString("") 
                    end
                end
                if level < down_limit or level > up_limit then
                    m_name_label:setString("lv." .. down_limit .. "~" .. "lv." .. up_limit .. string_helper.game_arena_shop.valid);
                end
                iCountText:setString(gameShop:getNodeWithKey("need_point"):toInt());
                btn_buy:setTag(101 + index)
            else
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            -- local gameShop = arenaShopConfig:getNodeAt(index)
            local  gameShop = showData[index + 1]
            local shop_reward = gameShop:getNodeWithKey("shop_reward")
            local tempTable = json.decode(shop_reward:getNodeAt(0):getFormatBuffer())
            if tempTable then
                game_util:lookItemDetal(tempTable)
            end
            --[[
            -- self:onItemClick_buy(index,id);
            local gameShop = arenaShopConfig:getNodeAt(index)
            local up_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(1):toInt()
            local down_limit = gameShop:getNodeWithKey("show_level"):getNodeAt(0):toInt()
            cclog("down_limit == " .. down_limit)
            cclog("level = " .. level)
            if level >= down_limit and level <= up_limit then
                local times = gameShop:getNodeWithKey("times"):toInt();--总购买次数
                local alreadyBuy = 0
                if times == -1 then
                    alreadyBuy = 0;
                else
                    local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
                    if exchange_log_item then
                        alreadyBuy = exchange_log_item.times;
                    else
                        alreadyBuy = 0;
                    end
                end

                local t_params = 
                {
                    okBtnCallBack = function(count)
                        if self.m_popUi then
                            self.m_popUi:removeFromParentAndCleanup(true);
                            self.m_popUi = nil;
                        end
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data");
                            cclog("------buy----\n" .. data:getFormatBuffer());
                            self.point = data:getNodeWithKey("point"):toInt();
                            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                            local exchange_log_tab = json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
                            for k,v in pairs(exchange_log_tab) do
                                self.m_exchange_log_tab[k] = v;
                            end
                            self:refreshUi()
                        end
                        cclog("self.point = " ..self.point)
                        if(self.point<=0)then
                            game_util:addMoveTips({text = "缺少竞技点!"});
                            return;
                        end
                        local params = {};
                        params.shop_id = gameShop:getKey()
                        params.count = count;
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, params,"arena_exchange")
                    end,
                    shopItemId = gameShop:getKey(),
                    maxCount = times,--传最大和已买的数量即可
                    alreadyCount = alreadyBuy,--已
                    touchPriority = GLOBAL_TOUCH_PRIORITY,
                    enterType = "game_pk",
                }
                game_scene:addPop("game_shop_pop",t_params)
            else
                game_util:addMoveTips({text = "您的等级不能购买!"});
            end
            ]]--
        end
    end
    return TableViewHelper:createGallery2(params);
end


--[[--

]]
function game_arena_shop.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end
--[[--
    刷新ui
]]
function game_arena_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    local tableViewTemp = self:createTableView2(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(self.point))
end

function game_arena_shop.formatShopData( self )
    -- body
    self.m_shopData = {}
    local arenaShopConfig = getConfig(game_config_field.arena_shop);
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local itemsCount = arenaShopConfig:getNodeCount()
    for i=1, itemsCount do
        local itemData = arenaShopConfig:getNodeAt( i - 1)
        if itemData then
            local up_limit = itemData:getNodeWithKey("show_level") and itemData:getNodeWithKey("show_level"):getNodeAt(1):toInt() or nil
            local down_limit = itemData:getNodeWithKey("show_level") and itemData:getNodeWithKey("show_level"):getNodeAt(0):toInt() or nil
            if up_limit == nil or down_limit == nil then
                table.insert(self.m_shopData, itemData)
            elseif level <= up_limit and level >= down_limit then
                table.insert(self.m_shopData, itemData)
            else
                cclog2(itemData, "this item can not show because level limit  ===  ")
            end
        end
    end
end


--[[--
    初始化
]]
function game_arena_shop.init(self,t_params)
    t_params = t_params or {};

    self.m_exchange_log_tab = t_params.m_gameData or {};
    self.point = t_params.point
    self:formatShopData()
    -- cclog("self.m_exchange_log_tab == " .. json.encode(self.m_exchange_log_tab))
end

--[[--
    创建ui入口并初始化数据
]]
function game_arena_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_arena_shop;