require "shared.extern"

local guild_detail_pop_model = class("guildDetailPopModel",require("like_oo.oo_dataBase"));


function guild_detail_pop_model:create( name , params)
	self.dataBase.create( self , name , params );
end

function guild_detail_pop_model:onCreate(  )
	self:getData( game_url.getUrlForKey("association_guild_detail"),self.m_params);
	
end

function guild_detail_pop_model:getPlayerCount(  )
	-- util.printf(self.m_data);
	return #self.m_data.data.guild.player;
end

function guild_detail_pop_model:getOwner(  )
	return self.m_data.data.guild.owner;
end

function guild_detail_pop_model:getVp(  )
	return self.m_data.data.guild.vp;
end

function guild_detail_pop_model:getPlayer( index )
	if(index<1 or index>self:getPlayerCount())then
		return nil;
	end
	local playerid = self.m_data.data.guild.player[index];
	local temp = self.m_data.data.player[playerid];
	return temp; 
end

return guild_detail_pop_model;