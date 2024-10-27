---  跨服擂台  主页->活动->擂台:决赛

local game_serverpk_scene = {
    m_gameData = nil,
    m_showData = nil,
    m_points = nil,
    m_node_nexttime = nil,
    m_playerInfo = nil,
    m_nameLabels = nil,
    m_nameLabeBgs = nil,
    m_winCount = nil,
    m_highlightLines = nil,
    m_winUid = nil,
    m_node_centerboard1 = nil,
    m_node_centerboard2 = nil,
    m_label_playerName1 = nil,
    m_label_playerSer1 = nil,
    m_heighlightBoard = nil,
    m_heighlineNumbers = nil,
}
-- 颜色
local Line_Color_Type = 
{
    gold = ccc4f(253 / 255.0, 230 / 255.0, 90 / 255.0,1) ,  -- 金色
    brown = ccc4f(130 / 255.0, 71 / 255.0, 38 / 255.0,1),     -- 棕色 
    gray = ccc4f(113 / 255.0,112 / 255.0,113 / 255.0,1),
    black = ccc4f( 0, 0, 0, 1),
}
--[[--
    销毁ui
]]
function game_serverpk_scene.destroy(self)
    -- body
    cclog("----------------- game_serverpk_scene destroy-----------------"); 
    self.m_gameData = nil;
    self.m_showData = nil;
    self.m_points = nil;
    self.m_node_nexttime = nil;
    self.m_playerInfo = nil;
    self.m_nameLabels = nil;
    self.m_nameLabeBgs = nil;
    self.m_winCount = nil;
    self.m_highlightLines = nil;
    self.m_winUid = nil;

    self.m_node_centerboard1 = nil;
    self.m_node_centerboard2 = nil;
    self.m_label_playerName1 = nil;
    self.m_label_playerSer1 = nil;
    self.m_heighlightBoard = nil;
    self.m_heighlineNumbers = nil;
end

--[[--
    返回
]]
function game_serverpk_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end

--[[--
    读取ccbi创建ui
]]
function game_serverpk_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then -- 排行榜
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_serverpk_rank",{gameData = gameData, showType = 2});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_final_battle_rank"), http_request_method.GET, nil,"serverpk_team_final_battle_rank")
        elseif btnTag == 102 then -- 玩法说明
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "135"})
        elseif btnTag == 103 then -- 战斗记录
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_serverpk_info_pop",{gameData = gameData, enterType = 2});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_final_combat_log"), http_request_method.GET, nil,"serverpk_team_final_combat_log")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_activity_serverpk.ccbi");

    self.m_node_nexttime = ccbNode:nodeForName("m_node_nexttime")
    self.m_node_centerboard1 = ccbNode:nodeForName("m_node_centerboard1")
    self.m_node_centerboard2 = ccbNode:nodeForName("m_node_centerboard2")
    self.m_label_playerName1 = ccbNode:labelTTFForName("m_label_playerName1")
    self.m_label_playerSer1 = ccbNode:labelTTFForName("m_label_playerSer1")
    local m_clayer_blaskmask = ccbNode:layerColorForName("m_clayer_blaskmask")
    m_clayer_blaskmask:setOpacity( 80 )
    m_clayer_blaskmask:setVisible(true)

    local m_node_mainboard = ccbNode:nodeForName("m_node_mainboard")
    local m_node_playinfoboard = ccbNode:nodeForName("m_node_playinfoboard")
    local battleBg = CCSprite:create("battle_ground/back_carpark.jpg")
    battleBg:setColor(ccc3(200,200,200))
    battleBg:setPosition(m_node_mainboard:getContentSize().width * 0.5, m_node_mainboard:getContentSize().height * 0.5)
    m_node_mainboard:addChild(battleBg, - 10)
    self.m_heighlightBoard = CCNode:create()
    m_node_playinfoboard:addChild(self.m_heighlightBoard, 10)

    local size = m_node_playinfoboard:getContentSize()
    local drawNode = ExtDrawNode:create(size,0);
    m_node_playinfoboard:addChild(drawNode, -1);
    function onButtonClicked( event, target )
        local node = tolua.cast(target, "CCNode")
        local btnTag = node:getTag()
        local uid = self.m_gameData.uid_list[btnTag]
        if uid == "" or uid == "null" then
            game_util:addMoveTips({text = string_helper.game_serverpk_scene.text})
        else
            game_util:lookPlayerInfo( uid , true, 2)
        end
    end
    local playerNodePointsStarts = {}
    local playerNameLabels = {}
    local playerNameLabelBgs = {}
    local tempNode = nil
    for i=1,16 do
        local nameLabel = ccbNode:labelTTFForName("m_label_name" .. i)
        playerNameLabels[tostring(i)] = nameLabel
        tempNode = ccbNode:nodeForName("m_node_player" .. i)
        playerNameLabelBgs[tostring(i)] = tempNode
        if tempNode then
            local x, y = tempNode:getPosition()
            if i < 9 then
                table.insert(playerNodePointsStarts, {x + tempNode:getContentSize().width, y})
            else
                table.insert(playerNodePointsStarts, {x - tempNode:getContentSize().width, y})
            end
            self:createTouchButton(onButtonClicked , tempNode, i)
        end
    end
    self.m_nameLabels = playerNameLabels
    self.m_nameLabeBgs = playerNameLabelBgs
    self.m_points = {}
    self.m_points = playerNodePointsStarts
    
    self.m_drawNode = drawNode
    -- self:refreshWinerLine( drawNode, heightLines )
    return ccbNode;
