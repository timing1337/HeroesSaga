---  跨服擂台  主页->活动->擂台:小组赛

local game_server_grouppk_scene = {
   m_gameData = nil,
   m_showData = nil,
   m_points = nil,
   m_label_combatInfos = nil,  -- 左下的信息
   m_label_lastTimes = nil,   -- 剩余场次
   m_node_countdown = nil,    -- 开战倒计时背景板
   m_playerData = nil,        -- 玩家数据
   m_myInfo = nil,            -- 自己的信息
   m_nextTime = nil,         -- 今日
   m_spr_battlbg2 = nil,
   m_sprite_light = nil,
   m_spr_battletitle = nil,
   m_spr_battleend = nil,
   m_spr_vs = nil,
   m_node_players = nil,
   m_node_last_twices = nil,
   m_node_countdownboard = nil,
   m_node_playersprEsts = nil,
}

--[[--
    销毁ui
]]
function game_server_grouppk_scene.destroy(self)
    -- body
    cclog("----------------- game_server_grouppk_scene destroy-----------------"); 
    self.m_gameData = nil;
    self.m_showData = nil;
    self.m_points = nil;
    self.m_label_combatInfos = nil; 
    self.m_label_lastTimes = nil;
    self.m_node_countdown = nil;
    self.m_playerData = nil;
    self.m_myInfo = nil;
    self.m_spr_battlbg2 = nil;
    self.m_sprite_light = nil;
    self.m_spr_battletitle = nil;
    self.m_spr_battleend = nil;
    self.m_spr_vs = nil;
    self.m_node_players = nil;
    self.m_node_last_twices = nil;
    self.m_node_countdownboard = nil;
    self.m_node_playersprEsts = nil;
end

--[[--
    返回
]]
function game_server_grouppk_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end

