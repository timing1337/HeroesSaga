require "shared.extern"

local guild_message_edit_view = class("guildMessageEditView",require("like_oo.oo_popBase"));

guild_message_edit_view.m_ccb = nil;
guild_message_edit_view.m_msgText = nil;

guild_message_edit_view.edit_flag = false;
guild_message_edit_view.notice_text = ""

--场景创建函数
function guild_message_edit_view:onCreate(  )
	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
			self:updataMsg(1);
        elseif btnTag == 2 then
        	self:updataMsg(2);
        end
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:openCCBFile("ccb/pop_guild_message_edit.ccbi");
	self.m_msgText = tolua.cast(self.m_ccb:objectForName("m_msgText"),"CCLabelTTF");
	local edit_node = tolua.cast(self.m_ccb:objectForName("edit_node"),"CCLayer")

	--公告内容
	-- cclog("self.m_control.m_data == " .. json.encode(self.m_control.m_data:getGuildData()))
	local guild_data = self.m_control.m_data:getGuildData()
	local notice_text = guild_data.data.guild_notice
	self.m_msgText:setString(tostring(notice_text))

	local guild_player = guild_data.data.player
	local myUid = game_data:getUserStatusDataByKey("uid");
	local user_post = guild_player[tostring(myUid)].title

	local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            -- self.m_guildName = edit:getText();
            self.edit_flag = true
            self.notice_text = edit:getText()
            self.m_msgText:setString(tostring(edit:getText()))
        end
    end

	if user_post == "owner" or user_post == "vp" then
		local editSize = edit_node:getContentSize()
		-- textFieldTTF = CCTextFieldTTF:textFieldWithPlaceHolder("输入文字", editSize, kCCTextAlignmentLeft, TYPE_FACE_TABLE.Arial_BoldMT, 12);
	 --    textFieldTTF:setPosition(ccp(editSize.width*0.5,editSize.height*0.5));
	 --    textFieldTTF:setColor(ccc3(255,255,255));
	 --    edit_node:addChild(textFieldTTF);

	 -- 	local function onTouch( eventType, x, y )
		-- 	cclog("------------- eventType " .. eventType);
		-- 	if eventType == "began" then
		-- 		textFieldTTF:attachWithIME();
	 --            return true;    --intercept event
	 --        elseif(eventType == "ended")then
	 --        	self.edit_flag = true
	 --            self.notice_text = textFieldTTF:getString()
	 --            self.m_msgText:setString(tostring(textFieldTTF:getString()))
	 --        end
		-- end
		-- edit_node:registerScriptTouchHandler(onTouch,false,2,true);
	    -- edit_node:setTouchEnabled(true);
	    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = edit_node:getContentSize(),placeHolder=""});
	    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
	    self.m_editBox:setMaxLength(140)
	    edit_node:addChild(self.m_editBox);
	end
	self.m_rootView:addChild(self.m_ccb);
end
function guild_message_edit_view:onEnter(  )
	
end

function guild_message_edit_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return guild_message_edit_view;