end

--[[--
    创建一个接受触摸事件的button
]]
function game_serverpk_scene.createTouchButton( self, fun, parent, tag , anchorX, anchorY)
    if not parent then return end
    local button = game_util:createCCControlButton("public_weapon.png","",fun)
    local tempSize = parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    button:setOpacity(0)
    button:setPreferredSize(tempSize)
    parent:addChild(button)
    button:setTag(tag)
end

--[[
    高亮线
]]
function game_serverpk_scene.refreshWinerLine( self, drawNode, linesGroup )
    local pix = 10.0
    -- cclog2(linesGroup, "refreshWinerLine  linesGroup   ====   ")
    local delayTime = 0
    local actionArray = CCArray:create()
    for i=1,16 do
        local v = linesGroup[tostring(i)]
        if v then
            actionArray:addObject(CCDelayTime:create( delayTime ))
            -- cclog2(delayTime, "delayTime  =====  ")
            -- cclog2(i, "i  =====  ")
            local oneLine = v[1]
            if oneLine then
                local length =  math.abs(oneLine["line"][1][1] - oneLine["line"][2][1] + oneLine["line"][1][2] - oneLine["line"][2][2] )
                delayTime = delayTime + length / pix
                -- cclog2(length, "length  =====  ")
                local callfunc = CCCallFunc:create(function ( )
                    local tempNode = CCNode:create()
                    drawNode:addChild(tempNode)
                    local t = 0
                    local dx = oneLine.dx or 1
                    local dy = oneLine.dy or 1
                    schedule(tempNode, function ()
                        for kk,vv in pairs(v) do
                            local startPoint = vv["line"][1]
                            local endPoint = { startPoint[1] + dx * t, startPoint[2] + dy * t}
                            drawNode:drawLine(ccp(startPoint[1],startPoint[2]), ccp(endPoint[1],endPoint[2]), 1, 
                            Line_Color_Type[ vv.colorType ] or ccc4f(255/255, 238/255, 0, 1))
                            t = t + length / pix
                            if t > length then
                                tempNode:stopAllActions()
                                tempNode:removeFromParentAndCleanup(true)
                            end  
                        end
                    end, 1 / pix)
                end)
                actionArray:addObject( callfunc )
            end
        end
    end
    local sequence = CCSequence:create( actionArray )
    drawNode:runAction( sequence )
end

--[[
    刷新参赛选手信息
]]
function game_serverpk_scene.refreshPlayerInfo( self )
    local playerUid = self.m_gameData.uid_list or {}
    local playerInfo = self.m_gameData.info or {}
    for i=1, 16 do
        local uid = playerUid[i] or ""
        local player = {}
        if uid ~= "" then
            -- cclog2(uid, "uid ===  ")
            player = playerInfo[tostring(uid)] or {}
        end
        local nameLabel = self.m_nameLabels[tostring(i)]
        if nameLabel then
            -- nameLabel:setFontSize(9)
            local name = player.name or string_helper.game_serverpk_scene.ornull
            nameLabel:setString(name)
        end
    end
