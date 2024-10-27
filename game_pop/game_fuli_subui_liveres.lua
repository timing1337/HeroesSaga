---  生存物资

local game_fuli_subui_liveres = {
    m_label_title = nil,
    m_label_temp_msg1 = nil,
    m_label_temp_msg2 = nil,
    m_node_showmsg_board = nil,
    m_node_rewardicon = nil,
    m_label_rewardtip = nil,
    m_node_showdes = nil,
    m_gameData = nil,
    m_conbtn_getres = nil,
}

--[[--
    销毁ui
]]
function game_fuli_subui_liveres.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_liveres destroy-----------------"); 
    self.m_label_title = nil;
    self.m_label_temp_msg1 = nil;
    self.m_label_temp_msg2 = nil;
    self.m_node_showmsg_board = nil;
    self.m_node_rewardicon = nil;
    self.m_label_rewardtip = nil;
    self.m_node_showdes = nil;
    self.m_gameData = nil;
    self.m_conbtn_getres = nil;
end
--[[--
    返回
]]
function game_fuli_subui_liveres.back(self,backType)
        self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_liveres.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press button tag is ", btnTag)
        if btnTag == 2 then --  领取物资
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog("reward_gift_award data=="..data:getFormatBuffer())
                local reward = data:getNodeWithKey("reward");
                game_util:rewardTipsByJsonData(reward);


                self.reward_flag = 0
                self:refreshUi()

                self.m_conbtn_getres:setEnabled(false)
                title = CCString:create(tostring(string_helper.game_fuli_subui_liveres.get));
                self.m_conbtn_getres:setTitleForState(title,CCControlStateDisabled)
                self.m_conbtn_getres:setTitleColorForState(ccc3(192,192,192),CCControlStateDisabled)

            end
            local params = {}
            params.award_id = self.m_reward_id
            -- cclog("self.m_reward_id == " .. self.m_reward_id)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_gift_award"),
             http_request_method.GET, params,"reward_gift_award")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_content_liveres.ccbi");

    self.m_label_title = ccbNode:labelTTFForName("m_label_title")
    self.m_label_temp_msg1 = ccbNode:labelTTFForName("m_label_temp_msg1")
    self.m_label_temp_msg2 = ccbNode:labelTTFForName("m_label_temp_msg2")
    self.m_node_showdes = ccbNode:nodeForName("m_node_showdes")
    self.m_node_rewardicon = ccbNode:nodeForName("m_node_rewardicon")
    self.m_label_rewardtip = ccbNode:labelTTFForName("m_label_rewardtip")
    self.m_node_liveres = ccbNode:nodeForName("m_node_liveres")

    self.m_conbtn_getres = ccbNode:controlButtonForName("m_conbtn_getres");
    self.m_conbtn_getres:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16)

    self.m_label_title:setString(string_helper.ccb.text178)
    self.m_label_rewardtip:setString(string_helper.ccb.text179)
    game_util:setCCControlButtonTitle(self.m_conbtn_getres,string_helper.ccb.text180)
    return ccbNode
end

--[[--
    刷新ui
]]
function game_fuli_subui_liveres.refreshUi(self)

    local activeCfg = getConfig( game_config_field.active_cfg )
    local active_liveres = activeCfg:getNodeWithKey("10")
    local des = active_liveres:getNodeWithKey("des") and active_liveres:getNodeWithKey("des"):toStr() or ""

    local itemSize = CCSizeMake(self.m_node_showdes:getContentSize().width , 0)
    local richLabel = game_util:createRichLabelTTF({text = des,dimensions = itemSize,
        textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentTop,
        color = ccc3(221,221,192),fontSize = 12})
    richLabel:setAnchorPoint(ccp(0, 0))
    richLabel:setPosition( ccp( 0, itemSize.height ) )
    self.m_node_showdes:addChild(richLabel)

    local res = {13,0,50}
    local icon,name,count = game_util:getRewardByItemTable(res);
    if icon then
        icon:setAnchorPoint(ccp(0.5, 0.5))
        icon:setPosition( self.m_node_liveres:getContentSize().width * 0.5, self.m_node_liveres:getContentSize().height * 0.5 )
        self.m_node_liveres:addChild(icon, -1, 20)
        icon:removeAllChildrenWithCleanup(true)
        icon:setScale(0.6)

        local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
        board:setPosition( self.m_node_liveres:getContentSize().width * 0.5, self.m_node_liveres:getContentSize().height * 0.5 )
        self.m_node_liveres:addChild(board, -2, 110)
        board:setScale(0.7)

        if name and count then
            local labelName = game_util:createLabelTTF({text = name .. "x" .. count, fontSize = 16, color = ccc3(0, 255, 0)})
            labelName:setAnchorPoint(ccp(0, 0.5))
            labelName:setPosition(icon:getContentSize().width * 1.5,  icon:getContentSize().height * 0.5 )
            icon:addChild(labelName, 10)
        end
    end

        local data = self.m_gameData:getNodeWithKey("data")
        -- cclog("activity data=="..data:getFormatBuffer())
        self.live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
        -- cclog("gift_reward == " .. data:getNodeWithKey("gift_reward"):getFormatBuffer())
        local restTime = -1;
        if data:getNodeWithKey("gift_reward"):getNodeCount() > 0 then
            local gift_reward = data:getNodeWithKey("gift_reward"):getNodeAt(0);--key 是奖励id  vaLue  是时间
            self.m_reward_id = gift_reward:getKey();
            restTime = gift_reward:toInt();
            -- cclog("restTime == " .. restTime)
        end
        
        local function timeOverCallFun()
            self.m_conbtn_getres:setEnabled(true)
        end
        if restTime == 0 then
            local timeLabel = game_util:createCountdownLabel(restTime,timeOverCallFun)
            timeLabel:setAnchorPoint(ccp(0.5,0.5))
            timeLabel:setPosition(ccp(100,100))
            timeLabel:setVisible(false)
            self.m_conbtn_getres:setEnabled(false)
            self.reward_flag = 0
        elseif restTime > 0 then
            self.m_conbtn_getres:setEnabled(true)
            self.m_conbtn_getres:setColor(ccc3(255,255,255))
            self.reward_flag = 1
        elseif restTime == -1 then
            self.m_conbtn_getres:setEnabled(false)
            self.reward_flag = 0
            self.m_conbtn_getres:setColor(ccc3(192,192,192))
        end
        -- cclog("self.m_access_flag 1 = " .. json.encode(self.m_access_flag))
end

--[[--
    初始化
]]
function game_fuli_subui_liveres.init(self,t_params)
    t_params = t_params or {}
    local gameData = t_params.gameData
    -- cclog2(gameData, "gameData ==== ")
    local data = gameData:getNodeWithKey("data")
    -- cclog("activity data=="..data:getFormatBuffer())

    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = util_json:new(t_params.gameData:getFormatBuffer());--json.decode(t_params.gameData:getFormatBuffer()) or {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_liveres.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_fuli_subui_liveres