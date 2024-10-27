---  世界地图

local map_world_scene = {
    m_tGameData = nil,
    m_root_layer = nil,
    m_map_container_node = nil,
    m_list_view_bg = nil,
    m_selIndex = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_story_label = nil,
    m_last_chapter = nil,
    m_last_city = nil,
    m_chapter_map_node = nil,
    m_draw_node = nil,
    m_playerAnimNode = nil,
    m_neutral_btn = nil,
    m_back_btn = nil,
    m_guideNode = nil,
    m_curPage = nil,
    m_tableView = nil,
    m_elite_levels_btn = nil,
    m_chapterTypeName = nil,
    m_mask_layer = nil,
    m_moveFlag = nil,
    m_chapter_left_btn = nil,
    m_chapter_right_btn = nil,
    m_showDataTab = nil,
    m_chapter_right_btn_pos = nil,
    m_elite_levels_btn_anim = nil,
    m_reward_node =nil,
    m_reward_guanka = nil,
    m_cityDataTab = nil,
    m_node_storyboard = nil,
    m_conbtn_equipinfo = nil,
    m_node_titles = nil,
    m_label_showtwice = nil,
    m_label_showtitle = nil,
    m_hard_done_times = nil,  -- 精英关卡已经挑战次数
    m_hard_max_times = nil,  -- 精英关卡最大次数
    m_hard_last_show_chapter = nil,  -- 上一次显示的是的哪个精英关卡
    m_fightChapter = nil,
    m_curShowEliteChapter = nil,
    m_achieve_btn = nil,
    m_hard_last_attack = nil,
    buy_hard_times, --
    isChapterSwitchingBegin = nil,
    m_sel_img = nil,
    m_ccbNode = nil,
    m_elite_levels_btn_2 = nil,
    m_itemId = nil,
};
--[[--
    销毁
]]
function map_world_scene.destroy(self)
    -- body
    cclog("-----------------map_world_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_root_layer = nil;
    self.m_map_container_node = nil;
    self.m_list_view_bg = nil;
    self.m_selIndex = nil;
    self.m_left_btn = nil;
    self.m_right_btn = nil;
    self.m_story_label = nil;
    self.m_last_chapter = nil;
    self.m_last_city = nil;
    self.m_chapter_map_node = nil;
    self.m_draw_node = nil;
    self.m_playerAnimNode = nil;
    self.m_neutral_btn = nil;
    self.m_back_btn = nil;
    self.m_guideNode = nil;
    self.m_curPage = nil;
    self.m_animMoveFlag = nil;
    self.m_tableView = nil;
    self.m_elite_levels_btn = nil;
    self.m_chapterTypeName = nil;
    self.m_mask_layer = nil;
    self.m_moveFlag = nil;
    self.m_chapter_left_btn = nil;
    self.m_chapter_right_btn = nil;
    self.m_showDataTab = nil;
    self.m_chapter_right_btn_pos = nil;
    self.m_elite_levels_btn_anim = nil;
    self.m_reward_node =nil;
    self.m_reward_guanka = nil;
    self.m_cityDataTab = nil;
    self.m_node_storyboard = nil;
    self.m_conbtn_equipinfo = nil;
    self.m_node_titles = nil;
    self.m_label_showtwice = nil;
    self.m_label_showtitle = nil;

    self.m_hard_done_times = nil;
    self.m_hard_max_times = nil;
    self.m_hard_last_show_chapter = nil;
    self.m_fightChapter = nil;
    self.m_curShowEliteChapter = nil;
    self.m_achieve_btn = nil;
    self.m_hard_last_attack = nil;
    self.buy_hard_times = nil;
    self.isChapterSwitchingBegin = nil;
    self.m_sel_img = nil;
    self.m_ccbNode = nil;
    self.m_elite_levels_btn_2 = nil;
    self.m_itemId = nil;
end


--[[--
    返回
]]
function map_world_scene.back(self,type)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function map_world_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    local level = game_data:getUserStatusDataByKey("level") or 0
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if game_data.getGuideProcess and game_data:getGuideProcess() == "first_battle_mine" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(28) end -- 点击返回主页 步骤28
                if game_data.setGuideProcess then game_data:setGuideProcess("first_enter_main_scene") end
            elseif game_data:getGuideProcess() == "battle_101002" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(45) end -- 地图2收复后返回 完成新手引导28 步骤28
                if game_data.setGuideProcess then game_data:setGuideProcess("") end
            end
            self:back();        
        elseif btnTag == 2 then--中立地图改成了自动扫荡
            -- if not game_button_open:checkButtonOpen(801) then
            --     return
            -- end
            if (vipLevel >= 5 and level >= 35) or level >= 45 then  -- 
                self:cityAutoRaids();
            else
                local tip = ""
                if vipLevel < 5 then 
                    tip = string_helper.map_world_scene.tip 
                else
                    tip = string_helper.map_world_scene.tip2 
                end
                game_util:addMoveTips({text = tip});
            end

            -- local function responseMethod(tag,gameData)
            --     game_scene:enterGameUi("game_neutral_map",{gameData = gameData});
            --     self:destroy();
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("public_city_index"), http_request_method.GET, nil,"public_city_index")

        elseif btnTag == 3 then--章节弹框
            local function callBackFunc(chapterId)
                cclog("self.m_last_chapter =" .. json.encode(self.m_last_chapter) .. " ; chapterId = " .. chapterId)
                if game_data:getMapType() == "normal" then
                    if tostring(self.m_last_chapter.normal) == tostring(chapterId) then return end
                    self.m_last_chapter.normal = self.m_showDataTab[tonumber(chapterId)] or self.m_last_chapter.normal
                elseif game_data:getMapType() == "hard" then
                    if tostring(self.m_last_chapter.hard) == tostring(chapterId) then return end
                    self.m_last_chapter.hard = self.m_showDataTab[tonumber(chapterId)] or self.m_last_chapter.hard
                end
                self:refreshChapterTableView();
            end
            game_scene:addPop("game_chapter_pop",{callBackFunc = callBackFunc,chapterTypeName = self.m_chapterTypeName});
        elseif btnTag == 4 or btnTag == 7 or btnTag == 8 then--精英关卡
            self:chapterSwitching(btnTag);       
        elseif btnTag == 5 then--世界成就
            local function responseMethod(tag,gameData)
                game_scene:addPop("word_achieve_pop",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_score"), http_request_method.GET, nil,"private_city_world_score")
        elseif btnTag == 101 then--上一章
            if game_data:getMapType() == "normal" then
                self.m_curPage.normal = math.max(self.m_curPage.normal - 1,1)
                self.m_last_chapter.normal = self.m_showDataTab[self.m_curPage.normal]
            elseif game_data:getMapType() == "hard" then
                self.m_curPage.hard = math.max(self.m_curPage.hard - 1,1)
                self.m_last_chapter.hard = self.m_showDataTab[self.m_curPage.hard]
            elseif self.m_chapterTypeName == "hero_road" then
                self.m_curPage.road = math.max(self.m_curPage.road - 1,1)
            end
            self:refreshChapterTableView();

        elseif btnTag == 102 then--下一章
            if game_data:getMapType() == "normal" then
                self.m_curPage.normal = math.min(self.m_curPage.normal + 1,#self.m_showDataTab)
                self.m_last_chapter.normal = self.m_showDataTab[self.m_curPage.normal]
            elseif game_data:getMapType() == "hard" then
                self.m_curPage.hard = math.min(self.m_curPage.hard + 1,#self.m_showDataTab)
                self.m_last_chapter.hard = self.m_showDataTab[self.m_curPage.hard]
            elseif game_data:getMapType() == "hero_road" then
                self.m_curPage.road = math.min(self.m_curPage.road + 1,#self.m_showDataTab)
            end
            --print("m_last_chapter  ======  1" , json.encode(self.m_last_chapter))
            self:refreshChapterTableView();
            --print("m_last_chapter  ====== 2 " , json.encode(self.m_last_chapter))
        elseif btnTag == 1001 then
            -- game_scene:addUILikePop("game_lllustrations_scene",{ showType = "equip" , isPop = true})    
            local function responseMethod(tag,gameData)
                -- game_scene:enterGameUi("game_lllustrations_scene",{gameData = gameData, showType = "equip"});
                game_scene:addUILikePop("game_lllustrations_scene",{ gameData = gameData, showType = "equip" , isPop = true})    
                -- self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_books"), http_request_method.GET, nil,"equip_books")
        elseif btnTag == 1002 then--伙伴碎片
            -- game_scene:addPop("game_active_limit_detail_pop",{openType = "map_world_scene"})
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_exchange_scene",{gameData = gameData,openType = 1,fromUi = "map_world_scene"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_view"), http_request_method.GET, {},"item_view");
        elseif btnTag == 11 then--装备
            game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "map_world_scene",showIndex= 1});
        elseif btnTag == 12 then--伙伴
            game_scene:enterGameUi("game_hero_list",{gameData = nil,openType = "map_world_scene",showIndex= 1});
        elseif btnTag == 13 then--阵型      
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="map_world_scene"});
        elseif btnTag == 14 then--星级伙伴
            local function callBackFunc()
                self:refreshAlert();
            end
            game_scene:addPop("hero_road_reward_pop",{callBackFunc = callBackFunc})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_map_world.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_map_container_node = ccbNode:scrollViewForName("m_map_container_node")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_story_label = ccbNode:labelTTFForName("m_story_label")
    self.m_chapter_map_node = ccbNode:nodeForName("m_chapter_map_node")
    self.m_neutral_btn = ccbNode:controlButtonForName("m_neutral_btn")
    self.m_elite_levels_btn = ccbNode:controlButtonForName("m_elite_levels_btn")
    self.m_chapter_left_btn = ccbNode:controlButtonForName("m_chapter_left_btn")
    self.m_chapter_right_btn = ccbNode:controlButtonForName("m_chapter_right_btn")
    self.m_node_storyboard = ccbNode:nodeForName("m_node_storyboard")
    self.m_achieve_btn = ccbNode:controlButtonForName("m_achieve_btn")
    self.m_sel_img = ccbNode:scale9SpriteForName("m_sel_img")

    local expBar = ExtProgressTime:createWithFrameName("public_diban.png","public_tili.png");
    expBar:setScale(0.6);
    local tempSize = self.m_achieve_btn:getContentSize();
    expBar:setPosition(ccp(0, -tempSize.height*0.15));
    self.m_achieve_btn:addChild(expBar);
    game_util:setWordAchieve(self.m_achieve_btn,expBar,self.m_tGameData.world_level,self.m_tGameData.world_score);

    self.m_label_showtwice = ccbNode:labelTTFForName("m_label_showtwice")   -- 显示挑战次数
    self.m_label_showtitle = ccbNode:labelTTFForName("m_label_showtitle")   -- 显示挑战关卡的名字
    self.m_label_showtwice:setFontSize( 10 )
    self.m_label_showtitle:setFontSize( 10 )

    self.m_conbtn_equipinfo = ccbNode:controlButtonForName("m_conbtn_equipinfo")
    self.m_conbtn_equipinfo:setVisible(false)

    self.m_node_titles = ccbNode:nodeForName("m_node_titles")
    self.m_node_titles:setVisible(false)


    self.m_mask_layer = ccbNode:layerColorForName("m_mask_layer");
    self.m_mask_layer:setVisible(false);
    -- self.m_elite_levels_btn:setVisible(false);
    self:setCityAutoRaidsBtnStatus(true)
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn");
    local id = game_guide_controller:getCurrentId();
    cclog("id ================================= " .. id)
    if id == 8 or id == 11 then
        game_guide_controller:gameGuide("show","1",12,{tempNode = self.m_back_btn})
        game_guide_controller:gameGuide("send","1",12);
    elseif id == 29 then
        game_guide_controller:gameGuide("show","2",29,{tempNode = self.m_back_btn})
    end
    local touchBeginPoint = nil;
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self.m_moveFlag = false;
            touchBeginPoint = {x = x, y = y}
            return true;--intercept event
        elseif eventType == "moved" then
            if ccpDistance(ccp(touchBeginPoint.x,touchBeginPoint.y),ccp(x,y)) > 20 then
                self.m_moveFlag = true;
            end
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY);
    self.m_root_layer:setTouchEnabled(true);


    self.m_elite_levels_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_conbtn_equipinfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    local pX,pY = self.m_chapter_right_btn:getPosition();
    self.m_chapter_right_btn_pos = {x = pX,y = pY}

    if (vipLevel >= 5 and level >= 35) or level >= 45 then--添加提示
        local skipFlag = CCUserDefault:sharedUserDefault():getBoolForKey("autoRaidsFlag");
        if skipFlag == nil or skipFlag == false then
            CCUserDefault:sharedUserDefault():setBoolForKey("autoRaidsFlag",true);
            CCUserDefault:sharedUserDefault():flush();
            game_util:createPulseAnmi("sjdt_saodang.png",self.m_neutral_btn)
        end
    end

    if not game_data:isViewOpenByID( 111 ) then
        self.m_neutral_btn:setVisible(false)
    end
    game_util:setPlayerPropertyByCCBAndTableData2(ccbNode)
    self.m_ccbNode = ccbNode;
    self.m_elite_levels_btn_2 = self.m_ccbNode:controlButtonForName("m_elite_levels_btn_2")
    self:refreshAlert();
    return ccbNode;
