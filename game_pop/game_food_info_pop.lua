--- game_food_info_pop信息

local game_food_info_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,

    itemData = nil,

    maxCount = nil,
    alreadyCount = nil,
    tempId = nil,
    buy_call_back = nil,
};

--[[--
    销毁
]]
function game_food_info_pop.destroy(self)
    -- body
    cclog("-----------------game_food_info_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.itemData = nil;

    self.maxCount = nil;
    self.alreadyCount = nil;
    self.tempId = nil;
    self.buy_call_back = nil;
end
--[[--
    返回
]]
function game_food_info_pop.back(self,type)
    game_scene:removePopByName("game_food_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_food_info_pop.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 5 then
            self:addBuyPop(self.tempId)
        elseif btnTag == 3 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_items_dialog.ccbi");
    local m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_icon_spr = ccbNode:spriteForName("m_icon_spr")

    local icon,name,count = game_util:getRewardByItemTable(self.itemData)
    if icon then
        m_icon_spr:removeAllChildrenWithCleanup(true)
        icon:setAnchorPoint(ccp(0.5,0.5))
        local size = m_icon_spr:getContentSize();
        icon:setPosition(ccp(size.width*0.5,size.height*0.5));
        m_icon_spr:addChild(icon,10)
        m_title_label:setString(name);
        m_story_label:setString(string_helper.game_food_info_pop.get .. name .. " ×" .. count)
    end

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");
    local m_batch_btn = ccbNode:controlButtonForName("m_batch_btn");
    local m_info_btn = ccbNode:controlButtonForName("m_info_btn")
    game_util:setCCControlButtonTitle(m_batch_btn,string_helper.ccb.title194);
    game_util:setCCControlButtonTitle(m_left_btn,string_helper.ccb.title193);
    game_util:setCCControlButtonTitle(m_right_btn,string_helper.ccb.title195);
    m_info_btn:setVisible(false)

    m_left_btn:setVisible(false)
    m_right_btn:setVisible(false)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 25);
    m_batch_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-25);
    m_batch_btn:setVisible(false)
    if self.openType == 2 then
        m_batch_btn:setVisible(true)
        game_util:setCCControlButtonTitle(m_batch_btn,string_helper.game_food_info_pop.buyMuch);
    end
    -- m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    -- m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[
    批量使用
]]
function game_food_info_pop.addUsePop(self,shopId)
    local itemCount = game_data:getItemCountByCid(tostring(self.m_itemId))
    local t_params = 
    {
        okBtnCallBack = function(count)
            local use_flag = true--为true可以继续调用use接口
            local function responseMethod(tag,gameData)
                game_data_statistics:useItem({itemId = self.m_itemId,count = count})
                if self.m_callBackFunc then
                    self.m_callBackFunc();
                end
                local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
                local itemName = config_date:getNodeWithKey("name"):toStr();
                local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
                if rewardCount and rewardCount == 0 then
                    game_util:addMoveTips({text = tostring(itemName) .. string_helper.game_food_info_pop.use});
                end
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = self.m_itemId,num = count},"item_use")
        end,
        shopItemId = self.m_itemId,
        maxCount = itemCount,
        alreadyCount = 1,
        times_limit = 1,
        touchPriority = GLOBAL_TOUCH_PRIORITY - 25,
        enterType = "game_buy_item_scene",
    }
    game_scene:addPop("game_use_pop",t_params)
end
--[[--
    批量购买函数
]]
function game_food_info_pop.addBuyPop(self,shopId)
    -- local shopCfg = getConfig(game_config_field.shop);
    -- local itemCfg = shopCfg:getNodeWithKey(shopId)
    local shopItemId = tostring(shopId)
    print( "t_params.isShowMoneyIcon == ", self.m_isShowMoneyIcon)
    local t_params = 
    {
        okBtnCallBack = function(count)
            -- self:removePop();
            cclog("createPropsTableView item click = " .. shopItemId);
            local function responseMethod(tag,gameData)
                game_data_statistics:buyItem({shopId = shopItemId,count = count})
                local data = gameData:getNodeWithKey("data");
                -- cclog("data == " .. data:getFormatBuffer())
                game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
                -- self.m_tGameData[shopId].bought = data:getNodeWithKey("bought"):toInt();
                self.buy_call_back(data:getNodeWithKey("bought"):toInt(),shopId)
            end
            local params = {};
            params.shop_id = shopItemId;
            params.count = count;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey(self.m_buyUrl or "shop_buy"), http_request_method.GET, params,self.m_buyUrl or "shop_buy")
        end,
        shopItemId = shopItemId,
        maxCount = self.maxCount,
        alreadyCount = self.alreadyCount,
        times_limit = 1,
        touchPriority = GLOBAL_TOUCH_PRIORITY - 24,
        isShowMoneyIcon = self.m_isShowMoneyIcon or "asdfasdfas",
        enterType = self.m_enterType or "game_buy_item_scene",
    }
    game_scene:addPop("game_shop_pop",t_params)
end
--[[--
    刷新ui
]]
function game_food_info_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_food_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.itemData = t_params.itemData
    self.openType = t_params.openType or 1
    self.maxCount = t_params.maxCount or 1;
    self.alreadyCount = t_params.alreadyCount or 1;
    self.tempId = t_params.tempId or 1;
    self.buy_call_back = t_params.buy_call_back or nil;
    self.m_itemId = t_params.itemId;

    self.m_buyUrl = t_params.buyUrl or "shop_buy"
    self.m_isShowMoneyIcon = t_params.isShowMoneyIcon or "yes"
    self.m_enterType = t_params.enterType
    print( "t_params.isShowMoneyIcon == ", t_params.isShowMoneyIcon)

end

--[[--
    创建ui入口并初始化数据
]]
function game_food_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_food_info_pop;