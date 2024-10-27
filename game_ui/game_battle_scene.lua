
---  战斗

local game_battle_scene = {
    m_gameData = nil,           --数据
    m_tGameData = nil,
    m_battleInitData = nil,     -- 战斗初始化数据table
    m_ccbNode = nil,            -- ccbNode节点
    m_AtkData = nil,            -- 攻方数据
    m_AtkFormation = nil,       -- 攻方阵容
    m_DfdData = nil,            -- 守方数据
    m_DfdFormation = nil,       -- 守方阵容
    m_AtkAnims = {},            -- 攻方动画
    m_DfdAnims = {},            -- 守方动画
    m_tempNode = {},            -- 代替位置节点
    m_sortData = {},            -- 排序信息
    m_BattleData = nil,         -- 战斗信息
    m_enterId = nil,            -- 计时器句柄
    m_canGo = 0,                -- 可以出手标记
    m_scale = 0.9,              -- 动画缩放比例
    m_realPos = nil,            -- 攻击后返回的初始位置
    m_pos = nil,                -- 真正攻击的位置
    m_currentAttackTable= nil,     -- 当前攻击对象
    m_currentHitTable = {},    --当前受击对象表
    m_curtentAnimLabelName = nil,--当前阶段名称
    m_battle_background_layer = nil, --战斗背景层
    m_battle_down_layer = nil,       --战斗下层
    m_battle_layer = nil,       --战斗层
    m_battle_up_layer = nil,       --战斗上层
    m_top_layer = nil,          --所有元素上层
    m_round_label = nil,        --战斗轮数
    m_currentFrameData = nil,   --当前frame数据
    m_btn_node = nil,           --按钮节点
    m_arrow_node = nil,         
    m_deadRef = 0,
    m_speedTable = nil,         --战斗中人物速度列表
    speedBarParent = nil,       --显示人物速度父节点
    m_buffAnimTable = nil,      --buff动画表格
    m_debutRef=nil,             --登场动画计数
    m_currentFrameId = nil,     --当前current frame index
    m_cityId = nil,             --当前正在收复的城市
    m_buildingId = nil,         --当前正在收复的建筑
    m_next_step = nil,          --当前关卡
    m_battle_result = nil,      --战斗结果
    m_hero_table = nil,         --主角表
    m_currentRound = nil,       --出手回合
    m_colorLayer = nil,         --白屏效果层
    m_deathRef = nil,           --死亡计数引用
    m_battleCount = nil,
    m_stage_name_label = nil,
    m_stage_label = nil,
    m_stageTableData = nil,
    m_speed1_btn = nil,
    m_speed_btn = nil,
    m_atk_role = nil,           --左侧主角ID
    m_dfd_role = nil,           --右侧主角ID
    m_atk_skill = nil,          --左侧主角技能ID
    m_dfd_skill = nil,          --右侧主角技能ID
    m_atk_lv = nil,             --主角级别
    m_dfd_lv = nil,             --敌人级别
    m_atk_name = nil,           --主角名字
    m_dfd_name = nil,           --敌人名字
    skillLayerTable = {},       --主角技能层表
    skillIconTable = {},        --主角技能icon表
    skillFrameTable = {},       --主角技能边框表
    m_hero_bg = nil,
    m_hero_half = nil,
    m_skill_lable = nil,
    m_hero_bg_R = nil,
    m_hero_half_R = nil,
    m_skill_lable_R = nil,

    m_animAtkNodeTable = nil, --关卡战斗中前一屏获得动画表(进攻方)
    m_animDefNodeTable = nil, --关卡战斗中前一屏获得动画表(防守方)

    m_animCounter = {},         -- 临时动画数据存储

    m_attacked = {},            -- 已出手纪录
    m_backGroundName = nil,        --背景

    m_hard_regain = nil,
    m_clickFlag = nil,
    m_guideBattleType = nil,  -- 特殊的战斗类型，第一场战斗等
    isNext = nil,
    lastScore = nil,
};

local self = game_battle_scene;
local formationPosTab = {{key = "position_a",x = 0.33,y = 0.5 },
                         {key = "position_b",x = 0.28,y = 0.35},
                         {key = "position_c",x = 0.23,y = 0.2 },
                         {key = "position_d",x = 0.18, y = 0.5 },
                         {key = "position_e",x = 0.13,y = 0.35},
                         {key = "position_f",x = 0.08, y = 0.2 }};

function game_battle_scene.destroy(self)
    -- body
    cclog("-----------------game_battle_scene destroy-----------------");
    if self.m_gameData ~= nil then
        self.m_gameData:delete();
        self.m_gameData = nil;
    end
    self.m_tGameData = nil;
    if self.m_enterId ~= nil then
        cclog("-----------------CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);-----------------");
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);
        self.m_enterId = nil;
    end
    self.m_ccbNode = nil;           -- ccbNode节点
    self.m_AtkData = nil;           -- 攻方数据
    self.m_AtkFormation = nil;      -- 攻方阵容
    self.m_DfdData = nil;           -- 守方数据
    self.m_DfdFormation = nil;      -- 守方阵容
    self.m_AtkAnims = {};           -- 攻方动画
    self.m_DfdAnims = {};           -- 守方动画
    self.m_tempNode = {};           -- 代替位置节点
    self.m_sortData = {};           -- 排序信息
    self.m_BattleData = nil;        -- 战斗信息
    self.m_canGo = 0;               -- 可以出手标记
    self.m_scale = 1.0;             -- 动画缩放比例
    self.m_realPos = nil;             -- 攻击后返回的初始位置
    self.m_pos = nil;
    self.m_currentAttackTable = nil;--当前攻击
    self.m_currentHitTable = nil;   --当前受击
    self.m_curtentAnimLabelName = nil;--当前阶段
    self.m_battle_background_layer = nil; --战斗背景层
    self.m_battle_down_layer = nil;       --战斗下层
    self.m_battle_layer = nil;      --战斗层
    self.m_battle_up_layer = nil;       --战斗上层
    self.m_round_label = nil; 
    -- public_config.action_rythm = 1.0;--速率
    public_config.battleTickPause = false;--暂停标记
    public_config.action_durition = public_config.action_durition_temp * public_config.action_rythm;
    self.m_currentFrameData = nil;--当前frame数据
    self.m_btn_node = nil;--按钮节点
    self.m_arrow_node = nil;
    self.m_deadIndex = nil;
    self.m_speedTable = nil;
    self.speedBarParent = nil;
    self.m_buffAnimTable = nil;
    self.m_debutRef = nil;
    self.m_currentFrameId = nil;
    self.m_cityId = nil;
    self.m_buildingId = nil;
    self.m_next_step = nil;
    self.m_battle_result = nil;
    self.m_hero_table = nil;
    self.m_currentRound = nil;
    self.m_colorLayer = nil;
    self.m_deathRef = nil;
    -- self.m_battleCount = nil;
    self.m_stage_name_label = nil;
    self.m_stage_label = nil;
    self.m_stageTableData = nil;
    self.m_animAtkNodeTable = nil;
    self.m_animDefNodeTable = nil;
    self.m_speed1_btn = nil;
    self.m_speed_btn = nil;
    self.m_atk_role = nil;
    self.m_dfd_role = nil;
    self.m_atk_skill = nil;
    self.m_dfd_skill = nil;
    self.m_atk_lv = nil;
    self.m_dfd_lv = nil;
    self.m_hero_bg = nil
    self.m_hero_half = nil
    self.m_skill_lable = nil
    self.m_hero_bg_R = nil
    self.m_hero_half_R = nil
    self.m_skill_lable_R = nil
    self.m_atk_name = nil;
    self.m_dfd_name = nil;
    self.killLayerTable = {};
    self.skillIconTable = {};
    self.skillFrameTable = {};
    self.m_backGroundName = nil;
    self.m_hard_regain = nil;
    self.m_clickFlag = nil;
    self.m_guideBattleType = nil;
    self.isNext = nil;
    self.lastScore = nil;
end
--[[--
    返回
]]
function game_battle_scene.back(self,type)
    local battleType = game_data:getBattleType();
    if battleType == "map_building_detail_scene" then
        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            local tempData = gameData:getNodeWithKey("data")
            local showDataTips = self:getTipsDataToShow(tempData:getFormatBuffer())
            -- if ((self.m_cityId ~= nil and self.m_buildingId ~= nil) and self.m_next_step ~= -1) or self.m_battle_result > 5 then
            --     game_scene:enterGameUi("map_building_detail_scene",{cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,gameData = gameData});
            -- else
                local is_recaptured = self.m_tGameData.is_recaptured;
                local hard_recapture = self.m_tGameData.curt_regain
                if self.m_battle_result < 5 then -- and not game_data:getReMapBattleFlag() 
                    local reward = self.m_tGameData.reward
                    game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,recoverBuildingId = self.m_buildingId,
                        buildingId = self.m_buildingId,is_recaptured = is_recaptured,reward=reward, showDataTips = showDataTips, hard_recapture = hard_recapture});
                -- else
                --     game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,recoverBuildingId = self.m_buildingId,buildingId = self.m_buildingId,is_recaptured = is_recaptured});
                end
            -- end
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = self.m_cityId},"private_city_open")
    elseif battleType == "game_neutral_city_map" or battleType == "game_neutral_building_detail_pop" then
        local city_id = game_data:getSelNeutralCityId();
        local function responseMethod(tag,gameData)
            local reward = self.m_tGameData.reward or {}
            game_data:setSelNeutralCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_neutral_city_map",{gameData = gameData,city_id = city_id});
            game_util:rewardTipsByDataTable(reward);
            self:destroy();
        end
        -- 公共地图，打开城市 city_id=10001
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_open"), http_request_method.GET, {city_id = city_id},"public_city_open")
    elseif battleType == "game_pk" then
        local function responseMethod(tag,gameData)
            -- game_scene:enterGameUi("game_pk",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            self:destroy();
        end
        --  nil
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
    elseif battleType == "game_first_opening" then
        local function sendRequestFunc()
            local function responseMethod(tag,gameData)
                if gameData then
                    game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                    game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,bgMusic = "background_singapo"});
                    self:destroy();
                else
                    game_util:closeAlertView();
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            sendRequestFunc();
                            game_util:closeAlertView();
                        end,   --可缺省
                        closeCallBack = function(target,event)
                            game_util:closeAlertView();
                            exitGame();
                        end,
                        okBtnText = string_helper.game_battle_scene.reDownLoad,       --可缺省
                        text = string_helper.game_battle_scene.data_fail,      --可缺省
                    }
                    game_util:openAlertView(t_params);
                end
            end
            local params = {}
            params.city = "100"
            params.chapter = "1";
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open",true,true);
        end
        sendRequestFunc();
        -- game_scene:enterGameUi("create_role_scene",{});
    elseif battleType == "active_map_building_detail_scene" then--活动地图
        local activeChapterId = game_data:getSelActiveDataByKey("activeChapterId")
        local activeId = game_data:getSelActiveDataByKey("activeId");
        if (self.m_next_step ~= -1) or self.m_battle_result > 5 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_data:setDataByKeyAndValue("map_fight_and_enemy",json.decode(data:getFormatBuffer()));
                game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = activeChapterId,activeId = activeId,next_step = self.m_next_step});
                self:destroy();
            end
            local params = {chapter = activeChapterId,active_id = activeId,step_n = self.m_next_step}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_map_fight_and_enemy"), http_request_method.GET, params,"active_map_fight_and_enemy")
        else
            local reward = self.m_tGameData.reward;
            game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                 -- game_data:setActiveDataByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("index"));
                cclog("reward == " .. json.encode(reward))
                game_util:rewardTipsByDataTable(reward);
                game_data_statistics:finishActive({activeId = activeId})
                self:destroy();
            end});
        end
    elseif battleType == "game_world_boss" then
        local function responseMethod(tag,gameData)
            local reward = self.m_tGameData.reward or {}
            local data = gameData:getNodeWithKey("data")
            local boss_info = data:getNodeWithKey("boss_info");

            cclog("boss_info == " ..boss_info:getFormatBuffer())
            if boss_info:getNodeCount() == 0 then   
                game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                    game_util:addMoveTips({text = string_helper.game_battle_scene.giant_active_end});
                    game_util:rewardTipsByDataTable(reward);
                    self:destroy()
                end});
            else
                game_scene:enterGameUi("game_world_boss",{gameData = gameData})
                game_util:rewardTipsByDataTable(reward);
                self:destroy()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
    elseif battleType == "game_guild_boss" then--工会boss
        local function responseMethod(tag,gameData)
            local reward = self.m_tGameData.reward or {}
            local data = gameData:getNodeWithKey("data")
            local boss_info = data:getNodeWithKey("boss_info");
            if boss_info:getNodeCount() == 0 then
                --活动结束，回到公会
                game_scene:setVisibleBroadcastNode(false);
                local association_id = game_data:getUserStatusDataByKey("association_id");
                if association_id == 0 then
                    require("like_oo.oo_controlBase"):openView("guild_join");
                    game_util:rewardTipsByDataTable(reward);
                else
                    require("like_oo.oo_controlBase"):openView("guild");
                end
            else
                local function callBackFunc()
                    self:destroy();
                    static_rootControl = nil;
                end
                game_scene:enterGameUi("game_guild_boss",{gameData = gameData})
                game_util:rewardTipsByDataTable(reward);
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guildboss_index"), http_request_method.GET, nil,"guildboss_index")
    elseif battleType == "game_activity_live" then
        local function responseMethod(tag,gameData)
            local reward = self.m_tGameData.reward or {}
            cclog("reward == " .. json.encode(reward))
            local data = gameData:getNodeWithKey("data")
            local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
            game_scene:enterGameUi("game_activity_live",{liveData = live_data})
            game_util:rewardTipsByDataTable(reward);
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    elseif battleType == "game_ability_commander_snatch" then
        local tempData = game_data:getCommanderRecipeData();
        -- local function responseMethod(tag,gameData)
            local reward = self.m_tGameData.reward or {}
            local rewardItem = reward.item or {}
            if #rewardItem > 0 or tempData.itemId == nil then
                -- if not game_button_open:checkButtonOpen(606) then
                --     return
                -- end
                local function responseMethod(tag,gameData)
                    if game_data:getDataByKey("m_commander_type") == "game_item_commander" then
                        game_scene:enterGameUi("game_item_commander",{gameData = gameData,recipeId = tempData.recipeId});
                    else
                        game_scene:enterGameUi("game_ability_commander",{gameData = gameData,recipeId = tempData.recipeId});
                    end
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index")
            else
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_ability_commander_snatch",{gameData = gameData,recipeId = tempData.recipeId,itemId = tempData.itemId});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_search"), http_request_method.GET, {item_id=tempData.itemId},"commander_search")
            end
            -- game_util:rewardTipsByDataTable(reward);
            -- self:destroy();
        -- end
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index")    
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end

function game_battle_scene.setInitState(self)
    self.m_btn_node:setPositionY(-25);
    self.m_arrow_node:getParent():setPositionY(-88);
end

--[[--
    更新主角技能信息
]]--
function game_battle_scene.updateHeroSkillInfo(self,tempTable)
    if(tempTable.cdindex >= tempTable.cdcount) then
        tempTable.cdindex = tempTable.cdcount
        tempTable.countLable:setString("")
        tempTable.progress:setPercentage(0)
    elseif(tempTable.cdindex == 0) then
        tempTable.countLable:setString(""..tempTable.cdcount)
        tempTable.progress:setPercentage(100)
    else
        local round = tempTable.cdcount - tempTable.cdindex
        tempTable.countLable:setString(""..round)
        tempTable.progress:setPercentage(round / tempTable.cdcount * 100)
    end
end

--[[--
    清空主角技能
]]--
function game_battle_scene.cleanHeroSkill(self)
   for i = 1,3 do
        if(self.m_atk_skill[i]) then
            local tempTable = self.m_atk_skill[i]
            tempTable.cdindex = 0
            tempTable.cdcount = tempTable.ready_time
            tempTable.isOnce = false
            self:updateHeroSkillInfo(tempTable)
        end
        if(self.m_dfd_skill[i]) then
            local tempTable = self.m_dfd_skill[i]
            tempTable.cdindex = 0
            tempTable.cdcount = tempTable.ready_time
            tempTable.isOnce = false
            self:updateHeroSkillInfo(tempTable)
        end
    end
end

--[[--
    使用主角技能
]]--
function game_battle_scene.useHeroSkill(self,skillid,camp)
    --cclog("useHeroSkill_skillid->"..skillid)
    --cclog("useHeroSkill_camp->"..camp)
    if(camp == 1) then
        for i = 1,3 do
            if(self.m_atk_skill[i] and self.m_atk_skill[i].id == skillid) then
                local tempTable = self.m_atk_skill[i]
                tempTable.cdindex = 0
                tempTable.cdcount = tempTable.cd
                tempTable.isOnce = true
                self:updateHeroSkillInfo(tempTable)
            end
        end
    else
        for i = 1,3 do
            if(self.m_dfd_skill[i] and self.m_dfd_skill[i].id == skillid) then
                local tempTable = self.m_dfd_skill[i]
                tempTable.cdindex = 0
                tempTable.cdcount = tempTable.cd
                tempTable.isOnce = true
                self:updateHeroSkillInfo(tempTable)
            end
        end
    end 
end

--[[--
    每轮攻击结束后更新主角技能
]]--
function game_battle_scene.refreshHeroSkill()
    if(self.m_atk_role ~= 0) then
        for i = 1,3 do
            if(self.m_atk_skill[i]) then
                local tempTable = self.m_atk_skill[i]
                if(tempTable.isOnce) then
                    tempTable.isOnce = false
                elseif(tempTable.cdindex < tempTable.cdcount) then
                    tempTable.cdindex = tempTable.cdindex + 1
                    self:updateHeroSkillInfo(tempTable)
                end
            end
        end
    end
    if(self.m_dfd_role ~= 0) then
        for i = 1,3 do
            if(self.m_dfd_skill[i]) then
                local tempTable = self.m_dfd_skill[i]
                if(tempTable.isOnce) then
                    tempTable.isOnce = false
                elseif(tempTable.cdindex < tempTable.cdcount) then
                    tempTable.cdindex = tempTable.cdindex + 1
                    self:updateHeroSkillInfo(tempTable)
                end
            end
        end
    end
end

