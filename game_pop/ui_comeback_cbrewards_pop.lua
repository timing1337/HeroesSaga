--- 老玩家信息
local ui_comeback_cbrewards_pop = {
    m_ccbNode = nil;
    m_callBack = nil;
    m_gameData = nil;
};

--[[--
    销毁
]]
function ui_comeback_cbrewards_pop.destroy(self)
    -- body
    cclog("-----------------ui_comeback_cbrewards_pop destroy-----------------");
    self.m_ccbNode = nil;
    self.m_callBack = nil;
    self.m_gameData = nil;
end
--[[--
    返回
]]
function ui_comeback_cbrewards_pop.back(self,type)
    game_scene:removePopByName("ui_comeback_cbrewards_pop");
end
--[[--
    读取ccbi创建ui
]]
function ui_comeback_cbrewards_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        elseif btnTag == 101 then  -- 确认
            local function responseMethod(tag,gameData)
                -- cclog2(gameData, "gameData   =====   ")
                local data = gameData:getNodeWithKey("data")
                game_util:rewardTipsByJsonData(data:getNodeWithKey("gift"));
                if type(self.m_callBack) == "function" then
                    self.m_callBack( "refreshForMain" )
                end
                self:back()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_get_king_reward"), http_request_method.GET, nil,"king_get_king_reward")
        elseif btnTag == 102 then  -- 重新输入
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_comeback_getreward_pop.ccbi");

    local m_label_playername = ccbNode:labelTTFForName("m_label_playername")
    local m_label_playeruid = ccbNode:labelTTFForName("m_label_playeruid")

    local show_name = game_data:getUserStatusDataByKey("show_name") or ""
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    m_label_playername:setString(show_name)
    m_label_playeruid:setString("UID:" .. tostring(uid))

    local m_node_playericonboard = ccbNode:nodeForName("m_node_playericonboard")
    local role = game_data:getUserStatusDataByKey("role") or math.random(1, 5)
    local tempIcon = game_util:createPlayerIconByRoleId(role);
    if tempIcon then
        tempIcon:setScale(0.92);
        local tempSize = m_node_playericonboard:getContentSize();
        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_node_playericonboard:addChild(tempIcon)
    end

    -- 根据sort显示玩家奖励
    local sort = tonumber(game_data:getDataByKey("come_back_sort"))
    local reward = nil
    local m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")
    local player_recall_cfg = getConfig(game_config_field.player_recall)
    local player_recall_table = player_recall_cfg and json.decode(player_recall_cfg:getFormatBuffer()) or {}
    for i,v in pairs( player_recall_table ) do
        if type(v) == "table" then
            -- cclog2(v,"v   =======   ")
            if v.sort == sort then
                reward = v.reward
                break
            end
        end
    end
    self:createHoroRewardTableView(m_node_rewardboard, reward)


    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    local btn_ok = ccbNode:controlButtonForName("btn_ok")
    btn_ok:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11)
    
    return ccbNode;
end


--[[
    创建横奖励列表
]]
function ui_comeback_cbrewards_pop.createHoroRewardTableView( self, viewBoard, rewardList )
     if not rewardList then return end
    local showData = rewardList
    local viewSize = viewBoard:getContentSize()
    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.15)
    leftArrow:setPosition(ccp(-5,viewSize.height*0.5));
    viewBoard:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.15)
    rightArrow:setPosition(ccp(viewSize.width + 5,viewSize.height*0.5));
    viewBoard:addChild(rightArrow)

    leftArrow:setVisible(false)
    rightArrow:setVisible(false)
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5
    -- if tempCount < params.column then math.max(params.column - 1, 1) end
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-8;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    params.showPoint = false
    params.showPageIndex = 1
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
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)

                if icon and count then
                    countStr = "×" .. tostring(count)
                    local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 12})
                    label_count:setAnchorPoint(ccp(0.5,0.5))
                    label_count:setPosition(ccp(0,-20))
                    node:addChild(label_count,20)
                end
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showData[index + 1]
            if itemData then
                game_util:lookItemDetal( itemData )
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        if curPage == 1 then
            leftArrow:setVisible(false)
        else
            leftArrow:setVisible(true)
        end
        if curPage < totalPage then
            rightArrow:setVisible(true)
        else
            rightArrow:setVisible(false)
        end
    end
    local tableView =  TableViewHelper:createGallery2(params);
    if tableView then
        viewBoard:addChild(tableView)
    end
end





--[[--
    刷新ui
]]
function ui_comeback_cbrewards_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function ui_comeback_cbrewards_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = {}
    self.m_callBack = t_params.callBack
    local gameData = t_params.gameData
    local data = gameData and gameData:getNodeWithKey("data")
    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
end

--[[--
    创建ui入口并初始化数据
]]
function ui_comeback_cbrewards_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return ui_comeback_cbrewards_pop;