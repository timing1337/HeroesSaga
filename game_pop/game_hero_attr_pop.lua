---  卡牌属性弹出框 

local game_hero_attr_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_node = nil,
    m_arrow_spr = nil,
    m_9sprite_bg = nil,
    m_pos = nil,
    m_callFunc = nil,
    m_name_label = nil,
    m_attr_label_1 = nil,
    m_attr_label_2 = nil,
    m_attr_label_3 = nil,
    m_attr_value_label_1 = nil,
    m_attr_value_label_2 = nil,
    m_attr_value_label_3 = nil,
    m_status_label_2 = nil,
    m_status_label_3 = nil,
    m_selHeroId = nil,
    m_posNode = nil,
    m_attrType = nil,
    m_bg_node = nil,
};

--[[--
    销毁
]]
function game_hero_attr_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_attr_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_node = nil;
    self.m_arrow_spr = nil;
    self.m_9sprite_bg = nil;
    self.m_pos = nil;
    self.m_callFunc = nil;
    self.m_name_label = nil;
    self.m_attr_label_1 = nil;
    self.m_attr_label_2 = nil;
    self.m_attr_label_3 = nil;
    self.m_attr_value_label_1 = nil;
    self.m_attr_value_label_2 = nil;
    self.m_attr_value_label_3 = nil;
    self.m_status_label_2 = nil;
    self.m_status_label_3 = nil;
    self.m_selHeroId = nil;
    self.m_posNode = nil;
    self.m_attrType = nil;
    self.m_bg_node = nil;
end

local attrNameTab = {{string_helper.game_hero_attr_pop.attrNameTab1,"hp"},{string_helper.game_hero_attr_pop.attrNameTab2,"patk"},{string_helper.game_hero_attr_pop.attrNameTab3,"matk"},{string_helper.game_hero_attr_pop.attrNameTab4,"def"},{string_helper.game_hero_attr_pop.attrNameTab5,"speed"}};

