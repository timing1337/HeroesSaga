--- 竞技场
local __pk = {
	m_first = true;
}
--[[--
	
]]
function __pk:create( t_params )
	-- body

	local function onCCBAnimEnd( lableName )
		-- body
		if(lableName == "onBack")then
        	local function endCallFunc()
            	self:destroy();
        	end
        	game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
			cclog("--------------------------onBack------------------------")
		end
	end
	
	local function onMainBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("-----------------button  " .. tostring(btnTag));
        if (btnTag == 1) then
        	-- 返回首页
			-- self.m_ccbNode:runAnimations("onBack");
			onCCBAnimEnd("onBack")
        elseif(btnTag == 2)then
        	-- 挑战页面按钮
        	game_scene:enterGameUi("game_pk",{pk_flag = "pk",gameData = self.m_gameData});
			-- self:destroy();
        elseif(btnTag == 3)then
        	-- 排行榜页面按钮
        	game_scene:enterGameUi("game_pk",{pk_flag = "rank",gameData = self.m_gameData});
			-- self:destroy();
        elseif(btnTag == 4)then
        	-- 兑换物品页面按钮
        	game_scene:enterGameUi("game_pk",{pk_flag = "buy",gameData = self.m_gameData});
			-- self:destroy();
		elseif(btnTag == 5)then
			-- 战报页面按钮
			game_scene:enterGameUi("game_pk",{pk_flag = "detail",gameData = self.m_gameData});
        elseif(btnTag == 10)then
        	-- 消除冷却
        elseif(btnTag == 11)then
        	-- 战报 -- 此按钮方法已经不用
        	local function responseMethod(tag,gameData)
				-- body
				cclog("------buy----\n" .. gameData:getNodeWithKey("data"):getFormatBuffer());
				local data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
				game_scene:addPop("game_pk_notice_pop",{gameData = data,parent = self});
        	end
        	
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_log"), http_request_method.GET, {},"arena_log");
        elseif(btnTag == 12)then
        	-- 物品兑换 新ui中被去掉
        	local function responseMethod(tag,gameData)
				-- body
				cclog("------buy----\n" .. gameData:getNodeWithKey("data"):getFormatBuffer());
				self.m_gameData.point = gameData:getNodeWithKey("data"):getNodeWithKey("point"):toInt();
				self.m_pk_buy_sp:setString(tostring(self.m_gameData.point));
				local tempCrystal = game_data:getUserStatusDataByKey("crystal");
				self.m_crystal_label:setString(tostring(tempCrystal));
        	end
        	--  nil
        	if(self.m_pk_buy_curtIndex<=0)then
        		return;
        	end
        	local tempShopId = self.m_pk_buy_item[self.m_pk_buy_flag][self.m_pk_buy_curtIndex].shop;
        	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, {shop_id=tempShopId},"arena_exchange")
        elseif(btnTag == 1001)then
        	-- 兑换道具分类 英雄 新ui中被去掉
        	local node = self.m_pk_buy_list:getParent();
        	self.m_pk_buy_list:removeFromParentAndCleanup(true);
        	self.m_pk_buy_list = self:createTableView_buy(node:getContentSize(),1);
        	node:addChild(self.m_pk_buy_list);
        	self.m_pk_buy_button[1]:setHighlighted(true);
			self.m_pk_buy_button[1]:setEnabled(false);
			self.m_pk_buy_button[2]:setHighlighted(false);
			self.m_pk_buy_button[2]:setEnabled(true);
			self.m_pk_buy_button[3]:setHighlighted(false);
			self.m_pk_buy_button[3]:setEnabled(true);
			self.m_pk_buy_flag = 1;
        elseif(btnTag == 1002)then
        	-- 兑换道具分类 装备 新ui中被去掉
        	local node = self.m_pk_buy_list:getParent();
        	self.m_pk_buy_list:removeFromParentAndCleanup(true);
        	self.m_pk_buy_list = self:createTableView_buy(node:getContentSize(),2);
        	node:addChild(self.m_pk_buy_list);
        	self.m_pk_buy_button[2]:setHighlighted(true);
			self.m_pk_buy_button[2]:setEnabled(false);
			self.m_pk_buy_button[1]:setHighlighted(false);
			self.m_pk_buy_button[1]:setEnabled(true);
			self.m_pk_buy_button[3]:setHighlighted(false);
			self.m_pk_buy_button[3]:setEnabled(true);
			self.m_pk_buy_flag = 2;
        elseif(btnTag == 1003)then
        	-- 兑换道具分类 道具 新ui中被去掉
        	cclog("-------------------- 1003")
        	local node = self.m_pk_buy_list:getParent();
        	self.m_pk_buy_list:removeFromParentAndCleanup(true);
        	self.m_pk_buy_list = self:createTableView_buy(node:getContentSize(),3);
        	node:addChild(self.m_pk_buy_list);
        	self.m_pk_buy_button[3]:setHighlighted(true);
			self.m_pk_buy_button[3]:setEnabled(false);
			self.m_pk_buy_button[1]:setHighlighted(false);
			self.m_pk_buy_button[1]:setEnabled(true);
			self.m_pk_buy_button[2]:setHighlighted(false);
			self.m_pk_buy_button[2]:setEnabled(true);
			self.m_pk_buy_flag = 3;
        elseif(btnTag == 100)then
        	-- 右上按钮
        end
	end

	-- 挑战玩家
	local function onPlayerClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if self.m_gameData.front_user[btnTag] == nil then return end
        self.m_pk_current_button_id = btnTag;
        -- pop 框按钮数据
        local function menuPopCallFunc( tag )
        	-- body
        	if(tag==1)then		-- 发起挑战
        		game_scene:removePopByName("game_menu_pop");
				local tempUid = self.m_gameData.front_user[self.m_pk_current_button_id].uid;
				local rank = self.m_gameData.front_user[self.m_pk_current_button_id].rank;
				local function responseMethod(tag,gameData)
			        -- body
					game_data:setBattleType("game_pk");
        			game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        			self:destroy();
        		end
        		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_battle"), http_request_method.GET, {target = tempUid,rank = rank},"arena_battle");
        	elseif(tag==2)then	-- 查看资料
        		game_scene:removePopByName("game_menu_pop");
        		local tempUid = self.m_gameData.front_user[self.m_pk_current_button_id].uid;
    			local function responseMethod(tag,gameData)
        			game_scene:addPop("game_player_info_pop",{gameData = gameData})
    			end
    			network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, {uid = tempUid},"user_info")
        	elseif(tag==3)then	-- 加为好友
        		game_scene:removePopByName("game_menu_pop");
        		local tempUid = self.m_gameData.front_user[self.m_pk_current_button_id].uid;
            	local function responseMethod(tag,gameData)
                	game_util:addMoveTips({text = string_helper.__pk.success_add_friend});
            	end
            	local params = {};
            	params.target_id = tempUid
            	network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_add_friend"), http_request_method.GET, params,"friend_add_friend")
        	else
        		game_scene:removePopByName("game_menu_pop");
        	end
        end
        local pkMenuTab = {{title = string_helper.__pk.send_challage,type=2},{title = string_helper.__pk.ckzl,type=1},{title = string_helper.__pk.add_friend,type=1}};
        local px,py = tagNode:getPosition();
        local pos = tagNode:getParent():convertToWorldSpace(ccp(px,py));
        game_scene:addPop("game_menu_pop",{menuTab = pkMenuTab,pos = pos,callFunc = menuPopCallFunc}); 
	end

	-- 挑战玩家
	local function onPlayerTZ( target,event )
		-- body
		local tagNode = tolua.cast(target,"CCNode");
		local btnTag = tagNode:getTag();
		if self.m_gameData.front_user[btnTag] == nil then return end
		local tempUid = self.m_gameData.front_user[btnTag].uid;
		local function responseMethod(tag,gameData)
			-- body
			game_data:setBattleType("game_pk");
        	game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        	self:destroy();
        end
        	
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_battle"), http_request_method.GET, {target = tempUid},"arena_battle");
	end

	self.m_ccbNode = luaCCBNode:create();
	local scene = CCScene:create()
	scene:addChild(self.m_ccbNode);
	self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	if(t_params == nil or t_params.gameData == nil)then
		-- default
		local function responseMethod(tag,gameData)
			self.m_gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer());
			self.m_ccbNode:registerFunctionWithFuncName("onPlayerClick",onPlayerClick);
			self.m_ccbNode:registerFunctionWithFuncName("onPlayerTZ",onPlayerTZ);
            self:initPk();
        end
        --  nil
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
		
	elseif(t_params.pk_flag == "pk")then
		-- pk page
		self.m_gameData = t_params.gameData;
		self.m_ccbNode:registerFunctionWithFuncName("onPlayerClick",onPlayerClick);
		self.m_ccbNode:registerFunctionWithFuncName("onPlayerTZ",onPlayerTZ);
		self:initPk();
	elseif(t_params.pk_flag == "rank")then
		-- pk_rand page
		self.m_gameData = t_params.gameData;
		self:initRank();
	elseif(t_params.pk_flag == "buy")then
		-- pk_buy page
		self.m_gameData = t_params.gameData;
		self:initBuy();
	elseif(t_params.pk_flag == "detail")then
		self.m_gameData = t_params.gameData;
		self:initDetail();
	end
	if(self.m_first)then
		self.m_first=false;
		self.m_ccbNode:runAnimations("onEnter");
	end
	self.m_ccbNode:registerAnimFunc(onCCBAnimEnd);
	return scene;
