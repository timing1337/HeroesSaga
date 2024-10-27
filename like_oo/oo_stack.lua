require "shared.extern"

local stack = class("stack",require("like_oo.oo_msgList"));


function addData( data )
	-- body
	if(data == nil)then
		return;
	end
	if(self.m_handle == nil)then
		self.m_handle = { d = data ,
						  n = nil  };
	else
		local temp = { d = data ,
					   n = self.m_handle };
		self.m_handle = temp;
	end
end



return stack;