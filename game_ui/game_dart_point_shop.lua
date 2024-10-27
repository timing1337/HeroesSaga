---  押镖积分商店
local game_dart_point_shop = {
    
};
--[[--
    销毁ui
]]
function game_dart_point_shop.destroy(self)
    -- body
    cclog("-----------------game_dart_point_shop destroy-----------------");
    
end
--[[--
    返回
]]
function game_dart_point_shop.back(self,backType)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_dart_main",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_point_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 2 then--刷新
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data");
            --     self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            --     self:refreshUi()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_shop_fresh"), http_request_method.GET, nil,"escort_shop_fresh")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_exchange.ccbi");
    
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")
    self.m_free_refresh_label = ccbNode:labelTTFForName("m_free_refresh_label")
    local m_free_refresh_btn = ccbNode:controlButtonForName("m_free_refresh_btn")
    m_free_refresh_btn:setVisible(false)

    local money_icon = ccbNode:spriteForName("money_icon")
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_score.png")
    if tempSpriteFrame then
        money_icon:setDisplayFrame(tempSpriteFrame);
    end
    return ccbNode;
end

--[[--
    创建道具列表
]]
function game_dart_point_shop.createTableView(self,viewSize)
    local showDataTable = self.m_tGameData.configs
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local index = btnTag - 100

        local function responseMethod(tag,gameData)
            -- cclog2(gameData:getNodeWithKey("data"))
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
            game_util:rewardTipsByJsonData(reward)
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_point_buy"), http_request_method.GET, {goods_id = index},"escort_point_buy")
    end
    local itemsCount = game_util:getTableLen(showDataTable)
    -- local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
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

            local itemData = showDataTable[tostring(index+1)]
            local cost = itemData.cost
            local limits = itemData.limits
            local nameExtra = ""
            if limits >= 0 then
                nameExtra = "(" .. limits .. ")"
            else
                nameExtra = string_helper.game_dart_point_shop.no_limit
            end
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_time_label = ccbNode:labelTTFForName("m_time_label")
            m_time_label:setVisible(false)
            local m_icon = ccbNode:nodeForName("m_icon")
            local m_count = ccbNode:labelBMFontForName("m_count")
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            local black_bg = ccbNode:layerColorForName("black_bg")
            local money_icon = ccbNode:spriteForName("money_icon")
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_score.png")
            if tempSpriteFrame then
                money_icon:setDisplayFrame(tempSpriteFrame);    
            end
            m_buy_btn:setTag(101 + index)

            m_icon:removeAllChildrenWithCleanup(true)
            m_count:setString(tostring(cost))
            local reward = itemData.reward[1]
            local icon,name,count = game_util:getRewardByItemTable(reward)
            if icon then
                icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
                m_icon:addChild(icon,10)
                if count then
                    local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                    countLabel:setPosition(ccp(40,10))
                    m_icon:addChild(countLabel,10)
                end
            end
            if name then
                m_name_label:setString(name .. nameExtra)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local itemData = showDataTable[tostring(index+1)]
            game_util:lookItemDetal(itemData.reward[1])
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    刷新ui
]]
function game_dart_point_shop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTable = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTable);

    local total_coin = self.m_tGameData.point
    self.m_num_label:setString(tostring(total_coin))
    self.m_free_refresh_label:setString("")
end
--[[--
    初始化
]]
function game_dart_point_shop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_point_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_dart_point_shop;
