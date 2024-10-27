---  押镖商店
local game_dart_shop = {
    m_add_googs_node = nil,
    m_add_googs_sprite = nil,
    m_list_view_bg = nil,
    m_num_label = nil,
    m_free_refresh_label = nil,
    m_add_tips_label = nil,
    m_tips_label = nil,
    m_create_team_btn = nil,
};
--[[--
    销毁ui
]]
function game_dart_shop.destroy(self)
    -- body
    cclog("-----------------game_dart_shop destroy-----------------");
    self.m_add_googs_node = nil;
    self.m_add_googs_sprite = nil;
    self.m_list_view_bg = nil;
    self.m_num_label = nil;
    self.m_free_refresh_label = nil;
    self.m_add_tips_label = nil;
    self.m_tips_label = nil;
    self.m_create_team_btn = nil;
end
--[[--
    返回
]]
function game_dart_shop.back(self,backType)
    local function responseMethod(tag,gameData)
        -- local is_sail = gameData:getNodeWithKey("data"):getNodeWithKey("is_sail"):toInt()--是否开始运送货物了
        -- if is_sail == 1 then
        --     game_scene:enterGameUi("game_dart_route",{gameData = gameData})
        -- else
        --     local identity = gameData:getNodeWithKey("data"):getNodeWithKey("identity"):toInt()--0是无对1是队长2是队员
        --     if identity == 0 then
                game_scene:enterGameUi("game_dart_main",{gameData = gameData});
        --     else
        --         game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,identity = identity})
        --     end
        -- end
        -- self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--刷新
            local shop_free_fresh_times = self.m_tGameData.shop_free_fresh_times or 0
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:addMoveTips({text = string_helper.game_dart_shop.refresh_success})
            end
            if shop_free_fresh_times > 0 then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_shop_fresh"), http_request_method.GET, nil,"escort_shop_fresh")
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_coin_shop_fresh"), http_request_method.GET, nil,"escort_coin_shop_fresh")
            end
        elseif btnTag == 3 then--添加货物
            self:addGood();
        elseif btnTag == 4 then--背包
            -- local function responseMethod(tag,gameData)
                game_scene:addPop("game_dart_goods",{gameData = self.m_tGameData,enterType = "look"})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_my_goods"), http_request_method.GET, nil,"escort_my_goods")
        elseif btnTag == 5 then--下一步
            local sel_dart_good = game_data:getDataByKey("sel_dart_good")
            if sel_dart_good == nil then
                -- game_util:addMoveTips({text = "请选择货物！"})
                self:addGood();
                return;
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_team_recruitment",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_team_index"), http_request_method.GET, nil,"escort_team_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_shop.ccbi");
    
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.m_free_refresh_label = ccbNode:labelTTFForName("m_free_refresh_label")
    self.m_add_googs_node = ccbNode:nodeForName("m_add_googs_node")
    self.m_add_googs_sprite = ccbNode:spriteForName("m_add_googs_sprite")
    self.m_add_tips_label = ccbNode:labelTTFForName("m_add_tips_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_create_team_btn = ccbNode:controlButtonForName("m_create_team_btn")

    return ccbNode;
end


--[[--
    创建道具列表
]]
function game_dart_shop.createTableView(self,viewSize)
    local showDataTable = self.m_tGameData.shop_goods
    local showData = {}
    for k,v in pairs(showDataTable) do
        table.insert(showData,k)
    end
    table.sort(showData,function(data1,data2) return tonumber(data1) <  tonumber(data2) end)
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();

        local function responseMethod(tag,gameData)
            -- cclog2(gameData:getNodeWithKey("data"))
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            local buy_goods_id = tostring(self.m_tGameData.buy_goods_id or "")
            local goods = self.m_tGameData.goods or {}
            local buyGoodData = goods[buy_goods_id]
            if buyGoodData then
                game_data:setDataByKeyAndValue("sel_dart_good",{goodId = tostring(buy_goods_id),goodData = buyGoodData.goods[1]})
            end
            self:refreshUi()
            game_util:rewardTipsByJsonData(reward)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_buy_goods"), http_request_method.GET, {goods_id = showData[btnTag+1]},"escort_buy_goods")
    end
    local itemsCount = #showData
    -- local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_shop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
            game_util:setControlButtonTitleBMFont(m_buy_btn);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local itemData = showDataTable[showData[index+1]]
            local price = itemData.price
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_time_label = ccbNode:labelTTFForName("m_time_label")
            local m_icon = ccbNode:nodeForName("m_icon")
            local m_count = ccbNode:labelBMFontForName("m_count")
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            local black_bg = ccbNode:layerColorForName("black_bg")
            m_buy_btn:setTag(index)

            m_icon:removeAllChildrenWithCleanup(true)
            m_count:setString(tostring(price))
            local goods = itemData.goods[1]
            local icon,name,count = game_util:getRewardByItemTable(goods)
            if icon then
                icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
                m_icon:addChild(icon,10)
                if count then
                    local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                    countLabel:setPosition(ccp(50,10))
                    m_icon:addChild(countLabel,10)
                end
            end
            if name then
                m_name_label:setString(name)
            end
            local is_buy = itemData.is_buy
            if is_buy == 0 then--没买过
                black_bg:setVisible(false)
                m_buy_btn:setEnabled(true)
            else
                black_bg:setVisible(true)
                m_buy_btn:setEnabled(false)
            end
            local validity = itemData.validity or 0
            m_time_label:setString(string_helper.game_dart_shop.validity .. tostring(validity) .. string_helper.game_dart_shop.hour)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local itemData = showDataTable[tostring(index+1)]
            local goods = itemData.goods[1]
            game_util:lookItemDetal(goods)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end

function game_dart_shop.addGood(self)
    local function callBackFunc()
        self:refreshGood();
    end
    -- local function responseMethod(tag,gameData)
        game_scene:addPop("game_dart_goods",{gameData = self.m_tGameData,enterType = "select",callBackFunc = callBackFunc})
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_my_goods"), http_request_method.GET, nil,"escort_my_goods")
end

function game_dart_shop.refreshGood(self)
    local sel_dart_good = game_data:getDataByKey("sel_dart_good")
    if sel_dart_good then
        local icon,name,count = game_util:getRewardByItemTable(sel_dart_good.goodData)
        if icon then
            self.m_add_googs_node:removeAllChildrenWithCleanup(true);
            self.m_add_googs_node:addChild(icon);
            self.m_add_googs_sprite:setVisible(false);
            local countLabel = game_util:createLabelBMFont({text = "×" .. tostring(count)});
            countLabel:setPosition(ccp(50,10))
            icon:addChild(countLabel,10)
        end
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_quzudui.png")
    else
        game_util:setCCControlButtonBackground(self.m_create_team_btn,"dart_btn_tianjiahuowu.png")
    end  
end

--[[--
    刷新ui
]]
function game_dart_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTable = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTable);

    local total_coin = game_data:getUserStatusDataByKey("coin") or 0;
    self.m_num_label:setString(tostring(total_coin))
    local shop_free_fresh_times = self.m_tGameData.shop_free_fresh_times or 0
    if shop_free_fresh_times > 0 then
        self.m_free_refresh_label:setString(string_helper.game_dart_shop.free_side .. shop_free_fresh_times)
    else
        local fresh_cost = self.m_tGameData.fresh_cost or 0
        self.m_free_refresh_label:setString(tostring(fresh_cost) ..string_helper.game_dart_shop.side)
    end
    self:refreshGood();
end
--[[--
    初始化
]]
function game_dart_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end


return game_dart_shop;
