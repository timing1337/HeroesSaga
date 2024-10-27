--- 装备信息

local game_equip_info_pop = {
    m_tGameData = nil,
    m_popUi = nil,
    m_fromUi = nil,
    m_name_label = nil,
    m_icon_spr = nil,
    m_ability1_name_label = nil,
    m_ability2_name_label = nil,
    m_level_label = nil,
    m_ability2_label = nil,
    m_ability1_label = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_openType = nil,
    m_callBack = nil,
    m_node = nil,
    m_ability1_icon = nil,
    m_ability2_icon = nil,
    m_ccbNode = nil,
    m_suit_name_label = nil,
    m_posEquipData = nil,
    m_btn_node = nil,
    m_node_getbtn_bg = nil,
    m_conbtn_toget = nil,
    m_togetFun = nil,
    m_suitEquipData = nil,
    m_sel_img = nil,
    m_label_name = nil,
};

--[[--
    销毁
]]
function game_equip_info_pop.destroy(self)
    -- body
    cclog("-----------------game_equip_info_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_name_label = nil;
    self.m_icon_spr = nil;
    self.m_ability1_name_label = nil;
    self.m_ability2_name_label = nil;
    self.m_level_label = nil;
    self.m_ability2_label = nil;
    self.m_ability1_label = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_openType = nil;
    self.m_callBack = nil;
    self.m_node = nil;
    self.m_ability1_icon = nil;
    self.m_ability2_icon = nil;
    self.m_ccbNode = nil;
    self.m_suit_name_label = nil;
    self.m_posEquipData = nil;
    self.m_btn_node = nil;
    self.m_node_getbtn_bg = nil;
    self.m_conbtn_toget = nil;
    self.m_togetFun = nil;
    self.m_suitEquipData = nil;
    self.m_sel_img = nil;
    self.m_label_name = nil;
end
--[[--
    返回
]]
function game_equip_info_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_equip_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_equip_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then--强化
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("strengthen");
            end
            self:back();
        elseif btnTag == 12 then--进阶
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("evolution");
            end
            self:back();
        elseif btnTag == 13 then--卸下
            if self.m_callBack and type(self.m_callBack) == "function" then
                self.m_callBack("unload");
            end
            self:back();
        elseif btnTag == 15 then-- 去获取
            if self.m_togetFun and type(self.m_togetFun) == "function" then
                self.m_togetFun();
            end
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_equip_info_pop.ccbi");
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");

    self.m_name_label = ccbNode:labelBMFontForName("m_name_label")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    self.m_ability1_name_label = ccbNode:labelTTFForName("m_ability1_name_label");
    self.m_ability2_name_label = ccbNode:labelTTFForName("m_ability2_name_label");
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label");
    self.m_ability2_label = ccbNode:labelBMFontForName("m_ability2_label");
    self.m_ability1_label = ccbNode:labelBMFontForName("m_ability1_label");
    self.m_ability1_icon = ccbNode:spriteForName("m_ability1_icon");
    self.m_ability2_icon = ccbNode:spriteForName("m_ability2_icon");
    self.m_suit_name_label = ccbNode:labelBMFontForName("m_suit_name_label");
    self.m_btn_node = ccbNode:nodeForName("m_btn_node");
    self.m_node_getbtn_bg = ccbNode:nodeForName("m_node_getbtn_bg");   -- 去获取装备按钮 board
    self.m_node_getbtn_bg:setVisible(false)

    self.m_icon_2_ability_1 = ccbNode:spriteForName("m_icon_2_ability_1")
    self.m_icon_2_ability_2 = ccbNode:spriteForName("m_icon_2_ability_2")
    self.m_label_2_ability_1 = ccbNode:spriteForName("m_label_2_ability_1")
    self.m_label_2_ability_2 = ccbNode:spriteForName("m_label_2_ability_2")

    self.m_conbtn_toget = ccbNode:controlButtonForName("m_conbtn_toget")  -- 去获取按钮
    game_util:setCCControlButtonTitle(self.m_conbtn_toget,string_helper.game_equip_info_pop.get);
    self.m_conbtn_toget:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);


    self.m_node = ccbNode:nodeForName("m_node")
    -- self.m_node:setVisible(false);
    local tempBtn = nil;
    for i=1,3 do
        tempBtn = ccbNode:controlButtonForName("m_btn" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
            game_util:setControlButtonTitleBMFont(tempBtn)
        end
    end

    if self.m_openType == 3 or self.m_openType == 4 then
        tempBtn = ccbNode:controlButtonForName("m_btn3")
        game_util:setCCControlButtonTitle(tempBtn,string_helper.game_equip_info_pop.equip);
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

    local touchLayer = CCLayer:create();
    self:initEquipLayerTouch(touchLayer);
    ccbNode:addChild(touchLayer)
    self.m_sel_img = CCSprite:createWithSpriteFrameName("public_light.png");
    self.m_sel_img:setVisible(false);
    self.m_sel_img:setScale(1.5);
    ccbNode:addChild(self.m_sel_img)

    self.m_ccbNode = ccbNode;

    local m_t_label2 = ccbNode:labelTTFForName("m_t_label2")
    m_t_label2:setString(string_helper.ccb.text130)
    local m_t_label3 = ccbNode:labelTTFForName("m_t_label3")
    m_t_label3:setString(string_helper.ccb.text131)
    local m_t_label4 = ccbNode:labelTTFForName("m_t_label4")
    m_t_label4:setString(string_helper.ccb.text132)

    local m_btn1 = ccbNode:controlButtonForName("m_btn1")
    game_util:setCCControlButtonTitle(m_btn1,string_helper.ccb.text133)
    local m_btn2 = ccbNode:controlButtonForName("m_btn2")
    game_util:setCCControlButtonTitle(m_btn2,string_helper.ccb.text134)
    local m_btn3 = ccbNode:controlButtonForName("m_btn3")
    game_util:setCCControlButtonTitle(m_btn3,string_helper.ccb.text135)
    local m_conbtn_toget = ccbNode:controlButtonForName("m_conbtn_toget")
    game_util:setCCControlButtonTitle(m_conbtn_toget,string_helper.ccb.text134)
    return ccbNode;
end

--[[--
    
]]
function game_equip_info_pop.initEquipLayerTouch(self,formation_layer)
    local tempItem,selItem = nil,nil
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        for i=1,4 do
            tempItem = self.m_ccbNode:spriteForName("m_suit_icon" .. i)
            if tempItem and tempItem:getParent():isVisible() then 
                realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y));
                if tempItem:boundingBox():containsPoint(realPos) then
                    tag = i;
                    selItem = tempItem;
                    break;
                end
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        if selItem then
            realPos = selItem:getParent():convertToNodeSpace(ccp(x,y));
            if selItem:boundingBox():containsPoint(realPos) then
                self:equipInfo(tag)
            end
        end
        tempItem = nil;
        tag = nil;
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)

        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11)
    formation_layer:setTouchEnabled(true)
