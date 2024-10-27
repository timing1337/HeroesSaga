--- 助威激活
local game_assistant_activation_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_btn_use = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    openType = nil,
    tips_label_1 = nil,
    m_list_view_bg = nil,
};
--[[--
    销毁
]]
function game_assistant_activation_pop.destroy(self)
    -- body
    cclog("-----------------game_assistant_activation_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_btn_use = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.openType = nil;
    self.tips_label_1 = nil;
    self.m_list_view_bg = nil;
end
--[[--
    返回
]]
function game_assistant_activation_pop.back(self,type)
    game_scene:removePopByName("game_assistant_activation_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_assistant_activation_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 105 then--  购买
            if self.m_tParams.okBtnCallBack then
                self.m_tParams.okBtnCallBack()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_assistant_activation_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.tips_label_1 = ccbNode:labelTTFForName("tips_label_1")
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.text59)
    -- game_util:setControlButtonTitleBMFont(self.m_btn_use);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_assistant_activation_pop.createTableView(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab
    local params = {};
    params.row = 1;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.viewSize = viewSize;
    local itemSize = nil;
    if tempCount > 3 then
        itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    else
        params.column = tempCount; --列
        itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    end
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
            local _,ownCount = game_data:getMetalByTable(rewardTab[index+1],0,0);
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                icon:setScale(0.65);
                cell:addChild(icon)
                if count > ownCount then
                    icon:setColor(ccc3(77,77,77))
                end
            end
            if name then
                local color = count > ownCount and ccc3(77,77,77) or ccc3(0,255,0)
                local tempLabel = game_util:createLabelTTF({text = name,color = color,fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_assistant_activation_pop.refreshUi(self)
    local assCfg = getConfig(game_config_field.assistant)
    local itemCfg = assCfg:getNodeWithKey(tostring(self.m_tParams.index))
    -- local sort = itemCfg:getNodeWithKey("sort"):toInt()
    -- local price = itemCfg:getNodeWithKey("price"):toInt()
    local cardlimit = itemCfg:getNodeWithKey("cardlimit")
    cardlimit = cardlimit and cardlimit:toInt() or 0;
    local att_type = itemCfg:getNodeWithKey("att_type")
    att_type = att_type and att_type:toInt() or 0;
    local att_value = itemCfg:getNodeWithKey("att_value")
    att_value = att_value and att_value:toInt() or 0;
    local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. att_type] or {};
    local activation = itemCfg:getNodeWithKey("activation")
    if activation then
        activation = json.decode(activation:getFormatBuffer())
    else
        activation = {}
    end
    local icon,name,count = game_util:getRewardByItemTable(activation[1])
    local tempStr = string_helper.game_assistant_activation_pop.use .. tostring(count) .. string_helper.game_assistant_activation_pop.ge .. tostring(name) .. string_helper.game_assistant_activation_pop.text .. tostring(abilityItem.name) .. string_helper.game_assistant_activation_pop.de .. tostring(att_value) .. "%";
    self.tips_label_1:setString(tempStr)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize(),activation)
    self.m_list_view_bg:addChild(tempTableView)
end
--[[--
    初始化
]]
function game_assistant_activation_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.openType = t_params.openType or 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_assistant_activation_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_assistant_activation_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_assistant_activation_pop;