end

--[[
    刷新冠军信息
]]
function game_serverpk_scene.refreshWiner( self )
    local playerInfo = self.m_gameData.info or {}
    if not self.m_winUid then 
        self.m_node_centerboard1:setVisible(true)
        self.m_node_centerboard2:setVisible(false)
        return 
    end
    self.m_node_centerboard1:setVisible(false)
    self.m_node_centerboard2:setVisible(true)

    local winner = playerInfo[self.m_winUid]
    local roldID = 1
    local half = game_util:createRoleBigImgHalf( winner.role )
    half:setAnchorPoint(ccp(0.5,0))
    half:setPositionX(self.m_node_centerboard2:getContentSize().width * 0.5)
    self.m_node_centerboard2:addChild(half, -1)
    self.m_label_playerName1:setString( winner.name )
    self.m_label_playerSer1:setString(winner.server_name)
    self.m_node_centerboard2:setScale(0.8)

    function onButtonClicked( event, target )
        game_util:lookPlayerInfo(self.m_winUid)
    end

    local tempSize = self.m_node_centerboard2:getContentSize()
    self:createTouchButton(onButtonClicked , self.m_node_centerboard2, 0)

end

--[[
    刷新线
]]
function game_serverpk_scene.refreshLine( self )
    -- self:initOtherPosints()
    -- self:initLines()
    local lines, heightLines = self:initLines()
    -- 画底下的黑色宽线
    for k,v in ipairs(lines) do
        self.m_drawNode:drawLine(ccp(v["line"][1][1],v["line"][1][2]), ccp(v["line"][2][1],v["line"][2][2]), 1.5, 
             ccc4f(0, 0, 0, 1))
    end
    -- 画上面的灰色线
    for k,v in ipairs(lines) do
        self.m_drawNode:drawLine(ccp(v["line"][1][1],v["line"][1][2]), ccp(v["line"][2][1],v["line"][2][2]), 0.5, 
            Line_Color_Type[ "gray" ])
    end

    self.m_heighlightBoard:removeAllChildrenWithCleanup(true)
    -- 画4组高亮线线
    local perNum = self.m_heighlineNumbers - 1
    local perNum = 5
    -- 先描绘出最后一组前面的线
    for i=1, perNum do
        self:drawOneLevelScale9Lines(heightLines, i - 1)
    end
    -- 描绘最后一组线
    -- self:drawOneLevelScale9LinesWithAni(heightLines, self.m_heighlineNumbers)
end

--[[--
    刷新ui
]]
function game_serverpk_scene.refreshUi(self)
    cclog2("---------refreshUi---------")
    self:refreshPlayerInfo()
    self:refreshLine()
    self:refreshCountDown()
    self:refreshWiner()
    local lines, heightLines = self:initLines()
    -- self:drawOneLeveLines(heightLines, 1, 5)
    -- self:drawOneLine()

    local winerId = self:initLightLine()
    local lastWinerId = winerId[tostring( winerId.fightCount )] or nil
    -- cclog2(winerId, "winerId  ===  ")
    -- cclog2(lastWinerId, "lastWinerId  ===  ")
    for i=1, 16 do
        local bg = self.m_nameLabeBgs[tostring(i)]
        local nameLabel = self.m_nameLabels[tostring(i)]
        if bg then
            if lastWinerId == nil or lastWinerId[tostring(i)] == true then
                -- bg:removeChildByTag( 987 )
                -- print(i .. " 是上场比赛的赢家  恭喜他们")
                local scale9bgNode = bg:getChildByTag(22)
                scale9bg = tolua.cast(scale9bgNode, "CCScale9Sprite")
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_serverpk_enniu_win.png")
                if scale9bg and frame then
                    scale9bg:setSpriteFrame(frame)
                end
                -- self:setColor(bg,  ccc3(255,255,255))
                if nameLabel then
                    nameLabel:setColor(ccc3(255,255,0))
                end
            else
                local scale9bgNode = bg:getChildByTag(22)
                scale9bg = tolua.cast(scale9bgNode, "CCScale9Sprite")
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_serverpk_enniu_lose.png")
                if scale9bg and frame then
                    scale9bg:setSpriteFrame(frame)
                end
                -- self:setColor(bg, ccc3(200,200,200))
                if nameLabel then
                    nameLabel:setColor(ccc3(155,155,155))
                end
            end
        end
    end

