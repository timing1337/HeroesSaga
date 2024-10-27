--- 城市的自动扫荡

local city_auto_raids_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_name_label = nil,
    m_time_label = nil,
    m_action_point_label = nil,
    m_img_spri = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_close_btn = nil,
    m_cityAutoRaidsScheduler = nil,
    m_auto_time = nil,
    m_stop_btn = nil,
    m_cityDataTab = nil,
    m_tickFlag = nil,
    m_selCity = nil,
    m_selBuildingId = nil,
    m_next_step = nil,
    m_fight_list_count = nil,
    m_autoRaidsType = nil,
    m_fragmentBuildingTab = nil,
    m_chapter_name_label = nil,
    m_auto_raids_count = nil,
    m_auto_raids_max = nil,
    m_selItemId = nil,
    m_itemIdTab = nil,
    m_detail_node = nil,
    m_intro_label = nil,
    m_num_label = nil,
    m_auto_btn_1 = nil,
    m_auto_btn_2 = nil,
    m_sel_spri_1 = nil,
    m_sel_spri_2 = nil,
    m_sel_label_1 = nil,
    m_sel_label_2 = nil,
    m_itemCount = nil,
};

local auto_raids_count = "auto_raids_count";
local auto_raids_time = "auto_raids_time";
local auto_buy_action_point = "auto_buy_action_point";
local auto_sell_card = "auto_sell_card";
local auto_time = 3;

--[[--
    销毁
]]
function city_auto_raids_pop.destroy(self)
    -- body
    cclog("-----------------city_auto_raids_pop destroy-----------------");
    self:stopAutoRaidsScheduler();
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_name_label = nil;
    self.m_time_label = nil;
    self.m_action_point_label = nil;
    self.m_img_spri = nil;
    self.m_left_btn = nil;
    self.m_right_btn = nil;
    self.m_close_btn = nil;
    self.m_auto_time = nil;
    self.m_stop_btn = nil;
    self.m_cityDataTab = nil;
    self.m_tickFlag = nil;
    self.m_selCity = nil;
    self.m_selBuildingId = nil;
    self.m_next_step = nil;
    self.m_fight_list_count = nil;
    self.m_autoRaidsType = nil;
    self.m_fragmentBuildingTab = nil;
    self.m_chapter_name_label = nil;
    self.m_auto_raids_count = nil;
    self.m_auto_raids_max = nil;
    self.m_selItemId = nil;
    self.m_itemIdTab = nil;
    self.m_detail_node = nil;
    self.m_intro_label = nil;
    self.m_num_label = nil;
    self.m_auto_btn_1 = nil;
    self.m_auto_btn_2 = nil;
    self.m_sel_spri_1 = nil;
    self.m_sel_spri_2 = nil;
    self.m_sel_label_1 = nil;
    self.m_sel_label_2 = nil;
    self.m_itemCount = nil;
end
--[[--
    返回
]]
function city_auto_raids_pop.back(self,type)
    game_scene:removePopByName("city_auto_raids_pop");
end
--[[--
    读取ccbi创建ui
]]
function city_auto_raids_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--碎片扫荡
            if self:getAutoRaidsFlag() == false then
                return;
            end
            self:selectFragmentAutoRaids();
        elseif btnTag == 3 then--地图扫荡
            if self:getAutoRaidsFlag() == false then
                return;
            end
            self.m_autoRaidsType = 2;
            self:startAutoRaids();
        elseif btnTag == 4 then--停止扫荡
            self:stopAutoRaids();
        elseif btnTag == 11 then--体力
            local vipLevel = game_data:getVipLevel()
            if vipLevel < 5 then
                game_util:addMoveTips({text =  string_helper.city_auto_raids_pop.vip5Tips});
                return;
            end
            if self.m_sel_spri_1:isVisible() then
                self.m_sel_spri_1:setVisible(false);
                CCUserDefault:sharedUserDefault():setStringForKey(auto_buy_action_point,"");
            else
                self.m_sel_spri_1:setVisible(true);
                CCUserDefault:sharedUserDefault():setStringForKey(auto_buy_action_point,"true");
            end
            CCUserDefault:sharedUserDefault():flush();
        elseif btnTag == 12 then--伙伴
            local vipLevel = game_data:getVipLevel()
            if vipLevel < 3 then
                game_util:addMoveTips({text =  string_helper.city_auto_raids_pop.vip3Tips});
                return;
            end
            if self.m_sel_spri_2:isVisible() then
                self.m_sel_spri_2:setVisible(false);
                CCUserDefault:sharedUserDefault():setStringForKey(auto_sell_card,"");
            else
                self.m_sel_spri_2:setVisible(true);
                CCUserDefault:sharedUserDefault():setStringForKey(auto_sell_card,"true");
            end
            CCUserDefault:sharedUserDefault():flush();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_city_auto_raids_pop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_action_point_label = ccbNode:labelTTFForName("m_action_point_label")
    self.m_chapter_name_label = ccbNode:labelTTFForName("m_chapter_name_label")
    self.m_img_spri = ccbNode:spriteForName("m_img_spri")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_stop_btn = ccbNode:controlButtonForName("m_stop_btn")
    self.m_detail_node = ccbNode:nodeForName("m_detail_node")
    self.m_intro_label = ccbNode:labelTTFForName("m_intro_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")

    self.m_auto_btn_1 = ccbNode:controlButtonForName("m_auto_btn_1")
    self.m_auto_btn_2 = ccbNode:controlButtonForName("m_auto_btn_2")
    self.m_sel_spri_1 = ccbNode:spriteForName("m_sel_spri_1")
    self.m_sel_spri_2 = ccbNode:spriteForName("m_sel_spri_2")
    self.m_sel_label_1 = ccbNode:labelTTFForName("m_sel_label_1")
    self.m_sel_label_2 = ccbNode:labelTTFForName("m_sel_label_2")

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_stop_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_stop_btn:setVisible(false);
    self.m_auto_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_auto_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_intro_label:setString(string_helper.ccb.text109)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text110)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text111)
    self.m_sel_label_2:setString(string_helper.ccb.text112)
    return ccbNode;
