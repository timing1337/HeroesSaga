require "shared.extern"

local guild_message_edit_model = class("guildMessageEditModel",require("like_oo.oo_dataBase"));

function guild_message_edit_model:onCreate(  )
	self:getData(  );
	-- self:getData( game_url.getUrlForKey("association_guild_detail"),);
end

function guild_message_edit_model:onEnter(  )
	self.m_data = self.m_params;

	-- cclog("message == " .. json.encode(self.m_data))
end

function guild_message_edit_model:getGuildData()
	return self.m_data
end
function guild_message_edit_model:setNewNotice(notice)
	self.m_data.data.guild_notice = notice
end
function guild_message_edit_model:getNotice( ... )
	return self.m_data.data.guild_notice
end
return guild_message_edit_model;