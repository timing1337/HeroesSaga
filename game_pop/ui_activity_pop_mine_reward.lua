--- 

local ui_activity_pop_mine_reward = {
    m_root_layer = nil,
    m_btn_close = nil,
    m_node_rewardList = nil,
    m_label_downTime = nil,

};
--[[--
    销毁
]]
function ui_activity_pop_mine_reward.destroy(self)
    -- body
    cclog("-----------------ui_activity_pop_mine_reward destroy-----------------");
    self.m_root_layer = nil
    self.m_btn_close = nil
    self.m_node_rewardList = nil
    self.m_label_downTime = nil
end
--[[--
    返回
]]
function ui_activity_pop_mine_reward.back(self,type)
    game_scene:removePopByName("ui_activity_pop_mine_reward")
end
--[[--
    读取ccbi创建ui
]]
function ui_activity_pop_mine_reward.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        if btnTag == 100 then   --关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_activity_pop_mine_reward.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node_rewardList = ccbNode:nodeForName("m_node_rewardList")
    self.m_label_downTime = ccbNode:labelTTFForName("m_label_downTime")
    self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    
    return ccbNode;
end



--[[--
    刷新ui
]]
function ui_activity_pop_mine_reward.refreshUi(self)
    
end

--[[--
    初始化
]]
function ui_activity_pop_mine_reward.init(self,t_params)
    t_params = t_params or {};
    -- body

end

--[[--
    创建ui入口并初始化数据
]]
function ui_activity_pop_mine_reward.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_activity_pop_mine_reward;