--- 宝箱

local game_treasure_chest_pop = {
    m_popUi = nil,
    m_numCityId = nil,
    m_tableRateLoot = {},
    m_ccbNode = nil,
    m_root_layer = nil,
    m_spr_bar = nil,
    m_curt_regain = nil,
    m_progress_rate_label = nil,
    m_city_name_label = nil,
    m_boxAnimTab = nil,
    m_callBackFunc = nil,
};

local treasure_chest_img = {{"bx_box1_2.png","bx_box2_2.png","bx_box3_2.png"},{"bx_box1_1.png","bx_box2_1.png","bx_box3_1.png"},{"bx_box1_0.png","bx_box2_0.png","bx_box3_0.png"}}
--[[--
    销毁
]]
function game_treasure_chest_pop.destroy(self)
    -- body
    cclog("-----------------game_treasure_chest_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_numCityId = nil;
    -- self.m_tableRateLoot = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_spr_bar = nil;
    self.m_curt_regain = nil;
    self.m_progress_rate_label = nil;
    self.m_city_name_label = nil;
    self.m_boxAnimTab = nil;
    self.m_callBackFunc = nil;
end
--[[--
    返回
]]
function game_treasure_chest_pop.back(self,type)
    -- if self.m_popUi ~= nil then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self:destroy();
    -- end
    game_scene:removePopByName("game_treasure_chest_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_treasure_chest_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 0 then
            local noTreasureChest = false
            for k,v in pairs(self.m_tableRateLoot) do
                if v.gift_type == 0 then
                    noTreasureChest = true;
                    break;
                end
            end
            if self.m_callBackFunc and not noTreasureChest then
                self.m_callBackFunc();
            end
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
    self.m_progress_rate_label = ccbNode:labelBMFontForName("m_progress_rate_label");
    self.m_city_name_label = ccbNode:labelTTFForName("m_city_name_label");
    self.m_ccbNode = ccbNode;
    local m_img = nil;
    local size = nil;
    local animNode = nil;
    local m_btn = nil;
    for i=1,3 do
        m_img = self.m_ccbNode:spriteForName("m_img_" .. i)
        m_img:setOpacity(0)
        animNode = self:createBoxAnim("capture_reward" .. i);
        size = m_img:getContentSize();
        animNode:setPosition(ccp(size.width*0.5,size.height*0.5));
        m_img:addChild(animNode,1,1);
        self.m_boxAnimTab[#self.m_boxAnimTab+1] = animNode
        m_btn = self.m_ccbNode:controlButtonForName("m_btn_" .. i)
        game_util:setControlButtonTitleBMFont(m_btn)
    end
    return ccbNode;
end

function game_treasure_chest_pop.createBoxAnim(self,animFile)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if theLabelName == "loading" then
            animNode:playSection(theLabelName)
        elseif theLabelName == "dakai" then
            animNode:playSection("daiji2")
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("daiji1");
    return mAnimNode;
end

--[[--
    创建宝箱列表
]]
function game_treasure_chest_pop.createTreasureChestTableView(self,viewSize,jsonRateLoot)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = math.min(jsonRateLoot:getNodeCount(),2);
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
            local text = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,12);
            text:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.2));
            text:setColor(ccc3(0,0,0))
            cell:addChild(text,10,10);
            local iconNode = CCNode:create();
            iconNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.62));
            cell:addChild(iconNode,20,20);
        end
        if cell then
            local itemData = jsonRateLoot:getNodeAt(index);
            local text = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            local iconNode = tolua.cast(cell:getChildByTag(20),"CCNode");
            iconNode:removeAllChildrenWithCleanup(true);
            cclog(itemData:getFormatBuffer())
            local icon,name = game_util:getRewardByItem(itemData,true);
            if icon then
                icon:setScale(0.66)
                iconNode:addChild(icon);
            end
            if name then
                text:setString(tostring(name));
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
function game_treasure_chest_pop.receivingGift(self,index)
    --领取宝箱gift=101
    local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
    local map_main_story_cfg = getConfig(game_config_field.map_main_story);
    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(self.m_numCityId)):toStr();
    local function responseMethod(tag,gameData)
        self.m_tableRateLoot[index].gift_type = 1;
        self:refreshUi(gameData);
        self.m_boxAnimTab[index]:playSection("dakai")
        game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gift_receiving_gift"), http_request_method.GET, {gift = cityOrderId*10+index},"gift_receiving_gift")

