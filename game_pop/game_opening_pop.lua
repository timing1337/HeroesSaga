---  ui模版

local game_opening_pop = {
    m_list_view_bg = nil, -- 左侧活动列表board
    m_tableView = nil, -- 左侧的tableview
    m_curShowActivityID = 0, -- 当前选中的活动id
    m_curSelectActivityCell= nil, -- 当前选中的cell
    m_sprite_activename = nil,
    m_sprite_activebg = nil,
    m_label_acitvity_asktitle = nil,
    m_label_acitvity_askdetaile = nil,
    m_label_acitvity_tieminfo = nil,
    m_node_rewardIcon = nil,
    m_label_acitivity_rewqrdnum = nil,
    m_sprite_getRewardEnd = nil,
    m_conbtn_getReward = nil,
    m_tActivityData = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_ticonbuttons = nil,
    m_openid = nil,
    m_label_acitvity_askdtime = nil,
    m_itemNum = nil;
};
--[[--
    销毁ui
]]
function game_opening_pop.destroy(self)
    -- body
    cclog("----------------- game_opening_pop destroy-----------------");  
    self.m_list_view_bg = nil; -- 左侧活动列表board
    self.m_tableView = nil; -- 左侧的tableview
    self.m_curShowActivityID = 0; -- 当前选中的活动id
    self.m_curSelectActivityCell= nil; -- 当前选中的cell
    self.m_sprite_activename = nil;
    self.m_sprite_activebg = nil;
    self.m_label_acitvity_asktitle = nil;
    self.m_label_acitvity_askdetaile = nil;
    self.m_label_acitvity_tieminfo = nil;
    self.m_node_rewardIcon = nil;
    self.m_label_acitivity_rewqrdnum = nil;
    self.m_sprite_getRewardEnd = nil;
    self.m_conbtn_getReward = nil;
    self.m_tActivityData = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_ticonbuttons = nil;
    self.m_openid = nil;
    self.m_label_acitvity_askdtime = nil;
    self.m_itemNum = nil;
