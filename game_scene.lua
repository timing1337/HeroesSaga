---游戏ui控制器
game_ui_table = 
{
    game_main_scene = {showTopBar = true,bgMusic = "background_home"},
    game_team_info = {showTopBar = true,bgMusic = ""},
    game_adjustment_formation = {showTopBar = false,bgMusic = ""},
    game_school_scene = {showTopBar = false,bgMusic = ""},
    skills_training_select_scene = {showTopBar = false,bgMusic = ""},
    skills_inheritance_scene = {showTopBar = false,bgMusic = "background_home"},
    game_refuge_scene = {showTopBar = true,bgMusic = ""},
    skills_practice_scene = {showTopBar = false,bgMusic = ""},
    skills_replacement_scene = {showTopBar = false,bgMusic = ""},
    game_hero_culture_scene = {showTopBar = false,bgMusic = "background_home"},
    removal_crystal_scene = {showTopBar = false,bgMusic = ""},
    equipment_production = {showTopBar = false,bgMusic = ""},
    equipment_strengthen = {showTopBar = false,bgMusic = ""},
    equipment_select = {showTopBar = false,bgMusic = ""},
    equip_normal_production = {showTopBar = true,bgMusic = ""},
    equip_material_production = {showTopBar = true,bgMusic = ""},
    building_statistics_scene = {showTopBar = true,bgMusic = ""},
    game_hero_list = {showTopBar = false,bgMusic = ""},
    game_hero_select = {showTopBar = false,bgMusic = ""},
    game_gacha_scene = {showTopBar = false,bgMusic = ""},
    game_recharge_scene = {showTopBar = true,bgMusic = ""},
    skills_reset_scene = {showTopBar = false,bgMusic = ""},
    game_login_scene = {showTopBar = false,bgMusic = "background_germany"},
    game_small_map_scene = {showTopBar = false,bgMusic = ""},
    map_building_detail_scene = {showTopBar = false,bgMusic = ""},
    game_battle_scene = {showTopBar = false,bgMusic = ""},
    game_battle_statistics = {showTopBar = false,bgMusic = ""},
    map_world_scene = {showTopBar = false,bgMusic = ""},
    game_hero_advanced_sure = {showTopBar = false,bgMusic = ""},
    skills_strengthen_scene = {showTopBar = false,bgMusic = "background_home"},
    game_neutral_map = {showTopBar = false,bgMusic = ""},
    game_neutral_city_map = {showTopBar = false,bgMusic = "background_home"},
    game_daily_scene = {showTopBar = true,bgMusic = ""},
    game_activity_scene = {showTopBar = true,bgMusic = ""},
    game_guild_ranking = {showTopBar = true,bgMusic = ""},
    game_guild_main = {showTopBar = true,bgMusic = ""},
    game_guild_post = {showTopBar = true,bgMusic = ""},
    game_guild_application = {showTopBar = true,bgMusic = ""},
    game_guild_audit = {showTopBar = true,bgMusic = ""},
    game_guild_conversion = {showTopBar = true,bgMusic = ""},
    game_guild_develop = {showTopBar = true,bgMusic = ""},
    battle_royale_reg_scene = {showTopBar = true,bgMusic = ""},
    battle_royale_scene = {showTopBar = true,bgMusic = ""},
    equipment_list = {showTopBar = false,bgMusic = ""},
    items_scene = {showTopBar = false,bgMusic = ""},
    ui_test_download = {showTopBar = false,bgMusic = ""},
    create_role_scene = {showTopBar = false,bgMusic = "background_germany"},
    game_shop_scene = {showTopBar = false,bgMusic = ""},
    game_pk = {showTopBar = false,bgMusic = "background_home"},
    game_first_opening = {showTopBar = false,bgMusic = ""},
    game_buy_item_scene = {showTopBar = false,bgMusic = ""},
    game_school_select_scene = {showTopBar = false,bgMusic = ""},
    active_map_scene = {showTopBar = false,bgMusic = ""},
    active_map_building_detail_scene = {showTopBar = false,bgMusic = "background_home"},
    game_exchange_scene = {showTopBar = false,bgMusic = ""},
    game_task_scene = {showTopBar = false,bgMusic = ""},
    game_card_split = {showTopBar = false,bgMusic = "background_home"},
    game_hero_inherit = {showTopBar = false,bgMusic = "background_home"},
    game_card_split_shop = {showTopBar = false,bgMusic = ""},
    game_activity = {showTopBar = false,bgMusic = "background_home"},
    game_world_boss = {showTopBar = true,bgMusic = "background_home"},
    game_daily_sign = {showTopBar = false,bgMusic = ""},
    game_activation = {showTopBar = false,bgMusic = ""},
    game_vip = {showTopBar = false,bgMusic = ""},
    equip_evolution = {showTopBar = false,bgMusic = ""},
    game_school_new = {showTopBar = false,bgMusic = ""},
    game_school_new_select = {showTopBar = false,bgMusic = ""},
    game_friend_scene = {showTopBar = false,bgMusic = ""},
    game_arena = {showTopBar = false,bgMusic = "background_home"},
    game_arena_shop = {showTopBar = false,bgMusic = ""},
    game_offer = {showTopBar = false,bgMusic = ""},
    game_notify_message_scene = {showTopBar = false,bgMusic = ""},
    game_daily_wanted = {showTopBar = false,bgMusic = ""},
    game_activity_live = {showTopBar = false,bgMusic = "background_home"},
    game_ability_commander = {showTopBar = false,bgMusic = "background_home"},
    game_ability_commander_snatch = {showTopBar = false,bgMusic = "background_home"},
    game_guild_boss = {showTopBar = true,bgMusic = "background_home"},
    game_pirate_map = {showTopBar = false,bgMusic = "background_home"},
    ui_levelap_rank = {showTopBar = false,bgMusic = ""},
    game_gvg_war_half = {showTopBar = false,bgMusic = "gvg_home_music"},
    game_dart_route = {showTopBar = false,bgMusic = "background_home"},
    game_pyramid_tower_scene = {showTopBar = false,bgMusic = "background_home"},
    open_door_cloister_detail = {showTopBar = false,bgMusic = "background_home"},
    open_door_main_scene = {showTopBar = true,bgMusic = "march-of-the-dead"},
    game_dart_main = {showTopBar = false,bgMusic = "dark-water"},
    open_door_cloister = {showTopBar = false,bgMusic = "dark-water"},
    game_pyramid_scene = {showTopBar = false,bgMusic = "dark-water"},
}

