require "shared.extern"

local guild_tou2_model = class("guildTou2Model",require("like_oo.oo_dataBase"));

function guild_tou2_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_tou2_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
	cclog("self.m_data.=" .. json.encode(self.m_data))
end

function guild_tou2_model:getListData(  )
	-- body
	return self.m_params.list_data;
end

function guild_tou2_model:getGameId(  )
	-- body
	return self.m_params.game_id;
end

function guild_tou2_model:getGuildList( index )
	-- body
	return self.m_params.list_data.data.rank.rank[index];
end
function guild_tou2_model:getUIData()
	return self.m_params.list_data.data
end
return guild_tou2_model;