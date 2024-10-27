---  中秋团购

local mid_autumn_group_buy_scene = {
    m_tGameData = nil,
    m_gain_label = nil,
    m_own_label = nil,
    m_buy_total_count_label = nil,
    m_buy_count_label = nil,
    m_anim_node = nil,
    m_item_detail_label = nil,
    m_item_node = nil,
    m_item_cost_label = nil,
    m_ccbNode = nil,
    m_left_time_node = nil,
    m_screenShoot = nil,
    m_ball_layer = nil,
    m_item_count_label = nil,
    m_item_name_label = nil,
    m_shop_id = nil,
    m_buy_max_count = nil,
    m_already_count = nil,
    m_showRewardItemTab = nil,
    m_showRewardTab = nil,
    m_showIdTab = nil,
    m_max_buy_count = nil,
    m_num_bar = nil,
    m_mid_autumn_anim = nil,
    m_groupShowIdTab = nil,
    m_item_cost_label_2 = nil,
    m_red_line = nil,
    m_num_bar_anim_flag = nil,
    title_new_label = nil,
    m_items_tab = nil,
};

--[[--
    销毁ui
]]
function mid_autumn_group_buy_scene.destroy(self)
    -- body
    cclog("-----------------mid_autumn_group_buy_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_gain_label = nil;
    self.m_own_label = nil;
    self.m_buy_total_count_label = nil;
    self.m_buy_count_label = nil;
    self.m_anim_node = nil;
    self.m_item_detail_label = nil;
    self.m_item_node = nil;
    self.m_item_cost_label = nil;
    self.m_ccbNode = nil;
    self.m_left_time_node = nil;
    self.m_screenShoot = nil;
    self.m_ball_layer = nil;
    self.m_item_count_label = nil;
    self.m_item_name_label = nil;
    self.m_shop_id = nil;
    self.m_buy_max_count = nil;
    self.m_already_count = nil;
    self.m_showRewardItemTab = nil;
    self.m_showRewardTab = nil;
    self.m_showIdTab = nil;
    self.m_max_buy_count = nil;
    self.m_num_bar = nil;
    self.m_mid_autumn_anim = nil;
    self.m_groupShowIdTab = nil;
    self.m_item_cost_label_2 = nil;
    self.m_red_line = nil;
    self.m_num_bar_anim_flag = nil;
    self.title_new_label = nil;
    self.m_items_tab = nil;
end

local moonAnimNameTab = {"impact","impact","impact1","impact1","impact2","impact2","impact2","impact3"}

--[[--
    返回
]]
function mid_autumn_group_buy_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene");
end
--[[--
    读取ccbi创建ui
]]
function mid_autumn_group_buy_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 then--详情
            local function responseMethod(tag,gameData)
                game_scene:addPop("mid_autumn_explain_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_group_rank"), http_request_method.GET, {},"active_group_rank")
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
                    cclog("count == " .. count);
                    local function responseMethod(tag,gameData)
                        game_data_statistics:buyItem({shopId = shopItemId,count = count})
                        local data = gameData:getNodeWithKey("data");
                        self.m_tGameData = json.decode(data:getFormatBuffer())
                        local reward = self.m_tGameData.reward or {}
                        game_util:rewardTipsByDataTable(reward);
                        self.m_num_bar_anim_flag = true;
                        self:refreshUi();
                    end
                    local params = {};
                    params.shop_id = shopItemId;
                    params.count = count;
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_group_active_buy"), http_request_method.GET, params,"active_group_active_buy")
                end,
                shopItemId = shopItemId,
                maxCount = 99,
                alreadyCount = 0,
                times_limit = 1,
                touchPriority = GLOBAL_TOUCH_PRIORITY,
                enterType = "mid_autumn_group_buy_scene",
            }
            game_scene:addPop("game_shop_pop",t_params)
        elseif btnTag == 104 then--兑换
            function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_charge_active",{gameData = gameData})
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_active_show"), http_request_method.GET, {},"active_active_show")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_mid_autumn_group_buy.ccbi");
    local title154 = ccbNode:labelTTFForName("title154");
    local title155 = ccbNode:labelTTFForName("title155");
    local title156 = ccbNode:labelTTFForName("title156");
    local title157 = ccbNode:labelTTFForName("title157");
    local title158 = ccbNode:labelTTFForName("title158");
    -- local title159 = ccbNode:labelTTFForName("title159");
    title154:setString(string_helper.ccb.title154);
    title155:setString(string_helper.ccb.title155);
    title156:setString(string_helper.ccb.title156);
    title157:setString(string_helper.ccb.title157);
    title158:setString(string_helper.ccb.title158);
    -- title159:setString(string_helper.ccb.title159);
    self.m_gain_label = ccbNode:labelTTFForName("m_gain_label")
    self.m_own_label = ccbNode:labelTTFForName("m_own_label")
    self.m_buy_total_count_label = ccbNode:labelTTFForName("m_buy_total_count_label")
    self.m_buy_count_label = ccbNode:labelTTFForName("m_buy_count_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_item_detail_label = ccbNode:labelTTFForName("m_item_detail_label")
    self.m_item_node = ccbNode:nodeForName("m_item_node")
    self.m_item_cost_label = ccbNode:labelTTFForName("m_item_cost_label")
    self.m_item_count_label = ccbNode:labelTTFForName("m_item_count_label")
    self.m_item_name_label = ccbNode:labelTTFForName("m_item_name_label")
    self.m_left_time_node = ccbNode:nodeForName("m_left_time_node")
    self.m_ball_layer = ccbNode:layerForName("m_ball_layer")
    self.m_item_cost_label_2 = ccbNode:labelTTFForName("m_item_cost_label_2")
    self.m_red_line = ccbNode:nodeForName("m_red_line")

    local group_version = getConfig(game_config_field.group_version)
    local itemCfg = group_version:getNodeWithKey( tostring(self.m_tGameData.version) )
    local des = itemCfg:getNodeWithKey("des"):toStr()
    self.title_new_label = ccbNode:labelTTFForName("title_new_label")
    self.title_new_label:setString(des)
    -- impact,impact1,impact2,impact3
    local tempAnim = game_util:createUniversalAnim({animFile = "anim_zhongqiujie",rhythm = 1.0,loopFlag = true,animCallFunc = nil});
    if tempAnim then
        self.m_anim_node:addChild(tempAnim)
        self.m_mid_autumn_anim = tempAnim;
    end
    local m_bar_spr = ccbNode:spriteForName("m_bar_spr")
    m_bar_spr:setOpacity(0);
    local bar = ExtProgressTime:createWithFrameName("a_zqmy_jindutiao1.png","a_zqmy_jindutiao2.png");
    bar:setCurValue(0,false);
    m_bar_spr:addChild(bar);
    self.m_num_bar = bar;

    self:initLayerTouch(self.m_ball_layer);
    self.m_ccbNode = ccbNode;
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end

    local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    game_util:setCCControlButtonTitle(m_buy_btn,string_helper.ccb.text74)
    local m_detail_btn = ccbNode:controlButtonForName("m_detail_btn")
    game_util:setCCControlButtonTitle(m_detail_btn,string_helper.ccb.title88)
    local tips_label = ccbNode:labelTTFForName("tips_label")
    tips_label:setString(string_helper.ccb.file79)
    return ccbNode;
end


--[[--
  
]]
function mid_autumn_group_buy_scene.initLayerTouch(self,formation_layer)
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
                for i=1,12 do
                    local m_item_node = self.m_ccbNode:spriteForName("m_item_node_" .. i)
                    if m_item_node then
                        realPos = m_item_node:getParent():convertToNodeSpace(ccp(x,y));
                        if m_item_node:boundingBox():containsPoint(realPos) then
                            cclog("i ==================== " .. i)   
                            local showId = nil;
                            if i < 9 then
                                local showItemIdTab = self.m_groupShowIdTab[1] or {}
                                showId = showItemIdTab[i]
                            else
                                local showEquipIdTab = self.m_groupShowIdTab[2] or {}
                                showId = showEquipIdTab[i - 8]
                            end
                            if showId then
                                local group_show_cfg = getConfig(game_config_field.group_show)
                                local itemCfg = group_show_cfg:getNodeWithKey(showId)
                                local itemTab = json.decode(itemCfg:getNodeWithKey("item"):getFormatBuffer()) or {}
                                if #itemTab > 0 then
                                    game_util:lookItemDetal(itemTab[1])
                                end
                            end
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
    设置购买的道具
]]
function mid_autumn_group_buy_scene.setBuyItemInfo(self,itemCfg)
    self.m_shop_id = nil;
    if itemCfg then
        self.m_shop_id = itemCfg:getKey();              
        local shop_reward = itemCfg:getNodeWithKey("reward")
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
                self.m_item_name_label:setString(name);
            end
        end
        local coin = itemCfg:getNodeWithKey("coin"):toInt();
        local selloff = itemCfg:getNodeWithKey("selloff"):toInt();
        if selloff >= 100 then
            self.m_item_cost_label:setString(coin);
            self.m_item_cost_label_2:setString(coin);
            -- self.m_red_line:setVisible(false);
        else
            self.m_item_cost_label:setString(coin);
            self.m_item_cost_label_2:setString(math.ceil(coin*selloff/100));
            -- self.m_red_line:setVisible(true);
        end
    end
