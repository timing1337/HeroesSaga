---  新竞技场
local ui_all_rank = {
    m_gameData = nil,
    m_rank_node= nil,
    m_rank_table_node = nil,
    m_index = nil,
    level_page = nil,
    combat_page = nil,
    change_flag_1 = nil,
    change_flag_2 = nil,
    count_1 = nil,
    count_2 = nil,
    lv_count = nil,
    combat_count = nil,

    m_curRankName = nil,    -- 当前显示的排行榜名字
    m_curRankPage = nil,    -- 当前显示的排行榜的分页
    m_allRankData = nil,    -- 所有排行榜数据  

    m_ccbNode = nil,

    m_descrTitles = nil,
    m_openType = nil,

};


local openRankList = {}
openRankList["2"] = true
openRankList["3"] = true
openRankList["4"] = true
openRankList["9"] = true

local btnType = { paiming = "arena_rank", level = "arena_renwudengji", from_guild_name = "arena_guild_name", combat = "arena_fight_num2", arena_max_level = "arena_max_level", userName = "arena_user_name"}
local defaultImageKeyName = {keyImage1 = "arena_rank", keyImage2 = "arena_user_name", keyImage3 = "arena_renwudengji", keyImage4 = "arena_fight_num2"}  
btnType[1] = { isVisiable =false, iconID = 3, rankName = "", isOK = false,  }  -- 活动 ------ 已经隐藏
btnType[2] = { isVisiable =false, iconID = 5, rankName = "" , isOK = false,  keyImage3 = "ui_more_rank_sti_search"}  -- 探索
btnType[3] = { isVisiable =true, iconID = 2, rankName = "rank_combat",  key1 = "level", key2 = "combat", topKey = "top",  page = 0, } -- 战斗力 
btnType[4] = { isVisiable =true, iconID = 1, rankName = "active_top" ,  key1 = "rank", key2 = "combat",  topKey = "users", page = 5,  keyImage3 = "arena_max_level", sortKey = "rank", isRev = true}  --生存大考验
btnType[5] = { isVisiable =true, iconID = 4, rankName = "arena_top", key1 = "guild_name", key2 = "combat", topKey = "top", page = 0, keyImage3 = "arena_guild_name" }  -- 竞技场
btnType[6] = { isVisiable =false, iconID = 6, rankName = "", isOK = false, keyImage3 = "ui_more_rank_mingyun_num" }  -- 命运
btnType[7] = { isVisiable =false, iconID = 7, rankName = "" , isOK = false, keyImage3 = "ui_more_rank_winnum"}  -- 竞技场连胜

btnType[8] = { isVisiable =true, iconID = 10, rankName = "rank_boss" , keyImage3 = "ui_more_rank_hitboss"}   -- boss 战
btnType[9] = { isVisiable =true, iconID = 9, rankName = "rank_level" , key1 = "level",      key2 = "combat", topKey = "top",  page = 0 }  -- 等级
btnType[10] = { isVisiable =true, iconID = 8, rankName = "rank_guide" ,   keyImage2 = "ui_more_rank_guild_gername", keyImage3 = "ui_more_rank_guild_gname", keyImage4 = "ui_more_rank_guild_startnum", topKey = "guild_list", page = 0,
                                                     key1 = "name", key2 = "tech_lv", key3 = "role", key4 = "owner",  sortKey = "tech_lv", isMiddle = true, isRev = true}  -- 联盟
btnType[11] = { isVisiable =false, iconID = 11, rankName = "" , isOK = false, keyImage3 = "ui_more_rank_sti_search"}   -- 精英关卡


do 
    if not game_data:isViewOpenByID(13) then    
        -- btnType[10].isVisiable = false
    end
end


