require "shared.extern"

local guild_world_scene_model = class("guildWorldSceneModel",require("like_oo.oo_dataBase"));

guild_world_scene_model.m_guildListData = nil;

function guild_world_scene_model:onCreate(  )
	-- body
	self:getData( game_url.getUrlForKey("association_game_list") );
	-- self:getData();
end

function guild_world_scene_model:onEnter(  )
	-- body
	
end

function guild_world_scene_model:getDataForId( id )
	-- body
	return self.m_data.data[tostring(id)];
end

function guild_world_scene_model:isOwner(  )
	-- body
	local tempUid = game_data:getUserStatusDataByKey("uid");
	local owner = self.m_params.player[tempUid].title;
	if( owner == "owner" )then
		return true;
	else
		return false;
	end
end

-- 获得公会捐献旗子列表
function guild_world_scene_model:getGuildFlagList( id )
	local function listCallBack( data )
		self.m_guildListData = data;
		cclog("self.m_guildListData == "  .. json.encode(self.m_guildListData))
		self.m_control:updataMsg(5,id);
	end
	self:getNetData(game_url.getUrlForKey("association_flag_rank"),{game_id=id},listCallBack);
end

function guild_world_scene_model:isFirst(  )
	if(self.m_guildListData.data.rank.self_rank>=0)then
		return false;
	else
		return true;
	end
	
end


return guild_world_scene_model;


