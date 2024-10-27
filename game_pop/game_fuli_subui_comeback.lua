---  王者归来 老玩家回归

local game_fuli_subui_comeback = {
    m_inputUid = nil,
    m_root_ccbNode = nil,
    m_curCCBNode = nil,
    m_node_invitlist = nil,
    m_tReward = nil,
    m_node_rewardall = nil,
}

--[[--
    销毁ui
]]
function game_fuli_subui_comeback.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_comeback destroy-----------------"); 
    self.m_inputUid = nil;
    self.m_root_ccbNode = nil;
    self.m_curCCBNode = nil;
    self.m_node_invitlist = nil;
    self.m_tReward = nil;
    sefl.m_node_rewardall = nil;
end
--[[--
    返回
]]
function game_fuli_subui_comeback.back(self,backType)
        self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_comeback.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_fuli_content_comeback_baord.ccbi");
    self.m_root_ccbNode = ccbNode

    return ccbNode
end

--[[
    创建初始化界面
]]
function game_fuli_subui_comeback.createComeInUi( self )

    local callBack = function ( backType )
        cclog2(backType, "callBack  backType   ====      ")
        if backType == "reInputUid" then
            local size = self.m_node_yaoqing_codebaord:getContentSize()
            self.m_editBox:setPosition(ccp(size.width * 0.5, size.height * 0.5))
        elseif backType == "refreshForMain" then
            self:refreshUi("main")
        elseif backType == "refreshUI" then
            self:refreshData()
            self:refreshUi()
        end
    end

    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press button tag is ", btnTag)
        if btnTag == 101 then --  我是邀请者
            -- game_scene:addPop("ui_comeback_cbrewards_pop", {gameData = gameData})
            self:refreshUi("main")
        elseif btnTag == 102 then  -- 我是被邀请者
            if self.m_gameData.king_badge == false or self.m_gameData.king_badge == 0 then
                game_util:addMoveTips({text = string_helper.game_fuli_subui_comeback.deny})
                return
            end
            self.m_node_firstcomein:setVisible(false)
            self.m_node_inputcode_board:setVisible(true)

        elseif btnTag == 201 then  -- 确认uid
            if self.m_inputUid == nil or  self.m_inputUid == "" then
                game_util:addMoveTips({text = string_helper.game_fuli_subui_comeback.inputUid});
                return;
            end
            local function responseMethod(tag,gameData)
                self.m_editBox:setPosition(ccp(-1000, 0))
                game_scene:addPop("ui_comeback_playerinfo_pop", {gameData = gameData, callBack = callBack})
            end
            local params = {}
            params.tid = tostring(util.url_encode(self.m_inputUid))
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_find_caller"), http_request_method.GET, params,"king_find_caller")
        elseif btnTag == 202 then  -- 直接领奖
            game_scene:addPop("ui_comeback_cbrewards_pop", {callBack = callBack})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_content_comeback.ccbi");
    self.m_node_firstcomein = ccbNode:nodeForName("m_node_firstcomein")
    self.m_node_inputcode_board = ccbNode:nodeForName("m_node_inputcode_board")

    -- 活动详情
    local m_node_detailinfoboard = ccbNode:nodeForName("m_node_detailinfoboard")
    m_node_detailinfoboard:removeAllChildrenWithCleanup(true)
    local labelSize = m_node_detailinfoboard:getContentSize()


    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = activeCfg:getNodeWithKey( "146" )
    local msg = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.game_fuli_subui_comeback.tip
    local node = self:createScrollLabel(CCSizeMake(labelSize.width - 10, labelSize.height - 5), {text = msg}, GLOBAL_TOUCH_PRIORITY - 7)
    if node then m_node_detailinfoboard:addChild(node) end

    -- 重置按钮出米优先级 防止被阻止
    function resetBtnTouchPriorityAndBMFont( ccbNode, btnName, touchPriority, isBMFont )
        if not ccbNode then return end
        local btn = ccbNode:controlButtonForName(btnName)
        if btn then
            btn:setTouchPriority( touchPriority )
            if isBMFont then
                game_util:setControlButtonTitleBMFont(btn)
            end
        end
    end
    resetBtnTouchPriorityAndBMFont(ccbNode, "m_btn_iamyaoqing", GLOBAL_TOUCH_PRIORITY - 6)
    resetBtnTouchPriorityAndBMFont(ccbNode, "m_btn_iambeyaoqing", GLOBAL_TOUCH_PRIORITY - 6)
    resetBtnTouchPriorityAndBMFont(ccbNode, "m_btn_inputcode_get", GLOBAL_TOUCH_PRIORITY - 6, true)
    resetBtnTouchPriorityAndBMFont(ccbNode, "m_btn_inputcode_ok", GLOBAL_TOUCH_PRIORITY - 6, true)

    --
    local isFirst = true
    self.m_node_firstcomein:setVisible( isFirst )
    self.m_node_inputcode_board:setVisible( not isFirst )
    if isFirst then   -- 选自己是邀请者还是被邀请者

    end

    self.m_node_yaoqing_codebaord = ccbNode:nodeForName("m_node_yaoqing_codebaord")
    
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_inputUid = edit:getText();
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_node_yaoqing_codebaord:getContentSize(),placeHolder=string_helper.game_fuli_subui_comeback.put,maxLength = 20,fontSize = 12});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_editBox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters);
    self.m_node_yaoqing_codebaord:addChild(self.m_editBox);

    return ccbNode
