---  龙珠降临

local dragon_ball_scene = {
    m_tGameData = nil,
    m_reward_table_node = nil,
    m_ball_node = nil,
    m_detail_label = nil,
    m_own_label = nil,
    m_percent_label = nil,
    m_anim_node = nil,
    m_item_detail_label = nil,
    m_item_node = nil,
    m_item_cost_label = nil,
    m_ccbNode = nil,
    m_left_time_node = nil,
    m_dragon_spr = nil,
    m_screenShoot = nil,
    m_showIdTab = nil,
    m_ball_layer = nil,
    m_item_count_label = nil,
    m_item_name_label = nil,
    m_shop_id = nil,
    m_buy_max_count = nil,
    m_already_count = nil,
    m_showRewardItemTab = nil,
    m_showRewardTab = nil,
    m_select_spr = nil,
    m_curPage = nil,
};

--[[--
    销毁ui
]]
function dragon_ball_scene.destroy(self)
    -- body
    cclog("-----------------dragon_ball_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_reward_table_node = nil;
    self.m_ball_node = nil;
    self.m_detail_label = nil;
    self.m_own_label = nil;
    self.m_percent_label = nil;
    self.m_anim_node = nil;
    self.m_item_detail_label = nil;
    self.m_item_node = nil;
    self.m_item_cost_label = nil;
    self.m_ccbNode = nil;
    self.m_left_time_node = nil;
    self.m_dragon_spr = nil;
    self.m_screenShoot = nil;
    self.m_showIdTab = nil;
    self.m_ball_layer = nil;
    self.m_item_count_label = nil;
    self.m_item_name_label = nil;
    self.m_shop_id = nil;
    self.m_buy_max_count = nil;
    self.m_already_count = nil;
    self.m_showRewardItemTab = nil;
    self.m_showRewardTab = nil;
    self.m_select_spr = nil;
    self.m_curPage = nil;
end
--[[--
    返回
]]
function dragon_ball_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function dragon_ball_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "btnTag  =====   ")
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--详情
            game_scene:addPop("dragon_ball_explain_pop", {version = self.m_tGameData.all_version})
        elseif btnTag == 102 then--查看道具
            if self.m_showRewardItemTab == nil then
                return;
            end
            game_util:lookItemDetal(self.m_showRewardItemTab);
        elseif btnTag == 103 then--购买
            local shopItemId = self.m_shop_id
            if shopItemId == nil then
                return;
            end
            local t_params = 
            {
                okBtnCallBack = function(count)
                    local function responseMethod(tag,gameData)
                        game_data_statistics:buyItem({shopId = shopItemId,count = count})
                        local data = gameData:getNodeWithKey("data");
                        local reward = data:getNodeWithKey("goods")
                        if reward then
                            reward = json.decode(reward:getFormatBuffer())
                        else
                            reward = {};
                        end
                        local function responseMethod(tag,gameData)
                            game_util:rewardTipsByDataTable(reward);
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer())
                            self:refreshUi();
                        end
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_active_index"), http_request_method.GET, {all_open = 1},"super_active_index")
                    end
                    local params = {};
                    params.shop_id = shopItemId;
                    params.count = count;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_buy"), http_request_method.GET, params,"shop_buy")
                end,
                shopItemId = shopItemId,
                maxCount = self.m_buy_max_count,
                alreadyCount = self.m_already_count,
                times_limit = 1,
                touchPriority = GLOBAL_TOUCH_PRIORITY,
                enterType = "game_buy_item_scene",
            }
            game_scene:addPop("game_shop_pop",t_params)
        elseif btnTag == 104 then--查看
            if self.m_showRewardTab == nil then
                return;
            end
            game_util:lookItemDetal(self.m_showRewardTab)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dragon_ball.ccbi");
    self.m_reward_table_node = ccbNode:nodeForName("m_reward_table_node")
    self.m_ball_node = ccbNode:nodeForName("m_ball_node")
    self.m_detail_label = ccbNode:labelTTFForName("m_detail_label")
    self.m_own_label = ccbNode:labelTTFForName("m_own_label")
    self.m_percent_label = ccbNode:labelTTFForName("m_percent_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_item_detail_label = ccbNode:labelTTFForName("m_item_detail_label")
    self.m_item_node = ccbNode:nodeForName("m_item_node")
    self.m_item_cost_label = ccbNode:labelTTFForName("m_item_cost_label")
    self.m_item_count_label = ccbNode:labelTTFForName("m_item_count_label")
    self.m_item_name_label = ccbNode:labelTTFForName("m_item_name_label")
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
    self.m_ball_layer = ccbNode:layerForName("m_ball_layer")
    self.m_select_spr = ccbNode:spriteForName("m_select_spr")
    self:initLayerTouch(self.m_ball_layer);
    self.m_dragon_spr = ccbNode:spriteForName("m_dragon_spr")
    local pX,pY = self.m_dragon_spr:getPosition();
    local animArr = CCArray:create();
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY+5)),CCTintTo:create(1,175,175,175)))
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY-5)),CCTintTo:create(1,255,255,255)))
    -- animArr:addObject(CCTintTo:create(1,175,175,175))
    -- animArr:addObject(CCTintTo:create(1,255,255,255))
    self.m_dragon_spr:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text123)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text124)
    local text3 = ccbNode:labelTTFForName("text3")
    text3:setString(string_helper.ccb.text125)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text126)
    local text5 = ccbNode:labelTTFForName("text5")
    text5:setString(string_helper.ccb.text127)
    local m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
    game_util:setCCControlButtonTitle(m_detail_btn,string_helper.ccb.text128)
    local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    game_util:setCCControlButtonTitle(m_buy_btn,string_helper.ccb.text129)
    return ccbNode;
