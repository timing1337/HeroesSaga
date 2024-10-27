require "shared.extern"
-- if you want create a pop window,you mast inheritance the oo_viewBase
local pop_base = class( "popBase" , require("like_oo.oo_viewBase") );
pop_base.m_type = 2;
pop_base.m_selfClose = false;

function pop_base:create(  )
	-- body
	self.viewBase.create( self );
	self.m_rootView = CCLayer:create();
	local function onTouch( eventType, x, y )
		-- body
		cclog("------------- eventType " .. eventType);
		if eventType == "began" then
            return true;    --intercept event
        elseif(eventType == "ended")then
        	if(self.m_selfClose)then
        		self.m_control:closeView();
        	end
        end
	end
	self.m_rootView:registerScriptTouchHandler(onTouch,false, 1 ,true);
	self.m_rootView:setTouchEnabled(true);
	self:onCreate();
	return self.m_rootView;
end

function pop_base:canClose( can )
	-- body
	self.m_selfClose = can;
end

function pop_base:consumeTouch( con )
	-- body
	self.m_rootView:setTouchEnabled(con);
end


function pop_base:destroy(  )
	-- body
	-- cclog("-------- destroy view " .. self.m_control.m_data:getName());
	if game_scene:getCurrentUiName() ~= "game_main_scene" then
		if self and self.m_rootView then
			self.m_rootView:removeFromParentAndCleanup(true);
		end
	end
end

return pop_base;