--- vip特权礼包
local ui_vip_show_gift_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_buy_btn = nil,
    m_pay_btn = nil,
    vip_show_node = nil,
    false_coin_label = nil,
    real_coin_label = nil,
    limit_text = nil,
    reward_node = nil,
    reward_sprite = nil,

    select_index = nil,
    last_select = nil,
    game_data = nil,
    m_endCallBackFunc = nil,

    buy_index = nil,
    look_btn = nil,
    buy_flag_sprite = nil,
    linght_sprite = nil,
    buy_text = nil,
    openType = nil,
    vip_data = nil,
};
--[[--
    销毁ui
]]
function ui_vip_show_gift_pop.destroy(self)
    -- body
    cclog("-----------------ui_vip_show_gift_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_buy_btn = nil;
    self.m_pay_btn = nil;
    self.vip_show_node = nil;
    self.false_coin_label = nil;
    self.real_coin_label = nil;
    self.limit_text = nil;
    self.reward_node = nil;
    self.reward_sprite = nil;

    self.select_index = nil;
    self.last_select = nil;
    self.game_data = nil;
    self.m_endCallBackFunc = nil;

    self.buy_index = nil;
    self.look_btn = nil;
    self.buy_flag_sprite = nil;
    self.linght_sprite = nil;
    self.buy_text = nil;
    self.openType = nil;
    self.vip_data = nil;
end
--[[--
    返回
]]
function ui_vip_show_gift_pop.back(self,backType)
    if self.openType == 1 then
        if self.m_endCallBackFunc then
            self.m_endCallBackFunc(self.buy_index);
        end
        game_scene:removePopByName("ui_vip_show_gift_pop");
        self:destroy();
    elseif self.openType == 2 then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function ui_vip_show_gift_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--购买vip礼包
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);

                cclog("shop_vip_buy -- " .. data:getFormatBuffer())
                self.game_data = json.decode(data:getNodeWithKey("vip_bought"):getFormatBuffer())

                -- self.buy_index = #self.game_data
                self.buy_index = data:getNodeWithKey("vip_bought"):getNodeCount()
                cclog("self.buy_index == " .. self.buy_index)
                self:refreshUi()
                self:refreshGiftContent(self.select_index)
            end

            local buy_table = {}
            local buy_falg = false
            for k,v in pairs(self.game_data) do
                if tostring(self.select_index + 1) == k then
                    buy_falg = true
                    break
                end
            end
            if buy_falg == true then
                game_util:addMoveTips({text = string_helper.ui_vip_show_gift_pop.vipGone});
            else
                local params = {}
                params.shop_id = tostring(self.select_index+1)
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_vip_buy"), http_request_method.GET, params,"shop_vip_buy")
            end
        elseif btnTag == 102 then
            -- self:back()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag > 200 and btnTag < 210 then
            local index = btnTag - 200
            local vipCfg = getConfig(game_config_field.vip_shop);
            local itemCfg = vipCfg:getNodeWithKey(tostring(self.select_index + 1))
            local reward = itemCfg:getNodeWithKey("reward")
            local itemData = reward:getNodeAt(index-1)
            local itemDataType = itemData:getNodeAt(0):toInt()
            if itemDataType == 6 then--道具
                local itemId = itemData:getNodeAt(1):toInt()
                game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
            elseif itemDataType == 7 then--装备
                local equipId = itemData:getNodeAt(1):toInt()
                local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
            elseif itemDataType == 5 then--卡牌
                local cId = itemData:getNodeAt(1):toInt()
                cclog("cId == " .. cId)
                game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
            else
                local icon,name,count = game_util:getRewardByItem(itemData,true);
                game_scene:addPop("game_food_info_pop",{itemData = json.decode(itemData:getFormatBuffer())})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_vip_packs.ccbi");
    local title40 = ccbNode:labelTTFForName("title40");
    title40:setString(string_helper.ccb.title40);
    local title41 = ccbNode:labelTTFForName("title41");
    title41:setString(string_helper.ccb.title41);
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    self.m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")

    self.vip_show_node = ccbNode:nodeForName("vip_show_node")
    self.false_coin_label = ccbNode:labelTTFForName("false_coin_label")
    self.real_coin_label = ccbNode:labelTTFForName("real_coin_label")
    self.limit_text = ccbNode:labelTTFForName("limit_text")
    self.buy_flag_sprite = ccbNode:spriteForName("buy_flag_sprite")
    self.linght_sprite = ccbNode:spriteForName("linght_sprite")
    self.buy_text = ccbNode:spriteForName("buy_text")

    self.look_btn = {}
    for i=1,5 do
        self.look_btn[i] = ccbNode:controlButtonForName("look_btn_" .. i)
        self.look_btn[i]:setOpacity(0)
        self.look_btn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY -1)
    end

    self.reward_node = {}
    self.reward_sprite = {}
    for i=1,5 do
        self.reward_node[i] = ccbNode:nodeForName("reward_node_" .. i)
        self.reward_sprite[i] = ccbNode:nodeForName("reward_sprite_" .. i)
    end

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_pay_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);

    local function animCallFunc(animName)
        ccbNode:runAnimations("enter_anim")
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations("enter_anim")

    self:refreshGiftContent(self.select_index)
    return ccbNode;
