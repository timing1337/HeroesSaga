
---  活动
local game_activity_new_pop = {
    m_root_layer = nil,
    m_table_view = nil,--table view
    m_selected_index = nil,
    m_activity_pic = nil,
    m_open_label = nil,
    m_btn_use = nil,
    m_label_table = nil,
    m_text_table = nil,
    m_active_cfg = nil,
    m_btn_reward = nil,
    m_alpha_back = nil,
    m_access_flag = nil,
    m_reward_id = nil,
    m_get_gift = nil,
    live_data = nil,
    sacrifice = nil,
    reward_flag = nil,
    others_index = nil,
    left_times_label = nil,
    m_gameData = nil,
    vip_index = nil;
    m_isOpen = false,
    falsh_blindness = nil,
    btn_look_2 = nil,
    chapterID_index = nil,
    myChapterId = nil,
    btn_rank = nil,
    search_treasure = nil,
    itemIndex = nil,
    m_cur_selectitem_index = nil,
    m_cur_selectcell = nil,
    m_node_showrewardboard = nil,
    m_node_showRewards_board = nil,
    m_curShowLeftView = nil,
};
--[[--
    销毁ui
]]
function game_activity_new_pop.destroy(self)
    -- body
    cclog("-----------------game_activity_new_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_table_view = nil;
    self.m_selected_index = nil;
    self.m_activity_pic = nil;
    self.m_open_label = nil;
    self.m_btn_use = nil;
    self.m_label_table = nil;
    self.m_text_table = nil;
    self.sacrifice = nil;
    self.m_btn_reward = nil;
    self.m_alpha_back = nil;
    self.m_access_flag = nil;
    self.m_reward_id = nil;
    self.m_get_gift = nil;
    self.live_data = nil;
    self.reward_flag = nil;
    self.others_index = nil;
    self.left_times_label = nil;
    -- if self.m_active_cfg then
        -- self.m_active_cfg:delete();
        self.m_active_cfg = nil;
    -- end
    if self.m_gameData then
        self.m_gameData:delete();
        self.m_gameData = nil;
    end
    self.vip_index = nil;
    self.m_isOpen = false;
    self.falsh_blindness = nil;
    self.btn_look_2 = nil;
    self.chapterID_index = nil;
    self.myChapterId = nil;
    self.btn_rank = nil;
    self.search_treasure = nil;
    itemIndex = nil;
    self.m_cur_selectitem_index = nil;
    self.m_cur_selectcell = nil;
    self.m_node_showrewardboard = nil;
    self.m_node_showRewards_board = nil;
    self.m_curShowLeftView = nil;
end
--[[ 新手引导开启的table ]]
-- 110：无主之地 106：资源争夺战 108：每日挑战 109：极限挑战 105：马上有经验 107：生存大考验  115 献祭 tongji 通缉  kuangshan 矿山
local openActivityTab = { item1 = 110,item2 = 106,item3 = 108, item4 = 109,item5 = 105,
    item6 = 107, item7 = 115, item8 = 114}

--[[ 活动id对应的事件 ]] -- name 名称  -- buttonId：开启标志
local activityIDInfo = {}
activityIDInfo["10"]= { name = "live_res" } -- 生存物资
activityIDInfo["20"]= { bane = "boss" } -- 世界BOSS
activityIDInfo["30"]= { name = "middle", buttonId = 110 } -- 无主之地
activityIDInfo["40"]= { name = "resource_war", buttonId = 106 } -- 资源争夺战
activityIDInfo["50"]= { name = "challange_normal", buttonId = 108 } -- 每日挑战
activityIDInfo["60"]= { name = "challange_hard", buttonId = 109 } -- 极限挑战
activityIDInfo["70"]= { name = "nima_exp", buttonId = 105 } -- 马上有经验
activityIDInfo["80"]= { name = "challange_live", buttonId = 107 } -- 生存大考验
activityIDInfo["90"]= { name = "god", buttonId = 115 } -- 献祭
activityIDInfo["100"]= { name = "rojer", buttonId = 114 } -- 罗杰的宝藏
activityIDInfo["110"]={ name = "challange_top" } -- 巅峰挑战
activityIDInfo["120"]={ name = "tongji" } -- 通缉令
activityIDInfo["130"]={ name = "kuangshan" } -- 矿山
activityIDInfo["140"]={ name = "server_pk" } -- 跨服PK



--[[--
    返回
]]
function game_activity_new_pop.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
	self:destroy();
end

--[[--
    再次进入这个界面
]]
function game_activity_new_pop.reEnter(self)
    if self.m_isOpen == false then
        return 
    end

    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_activity_new_pop",{gameData = gameData})
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end
--[[--
    读取ccbi创建ui
]]
function game_activity_new_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_activity_new_res.plist")
    self.m_isOpen = true
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            if game_data.setLeatestActivityIndex then  game_data:setLeatestActivityIndex(nil) end  -- 清空记录上次选中的活动
            self:back()
        elseif btnTag == 101 then--参战或未开启（右下角的按钮：参战/进入）
            if not self:isButtonByIndex( self.m_cur_selectitem_index ) then
                return;
            end
            local activeData =  self.m_active_cfg[self.m_cur_selectitem_index + 1]
            local active_cfg = activeData.data
            local active_key = activeData.activeIndex
            
            if  active_key == "20" then--世界boss
                self:fightWorldBOSS()
            elseif active_key == "30" then--中立地图
                self:openMiddleMap()
            elseif active_key == "80" then--生存大考验
                game_scene:enterGameUi("game_activity_live",{liveData = self.live_data})
                self:destroy();
            elseif  active_key == "90"  then--献祭
                self:openOfferingSacrifices();
            elseif  active_key == "100"  then -- 罗杰的宝藏
                    self:enterPrecious()
            elseif  active_key == "110"  then -- 巅峰挑战 顶级玩家
                self:fightTopPlayer()
            elseif active_key == "120" then -- 通缉令
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_activity_tongji_scene",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("wanted_wanted_ui"), http_request_method.GET, nil,"private_city_world_map")
             elseif active_key == "130" then
                function mineResponseMethod(tag,gameData)
                    game_scene:enterGameUi("game_activity_mine",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(mineResponseMethod,game_url.getUrlForKey("mine_index"), http_request_method.GET, {},"mine_index")
            elseif active_key == "140" then
                local function responseMethod(tag,gameData)
                    local data = gameData and gameData:getNodeWithKey("data")
                    local is_final = data and data:getNodeWithKey("is_final"):toInt() or -1
                    if is_final == 0 then
                        game_scene:enterGameUi("game_server_grouppk_scene",{data = data})
                    elseif is_final == 1 then
                        game_scene:enterGameUi("game_serverpk_scene",{data = data});
                        self:destroy();
                    else
                        -- 数据错误
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_battle"), http_request_method.GET, nil,"serverpk_team_battle")
            elseif #active_cfg.active_chapterID > 0 then
                local chapterID = active_cfg.active_chapterID[1]--根据chapterId来判断跳转
                --先判断，再进入
                if tolua.type(chapterID) == "table" then
                    chapterID = self:getMyChapterId(active_cfg)
                end
                -- cclog("chapterID == " .. chapterID)
                local downLimit = 0
                local upLimit = 0
                if chapterID < 100 then
                    local levelCfg = active_cfg.level
                    downLimit = levelCfg[1]
                    upLimit = levelCfg[2]
                else
                    local chapterCfg = getConfig(game_config_field.active_chapter)
                    local itemCfg = chapterCfg:getNodeWithKey(tostring(chapterID))
                    local levelCfg = itemCfg:getNodeWithKey("level")
                    downLimit = levelCfg:getNodeAt(0):toInt()
                    upLimit = levelCfg:getNodeAt(1):toInt()
                end
                if game_data:getUserStatusDataByKey("level") >= downLimit and game_data:getUserStatusDataByKey("level") <= upLimit then
                    local buy_index = self.others_index[tostring(chapterID)]
                    local active_step = buy_index.active_steps
                    -- cclog2("buy_index == " .. json.encode(buy_index))
                    cclog2(buy_index,"buy_index")
                    local cur_times = buy_index["cur_times"]--打了多少次活动
                    local fight_times = buy_index["times"]--总共能打几次
                    local active_steps = buy_index["active_steps"]--是否有打的记录
                    local steps = game_util:getTableLen(active_steps)
                    cclog("steps = " .. steps)
                    if cur_times < fight_times then
                        game_scene:enterGameUi("active_map_scene",{gameData = nil,activeChapterId = tostring(chapterID),cur_times = cur_times,fight_times = fight_times,active_step = active_step});
                        self:destroy();
                    else
                        if steps > 0 then--打过了没打完
                            game_scene:enterGameUi("active_map_scene",{gameData = nil,activeChapterId = tostring(chapterID),cur_times = fight_times - 1,fight_times = fight_times,active_step = active_step});
                            self:destroy();
                        else
                            local vipCfg = getConfig(game_config_field.vip);
                            local vipLevel = game_data:getVipLevel()
                            local vipItemCfg = vipCfg:getNodeWithKey(tostring(vipLevel))
                            local active_times = vipItemCfg:getNodeWithKey("active_times"):toInt()--0是不能打，1是可以打
                            if active_times == 0 then--活动次数等于0并且step也为0
                                game_util:addMoveTips({text = string_helper.game_activity_new_pop.lackTimes})
                            else
                                local chapterCfg = getConfig(game_config_field.active_chapter)
                                local itemCfg = chapterCfg:getNodeWithKey(tostring(chapterID))
                                local buy_limit = itemCfg:getNodeWithKey("vip_buy")
                                local buy_count = buy_limit:getNodeCount()
                                local cur_buy_times = buy_index["cur_buy_times"]
                                if cur_buy_times < buy_count then
                                    local function responseMethod(tag,gameData)
                                        game_scene:enterGameUi("active_map_scene",{gameData = nil,activeChapterId = tostring(chapterID),cur_times = fight_times - 1,fight_times = fight_times,active_step = active_step});
                                        self:destroy();
                                    end
                                    local coin = buy_limit:getNodeAt(cur_buy_times):toInt()
                                    --换成统一的提示
                                    local t_params = 
                                    {
                                        m_openType = 10,
                                        coin = coin,
                                        m_ok_func = function()
                                            game_scene:removePopByName("game_normal_tips_pop");
                                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_fight_times"), http_request_method.GET, {chapter = tostring(chapterID)},"buy_fight_times")
                                        end
                                    }
                                    game_scene:addPop("game_normal_tips_pop",t_params)
                                else
                                    game_util:addMoveTips({text = string_helper.game_activity_new_pop.lackTimes2})
                                end
                            end
                        end
                    end
                else
                    game_util:addMoveTips({text = downLimit .. string_helper.game_activity_new_pop.openLevel})
                end
            end
        elseif btnTag == 102 then--查看奖励
        elseif btnTag == 103 then--领取物资
        elseif btnTag == 500 then--boss排行榜
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_new_rank",{gameData = gameData,index = 7})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("top_world_boss_hurt"), http_request_method.GET, {page = 0},"top_world_boss_hurt",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_activity_new_scene.ccbi");
    self.m_table_view = ccbNode:nodeForName("table_view_node")
    self.m_activity_pic = ccbNode:spriteForName("sprite_activity_pic")
    self.m_open_label = ccbNode:labelTTFForName("activity_open_label")
    self.btn_use = ccbNode:controlButtonForName("btn_use")
    self.m_text_table = ccbNode:nodeForName("text_table_node")
    self.m_btn_reward = ccbNode:nodeForName("btn_reward")
    self.m_alpha_back = ccbNode:scale9SpriteForName("alpha_back")
    self.m_get_gift = ccbNode:controlButtonForName("btn_get_gift")
    self.left_times_label = ccbNode:labelTTFForName("left_times_label")
    self.btn_look_2 = ccbNode:controlButtonForName("btn_look_2")
    self.falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    self.m_node_showrewardboard = ccbNode:nodeForName("m_node_showrewardboard")
    self.btn_rank = ccbNode:controlButtonForName("btn_rank")
    self.m_node_showRewards_board = ccbNode:nodeForName("m_node_showRewards_board")
    self.falsh_blindness:runAction(game_util:createRepeatForeverFade());
    self.falsh_blindness:setVisible(false)
    self.m_get_gift:setVisible(false);

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);

    local btn_back = ccbNode:controlButtonForName("btn_back")
    btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    self.btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    self.btn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    -- cclog2( self.m_cur_selectitem_index, " self.m_cur_selectitem_index   ===   ")
    -- cclog2( self.m_cur_selectitem_index, " self.m_cur_selectitem_index   ===   ")
    if self.initItemIndex then
        self.m_cur_selectitem_index = self.initItemIndex - 1
        self.initItemIndex = nil
    end

    self.m_access_flag = {};
    self.live_data = {}
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog("activity data=="..data:getFormatBuffer())
        local month_award = data:getNodeWithKey("month_award"):toInt();--0可领取 1 已领取 2 可充值
        local week_award = data:getNodeWithKey("week_award"):toInt();
        local boss_flag = data:getNodeWithKey("world_boss"):toInt();--0未开启
        local others = data:getNodeWithKey("index");--有的即开启
        local search_treasure = data:getNodeWithKey("search_treasure")
        local wanted_info = data:getNodeWithKey("wanted")
        self.others_index = json.decode(others:getFormatBuffer())
        if search_treasure then
        self.search_treasure = json.decode(search_treasure:getFormatBuffer())
        self.wantedData = wanted_info and json.decode(wanted_info:getFormatBuffer()) or {}
        end
        for i=1,others:getNodeCount() do
            local indexItem = others:getNodeAt(i-1)
            local index_key = indexItem:getKey()
            table.insert(self.chapterID_index,tonumber(index_key))
        end
        self.live_data = data:getNodeWithKey("active_forever") and json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer()) or {}
        self.sacrifice = data:getNodeWithKey("sacrifice") and json.decode( data:getNodeWithKey("sacrifice"):getFormatBuffer()) or {}
        -- cclog("gift_reward == " .. data:getNodeWithKey("gift_reward"):getFormatBuffer())
        local restTime = -1;
        if data:getNodeWithKey("gift_reward"):getNodeCount() > 0 then
            local gift_reward = data:getNodeWithKey("gift_reward"):getNodeAt(0);--key 是奖励id  vaLue  是时间
            self.m_reward_id = gift_reward:getKey();
            restTime = gift_reward:toInt();
            -- cclog("restTime == " .. restTime)
        end

        local function timeOverCallFun()
            self.m_get_gift:setEnabled(true)
        end
        if restTime == 0 then
            local timeLabel = game_util:createCountdownLabel(restTime,timeOverCallFun)
            timeLabel:setAnchorPoint(ccp(0.5,0.5))
            timeLabel:setPosition(ccp(100,100))
            timeLabel:setVisible(false)
            self.m_table_view:addChild(timeLabel,10)
            self.m_get_gift:setEnabled(false)

            self.reward_flag = 0
        elseif restTime > 0 then
            self.m_get_gift:setEnabled(true)
            self.reward_flag = 1
        elseif restTime == -1 then
            self.m_get_gift:setEnabled(false)
            self.reward_flag = 0
            title = CCString:create(tostring(string_helper.game_activity_new_pop.get));

            self.m_get_gift:setTitleForState(title,CCControlStateDisabled)
            self.m_get_gift:setTitleColorForState(ccc3(192,192,192),CCControlStateDisabled)
        end

        self.m_access_flag.month_flag = month_award;
        self.m_access_flag.week_flag = week_award;
        self.m_access_flag.boss_flag = boss_flag;
        for i=1,others:getNodeCount() do
            local item = others:getNodeAt(i-1);
            local key = item:getKey();
            -- cclog("key == " .. key)
            self.m_access_flag[tostring(key)] = 1;
        end
        self:refreshUi()
        self:setActiveContent(self.m_cur_selectitem_index + 1)
        -- cclog("self.m_access_flag 1 = " .. json.encode(self.m_access_flag))
    end
    --联网取数据
    local function netForReward()
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        responseMethod("active_index",self.m_gameData)
    end
    netForReward()
    return ccbNode;
