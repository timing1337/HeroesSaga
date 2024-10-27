require "shared.extern"

local guild_join_view = class( "guildJoinView",require("like_oo.oo_sceneBase") );

guild_join_view.m_ccb = nil;
guild_join_view.m_playerNode = nil;
guild_join_view.m_listNode = nil;
guild_join_view.select_index = 0;
guild_join_view.last_select = nil;

guild_join_view.mode = 1;
guild_join_view.btn_find = nil;
guild_join_view.btn_back = nil;
guild_join_view.sprite_find = nil;
guild_join_view.scrollView = nil;

function guild_join_view:create(  )
	-- body
	local scene = self.sceneBase.create( self );

	local function onBack( target,event )
		self:updataMsg(2,nil);
	end

	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag == 1)then  -- 创建公会按钮
            self:updataMsg(4,nil);
        elseif(btnTag == 2)then  -- 查找公会按钮
            self:updataMsg(5,nil);
        elseif(btnTag == 3) then -- 返回公会列表
            self:updataMsg(7,nil);
        end
	end

	self.m_ccb = luaCCBNode:create();
	self.m_ccb:registerFunctionWithFuncName( "onBack",onBack );
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/ui_new_guild_list.ccbi");
	self.m_playerNode = tolua.cast(self.m_ccb:objectForName("m_playerNode"),"CCNode");
	self.m_listNode = tolua.cast(self.m_ccb:objectForName("m_listNode"),"CCNode");

    local btn_create = tolua.cast(self.m_ccb:objectForName("btn_create"),"CCControlButton")
    game_util:setCCControlButtonTitle(btn_create,string_helper.ccb.title144)
    self.btn_find = tolua.cast(self.m_ccb:objectForName("btn_find"),"CCControlButton")
    self.btn_back = tolua.cast(self.m_ccb:objectForName("btn_back"),"CCControlButton")
    self.sprite_find = tolua.cast(self.m_ccb:objectForName("sprite_find"),"CCSprite")
    game_util:setCCControlButtonTitle(self.btn_back,string_helper.ccb.title145)

    -- game_util:setControlButtonTitleBMFont(btn_create)
    -- game_util:setControlButtonTitleBMFont(self.btn_find)
    -- game_util:setControlButtonTitleBMFont(self.btn_back)
    game_util:setCCControlButtonTitle(btn_create,string_helper.ccb.file52)
    game_util:setCCControlButtonTitle(self.btn_find,string_helper.ccb.file53)
    game_util:setCCControlButtonTitle(self.btn_back,string_helper.ccb.file54)
    local scroll_node = self.m_ccb:nodeForName("scroll_node")
    scroll_node:removeAllChildrenWithCleanup(true)
    local tempTable = self:createInfoTable(scroll_node:getContentSize())
    scroll_node:addChild(tempTable)

	scene:addChild(self.m_ccb);
    self:refreshUi()
	return scene;
end
--[[
    创建scroll view
]]
function guild_join_view:createInfoTable(viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/activity.plist");
    local staticPic = {"button_active_boss.png","button_active_middle.png"}
    local staticPic2 = {"gonghui_boss.png","gonghui_hegemony.png"}
    local titleText = string_helper.guild_join.titleText
    local noticeTab = {"114","115","116"}
    local noticeCfg = getConfig(game_config_field.notice_active);
    local reward_pos = {
        {0},
        {-13,51},
        {-31,22,79},
        {-37,1,41,79},
    }
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        local itemCfg = noticeCfg:getNodeWithKey("114")
        local reward = itemCfg:getNodeWithKey("reward")
        local itemData = json.decode(reward:getNodeAt(btnTag-1):getFormatBuffer())
        game_util:lookItemDetal(itemData)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 2; -- 行
    params.column = 1; -- 列
    params.totalItem = 3
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempItem = luaCCBNode:create();
            tempItem:openCCBFile("ccb/ui_new_guild_info_item.ccbi");
            tempItem:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local title_label = ccbNode:labelTTFForName("title_label")
            local info_label = ccbNode:labelTTFForName("info_label")
            local reward_node = ccbNode:nodeForName("reward_node")

            local itemCfg = noticeCfg:getNodeWithKey(noticeTab[index+1])
            local word = itemCfg:getNodeWithKey("word"):toStr()
            info_label:setString(word)
            title_label:setString(titleText[index+1])
            reward_node:removeAllChildrenWithCleanup(true)
            if index == 0 then--奖励图标 动态
                local reward = itemCfg:getNodeWithKey("reward")
                local posTable = reward_pos[reward:getNodeCount()]
                for i=1,reward:getNodeCount() do
                    local rewardItem = reward:getNodeAt(i-1)
                    local reward_icon,name,count = game_util:getRewardByItem(rewardItem,true);
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.7)
                        reward_icon:setPosition(ccp(posTable[i],13))
                        reward_node:addChild(reward_icon)
                    end
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setTag(i)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(posTable[i],0))
                    button:setOpacity(0)
                    reward_node:addChild(button)
                end
            elseif index == 1 then--固定图标
                local pos = reward_pos[2]
                for i=1,2 do
                    local picName = staticPic[i]
                    local sprite = CCSprite:createWithSpriteFrameName(picName)
                    sprite:setAnchorPoint(ccp(0.5,0.5))
                    sprite:setScale(0.6)
                    sprite:setPosition(ccp(pos[i],13))
                    reward_node:addChild(sprite)
                end
            elseif index == 2 then
                local pos = reward_pos[2]
                for i=1,2 do
                    local picName = staticPic2[i]
                    local sprite = CCSprite:createWithSpriteFrameName(picName)
                    sprite:setAnchorPoint(ccp(0.5,0.5))
                    sprite:setScale(0.6)
                    sprite:setPosition(ccp(pos[i],13))
                    reward_node:addChild(sprite)
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then

        end
    end
    return TableViewHelper:create(params);
