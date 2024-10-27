---  每日登陆奖励
local game_daily_sign = {
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_receive_bg = nil,
    m_daily_node = nil,
    coin_status = nil,
    coin_days = nil,
    m_tab_node_1 = nil,
    m_tab_node_2 = nil,
    m_show_tpye = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_change_type = nil,

    m_table_view_1 = nil,
    m_table_view_2 = nil,
    next_tips = nil,
    daily_award_loop = nil,
};

--[[--
    销毁
]]
function game_daily_sign.destroy(self)
    -- body
    cclog("-----------------game_daily_sign destroy-----------------");
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_daily_node = nil;
    self.coin_status = nil;
    self.coin_days = nil;
    self.m_tab_node_1 = nil;
    self.m_tab_node_2 = nil;
    self.m_show_tpye = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_change_type = nil;
    self.m_table_view_1 = nil;
    self.m_table_view_2 = nil;
    self.next_tips = nil;
    self.daily_award_loop = nil;
end
--[[--
    返回
]]
function game_daily_sign.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_daily_sign.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 3 then--切换到每日签到
            self.m_change_type = true
            self.m_show_tpye = 1 
            self:refreshBtn()
        elseif btnTag == 4 then--切换到充值签到
            self.m_change_type = true
            self.m_show_tpye = 2
            self:refreshBtn()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event

    ccbNode:openCCBFile("ccb/ui_daily_sigh.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_daily_node = ccbNode:nodeForName("m_daily_node")
    self.m_receive_bg = ccbNode:nodeForName("m_receive_bg")
    self.m_tab_node_1 = ccbNode:nodeForName("m_tab_node_1")
    self.m_tab_node_2 = ccbNode:nodeForName("m_tab_node_2")
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3")

    game_util:setCCControlButtonTitle(self.m_tab_btn_2,string_helper.ccb.text114)
    game_util:setCCControlButtonTitle(self.m_tab_btn_3,string_helper.ccb.text115)

    self.m_daily_node2 = ccbNode:nodeForName("m_daily_node2")
    self.m_receive_bg2 = ccbNode:nodeForName("m_receive_bg2")
    self.next_tips = ccbNode:labelTTFForName("next_tips")
    self:refreshBtn()

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text113)
    return ccbNode;
end
--[[
    按钮刷新
]]
function game_daily_sign.refreshBtn(self)
    local function changeTab(node1,node2,table1,table2)
        local anim_time = 0.5
        local animArr = CCArray:create();
        local function hideFunc()
            table1:setVisible(false)
            node1:setVisible(false)
            table2:setVisible(true)
            node2:setVisible(true)
            -- node2:setScaleX(-1)
            -- local animArr2 = CCArray:create();
            -- animArr2:addObject(CCScaleTo:create(1,1,1));
            -- node2:runAction(CCSequence:create(animArr2))
        end
        local orbit = CCOrbitCamera:create(anim_time/2, 1, 0, 0, 0, 180, 0)
        animArr:addObject(orbit);
        animArr:addObject(CCCallFuncN:create(hideFunc));
        node1:runAction(CCSequence:create(animArr))

        local animArr2 = CCArray:create();
        animArr2:addObject(CCOrbitCamera:create(anim_time, 1, 0, 0, 0, 360, 0));
        node2:runAction(CCSequence:create(animArr2))
    end
    local function changeTab2(node1,node2,table1,table2)
        local endPos = ccp(240,452)
        local startPos = ccp(240,144)
        fade_time = 0.5
        local function hideFunc()
            table1:setVisible(false)
            node1:setVisible(false)
            node1:setPosition(startPos)
            table2:setVisible(true)
            node2:setVisible(true)
        end
        local animArr = CCArray:create();
        animArr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(fade_time),CCMoveTo:create(fade_time,endPos)))
        animArr:addObject(CCCallFuncN:create(hideFunc));
        node1:runAction(CCSequence:create(animArr))

        -- node2:setPosition(endPos)
        local animArr2 = CCArray:create();
        animArr2:addObject(CCDelayTime:create(fade_time));
        animArr2:addObject(CCFadeIn:create(fade_time));
        -- animArr2:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(fade_time),CCMoveTo:create(fade_time,startPos)))
        node2:runAction(CCSequence:create(animArr2))
    end
    self:refreshUi()
    local btn1_flag = true
    local btn2_flag = true
    if self.m_show_tpye == 1 then
        btn1_flag = true
        btn2_flag = false
    else
        btn1_flag = false
        btn2_flag = true
    end
    self.m_tab_btn_2:setHighlighted(btn1_flag);
    self.m_tab_btn_2:setEnabled(not btn1_flag);
    self.m_tab_btn_3:setHighlighted(btn2_flag);
    self.m_tab_btn_3:setEnabled(not btn2_flag);
    if self.m_change_type == true then
        if btn1_flag then
            changeTab2(self.m_tab_node_2,self.m_tab_node_1,self.m_table_view_2,self.m_table_view_1)
        else
            changeTab2(self.m_tab_node_1,self.m_tab_node_2,self.m_table_view_1,self.m_table_view_2)
        end
    else
        self.m_tab_node_1:setVisible(btn1_flag)
        self.m_tab_node_2:setVisible(btn2_flag)
    end
