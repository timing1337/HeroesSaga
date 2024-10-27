---  任务 

local game_task_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_tab_node_1 = nil,
    m_tab_node_2_3 = nil,
    m_tab_node_4 = nil,
    m_close_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_tab_btn_4 = nil,
    m_showIndex = nil,
    m_tDailyTaskData = nil,
    m_tMainTaskData = nil,
    m_tCodeData = nil,
    m_CodeId = nil,
    m_editBox = nil,
    m_progress_rate_label = nil,
    m_daily_layer = nil,
    m_receive_bg = nil,
    m_selListItem = nil,
    m_dailyAwardInit = nil,
    m_search_btn = nil,
    m_edit_bg_node = nil,
    m_search_list_view_bg = nil,
    m_codeId = nil,
};

--[[--
    销毁
]]
function game_task_pop.destroy(self)
    -- body
    cclog("-----------------game_task_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_tab_node_1 = nil;
    self.m_tab_node_2_3 = nil;
    self.m_tab_node_4 = nil;
    self.m_close_btn = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_tab_btn_4 = nil;
    self.m_showIndex = nil;
    self.m_tDailyTaskData = nil;
    self.m_tMainTaskData = nil;
    self.m_tCodeData = nil;
    self.m_CodeId = nil;
    self.m_editBox = nil;
    self.m_progress_rate_label = nil;
    self.m_daily_layer = nil;
    self.m_receive_bg = nil;
    self.m_selListItem = nil;
    self.m_dailyAwardInit = nil;
    self.m_search_btn = nil;
    self.m_edit_bg_node = nil;
    self.m_search_list_view_bg = nil;
    self.m_codeId = nil;
end
--[[--
    返回
]]
function game_task_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_task_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_task_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 or btnTag == 3 or btnTag == 4 or btnTag == 5 then--
            self.m_showIndex = btnTag - 1;
            self:refreshTabBtn();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    
    ccbNode:openCCBFile("ccb/ui_task_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_tab_node_2_3 = ccbNode:nodeForName("m_tab_node_2_3")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    game_util:setCCControlButtonTitle(self.m_tab_btn_2,string_helper.ccb.title56);
    game_util:setCCControlButtonTitle(self.m_tab_btn_3,string_helper.ccb.title57);
    self.m_progress_rate_label = ccbNode:labelTTFForName("m_progress_rate_label");
    self.m_progress_rate_label = ccbNode:labelTTFForName("m_progress_rate_label");
    
    -- self.m_tab_btn_2:setHighlighted(true);
    
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    创建奖励列表
]]
function game_task_pop.createRewardTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    

    local daily_award_cfg = getConfig(game_config_field.daily_award)
    local tGameData = game_data:getDailyAwardData();
    local score = tGameData.score;
    local reward = tGameData.reward;

    local btnFlag = true;
    local function onMainBtnClick( target,event )
        -- cclog("game_daily_pop event =============" .. event)
        if event == 2 then
            btnFlag = false;
        elseif event == 32 then
            if btnFlag then
                local tagNode = tolua.cast(target,"CCControlButton");
                local btnTag = tagNode:getTag();
                local itemCfg = daily_award_cfg:getNodeAt(btnTag);
                if game_util:valueInTeam(itemCfg:getKey(),reward) then
                    local function responseMethod(tag,gameData)
                        game_util:setCCControlButtonTitle(tagNode,string_helper.game_task_pop.get)
                        tagNode:setEnabled(false);
                        local data = gameData:getNodeWithKey("data");
                        -- game_data:setDailyAwardDataByJsonData();
                        -- game_data:updateMoreEquipDataByJsonData(data:getNodeWithKey("equip"));
                        -- game_data:updateMoreCardDataByJsonData(data:getNodeWithKey("cards"));
                        game_util:removeValueInTeam(itemCfg:getKey(),reward);
                        self:refreshUi();
                        -- game_util:addMoveTips({text = "领取成功!"});
                        game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                    end
                     --获得礼包  reward＝礼包id（可多个）
                    local params = {};
                    params.reward=itemCfg:getKey();
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_get_reward"), http_request_method.GET, params,"daily_award_get_reward")
                end
            end
            btnFlag = true;
        else
            btnFlag = true;
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_daily_reward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local m_btn = ccbNode:controlButtonForName("m_btn")
            m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            game_util:setControlButtonTitleBMFont(m_btn)
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local m_icon_spr = ccbNode:spriteForName("m_icon_spr");
                local m_top_label = ccbNode:labelTTFForName("m_top_label")
                local m_btn = ccbNode:controlButtonForName("m_btn")
                m_top_label:setString(string.format(string_helper.game_task_pop.sign,(index+1)))
                local award = itemCfg:getNodeWithKey("award")
                local awardCount = award:getNodeCount();
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelTTFForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                    else
                        local icon,name = game_util:getRewardByItem(award:getNodeAt(i-1),true);
                        if icon then
                            icon:setScale(0.3)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end                    
                end
                m_icon_spr:setOpacity(0)
                m_icon_spr:removeAllChildrenWithCleanup(true)
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                if icon then
                    local m_icon_spr_size = m_icon_spr:getContentSize();
                    icon:setPosition(ccp(m_icon_spr_size.width*0.5,m_icon_spr_size.height*0.5))
                    m_icon_spr:addChild(icon);
                end
                m_btn:setTag(index);
                if (index+1) <= score then
                    if not game_util:valueInTeam(itemCfg:getKey(),reward) then
                        m_btn:setVisible(true)
                        m_btn:setEnabled(false);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_task_pop.get)
                    else
                        m_btn:setVisible(true)
                        m_btn:setEnabled(true);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_task_pop.getReward)
                    end
                else
                    m_btn:setVisible(false)
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));

        end
    end
    return TableViewHelper:create(params);
