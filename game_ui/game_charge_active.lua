---  充值活动
local game_charge_active = {
    selectIndex = nil,
    ver_table_node = nil,
    hor_table_node = nil,
    time_node = nil,
    title_sprite = nil,

    m_tGameData = nil,
    selectIndex = nil,
    showCfg = nil,
    indexTable = nil,
    m_tableView = nil,
    showIndex = nil,
    m_showExchangeIdTab = nil,
    typeid = nil,
    myIndex = nil,
    exchangeData = nil,
    m_tableView = nil,
    m_tableView2 = nil,
    m_tableView3 = nil,
};
--[[--
    销毁ui
]]
function game_charge_active.destroy(self)
    -- body
    cclog("----------------- game_charge_active destroy-----------------"); 
    self.ver_table_node = nil;
    self.hor_table_node = nil;
    self.time_node = nil;
    self.title_sprite = nil;

    self.m_tGameData = nil;
    self.selectIndex = nil;
    self.showCfg = nil;
    self.indexTable = nil;
    self.m_tableView = nil;
    self.showIndex = nil;
    self.m_showExchangeIdTab = nil;
    self.typeid = nil;
    self.myIndex = nil;
    self.exchangeData = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
end
--[[--
    返回
]]
function game_charge_active.back(self)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    -- self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_charge_active.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_active_recharge.ccbi");

    self.ver_table_node = ccbNode:nodeForName("ver_table_node")
    self.hor_table_node = ccbNode:nodeForName("hor_table_node")
    self.time_node = ccbNode:nodeForName("time_node")
    self.title_sprite = ccbNode:spriteForName("title_sprite")
    local btn_recharge = ccbNode:controlButtonForName("btn_recharge")
    local m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.ver_table_node:getParent():convertToNodeSpace(ccp(x,y));
            if self.ver_table_node:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    横的table
]]
function game_charge_active.createLandTable(self,viewSize)
    local tabCount = game_util:getTableLen(self.showCfg)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.showPoint = false
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 1
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_active_recharge_item2.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            
            local m_sprite_titleType = ccbNode:spriteForName("m_sprite_titleType")
            local banner_sprite = ccbNode:spriteForName("banner_sprite")
            local light_add = ccbNode:scale9SpriteForName("light_add")

            local itemData = self.showCfg[index+1]
            local banner = itemData.banner
            
            local mark = itemData.mark

            banner_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(banner .. ".png"))
            m_sprite_titleType:setVisible(true)
            if mark == 1 then--new图标
                m_sprite_titleType:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_announce_h2.png"))
            elseif mark == 2 then--hot
                m_sprite_titleType:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_announce_h1.png"))
            else
                m_sprite_titleType:setVisible(false)
            end
            if self.selectIndex == index + 1 then
                light_add:setVisible(true)
            else
                light_add:setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            
            if self.selectIndex ~= index + 1 then
                self.selectIndex = index + 1
                -- self:refreshTable2()
                -- self:refreshLabel()
                self:refreshUi()
            end
        end
    end
    local tempTable = TableViewHelper:createGallery3(params);
    return tempTable