end

--[[
    根据index 查看功能是否开启
]]
function game_activity_new_pop.isButtonByIndex( self, index, showTips )
    -- cclog2(index, "index   ====   ")
    local activeData = self.m_active_cfg[index + 1]
    local activeIndex = activeData.activeIndex
    local active_info = activityIDInfo[activeIndex]
    -- cclog2(active_info, "active_info   =====   ")
    if not active_info or not active_info.buttonId then 
        local active_cfg = activeData.data
        local needLevel = active_cfg.level and active_cfg.level[1] 
        local level = game_data:getUserStatusDataByKey("level") or 0
        if level >= needLevel then
            return true, needLevel
        end
        return false, needLevel
    end
    local btnId = active_info.buttonId
    if not btnId then return true end
    -- cclog2(btnId ,"btnId   ===    ")
    local flag = false
    local needLevel = 0
    if activeIndex ~= "100" and (showTips == nil or showTips == true ) then
        flag = game_button_open:checkButtonOpen(btnId)
    else
        flag = game_button_open:getOpenFlagByBtnId(btnId)
    end
    if flag == true then return flag end
    -- cclog2(index, "index === ")
    if activeIndex == "100" then  --罗杰的宝藏
        local level = game_data:getUserStatusDataByKey("level") or 0
        if level >= 33 then
            return true
        end
        if showTips == nil or showTips == true then 
            game_button_open:checkButtonOpen(btnId)
        end
    end
    needLevel = game_button_open:getOpenButtonNeedLevel( btnId )
    return flag, needLevel
