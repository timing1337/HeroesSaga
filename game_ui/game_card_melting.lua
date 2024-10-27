---  装备分解
local game_card_melting = {
    m_table_view = nil,

    m_hero_id_table = nil,
    m_btn_table = nil,
    melting_type = nil,
    show_card_type = nil,
    exchange_id = nil,
    card_ids = nil,
    m_back_btn = nil,
    btn_shuoming = nil,
    btn_chongzhi = nil,
    tip_label = nil,
    m_material_n = nil,
    card_node = nil,
    tip_label = nil,
    m_material_node_tab = nil,
    m_food_total_label = nil,
    m_cost_food_label = nil,
    m_needFood = nil,
    need_food = nil,
    firstEnter = nil,
    btn_fenjie = nil,
}
--[[--
    销毁ui
]]
function game_card_melting.destroy(self)
    -- body
    cclog("-----------------game_card_melting destroy-----------------");
    self.m_table_view = nil;

    self.m_hero_id_table = nil;
    self.m_btn_table = nil;
    self.melting_type = nil;
    self.show_card_type = nil;
    self.exchange_id = nil;
    self.card_ids = nil;
    self.m_back_btn = nil;
    self.btn_shuoming = nil;
    self.btn_chongzhi = nil;
    self.tip_label = nil;
    self.m_material_n = nil;
    self.card_node = nil;
    self.tip_label = nil;
    self.m_material_node_tab = nil;
    self.m_food_total_label = nil;
    self.m_cost_food_label = nil;
    self.m_needFood = nil;
    self.need_food = nil;
    self.firstEnter = nil;
    self.btn_fenjie = nil;
end
local showTips =string_helper.game_card_melting.showTips
--[[--
    返回
]]
function game_card_melting.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[
    合成方法
]]
function game_card_melting.meltingMethod(self)
    local exchange_flag = false
    local tips = ""
    local params = ""
    local exchange_id = ""
    --exchange_id   1 是 两紫卡换   2 5紫卡换   3是  5橙卡换  4是  3橙卡换    5 是三个红卡换 6是   一个金卡
    local count = self:getAddCardCount()
    if self.melting_type == 1 then
        if count == 2 or count == 5 then--可兑换，其他的不可兑换
            exchange_flag = true
            if count == 2 then exchange_id = "1" 
            elseif count == 5 then exchange_id = "2" end
        else
            tips = string_helper.game_card_melting.text1
        end
    elseif self.melting_type == 2 then
        if count == 3 or count == 5 then--可兑换，其他的不可兑换
            exchange_flag = true
            if count == 3 then exchange_id = "4" 
            elseif count == 5 then exchange_id = "3" end
        else
            tips = string_helper.game_card_melting.text2
        end
    elseif self.melting_type == 3 then
        if count == 3 then
            exchange_flag = true
            exchange_id = "5"
        else
            tips = string_helper.game_card_melting.text3
        end
    elseif self.melting_type == 4 then
        if count == 1 then
            exchange_flag = true
            exchange_id = "6"
        else
            tips = string_helper.game_card_melting.text4
        end
    end
    if exchange_flag == true then
        params = params .. "exchange_id=" .. exchange_id .. "&"
        for i=1,#self.m_hero_id_table do
            params = params .. "card_ids=" .. self.m_hero_id_table[i] .. "&"
        end
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_hero_id_table = {}
            self.card_ids = {}
            self.melting_type = 1;
            self.show_card_type = 1;
            self.m_needFood = 0
            self:refreshShowHeroBack()
            self:refreshUi()
            for i=1,4 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[1]:setEnabled(false)
            self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_melting"), http_request_method.GET, params,"cards_melting")
    else
        game_util:addMoveTips({text = tips})
    end