--[[--
    返回
]]
function game_hero_attr_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_hero_attr_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_hero_attr_pop.createUi(self)
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
    ccbNode:openCCBFile("ccb/hero_attr_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node = ccbNode:nodeForName("m_node")
    self.m_arrow_spr = ccbNode:spriteForName("m_arrow_spr")
    self.m_9sprite_bg = tolua.cast(ccbNode:objectForName("m_9sprite_bg"), "CCScale9Sprite");--

    self.m_name_label = ccbNode:labelBMFontForName("m_name_label")
    self.m_attr_label_1 = ccbNode:labelBMFontForName("m_attr_label_1")
    self.m_attr_label_2 = ccbNode:labelBMFontForName("m_attr_label_2")
    self.m_attr_label_3 = ccbNode:labelBMFontForName("m_attr_label_3")
    self.m_attr_value_label_1 = ccbNode:labelTTFForName("m_attr_value_label_1")
    self.m_attr_value_label_2 = ccbNode:labelTTFForName("m_attr_value_label_2")
    self.m_attr_value_label_3 = ccbNode:labelTTFForName("m_attr_value_label_3")
    self.m_status_label_2 = ccbNode:labelBMFontForName("m_status_label_2")
    self.m_status_label_3 = ccbNode:labelBMFontForName("m_status_label_3")
    self.m_bg_node = ccbNode:nodeForName("m_bg_node")

    local m_node_size = self.m_node:getContentSize();
    if self.m_posNode then
        local tempPos = self.m_posNode:getAnchorPointInPoints();
        -- cclog("tolua.type(tempPos) = " .. tolua.type(tempPos) .. tempPos.x .. " ; " .. tempPos.y);
        local posNodeSize = self.m_posNode:getContentSize();
        local px,py = self.m_posNode:getPosition();
        px,py = px - tempPos.x + posNodeSize.width*0.5,py - tempPos.y + posNodeSize.height*0.5
        self.m_pos = self.m_posNode:getParent():convertToWorldSpace(ccp(px,py));
    end

    local pX = self.m_arrow_spr:getPositionX();
    if self.m_pos then
        local winSize = CCDirector:sharedDirector():getWinSize();
        local py = self.m_pos.y - m_node_size.height*0.5
        if py < 0 then
            self.m_node:setPosition(ccp(self.m_pos.x - pX,m_node_size.height*0.5));
        elseif py > (winSize.height - m_node_size.height) then
            self.m_node:setPosition(ccp(self.m_pos.x - pX,winSize.height - m_node_size.height*0.5));
        else
            self.m_node:setPosition(ccp(self.m_pos.x - pX,self.m_pos.y));
        end
    end
    local pX,pY = self.m_bg_node:getPosition();
    local tempPos = self.m_bg_node:getParent():convertToWorldSpace(ccp(pX,pY));
    local tempSize = self.m_bg_node:getContentSize();
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    if (tempPos.x + tempSize.width*0.5) > visibleSize.width then
        self.m_bg_node:setPositionX(pX - tempSize.width*0.5);
    end
    -- cclog("tempPos.x = " .. tempPos.x .. " ; tempSize.width = " .. tempSize.width*0.5);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 25,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_name_label:setString(string_helper.ccb.text1)
    self.m_attr_label_1:setString(string_helper.ccb.text2)
    self.m_attr_label_2:setString(string_helper.ccb.text3)
    self.m_attr_label_3:setString(string_helper.ccb.text4)
    self.m_status_label_2:setString(string_helper.ccb.text5)
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_hero_attr_pop.refreshUi(self)
    if self.m_attrType > 0 and self.m_attrType < 6 then
        local character_strengthen = getConfig("character_strengthen");
        local attrItem = attrNameTab[self.m_attrType];
        local attrName = attrItem[1]
        self.m_attr_label_1:setString(string_helper.game_hero_attr_pop.base .." " .. attrName .. ":")
        self.m_attr_label_2:setString(string_helper.game_hero_attr_pop.advance .. " " .. attrName .. ":")
        self.m_attr_label_3:setString(string_helper.game_hero_attr_pop.strengthen .. ":")
        self.m_name_label:setString(tostring(attrName));
        local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
        local totalValue = tonumber(cardData[attrNameTab[self.m_attrType][2]])

        local card_lv = cardData.lv
        local attr = attrItem[2];
        cclog("attr ================" .. attr)
        local crystal_lv = cardData[attr .."_crystal"];
        local crystal_value = 0;
        local item_cfg = character_strengthen:getNodeWithKey(tostring(crystal_lv));
        if item_cfg then
            crystal_value = item_cfg:getNodeWithKey(tostring("add_" .. attr)):toInt();
        end

        local base_value,growth_value;
        base_value = heroCfg:getNodeWithKey("base_" .. attr):toInt();
        growth_value = heroCfg:getNodeWithKey("growth_" .. attr):toInt();
        local temp_value = (base_value + growth_value*(card_lv - 1))

        self.m_attr_value_label_1:setString(tostring(temp_value))
        self.m_attr_value_label_2:setString(tostring(totalValue - temp_value - crystal_value))
        self.m_attr_value_label_3:setString(tostring(crystal_value))

        self.m_status_label_2:setString("")
        self.m_status_label_3:setString("Lv." .. tostring(crystal_lv))
    else
        self.m_name_label:setString("")
        self.m_attr_label_1:setString("")
        self.m_attr_label_2:setString("")
        self.m_attr_label_3:setString("")
        self.m_attr_value_label_1:setString("")
        self.m_attr_value_label_2:setString("")
        self.m_attr_value_label_3:setString("")
        self.m_status_label_2:setString("")
        self.m_status_label_3:setString("")
    end
end

--[[--
    初始化
]]
function game_hero_attr_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_pos = t_params.pos;
    self.m_callFunc = t_params.callFunc;
    self.m_selHeroId = t_params.selHeroId;
    self.m_posNode = t_params.posNode;
    self.m_attrType = t_params.attrType or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_attr_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_hero_attr_pop;