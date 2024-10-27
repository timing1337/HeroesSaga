require "shared.extern"

local guild_chat_pop_control = class("guildChatPopControl" , require("like_oo.oo_controlBase"));

guild_chat_pop_control.m_curFlag = "guild";

function guild_chat_pop_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	
end

function guild_chat_pop_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_chat_pop_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:closeView();	
	elseif(msg == 10)then   	-- 刷新消息
		self.m_data:changeData(data);
		self.m_view:refreshScrollView();
	elseif(msg == 201)then 		-- 战场
		self.m_curFlag = "guild_war";
		self.m_view:refreshScrollView();
	elseif(msg == 202)then 		-- 公会
		self.m_curFlag = "guild";
		self.m_view:refreshScrollView();
	end
end

function guild_chat_pop_control:getShowData(  )
	-- body
    local showDataTab = {};
    local tempMsg = self.m_data:getChatMsg();
	for k,v in pairs(tempMsg) do
        local kqgFlag = v.kqgFlag
		if self.m_curFlag=='world' then		-- 世界标记
			if kqgFlag == 'world' or kqgFlag == "system" or kqgFlag == 'guild' or kqgFlag == 'friend' then
                showDataTab[#showDataTab+1] = v;
			end
		elseif self.m_curFlag=='guild' then    -- 工会标记
			if kqgFlag == 'guild' then
                showDataTab[#showDataTab+1] = v;
			end
		elseif self.m_curFlag=='friend' then    -- 好友
			if kqgFlag == 'friend' then
                showDataTab[#showDataTab+1] = v;
			end
		elseif(self.m_curFlag == "guild_war")then 	-- 公会战
			if(kqgFlag == "guild_war" or kqgFlag == "guild")then
				showDataTab[#showDataTab+1] = v;
			end
		end
	end
    return showDataTab;
end

function guild_chat_pop_control:getFlag(  )
	-- body
	return self.m_curFlag;
end




return guild_chat_pop_control;