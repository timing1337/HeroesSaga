require "shared.extern"

local guild_player_prop_pop = class("guildPlayerPropPop" , require("like_oo.oo_controlBase"));

function guild_player_prop_pop:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_player_prop_pop:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_player_prop_pop:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		-- 申请者详情
		local function responseMethod(tag,gameData)
	        self:closeView();
	        game_scene:addPop("game_player_info_pop",{gameData = gameData})
	    end
	    local params = {};
	    params.uid = self.m_data:getUid();
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
	elseif(msg == 4)then
		-- 同意
		local function netDataCallBack( netData )
			if netData then
				self:updataMsg( 1234 , netData.data , "parent" );
				self:updataMsg( 1234 , netData.data , "guild_player_prop");
				self:closeView();
			else
				--重新刷新界面
				local function netDataCallBack2( netData )
					if netData then
						self:updataMsg( 1234 , netData.data , "parent" );
						self:updataMsg( 1234 , netData.data , "guild_player_prop");
						self:closeView();
					end
				end
				local association_id = game_data:getUserStatusDataByKey("association_id");
				self.m_data:getNetData(game_url.getUrlForKey("association_guild_detail"),{guild_id=association_id},netDataCallBack2);
			end
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_agree"),{user_id=self.m_data:getUid()},netDataCallBack,true,true);
	elseif(msg == 5)then
		-- 拒绝
		local function netDataCallBack( netData )
			-- body
			self:updataMsg( 1234 , netData.data , "parent" );
			self:updataMsg( 1234 , netData.data , "guild_player_prop");
			self:closeView();
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_not_agree"),{user_id=self.m_data:getUid()},netDataCallBack);
	end
end

function guild_player_prop_pop:onUpdata(  )
	-- body
end




return guild_player_prop_pop;