end

function game_fuli_subui_comeback.createScrollLabel( self, boardSize, params, touchPriority  )
    params = params or {}
    if not boardSize then return end
    local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    scrollView:setTouchEnabled(true)
    if touchPriority then scrollView:setTouchPriority(touchPriority ) end
    local text = params.text or ""
    local tempLabel = game_util:createRichLabelTTF({text = text,dimensions = CCSizeMake(boardSize.width  ,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    tempLabel:setAnchorPoint(ccp(0,0.99))
    tempLabel:setPosition(ccp(0, 0))
    scrollView:setContentSize(CCSizeMake(boardSize.width + 15, tempSize.height))
    scrollView:setContentOffset(ccp(0, boardSize.height - tempSize.height), false)
    scrollView:addChild(tempLabel, 0, 998)
    return scrollView
end

--[[
    创建主要界面
]]
function game_fuli_subui_comeback.createMainUI( self )
    
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("press button tag is ", btnTag)
        if btnTag == 101 then --  

        elseif btnTag == 401 then   -- 查看奖励
            local callBack = function ( endFun )
                local function responseMethod(tag,gameData)
                    if type(endFun) == "function" then
                        endFun()
                    end
                    self:refreshData(gameData)
                    self:refreshUi("main")
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_show_reward_interface"), http_request_method.GET, nil,"king_show_reward_interface")
            end

            local function responseMethod(tag,gameData)
                cclog2(gameData, "king   gameData  ===   ")
                game_scene:addPop("ui_comback_scorerewards_pop", {gameData = gameData, callBack = callBack})
            end
            local params = {}
            params.tid = tostring(util.url_encode(self.m_inputUid))
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_show_reward_total"), http_request_method.GET, params,"king_show_reward_total")
        elseif btnTag == 402 then   -- 查看详情
            game_scene:addPop("game_active_limit_detail_pop",{enterType = "148"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_content_comback2.ccbi");


    self.m_node_invitlist = ccbNode:nodeForName("m_node_invitlist")

    local m_node_playericonboard = ccbNode:nodeForName("m_node_playericonboard")
    local role = game_data:getUserStatusDataByKey("role") or math.random(1, 5)
    local tempIcon = game_util:createPlayerIconByRoleId(role);
    if tempIcon then
        tempIcon:setScale(0.75);
        local tempSize = m_node_playericonboard:getContentSize();
        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_node_playericonboard:addChild(tempIcon)
    end
    local m_label_playername = ccbNode:labelTTFForName("m_label_playername")
    local m_label_playeruid = ccbNode:labelTTFForName("m_label_playeruid")
    local show_name = game_data:getUserStatusDataByKey("show_name") or ""
    local uid = game_data:getUserStatusDataByKey("uid") or ""
    m_label_playername:setString(show_name)
    m_label_playeruid:setString("UID:" .. tostring(uid))

    local m_node_rewardall = ccbNode:nodeForName("m_node_rewardall")
    m_node_rewardall:setVisible(false)
    local m_node_moreinfo = ccbNode:nodeForName("m_node_moreinfo")
    m_node_moreinfo:setVisible(true)

    -- 可领取奖励数
    local m_label_cangetnum = ccbNode:labelTTFForName("m_label_cangetnum")
    m_label_cangetnum:setString(string_helper.game_fuli_subui_comeback.rewardTimes.. tostring(self.m_gameData.avail_reward_num))

    local maxScore = 100
    -- 奖励显示
    local rewards = nil
    local maxInfo = self.m_tReward[tostring(self.m_gameData.max_reward_id)]
    -- maxInfo = nil
    if maxInfo then
        maxScore = maxInfo.charge_num
        rewards = maxInfo.reward
        
        local m_node_showreward = ccbNode:nodeForName("m_node_showreward")
        self:addHorRewardTableView(m_node_showreward, rewards)

        -- 积分就爱那个李进度
        local m_label_nextscore = ccbNode:labelTTFForName("m_label_nextscore")
        local msg = ""
        msg = string_helper.game_fuli_subui_comeback.nextReward .. tostring(self.m_gameData.next_gift_need_score)
        m_label_nextscore:setString(msg)
        local m_node_jinduboard = ccbNode:nodeForName("m_node_jinduboard")
        local score = maxScore - self.m_gameData.next_gift_need_score
        cclog2(score, "score    =====   ")
        m_node_jinduboard:removeAllChildrenWithCleanup(true)
        local bar = ExtProgressTime:createWithFrameName("ui_comeback_JINDUITIAO1.png","ui_comeback_JINDUTIAO2.png");
        bar:setMaxValue(maxScore);
        bar:setCurValue( math.max(score - maxScore * 0.1, 0 ) ,false);
        bar:setCurValue(score ,true);
        m_node_jinduboard:addChild(bar)
        bar:setAnchorPoint(ccp(0.5, 0.5))
        bar:setPosition(ccp(m_node_jinduboard:getContentSize().width * 0.5, m_node_jinduboard:getContentSize().height * 0.5))
    else
        m_node_rewardall:setVisible(true)
        m_node_moreinfo:setVisible(false)
    end
    return ccbNode
end

--[[
    重置界面到 被邀请者界面
]]
function game_fuli_subui_comeback.refreshFirstUI( self )


end
--[[
    创建我邀请的人的信息
]]
function game_fuli_subui_comeback.createMyInvitePlayersTabelView( self, viewSize )
    local showData = self.m_gameData.feeder_list or {}
    local onHeadClickFun = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        local itemData = showData[btnTag + 1]
        local callBack = function ( endFun )
            local function responseMethod(tag,gameData)
                if type(endFun) == "function" then
                    endFun()
                end
                self:refreshData(gameData)
                self:refreshUi("main")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_show_reward_interface"), http_request_method.GET, nil,"king_show_reward_interface")
        end
        local function responseMethod(tag,gameData)
            game_scene:addPop("ui_comeback_oneplayer_reward_pop", {gameData = gameData, uid = itemData.uid, callBack = callBack})
        end
        local params = {}
        params.tid = tostring(itemData.uid)
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_show_reward_single"), http_request_method.GET, params,"king_show_reward_single")
    end
    local itemCount = math.max(#showData, 1)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1;
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 5;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    self.m_cellSize = itemSize
    self.m_cellCount = itemCount
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_fuli_comeback_invite_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local itemData = showData[index + 1]
                local m_node_icon = ccbNode:nodeForName("m_node_icon")
                local m_label_paynum = ccbNode:labelTTFForName("m_label_paynum")
                local m_label_name = ccbNode:labelTTFForName("m_label_name")
                local m_label_uid = ccbNode:labelTTFForName("m_label_uid")
                local m_node_btnboard = ccbNode:nodeForName("m_node_btnboard")
                local m_btn_getreward = ccbNode:controlButtonForName("m_btn_getreward")
                m_btn_getreward:setTag(index)

                if #showData > 0 then
                    local role = itemData.role or math.random(1, 5)
                    local tempIcon = game_util:createPlayerIconByRoleId(role);
                    if tempIcon then
                        tempIcon:setScale(0.75);
                        local tempSize = m_node_icon:getContentSize();
                        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                        m_node_icon:addChild(tempIcon)

                        -- 头像触摸事件
                        local button = game_util:createCCControlButton( "public_weapon.png","", onHeadClickFun)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(ccp(tempSize.width * 0.5, tempSize.height*  0.5))
                        button:setOpacity(0)
                        m_node_icon:addChild(button)
                        button:setTag( index )
                        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)
                    end

                    local name = itemData.name or string_helper.game_fuli_subui_comeback.mystic
                    m_label_name:setString(name)
                    local uid = itemData.uid or "h??????????"
                    m_label_uid:setString(uid)
                    local cost = itemData.score or "98981258"
                    m_label_paynum:setString(tostring(cost))

                    -- 按钮 
                    local isCanGet,  _ = game_util:valueInTeam( uid, self.m_gameData.avail_uid_list )   
                    if isCanGet then
                        game_util:setCCControlButtonBackground(m_btn_getreward, "ui_comeback_getreward1.png")
                    else
                        game_util:setCCControlButtonBackground(m_btn_getreward, "ui_comeback_getreward2.png")
                    end
                else
                    ccbNode:removeAllChildrenWithCleanup(true)
                    local tips = game_util:createLabelTTF({text = string_helper.game_fuli_subui_comeback.denyTips, fontSize = 12})
                    tips:setPosition(ccp(ccbNode:getContentSize().width * 0.5, ccbNode:getContentSize().height * 0.5))
                    ccbNode:addChild(tips)
                end
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
        end
    end
    local tableView = TableViewHelper:create(params)
    if tableView then
        tableView:setScrollBarVisible(false);
    end
    return tableView
end

--[[
    创建横奖励列表
]]
function game_fuli_subui_comeback.addHorRewardTableView( self, viewBoard, rewardList )
    if not rewardList then return end
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

    local showData = rewardList
    local tempCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = math.max(#showData, 3)
    params.totalItem = tempCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    params.direction = kCCScrollViewDirectionHorizontal;    --横向
    params.showPoint = false
    params.showPageIndex = 1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            cell:setContentSize(itemSize)
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local itemData = showData[index + 1]
            local icon,name,count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5))
                cell:addChild(icon,10)

                if icon and count then
                    countStr = "×" .. tostring(count)
                    local label_count = game_util:createLabelTTF({text = countStr,color = ccc3(255,255,255),fontSize = 8})
                    label_count:setAnchorPoint(ccp(1,0))
                    label_count:setPosition(ccp( itemSize.width,0))
                    cell:addChild(label_count,20)
                end
            end
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

--[[
    刷新我邀请的人的信息
]]
function game_fuli_subui_comeback.refreshMainUI( self )
    self.m_node_invitlist:removeAllChildrenWithCleanup(true)
    local tabelView = self:createMyInvitePlayersTabelView( self.m_node_invitlist:getContentSize() )
    if tabelView then
        self.m_node_invitlist:addChild(tabelView)
    end
end

--[[--
    刷新ui
]]
function game_fuli_subui_comeback.refreshUi(self, refreshType)
    self.m_root_ccbNode:removeAllChildrenWithCleanup(true)
    local tempNode = nil
    local fuli_data = game_data:getDataByKey("fuli_info") or {}
    if fuli_data.comeback_main == true or refreshType == "main" or (self.m_gameData.king_badge == 0 and #self.m_gameData.feeder_list > 0) or self.m_gameData.king_reward_stamp == true then
        tempNode = self:createMainUI()
        self:refreshMainUI()
    else
        tempNode = self:createComeInUi()
        if self.m_gameData.king_badge == 0 then
            game_data:setDataByKeyAndValue("fuli_info", {comeback_main = true})
        end
    end

    self.m_curCCBNode = tempNode
    self.m_root_ccbNode:addChild(tempNode, 10, 987)
end

--[[
    刷新数据
]]
function game_fuli_subui_comeback.refreshData( self, gameData )
    if gameData then
        self.m_gameData = {}
        local data = gameData and gameData:getNodeWithKey("data")
        self.m_gameData = data and json.decode(data:getFormatBuffer()) or {}
        if self.m_gameData.king_badge == false then self.m_gameData.king_badge = 0 end
        game_data:setDataByKeyAndValue("come_back_sort", self.m_gameData.king_badge)
    end
end

--[[
    格式化数据
]]
function game_fuli_subui_comeback.formatData( self )
    self.m_tReward = {}
    local recall_reward_cfg = getConfig(game_config_field.recall_reward)
    self.m_tReward = recall_reward_cfg and json.decode(recall_reward_cfg:getFormatBuffer()) or {}
end

--[[--
    初始化
]]
function game_fuli_subui_comeback.init(self,t_params)
    t_params = t_params or {}
    self:refreshData(t_params.gameData)
    self:formatData()
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_comeback.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_fuli_subui_comeback