local game_scene = {
    m_gameScene = nil,
    m_gameContainer = nil,
    m_propertyBar = nil,
    m_popContainer = nil,
    m_broadcastNode = nil,
    m_popUiTab = {},
    m_currentUiTab = nil,
    m_broadcastScrollView = nil,
    m_touch_priority = nil,
};
--[[--
    初始化
]]
function game_scene.init(self)
    self.m_touch_priority = GLOBAL_TOUCH_PRIORITY or -130;
    self.m_gameScene = CCScene:create();
    self.m_gameContainer = CCLayer:create();
    self.m_gameScene:addChild(self.m_gameContainer,1);
    self.m_propertyBar = self:createPropertyBar();
    self.m_propertyBar:setVisible(false);
    self.m_gameScene:addChild(self.m_propertyBar,2);
    self.m_popContainer = CCLayer:create();
    self.m_gameScene:addChild(self.m_popContainer,3);
    self.m_broadcastNode = self:createBroadcastNode();
    self.m_broadcastNode:setVisible(false);
    self.m_gameScene:addChild(self.m_broadcastNode,2);
    display.replaceScene(self.m_gameScene);
end
--[[--
    进入ui
]]
function game_scene.enterGameUi(self,gameUiName,t_params,t_params2)
    gameUiName = tostring(gameUiName);
    t_params2 = t_params2 or {}
    local currentUi = require("game_ui." .. gameUiName);
    if currentUi == nil then
        cclog("gameUiName = " .. gameUiName .. " not found ");
        return;
    end
    CCTextureCache:sharedTextureCache():removeUnusedTextures();
    
    if gameUiName == "game_main_scene" then
        self:enterGameMainScene(t_params,t_params2);
        return;
    end
    if self.m_currentUiTab and self.m_currentUiTab.ui then
        local currentUi = self.m_currentUiTab.ui
        local ccbNode = currentUi.m_ccbNode
        if ccbNode and t_params2.outer_anim ~= nil then
            local function animEndCallFunc(animName)
                self:enterUi(gameUiName,t_params,t_params2);
            end
            ccbNode:registerAnimFunc(animEndCallFunc)
            ccbNode:runAnimations("outer_anim")
        else
            self:enterUi(gameUiName,t_params,t_params2);
        end
    else
        self:enterUi(gameUiName,t_params,t_params2);
    end
