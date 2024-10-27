--- 一键合成

local gem_system_synthesis_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_info_label = nil,
    m_alpha_back_1 = nil,
    m_cost_coin_label = nil,
    m_alpha_back_2 = nil,
    m_number_label = nil,

    m_count_value = nil,
    m_max_count = nil,

    m_ok_btn = nil,
    m_btn_add = nil,
    m_btn_add10 = nil,
    m_btn_minute = nil,
    m_btn_min10 = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    m_title_spr = nil,
    m_cost_metal_label = nil,
    m_basic_coin = nil,
    m_basic_metal = nil,
};
--[[--
    销毁
]]
function gem_system_synthesis_pop.destroy(self)
    -- body
    cclog("-----------------gem_system_synthesis_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_info_label = nil;
    self.m_alpha_back_1 = nil;
    self.m_cost_coin_label = nil;
    self.m_alpha_back_2 = nil;
    self.m_number_label = nil;
    self.m_count_value = nil;
    self.m_max_count = nil;

    self.m_ok_btn = nil;
    self.m_btn_add = nil;
    self.m_btn_add10 = nil;
    self.m_btn_minute = nil;
    self.m_btn_min10 = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.m_title_spr = nil;
    self.m_cost_metal_label = nil;
    self.m_basic_coin = nil;
    self.m_basic_metal = nil;
end
--[[--
    返回
]]
function gem_system_synthesis_pop.back(self,type)
    game_scene:removePopByName("gem_system_synthesis_pop");
end
--[[
]]--
function gem_system_synthesis_pop.setCountAndMoney(self,addCount)
    if self.m_count_value + addCount <= self.m_max_count and self.m_count_value + addCount > 0 then
        self.m_count_value = self.m_count_value + addCount;
    elseif self.m_count_value + addCount > self.m_max_count then
        self.m_count_value = self.m_max_count;
    elseif self.m_count_value + addCount < 0 then
        if self.m_count_value ~= 0 then
            self.m_count_value = 0;
        end
    end
    self.m_number_label:setString(tostring(self.m_count_value));
    if self.m_tParams.enterType == "gem_system_synthesis" then
        local totalCoin = self.m_basic_coin * self.m_count_value;
        local totalMetal = self.m_basic_metal * self.m_count_value;
        self.m_cost_coin_label:setString(tostring(totalCoin));
        self.m_cost_metal_label:setString(tostring(totalMetal));
    end
end

--[[--
    读取ccbi创建ui
]]
function gem_system_synthesis_pop.createUi(self)
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
        elseif btnTag == 103 then--  max
            self:setCountAndMoney(self.m_tParams.maxCount)
        elseif btnTag == 104 then--  -10
            self:setCountAndMoney(-10)
        elseif btnTag == 105 then--  合成
            self.m_tParams.okBtnCallBack(self.m_count_value)
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gem_system_synthesis_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("m_icon_node");
    self.m_info_label = ccbNode:labelTTFForName("m_info_label");
    self.m_alpha_back_1 = ccbNode:spriteForName("m_alpha_back_1");
    self.m_cost_coin_label = ccbNode:labelBMFontForName("m_cost_coin_label");
    self.m_alpha_back_2 = ccbNode:spriteForName("m_alpha_back_2");
    self.m_number_label = ccbNode:labelBMFontForName("m_number_label");
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label");

    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_btn_add = ccbNode:controlButtonForName("m_btn_add");
    self.m_btn_minute = ccbNode:controlButtonForName("m_btn_minute");
    self.m_btn_min10 = ccbNode:controlButtonForName("m_btn_min10");
    self.m_btn_add10 = ccbNode:controlButtonForName("m_btn_add10");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_title_spr = ccbNode:spriteForName("m_title_spr");
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text205)
    self.m_btn_add:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_minute:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_min10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_btn_add10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 31);
    
    game_util:setControlButtonTitleBMFont(self.m_btn_add10);
    game_util:setControlButtonTitleBMFont(self.m_btn_min10);
    game_util:setControlButtonTitleBMFont(self.m_btn_add);
    game_util:setControlButtonTitleBMFont(self.m_btn_minute);
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn);

    self:setCountAndMoney(0);
    self.m_icon_node:removeAllChildrenWithCleanup(true);
    if self.m_tParams.enterType == "gem_system_synthesis" then
        local gem_cfg = getConfig(game_config_field.gem);
        local itemCfg = gem_cfg:getNodeWithKey(self.m_tParams.gemItemId);
        if itemCfg then
            local tempIcon = game_util:createGemIconByCfg(itemCfg)
            if tempIcon then
                self.m_icon_node:addChild(tempIcon,10);
            end
            local name = itemCfg:getNodeWithKey("last_name"):toStr()
            local first_name = itemCfg:getNodeWithKey("first_name"):toStr()
            self.m_info_label:setString(name .. first_name);
            self.m_basic_coin = 0;--itemCfg:getNodeWithKey("coin"):toInt();
            self.m_basic_metal = itemCfg:getNodeWithKey("iron"):toInt();
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
function gem_system_synthesis_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function gem_system_synthesis_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    print("  t_params  === 3", t_params.isShowMoneyIcon)
    self.m_tParams.m_showType = t_params.showType or 1;
    self.m_isShowMoneyIcon = t_params.isShowMoneyIcon or "yes"
    self.m_basic_coin = 0;
    self.m_basic_metal = 0;
end
--[[--
    创建ui入口并初始化数据
]]
function gem_system_synthesis_pop.create(self,t_params)
    print("  t_params  === 1", t_params.enterType)
    print("  t_params  === 2", t_params.isShowMoneyIcon)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_count_value = 0;
    cclog2(self.m_tParams.maxCount,"self.m_tParams.maxCount")
    if self.m_tParams.maxCount == nil or self.m_tParams.maxCount < 0 then -- 不限次数  设置默认最大值 9999
        self.m_tParams.maxCount = 99;
        self.m_tParams.alreadyCount = 0;
    end
    self.m_max_count = self.m_tParams.maxCount - self.m_tParams.alreadyCount;

    cclog("maxCount == "..self.m_tParams.maxCount);
    cclog("alreadyCount == "..self.m_tParams.alreadyCount);
    cclog("gemItemId == "..self.m_tParams.gemItemId);
    self.m_popUi = self:createUi();
    self:refreshUi();

    return self.m_popUi;
end

--[[--
    回调方法
]]
function gem_system_synthesis_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return gem_system_synthesis_pop;