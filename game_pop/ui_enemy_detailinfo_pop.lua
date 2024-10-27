---  查看仇人详细了信息
local ui_enemy_detailinfo_scene = {
    m_node_roleicon = nil,
    m_label_name = nil,
    m_label_chouhenvalue = nil,
    m_node_format = nil,
};

--[[--
    销毁
]]
function ui_enemy_detailinfo_scene.destroy(self)
    cclog("-----------------ui_enemy_detailinfo_scene destroy-----------------");
    self.m_node_roleicon = nil;
    self.m_label_name = nil;
    self.m_label_chouhenvalue = nil;
    self.m_node_format = nil;
end
--[[--
    返回
]]
function ui_enemy_detailinfo_scene.back(self,type)
    game_scene:removePopByName("ui_enemy_detailinfo_scene")
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function ui_enemy_detailinfo_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "enemy info btnTag ===   is ")
        if btnTag == 1 then
            self:back()
        end
        
    end
    ccbNode:openCCBFile("ccb/ui_enemy_info.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 

    self.m_node_roleicon = ccbNode:nodeForName("m_node_roleicon")
    self.m_label_name = ccbNode:labelTTFForName("m_label_name")
    self.m_label_chouhenvalue = ccbNode:labelTTFForName("m_label_chouhenvalue")
    self.m_node_detailinfo = ccbNode:nodeForName("m_node_detailinfo")
    self.m_node_formatiinfo = ccbNode:nodeForName("m_node_formatiinfo")
    self.m_node_format = ccbNode:nodeForName("m_node_format")
    self.m_btn_zhenxing = ccbNode:controlButtonForName("m_btn_zhenxing")
    self.m_btn_zhuwei = ccbNode:controlButtonForName("m_btn_zhuwei")
    self.m_blabel_viplevel = ccbNode:labelBMFontForName("m_blabel_viplevel")
    self.m_blabel_combat = ccbNode:labelBMFontForName("m_blabel_combat")

    self.m_cardPos = {}
    for i=1, 9 do
        self.m_cardPos["pos" .. i] = ccbNode:nodeForName("m_node_cardpos" .. i)
    end




    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)

    return ccbNode;
end



--[[--
    更新玩家头像
]]
function ui_enemy_detailinfo_scene.updateEnemyBaseInfo( self )
    
    local role = 1  -- 头像
    local name = string_config:getTextByKey("m_topplayer_unnowname")  -- 昵称

    if self.m_params.boss_data and self.m_params.boss_data.user then
        role = self.m_params.boss_data.user.role
    end
    local selfHalf = game_util:createRoleBigImgHalf(role)
    selfHalf:setAnchorPoint(ccp(0.5, 0))
    local scale = self.m_node_roleicon:getContentSize().width / selfHalf:getContentSize().width * 1.5
    selfHalf:setPositionX(self.m_node_roleicon:getContentSize().width  * 0.5)
    selfHalf:setScale(scale)
    self.m_node_roleicon:addChild(selfHalf, 10)
    -- self.m_node_roleicon:getParent():reorderChild(m_node_showh, 11)

     if self.m_params.boss_data and self.m_params.boss_data.user then
        name = self.m_params.boss_data.user.name or name
        if self.m_params.boss_data.user.association_name and self.m_params.boss_data.user.association_name ~= "" then
            guild = self.m_params.boss_data.user.association_name 
        end
    end

    if self.m_label_name then
        self.m_label_name:setString(name)
    end
    if self.m_blabel_combat then
        self.m_blabel_combat:setString(tostring(self.m_params.boss_data.user and self.m_params.boss_data.user.combat or 0))
    end
end


