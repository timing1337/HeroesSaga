---限时活动 海贼王宝藏

local game_seapoacher = {
    m_root_layer = nil,
    m_ccbNode = nil,
    m_tGameData = nil,
    m_parentNode_last_time = nil,
    m_node_last_time = nil,

    m_label_curKey = nil,
    m_label_curRanking = nil,
    m_node_curRanking = nil,

    m_node_view_bg = nil,

    m_label_explore_1 = nil,
    m_label_explore_2 = nil,
    m_layer_progress_bar = nil,
    m_node_progress_bar = nil,
    m_progress_bar = nil,
    m_progress_bar_flag = nil,
    m_sprite_progress_bar_test = nil,
    m_sprite_progressBar_item_tab = nil,
    m_startFlag = nil,
    m_posIndex = nil,
    m_light_sprite = nil,
    m_showReward = nil,
    m_light_sprite2 = nil,
    m_piece_tab= nil,
};

--[[--
    销毁
]]
function game_seapoacher.destroy(self)
    cclog("-----------------game_seapoacher destroy-----------------");
    self.m_root_layer = nil
    self.m_ccbNode = nil
    self.m_tGameData = nil
    self.m_parentNode_last_time = nil
    self.m_node_last_time = nil
    self.m_label_curKey = nil
    self.m_label_curRanking = nil
    self.m_node_curRanking = nil

    self.m_node_view_bg = nil

    self.m_label_explore_1 = nil
    self.m_label_explore_2 = nil
    self.m_layer_progress_bar = nil
    self.m_node_progress_bar = nil
    self.m_progress_bar = nil
    self.m_progress_bar_flag = nil
    self.m_sprite_progress_bar_test = nil
    self.m_sprite_progressBar_item_tab = nil
    self.m_startFlag = nil
    self.m_posIndex = nil
    self.m_light_sprite = nil
    self.m_showReward = nil;
    self.m_light_sprite2 = nil;
    self.m_piece_tab = nil;
