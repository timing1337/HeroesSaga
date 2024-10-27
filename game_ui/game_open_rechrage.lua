---  新竞技场
local game_open_recharge = {
    m_gameData = nil,
    m_rank_node= nil,
    tableview_node = nil,
    m_screenShoot = nil,
    m_root_layer = nil,
    default_index = nil,
};
--[[--
    销毁ui
]]
function game_open_recharge.destroy(self)
    cclog("-----------------game_open_recharge destroy-----------------");
    self.m_gameData = nil;
    --排行榜的控件
    self.m_rank_node = nil;
    self.tableview_node = nil;
    self.m_screenShoot = nil;
    self.m_root_layer = nil;
    self.default_index = nil;
end
--[[--
    返回
]]
function game_open_recharge.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_open_recharge.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 11 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_charge.ccbi");
    --排行榜的控件
    self.tableview_node = ccbNode:nodeForName("tableview_node");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    local tempposX, tempposY = self.tableview_node:getPosition()
    local tempPos = self.tableview_node:getParent():convertToWorldSpace(ccp(tempposX,tempposY))
    local tempPosX = tempPos.x + 85 or 453
    if self.default_index > 0 then--开启
        local chargeData = self.m_tGameData.show
        local chargeId = {}
        for k,v in pairs(chargeData) do
            table.insert(chargeId,k)
        end
        local function sortfunction(id1,id2)
           return tonumber(id1) < tonumber(id2)
        end
        table.sort( chargeId, sortfunction )
        local itemId = chargeId[self.default_index]
        local tempPos = {x = tempPosX,y = 275-self.default_index*38}
        game_scene:addPop("game_reward_info_pop",{itemId = itemId,pos = tempPos})
    end

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos = self.tableview_node:getParent():convertToNodeSpace(ccp(x,y));
            if self.tableview_node:boundingBox():containsPoint(realPos) then
                return false;
            end
            return true;  
        end 
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    local btn_recharge = ccbNode:controlButtonForName("btn_recharge")
    btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
    return ccbNode;
