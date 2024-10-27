---  海贼宝藏弹出框

local game_seapoacher_box_pop = {
    m_root_layer = nil,
    m_tGameData = nil,
    m_tips_label = nil,
    m_node_view_1 = nil,
    m_node_view_2 = nil,
    m_callBackFunc = nil,
    m_changeFlag = nil,
    m_selectViewY1 = nil,
    m_selectViewY2 = nil,
    m_tableView1 = nil,
    m_tableView2 = nil,
};
--[[--
    销毁ui
]]
function game_seapoacher_box_pop.destroy(self)
    -- body
    cclog("----------------- game_seapoacher_box_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_tGameData = nil;
    self.m_btn_ok = nil;
    self.m_tips_label = nil;
    self.m_node_view_1 = nil
    self.m_node_view_2 = nil
    self.m_callBackFunc = nil;
    self.m_changeFlag = nil;
    self.m_selectViewY1 = nil;
    self.m_selectViewY2 = nil;
    self.m_tableView1 = nil;
    self.m_tableView2 = nil;
end
--[[--
    返回
]]
function game_seapoacher_box_pop.back(self,backType)
    game_scene:removePopByName("game_seapoacher_box_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_seapoacher_box_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            if self.m_changeFlag == true and self.m_callBackFunc then
                self.m_callBackFunc({gameData = self.m_tGameData});
            end
            self:back()
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_seapoacher_box_pop.ccbi");
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-1,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_node_view_1 = ccbNode:nodeForName("m_node_view_1")
    self.m_node_view_2 = ccbNode:nodeForName("m_node_view_2")
    local m_mask_layer = ccbNode:layerForName("m_mask_layer")
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label");
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            local realPos1 = self.m_node_view_1:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_view_1:boundingBox():containsPoint(realPos1) then
                return false;
            end
            local realPos2 = self.m_node_view_2:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_view_2:boundingBox():containsPoint(realPos2) then
                return false;
            end
            return true;  
        end 
    end
    m_mask_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_mask_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建列表1
]]
function game_seapoacher_box_pop.createTableView(self,viewSize,showData)
    showData = showData or {}
    local showDataIds = {}
    for k,v in pairs(showData) do
        table.insert(showDataIds,k)
    end
    local one_piece_exchange_cfg = getConfig(game_config_field.one_piece_exchange)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ========== " .. btnTag)
        if btnTag < 10000 then
            if self.m_tableView1 then
                self.m_selectViewY1 = self.m_tableView1:getContentOffset().y
            end
            if self.m_tableView2 then
                self.m_selectViewY2 = self.m_tableView2:getContentOffset().y
            end
            self:exchangeByCid(showDataIds[btnTag+1])
        else
            local itemCfg = one_piece_exchange_cfg:getNodeWithKey(showDataIds[btnTag-9999] or "")
            if itemCfg then
                local reward = itemCfg:getNodeWithKey("reward")
                local rewardTable = json.decode(reward:getFormatBuffer()) or {}
                if #rewardTable > 0 then
                    game_util:lookItemDetal(rewardTable[1])
                end
            end
        end
    end
    local params = {}
    params.viewSize = viewSize
    params.row = 3
    params.column = 1 -- 列
    params.direction = kCCScrollViewDirectionVertical
    params.totalItem = #showDataIds
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);            
            ccbNode:openCCBFile("ccb/ui_game_seapoacher_box_item2.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_ok_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            ccbNode:controlButtonForName("m_look_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
            local m_look_btn = ccbNode:controlButtonForName("m_look_btn")
            local m_node = ccbNode:nodeForName("m_node")
            m_node:removeAllChildrenWithCleanup(true);
            local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local m_label_limitnum = ccbNode:labelTTFForName("m_label_limitnum")
            m_ok_btn:setTag(index)
            game_util:setCCControlButtonTitle(m_ok_btn,string_helper.ccb.text198)
            m_look_btn:setTag(10000+index)
            local itemData = showData[showDataIds[index+1]]
            local itemCfg = one_piece_exchange_cfg:getNodeWithKey(showDataIds[index+1])
            local tempName = "";
            if itemCfg then
                local reward = itemCfg:getNodeWithKey("reward")
                local rewardTable = json.decode(reward:getFormatBuffer()) or {}
                if #rewardTable > 0 then
                    local icon,name,count = game_util:getRewardByItemTable(rewardTable[1],false)
                    if icon then
                        icon:setScale(0.85)
                        m_node:addChild(icon)
                        if count then
                            local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count), scale = 1.5})
                            blabelCount:setAnchorPoint(ccp(0.5, 0))
                            blabelCount:setPosition(icon:getContentSize().width * 0.95, 0)
                            icon:addChild(blabelCount, 11)
                        end
                    end
                    tempName = name;
                end
                -- if itemData.remain == -1 then
                    m_tips_label:setString(tostring(tempName))
                -- else
                --     m_tips_label:setString(tostring(tempName) .. "(" .. tostring(itemData.remain) .. ")")
                -- end
                local need_key_num = itemCfg:getNodeWithKey("need_key_num"):toInt();
                m_cost_label:setString(need_key_num)


                local max_num =  itemCfg:getNodeWithKey("limit_num"):toInt();
                if max_num > 0 then
                    local limit_sort = itemCfg:getNodeWithKey("sort"):toInt() or 3
                    local perStr = string_helper.game_seapoacher_box_pop.perStr
                    if limit_sort == 1 then
                        perStr = string_helper.game_seapoacher_box_pop.perStr
                    elseif limit_sort == 3 then
                        perStr = string_helper.game_seapoacher_box_pop.allperStr
                    end
                    local string_info = tostring(perStr) .. tostring(math.max(itemData.remain, 0)) .. "/" .. tostring(max_num)
                    m_label_limitnum:setString(string_info)
                else
                    m_label_limitnum:setString(string_helper.game_seapoacher_box_pop.multiple) 
                end
            else
                m_tips_label:setString(string_helper.game_seapoacher_box_pop.noCfg)
                m_cost_label:setString(string_helper.game_seapoacher_box_pop.noCfg)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            -- game_util:lookItemDetal(rewardTab[index+1])
        end
    end
    return TableViewHelper:create(params);
