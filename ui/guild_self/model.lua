require "shared.extern"

local guild_self_model = class("guildSelfMode",require("like_oo.oo_dataBase"));

function guild_self_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_self_model:onEnter(  )
	-- body
end


return guild_self_model;