---  道具购买

local game_metal_shop_scene = {
    m_tGameData = nil,
    m_list_view_bg = nil,
    m_title_label = nil,
    m_num_label = nil,
    m_curPage = nil,
    m_shopItemIdTab = nil,
    buy_max_count = nil,
    already_count = nil,
    m_root_layer = nil,
    m_moveFlag = nil,

    money_icon = nil,
};

--[[--
    销毁ui
]]
function game_metal_shop_scene.destroy(self)
    -- body
    cclog("-----------------game_metal_shop_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_list_view_bg = nil;
    self.m_title_label = nil;
    self.m_num_label = nil;
    self.m_curPage = nil;
    self.m_shopItemIdTab = nil;
    self.buy_max_count = nil;
    self.already_count = nil;
    self.m_root_layer = nil;
    self.m_moveFlag = nil;

    self.money_icon = nil;
end

local shopSortTab = string_helper.game_metal_shop_scene.shopSortTab
local needSortTab = string_helper.game_metal_shop_scene.needSortTab

--[[--
    返回
]]
function game_metal_shop_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_metal_shop_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 102 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_shop.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.money_icon = ccbNode:spriteForName("money_icon")
    local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xilian.png")
    if spriteFrame then
        self.money_icon:setDisplayFrame(spriteFrame)
    end
    self.m_title_label:setString(string_helper.game_metal_shop_scene.prop_buy)
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
    创建购买道具列表
]]
function game_metal_shop_scene.createTableView(self,viewSize)    
    local itemsCount = #self.m_shopItemIdTab;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)

    local function onMainBtnClick(target,event)
        if self.m_moveFlag == false and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local shopItemId = tostring(self.m_shopItemIdTab[btnTag+1]);
            if shopItemId then
                local function responseMethod(tag,gameData)
                    game_data_statistics:buyItem({shopId = shopItemId,count = 1})
                    local data = gameData:getNodeWithKey("data");
                    -- cclog("data = " .. data:getFormatBuffer())   
                    -- game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
                    self.m_tGameData[shopItemId].bought = data:getNodeWithKey("bought"):toInt();

                    -- cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
                    self:refreshUi();

                    local itemData = self.m_tGameData[shopItemId]
                    local im_use = itemData.im_use or 0;
                    if im_use == 1 then
                        local shop_reward = itemData.shop_reward or {}
                        if #shop_reward > 0 then
                            local shop_reward_item = shop_reward[1]
                            if #shop_reward_item > 2 then
                                local tempType = shop_reward_item[1]
                                if tempType == 6 then--道具
                                    local itemId = shop_reward_item[2]
                                    local function responseMethod(tag,gameData)
                                        game_util:addMoveTips({text = string_helper.game_metal_shop_scene.buy_success});
                                    end
                                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = itemId,num = 1},"item_use")
                                end
                            end
                        end
                    else
                        game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
                    end
                end
                local params = {};
                params.shop_id = shopItemId;
                params.count = 1;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_buy_metal_shop"), http_request_method.GET, params,"shop_buy_metal_shop")
            end
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_buy_item_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
            local m_cost_icon_spr = ccbNode:spriteForName("m_cost_icon_spr")
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xilian.png")
            if spriteFrame then
                m_cost_icon_spr:setDisplayFrame(spriteFrame)
            end
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTag(index);
            if index < itemsCount then
                m_buy_btn:setVisible(true);
                m_spr_bg_up:setVisible(false);
                local tempId = tostring(self.m_shopItemIdTab[index+1]);
                -- cclog("tempId == " .. tempId)
                local itemData = self.m_tGameData[tempId]
                if itemData then
                    local m_node = ccbNode:nodeForName("m_node");
                    m_node:removeAllChildrenWithCleanup(true);
                    local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
                    local m_name_label = ccbNode:labelTTFForName("m_name_label")
                    local m_limit_label = ccbNode:labelBMFontForName("m_limit_label")
                    local bought = itemData.bought
                    bought = bought < 0 and 0 or bought;
                    
                    local shop_reward = itemData.shop_reward
                    local sell_max = itemData.sell_max or 0
                    local rewardCount = #shop_reward;
                    if rewardCount > 0 then
                        local icon,name,count = game_util:getRewardByItemTable(shop_reward[1]);
                        if icon then
                            icon:setScale(0.9)
                            m_node:addChild(icon);
                        end
                        if name then
                            if sell_max == 0 then
                                m_name_label:setString(name);
                            else
                                m_name_label:setString(name .. "(" .. (sell_max-bought)..")")
                            end
                        end
                        if count > 1 then
                            m_limit_label:setString("×" .. count)
                        else
                            m_limit_label:setString("")
                        end
                    end
                    local need_value = itemData.need_value or {}
                    local need_value_count = #need_value
                    if need_value_count > 0 then
                        m_cost_label:setString(need_value[math.max(1,math.min(bought+1,need_value_count))]);
                    else
                        m_cost_label:setString("0");
                    end
                    local cd_node = ccbNode:nodeForName("cd_node")
                    local m_cdTime = ccbNode:labelTTFForName("m_cdTime")
                    local open_text = ccbNode:labelTTFForName("open_text")
                    if open_text then open_text:setString(string_helper.ccb.file77) end
                    local sell_sort = itemData.sell_sort or 0
                    if sell_sort == 1 then
                        if sell_max-bought == 0 then
                            cd_node:setVisible(true)
                            m_cdTime:setString(string_helper.game_metal_shop_scene.day_refresh)
                        else
                            cd_node:setVisible(false)
                        end
                    elseif sell_sort == 2 then
                        if sell_max-bought == 0 then
                            cd_node:setVisible(true)
                            m_cdTime:setString(string_helper.game_metal_shop_scene.week_refresh)
                        end
                    else--不限次数
                        cd_node:setVisible(false)
                    end
                end
            else
                m_buy_btn:setVisible(false);
                m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local tempId = tostring(self.m_shopItemIdTab[index+1]);
            local itemData = self.m_tGameData[tempId]
            if itemData then
                local sell_max = itemData.sell_max or 0
                -- if sell_max == 0 then
                --     sell_max = 99
                -- end
                local bought = itemData.bought
                bought = bought < 0 and 0 or bought;
                self.buy_max_count = sell_max;
                self.already_count = bought;
                local shop_reward = itemData.shop_reward or {}
                if #shop_reward > 0 then
                    local shop_reward_item = shop_reward[1]
                    if #shop_reward_item > 2 then
                        local tempType = shop_reward_item[1]
                        if tempType == 6 then--道具
                            local itemId = shop_reward_item[2]
                            function buy_call_back(count,shopId)
                                -- self:removePop();
                                game_scene:removePopByName("game_item_info_pop");
                                self.m_tGameData[shopId].bought = count
                                self:refreshUi();
                            end
                            game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 10,maxCount = self.buy_max_count,alreadyCount = self.already_count,tempId = tempId,buy_call_back = buy_call_back,enterType = "game_metal_shop_scene",buyUrl = "shop_buy_metal_shop"})
                        elseif tempType == 7 then--装备
                            local equipId = shop_reward_item[2]
                            local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                            game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                        elseif tempType == 5 then--卡牌
                            local cId = shop_reward_item[2]
                            game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                        else
                            function buy_call_back(count,shopId)
                                -- self:removePop();
                                game_scene:removePopByName("game_food_info_pop");
                                self.m_tGameData[shopId].bought = count
                                self:refreshUi();
                            end
                            game_scene:addPop("game_food_info_pop",{itemId = itemId,itemData = shop_reward_item,openType = 2,maxCount = self.buy_max_count,alreadyCount = self.already_count,tempId = tempId,buy_call_back = buy_call_back,enterType = "game_metal_shop_scene",buyUrl = "shop_buy_metal_shop"})
                        end
                    end
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--

]]
function game_metal_shop_scene.getIconAndName(self,shop_sort,value)
    -- "卡牌","装备","道具","能晶"
    local icon,name;
    if shop_sort == 1 then
        icon,name = game_util:createCardIconByCid(value)
    elseif shop_sort == 2 then
        icon,name = game_util:createEquipIconByCid(value)
    elseif shop_sort == 3 then
        icon,name = game_util:createItemIconByCid(value)
    elseif shop_sort == 4 then
        icon,name = nil,shopSortTab[shop_sort]
    end
    return icon,name;