--[[--
    读取cbbi,初始化ui
]]
function game_battle_scene.createUi(self)
    -- body
    self.m_ccbNode = luaCCBNode:create();

    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then --暂停
            if public_config.battleTickPause == true then
                public_config.battleTickPause = false;
                CCDirector:sharedDirector():resume();
            else
                public_config.battleTickPause = true;
                CCDirector:sharedDirector():pause();
            end
        elseif btnTag == 2 then
            local level = game_data:getUserStatusDataByKey("level") or 0
            if level < 7 then
                game_util:addMoveTips({text = string_helper.game_battle_scene.text});
                return
            end
            self.m_speed_btn:setVisible(false)
            self.m_speed_btn:setEnabled(false)
            function btnenable()
                self.m_speed1_btn:setVisible(true)
                self.m_speed1_btn:setEnabled(true)
            end
            performWithDelay(self.m_speed_btn,btnenable,0.1)
            public_config.action_rythm = 0.1;
            -- game_util:setCCControlButtonTitle(self.m_speed1_btn,"")
            game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal11.png");
            -- game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal2.png");
            self:setAnimAccelerate(public_config.action_rythm);
            public_config.action_durition = public_config.action_durition_temp * public_config.action_rythm;
            cclog("public_config.action_durition =====================" .. public_config.action_durition);
        elseif btnTag == 4 then--加速
            if public_config.action_rythm == 0.1 then
            --     local level = game_data:getUserStatusDataByKey("level") or 0
            --     if level < 20 then
            --         game_util:addMoveTips({text = "20级开启3倍加速！"});
            --         return
            --     end
            --     public_config.action_rythm = 0.1;
            --     game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal2.png");
            -- else
                self.m_speed1_btn:setVisible(false)
                self.m_speed1_btn:setEnabled(false)
                function btnenable()
                    self.m_speed_btn:setVisible(true)
                    self.m_speed_btn:setEnabled(true)
                end
                performWithDelay(self.m_speed1_btn,btnenable,0.1)
                public_config.action_rythm = 0.5;
            end
            -- game_util:setCCControlButtonTitle(self.m_speed1_btn,"")
            self:setAnimAccelerate(public_config.action_rythm);
            public_config.action_durition = public_config.action_durition_temp * public_config.action_rythm;
            cclog("public_config.action_durition =====================" .. public_config.action_durition);
        elseif btnTag == 3 then--跳过
            if self.m_clickFlag == true then
                return;
            end
            self.m_clickFlag = true;
            public_config.battleTickPause = true;
            self.m_battle_layer:stopAllActions();
            if self.m_enterId ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);
                self.m_enterId = nil;
            end
            self:showBattleOverPop();
        else
            self:battleOverBtnClick(btnTag,event)
        end
    end
    self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local scrollView = nil;
    local rootLayerSize = nil;
    local arrowSpr = nil;
    local m_speedBarBtn = nil;
    -- local m_speedBottom = nil;
    local m_speedBarBtnX,m_speedBarBtnY,m_speedBottomX,m_speedBottomY,m_arrow_nodeX,m_arrow_nodeY
    local battleType = game_data:getBattleType();
    self.m_ccbNode:openCCBFile("ccb/ui_game_battle.ccbi");

    self.m_top_layer = CCLayer:create();
    self.m_ccbNode:addChild(self.m_top_layer,10,10);
    --战斗背景图
    self.m_battle_background_layer = self.m_ccbNode:layerForName("m_battle_bg")
    self.m_battle_down_layer = self.m_ccbNode:layerForName("m_battle_down_layer")
    self.m_battle_layer = self.m_ccbNode:layerColorForName("m_battle_layer")
    self.m_battle_up_layer = self.m_ccbNode:layerForName("m_battle_up_layer")
    self.m_round_label = self.m_ccbNode:labelTTFForName("m_round_label")
    self.m_btn_node = self.m_ccbNode:nodeForName("m_btn_node")
    self.m_arrow_node = self.m_ccbNode:nodeForName("m_arrow_node")
    self.m_stage_name_label = self.m_ccbNode:labelTTFForName("m_stage_name_label")
    self.m_stage_label = self.m_ccbNode:labelTTFForName("m_stage_label")
    self.m_speed1_btn = self.m_ccbNode:controlButtonForName("m_speed1_btn")
    self.m_speed_btn = self.m_ccbNode:controlButtonForName("m_speed_btn")
    self.m_hero_icon = self.m_ccbNode:layerForName("m_hero_icon")
    self.m_hero_icon:removeAllChildrenWithCleanup(true);
    self.m_enimy_icon = self.m_ccbNode:layerForName("m_enimy_icon")
    self.m_enimy_icon:removeAllChildrenWithCleanup(true);
    self.m_hero_bg = self.m_ccbNode:spriteForName("hero_bg")
    self.m_hero_half = self.m_ccbNode:spriteForName("hero_half")
    self.m_skill_lable = self.m_ccbNode:spriteForName("skill_lable")
    self.m_hero_bg_R = self.m_ccbNode:spriteForName("hero_bg_R")
    self.m_hero_half_R = self.m_ccbNode:spriteForName("hero_half_R")
    self.m_skill_lable_R = self.m_ccbNode:spriteForName("skill_lable_R")
    self.m_atkLayer = self.m_ccbNode:layerForName("m_atkLayer")
    self.m_dfdLayer = self.m_ccbNode:layerForName("m_dfdLayer")
    self.skillLayerTable = {}
    self.skillLayerTable[1] = self.m_ccbNode:layerForName("m_skillLayer11")
    self.skillLayerTable[2] = self.m_ccbNode:layerForName("m_skillLayer12")
    self.skillLayerTable[3] = self.m_ccbNode:layerForName("m_skillLayer13")
    self.skillLayerTable[4] = self.m_ccbNode:layerForName("m_skillLayer21")
    self.skillLayerTable[5] = self.m_ccbNode:layerForName("m_skillLayer22")
    self.skillLayerTable[6] = self.m_ccbNode:layerForName("m_skillLayer23")
    self.skillIconTable = {}
    self.skillIconTable[1] = self.m_ccbNode:layerForName("m_skillIcon11")
    self.skillIconTable[2] = self.m_ccbNode:layerForName("m_skillIcon12")
    self.skillIconTable[3] = self.m_ccbNode:layerForName("m_skillIcon13")
    self.skillIconTable[4] = self.m_ccbNode:layerForName("m_skillIcon21")
    self.skillIconTable[5] = self.m_ccbNode:layerForName("m_skillIcon22")
    self.skillIconTable[6] = self.m_ccbNode:layerForName("m_skillIcon23")
    self.skillFrameTable = {}
    self.skillFrameTable[1] = self.m_ccbNode:layerForName("m_skillkuang11")
    self.skillFrameTable[2] = self.m_ccbNode:layerForName("m_skillkuang12")
    self.skillFrameTable[3] = self.m_ccbNode:layerForName("m_skillkuang13")
    self.skillFrameTable[4] = self.m_ccbNode:layerForName("m_skillkuang21")
    self.skillFrameTable[5] = self.m_ccbNode:layerForName("m_skillkuang22")
    self.skillFrameTable[6] = self.m_ccbNode:layerForName("m_skillkuang23")
    for i = 1,6 do
        self.skillFrameTable[i]:setVisible(false)
    end
    local m_power_icon_1 = self.m_ccbNode:nodeForName("m_power_icon_1");
    local m_power_icon_2 = self.m_ccbNode:nodeForName("m_power_icon_2");
    local m_bar_node_bg_1 = self.m_ccbNode:nodeForName("m_bar_node_bg_1");
    local m_bar_node_bg_2 = self.m_ccbNode:nodeForName("m_bar_node_bg_2");
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    if role_detail_cfg then
        local itemCfg;
        local iconName;
        local tempSpr;
        if(self.m_atk_role == 0) then
            self.m_atkLayer:setVisible(false)
            self.skillLayerTable[1]:setVisible(false)
            self.skillLayerTable[2]:setVisible(false)
            self.skillLayerTable[3]:setVisible(false)
        else
            itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_atk_role));
            tempSpr = game_util:createPlayerIconByCfg(itemCfg); --game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
            if tempSpr then
                tempSpr:setPosition(ccp(31,29))
                self.m_hero_icon:addChild(tempSpr);
            end
            local skillCount = 0;
            for i = 1,3 do
                if(self.m_atk_skill[i]) then
                    skillCount = skillCount + 1;
                    local tempTable = self.m_atk_skill[i]
                    local tempIcon = game_util:createLeaderSkillIconByCid(tempTable.id,nil,true) --game_util:createIconByName(tempTable.icon);
                    if tempIcon then
                        tempIcon:setScale(0.5)
                        tempIcon:setPosition(ccp(15,15))
                        self.skillIconTable[i]:addChild(tempIcon)
                    end
                    local timeShader = CCSprite:createWithSpriteFrameName("skillShade.png")
                    local progress = CCProgressTimer:create(timeShader)
                    if(tempTable.cdcount == 0) then
                        progress:setPercentage(0)
                    else
                        progress:setPercentage(100)--(tempTable.cdcount - tempTable.cdindex) / tempTable.cdcount)
                    end
                    progress:setScale(0.6)
                    progress:setPosition(ccp(15,15))
                    tempTable.progress = progress
                    self.skillIconTable[i]:addChild(progress)
                    local countLable = CCLabelTTF:create("", "Helvetica", 14)
                    countLable:setColor(ccc3(255,255,255))
                    --countLable:enableStroke(ccc3(0,0,0),1)
                    if(tempTable.cdcount ~= 0) then
                        countLable:setString(tempTable.cdcount)
                    end
                    countLable:setPosition(ccp(15,15))
                    self.skillIconTable[i]:addChild(countLable)
                    tempTable.countLable = countLable
                else
                    self.skillLayerTable[i]:setVisible(false)
                end
            end
            if skillCount == 0 then
                m_power_icon_1:setVisible(false);
                m_bar_node_bg_1:setVisible(false);
            end
        end
        if(self.m_dfd_role == 0) then
            self.m_dfdLayer:setVisible(false)
            self.skillLayerTable[4]:setVisible(false)
            self.skillLayerTable[5]:setVisible(false)
            self.skillLayerTable[6]:setVisible(false)
        else
            itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_dfd_role));
            tempSpr = game_util:createPlayerIconByCfg(itemCfg)--game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
            if tempSpr then
               tempSpr:setPosition(ccp(31,29))
               tempSpr:setFlipX(true)
               self.m_enimy_icon:addChild(tempSpr);
            end
            local skillCount = 0;
            for i = 1,3 do
                if(self.m_dfd_skill[i]) then
                    skillCount = skillCount + 1
                    local tempTable = self.m_dfd_skill[i]
                    local tempIcon = game_util:createLeaderSkillIconByCid(tempTable.id,nil,true)--game_util:createIconByName(tempTable.icon);
                    if tempIcon then
                        tempIcon:setScale(0.5)
                        tempIcon:setPosition(ccp(15,15))
                        self.skillIconTable[i + 3]:addChild(tempIcon)
                    end
                    local timeShader = CCSprite:createWithSpriteFrameName("skillShade.png")
                    local progress = CCProgressTimer:create(timeShader)
                    if(tempTable.cdcount == 0) then
                        progress:setPercentage(0)
                    else
                        progress:setPercentage(100)--(tempTable.cdcount - tempTable.cdindex) / tempTable.cdcount)
                    end
                    progress:setScale(0.6)
                    progress:setPosition(ccp(15,15))
                    tempTable.progress = progress
                    self.skillIconTable[i + 3]:addChild(progress)
                    local countLable = CCLabelTTF:create("", "Helvetica", 14)
                    countLable:setColor(ccc3(255,255,255))
                    --countLable:enableStroke(ccc3(0,0,0),1)
                    if(tempTable.cdcount ~= 0) then
                        countLable:setString(tempTable.cdcount)
                    end
                    countLable:setPosition(ccp(15,15))
                    self.skillIconTable[i + 3]:addChild(countLable)
                    tempTable.countLable = countLable
                else
                    self.skillLayerTable[i + 3]:setVisible(false)
                end
            end
            if skillCount == 0 then
                m_power_icon_2:setVisible(false);
                m_bar_node_bg_2:setVisible(false);
            end
        end
    end
    -- if public_config.action_rythm == 1 then
    if public_config.action_rythm == 0.5 then
        self.m_speed_btn:setVisible(true)
        self.m_speed_btn:setEnabled(true)
        self.m_speed1_btn:setVisible(false)
        self.m_speed1_btn:setEnabled(false)
    else
        self.m_speed_btn:setVisible(false)
        self.m_speed_btn:setEnabled(false)
        self.m_speed1_btn:setVisible(true)
        self.m_speed1_btn:setEnabled(true)
        -- if public_config.action_rythm == 0.5 then
        --     -- game_util:setCCControlButtonTitle(self.m_speed1_btn,"")
        --     game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal11.png");
        -- elseif public_config.action_rythm == 0.1 then
        --     -- game_util:setCCControlButtonTitle(self.m_speed1_btn,"")
        --     game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal2.png");
        -- end
        if public_config.action_rythm == 0.1 then
            game_util:setCCControlButtonBackground(self.m_speed1_btn,"btnSpeedNormal11.png");
        end
    end
    -- game_util:setControlButtonTitleBMFont(self.m_speed_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_speed1_btn)
    local level = game_data:getUserStatusDataByKey("level") or 0
    if level < 7 then
        self.m_speed_btn:setColor(ccc3(155, 155, 155))
    end
    local skipNode = self.m_btn_node:getChildByTag(3);
    local tempId = game_guide_controller:getCurrentId();
    cclog("############################################# tempId = " .. tempId)
    if tempId == 7 or tempId == 8 then
        game_guide_controller:sendGuideData("1",8)
    end
    if (game_data:getReMapBattleFlag() and battleType == "map_building_detail_scene") or battleType == "game_pk" or (battleType == "game_ability_commander_snatch") or (battleType == "game_activity_live")  then
        -- self.m_btn_node:setVisible(false)
        skipNode:setVisible(true);
    elseif tempId == 1 or tempId == 7 or tempId == 8 then
        skipNode:setVisible(true)
    else
        if self.m_battleCount == 0 and battleType ~= "active_map_building_detail_scene" and battleType ~= "escort_battle_replay" and not (game_data:getMapType() == "hard" and battleType == "map_building_detail_scene") then
            skipNode = tolua.cast(skipNode, "CCControlButton")
            skipNode:setColor(ccc3(155, 155, 155))
            skipNode:setVisible(true);
            skipNode:setEnabled(false)
            skipNode:addChild(CCNode:create(), 0, 10001)
        end
    end

    self.m_arrow_node:getParent():reorderChild(self.m_arrow_node,100);
    m_speedBarBtn = self.m_ccbNode:controlButtonForName("m_speedBarBtn");
    self.m_round_label:setString(string_helper.game_battle_scene.attack_stage);
    local m_root_layer = self.m_ccbNode:layerForName("m_root_layer");
    local winSize = CCDirector:sharedDirector():getWinSize();
    if self.m_backGroundName == nil then
        self.m_backGroundName = "back_feixu";
    end
    cclog("self.m_backGroundName ========================= " .. self.m_backGroundName)
    local battleBGSp = CCSprite:create("battle_ground/" .. self.m_backGroundName .. ".jpg")
    if battleBGSp == nil then
        battleBGSp = CCSprite:create("battle_ground/" .. self.m_backGroundName .. ".png")
    end
    if battleBGSp then
        self.m_battle_background_layer:addChild(battleBGSp)
        battleBGSp:setPosition(ccp(winSize.width / 2,winSize.height / 2))
    end
    ------------------------怒气条---------------------
    local bar = ExtProgressTime:createWithFrameName("powBarBg.png","powBar.png");
    bar:setCurValue(0,false);
    m_bar_node_bg_1:addChild(bar);
    self.m_hero_table = {};
    self.m_hero_table[1] = {};
    self.m_hero_table[1][1] = bar;

    bar = ExtProgressTime:createWithFrameName("powBarBg.png","powBar.png");
    bar:setPosition(ccp(bar:getContentSize().width,0))
    bar:setCurValue(0,false);
    bar:setScaleX(-1);
    m_bar_node_bg_2:addChild(bar);
    self.m_hero_table[2] = {};
    self.m_hero_table[2][1] = bar;
    ---------------------------------------------------
    ----------------------出手顺序表--------------------
    rootLayerSize = m_root_layer:getContentSize();
    m_arrow_nodeX,m_arrow_nodeY = rootLayerSize.width*0.525,self.m_arrow_node:getPositionY();
    self.m_arrow_node:setPositionX(m_arrow_nodeX);
    self.speedBarParent = CCLayer:create()
    self.speedBarParent:setContentSize(CCSizeMake(rootLayerSize.width * 0.95,rootLayerSize.height * 0.1));
    self.speedBarParent:ignoreAnchorPointForPosition(false);
    self.speedBarParent:setAnchorPoint(ccp(0.5,0.5));
    local itemBgSize = self.speedBarParent:getContentSize();

    scrollView = CCScrollView:create(CCSizeMake(rootLayerSize.width,rootLayerSize.height*0.2));
    scrollView:setTouchEnabled(false);
    scrollView:setViewSize(CCSizeMake(rootLayerSize.width*0.5,rootLayerSize.height*0.2));
    scrollView:addChild(self.speedBarParent);
    scrollView:setViewSize(CCSizeMake(rootLayerSize.width,rootLayerSize.height*0.2));
    self.m_arrow_node:getParent():addChild(scrollView);
    self.speedBarParent:setPosition(ccp(0,5));
    --self.m_arrow_node:setPositionX(rootLayerSize.width*0.97);
    --self.m_arrow_node:setPositionY(-88);
    ---------------------------------------------------

    self.m_colorLayer = CCLayerColor:create(ccc4(255,255,255,0),winSize.width,winSize.height);
    self.m_ccbNode:addChild(self.m_colorLayer,1000);

    local m_own_name_label = self.m_ccbNode:labelTTFForName("m_own_name_label")
    local m_own_lv_label = self.m_ccbNode:labelTTFForName("m_own_lv_label")
    local m_enemy_name_label = self.m_ccbNode:labelTTFForName("m_enemy_name_label")
    local m_enemy_lv_label = self.m_ccbNode:labelTTFForName("m_enemy_lv_label")

    m_own_name_label:setString(tostring(self.m_atk_name));
    m_own_lv_label:setString(tostring(self.m_atk_lv))
    m_enemy_name_label:setString(tostring(self.m_dfd_name));
    m_enemy_lv_label:setString(tostring(self.m_dfd_lv))
    return self.m_ccbNode;
end
--[[--
    创建出手顺序的节点
]]
function game_battle_scene.createActionNode(self,pos,tag,scale)
    local itemNode = CCNode:create();
    itemNode:setPosition(pos);
    if scale ~= nil and type(scale) == "number" then
        itemNode:setScale(scale);
    end
    local headIconSpr = game_util:createIconByName("icon_naruto");
    headIconSpr:setVisible(false);
    itemNode:addChild(headIconSpr,1,1);
    --zhcj_diren.png  zhcj_zijidekuang.png
    local bgFileName = nil;
    local randValue = math.random(1,2);
    if math.floor(randValue) == 1 then
        bgFileName = "enemy.png";
    else
        bgFileName = "oneself.png";
    end
    local headIconTypeSpr = CCSprite:createWithSpriteFrameName(bgFileName);
    itemNode:addChild(headIconTypeSpr,2,2);
    return itemNode;
end

