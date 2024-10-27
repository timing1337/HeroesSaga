--- gvg map pop

local game_gvg_map_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    mvp_node = nil,
    detail_node = nil,
    home_node = nil,
    guild_att_name = nil,
    guild_def_name = nil,
    mvp_name = nil,
    mvp_combat = nil,
    mvp_guild = nil,
    mvp_hurt = nil,
    join_count = nil,
    exchange_count = nil,
    total_hurt = nil,
    att_count = nil,
    left_hp = nil,
    fall_probability = nil,
    m_tGameData = nil,
};
--[[--
    销毁
]]
function game_gvg_map_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_map_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.mvp_node = nil;
    self.detail_node = nil;
    self.home_node = nil;
    self.guild_att_name = nil;
    self.guild_def_name = nil;
    self.mvp_name = nil;
    self.mvp_combat = nil;
    self.mvp_guild = nil;
    self.mvp_hurt = nil;
    self.join_count = nil;
    self.exchange_count = nil;
    self.total_hurt = nil;
    self.att_count = nil;
    self.left_hp = nil;
    self.fall_probability = nil;
    self.m_tGameData = nil;
end
--[[--
    返回
]]
function game_gvg_map_pop.back(self,type)
    game_scene:removePopByName("game_gvg_map_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_map_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 2 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_battle_info"), http_request_method.GET, nil,"guild_gvg_battle_info")
        elseif btnTag == 3 then--战报

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_map_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_refresh_btn = ccbNode:controlButtonForName("m_refresh_btn")
    local m_battle_log_btn = ccbNode:controlButtonForName("m_battle_log_btn")

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    m_refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    m_battle_log_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)

    game_util:setControlButtonTitleBMFont(m_refresh_btn)
    game_util:setControlButtonTitleBMFont(m_battle_log_btn)

    self.mvp_node = ccbNode:nodeForName("mvp_node")
    self.detail_node = ccbNode:nodeForName("detail_node")
    self.home_node = ccbNode:nodeForName("home_node")
    --攻守方
    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name") 
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")
    --相信信息的 label
    self.mvp_name = ccbNode:labelTTFForName("mvp_name")
    self.mvp_combat = ccbNode:labelTTFForName("mvp_combat")
    self.mvp_guild = ccbNode:labelTTFForName("mvp_guild")
    self.mvp_hurt = ccbNode:labelTTFForName("mvp_hurt")
    self.join_count = ccbNode:labelTTFForName("join_count")
    self.exchange_count = ccbNode:labelTTFForName("exchange_count")
    self.total_hurt = ccbNode:labelTTFForName("total_hurt")
    self.att_count = ccbNode:labelTTFForName("att_count")
    self.left_hp = ccbNode:labelTTFForName("left_hp")
    self.fall_probability = ccbNode:labelTTFForName("fall_probability")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 9,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_gvg_map_pop.refreshUi(self)
    --设置label文字
    self.guild_att_name:setString(self.attacker)
    self.guild_def_name:setString(self.defender)
    self.mvp_name:setString(self.m_tGameData.niubi.name)
    self.mvp_combat:setString(self.m_tGameData.niubi.combat)
    self.mvp_guild:setString(self.m_tGameData.niubi.guild_name)
    self.mvp_hurt:setString(self.m_tGameData.niubi.score)
    self.join_count:setString(self.m_tGameData.info.capture_times)
    self.exchange_count:setString(self.m_tGameData.info.partake_times)
    self.total_hurt:setString("")
    self.att_count:setString(self.m_tGameData.home.battle_num)
    self.left_hp:setString(self.m_tGameData.home.remainder_hp)
    self.fall_probability:setString(self.m_tGameData.home.battle_rate)

    --加icon
    self.mvp_node:removeAllChildrenWithCleanup(true)
    self.detail_node:removeAllChildrenWithCleanup(true)
    self.home_node:removeAllChildrenWithCleanup(true)

    local role = self.m_tGameData.niubi.role or 1
    local icon = game_util:createPlayerIconByRoleId(tostring(role));
    local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
    if icon then
        icon_alpha:setAnchorPoint(ccp(0.5,0.5))
        icon_alpha:setPosition(ccp(7,4))
        icon_alpha:setOpacity(100)
        icon_alpha:setColor(ccc3(0,0,0))
        icon_alpha:setScale(0.75)
        self.mvp_node:addChild(icon_alpha)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(5,5))
        icon:setScale(0.75)
        self.mvp_node:addChild(icon);
    else
        cclog("tempFrontUser.role " .. role .. " not found !")
    end
    --详情icon
    self.detail_node:addChild(game_util:createIconByName("i_b_yuanli_2.png"))
    --主家icon
    self.home_node:addChild(game_util:createIconByName("icon_gvg_home.png"))
end
--[[--
    初始化
]]
function game_gvg_map_pop.init(self,t_params)
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.attacker = t_params.attacker
    self.defender = t_params.defender
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_map_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_gvg_map_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_map_pop;