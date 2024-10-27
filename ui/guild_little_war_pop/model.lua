require "shared.extern"

local guild_little_war_pop_model = class("guildLittleWarPopModel",require("like_oo.oo_dataBase"));

guild_little_war_pop_model.m_camp = 1;

function guild_little_war_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_little_war_pop_model:onEnter(  )
	-- body
	local uid = game_data:getUserStatusDataByKey("uid");
	local selfD = self.m_params.data.player_status[uid];
	self.m_camp = selfD.l_or_r;
end

function guild_little_war_pop_model:getLeft(  )
	-- body
	if(self.m_camp == 1)then
		return "guild_sf_zhendi.png";
	else
		return "guild_sf_zhendi2.png";
	end
end

function guild_little_war_pop_model:getRight(  )
	-- body
	if(self.m_camp == 1)then
		return "guild_sf_zhendi2.png";
	else
		return "guild_sf_zhendi.png";
	end
end

function guild_little_war_pop_model:getPlayerArray(  )
	-- body
	return self.m_params.data.player_status;
end




return guild_little_war_pop_model;