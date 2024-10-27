require "shared.extern"

local guild_war_control = class("guildWarControl" , require("like_oo.oo_controlBase"));

guild_war_control.m_timer = nil;

guild_war_control.m_curRoundData = nil;

-- 1 操作记时状态，2 操作结束等待状态，3 播放动作状态
guild_war_control.m_warType = 1;
-- movelist 播放计数
guild_war_control.m_index = 1;

guild_war_control.m_timeLong = 0;

guild_war_control.m_curSecond = 0;

-- 行动表(y,x);
guild_war_control.m_moveTable = {
        							  {-3, 0}, 
        				    {-2, -1}, {-2, 0}, {-2, 1}, 
        		  {-1, -2}, {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2}, 
        {0, -3},  {0, -2},  {0, -1},  {0, 0},  {0, 1},  {0, 2},  {0, 3},
        		  {1, -2},  {1, -1},  {1, 0},  {1, 1},  {1, 2}, 
        				    {2, -1},  {2, 0},  {2, 1}, 
        							  {3, 0}, 
    }

function guild_war_control:onCreate(  )
	-- body
	-- 初始化函数框架自动调用
	self.m_curSecond = self.m_data:getRoundEndTime();
	self:setTimer( 0 , self.onTimer );
	cclog("------------- onCreate " .. tostring(self.m_curSecond));

end

function guild_war_control:onEnter(  )
	-- body
	-- 创建view结束后调用，用来
	-- self.controlBase.onEnter( self );
	-- 添加自己代码
	self:_initWar();
	local selfUid = game_data:getUserStatusDataByKey("uid");
	self.m_view:carmWithUid(selfUid);
	self:openView("guild_little_war_pop",self.m_data.m_data);
	cclog("---------------------------- show rect ");
	self:showCanMove(selfUid);
	cclog("---------------------------- show rect ");
	self.m_view:showRound(); 		-- 显示等待
	self:openView("guild_chat");
end

function guild_war_control:onHandle( msg , data )
	-- body
	-- 消息响应函数
	-- 消息发送方法updataMsg（参考oo_controlBase）view和control中都可以直接使用
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:openView("guild_world_scene",{winer = 1 , game_id = self.m_data:getGameId()});
	elseif(msg == 3)then			-- 操作窗口
		cclog("---------------------- open click " .. tostring(self.m_warType));
		if(self.m_warType == 1)then
			local lx,ly = self.m_view:getSelfPos();
			local dl = (data.m_lx + data.m_ly) - (lx + ly);
			cclog("------------------------ 1("..lx ..","..ly..") 2(" .. data.m_lx .. "," .. data.m_ly .. ")");
			local mapData = self.m_data:getMapData(data.m_lx,data.m_ly);
			util.printf(mapData);
			if(mapData[3]~="" and not self.m_data:playerIsCampAsMe(mapData[3]))then
				data.m_flag = 1;
			else
				data.m_flag = 2;
			end
			if(dl<=3 and dl>=-3)then
				self:openView("guild_war_click",data);
			end
		end
	elseif(msg == 100)then			-- 移动点击
		-- local selfUid = game_data:getUserStatusDataByKey("uid");
		-- self.m_view:movePlayer( selfUid,data.m_x,data.m_y );
		self.m_view:showMoveLayer(false);
		self.m_view:showWart(); 		-- 显示等待
		self:closeView("guild_war_click");
		self.m_warType = 2;
		
		local outTime = CCHttpClient:getInstance():getTimeoutForRead();
		CCHttpClient:getInstance():setTimeoutForRead(40);
		cclog("---------------------- click " .. tostring(self.m_warType) .. " curS=" .. tostring(self.m_curSecond));
		local function netCallBack( netdata )
			-- body
			CCHttpClient:getInstance():setTimeoutForRead(outTime);

			self:updataMsg(10,self.m_data:getRoundNum(),"guild_little_war_pop");
			if(netdata == nil)then
				return;
			end
			self.m_curRoundData = netdata;

			for k,v in pairs(self.m_curRoundData.data.move_list) do
				v.x = v.x+1;
				v.y = v.y+1;
			end

			
			self.m_warType = 3;
			self.m_view:removeWait(); 			-- 结束等待
			self.m_data:updataFromNet(netdata);
			self.m_curSecond = self.m_data:getRoundEndTime();
			cclog("---------------------- click call " .. tostring(self.m_warType) .. " curS=" .. tostring(self.m_curSecond));
			
		end
		cclog("----------------------- net pos x=" .. tostring(data.m_x) .. " y=" .. tostring(data.m_y));
		self.m_data:getNetData(game_url.getUrlForKey("association_war_active"),{round_id=self.m_data:getRoundNum(),x=data.m_x-1,y=data.m_y-1,game_id=self.m_data:getGameId()},netCallBack,false,true);
		-- self:updataMsg(11,nil,"guild_little_war_pop");
	end
end

