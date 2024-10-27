---  每日任务

local game_daily_task_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_progress_bg = nil,
    m_activity_value = nil,
    m_task_story_label = nil,
    m_stageTab = nil,
    m_mask_layer = nil,
    m_rewardTips = nil,
    m_tGameData = nil,
    m_progress_bar = nil,

    task_table_view = nil,
};
--[[--
    销毁
]]
function game_daily_task_pop.destroy(self)
    -- body
    cclog("-----------------game_daily_task_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_progress_bg = nil;
    self.m_activity_value = nil;
    self.m_task_story_label = nil;
    self.m_stageTab = nil;
    self.m_mask_layer = nil;
    self.m_rewardTips = nil;
    self.m_tGameData = nil;
    self.m_progress_bar = nil;

    self.task_table_view = nil;
end
--[[--
    返回
]]
function game_daily_task_pop.back(self,type)
    -- game_scene:removePopByName("game_daily_task_pop");
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_daily_task_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 4 then--切换tab
            function shopOpenResponseMethod(tag,gameData)
                game_scene:removePopByName("game_daily_task_pop");
                -- game_scene:enterGameUi("game_daily_wanted",{gameData = gameData})
                -- self:destroy();
                game_scene:addPop("game_daily_wanted",{gameData = gameData})
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, {},"reward_index")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_daily_task.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_mask_layer = ccbNode:layerForName("m_mask_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_progress_bg = ccbNode:nodeForName("m_progress_bg")
    self.m_activity_value = ccbNode:labelTTFForName("m_activity_value")
    self.m_task_story_label = ccbNode:labelTTFForName("m_task_story_label")

    local m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2")
    local m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3")

    game_util:setCCControlButtonTitle(m_tab_btn_2,string_helper.ccb.text117)
    game_util:setCCControlButtonTitle(m_tab_btn_3,string_helper.ccb.text118)

    m_tab_btn_2:setEnabled(false)

    local barSize = self.m_progress_bg:getContentSize();
    local bar = ExtProgressBar:createWithFrameName("mrrw_progress_1.png","mrrw_progress_2.png",barSize);
    bar:setCurValue(0,false);
    self.m_progress_bg:addChild(bar);
    self.m_progress_bar = bar;

    local animTab = {"anim_ui_baoxiang1","anim_ui_baoxiang1","anim_ui_baoxiang2","anim_ui_baoxiang3"};
    for i=1,4 do
        local m_stage = ccbNode:spriteForName("m_stage_" .. i)
        local tempSize = m_stage:getContentSize();
        local tempAnim = self:createBoxAnim(animTab[i])
        tempAnim:setPosition(ccp(tempSize.width*0.5, tempSize.height*2.5));
        tempAnim:setTag(i);
        m_stage:addChild(tempAnim)
        self.m_stageTab[i] = {m_stage = m_stage,boxAnim = tempAnim,openFlag = false}
    end
    self:initLayerTouch(self.m_mask_layer);
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text116)
    return ccbNode;
end

function game_daily_task_pop.createBoxAnim(self,animFile)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if theLabelName == "daiji1" or theLabelName == "daiji2" or theLabelName == "daiji3" then
            animNode:playSection(theLabelName)
        elseif theLabelName == "dakai" then
            animNode:playSection("daiji3")
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("daiji1");
    return mAnimNode;
end

local rewardScoreTab = {"20","50","80","100"}

