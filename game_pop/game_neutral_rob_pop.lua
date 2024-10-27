--- 中立地图掠夺

local game_neutral_rob_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_map_id = nil,
    m_times_label_1 = nil,
    m_times_label_2 = nil,
    m_reward_node_1 = nil,
    m_reward_node_2 = nil,
    m_reward_count_label_1 = nil,
    m_reward_count_label_2 = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_callBackFunc = nil,
    m_steal_flag = nil,
    m_rob_falg = nil,
};
--[[--
    销毁ui
]]
function game_neutral_rob_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_rob_pop destroy-----------------");
    self.m_root_layer = nil
    self.m_close_btn = nil
    self.m_map_id = nil
    self.m_times_label_1 = nil
    self.m_times_label_2 = nil
    self.m_reward_node_1 = nil
    self.m_reward_node_2 = nil
    self.m_reward_count_label_1 = nil
    self.m_reward_count_label_2 = nil
    self.m_left_btn = nil
    self.m_right_btn = nil
    self.m_callBackFunc = nil
    self.m_steal_flag = nil
    self.m_rob_falg = nil
end
--[[--
    返回
]]
function game_neutral_rob_pop.back(self,backType)
    game_scene:removePopByName("game_neutral_rob_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_rob_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 2 or btnTag == 3 then--2 偷取 3 掠夺
            if btnTag == 2 and not self.m_steal_flag then
                game_util:addMoveTips({text = string_helper.game_neutral_rob_pop.tips1})
                return
            end
            if btnTag == 3 and not self.m_rob_falg then
                game_util:addMoveTips({text = string_helper.game_neutral_rob_pop.tips2})
                return
            end
            local gameData = game_data:getDataByKey("public_land_data") or {}
            local uid = gameData.friend_uid
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local battle = data:getNodeWithKey("battle")
                if battle and battle:getNodeCount() > 0 then--有战斗
                    game_data:setDataByKeyAndValue("game_neutral_rob_data",{uid = uid,home_type = 2})
                    game_data:setBattleType("game_neutral_rob_pop")
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData})
                else
                    local public_land_data = json.decode(data:getFormatBuffer())
                    game_data:setDataByKeyAndValue("public_land_data",public_land_data)
                    game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                    local rewardCount = game_util:rewardTipsByDataTable(public_land_data.reward)
                    local typeValue = public_land_data.type or 1
                    if typeValue == 1 and rewardCount == 0 then
                        game_util:addMoveTips({text = string_helper.game_neutral_rob_pop.tips3})
                    end
                    if self.m_callBackFunc then
                        self.m_callBackFunc()
                    end
                    self:back()
                end
            end
            
            -- 掠夺 map_id&type=1  1 偷取 2 抢夺
            local params = {}
            params.map_id = self.m_map_id
            params.type = btnTag - 1
            params.uid = uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_go_steal_rob"), http_request_method.GET, params,"public_land_go_steal_rob")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_game_neutral_rob_pop.ccbi")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_times_label_1 = ccbNode:labelTTFForName("m_times_label_1")
    self.m_times_label_2 = ccbNode:labelTTFForName("m_times_label_2")
    self.m_reward_node_1 = ccbNode:nodeForName("m_reward_node_1")
    self.m_reward_node_2 = ccbNode:nodeForName("m_reward_node_2")
    self.m_reward_count_label_1 = ccbNode:labelTTFForName("m_reward_count_label_1")
    self.m_reward_count_label_2 = ccbNode:labelTTFForName("m_reward_count_label_2")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_neutral_rob_pop.refreshUi(self)
    local seed_cfg = getConfig(game_config_field.seed)
    local gameData = game_data:getDataByKey("public_land_data") or {}
    local map_id_max_steal_times = gameData.map_id_max_steal_times or 2
    local map_id_max_rob_times = gameData.map_id_max_rob_times or 2
    local map = gameData.map or {}
    local itemData = map[tostring(self.m_map_id)]
    if itemData then
        local steal_times = itemData.steal_times or -1
        local rob_times = itemData.rob_times or -1
        self.m_times_label_1:setString(tostring(steal_times) .. "/" .. tostring(map_id_max_steal_times))
        self.m_times_label_2:setString(tostring(rob_times) .. "/" .. tostring(map_id_max_rob_times))
        if steal_times < map_id_max_steal_times then
            self.m_steal_flag = true
        end
        if rob_times < map_id_max_rob_times then
            self.m_rob_falg = true
        end
        local seed_id = itemData.seed_id or 0
        if seed_id > 0 then
            local itemCfg = seed_cfg:getNodeWithKey(tostring(seed_id))
            if itemCfg then
                local reward = itemData.reward or {}
                local tempCount = #reward
                if tempCount > 0 then
                    local icon,name,count = game_util:getRewardByItemTable(reward[1],true)
                    if icon then
                        self.m_reward_node_1:addChild(icon)
                    end
                    local icon2,_,_ = game_util:getRewardByItemTable(reward[1],true)
                    if icon2 then
                        self.m_reward_node_2:addChild(icon2)
                    end
                    if count then
                        self.m_reward_count_label_1:setString("×" .. tostring(count))
                        self.m_reward_count_label_2:setString("×" .. tostring(count))
                    end
                end
            end
        end
    end
end
--[[--
    初始化
]]
function game_neutral_rob_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_map_id = t_params.map_id
    self.m_callBackFunc = t_params.callBackFunc
    self.m_steal_flag = false
    self.m_rob_falg = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_rob_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_neutral_rob_pop;