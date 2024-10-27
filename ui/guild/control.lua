require "shared.extern"


local guild_control = class("guildControl" , require("like_oo.oo_controlBase"));

function guild_control:create(  )
	-- body
	self.controlBase.create( self );
	cclog("guild_control:create");
	-- game_scene:setVisiblePropertyBar(true);
	-- game_scene.m_propertyBar:runAnimations("enter_anim");
end

function guild_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:goHome();
	elseif(msg == 3)then			-- 公会任务
		local function responseMethod(tag,gameData)
			game_scene:addPop("game_guild_help_pop",{gameData = gameData})
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_rescue_index"), http_request_method.GET, nil,"association_rescue_index")
	elseif(msg == 4)then			-- 公会成员
		cclog("---- guild 公会成员");
		self:openView("guild_player_list_pop" , self.m_data:getPrimitiveData());
	elseif(msg == 5)then			-- 公会消息
		cclog("---- guild 公会消息");
		-- self:openView("guild_message_edit", self.m_data:getPrimitiveData());

		--    self.m_data:getGuildMessage()
		-- cclog("self.m_data:getGuildMessage() == " .. self.m_data:getPrimitiveData())
		game_scene:addPop("game_guild_message_pop",{m_gameData = self.m_data:getPrimitiveData()})
	elseif(msg == 6)then			-- 公会研究
		cclog("---- guild 公会研究");
		self:openView("guild_research_pop" , self.m_data:getGuildData());
	elseif(msg == 7)then			-- 公会商店
		cclog("---- guild 公会商店");
		self:openView("guild_shop_pop" , self.m_data:getGuildData());
	elseif(msg == 8)then			-- 公会捐献
		cclog("---- guild 公会捐献");
		self:openView("guild_donate_pop" , self.m_data:getDonateData());
	elseif(msg == 9)then			-- 势力争夺
		cclog("---- guild 势力争夺");
		self:openView("guild_world_scene" , self.m_data:getDataAll());
		-- self:openView("guild_battle_info",nil)
	elseif msg == 10 then--公会boss
		local function responseMethod(tag,gameData)
			local allData = self.m_data:getDataAll()
			local players = allData.player
			local myUid = game_data:getUserStatusDataByKey("uid");
			local user_post = players[tostring(myUid)].title
			game_scene:addPop("game_guild_before_pop",{gameData = gameData,user_post = user_post})
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guildboss_open"), http_request_method.GET, nil,"guildboss_open")
	elseif msg == 11 then--新公会战
		------------------------- 注 请求网络获取 跳转到相应的公会战阶段 -------------------------
		--[[
			sort:
			1:公会站前阶段   捐献战旗，攻守双方联盟可能为空
			2:公会站前展示阶段，攻守双方已经确定
			3:公会战地图
			4:公会战结算
			5:非攻城方或防守方的人展示界面
		]]
		-- game_scene:enterGameUi("game_gvg_war",{})--公会战战中
		local function responseMethod(tag,gameData)
			local data = gameData:getNodeWithKey("data")
			local sort = data:getNodeWithKey("sort"):toInt()
			if sort == 1 then--外围战布阵开启
				game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
			elseif sort == 2 then--外围战战争开始
				game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
			elseif sort == 3 then--内城布阵开始
				game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
			elseif sort == 4 then--内城战开始
				game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
			elseif sort == 5 then
				
			elseif sort == -1 then--公会战未开启
				game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
				-- game_scene:addPop("game_gvg_end_pop",{callFunc = nil,enterType = "win"})
			else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
			end
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index")
	elseif(msg == 1234)then			-- 同意加入公会更新数据以及消息
		self.m_data.m_data.data = data;
		self.m_view:updataLabel()
	elseif msg == 102 then--聊天
		game_scene:addPop("ui_chat_pop",{openType = 2});
	elseif(msg == 1235) then--更新自己资金
		-- self.m_data.m_data.data = data;
		self.m_data:setMoney(data)
	elseif(msg == 8082) then--只有有奖励的公会能看到的东东
		local function responseMethod(tag,gameData)
			local data = self.m_data:getPrimitiveData()
			local players = data.data.player
			game_scene:addPop("game_gvg_allot_pop",{gameData = gameData,players = players})
		end
		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_reward_index"), http_request_method.GET, nil,"association_reward_index")
	end
end

return guild_control;