end
--[[--
    进入ui
]]
function game_scene.enterUi(self,gameUiName,t_params,t_params2)
    gameUiName = tostring(gameUiName);
    local currentUi = require("game_ui." .. gameUiName);
    if currentUi == nil then
        cclog(gameUiName .. " load failed !")
        return
    end
    if currentUi.create == nil then
        cclog(gameUiName .. " create method not found !")
        return
    end
    self:removeAllPop();
    -- cclog("self.m_gameContainer ==============self.m_gameContainer=" .. tostring(tolua.type(self.m_gameContainer)) .. "; self=" .. type(self));
    local oldUiTab = self.m_currentUiTab or {};
    local oldUiName = tostring(oldUiTab.uiName)
    cclog("enter gameUiName = " .. tostring(gameUiName) .. " ; oldUiName = " .. oldUiName);
    self:removeCurrentUi();
    local tempNode = currentUi:create(t_params);
    local function sceneEventHandler( eventType )
        -- body
        cclog("-----------------sceneEventHandler-----------" .. eventType);
        if(eventType == "cleanup")then
            cclog("-----------------------------remove memory-----------------------------");
            -- cclog("TotalMemory = " .. (util_system:getTotalMemory()/1024/1024) .. " MB; AvailableMemory = " .. (util_system:getAvailableMemory()/1024/1024) .. " MB ; UsedMemory = " .. util_system:getUsedMemory()/1024/1024 .. "  MB");
            if zcAnimNode.removeAllUnusing then
                CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
                zcAnimNode:removeAllUnusing();
            end
            CCTextureCache:sharedTextureCache():removeUnusedTextures();
        elseif(eventType == "enter")then

        end
    end
    tempNode:registerScriptHandler(sceneEventHandler);
    self.m_gameContainer:addChild(tempNode);
    self.m_currentUiTab = {ui = currentUi,uiNode = tempNode,uiName = gameUiName}
    local tempUi = game_ui_table[gameUiName] or {showTopBar = false,bgMusic = ""}
    local showBarFlag = (tempUi.showTopBar ~= nil and tempUi.showTopBar or false);
    if not self.m_propertyBar:isVisible() and showBarFlag then
        self.m_propertyBar:runAnimations("enter_anim")
    end
    self.m_propertyBar:setVisible(showBarFlag);
    local bgMusic = tempUi.bgMusic
    if t_params and t_params.bgMusic then
        bgMusic = t_params.bgMusic
    end
    game_sound:playMusic(bgMusic,true);
    if gameUiName == "game_main_scene" then
        self:setVisibleBroadcastNode(true);
    else
        self:setVisibleBroadcastNode(false);
    end
    t_params2 = t_params2 or {};
    local endCallFunc = t_params2.endCallFunc
    if endCallFunc and type(endCallFunc) == "function" then
        endCallFunc();
    end
    if oldUiName == "game_main_scene" then
        if gameUiName == "equipment_list" then
            game_data:resetNewCardIdTab();
        elseif gameUiName == "game_hero_list" then
            game_data:resetNewEquipIdTab();
        else
            game_data:resetNewEquipIdTab();
            game_data:resetNewCardIdTab();
        end
    end
    cclog("----------------- enterUi end ----------------------")
end

--[[--
    移除当前ui
]]
function game_scene.removeCurrentUi(self)
    self.m_gameContainer:removeAllChildrenWithCleanup(true);
    local oldUiTab = self.m_currentUiTab or {};
    local oldUiTable = oldUiTab.ui
    if oldUiTable and oldUiTable.destroy then
        oldUiTable:destroy();
    end
    self.m_currentUiTab = nil;
end

