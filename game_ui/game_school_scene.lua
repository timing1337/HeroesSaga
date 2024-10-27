--- 学校 

local game_school_scene = {
    m_selHeroId = nil,--选中的heroid
    m_posIndex = nil,
    m_training_table = nil,
    m_formation_layer = nil,
    m_selHeroDataBackup = nil,
    m_countdownLabel = nil,
    m_posIconTab = nil,
    m_guildNode = nil,
};

--[[--
    销毁
]]
function game_school_scene.destroy(self)
    -- body
    cclog("-----------------game_school_scene destroy-----------------");
    self.m_selHeroId = nil;
    self.m_posIndex = nil;
    self.m_formation_layer = nil;
    self.m_selHeroDataBackup = nil;
    self.m_countdownLabel = nil;
    self.m_posIconTab = nil;
    self.m_guildNode = nil;
end
--[[--
    返回
]]
function game_school_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_school_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_school2.ccbi");
    self.m_formation_layer = ccbNode:layerColorForName("m_formation_layer")

    self:initAdjustmentFormationTouch(self.m_formation_layer);
    local tempTab = nil;
    local tempNode = nil;
    for i=1,4 do
        tempTab = {};
        tempNode = self.m_formation_layer:getChildByTag(i);
        tempTab.parentNode = tempNode;
        tempTab[1] = tolua.cast(tempNode:getChildByTag(1),"CCSprite");
        tempTab[2] = tolua.cast(tempNode:getChildByTag(2),"CCSprite");
        tempTab[3] = tolua.cast(tempNode:getChildByTag(3),"CCLabelTTF");
        self.m_posIconTab[i] = tempTab;
    end
    return ccbNode;
end


--[[--
    
]]
function game_school_scene.onBtnOnClick(self,btnType,btnTag)
    cclog("onBtnOnClick btnType ===========" .. btnType .. " ; btnTag ==" .. btnTag)
    self.m_posIndex = btnTag;
    self.m_selHeroId = self.m_training_table[self.m_posIndex].card_id;
    if btnType == 2 then--立即完成
        local function responseMethod(tag,gameData)
            game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
            self:initStovesFormation();

            game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(self.m_selHeroId)),heroDataBackup = self.m_selHeroDataBackup,openType=2})
        end
        if self.m_posIndex ~= nil and self.m_selHeroId ~= nil then
            local tGameData = game_data:getSchoolData();
            local stoves = tGameData.stoves;
            stoveItem = stoves["stove_" .. self.m_posIndex];
            local time_need = math.floor(stoveItem.end_time - tGameData.now - game_data:getTimeDifference(tGameData.dataTime));

            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.m_selHeroDataBackup = util.table_new( game_data:getCardDataById(tostring(self.m_selHeroId)));
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp_force"), http_request_method.GET, {stove_key="stove_" .. self.m_posIndex},"school_get_exp_force")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_speed_training,       --可缺省
                text = string.format(string_config.m_speed_training_tips,math.ceil(time_need/60)),      --可缺省 每分钟1钻石
            }
            game_util:openAlertView(t_params);
        end
    elseif btnType == 1 or btnType == 3 then--停止训练 领取经验
        local function responseMethod(tag,gameData)
            game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
            self:initStovesFormation();

            game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(self.m_selHeroId)),heroDataBackup = self.m_selHeroDataBackup,openType=2})
        end
        if self.m_posIndex ~= nil and self.m_selHeroId ~= nil then
            if btnType == 1 then
                local t_params = 
                {
                    title = string_config.m_warning,
                    okBtnCallBack = function(target,event)
                        self.m_selHeroDataBackup = util.table_new(game_data:getCardDataById(tostring(self.m_selHeroId)));
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp"), http_request_method.GET, {stove_key="stove_" .. self.m_posIndex},"school_get_exp")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_stop_training,       --可缺省
                    text = string_config.m_stop_training_tips,      --可缺省
                }
                game_util:openAlertView(t_params);
            else
                self.m_selHeroDataBackup = util.table_new(game_data:getCardDataById(tostring(self.m_selHeroId)));
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp"), http_request_method.GET, {stove_key="stove_" .. self.m_posIndex},"school_get_exp")
            end
        end
    end
end

