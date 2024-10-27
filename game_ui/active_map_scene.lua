---  活动地图

local active_map_scene = {
    m_root_layer = nil,
    m_map_container_node = nil,
    m_selIndex = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_last_chapter = nil,
    m_last_city = nil,
    m_chapter_map_node = nil,
    m_draw_node = nil,
    m_playerAnimNode = nil,
    m_time_label = nil,
    m_number_label = nil,
    m_activeChapterId = nil,
    left_times_label = nil,
    cur_times = nil,
    fight_times = nil,

    active_step = nil,
    chapter_detail = nil,
    over_ground = nil,
    m_combat_label = nil,
    last_step_label = nil,
    last_node = nil,

    active_name = nil,--活动的名字，取配置了
    show_first = nil,--第一次显示的是第几关
    btn_giveup = nil,--放弃按钮
    level_limit_node = nil,--新增
    open_label = nil,
    m_node_needtips = nil,
};
local show_name = {
    string_helper.active_map_scene.show_name1,
    string_helper.active_map_scene.show_name2,
    string_helper.active_map_scene.show_name3,
    string_helper.active_map_scene.show_name4,
    string_helper.active_map_scene.show_name5,
}
--[[--
    销毁
]]
function active_map_scene.destroy(self)
    -- body
    cclog("-----------------active_map_scene destroy-----------------");
    self.m_root_layer = nil;
    self.m_map_container_node = nil;
    self.m_selIndex = nil;
    self.m_left_btn = nil;
    self.m_right_btn = nil;
    self.m_last_chapter = nil;
    self.m_last_city = nil;
    self.m_chapter_map_node = nil;
    self.m_draw_node = nil;
    self.m_playerAnimNode = nil;
    self.m_time_label = nil;
    self.m_number_label = nil;
    self.m_activeChapterId = nil;
    self.left_times_label = nil;
    self.cur_times = nil;
    self.fight_times = nil;
    self.active_step = nil;
    self.chapter_detail = nil;
    self.over_ground = nil;
    self.active_name = nil;
    self.show_first = nil;
    self.btn_giveup = nil;
    self.level_limit_node = nil;
    self.open_label = nil;
    self.m_node_needtips = nil;
