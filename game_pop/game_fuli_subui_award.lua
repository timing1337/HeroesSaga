---  福利 - 领奖： 等级领奖， 关卡领奖，在线时间领奖，竞技场领奖

local game_fuli_subui_award = {
    m_node_awardview_board = nil,
    m_cur_showawardType = nil,
    m_cur_rewardCount = nil,
    m_onceData = nil,
    m_guide_node = nil,
    m_parentCloseBtn = nil,
    m_cur_reward= nil,
}

--[[--
    销毁ui
]]
function game_fuli_subui_award.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_award destroy-----------------"); 
    self.m_node_awardview_board = nil;
    self.m_cur_showawardType = nil;
    self.m_cur_rewardCount = nil;
    self.m_onceData = nil;
    self.m_guide_node = nil;
    self.m_parentCloseBtn = nil;
    self.m_cur_reward = nil;
end
--[[--
    返回
]]
function game_fuli_subui_award.back(self,backType)
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_award.createUi(self)

   local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "createUi btnTag  ==  ")
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 3 then--切换到每日签到
            self.m_change_type = true
            self.m_show_tpye = 1
            self:refreshBtn()
        elseif btnTag == 4 then--切换到充值签到
            self.m_change_type = true
            self.m_show_tpye = 2
            self:refreshBtn()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_fuli_content_award.ccbi");

    self.m_node_awardview_board = ccbNode:nodeForName("m_node_awardview_board")


    return ccbNode;
end

