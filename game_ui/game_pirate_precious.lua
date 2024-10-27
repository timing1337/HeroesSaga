---  罗杰的宝藏
local game_pirate_precious = {
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
    what_inside = nil,

    fightBtn = nil,
    round_sprite = nil,
    chose = nil,
    anim_node = nil,

    m_node_maskmain = nil,

};

--[[--
    销毁
]]
function game_pirate_precious.destroy(self)
    -- body
    cclog("-----------------game_pirate_precious destroy-----------------");
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
    self.what_inside = nil;
    self.m_combat_label = nil;

    self.fightBtn = nil;
    self.round_sprite = nil;
    self.chose = nil;
    self.anim_node = nil;
    self.m_node_maskmain = nil;
end
--[[--
    返回
]]
function game_pirate_precious.back(self,type)
    -- local function responseMethod(tag,gameData)
    --     game_scene:enterGameUi("game_activity",{gameData = gameData})
    --     self:destroy()
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_precious.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 101 then--向上翻页
            self.m_selIndex = math.max(self.m_selIndex - 1,1)
            self:refreshUi()
        elseif btnTag == 102 then--下翻
            local treasureCfg = getConfig(game_config_field.treasure)
            local count = treasureCfg:getNodeCount()
            self.m_selIndex = math.min(self.m_selIndex + 1,count)
            local itemCfg = treasureCfg:getNodeWithKey(tostring(self.m_selIndex))
            self:refreshUi()
        elseif btnTag == 103 then--排行   暂无

        elseif btnTag == 104 then--装备   
            game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_pirate_precious",showIndex= 1});
            self:destroy();
        elseif btnTag == 105 then--伙伴
            game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "game_pirate_precious",showIndex= 1});
            self:destroy();
        elseif btnTag == 106 then--阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_pirate_precious"});
            self:destroy();
        elseif btnTag == 200 then--宝箱预览
            -- --宝箱预览
            local treasureCfg = getConfig(game_config_field.treasure)
            local itemCfg = treasureCfg:getNodeWithKey(tostring(self.m_selIndex))
            local what_inside = itemCfg:getNodeWithKey("what_inside")
            self.what_inside = json.decode(what_inside:getFormatBuffer())
            if game_util:getTableLen(self.what_inside) > 0 then 
                game_scene:addPop("game_box_inside_pop",{itemId = 1,openType = 2,whatsIn = self.what_inside})
            end
        elseif btnTag >= 11 and btnTag <= 20 then--选难度1
            self.m_selIndex = btnTag - 10
            self:refreshUi()
        elseif btnTag == 500 then--出战
            local function responseMethod(tag,gameData)
                game_util:closeAlertView();
                game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
                self:destroy();
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local params = {}
                    params.treasure = self.m_selIndex
                    game_data:setTreasure(self.m_selIndex)
                    cclog2(game_data:getTreasure(),"treasure    ===  ")
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_think,
                text = string_config.pirate_enter_tip,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pirate_percious.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_node_maskmain = ccbNode:nodeForName("m_node_maskmain")
    -- self.m_chapter_map_node = ccbNode:nodeForName("m_chapter_map_node")
    -------------- 活动 改 -----------------
    -- self.m_chapter_left_btn = ccbNode:controlButtonForName("m_chapter_left_btn")
    -- self.m_chapter_right_btn = ccbNode:controlButtonForName("m_chapter_right_btn")
    self.m_combat_label = ccbNode:labelBMFontForName("m_combat_label")

    self.m_battle_btn_bg = ccbNode:spriteForName("m_battle_btn_bg")
    local animArr = CCArray:create();
    animArr:addObject(CCScaleTo:create(1,0.9));
    animArr:addObject(CCScaleTo:create(1,1.0));
    self.m_battle_btn_bg:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    for i=1,3 do
        local testBtn = ccbNode:controlButtonForName("btn_" .. i)
        testBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY)

        self.fightBtn[i] = ccbNode:controlButtonForName("fight_btn" .. i)
        self.round_sprite[i] = ccbNode:spriteForName("round_sprite_" .. i)
        self.chose[i] = ccbNode:spriteForName("chose_" .. i)
        self.anim_node[i] = ccbNode:nodeForName("anim_node" .. i)

        self.fightBtn[i]:setOpacity(0)
    end
    -- game_util:setControlButtonTitleBMFont(self.btn_continue)
    -- game_util:setControlButtonTitleBMFont(self.btn_restart)
    return ccbNode;
