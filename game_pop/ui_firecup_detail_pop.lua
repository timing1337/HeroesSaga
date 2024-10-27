--- 火焰杯 活动详情

local ui_firecup_detail_pop = {
    m_node_detail_board = nil,     -- 奖励列表
    m_scrollView = nil,
    m_node_zaushiinfoboard = nil,
    m_contract_tab = nil,
    m_version = nil,
};
--[[--
    销毁
]]
function ui_firecup_detail_pop.destroy(self)
    -- body
    cclog("-----------------ui_firecup_detail_pop destroy-----------------");
    self.m_node_detail_board = nil;
    self.m_scrollView = nil;
    self.m_node_zaushiinfoboard = nil;
    self.m_contract_tab = nil;
    self.m_version = nil;
end
--[[--
    返回
]]
function ui_firecup_detail_pop.back(self,type)
    game_scene:removePopByName("ui_firecup_detail_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_firecup_detail_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "ui_firecup_detail_pop   btnTag   =====   ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 101 then

        elseif btnTag == 102 then

        elseif btnTag == 103 then

        elseif btnTag == 104 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_firecup_detailinfo.ccbi");

    self.m_node_detail_board = ccbNode:nodeForName("m_node_detail_board")
    self.m_scrollView = ccbNode:scrollViewForName("m_scrollView")
    self.m_node_zaushiinfoboard = ccbNode:nodeForName("m_node_zaushiinfoboard")
    -- local msg = "[color=ffffff00]" .. "火焰杯" .. "[/color]"
    -- msg = msg .. "[color=ff32cd32]" .. "处于" .. "[/color]"
    -- msg = msg .. "[color=ffcd0000]" .. "FIRE" .. "[/color]"
    -- msg = msg .. "[color=ff32cd32]" .. "状态后，将在一个小时内将" .. "[/color]"
    -- msg = msg .. "[color=ffee00ee]" .. "所有钻石" .. "[/color]"
    -- msg = msg .. "[color=ff32cd32]" .. "奖励给幸运玩家" .. "[/color]"


    local contract_cfg = getConfig(game_config_field.contract)
    local tempCount = contract_cfg:getNodeCount() or 1
    local tempCfg = contract_cfg:getNodeWithKey( tostring(self.m_version) )
    local fire_des_cfg = tempCfg and tempCfg:getNodeWithKey("fire_des")
    local cupInfo = fire_des_cfg and fire_des_cfg:toStr()


    local msg = cupInfo or string_helper.ui_firecup_detail_pop.tips

    local boardSize = self.m_node_zaushiinfoboard:getContentSize()
    local itemSize = CCSizeMake(boardSize.width - 5 , 0)
    local richLabel = game_util:createRichLabelTTF({text = msg,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255, 255, 255),fontSize = 10})
    richLabel:setAnchorPoint(ccp(0.5, 1))
    richLabel:setPosition(ccp( boardSize.width * 0.5 ,  boardSize.height - 4))
    self.m_node_zaushiinfoboard:removeAllChildrenWithCleanup(true)
    self.m_node_zaushiinfoboard:addChild(richLabel,10,10)

    -- 139,181,66
    --  防透点
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    m_root_layer:setTouchEnabled(true);

    self.m_scrollView:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    if m_close_btn then m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5) end

    self:createActiveDetailInfo()  --  穿建详情

    return ccbNode;
end


--[[
    创建活动详情内容
]]
function ui_firecup_detail_pop.createActiveDetailInfo( self )

    local contract_cfg = getConfig(game_config_field.contract)
    local tempCfg = contract_cfg and contract_cfg:getNodeWithKey(tostring(self.m_version))
    -- cclog2(activeId, "activeId  =====   ")
    -- cclog2(tempCfg, "tempCfg  =====   ")
    local active_msg = tempCfg and tempCfg:getNodeWithKey("notice") and tempCfg:getNodeWithKey("notice"):toStr() or ""
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "139" )
    -- local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"
    local viewSize = self.m_scrollView:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(viewSize.width ,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    self.m_scrollView:setContentSize(CCSizeMake(viewSize.width + 15, tempSize.height))
    self.m_scrollView:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    self.m_scrollView:addChild(tempLabel, 0, 998)
end

--[[--
    创建列表
]]
function ui_firecup_detail_pop.createTableView(self,viewSize,rewardTab)
    local itemTitleSprName = {"ui_firecup_zb.png", "ui_firecup_yx.png", "ui_firecup_cz.png"}
    local contract_detail_cfg = getConfig(game_config_field.contract_detail)
    if not contract_detail_cfg then return end
    local nodeCount = #self.m_contract_tab
    local tempCount = nodeCount
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"ui_firecup_detail_pop  createTableView  btnTag  ==  ")
    end

    local params = {};
    params.row = 1;--行
    if tempCount < 3 then
        params.column = tempCount; --列
    else
        params.column = 3; --列
    end
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.viewSize = viewSize;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_firecup_detailinfo_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            local m_node_reward1 = ccbNode:nodeForName("m_node_reward1")
            local m_node_reward2 = ccbNode:nodeForName("m_node_reward2")
            local m_spr_title = ccbNode:spriteForName("m_spr_title")
            m_node_reward1:removeAllChildrenWithCleanup(true)
            m_node_reward2:removeAllChildrenWithCleanup(true)
            local contrack_key = self.m_contract_tab[index + 1]
            local itemData = contract_detail_cfg:getNodeWithKey( tostring(contrack_key) )

            -- 创建最终奖励
            local finalReward = itemData and itemData:getNodeWithKey("reward_show_final")
            self:createHoroRewardTableView(m_node_reward1, finalReward)

            -- 创建随机道具
            local baseReward = itemData and itemData:getNodeWithKey("reward_show_base")
            self:createHoroRewardTableView(m_node_reward2, baseReward)

            -- 更新标题
            local frameSprName = itemTitleSprName[index + 1] or ""
            local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameSprName)
            if tempFrame and m_spr_title then
                m_spr_title:setDisplayFrame(tempFrame)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        
        end
    end
    local tableView = TableViewHelper:create(params);
    if tempCount <= 3 then
        tableView:setMoveFlag(false)
    end
    return tableView
end

--[[
    创建横奖励列表
]]
function ui_firecup_detail_pop.createHoroRewardTableView( self, viewBoard, rewardList )
    if not rewardList then return end
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
            local itemData = rewardList:getNodeAt(index)
            if itemData then
                game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
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
        viewBoard:addChild(tableView)
    end
end

--[[
    刷新
]]
function ui_firecup_detail_pop.refreshTableView(self)
   self.m_node_detail_board:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createTableView(self.m_node_detail_board:getContentSize());
   self.m_node_detail_board:addChild(tempRewardTable,10,10)
end

--[[--
    刷新ui
]]
function ui_firecup_detail_pop.refreshUi(self)
    self:refreshTableView()
end

--[[--
    初始化
]]
function ui_firecup_detail_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_contract_tab = t_params.m_contract_tab or {}
    self.m_version = t_params.version
end

--[[--
    创建ui入口并初始化数据
]]
function ui_firecup_detail_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_firecup_detail_pop;