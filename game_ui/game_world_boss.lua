---  世界boss
local game_world_boss = {
    m_time_label = nil,
    m_boss_hp_label = nil,
    m_hurt_label = nil,
    m_personal_hurt_btn = nil,
    m_guild_btn = nil,
    
    m_hurt_flag = nil,
    m_user_rank_data = nil,
    m_guild_rank_data = nil,

    m_user_hurt_list = nil,
    m_guild_hurt_list = nil,

    m_rank_label_liset = nil,
    m_hurt_label_list = nil,

    m_playerAnimNode = nil,--主角
    m_start_node = nil,--起始位置
    m_fight_btn = nil,
    m_alpha_back = nil,

    m_boss_node = nil,
    m_user_node = nil,
    m_hp_bar_node = nil,
    m_boss_id = nil,
    m_active_node = nil,
    m_active_time_label = nil,
    m_move_flag = nil,
    m_gameData = nil,
    fight_flag = nil,

    people_move_flag = nil,
};
--[[--
    销毁ui
]]
function game_world_boss.destroy(self)
    -- body
    cclog("-----------------game_world_boss destroy-----------------");
    self.m_time_label = nil;
    self.m_hurt_label = nil;
    self.m_personal_hurt_btn = nil;
    self.m_guild_btn = nil;
    self.m_boss_hp_label = nil;
    self.m_hurt_flag = nil;
    self.user_rank_data = nil;
    self.m_guild_rank_data = nil;

    self.m_user_hurt_list = nil;
    self.m_guild_hurt_list = nil;

    self.m_rank_label_liset = nil;
    self.m_playerAnimNode = nil;
    self.m_start_node = nil;
    self.m_fight_btn = nil;
    self.m_hurt_label_list = nil;
    self.m_boss_node = nil;
    self.m_user_node = nil;
    self.m_hp_bar_node = nil;
    self.m_boss_id = nil;
    self.m_active_node = nil;
    self.m_active_time_label = nil;
    self.m_move_flag = nil;
    if self.m_gameData then
        self.m_gameData:delete();
        self.m_gameData = nil;
    end
    self.fight_flag = nil;
    self.people_move_flag = nil;
end
--[[--
    返回
]]
function game_world_boss.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                self:destroy();
            end});
end
function game_world_boss.createRankList(self,flag)
    local rank_count = 1
    local rank_list = {}
    local hurt_list = {}
    if flag == 1 then
        rank_count = #self.m_user_rank_data
        rank_list = self.m_user_rank_data
        hurt_list = self.m_user_hurt_list
    else
        rank_count = #self.m_guild_rank_data
        rank_list = self.m_guild_rank_data
        hurt_list = self.m_guild_hurt_list
    end

    for i=1,10 do 
        if i <= rank_count then
            self.m_rank_label_liset[i]:setString(tostring(i.."."..rank_list[i]))
            self.m_hurt_label_list[i]:setString(tostring(hurt_list[i]))
        else
            self.m_rank_label_liset[i]:setString("")
            self.m_hurt_label_list[i]:setString("")
        end
    end
