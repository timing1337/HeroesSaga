--- 显示下奖励

local game_reward_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_btn_use = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    openType = nil,
};
--[[--
    销毁
]]
function game_reward_pop.destroy(self)
    -- body
    cclog("-----------------game_reward_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_btn_use = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.openType = nil;
end
--[[--
    返回
]]
function game_reward_pop.back(self,type)
    game_scene:removePopByName("game_reward_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 105 then--  购买
            -- self:back()
            if self.m_tParams.enter_type == 1 then
                self.m_tParams.okBtnCallBack()
            else 
                self:back()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event

    if self.openType == 1 then
        self:createOneReward(ccbNode)
    elseif self.openType == 3 then
        self:createThreeReward(ccbNode)
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    创建3个的
]]
function game_reward_pop.createThreeReward(self,ccbNode)
    ccbNode:openCCBFile("ccb/ui_reward_pop_3.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.title_label = ccbNode:labelTTFForName("title_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.title92)
    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    
    game_util:setControlButtonTitleBMFont(self.m_btn_use);

    local liveCfg = getConfig(game_config_field.active_fight_forever);
    local page = self.m_tParams.page
    self.title_label:setString(string.format(string_helper.game_reward_pop.di,(page*5)))
    local itemCfg = liveCfg:getNodeWithKey(tostring(page*5)):getNodeWithKey("reward")
    local rewardTable = {}
    local spriteTable = {}
    local countTable = {}
    for i=1,3 do
        rewardTable[i] = ccbNode:nodeForName("icon_node_" .. i);
        spriteTable[i] = ccbNode:spriteForName("goods_sprite_" .. i);
        countTable[i] = ccbNode:labelBMFontForName("count_label_" .. i)
        local icon,name,count = game_util:getRewardByItem(itemCfg:getNodeAt(i-1))
        if icon then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(spriteTable[i]:getContentSize().width*0.5,spriteTable[i]:getContentSize().height*0.5))
            spriteTable[i]:addChild(icon,10)

            countTable[i]:setString("×"..count)
            -- local label = game_util:createLabelBMFont({text = "×"..count,color = ccc3(255,255,255)});
            -- label:setAnchorPoint(ccp(0.5,0.5))
            -- label:setPosition(ccp(spriteTable[i]:getContentSize().width*0.5,-10))
            -- spriteTable[i]:addChild(label,10)            
        end
    end
end
--[[
    创建一个的
]]
function game_reward_pop.createOneReward(self,ccbNode)
    ccbNode:openCCBFile("ccb/ui_reward_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("icon_node");
    self.m_goods_sprite = ccbNode:spriteForName("goods_sprite");
    self.m_goods_info_label = ccbNode:labelTTFForName("goods_info_label");
    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.title_label = ccbNode:labelTTFForName("title_label")
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.title92)
    if self.m_tParams.enter_type == 1 then 
        self.title_label:setString(string_helper.game_reward_pop.nowReward)
        title = CCString:create(tostring(string_helper.game_reward_pop.get));
        self.m_btn_use:setTitleForState(title,CCControlStateNormal)
    else
        self.title_label:setString(string_helper.game_reward_pop.nextReward)
        title = CCString:create(tostring(string_helper.game_reward_pop.certain));
        self.m_btn_use:setTitleForState(title,CCControlStateNormal)
    end

    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    
    game_util:setControlButtonTitleBMFont(self.m_btn_use);

    local table = self.m_tParams.award
    local icon,name,count = game_util:getRewardByItemTable(table,true)
    if icon then
        icon:setAnchorPoint(ccp(0.5,0.5));
        local iconSize = self.m_goods_sprite:getContentSize();
        icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))
        self.m_goods_sprite:addChild(icon,10);
    end
    if name then
        self.m_goods_info_label:setString(name)
    end
end
--[[--
    刷新ui
]]
function game_reward_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_reward_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    -- cclog("self.m_tParams == " .. json.encode(self.m_tParams))
    self.openType = t_params.openType or 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_reward_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_reward_pop;