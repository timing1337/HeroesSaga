require "shared.extern"

local guild_tou1_model = class("guildTou1Model",require("like_oo.oo_dataBase"));

function guild_tou1_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_tou1_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
	cclog("self.m_data == " .. json.encode(self.m_data))
end

function guild_tou1_model:getParams(  )
	return self.m_params;
end
function guild_tou1_model:getUIData()
	return self.m_params.list_data.data
end

return guild_tou1_model;