require "shared.extern"

local guild_detail_pop_control = class("guildDetailPopControl",require("like_oo.oo_controlBase"));

function guild_detail_pop_control:onCreate(  )
	cclog("--------------- guild_mini_pop_control onCreate");
	
end

function guild_detail_pop_control:onEnter(  )
	local tx,ty = self.m_view.m_miniNode:getPosition();
	-- self:openView("guild_mini_pop",{data = self.m_data.m_data , x = tx , y = ty});
end

function guild_detail_pop_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then 		-- 关闭消息
		self:closeView();
		-- self:updataMsg(3,nil,"guild_mini_pop");
	elseif(msg == 3)then 		-- 加入当前公会
		local function back( data )
			self:closeView();
			self:updataMsg(3,nil,"guild_mini_pop");
			game_util:addMoveTips({text = string_helper.guild_detail_pop.applyTips})
		end
		self.m_data:getNetData(game_url.getUrlForKey("association_guild_join"),self.m_data.m_params,back);
	elseif(msg == 4)then 		-- 公会成员被点击消息
	elseif(msg == 5)then		-- 公会mini弹框创建完毕
		cclog("--------------- yock 公会mini弹框创建完毕");
		-- local tx,ty = self.m_view.m_miniNode:getPosition();
		-- self:updataMsg(2,{x = tx,y = ty},"guild_mini_pop");
	
	end
end

return guild_detail_pop_control;