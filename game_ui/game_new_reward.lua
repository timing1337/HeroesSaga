---  领奖
local game_new_reward = {
    offer_node = nil,
    content_table_node = nil,
    m_close_btn = nil,

    last_select = nil,
    chpater_index = nil,
    select_index = nil,

    chapter_detail = nil,

    wanted_data = nil,

    wanted_id = nil,
    goto_table = nil,
    m_item_pop = nil,
    m_open_type = nil,
    result = nil,
    reward_index = nil,
    award_table_node = nil,
    award_table = nil,

    show_award_table = nil,--最终显示的数据
};
--[[--
    销毁ui
]]
function game_new_reward.destroy(self)
    -- body
    cclog("-----------------game_new_reward destroy-----------------");

    self.offer_node = nil;
    self.content_table_node = nil;
    self.m_close_btn = nil;

    self.last_select = nil;
    self.chpater_index = nil;
    self.select_index = nil;

    self.chapter_detail = nil;
    self.wanted_data = nil;
    self.wanted_id = nil;
    self.goto_table = nil;
    self.m_item_pop = nil;
    self.m_open_type = nil;
    self.result = nil;
    self.reward_index = nil;
    self.award_table_node = nil;
    self.award_table = nil;
    self.show_award_table = nil;
end
--[[--
    返回
]]
function game_new_reward.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_new_reward.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_award_new.ccbi");

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.award_table_node = ccbNode:nodeForName("award_table_node")
    return ccbNode;
end

--[[
    右边table
]]
function game_new_reward.createContentTableView(self,viewSize)
    local reward_pos = {
        {0},
        {-30,30},
        {-55,0,55},
        {-75,-25,25,75},
    }
    local onceCfg = getConfig(game_config_field.reward_once); 
    -- local indexTable = {}
    -- for i=1,onceCfg:getNodeCount() do
    --     local itemCfg = onceCfg:getNodeAt(i-1)
    --     local key = itemCfg:getKey()
    --     local key_int = tonumber(key)
    --     if self.select_index * 1000 < key_int and (self.select_index+1) * 1000 > key_int then
    --         table.insert(indexTable,key_int)
    --     end
    -- end
    -- local contentTable = {}
    -- local tonumber = tonumber;
    -- local function sortFunc(data1,data2)
    --     return tonumber(data1) < tonumber(data2)
    -- end
    -- table.sort(indexTable,sortFunc)
    -- cclog("indexTable = " .. json.encode(indexTable))
    -- -- json.decode(itemCfg:getFormatBuffer()
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog("btnTag = " ..btnTag)
        if btnTag > 10000 then--查看奖励
        elseif btnTag >= 1000 and btnTag < 10000 then--领奖
            local index = btnTag - 1000
            local com_id = self.award_table[index]
            local item = self.result[tostring(com_id)]
            local status = item[3]
            cclog("com_id == " .. com_id)
            cclog("status == " .. status)
            if status == 1 then--领奖按钮
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    -- cclog("data = " .. data:getFormatBuffer())
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    self.result = json.decode(data:getNodeWithKey("once"):getNodeWithKey("result"):getFormatBuffer())
                    self:refreshUi()
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
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local btnType = math.floor(btnTag / 10)
        local index = math.floor(btnTag % 10)
        local com_id = self.award_table[btnType]
        cclog("btnType = " .. btnType)
        -- local com_id = self.show_award_table[btnType]
        cclog("com_id == " .. com_id)
        local itemCfg = onceCfg:getNodeWithKey(tostring(com_id))
        local reward = itemCfg:getNodeWithKey("reward")
        local itemData = json.decode(reward:getNodeAt(index-1):getFormatBuffer())
        game_util:lookItemDetal(itemData)
    end
    -- local fightCount = #indexTable
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 1; --列
    params.totalItem = #self.show_award_table;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_award_new_item.ccbi");
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
            local alpha_layer = ccbNode:layerForName("alpha_layer")
            local particle = ccbNode:particleForName("particle")
            local countdown_label = ccbNode:nodeForName("countdown_label")
            -- if self.select_index == index + 1 then
            --     alpha_layer:setVisible(false)
            -- else
            --     alpha_layer:setVisible(true)
            -- end
            local com_id = self.show_award_table[index+1]
            if com_id < 1000 then--在线
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_online.png"))
                btn_go:setTag(1000)
            elseif com_id > 1000 and com_id < 2000 then--等级
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_lv.png"))
                btn_go:setTag(1001)
            elseif com_id > 2000 and com_id < 3000 then--关卡
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_pve.png"))
                btn_go:setTag(1002)
            elseif com_id > 3000 then--竞技场
                title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("award_pvp.png"))
                btn_go:setTag(1003)
            end
            local itemCfg = onceCfg:getNodeWithKey(tostring(com_id))
            local story = itemCfg:getNodeWithKey("story"):toStr()
            local reward = itemCfg:getNodeWithKey("reward")
            reward_node:removeAllChildrenWithCleanup(true)
            story_label:setString(story)
            if com_id < 1000 then
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
            if status == 1 then--领奖按钮
                game_util:setCCControlButtonBackground(btn_go,"award_btn_get.png")
                game_util:createPulseAnmi("award_btn_get.png",btn_go)
                -- particle:setVisible(true)
                alpha_layer:setVisible(false)
            else--挑战
                -- particle:setVisible(false)
                game_util:setCCControlButtonBackground(btn_go,"award_btn_go.png")
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(0.4,ccp(167,4)));
                animArr:addObject(CCMoveTo:create(0.3,ccp(153,4)));
                animArr:addObject(CCMoveTo:create(0.15,ccp(159,4)));
                animArr:addObject(CCMoveTo:create(0.15,ccp(157,4)));
                animArr:addObject(CCDelayTime:create(0.8));
                btn_go:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
                alpha_layer:setVisible(true)
            end
            
            local posTable = reward_pos[reward:getNodeCount()]
            for i=1,reward:getNodeCount() do
                local bgLayer = CCLayerColor:create(ccc4(255,255,255,255),36,36);
                bgLayer:setAnchorPoint(ccp(0.5,0.5))
                bgLayer:ignoreAnchorPointForPosition(false);

                local bgSprite = CCSprite:createWithSpriteFrameName("public_faguang.png");
                bgSprite:setScale(0.8)
                bgSprite:setAnchorPoint(ccp(0.5,0.5))

                local itemData = reward:getNodeAt(i-1)
                local reward_icon,name,count = game_util:getRewardByItem(itemData,true);
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
                    if com_id < 1000 then--在线
                        button:setTag(i)
                    elseif com_id > 1000 and com_id < 2000 then--等级
                        button:setTag(10 + i)
                    elseif com_id > 2000 and com_id < 3000 then--关卡
                        button:setTag(20 + i)
                    elseif com_id > 3000 then--竞技场
                        button:setTag(30 + i)
                    end
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
function game_new_reward.refreshUi(self)
    self:getRewardPos()
    self:refreshTab1()
    self:refreshTab2()
