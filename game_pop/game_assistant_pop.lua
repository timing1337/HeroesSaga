--- 显示下奖励
local game_assistant_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_btn_use = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    openType = nil,
    tips_label_1 = nil,
    cost_label = nil,
    have_label = nil,
    unit_sprite = nil,
    unit_sprite2 = nil,
};
--[[--
    销毁
]]
function game_assistant_pop.destroy(self)
    -- body
    cclog("-----------------game_assistant_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_btn_use = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.openType = nil;
    self.tips_label_1 = nil;
    self.cost_label = nil;
    self.have_label = nil;
    self.unit_sprite = nil;
    self.unit_sprite2 = nil;
end
--[[--
    返回
]]
function game_assistant_pop.back(self,type)
    game_scene:removePopByName("game_assistant_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_assistant_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 105 then--  购买
            -- self:back()
            -- if self.m_tParams.enter_type == 1 then
                self.m_tParams.okBtnCallBack()
            -- else 
                -- self:back()
            -- end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_assistant_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.tips_label_1 = ccbNode:labelTTFForName("tips_label_1")
    self.cost_label = ccbNode:labelBMFontForName("cost_label")
    self.have_label = ccbNode:labelBMFontForName("have_label")
    self.unit_sprite = ccbNode:spriteForName("unit_sprite")
    self.unit_sprite2 = ccbNode:spriteForName("unit_sprite2")
    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    
    game_util:setControlButtonTitleBMFont(self.m_btn_use);
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.text60)

    local assCfg = nil;
    if self.openType == 1 then
        assCfg = getConfig(game_config_field.assistant)
    else
        assCfg = getConfig(game_config_field.destiny)
    end
    local itemCfg = assCfg:getNodeWithKey(tostring(self.m_tParams.index))
    local sort = itemCfg:getNodeWithKey("sort"):toInt()
    local price = itemCfg:getNodeWithKey("price"):toInt()

    local myDirCount = 0
    local dirName = ""
    if sort == 1 then
        self.unit_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_2.png"));
        self.unit_sprite2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_2.png"));
        myDirCount = game_data:getUserStatusDataByKey("dirt_silver")
        dirName = string_helper.game_assistant_pop.sliverDirt
    else
        self.unit_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_1.png"));
        self.unit_sprite2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_1.png"));
        myDirCount = game_data:getUserStatusDataByKey("dirt_gold")
        dirName = string_helper.game_assistant_pop.goldDirt
    end
    
    self.cost_label:setString(tostring(price))
    self.have_label:setString(tostring(myDirCount))
    self.tips_label_1:setString(string_helper.game_assistant_pop.use .. price .. dirName ..string_helper.game_assistant_pop.open)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_assistant_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_assistant_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    -- cclog("self.m_tParams == " .. json.encode(self.m_tParams))
    self.openType = t_params.openType or 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_assistant_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_assistant_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_assistant_pop;