end

--[[
    获取活动信息, 次数 
]]
function game_activity_new_pop.getActiveLastInfo( self, index )
    local activeData = self.m_active_cfg[index + 1]
    local active_cfg = activeData.data
    local key = activeData.activeIndex
    if key == "80" then  -- 生存大考验
         return  self.live_data.forever_fails, 3
    elseif key == "90" then
        -- cclog2(self.sacrifice, "self.sacrifice.times    ====   ")
        self.sacrifice.times = self.sacrifice.times or 0
        if self.sacrifice.times > 0 then
            return 0, self.sacrifice.times
        end
    elseif key == "100" then -- 罗杰的宝藏
        local cur_time = self.search_treasure["cur_times"]
        local times = self.search_treasure["times"]
        local treasure = tonumber(self.search_treasure["treasure"])
        if cur_time < times or treasure > 0 then--当前可打小于总的或有正在进行的可以打
            return 0, 1
        end
    elseif key == "120" then -- 通缉活动
        -- cclog2(self.wantedData, "self.wantedData   ====  ")
        local isSuccess = self.wantedData["success"]
        -- cclog2(self.wantedData["fail_times"], "self.wantedData[")
        if not isSuccess then
            return 0, self.wantedData["fail_times"]
        end
        return 0, 0
    elseif #active_cfg.active_chapterID > 0 then
        -- if index > 1 and index < 6 then
        local chapterID = active_cfg.active_chapterID[1]--根据chapterId来判断跳转
        if tolua.type(chapterID) == "table" then
            chapterID = self:getMyChapterId(active_cfg)
        end
        -- cclog2("chapterID == " .. chapterID)
        local buy_index = self.others_index[tostring(chapterID)]
        -- cclog2( buy_index , "buy_index ===  ")
        local downLimit = 0
        local upLimit = 0
        if chapterID < 100 then
            local levelCfg = active_cfg.level
            downLimit = levelCfg[1]
            upLimit = levelCfg[2]
        else
            local chapterCfg = getConfig(game_config_field.active_chapter)
            local itemCfg = chapterCfg:getNodeWithKey(tostring(chapterID))
            local levelCfg = itemCfg:getNodeWithKey("level")
            downLimit = levelCfg:getNodeAt(0):toInt()
            upLimit = levelCfg:getNodeAt(1):toInt()
        end
        if game_data:getUserStatusDataByKey("level") >= downLimit and game_data:getUserStatusDataByKey("level") <= upLimit then
            local cur_times = buy_index["cur_times"]--打了多少次活动
            local fight_times = buy_index["times"]--总共能打几次
            return cur_times, fight_times
        end
    end
    return nil, nil
