---  仇人列表
cclog2 = cclog2 or function() end
local game_enemylist_scene = {
    m_enemyList = nil,
    m_node_enemylist = nil,

    m_tableView = nil,
    m_tableViewPosY = nil,
    m_openType = nil,
}

--[[--
    销毁ui
]]
function game_enemylist_scene.destroy(self)
    -- body
    cclog("----------------- game_enemylist_scene destroy-----------------"); 
    self.m_enemyList = nil;
    self.m_node_enemylist = nil;

    self.m_tableView = nil;
    self.m_tableViewPosY = nil;
    self.m_openType = nil;
end
--[[--
    返回
]]
function game_enemylist_scene.back(self,backType)
    if self.m_openType == "game_dart_main" then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_dart_main",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
    elseif self.m_openType == "open_door_main_scene" then
        game_scene:enterGameUi("open_door_main_scene")
    else
        local function responseMethod(tag,gameData)
            if gameData then
                game_scene:enterGameUi("game_pyramid_scene",{gameData = gameData,screenShoot = screenShoot, openData = {}});
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_index"), http_request_method.GET, nil,"pyramid_index")  
    end
end
--[[--
    读取ccbi创建ui
]]
function game_enemylist_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "pyramid index onMainBtnClick press button tag is ")
        if btnTag == 1 then -- 关闭
            self:back();
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_enemy_list.ccbi");
    self.m_node_enemylist = ccbNode:nodeForName("m_node_enemylist")


    return ccbNode;
end



