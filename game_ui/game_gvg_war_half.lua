---  上半场战斗
local game_gvg_war_half = {
    m_tGameData = nil,
    property_add = nil,
    treasure = nil,
    city = nil,
    heal_times = nil,
    total_hp = nil,
    alignment = nil,
    die = nil,
    city = nil,
    recapture_log = nil,
    regain_reward = nil,
    total_hp_rate = nil,
    tips_label = nil,
    winType = nil,

    home_left_time = nil,
    home_att_flag = nil,
    occupy_index = nil,
    auto_node = nil,
    m_cityAutoRaidsScheduler = nil,

    att_tips_node = nil,
    def_tips_node = nil,
    log_btn = nil,
    auto_time_label = nil,
    netFlag = nil,

    att_camp = nil,
    def_camp = nil,
    att_back_alpha = nil,
    def_back_alpha = nil,

    open_flag = nil,
    m_auto_time = nil,
    backData = nil,
    m_likefuhuo = nil,
    occupy_building = nil,
};
local autoRefreshTime = 5
--[[--
    销毁
]]
function game_gvg_war_half.destroy(self)
    cclog("-----------------game_gvg_war_half destroy-----------------");
    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
    self.m_tGameData = nil;
    self.property_add = nil;
    self.treasure = nil;
    self.city = nil;
    self.heal_times = nil;
    self.total_hp = nil;
    self.alignment = nil;
    self.die = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.regain_reward = nil;
    self.total_hp_rate = nil;
    self.tips_label = nil;
    self.winType = nil;

    self.home_left_time = nil;
    self.home_att_flag = nil;--是否可以打主家的flag
    self.occupy_index = nil;
    self.auto_node = nil;
    self.m_cityAutoRaidsScheduler = nil;

    self.att_tips_node = nil;
    self.def_tips_node = nil;
    self.log_btn = nil;
    self.auto_time_label = nil;
    self.netFlag = nil;

    self.att_camp = nil;
    self.def_camp = nil;
    self.att_back_alpha = nil;
    self.def_back_alpha = nil;
    self.open_flag = nil;
    self.m_auto_time = nil;
    self.backData = nil;
    self.m_likefuhuo = nil;
    self.occupy_building = nil;