end
--[[--
    读取ccbi创建ui
]]
function game_world_boss.createUi(self)
    local function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data")
        -- cclog("game_world_boss data=="..data:getFormatBuffer())
        local boss_info = data:getNodeWithKey("boss_info");
        local itemData = boss_info:getNodeAt(0);
        local boss_key = itemData:getKey();
        self.m_boss_id = boss_key;
        local boss_data = boss_info:getNodeWithKey(tostring(boss_key));
        local max_hp = boss_data:getNodeWithKey("max_hp"):toInt();
        local boss_hp = boss_data:getNodeWithKey("hp"):toInt();
        local expire = boss_data:getNodeWithKey("expire"):toInt();
        local my_hurt = boss_data:getNodeWithKey("self_hurt"):toInt();
        local user_rank = boss_data:getNodeWithKey("user_rank");
        local guild_rank = boss_data:getNodeWithKey("guild_hurt");
        local active_cd = data:getNodeWithKey("cd_expire"):toInt();
        local killer = boss_data:getNodeWithKey("killer");

        if killer:getNodeCount() ~= 0 then--boss已被打死，弹板显示信息，并发送通知
            local killer_name = killer:getNodeWithKey("name"):toStr()
            local testTable = json.decode(boss_info:getFormatBuffer());
            local t_params = 
            {
                killerData = testTable,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    self:back();
                end
            }
            game_scene:addPop("game_boss_result_pop",t_params)
            self.people_move_flag = false
        end
        local passers = boss_data:getNodeWithKey("passers");
        self:createUserMapAnim(passers);

        self.m_user_rank_data = {}
        self.m_guild_rank_data = {}
        self.m_user_hurt_list = {}
        self.m_guild_hurt_list = {}
        local user_rank_count = user_rank:getNodeCount()
        for i=1,user_rank_count do
            local user_data = user_rank:getNodeAt(i-1)
            hurt = user_data:getNodeWithKey("hurt"):toInt()
            name = user_data:getNodeWithKey("name"):toStr()
            local name_count = string.len(name);
            self.m_user_rank_data[i] = name
            self.m_user_hurt_list[i] = hurt
        end
        local guild_rank_count = guild_rank:getNodeCount()
        for i=1,guild_rank_count do
            local guild_data = guild_rank:getNodeAt(i-1)
            hurt = guild_data:getNodeWithKey("hurt"):toInt()
            name = guild_data:getNodeWithKey("guild_name"):toStr()
            local name_count = string.len(name);
            self.m_guild_rank_data[i] = name
            self.m_guild_hurt_list[i] = hurt
        end

        self.m_boss_hp_label:setString(tostring(boss_hp))
        self.m_hurt_label:setString(tostring(my_hurt))
        --倒计时回调函数
        local function timeEndFunc(label,type)
            local vipLevel = game_data:getVipLevel()
            if vipLevel >= 6 then
                
            else
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
            end
        end
        --取时间去倒计时
        self.m_time_label:setString("")
        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setPosition(ccp(countdownLabel:getContentSize().width*0.5,self.m_time_label:getContentSize().height*0.5))
        if self.m_time_label ~= nil then
            self.m_time_label:removeAllChildrenWithCleanup(true)
        end
        self.m_time_label:addChild(countdownLabel)
        countdownLabel:setTime(expire);

        local function timeActiveEndFunc(label,type)
            --复活后可以点击打boss
            self.m_active_node:setVisible(false);
            -- self.m_fight_btn:setEnabled(true);
            self.fight_flag = false
        end
        --复活时间
        self.m_active_time_label:setString("")
        local cdLabel = game_util:createCountdownLabel(0,timeActiveEndFunc,8);
        cdLabel:setPosition(ccp(cdLabel:getContentSize().width*0.5,self.m_active_time_label:getContentSize().height*0.5))
        if self.m_active_time_label ~= nil then
            self.m_active_time_label:removeAllChildrenWithCleanup(true)
        end
        self.m_active_time_label:addChild(cdLabel)

        self.m_active_node:setVisible(true);
        -- self.m_fight_btn:setEnabled(false);
        self.fight_flag = true
        if active_cd > 0 then
            cdLabel:setTime(active_cd);
        else
            cdLabel:setTime(0);
            timeActiveEndFunc()
        end
        -- self:refreshUi()
        self:createRankList(self.m_hurt_flag);
        self:createPlayerMapAnim(self.m_start_node)

        local bar = ExtProgressTime:createWithFrameName("world_boos_hp_2.png","world_boos_hp_1.png");
        bar:setScaleX(-1);
        bar:setMaxValue(max_hp)
        bar:setCurValue(boss_hp,false);
        bar:setAnchorPoint(ccp(0.5,0.5))
        bar:setPosition(ccp(0,0))
        self.m_hp_bar_node:addChild(bar,10)

    end
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 11 then--阵型
            game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_world_boss"});
            self:destroy();
        elseif btnTag == 12 then--返回
            self:back()
        elseif btnTag == 101 then--个人伤害
            if self.m_hurt_flag == 2 then
                self.m_personal_hurt_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab.png"),CCControlStateNormal);
                self.m_guild_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab_1.png"),CCControlStateNormal);
                self.m_hurt_flag = 1
                self:createRankList(self.m_hurt_flag);
            end
        elseif btnTag == 102 then--公会伤害
            if self.m_hurt_flag == 1 then
                self.m_personal_hurt_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab_1.png"),CCControlStateNormal);
                self.m_guild_btn:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("select_tab.png"),CCControlStateNormal);
                self.m_hurt_flag = 2
                self:createRankList(self.m_hurt_flag);
            end
        elseif btnTag == 500 then--战斗
            local function moveEndCallFunc()
                local function fightResponseMethod(tag,gameData)
                    if gameData then
                        game_data:setBattleType("game_world_boss");
                        local data = gameData:getNodeWithKey("data")
                        -- if data and data:getNodeWithKey("kill_boss") and    data:getNodeWithKey("kill_boss"):toBool() == true then
                        --     local chatOber = game_data:getChatObserver()
                        --     if chatOber then chatOber:sendLikeMsg("world_boss", "击败了世界BOSS") end
                        -- end
                        -- cclog("fight data=="..data:getFormatBuffer())
                        self.m_move_flag = false;
                        local stageTableData = {name = string_helper.game_world_boss.big_boss,step = 1,totalStep = 1}
                        --传背景图
                        local backImgCfg = getConfig(game_config_field.world_boss);
                        local imgName = backImgCfg:getNodeWithKey(self.m_boss_id):getNodeWithKey("background"):toStr();
                        cclog("imgName = "..imgName);
                        game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName=imgName});
                        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
                    else
                        self.m_move_flag = false;
                    end
                end

                local params = {}
                params.boss_id = self.m_boss_id
                --跳转到战斗
                network.sendHttpRequest(fightResponseMethod,game_url.getUrlForKey("world_boss_fight"), http_request_method.GET, params,"world_boss_fight",true,true)
                -- local nameLabel = tolua.cast(self.m_start_node:getChildByTag(11),"CCLabelTTF")
                -- self.m_playerAnimNode:setPosition(ccp(36,24))
                -- nameLabel:setPosition(ccp(36,24+60))
            end
            --几次移动
            local visibleSize = CCDirector:sharedDirector():getVisibleSize();
            local offset = 0
            if visibleSize.width == 480 then
                offset = 0;
            else
                offset = 44;
            end
            local moveArray = {
                ccp(135+offset,75),
                ccp(200+offset,70),
                ccp(245+offset,130),
                ccp(300+offset,150),
            }
            if self.fight_flag == true then
                game_util:addMoveTips({text = string_helper.game_world_boss.fuhe});
            else
                if self.m_playerAnimNode and self.m_move_flag == false then
                    -- local pX,pY = self.m_boss_node:getPosition();
                    local nameLabel = tolua.cast(self.m_start_node:getChildByTag(11),"CCLabelTTF")
                    game_util:createBuildingPersonWithNameAnimMove(self.m_playerAnimNode,moveEndCallFunc,nameLabel,moveArray);
                    self.m_move_flag = true;
                else
                    -- self.m_move_flag = false;
                    -- moveEndCallFunc();
                end
            end
        elseif btnTag == 999 then --加速复活
            local vipCfg = getConfig(game_config_field.vip);
            local vip_level = game_data:getVipLevel();
            local nowCfg = vipCfg:getNodeWithKey(tostring(vip_level));
            local skip_flag = nowCfg:getNodeWithKey("world_boss_skip"):toInt()
            if skip_flag == 1 then
                local function responseMethod(tag,gameData)
                    game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
                    cclog("world_boss_revive data == "..gameData:getNodeWithKey("data"):getFormatBuffer())
                    
                    self.m_active_node:setVisible(false);
                    -- self.m_fight_btn:setEnabled(true);
                    self.fight_flag = false
                end
                local payCfg = getConfig(game_config_field.pay)
                local reviveCfg = payCfg:getNodeWithKey("7")
                local coin = reviveCfg:getNodeWithKey("coin"):getNodeAt(0):toInt()
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_revive"), http_request_method.GET, nil,"world_boss_revive")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,
                    text = string_helper.game_world_boss.cost .. coin .. string_helper.game_world_boss.diamond_fuhe,
                }
                game_util:openAlertView(t_params);
            else
                game_util:addMoveTips({text = string_helper.game_world_boss.vip_less_tip });
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_world_boss.ccbi");

    self.m_time_label = ccbNode:labelTTFForName("time_label")
    self.m_personal_hurt_btn = ccbNode:controlButtonForName("personal_btn")
    game_util:setCCControlButtonTitle(self.m_personal_hurt_btn ,string_helper.ccb.title3)
    self.m_guild_btn = ccbNode:controlButtonForName("guild_btn")
    game_util:setCCControlButtonTitle(self.m_guild_btn ,string_helper.ccb.title4)
    self.m_boss_hp_label = ccbNode:labelTTFForName("boss_hp_label")
    self.m_hurt_label = ccbNode:labelTTFForName("my_hurt_label")

    -- self.m_rank_table = ccbNode:nodeForName("rank_table_node")
    -- self.m_rank_guild_table = ccbNode:nodeForName("rank_guild_table_node")
    self.m_start_node = ccbNode:nodeForName("user_start_node")
    self.m_fight_btn = ccbNode:controlButtonForName("fight_btn")
    self.m_fight_btn:setOpacity(0);
    self.m_boss_node = ccbNode:nodeForName("boss_node")
    self.m_hp_bar_node = ccbNode:nodeForName("hp_bar_node")
    self.m_active_node = ccbNode:nodeForName("active_node")
    self.m_active_time_label = ccbNode:labelTTFForName("active_time_label")
    local title1 = ccbNode:labelTTFForName("title1");
    local title2 = ccbNode:labelTTFForName("title2");
    local title3 = ccbNode:labelTTFForName("title3");
    title1:setString(string_helper.ccb.title1);
    title2:setString(string_helper.ccb.title2);
    title3:setString(string_helper.ccb.title5);

    self.m_rank_label_liset = {}
    self.m_hurt_label_list = {}
    self.m_user_node = {}
    for i=1,10 do
        self.m_rank_label_liset[i] = ccbNode:labelTTFForName("rank_label_"..i);
        self.m_hurt_label_list[i] = ccbNode:labelTTFForName("hurt_label_"..i);
        self.m_user_node[i] = ccbNode:nodeForName("user_node"..i);
    end

    self:createBossAnim()
    self.m_hurt_flag = 1--默认显示个人伤害
    self.m_move_flag = false;
    --联网取数据
    local function load_ui()
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("world_boss_index"), http_request_method.GET, nil,"world_boss_index")
        -- cclog("self.m_gameData == " .. self.m_gameData:getFormatBuffer())
        responseMethod("world_boss_index",self.m_gameData)
    end
    load_ui()
    --boss 动画
    
    return ccbNode;