end


--[[--
    创建每日列表
]]
function game_task_pop.createDailyTaskTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist");

    local reward_daily_cfg = getConfig(game_config_field.reward_daily);
    local tGameData = self.m_tDailyTaskData.data.result or {};
    self.m_progress_rate_label:setString(tostring(self.m_tDailyTaskData.data.done) .. "/" .. tostring(self.m_tDailyTaskData.data.length));
    cclog(" #tGameData ==============" ..  #tGameData)
    local btnFlag = true;
    local function onMainBtnClick( target,event )
        -- cclog("game_daily_pop event =============" .. event)
        if event == 2 then
            btnFlag = false;
        elseif event == 32 then
            if btnFlag then
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local itemData = tGameData[btnTag+1];
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    self.m_tDailyTaskData.init = true;
                    self.m_tDailyTaskData.data = json.decode(data:getNodeWithKey("daily"):getFormatBuffer()) or {}
                    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                    local tableViewTemp = self:createDailyTaskTableView(self.m_list_view_bg:getContentSize());
                    self.m_list_view_bg:addChild(tableViewTemp);
                    -- game_util:addMoveTips({text = "领取成功！"});
                    game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                end
                local params = {};
                params.award_id = itemData.id;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_daily_award"), http_request_method.GET, params,"reward_daily_award")
            end
            btnFlag = true;
        else
            btnFlag = true;
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_task_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_reward_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            local itemCfg = reward_daily_cfg:getNodeWithKey(tostring(itemData.id));
            if ccbNode and itemCfg then
                local m_icon_node = ccbNode:nodeForName("m_icon_node");
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_story_label = ccbNode:labelTTFForName("m_story_label")
                local m_progress_node = ccbNode:nodeForName("m_progress_node");
                local m_reward_btn = ccbNode:controlButtonForName("m_reward_btn");
                game_util:setCCControlButtonTitle(m_reward_btn,string_helper.ccb.title58)
                local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
                m_progress_node:removeAllChildrenWithCleanup(false);
                m_tips_label:setVisible(false);
                m_reward_btn:setTag(index);
                m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                m_story_label:setString(itemCfg:getNodeWithKey("story"):toStr());
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                if icon then
                    m_icon_node:removeAllChildrenWithCleanup(true);
                    m_icon_node:addChild(icon);
                end          
                if itemData.value >= itemData.need_value then
                    if itemData.status == 1 then
                        m_reward_btn:setVisible(true);
                    else
                        m_reward_btn:setVisible(false);  
                        m_tips_label:setVisible(true);  
                    end
                else
                    m_reward_btn:setVisible(false);
        
                    -- local bar = ExtProgressTime:createWithFrameName("o_public_ScheduleBg.png","o_public_ScheduleBar.png");
                    local bar = ExtProgressTime:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png");
                    bar:setAnchorPoint(ccp(1,0.5));
                    m_progress_node:addChild(bar);
                    bar:setMaxValue(math.max(1,itemData.need_value));
                    bar:setCurValue(math.max(0,itemData.value),false);
                    bar:addLabelTTF(CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,12));
                end
                local reward = itemCfg:getNodeWithKey("reward")
                local awardCount = reward:getNodeCount();
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelTTFForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                    else
                        local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                        if icon then
                            icon:setScale(0.3)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end                    
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            local px,py = cell:getPosition();
            local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
            selIndex = index;
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function game_task_pop.refreshTab2(self)
    -- self.m_tab_node_1:setVisible(false)
    self.m_tab_node_2_3:setVisible(true);
    -- self.m_tab_node_4:setVisible(false);
    if self.m_tDailyTaskData.init == false then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self.m_tDailyTaskData.init = true;
            self.m_tDailyTaskData.data = json.decode(data:getNodeWithKey("daily"):getFormatBuffer()) or {}
            self.m_tMainTaskData.init = true;
            self.m_tMainTaskData.data = json.decode(data:getNodeWithKey("once"):getFormatBuffer()) or {}
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createDailyTaskTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, nil,"reward_index")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createDailyTaskTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);
    end
