--- 世界boss结算弹出板

local game_neutral_result_pop = {
    m_popUi = nil,
    m_root_layer = nil, 
    m_tParams = nil,

    m_close_btn = nil,
    m_close_btn = nil,
    btn_revenge = nil,
    title_label = nil,
    detail_label = nil,

    building = nil,
    city = nil,
    name = nil,
    content =  nil,
    callFunc = nil,
};
--[[--
    销毁
]]
function game_neutral_result_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_result_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_tParams = nil;

    self.m_close_btn = nil;
    self.m_close_btn = nil;
    self.btn_revenge = nil;
    self.title_label = nil;
    self.detail_label = nil;

    self.building = nil;
    self.city = nil;
    self.name = nil;
    self.content =  nil;
    self.callFunc = nil;
end
--[[--
    返回
]]
function game_neutral_result_pop.back(self,type)    
    game_scene:removePopByName("game_neutral_result_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 101 then--夺取原来的地块
            self.callFunc()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_neutal_result_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local title147 = ccbNode:labelTTFForName("title147")
    title147:setString(string_helper.ccb.title147);
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.btn_revenge = ccbNode:controlButtonForName("btn_revenge");
    game_util:setCCControlButtonTitle(string_helper.ccb.title148);
    self.title_label = ccbNode:labelTTFForName("title_label");
    self.detail_label = ccbNode:labelTTFForName("detail_label");

    self.detail_label:setString(self.content)

    game_util:setControlButtonTitleBMFont(self.btn_revenge)
    self.btn_revenge:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_neutral_result_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_neutral_result_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    -- self.m_tParams.m_showType = t_params.showType or 1;
    self.building = t_params.building or 0
    self.city = t_params.city or 0
    self.name = t_params.name or ""
    self.content = t_params.content or ""
    self.callFunc = t_params.callFunc
end
--[[--
    创建ui入口并初始化数据
]]
function game_neutral_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end
--[[--
    回调方法
]]
function game_neutral_result_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end
return game_neutral_result_pop;