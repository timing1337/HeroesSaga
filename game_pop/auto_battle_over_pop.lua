---  自动战斗结束

local auto_battle_over_pop = {
    m_tGameData = nil,
    m_popUi = nil,
    m_callFunc = nil,
    returnType = nil,
    m_root_layer = nil,
    m_own_status_icon = nil,
    m_lv_label = nil,
    m_exp_bar_bg = nil,
    m_expBar = nil,
    m_reward_node_1 = nil,
    m_reward_node_2 = nil,
    m_reward_node_3 = nil,
    m_lost_node = nil,
    m_ccbNode = nil,
    m_win_anim_node = nil,
    m_atrr_up_btn = nil,
    m_equip_up_btn = nil,
    m_rebattle_count_label = nil,
    m_showCount = nil,
    m_buildingId = nil,
    m_godgiftTab = nil,
    m_mask_layer = nil,
};
--[[----
    销毁
]]
function auto_battle_over_pop.destroy(self)
    -- body
    cclog("-----------------auto_battle_over_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_callFunc = nil;
    self.returnType = nil;
    self.m_root_layer = nil;
    self.m_own_status_icon = nil;
    self.m_lv_label = nil;
    self.m_exp_bar_bg = nil;
    self.m_expBar = nil;
    self.m_reward_node_1 = nil;
    self.m_reward_node_2 = nil;
    self.m_reward_node_3 = nil;
    self.m_lost_node = nil;
    self.m_ccbNode = nil;
    self.m_win_anim_node = nil;
    self.m_atrr_up_btn = nil;
    self.m_equip_up_btn = nil;
    self.m_rebattle_count_label = nil;
    self.m_showCount = nil;
    self.m_buildingId = nil;
    self.m_godgiftTab = nil;
    self.m_mask_layer = nil;
end
--[[----
    返回
]]
function auto_battle_over_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("auto_battle_over_pop");
end
--[[----
    读取ccbi创建ui
]]
function auto_battle_over_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        game_scene:removePopByName("player_level_up_pop");
        if self.m_callFunc and type(self.m_callFunc) == "function" then
            self.m_callFunc(btnTag);
        end
        self:back();
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_auto_battle_over.ccbi");
    self.m_mask_layer = ccbNode:layerForName("m_mask_layer")
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    self.m_win_anim_node = ccbNode:nodeForName("m_win_anim_node")
    --数据解析start
    local user_data = game_data:getUserStatusData()
    local level = user_data["level"]
    local exp_max = user_data["exp_max"]
    local exp = user_data["exp"]
    self.m_battle_result = 1;
    cclog("level->"..tostring(level))
    cclog("exp_max->"..tostring(exp_max))
    cclog("exp->"..tostring(exp))
    cclog("m_battle_result->"..tostring(self.m_battle_result))
    --数据解析end
    self.m_rebattle_count_label = ccbNode:labelTTFForName("m_rebattle_count_label")
    --第一部分m_reward_node_1——start
    self.m_reward_node_1 = ccbNode:nodeForName("m_reward_node_1")
    self.m_own_status_icon = tolua.cast(ccbNode:objectForName("m_own_status_icon"), "CCSprite");
    

    --级别经验
    self.m_lv_label = tolua.cast(ccbNode:objectForName("m_lv_label"), "CCLabelTTF");
    self.m_exp_bar_bg = tolua.cast(ccbNode:objectForName("m_exp_bar_bg"), "CCNode");
    self.m_lv_label:setString(level)
    self.m_expBar = ExtProgressTime:createWithFrameName("public_diban.png","public_tili.png");
    local bar = self.m_expBar;
    --bar:setCurValue(exp / exp_max * 100,false);
    self.m_exp_bar_bg:addChild(bar,10,10);
    --第一部分m_reward_node_1——end

    --先不显示这两部分，然后判断是否有该奖励start
    self.m_reward_node_2 = ccbNode:nodeForName("m_reward_node_2")--送卡
    self.m_reward_node_3 = ccbNode:nodeForName("m_reward_node_3")--奖励
    self.m_lost_node = ccbNode:nodeForName("m_lost_node")
    self.m_reward_node_2:setVisible(false);
    self.m_reward_node_3:setVisible(false);
    self.m_reward_node_1:setVisible(false);
    self.m_lost_node:setVisible(false);
    -----------------------------------end

    -----战斗胜利结束后调用------animEndCallFunc--start
    local function animEndCallFunc(animName)
        if animName == "enter_anim" then
            game_scene:addPop("game_chest_pop",{godgiftTab = self.m_godgiftTab},{order = 100000})
            self.m_mask_layer:setTouchEnabled(false);
            game_sound:playUiSound("battle_success" .. math.random(1,3))
            local winAnimNode = game_util:createEffectAnim("win",1.0,true)
            if winAnimNode then
                self.m_win_anim_node:addChild(winAnimNode);
            end
            self:playerWin();
            ccbNode:runAnimations("loop_anim")
        elseif animName == "loop_anim" then
            ccbNode:runAnimations("loop_anim")
        end
    end
    -----战斗胜利结束后调用------animEndCallFunc--end

    if self.m_battle_result < 5 then--战斗胜利
        cclog("registerAnimFunc animEndCallFunc -----------------------")
        self.m_reward_node_1:setVisible(true);
        ccbNode:registerAnimFunc(animEndCallFunc)
        ccbNode:runAnimations("enter_anim")
    else
        game_sound:playUiSound("battle_failed" .. math.random(1,2))
        bar:setCurValue(exp / exp_max * 100,false);
        self.m_lost_node:setVisible(true);
    end
    self.m_atrr_up_btn = ccbNode:controlButtonForName("m_atrr_up_btn")
    self.m_equip_up_btn = ccbNode:controlButtonForName("m_equip_up_btn")
    self.m_atrr_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_equip_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    local battleType = game_data:getBattleType();
    local m_btn_node = ccbNode:nodeForName("m_btn_node")
    local btn = nil;
    for i = 2,3 do
        btn = tolua.cast(m_btn_node:getChildByTag(i),"CCControlButton");
        game_util:setControlButtonTitleBMFont(btn)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_mask_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-7,true);
    self.m_mask_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[----
    战斗胜利 
]]
function auto_battle_over_pop.playerWin(self)
        local bar = self.m_expBar;
        local ccbNode = self.m_ccbNode;
        local battle_rewards = self.m_tGameData.battle_rewards
        if battle_rewards == nil then 
            cclog("battle_rewards == nil")
            return 
        end
        local user_data = game_data:getUserStatusData()
        local level = user_data["level"]
        local exp_max = user_data["exp_max"]
        local exp = user_data["exp"]
        local reward_exp_player = battle_rewards.reward_exp_player
        local reward_exp_player_count = #reward_exp_player;

        -- 显示用户经验和等级等
        local levelUpFlag = false;
        local reward_exp_player_temp = nil;
        local reward_exp_player_item = nil;
        local levelUpCount = 1;
        local animStep = 1;
        local addExp = 0;
        local oldExp = 0;
        local lvTemp = 0;
        local function levelUpExpAnim(itemData)
            lvTemp = itemData[1]
            local exp_max_temp = itemData[2]
            bar:setMaxValue(exp_max_temp);
            if animStep == 1 then
                -- cclog("up animStep ======1==================" .. animStep .. " ;oldExp = " .. oldExp .. "; exp_max_temp ==" .. exp_max_temp);
                bar:setCurValue(oldExp,false);
            else
                -- cclog("up animStep ======2==================" .. animStep .. " ;oldExp = " .. oldExp .. "; exp_max_temp ==" .. exp_max_temp);
                bar:setCurValue(0,false);
            end
            bar:setCurValue(exp_max_temp,true);
            levelUpFlag = true;
            self.m_lv_label:setString("" .. lvTemp);
            animStep = animStep + 1;
        end
        local function playerLevelUpAnimEnd()
            cclog("playerLevelUpAnimEnd ============================= ");
            levelUpFlag = false;
            if animStep < (levelUpCount) then
                reward_exp_player_item = reward_exp_player_temp[animStep]
                levelUpExpAnim(reward_exp_player_item);
            elseif animStep == (levelUpCount) then
                bar:setMaxValue(exp_max);
                bar:setCurValue(0,false);
                bar:setCurValue(exp,true);
                lvTemp = level;
                self.m_lv_label:setString("" .. tostring(level));
                animStep = animStep + 1;
            end
        end
        local function playerExpAnimEnd(extBar)
            cclog("playerExpAnimEnd --------------levelUpFlag = " .. tostring(levelUpFlag));
            if levelUpFlag == true then
                if levelUpCount == 2 or (levelUpCount > 2 and animStep == (levelUpCount - 1)) then
                    game_scene:addPop("player_level_up_pop",{callBackFunc = playerLevelUpAnimEnd,lv = lvTemp})
                else
                    playerLevelUpAnimEnd();
                end
                -- ccbNode:addChild(game_util:playerLevelUpCCBAnim(playerLevelUpAnimEnd));
            else
                self:showRewardResurece();
                self:showRewardCharacter();
                self:showRewardItem();
            end
        end
        bar:registerScriptBarHandler(playerExpAnimEnd);
        --bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,12));
        cclog("reward_exp_player_count ====================" .. reward_exp_player_count);
        if reward_exp_player_count == 3 then
            addExp = reward_exp_player[1]
            oldExp = reward_exp_player[2]
            reward_exp_player_temp = reward_exp_player[3]
            levelUpCount = #reward_exp_player_temp
            -- cclog("levelUpCount ====================" .. levelUpCount);
            if levelUpCount == 1 then--没有升级
                bar:setMaxValue(exp_max);
                bar:setCurValue(exp - addExp,false);
                bar:setCurValue(exp,true);
                lvTemp = level;
                self.m_lv_label:setString("" .. tostring(level));
                -- m_exp_label:setString(tostring(exp .. "/" .. exp_max));
                animStep = 2;
            elseif levelUpCount > 1 then
                reward_exp_player_item = reward_exp_player_temp[animStep]
                levelUpExpAnim(reward_exp_player_item);
            end
        else
            bar:setMaxValue(exp_max);
            bar:setCurValue(exp,false);
            bar:setCurValue(exp,true);
        end
        self.m_reward_node_1:setVisible(true)