--[[--
    刷新英雄信息
]]
function game_school_scene.refreshHeroInfo(self,heroId,posIndex)
	if heroId ~= nil and tonumber(heroId) ~= 0 then
        local tGameData = game_data:getSchoolData();
        local stoves = tGameData.stoves;
        stoveItem = stoves["stove_" .. posIndex];

        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = luaCCBNode:create();
        local function onStopBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            self:onBtnOnClick(1,btnTag);
        end
        ccbNode:registerFunctionWithFuncName("onStopBtnClick",onStopBtnClick);
        local function onSpeedBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            self:onBtnOnClick(2,btnTag);
        end
        ccbNode:registerFunctionWithFuncName("onSpeedBtnClick",onSpeedBtnClick);
        local function onOkBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            self:onBtnOnClick(3,btnTag);
        end
        ccbNode:registerFunctionWithFuncName("onOkBtnClick",onOkBtnClick);
        ccbNode:openCCBFile("ccb/ui_school_item.ccbi");
        local m_spr_bg = ccbNode:spriteForName("m_spr_bg")
        local m_level_label = ccbNode:labelTTFForName("m_level_label");
        local m_name_label = ccbNode:labelTTFForName("m_name_label");
        local m_anim_node = ccbNode:nodeForName("m_anim_node");
        local m_type_label = ccbNode:labelTTFForName("m_type_label")
        local m_time_label = ccbNode:labelTTFForName("m_time_label")
        local m_exp_label = ccbNode:labelTTFForName("m_exp_label")
        local m_stop_btn = ccbNode:controlButtonForName("m_stop_btn")
        local m_speed_btn = ccbNode:controlButtonForName("m_speed_btn")
        local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
        m_time_label:setString("");
        m_ok_btn:setTag(posIndex);
        m_stop_btn:setTag(posIndex);
        m_speed_btn:setTag(posIndex);
        game_util:setControlButtonTitleBMFont(m_ok_btn)
        -- m_level_label:setString("Lv." .. cardData.lv .. "/" .. cardData.level_max);
        m_level_label:setString("Lv." .. cardData.lv);
        m_name_label:setString(heroCfg:getNodeWithKey("name"):toStr());
        game_util:setHeroNameColorByQuality(m_name_label,heroCfg);
        m_exp_label:setString(stoveItem.exp);

        local function timeEndFunc(label,type)
            local tag = label:getTag();
            m_ok_btn:setVisible(true);
            m_stop_btn:setVisible(false);
            m_speed_btn:setVisible(false);
        end
        -- local pX,pY = m_time_label:getPosition();
        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setColor(ccc3(112,112,112))
        countdownLabel:setTag(posIndex);
        countdownLabel:setPosition(ccp(- countdownLabel:getContentSize().width*0.5,m_time_label:getContentSize().height*0.5))
        m_time_label:addChild(countdownLabel)

        local school_train_type_config = getConfig(game_config_field.school_train_type_config);
        local train_type = stoveItem.train_type;
        local typeItem = school_train_type_config:getNodeWithKey(tostring(train_type));
        local percent = 100;
        if typeItem then
            percent = typeItem:getNodeAt(0):toInt();
        end
        m_type_label:setString(tostring(percent) .. "%");

        local time_need = math.floor(stoveItem.end_time - tGameData.now - game_data:getTimeDifference(tGameData.dataTime));
        if time_need > 0 then
            countdownLabel:setTime(time_need);
            m_ok_btn:setVisible(false);
            m_stop_btn:setVisible(true);
            m_speed_btn:setVisible(true);
        else
            countdownLabel:setTime(0);
            m_ok_btn:setVisible(true);
            m_stop_btn:setVisible(false);
            m_speed_btn:setVisible(false);
        end

        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = game_util:createIdelAnim(ainmFile,0,cardData,heroCfg);
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
        local size = self.m_posIconTab[posIndex].parentNode:getContentSize();
        ccbNode:setPosition(ccp(size.width*0.5,size.height*0.5));
        ccbNode:setAnchorPoint(ccp(0.5,0.5));
        self.m_posIconTab[posIndex].parentNode:addChild(ccbNode,100,100);
	end
end

--[[--
    清除ui数据
]]
function game_school_scene.clearUi(self,posIndex)

end
--[[--
    进入选择训练英雄ui
]]
function game_school_scene.enterSelectUi(self,posIndex)
    game_scene:enterGameUi("game_school_select_scene",{gameData = nil,openType = "game_school_select_scene",posIndex = posIndex});
    self:destroy();
