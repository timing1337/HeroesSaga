--- 竞技场商店

local ui_arena_shop_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_vip_need_money_label = nil,
    m_next_vip_label = nil,
    m_list_view_bg = nil,
    m_vip_level = nil,
    m_vip_bar_node = nil,
};
--[[--
    销毁ui
]]
function ui_arena_shop_pop.destroy(self)
    -- body
    cclog("-----------------ui_arena_shop_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_vip_need_money_label = nil;
    self.m_next_vip_label = nil;
    self.m_list_view_bg = nil;
    self.m_vip_level = nil;
    self.m_vip_bar_node = nil;
end
--[[--
    返回
]]
function ui_arena_shop_pop.back(self,backType)
    game_scene:removePopByName("game_vip_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_arena_shop_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_arena_shop_pop.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_vip_need_money_label = ccbNode:labelTTFForName("vip_need_money_label");
    self.m_next_vip_label = ccbNode:labelTTFForName("next_vip_label");
    self.m_list_view_bg = ccbNode:nodeForName("vip_info_table");
    self.m_vip_level = ccbNode:labelTTFForName("vip_level");
    self.m_vip_bar_node = ccbNode:nodeForName("vip_bar_node");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);

    local vip_level = game_data:getVipLevel();
    local vipCfg = getConfig(game_config_field.vip);
    local nowCfg = vipCfg:getNodeWithKey(tostring(vip_level));

    local nextCfg = nil;
    if vip_level <= 9 then
       nextCfg = vipCfg:getNodeWithKey(tostring(vip_level+1));
    else
       nextCfg = vipCfg:getNodeWithKey(tostring(10));
    end
    local vip_exp = game_data:getVipExp();
    local need_exp = nextCfg:getNodeWithKey("need_exp"):toInt();
    self.m_vip_level:setString(tostring("VIP"..vip_level));

    local bar = ExtProgressBar:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png",CCSizeMake(180,15));
    -- bar:addLabelTTF(CCLabelTTF:create(vip_exp.."/"..need_exp,TYPE_FACE_TABLE.Arial_BoldMT,12));
    bar:setMaxValue(need_exp);
    local itemSize = self.m_vip_bar_node:getContentSize();
    bar:setCurValue(vip_exp,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(itemSize.width*0.5+30,itemSize.height*0.5))
    self.m_vip_bar_node:addChild(bar,10)
    local barTTF = CCLabelTTF:create(vip_exp.."/"..need_exp,TYPE_FACE_TABLE.Arial_BoldMT,12);
    barTTF:setAnchorPoint(ccp(0.5,0.5))
    barTTF:setPosition(ccp(itemSize.width*0.5+30,itemSize.height*0.5))
    self.m_vip_bar_node:addChild(barTTF,10)
    return ccbNode;
end

--[[--
    创建活动列表
]]
function ui_vip_pop.ui_arena_shop_pop(self,viewSize)
    
end

--[[--
    刷新ui
]]
function ui_arena_shop_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_arena_shop_pop.init(self,t_params)
    t_params = t_params or {};
end

--[[--
    创建ui入口并初始化数据
]]
function ui_arena_shop_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_arena_shop_pop;