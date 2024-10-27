---  英雄信息弹出框 

local game_hero_info_pop = {
    m_tGameData = nil,
    m_popUi = nil,
    m_heroDataBackup = nil,
    m_root_layer = nil,
    m_name_label = nil,
    m_anim_node = nil,
    m_level_label = nil,
    m_bar_bg = nil,
    m_race_label = nil,
    m_life_label = nil,
    m_physical_atk_label = nil,
    m_magic_atk_label = nil,
    m_def_label = nil,
    m_speed_label = nil,
    m_story_label = nil,
    m_close_btn = nil,
    m_openType = nil, -- 1 查看自己的卡牌 2卡牌升级 3 查看其他玩家卡牌
    m_currentSkillTable = nil,
    m_skill_layer = nil,
    m_callBack = nil,
    m_lock_btn = nil,
    m_lockFlag = nil,
    m_lockChangedFlag = nil,
    m_img_1 = nil,
    m_img_2 = nil,
    m_occupation_icon = nil,
    m_cId = nil,
    m_info_scroll_view = nil,
    m_fate_label = nil,
    m_lllustrationsOpenFlag = nil,
    m_func_btn_node = nil,
    m_short_story_label = nil,
    m_ccbNode = nil,
    m_ccbNodeItem = nil,
    m_break_flag_label = nil,
    m_card_bre_value = nil,
    m_card_cfg_id = nil,
    m_heroInfoItem = nil,
    m_funBtns = nil,
};

--[[--
    销毁
]]
function game_hero_info_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_info_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_popUi = nil;
    self.m_heroDataBackup = nil;
    self.m_root_layer = nil;
    self.m_name_label = nil;
    self.m_anim_node = nil;
    self.m_level_label = nil;
    self.m_bar_bg = nil;
    self.m_race_label = nil;
    self.m_life_label = nil;
    self.m_physical_atk_label = nil;
    self.m_magic_atk_label = nil;
    self.m_def_label = nil;
    self.m_speed_label = nil;
    self.m_story_label = nil;
    self.m_close_btn = nil;
    self.m_openType = nil;
    self.m_currentSkillTable = nil;
    self.m_skill_layer = nil;
    self.m_callBack= nil;
    self.m_lock_btn = nil;
    self.m_lockFlag = nil;
    self.m_lockChangedFlag = nil;
    self.m_img_1 = nil;
    self.m_img_2 = nil;
    self.m_occupation_icon = nil;
    self.m_cId = nil;
    self.m_info_scroll_view = nil;
    self.m_fate_label = nil;
    self.m_lllustrationsOpenFlag = nil;
    self.m_func_btn_node = nil;
    self.m_short_story_label = nil;
    self.m_ccbNode = nil;
    self.m_ccbNodeItem = nil;
    self.m_break_flag_label = nil;
    self.m_card_bre_value = nil;
    self.m_card_cfg_id = nil;
    self.m_heroInfoItem = nil;
    self.m_funBtns = nil;
end
--[[--
    返回
]]
function game_hero_info_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_hero_info_pop");
end