--[[--
    刷新ui
]]
function game_battle_scene.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_battle_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if tolua.type(t_params.gameData) == "util_json" then
        self.m_battleCount = 0;
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()); 
    else
        self.m_battleCount = self.m_battleCount + 1;
        self.m_tGameData = t_params.gameData;
    end
    self.m_battleInitData = self.m_tGameData.battle.init;
    local data = self.m_tGameData;
    self.m_backGroundName = t_params.backGroundName
    self.m_buildingId = data.building or t_params.buildingId;
    self.m_next_step = data.next_step or t_params.next_step;
    self.m_cityId = data.city or t_params.cityId;
    self.isNext = t_params.isNext or false
    self.lastScore = t_params.lastScore or 0

    self.m_next_step = self.m_next_step or -1;
    local battle = data.battle;
    self.m_battle_result = battle.winer or 100;

    local jnode_init = battle.init
    self.m_AtkFormation = jnode_init.aform or 1;
    self.m_DfdFormation = jnode_init.dform or 1;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local formationConfig = getConfig(game_config_field.formation);
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_AtkFormation));
    local tempTag = 1;
    for i = 1,#formationPosTab do
        local formationPosTabItem = formationPosTab[i];
        local iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
        if iValue ~= 0 and tempTag < 6 then
            self.m_tempNode[tempTag] = {m_x = winSize.width * formationPosTabItem.x,m_y = winSize.height * formationPosTabItem.y};
            tempTag = tempTag +1;
        end
    end
    for i=#self.m_tempNode + 1,5 do
        self.m_tempNode[i] = {m_x = winSize.width * 0.1,m_y = winSize.height * 0.5};
    end
    local itemCfg = formationConfig:getNodeWithKey(tostring(self.m_DfdFormation));
    local tempTag = 1;
    for i=1,#formationPosTab do
        local formationPosTabItem = formationPosTab[i];
        local iValue = itemCfg:getNodeWithKey(formationPosTabItem.key):toInt();
        if iValue ~= 0 and tempTag < 6 then
            self.m_tempNode[tempTag + 5] = {m_x = winSize.width * (1 - formationPosTabItem.x),m_y = winSize.height * formationPosTabItem.y};
            tempTag = tempTag +1;
        end 
    end
    for i=#self.m_tempNode + 1,10 do
        self.m_tempNode[i] = {m_x = winSize.width * 0.9,m_y = winSize.height * 0.5};
    end

    local jnode_sort = jnode_init.sort_array
    self.m_sortData = {}
    if(jnode_sort ~= nil) then
        local sort_count = #jnode_sort
        for i = 1,sort_count do
            local jnode_param = jnode_sort[i]
            local nodeCount = #jnode_param
            local objecttable = {};
            for j = 1,nodeCount do
                objecttable[jnode_param[j]] = j;
                --cclog("sort_array->i->"..i.." j->"..j.." v->"..jnode_param[j])
            end
            self.m_sortData[i] = objecttable
        end
    end

    local jnode_dData = jnode_init.dfd
    local jnode_aData = jnode_init.atk
    self.m_AtkData = {};
    self.m_DfdData = {};
    local tempTab = {};


    --角色ID
    self.m_atk_role = jnode_init.atk_role
    self.m_dfd_role = jnode_init.dfd_role
    --角色名字
    self.m_atk_name = jnode_init.atk_name
    self.m_dfd_name = jnode_init.dfd_name
    --cclog("self.m_atk_name->"..tostring(self.m_atk_name))
    --cclog("self.m_dfd_name->"..tostring(self.m_dfd_name))
    ----------------------------------------------------------------
    --角色级别
    self.m_atk_lv = jnode_init.atk_lv
    self.m_dfd_lv = jnode_init.dfd_lv
    --cclog("self.m_atk_lv->"..tostring(self.m_atk_lv))
    --cclog("self.m_dfd_lv->"..tostring(self.m_dfd_lv))
    ----------------------------------------------------------------
    --技能ID数组
    self.m_atk_skill = {};
    self.m_dfd_skill = {};
    local temp_atk_skill = jnode_init.atk_skill
    local temp_dfd_skill = jnode_init.dfd_skill
    local skill_detail_cfg = getConfig(game_config_field.leader_skill);
    local itemCfg
    for i = 1,3 do
        local tempTable = {}
        tempTable.id = temp_atk_skill[i]
        if(tempTable.id > 0) then
            itemCfg = skill_detail_cfg:getNodeWithKey(tostring(tempTable.id));
            tempTable.icon = itemCfg:getNodeWithKey("icon"):toStr();
            tempTable.cd   = itemCfg:getNodeWithKey("cd"):toInt();
            tempTable.ready_time = itemCfg:getNodeWithKey("ready_time"):toInt();
            tempTable.cdcount = tempTable.ready_time
            tempTable.cdindex = 0
            tempTable.isOnce = false
            tempTable.progress = nil
            tempTable.index = i--在数组中的索引
            local index = #self.m_atk_skill + 1
            self.m_atk_skill[index] = tempTable;
        end
        tempTable = {}
        tempTable.id = temp_dfd_skill[i]
        if(tempTable.id > 0) then
            itemCfg = skill_detail_cfg:getNodeWithKey(tostring(tempTable.id));
            tempTable.icon = itemCfg:getNodeWithKey("icon"):toStr();
            tempTable.cd   = itemCfg:getNodeWithKey("cd"):toInt();
            tempTable.ready_time = itemCfg:getNodeWithKey("ready_time"):toInt();
            tempTable.cdcount = tempTable.ready_time
            tempTable.cdindex = 0
            tempTable.isOnce = false
            tempTable.progress = nil
            tempTable.index = i
            local index = #self.m_dfd_skill + 1
            self.m_dfd_skill[index] = tempTable;
        end
    end

    --解析排序数据
    for i = 1,10 do
        local tempANode = jnode_aData[i]
        if type(tempANode) == "table" and tempANode.card_id then
            self.m_AtkData[i] = tempANode;
        end
        local tempDNode = jnode_dData[i]
        if type(tempDNode) == "table" and tempDNode.card_id then
            self.m_DfdData[i] = tempDNode;
        end
    end

    -- 战斗数据
    self.m_BattleData = battle.battle or {};
    self.m_clickFlag = false;
end

function game_battle_scene.createBattleStep(self,t_params,step,isretain)
    --if(step == 1) then 
    game_sound:playMusic("background_battle" .. math.random(1,3),true);
    -- game_sound:playMusic("background_battle1",true);
    self:init(t_params);
    --elseif(step == 2) then
    self:createUi();
    --[[--if(isretain == nil) then
        self.m_ccbNode:retain()
    end]]--
    --elseif(step == 3) then
    self.m_stageTableData = t_params.stageTableData
    self.m_stage_label:setString("")
    if self.m_stageTableData then
        cclog("self.m_stageTableData.fight_boss *********************** " .. tostring(self.m_stageTableData.fight_boss))
        self.m_stage_name_label:setString(self.m_stageTableData.name)
        -- self.m_stage_label:setString("STAGE     " ..  self.m_stageTableData.step .. "/" .. self.m_stageTableData.totalStep)
    else
        self.m_stage_name_label:setString(string_helper.game_battle_scene.start_flight)
        -- self.m_stage_label:setString("STAGE     " .. "--/--")
    end
    --elseif(step == 4) then
    self:refreshUi();
    -- self.m_battleCount = 0;
    self:initStartBattle();
    --elseif(step == 5) then
    self:checkChain();
    self:start();
    --self:setCanGo(true,"enter_anim_2");
    --public_config.battleTickPause = false
    local function animEndCallFunc(animName)
        if animName == "enter_anim" then
            self.m_ccbNode:runAnimations("enter_anim_22")
        elseif animName == "enter_anim_22" then
            print("runanimation from enter_anim_22")
            self:setCanGo(true,"enter_anim_22");
            public_config.battleTickPause = false;
            self:skipBtnAnim();
        end
    end
    self.m_ccbNode:registerAnimFunc(animEndCallFunc)
    self.m_arrow_node:setVisible(false);
    self.m_arrow_node:setPositionY(-88);
    return self.m_ccbNode;
    --end
end

--[[--
    
]]
function game_battle_scene.skipBtnAnim(self)
    local skipNode = tolua.cast(self.m_btn_node:getChildByTag(3),"CCControlButton")

    if skipNode:getChildByTag(10001) then
        skipNode:removeChildByTag(10001, true)
        local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
        local time = 25
        if vipLevel > 0 then
            time = 10
        end
        local function timeOverCallFun(label,type)
            skipNode:setEnabled(true)
            skipNode:setColor(ccc3(255, 255, 255))
            skipNode:removeChildByTag(10000, true)
        end
        local timeLabel = game_util:createCountdownLabel(tonumber(time) ,timeOverCallFun,8, 2)
        -- timeLabel:setFontSize(12.00)
        local size = skipNode:getContentSize()
        timeLabel:setAnchorPoint(ccp( 0.5, 0 ))
        timeLabel:setPosition(size.width * 0.5, size.height)
        skipNode:addChild(timeLabel, 100, 10000)
        timeLabel:setScale(14/12.0)
        timeLabel:setColor(ccc3(255, 255, 0))
    end
    if skipNode:isVisible() and skipNode:isEnabled() then
        local skipFlag = CCUserDefault:sharedUserDefault():getBoolForKey("skipFlag");
        if skipFlag == nil or skipFlag == false then
            CCUserDefault:sharedUserDefault():setBoolForKey("skipFlag",true);
            CCUserDefault:sharedUserDefault():flush();
            game_util:createPulseAnmi("nextNormal2.png",skipNode)
        end
    end
end

--[[--
    解析战斗数据
]]
function game_battle_scene.create(self,t_params,step,animAtkNodeTable,animDefNodeTable)
    self.m_animAtkNodeTable = animAtkNodeTable or {};
    self.m_animDefNodeTable = animDefNodeTable or {};
    --if(step == nil) then
        --[[--for i = 1,4 do
            self:createBattleStep(t_params,i,false)
        end]]--
    return self:createBattleStep(t_params)
    --[[--elseif(step == 5) then
       return self:createBattleStep(t_params,step)
    else
       self:createBattleStep(t_params,step)
    end]]--
end

--[[--
    打印战场上的卡牌
]]
function game_battle_scene.printAnimNode(self)
    cclog("-------------- game_battle_scene.printAnimNode -------------------");
    table.foreach(self.m_AtkAnims,function(k,v)
        cclog("self.m_AtkAnims   ========= k = " .. tostring(k) .. " ; v = " .. tostring(v));
    end);
    table.foreach(self.m_DfdAnims,function(k,v)
        cclog("self.m_DfdAnims   --------- k = " .. tostring(k) .. " ; v = " .. tostring(v));
    end);
end

--[[--
    卡牌动作暂停
]]

function game_battle_scene.pauseAnim(self,pauseFlag,currentAnim)
    table.foreach(self.m_AtkAnims,function(k,v)
        if v.animNode ~= currentAnim then
            if pauseFlag then
                v.animNode:pause();
            else
                v.animNode:resume();
            end
        end
    end);
    table.foreach(self.m_DfdAnims,function(k,v)
        if v.animNode ~= currentAnim then
            if pauseFlag then
                v.animNode:pause();
            else
                v.animNode:resume();
            end
        end
    end);
end
--[[--
    加速方法
]]
function game_battle_scene.setAnimAccelerate(self,rhythm)
    table.foreach(self.m_AtkAnims,function(k,v)
        v.animNode:setRhythm(rhythm);
    end);
    table.foreach(self.m_DfdAnims,function(k,v)
        v.animNode:setRhythm(rhythm);
    end);
end

function game_battle_scene.objectDead(self,theId)
    
    local enemy_object_tab
    if(theId < 5)then
        enemy_object_tab = self.m_animCounter[tostring(theId)];
        if(enemy_object_tab == nil)then
            enemy_object_tab = self.m_AtkAnims[theId + 1]
        end
    else
        enemy_object_tab = self.m_animCounter[tostring(theId)];
        if(enemy_object_tab == nil)then
            enemy_object_tab = self.m_DfdAnims[theId - 99]
        end
    end
    if(enemy_object_tab == nil) then
        return
    end
    cclog("before objectDead->" .. tostring(theId) .. " deathRef->" .. tostring(enemy_object_tab.deathRef));
    enemy_object_tab.deathRef = enemy_object_tab.deathRef - 1;
    cclog("objectDead->"..tostring(theId) .. " deathRef->" .. tostring(enemy_object_tab.deathRef));
    -- game_util:isPlayTheAction(lableName,anim_label_name_cfg.siwang)
    if(enemy_object_tab.deathRef <= 0 or not game_util:isPlayTheAction(enemy_object_tab.animNode:getCurSectionName(),anim_label_name_cfg.siwang)) then
        cclog("enemy_object_tab.deathRef <= 0  theId: " .. tostring(theId) .. " ;animation is " .. enemy_object_tab.animNode:getCurSectionName());

        --enemy_object_tab.animNode:getParent():removeFromParentAndCleanup(true);
        enemy_object_tab.animNode:removeFromParentAndCleanup(true);
        if(theId < 5)then
            if(self.m_animCounter[tostring(theId)] ~= nil)then
                self.m_animCounter[tostring(theId)] = nil;
            else
                self.m_AtkAnims[theId + 1] = nil;
            end
        else
            if(self.m_animCounter[tostring(theId)] ~= nil)then
                self.m_animCounter[tostring(theId)] = nil;
            else
                self.m_DfdAnims[theId - 99] = nil;
            end
        end
        self.m_deathRef = self.m_deathRef - 1;
        cclog("self.m_deathRef death is over------------------------------" .. self.m_deathRef)
        -- if self.m_deathRef == 0 then
        --     self:setCanGo(true,"objectDead--------")
        -- end
    end
end

--[[--
    强制清除一个角色
]]
-- function game_battle_scene:removeAnimAndData( theId )
--     -- body
-- end

--[[--
    卡牌动作回调
]]
function game_battle_scene.animEnd(node,theId,lableName)
        -- body
        local state
        local tempAnims
        if(theId < 5) then
            tempAnims = self.m_AtkAnims[theId + 1];
        else
            tempAnims = self.m_DfdAnims[theId - 99];
        end
        if(tempAnims ~= nil) then
            state = tempAnims.aniState
        end
        if(state == nil) then
            state = 0
        end
        --cclog("##############打印动画结束名字->"..lableName)
        if(game_util:isPlayTheAction(lableName,anim_label_name_cfg.siwang))then
            cclog("##############death id  =============" .. theId);
            self:objectDead(theId)
            --[[--self.m_deathRef = self.m_deathRef - 1;
            cclog("self.m_deathRef ------------------------------" .. self.m_deathRef)
            if self.m_deathRef == 0 then
                self:setCanGo(true,"siwang anim end ------------------------------")
            end]]--
        elseif(game_util:isPlayTheAction(lableName,anim_label_name_cfg.beiji))then
            -- game_util:playSection(node,anim_label_name_cfg.daiji,state);
            self:playSection(theId,anim_label_name_cfg.daiji);
        elseif(game_util:isPlayTheAction(lableName,anim_label_name_cfg.daiji))then
            -- game_util:playSection(node,anim_label_name_cfg.daiji,state);
            self:playSection(theId,anim_label_name_cfg.daiji);
        elseif(game_util:isPlayTheAction(lableName,anim_label_name_cfg.dengchang))then
            self:setCanGo(true,"dengchang end");
            -- game_util:playSection(node,anim_label_name_cfg.daiji,state);
            self:playSection(theId,anim_label_name_cfg.daiji);
            cclog("self.m_debutRef ==========1==========" .. tostring(self.m_debutRef) .. " ; theId ===" .. tostring(theId));
            if self.m_debutRef ~= nil then
                self.m_debutRef = self.m_debutRef - 1;
                -- cclog("self.m_debutRef ========2============" .. tostring(self.m_debutRef) .. " ; theId ===" .. tostring(theId));
                if self.m_debutRef == 0 then
                    local tempFrameData = self.m_BattleData["1"]
                    if tempFrameData and tempFrameData["flag"] ~= "drama" then
                        if self.m_battleCount == 0 then
                            public_config.battleTickPause = true;
                            
                            self:setCanGo(false,"ccbNode:runAnim(enter_anim)");
                            self.m_arrow_node:setVisible(true);
                            local function callBackFunc()
                                self.m_btn_node:setPositionY(25);
                                self:setCanGo(true,"enter_anim_22");
                                public_config.battleTickPause = false;
                                self:skipBtnAnim();
                            end
                            if self.m_stageTableData and self.m_stageTableData.fight_boss  then
                                cclog("self.m_stageTableData.fight_boss ======= " .. tostring(self.m_stageTableData.fight_boss))
                                local animNode = game_util:createImgByName("image_" .. tostring(self.m_stageTableData.fight_boss),nil,false,true)
                                if animNode then
                                    local tempAnim = game_util:createEffectAnimCallBack("anim_bosschuxian",1.0,false,callBackFunc);
                                    if tempAnim then
                                        local visibleSize = CCDirector:sharedDirector():getVisibleSize();
                                        tempAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
                                        game_scene:getPopContainer():addChild(tempAnim)
                                        local tempSize = tempAnim:getContentSize();
                                        animNode:setPosition(ccp(tempSize.width*0.85, tempSize.height*0.6))
                                        tempAnim:addChild(animNode)
                                    else
                                        self.m_ccbNode:runAnimations("enter_anim")
                                    end
                                else
                                    self.m_ccbNode:runAnimations("enter_anim")
                                end
                            else
                                self.m_ccbNode:runAnimations("enter_anim")
                            end
                        else
                            public_config.battleTickPause = false;
                            self.m_btn_node:setPositionY(25);
                            -- self:setCanGo(true,"dengchang end")
                        end
                    else
                        public_config.battleTickPause = false;
                        self.m_btn_node:setPositionY(25);
                        -- self:setCanGo(true,"dengchang end")
                    end
                    -- audio.stopMusic(false);
                    -- game_sound:playMusic("battle_background",true);
                    self.m_debutRef = nil;
                end
            else
                self:setCanGo(true,"dengchang anim")
            end
        elseif(game_util:isPlayTheAction(lableName,anim_label_name_cfg.tibu))then
            -- game_util:playSection(node,anim_label_name_cfg.dengchang,state);
            self:playSection(theId,anim_label_name_cfg.dengchang);
            self:setCanGo(false,"dengchang start");
        elseif(game_util:isPlayTheAction(lableName,anim_label_name_cfg.shuaidao))then
            -- game_util:playSection(node,anim_label_name_cfg.daiji,state);
            self:playSection(theId,anim_label_name_cfg.daiji);
        else
            self:playSection(theId,lableName);
            --game_util:playSection(node,lableName,state);
        end
end
--[[--
    卡牌锚记回调方法
]]
function game_battle_scene.anchorCallFunc(animNode , mId , strValue)
    -- if self.m_currentHitTable ~= nil and self.m_currentFrameData ~= nil then
    --     local hurtValue = 0;
    --     if self.m_currentFrameData.hurt ~= nil and type(self.m_currentFrameData.hurt) == "number" then
    --         hurtValue = self.m_currentFrameData.hurt;
    --     end
    --     if self.m_curtentAnimLabelName == "attack" then
    --         self:anchorCall(strValue,self.m_currentHitTable,hurtValue);
    --     end
    -- end
    -- if animNode:getCurSectionName() == "siwang" then
    --     game_util:createEffectAnimAddToParent(animNode:getParent(),"siwangbaoxue",1);
    -- end
    if strValue == nil or strValue == "" then return end
    local firstValue = string.sub(strValue,0,1)
    if firstValue ~= "{" then return end
    local strTable = json.decode(strValue);
    if tostring(strTable.type) == "wav" then--
        local effectFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sound/attack_effect/" .. tostring(strTable.res)..".wav");
        local existFlag = util.fileIsExist(effectFileFullPath)
        -- cclog("effectFileFullPath =========" .. effectFileFullPath .. " ; existFlag === " .. tostring(existFlag));
        if existFlag == true then
            game_sound:playAttackSound(effectFileFullPath,false);
        end
    end