end


--[[--
  
]]
function dragon_ball_scene.initLayerTouch(self,formation_layer)
    local realPos = nil;
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        touchBeginPoint = {x = x, y = y}
        return true
    end
    
    local function onTouchMoved(x, y)
        if touchMoveFlag == false and ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
            touchMoveFlag = true;
        end
    end
    
    local function onTouchEnded(x, y)
        local all_reward_log = self.m_tGameData.all_reward_log or {}
        local realPos = formation_layer:getParent():convertToNodeSpace(ccp(x,y));
        if formation_layer:boundingBox():containsPoint(realPos) then
            if not touchMoveFlag then
                for i=1,7 do
                    local m_ball = self.m_ccbNode:spriteForName("m_ball_" .. i)
                    if m_ball then
                        realPos = m_ball:getParent():convertToNodeSpace(ccp(x,y));
                        if m_ball:boundingBox():containsPoint(realPos) then
                            local m_receiving_spr = self.m_ccbNode:spriteForName("m_receiving_spr_" .. i)
                            if m_receiving_spr and m_receiving_spr:isVisible() then
                                cclog("i ==================== " .. i)
                                self:getDragonBallRewardByKey(i)
                            end
                            self:setSelectDragonBallInfo(i);
                            break;
                        end
                    end
                end
            end
        end
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY)
    formation_layer:setTouchEnabled(true)
end
--[[
    获取奖励
]]
function dragon_ball_scene.getDragonBallRewardByKey(self,posIndex)
    local tempKey = self.m_showIdTab[posIndex]
    if tempKey == nil then
        return;
    end
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer())
        game_util:rewardTipsByDataTable(self.m_tGameData.reward);
        self:refreshUi();
    end
    local params = {};
    params.step = tempKey;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("super_active_get_all_reward"), http_request_method.GET, params,"super_active_get_all_reward")
end
--[[

]]
function dragon_ball_scene.setSelectDragonBallInfo(self,posIndex)
    local super_all_cfg = getConfig(game_config_field.super_all)
    local tempKey = self.m_showIdTab[posIndex]
    local itemCfg = super_all_cfg:getNodeWithKey(tempKey)
    if itemCfg then
        local all_scores = self.m_tGameData.all_scores or 0
        local score = itemCfg:getNodeWithKey("score"):toInt();
        local base = itemCfg:getNodeWithKey("base"):toInt();
        self.m_detail_label:setString(string_helper.dragon_ball_scene.title1 .. score .. string_helper.dragon_ball_scene.title2 .. all_scores .. string_helper.dragon_ball_scene.title3)
        local m_ball = self.m_ccbNode:spriteForName("m_ball_" .. posIndex)
        if m_ball then
            local pX,pY = m_ball:getPosition();
            local tempSize = m_ball:getContentSize();
            local tempSize2 = self.m_select_spr:getContentSize();
            self.m_select_spr:setPosition(ccp(pX,pY))
            self.m_select_spr:setScale(tempSize.width/tempSize2.width + 0.1);
        end
        self:setDragonBallRewardInfo(itemCfg,posIndex);
    end
end

--[[
    创建奖励列表
]]
function dragon_ball_scene.createRewardTabelView(self,viewSize,rewardTab)
    local rewardTab = rewardTab or {};
    local tempCount = #rewardTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    if tempCount < 4 then
        params.column = tempCount; --列
    else
        params.column = 4; --列
    end
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local icon,name,count = game_util:getRewardByItemTable(rewardTab[index+1],false)
            if icon then
                icon:setScale(0.65);
                icon:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.6))
                cell:addChild(icon)
            end
            if count then
                local tempLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255),fontSize = 8});
                tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.3))
                cell:addChild(tempLabel)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