--[[--
    读取ccbi创建ui
]]
function game_hero_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_lockChangedFlag then
                local function responseMethod(tag,gameData)
                    if self.m_callBack and type(self.m_callBack) == "function" then
                        self.m_callBack("refresh");
                    end
                    self:back();
                end
                --  card_id= 释放锁
                local params = {};
                params.card_id = self.m_tGameData.id;
                if self.m_lockFlag == true then
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_lock_card"), http_request_method.GET, params,"cards_lock_card");
                else
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_release_card"), http_request_method.GET, params,"cards_release_card");
                end
            else
                if self.m_callBack and type(self.m_callBack) == "function" then
                    self.m_callBack("noRefresh");
                end
                self:back();
            end
        elseif btnTag == 2 then
            if self.m_lockFlag == true then
                self.m_lockFlag = false;
            else
                self.m_lockFlag = true;
            end
            self:refresLockBtn();
            self.m_lockChangedFlag = true;
        elseif btnTag > 20 and btnTag < 26 then
            if self.m_tGameData and self.m_openType ~= 4 then
                game_scene:addPop("game_hero_attr_pop",{selHeroId = self.m_tGameData.id,posNode=tagNode,attrType = btnTag-20})
            end
        elseif btnTag == 101 then--技能升级
            if not game_button_open:checkButtonOpen(503) then
                return;
            end
            game_scene:enterGameUi("skills_strengthen_scene",{selHeroId = self.m_tGameData.id});
        elseif btnTag == 102 then--伙伴进阶
            if not game_button_open:checkButtonOpen(502) then
                return;
            end
            game_scene:enterGameUi("game_hero_advanced_sure",{selHeroId = self.m_tGameData.id});
        elseif btnTag == 103 then--属性改造
            if not game_button_open:checkButtonOpen(509) then
                return;
            end
            game_scene:enterGameUi("game_hero_culture_scene",{selHeroId = self.m_tGameData.id});
        elseif btnTag == 104 then--伙伴重生
            if not game_button_open:checkButtonOpen(117) then
                return;
            end
            -- game_scene:enterGameUi("game_card_split");
            game_scene:enterGameUi("ui_chongsheng_scene");   -- 改为重生
        elseif btnTag == 105 then--伙伴传承
            if not game_button_open:checkButtonOpen(506) then
                return;
            end
            game_scene:enterGameUi("game_hero_inherit");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_info_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_bar_bg = ccbNode:nodeForName("m_bar_bg")
    self.m_race_label = ccbNode:labelTTFForName("m_race_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_lock_btn = ccbNode:controlButtonForName("m_lock_btn")
    self.m_lock_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_img_1 = ccbNode:spriteForName("m_img_1")--显示完美和出战图标
    self.m_img_2 = ccbNode:spriteForName("m_img_2")
    self.m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    self.m_func_btn_node = ccbNode:nodeForName("m_func_btn_node")
    self.m_func_btn_node:setVisible(false);
    self.m_short_story_label = ccbNode:labelTTFForName("m_short_story_label")
    self.m_short_story_label:setFontSize( 8 )

    self.m_info_scroll_view = ccbNode:scrollViewForName("m_info_scroll_view")
    self.m_img_1:setVisible(false);
    self.m_img_2:setVisible(false);
    self.m_funBtns = {}
    for i=1,5 do
        local tempBtn = ccbNode:controlButtonForName("m_func_btn_" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
            self.m_funBtns["btn" .. tostring(i)] = tempBtn
        end
    end
    -- local btn = nil;
    -- for i=1,5 do
    --     btn = ccbNode:controlButtonForName("m_attr_btn_" .. i)
    --     btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    -- end
    -- if self.m_openType ~= 4 then
    --     self:initSkillLayerTouch(self.m_skill_layer);
    -- end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    self.m_root_layer:setTouchEnabled(true);

    local tempCcbNode = self:createHeroInfoItem();
    self.m_heroInfoItem = tempCcbNode;
    self.m_info_scroll_view:addChild(tempCcbNode);
    local viewSize = self.m_info_scroll_view:getViewSize();
    local contentSize = tempCcbNode:getContentSize();
    cclog("viewSize.width = " .. viewSize.width .. " viewSize.height = " .. viewSize.height)
    cclog("contentSize.width = " .. contentSize.width .. " contentSize.height = " .. contentSize.height)
    self.m_info_scroll_view:setContentSize(contentSize);
    self.m_info_scroll_view:setContentOffset(ccp(0, viewSize.height - contentSize.height));
    self.m_info_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    创建英雄信息
]]
function game_hero_info_pop.createHeroInfoItem(self,viewSize)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 20 and btnTag < 26 then
            if self.m_tGameData and self.m_openType ~= 4 then
                game_scene:addPop("game_hero_attr_pop",{selHeroId = self.m_tGameData.id,posNode=tagNode,attrType = btnTag-20})
            end
        end
    end
    local ccbNode = luaCCBNode:create();
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_info_item.ccbi");
    -- ccbNode:setAnchorPoint(ccp(0.5,0.5));
    -- viewSize = ccbNode:getContentSize();
    -- ccbNode:setPosition(ccp(viewSize.width*0.5,viewSize.height*0.5));
    local btn = nil;
    for i=1,5 do
        btn = ccbNode:controlButtonForName("m_attr_btn_" .. i)
        btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    end
    self.m_level_label = ccbNode:labelTTFForName("m_level_label")
    self.m_life_label = ccbNode:labelTTFForName("m_life_label")
    self.m_physical_atk_label = ccbNode:labelTTFForName("m_physical_atk_label")
    self.m_magic_atk_label = ccbNode:labelTTFForName("m_magic_atk_label")
    self.m_def_label = ccbNode:labelTTFForName("m_def_label")
    self.m_speed_label = ccbNode:labelTTFForName("m_speed_label")
    self.m_story_label = ccbNode:labelTTFForName("m_story_label")
    self.m_skill_layer = ccbNode:layerForName("m_skill_layer")
    self.m_fate_label = ccbNode:labelTTFForName("m_fate_label")
    self.m_break_flag_label = ccbNode:labelTTFForName("m_break_flag_label")
    self.m_break_flag_label:setVisible(false);
    -- if self.m_openType ~= 4 then
        self:initSkillLayerTouch(self.m_skill_layer);
    -- end
    local m_attr_node = ccbNode:nodeForName("m_attr_node")
    local m_node_zhusheng = ccbNode:nodeForName("m_node_zhusheng")
    local m_node_zhusheng2 = ccbNode:nodeForName("m_node_zhusheng2")
    if not game_data:isViewOpenByID( 130 ) then--宝石开关
        if m_attr_node then
            m_attr_node:setVisible(false);
        end
    end
    if not game_data:isViewOpenByID( 44 ) then--转生开关
        if m_node_zhusheng then 
            m_node_zhusheng:setVisible(false)
            -- m_node_zhusheng2:setVisible(false)
        end
    end
    self.m_ccbNodeItem = ccbNode
    self:resetCardDetailNodePosition();

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text244)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text245)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text246)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text247)
    return ccbNode;
end

--[[

]]
function game_hero_info_pop.resetCardDetailNodePosition(self)
    local showNodeTab = {"m_node_zhusheng2","m_node_zhusheng","m_skill_layer","m_attr_node","m_base_attr_node"}
    local pX = 0;
    for i=1,#showNodeTab do
        local tempNode = self.m_ccbNodeItem:nodeForName(showNodeTab[i])
        if tempNode and tempNode:isVisible() then
            tempNode:setPositionY(pX)
            pX = pX + tempNode:getContentSize().height;
        end
    end
    local tempSize = self.m_ccbNodeItem:getContentSize();
    self.m_ccbNodeItem:setContentSize(CCSizeMake(tempSize.width, pX))
    self.m_info_scroll_view:setContentSize(CCSizeMake(tempSize.width, pX));
