require "shared.extern"

local guild_research_level_up_model = class("guildResearchLevelUpModel",require("like_oo.oo_dataBase"));

function guild_research_level_up_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_research_level_up_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
end

function guild_research_level_up_model:getCurLv(  )
	return self.m_data.lv;
end

function guild_research_level_up_model:getNextLv(  )
	return self.m_data.lv+1
end

function guild_research_level_up_model:getCostCoin()
	local tempData = self:getNativeData("guild_GVGplayer");
	local curlv = tostring(self:getCurLv());
	cclog("tempData[curlv].cost == " .. tempData[curlv].cost)
	return tempData[curlv].cost
end

function guild_research_level_up_model:getCurDetail(  )
	local curlv = tostring(self:getCurLv());
	if(self.m_data.id == 1)then
		-- 公会等级
		local tempData = self:getNativeData("guild_level");
		return tempData[curlv].level_des;

	elseif(self.m_data.id == 2)then
		-- 公会商店
		local tempData = self:getNativeData("guild_shop");
		return tempData[curlv].level_des;
	elseif(self.m_data.id == 3)then
		-- 公会任务
		return nil;
	elseif(self.m_data.id == 4)then
		-- 玩家能力
		local tempData = self:getNativeData("guild_GVGplayer");
		return tempData[curlv].level_des;
	elseif(self.m_data.id == 5)then
		-- 野外怪物
		local tempData = self:getNativeData("guild_GVGmonster");
		return tempData[curlv].level_des;
	elseif(self.m_data.id == 6)then
		-- 主家血量
		local tempData = self:getNativeData("guild_GVGhome");
		return tempData[curlv].level_des;
	elseif(self.m_data.id == 7)then
		-- 中立地图
		local tempData = self:getNativeData("guild_middleplayer");
		return tempData[curlv].level_des;
	elseif(self.m_data.id == 8)then
		-- 世界boss
		local tempData = self:getNativeData("guild_bossplayer");
		return tempData[curlv].level_des;
	end

end

function guild_research_level_up_model:getNextDetail(  )
	-- body
	local curlv = tostring(self:getCurLv());
	if(self.m_data.id == 1)then
		-- 公会等级
		local tempData = self:getNativeData("guild_level");
		return tempData[curlv].next_des;

	elseif(self.m_data.id == 2)then
		-- 公会商店
		local tempData = self:getNativeData("guild_shop");
		return tempData[curlv].next_des;
	elseif(self.m_data.id == 3)then
		-- 公会任务
		return nil;
	elseif(self.m_data.id == 4)then
		-- 玩家能力
		local tempData = self:getNativeData("guild_GVGplayer");
		return tempData[curlv].next_des;
	elseif(self.m_data.id == 5)then
		-- 野外怪物
		local tempData = self:getNativeData("guild_GVGmonster");
		return tempData[curlv].next_des;
	elseif(self.m_data.id == 6)then
		-- 主家血量
		local tempData = self:getNativeData("guild_GVGhome");
		return tempData[curlv].next_des;
	elseif(self.m_data.id == 7)then
		-- 中立地图
		local tempData = self:getNativeData("guild_middleplayer");
		return tempData[curlv].next_des;
	elseif(self.m_data.id == 8)then
		-- 世界boss
		local tempData = self:getNativeData("guild_bossplayer");
		return tempData[curlv].next_des;
	end
end

function guild_research_level_up_model:getId(  )
	-- body
	return self.m_data.id;
end


return guild_research_level_up_model;