end
--[[--
    返回
]]
function game_seapoacher.back(self,type)
    local function endCallFunc()
        self:destroy()
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc})
end
--[[--
    读取ccbi创建ui
]]
function game_seapoacher.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then -- 海贼宝库
            -- function responseMethod( tag,gameData )
                local function callBackFunc(params)
                    if params and params.gameData then
                        self.m_tGameData = params.gameData;
                        self:refreshUi();
                    end
                end
                game_scene:addPop("game_seapoacher_box_pop",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_exchange_index"), http_request_method.GET, {},"one_piece_exchange_index")
        elseif btnTag == 12 then -- 查看详情
            function responseMethod( tag,gameData )
                game_scene:addPop("game_seapoacher_detail_pop",{gameData = gameData,show_ranking = self.m_tGameData.show_ranking})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_info"), http_request_method.GET, {},"one_piece_info")
        elseif btnTag == 13 then -- 探索一次
            function responseMethod(tag,gameData)
                self.m_root_layer:setTouchEnabled(true);
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:createRotationAnim("one");
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_open_roulette"), http_request_method.GET, {},"one_piece_open_roulette")
        elseif btnTag == 14 then -- 探索十次
            function responseMethod(tag,gameData)
                self.m_root_layer:setTouchEnabled(true);
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:createRotationAnim("ten");
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_open_roulette10"), http_request_method.GET, {},"one_piece_open_roulette10")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_seapoacher.ccbi");
    
    -- 相关
    
    self.m_ccbNode = ccbNode
    self.m_parentNode_last_time = ccbNode:nodeForName("m_parentNode_last_time")
    self.m_node_last_time = ccbNode:nodeForName("m_node_last_time")

    self.m_label_curKey = ccbNode:labelTTFForName("m_label_curKey")
    self.m_node_curRanking = ccbNode:nodeForName("m_node_curRanking")
    self.m_label_curRanking = ccbNode:labelTTFForName("m_label_curRanking")

    self.m_node_view_bg = ccbNode:nodeForName("m_node_view_bg")

    self.m_label_explore_1 = ccbNode:labelTTFForName("m_label_explore_1")
    self.m_label_explore_2 = ccbNode:labelTTFForName("m_label_explore_2")

    self.m_layer_progress_bar = ccbNode:layerForName("m_layer_progress_bar")
    self.m_node_progress_bar = ccbNode:nodeForName("m_node_progress_bar")
    self.m_sprite_progress_bar_test = ccbNode:spriteForName("m_sprite_progress_bar_test")
    self.m_light_sprite2 = ccbNode:spriteForName("m_light_sprite")
    self.m_light_sprite2:setVisible(false)
    self.m_light_sprite = ccbNode:nodeForName("m_light_sprite2")
    self.m_light_sprite:setScale(0.7)
    local m_node_treasure_1 = ccbNode:nodeForName("m_node_treasure_1")
    local pX,pY = m_node_treasure_1:getPosition();
    self.m_light_sprite:setPosition(ccp(pX,pY))

    self.m_sprite_progress_bar_test:setVisible(false)
    self:initMaterialLayerTouch(self.m_layer_progress_bar)

    for i=1, 8 do
        local tempSpr = self.m_ccbNode:nodeForName("m_sprite_treasure_" .. i)
        if tempSpr then
            tempSpr:setVisible(false)
        end
        local tempNode = self.m_ccbNode:nodeForName("m_node_treasure_" .. i)
        if tempNode then
            tempNode:removeChildByTag(997, true)
            local rewardCfg = self.m_showReward["show_id" .. i]
            local flag = true
            if rewardCfg then
                local rewardCfgTab = json.decode(rewardCfg:getFormatBuffer()) or {}
                local rewardTab = rewardCfgTab.reward or {}
                local reward_icon,name,count = game_util:getRewardByItemTable(rewardTab[1]);
                if reward_icon then
                    flag = false
                    reward_icon:setScale(0.7)
                    tempNode:addChild(reward_icon, 1, 997)
                end
            end
            if flag and tempSpr then tempSpr:setVisible(true) end
        end
    end
    -- 进度条
    local bar = ExtProgressTime:createWithFrameName("ui_progress_bar_1.png","ui_progress_bar_2.png");
    local tempSize = self.m_layer_progress_bar:getContentSize()
    bar:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setRotation(-90)
    bar:setCurValue(0,true);
    self.m_node_progress_bar:addChild(bar,-1);
    self.m_progress_bar = bar

    local m_sprite_progressBar_item,m_sprite_progress_bar_light,m_value_label
    for i=1,3 do
        m_sprite_progressBar_item = ccbNode:spriteForName("m_sprite_progressBar_item_"..i)
        m_sprite_progress_bar_light = ccbNode:spriteForName("m_sprite_progress_bar_light_"..i)
        -- m_value_label = ccbNode:labelTTFForName("m_label_00"..i)
        m_value_label = ccbNode:labelBMFontForName("m_blabel_00"..i)
        m_sprite_progress_bar_light:setVisible(false)
        m_sprite_progressBar_item:setOpacity(0);
        self.m_sprite_progressBar_item_tab[i] = {m_sprite_progressBar_item = m_sprite_progressBar_item, m_sprite_progress_bar_light = m_sprite_progress_bar_light,m_value_label=m_value_label} 
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;    --intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text197)
    return ccbNode;
