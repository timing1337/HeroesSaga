---  宝石合成

local gem_system_synthesis = {
    m_touch_layer = nil,
    m_material_node = nil,
    m_material_node_tab = nil,
    m_list_view_bg = nil,
    m_selListItem = nil,
    m_selSortIndex = nil,
    m_ccbNode = nil,
    m_selPosIndex = nil,
    m_tGameData = nil,
    m_root_layer = nil,
    m_tGameDataBackup = nil,
    m_animCount = nil,
    m_ok_btn = nil,
    m_level_label = nil,
    buy_cmdr_times = nil,
    m_sel_img = nil,
    m_show_icon_node = nil,
    m_rob_log = nil,
    m_showSortIdTab = nil,
    m_selSortId = nil,
    cmdr_energy_rate = nil,
    cmdr_energy_update_left = nil,
    m_animFlag = nil,
    m_guildNode = nil,
    m_title_spri = nil,
    m_exp_and_level_node = nil,
    m_quality_label_1 = nil,
    m_quality_label_2 = nil,
    m_attr_label_1 = nil,
    m_attr_label_2 = nil,
    m_attr_icon = nil,
    m_needMetal = nil,
    m_ownGemTab = nil,
    m_item_icon_node = nil,
    m_needIconSprite = nil,
    m_gemTeamCountTab = nil,
    m_gem_list_view_bg = nil,
    m_selListItem2 = nil,
    m_tableView = nil,
    m_tableView2= nil,
};
--[[--
    销毁ui
]]
function gem_system_synthesis.destroy(self)
    -- body
    cclog("-----------------gem_system_synthesis destroy-----------------");
    self.m_touch_layer = nil;
    self.m_material_node = nil;
    self.m_material_node_tab = nil;
    self.m_list_view_bg = nil;
    self.m_selListItem = nil;
    self.m_selSortIndex = nil;
    self.m_ccbNode = nil;
    self.m_selPosIndex = nil;
    self.m_tGameData = nil;
    self.m_root_layer = nil;
    self.m_tGameDataBackup = nil;
    self.m_animCount = nil;
    self.m_ok_btn = nil;
    self.m_level_label = nil;
    self.buy_cmdr_times = nil;
    self.m_sel_img = nil;
    self.m_show_icon_node = nil;
    self.m_rob_log = nil;
    self.m_showSortIdTab = nil;
    self.m_selSortId = nil;
    self.cmdr_energy_rate = nil;
    self.cmdr_energy_update_left = nil;
    self.m_animFlag = nil;
    self.m_guildNode = nil;
    self.m_title_spri = nil;
    self.m_exp_and_level_node = nil;
    self.m_quality_label_1 = nil;
    self.m_quality_label_2 = nil;
    self.m_attr_label_1 = nil;
    self.m_attr_label_2 = nil;
    self.m_attr_icon = nil;
    self.m_needMetal = nil;
    self.m_ownGemTab = nil;
    self.m_item_icon_node = nil;
    self.m_needIconSprite = nil;
    self.m_gemTeamCountTab = nil;
    self.m_gem_list_view_bg = nil;
    self.m_selListItem2 = nil;
    self.m_tableView = nil;
    self.m_tableView2= nil;
end

local ability_commander_pos_tab = {
                                    count1 = {{50.0,90.0}},
                                    count2 = {{50.0,90.0},{50.0,10.0}},
                                    count3 = {{50.0,90.0},{15.0,25.0},{85.0,25.0}},
                                    count4 = {{15.0,75.0},{15.0,25.0},{85.0,25.0},{85.0,75.0}},
                                    count5 = {{50.0,90.0},{10.0,60.0},{25.0,15.0},{75.0,15.0},{85.0,60.0}},
                                    }


