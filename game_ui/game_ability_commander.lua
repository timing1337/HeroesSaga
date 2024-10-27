---  ui 统帅能力

local game_ability_commander = {
    m_touch_layer = nil,
    m_material_node = nil,
    m_material_node_tab = nil,
    m_have_label = nil,
    m_progress_bar_bg = nil,
    m_countdown_node = nil,
    m_countdown_label = nil,
    m_vigor_total_label = nil,
    m_list_view_bg = nil,
    m_selListItem = nil,
    m_selSortIndex = nil,
    m_progress_bar = nil,
    m_ccbNode = nil,
    m_selPosIndex = nil,
    m_tGameData = nil,
    m_root_layer = nil,
    m_tGameDataBackup = nil,
    m_animCount = nil,
    m_ok_btn = nil,
    m_level_label = nil,
    m_protect_expire = nil,
    m_itemCount = nil,
    buy_cmdr_times = nil,
    m_sel_img = nil,
    m_next_stroy_label = nil,
    m_have_node = nil,
    m_protect_node = nil,
    m_protection_btn = nil,
    m_show_icon_node = nil,
    m_log_btn = nil,
    m_rob_log = nil,
    m_showSortIdTab = nil,
    m_selSortId = nil,
    cmdr_energy_rate = nil,
    left_time = nil,
    cmdr_energy_update_left = nil,
    m_animFlag = nil,
    m_guildNode = nil,
};
--[[--
    销毁ui
]]
function game_ability_commander.destroy(self)
    -- body
    cclog("-----------------game_ability_commander destroy-----------------");
    self.m_touch_layer = nil;
    self.m_material_node = nil;
    self.m_material_node_tab = nil;
    self.m_have_label = nil;
    self.m_progress_bar_bg = nil;
    self.m_countdown_node = nil;
    self.m_countdown_label = nil;
    self.m_vigor_total_label = nil;
    self.m_list_view_bg = nil;
    self.m_selListItem = nil;
    self.m_selSortIndex = nil;
    self.m_progress_bar = nil;
    self.m_ccbNode = nil;
    self.m_selPosIndex = nil;
    self.m_tGameData = nil;
    self.m_root_layer = nil;
    self.m_tGameDataBackup = nil;
    self.m_animCount = nil;
    self.m_ok_btn = nil;
    self.m_level_label = nil;
    self.m_protect_expire = nil;
    self.m_itemCount = nil;
    self.buy_cmdr_times = nil;
    self.m_sel_img = nil;
    self.m_next_stroy_label = nil;
    self.m_have_node = nil;
    self.m_protect_node = nil;
    self.m_protection_btn = nil;
    self.m_show_icon_node = nil;
    self.m_log_btn = nil;
    self.m_rob_log = nil;
    self.m_showSortIdTab = nil;
    self.m_selSortId = nil;
    self.cmdr_energy_rate = nil;
    self.left_time = nil;
    self.cmdr_energy_update_left = nil;
    self.m_animFlag = nil;
    self.m_guildNode = nil;
end