end

--[[
    倒计时按钮
]]
function game_serverpk_scene.refreshCountDown( self )
    -- self.m_gameData.countdown = -1
    local countdownTime = self.m_gameData.countdown or -1
    if countdownTime < 0 then
        self.m_node_nexttime:removeAllChildrenWithCleanup(true)
        local endLabel = game_util:createLabelTTF({text = string_helper.game_serverpk_scene.text2, fontSize = 10})
        endLabel:setAnchorPoint(ccp(0, 0.5))
        endLabel:setPositionY(self.m_node_nexttime:getContentSize().height * 0.5)
        endLabel:setPositionX(2)
        self.m_node_nexttime:addChild(endLabel)
        return 
    end

    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    cclog2(serTimeT, "serTime   ===   ")
    local nextTime = (self.m_gameData.countdown - serTime )
    if nextTime <= 0 then
        nextTime = 5
    end
    nextTime = nextTime + 6
    -- cclog2(nextTime, "nextTime ==== ")
    function timeDownFun(  )
        self:timeEnd()
        -- cclog2("timeDownFun  ===  ", "timeDownFun ==== ")
    end


    self.m_node_nexttime:removeAllChildrenWithCleanup(true)
    local lastTimeLabel = game_util:createCountdownLabel(nextTime, timeDownFun, 10, 1)
    -- local lastTimeLabel = game_util:createLabelTTF({text = "11111",color = ccc3(250,180,0),fontSize = 16});
    lastTimeLabel:setPositionY(self.m_node_nexttime:getContentSize().height * 0.5)
    lastTimeLabel:setAnchorPoint(ccp(0, 0.5))
    lastTimeLabel:setPositionX(2)
    lastTimeLabel:setVisible(true)
    self.m_node_nexttime:addChild(lastTimeLabel)
    -- cclog2(lastTimeLabel, "lastTimeLabel ==== ")
end

--[[
    置灰
]]
function game_serverpk_scene.setColor( self , node, color)
    local items = node:getChildren();
    local itemCount = items:count();
    for i = 1,itemCount do
        tempItem = tolua.cast(items:objectAtIndex(i - 1),"CCNodeRGBA");
        if tempItem and tempItem.setColor then
            tempItem:setColor(color)
        end
    end
end

--[[
    倒计时结束事件
]]
function game_serverpk_scene.timeEnd( self )
    cclog2(" game_serverpk_scene  倒计时结束 ")
    local function responseMethod(tag,gameData)
        local data = gameData and gameData:getNodeWithKey("data")
        local is_final = data and data:getNodeWithKey("is_final"):toInt() or -1
        if is_final == 0 then
            game_scene:enterGameUi("game_server_grouppk_scene",{data = data})
        elseif is_final == 1 then
            self:init({data = data})
            self:refreshUi()
            -- game_scene:enterGameUi("game_serverpk_scene",{data = data});
            -- self:destroy();
        else
            -- 数据错误
            cclog2("数据错误   ====== ")
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("serverpk_team_battle"), http_request_method.GET, nil,"serverpk_team_battle")
end

--[[
    获取点亮的线
]]
local tempWiner = {0,4,1,0,0,1,2,0,0,1,3,0,1,0,2,0}
function game_serverpk_scene.initLightLine( self )
    local tempLine = util.table_copy(self.m_winCount)
    -- local tempLine = util.table_copy(tempWiner)
    local linesId = {}
    for i=1,4 do
        -- print("  第" .. i .. "轮比赛开始了  。。。。。。")
        local lineId = {}
        local isFight = false
        for ii=1,16 do
            if tempLine[ tostring(ii) ] > 0 then
                -- print("id 为 " .. ii .. "的选手胜利了")
                lineId[tostring(ii)] = true
                tempLine[tostring(ii) ] = tempLine[tostring(ii) ] - 1
                isFight = true
            end
        end
        linesId[tostring(i)] = lineId
        if isFight then linesId.fightCount = i end
    end
    return linesId
