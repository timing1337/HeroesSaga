--- 数据缓存
local tostring,os,type,pairs,math,tonumber = tostring,os,type,pairs,math,tonumber
local M = {
    m_tCardsData = {},--卡牌数据
    m_tCardsIdTable = {},--卡牌id对应表
    m_tTeamData = {},--编队数据
    m_tEquipData = {},--装备数据
    m_tEquipIdTable = {},--装备id对应表
    m_tEquipPosData = {},--卡牌位置装备数据
    m_tAssEquipPosData = json.decode("{\"100\":[\"0\",\"0\",\"0\",\"0\"],\"101\":[\"0\",\"0\",\"0\",\"0\"],\"102\":[\"0\",\"0\",\"0\",\"0\"],\"103\":[\"0\",\"0\",\"0\",\"0\"],\"104\":[\"0\",\"0\",\"0\",\"0\"],\"105\":[\"0\",\"0\",\"0\",\"0\"],\"106\":[\"0\",\"0\",\"0\",\"0\"],\"107\":[\"0\",\"0\",\"0\",\"0\"],\"108\":[\"0\",\"0\",\"0\",\"0\"],\"109\":[\"0\",\"0\",\"0\",\"0\"]}"),--助威卡牌位置装备数据
    m_tEquipSortData = {},--装备分类数据
    m_tFormationData = {},--阵型数据
    m_tUserStatusData = {},--用户基础数据
    m_tUserStatusDataBackup = {},
    m_tBuildingAbilityData = {},--建筑
    m_tResourceData = {},--资源
    m_tPrivateBuildingData = {},
    m_globalSchedulerHandle = nil,
    m_last_request_time = os.time(),
    m_tHarborData = {},--避难所数据
    m_tLaboratoryData = {},--研究所数据
    m_tSchoolData = {},--学校数据
    m_tFactoryData = {},--工厂数据
    m_selCityId = nil,
    m_selBuildingId = nil,
    m_tGachaData = {},
    m_battleType = "",--战斗类型
    m_reMapBattleFlag = false,
    m_selNeutralCityId = nil,--选择的中立城市
    m_selNeutralBuildingId = nil,--选择的中立城市的建筑
    m_selGuildData = {},
    m_guildListData = {},
    m_dailyAwardData = {init = false,data = {}},
    m_itemsData = {},--道具
    m_enterBackgroundTime = os.time(),
    m_action_point_add_time = 180,
    m_openPositionData = {},
    m_leaderSkillData = {},--主角技能
    m_availableSkillTreeData = {},--技能树
    m_availableSkill = {},--开启的技能
    m_serverData = {},
    m_selServerId = "",
    m_tNoticesData = {},
    m_cardSortType = "default",
    m_equipSortType = "default",
    m_activeData = {};
    m_selActiveData = {},
    m_backgroundMusicName = "",
    m_skillIdTreeTab = {},
    m_alertsData = {},
    m_arenaRank = 0,
    m_arenaPoint = 0,                   -- 功勋
    m_online_award_expire = nil,
    m_onlinw_awawrd_id = nil,
    m_active = false,
    m_selCitySweepLogData = {},
    m_chapterTab = {},
    m_tSelCityData = {},
    m_tSelNeutralCityData = {},
    m_tBattleCardNum = {},
    tempCombatValue = 0,
    m_newCardIdTab = {count = 0},
    m_newEquipIdTab = {count = 0},
    m_newItemIdTab = {count = 0},
    m_currentFightId = "-1",
    m_currChapterTypeName = "normal",
    buy_ap_times = 0,
    shopData = {},
    -- 消息提醒相关数据
    m_texchangedCardEquip = {},  -- 可以兑换的卡牌或者装备
    m_ttrainfinishCard = {}, -- 训练完成的卡片
    m_tAssistant = {"-1","-1","-1","-1","-1","-1","-1","-1","-1"},       -- 助战小伙伴
    m_tAssistantEffect = {},
    m_tDestiny = {"-1","-1","-1","-1","-1","-1","-1","-1","-1"},  -- 命运小伙伴
    m_talreadyTips = {} , 
    m_commanderData = {},

    m_curValidButton = {},  -- 当前可用的功能

    m_curInReviewButton = {}, -- 当前不开启的按钮
    m_curInReviewOpenButton = {}, -- 当前不开启的按钮

    m_tLocalGameData = nil,     -- 一场游戏中的一些标记

    m_phone_num = "",--手机号
    m_showSthTips = {},  -- 是否限时某些提示
    m_mapWorldData = {},
    openTable = {},--活动开启table
    opening_award_expire = nil,
    m_mapType = nil,

    m_chatData = {maxMsg = 20, world = {curMsg = 0, data = {}}, guild = {curMsg = 0, data = {}}, friend = {curMsg = 0, data = {}}, guild_war = {curMsg = 0, data = {}}},  -- 聊天缓存
    m_chatTime = {world = 0, guild = 0, friend = 0},
    m_sdkAccount = nil,
    m_treasure = nil,--宝藏难度设置
    RecoverFlag = nil,
    m_commander_type = "",
    m_chat = nil,

    m_force_guide_info = nil,
    m_leatestShowActivityIndex = nil,
    m_guildName = nil,
    m_guideProcess = nil,
    m_tGemData = {},--宝石数据
    m_tGemIdTable = {},--宝石id对应表
    m_tGemPosData = {},--卡牌位置宝石数据
    m_newGemIdTab = {count = 0},
    m_gemSortType = "default",
};

function M.init(self)
    self.m_skillIdTreeTab = {};

    local leader_skill_tree = getConfig(game_config_field.leader_skill_tree);
    local tree_count = leader_skill_tree:getNodeCount();
    local count;
    local function paramsSkillTree(jsonData,treeId)
        count = jsonData:getNodeCount();
        for i=1,count do
            local item = jsonData:getNodeAt(i - 1);
            local key = item:getKey();
            -- cclog("key ===============" .. key .. " ; treeId = " .. treeId)
            self.m_skillIdTreeTab[key] = tonumber(treeId);
            if item:getNodeCount() ~= 0 then
                paramsSkillTree(item,treeId);
            end
        end
    end
    local itemData = nil;
    for i=1,tree_count do
        itemData = leader_skill_tree:getNodeAt(i-1)
        paramsSkillTree(itemData,itemData:getKey());
    end
    local chapter = getConfig(game_config_field.chapter);
    local chapter_count = chapter:getNodeCount();
    local itemCfg,is_hard = nil,nil;
    local playerLevel = self:getUserStatusDataByKey("level") or 1;
    local normalTab,difficultTab, openDifficultTab = {},{},{}
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    for i=1,chapter_count do
        itemCfg = chapter:getNodeAt(i-1);
        is_hard = itemCfg:getNodeWithKey("is_hard"):toInt();
        local open_level = itemCfg:getNodeWithKey("open_level"):toInt();
        local chapterId = itemCfg:getKey();
        if is_hard == 0 then
            normalTab[#normalTab + 1] = chapterId
        elseif is_hard == 2 and tonumber(chapterId or "0") > 200 then
            difficultTab[#difficultTab + 1] = chapterId
            if playerLevel >= open_level then
                openDifficultTab[chapterId] = true
            end
        end
    end
    local function sortFunc(idOne,idTwo)
        return tonumber(idOne) < tonumber(idTwo);
    end
    table.sort(normalTab,sortFunc);
    table.sort(difficultTab,sortFunc);
    self.m_chapterTab.normal = normalTab
    self.m_chapterTab.difficult = difficultTab
    self.m_chapterTab.openDifficult = openDifficultTab
    self.m_chapterTab.openCityTab = {};
    self.m_chapterTab.newOpenCityTab = {count = 0};
    self:judgeCityOpenChanged(true);

    self:resetOpenButtonList()

    -- 初始化标记
    self.m_tLocalGameData = self:getLocalGameData();           -- 

end
--[[--
    获得技能tree表
]]
function M.getSkillIdTreeTab(self)
    return self.m_skillIdTreeTab or {};
end
--[[--
    获得章节表
]]
function M.getChapterTabByKey(self,key)
    return self.m_chapterTab[key] or {};
end
--[[--
    获取已经记录的已经开启的功能
]]
function M.getOpenButtonList(self)
    return self.m_curValidButton or {};
end

--[[
    重置开启的功能
]]
function M.resetOpenButtonList( self )
    -- 初始化 现在开启功能列表
    self.m_curValidButton = {}
    local curOpen = game_button_open:getOpenButtonIdList()
    for i,v in pairs(curOpen) do
        self.m_curValidButton[i] = v
    end
end


--[[--
    添加已经提示的新功能到记录列表
]]
function M.addOneNewButtonByBtnID(self, btnId)
    -- print("add a new buton", type(btnId), btnId)
    btnId = tostring(btnId)
    self.m_curValidButton[btnId] = true
end

--[[ -- 
    更新小红点提示状态
    key ：    提示的种类  -- cmdr_energy：精力提示， totalStar：星灵提示
    isResetShow = nil
    isResetShow = have_show  查看小红点是否能提示
    isResetShow = reset_show  重置小红点提示状态
]]
function M.updateShowTips( self, key, isResetShow )
    if self.m_showSthTips == nil then self.m_showSthTips = {} end

    print("updateShowTips  == ", json.encode(self.m_showSthTips))

    if self.m_showSthTips[ key ] == nil then
        self.m_showSthTips[key] = {}
        self.m_showSthTips[key] = true
        return true
    end
    if isResetShow == "have_show" then
        self.m_showSthTips[key] = false
        return false
    elseif isResetShow == "reset_show" then
        self.m_showSthTips[key] = nil
    elseif self.m_showSthTips[key] == true then
        return true
    end
    return false
end

--[[--
    
]]
function M.judgeCityOpenChanged(self,initFlag)
    local map_main_story = getConfig(game_config_field.map_main_story);
    local playerLevel = self:getUserStatusDataByKey("level") or 1;
    local showDataTab = self.m_chapterTab.openCityTab
    local newOpenCityTab = self.m_chapterTab.newOpenCityTab
    local tempCount = map_main_story:getNodeCount();
    local selCityId = 100000;
    for i=1,tempCount do
        local itemCfg = map_main_story:getNodeAt(i-1);
        local openId = itemCfg:getKey();
        local stage_id = itemCfg:getNodeWithKey("stage_id"):toInt()
        local open_level = itemCfg:getNodeWithKey("open_level"):toInt()
        if playerLevel >= open_level and tonumber(openId) < 39 then--开启
            if initFlag == true then
                -- cclog("openId ==1== " .. openId .. " ; playerLevel == " .. playerLevel .. " ; open_level == " .. open_level)
                showDataTab[openId] = stage_id;
            else
                -- cclog("openId ==2== " .. openId .. " ; playerLevel == " .. playerLevel .. " ; open_level == " .. open_level)
                if showDataTab[openId] == nil then
                    showDataTab[openId] = stage_id;
                    newOpenCityTab[openId] = stage_id;
                    newOpenCityTab.count = newOpenCityTab.count + 1;
                    if stage_id < selCityId then
                        selCityId = stage_id
                    end
                end
            end
        end
    end
    if selCityId ~= 100000 then
        newOpenCityTab.selCityId = selCityId;
    end
    -- cclog("json.encode(showDataTab) ==== " .. json.encode(showDataTab))
    -- cclog("json.encode(newOpenCityTab) ==== " .. json.encode(newOpenCityTab))
end
--[[--
    
]]
function M.resetNewOpenCityTab(self)
    self.m_chapterTab.newOpenCityTab = {count = 0};
end

--[[--
    
]]
function M.getNewOpenCityTab(self)
    return self.m_chapterTab.newOpenCityTab
end

--[[--
    
]]
function M.getNewOpenCityId(self)
    return self.m_chapterTab.newOpenCityTab.selCityId;
end

--[[------------------------------------卡牌相关 start------------------------------------------- ]]
--[[--
    通过json数据设置cards数据
]]
function M.setCardsByJsonData(self,cardsJsonData)
    if cardsJsonData == nil then
        return;
    end
    self.m_tCardsIdTable = {};
    self.m_tCardsData = json.decode(cardsJsonData:getFormatBuffer()) or {};
    if self.m_tCardsData ~= nil and type(self.m_tCardsData) == "table" then
        for k,v in pairs(self.m_tCardsData) do
            self.m_tCardsIdTable[#self.m_tCardsIdTable + 1] = k;
        end
    end
    -- cclog("setCardsByJsonData ============count = " .. #self.m_tCardsIdTable);
    -- local writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
    -- local ret = util.writeFile(writablePath .. "heroData.temp",cardsJsonData:getFormatBuffer());
    self:cardsSortByTypeName(self.m_cardSortType);
end

--[[--
    cards数据排序
]]
function M.cardsSortByTypeName(self,typeName)
    -- table.foreach(self.m_tCardsIdTable,print)
-- 默认：1出战状态，2卡牌ID，3卡牌等级
-- 等级：1卡牌等级，2卡牌品质,3卡牌ID
-- 品质：1卡牌品质，2卡牌ID，3卡牌等级
-- 职业：1卡牌职业，2卡牌品质，3卡牌ID，4卡牌等级
    self.m_cardSortType = typeName;
    self:cardsSortByTypeNameWithTable(typeName,self.m_tCardsIdTable);
    -- cclog("----------------------------------")
    -- table.foreach(self.m_tCardsIdTable,print)
end
--[[--
    cards数据排序
]]
function M.cardsSortByTypeNameWithTable(self,typeName,idDataTable)
    -- table.foreach(self.m_tCardsIdTable,print)
-- 默认：1出战状态，2卡牌ID，3卡牌等级
-- 等级：1卡牌等级，2卡牌品质,3卡牌ID
-- 品质：1卡牌品质，2卡牌ID，3卡牌等级
-- 职业：1卡牌职业，2卡牌品质，3卡牌ID，4卡牌等级
    local tempTab = self.m_tCardsData;
    local str = tostring;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroData1,heroData2,heroCfg1,heroCfg2,quality1,quality2,c_ID1,c_ID2,race1,race2
    local tTeamTab = {};
    for k,v in pairs(self.m_tTeamData or {}) do
        tTeamTab[str(v)] = 20;
    end
    for k,v in pairs(self.m_tAssistant or {}) do
        tTeamTab[str(v)] = 10;
        tTeamTab[str(self.m_tDestiny[k])] = 9;
    end
    local flag1,flag2
    local function sortFunc(idOne,idTwo)
        heroData1 = tempTab[str(idOne)]
        heroData2 = tempTab[str(idTwo)]
        heroCfg1 = character_detail_cfg:getNodeWithKey(tostring(heroData1.c_id));
        heroCfg2 = character_detail_cfg:getNodeWithKey(tostring(heroData2.c_id));
        if heroCfg1 and heroCfg2 then
            quality1 = heroCfg1:getNodeWithKey("quality"):toInt()
            quality2 = heroCfg2:getNodeWithKey("quality"):toInt()
            c_ID1 = tonumber(heroData1.c_id)
            c_ID2 = tonumber(heroData2.c_id)
            if typeName == "default" then
                flag1 = tTeamTab[heroData1.id] or 0
                flag2 = tTeamTab[heroData2.id] or 0
                if flag1 == flag2 then
                        if quality1 == quality2 then
                            if c_ID1 == c_ID2 then
                                return heroData1.lv > heroData2.lv;
                            else
                                return c_ID1 > c_ID2;
                            end
                        else
                            return quality1 > quality2;
                        end
                else
                    return flag1 > flag2;
                end
            elseif typeName == "lv" then
                if heroData1.lv == heroData2.lv then
                    if quality1 == quality2 then
                        return c_ID1 > c_ID2;
                    else
                        return quality1 > quality2;
                    end
                else
                    return heroData1.lv > heroData2.lv;
                end
            elseif typeName == "quality" then
                if quality1 == quality2 then
                    if c_ID1 == c_ID2 then
                        return heroData1.lv > heroData2.lv;
                    else
                        return c_ID1 > c_ID2;
                    end
                else
                    return quality1 > quality2;
                end
            elseif typeName == "profession" then
                race1 = heroCfg1:getNodeWithKey("race"):toInt();
                race2 = heroCfg2:getNodeWithKey("race"):toInt();
                if race1 == race2 then
                    if quality1 == quality2 then
                        if c_ID1 == c_ID2 then
                            return heroData1.lv > heroData2.lv;
                        else
                            return c_ID1 > c_ID2;
                        end
                    else
                        return quality1 > quality2;
                    end
                else
                    return race1 > race2;
                end
            end
        else
            return idOne > idTwo;
        end
    end
    table.sort(idDataTable,sortFunc)
end
--[[--
    cards数据排序类型
]]
function M.getCardSortType(self)
    return self.m_cardSortType;
end

--[[--
    获得卡牌的数量
]]
function M.getCardsCount(self)
    return #self.m_tCardsIdTable;
end

--[[--
    卡牌数量
]]
function M.getCardCountByCid(self,cId,selId)
    local tempCount = 0;
    local tostring = tostring;
    cId = tostring(cId);
    selId = tostring(selId);
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    for k,v in pairs(self.m_tCardsData) do
        if tostring(v.c_id) == cId and tostring(k) ~= selId then
            local itemCfg = character_detail_cfg:getNodeWithKey(tostring(v.c_id));
            if itemCfg then
                local existFlag1 = self:heroInTeamById(v.id)
                local existFlag2 = self:heroInAssistantById(v.id)
                if not (existFlag1 or existFlag2) then
                    tempCount = tempCount + 1;
                end
            end
        end
    end
    return tempCount;
end

--[[--
    获得cards数据表
]]
function M.getTableCardsData(self)
    return self.m_tCardsData;
end

--[[--
    通过id获得card数据
]]
function M.getCardDataById(self,cardId)
    local cardData = self.m_tCardsData[tostring(cardId)];
    if cardData == nil then return nil,nil end
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardData.c_id));
    return cardData,heroCfg;
end

--[[
    通过index获得card数据
]]--
function M.getCardDataByIndex(self,index)
    if index > 0 and index <= #self.m_tCardsIdTable then
        return self:getCardDataById(self.m_tCardsIdTable[index]);
    end
    return nil,nil;
end
--[[ 
    返回符合要求的card数据   --品质返回    --专给分解用的，exchange_id > 0 才给用
]]--
function M.getCardsDataByQuality(self,quality)
    -- local cardsTable = self:getTableCardsData();
    local tempIdTable = {};
    for k,v in pairs(self.m_tCardsData) do
        local cardData,heroCfg = self:getCardDataById(tostring(k));
        local my_quality = heroCfg:getNodeWithKey("quality"):toInt();
        local exchange_id = heroCfg:getNodeWithKey("exchange_id"):toInt()
        if my_quality >= quality and exchange_id > 0 then
            table.insert(tempIdTable,tostring(k));
            -- tempIdTable[tostring(k)] = v;
        end
    end
    return tempIdTable;
end
--[[ 
    返回符合要求的card数据   --专一品质返回    品质是紫卡以上才有效，  品质大于3，返回特定品质的卡牌，如quality=3返回紫卡
]]--
function M.getCardsDataByQualityUnique(self,quality,cardsTable)
    -- local cardsTable = self:getTableCardsData();
    local tempIdTable = {};
    for i=1,#cardsTable do
        local cardData,heroCfg = self:getCardDataById(tostring(cardsTable[i]));
        local my_quality = heroCfg:getNodeWithKey("quality"):toInt();
        local exchange_id = heroCfg:getNodeWithKey("exchange_id"):toInt()
        if quality >= 3 then
            if my_quality == quality and exchange_id > 0 then
                table.insert(tempIdTable,tostring(cardsTable[i]));
            end
        else
            table.insert(tempIdTable,tostring(cardsTable[i]));
        end
    end
    return tempIdTable;
end
--[[--
    通过id获得  裁剪过的 card数据
]]
-- function M.getCardDataByIdWithQuality(self,cardId,quality)
--     local tempIdTable = self:getCardsDataByQuality(quality);
--     local cardData = tempIdTable[tostring(cardId)];
--     if cardData == nil then return nil,nil end
--     local character_detail_cfg = getConfig(game_config_field.character_detail);
--     local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardData.c_id));
--     return cardData,heroCfg;
-- end
--[[
    通过index获得  裁剪过的 card 表数据
]]--
-- function M.getCardDataByIndexWithQuality(self,index,quality)
--     local tempIdTable = self:getCardsDataByQuality(quality);
--     if index > 0 and index <= #tempIdTable then
--         return self:getCardDataByIdWithQuality(self.m_tCardsIdTable[index]);
--     end
--     return nil,nil;
-- end
--[[--
    通过index获得card id
]]
function M.getCardIdByIndex(self,index)
    if index > 0 and index <= #self.m_tCardsIdTable then
        return self.m_tCardsIdTable[index];
    end
    return nil;