end


function map_world_scene.refreshAlert(self)
    local m_detail_btn = self.m_ccbNode:controlButtonForName("m_detail_btn");
    if m_detail_btn then m_detail_btn:setScale(0.85) end
    local tempNode = m_detail_btn:getChildByTag(1000);
    if tempNode then
        tempNode:removeFromParentAndCleanup(true);
    end
    local m_star_reward_btn = self.m_ccbNode:controlButtonForName("m_star_reward_btn");
    if m_star_reward_btn then m_star_reward_btn:setScale(0.85) end
    local tempNode = m_star_reward_btn:getChildByTag(1000);
    if tempNode then
        tempNode:removeFromParentAndCleanup(true);
    end

    local btnPare = m_star_reward_btn:getParent()
    if btnPare and btnPare:getChildByTag(954654) then 
        btnPare:removeChildByTag(954654, true)
    end

    if btnPare and btnPare:getChildByTag(954655) then 
        btnPare:removeChildByTag(954655, true)
    end



    local exchange_card = game_data:getAlertsDataByKey("exchange_card");
    if exchange_card and exchange_card ~= "" then--兑换
        self:addTipsATipsAnime(m_detail_btn, 954654)
    end

    local mapWorldData = game_data:getMapWorldData();
    local star_reward_log = mapWorldData.star_reward_log or {};
    local hero_done = mapWorldData.hero_done or {};
    local totalStar = game_util:getTableLen(hero_done)

    local star_reward_cfg = getConfig(game_config_field.star_reward)
    local tempCount = star_reward_cfg:getNodeCount();
    local haveRewardFlag = false;
    for i=1,tempCount do
        local itemCfg = star_reward_cfg:getNodeAt(i-1);
        local key = itemCfg:getKey()
        local star = itemCfg:getNodeWithKey("star"):toInt();
        if totalStar >= star then
            local tempFlag = game_util:idInTableById(key,star_reward_log)
            if not tempFlag then
                haveRewardFlag = true
                break;
            end
        end
    end
    if haveRewardFlag then

        self:addTipsATipsAnime(m_star_reward_btn, 954654)
    
    
        -- local node = game_util:addTipsAnimByType(m_star_reward_btn, 17);
        -- -- node:setOpacity(155)
        -- node:setColor(ccc3(155, 155, 155))
    end
end

function map_world_scene.addTipsATipsAnime( self, btn , specialTag)
    local rhythm = 2 ;
    local loopFlag = true;
    local animFile = "anim_ui_tongyong";
    local tips_reward = game_util:createTipsAnim(animFile,rhythm,loopFlag);
    tips_reward:setPosition( ccp( btn:getPosition()))
    btn:getParent():addChild( tips_reward , -1, specialTag)
    tips_reward:setScale(0.9)
    return tips_reward
end



function map_world_scene.setCityAutoRaidsBtnStatus(self,visible)
    self.m_neutral_btn:setVisible(visible)
end

