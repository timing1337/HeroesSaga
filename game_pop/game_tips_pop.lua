--- 提示弹出框

local game_tips_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_title_label = nil,
    m_text_label = nil,
    m_close_btn = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_btn_3 = nil,
    m_callBackFunc = nil,
};
--[[--
    销毁
]]
function game_tips_pop.destroy(self)
    -- body
    cclog("-----------------game_tips_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_title_label = nil;
    self.m_text_label = nil;
    self.m_close_btn = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_btn_3 = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function game_tips_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_tips_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_tips_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then
            game_scene:enterGameUi("game_hero_list",{openType = "game_small_map_scene"});
            self:destroy();
        elseif btnTag == 12 then--
            game_scene:enterGameUi("skills_strengthen_scene",{openType = "game_small_map_scene"});
            self:destroy();
        elseif btnTag == 13 then--
            if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
                self.m_callBackFunc();
            end
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_tips_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");

    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_text_label = ccbNode:labelTTFForName("m_text_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_btn_3 = ccbNode:controlButtonForName("m_btn_3")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_tips_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_tips_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_callBackFunc = t_params.callBackFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function game_tips_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_tips_pop;