--[[--
    返回
]]
function gem_system_synthesis.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function gem_system_synthesis.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--合成
            game_scene:removeGuidePop();
            local itemData = self.m_tGameData[self.m_selSortId] or {}
            local tempItemData = itemData[self.m_selSortIndex];
            if tempItemData == nil then return end;
            local gemCfgId = tempItemData.key;
            local gem_cfg = getConfig(game_config_field.gem);
            local itemCfg = gem_cfg:getNodeWithKey(gemCfgId)
            if itemCfg == nil then
                game_util:addMoveTips({text = string_helper.gem_system_synthesis.config_error});
                return;
            end
            local gem_num = itemCfg:getNodeWithKey("gem_num"):toInt();
            local need_gem = itemCfg:getNodeWithKey("need_gem"):toStr();
            local tempOwnCount,_ = game_data:getGemDataById(need_gem);
            tempOwnCount = tempOwnCount or 0
            if tempItemData.synthesisFlag == false then
                game_util:addMoveTips({text = string_helper.gem_system_synthesis.gem_nf});
                return;
            end
            if tempOwnCount < gem_num then
                game_util:addMoveTips({text = string_helper.gem_system_synthesis.gem_nc});
                return;
            end


            local need_item = itemCfg:getNodeWithKey("need_item");
            local need_item_item = need_item:getNodeAt(0)
            if need_item_item then
                local need_item_id = need_item_item:getNodeAt(1):toInt()
                local need_item_count = need_item_item:getNodeAt(2):toInt() -- 需要的灵魂精华
                local own_item_count = game_data:getItemCountByCid(need_item_id) -- 已有的灵魂精华
                if need_item_count > own_item_count then
                    game_util:addMoveTips({text = string_helper.gem_system_synthesis.prop_nc});
                    return;
                end
            end
            self:gemSynthesisReq(gemCfgId,1);
        elseif btnTag == 102 then--一键合成
            local itemData = self.m_tGameData[self.m_selSortId] or {}
            local tempItemData = itemData[self.m_selSortIndex];
            if tempItemData == nil then return end;
            local gemCfgId = tempItemData.key;
            local gem_cfg = getConfig(game_config_field.gem);
            local itemCfg = gem_cfg:getNodeWithKey(gemCfgId)
            if itemCfg == nil then
                game_util:addMoveTips({text = string_helper.gem_system_synthesis.config_error});
                return;
            end
            local gem_num = itemCfg:getNodeWithKey("gem_num"):toInt();
            local need_gem = itemCfg:getNodeWithKey("need_gem"):toStr();
            local gemCount,_ = game_data:getGemDataById(need_gem);
            gemCount = gemCount or 0;
            local t_params = 
            {
                okBtnCallBack = function(count)
                    self:gemSynthesisReq(gemCfgId,count);
                end,
                gemItemId = gemCfgId,
                maxCount = math.floor(gemCount/gem_num),
                alreadyCount = 0,
                times_limit = 1,
                touchPriority = GLOBAL_TOUCH_PRIORITY,
                enterType = "gem_system_synthesis",
            }
            game_scene:addPop("gem_system_synthesis_pop",t_params)
        elseif btnTag == 103 then -- 说明
            game_scene:addPop("game_active_limit_detail_pop",{openType = "gem_system_synthesis"})
        elseif btnTag >= 201 and btnTag <= 205 then--排序
            self.m_animFlag = true;
            self:refreshSortTabBtn(btnTag - 200);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gem_system_synthesis.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")

    self.m_touch_layer = ccbNode:layerForName("m_touch_layer")
    self.m_material_node = ccbNode:nodeForName("m_material_node")
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label")
    self.m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")
    self.m_show_icon_node = ccbNode:nodeForName("m_show_icon_node")
    self.m_title_spri = ccbNode:spriteForName("m_title_spri")
    self.m_quality_label_1 = ccbNode:labelTTFForName("m_quality_label_1")
    self.m_quality_label_2 = ccbNode:labelTTFForName("m_quality_label_2")
    self.m_attr_label_1 = ccbNode:labelTTFForName("m_attr_label_1")
    self.m_attr_label_2 = ccbNode:labelTTFForName("m_attr_label_2")
    self.m_attr_icon = ccbNode:spriteForName("m_attr_icon")
    self.m_item_icon_node = ccbNode:nodeForName("m_item_icon_node")
    self.m_gem_list_view_bg = ccbNode:nodeForName("m_gem_list_view_bg")

    local m_auto_add_btn = ccbNode:controlButtonForName("m_auto_add_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    local m_shuoming_btn = ccbNode:controlButtonForName("m_shuoming_btn")

    self.m_item_icon_node:setScale(0.75)
    local m_material_node,m_mate_tips,m_num_label,parentNode = nil,nil,nil
    for i=1,5 do
        m_material_node = ccbNode:nodeForName("m_material_node_" .. i);
        m_mate_tips = ccbNode:spriteForName("m_mate_tips_" .. i);
        m_num_label = ccbNode:labelBMFontForName("m_num_label_" .. i);
        parentNode = m_material_node:getParent();
        self.m_material_node_tab[i] = {m_material_node = m_material_node,m_mate_tips = m_mate_tips,m_num_label = m_num_label,itemId = -1,count = 0,parentNode = parentNode}
    end

    self:initLayerTouch(self.m_touch_layer);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_ccbNode = ccbNode

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text202)
    game_util:setCCControlButtonTitle(m_shuoming_btn,string_helper.ccb.text203)
    game_util:setCCControlButtonTitle(m_auto_add_btn,string_helper.ccb.text204)
    game_util:setCCControlButtonTitle(m_ok_btn,string_helper.ccb.text205)
    return ccbNode;
