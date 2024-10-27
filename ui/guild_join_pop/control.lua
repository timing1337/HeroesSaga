require "shared.extern"

local guild_join_pop_control = class("guildJoinPopControl",require("like_oo.oo_controlBase"));

function guild_join_pop_control:onHandle( msg , data )
	-- body
	if(msg == 1)then
		print( data );
	elseif( msg == 2 )then   -- 查看公会详情
		local tempGuildId = self.m_data.m_params.id;
		self:openView("guild_detail_pop",{guild_id = tempGuildId});
		self:closeView();
	elseif( msg == 3 )then   -- 申请加入公会
		local tempGuildId = self.m_data.m_params.id;
		local function back( data )
			self:closeView();
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_join"),{guild_id = tempGuildId},back);
	end
end



return guild_join_pop_control;