--[[--
    奖励弹出框
]]
function game_daily_task_pop.createRewardTipsPop(self,clickNode)
    if self.m_rewardTips then return end
    local tag = clickNode:getTag();
    local diaryscore_cfg = getConfig(game_config_field.diaryscore)
    -- cclog("diaryscore_cfg = " .. diaryscore_cfg:getFormatBuffer())
    local diaryscore_item_cfg = diaryscore_cfg:getNodeWithKey(rewardScoreTab[tag])
    local reardNode = CCNode:create();
    local rewardHeight = 0;
    if diaryscore_item_cfg then
        local reward = diaryscore_item_cfg:getNodeWithKey("reward")
        if reward then
            local rewardCount = reward:getNodeCount();
            cclog("rewardCount===== " .. rewardCount)
            rewardHeight = 30*rewardCount
            reardNode:setContentSize(CCSizeMake(100, rewardHeight))
            for i=1,rewardCount do
                local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                -- cclog("icon == " .. tostring(icon) .. " name = " .. tostring(icon))
                if icon then
                    icon:setScale(0.5);
                    icon:setPosition(ccp(30, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(icon)
                end
                if name then
                    local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                    tempLabel:setPosition(ccp(80, rewardHeight - 30*(0.5 + i - 1)))
                    reardNode:addChild(tempLabel)
                end
            end
        end
    end
    local bgSpr = CCScale9Sprite:createWithSpriteFrameName("public_pop_box_back.png");
    local viewSize = CCSizeMake(130,30 + rewardHeight);
    bgSpr:setPreferredSize(viewSize);
    -- local scrollView = CCScrollView:create(viewSize);
    -- scrollView:setDirection(kCCScrollViewDirectionVertical);
    -- scrollView:setContentSize(CCSizeMake(viewSize.width,viewSize.height));
    -- scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    -- bgSpr:addChild(scrollView);
    reardNode:setPositionY(10)
    bgSpr:addChild(reardNode)
    local arrow = CCSprite:createWithSpriteFrameName("public_pop_box_arror.png")
    local arrowSize = arrow:getContentSize();
    arrow:setPosition(ccp(viewSize.width*0.5,0));
    arrow:setRotation(-90);
    bgSpr:addChild(arrow);
    local titleLabel = game_util:createLabelTTF({text = string_helper.game_daily_task_pop.activeReward,color = ccc3(250,180,0),fontSize = 14});
    titleLabel:setPosition(ccp(viewSize.width*0.5, viewSize.height - 10))
    bgSpr:addChild(titleLabel)
    local px,py = clickNode:getPosition();
    local tempSize = clickNode:getContentSize();
    bgSpr:setAnchorPoint(ccp(0.5,0));
    local pos = clickNode:getParent():convertToWorldSpace(ccp(px,py+arrowSize.height));
    bgSpr:setPosition(pos);
    self.m_rewardTips = CCLayer:create();
    self.m_rewardTips:addChild(bgSpr);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_rewardTips then
                self.m_rewardTips:removeFromParentAndCleanup(true);
                self.m_rewardTips = nil;
            end
            return true;--intercept event
        end
    end
    self.m_rewardTips:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_rewardTips:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(self.m_rewardTips);
end


--[[--
    
]]
function game_daily_task_pop.initLayerTouch(self,formation_layer)
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        -- CCTOUCHBEGAN event must return true
        tempItem = nil;
        for k,v in pairs(self.m_stageTab) do
            tempItem = v.boxAnim
            realPos = v.boxAnim:getParent():convertToNodeSpace(ccp(x,y));
            if tempItem:boundingBox():containsPoint(realPos) then
                break;
            end
        end
        return true
    end
    
    local function onTouchMoved(x, y)
    end
    
    local function onTouchEnded(x, y)
        if tempItem then
            realPos = tempItem:getParent():convertToNodeSpace(ccp(x,y));
            if tempItem:boundingBox():containsPoint(realPos) then
                tag = tempItem:getTag()
                if self.m_stageTab[tag] and self.m_stageTab[tag].openFlag == true then
                    if rewardScoreTab[tag] then
                        local function responseMethod(tag,gameData)
                            local data = gameData:getNodeWithKey("data")
                            local tData = json.decode(data:getFormatBuffer())
                            game_util:rewardTipsByDataTable(tData.reward);
                            self.m_tGameData.diaryscore = tData.diaryscore;
                            self.m_tGameData.diaryscore_done = tData.diaryscore_done
                            self:refreshUi();
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_diary_score_award"), http_request_method.GET, {score = rewardScoreTab[tag]},"reward_diary_score_award")
                    end
                else
                    self:createRewardTipsPop(tempItem);    
                end
            end
        end
        tempItem = nil;
        realPos = nil;
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
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1)
    formation_layer:setTouchEnabled(true)
end

--[[--
    
]]
function game_daily_task_pop.createTableView(self,viewSize)
    local reward_diary = getConfig(game_config_field.reward_diary)
    local diary = self.m_tGameData.diary
    local diary_done = self.m_tGameData.diary_done or {};
    local result = diary.result or {}
    local tempData = {}
    for k,v in pairs(result) do
        tempData[#tempData+1] = k;
    end
    local tonumber = tonumber;
    local function sortFunc(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(tempData,sortFunc)

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local tempId = tostring(tempData[btnTag + 1])
        self:goFinishTask(tempId);
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_daily_task_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_go_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_9sprite_bg = ccbNode:scale9SpriteForName("m_9sprite_bg")
            local m_go_btn = ccbNode:controlButtonForName("m_go_btn")
            game_util:setCCControlButtonTitle(m_go_btn,string_helper.ccb.text119)
            local m_task_name_label = ccbNode:labelTTFForName("m_task_name_label")
            local m_progress_label = ccbNode:labelBMFontForName("m_progress_label")
            local m_finish_label = ccbNode:labelBMFontForName("m_finish_label")
            m_finish_label:setString(string_helper.ccb.text120)
            local m_activity_reward = ccbNode:labelTTFForName("m_activity_reward")
            local m_progress_bg = ccbNode:nodeForName("m_progress_bg")
            m_progress_bg:removeAllChildrenWithCleanup(true)
            local bar = ExtProgressTime:createWithFrameName("o_public_skillExpBg.png","o_public_skillExp.png");
            if index % 2 == 0 then
                m_9sprite_bg:setSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("mrrw_tiao_1.png"));
            else
                m_9sprite_bg:setSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("mrrw_tiao_2.png"));
            end
            m_9sprite_bg:setPreferredSize(CCSizeMake(370, 35))
            m_progress_bg:addChild(bar);
            m_go_btn:setTag(index);
            local tempId = tostring(tempData[index + 1])
            local itemData = result[tempId]
            local itemCfg = reward_diary:getNodeWithKey(tempId);
            if itemData and itemCfg then
                local story = itemCfg:getNodeWithKey("story"):toStr();
                local num = itemCfg:getNodeWithKey("num"):toInt();
                m_task_name_label:setString(story);
                m_activity_reward:setString(string.format(string_helper.game_daily_task_pop.addActive,itemCfg:getNodeWithKey("reward_score"):toInt()))
                local finishValue = diary_done[tempId] or 0
                if num > 0 then
                    bar:setCurValue(100*finishValue/num,false);
                end
                m_progress_label:setString(string.format("%d/%d",finishValue,num))
                if finishValue >= num then
                    -- m_go_btn:setEnabled(false);
                    -- game_util:setCCControlButtonTitle(m_go_btn,"完成");
                    -- game_util:setCCControlButtonBackground(m_go_btn,"public_enniu_hui.png");
                    m_go_btn:setVisible(false);
                    m_finish_label:setVisible(true)
                else
                    -- m_go_btn:setEnabled(true)
                    -- game_util:setCCControlButtonTitle(m_go_btn,"前往");
                    -- game_util:setCCControlButtonBackground(m_go_btn,"public_enniu.png","public_neiniu_1.png");
                    m_go_btn:setVisible(true);
                    m_finish_label:setVisible(false)
                end
            else
                bar:setCurValue(0,false);
                m_task_name_label:setString(string_helper.game_daily_task_pop.cfgError);
                m_progress_label:setString("0/0")
                m_finish_label:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_daily_task_pop.goFinishTask(self,tempId)
    if tempId == "1" then--收复任意建筑
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    elseif tempId == "2" then--为任意伙伴训练
        if not game_button_open:checkButtonOpen(501) then
            return;
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_school_new",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
    elseif tempId == "3" then--为任意伙伴升级技能
        if not game_button_open:checkButtonOpen(503) then
            return;
        end
        game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil});
    elseif tempId == "4" then--为任意伙伴改造属性
        if not game_button_open:checkButtonOpen(509) then
            return;
        end
        game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData});
    elseif tempId == "5" then--强化任意装备
        if not game_button_open:checkButtonOpen(602) then
            return;
        end
        game_scene:enterGameUi("equipment_strengthen",{gameData = nil});
    elseif tempId == "6" then--在竞技场中获胜
        if not game_button_open:checkButtonOpen(200) then
            return;
        end
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
    elseif tempId == "7" or tempId == "8" or tempId == "9" or tempId == "10" then--参与进击的巨人
        game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
    -- elseif tempId == "8" then--参与资源争夺战

    -- elseif tempId == "9" then--参与马上有经验

    -- elseif tempId == "10" then--参与生存大考验

    end
