require "shared.extern"

local guild_shop_pop_model = class("guildShopPopModel",require("like_oo.oo_dataBase"));

function guild_shop_pop_model:onCreate(  )
	self:getData(game_url.getUrlForKey("association_shop"));
end

function guild_shop_pop_model:onEnter()
	-- cclog("self.m_data.data == " .. json.encode(self.m_data.data))
end

function guild_shop_pop_model:getItemsData( )
	local shopData = {}
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1
	for i,v in ipairs(self.m_data.data.shop) do
		if type(v) == "table" and v.shop_reward then
			if type(v.show_level) == "table" then
				local minLevel = v.show_level[1] or 0
				local maxLevel = v.show_level[2] or 1000
				-- cclog2(minLevel, "minLevel   ==    ")
				-- cclog2(maxLevel, "minLevel   ==    ")
				if playerLevel >= minLevel and playerLevel <= maxLevel then
					table.insert(shopData, v)
				else
					-- cclog2(v, "这个不到等级不显示   ==")
				end 
			else
				table.insert(shopData, v)
			end
		end
	end
	return shopData
end

function guild_shop_pop_model:getItemCount(  )
	local showData = self:getItemsData() or nil
	return #showData
end

function guild_shop_pop_model:getItem( index )
	local showData = self:getItemsData() or nil
	return showData[index];
end

function guild_shop_pop_model:showTimeLayer( index )
	local tempItem = self:getItem(index);
	if(tempItem.total_num == -1)then
		return false;
	end
	if( tonumber(tempItem.remain_amount) <= 0 ) then
		return true;
	else
		return false;
	end
end
function guild_shop_pop_model:getShopLevel()
	return self.m_data.data.shop_lv
end
function guild_shop_pop_model:getItemIcon( index )
	local tempItem = self:getItem(index);
	local reward = tempItem.shop_reward[1];
	local icon,name,count = game_util:getRewardByItemTable(reward);
	return icon,name,count;
end

function guild_shop_pop_model:getScore(  )
	return game_data:getUserStatusDataByKey("association_dedication");
end



return guild_shop_pop_model;