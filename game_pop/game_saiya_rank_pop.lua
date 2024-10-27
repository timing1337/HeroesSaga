---  赛亚人归来排行榜
local game_saiya_rank_pop = {
    selectIndex = nil,

    time_btn = nil,
    m_close_btn = nil,
    table_node = nil,
    m_root_layer = nil,
    m_tGameData = nil,
    text_scroll = nil,
    m_moveFlag = nil,
    m_version = nil,
};
--[[--
    销毁ui
]]
function game_saiya_rank_pop.destroy(self)
    cclog("----------------- game_saiya_rank_pop destroy-----------------"); 
    self.selectIndex = nil;
    self.time_btn = nil;
    self.m_close_btn = nil;
    self.table_node = nil;
    self.m_root_layer = nil;
    self.m_tGameData = nil;
    self.text_scroll = nil;
    self.m_moveFlag = nil;
    self.m_version = nil;
end
--[[--
    返回
]]
function game_saiya_rank_pop.back(self)
    game_scene:removePopByName("game_saiya_rank_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_saiya_rank_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag > 100 and btnTag < 200 then
            local index = btnTag - 100
            self.selectIndex = index
            self:refreshUi()
            for i=1,3 do
                self.time_btn[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab_1.png"),CCControlStateNormal);
            end
            self.time_btn[self.selectIndex]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab.png"),CCControlStateNormal);
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_saiya_back_rank.ccbi");

    for i=1,3 do
        self.time_btn[i] = ccbNode:controlButtonForName("time_btn_" .. i)
        if self.time_btn[i] then
            self.time_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
        end
    end
    self.table_node = ccbNode:nodeForName("table_node")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)

    self.text_scroll = ccbNode:scrollViewForName("text_scroll")
    self.text_scroll:setTouchPriority(GLOBAL_TOUCH_PRIORITY-10)
    -- 本层阻止触摸传导下一层
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_moveFlag = false;
            touchBeginPoint = {x = x, y = y}
            return true;--intercept event
        elseif eventType == "moved" then
            if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
                self.m_moveFlag = true;
            end
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-9,true);
    self.m_root_layer:setTouchEnabled(true);

    self:createText(self.text_scroll:getViewSize())
    return ccbNode;
end

--[[
    竖的table
]]
function game_saiya_rank_pop.createRankTable(self,viewSize)
    local frame_name = {"arena_gold.png","arena_silver.png","arena_copper.png"}
    local richCfg = getConfig(game_config_field.super_rich);
    local rewardName = {"reward_12","reward_21","reward_24"}
    local reward_key_tab = {}   -- 活动奖励的id列表
    local rankTable = richCfg:getNodeCount()
    for i=1, rankTable do
        local itemCfg = richCfg:getNodeAt( i - 1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_version ) then
            table.insert(reward_key_tab, itemCfg:getKey())
        end
    end
    local sortFun = function ( data1, data2 )
        return tonumber(data1) < tonumber(data2)
    end
    table.sort(reward_key_tab, sortFun)

    local showData = {}
    for i=1, #reward_key_tab do
        local itemCfg = richCfg:getNodeWithKey(tostring(reward_key_tab[i]))
        local rewardData = itemCfg:getNodeWithKey(rewardName[self.selectIndex])
        table.insert( showData, json.decode(rewardData:getFormatBuffer()) )
    end

    local function onBtnCilck( event,target )
        if self.m_moveFlag == false then-- and event == 32 then
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            
            local index = math.floor(btnTag / 100)
            local itemData = showData[index+1]
            local id = btnTag % 100
            local reward = itemData[id]
            game_util:lookItemDetal(reward)
        end
    end


    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #reward_key_tab ;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_saiya_back_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local rank_number = ccbNode:labelBMFontForName("rank_number")
            local top_icon = ccbNode:spriteForName("top_icon")
            local name_label = ccbNode:labelTTFForName("name_label")
            local reward_node = ccbNode:nodeForName("reward_node")

            rank_number:setString(tostring(index+1))
            if index >= 0 and index < 3 then
                top_icon:setVisible(true);
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(frame_name[index + 1]))
                top_icon:setDisplayFrame(tempSpriteFrame);
            else
                top_icon:setVisible(false);
            end
            name_label:setString(string.format(string_helper.game_saiya_rank_pop.di,(index+1)))

            local itemData = showData[index+1]
            local nodeSize = reward_node:getContentSize()
            local dw = nodeSize.width / #itemData
            local dx = dw / 2
            reward_node:removeAllChildrenWithCleanup(true)
            for i=1,math.min(5,#itemData) do
                local reward = itemData[i]
                local icon,name,count = game_util:getRewardByItemTable(reward,true)
                if icon then
                    icon:setScale(0.7)
                    icon:setPosition(ccp(dx + (i-1)*dw,23));
                    reward_node:addChild(icon)

                    --加查看按钮
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTouchPriority(GLOBAL_TOUCH_PRIORITY-9)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(dx + (i-1)*dw,23));
                    button:setScale(0.7)
                    button:setTag(index * 100 + i)
                    button:setOpacity(0)
                    reward_node:addChild(button)
                end
                if count then
                    local nameLabel = game_util:createLabelBMFont({text = "×" .. count})
                    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                    nameLabel:setPosition(ccp(dx + (i-1)*dw, 1))
                    reward_node:addChild(nameLabel, 10)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end
