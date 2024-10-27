require "shared.extern"

local guild_player_prop_control = class("guildPlayerPropControl" , require("like_oo.oo_controlBase"));

function guild_player_prop_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_player_prop_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_player_prop_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then
		self:openView("guild_player_prop_pop",self.m_data:getPlayer(data));
	elseif(msg == 11)then
		self:openView("guild_player_list_pop",self.m_data.m_params);
		self:closeView();
	elseif(msg == 1234)then
		self.m_data.m_data = data;
		self.m_view:resetData();
	end
end

function guild_player_prop_control:onUpdata(  )
	-- body
	self.m_view:resetData();
end



return guild_player_prop_control;