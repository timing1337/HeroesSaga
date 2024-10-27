---  战斗结束

local battle_over_pop = {
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
    m_reward_node_4 = nil,
    m_lost_node = nil,
    m_ccbNode = nil,
    m_AtkData = nil,
    m_win_anim_node = nil,
    m_atrr_up_btn = nil,
    m_equip_up_btn = nil,
    m_mask_layer = nil,
    m_skill_up_btn = nil,
    m_retreat_btn = nil,
    m_godgiftTab = nil,
    m_next_step = nil,
    m_countdownLabel = nil,
    m_requestFlag = nil,
    m_total_hurt_label = nil,
    m_boss_node = nil,
    m_gain_node_bg = nil,
    title_sprite = nil,
    m_arena_node = nil,
    m_arena_rank_label = nil,
    arena_count_label = nil,
};
--[[----
    销毁
]]
function battle_over_pop.destroy(self)
    -- body
    cclog("-----------------battle_over_pop destroy-----------------");
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
    self.m_reward_node_4 = nil;
    self.m_lost_node = nil;
    self.m_ccbNode = nil;
    self.m_AtkData = nil;
    self.m_win_anim_node = nil;
    self.m_atrr_up_btn = nil;
    self.m_equip_up_btn = nil;
    self.m_mask_layer = nil;
    self.m_skill_up_btn = nil;
    self.m_retreat_btn = nil;
    self.m_godgiftTab = nil;
    self.m_next_step = nil;
    self.m_countdownLabel = nil;
    self.m_requestFlag = nil;
    self.m_total_hurt_label = nil;
    self.m_boss_node = nil;
    self.m_gain_node_bg = nil;
    self.title_sprite = nil;
    self.m_arena_node = nil;
    self.m_arena_rank_label = nil;
    self.arena_count_label = nil;
