---  宝箱

local game_treasure_chest = {
    m_gameTreasureChest = nil,
    m_numCityId = nil,
    m_tableRateLoot = {},
    m_ccbNode = nil,
    m_root_layer = nil,
    m_spr_bar = nil,
    m_spr_bg_1 = nil,
    m_curt_regain = nil,
    m_progress_rate_label = nil,
    m_city_name_label = nil,
};

local treasure_chest_img = {{"bx_box1_2.png","bx_box2_2.png","bx_box3_2.png"},{"bx_box1_1.png","bx_box2_1.png","bx_box3_1.png"},{"bx_box1_0.png","bx_box2_0.png","bx_box3_0.png"}}
--[[--
    销毁
]]
function game_treasure_chest.destroy(self)
    -- body
    cclog("-----------------game_treasure_chest destroy-----------------");
    self.m_gameTreasureChest = nil;
    self.m_numCityId = nil;
    -- self.m_tableRateLoot = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_spr_bar = nil;
    self.m_spr_bg_1 = nil;
    self.m_curt_regain = nil;
    self.m_progress_rate_label = nil;
    self.m_city_name_label = nil;
end
--[[--
    返回
]]
function game_treasure_chest.back(self,type)
    if self.m_gameTreasureChest ~= nil then
        self.m_gameTreasureChest:removeFromParentAndCleanup(true);
        self:destroy();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_treasure_chest.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 0 then
            self:back();
        elseif btnTag == 1 or btnTag == 2 or btnTag == 3 then
            if self.m_tableRateLoot[btnTag] ~= nil and  self.m_tableRateLoot[btnTag].gift_type == 0 then
                cclog("receivingGift ===============" .. btnTag);
                self:receivingGift(btnTag);
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_treasure_chest.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_spr_bar = ccbNode:spriteForName("m_spr_bar")
    self.m_spr_bg_1 = ccbNode:spriteForName("m_spr_bg_1")
    self.m_progress_rate_label = ccbNode:labelTTFForName("m_progress_rate_label");
    self.m_city_name_label = ccbNode:labelTTFForName("m_city_name_label");
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    创建宝箱列表
]]
function game_treasure_chest.createTreasureChestTableView(self,viewSize,jsonRateLoot)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 6; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = jsonRateLoot:getNodeCount();
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), itemSize.width-2, itemSize.height-2)
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand)
            local text = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,16);
            text:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(text,10,10);
        end
        if cell then
            local itemData = jsonRateLoot:getNodeAt(index);
            local text = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            local rewardType = itemData:getNodeAt(0):toInt();
            --收复率1情况下的奖励  1,钻石;2,物资;3,能源;4,道具   最多6个[]
            if rewardType == 1 then
                text:setString(tring_helper.game_treasure_chest.money .. itemData:getNodeAt(1):toStr());
            elseif rewardType == 2 then
                text:setString(tring_helper.game_treasure_chest.minel .. itemData:getNodeAt(1):toStr());
            elseif rewardType == 3 then
                text:setString(tring_helper.game_treasure_chest.erage .. itemData:getNodeAt(1):toStr());
            elseif rewardType == 4 then
                text:setString(tring_helper.game_treasure_chest.prop .. itemData:getNodeAt(1):toStr());
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    领取宝箱
]]
function game_treasure_chest.receivingGift(self,index)
    --领取宝箱gift=101
    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(self.m_numCityId)):toStr();
    local function responseMethod(tag,gameData)
        self.m_tableRateLoot[index].gift_type = 1;
        self:refreshUi(gameData);
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gift_receiving_gift"), http_request_method.GET, {gift = cityOrderId*10+index},"gift_receiving_gift")

end
--[[--
    点击宝箱的处理
]]
function game_treasure_chest.createTreasureChest(self,formation_layer)
    local touchBeginPoint = nil;
    local touchMoveFlag = false;
    local tempItem = nil;
    local realPos = nil;
    local tag = nil;
    local function onTouchBegan(x, y)
        touchMoveFlag = false;
        --cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        return true
    end
    
    local function onTouchMoved(x, y)

    end
    
    local function onTouchEnded(x, y)
        realPos = formation_layer:convertToNodeSpace(ccp(x,y));
        for endTag = 1,3 do
            tempItem = tolua.cast(formation_layer:getChildByTag(endTag),"CCSprite");
            if tempItem and tempItem:boundingBox():containsPoint(realPos) then
                -- cclog("self.m_tableRateLoot[endTag].gift_type ==" .. self.m_tableRateLoot[endTag].gift_type);
                if self.m_tableRateLoot[endTag] ~= nil and  self.m_tableRateLoot[endTag].gift_type == 0 then
                    self:receivingGift(endTag);
                    cclog("sel game_treasure_chest tag =======================" .. endTag);
                end
                break;
            end
        end
    end
    
    local function onTouch(eventType, x, y)
        if self.m_tableView ~= nil then return end
        if eventType == "began" then
            return onTouchBegan(x, y)
            elseif eventType == "moved" then
            return onTouchMoved(x, y)
            else
            return onTouchEnded(x, y)
        end
    end
    -- formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-2)
    -- formation_layer:setTouchEnabled(true)
