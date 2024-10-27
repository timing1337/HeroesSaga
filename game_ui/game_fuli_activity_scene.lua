---  福利 
    -- 子模块
    -- 公告 签到 月卡 在线领奖 等级领奖 地图领奖 竞技场领奖 邀请码 师徒奖励
local game_fuli_activity_scene = {
    m_node_titlesboard = nil,
    m_node_contentboard = nil,

    m_node_titlelist_board = nil,

    m_cur_selectitem_index = nil,
    m_cur_selectcell = nil,

    m_fuli_tableview = nil,
    m_cellSize = nil,
    m_cellCount = nil,

    m_showContentViewUI = nil,

    m_awardData = nil;
    m_comeInTips = nil,
    m_showtabs = nil,
    m_root_layer = nil,
    m_screenShoot = nil,
    m_curShowTabName = nil,         -- 当前显示的标签
    m_guide_cell = nil,
    m_guide_index = nil,
}

--[[--
    销毁ui
]]
function game_fuli_activity_scene.destroy(self)
    -- body
    cclog("----------------- game_fuli_activity_scene destroy-----------------"); 
    self.m_node_titlesboard = nil;
    self.m_node_contentboard = nil;
    self.m_node_titlelist_board = nil;
    self.m_cur_selectitem_index = nil;
    self.m_cur_selectcell = nil;
    self.m_fuli_tableview = nil;
    self.m_cellSize = nil;
    self.m_cellCount = nil;
    self.m_showContentViewUI = nil;
    self.m_awardData = nil;
    self.m_comeInTips = nil;
    self.m_showtabs = nil;
    self.m_root_layer = nil;
    self.m_screenShoot = nil;
    self.m_curShowTabName = nil;
    self.m_guide_cell = nil;
    self.m_guide_index = nil;
end
--[[--
    返回
]]
function game_fuli_activity_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_activity_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then -- 右边按钮
            local size = self.m_fuli_tableview:getViewSize()
            local curOffset = self.m_fuli_tableview:getContentOffset()
            local width = self.m_cellCount * self.m_cellSize.width
            if curOffset.x > -1 * (width - size.width) then
                self.m_fuli_tableview:setContentOffset(ccp(  math.max(curOffset.x - self.m_cellSize.width, -1 * (width - size.width))  , 0), true);
            end
        elseif btnTag == 3 then -- 左边按钮
            local size = self.m_fuli_tableview:getViewSize()
            local curOffset = self.m_fuli_tableview:getContentOffset()
            local width = self.m_cellCount * self.m_cellSize.width
            if curOffset.x < 0 then
                self.m_fuli_tableview:setContentOffset(ccp(  math.min(curOffset.x + self.m_cellSize.width, 0), 0), true);
            end
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_activity_pop.ccbi");
    self.m_node_contentboard = ccbNode:nodeForName("m_node_contentboard")
    self.m_node_titlesboard = ccbNode:nodeForName("m_node_titlesboard")
    self.m_node_titlelist_board = ccbNode:nodeForName("m_node_titlelist_board")
    
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
         if eventType == "began" then 
            local realPos = self.m_node_contentboard:getParent():convertToNodeSpace(ccp(x,y));
            if self.m_node_contentboard:boundingBox():containsPoint(realPos) then
                -- cclog2( "点在子UI界面上面 -- " )
                return false;
            end
            return true;  
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 2,true);
    self.m_root_layer:setTouchEnabled(true);

    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition( tempSize.width*0.5, tempSize.height*0.5 );
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    -- 重置按钮出米优先级 防止被阻止
    local m_conbtn_left = ccbNode:controlButtonForName("m_conbtn_left")
    local m_conbtn_right = ccbNode:controlButtonForName("m_conbtn_right")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3 );
    m_conbtn_right:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3 );
    m_conbtn_left:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 3 );
    return ccbNode;
end

