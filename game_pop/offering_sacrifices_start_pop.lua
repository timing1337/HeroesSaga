--- 开始献祭

local offering_sacrifices_start_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_tParams = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_cost_label = nil,
    m_cost_icon = nil,
    m_scrollView = nil,
};
--[[--
    销毁
]]
function offering_sacrifices_start_pop.destroy(self)
    -- body
    cclog("-----------------offering_sacrifices_start_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_tParams = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_cost_label = nil;
    self.m_cost_icon = nil;
    self.m_scrollView = nil;
end
--[[--
    返回
]]
function offering_sacrifices_start_pop.back(self,type)
    game_scene:removePopByName("offering_sacrifices_start_pop");
end
--[[--
    读取ccbi创建ui
]]
function offering_sacrifices_start_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--开始献祭
            self:callBackFunc("start");
            -- self:back();
        elseif btnTag == 3 then--快速献祭
            game_scene:addPop("offering_sacrifices_fast_pop",{callBackFunc = self.m_tParams.callBackFunc})
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_offering_sacrifices_start_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local  title131 = ccbNode:layerForName("title131");
    title131:setString(string_helper.ccb.title131);
    -- self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    -- self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_cost_label = ccbNode:labelTTFForName("m_cost_label")
    self.m_cost_icon = ccbNode:spriteForName("m_cost_icon")
    self.m_scrollView = ccbNode:scrollViewForName("m_scrollView")
    self.m_scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

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
function offering_sacrifices_start_pop.refreshUi(self)
    self.m_scrollView:getContainer():removeAllChildrenWithCleanup(true);
    local viewSize = self.m_scrollView:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = string_config:getTextByKey("m_open_text"),dimensions = viewSize,textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollView:setContentSize(CCSizeMake(210,tempSize.height))
    self.m_scrollView:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollView:addChild(tempLabel)
end

--[[--
    初始化
]]
function offering_sacrifices_start_pop.init(self,t_params)
    self.m_tParams = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function offering_sacrifices_start_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function offering_sacrifices_start_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return offering_sacrifices_start_pop;