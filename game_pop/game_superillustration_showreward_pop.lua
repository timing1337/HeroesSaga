---  ui模版

local game_superillustration_showreward_pop = {
    m_root_layer = nil,
    m_sprite9_showboard = nil,
    m_node_itemsbg = nil,

    m_curPage = nil,
    t_rewards = nil,
    m_flag = nil,

};
--[[--
    销毁ui
]]
function game_superillustration_showreward_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_sprite9_showboard = nil;
    self.m_node_itemsbg = nil;

    self.m_curPage = nil;
    self.t_rewards = nil;

    self.m_flag = nil;
end
--[[--
    返回
]]
function game_superillustration_showreward_pop.back(self,backType)
    game_scene:removePopByName("game_superillustration_showreward_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_superillustration_showreward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_exchange_showrewards.ccbi")
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
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    -- -- 重置按钮出米优先级 防止被阻止
    -- self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    -- self.m_node_itemsbg:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_superillustration_showreward_pop.refreshUi(self)
    self.m_node_itemsbg:removeAllChildrenWithCleanup( true )
    local tableview = self:createItemsTabelViewByTypeID( self.m_node_itemsbg:getContentSize())
    if tableview == nil then return end
    tableview:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1 );
    self.m_node_itemsbg:addChild(tableview)

end
--[[--
    初始化
]]
function game_superillustration_showreward_pop.init(self,t_params)

    -- print("game_superillustration_showreward_pop   - data is ", t_params.gameData:getFormatBuffer())
    -- print_lua_table(t_params, 10)
    t_params = t_params or {};
    self.t_rewards = t_params.reward_data or {}

end

function game_superillustration_showreward_pop.createItemsTabelViewByTypeID(self, viewSize)
    local count = #self.t_rewards
    local params = {};
    params.viewSize = viewSize;
    params.row = 3; -- 行
    params.column = 5; -- 列
    params.totalItem = count  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage; -- 分页
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
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
            local reward = self.t_rewards[ index + 1 ]
            -- print("one reward is ===== ", json.encode(reward) )  -- 一个cell的信息
            local icon, name, count = game_util:getRewardByItemTable( self.t_rewards[ index + 1 ])
            if icon then
                cell:removeAllChildrenWithCleanup(true)
                -- 发光
                local board = nil
                if reward[4] ~= 0 then
                    board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                elseif reward[4] == 0 then
                    board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                end
                if board then
                    icon:setPosition(board:getContentSize().width * 0.5 , board:getContentSize().height * 0.5)
                    board:addChild(icon)
                    icon = board
                end
                icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))

                if  name then
                    if count then
                        name = name .. " x" .. count
                    end
                    if reward[4] ~= nil then
                        name = string_helper.game_superillustration_showreward_pop.drop
                    end
                    local blabelName = game_util:createLabelTTF({text = tostring(name)})
                    blabelName:setAnchorPoint(ccp(0.5, 1))
                    blabelName:setPosition(icon:getContentSize().width * 0.5,  6)
                    icon:addChild(blabelName, 10)
                end
                cell:addChild(icon)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
        -- print(" click item and index is === ", index)
        -- if index >= #self.t_rewards then return end;
        -- if eventType == "ended" and item then
        --     local info = self.t_rewards[ index + 1 ]
        --     if info then
        --         if info[1] == 5 then--卡牌
        --             local cId = info[2]
        --             cclog("cId == " .. cId)
        --             game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
        --         end
        --     end
        -- end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建ui入口并初始化数据
]]
function game_superillustration_showreward_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_superillustration_showreward_pop;