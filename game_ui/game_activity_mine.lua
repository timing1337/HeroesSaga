---  矿山UI

local game_activity_mine = {
    m_selMineId = nil,
    m_mineState = nil,
    root_mine_node = nil, --layer node
    layer_log = nil,
    m_label_log = nil,
    m_node_tableview_record = nil,
    m_btn_record_2 = nil,
    m_mine_bg = nil,

    m_node_dig = nil, 
    m_label_digCount = nil,
    m_label_dig_restTime = nil,
    m_label_owner_1 = nil,
    m_label_owner_2 = nil,
    m_label_brokerage_1 = nil,
    m_label_brokerage_2 = nil,
    m_label_brokerage_rest_1 = nil,
    m_label_brokerage_rest_2 = nil,
    m_label_brokerage_total_1 = nil,
    m_label_brokerage_total_2 = nil,
    m_btn_dig_1 = nil,
    m_btn_dig_2 = nil,
    m_btn_dig_3 = nil,
    m_btn_dig_4 = nil,

    m_node_buy = nil,
    m_label_buy_restTime = nil,
    m_label_biaowang_1 = nil,
    m_label_biaowang_2 = nil,
    m_label_highest_1 = nil,
    m_label_highest_2 = nil,

    m_tGameData = nil,
    m_log_table_view_node = nil,

    -- 大按钮
    m_btn_dig_1_bigger = nil, -- 挖矿1大按钮
    m_btn_dig_3_bigger = nil, -- 追加
    m_btn_dig_2_bigger = nil, -- 挖矿2
    m_btn_dig_4_bigger = nil, -- 追加

    m_btn_buy_1_bigger = nil, -- 竞标1
    m_btn_buy_2_bigger = nil, -- 竞标2

    m_btn_record_1 = nil, -- 日志 1
    m_btn_record_2 = nil, -- 日志 2 
    m_refresh_time_node = nil,
    m_autoRefreshTime = nil,
    m_refresh_time_label = nil,
};
-- 销毁ui
function game_activity_mine.destroy(self)
    cclog("-----------------game_activity_mine destroy-----------------");
    if self.m_cityAutoRaidsScheduler then
        scheduler.unschedule(self.m_cityAutoRaidsScheduler)
        self.m_cityAutoRaidsScheduler = nil;
    end
    self.m_selMineId = nil
    self.m_mineState = nil
    self.root_mine_node = nil
    self.layer_log = nil
    self.m_label_log = nil
    self.m_node_tableview_record = nil
    self.m_btn_record_2 = nil
    self.m_mine_bg = nil

    self.m_node_dig = nil
    self.m_label_digCount = nil
    self.m_label_dig_restTime = nil
    self.m_label_owner_1 = nil
    self.m_label_owner_2 = nil
    self.m_btn_dig_1 = nil
    self.m_btn_dig_2 = nil
    self.m_btn_dig_3 = nil
    self.m_btn_dig_4 = nil
    self.m_label_brokerage_1 = nil
    self.m_label_brokerage_2 = nil
    self.m_label_brokerage_rest_1 = nil
    self.m_label_brokerage_rest_2 = nil
    self.m_label_brokerage_total_1 = nil
    self.m_label_brokerage_total_2 = nil

    self.m_node_buy = nil
    self.m_label_buy_restTime = nil
    self.m_label_biaowang_1 = nil
    self.m_label_biaowang_2 = nil
    self.m_label_highest_1 = nil
    self.m_label_highest_2 = nil
    self.m_tGameData = nil
    self.m_log_table_view_node = nil

    self.m_btn_dig_1_bigger = nil -- 挖矿1大按钮
    self.m_btn_dig_3_bigger = nil -- 追加
    self.m_btn_dig_2_bigger = nil -- 挖矿2
    self.m_btn_dig_4_bigger = nil -- 追加

    self.m_btn_buy_1_bigger = nil -- 竞标1
    self.m_btn_buy_2_bigger = nil -- 竞标2

    self.m_btn_record_1 = nil -- 日志 1
    self.m_btn_record_2 = nil -- 日志 2 
    self.m_refresh_time_node = nil
    self.m_autoRefreshTime = nil
    self.m_refresh_time_label = nil
end

-- 返回
function game_activity_mine.back(self,backType)
    -- if backType == "back" then
    --     local function endCallFunc()
    --         self:destroy()
    --     end
    --     game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc})
    -- end
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end

