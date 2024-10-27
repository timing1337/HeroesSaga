---  福利公告

local game_fuli_subui_annoucement = {
    m_list_view_bg = nil, -- 左侧活动列表board
    m_tableView = nil, -- 左侧的tableview
    m_curShowActivityID = nil, -- 当前选中的活动id
    m_curSelectActivityCell= nil, -- 当前选中的cell
    m_root_layer = nil,
    m_close_btn = nil,
    adver_Id = nil,
    m_sprite_unselect = nil,
    m_sprite_select = nil, 
    m_showData = nil,
    m_popUi = nil,
    m_label_msgtitles = nil,
    m_textInfo = nil,
    m_lastRefreshTime = nil,
    m_node_slider_tboard = nil,
    m_layer_touchpos = nil,
    m_node_contentbar_board = nil,
    m_actionNode = nil,
    m_actionNode2 = nil,
};
--[[--
    销毁ui
]]
function game_fuli_subui_annoucement.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_annoucement destroy-----------------");  
    self.m_list_view_bg = nil; -- 左侧活动列表board
    self.m_tableView = nil; -- 左侧的tableview
    self.m_curShowActivityID = nil; -- 当前选中的活动id
    self.m_curSelectActivityCell= nil; -- 当前选中的cell
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.adver_Id = nil;
    self.m_sprite_unselect = nil;
    self.m_sprite_select = nil; 
    self.m_showData = nil;
    self.m_popUi = nil;
    self.m_label_msgtitles = nil;
    self.m_textInfo = nil;
    self.m_lastRefreshTime = nil;
    self.m_node_slider_tboard = nil;
    self.m_layer_touchpos = nil;
    self.m_node_contentbar_board = nil;
    self.m_actionNode = nil;
    self.m_actionNode2 = nil;
end
--[[--
    返回
]]
function game_fuli_subui_annoucement.back(self,backType)
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_annoucement.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            -- self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_content_announce.ccbi");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_node_slider_tboard = ccbNode:nodeForName("m_node_slider_tboard")
    self.m_node_contentbar_board = ccbNode:nodeForName("m_node_contentbar_board")

    self.m_scro_showinfo = ccbNode:scrollViewForName("m_scro_showinfo")
    self.m_node_labellimit = ccbNode:nodeForName("m_node_labellimit")


    self.m_label_msgtitles = {}
    for i=1,3 do
        local label = ccbNode:labelTTFForName("m_label_msgtitle_" .. i)
        if label then
           self.m_label_msgtitles[#self.m_label_msgtitles + 1] = label
        end 
    end

    -- 重置 scrollview 触摸优先级  防止被吞
    self.m_scro_showinfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16);
    self.m_actionNode = CCNode:create()
    ccbNode:addChild(self.m_actionNode)
    self.m_actionNode2 = CCNode:create()
    ccbNode:addChild(self.m_actionNode2)
    return ccbNode;
end

function game_fuli_subui_annoucement.updateRichLabel(self,showMsg)


    self.m_scro_showinfo:getContainer():removeAllChildrenWithCleanup(true)
    local sNode = CCNode:create()
    sNode:setAnchorPoint(ccp(0, 1))
    self.showInfoNode = sNode;
    self.m_scro_showinfo:getContainer():addChild(self.showInfoNode)

    local itemSize = CCSizeMake(self.m_node_labellimit:getContentSize().width , 0)
    local richLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    

    sNode:setContentSize(CCSizeMake(itemSize.width, richLabel:getContentSize().height))
    sNode:setPosition(0, richLabel:getContentSize().height)

    richLabel:setAnchorPoint(ccp(0.5, 1))
    richLabel:setPosition(ccp( richLabel:getContentSize().width * 0.5,  richLabel:getContentSize().height))
    self.showInfoNode:removeAllChildrenWithCleanup(true)
    self.showInfoNode:addChild(richLabel,10,10)

    local laSize = richLabel:getContentSize()
    self.m_scro_showinfo:setContentSize(laSize)
    self.m_scro_showinfo:setContentSize(CCSizeMake(itemSize.width, laSize.height))


    -- -- scroll 出现的时候显示成顶端
    local offsetY = laSize.height - self.m_scro_showinfo:getViewSize().height
    -- print("offsetY = ", offsetY)
    self.m_scro_showinfo:setContentOffset(ccp(0, -offsetY), false)
