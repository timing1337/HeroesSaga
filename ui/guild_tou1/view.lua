require "shared.extern"

local guild_tou1_view = class("guildTou1View",require("like_oo.oo_popBase"));

guild_tou1_view.m_ccb = nil;
-- 公会名字
guild_tou1_view.m_gname = nil;			
-- 大陆名字
guild_tou1_view.m_worldName = nil;
-- 大陆说明
guild_tou1_view.m_worldDetail = nil;
-- 大陆图片位置节点
guild_tou1_view.m_worldNode = nil;
-- 占领时间
guild_tou1_view.m_firstTime = nil;
-- 占领时长
guild_tou1_view.m_timeLong = nil;
-- 挑战者加成比例
guild_tou1_view.m_leftParent = nil;
-- 占领者加成比例
guild_tou1_view.m_rightParent = nil;


--场景创建函数
function guild_tou1_view:onCreate(  )
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
		cclog("------------ tou1 onButtonClick ");
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if(btnTag == 1)then
        	-- 捐献按钮
        	self:updataMsg( 3 );
        elseif(btnTag == 2)then
        	-- 奖励详情
        elseif(btnTag == 3)then
        	-- 历史查看
        end
	end
	self.m_ccb:registerFunctionWithFuncName( "onBack",onBack );
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/pop_guild_tou1.ccbi");

	self.m_gname = tolua.cast(self.m_ccb:objectForName("m_gname"),"CCLabelTTF");
	self.m_worldName = tolua.cast(self.m_ccb:objectForName("m_worldName"),"CCLabelTTF");
	self.m_worldDetail = tolua.cast(self.m_ccb:objectForName("m_worldDetail"),"CCLabelTTF");
	self.m_worldNode = tolua.cast(self.m_ccb:objectForName("m_worldNode"),"CCNode");
	self.m_firstTime = tolua.cast(self.m_ccb:objectForName("m_firstTime"),"CCLabelTTF");
	self.m_timeLong = tolua.cast(self.m_ccb:objectForName("m_timeLong"),"CCLabelTTF");
	self.m_leftParent = tolua.cast(self.m_ccb:objectForName("m_leftParent"),"CCLabelTTF");
	self.m_rightParent = tolua.cast(self.m_ccb:objectForName("m_rightParent"),"CCLabelTTF");

	local uiData = self.m_control.m_data:getUIData()
	local ownerName = uiData.owner
	if ownerName == nil or ownerName == "" then
		self.m_gname:setString("none")
	else 
		self.m_gname:setString(tostring(ownerName))
	end

	self.m_rootView:addChild(self.m_ccb);
end

function guild_tou1_view:onEnter(  )
	-- body
end

function guild_tou1_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_tou1_view;