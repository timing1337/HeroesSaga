require "shared.extern"

local guild_search_pop_model = class("guildSearchPopModel",require("like_oo.oo_dataBase"));

function guild_search_pop_model:onCreate()
	self:getData()
end

function guild_search_pop_model:onEnter(  )
	self.m_data = self.m_params;
	cclog("self.m_data == " .. json.encode(self.m_data))
end

function guild_search_pop_model:getGuildName()
	return self.m_data
end

function guild_search_pop_model:getNewGuildData(enter_name)
	local guild_table = self.m_data
	local tempTable = {}
	for i=1,#guild_table do
		local guild_name = string.lower(guild_table[i].name)

		if guild_name == string.lower(enter_name) then 
			--local testTable = {}
			--table.insert(enter_name);
			tempTable = self:sortGuildData(enter_name)
			break;
		else
			-- local char_length = util_utf8Length(enter_name)
			-- cclog("char_length == " .. char_length)
			-- for j=1,char_length do
			-- 	local char_index = string.sub(enter_name,j,1)
			-- 	cclog("char_index == " .. char_index)

			-- end
		end
	end
	return tempTable
end

function guild_search_pop_model:sortGuildData(enter_name)
	local tempTable = {}

	local guild_table = self.m_data
	-- for j=1,#test_table do
		-- local enter_name = test_table[i]
		
		for i=1,#guild_table do
			local guild_name = guild_table[i].name
			if guild_name == enter_name then 
				table.insert(tempTable,guild_table[i])
				-- break;
			end
		end
		for i=1,#guild_table do
			local guild_name = guild_table[i].name
			if guild_name ~= enter_name then
				table.insert(tempTable,guild_table[i])
			end
		end
	-- end
	return tempTable
end

return guild_search_pop_model;