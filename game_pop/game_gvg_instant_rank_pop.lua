--- 战场即时排名
local game_gvg_instant_rank_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    
    att_btn = nil,
    def_btn = nil,
    m_open_btn = nil,
    rank_node = nil,
    log_node = nil,
    callBackFunc = nil,
};
--[[--
    销毁
]]
function game_gvg_instant_rank_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_instant_rank_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    
    self.att_btn = nil;
    self.def_btn = nil;
    self.m_open_btn = nil;
    self.rank_node = nil;
    self.log_node = nil;
    self.callBackFunc = nil;
end
--[[--
    返回
]]
function game_gvg_instant_rank_pop.back(self,type)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_gvg_instant_rank_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_instant_rank_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        else--查看攻击
            local index = btnTag - 100
            if index ~= self.m_showType then
                self.m_showType = index
                self:refreshUi()
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_war_info.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.att_btn = ccbNode:controlButtonForName("att_btn")
    self.def_btn = ccbNode:controlButtonForName("def_btn")
    self.m_open_btn = ccbNode:controlButtonForName("m_open_btn")

    self.rank_node = ccbNode:nodeForName("rank_node")
    self.log_node = ccbNode:nodeForName("log_node")

    self.att_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.def_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    self.m_open_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);

    local function animCallFunc(animName)
        
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations("enterAnim")
    return ccbNode;
end

--[[
    排行榜
]]
function game_gvg_instant_rank_pop.createRankTable(self,viewSize)
    local rankTable = {}
    if self.m_showType == 1 then
        self.att_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab.png"),CCControlStateNormal);
        self.def_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab_1.png"),CCControlStateNormal);
        rankTable = self.m_tGameData.att_ranks
    else
        self.att_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab_1.png"),CCControlStateNormal);
        self.def_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab.png"),CCControlStateNormal);
        rankTable = self.m_tGameData.def_ranks
    end
    local tabCount = game_util:getTableLen(rankTable)
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
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rankData = rankTable[index+1] or {}
            local name = rankData.name or ""
            local score = rankData.score or ""
            local rank = rankData.rank or ""

            detail_label:setString(tostring(rank) .. "." .. name )
            detail_label_score:setString(tostring(score))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[
    即时战报
]]
function game_gvg_instant_rank_pop.createLogTable(self,viewSize)
    -- 战斗日志：battle_type类型如下： 
    -- BATTLE_TYPE_1 = 1           # 战斗类型: 1. 成功攻陷据点
    -- BATTLE_TYPE_2 = 2           # 战斗类型: 2. 成功捣毁资源据点
    -- BATTLE_TYPE_3 = 3           # 战斗类型: 3. 完成连胜
    -- BATTLE_TYPE_4 = 4           # 战斗类型: 4. 攻击成功
    -- BATTLE_TYPE_5 = 5           # 战斗类型: 5. 攻击失败
    -- BATTLE_TYPE_6 = 6           # 战斗类型: 6. 攻击资源成功
    -- BATTLE_TYPE_7 = 7           # 战斗类型: 7. 攻击资源失败
    --  1   4   5  需要加上攻击者的公会
    local log_type_table = string_helper.game_gvg_instant_rank_pop.log_type_table

    local logTable = self.m_tGameData.battle_log
    local tabCount = game_util:getTableLen(logTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
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
            local richLabel = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(120,32),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)});
            local logData = logTable[tabCount-index] or {}

            local logStr = ""
            local battType = logData.battle_type
            if battType == 2 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color]"
            elseif battType == 4 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color]"
            elseif battType == 1 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.dname .. "[/color],占领了该地块"
            elseif battType == 3 then 
                logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. log_type_table[battType] .. "[color=ffff0b03]" .. logData.times .. "连胜" .. "[/color]"
            elseif battType == 5 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "(" .. logData.aguild_name .. ")" .. "[/color]" .. "被" .. "[color=ffff0b03]" .. logData.dname .. "[/color]" .. "击败了"
            elseif battType == 6 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. "被" .. "[color=ffff0b03]" .. logData.dname .. "[/color]" .. "击败了"
            elseif battType == 7 then
                logStr =  "  [color=fffcb103]" .. logData.aname .. "[/color]" .. "被" .. "[color=ffff0b03]" .. logData.dname .. "[/color]" .. "击败了"
            end
            richLabel:setString(logStr)
            rich_label_node:removeAllChildrenWithCleanup(true)
            rich_label_node:addChild(richLabel)

            local timeLabel = ccbNode:labelTTFForName("time_label")
            local dateTemp = os.date("*t", logData.add_time)
            local hour = dateTemp.hour
            if hour < 10 then
                hour = "0" .. hour
            end
            local min = dateTemp.min
            if min < 10 then
                min = "0" .. min
            end
            timeLabel:setString(hour .. ":" .. min)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            ---点击查看详情
            local logData = logTable[index+1] or {}

        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_gvg_instant_rank_pop.refreshUi(self)
    --排行榜
    self.rank_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.rank_node:getContentSize());
    self.rank_node:addChild(tableView,10,10);
    --即时信息
    self.log_node:removeAllChildrenWithCleanup(true)
    local logTableView = self:createLogTable(self.log_node:getContentSize());
    self.log_node:addChild(logTableView,10,10);
end

--[[--
    初始化
]]
function game_gvg_instant_rank_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_showType = t_params.showType or 1;
    self.callBackFunc = t_params.callBackFunc
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_instant_rank_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_gvg_instant_rank_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_instant_rank_pop;