--[[--
    读取ccbi创建ui
]]
function game_server_grouppk_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then -- 排行榜
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_serverpk_rank",{gameData = gameData, showType = 1});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_battle_rank"), http_request_method.GET, nil,"serverpk_team_battle_rank")
        elseif btnTag == 102 then -- 玩法说明
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "135"})
        elseif btnTag == 104 then -- 战斗记录
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_serverpk_info_pop",{gameData = gameData, enterType = 1});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_group_combat_log"), http_request_method.GET, nil,"serverpk_group_combat_log")
        elseif btnTag == 103 then  -- 查看对手
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_serverpk_otherplayer_pop",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_check_enemy_list"), http_request_method.GET, nil,"serverpk_check_enemy_list")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_activity_serverpk_group2.ccbi");

    local m_node_mainboard = ccbNode:nodeForName("m_node_mainboard")
    local m_node_playinfoboard = ccbNode:nodeForName("m_node_playinfoboard")
    local battleBg = CCSprite:create("battle_ground/back_carpark.jpg")
    battleBg:setPosition(m_node_mainboard:getContentSize().width * 0.5, m_node_mainboard:getContentSize().height * 0.5)
    m_node_mainboard:addChild(battleBg, - 10)

    self.m_label_combatInfos = {}
    for i=1,3 do
        local tempLabel = ccbNode:labelTTFForName("m_label_info" .. i)
        if tempLabel then
            table.insert(self.m_label_combatInfos, tempLabel)
        end
    end
    self.m_label_lastTimes = ccbNode:labelTTFForName("m_label_lastTimes")
    self.m_node_countdown = ccbNode:nodeForName("m_node_countdown")
    self.m_sprite_light = ccbNode:spriteForName("m_sprite_light")
    self.m_spr_battlbg2 = ccbNode:scale9SpriteForName("m_spr_battlbg2")
    self.m_spr_battletitle = ccbNode:spriteForName("m_spr_battletitle")
    self.m_spr_vs = ccbNode:spriteForName("m_spr_vs")
    self.m_spr_battleend = ccbNode:spriteForName("m_spr_battleend")
    self.m_node_players = ccbNode:nodeForName("m_node_players")
    self.m_node_last_twices = ccbNode:nodeForName("m_node_last_twices")
    self.m_node_countdownboard = ccbNode:nodeForName("m_node_countdownboard")

    self.m_spr_vs:setVisible(false)
    self.m_spr_battleend:setVisible(false)

    if self.m_sprite_light then
        self.m_sprite_light:setVisible(true)
    end
    if self.m_spr_battlbg2 then
        self.m_spr_battlbg2:setVisible(true)
    end
    self.m_node_playersprEsts = {}
    for i=1,2 do
        self.m_node_playersprEsts[#self.m_node_playersprEsts + 1] = ccbNode:nodeForName("m_node_playersprEst" .. i)
    end

    self.m_playerInfo = {}
    for i=1,2 do
        self.m_playerInfo["m_label_playerName" .. i] = ccbNode:labelTTFForName("m_label_playerName" .. i)
        self.m_playerInfo["m_label_playerSer" .. i] = ccbNode:labelTTFForName("m_label_playerSer" .. i)
        self.m_playerInfo["m_label_combat" .. i] = ccbNode:labelBMFontForName("m_label_combat" .. i)
        self.m_playerInfo["m_node_playerspr" .. i] = ccbNode:nodeForName("m_node_playerspr" .. i)
    end

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2("btnTag  ===  ", btnTag)
        if btnTag == 1 then
            if self.m_gameData.countdown < 0 and self.m_gameData.uid then
                game_util:lookPlayerInfo(self.m_gameData.uid, true, 2);
            end
        else
            if self.m_gameData.enemy_uid then
                game_util:lookPlayerInfo(self.m_gameData.enemy_uid, true, 2);
            end
        end
    end
    for i=1,2 do
        -- 创建一个触摸按钮 查看对手信息
        local tempNode = self.m_playerInfo["m_node_playerspr" .. i]
        if tempNode then
            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
            local tempSize = tempNode:getContentSize()
            button:setPreferredSize(tempSize)
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(ccp(tempSize.width * 0.5, tempSize.height *  0.5))
            button:setOpacity(0)
            button:setTag(i)
            tempNode:addChild(button)
        end
    end
    return ccbNode;
end

local FlipXs = {true, true, false, false, false}
--[[
    刷新玩家信息
]]
function game_server_grouppk_scene.refreshPlayerInfo( self )
    if self.m_gameData.countdown < 0 then
        -- self.m_spr_battleend:setVisible(true)
        -- self.m_node_last_twices:setVisible(false)
        -- self.m_node_countdownboard:setVisible(false)
        self.m_spr_battlbg2:setVisible(false)
        self.m_sprite_light:setVisible(true)
        self.m_spr_battleend:setVisible(false)
        self.m_spr_vs:setVisible(false)
        self.m_node_players:setVisible(true)
        self.m_node_last_twices:setVisible(true)
        self.m_node_countdownboard:setVisible(true)
        for i=1,2 do
            local tempNode = self.m_node_playersprEsts[i]
            if tempNode then
                tempNode:setVisible(true)
            end
        end
        -- return
    else
        self.m_spr_battleend:setVisible(false)
        self.m_spr_vs:setVisible(true)
        self.m_node_players:setVisible(true)
        self.m_node_last_twices:setVisible(true)
        self.m_node_countdownboard:setVisible(true)
        for i=1,2 do
            local tempNode = self.m_node_playersprEsts[i]
            if tempNode then
                tempNode:setVisible(false)
            end
        end
    end

    for i=1,2 do
        local playerInfo = self.m_playerData["player" .. i]
        if self.m_playerInfo["m_label_playerName" .. i ] then
            self.m_playerInfo["m_label_playerName" .. i ]:setString(tostring(playerInfo.name))
        end
        if self.m_playerInfo["m_label_playerSer" .. i ] then
            self.m_playerInfo["m_label_playerSer" .. i ]:setString(tostring(playerInfo.server_name))
        end
        if self.m_playerInfo["m_label_combat" .. i ] then
            self.m_playerInfo["m_label_combat" .. i ]:setString(tostring(playerInfo.combat))
        end
        if self.m_playerInfo["m_node_playerspr" .. i ] then
            self.m_playerInfo["m_node_playerspr" .. i ]:removeChildByTag(998, true)
           local role = playerInfo.role or math.random(1, 5) 
           local tempNode = self:createBigImg(role)
           tempNode:setAnchorPoint(ccp(0.5,0))
           tempNode:setPositionX(self.m_playerInfo["m_node_playerspr" .. i ]:getContentSize().width * 0.5)
           tempNode:setScale(0.5)
           local FlipX = FlipXs[role]
           if i == 2 then
                FlipX = not FlipX
           end
           tempNode:setFlipX(FlipX) 
           self.m_playerInfo["m_node_playerspr" .. i ]:addChild(tempNode, 1, 998)
        end
    end
end

--[[
    刷新自己战斗信息
]]
function game_server_grouppk_scene.refreshFightInfo(self)
    local titles = string_helper.game_server_grouppk_scene.titles
    local battleInfo = self.m_myInfo or string_helper.game_server_grouppk_scene.battle
    if self.m_gameData.battle_countdown >= 0 then
        battleInfo = string_helper.game_server_grouppk_scene.battleInfo
    end
    local isFighting = false
    if self.m_gameData.battle_countdown >= 0 then isFighting = true end
    for i=1,3 do
        if self.m_label_combatInfos[i] then
            local tempLabel = self.m_label_combatInfos[i]
            tempLabel:removeAllChildrenWithCleanup(true)
            local fontSize = 9
            if isFighting then
                fontSize = 8
           end
           tempLabel:setString(tostring(titles[i]) .. "：")
            local infoLabel = CCLabelTTF:create(tostring(battleInfo[i]),TYPE_FACE_TABLE.Arial_BoldMT, fontSize)
            infoLabel:setPositionY(tempLabel:getContentSize().height * 0.5)
            infoLabel:setPositionX(tempLabel:getContentSize().width)
            infoLabel:setVisible(true)
            infoLabel:setAnchorPoint(ccp(0, 0.5))
            tempLabel:addChild(infoLabel)

        end
    end
    -- 今日剩余场次
    self.m_label_lastTimes:setString(tostring(self.m_gameData.rest_battle_num))
    self:refreshCountdownInfo()
end

--[[--
    刷新倒计时
]]
function game_server_grouppk_scene.refreshCountdownInfo( self )
    -- self.m_gameData.countdown = -1
    if self.m_gameData.countdown < 0 then
        local endLabel = game_util:createLabelTTF({text = string_helper.game_server_grouppk_scene.text, fontSize = 10})
        endLabel:setAnchorPoint(ccp(0, 0.5))
        endLabel:setPositionY(self.m_node_countdown:getContentSize().height * 0.5)
        endLabel:setPositionX(2)
        self.m_node_countdown:addChild(endLabel)
        return 
    end

    if self.m_spr_battlbg2 then
        self.m_spr_battlbg2:setVisible(false)
        self.m_spr_battlbg2:stopAllActions()
    end
    if self.m_sprite_light then
        self.m_sprite_light:setVisible(false)
        self.m_sprite_light:stopAllActions()
    end

    local titileTimeSpriteName = {"ui_serverpk_zhandou.png"}
    self.m_node_countdown:removeAllChildrenWithCleanup(true)
    local posx = 0
    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    local countDownTime = -1
    if self.m_gameData.battle_countdown >= 0 then  -- 正在战斗中
        countDownTime = math.max(2, self.m_gameData.battle_countdown - serTime)
        if self.m_spr_battlbg2 then
            self.m_spr_battlbg2:setVisible(true)
            self.m_spr_vs:setVisible(false)
            local animArr = CCArray:create();
            animArr:addObject(CCFadeTo:create(2,155));
            animArr:addObject(CCFadeTo:create(1,255));
            local fadeOutIn = CCRepeatForever:create(CCSequence:create(animArr));
            self.m_spr_battlbg2:runAction( fadeOutIn )
        end

        if self.m_spr_battletitle then
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_serverpk_zhandou.png")
            if frame then
                self.m_spr_battletitle:setDisplayFrame(frame)
            end
        end
    else  -- 正在等待下一场战斗
        countDownTime = math.max(2, self.m_gameData.countdown - serTime)
        if self.m_sprite_light then
            self.m_sprite_light:setVisible(true)
            self.m_spr_vs:setVisible(true)
        end

        if self.m_spr_battletitle then
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_serverpk_wenzi_9.png")
            if frame then
                self.m_spr_battletitle:setDisplayFrame(frame)
            end
        end
    end
    countDownTime = countDownTime + 3

    function timeDownFun(  )
        self:timeEnd()
        -- cclog2(lastTimeLabel, "timeDownFun ==== ")
    end
    local lastTimeLabel = game_util:createCountdownLabel(countDownTime, timeDownFun, 10, 1)
    -- local lastTimeLabel = game_util:createLabelTTF({text = "11111",color = ccc3(250,180,0),fontSize = 16});
    lastTimeLabel:setAnchorPoint(ccp(0, 0.5))
    lastTimeLabel:setPositionY(self.m_node_countdown:getContentSize().height * 0.5)
    lastTimeLabel:setPositionX(posx + 2)
    lastTimeLabel:setVisible(true)
    self.m_node_countdown:addChild(lastTimeLabel)
end


--[[
    创建玩家
]]
function game_server_grouppk_scene.createBigImg(self, roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return game_util:createPlayerBigImgByCfg(itemCfg);
end

--[[--
    刷新ui
]]
function game_server_grouppk_scene.refreshUi(self)
    self:refreshPlayerInfo()
    self:refreshFightInfo()
end

--[[
    矫正服务器时间
]]
function game_server_grouppk_scene.timeEnd( self )
    cclog2(" game_serverpk_scene  倒计时结束 " .. tostring(self.m_nextTime))
    local function responseMethod(tag,gameData)
        local data = gameData and gameData:getNodeWithKey("data")
        self:init({data = data})
        local is_final = data and data:getNodeWithKey("is_final"):toInt() or -1
        if is_final == 0 and self.m_gameData.battle_countdown and self.m_gameData.battle_countdown >= 0 then
            self:refreshUi()
        elseif is_final == 0 and self.m_nextTime == self.m_gameData.countdown then
            self:refreshUi()
        elseif is_final == 0 and self.m_gameData.battle_countdown < 0 then
            self:refreshUi()
            local function responseMethod(tag,gameData)
                game_data:setBattleType( "ui_serverpk" );
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = nil
            local battle_log = self.m_gameData.battle_log;
            if battle_log then
                tempkey = battle_log.battle_log
            end
            cclog2(tempkey, "tempkey   ===   ")
            if tempkey then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_group_replay"), http_request_method.GET, {key = tempkey},"serverpk_group_replay");
            else
               self:refreshUi() 
            end
        else
            self:refreshUi() 
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_battle"), http_request_method.GET, nil,"serverpk_team_battle")   
end


--[[--
    格式化数据
]]
function game_server_grouppk_scene.formatData( self )

    self.m_playerData = {}
    local player1 = {}
    player1.name = self.m_gameData.name
    player1.server_name = self.m_gameData.server_name
    player1.combat = self.m_gameData.combat
    player1.role = self.m_gameData.role
    self.m_playerData["player1"] = player1

    local player2 = {}
    player2.name = self.m_gameData.enemy_name
    player2.server_name = self.m_gameData.enemy_server_name
    player2.combat = self.m_gameData.enemy_combat
    player2.role = self.m_gameData.enemy_role
    self.m_playerData["player2"] = player2

    self.m_myInfo = {}
    self.m_myInfo[1] = self.m_gameData.score or 0
    self.m_myInfo[2] = self.m_gameData.round or 0
    self.m_myInfo[3] = self.m_gameData.hurt or 0
    -- if not safasdf then
    --     safasdf = true
        -- local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    --     self.m_gameData.battle_countdown = serTime + 15
    -- else
    --     self.m_gameData.battle_countdown = -1
    -- end
    self.m_gameData.battle_countdown = self.m_gameData.battle_countdown or -1
    self.m_gameData.countdown = self.m_gameData.countdown or -1
    if self.m_nextTime == nil then
        if self.m_gameData.battle_countdown >= 0 then
            self.m_nextTime = self.m_gameData.battle_countdown
        else
            self.m_nextTime = self.m_gameData.countdown
        end
    end
end


--[[--
    初始化
]]
function game_server_grouppk_scene.init(self,t_params)
    t_params = t_params or {}
    self.m_gameData = {}
    if t_params.data  then
        self.m_gameData = json.decode(t_params.data:getFormatBuffer()) or {}
    end
    self:formatData()
    -- cclog2(self.m_gameData, "self.m_gameData  ===  ")
end
--[[--
    创建ui入口并初始化数据
]]
function game_server_grouppk_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_server_grouppk_scene