end
--[[--
    返回
]]
function active_map_scene.back(self,type)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
end
--[[--
    读取ccbi创建ui
]]
function active_map_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--中立地图
            game_scene:enterGameUi("game_neutral_map",{gameData = nil});
            self:destroy();
        elseif btnTag == 3 then

        elseif btnTag == 101 then--向上翻页
            self.m_selIndex = math.max(self.m_selIndex - 1,1)
            -- self:refreshChapter()
            self:refreshUi()
        elseif btnTag == 102 then--下翻
            local active_chapter_cfg = getConfig(game_config_field.active_chapter);
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
            local active_detail = itemCfg:getNodeWithKey("active_detail");
            local count = active_detail:getNodeCount()
            self.m_selIndex = math.min(self.m_selIndex + 1,count)
            -- self:refreshChapter()
            self:refreshUi()
        elseif btnTag == 201 then--继续挑战
            local active_chapter_cfg = getConfig(game_config_field.active_chapter);
            local active_detail_cfg = getConfig(game_config_field.active_detail);
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
            local active_detail = itemCfg:getNodeWithKey("active_detail");
            local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
            -- game_data_statistics:enterActive({activeId = activeId})
            -- game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = self.over_ground+1});    
            self:enterActiveMapBuildingDetailScene({activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = self.over_ground+1});  
        elseif btnTag == 202 then--重新挑战
            local active_chapter_cfg = getConfig(game_config_field.active_chapter);
            local active_detail_cfg = getConfig(game_config_field.active_detail);
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
            local active_detail = itemCfg:getNodeWithKey("active_detail");
            local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
            local t_params = 
            {
                title = string_helper.active_map_scene.title1,
                okBtnCallBack = function(target,event)
                    game_data_statistics:enterActive({activeId = activeId})
                    -- game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});  
                    self:enterActiveMapBuildingDetailScene({activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});    
                    game_util:closeAlertView();
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_helper.active_map_scene.okBtnText,       --可缺省
                cancelBtnText = string_helper.active_map_scene.cancelBtnText,
                text = string_helper.active_map_scene.text1,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        elseif btnTag == 500 then--放弃
            local active_chapter_cfg = getConfig(game_config_field.active_chapter);
            local active_detail_cfg = getConfig(game_config_field.active_detail);
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
            local active_detail = itemCfg:getNodeWithKey("active_detail");
            local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
            local t_params = 
            {
                title = string_helper.active_map_scene.title2,
                okBtnCallBack = function(target,event)
                    params = params or {};
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data")
                        game_util:closeAlertView();
                        game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                            self:destroy();
                            game_util:addMoveTips({text = string_helper.active_map_scene.text2});
                        end});
                    end
                    local params = {};
                    params.chapter = self.m_activeChapterId
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("clear_fight_log"), http_request_method.GET, params,"clear_fight_log")
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_helper.active_map_scene.okBtnText2,       --可缺省
                cancelBtnText = string_helper.active_map_scene.cancelBtnText2,
                text = string_helper.active_map_scene.text3,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_active_map.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_map_container_node = ccbNode:scrollViewForName("m_map_container_node")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_chapter_map_node = ccbNode:nodeForName("m_chapter_map_node")
    self.m_time_label = ccbNode:labelTTFForName("m_time_label")
    self.m_number_label = ccbNode:labelTTFForName("m_number_label")
    self.left_times_label = ccbNode:labelTTFForName("left_times_label")

    self.left_times_label:setString(string_helper.active_map_scene.text4 .. (self.fight_times-self.cur_times) .. "/" .. self.fight_times)
    -------------- 活动 改 -----------------
    self.last_node = ccbNode:nodeForName("last_node")
    self.last_step_label = ccbNode:labelTTFForName("last_step_label")
    self.btn_continue = ccbNode:controlButtonForName("btn_continue")
    self.btn_restart = ccbNode:controlButtonForName("btn_restart")
    self.m_chapter_left_btn = ccbNode:controlButtonForName("m_chapter_left_btn")
    self.m_chapter_right_btn = ccbNode:controlButtonForName("m_chapter_right_btn")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    self.btn_giveup = ccbNode:controlButtonForName("btn_giveup")
    self.level_limit_node = ccbNode:nodeForName("level_limit_node")
    self.open_label = ccbNode:labelTTFForName("open_label")
    self.m_node_needtips = ccbNode:nodeForName("m_node_needtips")
    self.btn_giveup:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)

    game_util:setControlButtonTitleBMFont(self.btn_continue)
    game_util:setControlButtonTitleBMFont(self.btn_restart)

    game_util:setCCControlButtonTitle(self.btn_continue,string_helper.ccb.text42)
    game_util:setCCControlButtonTitle(self.btn_restart,string_helper.ccb.text43)
    return ccbNode;
end
--[[
    
]]
function active_map_scene.enterActiveMapBuildingDetailScene(self,params)
    params = params or {};
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        game_data:setDataByKeyAndValue("map_fight_and_enemy",json.decode(data:getFormatBuffer()));
        game_data_statistics:enterActive({activeId = params.activeId})
        game_scene:enterGameUi("active_map_building_detail_scene",params);    
    end
    local params2 = {};
    params2.chapter = params.activeChapterId
    params2.active_id = params.activeId
    params2.step_n = params.next_step
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_map_fight_and_enemy"), http_request_method.GET, params2,"active_map_fight_and_enemy")
end

