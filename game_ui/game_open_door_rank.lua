---  外域排行榜
local game_open_door_rank = {
    m_tGameData = nil,
    m_tableView = nil,
    m_tableView2 = nil,
    select_node = nil,
    show_table_node = nil,
    title_sprite = nil,
    praise_label = nil,
    variable_label = nil,
    praise = nil,
    select_index = nil,
    first_flag = nil,
};
--[[--
    销毁ui
]]
function game_open_door_rank.destroy(self)
    cclog("-----------------game_open_door_rank destroy-----------------");
    self.m_tGameData = nil;
    --排行榜的控件
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.select_node = nil;
    self.show_table_node = nil;
    self.title_sprite = nil;
    self.praise_label = nil;
    self.variable_label = nil;
    self.praise = nil;
    self.select_index = nil;
    self.first_flag = nil;
end
--[[
   战斗力排行        1
   金字塔           2
   运镖             3
   回廊             4
]]
local rank_name = {
    {title = "rank_combat_title.png",icon = "space_battle_power.png",url = "open_door_rank",sort = "combat"},--战斗力排行
    
    {title = "rank_level_title.png",icon = "space_goldtower.png",url = "open_door_rank",sort = "pyramid"},--金字塔
    
    {title = "rank_title_arena.png",icon = "space_guard.png",url = "open_door_rank",sort = "escort"},--运镖
    
    {title = "rank_title.png",icon = "space_huilang.png",url = "open_door_rank",sort = "maze"},--回廊
}
--[[--
    返回
]]
function game_open_door_rank.back(self,backType)
    game_scene:enterGameUi("open_door_main_scene")
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_open_door_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 200 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_space_rank.ccbi");
    --排行榜的控件
    self.select_node = ccbNode:nodeForName("select_node");
    self.show_table_node = ccbNode:nodeForName("show_tabel_node");
    self.title_sprite = ccbNode:spriteForName("title_sprite");
    self.variable_label3 = ccbNode:spriteForName("variable_label3");
    self.variable_label3:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("space_battle_power2.png"));
    -- self.praise_label = ccbNode:labelTTFForName("praise_label");
    -- for i=1,3 do
    --     self.variable_label[i] = ccbNode:labelTTFForName("variable_label" .. i)
    -- end

    local animName = "enter_anim"
    local function animCallFunc(animName)
        ccbNode:runAnimations(animName)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    return ccbNode;
end
--[[
    
]]
function game_open_door_rank.createRankTableView(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(rank_name);
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local textSprite = {"space_battle_power1.png","space_goldtower1.png","space_guard1.png","space_huilang1.png"}
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_space_rank_item2.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local rank_select = ccbNode:spriteForName("rank_select")
            local text_sprite = ccbNode:spriteForName("text_sprite")
            text_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(textSprite[index+1]));
            if self.select_index == index + 1 then
                rank_select:setVisible(true)
            else
                rank_select:setVisible(false)
            end
            local spriteName = rank_name[index+1].icon
            title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteName));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            if index + 1 ~= self.select_index then
                self.select_index = index + 1
                self:refreshUi()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建内容列表
]]
function game_open_door_rank.createContentTable(self,viewSize)
    local parise_already_tab = {};
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCControlButton");
        local btnTag = tagNode:getTag();        
        if btnTag >= 1000 and btnTag < 2000 then
            local index = btnTag - 1000

            local itemData = self.userInfo[index+1]
            if itemData == nil then return end
            local tempUid = itemData.uid;
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_player_info_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        elseif btnTag >= 2000 and btnTag < 3000 then

        elseif btnTag >= 3000 then
            
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = game_util:getTableLen(self.userInfo);
    params.direction = kCCScrollViewDirectionVertical;--纵向

    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_space_rank_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local user_head_node = ccbNode:nodeForName("m_icon_node");
            local top_icon = ccbNode:spriteForName("top_icon");
            local btn_look = ccbNode:controlButtonForName("btn_look")--查看
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local m_sprite9_cellbg2 = ccbNode:scale9SpriteForName("m_sprite9_cellbg2")
            local rank_number = ccbNode:labelBMFontForName("rank_number")

            local itemData = self.userInfo[index+1]

            if index < 3 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                top_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1]))
                -- m_sprite9_cellbg:setColor(colorTab[index+1])
                m_sprite9_cellbg:setVisible(false)
                m_sprite9_cellbg2:setVisible(true)
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setVisible(true)
                m_sprite9_cellbg2:setVisible(false)
                -- m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
            user_head_node:removeAllChildrenWithCleanup(true)
            local role = itemData.role or 1
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
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
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
            btn_look:setOpacity(0)
            btn_look:setTag(1000 + index)
            --设置不同排行榜的内容
            local variable_node = {}
            for i=1,3 do
                variable_node[i] = ccbNode:nodeForName("node_" .. i)
            end
            
            self:setRankData(variable_node[1],variable_node[2],variable_node[3],itemData,index)

            if index >= 19 and index == game_util:getTableLen(self.userInfo) - 1 and self.cur_page < 4 then
                local tipLabel = game_util:createLabelTTF({text = string_helper.game_open_door_rank.down_refresh,color = ccc3(250,180,0),fontSize = 12});
                tipLabel:setAnchorPoint(ccp(0.5,0.5))
                tipLabel:setPosition(ccp(itemSize.width*0.5,-20))
                cell:addChild(tipLabel,20,20)
            else
                local tempNode = cell:getChildByTag(20)
                if tempNode then
                    tempNode:removeFromParentAndCleanup(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        elseif eventType == "refresh" and item then
            if self.cur_page < 4 then
                self.cur_page = self.cur_page + 1
                self:requestForHttp()
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    设置不同排行榜内容
]]
function game_open_door_rank.setRankData(self,node1,node2,node3,itemData,index)
    local index = self.select_index
    node1:removeAllChildrenWithCleanup(true)
    node2:removeAllChildrenWithCleanup(true)
    node3:removeAllChildrenWithCleanup(true)
    local child1 = nil
    local child2 = nil
    local child3 = nil

    local name = itemData.name
    local level = itemData.level
    local rank = itemData.rank
    local score = itemData.score

    child1 = game_util:createLabelTTF({text = name,fontSize = 12})
    child2 = game_util:createLabelTTF({text = level,fontSize = 12})
    child3 = game_util:createLabelBMFont({text = score,fnt = "yellow_image_text.fnt"})
    if child1 ~= nil then
        node1:addChild(child1)
    end
    if child2 ~= nil then
        node2:addChild(child2)
    end
    if child3 ~= nil then
        node3:addChild(child3)
    end
