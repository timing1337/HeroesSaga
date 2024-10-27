---  新竞技场
local game_arena = {
    m_game_data = nil,
    m_arena_node = nil,
    m_challenge_table_node = nil,
    m_user_node = nil,
    m_reward_time_label = nil,
    m_rest_tiems_label = nil,
    m_reward_count_label = nil,
    m_self_rank_label = nil,
    m_self_point_label = nil,
    m_fight_power_label = nil,

    m_rank_node= nil,
    m_rank_table_node = nil,

    m_index = nil,

    btn_challenge = nil,
    btn_rank = nil,
    tips_label = nil,
    tips_label2 = nil,
    tips_sprite = nil,
    rank_page = nil,
    first_flag = nil,
    top_info = nil,
    m_guideFlag = nil,
    m_guildNode = nil,
};
--[[--
    销毁ui
]]
function game_arena.destroy(self)
    -- body
    cclog("-----------------game_arena destroy-----------------");
    self.m_game_data = nil;
    self.m_arena_node = nil;
    self.m_challenge_table_node = nil;
    self.m_user_node = nil;
    self.m_reward_time_label = nil;
    self.m_rest_tiems_label = nil;
    self.m_reward_count_label = nil;
    self.m_self_rank_label = nil;
    self.m_self_point_label = nil;
    self.m_fight_power_label = nil;
    --排行榜的控件
    self.m_rank_node = nil;
    self.m_rank_table_node = nil;
    self.m_index = nil;

    self.btn_challenge = nil; 
    self.btn_rank = nil;
    self.tips_label = nil;
    self.tips_label2 = nil;
    self.tips_sprite = nil;
    self.rank_page = nil;
    self.first_flag = nil;
    self.top_info = nil;
    self.m_guideFlag = nil;
    self.m_guildNode = nil;