end
--[[
    table
]]
function game_pirate_precious.createChapterTableView(self,viewSize)
    local treasureCfg = getConfig(game_config_field.treasure)
    local totalItem = treasureCfg:getNodeCount()
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
            local itemCfg = treasureCfg:getNodeWithKey(tostring(self.m_selIndex))
            local boss_resource = itemCfg:getNodeWithKey("boss_resource")
            --战斗力提示
            local combat_need = itemCfg:getNodeWithKey("combat_need"):toInt()
            self.m_combat_label:setString(tostring(combat_need))
            
            local map_id = itemCfg:getNodeWithKey("map_id"):toInt()
            ccbNode:openCCBFile("ccb/ui_active_map_item" .. map_id ..".ccbi");
            if ccbNode then
                ccbNode:ignoreAnchorPointForPosition(false);
                ccbNode:setAnchorPoint(ccp(0.5,0.5));
                ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                local active_button = ccbNode:controlButtonForName("active_button");
                if boss_resource then
                    boss_resource = game_util:getResName(boss_resource:toStr())
                    local tempIcon = game_util:createImgByName(boss_resource)
                    if tempIcon then
                        tempIcon:setAnchorPoint(ccp(0,0));
                        active_button:addChild(tempIcon);
                    end
                end
                cell:addChild(ccbNode,10,10);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local function responseMethod(tag,gameData)
                game_util:closeAlertView();
                game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
                self:destroy();
            end
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    local params = {}
                    params.treasure = self.m_selIndex
                    game_data:setTreasure(self.m_selIndex)
                    cclog2(game_data:getTreasure(),"treasure    ===  ")
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
                end,   --可缺省
                okBtnText = string_config.m_btn_sure,       --可缺省
                cancelBtnText = string_config.m_btn_think,
                text = string_config.pirate_enter_tip,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
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
        if self.m_selIndex == totalItem then
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
    刷新ui
]]
function game_pirate_precious.refreshUi(self)
    -- self.m_chapter_map_node:removeAllChildrenWithCleanup(true);
    -- local temp = self:createChapterTableView(self.m_chapter_map_node:getContentSize());
    -- self.m_chapter_map_node:addChild(temp);

    local treasureCfg = getConfig(game_config_field.treasure)
    local itemCfg = treasureCfg:getNodeWithKey(tostring(self.m_selIndex))
    --战斗力提示
    local combat_need = itemCfg:getNodeWithKey("combat_need"):toInt()
    self.m_combat_label:setString(tostring(combat_need))

    for i=1,3 do
        self.fightBtn[i]:setEnabled(true)
        self.round_sprite[i]:setColor(ccc3(151,151,151))
        self.chose[i]:setVisible(false)

        self.anim_node[i]:removeAllChildrenWithCleanup(true)
    end
    self.fightBtn[self.m_selIndex]:setEnabled(false)
    self.round_sprite[self.m_selIndex]:setColor(ccc3(255,255,255))
    -- self.chose[self.m_selIndex]:setVisible(true)

    local animArr = CCProgressTo:create(0.8,100)
    local rotateAnim = CCProgressTimer:create(self.chose[self.m_selIndex])
    rotateAnim:setType(kCCProgressTimerTypeRadial)
    -- rotateAnim:setReverseProgress(true)
    self.anim_node[self.m_selIndex]:addChild(rotateAnim)
    rotateAnim:runAction(animArr)
end

--[[--
    初始化
]]
function game_pirate_precious.init(self,t_params)
    t_params = t_params or {};
    self.m_activeChapterId = t_params.activeChapterId;
    self.cur_times = t_params.cur_times or 1;
    self.fight_times = t_params.fight_times or 2;
    self.active_step = t_params.active_step or 0;
    self.show_first = 1
    self.m_selIndex = 1
    self.what_inside = {}
    self.fightBtn = {}
    self.round_sprite = {}
    self.chose = {}
    self.anim_node = {}
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_precious.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();

    local id = game_guide_controller:getIdByTeam("71");
    -- id = 7101
    if id == 7101 then
        self:gameGuide("drama","71",id, t_params)
    end
    return rootScene;
end


function game_pirate_precious.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "71" and id == 7101 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, 7102 , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_maskmain
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "71" and id == 7102 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team,id + 1)
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true
            t_params.tempNode = self.m_node_maskmain
            game_guide_controller:showGuide(guide_team, id, t_params)
        end
    end
end






return game_pirate_precious;