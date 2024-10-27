--- 敌人
local game_pirate_enemy_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,

    name_label = nil,
    area_label = nil,
    level_label = nil,
    arena_label = nil,
    guild_label = nil,
    m_anim_node = nil,

    m_callFunc = nil,
    m_selBuildingId = nil,
    m_landItemOpenType = nil,
    city = nil,
    recapture_log = nil,
    treasure = nil,
    gameData = nil,
    enemy_tips_node = nil,
    win_tips_label = nil,
    title_sprite = nil,
    enemy_info_node = nil,
    recover_label = nil,
    cardLayer = nil,
    m_next_step = nil,
    m_combat_label = nil,
};

--[[--
    销毁
]]
function game_pirate_enemy_pop.destroy(self)
    -- body
    cclog("-----------------game_pirate_enemy_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;

    self.name_label = nil;
    self.area_label = nil;
    self.level_label = nil;
    self.arena_label = nil;
    self.guild_label = nil;
    self.m_anim_node = nil;

    self.m_callFunc = nil;
    self.m_selBuildingId = nil;
    self.m_landItemOpenType = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.treasure = nil;
    self.gameData = nil;

    self.enemy_tips_node = nil;
    self.win_tips_label = nil;
    self.title_sprite = nil;
    self.enemy_info_node = nil;
    self.recover_label = nil;
    self.cardLayer = nil;
    self.m_next_step = nil;
    self.m_combat_label = nil;
end
--[[--
    返回
]]
function game_pirate_enemy_pop.back(self,type)
    game_scene:removePopByName("game_pirate_enemy_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_enemy_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                self.m_callFunc("close");
            end
            self:back();
        elseif btnTag == 100 then--恢复血量
            cclog("!!!!!!!!!")
        elseif btnTag == 101 then--战斗   
            cclog("kljlkjasfjadjsfkladjsfkladjsfjadsfjdjkls")
            local battleCfg = getConfig(game_config_field.map_treasure_detail_battle);
            local itemCfg = battleCfg:getNodeWithKey(tostring(self.m_selBuildingId))
            local imgName = itemCfg:getNodeWithKey("background"):toStr()
            local title_name = itemCfg:getNodeWithKey("title_name"):toStr()
            local fight_list = itemCfg:getNodeWithKey("fight_list")
            local fightCount = fight_list:getNodeCount()
            self.m_next_step = self.m_next_step or 0;--没打过的是0
            -- if game_data:getReMapBattleFlag() == false then--打过的话判断是否通关，没通关取上次打到第几次了
                local recapture_log = self.recapture_log or {}
                local recapture_log_item = recapture_log[tostring(self.m_selBuildingId)] or {}
                if #recapture_log_item > 0 then
                    self.m_next_step = recapture_log_item[#recapture_log_item] + 1;
                end
            -- end
            local function fightResponseMethod(tag,gameData)
                if gameData then
                    game_data:setBattleType("game_pirate_precious");
                    local data = gameData:getNodeWithKey("data")
                    local stageTableData = {name = title_name,step = self.m_next_step,totalStep = fightCount}
                    --传背景图
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
                end
            end
            local params = {}
            params.treasure = self.treasure
            params.city = self.city
            params.building = self.m_selBuildingId
            params.step_n = self.m_next_step
            cclog2(params,"params")
            --跳转到战斗
            network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("search_treasure_recapture"), http_request_method.GET, params,"search_treasure_recapture",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pirate_enemy.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local title118 = ccbNode:labelTTFForName("title118");
    local title119 = ccbNode:labelTTFForName("title119");
    local title120 = ccbNode:labelTTFForName("title120");
    local title121 = ccbNode:labelTTFForName("title121");
    local title122 = ccbNode:labelTTFForName("title122");
    local title123 = ccbNode:labelTTFForName("title123");
    title118:setString(string_helper.ccb.title118);
    title119:setString(string_helper.ccb.title119);
    title120:setString(string_helper.ccb.title120);
    title121:setString(string_helper.ccb.title121);
    title122:setString(string_helper.ccb.title122);
    title123:setString(string_helper.ccb.title123);
    local btn_continue = ccbNode:controlButtonForName("btn_continue")
    game_util:setCCControlButtonTitle(btn_continue,string_helper.ccb.title124)
    btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    if game_data:getRecoverFlag() then--已经收复，不让点了
        btn_continue:setVisible(false)
    else
        btn_continue:setVisible(true)
    end

    self.enemy_tips_node = ccbNode:nodeForName("enemy_tips_node")
    self.win_tips_label = ccbNode:labelTTFForName("win_tips_label")

    self.name_label = ccbNode:labelTTFForName("name_label")
    self.area_label = ccbNode:labelTTFForName("area_label")
    self.level_label = ccbNode:labelTTFForName("level_label")
    self.arena_label = ccbNode:labelTTFForName("arena_label")
    self.guild_label = ccbNode:labelTTFForName("guild_label")
    self.title_sprite = ccbNode:spriteForName("title_sprite")

    self.enemy_info_node = ccbNode:nodeForName("enemy_info_node")

    self.recover_label = ccbNode:labelBMFontForName("recover_label")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.cardLayer = {}
    for i=1,8 do
        self.cardLayer[i] = ccbNode:layerForName("m_cardlayer_" .. i)
    end

    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local big_img = game_util:createPlayerBigImgByRoleId(1);
    if big_img then
        self.m_anim_node:addChild(big_img);
        self.m_anim_node:setScale(0.45);
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_pirate_enemy_pop.refreshUi(self)
    self.name_label:setString(self.gameData.name)
    self.area_label:setString(self.gameData.server_name)
    self.level_label:setString(self.gameData.level)
    self.arena_label:setString(self.gameData.rank)
    self.guild_label:setString(self.gameData.guild_name)

    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local big_img = game_util:createPlayerBigImgByRoleId(tonumber(self.gameData.role));
    if big_img then
        self.m_anim_node:addChild(big_img);
        self.m_anim_node:setScale(0.45);
    end

    self:initTeamFormation(self.enemy_info_node);
    self.m_combat_label:setString(self.gameData.combat);
    local mapCfg = getConfig(game_config_field.map_treasure_detail_battle)
    local buildCfg = mapCfg:getNodeWithKey(tostring(self.m_selBuildingId))
    local title_detail = buildCfg:getNodeWithKey("title_detail"):toStr()
    self.win_tips_label:setString(title_detail);
end
--[[
    初始化阵型
]]
function game_pirate_enemy_pop.initTeamFormation(self,parentNode)
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = self.gameData.alignment_info[btnTag];
        if itemData then
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
        end
    end
    self.enemy_info_node:removeAllChildrenWithCleanup(true)
    local nodeSize = self.enemy_info_node:getContentSize()
    local itemId = nil;
    local itemData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    local character_detail_cfg = getConfig("character_detail");
    local dw = nodeSize.width / #self.gameData.alignment_info
    local dx = dw / 2
    for i=1,math.min(5,#self.gameData.alignment_info) do
        itemData = self.gameData.alignment_info[i];
        if itemData and itemData.c_id then
            heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
            if itemData and heroCfg then
                headIconSpr = game_util:createCardIconByCfg(heroCfg);
                if headIconSpr then
                    headIconSpr:setScale(0.8);
                    headIconSpr:setPosition(ccp(dx + (i-1)*dw,27));
                    self.enemy_info_node:addChild(headIconSpr,1,1);

                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTag(i)
                    button:setOpacity(0)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(dx + (i-1)*dw,27))
                    self.enemy_info_node:addChild(button);
                end
            end
        end
    end
end
--[[--
    初始化
]]
function game_pirate_enemy_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callFunc = t_params.callFunc;
    self.m_selBuildingId = t_params.buildingId;
    self.m_landItemOpenType = t_params.landItemOpenType or 1;
    self.city = t_params.city
    self.recapture_log = t_params.recapture_log
    self.treasure = t_params.treasure
    self.gameData = t_params.gameData
    -- cclog2(self.gameData,"self.gameData")
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_enemy_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_enemy_pop;