end

--[[
    获取下一次战斗的玩家位置id
]]
function game_serverpk_scene.getNextFightPlayers( self )
    local tempcount = util.table_copy(self.m_winCount)
    local winTimeMaxPlayer = {}
    local maxCount = 0
    for i=1, 16 do
    end
end

--[[
    画一个阶段的9图线  一个阶段为一场战斗
]]
function game_serverpk_scene.drawOneLevelScale9Lines( self, linesInfo, level )
    level = level or 0
    linesInfo = linesInfo or {}
    local linesGroup = linesInfo[ tostring(level) ] or {}
    -- 画本组的横线和竖线
    for i=1,2 do
        local lines = linesGroup[ tostring(i) ] or {}
        for k,v in pairs(lines) do
            self:drawOneScale9Line(v)
        end
    end
end

--[[
    -- 渐渐画一组线动画
]]
function game_serverpk_scene.drawOneLevelScale9LinesWithAni( self, linesInfo, level, isAnimate, endFun )
    level = level or 0
    linesInfo = linesInfo or {}
    local linesGroup = linesInfo[ tostring(level) ] or {}
    -- 画本组的横线和竖线

    local lines1 = linesGroup[ tostring(1) ] or {}
    local lines2 = linesGroup[ tostring(2) ] or {}
    function drawSecondLine(  )
        self:drawOneScale9LineWithAni( lines2, true, nil )
    end
    self:drawOneScale9LineWithAni(lines1, true, drawSecondLine )
end

--[[
    -- 画一条线（有动画）
]]
function game_serverpk_scene.drawOneScale9LineWithAni( self, lineInfo, isAnimate, endFun  )
    lineInfo = lineInfo or {}
    local startPoint = lineInfo["line"][1]
    local endPoint = lineInfo["line"][2]
    local length = math.abs(startPoint[1] - endPoint[1] + startPoint[2] - endPoint[2])
    local temprect = CCSizeMake(length + 2.5,6)

    local heighline = CCScale9Sprite:createWithSpriteFrameName("ui_serverpk_tiao.png")
    -- heighline:setScaleY(6/8.0)
    heighline:setPreferredSize(temprect)
    local anchorPoint = ccp(0, 0.5)
    local pos = startPoint
    local angle = 0
    local scals
    if lineInfo.dx == -1 then
        pos = {endPoint[1] - 1, endPoint[2]}
    elseif lineInfo.dx == 1 then
        pos = {startPoint[1] -1, startPoint[2]}
    end

    if lineInfo.dy == 1 then
        pos = {startPoint[1], startPoint[2] - 1 }
        angle = 270
        temprect = CCSizeMake(length + 5,8)
    elseif lineInfo.dy == -1 then
        pos = {startPoint[1] + 0.5 , startPoint[2] + 1}
        angle = 90
        temprect = CCSizeMake(length + 3.5,8)
    end
    heighline:setAnchorPoint(anchorPoint)
    heighline:setPosition(pos[1], pos[2])
    heighline:setRotation(angle)
    self.m_heighlightBoard:addChild(heighline)
end