--[[
    自动扫荡
]]
function map_world_scene.cityAutoRaids(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        local dataTab = json.decode(data:getFormatBuffer())
        local fragmentBuildingTab = dataTab.building
        local rest_auto_sweep_times = dataTab.rest_auto_sweep_times or 0;
        game_scene:addPop("city_auto_raids_pop",{cityDataTab = self.m_cityDataTab,fragmentBuildingTab = fragmentBuildingTab,itemId = self.m_itemId,rest_auto_sweep_times = rest_auto_sweep_times})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_auto_sweep_building"), http_request_method.GET, nil,"private_city_auto_sweep_building")
end

--[[--
    章节类型切换
]]
function map_world_scene.chapterSwitching(self,btnTag)
    local m_chapter_btn = self.m_ccbNode:controlButtonForName("m_chapter_btn");
    local m_detail_btn = self.m_ccbNode:controlButtonForName("m_detail_btn");
    local m_bottom_node = self.m_ccbNode:nodeForName("m_bottom_node");
    local m_hero_road_label = self.m_ccbNode:labelTTFForName("m_hero_road_label");
    m_hero_road_label:setString("");
    btnTag = btnTag or 4;
    local posNode = nil;
    if btnTag == 4 then--普通关卡
        self.m_chapterTypeName = "normal"
        self:setCityAutoRaidsBtnStatus(true);
        game_data:setMapType("normal")
        self.m_node_storyboard:setVisible(true)
        
        posNode = self.m_ccbNode:controlButtonForName("m_elite_levels_btn")
        m_chapter_btn:setVisible(true);
        m_detail_btn:setVisible(false);
        m_bottom_node:setVisible(false);
        self.m_conbtn_equipinfo:setVisible(false)
        self.m_achieve_btn:setVisible(true)
    elseif btnTag == 7 then--精英关卡
        if not game_button_open:checkButtonOpen(800) then
            return;
        end
        game_data:setMapType("hard")
        self.m_chapterTypeName = "difficult"
        local id = game_guide_controller:getIdByTeam("17");
        if id == 1701 then
            game_guide_controller:gameGuide("drama","17",1701)
        end
        self:setCityAutoRaidsBtnStatus(false);
        self.m_node_storyboard:setVisible(false)
        self:createChapter( 105 )
        posNode = self.m_ccbNode:controlButtonForName("m_elite_levels_btn_2")
        m_chapter_btn:setVisible(true);
        m_detail_btn:setVisible(false);
        m_bottom_node:setVisible(false);
        self.m_conbtn_equipinfo:setVisible(false)
        self.m_achieve_btn:setVisible(false)
    elseif btnTag == 8 then--英雄之路
        -- if not game_button_open:checkButtonOpen(123) then
        --     return;
        -- end
        if game_data:isViewOpenByID(10000) then--配置控制开启
        else
            game_util:addMoveTips({text = "暫未開放！"});
            return;
        end
        local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
        if playerLevel < 40 then
            game_util:addMoveTips({text = string_helper.map_world_scene.text});
            return;
        end
        self:setCityAutoRaidsBtnStatus(false);
        self.m_chapterTypeName = "hero_road"
        game_data:setMapType("hero_road")
        posNode = self.m_ccbNode:controlButtonForName("m_elite_levels_btn_3")
        m_chapter_btn:setVisible(false);
        self.m_achieve_btn:setVisible(false)
        self.m_conbtn_equipinfo:setVisible(false)
        self.m_node_titles:setVisible(false)
        self.m_node_storyboard:setVisible(true);
        self.m_story_label:setString(string_helper.map_world_scene.hr_load);
        m_detail_btn:setVisible(true);
        m_bottom_node:setVisible(true);
    end
    if posNode then
        local pX,pY = posNode:getPosition();
        self.m_sel_img:setPosition(ccp(pX,pY))
    end

    cclog("self.m_last_chapter =" .. json.encode(self.m_last_chapter))
    game_data:setCurrChapterTypeName(self.m_chapterTypeName);
    self:refreshChapterTableView();
    cclog("self.m_chapterTypeName ================= " .. self.m_chapterTypeName);
    if self.m_elite_levels_btn_anim then
        self.m_elite_levels_btn_anim:removeFromParentAndCleanup(true);
        self.m_elite_levels_btn_anim = nil;
    end
end

--[[--
    创建章节列表
]]
function map_world_scene.createChapterTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local chapter = getConfig(game_config_field.chapter);
    local middle_map_count = chapter:getNodeCount();
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    local showDataTab = {};
    local itemCfg = nil;
    local chapterId = nil;

    local normalTab = game_data:getChapterTabByKey(self.m_chapterTypeName);
    for k,v in pairs(normalTab) do
        itemCfg = chapter:getNodeWithKey(v);
        local open_level = itemCfg:getNodeWithKey("open_level"):toInt();
        chapterId = itemCfg:getKey();
        if playerLevel >= open_level then--开启
            showDataTab[#showDataTab + 1] = chapterId
            if tostring(self.m_last_chapter.normal) == chapterId then
                self.m_curPage.normal = #showDataTab;
            end
        end
    end

    self.m_showDataTab = showDataTab;
    local totalItem = #showDataTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage.normal;
    params.showPoint = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            local itemCfg = chapter:getNodeWithKey(showDataTab[index+1])
            self.m_playerAnimNode = nil;
            cell:removeAllChildrenWithCleanup(true);
            if itemCfg then
                cclog("chapterId =============" .. itemCfg:getKey() .. " ; index = " .. index)
                local ccbNode = self:createChapter(itemCfg:getKey());
                if ccbNode then
                    ccbNode:ignoreAnchorPointForPosition(false);
                    ccbNode:setAnchorPoint(ccp(0.5,0.5));
                    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                    cell:addChild(ccbNode,10,10);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            -- local itemCfg = chapter:getNodeAt(index);
            -- self:createChapter(itemCfg:getKey());
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        cclog("totalPage==" .. totalPage .. " ; curPage = " .. curPage)
        self.m_curPage.normal = curPage;
        local chapter = getConfig(game_config_field.chapter);
        local itemCfg = chapter:getNodeWithKey(showDataTab[self.m_curPage.normal])
        -- self.m_story_label:setString(itemCfg:getNodeWithKey("chapter_story"):toStr());
        self.m_story_label:setString(itemCfg:getNodeWithKey("chapter_name"):toStr());
        self.m_chapter_right_btn:stopAllActions();
        if totalItem < 2 then
            self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_left_btn:setEnabled(false)
            self.m_chapter_right_btn:setEnabled(false)
        else
            local tempPos = self.m_chapter_right_btn_pos;
            if curPage == 1 then
                self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(false)
                self.m_chapter_right_btn:setEnabled(true)
                local id = game_guide_controller:getIdByTeam("16");
                if id == 1601 and self.m_chapterTypeName == "normal" then
                    local animArr = CCArray:create();
                    animArr:addObject(CCMoveTo:create(0.5,ccp(tempPos.x + 5, tempPos.y)));
                    animArr:addObject(CCMoveTo:create(0.5,ccp(tempPos.x - 5, tempPos.y)));
                    self.m_chapter_right_btn:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
                    game_guide_controller:gameGuide("send","16",1602);
                end
            elseif curPage == totalItem then
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(false)
                self.m_chapter_right_btn:setPosition(ccp(tempPos.x, tempPos.y))
            else
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(true)
            end
        end
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    创建精英章节列表
]]
function map_world_scene.createHardChapterTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local chapter = getConfig(game_config_field.chapter);
    local middle_map_count = chapter:getNodeCount();
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    local showDataTab = {};
    local itemCfg = nil;
    local chapterId = nil;

    local diffTab = game_data:getChapterTabByKey("difficult");
    for k,v in pairs(diffTab) do
        itemCfg = chapter:getNodeWithKey(v);
        local open_level = itemCfg:getNodeWithKey("open_level"):toInt();
        chapterId = itemCfg:getKey();
        if playerLevel >= open_level then--开启
            showDataTab[#showDataTab + 1] = chapterId
            if tostring(self.m_last_chapter.hard) == tostring(chapterId) then
                self.m_curPage.hard = #showDataTab;
                --print("  self.m_curPage  ====  ",  self.m_curPage.hard)
            end
        end
    end
    self.m_showDataTab = showDataTab;
    local totalItem = #showDataTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 1; --列
    params.totalItem = totalItem;
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage.hard;
    params.showPoint = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
        end
        if cell then
            local itemCfg = chapter:getNodeWithKey(showDataTab[index+1])
            self.m_playerAnimNode = nil;
            cell:removeAllChildrenWithCleanup(true);
            if itemCfg then
                cclog("chapterId =============" .. itemCfg:getKey() .. " ; index = " .. index)
                local ccbNode = self:createChapter(itemCfg:getKey());
                if ccbNode then
                    ccbNode:ignoreAnchorPointForPosition(false);
                    ccbNode:setAnchorPoint(ccp(0.5,0.5));
                    ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
                    cell:addChild(ccbNode,10,10);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            -- local itemCfg = chapter:getNodeAt(index);
            -- self:createChapter(itemCfg:getKey());
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        cclog("totalPage==" .. totalPage .. " ; curPage = " .. curPage)
        self.m_curPage.hard = curPage;
        local chapter = getConfig(game_config_field.chapter);
        local itemCfg = chapter:getNodeWithKey(showDataTab[self.m_curPage.hard])
        -- self.m_story_label:setString(itemCfg:getNodeWithKey("chapter_story"):toStr());
        self.m_story_label:setString(itemCfg:getNodeWithKey("chapter_name"):toStr());
        self.m_chapter_right_btn:stopAllActions();
        if totalItem < 2 then
            self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_left_btn:setEnabled(false)
            self.m_chapter_right_btn:setEnabled(false)
        else
            local tempPos = self.m_chapter_right_btn_pos;
            if curPage == 1 then
                self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(false)
                self.m_chapter_right_btn:setEnabled(true)
                local id = game_guide_controller:getIdByTeam("16");
                if id == 1601 and self.m_chapterTypeName == "normal" then
                    local animArr = CCArray:create();
                    animArr:addObject(CCMoveTo:create(0.5,ccp(tempPos.x + 5, tempPos.y)));
                    animArr:addObject(CCMoveTo:create(0.5,ccp(tempPos.x - 5, tempPos.y)));
                    self.m_chapter_right_btn:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
                    game_guide_controller:gameGuide("send","16",1602);
                end
            elseif curPage == totalItem then
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(false)
                self.m_chapter_right_btn:setPosition(ccp(tempPos.x, tempPos.y))
            else
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(true)
            end
        end
    end
    return TableViewHelper:createGallery3(params);
end




--[[--
    刷新章节列表
]]
function map_world_scene.refreshChapterTableView(self)
    self.m_chapter_map_node:removeAllChildrenWithCleanup(true);
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    if self.m_chapterTypeName == "normal" then
        self.m_tableView = self:createChapterTableView(self.m_chapter_map_node:getContentSize());
        self.m_chapter_map_node:addChild(self.m_tableView);
    elseif self.m_chapterTypeName == "difficult" then
        self.m_tableView = self:createHardChapterTableView(self.m_chapter_map_node:getContentSize());
        self.m_chapter_map_node:addChild(self.m_tableView);
    elseif self.m_chapterTypeName == "hero_road" then
        self.m_tableView = self:createHeroRoadTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(self.m_tableView);
    end
end


--[[--
    创建英雄之路列表
]]
function map_world_scene.createHeroRoadTableView(self,viewSize)
    local view_item_tab = {};

    local hero_road = self.m_tGameData.hero_road or {};
    local hero_done = self.m_tGameData.hero_done;
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    local hero_chapter_cfg = getConfig(game_config_field.hero_chapter)
    local showDataTab = {};
    if hero_chapter_cfg then
        local tempCount = hero_chapter_cfg:getNodeCount();
        for i=1,tempCount do
            local itemCfg = hero_chapter_cfg:getNodeAt(i-1);
            local key = itemCfg:getKey();
            local starCount = 0;
            local active_detail = itemCfg:getNodeWithKey("active_detail")
            local tempCount = active_detail:getNodeCount();
            for i=1,tempCount do
                local active_detail_key = active_detail:getNodeAt(i-1):toStr();
                local count = hero_done[active_detail_key] or 0;
                if count > 0 then
                    starCount = starCount + 1;
                end
            end
            local level = itemCfg:getNodeWithKey("level")
            local level_d = level:getNodeAt(0):toInt();
            local level_u = level:getNodeAt(1):toInt();
            if playerLevel >= level_d and level_d <= level_u then
                table.insert(showDataTab,{key = key,star = starCount,openFlag = true,openLevel = level_d});
            else
                table.insert(showDataTab,{key = key,star = starCount,openFlag = false,openLevel = level_d});
            end
        end
    end
    self.m_showDataTab = showDataTab;

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_moveFlag == true then return end
        if btnTag < 10000 then
            local itemData = showDataTab[btnTag+1]
            local itemCfg = hero_chapter_cfg:getNodeWithKey(itemData.key);
            local times = itemCfg:getNodeWithKey("times"):toInt();
            local active_detail = itemCfg:getNodeWithKey("active_detail")
            local tempCount = active_detail:getNodeCount();
            if tempCount > 0 then
                local active_detail_key = active_detail:getNodeAt(tempCount-1):toStr();
                local function responseMethod(tag,gameData)
                    local item_hero_road = hero_road[itemData.key] or {}
                    local active_done_status = item_hero_road.active_done_status or {}
                    active_done_status[active_detail_key] = active_done_status[active_detail_key] or 0;
                    active_done_status[active_detail_key] = active_done_status[active_detail_key] + 1;
                    local data = gameData:getNodeWithKey("data")

                    local is_win = data and data:getNodeWithKey("is_win"):toBool()
                    if is_win then
                        item_hero_road.cur_times = item_hero_road.cur_times + 1;
                    else
                        game_util:addMoveTips({ text = string_helper.map_world_scene.text2 })
                    end

                    if view_item_tab[btnTag] then
                        view_item_tab[btnTag].m_count_label:setString(string_helper.map_world_scene.text3 .. math.max(0,times - item_hero_road.cur_times));
                    end

                    local reward = data:getNodeWithKey("sweep_reward")
                    game_util:rewardTipsByJsonData(reward);
                    self:refreshChapterTableView();
                    game_util:setPlayerPropertyByCCBAndTableData2(self.m_ccbNode)
                end
                local params = {};
                params.chapter = tostring(itemData.key);
                params.active_id = active_detail_key;
                params.step_n = 0;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_fight"), http_request_method.GET, params,"active_fight")
            end
        else--刷新
            btnTag = btnTag - 10000
            local itemData = showDataTab[btnTag+1]
            local itemCfg = hero_chapter_cfg:getNodeWithKey(itemData.key);
            local times = itemCfg:getNodeWithKey("times"):toInt();
            local des = itemCfg:getNodeWithKey("des"):toStr();
            -- game_util:addMoveTips({text = "次数不够，请购买"});
            local item_hero_road = hero_road[itemData.key] or {}
            local buyTimes = item_hero_road.cur_buy_times or 0
            local canBuy,payValue = game_util:getCostCoinBuyTimes("23",buyTimes)
            if canBuy == true then
                local function responseMethod(tag,gameData)
                    game_util:closeAlertView();
                    local data = gameData:getNodeWithKey("data")
                    local dataTab = json.decode(data:getFormatBuffer()) or {};
                    if dataTab[itemData.key] then
                        hero_road[itemData.key] = dataTab[itemData.key];
                        local item_hero_road = hero_road[itemData.key] or {}
                        if view_item_tab[btnTag] then
                            local m_auto_battle_btn = view_item_tab[btnTag].m_auto_battle_btn
                            game_util:setCCControlButtonTitle(m_auto_battle_btn,string_helper.map_world_scene.sd);
                            m_auto_battle_btn:setTag(btnTag)
                            view_item_tab[btnTag].m_count_label:setString(string_helper.map_world_scene.text3 .. math.max(0,times - item_hero_road.cur_times));
                        end
                    end
                    game_util:addMoveTips({text = string_helper.map_world_scene.rf_success})
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_hero_road_buy_times"), http_request_method.GET, {chapter=tostring(itemData.key)},"active_hero_road_buy_times")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = string_helper.map_world_scene.cost .. payValue .. string_helper.map_world_scene.dialog_rf .. des .. "？",      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                }
                game_util:openAlertView(t_params)
            else
                game_util:addMoveTips({text = string_helper.map_world_scene.rf_out})
            end
        end
    end

    local sel_hero_chapter_key = game_data:getDataByKey("sel_hero_chapter_key") or ""
    local sel_hero_chapter_star = game_data:getDataByKey("sel_hero_chapter_star")
    local totalItem = #showDataTab;
    local tonumber = tonumber;
    table.sort(showDataTab,function(data1,data2) return tonumber(data1.key) < tonumber(data2.key) end);
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 3; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+2;
    params.totalItem = totalItem;
    params.showPoint = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.showPageIndex = self.m_curPage.road;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_hero_road_item.ccbi");
            ccbNode:ignoreAnchorPointForPosition(false);
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            ccbNode:controlButtonForName("m_auto_battle_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_anim_node = ccbNode:spriteForName("m_anim_node")
            local m_item_bg = ccbNode:spriteForName("m_item_bg")
            local m_count_bg = ccbNode:spriteForName("m_count_bg")
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_count_label = ccbNode:labelTTFForName("m_count_label")
            local m_open_label = ccbNode:labelTTFForName("m_open_label")
            if m_count_label then m_count_label:setFontSize( 8 ) end
            local m_auto_battle_btn = ccbNode:controlButtonForName("m_auto_battle_btn")
            game_util:setCCControlButtonTitle(m_auto_battle_btn,string_helper.ccb.text250)
            local itemData = showDataTab[index+1]
            local itemCfg = hero_chapter_cfg:getNodeWithKey(itemData.key);
            local banner = itemCfg:getNodeWithKey("banner"):toStr();
            -- local animNode = game_util:createIdelAnim(banner,0,nil,nil);
            -- cclog2(itemCfg, "itemCfg ====  ")
            local animNode = game_util:createImgByName( "image_" .. banner, 0 , true)
            if animNode then
                animNode:setAnchorPoint(ccp(0.5,0))
                animNode:setScale(0.9);
                m_anim_node:addChild(animNode);
            end
            local des = itemCfg:getNodeWithKey("des"):toStr();
            m_name_label:setString(des);
            local item_hero_road = hero_road[itemData.key] or {}
            local active_done_status = item_hero_road.active_done_status or {}
            local times = itemCfg:getNodeWithKey("times"):toInt();
            local cur_times = item_hero_road.cur_times or 0;
            local battle_num = math.max(0,times - cur_times)
            if battle_num > 0 then
                game_util:setCCControlButtonTitle(m_auto_battle_btn,string_helper.map_world_scene.sd);
                m_auto_battle_btn:setTag(index);
            else
                game_util:setCCControlButtonTitle(m_auto_battle_btn,string_helper.map_world_scene.rf);
                m_auto_battle_btn:setTag(10000+index);
            end
            m_count_label:setString(string_helper.map_world_scene.text3 .. battle_num);
            view_item_tab[index] = {m_count_label = m_count_label,m_auto_battle_btn = m_auto_battle_btn};
            local starCount = itemData.star
            for i=1,3 do
                local m_start_icon = ccbNode:spriteForName("m_star_icon_" .. i)
                if starCount >= i then
                    m_start_icon:setColor(ccc3(255, 255, 255))
                    if sel_hero_chapter_key == itemData.key and starCount > sel_hero_chapter_star and starCount == i then
                        sel_hero_chapter_key = "";
                        game_data:setDataByKeyAndValue("sel_hero_chapter_key","");
                        game_data:setDataByKeyAndValue("sel_hero_chapter_star",starCount);
                        m_start_icon:setScale(5);
                        local arr = CCArray:create();
                        arr:addObject(CCEaseIn:create(CCScaleTo:create(0.5, 0.9),5));
                        arr:addObject(CCScaleTo:create(0.2, 1.1));
                        arr:addObject(CCScaleTo:create(0.2, 1));
                        m_start_icon:runAction(CCSequence:create(arr))
                    end
                else
                    m_start_icon:setColor(ccc3(81, 81, 81))
                end
            end
            if starCount == 3 then
                m_auto_battle_btn:setVisible(true)
            else
                m_auto_battle_btn:setVisible(false)
            end
            m_open_label:setString("");
            local openFlag = false;
            if itemData.openFlag then
                local itemData2 = showDataTab[index]
                if itemData2 and itemData2.star < 1 then
                    openFlag = false;
                    itemData.type = 2;
                    local itemCfg = hero_chapter_cfg:getNodeWithKey(itemData2.key);
                    local des = itemCfg:getNodeWithKey("des"):toStr();
                    itemData.showMsg = string_helper.map_world_scene.complate .. des .. ">";
                    m_open_label:setString(itemData.showMsg);
                else
                    openFlag = true;    
                    itemData.showMsg = "";
                end
            else
                itemData.showMsg = "<" .. itemData.openLevel .. string_helper.map_world_scene.lv_open;
                m_open_label:setString(itemData.showMsg);
            end
            if openFlag then
                m_item_bg:setColor(ccc3(255, 255, 255))
                if animNode then
                    animNode:setColor(ccc3(255, 255, 255))
                end
                m_count_bg:setVisible(true);
            else
                m_item_bg:setColor(ccc3(81, 81, 81))
                if animNode then
                    animNode:setColor(ccc3(81, 81, 81))
                end
                m_count_bg:setVisible(false)                
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showDataTab[index+1]
            local hero_chapter_key = itemData.key;
            local itemCfg = hero_chapter_cfg:getNodeWithKey(hero_chapter_key);
            if itemData.showMsg ~= "" then
                game_util:addMoveTips({text = itemData.showMsg});
                return;
            end
            game_data:setDataByKeyAndValue("sel_hero_chapter_key",hero_chapter_key);
            game_data:setDataByKeyAndValue("sel_hero_chapter_star",itemData.star);
            local function callFunc(typeName)
                game_util:setPlayerPropertyByCCBAndTableData2(self.m_ccbNode)
            end
            game_scene:addPop("hero_road_pop",{hero_chapter_key = hero_chapter_key,starCount = itemData.star,callFunc = callFunc})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        local m_hero_road_label = self.m_ccbNode:labelTTFForName("m_hero_road_label");
        m_hero_road_label:setString(curPage .. "/" .. totalPage)
        cclog("totalPage==" .. totalPage .. " ; curPage = " .. curPage)
        self.m_curPage.road = curPage;
        game_data:setDataByKeyAndValue("m_curPage_road",curPage);
        self.m_chapter_right_btn:stopAllActions();
        if totalPage < 2 then
            self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
            self.m_chapter_left_btn:setEnabled(false)
            self.m_chapter_right_btn:setEnabled(false)
        else
            if curPage == 1 then
                self.m_chapter_left_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(false)
                self.m_chapter_right_btn:setEnabled(true)
            elseif curPage == totalPage then
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(81, 81, 81))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(false)
            else
                self.m_chapter_left_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_right_btn:setColor(ccc3(255, 255, 255))
                self.m_chapter_left_btn:setEnabled(true)
                self.m_chapter_right_btn:setEnabled(true)
            end
        end
        if zcAnimNode.removeAllUnusing then
            zcAnimNode:removeAllUnusing();
        end
        CCTextureCache:sharedTextureCache():removeUnusedTextures();
    end
    return TableViewHelper:createGallery3(params);
end


--[[--
    创建章节地图
]]
function map_world_scene.createChapter(self,chapterId,percentValue)

    --print( "will create chapterId == ", chapterId)

    self.m_hidden_city_visible = false;
    local chapter = getConfig(game_config_field.chapter);
    local itemCfg = chapter:getNodeWithKey(tostring(chapterId))

    --print("chapterId info is ", itemCfg:getFormatBuffer())

    local bgMusic = itemCfg:getNodeWithKey("music"):toStr();
    local fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("ccb/" .. itemCfg:getNodeWithKey("resource"):toStr() ..".ccbi");
    local existFlag = util.fileIsExist(fileFullPath)
    if existFlag == false then
        require("game_ui.game_pop_up_box").showAlertView(itemCfg:getNodeWithKey("resource"):toStr() ..string_helper.map_world_scene.not_ccbi);
        return;
    end


    --print("  itemCfg:getNodeWithKey(battlepoint):toStr()  ---- ", itemCfg:getNodeWithKey("battlepoint"):toStr())

    -- local info = {}
    -- info.combat_value = combat_value and combat_value:toStr() or "0001"
    -- local eliteNode = self:createEliteInfoLayer( info )

    -- self.m_map_container_node:getContainer():removeAllChildrenWithCleanup(true);
    -- self.m_chapter_map_node:removeAllChildrenWithCleanup(true);
    local map_main_story = getConfig(game_config_field.map_main_story);
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)

        local GoToFun = function ( )       end
        GoToFun = function ()
            if self.m_chapterTypeName == "difficult" and self.m_tGameData.hard_done_times >= self.m_tGameData.hard_max_times and tostring(self.m_curShowEliteChapter) ~= tostring(self.m_hard_last_attack ) then
                 local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    -- print(" get data is ", gameData:getFormatBuffer())
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        game_data:setMapWorldByJsonData(gameData:getNodeWithKey("data"));
                        self.m_tGameData = game_data:getMapWorldData();
                        self.buy_hard_times = self.m_tGameData.buy_hard_times
                        if self.m_tGameData.hard_last_attack.chapter ~= 1 then
                             self.m_hard_last_attack = tostring(self.m_tGameData.hard_last_attack.chapter) 
                         else
                           self.m_hard_last_attack = nil
                        end
                        -- self:refreshUi()
                        GoToFun()
                    end
                    game_util:addMoveTips({text = string_helper.map_world_scene.text4})
                    game_util:closeAlertView()
                end
                local buyTimes = self.buy_hard_times 
                local PayCfg = getConfig(game_config_field.pay):getNodeWithKey("16"):getNodeWithKey("coin")
                local payValue = 0
                if buyTimes >= PayCfg:getNodeCount() then
                    payValue = PayCfg:getNodeAt(PayCfg:getNodeCount()-1):toInt()
                else
                    payValue = PayCfg:getNodeAt(buyTimes):toInt()
                end
                -- print("----------    g:getNodeAt(buyT")
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("buy_done_times"), http_request_method.GET, nil,"buy_done_times")
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    cancelBtnText = string_config.m_btn_cancel,
                    text = string_helper.map_world_scene.cost .. payValue .. string_helper.map_world_scene.text5,      --可缺省
                    onlyOneBtn = false,
                    touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                }
                game_util:openAlertView(t_params)
                return
            end

            if self.m_moveFlag == false and event == 32 then
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                if btnTag == 2 and game_data.getGuideProcess and game_data:getGuideProcess() == "third_enter_main_scene" then
                    if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(40) end  -- 点击废墟城市 步骤40
                end
                local x = 1
                local function moveEndCallFunc()
                    local function responseMethod(tag,gameData)
                        game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                        game_scene:enterGameUi("game_small_map_scene",{bgMusic = bgMusic, isDifficult = (self.m_chapterTypeName == "difficult") and "yes" or nil});
                        self:destroy();
                        game_data:resetNewOpenCityTab();
                    end

                    if self.m_chapterTypeName == "difficult" then btnTag = btnTag + 1000 end
                    local main_story_item = map_main_story:getNodeWithKey(tostring(btnTag));
                    local params = {}
                    params.city = main_story_item:getNodeWithKey("stage_id"):toStr();
                    params.chapter = itemCfg:getKey();

                    if self.m_chapterTypeName == "difficult" then
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_hard_open"), http_request_method.GET, params,"private_city_open")
                    else
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open")
                    end

                end
                if self.m_playerAnimNode then
                    self.m_tableView:setTouchEnabled(false);
                    local pX,pY = tagNode:getPosition();
                    game_util:createBuildingPersonAnimMove(self.m_playerAnimNode,ccp(pX,pY+10),moveEndCallFunc);
                else
                    moveEndCallFunc();
                end
            end
        end


        -- print("self.m_curShowEliteChapter ~= self.m_hard_last_attack  === ", self.m_curShowEliteChapter , self.m_hard_last_attack, type(self.m_curShowEliteChapter), type(self.m_hard_last_attack))
        if self.m_chapterTypeName == "difficult" and self.m_hard_last_attack and tonumber(self.m_hard_last_attack) >= 200 and tostring(self.m_curShowEliteChapter) ~= tostring(self.m_hard_last_attack ) then
            local GiveUpAndGoOn = function ()
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    -- print(" get data is ", gameData:getFormatBuffer())
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        game_data:setMapWorldByJsonData(gameData:getNodeWithKey("data"));
                        self.m_tGameData = game_data:getMapWorldData();
                        self.buy_hard_times = self.m_tGameData.buy_hard_times
                        if self.m_tGameData.hard_last_attack.chapter ~= 1 then
                             self.m_hard_last_attack = tostring(self.m_tGameData.hard_last_attack.chapter) 
                         else
                           self.m_hard_last_attack = nil
                        end
                    end
                    GoToFun()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("hard_giveup"), http_request_method.GET, nil ,"hard_giveup")
            end
            local t_params = 
            {
                title = string_helper.map_world_scene.title,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    -- GoToFun()
                    GiveUpAndGoOn()
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                cancelBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_helper.map_world_scene.yw,       --可缺省
                cancelBtnText = string_helper.map_world_scene.me_s,
                text = string_helper.map_world_scene.text6,      --可缺省
                onlyOneBtn = false,
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            game_util:openAlertView(t_params)
            return
        end

        GoToFun()
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    --print("  itemCfg:getNodeWithKey(battlepoint):toStr()  ----  222 ", itemCfg:getNodeWithKey("battlepoint"):toStr())

    -- ccbNode:openCCBFile("ccb/ui_map_world_" .. (index + 1) ..".ccbi");
    ccbNode:openCCBFile("ccb/" .. itemCfg:getNodeWithKey("resource"):toStr() ..".ccbi");      
    local hard_story_id = nil
    local m_btn_root_node = tolua.cast(ccbNode:objectForName("m_btn_root_node"),"CCNode");
    if m_btn_root_node == nil then return end
    local items = m_btn_root_node:getChildren();
    if items then
        local itemCount = items:count();
        local btn = nil;
        local lineTab = {};
        local map_main_story = getConfig(game_config_field.map_main_story);
        local hidden_city_id = "-1"--itemCfg:getNodeWithKey('hidden_order'):toStr();
        local hidden_city_btn = nil;
        local hidden_city_item = nil
        local is_hidden_city_visible = true;
        for i = 1,itemCount do
            btn = tolua.cast(items:objectAtIndex(i - 1),"CCControlButton");
            local btnTag = btn:getTag()
            if self.m_chapterTypeName == "difficult" then btnTag = btnTag + 1000 hard_story_id = btnTag end
            local main_story_item = map_main_story:getNodeWithKey(tostring(btnTag));
            if main_story_item then
                local percentValue = 0
            
                if tostring(btn:getTag()) == hidden_city_id then
                    hidden_city_item = main_story_item;
                    hidden_city_btn = btn;
                    hidden_city_btn:setVisible(false);
                else
                    percentValue = self:createChapterTips(btn, main_story_item);
                    if percentValue ~= 100 then
                        is_hidden_city_visible = false;
                    end
                    self:createDifficultReward(ccbNode,main_story_item,percentValue)
                end
                local pX,pY = btn:getPosition();
                lineTab[#lineTab+1] = {pX = pX,pY = pY,tag = btn:getTag(),btn = btn};
            else
                cclog("main_story_item not found ===========" .. tostring(btn:getTag() + 1000))
                btn:setVisible(false);
            end
        end
        if is_hidden_city_visible == true and hidden_city_btn and main_story_item then
            hidden_city_btn:setVisible(true);
            self:createChapterTips(hidden_city_btn, hidden_city_item);
        end
        -- self.m_map_container_node:addChild(ccbNode);
        -- self.m_chapter_map_node:addChild(ccbNode);
    end

    --- 精英关卡 特殊信息： 继续游戏， 重新还是等等
    if self.m_chapterTypeName == "difficult" then
        local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
        local combat_value = itemCfg:getNodeWithKey("battlepoint"):toStr()
        if  m_combat_label then
            m_combat_label:removeFromParentAndCleanup(true);
        end
        local apNode = ccbNode:nodeForName("m_node_apboard")
        if apNode then
            apNode:removeFromParentAndCleanup(true)
        end
        -- self.m_conbtn_equipinfo:setVisible(true)
        local info = {}

        --print("combat_value == ", combat_value)
        info.combat_value = combat_value and tostring(combat_value) or "0"
        info.chapter_name = itemCfg:getNodeWithKey("chapter_name") and itemCfg:getNodeWithKey("chapter_name"):toStr() or string_helper.map_world_scene.not_place
        info.chapter_id = itemCfg:getKey() or "103"
        info.main_story_id = hard_story_id
        local eliteNode = self:createEliteInfoLayer( info )
        ccbNode:addChild( eliteNode, 100 )
        self.m_node_titles:setVisible(true)
    else
        -- self.m_conbtn_equipinfo:setVisible(false)
        self.m_node_titles:setVisible(false)
    end

    return ccbNode;
end

function map_world_scene.createEliteInfoLayer( self, info ) 

    --print(" elite info is ", json.encode(info))
    local ccbNode = luaCCBNode:create();
    local btnFuns = {}
    local onMainBtnClick = function ( target, event )
        local node = tolua.cast(target, "CCNode")
        local btnTag = node:getTag()
        --print(" click elite layer btn tag == ", btnTag)
            if btnFuns[btnTag] then 
                btnFuns[btnTag]()
            end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_map_elite_show.ccbi");

    local useTwices , allTwices = self.m_tGameData.hard_done_times or 3, self.m_tGameData.hard_max_times or 3

    local m_node_apointboard = ccbNode:nodeForName("m_node_apointboard")  -- 战斗力board
    local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")   -- 战斗力数字
    m_combat_label:setString( info.combat_value and tostring(info.combat_value) or "0" )

    local m_layer_restartboard = ccbNode:layerForName("m_layer_restartboard")
    local m_conbtn_refight = ccbNode:controlButtonForName("m_conbtn_refight")
    local m_conbtn_fightagain = ccbNode:controlButtonForName("m_conbtn_fightagain")
    game_util:setCCControlButtonTitle(m_conbtn_refight,string_helper.ccb.title166)
    game_util:setCCControlButtonTitle(m_conbtn_fightagain,string_helper.ccb.title167)

    -- if m_layer_restartboard and self.isFigthElite then
    --print("chapter_id  == ",  self.m_hard_last_attack, type(self.m_hard_last_attack ) , info.chapter_id, type(info.chapter_id) )
    self.m_curShowEliteChapter = info.chapter_id
    if self.m_hard_last_attack == info.chapter_id then
        m_layer_restartboard:setVisible(true)
        -- m_layer_restartboard:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
        -- m_layer_restartboard:setTouchEnabled(true);
        -- m_conbtn_refight:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
        -- m_conbtn_fightagain:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
        m_node_apointboard:setVisible(false)
    else
        m_layer_restartboard:setVisible(false)
        m_node_apointboard:setVisible(true)
    end

    if useTwices == 0 then
        m_layer_restartboard:setVisible(false)
        m_node_apointboard:setVisible(true)
    end

    local lastTwices = allTwices - useTwices
    self.m_label_showtwice:setString(string.format(string_helper.map_world_scene.day_challage, lastTwices >= 0 and lastTwices or 0, allTwices))

    local chapter = getConfig(game_config_field.chapter);
    local itemCfg = chapter:getNodeWithKey(tostring(self.m_fightChapter))


    local cur_chapter_name = ""
    if itemCfg then
        cur_chapter_name = itemCfg:getNodeWithKey("chapter_name") and itemCfg:getNodeWithKey("chapter_name"):toStr() or string_helper.map_world_scene.not_place
        self.m_label_showtitle:setString(string_helper.map_world_scene.challageing .. cur_chapter_name )
    else
        self.m_label_showtitle:setVisible(false)
    end
  

    btnFuns[11] = function ()
        -- 重新开始
         local t_params = 
        {
            title = string_helper.map_world_scene.yx_ts,
            okBtnCallBack = function(target,event)
                m_layer_restartboard:removeFromParentAndCleanup(true)
                m_node_apointboard:setVisible(true)
                local function responseMethod(tag,gameData)
                    if gameData ~= nil and tolua.type(gameData) == "util_json" then
                        game_data:setMapWorldByJsonData(gameData:getNodeWithKey("data"));
                        self.m_tGameData = game_data:getMapWorldData();
                        self.buy_hard_times = self.m_tGameData.buy_hard_times
                        if self.m_tGameData.hard_last_attack.chapter ~= 1 then
                             self.m_hard_last_attack = tostring(self.m_tGameData.hard_last_attack.chapter) 
                         else
                           self.m_hard_last_attack = nil
                        end
                    end
                    -- self.m_hard_last_attack = nil
                    -- self.m_tGameData.hard_last_city = 0
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("hard_giveup"), http_request_method.GET, nil ,"hard_giveup")
                game_util:closeAlertView();
            end,   --可缺省
            closeCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            cancelBtnCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            okBtnText = string_helper.map_world_scene.cxks,       --可缺省
            cancelBtnText = string_helper.map_world_scene.me_s,
            text = string_helper.map_world_scene.yx_sf .. cur_chapter_name .. string_helper.map_world_scene.cx_cg,      --可缺省
            onlyOneBtn = false,
            touchPriority = GLOBAL_TOUCH_PRIORITY-2,
        }
        game_util:openAlertView(t_params)
    end

     btnFuns[12] = function ()
        -- 继续挑战
        local function responseMethod(tag,gameData)
            m_layer_restartboard:removeFromParentAndCleanup(true)
            m_node_apointboard:setVisible(true)

            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
            game_scene:enterGameUi("game_small_map_scene",{bgMusic = bgMusic, isDifficult = (self.m_chapterTypeName == "difficult") and "yes" or nil});
            self:destroy();
            game_data:resetNewOpenCityTab();
        end
        if info.main_story_id  then
            --print("info.main_story_id ===  ", info.main_story_id)
            local map_main_story = getConfig(game_config_field.map_main_story);
            local main_story_item = map_main_story:getNodeWithKey(tostring(info.main_story_id));
            local params = {}
            params.city = main_story_item:getNodeWithKey("stage_id"):toStr();
            params.chapter = info.chapter_id;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_hard_open"), http_request_method.GET, params,"private_city_hard_open")
        else
            m_layer_restartboard:removeFromParentAndCleanup(true)
            m_node_apointboard:setVisible(true)
        end
    end

  
    if useTwices == 0 or not self.m_hard_last_attack then
        self.m_label_showtitle:setVisible(false)
    end

    if self.m_label_showtitle:isVisible() == false then
        self.m_label_showtwice:setDimensions(CCSizeMake(120, 30))
    else
        self.m_label_showtwice:setDimensions(CCSizeMake(120, 15))
    end


    return ccbNode
end


--[[--

]]
function map_world_scene.createDifficultReward(self,ccbNode,main_story_item,percentValue)
    if self.m_chapterTypeName == "difficult" then
        local m_reward_guanka = ccbNode:nodeForName("m_reward_guanka")
        local m_reward_node = ccbNode:nodeForName("reward_node")
        local pX = 70;
        local maxLenght = 330
        local m_reward_pos = {
            { 0.8 },
            { 0.6, 0.8},
            { 0.55, 0.75, 0.95 },
            { 0.4, 0.6, 0.8 ,1 },
            { 0.3,  0.5, 0.7, 0.9, 1.1},
        }
        if percentValue < 100 then
            local reward = main_story_item:getNodeWithKey("jingyingfirst")
            if reward then
                local function onBtnCilck( event,target )
                    local tagNode = tolua.cast(target, "CCNode");
                    local btnTag = tagNode:getTag();
                    local itemData = json.decode(reward:getNodeAt(btnTag-1):getFormatBuffer())
                    game_util:lookItemDetal(itemData)
                end

                for i=1,reward:getNodeCount() do
                    local itemData = reward:getNodeAt(i-1)
                    local reward_icon,name,count = game_util:getRewardByItem(itemData,false)
                    local posTable = m_reward_pos[reward:getNodeCount()]
                    m_reward_node:setScale(0.9)
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.9)
                        reward_icon:setPosition(ccp(posTable[i] * maxLenght,42))
                        m_reward_node:addChild(reward_icon)
                      
                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setTag(i)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(ccp(posTable[i] * maxLenght, 42))
                        button:setOpacity(0)
                        m_reward_node:addChild(button)
                        if name then
                            local label = game_util:createLabelTTF({text = name,color = ccc3(250,250,250),fontSize = 8})
                            label:setDimensions(CCSizeMake(maxLenght * 0.2,0))
                            label:setAnchorPoint(ccp(0.5,0.5))
                            label:setPosition(ccp(posTable[i] * maxLenght,10))
                            m_reward_node:addChild(label)
                        end
                    end
                end 
            end   
        else  
            local reward = main_story_item:getNodeWithKey("jingyingsweep")
            if reward then
                local function onBtnCilck( event,target )
                    local tagNode = tolua.cast(target, "CCNode");
                    local btnTag = tagNode:getTag();
                    local itemData = json.decode(reward:getNodeAt(btnTag-1):getFormatBuffer())
                    game_util:lookItemDetal(itemData)
                end  

                for i=1,reward:getNodeCount() do
                    local itemData = reward:getNodeAt(i-1)
                    local reward_icon,name,count = game_util:getRewardByItem(itemData,false)
                    local posTable = m_reward_pos[reward:getNodeCount()]
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(1.0)
                        reward_icon:setPosition(ccp(posTable[i],42))
                        m_reward_node:addChild(reward_icon)
                      
                        --加查看按钮
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setTag(i)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(ccp(posTable[i],42))
                        button:setOpacity(0)
                        m_reward_node:addChild(button)
                        if name then
                            local label = game_util:createLabelTTF({text = name,color = ccc3(250,250,250),fontSize = 12})
                            label:setAnchorPoint(ccp(0.5,0.5))
                            label:setPosition(ccp(posTable[i],7))
                            m_reward_node:addChild(label)
                        end
                    end
                end
            end
        end

    end
