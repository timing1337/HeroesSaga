--- 活动

local ui_vip_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_vip_need_money_label = nil,
    m_next_vip_label = nil,
    m_list_view_bg = nil,
    m_vip_level = nil,
    m_vip_bar_node = nil,
    text_scroll = nil,
};
--[[--
    销毁ui
]]
function ui_vip_pop.destroy(self)
    -- body
    cclog("-----------------ui_vip_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_vip_need_money_label = nil;
    self.m_next_vip_label = nil;
    self.m_list_view_bg = nil;
    self.m_vip_level = nil;
    self.m_vip_bar_node = nil;
    self.text_scroll = nil;
end
--[[--
    返回
]]
function ui_vip_pop.back(self,backType)
    game_scene:removePopByName("game_vip_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_vip_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 101 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_vip_pop.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    game_util:setCCControlButtonTitle(self.m_close_btn,string_helper.ccb.title36)
    self.m_vip_need_money_label = ccbNode:labelTTFForName("vip_need_money_label");
    self.m_next_vip_label = ccbNode:labelTTFForName("next_vip_label");
    self.m_list_view_bg = ccbNode:nodeForName("vip_info_table");
    self.m_vip_level = ccbNode:labelTTFForName("vip_level");
    self.m_vip_bar_node = ccbNode:nodeForName("vip_bar_node");
    local  title37 = ccbNode:labelTTFForName("title37");
    local title38 = ccbNode:labelTTFForName("title38");
    local title39 = ccbNode:labelTTFForName("title39");
    title39:setString(string_helper.ccb.title39);
    title38:setString(string_helper.ccb.title38);
    title37:setString(string_helper.ccb.title37);

    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    cclog("self.text_scroll == " .. tostring(self.text_scroll))

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setControlButtonTitleBMFont(self.m_close_btn)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
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

    self.createVipDescription()
    return ccbNode;
end
--[[
    加载vip描述
]]
function ui_vip_pop.createVipDescription(self)
    local vipCfg = getConfig(game_config_field.vip);
    local count = vipCfg:getNodeCount()
    for i=1,count do
        local itemCfg = vipCfg:getNodeWithKey(tostring(i-1))
        local description = itemCfg:getNodeWithKey("story"):toStr()

        -- print("description = " .. description)
    end

    -- self.text_scroll:addChild()
end
--[[--
    创建活动列表
]]
function ui_vip_pop.createTableView(self,viewSize)
    -- local vipCfg = getConfig(game_config_field.vip);
    -- local params = {};
    -- params.viewSize = viewSize;
    -- params.row = 1;
    -- params.column = 1; --列
    -- params.totalItem = vipCfg:getNodeCount();
    -- params.direction = kCCScrollViewDirectionVertical;--纵向
    -- local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    -- params.newCell = function(tableView,index) 
    --     local cell = tableView:dequeueCell()

    --     if cell == nil then
    --         cell = CCTableViewCell:new();
    --         cell:autorelease();        
            

    --         local tempLabel = game_util:createLabelTTF({text = "1\nj\nj\nj\nj\nj\nj\nj\n1\nj\nj\nj\nj\nj\nj\nj\n1\nj\nj\nj\nj\nj\nj\nj\n1\nj\nj\nj\nj\nj\nj\nj\n",color = ccc3(196,197,147)})
    --         tempLabel:setDimensions(CCSizeMake(240,120))
    --         tempLabel:setAnchorPoint(ccp(0.5,0.5))
    --         tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2))
    --         tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    --         cell:addChild(tempLabel)    
    --     end
    --     if cell ~= nil then

    --     end
    --     return cell;
    -- end
    -- return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function ui_vip_pop.refreshUi(self)
    -- self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_vip_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function ui_vip_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_vip_pop;