end

function mid_autumn_group_buy_scene.refreshSellOffInfo(self)
    local m_bar_spr = self.m_ccbNode:spriteForName("m_bar_spr")
    local tempSize = m_bar_spr:getContentSize();
    local group_shop_cfg = getConfig(game_config_field.group_shop)
    local index = 1;
    for i=1,#self.m_showIdTab do
        local item_cfg = group_shop_cfg:getNodeWithKey(self.m_showIdTab[i])
        local num = item_cfg:getNodeWithKey("num"):toInt();
        if num > 0 and index < 5 then
            local m_buy_label = self.m_ccbNode:labelTTFForName("m_buy_label_" .. index)
            local m_arrow_img = self.m_ccbNode:spriteForName("m_arrow_img_" .. index)
            local m_discounts_label = self.m_ccbNode:labelTTFForName("m_discounts_label_" .. index)
            local selloff = item_cfg:getNodeWithKey("selloff"):toInt();
            if m_buy_label then
                m_buy_label:setString(tostring(num));
                m_discounts_label:setString(string.format(string_helper.mid_autumn_group_buy_scene.discount,selloff/10))
                local pX = tempSize.width*num/self.m_max_buy_count - 5
                m_buy_label:setPositionX(pX)
                m_arrow_img:setPositionX(pX)
                m_discounts_label:setPositionX(pX)
            end
            index = index + 1;
        end
    end
