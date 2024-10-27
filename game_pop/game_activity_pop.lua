--- 活动

local game_activity_pop = {
    m_list_view_bg = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
};
--[[--
    销毁ui
]]
function game_activity_pop.destroy(self)
    -- body
    cclog("-----------------game_activity_pop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_popUi = nil;
    self.m_tab_btn_1 = nil
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
end
--[[--
    返回
]]
function game_activity_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_activity_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_activity_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_activity.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建活动列表
]]
function game_activity_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    
    local active_chapter_cfg = getConfig(game_config_field.active_chapter);
    local tGameData = game_data:getActiveData();
    local dataTab = {};
    for k,v in pairs(tGameData) do
        dataTab[#dataTab+1] = {id = k,data = v};
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.totalItem = #dataTab;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.direction = kCCScrollViewDirectionHorizontal;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_game_activity_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = dataTab[index + 1];
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(itemData.id));
            if ccbNode and itemData and itemCfg then
                local m_bg_spr = ccbNode:spriteForName("m_bg_spr")
                local m_img_node = ccbNode:nodeForName("m_img_node")
                local m_time_label = ccbNode:labelTTFForName("m_time_label")
                local m_number_label = ccbNode:labelTTFForName("m_number_label")
                m_time_label:setString(itemData.data.expire_day .. string_helper.game_activity_pop.day);
                m_number_label:setString(itemData.data.cur_times .. "/" .. itemData.data.times);
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(itemCfg:getNodeWithKey("banner_resource"):toStr() .. ".png")
                if tempSpriteFrame then
                    m_bg_spr:setDisplayFrame(tempSpriteFrame);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            local activeChapterId = dataTab[index + 1].id;
            game_scene:enterGameUi("active_map_scene",{gameData = nil,activeChapterId = activeChapterId});
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_activity_pop.refreshUi(self)
    local function sendRequest()
        local function responseMethod(tag,gameData)
            game_data:setActiveDataByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("index"));
            self.m_list_view_bg:removeAllChildrenWithCleanup(true);
            local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
            self.m_list_view_bg:addChild(tableViewTemp);
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    end
    sendRequest();
end
--[[--
    初始化
]]
function game_activity_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return game_activity_pop;