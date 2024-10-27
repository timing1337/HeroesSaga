require "shared.extern"

local guild_message_view = class("guildMessageView",require("like_oo.oo_popBase"));

guild_message_view.m_ccb = nil;
guild_message_view.m_msgText = nil;

--场景创建函数
function guild_message_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onBtnClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then 
			self:updataMsg(2);
        elseif btnTag == 2 then	
        	--公会成员
			-- local guild_data = self.m_control.m_data:getGuildData()
			-- local guild_player = guild_data.guild_player
			-- local myUid = game_data:getUserStatusDataByKey("uid");
			-- local user_post = guild_player[tostring(myUid)].title
			-- if user_post == "owner" or user_post == "vp" then

			-- end
        end
	end
	self.m_ccb:registerFunctionWithFuncName("onBtnClick",onBtnClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_message.ccbi");
	self.m_msgText = tolua.cast(self.m_ccb:objectForName("m_msgText"),"CCLabelTTF");
	local btn_edit = tolua.cast(self.m_ccb:objectForName("btn_edit"),"CCControlButton")
	local edit_node = tolua.cast(self.m_ccb:objectForName("edit_node"),"CCNode")
	local m_leave_message_btn = self.m_ccb:controlButtonForName("m_leave_message_btn")
	local m_ok_btn = self.m_ccb:controlButtonForName("m_ok_btn")
	btn_edit:setOpacity(0)

	--公告内容
	local notice_text = self.m_control.m_data:getGuildData().notices
	self.m_msgText:setString(tostring(notice_text))

	local text1 = self.m_ccb:labelTTFForName("text1")
	text1:setString(string_helper.ccb.text10)

	game_util:setCCControlButtonTitle(m_leave_message_btn,string_helper.ccb.text8)
	game_util:setCCControlButtonTitle(m_ok_btn,string_helper.ccb.text9)
	
	self.m_rootView:addChild(self.m_ccb);
end
function guild_message_view:editGuildMessage(message)
	local editView = CCTextFieldTTF:textFieldWithPlaceHolder(message,CCSizeMake(336,150),kCCTextAlignmentLeft,TYPE_FACE_TABLE.Arial_BoldMT,12)
	return editView
end
function guild_message_view:updateMessage(message)
	self.m_msgText:setString(tostring(message))
end
function guild_message_view:onEnter(  )
	
end

function guild_message_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_message_view;