---  公会主页

local game_guild_main = {
    m_list_view_bg = nil,
    m_guild_icon_bg = nil,
    m_guild_name_label = nil,
    m_guild_lv_label = nil,
    m_guild_ranking_label = nil,
    m_guild_total_label = nil,
    m_guild_integration_label = nil,
    m_ann_label = nil,
    m_pop_ui = nil,
    m_selGuildId = nil,
    m_jobType = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_tab_btn_4 = nil,
    m_building_lv_label = nil,
};
--[[--
    销毁ui
]]
function game_guild_main.destroy(self)
    -- body
    cclog("-----------------game_guild_main destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_guild_icon_bg = nil;
    self.m_guild_name_label = nil;
    self.m_guild_lv_label = nil;
    self.m_guild_ranking_label = nil;
    self.m_guild_total_label = nil;
    self.m_guild_integration_label = nil;
    self.m_ann_label = nil;
    self.m_pop_ui = nil;
    self.m_selGuildId = nil;
    self.m_jobType = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_tab_btn_4 = nil;
    self.m_building_lv_label = nil;
end
--[[--
    返回
]]
function game_guild_main.back(self,backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_guild_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then-- 信息

        elseif btnTag == 3 then-- 开发
            game_scene:enterGameUi("game_guild_develop",{gameData = nil,jobType=self.m_jobType});
            self:destroy();
        elseif btnTag == 4 then-- 兑换
            game_scene:enterGameUi("game_guild_conversion",{gameData = nil});
            self:destroy()
        elseif btnTag == 5 then-- 排行
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_data:setGuildListDataByJsonData(data:getNodeWithKey("guild_list"));
                game_scene:enterGameUi("game_guild_ranking",{gameData = nil});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_all"), http_request_method.GET, nil,"association_guild_all")
        elseif btnTag == 11 then--解散
            if self.m_jobType == 3 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_main.msg); return end
            local function responseMethod(tag,gameData)
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_guild_application",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_all"), http_request_method.GET, nil,"association_guild_all")
            end
            -- 移除公会
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_destroy"), http_request_method.GET, nil,"association_guild_destroy")
        elseif btnTag == 12 then--公告
            if self.m_jobType == 3 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_main.msg); return end
            if self.m_pop_ui == nil then
                self.m_pop_ui = self:createGuildEditAnnPop();
                game_scene:getPopContainer():addChild(self.m_pop_ui);
            end
        elseif btnTag == 13 then-- 审核
            if self.m_jobType == 3 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_main.msg); return end
            if self.m_pop_ui == nil then
                self.m_pop_ui = self:createGuildAppListPop();
                game_scene:getPopContainer():addChild(self.m_pop_ui);
            end
        elseif btnTag == 14 then-- 徽章
            if self.m_jobType == 3 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_main.msg); return end

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_main.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_guild_icon_bg = ccbNode:spriteForName("m_guild_icon_bg")
    self.m_guild_name_label = ccbNode:labelTTFForName("m_guild_name_label")
    self.m_guild_lv_label = ccbNode:labelTTFForName("m_guild_lv_label")
    self.m_guild_ranking_label = ccbNode:labelTTFForName("m_guild_ranking_label")
    self.m_guild_total_label = ccbNode:labelTTFForName("m_guild_total_label")
    self.m_guild_integration_label = ccbNode:labelTTFForName("m_guild_integration_label")
    self.m_ann_label = ccbNode:labelTTFForName("m_ann_label")

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_4 = ccbNode:controlButtonForName("m_tab_btn_4");
    self.m_building_lv_label = ccbNode:labelTTFForName("m_building_lv_label");
    self.m_tab_btn_1:setHighlighted(true);
    self.m_tab_btn_1:setEnabled(false);
    return ccbNode;
end

