--- 火焰杯 获得大奖提示

local ui_firecup_getdiamond_pop = {
    m_rewardInfo = nil,
};
--[[--
    销毁
]]
function ui_firecup_getdiamond_pop.destroy(self)
    -- body
    cclog("-----------------ui_firecup_getdiamond_pop destroy-----------------");
    self.m_rewardInfo = nil;
end
--[[--
    返回
]]
function ui_firecup_getdiamond_pop.back(self,type)
    game_scene:removePopByName("ui_firecup_getdiamond_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_firecup_getdiamond_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "ui_firecup_getdiamond_pop   btnTag   =====   ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 301 then
            rewards = self.m_rewardInfo.reward
            game_util:rewardTipsByDataTable(rewards or {})
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_firecup_getdiamond_pop.ccbi");

    local m_label_diamondnum = ccbNode:labelTTFForName("m_label_diamondnum")

    local rewards = self.m_rewardInfo["cost_big_reward"] or {}
    local oneReward = rewards[1] or {}
    if oneReward[3] then
        local diamondNum = oneReward[3]
        m_label_diamondnum:setString("x" .. tostring(diamondNum))
    else
        m_label_diamondnum:setString("")
    end

    -- 139,181,66
    --  防透点
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    m_root_layer:setTouchEnabled(true);

    local m_btn_getreward = ccbNode:controlButtonForName("m_btn_getreward")
    if m_btn_getreward then m_btn_getreward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5) end
    if m_btn_getreward then 
        game_util:setControlButtonTitleBMFont( m_btn_getreward ) 
        game_util:setCCControlButtonTitle(m_btn_getreward,string_helper.ccb.text166)
    end

    return ccbNode;
end


--[[--
    刷新ui
]]
function ui_firecup_getdiamond_pop.refreshUi(self)
end

--[[--
    初始化
]]
function ui_firecup_getdiamond_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_rewardInfo = t_params.rewardInfo or {};
end

--[[--
    创建ui入口并初始化数据
]]
function ui_firecup_getdiamond_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_firecup_getdiamond_pop;