end
--[[----
    返回
]]
function battle_over_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("battle_over_pop");
end
--[[----
    读取ccbi创建ui
]]
function battle_over_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("battle_over_pop btnTag ==== " .. btnTag)
        if self.m_callFunc and type(self.m_callFunc) == "function" then
            self:removeCountdownLabel();
            if game_guide_controller:getFormationGuideIndex() == 1 then
                game_scene:removeGuidePop()
                local function endCallFunc()
                    self.m_callFunc(btnTag);
                end
                local t_params = {};
                t_params.dramaId = 1029;
                t_params.endCallFunc = endCallFunc;
                game_scene:addPop("drama_dialog_pop",t_params);
            else
                self.m_callFunc(btnTag);
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_battle_over.ccbi");

    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    self.m_mask_layer = ccbNode:layerForName("m_mask_layer")
    self.m_win_anim_node = ccbNode:nodeForName("m_win_anim_node")
    self.m_boss_node = ccbNode:nodeForName("m_boss_node")
    self.m_gain_node_bg = ccbNode:nodeForName("m_gain_node_bg")
    self.m_total_hurt_label = ccbNode:labelBMFontForName("m_total_hurt_label")
    self.title_sprite = ccbNode:spriteForName("title_sprite")
    self.m_arena_node = ccbNode:nodeForName("m_arena_node")
    self.m_arena_rank_label = ccbNode:labelBMFontForName("m_arena_rank_label")

    self.arena_count_label = ccbNode:labelBMFontForName("arena_count_label")
    --数据解析start
    local user_data = game_data:getUserStatusData()
    local level = user_data["level"]
    local exp_max = user_data["exp_max"]
    local exp = user_data["exp"]
    local battle = self.m_tGameData.battle;
    self.m_battle_result = 100;
    if battle then
        self.m_battle_result = battle.winer or 100;
    end
    cclog("level->"..tostring(level))
    cclog("exp_max->"..tostring(exp_max))
    cclog("exp->"..tostring(exp))
    cclog("m_battle_result->"..tostring(self.m_battle_result))

    local user_data_backup = game_data:getUserStatusDataBackup();
    if user_data_backup.level == nil then
        user_data_backup.level = level;
    end

    --数据解析end
    --第一部分m_reward_node_1——start
    self.m_reward_node_1 = ccbNode:nodeForName("m_reward_node_1")
    self.m_own_status_icon = tolua.cast(ccbNode:objectForName("m_own_status_icon"), "CCSprite");
    --胜负 
    if self.m_battle_result == nil or self.m_battle_result > 5 then--负
        self.m_own_status_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lose.png"));
    else                            --胜
        self.m_own_status_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("win.png"));
    end
    --级别经验
    self.m_lv_label = tolua.cast(ccbNode:objectForName("m_lv_label"), "CCLabelTTF");
    self.m_exp_bar_bg = tolua.cast(ccbNode:objectForName("m_exp_bar_bg"), "CCNode");
    self.m_lv_label:setString(tostring(user_data_backup.level))
    self.m_expBar = ExtProgressTime:createWithFrameName("public_diban.png","public_tili.png");
    local bar = self.m_expBar;
    --bar:setCurValue(exp / exp_max * 100,false);
    self.m_exp_bar_bg:addChild(bar,10,10);
    --第一部分m_reward_node_1——end

    --先不显示这两部分，然后判断是否有该奖励start
    self.m_reward_node_2 = ccbNode:nodeForName("m_reward_node_2")--送卡
    self.m_reward_node_3 = ccbNode:nodeForName("m_reward_node_3")--奖励
    self.m_reward_node_4 = ccbNode:nodeForName("m_reward_node_4")--抢夺
    self.m_reward_node_4:setVisible(false);
    self.m_lost_node = ccbNode:nodeForName("m_lost_node")
    self.m_reward_node_2:setVisible(false);
    self.m_reward_node_3:setVisible(false);
    self.m_reward_node_1:setVisible(false);
    self.m_lost_node:setVisible(false);
    -----------------------------------end
    -----战斗胜利结束后调用------animEndCallFunc--start
    local battleType = game_data:getBattleType();
    local function animEndCallFunc(animName)
        if self.m_battle_result < 5 then
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
                local id = game_guide_controller:getIdByTeam("3");
                if id == 301 then
                    game_guide_controller:gameGuide("show","3",302,{tempNode = ccbNode:controlButtonForName("m_main_btn_3")})
                else
                    local id2 = game_guide_controller:getIdByTeam("5");
                    if id2 == 501 then
                        game_guide_controller:gameGuide("show","5",502,{tempNode = ccbNode:controlButtonForName("m_main_btn_3")})
                    else
                        if battleType == "map_building_detail_scene" and self.m_next_step ~= -1 then
                            self:autoBattleFunc();
                        end
                    end
                end
                if battleType == "game_ability_commander_snatch" then
                    self:abilityCommanderSnatch();
                end
            elseif animName == "loop_anim" then
                ccbNode:runAnimations("loop_anim")
            end
        else
            self.m_mask_layer:setTouchEnabled(false);
            if game_data:getReMapBattleFlag() == false and battleType == "map_building_detail_scene" then -- "10201" 战斗失败后新手引导
                local cardNumData = game_data:getBattleCardNumData()
                local position_num = math.min(cardNumData.position_num,5)
                local teamData = game_data:getTeamData();
                -- cclog("position_num === " .. position_num .. " ;game_data:getCurrentFightId() == " .. game_data:getCurrentFightId() .. " ; teamData[1] == " .. teamData[1] .. " ; teamData[3] == " .. teamData[3] .. " ;teamData[4] == " .. teamData[4])
                if position_num > 2 and game_data:getCurrentFightId() == "10201" and teamData[1] ~= "-1" and teamData[3] == "-1" and teamData[4] ~= "-1" then
                    game_guide_controller:setFormationGuideIndex(1);
                    game_scene:addGuidePop({tempNode = ccbNode:controlButtonForName("m_main_btn_3")})
                end
            end
            if battleType == "game_ability_commander_snatch" then
                self:abilityCommanderSnatch();
            end
        end
    end
    -----战斗胜利结束后调用------animEndCallFunc--end

    if self.m_battle_result < 5 then--战斗胜利
        cclog("registerAnimFunc animEndCallFunc -----------------------")
        self.m_reward_node_1:setVisible(true);
    else
        game_sound:playUiSound("battle_failed" .. math.random(1,2))
        bar:setCurValue(exp / exp_max * 100,false);
        if battleType ~= "game_ability_commander_snatch" then
            self.m_lost_node:setVisible(true);
        end
    end
    if battleType == "game_world_boss" then
        self.m_gain_node_bg:setVisible(false);
        self.m_boss_node:setVisible(true);
        self.m_lost_node:setVisible(false);
        self.m_total_hurt_label:setString(tostring(self.m_tGameData.hurt or 0))
        local reward = self.m_tGameData.reward
        local arena_point = reward.arena_point 
        self.arena_count_label:setString("×" .. arena_point)
    elseif battleType == "game_pk" then--竞技场 胜利
        if self.m_battle_result < 5 then--战斗胜利
            self.m_gain_node_bg:setVisible(false);
            self.m_arena_node:setVisible(true);
            self.m_lost_node:setVisible(false);
            self.m_arena_rank_label:setString(tostring(self.m_tGameData.cur_rank or 0))
        end
    else
        self.m_boss_node:setVisible(false);
    end
    ccbNode:registerAnimFunc(animEndCallFunc)
    ccbNode:runAnimations("enter_anim")
    self.m_atrr_up_btn = ccbNode:controlButtonForName("m_atrr_up_btn")
    self.m_equip_up_btn = ccbNode:controlButtonForName("m_equip_up_btn")
    self.m_skill_up_btn = ccbNode:controlButtonForName("m_skill_up_btn")
    self.m_retreat_btn = ccbNode:controlButtonForName("m_retreat_btn")
    self.m_atrr_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_equip_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_skill_up_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_retreat_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    
    local m_btn_node = ccbNode:nodeForName("m_btn_node")
    local btn = nil;
    local selCityId = tostring(game_data:getSelCityId())
    local tempId = game_guide_controller:getCurrentId();
    cclog("tempId ===================================== " .. tempId)
    local tempFlag = (battleType == "game_first_opening" or tempId == 7 or tempId == 8 or tempId == 28 or (selCityId == "101" and game_data:getReMapBattleFlag() == false))
    for i = 1,3 do
        btn = ccbNode:controlButtonForName("m_main_btn_" .. i)
        game_util:setControlButtonTitleBMFont(btn)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        if tempFlag and (i == 1 or i == 2) then
            btn:setColor(ccc3(151,151,151));
            btn:setTouchEnabled(false);
            if tempId == 8 and i == 1 then
                -- game_guide_controller:gameGuide("show","1",10,{tempNode = btn});
                game_guide_controller:gameGuide("send","1",10);
            end
        end
        -- if i == 1 then
        --     btn:setColor(ccc3(151,151,151));
        --     btn:setTouchEnabled(false);
        -- end
    end
    -- btn = tolua.cast(self.m_root_layer:getChildByTag(3),"CCControlButton");
    -- if battleType == "game_first_opening" then
    --     self.returnType = 1;
    -- end
    -- if(self.returnType == 0) then
    --     game_util:setCCControlButtonTitle(btn,"下一场")
    -- else
    --     game_util:setCCControlButtonTitle(btn,"完成")
    -- end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:removeCountdownLabel();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);    
    self.m_mask_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_mask_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end


