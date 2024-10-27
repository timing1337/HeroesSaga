---  漫天星
local game_sky_star = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_btn_recharge = nil,
    m_btn_detail = nil,
    m_left_time_node = nil,
    m_coin_label = nil,
    m_number_scroll_view = nil,
    m_startFlag = nil,
    m_screenShoot = nil,
    m_numberTab = nil,
    m_cost_coin_label = nil,
    m_get_coin_label = nil,
    m_active_keyTab = nil,   -- 活动id
};
--[[--
    销毁ui
]]
function game_sky_star.destroy(self)
    -- body
    cclog("----------------- game_sky_star destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_btn_recharge = nil;
    self.m_btn_detail = nil;
    self.m_left_time_node = nil;
    self.m_coin_label = nil;
    self.m_number_scroll_view = nil;
    self.m_startFlag = nil;
    self.m_screenShoot = nil;
    self.m_numberTab = nil;
    self.m_cost_coin_label = nil;
    self.m_get_coin_label = nil;
    self.m_active_keyTab = nil;
end

--[[--
    返回
]]
function game_sky_star.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_sky_star.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then--充值
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then--查看详情
            local bandit_cfg = getConfig(game_config_field.bandit)
            local active_msg = ""
            for k,v in pairs(self.m_active_keyTab ) do
                local itemCfg = bandit_cfg:getNodeWithKey(tostring(v))
                if itemCfg and itemCfg:getNodeWithKey("notice") then
                    local msg = itemCfg:getNodeWithKey("notice"):toStr()
                    if string.len(msg) > 0 then
                        active_msg = msg
                        break
                    end
                end
            end
            game_scene:addPop("game_active_limit_detail_pop",{openMsg = active_msg})
        elseif btnTag == 13 then--启动
                -- local costCoin = 0;
                -- local coin = game_data:getUserStatusDataByKey("coin");
                -- if costCoin > coin then
                --     game_scene:addPop("game_normal_tips_pop",{m_openType = 4})--钻石不足
                --     return;
                -- end
            function responseMethod(tag,gameData)
                self.m_root_layer:setTouchEnabled(true);
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:startActiveAnim();
            end
            -- reward_id = 1
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("bandit_get_reward"), http_request_method.GET, {},"bandit_get_reward")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_sky_star.ccbi");
    -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg");--
    self.m_coin_label = ccbNode:labelTTFForName("m_coin_label");--剩余钻石
    self.m_cost_coin_label = ccbNode:labelTTFForName("m_cost_coin_label");
    self.m_get_coin_label = ccbNode:labelTTFForName("m_get_coin_label");
    self.m_number_scroll_view = ccbNode:scrollViewForName("m_number_scroll_view")
    self.m_number_scroll_view:setTouchEnabled(false);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local title59 = ccbNode:labelTTFForName("title59");
    local title60 = ccbNode:labelTTFForName("title60");
    title60:setString(string_helper.ccb.title60);
    title59:setString(string_helper.ccb.title59)
    -- -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(false);
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end
    self.m_ccbNode = ccbNode;
    self:createNumberUi();
    return ccbNode;
end

--[[
    
]]
function game_sky_star.createNumberUi(self)
    local viewSize = self.m_number_scroll_view:getViewSize();
    local itemCount = 5;
    local itemWidth = viewSize.width/itemCount
    local itemHeight = viewSize.height*11
    for i=1,itemCount do
        local numberBatchNode = CCSpriteBatchNode:create("ccbResources/ui_sky_star_res-hd.pvr.ccz");
        numberBatchNode:setContentSize(CCSizeMake(itemWidth, itemHeight));
        for j=1,11 do
            local numberSpr = CCSprite:createWithSpriteFrameName("zsmtx_" .. ((j-1)%10) .. ".png");
            numberSpr:setPosition(ccp(itemWidth*0.5, viewSize.height*(j - 0.5)));
            numberBatchNode:addChild(numberSpr);
        end
        numberBatchNode:setPosition(ccp(itemWidth*(i - 1),0))
        numberBatchNode:setTag(i);
        self.m_number_scroll_view:addChild(numberBatchNode);
        self.m_numberTab[i] = {itemNode = numberBatchNode,itemWidth = itemWidth,itemHeight = itemHeight,numberHeight = viewSize.height,actionFlag = false}
    end