end

--[[--

]]
function game_daily_sign.refreshTab1(self)
    local tableViewTemp = self:createDateTableView(self.m_daily_node:getContentSize());
    tableViewTemp:setMoveFlag(false);
    tableViewTemp:setScrollBarVisible(false);
    self.m_daily_node:removeAllChildrenWithCleanup(true);
    self.m_daily_node:addChild(tableViewTemp);

    self.m_table_view_1 = self:createRewardTableView(self.m_receive_bg:getContentSize());
    self.m_table_view_1:setScrollBarVisible(false);
    self.m_receive_bg:removeAllChildrenWithCleanup(true);
    self.m_receive_bg:addChild(self.m_table_view_1,10,10)

    local tGameData = game_data:getDailyAwardData();
    local reward = tGameData.reward;
    local score = tGameData.score;
    local date = score
    local daily_award_cfg = nil
    if self.daily_award_loop == true then
        daily_award_cfg = getConfig(game_config_field.daily_award_loop)
        cclog("11111111111111")
    else
        daily_award_cfg = getConfig(game_config_field.daily_award)
        cclog("222222222222222")
    end
    local cfgCount = daily_award_cfg:getNodeCount()
    if #reward > 0 then
        date = reward[1]
        cclog("date == " .. date)
    else
        if score > (cfgCount-3) then
            date = (cfgCount-3)
        end
    end
    game_util:setTableViewIndex(date-1,self.m_receive_bg,10,4)
end

