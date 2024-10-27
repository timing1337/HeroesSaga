
---  活动
local game_activity = {
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
};
--[[--
    销毁ui
]]
function game_activity.destroy(self)
    -- body
    cclog("-----------------game_activity destroy-----------------");
    self.m_table_view = nil;
    self.m_selected_index = nil;
    self.m_activity_pic = nil;
    self.m_open_label = nil;
    self.m_btn_use = nil;
    self.m_label_table = nil;
    self.m_text_table = nil;
    
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
end
--[[ 新手引导开启的table ]]
-- 110：无主之地 106：资源争夺战 108：每日挑战 109：极限挑战 105：马上有经验 107：生存大考验  115 献祭
local openActivityTab = { item3 = 110,item4 = 106,item5 = 108, item6 = 109,item7 = 105,item8 = 107, item9 = 115}

--[[--
    返回
]]
function game_activity.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
	self:destroy();
end

function game_activity.reEnter(self)
    if self.m_isOpen == false then
        return 
    end

    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_activity",{gameData = gameData})
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end
--[[--
    读取ccbi创建ui
]]
function game_activity.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/activity_add.plist")
    if luaCCBNode.addPublicResource then
        luaCCBNode:addPublicResource("ccbResources/public_res_add.plist");
    end
    self.m_isOpen = true
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            self:back()
        elseif btnTag == 101 then--参战或未开启
            local btnId = openActivityTab["item" .. self.m_selected_index]
            if btnId and not game_button_open:checkButtonOpen(btnId) then
                return;
            end
            local active_cfg = self.m_active_cfg[self.m_selected_index]
            cclog2(active_cfg, "active_cfg  ====  ")
            local chapterID = active_cfg.active_chapterID[1]--根据chapterId来判断跳转
            --[[
            if self.m_selected_index == 1 then--周活动
                if self.m_access_flag.week_flag == 0 then--可领取
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        cclog("data == " .. data:getFormatBuffer())
                        local reward = data:getNodeWithKey("reward")
                        game_util:rewardTipsByJsonData(reward);

                        self.m_access_flag.week_flag = 1
                        self:setActiveContent(self.m_selected_index)
                        self.btn_use:setEnabled(false);
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("get_award"), http_request_method.GET, {tp = "week"},"get_award")
                elseif self.m_access_flag.week_flag == 1 then--已领取

                elseif self.m_access_flag.week_flag == 2 then--充值
                    -- chongzhiFunc(2)
                end
            elseif self.m_selected_index == 2 then--月活动
                if self.m_access_flag.month_flag == 0 then--领取
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        local reward = data:getNodeWithKey("reward")
                        game_util:rewardTipsByJsonData(reward);

                        self.m_access_flag.month_flag = 1
                        self:setActiveContent(self.m_selected_index)
                        self.btn_use:setEnabled(false);
                        self:refreshUi()
                        -- self.btn_use:setTitleForState(title,CCControlStateDisabled)
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("get_award"), http_request_method.GET, {tp = "month"},"get_award")
                elseif self.m_access_flag.month_flag == 1 then
                    
                elseif self.m_access_flag.month_flag == 2 then
                    -- chongzhiFunc(1)
                end
            elseif self.m_selected_index == 3 then--生存物资    
            ]]--
            if  self.m_selected_index == 2 then--世界boss
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
                            game_util:addMoveTips({text = string_helper.game_activity.text});
                        else
                            game_util:addMoveTips({text = string_helper.game_activity.text2});
                        end
                    else
                        game_scene:enterGameUi("game_world_boss",{gameData = gameData})
                        self:destroy()
                    end
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
            elseif self.m_selected_index == 3 then--中立地图
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_neutral_map",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_index"), http_request_method.GET, nil,"public_city_index")
            elseif self.m_selected_index == 8 then--生存大考验
            -- elseif self.m_selected_index == 9 then--生存大考验
                game_scene:enterGameUi("game_activity_live",{liveData = self.live_data})
                self:destroy();
            elseif self.m_selected_index == 9 then--献祭
                self:openOfferingSacrifices();
            else
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
                                game_util:addMoveTips({text = string_helper.game_activity.text3})
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
                                    game_util:addMoveTips({text = string_helper.game_activity.text4})
                                end
                            end
                        end
                    end
                else
                    game_util:addMoveTips({text = downLimit .. string_helper.game_activity.text5})
                end
            end
        elseif btnTag == 102 then--查看奖励
            if self.m_selected_index == 1 then
            elseif self.m_selected_index == 2 then
                local t_params = {}
                game_scene:addPop("game_month_gift_pop",t_params)
            elseif self.m_selected_index == 7 then

            elseif self.m_selected_index == 8 then

            end
        elseif btnTag == 103 then--领取物资
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                cclog("reward_gift_award data=="..data:getFormatBuffer())
                local reward = data:getNodeWithKey("reward");
                game_util:rewardTipsByJsonData(reward);

                self.m_get_gift:setEnabled(false)
                title = CCString:create(tostring(string_helper.game_activity.text6));
                self.m_get_gift:setTitleForState(title,CCControlStateDisabled)
                self.m_get_gift:setTitleColorForState(ccc3(192,192,192),CCControlStateDisabled)

                self.reward_flag = 0 
                self:refreshUi()
            end
            local params = {}
            params.award_id = self.m_reward_id
            cclog("self.m_reward_id == " .. self.m_reward_id)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_gift_award"), http_request_method.GET, params,"reward_gift_award")
        elseif btnTag == 500 then--boss排行榜
            local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("game_new_rank",{gameData = gameData,index = 7})
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("top_world_boss_hurt"), http_request_method.GET, {page = 0},"top_world_boss_hurt",true,true)
            -- local ui_all_rank = require("game_ui.ui_all_rank")
            -- ui_all_rank.enterAllRankByRankName( "rank_boss", nil, {openType = "game_activity"} )
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_activity.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node")
    self.m_activity_pic = ccbNode:spriteForName("sprite_activity_pic")
    self.m_open_label = ccbNode:labelBMFontForName("activity_open_label")
    self.btn_use = ccbNode:controlButtonForName("btn_use")
    self.m_text_table = ccbNode:nodeForName("text_table_node")
    self.m_btn_reward = ccbNode:nodeForName("btn_reward")
    self.m_alpha_back = ccbNode:scale9SpriteForName("alpha_back")
    self.m_get_gift = ccbNode:controlButtonForName("btn_get_gift")
    self.left_times_label = ccbNode:labelTTFForName("left_times_label")
    self.btn_look_2 = ccbNode:controlButtonForName("btn_look_2")
    self.falsh_blindness = ccbNode:spriteForName("falsh_blindness")

    self.btn_rank = ccbNode:controlButtonForName("btn_rank")
    self.falsh_blindness:runAction(game_util:createRepeatForeverFade());
    self.falsh_blindness:setVisible(false)

    self.m_get_gift:setVisible(false);
    if self.vip_index == 9 then
        self.m_selected_index = 2
    else
        self.m_selected_index = 1
    end

    if self.initItemIndex then
        self.m_selected_index = self.initItemIndex
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
        self.others_index = json.decode(others:getFormatBuffer())
        if search_treasure then
            self.search_treasure = json.decode(search_treasure:getFormatBuffer())
        end
        for i=1,others:getNodeCount() do
            local indexItem = others:getNodeAt(i-1)
            local index_key = indexItem:getKey()
            table.insert(self.chapterID_index,tonumber(index_key))
        end
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
            title = CCString:create(tostring(string_helper.game_activity.text7));

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
        self:setActiveContent(self.m_selected_index)
        cclog("self.m_access_flag 1 = " .. json.encode(self.m_access_flag))
    end
    --联网取数据
    local function netForReward()
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        responseMethod("active_index",self.m_gameData)
    end
    netForReward()
    return ccbNode;
