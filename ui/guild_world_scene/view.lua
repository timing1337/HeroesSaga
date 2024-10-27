require "shared.extern"

local guild_world_scene_view = class("guildWorldSceneView",require("like_oo.oo_sceneBase"));

guild_world_scene_view.m_ccb = nil;

guild_world_scene_view.m_worldNode = {};
guild_world_scene_view.m_publicNode = nil;

--场景创建函数
function guild_world_scene_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
		self:updataMsg(3,btnTag);
	end
	local function onHelp( target,event )
		-- body
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:registerFunctionWithFuncName("onHelp",onHelp);
	self.m_ccb:openCCBFile("ccb/ui_guild_world.ccbi");

	self.m_publicNode = tolua.cast(self.m_ccb:objectForName("m_publicNode"),"CCNode");
	for i=1,4 do
		self.m_worldNode[i] = tolua.cast(self.m_ccb:objectForName("m_worldNode" .. tostring(i)),"CCNode");
	end

	self.m_rootView:addChild(self.m_ccb);

end

function guild_world_scene_view:onEnter(  )
	-- body
end

function guild_world_scene_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_world_scene_view:getWorldPos( index )
	-- body
	local sz = CCDirector:sharedDirector():getWinSize();
	local px = sz.width/2;
	local py = sz.height/2;
	local x,y = self.m_worldNode[index]:getPosition();
	return px+x,py+y;
end

return guild_world_scene_view;