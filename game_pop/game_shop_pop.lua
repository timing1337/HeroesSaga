--- 商店弹板

local game_shop_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_goods_alpha_back = nil,
    m_price_label = nil,
    m_price_alpha_back = nil,
    m_number_label = nil,

    m_count_value = nil,
    m_max_count = nil,

    m_btn_use = nil,
    m_btn_add = nil,
    m_btn_add10 = nil,
    m_btn_minute = nil,
    m_btn_min10 = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    m_money_sprite = nil,
    m_title_spr = nil,
};
--[[--
    销毁
]]
function game_shop_pop.destroy(self)
    -- body
    cclog("-----------------game_shop_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_goods_alpha_back = nil;
    self.m_price_label = nil;
    self.m_price_alpha_back = nil;
    self.m_number_label = nil;
    self.m_count_value = nil;
    self.m_max_count = nil;

    self.m_btn_use = nil;
    self.m_btn_add = nil;
    self.m_btn_add10 = nil;
    self.m_btn_minute = nil;
    self.m_btn_min10 = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.m_money_sprite = nil;
    self.m_title_spr = nil;
end
--[[--
    返回
]]
function game_shop_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
 -- self:destroy();
    game_scene:removePopByName("game_shop_pop");
end
--[[
    修改个数和钻石    从竞技场进来，使用的是竞技点
]]--
function game_shop_pop.setCountAndMoney(self,addCount)
    if self.m_count_value + addCount <= self.m_max_count and self.m_count_value + addCount > 0 then
        self.m_count_value = self.m_count_value + addCount;
    elseif self.m_count_value + addCount > self.m_max_count then
        self.m_count_value = self.m_max_count;
    elseif self.m_count_value + addCount < 1 then
        if self.m_count_value ~= 0 then
            self.m_count_value = 1;
        end
    end
    self.m_number_label:setString(tostring(self.m_count_value));

    if self.m_tParams.enterType == "game_buy_item_scene" then
        --算钻石
        local shopCfg = getConfig(game_config_field.shop);
        local itemCfg = shopCfg:getNodeWithKey(tostring(self.m_tParams.shopItemId));
        local need_value = itemCfg:getNodeWithKey("need_value");

        local need_max_count = need_value:getNodeCount();
        local needMoney = 0;
        local buy_index = self.m_count_value + self.m_tParams.alreadyCount;--买的第几个是已经买过了的，加上又选的个数
        for i=self.m_tParams.alreadyCount+1,buy_index do--已经买过了的，当然不能算进来
            local money = 0;--第i次买的价格
            if i <= need_max_count then
                money = need_value:getNodeAt(i-1):toInt();
            else
                money = need_value:getNodeAt(need_max_count-1):toInt();
            end
            needMoney = needMoney + money;
        end
        self.m_price_label:setString(tostring(needMoney));
    elseif self.m_tParams.enterType == "game_metal_shop_scene" then
        --算钻石
        local shopCfg = getConfig(game_config_field.metal_core_shop);
        local itemCfg = shopCfg:getNodeWithKey(tostring(self.m_tParams.shopItemId));
        local need_value = itemCfg:getNodeWithKey("need_value");

        local need_max_count = need_value:getNodeCount();
        local needMoney = 0;
        local buy_index = self.m_count_value + self.m_tParams.alreadyCount;--买的第几个是已经买过了的，加上又选的个数
        for i=self.m_tParams.alreadyCount+1,buy_index do--已经买过了的，当然不能算进来
            local money = 0;--第i次买的价格
            if i <= need_max_count then
                money = need_value:getNodeAt(i-1):toInt();
            else
                money = need_value:getNodeAt(need_max_count-1):toInt();
            end
            needMoney = needMoney + money;
        end
        self.m_price_label:setString(tostring(needMoney));
    elseif self.m_tParams.enterType ==  "Integration_shop" then
        --算钻石
        local shopCfg = getConfig(game_config_field.Integration_shop);
        local itemCfg = shopCfg:getNodeWithKey(tostring(self.m_tParams.shopItemId));
        local need_value = itemCfg:getNodeWithKey("need_value");

        local need_max_count = need_value:getNodeCount();
        local needMoney = 0;
        local buy_index = self.m_count_value + self.m_tParams.alreadyCount;--买的第几个是已经买过了的，加上又选的个数
        for i=self.m_tParams.alreadyCount+1,buy_index do--已经买过了的，当然不能算进来
            local money = 0;--第i次买的价格
            if i <= need_max_count then
                money = need_value:getNodeAt(i-1):toInt();
            else
                money = need_value:getNodeAt(need_max_count-1):toInt();
            end
            needMoney = needMoney + money;
        end
        self.m_price_label:setString(tostring(needMoney));

        
    elseif self.m_tParams.enterType == "game_pk" then
        --算竞技场点数
        local shopCfg = getConfig(game_config_field.arena_shop);
        local itemCfg = shopCfg:getNodeWithKey(tostring(self.m_tParams.shopItemId));
        local needPoint = itemCfg:getNodeWithKey("need_point"):toInt();
        local totalPoint = needPoint * self.m_count_value;
        self.m_price_label:setString(tostring(totalPoint));
    elseif self.m_tParams.enterType == "mid_autumn_group_buy_scene" then
        local group_shop_cfg = getConfig(game_config_field.group_shop)
        local itemCfg = group_shop_cfg:getNodeWithKey(self.m_tParams.shopItemId);
        local coin = itemCfg:getNodeWithKey("coin"):toInt();
        local selloff = itemCfg:getNodeWithKey("selloff"):toInt();
        local totalPoint = math.ceil(coin*selloff/100) * self.m_count_value;
        self.m_price_label:setString(tostring(totalPoint));
    elseif self.m_tParams.enterType == "game_offering_sacrifices_shop" then--神恩商城
        local tree_shop_cfg = getConfig(game_config_field.tree_shop);
        local itemCfg = tree_shop_cfg:getNodeWithKey(self.m_tParams.shopItemId)
        local need_value = itemCfg:getNodeWithKey("need_value");
        local need_max_count = need_value:getNodeCount();
        local needMoney = 0;
        local buy_index = self.m_count_value + self.m_tParams.alreadyCount;--买的第几个是已经买过了的，加上又选的个数
        for i=self.m_tParams.alreadyCount+1,buy_index do--已经买过了的，当然不能算进来
            local money = 0;--第i次买的价格
            if i <= need_max_count then
                money = need_value:getNodeAt(i-1):toInt();
            else
                money = need_value:getNodeAt(need_max_count-1):toInt();
            end
            needMoney = needMoney + money;
        end
        self.m_price_label:setString(tostring(needMoney));
    end
end
--[[
    从竞技场进来，使用的是竞技点
]]--
function game_shop_pop.setCountAndArenaCount(self,addCount)
    -- body
end
--[[--
    读取ccbi创建ui
]]
function game_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 101 then--  +
            self:setCountAndMoney(1)
        elseif btnTag == 102 then--  -
            self:setCountAndMoney(-1)
        elseif btnTag == 103 then--  +10
            self:setCountAndMoney(10)
        elseif btnTag == 104 then--  -10
            self:setCountAndMoney(-10)
        elseif btnTag == 105 then--  购买
            self.m_tParams.okBtnCallBack(self.m_count_value)
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_shop_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("icon_node");
    self.m_goods_sprite = ccbNode:spriteForName("goods_sprite");
    self.m_goods_info_label = ccbNode:labelTTFForName("goods_info_label");
    self.m_goods_alpha_back = ccbNode:spriteForName("goods_alpha_back");
    self.m_price_label = ccbNode:labelBMFontForName("price_label");
    self.m_price_alpha_back = ccbNode:spriteForName("price_alpha_back");
    self.m_number_label = ccbNode:labelBMFontForName("number_label");

    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_btn_add = ccbNode:controlButtonForName("btn_add");
    self.m_btn_minute = ccbNode:controlButtonForName("btn_minute");
    self.m_btn_min10 = ccbNode:controlButtonForName("btn_min10");
    self.m_btn_add10 = ccbNode:controlButtonForName("btn_add10");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_money_sprite = ccbNode:spriteForName("money_sprite");
    self.m_title_spr = ccbNode:spriteForName("m_title_spr");

    local zongjia = ccbNode:labelBMFontForName("zongjia")
    zongjia:setString(string_helper.ccb.file82)

    if self.m_isShowMoneyIcon == "yes" then 
        self.m_money_sprite:setVisible(true)
    else
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_jifen2.png")
        if tempSpriteFrame then 
            self.m_money_sprite:setDisplayFrame(tempSpriteFrame) 
        else
            self.m_money_sprite:setVisible(false)
        end
    end
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.title71)
    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_minute:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_min10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_add10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    
    game_util:setControlButtonTitleBMFont(self.m_btn_add10);
    game_util:setControlButtonTitleBMFont(self.m_btn_min10);
    game_util:setControlButtonTitleBMFont(self.m_btn_add);
    game_util:setControlButtonTitleBMFont(self.m_btn_minute);
    -- game_util:setControlButtonTitleBMFont(self.m_btn_use);

    self:setCountAndMoney(0);
    
    if self.m_tParams.enterType == "game_buy_item_scene" then
        local shopCfg = getConfig(game_config_field.shop);
        local itemCfg = shopCfg:getNodeWithKey(self.m_tParams.shopItemId);
        local shop_reward = itemCfg:getNodeWithKey("shop_reward");
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);

        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end
    elseif self.m_tParams.enterType == "game_metal_shop_scene" then
        local shopCfg = getConfig(game_config_field.metal_core_shop);
        local itemCfg = shopCfg:getNodeWithKey(self.m_tParams.shopItemId);
        local shop_reward = itemCfg:getNodeWithKey("shop_reward");
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);

        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xilian.png")
        if tempSpriteFrame then
            self.m_money_sprite:setDisplayFrame(tempSpriteFrame);
        end
    elseif self.m_tParams.enterType ==  "Integration_shop" then
        local shopCfg = getConfig(game_config_field.Integration_shop);
        local itemCfg = shopCfg:getNodeWithKey(self.m_tParams.shopItemId);
        local shop_reward = itemCfg:getNodeWithKey("shop_reward");
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);

        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end

    elseif self.m_tParams.enterType == "game_pk" then
        self.m_money_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_medal.png"));
        local shopCfg = getConfig(game_config_field.arena_shop);
        local itemCfg = shopCfg:getNodeWithKey(self.m_tParams.shopItemId);
        local shop_reward = itemCfg:getNodeWithKey("shop_reward");
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);

        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end
    elseif self.m_tParams.enterType == "mid_autumn_group_buy_scene" then
        local group_shop_cfg = getConfig(game_config_field.group_shop)
        local itemCfg = group_shop_cfg:getNodeWithKey(self.m_tParams.shopItemId);
        local shop_reward = itemCfg:getNodeWithKey("reward")
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);

        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end
    elseif self.m_tParams.enterType == "game_offering_sacrifices_shop" then--神恩商城
        local tree_shop_cfg = getConfig(game_config_field.tree_shop);
        local itemCfg = tree_shop_cfg:getNodeWithKey(self.m_tParams.shopItemId)
        local shop_reward = itemCfg:getNodeWithKey("shop_reward")
        local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0),false);
        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5));
            local iconSize = self.m_goods_sprite:getContentSize();
            icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
            self.m_goods_sprite:addChild(icon,10);
        end
        if name then
            self.m_goods_info_label:setString(name)
        end
        local need_sort = itemCfg:getNodeWithKey("need_sort"):toInt();
        local tempSpriteFrame = nil;
        if need_sort == 5 then
            tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_shenen_d.png")
        elseif need_sort == 6 then
            tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_shenen_g.png")
        end
        if tempSpriteFrame then
            self.m_money_sprite:setDisplayFrame(tempSpriteFrame);
        end
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 30,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_shop_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_shop_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    print("  t_params  === 3", t_params.isShowMoneyIcon)
    self.m_tParams.m_showType = t_params.showType or 1;
    self.m_isShowMoneyIcon = t_params.isShowMoneyIcon or "yes"
end
--[[--
    创建ui入口并初始化数据
]]
function game_shop_pop.create(self,t_params)
    print("  t_params  === 1", t_params.enterType)
    print("  t_params  === 2", t_params.isShowMoneyIcon)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_count_value = 1;
    cclog2(self.m_tParams.maxCount,"self.m_tParams.maxCount")
    if self.m_tParams.maxCount <= 0 then -- 不限次数  设置默认最大值 9999
        self.m_tParams.maxCount = 99;
        self.m_tParams.alreadyCount = 0;
    end
    self.m_max_count = self.m_tParams.maxCount - self.m_tParams.alreadyCount;

    cclog("maxCount == "..self.m_tParams.maxCount);
    cclog("alreadyCount == "..self.m_tParams.alreadyCount);
    cclog("shopItemId == "..self.m_tParams.shopItemId);
    self.m_popUi = self:createUi();
    self:refreshUi();

    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_shop_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_shop_pop;