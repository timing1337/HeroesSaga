require "shared.extern"

local guild_tou3_view = class("guildTou3View",require("like_oo.oo_popBase"));

guild_tou3_view.m_ccb = nil;

-- 全部战旗数
guild_tou3_view.m_allFlag = nil;
-- 全军提升能力1
guild_tou3_view.m_powerUp1 = nil;
-- 全军提升能力2
guild_tou3_view.m_powerUp2 = nil;
-- 输入框代替节点
guild_tou3_view.m_editNode = nil;
-- 已捐献战旗数
guild_tou3_view.m_flagCount = nil;
-- 要捐献战旗数
guild_tou3_view.m_editFlagCount = 0;
-- 
guild_tou3_view.m_editBox = nil;

--场景创建函数
function guild_tou3_view:onCreate(  )
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
		self:updataMsg(3,self.m_editFlagCount);
	end

	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_tou3.ccbi");

	self.m_allFlag = tolua.cast(self.m_ccb:objectForName("m_allFlag"),"CCLabelTTF");
	self.m_powerUp1 = tolua.cast(self.m_ccb:objectForName("m_powerUp1"),"CCLabelTTF");
	self.m_powerUp2 = tolua.cast(self.m_ccb:objectForName("m_powerUp2"),"CCLabelTTF");
	self.m_editNode = tolua.cast(self.m_ccb:objectForName("m_editNode"),"CCNode");
	self.m_flagCount = tolua.cast(self.m_ccb:objectForName("m_flagCount"),"CCLabelTTF");

	self.m_rootView:addChild(self.m_ccb);

	local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_editFlagCount = tonumber(edit:getText());
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_editNode:getContentSize(),placeHolder=""});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_editNode:addChild(self.m_editBox);
end

function guild_tou3_view:onEnter(  )
	-- body
end

function guild_tou3_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end


return guild_tou3_view;



