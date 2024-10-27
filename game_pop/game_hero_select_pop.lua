---  弹框选择

local game_hero_select_pop = {
    m_list_view_bg = nil,
    m_selSortType = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_title_label = nil,
    m_curPage = nil,
    m_popUi = nil,
    m_guildNode = nil,
    m_openType = nil,
};
--[[--
    销毁
]]
function game_hero_select_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_select_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_selSortType = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_title_label = nil;
    self.m_curPage = nil;
    self.m_popUi = nil;
    self.m_guildNode = nil;
    self.m_openType = nil;
end

--[[--
    返回
]]
function game_hero_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_data:resetNewCardIdTab();
    game_scene:removePopByName("game_hero_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_hero_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            end
            self:back();
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                self.m_selSortType = CARD_SORT_TAB[btnTag].sortType;
                game_data:cardsSortByTypeName(self.m_selSortType);
                self:refreshUi();
            end
            local selSortType = game_data:getCardSortType();
            game_scene:addPop("game_sort_pop",{btnTitleTab = CARD_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = selSortType})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString(string_helper.game_hero_select_pop.heroList)
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end


--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,_ = game_data:getCardDataByIndex(index+1);
                if itemData then
                    game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                end
                if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                    cell:setContentSize(itemSize);
                    self.m_guildNode = cell;
                end
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local card_id = itemData.id;
            if self.m_itemOnClick then
                self.m_itemOnClick(card_id);
                self:back();
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_hero_select_pop.createTableView2(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local selSortType = game_data:getCardSortType();
    game_data:cardsSortByTypeName(selSortType);
    local cardsCount = game_data:getCardsCount() + 1;
    local totalItem = math.max(cardsCount%8 == 0 and cardsCount or math.floor(cardsCount/8+1)*8,8)

    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 100, 120)
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand)
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < cardsCount then
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local itemData,_ = game_data:getCardDataByIndex(index);
                    if itemData then
                        game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    end
                    if not game_data:heroInTeamById(itemData.id) and self.m_guildNode == nil then
                        cell:setContentSize(itemSize);
                        self.m_guildNode = cell;
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= cardsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local itemData,_ = game_data:getCardDataByIndex(index);
                local card_id = itemData.id;
                if self.m_itemOnClick then
                    if game_data.getGuideProcess and game_data:getGuideProcess() == "second_enter_main_scene" then
                        if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(37) end  -- 第一次点击阵型, 选择英雄 点击钢架 步骤37
                    end
                    self.m_itemOnClick("exchanged",card_id);
                    self:back();
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_hero_select_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    if self.m_openType == 2 then
        self.m_tableView = self:createTableView2(self.m_list_view_bg:getContentSize());
    else
        self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    end
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    初始化
]]
function game_hero_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_selSortType = "lv";
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_openType = t_params.openType or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if id == 20 and self.m_guildNode then
        game_guide_controller:gameGuide("show","1",21,{tempNode = self.m_guildNode})
    end
    return self.m_popUi;
end

return game_hero_select_pop;