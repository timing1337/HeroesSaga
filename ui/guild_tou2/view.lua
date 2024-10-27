require "shared.extern"

local guild_tou2_view = class("guildTou2View",require("like_oo.oo_popBase"));

guild_tou2_view.m_ccb = nil;
-- 防守公会名字
guild_tou2_view.m_gname1 = nil;
-- 挑战公会名字
guild_tou2_view.m_gname2 = nil;
-- 防守方战旗数量
guild_tou2_view.m_flagCount1 = nil;
-- 挑战方战旗数量
guild_tou2_view.m_flagCount2 = nil;
-- 防守方加成比例
guild_tou2_view.m_percent1 = nil;
-- 挑战方加成比例
guild_tou2_view.m_percent2 = nil;
-- 参与说明
guild_tou2_view.m_tips = nil;
-- 投票信息
guild_tou2_view.m_touMsg = nil;

--场景创建函数
function guild_tou2_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();

	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag == 1)then
        	self:updataMsg(4);
        elseif(btnTag == 2)then
        	self:updataMsg(3);
    	end
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_tou2.ccbi");

	self.m_gname1 = tolua.cast(self.m_ccb:objectForName("m_gname1"),"CCLabelTTF");
	self.m_gname2 = tolua.cast(self.m_ccb:objectForName("m_gname2"),"CCLabelTTF");
	self.m_flagCount1 = tolua.cast(self.m_ccb:objectForName("m_flagCount1"),"CCLabelTTF");
	self.m_flagCount2 = tolua.cast(self.m_ccb:objectForName("m_flagCount2"),"CCLabelTTF");
	self.m_percent1 = tolua.cast(self.m_ccb:objectForName("m_percent1"),"CCLabelTTF");
	self.m_percent2 = tolua.cast(self.m_ccb:objectForName("m_percent2"),"CCLabelTTF");
	self.m_tips = tolua.cast(self.m_ccb:objectForName("m_tips"),"CCLabelTTF");
	self.m_touMsg = tolua.cast(self.m_ccb:objectForName("m_touMsg"),"CCLabelTTF");
    local m_selfPort = tolua.cast(self.m_ccb:objectForName("m_selfPort"),"CCLabelTTF")

    local uiData = self.m_control.m_data:getUIData()
    local ownerName = uiData.owner
    local challengeName = uiData.challenger

    if ownerName == nil or ownerName == "" then
        self.m_gname1:setString("无")
    else
        self.m_gname1:setString(tostring(ownerName))
    end
    if challengeName == nil or challengeName == "" then
        self.m_gname2:setString("无")
    else
        self.m_gname2:setString(tostring(challengeName))
    end

    local self_rank = uiData.rank.self_rank
    if self_rank == -1 then
        m_selfPort:setString("未参加捐献")
    else 
        m_selfPort:setString("捐献排名第".. self_rank .. "名")
    end


	self.m_rootView:addChild(self.m_ccb);
end

function guild_tou2_view:onEnter(  )
	-- body
end

function guild_tou2_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_tou2_view:createTableView( viewSize )
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    -- local daily_award_cfg = getConfig(game_config_field.daily_award)
    -- local tGameData = game_data:getDailyAwardData();
    -- local score = tGameData.score;
    -- local reward = tGameData.reward;
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
            local tempData = self.m_control.m_data:getGuildList(index);
            util.printf(tempData);

            
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
            self:updataMsg( 3,index,'this');
        end
    end
    return TableViewHelper:create(params);
end

return guild_tou2_view;