---  技能强化

local ui_chongsheng_scene = {
    m_anim_node = nil,--动画节点
    m_selHeroId = nil,--选中的heroid
    m_ok_btn = nil,
    m_tips_spr_1 = nil,
    m_tips_spr_2 = nil,
    m_hero_bg_btn = nil,
    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_material_node = nil,
    m_selListItem = nil,
    m_curPage = nil,
    m_ccbNode = nil,
    m_anim_node_parent = nil,
    m_root_layer = nil,
    m_quick_sel_btn = nil,
    m_showHeroTable = nil,
    m_auto_add_btn = nil,
    m_scroll_view_tips = nil,
    m_selSortIndex = nil,
    m_light_bg_1 = nil,
    m_no_material_tips = nil,
    m_sell_id = nil,
};
--[[--
    销毁ui
]]
function ui_chongsheng_scene.destroy(self)
    -- body
    cclog("-----------------ui_chongsheng_scene destroy-----------------");
    self.m_anim_node = nil;
    self.m_selHeroId = nil;
    self.m_ok_btn = nil;
    self.m_tips_spr_1 = nil;
    self.m_tips_spr_2 = nil;
    self.m_hero_bg_btn = nil;
    self.m_list_view_bg = nil;
    self.m_sel_btn = nil;
    self.m_material_node = nil;
    self.m_selListItem = nil;
    self.m_curPage = nil;
    self.m_ccbNode = nil;
    self.m_anim_node_parent = nil;
    self.m_root_layer = nil;
    self.m_quick_sel_btn = nil;
    self.m_showHeroTable = nil;
    self.m_auto_add_btn = nil;
    self.m_scroll_view_tips = nil;
    self.m_selSortIndex = nil;
    self.m_light_bg_1 = nil;
    self.m_no_material_tips = nil;
    self.m_sell_id = nil;
end

--[[--
    返回
]]
function ui_chongsheng_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function ui_chongsheng_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 101 then-- 说明
            game_scene:addPop("game_active_limit_detail_pop",{enterType = 133})
        elseif btnTag == 102 then--重生
            cclog2(self.m_selHeroId, " this hero will chongsheng")
           local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = data and data:getNodeWithKey("reward") or nil
                if reward then
                    game_util:rewardTipsByJsonData(reward);
                end
                game_data:updateMoreCardDataByJsonData(data and data:getNodeWithKey("cards") or nil);
                self.m_selHeroId = nil
                self:refreshUi()
            end
            local card_id = self.m_selHeroId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("card_rebirth"), http_request_method.GET,
                 {card_id = card_id},"card_rebirth")
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            self:refreshSortTabBtn(btnTag - 200);
            local selSort = tostring(CARD_SORT_TAB[btnTag - 200].sortType);
            game_data:cardsSortByTypeName(selSort);
            self:refreshCardTableView();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_chongsheng.ccbi");
    --英雄相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")
    self.m_tips_spr_2 = ccbNode:spriteForName("m_tips_spr_2")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_hero_bg_btn = ccbNode:controlButtonForName("m_hero_bg_btn")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")

    self.m_quick_sel_btn = ccbNode:controlButtonForName("m_quick_sel_btn")
    self.m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")

    self.m_light_bg_1 = ccbNode:scale9SpriteForName("m_light_bg_1");
    self.m_no_material_tips = ccbNode:spriteForName("m_no_material_tips")

    game_util:setControlButtonTitleBMFont(self.m_sel_btn)
     game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file23)
    game_util:setCCControlButtonTitle(self.m_auto_add_btn,string_helper.ccb.file22)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    self.m_anim_node_parent = ccbNode:nodeForName("m_anim_node_parent")
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips")

    self.m_ccbNode = ccbNode
    game_util:createScrollViewTips(self.m_scroll_view_tips,{string_helper.ui_chongsheng_scene.title});--,"jnsj_miaoshu_1.png"

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text83)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text84)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text85)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text86)
    return ccbNode;
end

--[[--
    确定重生
]]
function ui_chongsheng_scene.onSureFunc(self)
   
end

--[[--
    属性英雄信息
]]
function ui_chongsheng_scene.refreshHeroInfo(self,heroId)
    self.m_selHeroId = heroId;
    local tempNode = nil;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
	if heroId ~= nil and heroId ~= "-1" then
        local cardData,heroCfg = game_data:getCardDataById(tostring(heroId));
        local ccbNode = game_util:createHeroListItemByCCB(cardData);
        self.m_anim_node:addChild(ccbNode,10,10);
	end
    self:refreshTips();
end