end
--[[
    竖的table
]]
function game_charge_active.createPorTable(self,viewSize)
    --取服务器数据
    local serverData = self.m_tGameData.show
    local itemShowData = serverData[tostring(self.myIndex)]
    local context = itemShowData.context
    local rechargeCfg = getConfig(game_config_field.active_recharge);
    -- self.rechargeCfg = json.decode(getConfig(game_config_field.active_recharge):getFormatBuffer())
    local rechargeData = {}
    -- for i=1,rechargeCfg:getNodeCount() do
    --     local itemCfg = rechargeCfg:getNodeWithKey(tostring(i))
    --     local charge_type = itemCfg:getNodeWithKey("charge_type"):toInt()
    --     if self.selectIndex == charge_type then
    --         local itemData = json.decode(itemCfg:getFormatBuffer())
    --         itemData.id = i
    --         table.insert(rechargeData,itemData)
    --     end
    -- end
    --改为不取配置，取服务器数据
    for k,v in pairs(context) do
        local itemFlag = v.flag
        if itemFlag ~= -1 then
            local itemCfg = rechargeCfg:getNodeWithKey(tostring(k))
            local itemData = json.decode(itemCfg:getFormatBuffer())
            itemData.id = k
            table.insert(rechargeData,itemData)
        end
    end
    -- for i=1,game_util:getTableLen(context) do
    --     local itemFlag = context[tostring(i)].flag
    --     if itemFlag == 1 then
    --         local itemCfg = rechargeCfg:getNodeWithKey(tostring(i))
    --         local itemData = json.decode(itemCfg:getFormatBuffer())
    --         itemData.id = i
    --         table.insert(rechargeData,itemData)
    --     end
    -- end
        
    local function sortFunc(itemData1,itemData2)
        local show_id1 = itemData1.show_id
        local show_id2 = itemData2.show_id
        return show_id1 < show_id2
    end
    table.sort( rechargeData, sortFunc )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local charge_type = math.floor(btnTag / 100)
        local index = btnTag % 100

        local params = {}
        params.active_id = rechargeData[index+1].id
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_recharge_receive"), http_request_method.GET, params,"active_recharge_receive")
    end

    local tabCount = game_util:getTableLen(rechargeData)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local index = math.floor(btnTag / 100)
        local reward = rechargeData[index+1].reward
        local id = btnTag % 100
        local itemData = reward[id]
        game_util:lookItemDetal(itemData)
    end

    local nodeSizeW = 320
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_active_recharte_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            
            local tip_word_label = ccbNode:labelTTFForName("tip_word_label")
            local btn_go = ccbNode:controlButtonForName("btn_go")

            local reward_layer = ccbNode:layerForName("reward_layer")
            local tip_time_label = ccbNode:labelTTFForName("tip_time_label")
            -- self:initLayerTouch(reward_layer);

            local rewardNode = {}
            local addSprite = {}
            local reward = rechargeData[index+1].reward
            local show_time = rechargeData[index+1].show_time
            
            local rewardCount = game_util:getTableLen(reward)
            for i=1,5 do
                rewardNode[i] = ccbNode:nodeForName("reward_node_" .. i)
                addSprite[i] = ccbNode:spriteForName("sprite_" .. i)

                rewardNode[i]:removeAllChildrenWithCleanup(true)
                rewardNode[i]:setVisible(true)
                addSprite[i]:setVisible(true)
                local dw = nodeSizeW / rewardCount
                local dx = dw / 2
                if i <= rewardCount then
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)

                        rewardNode[i]:addChild(reward_icon)

                        rewardNode[i]:setPosition(ccp(dx + (i-1)*dw,33))
                        addSprite[i]:setPosition(ccp(dx * 2 + (i-1)*dw ,33))

                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.7)
                        button:setTag(index * 100 + i)
                        button:setOpacity(0)
                        rewardNode[i]:addChild(button)

                        if name then
                            local nameLabel = game_util:createLabelTTF({text = name})
                            nameLabel:setColor(ccc3(250,180,0))
                            nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                            nameLabel:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(nameLabel, 11)
                        end
                    end
                    
                else
                    rewardNode[i]:setVisible(false)
                    addSprite[i]:setVisible(false)
                end
            end
            addSprite[rewardCount]:setVisible(false)

            local id = rechargeData[index+1].id
            local flag = context[tostring(id)].flag
            -- btn_go:setVisible(false)
            local test1 = btn_go:getChildByTag(10)
            local test2 = btn_go:getChildByTag(11)
            if test1 and test2 then
                test1:removeFromParentAndCleanup(true)
                test2:removeFromParentAndCleanup(true)
            end
            if flag == 0 then--可领取
                -- btn_go:setVisible(true)
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_get.png")
                if test1 == nil and test2 == nil then
                    game_util:createPulseAnmi("recharge_get.png",btn_go)
                end
            elseif flag == 1 then--不可领取
                btn_go:setEnabled(false)
                game_util:setCCControlButtonBackground(btn_go,"recharge_loss.png")
            --     local animArr = CCArray:create();
            --     animArr:addObject(CCMoveTo:create(0.4,ccp(331,4)));
            --     animArr:addObject(CCMoveTo:create(0.3,ccp(317,4)));
            --     animArr:addObject(CCMoveTo:create(0.15,ccp(331,4)));
            --     animArr:addObject(CCMoveTo:create(0.15,ccp(321,4)));
            --     animArr:addObject(CCDelayTime:create(0.8));
            --     btn_go:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
            else
                -- btn_go:setVisible(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_already.png")
                btn_go:setEnabled(false)
            end
            --加服务器数据
            local repeatValue = rechargeData[index+1]["repeat"]
            local charge_type = rechargeData[index+1]["charge_type"]
            local des = rechargeData[index+1].des
            -- if repeatValue == 1 or charge_type == 2 then--重复为1 或者 charge_type为2的需要显示
            if charge_type == 2 then--改为只有charge_type为2的需要显示
                local now_value = context[tostring(id)].now_value or "0"
                local num = rechargeData[index+1].num
                des = des .. "(" .. now_value .. "/" .. num .. ")"
            end
            tip_word_label:setString(des)
            tip_time_label:setString(show_time)
            --设置button索引   self.selectIndex * 100 + index
            btn_go:setTag(self.myIndex * 100 + index)
            --设置触摸
            
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
    竖的table2
]]
function game_charge_active.createPorTable2(self,viewSize)
    --取服务器数据
    local serverData = self.m_tGameData.show
    local itemShowData = serverData[tostring(self.myIndex)]
    local context = itemShowData.context
    local rechargeCfg = getConfig(game_config_field.active_consume);
    local rechargeData = {}
    --改为不取配置，取服务器数据
    for k,v in pairs(context) do
        local itemFlag = v.flag
        if itemFlag ~= -1 then
            local itemCfg = rechargeCfg:getNodeWithKey(tostring(k))
            local itemData = json.decode(itemCfg:getFormatBuffer())
            itemData.id = k
            table.insert(rechargeData,itemData)
        end
    end
        
    local function sortFunc(itemData1,itemData2)
        local show_id1 = itemData1.show_id
        local show_id2 = itemData2.show_id
        return show_id1 < show_id2
    end
    table.sort( rechargeData, sortFunc )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local charge_type = math.floor(btnTag / 100)
        local index = btnTag % 100

        local params = {}
        params.active_id = rechargeData[index+1].id
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            local reward = data:getNodeWithKey("reward")
            game_util:rewardTipsByJsonData(reward);
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
            self:refreshUi()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_consume_receive"), http_request_method.GET, params,"active_consume_receive")
    end

    local tabCount = game_util:getTableLen(rechargeData)

    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        local index = math.floor(btnTag / 100)
        local reward = rechargeData[index+1].reward
        local id = btnTag % 100
        local itemData = reward[id]
        game_util:lookItemDetal(itemData)
    end

    local nodeSizeW = 320
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_active_recharte_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local tip_word_label = ccbNode:labelTTFForName("tip_word_label")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            local reward_layer = ccbNode:layerForName("reward_layer")
            local tip_time_label = ccbNode:labelTTFForName("tip_time_label")
            local rewardNode = {}
            local addSprite = {}
            local reward = rechargeData[index+1].reward
            local show_time = rechargeData[index + 1].show_time
            
            local rewardCount = game_util:getTableLen(reward)
            for i=1,5 do
                rewardNode[i] = ccbNode:nodeForName("reward_node_" .. i)
                addSprite[i] = ccbNode:spriteForName("sprite_" .. i)
                rewardNode[i]:removeAllChildrenWithCleanup(true)
                rewardNode[i]:setVisible(true)
                addSprite[i]:setVisible(true)
                local dw = nodeSizeW / rewardCount
                local dx = dw / 2
                if i <= rewardCount then
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)

                        rewardNode[i]:addChild(reward_icon)

                        rewardNode[i]:setPosition(ccp(dx + (i-1)*dw,33))
                        addSprite[i]:setPosition(ccp(dx * 2 + (i-1)*dw ,33))
                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setScale(0.7)
                        button:setTag(index * 100 + i)
                        button:setOpacity(0)
                        rewardNode[i]:addChild(button)
                        if name then
                            local nameLabel = game_util:createLabelTTF({text = name})
                            nameLabel:setColor(ccc3(250,180,0))
                            nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                            nameLabel:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(nameLabel, 11)
                        end
                    end
                    
                else
                    rewardNode[i]:setVisible(false)
                    addSprite[i]:setVisible(false)
                end
            end
            addSprite[rewardCount]:setVisible(false)

            local id = rechargeData[index+1].id
            local flag = context[tostring(id)].flag
            -- btn_go:setVisible(false)
            local test1 = btn_go:getChildByTag(10)
            local test2 = btn_go:getChildByTag(11)
            if test1 and test2 then
                test1:removeFromParentAndCleanup(true)
                test2:removeFromParentAndCleanup(true)
            end
            if flag == 0 then--可领取
                -- btn_go:setVisible(true)
                btn_go:setEnabled(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_get.png")
                if test1 == nil and test2 == nil then
                    game_util:createPulseAnmi("recharge_get.png",btn_go)
                end
            elseif flag == 1 then--不可领取
                btn_go:setEnabled(false)
                game_util:setCCControlButtonBackground(btn_go,"recharge_loss.png")
            else
                -- btn_go:setVisible(true)
                game_util:setCCControlButtonBackground(btn_go,"recharge_already.png")
                btn_go:setEnabled(false)
            end
            --加服务器数据
            local repeatValue = rechargeData[index+1]["repeat"]
            -- local charge_type = rechargeData[index+1]["charge_type"]
            local des = rechargeData[index+1].des
            -- if repeatValue == 1 or charge_type == 2 then--重复为1 或者 charge_type为2的需要显示
            -- if charge_type == 2 then--改为只有charge_type为2的需要显示
                local now_value = context[tostring(id)].now_value or "0"
                local num = rechargeData[index+1].num
                des = des .. "(" .. now_value .. "/" .. num .. ")"
            -- end
            tip_word_label:setString(des)
            tip_time_label:setString(show_time)
            --设置button索引   self.selectIndex * 100 + index
            btn_go:setTag(self.myIndex * 100 + index)
            --设置触摸
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
    兑换table
]]
function game_charge_active.createTableView(self,viewSize)
    self.m_showExchangeIdTab = {};
    local lastcount = self.exchangeData.exchange_log;
    local server_time = game_data:getUserStatusDataByKey("server_time")
    local timedatetext = "14.07-14.20" ;
    local exchangcount = 1 ;
    local exchangestate = 1 ;
    --判断是兑换活动还是万物兑换 1表示兑换活动 0 表示万物兑换
    local omni_exchange_cfg  = getConfig(game_config_field.omni_exchange); 
    if omni_exchange_cfg  then
        local tempCount = omni_exchange_cfg:getNodeCount();
        for i=1,tempCount do
            local itemCfg = omni_exchange_cfg:getNodeAt(i - 1)
            local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
            local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
            end_time = end_time == "" and "0" or end_time
            local exchange_time =  itemCfg:getNodeWithKey("exchange_time"):toInt();
            exchangestate = itemCfg:getNodeWithKey("exchange_type"):toInt();
            exchangcount = itemCfg:getNodeWithKey("exchange_num"):toInt();
            if self.typeid == itemCfg:getNodeWithKey("type"):toInt() then
                if exchangestate == 0 then
                    if exchange_time == 0 then
                        table.insert(self.m_showExchangeIdTab,itemCfg:getKey())
                    else
                        if tonumber(end_time) > server_time and  tonumber(start_time) < server_time then
                            table.insert(self.m_showExchangeIdTab,itemCfg:getKey());
                        end
                    end
                else
                    if exchangcount > 0 then
                        local show_idcount = itemCfg:getNodeWithKey("show_id"):toStr();
                        local owncountnum = lastcount[show_idcount] or 0;
                        local tempOwnCount = exchangcount  - owncountnum ;
                        if tempOwnCount > 0 then
                            if exchange_time == 0 then
                                table.insert(self.m_showExchangeIdTab,itemCfg:getKey())
                            else
                                if tonumber(end_time) > server_time  and  tonumber(start_time) < server_time then
                                    table.insert(self.m_showExchangeIdTab,itemCfg:getKey());
                                end
                            end
                        end
                    end
                end
            end
        end

        local function onCellBtnClick( target,event )
            local tagNode = tolua.cast(target, "CCControlButton");
            local btnTag =  tagNode:getTag();
            local index = btnTag ; --math.floor(btnTag / 1000);
            local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
            local sendmesage = {};
            sendmesage.id = index + 1 ;
            self.showIndex = index
            local card = {} ;
            local equip = {} ;
            if itemCfg then
                local need_item = itemCfg:getNodeWithKey("need_item")
                local need_item_count = need_item:getNodeCount();
                local stepleve1 = itemCfg:getNodeWithKey("step"):toInt();
                local breakleve1 = itemCfg:getNodeWithKey("break"):toInt();
                local material_type = itemCfg:getNodeWithKey("material_type"):toInt();
                for i=1,need_item_count do
                    local itemCfgData = json.decode(need_item:getNodeAt(i-1):getFormatBuffer())
                    if itemCfgData[1] == 7 then
                        stepleve1 = itemCfg:getNodeWithKey("strengthen"):toInt();
                        breakleve1 = itemCfg:getNodeWithKey("equip_st"):toInt();
                    end
                    local senddatalist,ownCount = game_data:getMetalByTable(itemCfgData,stepleve1,breakleve1,material_type);
                    local icon,name,count,rewardType = game_util:getRewardByItemTable(itemCfgData);
                    local typeValue = itemCfgData[1];
                    if typeValue == 5 then
                        if count > 0 then
                            for i=1,count do
                                table.insert(card,senddatalist[i])
                            end
                        end
                    elseif typeValue == 7 then
                        if count > 0 then
                            for i=1,count do
                                table.insert(equip,senddatalist[i])
                            end
                        end
                    end
                    
                end 
                --判断是否是高级装备或者伙伴
                sendmesage.card = card ;
                sendmesage.equip = equip ;
                senddata = json.encode(sendmesage);
                local params = "";
                table.foreach(card,function(k,v)
                    params = params .. "card=" .. v .. "&";
                end)
                table.foreach(equip,function(k,v)
                    params = params .. "equip=" .. v .. "&";
                end)
                -------添加提示
                local cardTipsFlag = false
                local equipTipsFlag = false
                for k,v in pairs(card) do
                    local cardId = v
                    local cardData,heroCfg = game_data:getCardDataById(cardId)
                    local cardLevel = cardData.lv
                    local evo = cardData.evo
                    if cardLevel > 10 or evo > 0 then--提示高级卡牌
                        cardTipsFlag = true
                    end
                    -- local x = 1
                end
                for k,v in pairs(equip) do
                    local equipId = v
                    local equipData,equipCfg = game_data:getEquipDataById(equipId)
                    local equipLv = equipData.lv
                    local st_lv = equipData.st_lv
                    if equipLv > 10 or st_lv > 5 then--提示高级装备
                        equipTipsFlag = true
                    end
                end
                --兑换的接口
                local function exchageItem()
                    local id = itemCfg:getNodeWithKey("show_id"):toInt(); 
                    params = params .. "id=" .. id ;
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data");
                        self.exchangeData = json.decode(data:getFormatBuffer());
                        game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("omni_exchange"), http_request_method.GET, params,"omni_exchange")
                end
                if cardTipsFlag == true then
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            exchageItem()
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string_helper.game_charge_active.text,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                elseif equipTipsFlag == true then
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            exchageItem()
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string_helper.game_charge_active.text2,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                else
                    exchageItem()
                end
            end
        end

        local function onBtnCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local index = math.floor(btnTag / 1000)
            local indexRew = math.floor(btnTag % 1000)
            local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
            if itemCfg then
                local need_item = itemCfg:getNodeWithKey("need_item")
                local need_item_count = need_item:getNodeCount();
                local senddata = nil ;
                local stepleve1 = itemCfg:getNodeWithKey("step"):toInt();
                local breakleve1 = itemCfg:getNodeWithKey("break"):toInt();
                local material_type = itemCfg:getNodeWithKey("material_type"):toInt();
                if indexRew > need_item_count then
                    local numid = indexRew - need_item_count;
                    senddata = json.decode(itemCfg:getNodeWithKey("out_item" .. numid):getFormatBuffer());
                    -- game_scene:addPop("game_exchange_showitemsneed_pop",{gameData = senddata,type_id = 1,stepleve = stepleve1 ,breakleve = breakleve1});
                    game_util:lookItemDetal(senddata[1])
                else
                    senddata = json.decode(need_item:getNodeAt(indexRew-1):getFormatBuffer());
                    if senddata[1] == 7 then
                        stepleve1 = itemCfg:getNodeWithKey("strengthen"):toInt();
                        breakleve1 = itemCfg:getNodeWithKey("equip_st"):toInt();
                    end
                    game_scene:addPop("game_exchange_showitemsneed_pop",{gameData = senddata,type_id = 0,stepleve = stepleve1 ,breakleve = breakleve1,material_type = material_type});
                end
            end
        end
        local function onBtnrandomCilck( event,target )
            local tagNode = tolua.cast(target, "CCNode");
            local btnTag = tagNode:getTag();
            local index = math.floor(btnTag / 1000)
            local indexRew = math.floor(btnTag % 1000)
            local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
            if itemCfg then
                local need_item = itemCfg:getNodeWithKey("need_item");
                local numid = indexRew ;
                local senddata = json.decode(itemCfg:getNodeWithKey("out_item" .. numid):getFormatBuffer());
                game_scene:addPop("game_exchange_showitems_pop",senddata);
            end
        end

        local allcount = #self.m_showExchangeIdTab
        if allcount < 1 then
            -- self.lbtitlename:setVisible(true) ;
        end
        local params = {};
        params.viewSize = viewSize;
        params.row = 3 ;
        params.column = 1 ;
        params.totalItem = allcount;
        -- params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
        -- params.showPageIndex = self.m_curPage;
        -- params.itemActionFlag = false;
        params.direction = kCCScrollViewDirectionVertical;
        local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
        params.newCell =function( tableView,index )
            local cell = tableView:dequeueCell();
            if cell == nil then
                cell = CCTableViewCell:new();
                cell:autorelease();
                local ccbNode = luaCCBNode:create();
                ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
                ccbNode:openCCBFile("ccb/game_ui_exchange_item2.ccbi");
                self.m_points_layer = ccbNode:layerForName("m_points_layer"); 
                self.m_ccnode = ccbNode:nodeForName("m_ccnode"); 
                -- self:initLayerTouch(self.m_points_layer);
                ccbNode:setAnchorPoint(ccp(0.5,0.5));
                ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                cell:addChild(ccbNode,20,20)
            end
            if cell then
                local ccbNode = tolua.cast(cell:getChildByTag(20),"luaCCBNode");
                local stime = ccbNode:spriteForName("stime");
                local scount = ccbNode:spriteForName("scount");
                local sarrow = ccbNode:spriteForName("sarrow");
                local tbndh = ccbNode:controlButtonForName("btnexchange");
                tbndh:setTag(index);
                local lbtime = ccbNode:labelTTFForName("lbtime");
                local lbcount = ccbNode:labelTTFForName("lbcount");
                local m_ccnodeitem = ccbNode:nodeForName("m_ccnode"); 
                local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index+1]);
                local cellnumcount = 0 ;
                --取出需要的物品
                exchangestate = itemCfg:getNodeWithKey("exchange_type"):toInt();
                exchangcount = itemCfg:getNodeWithKey("exchange_num"):toInt();
                exchange_time =  itemCfg:getNodeWithKey("exchange_time"):toInt();
                local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
                local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
                end_time = end_time == "" and "0" or end_time
                local show_idcount = itemCfg:getNodeWithKey("show_id"):toStr();

                local server_left_time = 1
                if exchangestate == 0 then
                    scount:setVisible(false);
                    lbcount:setVisible(false);
                else
                    scount:setVisible(true);
                    lbcount:setVisible(true);
                    local owncountnum = lastcount[show_idcount] or 0;
                    exchangcount = exchangcount  - owncountnum ;
                    lbcount:setString(exchangcount);
                end
                if exchange_time == 0 then
                    lbtime:setVisible(false);
                    stime:setVisible(false);
                else
                    lbtime:setVisible(true);
                    stime:setVisible(true);
                    local dateTemp = os.date("*t", start_time)
                    local hour = dateTemp.hour
                    if hour < 10 then
                        hour = "0" .. hour
                    end
                    local min = dateTemp.min
                    if min < 10 then
                        min = "0" .. min
                    end
                    timedatetext = dateTemp.month .. "-" .. dateTemp.day .. " " .. hour .. ":" .. min ;
                    -- cclog(dateTemp.year, dateTemp.month, dateTemp.day, dateTemp.hour, dateTemp.min, dateTemp.sec);
                    local endDateTemp = os.date("*t", end_time)
                    local endHour = endDateTemp.hour
                    if endHour < 10 then
                        endHour = "0" .. endHour
                    end
                    local endMin = endDateTemp.min
                    if endMin < 10 then
                        endMin = "0" .. endMin
                    end
                    timedatetext =  timedatetext .. " ~ " .. endDateTemp.month .. "-" .. endDateTemp.day .. " " .. endHour .. ":" .. endMin ;
                    lbtime:setString(timedatetext);
                end
                m_ccnodeitem:removeAllChildrenWithCleanup(true);
                local need_item = itemCfg:getNodeWithKey("need_item")
                local need_item_count = need_item:getNodeCount();
                local countNum = 1 ;
                cellnumcount = cellnumcount + need_item_count ;
                for i = cellnumcount + 1, 5 do
                    local out_item = itemCfg:getNodeWithKey("out_item" .. countNum);
                    if out_item and out_item:getNodeCount() > 0 then
                        cellnumcount = i
                        countNum = countNum + 1 ;
                    end
                end

                local cellwidth = m_ccnodeitem:getContentSize();
                local jianju = cellwidth.width/(cellnumcount + 1);
                -- cclog("jianju == " .. tostring(jianju))
                local exwidth = jianju/2;
                local isall = 1 ;
                local material_type = itemCfg:getNodeWithKey("material_type"):toInt();
                for i=1,need_item_count do
                    local itemCfgData = json.decode(need_item:getNodeAt(i-1):getFormatBuffer())
                    local stepleve = 0 ;
                    local breakleve = 0 ;
                    local ownCount = 0 ;
                    local icon,name,count,rewardType = game_util:getRewardByItemTable(itemCfgData,true);
                    if itemCfgData[1] == 5 then
                        stepleve = itemCfg:getNodeWithKey("step"):toInt();
                        breakleve = itemCfg:getNodeWithKey("break"):toInt();
                        local _,ownCount1 = game_data:getMetalByTable(itemCfgData,stepleve,breakleve,material_type);
                        ownCount = ownCount1 ;
                        count = stepleve ;
                    elseif  itemCfgData[1] ==  7 then
                        stepleve = itemCfg:getNodeWithKey("strengthen"):toInt();
                        breakleve = itemCfg:getNodeWithKey("equip_st"):toInt();
                        local _,ownCount1 = game_data:getMetalByTable(itemCfgData,stepleve,breakleve,material_type);
                        ownCount = ownCount1 ;
                        count = stepleve ;
                    else
                        local _,ownCount1 = game_data:getMetalByTable(itemCfgData);
                        ownCount = ownCount1 ;
                    end
                    if icon then
                        if i ~= 1 then
                            local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_fuhao.png");
                            bgSpr:setPosition(ccp(exwidth + jianju*(i - 1) - jianju/2, 35))
                            m_ccnodeitem:addChild(bgSpr)
                        end
                        icon:setScale(0.70);
                        icon:setPosition(ccp(exwidth + jianju*(i - 1), 35))
                        m_ccnodeitem:addChild(icon)
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(icon:getPosition())
                        button:setOpacity(0)
                        m_ccnodeitem:addChild(button)
                        -- button:setScaleY(1.5)
                        button:setTag(1000 * index + i)
                        if ownCount < itemCfgData[3] then
                            icon:setColor(ccc3(71,71,71))
                            local bgSpri = tolua.cast(icon:getChildByTag(1),"CCSprite")
                            local bgSpri2 = tolua.cast(icon:getChildByTag(2),"CCSprite")
                            if bgSpri and bgSpri2 then
                                bgSpri:setColor(ccc3(71,71,71));
                                bgSpri2:setColor(ccc3(71,71,71));
                            end
                        end
                    else
                        cclog("----icon======" .. tostring(icon))
                    end
                    if ownCount < itemCfgData[3] then
                        isall = 0 ;
                    end
                    if name then
                        
                        local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                        tempLabel:setPosition(ccp(exwidth + jianju*(i - 1),  10));
                        m_ccnodeitem:addChild(tempLabel);
                        if breakleve > 0  and stepleve > 0 then
                            local board = CCSprite:createWithSpriteFrameName("public_equip_star.png");
                            board:setScale(0.60);
                            board:setPosition(ccp(exwidth + jianju*(i - 1) + 8,  20));
                            m_ccnodeitem:addChild(board);
                            tempLabel = game_util:createLabelTTF({text = breakleve,color = ccc3(250,180,0),fontSize = 10});
                            tempLabel:setPosition(ccp(exwidth + jianju*(i - 1),  20));
                            m_ccnodeitem:addChild(tempLabel);

                            stepleve = "+" .. stepleve ;
                            tempLabel = game_util:createLabelTTF({text = stepleve,color = ccc3(250,180,0),fontSize = 10});
                            tempLabel:setPosition(ccp(exwidth + jianju*(i - 1) - 10,  20));
                            m_ccnodeitem:addChild(tempLabel);
                        elseif breakleve > 0 then 
                            local board = CCSprite:createWithSpriteFrameName("public_equip_star.png");
                            board:setScale(0.60);
                            board:setPosition(ccp(exwidth + jianju*(i - 1) + 4,  20));
                            m_ccnodeitem:addChild(board);
                            tempLabel = game_util:createLabelTTF({text = breakleve,color = ccc3(250,180,0),fontSize = 10});
                            tempLabel:setPosition(ccp(exwidth + jianju*(i - 1)-4,  20));
                            m_ccnodeitem:addChild(tempLabel);
                        elseif stepleve > 0 then 
                            stepleve = "+" .. stepleve ;
                            tempLabel = game_util:createLabelTTF({text = stepleve,color = ccc3(250,180,0),fontSize = 10});
                            tempLabel:setPosition(ccp(exwidth + jianju*(i - 1) ,  20));
                            m_ccnodeitem:addChild(tempLabel);
                        end
                    end
                end
                -- tbndh:removeAllChildrenWithCleanup(true);
                local animNode = tbndh:getChildByTag(1000)
                if animNode then
                    animNode:removeFromParentAndCleanup(true)
                end
                if isall == 0 then
                    tbndh:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dhzx_enniu_2.png"),CCControlStateNormal);
                    tbndh:setColor(ccc3(71,71,71));
                    tbndh:setTouchEnabled(false);
                else
                    tbndh:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dhzx_enniu_1.png"),CCControlStateNormal);
                    tbndh:setTouchEnabled(true);
                    tbndh:setColor(ccc3(255,255,255));
                    game_util:addTipsAnimByType(tbndh,2);
                end
                --local isadd = 0 ; --判断是否需要添加“+”号 ，如果为0就不添加，否则就添加
                exwidth = need_item_count*jianju + jianju/3 ;
                sarrow:setPosition(ccp(exwidth, 40));
                exwidth = (need_item_count + 1)*jianju + jianju/3 ;
                local cou = cellnumcount - need_item_count

                for i=1,cou do
                    local out_item = itemCfg:getNodeWithKey("out_item" .. i);
                    local rewCount = out_item:getNodeCount()
                    if rewCount == 1 then
                        local icon,name,count,rewardType = game_util:getRewardByItem(out_item:getNodeAt(0));
                        if icon then
                            icon:setScale(0.70);
                            icon:setPosition(ccp(exwidth, 40));
                            m_ccnodeitem:addChild(icon);
                            if name then
                                if count then
                                    name = name .. "" ..  string.format("x%d", count) ;
                                end
                                local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
                                tempLabel:setPosition(ccp(exwidth,  10));
                                m_ccnodeitem:addChild(tempLabel);
                            end

                            local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck);
                            button:setAnchorPoint(ccp(0.5,0.5));
                            button:setPosition(icon:getPosition());
                            button:setOpacity(0);
                            m_ccnodeitem:addChild(button);
                            -- button:setScaleY(1.5);
                            button:setTag(1000 * index + i + need_item_count);
                        else

                        end
                    else
                        local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_kongwei.png");
                        bgSpr:setPosition(ccp(exwidth, 40))
                        m_ccnodeitem:addChild(bgSpr)
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnrandomCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(bgSpr:getPosition())
                        button:setOpacity(0)
                        m_ccnodeitem:addChild(button)
                        -- button:setScaleY(1.5)
                        button:setTag(1000 * index + i)
                        --随机礼包
                        -- bgSpr:removeAllChildrenWithCleanup(true)
                        local tempLabel = game_util:createLabelTTF({text = string_helper.game_charge_active.random_package,color = ccc3(250,180,0),fontSize = 10});
                        tempLabel:setPosition(ccp(exwidth,10));
                        m_ccnodeitem:addChild(tempLabel,10,10);
                    end
                    exwidth = exwidth + jianju ;
                end
            end
        return cell ;
        end
        params.itemOnClick = function( eventType,index,item )

        end
        return TableViewHelper:create(params);
    else
        self.lbtitlename:setVisible(true) ;
    end
    return nil;