end
--[[
    卖卡牌
]]
function city_auto_raids_pop.sellCardByQuality(self,quality)
    local sellQuality = quality or 2;
    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    local itemCfg = nil;
    for key,heroData in pairs(cardsDataTable) do
        if not game_data:heroInTeamById(key) and not game_util:getCardLockFlag(heroData) then
            itemCfg = character_detail:getNodeWithKey(heroData.c_id);
            if itemCfg:getNodeWithKey("quality"):toInt() <= sellQuality then
                showHeroTable[#showHeroTable+1] = heroData.id
            end
        end
    end
    cclog("sellCards #showHeroTable ====================== " .. #showHeroTable)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            game_util:addMoveTips({text = string_helper.city_auto_raids_pop.sellPartner});
            -- local get_food = gameData:getNodeWithKey("data"):getNodeWithKey("get_food"):toInt();
            -- game_util:rewardTipsByDataTable({food = get_food});
            if self.m_autoRaidsType == 1 and self.m_selItemId then
                self:startFragmentAutoRaids();
            elseif self.m_autoRaidsType == 2 then
                self:startAutoRaids();
            end
        end
        --  card_id= 
        local params = "";
        table.foreach(showHeroTable,function(k,v)
            params = params .. "card_id=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_butcher"), http_request_method.POST, params,"cards_butcher");
    end
    if #showHeroTable == 0 then
        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneTips});
    else
        sendRequest();
    end
end
--[[
    卖装备
]]
function city_auto_raids_pop.sellEquipByQuality(self,quality)
    local sellQuality = quality or 2;
    local equipCfg = getConfig(game_config_field.equip);
    local equipsDataTable = game_data:getEquipData();
    local showDataTable = {};
    local itemCfg = nil;
    for key,itemData in pairs(equipsDataTable) do
        itemCfg = equipCfg:getNodeWithKey(itemData.c_id);
        local existFlag,cardName = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
        if itemCfg and not existFlag then
            if itemCfg:getNodeWithKey("quality"):toInt() <= sellQuality then
                showDataTable[#showDataTable+1] = itemData.id;
            end
        end
    end
    cclog("sellEquips #showDataTable ====================== " .. #showDataTable)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            game_util:addMoveTips({text = string_helper.city_auto_raids_pop.sellEquip});
            -- local sell_metal = gameData:getNodeWithKey("data"):getNodeWithKey("sell_metal"):toInt();
            -- game_util:rewardTipsByDataTable({metal = sell_metal});
            if self.m_autoRaidsType == 1 and self.m_selItemId then
                self:startFragmentAutoRaids();
            elseif self.m_autoRaidsType == 2 then
                self:startAutoRaids();
            end
        end
        --  equip= 
        local params = "";
        table.foreach(showDataTable,function(k,v)
            params = params .. "equip=" .. v .. "&";
        end)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_sell"), http_request_method.POST, params,"equip_sell");
    end
    if #showDataTable == 0 then
        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneEquipTips});
    else
        sendRequest();
    end
end