end
--[[
    创建boss动画
]]--
function game_world_boss.createBossAnim(self)
    local anim_node = game_util:createEffectAnim("anim_world_boss_fight",1,true)
    anim_node:setAnchorPoint(ccp(0.5,0.5))
    anim_node:setPosition(ccp(0,0));
    --获得屏幕宽度，4、5偏移是44
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    if visibleSize.width == 480 then
        self.m_boss_node:setPosition(ccp(356,236))
    else
        self.m_boss_node:setPosition(ccp(400,236))
    end
    self.m_boss_node:addChild(anim_node,10)
    local anim_tip = game_util:createEffectAnim("anim_fight_index",1,true)
    anim_tip:setAnchorPoint(ccp(0.5,0.5))
    anim_tip:setPosition(ccp(-50,-25))
    self.m_boss_node:addChild(anim_tip,11,11)
end
--[[
    创建玩家
]]--
function game_world_boss.createUserMapAnim(self,passers)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local passersCount = passers:getNodeCount()
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local offset = 0
    if visibleSize.width == 480 then
        offset = 0;
    else
        offset = 44;
    end
    local moveArray = { ccp(300+offset,150), }
    for i=1,passersCount do
        local passersData = passers:getNodeAt(i-1)
        local roleId = passersData:getNodeWithKey("role"):toInt()
        local uid = passersData:getNodeWithKey("uid"):toStr()
        local name = passersData:getNodeWithKey("name"):toStr()
        local animName = nil;
        if uid == game_data:getUserStatusDataByKey("uid") then

        else
            local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
            if itemCfg then
                animName = itemCfg:getNodeWithKey("animation"):toStr();
            else
                animName = "role_soldier";
            end
            local pX,pY = self.m_user_node[i]:getPosition();
            pX = 0
            pY = 0
            local user = game_util:createPlayerRoleAnim(animName,1)
            user:setAnchorPoint(ccp(0.5,0))
            user:setPosition(ccp(pX,pY))
            local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(255,255,255),fontSize = 6});
            tempLabel:setAnchorPoint(ccp(0.5,0.5))
            tempLabel:setPosition(ccp(pX,pY+60))
            self.m_user_node[i]:addChild(user,10,10)
            self.m_user_node[i]:addChild(tempLabel,10,11)

            if self.people_move_flag == true then
                local moveEndCallFunc = nil;
                local function repeatMove()
                    game_util:createBuildingPersonWithNameAnimMove(user,moveEndCallFunc,tempLabel,moveArray);
                end

                moveEndCallFunc = function()
                    user:setPosition(ccp(pX,pY))
                    tempLabel:setPosition(ccp(pX,pY+60))
                    local actionArray = CCArray:create();
                    --取随机数   1.随机速度  2.随机间隔时间
                    local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
                    local delayTime = math.random(5,10)
                    actionArray:addObject(CCDelayTime:create(delayTime * i));
                    actionArray:addObject(CCCallFuncN:create(repeatMove));
                    self.m_user_node[i]:runAction(CCSequence:create(actionArray));
                end
                game_util:createBuildingPersonWithNameAnimMove(user,moveEndCallFunc,tempLabel,moveArray);
            end
        end
    end