function dragon_ball_scene.refreshRewardTabelView(self,viewSize,rewardTab)
    self.m_reward_table_node:removeAllChildrenWithCleanup(true);
    local showFlag = true;
    local tempCount = #self.m_showIdTab;
    local params = {};
    params.viewSize = viewSize;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tempCount;
    params.showPageIndex = self.m_curPage;
    params.showPoint = false;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    params.pageChangedCallFunc = function(totalPage,curPage,parentNode)
        if showFlag == true then
            showFlag = false;
            parentNode:removeChildByTag(1000, true);
            local tempRewardTable = self:createRewardTabelView(self.m_reward_table_node:getContentSize(),rewardTab);
            parentNode:addChild(tempRewardTable,1000,1000);
        else
            self.m_curPage = curPage;
            self:setSelectDragonBallInfo(curPage);
        end
        cclog("totalPage ==== " .. totalPage .. " ; curPage === " .. curPage )
    end
    local tempView = game_util:createGalleryPage(params);
    self.m_reward_table_node:addChild(tempView,10,10)
end


--[[
    设置购买的道具
]]
function dragon_ball_scene.setBuyItemInfo(self,shop_id)
    local shopCfg = getConfig(game_config_field.shop);
    local itemCfg = shopCfg:getNodeWithKey(shop_id)
    if itemCfg then
        self.m_shop_id = shop_id;              
        local boughtTab = self.m_tGameData.bought or {}
        local sell_max = itemCfg:getNodeWithKey("sell_max"):toInt()
        local bought = boughtTab[shop_id] or 0;
        local shop_reward = itemCfg:getNodeWithKey("shop_reward")
        self.m_buy_max_count = sell_max;
        self.m_already_count = bought;
        local rewardCount = shop_reward:getNodeCount();
        if rewardCount > 0 then
            self.m_showRewardItemTab = json.decode(shop_reward:getNodeAt(0):getFormatBuffer())
            local icon,name,count = game_util:getRewardByItemTable(self.m_showRewardItemTab);
            local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_showRewardItemTab[2]));
            if config_date then
                self.m_item_detail_label:setString(config_date:getNodeWithKey("story"):toStr())
            end
            if icon then
                self.m_item_node:addChild(icon);
            end
            if name then
                if sell_max == 0 then
                    self.m_item_name_label:setString(name);
                else
                    self.m_item_name_label:setString(name .. "(" .. (sell_max-bought)..")")
                end
            end
            if count > 1 then
                self.m_item_count_label:setString("×" .. count)
            else
                self.m_item_count_label:setString("")
            end
        end
        local need_value = itemCfg:getNodeWithKey("need_value");
        local need_value_count = need_value:getNodeCount();
        if need_value_count > 0 then
            self.m_item_cost_label:setString(need_value:getNodeAt(math.min(bought,need_value_count-1)):toInt());
        else
            self.m_item_cost_label:setString("0");
        end
    end
end
--[[
    倒计时
]]
function dragon_ball_scene.setCountdownTime(self,countdownTime)
    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.m_left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.dragon_ball_scene.title4,color = ccc3(0,255,0),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(tipsLabel,10,12)
    end
    
    if countdownTime > 0 then
        local countdownLabel = game_util:createCountdownLabel(countdownTime,timeEndFunc,8, 1);
        countdownLabel:setColor(ccc3(0, 255, 0))
        countdownLabel:setAnchorPoint(ccp(0.5,0.5))
        self.m_left_time_node:addChild(countdownLabel,10,10)
    else
        timeEndFunc();
    end
end