end

--[[
    
]]
function mid_autumn_group_buy_scene.addItemAndEquipByCid(self,showId,tag)
    local ownItemCount = 0;
    local m_item_node = self.m_ccbNode:spriteForName("m_item_node_" .. tag)
    if m_item_node then
        m_item_node:removeAllChildrenWithCleanup(true);
        if showId then
            
            local group_show_cfg = getConfig(game_config_field.group_show)
            local itemCfg = group_show_cfg:getNodeWithKey(showId)
            local itemTab = json.decode(itemCfg:getNodeWithKey("item"):getFormatBuffer()) or {}
            if #itemTab > 0 then
                local icon,name,count = game_util:getRewardByItemTable(itemTab[1],true)
                local itemCount = game_data:getItemCountByCid(itemTab[1][2])
                ownItemCount = itemCount;
                if icon then
                    if tag < 9 and itemCount <= 0 then
                        icon:setColor(ccc3(81, 81, 81))
                    end
                    local tempSize = m_item_node:getContentSize();
                    icon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                    if tag < 9 then
                        icon:setScale(0.75);
                    else
                        icon:setScale(0.55);
                    end
                    m_item_node:addChild(icon)
                end
            end
        end
    end
    return ownItemCount;
end

--[[
    
]]
function mid_autumn_group_buy_scene.refreshItemAndEquip(self)
    local showItemIdTab = self.m_groupShowIdTab[1] or {}
    local showEquipIdTab = self.m_groupShowIdTab[2] or {}
    local ownItemCount = 0;
    for i=1,8 do
        local tempCount = self:addItemAndEquipByCid(showItemIdTab[i], i);
        if tempCount > 0 then
            ownItemCount = ownItemCount + 1;
        end
    end
    if self.m_mid_autumn_anim and ownItemCount ~= 0 then
        self.m_mid_autumn_anim:playSection(moonAnimNameTab[ownItemCount]);
    end
    for i=1,4 do
        self:addItemAndEquipByCid(showEquipIdTab[i], (8+i));
    end
end

--[[
    倒计时
]]
function mid_autumn_group_buy_scene.refreshLabel(self)
    local countdownTime = self.m_tGameData.remainder_time or 0
    self.m_left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.m_left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.mid_autumn_group_buy_scene.out,color = ccc3(0,255,0),fontSize = 10});
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

