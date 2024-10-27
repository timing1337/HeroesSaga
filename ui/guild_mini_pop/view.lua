require "shared.extern"

local guild_mini_pop_view = class("guildMiniPopView",require("like_oo.oo_popBase"));

guild_mini_pop_view.m_ccb = nil;
guild_mini_pop_view.m_glayer = nil;
guild_mini_pop_view.m_glv = nil;
guild_mini_pop_view.m_gname = nil;
guild_mini_pop_view.m_gpost = nil;
guild_mini_pop_view.m_gplayerCount = nil;


function guild_mini_pop_view:onCreate(  )
	-- body
	cclog("---------------- guild_mini_pop_view:onCreate");
	self.m_ccb = luaCCBNode:create();
	self.m_ccb:openCCBFile("ccb/pop_new_guild_mini.ccbi");
	self.m_rootView:addChild(self.m_ccb);
	self.m_glayer = tolua.cast(self.m_ccb:objectForName("m_glayer"),"CCSprite");
	self.m_glv = tolua.cast(self.m_ccb:objectForName("m_glv"),"CCLabelTTF");
	self.m_gname = tolua.cast(self.m_ccb:objectForName("m_gname"),"CCLabelTTF");
	self.m_gpost = tolua.cast(self.m_ccb:objectForName("m_gpost"),"CCLabelTTF");
	self.m_gplayerCount = tolua.cast(self.m_ccb:objectForName("m_gplayerCount"),"CCLabelTTF");

	self.m_glv:setString(tostring(self.m_control.m_data:getGuildLv()));
	self.m_gname:setString(self.m_control.m_data:getGuildName());
	self.m_gpost:setString(tostring(self.m_control.m_data:getGuildPost()));
	self.m_gplayerCount:setString(tostring(self.m_control.m_data:getPlayerCount()));
	self.m_glayer:setPosition(self.m_control.m_data:getMiniPos());
end


function guild_mini_pop_view:onEnter(  )
	-- body
	self:consumeTouch(false);
	-- self:updataMsg(5,nil,"guild_detail_pop");
end

function guild_mini_pop_view:setPos( pos )
	-- body
	print(type(pos));
	self.m_glayer:setPosition(pos.x,pos.y);
end

return guild_mini_pop_view;