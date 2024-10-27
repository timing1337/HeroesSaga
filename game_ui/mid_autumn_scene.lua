---  中秋活动: 明月有礼

local mid_autumn_scene = {
    m_tGameData = nil,
    m_reward_table_node = nil,
    m_intimacy_label = nil,
    m_ccbNode = nil,
    m_left_time_node = nil,
    m_screenShoot = nil,
    m_detail_scroll_view = nil,
    m_detail_label = nil,
    m_info_label = nil,
    m_anim_node = nil,
    m_mid_autumn_anim = nil,
    m_item_name_label = nil,
};

--[[--
    销毁ui
]]
function mid_autumn_scene.destroy(self)
    -- body
    cclog("-----------------mid_autumn_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_reward_table_node = nil;
    self.m_intimacy_label = nil;
    self.m_ccbNode = nil;
    self.m_left_time_node = nil;
    self.m_screenShoot = nil;
    self.m_detail_scroll_view = nil;
    self.m_detail_label = nil;
    self.m_info_label = nil;
    self.m_anim_node = nil;
    self.m_mid_autumn_anim = nil;
    self.m_item_name_label = nil;
end

local moonAnimNameTab = {"impact","impact","impact1","impact1","impact2","impact2","impact2","impact3"}

--[[--
    返回
]]
function mid_autumn_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function mid_autumn_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 103 then--团购
            local screenShoot = game_util:createScreenShoot();
            screenShoot:retain();
           local function responseMethod(tag,gameData)
                if gameData then
                    game_scene:enterGameUi("mid_autumn_group_buy_scene",{gameData = gameData,screenShoot = screenShoot});
                end
                screenShoot:release();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_group_active_index"), http_request_method.GET, nil,"active_group_active_index",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_mid_autumn.ccbi");
    self.m_reward_table_node = ccbNode:nodeForName("m_reward_table_node")
    self.m_intimacy_label = ccbNode:labelBMFontForName("m_intimacy_label")
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
    self.m_detail_scroll_view = ccbNode:scrollViewForName("m_detail_scroll_view")
    self.m_info_label = ccbNode:labelTTFForName("m_info_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    local title161 = ccbNode:labelTTFForName("title161");
    title161:setString(string_helper.ccb.title161);
    self.m_item_name_label = ccbNode:labelTTFForName("m_item_name_label")
    self.m_item_name_label:setString(string_helper.mid_autumn_scene.detail)

    local tempAnim = game_util:createUniversalAnim({animFile = "anim_zhongqiujie",rhythm = 1.0,loopFlag = true,animCallFunc = nil});
    if tempAnim then
        self.m_anim_node:addChild(tempAnim)
        self.m_mid_autumn_anim = tempAnim;
    end
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end

    local tips_label = ccbNode:labelTTFForName("tips_label")
    tips_label:setString(string_helper.mid_autumn_scene.tips)
    return ccbNode;
end

--[[
    创建奖励列表
]]
function mid_autumn_scene.createRewardTabelView(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    if tempCount < 4 then
        params.column = tempCount; --列
    else
        params.column = 4; --列
    end
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = tostring(name) .. "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.1))
                tempLabel:setDimensions(CCSizeMake(50,25))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

function mid_autumn_scene.refreshRewardTabelView(self,rewardTab)
    self.m_reward_table_node:removeAllChildrenWithCleanup(true);
    local tempRewardTable = self:createRewardTabelView(self.m_reward_table_node:getContentSize(),rewardTab);
    self.m_reward_table_node:addChild(tempRewardTable,1000,1000);
end

--[[
    倒计时
]]
function mid_autumn_scene.refreshLabel(self,countdownTime)
    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    local countdownTime = self.m_tGameData.remainder_time or 0;
    local function timeEndFunc()
       self.m_left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.mid_autumn_scene.out,color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(tipsLabel,10,12)
    end
    
    if countdownTime > 0 then
        local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(countdownLabel,10,10)
    else
        timeEndFunc();
    end
    self.m_detail_scroll_view:getContainer():removeAllChildrenWithCleanup(true);
    -- 活动详情
    local activeCfg = getConfig(game_config_field.group_version)
    local itemCfg = activeCfg and activeCfg:getNodeWithKey(tostring(self.m_tGameData.version))
    local active_msg = itemCfg and itemCfg:getNodeWithKey("notice_2") and itemCfg:getNodeWithKey("notice_2"):toStr() or ""
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "128" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local viewSize = self.m_detail_scroll_view:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_detail_scroll_view:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_detail_scroll_view:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_detail_scroll_view:addChild(tempLabel)
    self.m_detail_label = tempLabel;
end

--[[--
    刷新ui
]]
function mid_autumn_scene.refreshUi(self)
    self:refreshLabel();
    local rewardTab = {};
    local group_score_cfg = getConfig(game_config_field.group_score)
    local item_cfg = group_score_cfg:getNodeWithKey(tostring(self.m_tGameData.version))
    local score = self.m_tGameData.score or 0
    local user_score = self.m_tGameData.user_score or 0
    local rank = self.m_tGameData.rank or 0

    if item_cfg then
        rewardTab = json.decode(item_cfg:getNodeWithKey("reward"):getFormatBuffer()) or {}
        local maxScore = item_cfg:getNodeWithKey("score"):toInt();
        self.m_intimacy_label:setString(tostring(score) .. "/" .. tostring(maxScore))
        self.m_info_label:setString(string_helper.mid_autumn_scene.my_intimary .. tostring(user_score) .. string_helper.mid_autumn_scene.my_autumn .. tostring(rank));
        if self.m_mid_autumn_anim then
            local tempIndex = math.min(math.max(1,math.floor(8*score/maxScore)),8)
            if moonAnimNameTab[tempIndex] then
                self.m_mid_autumn_anim:playSection(moonAnimNameTab[tempIndex]);
            end
        end
    end
    self:refreshRewardTabelView(rewardTab);
end

--[[--
    初始化
]]
function mid_autumn_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_screenShoot = t_params.screenShoot;
end


--[[--
    创建ui入口并初始化数据
]]
function mid_autumn_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return mid_autumn_scene;