end


function game_activity.openOfferingSacrifices(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_offering_sacrifices",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("sacrifice_index"), http_request_method.GET, nil,"sacrifice_index")
end


--[[
    设置内容
]]--
function game_activity.setActiveContent(self,index)
    --[[
        新活动顺序：去掉周活动和月活动
    ]]
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local active_cfg = self.m_active_cfg[index]
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
    -- if index == 2 or index == 1 then
    if index == 2 then
        -- self.m_btn_reward:setVisible(true)
        -- self.btn_look_2:setVisible(true)
    else
        -- self.m_btn_reward:setVisible(false)
        -- self.btn_look_2:setVisible(false)
    end
    self.btn_look_2:setVisible(false)
    if index == 2 then
        self.btn_rank:setVisible(true)
    else
        self.btn_rank:setVisible(false)
    end
    -- if index == 7 or index == 8 then
    --     self.m_btn_reward:setVisible(true)
    -- end
    local tempSpr = CCSprite:create(tostring("ccbResources/"..active_banner..".png"));
    if tempSpr then  
        self.m_activity_pic:setDisplayFrame(tempSpr:displayFrame())
    end
    self.btn_use:setEnabled(true);
    self.btn_use:setColor(ccc3(255,255,255));
    local title = nil;
    -- 1：生存物资 2：boss 3：无主之地 4：资源争夺战 5-6 动态活动 7：马上有经验 8：生存大考验
    if self.m_selected_index == 1 then--生存物资
        self.m_get_gift:setVisible(true);
        self.btn_use:setVisible(false);
    else
        self.m_get_gift:setVisible(false);
        self.btn_use:setVisible(true);
    end
    --[[
    if self.m_selected_index == 1 then--周活动
        if self.m_access_flag.week_flag == 0 then
            title = CCString:create(tostring("领奖"));
        elseif self.m_access_flag.week_flag == 1 then
            title = CCString:create(tostring("领奖"));
            self.btn_use:setEnabled(false);
            self.btn_use:setTitleForState(title,CCControlStateDisabled)
        else
            title = CCString:create(tostring("购买"));
        end
        --从vip条转过来的
        if self.vip_index == 8 then
            self.falsh_blindness:setVisible(true)
        end
    elseif self.m_selected_index == 2 then--月活动
        if self.m_access_flag.month_flag == 0 then
            title = CCString:create(tostring("领奖"));
        elseif self.m_access_flag.month_flag == 1 then
            title = CCString:create(tostring("领奖"));
            self.btn_use:setEnabled(false);
            self.btn_use:setTitleForState(title,CCControlStateDisabled)
        else
            title = CCString:create(tostring("购买"));
        end
        if self.vip_index == 9 then
             self.falsh_blindness:setVisible(true)
        end
        ]]
    -- elseif self.m_selected_index == 3 then--生存物资

    -- cclog2(self.m_selected_index, "self.m_selected_index   ===  ")
    if self.m_selected_index == 2 then--世界boss
        title = CCString:create(tostring(string_helper.game_activity.text8));
    elseif self.m_selected_index == 8 then--生存大考验
        title = CCString:create(tostring(string_helper.game_activity.text8));
    elseif self.m_selected_index == 9 then
        title = CCString:create(tostring(string_helper.game_activity.text9))
    else
        title = CCString:create(tostring(string_helper.game_activity.text8));
    end
    -- cclog2(title, "title   ===  ")
    --活动需要判断等级的
    if self.m_selected_index > 3 and self.m_selected_index < 8 then
        local active_cfg = self.m_active_cfg[self.m_selected_index]
        local chapterID = active_cfg.active_chapterID[1]--根据chapterId来判断跳转
        if tolua.type(chapterID) == "table" then
            chapterID = self:getMyChapterId(active_cfg)
        end
        -- cclog("chapterID == " .. chapterID)
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
            self.left_times_label:setString(string_helper.game_activity.text10.. (fight_times-cur_times) .. "/" .. fight_times)
        else
            game_util:addMoveTips({text = downLimit .. string_helper.game_activity.text11})
        end
    -- elseif self.m_selected_index == 9 then
    --     local btnId = openActivityTab["item" .. self.m_selected_index]
    --     if btnId and not game_button_open:checkButtonOpen(btnId) then

    --     end
    --     self.left_times_label:setVisible(false)
    else
        self.left_times_label:setVisible(false)
    end  
    local btnId = openActivityTab["item" .. self.m_selected_index]
    if btnId and not game_button_open:getOpenFlagByBtnId(btnId) then
        self.btn_use:setColor(ccc3(81,81,81));
    end
    self.btn_use:setTitleForState(title,CCControlStateNormal)
end
--[[--
    刷新ui
]]
function game_activity.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    if #self.m_active_cfg <= 10 then
        tableViewTemp:setMoveFlag(false)
    else
        tableViewTemp:setMoveFlag(true)
    end
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
function game_activity.getMyChapterId(self,active_cfg,enter_type)
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
    创建活动滑动列表
]]--
function game_activity.createTableView( self,viewSize )
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local reward_list = {self.m_access_flag.week_flag,self.m_access_flag.month_flag,self.reward_flag,self.m_access_flag.boss_flag}
    cclog("reward_list = " .. json.encode(reward_list))
    local activityCount = #self.m_active_cfg
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 2; --列
    params.itemActionFlag = false;
    params.totalItem = activityCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_activity_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2));
            cell:addChild(ccbNode,10,10);
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local sprite_selected = ccbNode:spriteForName("sprite_selected")
            local sprite_btn = ccbNode:spriteForName("activity_btn")
            local active_cfg = self.m_active_cfg[index+1]

            local myChapterId = self:getMyChapterId(active_cfg)
            -- cclog("index == " .. index .. "myChapterId == " .. myChapterId)
            local active_btn = active_cfg.button
            -- cclog("active_btn 111 == " .. active_btn)
            if myChapterId >= 100 then
                local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
                active_btn = itemCfg:getNodeWithKey("button"):toStr()
            else

            end
            -- cclog("active_btn 222 == " .. active_btn)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(active_btn..".png"))
            if tempSpriteFrame then
                sprite_btn:setDisplayFrame(tempSpriteFrame);
            end
            local btnId = openActivityTab["item" .. (index+1)]
            if btnId and not game_button_open:getOpenFlagByBtnId(btnId) then
                sprite_btn:setColor(ccc3(81,81,81));
            end
            -- if index == 0 and self.m_access_flag.week_flag == 0 then--可领取提示
            --     game_util:addTipsAnimByType(ccbNode,9);
            --     game_util:createPulseAnmi(tostring(active_btn..".png"),sprite_btn)
            -- elseif index == 1 and self.m_access_flag.month_flag == 0 then
            --     game_util:addTipsAnimByType(ccbNode,9);
            --     game_util:createPulseAnmi(tostring(active_btn..".png"),sprite_btn)
            if index == 0 and self.reward_flag == 1 then--物资可领的动画
                game_util:addTipsAnimByType(ccbNode,9);
                game_util:createPulseAnmi(tostring(active_btn..".png"),sprite_btn)
            elseif game_button_open:getOpenFlagByBtnId(btnId) and index == 1 and self.m_access_flag.boss_flag == 1 then--boss可打的动画
                game_util:addTipsAnimByType(ccbNode,9);
                game_util:createPulseAnmi(tostring(active_btn..".png"),sprite_btn)
            end

            if self.initChapterID then
                if self.initChapterID == myChapterId then
                    sprite_selected:setVisible(true)
                    self.m_selected_index = index + 1
                    self.initChapterID = nil
                else
                    sprite_selected:setVisible(false)
                end

            else
                if index == self.m_selected_index - 1 then
                    sprite_selected:setVisible(true)
                else
                    sprite_selected:setVisible(false)
                end  
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            if index+1 ~= self.m_selected_index then
                self.m_selected_index = index+1
                self:setActiveContent(self.m_selected_index)
                self:refreshUi()
                -- self:refreshActivityContent(index+1)
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建文字table view
]]--
function game_activity.createTextTableView(self,viewSize)
    local chapterCfg = getConfig(game_config_field.active_chapter)
    local textCount = 1;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 1; --列
    params.totalItem = textCount;
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()

        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();        
            local active_text
            local active_cfg = self.m_active_cfg[self.m_selected_index]
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
            local tempLabel = game_util:createLabelTTF({text = active_text,color = ccc3(196,197,147)})
            tempLabel:setDimensions(CCSizeMake(280,80))
            tempLabel:setAnchorPoint(ccp(0.5,0.5))
            tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2))
            tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            cell:addChild(tempLabel)    
        end
        return cell;
    end
    return TableViewHelper:create(params);