end
--[[
    
]]
function game_open_recharge.createTableView(self,viewSize)
    local chargeCfg = getConfig(game_config_field.server_active_recharge)
    local chargeData = self.m_tGameData.show
    local chargeId = {}
    for k,v in pairs(chargeData) do
        table.insert(chargeId,k)
    end
    local function sortfunction(id1,id2)
       return tonumber(id1) < tonumber(id2)
    end
    table.sort( chargeId, sortfunction )
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();        
        cclog("btnTag ==== " .. btnTag)
        if btnTag > 1000 and btnTag < 2000 then--领取
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);

                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
            end
            local index = btnTag - 1000
            local itemId = chargeId[index]
            local params = {}
            params.active_id = itemId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_active_recharge_receive"), http_request_method.GET, params,"server_active_recharge_receive")
        elseif btnTag > 2000 then--查看
            local index = btnTag - 2000
            local itemId = chargeId[index]
            local posX,posY = tagNode:getPosition()
            local tempPos = tagNode:getParent():convertToWorldSpace(ccp(posX,posY))
            cclog("posX = " .. tempPos.x .. "    posY = " .. tempPos.y)
            game_scene:addPop("game_reward_info_pop",{itemId = itemId,pos = tempPos})
        end
    end
    local function timeOverFunc()
        
    end
    local fightCount = game_util:getTableLen(chargeData)
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;
    params.column = 1; --列
    params.totalItem = fightCount + 1;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_open_charge_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < fightCount then
                ccbNode:setVisible(true)
                --
                local title_sprite = ccbNode:spriteForName("title_sprite")
                local bar_node = ccbNode:nodeForName("bar_node")
                local money_label = ccbNode:labelBMFontForName("money_label")
                local get_node = ccbNode:nodeForName("get_node")
                local look_get = ccbNode:controlButtonForName("look_get")
                look_get:setOpacity(0)
                look_get:setTag(1001 + index)
                local get_sprite = ccbNode:spriteForName("get_sprite")
                local look_node = ccbNode:nodeForName("look_node")
                local look_btn = ccbNode:controlButtonForName("look_btn")
                look_btn:setOpacity(0)
                look_btn:setTag(2001 + index)
                local rest_time_node = ccbNode:nodeForName("rest_time_node")
                local des_label = ccbNode:labelTTFForName("des_label")
                
                local cell_cost = ccbNode:scale9SpriteForName("cell_cost")
                local cell_charge = ccbNode:scale9SpriteForName("cell_charge")

                local itemId = chargeId[index+1]
                local itemData = chargeData[itemId]

                local itemCfg = chargeCfg:getNodeWithKey(tostring(itemId))
                local num = itemCfg:getNodeWithKey("num"):toInt()
                local des = itemCfg:getNodeWithKey("des"):toStr()

                --
                bar_node:removeAllChildrenWithCleanup(true)
                local bar = ExtProgressTime:createWithFrameName("open_charge_bar_back.png","open_charge_bar.png")
                bar:setMaxValue(num);
                bar:setCurValue(itemData.now_value,false);
                bar:setAnchorPoint(ccp(0.5,0.5));
                bar:setPosition(ccp(0,0));
                bar_node:addChild(bar)

                local bar_label = game_util:createLabelTTF({text = itemData.now_value .. "/" .. num,color = ccc3(255,255,255),fontSize = 10});
                bar_node:addChild(bar_label)

                des_label:setString(des)
                des_label_1 = {}
                for i=1,4 do
                    des_label_1[i] = ccbNode:labelTTFForName("des_label_" .. i)
                    des_label_1[i]:setString(des)
                end
                local charge_type = itemCfg:getNodeWithKey("charge_type"):toInt()
                if charge_type == 2 then--充值
                    cell_cost:setVisible(false)
                    cell_charge:setVisible(true)
                    des_label:setColor(ccc3(249,233,90))
                else--消费
                    cell_cost:setVisible(true)
                    cell_charge:setVisible(false)
                    des_label:setColor(ccc3(96,246,255))
                end
                local get_flag = itemData.flag
                look_node:setVisible(false)
                get_node:setVisible(false)
                if get_flag == 1 then--不可领取
                    look_node:setVisible(true)

                    local remain_time = math.floor(itemData.remain_time)
                    rest_time_node:removeAllChildrenWithCleanup(true)
                    -- local restTime = game_util:createCountdownLabel(remain_time,timeOverFunc,8,1)
                    local restTime = game_util:createStaticCountDownLabel(remain_time)
                    restTime:setColor(ccc3(66,18,3))
                    rest_time_node:addChild(restTime,10,10)
                elseif get_flag == 2 then--已领取
                    get_node:setVisible(true)
                    look_get:setEnabled(false)
                    get_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("open_charge_getted.png"));
                elseif get_flag == 0 then--可领取
                    look_get:setEnabled(true)
                    get_node:setVisible(true)
                    local testSpr = CCSprite:createWithSpriteFrameName("open_charge_getting.png")
                    get_sprite:setDisplayFrame(testSpr:displayFrame());
                end
            else
                ccbNode:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新
]]
function game_open_recharge.refreshUi(self)
    self.tableview_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView(self.tableview_node:getContentSize())
    self.tableview_node:addChild(tableView,10,10)
end

--[[--
    初始化
]]
function game_open_recharge.init(self,t_params)
    t_params = t_params or {};
    self.m_screenShoot = t_params.screenShoot;
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.default_index = 0
    local chargeCfg = getConfig(game_config_field.server_active_recharge)
    local chargeData = self.m_tGameData.show
    local chargeId = {}
    for k,v in pairs(chargeData) do
        table.insert(chargeId,k)
    end
    local function sortfunction(id1,id2)
       return tonumber(id1) < tonumber(id2)
    end
    table.sort( chargeId, sortfunction )
    for i=1,#chargeId do--遍历取得有无可领取的
        local itemId = chargeId[i]
        local itemData = chargeData[itemId]
        local flag = itemData.flag
        if flag == 0 then
            self.default_index = i
            break;
        end
    end
    if self.default_index == 0 then--没有可领取的，去取第一个未完成的
        for i=1,#chargeId do--
            local itemId = chargeId[i]
            local itemData = chargeData[itemId]
            local flag = itemData.flag
            if flag == 1 then
                self.default_index = i
                break;
            end
        end
    end
end

--[[--
    创建ui入口并初始化数据
]]
function game_open_recharge.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_open_recharge;
