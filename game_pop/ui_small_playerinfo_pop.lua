---  小型玩家信息弹出框
cclog2 = cclog2 or function() end
local ui_small_playerinfo_pop = {
    m_node_zhenrong_board = nil,
    m_node_playerInfo = nil,
    m_node_playerimage = nil, 
    m_playerInfo = nil,  -- 玩家数据
    m_describeInfo = nil, -- 玩家描述性信息
    m_pyramidInfo = nil,  -- 查看玩家的金字塔层数信息
    m_gameData = nil,
    m_callFun = nil,
};
--[[--
    销毁ui
]]
function ui_small_playerinfo_pop.destroy(self)
    -- body
    cclog("----------------- ui_small_playerinfo_pop destroy-----------------"); 
    self.m_node_zhenrong_board = nil;
    self.m_node_playerInfo = nil;
    self.m_node_playerimage = nil;
    self.m_playerInfo = nil;
    self.m_describeInfo = nil;
    self.m_pyramidInfo = nil;
    self.m_gameData = nil;
    self.m_callFun = nil;
end
--[[--
    返回
]]
function ui_small_playerinfo_pop.back(self,backType)
    game_scene:removePopByName("ui_small_playerinfo_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_small_playerinfo_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 101 then  -- 挑战
            if type(self.m_callFun) == "function" then
                self.m_callFun( "fight", function (  )
                    self:back()
                end )
            end
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_small_playerinfo_pop.ccbi");

    self.m_node_playerInfo = ccbNode:nodeForName("m_node_playerInfo")
    self.m_node_zhenrong_board = ccbNode:nodeForName("m_node_zhenrong_board")
    self.m_node_playerimage = ccbNode:nodeForName("m_node_playerimage")


    -- 本层阻止触摸传导下一层
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    -- local function onTouch(eventType, x, y)     
    --     if eventType == "began" then 
    --         local realPos = self.m_node_rewards:getParent():convertToNodeSpace(ccp(x,y));
    --         if self.m_node_rewards:boundingBox():containsPoint(realPos) then
    --             return false;
    --         end
    --         return true;  
    --     end 
    -- end
    -- m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-8,true);
    -- m_root_layer:setTouchEnabled(true);

    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    local layer = CCLayer:create()
    layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-6,true);
    layer:setTouchEnabled(true);
    m_root_layer:addChild(layer)

    -- 重置按钮出米优先级 防止被阻止
    local m_btn_close = ccbNode:controlButtonForName("m_btn_close");
    m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);

    local m_btn_tiaozhan = ccbNode:controlButtonForName("m_btn_tiaozhan")
    m_btn_tiaozhan:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 8);

    local myFloor = tonumber(self.m_pyramidInfo.myFloor)
    local curFloor = tonumber(self.m_pyramidInfo.lookFloor)
    local pos = self.m_playerInfo.pos

    if myFloor == 0 then myFloor = 21 end
    if curFloor < myFloor - 1 then
        m_btn_tiaozhan:setVisible(false)
    end
    return ccbNode;
end

--[[
    创建玩家信息列表
]]
function ui_small_playerinfo_pop.createDetailInfoTableInfo( self, viewSize )
    local showData = self.m_describeInfo
    -- cclog2(showData, "showData   ====  ")
    local tempCount = #showData
    local params = {};
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tempCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.viewSize = viewSize;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_small_playerinfo_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            local itemData = showData[index + 1]
            if ccbNode then 
                local m_spr_title = ccbNode:spriteForName("m_spr_title")
                local m_label_infovalue = ccbNode:labelTTFForName("m_label_infovalue")
                
                if m_spr_title then
                    local titleSprName = itemData.titleSprName
                    local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(titleSprName)
                    if tempFrame then
                        m_spr_title:setDisplayFrame(tempFrame)
                    end
                end
                if m_label_infovalue then
                    local value = itemData.value 
                    m_label_infovalue:setString(value and tostring(value) or "")
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        
        end
    end
    local tableView = TableViewHelper:create(params);
    if tableView and tempCount <= params.row then
        tableView:setMoveFlag(false)
    end
    return tableView
end

--[[
    创建横奖励列表
]]
function ui_small_playerinfo_pop.createTableView( self, viewSize )
    local showData = {{},{},{},{},{},{}}
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5; --列
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-7;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local sprBoard = CCSprite:createWithSpriteFrameName("pb_kuang.png")
            if sprBoard then
                sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.6)
                node:addChild(sprBoard, 20, 20)
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = rewardList:getNodeAt(index)
            if itemData then
                game_util:lookItemDetal( json.decode(itemData:getFormatBuffer()) )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    local tableView =  TableViewHelper:create(params);
    if tableView then
        viewBoard:addChild(tableView)
    end