end

--[[--
    刷新ui
]]
function game_equip_info_pop.equipInfo(self,posIndex)
    if self.m_suitEquipData == nil then return end
    local tempData = self.m_suitEquipData[posIndex];
    if tempData == nil then return end
    local itemData = tempData.itemData or {lv = 1,openValue = 1}
    local itemCfg = tempData.itemCfg;
    local level = itemData.lv;
    local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,level);
    self.m_ability1_name_label:setString(attrName1 .. ":");
    self.m_ability2_name_label:setString(attrName2 .. ":");

    self.m_ability1_label:setString("+" .. value1);
    self.m_ability2_label:setString("+" .. value2);

    local is_enchant = itemData.is_enchant == nil and false or itemData.is_enchant
    local atts = itemData.atts or {}
    cclog2(atts,"atts==")
    if is_enchant then -- 已附魔
        self.m_icon_2_ability_1:setVisible(false)
        self.m_icon_2_ability_2:setVisible(false)
        self.m_label_2_ability_1:setVisible(false)
        self.m_label_2_ability_2:setVisible(false)
        self.m_ccbNode:spriteForName("m_attr_node_1"):setPosition(ccp(132,81))
        local tempSpr ={}
        local i = 0 -- 计数 表示sprite的编号 1 2 
        for k,v in pairs(atts) do
            tempSpr = PUBLIC_ABILITY_NAME_TABLE[k] or {}
            -- cclog2(tempSpr,"tempSpr")
            i = i + 1
            local m_icon_ability = self.m_ccbNode:spriteForName("m_icon_2_ability_"..i)
            local m_label_ability = self.m_ccbNode:labelBMFontForName("m_label_2_ability_"..i)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tempSpr.icon))
            
            -- cclog2(tempSpriteFrame,"tempSpriteFrame")
            if tempSpriteFrame then
                m_icon_ability:setDisplayFrame(tempSpriteFrame)
                m_icon_ability:setVisible(true)
                local value,unit = game_util:formatValueToString2(v)
                cclog2(value..unit,"value..unit")
                m_label_ability:setString(value..unit)
                m_label_ability:setVisible(true)
            else
                m_icon_ability:setVisible(false)
                m_label_ability:setVisible(false)
            end
        end
    else
        -- 未附魔
        self.m_ccbNode:spriteForName("m_attr_node_1"):setPosition(ccp(132,71))
        self.m_ccbNode:spriteForName("m_attr_node_2"):setVisible(false)

    end




    local sort = itemCfg:getNodeWithKey("sort"):toInt();
     -- 1：武器，2：饰品，3：防具，4：鞋子，0：杂物（不可装备）
    local name_str = itemCfg:getNodeWithKey("name"):toStr() .. "(" .. tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]) .. ")"
    self.m_label_name:setString(name_str)
    -- self.m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]) .. ")");
    self.m_level_label:setString("Lv." ..level);

    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
    if tempDisplayFrame then
        self.m_ability1_icon:setDisplayFrame(tempDisplayFrame);
    end
    local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
    if tempDisplayFrame then
        self.m_ability2_icon:setDisplayFrame(tempDisplayFrame);
    end

    local icon = game_util:createEquipIcon(itemCfg)
    if icon then
        local size = self.m_icon_spr:getContentSize();
        icon:setPosition(ccp(size.width*0.5,size.height*0.5));
        self.m_icon_spr:addChild(icon)
        if itemData.openValue then
            icon:setColor(ccc3(71,71,71));
            -- icon:setColor(ccc3(255,0,0));
            local tempBg = tolua.cast(icon:getChildByTag(1),"CCSprite")
            if tempBg then
                tempBg:setColor(ccc3(71,71,71));
                -- tempBg:setColor(ccc3(0,255,0));
            end
        end
    end
    if sort == 0 then
        self.m_ability1_name_label:setString(string_helper.game_equip_info_pop.none);
        self.m_ability2_name_label:setString(string_helper.game_equip_info_pop.none);
        self.m_ability1_label:setString(string_helper.game_equip_info_pop.none);
        self.m_ability2_label:setString(string_helper.game_equip_info_pop.none);
        self.m_level_label:setString(string_helper.game_equip_info_pop.none);
    end

    local m_suit_icon = self.m_ccbNode:spriteForName("m_suit_icon" .. posIndex)
    if m_suit_icon then
        local pX,pY = m_suit_icon:getPosition();
        local tempPos = m_suit_icon:getParent():convertToWorldSpace(ccp(pX,pY));
        self.m_sel_img:setVisible(true);
        self.m_sel_img:setPosition(tempPos);
        -- cclog("posIndex = " .. posIndex)
        local suit = itemCfg:getNodeWithKey("suit"):toStr();
        -- cclog("suit = " .. suit)
        local suitCount,tempEquipData,_ = game_util:getEquipSuit(suit,self.m_posEquipData, self.m_equipData);
        -- print("suit info ==== ", json.encode(tempEquipData))

        local equipID = nil
        local equipCfg = getConfig(game_config_field.equip);
        local suitCfg = getConfig(game_config_field.suit);
        local suitItemCfg = suitCfg:getNodeWithKey(tostring(suit));
        -- print("suitItemCfg info ==== ", suitItemCfg:getFormatBuffer())
        if suitItemCfg then
            local part = suitItemCfg:getNodeWithKey("part")
            -- print("part info ==== ", part:getFormatBuffer())
            local partCount = part:getNodeCount();
            equipID = part:getNodeAt(posIndex - 1) and part:getNodeAt(posIndex - 1):toInt() or nil
            -- print("equipID info ==== ", equipID)
        end

        self.m_togetFun = nil

        if tempEquipData[posIndex] then
            if tempEquipData[posIndex].itemData == nil or self.m_openType == 4 then
                cclog("mei you a ", posIndex)
                -- cclog("tempEquipData[posIndex].itemData = " .. json.encode(tempEquipData[posIndex].itemData))
                --没有，按钮变成去获得
                local itemData = tempEquipData[posIndex].itemData
                self.m_togetFun = self:getGoToGetEquipFun( equipID )
                if self.m_togetFun then
                    self.m_node_getbtn_bg:setVisible(true)
                else
                    self.m_node_getbtn_bg:setVisible(false)
                end
                self.m_btn_node:setVisible(false);
            else
                if self.m_openType == 4 then
                    self.m_togetFun = self:getGoToGetEquipFun( equipID )
                    if  self.m_togetFun then
                        self.m_node_getbtn_bg:setVisible(true)
                    else
                        self.m_node_getbtn_bg:setVisible(false)
                    end
                    self.m_btn_node:setVisible(false);
                else  
                    self.m_btn_node:setVisible(true);
                    self.m_node_getbtn_bg:setVisible(false)
                end

                -- cclog("you zhe ge ", posIndex)
                -- cclog("tempEquipData[posIndex].itemData = " .. json.encode(tempEquipData[posIndex].itemData))
                -- --有，按钮是去强化等等等
            end
        end
    else
        self.m_togetFun = nil
        self.m_node_getbtn_bg:setVisible(false)
    end