end


--[[
    设置内容
]]--
function game_activity_new_pop.setActiveContent(self,index)
    cclog2(index, "index   ==   ")
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local activeData = self.m_active_cfg[ index ]
    local active_cfg = activeData.data
    local key = activeData.activeIndex
    -- cclog2(active_cfg, "active_cfg  === ")
    local open_text = active_cfg.open_time_word
    local active_banner = active_cfg.banner
    local myChapterId = self:getMyChapterId(active_cfg,2)
    if myChapterId >= 100 then
        local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
        active_banner = itemCfg:getNodeWithKey("banner"):toStr()
        open_text = itemCfg:getNodeWithKey("open_time_word"):toStr()
    end
    self.m_open_label:setString(tostring(open_text))
    local open_size = self.m_open_label:getContentSize()
    self.m_alpha_back:setPreferredSize(CCSizeMake(open_size.width+20,17))
    
    self.falsh_blindness:setVisible(false)
    
    self.btn_look_2:setVisible(false)
    if key == "20" then  -- 世界boss按钮
        self.btn_rank:setVisible(true)
    else
        self.btn_rank:setVisible(false)
    end

    local tempSpr = CCSprite:create(tostring("ccbResources/"..active_banner..".png"));
    if tempSpr then  
        self.m_activity_pic:setDisplayFrame(tempSpr:displayFrame())
    end
    self.btn_use:setEnabled(true);
    self.btn_use:setColor(ccc3(255,255,255));
    local title = nil;
    self.m_get_gift:setVisible(false);
    self.btn_use:setVisible(true);
    local reward = active_cfg.reward_show
    local myChapterId = self:getMyChapterId(active_cfg)
    local active_btn = active_cfg.button
    if myChapterId >= 100 then
        local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
        reward = json.decode(itemCfg:getNodeWithKey("reward_show"):getFormatBuffer())
    end

    if reward and #reward > 0 then -- 有奖励
        self.m_node_showrewardboard:setVisible(true)
        self.m_node_showRewards_board:removeAllChildrenWithCleanup(true)
            self.m_node_showRewards_board:removeAllChildrenWithCleanup(true)
            local tempTable = self:createRewardTable(self.m_node_showRewards_board:getContentSize(),#reward,reward)
            self.m_node_showRewards_board:addChild(tempTable)
    else  -- 无奖励
        self.m_node_showrewardboard:setVisible(false)
    end

    if key == "90" or key == "130"then
        title = tostring(string_helper.game_activity_new_pop.enter)
    else
        title = tostring(string_helper.game_activity_new_pop.enterWar);
    end
    -- cclog2(title, "title   ===  ")
    --活动需要判断等级的
    if #active_cfg.active_chapterID > 0 then
        local chapterID = active_cfg.active_chapterID[1]--根据chapterId来判断跳转
        if tolua.type(chapterID) == "table" then
            chapterID = self:getMyChapterId(active_cfg)
        end
        -- cclog2("chapterID == " .. chapterID)
        -- cclog2(self.others_index, "self.others_index ===  ")
        local buy_index = self.others_index[tostring(chapterID)]
        local downLimit = 0
        local upLimit = 0
        if chapterID < 100 then
            local levelCfg = active_cfg.level
            downLimit = levelCfg[1]
            upLimit = levelCfg[2]
        else
            local chapterCfg = getConfig(game_config_field.active_chapter)
            local itemCfg = chapterCfg:getNodeWithKey(tostring(chapterID))
            local levelCfg = itemCfg:getNodeWithKey("level")
            downLimit = levelCfg:getNodeAt(0):toInt()
            upLimit = levelCfg:getNodeAt(1):toInt()
        end
        if game_data:getUserStatusDataByKey("level") >= downLimit and game_data:getUserStatusDataByKey("level") <= upLimit then
            local cur_times = buy_index["cur_times"]--打了多少次活动
            local fight_times = buy_index["times"]--总共能打几次
            self.left_times_label:setVisible(true)
            self.left_times_label:setString(string_helper.game_activity_new_pop.leftTimes.. (fight_times-cur_times) .. "/" .. fight_times)
        else
            game_util:addMoveTips({text = downLimit .. string_helper.game_activity_new_pop.openLevel})
        end
    -- elseif self.m_selected_index == 9 then
    --     local btnId = openActivityTab["item" .. self.m_selected_index]
    --     if btnId and not game_button_open:checkButtonOpen(btnId) then

    --     end
    --     self.left_times_label:setVisible(false)
    else
        self.left_times_label:setVisible(false)
    end  

    if not self:isButtonByIndex( self.m_cur_selectitem_index ) then
        self.btn_use:setColor(ccc3(81,81,81));
    end
    self.btn_use:setTitleForState(CCString:create(tostring( title )) ,CCControlStateNormal)

    self.m_text_table:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createTextTableView(self.m_text_table:getContentSize())
    textTableTemp:setScrollBarVisible(false)
    self.m_text_table:addChild(textTableTemp);

end
--[[--
    刷新ui
]]
function game_activity_new_pop.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableViewLeft(self.m_table_view:getContentSize());
    self.m_curShowLeftView = tableViewTemp
    -- if #self.m_active_cfg <= 10 then
    --     tableViewTemp:setMoveFlag(false)
    -- else
    --     tableViewTemp:setMoveFlag(true)
    -- end
    tableViewTemp:setScrollBarVisible(false)
    self.m_table_view:addChild(tableViewTemp);

    self.m_text_table:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createTextTableView(self.m_text_table:getContentSize())
    textTableTemp:setScrollBarVisible(false)
    self.m_text_table:addChild(textTableTemp);
    -- 可领取的奖励
    -- game_util:addTipsAnimByType(self.m_formation_btn,9);
end
--[[
    锁定具体的chapterId
]]
function game_activity_new_pop.getMyChapterId(self,active_cfg,enter_type)
    enter_type = enter_type or 1
    local chapter_id = active_cfg.active_chapterID[1]
    if enter_type == 2 then
        cclog("chapter_id = " .. json.encode(chapter_id))
    end
    local myChapterId = -1
    --比较服务器开启的活动ID 和 配置里对应位置的ID
    if tolua.type(chapter_id) == "table" then
        for i=1,#chapter_id do
            local cfgChapterId = chapter_id[i]
            for i=1,#self.chapterID_index do
                local serverChapterId = self.chapterID_index[i]
                if serverChapterId == cfgChapterId then
                    myChapterId = serverChapterId
                    break;
                end
            end
        end
    else
        myChapterId = chapter_id or -1
    end
    self.myChapterId = myChapterId
    return myChapterId
end

--[[
    创建左侧活动滑动列表
]]--
function game_activity_new_pop.createTableViewLeft( self,viewSize )
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local reward_list = {self.m_access_flag.week_flag,self.m_access_flag.month_flag,self.reward_flag,self.m_access_flag.boss_flag}
    -- cclog("reward_list = " .. json.encode(reward_list))
    local showData = self.m_active_cfg
    local activityCount = #self.m_active_cfg
    -- cclog2(self.m_active_cfg, "self.m_active_cfg   ===")
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11; --列
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_activity_title_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
            local m_sprite_title = ccbNode:spriteForName("m_sprite_title")
            local m_sprite_titleback = ccbNode:spriteForName("m_sprite_titleback")
            local m_node_tips = ccbNode:nodeForName("m_node_tips")
            local m_label_tips = ccbNode:labelTTFForName("m_label_tips")
            m_label_tips:setVisible(true)
            m_node_tips:setVisible(false)

            local m_node_needtips = ccbNode:nodeForName("m_node_needtips")
            local m_label_needtips = ccbNode:labelTTFForName("m_label_needtips")
            m_node_needtips:setVisible(false)

            local itemData = showData[index + 1].data

            local activeIndex = showData[index + 1].activeIndex
            local titleSpriteName = itemData.button .. ".png"
            local myChapterId = self:getMyChapterId(itemData)

            -- cclog2(myChapterId, "myChapterId ====  ")
            -- cclog2(titleSpriteName, "titleSpriteName ====  ")
            if myChapterId >= 100 then
                local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
                active_text = itemCfg:getNodeWithKey("des"):toStr()
                titleSpriteName = itemCfg:getNodeWithKey("button"):toStr() .. ".png"
                -- cclog2(titleSpriteName, "titleSpriteName ====  ")
            end
            titleSpriteName = "new_" .. titleSpriteName   -- 区分原来的icon

            if self.m_cur_selectitem_index == index then
               self.m_cur_selectcell = cell
            end
            if self.m_cur_selectitem_index == index and m_scale9sprite_select then
                m_scale9sprite_select:setVisible(true)
            elseif m_scale9sprite_select then
                m_scale9sprite_select:setVisible(false)
            end
            -- cclog2(titleSpriteName, "titleSpriteName  ===  ")
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName )
            if m_sprite_title and frame then
                m_sprite_title:setDisplayFrame( frame )
                m_sprite_titleback:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName ))
            end

            if activeIndex == "20" and self.m_access_flag.boss_flag == 1 then--boss可打的动画
                game_util:createPulseAnmi2( titleSpriteName ,m_sprite_title)
            end
            -- cclog2(self:isButtonByIndex( index, false ), "self:isButtonByIndex( index )  ==  ")
            local flag, needLevel = self:isButtonByIndex( index, false )
            if not flag then
                if needLevel == nil and activeIndex == "100" then  -- 罗杰的宝藏
                    needLevel = 33
                end
                m_sprite_title:setColor(ccc3(155, 155, 155))
                m_sprite_titleback:setColor(ccc3(155, 155, 155))
                if needLevel then
                    m_node_needtips:setVisible(true)
                    m_label_needtips:setString( tostring(needLevel) )
                end
            else
                m_sprite_title:setColor(ccc3(255, 255, 255))
                m_sprite_titleback:setColor(ccc3(255, 255, 255))
                local cur_times, fight_times = self:getActiveLastInfo( index )
                if cur_times and fight_times then
                    if cur_times < fight_times then
                        m_node_tips:setVisible(true)
                        m_label_tips:setString(tostring(fight_times - cur_times ) .. "/" .. tostring(fight_times))
                    end
                end
            end

        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            if index ~= self.m_cur_selectitem_index then
            --     self.m_selected_index = index+1
                -- self:refreshUi()
                self:selectCellState(item , index)
                if game_data.setLeatestActivityIndex then game_data:setLeatestActivityIndex( showData[index + 1].activeIndex ) end
                self:setActiveContent(self.m_cur_selectitem_index + 1)
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[
    设置cell的状态 选中、非选中
]]
function game_activity_new_pop.selectCellState( self, cell , index)
    -- cclog2(cell, "cell   ===   ")
    -- cclog2(index, "index   ===   ")
    if index == self.m_cur_selectitem_index then return end
    self.m_cur_selectitem_index = index
    local lastSelectCell = self.m_cur_selectcell
    -- cclog2(self.m_cur_selectitem_index, "self.m_cur_selectitem_index   ===   ")
    -- cclog2(lastSelectCell, "lastSelectCell   ===   ")
    if lastSelectCell then 
        local ccbNode = tolua.cast(lastSelectCell:getChildByTag(10),"luaCCBNode")   
        -- cclog2(ccbNode, "ccbNode1 ===  ")
        if ccbNode then 
            local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
            if m_scale9sprite_select then
                m_scale9sprite_select:setVisible(false)
            end
        end
    end
    if cell then
        local ccbNode = tolua.cast( cell:getChildByTag(10),"luaCCBNode" )   
        -- cclog2(ccbNode, "ccbNode2 ===  ")
        if ccbNode then 
            local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
            if m_scale9sprite_select then
                m_scale9sprite_select:setVisible(true)
            end
        end
        self.m_cur_selectcell = cell
    end
