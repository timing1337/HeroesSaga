--- 火焰杯 我的契约

local ui_firecup_minereward_pop = {
    m_node_lucknum_board = nil,     -- 奖励列表底板
    m_contractList = nil,
    m_cur_showType = nil,
    m_controlBtns = nil,
    m_scale9_select = nil,
    m_page_sort_count = nil,
    m_curPage_info = nil,
    m_lastListPos = nil,
    m_tableView = nil,
};
--[[--
    销毁
]]
function ui_firecup_minereward_pop.destroy(self)
    -- body
    cclog("-----------------ui_firecup_minereward_pop destroy-----------------");
    self.m_node_lucknum_board = nil;
    self.m_contractList = nil;
    self.m_cur_showType = nil;
    self.m_controlBtns = nil;
    self.m_scale9_select = nil;
    self.page_sort_count = nil;
    self.m_curPage_info = nil;
    self.m_lastListPos = nil;
    self.m_tableView = nil;
end
--[[--
    返回
]]
function ui_firecup_minereward_pop.back(self,type)
    game_scene:removePopByName("ui_firecup_minereward_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_firecup_minereward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "ui_firecup_minereward_pop   btnTag   =====   ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then
            if self.m_tableView then
                self.m_lastListPos[tostring(self.m_cur_showType)] = self.m_tableView:getContentSize().height + self.m_tableView:getContentOffset().y
            end
            self.m_cur_showType = 1
            self:refreshUi()
        elseif btnTag == 102 then
            if self.m_tableView then
                self.m_lastListPos[tostring(self.m_cur_showType)] = self.m_tableView:getContentSize().height + self.m_tableView:getContentOffset().y
            end
            self.m_cur_showType = 2
            self:refreshUi()
        elseif btnTag == 103 then
            if self.m_tableView then
                self.m_lastListPos[tostring(self.m_cur_showType)] = self.m_tableView:getContentSize().height + self.m_tableView:getContentOffset().y
            end
            self.m_cur_showType = 3
            self:refreshUi()
        elseif btnTag == 104 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_firecup_mylucknum.ccbi");
    self.m_scale9_select = ccbNode:scale9SpriteForName("m_scale9_select")
    self.m_node_lucknum_board = ccbNode:nodeForName("m_node_lucknum_board")


    --  防透点
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);
    m_root_layer:setTouchEnabled(true);
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_node_lucknum_board:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_lucknum_board:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end

    self.m_controlBtns = {}
    for i=1,4 do
        local btn = ccbNode:controlButtonForName("m_btn_info" .. tostring(i))
        if btn then
            btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
        end
        self.m_controlBtns["btn" .. tostring(i)] = btn
    end

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    if m_close_btn then m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2) end
    return ccbNode;
end

--[[--
    创建列表
]]
function ui_firecup_minereward_pop.createTableView(self,viewSize)
    local showData = {}
    local curShowContractList = self.m_contractList[tostring(self.m_cur_showType)] or {}
    -- for k,v in pairs(curShowContractList) do
    --     if type(v) == "table" then
    --         table.insert(showData, 1, v)
    --     end
    -- end
    -- cclog2(showData, "showData   ====  ")
    showData = curShowContractList
    local tempCount = #showData
    local params = {};
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.viewSize = viewSize;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_firecup_qyreward_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            local itemData = showData[index + 1] or {}
            cclog2(itemData, "itemData  ====  ")
            if ccbNode then 
                local m_lable_number = ccbNode:labelTTFForName("m_lable_number")
                local m_node_reward = ccbNode:nodeForName("m_node_reward")
                m_lable_number:setString(tostring(itemData.code))
                m_node_reward:removeAllChildrenWithCleanup(true)

                local rewards = itemData.gifts or {}
                local info = ""
                for i=1,2 do
                    local oneReward = rewards[i] or nil
                    if oneReward then
                        local icon,name = game_util:getRewardByItemTable(oneReward, true);
                        if name then
                            info = info .. " " .. name
                        end
                    end
                end
                if #rewards > 2 then
                    info = info .. " 等"
                end

                local label = game_util:createLabelTTF({text = info,fontSize = 10})
                label:setPosition(m_node_reward:getContentSize().width * 0.5 + 10, m_node_reward:getContentSize().height * 0.5)
                m_node_reward:addChild(label)

                if index + 1 > params.row and index + 1 == #showData and self:isMoreContractData(self.m_cur_showType) then
                    -- 数据最后一条 并且后面仍然有数据
                    local label = game_util:createLabelTTF({text = string_helper.ui_firecup_minereward_pop.pullRefresh,fontSize = 10})
                    label:setPosition(ccbNode:getContentSize().width * 0.5, ccbNode:getContentSize().height * -0.5)
                    ccbNode:addChild(label, 0, 887)
                else
                    ccbNode:removeChildByTag(887, true)
                end

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
        elseif eventType == "refresh" and item then
            -- cclog2(eventType, "itemOnClick  eventType   =====   ")
            if not self:isMoreContractData(self.m_cur_showType) then
                return
            end

            if self.m_tableView then
                self.m_lastListPos[tostring(self.m_cur_showType)] = self.m_tableView:getContentSize().height + self.m_tableView:getContentOffset().y
            end
            self:refreshContractData( self.m_cur_showType )
        end
    end
    return TableViewHelper:create(params);
