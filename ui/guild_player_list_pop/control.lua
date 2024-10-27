require "shared.extern"

local guild_player_list_pop_control = class("guildPlayerListPopControl" , require("like_oo.oo_controlBase"));

function guild_player_list_pop_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_player_list_pop_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_player_list_pop_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		local tempPlayer = self.m_data:getPlayer(data);
		local tempMe = self.m_data:getPlayerWithUid(game_data:getUserStatusDataByKey("uid"));
		cclog("--------------- player opiton ---------------");
		util.printf(tempPlayer);
		cclog("---------------------------------------------");
		self:openView("guild_player_list_option",{player = tempPlayer , me = tempMe});
	elseif(msg == 12)then
		self:openView("guild_player_prop",self.m_data.m_params);
		self:closeView();
	elseif(msg == 2345)then
		self.m_data:changeData(data);
		self.m_view:updataItem();
	end
end

return guild_player_list_pop_control;