function city_auto_raids_pop.battleErrorFunc(self,status)
    if self:getAutoRaidsFlag() == false then
        return;
    end
    status = status or ""
    if status == "error_1" then--伙伴满
        local tempStr = CCUserDefault:sharedUserDefault():getStringForKey(auto_sell_card);
        if tempStr ~= "true" then
            return;
        else
            game_scene:removePopByName("game_normal_tips_pop")
        end
        self:sellCardByQuality(1);
    elseif status == "error_2" then--装备满
        -- self:sellEquipByQuality(1);
    elseif status == "error_3" then--行动力不足
        local tempStr = CCUserDefault:sharedUserDefault():getStringForKey(auto_buy_action_point);
        if tempStr ~= "true" then
            return;
        else
            game_scene:removePopByName("game_normal_tips_pop")
        end
        local errorCfg = getConfig(game_config_field.error_cfg)
        local itemCfg = errorCfg:getNodeWithKey(tostring("error_3"))
        local btnCfg = itemCfg:getNodeWithKey("button1"):getNodeAt(1)
        local item_id = nil;
        for i=1,btnCfg:getNodeCount() do
            local itemId = btnCfg:getNodeAt(i-1):toInt()
            local count = game_data:getItemCountByCid(tostring(itemId))
            if count > 0 then
                item_id = itemId
                break;
            end
        end
        local function responseMethod(tag,gameData)
            local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(item_id));
            local itemName = config_date:getNodeWithKey("name"):toStr();
            local rewardCount = game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("effect"));
            if rewardCount and rewardCount == 0 then
                game_util:addMoveTips({text = tostring(itemName) .. string_helper.city_auto_raids_pop.used});
                self.m_itemCount = self.m_itemCount - 1;
                self:setActionPointLabel();
                if self.m_autoRaidsType == 1 and self.m_selItemId then
                    self:startFragmentAutoRaids();
                elseif self.m_autoRaidsType == 2 then
                    self:startAutoRaids();
                end
            end
        end
        if item_id then
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = item_id,num = 1},"item_use")
        else--背包没体力药水，使用钻石购买
            -- game_util:addMoveTips({text = "药剂不足"});

            local buyTimes = game_data:getBuyActionTimes()
            local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("2"):getNodeWithKey("coin")
            local vipLevel = game_data:getVipLevel()
            local buyLimit = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel)):getNodeWithKey("buy_point"):toInt()
        
            if buyTimes < buyLimit then
                local payValue = 0
                if buyTimes >= PayCfg:getNodeCount() then
                    payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
                else
                    payValue = PayCfg:getNodeAt(buyTimes):toInt()
                end
                local ownCoin = game_data:getUserStatusDataByKey("coin") or 0
                if ownCoin >= payValue then
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        local buy_ap_times = data:getNodeWithKey("buy_ap_times"):toInt()
                        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.buyPoint})
                        game_data:setBuyActionTimes(buy_ap_times)
                        self:setActionPointLabel();
                        if self.m_autoRaidsType == 1 and self.m_selItemId then
                            self:startFragmentAutoRaids();
                        elseif self.m_autoRaidsType == 2 then
                            self:startAutoRaids();
                        end
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_point"), http_request_method.GET, nil,"buy_point")
                else
                    game_util:addMoveTips({text = string_helper.city_auto_raids_pop.lackMoney})    
                end
            else
                game_util:addMoveTips({text = string_helper.city_auto_raids_pop.buyPointLimit})                
            end
        end
    end
end