local testData = {}
testData["announce"] = {sort = 1, name = "announce", img = "ui_fuli_huadongtiao_gonggao.png", createfunName = "createAnnouncementUI", InReviewID = 11, isVisible = true }
testData["sign"] = {sort = 2, name = "sign", img = "ui_fuli_huadongtiao_qiandao.png" , createfunName = "createDailySignUI" , InReviewID = 9, isVisible = true }
testData["monthvip"] = {sort = 3, name = "monthvip", img = "ui_fuli_monthvip.png" , createfunName = "createMonthvipUI" , InReviewID = 126, isVisible = true }
testData["liveres"] = {sort = 4, name = "liveres", img = "ui_fuli_huadongtiao_shengcunwuzi.png" , createfunName = "createLiveResUI" , InReviewID = 49, isVisible = true  }
testData["online"] = {sort = 5, name = "online", img = "ui_fuli_huadongtiao_zaixianjiangli.png" , createfunName = "createAwardUI" , InReviewID = 8, isVisible = true  }
testData["level"] = {sort = 6, name = "level", img = "ui_fuli_huadongtiao_dengjijiangli.png" , createfunName = "createAwardUI" , InReviewID = 50, isVisible = true  }
testData["advanture"] = {sort = 7, name = "advanture", img = "ui_fuli_huadongtiao_guanqiajiangli.png" , createfunName = "createAwardUI" , InReviewID = 51, isVisible = true  }
testData["arena"] = {sort = 8, name = "arena", img = "ui_fuli_huadongtiao_jingjijiangli.png" , createfunName = "createAwardUI" , InReviewID = 5, isVisible = true  }
testData["activity_code"] = {sort = 9, name = "activity_code", img = "ui_fuli_huadongtiao_libaoduihuan.png" , createfunName = "createActivitionUI" , InReviewID = 37, isVisible = true  }
testData["invite_code"] = {sort = 10, name = "invite_code", img = "ui_fuli_huadongtiao_yaoqingma.png" , createfunName = "createInviteCodeUI" , InReviewID = 41, isVisible = true  }
testData["comeback"] = {sort = 11, name = "comeback", img = "ui_fuli_huadongtiao_comeback.png" , createfunName = "createComeBackUI" , InReviewID = 142, isVisible = true, reCreate = true  }