end

--[[--
    创建章节提示
]]
function map_world_scene.createChapterTips(self, btn, main_story_item)
    local stage_id = main_story_item:getNodeWithKey("stage_id"):toStr();
    game_util:setCCControlButtonTitle(btn,"")
    local btnPosX,btnPosY = btn:getPosition();
    local btnSize = btn:getContentSize();
    local tipsNodeSize = CCSizeMake(100, 30)
    -- local tipsNode = CCScale9Sprite:createWithSpriteFrameName("sjdt_putong.png") --CCSprite:createWithSpriteFrameName("sjdt_talk.png")
    -- local tipsNodeSize = CCSizeMake(100, 30) --tipsNode:getContentSize();
    -- tipsNode:setPreferredSize(tipsNodeSize);
    -- tipsNode:setPosition(ccp(btnPosX,btnPosY - tipsNodeSize.height*0.5))
    local tipsNode = nil;
    local open_level = main_story_item:getNodeWithKey("open_level"):toInt()
    local playerLevel = game_data:getUserStatusDataByKey("level")
    local percentValue = 0;
    if playerLevel >= open_level then
        local topLabel = CCLabelTTF:create(main_story_item:getNodeWithKey("stage_name"):toStr(),TYPE_FACE_TABLE.Arial_BoldMT,10);
        topLabel:setPosition(ccp(tipsNodeSize.width*0.5,tipsNodeSize.height*0.5))
        local all_city_regain_percent = self.m_tGameData.all_city_regain_percent;
        if all_city_regain_percent and all_city_regain_percent[stage_id] then
            percentValue = all_city_regain_percent[stage_id]
        end
        -- cclog("city id ==============" .. stage_id .. " ; percentValue = " .. percentValue)
        -- local bottomLabel = CCLabelTTF:create("收复度" .. percentValue .."%",TYPE_FACE_TABLE.Arial_BoldMT,10);
        -- bottomLabel:setColor(ccc3(255,188,33));
        -- bottomLabel:setPosition(ccp(tipsNodeSize.width*0.5,tipsNodeSize.height*0.4))
        -- tipsNode:addChild(bottomLabel)
        if percentValue == 100 then
        --     -- game_util:setCCControlButtonBackground(btn,"sjdt_recover.png");
        --     bottomLabel:setString("已收复")
            tipsNode = CCScale9Sprite:createWithSpriteFrameName("sjdt_shoufu.png")
            topLabel:setColor(ccc3(255,255,255));
            local tempSpr = CCSprite:createWithSpriteFrameName("sjdt_wanquanshoufu.png")
            tempSpr:setPosition(ccp(tipsNodeSize.width*0.5, tipsNodeSize.height))
            tipsNode:addChild(tempSpr);
        else
        --     -- game_util:setCCControlButtonBackground(btn,"sjdt_infection.png");
            tipsNode = CCScale9Sprite:createWithSpriteFrameName("sjdt_putong.png")
            topLabel:setColor(ccc3(255,237,88));
        end
        tipsNode:setPreferredSize(tipsNodeSize);
        tipsNode:addChild(topLabel)



        -- 精英关卡不显示动画了
        local last_cityType = "normal"
        cclog("self.m_last_city ===========" ..   stage_id .. json.encode(self.m_last_city) .. "s stage_id == " .. stage_id)
        if tostring(stage_id) == tostring(self.m_last_city["normal"])  then
            -- if game_data:getMapType() ~= "hard" then
                self:createPlayerMapAnim(btn)
            -- end
            local tempAnim = game_util:createUniversalAnim({animFile = "tips_reward",rhythm = 1.0,loopFlag = true});
            tempAnim:setPosition(ccp(tipsNodeSize.width*0.5,tipsNodeSize.height*0.5))
            tipsNode:addChild(tempAnim,100,100)
        end
        if btn:getTag() == 2 and self.m_guideNode == nil then
            self.m_guideNode = btn;
        end
    else
        -- game_util:setCCControlButtonBackground(btn,"sjdt_locked.png");
        tipsNode = CCScale9Sprite:createWithSpriteFrameName("sjdt_putong.png")
        tipsNode:setPreferredSize(tipsNodeSize);
        btn:setColor(ccc3(81,81,81));
        btn:setEnabled(false);
        local topLabel = CCLabelTTF:create(open_level .. string_helper.map_world_scene.lv_lock,TYPE_FACE_TABLE.Arial_BoldMT,12);
        topLabel:setColor(ccc3(173,48,0));
        topLabel:setPosition(ccp(tipsNodeSize.width*0.5,tipsNodeSize.height*0.5))
        tipsNode:addChild(topLabel)
    end
    -- self.m_chapter_map_node:addChild(tipsNode,5,5);
        if  self.m_chapterTypeName == "difficult" then
            tipsNode:setPosition(240,170)
        else
            tipsNode:setPosition(ccp(btnPosX,btnPosY - btnSize.height*0.5))
        end
    btn:getParent():addChild(tipsNode,5,5);
    return percentValue
