---  战前展示
local game_gvg_show = {
    guild_att_name = nil,
    guild_def_name = nil,
    war_flag_count = nil,
    war_flag_rank = nil,
    m_editBox1 = nil,
    left_time_node = nil,
    rank_node = nil,
    donate_flag = nil,
    sprite_title = nil,

    change_label = nil,
    btn_continue = nil,
    text_scroll = nil,
    open_times_label = nil,
    m_anim_node = nil,
    king_name_label = nil,
    stread_times_label = nil,
    m_tGameData = nil,
    sort = nil,
    time_label = nil,
    rank_sprite = nil,
    add_label = nil,
    tips_sprite = nil,
    per_node = nil,
};
--[[--
    销毁ui
]]
function game_gvg_show.destroy(self)
    cclog("----------------- game_gvg_show destroy-----------------"); 
    self.guild_att_name = nil;
    self.guild_def_name = nil;
    self.war_flag_count = nil;
    self.war_flag_rank = nil;
    self.m_editBox1 = nil;
    self.left_time_node = nil;
    self.rank_node = nil;
    self.donate_flag = nil;
    self.m_editBox1Node = nil;
    self.sprite_title = nil;
    ------
    self.change_label = nil;
    self.btn_continue = nil;
    self.text_scroll = nil;
    self.open_times_label = nil;
    self.m_anim_node = nil;
    self.king_name_label = nil;
    self.stread_times_label = nil;
    self.m_tGameData = nil;
    self.sort = nil;
    self.time_label = nil;
    self.rank_sprite = nil;
    self.add_label = nil;
    self.tips_sprite = nil;
    self.per_node = nil;
end
--[[--
    返回
]]
function game_gvg_show.back(self)
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        -- require("like_oo.oo_controlBase"):openView("guild_join");
        game_scene:enterGameUi("game_main_scene",{gameData = nil});
        self:destroy();
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_show.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 4 then--最大捐献
            
        elseif btnTag == 5 then--确定捐献
            
        elseif btnTag == 11 then--log
            game_scene:addPop("game_gvg_message_pop",{messages = self.m_tGameData.battle_info})
        elseif btnTag == 12 then--活动详情
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = "125"})
            game_scene:addPop("game_gvg_rules_pop",{m_comeInIndex = 0})
        elseif btnTag == 101 then--参战
            -- local function responseMethod(tag,gameData)
            --     game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公会战战中   布阵
            --     self:destroy()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing")
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local sort = data:getNodeWithKey("sort"):toInt()
                if sort == 1 then--外围战布阵开启
                    -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                    game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公会战战中   布阵
                elseif sort == 2 then--外围战战争开始
                    game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
                elseif sort == 3 then--内城布阵开始
                    -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                    game_scene:enterGameUi("game_gvg_war",{gameData = gameData})--公会战战中   布阵
                elseif sort == 4 then--内城战开始
                    game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
                elseif sort == 5 then
                    
                elseif sort == -1 then--公会战未开启
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                else
                    -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
                    local ready = data:getNodeWithKey("ready"):toInt()
                    local timeLeft = 30
                    if ready then
                        timeLeft = ready
                    end
                    game_util:addMoveTips({text = string_helper.game_gvg_show.text .. timeLeft .. string_helper.game_gvg_show.text2});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_embattle_doing"), http_request_method.GET, nil,"guild_gvg_embattle_doing")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_prewar.ccbi");

    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")--守城联盟

    self.open_times_label = ccbNode:labelTTFForName("open_times_label")--开战时间
    self.stread_times_label = ccbNode:labelTTFForName("stread_times_label")--连胜次数

    self.rank_node = ccbNode:nodeForName("rank_node")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")--角色role
    self.king_name_label = ccbNode:labelTTFForName("king_name_label")--mvp

    self.sprite_title = ccbNode:spriteForName("sprite_title")

    self.change_label = ccbNode:labelTTFForName("change_label")--可改变的label

    self.btn_continue = ccbNode:controlButtonForName("btn_continue");--参战按钮
    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.content_node = ccbNode:nodeForName("content_node")

    self.time_label = ccbNode:spriteForName("time_label")
    self.rank_sprite = ccbNode:spriteForName("rank_sprite")
    self.add_label = ccbNode:labelTTFForName("add_label")
    self.tips_sprite = ccbNode:scale9SpriteForName("tips_sprite")
    self.per_node = ccbNode:nodeForName("per_node")
    game_util:setControlButtonTitleBMFont(self.btn_continue)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text221)
    return ccbNode;