end

--[[--
    刷新
]]
function game_daily_task_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function game_daily_task_pop.refreshUi(self)
    self:refreshTableView();
    local diaryscore = self.m_tGameData.diaryscore or 0
    local tempValue = 20;
    if diaryscore >= 20 and diaryscore < 50 then
        tempValue = 50
    elseif diaryscore >= 50 and diaryscore < 80 then
        tempValue = 80
    elseif diaryscore >= 80 then
        tempValue = 100;
    end
    local leftVale = tempValue - diaryscore
    self.m_task_story_label:setString(string.format(string_helper.game_daily_task_pop.tips1,leftVale));
    if leftVale <= 0 then
        self.m_task_story_label:setString(string_helper.game_daily_task_pop.tips2);
    end
    self.m_activity_value:setString(diaryscore)
    local diaryscore_done = self.m_tGameData.diaryscore_done or {};
    self.m_progress_bar:setCurValue(diaryscore,false);
    for i=1,4 do
        local boxAnim = self.m_stageTab[i].boxAnim
        self.m_stageTab[i].openFlag = false;
        local scoreValue = tonumber(rewardScoreTab[i])
        local tempFlag = game_util:valueInTeam(scoreValue,diaryscore_done)
        if tempFlag == true then
            if boxAnim then
                boxAnim:playSection("daiji3")
            end
        else
            if diaryscore >= scoreValue then
                boxAnim:playSection("daiji2")
                self.m_stageTab[i].openFlag = true;
            else
                boxAnim:playSection("daiji1")
            end
        end
    end
end


--[[
    合并日常和任务
]]



--[[--
    初始化
]]
function game_daily_task_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_stageTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_daily_task_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    if self.m_tGameData then
        self:refreshUi();
    end
    return self.m_popUi;
end

return game_daily_task_pop;