--[[--
    填充属性数据
]]
function game_scene.fillPropertyBarData(self)
    game_util:setPlayerPropertyByCCBAndTableData(self.m_propertyBar,game_data:getUserStatusData());
end
--[[--
    创建属性栏
]]
function game_scene.createPropertyBar(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--买体力
            local buyTimes = game_data:getBuyActionTimes()
            local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("2"):getNodeWithKey("coin")
            local vipLevel = game_data:getVipLevel()
            local buyLimit = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel)):getNodeWithKey("buy_point"):toInt()
            
            if buyTimes < buyLimit then
                if game_data:getActionPointValue() >= 120 then
                    game_util:addMoveTips({text = string_helper.game_scene.fullEnergy})
                else
                    local payValue = 0
                    if buyTimes >= PayCfg:getNodeCount() then
                        payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
                    else
                        payValue = PayCfg:getNodeAt(buyTimes):toInt()
                    end
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        local buy_ap_times = data:getNodeWithKey("buy_ap_times"):toInt()
                        game_util:addMoveTips({text = string_helper.game_scene.buyEnd})
                        game_data:setBuyActionTimes(buy_ap_times)
                        game_util:closeAlertView();
                    end
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_point"), http_request_method.GET, nil,"buy_point")
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string.format(string_helper.game_scene.buyPoint1,payValue),      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                end
            else
                game_util:addMoveTips({text = string_helper.game_scene.buyOver})                
            end
        elseif btnTag == 2 then--买vip
            -- game_util:addMoveTips({text = "暂不支持！"});
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_complete_property_bar.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_head_icon_node = ccbNode:nodeForName("m_head_icon_node");
    local m_head_icon_node = ccbNode:nodeForName("m_head_icon_node");

    local function onTouch(eventType, x, y)
        if eventType == "began" and self.m_propertyBar:isVisible() then
            local realPos = m_head_icon_node:getParent():convertToNodeSpace(ccp(x,y));
            if m_head_icon_node:boundingBox():containsPoint(realPos) then
                -- cclog("head icon on click ===============");
                self:addPop("player_profile_pop",{gameData = nil})
                return true;--intercept event
            end
            return false;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,0,true);
    m_root_layer:setTouchEnabled(true);

    return ccbNode;
end
--[[--
    创建公告栏
]]
function game_scene.createBroadcastNode(self)
    local winSize = CCDirector:sharedDirector():getWinSize();
    local viewSize = CCSizeMake(winSize.width,winSize.height*0.05)
    local tempNode = CCNode:create();
    tempNode:setContentSize(viewSize);
    tempNode:ignoreAnchorPointForPosition(true);
    -- tempNode:setAnchorPoint(ccp(0.5,0.5));
    local tempLayer = CCLayerColor:create(ccc4(0,0,0, 100), viewSize.width, viewSize.height);
    -- tempNode:setPositionY(winSize.height-viewSize.height)
    -- tempNode:setPositionY(winSize.height)
    tempNode:setPositionY(winSize.height*0.66)
    local scrollView = CCScrollView:create(viewSize);
    tempNode:addChild(tempLayer,1,1);
    tempNode:addChild(scrollView,2,2);
    -- tempNode:setPosition(ccp(winSize.width*0.5,winSize.height*0.7));
    tempNode:setVisible(false);
    self.m_broadcastScrollView = scrollView;
    return tempNode;
end
--[[--
    获得游戏的场景
]]
function game_scene.getGameScene(self)
    return self.m_gameScene;
end
--[[--
    获得游戏容器
]]
function game_scene.getGameContainer(self)
    return self.m_gameContainer;
end
--[[--
    获得当前ui的名字  
]]
function game_scene.getCurrentUiName(self)
    if self.m_currentUiTab then
        return self.m_currentUiTab.uiName or "";
    end
    return "";
end
--[[--
    获得弹出框容器
]]
function game_scene.getPopContainer(self)
    return self.m_popContainer;
end
--[[--
    添加弹出框
]]
function game_scene.addNodeToPopContainer(self,node)
    self.m_popContainer:addChild(node)
