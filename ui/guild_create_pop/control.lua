require "shared.extern"

local guild_create_pop_control = class("guildCreatePopControl",require("like_oo.oo_controlBase"));

function guild_create_pop_control:create(  )
	-- body
	-- game_scene.m_propertyBar:runAnimations("enter_anim");
	self.controlBase.create( self );
end

function guild_create_pop_control:onHandle( msg , data )
	-- body
	if(msg == 1)then
		print( data );
	elseif( msg == 2 )then  	-- 关闭弹出框
		self:closeView();
	elseif( msg == 3 )then  	-- 发送创建消息
		self:openView("guild_create_ok",{ name = data });
	end
end


return guild_create_pop_control;