--[[
    战斗接口
]]
function city_auto_raids_pop.battleFunc(self,canBattleBuildingTab,selIndex)
    local responseMethod = function(tag,gameData,_,status)
        if(gameData == nil) then
            self:stopAutoRaids();
            self:battleErrorFunc(status);
            return 
        end
        local data = gameData:getNodeWithKey("data");
        local has_battled = data:getNodeWithKey("has_battled"):toInt();
        if has_battled == 1 then
            local battle = data:getNodeWithKey("battle")
            local winer = battle:getNodeWithKey("winer"):toInt();
            if winer >= 5 then--战斗失败
                self:stopAutoRaids();
                game_util:addMoveTips({text = string_helper.city_auto_raids_pop.battleTips});
                return;
            end
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward)
            self.m_auto_time = auto_time;
            self.m_tickFlag = true;
            self.m_next_step = self.m_next_step + 1;--下一个小关卡
            if self.m_next_step < self.m_fight_list_count then--可以继续打
                self:setInfoLabel();
            else
                table.remove(canBattleBuildingTab,1);
                cclog("json.encode(canBattleBuildingTab) == " .. json.encode(canBattleBuildingTab) .. " ; #canBattleBuildingTab = " .. #canBattleBuildingTab)
                self.m_selBuildingId,self.m_next_step,self.m_fight_list_count = self:getBuildingData(canBattleBuildingTab,2)
                if self.m_selBuildingId ~= nil then--
                    self:setAutoRaidsCount();
                    if self:getAutoRaidsFlag() == false then
                        return;
                    end
                    self:setInfoLabel();
                else--当前城市打完，打下个城市
                    cclog("city battle over ==========selCity= " .. self.m_selCity)
                    self:stopAutoRaidsScheduler();
                    self.m_cityDataTab[selIndex].percent = 100;
                    local mapWorldData = game_data:getMapWorldData();
                    local all_city_regain_percent = mapWorldData.all_city_regain_percent or {}
                    all_city_regain_percent[tostring(self.m_selCity)] = 100
                    self:startAutoRaids();
                end
            end

        end
    end
    local params = {};
    params.city = self.m_selCity;
    params.building = self.m_selBuildingId;
    params.step_n = self.m_next_step;
    params.auto_battle = 1;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_recapture"), http_request_method.GET, params,"private_city_recapture",true,true,true)
end
--[[
    得到城市数据
]]
function city_auto_raids_pop.getCityData(self,chapterId,selCity,callBackFunc)
    cclog("getCityData ================selCity= " .. selCity)
    local canBattleBuildingTab = {}
    local tempTab = {};
    local function responseMethod(tag,gameData)
        game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
        game_data:resetNewOpenCityTab();
        local selCityData = game_data:getSelCityData();
        local landData = selCityData.land or {};
        for i=1,#landData do
            local landDataX = landData[i]
            local landDataXCount = #landDataX
            for j=1,landDataXCount do
                local landItem = landDataX[j];
                local landItemOpenType = landItem[1]
                local buildingId = tonumber(landItem[2])-- -1为起始点
                if (landItemOpenType == 0 or landItemOpenType == 2) and buildingId > 0 then--可用扫荡
                    if tempTab[buildingId] == nil then
                        table.insert(canBattleBuildingTab,buildingId)
                        tempTab[buildingId] = 1
                    end
                end
            end
        end
        table.sort(canBattleBuildingTab,function(data1,data2) return data1 < data2 end)
        cclog("json.encode(canBattleBuildingTab) == " .. json.encode(canBattleBuildingTab) .. " ; #canBattleBuildingTab = " .. #canBattleBuildingTab)
        callBackFunc(canBattleBuildingTab);        
    end
    local params = {}
    params.city = selCity;
    params.chapter = chapterId;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open")
end
--[[
    得到建筑数据
]]
function city_auto_raids_pop.getBuildingData(self,canBattleBuildingTab,typeValue)
    local selBuildingId = nil;
    local next_step = 0;
    local fight_list_count = 0;
    if #canBattleBuildingTab > 0 then
        selBuildingId = canBattleBuildingTab[1]
        local selCityData = game_data:getSelCityData();
        local recapture_log = selCityData.recapture_log or {}
        local recapture_log_item = recapture_log[tostring(selBuildingId)] or {}
        if #recapture_log_item > 0 then
            next_step = recapture_log_item[#recapture_log_item] + 1;
        end
        local mapConfig = getConfig(game_config_field.map_title_detail);
        local buildingCfgData = mapConfig:getNodeWithKey(tostring(selBuildingId));
        local fight_list = buildingCfgData:getNodeWithKey("fight_list");
        if fight_list then
            fight_list_count = fight_list:getNodeCount();
        end
    end
    cclog("typeValue = " .. typeValue .." ; selBuildingId === " .. tostring(selBuildingId) .. "; next_step = " .. next_step .. " ;fight_list_count = " .. fight_list_count)
    return selBuildingId,next_step,fight_list_count
end

--[[--
    
]]
function city_auto_raids_pop.setBuildingName(self)
    -- cclog("setBuildingName ---------------- ")
    local mapConfig = getConfig(game_config_field.map_title_detail);
    local buildingCfgData = mapConfig:getNodeWithKey(tostring(self.m_selBuildingId));
    if buildingCfgData then
        -- local fight_list = buildingCfgData:getNodeWithKey("fight_list");
        -- if fight_list and fight_list:getNodeCount() > 0 then
        --     local fight_list_count = fight_list:getNodeCount();
        --     local fightItem = fight_list:getNodeAt(self.m_next_step);
        --     if fightItem then
        --         local stageName = fightItem:getNodeAt(0):toStr();
        --         self.m_name_label:setString((self.m_next_step+1) .. "/" .. fight_list_count .. " " .. stageName);
        --     end
        -- end
        local title_name = buildingCfgData:getNodeWithKey("title_name"):toStr();
        local typeName = "";
        if self.m_autoRaidsType == 1 then
            typeName = string_helper.city_auto_raids_pop.pieces
            self.m_name_label:setString(title_name);
        elseif self.m_autoRaidsType == 2 then
            typeName = string_helper.city_auto_raids_pop.map
            self.m_name_label:setString(title_name .. " " .. (self.m_next_step+1) .. "/" .. tostring(self.m_fight_list_count));
        end
    else
        if self.m_autoRaidsType == 1 then
            typeName = string_helper.city_auto_raids_pop.pieces
            self.m_name_label:setString("no config");
        elseif self.m_autoRaidsType == 2 then
            typeName = string_helper.city_auto_raids_pop.map
            self.m_name_label:setString((self.m_next_step+1) .. "/" .. tostring(self.m_fight_list_count));
        end
    end
end

--[[
    开始
]]
function city_auto_raids_pop.startAutoRaids(self)
    local selCity,selIndex,chapterId = nil,nil;
    --找没有打完的城市
    for i=1,#self.m_cityDataTab do
        if self.m_cityDataTab[i].percent < 100 then
            selIndex = i;
            selCity = self.m_cityDataTab[i].city
            chapterId = self.m_cityDataTab[i].chapterId;
            self.m_chapter_name_label:setString(string_helper.city_auto_raids_pop.recovering .. tostring(self.m_cityDataTab[i].chapter_name));
            break;
        end
    end
    if selCity then--有城市没打完
        self.m_selCity = selCity
        local function callBackFunc(canBattleBuildingTab)
            self:stopAutoRaidsScheduler();
            if self.m_cityAutoRaidsScheduler == nil then
                self.m_selBuildingId,self.m_next_step,self.m_fight_list_count = self:getBuildingData(canBattleBuildingTab,1)
                self.m_tickFlag = true;
                function tick( dt )
                    if self.m_tickFlag == false then return end
                    if self.m_auto_time > 0 then
                        self.m_auto_time = self.m_auto_time - 1;
                        self:setInfoLabel();
                    else
                        if self.m_selBuildingId ~= nil and self.m_next_step < self.m_fight_list_count then
                            self.m_tickFlag = false;
                            self:battleFunc(canBattleBuildingTab,selIndex);
                        else
                            table.remove(canBattleBuildingTab,1);
                            cclog("json.encode(canBattleBuildingTab) == " .. json.encode(canBattleBuildingTab) .. " ; #canBattleBuildingTab = " .. #canBattleBuildingTab)
                            self.m_selBuildingId,self.m_next_step,self.m_fight_list_count = self:getBuildingData(canBattleBuildingTab,2)
                            if self.m_selBuildingId ~= nil then--当前建筑打完，打下个建筑
                                self:setAutoRaidsCount();
                                if self:getAutoRaidsFlag() == false then
                                    return;
                                end
                                self.m_tickFlag = false;
                                self:battleFunc(canBattleBuildingTab,selIndex);
                            else--当前城市打完，打下个城市
                                cclog("city battle over ==========selCity= " .. selCity)
                                self:stopAutoRaidsScheduler();
                                self.m_cityDataTab[selIndex].percent = 100;
                                local mapWorldData = game_data:getMapWorldData();
                                local all_city_regain_percent = mapWorldData.all_city_regain_percent or {}
                                all_city_regain_percent[tostring(selCity)] = 100
                                self:startAutoRaids();
                            end
                        end
                    end
                end
                self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)
                self:setInfoLabel();
                self.m_left_btn:setVisible(false)
                self.m_right_btn:setVisible(false)
                self.m_stop_btn:setVisible(true)
            end
        end
        self:getCityData(chapterId,selCity,callBackFunc);
    else--所有城市都收复完成
        self:stopAutoRaids();
        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneCity});
    end
end

function city_auto_raids_pop.setInfoLabel(self)
    self.m_time_label:setString(game_util:formatTime(self.m_auto_time));
    -- self.m_name_label:setString(string.format("cid:%d;bid:%d;step = %d/%d",self.m_selCity,self.m_selBuildingId,self.m_next_step+1,self.m_fight_list_count))
    self:setBuildingName();
    local user_status = game_data:getUserStatusData();
    self.m_action_point_label:setString(tostring(user_status.action_point) .. "/" .. tostring(user_status.action_point_max));
end

--[[
    停止
]]
function city_auto_raids_pop.stopAutoRaids(self)
    self:stopAutoRaidsScheduler();
    self.m_chapter_name_label:setString(string_helper.city_auto_raids_pop.covering);
    self.m_name_label:setString(string_helper.city_auto_raids_pop.none);
    self.m_left_btn:setVisible(true)
    self.m_right_btn:setVisible(true)
    self.m_stop_btn:setVisible(false)
    self.m_auto_time = auto_time;
    self.m_tickFlag = false;
    self.m_time_label:setString("00:00:00")
    local user_status = game_data:getUserStatusData();
    self.m_action_point_label:setString(tostring(user_status.action_point) .. "/" .. tostring(user_status.action_point_max));
end

--[[
    停止
]]
function city_auto_raids_pop.stopAutoRaidsScheduler(self)
    if self.m_cityAutoRaidsScheduler ~= nil then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
end


--[[--
    
]]
function city_auto_raids_pop.selectFragmentAutoRaids(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            ccbNode:removeFromParentAndCleanup(true);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_select_fragment_pop.ccbi");

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local file69 = ccbNode:labelTTFForName("file69");
    file69:setString(string_helper.ccb.file69);
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    local m_list_view_bg = ccbNode:layerForName("m_list_view_bg")

    --创建扫荡碎片列表
    local viewSize = m_list_view_bg:getContentSize();
    local showData = self.m_itemIdTab or {};
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = #showData;
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local nodeTab = {};
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 255, 0), itemSize.width, itemSize.height*0.8)
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,10,10)
            -- local tempLabel = game_util:createLabelTTF({text = "点击扫荡",color = ccc3(250,180,0),fontSize = 12});
            -- tempLabel:setPosition(ccp(itemSize.width*0.75, itemSize.height*0.5))
            -- cell:addChild(tempLabel,11,11)
        end
        if cell then
            local spriteLand = cell:getChildByTag(10);
            spriteLand:removeAllChildrenWithCleanup(true);
            local itemId = showData[index + 1]
            local buildingTab = self.m_fragmentBuildingTab[itemId] or {};
            local tempIcon,name = game_util:createItemIconByCid(itemId);
            if tempIcon then
                tempIcon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                spriteLand:addChild(tempIcon)
            end
            if name then
                local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.0))
                spriteLand:addChild(tempLabel)
            end
            if #buildingTab > 0 then

            else

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local itemId = showData[index + 1]
            local buildingTab = self.m_fragmentBuildingTab[itemId] or {};
            if #buildingTab > 0 then
                ccbNode:removeFromParentAndCleanup(true);
                self.m_selItemId = showData[index + 1];
                self.m_autoRaidsType = 1;
                self:startFragmentAutoRaids();
            else
                game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneRecoveCity});
            end
        end
    end
    local tempTableView = TableViewHelper:create(params);
    m_list_view_bg:addChild(tempTableView);
    game_scene:getPopContainer():addChild(ccbNode)