end
--[[
    通过card id 得到index
]]--
function M.getIndexByCardId(self,cardId)
    for i=1,#self.m_tCardsIdTable do
        local card_id = self:getCardIdByIndex(i)
        if tostring(card_id) == tostring(cardId) then 
            return i;
        end
    end
    return nil;
end
--[[--
    更新卡牌数据
]]
function M.updateOneCardDataByJsonData(self,cardJsonData)
    if cardJsonData == nil then return end
    local cardData = json.decode(cardJsonData:getFormatBuffer());
    local cardId = tostring(cardData.id);
    if self.m_tCardsData[cardId] == nil then
        self.m_tCardsIdTable[#self.m_tCardsIdTable + 1] = cardId
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardData.c_id));
        if heroCfg and heroCfg:getNodeWithKey("quality"):toInt() > 3 then
            self.m_newCardIdTab[cardId] = 1;
            self.m_newCardIdTab.count = self.m_newCardIdTab.count + 1;
        end
    end
    self.m_tCardsData[cardId] = cardData;
end
--[[--
    更新卡牌数据
]]
function M.updateMoreCardDataByJsonData(self,cardsJsonData)
    if cardsJsonData == nil then return end
    local cardsCount = cardsJsonData:getNodeCount();
    for i=1,cardsCount do
        self:updateOneCardDataByJsonData(cardsJsonData:getNodeAt(i-1));
    end
    self:cardsSortByTypeName(self.m_cardSortType);
    -- cclog("updateMoreCardDataByJsonData ================cardsCount " .. cardsCount);
end

--[[--
    通过id移除卡牌数据
]]
function M.removeOneCardDataById(self,cardId)
    cardId = tostring(cardId);
    local removeIndex = nil;
    for k,v in pairs(self.m_tCardsIdTable) do
        if v == cardId then
            removeIndex = k;
            break;
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_tCardsIdTable,removeIndex);
        self.m_tCardsData[cardId] = nil;
    end
    if self.m_newCardIdTab[cardId] then
        self.m_newCardIdTab[cardId] = nil;
        self.m_newCardIdTab.count = self.m_newCardIdTab.count - 1;
    end
end
--[[--
    通过id表格移出卡牌数据
]]
function M.removeMoreCardDataByIdTable(self,tCardIds)
    if tCardIds == nil or type(tCardIds) ~= "table" then return end
    for k,v in pairs(tCardIds) do
        self:removeOneCardDataById(v);
    end
end