end

--[[--
    初始化
]]
function game_activity.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = util_json:new(t_params.gameData:getFormatBuffer());--json.decode(t_params.gameData:getFormatBuffer()) or {};
    end
    -- self.m_active_cfg = getConfig(game_config_field.active_cfg)
    self.m_active_cfg = {}
    --根据is_see 排序
    local activeCfg = getConfig(game_config_field.active_cfg)
    for i=1,activeCfg:getNodeCount() do
        local itemCfg = activeCfg:getNodeWithKey(tostring(10*i))
        local is_see = itemCfg:getNodeWithKey("is_see"):toInt()
        if is_see == 1 then
            table.insert(self.m_active_cfg,json.decode(itemCfg:getFormatBuffer()))
        end
    end
    --新版，去掉根据is_see，不排序
    -- self.m_active_cfg = json.decode(activeCfg:getFormatBuffer())
    self.vip_index = t_params.vip_index or 1
    self.chapterID_index = {}

    self.initItemIndex = t_params.itemIndex
    self.initChapterID = t_params.chapterID
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());

    -- local id = game_guide_controller:getIdByTeam("66");
    -- id = 6601 
    -- print("game_guide_controller:getIdByTeam(66)", id)
    -- if id == 6601 then
    --     self.initItemIndex = 6
    --     game_guide_controller:gameGuide("drama","66",6601)
    --     -- game_guide_controller:gameGuide("drama","19",1901)
    --     -- self:refreshUi();
    -- end
    return scene;
end

return game_activity;