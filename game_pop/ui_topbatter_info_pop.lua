--- 战报

local ui_topbatter_info_pop = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_battlefield_table_node = nil,
    m_topplayer_name = nil,
    log_info = nil,
    m_openType = nil,
};

local battleInfo = string_helper.ui_topbatter_info_pop.battleInfo

function ui_topbatter_info_pop.getBattleInfo(self, winer, loser)
    print("winer, loser   ======  ", winer, loser)
    local player = {WINER = winer or "", LOSER = loser or ""}
    local info = battleInfo["topplayer_info" .. math.random(1, 5)] or ""
    print("inco ======= ", info)
    info = string.gsub(info, "[WINER,LOSER]+", function ( key )
        return player[key] or key
    end )
    return info
end

--[[--
    销毁ui
]]
function ui_topbatter_info_pop.destroy(self)
    -- body
    cclog("-----------------ui_topbatter_info_pop destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_battlefield_table_node = nil;
    self.log_info = nil;
    self.m_openType = nil;
    self.m_topplayer_name = nil;
end
--[[--
    返回
]]
function ui_topbatter_info_pop.back(self,backType)
    game_scene:removePopByName("ui_topbatter_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_topbatter_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_arena_battlefield_pop.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_battlefield_table_node = ccbNode:nodeForName("battlefield_table_node");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    最强玩家战报
]]
function ui_topbatter_info_pop.createTableViewTopPlayer(self,viewSize)

    local function onCellBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
    end

    local fightCount = #self.log_info;
    cclog2(fightCount, "fightCount  ===  ")
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:registerFunctionWithFuncName("onMainClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_topplayer_battleinfo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));          
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_label_message = ccbNode:labelTTFForName("m_label_message")
            -- [{"atk_win":true,"id":"1404831270_0","atk_name":"转基因转","atk_uid":"h18985711","ts":1404831270}]
            local info = self.log_info[index + 1]

            local timeinfo = os.date("%Y-%m-%d %H:%M:%S", info.ts)
            local winer = self.m_topplayer_name or ""
            local loser = info.atk_name or ""
            if info.atk_win then 
                loser = self.m_topplayer_name or ""
                winer = info.atk_name or ""
            end
            local msg = self:getBattleInfo(winer, loser) or ""
            m_label_message:setString(tostring(msg) or "")

            local m_label_name1 = ccbNode:labelTTFForName("m_label_name1")
            m_label_name1:setString( info.atk_name or "" )

            for i=1,4 do
                local m_label_time = ccbNode:labelTTFForName("m_label_time" .. i)
                m_label_time:setString( timeinfo or "")
            end
        end
        cell:setTag(1001 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end



--[[--
    刷新ui
]]
function ui_topbatter_info_pop.refreshUi(self)
    if self.m_openType == "ui_topbatter_info_pop" then
        self.m_battlefield_table_node:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createTableViewTopPlayer(self.m_battlefield_table_node:getContentSize());
        self.m_battlefield_table_node:addChild(tableViewTemp);
    end
end
--[[--
    初始化
]]
function ui_topbatter_info_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_topplayer_name = t_params.top_name
    self.log_info = t_params.log_info or {};
    self.m_openType = t_params.openType or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function ui_topbatter_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_topbatter_info_pop;