--- game_maze_item_pop2信息

local game_maze_item_pop2 = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_callBackFunc = nil,
    itemData = nil,
    m_itemType = nil,
    openType = nil,
};

--[[--
    销毁
]]
function game_maze_item_pop2.destroy(self)
    -- body
    cclog("-----------------game_maze_item_pop2 destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_callBackFunc = nil;
    self.itemData = nil;
    self.m_itemType = nil;
    self.openType = nil;
end
--[[--
    返回
]]
function game_maze_item_pop2.back(self,type)
    game_scene:removePopByName("game_maze_item_pop2");
end
--[[--
    读取ccbi创建ui
]]
function game_maze_item_pop2.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then
            if self.m_itemType == 1 then
                local function responseMethod(tag,gameData)
                    local maze_item_cfg = getConfig(game_config_field.maze_item)
                    local itemCfg = maze_item_cfg:getNodeWithKey(tostring(self.itemData.id))
                    if itemCfg then
                        local name = itemCfg:getNodeWithKey("name"):toStr();
                        game_util:addMoveTips({text = tostring(name) .. string_helper.game_maze_item_pop2.use});
                    end
                    local data = gameData:getNodeWithKey("data");
                    local gameData = json.decode(data:getFormatBuffer()) or {};
                    if self.m_callBackFunc then
                        self.m_callBackFunc({gameData = gameData})
                    end
                    self:back();
                end
                local params = {item_id = self.itemData.id}
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_use_item"), http_request_method.GET, params,"maze_use_item")
            end
        elseif btnTag == 5 then

        elseif btnTag == 3 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_maze_item_pop2.ccbi");
    local m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");
    m_left_btn:setVisible(false)
    m_right_btn:setVisible(false)
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 25);
    m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-25);
    m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-25);

    local sort = 0;
    if self.m_itemType == 1 then
        local maze_item_cfg = getConfig(game_config_field.maze_item)
        local itemCfg = maze_item_cfg:getNodeWithKey(tostring(self.itemData.id))
        -- self.itemData.count
        if itemCfg then
            sort = itemCfg:getNodeWithKey("sort"):toInt();
            local name = itemCfg:getNodeWithKey("name"):toStr();
            m_title_label:setString(name)
            if sort ~= 0 then
                m_left_btn:setVisible(true)
                local tempSize = m_left_btn:getParent():getContentSize();
                m_left_btn:setPositionX(tempSize.width*0.5)
                game_util:setCCControlButtonTitle(m_left_btn,string_helper.game_maze_item_pop2.use2);
                if self.openType == 2 then
                    m_left_btn:setVisible(false)
                end
            end
            local story = itemCfg:getNodeWithKey("story")
            if story then
                story = story:toStr();
            else
                story = string_helper.game_maze_item_pop2.cfgTips
            end
            m_story_label:setString(story);
        end
        local icon = game_util:createMazeItemIconByCfg(itemCfg);
        if icon then
            m_icon_spr:removeAllChildrenWithCleanup(true)
            icon:setAnchorPoint(ccp(0.5,0.5))
            local size = m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            m_icon_spr:addChild(icon,10)
        end
    elseif self.m_itemType == 2 then
        local maze_buff_cfg = getConfig(game_config_field.maze_buff)
        local itemCfg = maze_buff_cfg:getNodeWithKey(tostring(self.itemData.id))
        if itemCfg then
            local name = itemCfg:getNodeWithKey("name"):toStr();
            m_title_label:setString(name)
            local story = itemCfg:getNodeWithKey("story")
            if story then
                story = story:toStr();
            else
                story = string_helper.game_maze_item_pop2.cfgTips
            end
            m_story_label:setString(story);
        end
        local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
        if icon then
            m_icon_spr:removeAllChildrenWithCleanup(true)
            icon:setAnchorPoint(ccp(0.5,0.5))
            local size = m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            m_icon_spr:addChild(icon,10)
        end
    end
    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_maze_item_pop2.refreshUi(self)

end

--[[--
    初始化
]]
function game_maze_item_pop2.init(self,t_params)
    t_params = t_params or {};
    self.itemData = t_params.itemData
    self.m_itemType = t_params.itemType or 1
    self.openType = t_params.openType or 1
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_maze_item_pop2.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_maze_item_pop2;