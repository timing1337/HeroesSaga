---  人物选择

local create_role_scene = {
    m_list_view_bg = nil,
    m_role_node = nil,
    m_role_story_label = nil,
    m_ok_btn = nil,
    m_select_role = nil,
    m_palyer_name = nil,
    m_tableView = nil,
    m_selListItem = nil,
    m_roleBtnTab = nil,
    m_role_btn_node = nil,
    m_showIndex = nil,
    m_bg_node = nil,
    m_story_spr = nil,
};

--[[--
    销毁ui
]]
function create_role_scene.destroy(self)
    -- body
    cclog("-----------------create_role_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_role_node = nil;
    self.m_role_story_label = nil;
    self.m_role_name = nil;
    self.m_ok_btn = nil;
    self.m_select_role = nil;
    self.m_palyer_name = nil;
    self.m_tableView = nil;
    self.m_selListItem = nil;
    self.m_roleBtnTab = nil;
    self.m_role_btn_node = nil;
    self.m_showIndex = nil;
    self.m_bg_node = nil;
    self.m_story_spr = nil;
end
--[[--
    返回
]]
function create_role_scene.back(self,type)

	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function create_role_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, " create_role_scene  onMainBtnClick btn  ===  ")
        if btnTag == 1 then--进入游戏
            if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(7) end  -- 点击开始征战 步骤7
            local username = CCUserDefault:sharedUserDefault():getStringForKey("username");
            -- --用户注册 role=1&show_name=
            local function responseMethod(tag,gameData)
                user_token = gameData:getNodeWithKey("data"):getNodeWithKey("uid"):toStr();
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(7) end -- 点击开始征战 步骤7
                if user_token == "" then return end
                cclog("user_token ====================================" .. user_token);
                -- CCUserDefault:sharedUserDefault():setStringForKey("user_token",user_token);
                CCUserDefault:sharedUserDefault():setBoolForKey("enterGameFlag",true);
                CCUserDefault:sharedUserDefault():flush();
                self:downloadData();
                if game_data_statistics then
                    game_data_statistics:event({eventId = "user_token_event",label = "createNewRole"})
                    game_data_statistics:createRole({username = username})
                end
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                require("shared.native_helper").createNewRole( username, serverId  )
                if getPlatForm() == "cmge" and PLATFORM_CMGE then
                    if type(PLATFORM_CMGE.createRole) == "function" then
                        local userData = game_data:getDataByKey("m_tUserStatusData") or {}
                        local sendInfo = {}
                        sendInfo.uid = tostring(userData.uid)
                        sendInfo.coin = tostring(userData.coin)
                        sendInfo.show_name = tostring(userData.show_name)
                        sendInfo.level = tostring(userData.level)
                        sendInfo.serverId = tostring(serverId)
                        PLATFORM_CMGE.createRole(sendInfo)
                    end
                end
            end
            local params = {};
            params.role = self.m_select_role;
            -- params.show_name = util.url_encode(self.m_palyer_name)
            params.account = username;
            local selServer,index = game_data:getServer();
            if selServer then
                params.server_name = selServer.server
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("new_user"), http_request_method.GET, params,"new_user")
            -- game_scene:enterGameUi("game_first_opening",{select_index = self.m_select_role});
        elseif btnTag > 10 and btnTag < 16 then
            self.m_showIndex = btnTag - 10;
            self:refreshRoleButton();
        elseif btnTag == 100 then--返回
            game:enterMainScene();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_create_role.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_role_node = ccbNode:nodeForName("m_role_node")
    self.m_role_story_label = ccbNode:labelTTFForName("m_role_story_label")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    self.m_role_btn_node = ccbNode:nodeForName("m_role_btn_node")
    self.m_bg_node = ccbNode:nodeForName("m_bg_node")
    self.m_story_spr = ccbNode:spriteForName("m_story_spr")
    local role_detail_cfg = getConfig(game_config_field.role_detail)
    local roleCount = role_detail_cfg:getNodeCount();
    local m_role_btn,itemCfg = nil,nil
    local pX,pY = nil,nil;
    for i=1,5 do
        m_role_btn = ccbNode:controlButtonForName("m_role_btn_" .. i)
        if i <= roleCount then
            pX,pY = m_role_btn:getPosition();
            itemCfg = role_detail_cfg:getNodeAt(i-1)
            -- local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
            local icon = game_util:createPlayerBattleImgRoleId(itemCfg:getKey());
            if icon then
                icon:setPosition(ccp(pX,pY));
                icon:setColor(ccc3(81,81,81));
                self.m_role_btn_node:addChild(icon);
            end
            self.m_roleBtnTab[i] = {m_role_btn = m_role_btn,icon = icon}
        else
            m_role_btn:setVisible(false);
        end
    end
    return ccbNode;
end

