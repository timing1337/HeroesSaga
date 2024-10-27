--- 活动奖励

local game_active_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_title_label = nil,
    m_sell_btn_1 = nil,
    m_sell_btn_2 = nil,
    m_sell_btn_3 = nil,
    m_tips_label_1 = nil,
    m_tips_label_2 = nil,
    m_tips_label_3 = nil,
    m_tParams = nil,
};
--[[--
    销毁
]]
function game_active_pop.destroy(self)
    -- body
    cclog("-----------------game_active_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_title_label = nil;
    self.m_sell_btn_1 = nil;
    self.m_sell_btn_2 = nil;
    self.m_sell_btn_3 = nil;
    self.m_tips_label_1 = nil;
    self.m_tips_label_2 = nil;
    self.m_tips_label_3 = nil;
    self.m_tParams = nil;
end
--[[--
    返回
]]
function game_active_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_active_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_active_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 or btnTag == 12 or btnTag == 13 then--
            if self.m_tParams.m_showType == 1 then
                self:auto_add(btnTag - 10);
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_month_gift.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_sell_btn_1 = ccbNode:controlButtonForName("m_sell_btn_1")
    self.m_sell_btn_2 = ccbNode:controlButtonForName("m_sell_btn_2")
    self.m_sell_btn_3 = ccbNode:controlButtonForName("m_sell_btn_3")
    self.m_tips_label_1 = ccbNode:labelTTFForName("m_tips_label_1")
    self.m_tips_label_2 = ccbNode:labelTTFForName("m_tips_label_2")
    self.m_tips_label_3 = ccbNode:labelTTFForName("m_tips_label_3")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_sell_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_sell_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_sell_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_title_label:setString(string_helper.game_active_pop.titile)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
]]
function game_active_pop.auto_add(self,tag)
    local callBackFunc = self.m_tParams.callBackFunc

    local auto_add_Quality = tag - 1;
    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    local itemCfg = nil;
    for key,heroData in pairs(cardsDataTable) do
        if not game_data:heroInTeamById(key) and not game_util:getCardLockFlag(heroData) then
            itemCfg = character_detail:getNodeWithKey(heroData.c_id);
            if itemCfg:getNodeWithKey("quality"):toInt() <= auto_add_Quality then
                showHeroTable[#showHeroTable+1] = heroData.id
            end
        end
    end
    cclog("sellCards #showHeroTable ====================== " .. #showHeroTable)
    cclog("showHeroTable == "..json.encode(showHeroTable))

    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(showHeroTable);
    end
    if #showHeroTable == 0 then
        game_util:addMoveTips({text = string_helper.game_active_pop.noneTips});
    else
        self:back()
    end
end
--[[--
    刷新ui
]]
function game_active_pop.refreshUi(self)
    self.m_tips_label_1:setString(string_helper.game_active_pop.whiteTips)
    self.m_tips_label_2:setString(string_helper.game_active_pop.GreenTips)
    self.m_tips_label_3:setString(string_helper.game_active_pop.BlueTips)
end

--[[--
    初始化
]]
function game_active_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_active_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_active_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_active_pop;