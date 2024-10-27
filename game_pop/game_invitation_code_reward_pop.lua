---  邀请码奖励

local game_invitation_code_reward_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_ok_btn = nil,
    m_title_label = nil,
    m_reward_icon = nil,
    m_openType = nil,
    m_callBackFunc = nil,
    m_rewardFlag = nil,
};
--[[--
    销毁ui
]]
function game_invitation_code_reward_pop.destroy(self)
    -- body
    cclog("----------------- game_invitation_code_reward_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_ok_btn = nil;
    self.m_title_label = nil;
    self.m_reward_icon = nil;
    self.m_openType = nil;
    self.m_callBackFunc = nil;
    self.m_rewardFlag = nil;
end
--[[--
    返回
]]
function game_invitation_code_reward_pop.back(self,backType)
    game_scene:removePopByName("game_invitation_code_reward_pop");
end
--[[--
    读取ccbi创建ui
    icon_box4.png
]]
function game_invitation_code_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then--
            if self.m_rewardFlag == false then
                self:back()
                return;
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                local request_code = data:getNodeWithKey("request_code")
                game_util:rewardTipsByJsonData(reward);
                if self.m_callBackFunc then
                    self.m_callBackFunc(json.decode(request_code:getFormatBuffer()));
                end
                self:back();
            end
            --领取奖励 tp=master&slave=h1993  tp :  master/slave  # 师傅奖励/徒弟奖励  slave: 如果tp为slave  需传递徒弟uid
            local params = {}
            if self.m_openType == 1 then--导师奖励
                params.tp = "master"
                params.slave = nil;
            else--徒弟奖励
                params.tp = "slave"
                params.slave = self.m_tGameData.uid
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_request_code_gift"), http_request_method.GET, params,"user_request_code_gift")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_invitation_code_reward.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    local title197 = ccbNode:labelTTFForName("title197");
    title197:setString(string_helper.ccb.title197);
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title198);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_reward_icon = ccbNode:spriteForName("m_reward_icon")

    local qualityTab = HERO_QUALITY_COLOR_TABLE[5];
    if self.m_reward_icon and qualityTab then
        local tempIconSize = self.m_reward_icon:getContentSize();
        local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
        img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        self.m_reward_icon:addChild(img1,-1,-1)
        local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
        img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        self.m_reward_icon:addChild(img2,1,1)
    end

    return ccbNode;
end

--[[--
    创建列表
]]
function game_invitation_code_reward_pop.createTableView(self,viewSize)
    local rewardTab = self:getReward();
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
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
    
]]
function game_invitation_code_reward_pop.getReward(self)
    local request_code_cfg = getConfig(game_config_field.request_code)
    -- cclog("request_code_cfg ==" .. request_code_cfg:getFormatBuffer())
    local level = 1;
    if self.m_openType == 1 then
        level = game_data:getUserStatusDataByKey("level") or 1;
    else
        level = self.m_tGameData.level or 1;
    end
    local gift = self.m_tGameData.gift or {}
    local rewardTab = {}
    if #gift > 0 then
        self.m_title_label:setString(string_helper.game_invitation_code_reward_pop.get);
        local requestId = tostring(gift[1])
        local request_item_cfg = request_code_cfg:getNodeWithKey(requestId)
        cclog("requestId ========== " .. requestId .. " ;request_item_cfg = " .. tostring(request_item_cfg) )
        if request_item_cfg then
            if self.m_openType == 1 then--导师奖励
                local player = request_item_cfg:getNodeWithKey("player")
                rewardTab = json.decode(player:getFormatBuffer()) or {}
            else--徒弟奖励
                local quest = request_item_cfg:getNodeWithKey("quest")
                rewardTab = json.decode(quest:getFormatBuffer()) or {}
            end
        end
    else
        self.m_rewardFlag = false;
        local requestId = "-1"
        local tempCount = request_code_cfg:getNodeCount();
        for i=1,tempCount do
            local tempItem = request_code_cfg:getNodeAt(i - 1);
            local tempLevel = tempItem:getNodeWithKey("level")
            local level1 = tempLevel:getNodeAt(0):toInt();
            local level2 = tempLevel:getNodeAt(1):toInt();
            if level >= level1 and level <= level2 then
                requestId = tostring(tonumber(tempItem:getKey()) + 1)
                break;
            end
        end
        local request_item_cfg = request_code_cfg:getNodeWithKey(requestId)
        cclog("requestId ========== " .. requestId .. " ;request_item_cfg = " .. tostring(request_item_cfg))
        if request_item_cfg then
            if self.m_openType == 1 then--导师奖励 
                local player = request_item_cfg:getNodeWithKey("player")
                rewardTab = json.decode(player:getFormatBuffer()) or {}
            else
                local quest = request_item_cfg:getNodeWithKey("quest")
                rewardTab = json.decode(quest:getFormatBuffer()) or {}
            end
            local tempLevel = request_item_cfg:getNodeWithKey("level")
            local level1 = tempLevel:getNodeAt(0):toInt();
            self.m_title_label:setString(level1 .. string_helper.game_invitation_code_reward_pop.openlevel);
        else
            self.m_title_label:setString(string_helper.game_invitation_code_reward_pop.getOver);
        end
    end
    return rewardTab;
end

--[[--
    刷新
]]
function game_invitation_code_reward_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function game_invitation_code_reward_pop.refreshUi(self)
    self:refreshTableView();
end
--[[--
    初始化
]]
function game_invitation_code_reward_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_tGameData = t_params.gameData or {};
    local gift = self.m_tGameData.gift or {}
    table.sort(gift,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    cclog("json.encode(self.m_tGameData)===== " .. json.encode(self.m_tGameData))
    self.m_openType = t_params.openType or 1;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_rewardFlag = true;
end
--[[--
    创建ui入口并初始化数据
]]
function game_invitation_code_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_invitation_code_reward_pop;