--[[
    画一条9图线
]]
function game_serverpk_scene.drawOneScale9Line( self, lineInfo )
    lineInfo = lineInfo or {}
    -- cclog2(lineInfo, "lineInfo   ===   ")
    local startPoint = lineInfo["line"][1]
    local endPoint = lineInfo["line"][2]
    local length = math.abs(startPoint[1] - endPoint[1] + startPoint[2] - endPoint[2])
    local temprect = CCSizeMake(length + 2.5,6)

    local heighline = CCScale9Sprite:createWithSpriteFrameName("ui_serverpk_tiao.png")
    -- heighline:setScaleY(6/8.0)
    heighline:setPreferredSize(temprect)
    local anchorPoint = ccp(0, 0.5)
    local pos = startPoint
    local angle = 0

    if lineInfo.dx == -1 then
        pos = {endPoint[1] - 1, endPoint[2]}
    elseif lineInfo.dx == 1 then
        pos = {startPoint[1] -1, startPoint[2]}
    end

    if lineInfo.dy == 1 then
        pos = {startPoint[1], startPoint[2] - 1 }
        angle = 270
        temprect = CCSizeMake(length + 5,8)
    elseif lineInfo.dy == -1 then
        pos = {startPoint[1] + 0.5 , startPoint[2] + 1}
        angle = 90
        temprect = CCSizeMake(length + 3.5,8)
    end

    -- if lineInfo.dy ~= 0 then
    -- print("dx, dy, angle", lineInfo.dx, lineInfo.dy, angle)
    heighline:setAnchorPoint(anchorPoint)
    heighline:setPosition(pos[1], pos[2])
    heighline:setRotation(angle)
    if lineInfo.colorType == "gray" then 
        -- heighline:setOpacity(130)
        heighline:setColor(ccc3(200,200,200))
    else
        heighline:setColor(ccc3(255,255,255))
    end
    self.m_heighlightBoard:addChild(heighline)
end

-------------------------------------------------------------
--[[
    画一条线
]]
function game_serverpk_scene.drawOneLine( self, line, dx, dy, color )
    dy = dy or 0
    dx = dx or 0
    color = color or ccc4f(255/255, 238/255, 0, 1)
    -- line = {{400, 100}, {100, 100}}
    -- local dl = line[1][1] - line[2][1] + line[1][2] - line[2][2]
    -- local length = math.abs(dl)
    local node = CCNode:create()
    local startPoint = line[1]
    local endPoint = {line[1][1], line[1][2]}
    self.m_drawNode:addChild(node)
    schedule(node, function (  )
        if ( dx > 0 and endPoint[1] >= line[2][1] ) or (dx < 0 and  endPoint[1] <= line[2][1] ) or 
            (dy > 0 and endPoint[2] >= line[2][2] ) or (dy < 0 and  endPoint[2] <= line[2][2])
        then
            node:stopAllActions()
            node:removeFromParentAndCleanup(true)
        end
        endPoint = {endPoint[1] + dx, endPoint[2] + dy}
        -- cclog2(endPoint[1], "endPoint[1]   ====  ")
        self.m_drawNode:drawLine(ccp(startPoint[1],startPoint[2]), ccp(endPoint[1],endPoint[2]), 0.5, color)
    end, 1 / 64)
end

--[[
    画一个阶段的线 一个阶段为一场战斗
]]
function game_serverpk_scene.drawOneLeveLines( self, heightLines, level, delayTime )
    local node = CCNode:create()
    self.m_drawNode:addChild(node)
    performOtherWithDelay(node, function ()
        local linesGroup = heightLines[tostring(level)]
        for i,v in pairs(linesGroup) do
            -- cclog2(v , "linesGroup   v ===   ")
            for kk,vv in pairs(v) do
                -- print(kk,vv)
                self:drawOneLine(vv.line, vv.dx, vv.dy , vv.color)
            end
        end
        -- body
    end, delayTime)
end