end
--[[
    海贼宝藏列表 table
]]
function game_seapoacher.createBoxTableView(self,viewSize)
    local one_piece_exchange_cfg = getConfig(game_config_field.one_piece_exchange)
    local exchange_index = self.m_tGameData.exchange_index or {}
    local gifts = exchange_index.gifts or {}
    local showData = {}
    for k1,v1 in pairs(gifts) do
        for k,v in pairs(v1) do
            v.c_id = k
            table.insert(showData,v);
        end
    end
    local rewardTab = {} -- 走配置
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 2 -- 列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local itemCfg = one_piece_exchange_cfg:getNodeWithKey(showData[index+1].c_id)
            if itemCfg then
                local reward = itemCfg:getNodeWithKey("reward")
                local rewardTable = json.decode(reward:getFormatBuffer()) or {}
                if #rewardTable > 0 then
                    rewardTab[index+1] = rewardTable[1];
                    local icon,name,count = game_util:getRewardByItemTable(rewardTable[1],false)
                    if icon then
                        icon:setScale(0.75);
                        icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.55))
                        cell:addChild(icon)
                    end
                    if count then
                        local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                        tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.085))
                        cell:addChild(tempLabel)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_seapoacher.refreshTableView(self)
    self.m_node_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createBoxTableView(self.m_node_view_bg:getContentSize());
    self.m_tableView:setScrollBarVisible(true);
    self.m_node_view_bg:addChild(self.m_tableView,10,10);
end

--[[--
    rotation 轮转
]]
function game_seapoacher.createRotationAnim( self,rotationType )
    if self.m_startFlag == true then
        return;
    end
    self.m_startFlag = true;
    local angle_value = 360/8
    local rewardRandom = math.max(1,math.min((self.m_tGameData.index or 1),8))--math.random(1,8)--
    -- cclog("rewardRandom = " .. rewardRandom .. " ; index = " .. (self.m_tGameData.index or 1))
    -- cclog2(self.m_piece_tab, "self.m_piece_tab   -=========   ")
    local one_piece_rate_cfg = getConfig(game_config_field.one_piece_rate)
    local itemCfg = one_piece_rate_cfg:getNodeWithKey(tostring(self.m_piece_tab[rewardRandom])) or nil
    local show_id = itemCfg and itemCfg:getNodeWithKey("show_id") and itemCfg:getNodeWithKey("show_id"):toInt() or 0
    local totalStep = 8*2+show_id;
    local stepValue = 1;
    local decelerationCount = 4;
    local posIndex = self.m_posIndex;
    local m_shared = 0;
    local dtime = 0;
    function tick( dt )        
        if posIndex > totalStep - decelerationCount and posIndex < totalStep then
            dtime = dtime + dt;
            if dtime > dt*2*(posIndex - totalStep + decelerationCount) then
                cclog("********************" .. (2*(posIndex - totalStep + decelerationCount)))
                dtime = 0;
                posIndex = posIndex + 1;
                local m_node_treasure = self.m_ccbNode:nodeForName("m_node_treasure_" .. (posIndex%8 == 0 and 8 or posIndex%8))
                local pX,pY = m_node_treasure:getPosition();
                self.m_light_sprite:setPosition(ccp(pX,pY));
            end
        elseif posIndex == totalStep then
            dtime = dtime + dt;
            if dtime > 1.0 then
                stepValue = 2;
            end
        else
            posIndex = posIndex + 1;
            local m_node_treasure = self.m_ccbNode:nodeForName("m_node_treasure_" .. (posIndex%8 == 0 and 8 or posIndex%8))
            local pX,pY = m_node_treasure:getPosition();
            self.m_light_sprite:setPosition(ccp(pX,pY));
        end
        if stepValue == 2 then
            self.m_posIndex = posIndex%8 == 0 and 8 or posIndex%8;
            scheduler.unschedule(m_shared)
            self.m_startFlag = false;
            local reward = self.m_tGameData.gifts or {}
            game_scene:addPop("game_seapoacher_reward_pop",{gameData = reward})
            self:refreshUi()
            self.m_root_layer:setTouchEnabled(false);
        end
    end
    m_shared = scheduler.schedule(tick, 0.05, false)
end