end
--[[--
    返回
]]
function game_arena.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_arena.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 3 then--切换
            self.m_index = 1
            self:refreshUi()
        elseif btnTag == 4 then
            self.m_index = 2
            self:refreshUi()
        elseif btnTag == 202 then--商店兑换 
            game_scene:enterGameUi("game_arena_shop",{m_gameData = self.m_game_data.exchange_log,point = self.m_game_data.point})
            self:destroy()
        elseif btnTag == 201 then--战报
            game_scene:addPop("ui_batter_info_pop",{log_info = self.m_game_data.log,openType = 1});
        elseif btnTag == 110 then--拨打110
            -- local item_count = game_data:getItemCountByCid("80000")

            -- local function responseMethod(tag,gameData)
            --     local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
            --     if rewardCount and rewardCount == 0 then
            --         game_util:addMoveTips({text = "增加成功!"});
            --         -- self:initArenaScene()
            --         self.m_game_data.can_battle_times = self.m_game_data.can_battle_times + 1
            --         self.m_rest_tiems_label:setString(tostring(self.m_game_data.can_battle_times .. "/10"))
            --     end
            -- end
            -- local function responseBuyMethod(tag,gameData)
            --     -- local data = gameData:getNodeWithKey("data");
            --     -- game_util:rewardTipsByJsonData(data:getNodeWithKey("goods"));
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = "80000",num = 1},"item_use")
            -- end
            -- if item_count > 0 then
            --     --使用道具
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = "80000",num = 1},"item_use")
            -- else
            --     local t_params = 
            --     {
            --         title = string_config.m_title_prompt,
            --         okBtnCallBack = function(target,event)
            --             local params = {};
            --             params.shop_id = "4";--购买用的是 shop id 使用道具用的是道具 id 
            --             params.count = "1";
            --             network.sendHttpRequest(responseBuyMethod,game_url.getUrlForKey("shop_buy"), http_request_method.GET, params,"shop_buy")
            --             game_util:closeAlertView();
            --         end,   --可缺省
            --         okBtnText = "确定",
            --         text = string_config.m_add_arena_time,
            --     }
            --     game_util:openAlertView(t_params);
            -- end
            local vipCfg = getConfig(game_config_field.vip);
            local vip_level = game_data:getVipLevel();
            local nowCfg = vipCfg:getNodeWithKey(tostring(vip_level));
            local buy_limit = nowCfg:getNodeWithKey("buy_arena"):toInt()
            if buy_limit > self.m_game_data.buy_count then
                local function responseBuyMethod(tag,gameData)
                    game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
                    game_util:addMoveTips({text = string_helper.game_arena.challage_num});
                    self.m_game_data.can_battle_times = self.m_game_data.can_battle_times + 1
                    self.m_rest_tiems_label:setString(tostring(self.m_game_data.can_battle_times .. "/10"))

                    self.m_game_data.buy_count = self.m_game_data.buy_count + 1
                end
                local payCfg = getConfig(game_config_field.pay)
                local reviveCfg = payCfg:getNodeWithKey("3"):getNodeWithKey("coin")
                local time = self.m_game_data.buy_count
                if time >= reviveCfg:getNodeCount() then
                    time = reviveCfg:getNodeCount() - 1
                end
                cclog("self.m_game_data.buy_count == " .. self.m_game_data.buy_count)
                cclog("time == " .. time)
                cclog("reviveCfg == " .. reviveCfg:getFormatBuffer())
                local coin = reviveCfg:getNodeAt(time):toInt()
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        local params = {};
                        network.sendHttpRequest(responseBuyMethod,game_url.getUrlForKey("arena_buy_count"), http_request_method.GET, params,"arena_buy_count")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_helper.game_arena.ok,
                    text = string_helper.game_arena.text .. coin .. string_helper.game_arena.text2
                }
                game_util:openAlertView(t_params);
            else
                game_util:addMoveTips({text = string_helper.game_arena.text3});
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_arena.ccbi");

    --挑战的控件
    self.m_arena_node = ccbNode:nodeForName("m_arena_node_1");
    self.m_challenge_table_node = ccbNode:nodeForName("m_tab_node_1");
    self.m_user_node = ccbNode:nodeForName("m_pk_icon");
    self.m_reward_time_label = ccbNode:labelTTFForName("m_reward_time");--奖励时间
    self.m_rest_tiems_label = ccbNode:labelBMFontForName("m_pk_count");--剩余挑战次数
    self.m_reward_count_label = ccbNode:labelBMFontForName("m_pk_point");--挑战奖励
    self.m_self_rank_label = ccbNode:labelBMFontForName("m_pk_place");--自己的排名
    self.m_self_point_label = ccbNode:labelBMFontForName("m_self_pk_point");--自己的竞技点数
    self.m_fight_power_label = ccbNode:labelBMFontForName("fight_power_point");--战斗力
    self.tips_label = ccbNode:labelTTFForName("tips_label_1")--tips
    self.tips_label2 = ccbNode:labelTTFForName("tips_label_2")
    self.tips_sprite = ccbNode:nodeForName("tips_node")

    --排行榜的控件
    self.m_rank_node = ccbNode:nodeForName("m_arena_node_2");
    self.m_rank_table_node = ccbNode:nodeForName("rank_table_node");

    --控制的按钮
    self.btn_challenge = ccbNode:controlButtonForName("m_tab_btn_2");
    self.btn_rank = ccbNode:controlButtonForName("m_tab_btn_3");

    game_util:setCCControlButtonTitle(self.btn_challenge,string_helper.ccb.text57)
    game_util:setCCControlButtonTitle(self.btn_rank,string_helper.ccb.text58)
    return ccbNode;
