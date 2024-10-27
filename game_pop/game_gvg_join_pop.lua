--- 加入公会战

local game_gvg_join_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    game_data = nil,
};

--[[--
    销毁
]]
function game_gvg_join_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_join_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.game_data = nil;
end
--[[--
    返回
]]
function game_gvg_join_pop.back(self,type)
    game_scene:removePopByName("game_gvg_join_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_join_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 3 then--进入
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_gvg_map",{gameData = gameData})--公会战战中
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_join_battle"), http_request_method.GET, nil,"guild_gvg_join_battle")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_join_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_button_3 = tolua.cast(ccbNode:objectForName("m_button_3"),"CCControlButton");

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    m_button_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    local def_guild = ccbNode:labelTTFForName("def_guild")
    local att_guild = ccbNode:labelTTFForName("att_guild")

    def_guild:setString(string_helper.game_gvg_join_pop.sc .. self.game_data.defender)
    att_guild:setString(string_helper.game_gvg_join_pop.gc .. self.game_data.attacker)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_gvg_join_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function game_gvg_join_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        local doing = data:getNodeWithKey("doing")
        self.game_data = json.decode(doing:getFormatBuffer())
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_gvg_join_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_gvg_join_pop;