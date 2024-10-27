require "shared.extern"

local guild_warf_pop_model = class("guildWarfPopModel",require("like_oo.oo_dataBase"));

function guild_warf_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_warf_pop_model:onEnter(  )
	-- body
end


return guild_warf_pop_model;