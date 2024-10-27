---  公会申请

local game_guild_info_pop = {
    m_tGameData = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_guild_icon_bg = nil,
    m_guild_name_label = nil,
    m_guild_lv_label = nil,
    m_guild_ranking_label = nil,
    m_guild_total_label = nil,
    m_ann_label = nil,
    m_selGuildId = nil,
    m_popUi = nil,
};
--[[--
    销毁ui
]]
function game_guild_info_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_info_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_guild_icon_bg = nil;
    self.m_guild_name_label = nil;
    self.m_guild_lv_label = nil;
    self.m_guild_ranking_label = nil;
    self.m_guild_total_label = nil;
    self.m_ann_label = nil;
    self.m_selGuildId = nil;
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_guild_info_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_guild_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_guild_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then--申请加入
            if self.m_selGuildId == nil then return end
            local function responseMethod(tag,gameData)
                cclog("association_guild_join =================================");
            end
            --申请加入工会  guild_id = 工会id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_join"), http_request_method.GET, {guild_id=self.m_selGuildId},"association_guild_join")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_info_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_guild_icon_bg = ccbNode:spriteForName("m_guild_icon_bg")
    self.m_guild_name_label = ccbNode:labelTTFForName("m_guild_name_label")
    self.m_guild_lv_label = ccbNode:labelTTFForName("m_guild_lv_label")
    self.m_guild_ranking_label = ccbNode:labelTTFForName("m_guild_ranking_label")
    self.m_guild_total_label = ccbNode:labelTTFForName("m_guild_total_label")
    self.m_ann_label = ccbNode:labelTTFForName("m_ann_label")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建公会列表
]]
function game_guild_info_pop.createTableView(self,viewSize,touchPriority)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    
    local player = self.m_tGameData.player;
    local guild = self.m_tGameData.guild;
    local playerIdTab = guild.player;
    local owner = guild.owner;
    local vp = guild.vp;
    local params = {};
    params.viewSize = viewSize;
    params.row = 13;--行
    params.column = 1; --列
    params.totalItem = table.getn(playerIdTab)
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
            msgLabel:setPosition(ccp(itemSize.width*0.09,itemSize.height*0.5));
            msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            local nameLabel = CCLabelTTF:create(string_helper.game_guild_help_pop.player,TYPE_FACE_TABLE.Arial_BoldMT,10);
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
            local statusLabel = CCLabelTTF:create(string_helper.game_guild_help_pop.line,TYPE_FACE_TABLE.Arial_BoldMT,10);
            statusLabel:setPosition(ccp(itemSize.width*0.87,itemSize.height*0.5));
            statusLabel:setColor(ccc3(200,120,0));
            cell:addChild(statusLabel,10,14);
        end
        if cell then
            local uid = playerIdTab[index+1];
            local itemData = player[uid]
            if itemData then
                if owner == uid then
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_help_pop.gvg_pr);
                elseif game_util:valueInTeam(uid,vp) then
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_help_pop.gvg_fr);
                else
                    tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString(string_helper.game_guild_help_pop.dy);
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

        end
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    刷新公会信息
]]
function game_guild_info_pop.refreshGuildInfo(self)
    if self.m_tGameData then
        local guild = self.m_tGameData.guild
        self.m_guild_name_label:setString(guild.name);
        self.m_guild_lv_label:setString(guild.guild_level.lv);
        self.m_guild_ranking_label:setString("1");
        self.m_guild_total_label:setString(table.getn(guild.player));
    end
end


--[[--
    刷新ui
]]
function game_guild_info_pop.refreshUi(self)
    self:refreshGuildInfo();
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize(),GLOBAL_TOUCH_PRIORITY-1);
    self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function game_guild_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer());
    end
    self.m_selGuildId = t_params.selGuildId;
end


--[[--
    创建ui入口并初始化数据
]]
function game_guild_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_info_pop;