--[[--
    通过json数据设置编队数据
]]
function M.setTeamByJsonData(self,teamJsonData)
    if teamJsonData == nil then return end
    self.m_tTeamData = {};
    local alignmentData = teamJsonData:getNodeAt(0);
    local attackerCount = alignmentData:getNodeCount();
    local itemId = nil;
    for i=1,5 do
        if i <= attackerCount then
            itemId = alignmentData:getNodeAt(i-1);
            self.m_tTeamData[i] = itemId:toStr();
        else
            self.m_tTeamData[i] = "-1";
        end
    end

    alignmentData = teamJsonData:getNodeAt(1);
    attackerCount = alignmentData:getNodeCount();
    for i=1,5 do
        if i <= attackerCount and i < 4 then
            itemId = alignmentData:getNodeAt(i-1);
            self.m_tTeamData[i+5] = itemId:toStr();
        else
            self.m_tTeamData[i+5] = "-1";
        end
    end
    cclog("setTeamByJsonData ================ " .. #self.m_tTeamData);
end

--[[--
    通过pos和卡牌id改变编队数据
]]
function M.setTeamByPosAndCardId(self,posIndex,cardId)
    if posIndex > 0 and posIndex < 11 then
        self.m_tTeamData[posIndex] = tostring(cardId);
    end
end

--[[--
    通过pos编队数据
]]
function M.exchangeTeamDataByTwoPos(self,posIndex1,posIndex2)
    if posIndex1 > 0 and posIndex1 < 11 and posIndex2 > 0 and posIndex2 < 11 then
        self.m_tTeamData[posIndex1],self.m_tTeamData[posIndex2] = self.m_tTeamData[posIndex2],self.m_tTeamData[posIndex1]
        self.m_tEquipPosData[tostring(posIndex1-1)],self.m_tEquipPosData[tostring(posIndex2-1)] = self.m_tEquipPosData[tostring(posIndex2-1)],self.m_tEquipPosData[tostring(posIndex1-1)]
        cclog("exchangeTeamDataByTwoPos = " .. json.encode(self.m_tEquipPosData))
    end
end

--[[--
    通过pos获得位置的卡牌数据
]]
function M.getTeamCardDataByPos(self,posIndex)
    local cardId = self.m_tTeamData[posIndex];
    if cardId and cardId ~= "-1" then
        return self:getCardDataById(cardId);
    end
    return nil,nil;
end

--[[--
    通过pos获得助威位置的卡牌数据
]]
function M.getAssTeamCardDataByPos(self,posIndex)
    local cardId = self.m_tAssistant[posIndex] or "-1"
    return self:getCardDataById(cardId);
end

--[[--
    获得编队数据
]]
function M.getTeamData(self)
    return self.m_tTeamData;
end

--[[--
    设置编队数据
]]
function M.setTeamData(self,tempData)
    self.m_tTeamData = tempData;
end

--[[--
    获得编队中前排卡牌个数
]]
function M.getTeamFrontRowCount(self)
    local tempCount = 0;
    for i=1,5 do
        if self.m_tTeamData[i] ~= "-1" then
            tempCount = tempCount + 1;
        end
    end
    return tempCount;
end

--[[--
    判断是否可以替换
]]
function M.getExchangeTeamDataByTwoPosFlag(self,posIndex1,posIndex2)
    local returnFlag = false;
    if posIndex1 > 0 and posIndex1 < 11 and posIndex2 > 0 and posIndex2 < 11 then
        if posIndex1 < 6 and posIndex2 < 6 then
            returnFlag = true;
        elseif posIndex1 > 5 and posIndex2 > 5 then
            returnFlag = true;
        else
            local tempCount = 0;
            for i=1,5 do
                if self.m_tTeamData[i] ~= "-1" and i ~= posIndex1 then
                    tempCount = tempCount + 1;
                end
            end
            if posIndex2 > 5 then
                if self.m_tTeamData[posIndex2] ~= "-1" then
                    tempCount = tempCount + 1;
                end
            end
            if tempCount > 0 then
                returnFlag = true;
            end
        end
    end
    return returnFlag;
end

--[[--
    判断英雄是否在编队中
]]
function M.heroInTeamById(self,heroId)
    for k,v in pairs(self.m_tTeamData) do
        if v ~= "-1" and tostring(v) == tostring(heroId) then
            return true;
        end
    end
    return false;
end

--[[--
    获得英雄在编队中的位置
]]
function M.getHeroInTeamIndexById(self,heroId)
    for k,v in pairs(self.m_tTeamData) do
        if v ~= "-1" and tostring(v) == tostring(heroId) then
            return k;
        end
    end
    return -1;
end

--[[--
    判断英雄是否在助阵中
]]
function M.heroInAssistantById(self,heroId)
    for k,v in pairs(self.m_tAssistant) do
        if v ~= "-1" and tostring(v) == tostring(heroId) then
            return true;
        end
    end
    for k,v in pairs(self.m_tDestiny) do
        if v ~= "-1" and tostring(v) == tostring(heroId) then
            return true;
        end
    end
    return false;
end

--[[--
    激活卡牌技能
]]
function M.activationCardSkill(self,cardId,skillPos)
    local cardData,_ = self:getCardDataById(tostring(cardId));
    local skillItem = cardData["s_" .. skillPos];
    -- 'avail': 1   # 0表示未解锁，1表示解锁未激活，2表示激活
    skillItem.avail = 2;
end

--[[------------------------------------卡牌相关 end------------------------------------------- ]]


--[[------------------------------------装备相关 start------------------------------------------- ]]

--[[--
    equip数据排序
]]
function M.equipSortByTypeName(self,typeName)

-- 默认：1装备是否装备状态，2装备ID，3卡牌等级
-- 等级：1装备等级，2装备品质,3装备ID
-- 品质：1装备品质，2装备ID，3装备等级
-- 类型：1装备类型，2装备品质，3装备ID，4装备等级

    self.m_equipSortType = typeName;
    typeName = typeName or "default";
    local tempTab = self.m_tEquipData;
    local str = tostring;
    local equipCfg = getConfig(game_config_field.equip);
    local itemData1,itemData2,itemCfg1,itemCfg2,quality1,quality2,c_ID1,c_ID2,sort1,sort2

    local tTeamTab = {};
    local tempItem = nil;
    for i=1,9 do
        tempItem = self.m_tEquipPosData[tostring(i-1)]
        if tempItem then
            for j=1,4 do
                if tempItem[j] then
                    tTeamTab[str(tempItem[j])] = 10;
                end
            end
        end
        tempItem = self.m_tAssEquipPosData[tostring(i+99)]
        if tempItem then
            for j=1,4 do
                if tempItem[j] then
                    tTeamTab[str(tempItem[j])] = 5;
                end
            end
        end
    end
    local flag1,flag2;
    local function sortFunc(idOne,idTwo)
        itemData1 = tempTab[str(idOne)]
        itemData2 = tempTab[str(idTwo)]
        itemCfg1 = equipCfg:getNodeWithKey(tostring(itemData1.c_id));
        itemCfg2 = equipCfg:getNodeWithKey(tostring(itemData2.c_id));
        if itemCfg1 and itemCfg2 then
            quality1,quality2 = itemCfg1:getNodeWithKey("quality"):toInt(),itemCfg2:getNodeWithKey("quality"):toInt();
            c_ID1,c_ID2 = tonumber(itemData1.c_id),tonumber(itemData2.c_id)
            if typeName == "default" then
                flag1 = tTeamTab[str(itemData1.id)] or 0
                flag2 = tTeamTab[str(itemData2.id)] or 0
                if flag1 == flag2 then
                    if quality1 == quality2 then
                        return itemData1.id > itemData2.id;
                    else
                        return quality1 > quality2
                    end
                else
                    return flag1 > flag2
                end
            elseif typeName == "lv" then
                if itemData1.lv == itemData2.lv then
                    if quality1 == quality2 then
                        return c_ID1 > c_ID2
                    else
                        return quality1 > quality2
                    end
                else
                    return itemData1.lv > itemData2.lv
                end
            elseif typeName == "quality" then
                if quality1 == quality2 then
                    if c_ID1 == c_ID2 then
                        return itemData1.lv > itemData2.lv
                    else
                        return c_ID1 > c_ID2
                    end
                else
                    return quality1 > quality2
                end
            elseif typeName == "sort" then
                sort1,sort2 = itemCfg1:getNodeWithKey("sort"):toInt(),itemCfg2:getNodeWithKey("sort"):toInt();
                if sort1 == sort2 then
                    if quality1 == quality2 then
                        if c_ID1 == c_ID2 then
                            return itemData1.lv > itemData2.lv
                        else
                            return c_ID1 > c_ID2
                        end
                    else
                        return quality1 > quality2;
                    end
                else
                    return sort1 > sort2
                end
            end

        else
            return idOne > idTwo;
        end
    end
    table.sort(self.m_tEquipIdTable,sortFunc)
    cclog("equipSortByTypeName ----------------------------------" .. typeName)
    -- table.foreach(self.m_tEquipData,print)
end

--[[--
    获得当前排序
]]
function M.getEquipSortType(self)
    return self.m_equipSortType;
end

--[[--
    通过json数据设置装备数据
]]
function M.setEquipDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tEquipData = json.decode(jsonData:getFormatBuffer()) or {};
    if self.m_tEquipData ~= nil and type(self.m_tEquipData) == "table" then
        for k,v in pairs(self.m_tEquipData) do
            self.m_tEquipIdTable[#self.m_tEquipIdTable + 1] = k;
        end
    end
    self:equipSortByTypeName(self.m_equipSortType);
    cclog("setEquipDataByJsonData ================ count " .. #self.m_tEquipIdTable);
end

--[[--
    通过装备数据
]]
function M.getEquipData(self)
    return self.m_tEquipData;
end

--[[--
    装备数量
]]
function M.getEquipCount(self)
    return #self.m_tEquipIdTable;
end

--[[--
    装备数量
]]
function M.getEquipCountByCid(self,cId,selEquipId)
    local tempCount = 0;
    local tostring = tostring;
    cId = tostring(cId);
    selEquipId = tostring(selEquipId);
    local equipCfg = getConfig(game_config_field.equip);
    for k,v in pairs(self.m_tEquipData) do
        if tostring(v.c_id) == cId and tostring(k) ~= selEquipId then
            local itemCfg = equipCfg:getNodeWithKey(tostring(v.c_id));
            if itemCfg then
                local existFlag,_ = self:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),k)
                if not existFlag then
                    tempCount = tempCount + 1;
                end
            end
        end
    end
    return tempCount;
end


--[[--
    装备
]]
function M.getEquipIdTable(self)
    return self.m_tEquipIdTable or {};
end

--[[--
    通过id获得装备数据
]]
function M.getEquipDataById(self,equipId)
    equipId = tostring(equipId)
    local equipData = self.m_tEquipData[equipId];
    if equipData == nil then
        if equipId ~= "0" then
            -- cclog("equipId = " .. equipId .. " ; type(equipId) == " .. tostring(type(equipId)) .. " ; self.m_tEquipData == " .. json.encode(self.m_tEquipData))
        end
        return nil,nil
    end
    local equipCfg = getConfig(game_config_field.equip);
    local equipItemCfg = equipCfg:getNodeWithKey(tostring(equipData.c_id));
    return equipData,equipItemCfg;
end

--[[--
    通过id, 在装备池获得装备数据
]]
function M.getEquipDataByIdFromPool(self,equipId, gameData)
    equipId = tostring(equipId)
    local equipData = gameData[equipId];
    if equipData == nil then
        if equipId ~= "0" then
            -- cclog("equipId = " .. equipId .. " ; type(equipId) == " .. tostring(type(equipId)) .. " ; self.m_tEquipData == " .. json.encode(self.m_tEquipData))
        end
        return nil,nil
    end
    local equipCfg = getConfig(game_config_field.equip);
    local equipItemCfg = equipCfg:getNodeWithKey(tostring(equipData.c_id));
    return equipData,equipItemCfg;
end

--[[--
    通过 index 获得装备数据
]]
function M.getEquipDataByIndex(self,index)
    if index > 0 and index <= #self.m_tEquipIdTable then
        return self:getEquipDataById(self.m_tEquipIdTable[index]);
    end
    return nil,nil;
end

--[[--
    通过json数据设置卡牌位置装备数据
]]
function M.setEquipPosDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    -- self.m_tEquipPosData = json.decode(jsonData:getFormatBuffer()) or {};
    local temp_count = jsonData:getNodeCount();
    for i=1,temp_count do
        local itemData = jsonData:getNodeAt(i-1)
        local tempItemData = {};
        for j=1,4 do
            table.insert(tempItemData,itemData:getNodeAt(j-1):toStr())
        end
        self.m_tEquipPosData[itemData:getKey()] = tempItemData;
    end
    cclog("setEquipPosDataByJsonData ================ " .. json.encode(self.m_tEquipPosData));
end

--[[--
    得到卡牌位置装备数据
]]
function M.getEquipPosData(self)
    return self.m_tEquipPosData;
end

--[[--
    设置卡牌位置装备数据
]]
function M.setEquipPosData(self,tempData)
    self.m_tEquipPosData = tempData;
end

--[[--
    通过json数据设置助威卡牌位置装备数据
]]
function M.setAssEquipPosDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tAssEquipPosData = json.decode(jsonData:getFormatBuffer()) or {};
    local temp_count = jsonData:getNodeCount();
    for i=1,temp_count do
        local itemData = jsonData:getNodeAt(i-1)
        local tempItemData = {};
        for j=1,4 do
            table.insert(tempItemData,itemData:getNodeAt(j-1):toStr())
        end
        self.m_tAssEquipPosData[itemData:getKey()] = tempItemData;
    end
    -- cclog("setAssEquipPosDataByJsonData ================ " .. json.encode(self.m_tAssEquipPosData));
end

--[[--
    得到助威卡牌位置装备数据
]]
function M.getAssEquipPosData(self)
    return self.m_tAssEquipPosData or {}
end

--[[--
    设置助威卡牌位置装备数据
]]
function M.setAssEquipPosData(self,tempData)
    self.m_tAssEquipPosData = tempData;
end

--[[--
    设置阵型相应位置装备数据
]]
function M.updateEquipPosData(self,equipPos,equipType,equipId)
    if equipPos > 9 or equipPos < 0 or equipType > 4 or equipType < 1 then return end
    cclog("updateEquipPosData equipPos = " .. equipPos .. " ; equipType = " .. equipType .. " ; equipId = " .. equipId);
    self.m_tEquipPosData[tostring(equipPos)][equipType] = tostring(equipId);
    cclog("updateEquipPosData = " .. json.encode(self.m_tEquipPosData))
end

--[[--
    判断是否装备上
]]
function M.equipInEquipPos(self,equipType,equipId)
    equipId = tostring(equipId);
    local existFlag = false;
    local cardName = "";
    local posEquipData = nil;
    if equipType then
        for i=1,10 do
            if self.m_tEquipPosData[tostring(i-1)][equipType] == equipId then
                posEquipData = self.m_tEquipPosData[tostring(i-1)];
                existFlag = true
                local _,itemCfg = self:getTeamCardDataByPos(i);
                if itemCfg then
                    cardName = itemCfg:getNodeWithKey("name"):toStr();
                else
                    cardName = i .. string_helper.game_data.pos
                end
                break;
            end
            if self.m_tAssEquipPosData[tostring(i+99)][equipType] == equipId then
                posEquipData = self.m_tAssEquipPosData[tostring(i-1)];
                existFlag = true
                local _,itemCfg = self:getAssTeamCardDataByPos(i);
                if itemCfg then
                    cardName = string_helper.game_data.help .. itemCfg:getNodeWithKey("name"):toStr();
                else
                    cardName = string_helper.game_data.help .. i .. string_helper.game_data.pos
                end
                break;
            end
        end
    end
    return existFlag,cardName,posEquipData
end

--[[--
    通过json数据设置装备分类数据
]]
function M.setEquipSortDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tEquipSortData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setEquipSortDataByJsonData ================ ");
end


--[[--
    更新装备数据
]]
function M.updateOneEquipDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    local itemData = json.decode(jsonData:getFormatBuffer());
    local equipId = jsonData:getKey();
    if self.m_tEquipData[equipId] == nil then
        self.m_tEquipIdTable[#self.m_tEquipIdTable + 1] = equipId
        local equipCfg = getConfig(game_config_field.equip);
        local equipItemCfg = equipCfg:getNodeWithKey(tostring(itemData.c_id));
        if equipItemCfg and equipItemCfg:getNodeWithKey("quality"):toInt() > 2  then
            self.m_newEquipIdTab[equipId] = 1;
            self.m_newEquipIdTab.count = self.m_newEquipIdTab.count + 1;
        end
    end
    self.m_tEquipData[equipId] = itemData;
end
--[[--
    更新装备数据
]]
function M.updateMoreEquipDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    local itemCount = jsonData:getNodeCount();
    for i=1,itemCount do
        self:updateOneEquipDataByJsonData(jsonData:getNodeAt(i-1));
    end
    self:equipSortByTypeName(self.m_equipSortType);
    cclog("updateMoreEquipDataByJsonData ================itemCount " .. itemCount .. " ; #self.m_tEquipIdTable == " .. #self.m_tEquipIdTable);
    -- cclog(json.encode(self.m_tEquipData))
    -- cclog(json.encode(self.m_tEquipIdTable))
end
--[[--
    通过id移除装备数据
]]
function M.removeOneEquipDataById(self,itemId)
    itemId = tostring(itemId);
    local removeIndex = nil;
    for k,v in pairs(self.m_tEquipIdTable) do
        if v == itemId then
            removeIndex = k;
            break;
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_tEquipIdTable,removeIndex);
        self.m_tEquipData[itemId] = nil;
    end
    if self.m_newEquipIdTab[itemId] then
        self.m_newEquipIdTab[itemId] = nil;
        self.m_newEquipIdTab.count = self.m_newEquipIdTab.count - 1;
    end
end
--[[--
    通过id表格移出装备数据
]]
function M.removeMoreEquipDataByIdTable(self,itemIds)
    for k,v in pairs(itemIds) do
        self:removeOneEquipDataById(v);
    end
    cclog("removeMoreEquipDataByIdTable #self.m_tEquipIdTable ===== " .. #self.m_tEquipIdTable)
end


--[[--
    通过 equipType 获得装备数据
]]
function M.getEquipDataByEquipType(self,equipType)
    local tempTab = {};
    local equipCfg = getConfig(game_config_field.equip);
    local equipCfgItem = nil;
    local sort = nil;
    local itemData = nil;
    for k,v in pairs(self.m_tEquipIdTable) do
        v = tostring(v)
        itemData = self.m_tEquipData[v];
        -- cclog("id ==================== " .. v)
        if itemData then
            equipCfgItem = equipCfg:getNodeWithKey(itemData.c_id);
            sort = equipCfgItem:getNodeWithKey("sort"):toInt();
            if equipCfgItem ~= nil and sort ~= 0 then
                if equipType == nil then
                    tempTab[#tempTab + 1] = v;
                else
                    equipType = tonumber(equipType);
                    if equipType == -1 then
                        tempTab[#tempTab + 1] = v;
                    elseif sort == equipType then
                        tempTab[#tempTab + 1] = v;
                    end
                end
            end
        end
    end
    return tempTab;
end

--[[------------------------------------装备相关 end------------------------------------------- ]]


--[[--
    通过json数据设置阵型数据
]]
function M.setFormationDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tFormationData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setFormationDataByJsonData ================ ");
end

--[[--
    获得阵型数据
]]
function M.getFormationData(self)
    return self.m_tFormationData;
end

--[[--
    通过json数据更新阵型数据
]]
function M.updateOwnFormationDataByJsonData(self,jsonData)
    if jsonData == nil or jsonData:getNodeWithKey("own") == nil then return end
    self.m_tFormationData.own = json.decode(jsonData:getNodeWithKey("own"):getFormatBuffer()) or {};
    cclog("updateOwnFormationDataByJsonData ================ ");
end

--[[--
    通过json数据设置用户基础数据
]]
function M.setUserStatusDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    local lastLevel = self.m_tUserStatusData and self.m_tUserStatusData.level
    self.m_tUserStatusData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_action_point_add_time = self.m_tUserStatusData["action_point_rate"] or 360
    if lastLevel and self.m_tUserStatusData and self.m_tUserStatusData.level ~= lastLevel then
        if game_data_statistics and game_data_statistics.userLevelChanged and tonumber(self.m_tUserStatusData.level) then
            game_data_statistics:userLevelChanged({level = self.m_tUserStatusData.level});
        end
    end
    -- cclog("setUserStatusDataByJsonData ================ " .. json.encode(self.m_tUserStatusData["guide"]));
end

--[[--
    获得用户基础数据
]]
function M.getUserStatusData(self)
    return self.m_tUserStatusData or {};
end

--[[--
   
]]
function M.setUserStatusDataBackup(self)
    self.m_tUserStatusDataBackup = util.table_copy(self.m_tUserStatusData)
end

--[[--
    
]]
function M.getUserStatusDataBackup(self)
    return self.m_tUserStatusDataBackup or {};
end

--[[--
    
]]
function M.getActionPointTime(self,key)
    local point = 0;
    if self.m_tUserStatusData.action_point_max then
        point = self.m_tUserStatusData.action_point_max - self.m_tUserStatusData.action_point;
    end
    return point*self.m_action_point_add_time;
end
--[[
    获得行动力
]]
function M.getActionPointValue(self)
    return self.m_tUserStatusData.action_point;
end
--[[--
    获得
]]
function M.getMaxGuideIndex(self)
    local guide = self.m_tUserStatusData["guide"] or {};
    local maxGuideIndex = -1;
    for k,v in pairs(guide) do
        maxGuideIndex = math.max(maxGuideIndex,v);
    end
    return maxGuideIndex;
end

--[[--
    通过json数据设置建筑数据
]]
function M.setBuildingAbilityDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tBuildingAbilityData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setBuildingAbilityDataByJsonData ================ ");
end

--[[--
   获得建筑数据
]]
function M.getBuildingAbilityData(self)
    return self.m_tBuildingAbilityData;
end

--[[--
   通过key获得建筑数据
]]
function M.getBuildingAbilityDataByKey(self,key)
    return self.m_tBuildingAbilityData[key];
end

--[[--
    通过json数据设置资源数据
]]
function M.setResourceDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tResourceData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setResourceDataByJsonData ================ ");
end

--[[--
   获得资源数据
]]
function M.getResourceData(self)
    return self.m_tResourceData;
end

--[[--
   通过key获得资源数据
]]
function M.getResourceDataByKey(self,key)
    return self.m_tResourceData[key];
end

--[[--
    通过json数据设置建筑数据
]]
function M.setPrivateBuildingDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tPrivateBuildingData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setPrivateBuildingDataByJsonData ================ ");
end

--[[--
   获得建筑数据
]]
function M.getPrivateBuildingData(self)
    return self.m_tPrivateBuildingData;
end
--[[--
    全局计时器
]]
function M.initGlobalScheduler(self)
    if self.m_globalSchedulerHandle ~= nil then
        scheduler.unschedule(self.m_globalSchedulerHandle);
        self.m_globalSchedulerHandle = nil;
    end
    local durTime = 0;
    local actionDurTime = 0;
    local function globalSchedulerFunc(dt)
        durTime = durTime + dt;
        -- cclog("globalSchedulerFunc ==================dt = " .. tostring(dt) .. " ; durTime = " .. durTime);
        if durTime >= 60 then
            -- cclog("globalSchedulerFunc ==================" .. tostring(dt));
            if self.m_tResourceData.food_ability ~= nil then
                self.m_tResourceData.food_pool = self.m_tResourceData.food_pool + self.m_tResourceData.food_ability
            end
            if self.m_tResourceData.metal_ability ~= nil then
                self.m_tResourceData.metal_pool = self.m_tResourceData.metal_pool + self.m_tResourceData.metal_ability
            end
            if self.m_tResourceData.energy_ability ~= nil then
                self.m_tResourceData.energy_pool = self.m_tResourceData.energy_pool + self.m_tResourceData.energy_ability
            end
            durTime = 0;
        end
        -- actionDurTime = actionDurTime + dt;
        -- if actionDurTime >= self.m_action_point_add_time then
        --     local action_point = self.m_tUserStatusData.action_point
        --     if action_point ~= nil and action_point < self.m_tUserStatusData.action_point_max then
        --         self.m_tUserStatusData.action_point = action_point + 1;
        --         game_scene:fillPropertyBarData();
        --     end
        --     actionDurTime = 0;
        -- end
    end
    self.m_globalSchedulerHandle = scheduler.schedule(globalSchedulerFunc,1.0,false,false);
end

function M.setLastRequestTime(self)
    self.m_last_request_time = os.time();
end

function M.getLastRequestTime(self)
    return self.m_last_request_time;
end

--[[--
   通过json数据设置避难所数据
]]
function M.setHarborDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tHarborData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_tHarborData.dataTime = os.time();
    cclog("setHarborDataByJsonData ================ ");
    self:setLeaderSkillDataByJsonData(jsonData:getNodeWithKey("leader_skill"))
    self:setAvailableSkillTreeDataByJsonData(jsonData:getNodeWithKey("available_tree"))
    self:setAvailableSkillDataByJsonData(jsonData:getNodeWithKey("available_skill"))
end

--[[--
   获得避难所数据
]]
function M.getHarborData(self)
    return self.m_tHarborData;
end

--[[--
   通过json数据设置避难所数据
]]
function M.setLaboratoryDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tLaboratoryData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_tLaboratoryData.dataTime = os.time();
    cclog("setLaboratoryDataByJsonData ================ ");
end

--[[--
   获得避难所数据
]]
function M.getLaboratoryData(self)
    return self.m_tLaboratoryData;
end

--[[--
   通过json数据设置避难所数据
]]
function M.setSchoolDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tSchoolData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_tSchoolData.dataTime = os.time();
    cclog("setSchoolDataByJsonData ================ ");
end

--[[--
   获得避难所数据
]]
function M.getSchoolData(self)
    return self.m_tSchoolData;
end

--[[--
   通过json数据设置避难所数据
]]
function M.setFactoryDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tFactoryData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_tFactoryData.dataTime = os.time();
    cclog("setFactoryDataByJsonData ================ ");
end

--[[--
   获得避难所数据
]]
function M.getFactoryData(self)
    return self.m_tFactoryData;
end

--[[--
   设置选择的城市id
]]
function M.setSelCityId(self,cityId)
    self.m_selCityId = cityId;
end

--[[--
   获得选择的城市id
]]
function M.getSelCityId(self)
    -- print_lua_table(self, 5)
    return self.m_selCityId;
end

--[[--
   设置选择的城市id
]]
function M.setSelBuildingId(self,cityId)
    self.m_selBuildingId = cityId;
end

--[[--
   获得选择的城市id
]]
function M.getSelBuildingId(self)
    return self.m_selBuildingId;
end

--[[--
   获得时间差
]]
function M.getTimeDifference(self,time)
    time = time or self:getLastRequestTime();
    return os.time() - time;
end

--[[--
   通过json数据设置Gacha数据
]]
function M.setGachaDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tGachaData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setGachaDataByJsonData ================ ");
end

--[[--
   获得Gacha数据
]]
function M.getGachaData(self)
    return self.m_tGachaData;
end


--[[--
   设置战斗类型
]]
function M.setBattleType(self,battleType)
    self.m_battleType = battleType;
end

--[[--
   获得战斗类型
]]
function M.getBattleType(self)
    return self.m_battleType;
end

--[[--
    设置地图类型
    "normal", 普通关卡
    "hard", 精英团契啊
    nil, 重置之后
]]
function M.setMapType( self, type )
    self.m_mapType = type
end

--[[--
    获取地图类型
]]
function M.getMapType( self )
    return self.m_mapType
end



--[[--
   设置选择的中立城市
]]
function M.setSelNeutralCityId(self,selNeutralCityId)
    self.m_selNeutralCityId = selNeutralCityId;
end

--[[--
   获得选择的中立城市
]]
function M.getSelNeutralCityId(self)
    return self.m_selNeutralCityId;
end

--[[--
   设置选择的中立城市的建筑
]]
function M.setSelNeutralBuildingId(self,selNeutralBuildingId)
    self.m_selNeutralBuildingId = selNeutralBuildingId;
end

--[[--
   获得选择的中立城市的建筑
]]
function M.getSelNeutralBuildingId(self)
    return self.m_selNeutralBuildingId;
end

--[[--
   通过json数据设置选择的公会数据
]]
function M.setSelGuildDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_selGuildData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setSelGuildDataByJsonData ================ ");
end

--[[--
   获得选择的公会数据
]]
function M.getSelGuildData(self)
    return self.m_selGuildData;
end

--[[--
   通过json数据设置选择的公会列表数据
]]
function M.setGuildListDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_guildListData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setGuildListDataByJsonData ================ ");
end

--[[--
   获得选择的公会列表数据
]]
function M.getGuildListData(self)
    return self.m_guildListData;
end

--[[--
   通过json数据设置每日奖励数据
]]
function M.setDailyAwardDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_dailyAwardData.data = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_dailyAwardData.init = true
    cclog("setDailyAwardDataByJsonData ================ ");
end

--[[--
   获得每日奖励数据
]]
function M.getDailyAwardData(self)
    return self.m_dailyAwardData.data;
end

--[[--
   获得每日奖励init
]]
function M.getDailyAwardDataInit(self)
    return self.m_dailyAwardData.init;
end

--[[--
   缓存更新
]]
function M.clientCacheUpdate(self,jsonData)
    if jsonData == nil then return end
    local tempCards = jsonData:getNodeWithKey("cards");
    if tempCards then
        local cards = tempCards:getNodeWithKey("cards");
        if cards then
            local cardsUpdate = cards:getNodeWithKey("update");
            local cardsRemove = cards:getNodeWithKey("remove");
            self:updateMoreCardDataByJsonData(cardsUpdate);
            if cardsRemove:getNodeCount() ~= 0 then
                self:removeMoreCardDataByIdTable(json.decode(cardsRemove:getFormatBuffer()));
            end
            if tempCards:getNodeWithKey("open_position") then
                cclog("----------client cache update open_position");
                local updateData = tempCards:getNodeWithKey("open_position"):getNodeWithKey("update");
                self:setOpenPositionDataByJsonData(updateData);
            end
            if tempCards:getNodeWithKey("formation") then
                cclog("----------client cache update formation");
                local updateData = tempCards:getNodeWithKey("formation"):getNodeWithKey("update");
                self:updateOwnFormationDataByJsonData(updateData);
            end
        end
        local position_num = tempCards:getNodeWithKey("position_num");
        if position_num then
            self.m_tBattleCardNum.position_num = position_num:getNodeWithKey("update"):toInt();
        end
        local alternate_num = tempCards:getNodeWithKey("alternate_num");
        if alternate_num then
            self.m_tBattleCardNum.alternate_num = alternate_num:getNodeWithKey("update"):toInt();
        end
        local assistant = tempCards:getNodeWithKey("assistant");
        if assistant then
            self:setAssistantByJsonData(assistant:getNodeWithKey("update"));
        end
        local destiny = tempCards:getNodeWithKey("destiny");
        if destiny then
            self:setDestinyByJsonData(destiny:getNodeWithKey("update"));
        end
        local assistant_effect = tempCards:getNodeWithKey("assistant_effect");
        if assistant_effect then
            self:setAssistantEffectByJsonData(assistant_effect:getNodeWithKey("update"));
        end
    end
    if jsonData:getNodeWithKey("equip") then
        local equips = jsonData:getNodeWithKey("equip"):getNodeWithKey("_equip")
        if equips then
            local updateData = equips:getNodeWithKey("update")
            local removeData = equips:getNodeWithKey("remove")
            self:updateMoreEquipDataByJsonData(updateData)
            if removeData:getNodeCount() > 0 then
                self:removeMoreEquipDataByIdTable(json.decode(removeData:getFormatBuffer()));
            end
        end
    end
    if jsonData:getNodeWithKey("gem") then
        local equips = jsonData:getNodeWithKey("gem"):getNodeWithKey("_gem")
        if equips then
            local updateData = equips:getNodeWithKey("update")
            local removeData = equips:getNodeWithKey("remove")
            self:updateMoreGemDataByJsonData(updateData)
            if removeData:getNodeCount() > 0 then
                self:removeMoreGemDataByIdTable(json.decode(removeData:getFormatBuffer()));
            end
        end
    end
    if jsonData:getNodeWithKey("item")then
        cclog("----------client cache update item");
        local items = jsonData:getNodeWithKey("item"):getNodeWithKey("items");
        if items then
            local updateData = items:getNodeWithKey("update");
            local removeData = items:getNodeWithKey("remove");
            self:updateMoreItemDataByJsonData(updateData);
            if removeData:getNodeCount()>0 then
                self:removeMoreItemDataById(removeData);
            end
        end
    end

    cclog("clientCacheUpdate ================ ");
end
--[[--
    接口返回的数据
]]
function M.responseGameData(self,gameData)
    self:setLastRequestTime();
    local data = gameData:getNodeWithKey("data")
    self:updateInreviewByJsonData(data:getNodeWithKey("inreview"))
    self:updateServerInreviewByJsonData(data:getNodeWithKey("server_inreview_close"))
    self:updateActiveInreviewByJsonData(data:getNodeWithKey("active_switch"))
    self:setUserStatusDataByJsonData(gameData:getNodeWithKey("user_status"));
    self:clientCacheUpdate(data:getNodeWithKey("_client_cache_update"));
end
--[[--
    获取卡牌的装备数据
]]
function M.getEquipDataByCardId(self,cardId)
    local equipData = {"0","0","0","0"};
    for k,v in pairs(self.m_tTeamData) do
        if tostring(v) == tostring(cardId) then
            local equipPosIndex = k - 1;
            local equipPosData = self.m_tEquipPosData[tostring(equipPosIndex)];
            if equipPosData then
                for i=1,4 do
                    local eId = equipPosData[i];
                    if eId and eId ~= "0" then
                        equipData[i] = self.m_tEquipData[tostring(eId)];
                    end
                end
            end
            break;
        end
    end
    return equipData;
end

--[[--
   通过json数据设置道具数据
]]
function M.setItemsDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_itemsData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setItemsDataByJsonData ================ ");
end

--[[--
    更新单个道具消息
]]

function M.updateOneItemDataByJsonData( self,jsonData )
    -- body
    if jsonData==nil then return end
    
    -- local itemData = json.decode(cardJsonData:getFormatBuffer());
    -- if self.m_tCardsData[tostring(cardData.id)] == nil then
    --     self.m_tCardsIdTable[#self.m_tCardsIdTable + 1] = tostring(cardData.id);
    -- end
    -- self.m_tCardsData[tostring(cardData.id)] = cardData;
    local itemKey = jsonData:getKey();
    local itemValue = {};
    local nodeCount = jsonData:getNodeCount();
    for i=1,nodeCount do
        itemValue[i] = jsonData:getNodeAt(i-1):toInt();
    end
    -- if self.m_itemsData[itemKey] == nil and (tonumber(itemKey) < 1000 or tonumber(itemKey) >= 3000) then
    --     self.m_newItemIdTab[itemKey] = 1;
    --     self.m_newItemIdTab.count = self.m_newItemIdTab.count + 1;
    -- end
    self.m_itemsData[itemKey]=itemValue;
end

--[[--
    更新多个道具消息
]]
function M.updateMoreItemDataByJsonData( self,jsonData )
    -- body
    if(jsonData == nil)then return end
    local nodeCount = jsonData:getNodeCount();
    -- cclog("1 = " .. json.encode(self.m_itemsData))
    for i=1,nodeCount do
        self:updateOneItemDataByJsonData(jsonData:getNodeAt(i-1));
    end
    -- cclog("2 = " .. json.encode(self.m_itemsData))
end

--[[--
    移出单个道具
]]
function M.removeMoreItemDataById( self,jsonData )
    -- body
    if(jsonData == nil)then return end
    local nodeCount = jsonData:getNodeCount();
    for i=1,nodeCount do
        self.m_itemsData[jsonData:getNodeAt(i-1):toStr()] = nil;
    end
end

--[[--
   获得道具数据
]]
function M.getItemsData(self)
    return self.m_itemsData;
end
--[[--
    获得道具数量
]]
function M.getItemsCount( self )
    -- body
    -- util.printf(self.m_itemsData);
    local i = 0;
    for k,v in pairs(self.m_itemsData) do
        i=i + (#v);
    end
    cclog(" --------- getItemsCount -----------" .. i)
    return i;
    -- return #self.m_itemsData;
end

--[[--
    获得制定道具数量
]]
function M.getItemCountByCid( self ,cId)
    local tempData = self.m_itemsData[tostring(cId)] or {}
    local count = 0;
    for k,v in pairs(tempData) do
        if type(v) == "table" then
            count=count + (#v);
        else
            count=count + v;
        end
    end
    if count > 0 then
        cclog(" --------- getItemCountByCid -----------" .. count .. " ; cId = " .. cId)
    end
    return count;
end

function M.getItemIdAndCountAt( self,index )
    -- body
    
    local i=0;
    -- cclog("---------------------item index----------" .. tostring(index) .. "i:" .. tostring(i));
    local cid,count = 0,0;
    for k,v in pairs(self.m_itemsData) do
        for j,u in pairs(v) do
            i=i+1;
            if(i>=index)then
                cid=k;
                count=u;
                return cid,count;
            end
        end
    end
    return cid,count;
end

--[[--
   游戏进入后台
]]
function M.didEnterBackground(self)
    self.m_enterBackgroundTime = os.time();
end

--[[--
   游戏从后台唤醒
]]
function M.willEnterForeground(self)
    if self.m_tUserStatusData.action_point == nil then return end
    local diffTime = os.time() - self.m_enterBackgroundTime;
    local action_point = self.m_tUserStatusData.action_point;
    self.m_tUserStatusData.action_point = math.min(self.m_tUserStatusData.action_point_max,action_point + math.floor(diffTime/self.m_action_point_add_time))
    cclog("action_point ===" .. action_point .. " ; self.m_tUserStatusData.action_point =====" .. self.m_tUserStatusData.action_point)
end

--[[--
    通过json数据设置位置数据
]]
function M.setOpenPositionDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_openPositionData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setOpenPositionDataByJsonData ================ ");
end

--[[--
   获得位置数据
]]
function M.getOpenPositionData(self)
    return self.m_openPositionData;
end

--[[--
   获得位置数据
]]
function M.getOpenPositionFlagByIndex(self,index)
    local flag = false;
    if self.m_openPositionData and type(self.m_openPositionData) == "table" then
        for k,v in pairs(self.m_openPositionData) do
            if tostring(v) == tostring(index) then
                flag = true;
            end
        end
    end
    return flag;
end

--[[--
   通过json数据设置主角技能数据
]]
function M.setLeaderSkillDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_leaderSkillData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setLeaderSkillDataByJsonData ================ ");
end

--[[--
   获得主角技能
]]
function M.getLeaderSkillData(self)
    return self.m_leaderSkillData or {};
end

--[[--
   通过json数据设置主角技能树数据
]]
function M.setAvailableSkillTreeDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_availableSkillTreeData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setAvailableSkillTreeDataByJsonData ================ ");
end

--[[--
   获得技能树数据
]]
function M.getAvailableSkillTreeData(self)
    return self.m_availableSkillTreeData or {};
end
     
--[[--
   通过json数据设置主角开启的技能数据
]]
function M.setAvailableSkillDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_availableSkill = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setAvailableSkillDataByJsonData ================ ");
end

--[[--
   获得主角开启的技能
]]
function M.getAvailableSkillData(self)
    return self.m_availableSkill or {};
end

--[[--
   设置再次探险标记
]]
function M.setReMapBattleFlag(self,flag)
    self.m_reMapBattleFlag = flag;
    cclog("setReMapBattleFlag ================ ");
end
--[[
    
]]
function M.setRecoverFlag( self,flag )
    self.RecoverFlag = flag
end
function M.getRecoverFlag( self)
    return self.RecoverFlag
end
--[[--
   获得再次探险标记
]]
function M.getReMapBattleFlag(self)
    return self.m_reMapBattleFlag;
end

--[[--
   通过json数据设置服务器数据
]]
function M.setServerDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(3) end -- 获取到服务列表数据
    self.m_serverData = json.decode(jsonData:getFormatBuffer()) or {};
    local function sortFunc(data1,data2)
        return data1.sort_id > data2.sort_id
    end
    table.sort(self.m_serverData,sortFunc)
    cclog("setServerDataByJsonData ================ ");
end

--[[--
   获得服务器数据
]]
function M.getServerData(self)
    return self.m_serverData or {};
end

--[[
    获取开服时间戳
]]
function M.getServerOpenTime( self )
    local serData = self:getServer() or {}
    return serData.open_time 
end

--[[--
   通过json数据设置服务器id
]]
function M.setServerId(self,serverId)
    self.m_selServerId = serverId;
    CCUserDefault:sharedUserDefault():setStringForKey("server_id",self.m_selServerId);
    CCUserDefault:sharedUserDefault():flush();
    cclog("setServerId ==================" .. serverId)
end

--[[--
   通过json数据获得选择的服务器id
]]
function M.getServerId(self)
    local serverId = CCUserDefault:sharedUserDefault():getStringForKey("server_id")
    serverId = serverId ~= "" and serverId or self.m_selServerId;
    return serverId;
end

--[[--
   获得服务器数据
]]
function M.getServer(self)
    if self.m_selServerId == nil or self.m_selServerId == "" then
        self.m_selServerId = CCUserDefault:sharedUserDefault():getStringForKey("server_id");
    end
    local selServerData = nil;
    local index = 1;
    for k,v in pairs(self.m_serverData) do
        if tostring(v.server) == tostring(self.m_selServerId) then
            selServerData = v;
            index = k;
            break;
        end
    end
    if selServerData == nil and self.m_serverData[index] then
        selServerData = self.m_serverData[index];
        self.m_selServerId = self.m_serverData[index].server;
        self:setServerId(self.m_selServerId);
    end
    -- cclog("getServer ==================" .. tostring(self.m_selServerId) .. " ; selServerData = " .. tostring(selServerData))
    -- cclog("selServerData == " .. json.encode(selServerData))
    -- selServerData.open_time = 1402156800 - 2 * 24 * 3600  - 10 * 3600
    return selServerData,index;
end

--[[--
    获取 opeing 天数
]]
function M.getOpeningDayNum( self )
    -- return 2
    return self.opening_award_expire 
end

--[[--
    通过key获得用户基础数据
]]
function M.getUserStatusDataByKey(self,key)
    -- if key == "server_time" then
    --     return 140215680 + 1 * 24 * 3600 + 1
    -- end
    return self.m_tUserStatusData[key];
end

function M.printUserStatusData( self )
    if type(cclog3) == "function" then
        cclog3( self.m_tUserStatusData )
    end
end

--[[--
   设置公告数据
]]
function M.setNoticesDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tNoticesData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setNoticesDataByJsonData ================ ");
end

--[[--
   获得公告数据
]]
function M.getNoticesData(self)
    return self.m_tNoticesData;
end

--[[--
    设置小伙伴数据
]]
function M.setAssistantByJsonData( self,jsonData )
    -- body
    if jsonData==nil then
        return;
    end
    self.m_tAssistant = json.decode(jsonData:getFormatBuffer());
end

--[[--
    获取小伙伴数据
]]
function M.getAssistant( self )
    -- body
    return self.m_tAssistant or {};
end

--[[--
    设置小伙伴数据
]]
function M.setAssistantEffectByJsonData( self,jsonData )
    -- body
    if jsonData == nil then return end
    self.m_tAssistantEffect = json.decode(jsonData:getFormatBuffer());
end

--[[--
    获取小伙伴数据
]]
function M.getAssistantEffect( self )
    -- body
    return self.m_tAssistantEffect or {};
end

--[[--
    设置命运小伙伴数据
]]
function M.setDestinyByJsonData( self,jsonData )
    -- body
    if jsonData == nil then return end
    self.m_tDestiny = json.decode(jsonData:getFormatBuffer());
end

--[[--
    获取命运小伙伴数据
]]
function M.getDestiny( self )
    -- body
    return self.m_tDestiny or {};
end

--[[
    设置运营活动开启接口 -- 限时神将， 限时积分
]]
function M.setActiveOpenData(self,jsonData)
    cclog("setActiveOpenData --------------- ")
    if jsonData == nil then return end
    self.openTable = json.decode(jsonData:getFormatBuffer()) or {};
end
function M.getActiveOpenData( self )
    return self.openTable or {}
end
--[[--
   更新MainPage接口数据
]]
function M.updateMainPageByJsonData(self,jsonData)
    if jsonData == nil then return end
    self:updateInreviewByJsonData(jsonData:getNodeWithKey("inreview"))
    self:updateServerInreviewByJsonData(jsonData:getNodeWithKey("server_inreview_close"))
    self:setActiveOpenData(jsonData:getNodeWithKey("actives"))
    self:setBuildingAbilityDataByJsonData(jsonData:getNodeWithKey("building_ability"))
    self:setPrivateBuildingDataByJsonData(jsonData:getNodeWithKey("private_building"))
    self:setResourceDataByJsonData(jsonData:getNodeWithKey("resource"))
    self:setNoticesDataByJsonData(jsonData:getNodeWithKey("notices"))
    self:setAlertsDataByJsonData(jsonData:getNodeWithKey("alerts"));
    self.m_arenaRank = jsonData:getNodeWithKey("arena_rank"):toInt();
    self.m_arenaPoint = jsonData:getNodeWithKey("arena_point"):toInt();

    local foundation_status = jsonData:getNodeWithKey("foundation_status")
    if foundation_status then
        self.foundation_status = foundation_status:toBool();
    end
    local server_foundation_status = jsonData:getNodeWithKey("server_foundation_status")
    if server_foundation_status then
        self.server_foundation_status = server_foundation_status:toBool();
    end
    if jsonData:getNodeWithKey("online_award_expire") then
        self.m_online_award_expire = jsonData:getNodeWithKey("online_award_expire"):toInt();--在线领奖时间
    end
    if jsonData:getNodeWithKey("onlinw_awawrd_id") then
        self.m_onlinw_awawrd_id = jsonData:getNodeWithKey("onlinw_awawrd_id"):toInt();--第几次领取
    end
    self.buy_ap_times = jsonData:getNodeWithKey("buy_ap_times"):toInt();--第几次购买体力
    local tempShop = jsonData:getNodeWithKey("shop")
    if tempShop then
        self.shopData = json.decode(tempShop:getFormatBuffer()) or {};
    end
    -- if jsonData:getNodeWithKey("opening_award_expire") then
    --     self.opening_award_expire = jsonData:getNodeWithKey("opening_award_expire"):toInt() or 14
    -- end
    if jsonData:getNodeWithKey("opening_award_expire") then 
        self.opening_award_expire = jsonData:getNodeWithKey("opening_award_expire"):toInt() or 14
    end 
    -- cclog("jsonData == " .. jsonData:getFormatBuffer())
end

--[[--
    更新inreview数据
]]
function M.updateInreviewByJsonData(self,jsonData)
    if not ( jsonData and jsonData:getFormatBuffer() ) then return end
    -- print("   updateInreviewByJsonData  info ", jsonData:getFormatBuffer())
    local info = json.decode(jsonData:getFormatBuffer()) or {}
    -- print_lua_table( info or {}, 8)
    -- self.m_curInReviewButton = nil
    -- self.m_curInReviewButton = {}
    for i,v in ipairs(info) do
        -- print("updateInreviewByJsonData ==== ", i,v)
        if v ~= nil then
            self.m_curInReviewButton["in_review_" .. tostring(v)] = "close"
        end
    end
    -- self.m_curInReviewButton["37"] = "close"  -- 测试
    -- self.m_curInReviewButton["41"] = "close"
    -- self.m_curInReviewButton["36"] = "close"
    -- self.m_curInReviewButton["38"] = "close"
end

--[[--
    更新server_inreview数据
]]
function M.updateServerInreviewByJsonData(self, jsonData)
    if not ( jsonData and jsonData:getFormatBuffer() ) then return end
    local info = json.decode(jsonData:getFormatBuffer()) or {}
    for i,v in pairs(info) do
        if v ~= nil then
            self.m_curInReviewButton["in_review_" .. tostring(v)] = "close"
        end
    end
end

--[[--
    检查按钮是否开启    
]]
function M.isViewOpenByID( self, viewID )
    -- print("will check is view open ", viewID, "value is ", self.m_curInReviewButton[tostring(viewID)])
    if self.m_curInReviewButton["in_review_" .. tostring(viewID)] == "close" then
        return false
    end
    -- 先查找inview表 default 决定默认显示  show_lv 决定是显示需要等级
    local inreview_cfg = getConfig(game_config_field.inreview)
    local btnInfo = inreview_cfg:getNodeWithKey( tostring(viewID) )

    if btnInfo then
        -- local default = btnInfo:getNodeWithKey("default") and btnInfo:getNodeWithKey("default"):toInt() or nil
        -- if default ~= 1 then return false end  --  default为1才显示
        local playerLevel = self:getUserStatusDataByKey("level") or 1;
        local showLevel = btnInfo:getNodeWithKey("show_lv") and btnInfo:getNodeWithKey("show_lv"):toInt() or 1
        if showLevel > playerLevel then return false end  --  等级大于显示等级才显示
    end
    -- 查找server_inreview表  通inreview表
    local server_inreview_cfg = getConfig(game_config_field.server_inreview)
    local btnInfo = server_inreview_cfg:getNodeWithKey( tostring(viewID) )
    if btnInfo then 
        -- local default = btnInfo:getNodeWithKey("default") and btnInfo:getNodeWithKey("default"):toInt() or nil
        -- if default ~= 1 then return false end  --  default为1才显示
        local playerLevel = self:getUserStatusDataByKey("level") or 1;
        local showLevel = btnInfo:getNodeWithKey("show_lv") and btnInfo:getNodeWithKey("show_lv"):toInt() or 1
        if showLevel > playerLevel then return false end  --  等级大于显示等级才显示
    end
    return true
end

--[[--
    检查按钮显示等级   
    -- 根据inview表 show_lv 决定是否显示某些按钮
]]
function M.isViewShowByID( self, viewID )
    -- if viewID == 129 then return false end
    if not self:isViewOpenByID(viewID) then return false end  -- 功能被是被关闭的，直接隐藏
    local inreview_cfg = getConfig(game_config_field.inreview)
    local btnInfo = inreview_cfg:getNodeWithKey( tostring(viewID) )
    if btnInfo then
        local playerLevel = self:getUserStatusDataByKey("level") or 1;
        local showLevel = btnInfo:getNodeWithKey("show_lv") and btnInfo:getNodeWithKey("show_lv"):toInt() or 1
        if showLevel > playerLevel then return false end
    end
    return true
end


--[[--
    更新server_inreview数据
]]
function M.updateActiveInreviewByJsonData(self, jsonData)
    if not ( jsonData and jsonData:getFormatBuffer() ) then return end
    local info = json.decode(jsonData:getFormatBuffer()) or {}
    self.m_curInReviewOpenButton = {}
    for i,v in pairs(info) do
        self.m_curInReviewOpenButton["in_review_" .. tostring(i)] = {level = v}
    end
end

--[[--
    检查可多次活动按钮显示   
    -- 根据active_inview表
]]
function M.isActiveOpenByID( self, viewID )
    -- 列表有 活动按钮显示  
    -- do return true end
    -- cclog2(self.m_curInReviewOpenButton, "self.m_curInReviewOpenButton  ========   ")
    local info = self.m_curInReviewOpenButton["in_review_" .. tostring(viewID)]
    -- cclog2(info, "info  ========   ")
    if info then
        local playerLevel = self:getUserStatusDataByKey("level") or 1;
        if playerLevel >= tonumber(info.level or 0) then
            return true
        end
    end
    return false
end

--[[--
   更新CardsOpen接口数据
]]
function M.updateCardsOpenByJsonData(self,jsonData)
    if jsonData == nil then return end
    self:setAssistantByJsonData(jsonData:getNodeWithKey("assistant"));
    self:setAssistantEffectByJsonData(jsonData:getNodeWithKey("assistant_effect"));
    self:setDestinyByJsonData(jsonData:getNodeWithKey("destiny"));
    self:setTeamByJsonData(jsonData:getNodeWithKey("alignment"));
    self:setEquipPosDataByJsonData(jsonData:getNodeWithKey("equip_pos"));
    self:setAssEquipPosDataByJsonData(jsonData:getNodeWithKey("ass_equip_pos"));
    self:setEquipSortDataByJsonData(jsonData:getNodeWithKey("equip_sort"));
    self:setFormationDataByJsonData(jsonData:getNodeWithKey("formation"));
    self:setItemsDataByJsonData(jsonData:getNodeWithKey("items"));
    self:setOpenPositionDataByJsonData(jsonData:getNodeWithKey("open_position"));
    self:setLeaderSkillDataByJsonData(jsonData:getNodeWithKey("leader_skill"))
    self:setAvailableSkillTreeDataByJsonData(jsonData:getNodeWithKey("available_tree"))
    self:setAvailableSkillDataByJsonData(jsonData:getNodeWithKey("available_skill"))
    self:setCardsByJsonData(jsonData:getNodeWithKey("cards"));
    self:setEquipDataByJsonData(jsonData:getNodeWithKey("equip"));
    self:setBattleCardNumByJsonData(jsonData:getNodeWithKey("battle_card_num"));
    self:setCommanderAttrsByJsonData(jsonData:getNodeWithKey("commander_attrs"))
    self:setGemPosDataByJsonData(jsonData:getNodeWithKey("gem_pos"));
    self:setGemDataByJsonData(jsonData:getNodeWithKey("gem"));
end

--[[--
   设置按钮提示数据
]]
function M.setAlertsDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_alertsData = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
   获得按钮提示数据
]]
function M.getAlertsData(self)
    return self.m_alertsData or {};
end

--[[--
   获得排名
]]
function M.getArenaRank(self)
    return self.m_arenaRank or 0;
end

--[[--
   获得竞技场点
]]
function M.getArenaPoint(self)
    return self.m_arenaPoint or 0;
end

--[[
    获得领奖时间
]]
function M.getOnlineExpire(self)
    return self.m_online_award_expire or -2;
end
--[[
    第几次领取
]]
function M.getOnlineExpireTimes(self)
    return self.m_onlinw_awawrd_id or -2;
end
--[[
    第几次购买体力
]]
function M.getBuyActionTimes(self)
    return self.buy_ap_times or 0;
end
--[[
    设置购买体力次数
]]
function M.setBuyActionTimes(self,times)
    self.buy_ap_times = times
end
--[[--
   获取所有的按钮提示标记
]]
function M.getAllAlertsData(self)
    return self.m_alertsData;
end
--[[--
   打印所有的按钮提示标记
]]
function M.printAllAlertsData(self)
    print("all alert data is ")
    print_lua_table(self.m_alertsData, "5")
end
--[[--
   通过key获得按钮提示标记
]]
function M.getAlertsDataByKey(self,key)
    local atertFalg = self.m_alertsData[key]
    -- if atertFalg == nil then atertFalg = false end
    return atertFalg;
end
--[[--
    强制使用等级礼包
]]
function M.useLevelGiftByLevel(self, level)
    -- print("  use gift level ", level, self.m_alertsData["level_gift"])
    if self.m_alertsData["level_gift"] then
        self.m_alertsData["level_gift"][tostring(level)] = nil
        local num  = 0
        for i,v in pairs(self.m_alertsData["level_gift"]) do
            num = num + 1
        end
        if num <= 0 then
           self.m_alertsData["level_gift"] = nil
       end  
    end
end

--[[--
   设置活动数据
]]
function M.setActiveDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_activeData = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
   获得活动数据
]]
function M.getActiveData(self)
    return self.m_activeData or {};
end

--[[--
   设置选择的活动数据
]]
function M.setSelActiveDataByKeyAndValue(self,key,value)
    self.m_selActiveData[tostring(key)] = value;
end

--[[--
   获得选择的活动数据
]]
function M.getSelActiveDataByKey(self,key)
    return self.m_selActiveData[tostring(key)];
end

--[[--
   设置背景音乐名称
]]
function M.setBackgroundMusicName(self,musicName)
    if musicName == nil then musicName = "" end
    self.m_backgroundMusicName = musicName;
end

--[[--
   获得背景音乐名称
]]
function M.getBackgroundMusicName(self)
    return self.m_backgroundMusicName;
end

--[[--
    获得可用的背包个数
]]
function M.getAvailableCardBackpackNum(self)
    local card_max = self.m_tUserStatusData["card_max"] or 0;
    local card_num = self:getCardsCount();
    return card_max - card_num;
end
--[[
    获得经验球的经验
]]
function M.getBallExp(self)
    local ballExp = self.m_tUserStatusData["exp_ball"] or 9999;
    return ballExp
end
--[[
    获得装备可用的背包个数
]]
function M.getAvailableEquipBackpackNum(self)
    local equip_max = self.m_tUserStatusData["equip_max"] or 0;
    local equip_num = self:getEquipCount();
    return equip_max - equip_num;
end
--[[--
   获得选中城市自动战斗次数
]]
function M.getSelCitySweepLogData(self)
    self.m_selCitySweepLogData = self.m_tSelCityData.sweep_log
    return self.m_selCitySweepLogData or {};
end
--[[
    通过city id 修改扫荡次数
]]
function M.setSweepLogData(self,buildingId,count)
    self.m_selCitySweepLogData[tostring(buildingId)] = count
end
--[[--
   增加自动战斗的次数
]]
function M.addSelCitySweepLogDataByBuildingId(self,buildingId)
    buildingId = tostring(buildingId);
    self.m_selCitySweepLogData = self.m_tSelCityData.sweep_log
    if self.m_selCitySweepLogData[buildingId] == nil then
        self.m_selCitySweepLogData[buildingId] = 1;
    else
        self.m_selCitySweepLogData[buildingId] = self.m_selCitySweepLogData[buildingId] + 1;
    end
end

--[[--
   设置选中城市数据
]]
function M.setSelCityDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tSelCityData = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
   获得选中城市数据
]]
function M.getSelCityData(self)
    return self.m_tSelCityData or {};
end

--[[--
   设置选中城市数据
]]
function M.setSelNeutralCityDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tSelNeutralCityData = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
   获得选中城市数据
]]
function M.getSelNeutralCityData(self)
    return self.m_tSelNeutralCityData or {};
end

--[[--
   设置阵型中的出战的数量
]]
function M.setBattleCardNumByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tBattleCardNum = json.decode(jsonData:getFormatBuffer()) or {};
    self:resetBattleCardNumData();
end

--[[--
   获得阵型中的出战的数量
]]
function M.getBattleCardNumData(self)
    return self.m_tBattleCardNum or {};
end

--[[--
   获得阵型位置开启提示
]]
function M.getOpenFormationAlertFlag(self)
    local tempFlag = false;
    if self.m_tBattleCardNum.position_num > self.m_tBattleCardNum.temp_position_num or self.m_tBattleCardNum.alternate_num > self.m_tBattleCardNum.temp_alternate_num then
        tempFlag = true;
    end
    return tempFlag, self.m_tBattleCardNum.position_num
end
--[[
    获得活动开启提示
]]
function M.openActiveAlertFlag(self)
    local tempFlag = false
    if self.m_active == 1 then
        tempFlag = true
    end
    return tempFlag
end
--[[--
   
]]
function M.resetBattleCardNumData(self)
    self.m_tBattleCardNum.temp_position_num = self.m_tBattleCardNum.position_num
    self.m_tBattleCardNum.temp_alternate_num = self.m_tBattleCardNum.alternate_num
end

--[[
    获得vip等级
]]
function M.getVipLevel(self)
    return self.m_tUserStatusData.vip;
end
--[[
    获得当前vip经验
]]
function M.getVipExp( self )
    return self.m_tUserStatusData.vip_exp;
end
--[[
    获得免费训练次数
]]
function M.getFreeTrainTimes(self)
    return self.m_tUserStatusData.free_train_times;
end

--[[--
   设置临时战斗力
]]
function M.setTempCombatValue(self,value)
    self.tempCombatValue = value
end

--[[--
   获得临时战斗力
]]
function M.getTempCombatValue(self)
    return self.tempCombatValue or 0;
end

--[[--
   重置新卡牌id表
]]
function M.resetNewCardIdTab(self)
    self.m_newCardIdTab = {count = 0};
end

--[[--
   重置新装备id表
]]
function M.resetNewEquipIdTab(self)
    self.m_newEquipIdTab = {count = 0};
end

--[[--
   重置新道具id表
]]
function M.resetNewItemIdTab(self)
    self.m_newItemIdTab = {count = 0};
end

--[[--
   判断是否是新卡牌
]]
function M.isNewCardFlagById(self,tempId)
    return self.m_newCardIdTab[tostring(tempId)] ~= nil;
end

--[[--
    判断是否是新装备
]]
function M.isNewEquipFlagById(self,tempId)
    return self.m_newEquipIdTab[tostring(tempId)] ~= nil;
end

--[[--
    判断是否是新道具
]]
function M.isNewItemFlagById(self,tempId)
    return self.m_newItemIdTab[tostring(tempId)] ~= nil;
end

--[[--
   获得新卡牌标记
]]
function M.getNewCardFlag(self)
    if self.m_newCardIdTab.count > 0 then
        return true
    end
    return false
end

--[[--
   获得新装备标记
]]
function M.getNewEquipFlag(self)
    if self.m_newEquipIdTab.count > 0 then
        return true
    end
    return false
end

--[[--
    获得新道具标记
]]
function M.getNewItemFlag(self)
    return self.m_newItemIdTab.count > 0;
end

--[[--
   设置当前战斗id
]]
function M.setCurrentFightId(self,tempId)
    self.m_currentFightId = tostring(tempId);
end

--[[--
    获得当前战斗id
]]
function M.getCurrentFightId(self)
    return self.m_currentFightId
end

--[[--
   设置
]]
function M.setCurrChapterTypeName(self,chapterTypeName)
    self.m_currChapterTypeName = chapterTypeName;
end

--[[--
    获得
]]
function M.getCurrChapterTypeName(self)
    return self.m_currChapterTypeName
end
--[[--

]]
function M.getEvolutionCfgByHeroCfg(self,itemCfg)
    local evo_kind = nil;
    if itemCfg then
        evo_kind = itemCfg:getNodeWithKey("evo_kind")
        if evo_kind then
            evo_kind = evo_kind:toInt();
        else
            evo_kind = itemCfg:getNodeWithKey("quality"):toInt();
        end
    end
    return self:getEvolutionCfgByQuality(evo_kind);
end
--[[--

]]
function M.getEvolutionCfgByQuality(self,quality)
    local evolutionCfg = nil;
    quality = quality or 0;
    if quality < 3 then
        evolutionCfg = getConfig(game_config_field.evolution);
    elseif quality == 3 then
        evolutionCfg = getConfig(game_config_field.evolution_3);
    elseif quality == 4 then
        evolutionCfg = getConfig(game_config_field.evolution_4);
    elseif quality > 4 then
        evolutionCfg = getConfig(game_config_field.evolution_5);
    end
    return evolutionCfg;
end

--[[--
    获得
]]
function M.getMaxLvCardFlag(self)
    local tempFlag = false;
    local maxFlag = false;
    local tempCount = 0;
    for k,v in pairs(self.m_tCardsIdTable) do
        local itemData,itemCfg = self:getCardDataById(v)
        if itemCfg:getNodeWithKey("character_ID"):toInt() == 38 and itemCfg:getKey() == "3800" then
            tempCount = tempCount + 1;
            -- local quality = itemCfg:getNodeWithKey("quality"):toInt();
            local evolutionCfg = self:getEvolutionCfgByHeroCfg(itemCfg)--self:getEvolutionCfgByQuality(quality);
            if evolutionCfg then
                local evo = itemData.evo
                local tempEvoItem = evolutionCfg:getNodeWithKey(tostring(evo+1))
                if tempEvoItem then
                    if itemData.lv >= tempEvoItem:getNodeWithKey("need_level"):toInt() then
                        maxFlag = true;
                    end
                end
            end
            if tempCount > 1 and maxFlag == true then
                tempFlag = true;
                break;
            end
        end
    end
    return tempFlag;
end
--[[
    获得商店的数据
]]
function M.getShopData(self)
    return self.shopData
end
--[[
    设置商店购买数据
]]
function M.setShopData(self,shopId,bought)
    self.shopData.items[tostring(shopId)].bought = bought
end
--[[
    获得
]]
function M.getNoUseEquipCountTab(self)
    local tempTab = {0,0,0,0}
    for k,v in pairs(self.m_tEquipPosData) do
        for index,id in pairs(v) do
            if id ~= "0" then
                tempTab[index] = tempTab[index] - 1;
            end
        end
    end
    for k,v in pairs(self.m_tAssEquipPosData) do
        for index,id in pairs(v) do
            if id ~= "0" then
                tempTab[index] = tempTab[index] - 1;
            end
        end
    end
    local equipCfg = getConfig(game_config_field.equip);
    local equipCfgItem = nil;
    local sort = nil;
    for k,itemData in pairs(self.m_tEquipData) do
        equipCfgItem = equipCfg:getNodeWithKey(itemData.c_id);
        sort = equipCfgItem:getNodeWithKey("sort"):toInt();
        if sort > 0 and sort < 5 then
            tempTab[sort] = tempTab[sort] + 1;
        end
    end
    -- table.foreach(tempTab,print)
    return tempTab;
end

--[[--
    stageID 与 chapter 对应关系
]]
function M.getChapterByStage( self, stageID )
    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(stageID)):toStr();
    local main_story_item = map_main_story_cfg:getNodeWithKey(cityOrderId);
    local chapterId = main_story_item:getNodeWithKey("chapter"):toStr();
    return chapterId