end


--[[--
    创建主任务列表
]]
function game_task_pop.createMainTaskTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_vip.plist");

    local reward_once_cfg = getConfig(game_config_field.reward_once);
    local tGameData = self.m_tMainTaskData.data.result or {};
    self.m_progress_rate_label:setString(tostring(self.m_tMainTaskData.data.done) .. "/" .. tostring(self.m_tMainTaskData.data.length));
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local btnFlag = true;
    local function onMainBtnClick( target,event )
        -- cclog("game_daily_pop event =============" .. event)
        if event == 2 then
            btnFlag = false;
        elseif event == 32 then
            if btnFlag then
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                local itemData = tGameData[btnTag+1];
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    self.m_tMainTaskData.init = true;
                    self.m_tMainTaskData.data = json.decode(data:getNodeWithKey("once"):getFormatBuffer()) or {}
                    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
                    local tableViewTemp = self:createMainTaskTableView(self.m_list_view_bg:getContentSize());
                    self.m_list_view_bg:addChild(tableViewTemp);
                    -- game_util:addMoveTips({text = "领取成功！"});
                    game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                end
                local params = {};
                params.award_id = itemData.id;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_once_award"), http_request_method.GET, params,"reward_once_award")
            end
            btnFlag = true;
        else
            btnFlag = true;
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_task_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_reward_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            local itemCfg = reward_once_cfg:getNodeWithKey(tostring(itemData.id));
            if ccbNode and itemCfg then
                cclog("itemData.id ==================" .. itemData.id)
                local m_icon_node = ccbNode:nodeForName("m_icon_node");
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_story_label = ccbNode:labelTTFForName("m_story_label")
                local m_progress_node = ccbNode:nodeForName("m_progress_node");
                local m_reward_btn = ccbNode:controlButtonForName("m_reward_btn");
                local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
                m_progress_node:removeAllChildrenWithCleanup(false);
                m_tips_label:setVisible(false);
                m_reward_btn:setTag(index);
                m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                m_story_label:setString(itemCfg:getNodeWithKey("story"):toStr());
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
                if icon then
                    m_icon_node:removeAllChildrenWithCleanup(true);
                    m_icon_node:addChild(icon);
                end 
                if itemData.value >= itemData.need_value then
                    if itemData.status == 1 then
                        m_reward_btn:setVisible(true);
                    else
                        m_reward_btn:setVisible(false);   
                        m_tips_label:setVisible(true); 
                        m_tips_label:setString("已领取")
                    end
                else
                    m_reward_btn:setVisible(false);
                    -- local bar = ExtProgressTime:createWithFrameName("o_public_ScheduleBg.png","o_public_ScheduleBar.png");
                    local bar = ExtProgressTime:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png");
                    bar:setAnchorPoint(ccp(1,0.5));
                    m_progress_node:addChild(bar);
                    bar:setMaxValue(math.max(1,itemData.need_value));
                    bar:setCurValue(math.max(0,itemData.value),false);
                    bar:addLabelTTF(CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,12));
                end
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelTTFForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    m_award_label:setString("")
                end
                local reward = itemCfg:getNodeWithKey("reward")
                local awardCount = reward:getNodeCount();
                for i=1,2 do
                    local m_award_node = ccbNode:nodeForName("m_award_node_" .. i)
                    local m_award_label = ccbNode:labelTTFForName("m_award_label_" .. i)
                    m_award_node:removeAllChildrenWithCleanup(true);
                    if i > awardCount then
                        m_award_label:setString("")
                    else
                        local icon,name = game_util:getRewardByItem(reward:getNodeAt(i-1),true);
                        if icon then
                            icon:setScale(0.3)
                            m_award_node:addChild(icon)
                        end
                        if name then
                            m_award_label:setString(name)
                        end
                    end                    
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
        end
    end
    return TableViewHelper:create(params);