end


--[[
    开始
]]
function city_auto_raids_pop.startFragmentAutoRaids(self)
    if self.m_selItemId == nil then 
        return;
    end
    local buildingTab = self.m_fragmentBuildingTab[self.m_selItemId] or {};
    if #buildingTab > 0 then
        cclog("json.encode(buildingTab) == " .. json.encode(buildingTab))
        local selIndex = 1;
        local auto_sweep_cfg = getConfig(game_config_field.auto_sweep)
        local auto_sweep_building = auto_sweep_cfg:getNodeWithKey(self.m_selItemId);

        local function responseMethod(tag,gameData)
            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_data:resetNewOpenCityTab();
            
            local function getSweep(tempIndex)
                local selBuildingId = buildingTab[tempIndex]
                if selBuildingId == nil then
                    return nil,nil;
                end
                local itemCfg = auto_sweep_building:getNodeWithKey(tostring(selBuildingId));
                local cityId = itemCfg:getNodeWithKey("stage_id"):toInt();
                local sweepLogData = game_data:getSelCitySweepLogData();
                local current_sweep = sweepLogData[tostring(selBuildingId)] or 0;
                local mapConfig = getConfig(game_config_field.map_title_detail);
                local buildingCfgData = mapConfig:getNodeWithKey(tostring(selBuildingId));
                local max_sweep = buildingCfgData:getNodeWithKey("max_sweep"):toInt();
                cclog("selBuildingId == " .. selBuildingId .. " ; cityId = " .. cityId ..  " ; current_sweep = " .. current_sweep .. " ; max_sweep = " .. max_sweep)
                if current_sweep >= max_sweep then
                    selIndex = selIndex + 1;
                    return getSweep(selIndex)
                else
                    local chapter = getConfig(game_config_field.chapter);
                    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
                    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
                    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(cityId))
                    if cityOrderId then
                        cityOrderId = cityOrderId:toStr();
                        local main_story_item = map_main_story_cfg:getNodeWithKey(cityOrderId);
                        local chapterId = main_story_item:getNodeWithKey("chapter"):toStr();
                        local itemCfg = chapter:getNodeWithKey(chapterId);
                        local chapter_name = itemCfg:getNodeWithKey("chapter_name"):toStr();
                        self.m_chapter_name_label:setString(string_helper.city_auto_raids_pop.covering2 .. tostring(chapter_name));
                    else
                        self.m_chapter_name_label:setString(string_helper.city_auto_raids_pop.covering);
                    end
                    return cityId,selBuildingId;
                end
            end

            local function battleFunc()
                local responseMethod = function(tag,gameData,_,status)
                    if gameData == nil then
                        self:stopAutoRaids();
                        self:battleErrorFunc(status);
                        return;
                    end
                    self:setAutoRaidsCount();
                    if self:getAutoRaidsFlag() == false then
                        return;
                    end
                    self.m_auto_time = auto_time;
                    self.m_tickFlag = true;
                    game_data:addSelCitySweepLogDataByBuildingId(self.m_selBuildingId);
                    local data = gameData:getNodeWithKey("data");
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward)

                    self.m_selCity,self.m_selBuildingId = getSweep(selIndex);
                    if self.m_selCity == nil or self.m_selBuildingId == nil then
                        self:stopAutoRaids();
                        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneRecoveCity});
                    end
                end
                local params = {};
                params.city = self.m_selCity;
                params.building = self.m_selBuildingId
                params.auto_battle = 1;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_auto_recapture"), http_request_method.GET, params,"private_city_auto_recapture",true,true)
            end
            self:stopAutoRaidsScheduler();
            self.m_selCity,self.m_selBuildingId = getSweep(selIndex);
            if self.m_selCity == nil or self.m_selBuildingId == nil then
                self:stopAutoRaids();
                game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneRecoveCity});
                return;
            end
            self.m_tickFlag = true;
            function tick( dt )
                if self.m_tickFlag == false then return end
                if self.m_auto_time > 0 then
                    self.m_auto_time = self.m_auto_time - 1;
                    self:setInfoLabel();
                else
                    if self.m_selCity == nil or self.m_selBuildingId == nil then
                        self:stopAutoRaids();
                        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneRecoveCity});
                    else
                        self.m_tickFlag = false;
                        battleFunc();
                    end
                end
            end
            self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)
            self:setInfoLabel();
            self.m_left_btn:setVisible(false)
            self.m_right_btn:setVisible(false)
            self.m_stop_btn:setVisible(true)
        end
        local params = {}
        params.city = 100;
        params.chapter = 1;
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open")
    else--没有可扫荡的城市和建筑
        self:stopAutoRaids();
        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.noneRecoveCity});
    end
