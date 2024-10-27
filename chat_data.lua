--- 聊天

--[[--
第一次连接后，服务器返回所保存的世界消息，以及系统消息，玩家对应工会消息，以及针对玩家的好友消息
第一次，
    {kqgFlag=first,uid="",association_id="",show_name=""}
数据格式 ： world－世界  guild－工会  friend－好友 system－系统 guild_war-世界争霸 vip_login-大R登录信息
    {kqgFlag="word",show_name="玩家名字",uid="玩家id",inputStr="输入的内容",data=数据表,association_id="工会id",sendToUid = "对象uid",sendToName = "对象名字"}    
]]


local reconnectIntervalTime = 5   -- 断开重连时间
local maxChatNums = 40

--- 数据缓存
local M = {
    m_socket = nil,
    m_connectOk = nil,

    m_chatData = nil,
    m_chatLinsters = nil,
    m_chatTime = nil,

    m_friendChatSign = nil,

    m_reconnectTimes = nil,
    m_isShowReconnect = nil,
    m_connectFailedTimes = nil,

    m_vipLoginSign = nil,

    m_state = nil,
    m_HistoryPageInfo = nil,
    m_history_chat = nil,
    m_chatRoom = nil,

}

function M.destroy( self )
    if  self.m_socket then
        self.m_socket:delete()
    end
    self.m_socket = nil;
    self.m_connectOk = nil;
    self.m_chatLinsters = nil;
    self.m_chatData = nil;
    self.m_chatTime = nil;

    self.m_friendChatSign = nil;
    self.m_reconnectTimes = nil;
    self.m_state = nil;
    self.m_isShowReconnect = nil;
    self.m_connectFailedTimes = nil;
    self.m_vipLoginSign = nil;
    self.m_HistoryPageInfo = nil;
    self.m_history_chat = nil;
    self.m_chatRoom = nil;
end

function M.close( self )
    if self.m_socket then
        self.m_socket:cocos_close()
        self.m_socket:delete()
        self.m_socket = nil
    end
    self:destroy()
end

function M.disconnect( self )
    self.m_connectOk = false
    self.m_socket:cocos_close()
end

local maxMsgCount = 20
local worldShow = {"world", "friend", "guild", "system"}
local frinedShow = {"friend"}
local guildShow = {"guild", "guild_war"}

local chat_flag_content =
{
    world = {world = true, friends = true, guild = true},
}


local historyChat =   -- 能够查看历史消息记录
{
    world = true,
}


function M.startChat( self )
    self.m_isShowReconnect = false;
    self.m_connectFailedTimes = 0;
    self.m_reconnectTimes = 0
    self.m_chatData = {}  -- 聊天缓存
    -- self.m_chatTime = {world = 0, guild = 0, friend = 0},
    self.m_chatTime = 0
    self.m_friendChatSign = 0;
    self.m_vipLoginSign = {}
    self.m_HistoryPageInfo = {}
    self.m_history_chat = {}
    self.m_chatRoom = {world = true}
    local function socketRecv( flag,data )
        self:filtrateData(flag, data)
    end

    self.m_socket = cocos_socket:new();
    self.m_socket:registerCallBackFunc( socketRecv );
    self:socketConnect();
    self.m_chatLinsters = {}

end

function M.setChatState( self, state )
    self.m_state = state
end

function M.getChatState( self, state )
    return self.m_state
end

--[[--
    连接聊天
]]
function M.socketConnect(self)
    -- cclog2(chat_ip, "chat_ip  =====   ")
    -- cclog2(chat_port, "chat_port  =====   ")
    self.m_socket:cocos_connect(chat_ip,chat_port);
end

--[[--
    
]]
function M.updateState( self )
    if  self.m_connectOk == false then
        self.m_reconnectTimes = 0
        self:connectFailed()
    end
end

--[[--
    发送聊天数据
]]
function M.sendOneChat( self, chatData, showLocal)
    -- cclog2(chatData, "chatData ======== ")
    if not chatData then return end
    if (chatData.kqgFlag == "show" or chatData.kqgFlag == "world") and not self:isCanChat() then
        game_util:addMoveTips({text = string_helper.chat_data.speakTooMuch});
        return false
    end
    chatData = self:completeChatData( chatData )
    local str = json.encode(chatData);
    str = self:shieldKeywordFunc(str);
    if showLocal == nil or showLocal == true then
        self:putOut(str);
    end
    local str1 = "<xml><length>" .. tostring(string.len(str)) .. "</length><content>" .. str .. "</content></xml>";
    if(self.m_connectOk)then
        self.m_socket:cocos_send(str1,string.len(str1));
    else
        game_util:addMoveTips({text = string_helper.chat_data.connectFail});
    end
    self:updateChatTime()
    return true
