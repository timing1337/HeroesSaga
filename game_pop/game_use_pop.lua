--- 商店弹板

local game_use_pop = {
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
function game_use_pop.destroy(self)
    -- body
    cclog("-----------------game_use_pop destroy-----------------");
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
function game_use_pop.back(self,type)
    game_scene:removePopByName("game_use_pop");
end
--[[
    修改个数和钻石    从竞技场进来，使用的是竞技点
]]--
function game_use_pop.setCountAndMoney(self,addCount)
    if self.m_count_value + addCount <= self.m_max_count and self.m_count_value + addCount > 0 then
        self.m_count_value = self.m_count_value + addCount;
    elseif self.m_count_value + addCount > self.m_max_count then
        self.m_count_value = self.m_max_count;
    elseif self.m_count_value + addCount < 1 then
        self.m_count_value = 1;
    end
    self.m_number_label:setString(tostring(self.m_count_value));
end
--[[
    从竞技场进来，使用的是竞技点
]]--
function game_use_pop.setCountAndArenaCount(self,addCount)
    -- body
end
--[[--
    读取ccbi创建ui
]]
function game_use_pop.createUi(self)
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
    ccbNode:openCCBFile("ccb/ui_use_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("icon_node");
    self.m_goods_sprite = ccbNode:spriteForName("goods_sprite");
    self.m_goods_info_label = ccbNode:labelTTFForName("goods_info_label");
    self.m_goods_alpha_back = ccbNode:spriteForName("goods_alpha_back");
    -- self.m_price_label = ccbNode:labelBMFontForName("price_label");
    self.m_price_alpha_back = ccbNode:spriteForName("price_alpha_back");
    self.m_number_label = ccbNode:labelBMFontForName("number_label");

    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_btn_add = ccbNode:controlButtonForName("btn_add");
    self.m_btn_minute = ccbNode:controlButtonForName("btn_minute");
    self.m_btn_min10 = ccbNode:controlButtonForName("btn_min10");
    self.m_btn_add10 = ccbNode:controlButtonForName("btn_add10");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.title46)
    -- self.m_money_sprite = ccbNode:spriteForName("money_sprite");
    self.m_title_spr = ccbNode:spriteForName("m_title_spr");

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
    game_util:setControlButtonTitleBMFont(self.m_btn_use);

    self:setCountAndMoney(0);

    local icon,name,count = game_util:getItemRewardId(self.m_tParams.shopItemId,1)
    if icon then
        icon:setAnchorPoint(ccp(0.5,0.5));
        local iconSize = self.m_goods_sprite:getContentSize();
        icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
        self.m_goods_sprite:addChild(icon,10);
    end
    if name then
        self.m_goods_info_label:setString(name)
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
function game_use_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_use_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
end
--[[--
    创建ui入口并初始化数据
]]
function game_use_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_count_value = 1;
    if self.m_tParams.maxCount <= 0 then -- 不限次数  设置默认最大值 9999
        self.m_tParams.maxCount = 99;
        self.m_tParams.alreadyCount = 0;
    end
    self.m_max_count = self.m_tParams.maxCount;
    cclog("shopItemId == "..self.m_tParams.shopItemId);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_use_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_use_pop;