end

function city_auto_raids_pop.getAutoRaidsMax(self)
    local tempCount = 10;
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    local vip_cfg = getConfig(game_config_field.vip);
    local maxVipDataCount = vip_cfg and vip_cfg:getNodeCount() or 16  
    if vipLevel < 0 then
        vipLevel = 0;
    elseif vipLevel + 1 > maxVipDataCount then
        vipLevel = maxVipDataCount - 1;
    end
    local item_cfg = vip_cfg:getNodeWithKey(tostring(vipLevel))
    if item_cfg then
        local auto_fight = item_cfg:getNodeWithKey("auto_fight")
        if auto_fight then
            tempCount = auto_fight:toInt();
        end
    end
    return tempCount;
end
--[[
    
]]
function city_auto_raids_pop.setAutoRaidsCount(self)
    self.m_auto_raids_count = math.min(self.m_auto_raids_count+1,self.m_auto_raids_max)
    -- CCUserDefault:sharedUserDefault():setIntegerForKey(auto_raids_count,self.m_auto_raids_count);
    -- CCUserDefault:sharedUserDefault():flush();
    cclog("self.m_auto_raids_count == " .. self.m_auto_raids_count .. " ; self.m_auto_raids_max == " .. self.m_auto_raids_max)
    self:setDetailInfo();
