require "shared.extern"

local guild_player_prop_model = class("guildPlayerPropModel",require("like_oo.oo_dataBase"));

function guild_player_prop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_player_prop_model:onEnter(  )
	-- body
	self.m_data = self.m_params.data;
end

function guild_player_prop_model:getPlayerCount(  )
	-- body
	return #self.m_data.guild.waiter;
end



function guild_player_prop_model:getPlayer( index )
	-- body
	return self.m_data.guild.waiter[index];
end

return guild_player_prop_model;