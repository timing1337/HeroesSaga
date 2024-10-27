---table view helper 列表封装

local M = {
    
};

visibleSize = CCDirector:sharedDirector():getVisibleSize();
origin = CCDirector:sharedDirector():getVisibleOrigin();

--[[--
use method:
	local params = {};
    params.viewSize = CCSizeMake(0,0);
    params.totalItem = 10;
    params.direction = kCCScrollViewDirectionVertical;
    params.newCell = function(tableView,index) 
        -- body
        local cell = tableView:dequeueCell()
        if cell then
        else
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 103, 129)
            spriteLand:setPosition(5, 5);
            cell:addChild(spriteLand,1,1)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- body
        cclog("eventType = " .. eventType .. ";index = " .. index);
    end
    params.row = 2;
    params.column = 4; 
    TableViewHelper.create(TableViewHelper,params) or TableViewHelper:create(params)
]]
function M.create(self,params)
    -- body
    if params == nil or type(params) ~= "table" then
    	params = {};
    end
    local tableView = nil;
    params.viewSize = params.viewSize or CCSizeMake(visibleSize.width, visibleSize.height);
    params.totalItem = params.totalItem or 33;
    params.row = params.row or 2;
    params.column = params.column or 4;
    local itemActionFlag = params.itemActionFlag
    itemActionFlag = itemActionFlag == nil and false or itemActionFlag;
    params.direction = params.direction or kCCScrollViewDirectionVertical;
    if params.newCell == nil or type(params.newCell) ~= "function" then
    	params.newCell = function (tableView,index)
            cclog("newCell index = " .. index);
            -- body
            local cell = tableView:dequeueCell()
            if cell then
            else
                cell = CCTableViewCell:new()
                cell:autorelease()
                local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 103, 129)
                spriteLand:setPosition(5, 5);
                cell:addChild(spriteLand,1,1)
            end
            return cell;
        end
    end
    if params.itemOnClick == nil or type(params.itemOnClick) ~= "function" then
    	params.itemOnClick = function (eventType,index,item)
            -- body
            cclog("eventType = " .. eventType .. ";index = " .. index);
        end
    end
    -- for k,v in pairs(params) do
    --     cclog("params k = " .. tostring(k) .. " ; v = " .. tostring(v));
    -- end
    tableView = TableView:createTableView(params.viewSize);--设置整个listview区域的大小
    tableView:setItemActionFlag(itemActionFlag);
    tableView:setNumberOfCellsInTableView(params.totalItem);--item的数量 
    tableView:setDirection(params.direction);--设置方向
    tableView:registerScriptTapHandler(params.newCell)--设置item加载方法
    tableView:registerOnClickScriptTapHandler(params.itemOnClick)--设置点击回调方法
    tableView:setLayoutParams(params.row, params.column)--自定义*行*列
    tableView:setDefaultTouchPriority(params.touchPriority and params.touchPriority or 0);
    if params.direction == kCCScrollViewDirectionHorizontal then
        tableView:setScrollBarVisible(false);
    end
    return tableView;