end

--[[
    创建文字table view
]]--
function game_activity_new_pop.createTextTableView(self,viewSize)
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local textCount = 1;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 1; --列
    params.totalItem = textCount;
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()

        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();        
            local active_text
            local active_cfg = self.m_active_cfg[self.m_cur_selectitem_index + 1].data
            if self.m_active_cfg ~= nil then
                active_text = active_cfg.des
            else
                active_text = ""
            end
            local myChapterId = self:getMyChapterId(active_cfg)
            if myChapterId >= 100 then
                local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
                active_text = itemCfg:getNodeWithKey("des"):toStr()
            end
            local tempLabel = game_util:createLabelTTF({text = active_text,color = ccc3(196,197,147), fontSize = 9})
            tempLabel:setDimensions(CCSizeMake(270,0))
            tempLabel:setAnchorPoint(ccp(0.5,1))
            tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height - 2))
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            cell:addChild(tempLabel)    
        end
        return cell;
    end
    return TableViewHelper:create(params);
end

--[[
    奖励列表
]]
function game_activity_new_pop.createRewardTable(self,viewSize,count,rewardList)


    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemCfg = rewardList[btnTag+1]
        game_util:lookItemDetal(itemCfg)
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true)
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
            end

            -- local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            -- button:setAnchorPoint(ccp(0.5,0.5))
            -- button:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
            -- button:setOpacity(0)
            -- button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
            -- node:addChild(button)
            -- button:setTag( index )

            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemCfg = rewardList[index+1]
            game_util:lookItemDetal(itemCfg)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end