local ability_commander_tab = {sort_5 = {iconName = "tsnl_shengming.png",typeName = "hp",typeName2 = "add_hp",sort = 5,sort2 = 3,attrName = string_helper.game_ability_commander.hp,stroyImgName = "tsnl_wenzi_hp.png",icon = "public_icon_hp.png"},
                                sort_1 = {iconName = "tsnl_wugong.png",typeName = "patk",typeName2 = "add_patk",sort = 1,sort2 = 4,attrName = string_helper.game_ability_commander.patk,stroyImgName = "tsnl_wenzi_wugong.png",icon = "public_icon_phsc.png"},
                                sort_2 = {iconName = "tsnl_mogong.png",typeName = "matk",typeName2 = "add_matk",sort = 2,sort2 = 5,attrName = string_helper.game_ability_commander.matk,stroyImgName = "tsnl_wenzi_mofa.png",icon = "public_icon_mgc.png"},
                                sort_3 = {iconName = "tsnl_fangyu.png",typeName = "def",typeName2 = "add_def",sort = 3,sort2 = 6,attrName = string_helper.game_ability_commander.add_def,stroyImgName = "tsnl_wenzi_fangyu.png",icon = "public_icon_dfs.png"},
                                sort_4 = {iconName = "tsnl_sudu.png",typeName = "speed",typeName2 = "add_speed",sort = 4,sort2 = 7,attrName = string_helper.game_ability_commander.speed,stroyImgName = "tsnl_wenzi_sudu.png",icon = "public_icon_speed.png"},
                                sort_6 = {iconName = "tsnl_hp_up2.png",typeName = "hp2",typeName2 = "add_hp2",sort = 6,sort2 = 2,attrName = string_helper.game_ability_commander.hp,stroyImgName = "tsnl_wenzi_hp2.png",icon = "public_icon_hp.png"},
                                sort_7 = {iconName = "tsnl_hp_up3.png",typeName = "hp3",typeName2 = "add_hp3",sort = 7,sort2 = 1,attrName = string_helper.game_ability_commander.hp,stroyImgName = "tsnl_wenzi_hp3.png",icon = "public_icon_hp.png"},
                                sort_8 = {iconName = "tsnl_fire.png",typeName = "firedfs",typeName2 = "add_firedfs",sort = 8,sort2 = 8,attrName = string_helper.game_ability_commander.fire,stroyImgName = "tsnl_wenzi_huofangyu.png",icon = "public_icon_hf.png"},
                                sort_9 = {iconName = "tsnl_water.png",typeName = "waterdfs",typeName2 = "add_waterdfs",sort = 9,sort2 = 9,attrName = string_helper.game_ability_commander.water,stroyImgName = "tsnl_wenzi_shuifangyu.png",icon = "public_icon_bf.png"},
                                sort_10 = {iconName = "tsnl_wind.png",typeName = "winddfs",typeName2 = "add_winddfs",sort = 10,sort2 = 10,attrName = string_helper.game_ability_commander.winder,stroyImgName = "tsnl_wenzi_fengfangyu.png",icon = "public_icon_ff.png"},
                                sort_11 = {iconName = "tsnl_earth.png",typeName = "earthdfs",typeName2 = "add_earthdfs",sort = 11,sort2 = 11,attrName = string_helper.game_ability_commander.earth,stroyImgName = "tsnl_wenzi_difangyu.png",icon = "public_icon_df.png"},
                            }

local ability_commander_pos_tab = {
                                    count1 = {{0,0}},
                                    count2 = {{0,0},{0,0}},
                                    count3 = {{50.0,90.0},{15.0,25.0},{85.0,25.0}},
                                    count4 = {{15.0,75.0},{15.0,25.0},{85.0,25.0},{85.0,75.0}},
                                    count5 = {{50.0,90.0},{10.0,60.0},{25.0,15.0},{75.0,15.0},{85.0,60.0}},
                                    }

