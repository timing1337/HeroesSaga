--- 弹框选择

local game_item_select_pop = {
    m_title_label = nil,
    m_list_view_bg = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_btnCallFunc = nil,
    m_itemOnClick = nil,
    m_popUi = nil,
};
--[[--
    销毁ui
]]
function game_item_select_pop.destroy(self)
    -- body
    cclog("-----------------game_item_select_pop destroy-----------------");
    self.m_title_label = nil;
    self.m_list_view_bg = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_btnCallFunc = nil;
    self.m_itemOnClick = nil;
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_item_select_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_item_select_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_item_select_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_btnCallFunc then
                self.m_btnCallFunc(target,event)
                self:back();
            end
        elseif btnTag == 2 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_hero_list.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    self.m_sort_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 2);
    self.m_title_label = ccbNode:labelBMFontForName("m_title_label")
    self.m_title_label:setString(string_helper.game_item_select_pop。itemList)
    game_util:setControlButtonTitleBMFont(self.m_sort_btn)
    self.m_sort_btn:setVisible(false)
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建道具列表
]]
function game_item_select_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local config_date = getConfig(game_config_field.item);
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    params.totalItem = game_data:getItemsCount();
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createItemsItem();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local item_id,count = game_data:getItemIdAndCountAt(index+1);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local iCountText = ccbNode:labelBMFontForName("m_count")
                local iNameText = ccbNode:labelTTFForName("m_name")
                local m_imgNode = tolua.cast(ccbNode:objectForName("m_imgNode"),"CCNode");
                local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
                local itemCfg = config_date:getNodeWithKey(tostring(item_id));
                iCountText:setString(tostring("x" .. count));
                iNameText:setString(itemCfg:getNodeWithKey("name"):toStr());
                m_imgNode:removeAllChildrenWithCleanup(true);
                m_imgNode:addChild(game_util:createItemIconByCfg(itemCfg))
                m_story_label:setString(itemCfg:getNodeWithKey("story"):toStr());
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local item_id,count = game_data:getItemIdAndCountAt(index+1);
            if self.m_itemOnClick then
                self.m_itemOnClick(item_id);
                self:back();
            end
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_item_select_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
end
--[[--
    初始化
]]
function game_item_select_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_btnCallFunc = t_params.btnCallFunc;
    self.m_itemOnClick = t_params.itemOnClick;
end

--[[--
    创建ui入口并初始化数据
]]
function game_item_select_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_item_select_pop;