end

--[[
    
]]
function city_auto_raids_pop.setDetailInfo(self)
    if self.m_auto_raids_count >= self.m_auto_raids_max then
        self.m_detail_node:setVisible(false)
        self.m_intro_label:setVisible(true);
    else
        self.m_detail_node:setVisible(true)
        self.m_intro_label:setVisible(false);
    end
    self.m_num_label:setString(tostring(self.m_auto_raids_max - self.m_auto_raids_count) .. "/" .. tostring(self.m_auto_raids_max))
end

--[[
    
]]
function city_auto_raids_pop.getAutoRaidsFlag(self)
    local tempFlag = true;
    if self.m_auto_raids_count >= self.m_auto_raids_max then
        tempFlag = false;
        game_util:addMoveTips({text = string_helper.city_auto_raids_pop.autoBattleLimit});
        self:stopAutoRaids();
    end
    return tempFlag;
end

--[[--
  
]]
function city_auto_raids_pop.setActionPointLabel(self)
    if self.m_itemCount > 0 then
        self.m_sel_label_1:setString(string_helper.city_auto_raids_pop.leftMed..self.m_itemCount)
    else
        local buyTimes = game_data:getBuyActionTimes()
        local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("2"):getNodeWithKey("coin")
        local vipLevel = game_data:getVipLevel()
        local buyLimit = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel)):getNodeWithKey("buy_point"):toInt()
        -- local payValue = 0
        -- if buyTimes >= PayCfg:getNodeCount() then
        --     payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
        -- else
        --     payValue = PayCfg:getNodeAt(buyTimes):toInt()
        -- end
        local tempCount = math.max(0,buyLimit - buyTimes)
        self.m_sel_label_1:setString(string_helper.city_auto_raids_pop.leftBuyTimes .. tempCount)
    end
end