end
--[[--
    训练位置的点击处理
]]
function game_school_scene.initAdjustmentFormationTouch(self,formation_layer)
    local beganItem = nil;
    local endItem = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local realPos = nil;
    -- local selItem = nil;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        -- selItem = nil;
        -- for endTag = 1,#self.m_posIconTab do
        --     realPos = self.m_posIconTab[endTag].parentNode:convertToNodeSpace(ccp(x,y));
        --     endItem = self.m_posIconTab[endTag][1];
        --     if endItem:boundingBox():containsPoint(realPos) then
        --         if self.m_training_table[endTag] ~= nil and self.m_training_table[endTag].available == 1 then
        --             if self.m_training_table[endTag].card_id == 0 then
        --                 selItem = endItem;
        --             end
        --         end
        --         break;
        --     end
        -- end
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)

    end
    
    local function onTouchEnded(x, y)
            for endTag = 1,#self.m_posIconTab do
                realPos = self.m_posIconTab[endTag].parentNode:convertToNodeSpace(ccp(x,y));
                endItem = self.m_posIconTab[endTag][1];
                if endItem:boundingBox():containsPoint(realPos) then
                    if self.m_training_table[endTag] ~= nil and self.m_training_table[endTag].available == 1  and self.m_training_table[endTag].flag == true then
                        if self.m_training_table[endTag].card_id == 0 then
                            self:enterSelectUi(endTag);
                        end
                    end
                    break;
                end
            end
        touchBeginPoint = nil;
        beganItem = nil;
        endItem = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,-129)
    formation_layer:setTouchEnabled(true)
end

--[[--
    初始化训练的位置信息
]]
function game_school_scene.initStovesFormation(self)
    self.m_training_table = {};
    local tGameData = game_data:getSchoolData();
    cclog("tGameData == " .. json.encode(tGameData))
    local stoves = tGameData.stoves;
    local stovesCount = game_util:getTableLen(stoves);
    
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local stoveItem = nil;
    local card_id = nil;
    local bg_spr = nil;
    local lock_spr = nil;
    local available = nil;
    local statusLabel = nil;
    local parentNode = nil;
    local open_level = -1;
    for i=1,#self.m_posIconTab do
        parentNode = self.m_posIconTab[i].parentNode;
        local tempNode = parentNode:getChildByTag(100);
        if tempNode then
            tempNode:removeFromParentAndCleanup(true);
        end
        bg_spr = self.m_posIconTab[i][1];
        lock_spr = self.m_posIconTab[i][2];
        statusLabel = self.m_posIconTab[i][3]
        bg_spr:removeAllChildrenWithCleanup(true);
        if i <= stovesCount then
            stoveItem = stoves["stove_" .. i];
            self.m_training_table[i] = stoveItem;
            card_id = stoveItem.card_id;
            available = stoveItem.available;
            open_level = stoveItem.open_level;
            if available == nil or available == 0 or open_level == -1 or  open_level > level then
                if open_level == -1 then
                    if i == 3 then
                        -- statusLabel:setString("vip达到" .. 10 .. "级")
                        statusLabel:setString(tostring(string_config.m_no_open))
                    else
                        -- statusLabel:setString("vip达到" .. 20 .. "级")
                        statusLabel:setString(tostring(string_config.m_no_open))
                    end
                else
                    statusLabel:setString(string.format(string_config.m_open_condition,open_level))
                end
                self.m_training_table[i].flag = false;
            else
                self.m_training_table[i].flag = true;
                bg_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xx_characterBg2.png"));
                lock_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xx_add.png"));
                if card_id ~= nil and card_id ~= 0 then
                    self:refreshHeroInfo(card_id,i);
                    bg_spr:setVisible(false);
                    lock_spr:setVisible(false);
                    statusLabel:setVisible(false);
                else
                    statusLabel:setString(tostring(string_config.m_add_training_card))
                    bg_spr:setVisible(true);
                    lock_spr:setVisible(true);
                    statusLabel:setVisible(true);
                    if self.m_guildNode == nil and i == 1 then
                        self.m_guildNode = bg_spr;
                    end
                end
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_school_scene.refreshUi(self)
    self:initStovesFormation();
end

--[[--
    初始化
]]
function game_school_scene.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setSchoolDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
    self.m_posIndex = t_params.posIndex;
    self.m_selHeroId = t_params.selHeroId;
    self.m_training_table = {};
    self.m_posIconTab = {};
end


--[[--
    创建入口
]]
function game_school_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("11");
    if id == 84 then
        self:gameGuide("drama","11",84)
    elseif id == 86 then
        self:gameGuide("drama","11",87)
    end
    return scene;
end

function game_school_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "11" and id == 84 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","11",84,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "11" and id == 87 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","11",87);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "11" and id == 89 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","11",89);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end


return game_school_scene;