--[[
    
]]
function game_saiya_rank_pop.createText(self,viewSize)
    -- local lastTabel = self.text_scroll:getChildByTag(10)
    -- if lastTabel then
    --     cclog("sdfdsfsdfds")
    --     lastTabel:removeFromParentAndCleanup(true)
    -- end

    -- 活动详情
    local super_active_cfg = getConfig(game_config_field.super_rich)
    local tempCount = super_active_cfg and super_active_cfg:getNodeCount() or 0
    local active_tab = {}
    for i=1, tempCount do
        local itemCfg = super_active_cfg:getNodeAt(i - 1)
        -- cclog2(itemCfg:getKey(), " version  =====    " .. tostring(self.m_version))
        if game_util:compareItemCfgVersion(itemCfg, self.m_version) then
            table.insert(active_tab, itemCfg:getKey())
        end
    end
    table.sort(active_tab, function(data1, data2) return tonumber(data1) < tonumber(data2) end)
    -- cclog2(active_tab, "active_tab  ======    ")
    local active_msg = ""
    for i,v in ipairs(active_tab) do
        local tempCfg = super_active_cfg and super_active_cfg:getNodeWithKey(tostring(active_tab[i]))
        -- cclog2(tempCfg, "tempCfg  ======   ")
        active_msg = tempCfg and tempCfg:getNodeWithKey("notice") and tempCfg:getNodeWithKey("notice"):toStr() or ""
        if string.len(active_msg) > 0 then
            break
        end
    end

    -- local contentText = "活动详情"
    -- local activeCfg = getConfig(game_config_field.notice_active)
    -- local itemCfg = activeCfg:getNodeWithKey( "122" )
    -- contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or "精彩活动，请大家踊跃参加！"    
    local tempLabel = game_util:createRichLabelTTF({text = active_msg,dimensions = CCSizeMake(400,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(242,224,225),fontSize = 10})
    local tempSize = tempLabel:getContentSize();
    self.text_scroll:setContentSize(CCSizeMake(400,tempSize.height))
    -- if tempSize.height > viewSize.height then
        self.text_scroll:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    -- end
    self.text_scroll:addChild(tempLabel,10,10)
end
--[[--
    刷新ui
]]
function game_saiya_rank_pop.refreshUi(self)
    self.table_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createRankTable(self.table_node:getContentSize());
    self.table_node:addChild(tableView,10,10);
end
--[[--
    初始化
]]
function game_saiya_rank_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_version = t_params.version
    self.time_btn = {}
    self.selectIndex = 1 
    self.m_moveFlag = false;
end
--[[--
    创建ui入口并初始化数据
]]
function game_saiya_rank_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_saiya_rank_pop