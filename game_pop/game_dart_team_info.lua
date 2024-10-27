--- 押镖队伍详情
local game_dart_team_info = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_go_btn = nil,
    m_callBackFunc = nil,
    m_ship_sprite = nil,
    m_ship_title = nil,
    m_tips_label = nil,
    m_ship_tips_label = nil,
    m_rob_times_label = nil,
};

--[[--
    销毁
]]
function game_dart_team_info.destroy(self)
    -- body
    cclog("-----------------game_dart_team_info destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_go_btn = nil;
    self.m_callBackFunc = nil;
    self.m_ship_sprite = nil;
    self.m_ship_title = nil;
    self.m_tips_label = nil;
    self.m_ship_tips_label = nil;
    self.m_rob_times_label = nil;
end


--[[--
    返回
]]
function game_dart_team_info.back(self,type)
    if self.m_callBackFunc then
        self.m_callBackFunc();
    end
    game_scene:removePopByName("game_dart_team_info");
end
--[[--
    读取ccbi创建ui
]]
function game_dart_team_info.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--打劫
            --没队伍创建或加入队伍，有自己的队伍直接打劫   0是无对1是队长2是队员
            local rob_identity =  self.m_tGameData.rob_identity or 0
            if rob_identity == 0 then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_tavern",{gameData = gameData})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_rob_index"), http_request_method.GET, nil,"escort_rob_index")
            elseif rob_identity == 1 then
                local rob_num = game_data:getDataByKey("rob_num") or 0--人数
                if rob_num < 3 then
                    -- game_util:addMoveTips({text = "您的队伍还未满，不能抢劫！"})
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, nil,"escort_check_my_rob_team")
                else
                    local function responseMethod(tag,gameData)
                        game_scene:addPop("game_dart_battle_result",{gameData = gameData,callBackFunc = self.m_callBackFunc})
                        game_scene:removePopByName("game_dart_team_info");
                    end
                    local vehicle_info = self.m_tGameData.vehicle_info or {}
                    local member = vehicle_info.member or {}
                    local params = {vehicle_captain_uid = member[1]}
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_rob"), http_request_method.GET, params,"escort_rob")
                end
            elseif rob_identity == 2 then
                local rob_num = game_data:getDataByKey("rob_num") or 0--0人数不足，1已满
                if rob_num == 0 then
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_dart_tavern_info",{gameData = gameData})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_check_my_rob_team"), http_request_method.GET, nil,"escort_check_my_rob_team")
                else
                    game_util:addMoveTips({text = string_helper.game_dart_team_info.robDeny})
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_teaminfo.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.team_node = ccbNode:nodeForName("team_node")
    self.m_go_btn = ccbNode:controlButtonForName("m_go_btn")
    self.m_go_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_ship_sprite = ccbNode:spriteForName("m_ship_sprite")
    self.m_ship_title = ccbNode:spriteForName("m_ship_title")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.m_ship_tips_label = ccbNode:labelTTFForName("m_ship_tips_label")
    self.m_rob_times_label = ccbNode:labelTTFForName("m_rob_times_label")
    game_util:setNodeUpAndDownMoveAction(self.m_ship_sprite)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[
    队伍信息
]]
function game_dart_team_info.createTavernTable(self,viewSize)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local members_info = vehicle_info.members_info
    local goods = vehicle_info.goods or {}
    local member = vehicle_info.member or {}
    local tabCount = #member;
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        local tempUid = tostring(member[btnTag + 1])
        local itemData = members_info[tempUid] or {}
        local playerGoods = goods[tempUid] or {}
        local tempGoods = playerGoods.goods or {}
        if #tempGoods > 0 then
            game_util:lookItemDetal(tempGoods[1])
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_dart_team_info_item2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_title_sprite = ccbNode:spriteForName("m_title_sprite")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
            local m_item_bg_spri = ccbNode:scale9SpriteForName("m_item_bg_spri")
            local tempSpriteFrame = nil;
            if index == 0 then
                tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pb_ditiao3.png")
            else
                tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pb_ditiao1.png")
            end
            if tempSpriteFrame then
                m_item_bg_spri:setSpriteFrame(tempSpriteFrame)
                m_item_bg_spri:setPreferredSize(CCSizeMake(185,55))
            end
            local m_icon_node = ccbNode:nodeForName("m_icon_node")
            local m_look_good_btn = ccbNode:controlButtonForName("m_look_good_btn")
            m_look_good_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            m_look_good_btn:setTag(index)
            local tempUid = tostring(member[index+1])
            local itemData = members_info[tempUid] or {}
            
            local playerGoods = goods[tempUid] or {}
            local tempGoods = playerGoods.goods or {}
            local icon,goods_name,count = game_util:getRewardByItemTable(tempGoods[1])
            if icon then
                m_look_good_btn:setVisible(true);
                icon:setScale(0.8)
                m_icon_node:addChild(icon)
                if count then
                    local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                    countLabel:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5-15))
                    icon:addChild(countLabel,10)
                end
            end
            m_name_label:setString(tostring(itemData.name) .. "(Lv." .. tostring(itemData.level) .. ")")
            m_combat_label:setString(string_helper.game_dart_team_info.combat .. tostring(itemData.combat))
            m_title_sprite:setVisible(member[1] == tempUid)
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
function game_dart_team_info.refreshUi(self)
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    local vehicle_info = self.m_tGameData.vehicle_info or {}
    local member = vehicle_info.member or {}
    local goods = vehicle_info.goods or {}
    local members_goods = goods[uid] or {}
    local inTeamFlag = game_util:valueInTeam(uid,member)
    inTeamFlag = (inTeamFlag and members_goods.goods ~= nil)
    local buff_sort = self.m_tGameData.buff_sort or 0
    if buff_sort == 4 and not inTeamFlag then
        self.m_tips_label:setVisible(true)
        -- self.m_ship_title:setVisible(false)
        -- self.m_ship_sprite:setVisible(false)
    else
        self.m_tips_label:setVisible(false)
        self.team_node:removeAllChildrenWithCleanup(true)
        local tempTable = self:createTavernTable(self.team_node:getContentSize())
        tempTable:setMoveFlag(false);
        tempTable:setScrollBarVisible(false)
        self.team_node:addChild(tempTable,10)
    end
    local buff_sort_item = BUFF_SORT_IMG[buff_sort+1]
    if buff_sort_item then
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.title)
        if tempSpriteFrame then
            self.m_ship_title:setDisplayFrame(tempSpriteFrame);
        end
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buff_sort_item.ship)
        if tempSpriteFrame then
            self.m_ship_sprite:setDisplayFrame(tempSpriteFrame);
        end
        self.m_ship_sprite:setScale(buff_sort_item.scale)
        self.m_ship_tips_label:setString(tostring(buff_sort_item.des))
    end
    self.m_go_btn:setVisible(not inTeamFlag)
    local rob_identity =  self.m_tGameData.rob_identity or 0
    local rob_num = game_data:getDataByKey("rob_num") or 0--人数
    if rob_identity == 0 or rob_num < 3 then
        game_util:setCCControlButtonBackground(self.m_go_btn,"dart_btn_zuduidajie.png")
    else
        game_util:setCCControlButtonBackground(self.m_go_btn,"dart_btn_dajie.png")
    end
    local rob_times = vehicle_info.rob_times or 0--被打劫次数
    local rob_times_des = inTeamFlag == true and string_helper.game_dart_team_info.robedTims .. tostring(rob_times) or ""
    self.m_rob_times_label:setString(rob_times_des)
end
--[[--
    初始化
]]
function game_dart_team_info.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.m_callBackFunc = t_params.callBackFunc
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_team_info.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_team_info;