require "shared.extern"

local guild_war_model = class("guildWarModel",require("like_oo.oo_dataBase"));

guild_war_model.m_camp = 1;
guild_war_model.m_build_config = nil;
guild_war_model.m_building_offset = require("building_offset");
guild_war_model.m_boss = {};

guild_war_model.m_playerRecord = {};

function guild_war_model:onCreate(  )
	-- body
	self:getData( game_url.getUrlForKey("association_join_war"), {game_id=self.m_params.game_id});
end

function guild_war_model:onEnter(  )
	-- body
	local uid = game_data:getUserStatusDataByKey("uid");
	local selfD = self.m_data.data.player_status[uid];
	self.m_camp = selfD.l_or_r;
	self.m_build_config = self:getNativeData("map_title_detail");

	for k,v in pairs(self.m_data.data.player_status) do
		v.x = v.x+1;
		v.y = v.y+1;
	end
end

-- 返回战场地图大小，宽高
function guild_war_model:getMaxSize(  )
	-- body
	return self.m_data.data.max_x,self.m_data.data.max_y;
end

-- 得到地图中单格数据
-- 1. 无意义
-- 2. 阵营 0中立，1攻方，2守方
-- 3. 玩家uid
-- 4. 建筑编号
function guild_war_model:getMapData( x,y )
	-- body
	return self.m_data.data.map[y][x];
end

function guild_war_model:isCampAsMe( x,y )
	-- body
	if(self.m_data.data.map[y][x][2] == self.m_camp)then
		return true;
	else
		return false;
	end
end

function guild_war_model:playerIsCampAsMe( uid )
	-- body
	local player = self.m_data.data.player_status[uid];
	if(player.l_or_r == self.m_camp)then
		return true;
	else
		return false;
	end
end

function guild_war_model:getPlayer( uid )
	-- body
	return self.m_data.data.player_status[uid];
end

-- 得到当前回合数
function guild_war_model:getRoundNum(  )
	-- body
	return self.m_data.data.round_num;
end
function guild_war_model:setRoundNum( value )
	-- body
	self.m_data.data.round_num = value;
end
-- 得到game_id
function guild_war_model:getGameId(  )
	-- body
	return self.m_params.game_id;
end

-- 得到当前操作周期结束时间 以秒为单位
function guild_war_model:getRoundEndTime(  )
	-- body
	return math.floor(self.m_data.data.end_time-self.m_data.data.server_time);
end

function guild_war_model:updataFromNet( netData )
	-- body
	self.m_data.data.end_time = netData.data.end_time;
	self.m_data.data.server_time = netData.data.server_time;
end

-- 修改基础数据
function guild_war_model:changedData( moveListItem )
	-- body
	local tempSelf = self:getPlayer(moveListItem.uid);
	local tempKick = nil;
	if(moveListItem.kicked ~= "" and moveListItem.kicked ~= "monster")then
		tempKick = self:getPlayer(moveListItem.kicked);
	end
	local tempSelfMap = self:getMapData(tempSelf.x,tempSelf.y);
	local tempWellMap = self:getMapData(moveListItem.x,moveListItem.y);

	-- 更新地图数据
	if(moveListItem.area_change == 1)then
		tempSelfMap[3] = "";
		tempWellMap[3] = moveListItem.uid;
		tempWellMap[2] = tempSelf.l_or_r;
	else
		tempSelfMap[3] = "";
		tempWellMap[3] = moveListItem.uid;
	end
	
	-- 更新玩家数据
	tempSelf.x = moveListItem.x;
	tempSelf.y = moveListItem.y;
	tempSelf.hp = moveListItem.attacker_hp;
	if(tempKick ~= nil)then
		tempKick.hp = moveListItem.defender_hp;
	elseif(string.find(moveListItem.kicked,"base",0))then
		self:changedBossHp(moveListItem.kicked,moveListItem.defender_hp);
	end


end

function guild_war_model:changedPlayerStatus( uid,playerStatus )
	-- body
	self.m_data.data.player_status[uid] = playerStatus;
end

function guild_war_model:changedAllPlayer( playerStatus )
	-- body
	self.m_data.data.player_status = playerStatus;
end

function guild_war_model:getBuildImgName( id )
	-- body
	cclog("------------------ " .. tostring(id));
	util.printf(id);
	if(tonumber(id)<0)then
		return nil;
	end
	local imgName = self.m_build_config[tostring(id)]["title_img"];
	local off = string.find(imgName,".png",0);
	shortName = string.sub(imgName,0,off-1);

	cclog("------------------ " .. tostring(id) .. " build image name " .. imgName);
	local offset = self.m_building_offset[shortName];
	if(offset == nil)then
		cclog("---------- not have offset " .. shortName);
		return imgName , 0 , 0;
	else
		cclog("----------" .. imgName .. "(" .. tostring(offset[1]) .. "," .. tostring(offset[2]) .. ")");
		return imgName , offset[1] , offset[2];
	end

	
end

function guild_war_model:changedBossHp( bossUid , hp)
	-- body
	self.m_boss[bossUid].m_hp = hp;
end

function guild_war_model:setBossData( id,x,y )
	-- body
	if(id == 10)then
		self.m_boss['base_1'] = {m_id=id,m_x=x,m_y=y,m_maxhp=self.m_data.data.left_base_hp_max,m_hp=self.m_data.data.left_base_hp};
	elseif(id == 20)then
		self.m_boss['base_2'] = {m_id=id,m_x=x,m_y=y,m_maxhp=self.m_data.data.right_base_hp_max,m_hp=self.m_data.data.right_base_hp};
	end
end

function guild_war_model:getBossData( uid )
	-- body
	return self.m_boss[uid];
end

function guild_war_model:bossIsCampAsMe( uid )
	-- body
	local temp = self.m_boss[uid].m_id/10;
	if(temp == self.m_camp)then
		return true;
	else
		return false;
	end
end




return guild_war_model;



