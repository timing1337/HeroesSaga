--- 擂台战排行榜

local ui_serverpk_rank = {
    m_root_layer = nil,
    m_close_btn = nil,
    m_node_tableboard = nil,
    m_rankInfo = nil,
    m_posXId = nil,
};
--[[--
    销毁ui
]]
function ui_serverpk_rank.destroy(self)
    -- body
    cclog("-----------------ui_serverpk_rank destroy-----------------");
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_node_tableboard = nil;
    self.m_rankInfo = nil;
    self.m_posXId = nil;
end
--[[--
    返回
]]
function ui_serverpk_rank.back(self,backType)
    game_scene:removePopByName("ui_serverpk_rank");
end

local titlePosX = {{45, 110, 190, 300, 400}, {45, 900, 190, 340, 900}}
local msgPosX = {{26, 90, 170, 270, 370}, {26, 900, 170, 320, 900}}

--[[--
    读取ccbi创建ui
]]
function ui_serverpk_rank.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_serverpk_rank.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_node_tableboard = ccbNode:nodeForName("m_node_tableboard");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);

    local posXs = titlePosX[self.m_posXId] or {}
    for i=1,5 do
        local node = ccbNode:nodeForName("m_sprite_title" .. i)
        if node and posXs[i] then
            node:setPositionX(posXs[i])
        end
    end
    local sprite_png_name = { "ui_serverpk_wenzi_17.png", "ui_serverpk_wenzi_2.png",}
    local titleSprite = ccbNode:spriteForName("m_sprite_title")
    if titleSprite then
        local name = sprite_png_name[self.m_posXId] or ""
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name)
        if frame then
            titleSprite:setDisplayFrame(frame)
        end
    end
    return ccbNode;
end

--[[--
    创建列表
]]
function ui_serverpk_rank.createTableView(self,viewSize)
    local rankLabelName = {"rank_1st.png","rank_2nd.png","rank_3th.png"}
    local colorTab = {ccc3(247,198,9),ccc3(252,234,30),ccc3(255,251,47)}
    local showData = self.m_rankData
    local count = #showData;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11;
    params.totalItem = count;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_serverpk_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local rank_number = ccbNode:labelBMFontForName("rank_number")
            local top_icon = ccbNode:spriteForName("top_icon")
            local name_label = ccbNode:labelTTFForName("m_label_usrName")
            local server_name = ccbNode:labelTTFForName("m_label_serName")
            local m_blabel_combat = ccbNode:labelBMFontForName("m_blabel_combat")
            local m_blabel_tiwce = ccbNode:labelBMFontForName("m_blabel_tiwce")
            local m_sprite9_cellbg = ccbNode:scale9SpriteForName("m_sprite9_cellbg")
            local posXs = msgPosX[self.m_posXId] or {}
            for i=1,5 do
                local node = ccbNode:nodeForName("m_node_info" .. i)
                if node and posXs[i] then
                    node:setPositionX(posXs[i])
                end
            end
            -- 
            if index < 2 then
                top_icon:setVisible(true)
                rank_number:setVisible(false)
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1])
                if frame then
                    top_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rankLabelName[index+1]))
                end
                m_sprite9_cellbg:setColor(colorTab[index+1])
            else
                top_icon:setVisible(false)
                rank_number:setVisible(true)
                rank_number:setString(index+1)
                m_sprite9_cellbg:setColor(ccc3(255,255,255))
            end
            if self.m_posXId == 2 then
                server_name:setFontSize(12)
            end

            local itemData = showData[index + 1] or {}
            rank_number:setString(tostring(itemData.rank or (index + 1)) ) 
            name_label:setString(tostring(itemData.name or "" ) )
            server_name:setString(tostring(itemData.server_name or "神秘服务器" ) )
            m_blabel_combat:setString(tostring(itemData.score or "" ) )
            m_blabel_tiwce:setString(tostring(itemData.round or "" ) )
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

--[[--
    刷新ui
]]
function ui_serverpk_rank.refreshUi(self)
    self.m_node_tableboard:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_node_tableboard:getContentSize());
    tableViewTemp:setScrollBarVisible(false)
    self.m_node_tableboard:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function ui_serverpk_rank.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = {}
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    local rankdata = data and data:getNodeWithKey("rank")
    local count = rankdata and rankdata:getNodeCount() or 0
    self.m_rankData = {}
    for i=1,count do
        local item = rankdata:getNodeAt(i - 1)
        if item then
            local one = json.decode(item:getFormatBuffer())
            table.insert(self.m_rankData, one)
        end
    end
    -- cclog2(self.m_rankData , "self.m_rankData == ")
    self.m_posXId = t_params.showType or 2
end

--[[--
    创建ui入口并初始化数据
]]
function ui_serverpk_rank.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_serverpk_rank;