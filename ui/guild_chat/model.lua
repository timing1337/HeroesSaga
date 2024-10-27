require "shared.extern"

local guild_chat_model = class("guildChatModel",require("like_oo.oo_dataBase"));

function guild_chat_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_chat_model:onEnter(  )
	-- body
end

function guild_chat_model:getGameId(  )
	-- body
	return 1;
end


return guild_chat_model;