---  ui模版

local game_limitgift_pop = {
    m_node_reward = nil,
    m_blabel_buycost = nil,
    m_conbtn_getReward = nil,
    m_label_timetip = nil,
    m_label_time = nil,
    m_ticonbuttons = nil,
    m_tData = nil,
    m_popRemFun = nil,
};
--[[--
    销毁ui
]]
function game_limitgift_pop.destroy(self)
    -- body
    cclog("----------------- game_limitgift_pop destroy-----------------"); 
    self.m_node_reward = nil;
    self.m_blabel_buycost = nil;
    self.m_conbtn_getReward = nil;
    self.m_label_timetip = nil;
    self.m_label_time = nil;
    self.m_ticonbuttons = nil;
    self.m_tData = nil;
    self.m_popRemFun = nil;
end
--[[--
    返回
]]
function game_limitgift_pop.back(self,backType)
    game_data:useLevelGiftByLevel(self.m_tData.level)
    if self.m_popRemFun then
        self.m_popRemFun()
    end
    game_scene:removePopByName("game_limitgift_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_limitgift_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag >= 51 and btnTag <= 53 then
                local info = self.m_tData.rewardInfo[btnTag - 50]
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
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self.m_conbtn_getReward:setEnabled(false)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("level_gift_buy"), http_request_method.GET, {lv = self.m_tData.level},"level_gift_buy")
        end
    end

    ccbNode:registerFunctionWithFuncName("onCellBtnClick", onBtnClick);
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_limitgift_pop.ccbi");

    self.m_node_reward = ccbNode:nodeForName("m_node_reward")           -- 显示图标 按钮
    self.m_label_timetip = ccbNode:labelTTFForName("m_label_timetip")               -- 倒计时提示
    self.m_label_timetip:setString( string_helper.game_limitgift_pop.end_time )
    self.m_label_time = ccbNode:labelTTFForName("m_label_time")                     -- 倒计时数字显示
    self.m_blabel_buycost = ccbNode:labelBMFontForName("m_blabel_buycost")          -- 花费
    -- 光效 显示
    local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_conbtn_getReward = ccbNode:controlButtonForName("m_conbtn_getReward")    -- 购买按钮
    self.m_conbtn_getReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonTitle(self.m_conbtn_getReward,string_helper.ccb.title186)
    game_util:setControlButtonTitleBMFont(self.m_conbtn_getReward)

    -- 倒计时
    local function timeOverCallFun(label,type)
        self:back()
    end
    local offset = {{-0.5,0.5},{-0.5,-0.5},{0.5,-0.5},{0.5,0.5},{0,0},};
    local color = {ccc3(0,255,0),ccc3(0,0,0),ccc3(0,0,0),ccc3(0,0,0),ccc3(0,255,0),}
    local timeLabel = game_util:createCountdownLabel(tonumber(self.m_tData.time) ,timeOverCallFun,8, 2)
    -- timeLabel:setFontSize(12.00)
    timeLabel:setAnchorPoint(ccp( 0, 0.5 ))
    timeLabel:setPosition(self.m_label_time:getPosition())
    self.m_label_time:getParent():addChild(timeLabel, 100)
    self.m_label_time:setVisible(false)
    timeLabel:setScale(14/12.0)
    timeLabel:setColor(ccc3(255, 255, 0))

       -- 图标按钮
    self.m_ticonbuttons = {}
    for i=1,4 do
        self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon" .. i)
        self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        self.m_ticonbuttons[i]:setVisible(false);
    end
    self.m_label_showinfos = {}
    for i=1,2 do
        self.m_label_showinfos[i] = ccbNode:labelTTFForName("m_label_showinfo" .. i)
        self.m_label_showinfos[i]:setColor(ccc3(233, 233, 233))
    end
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_limitgift_pop.refreshUi(self)
    local level_giftCfg = getConfig(game_config_field.level_gift)
    local level = game_data:getUserStatusDataByKey("level")
    local levelGift = level_giftCfg:getNodeWithKey(tostring( self.m_tData.level ))
    local reward = levelGift:getNodeWithKey("reward")
    local cost = levelGift:getNodeWithKey("coin"):toInt()
    local des = levelGift:getNodeWithKey("des")
    -- print("level gift describe is ", des , des and des:toStr())
    if des then
        for i=1,2 do
            self.m_label_showinfos[i]:setString(tostring(des:toStr()))
        end
    end
    -- local tempData = {}
    -- if levelGift then
        local rewardCount = reward:getNodeCount()
    --     for i=1,rewardCount do
    --         local itemCfg = reward:getNodeAt(i-1)
    --         tempData[#tempData + 1] = itemCfg:getKey();
    --     end
    --     local function sortFunc(data1,data2)
    --         return tonumber(data1) < tonumber(data2)
    --     end
    --     table.sort( tempData, sortFunc )
    -- end
    self.m_blabel_buycost:setString(tostring(cost or 0))       -- 更新花费
    -- 更新奖励
    if tempData or true then
        local allcount = rewardCount
        local posx = 0
        -- allcount = 2
        allcount = math.min(allcount, 4)
        for i=1,allcount do
            local icon, name, count = game_util:getRewardByItem(reward:getNodeAt(i - 1))
            -- print(icon, name, count, " icon, name, count = game_")
            local iin = reward:getNodeAt(i - 1)
            self.m_tData.rewardInfo[i] = json.decode(iin:getFormatBuffer())
            if icon then
                icon:setAnchorPoint(ccp(0.5, 1))
                icon:setPositionY(self.m_node_reward:getContentSize().height)
                self.m_node_reward:addChild(icon, 20, 20)
                if allcount == 1 then 
                    icon:setPositionX(self.m_node_reward:getContentSize().width * 0.4) 
                elseif allcount == 2 then 
                    icon:setPositionX(self.m_node_reward:getContentSize().width * 0.33 * i)
                elseif allcount == 3 then
                    icon:setPositionX(self.m_node_reward:getContentSize().width * 0.25 * i)
                elseif allcount == 4 then
                    icon:setPositionX(self.m_node_reward:getContentSize().width * (0.25 * i - 0.1))
                end 
                if name then
                    local blabelName = game_util:createLabelBMFont({text = name})
                    blabelName:setAnchorPoint(ccp(0.5, 1))
                    blabelName:setPosition(icon:getContentSize().width * 0.5, 3)
                    icon:addChild(blabelName, 10)
                    if count then
                        local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count), fontSize})
                        blabelCount:setAnchorPoint(ccp(0.5, 1))
                        blabelCount:setPosition(icon:getContentSize().width * 0.5, blabelName:getPositionY() - blabelName:getContentSize().height)
                        icon:addChild(blabelCount, 11)
                    end
                end
                self.m_ticonbuttons[i]:setVisible(true)
                self.m_ticonbuttons[i]:setPosition(icon:getPosition())
                self.m_ticonbuttons[i]:setAnchorPoint(ccp(0.5, 1))
            end
        end
    end
end
--[[--
    初始化
]]
function game_limitgift_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_popRemFun = t_params.popRemFun
    self.m_tData = { level = 5, time = 1, rewardInfo = {}}
    if t_params.gameData and type(t_params.gameData) == "table" then 
        local minLevel = 9999
        for i,v in pairs(t_params.gameData) do
            if minLevel > tonumber(i) then
                minLevel = tonumber(i)
            end
        end
        self.m_tData.level = minLevel
        self.m_tData.time = t_params.gameData[tostring(minLevel)] or 1
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_limitgift_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_limitgift_pop;