function game_fuli_subui_award.createRewardTableView( self, viewSize )
    local onceCfg = getConfig(game_config_field.reward_once); 
    local showData = self.m_onceData[self.m_cur_showawardType].data
    -- cclog2(showData, "showData  ====  ")

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " ..btnTag)
        local index = btnTag 
        local com_id = showData[index + 1].cid

        local item = self.result[tostring(com_id)]
        local status = item[3]
        -- cclog("com_id == " .. com_id)
        -- cclog("status == " .. status)
        if status == 1 then--领奖按钮
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                -- cclog("data = " .. data:getFormatBuffer())
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                self.result = json.decode(data:getNodeWithKey("once"):getNodeWithKey("result"):getFormatBuffer())
                self:refreshCurData()
                self:refreshUi()
                -- game_scene:removeGuidePop()
                -- self:guideHelper()
            end
            local award_id = com_id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("reward_once_award"), http_request_method.GET, {award_id = award_id},"reward_once_award")
        else--挑战
            if com_id > 3000 then--竞技场
            -- if index == 3 then--竞技场
                if not game_button_open:checkButtonOpen(200) then
                    return;
                end
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
            -- elseif index == 2 then --出战跳到具体的
            elseif com_id > 2000 and  com_id < 3000 then --出战跳到具体的
                local itemCfg = onceCfg:getNodeWithKey(tostring(com_id))
                local stage_id = itemCfg:getNodeWithKey("target_data"):getNodeAt(0):toInt()
                local map_main_story = getConfig(game_config_field.map_main_story);
                local cityid_cityorderid = getConfig(game_config_field.cityid_cityorderid);

                local city_id = cityid_cityorderid:getNodeWithKey(tostring(stage_id)):toStr()
                local function responseMethod(tag,gameData)
                    game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                    game_scene:enterGameUi("game_small_map_scene",{bgMusic = bgMusic,open_building_id = temp});
                    self:destroy();
                end
                local main_story_item = map_main_story:getNodeWithKey(tostring(city_id));
                local params = {}
                params.city = tostring(stage_id);
                params.chapter = main_story_item:getNodeWithKey("stage_id"):toInt()
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open")
            -- elseif index == 1 then--直接出战
            elseif com_id < 2000 then--直接出战
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("map_world_scene",{gameData = gameData});
                    self:destroy();
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
            end
        end
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local dataIndex = math.floor(btnTag / 1000)
        local rewardIndex = math.floor(btnTag % 10)
        

        local itemData = showData[dataIndex + 1].data.reward
        game_util:lookItemDetal(itemData[rewardIndex])
    end
    self.m_guide_node = nil
  local reward_pos = {
        {0},
        {-30,30},
        {-55,0,55},
        {-75,-25,25,75},
    }
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = #showData;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    params.touchPriority = GLOBAL_TOUCH_PRIORITY ; --列
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_fuli_content_award_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local title_sprite = ccbNode:spriteForName("title_sprite")
            local story_label = ccbNode:labelTTFForName("story_label")
            local reward_node = ccbNode:nodeForName("reward_node")
            local btn_go = ccbNode:controlButtonForName("btn_go")
            btn_go:setVisible(true)
            local alpha_layer = ccbNode:layerForName("alpha_layer")
            local particle = ccbNode:particleForName("particle")
            local countdown_label = ccbNode:nodeForName("countdown_label")
            local m_sprite_aleradyget = ccbNode:spriteForName("m_sprite_aleradyget")
            m_sprite_aleradyget:setVisible(false)
            local m_scale9sprite_backboard = ccbNode:scale9SpriteForName("m_scale9sprite_backboard")

            btn_go:setTouchPriority( GLOBAL_TOUCH_PRIORITY -1)
            if self.select_index == index + 1 then
                alpha_layer:setVisible(false)
            else
                alpha_layer:setVisible(true)
            end

            local itemData = showData[index + 1]
            local story = itemData.data.story 
            local reward = itemData.data.reward

            local com_id = itemData.cid
            if com_id < 1000 then--在线
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_online.png"))
            elseif com_id > 1000 and com_id < 2000 then--等级
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_lv.png"))
            elseif com_id > 2000 and com_id < 3000 then--关卡
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_pve.png"))
            elseif com_id > 3000 then--竞技场
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_pvp.png"))
            end
            btn_go:setTag( index )

            reward_node:removeAllChildrenWithCleanup(true)
            story_label:setString(story)
            if com_id < 1000 and index == 0 then
                story_label:removeAllChildrenWithCleanup(true)
                local item = self.result[tostring(com_id)]
                local time_all = item[2]
                local time_go = item[1]
                local time_left = time_all - time_go
                local function timeOverCallFun(label,type)
                    label:removeFromParentAndCleanup(true);
                    --可领取
                    self.result[tostring(com_id)][3] = 1
                    self:refreshUi()
                end
                local timeLabel = game_util:createCountdownLabel(time_left,timeOverCallFun,8,1)
                -- timeLabel:setColor(color[i])
                timeLabel:setAnchorPoint(ccp(0.5,0.5))
                -- story_label:addChild(timeLabel,10,10)
                countdown_label:addChild(timeLabel,10,10)
            else
                countdown_label:removeAllChildrenWithCleanup(true)
                -- story_label:removeAllChildrenWithCleanup(true)
            end
            local item = self.result[tostring(com_id)]
            particle:setVisible(false)
            local status = item[3]
            -- cclog2(item, "item  ===  ")
            -- cclog2(com_id, "com_id  ===  ")

            m_sprite_aleradyget:setVisible(false)
            if status == 1 and index == 0 then--领奖按钮
                game_util:setCCControlButtonBackground(btn_go,"award_btn_get.png")
                game_util:createPulseAnmi("award_btn_get.png",btn_go)
                m_scale9sprite_backboard:setColor(ccc3(255, 255, 255))
                -- particle:setVisible(true)
                -- alpha_layer:setVisible(false)
                self.m_guide_node = btn_go
            elseif status == 2 then
                m_scale9sprite_backboard:setColor(ccc3(255, 255, 255))
                m_sprite_aleradyget:setVisible(true)
                btn_go:setVisible(false)
            elseif index == 0 then--挑战
                -- particle:setVisible(false)
                m_scale9sprite_backboard:setColor(ccc3(155, 155, 155))
                game_util:setCCControlButtonBackground(btn_go,"award_btn_go.png")
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(0.4,ccp(167,4)));
                animArr:addObject(CCMoveTo:create(0.3,ccp(153,4)));
                animArr:addObject(CCMoveTo:create(0.15,ccp(159,4)));
                animArr:addObject(CCMoveTo:create(0.15,ccp(157,4)));
                animArr:addObject(CCDelayTime:create(0.8));
                btn_go:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
            else
                -- alpha_layer:setVisible(true)
                btn_go:removeAllChildrenWithCleanup(true)
                btn_go:setVisible(false)
            end
            -- self.alpha_layer:setVisible(false)
            
            local posTable = reward_pos[#reward]
            for i=1, #reward do
                local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                bgLayer:setAnchorPoint(ccp(0.5,0.5))
                bgLayer:ignoreAnchorPointForPosition(false);

                local bgSprite = CCSprite:createWithSpriteFrameName("public_faguang.png");
                bgSprite:setScale(0.8)
                bgSprite:setAnchorPoint(ccp(0.5,0.5))

                local itemRewardData = reward[i]
                local reward_icon,name,count = game_util:getRewardByItemTable(itemRewardData,true);
                if reward_icon then
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.8)
                    reward_icon:setPosition(ccp(posTable[i],0))
                    if status == 1 then--领奖按钮
                        reward_node:addChild(bgLayer)
                        reward_node:addChild(bgSprite)
                    end
                    reward_node:addChild(reward_icon)
                    bgLayer:setPosition(ccp(posTable[i],0))
                    bgSprite:setPosition(ccp(posTable[i],0))
                    --加查看按钮
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    -- button:setTag((index) * 10 + i)
                    button:setTag( i + index * 1000 )
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(posTable[i],0))
                    button:setOpacity(0)
                    reward_node:addChild(button)
                    if count then
                        local label = game_util:createLabelTTF({text = "×"..count,color = ccc3(250,250,250),fontSize = 12})
                        label:setAnchorPoint(ccp(0.5,0.5))
                        label:setPosition(ccp(posTable[i],-20))
                        reward_node:addChild(label)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_fuli_subui_award.refreshUi(self)
    -- self:createOnlineReward()
    self.m_node_awardview_board:removeAllChildrenWithCleanup(true)
    local tableView = self:createRewardTableView( self.m_node_awardview_board:getContentSize(), gameData )
    self.m_node_awardview_board:addChild( tableView, 10, 10 )
    -- local count = self.m_onceData[self.m_cur_showawardType].getcount
    -- game_util:setTableViewIndex(count - 1,self.m_node_awardview_board,10, 3)
    local id = game_guide_controller:getIdByTeam("7");
    -- print("game_guide_controller:getIdByTeam(7)", id)
    if id == 703 then
        if self.m_guide_node == nil then
            self:gameGuide("show", "7", 704)
        end
    end