--[[--
    刷新ui
]]
function city_auto_raids_pop.refreshUi(self)
    self:stopAutoRaids();
    self:setDetailInfo();
    self:setActionPointLabel();
    local tempStr = CCUserDefault:sharedUserDefault():getStringForKey(auto_buy_action_point);
    if tempStr ~= "true" then
        self.m_sel_spri_1:setVisible(false);
    else
        self.m_sel_spri_1:setVisible(true);
    end
    local tempStr2 = CCUserDefault:sharedUserDefault():getStringForKey(auto_sell_card);
    if tempStr2 ~= "true" then
        self.m_sel_spri_2:setVisible(false);
    else
        self.m_sel_spri_2:setVisible(true);
    end
end

--[[--
    初始化
]]
function city_auto_raids_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_auto_time = auto_time;
    self.m_cityDataTab = t_params.cityDataTab or {};
    self.m_tickFlag = false;

    -- local auto_sweep_cfg = getConfig(game_config_field.auto_sweep)
    -- local buildingTab = {};
    -- local tempCount = auto_sweep_cfg:getNodeCount();
    -- for i=1,tempCount do
    --     local item_cfg = auto_sweep_cfg:getNodeAt(i - 1);
    --     table.insert(buildingTab,item_cfg:getKey());
    -- end
    -- self.m_fragmentBuildingTab = buildingTab
    self.m_itemIdTab = {};
    self.m_fragmentBuildingTab = t_params.fragmentBuildingTab or {};
    table.sort(self.m_fragmentBuildingTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    -- cclog("json.encode(self.m_fragmentBuildingTab) == " .. json.encode(self.m_fragmentBuildingTab))
    local auto_sweep_cfg = getConfig(game_config_field.auto_sweep)
    local tempCount = auto_sweep_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = auto_sweep_cfg:getNodeAt(i - 1)
        table.insert(self.m_itemIdTab,itemCfg:getKey())
    end
    local itemCfg = getConfig(game_config_field.item);
    local function sortFunc(data1,data2)
        local itemCfg1 = itemCfg:getNodeWithKey(tostring(data1))
        local itemCfg2 = itemCfg:getNodeWithKey(tostring(data2))
        if itemCfg1 and itemCfg2 then
            return itemCfg1:getNodeWithKey("quality"):toInt() < itemCfg2:getNodeWithKey("quality"):toInt();
        else
            return false;
        end
    end
    table.sort(self.m_itemIdTab,sortFunc)

    self.m_auto_raids_count = t_params.rest_auto_sweep_times or 0--CCUserDefault:sharedUserDefault():getIntegerForKey(auto_raids_count);

    -- local localTime = CCUserDefault:sharedUserDefault():getDoubleForKey(auto_raids_time);
    -- local localDateTab = os.date("*t",localTime); --
    -- cclog(localDateTab.year, localDateTab.month, localDateTab.day, localDateTab.hour, localDateTab.min, localDateTab.sec);

    -- local serverTime = game_data:getUserStatusDataByKey("server_time")
    -- local dateTab=os.date("*t",serverTime); --
    -- cclog(dateTab.year, dateTab.month, dateTab.day, dateTab.hour, dateTab.min, dateTab.sec);
    -- if localDateTab.year ~= dateTab.year or localDateTab.month ~= dateTab.month or localDateTab.day ~= dateTab.day then
    --     cclog("next day");
    --     CCUserDefault:sharedUserDefault():setDoubleForKey(auto_raids_time,serverTime);
    --     CCUserDefault:sharedUserDefault():setIntegerForKey(auto_raids_count,0);
    --     CCUserDefault:sharedUserDefault():flush();
    --     self.m_auto_raids_count = 0;
    -- else
    --     cclog("curent day");
    -- end
    self.m_auto_raids_max = self:getAutoRaidsMax();
    self.m_auto_raids_count = math.min(self.m_auto_raids_count,self.m_auto_raids_max)
    cclog("self.m_auto_raids_count == " .. self.m_auto_raids_count .. " ; self.m_auto_raids_max == " .. self.m_auto_raids_max)
    local errorCfg = getConfig(game_config_field.error_cfg)
    local itemCfg = errorCfg:getNodeWithKey(tostring("error_3"))
    local btnCfg = itemCfg:getNodeWithKey("button1"):getNodeAt(1)
    local itemCount = 0
    for i=1,btnCfg:getNodeCount() do
        local itemId = btnCfg:getNodeAt(i-1):toInt()
        local count = game_data:getItemCountByCid(tostring(itemId))
        itemCount = count + itemCount
    end
    self.m_itemCount = itemCount;
    self.m_selItemId = tostring(t_params.itemId or "");
end

--[[--
    创建ui入口并初始化数据
]]
function city_auto_raids_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    if self.m_selItemId ~= "" then
        if self:getAutoRaidsFlag() == false then
            return;
        end
        self.m_autoRaidsType = 1;
        self:startFragmentAutoRaids();
    end
    return self.m_popUi;
end

return city_auto_raids_pop;