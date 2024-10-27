---  转盘奖励

local game_seapoacher_reward_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_ok_btn = nil,
    m_callBackFunc = nil,
};
--[[--
    销毁ui
]]
function game_seapoacher_reward_pop.destroy(self)
    -- body
    cclog("----------------- game_seapoacher_reward_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_ok_btn = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function game_seapoacher_reward_pop.back(self,backType)
    game_scene:removePopByName("game_seapoacher_reward_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_seapoacher_reward_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then -- 确定
            self:back()
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_seapoacher_reward_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text199)

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.m_list_view_bg:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_list_view_bg:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_list_view_bg:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    self.m_list_view_bg:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_seapoacher_reward_pop.createTableView(self,viewSize)
    local rewardTab = self.m_tGameData;--{{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000},{1,0,1000}} -- 走配置
    local params = {}
    params.viewSize = viewSize
    params.row = 2
    params.column = 3 -- 列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #rewardTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
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
                icon:setScale(0.75);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.55))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.085))
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

--[[--
    刷新
]]
function game_seapoacher_reward_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(m_tableView);
end


--[[--
    刷新ui
]]
function game_seapoacher_reward_pop.refreshUi(self)
    self:refreshTableView();
end
--[[--
    初始化
]]
function game_seapoacher_reward_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_tGameData = t_params.gameData or {};
    self.m_callBackFunc = t_params.callBackFunc;
end
--[[--
    创建ui入口并初始化数据
]]
function game_seapoacher_reward_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_seapoacher_reward_pop;