end
--[[--
    对锚记回调方法的数据解析
]]
function game_battle_scene.anchorCall(self,strValue,enemy_object_tab,hpValue)
    if hpValue == nil then hpValue = 0 end
    if enemy_object_tab == nil then return end
    if strValue == nil or strValue == "" then return end
    -- cclog("anchorCallFunc ; animFile = " .. enemy_object_tab.animFile .. " ; strValue = " .. strValue);
    local firstValue = string.sub(strValue,0,1)
    -- cclog("json.isEncodable(strValue) =======firstValue = " .. firstValue);
    local enemy_object = enemy_object_tab.animNode;
    if firstValue == "{" then
        local strTable = json.decode(strValue);
        if strTable.type == nil then return end
        if strTable.type == "bao" then--爆血
            local number = 1;
            if strTable.number ~= nil then
                number = math.max(1,tonumber(strTable.number));
            end
            if strTable.mode == nil then
                strTable.mode = 0;
            end
            -- cclog("hpValue ==========" .. hpValue .. " ; strTable.mode ==" .. strTable.mode);
            if hpValue ~= 0 then
                if strTable.mode == 1 then
                    game_util:createEffectAnimAddToParent(enemy_object,"shouji_1",1);
                else
                    game_util:createEffectAnimAddToParent(enemy_object,"shouji_2",1); 
                end
            end
            -- cclog("enemy_object_tab.bloodBar:getCurValue() =====" .. enemy_object_tab.bloodBar:getCurValue() .. " ; math.floor(hpValue/number)==" .. math.floor(hpValue/number));
            -- enemy_object_tab.bloodBar:setCurValue(enemy_object_tab.bloodBar:getCurValue() - math.floor(hpValue/number),false);
            cclog("----------------------this hurt all 1 " .. tostring(hpValue));
            self:hurtLable(enemy_object,-(hpValue/number),1,0);
            self:hitEffectAnchorCall(enemy_object_tab,1);
        elseif strTable.type == "shock_screen" then--
            local currentScene = game_scene:getGameScene();
            if currentScene then
                currentScene:stopAllActions();
                local arr = CCArray:create();
                arr:addObject(CCMoveTo:create(0.02,ccp(0,-20)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,0)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,-20)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,0)));
                currentScene:runAction(CCSequence:create(arr));
            end
        elseif strTable.type == "beiji" then--
            -- cclog("beiji strValue ==================" .. tostring(strValue));
            self:hitEffectAnchorCall(enemy_object_tab,strTable.mode);            
        elseif strTable.type == "baiping" then--
            self.m_colorLayer:setOpacity(255);
            self.m_colorLayer:runAction(CCFadeOut:create(0.1));
        elseif strTable.type == "wav" then--
            -- if self.m_currentAttackTable then
            local effectFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sound/attack_effect/" .. tostring(strTable.res)..".wav");
            local existFlag = util.fileIsExist(effectFileFullPath)
            -- cclog("effectFileFullPath =========" .. effectFileFullPath .. " ; existFlag === " .. tostring(existFlag));
            if existFlag == true then
                game_sound:playAttackSound(effectFileFullPath,false);
            end
            -- end
        end
    end
end

--[[--
    加入群攻效果
]]
function game_battle_scene.anchorAllCall(self,strValue,enemy_table,hp_table,effect,anchornum,anchorindex,add_table,add_hp_table,isHeroSkill,currentFrameData)
    if hp_table == nil then 
        hp_table = {0} 
    end
    cclog("------yock ----- " .. tostring(anchornum) .. " " .. tostring(anchorindex) );
    if enemy_table == nil then 
        return anchorindex
    end
    if strValue == nil or strValue == "" then 
        return anchorindex
    end
    currentFrameData = currentFrameData or {}
    local attr_hurt = currentFrameData.attr_hurt or {}
    if type(attr_hurt) == "number" then
        attr_hurt = {attr_hurt};
    end
    local attr_type = currentFrameData.attr_type or 0;
    local firstValue = string.sub(strValue,0,1)
    local enemy_count = #enemy_table
    local add_count = #add_table
    if firstValue == "{" then
        local strTable = json.decode(strValue);
        if strTable.type == nil then 
            return anchorindex
        end
        -- cclog("anchorAllCall->"..strTable.type)
        if strTable.type == "bao" then--爆血
            local number = 1;
            if strTable.number ~= nil then
                number = math.max(1,tonumber(strTable.number));
            end
            if strTable.mode == nil then
                strTable.mode = 0;
            end
            cclog("bao:enemy_count->"..enemy_count)
            if(num == nil) then
                num = 1
            end
            -- ----------------------- changed by yock
            if(isHeroSkill)then
                anchornum = number;
            end
            -- ------------------------changed by yock
            anchorindex = anchorindex + 1
            for i = 1,add_count do
                local hpValue = 0
                local hpTemp = add_hp_table[i]
                if(hpTemp == nil) then
                    hpTemp = 0
                end
                local hpValue2 = 0
                local hpTemp2 = attr_hurt[i] or 0
                if(anchornum <= 0) then
                    hpValue = hpTemp
                    hpValue2 = hpTemp2;
                else
                    
                    if(anchorindex == anchornum) then
                        hpValue = math.floor(hpTemp - (anchornum - 1) * math.floor(hpTemp / anchornum))
                        hpValue2 = math.floor(hpTemp2 - (anchornum - 1) * math.floor(hpTemp2 / anchornum))
                    elseif(anchorindex < anchornum)then
                        hpValue = math.floor(hpTemp / anchornum);
                        hpValue2 = math.floor(hpTemp2 / anchornum);
                    else
                        hpValue = 0;
                    end
                end
                local enemy_object_tab = add_table[i]
                local currentHp = enemy_object_tab.bloodBar:getCurValue();
                local tempHp = currentHp + hpValue;
                if(enemy_object_tab ~= nil and enemy_object_tab.bloodBar ~= nil) then
                    enemy_object_tab.bloodBar:setCurValue(tempHp,false);
                    cclog("----------------------this hurt all 2 " .. tostring(hpValue));
                    self:hurtLable(enemy_object_tab.animNode,tonumber(hpValue),1,0);
                    self:attrHurtLable(enemy_object_tab.animNode,tonumber(hpValue2),1,attr_type);
                    if(anchornum>0)then
                        self:hurtLableAll(enemy_object_tab.animNode,tonumber(hpValue),anchornum-anchorindex+1,1);
                    else
                        self:hurtLableAll(enemy_object_tab.animNode,tonumber(hpValue),1,1);
                    end
                end
            end
            cclog("-------hurthurthurt-------")
            for i = 1,enemy_count do
                local hpValue = 0
                local hpTemp = hp_table[i]
                if(hpTemp == nil) then
                    hpTemp = 0
                end
                local hpValue2 = 0
                local hpTemp2 = attr_hurt[i] or 0
                if(anchornum <= 0) then
                    hpValue = hpTemp
                    hpValue2 = hpTemp2;
                else
                    if(anchorindex == anchornum) then
                        hpValue = hpTemp - (anchornum - 1) * math.floor(hpTemp / anchornum)
                        hpValue2 = hpTemp2 - (anchornum - 1) * math.floor(hpTemp2 / anchornum)
                    elseif(anchorindex < anchornum)then
                        hpValue = math.floor(hpTemp / anchornum);
                        hpValue2 = math.floor(hpTemp2 / anchornum);
                    else
                        hpValue = 0;
                    end
                end
                local enemy_object_tab = enemy_table[i]
                local currentHp = enemy_object_tab.bloodBar:getCurValue();
                local tempHp = currentHp - hpValue - hpValue2;
                --cclog("currentHp->"..tempHp)
                if(enemy_object_tab ~= nil and enemy_object_tab.bloodBar ~= nil and enemy_object_tab.animNode ~= nil) then
                    enemy_object_tab.bloodBar:setCurValue(tempHp,false);
                    if hpValue ~= 0 then
                        --cclog("bao:hpValue ~= 0")
                        if(effect == nil or effect == "") then
                            if strTable.mode == 1 then
                                game_util:createEffectAnimAddToParent(enemy_object_tab.animNode,"shouji_1",1);
                            else
                                game_util:createEffectAnimAddToParent(enemy_object_tab.animNode,"shouji_2",1); 
                            end
                        else
                            game_util:createEffectAnimAddToParent(enemy_object_tab.animNode,effect,1);
                        end
                    end
                    --[[--cclog("currentHp->"..currentHp)
                    cclog("anchorindex->"..anchorindex)
                    cclog("anchornum->"..anchornum)
                    cclog("tempHp->"..tempHp)]]--
                    self:hurtLableAnchor(enemy_object_tab.animNode,-hpValue,1,0,anchorindex,anchornum);
                    self:hurtLableAll(enemy_object_tab.animNode , -hpValue , anchornum-anchorindex+1 , 1);
                    -- self:attrHurtLableAnchor(enemy_object_tab.animNode,-hpValue2,1,0,anchorindex,anchornum,attr_type);
                    self:attrHurtLableAll(enemy_object_tab.animNode , -hpValue2 , anchornum-anchorindex+1 , 1,attr_type);
                    if(anchorindex >= anchornum and tempHp <= 0) then
                        cclog("siwang")
                        -- enemy_object_tab.deathRef = 2;
                        --enemy_object_tab.animNode:registerScriptTapHandler(game_battle_scene.animEnd);
                        -- game_util:playSection(enemy_object_tab.animNode,anim_label_name_cfg.siwang,enemy_object_tab.aniState); 
                        self:playSection(enemy_object_tab.index,anim_label_name_cfg.siwang);
                    else
                        cclog("shoushang")
                        self:hitEffectAnchorCall(enemy_object_tab,1);
                    end
                    --cclog("----------------------this hurt all 3 " .. tostring(hpValue));
                end
            end
            cclog("-------kkkkkkkkkkkkk-------")
        elseif strTable.type == "shock_screen" then--
            local currentScene = game_scene:getGameScene();
            if currentScene then
                currentScene:stopAllActions();
                local arr = CCArray:create();
                arr:addObject(CCMoveTo:create(0.02,ccp(0,-20)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,0)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,-20)));
                arr:addObject(CCMoveTo:create(0.02,ccp(0,0)));
                currentScene:runAction(CCSequence:create(arr));
            end
        elseif strTable.type == "beiji" then--
            -- cclog("beiji strValue ==================" .. tostring(strValue));
            for i = 1,enemy_count do
                local enemy_object_tab = enemy_table[i]
                self:hitEffectAnchorCall(enemy_object_tab,strTable.mode);
            end            
        elseif strTable.type == "baiping" then--
            self.m_colorLayer:setOpacity(255);
            self.m_colorLayer:runAction(CCFadeOut:create(0.1));
        elseif strTable.type == "wav" then--
            -- if self.m_currentAttackTable then
                local effectFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sound/attack_effect/" .. tostring(strTable.res) .. ".wav");
                local existFlag = util.fileIsExist(effectFileFullPath)
                -- cclog("effectFileFullPath =========" .. effectFileFullPath .. " ; existFlag === " .. tostring(existFlag));
                if existFlag == true then
                    if(isHeroSkill)then
                        cclog("------------- hero skill wav " .. effectFileFullPath);
                    end
                    game_sound:playAttackSound(effectFileFullPath,false);
                else
                    cclog("----------------wav havn't " .. effectFileFullPath);
                end
            -- end
        end
    end
    return anchorindex
end


--[[--
    被攻击效果
]]
function game_battle_scene.hitEffectAnchorCall(self,enemy_object_tab,mode)
    if enemy_object_tab == nil then return end
    mode = mode or 1;
    cclog("hitEffectAnchorCall ===================mode=" .. mode)
    -- 1 代表普通被击动画 2 代表摔倒动画 3 击退   dis 代表击退的距离 4 横着打飞 5 竖着打飞
    local enemy_object = enemy_object_tab.animNode;
    if mode == 1 then
        if not game_util:isPlayTheAction(enemy_object:getCurSectionName(),anim_label_name_cfg.beiji) then
            -- game_util:playSection(enemy_object,anim_label_name_cfg.beiji,enemy_object_tab.aniState);
            self:playSection(enemy_object_tab.index,anim_label_name_cfg.beiji);
        end
    elseif mode == 2 then
        if not game_util:isPlayTheAction(enemy_object:getCurSectionName(),anim_label_name_cfg.shuaidao) then
            -- game_util:playSection(enemy_object,anim_label_name_cfg.shuaidao,enemy_object_tab.aniState);
            self:playSection(enemy_object_tab.index,anim_label_name_cfg.shuaidao);
        end
    else
        if not game_util:isPlayTheAction(enemy_object:getCurSectionName(),anim_label_name_cfg.beiji2) then
            -- game_util:playSection(enemy_object,anim_label_name_cfg.beiji2,enemy_object_tab.aniState);
            self:playSection(enemy_object_tab.index,anim_label_name_cfg.beiji2);
        end
    end
    local _,pos = self:getAnimTabAndPosByIndex(enemy_object_tab.index,0);
    local posX,posY = pos.x,pos.y;
    -- enemy_object:stopAllActions();
    enemy_object:stopActionByTag(100);
    local arr = CCArray:create();
    arr:addObject(CCMoveTo:create(0.02,ccp(posX,posY - 10)));
    arr:addObject(CCMoveTo:create(0.02,ccp(posX,posY)));
    -- arr:addObject(CCMoveTo:create(0.02,ccp(posX,posY - 10)));
    -- arr:addObject(CCMoveTo:create(0.02,ccp(posX,posY)));
    local seqAction = CCSequence:create(arr);
    seqAction:setTag(100);
    enemy_object:runAction(seqAction);
end


--[[--
    创建卡牌动画
]]
function game_battle_scene.createAnimTable(self,animFile,camp,face,showHpBar,posIndex,cardData,cardCfg,equipData,animNode)
    posIndex = posIndex or -1;
    local animTable = {};
    cclog("load anim animFile ======================" .. animFile);
    if(animNode == nil) then
       cclog("animNode == nil")
    end
    local m_iAnim = game_util:createBattleIdelAnim(animFile,posIndex,cardData,cardCfg,equipData,animNode);
    m_iAnim:registerScriptTapHandler(game_battle_scene.animEnd);
    m_iAnim:registerScriptAnchor(game_battle_scene.anchorCallFunc);
    m_iAnim:setAnchorPoint(ccp(0.5,0));
    m_iAnim:setFlipX(face);
    m_iAnim:playSection(anim_label_name_cfg.dengchang);
    self:setCanGo(false,"dengchang start in createAnimTable");
    m_iAnim:setRhythm(public_config.action_rythm);
    m_iAnim:setScale(public_config.anim_scale);
    local animSize = m_iAnim:getContentSize();
    local bar,msgLabel;
    if showHpBar == nil or showHpBar == true then
        local bgSpr = CCSprite:createWithSpriteFrameName("zd_bloodTroughBg.png");
        local bgSprSize = bgSpr:getContentSize();
        bgSpr:setPosition(animSize.width*0.5, animSize.height * 1.1);
        m_iAnim:addChild(bgSpr);
        msgLabel = CCLabelTTF:create("12",TYPE_FACE_TABLE.Arial_BoldMT,10);
        msgLabel:setPosition(bgSprSize.width*0.1, bgSprSize.height * 0.5);
        bgSpr:addChild(msgLabel);
        local barFile = "zd_bloodTroughOwn.png";
        if camp == 1 then
            barFile = "zd_bloodTroughEnemy.png";
        end
        bar = ExtProgressTime:createWithFrameName("zd_bloodTrough.png",barFile);
        -- bar:setCurValue(50,true);
        bar:setPosition(bgSprSize.width*0.2, bgSprSize.height*0.35);
        bgSpr:addChild(bar,0,99);
    end
    animTable["animNode"] = m_iAnim;
    animTable["bloodBar"] = bar;
    animTable["animFile"] = animFile;
    animTable["lvLabel"] = msgLabel;
    animTable["deathRef"] = 1;
    animTable["camp"] = posIndex < 100 and 1 or -1;
    animTable["posIndex"] = posIndex;
    return animTable;
end

function game_battle_scene.hurtLableAnchor(self,object,muV,comba,m_gid,index,num)
    cclog("game_battle_scene  function --------------------------- hurtLableAnchor");
    if object == nil then return end
    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local textHurt = nil;
    cclog("----------------this is real hurt " .. tostring(muV));
    muV = util.my_ceil(muV);
    cclog("----------------this is my_ceil " .. tostring(muV));
    if (muV == 0) then
        textHurt = CCSprite:create("MISS.png");
    elseif(muV>0) then
        -- textHurt = ExpLabelBMFont:createWithSpace(muV,"green_number.fnt",-2);
        return;
    else
        -- textHurt = ExpLabelBMFont:createWithSpace(muV,"red_number.fnt",-2);
        return;
    end
    -- if m_gid == 0 then
    --     if(muV>=0) then
    --         textHurt:setColor(ccc3(0,255,0));
    --     else
    --         textHurt:setColor(ccc3(255,0,0));
    --     end
    -- elseif m_gid == 1 then
    --     textHurt:setColor(ccc3(255,255,255));
    -- end

    if(comba == 1) then
        textHurt:setScale(1.5);
    end

    local function remove_node( node )
        -- body
        -- self:hurtLableAll(object,muV,num-index+1,comba);
        node:removeFromParentAndCleanup(true);
    end
    local offsetX = 0
    local middle = 0
    if(num % 2 == 1) then
       middle = ((num - 1) / 2 + 1);
       offsetX = (index - middle) * 75
    else
       middle = num / 2;
       offsetX = (index - middle) * 75 - 37.5
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    local tempX = w/2+math.random(-5,5);
    -- arr:addObject(CCMoveTo:create(1,ccp(w / 2 + offsetX,h + 50 + math.random(-20,20))));
    arr:addObject(CCMoveTo:create(0.05,ccp(tempX,h+30+math.random(-5,5))));
    -- arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5),CCMoveTo:create(0.5,ccp(tempX,h+50))));
    arr:addObject(remove);
    textHurt:runAction(CCSequence:create(arr));
    textHurt:setPosition(w/2,h);  
    object:addChild(textHurt,100,100);