end

--[[--
    弹框
]]

function tipNotEnough(isEliteOpen, goto)
    local text = ""
    local chaT = ""
    if goto then
        local chapter_cfg = getConfig(game_config_field.chapter)
        for i=1,#goto do
            local itemCfg = chapter_cfg:getNodeWithKey(tostring(goto[i]))
            print(" itemCfg  info is == ", itemCfg:getFormatBuffer())
            local name = itemCfg:getNodeWithKey("chapter_name"):toStr()
            local space = i==1 and "" or " "
            chaT = chaT .. space .. name
        end
    end

    if isEliteOpen then
        text = "" .. chaT .. string_helper.game_equip_info_pop.drop1 .. chaT .. string_helper.game_equip_info_pop.drop2
    else
        text = string_helper.game_equip_info_pop.drop3 .. chaT .. string_helper.game_equip_info_pop.drop2
    end
    local t_params = 
                    {
                        title = string_helper.game_equip_info_pop.prompt,
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close(); 
                        end,   --可缺省
                        text = text,
                        onlyOneBtn = true,          --可缺省
                    }
    require("game_ui.game_pop_up_box").show(t_params);
    -- require("game_ui.game_pop_up_box").showAlertView(msg or "等级不足，升级后解锁新功能");
end


--[[-- 
    获取去获得按钮
]]
function game_equip_info_pop.getGoToGetEquipFun( self, equip_id )
    -- print( "getGoToGetEquipFun equip_id == ", equip_id )
    if not equip_id then return end
    local getFun = nil
    local equip_detail_cfg = getConfig(game_config_field.equip);
    local equip_book_cfg = getConfig(game_config_field.equip_book);
    local equip_book_item_cfg = equip_book_cfg:getNodeWithKey( tostring(equip_id) )
    if equip_book_item_cfg == nil then return end
    local equip_id = equip_book_item_cfg:getNodeWithKey("equip_id"):toStr()
    local itemCfg = equip_detail_cfg:getNodeWithKey(equip_id)
    local gotoS = equip_book_item_cfg:getNodeWithKey("go_to")
    -- print("goto == ", equip_book_item_cfg:getFormatBuffer(), "  --  ")
    local goto = gotoS and json.decode(gotoS:getFormatBuffer())
    if itemCfg then
        -- print("goto == ", goto and json.encode(goto)) 
        if goto and type(goto) == "table" then
            gotoCount = #goto
        end
        local getFun = nil
        if gotoCount >0 then
            -- print(" ======== 1", id)
            local id = nil
            local openCha = game_data:getChapterTabByKey("openDifficult")
            for i=1, gotoCount do
                local ch1 = string.sub(tostring(goto[i]), 1, 3) or "1"
                if not id and openCha[ch1] then
                    id = ch1
                end
            end
            -- print(" ======== 2", id)
            if  not game_button_open:getOpenFlagByBtnId(800) then
            -- print(" ======== 3", id)
                getFun = function ()
                    -- print(  " 精英关卡还没有开启哦！！！  ",  json.encode( goto ) )
                    tipNotEnough(false, goto)
                end
                return getFun
            elseif id then
                -- print( " ididid ", id)
                ch1 = tonumber( id ) or 1
                getFun = function ()
                    local function responseMethod(tag,gameData)
                        game_data:setMapType()
                        game_scene:enterGameUi("map_world_scene",{gameData = gameData, chapterSwitchTo = "hard", assign_hard_chapter = ch1});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
                end
                return getFun
            else
                -- print( " 关卡还没有开启哦！！！ ", id)
                getFun = function ()
                    -- print(  " 关卡还没有开启哦！！！  ",  json.encode( goto ) )
                    tipNotEnough(true, goto)
                end
                return getFun
            end
        end
    end
    return getFun