--[[--
    创建列表
]]
function game_fuli_activity_scene.createChallangeList( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
    end
    local showData = self.m_showtabs
    local itemCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 5;
    params.direction = kCCScrollViewDirectionHorizontal;
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
            ccbNode:openCCBFile("ccb/ui_fuli_title_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  

            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")   
            if ccbNode then 
                local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
                local m_sprite_title = ccbNode:spriteForName("m_sprite_title")
                if self.m_cur_selectitem_index == index then
                    self.m_cur_selectcell = cell
                    local name = showData[index + 1].name
                    self.m_comeInTips[name] = false 
                end

                if self.m_cur_selectitem_index == index and m_scale9sprite_select then
                    m_scale9sprite_select:setVisible(true)
                elseif m_scale9sprite_select then
                    m_scale9sprite_select:setVisible(false)
                end 
                if self.m_guide_index == index then         -- 引导cell
                    self.m_guide_cell = ccbNode
                end
                local titleSpriteName = showData[index + 1].img or ""
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( titleSpriteName )
                if m_sprite_title and frame then
                    m_sprite_title:setDisplayFrame( frame )
                end

                local name = showData[index + 1].name
                if self.m_comeInTips[name] == true then
                    local tips_reward = game_util:addTipsAnimByType(ccbNode , 10)
                    tips_reward:setPositionX( ccbNode:getContentSize().width * 0.8)
                else
                    ccbNode:removeChildByTag(1000,true)
                end

            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" then
            cclog2("click table cell index === " .. tostring(index))
            local name = showData[index + 1].name
            self.m_comeInTips[name] = false 
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")  
            ccbNode:removeChildByTag(1000,true)
            self:selectCellState(cell, index)
            self:respondCellSelect( self.m_showtabs[index + 1] )
        end
    end
    return TableViewHelper:create(params)
end

--[[
    设置cell的状态 选中、非选中
]]
function game_fuli_activity_scene.selectCellState( self, cell , index)
    -- cclog2(cell, "cell   ===   ")
    -- cclog2(index, "index   ===   ")
    -- cclog2(self.m_cur_selectitem_index, "self.m_cur_selectitem_index   ===   ")
    -- cclog2(self.m_cur_selectcell, "self.m_cur_selectcell   ===   ")
    if index == self.m_cur_selectitem_index then return end
    self.m_cur_selectitem_index = index
    if self.m_cur_selectcell then 
        local ccbNode = tolua.cast(self.m_cur_selectcell:getChildByTag(10),"luaCCBNode")   
        if ccbNode then 
            local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
            if m_scale9sprite_select then
                m_scale9sprite_select:setVisible(false)
            end
        end
    end
    if cell then
        local ccbNode = tolua.cast( cell:getChildByTag(10),"luaCCBNode" )   
        if ccbNode then 
            local m_scale9sprite_select = ccbNode:scale9SpriteForName("m_scale9sprite_select")
            if m_scale9sprite_select then
                m_scale9sprite_select:setVisible(true)
            end
        end
        self.m_cur_selectcell = cell
    end
end

--[[
    选中福利的状态
]]
function game_fuli_activity_scene.respondCellSelect( self, uiInfo )
    -- cclog2(uiInfo, " uiInfo  ===  ")
    for k,v in pairs(self.m_showContentViewUI) do
        local info = testData[k] or {}
        if v and uiInfo.name ~= k and info.reCreate == true  then
            v:removeAllChildrenWithCleanup(true)
            self.m_showContentViewUI[k] = nil
        else
            v:setPositionY( -1000 )
            v:setVisible(false)
        end
    end
    if self.m_showContentViewUI[ uiInfo.name ] then
        self.m_showContentViewUI[ uiInfo.name ]:setVisible(true)
        self.m_showContentViewUI[ uiInfo.name ]:setPositionY( 0 )
    else
        local createfunName = uiInfo.createfunName
        cclog2(game_fuli_activity_scene[createfunName], "game_fuli_activity_scene[createfunName] === ")
        if type(game_fuli_activity_scene[createfunName]) == "function" then
            game_fuli_activity_scene[uiInfo.createfunName](self, uiInfo.name, uiInfo.name )
        else
            -- assert(false)
        end
    end
    self.m_curShowTabName = uiInfo
end

--[[
    创建签到页面
]]
function game_fuli_activity_scene.createDailySignUI( self, key )
    cclog2(key, "createDailySignUI   ===  and  key  === ")
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog2(data, "data =====  ")
        game_data:setDailyAwardDataByJsonData(data);
        local m_show_tpye = 2
        if game_data:getAlertsDataByKey("daily") then
            m_show_tpye = 1
        end
        local coin_days = data:getNodeWithKey("coin_days"):toInt()
        local coin_status = data:getNodeWithKey("coin_status"):toInt()
        local coin_pay_rmb = data:getNodeWithKey("coin_pay_rmb"):toInt()
        local daily_award_loop = data:getNodeWithKey("daily_award_loop")
        if daily_award_loop then
            daily_award_loop = daily_award_loop:toBool()
        end
        local coin_award_loop = data:getNodeWithKey("coin_award_loop")
        if coin_award_loop then
            coin_award_loop = coin_award_loop:toBool()
        end
        local coin_award_loop_reriod = data:getNodeWithKey("coin_award_loop_reriod")
        if coin_award_loop_reriod then
            coin_award_loop_reriod = coin_award_loop_reriod:toInt()
        end
        local ui = self:createContentUI( "game_fuli_subui_dailysign", {coin_status = coin_status,
            coin_days = coin_days,m_show_tpye = m_show_tpye,coin_pay_rmb = coin_pay_rmb,
            daily_award_loop = daily_award_loop,coin_award_loop = coin_award_loop,coin_award_loop_reriod = coin_award_loop_reriod})
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("daily_award_all_reward"), http_request_method.GET, nil,"daily_award_all_reward")
end

--[[
    创建月卡页面
]]
function game_fuli_activity_scene.createMonthvipUI( self, key )
    local function responseMethod(tag,gameData)
        local ui = self:createContentUI( "game_fuli_subi_monthvip_pop", {gameData = gameData} )
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pay_award_index"), http_request_method.GET, {tp="month"},"pay_award_index")
end

--[[
    创建礼包领取页面
]]
function game_fuli_activity_scene.createActivitionUI( self, key )
    local ui = self:createContentUI( "game_fuli_subui_activation" )
    self.m_showContentViewUI[key] = ui
    self.m_node_contentboard:addChild(ui)
end

--[[
    创建生存物资领取页面
]]
function game_fuli_activity_scene.createLiveResUI( self, key )
    local function responseMethod(tag,gameData)
        local ui = self:createContentUI( "game_fuli_subui_liveres" , {gameData = gameData})
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end

--[[
    创建王者归来活动
]]
function game_fuli_activity_scene.createComeBackUI( self, key )
    local function responseMethod(tag,gameData)
        local ui = self:createContentUI( "game_fuli_subui_comeback" , {gameData = gameData})
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("king_show_reward_interface"), http_request_method.GET, nil,"king_show_reward_interface")
end

--[[
    创建师徒奖励领取页面
]]
function game_fuli_activity_scene.createInviteCodeUI( self, key )
    local function responseMethod(tag,gameData)
        local ui = self:createContentUI( "game_fuli_subui_invitecode" , {gameData = gameData})
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_request_code_index"), http_request_method.GET, nil,"user_request_code_index")
end