end
--[[--
    加血或减血文本方法
]]
function game_battle_scene.hurtLable(self,object,muV,comba,m_gid)
    cclog("game_battle_scene  function --------------------------- hurtLable");
    if object == nil then return end
    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local textHurt = nil;
    -- muV = math.ceil(muV);
    cclog("----------------this is real hurt " .. tostring(muV));
    muV = util.my_ceil(muV);
    cclog("----------------this is my_ceil " .. tostring(muV));
    if (muV == 0) then
        textHurt = CCSprite:create("MISS.png");
    else
        -- if muV > 0 then
        --     textHurt = ExpLabelBMFont:createWithSpace(muV,"green_number.fnt",-2);
        -- else
        --     if muV < 1000 then
        --         textHurt = ExpLabelBMFont:createWithSpace(muV,"white_number.fnt",-2);
        --     else
        --         textHurt = ExpLabelBMFont:createWithSpace(muV,"red_number.fnt",-2);
        --     end
        -- end
        -- textHurt = ExpLabelBMFont:createWithSpace(muV,"textmap.fnt",-2);
        if(muV>0)then
            textHurt = ExpLabelBMFont:createWithSpace(muV,"green_number.fnt",-2);
        else
            textHurt = ExpLabelBMFont:createWithSpace(muV,"red_number.fnt",-2);
        end;
    end

    -- if m_gid == 0 then
    --     if(muV>=0) then
    --         textHurt:setColor(ccc3(0,255,0));
    --     else
    --         textHurt:setColor(ccc3(255,0,0));
    --     end
    --     -- textHurt:setSkewX(30);
    -- elseif m_gid == 1 then
    --     textHurt:setColor(ccc3(255,255,255));
    --     -- textHurt:setSkewX(30);
    -- end

    if(comba == 1) then
        textHurt:setScale(1.5);
    end

    local function remove_node( node )
        -- body
        -- self:hurtLableAll(object,muV,1,comba);
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    -- arr:addObject(CCMoveTo:create(1,ccp(w/2 + math.random(-20,20),h+20 + math.random(-20,20))));
    local tempX = w/2+math.random(-5,5);
    arr:addObject(CCMoveTo:create(0.05,ccp(tempX,h+40+math.random(-5,5))));
    -- arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5),CCMoveTo:create(0.5,ccp(tempX,h+20))));
    arr:addObject(remove);
    textHurt:runAction(CCSequence:create(arr));
    textHurt:setPosition(tempX,h);  
    object:addChild(textHurt,100,100);
end


-- 血量总和标签
function game_battle_scene.hurtLableAll( self,object,muV,number,comba )
    -- body
    cclog("-------------------hurtLableAll " .. tostring(number));
    if object == nil then
        return nil;
    end

    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local lab = tolua.cast(object:getChildByTag(80550),"ExpLabelBMFont");

    if( muV~=0 )then
        if(lab == nil)then
            if( muV>0 )then
                lab = ExpLabelBMFont:createWithSpace("0","green_number.fnt",-2);
            elseif( muV<0 )then
                lab = ExpLabelBMFont:createWithSpace("0","red_number.fnt",-2);
            end
            lab:setPosition(ccp(w/2,h+55));
            object:addChild( lab , 101 , 80550 );
            -- lab:setString("0");
        end

        if(comba == 1) then
            lab:setScale(1.5);
        end
        
        local num = tonumber(lab:getString());
        num = num + muV;
        lab:setString(tostring(num));
    end
    
    if( lab~=nil and number<=1 )then
        local function remove_node( node )
            -- body
            node:removeFromParentAndCleanup(true);
        end
        local remove = CCCallFuncN:create(remove_node);
        local delay = CCDelayTime:create(0.8);
        local arr = CCArray:create();
        arr:addObject(delay);
        arr:addObject(remove);
        lab:runAction(CCSequence:create(arr));
    end
    
end

----------------------------------属性伤害 start------------------------------------------
-- 黄蓝红绿
local attr_hurt_color_tab = {ccc3(255,170,27),ccc3(27,218,255),ccc3(255,64,27),ccc3(27,255,117)}

function game_battle_scene.attrHurtLableAnchor(self,object,muV,comba,m_gid,index,num,attr_type)
    cclog("game_battle_scene  function --------------------------- attrHurtLableAnchor muV = " .. tostring(muV));
    if object == nil then return end
    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local textHurt = nil;
    -- muV = util.my_ceil(muV);
    if muV >= 0 then
        return;
    end
    textHurt = ExpLabelBMFont:createWithSpace(muV,"white_number.fnt",-2);
    attr_type = attr_type or 0;
    local color = attr_hurt_color_tab[attr_type]
    if color then
        textHurt:setColor(color);
    end
    if(comba == 1) then
        textHurt:setScale(1.5);
    end

    local function remove_node( node )
        -- body
        -- self:hurtLableAll(object,muV,num-index+1,comba);
        node:removeFromParentAndCleanup(true);
    end
    local offsetX = 0
    local middle = 0
    if(num % 2 == 1) then
       middle = ((num - 1) / 2 + 1);
       offsetX = (index - middle) * 75
    else
       middle = num / 2;
       offsetX = (index - middle) * 75 - 37.5
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    local tempX = w/2+math.random(-5,5);
    -- arr:addObject(CCMoveTo:create(1,ccp(w / 2 + offsetX,h + 50 + math.random(-20,20))));
    arr:addObject(CCMoveTo:create(0.05,ccp(tempX,h+10+math.random(-5,5))));
    -- arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5),CCMoveTo:create(0.5,ccp(tempX,h+30))));
    arr:addObject(remove);
    textHurt:runAction(CCSequence:create(arr));
    textHurt:setPosition(w/2,h);  
    object:addChild(textHurt,102,102);
end

--[[--
    属性伤害
]]
function game_battle_scene.attrHurtLable(self,object,muV,comba,attr_type)
    cclog("game_battle_scene  function --------------------------- attrHurtLable muV = " .. tostring(muV));
    if object == nil then return end
    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local textHurt = nil;
    -- muV = util.my_ceil(muV);
    if muV >= 0 then
        return;
    end
    textHurt = ExpLabelBMFont:createWithSpace(muV,"white_number.fnt",-2);
    attr_type = attr_type or 0;
    local color = attr_hurt_color_tab[attr_type]
    if color then
        textHurt:setColor(color);
    end
    if(comba == 1) then
        textHurt:setScale(1.25);
    end

    local function remove_node( node )
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    -- arr:addObject(CCMoveTo:create(1,ccp(w/2 + math.random(-20,20),h+20 + math.random(-20,20))));
    local tempX = w/2+math.random(-5,5);
    arr:addObject(CCMoveTo:create(0.05,ccp(tempX,h+20+math.random(-5,5))));
    -- arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5),CCMoveTo:create(0.5,ccp(tempX,h+30))));
    arr:addObject(remove);
    textHurt:runAction(CCSequence:create(arr));
    textHurt:setPosition(tempX,h);  
    object:addChild(textHurt,102,102);
end


-- 属性伤害总和标签
function game_battle_scene.attrHurtLableAll( self,object,muV,number,comba,attr_type )
    -- body
    cclog("-------------------attrHurtLableAll " .. tostring(number) .. " ; muV = " .. tostring(muV));
    if object == nil then
        return nil;
    end
    if muV >= 0 then
        return;
    end
    local size = object:getContentSize();
    local w,h = size.width,size.height;
    local lab = tolua.cast(object:getChildByTag(80551),"ExpLabelBMFont");
    if( muV~=0 )then
        if(lab == nil)then
            lab = ExpLabelBMFont:createWithSpace("0","white_number.fnt",-2);
            lab:setPosition(ccp(w/2,h+35));
            object:addChild( lab , 103 , 80551 );
        end

        if(comba == 1) then
            lab:setScale(1.5);
        end
        local num = tonumber(lab:getString());
        num = num + muV;
        lab:setString(tostring(num));
        attr_type = attr_type or 0;
        local color = attr_hurt_color_tab[attr_type]
        if color then
            lab:setColor(color);
        end
    end
    
    if( lab~=nil and number<=1 )then
        local function remove_node( node )
            -- body
            node:removeFromParentAndCleanup(true);
        end
        local remove = CCCallFuncN:create(remove_node);
        local delay = CCDelayTime:create(0.8);
        local arr = CCArray:create();
        arr:addObject(delay);
        arr:addObject(remove);
        lab:runAction(CCSequence:create(arr));
    end
    
end

------------------------------------属性伤害 end----------------------------------------

function game_battle_scene.refreshShowSpeedTableAndUi(self)
    -- cclog("----------------------yock m_speedTable -------------------");
    -- util.printf(self.m_speedTable);
    -- cclog("-----------------------------------------------------------");
    local speedTableItemCount = table.getn(self.m_speedTable);
    local itemBgSize = self.speedBarParent:getContentSize();
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local itemWidth = visibleSize.width / 14;
    local speedNode = nil;
    local posX,posY;
    local tempPos;
    for i = 1,speedTableItemCount do
        speedNode = self.m_speedTable[i].speedNode;
        if speedNode ~= nil then
            speedNode:stopAllActions();
            posX,posY = speedNode:getPosition();
            if(i ~= 1) then
                tempPos = ccp(itemWidth * i,itemBgSize.height * 0.5);
                if not tempPos:equals(ccp(posX,posY)) then
                    speedNode:setScale(0.75);   
                end
            else
                tempPos = ccp(itemWidth  * 0.8,itemBgSize.height * 0.6);
                if not tempPos:equals(ccp(posX,posY)) then
                    speedNode:setScale(1);
                end
            end
            if(tempPos.x <= posX) then
                speedNode:runAction(CCMoveTo:create(0.3,tempPos));
            else
                speedNode:runAction(CCJumpTo:create(0.3,tempPos,50,1));
            end
        end
    end
end

function game_battle_scene.shiningIcon(self,desPosIndex,spc)
    local dexIndex = {}
    if(spc == nil) then
        cclog("shiningIcon-spc == nil")
        spc = 0
    end
    if type(desPosIndex) == "number" then
        for k,v in pairs(self.m_speedTable) do
            if v.posIndex == desPosIndex then
                dexIndex[1] = k;
                v.speed = v.speed - spc;--受攻击后减速度
            end
        end
    elseif type(desPosIndex) == "table" then
        for i = 1,#desPosIndex do
            local desPosIndexTemp = desPosIndex[i]
            for k,v in pairs(self.m_speedTable) do
                if v.posIndex == desPosIndexTemp then
                    dexIndex[i] = k;
                    v.speed = v.speed - spc;--受攻击后减速度
                end
            end
        end
    end
    if dexIndex ~= nil then
        --闪红
        cclog("dexIndex[]count->"..(#dexIndex))
        for i = 1,#dexIndex do
            local action = CCTintTo:create(0.5,255,0,0);
            local actionBack = CCTintTo:create(0.5,255,255,255);
            local animArr = CCArray:create();
            animArr:addObject(action);
            animArr:addObject(actionBack);
            local sequence = CCSequence:create(animArr)
            cclog("dexIndex->"..dexIndex[i])
            self.m_speedTable[dexIndex[i]].icon:runAction(sequence)
        end
        if(spc == nil or spc <= 0) then
            return
        end
        --排序
        local function sequenceFunc(dataOne,dataTwo)
            if dataOne.sortType == 1 and dataTwo.sortType == 1 then    --比较的两个人都没有出过手
                if(dataTwo.speed == dataOne.speed) then
                    return dataTwo.sortValue < dataOne.sortValue
                else
                    return dataTwo.speed < dataOne.speed
                end 
            elseif dataOne.sortType == 3 and dataTwo.sortType == 3 then--比较的两个人都出过手
                if dataTwo.nextSortValue == nil then
                    return true
                elseif dataOne.nextSortValue == nil then
                    return false
                else
                    return dataTwo.nextSortValue < dataOne.nextSortValue
                end
            elseif dataOne.sortType ~= dataTwo.sortType then           --不在同一组的，根据组号排序 未出过手>替补>出过手
                return dataOne.sortType < dataTwo.sortType
            else                                                       --同是替补，在前面的依旧在前面      
                return true
            end
        end
        for i = 1,#self.m_speedTable do
            for j = i + 1,#self.m_speedTable do
                if(not sequenceFunc(self.m_speedTable[i],self.m_speedTable[j])) then
                    local temp = self.m_speedTable[i]
                    self.m_speedTable[i] = self.m_speedTable[j]
                    self.m_speedTable[j] = temp
                end
            end
        end
        self:refreshShowSpeedTableAndUi()
    end
end
--[[--
    刷新出手顺序ui
]]
function game_battle_scene.refreshSpeedTableAndUi(self,removeFlag,srcPosIndex,desPosIndex,phsc,callname)
    cclog("refreshSpeedTableAndUi->"..callname)
    cclog("srcPosIndex->"..tostring(srcPosIndex))
    if self.m_speedTable == nil then 
        return 
    end
    local dexIndex = nil;
    local srcIndex = nil;
    if(phsc == nil) then
        phsc = 0;
    end
    dexIndex = {}
    if type(desPosIndex) == "number" then
        for k,v in pairs(self.m_speedTable) do
            if v.posIndex == desPosIndex then
                dexIndex[1] = k;
                v.speed = v.speed - phsc;--受攻击后减速度
            elseif v.posIndex == srcPosIndex then
                srcIndex = k;
            end
        end
    elseif type(desPosIndex) == "table" then
        for k,v in pairs(self.m_speedTable) do
            if v.posIndex == srcPosIndex then
                srcIndex = k;
            end
        end
        for i = 1,#desPosIndex do
            local desPosIndexTemp = desPosIndex[i]
            for k,v in pairs(self.m_speedTable) do
                if v.posIndex == desPosIndexTemp then
                    dexIndex[i] = k;
                    v.speed = v.speed - phsc;--受攻击后减速度
                end
            end
        end
    elseif(srcPosIndex ~= nil) then
        for k,v in pairs(self.m_speedTable) do
            if v.posIndex == srcPosIndex then
                srcIndex = k;
            end
        end
    end
    if removeFlag == true and dexIndex ~= nil then
        for i = 1,#dexIndex do
            if self.m_speedTable[dexIndex[i]].speedNode ~= nil then
                self.m_speedTable[dexIndex[i]].speedNode:removeFromParentAndCleanup(true);
            end
            table.remove(self.m_speedTable, dexIndex[i])--死亡移出
        end
    end
    if removeFlag == nil then
        local function sequenceFunc(dataOne,dataTwo)
            return dataTwo.sortValue < dataOne.sortValue;
        end
        table.sort(self.m_speedTable, sequenceFunc);
    elseif removeFlag == false and srcIndex ~= nil then--攻击方移动到攻击列表的最后
        --cclog("sortsortsortsortsortsortsortsortsort->"..srcIndex)
        local tempItem = self.m_speedTable[srcIndex];
        tempItem.sortFlag = false;
        tempItem.sortType = 3 
        table.remove(self.m_speedTable, srcIndex)--先移出
        --[[--for i = 1,#self.m_speedTable do
            local temp = self.m_speedTable[i]
            cclog("sortType"..tostring(temp.sortType))
            cclog("speed"..tostring(temp.speed))
            cclog("nextSortValue"..tostring(temp.nextSortValue))
            cclog("sortValue"..tostring(temp.sortValue))
        end]]--
        local function sequenceFunc(dataOne,dataTwo)
            if dataOne.sortType == 1 and dataTwo.sortType == 1 then    --比较的两个人都没有出过手
                if(dataTwo.speed == dataOne.speed) then
                    return dataTwo.sortValue < dataOne.sortValue
                else
                    return dataTwo.speed < dataOne.speed
                end 
            elseif dataOne.sortType == 3 and dataTwo.sortType == 3 then--比较的两个人都出过手
                if dataTwo.nextSortValue == nil then
                    return true
                elseif dataOne.nextSortValue == nil then
                    return false
                else
                    return dataTwo.nextSortValue < dataOne.nextSortValue
                end
            elseif dataOne.sortType ~= dataTwo.sortType then           --不在同一组的，根据组号排序 未出过手>替补>出过手
                return dataOne.sortType < dataTwo.sortType
            else                                                       --同是替补，在前面的依旧在前面      
                return true
            end
            --[[--if dataOne.sortFlag == true and dataTwo.sortFlag == true then
                return dataTwo.speed < dataOne.speed;
            elseif dataOne.sortFlag == true and dataTwo.sortFlag == false then
                return true;
            elseif dataOne.sortFlag == false and dataTwo.sortFlag == false then
                return dataTwo.sortValue < dataOne.sortValue;
            end]]--
        end
        for i = 1,#self.m_speedTable do
            for j = i + 1,#self.m_speedTable do
                if(not sequenceFunc(self.m_speedTable[i],self.m_speedTable[j])) then
                    local temp = self.m_speedTable[i]
                    self.m_speedTable[i] = self.m_speedTable[j]
                    self.m_speedTable[j] = temp
                end
            end
        end
        --table.sort(self.m_speedTable, sequenceFunc);
        table.insert(self.m_speedTable,tempItem);--在插入到列表最后
    end
    self:refreshShowSpeedTableAndUi()
    --[[--speedNode = self.m_speedTable[speedTableItemCount].speedNode;
    if speedNode ~= nil then
        speedNode:stopAllActions();
        posX,posY = speedNode:getPosition();
        tempPos = ccp(itemWidth * 0.8,itemBgSize.height * 0.6);
        if not tempPos:equals(ccp(posX,posY)) then
            speedNode:setScale(1);
            speedNode:runAction(CCMoveTo:create(0.1,tempPos));
        end
    end
    for i = 1,speedTableItemCount - 1 do
        speedNode = self.m_speedTable[i].speedNode;
        if speedNode ~= nil then
            speedNode:stopAllActions();
            posX,posY = speedNode:getPosition();
            tempPos = ccp(itemWidth * (i + 1),itemBgSize.height * 0.5);
            if not tempPos:equals(ccp(posX,posY)) then
               speedNode:setScale(0.75);
               speedNode:runAction(CCMoveTo:create(0.1,tempPos));
            end
        end
    end]]--
end
--[[--
    通过占位index得到相应位置上的卡牌动画
]]
function game_battle_scene.getAnimTabAndPosByIndex(self,tempdid,offest)
    local currentTable = nil;
    local tempPos = nil;
    if(tempdid >= 0 and tempdid<5)then
        currentTable = self.m_AtkAnims[tempdid+1];
        local pos =  self.m_tempNode[tempdid+1];
        tempPos = ccp(pos.m_x + offest,pos.m_y);
    elseif(tempdid >= 100 and tempdid<105)then
        currentTable = self.m_DfdAnims[tempdid-100+1];
        local pos = self.m_tempNode[tempdid-100+1+5];
        tempPos = ccp(pos.m_x - offest,pos.m_y);
    else
        cclog("yock-------------------------- getAnimTabAndPosByIndex :: " .. tostring(tempdid))
        return nil,nil;
    end
    cclog("yock ===============================" .. tostring(tempdid) .. " ; currentTable ==" .. tostring(currentTable) .. " ; tempPos = " .. tostring(tempPos));
    return currentTable,tempPos;
end

--[[--
    通过占位index得到相应位置上的卡牌动画
]]
function game_battle_scene.getPosByIndex(self,tempdid)
    local tempPos = nil;
    if(tempdid >= 0 and tempdid<5)then
        local pos =  self.m_tempNode[tempdid+1];
        tempPos = ccp(pos.m_x,pos.m_y);
    elseif(tempdid >= 100 and tempdid<105)then
        local pos = self.m_tempNode[tempdid-100+1+5];
        tempPos = ccp(pos.m_x,pos.m_y);
    end
    return tempPos;
end
--[[--
    data     卡牌数据
    camp     阵营
    face     朝向
    posIndex 占位下标
    realPos  位置
    sbtFlag  是否为替补
]]
function game_battle_scene.createAnimByPositionIndex(self,data,camp,face,posIndex,realPos,sbtFlag,animNode)
    if data ~= nil then
        -- cclog("data.card_id ======================" .. data.card_id);
        local cardData = nil;
        local cardCfg = nil;
        local equipData = {0,0,0,0}
        local initData = self.m_battleInitData;
        if camp ==2 then--我方
            local card_atk = initData.card_att
            cardData = card_atk[data.id]
            local equip_pos_atk = initData.equip_pos_att
            local equip_atk = initData.equip_att
            if equip_pos_atk and equip_atk then
                local equipDataTemp = equip_pos_atk[tostring(posIndex)]
                if equipDataTemp then
                    for i=1,4 do
                        local eId = equipDataTemp[i];
                        if eId and eId ~= 0 then
                            equipData[i] = equip_atk[tostring(eId)]
                        end
                    end
                end
            end
            cardCfg = getConfig(game_config_field.character_detail):getNodeWithKey(data.card_id);
        else--敌方
            local card_def = initData.card_def
            cardData = card_def[data.id]
            local equip_pos_def = initData.equip_pos_def
            local equip_def = initData.equip_def
            if equip_pos_def and equip_def then
                local equipDataTemp = equip_pos_def[tostring(posIndex-100)]
                if equipDataTemp then
                    for i=1,4 do
                        local eId = equipDataTemp[i];
                        if eId and eId ~= 0 then
                            equipData[i] = equip_def[tostring(eId)]
                        end
                    end
                end
            end

            local battleType = game_data:getBattleType();
            if(battleType == "game_pk") or (battleType == "friend_pk") or (battleType == "game_first_opening") or (battleType == "game_ability_commander_snatch") or self.m_tGameData.battle.fight_user == true then
                cardCfg = getConfig(game_config_field.character_detail):getNodeWithKey(data.card_id);
            else
                -- if battleType == "map_building_detail_scene" then
                --     cardCfg = game_util:getEnemyCfgByStageIdAndEnemyId(nil,data.card_id)
                -- else
                --     cardCfg = getConfig(game_config_field.enemy_detail):getNodeWithKey(data.card_id);
                -- end
            end
        end
        local animFile = ""
        if data.animation then
            cardCfg = data;
            animFile = data.animation;
        else
            if cardCfg == nil then
                cclog(" ---------------------------error is no config ----------------------" .. tostring(data.card_id))
                animNode = game_util:createUnknowIdelAnim("unknow",posIndex);
            else
                animFile = cardCfg:getNodeWithKey("animation"):toStr();
            end
        end
        -- cclog("data.card_id =============" .. data.card_id);
        -- cclog("cardCfg ==================" .. tostring(cardCfg));
        local animTable = self:createAnimTable(animFile,camp,face,true,posIndex,cardData,cardCfg,equipData,animNode);
        animTable.animNode:setPosition(realPos);
        animTable.bloodBar:setMaxValue(data.hp);
        animTable.lvLabel:setString(data.lv);
        animTable.aniState = 0;
        animTable.deathRef = 1;
        -- animTable.bloodBar:addLabelBMFont(CCLabelBMFont:create(data.hp .."/" .. data.hp,"textmap.fnt"));
        -- local hpLabel = CCLabelTTF:create(data.hp .."/" .. data.hp,TYPE_FACE_TABLE.Arial_BoldMT,12)
        -- hpLabel:setColor(ccc3(0,0,255))
        -- animTable.bloodBar:addLabelTTF(hpLabel);
        cclog(" data.hp ========================================" .. data.hp .. " ; posIndex ==" .. posIndex);
        animTable.index = posIndex;
        self.m_battle_layer:addChild(animTable.animNode);
        if camp == 2 then
            self.m_animCounter[tostring(posIndex)] = self.m_AtkAnims[posIndex+1];
            self.m_AtkAnims[posIndex + 1] = animTable;
        else
            self.m_animCounter[tostring(posIndex)] = self.m_DfdAnims[posIndex-99];
            self.m_DfdAnims[posIndex - 99] = animTable;
        end
        local countIndex = #self.m_speedTable + 1;
        local speedTemp = {};
        speedTemp.posIndex = posIndex;
        speedTemp.speed = data.speed;
        speedTemp.dataSpeed = data.speed;--不会变化的速度,用于每轮后重置
        -- if cardCfg then
        --     speedTemp.img = cardCfg:getNodeWithKey("img"):toStr();
        -- else
            speedTemp.img = "icon_chopper";
        -- end
        speedTemp.sortValue = countIndex;--出手顺序排序值
        speedTemp.nextSortValue = 0;     --下一次出手顺序排序值

        local itemBgSize = self.speedBarParent:getContentSize();
        local visibleSize = CCDirector:sharedDirector():getVisibleSize();
        local itemWidth = visibleSize.width / 14;

        local speedNode = self:createActionNode(ccp(itemWidth*countIndex,itemBgSize.height*0.5),countIndex,0.75);
        if speedNode ~= nil then
            if countIndex == 1 then
                speedNode:setPosition(ccp(itemWidth * 0.8,itemBgSize.height * 0.6));
                speedNode:setScale(1);
            else
                speedNode:setPosition(ccp(itemWidth * countIndex,itemBgSize.height * 0.5));
            end
            self.speedBarParent:addChild(speedNode,0,countIndex);
            local headIconSpr = tolua.cast(speedNode:getChildByTag(1),"CCSprite");
            speedTemp.icon = headIconSpr;
            if(camp == 2) then
                headIconSpr:setFlipX(false)
            else
                headIconSpr:setFlipX(true)
            end
            headIconSpr:setVisible(true);
            local iconTemp = game_util:createIconByName(speedTemp.img);
            if(iconTemp == nil) then
                cclog("--lack-->"..speedTemp.img)
            else
                headIconSpr:setDisplayFrame(iconTemp:displayFrame());
            end
            local headIconTypeSpr = tolua.cast(speedNode:getChildByTag(2),"CCSprite");
            local bgFileName = "";
            if(camp == 2) then
                bgFileName = "oneself.png"
            else
                bgFileName = "enemy.png"
            end
            headIconTypeSpr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgFileName));
        end
        speedTemp.speedNode = speedNode;
        if sbtFlag == true then
            -- animTable.animNode:playSection(anim_label_name_cfg.tibu);
            self:playSection(animTable.index,anim_label_name_cfg.tibu);
            speedTemp.sortFlag = false;
            speedTemp.sortType = 2;
            local tempAnim = game_util:createEffectAnimCallBack("anim_tibu",1.0,false,nil);
            -- cclog("tempAnim anim_tibu =============================================== " .. tostring(tempAnim))
            if tempAnim then
                tempAnim:setAnchorPoint(ccp(0.5,0));
                tempAnim:setPosition(realPos);
                self.m_battle_layer:addChild(tempAnim)
            end
        else
            speedTemp.sortFlag = true;
            speedTemp.sortType = 1;
        end
        table.insert(self.m_speedTable,speedTemp);
        return true;
    end
    return false;