end
--[[--
    设置列表的标签页点
]]
function M.setPageIndex(self,node,pageTotalCount_,currentPage_)
    if node == nil then return end
    -- node:removeAllChildrenWithCleanup(true);
    if pageTotalCount_ == 0 then return end
    if node:getChildrenCount() == 0 then
        local pageIndexSpr = CCSprite:createWithSpriteFrameName("public_point.png");
        local pageIndexSprSize = pageIndexSpr:getContentSize();
        local startPosX = -pageIndexSprSize.width*1.5*(pageTotalCount_-1)*0.5;
        for i=1,pageTotalCount_ do
            if i ~= currentPage_ then
                pageIndexSpr = CCSprite:createWithSpriteFrameName("public_point.png");
            else
                pageIndexSpr = CCSprite:createWithSpriteFrameName("public_pointSelect.png");--当前
            end
            pageIndexSpr:setPosition(startPosX + pageIndexSprSize.width*1.5*(i - 1),0);
            node:addChild(pageIndexSpr,1,i);
        end
    else
        local public_point = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_point.png")
        if currentPage_ == 1 then
            tolua.cast(node:getChildByTag(math.min(pageTotalCount_,currentPage_ + 1)),"CCSprite"):setDisplayFrame(public_point)
            tolua.cast(node:getChildByTag(pageTotalCount_),"CCSprite"):setDisplayFrame(public_point)
        elseif currentPage_ == pageTotalCount_ then
            tolua.cast(node:getChildByTag(1),"CCSprite"):setDisplayFrame(public_point)
            tolua.cast(node:getChildByTag(currentPage_ - 1),"CCSprite"):setDisplayFrame(public_point)
        else
            tolua.cast(node:getChildByTag(currentPage_ - 1),"CCSprite"):setDisplayFrame(public_point)
            tolua.cast(node:getChildByTag(currentPage_ + 1),"CCSprite"):setDisplayFrame(public_point)
        end
        tolua.cast(node:getChildByTag(currentPage_),"CCSprite"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_pointSelect.png"))
    end
end
--[[
    设置跳到索引位置
]]
function M.setIndex(self,index)
    
end
--[[--
    Gallery 1
]]
function M.createGallery(self,params)
    return self:createGallery2(params);
end
--[[--
    Gallery 2
]]
function M.createGallery2(self,params)
    if params == nil or type(params) ~= "table" then
        params = {};
    end

    local totalItem = 33;
    local row = 2;
    local column = 4;
    if params.totalItem ~= nil then
        totalItem = tonumber(params.totalItem);
    end
    if params.row ~= nil then
        row = tonumber(params.row);
    end
    if params.column ~= nil then
        column = tonumber(params.column);
    end
    local onePageCount = row * column;
    local m_nCurPage = 1;
    local m_nTotalPage = 1;
    m_nTotalPage = ((totalItem % onePageCount == 0) and (totalItem / onePageCount) or (totalItem / onePageCount + 1));
    m_nTotalPage = math.floor(m_nTotalPage);
    if params.showPageIndex and m_nTotalPage > 0 then
        m_nCurPage = math.min(params.showPageIndex,m_nTotalPage)
    end
    params.direction = kCCScrollViewDirectionHorizontal;
    local galleryLayer = CCLayer:create();
    local pageIndexNode = CCNode:create();
    local tableViewSize = params.viewSize;
    pageIndexNode:setPosition(tableViewSize.width*0.5,-visibleSize.height*0.025);
    galleryLayer:addChild(pageIndexNode,20,20);

    local pageLable = CCLabelTTF:create("0/0",TYPE_FACE_TABLE.Arial_BoldMT,10);
    pageLable:setVisible(false);
    pageLable:setAnchorPoint(ccp(1,0));
    pageLable:setPositionX(tableViewSize.width);
    galleryLayer:addChild(pageLable,100,100);
    if m_nTotalPage == 0 then
        pageLable:setVisible(false);
    end

    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.25)
    leftArrow:setPosition(ccp(-10,tableViewSize.height*0.5));
    galleryLayer:addChild(leftArrow)
    
    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.25)
    rightArrow:setPosition(ccp(tableViewSize.width + 10,tableViewSize.height*0.5));
    galleryLayer:addChild(rightArrow)
    if params.showPoint ~= nil and params.showPoint == false then
        pageIndexNode:setVisible(false);
        leftArrow:setVisible(false);
        rightArrow:setVisible(false);
        pageLable:setVisible(false);
    end

    local longClick = false;
    local onClickIndex,onClickItem = nil,nil;
    local newParams = {};
    newParams.viewSize = params.viewSize;
    newParams.row = row;--行
    newParams.column = column; --列
    newParams.totalItem = totalItem;
    newParams.direction = params.direction;
    newParams.touchPriority = params.touchPriority;
    newParams.itemActionFlag = params.itemActionFlag;
    newParams.newCell = function(tableView,index)
        return params.newCell(tableView,index);
    end
    newParams.itemOnClick = function(eventType,index,item)
        -- params.itemOnClick(eventType,index,item);
        -- cclog("--------------------- table view " .. eventType .. " " .. tostring(longClick));
        if eventType == "began" then
            onClickIndex = index;
            onClickItem = item;
        else
            onClickIndex = nil;
            onClickItem = nil;
        end
        if longClick == false then
            params.itemOnClick(eventType,index,item);
        end
    end
    local tableView = self:create(newParams);
    tableView:setMoveFlag(false);
    tableView:setScrollBarVisible(false);
    galleryLayer:addChild(tableView,10,10);
    local posX,posY;
    local direction = 0;
    local animFlag = false;
    local function refreshTableView()
        if params.pageChangedCallFunc and m_nTotalPage ~= 0 then
            params.pageChangedCallFunc(m_nTotalPage,m_nCurPage)
        end
        pageLable:setString(m_nCurPage .. "/" .. m_nTotalPage);
        posX,posY = tableView:getContainer():getPosition();

        -- cclog("posX,posY ========" .. posX .. "," ..posY .. "; tableViewSize.width = " .. tableViewSize.width .." ; -tableViewSize.width*(m_nCurPage - 1) ==" .. (-tableViewSize.width*(m_nCurPage - 1)) .. " ; m_nCurPage ==" .. m_nCurPage);
        self:setPageIndex(pageIndexNode,m_nTotalPage,m_nCurPage);
        -- tableView:getContainer():setPosition(ccp(-tableViewSize.width*m_nCurPage + direction*300,posY));
        -- tableView:getContainer():runAction(CCMoveTo:create(0.2,ccp(-tableViewSize.width*m_nCurPage,posY)))
        tableView:setContentOffset(ccp(-tableViewSize.width*(m_nCurPage - 1),posY), animFlag);
        if m_nTotalPage > 1 then
            if m_nCurPage == 1 then
                leftArrow:setOpacity(0);
                rightArrow:setOpacity(255);
            elseif m_nCurPage == m_nTotalPage then
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(0);
            else
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(255);
            end
        else
            leftArrow:setOpacity(0);
            rightArrow:setOpacity(0);
        end
    end
    refreshTableView();

    local function adjustScrollView(offset)
        animFlag = true;
        -- cclog("adjustScrollView offset =====================" .. tostring(offset));
        local refreshPageIndexFlag = true;
        if offset < -200 then
            m_nCurPage = m_nCurPage + 1;
            direction = 1;
        elseif offset > 200 then
            m_nCurPage = m_nCurPage - 1;
            direction = -1;
        else
            refreshPageIndexFlag = false;
        end
        if m_nCurPage < 1 then
            -- m_nCurPage = m_nTotalPage;
            m_nCurPage = 1;
            refreshPageIndexFlag = false;
        elseif m_nCurPage > m_nTotalPage then
            -- m_nCurPage = 1;
            m_nCurPage = m_nTotalPage;
            refreshPageIndexFlag = false;
        end
        if refreshPageIndexFlag and m_nTotalPage > 1 then
            refreshTableView();
        else
            -- tableView:setContentOffset(ccp(posX,posY), true);
            tableView:setContentOffset(ccp(-tableViewSize.width*(m_nCurPage - 1),posY), true);
        end
    end

    local function longClickFunc()
        if onClickIndex and onClickItem and not longClick then
            params.itemOnClick("longClick",onClickIndex,onClickItem);
            onClickIndex,onClickItem = nil,nil;
        end
        longClick = true;
        -- cclog("=======================longClickFunc ================" .. tostring(onClickIndex) .. " ; onClickItem = " .. tostring(onClickItem))
    end
    -- handing touch events
    local touchBeginPoint = nil
    local touchPoint = nil
    local beganTime = nil
    local moveFlag = nil
    local startPosX = nil;
    local function onTouchBegan(x, y)
        -- cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        beganTime = os.time();
        moveFlag = false;
        longClick = false;
        startPosX = tableView:getContainer():getPositionX();
        if not tableView:boundingBox():containsPoint(galleryLayer:convertToNodeSpace(ccp(x,y))) then
            return false;
        end
        performOtherWithDelay(galleryLayer,longClickFunc,1);
        return true
    end

    local function onTouchMoved(x, y)
        -- cclog("onTouchMoved: %0.2f, %0.2f", x, y)
        if touchPoint then
            local cx, cy = tableView:getContainer():getPosition();
            local offsetX = cx + x - touchPoint.x;
            -- cclog("offsetX ==========================" .. offsetX)
            if (offsetX-startPosX) < 100 and (offsetX-startPosX) > -100 then
                -- tableView:getContainer():setPositionX(offsetX);
                tableView:setContentOffset(ccp(offsetX,cy), false);
                touchPoint = {x = x, y = y}
            end
        end
        if moveFlag == false then
            galleryLayer:stopAllActions();
        end
        moveFlag = true;
    end

    local function onTouchEnded(x, y)
        -- cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        galleryLayer:stopAllActions();
        local distance = x - touchBeginPoint.x;
        if distance > 1 or distance < -1 then
            adjustScrollView(distance/math.max(0.1,(os.time() - beganTime)));
        end
        touchBeginPoint = nil
        touchPoint = nil
        beganTime = nil
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    
    galleryLayer:registerScriptTouchHandler(onTouch,false,params.touchPriority and params.touchPriority-1 or -128,false)
    galleryLayer:setTouchEnabled(true)
    return galleryLayer;