--[[--
    读取ccbi创建ui
]]
function game_activity_mine.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode")
        local btnTag = tagNode:getTag()
        if btnTag == 11 then
            self:back("back")

        elseif btnTag == 101 then   -- 奖励
            -- game_util:addMoveTips({text = "弹出奖励框"})
            -- game_scene:addPop("ui_activity_pop_mine_reward",{})

        elseif btnTag == 102 then   -- 说明
            -- game_util:addMoveTips({text = "弹出说明框"})
            game_scene:addPop("game_active_limit_detail_pop",{enterType = 131})

        elseif btnTag == 103 then   -- 挖矿记录 打开
            -- game_util:addMoveTips({text = "显示一个tableview"})
            self.m_label_log:getParent():setVisible(false)
            self.m_node_tableview_record:setVisible(true);
            local viewSize = self.m_log_table_view_node:getContentSize()
            self.m_log_table_view_node:addChild(self:createTableView(viewSize));
            self.m_node_tableview_record:setTouchEnabled(true)
        elseif btnTag == 110 then   -- 挖矿记录 关闭
            self.m_node_tableview_record:setTouchEnabled(false)
            self.m_node_tableview_record:setVisible(false);
            self.m_log_table_view_node:removeAllChildrenWithCleanup(true)
            self.m_label_log:getParent():setVisible(true)
        elseif btnTag == 104 or btnTag == 120 then   -- 点击挖矿1 
            self.m_selMineId = 1
            self:onSureDig(btnTag)
        elseif btnTag == 105 or btnTag == 122 then   --  点击挖矿2
            self.m_selMineId = 2
            self:onSureDig(btnTag)

        elseif btnTag == 106 or btnTag == 121 then   -- 点击追加投资1 
            -- game_util:addMoveTips({text = "弹出追加投资框"})
            self.m_selMineId = 1
            self:onSureAdd()
        elseif btnTag == 107 or btnTag == 123 then   -- 点击追加投资2
            -- game_util:addMoveTips({text = "弹出追加投资框"})
            self.m_selMineId = 2
            cclog2(self.m_selMineId,"self.m_selMineId==============")
            self:onSureAdd()

        elseif btnTag == 108 or btnTag == 124 then
            -- game_util:addMoveTips({text = "弹出竞标框"})
            self.m_selMineId = 1 
            self:onSureBuy()
        elseif btnTag == 109 or btnTag ==125 then
            -- game_util:addMoveTips({text = "弹出竞标框"})
            self.m_selMineId = 2
            self:onSureBuy()

        elseif btnTag == 111 then
            -- 加速
            self.m_selMineId = 1 
            self:onSureAccelerate()
        elseif btnTag == 300 then--刷新
            self.m_tickFlag = false;
            self:onAutoRefresh();
        end
        -- self:refreshUi()
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)
    ccbNode:openCCBFile("ccb/ui_activity_mine.ccbi")
    
    -- ui property
    self.m_node_dig = ccbNode:nodeForName("m_node_dig")
    self.m_label_digCount = ccbNode:labelTTFForName("m_label_digCount")
    self.m_label_dig_restTime = ccbNode:nodeForName("m_label_dig_restTime")
    self.m_label_owner_1 = ccbNode:labelTTFForName("m_label_owner_1")
    self.m_label_owner_2 = ccbNode:labelTTFForName("m_label_owner_2")
    self.m_btn_dig_1 = ccbNode:labelTTFForName("m_btn_dig_1")
    self.m_btn_dig_2 = ccbNode:labelTTFForName("m_btn_dig_2")
    self.m_btn_dig_3 = ccbNode:labelTTFForName("m_btn_dig_3")
    self.m_btn_dig_4 = ccbNode:labelTTFForName("m_btn_dig_4")
    self.m_label_brokerage_1 = ccbNode:labelTTFForName("m_label_brokerage_1")
    self.m_label_brokerage_2 = ccbNode:labelTTFForName("m_label_brokerage_2")
    self.m_label_brokerage_rest_1 = ccbNode:labelTTFForName("m_label_brokerage_rest_1")
    self.m_label_brokerage_rest_2 = ccbNode:labelTTFForName("m_label_brokerage_rest_2")
    self.m_label_brokerage_total_1 = ccbNode:labelTTFForName("m_label_brokerage_total_1")
    self.m_label_brokerage_total_2 = ccbNode:labelTTFForName("m_label_brokerage_total_2")

    self.m_node_buy = ccbNode:nodeForName("m_node_buy")
    self.m_label_buy_restTime = ccbNode:nodeForName("m_label_buy_restTime")
    self.m_label_biaowang_1 = ccbNode:labelTTFForName("m_label_biaowang_1")
    self.m_label_biaowang_2 = ccbNode:labelTTFForName("m_label_biaowang_2")
    self.m_label_highest_1 = ccbNode:labelTTFForName("m_label_highest_1")
    self.m_label_highest_2 = ccbNode:labelTTFForName("m_label_highest_2")
    self.m_log_table_view_node = ccbNode:nodeForName("m_log_table_view_node")

    self.m_btn_record_2 = ccbNode:controlButtonForName("m_btn_record_2")
    self.m_label_log = ccbNode:labelTTFForName("m_label_log")
    self.m_node_tableview_record = ccbNode:layerForName("m_node_tableview_record")
    self.root_mine_node = ccbNode:layerForName("root_mine_node")
    self.m_node_tableview_record:setVisible(false)

    self.m_btn_dig_1_bigger = ccbNode:controlButtonForName("m_btn_dig_1_bigger")
    self.m_btn_dig_3_bigger = ccbNode:controlButtonForName("m_btn_dig_3_bigger")
    self.m_btn_dig_2_bigger = ccbNode:controlButtonForName("m_btn_dig_2_bigger")
    self.m_btn_dig_4_bigger = ccbNode:controlButtonForName("m_btn_dig_4_bigger")

    self.m_btn_buy_1_bigger = ccbNode:controlButtonForName("m_btn_buy_1_bigger")
    self.m_btn_buy_2_bigger = ccbNode:controlButtonForName("m_btn_buy_2_bigger")

    self.m_btn_record_1 = ccbNode:controlButtonForName("m_btn_record_1")
    self.m_btn_record_2 = ccbNode:controlButtonForName("m_btn_record_2")

    self.m_btn_dig_1_bigger:setOpacity(0)
    self.m_btn_dig_3_bigger:setOpacity(0)
    self.m_btn_dig_2_bigger:setOpacity(0)
    self.m_btn_dig_4_bigger:setOpacity(0)

    self.m_btn_buy_1_bigger:setOpacity(0)
    self.m_btn_buy_2_bigger:setOpacity(0)

    self.m_btn_record_1:setOpacity(0)
    self.m_btn_record_2:setOpacity(0)

    -- 动画
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if 1 then
            animNode:playSection(theLabelName)
        else
            animNode:getParent():removeFromParentAndCleanup(true)
        end
    end
    local animFile = "anim_ui_xingkong"
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist")
    if mAnimNode then
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection("impact")
        mAnimNode:setRhythm(1)
    end
    local tempSize = self.root_mine_node:getContentSize()
    mAnimNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
    self.root_mine_node:addChild(mAnimNode,100,10)

    -- local function onTouch(eventType, x, y)
    --     if eventType == "began" then
    --         return true --intercept event
    --     end
    -- end
    -- self.root_mine_node:registerScriptTouchHandler(onTouch,false,-999,true)
    -- self.root_mine_node:setTouchEnabled(false)


    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_node_tableview_record:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true)
    self.m_node_tableview_record:setTouchEnabled(false)
    self.m_btn_record_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)

    -- self.m_refresh_time_node = ccbNode:nodeForName("m_refresh_time_node")
    -- local function timeDownCallFunction(label,type)
    --     self:onAutoRefresh();
    -- end
    -- local autoRefreshTime = game_util:createCountdownLabel(5,timeDownCallFunction,1)
    -- self.m_refresh_time_node:addChild(autoRefreshTime,30,30)
    -- self.m_autoRefreshTime = autoRefreshTime
    self.m_refresh_time_label = ccbNode:labelTTFForName("m_refresh_time_label")
    self.m_refresh_time_label:setString(string.format("00:%02d",self.m_auto_time))
    function tick( dt )
        if self.m_tickFlag == false then return end
        if self.m_auto_time > 0 then
            self.m_auto_time = self.m_auto_time - 1;
            self.m_refresh_time_label:setString(string.format("00:%02d",self.m_auto_time))
        else
            self.m_refresh_time_label:setString("00:00")
            self.m_tickFlag = false;
            self:onAutoRefresh();
        end
    end
    self.m_cityAutoRaidsScheduler = scheduler.schedule(tick, 1, false)

    local text1 = ccbNode:labelTTFForName("text1")
    local text2 = ccbNode:labelTTFForName("text2")
    local text3 = ccbNode:labelTTFForName("text3")
    local text4 = ccbNode:labelTTFForName("text4")

    text1:setString(string_helper.ccb.text44)
    text2:setString(string_helper.ccb.text45)
    text3:setString(string_helper.ccb.text44)
    text4:setString(string_helper.ccb.text45)
    return ccbNode
