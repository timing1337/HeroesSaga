--- 地块

local game_neutral_land_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_ok_btn = nil,
    m_name_label = nil,
    m_time_label = nil,
    m_gain_label = nil,
    m_worker_icon_node = nil,
    m_work_detail_label = nil,
    m_sel_seed_id = nil,
    m_map_id = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,

};
--[[--
    销毁ui
]]
function game_neutral_land_pop.destroy(self)
    -- body
    cclog("-----------------game_neutral_land_pop destroy-----------------");
    self.m_root_layer = nil
    self.m_close_btn = nil
    self.m_ok_btn = nil
    self.m_name_label = nil
    self.m_time_label = nil
    self.m_gain_label = nil
    self.m_worker_icon_node = nil
    self.m_work_detail_label = nil
    self.m_sel_seed_id = nil
    self.m_map_id = nil
    self.m_callBackFunc = nil
    self.m_tips_label = nil
end
--[[--
    返回
]]
function game_neutral_land_pop.back(self,backType)
    game_scene:removePopByName("game_neutral_land_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_neutral_land_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--取消生产
            if self.m_map_id == nil then
                game_util:addMoveTips({text = string_helper.game_neutral_land_pop.dataError})
                return
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("public_land_data",json.decode(data:getFormatBuffer()))
                game_data:setDataByKeyAndValue("public_land_data_time",os.time())
                if self.m_callBackFunc then
                    self.m_callBackFunc()
                end
                self:back()
            end
            -- map_id=3
            local params = {}
            params.map_id = self.m_map_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_cancel_sow_seed"), http_request_method.GET, params,"public_land_cancel_sow_seed")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_game_neutral_land_pop.ccbi")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_gain_label = ccbNode:labelTTFForName("m_gain_label")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_worker_icon_node = ccbNode:nodeForName("m_worker_icon_node")
    self.m_work_detail_label = ccbNode:labelTTFForName("m_work_detail_label")
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
    刷新
]]
function game_neutral_land_pop.refreshSelectSeed(self,key)
    local seed_cfg = getConfig(game_config_field.seed)
    local itemCfg = seed_cfg:getNodeWithKey(tostring(key))
    if itemCfg then
        self.m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr())
        -- self.m_time_label:setString(game_util:formatTime(itemCfg:getNodeWithKey("time"):toInt()))
        -- local tempStr = ""
        -- local reward = itemCfg:getNodeWithKey("reward")
        -- local tempCount = reward:getNodeCount()
        -- for i=1,tempCount do
        --     local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),true)
        --     if i == tempCount then
        --         tempStr = tempStr .. name
        --     else
        --         tempStr = tempStr .. name .. "\n"
        --     end
        -- end
        -- self.m_gain_label:setString(tempStr)
    end
end

--[[--
    刷新ui
]]
function game_neutral_land_pop.refreshUi(self)
    self.m_worker_icon_node:removeAllChildrenWithCleanup(true)
    local gameData = game_data:getDataByKey("public_land_data") or {}
    local refresh_worker_times = gameData.refresh_worker_times or 0
    local worker_cfg = getConfig(game_config_field.worker)
    local map = gameData.map or {}
    local itemData = map[tostring(self.m_map_id)]
    if itemData then
        self:refreshSelectSeed(itemData.seed_id)
        local tempStr = ""
        local reward = itemData.reward or {}
        local tempCount = #reward
        for i=1,tempCount do
            local icon,name,count = game_util:getRewardByItemTable(reward[i],true)
            if i == tempCount then
                tempStr = tempStr .. name
            else
                tempStr = tempStr .. name .. "\n"
            end
        end
        self.m_gain_label:setString(tempStr)
        local worker_id = itemData.worker_id or 0
        local worker_cfg_item = worker_cfg:getNodeWithKey(tostring(worker_id))
        if worker_cfg_item then
            local quality = worker_cfg_item:getNodeWithKey("quality"):toInt()
            local icon = game_util:createIconByName(worker_cfg_item:getNodeWithKey("icon"):toStr(),quality)
            if icon then
                icon:setScale(0.8)
                self.m_worker_icon_node:addChild(icon)
            end
            self.m_work_detail_label:setString(worker_cfg_item:getNodeWithKey("name"):toStr())
        else
            self.m_work_detail_label:setString(string_helper.game_neutral_land_pop.none)
        end
        local plant_time = itemData.plant_time or 0
        local function timeEndFunc(label)
           label:removeFromParentAndCleanup(true)
           self.m_time_label:setString("00:00:00")
           self.m_ok_btn:setVisible(false)
        end
        local public_land_data_time = game_data:getDataByKey("public_land_data_time")
        plant_time = math.max(plant_time - (os.time() - public_land_data_time),0)
        if plant_time > 0 then
            self.m_time_label:setString("")
            local pX,pY = self.m_time_label:getPosition()
            local countdownLabel = game_util:createCountdownLabel(plant_time,timeEndFunc,8, 1);
            countdownLabel:setColor(ccc3(0, 255, 0))
            countdownLabel:setPosition(ccp(pX,pY))
            self.m_time_label:getParent():addChild(countdownLabel,10,10)
            self.m_ok_btn:setVisible(true)
        else
            self.m_time_label:setString("00:00:00")
            self.m_ok_btn:setVisible(false)
        end
    else
        self.m_work_detail_label:setString(string_helper.game_neutral_land_pop.cfgError)
        self.m_ok_btn:setVisible(false)
    end 
end
--[[--
    初始化
]]
function game_neutral_land_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_map_id = t_params.map_id or ""
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_neutral_land_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_neutral_land_pop;