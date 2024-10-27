require "shared.extern"

local guild_player_list_pop_model = class("guildPlayerListPopModel",require("like_oo.oo_dataBase"));

function guild_player_list_pop_model:onCreate(  )
	-- body
	self:getData(  );
end

function guild_player_list_pop_model:onEnter(  )
	-- body
	self.m_data = self.m_params.data;
	local function playerSort( a,b )
		-- body
		-- owner + 10000
		-- vp + 5000
		-- lv + lv*1
		-- online + (online*100)
		local dataA = self.m_data.player[a];
		local dataB = self.m_data.player[b];
		local tempA = dataA.level;
		local tempB = dataB.level;
		if(dataA.title == "owner")then
			tempA = tempA+10000;
		elseif(dataA.title == "vp")then
			tempA = tempA+5000;
		end
		if(dataB.title == "owner")then
			tempB = tempB+10000;
		elseif(dataB.title == "vp")then
			tempB = tempB+5000;
		end
		tempA = tempA+(dataA.online*100);
		tempB = tempB+(dataB.online*100);
		return tempA>tempB;
	end
	table.sort( self.m_data , playerSort );
end

function guild_player_list_pop_model:getPlayerCount(  )
	-- body
	return #self.m_data.guild.player;
end

function guild_player_list_pop_model:getPlayer( index )
	-- body
	local tempId = self.m_data.guild.player[index];
	return self.m_data.player[tempId];
end

function guild_player_list_pop_model:getPlayerWithUid( uid )
	-- body
	return self.m_data.player[uid];
end

function guild_player_list_pop_model:changeData( data )
	-- body
	self.m_params.data = data;
	self.m_data = data;
	local function playerSort( a,b )
		-- body
		-- owner + 10000
		-- vp + 5000
		-- lv + lv*1
		-- online + (online*100)
		local dataA = self.m_data.player[a];
		local dataB = self.m_data.player[b];
		local tempA = dataA.level;
		local tempB = dataB.level;
		if(dataA.title == "owner")then
			tempA = tempA+10000;
		elseif(dataA.title == "vp")then
			tempA = tempA+5000;
		end
		if(dataB.title == "owner")then
			tempB = tempB+10000;
		elseif(dataB.title == "vp")then
			tempB = tempB+5000;
		end
		tempA = tempA+(dataA.online*100);
		tempB = tempB+(dataB.online*100);
		return tempA>tempB;
	end
	table.sort( self.m_data , playerSort );
end




return guild_player_list_pop_model;