--[[--
    返回
]]
function game_ability_commander.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_ability_commander.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--合成
            game_scene:removeGuidePop();
            local itemData = self.m_tGameData[self.m_selSortId] or {}
            local tempItemData = itemData[self.m_selSortIndex];
            if tempItemData == nil then return end;
            local recipeId = tempItemData.key;
            local function responseMethod(tag,gameData)
                if gameData == nil then
                    self.m_root_layer:setTouchEnabled(false);
                    return;
                end
                local data = gameData:getNodeWithKey("data")
                game_data:setCommanderAttrsByJsonData(data:getNodeWithKey("commander_attrs"))
                self:responseSuccess();
                game_util:addMoveTips({text = string_helper.game_ability_commander.text});
            end
            self.m_root_layer:setTouchEnabled(true);
            local commander_attrs = game_data:getCommanderAttrsData();
            self.m_tGameDataBackup = util.table_copy(commander_attrs)
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_synthesis"), http_request_method.GET, {recipe=recipeId},"commander_synthesis",true,true)
        elseif btnTag == 102 then--保护
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_protect_expire = data:getNodeWithKey("protect_expire"):toInt();
                self:refreshInfo();
                game_util:addMoveTips({text = string_helper.game_ability_commander.text2});
            end
            if self.m_protect_expire > 0 then
                game_util:addMoveTips({text = string_helper.game_ability_commander.text3});
            else
                if self.m_itemCount > 0 then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_protect"), http_request_method.GET, nil,"commander_protect")
                else
                    local function responseMethod2(tag,gameData)
                        game_util:closeAlertView();
                        local data = gameData:getNodeWithKey("data")
                        self.m_protect_expire = data:getNodeWithKey("protect_expire"):toInt();
                        self:refreshInfo();
                        game_util:addMoveTips({text = string_helper.game_ability_commander.text2});
                        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_protect"), http_request_method.GET, nil,"commander_protect")
                    end
                    local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("13"):getNodeWithKey("coin")
                    local payValue = PayCfg:getNodeAt(0):toInt()
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("buy_commbander_protect"), http_request_method.GET, nil,"buy_commbander_protect")
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string_helper.game_ability_commander.text4 .. payValue .. string_helper.game_ability_commander.text5,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                    }
                    game_util:openAlertView(t_params)
                end
            end
        elseif btnTag == 103 then--战报
            game_scene:addPop("ui_batter_info_pop",{log_info = self.m_rob_log,openType = 2});
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            self.m_animFlag = true;
            self:refreshSortTabBtn(btnTag - 200);
        elseif btnTag == 50 then--加精力
            local cmdr_energy = game_data:getUserStatusDataByKey("cmdr_energy") or 0
            if cmdr_energy >= 30 then
                game_util:addMoveTips({text = string_helper.game_ability_commander.text6})
            else
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    self:refreshUi()
                    game_util:addMoveTips({text = string_helper.game_ability_commander.text7})
                    game_util:closeAlertView()
                end
                local buyTimes = self.buy_cmdr_times
                local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("12"):getNodeWithKey("coin")
                local payValue = 0
                if buyTimes >= PayCfg:getNodeCount() then
                    payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
                else
                    payValue = PayCfg:getNodeAt(buyTimes):toInt()
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_cmdr_energy"), http_request_method.GET, nil,"buy_cmdr_energy")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = string_helper.game_ability_commander.text4 .. payValue .. string_helper.game_ability_commander.text8,      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                }
                game_util:openAlertView(t_params)
            end 
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_ability_commander.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")

    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_have_label = ccbNode:labelTTFForName("m_have_label") 
    self.m_progress_bar_bg = ccbNode:nodeForName("m_progress_bar_bg")
    self.m_countdown_node = ccbNode:nodeForName("m_countdown_node")
    self.m_vigor_total_label = ccbNode:labelBMFontForName("m_vigor_total_label")
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")
    self.m_next_stroy_label = ccbNode:labelTTFForName("m_next_stroy_label") 
    self.m_have_node = ccbNode:nodeForName("m_have_node")
    self.m_protect_node = ccbNode:nodeForName("m_protect_node")
    self.m_protection_btn = ccbNode:controlButtonForName("m_protection_btn")
    self.m_log_btn = ccbNode:controlButtonForName("m_log_btn")
    self.m_show_icon_node = ccbNode:nodeForName("m_show_icon_node")
    self.left_time = ccbNode:nodeForName("left_time")
    -- self.m_log_btn:setVisible(false);

    local m_commander_icon = ccbNode:spriteForName("m_commander_icon")
    local tempIcon =game_util:createItemIconByCid("30")
    if tempIcon then
        m_commander_icon:setDisplayFrame(tempIcon:displayFrame())
        m_commander_icon:setScale(0.3);
    end
    local function timeOverCallFun(label,type)
        self.m_have_node:setVisible(true);
        self.m_protect_node:setVisible(false);
    end
    self.m_countdown_label = game_util:createCountdownLabel(0,timeOverCallFun,8,1)
    self.m_countdown_node:addChild(self.m_countdown_label,10,10)

    local barSize = self.m_progress_bar_bg:getContentSize();
    local bar = ExtProgressBar:createWithFrameName("tsnl_progress_1.png","tsnl_progress_2.png",barSize);
    bar:setCurValue(10,false);
    self.m_progress_bar_bg:addChild(bar);
    self.m_progress_bar = bar;

    local m_material_node,m_mate_tips,m_num_label,parentNode = nil,nil,nil
    for i=1,5 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_num_label = ccbNode:labelBMFontForName("m_num_label_" .. i);
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_num_label = m_num_label,itemId = -1,count = 0,parentNode = parentNode}
    end

    self:initLayerTouch(self.m_touch_layer);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_ccbNode = ccbNode

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text23)

    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text24)

    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text25)

    game_util:setCCControlButtonTitle(self.m_protection_btn,string_helper.ccb.text26)
    game_util:setCCControlButtonTitle(self.m_log_btn,string_helper.ccb.text27)
    return ccbNode;
end