end

local reward_icon_tab = {reward_food = "public_icon_food2.png",reward_metal = "public_icon_metal2.png",reward_energy = "public_icon_energy2.png",reward_crystal = "public_icon_crystal2.png"};

--[[--
    设置奖励资源
]]
function auto_battle_over_pop.setRewardValue(self,tempIndex,value,reward_type)
    local ccbNode = self.m_ccbNode;
    local reward_icon = ccbNode:spriteForName("m_card_" .. tempIndex)
    local reward_label = ccbNode:labelTTFForName("m_reward_value_" .. tempIndex)
    reward_icon:setVisible(true)
    reward_label:setVisible(true)
    reward_label:setString("×" .. value)
    local reward_icon_size = reward_icon:getContentSize();
    local temp_reward_icon = CCSprite:createWithSpriteFrameName(reward_icon_tab[reward_type])
    temp_reward_icon:setPosition(ccp(reward_icon_size.width*0.5,reward_icon_size.height*0.5))
    reward_icon:addChild(temp_reward_icon);
    -- reward_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(reward_icon_tab[reward_type]));
    reward_icon:setScale(0.75)
end

--[[----
    资源奖励
]]
function auto_battle_over_pop.showRewardResurece(self)
    self.m_reward_node_2:setVisible(true);
    local ccbNode = self.m_ccbNode;
    local rewards = self.m_tGameData.reward or {};
    local reward_food = rewards.food or 0
    local reward_metal = rewards.metal or 0
    local reward_energy = rewards.energy or 0
    local tempIndex = 1;
    if reward_food ~= 0 then
        self:setRewardValue(tempIndex,reward_food,"reward_food");
        tempIndex = tempIndex + 1;
    end
    if reward_metal ~= 0 then
        self:setRewardValue(tempIndex,reward_metal,"reward_metal");
        tempIndex = tempIndex + 1;
    end
    if reward_energy ~= 0 then
        self:setRewardValue(tempIndex,reward_energy,"reward_energy");
        tempIndex = tempIndex + 1;
    end
    for i=tempIndex,3 do
        local reward_icon = ccbNode:spriteForName("m_card_" .. i)
        reward_icon:setScale(0.75)
    end
    rewards.food = 0;
    rewards.metal = 0;
    rewards.energy = 0;
    game_util:rewardTipsByDataTable(rewards);
