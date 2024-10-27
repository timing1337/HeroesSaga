---  回廊  第一次
local open_door_cloister_first_pop = {
    m_root_layer = nil,
};
--[[--
    销毁ui
]]
function open_door_cloister_first_pop.destroy(self)
    -- body
    cclog("-----------------open_door_cloister_first_pop destroy-----------------");

end
--[[--
    返回
]]
function open_door_cloister_first_pop.back(self,backType)
    game_scene:removePopByName("open_door_cloister_first_pop");
end
--[[--
    读取ccbi创建ui
]]
function open_door_cloister_first_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_open_door_cloister_fisrtpop.ccbi");

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
           self:back()
        end
    end

    local animName = "Default Timeline"
    local function animCallFunc(animName)
        
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function open_door_cloister_first_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function open_door_cloister_first_pop.init(self,t_params)
    t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_cloister_first_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return open_door_cloister_first_pop;