end

function game_fuli_subui_award.refreshUIByType( self, openType )
    if self.m_cur_showawardType == openType then
        return
    end
    self.m_cur_showawardType = openType
    self:refreshUi()
end

function game_fuli_subui_award.refreshCurData( self )
    local onceCfg = getConfig(game_config_field.reward_once); 
    local onceData = onceCfg and json.decode(onceCfg:getFormatBuffer()) or {}
    local maxCount = onceCfg:getNodeCount()
    self.m_onceData = nil
    self.m_cur_reward = {online = false, level = false, advanture = false, arena = false}
    self.m_onceData = {online = {data = {}, getcount = 0}, level = {data = {},getcount = 0}, 
    advanture = {data = {}, getcount = 0}, arena = {data = {}, getcount = 0}}
    -- 获取online奖励列表
    for i = 1, maxCount do
        --先遍历出1000+的再遍历出2000+的以此类推
        local oneitem = onceCfg:getNodeAt(tostring( i - 1 ))
        local key = oneitem:getKey() or ""
        local cid = tonumber(key)
        local itemData = json.decode(oneitem:getFormatBuffer())
        local openType = nil
        if tonumber(key) <= 1000 then
            openType = "online"
        elseif tonumber(key) > 1000 and tonumber(key) < 2000 then
            openType = "level"
        elseif tonumber(key) > 2000 and tonumber(key) < 3000 then
            openType = "advanture"
        elseif tonumber(key) > 3000 and tonumber(key) < 4000 then
            openType = "arena"
        end

        local resultItem = self.result[ tostring(cid) ]
        local info = {}
        info.cid = cid
        info.data = itemData
        info.isGet = false
        if resultItem and resultItem[3] ~= 2 then
            info.isGet = false
            self.m_onceData[openType].getcount = self.m_onceData[openType].getcount + 1
            table.insert(self.m_onceData[openType].data, info)
        end
        if resultItem and  resultItem[3] == 1 and self.m_cur_reward[openType] == false then
            self.m_cur_reward[openType] = true
        end
    end
    function sortFun( data1, data2 )
        return data1.cid < data2.cid
    end
    table.sort(self.m_onceData.online.data, sortFun)
    table.sort(self.m_onceData.level.data, sortFun)
    table.sort(self.m_onceData.advanture.data, sortFun)
    table.sort(self.m_onceData.arena.data, sortFun)
    -- cclog2
