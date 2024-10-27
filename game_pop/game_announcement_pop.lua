--- 公告

local game_announcement_pop = {
    m_list_view_bg = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_title_label = nil,
    m_back_btn = nil,
    m_typeName = nil,
    gonggao_sprite = nil,
};
--[[--
    销毁ui
]]
function game_announcement_pop.destroy(self)
    -- body
    cclog("-----------------game_announcement_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_title_label = nil;
    self.m_typeName = nil;
    self.gonggao_sprite = nil;
    self.m_back_btn = nil;
end
--[[--
    返回
]]
function game_announcement_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_announcement_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_announcement_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
        if btnTag == 2 then
            self:refreshUi();    
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_announcement.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.gonggao_sprite = ccbNode:spriteForName("gonggao_sprite")

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_announcement_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local size= self.m_list_view_bg:getContentSize();
    local pos = self.m_list_view_bg:boundingBox().origin

    cclog("1 x = " .. pos.x .. " ; y = " .. pos.y)
    pos = self.m_list_view_bg:getParent():convertToWorldSpace(pos);
    cclog("2 x = " .. pos.x .. " ; y = " .. pos.y)
    cclog(" size.width = " .. size.width .. " ; size.height = " .. size.height)
    local webView = zcWebView:create(CCRectMake(pos.x,pos.y,size.width,size.height));
    if self.m_typeName == "announcement" then
        self.m_title_label:setString(string_helper.game_announcement_pop.announcement)
        self.m_back_btn:setVisible(false);
        webView:requestURL(master_url .. "/static/notice/notice.html");
        self.gonggao_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ohter_public_gonggao.png"))
    elseif self.m_typeName == "help" then
        self.m_title_label:setString(string_helper.game_announcement_pop.help)
        webView:requestURL(master_url .. "/static/guide/index.html");
        self.gonggao_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ohter_public_help.png"))
    end
    self.m_list_view_bg:addChild(webView);
end
--[[--
    初始化
]]
function game_announcement_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_typeName = t_params.typeName or "announcement";
end

--[[--
    创建ui入口并初始化数据
]]
function game_announcement_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_announcement_pop;