--- 
local game_dart_ship_detail_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_logType = nil,
    m_list_view_node = nil,
    m_scroll_view = nil,
};

--[[--
    销毁
]]
function game_dart_ship_detail_pop.destroy(self)
    -- body
    cclog("-----------------game_dart_ship_detail_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_logType = nil;
    self.m_list_view_node = nil;
    self.m_scroll_view = nil;
end
--[[--
    返回
]]
function game_dart_ship_detail_pop.back(self,type)
    game_scene:removePopByName("game_dart_ship_detail_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_dart_ship_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_ship_detail_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    self.m_scroll_view = ccbNode:scrollViewForName("m_scroll_view")
    self.m_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新
]]
function game_dart_ship_detail_pop.refreshContent(self)
    self.m_scroll_view:getContainer():removeAllChildrenWithCleanup(true)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_dart_ship_detail_content.ccbi");
    ccbNode:setAnchorPoint(ccp(0,0));
    local viewSize = self.m_scroll_view:getViewSize();
    local tempSize = ccbNode:getContentSize();
    self.m_scroll_view:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view:addChild(ccbNode)
end

--[[--
    刷新ui
]]
function game_dart_ship_detail_pop.refreshUi(self)
    self:refreshContent();
end
--[[--
    初始化
]]
function game_dart_ship_detail_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_ship_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_ship_detail_pop;