--[[
    
]]
function battle_over_pop.abilityCommanderSnatch(self)
    local tempData = game_data:getCommanderRecipeData();
    if tempData.itemId == nil then return true end
    local ccbNode = self.m_ccbNode;
    self.m_reward_node_4:setVisible(true);
    local m_item_snatch_spri = ccbNode:spriteForName("m_item_snatch_spri")--
    local m_item_light_spri = ccbNode:spriteForName("m_item_light_spri")--
    local m_gain_item_label = ccbNode:labelTTFForName("m_gain_item_label") 

    local reward = self.m_tGameData.reward or {}
    local rewardItem = reward.item or {}
    if #rewardItem > 0 then--抢夺成功
        m_item_snatch_spri:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zdjs_wenzi_1.png"));
        m_item_light_spri:setVisible(true);
        
        local tempIcon,tempName = game_util:createItemIconByCid(rewardItem[1]);
        if tempIcon then
            local tempSize = m_item_light_spri:getContentSize();
            tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
            m_item_light_spri:addChild(tempIcon,-1)
        end
        if tempName then
            m_gain_item_label:setString(tempName)
        else
            m_gain_item_label:setString("道具名称")
        end
    else--抢夺失败
        m_item_snatch_spri:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zdjs_wenzi_2.png"));
        m_item_light_spri:setVisible(false);
    end