end
--[[--
    创建领取按钮
]]
function game_treasure_chest.createCCControlButton(self,tag)
    local function callBack(event,target)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_tableRateLoot[btnTag] ~= nil and  self.m_tableRateLoot[btnTag].gift_type == 0 then
            cclog("createCCControlButton ===============" .. btnTag);
            self:receivingGift(btnTag);
        end
    end
    local btn = game_util:createCCControlButton("bx_lingqu.png","",callBack);
    btn:setPosition(0,0);
    btn:setTag(tag);
    return btn;
end

--[[--
    刷新ui
]]
function game_treasure_chest.refreshUi(self,gameData)
    -- self.m_tableRateLoot = {};
    local data = gameData:getNodeWithKey("data");
    local curt_gift = data:getNodeWithKey("curt_gift");
    local old_gift = data:getNodeWithKey("old_gift");
    local count = 0;
    local itmeData = nil;
    local giftId = nil;
    if curt_gift ~= nil then
        count = curt_gift:getNodeCount();
        for i=1,count do
            itmeData = curt_gift:getNodeAt(i-1);
            giftId = itmeData:toInt();
            self.m_tableRateLoot[giftId%10] = {gift_type = 0};--可以领取
        end
    end
    if old_gift ~= nil then
        count = old_gift:getNodeCount();
        for i=1,count do
            itmeData = old_gift:getNodeAt(i-1);
            giftId = itmeData:toInt();
            self.m_tableRateLoot[giftId%10] = {gift_type = 1};--已经领取
        end
    end
    for k,v in pairs(self.m_tableRateLoot) do
        cclog("k ==============" .. tostring(k) .. " ; v =========" .. tostring(v.gift_type));
    end

    local bar_size = self.m_spr_bar:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("bx_degreeBg.png","bx_degree.png");
    if self.m_curt_regain ~= nil then
        bar:setCurValue(self.m_curt_regain,false);
        self.m_progress_rate_label:setString(self.m_curt_regain .. "%");
    else
        bar:setCurValue(0,false);
    end
    self.m_spr_bar:addChild(bar);

    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(self.m_numCityId)):toStr();
    local city_cfg = map_main_story_cfg:getNodeWithKey(cityOrderId);
    self.m_city_name_label:setString(city_cfg:getNodeWithKey("stage_name"):toStr())

    local spr_bg_size = self.m_spr_bg_1:getContentSize();
    local rateLoot = nil;
    local rate = nil;
    local rateLootBg = nil;
    local tableView = nil;
    local m_node = nil;
    local m_btn = nil;
    local m_percent_label = nil;
    local m_img = nil;
    for i=1,3 do
        rateLoot = city_cfg:getNodeWithKey("rate_loot" .. i);
        rate = city_cfg:getNodeWithKey("rate" .. i):toInt()*0.1;
        rateLootBg = self.m_ccbNode:spriteForName("m_spr_bg_" .. i)
        m_img = self.m_ccbNode:spriteForName("m_img_" .. i)
        m_node = self.m_ccbNode:nodeForName("m_node_" .. i)
        m_percent_label = self.m_ccbNode:labelTTFForName("m_percent_label_" .. i)
        m_btn = self.m_ccbNode:controlButtonForName("m_btn_" .. i)
        m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        if rateLoot:getNodeCount() > 0 then
            tableView = self:createTreasureChestTableView(CCSizeMake(spr_bg_size.width*0.8,spr_bg_size.height),rateLoot);
            tableView:setTouchEnabled(false);
            tableView:setScrollBarVisible(false);
            tableView:setPosition(ccp(0,0));
            rateLootBg:addChild(tableView);
            m_percent_label:setString(rate .. "%");
            rateLootBg:setColor(ccc3(222,152,40))
            if rate > self.m_curt_regain then
                m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[1][i]));
                self.m_tableRateLoot[i] = {gift_type = -1}--没开启
                m_btn:setVisible(false);
                rateLootBg:setColor(ccc3(255,255,255))
            else
                if self.m_tableRateLoot[i] == nil then --可领取
                    self.m_tableRateLoot[i] = {gift_type = 0}
                    m_btn:setVisible(true);
                    m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[2][i]));
                else
                    if self.m_tableRateLoot[i].gift_type == 1 then --已经领取
                        m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[3][i]));
                        m_btn:setVisible(false);
                        m_percent_label:setString(string_helper.game_treasure_chest.sd_out);
                    elseif self.m_tableRateLoot[i].gift_type == 0 then --可领取
                        m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[2][i]));
                        m_btn:setVisible(true);
                    end
                end
            end
        else
            m_node:setVisible(false);
        end
    end
    cclog("self.m_tableRateLoot count ==== " .. #self.m_tableRateLoot);

    local m_close_btn = tolua.cast(self.m_ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- cclog("m_root_layer-------------------------");
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
end
--[[--
    创举并添加宝箱ui
]]
function game_treasure_chest.addTreasureChest(self,t_params)
    -- body
    self.m_curt_regain = t_params.curt_regain;
    self.m_numCityId = t_params.cityId;
    if self.m_numCityId == nil then return end
    if t_params.parentNode == nil then
        t_params.parentNode = game_scene:getPopContainer()
    end
    self.m_gameTreasureChest = game_treasure_chest:createUi();
    t_params.parentNode:addChild(self.m_gameTreasureChest,10,10);
    self:refreshUi(t_params.gameData);
end

return game_treasure_chest;