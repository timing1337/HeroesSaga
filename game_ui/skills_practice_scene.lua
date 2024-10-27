---  技能修炼

local skills_practice_scene = {
    m_skill_layer = nil,--技能层
    m_curr_skill_layer = nil,--
    m_skillTotalLevel = nil,--当前选中技能类别的中等级，需要通过这个获取升级技能的材料
    m_sel_tree_id = nil,--但前选中的技能树id
    m_treeTable = nil,
    m_selMenuItem = nil,
    m_skill_type_icon = nil,
    m_back_btn = nil,
    m_treeOpenLevelTab = nil,
    m_guildNode = nil,
    m_ccbNode = nil,
    m_selSortIndex = nil,
    m_anim_node = nil,
    m_tempLeaderSkill = nil,
    m_changeFlag = nil,
    m_star_total_label = nil,
    m_root_layer = nil,
};
--[[--
    销毁
]]
function skills_practice_scene.destroy(self)
    -- body
    cclog("-----------------skills_practice_scene destroy-----------------");
    self.m_skill_layer = nil;
    self.m_curr_skill_layer = nil;
    self.m_skillTotalLevel = nil;
    self.m_sel_tree_id = nil;
    self.m_treeTable = nil;
    self.m_selMenuItem = nil;
    self.m_skill_type_icon = nil;
    self.m_back_btn = nil;
    self.m_treeOpenLevelTab = nil;
    self.m_guildNode = nil;
    self.m_ccbNode = nil;
    self.m_selSortIndex = nil;
    self.m_anim_node = nil;
    self.m_tempLeaderSkill = nil;
    self.m_changeFlag = nil;
    self.m_star_total_label = nil;
    self.m_root_layer = nil;
