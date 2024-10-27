---  不是月卡vip 提示

local ui_monthvip_shop_novip_pop = {
    m_root_layer = nil,

    m_endCallFun = nil,
};
--[[--
    销毁ui
]]
function ui_monthvip_shop_novip_pop.destroy(self)
    -- body
    self.m_root_layer = nil;

    self.m_endCallFun = nil;
end
--[[--
    返回
]]
function ui_monthvip_shop_novip_pop.back(self,backType)
    game_scene:removePopByName("ui_monthvip_shop_novip_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function ui_monthvip_shop_novip_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "createUi  btnTag   ==  ")
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then -- 右边按钮
            if type(self.m_endCallFun) == "function" then 
                self.m_endCallFun()
            end
            self:back()
        elseif btnTag == 3 then -- 左边按钮
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_monthvip_shop_noviptops_pop.ccbi")
    self.m_node_itemsbg = ccbNode:nodeForName("m_node_itemsbg")

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            cclog2("createUi stop touch ")
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false, GLOBAL_TOUCH_PRIORITY-20 ,true);
    self.m_root_layer:setTouchEnabled(true);
    -- -- 重置按钮出米优先级 防止被阻止
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);

    local m_conbtn_right = ccbNode:controlButtonForName("m_conbtn_right");
    local m_conbtn_left = ccbNode:controlButtonForName("m_conbtn_left")
    game_util:setCCControlButtonTitle(m_conbtn_left,string_helper.ccb.title152)
    game_util:setCCControlButtonTitle(m_conbtn_right,string_helper.ccb.title153)
    m_conbtn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);
    m_conbtn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21);

    local onBtnCilck = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "onBtnCilck  btnTag  ===  ")
        local reward = self.m_showItemData.shop_reward or {}
        game_util:lookItemDetal( reward[1] )
    end

    local m_title_label = ccbNode:labelTTFForName("m_label_itemmsg")
    local m_label_tips = ccbNode:labelTTFForName("m_label_tips")
    m_label_tips:setString(string_helper.ccb.file85)
    local m_cost_label = ccbNode:labelTTFForName("m_label_perprice")
    local m_label_curprice = ccbNode:labelTTFForName("m_label_curprice")
    local m_buy_flag = ccbNode:labelBMFontForName("m_buy_flag")
    if m_buy_flag then m_buy_flag:setString( string_helper.ccb.file78 ) end
    local m_imgNode = ccbNode:nodeForName("m_node_showicon")
    m_imgNode:removeAllChildrenWithCleanup(true);
    m_title_label:setString("")
    m_cost_label:setString("0")
    m_label_curprice:setString("0")
    local itemData = self.m_showItemData
    if itemData then
        m_cost_label:setString(tostring(itemData.show_value))
        m_label_curprice:setString(tostring(itemData.need_value))
        local reward = itemData.shop_reward or {}
        if #reward > 0 then
            local icon,name,count = game_util:getRewardByItemTable(reward[1])
            if icon then
                icon:setPosition( ccp(m_imgNode:getContentSize().width * 0.5, m_imgNode:getContentSize().height * 0.5) )
                icon:setScale(1)
                m_imgNode:addChild(icon)
            end
            if count then
                local m_num_label = game_util:createLabelBMFont({text = "x" .. tostring(count)})
                m_num_label:setAnchorPoint( ccp(0.5, 0.5) )
                m_num_label:setPosition( icon:getContentSize().width * 0.5, -5 )
                icon:addChild( m_num_label, 10 )
            end
            if name then
                m_title_label:setString(tostring(name))
            end

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
            button:setOpacity(0)
            icon:addChild(button)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 21)
        end
    end
    return ccbNode;
end

--[[--
    刷新ui
]]
function ui_monthvip_shop_novip_pop.refreshUi(self)

end

--[[
    初始化数据
]]
function ui_monthvip_shop_novip_pop.init( self, t_params )
    t_params = t_params or {}
    self.m_endCallFun = t_params.endCallFunc
    self.m_showItemData = t_params.itemData or {}
end

--[[--
    创建ui入口并初始化数据
]]
function ui_monthvip_shop_novip_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_monthvip_shop_novip_pop;
