require "shared.extern"

local guild_end_pop_model = class("guildEndPopModel",require("like_oo.oo_dataBase"));

function guild_end_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_end_pop_model:onEnter(  )
	-- body
end


return guild_end_pop_model;