--[[
    活动 改 2 添加滑动
]]
function active_map_scene.createChapterTableView(self,viewSize)
    local myLevel = game_data:getUserStatusDataByKey("level") or 0
    local active_chapter_cfg = getConfig(game_config_field.active_chapter);
    local active_detail_cfg = getConfig(game_config_field.active_detail);
    local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
    if itemCfg == nil then return end
    local active_detail = itemCfg:getNodeWithKey("active_detail");
    local active_detail_count = active_detail:getNodeCount();
    local totalItem = active_detail_count
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_selIndex;
    params.showPoint = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            cell:removeAllChildrenWithCleanup(true);
            local ccbNode = luaCCBNode:create();
            -- ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            local activeId = active_detail:getNodeAt(self.m_selIndex-1):toInt()
            local active_detail_item_cfg = active_detail_cfg:getNodeWithKey(tostring(activeId));
            local back_resource = active_detail_item_cfg:getNodeWithKey("back_resource"):toStr()
            local level = active_detail_item_cfg:getNodeWithKey("level")
            local downLimit = 1
            local upLimit = 200
            if level then
                downLimit = level:getNodeAt(0):toInt()
                upLimit = level:getNodeAt(1):toInt()
            end
            -- ccbNode:openCCBFile("ccb/ui_active_map_item" .. self.m_selIndex ..".ccbi");
            ccbNode:openCCBFile("ccb/ui_active_map_item" .. back_resource ..".ccbi");
            if ccbNode then
                ccbNode:ignoreAnchorPointForPosition(false);
                ccbNode:setAnchorPoint(ccp(0.5,0.5));
                ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                local openFlag = true
                local active_button = ccbNode:controlButtonForName("active_button");
                if myLevel >= downLimit and myLevel <= upLimit then
                    active_button:setColor(ccc3(255,255,255))
                    openFlag = true
                else
                    active_button:setColor(ccc3(81,81,81))
                    openFlag = false
                end
                self:createChapterTips(active_button,active_detail:getNodeAt(self.m_selIndex-1):toInt(),openFlag,downLimit);
                cell:addChild(ccbNode,10,10);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local active_chapter_cfg = getConfig(game_config_field.active_chapter);
            local active_detail_cfg = getConfig(game_config_field.active_detail);
            local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
            local active_detail = itemCfg:getNodeWithKey("active_detail");
            local activeId = active_detail:getNodeAt(self.m_selIndex-1):toInt();
            cclog("activeId == " .. activeId)
            --判断是否能打
            local active_detail_item_cfg = active_detail_cfg:getNodeWithKey(tostring(activeId));
            local level = active_detail_item_cfg:getNodeWithKey("level")
            local level = active_detail_item_cfg:getNodeWithKey("level")
            local downLimit = 1
            local upLimit = 200
            if level then
                downLimit = level:getNodeAt(0):toInt()
                upLimit = level:getNodeAt(1):toInt()
            end
            if myLevel >= downLimit and myLevel <= upLimit then
                if self.chapter_detail == 0 then--没有打，直接打
                    -- game_data_statistics:enterActive({activeId = activeId})
                    -- game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});  
                    self:enterActiveMapBuildingDetailScene({activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});  
                else
                    local activeId_back = active_detail:getNodeAt(self.chapter_detail-1):toInt();
                    if activeId_back == activeId then
                        local active_chapter_cfg = getConfig(game_config_field.active_chapter);
                        local active_detail_cfg = getConfig(game_config_field.active_detail);
                        local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
                        local active_detail = itemCfg:getNodeWithKey("active_detail");
                        local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
                        -- game_data_statistics:enterActive({activeId = activeId})
                        -- game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = self.over_ground+1});  
                        self:enterActiveMapBuildingDetailScene({activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = self.over_ground+1});  
                    else
                        -- local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
                        local t_params = 
                        {
                            title = string_helper.active_map_scene.title3,
                            okBtnCallBack = function(target,event)
                                -- game_data_statistics:enterActive({activeId = activeId})
                                -- game_scene:enterGameUi("active_map_building_detail_scene",{activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});    
                                self:enterActiveMapBuildingDetailScene({activeChapterId = self.m_activeChapterId,activeId = activeId,next_step = 0});
                                game_util:closeAlertView();
                            end,   --可缺省
                            closeCallBack = function(target,event)
                                game_util:closeAlertView();
                            end,
                            cancelBtnCallBack = function(target,event)
                                game_util:closeAlertView();
                            end,
                            okBtnText = string_helper.active_map_scene.okBtnText3,       --可缺省
                            cancelBtnText = string_helper.active_map_scene.cancelBtnText3,
                            text = string_helper.active_map_scene.text5,      --可缺省
                            onlyOneBtn = false,
                            touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                        }
                        game_util:openAlertView(t_params)
                    end
                end
            else
                game_util:addMoveTips({text = string_helper.active_map_scene.text6})
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_selIndex = curPage;
        if self.m_selIndex == 1 then
            self.m_chapter_left_btn:setEnabled(false)
            self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
        else
            self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
            self.m_chapter_left_btn:setEnabled(true)
        end
        if self.m_selIndex == active_detail_count then
            self.m_chapter_right_btn:setEnabled(false)
            self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
        else
            self.m_chapter_right_btn:setEnabled(true)
            self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
        end
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    创建章节提示
]]
function active_map_scene.createChapterTips(self,btn,activeDetailId,openFlag,openLevel)
    local active_detail_cfg = getConfig(game_config_field.active_detail);
    local active_chapter_cfg = getConfig(game_config_field.active_chapter);
    local active_detail_item_cfg = active_detail_cfg:getNodeWithKey(tostring(activeDetailId));
    game_util:setCCControlButtonTitle(btn,"")
    local btnPosX,btnPosY = btn:getPosition();
    if active_detail_item_cfg then
        local boss_resource = active_detail_item_cfg:getNodeWithKey("boss_resource")
        if boss_resource then
            boss_resource = game_util:getResName(boss_resource:toStr())
            local tempIcon = game_util:createImgByName(boss_resource)
            if tempIcon then
                tempIcon:setAnchorPoint(ccp(0,0));
                -- tempIcon:setPosition(ccp(100,100))
                if openFlag then
                    tempIcon:setColor(ccc3(255,255,255))
                else
                    tempIcon:setColor(ccc3(81,81,81))
                end
                btn:addChild(tempIcon);
            end
        end

    else
        btn:setVisible(false);
        cclog("activeDetailId not found ============== " .. activeDetailId)
    end
    
    self.level_limit_node:setVisible(openFlag)
    self.m_node_needtips:setVisible(not openFlag)
    self.open_label:setString(openLevel .. string_helper.active_map_scene.openLevel)
    
    local combat_need = active_detail_item_cfg:getNodeWithKey("combat_need"):toInt()
    self.m_combat_label:setString(tostring(combat_need))
    if self.over_ground ~= -1 then
        local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
        local active_detail = itemCfg:getNodeWithKey("active_detail");
        local activeId = active_detail:getNodeAt(self.chapter_detail-1):toInt();
        local last_active_detail_item_cfg = active_detail_cfg:getNodeWithKey(tostring(activeId));
        local active_name = last_active_detail_item_cfg:getNodeWithKey("active_name"):toStr()
        self.last_node:setVisible(true)
        self.last_step_label:setString(string_helper.active_map_scene.shangci .. active_name .. string_helper.active_map_scene.di .. (self.over_ground + 1 ).. string_helper.active_map_scene.guan)
    else
        self.last_node:setVisible(false)
        self.left_times_label:setPositionY(63)
    end