end
--[[--
    返回
]]
function game_opening_pop.back(self,backType)
    game_scene:removePopByName("game_opening_pop");
    if self.m_tActivityData and self.m_tActivityData.callFun then
        -- print("game_opening_pop  ---------  ")
        self.m_tActivityData.callFun()
    end
	self:destroy();
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
end
--[[--
    读取ccbi创建ui
]]
function game_opening_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag >= 51 and btnTag <= 53 then
            -- print("press button tag is ", btnTag)
                local opening_cfg = getConfig(game_config_field.opening)
                local itemCfg = opening_cfg:getNodeWithKey(tostring(self.m_openid))
                local story = itemCfg:getNodeWithKey("story"):toStr();
                local reward = itemCfg:getNodeWithKey("reward")
                local rewardCount = reward:getNodeCount();
                local info = json.decode(reward:getNodeAt(btnTag - 50 - 1):getFormatBuffer())
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                    cclog("cId == " .. cId)
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                end
        elseif  btnTag == 101 then
                ccbNode:runAnimations("got_reward")
            -- print("-------- 领奖 --------")
            local function responseMethod(tag,gameData)
                ccbNode:runAnimations("got_reward")
                local data = gameData:getNodeWithKey("data");
                self.m_tActivityData.init = true;
                self.m_tActivityData.data = json.decode(data:getNodeWithKey("opening"):getFormatBuffer()) or {}
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                -- if self.m_tActivityData.data["got_count"][tostring(self.m_curShowActivityID + 1)] then
                --     self.m_tActivityData.data["got_count"][tostring(self.m_curShowActivityID + 1)] = self.m_tActivityData.data["got_count"][tostring(self.m_curShowActivityID + 1)] + 1
                -- end
                self:refreshUi()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_kfhd_getreward"), http_request_method.GET, {award_id = self.m_curShowActivityID + 1 },"active_kfhd_getreward")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:registerFunctionWithFuncName("onCellBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_opening_pop.ccbi");
    self.m_sprite_activebg =  ccbNode:spriteForName("m_sprite_activebg");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_label_acitvity_askdtime = ccbNode:labelTTFForName("m_label_acitvity_askdtime")   --  时间
    self.m_node_rewardIcon = ccbNode:labelTTFForName("m_node_rewardIcon")   -- icon board
    self.m_label_acitvity_asktitle = ccbNode:labelTTFForName("m_label_acitvity_asktitle")  -- 标题 ： 默认是 任务要求
    self.m_label_acitvity_asktitle:setString(string_helper.ccb.title127)
    self.m_label_acitvity_askdetaile = ccbNode:labelTTFForName("m_label_acitvity_askdetaile")         -- 活动内容
    self.m_blabel_progress = ccbNode:labelBMFontForName("m_blabel_progress")            -- 活动进度
    self.m_conbtn_getReward = ccbNode:controlButtonForName("m_conbtn_getReward");                      -- 领奖按钮
    self.m_conbtn_getReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    falsh_blindness:runAction(game_util:createRepeatForeverFade());
    -- 已经领取奖励图标
    self.m_sprite_getRewardEnd =  ccbNode:spriteForName("m_sprite_getRewardEnd");
    self.m_sprite_getRewardEnd:setVisible(false)
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    -- 创建左侧的列表
       -- 图标按钮
       self.m_ticonbuttons = {}
    for i=1,3 do
        self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon" .. i)
        self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    end
    local sedata,_ = game_data:getServer()
    -- print_lua_table(os.date("*t", server_time), 10)
    local date = sedata.open_time
    -- date = game_data:getUserStatusDataByKey("server_time")
    local strDate = ""
    if date == -1 then
        strDate = string_helper.game_opening_pop.strData
    else
        -- local preDate = os.date("*t", sedata.open_time)
        local dayNum = game_data:getOpeningDayNum() or 14
        -- local lastDate = os.date("*t", sedata.open_time + dayNum *24*60*60)

        local startTimeStr = os.date(string_helper.game_opening_pop.data, sedata.open_time)
        local endTimeStr = os.date(string_helper.game_opening_pop.data, sedata.open_time + dayNum * 24 * 3600)
        strDate = startTimeStr .. "——" .. endTimeStr
        -- strDate = string.format("%d年%d月%d日 —— %d年%d月%d日", preDate.year, preDate.month, preDate.day, lastDate.year, lastDate.month ,lastDate.day)
    end
    self.m_label_acitvity_askdtime:setString(string_helper.game_opening_pop.hd_time .. strDate)
    


    local tipselectID = 0
    if game_data:getAlertsDataByKey("opening") ~= "" then
        tipselectID = tonumber(game_data:getAlertsDataByKey("opening")) - 1
        -- tipselectID = 0  - 1
    end
    self.m_curShowActivityID = tipselectID 

    -- print(" self.m_curShowActivityID  ==  ", self.m_curShowActivityID, tipselectID, game_data:getAlertsDataByKey("opening"))



    self:createOpeningTabelView()

    local adjustItemIndex = tipselectID
    if self.m_itemNum - tipselectID  < 5 then
        adjustItemIndex = self.m_itemNum  - 5
    end
    self.m_curShowActivityID = math.min(self.m_curShowActivityID, self.m_itemNum - 1 )


   

    local size = self.m_tableView:getViewSize()
    -- print(" view size is ", size.width, size.height)
    self.m_tableView:setContentOffset(ccp(0, size.height * 0.2 * (adjustItemIndex ) - 220));
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_opening_pop.refreshDetailInfo(self, openingId, state)
    state = state or {}
    -- print("self.m_curShowActivityID + 1 === ", self.m_curShowActivityID + 1)
    -- print("data ==== ", json.encode(self.m_tActivityData.data))
    -- print("opening id == ", openingId, "state == ", json.encode(state))


    self.m_openid = openingId
    local opening_cfg = getConfig(game_config_field.opening)
    local itemCfg = opening_cfg:getNodeWithKey(tostring(openingId))
    local story = itemCfg:getNodeWithKey("story"):toStr();
    local reward = itemCfg:getNodeWithKey("reward")
    local rewardCount = reward:getNodeCount();
    self.m_node_rewardIcon:removeAllChildrenWithCleanup(true)
    -- 卡片按钮设置
    for i=1,3 do
        self.m_ticonbuttons[i]:setVisible(false)
    end
    for i=1,rewardCount do
        local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),false);
        if icon then
            icon:setAnchorPoint(ccp(0, 0))
            icon:setPosition((i - 1) * 53, 0)
            self.m_ticonbuttons[i]:setPositionX((i - 1) * 53)
            self.m_ticonbuttons[i]:setVisible(true)
            self.m_node_rewardIcon:addChild(icon, -2)
            if count then
                local label = game_util :createLabelBMFont({text = string.format("x%d", count), color = ccc3(250, 250, 250), fontSize = 15})
                label:setAnchorPoint(ccp(1, 0))
                local x = icon:getContentSize().width 
                label:setPosition(x, 0)
                icon:addChild(label, 10)
            end
        end
    end

    local allNum = itemCfg:getNodeWithKey("all_num"):toInt();
    local curNum = self.m_tActivityData.data["got_count"][tostring(self.m_curShowActivityID + 1)] or 0
    -- allNum = 50
    -- curNum = 50
    -- if curNum == 48 then curNum = 50 end
    if curNum > allNum then curNum = allNum end
    -- print("curNum" , curNum, tostring(self.m_curShowActivityID + 1))
    if  allNum ~= 0 and allNum - curNum > 0 then
        self.m_blabel_progress:setString(string.format("%d / %d", allNum - curNum, allNum))   -- 任务进度
    elseif allNum ~= 0 and allNum - curNum <= 0 then
        self.m_blabel_progress:setString(string_helper.game_opening_pop.rewardOver)   -- 任务进度
    elseif allNum == 0 then
        self.m_blabel_progress:setString(string_helper.game_opening_pop.noLimit)
    end

    self.m_conbtn_getReward:setEnabled(false)
    self.m_sprite_getRewardEnd:setVisible(false)
    -- game_util:setControlButtonTitleBMFont(self.m_conbtn_getReward)
    -- game_util:setCCControlButtonTitle(self.m_conbtn_getReward, "条件不足")

    -- state[1] = 2
    -- state[2] = 1
    -- state[3] =1
    if allNum ~= 0 and allNum - curNum  <= 0  then                       -- 奖励全部领完
        if state[3] ~= 2 then         -- 没有领过奖励
            self.m_conbtn_getReward:setVisible(true)
            game_util:setCCControlButtonTitle(self.m_conbtn_getReward, string_helper.game_opening_pop.reward_out)
            self.m_sprite_getRewardEnd:setVisible(false)
        else  -- 领过奖励
            game_util:setCCControlButtonTitle(self.m_conbtn_getReward, string_helper.game_opening_pop.geted)
            self.m_sprite_getRewardEnd:setVisible(true)
        end
    else                                                                -- 还有奖励剩余
        if state[1] >= state[2] then                                    -- 可以领奖
            if state[3] == 1  then                                      -- 自己没有领过奖
                -- 领奖按钮是否可以被按下
                self.m_conbtn_getReward:setEnabled(true)
                self.m_sprite_getRewardEnd:setVisible(false)
                game_util:setCCControlButtonTitle(self.m_conbtn_getReward, string_helper.game_opening_pop.get)
            elseif state[3] == 2 then                  -- 自己领过奖励
                game_util:setCCControlButtonTitle(self.m_conbtn_getReward, string_helper.game_opening_pop.geted)
                self.m_sprite_getRewardEnd:setVisible(true)
            end
        else                                                            -- 领奖条件没有达到
            game_util:setCCControlButtonTitle(self.m_conbtn_getReward, string_helper.game_opening_pop.accessDeny)
            self.m_conbtn_getReward:setVisible(true)
            self.m_sprite_getRewardEnd:setVisible(false)
        end
        self.m_conbtn_getReward:setVisible(true)
    end
    -- 任务要求详细内容
    self.m_label_acitvity_askdetaile:setString(story)