end
--[[--
    返回
]]
function game_gvg_war_half.back(self,type)
    self.netFlag = true
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
function game_gvg_war_half.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --返回
            self:back();
        elseif btnTag == 2 then--详情
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_war_half_pop",{gameData = gameData,attacker = self.m_tGameData.attacker,defender = self.m_tGameData.defender,callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_battle_info"), http_request_method.GET, nil,"guild_gvg_battle_info")
        elseif btnTag == 3 then--刷新
            self:refreshData()
        elseif btnTag == 4 then--立刻复活
            local function buyTimeResponseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local gvgData = data:getNodeWithKey("gvg")
                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                self:refreshUi()
                game_util:closeAlertView()
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    network.sendHttpRequest(buyTimeResponseMethod,game_url.getUrlForKey("guild_gvg_buy_time"), http_request_method.GET, nil,"guild_gvg_buy_time")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_cancel,
                text = string_helper.game_gvg_war_half.text,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-17,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 100 then--即时排名
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_instant_rank_pop",{gameData = gameData,callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_show_log"), http_request_method.GET, nil,"guild_gvg_show_log")
        elseif btnTag == 501 then--防守方排名
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_ranp_pop",{gameData = gameData,enterType = "gvg_def_rank",callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_top_rank"), http_request_method.GET, {sort = "defender"},"guild_gvg_top_rank")
        elseif btnTag == 502 then--攻击方排名
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_ranp_pop",{gameData = gameData,enterType = "gvg_att_rank",callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_top_rank"), http_request_method.GET, {sort = "attacker"},"guild_gvg_top_rank")
        elseif btnTag == 888 then--查看详情
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            game_scene:addPop("game_gvg_inspire_pop",{gameData = self.m_tGameData.battle_log,selfGameData = self.m_tGameData.user_battle_log,enterType = 2,callBackFunc = callBackFunc})
        elseif btnTag == 12 then--活动详情
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = "126",callBackFunc = callBackFunc})
            game_scene:addPop("game_gvg_rules_pop",{m_comeInIndex = 1,callBackFunc = callBackFunc})
        elseif btnTag == 11 then--阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="gvg"});
            self:destroy();
        elseif btnTag == 201 then--防守排行榜
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_ranp_pop",{gameData = gameData,enterType = "gvg_def_rank",callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_top_rank"), http_request_method.GET, {sort = "defender"},"guild_gvg_top_rank")
        elseif btnTag == 202 then--攻击排行榜
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_gvg_ranp_pop",{gameData = gameData,enterType = "gvg_att_rank",callBackFunc = callBackFunc})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_top_rank"), http_request_method.GET, {sort = "attacker"},"guild_gvg_top_rank")
        elseif btnTag == 555 then--聊天
            self.open_flag = true
            game_scene:addPop("ui_chat_pop",{enterType = 2});
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_citys_war.ccbi");
    
    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name")
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")

    self.bar_node = ccbNode:nodeForName("bar_node")
    self.left_time_node = ccbNode:nodeForName("left_time_node")

    self.att_num = ccbNode:labelTTFForName("att_num")
    self.def_num = ccbNode:labelTTFForName("def_num")

    --阵营
    self.def_camp = ccbNode:spriteForName("def_camp")
    self.att_camp = ccbNode:spriteForName("att_camp")
    
    self.map_node = ccbNode:nodeForName("map_node")--地图按钮
    self.map_sprite = ccbNode:spriteForName("map_sprite")--地图底图
    
    self.att_left_node = ccbNode:nodeForName("att_left_node")--攻击倒计时
    self.att_left_label = ccbNode:labelTTFForName("att_left_label")--攻击剩余次数

    self.def_left_node = ccbNode:nodeForName("def_left_node")--防守方占坑的
    self.def_left_label = ccbNode:labelTTFForName("def_left_label")--防守方剩余血量

    --准备用的node
    self.perpare_node = ccbNode:nodeForName("perpare_node")
    self.perpare_node:removeAllChildrenWithCleanup(true)
    self.perpare_node:setVisible(false)
    --log
    self.log_node = ccbNode:nodeForName("log_node")

    self.auto_node = ccbNode:nodeForName("auto_node")
    self.auto_time_label = ccbNode:labelTTFForName("auto_time_label")
    self.auto_time_label:setString("")

    self.scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")
    --提示
    self.att_tips_node = ccbNode:nodeForName("att_tips_node")
    self.def_tips_node = ccbNode:nodeForName("def_tips_node")

    self.log_btn = ccbNode:controlButtonForName("log_btn")
    self.log_btn:setOpacity(0)
    --提示信息
    self.att_tips_label = ccbNode:nodeForName("att_tips_label")

    --阵营信息
    self.def_back_alpha = ccbNode:spriteForName("def_back_alpha")
    self.att_back_alpha = ccbNode:spriteForName("att_back_alpha")
    self.def_camp = ccbNode:spriteForName("def_camp")
    self.att_camp = ccbNode:spriteForName("att_camp")

    --排行榜
    local m_btn_att_rank = ccbNode:controlButtonForName("m_btn_att_rank")
    local m_btn_def_rank = ccbNode:controlButtonForName("m_btn_def_rank")

    m_btn_att_rank:setVisible(true)
    m_btn_def_rank:setVisible(true)

    local btn_detail = ccbNode:controlButtonForName("btn_detail")
    btn_detail:setVisible(true)

    local m_formation_btn = ccbNode:controlButtonForName("m_formation_btn")
    m_formation_btn:setVisible(true)

    self.m_likefuhuo = ccbNode:controlButtonForName("m_likefuhuo")

    if self.m_tGameData.is_def == true then--防守方
        self.def_camp:setVisible(true)
        self.def_back_alpha:setVisible(true)
        self.def_back_alpha:runAction(game_util:createRepeatForeverFade());
    else
        self.att_camp:setVisible(true)
        self.att_back_alpha:setVisible(true)
        self.att_back_alpha:runAction(game_util:createRepeatForeverFade());
    end

    self.m_ccbNode = ccbNode;

    function tick( dt )
        if self.open_flag == false then
            self:setInfoLabel();
            if self.m_auto_time > 0 then
                self.m_auto_time = self.m_auto_time - 1;
            else
                if self.netFlag == false then
                    self.netFlag = true;
                    local screenShoot = game_util:createScreenShoot();
                    screenShoot:retain();
                    local function responseMethod(tag,gameData)
                        if gameData then
                            local data = gameData:getNodeWithKey("data");
                            local sort = data:getNodeWithKey("sort"):toInt()
                            self.netFlag = false;
                            if sort == 2 or sort == 4 then
                                local gvgData = data:getNodeWithKey("gvg")
                                self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                                self:refreshUi()
                            elseif sort == 1 or sort == 3 then
                                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
                            elseif sort == -1 then
                                --从2或4跳到-1需要先播放动画
                                self.open_flag = true
                                local function callFunc()
                                   -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                                end
                                --从2或4跳到-1需要先播放动画
                                local data = gameData:getNodeWithKey("data");
                                local gvgData = data:getNodeWithKey("gvg")
                                local win_times = gvgData:getNodeWithKey("win_times"):toInt()
                                if (win_times > 0 and self.m_tGameData.is_def == true) then--防守方播放胜利动画
                                    game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "win",screenShoot = screenShoot})
                                elseif (win_times <= 0 and self.m_tGameData.is_def == true) then--防守方播放失败动画
                                    game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "lose",screenShoot = screenShoot})
                                elseif (win_times <= 0 and self.m_tGameData.is_def == false) then--攻击方播放胜利动画
                                    game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "win",screenShoot = screenShoot})
                                elseif (win_times > 0 and self.m_tGameData.is_def == false) then--攻击方播放失败
                                    game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "lose",screenShoot = screenShoot})
                                end
                                -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                            else
                                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
                            end
                        else
                            self.netFlag = false;
                        end
                        screenShoot:release();
                    end
                   network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index",false,true)    
                end
            end
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)

    local day_label = ccbNode:labelTTFForName("day_label")
    day_label:setString(string_helper.ccb.text212)
    return ccbNode;
