require "shared.extern"

local guild_search_pop_control = class("guildSearchPopControl",require("like_oo.oo_controlBase"));

function guild_search_pop_control:create(  )
	-- game_scene.m_propertyBar:runAnimations("enter_anim");
	self.controlBase.create( self );
end

function guild_search_pop_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif( msg == 2 )then  	-- 关闭弹出框
		self:closeView();
	elseif( msg == 3 )then  	-- 发送创建消息
		-- self:openView("guild_create_ok",{ name = data });

		--模糊匹配
		local enter_name = data
		local temp_table = self.m_data:getNewGuildData(enter_name)
		if #temp_table == 0 then
			game_util:addMoveTips({text = string_helper.guild_search_pop.notFound})
		else 
			self:updataMsg(6,temp_table,"parent");
			self:closeView()
		end
	end
end

return guild_search_pop_control;