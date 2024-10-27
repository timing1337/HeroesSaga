--- npc
local game_pirate_npc_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    
    m_callFunc = nil,
    m_selBuildingId = nil,
    m_landItemOpenType = nil,
    city = nil,
    recapture_log = nil,
    treasure = nil,
    gameData = nil,
    firstFight = nil,

    m_building_name = nil,
    m_anim_node = nil,
    enemy_info_node = nil,
};

--[[--
    销毁
]]
function game_pirate_npc_pop.destroy(self)
    -- body
    cclog("-----------------game_pirate_npc_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    
    self.m_callFunc = nil;
    self.m_selBuildingId = nil;
    self.m_landItemOpenType = nil;
    self.city = nil;
    self.recapture_log = nil;
    self.treasure = nil;
    self.gameData = nil;
    self.firstFight = nil;

    self.m_building_name = nil;
    self.m_anim_node = nil;
    self.enemy_info_node = nil;
end
--[[--
    返回
]]
function game_pirate_npc_pop.back(self,type)
    game_scene:removePopByName("game_pirate_npc_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_npc_pop.createUi(self)
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
            
        elseif btnTag == 101 then--战斗   
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
    ccbNode:openCCBFile("ccb/ui_pirate_npc_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local title114 = ccbNode:labelTTFForName("title114");
    title114:setString(string_helper.ccb.title114);
    local btn_continue = ccbNode:controlButtonForName("btn_continue")
    btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    game_util:setCCControlButtonTitle(btn_continue,string_helper.ccb.text251);

    if game_data:getRecoverFlag() then--已经收复，不让点了
        btn_continue:setVisible(false)
    else
        btn_continue:setVisible(true)
    end

    self.m_building_name = ccbNode:labelTTFForName("m_building_name")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.enemy_info_node = ccbNode:nodeForName("enemy_info_node")

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
function game_pirate_npc_pop.refreshUi(self)
    local mapCfg = getConfig(game_config_field.map_treasure_detail_battle)
    local buildCfg = mapCfg:getNodeWithKey(tostring(self.m_selBuildingId))
    local title_name = buildCfg:getNodeWithKey("title_name"):toStr()
    local title_img = buildCfg:getNodeWithKey("title_img"):toStr()

    self.m_building_name:setString(title_name)
    local firstValue,_ = string.find(title_img,".png");
    local buildingSpr = CCSprite:create("building_img/" .. title_img .. (firstValue == nil and ".png" or ""));
    local buildingSize = buildingSpr:getContentSize();
    local scale = math.min(buildingSize.width~=0 and 120/buildingSize.width or 1,buildingSize.height~=0 and 120/buildingSize.height or 1);
    buildingSpr:setScale(scale);
    buildingSpr:setAnchorPoint(ccp(0.5, 0));
    self.m_anim_node:addChild(buildingSpr,10,10)

    self:initTeamFormation(self.enemy_info_node)
end
--[[
    初始化阵型
]]
function game_pirate_npc_pop.initTeamFormation(self,node)
    
    self.enemy_info_node:removeAllChildrenWithCleanup(true)
    local nodeSize = self.enemy_info_node:getContentSize()
    local itemId = nil;
    local itemData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    
    local dw = nodeSize.width / 5
    local dx = dw / 2

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local map_fight = self.gameData.map_fight[tostring(self.firstFight)]
        local position = map_fight["position" .. btnTag][1]
        local posX,posY = tagNode:getPosition()
        local itemData = self.gameData.enemy_detail[tostring(position)]
        local tempPos = tagNode:getParent():convertToWorldSpace(ccp(posX,posY+65))
        if itemData then
            game_scene:addPop("game_enemy_info_pop",{itemCfg = itemData,pos = tempPos,openType = 2})
        end
    end

    local map_fight = self.gameData.map_fight[tostring(self.firstFight)]
    for i=1,5 do
        local position = map_fight["position" .. i][1]
        if position then
            local itemData = self.gameData.enemy_detail[tostring(position)]
            local tempIcon = game_util:createIconByName(tostring(itemData.img))
            if tempIcon then
                tempIcon:setScale(0.8);
                tempIcon:setPosition(ccp(dx + (i-1)*dw,27));
                self.enemy_info_node:addChild(tempIcon,1,1);

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
--[[--
    初始化
]]
function game_pirate_npc_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callFunc = t_params.callFunc;
    self.m_selBuildingId = t_params.buildingId;
    self.m_landItemOpenType = t_params.landItemOpenType or 1;
    self.city = t_params.city
    self.recapture_log = t_params.recapture_log
    self.treasure = t_params.treasure
    self.gameData = t_params.gameData
    self.firstFight = t_params.firstFight
    -- cclog2(self.gameData,"self.gameData")
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_npc_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_npc_pop;