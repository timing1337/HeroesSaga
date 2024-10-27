---  新竞技场
local game_live_rank = {
    m_gameData = nil,
    m_rank_node= nil,
    m_rank_table_node = nil,
};
--[[--
    销毁ui
]]
function game_live_rank.destroy(self)
    cclog("-----------------game_live_rank destroy-----------------");
    self.m_gameData = nil;
    --排行榜的控件
    self.m_rank_node = nil;
    self.m_rank_table_node = nil;
end
--[[--
    返回
]]
function game_live_rank.back(self,backType)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
        game_scene:enterGameUi("game_activity_live",{liveData = live_data})
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end
--[[--
    读取ccbi创建ui
]]
function game_live_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_live_rank.ccbi");
    --排行榜的控件
    self.m_rank_node = ccbNode:nodeForName("m_arena_node_2");
    self.m_rank_table_node = ccbNode:nodeForName("rank_table_node");
    return ccbNode;
end
--[[
    创建竞技场排行榜列表
]]
function game_live_rank.createRankTableView(self,viewSize)
    local rank_info = self.user
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();        
        local index = btnTag - 1000
        local tempUid = rank_info[index].uid;
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_player_info_pop",{gameData = gameData})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
    end
    local frame_name = {"arena_gold.png","arena_silver.png","arena_copper.png"}
    local fightCount = #rank_info;
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local sb_name = {}
    local sb_guild = {}
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local user_rank_label = ccbNode:labelBMFontForName("rank_number");
            local user_name_label = ccbNode:labelTTFForName("m_user_label");
            local fight_count_label = ccbNode:labelBMFontForName("fight_point_label");
            local top_icon = ccbNode:spriteForName("top_icon");
            local guild_name_label = ccbNode:labelTTFForName("m_guild_label");

            local btn_look = ccbNode:controlButtonForName("btn_look")

            btn_look:setTag(1001 + index)
            btn_look:setOpacity(0)

            local user_info = rank_info[index + 1];
            user_rank_label:setString(tostring(index + 1));
            if index >= 0 and index < 3 then
                top_icon:setVisible(true);
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(frame_name[index + 1]))
                top_icon:setDisplayFrame(tempSpriteFrame);
            else
                top_icon:setVisible(false);
            end
            user_name_label:setString(tostring(user_info.name));
            local hightest_level = tonumber(user_info.rank)
            guild_name_label:setString(hightest_level)  
            for i=1,4 do
                sb_name[i] = ccbNode:labelTTFForName("m_user_label_" .. i);
                sb_name[i]:setString(tostring(user_info.name));
                sb_guild[i] = ccbNode:labelTTFForName("m_guild_label_" .. i);
                sb_guild[i]:setString(hightest_level)  
            end
            local icon = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(user_info.role));
            if icon then
                user_head_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                user_head_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                user_head_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. user_info.role .. " not found !")
            end
            fight_count_label:setString(tostring(user_info.combat));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新
]]
function game_live_rank.refreshUi(self)
    self:refreshTab2()
end
--[[
    刷新表2
]]
function game_live_rank.refreshTab2(self)
    self.m_rank_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createRankTableView(self.m_rank_table_node:getContentSize())
    textTableTemp:setScrollBarVisible(false)
    self.m_rank_table_node:addChild(textTableTemp);
end
--[[--
    初始化
]]
function game_live_rank.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        self.m_gameData = t_params.gameData
    end
    cclog("self.m_gameData = " .. json.encode(self.m_gameDatam))
    self.user = self.m_gameData.users
end

--[[--
    创建ui入口并初始化数据
]]
function game_live_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_live_rank;