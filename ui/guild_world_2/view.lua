require "shared.extern"

local guild_world_2_view = class("guildWorld2View",require("like_oo.oo_popBase"));

guild_world_2_view.m_ccb = nil;


-- 公会挑战等待倒计时
guild_world_2_view.m_time = nil;

--场景创建函数
function guild_world_2_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:openCCBFile("ccb/pop_guild_world_2.ccbi");

	self.m_time = tolua.cast(self.m_ccb:objectForName("m_time"),"CCLabelTTF");

	local tempTime = self.m_control.m_data:getResiTime();
	local tempDay = math.floor(tempTime/60/60/24);
	if(tempDay>0)then
		self.m_time:setString(tostring(tempDay) .. "天后");
	else
		local tempHour = math.floor(tempTime/60/60);
		if(tempHour>0)then
			self.m_time:setString(tostring(tempHour) .. "小时后");
		else
			self.m_time:setString("现在");
		end
	end
	
	self.m_rootView:addChild(self.m_ccb);
	self:consumeTouch(false);
	self.m_ccb:setPosition(ccp(self.m_control.m_data:getPos()));
end

function guild_world_2_view:onEnter(  )
	-- body
end

function guild_world_2_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end



return guild_world_2_view;