function dragon_ball_scene.setDragonBallRewardInfo(self,itemCfg,posIndex)
    self.m_curPage = posIndex;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local countdownTime = 0;
    local reward = itemCfg:getNodeWithKey("reward");
    self:refreshRewardTabelView(self.m_reward_table_node:getContentSize(),json.decode(reward:getFormatBuffer()));
    -- local end_time = itemCfg:getNodeWithKey("end_time"):toFloat();
    local server_time = game_data:getUserStatusDataByKey("server_time") or os.time();
    local end_time = self.m_tGameData.all_end_time or server_time
    countdownTime = end_time - server_time;
    local show = itemCfg:getNodeWithKey("show");
    local showReward = show:getNodeAt(0)
    if showReward then
        local showRewardTab = json.decode(showReward:getFormatBuffer())
        self.m_showRewardTab = showRewardTab;
        local rewardType = showRewardTab[1]
        local tempId = showRewardTab[2]
        if rewardType == 5 then
            local character_detail_cfg = getConfig(game_config_field.character_detail);
            local itemCfg = character_detail_cfg:getNodeWithKey(tostring(tempId));
            cclog("rewardType ======== " .. tostring(rewardType) .. " ; tempId == " .. tostring(tempId) .. " ; itemCfg == " .. tostring(itemCfg))
            if itemCfg then
                local ainmFile = itemCfg:getNodeWithKey("animation"):toStr();
                local animNode = game_util:createAnimSequence(ainmFile,0,nil,itemCfg);
                if animNode then
                    animNode:setScale(0.6);
                    animNode:setRhythm(1);
                    animNode:setAnchorPoint(ccp(0.5,0));
                    self.m_anim_node:addChild(animNode);
                end
            end
        end
    end
    local shop_id = itemCfg:getNodeWithKey("shop_id"):toStr();
    self:setBuyItemInfo(shop_id);
    return countdownTime
end

--[[--
    刷新ui
]]
function dragon_ball_scene.refreshUi(self)
    self.m_item_node:removeAllChildrenWithCleanup(true);
    self.m_item_detail_label:setString(string_helper.dragon_ball_scene.title5);
    self.m_item_name_label:setString(string_helper.dragon_ball_scene.title5);
    self.m_item_count_label:setString("");
    self.m_item_cost_label:setString("0");
    self.m_detail_label:setString("");
    self.m_buy_max_count = 0;
    self.m_already_count = 0;
    self.m_shop_id = nil;
    self.m_showRewardItemTab = nil;
    self.m_showRewardTab = nil;
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    local countdownTime = 0;
    local all_scores = self.m_tGameData.all_scores or 0
    local scores = self.m_tGameData.all_user_scores or 0
    self.m_own_label:setString(tostring(scores));
    if all_scores <= 0 then
        self.m_percent_label:setString("0%");
    else
        self.m_percent_label:setString(math.floor(scores*100/all_scores) .. "%");
    end
    self.m_reward_table_node:removeAllChildrenWithCleanup(true)
    local super_all_cfg = getConfig(game_config_field.super_all)
    local showFlag,isShowFlag = false,false;
    local tempCount = #self.m_showIdTab
    local all_reward_log = self.m_tGameData.all_reward_log or {}
    for i=1,math.min(tempCount,7) do
        local m_ball = self.m_ccbNode:spriteForName("m_ball_" .. i)
        local m_receiving_spr = self.m_ccbNode:spriteForName("m_receiving_spr_" .. i)
        m_ball:setColor(ccc3(121, 121, 121))
        m_receiving_spr:setVisible(false);
        local tempKey = self.m_showIdTab[i];
        local itemCfg = super_all_cfg:getNodeWithKey(tempKey)
        if itemCfg then
            local score = itemCfg:getNodeWithKey("score"):toInt();
            local base = itemCfg:getNodeWithKey("base"):toInt();
            if all_scores < score then--全服
                showFlag = true;
            else
                m_ball:setColor(ccc3(255, 255, 255))
                if scores >= base then--条件达成
                    if all_reward_log[tempKey] == nil then--可以领取
                        m_receiving_spr:setVisible(true);
                    end
                end
            end
            if isShowFlag == false and (showFlag == true or i == tempCount) then
                isShowFlag = true;
                self.m_detail_label:setString(string_helper.dragon_ball_scene.title1 .. score .. string_helper.dragon_ball_scene.title2 .. all_scores .. string_helper.dragon_ball_scene.title3)
                countdownTime = self:setDragonBallRewardInfo(itemCfg,i);
                local pX,pY = m_ball:getPosition();
                self.m_select_spr:setPosition(ccp(pX,pY))
            end
        end
    end
    self:setCountdownTime(countdownTime);
end

--[[--
    初始化
]]
function dragon_ball_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_screenShoot = t_params.screenShoot;
    self.m_showIdTab = {}
    local super_all_cfg = getConfig(game_config_field.super_all)
    local tempCount = super_all_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = super_all_cfg:getNodeAt(i - 1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.all_version) then
            table.insert(self.m_showIdTab,itemCfg:getKey())
        end
    end
    table.sort(self.m_showIdTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    self.m_buy_max_count = 0;
    self.m_already_count = 0;
end


--[[--
    创建ui入口并初始化数据
]]
function dragon_ball_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return dragon_ball_scene;