end
--[[--
    刷新ui
]]
--[[
    创建竞技场挑战列表
]]
function game_arena.createFightTableView(self,viewSize)
    self.m_guildNode = nil;
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 1000 and btnTag < 1100 then
            if self.m_guideFlag == true then--新手引导默认固定打一场
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("game_pk");
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                    self:destroy();
                end
                if self.m_game_data.can_battle_times > 0 then
                    game_data:setUserStatusDataBackup();
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_battle"), http_request_method.GET, {rank=1000,test_robot = "robot_1000"},"arena_battle");
                end
                return;
            end
            local index = btnTag - 1000
            if self.m_game_data.front_user[index] == nil then return end
            game_data:setUserStatusDataBackup()
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_pk");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end

            if self.m_game_data.can_battle_times > 0 then
                game_data:setUserStatusDataBackup();
                local tempUser = self.m_game_data.front_user[index];
                -- cclog("tempUser = " .. json.encode(tempUser))
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_battle"), http_request_method.GET, {target=tempUser.uid,rank=tempUser.rank},"arena_battle");
            else
                local vipCfg = getConfig(game_config_field.vip);
                local vip_level = game_data:getVipLevel();
                local nowCfg = vipCfg:getNodeWithKey(tostring(vip_level));
                local buy_limit = nowCfg:getNodeWithKey("buy_arena"):toInt()
                if buy_limit > self.m_game_data.buy_count then
                    local function responseBuyMethod(tag,gameData)
                        game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
                        game_util:addMoveTips({text = string_helper.game_arena.challage_num_success});
                        self.m_game_data.can_battle_times = self.m_game_data.can_battle_times + 1
                        self.m_rest_tiems_label:setString(tostring(self.m_game_data.can_battle_times .. "/10"))
                        self.m_game_data.buy_count = self.m_game_data.buy_count + 1
                        game_scene:removePopByName("game_normal_tips_pop");
                    end
                    local payCfg = getConfig(game_config_field.pay)
                    local reviveCfg = payCfg:getNodeWithKey("3"):getNodeWithKey("coin")
                    local time = self.m_game_data.buy_count
                    if time >= reviveCfg:getNodeCount() then
                        time = reviveCfg:getNodeCount() - 1
                    end
                    local coin = reviveCfg:getNodeAt(time):toInt()
                    --统一提示
                    local t_params = 
                    {
                        m_openType = 9,
                        time = time,
                        coin = coin,
                        m_ok_func = function()
                            network.sendHttpRequest(responseBuyMethod,game_url.getUrlForKey("arena_buy_count"), http_request_method.GET, nil,"arena_buy_count")
                        end,
                        add_call_func = function()
                            self.m_game_data.can_battle_times = self.m_game_data.can_battle_times + 1
                            self.m_rest_tiems_label:setString(tostring(self.m_game_data.can_battle_times .. "/10"))
                        end,
                    }
                    game_scene:addPop("game_normal_tips_pop",t_params)
                else
                    game_util:addMoveTips({text = string_helper.game_arena.text3});
                end
            end
        elseif btnTag > 1100 then
            local index = btnTag - 1100
            local tempUid = self.m_game_data.front_user[index].uid;
            if self.m_game_data.front_user[index] == nil then return end
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        end
    end
    local front_user = self.m_game_data.front_user
    local fightCount = #front_user;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local sb_name_show = {}
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_arena_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local user_rank_label = ccbNode:labelTTFForName("m_rank_label");
            local user_name_label = ccbNode:labelTTFForName("m_name_label");
            local fight_count_label = ccbNode:labelBMFontForName("fight_power_point");

            local btn_fight = ccbNode:controlButtonForName("btn_fight");
            local btn_look = ccbNode:controlButtonForName("btn_look");

            btn_fight:setTag(1001 + index)
            btn_look:setTag(1101 + index)
            btn_look:setOpacity(0)

            local user_info = front_user[index + 1];

            user_rank_label:setString(string_helper.game_arena.rank .. user_info.rank )
            user_name_label:setString(tostring(user_info.name));
            
            for i=1,4 do
                sb_name_show[i] = ccbNode:labelTTFForName("m_name_label_" .. i)
                sb_name_show[i]:setString(tostring(user_info.name));
            end
            local icon = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            fight_count_label:setString(tostring(user_info.combat));
            if self.m_guildNode == nil and index == 3 then
                cell:setContentSize(itemSize);
                self.m_guildNode = btn_fight;
            end
        end
        cell:setTag(1001 + index);
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建竞技场排行榜列表
]]
function game_arena.createRankTableView(self,viewSize)
    -- local rank_info = self.m_game_data.top
    local rank_info = self.top_info
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();        
        local index = btnTag - 1000
        local tempUid = rank_info[index].uid;
        if self.top_info[index] == nil then return end
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_player_info_pop",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
    end
    -- cclog("rank_info == " .. json.encode(rank_info))
    local frame_name = {"arena_gold.png","arena_silver.png","arena_copper.png"}
    local fightCount = #rank_info;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local sb_name = {}
    local sb_guild = {}
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local user_rank_label = ccbNode:labelBMFontForName("rank_number");
            local user_name_label = ccbNode:labelTTFForName("m_user_label");
            local fight_count_label = ccbNode:labelBMFontForName("fight_point_label");
            local top_icon = ccbNode:spriteForName("top_icon");
            local guild_name_label = ccbNode:labelTTFForName("m_guild_label");
            local btn_look = ccbNode:controlButtonForName("btn_look")

            btn_look:setTag(1001 + index)
            btn_look:setOpacity(0)

            local user_info = rank_info[index + 1];
            user_rank_label:setString(tostring(index + 1));
            if index >= 0 and index < 3 then
                top_icon:setVisible(true);
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(frame_name[index + 1]))
                top_icon:setDisplayFrame(tempSpriteFrame);
            else
                top_icon:setVisible(false);
            end
            user_name_label:setString(tostring(user_info.name));
            local guild_show = ""
            if user_info.guild_name == "" then
                guild_show = string_helper.game_arena.wu
            else
                guild_show = tostring(user_info.guild_name)
            end
            guild_name_label:setString(guild_show)  
            
            for i=1,4 do
                sb_name[i] = ccbNode:labelTTFForName("m_user_label_" .. i);
                sb_name[i]:setString(tostring(user_info.name));
                sb_guild[i] = ccbNode:labelTTFForName("m_guild_label_" .. i);
                sb_guild[i]:setString(guild_show)  
            end
            local icon = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            fight_count_label:setString(tostring(user_info.combat));
            if index == fightCount - 1 and self.rank_page < 4 then
                local tipLabel = game_util:createLabelTTF({text = string_helper.game_arena.down_refresh,color = ccc3(250,180,0),fontSize = 12});
                tipLabel:setAnchorPoint(ccp(0.5,0.5))
                tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                cell:addChild(tipLabel,20,20)
            else
                local tempNode = cell:getChildByTag(20)
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then
            cclog("ssssss")
            if self.rank_page < 4 then
                self.rank_page = self.rank_page + 1
                self:requestForHttp()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新
]]
function game_arena.refreshUi(self)
    local flag1 = self.m_index == 1 and true or false
    local flag2 = self.m_index == 2 and true or false

    self.m_arena_node:setVisible(flag1);
    self.m_rank_node:setVisible(flag2);

    self.btn_challenge:setHighlighted(flag1);
    self.btn_challenge:setEnabled(not flag1);
    self.btn_rank:setHighlighted(flag2);
    self.btn_rank:setEnabled(not flag2);
    if self.m_index == 1 then
        self:initArenaScene();
    else
        self:initRankScene();
    end
