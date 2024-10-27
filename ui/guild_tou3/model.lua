require "shared.extern"

local guild_tou3_model = class("guildTou3Model",require("like_oo.oo_dataBase"));

function guild_tou3_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_tou3_model:onEnter(  )
	-- body
end

function guild_tou3_model:getGameId(  )
	-- body
	cclog(" --------------- game_id " .. tostring(self.m_params.game_id));
	return self.m_params.game_id;
end


return guild_tou3_model;