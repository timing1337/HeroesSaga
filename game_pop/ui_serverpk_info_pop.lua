--- 擂台战战报

local ui_serverpk_info_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_battlefield_table_node = nil,
    m_topplayer_name = nil,
    m_isShowShareBtn = nil,
    m_logs = nil,
    m_enterType = nil,
};
--[[--
    销毁ui
]]
function ui_serverpk_info_pop.destroy(self)
    -- body
    cclog("-----------------ui_serverpk_info_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_battlefield_table_node = nil;
    self.m_logs = nil;
    self.m_isShowShareBtn = nil;
    self.m_topplayer_name = nil;
    self.m_enterType = nil;
end
--[[--
    返回
]]
function ui_serverpk_info_pop.back(self,backType)
    game_scene:removePopByName("ui_serverpk_info_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_serverpk_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_arena_battlefield_pop.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_battlefield_table_node = ccbNode:nodeForName("battlefield_table_node");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建小组赛
]]
function ui_serverpk_info_pop.createTableView(self,viewSize)
    local showData = self.m_logs

    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag >= 1000 and btnTag < 1100 then
            local index = btnTag - 1000
            self:watchBattleScene( showData[ index + 1 ].battle_log)
        elseif btnTag >= 1100 and btnTag <= 1200 then
            self:shareBattleInfo("server_pk", "serverpk_group_replay", showData[index + 1 ].battle_log)
        end
    end
    local fightCount = #showData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            if self.m_isShowShareBtn then
                ccbNode:openCCBFile("ccb/ui_area_battlefield_item2.ccbi");
            else
                ccbNode:openCCBFile("ccb/ui_arena_battlefield_pop_item.ccbi");
            end
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- 按钮触摸级别
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            btn_relook:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
            local btn_shareinfo = ccbNode:controlButtonForName("btn_shareinfo") or nil
            if btn_shareinfo then
                btn_shareinfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
            end
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local win_icon = ccbNode:spriteForName("win_icon")
            local fight_point_label = ccbNode:labelBMFontForName("fight_point_label")
            local name_label = ccbNode:labelTTFForName("name_label")
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            local btn_shareinfo = ccbNode:controlButtonForName("btn_shareinfo")
            if not self.m_isShowShareBtn and btn_shareinfo then btn_shareinfo:setVisible(false) end

            local item = showData[index + 1]
            m_icon_node:removeAllChildrenWithCleanup(true);
            local attacker = item.attacker
            local defender = item.defender
            local name = ""
            local power = 1
            if game_data:getUserStatusDataByKey("show_name") == attacker then
                name = defender
                power = item.d_combat
            else
                name = attacker
                power = item.a_combat
            end
            local tp = item.tp
            if tp == "attack" then--自己是攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_att.png");
                m_icon_node:addChild(tempSpr,10,10)
                if item.is_win == true then--自己攻击赢了
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                    name_label:setString(string.format(string_helper.ui_serverpk_info_pop.attackWin,name))
                else
                    name_label:setString(string.format(string_helper.ui_serverpk_info_pop.attackLose,name))
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                end
            else--自己是被攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_def.png");
                m_icon_node:addChild(tempSpr,10,10)
                if item.is_win == true then
                    name_label:setString(string.format(string_helper.ui_serverpk_info_pop.attackedWin,name))
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                else
                    name_label:setString(name .. string_helper.ui_serverpk_info_pop.attackedLose)
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                end
            end
            -- name_label:setString(name)
            fight_point_label:setString(tostring(power))

            btn_relook:setTag(1000 + index)
            if btn_shareinfo then 
                btn_shareinfo:setTag(1100 + index)
            end
        end
        cell:setTag(1000 + index);
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建决赛列表
]]
function ui_serverpk_info_pop.createTableView2(self,viewSize)
    local showData = self.m_logs
    local function onHeadBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = 0
        local playertype = 1
        if btnTag >= 2000 then
            index = btnTag - 2000
            playertype = "attacker_uid"
        elseif btnTag >= 1000 then
            index = btnTag - 1000
            playertype = "defender_uid"
        end
        local itemData = showData[index + 1] or {}
        if itemData then
            local uid = itemData[playertype] 
            if uid then
                game_util:lookPlayerInfo(uid, true, 2);
            end
        end
        -- cclog2(itemData, "itemData  =====  ")
    end
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag >= 1000 and btnTag < 1100 then
            local index = btnTag - 1000
            self:watchBattleScene( showData[ index + 1 ].battle_log)
        elseif btnTag >= 1100 and btnTag <= 1200 then
            self:shareBattleInfo("server_pk", "serverpk_group_replay", showData[index + 1 ].battle_log)
        end
    end
    local fightCount = #showData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY- 11;
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_serverpk_battleinfo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- 按钮触摸级别
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            btn_relook:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
            game_util:setCCControlButtonTitle(btn_relook,string_helper.ccb.title72)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            local itemData = showData[index + 1]
            local isAttackPlayerWin = false
            if itemData.is_win == 1 then isAttackPlayerWin = true end
            do
                -- 左边玩家
                self:refreshOnePlayerInfo(ccbNode, 1, itemData.attacker_role, itemData.attacker, isAttackPlayerWin, 1000 + index, onHeadBtnCilck )
                -- 右边玩家信息
                self:refreshOnePlayerInfo(ccbNode, 2, itemData.defender_role, itemData.defender, not isAttackPlayerWin, 2000 + index, onHeadBtnCilck )
            end

            btn_relook:setTag(1000 + index)
        end
        cell:setTag(1000 + index);
        return cell;
    end

    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end

