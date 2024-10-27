--- 火焰杯 幸运奖励详情

local ui_firecup_rewarddetail_pop = {
    m_node_lucknum_board = nil,     -- 最终奖励列表
    m_node_lucknum_board2 = nil,     -- 钻石大奖奖励列表
    m_node_diamondinfo_board = nil,  -- 钻石奖励列表
    m_cur_showType = nil,  -- 当前展示的类型
    m_controlBtns = nil,
    m_luckyReward = nil,
    m_luck_contractList = nil, -- 幸运号码
    m_coin_bigreward = nil,  -- 钻石大奖
    m_version = nil, -- 活动版本
};
--[[--
    销毁
]]
function ui_firecup_rewarddetail_pop.destroy(self)
    -- body
    cclog("-----------------ui_firecup_rewarddetail_pop destroy-----------------");
    self.m_node_lucknum_board = nil;
    self.m_node_lucknum_board2 = nil;
    self.m_node_diamondinfo_board = nil;
    self.m_cur_showType = nil;
    self.m_controlBtns = nil;
    self.m_luckyReward = nil;
    self.m_luck_contractList = nil;  -- 幸运号码
    self.m_coin_bigreward = nil;
    self.m_version = nil;
end
--[[--
    返回
]]
function ui_firecup_rewarddetail_pop.back(self,type)
    game_scene:removePopByName("ui_firecup_rewarddetail_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_firecup_rewarddetail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "ui_firecup_rewarddetail_pop   btnTag   =====   ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then
            self.m_cur_showType = 1
            self:refreshUi()
        elseif btnTag == 102 then
            self.m_cur_showType = 2
            self:refreshUi()
        elseif btnTag == 103 then
            self.m_cur_showType = 3
            self:refreshUi()
        elseif btnTag == 104 then
            self.m_cur_showType = 4
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_firecup_reward.ccbi");

    self.m_node_lucknum_board = ccbNode:nodeForName("m_node_lucknum_board")
    self.m_node_lucknum_board2 = ccbNode:nodeForName("m_node_lucknum_board2")
    self.m_node_diamondinfo_board = ccbNode:nodeForName("m_node_diamondinfo_board")
    self.m_node_diamondinfo_board:setVisible(false)
    self.m_node_lucknum_board:setVisible(true)
    self.m_scale9_select = ccbNode:scale9SpriteForName("m_scale9_select")
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

    local contract_cfg = getConfig(game_config_field.contract)
    local tempCfg = contract_cfg and contract_cfg:getNodeWithKey(tostring(self.m_version))
    local days_cfg = tempCfg and tempCfg:getNodeWithKey("day")
    local days = days_cfg and days_cfg:toInt() or 0
    if days > 0 then
        self.m_cur_showType = 1
    end

    self.m_controlBtns = {}
    for i=1,4 do
        local btn = ccbNode:controlButtonForName("m_btn_info" .. tostring(i))
        if btn then
            btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2)
        end
        self.m_controlBtns["btn" .. tostring(i)] = btn
    end
    local poss = {{-1, -1, -1, 0.5}, { 0.35, -1, -1 , 0.65}, {0.3, 0.5, -1, 0.7}, {0.25, 0.42, 0.6, 0.75}}
    local pos = poss[days + 1] or {}
    for i=1, 4 do
        local btn = self.m_controlBtns["btn" .. tostring(i)]
        if btn then
            local parentNode = btn:getParent()
            if parentNode and  pos[i] and pos[i] ~= -1 then
                local pparent = parentNode:getParent()
                local size = pparent:getContentSize()
                parentNode:setPositionX(size.width * pos[i])
            elseif parentNode then
                parentNode:setVisible(false)
            end
        end
    end

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    if m_close_btn then m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2) end
    return ccbNode;
end

--[[--
    创建钻石大奖
]]
function ui_firecup_rewarddetail_pop.createTableView(self,viewSize,rewardTab)
    local oldData = self.m_coin_bigreward
    local newData = {}
    for k,v in ipairs(oldData) do
        table.insert(newData, 1, v)
    end
    local showData = newData
    local tempCount = #showData
    tempCount = math.max(tempCount, 1)
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
            local m_lable_number = ccbNode:labelTTFForName("m_lable_number")
            local m_node_reward = ccbNode:nodeForName("m_node_reward")
            if #showData == 0 then
                m_lable_number:setString(string_helper.ui_firecup_rewarddetail_pop.tips)
                m_lable_number:setPositionX(ccbNode:getContentSize().width * 0.5)
                m_node_reward:removeAllChildrenWithCleanup(true)
            else
                local itemData = showData[index + 1]
                -- cclog2(itemData, "itemData   ===   ")
                if ccbNode then 
                    m_lable_number:setString(tostring(itemData.code or "????"))
                    m_node_reward:removeAllChildrenWithCleanup(true)

                    local oneReward = itemData and itemData.reward[1] or nil
                    local msg = ""
                    if oneReward then
                        -- cclog2(oneReward, "oneReward   ====   ")
                        local icon,name = game_util:getRewardByItemTable(oneReward, true);
                        if name then
                            msg = msg .. name
                        end
                    end
                    local label = game_util:createLabelTTF({text = msg,fontSize = 10})
                    label:setPosition(m_node_reward:getContentSize().width * 0.5, m_node_reward:getContentSize().height * 0.5)
                    m_node_reward:addChild(label)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        
        end
    end
    return TableViewHelper:create(params);
end

