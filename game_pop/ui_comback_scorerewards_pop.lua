---  王者归来 总积分奖励列表
cclog2 = cclog2 or function() end
local ui_comback_scorerewards_pop = {
    m_list_view_bg = nil,
    m_label_norewars = nil,
    m_callBack = nil,
};
--[[--
    销毁ui
]]
function ui_comback_scorerewards_pop.destroy(self)
    -- body
    cclog("----------------- ui_comback_scorerewards_pop destroy-----------------"); 
    self.m_list_view_bg = nil;
    self.m_label_norewars = nil;
    self.m_callBack= nil;
end
--[[--
    返回
]]
function ui_comback_scorerewards_pop.back(self,backType)
    game_scene:removePopByName("ui_comback_scorerewards_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_comback_scorerewards_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            if type(self.m_callBack) == "function" then
                self.m_callBack( function ()  self:back()  end)
            end
        elseif btnTag == 2 then  -- 进入本层

        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_comeback_getrewardlist_pop.ccbi");
    
    self.m_label_norewars = ccbNode:labelTTFForName("m_label_norewars")
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_list_view_bg:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_list_view_bg:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    m_root_layer:setTouchEnabled(true);

    -- 重置按钮出米优先级 防止被阻止
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);


    return ccbNode;
end


--[[
    创建横奖励列表
]]
function ui_comback_scorerewards_pop.createTableView( self, viewSize )
    local showData = self.m_tReward

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod(tag,gameData)
            if gameData then
                self:refreshData(gameData)
                self:refreshUi()
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("gift"));
            end
        end
        local params = {}
        params.sort = btnTag
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_reward_total"), http_request_method.GET, params,"king_get_reward_total")
    end
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3 ;
    params.column = 1; --列
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-8;
    params.direction = kCCScrollViewDirectionVertical;    --横向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_comeback_getreward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local m_node_mask = ccbNode:nodeForName("m_node_mask")
                local m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")
                local m_node_progress = ccbNode:nodeForName("m_node_progress")
                local m_label_costinfo = ccbNode:labelTTFForName("m_label_costinfo")
                local btn_go = ccbNode:controlButtonForName("btn_go")
                local m_sprite_aleradyget = ccbNode:nodeForName("m_sprite_aleradyget")
                local m_sprite_jinxingzhong = ccbNode:nodeForName("m_sprite_jinxingzhong")
                local m_sca9spir_background = ccbNode:scale9SpriteForName("m_sca9spir_background")
                local itemData = showData[index + 1]
                -- 创建奖励
                local reward = itemData.reward
                -- cclog2(reward, "reward  ====  ")
                m_node_rewardboard:removeAllChildrenWithCleanup(true)
                self:createHorRewardTableView(m_node_rewardboard, reward)

                -- 条件
                m_label_costinfo:setString(tostring(itemData.des or ""))


                -- 充值奖励嫉妒条
                local score = self.m_gameData.total_charge_score

                local maxScore = itemData.charge_num
                m_node_progress:removeAllChildrenWithCleanup(true)
                local bar = ExtProgressTime:createWithFrameName("ui_comeback_JINDUITIAO1.png","ui_comeback_JINDUITIAO1.png");
                bar:setMaxValue(maxScore);
                bar:setCurValue(score ,false);
                m_node_progress:addChild(bar)

                -- 领奖按钮
                btn_go:removeAllChildrenWithCleanup(true)
                if score >= itemData.charge_num then
                    if game_util:valueInTeam( itemData.only_sort, self.m_gameData.finished_total_reward ) then
                        m_sprite_aleradyget:setVisible(true)
                        btn_go:setVisible(false)
                    else
                        m_sprite_aleradyget:setVisible(false)
                        btn_go:setVisible(true)
                        btn_go:setTag(itemData.only_sort)

                        game_util:setCCControlButtonBackground(btn_go,"award_btn_get.png")
                        game_util:createPulseAnmi("award_btn_get.png",btn_go)
                    end
                    m_sprite_jinxingzhong:setVisible(false)
                else
                    m_sprite_aleradyget:setVisible(false)
                    btn_go:setVisible(false)
                    m_sprite_jinxingzhong:setVisible(true)
                end
                -- 条件是否达成
                local isValid = ( score >= itemData.charge_num)
                if isValid then
                    m_sca9spir_background:setColor(ccc3(255,255,255))
                else
                    m_sca9spir_background:setColor(ccc3(155,155,155))
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
    end

    local tableView =  TableViewHelper:create(params);
    if params.totalItem > 0 then
        self.m_label_norewars:setVisible(false)
    else
        self.m_label_norewars:setVisible(true)
    end
    return tableView
