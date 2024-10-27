require "shared.extern"

local guild_war_click_view = class("guildWarClickView",require("like_oo.oo_popBase"));

guild_war_click_view.m_ccb = nil;

guild_war_click_view.m_button = {};

--场景创建函数
function guild_war_click_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();

	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(3,btnTag);
	end
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/pop_guild_war_click.ccbi");

	for i=1,3 do
		self.m_button[i] = tolua.cast(self.m_ccb:objectForName("m_button" .. tostring(i)),"CCControlButton");
		self.m_button[i]:setVisible(false);
	end
	local x,y = self.m_control.m_data:getPos();
	self.m_ccb:setPosition(ccp(x,y));
	self.m_rootView:addChild(self.m_ccb);
end

function guild_war_click_view:onEnter(  )
	-- body
	self:canClose(true);
end

function guild_war_click_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

-- 显示按钮 1 攻击 2,移动 3.占领
function guild_war_click_view:showButton( id )
	-- body
	for i=1,3 do
		self.m_button[i]:setVisible(false);
	end
	cclog("---------- showButton " .. id);
	self.m_button[id]:setVisible(true);
end

return guild_war_click_view;