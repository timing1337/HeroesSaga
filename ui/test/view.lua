require "shared.extern"

local test_view = class("testView",require("like_oo.oo_sceneBase"));

--场景创建函数
function test_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
end

function test_view:onEnter(  )
	-- body
end

function test_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

return test_view;