end

--[[
    运行文字动画
]]
function game_sky_star.runNumberAction(self,index,toNumber,delayTime,actionCallBackFunc,lastFlag)
    local itemCount = #self.m_numberTab;
    local itemData = self.m_numberTab[index];
    itemData.actionFlag = true;
    local pX,pY = itemData.itemNode:getPosition();
    local offsetY = itemData.numberHeight*toNumber + pY;
    local arr = CCArray:create();
    if delayTime > 0 then
        arr:addObject(CCDelayTime:create(delayTime));
    end
    if lastFlag == true then
        arr:addObject(CCEaseOut:create(CCMoveTo:create(offsetY/600,ccp(pX,-itemData.numberHeight*toNumber)),5));
    else
        arr:addObject(CCMoveTo:create(offsetY/800,ccp(pX,-itemData.numberHeight*toNumber)));
    end
    arr:addObject(CCCallFuncN:create(actionCallBackFunc));
    itemData.itemNode:runAction(CCSequence:create(arr));
end

--[[
    开始数字滚动动画
]]
function game_sky_star.startActiveAnim(self)
    if self.m_startFlag == true then
        return;
    end
    self.m_startFlag = true;
    -- local resultTab = {math.random(0,9),math.random(0,9),math.random(0,9),math.random(0,9),math.random(0,9)}
    local reward = self.m_tGameData.reward or {};
    local coin = reward.coin or 0;
    if coin > 99999 then--超过上限
        self.m_startFlag = false;
        self.m_root_layer:setTouchEnabled(false);
        game_util:rewardTipsByDataTable(reward);
        self:refreshUi();
        return;
    end
    local resultTab = {math.floor(coin/10000),math.floor(coin%10000/1000),math.floor(coin%1000/100),math.floor(coin%100/10),math.floor(coin%10)}
    cclog("resultTab == " .. json.encode(resultTab) .. " ;coin = " .. coin)
    local itemCount = #self.m_numberTab;
    local actionIndex = itemCount;
    local roundCount = 0;
    local function actionCallBackFunc( node )
        local index = node:getTag();
        local itemData = self.m_numberTab[index];
        local pX,pY = itemData.itemNode:getPosition();
        if pY <= -itemData.numberHeight*10 then
            -- cclog("reset postion --------------------index = " .. index)
            pY = 0;
            itemData.itemNode:setPositionY(pY);
        end
        local tempItem = self.m_numberTab[index + 1]
        if (tempItem == nil and roundCount > 1) or (tempItem and tempItem.actionFlag == false) then--可以停止
            if -pY == resultTab[index]*itemData.numberHeight then
                itemData.actionFlag = false;
                actionIndex = actionIndex - 1;
                if actionIndex <= 0 then
                    self.m_startFlag = false;
                    -- cclog("startActive end --------------------index = " .. index)
                    self.m_root_layer:setTouchEnabled(false);
                    game_util:rewardTipsByDataTable(reward);
                    self:refreshUi();
                end
            else
                local lastFlag = true;
                local toNumber = resultTab[index]
                local tempNumber = toNumber - 2;--
                if tempNumber < 0 then
                    if itemData.realStop == false then
                        tempNumber = 10 + tempNumber;
                        lastFlag = false;
                        toNumber = 10
                        itemData.realStop = true;
                    end
                else
                    itemData.realStop = true;
                end
                pY = -itemData.numberHeight*tempNumber;
                itemData.itemNode:setPosition(ccp(pX, pY))
                self:runNumberAction(index,toNumber,0,actionCallBackFunc,lastFlag);
            end
        else
            self:runNumberAction(index,10,0,actionCallBackFunc,false);
            if index == itemCount then
                roundCount = roundCount + 1;
            end
        end
    end
    for index=itemCount,1,-1 do
        local itemData = self.m_numberTab[index];
        itemData.realStop = false;
        self:runNumberAction(index,10,(itemCount - index)*0.1,actionCallBackFunc,false);
        if index == itemCount then
            roundCount = roundCount + 1;
        end
    end