end

--[[
    
]]
function game_seapoacher_box_pop.exchangeByCid(self,c_id)
    function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        local reward = self.m_tGameData.reward or {}
        game_util:rewardTipsByDataTable(reward);
        self:refreshUi();
        self.m_changeFlag = true;
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("one_piece_exchange"), http_request_method.GET, {id = c_id},"one_piece_exchange")
end

--[[--
    刷新
]]
function game_seapoacher_box_pop.refreshTableView(self)
    local exchange_index = self.m_tGameData.exchange_index or {}
    local gifts = exchange_index.gifts or {}
    self.m_node_view_1:removeAllChildrenWithCleanup(true);
    self.m_tableView1 = nil
    local m_tableView1 = self:createTableView(self.m_node_view_1:getContentSize(),gifts.exchange_1 or {});
    self.m_node_view_1:addChild(m_tableView1);
    self.m_tableView1 = m_tableView1
    if self.m_selectViewY1 then
        self.m_tableView1:setContentOffset(ccp(0, self.m_selectViewY1))
        self.m_selectViewY1 = nil
    end


    self.m_node_view_2:removeAllChildrenWithCleanup(true);
    self.m_tableView2 = nil
    local m_tableView2 = self:createTableView(self.m_node_view_2:getContentSize(),gifts.exchange_2 or {});
    self.m_node_view_2:addChild(m_tableView2);
    self.m_tableView2 = m_tableView2
    if self.m_selectViewY2 then
        self.m_tableView2:setContentOffset(ccp(0, self.m_selectViewY2))
        self.m_selectViewY2 = nil
    end
end

--[[--
    刷新ui
]]
function game_seapoacher_box_pop.refreshUi(self)
    self:refreshTableView();
    local key_num = self.m_tGameData.key_num or 0
    self.m_tips_label:setString(string.format(string_helper.game_seapoacher_box_pop.have,key_num))
end
--[[--
    初始化
]]
function game_seapoacher_box_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        else
            self.m_tGameData = t_params.gameData;
        end
    else
        self.m_tGameData = {};
    end
    self.m_callBackFunc = t_params.callBackFunc
    self.m_changeFlag = false;
end
--[[--
    创建ui入口并初始化数据
]]
function game_seapoacher_box_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_seapoacher_box_pop;