end


function gem_system_synthesis.gemSynthesisReq(self,gemCfgId,count)
    count = count or 1;
    local function responseMethod(tag,gameData)
        if gameData == nil then
            self.m_root_layer:setTouchEnabled(false);
            return;
        end
        local data = gameData:getNodeWithKey("data")
        local reward = data:getNodeWithKey("reward")
        local rewardTab = {}
        if reward then
            rewardTab = json.decode(reward:getFormatBuffer())
        end
        local function callBackFunc()
            game_util:rewardTipsByDataTable(rewardTab);
        end
        self:responseSuccess(callBackFunc);
        -- game_util:addMoveTips({text = "合成成功！"});
    end
    self.m_root_layer:setTouchEnabled(true);
    --参数 gem_id=
    local params = {};
    params.gem_id = gemCfgId
    params.gem_num = count
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gem_synthesis"), http_request_method.GET,params,"gem_synthesis",true,true)
end

--[[--
    
]]
function gem_system_synthesis.responseSuccess(self,callBackFunc)
    self.m_animFlag = false;
    game_sound:playUiSound("up_success")
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        self:refreshData();
        self:refreshUi();
        callBackFunc();
    end

    local removeIndex = math.min(self.m_animCount,5)
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        -- cclog("tempParticle particleMoveEndCallFunc --------------------------")
    end
    for i=1,math.min(self.m_animCount,5) do
        local m_material_node = self.m_material_node_tab[i].m_material_node;
        local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
        if mAnimNode then
            local function onAnimSectionEnd(animNode, theId,theLabelName)
                if theLabelName == "impact1" then
                    animNode:playSection("impact2");
                    local tempNode = m_material_node:getChildByTag(10)
                    if tempNode then
                        tempNode:setVisible(false);
                    end
                else
                    mAnimNode:removeFromParentAndCleanup(true);
                    removeIndex = removeIndex - 1;
                    if removeIndex == 0 then
                        responseEndFunc();
                    end
                end
            end
            mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
            mAnimNode:playSection("impact1");
            local tempSize = m_material_node:getContentSize();
            mAnimNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
            m_material_node:addChild(mAnimNode,100,100);
            -- local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up2"});
            -- if tempParticle then
            --     game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_material_node,endNode = self.m_ok_btn,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
            --     game_scene:getPopContainer():addChild(tempParticle)
            -- end
        else
            removeIndex = removeIndex - 1;
            if removeIndex == 0 then
                responseEndFunc();
            end
        end
    end
