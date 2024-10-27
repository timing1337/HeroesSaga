require "shared.extern"

local guild_little_war_pop_view = class("guildLittleWarPopView",require("like_oo.oo_popBase"));

guild_little_war_pop_view.m_ccb = nil;
guild_little_war_pop_view.m_tmx = nil;
guild_little_war_pop_view.m_player = {};

guild_little_war_pop_view.m_bg = nil;
guild_little_war_pop_view.m_fight = nil;
guild_little_war_pop_view.m_roundNum = nil;

--场景创建函数
function guild_little_war_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	self.m_ccb:openCCBFile("ccb/pop_guild_small_fight.ccbi");

	-- self.m_bg = tolua.cast(self.m_ccb:objectForName("m_bg"),"CCSprite");
	self.m_fight = tolua.cast(self.m_ccb:objectForName("m_fight"),"CCLayer");
	self.m_roundNum = tolua.cast(self.m_ccb:objectForName("m_roundText"),"CCLabelBMFont");




	self.m_tmx = CCTMXTiledMap:create("building_img/small_guild_fight1.tmx");
	self.m_title_round = self.m_tmx:layerNamed("title_round");
	self.m_tmx:setAnchorPoint(ccp(0.5,0.5));
	self.m_fight:addChild(self.m_tmx);

	-- local ground = self.m_tmx:objectGroupNamed("object");
	-- local tempGround1 = ground:objectNamed("m_home1");
	-- local tempHome1x = tempGround1:valueForKey('x'):floatValue();
	-- local tempHome1y = tempGround1:valueForKey('y'):floatValue();

	local tempHome1x,tempHome1y = self:_getPosWithLogic(21,3);
	cclog("--------- home1 " .. tempHome1x .. "  " .. tempHome1y);

	-- local tempGround2 = ground:objectNamed("m_home2");
	-- local tempHome2x = tempGround2:valueForKey('x'):floatValue();
	-- local tempHome2y = tempGround2:valueForKey('y'):floatValue();
	local tempHome2x,tempHome2y = self:_getPosWithLogic(2,22);
	cclog("--------- home2 " .. tempHome1x .. "  " .. tempHome1y);

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/guild_sf_res.plist");

	local home1 = CCSprite:createWithSpriteFrameName(self.m_control.m_data:getLeft());
	home1:setPosition(ccp(tonumber(tempHome1x),tonumber(tempHome1y)));
	self.m_tmx:addChild(home1);

	local home2 = CCSprite:createWithSpriteFrameName(self.m_control.m_data:getRight());
	home2:setPosition(ccp(tostring(tempHome2x),tostring(tempHome2y)));
	self.m_tmx:addChild(home2);

	self.m_rootView:addChild(self.m_ccb);
end

function guild_little_war_pop_view:onEnter(  )
	-- body
end

function guild_little_war_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_little_war_pop_view:_getPosWithLogic( lx,ly )
	-- body
	lx = 22 - lx;
	ly = 22 - ly;
	local pos = self.m_title_round:positionAt(ccp(lx,ly));
	return pos.x , pos.y;
end

function guild_little_war_pop_view:createPlayer( uid,camp,lx,ly )
	-- body
	local ccb = luaCCBNode:create();
	ccb:openCCBFile("ccb/pop_guild_smail_player.ccbi");

	local tempSelf = tolua.cast(ccb:objectForName("m_self"),"CCSprite");
	local tempOther = tolua.cast(ccb:objectForName("m_other"),"CCSprite");
	local tempFriend = tolua.cast(ccb:objectForName("m_friend"),"CCSprite");

	if(camp == 's')then
		-- 自己
		tempOther:setVisible(false);
		tempFriend:setVisible(false);
	elseif(camp == 'f')then
		-- 队友
		tempSelf:setVisible(false);
		tempOther:setVisible(false);
	else
		-- 敌人
		tempSelf:setVisible(false);
		tempFriend:setVisible(false);
	end
	local vx,vy = self:_getPosWithLogic(lx,ly);
	ccb:setPosition(ccp(vx,vy));
	self.m_tmx:addChild(ccb);
	self.m_player[uid] = ccb;
end

function guild_little_war_pop_view:birth( uid,lx,ly )
	-- body
	local vx,vy = self:_getPosWithLogic(lx,ly);
	self.m_player[uid]:setPosition(ccp(vx,vy));
	self.m_player[uid]:runAnimations("birth");
end

function guild_little_war_pop_view:moveTo( uid,lx,ly )
	-- body
	local vx,vy = self:_getPosWithLogic(lx,ly);
	local node = self.m_player[uid];
	node:runAction(CCMoveTo:create(0.5,ccp(vx,vy)));
	node:runAnimations("move");
end

function guild_little_war_pop_view:death( uid )
	-- body
	local node = self.m_player[uid];
	node:runAnimations("death");
end

function guild_little_war_pop_view:smallOrBig( s_or_b )
	-- body
	if(s_or_b)then
		
		-- local function animFunc( animName )
			-- body
		-- 	if(animName == "round")then
		-- 		self.m_ccb:setScale(0.4);
		-- 		-- self.m_bg:setVisible(false);
		-- 		local size = CCDirector:sharedDirector():getWinSize();
		-- 		self.m_ccb:setPosition(ccp(size.width-size.width/5*2+30 , size.height-size.height/5*2+20));
		-- 		self:consumeTouch(false);
		-- 	end
		-- end
		-- self.m_ccb:registerAnimFunc(animFunc);
		-- self.m_ccb:runAnimations("round");
			self.m_ccb:setScale(0.4);
			-- self.m_bg:setVisible(false);
			local size = CCDirector:sharedDirector():getWinSize();
			self.m_ccb:setPosition(ccp(size.width-size.width/5*2+30 , size.height-size.height/5*2+20));
			self:consumeTouch(false);
	else
		self.m_ccb:setScale(1);
		-- self.m_bg:setVisible(false);
		self.m_ccb:setPosition(ccp(0,0));
		self:consumeTouch(false);
		-- self.m_ccb:runAnimations("wait")

	end
end

function guild_little_war_pop_view:setRoundNum( num )
	-- body
	self.m_roundNum:setString(num);
end

return guild_little_war_pop_view;


