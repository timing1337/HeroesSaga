---  每日

local game_daily_pop = {
    m_daily_layer = nil,
    m_receive_bg = nil,
    m_selListItem = nil,
    m_popUi = nil,
    m_close_btn = nil,
};
--[[--
    销毁ui
]]
function game_daily_pop.destroy(self)
    -- body
    cclog("-----------------game_daily_pop destroy-----------------");
    self.m_daily_layer = nil;
    self.m_receive_bg = nil;
    self.m_selListItem = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
end
--[[--
    返回
]]
function game_daily_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_daily_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_daily_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then -- 每日

        elseif btnTag == 3 then -- 活动
            -- game_scene:enterGameUi("game_activity_scene",{gameData = nil});
            game_scene:addPop("game_activity_pop")
            self:back();
        elseif btnTag == 4 then -- 公告
            game_scene:addPop("game_announcement_pop")
            self:back();
        elseif btnTag == 11 then -- 领取
            if self.m_selListItem then
                local selTag = self.m_selListItem:getTag();
                local daily_award_cfg = getConfig(game_config_field.daily_award)
                local itemCfg = daily_award_cfg:getNodeAt(selTag);
                local tGameData = game_data:getDailyAwardData();
                local reward = tGameData.reward;
                if game_util:valueInTeam(itemCfg:getKey(),reward) then
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data");
                        -- game_data:setDailyAwardDataByJsonData();
                        game_data:updateMoreEquipDataByJsonData(data:getNodeWithKey("equip"));
                        game_data:updateMoreCardDataByJsonData(data:getNodeWithKey("cards"));
                        game_util:removeValueInTeam(itemCfg:getKey(),reward);
                        self.m_selListItem = nil;
                        self:refreshUi();
                    end
                     --获得礼包  reward＝礼包id（可多个）
                    local params = {};
                    params.reward=itemCfg:getKey();
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_get_reward"), http_request_method.GET, params,"daily_award_get_reward")
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_daily.ccbi");
    self.m_daily_layer = tolua.cast(ccbNode:objectForName("m_daily_layer"), "CCLayer");
    self.m_receive_bg = tolua.cast(ccbNode:objectForName("m_receive_bg"), "CCNode");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建日期列表
]]
function game_daily_pop.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    local daily_award_cfg = getConfig(game_config_field.daily_award)
    local tGameData = game_data:getDailyAwardData();
    local score = tGameData.score;
    local reward = tGameData.reward;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 4; --列
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("o_public_110.png")
            -- spriteLand:ignoreAnchorPointForPosition(false);
            -- spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- cell:addChild(spriteLand,1,1)
            -- local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            local msgLabel = CCLabelBMFont:create("","textmap.fnt");
            msgLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            tolua.cast(cell:getChildByTag(10),"CCLabelBMFont"):setString(index+1);
            if not game_util:valueInTeam(itemCfg:getKey(),reward) and (index+1) <= score then
                local tempLabel = tolua.cast(cell:getChildByTag(10),"CCLabelBMFont");
                tempLabel:setString(index + 1);
                local public_right = CCSprite:createWithSpriteFrameName("public_right.png")
                public_right:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.25));
                cell:addChild(public_right,20,20)
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建奖励列表
]]
function game_daily_pop.createRewardTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    local daily_award_cfg = getConfig(game_config_field.daily_award)
    local tGameData = game_data:getDailyAwardData();
    local score = tGameData.score;
    local reward = tGameData.reward;

    local btnFlag = true;
    local function onMainBtnClick( target,event )
        -- cclog("game_daily_pop event =============" .. event)
        if event == 2 then
            btnFlag = false;
        elseif event == 32 then
            if btnFlag then
                local tagNode = tolua.cast(target,"CCControlButton");
                local btnTag = tagNode:getTag();
                local itemCfg = daily_award_cfg:getNodeAt(btnTag);
                if game_util:valueInTeam(itemCfg:getKey(),reward) then
                    local function responseMethod(tag,gameData)
                        game_util:setCCControlButtonTitle(tagNode,string_helper.game_daily_pop.geted)
                        tagNode:setEnabled(false);
                        local data = gameData:getNodeWithKey("data");
                        -- game_data:setDailyAwardDataByJsonData();
                        game_data:updateMoreEquipDataByJsonData(data:getNodeWithKey("equip"));
                        game_data:updateMoreCardDataByJsonData(data:getNodeWithKey("cards"));
                        game_util:removeValueInTeam(itemCfg:getKey(),reward);
                        self:refreshUi();
                    end
                     --获得礼包  reward＝礼包id（可多个）
                    local params = {};
                    params.reward=itemCfg:getKey();
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_get_reward"), http_request_method.GET, params,"daily_award_get_reward")
                end
            end
            btnFlag = true;
        else
            btnFlag = true;
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_game_daily_reward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local m_icon_spr = ccbNode:spriteForName("m_icon_spr");
                local m_top_label = ccbNode:labelTTFForName("m_top_label")
                local m_bottom_label = ccbNode:labelTTFForName("m_bottom_label")
                local m_btn = ccbNode:controlButtonForName("m_btn")
                m_top_label:setString(string_helper.game_daily_pop.sign .. (index+1) .. string_helper.game_daily_pop.day)
                local rewardItem1 = self:getRewardItem(1,itemCfg:getNodeWithKey("award1_sort"):toInt(),itemCfg:getNodeWithKey("award1_ID"):toStr(),itemCfg:getNodeWithKey("num1"):toInt());
                local rewardItem2 = self:getRewardItem(2,itemCfg:getNodeWithKey("award2_sort"):toInt(),itemCfg:getNodeWithKey("award2_ID"):toStr(),itemCfg:getNodeWithKey("num2"):toInt());
                m_bottom_label:setString(rewardItem1 .. ";" .. rewardItem2)
                m_btn:setTag(index);
                if (index+1) <= score then
                    if not game_util:valueInTeam(itemCfg:getKey(),reward) then
                        m_btn:setVisible(true)
                        m_btn:setEnabled(false);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_daily_pop.geted)
                    else
                        m_btn:setVisible(true)
                        m_btn:setEnabled(true);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_daily_pop.getReward)
                    end
                else
                    m_btn:setVisible(false)
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_daily_pop.refreshRewardDetail(self,item)
    local tGameData = game_data:getDailyAwardData();
    local reward = tGameData.reward;
    if self.m_selListItem then
        tolua.cast(self.m_selListItem:getChildByTag(1),"CCLayerColor"):setOpacity(0);
    end
    self.m_selListItem = item;
    if self.m_selListItem then
        tolua.cast(self.m_selListItem:getChildByTag(1),"CCLayerColor"):setOpacity(255);
        local selTag = self.m_selListItem:getTag();
        local daily_award_cfg = getConfig(game_config_field.daily_award)
        local itemCfg = daily_award_cfg:getNodeAt(selTag);
        if itemCfg == nil then return end
        if game_util:valueInTeam(itemCfg:getKey(),reward) then
            
        end
        self.m_receive_bg:removeAllChildrenWithCleanup(true);
        self:refreshRewardItem(1,itemCfg:getNodeWithKey("award1_sort"):toInt(),itemCfg:getNodeWithKey("award1_ID"):toStr(),itemCfg:getNodeWithKey("num1"):toInt());
        self:refreshRewardItem(2,itemCfg:getNodeWithKey("award2_sort"):toInt(),itemCfg:getNodeWithKey("award2_ID"):toStr(),itemCfg:getNodeWithKey("num2"):toInt());
    end