end

function __pk:destroy(  )
	-- body
	if(self.m_pk_scheduleId~=nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_pk_scheduleId);
		self.m_pk_scheduleId = nil;
	end
	if(self.m_pk_award_scheduleId~=nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_pk_award_scheduleId);
		self.m_pk_award_scheduleId = nil;
	end
	self.m_first = true;
end

function __pk:initPk(  )
	-- game_sound:playMusic("background_home",true);
	-- body
	cclog("--------------pk--------------");
	self.m_page_flag = 1;
	self.m_ccbNode:openCCBFile("ccb/ui_pk_pop.ccbi");
	-- hand icon
	self.m_pk_name = tolua.cast(self.m_ccbNode:objectForName("m_pk_name"),"CCLabelTTF");
	self.m_pk_icon = tolua.cast(self.m_ccbNode:objectForName("m_pk_icon"),"CCNode");
	self.m_pk_place = tolua.cast(self.m_ccbNode:objectForName("m_pk_place"),"CCLabelTTF");
	self.m_pk_point = tolua.cast(self.m_ccbNode:objectForName("m_pk_point"),"CCLabelTTF");
	self.m_pk_backPoint = tolua.cast(self.m_ccbNode:objectForName("m_pk_backPoint"),"CCLabelTTF");
	self.m_pk_backFood = tolua.cast(self.m_ccbNode:objectForName("m_pk_backFood"),"CCLabelTTF");
	self.m_pk_backMetal = tolua.cast(self.m_ccbNode:objectForName("m_pk_backMetal"),"CCLabelTTF");
	self.m_pk_backEnergy = tolua.cast(self.m_ccbNode:objectForName("m_pk_backEnergy"),"CCLabelTTF");
	self.m_pk_time = tolua.cast(self.m_ccbNode:objectForName("m_pk_time"),"CCLabelTTF");
	self.m_pk_count = tolua.cast(self.m_ccbNode:objectForName("m_pk_count"),"CCLabelTTF");
	self.m_pk_combat = tolua.cast(self.m_ccbNode:objectForName("m_pk_combat"),"CCLabelTTF");

	-- self.m_crystal_label = tolua.cast(self.m_ccbNode:objectForName("m_able_crystal_label"),"CCLabelTTF");
	-- local tempCrystal = game_data:getUserStatusDataByKey("crystal");
	-- self.m_crystal_label:setString(tostring(tempCrystal));

	-- local tempListNode = tolua.cast(self.m_ccbNode:objectForName("m_list_view_bg"),"CCLayer");
	-- self.m_pk_list = self:createTableView_pk(tempListNode:getContentSize());
	-- tempListNode:addChild(self.m_pk_list);
	local unEnableButton = tolua.cast(self.m_ccbNode:objectForName("m_tab_btn_1"),"CCControlButton");
	unEnableButton:setHighlighted(true);
	unEnableButton:setEnabled(false);

	-- 新ui部分
	local roleConfig = getConfig(game_config_field.role_detail);
	self.m_player_bt = {};
	for i=1,math.min(5,#self.m_gameData.front_user) do
		local tempFrontUser = self.m_gameData.front_user[i];
		self.m_player_bt[i] = tolua.cast(self.m_ccbNode:objectForName("m_player_bt" .. tostring(i)),"CCControlButton");
		local tempPlayerRank = tolua.cast(self.m_ccbNode:objectForName("m_player_rank" .. tostring(i)),"CCLabelTTF");
		tempPlayerRank:setString(tostring(tempFrontUser.rank));
		local tempPlayerName = tolua.cast(self.m_ccbNode:objectForName("m_player_name" .. tostring(i)),"CCLabelTTF");
		tempPlayerName:setString(tempFrontUser.name);
		local tempPlayerLv = tolua.cast(self.m_ccbNode:objectForName("m_player_lv" .. tostring(i)),"CCLabelTTF");
		tempPlayerLv:setString(tostring(tempFrontUser.level));
		local tempPlayerIcon = tolua.cast(self.m_ccbNode:objectForName("m_player_icon" .. tostring(i)),"CCNode");
		local m_union_label = tolua.cast(self.m_ccbNode:objectForName("m_union_label_" .. tostring(i)),"CCLabelTTF");
		m_union_label:setString(string_helper.__pk.not_guild);
 	
 		local icon = game_util:createPlayerBattleImgRoleId(tostring(tempFrontUser.role));
		if icon then
			tempPlayerIcon:addChild(icon);
		else
			cclog("tempFrontUser.role " .. tempFrontUser.role .. " not found !")
		end
		-- 通过front_user.role获得用户的角色图标；
		local tempPlayerCombat = tolua.cast(self.m_ccbNode:objectForName("m_player_combat" .. tostring(i)),"CCLabelTTF");
		tempPlayerCombat:setString(tostring(tempFrontUser.combat));
	end
	self.m_pk_reward_time = tolua.cast(self.m_ccbNode:objectForName("m_reward_time"),"CCLabelTTF");
	self.m_pk_lv = tolua.cast(self.m_ccbNode:objectForName("m_lv"),"CCLabelTTF");
	self.m_time_layer = tolua.cast(self.m_ccbNode:objectForName("m_time_layer"),"CCLayerColor");
	-- 新ui部分，完
	self:updata_pk();
end

function __pk:initRank(  )
	-- body
	cclog("--------------pk rank--------------");
	self.m_page_flag = 2;
	self.m_ccbNode:openCCBFile("ccb/ui_pk_rank_pop.ccbi");
	-- self.m_pk_rank_name = tolua.cast(self.m_ccbNode:objectForName("m_pk_name"),"CCLabelTTF");
	-- self.m_pk_rank_position = tolua.cast(self.m_ccbNode:objectForName("m_pk_position"),"CCLabelTTF");
	-- self.m_pk_rank_icon = tolua.cast(self.m_ccbNode:objectForName("m_pk_icon"),"CCLabelTTF");
	-- self.m_pk_rank_point = tolua.cast(self.m_ccbNode:objectForName("m_pk_point"),"CCLabelTTF");

	-- self.m_crystal_label = tolua.cast(self.m_ccbNode:objectForName("m_able_crystal_label"),"CCLabelTTF");
	-- local tempCrystal = game_data:getUserStatusDataByKey("crystal");
	-- self.m_crystal_label:setString(tostring(tempCrystal));
	-- self.m_pk_rank_place = tolua.cast(self.m_ccbNode:objectForName("m_pk_place"),"CCLabelTTF");
	-- self.m_pk_rank_lv = tolua.cast(self.m_ccbNode:objectForName("m_lv"),"CCLabelTTF");

	-- util.printf(game_data.m_tUserStatusData);

	local tempListNode = tolua.cast(self.m_ccbNode:objectForName("m_list_view_bg"),"CCLayer");
	--添加tabelview
	self.m_pk_rank_list = self:createTableView_rank(tempListNode:getContentSize());
	tempListNode:addChild(self.m_pk_rank_list);
	local unEnableButton = tolua.cast(self.m_ccbNode:objectForName("m_tab_btn_2"),"CCControlButton");
	unEnableButton:setHighlighted(true);
	unEnableButton:setEnabled(false);
	self:updata_rank();
end

function __pk:initBuy(  )
	-- body

	cclog("--------------pk buy--------------");
	self.m_page_flag = 3;
	self.m_ccbNode:openCCBFile("ccb/ui_pk_buy_pop.ccbi");
	-- self.m_pk_buy_button={};
	-- for i=1,3 do
	-- 	self.m_pk_buy_button[i] = tolua.cast(self.m_ccbNode:objectForName("m_type_btn_" .. tostring(i)),"CCControlButton");
	-- end
	-- self.m_pk_buy_button[1]:setHighlighted(true);
	-- self.m_pk_buy_button[1]:setEnabled(false);
	-- self.m_pk_buy_information = tolua.cast(self.m_ccbNode:objectForName("m_intro_label"),"CCLabelTTF");
	self.tempListNode = tolua.cast(self.m_ccbNode:objectForName("m_list_view_bg"),"CCLayer");

	-- self.m_crystal_label = tolua.cast(self.m_ccbNode:objectForName("m_able_crystal_label"),"CCLabelTTF");
	-- local tempCrystal = game_data:getUserStatusDataByKey("crystal");
	-- self.m_crystal_label:setString(tostring(tempCrystal));

	self.m_pk_buy_name = tolua.cast(self.m_ccbNode:objectForName("m_pk_name"),"CCLabelTTF");
	self.m_pk_buy_lv = tolua.cast(self.m_ccbNode:objectForName("m_lv"),"CCLabelTTF");

	self.m_pk_point = tolua.cast(self.m_ccbNode:objectForName("m_pk_point"),"CCLabelTTF");
	self.m_pk_buy_place = tolua.cast(self.m_ccbNode:objectForName("m_pk_place"),"CCLabelTTF");

	local unEnableButton = tolua.cast(self.m_ccbNode:objectForName("m_tab_btn_3"),"CCControlButton");
	unEnableButton:setHighlighted(true);
	unEnableButton:setEnabled(false);

	self.m_exchange_log_tab = self.m_gameData.exchange_log or {};
	self.m_pk_buy_item = {{},{},{},all={}};
	local gameShopConfig = getConfig(game_config_field.arena_shop);
	local shopCount = gameShopConfig:getNodeCount();
	local level = game_data:getUserStatusDataByKey("level") or 1;
	local show_level = nil;
	local downValue,upValue = nil;
	for i=1,shopCount do
		local shopNode = gameShopConfig:getNodeAt(i-1);
		local shop_reward = shopNode:getNodeWithKey("shop_reward")
		show_level = shopNode:getNodeWithKey("show_level")
		downValue,upValue = 1,1;
		if show_level and show_level:getNodeCount() > 1 then
			downValue = show_level:getNodeAt(0):toInt();
			upValue = show_level:getNodeAt(1):toInt();
		end
		if shop_reward:getNodeCount() > 0 and level >= downValue and level <= upValue then
			local itemData = shop_reward:getNodeAt(0);
			local shopSort = itemData:getNodeAt(0)
			if( shopSort == 1)then
				local index = #self.m_pk_buy_item[1]+1;
				self.m_pk_buy_item[1][index] = shopNode:getKey()
				local indexall = #self.m_pk_buy_item["all"]+1;
				self.m_pk_buy_item["all"][indexall] = self.m_pk_buy_item[1][index];
			elseif(shopSort == 2)then
				local index = #self.m_pk_buy_item[2]+1;
				self.m_pk_buy_item[2][index] = shopNode:getKey()
				local indexall = #self.m_pk_buy_item["all"]+1;
				self.m_pk_buy_item["all"][indexall] = self.m_pk_buy_item[2][index];
			else
				local index = #self.m_pk_buy_item[3]+1;
				self.m_pk_buy_item[3][index] = shopNode:getKey()
				local indexall = #self.m_pk_buy_item["all"]+1;
				self.m_pk_buy_item["all"][indexall] = self.m_pk_buy_item[3][index];
			end
		end
	end
	self:refreshBuy();
end

function __pk:refreshBuy(  )
	-- 添加tabelview
	self.tempListNode:removeAllChildrenWithCleanup(true);
	self.m_pk_buy_list = self:createTableView_buy(self.tempListNode:getContentSize(),"all");
	self.m_pk_buy_flag = "all";
	self.m_pk_buy_curtIndex = 1;
	self.tempListNode:addChild(self.m_pk_buy_list);
	self:updata_buy();
end

-- 战报初始化
function __pk:initDetail(  )
	-- body
	cclog("--------------pk buy--------------");
	self.m_page_flag = 4;
	self.m_ccbNode:openCCBFile("ccb/ui_pk_detail_pop.ccbi");
	local unEnableButton = tolua.cast(self.m_ccbNode:objectForName("m_tab_btn_4"),"CCControlButton");
	unEnableButton:setHighlighted(true);
	unEnableButton:setEnabled(false);
	local tempListNode = tolua.cast(self.m_ccbNode:objectForName("m_list_view_bg"),"CCLayer");
	self.m_pk_detail_list = self:createTableView_detail(tempListNode:getContentSize());
	tempListNode:addChild(self.m_pk_detail_list);
end

function __pk:updata_pk(  )
	-- body
	local function tick( dt )
		-- body
		if(self.m_page_flag == 1)then
			local tempH = tostring(math.floor(self.m_gameData.cd_expire/3600));
			local tempM = tostring(math.fmod(math.floor(self.m_gameData.cd_expire/60),60));
			local tempS = tostring(math.fmod(self.m_gameData.cd_expire,60));
			if(tonumber(tempH)<10)then tempH = '0' .. tempH; end
			if(tonumber(tempM)<10)then tempM = '0' .. tempM; end
			if(tonumber(tempS)<10)then tempS = '0' .. tempS; end
			local tempEndTime = tempH .. ":" .. tempM .. ":" .. tempS;
			self.m_pk_time:setString(tempEndTime);
		end
		if(self.m_gameData.cd_expire<=0)then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_pk_scheduleId);
			self.m_pk_scheduleId = nil;
			self.m_time_layer:setVisible(false);
			for i=1,math.min(5,#self.m_player_bt) do
				self.m_player_bt[i]:setVisible(true);
			end
		end
		self.m_gameData.cd_expire = self.m_gameData.cd_expire-1;
	end
	
	cclog("------------rele------------------");
	local roleConfig = getConfig(game_config_field.role_detail);
	cclog("------------rele------------------2");
	cclog("-------role-----" .. tostring(game_data.m_tUserStatusData.role));
	local temprole = roleConfig:getNodeWithKey(tostring(game_data.m_tUserStatusData.role));
	cclog("------------rele------------------3");
	local imgName = temprole:getNodeWithKey("img"):toStr();
	cclog("------------rele------------------4");
	imgName = "humen/" .. imgName .. ".png";
	local iconSprite = CCSprite:create(imgName);
	iconSprite:setScale(0.5);

	cclog("------------rele------------------5");
	self.m_pk_icon:addChild(iconSprite);
	
	self.m_pk_place:setString(tostring(self.m_gameData.rank));
	self.m_pk_point:setString(tostring(self.m_gameData.point));
	
	self.m_pk_count:setString(tostring(self.m_gameData.can_battle_times));
	self.m_pk_combat:setString(tostring(self.m_gameData.combat));


	local function award_expire_tick( dt )
		-- body
		if(self.m_gameData.award_expire<=0)then
			self.m_gameData.award_expire=600;
			if(self.m_gameData.tempPoint~=nil)then
				self.m_gameData.point = self.m_gameData.point+self.m_gameData.tempPoint;
				if(self.m_page_flag == 1 or self.m_page_flag == 3)then
					self.m_pk_point:setString(tostring(self.m_gameData.point));
				end
			end
		end
		if(self.m_page_flag == 1)then
			local tempH = tostring(math.floor(self.m_gameData.award_expire/3600));
			local tempM = tostring(math.fmod(math.floor(self.m_gameData.award_expire/60),60));
			local tempS = tostring(math.fmod(self.m_gameData.award_expire,60));
			if(tonumber(tempH)<10)then tempH = '0' .. tempH; end
			if(tonumber(tempM)<10)then tempM = '0' .. tempM; end
			if(tonumber(tempS)<10)then tempS = '0' .. tempS; end
			local tempEndTime = tempH .. ":" .. tempM .. ":" .. tempS;
			self.m_pk_reward_time:setString(tempEndTime);
			-- cclog("------------------award_expire_tick---------------" .. tostring(self.m_gameData.award_expire) .. tempEndTime)
		end
		self.m_gameData.award_expire = self.m_gameData.award_expire-1;
	end

	

	self.m_pk_lv:setString(tostring(game_data.m_tUserStatusData.level));
	self.m_pk_name:setString(game_data.m_tUserStatusData.show_name);

	local gameArenaConfig = getConfig(game_config_field.arena_award);
	local count = gameArenaConfig:getNodeCount();
	local start_i = 1;
	local end_i = count;
	local index = 0;
	while (true) do

		if (end_i<start_i) then
			index = 0;
			break;
		end
		index = math.floor((end_i-start_i+1)/2)+start_i;
		cclog("----------------- index " .. tostring(index));
		local tempNode = gameArenaConfig:getNodeWithKey(tostring(index));
		if(tempNode:getNodeWithKey("start_rank"):toInt()>self.m_gameData.rank)then
			end_i=index-1;
		elseif(tempNode:getNodeWithKey("end_rank"):toInt()<self.m_gameData.rank)then
			start_i=index+1;
		else
			break;
		end
	end
	if(index>0)then
		local tempNode = gameArenaConfig:getNodeWithKey(tostring(index));
		self.m_gameData.tempPoint = tempNode:getNodeWithKey("per_point"):toInt();
		local tempFood = tempNode:getNodeWithKey("per_food"):toInt();
		local tempMetal = tempNode:getNodeWithKey("per_metal"):toInt();
		local tempEnergy = tempNode:getNodeWithKey("per_energy"):toInt();
		self.m_pk_backPoint:setString(tostring(self.m_gameData.tempPoint));
		self.m_pk_backFood:setString(tostring(tempFood));
		self.m_pk_backMetal:setString(tostring(tempMetal));
		self.m_pk_backEnergy:setString(tostring(tempEnergy));
	end
	-- self.m_pk_name:setString(); -- 设置自己的名字
	-- self.m_pk_reward_time:setString();	-- 设置下次奖励时间
	-- 设置资源获取时间
	if(self.m_pk_award_scheduleId==nil)then
		self.m_pk_award_scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(award_expire_tick, 1, false);
	end
	-- 设置pkcd时间
	if(self.m_gameData.cd_expire>0)then
		for i=1,math.min(5,#self.m_player_bt) do
			self.m_player_bt[i]:setVisible(false);
		end
		self.m_time_layer:setVisible(true);
		if(self.m_pk_scheduleId==nil)then
			self.m_pk_scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1, false);
		end
	else
		for i=1,math.min(5,#self.m_player_bt) do
			self.m_player_bt[i]:setVisible(true);
		end
		self.m_time_layer:setVisible(false);
		if(self.m_pk_scheduleId~=nil)then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_pk_scheduleId);
			self.m_pk_scheduleId = nil;
		end
	end
end

function __pk:updata_buy(  )
	-- body
	self.m_pk_point:setString(tostring(self.m_gameData.point));
	-- self.m_pk_buy_place:setString(tostring(self.m_gameData.rank));
	-- self.m_pk_buy_lv:setString("Lv." .. tostring(game_data.m_tUserStatusData.level));
	-- self.m_pk_buy_name:setString(game_data.m_tUserStatusData.show_name);
end

function __pk:updata_rank(  )
	-- body
	-- self.m_pk_rank_name:setString(self.m_gameData.top[1].name);
	-- self.m_pk_rank_place:setString(tostring(self.m_gameData.rank));
	-- self.m_pk_rank_point:setString(tostring(self.m_gameData.point));
	-- self.m_pk_rank_lv:setString("Lv." .. tostring(game_data.m_tUserStatusData.level));
	-- self.m_pk_rank_name:setString(game_data.m_tUserStatusData.show_name);

end

function __pk:updata_detail(  )
	-- body
end

function __pk:onItemClick_pk( index )
	if self.m_gameData.front_user[index+1] == nil then return end
	-- body
	
	local function responseMethod(tag,gameData)
        -- if gameData:getNodeWithKey("data"):getNodeWithKey("battle"):getNodeWithKey("no_fight"):toInt() == 1 then
        -- 	return;
        -- end
        -- game_data:setSelNeutralBuildingId(self.m_selBuildingId);
        -- game_data:setBattleType("game_neutral_city_map");
        game_data:setBattleType("game_pk");
        game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        self:destroy();
    end
    local tempUser = self.m_gameData.front_user[index+1];
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_battle"), http_request_method.GET, {target=tempUser.uid},"arena_index");
end

function __pk:onItemClick_buy(index,id)
	-- body
	self.m_pk_buy_curtIndex = index+1;
	
	--改动可以一次性买多个的
	local gameShopConfig = getConfig(game_config_field.arena_shop);
	local gameShop = gameShopConfig:getNodeWithKey(self.m_pk_buy_item[id][index+1]);
	local times = gameShop:getNodeWithKey("times"):toInt();--总购买次数
	local alreadyBuy = 0
	if times == -1 then
		alreadyBuy = 0;
	else
		local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
		if exchange_log_item then
			alreadyBuy = exchange_log_item.times;
		else
			alreadyBuy = 0;
		end
	end
	
    local t_params = 
    {
        okBtnCallBack = function(count)
            if self.m_pk_buy_pop_popUi then
            	self.m_pk_buy_pop_popUi:removeFromParentAndCleanup(true);
            	self.m_pk_buy_pop_popUi = nil;
        	end
            local function responseMethod(tag,gameData)
				local data = gameData:getNodeWithKey("data");
				cclog("------buy----\n" .. data:getFormatBuffer());
				self.m_gameData.point = data:getNodeWithKey("point"):toInt();
				self.m_pk_point:setString(tostring(self.m_gameData.point));
				game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
				local exchange_log_tab = json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
				for k,v in pairs(exchange_log_tab) do
					self.m_exchange_log_tab[k] = v;
				end
				self:refreshBuy();
            end
            if(self.m_pk_buy_curtIndex<=0)then
        		return;
        	end
            local params = {};
            params.shop_id = self.m_pk_buy_item[self.m_pk_buy_flag][self.m_pk_buy_curtIndex];
            params.count = count;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_exchange"), http_request_method.GET, params,"arena_exchange")
        end,
        shopItemId = gameShop:getKey(),
        maxCount = times,--传最大和已买的数量即可
        alreadyCount = alreadyBuy,--已
        touchPriority = GLOBAL_TOUCH_PRIORITY,
        enterType = "game_pk",
    }
    game_scene:addPop("game_shop_pop",t_params)
end

function __pk:onItemClick_rank( index )
	-- body
	-- local tempPlayer = self.m_gameData.top[index+1];
	-- self.m_pk_rank_position:setString("第" .. tostring(tempPlayer.rank) .. "名");
	-- self.m_pk_rank_name:setString(tempPlayer.name);
end

-- pk列表生成
function __pk:createTableView_pk(viewSize)
    
end

-- 兑换物品列表生成 这个地方呀，有点问题
function __pk:createTableView_buy( viewSize , id)
    local itemsCount = #self.m_pk_buy_item[id];
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
	local gameShopConfig = getConfig(game_config_field.arena_shop);
	-- body
	self.m_pk_buy_curtNode = nil;
	self.m_pk_buy_curtIndex = 0;
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_pk_buy_pop_item.ccbi");
            ccbNode:setPosition(ccp(0,0));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local iCountText = tolua.cast(ccbNode:objectForName("m_count"),"CCLabelTTF");
                local iIconNode = tolua.cast(ccbNode:objectForName("m_icon"),"CCLayer");
                local m_limit_label = tolua.cast(ccbNode:objectForName("m_limit_label"),"CCLabelTTF");
                local m_name_label = tolua.cast(ccbNode:objectForName("m_name_label"),"CCLabelTTF");
                m_name_label:setString("");

                local gameShop = gameShopConfig:getNodeWithKey(self.m_pk_buy_item[id][index+1]);
                local times = gameShop:getNodeWithKey("times"):toInt();
                if times == -1 then
                	m_limit_label:setString(string_helper.__pk.not_limit);
                else
                	local exchange_log_item = self.m_exchange_log_tab[gameShop:getKey()]
                	if exchange_log_item then
                		m_limit_label:setString(string_helper.__pk.charge_limit .. exchange_log_item.times .. "/" .. times);
                	else
                		m_limit_label:setString(string_helper.__pk.charge_limit .. "0/" .. times);
                	end
                end
                local shop_reward = gameShop:getNodeWithKey("shop_reward")
                iIconNode:removeAllChildrenWithCleanup(false);
                if shop_reward:getNodeCount() > 0 then
                	local icon,name = game_util:getRewardByItem(shop_reward:getNodeAt(0));
                	if icon then
                		local size = iIconNode:getContentSize();
                		icon:setPosition(ccp(size.width/2,size.height/2));
                		iIconNode:addChild(icon);
                	end
                	if name then
                		m_name_label:setString(name);
                	end
                end
                iCountText:setString(gameShop:getNodeWithKey("need_point"):toInt());
            else
            	m_spr_bg_up:setVisible(true);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            self:onItemClick_buy(index,id);
            -- if(self.m_pk_buy_curtNode~=nil)then
            -- 	tolua.cast(self.m_pk_buy_curtNode:objectForName("m_colorLayer"),"CCLayerColor"):setVisible(false);
            -- end
            -- self.m_pk_buy_curtNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            -- if(self.m_pk_buy_curtNode==nil)then
            -- 	cclog("-------------curt node is nil");
            -- end
            -- tolua.cast(self.m_pk_buy_curtNode:objectForName("m_colorLayer"),"CCLayerColor"):setVisible(true);
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

-- 排行榜列表生成
function __pk:createTableView_rank( viewSize )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.totalItem = #self.m_gameData.top;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
    	cclog("rank index ================================" .. index);
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_pk_rank_pop_item.ccbi");
            cclog("---------------------open file-------");
            ccbNode:setPosition(ccp(0,0));
            cell:addChild(ccbNode,10,10);
        end
        if cell~=nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local iPosText = tolua.cast(ccbNode:objectForName("m_pos"),"CCLabelTTF");
                local iNameText = tolua.cast(ccbNode:objectForName("m_name"),"CCLabelTTF");
                local iLevelText = tolua.cast(ccbNode:objectForName("m_lv"),"CCLabelTTF");
                local iIconNode = tolua.cast(ccbNode:objectForName("m_icon"),"CCLayer");
                local iCombat = tolua.cast(ccbNode:objectForName("m_combat"),"CCLabelTTF");

                
                local tempUser = self.m_gameData.top[index+1];
                local roleConfig = getConfig(game_config_field.role_detail);
				local temprole = roleConfig:getNodeWithKey(tostring(tempUser.role));
				local icon = game_util:createIconByName(temprole:getNodeWithKey("icon"):toStr());
				if icon then
					icon:setAnchorPoint(ccp(0,0));
					iIconNode:addChild(icon);
				end
                iPosText:setString(tostring(tempUser.rank));
                iNameText:setString(tostring(tempUser.name))
                iLevelText:setString(tempUser.level);
                iCombat:setString(tostring(tempUser.combat));
            end
        else
        	cclog("---------------new table cell have error ----" .. tostring(index));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            self:onItemClick_rank(index);
        end
    end
    return TableViewHelper:create(params);
end

-- 战斗报列表生成
function __pk:createTableView_detail( viewSize )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = #self.m_gameData.log;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            cclog("----------------------------- 1");
            local function onRelook( target,event )
            	-- body
            	cclog("---------------- onRelook be click --------------" .. tostring(self.m_pk_detail_curtIndex));
            	local function responseMethod(tag,gameData)
				    -- body
					game_data:setBattleType("game_pk");
        			game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        			self:destroy();
        		end
        		local tempkey = self.m_gameData.log[self.m_pk_detail_curtIndex+1].battle_log;
        		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
            end
            local function onWeibo( target,event )
            	-- body
            	cclog("---------------- onWeibo be click ---------------");
            end
            ccbNode:registerFunctionWithFuncName("onRelook",onRelook);
            ccbNode:registerFunctionWithFuncName("onWeibo",onWeibo);
            ccbNode:openCCBFile("ccb/ui_pk_detail_pop_item.ccbi");
            local tempRelook = tolua.cast(ccbNode:objectForName("m_relook"),"CCControlButton");
            local tempWeibo = tolua.cast(ccbNode:objectForName("m_weibo"),"CCControlButton");
            tempRelook:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            tempWeibo:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);

            cclog("----------------------------- 2");
            ccbNode:setPosition(ccp(0,0));
            cell:addChild(ccbNode,10,10);
            cclog("----------------------------- 3");
        end
        if cell~=nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            cclog("----------------------------- 4");
            if ccbNode then
            	local tempLog = self.m_gameData.log[index+1];
                local tempPlayerIcon = tolua.cast(ccbNode:objectForName("m_player_icon"),"CCSprite");
                cclog("----------------------------- 5");

                local tempBattleInfor = tolua.cast(ccbNode:objectForName("m_battle_information"),"CCLabelTTF");
                cclog("----------------------------- 6");
                tempBattleInfor:setString(tostring(tempLog.tp));
                cclog("----------------------------- 7");

                local roleConfig = getConfig(game_config_field.role_detail);
                cclog("----------------------------- 71");
				local temprole = roleConfig:getNodeWithKey(tostring(tempLog.role));
				cclog("----------------------------- 72");
				local imgName = temprole:getNodeWithKey("icon"):toStr();
				local icon = game_util:createIconByName(imgName);
				if icon then
					tempPlayerIcon:addChild(icon);
				end
            end
        else
        	cclog("---------------new table cell have error ----" .. tostring(index));
        end
        cclog("----------------------------- 8");
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            self.m_pk_detail_curtIndex = index;
        end
    end
    return TableViewHelper:create(params);
end
return __pk