end

--[[
    排行榜
]]
function game_gvg_show.createRankTable(self,viewSize)
    local rankTable = self.m_tGameData.ranks
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
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

            local rankData = rankTable[index+1] or {}
            local name = rankData.name or ""
            local score = rankData.score or ""
            local rank = rankData.rank or ""

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
function game_gvg_show.refreshUi(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local role = self.m_tGameData.role
    local roleIcon = game_util:createPlayerBigImgByRoleId(role)
    roleIcon:setAnchorPoint(ccp(0.5,0))
    roleIcon:setScale(0.4)
    self.m_anim_node:addChild(roleIcon)
    --
    self.guild_def_name:setString(self.m_tGameData.ass_name)
    --
    self.stread_times_label:setString(self.m_tGameData.win_times)
    --
    self.king_name_label:setString(self.m_tGameData.name)
    --
    self.king_name_label:setString(self.m_tGameData.name)

    local start_time = self.m_tGameData.start_time
    local timeTab = os.date("*t",start_time)
    local hour = timeTab.hour
    local min = timeTab.min
    if hour < 10 then hour = "0" .. hour end
    if min < 10 then min = "0" .. min end
    local testMin = tonumber(timeTab.min) - 10
    local testHour = tonumber(timeTab.hour)
    if testMin < 0 then
        testHour = testHour - 1
        testMin = testMin + 60 
    end
    if testMin < 10 then testMin = "0" .. testMin end

    self.open_times_label:setString(timeTab.month .. "月" .. timeTab.day .. "日" .. " " .. hour .. ":" .. min)
    --排行榜
    self.rank_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.rank_node:getContentSize());
    self.rank_node:addChild(tableView,10,10);
    --改title
    if self.sort == 1 or self.sort == -1 or self.sort == -10 then
        self.sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_prepare.png"));
        self.rank_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_last_rank.png"));
        if self.sort == -1 then
            self.sprite_title:setVisible(false)
            -- self.rank_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_last_rank.png"));
        end
        -- self.sprite_end:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_beforewar.png"));
        self.time_label:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_war_time.png"))
        self.change_label:setString(string_helper.game_gvg_show.reward)

        local welfare = self.m_tGameData.welfare
        local welfareTxt = ""
        
        local itemWelfare_1 = welfare[tostring(1)]
        local status_1 = itemWelfare_1.status
        local timeTab1 = os.date("*t",itemWelfare_1.time)
        local hour1 = timeTab1.hour
        local min1 = timeTab1.min
        if hour1 < 10 then hour1 = "0" .. hour1 end
        if min1 < 10 then min1 = "0" .. min1 end
        if status_1 then
            -- if itemWelfare_1.is_global == 1 then
            --     welfareTxt = "1.全服玩家抽卡9折\n"
            -- else
            --     welfareTxt = "1." .. self.m_tGameData.ass_name .."联盟玩家抽卡9折\n"
            -- end
            -- welfareTxt = welfareTxt .. "（" .. (timeTab.month .. "月" .. timeTab.day .. "日" .. " " .. hour .. ":" .. min) .."结束）".. "\n"
            if itemWelfare_1.sort == 1 then
                welfareTxt = "1." .. self.m_tGameData.ass_name ..string_helper.game_gvg_show.text3
            elseif itemWelfare_1.sort == 2 then
                welfareTxt = string_helper.game_gvg_show.text4
            else
                welfareTxt = string_helper.game_gvg_show.text5
            end
            welfareTxt = welfareTxt .. "（" .. (timeTab1.month .. string_helper.game_gvg_show.month .. timeTab1.day .. string_helper.game_gvg_show.day .. " " .. hour1 .. ":" .. min1) ..string_helper.game_gvg_show.game_end.. "\n"
        end
        local itemWelfare_2 = welfare[tostring(2)]
        local status_2 = itemWelfare_2.status
        if status_2 then
            local timeTab2 = os.date("*t",itemWelfare_2.time)
            local hour2 = timeTab2.hour
            local min2 = timeTab2.min
            if hour2 < 10 then hour2 = "0" .. hour2 end
            if min2 < 10 then min2 = "0" .. min2 end
            welfareTxt = welfareTxt .. string_helper.game_gvg_show.text6
            welfareTxt = welfareTxt .. "（" .. (timeTab2.month .. string_helper.game_gvg_show .month .. timeTab2.day .. string_helper.game_gvg_show .day .. " " .. hour2 .. ":" .. min2) ..string_helper.game_gvg_show .game_end .. "\n"
        end

        local tempLabel = game_util:createRichLabelTTF({text = welfareTxt,dimensions = CCSizeMake(120,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
        local tempSize = tempLabel:getContentSize();
        self.text_scroll:setContentSize(CCSizeMake(120,tempSize.height))

        local viewSize = self.content_node:getContentSize()
        -- if tempSize.height > viewSize.height then
            self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
        -- end
        self.text_scroll:addChild(tempLabel)
    elseif self.sort == 3 or self.sort == - 11 then
        self.rank_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_now_rank.png"));
        self.sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_ing.png"));
        -- self.sprite_end:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_end.png"));
        self.time_label:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_seconf_half.png"))
        self.change_label:setString(string_helper.game_gvg_show.inter_gvg)

        local attScore = game_util:createLabelTTF({text = string_helper.game_gvg_show.atfd .. self.m_tGameData.attacker_score,color = ccc3(221,221,192),fontSize = 12});
        local defScore = game_util:createLabelTTF({text = string_helper.game_gvg_show.dffd .. self.m_tGameData.defender_score,color = ccc3(221,221,192),fontSize = 12});
        self.content_node:removeAllChildrenWithCleanup(true)
        attScore:setPosition(ccp(5,40))
        defScore:setPosition(ccp(5,16))
        attScore:setAnchorPoint(ccp(0,0.5))
        defScore:setAnchorPoint(ccp(0,0.5))
        self.content_node:addChild(attScore)
        self.content_node:addChild(defScore)
    end
    --控制按钮开启
    self.btn_continue:setVisible(false)
    if (self.sort == 1 or self.sort == -10) and self.m_tGameData.is_def == true then
        self.btn_continue:setVisible(true)
        --显示准备倒计时
        self.time_label:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_perpare_time.png"))
       self.open_times_label:setString(testHour .. ":" .. testMin .. "-" .. hour .. ":" .. min)
    elseif (self.sort == 3 or self.sort == -11) and self.m_tGameData.is_def == true then
        self.btn_continue:setVisible(true)
        self.time_label:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_perpare_time.png"))
        self.open_times_label:setString(testHour .. ":" .. testMin .. "-" .. hour .. ":" .. min)
    end
    --倒计时到了进入下一场
    if self.sort == 1 or self.sort == 3 or self.sort == -10 or self.sort == -11 then
        --倒计时         战斗度倒计时，到0刷新界面
        local function timeEndFunc()
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local sort = data:getNodeWithKey("sort"):toInt()
                if sort == 1 then--外围战布阵开启
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
                elseif sort == 2 then--外围战战争开始
                    game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
                elseif sort == 3 then--内城布阵开始
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
                elseif sort == 4 then--内城战开始
                    game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
                elseif sort == 5 then
                    
                elseif sort == -1 then--公会战未开启
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                else
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
        end
        local countDownTime = self.m_tGameData.remainder_time + 2--延迟2秒来抵消不同服务器的延时
        local countdownLabel = game_util:createCountdownLabel(countDownTime,timeEndFunc,8,1);
        countdownLabel:setAnchorPoint(ccp(0,0.5))
        countdownLabel:setColor(ccc3(255,94,9))
        countdownLabel:setPosition(ccp(30,0))
        if countDownTime <= 0 then
            timeEndFunc()
        end
        self.per_node:setVisible(true)
        self.per_node:addChild(countdownLabel,10,10)
    end
    --连胜奖励
    if self.m_tGameData.win_times > 0 then
        self.add_label:setVisible(true)
        self.tips_sprite:setVisible(true)
        self.add_label:setString(string_helper.game_gvg_show.text7 .. (self.m_tGameData.win_times*50) .. "%")
    else
        self.tips_sprite:setVisible(false)
        self.add_label:setVisible(false)
    end
end
--[[--
    初始化
]]
function game_gvg_show.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local gvgData = data:getNodeWithKey("gvg")
        self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.sort = t_params.sort
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_show.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_gvg_show