end
local buttonInfo = {
    {pos = ccp(93,431),id = 1,size = 2},
    {pos = ccp(21,333),id = 2},
    {pos = ccp(265,457),id = 3},
    {pos = ccp(110,260),id = 4},
    {pos = ccp(239,316),id = 5},
    {pos = ccp(360,385),id = 6},
    {pos = ccp(44,159),id = 7},
    {pos = ccp(190,191),id = 8},
    {pos = ccp(301,237),id = 9},
    {pos = ccp(398,296),id = 10},
    {pos = ccp(526,353),id = 11},
    {pos = ccp(491,432),id = 12},
    {pos = ccp(181,97),id = 13},
    {pos = ccp(314,147),id = 14},
    {pos = ccp(443,211),id = 15},
    {pos = ccp(562,270),id = 16},
    {pos = ccp(393,46),id = 105},
    {pos = ccp(528,111),id = 104},
    {pos = ccp(648,180),id = 103},
    {pos = ccp(764,270),id = 102},
    {pos = ccp(743,53),id = 101,size = 2},
}
--[[
    刷新数据
]]
function game_gvg_war_half.refreshData(self)
    local screenShoot = game_util:createScreenShoot();
    screenShoot:retain();
    local function responseMethod(tag,gameData)
        if gameData == nil then
            screenShoot:release();
            return;
        end
        local data = gameData:getNodeWithKey("data")
        local sort = data:getNodeWithKey("sort"):toInt()
        if sort == 1 then--外围战布阵开启
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
        elseif sort == 2 then--外围战战争开始
            -- game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            local gvgData = data:getNodeWithKey("gvg")
            self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
            self:refreshUi()
        elseif sort == 3 then--内城布阵开始
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
        elseif sort == 4 then--内城战开始
            -- game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            local gvgData = data:getNodeWithKey("gvg")
            self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
            self:refreshUi()
        elseif sort == 5 then
            
        elseif sort == -1 then--公会战未开启
            --从2或4跳到-1需要先播放动画
            self.open_flag = true
            local function callFunc()
               -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
            end

            --从2或4跳到-1需要先播放动画
            local data = gameData:getNodeWithKey("data");
            local gvgData = data:getNodeWithKey("gvg")
            local win_times = gvgData:getNodeWithKey("win_times"):toInt()
            -- local win_times = 1
            if (win_times > 0 and self.m_tGameData.is_def == true) then--防守方播放胜利动画
                game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "win",screenShoot = screenShoot})
            elseif (win_times <= 0 and self.m_tGameData.is_def == true) then--防守方播放失败动画
                game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "lose",screenShoot = screenShoot})
            elseif (win_times <= 0 and self.m_tGameData.is_def == false) then--攻击方播放胜利动画
                game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "win",screenShoot = screenShoot})
            elseif (win_times > 0 and self.m_tGameData.is_def == false) then--攻击方播放失败
                game_scene:enterGameUi("game_gvg_end_pop",{callFunc = callFunc,enterType = "lose",screenShoot = screenShoot})
            end
            -- game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
        else
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
        end
        screenShoot:release();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index",true,true)