--[[
    创建仇人列表
]]
function game_enemylist_scene.createTabelView( self, viewSize )
    local showData = self.m_enemyList or {}
    -- local showData = {{}, {}}
    -- cclog2(showData, "showData   ====  ")



    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local qianNum = math.floor(btnTag / 1000)
        local index = btnTag - qianNum * 1000
        local itemData = showData[index + 1]

        if btnTag >= 1000 and btnTag < 2000 then -- 金字塔
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_pyramid_tower_scene", {gameData = gameData, showLevelInfo = {floor = itemData.pyramid_floor, pos = itemData.pyramid_pos} })
            end
            local params = {}
            params.floor = itemData.pyramid_floor
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_go_fight"), http_request_method.GET, params,"pyramid_go_fight")
        elseif btnTag >= 2000 and btnTag < 3000 then  -- 时空虫洞
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_dart_main",{gameData = gameData});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
        elseif btnTag >= 3000 and btnTag < 4000 then  -- 删除敌人
            local function responseMethod(tag,gameData)
                table.remove(self.m_enemyList, index + 1)
                self:refreshUi()
            end
            local params = {enemy_id = itemData.uid}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_give_up_enemy"), http_request_method.GET, params,"enemy_give_up_enemy")
        elseif btnTag >= 4000 and btnTag < 5000 then  -- 关注
            local function responseMethod(tag,gameData)
                self.m_enemyList[index + 1].care = not self.m_enemyList[index + 1].care
                self:refreshUi()
            end
            local params = {enemy_id = itemData.uid}
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("enemy_care_enemy"), http_request_method.GET, params,"enemy_care_enemy")
        end
        if self.m_tableView then
            self.m_tableViewPosY = self.m_tableView:getContentOffset().y
        end
    end

    local function onHeadBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local itemData = showData[btnTag + 1]
        game_util:lookPlayerInfo(itemData and itemData.uid, true, 2);

    end

    local tempCount = #showData
    local params = {};
    params.row = 3;--行
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
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_enemy_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            local itemData = showData[index + 1]
            if ccbNode then 
                local itemData = showData[index + 1]
                local m_node_roleicon = ccbNode:nodeForName("m_node_roleicon")
                local m_node_chouhenvalue_board = ccbNode:nodeForName("m_node_chouhenvalue_board")
                local m_node_gunzhu_board = ccbNode:nodeForName("m_node_gunzhu_board")
                local m_node_statebtn_board = ccbNode:nodeForName("m_node_statebtn_board")
                local m_label_name = ccbNode:labelTTFForName("m_label_name")
                local m_btn_watch = ccbNode:controlButtonForName("m_btn_watch")
                local m_node_chouhenvalue_barboard = ccbNode:nodeForName("m_node_chouhenvalue_barboard")
                local m_label_chouhen_value = ccbNode:labelTTFForName("m_label_chouhen_value")
                m_btn_watch:setTag(4000 + index)


                -- 名字
                m_label_name:setString(itemData.name or "")

                -- 头像
                m_node_roleicon:removeAllChildrenWithCleanup(true)
                local iconBoardSize = m_node_roleicon:getContentSize()
                local role = itemData.role or math.random(1, 5) 
                local tempIcon = game_util:createPlayerIconByRoleId(role)
                if tempIcon then
                    tempIcon:setScale(0.8);
                    tempIcon:setPosition(ccp(iconBoardSize.width*0.5, iconBoardSize.height*0.5));
                    m_node_roleicon:addChild(tempIcon)

                    local button = game_util:createCCControlButton("public_weapon.png","",onHeadBtnClick)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPreferredSize(iconBoardSize)
                    button:setPosition(ccp(iconBoardSize.width*0.5, iconBoardSize.height* 0.5))
                    button:setOpacity(0)
                    m_node_roleicon:addChild(button)
                    button:setTag(index)

                end

                -- 仇恨值
                local curHatred = itemData.hatred or 0
                m_node_chouhenvalue_barboard:removeAllChildrenWithCleanup(true)
                local barBoardSize = m_node_chouhenvalue_barboard:getContentSize()
                
                local bar = ExtProgressTime:createWithFrameName("pb_alpha0_1X1.png", "ui_chouren_valuebar.png")
                bar:setPosition(ccp(barBoardSize.width * 0.5, barBoardSize.height * 0.5))
                bar:setAnchorPoint(ccp(0.5, 0.5))
                m_node_chouhenvalue_barboard:addChild(bar)
                bar:setMaxValue(100)
                -- bar:setCurValue(curHatred, false)
                bar:setCurValue(50, false)
                -- 仇恨值
                m_label_chouhen_value:setString(tostring(itemData.hatred))

                -- 敌人状态按钮
                local pos = {0.2, 0.5, 0.8}
                if itemData.care == false then
                    pos = {-1, -1, 0.8}
                end
                local sprName= {"space_goldtower.png", "space_guard.png", "space_delete.png"}
                local stateName = {"pyramid", "escort", "nothing"}
                local names = string_helper.game_enemylist_scene.name
                local boardSize = m_node_statebtn_board:getContentSize()
                m_node_statebtn_board:removeAllChildrenWithCleanup(true)
                for i=1, 3 do
                    if pos[i] and pos[i] ~= -1 then
                        local tempCCBNode = luaCCBNode:create();
                        tempCCBNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
                        tempCCBNode:openCCBFile("ccb/ui_enemy_btn_item.ccbi")
                        local m_btn_btn = tempCCBNode:controlButtonForName("m_btn_btn")
                        local rank_select = tempCCBNode:spriteForName("rank_select") 
                        if itemData[stateName[i]] == true then
                            rank_select:setVisible(true)
                        else
                            rank_select:setVisible(false)
                        end

                        local m_label_title = tempCCBNode:labelTTFForName("m_label_title")
                        m_label_title:setString( tostring(names[i]) )

                        game_util:setCCControlButtonBackground(m_btn_btn, sprName[i])
                        if m_btn_btn then
                            m_btn_btn:setTag(index + 1000 * i)
                        end
                        tempCCBNode:setScale(0.9)
                        tempCCBNode:setAnchorPoint(ccp(0.5, 0.5))
                        tempCCBNode:setPosition(ccp(boardSize.width * pos[i], boardSize.height * 0.5))
                        m_node_statebtn_board:addChild(tempCCBNode)
                    end
                end

                -- 关注状态
                if itemData.care == true then
                    game_util:setCCControlButtonBackground(m_btn_watch, "ui_chouren_watch.png")
                else
                    game_util:setCCControlButtonBackground(m_btn_watch, "ui_chouren_towatch.png")
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
    -- if tableView and tempCount <= params.row then
    --     tableView:setMoveFlag(false)
    -- end
    tableView:setScrollBarVisible(false);
    return tableView
end



--[[
    刷新数据
]]
function game_enemylist_scene.refreshData( self, gameData )
end



--[[--
    刷新ui
]]
function game_enemylist_scene.refreshUi( self )
    self.m_node_enemylist:removeAllChildrenWithCleanup(true)
    self.m_tableView = nil
    local tableview = self:createTabelView(self.m_node_enemylist:getContentSize())
    if tableview then 
        self.m_node_enemylist:addChild(tableview) 
        self.m_tableView = tableview
        if self.m_tableViewPosY then
            self.m_tableView:setContentOffset(ccp(0, self.m_tableViewPosY))
            self.m_tableViewPosY = nil
        end
    end
end

--[[
    格式化数据
]]
function game_enemylist_scene.formatData( self )
    self.m_enemyList = self.m_gameData.enemys or {}
end

--[[--
    初始化
]]
function game_enemylist_scene.init(self,t_params)
    t_params = t_params or {}
    local gameData = t_params.gameData

    local data = gameData and gameData:getNodeWithKey("data")

    self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}

    self:formatData()
    self.m_openType = t_params.openType or "";
end
--[[--
    创建ui入口并初始化数据
]]
function game_enemylist_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_enemylist_scene