end
--[[--
    读取ccbi创建ui
]]
function game_card_melting.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--改成一键添加
            local meltingCfg = getConfig(game_config_field.exchange_card)
            -- local tempTable = {}
            -- for i=1,meltingCfg:getNodeCount() do
            --     local itemCfg = meltingCfg:getNodeWithKey(tostring(i))
            --     local prefer = itemCfg:getNodeWithKey("select"):toInt()
            --     tempTable[tostring(prefer)] = i
            -- end
            -- cclog2(tempTable)
            -- for i=1,game_util:getTableLen(tempTable) do
            --     local try = tempTable[tostring(i)]
            --     local cardTable = game_data:getCardsDataByQuality(3);
            --     local itemCfg = meltingCfg:getNodeWithKey(tostring(try))
            --     for j=1,5 do
            --         local card = itemCfg:getNodeWithKey("card" .. j)

            --     end
            -- end
            --不用循环，用递归
            local function getRightCardId(quality,count)
                local cardTable = game_data:getCardsDataByQuality(3);   
                local qualityCard = game_data:getCardsDataByQualityUnique(quality,cardTable)
                game_data:cardsSortByTypeNameWithTable("default",qualityCard);
                -- cclog2(qualityCard,"qualityCard")
                local choseTable = {}
                for i=1,#qualityCard do
                    local cardId = cardTable[i]
                    local itemData,hero_config = game_data:getCardDataById(qualityCard[#qualityCard - i + 1]);
                    local is_in_team = game_data:heroInTeamById(itemData.id);
                    local is_lock = game_util:getCardUserLockFlag(itemData);
                    local is_in_train = game_util:getCardTrainingFlag(itemData);
                    local is_in_cheer = game_data:heroInAssistantById(itemData.id)
                    local can_select = is_in_team or is_lock or is_in_train or is_in_cheer;
                    local rebirth = hero_config:getNodeWithKey("rebirth"):toInt()
                    if can_select == true then
                    else
                        local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
                        if itemData.step and itemData.step < 4 then
                            if exchange_id > 0 then
                                if rebirth < 5 then
                                    table.insert(choseTable,itemData.id)
                                end
                            end
                        end
                    end
                end
                -- cclog2(choseTable,"choseTable")
                if #choseTable >= count then
                    local returnTaebl = {}
                    for i=1,count do
                        table.insert(returnTaebl,choseTable[i])
                    end
                    -- cclog2(returnTaebl,"returnTaebl")
                    return returnTaebl
                else
                    return false
                end
            end
            local function getTryId(preferId)
               for i=1,meltingCfg:getNodeCount() do
                    local itemCfg = meltingCfg:getNodeWithKey(tostring(i))
                    local prefer = itemCfg:getNodeWithKey("select"):toInt()
                    if preferId == prefer then
                        return i
                    end
                end
                return 0
            end
            local preferId = 1
            local function doAutoSelect(preferId)
                -- cclog2(preferId,"preferId")
                local itemId = getTryId(preferId)
                -- cclog2(itemId,"itemId")
                local itemCfg = meltingCfg:getNodeWithKey(tostring(itemId))
                local cardShow = {0,0,0,0}
                for i=1,5 do
                    local card = itemCfg:getNodeWithKey("card" .. i):toStr()
                    if card == "all3" then
                        cardShow[1] = cardShow[1] + 1
                    elseif card == "all4" then
                        cardShow[2] = cardShow[2] + 1
                    elseif card == "all5" then
                        cardShow[3] = cardShow[3] + 1
                    elseif card == "all6" then
                        cardShow[4] = cardShow[4] + 1
                    end
                end
                -- cclog2(cardShow,"cardShow")
                local finalCard = {}
                if cardShow[1] == 2 then--取二紫卡
                    finalCard = getRightCardId(3,2)
                elseif cardShow[1] == 5 then--取五紫卡
                    finalCard = getRightCardId(3,5)
                elseif cardShow[2] == 3 then--取3橙卡
                    finalCard = getRightCardId(4,3)
                elseif cardShow[2] == 5 then--取5橙卡
                    finalCard = getRightCardId(4,5)
                elseif cardShow[3] == 3 then--取3红卡
                    finalCard = getRightCardId(5,3)
                end
                -- cclog2(finalCard,"finalCard")
                if finalCard == false then
                    -- game_util:addMoveTips({text = "没有符合要求的卡牌！"})
                    -- preferId = preferId + 1
                    if preferId < 5 then
                        preferId = preferId + 1
                        --进行下一次递归
                        doAutoSelect(preferId)
                    else
                        game_util:addMoveTips({text = string_helper.game_card_melting.text5})
                    end
                else
                    self.m_hero_id_table = finalCard
                    self:refreshShowHeroBack()
                    self:refreshUi()
                end
            end
            doAutoSelect(preferId)
            self:gameGuide("show", 7, 709)
        elseif btnTag == 101 then--合成
            if self.need_food == true then
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 5,
                    m_call_func = function()
                        -- self:refreshTips();
                        self:refreshUi()
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                self:meltingMethod()
            end
            self:gameGuide("drama", 7, 710)
            game_scene:removeGuidePop()
        elseif btnTag == 102 then--重置
            self.m_hero_id_table = {}
            self.card_ids = {}
            self.melting_type = 1;
            self.show_card_type = 1;
            self.m_needFood = 0
            self:refreshShowHeroBack()
            self:refreshUi()
            for i=1,4 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[1]:setEnabled(false)
            self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
        elseif btnTag == 105 then--返回
            self:back();
        elseif btnTag == 12 then--查看详情
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "137"})
        elseif btnTag >= 1 and btnTag <= 5 then--选择合成卡
            cclog("btnTag == " .. btnTag)
            if self.m_material_node_tab[btnTag].isAdded == true then--有
                local key = self.m_hero_id_table[btnTag]
                local flag,k = game_util:idInTableById(tostring(key),self.m_hero_id_table);
                table.remove(self.m_hero_id_table,k);
                self:refreshShowHeroBack()
                self:refreshUi()
            end
        elseif btnTag > 200 and btnTag < 210 then--选择显示类型
            local index = btnTag - 200;
            for i=1,4 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[index]:setEnabled(false)
            self.m_btn_table[index]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
            --切换table
            self.show_card_type = index
            if index > 1 then
                self.show_card_type = index + 1
            end
            self:refreshUi();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_card_melting.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node");
    
    self.m_back_btn = ccbNode:controlButtonForName("btn_back");
    self.btn_shuoming = ccbNode:controlButtonForName("btn_shuoming")
    self.btn_chongzhi = ccbNode:controlButtonForName("btn_chongzhi")

    game_util:setCCControlButtonTitle(self.btn_shuoming,string_helper.ccb.text76)
    game_util:setCCControlButtonTitle(self.btn_chongzhi,string_helper.ccb.text75)


    self.tip_label = ccbNode:labelTTFForName("tip_label")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.card_node = ccbNode:nodeForName("card_node")
    self.m_food_total_label = ccbNode:labelBMFontForName("m_food_total_label")
    self.m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
    self.btn_fenjie = ccbNode:controlButtonForName("btn_fenjie")
    game_util:setCCControlButtonTitle(self.btn_fenjie,string_helper.ccb.text77)

    self.tip_label:setString(showTips[1])

    local m_material_node,selectBtn,isAdded = nil,nil,false--是否添加
    for i=1,5 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        selectBtn = ccbNode:controlButtonForName("m_material_btn_" .. i)
        isAdded = false
        selectBtn:setOpacity(0)
        self.m_material_node_tab[i] = {m_material_node = m_material_node,selectBtn = selectBtn,isAdded = isAdded}
    end
    
    self.m_btn_table = {}
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
    
    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text78)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text79)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text80)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text81)
    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text82)
    return ccbNode;
