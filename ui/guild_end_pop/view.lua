require "shared.extern"

local guild_end_pop_view = class("guildEndPopView",require("like_oo.oo_popBase"));

guild_end_pop_view.m_ccb = nil;
guild_end_pop_view.m_bgNode = nil;

--场景创建函数
function guild_end_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	self.m_ccb:openCCBFile("ccb/pop_guild_battle_end.ccbi");
	self.m_bgNode = tolua.cast(self.m_ccb:objectForName("m_bgNode"),"CCNode");
	local spritebg = CCSprite:create("guild_test_end.png");
	self.m_bgNode:addChild(spritebg);
end

function guild_end_pop_view:onEnter(  )
	-- body
	self:canClose(true);
end

function guild_end_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_end_pop_view;