end
function game_world_boss.createPlayerMapAnim(self,node,roleId)
    if self.m_playerAnimNode == nil and node then
        
        self.m_playerAnimNode = game_util:createOwnRoleAnim();
        if self.m_playerAnimNode then
            self.m_playerAnimNode:setAnchorPoint(ccp(0.5,0));
            local pX,pY = self.m_playerAnimNode:getPosition();
            local name = game_data:getUserStatusDataByKey("show_name")
            local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(0,255,0),fontSize = 6});
            tempLabel:setAnchorPoint(ccp(0.5,0.5))
            tempLabel:setPosition(ccp(pX,pY+60))
            node:addChild(self.m_playerAnimNode,10,10)
            node:addChild(tempLabel,10,11)
        end
    end
end
--[[
    创建排行榜的table view
]]--
-- local colorArray = {
--             ccc3(218,0,17),
--             ccc3(211,173,41),
--             ccc3(41,223,14),
--             ccc3(196,197,147)
--         }
-- function game_world_boss.createTableView(self,viewSize)
--     local textCount = 1
--     local text_data = nil
--     if self.m_user_rank_data ~= nil then
--         textCount = self.m_user_rank_data:getNodeCount();
--         text_data = self.m_user_rank_data
--     end
--     local params = {};
--     params.viewSize = viewSize;
--     params.row = 10
--     params.column = 1; --列
--     params.totalItem = 10;
--     params.direction = kCCScrollViewDirectionVertical;--纵向
--     local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
--     params.newCell = function(tableView,index) 
--         local cell = tableView:dequeueCell()
--         if cell == nil then
--             cell = CCTableViewCell:new();
--             cell:autorelease();        
--             local tempLabel = game_util:createLabelTTF()
--             tempLabel:setDimensions(CCSizeMake(120,15))
--             tempLabel:setAnchorPoint(ccp(0.5,0.5))
--             tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2))
--             tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
--             cell:addChild(tempLabel,10,10)    
--         end
--         if cell then
--             local tempLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF")
--             local text = ""
--             if text_data ~= nil then
--                 local hurt = ""
--                 local name = ""
--                 if index < textCount then
--                     local user_data = text_data:getNodeAt(index)
--                     hurt = user_data:getNodeWithKey("hurt"):toInt()
--                     name = user_data:getNodeWithKey("name"):toStr()
--                     text = (index + 1) .."、 " .. name .. "  " .. hurt
--                 end
--             end
--             tempLabel:setString(tostring(text))
--             local color_value
--             if index < 3 then
--                 color_value = colorArray[index+1]
--             else
--                 color_value = colorArray[4]
--             end
--             tempLabel:setColor(color_value)
--         end
--         return cell;
--     end
--     return TableViewHelper:create(params);
-- end
-- --[[
--     创建公会排行table view
-- ]]--
-- function game_world_boss.createGuildTableView(self,viewSize)
--     local textCount = 1
--     local text_data = nil
--     if self.m_guild_rank_data ~= nil then
--         textCount = self.m_guild_rank_data:getNodeCount();
--         text_data = self.m_guild_rank_data
--     end
--     local params = {};
--     params.viewSize = viewSize;
--     params.row = 10
--     params.column = 1; --列
--     params.totalItem = 10;
--     params.direction = kCCScrollViewDirectionVertical;--纵向
--     local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
--     params.newCell = function(tableView,index) 
--         local cell = tableView:dequeueCell()
--         if cell == nil then
--             cell = CCTableViewCell:new();
--             cell:autorelease();        
--             local tempLabel = game_util:createLabelTTF()
--             tempLabel:setDimensions(CCSizeMake(120,15))
--             tempLabel:setAnchorPoint(ccp(0.5,0.5))
--             tempLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-2))
--             tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
--             cell:addChild(tempLabel,10,10)    
--         end
--         if cell then
--             local tempLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF")
--             local text = ""
--             if text_data ~= nil then
--                 local hurt = ""
--                 local name = ""
--                 if index < textCount then
--                     local guild_data = text_data:getNodeAt(index)
--                     hurt = guild_data:getNodeWithKey("hurt"):toInt()
--                     name = guild_data:getNodeWithKey("guild_name"):toStr()
--                     text = (index + 1) .."、 " .. name .. "  " .. hurt
--                 end
--             end
--             tempLabel:setString(tostring(text)..index+1)
--             local color_value
--             if index < 3 then
--                 color_value = colorArray[index+1]
--             else
--                 color_value = colorArray[4]
--             end
--             tempLabel:setColor(color_value)
--         end
--         return cell;
--     end
--     return TableViewHelper:create(params);
-- end
--[[--
    刷新ui
]]
function game_world_boss.refreshUi(self)
    -- self.m_rank_table:removeAllChildrenWithCleanup(true);
    -- local tableViewTemp = self:createTableView(self.m_rank_table:getContentSize());
    -- tableViewTemp:setScrollBarVisible(false)
    -- tableViewTemp:setMoveFlag(false)
    -- self.m_rank_table:addChild(tableViewTemp);

    -- self.m_rank_guild_table:removeAllChildrenWithCleanup(true);
    -- local guildTableView = self:createGuildTableView(self.m_rank_guild_table:getContentSize());
    -- guildTableView:setScrollBarVisible(false)
    -- guildTableView:setMoveFlag(false)
    -- self.m_rank_guild_table:addChild(guildTableView);
end
--[[--
    初始化
]]
function game_world_boss.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = util_json:new(t_params.gameData:getFormatBuffer());--json.decode(t_params.gameData:getFormatBuffer()) or {};
    end
    self.fight_flag = false
    self.people_move_flag = true
end

--[[--
    创建ui入口并初始化数据
]]
function game_world_boss.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_world_boss;