--[[--
    初始化编队信息
]]
function ui_enemy_detailinfo_scene.initTeamFormation( self )

    -- local function onBtnCilck( event,target )
    --     local tagNode = tolua.cast(target, "CCNode");
    --     local btnTag = tagNode:getTag();
    --     cclog2("btnTag  ===  ", btnTag)
    --     local index = btnTag - 20000
    --     self:initRightContentInfo( index )
    --     self:selIcon(index)
    -- end

    local character_detail_cfg = getConfig("character_detail");
    local flag = false
    for i=1,9 do
        -- local animNode,character_ID = self:createCardAnimByPosIndex(i)
        local cardData,cardCfg = nil, nil
        if self.m_selLeftIndex == 1 then
           cardData,cardCfg = self:getTeamCardDataByPos(i);
        elseif self.m_selLeftIndex == 2 then
           cardData,cardCfg = self:getFriendCardDataByPos(i);
        end

        local tempCardPosNode = self.m_cardPos["pos" ..  i]
        if tempCardPosNode then
            tempCardPosNode:removeAllChildrenWithCleanup(true)
            local animNode,character_ID = self:createCardAnimByData( cardData, cardCfg)
            cclog("animNode ================ " .. tostring(animNode))
            if animNode then
                -- animNode:setPosition(ccp(headIconBgSize.width*0.5,headIconBgSize.height*0.1));
                tempCardPosNode:addChild(animNode,1,1);
            end
        end

        -- local k = i + (self.m_selLeftIndex - 1) * 10
        -- self.m_boss_icons[i]:removeAllChildrenWithCleanup(true)
        -- self.m_boss_icons[k]:removeAllChildrenWithCleanup(true)
        -- if cardData and  cardCfg then
        --     if cardCfg then
        --         icon = game_util:createCardIconByCfg(cardCfg);

        --         if self.m_boss_icons[k] and icon then
        --             icon:setPosition(self.m_boss_icons[k]:getContentSize().width * 0.5, self.m_boss_icons[k]:getContentSize().width * 0.5)
        --             self.m_boss_icons[k]:addChild(icon, 10)

        --             local name = game_util:getCardName( cardData, cardCfg)
        --             cclog2(name, "name ===  ")
        --             if name and name ~= "" then
        --                 local label = game_util:createLabelTTF({text = name, fontSize = 10})   
        --                 label:setPosition(self.m_boss_icons[k]:getContentSize().width * 0.5, - 2)
        --                 self.m_boss_icons[k]:addChild(label, 11)
        --             end

        --             local  tempSize = self.m_boss_icons[k]:getContentSize()
        --             local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
        --             button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
        --             button:setAnchorPoint(ccp(0.5,0.5))
        --             button:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
        --             button:setOpacity(0)
        --             self.m_boss_icons[k]:addChild(button)
        --             button:setTag(20000 + i)
        --             if not flag then
        --                 self:initRightContentInfo( i )
        --                 self:selIcon(i)
        --                 flag = true
        --             end
        --         end

        --     end
    end 
end



