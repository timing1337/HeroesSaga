require "shared.extern"

local guild_self_control = class("guildSelfControl" , require("like_oo.oo_controlBase"));

function guild_self_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_self_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_self_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	end
end




return guild_self_control;