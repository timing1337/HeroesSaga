require "shared.extern"

local guild_message_edit_control = class("guildMessageEditControl" , require("like_oo.oo_controlBase"));

function guild_message_edit_control:onCreate(  )
	-- 初始化函数框架自动调用
	
end

function guild_message_edit_control:onEnter(  )
	-- 创建view结束后调用，用来
	self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_message_edit_control:onHandle( msg , data )
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 2)then
		-- print( data );
		if self.m_view.edit_flag == true then
			local function netCallBack( netdata )
				self.m_data:setNewNotice(self.m_view.notice_text)
				self:updataMsg( 1234 , self.m_data:getGuildData() , "guild" )
				game_util:addMoveTips({text = string_helper.guild_message.edit})
			end
			local urlMessage = util.url_encode(self.m_view.notice_text)
			self.m_data:getNetData(game_url.getUrlForKey("association_add_notice"),{notice=urlMessage},netCallBack,false,true);
		else 
			-- self:closeView();
			game_util:addMoveTips({text = string_helper.guild_message.inputWord})
		end
	elseif(msg == 1)then
		-- self:updataMsg(3, gameData.data , "parent" )
		-- if self.m_view.edit_flag == true then
		-- 	local function netCallBack( netdata )
		-- 		self.m_data:setNewNotice(self.m_view.notice_text)
		-- 		self:updataMsg( 1234 , self.m_data:getGuildData() , "guild" )
		-- 		self:closeView();
		-- 	end
		-- 	local urlMessage = util.url_encode(self.m_view.notice_text)
		-- 	self.m_data:getNetData(game_url.getUrlForKey("association_add_notice"),{notice=urlMessage},netCallBack,false,true);
		-- else 
			self:closeView();
		-- end
	end
end
return guild_message_edit_control;