end
--[[--

]]
function game_metal_shop_scene.getBuySuccessTipsText(self,itemCfg)
    local shop_sort = itemCfg:getNodeWithKey("shop_sort"):toInt();
    local value = itemCfg:getNodeWithKey("value"):toInt();
    local get_num = itemCfg:getNodeWithKey("get_num"):toInt();
    local need_sort = itemCfg:getNodeWithKey("need_sort"):toInt();
    local need_value = itemCfg:getNodeWithKey("need_value"):toInt();
    local text = "";
    local icon,name = self:getIconAndName(shop_sort,value)
    if shop_sort == 1 then
        text = string_helper.game_metal_shop_scene.success_buy  .. get_num .. string_helper.game_metal_shop_scene.zhang .. tostring(name) ..  tostring(shopSortTab[shop_sort]);
    elseif shop_sort == 2 then
        text = string_helper.game_metal_shop_scene.success_buy .. get_num .. string_helper.game_metal_shop_scene.jian .. tostring(name) ..  tostring(shopSortTab[shop_sort]);
    elseif shop_sort == 3 then
        text = string_helper.game_metal_shop_scene.success_buy .. get_num .. string_helper.game_metal_shop_scene.ge .. tostring(name) ..  tostring(shopSortTab[shop_sort]);
    elseif shop_sort == 4 then
        text = string_helper.game_metal_shop_scene.success_buy .. get_num .. string_helper.game_metal_shop_scene.ge ..  tostring(shopSortTab[shop_sort]);
    end
    return text;
