---  基金

local fund_main_server_scene = {
    m_tGameData = nil,
    m_ccbNode = nil,
    m_left_time_node = nil,
    m_screenShoot = nil,
    m_showIdTab = nil,
    m_select_spr = nil,
    m_bar_node = nil,
    m_cost_bar = nil,
    m_max_coin_value = nil,
    m_selFundTab = nil,
};

--[[--
    销毁ui
]]
function fund_main_server_scene.destroy(self)
    -- body
    cclog("-----------------fund_main_server_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.m_left_time_node = nil;
    self.m_screenShoot = nil;
    self.m_showIdTab = nil;
    self.m_select_spr = nil;
    self.m_bar_node = nil;
    self.m_cost_bar = nil;
    self.m_max_coin_value = nil;
    self.m_selFundTab = nil;
end
--[[--
    返回
]]
function fund_main_server_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function fund_main_server_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--详情
            game_scene:addPop("fund_explain_server_pop")
        elseif btnTag == 102 then--激活
            local foundation_cfg = getConfig(game_config_field.server_foundation)
            local costCoin = 0;
            local selItemCount = 0;
            local params = "";
            for k,v in pairs(self.m_selFundTab) do
                if self.m_showIdTab[k] then
                    local itemCfg = foundation_cfg:getNodeWithKey(self.m_showIdTab[k])
                    local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt();
                    costCoin = costCoin + need_coin;
                    selItemCount = selItemCount + 1;
                    params = params .. "id=" .. self.m_showIdTab[k] .. "&"
                end
            end
            if selItemCount == 0 then
                game_util:addMoveTips({text = string_helper.fund_main_server_scene.text})
                return;
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local screenShoot = game_util:createScreenShoot();
                    screenShoot:retain();
                    function responseMethod(tag,gameData)
                        if gameData then
                            game_util:closeAlertView();
                            game_scene:enterGameUi("fund_activation_server_scene",{gameData = gameData,screenShoot = screenShoot})
                        end
                        screenShoot:release();
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_foundation_activate"), http_request_method.GET, params,"server_foundation_activate",true,true)
                    -- local screenShoot = game_util:createScreenShoot();
                    -- game_scene:enterGameUi("fund_activation_scene",{gameData = nil, screenShoot = screenShoot})
                    -- game_util:closeAlertView();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_helper.fund_main_server_scene.okBtnText,       --可缺省
                text = string_helper.fund_main_server_scene.text2 .. costCoin .. string_helper.fund_main_server_scene.text3,      --可缺省
                onlyOneBtn = false,
            }
            game_util:openAlertView(t_params);

        elseif btnTag >= 11 and btnTag <= 13 then--基金
            local tempTag = btnTag - 10;
            local m_sel_bg = self.m_ccbNode:scale9SpriteForName("m_sel_bg_" .. tempTag)
            local m_mask_layer = self.m_ccbNode:layerColorForName("m_mask_layer_" .. tempTag)
            if m_sel_bg:isVisible() then
                m_sel_bg:setVisible(false);
                m_mask_layer:setVisible(true);
                if self.m_showIdTab[tempTag] then
                    self.m_selFundTab[tempTag] = nil;
                end
            else
                m_sel_bg:setVisible(true);
                m_mask_layer:setVisible(false);
                if self.m_showIdTab[tempTag] then
                    self.m_selFundTab[tempTag] = 1;
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_fund_main.ccbi");
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
    self.m_bar_node = ccbNode:nodeForName("m_bar_node")

    local bar = ExtProgressTime:createWithFrameName("fund_jindutiao1.png","fund_jindutiao2.png");
    bar:setScaleX(1.35)
    bar:setScaleY(0.75)
    bar:setCurValue(0,false);
    self.m_bar_node:addChild(bar);
    self.m_cost_bar = bar;

    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end
    return ccbNode;
end


--[[
    倒计时
]]
function fund_main_server_scene.setCountdownTime(self)
    local countdownTime = self.m_tGameData.active_remain_time or 0
    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.m_left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.fund_main_server_scene.text4,color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(tipsLabel,10,12)
    end
    
    if countdownTime > 0 then
        local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(countdownLabel,10,10)
    else
        timeEndFunc();
    end
end

function fund_main_server_scene.refreshFund(self)
    local foundation_cfg = getConfig(game_config_field.server_foundation)
    local tempSize = self.m_bar_node:getContentSize();
    for i=1,#self.m_showIdTab do
        local itemCfg = foundation_cfg:getNodeWithKey(self.m_showIdTab[i])
        local m_fund_reward_node = self.m_ccbNode:nodeForName("m_fund_reward_node_" .. i)
        local m_cursor_img = self.m_ccbNode:spriteForName("m_cursor_img_" .. (i+1))
        local m_coin_icon = self.m_ccbNode:spriteForName("m_coin_icon_" .. (i+1))
        local m_coin_label = self.m_ccbNode:labelTTFForName("m_coin_label_" .. (i+1))
        local reward_show = itemCfg:getNodeWithKey("reward_show")
        if reward_show:getNodeCount() > 0 then
            local icon,name,count = game_util:getRewardByItem(reward_show:getNodeAt(0))
            if icon and m_fund_reward_node then
                icon:setScale(0.75)
                m_fund_reward_node:addChild(icon)
            end
            -- if count then
            --     local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(0,255,0),fontSize = 12});
            --     tempLabel:setPosition(ccp(10,-10));
            --     m_fund_reward_node:addChild(tempLabel);
            -- end
        end
        local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt();
        local pX = tempSize.width*need_coin/self.m_max_coin_value
        if m_cursor_img then
            m_cursor_img:setPositionX(pX)
        end
        if m_coin_icon then
            m_coin_icon:setPositionX(pX)
        end
        if m_coin_label then
            m_coin_label:setPositionX(pX)
            m_coin_label:setString(need_coin)
        end
    end
end

--[[--
    刷新ui
]]
function fund_main_server_scene.refreshUi(self)
    self:setCountdownTime();
    self:refreshFund();
    local foundation_score = self.m_tGameData.foundation_score
    self.m_cost_bar:setCurValue(math.min(100*foundation_score/self.m_max_coin_value,100),false);
end

--[[--
    初始化
]]
function fund_main_server_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_max_coin_value = 100;
    self.m_screenShoot = t_params.screenShoot;
    self.m_showIdTab = {}
    local foundation_cfg = getConfig(game_config_field.server_foundation)
    local tempCount = foundation_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = foundation_cfg:getNodeAt(i - 1)
        table.insert(self.m_showIdTab,itemCfg:getKey())
        local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt();
        if need_coin > self.m_max_coin_value then
            self.m_max_coin_value = need_coin;
        end
    end
    table.sort(self.m_showIdTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    self.m_selFundTab = {};
end


--[[--
    创建ui入口并初始化数据
]]
function fund_main_server_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return fund_main_server_scene;