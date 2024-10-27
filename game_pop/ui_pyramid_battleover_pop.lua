--- 金字塔战胜提示

local ui_pyramid_battleover_pop = {
    m_gameData = nil,
    m_showFlag = nil,
    m_ccbNode = nil,
    m_canTouch = nil,
};

--[[--
    销毁ui
]]
function ui_pyramid_battleover_pop.destroy(self)
    -- body
    cclog("-----------------ui_pyramid_battleover_pop destroy-----------------");
    self.m_gameData = nil;
    self.m_showFlag = nil;
    self.m_ccbNode = nil;
    self.m_canTouch = nil;
end
--[[--
    返回
]]
function ui_pyramid_battleover_pop.back(self,backType)
    game_scene:removePopByName("ui_pyramid_battleover_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_pyramid_battleover_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_battleover.ccbi");

    self.m_node_winboard = ccbNode:nodeForName("m_node_winboard")
    self.m_label_battletitle = ccbNode:labelTTFForName("m_label_battletitle")
    self.m_label_battletitle:setVisible(false)


    if self.m_gameData.luckPos == true then
        local m_node_hong_win2 = ccbNode:nodeForName("m_node_hong_win1")
        m_node_hong_win2:removeFromParentAndCleanup(true)
    else
        local m_node_hong_win2 = ccbNode:nodeForName("m_node_hong_win2")
        m_node_hong_win2:removeFromParentAndCleanup(true)
        local m_node_lucksign = ccbNode:nodeForName("m_node_lucksign")
        m_node_lucksign:removeFromParentAndCleanup(true)
    end

    if self.m_gameData then
        local isWin = self.m_gameData.is_win 
        if isWin == true then
            self.m_node_winboard:setVisible(true)
            self.m_label_battletitle:setColor(ccc3(85,5,85))
            if self.m_gameData.is_luck == true then
                self.m_label_battletitle:setString(string_helper.ui_pyramid_battleover_pop.luckyPos)
                local m_spr_battletitle = ccbNode:nodeForName("ui_pyramid_n_XYNW.png")
                game_util:setSpriteDisplayBySpriteFrameName()
            else
                self.m_label_battletitle:setString(string_helper.ui_pyramid_battleover_pop.rankUp)
                game_util:setSpriteDisplayBySpriteFrameName("ui_pyramid_n_gx.png")
            end
        else
            self.m_node_winboard:setVisible(false)
            self.m_label_battletitle:setColor(ccc3(155,155,155))
        end

        -- 敌人  失败方
        local m_node_lan_playericon = ccbNode:nodeForName("m_node_lan_playericon")
        local m_label_lanname = ccbNode:labelTTFForName("m_label_lanname")
        m_node_lan_playericon:removeAllChildrenWithCleanup(true)
        local iconBoardSize = m_node_lan_playericon:getContentSize()
        local role = self.m_gameData.battle.init.dfd_role or math.random(1, 5)
        local name = self.m_gameData.enemy_name or ""
        m_label_lanname:setString(name)
        local tempNode = game_util:createIconByName("icon_player_role_" .. tostring(role) .. ".png")
        if tempNode then
            tempNode:setAnchorPoint(ccp(0.5,0.5))
            tempNode:setPositionX(iconBoardSize.width * 0.5)
            tempNode:setPositionY(iconBoardSize.height * 0.5)
            tempNode:setScale(0.95)
            m_node_lan_playericon:addChild(tempNode, 1, 998)
        end

        -- 自己
        local m_node_hong_playericon = ccbNode:nodeForName("m_node_hong_playericon")
        local m_label_hongname = ccbNode:labelTTFForName("m_label_hongname")
        m_node_hong_playericon:removeAllChildrenWithCleanup(true)
        local iconBoardSize = m_node_hong_playericon:getContentSize()
        local role = game_data:getUserStatusDataByKey("role") or math.random(1, 5)
        local name = game_data:getUserStatusDataByKey("show_name") or ""
        m_label_hongname:setString(name)
        local tempNode = game_util:createIconByName("icon_player_role_" .. tostring(role) .. ".png")
        if tempNode then
            tempNode:setAnchorPoint(ccp(0.5,0.5))
            tempNode:setPositionX(iconBoardSize.width * 0.5)
            tempNode:setPositionY(iconBoardSize.height * 0.5)
            tempNode:setScale(0.95)
            m_node_hong_playericon:addChild(tempNode, 1, 998)
        end
    end

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if not self.m_canTouch then return true end
            if self.m_showFlag == true then return true end
            self.m_showFlag = true
            self.m_ccbNode:runAnimations("getoff")
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);


    local function animEndCallFunc(animName)
        if animName == "comein" then
            self.m_canTouch = true
        elseif animName == "getoff" then
            self:back()
        end
    end
    ccbNode:registerAnimFunc(animEndCallFunc)

    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    刷新ui
]]
function ui_pyramid_battleover_pop.refreshUi(self)

end
--[[--
    初始化
]]
function ui_pyramid_battleover_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = t_params.gameData
end

--[[--
    创建ui入口并初始化数据
]]
function ui_pyramid_battleover_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_pyramid_battleover_pop;