end
--[[
    刷新礼包内容
]]
function ui_vip_show_gift_pop.refreshGiftContent(self,vip_index)
    self.limit_text:setString(string.format(string_helper.ui_vip_show_gift_pop.vipTips,vip_index))
    local vipCfg = getConfig(game_config_field.vip_shop);

    local itemCfg = vipCfg:getNodeWithKey(tostring(vip_index + 1))
    if itemCfg then
        local false_coin = itemCfg:getNodeWithKey("false_coin"):toInt()
        local need_coin = itemCfg:getNodeWithKey("need_coin"):toInt()
        local reward = itemCfg:getNodeWithKey("reward")

        self.false_coin_label:setString(false_coin)
        self.real_coin_label:setString(need_coin)

        local rewardCount = reward:getNodeCount()
        for i=1,5 do
            if rewardCount == 4 then
                self.reward_node[i]:setPosition(ccp(8 + (i-1)*75,-20))
            elseif rewardCount == 5 then
                self.reward_node[i]:setPosition(ccp(-3 + (i-1)*63,-20))
            end
            if i <= rewardCount then
                self.reward_node[i]:setVisible(true)
                local itemData = reward:getNodeAt(i-1)
                local icon,name,count = game_util:getRewardByItem(itemData,true);
                if icon then
                    icon:setScale(0.7)
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    local iconSize = self.reward_sprite[i]:getContentSize()
                    icon:setPosition(ccp(iconSize.width*0.5,iconSize.height*0.5))

                    self.reward_sprite[i]:removeAllChildrenWithCleanup(true);
                    self.reward_sprite[i]:addChild(icon)

                    local countLabel = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,7),fontSize = 12});
                    countLabel:setAnchorPoint(ccp(0.5,0.5))
                    countLabel:setPosition(ccp(iconSize.width*0.5,0))
                    self.reward_sprite[i]:addChild(countLabel)
                end
            else
                self.reward_node[i]:setVisible(false)
            end 
        end
    else
        self.false_coin_label:setString("0")
        self.real_coin_label:setString("0")
    end
    local buyFlag = false
    for k,v in pairs(self.game_data) do
        if k == tostring(vip_index+1) then
            buyFlag = true
            break;
        end
    end
    -- cclog("vip_index = " .. vip_index)
    -- cclog("self.game_data == " .. json.encode(self.game_data))
    -- cclog("buyFla == " .. tostring(buyFlag))
    if buyFlag == true then
        self.m_buy_btn:setVisible(false)
        self.buy_flag_sprite:setVisible(true)
        self.linght_sprite:setVisible(false)
        self.buy_text:setVisible(false)
    else
        self.m_buy_btn:setVisible(true)
        self.buy_flag_sprite:setVisible(false)
        self.linght_sprite:setVisible(true)
        self.buy_text:setVisible(true)
    end
