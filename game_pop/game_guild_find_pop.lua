---  公会查找

local game_guild_find_pop = {
    m_popUi = nil,
};
--[[--
    销毁ui
]]
function game_guild_find_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_find_pop destroy-----------------");
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_guild_find_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_guild_find_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_guild_find_pop.createUi(self)
    local editText = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then
            local selGuildId = util.url_encode(editText)
            local function responseMethod(tag,gameData)
                self:back();
                game_scene:addPop("game_guild_info_pop",{gameData=gameData,selGuildId=selGuildId})
            end
            --工会详情  guild_id = 工会id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_detail"), http_request_method.GET, {guild_id=selGuildId},"association_guild_detail")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_find_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    m_edit_bg_node:setOpacity(0);
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            editText = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = m_edit_bg_node:getContentSize()});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_edit_bg_node:addChild(editBox);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_guild_find_pop.refreshUi(self)

end
--[[--
    初始化
]]
function game_guild_find_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_find_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_find_pop;