end
--[[--
    点击宝箱的处理
]]
function game_treasure_chest_pop.createTreasureChest(self,formation_layer)
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
                    cclog("sel game_treasure_chest_pop tag =======================" .. endTag);
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
function game_treasure_chest_pop.createCCControlButton(self,tag)
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
function game_treasure_chest_pop.refreshUi(self,gameData)
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
    self.m_spr_bar:setOpacity(0);
    local bar = ExtProgressTime:createWithFrameName("o_public_recoverBg.png","o_public_recoverBar.png");
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
    cclog("cityOrderId ====================" .. cityOrderId)
    local city_cfg = map_main_story_cfg:getNodeWithKey(cityOrderId);
    self.m_city_name_label:setString(city_cfg:getNodeWithKey("stage_name"):toStr())

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
        rateLootBg = self.m_ccbNode:nodeForName("m_reward_ndoe_" .. i)
        m_img = self.m_ccbNode:spriteForName("m_img_" .. i)
        m_node = self.m_ccbNode:nodeForName("m_node_" .. i)
        m_percent_label = self.m_ccbNode:labelTTFForName("m_percent_label_" .. i)
        m_btn = self.m_ccbNode:controlButtonForName("m_btn_" .. i)
        m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        cclog("rateLoot:getNodeCount() ============ " .. rateLoot:getNodeCount())
        if rateLoot:getNodeCount() > 0 then
            tableView = self:createTreasureChestTableView(rateLootBg:getContentSize(),rateLoot);
            tableView:setTouchEnabled(false);
            tableView:setScrollBarVisible(false);
            tableView:setPosition(ccp(0,0));
            rateLootBg:addChild(tableView);
            m_percent_label:setString(string_helper.game_treasure_chest_pop.shoufudu .. rate .. string_helper.game_treasure_chest_pop.get);
            if rate > self.m_curt_regain then
                m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[1][i]));
                self.m_tableRateLoot[i] = {gift_type = -1}--没开启
                m_btn:setVisible(false);
            else
                m_percent_label:setVisible(false);
                m_btn:setVisible(true);
                if self.m_tableRateLoot[i] == nil then --可领取
                    self.m_tableRateLoot[i] = {gift_type = 0}
                    m_btn:setEnabled(true);
                    game_util:setCCControlButtonTitle(m_btn,string_helper.game_treasure_chest_pop.get2)
                    m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[2][i]));
                    self.m_boxAnimTab[i]:playSection("loading")
                else
                    if self.m_tableRateLoot[i].gift_type == 1 then --已经领取
                        m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[3][i]));
                        m_btn:setEnabled(false);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_treasure_chest_pop.geted)
                        self.m_boxAnimTab[i]:playSection("daiji2")
                    elseif self.m_tableRateLoot[i].gift_type == 0 then --可领取
                        m_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treasure_chest_img[2][i]));
                        m_btn:setEnabled(true);
                        game_util:setCCControlButtonTitle(m_btn,string_helper.game_treasure_chest_pop.get2)
                        self.m_boxAnimTab[i]:playSection("loading")
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
    初始化
]]
function game_treasure_chest_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_fromUi = t_params.fromUi;
    self.m_curt_regain = t_params.curt_regain;
    self.m_numCityId = t_params.cityId;
    self.m_boxAnimTab = {};
    self.m_callBackFunc = t_params.callBackFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function game_treasure_chest_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    if self.m_numCityId == nil then return end
    self.m_popUi = self:createUi();
    self:refreshUi(t_params.gameData);
    return self.m_popUi;
end

return game_treasure_chest_pop;