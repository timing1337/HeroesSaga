--- 战报

local ui_batter_info_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_battlefield_table_node = nil,
    m_topplayer_name = nil,
    log_info = nil,
    m_openType = nil,
    m_isShowShareBtn = false,
    m_callBackFunc = nil,
};
--[[--
    销毁ui
]]
function ui_batter_info_pop.destroy(self)
    -- body
    cclog("-----------------ui_batter_info_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_battlefield_table_node = nil;
    self.log_info = nil;
    self.m_openType = nil;
    self.m_topplayer_name = nil;
    self.m_isShowShareBtn = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function ui_batter_info_pop.back(self,backType)
    game_scene:removePopByName("ui_batter_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_batter_info_pop.createUi(self)
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
    创建列表
]]
function ui_batter_info_pop.createTableView(self,viewSize)
    local myUid = game_data:getUserStatusDataByKey("uid")
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        local function onRelook( target,event )
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_pk");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = self.m_gameData.log[self.m_pk_detail_curtIndex+1].battle_log;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
        end
        local function onWeibo( target,event )

        end

        if btnTag > 1000 and btnTag < 1100 then
            local index = btnTag - 1000
            local function responseMethod(tag,gameData)
                if  self.m_isShowShareBtn == "true"  then
                    game_data:setBattleType("game_main_scene_chat_pop");
                else
                    game_data:setBattleType("game_pk");
                end
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = self.log_info[index].battle_log;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
        elseif btnTag >= 1100 and btnTag <= 1200 then
            local index = btnTag - 1100
            local tempkey = self.log_info[index].battle_log;
            -- cclog2("will share tempkey  ===== " .. (tempkey or "") )
            local chatOber = game_data:getChatObserver()
            local tempData = {}
            local item = self.log_info[index]
            local attacker = item.attacker or ""
            local defender = item.defender or ""
            local info = " " .. attacker .. " VS " .. defender .. " "
            tempData[info] =  {typeName = "show", data = tempkey }
            local chatData = {kqgFlag = "world", inputStr = info,data = tempData}
            local flag =  chatOber:sendOneChat(chatData)
            if flag then game_util:addMoveTips({text = string_helper.ui_batter_info_pop.share}); end
        end
    end
    local fightCount = #self.log_info;
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
            if self.m_isShowShareBtn == "true" then
                ccbNode:openCCBFile("ccb/ui_area_battlefield_item2.ccbi");
            else
                ccbNode:openCCBFile("ccb/ui_arena_battlefield_pop_item.ccbi");
            end
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));

            local btn_relook = ccbNode:controlButtonForName("btn_relook")

            btn_relook:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)

            game_util:setCCControlButtonTitle(btn_relook,string_helper.ccb.text28)
            if self.m_isShowShareBtn == "true" then
                local btn_shareinfo = ccbNode:controlButtonForName("btn_shareinfo") or nil
                if btn_shareinfo then
                    btn_shareinfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
                end
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

            local item = self.log_info[index + 1]
            -- local icon = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- local icon_alpha = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- if icon then
            --     m_icon_node:removeAllChildrenWithCleanup(true);
            --     icon_alpha:setAnchorPoint(ccp(0.5,0.5))
            --     icon_alpha:setPosition(ccp(7,4))
            --     icon_alpha:setOpacity(100)
            --     icon_alpha:setColor(ccc3(0,0,0))
            --     m_icon_node:addChild(icon_alpha)
            --     icon:setAnchorPoint(ccp(0.5,0.5))
            --     icon:setPosition(ccp(5,5))
            --     m_icon_node:addChild(icon);
            -- else
            --     cclog("tempFrontUser.role " .. item.role .. " not found !")
            -- end
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
                    name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttackWin,name))
                else
                    name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttacklose,name))
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                end
            else--自己是被攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_def.png");
                m_icon_node:addChild(tempSpr,10,10)
                if item.is_win == true then
                    name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttacked,name))
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                else
                    name_label:setString(name .. string_helper.ui_batter_info_pop.bitWin)
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                end
            end
            -- name_label:setString(name)
            fight_point_label:setString(tostring(power))

            btn_relook:setTag(1001 + index)
            if btn_shareinfo then 
                btn_shareinfo:setTag(1101 + index)
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


