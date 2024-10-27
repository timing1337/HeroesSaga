--- 宝石列表

local gem_explore_scene = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_posIndex = nil,
    m_back_btn = nil,
    m_food_label = nil,
    m_cost_food_label = nil,
    m_ccbNode = nil,
};
--[[--
    销毁ui
]]
function gem_explore_scene.destroy(self)
    -- body
    cclog("-----------------gem_explore_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_posIndex = nil;
    self.m_back_btn = nil;
    self.m_food_label = nil;
    self.m_cost_food_label = nil;
    self.m_ccbNode = nil;
end

--[[--
    返回
]]
function gem_explore_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function gem_explore_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gem_explore.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_food_label = ccbNode:labelTTFForName("m_food_label")
    self.m_cost_food_label = ccbNode:labelTTFForName("m_cost_food_label")
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    创建装备列表
]]
function gem_explore_scene.createTableView(self,viewSize)
    local showData = {};
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then

        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新列表
]]
function gem_explore_scene.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function gem_explore_scene.refreshUi(self)
    self:refreshTableView();
    for i=1,5 do
        local m_title_spr = self.m_ccbNode:spriteForName("m_title_spr_" .. i)
        if m_title_spr then
            if self.m_posIndex == i then
                m_title_spr:setColor(ccc3(255, 255, 255))
            else
                m_title_spr:setColor(ccc3(81,81,81))
            end
        end
    end
end
--[[--
    初始化
]]
function gem_explore_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex or 1

end

--[[--
    创建ui入口并初始化数据
]]
function gem_explore_scene.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return gem_explore_scene;