end
--[[--
    刷新ui
]]
function game_fuli_subui_annoucement.refreshDetailInfo(self, adver_Id)
    local annoucement_cfg = getConfig(game_config_field.adver)
    -- print("   ----  annoucement_cfg info  ", annoucement_cfg:getFormatBuffer())
    local itemCfg = annoucement_cfg:getNodeWithKey(tostring(adver_Id))
    if itemCfg == nil then return end
    local showMsg = itemCfg:getNodeWithKey("word"):toStr();
    local title = itemCfg:getNodeWithKey("title") and itemCfg:getNodeWithKey("title"):toStr() or string_helper.game_fuli_subui_annoucement.title;
    for i=1,3 do
        if self.m_label_msgtitles[i] then
            self.m_label_msgtitles[i]:setString(title)
        end
    end
    self:updateRichLabel(showMsg);
end

--[[--
    刷新新的内容
]]
function game_fuli_subui_annoucement.createMsgContent( self )

    local annoucement_cfg = getConfig(game_config_field.adver)
    local tempData = self.m_showData
    local textTable = {}
    local node = CCNode:create()
    local itemSize = CCSizeMake(self.m_node_labellimit:getContentSize().width , 0)
    local height = 0
    for i=1, #tempData or 0 do
        local itemData = tempData[i ] or {}
        local itemCfg = itemData.itemCfg
        local showMsg = itemCfg:getNodeWithKey("word"):toStr();
        showMsg = self:changeStr(showMsg, itemData.changeStrTab)
        -- cclog2(showMsg, "showMsg" .. i .. "  ===   ")
        local richLabel = game_util:createRichLabelTTF({text = showMsg,dimensions = itemSize,textAlignment = kCCTextAlignmentLeft,
            verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255, 255, 255),fontSize = 11})
        -- cclog2(richLabel, "richLabel" .. i .. "  ===   ")
        if richLabel then
            height = height + richLabel:getContentSize().height + 40
            node:addChild(richLabel, 0 , i + 100)
        end
    end
    node:setContentSize(CCSizeMake(itemSize.width, height))
    -- cclog2(tempData, "tempData  ====  ")
    local itemSize = CCSizeMake(self.m_node_labellimit:getContentSize().width , 0)
    local y = height
    for i=1, #tempData or 0 do
        textTable[i] = {posY = y, height = 0}
        local label = node:getChildByTag(i + 100)
        if label then
            local richLabel = tolua.cast(label, "CCNode")
            if richLabel then
                local itemData = tempData[i] or {}
                local itemCfg = itemData.itemCfg
                local title = itemCfg:getNodeWithKey("ad_title") and itemCfg:getNodeWithKey("ad_title"):toStr() or string_helper.game_fuli_subui_annoucement.title;
                y = y - 20
                for i= 1, 4 do
                    local label = game_util:createRichLabelTTF({text = title,dimensions = itemSize,textAlignment = kCCTextAlignmentCenter,
                            verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(255, 255, 255),fontSize = 14})
                    label:setPosition(ccp(itemSize.width * 0.5,  y))
                    node:addChild(label)
                end
                y = y - 20
                textTable[i].height = richLabel:getContentSize().height
                richLabel:setAnchorPoint(ccp(0.5, 1))
                richLabel:setPosition(ccp( richLabel:getContentSize().width * 0.5,  y))
                y = y - richLabel:getContentSize().height
            end
        end
    end
    self.m_textInfo = textTable

    self.m_scro_showinfo:getContainer():removeAllChildrenWithCleanup(true)
    node:setAnchorPoint(ccp(0, 1))
    self.showInfoNode = node;
    self.m_scro_showinfo:getContainer():addChild(self.showInfoNode)

    node:setPosition(0, height)
    -- self.m_scro_showinfo:setContentSize(node:getContentSize())
    self.m_scro_showinfo:setContentSize(CCSizeMake(itemSize.width, height))
    -- -- scroll 出现的时候显示成顶端
    local offsetY = height - self.m_scro_showinfo:getViewSize().height
    -- print("offsetY = ", offsetY)
    self.m_scro_showinfo:setContentOffset(ccp(0, -offsetY), false)


    local boardSize = self.m_node_contentbar_board:getContentSize()
    self.m_node_contentbar_board:removeChildByTag(101,true)
    local sboard = CCScale9Sprite:createWithSpriteFrameName("ui_announce_reshuadong.png")
    sboard:setPosition(boardSize.width * 0.5, boardSize.height * 0.5)
    sboard:setPreferredSize(CCSizeMake(6, boardSize.height))
    self.m_node_contentbar_board:addChild(sboard , -1, 121)



    local tempSize = self.m_node_slider_tboard:getContentSize()
    local vHeight = self.m_scro_showinfo:getViewSize().height
    local sh = vHeight / height
    local bh = sh * tempSize.height
    self.m_node_slider_tboard:removeChildByTag(101, true)
    self.m_slider_t = CCScale9Sprite:createWithSpriteFrameName("ui_announce_reshuadong_1.png")
    self.m_slider_t:setPositionX(tempSize.width * 0.5)
    self.m_slider_t:setPositionY(tempSize.height * 0.95)
    self.m_slider_t:setPreferredSize(CCSizeMake(tempSize.width, bh))
    self.m_node_slider_tboard:addChild(self.m_slider_t, 10, 101)

    local lheight = height - self.m_scro_showinfo:getViewSize().height

    schedule(self.m_actionNode2, function ( )
        local offset = self.m_scro_showinfo:getContentOffset()
        local cy = -1 * offset.y
        local sy = cy / lheight
        sy = math.min(sy, 1)
        local y = tempSize.height * sy - bh * 0.5
        y = math.max(bh * 0.5, tempSize.height * sy - bh * 0.5)
        local ddy =  y - self.m_slider_t:getPositionY()
        if ddy > 0.2 or ddy< -0.2 then 
        -- if math.floor(ddy) > 0 then 
            self.m_slider_t:stopAllActions()
            self.m_slider_t:runAction(CCMoveBy:create( 0.19, ccp(0, y - self.m_slider_t:getPositionY() )))
        -- self.m_slider_t:setPositionY( y)
        -- end
        end
    end, 0.2)

