require "shared.extern"

local msg_list = class("msgList",nil);

msg_list.m_handle = nil;
msg_list.m_last = nil;

function msg_list:addMsg( data )
	-- body
	if(data == nil)then
		return;
	end
	if(self.m_handle == nil)then
		self.m_handle = { d = data ,
						  n = nil  };
		self.m_last = self.m_handle;
	else
		local temp = { d = data ,
					   n = nil };
		self.m_last.n = temp;
		self.m_last = self.m_last.n ;
	end

end

function msg_list:pop(  )
	-- body
	if(self.m_handle == nil)then
		return nil;
	end
	local data = self.m_handle.d;
	self.m_handle = self.m_handle.n;
	return data;
end

function msg_list:hasData(  )
	-- body
	if( self.m_handle == nil )then
		return false;
	else
		return true;
	end
end

function msg_list:cleanAll(  )
	-- body
	self.m_handle = nil ;
	self.m_last = nil ;
end

return msg_list;