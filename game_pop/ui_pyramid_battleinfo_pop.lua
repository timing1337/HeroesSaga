--- 金字塔战报

local ui_pyramid_battleinfo_pop = {
    m_root_layer = nil,
    m_node_battleinfo_board = nil,
    m_topplayer_name = nil,
    log_info = nil,
    m_openType = nil,
    m_gameData = nil,
    m_enterType = nil,
};


function ui_pyramid_battleinfo_pop.getBattleInfo(self, winer, loser)
    print("winer, loser   ======  ", winer, loser)
    local player = {WINER = winer or "", LOSER = loser or ""}
    local info = battleInfo["topplayer_info" .. math.random(1, 5)] or ""
    print("inco ======= ", info)
    info = string.gsub(info, "[WINER,LOSER]+", function ( key )
        return player[key] or key
    end )
    return info
end

--[[--
    销毁ui
]]
function ui_pyramid_battleinfo_pop.destroy(self)
    -- body
    cclog("-----------------ui_pyramid_battleinfo_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_node_battleinfo_board = nil;
    self.log_info = nil;
    self.m_openType = nil;
    self.m_topplayer_name = nil;
    self.m_gameData = nil;
    self.m_enterType = nil;
end
--[[--
    返回
]]
function ui_pyramid_battleinfo_pop.back(self,backType)
    game_scene:removePopByName("ui_pyramid_battleinfo_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_pyramid_battleinfo_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_battleinfo_pop.ccbi");


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);


    local m_btn_close = ccbNode:controlButtonForName("m_btn_close");
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_node_battleinfo_board = ccbNode:nodeForName("m_node_battleinfo_board");

    return ccbNode;
end

--[[
    为文字添加颜色值
]]
function ui_pyramid_battleinfo_pop.addStringColor( self, msg, color )
    if not msg or msg == "" then return "" end
    if not color then return msg end
    return "[color=" .. color .. "]" .. tostring(msg) .. "[/color]"

end


--[[--
    金字塔战报
]]
function ui_pyramid_battleinfo_pop.createTableViewTopPlayer(self,viewSize)
    local showData = {}
    for i,v in ipairs(self.m_gameData.log) do
        table.insert(showData, 1, v)
    end
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag + 1]
        self:watchBattleInfo(itemData.battle_log)
    end

    local itemCount = math.max(#showData , 1);
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    params.totalItem = itemCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_pyramid_battleinfo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));          
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local itemData = showData[index + 1]
                local m_node_msgboard = ccbNode:labelTTFForName("m_node_msgboard")
                local m_btn_reshow = ccbNode:controlButtonForName("m_btn_reshow")
                local m_node_timeboard = ccbNode:nodeForName("m_node_timeboard")
                game_util:setCCControlButtonTitle(m_btn_reshow,string_helper.ccb.title103)
                m_btn_reshow:setTag(index)
                m_btn_reshow:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
                m_node_msgboard:removeAllChildrenWithCleanup(true)
                m_node_timeboard:removeAllChildrenWithCleanup(true)
                if #showData > 0 then

                    -- local formatBattleInfo = function ( info )
                    --     info = info or {}
                    --     local attacker = info.attacker or ""
                    --     local defender = info.defender or ""
                    --     attacker = self:addStringColor(attacker, "ff00ff00")
                    --     defender = self:addStringColor(defender, "ff00ff00")
                    --     local attCurLevel = info.battle_floor or ""
                    --     local attCurPos = info.battle_pos or ""
                    --     local attLostMorale = info.attacker_morale or nil
                    --     local defLostMorale = info.defender_morale or nil
                    --     local msg = ""
                    --     if info.is_win < 1 then
                    --         msg = msg .. attacker .. "挑战" .. defender .. "失败" 
                    --         if attCurLevel >= 1 then
                    --             msg = msg .. "，" .. attacker .. "位置下降为" .. attCurLevel .. "层" .. attCurPos .. "位"
                    --         else
                    --             if attCurLevel == 0 then
                    --                 msg = msg .. "，" .. attacker .. "跌出血之金字塔,士气回复为100%"
                    --             elseif attLostMorale then 
                    --                 msg = msg .. "，".. "士气下降" .. attLostMorale 
                    --             end
                    --         end
                    --     else
                    --         msg = msg .. attacker .. "挑战" .. defender .. "成功，" .. attacker .. "位置上升为" .. attCurLevel .. "层" .. attCurPos .. "位"
                    --     end

                    --     if attCurLevel == 20 then
                    --         msg = msg .. "，" ..  defender .. "跌出血之金字塔,士气回复为100%" 
                    --     elseif defLostMorale then
                    --         msg = msg .. "，" .. defender .. "士气下降" .. defLostMorale 
                    --     end
                    --     return msg
                    -- end
                    local msg = itemData.msg or ""
                    -- {text = text,dimensions = CCSizeMake(labelWidth - 10, 0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment,color = ccc3(221,221,192)}
                    local tempRichLabel = game_util:createRichLabelTTF({text = msg, dimensions = CCSizeMake(m_node_msgboard:getContentSize().width - 5, 0),
                        textAlignment = kCCTextAlignmentLeft, verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(200,255,255),fontSize = 10})
                    tempRichLabel:setAnchorPoint(ccp(0.5, 1))
                    tempRichLabel:setPosition(ccp(m_node_msgboard:getContentSize().width * 0.5, m_node_msgboard:getContentSize().height))
                    m_node_msgboard:addChild(tempRichLabel)

                    local ts = itemData.ts or 0
                    local time = os.date("%H:%M:%S", tonumber(ts)) 
                    local tempTimeLabel = game_util:createLabelTTF({text = time, fontSize = 10})
                    tempTimeLabel:setAnchorPoint(ccp(0.5, 1))
                    tempTimeLabel:setColor(ccc3(200,255,255))
                    tempTimeLabel:setPosition(ccp(m_node_timeboard:getContentSize().width * 0.5, m_node_timeboard:getContentSize().height))
                    m_node_timeboard:addChild(tempTimeLabel)
                else
                    local msg = string_helper.ui_pyramid_battleinfo_pop.tips
                    local tempLabel = game_util:createLabelTTF({text = msg, fontSize = 10})
                    tempLabel:setColor(ccc3(116, 177, 178))
                    tempLabel:setAnchorPoint(ccp(0.5, 0.5))
                    tempLabel:setPosition(ccp(m_node_msgboard:getContentSize().width * 0.5, m_node_msgboard:getContentSize().height * 0.5))
                    m_node_msgboard:addChild(tempLabel)
                    m_btn_reshow:setVisible(false)
                end
            end
        end
        cell:setTag(1001 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    -- local tableView = 
    return TableViewHelper:create(params);
end

--[[
    观看战报
]]
function ui_pyramid_battleinfo_pop.watchBattleInfo( self, battleKey )
    if not battleKey then return end
    local function responseMethod(tag,gameData)
        game_data:setBattleType( self.m_enterType );
        if gameData then
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            self:destroy();
        end
    end
    local tempkey = battleKey;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_battle_replay"), http_request_method.GET, {key = tempkey},"pyramid_battle_replay");
end


--[[--
    刷新ui
]]
function ui_pyramid_battleinfo_pop.refreshUi(self)
    self.m_node_battleinfo_board:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableViewTopPlayer(self.m_node_battleinfo_board:getContentSize());
    self.m_node_battleinfo_board:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_pyramid_battleinfo_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self.m_enterType = t_params.enterType
end

--[[--
    创建ui入口并初始化数据
]]
function ui_pyramid_battleinfo_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_pyramid_battleinfo_pop;