end

--[[
    
]]
function battle_over_pop.removeCountdownLabel(self)
    if self.m_countdownLabel then
        self.m_countdownLabel:removeFromParentAndCleanup(true);
        self.m_countdownLabel = nil;
    end
end

--[[
    自动下一场战斗倒计时
]]
function battle_over_pop.autoBattleFunc(self)
    cclog("battle_over_pop.autoBattleFunc---------------------------")
    local function timeOverCallFun(label,type)
        self:removeCountdownLabel();
        if self.m_callFunc then
            self.m_callFunc(3);
        end
    end
    self.m_countdownLabel = game_util:createCountdownLabel(5,timeOverCallFun,12,2)
    self.m_countdownLabel:setScale(1.1)
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    self.m_countdownLabel:setPosition(ccp(visibleSize.width*0.87, visibleSize.height*0.32))
    self.m_ccbNode:addChild(self.m_countdownLabel,10,10)
end
--[[----
    战斗胜利 
]]
function battle_over_pop.playerWin(self)
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
               self:playerShowCardExp(); 
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

--[[----
    卡牌经验
]]
function battle_over_pop.playerShowCardExp(self)
        local bar = self.m_expBar;
        local ccbNode = self.m_ccbNode;
        local battle_rewards = self.m_tGameData.battle_rewards
        if battle_rewards == nil then 
            cclog("battle_rewards == nil")
            return 
        end
        local reward_exp_character = battle_rewards.reward_exp_character or {};
        local reward_exp_character_count = game_util:getTableLen(reward_exp_character)
        if reward_exp_character_count == 0 then
            self:showRewardCharacter();
            return;
        end
        --显示战斗英雄的经验等
        local function getShowCardDataByIndex(index,step)
            local lv,oldExp,currExp,maxExp,levelFlag;
            local exp_character_item = reward_exp_character[tostring(self.m_AtkData[index].data_id)]
            if exp_character_item and #exp_character_item == 3 then
                local add_exp = exp_character_item[1]
                oldExp = exp_character_item[2]
                local add_exp_temp = exp_character_item[3]
                local add_exp_temp_count = #add_exp_temp
                if step < add_exp_temp_count then
                    local add_exp_item = add_exp_temp[step+1]
                    lv = add_exp_item[1]
                    maxExp = add_exp_item[2]
                    if add_exp_temp_count == 1 then
                        currExp = add_exp + oldExp;
                        levelFlag = false;
                    elseif add_exp_temp_count > 1 then
                        if step == 0 then
                            currExp = maxExp;
                            levelFlag = true;
                        elseif step < (add_exp_temp_count - 1) then
                            currExp = maxExp;
                            oldExp = 0;
                            levelFlag = true;
                        elseif step == (add_exp_temp_count - 1) then
                            currExp = add_exp + oldExp;
                            cclog("add_exp ============" .. add_exp .. " ; oldExp ==" .. oldExp .. " ; currExp ==" .. currExp)
                            for i = 1,add_exp_temp_count - 1 do
                                add_exp_item = add_exp_temp[i]
                                currExp = currExp - add_exp_item[2]
                                cclog("currExp ======================" .. currExp .. " ; add_exp_item[2] = " .. add_exp_item[2])
                            end
                            oldExp = 0;
                            levelFlag = false;
                        end
                    end
                end
            end
            return lv,oldExp,currExp,maxExp,levelFlag;
        end

        -- 显示战斗英雄的经验等
        local function heroExpAnim()
            self.m_reward_node_2:setVisible(true)
            cclog("heroExpAnim =================================");
            local cardItemTab = {};
            local function barSchedulerAndActions(pauseFlag)
                if pauseFlag then
                    for k,v in pairs(cardItemTab) do
                        v.heroExpBar:pause()
                    end
                else
                    for k,v in pairs(cardItemTab) do
                        v.heroExpBar:resume()
                    end
                end
            end

            local indexTemp = 0;
            local function playerHeroExpAnimEnd(extBar)
                cclog("playerHeroExpAnimEnd->"..indexTemp)
                local posIndex = extBar:getTag();
                local cardItemTab = cardItemTab[posIndex]
                if cardItemTab then
                    cardItemTab.currentStep = cardItemTab.currentStep + 1;
                    local lv,oldExp,currExp,maxExp,levelFlag = getShowCardDataByIndex(posIndex,cardItemTab.currentStep)
                    if lv then
                        -- cclog("posIndex ==" .. posIndex .. " ; levelFlag ====" .. tostring(levelFlag) .. " ; currentStep = " .. cardItemTab.currentStep)
                        --cclog("lv,oldExp,currExp,maxExp,levelFlag = " .. lv .. ";" .. oldExp .. ";" .. currExp .. ";" .. maxExp .. ";" .. tostring(levelFlag))
                        local function callBackFunc()
                            local heroExpBar = cardItemTab.heroExpBar;
                            heroExpBar:setMaxValue(maxExp);
                            heroExpBar:setCurValue(oldExp,false);
                            heroExpBar:setCurValue(currExp,true);
                            cardItemTab.levelFlag = levelFlag
                            cardItemTab.lvLabel:setString("Lv."..tostring(lv));
                            barSchedulerAndActions(false)
                        end
                        -- if cardItemTab.levelFlag then
                            -- barSchedulerAndActions(true)
                            -- game_scene:getPopContainer():addChild(game_util:createBattleHeroLevelUpByCCB(callBackFunc,cardItemTab.cardId,lv))
                        -- else
                            game_util:addTipsAnimByType(cardItemTab.itemBg,4);                        
                            callBackFunc();
                        -- end
                    else
                        indexTemp = indexTemp - 1;
                    end
                else
                    indexTemp = indexTemp - 1;
                end
                if indexTemp == 0 then
                    self:showRewardCharacter();
                end
            end

            local itemConfig = nil;
            local itemBg = nil;
            local headIconSpr = nil;
            local heroExpBar = nil;
            local showIndex = 1;

            for i = 1,8 do
                itemBg = ccbNode:spriteForName("m_card_" .. i)
                itemBg:setVisible(false)
                if self.m_AtkData[i] ~= nil and self.m_AtkData[i].card_id then
                    itemBg = ccbNode:spriteForName("m_card_" .. showIndex)
                    itemBg:setVisible(true)
                    -- cclog("self.m_AtkData[" .. i .. "] ==========card_id = " .. self.m_AtkData[i].card_id .. " ; data_id = " .. self.m_AtkData[i].data_id .. " ; exp ===" .. self.m_AtkData[i].exp);
                    indexTemp = indexTemp + 1;
                    local headIconSprSize = itemBg:getContentSize();
                    itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(self.m_AtkData[i].card_id);
                    headIconSpr = game_util:createIconByName(itemConfig:getNodeWithKey("img"):toStr());
                    if headIconSpr then
                        headIconSpr:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                        headIconSpr:setScale(headIconSprSize.width/headIconSpr:getContentSize().width);
                        itemBg:addChild(headIconSpr,-1);
                    end
                    local lv,oldExp,currExp,maxExp,levelFlag = getShowCardDataByIndex(i,0)
                    cclog("lv,oldExp,currExp,maxExp,levelFlag = " .. lv .. ";" .. oldExp .. ";" .. currExp .. ";" .. maxExp .. ";" .. tostring(levelFlag))
                    if lv then
                        heroExpBar = ExtProgressTime:createWithFrameName("o_public_skillExpBg.png","o_public_skillExp.png");
                        heroExpBar:setAnchorPoint(ccp(0.5,0.5));
                        heroExpBar:setPosition(ccp(headIconSprSize.width*0.5,-headIconSprSize.height * 0.1));
                        heroExpBar:setMaxValue(maxExp);
                        heroExpBar:registerScriptBarHandler(playerHeroExpAnimEnd);
                        heroExpBar:setCurValue(oldExp,false);
                        heroExpBar:setCurValue(currExp,true);
                        heroExpBar:setTag(i);
                        itemBg:addChild(heroExpBar);
                        local label_temp = game_util:createLabel({text = "Lv."..lv}) --CCLabelTTF:create("Lv."..lv,TYPE_FACE_TABLE.Arial_BoldMT,12);
                        label_temp:setAnchorPoint(ccp(0,0.5));
                        -- label_temp:setColor(ccc3(255,255,255));
                        label_temp:setPosition(ccp(0,headIconSprSize.height * 0.1));
                        itemBg:addChild(label_temp,0,10);
                        cardItemTab[i] = {heroExpBar = heroExpBar,lvLabel = label_temp,currentStep = 0,levelFlag=levelFlag,cardId = self.m_AtkData[i].data_id,itemBg = itemBg}
                    end
                    showIndex = showIndex + 1;
                end
                if i == 5 then 
                    showIndex = 6 
                end
            end
        end 
        heroExpAnim();
