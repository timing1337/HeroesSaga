require "shared.extern"

local guild_search_pop_view = class("guildSearchPopView",require("like_oo.oo_popBase"));

guild_search_pop_view.m_ccb = nil;
guild_search_pop_view.m_editBox = nil;
guild_search_pop_view.m_guildName = nil;

function guild_search_pop_view:create(  )
	local pop = self.popBase.create( self );

	self.m_ccb = luaCCBNode:create();
	pop:addChild(self.m_ccb);
	local function onBack( target,event )
		self:updataMsg( 2 ,nil,"this" );
	end
	local function onButtonClick( target,event )
		self:updataMsg( 3 , self.m_guildName , "this" );
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);

	self.m_ccb:openCCBFile("ccb/pop_new_guild_search.ccbi");
	local tempEditNode = tolua.cast(self.m_ccb:objectForName("m_editNode"),"CCNode");
	local btn_search = self.m_ccb:controlButtonForName("btn_search")
	game_util:setControlButtonTitleBMFont(btn_search)

	local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_guildName = edit:getText();
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = tempEditNode:getContentSize(),placeHolder=""});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    tempEditNode:addChild(self.m_editBox);

    local text1 = self.m_ccb:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text21)

    game_util:setCCControlButtonTitle(btn_search,string_helper.ccb.text22)
	return pop;
end

function guild_search_pop_view:onCommand( command , data )
	
end


return guild_search_pop_view;