--[[
    创建公告页面
]]
function game_fuli_activity_scene.createAnnouncementUI( self, key )
    local ui = self:createContentUI( "game_fuli_subui_annoucement" )
    self.m_showContentViewUI[key] = ui
    self.m_node_contentboard:addChild(ui)
end

--[[
    创建领奖页面
]]
function game_fuli_activity_scene.createAwardUI( self, key , openType)
    -- cclog2()
    if self.m_awardData then
        local ui = self:createContentUI( "game_fuli_subui_award" , {gameData = self.m_awardData , openType = openType, parentCloseBtn = self.m_close_btn})
        self.m_showContentViewUI[key] = ui
        self.m_node_contentboard:addChild(ui)
        self.m_awardData = nil
    else    
        local function responseMethod(tag,gameData)
            local ui = self:createContentUI( "game_fuli_subui_award" , {gameData = gameData , openType = openType, parentCloseBtn = self.m_close_btn})
            self.m_showContentViewUI[key] = ui
            self.m_node_contentboard:addChild(ui) 
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_once_index"), http_request_method.GET, nil,"reward_once_index")
    end

end

--[[
    创建一个UI
]]
function game_fuli_activity_scene.createContentUI( self, name, params)
    local ui_content = require("game_pop." .. name)
    ui = ui_content:create( params )
    return ui
end

--[[--
    刷新ui
]]
function game_fuli_activity_scene.refreshUi( self )
    local showData = nil
    local index = nil
    for k,v in ipairs(self.m_showtabs) do
        if v.name then
            if self.m_comeInTips[v.name] == true then
                showData = v
                index = k
                break
            end
        end
    end

    index = index and index - 1 or 0
    self.m_cur_selectitem_index = index
    self.m_node_titlelist_board:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_node_titlelist_board:getContentSize())
    self.m_fuli_tableview = view
    self.m_node_titlelist_board:addChild(view)
    self:refreshTableViewShowPos( index )
   
    showData = showData or self.m_showtabs[1]
    -- cclog2(showData, "showData ====  ")
    if showData then
        self:respondCellSelect( showData )
    end
    self.m_awardData = nil
end

--[[
    根据显示cell index
]]

function game_fuli_activity_scene.refreshTableViewShowPos( self, index, animate )
    index = index or 0
    if animate ~= false then animate = true end
    local size = self.m_fuli_tableview:getViewSize()
    local width = self.m_cellCount * self.m_cellSize.width
    local curOffset = self.m_fuli_tableview:getContentOffset()
    local bgsize = self.m_fuli_tableview:getContentSize()
    if index > 4 then
        self.m_fuli_tableview:setContentOffset(ccp(math.max( curOffset.x - self.m_cellSize.width * math.max(index - 3, 0) , size.width - bgsize.width), 0), animate);
    end
end

function game_fuli_activity_scene.resetCell( self )
    local tip = ""
    if game_data:getAlertsDataByKey("daily") == true and game_data:isViewOpenByID( 9 ) then  -- 签到
        self.m_comeInTips.sign = true
    end

    if game_data:getAlertsDataByKey("active") == 1 and game_data:isViewOpenByID( 49 ) then--活动
        self.m_comeInTips.liveres = true
    end
    -- if game_data:getAlertsDataByKey("once") == true then--领奖   或在线领奖

    -- end
    if game_data:getAlertsDataByKey("month") and game_data:isViewOpenByID( 126 ) then--活动
        self.m_comeInTips.monthvip = true
    end
end


