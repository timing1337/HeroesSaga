--- 队伍信息
local game_pirate_team_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,
    m_look_flag = nil,
    m_table_view = nil,
    m_isBeganIn = nil,
    whatsIn = nil,
    alignment = nil,
    total_hp = nil,
    leftHeals = nil,
};

--[[--
    销毁
]]

function game_pirate_team_pop.destroy(self)
    -- body
    cclog("-----------------game_pirate_team_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.m_look_flag = nil;
    self.m_table_view = nil;
    self.m_isBeganIn = nil;
    self.whatsIn = nil;
    self.alignment = nil;
    self.total_hp = nil;
    self.leftHeals = nil;
end
--[[--
    返回
]]
function game_pirate_team_pop.back(self,closeType)
    if self.addHpFlag == true then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
            self:destroy();
        end
        local params = {}
        params.treasure = self.treasure
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
    else
        if self.m_callBackFunc then
            self.m_callBackFunc()
        end
        game_scene:removePopByName("game_pirate_team_pop");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_team_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 100 then--恢复血量
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.total_hp_rate = data:getNodeWithKey("total_hp_rate"):toInt()
                self.total_hp = json.decode(data:getNodeWithKey("total_hp"):getFormatBuffer())
                self.heal_times = data:getNodeWithKey("heal_times"):toInt()
                self.leftHeals = math.max(self.leftHeals - 1,0)
                self:refreshUi()
                self.addHpFlag = true
            end
            local params = {}
            params.treasure = self.treasure
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_recover_hp"), http_request_method.GET, params,"search_treasure_recover_hp")
        elseif btnTag == 3 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pirate_team_info.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-21)

    local btn_recover = ccbNode:controlButtonForName("btn_recover")
    btn_recover:setTouchPriority(GLOBAL_TOUCH_PRIORITY-21)

    self.recover_label = ccbNode:labelBMFontForName("recover_label")
    self.percent_label = ccbNode:labelBMFontForName("percent_label")
    self.cardLayer = {}
    for i=1,8 do
        self.cardLayer[i] = ccbNode:layerForName("m_cardlayer_" .. i)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-20,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_pirate_team_pop.refreshUi(self)
    local masterAtt = self.alignment[1]
    local subAtt = self.alignment[2]
    for i=1,8 do
        if i <= 5 then
            table.insert(self.team_info,masterAtt[i])
        else
            table.insert(self.team_info,subAtt[i-5])
        end
        --1~5是主战 
        local heroId = self.team_info[i]
        cclog2(heroId,"heroId")
        if heroId ~= "-1" then
            local cId = self.total_hp[tostring(heroId)].c_id
            local icon = game_util:createCardIconByCid(cId)
            if icon then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:ignoreAnchorPointForPosition(true);
                self.cardLayer[i]:addChild(icon,10,10);
            end

            --加血条
            local life_bar = self.cardLayer[i]:getChildByTag(11)
            if life_bar then
                life_bar:removeFromParentAndCleanup(true)
            end
            local max_value = self.total_hp[tostring(heroId)].max_hp
            local now_value = self.total_hp[tostring(heroId)].cur_hp
            -- if i % 2 == 0 then
            --     now_value = 0
            -- else
            --     now_value = 1000
            -- end
            local bar = ExtProgressTime:createWithFrameName("pirate_hero_life_1.png","pirate_hero_life.png")
            bar:setMaxValue(max_value);
            bar:setCurValue(now_value,false);
            bar:setAnchorPoint(ccp(0.5,0.5))
            -- bar:ignoreAnchorPointForPosition(true);
            bar:setPosition(ccp(22,-8))
            self.cardLayer[i]:addChild(bar,10,11)

            local spriteWeak = self.cardLayer[i]:getChildByTag(12)
            if spriteWeak then
                spriteWeak:removeFromParentAndCleanup(true)
            end
            local spriteDie = self.cardLayer[i]:getChildByTag(13)
            if spriteDie then
                spriteDie:removeFromParentAndCleanup(true)
            end

            --加虚弱或死亡
            if icon then
                if now_value <= 0 then
                    icon:setColor(ccc3(250,0,0))
                    local sprite = CCSprite:createWithSpriteFrameName("pirate_death.png")
                    sprite:setAnchorPoint(ccp(0.5,0.5))
                    sprite:setPosition(ccp(43,8))
                    self.cardLayer[i]:addChild(sprite,10,13)
                elseif now_value > 0 and (now_value/max_value) < 0.3 then--虚弱
                    icon:setColor(ccc3(150,0,255))
                    local sprite = CCSprite:createWithSpriteFrameName("pirate_weak.png")
                    sprite:setAnchorPoint(ccp(0.5,0.5))
                    sprite:setPosition(ccp(43,8))
                    self.cardLayer[i]:addChild(sprite,10,12)
                end
            end
        end
    end

    self.recover_label:setString("×" .. self.leftHeals)
    self.percent_label:setString(self.hp_heal_percent .. "%")
end

--[[--
    初始化
]]
function game_pirate_team_pop.init(self,t_params)
    t_params = t_params or {};
    self.team_info = {}
    self.alignment = t_params.alignment
    self.total_hp = t_params.total_hp
    self.leftHeals = t_params.leftHeals
    self.hp_heal_percent = t_params.hp_heal_percent
    self.die = t_params.die
    self.treasure = t_params.treasure
    self.addHpFlag = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_team_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_team_pop;