end




--[[--
   设置 recipeId  itemId
]]
function M.setCommanderRecipeData(self,key,tempId)
    self.m_commanderData[tostring(key)] = tempId;
end

--[[--
    获得
]]
function M.getCommanderRecipeData(self)
    return self.m_commanderData
end

--[[--
   设置 
]]
function M.setCommanderAttrsByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_commanderData.commanderAttrs = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
    获得
]]
function M.getCommanderAttrsData(self)
    return self.m_commanderData.commanderAttrs or {};
end

--[[--
    读取保存在本地的数据
]]
function M.getLocalGameData( self )
    local localData = {}
    -- local filePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "other/";
    -- local data_json = util.readFile(filePath .. "local.configtea")
    -- if data_json then
    --     print(" local data is ", data_json)
    --     localData = json.decode(data_json) or {}
    -- end
    localData["m_task_btn_date"] = CCUserDefault:sharedUserDefault():getStringForKey("m_task_btn_date")
    localData["shencundakaoyan"] = CCUserDefault:sharedUserDefault():getStringForKey("shencundakaoyan")
    -- print("localData[m_task_btn_date]  -- ", localData["m_task_btn_date"] , " -- this is the info -- tonumber is ", tonumber(localData["m_task_btn_date"]), "end")
    if localData["m_task_btn_date"] == nil then
        -- print("localData[m_task_btn_date]  -- ", "is nil")
    end

    return localData 
