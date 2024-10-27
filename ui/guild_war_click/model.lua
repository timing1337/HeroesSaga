require "shared.extern"

local guild_war_click_model = class("guildWarClickModel",require("like_oo.oo_dataBase"));

function guild_war_click_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_war_click_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
end

function guild_war_click_model:getPos(  )
	-- body
	return self.m_data.m_x , self.m_data.m_y;
end

function guild_war_click_model:getLogicPos(  )
	-- body
	return self.m_data.m_lx , self.m_data.m_ly;
end

function guild_war_click_model:getFlag(  )
	-- body
	return self.m_data.m_flag;
end

return guild_war_click_model;