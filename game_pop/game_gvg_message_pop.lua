--- 公会消息详细

local game_gvg_message_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    title_label = nil,
    content_label = nil,
    award_node = nil,
    m_reward_btn = nil, 
    fuken_node = nil,
    content_node = nil,
    show_node = nil,
};
--[[--
    销毁
]]
function game_gvg_message_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_message_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.title_label = nil;
    self.content_label = nil;
    self.award_node = nil;
    self.m_reward_btn = nil;
    self.fuken_node = nil;
    self.content_node = nil;
    self.show_node = nil;
end
--[[--
    返回
]]
function game_gvg_message_pop.back(self,type)
    game_scene:removePopByName("game_gvg_message_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_message_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        if btnTag == 100 then
            -- self:receiveAwards(btnTag);
            -- self.m_tParams.okBtnCallBack()
            self:back()
        elseif btnTag == 101 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_message_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    self.title_label = ccbNode:labelTTFForName("title_label")
    self.content_label = ccbNode:labelTTFForName("content_label")
    self.content_node = ccbNode:nodeForName("content_node")
    self.show_node = ccbNode:nodeForName("show_node")
    
    self.m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")

    game_util:setCCControlButtonTitle(self.m_reward_btn,string_helper.ccb.text217)

    game_util:setControlButtonTitleBMFont(self.m_reward_btn)
    self.m_reward_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local back_btn = ccbNode:controlButtonForName("back_btn")
    back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

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
--[[
    内容列表
]]
function game_gvg_message_pop.createContentTable(self,viewSize)
    local contentText = self.messages
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(200,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(102,67,35),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(200,tempSize.height))
    if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    end
    self.text_scroll:addChild(tempLabel)
end

--[[--
    刷新ui
]]
function game_gvg_message_pop.refreshUi(self)
    self:createContentTable(self.content_node:getContentSize())
end
--[[--
    初始化
]]
function game_gvg_message_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    -- cclog("self.m_tParams == " .. json.encode(self.m_tParams))
    self.messages = t_params.messages
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_message_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_gvg_message_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_message_pop;