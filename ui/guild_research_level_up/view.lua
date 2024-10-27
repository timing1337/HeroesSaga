require "shared.extern"

local guild_research_level_up_view = class("guildResearchLevelUpView",require("like_oo.oo_popBase"));

guild_research_level_up_view.m_ccb = nil;

guild_research_level_up_view.m_curLv = nil;
guild_research_level_up_view.m_nextLv = nil;
guild_research_level_up_view.m_curDetail = nil;
guild_research_level_up_view.m_nextDetail = nil;
guild_research_level_up_view.m_title = nil;
--消耗品
guild_research_level_up_view.costLabel = nil;

--场景创建函数
function guild_research_level_up_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/guild_text_res.plist");
	self.m_ccb = luaCCBNode:create();

	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		-- body
		-- 科技升级消息
		self:updataMsg(3);
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_research_pop.ccbi");

	self.m_curLv = tolua.cast(self.m_ccb:objectForName("m_curLv"),"CCLabelTTF");
	self.m_nextLv = tolua.cast(self.m_ccb:objectForName("m_nextLv"),"CCLabelTTF");
	self.m_curDetail = tolua.cast(self.m_ccb:objectForName("m_curDetail"),"CCLabelTTF");
	self.m_nextDetail = tolua.cast(self.m_ccb:objectForName("m_nextDetail"),"CCLabelTTF");
	self.m_title = tolua.cast(self.m_ccb:objectForName("m_title"),"CCNode");

	self.costLabel = tolua.cast(self.m_ccb:objectForName("m_cost_metal_label"),"CCLabelBMFont");

	local tempId = self.m_control.m_data:getId();
	local tempTitle = CCSprite:createWithSpriteFrameName("guild_text_" .. tostring(tempId) .. ".png" );
	self.m_title:addChild(tempTitle);

	self:resetData();

	local now_level = self.m_ccb:labelTTFForName("now_level")
	now_level:setString(string_helper.ccb.text11)

	local m_button = self.m_ccb:controlButtonForName("m_button")
	game_util:setCCControlButtonTitle(m_button,string_helper.ccb.text12)

	local next_level = self.m_ccb:labelTTFForName("next_level")
	next_level:setString(string_helper.ccb.text12add)
	self.m_rootView:addChild(self.m_ccb);
end

function guild_research_level_up_view:onEnter(  )
	-- body
end

function guild_research_level_up_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_research_level_up_view:resetData(  )
	-- body
	self.m_curLv:setString(tostring(self.m_control.m_data:getCurLv()));
	self.m_nextLv:setString(tostring(self.m_control.m_data:getNextLv()));
	local str = "";
	str = self.m_control.m_data:getCurDetail();
	if( str~=nil )then
		self.m_curDetail:setString(tostring(str));
	end
	str = self.m_control.m_data:getNextDetail();
	if( str~=nil )then
		self.m_nextDetail:setString(tostring(str));
	end
	self.costLabel:setString(tostring(self.m_control.m_data:getCostCoin()))
	cclog("getCostCoin =  "  .. self.m_control.m_data:getCostCoin())
end

return guild_research_level_up_view;