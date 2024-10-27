---  星灵悬赏
local game_offer = {
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
};
--[[--
    销毁ui
]]
function game_offer.destroy(self)
    -- body
    cclog("-----------------game_offer destroy-----------------");

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
end
--[[--
    返回
]]
function game_offer.back(self,backType)
    local function responseMethod(tag,gameData)
        game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
        game_scene:enterGameUi("game_small_map_scene",{gameData = gameData});
        self:destroy();
    end
    if self.m_open_type == 1 then
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, {city = game_data:getSelCityId()},"private_city_open")
    else
        game_scene:enterGameUi("game_main_scene",{gameData = nil});
        self:destroy();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_offer.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_offer.ccbi");

    self.offer_node = ccbNode:nodeForName("offer_node")
    self.content_table_node = ccbNode:nodeForName("content_table_node")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    return ccbNode;
end
--[[
    创建章节信息table
]]
function game_offer.createSectionTableView(self,viewSize)
    cclog("self.wanted_data = " .. json.encode(self.wanted_data))
    local mapCfg = getConfig(game_config_field.map_main_story)
    local wantedCfg = getConfig(game_config_field.wanted)
    local level = game_data:getUserStatusDataByKey("level")
    local function onCellBtnClick( target,event )
        -- self.last_select:setEnabled(true)

        -- local btn = tolua.cast(target,"CCControlButton")
        -- cclog("btn == ".. btn:getTag())
        -- btn:setEnabled(false)
    end
    local chapterCount = #self.chapter_detail
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = chapterCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_offer_left_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --            
            -- local chapter_btn = ccbNode:controlButtonForName("chapter_btn")
            local sprite_back = ccbNode:spriteForName("sprite_back")
            local title_label = ccbNode:labelTTFForName("title_label")
            local perfect_sprite = ccbNode:spriteForName("perfect_sprite")

            local chapterItem = mapCfg:getNodeWithKey(tostring(self.chapter_detail[index + 1]))
            local wanted_name = chapterItem:getNodeWithKey("stage_name"):toStr()
            local open_level = chapterItem:getNodeWithKey("open_level"):toInt()

            title_label:setString(wanted_name)
            -- chapter_btn:setTag(101 + index)
            if index == self.select_index then
                -- self.last_select = chapter_btn;
                -- self.last_select:setEnabled(false)  offer_btn_down     offer_btn_nomal
                self.last_select = cell;
                sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_nomal.png"));
                title_label:setColor(ccc3(0,0,0))
            else
                -- sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_nomal.png"));
                --未开启的置灰
                if open_level > level then
                    sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_nomal.png"));
                    title_label:setColor(ccc3(0,0,0))
                else
                    sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_down.png"));
                    title_label:setColor(ccc3(188,188,188))
                end
            end
            --显示完美
            local all_progress = {}
            local wanted = mapCfg:getNodeWithKey(tostring(self.chapter_detail[index + 1])):getNodeWithKey("wanted")
            for i=1,wanted:getNodeCount() do
                local wanted_id = wanted:getNodeAt(i-1):toInt()    
                -- local progress = {}  -- 这个地方有问题 
                local progress = {0,0,0}  -- 当地图完全收复之后，服务器返回值wantend_data = {}  不执行下面的for循环
                for key,value in pairs(self.wanted_data) do
                    if tostring(key) == tostring(wanted_id) then
                        progress = value
                        break;
                    else
                        --显示已完成
                        progress = {0,0,0}
                    end
                end
                all_progress[i] = progress
            end
            local perfect_flag = false
            for i=1,#all_progress do
                local flag = all_progress[i][2]
                if flag == 0 then
                    perfect_flag = true
                else
                    perfect_flag = false
                    break
                end
            end
            if perfect_flag then
                perfect_sprite:setVisible(true)
            else
                perfect_sprite:setVisible(false)
            end
        end
        cell:setTag(index)
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");

            local chapterItem = mapCfg:getNodeWithKey(tostring(self.chapter_detail[index + 1]))
            local open_level = chapterItem:getNodeWithKey("open_level"):toInt()
            if open_level <= level then
                local last_tag = self.last_select:getTag()
                local chapterItem = mapCfg:getNodeWithKey(tostring(self.chapter_detail[last_tag + 1]))
                if chapterItem:getNodeWithKey("open_level"):toInt() <= level then
                    if self.last_select and self.last_select ~= item then
                        local lastCcbNode = tolua.cast(self.last_select:getChildByTag(10),"luaCCBNode");
                        local last_back_alpha = lastCcbNode:spriteForName("sprite_back");
                        local last_title_label = lastCcbNode:labelTTFForName("title_label")
                        last_back_alpha:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_down.png"));
                        last_title_label:setColor(ccc3(188,188,188))
                    end
                end
                local sprite_back = ccbNode:spriteForName("sprite_back")
                local title_label = ccbNode:labelTTFForName("title_label")
                sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_btn_nomal.png"));
                title_label:setColor(ccc3(0,0,0))

                self.last_select = item;
                self.select_index = index

                self:refreshTab2()
            else

            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建显示奖励
]]
function game_offer.addRewardPop(self,reward)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/gift_show_pop.ccbi");
    -- ccbNode:setAnchorPoint(ccp(0.5,0.5))
    -- ccbNode:setPosition(ccp(0,0))
    local m_touch_layer = ccbNode:layerForName("m_touch_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then 
            if self.m_item_pop then
                self.m_item_pop:removeAllChildrenWithCleanup(true);
                self.m_item_pop = nil;
            end
            return true;
        end
    end
    m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_touch_layer:setTouchEnabled(true)

    local item_node = {}
    
    local count_label = {}

    local rewardCout = #reward;
    for i=1,rewardCout do
        item_node[i] = ccbNode:nodeForName("item_node"..i)
        count_label[i] = ccbNode:labelBMFontForName("count_label"..i)
        count_label[i]:setString("")
        local itemData = reward[i]
        local icon,name,count = game_util:getRewardByItemTable(itemData,true);
        if icon then
            icon:setScale(0.7)
            icon:setAnchorPoint(ccp(0.5,0.5))
            local iconSize = icon:getContentSize()
            icon:setPosition(ccp(iconSize.width*0.5*0.7,iconSize.height*0.5*0.7))
            item_node[i]:removeAllChildrenWithCleanup(true);
            item_node[i]:addChild(icon)
        end
        if count then
            count_label[i]:setString("×"..count)
        end
    end
    return ccbNode
end
--[[
    创建章节内容table
]]
function game_offer.createContentTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    local wantedCfg = getConfig(game_config_field.wanted)
    local mapCfg = getConfig(game_config_field.map_main_story)
    local mapItemCfg = mapCfg:getNodeWithKey(tostring(self.chapter_detail[self.select_index + 1]))
    if mapItemCfg == nil then return nil end
    local wanted = mapItemCfg:getNodeWithKey("wanted")

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag > 10000 then--查看奖励
            local wanted_id = btnTag - 10000
            local wanted_id = wantedCfg:getNodeWithKey(tostring(wanted_id))
            local reward = wanted_id:getNodeWithKey("reward")
            local rewart_table = json.decode(reward:getFormatBuffer())
            
            if self.m_item_pop then
                self.m_item_pop:removeAllChildrenWithCleanup(true);
                self.m_item_pop = nil;
            end
            self.m_item_pop = self:addRewardPop(rewart_table)
            self.m_item_pop:setAnchorPoint(ccp(0,0.5));
            local pX,pY = tagNode:getPosition();
            local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX+140,pY+75))
            self.m_item_pop:setPosition(tempPos);
            game_scene:getPopContainer():addChild(self.m_item_pop)
        elseif btnTag > 1000 and btnTag < 10000 then--领取或挑战
            local wanted_id = btnTag
            -- "110004"
            -- "110"
            if self.goto_table[tostring(wanted_id)] == 1 then--1是挑战
                local itemData = wantedCfg:getNodeWithKey(tostring(wanted_id))
                local target_sort = itemData:getNodeWithKey("target_sort"):toInt()
                local stage_id = nil;
                local temp = nil;
                if target_sort == 100 then--跳到城市
                    stage_id = itemData:getNodeWithKey("target_data"):getNodeAt(0):toInt()
                else--跳到城市且跳到板块
                    temp = itemData:getNodeWithKey("target_data"):getNodeAt(0):toStr()
                    stage_id = string.sub(temp,1,3)
                end

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
            elseif self.goto_table[tostring(wanted_id)] == 2 then--2是领取
                local function resRewardPonseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);

                    local temp = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                    self.wanted_data = temp.wanted.result
                    self:refreshTab2()
                end
                local params = {}
                params.award_id = tostring(wanted_id)
                network.sendHttpRequest(resRewardPonseMethod,game_url.getUrlForKey("wanted_award"), http_request_method.GET, params,"wanted_award")
            else

            end 
        end
    end
    local fightCount = wanted:getNodeCount();
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 1; --列
    params.totalItem = fightCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_offer_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            local reward_btn = ccbNode:controlButtonForName("reward_icon")
            local complete_sprite = ccbNode:spriteForName("complete_sprite")
            local content_label = ccbNode:labelTTFForName("content_label")
            local btn_fight = ccbNode:controlButtonForName("btn_fenjie")
            game_util:setCCControlButtonTitle(btn_fight,string_helper.ccb.title133)
            local progress_node = ccbNode:nodeForName("progress_node")
            
            complete_sprite:setTag(999)
            local wanted_id = wanted:getNodeAt(index):toInt()
            local wantedItem = wantedCfg:getNodeWithKey(tostring(wanted_id))
            local wanted_name = wantedItem:getNodeWithKey("name")
            local wanted_story = wantedItem:getNodeWithKey("story"):toStr()

            content_label:setString(wanted_story)

            reward_btn:setTag(wanted_id + 10000)
            btn_fight:setTag(wanted_id)
            -- 另一处
            local progress = {0,0,0}
            for key,value in pairs(self.wanted_data) do
                if tostring(key) == tostring(wanted_id) then
                    progress = value
                    self.wanted_id = key
                    break;
                else
                    --显示已完成
                    progress = {0,0,0}
                end
            end
            if progress[2] == 0 then
                complete_sprite:setVisible(true)
                complete_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_get_reward.png"));
                btn_fight:setEnabled(false)
                btn_fight:setTitleForState(CCString:create(string_helper.game_offer.ygt),CCControlStateDisabled)
                btn_fight:setTitleColorForState(ccc3(188,188,188),CCControlStateDisabled)
                self.goto_table[tostring(wanted_id)] = 0
            elseif progress[2] then
                local progress_bar = ExtProgressBar:createWithFrameName("o_public_skillExpBg.png","o_public_skillExp.png",CCSizeMake(50,10));
                progress_bar:setAnchorPoint(ccp(0.5,0.5))
                progress_bar:setPosition(ccp(0,0))
                progress_bar:setMaxValue(progress[2]);
                progress_bar:setCurValue(progress[1],false);
                progress_node:addChild(progress_bar,10)

                local barTTF = CCLabelTTF:create(progress[1].."/"..progress[2],TYPE_FACE_TABLE.Arial_BoldMT,10);
                barTTF:setColor(ccc3(0,0,0))
                barTTF:setAnchorPoint(ccp(0.5,0.5))
                barTTF:setPosition(ccp(0,0))
                progress_node:addChild(barTTF,10)

                if progress[3] == 1 then
                    complete_sprite:setVisible(true)
                    complete_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("offer_complete.png")); 
                    btn_fight:setTitleForState(CCString:create(string_helper.game_offer.gt),CCControlStateNormal)
                    btn_fight:setEnabled(true)
                    self.goto_table[tostring(wanted_id)] = 2
                else
                    complete_sprite:setVisible(false)
                    btn_fight:setTitleForState(CCString:create(string_helper.game_offer.challage),CCControlStateNormal)
                    btn_fight:setEnabled(true)
                    self.goto_table[tostring(wanted_id)] = 1
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_offer.refreshUi(self)
    self:refreshTab1()
    self:refreshTab2()