end

function game_activity_mine.onAutoRefresh( self )
    function mineResponseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data")
            self.m_tGameData = json.decode(data:getFormatBuffer())
            self:refreshUi();
            self.m_auto_time = 5;
            self.m_tickFlag = true;
            -- if self.m_autoRefreshTime then
            --     self.m_autoRefreshTime:setTime(5)
            -- end
        end
    end
    network.sendHttpRequest(mineResponseMethod,game_url.getUrlForKey("mine_index"), http_request_method.GET, {},"mine_index",false,true)
end

--[[--
    点击矿 挖矿
]]
function game_activity_mine.onSureDig( self,btnTag )

    -- 请求
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                game_util:rewardTipsByDataTable(self.m_tGameData.reward or {});
                self:refreshUi()
                self.m_auto_time = 5;
                self.m_tickFlag = true;
            else
                self.m_tickFlag = true;
            end
        end

        local params = {}
        params.mid = self.m_selMineId
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mine_mining"), http_request_method.GET, params,"mine_mining",true,true)
    end
    self.m_tickFlag = false;
    sendRequest()
end

--[[--
    加速
]]
function game_activity_mine.onSureAccelerate( self )
    
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self:refreshUi()
                self.m_auto_time = 5;
                self.m_tickFlag = true;
            else
                self.m_tickFlag = true;
            end
        end

        local params = {}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mine_mining_quick"), http_request_method.GET, params,"mine_mining_quick",true,true)
    end
    self.m_tickFlag = false;
    local add_need_coin = self.m_tGameData.add_need_coin or 0
    local t_params = 
    {
        title = string_config.m_title_prompt,
        okBtnCallBack = function(target,event)
            sendRequest()
            game_util:closeAlertView();
        end,   --可缺省
        closeCallBack = function(target,event)
            game_util:closeAlertView();
            self.m_tickFlag = true;
        end,
        okBtnText = string_helper.game_activity_mine.sure,       --可缺省
        text = string_helper.game_activity_mine.cost .. tostring(add_need_coin) .. string_helper.game_activity_mine.diamond_speed,      --可缺省
    }
    game_util:openAlertView(t_params);