end
--[[
    初始化按钮位置
]]
function game_gvg_war_half.initMapButton(self)
    local attColor = ccc3(255,38,40)
    local defColor = ccc3(30,135,253)
    local selfColor = ccc3(246,197,14)
    local lifePos = {
        {0},
        {-7,8},
        {-15,0,15},
        {-22,-7,8,23},
        {-30,-15,0,15,30},
    }
    local guild_fightCfg = getConfig(game_config_field.guild_fight)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local cityData = self.m_tGameData.city
        local itemData = cityData[tostring(btnTag)]
        --根据当时的状态来判断是去请求哪一个
        local sort = itemData.sort
        local reboot = itemData.reboot
        local life = itemData.life

        local params = {}
        params.building_id = btnTag
        if reboot == 0 then--空地块，占领
            
        else
            local function callBackFunc()
               self.open_flag = false
            end
            self.open_flag = true
            local function responseMethod(tag,gameData)
                local function callFunc(callFuncData)
                    self.m_tGameData = callFuncData or {};
                   self:refreshUi()
                   game_util:addMoveTips({text = string_helper.game_gvg_war_half.del_success})
                end
                local data = gameData:getNodeWithKey("data");
                local reboot = data:getNodeWithKey("reboot"):toInt()
                if reboot == 1 or reboot == 2 then--人
                    game_scene:addPop("game_gvg_enemy_pop",{gameData = gameData,sort = self.sort,buildingId = btnTag,enterType = "half",callFunc = callFunc,life = life,owner_times = self.m_tGameData.owner_times,cd_flag = self.cd_flag,can_buy_times = self.m_tGameData.can_buy_times,in_building = self.m_tGameData.in_building,callBackFunc = callBackFunc,occupy_building = self.occupy_building})
                elseif reboot == 3 then--怪
                    game_scene:addPop("game_gvg_npc",{gameData = gameData,buildingId = btnTag,enterType = "half",life = life,owner_times = self.m_tGameData.owner_times,cd_flag = self.cd_flag,can_buy_times = self.m_tGameData.can_buy_times,callBackFunc = callBackFunc})
                elseif reboot == 0 then--空地块
                    -- game_util:addMoveTips({text = "占领成功"})
                    --测试--测试--测试--测试--测试--测试--测试
                end
            end
            --判断购买次数   放在下一界面
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_open_building"), http_request_method.GET, params,"guild_gvg_open_building")
        end
    end
    self.map_node:removeAllChildrenWithCleanup(true)
    local cityData = self.m_tGameData.city
    for i=1,game_util:getTableLen(buttonInfo) do
        local btnPos = buttonInfo[i].pos
        local realPos = ccp(math.floor(btnPos.x/2),math.floor(btnPos.y/2))
        local size = buttonInfo[i].size
        local realSize = CCSizeMake(36,36)
        if size == 2 then
            realSize = CCSizeMake(51,51)
        end
        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        button:setPosition(realPos)
        button:setAnchorPoint(ccp(0,0))
        button:setPreferredSize(realSize)
        local id = buttonInfo[i].id
        button:setTag(id)
        button:setOpacity(0)
        self.map_node:addChild(button,10,id)

        --加建筑node来显示内容的
        local roleNode = CCNode:create()
        roleNode:setPosition(ccp(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5))
        roleNode:removeAllChildrenWithCleanup(true)

        self.map_node:addChild(roleNode,11,100+id)
        local itemData = cityData[tostring(id)]
        local backItemData = self.backData.city[tostring(id)]
        local sort = itemData.sort   --建筑物积分类型 1: 防守方占领, 2: 资源地块 3: 大资源块 
        if sort == 0 then

        elseif sort == 1 or sort == 2 or sort == 3 then--防守方
            local name = itemData.name
            local life = itemData.life
            local reboot = itemData.reboot--reboot: 0. 未知. 1. 人, 2. 机器人, 3.怪物    根据roboot来判断是否可占领
            local guild_id = itemData.guild_id or 0

            local lifeBack = CCScale9Sprite:createWithSpriteFrameName("gvg_alpha_back.png")
            lifeBack:setColor(ccc3(255,146,0))
            --底条
            lifeBack:setPreferredSize(CCSizeMake(70,13))
            lifeBack:setPosition(ccp(0,realSize.height/4))
            roleNode:addChild(lifeBack,10)

            --名字
            local nameLabel = game_util:createLabelTTF({text = name,color = ccc3(255,255,255),fontSize = 10});
            -- if id < 100 then--防守方
            --     nameLabel:setColor(defColor)
            -- else
            --     nameLabel:setColor(attColor)
            -- end
            local is_def = itemData.is_def
            if is_def == true then
                nameLabel:setColor(defColor)
            else
                nameLabel:setColor(selfColor)
                if guild_id == game_data:getUserStatusDataByKey("association_id") then--自己的公会的，显示黄色
                    nameLabel:setColor(attColor)
                end
                if sort == 2 or sort == 3 then
                    nameLabel:setColor(attColor) 
                end
            end
            if life <= 0 then--显示被占领了
                if self.m_tGameData.is_def == true then--防守方
                    if id > 100 then--攻击方建筑
                        -- nameLabel:setColor(ccc3(240,0,0))
                        -- nameLabel:setString("占领")
                        nameLabel:setString(string_helper.game_gvg_war_half.str)
                        -- nameLabel:setColor(defColor)
                        nameLabel:setColor(ccc3(127,127,127))
                    else
                        -- nameLabel:setColor(ccc3(28,240,2))
                        -- nameLabel:setString("被占领")
                        local guild_name_label = game_util:createLabelTTF({text = itemData.guild_name,color = ccc3(255,255,255),fontSize = 10});
                        guild_name_label:setPosition(ccp(0,-5))
                        roleNode:addChild(guild_name_label,10)
                    end
                else
                    if id > 100 then--攻击方建筑壹柒贰
                        -- nameLabel:setColor(ccc3(28,240,2))
                        -- nameLabel:setString("被占领")
                        nameLabel:setString(string_helper.game_gvg_war_half.str)
                        -- nameLabel:setColor(defColor)
                        nameLabel:setColor(ccc3(127,127,127))
                    else
                        -- nameLabel:setColor(ccc3(240,0,0))
                        -- nameLabel:setString("占领")
                        local guild_name_label = game_util:createLabelTTF({text = itemData.guild_name,color = ccc3(255,255,255),fontSize = 10});
                        guild_name_label:setPosition(ccp(0,-5))
                        roleNode:addChild(guild_name_label,10)
                    end
                end
                -- if id > 100 then--攻击方被防守方占领
                --     nameLabel:setColor(defColor)
                -- else
                --     nameLabel:setColor(attColor)
                -- end

                --加动画 -------------本界面的加动画
                local backLife = backItemData.life
                if backLife > 0 then--加动画,back > 0，现在小于0的
                    local effect = game_util:createEffectAnim("anim_zhanling",1.0)
                    effect:setPosition(ccp(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5))
                    self.map_node:addChild(effect,10)
                end
            end
            nameLabel:setPosition(ccp(0,realSize.height/4))
            roleNode:addChild(nameLabel,10)
            --加自己的标志
            local uid = game_data:getUserStatusDataByKey("uid")
            if uid == itemData.owner then
                local spriteTip = CCSprite:createWithSpriteFrameName("gvg_select1.png")
                spriteTip:setPosition(ccp(0,realSize.height/4+10))
                roleNode:addChild(spriteTip,100)
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(1,ccp(0, realSize.height/4+12)))
                animArr:addObject(CCMoveTo:create(1,ccp(0, realSize.height/4+8)))
                spriteTip:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
            end
            --血
            if sort == 1 then--显示血
                --根据
                -- createLifeIcon(roleNode,life)
                if reboot == 0 then--布阵时刻

                else
                    if life > 1 then
                        for i=1,life-1 do
                            local iconLife = CCSprite:createWithSpriteFrameName("gvg_icon_life.png")
                            iconLife:setPosition(ccp(lifePos[life-1][i],-5))
                            -- roleNode:addChild(iconLife)
                        end
                    end
                    -- local debuff = 100 - itemData.debuff
                    -- local left = game_util:createLabelTTF({text = debuff .. "%"})
                    -- left:setPosition(ccp(0,-5))
                    -- roleNode:addChild(left)
                end
            else--显示   */*
                local itemCfg = guild_fightCfg:getNodeWithKey(tostring(id))
                local life_1 = itemCfg:getNodeWithKey("life_1"):toInt()
                local lifeLabel = game_util:createLabelTTF({text = life .. "/" .. life_1,color = ccc3(222,217,8),fontSize = 12});
                lifeLabel:setPosition(ccp(0,-5))
                roleNode:addChild(lifeLabel,10)
            end
            --全局的动画
            if id > 6 and id < 100 then--加小建筑动画
                if life > 0 and itemData.is_def == true then---------改，id为防守方，且占领者也是防守方
                    -- local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
                    -- local delayTime = math.random(1,10)
                    local buildEffect = game_util:createEffectAnim("anim_qiangbing",1.0,true,delayTime)
                    if self.m_tGameData.sort == 4 then
                        buildEffect:playSection("impact1");
                    end
                    roleNode:addChild(buildEffect,10)
                else--死亡动画
                    local destroyEffect = game_util:createEffectAnim("anim_gonghui_zhaohuo",1.0,true,delayTime)
                    roleNode:addChild(destroyEffect,1)
                end
            elseif id > 101 and id < 106 then--攻击方建筑动画
                if life > 0 then--血>0才播放动画
                    local index = 106 - id
                    local attEffect = game_util:createEffectAnim("anim_gonghui_paodan",1.0,true)
                    attEffect:playSection("impact" .. index)
                    if self.m_tGameData.sort == 2 and id == 105 then
                        attEffect:playSection("impact")
                    elseif self.m_tGameData.sort == 4 and id == 102 then
                        attEffect:playSection("impact5")
                    end
                    attEffect:setPosition(ccp(240,160))
                    self.map_node:addChild(attEffect)
                else
                    local destroyEffect = game_util:createEffectAnim("anim_gonghui_baozha",1.0,true,delayTime)
                    roleNode:addChild(destroyEffect,1)
                end
            end
            local bigEffect = game_util:createEffectAnim("anim_gonghui_fight",1.0,true)
            if self.m_tGameData.sort == 4 then
                bigEffect:playSection("impact1");
            end
            bigEffect:setPosition(ccp(240,160))
            self.map_node:addChild(bigEffect,9)
            --播放动画   chuansong   zhanling    guwu
            if self.occupy_index and self.occupy_index == id then
                local effect = game_util:createEffectAnim("anim_zhanling",1.0)
                effect:setPosition(ccp(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5))
                self.map_node:addChild(effect,10)
                self.occupy_index = nil;
            end

            ------加爆炸的动画   在界面等的人看到的动画
            local back_is_def = backItemData.is_def
            if back_is_def ~= itemData.is_def then
                local effect = game_util:createEffectAnim("anim_zhanling",1.0)
                effect:setPosition(ccp(realPos.x + realSize.width * 0.5,realPos.y + realSize.height * 0.5))
                self.map_node:addChild(effect,10)
            end
        -- elseif sort == 2 then--资源点
        end
    end
    if self.m_tGameData.sort == 2 then
        local mapSprite = CCSprite:create("ccbResources/ui_gvg_gates_map.jpg")
        self.map_sprite:setDisplayFrame(mapSprite:displayFrame());
    else
        local mapSprite = CCSprite:create("ccbResources/ui_gvg_inner_city_map.jpg")
        self.map_sprite:setDisplayFrame(mapSprite:displayFrame());
    end
    ---加完动画重新赋值back data
    self.backData = self.m_tGameData
end
--[[
    刷新label
]]
function game_gvg_war_half.refreshLabel(self)
    self.open_flag = false
    self.m_auto_time = autoRefreshTime;
    -- self.guild_def_name:setString(self.m_tGameData.defender)
    -- self.guild_att_name:setString(self.m_tGameData.attacker)
    self.bar_node:removeAllChildrenWithCleanup(true)
    self.left_time_node:removeAllChildrenWithCleanup(true)

    --倒计时         战斗度倒计时，到0刷新界面
    local function timeEndFunc()
        self:refreshData()
    end
    local countDownTime = self.m_tGameData.remainder_time
    local countdownLabel = game_util:createCountdownLabel(countDownTime,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setColor(ccc3(255,94,9))
    self.left_time_node:addChild(countdownLabel,10,10)
    if countDownTime <= 0 then
        timeEndFunc()
    end
    --进度条
    local att_score = self.m_tGameData.att_score
    local def_score = self.m_tGameData.def_score
    local max_value = att_score + def_score
    local now_value = def_score
    local bar = ExtProgressTime:createWithFrameName("gvg_att_hp.png","gvg_def_hp.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(0,-1));
    self.bar_node:addChild(bar,-1,11)
    --
    self.att_num:setString(att_score)
    self.def_num:setString(def_score)

    self.att_tips_label:removeAllChildrenWithCleanup(true)
    if self.m_tGameData.in_building == true then--占坑
        self.cd_flag = false
        self.att_tips_node:setVisible(false)
        self.def_tips_node:setVisible(true)

        local uid = game_data:getUserStatusDataByKey("uid")
        local life = 0
        local debuff = 100
        --遍历获取位置
        for k,v in pairs(self.m_tGameData.city) do
            local itemData = v
            if tostring(itemData.owner) == tostring(uid) then
                life = itemData.life
                debuff = itemData.debuff + 100
                --将自己占领的地盘存下来
                self.occupy_building = k
                break;
            end
        end
        local maxLife = 2
        if self.sort == 4 then--内城
            maxLife = 4
        end
        self.def_left_label:setString(debuff .. "%")

        self.def_left_node:removeAllChildrenWithCleanup(true)
        local status = ""
        if life > 0 then
            status = string_helper.game_gvg_war_half.fding
        else
            status = string_helper.game_gvg_war_half.att_failed
        end
        self.def_left_node:removeAllChildrenWithCleanup(true)
        local def_tip = game_util:createLabelTTF({text = status})
        self.def_left_node:addChild(def_tip)
    else
        self.att_tips_node:setVisible(true)
        self.def_tips_node:setVisible(false)
        local function timeEndFunc2()
            self.cd_flag = false
            self.m_likefuhuo:setVisible(false)
            self.att_left_node:removeAllChildrenWithCleanup(true)
            local tipsWord = ""
            if self.m_tGameData.owner_times > 0 then
                tipsWord = string_helper.game_gvg_war_half.attack
            else
                tipsWord = string_helper.game_gvg_war_half.side_ind
            end
            local attLabel = game_util:createLabelTTF({text = tipsWord})
            self.att_left_node:addChild(attLabel)
        end
        self.att_left_node:removeAllChildrenWithCleanup(true)
        local attLeftTime = game_util:createCountdownLabel(self.m_tGameData.owner_time,timeEndFunc2,8,2);
        self.att_left_node:addChild(attLeftTime)

        if self.m_tGameData.owner_time > 0 then
            self.cd_flag = true
            self.m_likefuhuo:setVisible(true)
        else
            -- self.cd_flag = false
            timeEndFunc2()
        end
        self.att_left_label:setString(self.m_tGameData.owner_times .. "/2")
    end
    cclog2(self.m_tGameData.is_def,"self.m_tGameData.is_def")
    if self.m_tGameData.is_def == true then--防守方，提示去打攻击方
        local tipsLabel = game_util:createLabelTTF({text = string_helper.game_gvg_war_half.text2})
        self.att_tips_label:addChild(tipsLabel)
    else
        local tipsLabel = game_util:createLabelTTF({text = string_helper.game_gvg_war_half.text3})
        self.att_tips_label:addChild(tipsLabel)
    end
end
--[[--
    刷新ui
]]
function game_gvg_war_half.refreshUi(self)
    self:refreshLabel()
    --初始化地图按钮
    self:initMapButton()
    --即时信息
    -- local logTableView = self.log_node:getChildByTag(10)
    -- if logTableView then
    --     logTableView:removeFromParentAndCleanup(true)
    -- end
    -- local logTableView2 = self:createLogTable(self.log_node:getContentSize());
    -- self.log_node:addChild(logTableView2,10,10);

    --5秒自动刷新界面
    -- local function timeEnd()
    --     local function responseMethod(tag,gameData)
    --         local data = gameData:getNodeWithKey("data");
    --         local sort = data:getNodeWithKey("sort"):toInt()
    --         if sort == 2 then
    --             local gvgData = data:getNodeWithKey("gvg")
    --             self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
    --             self:refreshUi()
    --         end
    --     end
    --    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")    
    -- end
    -- self.auto_node:removeAllChildrenWithCleanup(true)
    -- local attLeftTime = game_util:createCountdownLabel(autoRefreshTime,timeEnd,8,2);
    -- self.auto_node:addChild(attLeftTime)
    self:createScrollViewTips();
end
function game_gvg_war_half.createScrollViewTips(self)
    --[[
        BATTLE_TYPE_2 = 2           # 战斗类型: 2. 防守方 攻打 资源点成功捣毁
        BATTLE_TYPE_3 = 3           # 战斗类型: 3. 防守方连续X次防守住阵地, 完成连胜
        BATTLE_TYPE_4 = 4           # 战斗类型: 4. 攻击方 攻打 防守方成功 | 防守方 攻打 攻击方成功
        BATTLE_TYPE_5 = 5           # 战斗类型: 5. 攻击方 攻打 防守方失败 | 防守方 攻打 攻击方失败
        BATTLE_TYPE_6 = 6           # 战斗类型: 6. 防守方 攻打 资源点成功
        BATTLE_TYPE_7 = 7           # 战斗类型: 7. 防守方 攻打 资源点失败
    ]]
    local logTable = self.m_tGameData.battle_log
    if logTable == nil or game_util:getTableLen(logTable) == 0 then return end
    local log_type_table = string_helper.game_gvg_war_half.log_type_table
    self.scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true);
    local showIndex = 0;
    local scroll_view_size = self.scroll_view_tips:getViewSize();
    local containerNode = CCNode:create();
    self.scroll_view_tips:addChild(containerNode)
    self.scroll_view_tips:setTouchEnabled(false);

    local function showTips()
        local richLabel = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(180,30),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)});
        containerNode:addChild(richLabel)
        local attColor = "[color=ffff2628]"
        local defColor = "[color=ff1e87fd]"
        local color1 = ""
        local color2 = ""
        local function backCallFunc( node )
            local logData = logTable[game_util:getTableLen(logTable)-showIndex] or {}
            local logStr = ""
            local battType = logData.battle_type
            local ais_def = logData.ais_def
            local dguild_name = logData.dguild_name or ""
            local aguild_name = logData.aguild_name or ""
            if ais_def then
                color1 = defColor
                color2 = attColor
            else
                color2 = defColor
                color1 = attColor
            end
            if battType == 4 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.att_success .. color2 .. logData.dname .. "(" .. dguild_name .. ")" .. "[/color]," .. string_helper.game_gvg_war_half.hold_place
            elseif battType == 3 then
                logStr =  " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.finish .. "[color=ffff0b03]" .. logData.times .. string_helper.game_gvg_war_half.winned .. "[/color]"
            elseif battType == 6 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.att_success .. color2 .. logData.dname .. "[/color]"
            elseif battType == 5 or battType == 7 then
                logStr =  " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.bei .. color2 .. logData.dname .. "(" .. dguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.att_fail
            elseif battType == 2 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. string_helper.game_gvg_war_half.att_success .. color2 .. logData.dname .. "[/color]" .. string_helper.game_gvg_war_half.att_place
            end

            -- if battType == 2 then
            --     logStr =  " " .. attColor .. logData.aname .. "[/color]" .. log_type_table[battType] .. defColor .. logData.dname .. "[/color]"
            -- elseif battType == 4 then
            --     -- logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color]"
            --     logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. "战胜了" .. "[color=ffff0b03]" .. logData.dname .. "[/color]"
            -- elseif battType == 1 then
            --     logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color],占领了该地块"
            -- elseif battType == 3 then 
            --     logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.times .. "连胜" .. "[/color]"
            -- elseif battType == 5 then
            --     -- logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. "被" .. "[color=ffff0b03]" .. logData.dname .. "[/color]" .. "击败了"
            -- elseif battType == 6 then
            --     logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color]"
            -- elseif battType == 7 then
            --     logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. "被" .. "[color=ffff0b03]" .. logData.dname .. "[/color]" .. "击败了"
            -- end
            showIndex = showIndex + 1
            if showIndex >= (game_util:getTableLen(logTable) - 1) then
                showIndex = 0;
            end
            richLabel:setString(logStr)
            richLabel:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
        end
        local animArr = CCArray:create();
        animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*0.5)),5));
        animArr:addObject(CCDelayTime:create(1));
        animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*2)),5));
        animArr:addObject(CCCallFuncN:create(backCallFunc));
        richLabel:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    end
    showTips();
end
function game_gvg_war_half.setInfoLabel(self)
    self.auto_time_label:setString("00:0" .. self.m_auto_time)
end
--[[--
    初始化
]]
function game_gvg_war_half.init(self,t_params)
    t_params = t_params or {};
    self.m_buildingTable = {};
    self.m_touchRef = 0;
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local gvgData = data:getNodeWithKey("gvg")
        self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
        self.sort = self.m_tGameData.sort
        self.backData = self.m_tGameData
    else
        self.m_tGameData = {};
    end
    if t_params.occupy_index then
        self.occupy_index = tonumber(t_params.occupy_index)
    end
    -- cclog("self.occupy_index =============== " .. tostring(self.occupy_index))
    self.m_auto_time = autoRefreshTime;
    self.netFlag = false;
    self.open_flag = false;
end

--[[--
    创建入口
]]
function game_gvg_war_half.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end
return game_gvg_war_half;