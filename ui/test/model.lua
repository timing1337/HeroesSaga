require "shared.extern"

local test_model = class("testModel",require("like_oo.oo_dataBase"));

function test_model:onCreate(  )
	-- body
	self:getData(  );
end

function test_model:onEnter(  )
	-- body
end


return test_model;