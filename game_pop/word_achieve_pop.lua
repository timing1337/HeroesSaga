---  世界成就奖励

local word_achieve_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_progress_bar_bg = nil,
    m_progress_label = nil,
    m_ok_btn = nil,
    m_progress_bar = nil,
    m_rewardLevel = nil,
    m_level_label = nil,
    m_finish_label = nil,
};
--[[--
    销毁ui
]]
function word_achieve_pop.destroy(self)
    -- body
    cclog("----------------- word_achieve_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_progress_bar_bg = nil;
    self.m_progress_label = nil;
    self.m_ok_btn = nil;
    self.m_progress_bar = nil;
    self.m_rewardLevel = nil;
    self.m_level_label = nil;
    self.m_finish_label = nil;
end
--[[--
    返回
]]
function word_achieve_pop.back(self,backType)
    game_scene:removePopByName("word_achieve_pop");
end
--[[--
    读取ccbi创建ui
]]
function word_achieve_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then--领取奖励
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local tempData = json.decode(data:getFormatBuffer()) or {};
                self.m_tGameData.world_score = tempData.world_score;
                self.m_tGameData.world_level = tempData.world_level;
                self.m_tGameData.world_reward_log = tempData.world_reward_log;
                game_util:rewardTipsByDataTable(tempData.reward);
                self:refreshUi();
            end
            local params = {}
            params.level = self.m_rewardLevel;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_get_world_reward"), http_request_method.GET, params,"private_city_get_world_reward")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_word_achieve_pop.ccbi");
    -- 光效 显示
    local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    local title6 = ccbNode:labelTTFForName("title6");
    title6:setString(string_helper.ccb.title6);

    self.m_progress_bar_bg = ccbNode:nodeForName("m_progress_bar_bg")
    self.m_progress_label = ccbNode:labelBMFontForName("m_progress_label")
    self.m_finish_label = ccbNode:labelBMFontForName("m_finish_label")
    self.m_finish_label:setVisible(false);
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title7)
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local barSize = self.m_progress_bar_bg:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("sjdt_sf_jindutiao_1.png","sjdt_sf_jindutiao.png")
    bar:setAnchorPoint(ccp(0, 0))
    bar:setCurValue(0,false);
    self.m_progress_bar_bg:addChild(bar);
    self.m_progress_bar = bar;

    return ccbNode;
end

--[[--
    创建列表
]]
function word_achieve_pop.createTableView(self,viewSize)
    local rewardTab = {};
    local world_reward_log = self.m_tGameData.world_reward_log  or {};
    table.sort(world_reward_log,function(data1,data2) return data1 < data2 end);
    -- table.foreach(world_reward_log,print)
    local integration_world_cfg = getConfig(game_config_field.integration_world)
    local tempCount = integration_world_cfg:getNodeCount();
    self.m_rewardLevel = #world_reward_log + 1;
    if self.m_rewardLevel <= tempCount then
        local item_cfg = integration_world_cfg:getNodeWithKey(tostring(self.m_rewardLevel));
        if item_cfg then
            local world_reward = item_cfg:getNodeWithKey("reward")
            rewardTab = json.decode(world_reward:getFormatBuffer()) or {}
        end
    else
        self.m_finish_label:setVisible(true);
        self.m_ok_btn:setVisible(false);
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],true)
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
                cell:addChild(icon)
            end
            if name then
                local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1]);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function word_achieve_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function word_achieve_pop.refreshUi(self)
    local world_level = self.m_tGameData.world_level or 1;
    local world_score = self.m_tGameData.world_score or 0;
    local integration_world_cfg = getConfig(game_config_field.integration_world)
    local item_cfg = integration_world_cfg:getNodeWithKey(tostring(world_level));
    if item_cfg then
        -- cclog(item_cfg:getFormatBuffer())
        local maxScore = item_cfg:getNodeWithKey("top"):toInt();
        maxScore = maxScore == 0 and 100 or maxScore;
        self.m_progress_bar:setMaxValue(maxScore);
        self.m_progress_bar:setCurValue(world_score,false);
        self.m_progress_label:setString(string.format("%0.0f",100*math.min(maxScore,world_score)/maxScore) .. "%");
    end
    self.m_level_label:setString("Lv." .. world_level)
    self:refreshTableView();
end
--[[--
    初始化
]]
function word_achieve_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function word_achieve_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return word_achieve_pop;