end

--[[--

]]
function gem_system_synthesis.refreshSortTabBtn(self,sortIndex)
    local tempBtn = nil;
    self.m_selSortIndex = sortIndex
    -- for i=1,5 do
    --     tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
    --     if tempBtn:isVisible() then
    --         tempBtn:setHighlighted(self.m_selSortIndex == i);
    --         tempBtn:setEnabled(self.m_selSortIndex ~= i);
    --         if self.m_selSortIndex == i then
    --             local pX,pY = tempBtn:getPosition();
    --             self.m_sel_img:setPosition(ccp(pX, pY))
    --         end
    --     end
    -- end
    self:refreshCommanderDetail(sortIndex);
    self:refreshInfo();
end

--[[--

]]
function gem_system_synthesis.showSortTabBtn(self,sortIndex)
    -- local itemData = self.m_tGameData[self.m_selSortId]
    -- if itemData == nil then return end;
    -- local tempCount = #itemData;
    -- self.m_show_icon_node:removeAllChildrenWithCleanup(true);
    -- -- cclog("show btn count =========== " .. tempCount)
    -- local gem_cfg = getConfig(game_config_field.gem);
    -- local tempBtn = nil;
    -- for i=1,5 do
    --     tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
    --     if i > tempCount then
    --         tempBtn:setVisible(false)
    --     else
    --         tempBtn:setVisible(true)
    --         -- game_util:setCCControlButtonTitle(tempBtn,tostring(itemData[i].name))
    --         local itemCfg = gem_cfg:getNodeWithKey(tostring(itemData[i].key))
    --         game_util:setCCControlButtonTitle(tempBtn,itemCfg:getNodeWithKey("last_name"):toStr())
    --         local icon = itemCfg:getNodeWithKey("icon")
    --         local pX,pY = tempBtn:getPosition();
    --         if icon then
    --             local tempIcon = game_util:createIconByName(icon:toStr())
    --             if tempIcon then
    --                 tempIcon:setScale(0.8);
    --                 tempIcon:setPosition(ccp(pX, pY))
    --                 self.m_show_icon_node:addChild(tempIcon)
    --             end
    --         end
    --         local quality = itemCfg:getNodeWithKey("quality")
    --         if quality then
    --             quality = quality:toInt();
    --             local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
    --             if qualityTab then
    --                 local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
    --                 img2:setScale(0.8);
    --                 img2:setPosition(ccp(pX, pY));
    --                 self.m_show_icon_node:addChild(img2,2,2)
    --             end
    --         end
    --     end
    -- end
    self:refreshGemTabTableView();
end

--[[--
    
]]
function gem_system_synthesis.initLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        for k,v in pairs(self.m_material_node_tab) do
            realPos = v.parentNode:convertToNodeSpace(ccp(x,y));
            if v.m_material_node:isVisible() and v.m_material_node:boundingBox():containsPoint(realPos) then
                tag = v.m_material_node:getTag();
                local itemData = self.m_tGameData[self.m_selSortId] or {}
                local tempItemData = itemData[self.m_selSortIndex];
                if tempItemData == nil then return end;
                local gemCfgId = tempItemData.key;
                local gem_cfg = getConfig(game_config_field.gem);
                local itemCfg = gem_cfg:getNodeWithKey(gemCfgId)
                if itemCfg == nil then
                    game_util:addMoveTips({text = string_helper.gem_system_synthesis.config_error});
                    return;
                end
                local need_gem = itemCfg:getNodeWithKey("need_gem"):toStr();
                local itemData,itemCfg = game_data:getGemDataById(need_gem);
                game_scene:addPop("gem_system_info_pop",{tGameData = {count = itemData or 0,c_id = need_gem},callBack = nil, openType=3});
                break;
            end
        end
        if self.m_needIconSprite then
            realPos = self.m_needIconSprite:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_needIconSprite:isVisible() and self.m_needIconSprite:boundingBox():containsPoint(realPos) then
                local itemData = self.m_tGameData[self.m_selSortId] or {}
                local tempItemData = itemData[self.m_selSortIndex];
                if tempItemData == nil then return end;
                local gemCfgId = tempItemData.key;
                local gem_cfg = getConfig(game_config_field.gem);
                local itemCfg = gem_cfg:getNodeWithKey(gemCfgId)
                if itemCfg == nil then
                    game_util:addMoveTips({text = string_helper.gem_system_synthesis.config_error});
                    return;
                end
                local need_item = itemCfg:getNodeWithKey("need_item");
                local need_item_item = need_item:getNodeAt(0)
                if need_item_item then
                    local itemTable = json.decode(need_item_item:getFormatBuffer())
                    local typeValue = itemTable[1]
                    if typeValue == 6 then
                        game_util:lookItemDetal(itemTable)
                    end
                end
            end
        end
        realPos = nil;
        tempItem = nil;
        tag = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end