--[[--
    
]]
function game_ability_commander.responseSuccess(self)
    self.m_animFlag = false;
    game_sound:playUiSound("up_success")
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        self:refreshData();
        self:refreshUi();
        local id = game_guide_controller:getIdByTeam("18");
        if id == 1804 then
            self:gameGuide("drama","18",1806)
        end
    end
    local function expBarAnim()
        local tempAnim = game_util:createUniversalAnim({animFile = "anim_ui_jindutiao",rhythm = 1.0,loopFlag = false,animCallFunc = nil});
        local tempSize = self.m_progress_bar_bg:getContentSize();
        tempAnim:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_progress_bar_bg:addChild(tempAnim,10,10)
        local commander_type_cfg = getConfig(game_config_field.commander_type);
        local tempItem = ability_commander_tab["sort_" .. self.m_selSortId]
        if tempItem == nil then 
            responseEndFunc();
            return
        end
        local itemDataBackup = self.m_tGameDataBackup[tempItem.typeName]
        local commander_attrs = game_data:getCommanderAttrsData();
        local itemData = commander_attrs[tempItem.typeName]
        local lv1,lv2,addLv = 0,0,0
        local function timeOverCallFun(extBar)
            if lv2 > (lv1 + addLv) then
                self.m_progress_bar:setCurValue(0,false);
                self.m_progress_bar:setCurValue(100,true);
                -- cclog("lv1 + addLv =======1======== " .. (lv1 + addLv) .. " ;lv2 == " .. lv2)
                self.m_level_label:setString("Lv." .. (lv1 + addLv));
                addLv = addLv + 1;
            elseif lv2 == (lv1 + addLv) then
                -- cclog("lv1 + addLv =======2======== " .. (lv1 + addLv) .. " ;lv2 == " .. lv2)
                local itemCfg1 = commander_type_cfg:getNodeWithKey(tostring(lv1 + addLv - 1))
                local itemCfg2 = commander_type_cfg:getNodeWithKey(tostring(lv1 + addLv))
                self.m_level_label:setString("Lv." .. (lv1 + addLv));
                local needExp = itemCfg2:getNodeWithKey("exp"):toInt()
                needExp = needExp == 0 and 100 or needExp
                addLv = addLv + 1;
                if itemCfg1 and itemCfg2 then
                    local attrValue1 = itemCfg1:getNodeWithKey(tempItem.typeName2):toInt();
                    local attrValue2 = itemCfg2:getNodeWithKey(tempItem.typeName2):toInt();
                    game_util:addMoveTips({text = string.format(string_helper.game_ability_commander.text9,tempItem.attrName,attrValue2 - attrValue1)});
                end              
                self.m_progress_bar:setCurValue(0,false);
                self.m_progress_bar:setCurValue(100*itemData.exp/needExp,true);
            else
                -- cclog("lv1 + addLv =======end======== " .. (lv1 + addLv) .. " ;lv2 == " .. lv2)
                self.m_progress_bar:unregisterScriptBarHandler()
                responseEndFunc();
            end
        end
        self.m_progress_bar:registerScriptBarHandler(timeOverCallFun);

        if itemData and itemDataBackup then
            lv1 = itemDataBackup.lv;
            lv2 = itemData.lv;
            -- cclog("lv1 ============ " .. lv1 .. " ; lv2 =========== " .. lv2 .. " ; tempItem.typeName == " .. tempItem.typeName .. " ; exp = " .. itemData.exp)
            local itemCfg1 = commander_type_cfg:getNodeWithKey(tostring(lv1))
            local itemCfg2 = commander_type_cfg:getNodeWithKey(tostring(lv2))
            if itemCfg1 and itemCfg2 then
                local needExp = itemCfg2:getNodeWithKey("exp"):toInt()
                needExp = needExp == 0 and 100 or needExp
                addLv = addLv + 1;
                if lv2 > lv1 then
                    self.m_progress_bar:setCurValue(100,true);
                else
                    self.m_progress_bar:setCurValue(100*itemData.exp/needExp,true);
                end
            else
                responseEndFunc();
            end
        else
            responseEndFunc();
        end 
    end

    local removeIndex = math.min(self.m_animCount,5)
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        -- cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,math.min(self.m_animCount,5) do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
        if mAnimNode then
            local function onAnimSectionEnd(animNode, theId,theLabelName)
                if theLabelName == "impact1" then
                    animNode:playSection("impact2");
                    local tempNode = m_material_node:getChildByTag(10)
                    if tempNode then
                        tempNode:setVisible(false);
                    end
                else
                    mAnimNode:removeFromParentAndCleanup(true);
                    removeIndex = removeIndex - 1;
                    if removeIndex == 0 then
                        expBarAnim();
                    end
                end
            end
            mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
            mAnimNode:playSection("impact1");
            local tempSize = m_material_node:getContentSize();
            mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
            m_material_node:addChild(mAnimNode,100,100);
            local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up2"});
            if tempParticle then
                game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_material_node,endNode = self.m_ok_btn,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                game_scene:getPopContainer():addChild(tempParticle)
            end
        else
            removeIndex = removeIndex - 1;
            if removeIndex == 0 then
                expBarAnim();
            end
        end
    end
end

--[[--

]]
function game_ability_commander.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    self.m_selSortIndex = sortIndex
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        if tempBtn:isVisible() then
            tempBtn:setHighlighted(self.m_selSortIndex == i);
            tempBtn:setEnabled(self.m_selSortIndex ~= i);
            if self.m_selSortIndex == i then
                local pX,pY = tempBtn:getPosition();
                self.m_sel_img:setPosition(ccp(pX, pY))
            end
        end
    end
    self:refreshCommanderDetail(sortIndex);