function game_seapoacher.initMaterialLayerTouch(self,formation_layer)
    local realPos = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        for i=1,8 do
            local m_sprite_progressBar_item = self.m_ccbNode:spriteForName("m_sprite_progressBar_item_"..i)
            if m_sprite_progressBar_item then
                realPos = m_sprite_progressBar_item:getParent():convertToNodeSpace(ccp(x,y));
                if m_sprite_progressBar_item:boundingBox():containsPoint(realPos) then
                    if self.m_sprite_progressBar_item_tab[i].m_sprite_progress_bar_light:isVisible() then
                        self:getStepReward(i);
                    else
                        local one_piece_cfg = getConfig(game_config_field.one_piece)
                        local version = self.m_tGameData.version
                        local itemCfg = one_piece_cfg:getNodeWithKey(tostring(version))
                        if itemCfg then
                            local reward = itemCfg:getNodeWithKey(tostring("reward_" .. i))
                            local rewardTable = json.decode(reward:getFormatBuffer()) or {}
                            if #rewardTable > 0 then
                                game_util:lookItemDetal(rewardTable[1])
                            end
                        end
                    end
                    break;
                end
            end
            local m_node_treasure = self.m_ccbNode:nodeForName("m_sprite_treasure_" .. i)
            if m_node_treasure then
                realPos = m_node_treasure:getParent():convertToNodeSpace(ccp(x,y));
                if m_node_treasure:boundingBox():containsPoint(realPos) then
                    -- local one_piece_rate_cfg = getConfig(game_config_field.one_piece_rate)
                    -- local itemCfg = one_piece_rate_cfg:getNodeWithKey(tostring(i))
                    -- local show_id = itemCfg and itemCfg:getNodeWithKey(show_id) and itemCfg:getNodeWithKey(show_id):toInt()
                    local itemCfg = self.m_showReward["show_id" .. tostring(i)]
                    if itemCfg then
                        local reward = itemCfg:getNodeWithKey("reward")
                        local rewardTable = json.decode(reward:getFormatBuffer()) or {}
                        if #rewardTable > 0 then
                            game_util:lookItemDetal(rewardTable[1])
                        end
                    end
                    break;
                end
            end
        end
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY + 5)
    formation_layer:setTouchEnabled(true)
end

--[[
    
]]
function game_seapoacher.getStepReward(self,step)
    function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        local reward = self.m_tGameData.reward or {}
        game_util:rewardTipsByDataTable(reward);
        self:refreshUi();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_step_reward"), http_request_method.GET, {step = step},"one_piece_step_reward")
end

--[[
    倒计时
]]
function game_seapoacher.setCountdownTime(self)
    local countdownTime = self.m_tGameData.remainder_time or 0
    self.m_node_last_time:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.m_node_last_time:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.game_seapoacher.ended,color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_node_last_time:addChild(tipsLabel,10,12)
    end
    
    if countdownTime > 0 then
        local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_node_last_time:addChild(countdownLabel,10,10)
    else
        timeEndFunc();
    end
end