end

--[[
    检查奖励是被领取过
]]
function ui_comback_scorerewards_pop.rewardStuate( self, rewardId )
    for k,v in pairs(self.m_gameData.finished_total_reward) do
        if tostring(v) == tostring(rewardId) then
            return true
        end
    end
    return false
end

--[[
    创建横奖励列表
]]
function ui_comback_scorerewards_pop.createHorRewardTableView( self, viewBoard, rewardList )
    if not rewardList then return end
    local showData = rewardList
    local viewSize = viewBoard:getContentSize()
    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.15)
    leftArrow:setPosition(ccp(-5,viewSize.height*0.5));
    viewBoard:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.15)
    rightArrow:setPosition(ccp(viewSize.width + 5,viewSize.height*0.5));
    viewBoard:addChild(rightArrow)

    leftArrow:setVisible(false)
    rightArrow:setVisible(false)
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3; --列
    if tempCount < params.column then math.max(params.column - 1, 1) end
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-8;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    params.showPoint = false
    params.showPageIndex = 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)

                if icon and count then
                    countStr = "×" .. tostring(count)
                    local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5,0.5))
                    label_count:setPosition(ccp(0,-20))
                    node:addChild(label_count,20)
                end
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showData[index + 1]
            if itemData then
                game_util:lookItemDetal( itemData )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        if curPage == 1 then
            leftArrow:setVisible(false)
        else
            leftArrow:setVisible(true)
        end
        if curPage < totalPage then
            rightArrow:setVisible(true)
        else
            rightArrow:setVisible(false)
        end
    end
    local tableView =  TableViewHelper:createGallery2(params);
    if tableView then
        if params.totalItem <= params.column then
            tableView:setTouchEnabled(false)
        end
        viewBoard:addChild(tableView)
    end
end



--[[--
    刷新ui
]]
function ui_comback_scorerewards_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView( self.m_list_view_bg:getContentSize() )
    if tableView then
        self.m_list_view_bg:addChild(tableView)
    end
end



--[[
    格式化数据
]]
function ui_comback_scorerewards_pop.formatData( self )
    self.m_tReward = {}
    local recall_reward_cfg = getConfig(game_config_field.recall_reward)
    local rewardInfo = recall_reward_cfg and json.decode(recall_reward_cfg:getFormatBuffer()) or {}
    local count = recall_reward_cfg:getNodeCount()
    for i = 1, count do
        local itemCfg = recall_reward_cfg:getNodeAt(i - 1)
        local info = itemCfg and json.decode(itemCfg:getFormatBuffer()) or nil
        if info then
            info.only_sort = tonumber(itemCfg:getKey()) or i
            table.insert( self.m_tReward, info)
        end
    end
    local sortFun = function ( data1, data2 )
        return data1.only_sort < data2.only_sort
    end
    table.sort(self.m_tReward, sortFun)
end

--[[
    刷新数据
]]
function ui_comback_scorerewards_pop.refreshData( self, gameData )
    local data = gameData and gameData:getNodeWithKey("data")
    local tempData = data and json.decode(data:getFormatBuffer()) or {}
    if tempData.finished_total_reward then
        self.m_gameData.finished_total_reward = tempData.finished_total_reward
    end
    if tempData.total_charge_score then
        self.m_gameData.total_charge_score = tempData.total_charge_score
    end
end

--[[--
    初始化
]]
function ui_comback_scorerewards_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_callBack = t_params.callBack
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self:formatData()
end
--[[--
    创建ui入口并初始化数据
]]
function ui_comback_scorerewards_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_comback_scorerewards_pop;