end

--[[--

]]
function game_ability_commander.showSortTabBtn(self,sortIndex)
    local itemData = self.m_tGameData[self.m_selSortId]
    if itemData == nil then return end;
    local tempCount = #itemData;
    self.m_show_icon_node:removeAllChildrenWithCleanup(true);
    -- cclog("show btn count =========== " .. tempCount)
    local commander_recipe_cfg = getConfig(game_config_field.commander_recipe);
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        if i > tempCount then
            tempBtn:setVisible(false)
        else
            tempBtn:setVisible(true)
            game_util:setCCControlButtonTitle(tempBtn,tostring(itemData[i].name))
            local itemCfg = commander_recipe_cfg:getNodeWithKey(tostring(itemData[i].key))
            local icon = itemCfg:getNodeWithKey("icon")
            local pX,pY = tempBtn:getPosition();
            if icon then
                local tempIcon = game_util:createIconByName(icon:toStr())
                if tempIcon then
                    tempIcon:setScale(0.8);
                    tempIcon:setPosition(ccp(pX, pY))
                    self.m_show_icon_node:addChild(tempIcon)
                end
            end
            local quality = itemCfg:getNodeWithKey("quality")
            if quality then
                quality = quality:toInt();
                local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
                if qualityTab then
                    local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
                    img2:setScale(0.8);
                    img2:setPosition(ccp(pX, pY));
                    self.m_show_icon_node:addChild(img2,2,2)
                end
            end
        end
    end
end

--[[--
    
]]
function game_ability_commander.initLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        for k,v in pairs(self.m_material_node_tab) do
            realPos = v.parentNode:convertToNodeSpace(ccp(x,y));
            if v.m_material_node:isVisible() and v.m_material_node:boundingBox():containsPoint(realPos) then
                tag = v.m_material_node:getTag();
                cclog("v.itemId =============== " .. v.itemId)
                if v.itemId ~= -1 then
                    if v.level < v.able_level then
                        game_util:addMoveTips({text = string.format(string_helper.game_ability_commander.text10,v.able_level)});
                        return;
                    end
                    if v.count > 0 then
                        game_scene:addPop("game_item_info_pop",{itemId = v.itemId,openType = 2})
                    else
                        local function responseMethod(tag,gameData)
                            local tempItem = ability_commander_tab["sort_" .. self.m_selSortId]
                            if tempItem == nil then return end
                            game_data:setCommanderRecipeData("sort",self.m_selSortId);
                            game_data:setCommanderRecipeData("selPosIndex",self.m_selPosIndex);
                            game_data:setCommanderRecipeData("selSortIndex",self.m_selSortIndex);
                            local itemData = self.m_tGameData[self.m_selSortId] or {}
                            local tempItemData = itemData[self.m_selSortIndex];
                            if tempItemData == nil then return end;
                            local recipeId = tempItemData.key;
                            cclog("recipeId ================== " .. recipeId)
                            game_scene:enterGameUi("game_ability_commander_snatch",{gameData = gameData,recipeId = recipeId,itemId = v.itemId});
                            self:destroy();
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_search"), http_request_method.GET, {item_id=v.itemId},"commander_search")
                    end
                end
                break;
            end
        end
        realPos = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end


