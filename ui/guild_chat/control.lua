require "shared.extern"

local guild_chat_control = class("guildChatControl" , require("like_oo.oo_controlBase"));

guild_chat_control.m_socket = nil;
guild_chat_control.m_conectOk = false;
guild_chat_control.m_curData = "";
guild_chat_control.m_netMsg = {};

guild_chat_control.m_curMsg = 0;
guild_chat_control.m_maxMsg = 20;



function guild_chat_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	local function socketRecv( flag,data )
		-- body
		cclog("-------------recv flag----" .. tostring(flag));
        if(flag==2)then     -- 首次连接成功
            self.m_conectOk = true;
            local userStatusData = game_data:getUserStatusData();
            -- kqgFlag="first",uid="uid",association_id=""
            local str = json.encode({kqgFlag = "first",uid = userStatusData.uid,show_name = userStatusData.show_name,association_id = userStatusData.association_id,game_id = self.m_data:getGameId()})
            local str1 = "<xml><length>" .. tostring(string.len(str)) .. "</length><content>" .. str .. "</content></xml>";
            local err = self.m_socket:cocos_send(str1,string.len(str1));
            cclog("--------- first send " .. tostring(err));
        elseif(flag == -2)then   -- 连接失败
        	self.m_socket:cocos_connect(chat_ip,chat_port);
        elseif(flag>0)then  
            if(data~=nil)then    -- 正常接受数据
            	cclog("----------recv-----" .. data);
                self:putOut(data);
            end
        else                -- 接收异常或连接断开
            cclog("-------------recv flag----" .. tostring(flag));
        end
	end

	self.m_socket = cocos_socket:new();
	self.m_socket:registerCallBackFunc(socketRecv);
	self.m_socket:cocos_connect(chat_ip,chat_port);
end

function guild_chat_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_chat_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then
		cclog("---------- view open guild_chat_pop ");
		self:openView("guild_chat_pop",self.m_netMsg);
	elseif(msg == 4)then
		-- 发送数据消息
		cclog("----------- onSendData flag = " .. data.f .. " data = " .. data.m);
		self:sendTo( data.m , data.f );
	end
end

function guild_chat_control:destroy(  )
	-- body
	if(self.m_socket ~= nil)then
		self.m_socket:delete();
		self.m_socket = nil;
	end
	self.controlBase.destroy( self );

end



function guild_chat_control:putOut( msg )
	-- body
	if(self.m_curMsg>=self.m_maxMsg)then
		for i=1,self.m_maxMsg-1 do
			self.m_netMsg[i]=self.m_netMsg[i+1];
		end
		self.m_netMsg[self.m_curMsg]=self:getFormatMsg(msg);
	else
		self.m_netMsg[self.m_curMsg]=self:getFormatMsg(msg);
		self.m_curMsg=self.m_curMsg+1;
	end
    -- self:setShowLabelContent();
    self:updataMsg(10,self.m_netMsg,"guild_chat_pop");
end

