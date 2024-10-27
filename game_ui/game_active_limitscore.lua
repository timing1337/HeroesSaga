---  限时活动

local game_active_limitscore_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_idTab = nil,

    rank_node = nil,
    left_time_node = nil,
    reward_table_node = nil,
    points_label = nil,
    points_rank_label = nil,
    left_dimond_label = nil,
    btn_recharge = nil,
    btn_detail = nil,
    anim_node = nil,


    m_conbtn_scoreShop = nil,

    m_score = nil,
    m_activeType = nil,
};
--[[--
    销毁ui
]]
function game_active_limitscore_pop.destroy(self)
    -- body
    cclog("----------------- game_active_limitscore_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;

    self.rank_node = nil;
    self.left_time_node = nil;
    self.reward_table_node = nil;
    self.points_label = nil;
    self.points_rank_label = nil;
    self.left_dimond_label = nil;
    self.btn_recharge = nil;
    self.btn_detail = nil;
    self.anim_node = nil;

    self.m_conbtn_scoreShop = nil;
    self.m_score = nil;
    self.m_activeType = nil;
end
--[[--
    返回
]]
function game_active_limitscore_pop.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_active_limitscore_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then--充值
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then--查看详情
            game_scene:addPop("game_active_limit_detail_pop",{enterType = self.m_activeType})
        elseif btnTag == 101 then--  积分商城
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_buy_shop_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("integration_shop"), http_request_method.GET, {},"integration_shop")
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_active_limitscore.ccbi");
    -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    self.rank_node = ccbNode:nodeForName("rank_node");
    -- self.left_time_label_node = ccbNode:nodeForName("left_time_label_node");
    self.reward_table_node = ccbNode:nodeForName("reward_table_node");--奖励列表node
    self.points_label = ccbNode:labelTTFForName("points_label");--当前积分
    self.points_rank_label = ccbNode:labelTTFForName("points_rank_label");--当前积分排名
    self.left_dimond_label = ccbNode:labelTTFForName("left_dimond_label");--剩余钻石
    self.btn_recharge = ccbNode:controlButtonForName("btn_recharge");
    self.btn_detail = ccbNode:controlButtonForName("btn_detail");   
    self.anim_node = ccbNode:nodeForName("anim_node");
    self.left_time_node = ccbNode:nodeForName("left_time_node");
    self.m_conbtn_scoreShop = ccbNode:controlButtonForName("m_conbtn_scoreShop")


    self.m_conbtn_scoreShop:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    -- game_util:setControlButtonTitleBMFont(self.m_conbtn_scoreShop)

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    --添加英雄
    local giftCfg = getConfig(game_config_field.ranking);
    -- print("giftCfg == ", giftCfg:getFormatBuffer())
    local itemCfg = giftCfg:getNodeWithKey(tostring(1))
    local reward = itemCfg:getNodeWithKey("reward")
    -- print("reward == ", reward:getFormatBuffer())
    local itemData = reward:getNodeAt(0)
    local cardId = itemData:getNodeAt(1):toInt()
    self:createAnimNode(cardId)
    return ccbNode;
end
--[[
    招募后刷新
]]
function game_active_limitscore_pop.refreshLabel(self)
    -- --倒计时
    self.left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.game_active_limitscore_pop.text,color = ccc3(255,255,255),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        tipsLabel:setPosition(ccp(0,0))
        self.left_time_node:addChild(tipsLabel,10,12)
    end
    local countdownLabel = game_util:createCountdownLabel(tonumber(self.m_tGameData.delta_time),timeEndFunc,8);
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setPosition(ccp(0,0))
    self.left_time_node:addChild(countdownLabel,10,10)

    if tonumber(self.m_tGameData.delta_time) <= 0 then
        countdownLabel:setTime(1)
    end
    -- --免费倒计时
    -- self.free_one_node:removeAllChildrenWithCleanup(true)
    -- local function timeEndFunc2()
    --     self.free_one_node:removeAllChildrenWithCleanup(true)
    --     local tipsLabel = game_util:createLabelTTF({text = "免费招募",color = ccc3(255,255,255),fontSize = 10});
    --     tipsLabel:setAnchorPoint(ccp(0.5,0.5))
    --     tipsLabel:setPosition(ccp(0,0))
    --     self.free_one_node:addChild(tipsLabel,10,12)
    -- end
    -- local gacha_coin = self.m_tGameData.gacha_coin
    -- local free_time = gacha_coin.free_time
    -- local countdownLabel2 = game_util:createCountdownLabel(tonumber(free_time),timeEndFunc2,8);
    -- countdownLabel2:setAnchorPoint(ccp(0.5,0.5))
    -- countdownLabel2:setPosition(ccp(0,5))
    -- self.free_one_node:addChild(countdownLabel2,10,10)

    -- local freeLabel = game_util:createLabelTTF({text = "后免费",color = ccc3(255,255,255),fontSize = 10});
    -- freeLabel:setAnchorPoint(ccp(0.5,0.5))
    -- freeLabel:setPosition(ccp(0,-5))
    -- self.free_one_node:addChild(freeLabel,10,11)

    -- if free_time == 0 then
    --     countdownLabel2:setTime(1)
    -- end

    self.points_label:setString(self.m_tGameData.score);
    self.points_rank_label:setString(self.m_tGameData.rank);
    self.left_dimond_label:setString(tostring(game_data:getUserStatusDataByKey("coin")));
