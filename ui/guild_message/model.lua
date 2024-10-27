require "shared.extern"

local guild_message_model = class("guildMessageModel",require("like_oo.oo_dataBase"));

function guild_message_model:onCreate(  )
	self:getData(  );
	-- self:getData( game_url.getUrlForKey("association_guild_detail"),);
end

function guild_message_model:onEnter()
	self.m_data = self.m_params;

	-- cclog("message == " .. json.encode(self.m_data))
end

function guild_message_model:getGuildData()
	return self.m_data
end

return guild_message_model;