end
--[[--
    移除所有的弹出框  
]]
function game_scene.removeAllPop(self)
    for k,v in pairs(self.m_popUiTab) do
        self:removePopByName(k);
    end
    self.m_popContainer:removeAllChildrenWithCleanup(true);
    self.m_popUiTab = {};
    self.m_touch_priority = GLOBAL_TOUCH_PRIORITY or -130;
end
--[[--
    通过名称移除弹出框
]]
function game_scene.removePopByName(self,popUiName)
    -- local tempPop = self.m_popUiTab[tostring(popUiName)];
    -- if tempPop and tempPop.popUiNode then
    --     tempPop.popUiNode:removeFromParentAndCleanup(true);
    --     self.m_popUiTab[tostring(popUiName)] = nil;
    -- end
    popUiName = tostring(popUiName);
    local tempPop = self.m_popUiTab[popUiName];
    if tempPop and tempPop.popUiNode then
        cclog("removePopByName ========================= " .. popUiName)
        tempPop.popUiNode:removeFromParentAndCleanup(true);
        local tempUi = tempPop.popUi;
        if tempUi and tempUi.destroy then
            tempUi:destroy();
        end
        self.m_popUiTab[popUiName] = nil;
    end
    if zcAnimNode.removeAllUnusing then
        -- CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames();
        zcAnimNode:removeAllUnusing();
    end
    -- CCTextureCache:sharedTextureCache():removeUnusedTextures();
end

--[[--
    通过名字设置弹出框的隐藏状态
]]
function game_scene.setPopVisibleByName(self,popUiName,visible)
    local tempPop = self.m_popUiTab[tostring(popUiName)];
    if tempPop and tempPop.popUiNode then
        if visible == nil then
            visible = true;
        end
        tempPop.popUiNode:setVisible(visible);
    end
end

--[[--
    通过名字获得弹出框
]]
function game_scene.getPopByName(self,popUiName)
    local tempPop = self.m_popUiTab[tostring(popUiName)];
    return tempPop;
end

--[[--
    获得当前的ui
]]
function game_scene.getCurrentUi(self)
    return self.m_currentUiTab;
end
--[[--
    设置状态栏的显示状态
]]
function game_scene.setVisiblePropertyBar(self,visible)
    self.m_propertyBar:setVisible(visible);
end
--[[--
    执行状态拦的动作
]]
function game_scene.runPropertyBarAnim(self,animName)
    self.m_propertyBar:runAnimations(animName)
end
--[[--
    设置公告栏显示状态
]]
function game_scene.setVisibleBroadcastNode(self,visible)
    self.m_broadcastNode:setVisible(visible);
    if visible == true then
        self:setBroadcastStrTab();
    else
        if self.m_broadcastScrollView then
            self.m_broadcastScrollView:getContainer():removeAllChildrenWithCleanup(true);
        end
    end
end
--[[--
    设置公告栏信息
]]
function game_scene.setBroadcastStrTab(self,strTab)
    if self.m_broadcastNode then
        -- strTab = strTab or {};
        strTab = game_data:getNoticesData()
        local scrollView = tolua.cast(self.m_broadcastNode:getChildByTag(2),"CCScrollView")
        game_util:createScrollViewTips(scrollView,strTab,false,2)
    end
end
--[[--
    刷新当前ui
]]
function game_scene.refreshCurrentUi(self)
    if self.m_currentUiTab and self.m_currentUiTab.ui then
        local currentUi = self.m_currentUiTab.ui
        if currentUi.refreshUi then
            currentUi:refreshUi();
        end
    end
end
--[[--
    添加弹出框
]]
function game_scene.addPop(self,popUiName,t_params,t_params2)
    local currentPopUi = require("game_pop." .. popUiName);
    if currentPopUi == nil then
        cclog("game_scene addPop " .. popUiName .. " not found ");
        return;
    end
    self:removePopByName(popUiName);
    self.m_touch_priority = self.m_touch_priority - 5;
    local tempNode = currentPopUi:create(t_params);
    if tempNode then
        if popUiName == "drama_dialog_pop" then
            self.m_popContainer:addChild(tempNode,9999,9999)
            self.m_popUiTab[popUiName] = {popUi = currentPopUi,popUiNode = tempNode}
        else
            t_params2 = t_params2 or {};
            local order = t_params2.order or -1;
            self.m_popContainer:addChild(tempNode,order)
            self.m_popUiTab[popUiName] = {popUi = currentPopUi,popUiNode = tempNode}
        end
    else
        cclog("popUiName = " .. popUiName .. " create faild ! ");
    end