--[[--
    创建日期列表
]]
function game_daily_sign.createDateTableView(self,viewSize)
    local daily_award_cfg = nil;
    if self.daily_award_loop == true then
        daily_award_cfg = getConfig(game_config_field.daily_award_loop)
    else
        daily_award_cfg = getConfig(game_config_field.daily_award)
    end
    local tGameData = game_data:getDailyAwardData();
    cclog("tGameData = " .. json.encode(tGameData))
    local score = tGameData.score;
    local reward = tGameData.reward;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 5; --列
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.itemActionFlag = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            if not game_util:valueInTeam(itemCfg:getKey(),reward) and (index+1) <= score then
                local public_right = CCSprite:createWithSpriteFrameName("signed.png")
                public_right:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                cell:addChild(public_right,20,20)
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then

        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建奖励列表
]]
function game_daily_sign.createRewardTableView(self,viewSize)
    local daily_award_cfg = nil
    if self.daily_award_loop == true then
        daily_award_cfg = getConfig(game_config_field.daily_award_loop)
        cclog("33333333333")
    else
        cclog("444444444444")
        daily_award_cfg = getConfig(game_config_field.daily_award)
    end
    local tGameData = game_data:getDailyAwardData();
    --设置推送信息
    cclog("tGameData == " .. json.encode(tGameData))
    local score = tGameData.score;
    local reward = tGameData.reward;
    if score == 1 and #reward == 0 then--设置变量
        local uid = game_data:getUserStatusDataByKey("uid")
        local rewardSign = CCUserDefault:sharedUserDefault():getStringForKey(uid .. "rewardSign");
        -- cclog(uid .. "rewardSign = " .. tostring(rewardSign))
        if rewardSign == nil or rewardSign == "" then
            -- cclog("yes")
            CCUserDefault:sharedUserDefault():setStringForKey(uid .. "rewardSign","first");
            CCUserDefault:sharedUserDefault():flush();
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.itemActionFlag = false;
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_daily_sigh_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local m_btn = ccbNode:controlButtonForName("m_btn")
            m_btn:setTouchEnabled(false);
            game_util:setControlButtonTitleBMFont(m_btn)
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local m_icon_spr = ccbNode:spriteForName("m_icon_spr");
                local m_top_label = ccbNode:labelBMFontForName("m_top_label")
                local m_btn = ccbNode:controlButtonForName("m_btn")
                local select_sprite = ccbNode:scale9SpriteForName("select_sprite")
                local btn_node = ccbNode:nodeForName("btn_node")
                local icon_node = ccbNode:nodeForName("icon_node")
                m_top_label:setString(string_helper.game_daily_sign.sign .. (index+1) .. string_helper.game_daily_sign.day)
                local award = itemCfg:getNodeWithKey("award")
                local awardCount = award:getNodeCount();
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelBMFontForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                    else
                        local icon,name = game_util:getRewardByItem(award:getNodeAt(i-1),true);
                        if icon~=nil then
                            icon:setScale(0.6)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end              
                end
                m_icon_spr:setOpacity(0)
                m_icon_spr:removeAllChildrenWithCleanup(true)
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                if icon then
                    local m_icon_spr_size = m_icon_spr:getContentSize();
                    icon:setPosition(ccp(m_icon_spr_size.width*0.5,m_icon_spr_size.height*0.5))
                    m_icon_spr:addChild(icon);
                end
                if (index+1) <= score then
                    if not game_util:valueInTeam(itemCfg:getKey(),reward) then
                        btn_node:setVisible(true)
                        icon_node:setVisible(false)
                        game_util:setCCControlButtonBackground(m_btn,"daily_alredy.png")
                        -- game_util:setCCControlButtonTitle(m_btn,"已领取")
                        select_sprite:setVisible(false)
                    else
                        btn_node:setVisible(true)
                        icon_node:setVisible(false)
                        -- game_util:setCCControlButtonTitle(m_btn,"签到")
                        game_util:setCCControlButtonBackground(m_btn,"daily_btn.png")
                        select_sprite:setVisible(true)
                    end
                else
                    btn_node:setVisible(false)
                    icon_node:setVisible(true)
                    select_sprite:setVisible(false)
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemCfg = daily_award_cfg:getNodeAt(index);
            if game_util:valueInTeam(itemCfg:getKey(),reward) then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    game_util:removeValueInTeam(itemCfg:getKey(),reward);
                    self:refreshUi();
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                end
                 --获得礼包  reward＝礼包id（可多个）
                local params = {};
                params.reward=itemCfg:getKey();
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_get_reward"), http_request_method.GET, params,"daily_award_get_reward")
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建奖励列表
]]
function game_daily_sign.createRewardTableView2(self,viewSize)
    local month_award_coin = getConfig(game_config_field.month_award_coin)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.itemActionFlag = false;
    params.totalItem = month_award_coin:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_daily_sigh_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local m_btn = ccbNode:controlButtonForName("m_btn")
            m_btn:setTouchEnabled(false);
            game_util:setControlButtonTitleBMFont(m_btn)
        end
        local itemCfg = month_award_coin:getNodeAt(index);
        if cell and itemCfg then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local m_icon_spr = ccbNode:spriteForName("m_icon_spr");
                local m_top_label = ccbNode:labelBMFontForName("m_top_label")
                local m_btn = ccbNode:controlButtonForName("m_btn")
                local select_sprite = ccbNode:scale9SpriteForName("select_sprite")
                local btn_node = ccbNode:nodeForName("btn_node")
                local icon_node = ccbNode:nodeForName("icon_node")
                m_top_label:setString(string_helper.game_daily_sign.sign .. (index+1) .. string_helper.game_daily_sign.day)

                local award = itemCfg:getNodeWithKey("award")
                local awardCount = award:getNodeCount();
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelBMFontForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                    else
                        local icon,name = game_util:getRewardByItem(award:getNodeAt(i-1),true);
                        if icon~=nil then
                            icon:setScale(0.6)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end                  
                end
                m_icon_spr:setOpacity(0)
                m_icon_spr:removeAllChildrenWithCleanup(true)
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                if icon then
                    local m_icon_spr_size = m_icon_spr:getContentSize();
                    icon:setPosition(ccp(m_icon_spr_size.width*0.5,m_icon_spr_size.height*0.5))
                    m_icon_spr:addChild(icon);
                end
                if (index) < self.coin_days then
                    btn_node:setVisible(true)
                    icon_node:setVisible(false)
                    -- game_util:setCCControlButtonTitle(m_btn,"已领取")
                    game_util:setCCControlButtonBackground(m_btn,"daily_alredy.png")
                    select_sprite:setVisible(false)
                elseif (index) == self.coin_days then
                    btn_node:setVisible(true)
                    icon_node:setVisible(false)
                    -- game_util:setCCControlButtonTitle(m_btn,"签到")
                    if self.coin_status == 1 then--可以领取
                        game_util:setCCControlButtonBackground(m_btn,"daily_btn.png")
                    elseif self.coin_status == 0 then --充值
                        game_util:setCCControlButtonBackground(m_btn,"daily_chongzhi.png")
                    elseif self.coin_status == 2 then --已领取
                        game_util:setCCControlButtonBackground(m_btn,"daily_alredy.png")
                    end
                    select_sprite:setVisible(true)
                else
                    btn_node:setVisible(false)
                    icon_node:setVisible(true)
                    select_sprite:setVisible(false)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and index == self.coin_days then
            if self.coin_status == 1 then
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    local coin_days = data:getNodeWithKey("coin_days"):toInt()
                    local coin_status = data:getNodeWithKey("coin_status"):toInt()
                    self.coin_days = coin_days
                    self.coin_status = coin_status
                    game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    self:refreshUi();
                end
                 --获得礼包
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_coin_award"), http_request_method.GET, nil,"daily_award_coin_award")
            elseif self.coin_status == 0 then
                -- game_util:addMoveTips({text = "不可领取"});
                --跳到充值
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("ui_vip",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    创建日期列表
]]
function game_daily_sign.createDateTableView2(self,viewSize)
    local month_award_coin = getConfig(game_config_field.month_award_coin)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 5; --列
    params.totalItem = month_award_coin:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.itemActionFlag = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        local itemCfg = month_award_coin:getNodeAt(index);
        if index < self.coin_days then
            local public_right = CCSprite:createWithSpriteFrameName("super_signed.png")
            public_right:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
            cell:addChild(public_right,20,20)
        elseif index == self.coin_days and self.coin_status == 2 then
            local public_right = CCSprite:createWithSpriteFrameName("super_signed.png")
            public_right:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
            cell:addChild(public_right,20,20)
        end

        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then

        end
    end
    return TableViewHelper:create(params);
