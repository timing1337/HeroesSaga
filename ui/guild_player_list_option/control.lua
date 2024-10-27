require "shared.extern"

local guild_player_list_option_control = class("guildPlayerListOptionControl",require("like_oo.oo_controlBase"));

function guild_player_list_option_control:onCreate(  )
	-- 初始化函数框架自动调用
end

function guild_player_list_option_control:onEnter(  )
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
end

function guild_player_list_option_control:onHandle( msg , data )
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	local function netDataBack( netData )
		self:updataMsg(2345,netData.data,"guild_player_list_pop");
		self:closeView();
	end
	if(msg == 1)then
		print( data );
	elseif(msg == 3)then		-- 玩家详情
	    local function responseMethod(tag,gameData)
	        self:closeView();
	        game_scene:addPop("game_player_info_pop",{gameData = gameData})
	    end
	    local params = {};
	    params.uid = self.m_data:getUid();
	    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
	elseif(msg == 4)then		-- 升职
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 2 , user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 5)then		-- 降职
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 0 , user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 6)then		-- 踢出公会
		self.m_data:getNetData( game_url.getUrlForKey("association_remove_player") , {user_id = self.m_data:getUid()},netDataBack);
	elseif(msg == 7)then		-- 转交会长
		self.m_data:getNetData( game_url.getUrlForKey("association_appoint_player") , {position = 1 , user_id = self.m_data:getUid()},netDataBack);
	elseif msg == 8 then		--解散工会
		local function myNetBackData(tag,gameData)
			self:goHome();
			game_util:addMoveTips({text = string_helper.guild_player_list_option.dismiss})
		end
		local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                self.m_data:getNetData( game_url.getUrlForKey("association_guild_destroy") , nil,myNetBackData);
                game_util:closeAlertView();
            end,   --可缺省
            okBtnText = string_helper.guild_player_list_option.certain,       --可缺省
            text = string_helper.guild_player_list_option.text,      --可缺省
        }
        game_util:openAlertView(t_params);
    elseif msg == 9 then			  --退出公会
    	local function myNetBackData(tag,gameData)
			self:goHome();
			game_util:addMoveTips({text = string_helper.guild_player_list_option.quit})
		end
		local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                self.m_data:getNetData( game_url.getUrlForKey("association_guild_quit") , nil,myNetBackData);
                game_util:closeAlertView();
            end,   --可缺省
            okBtnText = string_helper.guild_player_list_option.certain,       --可缺省
            text = string_helper.guild_player_list_option.quitTips,      --可缺省
        }
        game_util:openAlertView(t_params);
	end
end

return guild_player_list_option_control;