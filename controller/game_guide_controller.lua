---新手引导

local M = {
    m_guideFlag = true,
    m_guide_team = "-1",
    m_guide_id = -1,
    m_guide = {},
    m_formationGuideIndex = -1,
};

function M.init(self)
    local guide = game_data:getUserStatusDataByKey("guide");
    -- print("guide data is ", guide)
    -- if type(guide) == "table" then
    --     print_lua_table(guide, "00000")
    -- end
    if guide then
        self.m_guide = util.table_copy(guide)
        -- table.foreach(guide,print);
    end
    -- if self.m_guide_team == nil or self.m_guide_id == nil then
    -- 	self:setGuideFlag(false);
    -- else
    -- 	local guideCfg = getConfig(game_config_field.guide);
    -- 	local guideTeamCfg = guideCfg:getNodeWithKey(tostring(self.m_guide_team));
    -- 	if guideTeamCfg then
    -- 		local tempCount = guideTeamCfg:getNodeCount();
    -- 		if self.m_guide_id > tempCount then
    -- 			self:setGuideFlag(false);
    -- 		else
    -- 			self:setGuideFlag(true);
    -- 		end
    -- 	else
    -- 		self:setGuideFlag(false);
    -- 	end
   	-- end
    -- self.m_guide["1"] = 27;
    -- self.m_guideFlag = false;
    -- self.m_guide["24"] = 86
    -- self.m_guide["10"] = 1001
    if self.m_guide["67"] == nil then
        self.m_guide["67"] = 6701
    end
    if self.m_guide["68"] == nil then
        self.m_guide["68"] = 6801
    end

    if self.m_guide["69"] == nil then
        self.m_guide["69"] = 6901
    end

    -- local level = game_data:getUserStatusDataByKey("level") or 0
    -- if level >= 10 and self.m_guide["7"] == nil then
    --     self.m_guide["7"] = 701
    -- elseif level >= 10 and self.m_guide["7"] ~= 711 then
    --     cclog2(self.m_guide["7"], "self.m_guide[7]   == ")
    --     self:sendGuideData("7", 701)
    -- end
end

function M.start(self)
    local guide_team_cfg = getConfig(game_config_field.guide_team);
    local firstGuideId = self.m_guide["1"];
    local secondGuideId = self.m_guide["2"];
    local guideId3 = self.m_guide["3"];
    local guideId5 = self.m_guide["5"];
    local guideId13 = self.m_guide["13"];
    local guideId15 = self.m_guide["15"];
    local enterMainSceneFlag = true;
    if firstGuideId and firstGuideId < 26 then
        if firstGuideId >= 0 and firstGuideId < 8 then--到第3步
            enterMainSceneFlag = false;
            if firstGuideId < 4 then
                self:setGuideData("1",2)
            else
                self:setGuideData("1",4)
            end
            local function sendRequest()
                local function responseMethod(tag,gameData)
                    if gameData == nil then
                        game_util:closeAlertView();
                        local t_params = 
                        {
                            title = string_config.m_title_prompt,
                            okBtnCallBack = function(target,event)
                                sendRequest();
                                game_util:closeAlertView();
                            end,   --可缺省
                            closeCallBack = function(target,event)
                                game_util:closeAlertView();
                                exitGame();
                            end,
                            okBtnText = string_config.m_re_conn,       --可缺省
                            text = string_config.m_net_req_failed,      --可缺省
                            closeFlag = false,
                        }
                        game_util:openAlertView(t_params);
                        return;
                    end
                    game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                    game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,bgMusic = "background_singapo"});
                end
                local params = {}
                params.city = "100";
                params.chapter = "1";
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open",true,true)
            end
            sendRequest();
        elseif firstGuideId >= 8 and firstGuideId < 15 then--到第12步
            self:setGuideData("1",12)
        elseif firstGuideId >= 15 and firstGuideId < 21 then--到第16步
            self:setGuideData("1",16)
        elseif firstGuideId >= 21 and firstGuideId < 26 then--到第21步
            self:setGuideData("1",21)
        end
    elseif secondGuideId and secondGuideId < 38 then
        if secondGuideId >= 28 and secondGuideId < 34 then
            self:setGuideData("2",29);
        elseif secondGuideId >= 34 and secondGuideId < 38 then
            self:setGuideData("2",34);
        end
    elseif guideId3 and guideId3 < 308 then
        self:setGuideData("3",308);
    elseif guideId5 and guideId5 < 509 then
        if guideId5 >= 501 and guideId5 < 505 then
            self:setGuideData("5",502);
        elseif guideId5 >= 505 and guideId5 < 509 then
            self:setGuideData("5",505);
        end
    elseif guideId13 and guideId13 < 1306 then
        if guideId13 >= 1301 and guideId13 < 1303 then
            self:setGuideData("13",1301);
        elseif guideId13 >= 1303 and guideId13 < 1306 then
            self:setGuideData("13",1303);
        end
    elseif guideId15 and guideId15 < 1505 then
        if guideId15 >= 1501 and guideId15 < 1504 then
            self:setGuideData("15",1501);
        elseif guideId15 >= 1504 and guideId15 < 1505 then
            self:setGuideData("15",1504);
        end
    end
    if enterMainSceneFlag == true then
        local function endCallFunc(returnValue)
            returnValue = returnValue or "0"
            if returnValue == "1" then--请求失败
                game_util:closeAlertView();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_scene:enterGameUi("game_main_scene",{gameData = nil,firstFlag = true},{endCallFunc = endCallFunc});
                        game_util:closeAlertView();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_config.m_re_conn,       --可缺省
                    text = string_config.m_net_req_failed,      --可缺省
                    closeFlag = false,
                }
                game_util:openAlertView(t_params);
            end
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil,firstFlag = true},{endCallFunc = endCallFunc});
    end