--[[--
    刷新ui
]]
function mid_autumn_group_buy_scene.refreshUi(self)
    self.m_item_node:removeAllChildrenWithCleanup(true);
    self.m_item_detail_label:setString(string_helper.mid_autumn_group_buy_scene.wu);
    self.m_item_name_label:setString(string_helper.mid_autumn_group_buy_scene.wu);
    self.m_item_count_label:setString("0");
    self.m_item_cost_label:setString("0");
    self.m_item_cost_label_2:setString("0");
    self.m_red_line:setVisible(true);
    self.m_buy_max_count = 0;
    self.m_already_count = 0;
    self.m_shop_id = nil;
    self.m_showRewardItemTab = nil;
    self.m_showRewardTab = nil;
    local coin = game_data:getUserStatusDataByKey("coin") or 0
    local value,unit = game_util:formatValueToString(coin);
    self.m_own_label:setString(tostring(value));

    local all_goods_count = self.m_tGameData.all_goods_count or 0
    local usr_goods_count = self.m_tGameData.usr_goods_count or 0
    local remission_coin = self.m_tGameData.remission_coin or 0
    self.m_buy_total_count_label:setString(tostring(all_goods_count) .. string_helper.mid_autumn_group_buy_scene.ge)
    self.m_buy_count_label:setString(tostring(usr_goods_count))
    self.m_gain_label:setString(tostring(remission_coin))
    self.m_num_bar:setCurValue(100*all_goods_count/self.m_max_buy_count,self.m_num_bar_anim_flag);

    local group_shop_cfg = getConfig(game_config_field.group_shop)
    local tempCount = group_shop_cfg:getNodeCount();
    local selItmeCfg = nil;
    for k,v in pairs(self.m_showIdTab) do
        local item_cfg = group_shop_cfg:getNodeWithKey(v)
        local num = item_cfg:getNodeWithKey("num"):toInt();
        if all_goods_count < num then
            break;
        end
        selItmeCfg = item_cfg
    end
    if selItmeCfg then
        local num = selItmeCfg:getNodeWithKey("num"):toInt();
        cclog("all_goods_count = " .. all_goods_count .. " ; num == " .. num .. " ; key = " .. selItmeCfg:getKey())
    end
    self:setBuyItemInfo(selItmeCfg);
    self:refreshLabel();
    self:refreshSellOffInfo();
    self:refreshItemAndEquip();
end

--[[--
    初始化
]]
function mid_autumn_group_buy_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_screenShoot = t_params.screenShoot;
    self.m_max_buy_count = 100;
    self.m_showIdTab = {}
    local group_shop_cfg = getConfig(game_config_field.group_shop)
    local tempCount = group_shop_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = group_shop_cfg:getNodeAt(i - 1)
        if itemCfg and itemCfg:getNodeWithKey("version") and itemCfg:getNodeWithKey("version"):toInt() == self.m_tGameData.version then
            local num = itemCfg:getNodeWithKey("num"):toInt();
            if num > self.m_max_buy_count then
                self.m_max_buy_count = num;
            end
            table.insert(self.m_showIdTab,itemCfg:getKey())
        end
    end
    table.sort(self.m_showIdTab,function(data1,data2) return tonumber(data1) < tonumber(data2) end)

    self.m_groupShowIdTab = {};
    local group_show_cfg = getConfig(game_config_field.group_show)
    local tempCount = group_show_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = group_show_cfg:getNodeAt(i-1)
        if game_util:compareItemCfgVersion(itemCfg, self.m_tGameData.version) then
            local sort = itemCfg:getNodeWithKey("sort"):toInt();
            if self.m_groupShowIdTab[sort] == nil then
                self.m_groupShowIdTab[sort] = {};
            end
            table.insert(self.m_groupShowIdTab[sort],itemCfg:getKey());
        end
    end
    for k,v in pairs(self.m_groupShowIdTab) do
        table.sort(v,function(data1,data2) return tonumber(data1) < tonumber(data2) end)
    end
    self.m_buy_max_count = 0;
    self.m_already_count = 0;
    self.m_num_bar_anim_flag = false;
end


--[[--
    创建ui入口并初始化数据
]]
function mid_autumn_group_buy_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return mid_autumn_group_buy_scene;