--[[--
    创建列表
]]
function game_ability_commander.createTableView(self,viewSize)
    local commander_attrs = game_data:getCommanderAttrsData();
    local commander_type_cfg = getConfig(game_config_field.commander_type);
    self.m_selListItem = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = #self.m_showSortIdTab
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_ability_commander_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempSortId = self.m_showSortIdTab[index + 1]
            local tempItem = ability_commander_tab["sort_" .. tempSortId]
            cclog("tempSortId ==================== " .. tempSortId .. " ; tempItem == " .. tostring(tempItem))
            local m_type_icon = ccbNode:spriteForName("m_type_icon")
            local m_level_label = ccbNode:labelBMFontForName("m_level_label")
            local m_stroy_img = ccbNode:spriteForName("m_stroy_img")
            local m_attr_icon = ccbNode:spriteForName("m_attr_icon")
            local m_attr_label = ccbNode:labelTTFForName("m_attr_label")
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempItem.iconName)
            if tempSpriteFrame then
                m_type_icon:setDisplayFrame(tempSpriteFrame);
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempItem.stroyImgName)
            if tempSpriteFrame then
                m_stroy_img:setDisplayFrame(tempSpriteFrame);
            end
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempItem.icon)
            if tempSpriteFrame then
                m_attr_icon:setDisplayFrame(tempSpriteFrame);
            end
            local itemData = commander_attrs[tempItem.typeName]
            if itemData then
                local itemCfg = commander_type_cfg:getNodeWithKey(tostring(itemData.lv))
                m_level_label:setString(tostring(itemData.lv))
                if itemCfg then
                    local attrValue = itemCfg:getNodeWithKey(tempItem.typeName2):toInt();
                    m_attr_label:setString("+" .. tostring(attrValue))
                else
                    m_attr_label:setString("+0")
                end
            else
                m_attr_label:setString("+0")
            end
            local m_sel_node = ccbNode:nodeForName("m_sel_node");
            if self.m_selSortId == tempSortId then
                self.m_selListItem = cell;
                m_sel_node:setVisible(true);
            else
                m_sel_node:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if eventType == "ended" and cell then
            if self.m_selListItem then
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_node = ccbNode:nodeForName("m_sel_node");
                m_sel_node:setVisible(false);
            end
            self.m_selPosIndex = index + 1
            self.m_selSortId = self.m_showSortIdTab[index + 1]
            self.m_selListItem = cell;
            local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local m_sel_node = ccbNode:nodeForName("m_sel_node");
            m_sel_node:setVisible(true);
            self.m_animFlag = true;
            self:showSortTabBtn(self.m_selPosIndex);
            self.m_selSortIndex = 1;
            self:refreshSortTabBtn(self.m_selSortIndex);
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_ability_commander.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_tableView:setScrollBarVisible(false)
    -- self.m_tableView:setMoveFlag(false)
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新
]]
function game_ability_commander.refreshCommanderDetail(self,sortIndex)
    local id = game_guide_controller:getIdByTeam("18");
    local commander_recipe_cfg = getConfig(game_config_field.commander_recipe);
    local commander_type_cfg = getConfig(game_config_field.commander_type);
    self.m_animCount = 0;
    local sortItemData = self.m_tGameData[self.m_selSortId] or {};
    local tempItemData = sortItemData[sortIndex];
    self.m_level_label:setString("Lv.0");
    if tempItemData then
        local recipeId = tempItemData.key;
        -- cclog("sel recipeId ======================= " .. recipeId)
        local part = tempItemData.part
        local partCount = #part
        local tempPosTab = ability_commander_pos_tab["count" .. partCount]
        self.m_animCount = partCount
        if self.m_guildNode == nil and id == 1803 and tempItemData.synthesisFlag == true then
            self.m_guildNode = self.m_ok_btn;
        end
        -- cclog("partCount ===================== " .. partCount)
        local material_node_size = self.m_material_node:getContentSize();
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:removeAllChildrenWithCleanup(true);
            if i > partCount then
                itemTab.m_material_node:setVisible(false)
                itemTab.m_mate_tips:setVisible(false)
                itemTab.itemId = -1
                itemTab.count = 0
            else
                itemTab.m_material_node:setVisible(true)
                itemTab.m_mate_tips:setVisible(true)
                local itemId = tostring(part[i][1])
                local itemCount = part[i][2]
                local tempIcon = game_util:createItemIconByCid(itemId,false)
                if tempIcon then
                    local tempSize = itemTab.m_material_node:getContentSize();
                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    itemTab.m_material_node:addChild(tempIcon)
                    
                    itemTab.m_num_label:setString(tostring(itemCount))
                    if itemCount == 0 then
                        tempIcon:setColor(ccc3(81,81,81))
                        itemTab.m_mate_tips:setOpacity(255)
                    else
                        itemTab.m_mate_tips:setOpacity(0)
                    end
                else
                    itemTab.m_num_label:setString(tostring(itemCount))
                    if itemCount == 0 then
                        itemTab.m_mate_tips:setOpacity(255)
                    else
                        itemTab.m_mate_tips:setOpacity(0)
                    end
                end
                if id == 1801 and self.m_guildNode == nil and itemId == "6501" and itemCount <= 0 then
                    self.m_guildNode = itemTab.m_material_node;
                end
                itemTab.itemId = itemId
                itemTab.count = itemCount
                itemTab.able_level = tempItemData.able_level
                itemTab.level = tempItemData.level
                local tempPos = tempPosTab[i]
                local tempSize = self.m_material_node:getContentSize();
                if self.m_animFlag == true then
                    itemTab.parentNode:stopAllActions()
                    itemTab.parentNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    itemTab.parentNode:runAction(CCMoveTo:create(0.2,ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height)));
                else
                    itemTab.parentNode:setPosition(ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height))
                end
            end
        end
    else
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:setVisible(false)
            itemTab.m_mate_tips:setVisible(false)
            itemTab.itemId = -1
            itemTab.count = 0
        end
    end
    local tempValue = 0;
    self.m_progress_bar:setCurValue(0,false);
    local commander_attrs = game_data:getCommanderAttrsData();
    local tempItem = ability_commander_tab["sort_" .. self.m_selSortId]
    if tempItem == nil then return end
    local itemData = commander_attrs[tempItem.typeName]
    if itemData then
        self.m_level_label:setString("Lv." .. itemData.lv);
        local itemCfg1 = commander_type_cfg:getNodeWithKey(tostring(itemData.lv))
        if itemCfg1 then
            local needExp = itemCfg1:getNodeWithKey("exp"):toInt()
            needExp = needExp == 0 and 100 or needExp
            self.m_progress_bar:setCurValue(100*itemData.exp/needExp,false);
            local itemCfg2 = commander_type_cfg:getNodeWithKey(tostring(itemData.lv + 1))
            if itemCfg2 then
                local attrValue1 = itemCfg1:getNodeWithKey(tempItem.typeName2):toInt();
                local attrValue2 = itemCfg2:getNodeWithKey(tempItem.typeName2):toInt();
                tempValue = math.max(0,attrValue2 - attrValue1)
            end
        end
    end 
    -- self:responseSuccess();
    self.m_next_stroy_label:setString(string.format(string_helper.game_ability_commander.text11,tempItem.attrName,tempValue));
    return showFlag;
