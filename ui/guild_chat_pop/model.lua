require "shared.extern"

local guild_chat_pop_model = class("guildChatPopModel",require("like_oo.oo_dataBase"));

function guild_chat_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_chat_pop_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
end

function guild_chat_pop_model:getChatMsg(  )
	-- body
	return self.m_data;
end

function guild_chat_pop_model:changeData( data )
	-- body
	self.m_data = data;
end


return guild_chat_pop_model;