end

--[[
    解析收到的数据
]]
function M.putOut(self, msg )
    local chatData = self:parseChatDataByKqgFlag( msg )
    if chatData.next then return end
    -- cclog2(chatData, "parseChatData   chatData  ========   ")
    local kqgFlags = self:addOneChat( chatData )
    for k,v in pairs(self.m_chatLinsters) do
        -- print(" ======= ", k, "  ", v)
        if type(v) == "function" then
            v(chatData, self.m_chatLinsters, kqgFlags)
        end
    end
end

--[[
    根据信息类型解析聊天数据
]]
function M.parseChatDataByKqgFlag( self, msg )

    -- cclog("getFormatMsg == " .. msg);
    local tempRecData = json.decode(msg)
    if tempRecData == nil or tempRecData.kqgFlag == nil then
        return {};
    end
    if tempRecData.kqgFlag == "first" then
        return tempRecData
    else
        return self:parseChatData(tempRecData)
    end 
end

--[[
    解析收到的聊天数据
]]
local like_dsign = 0
local msgColor = {"ffFFD700", "ffFFB90F","ffFF1493",}
function M.parseChatData( self, tempRecData )
    if not tempRecData then return {} end
    local vipLevel = tonumber(tempRecData.vip)
    local color = "ffddddc0"
    if vipLevel >= 1 and vipLevel <=3 then  color = msgColor[1] end
    if vipLevel >= 4 and vipLevel <=7 then  color = msgColor[2] end
    if vipLevel >= 8 and vipLevel <=18 then  color = msgColor[3] end

    local showDataTab = {};
    local kqgFlag = tempRecData.kqgFlag;
    local inputStr = tempRecData.inputStr;

    local tempStrTable = util.string_cut(inputStr,'@');
    -- cclog2(tempStrTable, "tempStrTable   ===   ")
    local showMsg = "";
    local smpleMsg = ""
    local clickTab = {};
    local strTable = util.string_cut(inputStr,'&');
    -- cclog2(strTable, "strTable   ===   ")
    local data = tempRecData.data or {};
    -- cclog2(tempRecData, "tempRecData   =====   ")
    -- cclog2(data, "data   =====   ")
    local inviteFlag = false
    for k,v in pairs(strTable) do
        local tempMsg = v;
        local tempData = data[v];
        if(tempData~=nil and tempData.data)then
            local typeName = tempData.typeName
            cclog2(typeName, "typeName   =======    ")
            if typeName == "card" then
                tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. v .. "[/link])";
                showMsg = showMsg .. tempMsg;
                smpleMsg = smpleMsg .. v
                clickTab[#clickTab+1] = tempData;
            elseif typeName == "equip" then
                tempMsg = "([link bg=ff000000 bg_click=9f00ff00]" .. v .. "[/link])";
                showMsg = showMsg .. tempMsg;
                clickTab[#clickTab+1] = tempData;
                smpleMsg = smpleMsg .. v
            elseif typeName == "show" then 
                tempicon = "[image=icon/ui_chat_backshow.png ][/image]"
                tempMsg = "([link bg=ff331111 bg_click=ff331111][color=fff9f900]" .. v .. "[/color][/link])";
                showMsg = showMsg .. tempicon .. "  ".. tempMsg;
                clickTab[#clickTab+1] = tempData;
                smpleMsg = smpleMsg .. v
            elseif typeName == "dart_invite" then
                tempicon = "[image=icon/ui_chat_addteam.png ][/image]"
                local title = string_helper.chat_data.team
                if kqgFlag == "rob" then  title = string_helper.chat_data.robTeam end
                if kqgFlag == "escort" then title = string_helper.chat_data.dartTeam end
                local teamName = tostring(v)
                if string.len(smpleMsg) > 3 then
                    teamName = smpleMsg
                end
                local ttempMsg = "\\[ " .. title .. "  " .. tostring(teamName) .. "  \\]" 
                tempMsg = " [link bg=00000000 bg_click=00000000][color=fff9f900]" .. ttempMsg  .. "[/color][/link]  ";
                -- showMsg = showMsg .. "  ".. tempMsg .. "      " .. tempicon;
                showMsg =  tempMsg;
                clickTab[#clickTab+1] = tempData;
                smpleMsg = smpleMsg .. v
                inviteFlag = true
            elseif typeName == "like" then   -- 点赞
                tempicon = "[image=icon/ui_chat_like.png ][/image]"
                tempMsg = " [link bg=ff331111 bg_click=ff331111][color=fff9f900]" .. tempicon .. "[/color][/link] ";
                showMsg = showMsg .. "  ".. tempMsg;
                clickTab[#clickTab+1] = tempData;
                smpleMsg = smpleMsg .. v
            end
        else
            -- local imagePath = CCFileUtils:sharedFileUtils():fullPathForFilename("icon/e_c_qiangzu.png")
             -- .. "[image=icon/ui_chat_backshow.png]" .. "e_c_qiangzu.png" .. "[/image]" .. "name"
             if color then
                showMsg = showMsg .. "[color=" .. color .. "]" .. tempMsg .. "[/color]";
            else
                showMsg = showMsg .. tempMsg
            end
            smpleMsg = smpleMsg .. tempMsg
        end
    end



    -- 有标记 添加标记
    showDataTab.kqgFlag = kqgFlag
    showDataTab.user = tempRecData.show_name
    showDataTab.inviteFlag = inviteFlag
    showDataTab.content = showMsg 
    showDataTab.clickTab = clickTab
    if not tempRecData.dsign then 
        tempRecData.dsign = like_dsign 
        like_dsign = like_dsign + 1
    end
    showDataTab.dsign = tempRecData.dsign and tonumber( tempRecData.dsign )
    showDataTab.vip = tempRecData.vip
    showDataTab.level = tempRecData.level
    showDataTab.avatarID = tempRecData.avatarID
    showDataTab.uid = tempRecData.uid
    showDataTab.association_id = tempRecData.association_id
    showDataTab.sendToUid = tempRecData.sendToUid
    showDataTab.sendToName = tempRecData.sendToName
    showDataTab.guildName = tempRecData.guildName
    showDataTab.smpleMsg = smpleMsg
    -- cclog2(showDataTab, "showDataTab  ===  ")
    return showDataTab;
end

--[[
    添加聊天个人信息
]]
function M.completeChatData( self, chatData )
    chatData = chatData or {}
    chatData.vip = game_data:getUserStatusDataByKey("vip")
    chatData.level = game_data:getUserStatusDataByKey("level")
    chatData.uid = game_data:getUserStatusDataByKey("uid")
    chatData.show_name = game_data:getUserStatusDataByKey("show_name")
    chatData.association_id = game_data:getUserStatusDataByKey("association_id")

    local avatarID = game_data:updateLocalData("avatar_id")
    if avatarID == "" then
        local role = game_data:getUserStatusDataByKey("role")
        game_data:updateLocalData("avatar_id", tostring(role), true)
        avatarID = game_data:updateLocalData("avatar_id")
    end
    chatData.avatarID = avatarID or ""
    -- 添加一个唯一标示id
    local localTime = os.time()
    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    chatData.dsign = tostring(localTime)
    -- chatData.dsign = tostring(localTime)
    return chatData
end



local worldShow = {world = true, friend = true, guild = true, system = true}
local frinedShow = {"friend"}
local guildShow = {"guild", "guild_war"}

--[[--
    聊天数据
]]
function M.addOneChat( self, msg )
    game_data:addOneChat(msg)
    local kqgFlags = {}
    local maxMsg = self.m_chatData.maxMsg
    if not msg or type(msg) ~= "table" then return end
    local kqgFlag = msg.kqgFlag
    local key = nil
    if kqgFlag == 'world' or kqgFlag == "system" or kqgFlag == 'guild' or kqgFlag == 'friend' then
        key = "world"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end
    if kqgFlag == 'guild' then
        key = "guild"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end
    if kqgFlag == 'friend' then
        key = "friend"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end
    if kqgFlag == "guild_war" then
        key = "guild_war"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end

    if kqgFlag == "escort" then
        key = "escort"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end

    if kqgFlag == "rob" then
        key = "rob"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end


    if kqgFlag == "team" then
        key = "team"
        kqgFlags[key] = true
        self:insertOneChat(key, msg)
    end


    -- if kqgFlag == "first" then
    --     local flag = true
    --     -- local lastTime = self.m_vipLoginSign[msg.uid] 
    --     -- local curTime = msg.loginTime
    --     -- if (lastTime and msg.loginTime )and lastTime - curTime < 3600 * 6 then
    --     --     flag = false
    --     -- end
    --     if flag then
    --         self:insertOneChat("world", msg)
    --         self.m_vipLoginSign[msg.uid] = msg.loginTime
    --     end
    -- end
    return kqgFlags
end

--[[
    查看聊天信息可用
]]
function M.isChatDataUsed( self, key, chatData )
    if not chatData then return false end
    if not key then return false end
    if self.m_chatData[key] == nil then return true end
    local lastMsgData = self.m_chatData[key]
    local flag = false
    local lastCount = #lastMsgData
    local isNewFlag = true
    for k,v in ipairs(lastMsgData) do
        if (v.dsign or chatData.dsign )and v.dsign == chatData.dsign  and  v.uid == chatData.uid then 
            isNewFlag = false 
        elseif not v.dsign and not chatData.dsign and v.uid == chatData.uid then
            if v.data then
                local isDataSame = true
                for i=1, #v.data do
                    if v.data[i] ~= chatData.data[i] then isDataSame = false end
                end
                if isDataSame == true then isNewFlag = false end
            end
        end
    end
    return isNewFlag
end

function M.insertOneChat( self, key, msg )
    if not self:isChatDataUsed(  key, msg ) then return end
    if not self.m_chatData[key] then self.m_chatData[key] = {} end
    msg.dsign = msg.dsign or like_dsign
    cclog2("=========================================*******************************")
    local firstChat = self.m_chatData[key][1]
    if firstChat then
        if firstChat.dsign > msg.dsign then
            self:insertOneChatArray( key, msg, true )
            return 
        end
    end 
    self:insertOneChatArray( key, msg )
end



function M.insertOneChatArray( self, key, msg, isHistory )
    -- if isHistory then cclog2(" insert msg to isHistory   ====   ") end
    if isHistory then
        if not self.m_history_chat[key] then 
            self.m_history_chat[key] = {} 
        end
        local insertFlag = false
        for i=1, #self.m_history_chat[key] do
            if self.m_history_chat[key][i].dsign <= msg.dsign then
                table.insert(self.m_history_chat[key], i, msg)
                insertFlag = true
                break
            end
        end
        if not insertFlag then
            table.insert(self.m_history_chat[key], msg)
        end
        if #self.m_history_chat[key] > maxChatNums then
            table.remove(self.m_history_chat[key], 1)
        end
    else
        table.insert(self.m_chatData[key], msg)
        if #self.m_chatData[key] > maxChatNums then
            local oneChatData = util.table_copy( self.m_chatData[key][1])
            table.remove(self.m_chatData[key], 1)
            self:insertOneChatArray(key, oneChatData, true)
        end
    end

    -- if #self.m_chatData[key] > maxMsgCount then
    --     table.remove(self.m_chatData[key], 1)
    -- end
end

-- function M.getAllMsg( self )
--     local lastMsg = self.m_chatData[key][#self.m_chatData[key]]
--     if lastMsg and os.date("%Y-%m-%d", lastMsg.dsign) ~= os.date("%Y-%m-%d", msg.dsign )  then
--     -- if lastMsg then
--     -- cclog2(os.date("%Y-%m-%d", msg.dsign ), "os.date( =============  " )
--         self.m_chatData[key][#self.m_chatData[key]].lastDate = os.date("%Y-%m-%d", msg.dsign)
--     end
-- end

--[[--
    查看是否可以发送消息    
]]
function M.isCanChat( self, key )
   do return true end
   local lastTime = self.m_chatTime
   -- cclog2(lastTime, "  ", os.time())
   if not lastTime or os.time() - lastTime >= 10 then
        return true
    end
    return false
end

--[[ --
    更新说话时间
]]
function M.updateChatTime( self, key )
    self.m_chatTime = os.time()
end

--[[--
    获取聊天数据
]]
function M.getChats( self, key )
    return self.m_chatData[key] or {}
    -- return self.m_chatData[key]
end

--[[--
    获取聊天数据
]]
function M.getAllChats( self, key )
    return self.m_history_chat[key] or {}, self.m_chatData[key] or {}
    -- return self.m_chatData[key]
end

function M.getFriendChatMessage( self )
    return self.m_friendChatSign, lastFriendChat
end

function M.resetFriendChatSign( self )
    self.m_friendChatSign = 0
end

function M.getLastFriendChatMessage( self )
    local friendChats = self:getChats("friend") 
    -- cclog2(friendChats, "friendChats  =====   ")
    if not friendChats  or #friendChats < 1 then return nil end
    -- cclog2(friendChats, "friendChats  ===  ")
    return friendChats[#friendChats] or nil
    -- local myuid = game_data:getUserStatusDataByKey("uid")
    -- for i=1, friendChats.curMsg do
    --     local msg = friendChats.data[friendChats.curMsg - i + 1]
    --     if tostring(msg.uid) ~= tostring(myuid) then
    --         return msg
    --     end
    -- end
    -- return nil
end




--[[
    注册一个接收这
]]
function M.registerOneLinster( self, linsterFun, key )
    self.m_chatLinsters[key] = linsterFun
end

--[[
    销毁一个接受者
]]
function M.removeOneLinster( self, key)
    if self.m_chatLinsters then
        self.m_chatLinsters[key] = nil
    end
end


--[[
    过滤敏感字
]]
local shieldKeywordTab = string_helper.chat_data.shieldKeywordTab

function M.shieldKeywordFunc(self,str)
    for k,v in pairs(shieldKeywordTab) do
        str = string.gsub(str,tostring(v),"***");
    end
    return str;
end


--[[--
    过滤一下 聊天信息
]]
function M.filtrateData( self, flag, data )
    -- body
        -- cclog("-------------recv flag----  " .. tostring(flag));
        -- cclog2(data, "-------------recv data----  " );
        if(flag==2)then     -- 首次连接成功
            self.m_connectOk = true;
            self.m_reconnectTimes = 0
            self.m_connectFailedTimes = 0
            local userStatusData = game_data:getUserStatusData();
            local vip = game_data:getUserStatusDataByKey("vip")
            -- kqgFlag="first",uid="uid",association_id=""
            local str = json.encode({kqgFlag = "first",uid = userStatusData.uid,vip = vip,
                show_name = userStatusData.show_name,association_id = userStatusData.association_id, dsign = self:getSign() })
            local str1 = "<xml><length>" .. tostring(string.len(str)) .. "</length><content>" .. str .. "</content></xml>";
            cclog2(str, "FIRST SEND")
            self.m_socket:cocos_send(str1,string.len(str1));

            self:updateChatRoom()
        elseif(flag == -2)then   -- 连接失败
            -- game_util:addMoveTips({text = "连接失败！"});
            self:connectFailed()
        elseif(flag>0)then  
            self.m_reconnectTimes = 0
            self.m_connectFailedTimes = 0
            if(data~=nil)then    -- 正常接受数据
                -- cclog("----------recv-----" .. data);                
                self:putOut(data);
            end
        else                -- 接收异常或连接断开
            -- cclog("-------------recv flag----" .. tostring(flag));
            self:connectFailed()

            -- if flag == -1 then
            --     self:connectFailed()
            --     self.m_connectFailedTimes = self.m_connectFailedTimes + 1
            -- else
            --     self:connectFailed()
            -- end
        end
end

function M.getSign( self )
    return tostring(os.time())
end

function M.updateChatRoom( self, room )
    if not self.m_connectOk then return end
    room = room or {}
    for k,v in pairs(room) do
        self.m_chatRoom[k] = v
    end
    local chatData = {kqgFlag = "update", inputStr = "" }
    for k,v in pairs( self.m_chatRoom ) do
        chatData[tostring(k)] = v
    end
    self:sendOneChat(chatData, false)
end

--[[
    是否可以获取历史聊天消息记录
]]
function M.isCanRequestHistoruChatLog( self, chatType )
    if historyChat[ chatType ] then 
        if not self.m_HistoryPageInfo[ chatType ] or self.m_HistoryPageInfo[ chatType ] < 2 then
            return true
        end
    end
    return false
end

--[[
    获取历史聊天记录
]]
function M.requestHistoryChatLog( self, chatType )
    if not self:isCanRequestHistoruChatLog( chatType ) then return false end
    if not self.m_HistoryPageInfo[ chatType ] then self.m_HistoryPageInfo[ chatType ] = 0 end
    local chatData = {kqgFlag = chatType, inputStr = "" }
    chatData["next"] = self.m_HistoryPageInfo[ chatType ] + 1
    -- self.m_history_chat[chatType] = self.m_history_chat[chatType] or {}
    -- cclog2("--------------------------------------aaaaaa-----------------------")
    -- cclog2(#self.m_chatData[chatType], "per self.m_chatData   ======    ")
    -- cclog2(#self.m_history_chat[chatType], "per self.m_history_chat   ======    ")
    -- for k,v in pairs( self.m_history_chat[chatType] or {} ) do
    --     if type(v) == "table" then
    --         table.insert(self.m_chatData[chatType], k, v)
    --     end
    -- end
    -- self.m_history_chat[chatType] = {}
    -- cclog2(#self.m_chatData[chatType], "cur self.m_chatData   ======    ")
    -- cclog2(#self.m_history_chat[chatType], "cur self.m_history_chat   ======    ")
    self:sendOneChat(chatData, false)
    self.m_HistoryPageInfo[ chatType ] = self.m_HistoryPageInfo[ chatType ] + 1
end

--[[
    发送点赞
]]
function M.sendLikeMsg( self, key, msg )
    local chatOber = game_data:getChatObserver()
    local show_name = game_data:getUserStatusDataByKey("show_name") or ""
    local info = " " .. tostring(show_name) .. tostring(msg) .. "&like&"
    local tt = {}
    tt["like"] = {typeName = "like", data = key}
    local chatData = {kqgFlag = "system", inputStr = info , data = tt }
    self:sendOneChat(chatData)
end


local failedTimes = 0

function M.connectFailed( self )
    -- cclog2(failedTimes, "connectFailed =======   ")
    failedTimes = failedTimes + 1
    self.m_connectOk = false;
    -- cclog2(self.m_reconnectTimes, "self.m_reconnectTimes  ====  ")
    -- cclog2(self.m_isShowReconnect, "self.m_isShowReconnect  ====  ")
    -- cclog2(self.m_connectFailedTimes, "self.m_connectFailedTimes  ====  ")
    -- if self.m_isShowReconnect == true then
    --     return
    -- end
    -- if self.m_reconnectTimes >= 1 then
        -- self:disconnect()
        -- self:reconnect()
        -- return
    -- end
    -- self.m_connectOk = false;
    -- self.m_socket:cocos_close();
    self:disconnect()
    self:reconnect()
    -- local t_params = 
    -- {
    --     title = string_config.m_title_prompt,
    --     okBtnCallBack = function(target,event)
    --         self.m_isShowReconnect = false
    --         if self.m_connectFailedTimes > 3 then 
    --             self.m_connectFailedTimes = 0
    --             game_util:closeAlertView();
    --             self:disconnect()
    --             self:reconnect()
    --         else
    --             self.m_reconnectTimes = self.m_reconnectTimes + 1
    --             game_util:closeAlertView();
    --             -- self:socketConnect();
    --             self:disconnect()
    --             self:reconnect()
    --         end
    --     end,   --可缺省
    --     closeCallBack = function(target,event)
    --         self.m_isShowReconnect = false
    --         game_util:closeAlertView();
    --         self:disconnect()
    --         self:reconnect()
    --     end,
    --     okBtnText = "重新连接",       --可缺省
    --     text = "接收异常或连接断开！",      --可缺省
    -- }
    -- self.m_isShowReconnect = true
    -- game_util:openAlertView(t_params)
end

--[[
    断开重连方案
]]
function M.reconnect( self )
    local connect_id = 0;
    function tick( dt )
        -- cclog2(connect_id, "start reconnect socket   ==================  ")
        scheduler.unschedule( connect_id )  -- 已经连接上
        self:socketConnect()
        -- if self.m_connectOk then 
        -- end
    end
    connect_id = scheduler.schedule(tick, reconnectIntervalTime, false)
end




return M;