end

function M.updateLocalData( self, key, data, isNew)
    if key == nil or type(key) ~= "string" then return end
    if data or isNew then
        if type(data) == "table" then data = json.encode(data) or data end
        self.m_tLocalGameData[key] = data 
        CCUserDefault:sharedUserDefault():setStringForKey(key, tostring(data))
        CCUserDefault:sharedUserDefault():flush();
        -- self:saveLocaData()
    end
    if self.m_tLocalGameData[key] then
        return self.m_tLocalGameData[key]
    end
    self.m_tLocalGameData[key] = CCUserDefault:sharedUserDefault():getStringForKey(tostring(key))
    return self.m_tLocalGameData[key]
end

-- function M.saveLocaData( self )
--     local teaKey = getGameTeaKey()
--     local filePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "other/";
--     local tempText = json.encode( self.m_tLocalGameData )
--     -- local tempText = CCCrypto:encryptXXTEALua(tempText,string.len(tempText),teaKey,string.len(teaKey));
--     local fullpath = filePath .. "local.configtea"
--     local ret = util.writeFile(fullpath,tempText);
-- end


--[[--
    获取用户本地数据
]]
function M.getUserLocalData( self )
    local key = "local_" .. ( self:getUserStatusDataByKey("uid") or "default" )
    local userdatas = CCUserDefault:sharedUserDefault():getStringForKey( key )
    -- cclog2(key, "will check this one data ==== ")
    -- cclog2(userdatas, "check this one userdatas ==== ")
    if type(userdatas) ~= "string" or userdatas == "" then 
        local defaultUserData = json.encode( {} )
        CCUserDefault:sharedUserDefault():setStringForKey(key, defaultUserData)
        CCUserDefault:sharedUserDefault():flush();
        return {}
    end
    return json.decode( userdatas )