end

--[[--
    初始化战斗场景
]]
function game_battle_scene.initStartBattle(self)
    self.m_deathRef = 0;
    self.m_debutRef = 0;
    -- audio.stopMusic(false);
    -- game_sound:playMusic("start_battle_music",false);

    local winSize = CCDirector:sharedDirector():getWinSize();
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local itemCfg,animationName
    --[[--if self.m_atk_role > 0 then
        itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_atk_role));
        animationName = itemCfg:getNodeWithKey("animation"):toStr();
        cclog("atkanimationName->"..animationName)
        --主角1
        local animTable = self:createAnimTable(animationName,2,false,false);
        animTable.animNode:setPosition(ccp(winSize.width * 0.02,winSize.height * 0.6));
        self.m_battle_layer:addChild(animTable.animNode);
        self.m_hero_table[1][2] = animTable;
    end
    self.m_debutRef = self.m_debutRef + 1;

    if self.m_dfd_role > 0 then
        itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_dfd_role));
        animationName = itemCfg:getNodeWithKey("animation"):toStr();
        cclog("dfdanimationName->"..animationName)
        --主角2
        local animTable = self:createAnimTable(animationName,1,true,false);
        animTable.animNode:setPosition(ccp(winSize.width * 0.98,winSize.height * 0.6));
        self.m_battle_layer:addChild(animTable.animNode);
        self.m_hero_table[2][2] = animTable;
    end
    self.m_debutRef = self.m_debutRef + 1;]]--

    self.speedBarParent:removeAllChildrenWithCleanup(true);
    self.m_buffAnimTable = {};
    self.m_speedTable = {};
    local x,y;
    local atkData,dfdData;
    local realPos = nil;
    local animAtkIndex = 1;
    local animDefIndex = 1;
    -- 初始化战场
    for i = 1,5 do
        cclog("--------------init war --  " .. tostring(i));
        realPos = ccp(self.m_tempNode[i].m_x,self.m_tempNode[i].m_y)
        atkData = self.m_AtkData[i];

        if atkData ~= nil then
            self:createAnimByPositionIndex(atkData,2,false,i - 1,realPos,false,self.m_animAtkNodeTable[animAtkIndex]);
            self.m_debutRef = self.m_debutRef + 1;
            animAtkIndex = animAtkIndex + 1;
        end
        
        realPos = ccp(self.m_tempNode[i + 5].m_x,self.m_tempNode[i + 5].m_y)
        dfdData = self.m_DfdData[i]

        if dfdData ~= nil then
            self:createAnimByPositionIndex(dfdData,1,true,i + 99,realPos,false,self.m_animDefNodeTable[animDefIndex]);
            self.m_debutRef = self.m_debutRef + 1;
            animDefIndex = animDefIndex + 1;
        end
    end

    -- 创建第一次排序
    cclog("self.m_debutRef =============================" .. tostring(self.m_debutRef));
    local frameNodeOne = self.m_BattleData["1"]
    if(frameNodeOne and frameNodeOne["flag"] == "sort")then
        local frameData = frameNodeOne.param
        local tempParamSort = {}
        for i=1,#frameData do
            tempParamSort[frameData[i]] = i;
        end
        cclog("----------------" .. tostring(#frameData));
        -- util.printf(self.m_speedTable);
        for k,v in pairs(self.m_speedTable) do
            -- util.printf(v);
            v.sortValue = tempParamSort[v.posIndex];
            v.sortFlag = true;
            v.sortType = 1;
            v.nextSortValue = 0;
        end
        self:refreshSpeedTableAndUi(nil,nil,nil,nil,"initStartBattle");
    end

    self:cleanHeroSkill()

    self.m_currentRound = 0;
    if self.m_currentRound == 0 then
        self.m_round_label:setString(string_helper.game_battle_scene.attack_stage);
    else
        self.m_round_label:setString(self.m_currentRound .. "/30");
    end
    self.m_hero_table[1][1]:setCurValue(0,false);
    self.m_hero_table[2][1]:setCurValue(0,false);
end

--[[--
    攻击方法
    tempFrameData 攻击数据
]]
function game_battle_scene.attackFunc(self,tempFrameData)
    cclog("---------------------------- attack -----------------------srcid:%d,desid:%d",tempFrameData.param.src,tempFrameData.param.des);
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil;
    -- self.m_currentFrameData = tempFrameData.param;

    self.m_currentFrameData.name = "skill1";
    if self.m_currentFrameData.src ~= nil and self.m_currentFrameData.name ~= nil then
        local tempid = self.m_currentFrameData.src;
        local tempdid = self.m_currentFrameData.des;
        local spc = self.m_currentFrameData.spc
        --cclog("attackFunctempdid->"..tempdid)
        self:shiningIcon(tempdid,spc)
        --game_util:testShowSortInfo(tempid,tempdid,spc,"attackFunc")
        --self:refreshSpeedTableAndUi(false,tempid,tempdid,self.m_currentFrameData.spc);
        self.m_currentAttackTable, self.m_realPos = self:getAnimTabAndPosByIndex(tempid,0);
        -- self.m_canGo = false;  
        local game_battle_skill = require("skill_effect.game_battle_skill");
        local skill1 = game_battle_skill:new();
        local skillTable = {
            game_battle_table = self,
            skill_type = "attack",
            currentFrameData = currentFrameData,
            m_tempid = tempid,
            m_tempdid = tempdid,
            m_spc = self.m_currentFrameData.spc,
        }
        skill1:create(skillTable);
    end
end

--[[--
    替补方法
    tempFrameData 替补数据
]]
function game_battle_scene.sbtFunc(self,tempFrameData)
    -- self.m_canGo = false;
    -- self.m_curtentAnimLabelName = tempFrameData.flag;
    -- cclog("---------------------------- sbt -----------------------");
    local tempid = tempFrameData.param.a;
    local tempSbtId = tempFrameData.param.b;
    if(tempid >=0 and tempid < 5)then
        local atkData = self.m_AtkData[tempSbtId+1];
        if atkData == nil then 
           -- self:setCanGo(true,"sbtFunc") 
           return 
        end
        local realPos = ccp(self.m_tempNode[tempid + 1].m_x,self.m_tempNode[tempid + 1].m_y);
        local returnFlag = self:createAnimByPositionIndex(atkData,2,false,tempid,realPos,true);
        if returnFlag == false then 
            -- self:setCanGo(true,"sbtFunc") 
            return 
        end
    elseif(tempid >=100 and tempid<105)then
        local dfdData = self.m_DfdData[tempSbtId-99];
        if dfdData == nil then 
            -- self:setCanGo(true,"sbtFunc") 
            return 
        end
        local realPos = ccp(self.m_tempNode[tempid - 94].m_x,self.m_tempNode[tempid - 94].m_y);
        local returnFlag = self:createAnimByPositionIndex(dfdData,1,true,tempid,realPos,true);
        if returnFlag == false then 
            -- self:setCanGo(true,"sbtFunc") 
            return 
        end
    else
        -- self:setCanGo(true,"sbtFunc")
    end
    self:refreshSpeedTableAndUi(false,nil,nil,nil,"sbtFunc");
end

--[[--
    主角技
    tempFrameData 数据
]]
function game_battle_scene.skillHeroFunc(self,tempFrameData)
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    -- self.m_curtentAnimLabelName = tempFrameData.flag;
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil;
    -- self.m_currentFrameData = tempFrameData.param;
    local temp_src = self.m_currentFrameData.src;
    --local posX,posY = self.m_hero_table[temp_src + 1][2].animNode:getPosition();
    if temp_src ~= nil and (temp_src == 0 or temp_src == 1) then
        self.m_hero_table[temp_src + 1][1]:setCurValue(0,false);
        -- cclog("---------------------------- skill_hero -----------------------");
        local camp
        if self.m_currentFrameData.src == 0 then
            camp = 1
        else
            camp = -1
        end
        local runEnd = function()
            local game_battle_skill = require("skill_effect.game_battle_skill");
            local skill1 = game_battle_skill:new();
            local skillTable = {
                game_battle_table = self,
                currentFrameData = currentFrameData,
                skill_type = "skill_hero",
                camp = camp,
                --attack_object = self.m_hero_table[temp_src + 1][2],
                --realPos = ccp(posX,posY),
            }
            skill1:create(skillTable);
        end
        self.m_ccbNode:registerAnimFunc(runEnd)
        local role_detail_cfg = getConfig(game_config_field.role_detail);
        local itemCfg,img
        if camp == 1 then
            itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_atk_role));
            img = itemCfg:getNodeWithKey("img"):toStr()
            -- cclog("----------m_hero_bg type " .. tolua.type(self.m_hero_bg));
            -- table.foreach(CCSprite,print);

            self.m_hero_bg:setDisplayFrame(CCSprite:create("humen/" .. img .."bg.png"):displayFrame());
            self.m_hero_half:setDisplayFrame(CCSprite:create("humen/" .. img..".png"):displayFrame());
            self.m_skill_lable:setDisplayFrame(CCSprite:create("lead_skill_label/" .. currentFrameData.name..".png"):displayFrame());
            self.m_ccbNode:runAnimations("left_anim")
        else
            itemCfg = role_detail_cfg:getNodeWithKey(tostring(self.m_dfd_role));
            img = itemCfg:getNodeWithKey("img"):toStr()
            self.m_hero_bg_R:setDisplayFrame(CCSprite:create("humen/" .. img.."bg.png"):displayFrame());
            self.m_hero_half_R:setDisplayFrame(CCSprite:create("humen/" .. img..".png"):displayFrame());
            self.m_skill_lable_R:setDisplayFrame(CCSprite:create("lead_skill_label/" .. currentFrameData.name..".png"):displayFrame());
            self.m_ccbNode:runAnimations("right_anim")
        end
    else
        self:setCanGo(true,"skillHeroFunc");
    end
end

--[[--
    技能方法
    tempFrameData 数据
]]
function game_battle_scene.skillFunc(self,tempFrameData)
    -- cclog("---------------------------- skill -----------------------1");
    -- local currentFrameData = tempFrameData.param;
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    -- self.m_curtentAnimLabelName = tempFrameData.flag;
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil;
    -- self.m_currentFrameData = tempFrameData.param;
    if self.m_currentFrameData.src ~= nil and self.m_currentFrameData.name ~= nil then
        local tempid = self.m_currentFrameData.src;
        local tempdid = self.m_currentFrameData.des;
        local spc = self.m_currentFrameData.spc
        --cclog("attackFunctempdid->"..tempdid)
        self:shiningIcon(tempdid,spc)
        --game_util:testShowSortInfo(tempid,tempdid,spc,"skillFunc")
        --cclog("---------------skillFunc---------------")
        --self:refreshSpeedTableAndUi(false,tempid,tempdid,self.m_currentFrameData.spc or 0);
        self.m_currentAttackTable, self.m_realPos = self:getAnimTabAndPosByIndex(tempid,0);
        cclog("---------- skill -------->"..currentFrameData.name);
        local delayCallBack = function()
            local game_battle_skill = require("skill_effect.game_battle_skill");
            local skill1 = game_battle_skill:new();
            local skillTable = {
                game_battle_table = self,
                currentFrameData = currentFrameData,
                skill_type = "skill",
                m_tempid = tempid,
                m_tempdid = tempdid,
                m_spc = spc,
            }
            skill1:create(skillTable);
        end
        delayCallBack();
    else
        self:setCanGo(true,"skillFunc");
    end
end
--[[--
    添加buff方法
    tempFrameData 数据
]]
function game_battle_scene.addBuffFunc(self,tempFrameData,frameId)
    -- local currentFrameData = tempFrameData.param;
    -- local curtentAnimLabelName = tempFrameData.flag;
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil; 
    -- self.m_curtentAnimLabelName = curtentAnimLabelName;
    -- self.m_currentFrameData = currentFrameData;
    
    if currentFrameData.src ~= nil and currentFrameData.name ~= nil then
        local tempid = tempFrameData.param.src;
        self.m_currentAttackTable, self.m_realPos = self:getAnimTabAndPosByIndex(tempid,0);
        cclog("---------------------------- add_buff -----------------------2");
        local game_battle_skill = require("skill_effect.game_battle_skill");
        local skill1 = game_battle_skill:new();
        local skillTable = {
            game_battle_table = self,
            skill_type = "add_buff",
            currentFrameData = currentFrameData,
        }
        skill1:create(skillTable);
    end