end

--[[--
    
]]
function game_hero_info_pop.cardChainByCfg(self,heroCfg,cardId)
    if heroCfg == nil then return end
    local chainTab = game_util:cardChainByCfg(heroCfg,cardId)
    local tempCount = #chainTab
    local showStr = ""
    if tempCount > 0 then
        for i=1,tempCount do
            if i ~= tempCount then
                showStr = showStr .. chainTab[i].detail .. "\n"
            else
                showStr = showStr .. chainTab[i].detail
            end
        end
    else
        showStr = string_helper.game_hero_info_pop.none;
    end
    local viewSize = self.m_info_scroll_view:getViewSize();
    -- local msgLabel = game_util:createRichLabelTTF({text = showStr,dimensions = labelsize,textAlignment = kCCTextAlignmentLeft,verticalTextAlignment,color = ccc3(221,221,192)})
    local msgLabel = game_util:createCustomLabel({text = showStr,title = string_helper.game_hero_info_pop.fate,labelWidth = viewSize.width - 16})
    local msgLabelSize = msgLabel:getContentSize();
    local story = string_helper.game_hero_info_pop.none;
    if heroCfg then
        -- self.m_story_label:setString(heroCfg:getNodeWithKey("story"):toStr());
        story = heroCfg:getNodeWithKey("story"):toStr();
    end
    local storyNode = game_util:createCustomLabel({text = story,title = string_helper.game_hero_info_pop.introdction,labelWidth = viewSize.width - 16,pos = 15})
    local storyNodeSize = storyNode:getContentSize();
    msgLabel:setPosition(ccp(8,storyNodeSize.height));
    storyNode:setPosition(ccp(8,0));
    self.m_heroInfoItem:setPosition(ccp(0, storyNodeSize.height + msgLabelSize.height))
    local contentSize = self.m_info_scroll_view:getContentSize();
    local realSize = CCSizeMake(contentSize.width, contentSize.height+msgLabelSize.height+storyNodeSize.height)
    self.m_info_scroll_view:setContentSize(realSize);
    self.m_info_scroll_view:setContentOffset(ccp(0, viewSize.height - realSize.height));
    self.m_info_scroll_view:addChild(msgLabel);
    self.m_info_scroll_view:addChild(storyNode);
end

--[[--
    技能层
]]
function game_hero_info_pop.initSkillLayerTouch(self,formation_layer)
    local items = formation_layer:getChildren();
    local itemCount = items:count();
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        touchBeginPoint = {x = x, y = y}
        touchMoveFlag = false;
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for i = 1,itemCount do
            tempItem = tolua.cast(items:objectAtIndex(i - 1),"CCSprite");
            if tempItem:boundingBox():containsPoint(realPos) then
                tag = tempItem:getTag();
                cclog("tag == ".. tag)
                if tag < 7 and self.m_currentSkillTable[tag] ~= nil then
                    
                else
                    tempItem = nil;
                end
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if tempItem and tempItem:boundingBox():containsPoint(realPos) and tag and tag < 7 then
            local itemData = self.m_currentSkillTable[tag]
            if itemData then
                if self.m_openType == 1 or self.m_openType == 2 then
                    game_scene:addPop("skills_activation_pop",{skillData = itemData,selHeroId=self.m_tGameData.id,posIndex = tag})
                elseif self.m_openType == 3 then
                    game_scene:addPop("skills_activation_pop",{skillData = itemData,selHeroId=self.m_tGameData.id,posIndex = tag})
                elseif self.m_openType == 4 then
                    game_scene:addPop("skills_activation_pop",{skillData = itemData,selHeroId=-1,posIndex = tag})
                end
            end
        end
        tempItem = nil;
        tag = nil;
        -- if touchMoveFlag == false then
        --     for i=1,10 do
        --         local m_star_icon = self.m_ccbNodeItem:spriteForName("m_break_icon_" .. i)
        --         local parentNode = m_star_icon:getParent();
        --         if parentNode:isVisible() == false then
        --             break;
        --         end
        --         realPos = parentNode:convertToNodeSpace(ccp(x,y));
        --         if m_star_icon:boundingBox():containsPoint(realPos) then
        --             if self.m_card_cfg_id and self.m_card_bre_value then
        --                 game_scene:addPop("hero_breakthrough_detail_pop",{cardCfgId = self.m_card_cfg_id,breValue = self.m_card_bre_value,selBreValue = i})
        --             end
        --         end
        --     end
        -- end
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true)
    formation_layer:setTouchEnabled(true)
end