end

--[[--
    根据key获取用户本地数据
]]
function M.getUserLocalDataByKey( self, key )
    local localUserData = self:getUserLocalData() or {}
    return localUserData[key]
end

--[[--
    根据key保存用户本地数据
]]
function M.setUserLocalDataByKey( self, key, data )
    local localUserData = self:getUserLocalData()
    -- cclog2(data, "will setUserLocalDataByKey ")
    -- cclog2(key, "will setUserLocalDataByKey  key  ===  ")
    if data == nil then
        localUserData[key] = data
    elseif type(data) == "table" then
        localUserData[key] = data
    elseif type(data) ~= "userdata" and type(data) ~= "function" then 
        localUserData[key] = data
    end 
    
    local user_key = "local_" .. ( self:getUserStatusDataByKey("uid") or "default" )
    local defaultUserData = json.encode( localUserData )
    -- cclog2(user_key, "will check this one data ==== ")
    -- cclog2(localUserData, "check this one localUserData ==== ")
    CCUserDefault:sharedUserDefault():setStringForKey(user_key, defaultUserData)
    CCUserDefault:sharedUserDefault():flush();
end


--[[--
    
]]
function M.getEquipGuideFlag(self)
    local tempFlag = true;
    for k,v in pairs(self.m_tEquipPosData) do
        if v[1] ~= "0" then
            tempFlag = false;
            break;
        end
    end
    return tempFlag;        
