require "shared.extern"

local guild_join_control = class( "guildJoinControl",require("like_oo.oo_controlBase") );

guild_join_control.m_curItem = 1;

function guild_join_control:create(  )
	-- body
	self.controlBase.create( self );
end

function guild_join_control:onEnter(  )
	-- body
	self.controlBase.onEnter( self );
	local imgName = self.m_data:getSelfIconName();
	self.m_view:setIcon( imgName );
end

function guild_join_control:onHandle( msg , data )
	if(msg == 1)then
		print( data );
	elseif(msg == 2)then
		self:goHome();
	elseif(msg == 3)then  -- 公会列表被点击
		self.m_curItem = data+1;
		local tempData = self.m_data:getGuildData(self.m_curItem);
		self:openView("guild_join_pop",tempData);
	elseif(msg == 4)then  -- 创建公会
		self:openView("guild_create_pop");
	elseif(msg == 5)then  -- 公会查找
		self:openView("guild_search_pop",self.m_data:getGuild());
	elseif(msg == 6) then -- 重新排序
		self.m_data:setGuildData(data)
		self.m_view.mode = 2
		self.m_view:refreshUi()
	elseif(msg == 7) then -- 取原来的排序
		self.m_data:setDefaultData()
		self.m_view.mode = 1
		self.m_view:refreshUi()
	end
end


return guild_join_control;