function game_hero_info_pop.cardBreakIcon(self,itemCfg,bre)
    local character_break_cfg = getConfig(game_config_field.character_break_new)
    local character_ID = itemCfg:getKey()--itemCfg:getNodeWithKey("character_ID"):toStr();
    local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
    if character_break_item == nil then--不能进阶
        self.m_break_flag_label:setVisible(true);
        -- local m_break_icon = self.m_ccbNodeItem:spriteForName("m_break_icon_1")
        -- m_break_icon:getParent():setVisible(false);
        for i=1,5 do
            local m_break_icon = self.m_ccbNodeItem:spriteForName("m_break_icon_" .. i)
            local m_break_label = self.m_ccbNodeItem:spriteForName("m_break_label_" .. i)
            m_break_icon:setVisible(false);
            m_break_label:setVisible(false);
        end
    else
        local high_break = character_break_item:getNodeWithKey("high_break")
        high_break = high_break and high_break:toInt() or 5
        local bre = math.min(bre or 0,high_break)
        -- if high_break > 5 and bre >= 5 then--显示10转
        --     local m_node_zhusheng = self.m_ccbNodeItem:nodeForName("m_node_zhusheng")
        --     -- local m_node_zhusheng2 = self.m_ccbNodeItem:nodeForName("m_node_zhusheng2")
        --     -- m_node_zhusheng2:setVisible(m_node_zhusheng:isVisible())
        --     self:resetCardDetailNodePosition();
        -- end
        -- for i=1,10 do
        --     local m_break_icon = self.m_ccbNodeItem:spriteForName("m_break_icon_" .. i)
        --     local m_break_label = self.m_ccbNodeItem:spriteForName("m_break_label_" .. i)
        --     if i <= bre then
        --         -- m_break_icon:setVisible(true);
        --     else
        --         -- m_break_icon:setVisible(false);
        --         m_break_icon:setColor(ccc3(81, 81, 81));
        --         m_break_label:setColor(ccc3(81, 81, 81));
        --     end
        --     m_break_icon:setVisible(i <= high_break)
        --     m_break_label:setVisible(i <= high_break)
        -- end
        self:refreshBreakTable(bre < 5 and 5 or high_break, bre);
        self.m_card_bre_value = bre;
        self.m_card_cfg_id = itemCfg:getKey();
    end
end

--[[
    
]]
function game_hero_info_pop.createBreakTable(self, viewSize, maxBreak,currentBreak)
    maxBreak = maxBreak or 5;
    currentBreak = currentBreak or 0;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    params.totalItem = maxBreak;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_hero_breakthrough_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_break_icon = ccbNode:spriteForName("m_break_icon")
            local m_break_label = ccbNode:labelTTFForName("m_break_label")
            local m_break_sel_spr = ccbNode:spriteForName("m_break_sel_spr")
            -- m_break_sel_spr:setVisible(currentBreak == index)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("kpxq_break_" .. (index+1) .. ".png")
            if tempSpriteFrame then
                m_break_icon:setDisplayFrame(tempSpriteFrame);
            end
            local tempStr = game_util:getBreakLevelDes(index+1)
            --m_break_label:setString(tostring(tempStr) .. string_helper.game_hero_info_pop.zhuan)
            m_break_label:setString(tostring(tempStr))
            if index < currentBreak then
                m_break_icon:setColor(ccc3(255, 255, 255));
                m_break_label:setColor(ccc3(255, 255, 255));
            else
                m_break_icon:setColor(ccc3(81, 81, 81));
                m_break_label:setColor(ccc3(81, 81, 81));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if self.m_card_cfg_id and self.m_card_bre_value then
                game_scene:addPop("hero_breakthrough_detail_pop",{cardCfgId = self.m_card_cfg_id,breValue = self.m_card_bre_value,selBreValue = index+1})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    return TableViewHelper:create(params);
end

function game_hero_info_pop.refreshBreakTable(self, maxBreak,currentBreak)
    local m_bre_list_view_bg = self.m_ccbNodeItem:spriteForName("m_bre_list_view_bg")
    m_bre_list_view_bg:removeAllChildrenWithCleanup(true)
    local tempTableView = self:createBreakTable(m_bre_list_view_bg:getContentSize(), maxBreak,currentBreak)
    m_bre_list_view_bg:addChild(tempTableView)