end
--[[--
    角色死亡
]]
function game_battle_scene:deathFunc( tempFrameData,frameId )
    -- body
    local isjump = false
    local nextNode = self.m_BattleData[tostring(frameId+1)]
    local tempFlag = nextNode.flag

    -- if tempFlag == "death" then--判断下一个动作是否是死亡
    --     self.m_canGo = true;
    -- elseif tempFlag == "skill" then
    --     self.m_canGo = false;
    --     local skillName = nextNode:getNodeWithKey("param"):getNodeWithKey("name"):toStr();
    --     for i = 1,#RELIFE_SKILL_NAME do
    --         --cclog("--self.m_BattleData[frameId + 1].name--"..tostring(self.m_BattleData[frameId + 1].param.name));
    --         --cclog("--RELIFE_SKILL_NAME[i]--"..tostring(RELIFE_SKILL_NAME[i]));
    --         if(skillName == RELIFE_SKILL_NAME[i]) then
    --             isjump = true
    --             self.m_canGo = true;
    --             break;
    --         end
    --     end
    -- else
    --     self.m_canGo = false;
    -- end
    -- if(not isjump) then
        self.m_curtentAnimLabelName = "death"
        self.m_deathRef = self.m_deathRef + 1;
        local tempid = tempFrameData.param;
        self.m_buffAnimTable[tempid] = {};
        
        self:refreshSpeedTableAndUi(true,nil,tempid,0,"start_death");
        --self.m_deadIndex =  tempid;
        local tempAnim = nil
        if(tempid < 5)then
            tempAnim = self.m_AtkAnims[tempid + 1]
        else
            tempAnim = self.m_DfdAnims[tempid - 99]
        end
        if tempAnim then
            cclog("---------- death -----------" .. tostring(tempid) .. "  deathRef=" .. tostring(tempAnim.deathRef));
        end
        self:objectDead(tempid)
        --[[--if(tempAnim ~= nil) then
            tempAnim.animNode:registerScriptTapHandler(game_battle_scene.animEnd);
            game_util:playSection(tempAnim.animNode,anim_label_name_cfg.siwang,tempAnim.aniState); 
            tempAnim.bloodBar:setCurValue(0,false);
        end]]--
    -- end
end

--[[--
    发动buff方法
    tempFrameData 数据
]]
function game_battle_scene.buffSkillFunc(self,tempFrameData)
    -- cclog("---------------------------- buff_skill -----------------------1");
    -- local currentFrameData = tempFrameData.param;
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    -- self.m_curtentAnimLabelName = tempFrameData.flag;
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil;
    -- self.m_currentFrameData = tempFrameData.param;
            
    if self.m_currentFrameData.src ~= nil and self.m_currentFrameData.name ~= nil then
        local tempid = tempFrameData.param.src;
        self.m_currentAttackTable, self.m_realPos = self:getAnimTabAndPosByIndex(tempid,0);
        -- self.m_canGo = false;  
        -- cclog("---------------------------- buff_skill -----------------------2");
        local game_battle_skill = require("skill_effect.game_battle_skill");
        local skill1 = game_battle_skill:new();
        local skillTable = {
            game_battle_table = self,
            skill_type = "buff_skill",
            currentFrameData = currentFrameData,
        }
        skill1:create(skillTable);
    end
end

--[[--
    移除buff方法
    tempFrameData 数据
]]
function game_battle_scene.removeBuffFunc(self,tempFrameData)
   -- local currentFrameData = tempFrameData.param;
   cclog("-------------- removeBuffFunc ------------name = " .. self.m_currentFrameData.name);
   local tempSrc = self.m_currentFrameData.src;
   -- local tempSrc = tempFrameData.src;
   self:removeBuff(tempSrc,self.m_currentFrameData.name);
end
--[[--

]]
function game_battle_scene.addBuff(self,tempSrc,name,animNodeTab,obj)
    cclog("------------- addBuff ----------name=" .. name .. " src=" .. tostring(tempSrc));
   animNodeTab = animNodeTab or {};
   table.foreach(animNodeTab, print)
   name = name .. tempSrc;
   if self.m_buffAnimTable[tempSrc] == nil then self.m_buffAnimTable[tempSrc] = {} end
   if self.m_buffAnimTable[tempSrc][name] ~= nil then
      for k,v in pairs(self.m_buffAnimTable[tempSrc][name]["table"]) do
         v:removeFromParentAndCleanup(true);
      end
      self.m_buffAnimTable[tempSrc][name] = nil;
   end
   self.m_buffAnimTable[tempSrc][name] = {}
   self.m_buffAnimTable[tempSrc][name]["table"] = animNodeTab
   self.m_buffAnimTable[tempSrc][name]["node"] = obj
end

--[[--

]]
function game_battle_scene.removeBuff(self,tempSrc,name)
   if self.m_buffAnimTable[tempSrc] ~= nil then
      name = name .. tempSrc;
      if self.m_buffAnimTable[tempSrc][name] ~= nil then
         --table.foreach(self.m_buffAnimTable[tempSrc][name],print)
         for k,v in pairs(self.m_buffAnimTable[tempSrc][name]["table"]) do
            -- cclog("remove buff name =========" .. tolua.type(v))
            v:removeFromParentAndCleanup(true);
         end
         cclog("-------------- removeBuffFunc ------------name = " .. name .. " aniState = 0");
         self.m_buffAnimTable[tempSrc][name]["node"].aniState = 0
         self.m_buffAnimTable[tempSrc][name]["node"].animNode:setColor(ccc3(255,255,255))
         self.m_buffAnimTable[tempSrc][name] = nil;
      end
   end
end

--[[--
    显示对话方法
    tempFrameData 数据
    数据格式为 int
]]
function game_battle_scene.showDialog( self , tempFrameData )
    -- body
    -- if self.m_currentFrameId == 1 and self.m_battleCount > 0 then
    --     self:setCanGo(true,"drama end");
    --     public_config.battleTickPause = false;
    --     return;
    -- end
    local currentFrameData = util.table_copy(self.m_currentFrameData);
    local function endCallFunc()
        if game_util.statisticsSendUserStep then
            if currentFrameData == 1000 then 
                game_util:statisticsSendUserStep(13)  --  完成drama1000 步骤13
            elseif currentFrameData == 101 then 
                game_util:statisticsSendUserStep(14)  --  完成drama101 步骤14
            elseif currentFrameData == 102 then 
                game_util:statisticsSendUserStep(15)  --  完成drama102 步骤15
            elseif currentFrameData == 103 then 
                game_util:statisticsSendUserStep(16)  --  完成drama103 步骤16
            elseif currentFrameData == 1038 then 
                game_util:statisticsSendUserStep(23)  --  完成drama1038 步骤23
            end
        end
        if self.m_currentFrameId == 1 and self.m_battleCount == 0 then
            self.m_arrow_node:setVisible(true);
            self.m_ccbNode:runAnimations("enter_anim")
        else
            self:setCanGo(true,"drama end");
            public_config.battleTickPause = false;
        end
    end
    local t_params = {};
    t_params.dramaId = currentFrameData;
    t_params.endCallFunc = endCallFunc;
    game_scene:addPop("drama_dialog_pop",t_params);
    -- self:setCanGo(false,"drama start");
    public_config.battleTickPause = true;
end

--[[--
    同步数据方法
]]
function game_battle_scene.synchroData( self,tempFrameData )
    -- body
    cclog("-----------------synchroData");
    util.printf(tempFrameData);
    -- self.m_AtkData;
    -- self.m_DfdData;
    local tempData = nil;
    local tempAnim = nil;
    for k,v in pairs(tempFrameData.param) do
        k = tonumber(k);
        -- if(k<5)then
        --     -- util.printf(self.m_AtkData);
        --     tempData = self.m_AtkData[k+1];
        -- else
        --     -- util.printf(self.m_DfdData);
        --     tempData = self.m_DfdData[k-99];
        -- end
        if(v["maxHp"]~=nil)then
            if(k < 5)then
                tempAnim = self.m_AtkAnims[k + 1]
            else
                tempAnim = self.m_DfdAnims[k - 99]
            end
            if tempAnim then
                local currentHp = tempAnim.bloodBar:getCurValue();
                local currentMaxHp = tempAnim.bloodBar:getMaxValue();
                if(currentMaxHp ~= v["maxHp"])then
                    cclog("changed max Hp currentHp->"..currentHp);
                    tempAnim.bloodBar:setMaxValue(v["maxHp"]);
                    tempAnim.bloodBar:setCurValue(currentHp,false);
                end
            end
        end
        if tempAnim then
            for ki,vi in pairs(v) do
                if(ki == "tempHp")then         -- 血量变化
                    -- tempData["hp"] = vi;
                    if(k < 5)then
                        tempAnim = self.m_AtkAnims[k + 1]
                    else
                        tempAnim = self.m_DfdAnims[k - 99]
                    end
                    local currentHp = tempAnim.bloodBar:getCurValue();
                    if(currentHp ~= vi)then
                        cclog("changed current hp ->" .. tostring(currentHp) .. "  psid=" .. tostring(k) );
                        tempAnim.bloodBar:setCurValue(vi,false);
                    end

                elseif(ki == "tempMgc")then    -- 魔攻变化
                    -- tempData["mgc"] = vi;
                elseif(ki == "tempPhsc")then   -- 物攻变化
                    -- tempData["phsc"] = vi;
                elseif(ki == "tempDfs")then    -- 防御变化
                    -- tempData["dfs"] = vi;
                elseif(ki == "tempSpeed")then  -- 速度变化
                    --     tempData["speed"] = vi;
                    for kt,vt in pairs(self.m_speedTable) do
                        if vt.posIndex == k then
                            vt.speed = vi;--受攻击后减速度
                        end
                    end
                elseif(ki == "maxHp")then      -- 最大血量变化
                    
                end
            end
        end
    end

    cclog("-----------------synchroData");
end

--[[--
    战斗主循环
]]
function game_battle_scene:start()
    -- self:initStartBattle();
    local frameCount = game_util:getTableLen(self.m_BattleData)
    local frameId = 1;          -- 帧计数器
    self.m_currentFrameId = frameId;
    local tempFrameData = nil;
    local tempFlag = nil;
    local function tick( dt )
        if self.m_enterId ~= nil and (self.m_BattleData == nil or frameId > frameCount) then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);
            self.m_enterId = nil;
        end
        if(self.m_canGo>0)then
            return;
        end
        local tempJsonNode = self.m_BattleData[tostring(frameId)];
        self:setCanGo(false,tempJsonNode.flag);
        tempFrameData = tempJsonNode;
        tempFlag = tempFrameData.flag;
        self.m_curtentAnimLabelName = tempFlag;

        self.m_currentFrameData = tempFrameData.param;
        --cclog("battle tick->"..tempFlag)
        if(tempFlag == "attack")then
            self:attackFunc(tempFrameData);
        elseif(tempFlag == "cur_hp")then
            -- for i = 1,#tempFrameData.param do
            --     local tempid = tempFrameData.param[i].index
            --     if(tempid < 5)then
            --         tempAnim = self.m_AtkAnims[tempid + 1]
            --     else
            --         tempAnim = self.m_DfdAnims[tempid - 99]
            --     end
            --     local currentHp = tempAnim.bloodBar:getCurValue();
            --     cclog("currentHp->"..currentHp)
            --     cclog("currentvalue->"..tempFrameData.param[i].value)
            --     cclog("tempid->"..tempid)
            --     tempAnim.bloodBar:setCurValue(tempFrameData.param[i].value,false);
            -- end
            self:setCanGo(true,"cur_hp");
        elseif(tempFlag == "cur_data")then
            self:synchroData(tempFrameData);
            self:setCanGo(true,"cur_data");
        elseif(tempFlag == "death")then
            self:deathFunc(tempFrameData,frameId);
            self:setCanGo(true,"death");
        elseif(tempFlag == "sort")then
            cclog("---------------------------- sort -----------------------");
            self.m_attacked={};
            self.m_currentRound = self.m_currentRound + 1;
            self.m_round_label:setString(self.m_currentRound .. "/30");
            if(self.m_currentRound > 1) then
                self:refreshHeroSkill();
            end
            local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
            local battleType = game_data:getBattleType();
            if battleType == "game_world_boss" then
                if vipLevel > 2 then
                    if self.m_currentRound == 1 then
                        local skipNode = self.m_btn_node:getChildByTag(3);
                        skipNode:setVisible(true);
                    end
                else
                    if self.m_currentRound == 5 then
                        local skipNode = self.m_btn_node:getChildByTag(3);
                        skipNode:setVisible(true);
                    end
                end
            else
                if vipLevel > 0 then
                    if self.m_currentRound == 4 then
                    -- if self.m_currentRound == 1 then
                        local skipNode = self.m_btn_node:getChildByTag(3);
                        skipNode:setVisible(true);
                    end
                else
                    if self.m_currentRound == 6 then
                        local skipNode = self.m_btn_node:getChildByTag(3);
                        skipNode:setVisible(true);
                    end
                end
            end
            -- local frameData = tempFrameData.param;
            local frameData = {};
            for k,v in pairs(tempFrameData.param) do
                frameData[v] = k;
            end

            local nextSortData = self.m_sortData[self.m_currentRound + 1]
            if(nextSortData == nil) then
                for k,v in pairs(self.m_speedTable) do
                    v.sortValue = frameData[v.posIndex]
                    v.nextSortValue = 0;
                    --[[--cclog("v.posIndex->"..v.posIndex)
                    cclog("v.sortValue->"..v.sortValue)
                    cclog("v.nextSortValue->nil")]]--
                    v.sortFlag = true;
                    v.sortType = 1;
                    v.speed = v.dataSpeed
                end
            else
                for k,v in pairs(self.m_speedTable) do
                    v.sortValue = frameData[v.posIndex]
                    v.nextSortValue = nextSortData[v.posIndex]
                    --cclog("v.posIndex->"..v.posIndex)
                    --cclog("v.sortValue->"..v.sortValue)
                    if(v.nextSortValue == nil) then
                        v.nextSortValue = 0;
                    end
                    v.sortFlag = true;
                    v.sortType = 1;
                    v.speed = v.dataSpeed
                end
            end
            if(self.m_currentRound == 1) then
                self:refreshSpeedTableAndUi(nil,nil,nil,nil,"start_sort");
            end
            self:setCanGo(true,"sort");
        elseif(tempFlag == "sbt")then
            self:sbtFunc(tempFrameData);
            self:setCanGo(true,"sbt");
        elseif(tempFlag == "next")then
            self:refreshSpeedTableAndUi(false,tempFrameData.param,nil,nil,"start_next");
            self:setCanGo(true,"next");
        elseif(tempFlag == "attack_over")then
            self.m_attacked[tempFrameData.param.src]=true;
            self:refreshSpeedTableAndUi(false,tempFrameData.param.src,nil,0,"start_attack_over");
            self:setCanGo(true,"attack_over");
        elseif(tempFlag == "skill_hero")then
            self:skillHeroFunc(tempFrameData);
        elseif(tempFlag == "anger")then
            local currentFrameData = tempFrameData.param;
            local temp_src = currentFrameData.src;
            cclog("-----anger-----")
            if temp_src ~= nil and (temp_src == 0 or temp_src == 1) then
                cclog("anger currentFrameData.value ==" .. currentFrameData.value .. " ; current value = " ..  self.m_hero_table[temp_src + 1][1]:getCurValue());
                self.m_hero_table[temp_src + 1][1]:setCurValue(currentFrameData.value,true,1);
            end
            self:setCanGo(true,"anger");
        elseif (tempFlag == "skill") then
            self:skillFunc(tempFrameData);
        elseif(tempFlag == "add_buff")then
            self:addBuffFunc(tempFrameData,frameId);
            self:setCanGo(true,"add_buff");
        elseif(tempFlag == "buff_skill")then
            self:buffSkillFunc(tempFrameData);
        elseif(tempFlag == "remove_buff")then
            self:removeBuffFunc(tempFrameData);
            self:setCanGo(true,"remove_buff");
        elseif(tempFlag == "winer")then
            cclog("---------------------------- winer -----------------------");
            self.m_curtentAnimLabelName = "winer"
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);
            self.m_enterId = nil;
            self.m_clickFlag = true;
            self:showBattleOverPop();
        elseif(tempFlag == 'drama')then
            -- cclog("-----------------------drama-----------------------");
            self:showDialog(tempFrameData);
        else
            cclog("this flag is unknow " .. tempFlag);
            util.printf(tempFrameData.param);
            self:setCanGo(true,tempFlag);
        end
        self.m_currentFrameId = frameId;
        cclog("self.m_currentFrameId  ===" .. self.m_currentFrameId .. " ;tempFlag = " .. tempFlag);
        frameId = frameId+1;
        tempFrameData = self.m_BattleData[tostring(frameId)];
        if tempFrameData then
            tempFlag = tempFrameData.flag;
            cclog("next frameId  ============" .. frameId .. " ;tempFlag 2 = " .. tempFlag);
        end
    end

    local realTime = 0;
    local function timerCallBack( dt )
        if public_config.battleTickPause == true then
            return;
        end
         -- body
        realTime = realTime+dt;
        if(realTime>public_config.action_durition) then
            realTime = realTime - public_config.action_durition;
            tick();
        end
    end
    local function tickDelayFunc()
        public_config.battleTickPause = true;
        self.m_enterId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timerCallBack, 1/60.0, false)
    end
    performWithDelay(self.m_battle_layer, tickDelayFunc, 0.1);
end

function game_battle_scene.setCanGo(self,boolFlag,fromStr)
    cclog("game_battle_scene.setCanGo ================" .. tostring(boolFlag) .. " ; fromStr ===" .. tostring(fromStr) .. "  can go :" .. tostring(self.m_canGo));
    if(boolFlag)then
        self.m_canGo = self.m_canGo-1;
    else
        self.m_canGo = self.m_canGo+1;
    end
    if(self.m_canGo<0)then
        self.m_canGo=0;
        cclog("yock setCanGo assert ---------------- " .. fromStr);
    end
end

