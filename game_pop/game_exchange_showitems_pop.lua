---  ui模版

local game_exchange_showitems_pop = {
    m_root_layer = nil,
    m_sprite9_showboard = nil,
    m_node_itemsbg = nil,

    m_curPage = nil,
    t_rewards = nil,

    m_flag = nil,
    m_gameData = nil ,

};
--[[--
    销毁ui
]]
function game_exchange_showitems_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_sprite9_showboard = nil;
    self.m_node_itemsbg = nil;

    self.m_curPage = nil;
    self.t_rewards = nil;

    self.m_flag = nil;
    self.m_gameData = nil ;
end
--[[--
    返回
]]
function game_exchange_showitems_pop.back(self,backType)
    game_scene:removePopByName("game_exchange_showitems_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_exchange_showitems_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/game_exchange_showitems.ccbi")
    self.m_node_itemsbg = ccbNode:nodeForName("m_node_itemsbg")

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        local rect = self.m_node_itemsbg:boundingBox()
        -- print_rect(rect, "rect is " )

        local flag = false
        if x >= rect.origin.x and x <= rect.origin.x + rect.size.width
            and y >= rect.origin.y and y <= rect.origin.y + rect.size.height then
            flag = true
        end

        if eventType == "began" then
            self.m_flag = not flag
            return true;--intercept event
        elseif eventType == "ended" and not flag and self.m_flag then
            self:back()
            return true
        elseif eventType == "ended" then
            self.m_flag = nil
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_exchange_showitems_pop.refreshUi(self)
    self.m_node_itemsbg:removeAllChildrenWithCleanup( true )
    local tableview = self:createItemsTabelViewByTypeID( self.m_node_itemsbg:getContentSize())
    if tableview == nil then return end
    tableview:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1 );
    self.m_node_itemsbg:addChild(tableview)

end
--[[--
    初始化
]]
function game_exchange_showitems_pop.init(self,t_params)

     self.m_gameData = t_params or {};
     cclog("t_params ======== ".. json.encode(t_params))

end

function game_exchange_showitems_pop.createItemsTabelViewByTypeID(self, viewSize)
    local gameData = self.m_gameData or {};
    cclog("gameData ======== ".. json.encode(gameData))
    local out_item_count = #gameData;
    local totalItem = out_item_count or 0
    local rowcount = 1 ;
    local columncount = 1 ;

    if totalItem > 4 then
        rowcount = 2 ;
        columncount = 4 ;
    else 
        columncount = totalItem ;
    end
    local numcount = 1 ;
    local params = {};
    params.viewSize = viewSize;
    params.row = rowcount; -- 行
    params.column = columncount; -- 列
    params.totalItem = totalItem  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage; -- 分页
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-4;
    local itemSize = CCSizeMake( viewSize.width/params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog(" new index ===================  " .. index)
            cell = CCTableViewCell:new()
            cell:autorelease()
        -- body
        end
        if cell then  -- 更新cell的内容
            cell:removeAllChildrenWithCleanup(true)
            local icon,name,count,rewardType = game_util:getRewardByItemTable(gameData[numcount]);
            numcount = numcount + 1 ;
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                -- 发光
                local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                if board then
                    board:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                    cell:addChild(board)
                end
                if  name then
                    -- local blabelName = game_util:createLabelBMFont({text = tostring(name)})
                    local blabelName = game_util:createLabelTTF({text = tostring(name)})
                    blabelName:setAnchorPoint(ccp(0.5, 1))
                    blabelName:setPosition(itemSize.width * 0.5,  itemSize.height*0.3)
                    cell:addChild(blabelName)
                end
                cell:addChild(icon)
            else
                cclog("pop ========   no  Data")
            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
    
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建ui入口并初始化数据
]]
function game_exchange_showitems_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_exchange_showitems_pop;