end

--[[--
    获得
]]
function M.getMaxGuideIndex(self)
    local maxGuideIndex = -1;
    for k,v in pairs(self.m_guide) do
        maxGuideIndex = math.max(maxGuideIndex,v);
    end
    return math.max(maxGuideIndex,game_data:getMaxGuideIndex())
end

--[[--
   设置新手引导标示
]]
function M.setGuideFlag(self,guideFlag)
    self.m_guideFlag = guideFlag;
end

--[[--
   获得新手引导步骤标示
]]
function M.getGuideFlag(self)
    return self.m_guideFlag;
end

function M.setGuideTeam(self,guide_team)
    self.m_guide_team = guide_team;
end

function M.getGuideTeam(self)
    return self.m_guide_team;
end

function M.setGuideId(self,guideId)
    self.m_guide_id = guideId;
end

function M.getGuideId(self)
    return self.m_guide_id;
end

function M.setGuideData(self,guide_team,guide_id)
    self.m_guide_team = guide_team;
    self.m_guide_id = guide_id;
    local temp_id = self.m_guide[tostring(guide_team)]
    if temp_id then
        self.m_guide[tostring(guide_team)] = guide_id;
    end
end

function M.getGuideData(self)
    return self.m_guide_team,self.m_guide_id
end

function M.showGuide(self,guide_team,guide_id,t_params)
    -- cclog("showGuide =============== guide_team =" .. tostring(guide_team) .. " ; guide_id = " .. tostring(guide_id))
    t_params = t_params or {};
    local dramaFlag = false;
    local guideCfg = getConfig(game_config_field.guide);
    local guideTeamCfg = guideCfg:getNodeWithKey(tostring(guide_team));
    if guideTeamCfg then
        if game_data_statistics then
            game_data_statistics:guide({guideTeam = guide_team,guideId = guide_id})
        end
        local guideIdCfg = guideTeamCfg:getNodeWithKey(tostring(guide_id));
        if guideIdCfg then
            self.m_guide_team = guide_team;
            self.m_guide_id = guide_id;
            if t_params.guideType == "drama" then
                local dramaId = guideIdCfg:getNodeWithKey("drama");
                if dramaId then
                    -- cclog2(dramaId, "dramaId   =====   ")
                    t_params.dramaId = dramaId:toInt()
                    game_scene:addPop("drama_dialog_pop",t_params);
                    dramaFlag = true;
                end
            else
                game_scene:addGuidePop(t_params)
            end
        end
    end
    if not dramaFlag then
        if t_params.endCallFunc and type(t_params.endCallFunc) == "function" then
            t_params.endCallFunc();
        end
    end
end