end
--[[
    刷新表1
]]
function game_offer.refreshTab1(self)
    self.offer_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createSectionTableView(self.offer_node:getContentSize())
    tempTable:setScrollBarVisible(false)
    self.offer_node:addChild(tempTable,10,10);

    game_util:setTableViewIndex(self.select_index,self.offer_node,10,5)
end
--[[
    刷新表2
]]
function game_offer.refreshTab2(self)
    self.content_table_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createContentTableView(self.content_table_node:getContentSize())
    if textTableTemp then
        textTableTemp:setScrollBarVisible(false)
        self.content_table_node:addChild(textTableTemp);
    end
end
--[[
    设置当前关卡的索引
]]
function game_offer.setCurIndex(self)
    local mapCfg = getConfig(game_config_field.map_main_story)
    local city = game_data:getSelCityId()
    -- cclog("city == " .. city)
    local index = 1
    for i=1,#self.chapter_detail do
        local key = tostring(self.chapter_detail[i])
        local stage_id = mapCfg:getNodeWithKey(key):getNodeWithKey("stage_id"):toStr()
        -- cclog("stage_id == " .. stage_id)
        if stage_id == tostring(city) then
            index = i
            break;
        end
    end
    self.select_index = index - 1
end
--[[--
    初始化
]]
function game_offer.init(self,t_params)
    t_params = t_params or {};
    -- self.select_index = 0;
    self.chapter_detail = {}
    self.goto_table = {}
    self.m_open_type = t_params.openType or 1

    local mapCfg = getConfig(game_config_field.map_main_story)
    local wantedCfg = getConfig(game_config_field.wanted)
    local level = game_data:getUserStatusDataByKey("level")

    for i=1,mapCfg:getNodeCount() do
        local wantedItem = mapCfg:getNodeWithKey(tostring(i))
        if wantedItem then
            local wanted = wantedItem:getNodeWithKey("wanted")
            local open_level = wantedItem:getNodeWithKey("open_level"):toInt()
            if wanted:getNodeCount() > 0 and level >= open_level then
                table.insert(self.chapter_detail,i)
            end
        end
    end
    self:setCurIndex()
    -- cclog("gameData == " .. json.encode(t_params.gameData))
    self.wanted_data = t_params.gameData.wanted_data.result
    -- cclog("self.wanted_data == " .. json.encode(self.wanted_data))
    self.m_item_pop = nil;
end

--[[--
    创建ui入口并初始化数据
]]
function game_offer.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    return scene;
end

return game_offer;