end

--[[--
    Gallery 3
]]
function M.createGallery3(self,params)
    if params == nil or type(params) ~= "table" then
        params = {};
    end

    local totalItem = 33;
    local row = 2;
    local column = 4;
    if params.totalItem ~= nil then
        totalItem = tonumber(params.totalItem);
    end
    if params.row ~= nil then
        row = tonumber(params.row);
    end
    if params.column ~= nil then
        column = tonumber(params.column);
    end
    local onePageCount = row * column;
    local m_nCurPage = 1;
    local m_nTotalPage = 1;
    m_nTotalPage = ((totalItem % onePageCount == 0) and (totalItem / onePageCount) or (totalItem / onePageCount + 1));
    m_nTotalPage = math.floor(m_nTotalPage);
    if params.showPageIndex and m_nTotalPage > 0 then
        m_nCurPage = math.min(params.showPageIndex,m_nTotalPage)
    end
    -- params.direction = kCCScrollViewDirectionHorizontal;
    local galleryLayer = CCLayer:create();
    local pageIndexNode = CCNode:create();
    local tableViewSize = params.viewSize;
    pageIndexNode:setPosition(ccp(tableViewSize.width*0.5,-visibleSize.height*0.025));
    galleryLayer:addChild(pageIndexNode,20,20);

    local pageLable = CCLabelTTF:create("0/0",TYPE_FACE_TABLE.Arial_BoldMT,10);
    pageLable:setVisible(false);
    pageLable:setAnchorPoint(ccp(1,0));
    pageLable:setPositionX(tableViewSize.width);
    galleryLayer:addChild(pageLable,100,100);
    if m_nTotalPage == 0 then
        pageLable:setVisible(false);
    end
    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.25)
    leftArrow:setPosition(ccp(-10,tableViewSize.height*0.5));
    galleryLayer:addChild(leftArrow)
    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.25)
    rightArrow:setPosition(ccp(tableViewSize.width + 10,tableViewSize.height*0.5));
    galleryLayer:addChild(rightArrow)
    if params.showPoint ~= nil and params.showPoint == false then
        pageIndexNode:setVisible(false);
        leftArrow:setVisible(false);
        rightArrow:setVisible(false);
        pageLable:setVisible(false);
    end
    local longClick = false;
    local onClickIndex,onClickItem = nil,nil;
    local newParams = {};
    newParams.viewSize = params.viewSize;
    newParams.row = row;--行
    newParams.column = column; --列
    newParams.totalItem = onePageCount;
    newParams.direction = params.direction;
    newParams.touchPriority = params.touchPriority;
    newParams.itemActionFlag = params.itemActionFlag;
    newParams.newCell = function(tableView,index)
        index = index + (m_nCurPage - 1) * onePageCount;
        return params.newCell(tableView,index);
    end
    newParams.itemOnClick = function(eventType,index,item)
        -- cclog()
        index = index + (m_nCurPage - 1) * onePageCount;
        if eventType == "began" then
            onClickIndex = index;
            onClickItem = item;
        end
        if longClick == false then
            params.itemOnClick(eventType,index,item);
        end
    end
    local tableView = nil;
    local posX,posY;
    local direction = 0;
    local function refreshTableView()
        if params.pageChangedCallFunc and m_nTotalPage ~= 0 then
            params.pageChangedCallFunc(m_nTotalPage,m_nCurPage)
        end
        pageLable:setString(m_nCurPage .. "/" .. m_nTotalPage);
        local tempNode = galleryLayer:getChildByTag(10);
        if tempNode then
            tempNode:removeFromParentAndCleanup(true);
        end
        -- if tableView then
        --     local function remove_node( node )
        --         -- body
        --         node:removeFromParentAndCleanup(true);
        --     end
        --     local remove = CCCallFuncN:create(remove_node);
        --     local arr = CCArray:create();
        --     arr:addObject(CCMoveTo:create(0.2,ccp(-direction*tableViewSize.width,posY)));
        --     arr:addObject(remove);
        --     tableView:getContainer():runAction(CCSequence:create(arr));
        -- end

        newParams.totalItem = onePageCount;
        if m_nCurPage == m_nTotalPage and (totalItem % onePageCount ~= 0) then
            newParams.totalItem = math.floor(totalItem % onePageCount);
        end
        if totalItem == 0 then newParams.totalItem = 0 end
        tableView = self:create(newParams);
        tableView:setMoveFlag(false);
        tableView:setScrollBarVisible(false);
        -- tableView:setPositionY(visibleSize.height*0.05);
        galleryLayer:addChild(tableView,10,10);
        posX,posY = tableView:getContainer():getPosition();
        -- cclog("posX,posY ========" .. posX .. "," ..posY);
        self:setPageIndex(pageIndexNode,m_nTotalPage,m_nCurPage);
        tableView:getContainer():setPosition(ccp(direction*300,posY));
        tableView:getContainer():runAction(CCMoveTo:create(0.2,ccp(0,posY)))
        if m_nTotalPage > 1 then
            if m_nCurPage == 1 then
                leftArrow:setOpacity(0);
                rightArrow:setOpacity(255);
            elseif m_nCurPage == m_nTotalPage then
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(0);
            else
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(255);
            end
        else
            leftArrow:setOpacity(0);
            rightArrow:setOpacity(0);
        end
    end
    refreshTableView();

    local function adjustScrollView(offset)
        -- cclog("adjustScrollView offset =====================" .. tostring(offset));
        local refreshPageIndexFlag = true;
        if offset < -200 then
            m_nCurPage = m_nCurPage + 1;
            direction = 1;
        elseif offset > 200 then
            m_nCurPage = m_nCurPage - 1;
            direction = -1;
        else
            refreshPageIndexFlag = false;
        end
        if m_nCurPage < 1 then
            -- m_nCurPage = m_nTotalPage;
            m_nCurPage = 1;
            refreshPageIndexFlag = false;
        elseif m_nCurPage > m_nTotalPage then
            -- m_nCurPage = 1;
            m_nCurPage = m_nTotalPage;
            refreshPageIndexFlag = false;
        end
        if refreshPageIndexFlag and m_nTotalPage > 1 then
            refreshTableView();
        else
            tableView:setContentOffset(ccp(posX,posY), true);
            -- tableView:getContainer():setPositionX(0);
        end
    end
    local function longClickFunc()
        longClick = true;
        params.itemOnClick("longClick",onClickIndex,onClickItem);
        -- cclog("=======================longClickFunc ================" .. tostring(onClickIndex) .. " ; onClickItem = " .. tostring(onClickItem))
    end
    -- handing touch events
    local touchBeginPoint = nil
    local touchPoint = nil
    local beganTime = nil
    local moveFlag = nil
    local function onTouchBegan(x, y)
        -- cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        beganTime = os.time();
        moveFlag = false;
        longClick = false;
        if not tableView:boundingBox():containsPoint(galleryLayer:convertToNodeSpace(ccp(x,y))) then
            return false;
        end
        performOtherWithDelay(galleryLayer,longClickFunc,1);
        return true
    end

    local function onTouchMoved(x, y)
        -- cclog("onTouchMoved: %0.2f, %0.2f", x, y)
        if touchPoint then
            local cx, cy = tableView:getContainer():getPosition();
            local offsetX = cx + x - touchPoint.x;
            -- cclog("offsetX ==========================" .. offsetX)
            if offsetX < 100 and offsetX > -100 then
                tableView:getContainer():setPositionX(offsetX);
                touchPoint = {x = x, y = y}
            end
        end
        if moveFlag == false then
            galleryLayer:stopAllActions();
        end
        moveFlag = true;
    end

    local function onTouchEnded(x, y)
        -- cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        onClickItem = nil;
        galleryLayer:stopAllActions();
        local distance = x - touchBeginPoint.x;
        if distance > 1 or distance < -1 then
            adjustScrollView(distance/math.max(0.1,(os.time() - beganTime)));
        end
        touchBeginPoint = nil
        touchPoint = nil
        beganTime = nil
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    
    galleryLayer:registerScriptTouchHandler(onTouch,false,params.touchPriority and params.touchPriority-1 or -128,false)
    galleryLayer:setTouchEnabled(true)
    return galleryLayer;
end

return M;