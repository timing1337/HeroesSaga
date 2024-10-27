---  英雄选择  

local game_hero_select = {
    m_openType = nil,--打开选择的类型
    m_selectHeroIdTable = nil,--选择的英雄id表
    m_selHeroId = nil,--选中的强化的英雄id
    m_material_id_table = nil,
    m_ok_btn = nil,
    m_max_material_count = nil,
    m_posIndex = nil,
};
--[[--
    销毁
]]
function game_hero_select.destroy(self)
    -- body
    cclog("-----------------game_hero_select destroy-----------------");
    self.m_openType =nil;
    self.m_selectHeroIdTable = nil;
    self.m_selHeroId = nil;
    self.m_material_id_table = nil;
    self.m_ok_btn = nil;
    self.m_max_material_count = nil;
    self.m_posIndex = nil;
end
--[[--
    返回
]]
function game_hero_select.back(self,backType)
    if self.m_openType == "select_strengthen_hero" or self.m_openType == "select_material_hero" then
        game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil,selHeroId = self.m_selHeroId,material_id_table = self.m_material_id_table});
    end
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_hero_select.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 or btnTag == 3 then
            self:back("back");
        elseif btnTag == 2 then--排序
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_select.ccbi");
    local m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_ok_btn:setVisible(false)
    if (self.m_openType == "select_advanced_material") and self.m_selHeroId ~= nil then
        self.m_tableView = self:createFilterTableView(m_list_view_bg:getContentSize());
    else
        self.m_tableView = self:createTableView(m_list_view_bg:getContentSize());
    end
    if self.m_openType == "select_material_hero" then
        self.m_max_material_count = 6;
        self.m_ok_btn:setVisible(true);
        game_util:setCCControlButtonTitle(self.m_ok_btn,#self.m_material_id_table .. "/" .. self.m_max_material_count)
    end
    m_list_view_bg:addChild(self.m_tableView);
    return ccbNode;
end


--[[--
    创建筛选的列表
]]
function game_hero_select.createFilterTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local character_ID = -1;
    local heroData = nil;
    local itemConfig = nil;
    local selHeroStar = 0;
    local selQuality = 0;
    local skillItem = nil;
    local skillId = nil;
    local currentSkillTable = {};

    if self.m_selHeroId ~= nil then
        heroData,itemConfig = game_data:getCardDataById(tostring(self.m_selHeroId));
        selHeroStar = heroData.star
        character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
        selQuality = itemConfig:getNodeWithKey("quality"):toInt();
        for i=1,3 do
            skillItem = heroData["s_" .. i]
            skillId = skillItem.s
            if skillId and skillId ~= 0 and skillItem.avail == 2 then
                if self.m_selSkillIndex == nil then
                    currentSkillTable[skillId]=i;
                else
                    if i == self.m_selSkillIndex then
                        currentSkillTable[skillId]=i;
                    end
                end
            end
        end
    end

    local character_detail = getConfig(game_config_field.character_detail);
    local cardsDataTable = game_data:getTableCardsData();
    local showHeroTable = {};
    for key,heroData in pairs(cardsDataTable) do
        if key ~= tostring(self.m_selHeroId) and not game_data:heroInTeamById(key) then
        itemConfig = character_detail:getNodeWithKey(heroData.c_id);
        if self.m_openType == "select_advanced_material" then
            if character_ID == itemConfig:getNodeWithKey("character_ID"):toInt() and selHeroStar >= heroData.star then
                showHeroTable[#showHeroTable+1] = {heroData = heroData,heroCfg = itemConfig}
            end 
        elseif self.m_openType == "select_inheritance_material" then--有相同的技能并且材料的星要高
            if selHeroStar <= heroData.star then
                for i=1,3 do
                    skillItem = heroData["s_" .. i]
                    skillId = skillItem["s"]
                    if skillId and skillId ~= 0 and skillItem.avail == 2 and  currentSkillTable[skillId]~=nil then
                        cclog("skillId =============================" .. skillId);
                        showHeroTable[#showHeroTable+1] = {heroData = heroData,heroCfg = itemConfig}
                        break;
                    end
                end
            end
        elseif self.m_openType == "select_skills_reset_material" then--材料卡的品质要相等或者高于主卡
            if selQuality <= itemConfig:getNodeWithKey("quality"):toInt() then
                showHeroTable[#showHeroTable+1] = {heroData = heroData,heroCfg = itemConfig}
                cclog("heroData key ===" .. key .. " ; #showHeroTable ==" .. #showHeroTable);
            end
        elseif self.m_openType == "select_material_hero" then
            showHeroTable[#showHeroTable+1] = {heroData = heroData,heroCfg = itemConfig}
        end
        end
    end
    local function sortFunc(dataOne,dataTwo)
        return dataOne.heroCfg:getNodeWithKey("quality"):toInt() > dataTwo.heroCfg:getNodeWithKey("quality"):toInt();
    end
    table.sort(showHeroTable,sortFunc)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = #showHeroTable;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local itemData = showHeroTable[index+1].heroData;
            local heroId = itemData.id;
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode and itemData then
                game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                local m_spr_bg = tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite");
                local tempNode = cell:getChildByTag(20);
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true);
                end
                tempNode = cell:getChildByTag(30);
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true);
                end
                if game_data:heroInTeamById(heroId) then--在编队中
                    local inTeamSpr = CCSprite:createWithSpriteFrameName("public_played.png");
                    inTeamSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                    cell:addChild(inTeamSpr,20,20);
                    m_spr_bg:setColor(ccc3(0,0,0));
                elseif tostring(itemData.id) == tostring(self.m_selHeroId)  then--不能选择的
                    cclog("sel ===============================id = " .. self.m_selHeroId);
                    m_spr_bg:setColor(ccc3(0,0,0));
                else--可以选择的和取消选择的
                    m_spr_bg:setColor(ccc3(255,255,255));
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_material_id_table)
                    if flag then
                        local selSpr = CCSprite:createWithSpriteFrameName("public_listxuanzhong.png");
                        selSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                        cell:addChild(selSpr,30,30);
                    else
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if eventType == "ended" and item then
                local itemData = showHeroTable[index+1].heroData;
                local heroId = tostring(itemData.id);
            -- if (not game_data:heroInTeamById(heroId)) then
                if self.m_openType == "select_advanced_material" then
                    if not game_data:heroInTeamById(heroId) and self.m_selHeroId ~= heroId then
                        self.m_material_id_table[1] = heroId;
                        self:back();
                    end
                elseif self.m_openType == "select_material_hero" then
                    if not game_data:heroInTeamById(heroId) and self.m_selHeroId ~= heroId then
                        local flag,k = game_util:idInTableById(heroId,self.m_material_id_table)
                        -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                        if flag and k ~= nil then
                            -- cclog("remove select material hero id ==========" .. heroId);
                            table.remove(self.m_material_id_table,k);
                            -- tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite"):setColor(ccc3(255,255,255));
                            if item:getChildByTag(30) then
                                item:removeChildByTag(30,true);
                            end
                        else
                            if #self.m_material_id_table < self.m_max_material_count then
                                -- cclog("add select material hero id ==========" .. heroId);
                                table.insert(self.m_material_id_table,heroId);
                                -- tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite"):setColor(ccc3(255,0,0));
                                local selSpr = CCSprite:createWithSpriteFrameName("public_listxuanzhong.png");
                                selSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                                item:addChild(selSpr,30,30);
                            end
                        end
                        -- print("---------------------------------m_material_id_table-----start");
                        -- table.foreach(self.m_material_id_table,print);
                        -- print("--------------------------------m_material_id_table------end");
                        game_util:setCCControlButtonTitle(self.m_ok_btn,#self.m_material_id_table .. "/" .. self.m_max_material_count)
                    end
                end
            -- end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建所有的英雄列表
]]
function game_hero_select.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = game_data:getCardsCount();
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local card_id = game_data:getCardIdByIndex(index+1);
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode and itemData then
                game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                local m_spr_bg = tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite");
                local tempNode = cell:getChildByTag(20);
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true);
                end
                tempNode = cell:getChildByTag(30);
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true);
                end
                if game_data:heroInTeamById(card_id) then--在编队中
                    local inTeamSpr = CCSprite:createWithSpriteFrameName("public_played.png");
                    inTeamSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                    cell:addChild(inTeamSpr,20,20);
                    -- m_spr_bg:setColor(ccc3(0,0,0));
                elseif tostring(card_id) == tostring(self.m_selHeroId)  then--不能选择的
                    cclog("sel ===============================id = " .. self.m_selHeroId);
                    -- m_spr_bg:setColor(ccc3(0,0,0));
                else--可以选择的和取消选择的
                    -- m_spr_bg:setColor(ccc3(255,255,255));
                    local flag,k = game_util:idInTableById(card_id,self.m_material_id_table)
                    if flag then--选择的
                        local selSpr = CCSprite:createWithSpriteFrameName("public_listxuanzhong.png");
                        selSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                        cell:addChild(selSpr,30,30);
                    else--没有选择的
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if eventType == "ended" and item then
            local card_id = game_data:getCardIdByIndex(index+1);
            -- if (not game_data:heroInTeamById(card_id)) then
                if self.m_openType == "select_strengthen_hero" then
                    self.m_selHeroId = card_id;
                    self:back();
                elseif self.m_openType == "select_advanced_material"then
                    if not game_data:heroInTeamById(card_id) and self.m_selHeroId ~= card_id then
                        self.m_material_id_table[1] = card_id;
                        self:back();
                    end
                elseif self.m_openType == "select_material_hero" then
                    if not game_data:heroInTeamById(card_id) and self.m_selHeroId ~= card_id then
                        local flag,k = game_util:idInTableById(card_id,self.m_material_id_table)
                        -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                        if flag and k ~= nil then--取消选择
                            -- cclog("remove select material hero id ==========" .. card_id);
                            table.remove(self.m_material_id_table,k);
                            -- tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite"):setColor(ccc3(255,255,255));
                            if item:getChildByTag(30) then
                                item:removeChildByTag(30,true);
                            end
                        else--选择
                            if #self.m_material_id_table < self.m_max_material_count then
                                -- cclog("add select material hero id ==========" .. card_id);
                                table.insert(self.m_material_id_table,card_id);
                                -- tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite"):setColor(ccc3(255,0,0));
                                local selSpr = CCSprite:createWithSpriteFrameName("public_listxuanzhong.png");
                                selSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                                item:addChild(selSpr,30,30);
                            end
                        end
                        -- print("---------------------------------m_material_id_table-----start");
                        -- table.foreach(self.m_material_id_table,print);
                        -- print("--------------------------------m_material_id_table------end");
                        game_util:setCCControlButtonTitle(self.m_ok_btn,#self.m_material_id_table .. "/" .. self.m_max_material_count)
                    end
                end
            -- end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_hero_select.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_hero_select.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_material_id_table = t_params.material_id_table or {};
    self.m_selHeroId = t_params.selHeroId;
    self.m_selectHeroIdTable = {};
    self.m_max_material_count = 1;
    self.m_openType = t_params.openType;
    self.m_posIndex = t_params.posIndex;
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_select.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_hero_select;