end

--[[--
    
]]
function map_world_scene.createPlayerMapAnim(self,node)
    if self.m_playerAnimNode == nil and node then
        local pX,pY = node:getPosition();
        self.m_playerAnimNode = game_util:createOwnRoleAnim();
        if self.m_playerAnimNode then
            self.m_playerAnimNode:setPosition(ccp(pX,pY + 10))
            self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
            node:getParent():addChild(self.m_playerAnimNode,10,10)
        end
    end
end

--[[--
    刷新ui
]]
function map_world_scene.refreshUi(self)
    local btnTag = 4;
    if self.m_chapterTypeName == "normal" then
        btnTag = 4;
    elseif self.m_chapterTypeName == "difficult" then
        btnTag = 7;
    elseif self.m_chapterTypeName == "hero_road" then
        btnTag = 8;
    end
    self:chapterSwitching(btnTag);
    game_button_open:setButtonShow(self.m_ccbNode:controlButtonForName("m_elite_levels_btn_2"),800,1);--精英关卡
    -- game_button_open:setButtonShow(self.m_ccbNode:controlButtonForName("m_elite_levels_btn_3"),123,1);--英雄之路
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    if playerLevel < 40 then
        self.m_ccbNode:controlButtonForName("m_elite_levels_btn_3"):setColor(ccc3(81, 81, 81))
    end
    if game_data:isViewOpenByID(10000) then
    else
        self.m_ccbNode:controlButtonForName("m_elite_levels_btn_3"):setColor(ccc3(81, 81, 81))
    end