end


--[[--
    点击追加投资
]]
function game_activity_mine.onSureAdd( self,btnTag )
    local function callBackFunc(gameData)
        if gameData and tolua.type(gameData) == "util_json" then
            local data = gameData:getNodeWithKey("data")
            -- cclog2(data,"data=====")
            self.m_tGameData = json.decode(data:getFormatBuffer())
                cclog("game_activity_pop_mine_zhuijia  callBackFunc ------------ ")
            self:refreshUi();
            self.m_auto_time = 5;
        end
        self.m_tickFlag = true;
    end
    self.m_tickFlag = false;
    local m_mineId = self.m_selMineId
    cclog2(m_mineId,"m_mineId========")
    game_scene:addPop("game_activity_pop_mine_zhuijia",{gameData = self.m_tGameData,m_mineId = m_mineId,callBackFunc = callBackFunc}) -- m_mineId传到竞标UI 可以用
end

--[[--
    点击矿 竞标
]]
function  game_activity_mine.onSureBuy( self )
    local function callBackFunc(gameData)
        if gameData and tolua.type(gameData) == "util_json" then
            local data = gameData:getNodeWithKey("data")
            -- cclog2(data,"data=====")
            self.m_tGameData = json.decode(data:getFormatBuffer())
            cclog("game_activity_pop_mine_jingbiao  callBackFunc ------------ ")
            self:refreshUi();
            self.m_auto_time = 5;
        end
        self.m_tickFlag = true;
    end
    self.m_tickFlag = false;
    local m_mineId = self.m_selMineId
    game_scene:addPop("game_activity_pop_mine_jingbiao",{gameData = self.m_tGameData,mineId = m_mineId,callBackFunc = callBackFunc}) -- m_mineId传到竞标UI 可以用
end

