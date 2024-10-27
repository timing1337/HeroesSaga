--- 抢劫战斗结算
local game_dart_battle_result = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view_node = nil,
    m_reward_node = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
};

--[[--
    销毁
]]
function game_dart_battle_result.destroy(self)
    -- body
    cclog("-----------------game_dart_battle_result destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view_node = nil;
    self.m_reward_node = nil;
    self.m_callBackFunc = nil;
    self.m_tips_label = nil;
end
--[[--
    返回
]]
function game_dart_battle_result.back(self,type)
    if self.m_callBackFunc then
        self.m_callBackFunc();
    end
    game_scene:removePopByName("game_dart_battle_result");
end
--[[--
    读取ccbi创建ui
]]
function game_dart_battle_result.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_battle_result.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    self.m_reward_node = ccbNode:nodeForName("m_reward_node")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos1 = self.m_list_view_node:getParent():convertToNodeSpace(ccp(x,y));
            local realPos2 = self.m_reward_node:getParent():convertToNodeSpace(ccp(x,y));
            if not (self.m_list_view_node:boundingBox():containsPoint(realPos1) or self.m_reward_node:boundingBox():containsPoint(realPos2)) then
                self:back();
            end
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    信息
]]
function game_dart_battle_result.createRewardTable(self,viewSize)
    local showData = self.m_tGameData.reward_list or {}
    self.m_tips_label:setVisible(#showData == 0)
    self.m_tips_label:setString(string_helper.game_dart_battle_result.noGoods)
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = #showData;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_dart_goods_pop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local left_time_label = ccbNode:labelTTFForName("left_time_label")
            local icon_node = ccbNode:nodeForName("icon_node")
            icon_node:removeAllChildrenWithCleanup(true)
            local icon,name,count = game_util:getRewardByItemTable(showData[index+1])
            if icon then
                icon_node:addChild(icon)
            end
            left_time_label:setString("×" .. tostring(count))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            game_util:lookItemDetal(showData[index+1])
        end
    end
    return TableViewHelper:create(params);
end
--[[
    信息
]]
function game_dart_battle_result.createBattleResultTable(self,viewSize)
    local showData = self.m_tGameData.log_list
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag+1]
        local function responseMethod(tag,gameData)
            game_data:setBattleType("escort_battle_replay");
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        end
        local params = {battle_log = itemData.battle_log}
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_battle_replay"), http_request_method.GET, params,"escort_battle_replay")
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = #showData;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.itemActionFlag = true;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_battle_result_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
        end
        if cell then
            local itemData = showData[index+1]
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            m_look_btn:setTag(index)
            local m_name_label_1 = ccbNode:labelTTFForName("m_name_label_1")
            local m_name_label_2 = ccbNode:labelTTFForName("m_name_label_2")
            local m_reslut_sprite_1 = ccbNode:spriteForName("m_reslut_sprite_1")
            local m_reslut_sprite_2 = ccbNode:spriteForName("m_reslut_sprite_2")
            local m_icon_sprite_1 = ccbNode:spriteForName("m_icon_sprite_1")
            local m_icon_sprite_2 = ccbNode:spriteForName("m_icon_sprite_2")
            m_name_label_1:setString(tostring(itemData.attacker))
            m_name_label_2:setString(tostring(itemData.defender))
            local tempSize = m_icon_sprite_1:getContentSize();
            local tempIcon = game_util:createPlayerIconByRoleId(itemData.attacker_role)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                m_icon_sprite_1:addChild(tempIcon)
            end
            local tempIcon = game_util:createPlayerIconByRoleId(itemData.defender_role)
            if tempIcon then
                tempIcon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
                m_icon_sprite_2:addChild(tempIcon)
            end
            local is_win = itemData.is_win or 0
            local tempSpriteFrame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_sheng.png")
            local tempSpriteFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_bai.png")
            if is_win == 1 then
                if tempSpriteFrame1 then
                    m_reslut_sprite_1:setDisplayFrame(tempSpriteFrame1)
                end
                if tempSpriteFrame2 then
                    m_reslut_sprite_2:setDisplayFrame(tempSpriteFrame2)
                end
            else
                if tempSpriteFrame1 then
                    m_reslut_sprite_1:setDisplayFrame(tempSpriteFrame2)
                end
                if tempSpriteFrame2 then
                    m_reslut_sprite_2:setDisplayFrame(tempSpriteFrame1)
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
    刷新ui
]]
function game_dart_battle_result.refreshUi(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true)
    self.m_reward_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createBattleResultTable(self.m_list_view_node:getContentSize())
    self.m_list_view_node:addChild(tempTable,10)
    local tempTable = self:createRewardTable(self.m_reward_node:getContentSize())
    self.m_reward_node:addChild(tempTable,10)
    local m_result_sprite = self.m_ccbNode:spriteForName("m_result_sprite")
    local is_win = self.m_tGameData.is_win or 0
    local tempSpriteFrame = nil;
    if is_win == 1 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_shengli.png")
        -- game_util:addMoveTips({text = "恭喜您！胜利里"});
    else
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dart_shibai.png")
        -- game_util:addMoveTips({text = "很遗憾~你失败了"});
    end
    if tempSpriteFrame then
        m_result_sprite:setDisplayFrame(tempSpriteFrame)
    end
end
--[[--
    初始化
]]
function game_dart_battle_result.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {}
    end
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_battle_result.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_battle_result;