end
--[[
    添加英雄动画
]]
function game_active_limitscore_pop.createAnimNode(self,cardId)
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardId));
    local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
    local animNode = nil
    animNode = game_util:createIdelAnim(ainmFile,0,cardData,heroCfg);
    if animNode then
        animNode:setRhythm(1);
        animNode:setAnchorPoint(ccp(0.5,0));
        animNode:setScale(1.1);
        self.anim_node:addChild(animNode);
    end
end
--[[--
    创建列表 积分排行榜
]]
function game_active_limitscore_pop.createTableView(self,viewSize)
    local rankTable = self.m_tGameData.score_ranks
    local function sortfunction( data1,data2 )
        return tonumber(data1.rank) < tonumber(data2.rank)
    end
    table.sort( rankTable, sortfunction )
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
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

            local rankData = rankTable[index+1]
            local name = rankData.name
            local score = rankData.score

            -- detail_label:setString(tostring(index+1) .. "." .. name .. "   " .. score)
            detail_label:setString(tostring(index+1) .. "." .. name)
            detail_label_score:setString( tostring(score))
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
    创建奖励列表
]]
function game_active_limitscore_pop.createRewardTabelView(self,viewSize)
    local rewardPos = {
        {0},
        {-30,30},
        {-42,0,42},
    }
    local giftCfg = getConfig(game_config_field.ranking);
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local btnType = math.floor(btnTag / 10)
        local index = math.floor(btnTag % 10)
        -- cclog("btnTag == " .. btnTag)
        -- cclog("btnType = " .. btnType)
        -- cclog("index == " .. index)
        local itemCfg = giftCfg:getNodeWithKey(tostring(btnType))
        local reward = itemCfg:getNodeWithKey("reward")--奖励
        local rewardItem = reward:getNodeAt(index-1)
        local itemData = json.decode(rewardItem:getFormatBuffer())
        game_util:lookItemDetal(itemData)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = giftCfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:openCCBFile("ccb/ui_active_limit_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local reward_label = ccbNode:labelTTFForName("reward_label");
            local reward_node = ccbNode:nodeForName("reward_node");

            local itemCfg = giftCfg:getNodeWithKey(tostring(index+1))
            local reward = itemCfg:getNodeWithKey("reward")--奖励
            local rankInfo = itemCfg:getNodeWithKey("name") and itemCfg:getNodeWithKey("name"):toStr() or string_helper.game_active_limitscore_pop.text2  -- 排名奖励信息

            reward_label:setString(rankInfo .. string_helper.game_active_limitscore_pop.text3)
            reward_node:removeAllChildrenWithCleanup(true)
            for i=1,reward:getNodeCount() do
                local rewardItem = reward:getNodeAt(i-1)
                local reward_icon,name,count = game_util:getRewardByItem(rewardItem,true);
                local posTable = rewardPos[reward:getNodeCount()]
                if reward_icon then
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.8)
                    reward_icon:setPosition(ccp(posTable[i],0))

                    if count then
                        local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count), fontSize})
                        blabelCount:setAnchorPoint(ccp(0.5, 0))
                        blabelCount:setPosition(reward_icon:getContentSize().width * 0.5, 0)
                        reward_icon:addChild(blabelCount, 11)
                    end
                    reward_node:addChild(reward_icon,10,10)
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(posTable[i],0))
                    button:setOpacity(0)
                    reward_node:addChild(button)
                    button:setTag((index + 1)*10 + i)
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
--[[--
    刷新
]]
function game_active_limitscore_pop.refreshTableView(self)
    self.rank_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.rank_node:getContentSize());
    self.rank_node:addChild(self.m_tableView,10,10);
end

--[[
    刷新奖励
]]
function game_active_limitscore_pop.refreshRewardTableView(self)
   self.reward_table_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable = self:createRewardTabelView(self.reward_table_node:getContentSize());
   self.reward_table_node:addChild(tempRewardTable,10,10)
end
--[[--
    刷新ui
]]
function game_active_limitscore_pop.refreshUi(self)
    self:refreshTableView();
    self:refreshRewardTableView();
    self:refreshLabel();
end
--[[--
    初始化
]]
function game_active_limitscore_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        self.m_activeType = tostring(self.m_tGameData.integration_type)
    else
        self.m_tGameData = {};
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_active_limitscore_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_active_limitscore_pop;