--[[--
    销毁ui
]]
function ui_all_rank.destroy(self)
    cclog("-----------------ui_all_rankdestroy-----------------");
    self.m_gameData = nil;
    --排行榜的控件
    self.m_rank_node = nil;
    self.m_rank_table_node = nil;
    self.m_index = nil;
    self.level_page = nil;
    self.combat_page = nil;
    self.change_flag_1 = nil;
    self.change_flag_2 = nil;
    self.count_1 = nil;
    self.count_2 = nil;
    self.lv_count = nil;
    self.combat_count = nil;


    self.m_curRankName = nil;
    self.m_curRankPage = nil;
    self.m_allRankData = nil;

    self.m_ccbNode = nil;
    self.m_openType = nil;
end
--[[--
    返回
]]
function ui_all_rank.back(self)

    if self.m_openType == "game_active_topchallenge_scene" then
        local game_active_topchallenge_scene = require("game_ui.game_active_topchallenge_scene")
        if game_active_topchallenge_scene then
            game_active_topchallenge_scene.enterScene({enterSuccCallFun = function() self:destroy() end})
        end
    elseif self.m_openType == "game_activity_live" then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local live_data = json.decode(data:getNodeWithKey("active_forever"):getFormatBuffer())
            game_scene:enterGameUi("game_activity_live",{liveData = live_data})
            game_util:rewardTipsByDataTable(reward);
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    elseif self.m_openType == "game_activity" then
        local function responseMethod(tag,gameData)
            self:back()
            game_scene:enterGameUi("game_activity",{gameData = gameData, itemIndex = 2});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end