end
--[[--
    返回
]]
function skills_practice_scene.back(self,backType)
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
function skills_practice_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_changeFlag == true then
                local function setSkillResponseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    game_data:setLeaderSkillDataByJsonData(data:getNodeWithKey("leader_skill"))
                    if btnTag == 1 then--返回
                        self:back("back");
                    end
                end
                -- harbor_set_skill = service_url .. "/?method=harbor.set_skill",--避难所技能替换skill_1=101&skill_2=102&skill_3=103
                local params = {};
                for i=1,3 do
                    params["skill_" .. i ] = self.m_tempLeaderSkill["skill_" .. i];
                end
                network.sendHttpRequest(setSkillResponseMethod,game_url.getUrlForKey("harbor_set_skill"), http_request_method.GET, params,"harbor_set_skill")
            else
                self:back("back");
            end
        elseif btnTag == 2 then--加点
            if self.m_sel_tree_id == nil then return end
            local function callBackFunc()
                self:refreshUi();
            end
            game_scene:addPop("game_skill_point_buy_pop",{tree_id = self.m_sel_tree_id,callBackFunc=callBackFunc})
        elseif btnTag == 3 then--重置
            if self.m_sel_tree_id == nil then return end
            local count = game_data:getItemCountByCid(tostring(25))
            if count > 0 then
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        local function responseMethod(tag,gameData)
                            game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                            self:refreshUi();
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_wash_down"), http_request_method.GET,{tree = self.m_sel_tree_id},"leader_skill_wash_down")
                        game_util:closeAlertView();
                    end,   --可缺省
                    text = string_helper.skills_practice_scene.text,
                }
                game_util:openAlertView(t_params);
            else
                local function responseMethod2(tag,gameData)
                    game_data:setHarborDataByJsonData(gameData:getNodeWithKey("data"));
                    self:refreshUi();
                end
                -- local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("14"):getNodeWithKey("coin")
                local payValue = 100
                if getConfig(game_config_field.pay):getNodeWithKey("14") ~= nil then
                    local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("14"):getNodeWithKey("coin")
                    payValue = PayCfg:getNodeAt(0):toInt()
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod2,game_url.getUrlForKey("leader_skill_wash_down"), http_request_method.GET,{tree = self.m_sel_tree_id},"leader_skill_wash_down")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = string_helper.skills_practice_scene.text2 .. payValue .. string_helper.skills_practice_scene.payValue,      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                }
                game_util:openAlertView(t_params)
            end
        elseif btnTag >= 201 and btnTag <= 204 then
            if not self:checkSkillOpen(btnTag - 200) then return end
            self:refreshSortTabBtn(btnTag - 200);
            local treeId = self.m_treeOpenLevelTab[btnTag-200].treeId;
            self:refreshSkillsTree(self.m_skill_layer,treeId);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_skills_practice.ccbi");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_skill_layer = ccbNode:layerColorForName("m_skill_layer")
    self.m_curr_skill_layer = ccbNode:layerColorForName("m_curr_skill_layer")
    self.m_skill_type_icon = ccbNode:spriteForName("m_skill_type_icon")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_star_total_label = ccbNode:labelBMFontForName("m_star_total_label")
    local m_table_tab_label_1= ccbNode:labelBMFontForName("m_table_tab_label_1");
    local m_table_tab_label_2= ccbNode:labelBMFontForName("m_table_tab_label_2");
    local m_table_tab_label_3= ccbNode:labelBMFontForName("m_table_tab_label_3");
    local m_table_tab_label_4= ccbNode:labelBMFontForName("m_table_tab_label_4");
    m_table_tab_label_1:setString(string_helper.ccb.file1);
    m_table_tab_label_2:setString(string_helper.ccb.file2);
    m_table_tab_label_3:setString(string_helper.ccb.file3);
    m_table_tab_label_4:setString(string_helper.ccb.file4);
    local title67 = ccbNode:labelTTFForName("title67");
    title67:setString(string_helper.ccb.title67);
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY);
    self:initSkillsTreeTouch(self.m_skill_layer);
    self:initCurrentSkillsTouch(self.m_curr_skill_layer);
    local roleImg = game_util:createOwnBigImg();
    if roleImg then
        roleImg:setScale(0.4);
        roleImg:setAnchorPoint(ccp(0.5, 0));
        self.m_anim_node:addChild(roleImg);
    end
    self.m_ccbNode = ccbNode;
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    检查技能是否开启
]]
function skills_practice_scene.checkSkillOpen( self, skillId )
    local skillInfo = {
                            {name = string_helper.skills_practice_scene.lt, level = 0},
                            {name = string_helper.skills_practice_scene.ly, level = 10},
                            {name = string_helper.skills_practice_scene.bd, level = 20},
                            {name = string_helper.skills_practice_scene.ym, level = 30},
                        }
    local needLevel = 0
    if skillInfo[skillId] then 
        needLevel = skillInfo[skillId].level
    end
    local level = game_data:getUserStatusDataByKey("level")
    if level >= needLevel then
        return true
    else
        local lockStr = ""
        if skillInfo[skillId] then 
            lockStr = lockStr .. skillInfo[skillId].name
        end
        --lockStr = lockStr ..string_helper.skills_practice_scene.need..needLevel..string_helper.skills_practice_scene.level_open
        lockStr = lockStr..needLevel..string_helper.skills_practice_scene.level_open
        game_util:addMoveTips({text = lockStr});
        return false
    end
    return true
end

--[[--

]]
function skills_practice_scene.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(sortIndex == i);
        tempBtn:setEnabled(sortIndex ~= i);
    end
end