--[[--
    创建列表
]]
function ui_batter_info_pop.createTableView2(self,viewSize)
    local itemCfg = getConfig(game_config_field.item);
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        local function onRelook( target,event )
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_ability_commander_snatch");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = self.m_gameData.log[self.m_pk_detail_curtIndex+1].battle_log;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
        end
        local function onWeibo( target,event )

        end
        if btnTag > 1000 and btnTag < 1100 then
            local index = btnTag - 1000
            local function responseMethod(tag,gameData)
                game_data:setCommanderRecipeData("itemId",nil);
                game_data:setBattleType("game_ability_commander_snatch");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = self.log_info[index].battle_log;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
        end
    end
    local fightCount = #self.log_info;
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
            ccbNode:openCCBFile("ccb/ui_ability_commander_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));

            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            local btn_share = ccbNode:controlButtonForName("btn_share")

            btn_relook:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)
            btn_share:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)

            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local win_icon = ccbNode:spriteForName("win_icon")
            local name_label = ccbNode:labelTTFForName("name_label")
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            local btn_share = ccbNode:controlButtonForName("btn_share")

            game_util:setCCControlButtonTitle(btn_relook,string_helper.ccb.text28)
            game_util:setCCControlButtonTitle(btn_share,string_helper.ccb.text29)
            local item = self.log_info[index + 1]
            -- cclog("item == " .. json.encode(item))
            -- local icon = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- local icon_alpha = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- if icon then
            --     m_icon_node:removeAllChildrenWithCleanup(true);
            --     icon_alpha:setAnchorPoint(ccp(0.5,0.5))
            --     icon_alpha:setPosition(ccp(7,4))
            --     icon_alpha:setOpacity(100)
            --     icon_alpha:setColor(ccc3(0,0,0))
            --     m_icon_node:addChild(icon_alpha)
            --     icon:setAnchorPoint(ccp(0.5,0.5))
            --     icon:setPosition(ccp(5,5))
            --     m_icon_node:addChild(icon);
            -- else
            --     cclog("tempFrontUser.role " .. item.role .. " not found !")
            -- end
            -- if item.is_win == true then
            --     win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
            -- else
            --     win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
            -- end
            m_icon_node:removeAllChildrenWithCleanup(true);
            local a_uid = item.a_uid or ""
            local itemItemCfg = itemCfg:getNodeWithKey(tostring(item.item));
            local itemName = nil;
            if itemItemCfg then
                itemName = itemItemCfg:getNodeWithKey("name"):toStr();
            end
            if game_data:getUserStatusDataByKey("uid") == a_uid then--我是攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_att.png");
                m_icon_node:addChild(tempSpr,10,10)
                win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                if item.is_win == true then
                    if itemName == nil then
                        name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttackWin,tostring(item.defender)))
                    else
                        name_label:setString(string.format(string_helper.ui_batter_info_pop.winGet,tostring(item.defender)) .. itemName)
                    end
                else
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                    name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttacklose,tostring(item.defender)))
                end
            else--我是防守方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_def.png");
                m_icon_node:addChild(tempSpr,10,10)
                if item.is_win == true then
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                    if itemName == nil then
                        name_label:setString(string.format(string_helper.ui_batter_info_pop.youAttacked,tostring(item.attacker)));
                    else
                        name_label:setString(tostring(item.attacker) .. string.format(string_helper.ui_batter_info_pop.robYou,itemName))
                    end
                else
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                    name_label:setString(tostring(item.attacker) .. string_helper.ui_batter_info_pop.bitWin);
                end
            end

            btn_relook:setTag(1001 + index)
            btn_share:setTag(1101 + index)
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
    无主之地战报
]]
function ui_batter_info_pop.createTableView3(self,viewSize)
    local myUid = game_data:getUserStatusDataByKey("uid")
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 1000 and btnTag < 1100 then
            local index = btnTag - 1000
            local function responseMethod(tag,gameData)
                game_data:setBattleType("game_neutral_city_map");
                game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
                self:destroy();
            end
            local tempkey = self.log_info[index].battle_log;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
        end
    end
    local fightCount = #self.log_info;
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
            ccbNode:openCCBFile("ccb/ui_neutral_battle_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            game_util:setCCControlButtonTitle(btn_relook,string_helper.ccb.title146);
            btn_relook:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)            
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local win_icon = ccbNode:spriteForName("win_icon")
            local story_label = ccbNode:labelTTFForName("story_label")
            local btn_relook = ccbNode:controlButtonForName("btn_relook")
            game_util:setCCControlButtonTitle(btn_relook,string_helper.ccb.title146);
            local item = self.log_info[index + 1]
            -- local icon = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- local icon_alpha = game_util:createPlayerIconByRoleId(tostring(item.role));
            -- if icon then
            --     m_icon_node:removeAllChildrenWithCleanup(true);
            --     icon_alpha:setAnchorPoint(ccp(0.5,0.5))
            --     icon_alpha:setPosition(ccp(7,4))
            --     icon_alpha:setOpacity(100)
            --     icon_alpha:setColor(ccc3(0,0,0))
            --     m_icon_node:addChild(icon_alpha)
            --     icon:setAnchorPoint(ccp(0.5,0.5))
            --     icon:setPosition(ccp(5,5))
            --     m_icon_node:addChild(icon);
            -- else
            --     cclog("tempFrontUser.role " .. item.role .. " not found !")
            -- end
            local reward = item.reward[1]
            cclog("reward = " .. json.encode(reward))
            local icon,name,count = game_util:getRewardByItemTable(reward)
            local attacker = item.a_uid
            local defender = item.d_uid

            local att_name = item.attacker
            local def_name = item.defender
            m_icon_node:removeAllChildrenWithCleanup(true);
            if myUid == attacker then--自己是攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_att.png");
                m_icon_node:addChild(tempSpr,10,10)
                win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                if item.is_win == true then--自己攻击赢了
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                    story_label:setString("你击败了 " .. def_name .. "，夺得 " .. count .. " 食物")
                else
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                    story_label:setString("你试图夺取 " .. def_name .. "的食物，被打的落荒而逃")
                end
            else--自己是被攻击方
                local tempSpr = CCSprite:createWithSpriteFrameName("arena_def.png");
                m_icon_node:addChild(tempSpr,10,10)
                win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                if item.is_win == true then
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_lose.png"))
                    story_label:setString("你被 " .. att_name .. "抢走了" .. count .."食物")
                else
                    win_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("arena_win.png"))
                    story_label:setString(att_name .. "试图抢夺你的食物，被你打的鼻青脸肿")
                end
            end
            btn_relook:setTag(1001 + index)
        end
        cell:setTag(1001 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end

--[[
    新无主之地战报
]]
function ui_batter_info_pop.createTableView4(self,viewSize)
    local myUid = game_data:getUserStatusDataByKey("uid")
    --复仇
    local function onMainClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.log_info[btnTag + 1] or {}
        local index = btnTag - 1000
        local function responseMethod(tag,gameData)
            game_data:setBattleType("public_land_go_revenge");
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        end
        -- uid&index
        local params = {}
        params.uid = itemData.uid
        params.index = itemData.index
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_land_go_revenge"), http_request_method.GET, params,"public_land_go_revenge");
    end
    --拜访
    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.log_info[btnTag + 1] or {}
        self.m_callBackFunc("visit",{uid = itemData.uid,index = itemData.index})
        self:back()
    end
    local fightCount = #self.log_info;
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
            ccbNode:registerFunctionWithFuncName("onMainClick",onMainClick);
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_neutral_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            local m_visit_btn = ccbNode:controlButtonForName("m_visit_btn")
            m_visit_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)  
            local m_revenge_btn = ccbNode:controlButtonForName("m_revenge_btn")
            m_revenge_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12)  
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_visit_btn = ccbNode:controlButtonForName("m_visit_btn")
            local m_revenge_btn = ccbNode:controlButtonForName("m_revenge_btn")
            local m_detail_node = ccbNode:nodeForName("m_detail_node")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            m_icon_node:removeAllChildrenWithCleanup(true)
            m_detail_node:removeAllChildrenWithCleanup(true)
            local itemData = self.log_info[index+1] or {}
            local tempNode = game_util:createPlayerIconByRoleId(itemData.role or 0)
            if tempNode then
                tempNode:setScale(0.7)
                m_icon_node:addChild(tempNode)
            end
            local dimensions = m_detail_node:getContentSize()
            local detail_label = game_util:createRichLabelTTF({text = tostring(itemData.msg),dimensions = dimensions,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255,255,255)})
            detail_label:setAnchorPoint(ccp(0, 0))
            m_detail_node:addChild(detail_label)

            local has_battle = itemData.has_battle
            local is_win = itemData.is_win
            local typeValue = itemData.type --1偷取 2掠夺 3 祝福
            if typeValue == 1 then
                if has_battle == true and is_win == false then
                    m_visit_btn:setVisible(false)
                    m_revenge_btn:setVisible(true)
                else
                    m_visit_btn:setVisible(false)
                    m_revenge_btn:setVisible(false)
                end
            elseif typeValue == 2 then
                m_visit_btn:setVisible(false)
                m_revenge_btn:setVisible(true)
            elseif typeValue == 3 then
                m_visit_btn:setVisible(true)
                m_revenge_btn:setVisible(false)
            end
            m_visit_btn:setTag(index)
            m_revenge_btn:setTag(index)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    最强玩家战报
]]
function ui_batter_info_pop.createTableViewTopPlayer(self,viewSize)

    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
    end

    local fightCount = #self.log_info;
    cclog2(fightCount, "fightCount  ===  ")
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
            ccbNode:registerFunctionWithFuncName("onMainClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_topplayer_battleinfo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));          
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_label_message = ccbNode:labelTTFForName("m_label_message")
            -- [{"atk_win":true,"id":"1404831270_0","atk_name":"转基因转","atk_uid":"h18985711","ts":1404831270}]
            local info = self.log_info[index + 1]

            local timeinfo = os.date("%Y-%m-%d %H:%M:%S", info.ts)
            local winer = self.m_topplayer_name or ""
            local loser = info.atk_name or ""
            if info.atk_win then 
                loser = self.m_topplayer_name or ""
                winer = info.atk_name or ""
            end
            local msg = string_config:getTextByKey("topplayer_info" .. (math.random(1, 5) or 1))
            msg = string.gsub(msg, "WINER", winer)
            msg = string.gsub(msg, "LOSER", loser )
            m_label_message:setString(msg or "")

            local m_label_name1 = ccbNode:labelTTFForName("m_label_name1")
            m_label_name1:setString( info.atk_name or "" )

            for i=1,4 do
                local m_label_time = ccbNode:labelTTFForName("m_label_time" .. i)
                m_label_time:setString( timeinfo or "")
            end
        end
        cell:setTag(1001 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end



--[[--
    刷新ui
]]
function ui_batter_info_pop.refreshUi(self)
    if self.m_openType == 1 then--竞技场
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView(self.m_battlefield_table_node:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_battlefield_table_node:addChild(tableViewTemp);
    elseif self.m_openType == 2 then--统帅能力
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView2(self.m_battlefield_table_node:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_battlefield_table_node:addChild(tableViewTemp);
    elseif self.m_openType == 3 then--无主之地
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView3(self.m_battlefield_table_node:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_battlefield_table_node:addChild(tableViewTemp);
    elseif self.m_openType == 4 then--新无主之地
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView4(self.m_battlefield_table_node:getContentSize());
        tableViewTemp:setScrollBarVisible(false)
        self.m_battlefield_table_node:addChild(tableViewTemp);
    elseif self.m_openType == "game_topplayer_scene" then
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableViewTopPlayer(self.m_battlefield_table_node:getContentSize());
        self.m_battlefield_table_node:addChild(tableViewTemp);
    end
end
--[[--
    初始化
]]
function ui_batter_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_topplayer_name = t_params.top_name
    self.log_info = t_params.log_info or {};
    -- cclog("t_params == " .. json.encode(t_params))
    self.m_openType = t_params.openType or 1;
    self.m_isShowShareBtn = t_params.isShowShareBtn or false
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function ui_batter_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_batter_info_pop;