end


--[[--

]]
function game_ability_commander.refreshData(self)
    -- cclog("ItemsData = " .. json.encode(game_data:getItemsData() or {}));
    local id = game_guide_controller:getIdByTeam("18");
    local tempSortTab = {};
    self.m_showSortIdTab = {};
    self.m_tGameData = {}
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local commander_recipe_cfg = getConfig(game_config_field.commander_recipe);
    local commander_level_cfg = getConfig(game_config_field.commander_level);
    local tempCount = commander_recipe_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = commander_recipe_cfg:getNodeAt(i-1);
        local key = itemCfg:getKey();
        local sort = itemCfg:getNodeWithKey("sort"):toInt();
        local is_show = itemCfg:getNodeWithKey("is_show"):toInt();
        local name = itemCfg:getNodeWithKey("name"):toStr();

        local part = itemCfg:getNodeWithKey("part")
        local partCount = part:getNodeCount();
        -- cclog("partCount ===================== " .. partCount)
        local partTab = {}
        local showFlag = false;
        local synthesisFlag = true;
        for i=1,partCount do
            local itemId = part:getNodeAt(i-1):toInt();
            local tempItemId = tostring(itemId)
            local itemCount = game_data:getItemCountByCid(tempItemId)
            partTab[i] = {itemId,itemCount}
            if itemCount > 0 then
                showFlag = true
            else
                synthesisFlag = false;
            end
        end
        if showFlag == true then
            is_show = 1;
        end
        local show_level,able_level = 1,1
        local commander_level_item_cfg = commander_level_cfg:getNodeWithKey(tostring(sort));
        if commander_level_item_cfg then
            show_level,able_level = commander_level_item_cfg:getNodeWithKey("show_level"):toInt(),commander_level_item_cfg:getNodeWithKey("able_level"):toInt()
        end
        if is_show == 1 and level >= show_level then
            if self.m_tGameData[sort] == nil then
                self.m_tGameData[sort] = {}
            end
            table.insert(self.m_tGameData[sort],{key = key,part = partTab,name = name,able_level = able_level,level = level,synthesisFlag = synthesisFlag})
            if tempSortTab[sort] == nil then
                table.insert(self.m_showSortIdTab,sort)
                tempSortTab[sort] = 1;
                if id == 1801 and key == "17" then
                    self.m_selPosIndex = #self.m_showSortIdTab;
                    self.m_selSortId = self.m_showSortIdTab[self.m_selPosIndex];
                end
            end
        end
    end
    table.sort(self.m_showSortIdTab,function(data1,data2) 
        local itemData1 = ability_commander_tab["sort_" .. data1]
        local itemData2 = ability_commander_tab["sort_" .. data2]
        if itemData1 and itemData2 then
            return itemData1.sort2 < itemData2.sort2
        else
            return false;
        end
    end)
    if id ~= 1801 and self.m_selSortId == nil and #self.m_showSortIdTab > 0 then
        self.m_selPosIndex = 1;
        self.m_selSortId = self.m_showSortIdTab[self.m_selPosIndex];
    end
end