end
--[[
    初始化竞技场
]]
function game_arena.initArenaScene(self)
    local user = game_util:createOwnBigImg()
    user:setAnchorPoint(ccp(0.5,0.5))
    user:setScale(0.35)
    self.m_user_node:removeAllChildrenWithCleanup(true)
    self.m_user_node:addChild(user,10,10)
    --倒计时回调函数
    local function timeEndFunc(label,type)
        
    end
    local time_need = self.m_game_data.award_expire
    self.m_reward_time_label:setString("")
    local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8,2);
    countdownLabel:setPosition(ccp(-countdownLabel:getContentSize().width*0.5,self.m_reward_time_label:getContentSize().height*0.5))
    if self.m_reward_time_label ~= nil then
        self.m_reward_time_label:removeAllChildrenWithCleanup(true)
    end
    self.m_reward_time_label:addChild(countdownLabel)
    countdownLabel:setTime(time_need);

    self.m_rest_tiems_label:setString(tostring(self.m_game_data.can_battle_times .. "/10"))
    -- self.m_reward_count_label:
    self.m_self_rank_label:setString(tostring(self.m_game_data.rank))

    local icon,tips1,tips2 = self:getTipsText(self.m_game_data.rank)
    if icon then
        icon:setScale(0.33)
        icon:setAnchorPoint(ccp(0.5,0.5))
        self.tips_sprite:addChild(icon)
    end
    if tips1 then
        self.tips_label:setString(tips1)
    end
    if tips2 then
        self.tips_label2:setString(tips2)
    end

    -- self.m_self_rank_label:setString(tips)

    self.m_self_point_label:setString(tostring(self.m_game_data.point))
    self.m_fight_power_label:setString(tostring(self.m_game_data.combat))

    local arenaRewardCfg = getConfig(game_config_field.arena_award);
    local rewardCount = arenaRewardCfg:getNodeCount()
    local reward_value = 1

    for i=1,rewardCount do
        local item = arenaRewardCfg:getNodeAt(i-1)
        local start_rank = item:getNodeWithKey("start_rank"):toInt()
        local end_rank = item:getNodeWithKey("end_rank"):toInt()

        if start_rank <= self.m_game_data.rank and self.m_game_data.rank <= end_rank then
            reward_value = item:getNodeWithKey("per_point"):toInt()
            break;
        end 
    end
    self.m_reward_count_label:setString(tostring(reward_value))

    self:refreshTab1()