end

--[[
    刷新
]]
function game_sky_star.refreshLabel(self)
    --倒计时
    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.m_left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.game_sky_star.out,color = ccc3(255,255,255),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(tipsLabel,10,12)
    end
    local countdownTime = self.m_tGameData.expire or 0;
    if countdownTime > 0 then
        local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
        countdownLabel:setScale(0.9)
        countdownLabel:setColor(ccc3(255, 255, 255))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(countdownLabel,10,10)
    else
        timeEndFunc();
    end
    self.m_coin_label:setString(tostring(game_data:getUserStatusDataByKey("coin") or 0));

    local bandit_cfg = getConfig(game_config_field.bandit)
    local active_keys = self.m_active_keyTab

    local log = self.m_tGameData.log or {}
    local currKey = "0";
    for k,v in pairs(log) do
        if tonumber(k) > tonumber(currKey) then
            currKey = k;
        end
    end
    local thisKey = active_keys[tonumber(currKey) + 1]
    local itemCfg = bandit_cfg:getNodeWithKey(tostring(thisKey))
    if itemCfg then
        local coin = itemCfg:getNodeWithKey("coin"):toInt();
        local git_coin = itemCfg:getNodeWithKey("git_coin")
        local value_down = git_coin:getNodeAt(0):toInt();
        local value_up = git_coin:getNodeAt(1):toInt();
        self.m_get_coin_label:setString(string_helper.game_sky_star.sd .. value_down .. " - " .. value_up)
        self.m_cost_coin_label:setString(string_helper.game_sky_star.cost .. coin);
    else
        self.m_get_coin_label:setString(string_helper.game_sky_star.sd1)
        self.m_cost_coin_label:setString(string_helper.game_sky_star.out_lt);
    end
end

--[[--
    创建列表
]]
function game_sky_star.createTableView(self,viewSize)
    local notices = self.m_tGameData.notices or {};
    local tabCount = #notices
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempNode = CCNode:create();
            cell:addChild(tempNode,10,10);
            local public_line = CCScale9Sprite:createWithSpriteFrameName("public_line.png");
            public_line:setColor(ccc3(0, 0, 0));
            public_line:setPosition(ccp(itemSize.width*0.5, 0))
            public_line:setPreferredSize(CCSizeMake(itemSize.width*0.9, 1));
            cell:addChild(public_line);
        end
        if cell then
            local itemData = notices[index + 1] or {}
            local tempNode = cell:getChildByTag(10)
            tempNode:removeAllChildrenWithCleanup(true);
            local richLabel = game_util:createRichLabelTTF({text = "[color=ffffdc00]" .. tostring(itemData.name) .. string_helper.game_sky_star.player .. tostring(itemData.coin) .. string_helper.game_sky_star.diamond,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
            verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 8})
            richLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            tempNode:addChild(richLabel);
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_sky_star.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_tableView:setScrollBarVisible(true);
    self.m_list_view_bg:addChild(self.m_tableView,10,10);
end


--[[--
    刷新ui
]]
function game_sky_star.refreshUi(self)
    self:refreshTableView();
    self:refreshLabel();
end

--[[
    格式化数据
]]
function game_sky_star.formatData( self )
    local bandit_cfg = getConfig(game_config_field.bandit)
    local itemCount = bandit_cfg and bandit_cfg:getNodeCount() or 0
    self.m_active_keyTab = {}
    for i=1, itemCount do
        local item = bandit_cfg:getNodeAt( i - 1 )
        if item and item:getNodeWithKey("version") and  item:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
            table.insert(self.m_active_keyTab, item:getKey())
        end
    end
    local sortFun = function ( data1, data2 )
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(self.m_active_keyTab, sortFun)
end

--[[--
    初始化
]]
function game_sky_star.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_startFlag = false;
    self.m_screenShoot = t_params.screenShoot;
    self.m_numberTab = {};
    self:formatData()
end
--[[--
    创建ui入口并初始化数据
]]
function game_sky_star.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

function game_sky_star.gameGuide(self,guideType,guide_team,guide_id,t_params)

end

return game_sky_star;