function guild_chat_control:getFormatMsg( msg )
    cclog("getFormatMsg == " .. msg);
    local tempRecData = json.decode(msg)
    -- body
    local showDataTab = {};
    if tempRecData == nil or tempRecData.kqgFlag == nil then
        return showDataTab;
    end
    local selfUid = game_data:getUserStatusDataByKey('uid');
    local kqgFlag = tempRecData.kqgFlag;
    local inputStr = tempRecData.inputStr;
    local tempStrTable = util.string_cut(inputStr,'@');
    local showMsg = "";
    local clickTab = {};
    local strTable = util.string_cut(inputStr,'&');
    local data = tempRecData.data;
    for k,v in pairs(strTable) do
        local tempMsg = v;
        local tempData = data[v];
        if(tempData~=nil and tempData.data)then
            local typeName = tempData.typeName
            if typeName == "card" then
                tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. v .. "[/link])";
                showMsg = showMsg .. tempMsg;
                clickTab[#clickTab+1] = tempData;
            elseif typeName == "equip" then
                tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. v .. "[/link])";
                showMsg = showMsg .. tempMsg;
                clickTab[#clickTab+1] = tempData;
            end
        else
            showMsg = showMsg .. tempMsg;
        end
    end
    local tempUID = tempRecData.uid
    cclog("showMsg== " .. showMsg)
    if(kqgFlag == 'world')then -- 世界标记
        local name = tempRecData.show_name or tempUID;
        if selfUid == tempUID then--我说
            showDataTab = {kqgFlag = "world",user = string_helper.guild_chat.isay,content = showMsg,clickTab = clickTab};
        else
            table.insert(clickTab,1,{typeName = "user",data = {uid = tempUID,name = name}})
            showDataTab = {kqgFlag = "world",user = "[color=ffffc100][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]"..string_helper.guild_chat.say,content = showMsg,clickTab = clickTab};
        end
    elseif(kqgFlag == 'guild')then-- 工会标记
        local name = tempRecData.show_name or tempUID;
        if selfUid == tempUID then--我对公会说
            showDataTab = {kqgFlag = "guild",user = string_helper.guild_chat.iSayToGuild,content = showMsg,clickTab = clickTab};
        else
            table.insert(clickTab,1,{typeName = "user",data = {uid = tempUID,name = name}})
            showDataTab = {kqgFlag = "guild",user = "[color=ff0000ff][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]"..string_helper.guild_chat.sayToGuild,content = showMsg,clickTab = clickTab};

        end
    elseif(kqgFlag == "guild_war")then -- 公会战
    	local name = tempRecData.show_name or tempUID;
        if selfUid == tempUID then--我对公会说
            showDataTab = {kqgFlag = "guild_war",user = string_helper.guild_chat.iSayToWar,content = showMsg,clickTab = clickTab};
        else
            table.insert(clickTab,1,{typeName = "user",data = {uid = tempUID,name = name}})
            showDataTab = {kqgFlag = "guild_war",user = "[color=ff0000ff][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]"..string_helper.guild_chat.sayToWar,content = showMsg,clickTab = clickTab};

        end
    elseif(kqgFlag == 'friend')then -- 好友
        -- sendToUid = "对象uid",sendToName = "对象名字"
        if selfUid == tempUID then--我对某人说
            local name = tempRecData.sendToName or tempRecData.sendToUid;
            table.insert(clickTab,1,{typeName = "user",data = {uid = tempRecData.sendToUid,name = name}})
            showDataTab = {kqgFlag = "friend",user = string_helper.guild_chat.me.."[color=ffffff00][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]"..string_helper.guild_chat.say,content = showMsg,clickTab = clickTab};
        else
            local name = tempRecData.show_name or tempRecData.tempUID;
            table.insert(clickTab,1,{typeName = "user",data = {uid = tempRecData.uid,name = name}})
            showDataTab = {kqgFlag = "friend",user = "[color=ffffff00][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]"..string_helper.guild_chat.sayToMe,content = showMsg,clickTab = clickTab};
        end
    elseif(kqgFlag == 'system')then -- 系统
        local name = tempRecData.show_name or string_helper.guild_chat.sys;
        showDataTab = {kqgFlag = "system",user = name,content = showMsg,clickTab = clickTab};
    else
        local name = tempRecData.show_name or "";
        showDataTab = {kqgFlag = kqgFlag,user = "[color=ffff0000][link bg=ff000000 bg_click=9f00ff00]" .. name .. "[/link][/color]",content = showMsg,clickTab = clickTab};
    end
    return showDataTab;
end

function guild_chat_control:sendTo( msgdata , flag )

		cclog("=========== sendTo flag = " .. flag .. " data=" .. msgdata);
        local tempstr = msgdata;
        local function sendData()
        	cclog(" --------------- sendData")
            local tempData = nil
            local userStatusData = game_data:getUserStatusData();
            if(flag == 'world')then       -- 世界
                tempData = {kqgFlag = "world",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = {}}
            elseif(flag == 'guild')then   -- 工会
                tempData = {kqgFlag = "guild",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = {},association_id = userStatusData.association_id}
            elseif(flag == 'friend')then   -- 好友
                tempData = {kqgFlag = "friend",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = {},sendToUid = sendToUid,sendToName = self.m_sendToName}
            elseif(flag == 'guild_war')then -- 公会战
            	tempData = {kqgFlag = "guild_war",show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = {},association_id = userStatusData.association_id,game_id = self.m_data:getGameId()}
            else
                tempData = {kqgFlag = flag,show_name = userStatusData.show_name,uid = userStatusData.uid,inputStr = tempstr,data = {}}
            end
            local str = json.encode(tempData);
            self:putOut(str);
            local str1 = "<xml><length>" .. tostring(string.len(str)) .. "</length><content>" .. str .. "</content></xml>";
            -- 发送数据
            cclog("------------ well send ");
            if(self.m_conectOk)then
            	cclog("---------------- be sended data  " .. str1);
                self.m_socket:cocos_send(str1,string.len(str1));
            else
            	cclog("---------------- be sended data error ");
                game_util:addMoveTips({text = string_helper.guild_chat.connectFail});
            end
        end
        if flag == "friend" then
            if sendToUid == nil or sendToUid == "" then
                game_util:addMoveTips({text = string_helper.guild_chat.inputUid});
                return
            end
            if tempstr == nil or tempstr == "" then 
                self.m_tempData = {};
                game_util:addMoveTips({text = string_helper.guild_chat.inputWord});
                return 
            end
            if self.m_editUserChanged == true then
                local function responseMethod(tag,gameData)
                    self.m_editUserChanged = false;
                    self.m_sendToName = gameData:getNodeWithKey("data"):getNodeWithKey("name"):toStr();
                    cclog("self.m_sendToName ====== " .. self.m_sendToName)
                end 
                local params = {};
                params.uid = sendToUid;
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
            else
                sendData();
            end
        else
            if flag == "guild" then
                local association_id = game_data:getUserStatusDataByKey("association_id");
                if association_id == 0 then--无公会
                    game_util:addMoveTips({text = string_helper.guild_chat.guildTips});
                    return;
                end
            end
            if tempstr == nil or tempstr == "" then 
                self.m_tempData = {};
                game_util:addMoveTips({text = string_helper.guild_chat.inputWord});
                return 
            end
            sendData();
        end
end


return guild_chat_control;