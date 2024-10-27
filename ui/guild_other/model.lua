require "shared.extern"

local guild_other_model = class("guildOtherModel",require("like_oo.oo_dataBase"));

function guild_other_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_other_model:onEnter(  )
	-- body
end


return guild_other_model;