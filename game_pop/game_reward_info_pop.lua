---  查看奖励信息
local game_reward_info_pop = {
    m_popUi = nil,
    m_root_layer = nil,

    m_life_label = nil,
    m_def_label = nil,
    m_physical_atk_label = nil,
    m_speed_label = nil,
    m_magic_atk_label = nil,
    m_skill_layer = nil,
    m_btn_node = nil,
    itemCfg = nil,
    pos = nil,
    name_label = nil,
    openType = nil,
    reward_node = nil,
    itemId = nil,
};

--[[--
    销毁
]]
function game_reward_info_pop.destroy(self)
    cclog("-----------------game_reward_info_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;

    self.m_life_label = nil;
    self.m_def_label = nil;
    self.m_physical_atk_label = nil;
    self.m_speed_label = nil;
    self.m_btn_node = nil;  
    self.m_magic_atk_label = nil;
    self.m_skill_layer = nil;
    self.itemCfg = nil;
    self.pos = nil;
    self.name_label = nil;
    self.openType = nil;
    self.reward_node = nil;
    self.itemId = nil;
end
--[[--
    返回
]]
function game_reward_info_pop.back(self,type)
    game_scene:removePopByName("game_reward_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_reward_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_game_reward_info_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 

    self.m_btn_node = ccbNode:nodeForName("m_btn_node")
    self.reward_node = ccbNode:nodeForName("reward_node")

    self.m_btn_node:setPosition(ccp(self.pos.x-217,self.pos.y-40))

    local chargeCfg = getConfig(game_config_field.server_active_recharge)
    local itemCfg = chargeCfg:getNodeWithKey(tostring(self.itemId))
    local reward = itemCfg:getNodeWithKey("reward")
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local itemReward = reward:getNodeAt(btnTag-1)
        local rewardTable = json.decode(itemReward:getFormatBuffer())
        game_util:lookItemDetal(rewardTable)
    end
    local rewardCount = reward:getNodeCount()
    local nodeSize = self.m_btn_node:getContentSize()
    local dw = nodeSize.width / rewardCount
    local dx = dw / 2
    for i=1,rewardCount do
        local itemReward = reward:getNodeAt(i-1)
        local icon,name,count = game_util:getRewardByItem(itemReward)
        if icon then
            icon:setPosition(ccp(dx + (i-1)*dw,22));
            icon:setScale(0.7)
            self.reward_node:addChild(icon,1,1)

            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            button:setTag(i)
            button:setOpacity(0)
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp(dx + (i-1)*dw,22))
            self.reward_node:addChild(button);
        end
        if count then
            local countLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 10});
            countLabel:setPosition(ccp(dx + (i-1)*dw,10))
            self.reward_node:addChild(countLabel,3);
        end
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            self.m_isBeganIn = self.m_btn_node:boundingBox():containsPoint(realPos)
            return true;--intercept event
        elseif eventType == "ended" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            local isEndIn = self.m_btn_node:boundingBox():containsPoint(realPos)
            if isEndIn == false and self.m_isBeganIn == false then
                self:back();
                return
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_reward_info_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function game_reward_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.itemId = t_params.itemId;
    self.pos = t_params.pos
end

--[[--
    创建ui入口并初始化数据
]]
function game_reward_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_reward_info_pop;