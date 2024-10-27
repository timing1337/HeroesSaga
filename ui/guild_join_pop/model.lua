require "shared.extern"

local guild_join_pop_model = class("guildJoinPopModel",require("like_oo.oo_dataBase"));

function guild_join_pop_model:create( name , params )
	-- body
	self.dataBase.create( self,name,params );
	self:getData(nil);
end

return guild_join_pop_model;