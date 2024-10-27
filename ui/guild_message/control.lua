require "shared.extern"

local guild_message_control = class("guildMessageControl" , require("like_oo.oo_controlBase"));

function guild_message_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_message_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_message_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
		
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3) then
		self.m_view:updateMessage()
	elseif(msg == 4) then
		self:openView("guild_message_edit" , self.m_data:getGuildData().notices);
	end
end




return guild_message_control;