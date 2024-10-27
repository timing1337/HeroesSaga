require "shared.extern"

local control_base = class( "controlBase" , nil );

-- message data list
control_base.m_msg = nil;		
-- run loop with message data
control_base.m_enterId = nil;
-- map with chiled controller
control_base.m_chilrenList = {};
-- model for this control
control_base.m_data = nil;
-- view with self
control_base.m_view = nil;
-- mind perant control
control_base.m_parent = nil;
-- need save data for goBack
control_base.m_needBack = false;
-- timer list
control_base.m_timerList = {};

-- static var with root control
static_rootControl = nil;
-- static var that with histroy page list
static_pageList = require("like_oo.oo_stack"):new();

-- 
function control_base:create(  )

	-- body
	cclog("----------- control_base:create " .. self.m_data:getName());
	self.m_msg = require("like_oo.oo_msgList"):new();

	local function tick( dt )
		-- body
		-- cclog("--- control_base tick all " .. self.__cname .. " " .. tostring(dt));
		-- local temp = 1;
		for tk,tv in pairs(self.m_timerList) do
			-- cclog("------- temp " .. tostring(temp));
			-- temp = temp+1;
			tv.time = tv.time+dt;
			-- cclog("-------- control_base tick " .. self.__cname .. " " .. tostring(tv.time));
			if(tv.inter<=0)then
				tv.callFunc( self , tv.time );
				tv.time = 0;
			elseif(tv.time>=tv.inter)then
				tv.callFunc( self , tv.inter );
				tv.time = tv.time-tv.inter;
			end
		end

		local tempMsg = self.m_msg:pop();
		if(tempMsg~=nil)then
			if( tempMsg.m_msg == "oo_updata")then
				if( static_rootControl~=nil )then
					static_rootControl:onUpdata();
					for k,v in pairs(static_rootControl.m_chilrenList) do
						v:onUpdata();
					end
				end
			else
				self:onHandle( tempMsg.m_msg , tempMsg.m_data );
			end
		end
	end
	self.m_enterId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 1/60.0, false)
	self:onCreate();
	local tempType = self:createView();
	self.m_view:onEnter();
	self:onEnter();
	return tempType;
end

-- 
function control_base:destroy(  )
	-- body
	cclog("--------- destroy control " .. self.m_data:getName());
	if self.m_enterId ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_enterId);
        self.m_enterId = nil;
    end
    -- message data list
    if self.m_msg then
	    self.m_msg:cleanAll();
    end
	self.m_msg = nil;		
	-- run loop with message data
	self.m_enterId = nil;
	-- map with chiled controller
	if self.m_chilrenList then
		local childCount = #self.m_chilrenList;

		for k,v in pairs(self.m_chilrenList) do
			v:closeView();
		end
	end
	self.m_view:destroy();
	self.m_data:destroy();


	-- mind perant control
	if(self.m_parent ~= nil)then
		self.m_parent.m_chilrenList[self.m_data:getName()] = nil;
		self.m_parent = nil;
	end
	-- model for this control
	self.m_data = nil;
	-- view with self
	self.m_view = nil;
	if self.m_timerList then
		for k,v in pairs(self.m_timerList) do
			self.m_timerList[k] = nil;
		end
	end
end

-- 构造view用
function control_base:createView(  )
	-- body
	self.m_view = require("ui." .. self.m_data:getName() .. ".view"):new();
	self.m_view.m_control = self;
	local tempV = self.m_view:create();
	if(tempV~=nil)then
		local tempVT = self.m_view:getType();
		if(tempVT == 1)then
			-- changed scene
			-- display.replaceScene(tempV);
			if(static_rootControl)then
				if(static_rootControl.m_data.m_type == 1)then	-- if data type is a first flag
					if(static_rootControl.m_needBack)then
						static_pageList:addData(static_rootControl.m_data);
					end
				elseif(static_rootControl.m_data.m_type == 2)then	-- if data type is a histroy flag
					static_rootControl.m_data:destroy();
				end
				static_rootControl:destroy();
			end
			self.m_parent = nil;
			static_rootControl = self;

			self:replaceScene(tempV);
		elseif(tempVT == 2)then
			-- add pop in the control
			if(static_rootControl)then
				self.m_parent = static_rootControl;
				self:getRootWin():addChild(tempV);
				cclog("------child---- " .. self.m_data:getName() .. ".view");
				if(static_rootControl.m_chilrenList[self.m_data:getName()]~=nil)then
					local tempName = self.m_data:getName();
					tempName = tempName .. tostring(os.clock());
					self.m_data.m_name = tempName;
					static_rootControl.m_chilrenList[tempName] = self;

				else
					static_rootControl.m_chilrenList[self.m_data:getName()] = self;
				end
				
			end
		end
		return tempVT;
	end
	return nil;
