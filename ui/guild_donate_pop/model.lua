require "shared.extern"


local guild_donate_pop_model = class("guildDonatePopModel",require("like_oo.oo_dataBase"));

guild_donate_pop_model.m_donate_flag = "food";


function guild_donate_pop_model:onCreate()
	-- self:getData( game_url.getUrlForKey("association_shop") );
	self:getData();
	-- cclog("self.m_data == " .. json.encode(self.m_data))
end

function guild_donate_pop_model:onEnter(  )
	self.m_data = self.m_params;
	util.printf(self.m_data);
end

function guild_donate_pop_model:setDonateFlag( flag )
	self.m_donate_flag = flag;
end

function guild_donate_pop_model:getDonateFlag(  )
	return self.m_donate_flag;
end

function guild_donate_pop_model:getScore(  )
	return self.m_data.dedication;
end

function guild_donate_pop_model:getMaxGoods(  )
	local tempMax = self.m_data.goods_limit - self.m_data.goods_log;
	local tempGoods = 0;
	if(self.m_donate_flag == "food")then
		tempGoods = game_data:getUserStatusDataByKey("food");
	elseif(self.m_donate_flag == "energy")then
		tempGoods = game_data:getUserStatusDataByKey("energy");
	elseif(self.m_donate_flag == "metal")then
		tempGoods = game_data:getUserStatusDataByKey("metal");
	else
		tempGoods = game_data:getUserStatusDataByKey("food");
	end

	tempMax = math.min(tempMax,tempGoods);

	return tempMax;
end

function guild_donate_pop_model:getMaxFlag(  )
	-- cclog("self.m_data == " .. json.encode(self.m_data))
	-- cclog("tempMax== " .. tempMax .. "self.m_data.war_flag == " .. self.m_data.war_flag[1])
	local tempMax = self.m_data.war_flag_limit-self.m_data.war_flag_log;
	tempMax = math.min(tempMax,self.m_data.war_flag);
	return tempMax;
end

function guild_donate_pop_model:getMaxShowFlag(  )
	local tempMax = self.m_data.war_flag_limit-self.m_data.war_flag_log;
	return tempMax
end

function guild_donate_pop_model:getMyFlagCount()
	return self.m_data.war_flag
end

return guild_donate_pop_model;