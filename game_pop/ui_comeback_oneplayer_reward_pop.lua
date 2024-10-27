---  王者归来 一个玩家的就爱那个李
cclog2 = cclog2 or function() end
local ui_comeback_oneplayer_reward_pop = {
    m_showData = nil,
    m_ccbNode = nil,
    m_uid = nil,
    m_callBack = nil,
};
--[[--
    销毁ui
]]
function ui_comeback_oneplayer_reward_pop.destroy(self)
    -- body
    cclog("----------------- ui_comeback_oneplayer_reward_pop destroy-----------------"); 
    self.m_showData = nil;
    self.m_ccbNode = nil;
    self.m_uid = nil;
    self.m_callBack = nil;
end
--[[--
    返回
]]
function ui_comeback_oneplayer_reward_pop.back(self,backType)
    game_scene:removePopByName("ui_comeback_oneplayer_reward_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_comeback_oneplayer_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            if type(self.m_callBack) == "function" then
                self.m_callBack( function ()  self:back()  end)
            end
        elseif btnTag == 401 then  -- 领取首日奖励
            local function responseMethod(tag,gameData)
                self:refreshData(gameData)
                self:refreshUi()
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("gift"));
            end
            local params = {}
            params.sort = 1
            params.tid = self.m_uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_reward_single"), http_request_method.GET, params,"king_get_reward_single")
        elseif btnTag == 402 then
            local function responseMethod(tag,gameData)
                self:refreshData(gameData)
                self:refreshUi()
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("gift"));
            end
            local params = {}
            params.sort = 2
            params.tid = self.m_uid
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_reward_single"), http_request_method.GET, params,"king_get_reward_single")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_comeback_payreward_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    -- 重置按钮出米优先级 防止被阻止
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    self.m_ccbNode = ccbNode
    return ccbNode;
end



--[[--
    刷新ui
]]
function ui_comeback_oneplayer_reward_pop.refreshUi(self)
    local show_name = self.m_gameData.t_name or ""
    local m_label_name = self.m_ccbNode:labelTTFForName("m_label_name")
    m_label_name:setString(tostring(show_name))

    local showData ={}
    showData[1] = {fb_score = self.m_gameData.fb_score, fb_record = self.m_gameData.fb_record, fb_limit = self.m_gameData.fb_limit, avail_fb_reward = self.m_gameData.avail_fb_reward,}
    showData[2] = {fb_score = self.m_gameData.normal_score, fb_record = self.m_gameData.normal_record, fb_limit = self.m_gameData.normal_limit, avail_fb_reward = self.m_gameData.avail_normal_reward,}

    -- local recall_charge_reward_cfg = getConfig(game_config_field.recall_charge_reward)
    local msgs = string_helper.ui_comeback_oneplayer_reward_pop.msgs
    for i=1, 2 do
        local m_label_rewardtitle = self.m_ccbNode:labelTTFForName("m_label_rewardtitle" .. i)
        local m_label_pay = self.m_ccbNode:labelTTFForName("m_label_pay" .. i)
        local m_label_get = self.m_ccbNode:labelTTFForName("m_label_get" .. i)
        local m_label_getmax = self.m_ccbNode:labelTTFForName("m_label_getmax" .. i)
        local m_label_diaNUM = self.m_ccbNode:labelTTFForName("m_label_diaNUM" .. i)
        local m_btn_getreward = self.m_ccbNode:controlButtonForName("m_btn_getreward" .. i)
        m_btn_getreward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
        local itemData = showData[i]

        m_label_pay:setString(string.format(string_helper.ui_comeback_oneplayer_reward_pop.charge,tostring(itemData.fb_score)))
        m_label_get:setString(string.format(string_helper.ui_comeback_oneplayer_reward_pop.charge,tostring(itemData.fb_record)))
        m_label_getmax:setString(msgs[i] .. tostring(itemData.fb_limit))
        m_label_diaNUM:setString(tostring(itemData.avail_fb_reward))

        if itemData.avail_fb_reward > 0 then
            game_util:setCCControlButtonBackground(m_btn_getreward, "ui_comeback_getreward1.png")
        else
            game_util:setCCControlButtonBackground(m_btn_getreward, "ui_comeback_getreward2.png")
        end
    end
end

--[[
    刷新数据
]]
function ui_comeback_oneplayer_reward_pop.refreshData( self, gameData )
    local data = gameData and gameData:getNodeWithKey("data")
    local tempData = data and json.decode(data:getFormatBuffer()) or {}
    for k,v in pairs(tempData) do
        if self.m_gameData[k] then
            self.m_gameData[k] = tempData[k]
        end
    end
end

--[[--
    初始化
]]
function ui_comeback_oneplayer_reward_pop.init(self,t_params)
    t_params = t_params or {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self.m_uid = t_params.uid
    self.m_callBack = t_params.callBack
end
--[[--
    创建ui入口并初始化数据
]]
function ui_comeback_oneplayer_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_comeback_oneplayer_reward_pop;
