--- 月充值奖励

local game_month_gift_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_table_view = nil,
    m_tParams = nil,
    m_isBeganIn = nil,
    m_table_data = nil,
    get_day = nil,
};
--[[--
    销毁
]]
function game_month_gift_pop.destroy(self)
    -- body
    cclog("-----------------game_month_gift_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_table_view = nil;
    self.m_tParams = nil;
    self.m_isBeganIn = nil;
    self.m_table_data = nil;
    self.get_day = nil;
end
--[[--
    返回
]]
function game_month_gift_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
 -- self:destroy();
    game_scene:removePopByName("game_month_gift_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_month_gift_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 or btnTag == 12 or btnTag == 13 then--
            if self.m_tParams.m_showType == 1 then
                self:auto_add(btnTag - 10);
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_month_gift.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_table_view = ccbNode:nodeForName("table_node")
    cclog("self.m_table_view = " .. tostring(self.m_table_view))
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            self.m_isBeganIn = self.m_table_view:boundingBox():containsPoint(realPos)
            return true;
        elseif eventType == "ended" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            local isEndIn = self.m_table_view:boundingBox():containsPoint(realPos)
            if isEndIn == false and self.m_isBeganIn == false then
               self:back()
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog("award_data =="..data:getFormatBuffer())
        local month_award = data:getNodeWithKey("month_award");
        local reward_data = month_award:getNodeWithKey("reward");
        self.get_day = month_award:getNodeWithKey("days"):toInt()

        self.m_table_data = {}
        if reward_data:getNodeCount() > 0 then
            local testTable = json.decode(reward_data:getFormatBuffer());
            for i=1,reward_data:getNodeCount() do
                local testData = reward_data:getNodeAt(i-1);
                local award = testData:getNodeWithKey("award");
                local awardBuff = json.decode(award:getFormatBuffer());
                table.insert(self.m_table_data,awardBuff);
            end
        else
            local localMonthAward = getConfig("month_award")
            local testTable = json.encode(localMonthAward:getFormatBuffer());
            for i=1,localMonthAward:getNodeCount() do
                local testData = localMonthAward:getNodeAt(i-1);
                local award = testData:getNodeWithKey("award");
                local awardBuff = json.decode(award:getFormatBuffer());
                table.insert(self.m_table_data,awardBuff);
            end
        end
        self:refreshUi()
    end
    -- 联网取数据
    local function netForReward()
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pay_award_index"), http_request_method.GET, nil,"pay_award_index")
    end
    netForReward()
    return ccbNode;
end

--[[--
]]
function game_month_gift_pop.createTableView(self,viewSize)
    local cardsCount = 20;
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = cardsCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/month_gift_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0,0))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local day_label = ccbNode:labelTTFForName("day_label")
            local get_sprite = ccbNode:spriteForName("get_sprite")

            if index < self.get_day then
                get_sprite:setVisible(true)
            else
                get_sprite:setVisible(false)
            end
            local item_node = {} 
            local count_label = {}
            -- if self.m_table_data ~= nil then
                local dayReward = self.m_table_data[index+1];
            -- end
            local rewardCout = #dayReward;
            for i=1,4 do
                item_node[i] = ccbNode:nodeForName("item_node"..i)
                count_label[i] = ccbNode:labelTTFForName("count_label"..i)
                if i <= rewardCout then 
                    local itemData = dayReward[i]
                    local icon,name,count = game_util:getRewardByItemTable(itemData,true);
                    icon:setScale(0.7)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    local iconSize = icon:getContentSize()
                    icon:setPosition(ccp(iconSize.width*0.5*0.7,iconSize.height*0.5*0.7))
                    item_node[i]:removeAllChildrenWithCleanup(true);
                    item_node[i]:addChild(icon)
                    count_label[i]:setString("×"..count)
                    if rewardCout == 2 then
                        item_node[i]:setPosition(ccp(20+i*80,27));
                        count_label[i]:setPosition(ccp(20+i*80,6));
                    elseif rewardCout == 3 then
                        item_node[i]:setPosition(ccp(-40+i*80,27));
                        count_label[i]:setPosition(ccp(-40+i*80,6));
                    end
                else
                    item_node[i]:setVisible(false);
                    count_label[i]:setVisible(false);
                end
            end
            day_label:setString(string_helper.game_month_gift_pop.di..(index+1)..string_helper.game_month_gift_pop.day)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)        
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_month_gift_pop.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false)
    self.m_table_view:addChild(tableViewTemp,10,10);
    if self.get_day > 0 then
        game_util:setTableViewIndex(self.get_day-1,self.m_table_view,10,3)
    end
end

--[[--
    初始化
]]
function game_month_gift_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
end
--[[
    创建icon图片
]]--
function game_month_gift_pop.createGiftIconByName(self,iconName)
    local iconTmp = game_util:createIconByName(iconName)
    return iconTmp;
end
--[[--
    创建ui入口并初始化数据
]]
function game_month_gift_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    -- self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_month_gift_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_month_gift_pop;