end

function game_opening_pop.checkItemValid(self, itemId, opening_cfg, state)
    local itemCfg = tolua.cast(opening_cfg, "util_json"):getNodeWithKey(tostring(itemId))
    local allNum = itemCfg:getNodeWithKey("all_num"):toInt();
    local curNum = self.m_tActivityData.data["got_count"][tostring(self.m_curShowActivityID + 1)] or 0

    if allNum ~= 0 and allNum - curNum  <= 0  then                       -- 奖励全部领完
        return 0
    else                                                                -- 还有奖励剩余
        if state[1] >= state[2] then                                    -- 可以领奖
            if state[3] == 1  then                                      -- 自己没有领过奖
                return 1
            elseif state[3] == 2 then                  -- 自己领过奖励
                return 2
            end
        else                                                            -- 领奖条件没有达到
            return 0
        end
    end
end

function game_opening_pop.getValidItem( self )
    local opening_cfg = getConfig(game_config_field.opening)
    local tempData = {};
    local opening_cfg_count = opening_cfg:getNodeCount();
    for i=1,opening_cfg_count do
        local itemCfg = opening_cfg:getNodeAt(i-1)
        tempData[#tempData + 1] = itemCfg:getKey();
    end
    local function sortFunc(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort( tempData, sortFunc )

    for i=1,#tempData do
        local state = self.m_tActivityData.data.result[tempData[i]]
        if self:checkItemValid(i ,opening_cfg, state ) == 1 then
            return i - 1
        end
    end
    return itemId - 1
end


function game_opening_pop.createOpeningTabelView(self)
    if self.m_tableView == nil then
        self.m_tableView = self:createActivityTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(self.m_tableView)
    end
end
--[[--
    刷新ui
]]
function game_opening_pop.refreshUi(self)
    self:createOpeningTabelView();
    -- 更新信息
    local opening_cfg = getConfig(game_config_field.opening)
    local tempData = {};
    local opening_cfg_count = opening_cfg:getNodeCount();
    for i=1,opening_cfg_count do
        local itemCfg = opening_cfg:getNodeAt(i-1)
        tempData[#tempData + 1] = itemCfg:getKey();
    end
    local function sortFunc(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort( tempData, sortFunc )
    self:refreshDetailInfo(tempData[self.m_curShowActivityID + 1], self.m_tActivityData.data.result[tempData[self.m_curShowActivityID + 1]]);
end
--[[--
    初始化
]]
function game_opening_pop.init(self,t_params)

    -- print("game_opening_pop   - data is ", t_params.gameData:getFormatBuffer())
    -- print_lua_table(t_params, 10)


    t_params = t_params or {};
    self.m_tActivityData = {init = false, data = {}}
    -- 获得数据
    local data = t_params.gameData:getNodeWithKey("data")
    local opening = data:getNodeWithKey("opening")
    local tableData = json.decode(opening:getFormatBuffer(), true)
    if tableData then
        self.m_tActivityData.init = true
        self.m_tActivityData.callFun =  t_params.callFun
        self.m_tActivityData.data = tableData
    end

end

--[[--
    创建ui入口并初始化数据
]]
function game_opening_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
--[[--
    创建左侧开服活动的列表
]]
function game_opening_pop.createActivityTableView( self, viewSize )
    local opening_cfg = getConfig(game_config_field.opening)
    local tempData = {};
    local opening_cfg_count = opening_cfg:getNodeCount();
    for i=1,opening_cfg_count do
        local itemCfg = opening_cfg:getNodeAt(i-1)
        tempData[#tempData + 1] = itemCfg:getKey();
        -- print("key is 0... ", tempData[#tempData])
    end
    local function sortFunc(data1,data2)
        return tonumber(data1) < tonumber(data2)
    end
    table.sort( tempData, sortFunc )
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tempData;
    self.m_itemNum = params.totalItem
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_startserver_active_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end

        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local key = tempData[index + 1]
            local itemCfg = opening_cfg:getNodeWithKey(tostring(key))
            -- 
            local state = self.m_tActivityData.data.result[tempData[self.m_curShowActivityID + 1]]
            -- 修正活动标题
            local iconName = itemCfg:getNodeWithKey("title")
            if iconName then
                iconName = iconName:toStr();
                local m_sprite_title = ccbNode:spriteForName("m_sprite_active_title")
                local newSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( iconName .. ".png" )
                if newSpriteFrame then
                    m_sprite_title:setDisplayFrame(newSpriteFrame)
                else
                end
            end
            local m_sprite_bg = ccbNode:spriteForName("m_sprite_title_bg")
            if self.m_curShowActivityID == index then                
                m_sprite_bg:setDisplayFrame(display.newSpriteFrame("opening_xuanzeianniu.png"))
                self.m_curSelectActivityCell = cell
            else
                m_sprite_bg:setDisplayFrame(display.newSpriteFrame("opening_anniu.png"))
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" and cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_sprite_bg = ccbNode:spriteForName("m_sprite_title_bg")
            if self.m_curSelectActivityCell ~= nil then
                local ccbNode = tolua.cast(self.m_curSelectActivityCell:getChildByTag(10),"luaCCBNode")
                local m_sprite_bg = ccbNode:spriteForName("m_sprite_title_bg")
                m_sprite_bg:setDisplayFrame(display.newSpriteFrame("opening_anniu.png"))
            end
            -- 更新新的选中cell状态
            self.m_curShowActivityID = index 
            self.m_curSelectActivityCell = cell
            m_sprite_bg:setDisplayFrame(display.newSpriteFrame("opening_xuanzeianniu.png"))
            self:refreshUi()
        end
    end
    return TableViewHelper:create(params)
end

return game_opening_pop;