--[[--
    创建英雄列表
]]
function ui_chongsheng_scene.createTableView(self,viewSize)
    self.m_selListItem = nil;
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local cardsCount = game_data:getCardsCount();
    local totalItem = math.max(cardsCount%4 == 0 and cardsCount or math.floor(cardsCount/4+1)*4,4)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = cardsCount -- totalItem;
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local id = game_guide_controller:getIdByTeam("3");
    if id == 302 then
        params.itemActionFlag = false;
    else
        local id = game_guide_controller:getIdByTeam("6");
        if id == 601 then
            params.itemActionFlag = false;
        else
            params.itemActionFlag = true;
        end
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < cardsCount then
                local itemData,_ = game_data:getCardDataByIndex(index+1);
                if itemData then
                    local card_id = itemData.id;
                    game_util:setHeroListItemInfoByTable2(ccbNode,itemData);
                    if self.m_selHeroId and self.m_selHeroId == card_id then
                        local m_sel_img = ccbNode:spriteForName("sprite_selected")
                        m_sel_img:setVisible(true);
                        local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                        sprite_back_alpha:setVisible(true);
                        self.m_selListItem = cell;
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if index >= cardsCount then return end;
        if eventType == "ended" and cell then
            local itemData,itemConfig = game_data:getCardDataByIndex(index+1);
            -- cclog2(itemData, "itemData   ====   ")

            local is_in_team = game_data:heroInTeamById(itemData.id);
            local is_lock = game_util:getCardUserLockFlag(itemData);
            local is_in_train = game_util:getCardTrainingFlag(itemData);
            local is_in_cheer = game_data:heroInAssistantById(itemData.id)
            local can_select = is_in_team or is_lock or is_in_train or is_in_cheer;
            if can_select == true then
                if is_in_team then
                    game_util:addMoveTips({text = string_helper.ui_chongsheng_scene.text});
                elseif is_in_train then
                    game_util:addMoveTips({text = string_helper.ui_chongsheng_scene.text2});
                elseif is_lock then
                    game_util:addMoveTips({text = string_helper.ui_chongsheng_scene.text3});
                elseif is_in_cheer then
                    game_util:addMoveTips({text = string_helper.ui_chongsheng_scene.text4});
                end
                return
            end

            local card_id = itemData.id;
            if self.m_selHeroId == nil or self.m_selHeroId ~= card_id then
                local character_ID = itemConfig:getNodeWithKey("character_ID"):toInt();
                if not itemData.step or itemData.step < 4 then
                    game_util:addMoveTips({text = string_helper.ui_chongsheng_scene.text5});
                    return;
                end
                if self.m_selListItem then
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("sprite_selected")
                    m_sel_img:setVisible(false);
                    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                    sprite_back_alpha:setVisible(false);
                end
                self.m_selListItem = cell;
                self.m_selHeroId = card_id;
                self:refreshHeroInfo(self.m_selHeroId);
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:spriteForName("sprite_selected")
                m_sel_img:setVisible(true);
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                sprite_back_alpha:setVisible(true);
            end
        elseif eventType == "longClick" and cell then
            local itemData,_ = game_data:getCardDataByIndex(index+1);
            local function callBack(typeName)
                typeName = typeName or ""
                if typeName == "refresh" then
                    self:refreshCardTableView();
                end
            end
            game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 1,callBack = callBack})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function ui_chongsheng_scene.refreshCardTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--

]]
function ui_chongsheng_scene.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    self.m_selSortIndex = sortIndex
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
end

--[[--
    刷新
]]
function ui_chongsheng_scene.refreshTableView( self )
    self.m_no_material_tips:setVisible(false);
    -- self.m_ok_btn:setVisible(false);
    -- self.m_auto_add_btn:setVisible(true);
    self:refreshSortTabBtn(self.m_selSortIndex);
    self:refreshCardTableView();
    self:refreshTips(); 
end

--[[--
    刷新状态
]]
function ui_chongsheng_scene.refreshTips( self )
    game_util:setCCControlButtonEnabled(self.m_auto_add_btn,true);
    if self.m_selHeroId == nil then
        game_util:setCCControlButtonEnabled(self.m_auto_add_btn,false);
        self.m_tips_spr_1:setVisible(true);

        self.m_tips_spr_2:setVisible(false);
        self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
        self.m_light_bg_1:runAction(game_util:createRepeatForeverFade())
    else
        self.m_tips_spr_1:setVisible(false);
        self.m_tips_spr_2:setVisible(false);
    end
end

--[[--
    刷新ui
]]
function ui_chongsheng_scene.refreshUi(self)
    self:refreshHeroInfo(self.m_selHeroId);
    self:refreshTableView();
end
--[[--
    初始化
]]
function ui_chongsheng_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_showHeroTable = {};
    local selSort = game_data:getCardSortType();
    for k,v in pairs(CARD_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function ui_chongsheng_scene.create(self,t_params)
    -- body
    game_data:addOneNewButtonByBtnID(503)   -- 已经了解了技能升级功能
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();
    return uiNode;
end

return ui_chongsheng_scene;
