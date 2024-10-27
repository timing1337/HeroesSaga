--- 数据缓存
local M = {
    m_tCardsData = nil,--卡牌数据
    m_tCardsIdTable = nil,--卡牌id对应表
    m_tTeamData = nil,--编队数据
    m_tEquipData = nil,--装备数据
    m_tEquipIdTable = nil,--装备id对应表
    m_tEquipPosData = nil,--卡牌位置装备数据
    m_tEquipSortData = nil,--装备分类数据
    m_tFormationData = nil,--阵型数据
    m_tUserStatusData = nil,--用户基础数据
    m_tGemPosData = nil,--卡牌位置宝石数据
    m_tDestiny = nil,  --命运小伙伴信息
};

function M.init(self)
    self.m_tCardsData = {}
    self.m_tCardsIdTable = {}
    self.m_tTeamData = {}
    self.m_tEquipData = {}
    self.m_tEquipIdTable = {}
    self.m_tEquipPosData = {}
    self.m_tEquipSortData = {}
    self.m_tFormationData = {}
    self.m_tUserStatusData = {}
    self.m_tGemPosData = {}
    self.m_tDestiny = {}
end


--[[--
   更新CardsOpen接口数据
]]
function M.updateCardsOpenByJsonData(self,jsonData)

    -- cclog2(jsonData, "updateCardsOpenByJsonData  ====  ")

    if jsonData == nil then return end
    self:setAssistantByJsonData(jsonData:getNodeWithKey("assistant"));
    self:setDestinyByJsonData(jsonData:getNodeWithKey("destiny"))
    self:setTeamByJsonData(jsonData:getNodeWithKey("alignment"));
    self:setEquipPosDataByJsonData(jsonData:getNodeWithKey("equip_pos"));
    self:setAssEquipPosDataByJsonData(jsonData:getNodeWithKey("ass_equip_pos"));
    -- self:setEquipSortDataByJsonData(jsonData:getNodeWithKey("equip_sort"));
    self:setFormationDataByJsonData(jsonData:getNodeWithKey("formation"));
    self:setOpenPositionDataByJsonData(jsonData:getNodeWithKey("open_position"));
    self:setCardsByJsonData(jsonData:getNodeWithKey("cards"));
    self:setEquipDataByJsonData(jsonData:getNodeWithKey("equip"));
    self:setGemPosDataByJsonData(jsonData:getNodeWithKey("gem_pos"));
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
    local tempTab = self.m_tCardsData;
    local str = tostring;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroData1,heroData2,heroCfg1,heroCfg2,quality1,quality2,c_ID1,c_ID2,race1,race2
    local tTeamTab = {};
    for k,v in pairs(self.m_tTeamData or {}) do
        tTeamTab[str(v)] = 2;
    end
    for k,v in pairs(self.m_tAssistant or {}) do
        tTeamTab[str(v)] = 1;
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
            return true;
        end
        -- return tempTab[str(idOne)][str(typeName)] > tempTab[str(idTwo)][str(typeName)]
    end
    table.sort(self.m_tCardsIdTable,sortFunc)
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
        tTeamTab[str(v)] = 2;
    end
    for k,v in pairs(self.m_tAssistant or {}) do
        tTeamTab[str(v)] = 1;
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
            return true;
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
        if heroCfg and heroCfg:getNodeWithKey("quality"):toInt() > 2 then
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
    for i=1,8 do
        tempItem = self.m_tEquipPosData[tostring(i-1)]
        if tempItem then
            for j=1,4 do
                if tempItem[j] then
                    tTeamTab[str(tempItem[j])] = 1;
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
            return true;
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
    设置助威卡牌位置装备数据
]]
function M.setAssEquipPosData(self,tempData)
    self.m_tAssEquipPosData = tempData;
end

--[[--
    得到助威卡牌位置装备数据
]]
function M.getAssEquipPosData(self)
    return self.m_tAssEquipPosData or {}
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
                    cardName = i .. string_helper.game_player_data.pos
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
        self.m_newEquipIdTab[equipId] = 1;
        self.m_newEquipIdTab.count = self.m_newEquipIdTab.count + 1;
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
    cclog2(jsonData, "setFormationDataByJsonData ================ ");
    if jsonData == nil then return end
    self.m_tFormationData = json.decode(jsonData:getFormatBuffer()) or {};
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
    self.m_tUserStatusData = json.decode(jsonData:getFormatBuffer()) or {};
    self.m_action_point_add_time = self.m_tUserStatusData["action_point_rate"] or 360
    cclog("setUserStatusDataByJsonData ================ " .. json.encode(self.m_tUserStatusData["guide"]));
end

--[[--
    获得用户基础数据
]]
function M.getUserStatusData(self)
    return self.m_tUserStatusData or {};
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
    通过key获得用户基础数据
]]
function M.getUserStatusDataByKey(self,key)
    -- if key == "server_time" then
    --     return 140215680 + 1 * 24 * 3600 + 1
    -- end
    return self.m_tUserStatusData[key];
end

--[[--
    打印 UserStatusData
]]
function M.printUserStatusData(self)
    cclog2(self.m_tUserStatusData)
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

--[[--
    获得
]]
function M.getMaxLvCardFlag(self)
    local tempFlag = false;
    local maxFlag = false;
    local tempCount = 0;
    for k,v in pairs(self.m_tCardsIdTable) do
        local itemData,itemCfg = self:getCardDataById(v)
        if itemCfg:getNodeWithKey("character_ID"):toInt() == 38 then
            tempCount = tempCount + 1;
            local quality = itemCfg:getNodeWithKey("quality"):toInt();
            local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(itemCfg);--game_util:getEvolutionCfgByQuality(quality);
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


return M;