--- 世界boss结算弹出板

local game_boss_result_pop = {
    m_popUi = nil,
    m_root_layer = nil, 
    m_tParams = nil,

    m_close_btn = nil,
    boss_name_label = nil,
    kill_label = nil,
    hurt_label = nil,
    rank_label = nil,
    goods_label_1 = nil,
    goods_label_2 = nil,
    count_label_1 = nil,
    count_label_2 = nil,
    reward_label = nil,

    showType = nil,
    title = nil,
};
--[[--
    销毁
]]
function game_boss_result_pop.destroy(self)
    -- body
    cclog("-----------------game_boss_result_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_tParams = nil;

    self.m_close_btn = nil;
    self.boss_name_label = nil;
    self.kill_label = nil;
    self.hurt_label = nil;
    self.rank_label = nil;
    self.goods_label_1 = nil;
    self.goods_label_2 = nil;
    self.count_label_1 = nil;
    self.count_label_2 = nil;
    self.reward_label = nil;
    self.showType = nil;
    self.title = nil;
end
--[[--
    返回
]]
function game_boss_result_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    if self.showType == 2 then
        game_scene:setVisibleBroadcastNode(false);
        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then
            require("like_oo.oo_controlBase"):openView("guild_join");
        else
            require("like_oo.oo_controlBase"):openView("guild");
        end
    else
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = function (  )
                game_scene:removePopByName("game_boss_result_pop");
                self:destroy();
            end});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_boss_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_boss_result_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.boss_name_label = ccbNode:labelTTFForName("boss_name_label");
    self.kill_label = ccbNode:labelTTFForName("kill_label");
    self.hurt_label = ccbNode:labelTTFForName("hurt_label");
    self.rank_label = ccbNode:labelTTFForName("rank_label");
    -- self.goods_label_1 = ccbNode:labelTTFForName("goods_label_1");
    self.goods_label_2 = ccbNode:spriteForName("icon_food");
    self.count_label_1 = ccbNode:labelTTFForName("count_label_1");
    self.count_label_2 = ccbNode:labelTTFForName("count_label_2");
    self.reward_label = ccbNode:labelTTFForName("reward_label")

    -- cclog("killerData = " .. json.encode(self.m_tParams.killerData));
    local boss_data = self.m_tParams.killerData;
    local boss_key = "";
    for k,v in pairs(boss_data) do
        boss_key = k;
    end
    local boss_info = boss_data[tostring(boss_key)];

    -- if boss_info.self_hurt > 0 then
    --     self.reward_label:setString("伤害奖励稍后在消息中发出")
    -- else
    --     self.reward_label:setString("无")
    -- end

    local killer = boss_info.killer;
    -- local bossCfg = getConfig(game_config_field.world_boss);
    
    -- local boss_id = bossCfg:getNodeWithKey(boss_key):getNodeWithKey("enemy_id"):toInt();
    -- local enemyCfg = getConfig(game_config_field.enemy_detail);
    -- local boss_name = enemyCfg:getNodeWithKey(boss_id):getNodeWithKey("enemy_name"):toStr();
    -- self.boss_name_label:setString(boss_name)

    cclog2(self.title,"self.title")
    if self.showType == 2 then
        self.boss_name_label:setString(self.title)        
    else
        self.boss_name_label:setString("attack on titan")
    end

    local my_rank = boss_info.self_rank;
    self.rank_label:setString(my_rank);

    local percent = math.floor(boss_info.self_hurt / boss_info.max_hp * 100);
    self.hurt_label:setString(tostring(boss_info.self_hurt .. "(" .. percent .. "%)"))

    -- local rewardCfg = getConfig(game_config_field.world_boss_reward);
    -- local bossRewardCfg = rewardCfg:getNodeWithKey(tostring(boss_key));
    -- local allReward = bossRewardCfg:getNodeWithKey("all_player"):getNodeAt(0);

    -- local icon,name,count = game_util:getRewardByItem(allReward,false);
    -- self.goods_label_1:setString(name);
    -- local count = 50 + boss_info.self_hurt * 0.001

    -- local my_food_rewrad = mcountath.floor(count * percent / 100);
    -- local my_food_rewrad = math.floor(count)
    local top10_reward = 0;
    -- if my_rank == 1 then
    --     top10_reward = bossRewardCfg:getNodeWithKey("top1"):getNodeAt(0):getNodeAt(2):toInt();
    -- elseif my_rank == 2 then
    --     top10_reward = bossRewardCfg:getNodeWithKey("top2"):getNodeAt(0):getNodeAt(2):toInt();
    -- elseif my_rank == 3 then
    --     top10_reward = bossRewardCfg:getNodeWithKey("top3"):getNodeAt(0):getNodeAt(2):toInt();
    -- elseif my_rank > 3 and my_rank <= 10 then
    --     top10_reward = bossRewardCfg:getNodeWithKey("top10"):getNodeAt(0):getNodeAt(2):toInt();
    -- else
    --     top10_reward = 0;
    -- end
    if my_rank <= 10 then
        top10_reward = 1;
    else
        top10_reward = 0;
    end
    self.reward_label:setString(string_helper.game_boss_result_pop.rankReward)
    if top10_reward > 0 then
        self.reward_label:setString(string_helper.game_boss_result_pop.rankReward)
    end
    -- self.count_label_1:setString(tostring(my_food_rewrad + top10_reward));

    local killer_id = killer.uid;
    local killer_name = killer.name;

    -- if killer_id == game_data:getUserStatusDataByKey("uid") then
    --     self.kill_label:setString("击杀");
    --     self.reward_label:setString("Rewards will be sent by mail later")
    --     --取特殊奖励
    --     local kill_reward = bossRewardCfg:getNodeWithKey("kill"):getNodeAt(0);
    --     local killIcon,killName,killCount = game_util:getRewardByItem(kill_reward,false);
    --     -- self.goods_label_2:setVisible(true);
    --     self.count_label_2:setString(tostring(killCount));
    -- else
    --     self.kill_label:setString("未击杀");
    --     self.goods_label_2:setVisible(false);
    --     self.count_label_2:setVisible(false);
    -- end
    self.kill_label:setString(string_helper.game_boss_result_pop.skilled .. killer_name);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text68)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text69)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text695)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text70)
    local text5 = ccbNode:labelTTFForName("text5")
    text5:setString(string_helper.ccb.text71)
    local text6 = ccbNode:labelTTFForName("text6")
    text6:setString(string_helper.ccb.text72)
    local text7 = ccbNode:labelTTFForName("text7")
    text7:setString(string_helper.ccb.text73)
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_boss_result_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_boss_result_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
    self.showType = t_params.showType or 1;
    self.title = t_params.title
end
--[[--
    创建ui入口并初始化数据
]]
function game_boss_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end
--[[--
    回调方法
]]
function game_boss_result_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end
return game_boss_result_pop;