end



--[[--
    刷新ui
]]
function game_equip_info_pop.equipDetail(self)
    if self.m_tGameData == nil then return end
    self.m_ability1_name_label:setVisible(false);
    self.m_ability2_name_label:setVisible(false);
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(self.m_tGameData.c_id));
    print("self.m_tGameData.c_id itemcfg ", self.m_tGameData.c_id, equip)
    cclog2(self.m_tGameData,"self.m_tGameData===")
    local function setEquipInfo()
        local level = self.m_tGameData.lv
        local attrName1,value1,attrName2,value2,icon1,icon2 = game_util:getEquipAttributeValue(itemCfg,level);
        self.m_ability1_name_label:setString(attrName1 .. ":");
        self.m_ability2_name_label:setString(attrName2 .. ":");
        self.m_ability1_label:setString("+" .. value1);
        self.m_ability2_label:setString("+" .. value2);

        local is_enchant = self.m_tGameData.is_enchant
        local atts = self.m_tGameData.atts
        if is_enchant then -- 已附魔
            self.m_icon_2_ability_1:setVisible(false)
            self.m_icon_2_ability_2:setVisible(false)
            self.m_label_2_ability_1:setVisible(false)
            self.m_label_2_ability_2:setVisible(false)
            self.m_ccbNode:spriteForName("m_attr_node_1"):setPosition(ccp(132,81))
            local tempSpr ={}
            -- local spriteTable = {self.m_property_sprite_add_1,self.m_property_sprite_add_2}
            local i = 0 -- 计数 表示sprite的编号 1 2 
            for k,v in pairs(atts) do
                tempSpr = PUBLIC_ABILITY_NAME_TABLE[k] or {}
                -- cclog2(tempSpr,"tempSpr")
                i = i + 1
                local m_icon_ability = self.m_ccbNode:spriteForName("m_icon_2_ability_"..i)
                local m_label_ability = self.m_ccbNode:labelBMFontForName("m_label_2_ability_"..i)
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tempSpr.icon))
                -- cclog2(tempSpriteFrame,"tempSpriteFrame")
                if tempSpriteFrame then
                    m_icon_ability:setDisplayFrame(tempSpriteFrame)
                    m_icon_ability:setVisible(true)
                    local value,unit = game_util:formatValueToString2(v)
                    m_label_ability:setString(value..unit)
                    cclog2(value..unit,"value..unit")
                    m_label_ability:setVisible(true)
                else
                    m_icon_ability:setVisible(false)
                    m_label_ability:setVisible(false)
                end
            end
        else
            -- 未附魔
            self.m_ccbNode:spriteForName("m_attr_node_1"):setPosition(ccp(132,71))
            self.m_ccbNode:spriteForName("m_attr_node_2"):setVisible(false)

        end



        local sort = itemCfg:getNodeWithKey("sort"):toInt();
         -- 1：武器，2：饰品，3：防具，4：鞋子，0：杂物（不可装备）
        self.m_label_name:setString(itemCfg:getNodeWithKey("name"):toStr() .. "(" .. tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]) .. ")");
        self.m_level_label:setString("Lv." ..level);

        local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1);
        if tempDisplayFrame then
            self.m_ability1_icon:setDisplayFrame(tempDisplayFrame);
        end
        local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2);
        if tempDisplayFrame then
            self.m_ability2_icon:setDisplayFrame(tempDisplayFrame);
        end

        local icon = game_util:createEquipIcon(itemCfg)
        if icon then
            local size = self.m_icon_spr:getContentSize();
            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
            self.m_icon_spr:addChild(icon)
        end
        if sort == 0 then
            self.m_ability1_name_label:setString(string_helper.game_equip_info_pop.none);
            self.m_ability2_name_label:setString(string_helper.game_equip_info_pop.none);
            self.m_ability1_label:setString(string_helper.game_equip_info_pop.none);
            self.m_ability2_label:setString(string_helper.game_equip_info_pop.none);
            self.m_level_label:setString(string_helper.game_equip_info_pop.none);
        end
    end
    local suit = itemCfg:getNodeWithKey("suit"):toStr();
    if suit ~= "0" then
        local showFlag = false;
        local suitCount,tempEquipData,_ = game_util:getEquipSuit(suit,self.m_posEquipData, self.m_equipData);
        self.m_suitEquipData = tempEquipData;
        self.m_ccbNode:runAnimations("m_enter_anim_2")
        local suitCfg = getConfig(game_config_field.suit);
        local suitItemCfg = suitCfg:getNodeWithKey(tostring(suit));
        if suitItemCfg then
            local effectItem = nil;
            for i=2,4 do
                effectItem = suitItemCfg:getNodeWithKey("effect_" .. i)
                local tempCount = effectItem:getNodeCount();
                local m_t_label = self.m_ccbNode:labelTTFForName("m_t_label" .. i)
                if i > suitCount then
                    m_t_label:setColor(ccc3(155,155,155));
                end
                local len = (i == 4 and 4 or 2);
                for j=1,len do
                   local m_icon = self.m_ccbNode:spriteForName("m_icon" .. i .. j)
                   local m_attr = self.m_ccbNode:labelTTFForName("m_attr" .. i .. j)
                   if j > tempCount then
                        m_icon:setVisible(false)
                        m_attr:setVisible(false)
                    else
                        local tempItem = effectItem:getNodeAt(j-1);
                        local attType = tempItem:getNodeAt(0):toInt();
                        local attValue = tempItem:getNodeAt(1):toInt();
                        cclog("attType ========== " .. attType .. " ; attValue =========== " .. attValue)
                        local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. attType]
                        if attrTab then
                            local tempDisplayFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(attrTab.icon);
                            if tempDisplayFrame then
                                m_icon:setDisplayFrame(tempDisplayFrame);
                            end
                        end
                        m_attr:setString("+" .. attValue);
                        if i > suitCount then
                            m_icon:setColor(ccc3(155,155,155));
                            m_attr:setColor(ccc3(155,155,155));
                        end
                    end
                end
            end
            local part = suitItemCfg:getNodeWithKey("part")
            local partCount = part:getNodeCount();
            for i=1,4 do
                local m_suit_icon = self.m_ccbNode:spriteForName("m_suit_icon" .. i)
                local size = m_suit_icon:getContentSize();
                if tempEquipData[i] then
                    local tempEquipCfg = tempEquipData[i].itemCfg;
                    if tempEquipCfg then
                        local icon = game_util:createEquipIcon(tempEquipCfg)
                        if icon then
                            icon:setPosition(ccp(size.width*0.5,size.height*0.5));
                            m_suit_icon:addChild(icon)
                            if tempEquipData[i].itemData == nil then
                                icon:setColor(ccc3(71,71,71));
                                --没有的显示灰色
                                local tempBg = tolua.cast(icon:getChildByTag(1),"CCSprite")
                                if tempBg then
                                    tempBg:setColor(ccc3(71,71,71));
                                end
                            else
                                if self.m_tGameData.id == tempEquipData[i].itemData.id then
                                    showFlag = true;
                                    self:equipInfo(i);
                                end
                            end
                        end
                        local nameLabel = game_util:createLabelTTF({text = tempEquipCfg:getNodeWithKey("name"):toStr(),color = ccc3(250,180,0),fontSize = 10});
                        nameLabel:setPosition(ccp(size.width*0.5,-size.height*0.2));
                        m_suit_icon:addChild(nameLabel);
                    end
                end
            end
            self.m_suit_name_label:setString(suitItemCfg:getNodeWithKey("name"):toStr());
        else
            self.m_suit_name_label:setString("");
        end
        if showFlag == false then
            setEquipInfo();
        end
    else
        self.m_ccbNode:runAnimations("m_enter_anim_1")
        setEquipInfo();
    end
