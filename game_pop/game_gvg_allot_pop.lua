--- gvg分配奖励
local game_gvg_allot_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    
    att_btn = nil,
    def_btn = nil,
    m_open_btn = nil,
    rank_node = nil,
    log_node = nil,

    btn_back = nil,
    reward_node = nil,
    log_node = nil,
    players = nil,
};
--[[--
    销毁
]]
function game_gvg_allot_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_allot_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    
    self.att_btn = nil;
    self.def_btn = nil;
    self.m_open_btn = nil;
    self.rank_node = nil;
    self.log_node = nil;

    self.btn_back = nil;
    self.reward_node = nil;
    self.log_node = nil;
    self.players = nil;
end
--[[--
    返回
]]
function game_gvg_allot_pop.back(self,type)
    game_scene:removePopByName("game_gvg_allot_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_allot_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_allot_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.btn_back = ccbNode:controlButtonForName("btn_back")
    self.reward_node = ccbNode:nodeForName("reward_node")
    self.log_node = ccbNode:nodeForName("log_node")

    self.btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    排行榜
]]
function game_gvg_allot_pop.createRankTable(self,viewSize)
    local rewardTable = self.m_tGameData.reward
    local idTable = {}
    for k,v in pairs(rewardTable) do
        table.insert( idTable, k )
    end
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " ..btnTag)

        local itemKey = idTable[btnTag+1]
        local itemData = rewardTable[tostring(itemKey)]
        local status = itemData.status
        --把key 传到下一层
        if status == 0 then
            game_scene:addPop("game_gvg_allot_people_pop",{players = self.players,itemKey = itemKey})
            self:back()
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = game_util:getTableLen(rewardTable);
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_gvg_allot_item.ccbi");
            ccbNode:controlButtonForName("m_user_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-12)
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local m_name = ccbNode:labelTTFForName("m_name")
            local m_user_btn = ccbNode:controlButtonForName("m_user_btn")
            game_util:setCCControlButtonTitle(m_user_btn,string_helper.ccb.text211)
            local m_count = ccbNode:labelBMFontForName("m_count")
            local m_imgNode = ccbNode:nodeForName("m_imgNode")

            local allot_node = ccbNode:nodeForName("allot_node")
            local log_label = ccbNode:labelTTFForName("log_label")

            m_imgNode:removeAllChildrenWithCleanup(true)
            local itemKey = idTable[index+1]
            local itemData = rewardTable[tostring(itemKey)]

            local reward = itemData.reward
            local icon,name,count = game_util:getRewardByItemTable(reward)
            local myUid = game_data:getUserStatusDataByKey("uid")
            
            m_user_btn:setTag(index)
            if icon then
                m_imgNode:addChild(icon)
                m_name:setString(name)
            end
            if count > 1 then
                m_count:setString("×" .. count)
            else
                m_count:setString("")
            end
            if itemData.status == 0 then--没领过
                allot_node:setVisible(false)
                m_user_btn:setVisible(true)
                if myUid == self.m_tGameData.owner then
                    -- m_user_btn:setEnabled(true)
                    m_user_btn:setVisible(true)
                else
                    m_user_btn:setVisible(false)
                    -- m_user_btn:setEnabled(false)
                end
            else
                allot_node:setVisible(true)
                m_user_btn:setVisible(false)
                log_label:setString(itemData.name)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemKey = idTable[index+1]
            local itemData = rewardTable[tostring(itemKey)]
            local reward = itemData.reward
            game_util:lookItemDetal(reward)
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[
    log
]]
function game_gvg_allot_pop.createLogTable(self,viewSize)
    local logTable = self.m_tGameData.reward_log
    local tabCount = game_util:getTableLen(logTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_gvg_log_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local rich_label_node = ccbNode:nodeForName("rich_label_node");

            local richLabel = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(130,28),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)});
            local logData = logTable[tabCount-index] or {}

            local icon,name,count,rewardType,quality = game_util:getRewardByItemTable(logData.reward)
            local allotTime = logData.add_time
            local timeTab = os.date("*t",allotTime)
            local hour = timeTab.hour
            local min = timeTab.min
            if hour < 10 then hour = "0" .. hour end
            if min < 10 then min = "0" .. min end

            -- local rgba = game_util:getColorCfgByRewardType(rewardType,logData.reward[3])
            quality = quality or 0;
            if quality < 0 or quality > 6 then
                quality = 0;
            end
            local colorStr = "[color=" .. HERO_QUALITY_COLOR_TABLE[quality+1].rgba .. "]"
            local logStr =  "[color=fffcb103]" .. logData.owner_name .. "[/color]" .. "将" .. colorStr .. name .. "[/color]" .."分配给" .. "[color=fffcb103]" .. logData.name .. "[/color]" .. "(" .. timeTab.month .. "/" .. timeTab.day .. ")"
            richLabel:setString(logStr)
            rich_label_node:removeAllChildrenWithCleanup(true)
            rich_label_node:addChild(richLabel)

            local timeLabel = ccbNode:labelTTFForName("time_label")
            timeLabel:setString("")
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_gvg_allot_pop.refreshUi(self)
    --排行榜
    self.reward_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.reward_node:getContentSize());
    self.reward_node:addChild(tableView,10,10);
    --即时信息
    self.log_node:removeAllChildrenWithCleanup(true)
    local logTableView = self:createLogTable(self.log_node:getContentSize());
    self.log_node:addChild(logTableView,10,10);
end

--[[--
    初始化
]]
function game_gvg_allot_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_showType = t_params.showType or 1;
    self.players = t_params.players or {}
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_allot_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_gvg_allot_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_allot_pop;