--[[--

]]
function game_ability_commander.refreshInfo(self)
    local cmdr_energy = game_data:getUserStatusDataByKey("cmdr_energy") or 0
    local value,unit = game_util:formatValueToString(cmdr_energy);
    self.m_vigor_total_label:setString(value .. unit .. "/30");
    self.m_itemCount = game_data:getItemCountByCid(tostring(30))
    self.m_have_label:setString(string.format("%d",self.m_itemCount))
    self.m_countdown_label:setTime(self.m_protect_expire);
    if self.m_protect_expire > 0 then
        self.m_have_node:setVisible(false);
        self.m_protect_node:setVisible(true);
        self.m_protection_btn:setVisible(false);
    else
        self.m_have_node:setVisible(true);
        self.m_protect_node:setVisible(false);
        self.m_protection_btn:setVisible(true);
    end
    self.left_time:removeAllChildrenWithCleanup(true)
    if cmdr_energy < 30 then
        self.left_time:setVisible(true)
        local function timeOverFunc(label,type)
            cmdr_energy = cmdr_energy + 1
            local value,unit = game_util:formatValueToString(cmdr_energy);
            self.m_vigor_total_label:setString(value .. unit .. "/30");
            label:setTime(360)
            if cmdr_energy == 30 then
                label:removeFromParentAndCleanup(true)
            end
        end
        local timeOverLabel = game_util:createCountdownLabel(self.cmdr_energy_update_left,timeOverFunc,8,2)
        timeOverLabel:setAnchorPoint(ccp(0.5,0.5))
        self.left_time:addChild(timeOverLabel,10,10)
    else
        self.left_time:setVisible(false)
    end
end

--[[--
    刷新ui
]]
function game_ability_commander.refreshUi(self)
    self:refreshTableView();
    self:showSortTabBtn(self.m_selPosIndex);
    self:refreshSortTabBtn(self.m_selSortIndex);
    self:refreshInfo();
end


--[[--
    初始化
]]
function game_ability_commander.init(self,t_params)
    t_params = t_params or {};
    self.m_protect_expire = 0;
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        -- self.m_tGameData = json.decode(data:getFormatBuffer())
        self.m_protect_expire = data:getNodeWithKey("protect_expire"):toInt();
        self.buy_cmdr_times = data:getNodeWithKey("buy_cmdr_times"):toInt()
        self.m_rob_log = json.decode(data:getNodeWithKey("rob_log"):getFormatBuffer()) or {}
        self.cmdr_energy_rate = data:getNodeWithKey("cmdr_energy_rate"):toInt()
        self.cmdr_energy_update_left = data:getNodeWithKey("cmdr_energy_update_left"):toInt()
    end
    self.m_material_node_tab = {};
    -- local recipeId = tonumber(t_params.recipeId or 17);
    -- cclog("recipeId ================= " .. recipeId)
    -- local commander_recipe_cfg = getConfig(game_config_field.commander_recipe);
    -- local itemCfg = commander_recipe_cfg:getNodeWithKey(tostring(recipeId))
    -- local sort = 1;
    -- if itemCfg then
    --     sort = itemCfg:getNodeWithKey("sort"):toInt();
    -- end
    -- local tempTab= {pos5=1,pos1=2,pos2=3,pos3=4,pos4=5}
    -- self.m_selPosIndex = tempTab["pos" .. sort] or 1

    local tempData = game_data:getCommanderRecipeData();
    self.m_selSortIndex = tempData.selSortIndex or 1;
    self.m_selPosIndex = tempData.selPosIndex or 1;
    cclog("self.m_selSortIndex====== " .. self.m_selSortIndex)
    cclog("self.m_selPosIndex====== " .. self.m_selPosIndex)
    self.m_selSortId = tempData.sort
    self.m_animCount = 0;
    self:refreshData();
    self.m_animFlag = true;
end

--[[--
    创建ui入口并初始化数据
]]
function game_ability_commander.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("18");
    -- if id == 1801 then
    --     game_guide_controller:gameGuide("drama","18",1801)
    -- end
    if id == 1801 then
        self:gameGuide("drama","18",1801)
    elseif id == 1803 then
        if self.m_guildNode then
            game_guide_controller:gameGuide("show","18",1804,{tempNode = self.m_guildNode})
            game_guide_controller:gameGuide("send","18",1804);
        end
    elseif id == 1804 then
        self:gameGuide("drama","18",1806)
    end

    game_data:updateShowTips( "cmdr_energy" , "have_show")

    game_guide_controller:showEndForceGuide("18")
    return scene;
end

--[[
    新手引导
]]
function game_ability_commander.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "18" and id == 1801 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","18",1802,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "18" and id == 1806 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","18",1806);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return game_ability_commander;