end

--[[--
    初始化
    @ t_params.assign_city : 手动指定要战斗的城市 
    @ t_params.assign_chapter : 手动指定要战斗章节
]]
function map_world_scene.init(self,t_params)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    t_params = t_params or {};
    -- body
    self.m_cityDataTab = {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setMapWorldByJsonData(t_params.gameData:getNodeWithKey("data"));
        self.m_tGameData = game_data:getMapWorldData();
        -- self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
        if self.m_tGameData.hard_last_attack.chapter ~= 1 then
            self.m_hard_last_attack = tostring(self.m_tGameData.hard_last_attack.chapter) 
        end
        self.m_last_chapter = {normal = self.m_tGameData.last_chapter, hard = self.m_hard_last_attack and tostring(self.m_hard_last_attack) or self.m_tGameData.hard_last_chapter}
        self.m_last_city = {normal = self.m_tGameData.last_city, hard = self.m_tGameData.hard_last_city}

        self.m_last_city.normal = t_params.assign_normal_city or t_params.assign_city or self.m_last_city.normal
        self.m_last_city.hard = t_params.assign_hard_city or self.m_last_city.hard
        
        self.m_last_chapter.normal = t_params.assign_normal_chapter or self.m_last_chapter.normal
        self.m_last_chapter.hard = t_params.assign_hard_chapter or self.m_last_chapter.hard

        self.buy_hard_times = self.m_tGameData.buy_hard_times

        -- --print("city map data is ---------------- ")
        -- --print_lua_table(self.m_tGameData, 8)
        local all_city_regain_percent = self.m_tGameData.all_city_regain_percent or {}
        local chapter = getConfig(game_config_field.chapter);
        local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
        local map_main_story_cfg = getConfig(game_config_field.map_main_story);
        local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
        for k,v in pairs(all_city_regain_percent) do
            local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(k))
            if cityOrderId then
                cityOrderId = cityOrderId:toStr();
                local main_story_item = map_main_story_cfg:getNodeWithKey(cityOrderId);
                local open_level = main_story_item:getNodeWithKey("open_level"):toInt(); 
                local chapterId = main_story_item:getNodeWithKey("chapter"):toStr();
                local itemCfg = chapter:getNodeWithKey(chapterId);
                local is_hard = nil
                local chapter_name = nil
                if itemCfg then
                    chapter_name = itemCfg:getNodeWithKey("chapter_name"):toStr();
                    is_hard = itemCfg:getNodeWithKey("is_hard"):toInt();
                end
                if playerLevel >= open_level and ( is_hard and is_hard == 0) and chapter_name and v < 100 then--开启
                    -- cclog("city ============== " .. k .. " ; is_hard== " .. is_hard .. " ; open_level = " .. open_level)
                    table.insert(self.m_cityDataTab,{city = k,percent = v,chapterId = chapterId,chapter_name = chapter_name})
                end
            end
        end
        table.sort(self.m_cityDataTab,function (data1,data2) return data1.city < data2.city end)
        -- cclog("json.encode(self.m_cityDataTab) == " .. json.encode(self.m_cityDataTab) .. " ; #self.m_cityDataTab = " .. #self.m_cityDataTab)
    end

    self.m_hard_last_show_chapter = t_params.hard_last_chapter or self.m_hard_last_attack or "201"
    self.m_curPage = {normal = 1, hard = 1,road = game_data:getDataByKey("m_curPage_road") or 1};

    local mapType = game_data:getMapType();
    if mapType == "hard" then
        self.m_chapterTypeName = "difficult"
    else
        self.m_chapterTypeName = mapType or "normal"
    end
    cclog("self.m_chapterTypeName ============ " .. self.m_chapterTypeName .. " ; mapType = " .. tostring(mapType))
    self.m_moveFlag = false;
    game_data:setCurrChapterTypeName(self.m_chapterTypeName);
    self.m_showDataTab = {};

    self.isChapterSwitchingBegin = t_params.chapterSwitchTo or "normal"
    self.m_fightChapter = self.m_tGameData.hard_last_chapter
    self.m_itemId = tostring(t_params.itemId or "")
end

--[[--
    创建ui入口并初始化数据
]]
function map_world_scene.create(self,t_params)
    self:init(t_params);
    local rootScene = CCScene:create();
    rootScene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getCurrentId();
    cclog("id ====================================" .. id)
    if id == 24 and self.m_guideNode and self.m_curPage.normal == 1 then
        if game_data.setGuideProcess then game_data:setGuideProcess("third_enter_main_scene") end
        game_guide_controller:gameGuide("show","1",25,{tempNode = self.m_guideNode});
    else
        if self.m_chapterTypeName == "normal" then
            -- local id = game_guide_controller:getIdByTeam("17");
            -- if id == 1701 then
            --     -- self.m_elite_levels_btn_anim = game_util:addTipsAnimByType(self.m_elite_levels_btn,13);
            -- end
            if self.m_itemId ~= "" then
                self:cityAutoRaids();
            end
        end
    end

    self.isFigthElite = t_params.openId or false
    if self.isChapterSwitchingBegin == "hard" then 
        -- self.m_last_chapter = 20 -- t_params.assign_chapter or 1
        self:chapterSwitching()
        self.isChapterSwitchingBegin = nil;
    end

    self:guideHelper()
    return rootScene;
end

--[[
    -- 本场景新手引导后续
]]
function map_world_scene.forceGuideDeatilFun( self, forceInfo )
    if not forceInfo then return end
    if forceInfo.guide_team == "17" then
        game_guide_controller:showEndForceGuide("17")
    end
end

--[[
    -- 本场景新手引导入口
]]
function map_world_scene.forceGuideFun( self, forceInfo )
    if forceInfo and forceInfo.map_world_scene then
        local t_params = {}
        t_params.clickCallFunc = function (  )
            -- cclog2("click")
            game_scene:removeGuidePop()
            self:forceGuideDeatilFun( forceInfo )
        end
        -- cclog2(forceInfo, "forceInfo  =======   ")
        -- cclog2(forceInfo.map_world_scene, "forceInfo.map_world_scene  =======   ")
        t_params.tempNode = self[ forceInfo.map_world_scene[1] ]
        t_params.skipFunc = function (  )
            if type(forceInfo.guideEndfun) == "function" then
                forceInfo.guideEndfun( forceInfo.guide_team )
            end
        end
        game_scene:addGuidePop( t_params )
        game_data:setForceGuideInfo( forceInfo )
    end
end

--[[
    检查时候需要新手引导
]]
function map_world_scene.guideHelper( self )
    local force_guide = game_data:getForceGuideInfo()
    if type(force_guide) == "table" and force_guide.map_world_scene then
        self:forceGuideFun( force_guide )
    else
        local  guidfun = function (  forceInfo )
            self:forceGuideFun( forceInfo )
        end
        game_guide_controller:guideHelper( guidfun , "map_world_scene")
    end
end



return map_world_scene;