--[[--
    直接战斗
]]
function game_battle_scene.enterBattle(self)
    local function responseMethod(tag,gameData)
        local mapConfig = getConfig(game_config_field.map_title_detail);
        local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_buildingId));
        local background = buildingCfgData:getNodeWithKey("background"):toStr();
        background = game_util:getResName(background);
        local fight_list = buildingCfgData:getNodeWithKey("fight_list");
        local fightItem = fight_list:getNodeAt(self.m_next_step);
        local stageName = ""
        local fight_list_count = 0;
        local fight_boss = "0";
        if fightItem then
            stageName = fightItem:getNodeAt(0):toStr();
            fight_list_count = fight_list:getNodeCount();
            local fightId = fightItem:getNodeAt(1):toStr()
            game_data:setCurrentFightId(fightId);
            -- local enemyCfg = getConfig(game_config_field.map_fight)
            -- local mapEnemyCfg = enemyCfg:getNodeWithKey(fightId)
            -- if mapEnemyCfg then
            --     fight_boss = mapEnemyCfg:getNodeWithKey("fight_boss"):toStr()
            -- end
            local map_fight_and_enemy = game_data:getDataByKey("map_fight_and_enemy") or {}
            local map_fight_cfg = map_fight_and_enemy.map_fight or {}
            local mapEnemyCfg = map_fight_cfg[fightId]
            if mapEnemyCfg then
                fight_boss = tostring(mapEnemyCfg.fight_boss);
            end
            cclog("fight_boss ======================= " .. fight_boss .. " ;mapEnemyCfg == " .. tostring(mapEnemyCfg) .. " ; fightId == " .. fightId)
        end
        local stageTableData = {name = stageName,step = self.m_next_step+1,totalStep = fight_list_count,fight_boss = fight_boss}
        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step,stageTableData=stageTableData,backGroundName = background});
    end
    game_data:setUserStatusDataBackup();
    local params = {};
    params.city = self.m_cityId;
    params.building = self.m_buildingId;
    params.step_n = self.m_next_step;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_recapture"), http_request_method.GET, params,"private_city_recapture")
end

--[[--
    战斗结束ui
]]
function game_battle_scene.showBattleOverPop(self)
    local battleType = game_data:getBattleType();
    if battleType == "game_first_opening" then
        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(17) end  -- 神卡大战战斗播放完成（或点击跳过） 步骤17
    elseif game_data.getGuideProcess and game_data:getGuideProcess() == "first_battle_mine" then
        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(24) end  -- 完成第一场战斗（或点击跳过） 步骤24
    end

    if battleType == "game_first_opening" then
        local m_shared
        m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt)
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
            m_shared = nil;
            self:back();
        end, 0.1 , false);
        return;
    end
    if self.m_clickFlag == true then
        local returnType = 0;
        if ((self.m_cityId ~= nil and self.m_buildingId ~= nil) and self.m_next_step == -1) and self.m_battle_result < 5 then
            returnType = 1;--战斗完成
        else
            if self.m_next_step == -1 then
                returnType = 1;--战斗完成
            end
        end
        public_config.battleTickPause = true; 
        local m_shared = nil;
        m_shared = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt)
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(m_shared);
            m_shared = nil;
            if returnType == 0 and battleType == "map_building_detail_scene" and self.m_battle_result < 5 then
                local m_battle_over_node = self.m_ccbNode:nodeForName("m_battle_over_node")
                local m_arrow_sprite = self.m_ccbNode:spriteForName("m_arrow_sprite")
                m_battle_over_node:setVisible(true);
                self.m_btn_node:setVisible(false);
                for k,v in pairs(self.m_DfdAnims) do
                    if v.animNode then
                        v.animNode:setVisible(false);
                    end
                end
                local pX,pY = m_arrow_sprite:getPosition();
                m_arrow_sprite:runAction(game_util:createRepeatForeverMove(ccp(pX-10,pY),ccp(pX+10,pY)));   
                self:autoBattleFunc();             
            else
                local tempSize = CCDirector:sharedDirector():getWinSize();  
                local screenShoot = CCRenderTexture:create(tempSize.width,tempSize.height, kCCTexture2DPixelFormat_RGB565);
                local pCurScene = CCDirector:sharedDirector():getRunningScene();
                screenShoot:begin();  
                pCurScene:visit();  
                screenShoot:endToLua(); 
                self.m_clickFlag = false;
                game_scene:enterGameUi("battle_over_scene",{gameData = self.m_tGameData,backGroundName = self.m_backGroundName,screenShoot = screenShoot,isNext = self.isNext,lastScore = self.lastScore})
            end
        end, 0.1 , false);
    end
    --[[
    public_config.battleTickPause = true;
    local function callFunc(btnTag)
        if btnTag == 1 then--战斗统计
            -- game_scene:enterGameUi("game_battle_statistics",{gameData = nil,cityId = self.m_cityId,buildingId = self.m_buildingId,next_step = self.m_next_step});
            -- self:destroy();
            
            self:back();
            -- local function endCallFunc()
            --     self:destroy();
            -- end
            -- game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        elseif btnTag == 2 then--战斗回放
            game_scene:removeAllPop();
            self:restart();
        elseif btnTag == 3 then--返回  
            local function backFunc()
                local id = game_guide_controller:getIdByTeam("3");
                if id == 302 then -- 技能升级
                    game_scene:enterGameUi("game_main_scene");
                else
                    local id2 = game_guide_controller:getIdByTeam("5");
                    if id2 == 502 then -- 伙伴进阶
                        game_scene:enterGameUi("game_main_scene");
                    else
                        self:back();
                    end
                end
            end
            local battleType = game_data:getBattleType();
            if battleType == "map_building_detail_scene" then
                if self.m_next_step == -1 or self.m_battle_result > 5 then--战斗完成 或 失败
                    backFunc();
                else--直接战斗
                    self:enterBattle();
                end
            else
                backFunc();
            end
        elseif btnTag == 11 then--属性改造
            if not game_button_open:checkButtonOpen(509) then
                return;
            end
            game_scene:enterGameUi("game_hero_culture_scene",{gameData = nil,openType = "game_battle_scene"});
            self:destroy();
        elseif btnTag == 12 then--装备强化
            if not game_button_open:checkButtonOpen(602) then
                return;
            end
            game_scene:enterGameUi("equipment_strengthen",{gameData = nil,openType = "game_battle_scene"});
            self:destroy();
        elseif btnTag == 13 then--技能升级
            if not game_button_open:checkButtonOpen(503) then
                return;
            end
            game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil,openType = "game_battle_scene"});
            self:destroy();
        elseif btnTag == 14 then--回到城市地图
            -- local function responseMethod(tag,gameData)
            --     game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            --     game_scene:enterGameUi("game_small_map_scene",{});
            --     self:destroy();
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = self.m_cityId},"private_city_open")
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        end
    end
    local returnType = 0;
    if ((self.m_cityId ~= nil and self.m_buildingId ~= nil) and self.m_next_step == -1) and self.m_battle_result < 5 then
        returnType = 1;--战斗完成
    else
        if self.m_next_step == -1 then
            returnType = 1;--战斗完成
        end
        -- if self.m_stageTableData == nil or self.m_stageTableData.totalStep == nil or (self.m_next_step >= (self.m_stageTableData.totalStep-1)) then
        --     returnType = 1;
        -- end
    end
    game_scene:addPop("battle_over_pop",{gameData = self.m_tGameData,callFunc = callFunc,returnType = returnType})
    ]]
end

function game_battle_scene.battleOverBtnClick(self,btnTag,event)
    -- cclog("battleOverBtnClick === " .. btnTag .. " ; event = " .. tostring(event))
    if btnTag == 11 then --返回
        self:back();
    elseif btnTag == 12 then --阵型
        game_data:setDataByKeyAndValue("ToAdjustBuildLastStep", {next_step = self.m_next_step, city = nil, building = nil})
        game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="map_building_detail_scene"});
    elseif btnTag == 13 then --下一关
        if event == CCControlEventTouchDown then
            self:removeCountdownLabel();
        else
            self:enterBattle();
        end
    end
end

--[[
    
]]
function game_battle_scene.removeCountdownLabel(self)
    if self.m_countdownLabel then
        self.m_countdownLabel:removeFromParentAndCleanup(true);
        self.m_countdownLabel = nil;
    end
end

--[[
    自动下一场战斗倒计时
]]
function game_battle_scene.autoBattleFunc(self)
    local function timeOverCallFun(label,type)
        self:removeCountdownLabel();
        self:enterBattle();
    end
    self.m_countdownLabel = game_util:createCountdownLabel(5,timeOverCallFun,12,2)
    self.m_countdownLabel:setScale(1.1)
    local m_arrow_sprite = self.m_ccbNode:spriteForName("m_arrow_sprite")
    local pX,pY = m_arrow_sprite:getPosition();
    self.m_countdownLabel:setPosition(ccp(pX, visibleSize.height*0.25))
    self.m_ccbNode:addChild(self.m_countdownLabel,10,10)
end

--[[--
    战斗重新播放方法
]]
function game_battle_scene.restart(self)
    public_config.battleTickPause = true;
    -- public_config.action_rythm = 1.0;
    -- public_config.action_durition = public_config.action_durition_temp * public_config.action_rythm;
    self.m_animAtkNodeTable = {};
    self.m_animDefNodeTable = {};
    self.m_AtkAnims = {};           -- 攻方动画
    self.m_DfdAnims = {};           -- 守方动画
    self.m_enterId = nil;            -- 计时器句柄
    self:setCanGo(true,"restart");             -- 可以出手标记
    self.m_currentAttackTable = nil;
    self.m_currentHitTable = nil;
    self.m_curtentAnimLabelName = nil;
    self.m_battle_layer:stopAllActions();
    self.m_battle_layer:removeAllChildrenWithCleanup(true);
    self.m_battle_down_layer:removeAllChildrenWithCleanup(true);
    self.m_battle_up_layer:removeAllChildrenWithCleanup(true);
    self.m_battleCount = self.m_battleCount + 1;
    self:initStartBattle();
    self:checkChain();
    self:start();
    local skipNode = self.m_btn_node:getChildByTag(3);
    skipNode:setVisible(true);
end

--[[--
    战斗中播放动画封装
]]

function game_battle_scene:playSection( theId,animName )
    -- body
    local enemy_object_tab = nil;
    if(theId < 5)then
        enemy_object_tab = self.m_AtkAnims[theId + 1]    
    else
        enemy_object_tab = self.m_DfdAnims[theId - 99]
    end
    if(enemy_object_tab == nil) then
        return
    end
    -- cclog("------game_battle_scene:playSection->" .. animName);
    local curSectionName = enemy_object_tab.animNode:getCurSectionName();
    if(game_util:isPlayTheAction(curSectionName,anim_label_name_cfg.siwang))then
        if (string.find(animName,"gongji")==nil or string.find(animName,"mofa")==nil) then
            cclog("-------------------anim is siwang and animName is not gongji or mofa");
            return;
        end
    end

    if(string.find(animName,anim_label_name_cfg.siwang))then
        enemy_object_tab.deathRef = 2;
    else
        if(enemy_object_tab.deathRef>1)then
            enemy_object_tab.deathRef = 1;
        end
    end
    

    game_util:playSection(enemy_object_tab.animNode,animName,enemy_object_tab.aniState); 
end


function game_battle_scene.getTipsDataToShow ( self, data )
    local tipInfo = {}

    local allData = json.decode(data)
    if allData then
        -- print("allData.reward", allData.reward)
        -- print("allData.once", allData.once)
        if allData.reward == true then 
            tipInfo.reward = ture
        end
        if allData.once == true then
            tipInfo.once = true
        end
        if allData.online_award_expire == 0 then
            tipInfo.online_award = true
        end
    end
    return tipInfo
end

function game_battle_scene:checkChain(  )
    -- body
    -- cardChainByCfg
    
    local chainCfg = getConfig(game_config_field.chain);
    local function getMaxChain( data , LorR)
        -- body
        local chain = nil;
        for k,v in pairs(data) do
            if v.card_id then
                local cardCfg = getConfig(game_config_field.character_detail):getNodeWithKey(v.card_id);
                local valueTab = util.stringSplit(tostring(v["id"]),"_");
                local chainTab = {};
                if(LorR)then
                    chainTab = game_util:cardChainByCfg(cardCfg,valueTab[2]);
                else
                    chainTab = game_util:dfdCardChainByCfg(cardCfg , valueTab , data , self.m_battleInitData.dfd_friend);
                end
            
                for m,n in pairs(chainTab) do
                    -- print(m,json.encode(n));
                    if(n.openFlag)then
                        if(chain == nil)then
                            chain = n;
                        else
                            if(n.count>chain.count)then
                                chain = n;
                            end
                        end
                    end
                end
            end
        end
        return chain;
    end

    local function createIcon( chainId , LorR )
        local chain = chainCfg:getNodeWithKey(chainId);
        local x = 0;
        local y = 0;
        local dx = 0;
        local dy = 0;
        local dly = 0.2;
        local sz = CCDirector:sharedDirector():getWinSize();
        y = sz.height*0.1;
        local chainData = chain:getNodeWithKey("data");
        local count = chainData:getNodeCount();
        local width = sz.width * 0.4
        local w = width/count;
        if(LorR)then
            x = w/2;
            dx = w;
            
        else
            x = sz.width - w/2;
            dx = -w;
        end

        local chainType = chain:getNodeWithKey("condition_sort"):toInt();


        local sharedId = nil;
        local time = 0.1;
        local daleyStart = 0.1;
        local iconStart = 1;
        local iconMap = {};
        local function tick( dt )
            -- body
            time = time+dt;
            if(time>=daleyStart)then
                if(iconMap[iconStart])then
                    -- local delay = CCDelayTime:create(dly);
                    local fade = CCFadeIn:create(0.1);
                    local scale = CCScaleTo:create(0.2,1.0);
                    -- local move = CCMoveTo:create(0.2,ccp(x+dx*6,y));

                    local function remove_node( node )
                        -- body
                        node:removeFromParentAndCleanup(true);
                    end
                    local remove = CCCallFuncN:create(remove_node);
                    local delay2 = CCDelayTime:create(1.5 - dly*iconStart);
                    local arr = CCArray:create();
                    -- arr:addObject(delay);
                    -- arr:addObject(move);
                    arr:addObject(CCSpawn:createWithTwoActions(fade,scale));
                    -- arr:addObject(fade);
                    -- arr:addObject(scale);
                    arr:addObject(delay2);
                    arr:addObject(remove);
                    iconMap[iconStart]:setScale(2);
                    iconMap[iconStart]:setVisible(true);
                    iconMap[iconStart]:runAction(CCSequence:create(arr));
                    iconStart = iconStart+1;
                else
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(sharedId);
                end
                time = time - daleyStart;
            end
        end

        print("--------- chain = " .. chain:getFormatBuffer());

            
        for i=1 , count do
            local v = chainData:getNodeAt(i-1):toStr();
            cclog("------- cardid = " .. v);
            local icon = nil;
            if(chainType == 0)then
                icon = game_util:createCardIconByCid(v);
            else
                icon = game_util:createEquipIconByCid(v)
            end
            icon:setPosition(ccp(x,y));
            icon:setVisible(false);
            -- icon:setScale(5);
                
            iconMap[#iconMap+1] = icon;
            self.m_top_layer:addChild(icon);
            x = x+dx;
        end
        sharedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick , 1/60 , false);

    end
    
    cclog("----------------- get chainA");
    local chainA = getMaxChain(self.m_AtkData , true );
    cclog("----------------- get chainD");
    local chainD = getMaxChain(self.m_DfdData , false );

    


    if(chainA ~= nil and chainA.count >= 3)then
        cclog("--------------------- chainA ")
        local sz = CCDirector:sharedDirector():getWinSize();
        local anim = zcAnimNode:create("anim_lianxie.swf.sam",0,"anim_lianxie.plist");
        local function OnAnimSectionEnd(node, theId, theLabelName)
            node:playSection(theLabelName);
        end
        anim:registerScriptTapHandler(OnAnimSectionEnd);
        anim:playSection("impact");
        anim:setPosition(ccp(sz.width*0.2,sz.height*0.1));
        anim:setScale(0.8);
        self.m_top_layer:addChild(anim);

        local function startIcon( node )
            cclog("------------- startIcon --------")
            
            local chainText = CCLabelTTF:create(chainA.nameExt,TYPE_FACE_TABLE.Arial_BoldMT,24);
            if(chainA.count <= 3)then
                chainText:setColor(ccc3(104,153,246));
            elseif(chainA.count == 4)then
                chainText:setColor(ccc3(159,69,243));
            elseif(chainA.count == 5)then
                chainText:setColor(ccc3(255,160,48));
            end
            chainText:setScale(3);
            chainText:setPosition(ccp(sz.width*0.2,sz.height*0.1));
            local scaleto = CCScaleTo:create(0.2,1.0);
            local function remove_node( node )
                -- body
                node:removeFromParentAndCleanup(true);
                anim:removeFromParentAndCleanup(true);
            end
            local remove = CCCallFuncN:create(remove_node);
            local delay = CCDelayTime:create(0.8);
            local arr = CCArray:create();
            arr:addObject(scaleto);
            arr:addObject(delay);
            arr:addObject(remove);
            chainText:runAction(CCSequence:create(arr));

            self.m_top_layer:addChild(chainText);
        end
        local delayI = CCDelayTime:create(0.5);
        local startI = CCCallFuncN:create(startIcon);
        local arr = CCArray:create();
        arr:addObject(delayI);
        arr:addObject(startI);
        self.m_top_layer:runAction(CCSequence:create(arr));
        createIcon(chainA.chain,true);
    else
        cclog("------------------------ chainA is nil");
    end

    if(chainD ~= nil and chainD.count >= 3)then
        cclog("------------------------ chainD ");
        local sz = CCDirector:sharedDirector():getWinSize();
        local anim = zcAnimNode:create("anim_lianxie.swf.sam",0,"anim_lianxie.plist");
        local function OnAnimSectionEnd(node, theId, theLabelName)
            node:playSection(theLabelName);
        end
        anim:registerScriptTapHandler(OnAnimSectionEnd);
        anim:playSection("impact");
        anim:setFlipX(true);
        anim:setScale(0.8);
        anim:setPosition(ccp(sz.width*0.8,sz.height*0.1));
        self.m_top_layer:addChild(anim); 

        local function startIcon( node )
            -- body
            cclog("------------- startIcon --------")
            
            local chainText = CCLabelTTF:create(chainD.nameExt,TYPE_FACE_TABLE.Arial_BoldMT,24);
        
            if(chainD.count <= 3)then
                chainText:setColor(ccc3(104,153,246));
            elseif(chainD.count == 4)then
                chainText:setColor(ccc3(159,69,243));
            elseif(chainD.count == 5)then
                chainText:setColor(ccc3(255,160,48));
            end
            chainText:setScale(3);
            chainText:setPosition(ccp(sz.width*0.8,sz.height*0.1));
            local scaleto = CCScaleTo:create(0.05,1.0);
            local function remove_node( node )
                 -- body
                node:removeFromParentAndCleanup(true);
                anim:removeFromParentAndCleanup(true);
            end
            local remove = CCCallFuncN:create(remove_node);
            local delay = CCDelayTime:create(1.0);
            local arr = CCArray:create();
            arr:addObject(scaleto);
            arr:addObject(delay);
            arr:addObject(remove);
            chainText:runAction(CCSequence:create(arr));

            self.m_top_layer:addChild(chainText);
        end

        local delayI = CCDelayTime:create(0.5);
        local startI = CCCallFuncN:create(startIcon);
        local arr = CCArray:create();
        arr:addObject(delayI);
        arr:addObject(startI);
        self.m_top_layer:runAction(CCSequence:create(arr));
        createIcon(chainD.chain,false);
    else
        cclog("------------------- chainD is nil");
    end
end

return game_battle_scene;