--[[--
    创建 tableview
]]
function game_activity_mine.createTableView( self,viewSize )
    local showData = {};
    -- -- 加载数据
    if self.m_mineState == 1 then
        showData = self.m_tGameData["log"]
        table.sort(showData,function(data1,data2) return data1.time > data2.time end)
    end

    if self.m_mineState == 2 then
        local m_mine_bidding = self.m_tGameData["bidding"]
        if m_mine_bidding then
            for k,v in pairs {"1","2"} do
                local itemData = m_mine_bidding[v] or {}
                local logData = itemData["log"] or {}
                for i=1,#logData do
                    table.insert(showData,logData[i])
                end
            end
        end
    
        table.sort(showData,function(data1,data2) return data1.time > data2.time end)
    end



    local params = {}
    params.viewSize = viewSize
    params.row = 5      --行
    params.column = 1   --列
    params.totalItem = #showData -- 留20条
    params.direction = kCCScrollViewDirectionVertical
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index)
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local tempSpr = CCScale9Sprite:createWithSpriteFrameName("public_line.png");
            if tempSpr then
                tempSpr:setOpacity(100)
                tempSpr:setPreferredSize(CCSizeMake(itemSize.width,2))
                tempSpr:setAnchorPoint(ccp(0.5,0.5))
                tempSpr:setPositionX(itemSize.width*0.5)
                cell:addChild(tempSpr,100)
            end


            -- -- 加载数据
            if self.m_mineState == 1 then
                local m_log_item = showData[index+1]
                cclog2(itemData,"itemData=========")
                cclog("index======="..index)

                if m_log_item then     
                    local showLabel,mine_id_info,mine_owner_info,show_gift_info = "","","",nil

                    if m_log_item.mine_id == 1 then
                        mine_id_info = "在时空虫洞挖矿"
                    end
                    if m_log_item.mine_id == 2 then
                        mine_id_info = "在宇宙立方挖矿"
                    end
                    cclog("m_log_item.mine_owner======"..m_log_item.mine_owner)
                    if m_log_item.mine_owner == "" then
                        -- cclog("1111111111111111111111111111111")
                        if m_log_item.show_gift then
                            local show_gift = m_log_item.show_gift or {}
                            if #show_gift > 0 then
                                local icon,name,count = game_util:getRewardByItemTable(show_gift[1],true)                       
                                show_gift_info = string_helper.game_activity_mine.mishap_gain.. tostring(name)
                                mine_owner_info = show_gift_info
                            else
                                mine_owner_info = string_helper.game_activity_mine.not_gain
                            end
                        end
                    else
                        -- cclog("22222222222222222222222222222222")
                        local show_gift = m_log_item.show_gift or {}
                        if #show_gift > 0 then
                            local icon,name,count = game_util:getRewardByItemTable(show_gift[1],true)                       
                            show_gift_info = string_helper.game_activity_mine.mishap_gain .. tostring(name)
                        end
                        mine_owner_info = show_gift_info..string_helper.game_activity_mine.mine_main .. m_log_item.mine_owner .. string_helper.game_activity_mine.provide.. m_log_item.coin .. string_helper.game_activity_mine.diamond
                    end

                    showLabel = m_log_item.name..mine_id_info..mine_owner_info
                    
                    local lastNameLabel = cell:getChildByTag(101)
                    if lastNameLabel then
                        lastNameLabel:removeFromParentAndCleanup(true)
                    end
                    local nameLabel = game_util:createLabelTTF({text = tostring(showLabel),color = ccc3(246,221,154),fontSize = 10});
                    nameLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                    cell:addChild(nameLabel,10,101)

                    local m_show_time = ""
                    local timeValue = m_log_item.time
                    local server_time = game_data:getUserStatusDataByKey("server_time")
                    local diff = math.floor(server_time - timeValue)
                    local min_ = math.floor(diff/60)
                    if min_ >= 60 then
                        local hour_ = math.floor(min_/60)
                        m_show_time = hour_ .. string_helper.game_activity_mine.hour_before
                    elseif min_ < 60 and min_ >= 1 then
                        m_show_time = min_ .. string_helper.game_activity_mine.minute_before
                    elseif min_ < 1 then
                        local sec_ = math.floor(diff%60)
                        m_show_time = string_helper.game_activity_mine.just
                    end
                    
                    local lastTimeLabel = cell:getChildByTag(102)
                    if lastTimeLabel then
                        lastTimeLabel:removeFromParentAndCleanup(true)
                    end
                    local timeLabel = game_util:createLabelTTF({text = tostring(m_show_time),color = ccc3(246,221,154),fontSize = 7})
                    timeLabel:setAnchorPoint(ccp(1,0))
                    timeLabel:setPosition(ccp(itemSize.width,2))
                    cell:addChild(timeLabel,10,102)
                end
            end

            if self.m_mineState == 2 then
                local itemData = showData[index+1]
                cclog("self.m_selMineId=========="..self.m_selMineId) 
                if itemData then
                    local showLabel = ""
                    if self.m_selMineId == 1 then
                        showLabel = itemData.name .. string_helper.game_activity_mine.bidding .. itemData.price .. string_helper.game_activity_mine.diamond_time
                    end
                    if self.m_selMineId == 2 then
                        showLabel = itemData.name .. string_helper.game_activity_mine.bidding .. itemData.price .. string_helper.game_activity_mine.space
                    end

                    local lastNameLabel = cell:getChildByTag(103)
                    if lastNameLabel then
                        lastNameLabel:removeFromParentAndCleanup(true)
                    end
                    local nameLabel = game_util:createLabelTTF({text = tostring(showLabel),color = ccc3(246,221,154),fontSize = 10});
                    nameLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                    cell:addChild(nameLabel,10,103)

                    local m_show_time = ""
                    local timeValue = itemData.time
                    local server_time = game_data:getUserStatusDataByKey("server_time")
                    local diff = math.floor(server_time - timeValue)
                    local min_ = math.floor(diff/60)
                    if min_ >= 60 then
                        local hour_ = math.floor(min_/60)
                        m_show_time = hour_ .. string_helper.game_activity_mine.hour_before
                    elseif min_ < 60 and min_ >= 1 then
                        m_show_time = min_ .. string_helper.game_activity_mine.minute_before
                    elseif min_ < 1 then
                        local sec_ = math.floor(diff%60)
                        m_show_time = string_helper.game_activity_mine.just
                    end

                    local lastTimeLabel = cell:getChildByTag(104)
                    if lastTimeLabel then
                        lastTimeLabel:removeFromParentAndCleanup(true)
                    end

                    local timeLabel = game_util:createLabelTTF({text = tostring(m_show_time),color = ccc3(246,221,154),fontSize = 7})
                    timeLabel:setAnchorPoint(ccp(1,0))
                    timeLabel:setPosition(ccp(itemSize.width,2))
                    cell:addChild(timeLabel,10,104)
                end
            end


        end
        return cell
    end

    return TableViewHelper:create(params);
