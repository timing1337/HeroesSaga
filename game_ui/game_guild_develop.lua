---  公会开发

local game_guild_develop = {
    m_list_view_bg = nil,
    m_integration_label = nil,
    m_progress_bar = nil,
    m_num_label = nil,
    m_intro_label = nil,
    m_pop_ui = nil,
    m_jobType = nil,
    m_set_develop_btn = nil,
    m_selListItem = nil,
    m_selListIndex = nil,
    m_sel_type_level_label = nil,
    m_donationValue = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
    m_tab_btn_4 = nil,
    m_building_lv_label = nil,
};
--[[--
    销毁ui
]]
function game_guild_develop.destroy(self)
    -- body
    cclog("-----------------game_guild_develop destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_integration_label = nil;
    self.m_progress_bar = nil;
    self.m_num_label = nil;
    self.m_intro_label = nil;
    self.m_pop_ui = nil;
    self.m_jobType = nil;
    self.m_set_develop_btn = nil;
    self.m_selListItem = nil;
    self.m_selListIndex = nil;
    self.m_sel_type_level_label = nil;
    self.m_donationValue = nil;
    self.m_tab_btn_1 = nil;
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
    self.m_tab_btn_4 = nil;
    self.m_building_lv_label = nil;
end
--[[--
    返回
]]
function game_guild_develop.back(self,backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_guild_develop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 2 then--信息
            game_scene:enterGameUi("game_guild_main",{gameData = nil});
            self:destroy();
        elseif btnTag == 3 then--开发

        elseif btnTag == 4 then--兑换
            game_scene:enterGameUi("game_guild_conversion",{gameData = nil});
            self:destroy()
        elseif btnTag == 5 then--排行
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_data:setGuildListDataByJsonData(data:getNodeWithKey("guild_list"));
                game_scene:enterGameUi("game_guild_ranking",{gameData = nil});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_all"), http_request_method.GET, nil,"association_guild_all")
        -- elseif btnTag == 11 then--默认开发
        --     if self.m_selListIndex == nil then return end
        --     local guild_client = getConfig(game_config_field.guild_client);
        --     local developType = guild_client:getNodeAt(self.m_selListIndex):getNodeWithKey("type"):toStr();
        --     local function responseMethod(tag,gameData)
        --         self.m_selListItem = nil;
        --         local tGameData = game_data:getSelGuildData();
        --         tGameData.guild.default = developType;
        --         self:refreshUi();
        --     end
        --     -- 设置默认科技 science_id＝科技名
        --     local params = {};
        --     params.science_id=developType
        --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_set_default"), http_request_method.GET, params,"association_set_default")
        elseif btnTag == 11 then--纪录
            if self.m_pop_ui == nil then
                self.m_pop_ui = self:createGuildDevelopRecordsPop();
                game_scene:getPopContainer():addChild(self.m_pop_ui);
            end
        elseif btnTag == 12 then--钻石捐献
            local function responseMethod(tag,gameData)
                game_data:setSelGuildDataByJsonData(gameData:getNodeWithKey("data"));
                self:refreshBar();
            end
            -- 开发科技 food＝钻石数
            local params = {};
            params.food=self.m_donationValue;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_develop_science"), http_request_method.GET, params,"association_develop_science")
        elseif btnTag == 13 then-- －
            self.m_donationValue = self.m_donationValue - 100;
            if self.m_donationValue <= 0 then
                self.m_donationValue = 100;
            end
            self.m_num_label:setString(self.m_donationValue);
        elseif btnTag == 14 then-- +
            self.m_donationValue = self.m_donationValue + 100;
            self.m_num_label:setString(self.m_donationValue);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_develop.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayer");
    self.m_integration_label = tolua.cast(ccbNode:objectForName("m_integration_label"), "CCLabelTTF");
    local m_progress_bar_bg = tolua.cast(ccbNode:objectForName("m_progress_bar_bg"), "CCSprite");
    m_progress_bar_bg:setOpacity(0);
    local bar_bg_size = m_progress_bar_bg:getContentSize();
    self.m_num_label = tolua.cast(ccbNode:objectForName("m_num_label"), "CCLabelTTF");
    self.m_intro_label = tolua.cast(ccbNode:objectForName("m_intro_label"), "CCLabelTTF");
    self.m_set_develop_btn = tolua.cast(ccbNode:objectForName("m_set_develop_btn"), "CCControlButton");
    self.m_sel_type_level_label = tolua.cast(ccbNode:objectForName("m_sel_type_level_label"), "CCLabelTTF");

    self.m_num_label:setString(self.m_donationValue);
    -- local testBtn = CCControlStepper:create(CCSprite:createWithSpriteFrameName("ghkf_kaifadengji.png"), CCSprite:createWithSpriteFrameName("ghkf_kaifadengji.png"));
    -- testBtn:setPositionX(self.m_num_label:getParent():getContentSize().width*0.5);
    -- self.m_num_label:getParent():addChild(testBtn);

    -- local function defaultBtnCallback(event,target)
    --     local pControl = tolua.cast(target,"CCControlStepper");
    --     self.m_donationValue = 100*(pControl:getValue()+1)
    --     self.m_num_label:setString(self.m_donationValue);
    -- end
    -- testBtn:addHandleOfControlEvent(defaultBtnCallback,CCControlEventValueChanged);

    -- self.m_progress_bar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("ghkf_yuan.png"));
    -- self.m_progress_bar:setReverseProgress(true);
    -- self.m_progress_bar:setPercentage(0);
    -- -- self.m_progress_bar:setScaleY(-1);
    -- self.m_progress_bar:setRotation(180);
    -- self.m_progress_bar:setType(kCCProgressTimerTypeRadial);
    -- self.m_progress_bar:setPosition(ccp(bar_bg_size.width*0.5,bar_bg_size.height*0.5));
    -- m_progress_bar_bg:addChild(self.m_progress_bar);
    -- self.m_progress_bar:runAction(CCProgressTo:create(1, 0));

    self.m_progress_bar = ExtProgressTime:createWithFrameName("gh_barDown.png","gh_barUp.png");
    self.m_progress_bar:setCurValue(0,false);
    m_progress_bar_bg:addChild(self.m_progress_bar)

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_4 = ccbNode:controlButtonForName("m_tab_btn_4");
    self.m_building_lv_label = ccbNode:labelTTFForName("m_building_lv_label");
    self.m_tab_btn_2:setHighlighted(true);
    self.m_tab_btn_2:setEnabled(false);

    return ccbNode;
end

--[[--
    开发列表
]]
function game_guild_develop.createGuildDevelopList(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local guild_client = getConfig(game_config_field.guild_client);

    local tGameData = game_data:getSelGuildData();
    local defaultDevelop = tGameData.guild.default;

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.totalItem = guild_client:getNodeCount();
    params.touchPriority = touchPriority;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            local spriteLand = CCSprite:createWithSpriteFrameName("public_btnNormal.png");
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            msgLabel:setPosition(ccp(itemSize.width*0.2,itemSize.height*0.5));
            -- msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            local detailLabel = CCLabelTTF:create(string_helper.game_guild_develop.g_name,TYPE_FACE_TABLE.Arial_BoldMT,10);
            detailLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- detailLabel:setColor(ccc3(200,120,0));
            cell:addChild(detailLabel,10,11);
            local lvLabel = CCLabelTTF:create("lv.1",TYPE_FACE_TABLE.Arial_BoldMT,10);
            lvLabel:setPosition(ccp(itemSize.width*0.8,itemSize.height*0.5));
            -- lvLabel:setColor(ccc3(200,120,0));
            cell:addChild(lvLabel,10,12);
        end
        if cell then
            local itemCfg = guild_client:getNodeAt(index);
            if itemCfg then
                tolua.cast(cell:getChildByTag(10),"CCLabelTTF"):setString("" .. (index + 1));
                tolua.cast(cell:getChildByTag(11),"CCLabelTTF"):setString(itemCfg:getNodeWithKey("name"):toStr());
                -- cclog("defaultDevelop ==" .. tostring(defaultDevelop) .. " ; type = " .. itemCfg:getNodeWithKey("type"):toStr());
                local itemBg = tolua.cast(cell:getChildByTag(1),"CCSprite");
                itemBg:setColor(ccc3(255,255,255));
                if self.m_selListIndex == index then
                    self.m_selListItem = cell;
                    itemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_btnDown.png"));
                else
                    itemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_btnNormal.png"));
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if self.m_selListItem then
                local itemBg = tolua.cast(self.m_selListItem:getChildByTag(1),"CCSprite");
                itemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_btnNormal.png"));
            end
            self.m_selListIndex = index;
            self.m_selListItem = item;
            local itemBg = tolua.cast(self.m_selListItem:getChildByTag(1),"CCSprite");
            itemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_btnDown.png"));
        end
    end
    return TableViewHelper:create(params);
end


--[[--
    开发纪录列表
]]
function game_guild_develop.createGuildDevelopRecordsList(self,viewSize,touchPriority)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;--行
    params.column = 1; --列
    params.totalItem = 35;
    params.touchPriority = touchPriority;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 0), 30, 30)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("ghkf_liebiaobeijing.png");
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            msgLabel:setPosition(ccp(itemSize.width*0.1,itemSize.height*0.5));
            msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
            local detailLabel = CCLabelTTF:create(string_helper.game_guild_develop.record_des,TYPE_FACE_TABLE.Arial_BoldMT,10);
            detailLabel:setPosition(ccp(itemSize.width*0.6,itemSize.height*0.5));
            detailLabel:setColor(ccc3(200,120,0));
            cell:addChild(detailLabel,10,11);
        end
        if cell then
            local msgLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            if msgLabel  then
                msgLabel:setString("" .. (index + 1));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    创建开发弹出框
]]
function game_guild_develop.createGuildDevelopRecordsPop(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if self.m_pop_ui then--关闭
                self.m_pop_ui:removeFromParentAndCleanup(true);
                self.m_pop_ui = nil;
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_develop_records_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayer");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local tableViewTemp = self:createGuildDevelopRecordsList(m_list_view_bg:getContentSize(),GLOBAL_TOUCH_PRIORITY-1);
    m_list_view_bg:addChild(tableViewTemp);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    
]]
function game_guild_develop.refreshBar(self)
    local tGameData = game_data:getSelGuildData();
    local guild = tGameData.guild;
    local selDevelop = guild[guild.default];
    if selDevelop then
        local guildCfg = getConfig(game_config_field.guild);
        local itemCfg = guildCfg:getNodeWithKey(tostring(selDevelop.lv));
        local maxExp = itemCfg:getNodeWithKey("exp"):toStr();
        local currentExp = selDevelop.exp
        cclog("maxExp ========" .. maxExp .. " ; currentExp ====" .. currentExp);
        -- self.m_progress_bar:runAction(CCProgressTo:create(0.5, currentExp*100/maxExp));
        self.m_progress_bar:setCurValue(currentExp*100/maxExp,true);
        self.m_sel_type_level_label:setString("Lv." .. selDevelop.lv);
        self.m_integration_label:setString(guild.score);
    end
end

--[[--
    刷新ui
]]
function game_guild_develop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createGuildDevelopList(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    if self.m_jobType == 3 then
        self.m_set_develop_btn:setVisible(false);
    end
    self:refreshBar();
end
--[[--
    初始化
]]
function game_guild_develop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_jobType = t_params.jobType;
    self.m_donationValue = 100;
    self.m_selListIndex = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_develop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_develop;