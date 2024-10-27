---  月卡奖励

local game_fuli_subi_monthvip_pop = {

    m_gameData = nil,

    m_monthData = nil,
    m_gameData = nil,
    m_root_ccbNode = nil,
    m_isMonthVIP = nil,
    m_conbtn_buy = nil,
    m_sprite_alredygot = nil,
}

--[[--
    销毁ui
]]
function game_fuli_subi_monthvip_pop.destroy(self)
    -- body
    cclog("----------------- game_fuli_subi_monthvip_pop destroy-----------------"); 

    self.m_gameData = nil;
    self.m_monthData = nil;
    self.m_gameData = nil;
    self.m_root_ccbNode = nil;
    self.m_isMonthVIP = nil;
    self.m_conbtn_buy = nil;
    self.m_sprite_alredygot = nil;
end
--[[--
    返回
]]
function game_fuli_subi_monthvip_pop.back(self,backType)
        self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subi_monthvip_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_fuli_content_monthvip_board.ccbi");
    self.m_root_ccbNode = ccbNode
    return ccbNode
end

function game_fuli_subi_monthvip_pop.createHalfImage( self, heroid, isflipX  )
    isflipX = isflipX or false
    heroid = heroid or 4660
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(heroid));
    local animation = wuKongCfg:getNodeWithKey("animation"):toStr();
    local rgb = wuKongCfg:getNodeWithKey("rgb_sort"):toInt();
    local tempIcon = game_util:createImgByName("image_" .. animation,rgb, true, isflipX)
    tempIcon:setScale(1.5)
    return tempIcon
end