end
--[[
    得到文字信息
]]
function game_arena.getTipsText(self,rank)
    local rankCfg = getConfig(game_config_field.arena_award_milestone)
    local myLevel = 1
    for i=1,rankCfg:getNodeCount() do
        local start_rank = rankCfg:getNodeWithKey(tostring(i)):getNodeWithKey("rank"):toInt()
        local end_rank = 1
        local nextRank = i + 1
        if nextRank < rankCfg:getNodeCount() then
            end_rank = rankCfg:getNodeWithKey(tostring(nextRank)):getNodeWithKey("rank"):toInt()
        else
            end_rank = 1
        end
        if start_rank < rank and rank >= end_rank then
            myLevel = i
            break
        end
    end
    local itemCfg = rankCfg:getNodeWithKey(tostring(myLevel))
    if itemCfg == nil then
        self.tips_label:setVisible(false)
        self.tips_label2:setVisible(false)
        self.tips_sprite:setVisible(false)
    else
        local reward = itemCfg:getNodeWithKey("reward"):getNodeAt(0)
        local nextRew = itemCfg:getNodeWithKey("rank"):toInt()
        local icon,name,count = game_util:getRewardByItem(reward)
        name = string_helper.game_arena.advance .. nextRew .. string_helper.game_arena.rank_gain
        count = "×" .. count
        if icon then
            -- icon:setScale(0.33)
            return icon,name,count
        end
    end
    return nil,nil,nil
end
--[[
    初始化排行榜
]]
function game_arena.initRankScene(self)
    if self.first_flag == true then
        self:requestForHttp()
    else
        self:refreshTab2()
    end
end
--[[
    请求排行榜
]]
function game_arena.requestForHttp(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local top = json.decode(data:getNodeWithKey("top"):getFormatBuffer())
        for i=1,#top do
            table.insert(self.top_info,top[i])
        end
        if self.first_flag == true then
            self.first_flag = false
        end
        self:refreshTab2()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_top"), http_request_method.GET, {page = self.rank_page},"arena_top")
end
--[[
    刷新表1
]]
function game_arena.refreshTab1(self)
    self.m_challenge_table_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createFightTableView(self.m_challenge_table_node:getContentSize())
    tempTable:setScrollBarVisible(false)
    tempTable:setMoveFlag(false);
    self.m_challenge_table_node:addChild(tempTable);
end
--[[
    刷新表2
]]
function game_arena.refreshTab2(self)
    self.m_rank_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createRankTableView(self.m_rank_table_node:getContentSize())
    textTableTemp:setScrollBarVisible(false)
    self.m_rank_table_node:addChild(textTableTemp,10,10);

    local index = self.rank_page * 20
    game_util:setTableViewIndex(index,self.m_rank_table_node,10,4)
end
--[[--
    初始化
]]
function game_arena.init(self,t_params)
    t_params = t_params or {};
    self.top_info = {}
    self.m_game_data = t_params.gameData
    self.rank_page = 0
    self.first_flag = true
    -- cclog("self.m_game_data = " .. json.encode(self.m_game_data))
    self.m_index = 1;
    -- game_sound:playMusic("background_home",true);
    self.m_guideFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_arena.create(self,t_params)
    game_data:addOneNewButtonByBtnID(200)   -- 已经了解了竞技场功能
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("4");
    if id == 401 then
        self:gameGuide("drama","4",403)
    elseif id == 403 then
        self:gameGuide("drama","4",406)
    end
    return scene;
end

--[[
    新手引导
]]
function game_arena.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "4" and id == 403 then
            local function endCallFunc()
                if self.m_guildNode then
                    self.m_guideFlag = true;
                    game_guide_controller:gameGuide("show","4",403,{tempNode = self.m_guildNode})
                    -- game_guide_controller:gameGuide("send","4",403);
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "4" and id == 406 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","4",406);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return game_arena;