--[[--
    创建公会成员列表
]]
function game_guild_main.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    
    local tGameData = game_data:getSelGuildData();
    local player = tGameData.player;
    local guild = tGameData.guild;
    local playerIdTab = guild.player;
    local owner = guild.owner;
    local vp = guild.vp;
    local params = {};
    params.viewSize = viewSize;
    params.row = 13;--行
    params.column = 1; --列
    params.totalItem = table.getn(playerIdTab)
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            msgLabel:setPosition(ccp(itemSize.width*0.09,itemSize.height*0.5));
            msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            local nameLabel = CCLabelTTF:create(string_helper.game_guild_main.name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            nameLabel:setPosition(ccp(itemSize.width*0.3,itemSize.height*0.5));
            nameLabel:setColor(ccc3(200,120,0));
            cell:addChild(nameLabel,10,11);
            local lvLabel = CCLabelTTF:create("10",TYPE_FACE_TABLE.Arial_BoldMT,10);
            lvLabel:setPosition(ccp(itemSize.width*0.46,itemSize.height*0.5));
            lvLabel:setColor(ccc3(200,120,0));
            cell:addChild(lvLabel,10,12);
            local numLabel = CCLabelTTF:create("200",TYPE_FACE_TABLE.Arial_BoldMT,10);
            numLabel:setPosition(ccp(itemSize.width*0.63,itemSize.height*0.5));
            numLabel:setColor(ccc3(200,120,0));
            cell:addChild(numLabel,10,13);
            local statusLabel = CCLabelTTF:create(string_helper.game_guild_main.online,TYPE_FACE_TABLE.Arial_BoldMT,10);
            statusLabel:setPosition(ccp(itemSize.width*0.87,itemSize.height*0.5));
            statusLabel:setColor(ccc3(200,120,0));
            cell:addChild(statusLabel,10,14);
        end
        if cell then
            local uid = playerIdTab[index+1];
            local itemData = player[uid]
            if itemData then
                if owner == uid then
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_main.gvg_r);
                elseif game_util:valueInTeam(uid,vp) then
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_main.gvg_fr);
                else
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_main.teamer);
                end
                -- tolua.cast(cell:getChildByTag(11),"CCLabelTTF"):setString(itemData.name);
                tolua.cast(cell:getChildByTag(11),"CCLabelTTF"):setString(uid);
                tolua.cast(cell:getChildByTag(12),"CCLabelTTF"):setString(itemData.level);
                tolua.cast(cell:getChildByTag(13),"CCLabelTTF"):setString(itemData.score);
                tolua.cast(cell:getChildByTag(14),"CCLabelTTF"):setString(itemData.inline);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local function responseMethod(tag,gameData)
                local selPlayerJobType = 3;
                local uid = playerIdTab[index+1];
                if owner == uid then
                    selPlayerJobType = 1;
                elseif game_util:valueInTeam(uid,vp) then
                    selPlayerJobType = 2;
                end
                game_scene:addPop("game_guild_post_pop",{gameData = gameData,guildId=self.m_selGuildId,jobType=self.m_jobType,selPlayerJobType=selPlayerJobType})
            end
            --  user_id＝玩家id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_get_player_detail"), http_request_method.GET, {user_id=playerIdTab[index+1]},"association_get_player_detail")

        end
    end
    return TableViewHelper:createGallery2(params);
end