function M.getId(self,guide_team,guide_id)
    -- cclog("getId =============== guide_team =" .. tostring(guide_team) .. " ; guide_id = " .. tostring(guide_id))
    local id = -1;
    local guideCfg = getConfig(game_config_field.guide);
    local guideTeamCfg = guideCfg:getNodeWithKey(tostring(guide_team));
    if guideTeamCfg and self.m_guideFlag == true then
        local guideIdCfg = guideTeamCfg:getNodeWithKey(tostring(guide_id));
        if guideIdCfg then
            id = guideIdCfg:getNodeWithKey("id"):toInt();
        end
    end
    return id;
end

function M.getCurrentId(self)
    local guide = game_data:getUserStatusDataByKey("guide") or {};
    if guide["1"] ~= nil and guide["1"] == 1 then
        if self.m_guide["1"] == nil then
            self.m_guide["1"] = 1;
            self.m_guide_team = "1";
            self.m_guide_id = 1;
        end
    elseif guide["2"] ~= nil and guide["2"] == 28 then
        if self.m_guide["2"] == nil then
            self.m_guide["2"] = 28;
            self.m_guide_team = "2";
            self.m_guide_id = 28;
        end
    end
    return self:getId(self.m_guide_team,self.m_guide_id);
end

function M.getIdByTeam(self,guide_team)
    local guide_id = self:getMaxGuideIdByTeam(guide_team);
    return self:getId(guide_team,guide_id);
end


function M.getCurrentGuideType(self,guide_team)
    local typeValue = -1;
    local guideCfg = getConfig(game_config_field.guide);
    local guideTeamCfg = guideCfg:getNodeWithKey(tostring(guide_team));
    local tempId = self.m_guide[tostring(guide_team)]
    if guideTeamCfg and tempId then
        local tempCount = guideTeamCfg:getNodeCount();
        local tempItem = guideTeamCfg:getNodeWithKey(tostring(tempId))
        if tempId <= tempCount and tempItem then
            -- typeValue = tempItem:getNodeWithKey("type"):toInt();
            typeValue = 1;
        end
    end
    return typeValue;
end


function M.getGuideCompareFlag(self,guide_team,guide_id)
    local flag = false;
    if self.m_guideFlag == true then
        local temp_id = self:getMaxGuideIdByTeam(guide_team)
        -- cclog("guide_team====" .. guide_team .. " ; guide_id=== " .. guide_id .. " ; temp_id == " .. temp_id)
        if temp_id and tonumber(temp_id) <= guide_id then
            self.m_guide[tostring(guide_team)] = guide_id;
            flag = true;
        else
            local guide = game_data:getUserStatusDataByKey("guide");

        end
    end
    return flag;
end

function M.getMaxGuideIdByTeam(self,guide_team)
    local guide = game_data:getUserStatusDataByKey("guide") or {};
    guide_team = tostring(guide_team)
    local guide_id = guide[guide_team] or -1;
    -- if guide_team == "1" and guide_id == -1 then
    if guide_id == -1 then
        -- cclog("getMaxGuideIdByTeam guide = " .. json.encode(guide))
    end
    if guide_id and self.m_guide[guide_team] then
        guide_id = math.max(guide_id,self.m_guide[guide_team])
    end
    return guide_id;
end

function M.sendGuideData(self,guide_team,guide_id,t_params)
    if not self:getGuideCompareFlag(guide_team,guide_id) then return end 
    t_params = t_params or {};
    local showLoading = t_params.showLoading or false;
    local function responseMethod(tag,gameData)
        local endCallFunc = t_params.endCallFunc;
        if endCallFunc then
            if gameData and not gameData:isEmpty() then
                endCallFunc(true);
            else
                endCallFunc(false);
            end
        end
    end
    -- guide_team=1&guide_id=5
    local params = {};
    params.guide_team = guide_team;
    params.guide_id = guide_id;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_guide"), http_request_method.GET, params,"user_guide",showLoading,true)
end