--[[--
    创建列表
]]
function gem_system_synthesis.createTableView(self,viewSize)
    local gem_cfg = getConfig(game_config_field.gem);
    self.m_selListItem = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = #self.m_showSortIdTab
    params.showPageIndex = self.m_curPage;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_item_commander_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempSortId = self.m_showSortIdTab[index + 1]
            local itemData = self.m_tGameData[tempSortId]

            local itemCfg = gem_cfg:getNodeWithKey(tostring(itemData[1].key))
            cclog("tempSortId ==================== " .. tempSortId .. " ; itemCfg == " .. tostring(itemCfg))
            local m_type_icon = ccbNode:spriteForName("m_type_icon")
            local m_stroy_img = ccbNode:spriteForName("m_stroy_img")
            local m_attr_icon = ccbNode:spriteForName("m_attr_icon")
            local m_stroy_label = ccbNode:labelTTFForName("m_stroy_label")
            m_stroy_label:setVisible(true);
            m_type_icon:setScale(0.75);
            m_stroy_img:setVisible(false);
            local m_attr_label = ccbNode:labelTTFForName("m_attr_label")
            if itemCfg then
                -- local item_image = itemCfg:getNodeWithKey("item_image"):toStr()
                -- local itemIcon = game_util:createIconByName(item_image);
                -- if itemIcon then
                --     m_type_icon:setScale(0.75);
                --     m_type_icon:setDisplayFrame(itemIcon:displayFrame());
                -- end
                -- local iconName = itemCfg:getNodeWithKey("image"):toStr();
                -- local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(iconName .. ".png")
                -- if tempSpriteFrame then
                --     m_stroy_img:setDisplayFrame(tempSpriteFrame);
                -- end

                local icon = itemCfg:getNodeWithKey("icon")
                local tempIcon = game_util:createIconByName(icon:toStr())
                if tempIcon then
                    m_type_icon:setDisplayFrame(tempIcon:displayFrame());
                end
                local team = itemCfg:getNodeWithKey("team"):toInt();
                local tempCount = self.m_gemTeamCountTab[team] or 0
                -- for k,v in pairs(itemData) do
                --     local count = self.m_ownGemTab[v.key] or 0
                --     tempCount = tempCount + count;
                -- end
                m_attr_label:setString(tempCount)
                local name = itemCfg:getNodeWithKey("first_name"):toStr()
                m_stroy_label:setString(name);
            else
                m_attr_label:setString("0")
            end
            local m_sel_node = ccbNode:nodeForName("m_sel_node");
            if self.m_selSortId == tempSortId then
                self.m_selListItem = cell;
                m_sel_node:setVisible(true);
            else
                m_sel_node:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if eventType == "ended" and cell then
            if self.m_selListItem then
                local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                local m_sel_node = ccbNode:nodeForName("m_sel_node");
                m_sel_node:setVisible(false);
            end
            self.m_selPosIndex = index + 1
            self.m_selSortId = self.m_showSortIdTab[index + 1]
            self.m_selListItem = cell;
            local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
            local m_sel_node = ccbNode:nodeForName("m_sel_node");
            m_sel_node:setVisible(true);
            self.m_animFlag = true;
            self.m_selSortIndex = 1;
            self:showSortTabBtn(self.m_selPosIndex);
            self:refreshSortTabBtn(self.m_selSortIndex);
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
function gem_system_synthesis.refreshTableView(self)
    local pX,pY = nil,nil
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_tableView:setScrollBarVisible(false)
    -- self.m_tableView:setMoveFlag(false)
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY),false)
    end
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    创建列表
]]
function gem_system_synthesis.createGemTabTableView(self,viewSize)
    local itemData = self.m_tGameData[self.m_selSortId]
    if itemData == nil then return end;
    local showCount = #itemData;
    local gem_cfg = getConfig(game_config_field.gem);
    self.m_selListItem2 = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 5; --列
    params.totalItem = showCount;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_gem_system_synthesis_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node = ccbNode:nodeForName("m_node")
            local m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            m_node:removeAllChildrenWithCleanup(true);

            local itemCfg = gem_cfg:getNodeWithKey(tostring(itemData[index+1].key))
            m_name_label:setString(itemCfg:getNodeWithKey("last_name"):toStr());
            local icon = itemCfg:getNodeWithKey("icon")
            if icon then
                local tempIcon = game_util:createIconByName(icon:toStr())
                if tempIcon then
                    tempIcon:setScale(0.8);
                    m_node:addChild(tempIcon)
                end
            end
            local quality = itemCfg:getNodeWithKey("quality")
            if quality then
                quality = quality:toInt();
                local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
                if qualityTab then
                    local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
                    img2:setScale(0.8);
                    m_node:addChild(img2,2,2)
                end
            end
            if self.m_selSortIndex == index + 1 then
                self.m_selListItem2 = cell;
                m_sel_img:setVisible(true);
            else
                m_sel_img:setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if eventType == "ended" and cell then
            if self.m_selListItem2 then
                local ccbNode = tolua.cast(self.m_selListItem2:getChildByTag(10),"luaCCBNode");
                local m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")
                m_sel_img:setVisible(false);
            end
            self.m_selListItem2 = cell;
            local ccbNode = tolua.cast(self.m_selListItem2:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")
            m_sel_img:setVisible(true);
            self.m_animFlag = true;
            self:refreshSortTabBtn(index+1);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function gem_system_synthesis.refreshGemTabTableView(self)
    local pX,pY = nil,nil
    if self.m_tableView2 then
        pX,pY = self.m_tableView2:getContainer():getPosition();
    end
    self.m_gem_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = self:createGemTabTableView(self.m_gem_list_view_bg:getContentSize());
    if pX and pY then
        self.m_tableView2:setContentOffset(ccp(pX,pY),false)
    end
    self.m_gem_list_view_bg:addChild(self.m_tableView2);
end

--[[--
    刷新
]]
function gem_system_synthesis.refreshCommanderDetail(self,sortIndex)
    local gem_cfg = getConfig(game_config_field.gem);
    self.m_animCount = 0;
    self.m_needMetal = 0;
    self.m_needIconSprite = nil;
    local sortItemData = self.m_tGameData[self.m_selSortId] or {};
    local tempItemData = sortItemData[sortIndex];
    if tempItemData then
        local gemCfgId = tempItemData.key;
        -- cclog("sel gemCfgId ======================= " .. gemCfgId)
        local tempItemCfg = gem_cfg:getNodeWithKey(tostring(gemCfgId))
        local tempQuality = tempItemCfg:getNodeWithKey("quality"):toInt()
        self.m_needMetal = tempItemCfg:getNodeWithKey("iron"):toInt();
        local need_item = tempItemCfg:getNodeWithKey("need_item");
        
        if need_item:getNodeCount() > 0 then
            self.m_item_icon_node:setVisible(true)
            local need_item_item = need_item:getNodeAt(0)
            local need_item_id = need_item_item:getNodeAt(1):toInt()
            local tempIcon = game_util:createItemIconByCid(need_item_id)
            if tempIcon then
                self.m_needIconSprite = tempIcon;
                local need_item_count = need_item_item:getNodeAt(2):toInt() -- 需要的灵魂精华
                local own_item_count = game_data:getItemCountByCid(need_item_id) -- 已有的灵魂精华
                if need_item_count > own_item_count then
                    tempIcon:setColor(ccc3(81,81,81))
                end
                self.m_item_icon_node:addChild(tempIcon)
            end
        else
            self.m_item_icon_node:setVisible(false)
        end
        local part = tempItemData.part
        local partCount = #part
        local tempPosTab = ability_commander_pos_tab["count" .. partCount]
        self.m_animCount = partCount
        local tempCount = self.m_ownGemTab[gemCfgId] or 0
        -- cclog("partCount ===================== " .. partCount)
        local material_node_size = self.m_material_node:getContentSize();
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:removeAllChildrenWithCleanup(true);
            if i > partCount then
                itemTab.m_material_node:setVisible(false)
                itemTab.m_mate_tips:setVisible(false)
                itemTab.itemId = -1
                itemTab.count = 0
            else
                itemTab.m_material_node:setVisible(true)
                itemTab.m_mate_tips:setVisible(true)
                itemTab.m_mate_tips:setOpacity(0)
                local itemId = tostring(part[i][1])
                local itemCount = part[i][2]

                local itemCfg = gem_cfg:getNodeWithKey(itemId)
                local icon = itemCfg:getNodeWithKey("icon")
                local tempIcon = game_util:createIconByName(icon:toStr())
                if tempIcon then
                    local tempSize = itemTab.m_material_node:getContentSize();
                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    itemTab.m_material_node:addChild(tempIcon)
                    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
                    -- cclog("quality ==" .. quality)
                    local qualityTab = HERO_QUALITY_COLOR_TABLE[quality];
                    local img1,img2;
                    if qualityTab then
                        local tempIconSize = tempIcon:getContentSize();
                        img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                        img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                        tempIcon:addChild(img1,-1,1)
                        img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
                        img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                        tempIcon:addChild(img2,1,2)
                    end
                    if itemCount < i then
                        tempIcon:setColor(ccc3(81,81,81))
                        if img1 then
                            img1:setColor(ccc3(81,81,81))
                        end
                        if img2 then
                            img2:setColor(ccc3(81,81,81))
                        end
                    end
                end
                itemTab.m_num_label:setString("x"..tostring(itemCount))
                itemTab.m_num_label:setVisible(false)
                itemTab.itemId = itemId
                itemTab.count = itemCount
                local tempPos = tempPosTab[i]
                local tempSize = self.m_material_node:getContentSize();
                if self.m_animFlag == true then
                    itemTab.parentNode:stopAllActions();
                    itemTab.parentNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    itemTab.parentNode:runAction(CCMoveTo:create(0.2,ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height)));
                else
                    itemTab.parentNode:setPosition(ccp(tempPos[1]*0.01*material_node_size.width, tempPos[2]*0.01*material_node_size.height))
                end
            end
        end
    else
        for i=1,#self.m_material_node_tab do
            local itemTab = self.m_material_node_tab[i]
            itemTab.m_material_node:setVisible(false)
            itemTab.m_mate_tips:setVisible(false)
            itemTab.itemId = -1
            itemTab.count = 0
        end
    end
    return showFlag;
