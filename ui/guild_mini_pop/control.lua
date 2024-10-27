require "shared.extern"

local guild_mini_pop_control = class("guildMiniPopControl",require("like_oo.oo_controlBase"));

function guild_mini_pop_control:onCreate(  )
	-- body
end

function guild_mini_pop_control:onEnter(  )
	-- body
end

function guild_mini_pop_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self.m_view:setPos(data);
	elseif(msg == 3)then
		self:closeView();
	end
end

return guild_mini_pop_control;