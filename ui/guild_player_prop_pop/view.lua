require "shared.extern"

local guild_player_prop_pop_view = class("guildPlayerPropPopView",require("like_oo.oo_popBase"));

guild_player_prop_pop_view.m_ccb = nil;
guild_player_prop_pop_view.m_playerName = nil;

--场景创建函数
function guild_player_prop_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	
	self.m_ccb = luaCCBNode:create();
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- btnTag 1.查看详情 2.同意 3.拒绝
        self:updataMsg(btnTag+2);
	end
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_new_guild_proplist_pop.ccbi");
	self.m_playerName = tolua.cast(self.m_ccb:objectForName("m_playerName"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);
end

function guild_player_prop_pop_view:onEnter(  )
	-- body
	self:canClose(true);
end

function guild_player_prop_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_player_prop_pop_view;