-------------------------------------------------------------
function game_serverpk_scene.initLines( self )
    local winerId = self:initLightLine()
    local lastWinerId = winerId[tostring( winerId.fightCount )] or {}
    cclog2(winerId, "winerId  ===  ")
    local count = #self.m_points
    local width = (self.m_points[count][1] - self.m_points[1][1]) / 8 - 5
    local height = {}
    height[1] = (self.m_points[1][2] - self.m_points[2][2]) * 0.5 + 1
    height[2] = (self.m_points[1][2] - self.m_points[4][2]) * 0.5 - height[1] + 1
    height[3] = (self.m_points[1][2] - self.m_points[8][2]) * 0.5 - height[2] - height[1] + 1
    height[0] = (self.m_points[1][2] - self.m_points[8][2]) * 0.5 - height[2] - height[1]
    local lineNumbers = 0
    local lines = {}
    local heightLines = {}
    for i=1, 4 do
        local tempLineGroup = {}
        tempLineGroup["1"] = {}
        tempLineGroup["2"] = {}
        local level = math.pow(2, i - 1)
        local lineCount = count / level
        -- cclog2(lineCount, "lineCount  ===  ")
        for ii=1, lineCount do
            tempWidth = width
            local tempPoints = {}
            local x = 0
            local y = 0
            x = self.m_points[ii * level][1]
            local dy = 0
            local isWinH = false
            local isEndWinH = false
            for iii=1, level do
                if winerId[tostring(i)][tostring((ii - 1) * level + iii)] == true then
                    isWinH = true
                end 
                if lastWinerId[tostring((ii - 1) * level + iii)] == true then
                    isEndWinH = true
                end
            end
            for iii=1, level do
                local index = (ii - 1) * level + iii 
                y = y + self.m_points[index][2]
            end
            y = y / level
            local points = {}
            local startPos = self.m_points[ii]
            local startX = startPos[1] + width * ( i - 1)
            -- 横线
            local line1Info = {dx = 1, dy = 0}
            local otherX = 0
            if i == 4 then
                otherX = 8
            end
            line1Info.lenght = width
            if ii > lineCount * 0.5 then
                -- 横线从右到左
                line1Info.line = {{x - tempWidth * (i - 1) , y }, {x - tempWidth * (i) - 1 - otherX , y}}
                line1Info.dx = -1
                tempWidth = -1 * width
            else
                -- 横线从左到右
                line1Info.line = {{x + tempWidth * (i - 1), y }, {x + tempWidth * i + 1 + otherX , y}}
            end
            if isWinH then 
                line1Info = util.table_copy(line1Info)
                if not isEndWinH then line1Info.colorType = "gray" end
                table.insert(tempLineGroup["1"], line1Info)
                lineNumbers = i
            else
                table.insert(lines, 1, line1Info)
            end

            -- 竖线
            local dh = height[i] or 0
            -- if ii % 2 == 1 then dh = -1 * ( height[i] or 0 ) end
            local line2Info = {dx = 0, dy = 1}
            line2Info.lenght = dh
            if ii % 2 == 1 then 
                -- 竖线从上到下
                line2Info.line = {{x + tempWidth * i , y}, {x + tempWidth * i, y - dh}}
                line2Info.dy = -1
            else
                -- 竖线从下到上
                line2Info.line = {{x + tempWidth * i , y}, {x + tempWidth * i, y + dh}}
            end
            if isWinH then 
                line2Info = util.table_copy(line2Info)
                if not isEndWinH then line2Info.colorType = "gray" end
                table.insert(tempLineGroup["2"], line2Info)
                lineNumbers = i
            else
                table.insert(lines, 1, line2Info)
            end
        end
        heightLines[tostring(i)] = tempLineGroup
    end
    self.m_heighlineNumbers = lineNumbers
    return lines , heightLines
end


--[[--
    格式化数据
]]
function game_serverpk_scene.formatData( self )
    self.m_heighlineNumbers = 0
    local playerUid = self.m_gameData.uid_list or {}
    local playerInfo = self.m_gameData.info or {}
    self.m_winCount = {}
    for i=1, 16 do
        local uid = playerUid[i] 
        if uid ~= "" and playerInfo[uid] then
            self.m_winCount[ tostring(i) ] = playerInfo[uid].final_win_num or 0
        else
            self.m_winCount[ tostring(i) ] = 0
        end
    end
    local playerInfo = self.m_gameData.info or {}
    local winnerUid = nil
    for k,v in pairs(playerInfo) do
        if v.final_win_num == 4 then
            self.m_winUid = k
        end
    end
end

--[[--
    初始化
]]
function game_serverpk_scene.init(self,t_params)
    t_params = t_params or {}
    self.m_gameData = {}
    if t_params.data  then
        self.m_gameData = json.decode(t_params.data:getFormatBuffer()) or {}
    end
    -- cclog2(self.m_gameData, "self.m_gameData  ===  ")
    self:formatData()
end
--[[--
    创建ui入口并初始化数据
]]
function game_serverpk_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_serverpk_scene