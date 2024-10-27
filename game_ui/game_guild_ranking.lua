---  公会排行

local game_guild_ranking = {
    m_list_view_bg = nil,
    m_guild_icon_bg = nil,
    m_guild_name_label = nil,
    m_guild_lv_label = nil,
    m_guild_ranking_label = nil,
    m_guild_total_label = nil,
    m_guild_integration_label = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_tab_btn_4 = nil,
    m_building_lv_label = nil,
    m_jobType = nil,
};
--[[--
    销毁ui
]]
function game_guild_ranking.destroy(self)
    -- body
    cclog("-----------------game_guild_ranking destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_guild_icon_bg = nil;
    self.m_guild_name_label = nil;
    self.m_guild_lv_label = nil;
    self.m_guild_ranking_label = nil;
    self.m_guild_total_label = nil;
    self.m_guild_integration_label = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_tab_btn_4 = nil;
    self.m_building_lv_label = nil;
    self.m_jobType = nil;
end
--[[--
    返回
]]
function game_guild_ranking.back(self,backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_guild_ranking.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then-- 信息
            game_scene:enterGameUi("game_guild_main",{gameData = nil});
            self:destroy();
        elseif btnTag == 3 then-- 开发
            game_scene:enterGameUi("game_guild_develop",{gameData = nil,jobType=self.m_jobType});
            self:destroy();
        elseif btnTag == 4 then-- 兑换
            game_scene:enterGameUi("game_guild_conversion",{gameData = nil});
            self:destroy()
        elseif btnTag == 5 then-- 排行
        
        elseif btnTag == 11 then--解散公会
            if self.m_jobType == 3 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_ranking.msg); return end
            local function responseMethod(tag,gameData)
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_guild_application",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_all"), http_request_method.GET, nil,"association_guild_all")
            end
            -- 移除公会
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_destroy"), http_request_method.GET, nil,"association_guild_destroy")
        elseif btnTag == 12 then --搜索公会
            game_scene:addPop("game_guild_find_pop",{})
        elseif btnTag == 14 then --徽章
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_ranking.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_guild_icon_bg = ccbNode:spriteForName("m_guild_icon_bg")
    self.m_guild_name_label = ccbNode:labelTTFForName("m_guild_name_label")
    self.m_guild_lv_label = ccbNode:labelTTFForName("m_guild_lv_label")
    self.m_guild_ranking_label = ccbNode:labelTTFForName("m_guild_ranking_label")
    self.m_guild_total_label = ccbNode:labelTTFForName("m_guild_total_label")
    self.m_guild_integration_label = ccbNode:labelTTFForName("m_guild_integration_label")
    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_4 = ccbNode:controlButtonForName("m_tab_btn_4");
    self.m_building_lv_label = ccbNode:labelTTFForName("m_building_lv_label");
    self.m_tab_btn_4:setHighlighted(true);
    self.m_tab_btn_4:setEnabled(false);
    return ccbNode;
end


--[[--
    创建排行列表
]]
function game_guild_ranking.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local guild_list = game_data:getGuildListData();
    local params = {};
    params.viewSize = viewSize;
    params.row = 9;--行
    params.column = 1; --列
    params.totalItem = table.getn(guild_list)
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
            local nameLabel = CCLabelTTF:create(string_helper.game_guild_ranking.guild_name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            nameLabel:setPosition(ccp(itemSize.width*0.39,itemSize.height*0.5));
            nameLabel:setColor(ccc3(200,120,0));
            cell:addChild(nameLabel,10,11);
            local lvLabel = CCLabelTTF:create(string_helper.game_guild_ranking.guild_level,TYPE_FACE_TABLE.Arial_BoldMT,10);
            lvLabel:setPosition(ccp(itemSize.width*0.71,itemSize.height*0.5));
            lvLabel:setColor(ccc3(200,120,0));
            cell:addChild(lvLabel,10,12);
            local numLabel = CCLabelTTF:create("200/300",TYPE_FACE_TABLE.Arial_BoldMT,10);
            numLabel:setPosition(ccp(itemSize.width*0.91,itemSize.height*0.5));
            numLabel:setColor(ccc3(200,120,0));
            cell:addChild(numLabel,10,13);
        end
        if cell then
            local itemData = guild_list[index+1]
            if itemData then
                tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString("" .. (index + 1));
                tolua.cast(cell:getChildByTag(11),"CCLabelTTF"):setString(itemData.name);
                tolua.cast(cell:getChildByTag(12),"CCLabelTTF"):setString(itemData.lv);
                tolua.cast(cell:getChildByTag(13),"CCLabelTTF"):setString(itemData.player_count);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = guild_list[index+1]
            local selGuildId = itemData.id
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_guild_info_pop",{gameData=gameData,selGuildId=selGuildId})
            end
            --工会详情  guild_id = 工会id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_detail"), http_request_method.GET, {guild_id=selGuildId},"association_guild_detail")
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_guild_ranking.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    local tGameData = game_data:getSelGuildData();
    if tGameData then
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
function game_guild_ranking.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_ranking.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_ranking;