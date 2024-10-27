--- 排序

local game_sort_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_btnTitleTab = nil,
    m_btnCallFunc = nil,
    m_currentSortType = nil,
};
--[[--
    销毁
]]
function game_sort_pop.destroy(self)
    -- body
    cclog("-----------------game_sort_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_btnTitleTab = nil;
    self.m_btnCallFunc = nil;
    self.m_currentSortType = nil;
end
--[[--
    返回
]]
function game_sort_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_sort_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_sort_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        self:back();
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_sort_pop.ccbi");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_btn_node = ccbNode:nodeForName("m_btn_node")
    local sort_label = ccbNode:labelTTFForName("sort_label");
    sort_label:setString(string_helper.ccb.file21);
    local m_btn_node_size = m_btn_node:getContentSize()
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 14);

    local function btnCallFunc(eventName,target)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_btnCallFunc and type(self.m_btnCallFunc) == "function" then
            self.m_btnCallFunc(btnTag);
        end
        self:back();
    end

    for i=1,#self.m_btnTitleTab do
        local params = {}
        params.btnImgName="public_enniu.png";
        params.btnImgNameSel="public_neiniu_1.png";
        params.text=tostring(self.m_btnTitleTab[i].sortName)
        params.callFunc = btnCallFunc;
        params.touchPriority = GLOBAL_TOUCH_PRIORITY-14
        local btnTemp = game_util:createCCControlButtonByTable(params);
        btnTemp:setTag(i);
        btnTemp:setPosition(m_btn_node_size.width*((i-1)%2 == 0 and 0.3 or 0.7),m_btn_node_size.height*(0.825 - 0.22*math.floor((i-1)/2)));
        m_btn_node:addChild(btnTemp)
        if self.m_btnTitleTab[i].sortType == tostring(self.m_currentSortType) then
            btnTemp:setEnabled(false);
            btnTemp:setHighlighted(true);
        end
    end
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-14,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_sort_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_sort_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_btnTitleTab = t_params.btnTitleTab or {};
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_currentSortType = t_params.currentSortType;
end

--[[--
    创建ui入口并初始化数据
]]
function game_sort_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_sort_pop;