end

--[[
    当前显示的是否有奖励可以领取
]]

--[[--
    初始化
]]
function game_fuli_subui_award.init(self,t_params)
    t_params = t_params or {};
    self.m_parentCloseBtn = t_params.parentCloseBtn
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local temp = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp
    end
    self.result = self.m_tGameData.once.result
    self.m_cur_showawardType = t_params.openType or "level"
    self:refreshCurData()
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_award.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    -- local m_shared = 0;
    -- function tick( dt )
    --     scheduler.unschedule(m_shared)
    --     self:guideHelper()
    -- end
    -- m_shared = scheduler.schedule(tick, 0.1, false)

    local m_shared = 0;
    function tick( dt )
        scheduler.unschedule(m_shared)
        local id = game_guide_controller:getIdByTeam("7");
        print("game_guide_controller:getIdByTeam(7)", id)
        -- id = 703
        if id == 703 then
            self:gameGuide("show","7", 703)
        end
    end
    m_shared = scheduler.schedule(tick, 0.1, false)
    return scene;
end



function game_fuli_subui_award.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" and id == 707 then
            local function endCallFunc()
                game_guide_controller:gameGuide("show","7",707)
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
    elseif guideType == "show" and id == 703 then
        local function endCallFunc()
            -- self:gameGuide("show","7",708)
        end
        t_params.guideType = "show";
        -- t_params.endCallFunc = endCallFunc;
        t_params.tempNode = self.m_guide_node
        game_guide_controller:gameGuide("show","7",703, t_params)
    elseif guideType == "show" and id == 704 then
        local function endCallFunc()
            -- game_guide_controller:sendGuideData("7", 705)
            game_guide_controller:setGuideData("7",706);
        end
        t_params.guideType = "show";
        t_params.endCallFunc = endCallFunc;
        t_params.tempNode = self.m_parentCloseBtn
        game_guide_controller:gameGuide("show","7",704, t_params)
        game_guide_controller:setGuideData("7", 705)
    end
end





-- --[[
--     -- 本场景新手引导入口
-- ]]
-- function game_fuli_subui_award.forceGuideFun( self, forceInfo )
--     -- cclog2(forceInfo, "forceInfo   ====   ")
--     -- cclog2(self.m_guide_node, "self.m_guide_node   ====   ")
--     if forceInfo and forceInfo.game_fuli_subui_award then
--         local guideInfo = forceInfo.game_fuli_subui_award or {}
--         local showType  = guideInfo.guideType
--         if showType ~= self.m_cur_showawardType then return end

--         if self.m_guide_node then
--             local t_params = {}
--             t_params.tempNode = self.m_guide_node
--             t_params.clickCallFunc = function (  )
--                 -- cclog2("click")
--                 self.m_guide_node = nil
--             end
--             t_params.skipFunc = function (  )
--                 if type(forceInfo.guideEndfun) == "function" then
--                     forceInfo.guideEndfun( forceInfo.guide_team )
--                 end
--             end
--             game_scene:addGuidePop( t_params )
--         elseif self.m_parentCloseBtn then
--             local t_params = {}
--             t_params.tempNode = self.m_parentCloseBtn
--             t_params.clickCallFunc = function (  )
--                 -- cclog2("click")
--                 game_scene:removeGuidePop()
--             end
--             t_params.skipFunc = function (  )
--                 if type(forceInfo.guideEndfun) == "function" then
--                     forceInfo.guideEndfun( forceInfo.guide_team )
--                 end
--             end
--             game_scene:addGuidePop( t_params )
--         end
--     end
-- end

-- --[[
--     检查时候需要新手引导
-- ]]
-- function game_fuli_subui_award.guideHelper( self )
--     -- cclog2("player_level_up_pop  guideHelper  ======  ")
--     local force_guide = game_data:getForceGuideInfo()
--     cclog2(force_guide, "force_guide   ======  ")
--     if type(force_guide) == "table" and force_guide.game_fuli_subui_award then
--         self:forceGuideFun( force_guide )
--         return true
--     end
--     return false
-- end

return game_fuli_subui_award