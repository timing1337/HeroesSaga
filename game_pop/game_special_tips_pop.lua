--- game_special_tips_pop信息

local game_special_tips_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,

    itemData = nil,
    hero_id = nil,
    m_tParams = nil,

    m_text_label = nil,
    m_func_btn_1 = nil,
    m_func_btn_2 = nil,
    hero_icon_node = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_close_btn = nil,

    show_node_btn = nil,
    show_node_label = nil,
    sliver_dir = nil,
    gold_dir = nil,

    sliver_dir_basis = nil,
    gold_dir_basis = nil,
};

--[[--
    销毁
]]
function game_special_tips_pop.destroy(self)
    -- body
    cclog("-----------------game_special_tips_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.itemData = nil;
    self.hero_id = nil;
    self.m_tParams = nil;

    self.m_text_label = nil;
    self.m_func_btn_1 = nil;
    self.m_func_btn_2 = nil;
    self.hero_icon_node = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_close_btn = nil;

    self.show_node_btn = nil;
    self.show_node_label = nil;
    self.sliver_dir = nil;
    self.gold_dir = nil;
    self.sliver_dir_basis = nil;
    self.gold_dir_basis = nil;
end
--[[--
    返回
]]
local quality_name = string_helper.game_special_tips_pop.quality_name

function game_special_tips_pop.back(self,type)
    game_scene:removePopByName("game_special_tips_pop");

end
--[[--
    读取ccbi创建ui
]]
function game_special_tips_pop.createUi(self)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/new_main_add_res.plist")
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 11 then
            self.m_tParams.okBtnCallBack()
        elseif btnTag == 12 then
            self:back()
        elseif btnTag == 101 then--左边跳转
            if self.m_openType == 1 or self.m_openType == 3 or self.m_openType == 4 or self.m_openType == 6 then--跳到分解
                if game_button_open :checkButtonOpen( 122 ) then
                    game_scene:enterGameUi("game_card_melting",{})
                    self:destroy()
                end
            elseif self.m_openType == 2 or self.m_openType == 5 or self.m_openType == 8 or self.m_openType == 10 then--跳到传承
                if not game_button_open:checkButtonOpen(506) then
                    game_scene:enterGameUi("game_hero_inherit");
                    self:destroy();
                end
            end
        elseif btnTag == 102 then--右边跳转
            if self.m_openType == 3 or self.m_openType == 6 then--跳到进阶
                game_scene:enterGameUi("game_hero_advanced_sure",{gameData = nil});
                self:destroy();
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_wanning_pop.ccbi");
    
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_text_label = ccbNode:labelTTFForName("m_text_label")
    self.m_func_btn_1 = ccbNode:controlButtonForName("m_func_btn_1")
    self.m_func_btn_2 = ccbNode:controlButtonForName("m_func_btn_2")
    self.hero_icon_node = ccbNode:nodeForName("hero_icon_node")
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    game_util:setCCControlButtonTitle(self.m_btn_1,string_helper.ccb.title8)
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    game_util:setCCControlButtonTitle(self.m_btn_2,string_helper.ccb.title9)
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    self.show_node_btn = ccbNode:nodeForName("show_node_btn")
    self.show_node_label = ccbNode:nodeForName("show_node_label")
    self.sliver_dir = ccbNode:labelTTFForName("sliver_dir")
    self.gold_dir = ccbNode:labelTTFForName("gold_dir")

    self.m_func_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_func_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)

    cclog("self.hero_id = " .. self.hero_id)
    local itemData,hero_config = game_data:getCardDataById(self.hero_id)

    local card_name = hero_config:getNodeWithKey("name"):toStr()
    local advance_step = itemData.step -- 进阶层数
    local lv = itemData.lv  --等级
    -- cclog("itemData == " .. json.encode(itemData))
    local quality = itemData.quality+1;--品质
    --[[
        排序：进阶过的，等级大于10的，蓝色以上的
        1-3     出售卡牌
        4-6     技能升级
        7-8     伙伴进阶    只考虑进阶了和等级大于10的
        9-10    伙伴分解    只考虑进阶了和等级大于10的
    ]]
    if self.m_openType == 1 then--出售高阶
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_1,card_name,lv,advance_step))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"m_button_melting.png")
        self.m_func_btn_1:setPreferredSize(CCSizeMake(50, 50))
        if not game_data:isViewOpenByID(133) then self.m_func_btn_1:setVisible(false) end
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.sell),CCControlStateNormal)
    elseif self.m_openType == 2 then--出售高等级的卡
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_2,card_name,lv))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"mbutton_5_5.png")
        if not game_data:isViewOpenByID(33) then self.m_func_btn_1:setVisible(false) end
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.sell),CCControlStateNormal)
    elseif self.m_openType == 3 then--出售蓝卡以上
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_3,card_name,lv,quality_name[quality]))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"m_button_melting.png")
        self.m_func_btn_1:setPreferredSize(CCSizeMake(50, 50))
        if not game_data:isViewOpenByID(133) then self.m_func_btn_1:setVisible(false) end
        game_util:setCCControlButtonBackground(self.m_func_btn_2,"mbutton_2_3.png")
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.sell),CCControlStateNormal)
    elseif self.m_openType == 4 then--技能升级 高阶
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_4,card_name,lv,advance_step))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"m_button_melting.png")
        self.m_func_btn_1:setPreferredSize(CCSizeMake(50, 50))
        if not game_data:isViewOpenByID(133) then self.m_func_btn_1:setVisible(false) end
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.levelUp),CCControlStateNormal)
    elseif self.m_openType == 5 then--技能升级 高级
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_5,card_name,lv))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"mbutton_5_5.png")
        if not game_data:isViewOpenByID(33) then self.m_func_btn_1:setVisible(false) end
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.levelUp),CCControlStateNormal)
    elseif self.m_openType == 6 then--技能升级 蓝色以上
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_6,card_name,lv,quality_name[quality]))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"m_button_melting.png")
        self.m_func_btn_1:setPreferredSize(CCSizeMake(50, 50))
        if not game_data:isViewOpenByID(133) then self.m_func_btn_1:setVisible(false) end
        game_util:setCCControlButtonBackground(self.m_func_btn_2,"mbutton_2_3.png")
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.levelUp),CCControlStateNormal)
    elseif self.m_openType == 7 then --伙伴进阶 高阶
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_7,card_name,lv,advance_step))
        self.show_node_btn:setVisible(false)
        self.show_node_label:setVisible(true)
        self.sliver_dir:setString(self.sliver_dir_basis)
        self.gold_dir:setString(self.gold_dir_basis)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.advance),CCControlStateNormal)
    elseif self.m_openType == 8 then --伙伴进阶 高级
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"mbutton_5_5.png")
        if not game_data:isViewOpenByID(33) then self.m_func_btn_1:setVisible(false) end
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_8,card_name,lv))
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.advance),CCControlStateNormal)
    elseif self.m_openType == 9 then -- 伙伴分解 高阶
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_9,card_name,lv,advance_step))
        self.show_node_btn:setVisible(false)
        self.show_node_label:setVisible(true)
        self.sliver_dir:setString(self.sliver_dir_basis)
        self.gold_dir:setString(self.gold_dir_basis)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.split),CCControlStateNormal)
    elseif self.m_openType == 10 then -- 伙伴分解 高级
        self.m_text_label:setString(string.format(string_config.m_seecial_tips_10,card_name,lv))
        self.show_node_btn:setVisible(true)
        self.show_node_label:setVisible(false)
        game_util:setCCControlButtonBackground(self.m_func_btn_1,"mbutton_5_5.png")
        self.m_func_btn_1:setPosition(ccp(90,25))
        self.m_func_btn_2:setVisible(false)
        self.m_btn_1:setTitleForState(CCString:create(string_helper.game_special_tips_pop.split),CCControlStateNormal)
        if not game_data:isViewOpenByID(33) then self.m_func_btn_1:setVisible(false) end
    end
    local hero_node = game_util:createHeroListItemByCCB(itemData);
    hero_node:setAnchorPoint(ccp(0.5,0.5))
    self.hero_icon_node:removeAllChildrenWithCleanup(true)

    game_util:setControlButtonTitleBMFont(self.m_func_btn_1)
    game_util:setControlButtonTitleBMFont(self.m_func_btn_2)
    game_util:setControlButtonTitleBMFont(self.m_btn_1)
    game_util:setControlButtonTitleBMFont(self.m_btn_2)
    self.hero_icon_node:addChild(hero_node)

    if not self.m_func_btn_1:isVisible() then 
        self.m_func_btn_2:setPosition(ccp(90,25))
    end
    if not game_data:isViewOpenByID(19) then 
        self.m_func_btn_2:setVisible(false) 
    end

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_special_tips_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_special_tips_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tParams = t_params;

    self.hero_id = t_params.hero_id
    self.m_openType = t_params.m_openType
    self.sliver_dir_basis = t_params.sliver_dir_basis
    self.gold_dir_basis = t_params.gold_dir_basis
end

--[[--
    创建ui入口并初始化数据
]]
function game_special_tips_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_special_tips_pop;