function ui_serverpk_info_pop.refreshOnePlayerInfo( self, ccbNode, playerID, roleID, playerName, isWin, playerUidIndex, btnFun )
    local  m_node_playerinfo = ccbNode:nodeForName("m_node_playerinfo" .. playerID)
    if m_node_playerinfo then 
        --头像
        local role = roleID or 1
        local icon = game_util:createPlayerIconByRoleId(tostring(role));
        local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
        if icon then
            m_node_playerinfo:removeAllChildrenWithCleanup(true)
            icon_alpha:setAnchorPoint(ccp(0.5,0.5))
            icon_alpha:setPosition(m_node_playerinfo:getContentSize().width * 0.5, m_node_playerinfo:getContentSize().height * 0.6)
            icon_alpha:setOpacity(100)
            icon_alpha:setColor(ccc3(0,0,0))
            m_node_playerinfo:addChild(icon_alpha)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(m_node_playerinfo:getContentSize().width * 0.5, m_node_playerinfo:getContentSize().height * 0.6)
            m_node_playerinfo:addChild(icon);

            self:createTouchButton({fun = btnFun, parent = m_node_playerinfo, tag = playerUidIndex})
        else
            cclog("tempFrontUser.role " .. tostring(user_info.role) .. " not found !")
        end
    end
    -- 胜负icon
    local m_sprite_winicon = ccbNode:spriteForName("m_sprite_winicon" .. playerID)
    if isWin then
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png")
        if frame then
            m_sprite_winicon:setDisplayFrame(frame)
        end
    else
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png")
        if frame then
            m_sprite_winicon:setDisplayFrame(frame)
        end
    end

    local m_label_name = ccbNode:labelTTFForName("m_label_name" .. playerID)
    if m_label_name then m_label_name:setString(tostring(playerName)) end
    -- m_label_name:setString("------")
end

--[[--
    创建一个接受触摸事件的button
]]
function ui_serverpk_info_pop.createTouchButton( self, params )
    if not params.parent then return end
    local button = game_util:createCCControlButton(params.sprName or "public_weapon.png","",params.fun)
    local tempSize = params.parent:getContentSize()
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(ccp(tempSize.width * (anchorX or 0.5), tempSize.height* (anchorY or 0.5)))
    if not params.isShow then
        button:setOpacity(0)
    end
    params.parent:addChild(button)
    button:setTag(params.tag)
    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
end


--[[
    查看战斗信息
]]
function ui_serverpk_info_pop.watchBattleScene( self, battleKey )
    -- cclog2(battleKey, "battleKey === ")
    -- cclog2(battleURL, "battleKey === ")
    -- cclog2(battleKey, "battleKey === ")
    if self.m_enterType == 1 then
        battleURL = "serverpk_group_replay"
    else
        battleURL = "serverpk_team_final_replay"
    end
    local function responseMethod(tag,gameData)
        game_data:setBattleType( "ui_serverpk" );
        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        self:destroy();
    end
    local tempkey = battleKey;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(battleURL), http_request_method.GET, {key = tempkey},battleURL);
end

--[[
    分享战斗信息到聊天
]]
function ui_serverpk_info_pop.shareBattleInfo( self )
    
end


--[[--
    刷新ui
]]
function ui_serverpk_info_pop.refreshUi(self)
    self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = nil
    if self.m_enterType == 1 then
        tableViewTemp = self:createTableView(self.m_battlefield_table_node:getContentSize());
    else
        tableViewTemp = self:createTableView2(self.m_battlefield_table_node:getContentSize());
    end
    tableViewTemp:setScrollBarVisible(false)
    self.m_battlefield_table_node:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_serverpk_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_logs = {}
    local data =  t_params.gameData and t_params.gameData:getNodeWithKey("data")
    self.m_logs = data and json.decode(data:getNodeWithKey("log"):getFormatBuffer()) or {}
    self.m_isShowShareBtn = t_params.showShareBtn or false
    -- cclog2(self.m_logs, "self.m_logs   ===   ")
    self.m_enterType = t_params.enterType or 1
end

--[[--
    创建ui入口并初始化数据
]]
function ui_serverpk_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_serverpk_info_pop;