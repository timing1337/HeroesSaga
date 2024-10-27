--- 弹框选择

local gem_system_select_pop = {
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
function gem_system_select_pop.destroy(self)
    -- body
    cclog("-----------------gem_system_select_pop destroy-----------------");
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
function gem_system_select_pop.back(self,type)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_data:resetNewEquipIdTab();
    game_scene:removePopByName("gem_system_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function gem_system_select_pop.createUi(self)
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
                cclog("btnCallBack ===========btnTag===" .. btnTag)
                local selSort = tonumber(EQUIP_SORT_TAB[btnTag].sortType);
                self:refreshGemTableView(selSort);
            end
            game_scene:addPop("game_sort_pop",{btnTitleTab = EQUIP_SORT_TAB,btnCallFunc = btnCallBack,currentSortType = self.m_selSort})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString(string_helper.gem_system_select_pop.gemList)
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 12);
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-11,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建装备列表
]]
function gem_system_select_pop.createGemTableView(self,viewSize,tableData)
    local itemsCount = #tableData
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
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
                game_util:setGemItemInfoByTable(ccbNode,itemData);
                local m_team_img = ccbNode:spriteForName("m_team_img")
                if not m_team_img:isVisible() then
                    -- local id = game_guide_controller:getCurrentId();
                    -- if id == 32 and self.m_guildNode == nil then
                    --     cell:setContentSize(itemSize);
                    --     self.m_guildNode = cell;
                    -- end
                end
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
            local itemData,itemCfg = game_data:getGemDataById(tableData[index+1]);
            if self.m_itemOnClick then
                self.m_itemOnClick(tableData[index+1]);
                self:back();
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建装备列表
]]
function gem_system_select_pop.createGemTableView2(self,viewSize,tableData)
    cclog("gem_system_select_pop json.encode(tableData) == " .. json.encode(tableData))
    local itemsCount = #tableData + 1;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-12;
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
                if index == 0 then
                    m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg2.png"))
                    m_spr_bg_up:setVisible(true);
                    ccbNode:nodeForName("m_info_node"):setVisible(false);
                else
                    m_spr_bg_up:setVisible(false);
                    local itemData,itemCfg = game_data:getGemDataById(tableData[index]);
                    game_util:setGemItemInfoByTable(ccbNode,{count = itemData,c_id = tableData[index]});
                    local m_team_img = ccbNode:spriteForName("m_team_img")
                    if not m_team_img:isVisible() then
                        -- local id = game_guide_controller:getCurrentId();
                        -- if id == 32 and self.m_guildNode == nil then
                        --     cell:setContentSize(itemSize);
                        --     self.m_guildNode = cell;
                        -- end
                    end
                end
            else
                m_spr_bg_up:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_q_bg.png"))
                m_spr_bg_up:setVisible(true);
                ccbNode:nodeForName("m_info_node"):setVisible(false);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            if index == 0 then
                self.m_itemOnClick("unload",nil);
                self:back();
            else
                local itemData,itemCfg = game_data:getGemDataById(tableData[index]);
                if self.m_itemOnClick and itemData then
                    self.m_itemOnClick("exchanged",tableData[index]);
                    -- self:back();
                end
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新列表
]]
function gem_system_select_pop.refreshGemTableView(self,sort)
    self.m_selSort = sort;
    if self.m_tableView ~= nil then
        self.m_tableView:removeFromParentAndCleanup(true);
    end
    local showData = game_data:getGemDataByGemType(self.m_selSort);
    if self.m_openType == 2 then 
        self.m_tableView = self:createGemTableView2(self.m_list_view_bg:getContentSize(),showData);
    else
        self.m_tableView = self:createGemTableView(self.m_list_view_bg:getContentSize(),showData);
    end
    self.m_list_view_bg:addChild(self.m_tableView);
    -- local id = game_guide_controller:getCurrentId();
    -- if id == 32 then
    --     self.m_tableView:setTouchEnabled(false);
    -- end
end

--[[--
    刷新ui
]]
function gem_system_select_pop.refreshUi(self)
    self:refreshGemTableView(self.m_selSort);
    self.m_sort_btn:setVisible(self.m_sortBtnShow);
end
--[[--
    初始化
]]
function gem_system_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_posIndex = t_params.posIndex;
    self.m_selSort = t_params.selSort or "-1";
    self.m_openType = t_params.openType or 1;
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
    self.m_sortBtnShow = t_params.sortBtnShow or false;
end

--[[--
    创建ui入口并初始化数据
]]
function gem_system_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    -- local id = game_guide_controller:getCurrentId();
    -- if self.m_guildNode and id == 32 then
    --     game_guide_controller:gameGuide("show","2",33,{tempNode = self.m_guildNode})
    -- end
    return self.m_popUi;
end

return gem_system_select_pop;