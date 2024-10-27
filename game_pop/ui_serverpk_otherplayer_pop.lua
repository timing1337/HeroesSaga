--- 擂台战战报

local ui_serverpk_otherplayer_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_battlefield_table_node = nil,
};
--[[--
    销毁ui
]]
function ui_serverpk_otherplayer_pop.destroy(self)
    -- body
    cclog("-----------------ui_serverpk_otherplayer_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_battlefield_table_node = nil;
end
--[[--
    返回
]]
function ui_serverpk_otherplayer_pop.back(self,backType)
    game_scene:removePopByName("ui_serverpk_otherplayer_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_serverpk_otherplayer_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverpk_lookother.ccbi");

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
    创建列表
]]
function ui_serverpk_otherplayer_pop.createTableView(self,viewSize)
    local showData = self.m_allPlayerData
    local function onHeadBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag + 1] or {}
        if itemData then
            game_util:lookPlayerInfo(itemData.uid, true, 2);
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
            ccbNode:openCCBFile("ccb/ui_serverpk_otherplayer_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local m_player_icon = ccbNode:spriteForName("m_icon_node");
            local m_level_label = ccbNode:labelTTFForName("m_level_label")
            local m_player_label = ccbNode:labelTTFForName("m_player_label")
            local m_online_icon = ccbNode:spriteForName("m_online_icon");
            local m_server_label = ccbNode:labelTTFForName("m_label_sername")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local m_sprite_pksign = ccbNode:spriteForName("m_sprite_pksign")

            local itemData = showData[index + 1] or {}
            -- 在线标记
            if itemData.online then
                m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_on.png"))
            else
                -- m_online_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_off.png"))
                m_online_icon:setVisible(false)
            end

            --头像
            local role = itemData.role
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                m_player_icon:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                m_player_icon:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(m_player_icon:getContentSize().width * 0.5, m_player_icon:getContentSize().height * 0.6)
                m_player_icon:addChild(icon);

                self:createTouchButton({fun = onHeadBtnCilck, parent = m_player_icon, tag = index})
            else
                -- cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            -- 玩家等级
            if m_level_label then m_level_label:setString(tostring(itemData.level or "?")) end
            if m_combat_label then m_combat_label:setString(tostring(itemData.combat or "999999")) end
            if m_server_label then m_server_label:setString(tostring(itemData.server_name or "????")) end
            if m_player_label then m_player_label:setString(tostring(itemData.name or "????")) end
            local pngNames = {"ui_serverpk_biao_1.png", "ui_serverpk_biao_2.png"}
            local signId = 2
            if itemData.is_battle == 1 then signId = 1 end
            if m_sprite_pksign then
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(pngNames[signId])
                if frame then
                    m_sprite_pksign:setDisplayFrame(frame)
                end
            end


        end
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
    创建一个接受触摸事件的button
]]
function ui_serverpk_otherplayer_pop.createTouchButton( self, params )
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



--[[--
    刷新ui
]]
function ui_serverpk_otherplayer_pop.refreshUi(self)
    self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_battlefield_table_node:getContentSize());
    tableViewTemp:setScrollBarVisible(false)
    self.m_battlefield_table_node:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_serverpk_otherplayer_pop.init(self,t_params)
    t_params = t_params or {};
    -- cclog2(t_params, "t_params == ")
    local gameData = t_params.gameData
    self.m_allPlayerData = {}
    if gameData and gameData:getNodeWithKey("data") then
        local data = gameData:getNodeWithKey("data")
        local enemy_data = data and data:getNodeWithKey("enemy_list")
        local playerCount = enemy_data:getNodeCount()
        cclog2(playerCount, "playerCount   ===    ")
        for i=1, playerCount do
            local one = enemy_data:getNodeAt( i - 1 )
            if one then
                local oneTab = json.decode(one:getFormatBuffer())
                table.insert(self.m_allPlayerData, oneTab)
            end
        end
    end
    -- cclog2(self.m_allPlayerData, "self.m_allPlayerData == ")
end

--[[--
    创建ui入口并初始化数据
]]
function ui_serverpk_otherplayer_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_serverpk_otherplayer_pop;