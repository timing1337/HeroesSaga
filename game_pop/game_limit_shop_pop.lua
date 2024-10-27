---  限量商城

local game_limit_shop_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_idTab = nil,
};
--[[--
    销毁ui
]]
function game_limit_shop_pop.destroy(self)
    -- body
    cclog("----------------- game_limit_shop_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;
end
--[[--
    返回
]]
function game_limit_shop_pop.back(self,backType)
    game_scene:removePopByName("game_limit_shop_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_limit_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_limit_shop_pop.ccbi");
    -- 光效 显示
    local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    return ccbNode;
end

--[[--
    创建列表
]]
function game_limit_shop_pop.createTableView(self,viewSize)
    local shop = self.m_tGameData.shop or {}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local shopId = self.m_idTab[btnTag + 1];
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            local shop = data:getNodeWithKey("shop");
            if shop then
                self.m_tGameData.shop = json.decode(shop:getFormatBuffer()) or {};
            end
            self:refreshTableView();
            game_util:rewardTipsByJsonData(reward);
        end
        local params = {}
        params.shop_id = shopId
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_outlets_buy"), http_request_method.GET, params,"shop_outlets_buy")
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #self.m_idTab;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_limit_shop_item.ccbi");
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn");
            m_buy_btn:setTag(index);
            local m_title_label = ccbNode:labelBMFontForName("m_title_label")
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local m_buy_flag = ccbNode:labelBMFontForName("m_buy_flag")
            if m_buy_flag then m_buy_flag:setString( string_helper.ccb.file78 ) end
            local m_num_label = ccbNode:labelBMFontForName("m_num_label")
            local m_imgNode = ccbNode:nodeForName("m_imgNode")
            m_imgNode:removeAllChildrenWithCleanup(true);
            local itemData = shop[self.m_idTab[index + 1]]
            if itemData then
                m_title_label:setString(string.format(string_helper.game_limit_shop_pop.stock,itemData.left,itemData.num))
                m_cost_label:setString(tostring(itemData.coin))
                local reward = itemData.reward or {}
                if #reward > 0 then
                    local icon,name,count = game_util:getRewardByItemTable(reward[1])
                    if icon then
                        icon:setScale(0.7)
                        m_imgNode:addChild(icon)
                    end
                    if count then
                        m_num_label:setString("x" .. count)
                    end
                end
                if itemData.bought > 0 then
                    m_buy_flag:setVisible(true)
                else
                    m_buy_flag:setVisible(false)
                end
            else
                m_title_label:setString(string_helper.game_limit_shop_pop.stock0);
                m_cost_label:setString("0");
                m_buy_flag:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = shop[self.m_idTab[index + 1]]
            local reward = itemData.reward or {}
            if #reward > 0 then
                local info = reward[1]
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                 end
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_limit_shop_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function game_limit_shop_pop.refreshUi(self)
    self:refreshTableView();
end
--[[--
    初始化
]]
function game_limit_shop_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_idTab = {};
    local shop = self.m_tGameData.shop or {}
    for k,v in pairs(shop) do
        table.insert(self.m_idTab,k) 
    end
    table.sort(self.m_idTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
end
--[[--
    创建ui入口并初始化数据
]]
function game_limit_shop_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_limit_shop_pop;
