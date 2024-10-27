require "shared.extern"

local guild_Shop_model = class("guildShopModel",require("like_oo.oo_dataBase"));

function guild_Shop_model:create( name , params )
	-- body
	self.dataBase.create( self,name,params );
	self:getData(nil);
end

return guild_Shop_model;