--[[--
    刷新ui
]]
function game_seapoacher.refreshUi(self)
    -- 刷新 今日免费次数, 消耗钻石数量, 当前密钥, 当前排名
    local key_num = self.m_tGameData.score or 0
    self.m_label_curKey:setString(tostring(key_num))
    local rank = self.m_tGameData.rank or 0
    self.m_label_curRanking:setString(tostring(rank))
    self:setCountdownTime();

    local m_label_curscore = self.m_ccbNode:labelBMFontForName("m_blabel_curscore")
    if m_label_curscore then
        m_label_curscore:setString(tostring(self.m_tGameData.score))
    end

    -- 进度条控制 34% = 100  65.5 = 200 100 = 300    
    local one_piece_cfg = getConfig(game_config_field.one_piece)
    local version = self.m_tGameData.version
    local itemCfg = one_piece_cfg:getNodeWithKey(tostring(version))
    if itemCfg then
        local step_reward = self.m_tGameData.step_reward or {}
        local maxValue = 100
        local ownScore = self.m_tGameData.score or 0
        for i=1,3 do
            local score = itemCfg:getNodeWithKey("score_" .. i)
            if score then
                score = score:toInt();
                maxValue = math.max(maxValue,score)
                if ownScore >= score then
                    if game_util:idInTableById(i,step_reward) == true then
                        self.m_sprite_progressBar_item_tab[i].m_sprite_progress_bar_light:setVisible(false)
                    else
                        self.m_sprite_progressBar_item_tab[i].m_sprite_progress_bar_light:setVisible(true)
                    end
                else
                    self.m_sprite_progressBar_item_tab[i].m_sprite_progress_bar_light:setVisible(false)
                end
                self.m_sprite_progressBar_item_tab[i].m_value_label:setString(score)
            end
            local m_sprite_progressBar_item = self.m_sprite_progressBar_item_tab[i].m_sprite_progressBar_item
            m_sprite_progressBar_item:removeAllChildrenWithCleanup(true)
            local reward = itemCfg:getNodeWithKey(tostring("reward_" .. i))
            local rewardTable = json.decode(reward:getFormatBuffer()) or {}
            if #rewardTable > 0 then
                local icon,name,count = game_util:getRewardByItemTable(rewardTable[1],false)
                if icon then
                    local itemSize = m_sprite_progressBar_item:getContentSize();
                    icon:setScale(0.6);
                    icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.55))
                    m_sprite_progressBar_item:addChild(icon)
                    if ownScore < score then
                        icon:setColor(ccc3(155,155,155))
                    end
                end
            end
        end        
        self.m_progress_bar:setCurValue(100*ownScore/maxValue,self.m_progress_bar_flag)
        local one_coin = itemCfg:getNodeWithKey("one_coin"):toInt();
        local ten_coin = itemCfg:getNodeWithKey("ten_coin"):toInt();
        self.m_label_explore_1:setString(one_coin .. string_helper.game_seapoacher.diamond)
        self.m_label_explore_2:setString(ten_coin .. string_helper.game_seapoacher.diamond)
    else
        self.m_label_explore_1:setString(string_helper.game_seapoacher.not_config)
        self.m_label_explore_2:setString(string_helper.game_seapoacher.not_config)
    end
    local open_times = self.m_tGameData.open_times or 0
    if open_times > 0 then
        self.m_label_explore_1:setString(string_helper.game_seapoacher.day_out..tostring(open_times)..string_helper.game_seapoacher.ci)
    end
    self:refreshTableView();
end

--[[--
    初始化
]]
function game_seapoacher.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_sprite_progressBar_item_tab = {}
    self.m_progress_bar_flag = false
    self.m_screenShoot = t_params.screenShoot;
    self.m_startFlag = false;
    self.m_posIndex = 1;

    self.m_showReward = {}
    local one_piece_rate_cfg = getConfig(game_config_field.one_piece_rate)
    cclog2(one_piece_rate_cfg, "one_piece_rate   ========   ")
    local  count = one_piece_rate_cfg:getNodeCount()
    self.m_piece_tab = {}
    for i=1, count do
        local cnode = one_piece_rate_cfg:getNodeAt(i - 1)
        if game_util:compareItemCfgVersion(cnode, self.m_tGameData.version) then
            local show_id = cnode:getNodeWithKey("show_id") and cnode:getNodeWithKey("show_id"):toInt() or 0
            if show_id then
                self.m_showReward["show_id" .. tostring(show_id)] = cnode
            else
                cclog2(string_helper.game_seapoacher.id .. i .. string_helper.game_seapoacher.not_found)
            end
            table.insert( self.m_piece_tab, cnode:getKey() )
        end
    end
    table.sort(self.m_piece_tab, function (data1, data2) return tonumber(data1) < tonumber(data2) end)
    -- cclog2(self.m_showReward, "self.m_showReward   ===  ")
end

--[[--
    创建ui入口并初始化数据
]]
function game_seapoacher.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();

    return rootScene;
end

return game_seapoacher;