end
--[[
    已经添加了几个
]]
function game_card_melting.getAddCardCount(self)
    local count = 0
    for i=1,5 do
        local isAdded = self.m_material_node_tab[i].isAdded
        if isAdded == true then
            count = count + 1
        end
    end
    return count
end
--[[
    创建英雄列表
]]--
function game_card_melting.createTableView( self,viewSize )
    --根据融合类型和显示类型来筛选显示的卡牌
    local count = self:getAddCardCount()
    if count > 0 then--有已选，则只显示同品质卡牌
        local allCard = game_data:getCardsDataByQuality(3);
        if self.melting_type == 1 then--只显示紫卡
            self.m_temp_table = game_data:getCardsDataByQualityUnique(3,allCard)
        elseif self.melting_type == 2 then--只显示橙卡
            self.m_temp_table = game_data:getCardsDataByQualityUnique(4,allCard)
        elseif self.melting_type == 3 then--只显示红卡
            self.m_temp_table = game_data:getCardsDataByQualityUnique(5,allCard)
        elseif self.melting_type == 4 then--只显示金卡
            self.m_temp_table = game_data:getCardsDataByQualityUnique(6,allCard)
        end
        if self.show_card_type > 1 then
            local finalShowCard = game_data:getCardsDataByQualityUnique(self.show_card_type,self.m_temp_table)
            self.m_temp_table = finalShowCard
        end
    else--无已选，可显示所有卡牌
        self.m_temp_table = game_data:getCardsDataByQuality(3);
        if self.show_card_type > 1 then--选择了卡牌类型
            local tempTable = game_data:getCardsDataByQualityUnique(self.show_card_type,self.m_temp_table)
            self.m_temp_table = tempTable
        end
    end
    game_data:cardsSortByTypeNameWithTable("default",self.m_temp_table);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    local cardCount = #self.m_temp_table
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = cardCount;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardCount then
                local itemData,itemCfg = game_data:getCardDataById(self.m_temp_table[cardCount - index]);
                if itemData and itemCfg then
                    local heroId = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    local sprite_selected = ccbNode:spriteForName("sprite_selected");
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");

                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_hero_id_table);
                    if flag then
                        sprite_selected:setVisible(true);
                        sprite_back_alpha:setVisible(true);
                    else
                        sprite_selected:setVisible(false);
                        sprite_back_alpha:setVisible(false);
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            local sprite_selected = ccbNode:spriteForName("sprite_selected");

            local itemData,hero_config = game_data:getCardDataById(self.m_temp_table[cardCount - index]);
            local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_hero_id_table);
            if flag and k ~= nil then
                table.remove(self.m_hero_id_table,k);
                sprite_selected:setVisible(false);
                sprite_back_alpha:setVisible(false);
                self:refreshShowHeroBack()
            else
                if #self.m_hero_id_table < 5 then
                    local is_in_team = game_data:heroInTeamById(itemData.id);
                    local is_lock = game_util:getCardUserLockFlag(itemData);
                    local is_in_train = game_util:getCardTrainingFlag(itemData);
                    local is_in_cheer = game_data:heroInAssistantById(itemData.id)
                    local can_select = is_in_team or is_lock or is_in_train or is_in_cheer;
                    if can_select == true then
                        if is_in_team then
                            game_util:addMoveTips({text = string_helper.game_card_melting.text6});
                        elseif is_in_train then
                            game_util:addMoveTips({text = string_helper.game_card_melting.text7});
                        elseif is_lock then
                            game_util:addMoveTips({text = string_helper.game_card_melting.text8});
                        elseif is_in_cheer then
                            game_util:addMoveTips({text = string_helper.game_card_melting.text9});
                        end
                    else
                        local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
                        if itemData.step and itemData.step >= 4 then
                            game_util:addMoveTips({text = string_helper.game_card_melting.text10});
                        elseif exchange_id > 0 then
                            if self:getAddCardCount() > 0 then
                                local flag = false
                                local quality = hero_config:getNodeWithKey("quality"):toInt()
                                --再根据现在选的卡牌类型判断
                                if self.melting_type == 1 then--只能加紫卡
                                    if quality == 3 then
                                        flag = true
                                    end
                                elseif self.melting_type == 2 then--只能加橙卡
                                    if quality == 4 then
                                        flag = true
                                    end
                                elseif self.melting_type == 3 then--只能加红卡
                                    if quality == 5 then
                                        flag = true
                                    end
                                elseif self.melting_type == 4 then--放一张万能金卡
                                    if quality == 6 then
                                        flag = true
                                    end
                                end
                                if flag == true then
                                    table.insert(self.m_hero_id_table,itemData.id)
                                    sprite_selected:setVisible(true);
                                    sprite_back_alpha:setVisible(true);
                                    self:refreshShowHeroBack()
                                else
                                    game_util:addMoveTips({text = string_helper.game_card_melting.text11});    
                                end
                            else
                                table.insert(self.m_hero_id_table,itemData.id)
                                sprite_selected:setVisible(true);
                                sprite_back_alpha:setVisible(true);
                                self:refreshShowHeroBack()
                            end
                        else--exchange_id=0 的伙伴不能分解
                            game_util:addMoveTips({text = string_helper.game_card_melting.text12});
                        end
                    end
                else
                    game_util:addMoveTips({text = string_helper.game_card_melting.text13})
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加装备全身像
]]--
function game_card_melting.refreshShowHeroBack(self)
    for i=1,5 do
        local lastIcon = self.m_material_node_tab[i].m_material_node:getChildByTag(10)
        if lastIcon then
            lastIcon:removeFromParentAndCleanup(true)
        end
        -- self.m_material_node_tab[i].m_material_node:removeAllChildrenWithCleanup(true)
        self.m_material_node_tab[i].isAdded = false
        if i <= #self.m_hero_id_table then
            self.m_material_node_tab[i].isAdded = true
            local id = self.m_hero_id_table[i]
            local heroData,hero_config = game_data:getCardDataById(id);
            local tempIcon = game_util:createCardIconByCfg(hero_config)
            if tempIcon then
                tempIcon:setScale(0.75);
                self.m_material_node_tab[i].m_material_node:addChild(tempIcon,10,10)
            end
        else

        end
    end
    local count = self:getAddCardCount()
    local flag = false 
    if count > 0 then flag = true end
    self.btn_shuoming:setVisible(not flag)
    self.btn_chongzhi:setVisible(flag)

    --根据现在所选的来判断是哪个类型
    local firstCard = self.m_hero_id_table[1] or nil
    if firstCard then
        local itemData,itemCfg = game_data:getCardDataById(firstCard);
        local quality = itemCfg:getNodeWithKey("quality"):toInt();
        if quality == 3 then
            self.melting_type = 1
        elseif quality == 4 then
            self.melting_type = 2
        elseif quality == 5 then
            self.melting_type = 3
        elseif quality == 6 then
            self.melting_type = 4
        end
    else
        self.melting_type = 1
    end
    -- self:refreshUi()

    local count = self:getAddCardCount()
    -- self.btn_shuoming:setVisible((count<=0))
    -- self.btn_chongzhi:setVisible((count>0))
    self.card_node:removeAllChildrenWithCleanup(true)
    local showSprite = nil
    if self.melting_type == 1 then
        if count >= 2 then
            self.tip_label:setString(showTips[3])
        elseif count == 1 then
            self.tip_label:setString(showTips[2])
        else
            self.tip_label:setString(showTips[1])
        end
        if count == 2 then
            local heroData = {c_id = "50",bre = 0,lv = 1,level_max = 1,id = "0",step = 0}
            showSprite = game_util:createHeroListItemByCCB(heroData)--万能紫卡
            -- local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(heroData.c_id);
            -- local animation = itemConfig:getNodeWithKey("animation"):toStr();
            -- local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();
            -- showSprite = game_util:createImgByName("image_" .. animation,rgb,nil,nil,heroData.bre,itemConfig)
            showSprite:setScale(0.78)
        else
            showSprite = CCSprite:createWithSpriteFrameName("melting_card_orange.png");
        end
    elseif self.melting_type == 2 then
        if count >= 3 then
            self.tip_label:setString(showTips[5])
        else
            self.tip_label:setString(showTips[4])
        end
        if count == 3 then
            local heroData = {c_id = "52",bre = 0,lv = 1,level_max = 1,id = "0",step = 0}
            showSprite = game_util:createHeroListItemByCCB(heroData)----万能红卡
            showSprite:setScale(0.78)
        elseif count == 5 then
            local heroData = {c_id = "51",bre = 0,lv = 1,level_max = 1,id = "0",step = 0}
            showSprite = game_util:createHeroListItemByCCB(heroData)----万能橙卡*2
            local countLabel = game_util:createLabelBMFont({text = "×3"})
            countLabel:setScale(1.5)
            countLabel:setPosition(ccp(90,40))
            showSprite:addChild(countLabel)
            showSprite:setScale(0.78)
        else
            showSprite = CCSprite:createWithSpriteFrameName("melting_card_orange.png");
        end
    elseif self.melting_type == 3 then
        self.tip_label:setString(showTips[6])
        if count == 3 then
            local heroData = {c_id = "53",bre = 0,lv = 1,level_max = 1,id = "0",step = 0}
            showSprite = game_util:createHeroListItemByCCB(heroData)----万能金卡
            showSprite:setScale(0.78)
        else
            showSprite = CCSprite:createWithSpriteFrameName("melting_card_red.png");
        end
    elseif self.melting_type == 4 then
        self.tip_label:setString(showTips[7])
        if count == 1 then
            local heroData = {c_id = "52",bre = 0,lv = 1,level_max = 1,id = "0",step = 0}
            showSprite = game_util:createHeroListItemByCCB(heroData)----万能红卡
            local countLabel = game_util:createLabelBMFont({text = "×2"})
            countLabel:setScale(1.5)
            countLabel:setPosition(ccp(90,40))
            showSprite:addChild(countLabel)
            showSprite:setScale(0.78)
        else
            showSprite = CCSprite:createWithSpriteFrameName("melting_card_red.png");
        end
    end
    self.card_node:addChild(showSprite)
    --肉
    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local value,unit = game_util:formatValueToString(totalFood);
    self.m_food_total_label:setString(value .. unit);
    local meltingCfg = getConfig(game_config_field.exchange_card)
    self.m_needFood = 0
    local exchange_id = "0"
    if self.melting_type == 1 then
        if count == 2 or count == 5 then--可兑换，其他的不可兑换
            -- self.m_needFood = 100
            if count == 2 then exchange_id = "1" 
            elseif count == 5 then exchange_id = "2" end
        end
    elseif self.melting_type == 2 then
        if count == 3 or count == 5 then--可兑换，其他的不可兑换
            -- self.m_needFood = 200
            if count == 3 then exchange_id = "4" 
            elseif count == 5 then exchange_id = "3" end
        end
    elseif self.melting_type == 3 then
        if count == 3 then
            -- self.m_needFood = 300
            exchange_id = "5"
        end
    elseif self.melting_type == 4 then
        if count == 1 then
            exchange_id = "6"
        end
    end
    if exchange_id ~= "0" then
        local itemCfg = meltingCfg:getNodeWithKey(exchange_id)
        local cost = itemCfg:getNodeWithKey("cost")
        local food = cost:getNodeAt(0):getNodeAt(2):toInt()
        self.m_needFood = food
    end
    game_util:setCostLable(self.m_cost_food_label,self.m_needFood,totalFood);
    if self.m_needFood > totalFood then
        self.need_food = true
    else
        self.need_food = false
    end