end

--[[--

]]
function game_daily_pop.refreshRewardItem(self,index,award_sort,award_id,mun)
        -- "award1_ID" : 0,
        -- "num1" : 100,
        -- "num2" : 3,
        -- "award1_sort" : 1,
        -- "award2_ID" : 0,
        -- "award2_sort" : 2
        -- 1：钻石 2：钻石 3：装备 4：卡牌 5：道具 6：物资 7：能源
    local rewardText = nil;
    if award_sort == 1 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.diamond .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 2 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.diamond .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 3 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.equip .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 4 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.card .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 5 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.item .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 6 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.goods .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 7 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_pop.energy .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    end
    if rewardText then
        local bgSize = self.m_receive_bg:getContentSize();
        rewardText:setPosition(ccp(bgSize.width*0.5,bgSize.height*(1 - 0.2*index)));
        self.m_receive_bg:addChild(rewardText);
    end
end

--[[--

]]
function game_daily_pop.getRewardItem(self,index,award_sort,award_id,mun)
        -- "award1_ID" : 0,
        -- "num1" : 100,
        -- "num2" : 3,
        -- "award1_sort" : 1,
        -- "award2_ID" : 0,
        -- "award2_sort" : 2
        -- 1：钻石 2：钻石 3：装备 4：卡牌 5：道具 6：物资 7：能源
    local rewardItem = "";
    if award_sort == 1 then
        rewardItem = string_helper.game_daily_pop.diamond .. mun;
    elseif award_sort == 2 then
        rewardItem = string_helper.game_daily_pop.diamond .. mun;
    elseif award_sort == 3 then
        rewardItem = string_helper.game_daily_pop.equip .. award_id .. " x" .. mun;
    elseif award_sort == 4 then
        rewardItem = string_helper.game_daily_pop.card .. award_id .. " x" .. mun;
    elseif award_sort == 5 then
        rewardItem = string_helper.game_daily_pop.item .. award_id .. " x" .. mun;
    elseif award_sort == 6 then
        rewardItem = string_helper.game_daily_pop.goods .. mun;
    elseif award_sort == 7 then
        rewardItem = string_helper.game_daily_pop.energy .. mun;
    end
    return rewardItem;
end

--[[--
    刷新ui
]]
function game_daily_pop.refreshUi(self)
    self.m_daily_layer:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_daily_layer:getContentSize());
    tableViewTemp:setMoveFlag(false);
    tableViewTemp:setScrollBarVisible(false);
    self.m_daily_layer:addChild(tableViewTemp);
    self.m_receive_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createRewardTableView(self.m_receive_bg:getContentSize());
    self.m_receive_bg:addChild(tableViewTemp)
end
--[[--
    初始化
]]
function game_daily_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setDailyAwardDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_daily_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_daily_pop;