end

--[[-- 
    将UI 以 pop的方式弹出
]]
function game_scene.addUILikePop(self,popUiName,t_params,t_params2)
    local currentPopUi = require("game_ui." .. popUiName);
    if currentPopUi == nil then
        cclog("game_scene addPop " .. popUiName .. " not found ");
        return;
    end
    self:removePopByName(popUiName);
    self.m_touch_priority = self.m_touch_priority - 5;
    local tempNode = currentPopUi:create(t_params);
    if tempNode then
        if popUiName == "drama_dialog_pop" then
            self.m_popContainer:addChild(tempNode,9999,9999)
            self.m_popUiTab[popUiName] = {popUi = currentPopUi,popUiNode = tempNode}
        else
            t_params2 = t_params2 or {};
            local order = t_params2.order or -1;
            self.m_popContainer:addChild(tempNode,order)
            self.m_popUiTab[popUiName] = {popUi = currentPopUi,popUiNode = tempNode}
        end
    else
        cclog("popUiName = " .. popUiName .. " create faild ! ");
    end
end



function game_scene.addGuidePop(self,t_params)
    self:removeGuidePop();
    local currentPopUi = require("game_pop.guide_dialog_pop");
    if currentPopUi == nil then
        cclog("game_scene addGuidePop guide_dialog_pop not found ");
        return;
    end
    local tempNode = currentPopUi:create(t_params);
    self.m_popContainer:addChild(tempNode,10000,10000)
end

function game_scene.removeGuidePop(self)
    local tempNode = self.m_popContainer:getChildByTag(10000)
    if tempNode then
        tempNode:removeFromParentAndCleanup(true);
    end
end

function game_scene.enterGameMainScene(self,t_params,t_params2)
    t_params = t_params or {};
    local firstFlag = t_params.firstFlag
    firstFlag = firstFlag ~= nil and firstFlag or false;
    if firstFlag == false then
        local function responseMethod(tag,gameData,contentLength,status,new_config_version)
            local data = gameData:getNodeWithKey("data");
            -- cclog("game_main_scene data == " .. data:getFormatBuffer());
            game_data:updateMainPageByJsonData(data);
            game_scene:enterUi("game_main_scene",t_params,t_params2);
            local old_config_version = CCUserDefault:sharedUserDefault():getStringForKey("all_config_version") or ""
            new_config_version = new_config_version or ""
            local config_refresh = data:getNodeWithKey("config_refresh")--是否更新  1 是 0 否
            if config_refresh then
                config_refresh = config_refresh:toInt();
            else
                config_refresh = 1;
            end
            if config_refresh == 1 and old_config_version ~= new_config_version then
                cclog("new_config_version === " .. new_config_version .. " ; old_config_version = " .. old_config_version)
                local config_refresh_text = data:getNodeWithKey("config_refresh_text")
                if config_refresh_text then
                    config_refresh_text = config_refresh_text:toStr();
                else
                    config_refresh_text = string_helper.game_scene.versionTips;
                end
                game_util:closeAlertView();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        game_scene:setVisibleBroadcastNode(false);
                        game:resourcesDownload();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_helper.game_scene.reLogin,       --可缺省
                    text = tostring(config_refresh_text),      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_main_page"), http_request_method.GET, nil,"user_main_page")
    else
        local function responseMethod(tag,gameData)
            if gameData == nil then
                t_params2 = t_params2 or {};
                local endCallFunc = t_params2.endCallFunc
                if endCallFunc and type(endCallFunc) == "function" then
                    endCallFunc("1");
                end
                return;
            end
            local data = gameData:getNodeWithKey("data");
            -- cclog("game_main_scene data == " .. data:getFormatBuffer());
            game_data:updateMainPageByJsonData(data);
            game_scene:enterUi("game_main_scene",t_params,t_params2);     
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_main_page"), http_request_method.GET, nil,"user_main_page",true,true)
    end
end

function game_scene.getTouchPriority(self)
    return self.m_touch_priority;
end

return game_scene;