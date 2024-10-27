require "shared.extern"

local guild_join_pop_view = class("guldJoinPopView",require("like_oo.oo_popBase"));

guild_join_pop_view.m_ccb = nil;

-- function guild_join_pop_view:create(  )
-- 	-- body
-- 	local pop = self.popBase.create( self );
	
-- 	return pop;
-- end

function guild_join_pop_view:onCreate(  )
	-- body
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag==1)then  -- 查看公会详情按钮
        	self:updataMsg( 2 )
        elseif(btnTag==2)then    -- 公会申请加入按钮
        	self:updataMsg( 3 );
        end
	end
	cclog("------------ guild_join_pop_view:create");
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/pop_new_guild_pop.ccbi");

	self.m_rootView:addChild(self.m_ccb);
	self:canClose(true);
end


return guild_join_pop_view;