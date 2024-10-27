require "shared.extern"

local guild_chat_view = class("guildChatView",require("like_oo.oo_popBase"));

guild_chat_view.m_ccb = nil;

--场景创建函数
function guild_chat_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onChatButtonClick( target,event )
		-- body
		cclog("---------- onChatButtonClick ");
		self:updataMsg(3);
	end
	self.m_ccb:registerFunctionWithFuncName("onChatButtonClick",onChatButtonClick);
	
	self.m_ccb:openCCBFile("ccb/pop_guild_chat_button.ccbi");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_chat_view:onEnter(  )
	-- body
	self:consumeTouch(false);
end

function guild_chat_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;

end

return guild_chat_view;