--[[--
    刷新技能树    
]]
function skills_practice_scene.refreshSkillsTree(self,formation_layer,treeId)
    self.m_guildNode = nil;
    self.m_skillTotalLevel = 0;
    self.m_sel_tree_id = treeId;
    formation_layer:removeAllChildrenWithCleanup(true);
    if treeId == nil then return end
    treeId = tonumber(treeId);
    if treeId > 0 and treeId < 9 then
        -- self.m_skill_type_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ball" .. treeId .. ".png"));
    end
    local tGameData = game_data:getHarborData();
    local skill = tGameData.available_skill;
    local leader_skill_tree = getConfig(game_config_field.leader_skill_tree);
    local leader_skill_cfg = getConfig(game_config_field.leader_skill)
    local treeItem = leader_skill_tree:getNodeWithKey(tostring(self.m_sel_tree_id));
    if treeItem == nil then return end
    local item = nil;
    local count = nil;
    self.m_treeTable = {};
    local skillIcon = nil;
    local index_x = 0;
    local index_y = 0;
    local leader_skill_item = nil;
    local is_positive = 0;

    local heightCount = 0;
    local size = formation_layer:getContentSize();
    local itemSize = CCSizeMake(size.width*0.25,size.height*0.25);
    if treeItem:getNodeCount() > 0 then
        heightCount = treeItem:getNodeAt(0):getNodeCount();
        if heightCount > 3 then
            itemSize = CCSizeMake(size.width*0.25,size.height*0.175);
        end
    end

    local size = formation_layer:getContentSize();
    local drawNode = ExtDrawNode:create(size,3);
    drawNode:setPosition(ccp(0,0));
    formation_layer:addChild(drawNode);
    
    local function paramsSkillTree(jsonData)
        count = jsonData:getNodeCount();
        for i=1,count do
            local item = jsonData:getNodeAt(i - 1);
            local key = item:getKey();
            if self.m_treeTable[key] == nil then
                local skillIcon,is_positive = nil;
                leader_skill_item = leader_skill_cfg:getNodeWithKey(key);
                local current_lv = 0;
                if skill[key] == nil then--未开启
                    skillIcon,is_positive = game_util:createLeaderSkillIconByCfg(leader_skill_item,self.m_sel_tree_id,false);
                else--开启
                    current_lv = skill[key];
                    self.m_skillTotalLevel = self.m_skillTotalLevel + current_lv
                    skillIcon,is_positive = game_util:createLeaderSkillIconByCfg(leader_skill_item,self.m_sel_tree_id,true);
                    if self.m_guildNode == nil and current_lv > 0 then
                        self.m_guildNode = skillIcon;
                    end
                end
                local skillIconSize = skillIcon:getContentSize();
                local levelLabel = game_util:createLabel({text = "Lv." .. current_lv .. "/" .. leader_skill_item:getNodeWithKey("max_level"):toStr()})--CCLabelTTF:create("Lv." .. current_lv .. "/" .. leader_skill_item:getNodeWithKey("max_level"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
                levelLabel:setPosition(ccp(skillIconSize.width*0.5,skillIconSize.height*0.1));
                -- levelLabel:setColor(ccc3(255,255,0));
                skillIcon:addChild(levelLabel,1,1);
                local nameLabel = game_util:createLabel({text = leader_skill_item:getNodeWithKey("name"):toStr()})--CCLabelTTF:create(leader_skill_item:getNodeWithKey("name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
                nameLabel:setPosition(ccp(skillIconSize.width*0.5,-skillIconSize.height*0.2));
                skillIcon:addChild(nameLabel,2,2);
                skillIcon:setTag(tonumber(key));
                local xy = leader_skill_item:getNodeWithKey("xy");
                index_x = xy:getNodeAt(1):toInt();
                index_y = xy:getNodeAt(0):toInt();
                local px,py = itemSize.width * (index_x - 1),size.height - itemSize.height*(index_y - 1)
                skillIcon:setPosition(ccp(px,py));
                cclog("item ============== id = " .. key .. " ; index_x = " ..index_x .. " ; index_y = " .. index_y);
                skillIcon:setScale(0.75);
                formation_layer:addChild(skillIcon);
                local parentTable = {};
                local parent = self.m_treeTable[jsonData:getKey()]
                if parent ~= nil then
                    table.insert(parentTable,parent);
                    if current_lv > 0 then
                        self:drawLine(drawNode,index_x,index_y,parent,px,py);
                    end
                end
                self.m_treeTable[key] = {id = key,skillIcon = skillIcon,parentTable = parentTable,px=px,py=py,lv=current_lv,index_x = index_x,index_y = index_y,is_positive = is_positive};
            else
                local parent = self.m_treeTable[jsonData:getKey()]
                if parent ~= nil then
                    table.insert(self.m_treeTable[key].parentTable,parent);
                    if self.m_treeTable[key].lv > 0 then
                        local tempItem = self.m_treeTable[key];
                        local px,py = tempItem.px,tempItem.py;
                        local index_x,index_y = tempItem.index_x,tempItem.index_y;
                        self:drawLine(drawNode,index_x,index_y,parent,px,py);
                    end
                end
            end
            if item:getNodeCount() ~= 0 then
                paramsSkillTree(item);
            end
        end
    end
    paramsSkillTree(treeItem);
end


--[[--
    
]]
function skills_practice_scene.drawLine(self,drawNode,index_x,index_y,parent,px,py)
    if index_y == 2 and (index_x == 1 or index_x == 5) then
        drawNode:drawLine(ccp(parent.px,parent.py), ccp(px,parent.py), 2, ccc4f(255/255, 238/255, 0, 1));
        drawNode:drawLine(ccp(px,parent.py), ccp(px,py), 2, ccc4f(255/255, 238/255, 0, 1));
    elseif index_y == 5 and (index_x == 2 or index_x == 4) then
        drawNode:drawLine(ccp(parent.px,parent.py), ccp(parent.px,py), 2, ccc4f(255/255, 238/255, 0, 1));
        drawNode:drawLine(ccp(parent.px,py), ccp(px,py), 2, ccc4f(255/255, 238/255, 0, 1));
    else
        drawNode:drawLine(ccp(parent.px,parent.py), ccp(px,py), 2, ccc4f(255/255, 238/255, 0, 1));
    end
end

--[[--
    点击技能图标的处理
]]
function skills_practice_scene.initSkillsTreeTouch(self,formation_layer)
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local tempItem = nil;
    local selItem = nil;
    local realPos = nil;
    local moveItem = nil;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        moveItem = nil;
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for k,v in pairs(self.m_treeTable) do
            tempItem = v.skillIcon;
            if tempItem:boundingBox():containsPoint(realPos) then
                selItem = tempItem;
                local selSkill = selItem:getTag()
                local tGameData = game_data:getHarborData();
                local skill = tGameData.available_skill;
                local tempLv = skill[tostring(selSkill)]
                if tempLv and tempLv > 0 and v.is_positive == 1 then--开启
                    moveItem = game_util:createLeaderSkillIconByCid(selSkill,nil,true);
                    if moveItem then
                        moveItem:setPosition(realPos);
                        moveItem:setScale(0.8);
                        moveItem:setVisible(false);
                        moveItem:setTag(selSkill);
                        formation_layer:addChild(moveItem,100);
                    end
                end
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if moveItem then
                realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                moveItem:setPosition(realPos);
                moveItem:setVisible(true);
            end
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        realPos = self.m_curr_skill_layer:convertToNodeSpace(ccp(x,y));
        for i=1,3 do
            local tempNode = self.m_ccbNode:spriteForName("m_skill_" .. i);
            if tempNode:boundingBox():containsPoint(realPos) then
                if moveItem and touchMoveFlag then
                    local selSkill = moveItem:getTag();
                    if self:leaderSkillIsAvailable(selSkill) then
                        self.m_changeFlag = true;
                        self.m_tempLeaderSkill["skill_" .. i] = selSkill;
                        tempNode:removeAllChildrenWithCleanup(true);
                        local tempSkillNode = game_util:createLeaderSkillIconByCid(selSkill,nil,true);
                        if tempSkillNode then
                            tempSkillNode:setScale(0.8);
                            local tempSize = tempNode:getContentSize();
                            tempSkillNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                            tempNode:addChild(tempSkillNode)
                        end
                        local id = game_guide_controller:getIdByTeam("13");
                        if id == 1304 then
                            self:gameGuide("drama","13",1306)
                        end
                    end
                else
                    local selSkill = self.m_tempLeaderSkill["skill_" .. i];
                    cclog("selSkill ================ " .. selSkill)
                    if selSkill ~= 0 and touchMoveFlag == false then
                        local function callBackFunc()
                            self:refreshUi();
                        end
                        game_scene:addPop("skills_practice_pop",{skillId = selSkill,callBackFunc = callBackFunc,skillTotalLevel = self.m_skillTotalLevel,treeId = self.m_sel_tree_id,treeTable = self.m_treeTable})
                    end
                end
                break;
            end
        end
        if moveItem then
            moveItem:removeFromParentAndCleanup(true);
            moveItem = nil;
        end
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        if selItem and selItem:boundingBox():containsPoint(realPos) then
            local selSkill = selItem:getTag()
            local function callBackFunc()
                local id = game_guide_controller:getIdByTeam("13");
                if id == 1303 then
                    self:gameGuide("drama","13",1304)
                end
                self:refreshUi();
            end
            game_scene:addPop("skills_practice_pop",{skillId = selSkill,callBackFunc = callBackFunc,skillTotalLevel = self.m_skillTotalLevel,treeId = self.m_sel_tree_id,treeTable = self.m_treeTable})
        end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1)
    formation_layer:setTouchEnabled(true)
end


--[[--
    点击技能图标的处理
]]
function skills_practice_scene.initCurrentSkillsTouch(self,formation_layer)
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local tempItem = nil;
    local selItem = nil;
    local realPos = nil;
    local moveItem = nil;
    local selIndex = nil;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        selItem = nil;
        moveItem = nil;
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for i=1,3 do
            local tempNode = self.m_ccbNode:spriteForName("m_skill_" .. i);
            if tempNode:boundingBox():containsPoint(realPos) then
                selIndex = i;
                selItem = tempNode;
                local selSkill = self.m_tempLeaderSkill["skill_" .. i];
                if selSkill and selSkill ~= 0 then
                    moveItem = game_util:createLeaderSkillIconByCid(selSkill,nil,true);
                    if moveItem then
                        moveItem:setPosition(realPos);
                        moveItem:setScale(0.8);
                        moveItem:setVisible(false);
                        moveItem:setTag(selSkill);
                        formation_layer:addChild(moveItem,100);
                    end
                end
                break;
            end
        end

        return true
    end
    
    local function onTouchMoved(x, y)
        if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 or touchMoveFlag == true then
            if moveItem then
                realPos = formation_layer:convertToNodeSpace(ccp(x,y));
                moveItem:setPosition(realPos);
                moveItem:setVisible(true);
            end
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        if selItem then
            realPos = formation_layer:convertToNodeSpace(ccp(x,y));
            local tempSelItem = nil;
            for i=1,3 do
                local tempNode = self.m_ccbNode:spriteForName("m_skill_" .. i);
                if tempNode:boundingBox():containsPoint(realPos) then
                    tempSelItem = tempNode;
                    if tempNode ~= selItem then
                        self.m_changeFlag = true;
                        cclog("exchange -------------")
                        self.m_tempLeaderSkill["skill_" .. i],self.m_tempLeaderSkill["skill_" .. selIndex] = self.m_tempLeaderSkill["skill_" .. selIndex],self.m_tempLeaderSkill["skill_" .. i]
                        self:fillCurrentLeaderSkill();
                    end
                    break;
                end
            end
            if tempSelItem == nil then
                self.m_changeFlag = true;
                cclog("remove -------------")
                self.m_tempLeaderSkill["skill_" .. selIndex] = 0;
                self:fillCurrentLeaderSkill();
            end
        end
        if moveItem then
            moveItem:removeFromParentAndCleanup(true);
            moveItem = nil;
        end
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1)
    formation_layer:setTouchEnabled(true)
end

--[[--
    
]]
function skills_practice_scene.fillCurrentLeaderSkill(self)
    local skillIdTreeTab = game_data:getSkillIdTreeTab();
    for i=1,3 do
        local tempNode = self.m_ccbNode:spriteForName("m_skill_" .. i);
        tempNode:removeAllChildrenWithCleanup(true);
        local skillId = self.m_tempLeaderSkill["skill_" .. i]
        if skillId and skillId ~= 0 then
            local tempIcon = game_util:createLeaderSkillIconByCid(skillId,skillIdTreeTab[tostring(skillId)],true);
            if tempIcon then
                tempIcon:setScale(0.8);
                local tempSize = tempNode:getContentSize();
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                tempNode:addChild(tempIcon)
            end
        end
    end
end

--[[--
    
]]
function skills_practice_scene.leaderSkillIsAvailable(self,selSkillId)
    local availableFlag = true;
    for i=1,3 do
        local skillId = self.m_tempLeaderSkill["skill_" .. i]
        if skillId and skillId ~= 0 and skillId == selSkillId then
            availableFlag = false;
        end
    end
    return availableFlag;
end

--[[--
    刷新ui
]]
function skills_practice_scene.refreshUi(self)
    self:refreshSkillsTree(self.m_skill_layer,self.m_sel_tree_id);
    self:refreshSortTabBtn(self.m_selSortIndex);
    self:fillCurrentLeaderSkill();
    local totalStar = game_data:getUserStatusDataByKey("star") or 0
    self.m_star_total_label:setString(tostring(totalStar))
end
--[[--
    初始化
]]
function skills_practice_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setHarborDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
    self.m_posIconTab = {};
    self.m_treeOpenLevelTab = {};
    local building_base_harbor_cfg = getConfig(game_config_field.building_base_harbor);
    local tempCount = building_base_harbor_cfg:getNodeCount();
    local tempItem,treeId = nil;
    for i=1,tempCount do
        tempItem = building_base_harbor_cfg:getNodeAt(i-1);
        treeId = tempItem:getNodeWithKey("tree"):toInt();
        if treeId > 0 then
            self.m_treeOpenLevelTab[#self.m_treeOpenLevelTab+1] = {treeId = treeId,openLevel = tonumber(tempItem:getKey())}
        end
    end
    if #self.m_treeOpenLevelTab > 0 then
        self.m_sel_tree_id = self.m_treeOpenLevelTab[1].treeId;
    end
    local function sortFunc(dataOne,dataTwo)
        return dataOne.treeId < dataTwo.treeId;
    end
    table.sort(self.m_treeOpenLevelTab,sortFunc)
    table.foreach(self.m_treeOpenLevelTab,print)
    self.m_treeTable = {};
    self.m_selSortIndex = 1;
    self.m_tempLeaderSkill = game_data:getLeaderSkillData();
    self.m_changeFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function skills_practice_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("13");
    if id == 1301 then
        self:gameGuide("drama","13",1302)
    elseif id == 1303 then
        self:gameGuide("drama","13",1304)
    end

    game_data:updateShowTips("totalStar", "have_show")


    game_guide_controller:showEndForceGuide("13")
    return scene;
end

function skills_practice_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "13" and id == 1302 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","13",1302);
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","13",1302,{tempNode = self.m_guildNode})
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "13" and id == 1304 then
            local function endCallFunc()
                -- game_guide_controller:gameGuide("send","13",1304);
                local endNode = self.m_ccbNode:spriteForName("m_skill_1");
                cclog("self.m_guildNode == " .. tostring(self.m_guildNode) .. " ; endNode ==" .. tostring(endNode))
                if self.m_guildNode and endNode then
                    self.m_root_layer:setTouchEnabled(true);
                    local yindao_shouzhi = game_util:createImpactAnim("yindao_shouzhi",1)
                    yindao_shouzhi:pause();
                    local pX,pY = self.m_guildNode:getPosition();
                    local startPos = self.m_guildNode:getParent():convertToWorldSpace(ccp(pX,pY));
                    local pX,pY = endNode:getPosition();
                    local endPos = endNode:getParent():convertToWorldSpace(ccp(pX,pY));
                    yindao_shouzhi:setPosition(startPos);
                    local function animCallbackFunc(node)
                        yindao_shouzhi:removeFromParentAndCleanup(true);
                        self.m_root_layer:setTouchEnabled(false);
                    end
                    local animArr = CCArray:create();
                    animArr:addObject(CCMoveTo:create(2,endPos));
                    animArr:addObject(CCCallFuncN:create(animCallbackFunc));
                    yindao_shouzhi:runAction(CCSequence:create(animArr));
                    game_scene:getPopContainer():addChild(yindao_shouzhi)
                else

                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "13" and id == 1306 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","13",1306);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return skills_practice_scene;
