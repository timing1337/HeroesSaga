require "shared.extern"

local guild_create_ok_model = class("guildCreateOkModel",require("ui.guild.model"));

function guild_create_ok_model:create( name , params )
	-- body
	self.dataBase.create( self , name , params );
	local association_id = game_data:getUserStatusDataByKey("association_id");
 	-- if( association_id==0 )then
	-- 	self:getData( game_url.getUrlForKey("association_guild_all"),nil );
	-- else
		local guild_name = util.url_encode(self.m_params.name)
		self:getData( game_url.getUrlForKey("association_guild_create") , {name =  guild_name, icon = 1 } );
	-- end
end

return guild_create_ok_model;