end



--[[
	打开指定名字的窗口

]]
function control_base:openView( name , params )
	-- body
	fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("ui/" .. name .. "/model.lua");
	local tempHasF = util.fileIsExist(fileFullPath)
	if(tempHasF)then


		local tempname = "ui." .. name .. ".model";
		cclog("-------------- openView" .. tempname );
		local tempCls = require (tempname);
		local tempModel = tempCls:new();
		tempModel:create( name , params );
	end
end

function control_base:closeView( name )
	-- body
	if(name)then
		local tempChiled = self.m_chilrenList[name];
		if(tempChiled)then
			tempChiled:closeView();
			self.m_chilrenList[name] = nil;
		end
	else
		self:destroy();
	end
end

--[[
更新一个消息到消息队列中
msg :消息标记
data:为消息数据
flag:为数据传递标志
	 'this'   当前control消息
	 'parent' 父control消息
	 '其他'   指定名字control消息
]]
function control_base:updataMsg( msg , data , flag )
	-- body
	local temp = { m_msg = msg , m_data = data };

	if(flag == 'this' or flag == nil)then
		self.m_msg:addMsg( temp );
	elseif(flag == 'parent')then
		if(self.m_parent)then
			self.m_parent:updataMsg( msg, data , 'this' );
		else
			self.m_msg:addMsg(temp)
		end
	else
		if(static_rootControl.m_chilrenList[flag] ~= nil)then
			cclog("---------- yock chilren " .. flag);
			static_rootControl.m_chilrenList[flag]:updataMsg( msg , data , 'this' );
		else
			for k,v in pairs(static_rootControl.m_chilrenList) do
				print(k);
			end
			cclog("---------- yock no chilren " .. flag);
		end
	end

end

--[[
	发出一个更新全族消息
]]
function control_base:updataView(  )
	-- body
	if(static_rootControl~=nil)then
		static_rootControl:updataMsg("oo_updata");
	end
end

--[[
	检查是否可以回退
	返回值：true   可以返回
		   false  不可以返回
]]

function control_base:canBack(  )
	-- body
	if(static_pageList:hasData())then
		return true;
	else
		return false;
	end
end

--[[
	返回上一个页面
	从历史数据里取得最后一个压栈数据
	还原视图
]]
function control_base:goBack(  )
	-- body
	if(not self:canBack())then
		return;
	end
	local tempModel = static_pageList:pop();
	tempModel:create(tempModel.m_name);
end


--[[
	获得根窗口
	根窗口为静态变量
]]
function control_base:getRootWin(  )
	-- body
	local tempRC = self:getRootControl();
	if(tempRC ~= nil)then
		return tempRC.m_view:getRootView();
	else
		return nil;
	end
end

--[[
	得到根控制器（control）
]]
function control_base:getRootControl(  )
	-- body
	return static_rootControl;
end


--[[
	注册timer回调函数
]]
function control_base:setTimer( interval,onTimer )
	-- body
	local tempTimer = { time = 0 , inter = interval , callFunc = onTimer };
	local id = #self.m_timerList+1;
	self.m_timerList[id] = tempTimer;
	return id;
end

--[[
	移出timer回调
]]
function control_base:removeTimer( id )
	-- body
	self.m_timerList[id]=nil;
end


-- ================================= a cut of line =================================

-- 构造结束后调用

function control_base:onCreate(  )
	-- body
	cclog("------------- control onCreate " .. self.m_data:getName());
end

-- 构造结束后调用
function control_base:onEnter(  )
	-- body
	cclog("------------- control onEnter " .. self.m_data:getName());
	
end

-- 消息循环重载后使用
function control_base:onHandle( msg , data )
	-- body
end

function control_base:onUpdata(  )
	-- body
end


-- ================================= a cut of line =================================

--[[
	融合小伍框架用
	返回首页
]]
function control_base:goHome(  )
	-- body
	local function callBackFunc()
		self:destroy();
		static_rootControl = nil;
	end
	game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = callBackFunc});
end

--[[
	融合小伍框架用
	切换场景
]]
function control_base:replaceScene( scene )
	-- body
	-- local rootScene = game_scene:getGameContainer();
	-- rootScene:removeAllChildrenWithCleanup(true);
	-- rootScene:addChild(scene);
	-- local rootPop = game_scene:getPopContainer();
	-- rootPop:removeAllChildrenWithCleanup(true);
	-- game_scene.m_currentUiTab = nil;
	-- game_scene:setVisiblePropertyBar(false);
	game_scene:removeAllPop();
	game_scene:removeCurrentUi();
	local rootScene = game_scene:getGameContainer();
	rootScene:addChild(scene);
	game_scene:setVisiblePropertyBar(false);
	cclog("------------control_base:replaceScene");
end




return control_base;



