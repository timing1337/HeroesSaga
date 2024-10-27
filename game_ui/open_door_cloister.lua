--- 开门活动 回廊

local open_door_cloister = {
    m_tGameData = nil,
    m_close_btn = nil,
    m_ccbNode = nil,
    m_battle_btn = nil,
    m_record_label = nil,
    m_score_label = nil,
    m_reward_list_node_1 = nil,
    m_reward_list_node_2 = nil,
    m_scroll_view_tips = nil,
    m_battle_btn_2 = nil,
    m_battle_btn_3 = nil,
    word_tips3 = nil,
    word_tips2 = nil,
    m_detail_open_flag = nil,
};
--[[--
    销毁
]]
function open_door_cloister.destroy(self)
    -- body
    cclog("-----------------open_door_cloister destroy-----------------");
    self.m_tGameData = nil;
    self.m_close_btn = nil;
    self.m_ccbNode = nil;
    self.m_battle_btn = nil;
    self.m_record_label = nil;
    self.m_score_label = nil;
    self.m_reward_list_node_1 = nil;
    self.m_reward_list_node_2 = nil;
    self.m_scroll_view_tips = nil;
    self.m_battle_btn_2 = nil;
    self.m_battle_btn_3 = nil;
    self.word_tips3 = nil;
    self.word_tips2 = nil;
    self.m_detail_open_flag = nil;
end
--[[--
    返回
]]
function open_door_cloister.back(self,type)
    game_scene:enterGameUi("open_door_main_scene",{});
end
--[[--
    读取ccbi创建ui
]]
function open_door_cloister.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 then
            -- game_scene:addPop("game_active_limit_detail_pop",{enterType = "145"})
            if self.m_detail_open_flag == true then
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,105))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,70))
            else
                self.m_detail_msg_bg:setPreferredSize(CCSizeMake(270,250))
                self.m_scroll_view_tips:setViewSize(CCSizeMake(230,220))
            end
            self.m_detail_open_flag = not self.m_detail_open_flag;
            self:refreshActivityDetail();
        elseif btnTag == 12 or btnTag == 13 then
            local status = self.m_tGameData.status or 0   --状态0. 没有开启过, 1开启过 2再次挑战
            if status == 0 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("open_door_cloister_detail",{gameData = gameData,enterFlag = btnTag});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_start"), http_request_method.GET, nil,"maze_start")
            else
                game_scene:enterGameUi("open_door_cloister_detail",{gameData = self.m_tGameData});
            end
        elseif btnTag == 14 then--重新挑战
            local max_layer = self.m_tGameData.max_layer or 1
            game_scene:addPop("open_door_cloister_stage_sel",{max_layer = max_layer})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_door_cloister.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_battle_btn = ccbNode:controlButtonForName("m_battle_btn");
    self.m_battle_btn_2 = ccbNode:controlButtonForName("m_battle_btn_2");
    self.m_battle_btn_3 = ccbNode:controlButtonForName("m_battle_btn_3");
    self.m_scroll_view_tips = ccbNode:scrollViewForName("m_scroll_view_tips");
    self.m_record_label = ccbNode:labelTTFForName("m_record_label");
    self.m_score_label = ccbNode:labelTTFForName("m_score_label");
    self.m_reward_list_node_1 = ccbNode:nodeForName("m_reward_list_node_1");
    self.m_reward_list_node_2 = ccbNode:nodeForName("m_reward_list_node_2");
    self.word_tips3 = ccbNode:spriteForName("word_tips3")
    self.word_tips2 = ccbNode:spriteForName("word_tips2")
    self.m_scroll_view_tips:setTouchPriority(GLOBAL_TOUCH_PRIORITY + 1);
    self.m_detail_msg_bg = ccbNode:scale9SpriteForName("m_detail_msg_bg")

    local animName = "enter_anim"
    local function animCallFunc(animName)
        ccbNode:runAnimations(animName)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    创建列表
]]
function open_door_cloister.createRewardTableView(self,viewSize)
    -- local showData = {{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000}}
    local showData = self.m_tGameData.daily_reward or {}
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #showData
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    if #showData == 0 then--显示一个提示
        self.word_tips2:setVisible(true)
    else
        self.word_tips2:setVisible(false)
    end
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建奖励列表
]]
function open_door_cloister.createRankRewardTableView(self,viewSize)
    local rewardCfg = getConfig(game_config_field.maze_top_reward)
    local myRank = self.m_tGameData.max_rank
    local showData = {}
    if myRank == 0 or myRank > 100 then
        self.word_tips3:setVisible(true)
    else
        self.word_tips3:setVisible(false)
        local itemCfg = rewardCfg:getNodeWithKey(tostring(myRank))
        showData = json.decode(itemCfg:getNodeWithKey("reward"):getFormatBuffer())
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.2))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function open_door_cloister.refreshActivityDetail(self)
    self.m_scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true)
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "145" )
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.open_door_cloister.activity_wonderful
    local viewSize = self.m_scroll_view_tips:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(121,236,236),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scroll_view_tips:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view_tips:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scroll_view_tips:addChild(tempLabel)
end


--[[--
    刷新ui
]]
function open_door_cloister.refreshUi(self)
    self:refreshActivityDetail();
    self.m_reward_list_node_1:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTableView(self.m_reward_list_node_1:getContentSize());
    self.m_reward_list_node_1:addChild(tableViewTemp);
    self.m_reward_list_node_2:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRankRewardTableView(self.m_reward_list_node_2:getContentSize());
    self.m_reward_list_node_2:addChild(tableViewTemp)
    local max_layer = self.m_tGameData.max_layer or 1
    self.m_record_label:setString(tostring(max_layer) .. string_helper.open_door_cloister.cen);
    local max_score = self.m_tGameData.max_score or 0
    self.m_score_label:setString(tostring(max_score));
    local status = self.m_tGameData.status or 0   --状态0. 没有开启过, 1开启过 

    if status == 0 then
        self.m_battle_btn:setVisible(true);
        self.m_battle_btn_2:setVisible(false);
        self.m_battle_btn_3:setVisible(false);
    else
        self.m_battle_btn:setVisible(false);
        self.m_battle_btn_2:setVisible(true);
        self.m_battle_btn_3:setVisible(true);
    end
end

--[[--
    初始化
]]
function open_door_cloister.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_detail_open_flag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_cloister.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return open_door_cloister;