end

--[[--
    刷新ui
]]
function active_map_scene.refreshUi(self)
    --原始
    -- self:createChapter(self.m_selIndex);
    --改1
    -- self:refreshChapter()
    --改2  增加滑动功能
    self.m_chapter_map_node:removeAllChildrenWithCleanup(true);
    local temp = self:createChapterTableView(self.m_chapter_map_node:getContentSize());
    self.m_chapter_map_node:addChild(temp);

    local tGameData = game_data:getActiveData();
end

--[[--
    初始化
]]
function active_map_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_activeChapterId = t_params.activeChapterId;
    -- self.m_selIndex = self.m_last_chapter or 1;

    self.cur_times = t_params.cur_times or 1;
    self.fight_times = t_params.fight_times or 2;
    self.active_step = t_params.active_step or 0;
    self.show_first = 1
    self:getActiveStep()
end
--[[
    获得上次打的数据
]]
function active_map_scene.getActiveStep(self)
    cclog("self.active_step = " .. json.encode(self.active_step))
    self.m_selIndex = 1
    self.chapter_detail = 0
    local active_chapter_detail = ""
    local step = -1
    if self.active_step ~= nil and tolua.type(self.active_step) == "table" then
        for k,v in pairs(self.active_step) do
            active_chapter_detail = k
            step = v[#v]
        end
    end
    local active_detail_cfg = getConfig(game_config_field.active_detail);
    local active_chapter_cfg = getConfig(game_config_field.active_chapter);
    local itemCfg = active_chapter_cfg:getNodeWithKey(tostring(self.m_activeChapterId))
    local active_detail = itemCfg:getNodeWithKey("active_detail");
    local active_detail_count = active_detail:getNodeCount();
    local index = 0
    for i=1,active_detail_count do
        local item_detail = active_detail:getNodeAt(i-1):toInt()
        if tonumber(active_chapter_detail) == item_detail then
            index = i
        end
    end
    -- self.chapter_detail = active_chapter_detail
    self.over_ground = step
    if step ~= -1 then
        self.m_selIndex = index
        self.chapter_detail = index
    end
end
--[[--
    创建ui入口并初始化数据
]]
function active_map_scene.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    return rootScene;
end

return active_map_scene;