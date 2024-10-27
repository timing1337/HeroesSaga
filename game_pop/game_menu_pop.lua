---  好友 

local game_menu_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_btn_node = nil,
    m_arrow_spr = nil,
    m_title_label = nil,
    m_9sprite_bg = nil,
    m_menuTab = nil,
    m_pos = nil,
    m_callFunc = nil,
    m_title = nil,
};

--[[--
    销毁
]]
function game_menu_pop.destroy(self)
    -- body
    cclog("-----------------game_menu_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_btn_node = nil;
    self.m_arrow_spr = nil;
    self.m_title_label = nil;
    self.m_9sprite_bg = nil;
    self.m_menuTab = nil;
    self.m_pos = nil;
    self.m_callFunc = nil;
    self.m_title = nil;
end
--[[--
    返回
]]
function game_menu_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_menu_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_menu_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ================" .. btnTag)
        if self.m_callFunc and type(self.m_callFunc) == "function" then
            self.m_callFunc(btnTag);
        end
    end

    -- ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_menu_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_btn_node = ccbNode:nodeForName("m_btn_node")
    self.m_arrow_spr = ccbNode:spriteForName("m_arrow_spr")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_9sprite_bg = tolua.cast(ccbNode:objectForName("m_9sprite_bg"), "CCScale9Sprite");--

    local menuItemCount = #self.m_menuTab;
    local m_btn_node_size = self.m_btn_node:getContentSize();
    m_btn_node_size = CCSizeMake(m_btn_node_size.width,30*(menuItemCount+1))
    self.m_btn_node:setContentSize(m_btn_node_size)
    self.m_9sprite_bg:setPreferredSize(m_btn_node_size)
    self.m_9sprite_bg:setPositionY(m_btn_node_size.height*0.5)
    self.m_title_label:setPositionY(m_btn_node_size.height-10)
    self.m_arrow_spr:setPositionY(m_btn_node_size.height*0.5)
    self.m_title_label:setString(self.m_title);

    for i=1,menuItemCount do
        local params = {}
        if self.m_menuTab[i].type == 1 then
            params.btnImgName="public_enniu.png";
            params.btnImgNameSel="public_neiniu_1.png";
        else
            params.btnImgName="public_enniu.png";
            params.btnImgNameSel="public_neiniu_1.png";
        end
        params.text=tostring(self.m_menuTab[i].title)
        params.callFunc = onMainBtnClick;
        params.touchPriority = GLOBAL_TOUCH_PRIORITY-6
        local btnTemp = game_util:createCCControlButtonByTable(params);
        btnTemp:setPreferredSize(CCSizeMake(70, 30));
        btnTemp:setTag(i);
        btnTemp:setPosition(m_btn_node_size.width*0.5,m_btn_node_size.height- 35 - 30*(i-1));
        self.m_btn_node:addChild(btnTemp)
    end
    if self.m_pos then
        local winSize = CCDirector:sharedDirector():getWinSize();
        local py = self.m_pos.y - m_btn_node_size.height*0.5
        if py < 0 then
            self.m_btn_node:setPosition(ccp(self.m_pos.x,m_btn_node_size.height*0.5));
            -- self.m_arrow_spr:setPositionY(40)
        elseif py > (winSize.height - m_btn_node_size.height) then
            self.m_btn_node:setPosition(ccp(self.m_pos.x,winSize.height - m_btn_node_size.height*0.5));
        else
            self.m_btn_node:setPosition(self.m_pos);
        end
        self.m_arrow_spr:setPosition(self.m_pos);
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_menu_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function game_menu_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_menuTab = t_params.menuTab or {};
    self.m_pos = t_params.pos;
    self.m_callFunc = t_params.callFunc;
    self.m_title = t_params.title or "";
end

--[[--
    创建ui入口并初始化数据
]]
function game_menu_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_menu_pop;