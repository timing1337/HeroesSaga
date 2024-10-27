require "shared.extern"

local view_base = class( "viewBase",nil );

view_base.m_control = nil;
view_base.m_type = 1
view_base.m_rootView = nil;

--[[
	此方法重载后用来做view的创建
]]
function view_base:create(  )
	-- body
	return nil;
end
--[[
	使用方法，与参数性质同controlBase
]]
function view_base:updataMsg( msg , data , flag )
	-- body
	self.m_control:updataMsg( msg,data,flag );
end

--[[
	此方法是用来给自己view发命令用的
]]
function view_base:updataCommand( command , data )
	-- body
	self:onCommand(command,data);
end

function view_base:destroy(  )
	-- body
end

function view_base:getType(  )
	-- body
	return self.m_type;
end

function view_base:getRootView(  )
	-- body
	return self.m_rootView;
end


-- ======================= a stupid cut of line ===============================

--[[
	此方法是重载后用来接受消息的
]]
function view_base:onCommand( command , data )
	-- body
end

--[[
	页面调用create时调用
]]
function view_base:onCreate(  )
	-- body
	cclog("-------------- view onCreate " .. self.m_control.m_data:getName());
end

--[[
	页面进入后
]]
function view_base:onEnter(  )
	-- body
	cclog("-------------- view onEnter " .. self.m_control.m_data:getName());
end


return view_base;