end


--[[--
    刷新node 挖矿
]]
function game_activity_mine.refreshNodeDig( self )
    cclog("========refreshNodeDig =========")

    -- 次数
    local digCount = self.m_tGameData["times"] -- test 从后台获取
    if digCount then
        self.m_label_digCount:setString(tostring(digCount))
    end

    -- 倒计时
    local m_dig_restTime = self.m_tGameData["rest_time"]
    local function timeDownCallFunction(label,type)
        self.m_label_dig_restTime:getParent():setVisible(false)
    end
    cclog("m_dig_restTime==========="..m_dig_restTime)
    if m_dig_restTime then
        if m_dig_restTime > 0 then

            local timeDown = game_util:createCountdownLabel(m_dig_restTime,timeDownCallFunction,1)
            self.m_label_dig_restTime:removeAllChildrenWithCleanup(true)
            self.m_label_dig_restTime:addChild(timeDown,30,30)
            self.m_label_dig_restTime:getParent():setVisible(true)
        else
            self.m_label_dig_restTime:getParent():setVisible(false)
        end
    end

    local m_mine_item = self.m_tGameData["mine"]
    if m_mine_item then
        -- 拥有者 金额
        local userId = game_data:getUserStatusDataByKey("uid")
        -- if self.m_selMineId == 1 then
            local m_mine_item_1 = m_mine_item["1"]
            if m_mine_item_1 then
                local mineOwner1 = m_mine_item_1["name"]   -- test 从后台获取
                local mineOwnerUid1 = m_mine_item_1["uid"]
                if mineOwnerUid1 == "" then
                    self.m_label_owner_1:getParent():setVisible(false)
                    self.m_label_brokerage_1:getParent():setVisible(false)

                else
                    self.m_label_owner_1:getParent():setVisible(true)
                    self.m_label_owner_1:setString(tostring(mineOwner1))

                    local m_label_brokerage_rest_1 = m_mine_item_1["coin"]     -- test 从后台获取
                    local m_label_brokerage_total_1 = m_mine_item_1["max_coin"] 
                    self.m_label_brokerage_1:getParent():setVisible(true)                    
                    self.m_label_brokerage_1:setString(tostring(m_label_brokerage_rest_1.."/"..m_label_brokerage_total_1))
                end
                


            end
        -- end
        -- if self.m_selMineId == 2 then
            local m_mine_item_2 = m_mine_item["2"]
            if m_mine_item_2 then
                local mineOwner2 = m_mine_item_2["name"] 
                local nmineOwnerUid2 = m_mine_item_2["uid"]
                if nmineOwnerUid2 == "" then
                    self.m_label_owner_2:getParent():setVisible(false)
                    self.m_label_brokerage_2:getParent():setVisible(false)
                else
                    self.m_label_owner_2:getParent():setVisible(true)
                    self.m_label_owner_2:setString(tostring(mineOwner2))

                    self.m_label_brokerage_2:getParent():setVisible(true)                    
                    local m_label_brokerage_rest_2 = m_mine_item_2["coin"]
                    local m_label_brokerage_total_2 = m_mine_item_2["max_coin"] 
                    self.m_label_brokerage_2:setString(tostring(m_label_brokerage_rest_2.."/"..m_label_brokerage_total_2))
                end
            end
        -- end
    end