end
--[[--
    刷新ui
    ["train","user"]
]]
function game_hero_info_pop.cardDetail(self)
        self.m_lock_btn:setVisible(true);
        -- self.m_lock_btn:setVisible(false);
        local cardData = self.m_tGameData;
        -- cclog(json.encode(cardData))
        self.m_lockFlag = game_util:getCardUserLockFlag(cardData);
        self:refresLockBtn();
        local c_id = cardData.c_id
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id));
        
        -- self.m_level_label:setString(cardData.lv .. "/" .. cardData.level_max);
        self.m_level_label:setString(cardData.lv);

        local name_after = game_util:getCardName(cardData,heroCfg)
        self.m_name_label:setString(name_after);
        game_util:setHeroNameColorByQuality(self.m_name_label,heroCfg);
        local race_cfg = getConfig(game_config_field.race);
        local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
        if race_item_cfg then
            self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
        else
            self.m_race_label:setString(string_helper.game_hero_info_pop.noRace);
        end
        self.m_life_label:setString(tostring(cardData.hp));
        self.m_physical_atk_label:setString(tostring(cardData.patk));
        self.m_magic_atk_label:setString(tostring(cardData.matk));
        self.m_def_label:setString(tostring(cardData.def));
        self.m_speed_label:setString(tostring(cardData.speed));

        local character_base_cfg = getConfig(game_config_field.character_base);
        local character_base_item = character_base_cfg:getNodeWithKey(tostring(cardData.lv));
        local character_base_rate_cfg = getConfig(game_config_field.character_base_rate);
        local character_base_rate_item = character_base_rate_cfg:getNodeWithKey(heroCfg:getNodeWithKey("type"):toStr());
        local exp_rate = character_base_rate_item:getNodeWithKey("exp_rate"):toFloat();
        local maxExp = math.floor(character_base_item:getNodeWithKey("exp"):toInt() * exp_rate)
        local bar_size = self.m_bar_bg:getContentSize();
        local bar = ExtProgressTime:createWithFrameName("o_public_jingyan_1.png","o_public_jingyan.png");
        bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,12));
        self.m_bar_bg:addChild(bar,10,10);
        bar:setMaxValue(maxExp);
        bar:setCurValue(cardData.exp,false);

        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = game_util:createAnimSequence(ainmFile,0,cardData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
            self.m_anim_node:addChild(animNode);
        end
        local occupation_cfg = getConfig(game_config_field.occupation);
        local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
        if occupation_item_cfg then
            local occupationType = occupation_item_cfg:toInt();
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
            if spriteFrame then
                self.m_occupation_icon:setDisplayFrame(spriteFrame);
            end
        end
        local skill_detail_cfg = getConfig("skill_detail");
        local skillJsonData = nil;
        local skillItem = nil;
        for i=1,3 do
            skillItem = cardData["s_" .. i];
            if skillItem and skillItem.s ~= 0 then
                local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
                skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                if skillJsonData then
                    self.m_currentSkillTable[i] = skillItem;
                    game_util:setSkillInfo(skillItem,skillJsonData,skill_icon_spr_bg,2);
                    local is_evolution = skillJsonData:getNodeWithKey("is_evolution"):toStr();
                    local skillEvoCfg = skill_detail_cfg:getNodeWithKey(is_evolution)
                    if skillEvoCfg then
                        local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(3+i)
                        local tempData = util.table_copy(skillItem)
                        tempData.s = is_evolution;
                        tempData.avail = 0;
                        game_util:setSkillInfo(tempData,skillEvoCfg,skill_icon_spr_bg);
                        self.m_currentSkillTable[3+i] = tempData;
                    end
                end
            end
        end
        local short_story = heroCfg:getNodeWithKey("short_story")
        if short_story then
            self.m_short_story_label:setString(short_story:toStr());
        end
        self:cardBreakIcon(heroCfg,cardData.bre);
        self:cardChainByCfg(heroCfg,cardData.id);
        local attrValueTab = nil;
        if self.m_openType == 1 or self.m_openType == 2 then
            attrValueTab = game_util:getOwnCardAttrValueByCardId(cardData.id) or {};
        else
            attrValueTab = cardData or {};
        end
        for k,v in pairs(COMBAT_ABILITY_TABLE.card) do
            local tempLabel = self.m_ccbNodeItem:labelTTFForName("m_" .. v .. "_label");
            if tempLabel then
                tempLabel:setString(tostring(attrValueTab[v]))
            end
        end
end

function game_hero_info_pop.ownCardDetail(self)
    self.m_func_btn_node:setVisible(true);
    self:cardDetail();

    local cardData = self.m_tGameData;
    local c_id = cardData.c_id
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id));
    local quality = heroCfg:getNodeWithKey("quality"):toInt();

    local showImgIndex = 0;
    local evolution_flag = cardData.evolution_flag or 0
    local is_evolution = cardData.is_evolution or 0;
    if is_evolution == 1 and quality >= 3 then
        if evolution_flag == 1 then--完美
            showImgIndex = 1;
            self.m_img_1:setVisible(true);
            self.m_img_1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_perfect2.png"));
        elseif evolution_flag == 2 then--超完美
            showImgIndex = 1;
            self.m_img_1:setVisible(true);
            self.m_img_1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_perfect2.png"));--public_superPerfect2.png
        end
    end
    if game_data:heroInTeamById(cardData.id) then
        if showImgIndex == 0 then
            self.m_img_1:setVisible(true);
            self.m_img_1:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_fight2.png"));
        elseif showImgIndex == 1 then
            self.m_img_2:setVisible(true);
            self.m_img_2:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_fight2.png"));
        end
    end
end

