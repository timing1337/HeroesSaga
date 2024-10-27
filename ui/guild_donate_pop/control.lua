require "shared.extern"

local guild_donate_pop_control = class("guildDonatePopControl",require("like_oo.oo_controlBase"));

function guild_donate_pop_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_donate_pop_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	
	-- 添加自己代码
end

function guild_donate_pop_control:onHandle( msg , data )
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	local function onNetCallBack( gameData )
		self.m_data.m_data = gameData.data.user_data;
		local addScore = self.m_data:getScore() - self.m_view.lastScore
		self.m_view:setScore(self.m_data:getScore());
		--清空数字，显示奖励
		self.m_view:refreshLabel()
		game_util:addMoveTips({text = string_helper.guild_donate_pop.donateAdd .. addScore .."!"});
		self.m_view.lastScore = self.m_data:getScore()
		self.m_view:setEdit1("")
		self.m_view:setEdit2("")
		--传消息更新
		self:updataMsg( 1234 , gameData.data , "parent" )		
	end
	-- print("data== " .. json.encode(data));
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();
	elseif(msg == 3)then		-- 选择食物
		self.m_data:setDonateFlag("food");
		self.m_view:setBoard("food");
		self.m_view:refreshLabel()
	elseif(msg == 4)then		-- 选择金属
		self.m_data:setDonateFlag("metal");
		self.m_view:setBoard("metal");
		self.m_view:refreshLabel()
	elseif(msg == 5)then		-- 选择能源
		self.m_data:setDonateFlag("energy");
		self.m_view:setBoard("energy");
		self.m_view:refreshLabel()
	elseif(msg == 6)then		-- 最大资源
		self.m_view:setEdit1(tostring(self.m_data:getMaxGoods()));
	elseif(msg == 7)then		-- 资源捐献
		local tempParams = {flag = self.m_data:getDonateFlag(),amount = data.goods};
		cclog("---------------------------- ");
		util.printf(tempParams);
		cclog("---------------------------- ");
		if tonumber(data.goods) > 0 then
			self.m_data:getNetData(game_url.getUrlForKey("association_dedicate"),tempParams,onNetCallBack);
		end
	elseif(msg == 8)then		-- 最大战旗
		cclog("------ " .. tostring(self.m_data:getMaxFlag()));
		self.m_view:setEdit2(self.m_data:getMaxFlag());
	elseif(msg == 9)then		-- 战旗捐献
		if tonumber(data.war_flag) > 0 then
			self.m_data:getNetData(game_url.getUrlForKey("association_dedicate"),{flag = "war_flag",amount = data.war_flag},onNetCallBack);
		else
			-- game_util:addMoveTips({text = ""})
		end
	end
end

return guild_donate_pop_control;