end
--[[
    刷新label
]]
function game_open_door_rank.refreshLabel(self)
    -- local parise_count = game_data:getUserStatusDataByKey("parise_count") or 0;
    -- local parise_max = game_data:getUserStatusDataByKey("parise_max") or 10;
    -- self.praise_label:setString("点赞:" .. (parise_max - parise_count) .. "/" .. parise_max)
end
--[[
    添加新数据  当前排行榜添加新数据
]]
function game_open_door_rank.requestForHttp(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local top = json.decode(data:getNodeWithKey("top"):getFormatBuffer())
        for i=1,#top do
            table.insert(self.userInfo,top[i])
        end
        self:refreshTab1()
    end
    local params = {}
    local url = rank_name[self.select_index].url
    local sort = rank_name[self.select_index].sort
    params.sort = sort
    params.page = self.cur_page
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url)
end
--[[
    刷新
]]
function game_open_door_rank.refreshUi(self)
    --联网重新取数据   切换排行榜
    function responseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:formatData(self.m_tGameData)
            --切换完table重置当前页
            self.cur_page = 0
            self:refreshTab2()
            self:refreshLabel()
            self:refreshTab1()
        end
    end
    if self.select_index == 1 then
        self.variable_label3:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("space_battle_power2.png"));
    else
        self.variable_label3:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("space_personal_number.png"));
    end
    local params = {}
    local url = rank_name[self.select_index].url
    local sort = rank_name[self.select_index].sort
    params.sort = sort
    params.page = 0
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(url), http_request_method.GET, params,url,true,true)
end
--[[
    刷新
]]
function game_open_door_rank.firstRefreshUi(self)
    --联网重新取数据   切换排行榜
    self:refreshTab2()
    local spriteName = rank_name[self.select_index].title
    self:refreshLabel()
    self:refreshTab1()
end
--[[
    刷新表1
]]
function game_open_door_rank.refreshTab1(self)
    self.show_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView2 = self:createContentTable(self.show_table_node:getContentSize());
    self.show_table_node:addChild(self.m_tableView2,10,10);
    local index = self.cur_page * 20
    game_util:setTableViewIndex(index,self.show_table_node,10,5)
end
--[[
    刷新表2
]]
function game_open_door_rank.refreshTab2(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.select_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView = self:createRankTableView(self.select_node:getContentSize());
    self.select_node:addChild(self.m_tableView,33,33);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    if self.first_flag == true then
        self.first_flag = false
        if self.select_node then 
            game_util:setTableViewIndex(self.select_index-1,self.select_node,33,5)
        end
    end
end
--[[--
    初始化
]]
function game_open_door_rank.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.praise = 10
    self.select_index = t_params.index or 1
    -- self.variable_label = {}
    self.cur_page = 0

    self.first_flag = true
    --格式化所有接口数据，返回统一的
    self:formatData(self.m_tGameData)
end
--[[
    格式化接口数据
]]
function game_open_door_rank.formatData(self,netData)
    local index = self.select_index
    -- if index == 1 or index == 2 or index == 3 or index == 7 or index == 5 or index == 6 or index == 9 then--战斗力。等级
    --     self.userInfo = self.m_tGameData.top
    -- if index == 4 then--联盟排行
    --     self.userInfo = self.m_tGameData.guild_list
    -- elseif index == 8 then--生存大考验
    --     self.userInfo = self.m_tGameData.users
    -- else
        self.userInfo = self.m_tGameData.top
    -- end
end
--[[--
    创建ui入口并初始化数据
]]
function game_open_door_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:firstRefreshUi();
    return scene;
end

return game_open_door_rank;