end
--[[--
    读取ccbi创建ui
]]
function ui_all_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        -- --print(" target,event ", target , " ",event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- --print("click button and btnTag is ", btnTag)
        if btnTag == 1 then
            self:back()
        elseif btnTag == 102 then         -- 更多排行
            self:showMoreRankButtons()
        elseif btnTag >= 21 and btnTag <= 31 then         -- 战力排行榜
            self:hideMoreRankButtons()
        end
    end

    local function onButtonClick(event, target)
        -- --print(" onButtonClick target,event ", target , " ",event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag >= 21 and btnTag <= 31 then         -- 更多排行
            self:hideMoreRankButtons()

            self.m_allRankData = {}
            self.m_curRankName = btnType[ btnTag - 20].rankName
            self.m_curRankPage = 0

            self:refreshUi(btnType[ btnTag - 20].rankName, btnType[btnTag - 20].page )
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_all_rank.ccbi");
    self.m_ccbNode = ccbNode
    --排行榜的控件
    self.m_rank_node = ccbNode:nodeForName("m_arena_node_2");
    self.m_rank_table_node = ccbNode:nodeForName("rank_table_node");


    self.m_layer_btnbg = ccbNode:nodeForName("m_layer_btnbg")  -- 按钮board  
    self.m_layer_btnbg:setVisible(false)  -- 首先隐藏起来
    self.m_node_button_parent = ccbNode:nodeForName("m_node_button_parent")

    -- banner 标题
    self.m_sprite_bannerName =  ccbNode:spriteForName("m_sprite_bannerName")


    -- 排行榜小标题
    self.m_descrTitles = {}
    for i=1,4 do
        self.m_descrTitles[i] = ccbNode:spriteForName("m_sprite_detailtitle" .. i)
    end

     -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        elseif eventType == "ended" then
            self:hideMoreRankButtons()
            return true
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);


    self.m_conbtn_morerank = ccbNode:controlButtonForName("m_conbtn_morerank")
    self.m_conbtn_morerank:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_conbtn_ranks = {}

    local count = 0
    for i= 1,11 do

        local btn = self.m_node_button_parent:getChildByTag(20 + i)
        btn = tolua.cast(btn, "CCControlButton")
        btn:setVisible(false)
        -- (self,btnImgName,text,callFunc)
        local conbtn = game_util:createCCControlButton("ui_more_rank_button_" .. btnType[i].iconID .. ".png", "", onButtonClick)
        btn:getParent():addChild(conbtn)
        conbtn:setPositionX(btn:getPositionX())
        conbtn:setPositionY(btn:getPositionY())
        conbtn:setTag( btn:getTag() )
        self.m_conbtn_ranks[i] = conbtn
        self.m_conbtn_ranks[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
        if btnType[ i ].isOK == false then 
            conbtn:setEnabled(false) 
            self.m_conbtn_ranks[i]:setColor(ccc3(155, 155, 155))
            conbtn:setTouchEnabled(false)
        end
        if btnType[i].isVisiable == false then
            self.m_conbtn_ranks[i]:setVisible(false)
        end

    end
    return ccbNode;
end

function ui_all_rank.showMoreRankButtons( self )
    
    self.m_layer_btnbg:setVisible(true)
    self.m_root_layer:setTouchEnabled(true);

    for i=1, #self.m_conbtn_ranks do
        self.m_conbtn_ranks[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    end


    self.m_ccbNode:runAnimations("rankbuttons_appear")

end

function ui_all_rank.hideMoreRankButtons( self )
    self.m_layer_btnbg:setVisible(false)
    self.m_root_layer:setTouchEnabled(false);

    
    self.m_ccbNode:runAnimations("rankbuttons_disappear")




end



--[[
    创建竞技场排行榜列表
]]
function ui_all_rank.createRankTableView(self,viewSize, rankData)
    local rank_info = rankData.rankData or {}
    --print("createRankTableView by data \n ", json.encode(rank_info))
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
    local fightCount = #rank_info ;

    --print( "fightCount  is --- " , fightCount, rankData, rankData.count )


    --  local params = {};
    -- params.viewSize = viewSize;
    -- params.row = 4;
    -- params.column = 1; --列

    -- local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    -- for i=0,fightCount - 1 do
    --      local cell = nil
    --     if cell == nil then
    --         cell = CCTableViewCell:new();
    --         cell:autorelease();
    --         local ccbNode = luaCCBNode:create();
    --         ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
    --         ccbNode:openCCBFile("ccb/ui_arena_rank_item.ccbi");
    --         ccbNode:ignoreAnchorPointForPosition(false);
    --         ccbNode:setAnchorPoint(ccp(0.5,0.5))
    --         -- ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
    --         cell:addChild(ccbNode,10,10);
    --     end
    --     if cell then
    --         self:refreshCellData(cell, rank_info[i + 1], i, fightCount, itemSize  )
    --     end
    -- end



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
            self:refreshCellData(cell, rank_info[index + 1], index, fightCount , itemSize)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
        elseif eventType == "refresh" and item then

            if (self.m_curRankPage and self.m_curRankPage > 3 ) or fightCount%20 ~= 0 then
                return
            end
            self:refreshUi( self.m_curRankName, self.m_curRankPage + 1)
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    通过排行榜名字更新排行榜
]]
function ui_all_rank.refreshUi(self, rankName, page)
    --print(" will refresh ", rankName, page)
    --print(" cur rank data is ", json.encode(self.m_allRankData))
    if not self.m_allRankData then self.m_allRankData = {} end              -- 为空赋初值
    if not self.m_allRankData[rankName] then self.m_allRankData[rankName] = {} end    -- 为空赋初值
    if self.m_allRankData[rankName] and self.m_allRankData[rankName].page and self.m_allRankData[rankName].page >= page then                              -- 不为空，刷新数据
        --print("--------------- refreshUi and will refreshTabByData")
        self:refreshTabByData( self.m_allRankData[rankName] )
        return
    end



    -- 当前显示的排行榜，当前页的数据没有  去请求服务器数据
    local function responseMethod(tag,gameData)                           
        local data = gameData:getNodeWithKey("data")
        cclog("rank_level data = " .. data:getFormatBuffer())
        local rankInfo = json.decode(data:getFormatBuffer())

        --print("rankInfo  == ", json.encode(rankInfo))

        local pageData = {}

            -- 给后面两个关键key 复制 -- 用于统一显示
        local key1, key2, topKey, key4 = ui_all_rank.getKeys( rankName )
        local key3 = "role"
        local rankId = self.getRankID( self.m_curRankName ) 
        if rankId and btnType[rankId].key3 then
            key3 = btnType[rankId].key3
        end

        pageData.rankData = rankInfo[topKey]

        if pageData.rankData == nil then return end

        if key1 and key2 then
            for i,v in ipairs(pageData.rankData) do
                if type(v) == "table" then
                    pageData.rankData[i]["key1"] = v[key1]
                    pageData.rankData[i]["key2"] = v[key2]
                    pageData.rankData[i]["key3"] = v[key3]
                    pageData.rankData[i]["key4"] = v[key4]
                end
            end
        end

        local rankId = self.getRankID( self.m_curRankName )
        -- --print( "pageData.rankData  --  ", json.encode(pageData.rankData))

            local sortKey = "rank"
            if rankId and btnType[rankId].sortKey then
                sortKey = btnType[rankId].sortKey 
            end
            --print( " sort key is ",  sortKey)

        local function sortFunc(data1,data2)
            local sortKey = "rank"
            if rankId and btnType[rankId].sortKey then
                sortKey = btnType[rankId].sortKey 
            end
            --print( " sort key is ",  sortKey)

            --print("data1   data2",data1[sortKey],  data2[sortKey])

            if rankId and btnType[rankId] and btnType[rankId].isRev then
                return tonumber(data1[sortKey]) > tonumber(data2[sortKey])
            else
                return tonumber(data1[sortKey]) < tonumber(data2[sortKey])
            end
        end
        table.sort( pageData.rankData, sortFunc )

        -- --print(" cur per  rank data is ", json.encode(self.m_allRankData))
        if self.m_allRankData[rankName].rankData == nil then 
            self.m_allRankData[rankName].rankData = {}
        end
        for i=1, #pageData.rankData do
            self.m_allRankData[rankName].rankData[#self.m_allRankData[rankName].rankData + 1] = pageData.rankData[i]
        end
        -- --print(" cur next rank data is ", json.encode(self.m_allRankData))
        self.m_allRankData[rankName].count = #self.m_allRankData[rankName].rankData
        self.m_curRankPage = rankInfo.cur_page or 5

        pageData.count = #pageData.rankData
        self.m_allRankData[rankName].page = rankInfo.cur_page or 5
        -- --print(" new page is ", rankInfo.cur_page)
        self:refreshUi( rankName, self.m_curRankPage)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey( rank_type_name[rankName] ), http_request_method.GET, {page = page, guiderank = 1}, rank_type_name[rankName])
end

--[[--
    更新排行榜数据
]]

--[[
    刷新表2
]]
function ui_all_rank.refreshTabByData(self, data)

    -- 更新banner 标题
    local rankID = self.getRankID( self.m_curRankName )
    if rankID then
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( "ui_more_rank_banner_" .. btnType[rankID]["iconID"] .. ".png" )
        if tempSpriteFrame then
            self.m_sprite_bannerName:setDisplayFrame( tempSpriteFrame)
        else
            self.m_sprite_bannerName:setVisible( false )
        end
    else
        self.m_sprite_bannerName:setVisible( false )
    end

    -- 更新排行榜小标题
    local keyImages = self.getImageName( self.m_curRankName)
    --print( "m_curRankName  keyImage1, keyImage2, keyImage3, keyImage4 === ", self.m_curRankName , "--", json.encode(keyImages) )
    for i=1,4 do
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( keyImages[ "keyImage" .. i ] .. ".png" )
        --print( "tempSpriteFrame == ", i, "  ", keyImages[ "keyImage" .. i ], " ",  tempSpriteFrame )
        if tempSpriteFrame then
            self.m_descrTitles[i]:setDisplayFrame( tempSpriteFrame)
        end
        tempSpriteFrame = nil
        -- self.m_descrTitles[i]:setVisible(false)
    end

    self.m_rank_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createRankTableView(self.m_rank_table_node:getContentSize(), data)
    textTableTemp:setScrollBarVisible(false)
    self.m_rank_table_node:addChild(textTableTemp,10,10);

    local com_index = math.min(self.m_curRankPage * 20, self.m_allRankData[self.m_curRankName].count - 4)
    if self.m_curRankPage and self.m_curRankPage <= 4 then
        game_util:setTableViewIndex(com_index,self.m_rank_table_node,10,4)
    end
    
end

function ui_all_rank.refreshCellData( self, cell, cellInfo, cellIndex, cellCount , itemSize)
    --print(" refreshCellData args ", cell, cellInfo, cellIndex, cellCount, json.encode( cellInfo ))
    if not cell then return end
    if not cellInfo then return end
    cellIndex = cellIndex or 0
    local ccbNode = tolua.cast( cell:getChildByTag(10), "luaCCBNode" )
    local cellBg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")

    --
    local user_head_node = ccbNode:nodeForName("m_icon_node");
    local user_rank_label = ccbNode:labelBMFontForName("rank_number");
    local user_name_label = ccbNode:labelTTFForName("m_user_label");
    local top_icon = ccbNode:spriteForName("top_icon");
    local label_info1 = ccbNode:labelTTFForName("m_guild_label");
    local blabel_info2 = ccbNode:labelBMFontForName("fight_point_label");

    local test_label = ccbNode:spriteForName("test_label")
    local m_sprite9_pointbg = ccbNode:scale9SpriteForName("m_sprite9_pointbg")
    local rankId = self.getRankID( self.m_curRankName )
        --print("   rankId   test_bale", rankId,"  ", test_label, "   ", m_sprite9_pointbg )
    if rankId and btnType[rankId].isMiddle then
        test_label:setVisible(false)
        m_sprite9_pointbg:setPositionY( 15 )
        blabel_info2:setPositionY( 26 )
    else
        test_label:setVisible(true)
        m_sprite9_pointbg:setPositionY( 8 )
        blabel_info2:setPositionY( 17 )

    end



    -- cell 上的 btn 设置
    local btn_look = ccbNode:controlButtonForName("btn_look")
    btn_look:setTag(1001 + cellIndex)
    btn_look:setOpacity(0)
    -- 前3名
    local user_info = cellInfo
    local color = {{255,189,56}, {253,219,134}, {250,247,191}}
    if cellIndex >= 0 and cellIndex < 3 then  

        top_icon:setVisible( true )
        local frame_name = {"arena_gold.png","arena_silver.png","arena_copper.png"}
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( tostring(frame_name[cellIndex + 1]) )
        if tempSpriteFrame then
            top_icon:setDisplayFrame(tempSpriteFrame)
        end

        cellBg:setColor(ccc3(color[cellIndex + 1][1], color[cellIndex + 1][2], color[cellIndex + 1][3]))
    else
        top_icon:setVisible(false)
        cellBg:setColor(ccc3(255, 255, 255))
    end
    user_name_label:setString(tostring(user_info.key4 or "error"))   -- 用户名
    local hightest_level = tonumber(user_info.rank) or 0
    user_rank_label:setString(tostring(cellIndex + 1))
    local ginfo = tostring(user_info.key1 or "")
    if ginfo == "" and  self.m_curRankName == "arena_top" then
        ginfo = "none"
    end
    label_info1:setString(ginfo)

    local sb_name = {}
    local sb_guild = {}
    for i=1,4 do
        sb_name[i] = ccbNode:labelTTFForName("m_user_label_" .. i);
        sb_name[i]:setVisible(false);
        sb_guild[i] = ccbNode:labelTTFForName("m_guild_label_" .. i);
        sb_guild[i]:setVisible(false)  
    end

    -- 人物头像
    local icon = game_util:createPlayerIconByRoleId(tostring(user_info.key3));
    local icon_alpha = game_util:createPlayerIconByRoleId(tostring(user_info.key3));
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
    blabel_info2:setString(tostring(user_info.key2));

    -- 下拉刷新请求下一个page排名信息
        --print( "-------------  index "  , index, " cellCount  ",  cellCount - 1)
    if cellCount % 20 == 0 and cellIndex == cellCount - 1 and self.m_curRankPage < 4 then
        --print( "-------------  index "  , index )

        local tipLabel = game_util:createLabelTTF({text = ui_all_rank.text,color = ccc3(250,180,0),fontSize = 12});
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


--[[--
    初始化
]]
function ui_all_rank.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_openType = t_params.openType or "";
    if t_params.gameData ~= nil then
        self.m_gameData = t_params.gameData
    end
    self.m_curRankName = t_params.rankName  -- rankName 
    self.m_curRankPage = 0
    --print(" get game  gamedata is ", json.encode(self.m_gameData))
    local key1, key2 , topKey, key4 = ui_all_rank.getKeys( t_params.rankName )
    local rankId = self.getRankID( self.m_curRankName ) 
    local key3 = "role"
    if rankId and btnType[rankId].key3 then
        key3 = btnType[rankId].key3
    end
    local playerRank = self.m_gameData[topKey]
    --print("per playerRank === ", json.encode(playerRank))
    -- 给后面两个关键key 复制 -- 用于统一显示
    if key1 and key2 then
        for i,v in ipairs(playerRank) do
            --print( "v == ",v, "\n == ", json.encode(v))
            if type(v) == "table" then
                playerRank[i]["key1"] = v[key1]
                playerRank[i]["key2"] = v[key2]
                playerRank[i]["key3"] = v[key3]
                playerRank[i]["key4"] = v[key4]
            end
        end
    end

    if type(playerRank) ~= "table" then return end

    local rankId = self.getRankID( self.m_curRankName )
    -- --print( "pageData.rankData  --  ", json.encode(pageData.rankData))
    -- local count_2 = rankInfo.count 
    local function sortFunc(data1,data2)
        local sortKey = "rank"
        if rankId and btnType[rankId].sortKey then
            sortKey = btnType[rankId].sortKey 
        end
        if rankId and btnType[rankId] and btnType[rankId].isRev then
            return tonumber(data1[sortKey]) > tonumber(data2[sortKey])
        else
            return tonumber(data1[sortKey]) < tonumber(data2[sortKey])
        end
    end
    table.sort( playerRank, sortFunc )
    -- 解析第一次数据  
    self.m_allRankData = {}
    self.m_curRankPage =  self.m_gameData["cur_page"] or 0  -- page
    if self.m_curRankName == "active_top" then self.m_curRankPage = 5 end
    local rankData = {}
    rankData.count = #playerRank
    rankData.rankData = playerRank
    rankData.page = self.m_curRankPage
    self.m_allRankData[self.m_curRankName] = rankData
end

--[[--
    创建ui入口并初始化数据
]]
function ui_all_rank.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi(self.m_curRankName, self.m_curRankPage);
    return scene;
end

function ui_all_rank.enterAllRankByRankName( rankName , enterCallBack, params )
    params = params or {}
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog("data = " .. data:getFormatBuffer())
        game_scene:enterGameUi("ui_all_rank",{gameData = json.decode(data:getFormatBuffer()), rankName = rankName, openType = params.openType})
        if type(enterCallBack) == "function" then enterCallBack() end
    end
    rankName = rankName or "rank_combat"
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey( rank_type_name[rankName] ), http_request_method.GET, {page = 0}, rank_type_name[rankName] )
end

function ui_all_rank.getKeys( rankName )
    for i,v in ipairs(btnType) do
        if v.rankName == rankName then
            -- --print( "v.rankName == rankName   ", v.rankName , rankName, v.key1, v.key2 )
            return v.key1 or "score" , v.key2 or "combat", v.topKey or "top", v.key4 or "name"
        end
    end
    return nil
end

function ui_all_rank.getImageName(  rankName )
    for i,v in ipairs(btnType) do
        if v.rankName == rankName then
            local images = {}
            for i=1,4 do
                images["keyImage" .. i] = v["keyImage" .. i] or defaultImageKeyName["keyImage" .. i]
            end
            return images
        end
    end
    return defaultImageKeyName
end

function ui_all_rank.getRankID(  rankName )
    --print("will check id ", rankName)
    for i,v in ipairs(btnType) do
            --print("check it  v.rankName == rankName   ", v.rankName , rankName , " i ", i)
        if v.rankName == rankName then
            --print("find it and id is ", i)
            return i
        end
    end
    return nil
end


return ui_all_rank;