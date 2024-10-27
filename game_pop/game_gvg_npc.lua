--- gvg npc 
local game_gvg_npc = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    
    m_callFunc = nil,
    treasure = nil,
    gameData = nil,
    firstFight = nil,

    m_anim_node = nil,
    enemy_info_node = nil,

    fight_flag = nil,
    protect_node = nil,
    tip_label = nil,
    countDownTime = nil,
    buildingId = nil,
    building_cid = nil,

    btn_continue = nil,
    enterType = nil,
    is_def = nil,
    callFunc = nil,
    reboot = nil,
    owner = nil,
    life = nil,

    owner_times = nil,
    cd_flag = nil,
    can_buy_times = nil,
};

--[[--
    销毁
]]
function game_gvg_npc.destroy(self)
    -- body
    cclog("-----------------game_gvg_npc destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    
    self.m_callFunc = nil;
    self.treasure = nil;
    self.gameData = nil;
    self.firstFight = nil;

    self.m_anim_node = nil;
    self.enemy_info_node = nil;
    self.fight_flag = nil;
    self.protect_node = nil;
    self.tip_label = nil;
    self.countDownTime = nil;
    self.buildingId = nil;
    self.building_cid = nil;
    ---------
    self.btn_continue = nil;
    self.enterType = nil;
    self.is_def = nil;
    self.callFunc = nil;
    self.reboot = nil;
    self.owner = nil;
    self.life = nil;

    self.owner_times = nil;
    self.cd_flag = nil;
    self.can_buy_times = nil;
end
--[[--
    返回
]]
function game_gvg_npc.back(self,type)
    -- game_scene:removePopByName("game_gvg_npc");
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local sort = data:getNodeWithKey("sort"):toInt()
        if sort == 1 then--外围战布阵开启
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
        elseif sort == 2 then--外围战战争开始
            game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
        elseif sort == 3 then--内城布阵开始
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
        elseif sort == 4 then--内城战开始
            game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
        elseif sort == 5 then
            
        elseif sort == -1 then--公会战未开启
            game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_npc.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            if self.enterType == "half" then--上半场战斗
                local gvgCfg = getConfig(game_config_field.guild_fight)
                local itemCfg = gvgCfg:getNodeWithKey(tostring(self.buildingId))
                local function responseMethod(tag,gameData)
                    game_data:setBattleType("game_gvg");
                    local data = gameData:getNodeWithKey("data")
                    local building_name = itemCfg:getNodeWithKey("building_name"):toStr()
                    local stageTableData = {name = building_name,step = 1,totalStep = 1}
                    --传背景图
                    -- local backImgCfg = self.liveCfg:getNodeWithKey(tostring(self.curr_level))
                    -- local imgName = backImgCfg:getNodeWithKey("background"):toStr();
                    game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=nil});
                end
                if self.owner_times > 0 then--次数大于0
                    if self.cd_flag == false then--次数大于0且不在cd
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_attack"), http_request_method.GET, {building_id = self.buildingId},"guild_gvg_attack")
                    else--否则买时间
                        local function buyTimeResponseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gvgData = data:getNodeWithKey("gvg")
                            self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                            if self.m_tGameData.owner_time > 0 then
                                self.cd_flag = true
                            else
                                self.cd_flag = false
                            end
                            self.owner_times = self.m_tGameData.owner_times
                            self.can_buy_times = self.m_tGameData.can_buy_times
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
                            text = string_helper.game_gvg_npc.tips1,      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-17,
                        }
                        game_util:openAlertView(t_params)
                    end
                else--次数为0，买次数
                    if self.can_buy_times > 0 then--可购买次数大于0
                        local function buyTimeResponseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local gvgData = data:getNodeWithKey("gvg")
                            self.m_tGameData = json.decode(gvgData:getFormatBuffer()) or {};
                            if self.m_tGameData.owner_time > 0 then
                                self.cd_flag = true
                            else
                                self.cd_flag = false
                            end
                            self.owner_times = self.m_tGameData.owner_times
                            self.can_buy_times = self.m_tGameData.can_buy_times
                            game_util:closeAlertView()
                        end
                        local t_params = 
                        {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                network.sendHttpRequest(buyTimeResponseMethod,game_url.getUrlForKey("guild_gvg_buy_times"), http_request_method.GET, nil,"guild_gvg_buy_times")
                            end,   --可缺省
                            okBtnText = string_config.m_btn_sure,       --可缺省
                            cancelBtnText = string_config.m_btn_cancel,
                            text = string_helper.game_gvg_npc.tips2,      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-17,
                        }
                        game_util:openAlertView(t_params)
                    else
                        game_util:addMoveTips({text = string_helper.game_gvg_npc.tips3})
                    end
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_npc_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.btn_continue = ccbNode:controlButtonForName("btn_continue")
    self.btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.enemy_info_node = ccbNode:nodeForName("enemy_info_node")


    -- self.protect_node = ccbNode:nodeForName("protect_node")--保护时间倒计时
    -- self.tip_label = ccbNode:labelTTFForName("tip_label")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text216)

    game_util:setCCControlButtonTitle(self.btn_continue,string_helper.ccb.text218)
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_gvg_npc.refreshUi(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    -- local enemy_detail = self.gameData.enemy_detail[tostring(self.firstFight)]
    local enemy_id = nil
    for k,v in pairs(self.gameData.enemy_detail) do
        enemy_id = k
    end
    if enemy_id ~= nil then
        local enemy_detail = self.gameData.enemy_detail[tostring(enemy_id)]
        local animFile = enemy_detail.animation
        local animNode = game_util:createIdelAnim(animFile)
        animNode:setAnchorPoint(ccp(0.5,0))
        self.m_anim_node:addChild(animNode,2,2)
    end
    -- local position = map_fight["position" .. btnTag][1]
    -- local animFile = enemy_detail.animation
    -- local animNode = game_util:createIdelAnim(animFile)
    -- animNode:setAnchorPoint(ccp(0.5,0))
    -- self.m_anim_node:addChild(animNode,2,2)
    self:initTeamFormation(self.enemy_info_node)
    -- cclog2(self.is_def,"self.is_def")
    -- cclog2(self.buildingId,"self.buildingId")
    -- cclog2(self.enterType,"self.enterType")
    if self.enterType == "half" then--上半场
        if self.is_def == true then--自己是防守方
            if self.buildingId > 100 then--攻击方的地块，可以打
                self.btn_continue:setVisible(true)
            else
                self.btn_continue:setVisible(false)
            end
        else--自己是攻击方
            if self.buildingId > 100 then--
                self.btn_continue:setVisible(false)
            else
                self.btn_continue:setVisible(true)
            end
        end
        if self.life <= 0 then
            self.btn_continue:setVisible(false)
        end
    end
end
--[[
    初始化阵型
]]
function game_gvg_npc.initTeamFormation(self,node)
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
function game_gvg_npc.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.is_def = data:getNodeWithKey("is_def"):toBool()
        local gvgData = data:getNodeWithKey("gvg")
        self.gameData = json.decode(gvgData:getFormatBuffer()) or {};
        -- self.countDownTime = data:getNodeWithKey("time"):toInt()
        for k,v in pairs(self.gameData.map_fight) do
            self.firstFight = k
        end
        self.buildingId = t_params.buildingId
        -- self.building_cid = t_params.building_cid--配置的id
    else
        self.gameData = {};
    end
    self.enterType = t_params.enterType
    self.life = t_params.life
    self.owner_times = t_params.owner_times
    self.cd_flag = t_params.cd_flag
    self.can_buy_times = t_params.can_buy_times
end

--[[--
    创建ui入口并初始化数据
]]
function game_gvg_npc.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_gvg_npc;