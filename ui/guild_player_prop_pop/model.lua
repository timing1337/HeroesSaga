require "shared.extern"

local guild_player_prop_pop = class("guildPlayerPropPop",require("like_oo.oo_dataBase"));

function guild_player_prop_pop:onCreate(  )
	self:getData(  );
end

function guild_player_prop_pop:onEnter(  )
	self.m_data = self.m_params;
end

function guild_player_prop_pop:getUid(  )
	return self.m_data.uid;
end

return guild_player_prop_pop;