end
--[[
    tab1
]]
function game_charge_active.refreshTable1(self)
    self.hor_table_node:removeAllChildrenWithCleanup(true);
    local tempTable = self:createLandTable(self.hor_table_node:getContentSize());
    self.hor_table_node:addChild(tempTable,10,10);
end
--[[
    tab2
]]
function game_charge_active.refreshTable2(self)
    local pX,pY;
    if self.m_tableView3 then
        pX,pY = self.m_tableView3:getContainer():getPosition();
    end
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView = nil;
    self.m_tableView3 = nil;
    self.m_tableView3 = self:createPorTable(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView3,10,10);
    if pX and pY then
        self.m_tableView3:setContentOffset(ccp(pX,pY), false);
    end
end
--[[
    tab4
]]
function game_charge_active.refreshTable4(self)
    local pX,pY;
    if self.m_tableView2 then
        pX,pY = self.m_tableView2:getContainer():getPosition();
    end
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil;
    self.m_tableView = nil;
    self.m_tableView3 = nil;
    self.m_tableView2 = self:createPorTable2(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView2,10,10);
    if pX and pY then
        self.m_tableView2:setContentOffset(ccp(pX,pY), false);
    end
end
function game_charge_active.refreshTable3(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.ver_table_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil;
    self.m_tableView2 = nil;
    self.m_tableView3 = nil;
    self.m_tableView = self:createTableView(self.ver_table_node:getContentSize());
    self.ver_table_node:addChild(self.m_tableView,33,33);

    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
end 
--[[
    label
]]
function game_charge_active.refreshLabel(self)
    local itemData = self.showCfg[self.myIndex]
    -- local title = itemData.title
    -- self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(title .. ".png"));
    local function timeEndFunc()
        
    end
    self.time_node:removeAllChildrenWithCleanup(true)
    local showActive = self.m_tGameData.show
    local itemData = showActive[tostring(self.myIndex)]
    local countdownLabel = game_util:createCountdownLabel(itemData.active_time,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0,0.5))
    countdownLabel:setPosition(ccp(0,0))
    countdownLabel:setColor(ccc3(0,250,0))
    self.time_node:addChild(countdownLabel,10,10)
