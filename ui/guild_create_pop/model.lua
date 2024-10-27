require "shared.extern"

local guild_create_pop_model = class("guildCreatePopModel",require("like_oo.oo_dataBase"));

function guild_create_pop_model:create( name )
	-- body
	self.dataBase.create( self,name );
	self:getData( nil );
end

return guild_create_pop_model;