end


--[[--

]]
function gem_system_synthesis.refreshData(self)
    local tempData = game_data:getGemData() or {};
    self.m_ownGemTab = tempData;
    -- cclog("ItemsData = " .. json.encode(game_data:getItemsData() or {}));
    local tempSortTab = {};
    self.m_showSortIdTab = {};
    self.m_tGameData = {}
    local gem_cfg = getConfig(game_config_field.gem);
    local tempCount = gem_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = gem_cfg:getNodeAt(i-1);
        local key = itemCfg:getKey();
        local team = itemCfg:getNodeWithKey("team"):toInt();
        local last_name = itemCfg:getNodeWithKey("last_name"):toStr();
        local first_name = itemCfg:getNodeWithKey("first_name"):toStr();
        local quality = itemCfg:getNodeWithKey("quality"):toInt();
        local need_gem = itemCfg:getNodeWithKey("need_gem"):toStr();
        local gem_num = itemCfg:getNodeWithKey("gem_num"):toInt();
        local tempItemCfgNew = gem_cfg:getNodeWithKey(need_gem)
        local synthesisFlag = true;
        if need_gem == "0" or tempItemCfgNew == nil then
            synthesisFlag = false;
        end
        if self.m_tGameData[team] == nil then
            self.m_tGameData[team] = {}
            self.m_gemTeamCountTab[team] = 0;
        end
        local count = tempData[need_gem] or 0
        self.m_gemTeamCountTab[team] = self.m_gemTeamCountTab[team] + count;
        if synthesisFlag == true then
            local partTab = {}
            for i=1,gem_num do
                table.insert(partTab,{need_gem,count})
            end
            table.insert(self.m_tGameData[team],{key = key,part = partTab,last_name = last_name,first_name=first_name,quality = quality,synthesisFlag = synthesisFlag})
            if tempSortTab[team] == nil then
                table.insert(self.m_showSortIdTab,team)
                tempSortTab[team] = 1;
            end
        end
    end
    table.sort(self.m_showSortIdTab,function(data1,data2) 
        return data1 < data2
    end)
    for k,v in pairs(self.m_tGameData) do
        table.sort(v,function(data1,data2) 
            return data1.quality < data2.quality
        end)
    end
    if self.m_selSortId == nil and #self.m_showSortIdTab > 0 then
        self.m_selPosIndex = 1;
        self.m_selSortId = self.m_showSortIdTab[self.m_selPosIndex];
    end
    local itemData = self.m_tGameData[self.m_selSortId]
    if itemData then
        if self.m_selSortIndex > #itemData then
            self.m_selSortIndex = 1;
        end
    else
        self.m_selPosIndex = 1;
        self.m_selSortId = self.m_showSortIdTab[self.m_selPosIndex];
    end