end
--[[--
    刷新ui
]]
function game_charge_active.refreshUi(self)
    self.myIndex = self.showCfg[self.selectIndex].id
    if game_util:getTableLen(self.m_tGameData.show) ~= 0 then
        self:refreshTable1()
        local sort = self.showCfg[self.selectIndex].sort
        if sort > 0 and sort < 3 then--充值活动
            self:refreshTable2()
        elseif sort == 4 then--消耗活动
            self:refreshTable4()
        elseif sort == 3 then--兑换中心
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.exchangeData = json.decode(data:getFormatBuffer())
                self:refreshTable3()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("omni_exchange_lastcount"), http_request_method.GET, nil,"omni_exchange_lastcount")
        end
    end
    self:refreshLabel()
end
--[[--
    初始化
]]
function game_charge_active.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.selectIndex = 1
    self.showCfg = {}
    self.indexTable = {}
    local showCfg = getConfig(game_config_field.active_show)

    -- for i=1,showCfg:getNodeCount() do
    --     local itemCfg = showCfg:getNodeWithKey(tostring(i))
    --     local show = itemCfg:getNodeWithKey("show"):toInt()
    --     if show == 1 then
    --         local itemData = json.decode(itemCfg:getFormatBuffer())
    --         itemData.id = i
    --         table.insert(self.showCfg,itemData)--存数据
    --         -- table.insert(self.indexTable,i)--存索引    id
    --     end
    -- end

    --取服务器数据来确定显示
    local serverShow = self.m_tGameData.show
    for i=1,game_util:getTableLen(serverShow) do
        local itemData = serverShow[tostring(i)]
        local showFlag = itemData.flag

        if showFlag == 1 then
            local itemCfg = showCfg:getNodeWithKey(tostring(i))
            local itemItemCfg = json.decode(itemCfg:getFormatBuffer())
            itemItemCfg.id = i
            table.insert(self.showCfg,itemItemCfg)--存数据
        end
    end
    if game_util:getTableLen(self.showCfg) > 0 then
        self.myIndex = self.showCfg[self.selectIndex].id
    end

    self.typeid = t_params.typeid or 1 ;
end
--[[--
    创建ui入口并初始化数据
]]
function game_charge_active.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    if game_util:getTableLen(self.showCfg) > 0 then
        self:refreshUi();
    end
    return scene;
end

return game_charge_active