end

--[[----
    卡牌奖励
]]
function battle_over_pop.showRewardCharacter(self)
        local bar = self.m_expBar;
        local ccbNode = self.m_ccbNode;
        local battle_rewards = self.m_tGameData.battle_rewards
        if battle_rewards == nil then 
            cclog("battle_rewards == nil")
            return 
        end
        local reward_character = battle_rewards.reward_character or {}
        local reward_character_count = game_util:getTableLen(reward_character)
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
            local characterName = nil;
            local posIndex = 1;
            for k,reward_character_item in pairs(reward_character) do
                headIconSpr = ccbNode:spriteForName("m_props_" .. posIndex)
                if headIconSpr then
                    c_id = reward_character_item.c_id;
                    itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(c_id);
                    img = itemConfig:getNodeWithKey("img"):toStr();
                    characterName = itemConfig:getNodeWithKey("name"):toStr();
                    cclog("characterName img->"..img)
                    cclog("characterName->"..characterName)
                    local headIconSprSize = headIconSpr:getContentSize();
                    local icon = game_util:createIconByName(img);
                    headIconSpr:setDisplayFrame(icon:displayFrame());
                    -- headIconSpr:setScale(headIconSprSize.width / 64);
                    headIconSpr:setColor(ccc3(0,0,0));
                    local label_temp = CCLabelTTF:create(tostring(characterName),TYPE_FACE_TABLE.Arial_BoldMT,10);
                    label_temp:setPosition(ccp(headIconSprSize.width * 0.5,headIconSprSize.height * 0.5));
                    headIconSpr:addChild(label_temp,0,10);
                    label_temp:setVisible(false)
                    local function objectReset( node )
                        --headIconSpr:setColor(ccc3(255,255,255));
                        local sprite = tolua.cast(node,"CCSprite");
                        sprite:setColor(ccc3(255,255,255));

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
            for i = posIndex,5 do
                headIconSpr = ccbNode:spriteForName("m_props_" .. i)
                headIconSpr:setVisible(false)
            end
        end
        showRewardCharacter();
end

--[[----
    刷新ui
]]
function battle_over_pop.refreshUi(self)

end

--[[----
    初始化
]]
function battle_over_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = t_params.gameData or {};
    self.m_AtkData = {};
    if self.m_tGameData and self.m_tGameData.battle then
        self.m_AtkData = self.m_tGameData.battle.init.atk or {};
        self.m_godgiftTab = self.m_tGameData.godgift or {};
        self.m_next_step = self.m_tGameData.next_step or 0
    end
    self.m_callFunc = t_params.callFunc;
    self.returnType = t_params.returnType;
    -- cclog(json.encode(self.m_AtkData))
    for k,v in pairs(self.m_AtkData) do
        if type(v) == "table" and v["id"] then
            -- cclog("v[\"id\"] ======================== " .. tostring(v["id"]))
            local valueTab = util.stringSplit(tostring(v["id"]),"_");
            v.data_id = valueTab[2];
        else
            self.m_AtkData[k] = {};
        end
    end
    self.m_requestFlag  = false;
end

--[[----
    创建ui入口并初始化数据
]]
function battle_over_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return battle_over_pop;