--[[--
    刷新ui   卡牌等级变化
]]  
function game_hero_info_pop.cardChangedDetail(self)
    self.m_lock_btn:setVisible(false);
    cclog("cardChangedDetail ---------------------")
    -- cclog("self.m_heroDataBackup : " .. json.encode(self.m_heroDataBackup))
    -- cclog("self.m_tGameData : " .. json.encode(self.m_tGameData))
    local exp = self.m_heroDataBackup.exp; 
    local lv = self.m_heroDataBackup.lv;
    local hp = self.m_heroDataBackup.hp;
    local patk = self.m_heroDataBackup.patk;
    local matk = self.m_heroDataBackup.matk;
    local def = self.m_heroDataBackup.def;
    local speed = self.m_heroDataBackup.speed;
    -- self.m_level_label:setString(tostring(lv)  .. "/" .. self.m_heroDataBackup.level_max);
    self.m_level_label:setString(tostring(lv));

    if hp == self.m_tGameData.hp then
        self.m_life_label:setString(tostring(self.m_tGameData.hp));
    else
        self.m_life_label:setString(tostring(hp .. "->" .. self.m_tGameData.hp));
    end
    if patk == self.m_tGameData.patk then
        self.m_physical_atk_label:setString(tostring(self.m_tGameData.patk));
    else
        self.m_physical_atk_label:setString(tostring(patk .. "->" .. self.m_tGameData.patk));
    end
    if matk == self.m_tGameData.matk then
        self.m_magic_atk_label:setString(tostring(self.m_tGameData.matk));
    else
        self.m_magic_atk_label:setString(tostring(matk .. "->" .. self.m_tGameData.matk));
    end
    if def == self.m_tGameData.def then
        self.m_def_label:setString(tostring(self.m_tGameData.def));
    else
        self.m_def_label:setString(tostring(def .. "->" .. self.m_tGameData.def));
    end
    if speed == self.m_tGameData.speed then
        self.m_speed_label:setString(tostring(self.m_tGameData.speed));
    else
        self.m_speed_label:setString(tostring(speed .. "->" .. self.m_tGameData.speed));
    end

    exp = self.m_tGameData.exp - exp
    local new_lv = self.m_tGameData.lv
    local add_lv = new_lv - lv;
    hp = self.m_tGameData.hp - hp;
    patk = self.m_tGameData.patk - patk;
    matk = self.m_tGameData.matk - matk;
    def = self.m_tGameData.def - def;
    speed = self.m_tGameData.speed - speed;
    local changdeColor = ccc3(0,230,13)
    if exp > 0 then
        -- m_exp_label:setColor(changdeColor);
    end
    if add_lv > 0 then
        self.m_level_label:setColor(changdeColor);
    end
    if hp > 0 then
        self.m_life_label:setColor(changdeColor);
    end
    if patk > 0 then
        self.m_physical_atk_label:setColor(changdeColor);
    end
    if matk > 0 then
        self.m_magic_atk_label:setColor(changdeColor);
    end
    if def > 0 then
        self.m_def_label:setColor(changdeColor);
    end
    if speed > 0 then
        self.m_speed_label:setColor(changdeColor);
    end

    local c_id = self.m_tGameData.c_id
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(c_id));
    self.m_name_label:setString(heroCfg:getNodeWithKey("name"):toStr());
     game_util:setHeroNameColorByQuality(self.m_name_label,heroCfg);
    local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
    local animNode = game_util:createPauseAnim(ainmFile,0,self.m_tGameData,heroCfg);
    animNode:setAnchorPoint(ccp(0.5,0));
    self.m_anim_node:addChild(animNode);
    local occupation_cfg = getConfig(game_config_field.occupation);
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt();
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
        if spriteFrame then
            self.m_occupation_icon:setDisplayFrame(spriteFrame);
        end
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local bar_size = self.m_bar_bg:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("o_public_jingyan_1.png","o_public_jingyan.png");
    bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,12));
    self.m_bar_bg:addChild(bar,10,10);
    local race_cfg = getConfig(game_config_field.race);
    local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
    if race_item_cfg then
        self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
    else
        self.m_race_label:setString(string_helper.game_hero_info_pop.none);
    end
    local character_base_cfg = getConfig(game_config_field.character_base);
    local character_base_rate_cfg = getConfig(game_config_field.character_base_rate);
    local character_base_rate_item = character_base_rate_cfg:getNodeWithKey(heroCfg:getNodeWithKey("type"):toStr());
    local exp_rate = character_base_rate_item:getNodeWithKey("exp_rate"):toFloat();
    local character_base_item = nil;
    local maxExp = 100;
    local exp = self.m_heroDataBackup.exp;
    local new_exp = self.m_tGameData.exp;
    cclog("exp ==================" .. exp .. "; new_exp ==============" .. new_exp);
    if add_lv == 0 then
        character_base_item = character_base_cfg:getNodeWithKey(tostring(lv));
        maxExp = math.floor(character_base_item:getNodeWithKey("exp"):toInt() * exp_rate)
        bar:setMaxValue(maxExp);
        bar:setCurValue(exp,false);
        bar:setCurValue(new_exp,true);
        cclog("maxExp ====" .. maxExp .. " ; exp ==" .. exp .. " ; lv == " .. lv);
    elseif add_lv > 0 then
        local showStep = 0;
        bar:registerScriptBarHandler(function(extBar)
            cclog("anim end ----------------------------") 
            if showStep == add_lv then
                showStep = showStep + 1;
                -- self.m_level_label:setString(tostring(new_lv)  .. "/" .. self.m_heroDataBackup.level_max);
                self.m_level_label:setString(tostring(new_lv));
                character_base_item = character_base_cfg:getNodeWithKey(tostring(lv + showStep));
                maxExp = math.floor(character_base_item:getNodeWithKey("exp"):toInt() * exp_rate)
                bar:setMaxValue(maxExp);
                bar:setCurValue(0,false);
                bar:setCurValue(new_exp,true);
                cclog("maxExp ==3==" .. maxExp .. " ; lv == " .. (lv + showStep));
            elseif showStep < add_lv then
                showStep = showStep + 1;
                -- self.m_level_label:setString(tostring(lv + showStep)  .. "/" .. self.m_heroDataBackup.level_max);
                self.m_level_label:setString(tostring(lv + showStep));
                character_base_item = character_base_cfg:getNodeWithKey(tostring(lv + showStep));
                maxExp = math.floor(character_base_item:getNodeWithKey("exp"):toInt() * exp_rate)
                bar:setMaxValue(maxExp);
                bar:setCurValue(0,false);
                bar:setCurValue(maxExp,true);
                cclog("maxExp ==2==" .. maxExp .. " ; lv == " .. (lv + showStep)); 
            end
        end);
        character_base_item = character_base_cfg:getNodeWithKey(tostring(lv + showStep));
        maxExp = math.floor(character_base_item:getNodeWithKey("exp"):toInt() * exp_rate)
        bar:setMaxValue(maxExp);
        bar:setCurValue(exp,false);
        bar:setCurValue(maxExp,true);
        cclog("maxExp ==1==" .. maxExp .. " ; lv == " .. (lv + showStep));
        showStep = showStep + 1;
    end

    local skill_detail_cfg = getConfig("skill_detail");
    local skillJsonData = nil;
    local skillItem = nil;
    for i=1,3 do
        skillItem = self.m_tGameData["s_" .. i];
        if skillItem and skillItem.s ~= 0 then
            local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
            local skill_bottom_node = self.m_skill_layer:getChildByTag(3+i)
            skillJsonData = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
            if skillJsonData then
                self.m_currentSkillTable[i] = skillItem;
                game_util:setSkillInfo(skillItem,skillJsonData,skill_icon_spr_bg,skill_bottom_node,2);
                local is_evolution = skillJsonData:getNodeWithKey("is_evolution"):toStr();
                local skillEvoCfg = skill_detail_cfg:getNodeWithKey(is_evolution)
                if skillEvoCfg then
                    local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(3+i)
                    local tempData = util.table_copy(skillItem)
                    tempData.s = is_evolution;
                    tempData.avail = 0;
                    game_util:setSkillInfo(tempData,skillEvoCfg,skill_icon_spr_bg);
                    self.m_currentSkillTable[3+i] = tempData;
                end
            end
        end
    end
    local short_story = heroCfg:getNodeWithKey("short_story")
    if short_story then
        self.m_short_story_label:setString(short_story:toStr());
    end
    self:cardBreakIcon(heroCfg,self.m_tGameData.bre);
    self:cardChainByCfg(heroCfg,self.m_tGameData.id);
    for k,v in pairs(COMBAT_ABILITY_TABLE.card) do
        local tempLabel = self.m_ccbNodeItem:labelTTFForName("m_" .. v .. "_label");
        local value1 = self.m_heroDataBackup[v] or 0
        local value2 = self.m_tGameData[v] or 0
        if tempLabel then
            if value1 == value2 then
                tempLabel:setString(tostring(value2));
            else
                tempLabel:setString(tostring(value1 .. "->" .. value2));
            end
            if value2 - value1 > 0 then
                tempLabel:setColor(changdeColor);
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_hero_info_pop.lookOthersCardDetail(self)
    self:cardDetail();
    self.m_lock_btn:setVisible(false);
