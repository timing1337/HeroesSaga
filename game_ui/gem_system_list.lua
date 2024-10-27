--- 宝石列表

local gem_system_list = {
    m_list_view_bg = nil,
    m_tableView = nil,
    m_posIndex = nil,
    m_selSort = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_openType = nil,
    m_title_label = nil,
    m_popUi = nil,
    m_sortBtnShow = nil,
    m_guildNode = nil,
};
--[[--
    销毁ui
]]
function gem_system_list.destroy(self)
    -- body
    cclog("-----------------gem_system_list destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tableView = nil;
    self.m_posIndex = nil;
    self.m_selSort = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_openType = nil;
    self.m_title_label = nil;
    self.m_popUi = nil;
    self.m_sortBtnShow = nil;
    self.m_guildNode = nil;
end

--[[--
    返回
]]
function gem_system_list.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function gem_system_list.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
            end
            self:back();
        elseif btnTag == 2 then
            local function btnCallBack(btnTag)
                local selSort = tostring(GEM_SORT_TAB[btnTag].sortType);
                cclog("btnCallBack ===========btnTag===" .. btnTag .. " ; selSort = " .. selSort)
                self:refreshTableView(selSort);
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = GEM_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = self.m_selSort})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString(string_helper.gem_system_list.gem_list)
    return ccbNode;
end

--[[--
    创建装备列表
]]
function gem_system_list.createTableView(self,viewSize,tableData)
    local itemsCount = #tableData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createGemItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local itemData,itemCfg = game_data:getGemDataById(tableData[index+1]);
                game_util:setGemItemInfoByTable(ccbNode,{count = itemData,c_id = tableData[index+1]});
            else
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            local tempId = tableData[index+1]
            local itemData,itemCfg = game_data:getGemDataById(tempId);
            game_scene:addPop("gem_system_info_pop",{tGameData = {count = itemData,c_id = tableData[index+1]},callBack = nil, openType=3});
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function gem_system_list.refreshTableView(self,sort)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    self.m_selSort = sort;
    game_data:gemSortByTypeName(self.m_selSort)
    local tempData = game_data:getGemIdTable();
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize(),tempData);
    self.m_list_view_bg:addChild(self.m_tableView);
end

--[[--
    刷新ui
]]
function gem_system_list.refreshUi(self)
    self:refreshTableView(self.m_selSort);
    -- self.m_sort_btn:setVisible(self.m_sortBtnShow);
end
--[[--
    初始化
]]
function gem_system_list.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = game_data:getGemSortType();
    self.m_openType = t_params.openType or 1;
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_sortBtnShow = t_params.sortBtnShow or false;
end

--[[--
    创建ui入口并初始化数据
]]
function gem_system_list.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return gem_system_list;