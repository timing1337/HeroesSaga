require "shared.extern"

local guild_other_view = class("guildOtherView",require("like_oo.oo_popBase"));

guild_other_view.m_ccb = nil;

-- 头像节点
guild_other_view.m_head_icon_node = nil;
-- 头衔节点
guild_other_view.m_title = nil;
-- 血条节点
guild_other_view.m_hpBg = nil;
-- 玩家名字
guild_other_view.m_pname = nil;
-- 玩家战斗力
guild_other_view.m_power = nil;

--场景创建函数
function guild_other_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_other.ccbi");

	self.m_head_icon_node = tolua.cast(self.m_ccb:objectForName("m_head_icon_node"),"CCNode");
	self.m_title = tolua.cast(self.m_ccb:objectForName("m_title"),"CCNode");
	self.m_hpBg = tolua.cast(self.m_ccb:objectForName("m_hpBg"),"CCSprite");
	self.m_pname = tolua.cast(self.m_ccb:objectForName("m_pname"),"CCLabelTTF");
	self.m_power = tolua.cast(self.m_ccb:objectForName("m_power"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_other_view:onEnter(  )
	-- body
end

function guild_other_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_other_view;