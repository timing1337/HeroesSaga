---  赛亚人归来
local game_saiya_active = {
    m_screenShoot = nil,
    m_root_layer = nil,
    reware_node = nil,
    next_time_node = nil,
    left_time_node = nil,
    award_btn = nil,
    reward_name = nil,
    rank_node = nil,
    current_point = nil,
    current_rank = nil,
    back_btn = nil,
    btn_rank = nil,
    btn_detail = nil,
    m_tGameData = nil,
    tips_word = nil,
    bar_node = nil,
    reward_steps = nil,
    title_new_label = nil,
};
--[[--
    销毁ui
]]
function game_saiya_active.destroy(self)
    cclog("----------------- game_saiya_active destroy-----------------"); 
    self.m_screenShoot = nil;
    self.m_root_layer = nil;
    self.reware_node = nil;
    self.next_time_node = nil;
    self.left_time_node = nil;
    self.award_btn = nil;
    self.reward_name = nil;

    self.rank_node = nil;
    self.current_point = nil;
    self.current_rank = nil;
    self.back_btn = nil;
    self.btn_rank = nil;
    self.btn_detail = nil;
    self.m_tGameData = nil;
    self.tips_word = nil;
    self.bar_node = nil;
    self.reward_steps = nil;
    self.title_new_label = nil;
end
--[[--
    返回
]]
function game_saiya_active.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_saiya_active.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 101 then -- 关闭
            self:back()
        elseif btnTag == 3 then--查看排行
            game_scene:addPop("game_saiya_rank_pop",{version = self.m_tGameData.rich_version})
        elseif btnTag == 12 then--详情

            -- 活动详情
            local super_active_cfg = getConfig(game_config_field.super_rich)
            local tempCount = super_active_cfg and super_active_cfg:getNodeCount() or 0
            local active_tab = {}
            for i=1, tempCount do
                local itemCfg = super_active_cfg:getNodeAt(i - 1)
                -- cclog2(itemCfg:getKey(), " version  =====    " .. tostring(self.m_tGameData.rich_version))
                if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.rich_version) then
                    table.insert(active_tab, itemCfg:getKey())
                end
            end
            table.sort(active_tab, function(data1, data2) return tonumber(data1) < tonumber(data2) end)
            -- cclog2(active_tab, "active_tab  ======    ")
            local active_msg = ""
            for i,v in ipairs(active_tab) do
                local tempCfg = super_active_cfg and super_active_cfg:getNodeWithKey(tostring(active_tab[i]))
                -- cclog2(tempCfg, "tempCfg  ======   ")
                active_msg = tempCfg and tempCfg:getNodeWithKey("notice") and tempCfg:getNodeWithKey("notice"):toStr() or ""
                if string.len(active_msg) > 0 then
                    break
                end
            end

            game_scene:addPop("game_active_limit_detail_pop",{openMsg = active_msg})
        elseif btnTag > 200 and btnTag < 300 then--三个阶段
            
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_saiya_back.ccbi");

    self.next_time_node = ccbNode:nodeForName("next_time_node")
    self.left_time_node = ccbNode:nodeForName("left_time_node")
    for i=1,3 do
        self.reware_node[i] = ccbNode:nodeForName("reware_node_" .. i)
        self.reward_name[i] = ccbNode:labelTTFForName("reward_name_" .. i)
        self.award_btn[i] = ccbNode:controlButtonForName("award_btn_" .. i)

        self.tips_word[i] = ccbNode:labelTTFForName("tips_word_" .. i)
        -- self.award_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)        
    end
    self.rank_node = ccbNode:nodeForName("rank_node")
    self.current_point = ccbNode:labelTTFForName("current_point")
    self.current_rank = ccbNode:labelTTFForName("current_rank")
    self.back_btn = ccbNode:controlButtonForName("back_btn")
    self.btn_rank = ccbNode:controlButtonForName("btn_rank")
    game_util:setCCControlButtonTitle(self.btn_rank,string_helper.ccb.title89);
    game_util:setControlButtonTitleBMFont(self.btn_rank)
    self.btn_detail = ccbNode:controlButtonForName("btn_detail")
    self.title_new_label = ccbNode:labelTTFForName("title_new_label")
    self.bar_node = ccbNode:nodeForName("bar_node")
    local title86 = ccbNode:labelTTFForName("title86");
    local title87 = ccbNode:labelTTFForName("title87");
    local title88 = ccbNode:labelTTFForName("title88");
    local title90 = ccbNode:labelTTFForName("title90");
    local title91 = ccbNode:labelTTFForName("title91");
    title86:setString(string_helper.ccb.title86);
    title87:setString(string_helper.ccb.title87);
    title88:setString(string_helper.ccb.title88);
    title90:setString(string_helper.ccb.title90);
    title91:setString(string_helper.ccb.title91);
    -- self.back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    -- self.btn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    -- self.btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    -- 本层阻止触摸传导下一层
    -- local function onTouch(eventType, x, y)
    --     if eventType == "began" then 
    --         return true; 
    --     end 
    -- end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    -- self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    -- self.m_root_layer:setTouchEnabled(true);
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end
    return ccbNode;
end

--[[
    竖的table
]]
function game_saiya_active.createRankTable(self,viewSize)
    local rankTable = self.m_tGameData.players
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rankData = rankTable[index+1]
            local name = rankData.name
            local score = rankData.score
            local rank = rankData.rank

            detail_label:setString(tostring(rank) .. "." .. name )
            detail_label_score:setString(tostring(score))
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
--[[
    label
]]