end

--[[--

]]
function game_metal_shop_scene.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end
--[[--

]]
function game_metal_shop_scene.getBuyText(self,itemCfg,bought)
    local need_sort = itemCfg:getNodeWithKey("need_sort"):toInt();
    local need_value = itemCfg:getNodeWithKey("need_value"):toInt();
    local text = "";
    local icon,name = nil,"";
    local shop_reward = itemCfg:getNodeWithKey("shop_reward")
    local rewardCount = shop_reward:getNodeCount();
    if rewardCount > 0 then
        icon,name,count = game_util:getRewardByItem(shop_reward:getNodeAt(0));
    end
    bought = bought or 0;
    bought = bought < 0 and 0 or bought;
    local need_value = itemCfg:getNodeWithKey("need_value");
    local need_value_count = need_value:getNodeCount();
    local cost_value = 0;
    if need_value_count > 0 then
        cost_value = need_value:getNodeAt(math.min(bought,need_value_count-1)):toInt()
    end
    text = string_helper.game_metal_shop_scene.sure_cost .. cost_value .. tostring(needSortTab[need_sort]) .. string_helper.game_metal_shop_scene.buy .. name;
    return text;
end

--[[--
    刷新ui
]]
function game_metal_shop_scene.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(game_data:getUserStatusDataByKey("metalcore") or 0));
end

--[[--
    初始化
]]
function game_metal_shop_scene.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getNodeWithKey("items"):getFormatBuffer())
    end
    self.m_tGameData = self.m_tGameData or {};
    -- cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
    self.m_shopItemIdTab = {};
    for k,v in pairs(self.m_tGameData) do
        self.m_shopItemIdTab[#self.m_shopItemIdTab + 1] = k;
    end
    local function sortFunc(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort( self.m_shopItemIdTab, sortFunc)
    -- for i=1,#self.m_tGameData do
    --     self.m_shopItemIdTab[tostring(i)] = self.m_tGameData[tostring(i)]
    -- end
    -- cclog("self.m_shopItemIdTab == " .. json.encode(self.m_shopItemIdTab))
    self.m_moveFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_metal_shop_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_metal_shop_scene;