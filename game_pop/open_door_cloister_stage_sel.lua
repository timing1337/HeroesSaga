--- 信息
local M = 
{
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_list_view_node = nil,
    m_max_layer = nil,
}
local open_door_cloister_stage_sel = M;

--[[--
    销毁
]]
function M.destroy(self)
    -- body
    cclog("-----------------open_door_cloister_stage_sel destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_list_view_node = nil;
    self.m_max_layer = nil;
end
--[[--
    返回
]]
function M.back(self,type)
    game_scene:removePopByName("open_door_cloister_stage_sel");
end
--[[--
    读取ccbi创建ui
]]
function M.createUi(self)
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_door_cloister_stage_sel.ccbi");
    self.m_list_view_node = ccbNode:nodeForName("m_list_view_node")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            local realPos = self.m_list_view_node:getParent():convertToNodeSpace(ccp(x,y));
            if not self.m_list_view_node:boundingBox():containsPoint(realPos) then
                self:back();
            end
            return true;
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    创建列表
]]
function M.createStageTableView(self,viewSize)
    local maze_mine_cfg = getConfig(game_config_field.maze_mine)
    local totalItem = maze_mine_cfg:getNodeCount();
    local showData = {}
    local tempValue = math.floor(1 + self.m_max_layer / 10);
    for i=1,tempValue do
        table.insert(showData,10*(i - 1) + 1)
    end
    local selListItem = nil;
    local selIndex = 0;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local tempLabel = game_util:createLabelTTF({text = string.format(string_helper.open_door_cloister_stage_sel,showData[index + 1]),color = ccc3(33,197,230),fontSize = 20});
            tempLabel:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(tempLabel,1,1000)
            if index == selIndex then
                tempLabel:setScale(1.5)
                selListItem = cell;
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xjhl_dasanjiao.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setPosition(ccp(itemSize.width*0.2, itemSize.height*0.5))
                    cell:addChild(tempSprite,1,1001)
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setPosition(ccp(itemSize.width*0.8, itemSize.height*0.5))
                    tempSprite:setFlipX(true);
                    cell:addChild(tempSprite,1,1002)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            if index ~= selIndex then
                selIndex = index;
                if selListItem then
                    local tempLabel = selListItem:getChildByTag(1000)
                    if tempLabel then
                        tempLabel:setScale(1);
                    end
                    local tempNode1 = selListItem:getChildByTag(1001)
                    if tempNode1 then
                        tempNode1:removeFromParentAndCleanup(true);
                    end
                    local tempNode2 = selListItem:getChildByTag(1002)
                    if tempNode2 then
                        tempNode2:removeFromParentAndCleanup(true);
                    end
                end
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xjhl_dasanjiao.png")
                if spriteFrame then
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setPosition(ccp(itemSize.width*0.2, itemSize.height*0.5))
                    cell:addChild(tempSprite,1,1001)
                    local tempSprite = CCSprite:createWithSpriteFrame(spriteFrame)
                    tempSprite:setPosition(ccp(itemSize.width*0.8, itemSize.height*0.5))
                    tempSprite:setFlipX(true);
                    cell:addChild(tempSprite,1,1002)
                end
                local tempLabel = cell:getChildByTag(1000)
                if tempLabel then
                    tempLabel:setScale(1.5);
                end
                selListItem = cell;
            end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("open_door_cloister_detail",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_start"), http_request_method.GET, {layer = showData[index + 1]},"maze_start")
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function M.refreshStageTableView(self)
    self.m_list_view_node:removeAllChildrenWithCleanup(true);
    local tableView = self:createStageTableView(self.m_list_view_node:getContentSize());
    tableView:setScrollBarVisible(false);
    self.m_list_view_node:addChild(tableView,10,10);
end

--[[--
    刷新ui
]]
function M.refreshUi(self)
    self:refreshStageTableView();
end

--[[--
    初始化
]]
function M.init(self,t_params)
    t_params = t_params or {};
    self.m_max_layer = t_params.max_layer or 1
    self.m_max_layer = self.m_max_layer == 0 and 1 or self.m_max_layer;
end

--[[--
    创建ui入口并初始化数据
]]
function M.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return open_door_cloister_stage_sel;