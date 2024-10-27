--game daily scene  每日

local game_daily_scene = {
    m_daily_layer = nil,
    m_receive_bg = nil,
    m_receive_btn = nil,
    m_selListItem = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
};
--[[--
    销毁ui
]]
function game_daily_scene.destroy(self)
    -- body
    cclog("-----------------game_daily_scene destroy-----------------");
    self.m_daily_layer = nil;
    self.m_receive_bg = nil;
    self.m_receive_btn = nil;
    self.m_selListItem = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_tab_btn_1 = nil
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
end
--[[--
    返回
]]
function game_daily_scene.back(self,backType)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_daily_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then -- 每日

        elseif btnTag == 3 then -- 活动
            -- game_scene:enterGameUi("game_activity_scene",{gameData = nil});
            require("game_ui.game_activity_scene"):addPop({gameData = nil})
            self:back();
        elseif btnTag == 4 then -- 公告

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
    self.m_receive_btn = tolua.cast(ccbNode:objectForName("m_receive_btn"), "CCControlButton");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_receive_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_1:setHighlighted(true);
    self.m_tab_btn_1:setEnabled(false);

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
function game_daily_scene.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");

    local daily_award_cfg = getConfig(game_config_field.daily_award)
    local tGameData = game_data:getDailyAwardData();
    local score = tGameData.score;
    local reward = tGameData.reward;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 7; --列
    params.totalItem = daily_award_cfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            -- local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            local msgLabel = CCLabelBMFont:create("","textmap.fnt");
            msgLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            if msgLabel and (index+1) <= score then
                msgLabel:setString(index + 1);
                local tempLabel = CCLabelTTF:create(string_helper.game_daily_scene.received,TYPE_FACE_TABLE.Arial_BoldMT,10);
                tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                cell:addChild(tempLabel,20,20);
            end
        end
        local itemCfg = daily_award_cfg:getNodeAt(index);
        if cell and itemCfg then
            tolua.cast(cell:getChildByTag(10),"CCLabelBMFont"):setString(index+1);
            if not game_util:valueInTeam(itemCfg:getKey(),reward) then
                local tempLabel = tolua.cast(cell:getChildByTag(20),"CCLabelTTF");
                if tempLabel then
                    tempLabel:setString(string_helper.game_daily_scene.received)
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (index+1) <= score then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            self:refreshRewardDetail(item);
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新
]]
function game_daily_scene.refreshRewardDetail(self,item)
    self.m_receive_btn:setVisible(false);
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
            self.m_receive_btn:setVisible(true);
        end
        self.m_receive_bg:removeAllChildrenWithCleanup(true);
        self:refreshRewardItem(1,itemCfg:getNodeWithKey("award1_sort"):toInt(),itemCfg:getNodeWithKey("award1_ID"):toStr(),itemCfg:getNodeWithKey("num1"):toInt());
        self:refreshRewardItem(2,itemCfg:getNodeWithKey("award2_sort"):toInt(),itemCfg:getNodeWithKey("award2_ID"):toStr(),itemCfg:getNodeWithKey("num2"):toInt());
    end
end

--[[--

]]
function game_daily_scene.refreshRewardItem(self,index,award_sort,award_id,mun)
        -- "award1_ID" : 0,
        -- "num1" : 100,
        -- "num2" : 3,
        -- "award1_sort" : 1,
        -- "award2_ID" : 0,
        -- "award2_sort" : 2
        -- 1：钻石 2：钻石 3：装备 4：卡牌 5：道具 6：物资 7：能源
    local rewardText = nil;
    if award_sort == 1 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.diamond .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 2 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.diamond .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 3 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.equip .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 4 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.card .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 5 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.prop .. award_id .. " x" .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 6 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.goods .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    elseif award_sort == 7 then
        rewardText = CCLabelTTF:create(string_helper.game_daily_scene.energy .. mun,TYPE_FACE_TABLE.Arial_BoldMT,16);
    end
    if rewardText then
        local bgSize = self.m_receive_bg:getContentSize();
        rewardText:setPosition(ccp(bgSize.width*0.5,bgSize.height*(1 - 0.2*index)));
        self.m_receive_bg:addChild(rewardText);
    end
end

--[[--
    刷新ui
]]
function game_daily_scene.refreshUi(self)
    self.m_daily_layer:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_daily_layer:getContentSize());
    tableViewTemp:setMoveFlag(false);
    tableViewTemp:setScrollBarVisible(false);
    self.m_daily_layer:addChild(tableViewTemp);
    self.m_receive_btn:setVisible(false);
end
--[[--
    初始化
]]
function game_daily_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setDailyAwardDataByJsonData(t_params.gameData:getNodeWithKey("data"));
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_daily_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

--[[--
    创建并添加弹出框
]]
function game_daily_scene.addPop(self,t_params)
    -- body
    t_params = t_params or {};
    if self.m_popUi == nil then
        if t_params.parentNode == nil then
            t_params.parentNode = game_scene:getPopContainer()
            if t_params.parentNode == nil then
                return;
            end
        end
        self:init(t_params);
        self.m_popUi = self:createUi();
        self:refreshUi();
        t_params.parentNode:addChild(self.m_popUi);
    end    
end

return game_daily_scene;