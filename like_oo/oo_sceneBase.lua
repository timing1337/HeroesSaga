require "shared.extern"

-- if you want create a scene , 
local scene_base = class( "sceneBase" , require("like_oo.oo_viewBase") );

scene_base.m_type = 1;

function scene_base:create(  )
	-- body
	self.viewBase.create( self );
	self.m_rootView = CCScene:create();
	self:onCreate();
	return self.m_rootView;
end

function scene_base:destroy(  )
	-- body
	cclog("-------- destroy view " .. self.m_control.m_data:getName());
end

return scene_base;