--[[
    进入罗杰的宝藏
]]
function game_activity_new_pop.enterPrecious(self)
    local cur_time = self.search_treasure["cur_times"]
    local times = self.search_treasure["times"]
    local treasure = tonumber(self.search_treasure["treasure"])
    -- cclog2(game_data:getTreasure(),"treasure    ===  ")
    game_data:setTreasure(treasure)
    if cur_time < times or treasure > 0 then--当前可打小于总的或有正在进行的可以打
        if treasure > 0 then--有正在进行的直接进入
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
                self:destroy();
            end
            local params = {}
            params.treasure = treasure
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
        else
            game_scene:enterGameUi("game_pirate_precious",{})
            self:destroy();
        end
    else--不可打，判断是否可以买
        local vipCfg = getConfig(game_config_field.vip);
        local vipLevel = game_data:getVipLevel()
        local vipItemCfg = vipCfg:getNodeWithKey(tostring(vipLevel))
        local treasure_time = vipItemCfg:getNodeWithKey("treasure_time"):toInt()--1是可以购买一次
        if treasure_time == 0 then--活动次数等于0并且step也为0
            game_util:addMoveTips({text = string_helper.game_activity_new_pop.overTime})
        else
            --以后加vip
            local cur_buy_times = self.search_treasure["cur_buy_times"]
            if cur_buy_times < treasure_time then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_pirate_precious",{});
                    self:destroy();
                end
                --钱从pay config id 21
                local payCfg = getConfig(game_config_field.pay)
                local itemCfg = payCfg:getNodeWithKey("21")
                cclog2(itemCfg,"itemCfg")
                cclog2(cur_buy_times,"cur_buy_times")
                cclog2(treasure_time,"treasure_time")
                local coin = itemCfg:getNodeWithKey("coin"):getNodeAt(cur_buy_times):toInt()
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 10,
                    coin = coin,
                    m_ok_func = function()
                        game_scene:removePopByName("game_normal_tips_pop");
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_recover_times"), http_request_method.GET, {},"search_treasure_recover_times")
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                game_util:addMoveTips({text = string_helper.game_activity_new_pop.overTime})
            end
        end
    end