--[[
    创建最终大奖列表
]]
local itemTitleSprName = {"ui_firecup_zbqy.png", "ui_firecup_yxqy.png", "ui_firecup_chengzhangqiyu.png"}
function ui_firecup_rewarddetail_pop.createLastRewardTableView( self, viewSize )
    local luckNumData = self.m_luck_contractList[tostring(self.m_cur_showType)] or {}
    local showData = self.m_luckyReward["day" .. tostring(self.m_cur_showType)] or {}
    local tempCount = #showData
    tempCount = math.max(tempCount , 1)
    local params = {};
    params.row = 1;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionHorizontal;
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
            ccbNode:openCCBFile("ccb/ui_firecup_luckreward_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode") 
            if ccbNode then
                local m_label_lucknum = ccbNode:labelTTFForName("m_label_lucknum")
                local rewardNode = ccbNode:nodeForName("m_node_rewardboard")
                local m_spr_title = ccbNode:spriteForName("m_spr_title")
                -- cclog2(luckNumData, "luckNumData   ====   ")
                -- 幸运号码
                local luckData = luckNumData[tostring(index + 1)]
                luckData = luckData and luckData[1] 
                if luckData then
                    local num = luckData.code or "????????"
                    m_label_lucknum:setString(tostring(num))
                else
                    m_label_lucknum:setString(string_helper.ccb.file83)
                end

                -- 中级大奖
                rewardNode:removeAllChildrenWithCleanup(true)
                local itemCfg = showData[index + 1] 
                local reward = itemCfg and itemCfg:getNodeWithKey("reward")
                self:createRewardTableView(rewardNode, reward)

                -- 标题
                local frameSprName = itemTitleSprName[index + 1] or ""
                local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameSprName)
                if tempFrame and m_spr_title then
                    m_spr_title:setDisplayFrame(tempFrame)
                end
            end  
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    local tableview = TableViewHelper:create(params)
    if tempCount <= 3 then
        tableview:setMoveFlag(false)
    end
    return tableview
end


--[[
    创建横奖励列表
]]
function ui_firecup_rewarddetail_pop.createRewardTableView( self, viewBoard, rewardList )
    if not rewardList then return end
    local viewSize = viewBoard:getContentSize()
    -- cclog2(rewardList, "rewardList ==== ")
    function onBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local itemData = rewardList[btnTag + 1]
        if itemData then
            game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
        end
    end
    local tempCount = rewardList:getNodeCount()
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 2; --列
    if tempCount < 2 then params.column = 1 end
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
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
            local itemGift = rewardList:getNodeAt(index)
            local icon,name,count = game_util:getRewardByItem(itemGift)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)

                if icon and count then
                    countStr = "×" .. tostring(count)
                    local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5,0.5))
                    label_count:setPosition(ccp(icon:getContentSize().width,0))
                    icon:addChild(label_count,20)
                end
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = rewardList:getNodeAt(index)
            if itemData then
                game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    local tableView =  TableViewHelper:create(params);
    if tableView then
        viewBoard:addChild(tableView)
    end
end

--[[
    刷新
]]
function ui_firecup_rewarddetail_pop.refreshTableView(self)
    self.m_node_diamondinfo_board:setVisible(false)
    self.m_node_lucknum_board:setVisible(false)
   self.m_node_lucknum_board:removeAllChildrenWithCleanup(true)
   self.m_node_lucknum_board2:removeAllChildrenWithCleanup(true)
   local tempRewardTable = nil
   if self.m_cur_showType <=3 then
        self.m_node_lucknum_board:setVisible(true)
        tempRewardTable = self:createLastRewardTableView(self.m_node_lucknum_board:getContentSize());
        self.m_node_lucknum_board:addChild(tempRewardTable,10,10)
   elseif self.m_cur_showType == 4 then
        self.m_node_diamondinfo_board:setVisible(true)
        tempRewardTable = self:createTableView(self.m_node_lucknum_board2:getContentSize());
        self.m_node_lucknum_board2:addChild(tempRewardTable,10,10)
   end
end

--[[--
    刷新ui
]]
function ui_firecup_rewarddetail_pop.refreshUi(self)
    self:refreshTableView()


    local btn = self.m_controlBtns["btn" .. tostring(self.m_cur_showType)]
    if btn then
        local node = btn:getParent()
        self.m_scale9_select:setPosition(node:getPositionX(), node:getPositionY() - 1)
    end
end

--[[
    格式化数据
]]
function ui_firecup_rewarddetail_pop.formatData( self )
    self.m_luckyReward = {}
    local contract_reward = getConfig( game_config_field.contract_reward )
    local nodeCount = contract_reward:getNodeCount()
    for i=1, nodeCount do
        local itemCfg = contract_reward:getNodeAt(i - 1)
        if itemCfg and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_version then
            local sort = itemCfg:getNodeWithKey("sort") and itemCfg:getNodeWithKey("sort"):toInt() or 0
            if not self.m_luckyReward["day" .. tostring(sort)]  then self.m_luckyReward["day" .. tostring(sort)]  = {} end
            table.insert(self.m_luckyReward["day" .. tostring(sort)], itemCfg)
        end
    end
end

--[[--
    初始化
]]
function ui_firecup_rewarddetail_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_cur_showType = 4
    self.m_luck_contractList = t_params.luck_contractList or {}
    self.m_coin_bigreward = t_params.coin_bigreward or {}
    self.m_version = t_params.version 
    -- cclog2(self.m_luck_contractList, "self.m_luck_contractList   ====   ")
    self:formatData()
end

--[[--
    创建ui入口并初始化数据
]]
function ui_firecup_rewarddetail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_firecup_rewarddetail_pop;