end

--[[--
    刷新ui
]]
function game_hero_info_pop.refresLockBtn(self)
    if self.m_lockFlag == true then
        -- game_util:setCCControlButtonBackground(self.m_lock_btn,"public_btnLock2.png")
        game_util:setCCControlButtonTitle(self.m_lock_btn,string_config.m_unlock_str)
    else
        -- game_util:setCCControlButtonBackground(self.m_lock_btn,"public_btnUnlock.png")
        game_util:setCCControlButtonTitle(self.m_lock_btn,string_config.m_lock_str)
    end
end

local OpenButtonTable = {
    btn1 = {name = "技能升级", InReviewID = 18, openBtnId = 503, openFlag = true, btnIndex = 1 },
    btn2 = {name = "伙伴进阶", InReviewID = 19, openBtnId = 502, openFlag = true, btnIndex = 2 },
    btn3 = {name = "能晶改造", InReviewID = 20, openBtnId = 509, openFlag = true, btnIndex = 3 },
    btn4 = {name = "伙伴传承", InReviewID = 33, openBtnId = 506, openFlag = true, btnIndex = 4 },
    btn5 = {name = "伙伴重生", InReviewID = 128, openBtnId = 117, openFlag = true, btnIndex = 5 },
}

local TablePosX = {
    {0.5},
    {0.35, 0.65},
    {0.2, 0.5, 0.8},
    {0.2, 0.4, 0.6, 0.8},
    {0.1, 0.3, 0.5, 0.7, 0.9}
}
--[[
    刷新ui：显示按钮 进阶 重生 技能升级 能晶改造
]]
function game_hero_info_pop.refreshFunBtnState( self )
    -- assert()
    local showBtns = {}
    local len = game_util:getTableLen(OpenButtonTable)
    for i=1, len do
        local curState = OpenButtonTable["btn" .. i] or {}
        -- cclog2(curState, "判断按钮显示状态 id == " .. i)
        local btn = self.m_funBtns["btn" .. tostring(curState.btnIndex) ]
        if btn and game_data:isViewOpenByID( curState.InReviewID ) then
            table.insert(showBtns, curState)
            btn:setVisible(true)
        elseif btn then
            btn:setVisible(false)
        end
    end
    local posx = TablePosX[#showBtns] 
    local tempSize = self.m_func_btn_node:getContentSize()
    for i,v in ipairs(showBtns) do
        local btn = self.m_funBtns["btn" .. tostring(v.btnIndex) ]
        if btn then
            btn:setPositionX(tempSize.width * posx[i])
            game_button_open:setButtonShow(btn, v.openBtnId, 1);
        end
    end
end

--[[--
    刷新ui
]]
function game_hero_info_pop.lookCardDetailByConfigId(self)
    self.m_lock_btn:setVisible(false);
    if self.m_cId ~= nil then
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(self.m_cId));
        if heroCfg == nil then return end

        -- self.m_level_label:setString("0/" .. heroCfg:getNodeWithKey("level_max"):toStr());
        self.m_level_label:setString("0");
        self.m_name_label:setString(heroCfg:getNodeWithKey("name"):toStr());
        game_util:setHeroNameColorByQuality(self.m_name_label,heroCfg);
        local race_cfg = getConfig(game_config_field.race);
        local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
        if race_item_cfg then
            self.m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
        else
            self.m_race_label:setString(string_helper.game_hero_info_pop.noRace);
        end
        local base_hp,base_patk,base_matk,base_def,base_speed;
        base_hp = heroCfg:getNodeWithKey("base_hp"):toInt();
        base_patk = heroCfg:getNodeWithKey("base_patk"):toInt();
        base_matk = heroCfg:getNodeWithKey("base_matk"):toInt();
        base_def = heroCfg:getNodeWithKey("base_def"):toInt();
        base_speed = heroCfg:getNodeWithKey("base_speed"):toInt();

        self.m_life_label:setString(base_hp);
        self.m_physical_atk_label:setString(base_patk);
        self.m_magic_atk_label:setString(base_matk);
        self.m_def_label:setString(base_def);
        self.m_speed_label:setString(base_speed);

        local bar_size = self.m_bar_bg:getContentSize();
        local bar = ExtProgressTime:createWithFrameName("o_public_jingyan_1.png","o_public_jingyan.png");
        bar:addLabelTTF(CCLabelTTF:create("0/100",TYPE_FACE_TABLE.Arial_BoldMT,12));
        self.m_bar_bg:addChild(bar,10,10);
        bar:setMaxValue(100);
        bar:setCurValue(0,false);
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = nil
        if self.m_lllustrationsOpenFlag == true then
            animNode = game_util:createAnimSequence(ainmFile,0,cardData,heroCfg);
        else
            animNode = game_util:createUnknowIdelAnim()
        end
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
            self.m_anim_node:addChild(animNode);
        end
        local occupation_cfg = getConfig(game_config_field.occupation);
        local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
        if occupation_item_cfg then
            local occupationType = occupation_item_cfg:toInt();
            local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
            if spriteFrame then
                self.m_occupation_icon:setDisplayFrame(spriteFrame);
            end
        end
        local skill_detail_cfg = getConfig("skill_detail");
        local skillItemData = nil;
        local skillItem = nil;
        local skill_source = nil;
        local skill_source_count = nil;
        for i=1,3 do
            skill_source = heroCfg:getNodeWithKey("skill_" .. i .. "_source");
            skill_source_count = skill_source:getNodeCount();
            if skill_source_count > 0 then
                skillItem = {avail = 0,lv = 1,exp = 0,s = skill_source:getNodeAt(0):getNodeAt(0):toInt()}
                local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
                skillItemData = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                if skillItemData then
                    self.m_currentSkillTable[i] = skillItem;
                    game_util:setSkillInfo(skillItem,skillItemData,skill_icon_spr_bg,2);
                    local is_evolution = skillItemData:getNodeWithKey("is_evolution"):toStr();
                    local skillEvoCfg = skill_detail_cfg:getNodeWithKey(is_evolution)
                    if skillEvoCfg then
                        local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(3+i)
                        local tempData = util.table_copy(skillItem)
                        tempData.s = is_evolution;
                        game_util:setSkillInfo(tempData,skillEvoCfg,skill_icon_spr_bg);
                        self.m_currentSkillTable[3+i] = tempData;
                    end
                end
            end
        end
        local short_story = heroCfg:getNodeWithKey("short_story")
        if short_story then
            self.m_short_story_label:setString(short_story:toStr());
        end
        self:cardBreakIcon(heroCfg,0);
        self:cardChainByCfg(heroCfg);
        for k,v in pairs(COMBAT_ABILITY_TABLE.card) do
            local tempLabel = self.m_ccbNodeItem:labelTTFForName("m_" .. v .. "_label");
            if tempLabel then
                tempLabel:setString("0")
            end
        end
    end