--[[--
    初始化
]]
function game_fuli_activity_scene.init(self,t_params)
    self.m_screenShoot = t_params.screenShoot
    self.m_showtabs = {}
    for i,v in pairs(testData) do
        if v and v.isVisible then
            if game_data:isViewOpenByID( v.InReviewID ) then
                table.insert(self.m_showtabs, v)
            end
        end
    end
    local sortFun = function ( data1, data2 )
        return data1.sort < data2.sort
    end
    table.sort(self.m_showtabs, sortFun)

    t_params = t_params or {}
    self.m_cur_selectitem_index = 0
    self.m_showContentViewUI = {};

    self.m_awardData = t_params.awardData

    local needData = {}
    if t_params.awardData ~= nil and tolua.type(t_params.awardData) == "util_json" then
        local temp = json.decode(t_params.awardData:getNodeWithKey("data"):getFormatBuffer())
        needData = temp
    end
    -- cclog2(needData, "needData  ==  ")
    local result = needData.once.result

    local onceCfg = getConfig(game_config_field.reward_once); 
    local onceData = onceCfg and json.decode(onceCfg:getFormatBuffer()) or {}
    local maxCount = onceCfg:getNodeCount()

    local showType = {online = false, level = false, advanture = false, arena = false}
    self.m_comeInTips = {online = false, level = false, advanture = false, arena = false}
    -- 获取online奖励列表
    for i = 1, maxCount do
        --先遍历出1000+的再遍历出2000+的以此类推
        local oneitem = onceCfg:getNodeAt(tostring( i - 1 ))
        local key = oneitem:getKey() or ""
        local cid = tonumber(key)

        local itemData = json.decode(oneitem:getFormatBuffer())
        local item = result[ tostring(cid) ]
        if item and tonumber(key) <= 1000 then
            if item[3] ~= 2 then showType.online = true  end
            if item[3] == 1 then self.m_comeInTips.online = true  end
        elseif item and tonumber(key) > 1000 and tonumber(key) < 2000 then
            if item[3] ~= 2 then showType.level = true  end
            if item[3] == 1 then self.m_comeInTips.level = true  end
        elseif item and  tonumber(key) > 2000 and tonumber(key) < 3000 then
            if item[3] ~= 2 then showType.advanture = true  end
            if item[3] == 1 then self.m_comeInTips.advanture = true  end
        elseif item and  tonumber(key) > 3000 and tonumber(key) < 4000 then
            if item[3] ~= 2 then showType.arena = true  end
            if item[3] == 1 then self.m_comeInTips.arena = true  end
        end
    end
    cclog2(showType, "showType  ==  ")
    local ids = {}
    for kd,info in pairs( self.m_showtabs ) do
        for i,v in pairs(showType) do
            if v == false and info.name == i then
                ids[#ids + 1] = kd
            end
        end
    end
    cclog2(ids, "ids  ==  ")
    local count = #ids
    for i=1, count do
        table.remove(self.m_showtabs, ids[count - i + 1])
    end
    self:resetCell()
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_activity_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    -- self:guideHelper()
    local id = game_guide_controller:getIdByTeam("7");
    print("game_guide_controller:getIdByTeam(7)", id)
    -- id = 703
    if id == 703 then
        -- self:gameGuide("show","7", 703)
        for k,v in pairs(self.m_comeInTips ) do
            self.m_comeInTips[k] = false
        end
        self.m_comeInTips["level"] = true
    end
    self:refreshUi();
    return scene;
end



-- --[[
--     -- 本场景新手引导入口
-- ]]
-- function game_fuli_activity_scene.forceGuideFun( self, forceInfo )
--     if forceInfo and forceInfo.game_fuli_activity_scene then
--         game_data:setForceGuideInfo( forceInfo )
--         local guideInfo = forceInfo.game_fuli_activity_scene
--         local tipsName = guideInfo.tipsName
--         if self.m_curShowTabName ~= tipsName then  -- 当前显示的不是引导的页面 
--             for k,v in ipairs(self.m_showtabs) do
--                 if v.name == tipsName then
--                     self.m_guide_index = math.max(tonumber(k) - 1, 0)
--                 end
--             end
--             self:refreshUi()
--             cclog2(self.m_guide_index, "self.m_guide_index   ===  ")
--             self:refreshTableViewShowPos( self.m_guide_index , false )
--             if self.m_guide_cell then
--                 local t_params = {}
--                 t_params.tempNode = self.m_guide_cell
--                 t_params.clickCallFunc = function (  )
--                     -- cclog2("click")
--                     game_scene:removeGuidePop()
--                 end
--                 t_params.skipFunc = function (  )
--                     if type(forceInfo.guideEndfun) == "function" then
--                         forceInfo.guideEndfun( forceInfo.guide_team )
--                     end
--                 end
--                 game_scene:addGuidePop( t_params )
--             end
--         end
--     end
-- end

-- --[[
--     检查时候需要新手引导
-- ]]
-- function game_fuli_activity_scene.guideHelper( self )
--     -- cclog2("player_level_up_pop  guideHelper  ======  ")
--     local force_guide = game_data:getForceGuideInfo()
--     -- cclog2(force_guide, "force_guide   ======  ")
--     if type(force_guide) == "table" and force_guide.game_fuli_activity_scene then
--         self:forceGuideFun( force_guide )
--         return true
--     end
--     return false
-- end



return game_fuli_activity_scene