require "shared.extern"

local guild_world_1_view = class("guildWorld1View",require("like_oo.oo_popBase"));

guild_world_1_view.m_ccb = nil;

-- 公会名字
guild_world_1_view.m_gname = nil;

--场景创建函数
function guild_world_1_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_world_1.ccbi");
	
	self.m_gname = tolua.cast(self.m_ccb:objectForName("m_gname"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
	self:consumeTouch(false);
	self.m_ccb:setPosition(ccp(self.m_control.m_data:getPos()));
end

function guild_world_1_view:onEnter(  )
	-- body
end

function guild_world_1_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_world_1_view;