function game_fuli_subi_monthvip_pop.showRewardOnNode( self, node, rewardData, day)
    rewardData = rewardData or {}
    function onBtnCilck( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local day = btnTag/100
        local index = btnTag%100
        game_util:lookItemDetal( rewardData[index] )
    end

    if #rewardData == 0 then return end
    local posx = {  {0.5}, {0.33, 0.66}, {0.25, 0.5, 0.75}, {0.2, 0.4, 0.6, 0.8} }
    local curPosx = posx[#rewardData]
    local size = node:getContentSize()
    for i=1, #rewardData do
        local rewardItem = rewardData[i]
        if rewardItem then
        local icon,name,count = game_util:getRewardByItemTable(rewardItem);
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition( size.width * curPosx[i], size.height * 0.6 )
                icon:setScale(0.8)
                node:addChild(icon, -1, 20)

                if name and count then
                    local labelName = game_util:createLabelBMFont({text = name .. "x" .. count, fontSize = 16, color = ccc3(255, 255, 255)})
                    labelName:setAnchorPoint(ccp(0.5, 1))
                    labelName:setPosition(icon:getContentSize().width * 0.5,  -4 )
                    icon:addChild(labelName, 10)
                end

                local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5 )
                button:setOpacity(0)
                icon:addChild(button)
                button:setTag(day*100 + i)
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_fuli_subi_monthvip_pop.refreshUi(self)

    self.m_root_ccbNode:removeChildByTag( 987 , true)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        if btnTag == 101 then -- 月卡商城
            function shopOpenResponseMethod(tag,gameData)
                -- cclog2(self.m_isMonthVIP, "self.m_isMonthVIP    ===    ")
                game_scene:addPop("game_monthvip_shop_pop",{gameData = gameData, isMonthVIP = self.m_isMonthVIP});
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("card_shop_open"), http_request_method.GET, {},"card_shop_open")
        elseif btnTag == 102 then -- 购买
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 201 then -- 领取奖励
            local function responseMethod(tag,gameData)
                local data = gameData and gameData:getNodeWithKey("data")
                if data then
                    self.m_gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
                end
                self:refreshUi()
                game_util:rewardTipsByDataTable( self.m_gameData.reward or {} );
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("get_award"), http_request_method.GET, {tp="month"},"get_award")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);

    local montReward = self.m_gameData.month_award.reward
    local count = game_util:getTableLen(montReward) or 20
    local monthData = self.m_gameData.month_award or {}
    local showDays = monthData.days or 0

    if monthData.pay_dt == "" or ( showDays >= count )  then
        ccbNode:openCCBFile("ccb/ui_fuli_content_monthvip.ccbi");
        local m_conbtn_shop = ccbNode:controlButtonForName("m_conbtn_shop")
        local m_conbtn_buy = ccbNode:controlButtonForName("m_conbtn_buy")
        m_conbtn_shop:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        m_conbtn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY)

        local m_conbtn_shop2 = ccbNode:controlButtonForName("m_conbtn_shop2")
        m_conbtn_shop2:setTouchPriority(GLOBAL_TOUCH_PRIORITY)

        local m_node_left_heroimage = ccbNode:nodeForName("m_node_left_heroimage")
        local m_node_right_heroimage = ccbNode:nodeForName("m_node_right_heroimage")

        -- 展示界面两侧的半身像
        local imageLeft = self:createHalfImage( 1 )
        imageLeft:setAnchorPoint(ccp( 0.5, 0))
        imageLeft:setPositionX( m_node_left_heroimage:getContentSize().width * 0.5 )
        m_node_left_heroimage:addChild(imageLeft, -1 )
        local imageRight = self:createHalfImage( 8 , true)
        imageRight:setAnchorPoint(ccp( 0.5, 0))
        imageRight:setPositionX( m_node_right_heroimage:getContentSize().width * 0.5 )
        m_node_right_heroimage:addChild(imageRight, -1 )

        local m_node_showfirstboard = ccbNode:nodeForName("m_node_showfirstboard")
        self:showRewardOnNode(m_node_showfirstboard, self.m_monthData["1"].award, 1)

        local m_show_nextreward_board = ccbNode:nodeForName("m_show_nextreward_board")
        self:showRewardOnNode(m_show_nextreward_board, self.m_monthData["2"].award, 2)
    elseif monthData.pay_dt ~= "" then
        ccbNode:openCCBFile("ccb/ui_fuli_content_monthvip_get.ccbi");
        local m_conbtn_shop = ccbNode:controlButtonForName("m_conbtn_shop")
        local m_conbtn_buy = ccbNode:controlButtonForName("m_conbtn_buy")
        m_conbtn_shop:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        m_conbtn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY)
        local m_sprite_alredygot = ccbNode:nodeForName("m_sprite_alredygot")

        local m_conbtn_shop2 = ccbNode:controlButtonForName("m_conbtn_shop2")
        m_conbtn_shop2:setTouchPriority(GLOBAL_TOUCH_PRIORITY)

        local showDays = monthData.days or 0
        -- cclog2(showDays,  "showDays   ====   ")
        local server_time = game_data:getUserStatusDataByKey("server_time")
        local serstr = os.date("%Y-%m-%d", server_time) or ""
        -- if monthData.award_day == serstr then  -- 已领取
        --     m_conbtn_buy:setVisible(false)
        --     m_sprite_alredygot:setVisible(true)
        -- else
        --     m_conbtn_buy:setVisible(true)
        --     m_sprite_alredygot:setVisible(false)
        --     showDays = showDays + 1
        -- end
        --加一个月卡判断逻辑
        if self.m_gameData.month_avail == true then--可领取
            m_conbtn_buy:setVisible(true)
            m_sprite_alredygot:setVisible(false)
            showDays = showDays + 1
        else
            m_conbtn_buy:setVisible(false)
            m_sprite_alredygot:setVisible(true)
        end

         -- 展示界面两侧的半身像
        local m_node_left_heroimage = ccbNode:nodeForName("m_node_left_heroimage")
        local imageLeft = self:createHalfImage( 1 )
        imageLeft:setAnchorPoint(ccp( 0.5, 0))
        imageLeft:setPositionX( m_node_left_heroimage:getContentSize().width * 0.5 )
        m_node_left_heroimage:addChild(imageLeft, -1 )

        self.m_blabel_alreadyday = ccbNode:labelBMFontForName("m_blabel_alreadyday")
        local dayLabel = monthData.days
        if dayLabel > count then
            dayLabel = count
        end
        self.m_blabel_alreadyday:setString(tostring(dayLabel))
        self.m_blabel_lastday = ccbNode:labelBMFontForName("m_blabel_lastday")
        local already = count - (monthData.days or count)
        if already < 0 then
            already = 0
        end
        self.m_blabel_lastday:setString(tostring(already))

        local m_node_showfirstboard = ccbNode:nodeForName("m_node_showfirstboard")
        showDays = math.min(showDays, count)
        self:showRewardOnNode(m_node_showfirstboard, self.m_monthData[ tostring(math.max(showDays, 1)) ].award, tostring(monthData.days))
    end
    self.m_root_ccbNode:addChild(ccbNode, 10, 987)
    -- local activeCfg = getConfig( game_config_field.active_cfg )
    -- local icon,name,count = game_util:getRewardByItemTable(res);
    -- if icon then
    --     icon:setAnchorPoint(ccp(0.5, 0.5))
    --     icon:setPosition( self.m_node_liveres:getContentSize().width * 0.5, self.m_node_liveres:getContentSize().height * 0.5 )
    --     self.m_node_liveres:addChild(icon, -1, 20)
    --     icon:removeAllChildrenWithCleanup(true)
    --     icon:setScale(0.6)

    --     local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
    --     board:setPosition( self.m_node_liveres:getContentSize().width * 0.5, self.m_node_liveres:getContentSize().height * 0.5 )
    --     self.m_node_liveres:addChild(board, -2, 110)
    --     board:setScale(0.7)

    --     if name and count then
    --         local labelName = game_util:createLabelTTF({text = name .. "x" .. count, fontSize = 16, color = ccc3(0, 255, 0)})
    --         labelName:setAnchorPoint(ccp(0, 0.5))
    --         labelName:setPosition(icon:getContentSize().width * 1.5,  icon:getContentSize().height * 0.5 )
    --         icon:addChild(labelName, 10)
    --     end
    -- end

        -- cclog("self.m_access_flag 1 = " .. json.encode(self.m_access_flag))
end

--[[--
    初始化
]]
function game_fuli_subi_monthvip_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" and t_params.gameData:getNodeWithKey("data") then
        self.m_gameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
    end
    local monthCfg = getConfig(game_config_field.month_award)
    self.m_monthData = json.decode(monthCfg and monthCfg:getFormatBuffer()) or {}
    local monthDays = game_util:getTableLen( self.m_monthData )
    local monthData = self.m_gameData.month_award or {}
    if monthData.pay_dt ~= "" then
        self.m_isMonthVIP = true
    else
        self.m_isMonthVIP = false
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subi_monthvip_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_fuli_subi_monthvip_pop