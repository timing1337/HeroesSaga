---  公会申请

local game_guild_application = {
    m_anim_node = nil,
    m_list_view_bg = nil,
    m_pop_ui = nil,
    m_selGuildId = nil,
};
--[[--
    销毁ui
]]
function game_guild_application.destroy(self)
    -- body
    cclog("-----------------game_guild_application destroy-----------------");
    self.m_anim_node = nil;
    self.m_list_view_bg = nil;
    self.m_pop_ui = nil;
    self.m_selGuildId = nil;
end
--[[--
    返回
]]
function game_guild_application.back(self,backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_guild_application.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 11 then--创建公会
            if self.m_pop_ui == nil then
                self.m_pop_ui = self:createPop();
                game_scene:getPopContainer():addChild(self.m_pop_ui);
            end
        elseif btnTag == 12 then--公会详情
            self:refreshGuildInfo();
        elseif btnTag == 13 then--申请加入
            if self.m_selGuildId == nil then return end
            local function responseMethod(tag,gameData)
                cclog("association_guild_join =================================");
            end
            --申请加入工会  guild_id = 工会id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_join"), http_request_method.GET, {guild_id=self.m_selGuildId},"association_guild_join")
        elseif btnTag == 14 then--搜索公会
            game_scene:addPop("game_guild_find_pop",{})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_application.ccbi");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    return ccbNode;
end

--[[--
    创建公会列表
]]
function game_guild_application.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    
    local guild_list = game_data:getGuildListData();
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 5; --列
    params.totalItem = table.getn(guild_list)
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_guild_conversion_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,1,1)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(1),"luaCCBNode")
            local m_top_label = ccbNode:labelTTFForName("m_top_label")
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_bottom_label = ccbNode:labelTTFForName("m_bottom_label")
            m_icon_node:removeAllChildrenWithCleanup(true)

            local itemData = guild_list[index+1]
            if itemData then
                m_top_label:setString("Lv." .. itemData.lv)
                m_bottom_label:setString(itemData.name)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = guild_list[index+1]
            self.m_selGuildId = itemData.id
            self:refreshGuildInfo();
        end
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    刷新公会信息
]]
function game_guild_application.refreshGuildInfo(self)
    -- game_guild_application
    if self.m_selGuildId == nil then return end
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_guild_info_pop",{gameData=gameData,selGuildId=self.m_selGuildId})
    end
    --工会详情  guild_id = 工会id
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_detail"), http_request_method.GET, {guild_id=self.m_selGuildId},"association_guild_detail")
end

--[[--
    创建弹出框
]]
function game_guild_application.createPop(self)
    local guildName = "";
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self.m_selEquipId = nil;
            if self.m_pop_ui then--关闭
                self.m_pop_ui:removeFromParentAndCleanup(true);
                self.m_pop_ui = nil;
            end
        elseif btnTag == 2 then
            local function responseMethod(tag,gameData)
                if self.m_pop_ui then--关闭
                    self.m_pop_ui:removeFromParentAndCleanup(true);
                    self.m_pop_ui = nil;
                end
                local data = gameData:getNodeWithKey("data");
                game_data:setGuildListDataByJsonData(data:getNodeWithKey("guild_list"));
                self:refreshUi();
            end
             --创建公会  name = 工会名&icon ＝ 图标
            if guildName == "" then return end
            local params = {};
            params.name=util.url_encode(guildName)
            params.icon = "icon.png";
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_create"), http_request_method.GET, params,"association_guild_create")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_create_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    m_edit_bg_node:setOpacity(0);
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            guildName = edit:getText();
        end
    end
    local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = m_edit_bg_node:getContentSize()});
    editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_edit_bg_node:addChild(editBox);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_guild_application.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function game_guild_application.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        game_data:setGuildListDataByJsonData(data:getNodeWithKey("guild_list"));
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_application.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_application;