require "shared.extern"

local guild_warf_pop_view = class("guildWarfPopView",require("like_oo.oo_popBase"));

guild_warf_pop_view.m_ccb = nil;

-- 玩家贴图节点
guild_warf_pop_view.m_playerNode = {};
-- 进入按钮
guild_warf_pop_view.m_enterButton = nil;
-- 公会名字
guild_warf_pop_view.m_leftGName = nil;
guild_warf_pop_view.m_rightGName = nil;
-- 公会加成百分比
guild_warf_pop_view.m_leftPercent = nil;
guild_warf_pop_view.m_rightPercent = nil;
-- 倒计时
guild_warf_pop_view.m_timer = nil;

--场景创建函数
function guild_warf_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		-- body
		self.updataMsg(2);
	end
	local function onComeTo( target,event )
		-- body
	end
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- 1 上周战斗
        -- 2 历史战况
        -- 3 奖励查询

	end
	local function onDetail( target,event )
		-- body
		local tagNode = tolua.cast(target,"CCNode");
		local btnTag = tagNode:getTag();
		-- 1 挑战者公会详情
		-- 2 防守者公会详情

	end
	self.m_ccb:registerFunctionWithFuncName( "onBack",onBack );
	self.m_ccb:registerFunctionWithFuncName( "onComeTo",onComeTo );
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:registerFunctionWithFuncName( "onDetail",onDetail );
	self.m_ccb:openCCBFile("ccb/pop_guild_warf.ccbi");

	for i=1,8 do
		self.m_playerNode[i] = tolua.cast(self.m_ccb:objectForName("m_playerNode" .. tostring(i)),"CCNode");
	end
	self.m_enterButton = tolua.cast( self.m_ccb:objectForName("m_enterButton"),"CCControlButton" );
	self.m_leftGName = self.m_ccb:labelTTFForName("m_leftGName");
	self.m_rightGName = self.m_ccb:labelTTFForName("m_rightGName");
	self.m_leftPercent = self.m_ccb:labelTTFForName("m_leftPercent");
	self.m_rightPercent = self.m_ccb:labelTTFForName("m_rightPercent");
	self.m_timer = self.m_ccb:labelTTFForName("m_timer");


	self.m_rootView:addChild(self.m_ccb);
end

function guild_warf_pop_view:onEnter(  )
	-- body
end

function guild_warf_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_warf_pop_view;