end
--[[
    刷新table view
]]
function guild_join_view:refreshUi()
    if self.mode == 1 then
        self.btn_back:setVisible(false)
        self.sprite_find:setVisible(true)
        self.btn_find:setVisible(true)
    else
        self.btn_back:setVisible(true)
        self.sprite_find:setVisible(false)
        self.btn_find:setVisible(false)
    end
    self.m_listNode:removeAllChildrenWithCleanup(true)

    self.m_listNode:addChild(self:createTableView(self.m_listNode:getContentSize()));
end

function guild_join_view:onCommand( command , data )
	self.sceneBase.onCommand( self , command , data );
end

function guild_join_view:setIcon( name )
	local sprite = CCSprite:create( name );
    sprite:setScale( 0.5 );
	self.m_playerNode:addChild( sprite );
end

function guild_join_view:createTableView( viewSize )
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    local gvg_land_table = {"gonghui_ouzhou.png","gonghui_meizhou.png","gonghui_feizhou.png","gonghui_zhongguo.png"}
    -- local daily_award_cfg = getConfig(game_config_field.daily_award)
    -- local tGameData = game_data:getDailyAwardData();
    -- local score = tGameData.score;
    -- local reward = tGameData.reward;
    -- cclog("self.m_data.data.guild_list = " .. json.encode(self.m_control.m_data:getGuild()))

    local params = {};
    params.viewSize = viewSize;
    params.row = 5; -- 行
    params.column = 1; -- 列
    params.totalItem = self.m_control.m_data:getGuildCount();
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempItem = luaCCBNode:create();
            tempItem:openCCBFile("ccb/ui_new_guild_list_item.ccbi");
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local tempItem = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempData = self.m_control.m_data:getGuildData(index + 1);
            -- local tempData = self.m_control.m_data:getGuildData(self.m_control.m_data:getGuildCount()-index);
            cclog("tempData == " .. json.encode(tempData))
            cclog("index + 1 = " .. index + 1)
            -- util.printf(tempData);
            cclog("-------------------------------------1")
            -- 公会排名
            local m_pos = tolua.cast(tempItem:objectForName("m_pos"),"CCLabelTTF");
            --m_pos:setString(tostring(tempData.id));

            local backUp = self.m_control.m_data:getBackUp()
            for i=1,#backUp do
                -- local back_name = backUp[i].name
                -- if back_name == tempData.name then
                --     --m_pos:setString(tostring(#backUp-i+1));
                --     m_pos:setString(tostring(i));
                --     break;
                -- end
                local back_id = backUp[i].id
                if back_id == tempData.id then
                    m_pos:setString(tostring(i));
                    break;
                end
            end
            cclog("-------------------------------------2")
            -- 公会名字
            local m_gname = tolua.cast(tempItem:objectForName("m_gname"),"CCLabelTTF");
            m_gname:setString(tostring(tempData.name));
            cclog("-------------------------------------3")
            -- 公会等级
            local m_glv = tolua.cast(tempItem:objectForName("m_glv"),"CCLabelTTF");
            m_glv:setString(tostring(tempData.lv));
            cclog("-------------------------------------4")
            -- 公会玩家数量
            local m_gPlayerNum = tolua.cast(tempItem:objectForName("m_gPlayerNum"),"CCLabelTTF");
            m_gPlayerNum:setString(tostring(tempData.player_count) .. "/" .. tostring(tempData.player_max));
            cclog("-------------------------------------5")
            -- 公会会长名
            local m_gOwnerName = tolua.cast(tempItem:objectForName("m_gOwnerName"),"CCLabelTTF");
            m_gOwnerName:setString(tostring(tempData.owner));
            cclog("-------------------------------------6")
            -- 公会占领地图标位置
            local m_territory = tolua.cast(tempItem:objectForName("m_territory"),"CCNode");
            -- cclog("tempData == " .. json.encode(tempData))
            local gvg_land = tempData.gvg_land
            m_territory:removeAllChildrenWithCleanup(true)
            if gvg_land == 0 then
                local temp = game_util:createLabelTTF({text = string_helper.guild_join.none,color = ccc3(244,31,32),fontSize = 12});
                temp:setAnchorPoint(ccp(0.5,0.5))
                m_territory:addChild(temp,10)
            else
                local temp = CCSprite:createWithSpriteFrameName(gvg_land_table[gvg_land])
                temp:setAnchorPoint(ccp(0.5,0.5))
                m_territory:addChild(temp,10)
            end
            cclog("-------------------------------------7")
            --科技等级
            local m_tech_level = tolua.cast(tempItem:objectForName("m_tech_level"),"CCLabelTTF")
            local tech_lv = tempData.tech_lv or 1
            m_tech_level:setString(tostring(tech_lv))

            local sprite_select = tolua.cast(tempItem:objectForName("sprite_select"),"CCSprite")
                -- sprite_select:setVisible(true)
                -- self.last_select = sprite_select
            -- else
                sprite_select:setVisible(false)
            -- end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_select = ccbNode:spriteForName("sprite_select");
            if self.last_select ~= sprite_select then
                if self.last_select then
                    self.last_select:setVisible(false)
                end
                sprite_select:setVisible(true)
                self.last_select = sprite_select
                self.select_index = index
            end
            -- self:updataMsg( 3,self.m_control.m_data:getGuildCount()-index-1,'this');
            self:updataMsg( 3,index,'this');
        end
    end
    return TableViewHelper:create(params);
end

return guild_join_view;