end
--[[--

]]
function game_daily_sign.refreshTab2(self)
    local tableViewTemp = self:createDateTableView2(self.m_daily_node2:getContentSize());
    tableViewTemp:setMoveFlag(false);
    tableViewTemp:setScrollBarVisible(false);
    self.m_daily_node2:removeAllChildrenWithCleanup(true);
    self.m_daily_node2:addChild(tableViewTemp);

    self.m_table_view_2 = self:createRewardTableView2(self.m_receive_bg2:getContentSize());
    self.m_table_view_2:setScrollBarVisible(false);
    self.m_receive_bg2:removeAllChildrenWithCleanup(true);
    self.m_receive_bg2:addChild(self.m_table_view_2,10,10)

    local showIndex = self.coin_days
    local month_award_coin = getConfig(game_config_field.daily_award_loop)
    cclog2(month_award_coin,"month_award_coin")
    local cfgCount = month_award_coin:getNodeCount()
    if showIndex > (cfgCount-3) then
        showIndex = (cfgCount-3)
    end
    if showIndex < 1 then
        showIndex = 1
    end
    game_util:setTableViewIndex(showIndex-1,self.m_receive_bg2,10,4)

    --再充值提示
    if self.coin_status == 1 or self.coin_status == 2 then
        self.next_tips:setVisible(false)
    else
        local month_award_coin = getConfig(game_config_field.month_award_coin)
        local itemCfg = month_award_coin:getNodeWithKey(tostring(self.coin_days+1))
        if itemCfg then
            local pay = itemCfg:getNodeWithKey("pay"):toInt()
            local rest = pay - self.coin_pay_rmb
            self.next_tips:setString(string_helper.game_daily_sign.text .. rest .. string_helper.game_daily_sign.text2)
            self.next_tips:setVisible(true)
        end
    end
end

--[[--
    刷新ui
]]
function game_daily_sign.refreshUi(self)
    -- self:refreshTabBtn();    
    if self.m_show_tpye == 1 then
        self:refreshTab1();
    else
        self:refreshTab2();
    end
end

--[[--
    初始化
]]
function game_daily_sign.init(self,t_params)
    t_params = t_params or {};
    self.coin_status = t_params.coin_status
    self.coin_days = t_params.coin_days
    self.coin_pay_rmb = t_params.coin_pay_rmb
    -- cclog("self.coin_days = " .. self.coin_days)

    self.m_show_tpye = t_params.m_show_tpye or 0
    self.m_change_type = false
    self.daily_award_loop = t_params.daily_award_loop or false
    cclog2(self.daily_award_loop,"self.daily_award_loop")
    -- self.daily_award_loop = true
    -- self.coin_status = 1
    -- self.coin_days = 0
end

--[[--
    创建ui入口并初始化数据
]]
function game_daily_sign.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return game_daily_sign;