function M.skipCurrentGameGuide(self)
    -- cclog("----game_guide_controller:skipCurrentGameGuide---" .. "team = " .. tostring(self.m_guide_team) .. " ; id == " .. tostring(self.m_guide_id))
    if self.m_guide_team == "1" then
        if self.m_guide_id >= 8 then
            game_guide_controller:sendGuideData("1",27);
        end
    elseif self.m_guide_team == "2" then
        self:sendGuideData("2",40);
    else
        local tempId = -1;
        local guideCfg = getConfig(game_config_field.guide);
        local guideTeamCfg = guideCfg:getNodeWithKey(tostring(self.m_guide_team));
        if guideTeamCfg then
            local tempCount = guideTeamCfg:getNodeCount();
            tempId = tonumber(self.m_guide_team)*100 + tempCount
        else
            tempId = tonumber(self.m_guide_team)*100 + 100
        end
        self:sendGuideData(self.m_guide_team,tempId);
    end
end


function M.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not self:getGuideCompareFlag(guide_team,guide_id) then return end
    t_params = t_params or {};
    if guideType == "show" then
        self:showGuide(guide_team,guide_id,t_params);
    elseif guideType == "send" then
        self:sendGuideData(guide_team,guide_id,t_params)
    elseif guideType == "drama" then
        local function endCallFunc()
            self:gameGuide("send",guide_team,guide_id+1);
        end
        t_params.guideType = "drama";
        t_params.endCallFunc = endCallFunc;
        -- print("will showGuide ", guide_team,guide_id,t_params)
        local xx = self:showGuide(guide_team,guide_id,t_params)

    end
end


--[[
    -- 主动引导初始化信息
]]
local force_guide = {}
local endfun = function ( guide_team )
    game_guide_controller:showEndForceGuide(guide_team)
end
force_guide["10"] = {guide_team = "10", guide_id = 1001, player_level_up_pop = {}, --[[game_main_scene = {"m_partner_btn"}, funBtnInfo = {key = "partner", btnID = 501} ,]] guideEndfun = endfun}       -- 伙伴训练
force_guide["13"] = {guide_team = "13", guide_id = 1301, player_level_up_pop = {}, --[[game_main_scene = {"m_leader_skill_btn"}, funBtnInfo =  {key = "heroInfo", btnID = 605} ,]] guideEndfun = endfun}       -- 英雄技能
force_guide["14"] = {guide_team = "14", guide_id = 1401, player_level_up_pop = {}, --[[game_main_scene = {"m_backpack_btn"}, funBtnInfo = {key = "backpack", btnID = 603} ,]] guideEndfun = endfun}     -- 装备进阶
force_guide["15"] = {guide_team = "15", guide_id = 1501, player_level_up_pop = {}, --[[game_main_scene = {"m_partner_btn"}, funBtnInfo = {key = "partner", btnID = 509} ,]] guideEndfun = endfun}    -- 属性改造
force_guide["17"] = {guide_team = "17", guide_id = 1701, battle_over_scene = {}, --[[game_main_scene = {"m_battle_btn"}, map_world_scene = {"m_elite_levels_btn_2"} ,]] guideEndfun = endfun}   -- 精英关卡
force_guide["18"] = {guide_team = "18", guide_id = 1801, player_level_up_pop = {}, --[[game_main_scene = {"m_leader_skill_btn"}, funBtnInfo =  {key = "heroInfo", btnID = 606} ,]] guideEndfun = endfun}      -- 统帅能力
-- force_guide["75"] = {guide_team = "75", guide_id = 7501, 
--     game_fuli_activity_scene = {tipsName = "level"}, 
--     game_fuli_subui_award = { guideType = "level", level = 10},
--     game_main_scene = {
--         step = 2,
--         step1 = {btn = "m_conbtn_fuli", state = false}, 
--         step2 = {btn = "m_shop_btn", state = false}, 
--         },
--     game_card_melting = {
--         step = 2,
--         step1 = {btn = "btn_chongzhi", state = false}, 
--         step2 = {btn = "btn_fenjie", state = false}, 
--     },
--     funBtnInfo =  {key = "shop", btnID = 122} , 
--     guideEndfun = endfun,
--     onlyOneBtn = true}      -- 统帅能力



--[[
    -- 主动引导完毕
]]
function M.showEndForceGuide( self, guide_team )
    game_data:resetForceGuideInfo( guide_team )
    local all_force_guide = game_data:getUserLocalDataByKey("force_guide") or {}
    all_force_guide[guide_team] = true
    game_data:setUserLocalDataByKey("force_guide", all_force_guide)
end

