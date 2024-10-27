--- 押镖货物
local game_dart_goods = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_callBackFunc = nil,
    m_tips_label = nil,
};

--[[--
    销毁
]]
function game_dart_goods.destroy(self)
    -- body
    cclog("-----------------game_dart_goods destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_callBackFunc = nil;
    self.m_tips_label = nil;
end
--[[--
    返回
]]
function game_dart_goods.back(self,type)
    game_scene:removePopByName("game_dart_goods");
end
--[[--
    读取ccbi创建ui
]]
function game_dart_goods.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then
            
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_goods_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    self.m_tips_label = ccbNode:labelTTFForName("m_tips_label")
    self.table_view_node = ccbNode:nodeForName("table_view_node")
    -- self.protect_node = ccbNode:nodeForName("protect_node")--保护时间倒计时
    -- self.tip_label = ccbNode:labelTTFForName("tip_label")
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
    货物
]]
function game_dart_goods.createGoodsTable(self,viewSize)
    local goodsTable = self.m_tGameData.goods
    local goodsId = {}
    for k,v in pairs(goodsTable) do
        table.insert(goodsId,k)
    end
    local tabCount = #goodsId;
    self.m_tips_label:setVisible(tabCount == 0)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2
    params.totalItem = tabCount;
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
            local left_time_label = ccbNode:labelTTFForName("left_time_label");
            local icon_node = ccbNode:nodeForName("icon_node");

            local itemData = goodsTable[tostring(goodsId[index+1])]
            local goods = itemData.goods[1]
            local icon,name,count = game_util:getRewardByItemTable(goods)
            if icon then
                -- icon:setPosition(ccp(m_icon:getContentSize().width*0.5,m_icon:getContentSize().height*0.5))
                icon_node:addChild(icon,10)
                if count then
                    local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                    countLabel:setPosition(ccp(0,-15))
                    icon_node:addChild(countLabel,10)
                end
            end
            local leftTime = itemData.invalidity_stamp
            local timeLabel,timeStr = game_util:createStaticCountDownLabel(leftTime)
            -- CCLuaLog(timeStr)
            left_time_label:setString(timeStr)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- local itemData = goodsTable[tostring(index+1)]
            local itemData = goodsTable[tostring(goodsId[index+1])]
            local goods = itemData.goods[1]
            if self.enterType == "select" then--选中，返回到选货物界面
                if self.m_callBackFunc then
                    game_data:setDataByKeyAndValue("sel_dart_good",{goodId = tostring(goodsId[index+1]),goodData = goods})
                    self.m_callBackFunc();
                end
                self:back()
                -- game_scene:addPop("game_dart_create_team_pop",{goods_id = tostring(goodsId[index+1]),goods_info = itemData})
            elseif self.enterType == "join" then--加入其他队伍
                local params = {}
                params.goods_id = tostring(goodsId[index+1])
                params.captain_uid = self.captain_uid
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,identity = 2})
                    game_util:addMoveTips({text = string_helper.game_dart_goods.joinTeam})
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_join_goods_team"), http_request_method.GET, params,"escort_join_goods_team")
            else--查看
                game_util:lookItemDetal(goods)
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_dart_goods.refreshUi(self)
    self.table_view_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createGoodsTable(self.table_view_node:getContentSize())
    self.table_view_node:addChild(tempTable,10)
end
--[[--
    初始化
]]
function game_dart_goods.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil then
        if tolua.type(t_params.gameData) == "util_json" then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
        else
            self.m_tGameData = t_params.gameData
        end
    else
        self.m_tGameData = {}
    end
    self.enterType = t_params.enterType or "select"
    self.captain_uid = t_params.captain_uid
    self.m_callBackFunc = t_params.callBackFunc;
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_goods.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_goods;