end

--[[--

]]
function gem_system_synthesis.refreshInfo(self)
    local m_metal_total_label = self.m_ccbNode:labelBMFontForName("m_metal_total_label")
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    m_metal_total_label:setString(value .. unit);
    local m_cost_metal_label = self.m_ccbNode:labelBMFontForName("m_cost_metal_label")
    m_cost_metal_label:setString(self.m_needMetal)
    game_util:setCostLable(m_cost_metal_label,self.m_needMetal,totalMetal);
end

--[[--
    刷新ui
]]
function gem_system_synthesis.refreshUi(self)
    self:refreshTableView();
    self:showSortTabBtn(self.m_selPosIndex);
    self:refreshSortTabBtn(self.m_selSortIndex);
end


--[[--
    初始化
]]
function gem_system_synthesis.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then

    end
    self.m_material_node_tab = {};
    self.m_selSortIndex = 1;
    self.m_selPosIndex = 1;
    cclog("self.m_selSortIndex====== " .. self.m_selSortIndex)
    cclog("self.m_selPosIndex====== " .. self.m_selPosIndex)
    self.m_selSortId = 1;
    self.m_animCount = 0;
    self.m_animFlag = true;
    self.m_needMetal = 0;
    self.m_gemTeamCountTab = {};
    self:refreshData();
end

--[[--
    创建ui入口并初始化数据
]]
function gem_system_synthesis.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    -- game_data:updateShowTips( "cmdr_energy" , "have_show")

    return scene;
end


return gem_system_synthesis;