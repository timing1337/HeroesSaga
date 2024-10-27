require "shared.extern"

local data_base = class( "dataBase" , nil );

data_base.m_netWork = require("shared.network");
data_base.m_control = nil;				-- the handle with frame's control
data_base.m_name = nil;					-- the frame name
data_base.m_data = nil;					-- nomorl data with net or native
data_base.m_params = nil;				-- the frame's params that control function openViews second param
-- 1 is a first data
-- 2 is a histroy data for back to
data_base.m_type = 1;

--[[
异／同步方法，获得getData获得的数据
data : type is lua table
]]
function data_base:callBack( data )
	-- body
	self.m_data = data;
	local tempControl = require("ui." .. self.m_name .. ".control"):new();
	tempControl.m_data = self;
	self:onEnter();
	tempControl:create();
	self.m_control = tempControl;
	-- util.printf( data );
end


--[[
根据key得到数据，
key ＝ "http://"开头时，是网络数据,否则为本地数据
params_ 为网络请求参数，可以没有
]]
function data_base:getData( key , params_ )
	-- body
	if( self.m_data~=nil )then
		self:callBack( self.m_data );
		return;
	end
	if(key~=nil and string.find( key , "http://"))then
		local function responseMethod(tag,gameData)
            local data = require("shared.json").decode(gameData:getFormatBuffer());
            self:callBack( data );
        end
		self.m_netWork.sendHttpRequest( responseMethod , key , http_request_method.GET , params_ , key );
	else
		if(key==nil)then
			self:callBack(nil);
		else
			local data = getConfig( key );
			if(data~=nil)then
				data = require("shared.json").decode(data:getFormatBuffer());
				self:callBack( data );
			else
				self:callBack( nil );
			end
		end
	end
end

-- 获得本地数据，没有回调
function data_base:getNativeData( key )
	-- body
	local tempData = getConfig( key );
	if(tempData)then
		tempData = require("shared.json").decode(tempData:getFormatBuffer());
	end
	return tempData;
end

-- 获取网络数据，有回调
function data_base:getNetData( key , params_ , callfunc , loadingFlag, retrunFlag)
	-- body
	cclog("----- data_base:getNetData --- " .. key);
	local function responseMethod(tag,gameData)
		if(gameData ~= nil)then
        	local data = require("shared.json").decode(gameData:getFormatBuffer());
        	if(callfunc)then
       			callfunc( data );
       		end
       	else
       		if(callfunc)then
    			callfunc(nil);
        	end
        end
    end

    if(loadingFlag == nil or loadingFlag == true)then
		self.m_netWork.sendHttpRequest( responseMethod , key , http_request_method.GET , params_ , key ,loadingFlag , retrunFlag);
	else
		cclog("---------------- noloading ");
		self.m_netWork.sendHttpRequest( responseMethod , key , http_request_method.GET , params_ , "guild_noLoading" ,loadingFlag , retrunFlag);
	end
end


-- 获得当前view框架名字
function data_base:getName(  )
	-- body
	return self.m_name;
end

--[[
data_base默认启动接口
]]
function data_base:create( name , params )
	-- body
	self.m_name = name;
	self.m_params = params;
	-- add yourself code getData
	self:onCreate();
end

--[[
默认销毁接口
]]
function data_base:destroy(  )
	-- body
	cclog("----------- destroy model " .. self:getName());
end

-- ============================================ a little cut of line ================================

function data_base:onCreate(  )
	-- body
	cclog("------------------ model onCreate " .. self.m_name);
end

function data_base:onEnter(  )
	-- body
	cclog("------------------ model onEnter " .. self.m_name);
end


return data_base;