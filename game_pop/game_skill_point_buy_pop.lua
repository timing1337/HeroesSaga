--- 技能点购买

local game_skill_point_buy_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_title_label = nil,
    m_tips_label = nil,
    m_point_spr = nil,
    m_cost_node_1 = nil,
    m_cost_node_2 = nil,
    m_cost_energy_label = nil,
    m_energy_total_label = nil,
    m_cost_gold_label = nil,
    m_gold_total_label = nil,
    m_close_btn = nil,
    m_cancel_btn = nil,
    m_sure_btn = nil,
    m_callBackFunc = nil,
    m_tree_id = nil,
};
--[[--
    销毁
]]
function game_skill_point_buy_pop.destroy(self)
    -- body
    cclog("-----------------game_skill_point_buy_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_title_label = nil;
    self.m_tips_label = nil;
    self.m_point_spr = nil;
    self.m_cost_node_1 = nil;
    self.m_cost_node_2 = nil;
    self.m_cost_energy_label = nil;
    self.m_energy_total_label = nil;
    self.m_cost_gold_label = nil;
    self.m_gold_total_label = nil;
    self.m_close_btn = nil;
    self.m_cancel_btn = nil;
    self.m_sure_btn = nil;
    self.m_callBackFunc = nil;
    self.m_tree_id = nil;
end
--[[--
    返回
]]
function game_skill_point_buy_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_skill_point_buy_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_skill_point_buy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--取消
            self:back();
        elseif btnTag == 3 then--确定
            if self.m_tree_id == nil then return end
            local function responseMethod(tag,gameData)
                game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                if self.m_callBackFunc and type(self.m_callBackFunc) == "function" then
                    self.m_callBackFunc();
                end
                self:back();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_add_tree_point"), http_request_method.GET,{tree = self.m_tree_id},"leader_skill_add_tree_point")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_skill_point_buy_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_point_spr = ccbNode:spriteForName("m_point_spr")
    self.m_cost_node_1 = ccbNode:nodeForName("m_cost_node_1")
    self.m_cost_node_2 = ccbNode:nodeForName("m_cost_node_2")
    self.m_cost_energy_label = ccbNode:labelTTFForName("m_cost_energy_label")
    self.m_energy_total_label = ccbNode:labelTTFForName("m_energy_total_label")
    self.m_cost_gold_label = ccbNode:labelTTFForName("m_cost_gold_label")
    self.m_gold_total_label = ccbNode:labelTTFForName("m_gold_total_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_cancel_btn = ccbNode:controlButtonForName("m_cancel_btn")
    self.m_sure_btn = ccbNode:controlButtonForName("m_sure_btn")

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_cancel_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_sure_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_skill_point_buy_pop.refreshUi(self)
    cclog("self.m_tree_id ===" .. tostring(self.m_tree_id));
    local tGameData = game_data:getHarborData();
    local skill_point = tGameData.skill_point[tostring(self.m_tree_id)]
    local leader_skill_develop_cfg = getConfig(game_config_field.leader_skill_develop);
    local nextPoint = 0;
    if skill_point then
        nextPoint = skill_point[1] + skill_point[2] + 1;
        self.m_tips_label:setString(nextPoint..tostring(LEADER_SKILL_TREE_TABLE[self.m_tree_id].name).. string_helping.game_skill_point_buy_pop.buyTips1);
    else
        nextPoint = 1;
        self.m_tips_label:setString(string_helping.game_skill_point_buy_pop.buyTips2..string_helper.game_skill_point_buy_pop.buyTips3 .. tostring(LEADER_SKILL_TREE_TABLE[self.m_tree_id].name) );
    end
    local itemCfg = leader_skill_develop_cfg:getNodeWithKey(tostring(nextPoint))
    if itemCfg then
        local costEnergy = itemCfg:getNodeWithKey("energy_" .. self.m_tree_id):toInt();
        local costCoin = itemCfg:getNodeWithKey("coin_" .. self.m_tree_id):toInt();
        if costEnergy > 0 then
            local totalEnergy = game_data:getUserStatusDataByKey("energy") or 0
            self.m_energy_total_label:setString(tostring(totalEnergy));
            game_util:setCostLable(self.m_cost_energy_label,costEnergy,totalEnergy);
        else
            self.m_cost_node_1:setVisible(false);
        end
        if costCoin > 0 then
            local totalGold = game_data:getUserStatusDataByKey("coin") or 0
            self.m_gold_total_label:setString(tostring(totalGold));
            game_util:setCostLable(self.m_cost_gold_label,costCoin,totalGold);
        else
            self.m_cost_node_2:setVisible(false);
        end
        if not self.m_cost_node_1:isVisible() and self.m_cost_node_2:isVisible() then
            self.m_cost_node_2:setPositionY(self.m_cost_node_2:getPositionY() + 15);
        elseif self.m_cost_node_1:isVisible() and not self.m_cost_node_2:isVisible() then
            self.m_cost_node_1:setPositionY(self.m_cost_node_1:getPositionY() - 15);
        end
    else

    end
    local treeId = tonumber(self.m_tree_id);
    if treeId > 0 and treeId < 9 then
        self.m_point_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ball" .. treeId .. ".png"));
    end
end

--[[--
    初始化
]]
function game_skill_point_buy_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_tree_id = t_params.tree_id or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_skill_point_buy_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_skill_point_buy_pop;