end

--[[--
    卡牌奖励
]]
function auto_battle_over_pop.showRewardCharacter(self)
        local bar = self.m_expBar;
        local ccbNode = self.m_ccbNode;
        local battle_rewards = self.m_tGameData.battle_rewards
        if battle_rewards == nil then 
            cclog("battle_rewards == nil")
            return 
        end
        local reward_character = battle_rewards.reward_character or {}
        local reward_character_count = game_util:getTableLen(reward_character)
        self.m_showCount = reward_character_count;
        -- 显示战斗奖励
        local function showRewardCharacter()
            cclog("showRewardCharacter =================================");
            cclog("reward_character_count ===================="..reward_character_count);
            if reward_character_count == 0 then 
                return 
            end
            self.m_reward_node_3:setVisible(true)
            local reward_character_item = nil;
            local c_id = nil;
            local itemConfig = nil;
            local img = nil;
            local headIconSpr = nil;
            local characterName,quality = nil;
            local posIndex = 1;
            for k,reward_character_item in pairs(reward_character) do
                headIconSpr = ccbNode:spriteForName("m_props_" .. posIndex)
                if headIconSpr then
                    c_id = reward_character_item.c_id
                    itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(c_id);
                    quality = itemConfig:getNodeWithKey("quality"):toInt();
                    img = itemConfig:getNodeWithKey("img"):toStr();
                    characterName = itemConfig:getNodeWithKey("name"):toStr();
                    cclog("characterName img->"..img)
                    cclog("characterName->"..characterName)
                    local headIconSprSize = headIconSpr:getContentSize();
                    local icon = game_util:createIconByName(img);
                    headIconSpr:setDisplayFrame(icon:displayFrame());
                    -- headIconSpr:setScale(headIconSprSize.width / 64);
                    headIconSpr:setColor(ccc3(0,0,0));
                    if quality >= 3 then
                        local rareIcon = CCSprite:createWithSpriteFrameName("zdjs_faguang.png")
                        rareIcon:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                        rareIcon:setVisible(false);
                        headIconSpr:addChild(rareIcon,0,5);
                    end
                    local label_temp = CCLabelTTF:create(tostring(characterName),TYPE_FACE_TABLE.Arial_BoldMT,10);
                    label_temp:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                    headIconSpr:addChild(label_temp,0,10);
                    label_temp:setVisible(false)
                    local function objectReset( node )
                        --headIconSpr:setColor(ccc3(255,255,255));
                        local sprite = tolua.cast(node,"CCSprite");
                        sprite:setColor(ccc3(255,255,255));
                        local rareIcon = node:getChildByTag(5);
                        if rareIcon then
                            rareIcon:setVisible(true);
                        end
                    end
                    local function addNameLable(node)
                        --label_temp:setVisible(true)
                    end
                    local arr = CCArray:create();
                    arr:addObject(CCOrbitCamera:create(0.5 , 1 , 0 , 0 , 90 , 0, 0));
                    arr:addObject(CCCallFuncN:create(objectReset));
                    arr:addObject(CCOrbitCamera:create(0.5 , 1 , 0 , 90, 90 , 0, 0));
                    arr:addObject(CCCallFuncN:create(addNameLable));
                    headIconSpr:runAction(CCSequence:create(arr));
                end
                posIndex = posIndex + 1;
            end
            for i = posIndex,10 do
                headIconSpr = ccbNode:spriteForName("m_props_" .. i)
                headIconSpr:setVisible(false)
            end
        end
        showRewardCharacter();