end

--[[--
    重置bar的位置
]]
function game_fuli_subui_annoucement.resetBarPos( self, posY )
    -- body
end




--[[--
    刷新ui
]]
function game_fuli_subui_annoucement.createOpeningTabelView(self)
    -- if self.m_tableView == nil then
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        self.m_tableView = self:createActivityTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(self.m_tableView);
    -- end
end
--[[--
    刷新ui
]]
function game_fuli_subui_annoucement.refreshUi(self)
    self:formatData()
    self:createOpeningTabelView();
    self:createMsgContent()

    self.m_actionNode:stopAllActions()
    if self.m_lastRefreshTime > 0 then
        schedule(self.m_actionNode, function (  )
            self:refreshUi()
        end, self.m_lastRefreshTime)
    end
    -- 更新信息
    -- mark do
    -- self:refreshDetailInfo(self.m_showData[1]);
    
end
--[[--
    初始化
]]
function game_fuli_subui_annoucement.init(self,t_params)
    t_params = t_params or {};
    -- 获得数据
    -- local data = t_params.gameData:getNodeWithKey("data")
    self.m_curShowActivityID = 0;
    self.m_endCallFunc = t_params.endCallFunc
end

--[[
    格式化显示数据
]]
function game_fuli_subui_annoucement.formatData( self )

    self.m_lastRefreshTime = 999999999
    local tempDataOld = self:initOldServerAdver()
    local tempDataNew = self:initNewServerAdver()
    self.m_showData = {};

    for i,v in ipairs(tempDataOld) do
        table.insert(self.m_showData,v )
    end
    for i,v in ipairs(tempDataNew) do
        table.insert(self.m_showData,v )
    end

    local function sortFunc(data1,data2)
        return tonumber(data1.adver_id) < tonumber(data2.adver_id)
    end
    table.sort( self.m_showData, sortFunc )
    self.m_lastRefreshTime = self.m_lastRefreshTime + 5
    -- 获取新服公告显示条目
    -- 获取老服公告显示条目
end

--[[
    字符串替换
]]
function game_fuli_subui_annoucement.changeStr( self, perStr, turnStrTab )
    turnStrTab = turnStrTab or {}
    local text = perStr or ""
    local patt = nil
    local info = {}
    -- cclog2(turnStrTab, "turnStrTab   ====   ")
    for i,v in pairs(turnStrTab) do
        if type(v) == "string" then
            local patt = "[" .. i .. "]+"
            text = string.gsub(text, patt, function ( key )
                return turnStrTab[key] or key
            end)
        end
    end
    return text
end

