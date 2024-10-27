require "shared.extern"

local guild_little_war_pop_control = class("guildLittleWarPopControl" , require("like_oo.oo_controlBase"));

function guild_little_war_pop_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_little_war_pop_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
	local playerArray = self.m_data:getPlayerArray();
	local camp = "s";
	local uid = game_data:getUserStatusDataByKey("uid");
	local player_status = self.m_data:getPlayerArray();
	for k,v in pairs(player_status) do
		if(v.l_or_r == self.m_data.m_camp)then
			if(k == uid)then
				camp = 's';
			else
				camp = 'f';
			end
		else
			camp = "o";
		end
		self.m_view:createPlayer(k,camp,v.x,v.y);
	end
	self.m_view:smallOrBig(true);
end

function guild_little_war_pop_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then
		-- move
		self.m_view:moveTo(data.uid,data.x,data.y);
	elseif(msg == 4)then
		-- death
		self.m_view:death(data.uid);
	elseif(msg == 5)then
		-- birth
		self.m_view:birth(data.uid,data.x,data.y);
	elseif(msg == 10)then
		-- 迷你地图变小
		self.m_view:smallOrBig(true);
		self.m_view:setRoundNum(data);		
	elseif(msg == 11)then
		-- 迷你地图变大
		self.m_view:smallOrBig(false);
	end
end




return guild_little_war_pop_control;