--[[--
    刷新ui
]]
function game_saiya_active.refreshUi(self)
    self.current_point:setString(tostring(self.m_tGameData.scores))
    self.current_rank:setString(tostring(self.m_tGameData.rank))

    self.rank_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createRankTable(self.rank_node:getContentSize());
    self.rank_node:addChild(tableView,10,10);

    local richCfg = getConfig(game_config_field.super_rich);
    local reward_key_tab = {}   -- 活动奖励的id列表
    local rankTable = richCfg:getNodeCount()
    for i=1, rankTable do
        local itemCfg = richCfg:getNodeAt( i - 1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.rich_version) then
            table.insert(reward_key_tab, itemCfg:getKey())
        end
    end
    local sortFun = function ( data1, data2 )
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(reward_key_tab, sortFun)

    local firstCfg = richCfg:getNodeWithKey(tostring(reward_key_tab[1]))
    if not firstCfg then 
        return
    end
    local reward_12 = firstCfg:getNodeWithKey("reward_12"):getNodeAt(0)
    local reward_21 = firstCfg:getNodeWithKey("reward_21"):getNodeAt(0)
    local reward_24 = firstCfg:getNodeWithKey("reward_24"):getNodeAt(0)
    local des = firstCfg:getNodeWithKey("des"):toStr()

    local rewardTable = {}
    table.insert( rewardTable, json.decode(reward_12:getFormatBuffer()) )
    table.insert( rewardTable, json.decode(reward_21:getFormatBuffer()) )
    table.insert( rewardTable, json.decode(reward_24:getFormatBuffer()) )
    local serverTime = math.floor(game_data:getUserStatusDataByKey("server_time"))
    local name_tab = {"12","21","24"}
    local countDownTime = 5000
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local itemData = rewardTable[btnTag]
        game_util:lookItemDetal(itemData)
    end
    for i=1,3 do
        local icon,name,count = game_util:getRewardByItemTable(rewardTable[i],true)

        self.reware_node[i]:removeAllChildrenWithCleanup(true)
        if icon then
            self.reware_node[i]:addChild(icon)
        end
        if count then
            self.reward_name[i]:setString("×" .. count)
        end

        local richer = self.reward_steps[name_tab[i]].richer
        self.tips_word[i]:setHorizontalAlignment(kCCTextAlignmentCenter)
        self.tips_word[i]:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
        if richer == "" then
            self.tips_word[i]:setString(name_tab[i] .. ":00" .. "\n" .. string_helper.game_saiya_active.rank_one)
            -- cclog2(name_tab[i])
        else
            self.tips_word[i]:setString(string_helper.game_saiya_active.rewarder .. richer)
        end
        --加查看按钮
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setTag(i)
        button:setAnchorPoint(ccp(0.5,0.5))
        button:setOpacity(0)
        self.reware_node[i]:addChild(button)
    end
    for i=1,3 do
        local end_time = self.reward_steps[name_tab[i]].end_time
        if end_time - serverTime > 0 then
            countDownTime = end_time - serverTime
            break;
        end
    end
    --如果结束了，直接设为0
    if serverTime > self.m_tGameData.rich_end_time then
        countDownTime = 0
    end
    --活动倒计时
    local lastTlabel2 = self.left_time_node:getChildByTag(10)
    if lastTlabel2 then
        lastTlabel2:removeFromParentAndCleanup(true)
    end
    local countDownTime2 = self.m_tGameData.rich_end_time - serverTime
    local function timeEndFunc()
       function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_active_index"), http_request_method.GET, {rich_open = 1},"super_active_index",true,true)
    end
    local countdownLabel2 = game_util:createCountdownLabel(countDownTime2,timeEndFunc,8,1);
    countdownLabel2:setAnchorPoint(ccp(0,0.5))
    countdownLabel2:setColor(ccc3(0,250,0))
    self.left_time_node:addChild(countdownLabel2,10,10)
    --倒计时
    local lastTlabel = self.next_time_node:getChildByTag(10)
    if lastTlabel then
        lastTlabel:removeFromParentAndCleanup(true)
    end

    local countdownLabel = game_util:createCountdownLabel(countDownTime,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setColor(ccc3(0,250,0))
    self.next_time_node:addChild(countdownLabel,10,10)
    --倒计时bar
    local time_bar = self.bar_node:getChildByTag(11)
    if time_bar then
        time_bar:removeFromParentAndCleanup(true)
    end
    local max_value = self.m_tGameData.rich_end_time - self.m_tGameData.rich_start_time
    local now_value = serverTime - self.m_tGameData.rich_start_time
    local bar = ExtProgressTime:createWithFrameName("pirate_life_1.png","pirate_life.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,0));
    self.bar_node:addChild(bar,-1,11);
    self.title_new_label:setString(des)
end
--[[--
    初始化
]]
function game_saiya_active.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_screenShoot = t_params.screenShoot;
    self.reware_node = {}
    self.reward_name = {}
    self.award_btn = {}
    self.tips_word = {}
    self.reward_steps = self.m_tGameData.reward_steps or {}
end
--[[--
    创建ui入口并初始化数据
]]
function game_saiya_active.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_saiya_active