end
--[[
    刷新表1
]]
function game_new_reward.refreshTab1(self)

end
--[[
    刷新表2
]]
function game_new_reward.refreshTab2(self)
    self.award_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createContentTableView(self.award_table_node:getContentSize())
    textTableTemp:setScrollBarVisible(false)
    -- textTableTemp:setMoveFlag(false)
    self.award_table_node:addChild(textTableTemp,10,10);
    -- local showIndex = self.reward_index
    -- game_util:setTableViewIndex(showIndex-1,self.content_table_node,10,3)
    --定位
    local onlineItem = self.show_award_table[1]
    local arenaItem = self.show_award_table[4]
    -- self.result[tostring(arenaItem)][3] = 1
    if onlineItem and arenaItem then
        if self.result[tostring(onlineItem)][3] and self.result[tostring(arenaItem)][3] then
            if self.result[tostring(onlineItem)][3] == 0 and  self.result[tostring(arenaItem)][3] == 1 then
                game_util:setTableViewIndex(1,self.award_table_node,10,3)
            end
        end
    end
end
--[[
    锁定位置
]]
function game_new_reward.getRewardPos(self)
    local online_count = 0
    local level_count = 0
    local advanture_count = 0
    local arena_count = 0

    -- cclog("self.result = " .. json.encode(self.result))
    for key,value in pairs(self.result) do
        --先遍历出1000+的再遍历出2000+的以此类推
        if tonumber(key) <= 1000 then
            online_count = online_count + 1
        elseif tonumber(key) > 1000 and tonumber(key) < 2000 then
            level_count = level_count + 1
        elseif tonumber(key) > 2000 and tonumber(key) < 3000 then
            advanture_count = advanture_count + 1
        elseif tonumber(key) > 3000 and tonumber(key) < 4000 then
            arena_count = arena_count + 1
        end
    end
    local com_index = 1
    local com_type = 1
    local com_flag = false -- 是否完成的flag 如果有完成的为true 否则继续遍历得到最近一个未完成的
    -- self.result["3025"][3] = 2
    -- self.result["1019"][3] = 2
    local function getComId(count,comType)
        self.award_table[comType] = (comType * 1000) + 1
        for i=1,count do
            -- cclog("(comType * 1000) + i == " .. (comType * 1000) + i)
            local item = self.result[tostring((comType * 1000) + i)]
            local status = item[3]
            -- cclog("status == " .. i .. " == == == " .. status ..  "type = " .. comType)
            if status == 1 then--筛选出来
                com_type = comType
                com_id = (comType * 1000) + i
                self.award_table[comType] = com_id
                com_index = i
                com_flag = false
                break
            else
                com_flag = true
            end
        end
        if com_flag == true then
            for i=1,count do
                local item = self.result[tostring((comType * 1000) + i)]
                local status = item[3]
                if status == 0 then--筛选出来
                    com_type = comType
                    com_id = (comType * 1000) + i
                    self.award_table[comType] = com_id
                    com_index = i
                    break
                end
            end
        end
    end
    self.award_table = {}
    getComId(online_count,0)
    getComId(level_count,1)
    getComId(advanture_count,2)
    getComId(arena_count,3)
    cclog("self.award_table == " .. json.encode(self.award_table))
    self.show_award_table = {}
    -- cclog("online_count == " .. online_count)
    local last_table = {online_count,level_count,advanture_count,arena_count}
    --取最后一个数据，如果status是2则说明所有奖励都已经领完了
    for i=1,4 do  
        local last_index = ((i-1) * 1000) + last_table[i]
        cclog("last_index = " .. last_index)
        local item = self.result[tostring(last_index)] or {2,2,2}
        local status = item[3]
        if status ~= 2 then
            table.insert(self.show_award_table,self.award_table[i-1])
        end
    end
    -- self.show_award_table = {1020,2001,3003}
    cclog("self.show_award_table = " .. json.encode(self.show_award_table))
    -- return com_index,com_type
end
--[[--
    初始化
]]
function game_new_reward.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local temp = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer())
        self.m_tGameData = temp
    end
    self.result = self.m_tGameData.once.result
    -- cclog("self.result == " .. json.encode(self.result))
end

--[[--
    创建ui入口并初始化数据
]]
function game_new_reward.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    return scene;
end

return game_new_reward;