end

--[[--
    刷新ui
]]
function ui_small_playerinfo_pop.refreshUi(self)
    self.m_node_playerInfo:removeAllChildrenWithCleanup(true)
    local playerInfoTableView = self:createDetailInfoTableInfo(self.m_node_playerInfo:getContentSize())
    if playerInfoTableView then
        self.m_node_playerInfo:addChild(playerInfoTableView, 0, 887)
    end

    -- self.m_node_rewards:removeAllChildrenWithCleanup(true)
    -- local tableView = self:createTableView( self.m_node_rewards, self.m_curLevel_reward)
    -- if tableView then
    --     self.m_node_rewards:addChild(tableView)
    -- end
    local roleId = self.m_gameData.role or math.random(1, 5)
    local img = self:createBigImg(roleId)
    img:setAnchorPoint(ccp(0.5, 0))
    img:setPositionX(self.m_node_playerimage:getContentSize().width * 0.5)
    img:setScale(0.4)
    self.m_node_playerimage:addChild(img)
    self.m_node_zhenrong_board:removeAllChildrenWithCleanup(true)
    local formatTableView = self:creatFormatTableView(self.m_node_zhenrong_board:getContentSize())
    if formatTableView then
        self.m_node_zhenrong_board:addChild(formatTableView, 0, 887)
    end
end

--[[--
    创建列表
]]
function ui_small_playerinfo_pop.creatFormatTableView( self, viewSize )

    local character_detail_cfg = getConfig("character_detail");
    local heroCfg = nil
    local showData = self.m_gameData.alignment_info 

    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 8;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
        end
        if cell then  
            cell:removeAllChildrenWithCleanup(true)
            local itemData = showData[index + 1]
            if itemData and itemData.c_id then
                heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
                if itemData and heroCfg then
                    headIconSpr = game_util:createCardIconByCfg(heroCfg);
                    if headIconSpr then
                        headIconSpr:setScale(0.8);
                        headIconSpr:setPosition(itemSize.width * 0.5, itemSize.height * 0.5);
                        cell:addChild(headIconSpr,1,1);

                        local node = headIconSpr:getChildByTag(1)
                        if node then
                            node:setVisible(false)
                        end

                        local sprBoard = CCSprite:createWithSpriteFrameName("ui_pyramid_n_kuang3.png")
                        if sprBoard then
                            sprBoard:setPosition(itemSize.width * 0.5, itemSize.height * 0.5)
                            sprBoard:setScale(0.8);
                            cell:addChild(sprBoard, 20, 20)
                        end
                    end
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            local itemData = showData[index + 1]
            if itemData then
                game_scene:addPop("game_hero_info_pop",{tGameData = itemData,openType = 3})
            end
        end
    end
    return TableViewHelper:create(params)
end

--[[
    创建玩家大图
]]
function ui_small_playerinfo_pop.createBigImg(self, roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return game_util:createPlayerBigImgByCfg(itemCfg);
end

--[[
    格式化一些数据
]]
function ui_small_playerinfo_pop.formatData( self )
    local infoExt = {}
    infoExt[1] = {key = "name", sprName = "ui_smallplayer_wanjiamingcheng.png"}
    infoExt[2] = {key = "server", sprName = "ui_smallplayer_qufu.png"}
    infoExt[3] = {key = "level", sprName = "ui_smallplayer_dengji.png"}
    infoExt[4] = {key = "combat", sprName = "ui_smallplayer_zhandouli.png"}
    infoExt[5] = {key = "guild", sprName = "ui_smallplayer_own_guide.png"}
    infoExt[6] = {key = "morale", sprName = "ui_smallplayer_own_morale.png"}

    self.m_describeInfo = {}
    for kk,vv in pairs(infoExt) do
        local data = nil
        local k = vv["key"]
        local v = vv["sprName"]
        if self.m_playerInfo.data[k] then
            data = {key = k, titleSprName = v, value = self.m_playerInfo.data[k]}
        else
            -- table.insert(self.m_describeInfo, {key = k, titleSprName = infoExt[k], value = "顶顶大名"})
        end
        if self.m_gameData[k] then
            data = {key = k, titleSprName = v, value = self.m_gameData[k]}
        end
        if data then 
            table.insert(self.m_describeInfo, data) 
        end
    end
end

--[[--
    初始化
]]
function ui_small_playerinfo_pop.init(self,t_params)
    t_params = t_params or {}
    self.m_playerInfo = t_params.playerInfo
    self.m_pyramidInfo = t_params.pyramidInfo
    self.m_callFun = t_params.callFun
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
    self:formatData()
end

--[[--
    创建ui入口并初始化数据
]]
function ui_small_playerinfo_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_small_playerinfo_pop;
