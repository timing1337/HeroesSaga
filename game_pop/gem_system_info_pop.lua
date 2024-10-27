--- 宝石信息

local gem_system_info_pop = {
    m_tGameData = nil,
    m_popUi = nil,
    m_fromUi = nil,
    m_name_label = nil,
    m_icon_spr = nil,
    m_ability1_name_label = nil,
    m_level_label = nil,
    m_ability1_label = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_openType = nil,
    m_callBack = nil,
    m_node = nil,
    m_ability1_icon = nil,
    m_ccbNode = nil,
    m_suit_name_label = nil,
    m_posGemData = nil,
    m_btn_node = nil,
    m_ability2_name_label = nil,
    m_ability2_icon = nil,
};

--[[--
    销毁
]]
function gem_system_info_pop.destroy(self)
    -- body
    cclog("-----------------gem_system_info_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_name_label = nil;
    self.m_icon_spr = nil;
    self.m_ability1_name_label = nil;
    self.m_level_label = nil;
    self.m_ability1_label = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_openType = nil;
    self.m_callBack = nil;
    self.m_node = nil;
    self.m_ability1_icon = nil;
    self.m_ccbNode = nil;
    self.m_suit_name_label = nil;
    self.m_posGemData = nil;
    self.m_btn_node = nil;
    self.m_ability2_name_label = nil;
    self.m_ability2_icon = nil;
end
--[[--
    返回
]]
function gem_system_info_pop.back(self,type)
    game_scene:removePopByName("gem_system_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function gem_system_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then--升级
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("strengthen");
            else
                local tempId = self.m_tGameData == nil and nil or self.m_tGameData.id;
                game_scene:enterGameUi("gem_system_strengthen_scene",{selGemId = tempId});
            end
            self:back();
        elseif btnTag == 12 then--合成
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("synthesis");
            else
                local tempId = self.m_tGameData == nil and nil or self.m_tGameData.id;
                game_scene:enterGameUi("gem_system_synthesis",{selGemId = tempId});
                
            end
            self:back();
        elseif btnTag == 13 then--卸下
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("unload");
            else
                game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
            end
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gem_system_info_pop.ccbi");
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");

    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    self.m_ability1_name_label = ccbNode:labelTTFForName("m_ability1_name_label");
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label");
    self.m_ability1_label = ccbNode:labelBMFontForName("m_ability1_label");
    self.m_ability1_icon = ccbNode:spriteForName("m_ability1_icon");    
    self.m_ability2_label = ccbNode:labelBMFontForName("m_ability2_label");
    self.m_ability2_icon = ccbNode:spriteForName("m_ability2_icon");
    self.m_suit_name_label = ccbNode:labelBMFontForName("m_suit_name_label");
    self.m_btn_node = ccbNode:nodeForName("m_btn_node");
    self.m_level_label:setVisible(false)
    self.m_node = ccbNode:nodeForName("m_node")
    local tempBtn = nil;
    for i=1,3 do
        tempBtn = ccbNode:controlButtonForName("m_btn_" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
            -- game_util:setControlButtonTitleBMFont(tempBtn)
        end
    end
    self.m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;

    local m_btn_3 = ccbNode:controlButtonForName("m_btn_3")
    local m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    game_util:setCCControlButtonTitle(m_btn_2,string_helper.ccb.text200)
    game_util:setCCControlButtonTitle(m_btn_3,string_helper.ccb.text201)
    return ccbNode;
end

--[[--
    刷新ui
]]
function gem_system_info_pop.equipDetail(self)
    if self.m_tGameData == nil then return end
    self.m_ability1_name_label:setVisible(false);
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(tostring(self.m_tGameData.c_id));
    local function setEquipInfo()
        local attrName1,value1,icon1,attrName2,value2,icon2 = game_util:getGemAttributeValue(itemCfg);
        -- self.m_ability1_name_label:setString(attrName1 .. ":");
        self.m_ability1_label:setString("+" .. value1);
        local career = itemCfg:getNodeWithKey("career"):toInt();
        local last_name = itemCfg:getNodeWithKey("last_name"):toStr()
        local first_name = itemCfg:getNodeWithKey("first_name"):toStr()
        local count = self.m_tGameData.count or 0
        -- self.m_name_label:setString(last_name .. first_name .. " x" .. tostring(count));
        self.m_name_label:setString(last_name .. first_name)
        local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
        if tempDisplayFrame then
            self.m_ability1_icon:setDisplayFrame(tempDisplayFrame);
        end
        if value2 > 0 then
            self.m_ability2_label:setString("+" .. value2);
            local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
            if tempDisplayFrame then
                self.m_ability2_icon:setDisplayFrame(tempDisplayFrame);
            end
            local tempSize = self.m_ability1_icon:getParent():getContentSize()
            local width = tempSize.width
            self.m_ability1_icon:setPositionX(width*0.25)
            self.m_ability1_label:setPositionX(width*0.4)
            self.m_ability2_icon:setPositionX(width*0.55)
            self.m_ability2_label:setPositionX(width*0.7)
            self.m_ability2_label:setVisible(true)
            self.m_ability2_icon:setVisible(true)
        end
        local icon = game_util:createGemIconByCfg(itemCfg)
        if icon then
            local size = self.m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            self.m_icon_spr:addChild(icon)
        end
    end
    self.m_ccbNode:runAnimations("m_enter_anim_1")
    if itemCfg then
        setEquipInfo();
    end
end

--[[--
    刷新ui
]]
function gem_system_info_pop.refreshUi(self)
    self:equipDetail();
    if self.m_openType == 1 then
        self.m_btn_node:setVisible(false);
    elseif self.m_openType == 4 then
        self.m_btn_node:setVisible(false);
    else
        self.m_btn_node:setVisible(true);
    end
end

--[[--
    初始化
]]
function gem_system_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = t_params.tGameData;
    self.m_fromUi = t_params.fromUi;
    self.m_openType = t_params.openType or 1;
    self.m_callBack = t_params.callBack;
    self.m_posGemData = t_params.posGemData;
    print("self.m_tGameData.c_id ", json.encode(self.m_tGameData),  self.m_tGameData.c_id)
end

--[[--
    创建ui入口并初始化数据
]]
function gem_system_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return gem_system_info_pop;