--- 聊天

--[[--
第一次发送数据 kqgFlag=first&uid=''&guide=''
第一次连接后，服务器返回所保存的世界消息，以及系统消息，玩家对应工会消息，以及针对玩家的好友消息
第一次，
    kqgFlag=first  &  uid  &  工会id  &  名字 
世界，	
	kqgFlag=word&  &  name='玩家名字'  &  uid='玩家id'  &  data='消息'
工会，
	kqgFlag=guide  &  name='玩家名字'  &  uid='玩家id'  &  data='消息'
系统，
	kqgFlag=system &  name=''  &  uid=''  &  data='消息'
好友
	kqgFlag=friend  &  name='玩家名字'  &  uid='对象uid'  &  data='消息'
]]



local __ui_chat = {
	m_ccbNode = nil,			-- 
	m_editNode = nil,			-- 输入框
	m_socket = nil,
	m_msg = {},
	m_maxMsg = 7,
	m_curMsg = 1,
	m_curFlag = 'world',				-- 分类标记 ， world,世界  guide,工会  friend,好友
	m_webView = nil,
	m_conectOk = false,
	m_tempData = {},
	layer = nil,
}

function __ui_chat:create(  )
	-- body
	self.m_ccbNode = luaCCBNode:create();
	local function onCancel(target,event)
		-- body
		game_scene:removePopByName("ui_chat");
	end

	local function onOk(target,event)
		-- body
		cclog("--------------------------------[");
		util.printf(game_data.m_tUserStatusData);
		cclog("]---------------------------------");
		local tempstr = self.m_editNode:getText();
		local strTable = util.string_cut(tempstr,'&');
		local str = "";
		for k,v in pairs(strTable) do
			if(self.m_tempData[v]~=nil)then
				local tempStrTable = util.string_cut(v,'@');
				local tempchgstr = string.gsub(self.m_tempData[v],'\"','@');
				str = str .. '<a color=10c155 href="kqg://' .. tempStrTable[1] .. '/' .. tempchgstr .. '">' .. tempStrTable[2] .. '</a>';
			else
				str = str .. v ;
			end
		end
		-- local str2 = "<a color=ff0000>我:</font>" .. str;
		cclog("-------------------" .. str);
		if(self.m_curFlag == 'world')then		-- 世界
			str = 'world&' .. game_data.m_tUserStatusData.show_name .. '&' .. game_data.m_tUserStatusData.uid .. '&' .. str;
		elseif(self.m_curFlag == 'guide')then   -- 工会
			str = 'guide&' .. game_data.m_tUserStatusData.show_name .. '&' .. game_data.m_tUserStatusData.uid .. '&' .. str;
		else
			str = self.m_curFlag .. '&' .. game_data.m_tUserStatusData.show_name .. '&' .. game_data.m_tUserStatusData.uid .. '&' .. str;
		end
		self:putOut(str);
		local str1 = "<xml><length>" .. tostring(string.len(str)) .. "</length><content>" .. str .. "</content></xml>";
		-- 发送数据
		if(self.m_conectOk)then
			self.m_socket:cocos_send(str1,string.len(str1));
		else
			cclog("------------------------连接未成功");
		end
		self.m_tempData = {};
    end

    local function onChange( target,event )
    	-- body
    	self.m_webView:showOrHidden();
    end
	local function editboxEventHandler(eventType)
        -- echoInfo("eventType ---- " .. eventType);
        if eventType == "began" then
        -- triggered when an edit box gains focus after keyboard is shown
        elseif eventType == "ended" then
        -- triggered when an edit box loses focus after keyboard is hidden.
        elseif eventType == "changed" then
        -- triggered when the edit box text was changed.
        elseif eventType == "return" then
        -- triggered when the return button was pressed or the outside area of keyboard was touched.
        end
    end
    local function socketRecv( flag,data )
    	-- body
    	cclog("-------------recv flag----" .. tostring(flag) .. " and data = " ..  tostring(data));
    	if(flag==2)then		-- 首次连接成功
    		self.m_conectOk = true;
    		local str1 = 'first' .. '&' .. game_data.m_tUserStatusData.uid .. '&' .. game_data.m_tUserStatusData.show_name .. '&' .. game_data.m_tUserStatusData.association_id;
    		self.m_socket:cocos_send(str1,string.len(str1));
    	elseif(flag == -2)then   -- 连接失败

    	elseif(flag>0)then	
            print(" recv data, and data === ", nil or "  data = nil  ")
    		if(data~=nil)then    -- 正常接受数据
    			cclog("----------recv-----" .. data);
    			self:putOut(data);
    		end
    	else 				-- 接收异常或连接断开
    		cclog("-------------recv flag----" .. tostring(flag));
    	end
    end

    local function onFriendCallBack(  )
    	-- body
    	cclog("-------------------onFriendCallBack");
    	self:setButtonTitle("好友");
    	self.m_webView:showOrHidden();
    	-- self.m_curFlag = "friend";
    	local msg = self:updataMsg();
		self.m_webView:setData(msg);
    end
    local function onGuildCallBack(  )
    	-- body
    	cclog("-------------------onGuildCallBack");
    	self:setButtonTitle("工会");
    	self.m_webView:showOrHidden();
    	self.m_curFlag = "guide";
    	local msg = self:updataMsg();
		self.m_webView:setData(msg);
    end
    local function onWorldCallBack(  )
    	-- body
    	cclog("-------------------onWorldCallBack");
    	self:setButtonTitle("世界");
    	self.m_webView:showOrHidden();
    	self.m_curFlag = "world";
    	local msg = self:updataMsg();
		self.m_webView:setData(msg);
    end
    local function onBagCallBack( flag )
    	-- body
    	cclog("-------------------onBagCallBack");
    	if(flag==1)then
    		-- 卡牌
    		self:addSelHeroUi();
    		self.m_webView:setHidden(true);
    	elseif(flag==2)then
    		-- 装备
    		self:addSelEquipUi();
    		self.m_webView:setHidden(true);
    	elseif(flag==3)then
    		-- 道具
    	end
    end
    local function onWebCallBack( obj,flag,msg )
    	-- body
    	cclog("------------------------");
    	if(flag == 5)then 				-- 处理超链接
    		local tempTable = util.string_cut(msg,'/');
    		cclog("-------------" .. tostring(#tempTable));
    		for k,v in pairs(tempTable) do
    			print(k,v)
    		end
    		local str = urlDecoding(tempTable[4]);
    		local str = string.gsub(str,'@','\"');
    		local gameData = json.decode(str);
    		if(tempTable[3] == 'card')then
    			game_scene:addPop("game_hero_info_pop",{tGameData = gameData,
    													 openType = 3 , 
    													 callBack = function ( )
    																	-- body
    																	cclog("返回聊天")
    																	self.m_webView:setHidden(false);
    																end})
    		elseif(tempTable[3] == 'equip')then
    			
    		end
    		self.m_webView:setHidden(true);
    	end
    end
    cclog("---------chat start");
	self.m_ccbNode:registerFunctionWithFuncName("closeBtnPress",onCancel);
	self.m_ccbNode:registerFunctionWithFuncName("chatBtnPress",onOk);
	self.m_ccbNode:registerFunctionWithFuncName("itemBtnPress",onChange);
	self.m_ccbNode:openCCBFile("ccb/ui_chat.ccbi");
	cclog("---------chat ui loaded");
	local tempEditNode = tolua.cast(self.m_ccbNode:objectForName("m_edit"),"CCNode");
	local tempMsgNode = tolua.cast(self.m_ccbNode:objectForName("m_node"),"CCNode");
	self.m_itemBtn = tolua.cast(self.m_ccbNode:objectForName("m_itemBtn"),"CCControlButton");
    -- self:setButtonTitle(m_itemBtn,"test")
	
	cclog("---------start edit");
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbDefaultImages.plist");
    local bg_ = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_talkBar.png");
    local scale9 = CCScale9Sprite:createWithSpriteFrame(bg_,CCRectMake(0,0,0,0) );
    scale9:setOpacity(0);
    self.m_editNode = CCEditBox:create(tempEditNode:getContentSize(),  scale9);
    self.m_editNode:registerScriptEditBoxHandler(editboxEventHandler)
    self.m_editNode:setFontColor(ccc3(0,0,0))
    self.m_editNode:setAnchorPoint(ccp(0,0));
    local editx,edity = tempEditNode:getPosition()
    local editpt = tempEditNode:getParent():convertToWorldSpace(ccp(editx,edity));
    self.m_editNode:setPosition(editpt);
    self.m_ccbNode:addChild(self.m_editNode);
    cclog("----------edit end");

    self.m_socket = cocos_socket:new();
    self.m_socket:cocos_connect(chat_ip,chat_port);
    self.m_socket:registerCallBackFunc(socketRecv);


    local x,y = tempMsgNode:getPosition();
    local sz = tempMsgNode:getContentSize();
    local pt = tempMsgNode:getParent():convertToWorldSpace(ccp(x,y));
    -- local gsz = CCDirector:sharedDirector():getWinSize();
    -- local offestX = (gsz.width - 480) / 2 + 3
    self.m_webView = zcWebView:create(CCRectMake(pt.x,pt.y,sz.width,sz.height));
    tempMsgNode:addChild(self.m_webView);
    self.m_webView:registerFriend(onFriendCallBack);
    self.m_webView:registerGuild(onGuildCallBack);
    self.m_webView:registerWorld(onWorldCallBack);
    self.m_webView:registerBag(onBagCallBack);
    self.m_webView:registerCallBack(onWebCallBack);
    -- self.m_webView:requestURL("http://www.baidu.com");
    local winSize = CCDirector:sharedDirector():getWinSize();

    self.layer = CCLayer:create();
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    -- layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    self.layer:registerScriptTouchHandler(onTouch,false,1,true);
    self.layer:setTouchEnabled(true);
    self.layer:addChild(self.m_ccbNode);
    return self.layer;
end

function __ui_chat:setButtonTitle(str)
    self.m_itemBtn:setTitleForState(CCString:create(str),1)
	-- btn:setTitleForState(CCString:create(str),0.1)
	-- btn:setTitleForState(CCString:create(str),0.01)
	-- btn:setTitleForState(CCString:create(str),0.001)
end

function __ui_chat:destroy(  )
    cclog("-----------------__ui_chat destroy-----------------");
	-- body
	-- self.m_ccbNode:removeFromParentAndCleanup(true);
	-- self.layer:removeFromParentAndCleanup(true);
	self.m_ccbNode = nil;
	self.m_socket:delete();
	self.m_msg = {};
	self.m_maxMsg = 7;
	self.m_curMsg = 1;
	self.m_curFlag = 'world';
	self.m_conectOk = false;
end

function __ui_chat:putOut( msg )
	-- body
	if(self.m_curMsg>=self.m_maxMsg)then
		for i=1,self.m_maxMsg-1 do
			self.m_msg[i]=self.m_msg[i+1];
		end
		self.m_msg[self.m_curMsg]=msg;
	else
		self.m_msg[self.m_curMsg]=msg;
		self.m_curMsg=self.m_curMsg+1;
	end
	local msg = self:updataMsg();
	cclog("显示的html标记" .. msg);
	self.m_webView:setData(msg);
end

function __ui_chat:updataMsg(  )
	-- body
	local msg="";
	for k,v in pairs(self.m_msg) do
		if(self.m_curFlag=='world')then		-- 世界标记
			local tabmsg = util.string_cut(v,'&');
			if(tabmsg[1] == 'world')then
				msg = msg .. "<p>" .. "<font color=ffc100>" .. tabmsg[2] .. ":" .. tabmsg[4] .. "</font>";
			elseif(tabmsg[1] == 'guide')then
				msg = msg .. "<p>" .. "<font color=0000ff>" .. tabmsg[2] .. ":" .. tabmsg[4] .. "</font>";
			else
				msg = msg .. "<p>" .. "<font color=ffff00>" .. tabmsg[2] .. ":" .. tabmsg[4] .. "</font>";
			end
		elseif(self.m_curFlag=='guide')then    -- 工会标记
			local tabmsg = util.string_cut(v,'&');
			if(tabmsg[1] == 'guide')then
				msg = msg .. "<p>" .. "<font color=0000ff>" .. tabmsg[2] .. ":" .. tabmsg[4] .. "</font>" .. "</p>";
			end
		else     							   -- 好友
			local tabmsg = util.string_cut(v,'&');
			if(tabmsg[1] == 'friend') and (tabmsg[3] == self.m_curFlag)then
				msg = msg .. "<p>" .. "<font color=ffff00>" .. tabmsg[2] .. ":" .. tabmsg[4] .. "</font>" .. "</p>";
			end
		end
		
	end
	return msg;
end


--[[--
    卡牌背包
]]
function __ui_chat.addSelHeroUi(self)
    local btnCallFunc = function( target,event )
        
    end
    local itemOnClick = function (id)
        if id then
        	local cardData,cardCfg = game_data:getCardDataById(id);

        	local name = cardCfg:getNodeWithKey("name"):toStr();
        	local key = "card@" .. name .. tostring(#self.m_tempData+1);
        	self.m_tempData[key] = json.encode(cardData);
        	cclog(self.m_tempData[key]);
            -- if (not game_data:heroInTeamById(id)) then
            --     cclog("itemOnClick id ==================== " .. id);

            -- －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
            self.m_webView:setHidden(false);
            local str = self.m_editNode:getText();
            str = str .. '&' .. key .. '&'
            self.m_editNode:setText(str);
            --     -- local teamTable = game_data:getTeamData();
            --     -- game_data:setTeamByPosAndCardId(posIndex,id);
            -- end
        end
    end
    game_scene:addPop("game_hero_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick})
end

--[[--
    装备背包
]]
function __ui_chat.addSelEquipUi(self)
    local btnCallFunc = function( target,event )

    end
    local itemOnClick = function (id)
        if id then

        	local equipData,equipCfg = game_data:getEquipDataById(id);

        	local name = equipCfg:getNodeWithKey("name"):toStr();
        	local key = "equip@" .. name .. tostring(#self.m_tempData+1);
            self.m_tempData[key] = json.encode(cardData);

            local str = self.m_editNode:getText();
            str = str .. '&' .. key .. '&'
            self.m_editNode:setText(str);
        end
    end
    game_scene:addPop("game_equip_select_pop",{btnCallFunc = btnCallFunc,itemOnClick = itemOnClick,sortBtnShow = true})
end



return __ui_chat;