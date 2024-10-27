require "shared.extern"

local guild_player_list_option_view = class("guildPlayerListOptionView",require("like_oo.oo_popBase"));

guild_player_list_option_view.m_ccb = nil;
guild_player_list_option_view.m_playerName = nil;

guild_player_list_option_view.uid = nil;

--场景创建函数
function guild_player_list_option_view:onCreate(  )
	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2);
        -- btnTag 1.查看详情 2.升职 3.降职 4.踢出公会 5.转交会长	    6.会长解散公会  7.会员退出公会
	end
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	local tempTitle = self.m_control.m_data:getTitle();
	local playerUid = self.m_control.m_data:getUid()
	local myUid = game_data:getUserStatusDataByKey("uid")	
	if(self.m_control.m_data:getMineTitle() == "owner")then
		if(tempTitle == "vp")then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop2.ccbi");
		elseif(tempTitle == "owner")then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop5.ccbi");
		else
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop3.ccbi");
		end
	else
		if playerUid == myUid then
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop6.ccbi");
		else
			self.m_ccb:openCCBFile("ccb/pop_new_guild_playerlist_pop4.ccbi");
		end
	end

	self.m_playerName = tolua.cast(self.m_ccb:objectForName("m_playerName"),"CCLabelTTF");
	self.m_playerName:setString(self.m_control.m_data:getPlayerName());

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_list_option_view:onEnter(  )
	self:canClose(true);
end

function guild_player_list_option_view:onCommand( command , data )
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_player_list_option_view;