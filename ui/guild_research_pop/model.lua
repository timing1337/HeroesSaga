require "shared.extern"

local guild_research_pop_model = class("guildResearchPopModel",require("like_oo.oo_dataBase"));

guild_research_pop_model.m_lvname = {
	"guild",
	"shop",
	"",
	"gvg_player",
	"gvg_monster",
	"gvg_home",
	"map",
	"boss"
}

function guild_research_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_research_pop_model:onEnter(  )
	-- body
	self.m_data = self.m_params;
	cclog("self.m_data == " .. json.encode(self.m_data))
end

function guild_research_pop_model:getLvWithIndex( index )
	-- body
	local tempLv = self.m_data.level[self.m_lvname[index]];
	if(tempLv == nil)then
		tempLv = 0;
	end
	return tempLv;
end
--[[
	获得科技开启的配置
]]
function guild_research_pop_model:getTechOpenCfg()
	local Cfg = self:getNativeData("guild_tech");
	return Cfg
end
function guild_research_pop_model:getMoney(  )
	-- body
	return self.m_data.goods;
end
function guild_research_pop_model:getGuildData(  )
	return self.m_data.guild_lv;
end
function guild_research_pop_model:canLevelup(  )
	-- body
	local tempUid = game_data:getUserStatusDataByKey("uid");
	if(tempUid == self.m_data.owner)then
		return true;
	end
	for k,v in pairs(self.m_data.vp) do
		if(v == tempUid)then
			return true;
		end
	end
	return false;
end


return guild_research_pop_model;