end

function game_activity_new_pop.resetActivityTabPos( self )
    cclog2(self.m_cur_selectitem_index, "self.m_cur_selectitem_index  ==  ")
    -- if game_data.setLeatestActivityIndex then game_data:setLeatestActivityIndex( self.m_cur_selectitem_index ) end
    self:setActiveContent(self.m_cur_selectitem_index + 1)   

    local bg_height = self.m_table_view:getContentSize().height
    local view_height = self.m_curShowLeftView:getContentSize().height
    if self.m_cur_selectitem_index > 4 then 
        local offy = (self.m_cur_selectitem_index + 3) / 5 * bg_height - view_height
        self.m_curShowLeftView:setContentOffset(ccp(0, math.min(offy, 0 ) ), true)
    end
end

--[[
    巅峰挑战 顶级玩家挑战
]]
function game_activity_new_pop.fightTopPlayer( self )
    function shopOpenResponseMethod(tag,gameData)
        game_scene:enterGameUi("game_topplayer_scene",{gameData = gameData})
    end
    network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("playerboss_index"), http_request_method.GET, {},"playerboss_index")
end

--[[
    -- 中立地图
]]
function game_activity_new_pop.openMiddleMap( self )
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_neutral_map",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_index"), http_request_method.GET, nil,"public_city_index")    
    -- local function responseMethod(tag,gameData)
    --     game_scene:enterGameUi("game_neutral_city_map_new",{gameData = gameData});
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_index"), http_request_method.GET, nil,"public_land_index")
end