end

function ui_firecup_minereward_pop.refreshContractData( self, sortId, pageIndex )
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local dataTab = data and json.decode(data:getFormatBuffer()) or {}
        local newTab = {}

        for i,v in ipairs(dataTab.contract or {}) do
            table.insert(self.m_contractList[tostring(sortId)], v)
        end
        -- cclog2(self.m_contractList, "self.m_contractList  ===  ")
        self.m_page_sort_count[sortId][1] = math.min(self.m_page_sort_count[sortId][1] + 1, self.m_page_sort_count[sortId][2])
        self:refreshUi()  
    end
    local params = {}
    params.sort_id = sortId
    params.page = math.min(self.m_page_sort_count[sortId][1] + 1, self.m_page_sort_count[sortId][2])
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("magic_school_get_page_num"), http_request_method.GET, params,"magic_school_get_page_num")
      
end

function ui_firecup_minereward_pop.isMoreContractData( self, sortId )
    local sort_info = self.m_page_sort_count[sortId]
    -- cclog2(sort_info, "sort_info  ===  ")
    if sort_info[1] < sort_info[2] then
        return true
    end
    return false
end


--[[
    刷新
]]
function ui_firecup_minereward_pop.refreshTableView(self)
   self.m_node_lucknum_board:removeAllChildrenWithCleanup(true)
   self.m_tableView = nil
   local tempRewardTable = self:createTableView(self.m_node_lucknum_board:getContentSize());
   self.m_node_lucknum_board:addChild(tempRewardTable,10,10)
   self.m_tableView = tempRewardTable
   if self.m_lastListPos[tostring(self.m_cur_showType)] then
        local y = self.m_lastListPos[tostring(self.m_cur_showType)] - self.m_tableView:getContentSize().height
        self.m_tableView:setContentOffset(ccp(0, y))
   end
end

--[[--
    刷新ui
]]
function ui_firecup_minereward_pop.refreshUi(self)
    self:refreshTableView()

    local btn = self.m_controlBtns["btn" .. tostring(self.m_cur_showType)]
    if btn then
        local node = btn:getParent()
        self.m_scale9_select:setPosition(node:getPositionX(), node:getPositionY() - 1)
    end
end

--[[--
    初始化
]]
function ui_firecup_minereward_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_lastListPos = {}
    self.m_contractList = t_params.contractList or {};
    local page_sort_count = t_params.page_sort_count or {}
    local curPage_info = {}
    curPage_info[1] = {1, page_sort_count["1"] or 1}
    curPage_info[2] = {1, page_sort_count["2"] or 1}
    curPage_info[3] = {1, page_sort_count["3"] or 1}
    self.m_page_sort_count = curPage_info
    self.m_cur_showType = 1


    -- 初始化数据
    for k,v in pairs(self.m_contractList) do
        local newTab = {}
        for kk,vv in pairs(v) do
            table.insert(newTab, 1, vv)
        end
        self.m_contractList[k] = newTab
    end
end

--[[--
    创建ui入口并初始化数据
]]
function ui_firecup_minereward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_firecup_minereward_pop;