end
--[[--
    刷新node 竞标
]]
function game_activity_mine.refreshNodeBuy( self )
    cclog("refreshNodeBuy---------------------")
    -- local time = game_data:getUserStatusDataByKey("server_time")
    -- local cur_time = os.date("*t", time)
    self.m_label_buy_restTime:removeAllChildrenWithCleanup(true)
    local timeLeft = self.m_tGameData["remainder_time"]
    if timeLeft then
        if timeLeft > 0 then
            local function timeDownCallFunction(label,type)
            end
            local timeDown = game_util:createCountdownLabel(timeLeft,timeDownCallFunction,1)
            -- timeDown:setAnchorPoint(ccp(0,0.5))
            self.m_label_buy_restTime:addChild(timeDown,20,20)
        else
            game_util:addMoveTips({text = string_helper.game_activity_mine.bidding_end})
        end
    end

    local m_mine_item = self.m_tGameData["bidding"]
    if m_mine_item then
        local m_mine_item_1 = m_mine_item["1"]
        local m_mine_item_2 = m_mine_item["2"]
        if m_mine_item_1 then
            local theBiaoWang1 = m_mine_item_1["name"] -- test 
            local theBiaoWangUid1 = m_mine_item_1["uid"]
            if theBiaoWangUid1 == "" then
                self.m_label_biaowang_1:getParent():setVisible(false)
                self.m_label_highest_1:getParent():setVisible(false)
            else
                self.m_label_biaowang_1:getParent():setVisible(true)
                self.m_label_biaowang_1:setString(tostring(theBiaoWang1))

                self.m_label_highest_1:getParent():setVisible(true)
                local hightestPrice1 = m_mine_item_1["coin"]
                -- cclog2(hightestPrice1,"hightestPrice1=========")
                self.m_label_highest_1:removeAllChildrenWithCleanup(true)
                self.m_label_highest_1:setString(tostring(hightestPrice1))
            end

        end
        if m_mine_item_2 then
            local theBiaoWang2 = m_mine_item_2["name"]   -- test 后台获取
            local theBiaoWangUid2 = m_mine_item_2["uid"]
            if theBiaoWangUid2 == "" then
                self.m_label_biaowang_2:getParent():setVisible(false)
                self.m_label_highest_2:getParent():setVisible(false)
            else
                self.m_label_biaowang_2:getParent():setVisible(true)
                self.m_label_biaowang_2:setString(tostring(theBiaoWang2))

                self.m_label_highest_2:getParent():setVisible(true)
                local hightestPrice2 = m_mine_item_2["coin"] 
                -- cclog2(hightestPrice2,"hightestPrice2========")
                self.m_label_highest_2:removeAllChildrenWithCleanup(true)
                self.m_label_highest_2:setString(tostring(hightestPrice2))
            end

        end
    end

end
--[[--
    刷新 log
]]
function game_activity_mine.refreshLog( self )
    cclog2(self.m_mineState,"self.m_mineState == ")
    cclog2(self.m_tGameData,"self.m_tGameData=============================")
    if self.m_mineState == 1 then
        local m_log_log = self.m_tGameData["log"]
        table.sort(m_log_log,function(data1,data2) return data1.time > data2.time end)
        local m_log_item = m_log_log[1]
        -- cclog2("m_log_item========"..m_log_item)
        cclog2(m_log_item,"m_log_item")
        if m_log_item then
            self.m_label_log:getParent():setVisible(true)
            local log,mine_id_info,mine_owner_info,show_gift_info = "","","",""

            if m_log_item.mine_id == 1 then
                mine_id_info = string_helper.game_activity_mine.time_mining
            end
            if m_log_item.mine_id == 2 then
                mine_id_info = string_helper.game_activity_mine.space_mining
            end
            if m_log_item.mine_owner == "" then
                if m_log_item.show_gift then
                    local show_gift = m_log_item.show_gift or {}
                    if #show_gift > 0 then
                        local icon,name,count = game_util:getRewardByItemTable(show_gift[1],true)                       
                        show_gift_info = string_helper.game_activity_mine.mishap_gain.. tostring(name)
                        mine_owner_info = show_gift_info
                    else
                        mine_owner_info = string_helper.game_activity_mine.not_gain
                    end
                end
            else

                local show_gift = m_log_item.show_gift or {}
                if #show_gift > 0 then
                    local icon,name,count = game_util:getRewardByItemTable(show_gift[1],true)                       
                    show_gift_info = string_helper.game_activity_mine.mishap_gain .. tostring(name)
                end
                mine_owner_info = show_gift_info..string_helper.game_activity_mine.mine_main .. m_log_item.mine_owner .. string_helper.game_activity_mine.provide.. m_log_item.coin .. string_helper.game_activity_mine.diamond
            end
            -- cclog("m_log_item========="..m_log_item)

            log = m_log_item.name..mine_id_info..mine_owner_info
            self.m_label_log:setString(tostring(log))
        else
            self.m_label_log:getParent():setVisible(false)
            self.m_label_log:setString("")
        end
    end

    if self.m_mineState == 2 then -- 竞标
        self.m_label_log:getParent():setVisible(true)
        cclog2(self.m_selMineId,"self.m_selMineId")
        cclog2(self.m_tGameData,"self.m_tGameData")
        local m_mine_item = self.m_tGameData["bidding"]
        if self.m_selMineId == 1 then
            local m_mine_item_1 = m_mine_item["1"]
            local log_item = m_mine_item_1["log"]

            local logLength = game_util:getTableLen(log_item)

            -- #玩家名 出价#数量钻石，成为新的标王
            local m_log_item = log_item[logLength]
            local log = ""
            if m_log_item then
                log = m_log_item["name"]..string_helper.game_activity_mine.bidding..m_log_item["price"] ..string_helper.game_activity_mine.diamond_time
            end
            if log == "" then
                self.m_label_log:getParent():setVisible(false)
            else
                self.m_label_log:getParent():setVisible(true)
            end
            self.m_label_log:setString(tostring(log))
        end
        if self.m_selMineId == 2 then
            local m_mine_item_2 = m_mine_item["2"]
            local log_item = m_mine_item_2["log"]

            local logLength = game_util:getTableLen(log_item)

            -- #玩家名 出价#数量钻石，成为新的标王
            local m_log_item = log_item[logLength]
            local log = "";
            if m_log_item then
                log = m_log_item["name"]..string_helper.game_activity_mine.bidding..m_log_item["price"] ..string_helper.game_activity_mine.diamond_time
            end
            if log == "" then
                self.m_label_log:getParent():setVisible(false)
            else
                self.m_label_log:getParent():setVisible(true)
            end
            self.m_label_log:setString(tostring(log))
        end
    end
