require "shared.extern"

local guild_world_1_model = class("guildWorld1Model",require("like_oo.oo_dataBase"));

function guild_world_1_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_world_1_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
end

function guild_world_1_model:getPos(  )
	-- body
	return self.m_data.x,self.m_data.y;
end


return guild_world_1_model;