--[[
    -- 世界BOSS
]]
function game_activity_new_pop.fightWorldBOSS( self )
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog("game_world_boss data=="..data:getFormatBuffer())
        local boss_info = data:getNodeWithKey("boss_info");

        if boss_info:getNodeCount() == 0 then
            local today = os.date("*t")
            local hour = today.hour
            local min = today.min
            local time_format = hour * 100 + min
            if (time_format > 1315 and time_format < 1415) or (time_format > 2015 and time_format < 2115) then
                game_util:addMoveTips({text = string_helper.game_activity_new_pop.giantEnd});
            else
                game_util:addMoveTips({text = string_helper.game_activity_new_pop.gaintNotTime});
            end
        else
            game_scene:enterGameUi("game_world_boss",{gameData = gameData})
            self:destroy()
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")          
end

--[[
    -- 献祭活动
]]
function game_activity_new_pop.openOfferingSacrifices(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_offering_sacrifices",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("sacrifice_index"), http_request_method.GET, nil,"sacrifice_index")
end

--[[
    -- 格式化活动数据
]]
function game_activity_new_pop.formatActiveData( self )
    self.m_active_cfg = {}
    local tempData = self.m_gameData and self.m_gameData:getNodeWithKey("data") or nil
    local serverpk_data = tempData and tempData:getNodeWithKey("serverpk") or nil
    local serverpk_dataTab = serverpk_data and json.decode(serverpk_data:getFormatBuffer()) or {}
    --根据is_see 绝定是否显示活动 is_see为显示活动的等级
    local level = game_data:getUserStatusDataByKey("level") or 1
    local activeCfg = getConfig(game_config_field.active_cfg)
    for i=1,activeCfg:getNodeCount() do
        local itemCfg = activeCfg:getNodeWithKey(tostring(10*i))
        local is_see = itemCfg:getNodeWithKey("is_see") and itemCfg:getNodeWithKey("is_see"):toInt() or 1
        if level >=is_see then
            local activeData = json.decode(itemCfg:getFormatBuffer())
            local key = itemCfg:getKey()
            local openFlag = true
            if key == "140" and serverpk_dataTab.open ~= true then
                openFlag = false
            end
            if openFlag and key and activeData then 
                local activityInfo = { activeIndex = key, data = activeData }
                table.insert(self.m_active_cfg,activityInfo)
            end
        end
    end
    -- cclog2(self.m_active_cfg, "self.m_active_cfg   ====   ")
    -- 给活动排序
    -- local sortFunc = function ( data1, data2 )
    --     return data1.data.sort > data1.data.sort
    -- end
    -- table.sort(self.m_active_cfg, sortFunc)
    --新版，去掉根据is_see，不排序
    -- self.m_active_cfg = json.decode(activeCfg:getFormatBuffer())
    self:sortActiveData()
    for i,v in ipairs( self.m_active_cfg ) do
        -- 定位上次选中的活动
        -- cclog2(game_data:getLeatestActivityIndex(), "game_data:getLeatestActivityIndex()   ====   ")
        -- cclog2(v.activeIndex, "v.activeIndex   ====   ")
        if game_data.getLeatestActivityIndex and v.activeIndex == game_data:getLeatestActivityIndex() then
            self.m_cur_selectitem_index = math.max(i - 1, 0)
        end
    end
end

--[[
    -- 给活动排序
]] 
function game_activity_new_pop.sortActiveData( self )
    -- 还没做
end

--[[--
    初始化
]]
function game_activity_new_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = util_json:new(t_params.gameData:getFormatBuffer());--json.decode(t_params.gameData:getFormatBuffer()) or {};
    end
    self.vip_index = t_params.vip_index or 1
    self.chapterID_index = {}
    self.m_cur_selectitem_index = 0
    self.initItemIndex = t_params.itemIndex
    self.initChapterID = t_params.chapterID
    -- self.m_active_cfg = getConfig(game_config_field.active_cfg)
    self:formatActiveData()
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_new_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:resetActivityTabPos()
    return scene;
end

return game_activity_new_pop;