end
--[[
    保存手机号
]]
function M.setPhoneNum(self,phoneNum)
    self.m_phone_num = phoneNum
end
--[[
    得到手机号
]]
function M.getPhoneNum(self)
    return self.m_phone_num
end

--[[--
    通过json数据设置数据
]]
function M.setMapWorldByJsonData(self,jsonData)
    if jsonData == nil then
        return;
    end
    self.m_mapWorldData = json.decode(jsonData:getFormatBuffer()) or {};
end

--[[--
    通过json数据设置数据
]]
function M.getMapWorldData(self)
    return self.m_mapWorldData;
end

--[[--
    聊天数据
]]
function M.addOneChat( self, msg )
    local maxMsg = self.m_chatData.maxMsg
    if not msg or type(msg) ~= "table" then return end
    local kqgFlag = msg.kqgFlag
    local key = nil
    if kqgFlag == 'world' or kqgFlag == "system" or kqgFlag == 'guild' or kqgFlag == 'friend' then
        key = "world"
        self:insertOneChat(key, msg)
    end

    if kqgFlag == "outdoor" or kqgFlag == "system" or kqgFlag == 'friend'then
        key = "outdoor"
        self:insertOneChat(key, msg)
    end

    if kqgFlag == 'guild' then
        key = "guild"
        self:insertOneChat(key, msg)
    end
    if kqgFlag == 'friend' then
        key = "friend"
        self:insertOneChat(key, msg)
    end
    if kqgFlag == "guild_war" then
        key = "guild_war"
        self:insertOneChat(key, msg)
    end

    -- print("kqgFlag =======  ", kqgFlag, " key ==== ", key)

    -- -- print("msg data == ", json.encode(msg))
    -- if not key or not self.m_chatData[key] then return end

    -- local msgData = self.m_chatData[key].data
    -- local flag = false
    -- for i=1, #msgData do
    --     if msgData[i] and msgData[i].user == msg.user then
    --         if msg.dsign and msg.dsign ==  msgData[i].dsign then return end
    --         if msg.content == msgData[i].content  then
    --             print(msg.content == msgData[i].content)
    --             for j = i, #msgData - 1 do
    --                 self.m_chatData[key].data[j] = self.m_chatData[key].data[j + 1]
    --                 if j+ 1 == #msgData then
    --                      self.m_chatData[key].data[j + 1] = msg
    --                      return
    --                 end
    --             end
    --         end
    --     end
    -- end



    -- if(self.m_chatData[key].curMsg>=maxMsg)then
    -- for i=1, maxMsg-1 do
    --     self.m_chatData[key].data[i] = self.m_chatData[key].data[i + 1]
    -- end
    --     self.m_chatData[key].data[self.m_chatData[key].curMsg] = msg
    -- else
    --     self.m_chatData[key].curMsg = self.m_chatData[key].curMsg + 1
    --     self.m_chatData[key].data[self.m_chatData[key].curMsg] = msg
    -- end
    -- print("get one msg type == ", key, " all data is ", key and json.encode(self.m_chatData[key]), "end")
end

function M.insertOneChat( self, key, msg )
    local maxMsg = self.m_chatData.maxMsg
    -- body
    -- print("msg data == ", json.encode(msg))
    if not key or not self.m_chatData[key] then return end

    local msgData = self.m_chatData[key].data
    local flag = false
    for i=1, #msgData do
        if msgData[i] and msgData[i].user == msg.user then
            if msg.dsign and msg.dsign ==  msgData[i].dsign then return end
            if msg.content == msgData[i].content  then
                print(msg.content == msgData[i].content)
                for j = i, #msgData - 1 do
                    self.m_chatData[key].data[j] = self.m_chatData[key].data[j + 1]
                    if j+ 1 == #msgData then
                         self.m_chatData[key].data[j + 1] = msg
                         return
                    end
                end
            end
        end
    end

    if(self.m_chatData[key].curMsg>=maxMsg)then
    for i=1, maxMsg-1 do
        self.m_chatData[key].data[i] = self.m_chatData[key].data[i + 1]
    end
        self.m_chatData[key].data[self.m_chatData[key].curMsg] = msg
    else
        self.m_chatData[key].curMsg = self.m_chatData[key].curMsg + 1
        self.m_chatData[key].data[self.m_chatData[key].curMsg] = msg
    end
end

--[[
    宝藏难度
]]
function M.setTreasure(self,treasure)
    self.m_treasure = treasure
end
--[[
    
]]
function M.getTreasure(self)
    return self.m_treasure
end
--[[--
    查看是否可以发送消息    
]]
function M.isCanChat( self, key )
   local lastTime = self.m_chatTime[key] 
   if not lastTime or os.time() - lastTime >= 10 then
        return true
    end
    return false
end

--[[ --
    更新说话时间
]]
function M.updateChatTime( self, key )
    self.m_chatTime[key] = os.time()
end

--[[--
    获取聊天数据
]]
function M.getChats( self, key )
    return self.m_chatData[key]
end

--[[
    记录SDKAccount
]]
function M.setSDKAccount( self, account )
    self.m_sdkAccount = account
end

--[[
    获取SDKAccount
]]
function M.getSDKAccount( self )
    return self.m_sdkAccount
end
--[[
    设置数据
]]
function M.setDataByKeyAndValue( self, key , value)
    self[tostring(key)] = value;
end
--[[
    获取数据
]]
function M.getDataByKey( self , key)
    return self[tostring(key)]
end

--[[--
    通用
]]
function M.getMetalByJsonData(self,jsonData)
    if jsonData == nil then return end
    return self:rewardTipsByDataTable(json.decode(jsonData:getFormatBuffer()));
end

--[[
    判断是否在训练中
]]
function M.getCardTrainingFlag(self,itemData)
    local trainingFlag = false;
    if itemData and itemData.remove_avail then
        for k,v in pairs(itemData.remove_avail) do
            if tostring(v) == "train" then
                trainingFlag = true;
                break;
            end
        end
    end
    return trainingFlag;