end


--[[--
    刷新ui
]]
function game_activity_mine.refreshUi(self, time)
    cclog("refreshUi-----------")

    local cur_state = self.m_tGameData["sort"]
    if cur_state == 0 then
        cclog("不在活动时间")
    end

    -- if cur_state == self.m_mineState then   -- 如果当前矿山状态与之前状态相同 则不用刷新
    --     return
    -- end

    self.m_mineState = cur_state
    if cur_state == 1 then
        cclog("11111111111")
        self:refreshNodeDig()
    end
    if cur_state == 2 then
        cclog("222222222")
        self:refreshNodeBuy()
    end

    self:refreshLog()

    if self.m_mineState == 1 then
        self.m_btn_buy_1_bigger:setTouchEnabled(false)
        self.m_btn_buy_2_bigger:setTouchEnabled(false)

        self.m_node_buy:setVisible(false)
        self.m_node_dig:setVisible(true)

        local userId = game_data:getUserStatusDataByKey("uid")
        local m_mine_item = self.m_tGameData["mine"]
        if m_mine_item then
            local m_mine_item_1 = m_mine_item["1"]
            if m_mine_item_1 then
                local ownerId_1 = m_mine_item_1["uid"]    -- test 
                if userId == ownerId_1 then
                    self.m_btn_dig_1:setVisible(false)
                    self.m_btn_dig_3:setVisible(true)
                    self.m_btn_dig_1_bigger:setTouchEnabled(false)
                    self.m_btn_dig_3_bigger:setTouchEnabled(true)
                else
                    self.m_btn_dig_1:setVisible(true)
                    self.m_btn_dig_3:setVisible(false)     
                    self.m_btn_dig_1_bigger:setTouchEnabled(true)
                    self.m_btn_dig_3_bigger:setTouchEnabled(false)
                end
            else
                self.m_btn_dig_1:setVisible(true)
                self.m_btn_dig_3:setVisible(false)     
                self.m_btn_dig_1_bigger:setTouchEnabled(true)
                self.m_btn_dig_3_bigger:setTouchEnabled(false)
            end
            local m_mine_item_2 = m_mine_item["2"]
            if m_mine_item_2 then
                local ownerId_2 = m_mine_item_2["uid"]
                if userId == ownerId_2 then
                    self.m_btn_dig_2:setVisible(false)
                    self.m_btn_dig_4:setVisible(true)
                    self.m_btn_dig_2_bigger:setTouchEnabled(false)
                    self.m_btn_dig_4_bigger:setTouchEnabled(true)
                else
                    self.m_btn_dig_2:setVisible(true)
                    self.m_btn_dig_4:setVisible(false)
                    self.m_btn_dig_2_bigger:setTouchEnabled(true)
                    self.m_btn_dig_4_bigger:setTouchEnabled(false)
                end
            else
                self.m_btn_dig_2:setVisible(true)
                self.m_btn_dig_4:setVisible(false)
                self.m_btn_dig_2_bigger:setTouchEnabled(true)
                self.m_btn_dig_4_bigger:setTouchEnabled(false)
            end
        end
    end
    if self.m_mineState == 2 then
        self.m_btn_buy_1_bigger:setTouchEnabled(true)
        self.m_btn_buy_2_bigger:setTouchEnabled(true)
        self.m_node_dig:setVisible(false)
        self.m_node_buy:setVisible(true)
    end



end
--[[--
    初始化
]]
function game_activity_mine.init(self,t_params)
    t_params = t_params or {}

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    cclog2(self.m_tGameData,"m_tGameData==============")
    -- self.root_mine_node = nil
    self.m_selMineId = 1
    self.m_mineState = 1
    self.m_label_brokerage_rest_1 = 0
    self.m_label_brokerage_rest_2 = 0
    self.m_label_brokerage_total_1 = 0
    self.m_label_brokerage_total_2 = 0
    self.m_tickFlag = true;
    self.m_auto_time = 5;
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_mine.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activity_mine;