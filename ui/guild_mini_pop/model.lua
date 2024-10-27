require "shared.extern"

local guild_mini_pop_model = class("guildMiniPopModel",require("like_oo.oo_dataBase"));

function guild_mini_pop_model:onCreate(  )
	-- body
	self:getData();
end

function guild_mini_pop_model:onEnter(  )
	-- body
	cclog("---------------- guild_mini_pop_model:onEnter");
	if(self.m_data == nil)then
		self.m_data = self.m_params.data;
	end
end


function guild_mini_pop_model:getGuildLv(  )
	-- body
	return tonumber(self.m_data.data.guild.guild_lv);
end

function guild_mini_pop_model:getPlayerCount(  )
	-- body
	return #self.m_data.data.guild.player;
end

function guild_mini_pop_model:getGuildName(  )
	-- body
	return self.m_data.data.guild.name;
end

function guild_mini_pop_model:getGuildPost(  )
	-- body
	return self.m_data.data.guild.sort;
end

function guild_mini_pop_model:getMiniPos(  )
	-- body
	return self.m_params.x,self.m_params.y;
end

return guild_mini_pop_model;