end
--[[--
    刷新ui
]]
function game_card_melting.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function game_card_melting.init(self, t_params)
    t_params = t_params or {};
    self.m_material_node_tab = {}
    self.need_food = false
    self.card_ids = {}
    self.m_hero_id_table = {}
    self.melting_type = 1;--融合类型，添加时判断是否是同类型    1，紫卡   2，橙卡  3，红卡
    self.firstEnter = true;
    self.show_card_type = 1;--3 是所有，   大于3 是返回品质为选择的卡牌
    self.m_needFood = 0
end

--[[--
    创建ui入口并初始化数据
]]
function game_card_melting.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    -- self:guideHelper()
    local id = game_guide_controller:getIdByTeam("7");
    print("game_guide_controller:getIdByTeam(7)", id)
    if id == 707 then
        self:gameGuide("drama","7", 707)
    end
    return scene;
end


function game_card_melting.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" and id == 707 then
        local function endCallFunc()
            self:gameGuide("show","7",708)
        end
        t_params.guideType = "drama";
        t_params.endCallFunc = endCallFunc;
        game_guide_controller:showGuide(guide_team,guide_id,t_params)
    elseif guideType == "show" and id == 708 then
        game_guide_controller:gameGuide("show","7",708, {tempNode = self.btn_chongzhi})
    elseif guideType == "show" and id == 709 then
        game_guide_controller:gameGuide("show","7",709, {tempNode = self.btn_fenjie})
    elseif guideType == "drama" and id == 710 then
        local function endCallFunc()
            game_guide_controller:sendGuideData("7", 711)
            -- game_guide_controller:setGuideData("send","7",711);
        end
        t_params.guideType = "drama";
        t_params.endCallFunc = endCallFunc;
        game_guide_controller:showGuide(guide_team,guide_id,t_params)
    end
end


return game_card_melting;