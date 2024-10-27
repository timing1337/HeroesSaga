---  ui模版

local M = {

};
--[[--
    销毁ui
]]
function M.destroy(self)
    -- body
    cclog("-----------------M destroy-----------------");
end
--[[--
    返回
]]
function M.back(self,backType)
	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function M.createUi(self)
    local ccbNode = luaCCBNode:create();
    -- local function onMainBtnClick( target,event )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    -- end
    -- ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_main.ccbi");
    -- local m_gem_label = tolua.cast(ccbNode:objectForName("m_gem_label"), "CCLabelTTF");--
    return ccbNode;
end
--[[--
    刷新ui
]]
function M.refreshUi(self)
    
end
--[[--
    初始化
]]
function M.init(self,t_params)
    t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function M.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return M;