end


--[[--
    刷新ui
]]
function game_hero_info_pop.refreshUi(self)
    if self.m_openType == 1 or (self.m_openType == 2 and self.m_heroDataBackup == nil) then
        self:ownCardDetail();
    elseif self.m_openType == 2 then
        self:cardChangedDetail();
    elseif self.m_openType == 3 then
        self:lookOthersCardDetail();
    elseif self.m_openType == 4 then
        self:lookCardDetailByConfigId();
    end
    self:refresLockBtn();
    self:refreshFunBtnState()
end

--[[--
    初始化
]]
function game_hero_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = t_params.tGameData;
    self.m_heroDataBackup = t_params.heroDataBackup;
    self.m_openType = t_params.openType or 1;
    self.m_currentSkillTable = {};
    self.m_callBack = t_params.callBack;
    self.m_lockFlag = false;
    self.m_lockChangedFlag = false;
    self.m_cId = t_params.cId;
    self.m_lllustrationsOpenFlag = t_params.lllustrationsOpenFlag == nil and true or t_params.lllustrationsOpenFlag
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_info_pop.create(self,t_params)
    self:init(t_params);
    if self.m_openType ~= 4 then
        if self.m_tGameData == nil then return end
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    self.m_popUi = self:createUi();
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    if id == 16 then
        game_guide_controller:gameGuide("show","1",17,{tempNode = self.m_close_btn})
    end
    return self.m_popUi;
end

return game_hero_info_pop;