--[[--

]]
function create_role_scene.downloadData(self)
    local function enterGame()
        local function endCallFunc(returnFlag)
            if returnFlag then
                game_scene:enterGameUi("game_first_opening",{});
                local function sendRequestFunc()
                    local function responseMethod(tag,gameData)
                        if gameData then
                            game_data:setSelCityDataByJsonData(gameData:getNodeWithKey("data"));
                            game_scene:enterGameUi("game_small_map_scene",{gameData = gameData,bgMusic = "background_singapo"});
                            self:destroy();
                        else
                            game_util:closeAlertView();
                            local t_params = 
                            {
                                title = string_config.m_title_prompt,
                                okBtnCallBack = function(target,event)
                                    sendRequestFunc();
                                    game_util:closeAlertView();
                                end,   --可缺省
                                closeCallBack = function(target,event)
                                    game_util:closeAlertView();
                                    exitGame();
                                end,
                                okBtnText = string_helper.create_role_scene.okBtnText,       --可缺省
                                text = string_helper.create_role_scene.text,      --可缺省
                            }
                            game_util:openAlertView(t_params);
                        end
                    end
                    local params = {}
                    params.city = "100"
                    params.chapter = "1";
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_open"), http_request_method.GET, params,"private_city_open",true,true);
                end
                -- sendRequestFunc();

            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        require("game_download.game_data_download"):start({endCallFunc = endCallFunc});
                        game_util:closeAlertView();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_config.m_re_donwload,       --可缺省
                    text = string_config.m_download_failed,      --可缺省
                }
                game_util:openAlertView(t_params);
            end
        end
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data");
                mark_user_login_mk = data:getNodeWithKey("mk"):toStr();
                require("game_download.game_data_download"):start({endCallFunc = endCallFunc});
            else
                game_util:closeAlertView();
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        enterGame();
                        game_util:closeAlertView();
                    end,   --可缺省
                    closeCallBack = function(target,event)
                        game_util:closeAlertView();
                        exitGame();
                    end,
                    okBtnText = string_helper.create_role_scene.okBtnText,       --可缺省
                    text = string_helper.create_role_scene.text2,      --可缺省
                }
                game_util:openAlertView(t_params);
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mark_user_login"), http_request_method.GET, nil,"mark_user_login",true,true)
    end
    enterGame();
end

--[[--

]]
function create_role_scene.createTableView(self,viewSize)
    cclog("create_role_scene.createTableView")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local role_detail_cfg = getConfig(game_config_field.role_detail)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = role_detail_cfg:getNodeCount();
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local iconNode = CCNode:create();
            iconNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(iconNode,1,1)
            local tempSpr = CCSprite:createWithSpriteFrameName("cjjs_box01.png")
            tempSpr:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(tempSpr,10,10)
        end
        if cell then
            local itemCfg = role_detail_cfg:getNodeAt(index)--getNodeWithKey(tostring(index+1))
            local key = itemCfg:getKey();
            local iconNode = tolua.cast(cell:getChildByTag(1),"CCNode")
            local tempSpr = tolua.cast(cell:getChildByTag(10),"CCSprite")
            iconNode:removeAllChildrenWithCleanup(true);
            local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
            if icon then
                iconNode:addChild(icon);
            end
            if tonumber(key) == self.m_select_role then
                self.m_selListItem = cell;
                tempSpr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_characterSelect.png"));
            else
                tempSpr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_box01.png"));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            if self.m_selListItem then
                local itemBg = tolua.cast(self.m_selListItem:getChildByTag(10),"CCSprite");
                itemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_box01.png"));
            end
            self.m_selListItem = cell;
            local tempSpr = tolua.cast(cell:getChildByTag(10),"CCSprite")
            tempSpr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cjjs_characterSelect.png"));
            local itemCfg = role_detail_cfg:getNodeAt(index)
            self:refreshRoleInfoByIndex(itemCfg:getKey());
        end
    end
    return TableViewHelper:create(params);
end

--[[--

]]
function create_role_scene.refreshRoleInfoByIndex(self,index)
    self.m_role_node:removeAllChildrenWithCleanup(true);
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    cclog("index ======================================== " .. index);
    local itemCfg = role_detail_cfg:getNodeAt(index);
    local role_name = "";
    local story = "";
    if itemCfg then
        self.m_select_role = itemCfg:getKey();
        role_name = itemCfg:getNodeWithKey("role_name"):toStr();
        story = itemCfg:getNodeWithKey("story"):toStr();
        local temp_big_img = CCSprite:create("humen/" .. itemCfg:getNodeWithKey("img"):toStr() .. ".png");
        if temp_big_img then
            temp_big_img:setFlipX(true);
            self.m_role_node:addChild(temp_big_img)
        end
        local select_background = itemCfg:getNodeWithKey("select_background")
        if select_background then
            select_background = game_util:getResName(select_background:toStr());
            local select_background_spr = CCSprite:create("battle_ground/"..select_background..".jpg")
            if select_background_spr then
                self.m_bg_node:removeAllChildrenWithCleanup(true);
                self.m_bg_node:addChild(select_background_spr);
            end
        end
        image = game_util:getResName(story);
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image .. ".png")
        if spriteFrame then
            self.m_story_spr:setVisible(true);
            self.m_story_spr:setDisplayFrame(spriteFrame);
        else
            self.m_story_spr:setVisible(false);
        end
    end
    self.m_role_story_label:setString("");
end

--[[--

]]
function create_role_scene.refreshRoleButton(self)
    local flag = false;
    for k,v in pairs(self.m_roleBtnTab) do
        if k == self.m_showIndex then
            if v.icon then
                v.icon:setColor(ccc3(255,255,255))
            end
            flag = true;
        else
            if v.icon then
                v.icon:setColor(ccc3(81,81,81))
            end
            flag = false;
        end
        v.m_role_btn:setEnabled(not flag);
        v.m_role_btn:setHighlighted(flag);
    end
    self:refreshRoleInfoByIndex(self.m_showIndex - 1);
end

--[[--
    刷新ui
]]
function create_role_scene.refreshUi(self)
    -- self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    -- self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    -- self.m_tableView:setScrollBarVisible(false);
    -- self.m_tableView:setMoveFlag(false);
    -- self.m_list_view_bg:addChild(self.m_tableView);
    self:refreshRoleInfoByIndex(self.m_select_role);
    self:refreshRoleButton();
end

--[[--
    初始化
]]
function create_role_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_palyer_name = "";
    self.m_select_role = 1;
    self.m_roleBtnTab = {};
    self.m_showIndex = 1;
end


--[[--
    创建ui入口并初始化数据
]]
function create_role_scene.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return create_role_scene;