require "shared.extern"

local guild_player_list_option_model = class("guildPlayerListOptionModel",require("like_oo.oo_dataBase"));

guild_player_list_option_model.m_me = nil;

function guild_player_list_option_model:onCreate(  )
	self:getData(  );
end

function guild_player_list_option_model:onEnter(  )
	cclog("---------------- guild_player_list_option_model ");
	util.printf(self.m_params);
	cclog("---------------- guild_player_list_option_model ");
	self.m_data = self.m_params.player;
	self.m_me = self.m_params.me;
end

function guild_player_list_option_model:getPlayerName(  )
	return self.m_data.name;
end

function guild_player_list_option_model:getTitle()
	return self.m_data.title;
end

function guild_player_list_option_model:getUid(  )
	return self.m_data.uid;
end

function guild_player_list_option_model:getMineTitle(  )
	return self.m_me.title;
end
--[[
	得到自己的信息
]]
function guild_player_list_option_model:getMyInfo()
	return self.m_me;
end
return guild_player_list_option_model;