--[[
    初始化新服公告显示条目
]]
function game_fuli_subui_annoucement.initNewServerAdver( self )
    local annoucement_cfg = getConfig(game_config_field.server_adver)
    if not annoucement_cfg then return {} end
    local tempData = {};
    local annoucement_cfg_count = annoucement_cfg:getNodeCount();
    local server_time = game_data:getUserStatusDataByKey("server_time")
    for i=1,annoucement_cfg_count do
        local itemCfg = annoucement_cfg:getNodeAt(i-1)
        local server_time_cfg = itemCfg:getNodeWithKey("server_time") 
        local server_day = server_time_cfg and server_time_cfg:toInt() or 0
        if not game_util:isInServertimeInServerday( server_day ) then
            local start_time_str = itemCfg:getNodeWithKey("start_time") and itemCfg:getNodeWithKey("start_time"):toStr() or ""
            local end_time_str = itemCfg:getNodeWithKey("end_time") and itemCfg:getNodeWithKey("end_time"):toStr() or ""
            local start_time = game_util:parseDDHHMMTime1( start_time_str )
            local end_time = game_util:parseDDHHMMTime1( end_time_str )
            if start_time >= 0 and end_time >=0 then
                if start_time > server_time and start_time - server_time < self.m_lastRefreshTime then
                    self.m_lastRefreshTime = start_time - server_time

                elseif end_time > server_time and end_time - server_time < self.m_lastRefreshTime then
                    self.m_lastRefreshTime = end_time - server_time
                end
                self.m_lastRefreshTime = -9999
            end

            local startTimeStr = os.date(string_helper.game_fuli_subui_annoucement.time, start_time)
            local endTimeStr = os.date(string_helper.game_fuli_subui_annoucement.time, end_time)
            local timeInfo = tostring(startTimeStr) .. "-" .. tostring(endTimeStr)

             -- cclog2(self.m_lastRefreshTime, "self.m_lastRefreshTime == ")
            if (start_time < server_time and end_time > server_time ) or  start_time < 0 then
                tempData[#tempData + 1] = {adver_id = itemCfg:getKey(), itemCfg = itemCfg, changeStrTab = {STARTTIMEENDTIME = timeInfo}};
            end
        end
    end
    return tempData
end

--[[
    初始化老服公告显示条目
]]
function game_fuli_subui_annoucement.initOldServerAdver( self )
    local annoucement_cfg = getConfig(game_config_field.adver)
    if not annoucement_cfg then return {} end
    local tempData = {};
    local annoucement_cfg_count = annoucement_cfg:getNodeCount();
    local server_time = game_data:getUserStatusDataByKey("server_time")
    for i=1,annoucement_cfg_count do
        local itemCfg = annoucement_cfg:getNodeAt(i-1)
        local server_time_cfg = itemCfg:getNodeWithKey("server_time") 
        local server_day = server_time_cfg and server_time_cfg:toInt() or 0
        if not game_util:isInServertimeInServerday( server_day ) then
            local start_time = itemCfg:getNodeWithKey("start_time") and itemCfg:getNodeWithKey("start_time"):toInt() or -1
            local end_time = itemCfg:getNodeWithKey("end_time") and itemCfg:getNodeWithKey("end_time"):toInt() or -1
            if start_time >= 0 and end_time >=0 then
                if start_time > server_time and start_time - server_time < self.m_lastRefreshTime then
                    self.m_lastRefreshTime = start_time - server_time

                elseif end_time > server_time and end_time - server_time < self.m_lastRefreshTime then
                    self.m_lastRefreshTime = end_time - server_time
                end
                self.m_lastRefreshTime = -9999
            end

            -- cclog2(self.m_lastRefreshTime, "self.m_lastRefreshTime == ")
            if (start_time < server_time and end_time > server_time ) or  start_time < 0 then
                tempData[#tempData + 1] = {adver_id = itemCfg:getKey(), itemCfg = itemCfg};
            end
        end
    end
    return tempData
end


--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_annoucement.create(self,t_params)
    -- cclog2(t_params, "t_params  ===   ")
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end
--[[--
    创建左侧开服活动的列表
]]
function game_fuli_subui_annoucement.createActivityTableView( self, viewSize )
    self.m_curSelectActivityCell = nil;
    local annoucement_cfg = getConfig(game_config_field.adver)
    local tempData = self.m_showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/annoucement_list.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end

        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            local itemData = tempData[index + 1] or {}
            local itemCfg = itemData.itemCfg
            -- 公告标题
            local title = string_helper.game_fuli_subui_annoucement.title;
            if itemCfg then
                title = itemCfg:getNodeWithKey("title") and itemCfg:getNodeWithKey("title"):toStr() or string_helper.game_fuli_subui_annoucement.title
            end

            local fontSize = 12
            if string.len(title) > 7*3 then fontSize = 10 end
            for i=1,4 do
                local label = ccbNode:labelTTFForName("m_label_title_" .. i)
                if label then
                    label:setFontSize(fontSize)
                    label:setString(title)
                end
            end

            -- 公告类型标签
            local m_sprite_titleIcon = ccbNode:spriteForName("m_sprite_titleIcon")
            if m_sprite_titleIcon and itemCfg then
                m_sprite_titleIcon:setVisible(false)
                local iconType =  itemCfg:getNodeWithKey("adver_type") and itemCfg:getNodeWithKey("adver_type"):toStr() or math.random(1,4)
                local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
                if iconType then
                    local frame = sharedSpriteFrameCache:spriteFrameByName("biaoqian_" .. iconType .. ".png")
                    if frame then
                        m_sprite_titleIcon:setDisplayFrame( frame )
                        m_sprite_titleIcon:setVisible(true)
                    end
                end
            end

            -- 公告标签
            local m_sprite_titleType = ccbNode:spriteForName("m_sprite_titleType")
            if m_sprite_titleType and itemCfg then
                m_sprite_titleType:setVisible(false)
                local mark =  itemCfg:getNodeWithKey("mark") and itemCfg:getNodeWithKey("mark"):toStr() or math.random(1,2)
                local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
                if mark then
                    local frame = sharedSpriteFrameCache:spriteFrameByName("ui_announce_h" .. mark .. ".png")
                    if frame then
                        m_sprite_titleType:setDisplayFrame( frame )
                        m_sprite_titleType:setVisible(true)
                    end
                end
            end

            local m_sprite_board_1 = ccbNode:spriteForName("m_sprite_board_1")
            local m_sprite_board_2 = ccbNode:spriteForName("m_sprite_board_2")

            local wwidth = m_sprite_titleType:getParent():getContentSize().width
            if self.m_curShowActivityID == index then
                m_sprite_board_2:setVisible(true);
                m_sprite_titleType:setPositionX(wwidth * 0.87)
                m_sprite_board_1:setVisible(false);
                self.m_curSelectActivityCell = cell
            else
                m_sprite_board_2:setVisible(false);
                m_sprite_board_1:setVisible(true);
                m_sprite_titleType:setPositionX(wwidth * 0.78)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" and cell then

            if self.m_curSelectActivityCell then
                local ccbNode = tolua.cast(self.m_curSelectActivityCell:getChildByTag(10),"luaCCBNode")
                local m_sprite_board_1 = ccbNode:spriteForName("m_sprite_board_1")
                local m_sprite_board_2 = ccbNode:spriteForName("m_sprite_board_2")
                m_sprite_board_2:setVisible(false);
                m_sprite_board_1:setVisible(true);
                local m_sprite_titleType = ccbNode:spriteForName("m_sprite_titleType")
                local wwidth = m_sprite_titleType:getParent():getContentSize().width
                m_sprite_titleType:setPositionX(wwidth * 0.78)
            end

            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_sprite_board_1 = ccbNode:spriteForName("m_sprite_board_1")
            local m_sprite_board_2 = ccbNode:spriteForName("m_sprite_board_2")

            local m_sprite_titleType = ccbNode:spriteForName("m_sprite_titleType")
            local wwidth = m_sprite_titleType:getParent():getContentSize().width
            -- 更新新的选中cell状态
            self.m_curShowActivityID = index 
            self.m_curSelectActivityCell = cell
            m_sprite_board_2:setVisible(true);
            m_sprite_board_1:setVisible(false);
            m_sprite_titleType:setPositionX(wwidth * 0.87)

            local posY = self.m_textInfo[index + 1].posY
            local offsetY = posY - self.m_scro_showinfo:getViewSize().height
            if offsetY < 0 then offsetY = 0 end
            -- self.m_scro_showinfo:stopDeaccelerateScrolling()
            self.m_scro_showinfo:setContentOffsetInDuration(ccp(0, -offsetY), 0.3)


            -- local key = tempData[index + 1]
            -- -- self:refreshDetailInfo(key);
            -- self:createMsgContent()
        end
    end
    local tview = TableViewHelper:create(params)
    tview:setScrollBarVisible(false)
    return tview
end

--[[--
    创建右侧的下拉条
]]
function game_fuli_subui_annoucement.initContentBar( self )
    local tempSize = self.m_node_slider_tboard:getContentSize()
    local sidebar = CCControlSlider:create()



end


return game_fuli_subui_annoucement;