end


--[[--

]]
function game_task_pop.refreshTab3(self)
    -- self.m_tab_node_1:setVisible(false)
    self.m_tab_node_2_3:setVisible(true);
    -- self.m_tab_node_4:setVisible(false);
    if self.m_tMainTaskData.init == false then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self.m_tDailyTaskData.init = true;
            self.m_tDailyTaskData.data = json.decode(data:getNodeWithKey("daily"):getFormatBuffer()) or {}
            self.m_tMainTaskData.init = true;
            self.m_tMainTaskData.data = json.decode(data:getNodeWithKey("once"):getFormatBuffer()) or {}
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createMainTaskTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_index"), http_request_method.GET, nil,"reward_index")
    else
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createMainTaskTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);
    end
end

--[[--

]]
function game_task_pop.refreshTab4(self)
    -- self.m_tab_node_1:setVisible(false)
    self.m_tab_node_2_3:setVisible(false);
    -- self.m_tab_node_4:setVisible(true);
    if self.m_tCodeData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tCodeData.init = true;
            local data = gameData:getNodeWithKey("data");
            local codes = data:getNodeWithKey("codes");
            self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
            self:refreshTab4();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_index"), http_request_method.GET, nil,"code_index")
    else
        local tableViewTemp = self:createCodeTableView(self.m_search_list_view_bg:getContentSize());
        self.m_search_list_view_bg:addChild(tableViewTemp);
    end
end

--[[--

]]
function game_task_pop.refreshTabBtn(self)
    local flag1 = self.m_showIndex == 1 and true or false
    local flag2 = self.m_showIndex == 2 and true or false
    local flag3 = self.m_showIndex == 3 and true or false
    local flag4 = self.m_showIndex == 4 and true or false
    -- cclog("self.m_showIndex = " .. self.m_showIndex .. " ; flag1 = " .. tostring(flag1) .. ";flag2 = " .. tostring(flag2) .. ";flag3 = " .. tostring(flag3) .. ";flag4 = " .. tostring(flag4))
    -- self.m_tab_btn_1:setHighlighted(flag1);
    -- self.m_tab_btn_1:setEnabled(not flag1);
    self.m_tab_btn_2:setHighlighted(flag2);
    self.m_tab_btn_2:setEnabled(not flag2);
    self.m_tab_btn_3:setHighlighted(flag3);
    self.m_tab_btn_3:setEnabled(not flag3);
    -- self.m_tab_btn_4:setHighlighted(flag4);
    -- self.m_tab_btn_4:setEnabled(not flag4);

    -- self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- self.m_daily_layer:removeAllChildrenWithCleanup(true);
    -- self.m_receive_bg:removeAllChildrenWithCleanup(true);
    -- self.m_search_list_view_bg:removeAllChildrenWithCleanup(true);
    if self.m_showIndex == 1 then
        -- self:refreshTab1();
    elseif self.m_showIndex == 2 then
        -- self.m_tab_btn_2:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_biaoqian.png"),CCControlStateNormal);
        -- self.m_tab_btn_2:setTitleColorForState(ccc3(255,255,255),CCControlStateNormal)
        self:refreshTab2();
    elseif self.m_showIndex == 3 then
        -- self.m_tab_btn_3:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_biaoqian2.png"),CCControlStateNormal);
        -- self.m_tab_btn_3:setTitleColorForState(ccc3(255,255,255),CCControlStateNormal)
        self:refreshTab3();
    elseif self.m_showIndex == 4 then
        -- self:refreshTab4();
    end
end

--[[--
    刷新ui
]]
function game_task_pop.refreshUi(self)
    self:refreshTabBtn();    
end

--[[--
    初始化
]]
function game_task_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_showIndex = t_params.showIndex or 2;
    self.m_tDailyTaskData = {init = false,data = {}};
    self.m_tMainTaskData = {init = false,data = {}};
    self.m_tCodeData = {init = false,data = {}}
    self.m_dailyAwardInit = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_task_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_task_pop;