--[[
    -- 检查引导类型
]]
function M.checkGuideType( self , guide_in)
    -- do return "75" end
    guide_in = guide_in or "nnnnnllll"
    local game_team_cfg = getConfig( game_config_field.guide_team )
    if game_team_cfg then
        local count = game_team_cfg:getNodeCount()
        local all_force_guide = game_data:getUserLocalDataByKey("force_guide") or {}
        for i=1,count do
            local item = game_team_cfg:getNodeAt(i - 1)
            if item then
                local guide_sort = item:getNodeWithKey("guide_sort") and item:getNodeWithKey("guide_sort"):toInt() or 1
                local key = item:getKey()
                -- cclog2(self:getIdByTeam( key ), "self:getIdByTeam( key )  =====  ")
                -- cclog2(key, "key  =====  ")
                if self:getIdByTeam( key ) ~= -1 and (tostring(force_guide[key] and force_guide[key].guide_id) == tostring(self:getIdByTeam( key ))) then
                -- if self.m_guide[key] and key == "17" then
                    if force_guide[key][ guide_in ] then
                        if guide_sort == 4 and all_force_guide[tostring(key)] ~= true then
                            local cur_id = self:getIdByTeam( tostring(key) )
                            -- cclog2(key, "这个新手引导需要强制引导  ====  ")
                            -- cclog2(cur_id, "这个新手引导需要强制引导  ====  ")
                            return tostring(key)
                        end
                    end
                end
            end
        end
    end
end

--[[ 
    主动引导提示
]]
function M.guideHelper( self, guidfun, guide_in, skipfun )
    do
        return
    end
    local guide_team_id = self:checkGuideType( guide_in )
    -- cclog2(guide_team_id, "guideHelper  ====  ")
    if guide_team_id then
        local forceInfo = force_guide[tostring( guide_team_id )]
        -- cclog2(forceInfo, " forceInfo  ====  ")
        if forceInfo then
            local id = game_guide_controller:getIdByTeam( forceInfo.guide_team );
            -- cclog2(id, "  ----------  id == ")
            -- cclog2(forceInfo.guide_team, "  ----------  forceInfo.guide_team == ")
            -- id = 7501
            if id == forceInfo.guide_id then
            -- if true then
                local guideSkipFunc = function (  )
                    -- cclog2(forceInfo.guideEndfun, "forceInfo.guideEndfun =====  ")
                    -- cclog2(forceInfo.guide_team, "forceInfo.guide_team =====  ")
                    if type(skipfun) == "function" then
                        skipfun()
                    end

                    if type(forceInfo.guideEndfun) == "function" then
                        forceInfo.guideEndfun( forceInfo.guide_team )
                        game_data:setForceGuideInfo( nil )
                    end
                end
                -- local start_guide = function ()
                --     local t_params = {}
                --     t_params.clickCallFunc = function (  )
                --         cclog2("click")
                --         game_scene:removeGuidePop()
                --     end
                --     t_params.tempNode = self[ forceInfo.game_main_scene[1] ]
                --     t_params.skipFunc = guideSkipFunc
                --     game_scene:addGuidePop( t_params )
                --     game_data:setForceGuideInfo( forceInfo )
                -- end

                game_util:closeAlertView();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        game_util:closeAlertView();
                        -- start_guide()
                        if type(guidfun) == "function" then
                            guidfun( forceInfo  )
                        end
                    end,   --可缺省
                    cancelBtnCallBack = function(target,event)
                        guideSkipFunc()
                        game_util:closeAlertView();
                    end,
                    btnUseTTF = true,
                    okBtnText = string_helper.game_guide_controller.okBtnText,       
                    cancelBtnText = string_helper.game_guide_controller.cancelBtnText,
                    onlyOneBtn = false,  
                    text = string_config:getTextByKey("m_forceGuide_" .. forceInfo.guide_team),      --可缺省
                    closeFlag = false,
                }
                if forceInfo.onlyOneBtn then
                    t_params.onlyOneBtn = true
                    t_params.cancelBtnText = nil
                end
                game_util:openAlertView(t_params);
                return true
            end
        end
    end
    return false
end

--[[--
   设置阵型引导
]]
function M.setFormationGuideIndex(self,tempIndex)
    self.m_formationGuideIndex = tempIndex;
end

--[[--
    获得阵型引导
]]
function M.getFormationGuideIndex(self)
    return self.m_formationGuideIndex
end

return M;