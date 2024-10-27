require "shared.extern"


local guild_model = class("guldModel",require("like_oo.oo_dataBase"));

function guild_model:create( name )
	-- body
	self.dataBase.create( self , name );
	local association_id = game_data:getUserStatusDataByKey("association_id");
 	-- if( association_id==0 )then
	-- 	self:getData( game_url.getUrlForKey("association_guild_all"),nil );
	-- else
		self:getData( game_url.getUrlForKey("association_guild_detail") , {guild_id=association_id} );
	-- end

end
function guild_model:onEnter()
	-- cclog("guild main data == " ..json.encode(self.m_data))
	-- print("guild main data == " ..json.encode(self.m_data))
end
function guild_model:getDonateData(  )
	-- body
	return self.m_data.data.user_data;
end
function guild_model:setMoney( money )
	self.m_data.data.user_data.dedication = money
end
function guild_model:getGuildData(  )
	-- body
	return self.m_data.data.guild;
end

function guild_model:getDataAll(  )
	-- body
	return self.m_data.data;
end
--[[
	公会公告
]]
function guild_model:getGuildMessage()
	return self.m_data.data.guild_notice;
end
--[[
	获得开启条件
]]
function guild_model:getOpenLevel()
	local tempData = self:getNativeData("guild_funtion");
	return tempData
end
function guild_model:getPrimitiveData(  )
	return self.m_data
end

return guild_model;