end
--[[--
    创建vip
]]
function ui_vip_show_gift_pop.createTableView(self,viewSize)
    self.last_select = nil;
    local buy_table = {0,0,0,0,0,0,0,0,0,0,0}
    for k,v in pairs(self.game_data) do
        -- table.insert(buy_table,k)
        buy_table[tonumber(k)] = 1
        -- buy_table[]
    end
    -- cclog("buy_table == " .. json.encode(buy_table))
    local vipCfg = getConfig(game_config_field.vip_shop);
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = vipCfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/vip_packs_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local select_light = ccbNode:scale9SpriteForName("select_light")
            local packs_node = ccbNode:nodeForName("packs_node")
            local privilege_node = ccbNode:nodeForName("privilege_node")
            local sprite_alpha = ccbNode:spriteForName("sprite_alpha")

            packs_node:setVisible(true)
            privilege_node:setVisible(false)

            sprite_alpha:setVisible(false)
            
            local sprite_done = ccbNode:spriteForName("sprite_done")
            local vip_level_label = ccbNode:labelBMFontForName("vip_level_label") 
            sprite_done:setVisible(false)
            vip_level_label:setString(tostring(index))

            -- for i=1,#buy_table do
            --     if tostring(index + 1) == buy_table[i] then
            --         sprite_done:setVisible(true)
            --         sprite_alpha:setVisible(true)
            --         break;
            --     end
            -- end
            if buy_table[index + 1] == 1 then
                sprite_done:setVisible(true)
                sprite_alpha:setVisible(true)
            end

            if index == self.select_index then
                select_light:setVisible(true)
                self.last_select = select_light
            else
                select_light:setVisible(false)

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local select_light = ccbNode:scale9SpriteForName("select_light")

            if select_light ~= self.last_select then
                select_light:setVisible(true)
                if self.last_select then
                    self.last_select:setVisible(false)
                end
                self.select_index = index
                self.last_select = select_light
                self:refreshGiftContent(self.select_index)
            end
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function ui_vip_show_gift_pop.refreshUi(self)
    self.vip_show_node:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.vip_show_node:getContentSize());
    tableViewTemp:setScrollBarVisible(false)
    self.vip_show_node:addChild(tableViewTemp,10,10);

    local showIndex = self.buy_index-1
    if showIndex < 4 then
        showIndex = 0
    end
    if showIndex > 6 then
        showIndex = 6
    end
    game_util:setTableViewIndex(showIndex,self.vip_show_node,10,5)
end
--[[--
    初始化
]]
function ui_vip_show_gift_pop.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        self.game_data = t_params.gameData
    end
    -- cclog("self.game_data == " .. json.encode(self.game_data))
    -- local count = game_util:getTableLen(self.game_data)
    local count = 0
    for k,v in pairs(self.game_data) do
        -- print(k,v, type(k), type(v))
        count = count + 1
    end
    local vipLv = game_data:getVipLevel();
    -- self.buy_index = game_util:getTableLen(self.game_data)

    for i=1,11 do
        if not self.game_data[tostring(i)] then
            self.buy_index = i - 1
            break
        end 
    end

    -- print("  buy_index === ",self.buy_index)
    self.buy_index = self.buy_index or count
    -- for i=1,count do
    --     self.buy_index = i - 1
    --     local item = self.game_data[tostring(i)]
    --     if item == nil then
    --         break;
    --     end
    -- end
    -- cclog("self.buy_index == " .. self.buy_index)
    self.m_endCallBackFunc = t_params.endCallBackFunc or nil;
    -- self.buy_index = t_params.buy_index
    self.select_index = math.min(self.buy_index,10)
    self.openType = t_params.openType or 1
    self.vip_data = t_params.vip_data or {0,0,0,0,0,0,0,0,0,0,0}
end

--[[--
    创建ui入口并初始化数据
]]
function ui_vip_show_gift_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_vip_show_gift_pop;