--[[--
    创建公告弹出框
]]
function game_guild_main.createGuildEditAnnPop(self)
    local ccbNode = luaCCBNode:create();
    local textFieldTTF = nil;
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
                if self.m_pop_ui then--关闭
                    self.m_pop_ui:removeFromParentAndCleanup(true);
                    self.m_pop_ui = nil;
                end
                cclog("textFieldTTF:getString() ===" .. textFieldTTF:getString());
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_edit_ann_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_edit_bg_node = tolua.cast(ccbNode:objectForName("m_edit_bg_node"), "CCSprite");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    local m_ok_btn = tolua.cast(ccbNode:objectForName("m_ok_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     local edit = tolua.cast(pSender,"CCEditBox")
    --     local strFmt
    --     if strEventName == "changed" then
    --         strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
    --         print(strFmt)
    --     end
    -- end
    -- local editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle});
    -- editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    -- m_edit_bg_node:addChild(editBox);
    local m_edit_bg_node_size = m_edit_bg_node:getContentSize();
    textFieldTTF = CCTextFieldTTF:textFieldWithPlaceHolder(string_helper.game_guild_main.prt, m_edit_bg_node_size, kCCTextAlignmentLeft, "", 25);
    textFieldTTF:setPosition(ccp(m_edit_bg_node_size.width*0.5,m_edit_bg_node_size.height*0.5));
    textFieldTTF:setColor(ccc3(255,255,255));
    m_edit_bg_node:addChild(textFieldTTF);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            textFieldTTF:attachWithIME();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    
]]
function game_guild_main.createGuildAppList(self,viewSize,touchPriority)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local tGameData = game_data:getSelGuildData();
    local guild = tGameData.guild;
    local waiter = {}
    if guild.waiter then
        waiter = guild.waiter;
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;--行
    params.column = 1; --列
    params.totalItem = table.getn(waiter);
    params.touchPriority = touchPriority;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            msgLabel:setPosition(ccp(itemSize.width*0.1,itemSize.height*0.5));
            msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            local nameLabel = CCLabelTTF:create(string_helper.game_guild_main.name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            nameLabel:setPosition(ccp(itemSize.width*0.4,itemSize.height*0.5));
            nameLabel:setColor(ccc3(200,120,0));
            cell:addChild(nameLabel,10,11);
            local lvLabel = CCLabelTTF:create("10",TYPE_FACE_TABLE.Arial_BoldMT,10);
            lvLabel:setPosition(ccp(itemSize.width*0.7,itemSize.height*0.5));
            lvLabel:setColor(ccc3(200,120,0));
            cell:addChild(lvLabel,10,12);
            local numLabel = CCLabelTTF:create("200",TYPE_FACE_TABLE.Arial_BoldMT,10);
            numLabel:setPosition(ccp(itemSize.width*0.9,itemSize.height*0.5));
            numLabel:setColor(ccc3(200,120,0));
            cell:addChild(numLabel,10,13);
        end
        if cell then
            local msgLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            local itemData = waiter[index+1]
            if msgLabel and itemData then
                msgLabel:setString(itemData);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = waiter[index+1]
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_guild_audit_pop",{gameData = gameData,guildId=self.m_selGuildId})
            end
            --  user_id＝玩家id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_get_player_detail"), http_request_method.GET, {user_id=itemData},"association_get_player_detail")
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建申请列表弹出框
]]
function game_guild_main.createGuildAppListPop(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_pop_ui then--关闭
                self.m_pop_ui:removeFromParentAndCleanup(true);
                self.m_pop_ui = nil;
            end
        elseif btnTag == 2 then
                if self.m_pop_ui then--关闭
                    self.m_pop_ui:removeFromParentAndCleanup(true);
                    self.m_pop_ui = nil;
                end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_app_list_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayer");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    local m_ok_btn = tolua.cast(ccbNode:objectForName("m_ok_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local tableViewTemp = self:createGuildAppList(m_list_view_bg:getContentSize(),GLOBAL_TOUCH_PRIORITY-1);
    m_list_view_bg:addChild(tableViewTemp);

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
function game_guild_main.refreshUi(self)
    -- local guild_icon = CCSprite:createWithSpriteFrameName("ghsq_huizhang0.png");
    -- local icon_bg_size = self.m_guild_icon_bg:getContentSize();
    -- guild_icon:setPosition(ccp(icon_bg_size.width*0.5,icon_bg_size.height*0.5));
    -- self.m_guild_icon_bg:addChild(guild_icon)

    local tGameData = game_data:getSelGuildData();
    if tGameData then
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(tableViewTemp);

        local guild = tGameData.guild
        self.m_guild_name_label:setString(guild.name);
        self.m_guild_lv_label:setString(guild.guild_level.lv);
        self.m_guild_ranking_label:setString("1");
        self.m_guild_total_label:setString(table.getn(guild.player));
        self.m_guild_integration_label:setString("1");

        local owner = guild.owner;
        local vp = guild.vp;
        local uid = game_data:getUserStatusDataByKey("uid");
        if owner == uid then
            self.m_jobType = 1;
        elseif game_util:valueInTeam(uid,vp) then
            self.m_jobType = 2;
        else
            self.m_jobType = 3;
        end
    end
end
--[[--
    初始化
]]
function game_guild_main.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setSelGuildDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
    self.m_selGuildId = t_params.guildId;
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_main;