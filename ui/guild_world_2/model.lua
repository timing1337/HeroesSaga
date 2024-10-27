require "shared.extern"

local guild_world_2_model = class("guildWorld2Model",require("like_oo.oo_dataBase"));

function guild_world_2_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_world_2_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
end

function guild_world_2_model:getPos(  )
	-- body
	return self.m_data.x,self.m_data.y;
end

function guild_world_2_model:getResiTime(  )
	-- body
	return math.floor(self.m_data.data.battle_start_time - self.m_data.data.server_time);
end


return guild_world_2_model;