function guild_war_control:onTimer( dt )
	-- body
	self.m_timeLong = self.m_timeLong+dt;
	if(self.m_timeLong>1)then
		if(self.m_curSecond>0)then
			self.m_curSecond = self.m_curSecond-1;
		end
		self.m_timeLong = self.m_timeLong-1;
	end
	

	if(self.m_warType == 1)then 		-- 操作阶段
		self.m_view:setTime(self.m_curSecond);
		self.m_view:showMoveLayer(true);
		if(self.m_curSecond<=0)then 		
			local lx,ly = self.m_view:getSelfPos();
			self:updataMsg(100,{m_x=lx , m_y=ly});
			self.m_warType = 2;
		end
	elseif(self.m_warType == 2)then 		-- 操作结束等待阶段
		self.m_view:setTime(self.m_curSecond);
		self.m_view:showMoveLayer(false);
		return;
	elseif(self.m_warType == 3)then 		-- 行动阶段
		self.m_view:showMoveLayer(false);
		self:playGame();
		return;
	end


end

function guild_war_control:playGame(  )
	-- body
	if(not self.m_view:canPlay())then
		return;
	end
	local tempItem = self.m_curRoundData.data.move_list[self.m_index];
	cclog("------------------------------------------- yock index " .. tostring(self.m_index));
	util.printf(tempItem);
	cclog("------------------------------------------- yock ");
	if(tempItem~=nil)then
		if(tempItem.stand == 0)then
			local playerData = self.m_data:getPlayer(tempItem.uid);
			local tempNew = nil;
			local tempItem1 = nil;
			for i=1,3 do
				tempItem1 = self.m_curRoundData.data.move_list[self.m_index+1];
				if(tempItem1~=nil and tempItem1.stand==0 and tempItem1.uid==tempItem.uid and (tempItem1.x==playerData.x or tempItem1.y==playerData.y))then	
					self.m_index = self.m_index+1;
					tempNew = tempItem1;
					-- cclog("")
				else
					break;
				end
			end
			if(tempNew)then
				tempItem = tempNew;
			end
		end
		cclog("------------------------------------------- yock index " .. tostring(self.m_index));
		util.printf(tempItem);
		cclog("------------------------------------------- yock ");
		self.m_view:optionMoveList(tempItem);

		self.m_data:changedData(tempItem);
		-- self.m_data:changedPlayerStatus(tempItem.uid,self.m_curRoundData.data.player_status[tempItem.uid]);
		-- if(tempItem.kicked~="")then
		-- 	self.m_data:changedPlayerStatus(tempItem.kicked,self.m_curRoundData.data.player_status[tempItem.kicked]);
		-- end
	else
		
		self.m_warType = 1;
		self.m_index = 1;
		self.m_data:setRoundNum(self.m_curRoundData.data.round_num);
		cclog("---------------------- option end " .. tostring(self.m_warType));
		if(self.m_curRoundData.data.game_end == 1)then
			self:updataMsg(2);
		elseif(self.m_curRoundData.data.game_end == 2)then
			self:updataMsg(2);
		else
			self.m_data:changedAllPlayer(self.m_curRoundData.data.player_status);
			local selfUid = game_data:getUserStatusDataByKey("uid");
			self.m_view:carmWithUid(selfUid);
			self:showCanMove(selfUid);
			self.m_view:showRound();		-- 显示回合
		end
		return;
	end
	self.m_index = self.m_index+1;
end

function guild_war_control:_initWar(  )
	-- body
	local w,h = self.m_data:getMaxSize();
	for y=1,h do
		for x=1,w do
			local mapData = self.m_data:getMapData(x,y);
			if(mapData[3]~="")then
				self.m_view:createPlayer(mapData[3],x,y);
			end
			-- 创建公会战地图
			local mapId = tonumber(mapData[4]);
			if(mapId~=0)then

				if(mapId == 10 or mapId == 20)then
					cclog("---------------- create boss " .. mapId);
					self.m_data:setBossData(mapId,x,y);
					self.m_view:createBoss(mapId);
				end

				local imgName,offsetx,offsety = self.m_data:getBuildImgName(mapId);
				if(imgName ~= nil)then
					local vx,vy = self.m_view:getViewPos(x,y);
					cclog("---------------build xy " .. x .. " " .. y .. " " .. vx .. " " .. vy);
					-- self.m_view:createBuilding(imgName,vx-offsetx,vy-offsety);
					self.m_view:createBuilding(imgName,vx-0,vy-0);
				end
			end
			
		end
	end
end

function guild_war_control:showCanMove( uid )
	-- body
	-- local lx,ly = self.m_view:getPosWithUid(uid);
	self.m_view:showMoveLayer(true);
	local lx,ly = self.m_view:getSelfPos();
	cclog("--------------------- lx=" .. lx .. " ly=" .. ly);
	local temp = {};
	for k,v in pairs(self.m_moveTable) do
		cclog(" ----- " .. v[1] .. " " .. v[2]);
		local nx,ny = lx+v[1] , ly+v[2];
		cclog(" -----nn " .. nx .. " " .. ny);
		if not(nx>22 or ny>22 or nx<1 or ny<1)then
			local mdata = self.m_data:getMapData(nx,ny);
			if(mdata[3]~="" and mdata[3]~=uid)then
				cclog("------------------ " .. tostring(game_data:getUserStatusDataByKey("uid")) .. "-------" .. mdata[3]);
				if not(self.m_data:isCampAsMe(nx,ny))then
					temp[#temp+1]={nx,ny,'r'};
				end
			else
				temp[#temp+1]={nx,ny,'g'}
			end

		end

	end
	self.m_view:showMove(temp);

end







return guild_war_control;