end
--stepleve 卡牌或者装备等级  breakleve 卡牌转生等级或者装备精炼等级
function M.getMetalByTable(self,dataTable,stepleve,breakleve,material_type)
    material_type = material_type or 0
    local equipCfg = getConfig(game_config_field.equip);
    local materialData = {};
    local count = 0;
    local typeValue = 0;
    if dataTable then
        typeValue = dataTable[1]
        local tempId = dataTable[2];
        if typeValue == 1 then--食品，占位，参数数量；[1,0,100]
            count = self.m_tUserStatusData.food or 0;
        elseif typeValue == 2 then--金属，占位，参数数量；[2,0,100]
            count = self.m_tUserStatusData.metal or 0;
        elseif typeValue == 3 then--能源，占位，能源数量；[3,0,100]
            count = self.m_tUserStatusData.energy or 0;
        elseif typeValue == 4 then--能晶，占位，能晶数量；[4,0,100]
            count = self.m_tUserStatusData.crystal or 0;
        elseif typeValue == 5 then--卡牌，卡牌ID,数量；[5,4,1]
            for k,v in pairs(self.m_tCardsData) do
                --进阶>=5的不显示
                if (material_type == 0 and v.evo < 5) or material_type == 1 then
                    local ishave = self:heroInTeamById(v.id) or self:heroInAssistantById(v.id) or self:getCardTrainingFlag(v)
                    if tempId == tonumber(v.c_id) and not ishave and stepleve <= tonumber(v.step)  then
                        cclog("v.step)== " .. v.step .. "tonumber(v.bre) = " .. v.bre)
                    end
                    if tempId == tonumber(v.c_id) and not ishave and stepleve <= tonumber(v.step) and breakleve <= tonumber(v.bre) then
                    -- if tempId == tonumber(v.c_id)  then
                        table.insert(materialData,k)
                        cclog("v.step1)== " .. v.step .. "tonumber(v.bre1) = " .. v.bre)
                    end
                end
            end
            count = #materialData;
        elseif typeValue == 6 then--道具，ID,数量；[6,4,1]
            count = self:getItemCountByCid(tempId);
        elseif typeValue == 7 then--装备,ID，数量；[7,4,1]
            for k,v in pairs(self.m_tEquipData) do
                local itemCfg = equipCfg:getNodeWithKey(v.c_id)
                local existFlag,_ = self:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),v.id)
                if tempId == tonumber(v.c_id) and existFlag == false and stepleve <= tonumber(v.lv) and breakleve <= tonumber(v.st_lv) then
                    table.insert(materialData,k)
                    cclog("m_tEquipData ==== " .. json.encode(v))
                end
            end
            count = #materialData;
        elseif typeValue == 8 then--玩家经验，占位，数值;[8,0,100]
            count = self.m_tUserStatusData.exp or 0;
        elseif typeValue == 9 then--钻石,占位，数量;[9,0,1]
            count = self.m_tUserStatusData.coin or 0;
        elseif typeValue == 10 then--强能之尘,占位，数量;[10,0,1]
            count = self.m_tUserStatusData.dirt_silver or 0;
        elseif typeValue == 11 then--超能之尘,占位，数量;[11,0,1]
            count = self.m_tUserStatusData.dirt_gold or 0;
        elseif typeValue == 12 then--阵石,占位，数量;[12,0,1]
            count = 0;
        elseif typeValue == 13 then--行动力,占位，数量;[13,0,1]
            count = self.m_tUserStatusData.action_point or 0;
        elseif typeValue == 14 then--星灵,占位，数量;[14,0,1]
            count = self.m_tUserStatusData.star or 0;
        elseif typeValue == 15 then--金币,占位，数量;[15,0,1]
            count = self.m_tUserStatusData.silver or 0;
        elseif typeValue == 16 then--精炼石
            count = self.m_tUserStatusData.metalcore or 0; 
        elseif typeValue == 100 then--功勋,占位,数量；[100,0,1]
            count = 0; 
        end
    end
    --cclog("materialData count == " .. #materialData)
    local function sortFunc(data1,data2)
        if typeValue == 5 then
            local itemData1,_ = self.m_tCardsData[data1];
            local itemData2,_ = self.m_tCardsData[data2];
            if itemData1 and itemData2 then
                -- return itemData1.evo < itemData2.evo;--先按进阶排序，再按等级排序
                if itemData1.evo == itemData2.evo then
                    return itemData1.lv < itemData2.lv
                else
                    return itemData1.evo < itemData2.evo
                end
            else
                 return false;
            end
        elseif typeValue == 7 then
            local itemData1,_ = self.m_tEquipData[data1];
            local itemData2,_ = self.m_tEquipData[data2];
            if itemData1 and itemData2 then
                return itemData1.lv < itemData2.lv;
            else
                 return false;
            end
        end
    end
    table.sort(materialData,sortFunc)
    return materialData,count;
end

function M.startChat( self )
    if not self.m_chat then
        self.m_chat = require("chat_data")
        self.m_chat:startChat()
    else 
        self.m_chat:updateState()
    end
end

function M.getChatObserver( self )
    return self.m_chat
end

function M.resetChatObserver( self )
    if self.m_chat then 
        self.m_chat:close()
    end
    self.m_chat = nil
end

function M.removeChatLinster( self, name )
    if self.m_chat then 
        self.m_chat:removeOneLinster( name ) 
    end
end

function M.updateChatRoom( self, room )
    if self.m_chat then 
        self.m_chat:updateChatRoom( room ) 
    end
end

function M.setForceGuideInfo( self, guide_info)
    self.m_force_guide_info = guide_info
end

function M.resetForceGuideInfo( self, key)
    if self.m_force_guide_info and self.m_force_guide_info.guide_team == key then
        self.m_force_guide_info = nil
    end
end


function M.getForceGuideInfo( self )
    return self.m_force_guide_info
end

--[[
    设置上一个打开的活动的 chapterid
]]
function M.setLeatestActivityIndex( self, index )
    -- cclog2(index, "setLeatestActivityIndex  index ====== ")
    self.m_leatestShowActivityIndex = index
end

--[[
    获取上一个打开的活动的 chapterid
]]
function M.getLeatestActivityIndex( self )
    return self.m_leatestShowActivityIndex
end


function M.updateGuildName( self, guildName )
    cclog2(updateGuildName, "updateGuildName guildName")
    if guildName and guildName ~= self.m_guildName then
        self.m_guildName = guildName 
    end
    return self.m_guildName
end


--[[--
   设置引导过程阶段
]]
function M.setGuideProcess(self, guideProcess)
    self.m_guideProcess = guideProcess;
end

--[[--
   获得引导过程阶段
]]
function M.getGuideProcess(self)
    return self.m_guideProcess;
end
--[[------------------------------------宝石相关 start------------------------------------------- ]]
--[[--
    gem数据排序

    m_tGemData = {},--宝石数据
    m_tGemIdTable = {},--宝石id对应表
    m_tGemPosData = {},--卡牌位置宝石数据
    m_newGemIdTab = {count = 0},
    m_gemSortType = "default",

]]
function M.gemSortByTypeName(self,typeName)

-- 默认：1宝石是否宝石状态，2宝石ID，3宝石等级
-- 等级：1宝石等级，2宝石品质,3宝石ID
-- 品质：1宝石品质，2宝石ID，3宝石等级
-- 类型：1宝石类型，2宝石品质，3宝石ID，4宝石等级

    self.m_gemSortType = typeName;
    self:gemSortByTypeNameWithTable(typeName,self.m_tGemIdTable)
    cclog("gemSortByTypeName ----------------------------------" .. typeName)
    -- table.foreach(self.m_tGemData,print)
end

function M.gemSortByTypeNameWithTable(self,typeName,idDataTable)
    typeName = typeName or "default";
    local tempTab = self.m_tGemData;
    local tostring = tostring;
    local tempCfg = getConfig(game_config_field.gem);
    local itemData1,itemData2,itemCfg1,itemCfg2,quality1,quality2,c_ID1,c_ID2,sort1,sort2

    local tTeamTab = {};
    local tempItem = nil;
    for i=1,8 do
        tempItem = self.m_tGemPosData[tostring(i-1)]
        if tempItem then
            for j=1,4 do
                if tempItem[j] then
                    tTeamTab[tostring(tempItem[j])] = 1;
                end
            end
        end
    end
    local flag1,flag2;
    local function sortFunc(idOne,idTwo)
        itemData1 = tempTab[tostring(idOne)] or 0
        itemData2 = tempTab[tostring(idTwo)] or 0
        itemCfg1 = tempCfg:getNodeWithKey(tostring(idOne));
        itemCfg2 = tempCfg:getNodeWithKey(tostring(idTwo));
        if itemCfg1 and itemCfg2 then
            quality1,quality2 = itemCfg1:getNodeWithKey("quality"):toInt(),itemCfg2:getNodeWithKey("quality"):toInt();
            c_ID1,c_ID2 = tonumber(idOne),tonumber(idTwo)
            if typeName == "default" then
                flag1 = tTeamTab[tostring(idOne)] or 0
                flag2 = tTeamTab[tostring(idTwo)] or 0
                if flag1 == flag2 then
                    if quality1 == quality2 then
                        return itemData1 > itemData2
                    else
                        return quality1 > quality2
                    end
                else
                    return flag1 > flag2
                end
            elseif typeName == "count" then
                if itemData1 == itemData2 then
                    if quality1 == quality2 then
                        return c_ID1 > c_ID2
                    else
                        return quality1 > quality2
                    end
                else
                    return itemData1 > itemData2
                end
            elseif typeName == "quality" then
                if quality1 == quality2 then
                    if c_ID1 == c_ID2 then
                        return itemData1 > itemData2
                    else
                        return c_ID1 > c_ID2
                    end
                else
                    return quality1 > quality2
                end
            elseif typeName == "career" then
                sort1,sort2 = itemCfg1:getNodeWithKey("career"):toInt(),itemCfg2:getNodeWithKey("career"):toInt();
                if sort1 == sort2 then
                    if quality1 == quality2 then
                        if c_ID1 == c_ID2 then
                            return itemData1 > itemData2
                        else
                            return c_ID1 > c_ID2
                        end
                    else
                        return quality1 > quality2;
                    end
                else
                    return sort1 > sort2
                end
            end

        else
            return idOne > idTwo;
        end
    end
    table.sort(idDataTable,sortFunc)
end

--[[--
    获得当前排序
]]
function M.getGemSortType(self)
    return self.m_gemSortType;
end

--[[--
    通过json数据设置宝石数据
]]
function M.setGemDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tGemData = json.decode(jsonData:getFormatBuffer()) or {};
    if self.m_tGemData ~= nil and type(self.m_tGemData) == "table" then
        for k,v in pairs(self.m_tGemData) do
            self.m_tGemIdTable[#self.m_tGemIdTable + 1] = k;
        end
    end
    self:gemSortByTypeName(self.m_gemSortType);
    cclog("setGemDataByJsonData ================ count " .. #self.m_tGemIdTable);
end

--[[--
    通过宝石数据
]]
function M.getGemData(self)
    return self.m_tGemData;
end

function M.addGemDataByCid(self, c_id, count)
    c_id = tostring(c_id)
    if c_id == "0" then return end
    count = count or 1;
    if self.m_tGemData[c_id] then
        self.m_tGemData[c_id] = math.max(0,self.m_tGemData[c_id] + count)
    else
        self.m_tGemData[c_id] = count;
    end
end

function M.minusGemDataCid(self, c_id, count)
    c_id = tostring(c_id)
    count = count or 1;
    if self.m_tGemData[c_id] then
        self.m_tGemData[c_id] = math.max(0,self.m_tGemData[c_id] - count)
    end
end

--[[--
    宝石数量
]]
function M.getGemCount(self)
    return #self.m_tGemIdTable;
end

--[[--
    宝石数量
]]
function M.getGemCountByCid(self,cId,selTmepId)
    local tempCount = 0;
    local tostring = tostring;
    cId = tostring(cId);
    selTmepId = tostring(selTmepId);
    local tempCfg = getConfig(game_config_field.gem);
    for k,v in pairs(self.m_tGemData) do
        if tostring(v.c_id) == cId and tostring(k) ~= selTmepId then
            local itemCfg = tempCfg:getNodeWithKey(tostring(v.c_id));
            if itemCfg then
                local existFlag,_ = self:gemInGemPos(itemCfg:getNodeWithKey("career"):toInt(),k)
                if not existFlag then
                    tempCount = tempCount + 1;
                end
            end
        end
    end
    return tempCount;
end


--[[--
    宝石
]]
function M.getGemIdTable(self)
    return self.m_tGemIdTable or {};
end

--[[--
    通过id获得宝石数据
]]
function M.getGemDataById(self,tempId)
    tempId = tostring(tempId)
    local tempData = self.m_tGemData[tempId];
    if tempData == nil then
        if tempId ~= "0" then
            cclog("tempId = " .. tempId .. " ; type(tempId) == " .. tostring(type(tempId)) .. " ; self.m_tGemData == " .. json.encode(self.m_tGemData))
        end
        return nil,nil
    end
    local tempCfg = getConfig(game_config_field.gem);
    local tempItemCfg = tempCfg:getNodeWithKey(tostring(tempId));
    return tempData,tempItemCfg;
end

--[[--
    通过id, 在宝石池获得宝石数据
]]
function M.getGemDataByIdFromPool(self,tempId, gameData)
    tempId = tostring(tempId)
    local tempData = gameData[tempId];
    if tempData == nil then
        if tempId ~= "0" then
            cclog("tempId = " .. tempId .. " ; type(tempId) == " .. tostring(type(tempId)) .. " ; self.m_tGemData == " .. json.encode(self.m_tGemData))
        end
        return nil,nil
    end
    local tempCfg = getConfig(game_config_field.gem);
    local tempItemCfg = tempCfg:getNodeWithKey(tostring(tempId));
    return tempData,tempItemCfg;
end

--[[--
    通过 index 获得宝石数据
]]
function M.getGemDataByIndex(self,index)
    if index > 0 and index <= #self.m_tGemIdTable then
        return self:getGemDataById(self.m_tGemIdTable[index]);
    end
    return nil,nil;
end

--[[--
    通过json数据设置卡牌位置宝石数据
]]
function M.setGemPosDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    self.m_tGemPosData = json.decode(jsonData:getFormatBuffer()) or {};
    cclog("setGemPosDataByJsonData ================ " .. json.encode(self.m_tGemPosData));
end

--[[--
    得到卡牌位置宝石数据
]]
function M.getGemPosData(self)
    return self.m_tGemPosData;
end

--[[--
    设置卡牌位置宝石数据
]]
function M.setGemPosData(self,tempData)
    self.m_tGemPosData = tempData;
end

--[[--
    设置阵型相应位置宝石数据
]]
function M.updateGemPosData(self,tempPos,tempType,tempId)
    if tempPos > 9 or tempPos < 0 or tempPos > 4 or tempType < 1 then return end
    cclog("updateGemPosData tempPos = " .. tempPos .. " ; tempType = " .. tempType .. " ; tempId = " .. tempId);
    self.m_tGemPosData[tostring(tempPos)][tempType] = tostring(tempId);
    cclog("updateGemPosData = " .. json.encode(self.m_tGemPosData))
end

--[[--
    判断是否宝石上
]]
function M.gemInGemPos(self,tempType,tempId)
    tempId = tostring(tempId);
    local existFlag = false;
    local cardName = "";
    local tempPosData = nil;
    if tempType then
        for i=1,10 do
            if tempType == 1 then
                if self.m_tGemPosData[tostring(i-1)][tempType] == tempId then
                    tempPosData = self.m_tGemPosData[tostring(i-1)];
                    existFlag = true
                    local _,itemCfg = self:getTeamCardDataByPos(i);
                    if itemCfg then
                        cardName = itemCfg:getNodeWithKey("name"):toStr();
                    else
                        cardName = i .. string_helper.game_data.pos
                    end
                    break;
                end
            else
                for j=2,4 do
                    if self.m_tGemPosData[tostring(i-1)][j] == tempId then
                        tempPosData = self.m_tGemPosData[tostring(i-1)];
                        existFlag = true
                        local _,itemCfg = self:getTeamCardDataByPos(i);
                        if itemCfg then
                            cardName = itemCfg:getNodeWithKey("name"):toStr();
                        else
                            cardName = i .. string_helper.game_data.pos
                        end
                        break;
                    end
                end
            end
            if cardName ~= "" then
                break;
            end
        end
    end
    return existFlag,cardName,tempPosData
end


--[[--
    更新宝石数据
]]
function M.updateOneGemDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    -- local itemData = json.decode(jsonData:getFormatBuffer());
    local itemData = jsonData:toInt();
    local tempId = jsonData:getKey();
    if self.m_tGemData[tempId] == nil then
        -- self.m_tGemIdTable[#self.m_tGemIdTable + 1] = tempId
        self.m_newGemIdTab[tempId] = 1;
        self.m_newGemIdTab.count = self.m_newGemIdTab.count + 1;
    end
    self.m_tGemData[tempId] = itemData;
    local existFlag = false;
    for k,v in pairs(self.m_tGemIdTable) do
        if v == tempId then
            existFlag = true;
            break;
        end
    end
    if existFlag == false then
        self.m_tGemIdTable[#self.m_tGemIdTable + 1] = tempId;
    end
end
--[[--
    更新宝石数据
]]
function M.updateMoreGemDataByJsonData(self,jsonData)
    if jsonData == nil then return end
    local itemCount = jsonData:getNodeCount();
    for i=1,itemCount do
        self:updateOneGemDataByJsonData(jsonData:getNodeAt(i-1));
    end
    self:gemSortByTypeName(self.m_gemSortType);
    cclog("updateMoreGemDataByJsonData ================itemCount " .. itemCount .. " ; #self.m_tGemIdTable == " .. #self.m_tGemIdTable);
    cclog(json.encode(self.m_tGemData))
    cclog(json.encode(self.m_tGemIdTable))
end
--[[--
    通过id移除宝石数据
]]
function M.removeOneGemDataById(self,itemId)
    itemId = tostring(itemId);
    local removeIndex = nil;
    for k,v in pairs(self.m_tGemIdTable) do
        if v == itemId then
            removeIndex = k;
            break;
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_tGemIdTable,removeIndex);
        self.m_tGemData[itemId] = nil;
    end
    if self.m_newGemIdTab[itemId] then
        self.m_newGemIdTab[itemId] = nil;
        self.m_newGemIdTab.count = self.m_newGemIdTab.count - 1;
    end
end
--[[--
    通过id表格移出宝石数据
]]
function M.removeMoreGemDataByIdTable(self,itemIds)
    for k,v in pairs(itemIds) do
        self:removeOneGemDataById(v);
    end
    cclog("removeMoreGemDataByIdTable #self.m_tGemIdTable ===== " .. #self.m_tGemIdTable)
end


--[[--
    通过 gemType 获得宝石数据
]]
function M.getGemDataByGemType(self,gemType)
    local tempTab = {};
    local tempCfg = getConfig(game_config_field.gem);
    local tempCfgItem = nil;
    local career = nil;
    local itemData = nil;
    gemType = tonumber(gemType or -1)
    gemType = gemType > 2 and 2 or gemType;
    for k,v in pairs(self.m_tGemData) do
        k = tostring(k)
        if v > 0 then
            -- cclog("id ==================== " .. k)
            tempCfgItem = tempCfg:getNodeWithKey(k);
            if tempCfgItem then
                career = tempCfgItem:getNodeWithKey("career"):toInt();
                if career ~= 0 then
                    if gemType == -1 then
                        table.insert(tempTab,k)
                    elseif career == gemType then
                        table.insert(tempTab,k)
                    end
                end
            end
        end
    end
    return tempTab;
end

--[[
    获得
]]
function M.getNoUseGemCountTab(self)
    local tempTab = {0,0,0,0}
    -- cclog2(self.m_tGemPosData, "self.m_tGemPosData  ====  ")
    -- cclog2(self.m_tGemData, "self.m_tGemPosData  ====  ")
    -- for k,v in pairs(self.m_tGemPosData) do
    --     for index,id in pairs(v) do
    --         if id ~= "0" then
    --             if index == 1 then
    --                 tempTab[1] = tempTab[1] - 1;
    --             else
    --                 tempTab[2] = tempTab[2] - 1;
    --             end
    --         end
    --     end
    -- end
    local gemCfg = getConfig(game_config_field.gem);
    local gemCfgItem = nil;
    local sort = nil;
    for k,itemData in pairs(self.m_tGemData) do
        gemCfgItem = gemCfg:getNodeWithKey(tostring(k));
        if gemCfgItem then
            sort = gemCfgItem:getNodeWithKey("career"):toInt();
            if sort > 0 and sort < 5 then
                tempTab[sort] = tempTab[sort] + itemData;
            end
        end
    end
    tempTab[3] = tempTab[2];
    tempTab[4] = tempTab[2];
    -- table.foreach(tempTab,print)
    return tempTab;
end

--[[------------------------------------宝石相关 end------------------------------------------- ]]

return M;