end

--[[--
    刷新ui
]]
function game_equip_info_pop.refreshUi(self)
    self:equipDetail();

    -- print("self.m_openType ==  ", self.m_openType, self.m_togetFun)
    self.m_node_getbtn_bg:setVisible(false)
    if self.m_openType == 1 then
        self.m_btn_node:setVisible(false);
        -- self.m_btn_node:setVisible(true);
    elseif self.m_openType == 11 then
        if self.m_togetFun then
            self.m_node_getbtn_bg:setVisible(true)
        end
        self.m_btn_node:setVisible(false);
    elseif self.m_openType == 4 then
        self.m_btn_node:setVisible(false);
        self.m_node_getbtn_bg:setVisible(true)
    else
        self.m_btn_node:setVisible(true);
    end
    if not self.m_togetFun then
        self.m_node_getbtn_bg:setVisible(false)
    end
end

--[[--
    初始化
]]
function game_equip_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = t_params.tGameData;
    self.m_fromUi = t_params.fromUi;
    self.m_openType = t_params.openType or 1;
    self.m_callBack = t_params.callBack;
    self.m_posEquipData = t_params.posEquipData;
    self.m_equipData = t_params.equipData

    print("self.m_tGameData.c_id ", json.encode(self.m_tGameData),  self.m_tGameData.c_id)

    if self.m_openType == 11 then
        self.m_togetFun = self:getGoToGetEquipFun( self.m_tGameData.c_id )
    end

end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_info_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_equip_info_pop;