end

--[[--
    卡牌道具
]]
function auto_battle_over_pop.showRewardItem(self)
        local bar = self.m_expBar;
        local ccbNode = self.m_ccbNode;
        local battle_rewards = self.m_tGameData.battle_rewards
        if battle_rewards == nil then 
            cclog("battle_rewards == nil")
            return 
        end
        local reward_item = battle_rewards.reward_item or {};
        local reward_item_count = game_util:getTableLen(reward_item)
        -- 显示战斗奖励
        local function showRewardItem()
            cclog("showRewardItem =================================");
            cclog("reward_item_count ===================="..reward_item_count);
            if reward_item_count == 0 then 
                return 
            end
            self.m_reward_node_3:setVisible(true)
            local reward_character_item = nil;
            local c_id = nil;
            local itemConfig = nil;
            local iconName = nil;
            local headIconSpr = nil;
            local characterName,shade = nil;
            local posIndex = self.m_showCount+1;
            for k,count in pairs(reward_item) do
                headIconSpr = ccbNode:spriteForName("m_props_" .. posIndex)
                if headIconSpr then
                    headIconSpr:setVisible(true)
                    c_id = k;
                    itemConfig = getConfig(game_config_field.item):getNodeWithKey(c_id);
                    local icon = game_util:createItemIconByCfg(itemConfig);
                    shade = itemConfig:getNodeWithKey("shade"):toStr();
                    characterName = itemConfig:getNodeWithKey("name"):toStr();
                    cclog("item Name->"..characterName)
                    local headIconSprSize = headIconSpr:getContentSize();
                    icon:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                    headIconSpr:addChild(icon,1,1)
                    icon:setVisible(false);
                    headIconSpr:setColor(ccc3(0,0,0));
                    if shade ~= "" then
                        local rareIcon = CCSprite:createWithSpriteFrameName("zdjs_faguang.png")
                        rareIcon:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                        rareIcon:setVisible(false);
                        headIconSpr:addChild(rareIcon,2,5);
                    end
                    -- local label_temp = game_util:createLabelTTF({text = "×" .. count,color = ccc3(250,180,0),fontSize = 10});
                    -- label_temp:setPosition(ccp(headIconSprSize.width * 0.5,-headIconSprSize.height * 0.1));
                    -- headIconSpr:addChild(label_temp,3,10);
                    -- label_temp:setVisible(false)
                    local function objectReset( node )
                        --headIconSpr:setColor(ccc3(255,255,255));
                        local sprite = tolua.cast(node,"CCSprite");
                        sprite:setOpacity(0);
                        local tempIcon = node:getChildByTag(1);
                        if tempIcon then
                            tempIcon:setVisible(true);
                        end
                        local rareIcon = node:getChildByTag(5);
                        if rareIcon then
                            rareIcon:setVisible(true);
                        end
                        label_temp:setVisible(true)
                    end
                    local function addNameLable(node)
                        -- label_temp:setVisible(true)
                    end
                    local arr = CCArray:create();
                    arr:addObject(CCOrbitCamera:create(0.5 , 1 , 0 , 0 , 90 , 0, 0));
                    arr:addObject(CCCallFuncN:create(objectReset));
                    arr:addObject(CCOrbitCamera:create(0.5 , 1 , 0 , 90, 90 , 0, 0));
                    arr:addObject(CCCallFuncN:create(addNameLable));
                    headIconSpr:runAction(CCSequence:create(arr));
                end
                posIndex = posIndex + 1;
            end
            for i = posIndex,10 do
                headIconSpr = ccbNode:spriteForName("m_props_" .. i)
                headIconSpr:setVisible(false)
            end
        end
        showRewardItem();
end

--[[----
    刷新ui
]]
function auto_battle_over_pop.refreshUi(self)
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
    if buildingCfgData then
        local sweepLogData = game_data:getSelCitySweepLogData();
        local current_sweep = sweepLogData[tostring(self.m_buildingId)] or 0;
        local max_sweep = buildingCfgData:getNodeWithKey("max_sweep"):toInt();
        current_sweep = math.min(current_sweep,max_sweep)
        --这里需要重置一下的功能
        self.m_rebattle_count_label:setString(string.format(string_config.m_rebattle_count,math.max(0,max_sweep-current_sweep),max_sweep))
    else
        self.m_rebattle_count_label:setString(string.format(string_config.m_rebattle_count,0,0))
    end
end

--[[----
    初始化
]]
function auto_battle_over_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
        self.m_godgiftTab = self.m_tGameData.godgift or {};
    end
    self.m_callFunc = t_params.callFunc;
    self.returnType = t_params.returnType;
    self.m_showCount = 0;
    self.m_buildingId = t_params.buildingId;
end

--[[----
    创建ui入口并初始化数据
]]
function auto_battle_over_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return auto_battle_over_pop;