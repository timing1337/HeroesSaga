require "shared.extern"

local guild_Shop_control = class("guildShopControl",require("like_oo.oo_controlBase"));

function guild_Shop_control:onHandle( msg , data )
	-- body
	if(msg == 1)then
		print( data );
	elseif( msg == 2 )then   -- 查看公会详情
		local tempGuildId = self.m_data.m_params.id;
		
	elseif( msg == 3 )then   -- 申请加入公会

	end
end

return guild_Shop_control;