--[[
    获取小伙伴位置上的动画
]]
function ui_enemy_detailinfo_scene.createCardAnimByData( self, heroData,heroCfg)
    local animNode = nil;
    local character_ID = -1;
    if heroData and heroCfg then
        character_ID = heroCfg:getNodeWithKey("character_ID"):toInt();
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
            -- animNode:setScale(0.7);
            -- local name_after = heroData.step < 1 and "" or ("+" .. heroData.step);
            -- local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max .. "\n" .. name_after,TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
            -- tempLabel:setPosition(ccp(itemSize.width*0.5 - 50,97));
            -- tempLabel:setAnchorPoint(ccp(0,0.5));
            -- animNode:addChild(tempLabel,100,100)
            -- -- local tempLabel = CCLabelTTF:create(heroCfg:getNodeWithKey("name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
            -- -- tempLabel:setPosition(ccp(itemSize.width*0.5 + 50,95));
            -- -- tempLabel:setAnchorPoint(ccp(1,0.5));
            -- -- animNode:addChild(tempLabel,100,100)
            -- -- game_util:setHeroNameColorByQuality(tempLabel,heroCfg);
            -- local occupation_cfg = getConfig(game_config_field.occupation);
            -- local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            -- if occupation_item_cfg then
            --     local occupationType = occupation_item_cfg:toInt();
            --     local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
            --     if spriteFrame then
            --         local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
            --         occupation_icon:setPosition(ccp(itemSize.width*0.5 + 57,98));
            --         occupation_icon:setAnchorPoint(ccp(1,0.5));
            --         animNode:addChild(occupation_icon);
            --     end
            -- end
            animNode:setScale(0.6);
        end
    end
    return animNode,character_ID
end

--[[
    属性信息
]]
function ui_enemy_detailinfo_scene.createAttributeInfo( self, cardData, cardCfg )
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_enemy_info_attribute.ccbi");

    local m_life_label = ccbNode:labelBMFontForName("m_life_label")
    local m_physical_atk_label = ccbNode:labelBMFontForName("m_physical_atk_label")
    local m_magic_atk_label = ccbNode:labelBMFontForName("m_magic_atk_label")
    local m_def_label = ccbNode:labelBMFontForName("m_def_label")
    local m_speed_label = ccbNode:labelBMFontForName("m_speed_label")

    local m_life_label2 = ccbNode:labelBMFontForName("m_life_label")
    local m_physical_atk_label2 = ccbNode:labelBMFontForName("m_physical_atk_label")
    local m_magic_atk_label2 = ccbNode:labelBMFontForName("m_magic_atk_label")
    local m_def_label2 = ccbNode:labelBMFontForName("m_def_label")
    local m_speed_label2 = ccbNode:labelBMFontForName("m_speed_label")

    if cardData and cardCfg then
        m_life_label:setString(cardData.hp or "---" );
        m_physical_atk_label:setString(cardData.patk or "---");
        m_magic_atk_label:setString(cardData.matk or "---");
        m_def_label:setString(cardData.def or "---");
        m_speed_label:setString(cardData.speed or "---");



        m_life_label2:setString("+" .. 99999)
        m_physical_atk_label2:setString("+" .. 99999)
        m_magic_atk_label2:setString("+" .. 99999)
        m_def_label2:setString("+" .. 99)
        m_speed_label2:setString("+" .. 0)

        -- local patk,matk,def,speed,hp = self:getPosEquipAttrValue(posIndex);
        -- local attrValueTab2 = game_util:getCommanderCombatValue();
        -- local cbmTab = game_util:getCombatBonusMultiplierByCfg(cardCfg,cardData.id);

        -- m_life_label2:setString("+" .. (hp+ attrValueTab2[5] + math.floor(cardData.hp*cbmTab[5]) ))
        -- m_physical_atk_label2:setString("+" .. (patk + attrValueTab2[1] + math.floor(cardData.patk*cbmTab[1]) ))
        -- m_magic_atk_label2:setString("+" .. (matk+attrValueTab2[2] + math.floor(cardData.matk*cbmTab[2] )))
        -- m_def_label2:setString("+" .. (def+attrValueTab2[3] + math.floor(cardData.def*cbmTab[3] )))
        -- m_speed_label2:setString("+" .. (speed+attrValueTab2[4] + math.floor(cardData.speed*cbmTab[4] )))

    else
        m_life_label:setString( "---" );
        m_physical_atk_label:setString( "---");
        m_magic_atk_label:setString( "---");
        m_def_label:setString("---");
        m_speed_label:setString( "---");
    end
    return ccbNode
end


--[[--
    刷新卡牌信息
]]
function ui_enemy_detailinfo_scene.getPosEquipAttrValue(self,posIndex)
    -- 1物攻 2魔攻 3防御 4速度 5生命
    local attrValueTab = {0,0,0,0,0};
    local posEquips = self.m_tempEquipPosData[posIndex]
    -- cclog("posIndex ==== " .. posIndex .. " ;type(posEquips) == " .. type(posEquips))
    local level,value1,value2;
    local suitTab = {};
    if posEquips and type(posEquips) == "table" then
        for k,v in pairs(posEquips) do
            local equipItemData,itemCfg = game_data:getEquipDataById(v);
            if equipItemData and itemCfg then
                level = equipItemData.lv;
                value1 = itemCfg:getNodeWithKey("value1"):toInt();
                value2 = itemCfg:getNodeWithKey("value2"):toInt();
                local level_add1,level_add2 = itemCfg:getNodeWithKey("level_add1"):toInt(),itemCfg:getNodeWithKey("level_add2"):toInt()
                for i=2,level do
                    value1 = value1 + level_add1;
                    value2 = value2 + level_add2;
                end
                -- cclog("value1 == " .. value1 .. " ; value2 == " .. value2)
                local ability1 = itemCfg:getNodeWithKey("ability1"):toInt();
                local ability2 = itemCfg:getNodeWithKey("ability2"):toInt();
                if attrValueTab[ability1] then
                    attrValueTab[ability1] = attrValueTab[ability1] + value1;
                end
                if attrValueTab[ability2] then
                    attrValueTab[ability2] = attrValueTab[ability2] + value2;
                end
                local suit = itemCfg:getNodeWithKey("suit"):toInt();
                if suitTab[suit] == nil then
                    suitTab[suit] = 0;
                    local suitCount,_,tempAttrValueTab = game_util:getEquipSuit(itemCfg:getNodeWithKey("suit"):toStr(),posEquips);
                    if suitCount > 0 then
                        for i=1,5 do
                            attrValueTab[i] = attrValueTab[i] + tempAttrValueTab[i]
                        end
                    end
                end
            end
        end
    end
    return attrValueTab[1],attrValueTab[2],attrValueTab[3],attrValueTab[4],attrValueTab[5];
end


--[[
    创建装备信息
]]
function ui_enemy_detailinfo_scene.createEquipInfo( self, cardData, cardCfg )
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_enemy_info_equip.ccbi");
    local tempNode = nil
    if cardData then
        local equipPosData = self.m_tempEquipPosData[index]
        if equipPosData then
            if equipPosData then
                local noUseEquipCountTab = self.m_player_data:getNoUseEquipCountTab();
                for i=1,4 do
                    tempNode = ccbNode:nodeForName("m_node_roleicon" .. i)
                    if tempNode then
                        tempNode:removeAllChildrenWithCleanup(true);
                        local tempNodeSize = tempNode:getContentSize();
                        local id = equipPosData[i];
                        if id and id ~= "0" then
                            local equipItemData,equipItemCfg = self.m_player_data:getEquipDataById(tostring(id));
                            local equipIcon = game_util:createEquipIcon(equipItemCfg);
                            if equipIcon then
                                equipIcon:setPosition(ccp(tempNodeSize.width*0.5,tempNodeSize.height*0.5))
                                tempNode:addChild(equipIcon,10,10)
                                self:createTouchButton(onBtnCilck, tempNode, 60000 + i + roleIndex_use * 100)

                                local sl =  equipItemData.st_lv or 0
                                if sl > 0 then
                                    -- 星星标志
                                    local star = CCSprite:createWithSpriteFrameName("public_equip_star.png");
                                    star:setPositionY(tempNode:getContentSize().height)
                                    tempNode:addChild(star, 20)
                                    local labelG = game_util:createLabelTTF({text = tostring(sl), fontSize = 12, color = ccc3(255, 255, 0)})
                                    labelG:setAnchorPoint(ccp(0,0.5))
                                    labelG:setPosition(ccp(star:getContentSize().width * 1.2, star:getContentSize().height * 0.5))
                                    star:addChild(labelG)
                                end

                                local  lv = equipItemData.lv or 1
                                local labelL = game_util:createLabelTTF({text = "+" .. lv, fontSize = 12, color = ccc3(0, 255, 0)})
                                labelL:setAnchorPoint(ccp(0.5, 1))
                                labelL:setPosition(ccp(equipIcon:getContentSize().width * 0.5, -2))
                                equipIcon:addChild(labelL)
                            end
                        end
                    end
                end
            end
        end
    end
    return ccbNode
end

--[[
    初始化卡片详情
]]
function ui_enemy_detailinfo_scene.initRightContentInfo( self, index )

    local cardData,cardCfg = nil, nil
    if self.m_selLeftIndex == 1 then
       cardData,cardCfg = self:getTeamCardDataByPos(index);
    elseif self.m_selLeftIndex == 2 then
       cardData,cardCfg = self:getFriendCardDataByPos(index);
    end

    self.m_node_detailinfo:removeAllChildrenWithCleanup(true)
    local viewSize = self.m_node_detailinfo:getContentSize()
    local scrollView = CCScrollView:create(viewSize)
    scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setContentSize(viewSize)
    self.m_node_detailinfo:addChild(scrollView)
    local y = 0
    local height = 10
    local attributeNode = self:createAttributeInfo(cardData,cardCfg)
    attributeNode:setAnchorPoint(ccp(0.5, 1))
    height = height + attributeNode:getContentSize().height + 2

    local equipNode = self:createEquipInfo(index)
    equipNode:setAnchorPoint(ccp(0.5, 1))
    height = height + equipNode:getContentSize().height + 2

    local tempNode = CCNode:create()
    tempNode:setContentSize(CCSizeMake(viewSize.width, height))
    y = height - 5
    attributeNode:setPosition(ccp(viewSize.width * 0.5, y))
    tempNode:addChild(attributeNode)
    y = y - 2 - attributeNode:getContentSize().height

    equipNode:setPosition(ccp(viewSize.width * 0.5, y))
    tempNode:addChild(equipNode)
    y = y - 2 - equipNode:getContentSize().height

    scrollView:getContainer():addChild( tempNode )
    -- local itemSize = CCSizeMake(sNode:getContentSize().width , sNode:getContentSize().height)
    scrollView:setContentSize(tempNode:getContentSize())
    local offsetY = tempNode:getContentSize().height - viewSize.height
    scrollView:setContentOffset(ccp(0, -offsetY), false)
end


--[[--
    
]]
function ui_enemy_detailinfo_scene.getTeamCardDataByPos(self,posIndex)
    return  self.m_player_data:getCardDataById(self.m_tempTeamData[posIndex])
end

--[[--
    获得卡牌配置以及数据
]]
function ui_enemy_detailinfo_scene:getFriendCardDataByPos( posIndex )
    -- body
    return self.m_player_data:getCardDataById(self.m_tempFriendData[posIndex])
end

--[[--
    阵型显示
]]
function ui_enemy_detailinfo_scene.updateFromation( self )

    local formationPosTab = {{key="position_a",x=0.82,y=0.83},{key="position_b",x=0.82,y=0.5},
      {key="position_c",x=0.82,y=0.17},{key="position_d",x=0.5,y=0.83},{key="position_e",x=0.5,y=0.5},{key="position_f",x=0.5,y=0.17}};
    self.m_posIndex = -1;
    self.m_tempSelIndex = -1;
    self.m_tempTeamData = {};
    self.m_tempFriendData = {};
    self.m_tempEquipPosData = {};
    self.m_tempGemPosData = {};

    local formationData = self.m_player_data:getFormationData();
    local ownFormation = formationData.own
    local ownFormationCount = #ownFormation
    self.m_currentFormationId = formationData.current
    self.m_selFormationId = self.m_currentFormationId;

    local teamData = self.m_player_data:getTeamData();
    local friendData = self.m_player_data:getAssistant();
    local tempEquipPosData = self.m_player_data:getEquipPosData()
    local tempGemPosData = self.m_player_data:getGemPosData();
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_selFormationId));
    local tempTag = 1;
    local iValue = nil;
    if itemCfg ~= nil then
        for i=1,#formationPosTab do
            local formationPosTabItem = formationPosTab[i];
            iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
            if iValue ~= 0 and tempTag < 7 then
                self.m_tempTeamData[i] = teamData[tempTag]
                self.m_tempEquipPosData[i] = util.table_copy(tempEquipPosData[tostring(tempTag-1)]);
                self.m_tempGemPosData[i] = util.table_copy(tempGemPosData[tostring(tempTag-1)]); 
                tempTag = tempTag + 1;
            else
                self.m_tempTeamData[i] = "-1";
                self.m_tempEquipPosData[i] = {"0","0","0","0"}
                self.m_tempGemPosData[i] = {"0","0","0","0"}
            end
        end
    end
    for i=6,8 do
        self.m_tempTeamData[i+1] = teamData[i];
        self.m_tempEquipPosData[i+1] = util.table_copy(tempEquipPosData[tostring(i-1)]);
        self.m_tempGemPosData[i+1] = util.table_copy(tempGemPosData[tostring(i-1)]);
    end
    self.m_tempFriendData = friendData;
    local cardNumData = self.m_player_data:getBattleCardNumData()
    local maxCount1,maxCount2 = cardNumData.position_num or 2,cardNumData.alternate_num or 0;
    self.m_openTab = TEAM_POS_OPEN_TAB["open" .. maxCount1 .. maxCount2] or {};
end




--[[--
    刷新ui
]]
function ui_enemy_detailinfo_scene.refreshUi(self)
    
    self:updateFromation()
    self:updateEnemyBaseInfo()
    self:initTeamFormation()
    self:initRightContentInfo(1)
end

--[[--
    初始化
]]
function ui_enemy_detailinfo_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_player_data = require("game_player_data")
    self.m_player_data:init()

    -- cclog2(t_params, "t_params === ")
    local gameData = t_params.gameData
    local data = gameData:getNodeWithKey("data")
    self.m_params = {}
    if data and data:getNodeWithKey("new_data") then
        self.m_params.boss_data = json.decode(data:getNodeWithKey("new_data"):getFormatBuffer()) or {}
    end
    local userdata = data:getNodeWithKey("new_data")
    self.m_player_data:updateCardsOpenByJsonData(userdata  or nil)
    self.m_selLeftIndex = 1
    self.m_selRightIndex = 3
    if self.m_params.boss_data and self.m_params.boss_data.user then
        self.m_uid = self.m_params.boss_data.user.uid
        self.m_name = self.m_params.boss_data.user.name
    end
end

--[[--
    创建ui入口并初始化数据
]]
function ui_enemy_detailinfo_scene.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_enemy_detailinfo_scene;