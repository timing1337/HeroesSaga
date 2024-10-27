--- 老玩家信息
local ui_comeback_playerinfo_pop = {
    m_ccbNode = nil,
    m_callBack = nil,
    m_gameData = nil,
};

--[[--
    销毁
]]
function ui_comeback_playerinfo_pop.destroy(self)
    -- body
    cclog("-----------------ui_comeback_playerinfo_pop destroy-----------------");
    self.m_ccbNode = nil;
    self.m_callBack = nil;
    self.m_gameData = nil;
end
--[[--
    返回
]]
function ui_comeback_playerinfo_pop.back(self,type)
    game_scene:removePopByName("ui_comeback_playerinfo_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_comeback_playerinfo_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then  -- 确认
            local function responseMethod(tag,gameData)
                game_scene:addPop("ui_comeback_cbrewards_pop", {gameData = gameData, callBack = self.m_callBack})
                self:back()
            end
            local params = {}
            params.tid = tostring(util.url_encode( self.m_gameData.uid ))
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_add_caller"), http_request_method.GET, params,"king_add_caller")
        elseif btnTag == 102 then  -- 重新输入
            if type(self.m_callBack) == "function" then
                self.m_callBack( "reInputUid" )
            end
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_comeback_playerinfo_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local btn_continue = ccbNode:controlButtonForName("btn_ok")
    btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local btn_reput = ccbNode:controlButtonForName("btn_reput")
    btn_reput:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)

    local data  =  self.m_gameData

    local info = {
        {title = string_helper.ui_comeback_playerinfo_pop.info1, msg = data.name },
        {title = string_helper.ui_comeback_playerinfo_pop.info2, msg = data.server_name},
        {title = string_helper.ui_comeback_playerinfo_pop.info3, msg = data.level},
        {title = string_helper.ui_comeback_playerinfo_pop.info4, msg = data.combat },
        {title = string_helper.ui_comeback_playerinfo_pop.info5, msg = (data.guild == nil or data.guild == "") and string_helper.ui_comeback_playerinfo_pop.none or data.guild },
    }
    for i=1, 5 do
        local m_node_info = ccbNode:nodeForName("m_node_info" .. i)
        local m_label_title = ccbNode:labelTTFForName("m_label_title" .. i)
        local m_label_info = ccbNode:labelTTFForName("m_label_info" .. i)
        local itemInfo = info[i]
        if not itemInfo and m_node_info then m_node_info:setVisible(false) end
        if itemInfo and m_label_title then
            m_label_title:setString(tostring( itemInfo.title ))
        end
        if itemInfo and m_label_info then
            m_label_info:setString(tostring( itemInfo.msg ))
        end
    end

    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    local role = self.m_gameData.role or math.random(1,5)
    local big_img = game_util:createPlayerBigImgByRoleId( role );
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
function ui_comeback_playerinfo_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function ui_comeback_playerinfo_pop.init(self,t_params)
    t_params = t_params or {};
    -- cclog2(self.gameData,"self.gameData")
    self.m_callBack = t_params.callBack
    self.m_gameData = {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
end

--[[--
    创建ui入口并初始化数据
]]
function ui_comeback_playerinfo_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_comeback_playerinfo_pop;