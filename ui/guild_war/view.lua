require "shared.extern"

local guild_war_view = class("guildWarView",require("like_oo.oo_sceneBase"));

guild_war_view.m_ccb = nil;

guild_war_view.m_tmx = nil;
guild_war_view.m_animLayer = nil;
guild_war_view.m_canMoveLayer = nil;
guild_war_view.m_buildLayer = nil;

guild_war_view.m_ground = nil;
guild_war_view.m_time = nil;
guild_war_view.m_warNode = nil;

guild_war_view.m_startX = 1;
guild_war_view.m_startY = 1;
guild_war_view.m_isMove = false;

guild_war_view.m_warSize = {w=0,h=0};

guild_war_view.m_playerNode = {};
guild_war_view.m_bossNode = {};

guild_war_view.m_canPlay = true;

-- 活动节点数
guild_war_view.m_actionCount = 0;
-- 当前动作操作数据
guild_war_view.m_optionData = nil;
-- 动作回调
guild_war_view.m_func = nil;

-- 
guild_war_view.m_roundText = nil;





-- 场景创建函数
function guild_war_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点


	self.m_ccb = luaCCBNode:create();
	local function onButtonClick( target,event )
		-- body
		cclog("---------------------------------cut of line-----------------");
		self:updataMsg(2);
	end
	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:openCCBFile("ccb/ui_new_guild_war.ccbi");
	self.m_ground = tolua.cast(self.m_ccb:objectForName("m_ground"),"CCLabelTTF");
	self.m_time = tolua.cast(self.m_ccb:objectForName("m_time"),"CCLabelTTF");
	self.m_warNode = tolua.cast(self.m_ccb:objectForName("m_warNode"),"CCLayer");
	self.m_roundText = tolua.cast(self.m_ccb:objectForName("m_roundText"),"CCLabelBMFont");

	local function onTouch( eventType, x, y )
		-- body
		cclog("------------- eventType " .. eventType);
		if eventType == "began" then
			self.m_startX = x;
			self.m_startY = y;
			self.m_isMove = false;
            return true;    --intercept event
        elseif(eventType == "moved")then
        	local tx = x - self.m_startX;
        	local ty = y - self.m_startY;
        	if(tx>10 or tx<-10 or ty>10 or ty<-10)then
        		self.m_isMove = true;
        	end
        	if(self.m_isMove)then
        		local px,py = self.m_tmx:getPosition();
        		px = px+tx;
        		py = py+ty;
        		if(px>0)then
        			px = 0;
        		elseif(px < -self.m_warSize.w)then
        			px = -self.m_warSize.w;
        		end
        		if(py > 0)then
        			py = 0;
        		elseif(py < -self.m_warSize.h)then
        			py = -self.m_warSize.h;
        		end
        		px,py = self:getXY( px,py );
        		cclog("------ " .. tostring(px) .. "   " .. tostring(py));
        		self.m_tmx:setPosition(ccp(px,py));
        		self.m_startX = x;
        		self.m_startY = y;
        	end
        elseif(eventType == "ended")then
        	if(not self.m_isMove)then
        		-- 点击
        		local tx1,ty1 = self.m_warNode:getPosition();
        		x = x-tx1;
        		y = y-ty1;
        		local tempOp,tempX,tempY,lx,ly = self:getOptPos( x,y );
        		if(tempOp)then
        			-- tempX = tempX-tx1;
        			-- tempY = tempY-ty1;
        			self:updataMsg(3,{m_x = tempX , m_y = tempY, m_lx=lx , m_ly=ly});
        			cclog("------ya " .. '(' .. tostring(tempX) .. ',' .. tostring(tempY) .. ')');
        		else
        			cclog("------not " .. '(' .. tostring(tempX) .. ',' .. tostring(tempY) .. ')');
        		end
        	end
        end
	end
	self.m_warNode:registerScriptTouchHandler(onTouch,false, 1 ,true);
	self.m_warNode:setTouchEnabled(true);

	self.m_rootView:addChild(self.m_ccb);

	cclog("--------- yock CCTMXTiledMap create ");
	local tmxName = "building_img/" .. tostring(self.m_control.m_data:getGameId()) .. ".tmx";
	self.m_tmx = CCTMXTiledMap:create(tmxName);
	local tempMapSize = self.m_tmx:getMapSize();
	local tempTileSize = self.m_tmx:getTileSize();

	self.m_warSize.w = (tempMapSize.height * tempTileSize.width)/2;
	self.m_warSize.h = (tempMapSize.width * tempTileSize.height)/2;
	
	cclog("--------- " .. tostring(self.m_warSize.w) .. " " .. tostring(self.m_warSize.h));
	self.m_tmx:setPosition(ccp(0-(self.m_warSize.w/2),0-(self.m_warSize.h/2)));
	self.m_warNode:addChild(self.m_tmx);

	cclog("--------- yock CCTMXTiledMap end ");

	self.m_canMoveLayer = CCLayer:create();
	self.m_tmx:addChild(self.m_canMoveLayer,100);

	self.m_buildLayer = CCLayer:create();
	self.m_tmx:addChild(self.m_buildLayer,100);

	self.m_animLayer = CCLayer:create();
	self.m_tmx:addChild(self.m_animLayer,100);
end

function guild_war_view:onEnter(  )
	-- body
end

function guild_war_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_war_view:setTime( value )
	-- body
	self.m_time:setString(tostring(value));
end

function guild_war_view:getSelfPos( )
	-- body
	local suid = game_data:getUserStatusDataByKey("uid");
	local node = self.m_playerNode[suid];
	local vx,vy = node:getPosition();
	local lx,ly = self:getLogicPos(vx,vy);
	return lx,ly;
end

function guild_war_view:getPosWithUid( uid )
	-- body
	local node = self.m_playerNode[uid];
	if(node)then
		local vx,vy = node:getPosition();
		local lx,ly = self:getLogicPos(vx,vy);
		return lx,ly;
	else
		return nil;
	end
end

-- 获得可以显示的坐标点
function guild_war_view:getXY( x,y )
	-- body
	-- x 最大点为 0 ，最小点为 －self.m_warSize.w
	-- y 最大点为 0 ，最小点为 －self.m_warSize.h
	-- f() y*2+x
	local opt = {x = -self.m_warSize.w/2 , y = -self.m_warSize.h/2};
	local con = (-opt.x);
	local function lt( x,y )
		-- body
		if(((x-opt.x)+(opt.y-y)*2)<=con)then
			return x,y;
		else
			return x,opt.y-((con-(x-opt.x))/2);
		end
	end
	local function lb( x,y )
		-- body
		if(((x-opt.x)+(y-opt.y)*2)<=con)then
			return x,y;
		else
			return x,opt.y+(con-(x-opt.x))/2;
		end
	end
	local function rb( x,y )
		-- body
		if(((opt.x-x)+(y-opt.y)*2)<=con)then
			return x,y;
		else
			return x,opt.y+(con-(opt.x-x))/2;
		end
	end
	local function rt( x,y )
		-- body
		if(((opt.x-x)+(opt.y-y)*2)<=con)then
			return x,y;
		else
			return x,opt.y-((con-(opt.x-x))/2);
		end
	end
	
	if( x>opt.x and y>opt.y)then
		return lb(x,y);
	elseif( x>opt.x and y<opt.y )then
		return lt(x,y);
	elseif( x<opt.x and y>opt.y )then
		return rb(x,y);
	elseif( x<opt.x and y<opt.y )then
		return rt(x,y);
	end

end

-- 获得操作区域的中心点，4*4格操作区域
--[[
	返回值
	是否合理点
	实际点x
	实际点y
	逻辑点x
	逻辑点y
]]
function guild_war_view:getOptPos( x,y )
	-- body
	-- local toux,touy = self:getXY(x,y);
	local dw = 160;
	local dh = 80;
	local toux = math.floor(self.m_warSize.w/dw);
	local touy = math.floor(self.m_warSize.h/dh);

	local tx,ty = self.m_tmx:getPosition();
	local nx,ny = self.m_warNode:getPosition();
	local mx = -tx+x;
	local my = -ty+y;
	local w = self.m_warSize.w;
	local px = math.ceil((2*my+(w-mx)-w/2)/dw);
	local py = math.ceil((2*my+mx-w/2)/dw);
	-- 得到逻辑点
	cclog("-------getOptPos1------" .. tostring(mx) .. " " .. tostring(my));
	cclog("-------getOptPos2------" .. tostring(px) .. " " .. tostring(py));


	if(px<=0 or px>toux)then
		return false,0,0,0,0;
	end

	if(py<=0 or py>touy)then
		return false,0,0,0,0;
	end

	local rx = (dw*(py-px)+w)/2;
	local ry = (dw*py+w/2-rx)/2;
	cclog("-------getOptPos3------" .. tostring(rx) .. " " .. tostring(ry));
	-- 得到相对于m_tmx点

	return true,rx+tx+nx-dw/2+80,ry+ty+ny-dh/2,px,py;
end

-- 通过实际点获得逻辑点
function guild_war_view:getLogicPos( vx,vy )
	-- body
	local dw = 160;
	local dh = 80;
	-- local toux = math.floor(self.m_warSize.w/dw);
	-- local touy = math.floor(self.m_warSize.h/dh);

	-- local tx,ty = self.m_tmx:getPosition();
	-- local nx,ny = self.m_warNode:getPosition();
	local mx = vx;
	local my = vy;
	local w = self.m_warSize.w;
	local px = math.ceil((2*my+(w-mx)-w/2)/dw);
	local py = math.ceil((2*my+mx-w/2)/dw);
	return px,py;
end


-- 通过逻辑点获得地图点
function guild_war_view:getViewPos( lx,ly )
	-- body
	local dw = 160;
	local dh = 80;
	local w = self.m_warSize.w;
	local toux = math.floor(self.m_warSize.w/dw);
	local touy = math.floor(self.m_warSize.h/dh);

	local rx = (dw*(ly-lx)+w)/2;
	local ry = (dw*ly+w/2-rx)/2;

	return rx,ry-dh/2;
end

-- 定位逻辑点
function guild_war_view:moveToPos( lx,ly )
	-- body
	local x,y = self:getViewPos(lx,ly);
	self.m_tmx:setPosition(-x,-y);
end

-- 判断方向（x1,y1,x2,y2）
-- 创建一个角色
function guild_war_view:createPlayer( uid , x , y )
	-- body
	local playerData = self.m_control.m_data:getPlayer( uid );

	local role_detail_cfg = getConfig(game_config_field.role_detail);
    
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(playerData.role));

    if itemCfg then
        animName = itemCfg:getNodeWithKey("animation"):toStr();
    else
        animName = "role_soldier";
    end

    local function onAnimationEnd( animNode, theId,theLabelName )
    	-- body
    	
    	if(theLabelName~='xiazuo' and theLabelName~='xiayou' and theLabelName~='shangzuo' and theLabelName~='shangyou')then
    		if(string.find(theLabelName,"D") == nil and string.find(theLabelName,"F") == nil)then
    			if(string.find(theLabelName,"G"))then
    				local handle = self:getNameHandle(theLabelName);
    				animNode:playSection(handle .. "D");
    			end
    			if(theLabelName == "fuhuo")then
    				animNode:playSection("xiayouD");
    			end
    			self:onAnimationNodeActionEnd(animNode,theLabelName);
    			return;
    		end
    	end

    	animNode:playSection(theLabelName);
    end

    local animationNode = SortNode:create(animName .. ".swf.sam" , 0 , animName .. ".plist");
    animationNode:registerScriptTapHandler(onAnimationEnd);
    animationNode:playSection("shangyouD");
    self.m_playerNode[uid]=animationNode;
    local tx,ty = self:getViewPos(x,y);
    animationNode:setPosition(ccp(tx,ty));
    animationNode:setAnchorPoint(ccp(0.5,0));


    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_battle_res.plist");
    local barFile = "zd_bloodTroughOwn.png";
    if self.m_control.m_data:playerIsCampAsMe(uid) then
        barFile = "zd_bloodTroughEnemy.png";
    end
    local bar = ExtProgressTime:createWithFrameName("zd_bloodTrough.png",barFile);
    bar:setMaxValue(playerData.max_hp);
    bar:setCurValue(playerData.hp);
    local animSize = animationNode:getContentSize();
    bar:setPosition(ccp(animSize.width/2,animSize.height));
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:ignoreAnchorPointForPosition(false);
    animationNode:addChild(bar,1,10);

    local nameTTF = CCLabelTTF:create(playerData.name,"Arial-BoldMT",12);
    if not self.m_control.m_data:playerIsCampAsMe(uid) then
    	nameTTF:setColor(ccc3(255,90,90));
    end
    nameTTF:setPosition(ccp(animSize.width/2,animSize.height+15));
    animationNode:addChild(nameTTF);

    -- local test1 = SortNode:create(animName .. ".swf.sam" , 0 , animName .. ".plist");
    -- test1:playSection("shangzuo");
    -- local test2 = SortNode:create(animName .. ".swf.sam" , 0 , animName .. ".plist");
    -- test2:playSection("shangyou");
    -- local test3 = SortNode:create(animName .. ".swf.sam" , 0 , animName .. ".plist");
    -- test3:playSection("xiazuo");
    -- local test4 = SortNode:create(animName .. ".swf.sam" , 0 , animName .. ".plist");
    -- test4:playSection("xiayou");
    -- test1:registerScriptTapHandler(onAnimationEnd);
    -- test2:registerScriptTapHandler(onAnimationEnd);
    -- test3:registerScriptTapHandler(onAnimationEnd);
    -- test4:registerScriptTapHandler(onAnimationEnd);
    -- self.m_animLayer:addChild(test1);
    -- test1:setPosition(ccp(tx+20,ty));
    -- self.m_animLayer:addChild(test2);
    -- test2:setPosition(ccp(tx+40,ty));
    -- self.m_animLayer:addChild(test3);
    -- test3:setPosition(ccp(tx+60,ty));
    -- self.m_animLayer:addChild(test4);
    -- test4:setPosition(ccp(tx+80,ty));

    self.m_animLayer:addChild(animationNode);

end

-- 玩家移动到逻辑点
function guild_war_view:movePlayer( uid , x , y )
	-- body
	self.m_actionCount = self.m_actionCount+1;
	local animationNode = self.m_playerNode[uid];
	local cx,cy = animationNode:getPosition();
	local lx,ly = self:getLogicPos(cx,cy);
	local tx,ty = self:getViewPos(x,y);
	local tmxX,tmxY = self.m_tmx:getPosition();
	local newX = tmxX - (tx - cx);
	local newY = tmxY - (ty - cy);

	local moveTo = CCMoveTo:create(0.5,ccp(tx,ty));
	local moveTo1 = CCMoveTo:create(0.5,ccp(newX,newY));
	local function onMoveEnd(  )
		-- body
		local sectionName = animationNode:getCurSectionName();

		local tempName = "";
		if(string.find(sectionName,"xia") ~= nil)then
			tempName = tempName .. "xia";
		else
			tempName = tempName .. "shang";
		end
		if(string.find(sectionName,"you") ~= nil)then
			tempName = tempName .. "you";
		else
			tempName = tempName .. "zuo";
		end
		tempName = tempName .. "D";
		animationNode:playSection(tempName);
		cclog("--------------------- movePlayer end");
		self:onAnimationNodeActionEnd(animationNode,"abc");
		-- self.m_canPlay = true;
	end
	local moveEnd = CCCallFunc:create(onMoveEnd);
	local sequence = CCSequence:createWithTwoActions(moveTo,moveEnd);

	-- this is a test
	-- local colorLayer = CCLayerColor:create(ccc4(160,160,160,160),40,40);
	-- colorLayer:setAnchorPoint(ccp(0.5,0.5));
	-- colorLayer:ignoreAnchorPointForPosition(false);
	-- colorLayer:setPosition(ccp(cx,cy));
	-- self.m_animLayer:addChild(colorLayer);
	-- test over

	-- 获得方向
	local nameA,nameD = self:judgmentDirection(lx,ly,x,y);
	cclog("------------------------ movePlayer " .. nameA);
	animationNode:playSection(nameA);

	animationNode:runAction(sequence);
	self.m_tmx:runAction(moveTo1);
end

-- 摄像头移动到玩家点上
function guild_war_view:carmWithUid( uid )
	-- body
	local curNode = self.m_playerNode[uid];
	if(curNode~=nil)then
		cclog("-------------- cut of line --------------");
		local x,y = curNode:getPosition();
		self.m_tmx:setPosition(ccp(-x,-y));
	end
end

--[[
stand 状态码


stand_move			0	正常移动
stand_move_monster	1	移动，怪战斗，怪死
stand_move_defender	2	移动，战斗，敌方死亡
stand_standing		3	站着
stand_error_move	4	原地
stand_all_teammate	5	原地
stand_dead			6	死亡
stand_dead_moster	7	移动，怪战斗，死亡
stand_dead_defender	8	移动，战斗，死亡
stand_resurrect		9	复活
stand_resurrect_and_killed	10	想复活，结果被复活点的敌人或者怪杀死
stand_resurrect_and_alive 	11	复活，战斗，敌方死亡
stand_attack_base_fail		12	攻打boss boss未死 玩家未死
stand_attack_base_dead		13	攻打boss boss未死 玩家死
stand_attack_base_win		14	攻打boss boss死	游戏结束
]]


function guild_war_view:optionMoveList( listItem )
	-- body
	if(not self.m_canPlay)then
		return false;
	end
	cclog("---------------------------- optionMoveList ");
	self.m_canPlay = false;
	self.m_optionData = listItem;
	-- 得到玩家当前数据
	local tempPlayer = self.m_control.m_data:getPlayer(listItem.uid);
	-- 获得当前移动玩家节点
	local tempSelf = self.m_playerNode[listItem.uid];
	-- 得到敌方玩家节点,有可能为空
	local tempOther = self.m_playerNode[listItem.kicked];
	-- 得到目的点
	local lx = listItem.x;
	local ly = listItem.y;
	-- 得到移动玩家当前点
	local clx = tempPlayer.x;
	local cly = tempPlayer.y;

	-- 锁定当前镜头点
	self:carmWithUid(listItem.uid);

	-- 得到当前的操作码
	local tempStand = listItem.stand;
	-- 执行操作
	-- local AactionName,DactionName = self:judgmentDirection(clx,cly,lx,ly);
	-- if(actionName ~= nil)then
	
		if(tempStand == 0)then 			-- 移动
			-- tempSelf:playSection(AactionName);
			self:_actionMovePlayer(listItem.uid,lx,ly);
		elseif(tempStand == 1)then 		-- 移动，怪战斗，怪物死
			-- tempSelf:playSection(AactionName);
			self:_actionMovePlayer(listItem.uid,lx,ly);
			self:_actionFightMonster();
			self:_actionDeathMonster(lx,ly);
			self:_actionChangedHp(listItem.uid,listItem.attacker_hp);
		elseif(tempStand == 2)then 		-- 战斗，敌方死，移动，
			-- tempSelf:playSection(AactionName);
			self:_actionAttackPlayer(listItem.uid,listItem.kicked);
			self:_actionChangedHp(listItem.kicked,0);
			self:_actionChangedHp(listItem.uid,listItem.attacker_hp);
			self.m_func = {func=function( ... )
				-- body
				self:_actionDefensePlayer();
				self:_actionDeathPlayer(listItem.kicked);
				self.m_func = {func=function( ... )
					-- body
					self:_actionMovePlayer(listItem.uid,lx,ly);
				end}
			end}
			
		elseif(tempStand == 3)then 		-- 原地不动
			self.m_canPlay = true;
		elseif(tempStand == 4)then 		-- 原地不动
			self.m_canPlay = true;
		elseif(tempStand == 5)then 		-- 原地不动
			self.m_canPlay = true;
		elseif(tempStand == 6)then 		-- 死亡
			self:_actionDeathPlayer(listItem.uid);
			self:_actionChangedHp(listItem.uid,0);
		elseif(tempStand == 7)then 		-- 移动，怪战斗，死亡
			self:_actionMovePlayer(listItem.uid,lx,ly);
			self:_actionFightMonster();
			self:_actionDeathPlayer(listItem.uid);
			self:_actionChangedHp(listItem.uid,0);
		elseif(tempStand == 8)then 		-- 战斗，死亡
			self:_actionAttackPlayer(listItem.uid,listItem.kicked);
			self:_actionChangedHp(listItem.uid,0);
			self:_actionChangedHp(listItem.kicked,listItem.defender_hp);
			self.m_func = {func = function( ... )
				-- body
				self:_actionDefensePlayer();
				self:_actionDeathPlayer(listItem.uid);
				self:_actionStop(listItem.kicked);
			end}
		elseif(tempStand == 9)then 		-- 复活
			self:_actionLife(listItem.uid,lx,ly);
			self:_actionChangedHp(listItem.uid,listItem.attacker_hp);
		elseif(tempStand == 10)then 	-- 复活，战斗，死亡
			self:_actionLife();
			self:_actionAttackPlayer(listItem.uid,listItem.kicked);
			self:_actionChangedHp(listItem.uid,1000);
			self.m_func = {func=function( ... )
				-- body
				self:_actionDefensePlayer();
				self:_actionDeathPlayer(listItem.uid);
				self:_actionStop(listItem.kicked);
				self:_actionChangedHp(listItem.uid,0);
				self:_actionChangedHp(listItem.kicked,listItem.defender_hp);
			end}
			
		elseif(tempStand == 11)then 	-- 复活，战斗，敌方死亡
			self:_actionLife();
			self:_actionAttackPlayer(listItem.uid,listItem.kicked);
			self:_actionChangedHp(listItem.uid,listItem.attacker_hp);
			self:_actionChangedHp(listItem.kicked,0);
			self.m_func = {func=function( ... )
				-- body
				self:_actionDefensePlayer();
				self:_actionDeathPlayer(listItem.kicked);
				self:_actionStop(listItem.uid);
			end}
		elseif(tempStand == 12)then 	-- 打boss boss未死 玩家未死
			self:_actionAttackBoss( listItem.uid , listItem.kicked );
			self:_actionChangedBossHp( listItem.kicked , listItem.defender_hp );
			self:_actionChangedHp( listItem.uid , listItem.attacker_hp );
		elseif(tempStand == 13)then 	-- 打boss boss未死 玩家死
			self:_actionAttackBoss( listItem.uid , listItem.kicked );
			self:_actionChangedBossHp( listItem.kicked , listItem.defender_hp );
			self:_actionChangedHp( listItem.uid , 0 );
			self.m_func = {func=function( ... )
				-- body
				self:_actionDeathPlayer(listItem.uid);
			end}
		elseif(tempStand == 14)then 	-- 打boss boss死 玩家未死
			self:_actionAttackBoss( listItem.uid , listItem.kicked );
			self:_actionChangedBossHp( listItem.kicked , 0 );
			self:_actionChangedHp( listItem.uid , listItem.attacker_hp );
			self.m_func = {func=function( ... )
				-- body
				self:_actionDeathBoss(listItem.kicked);
			end}
		else
			-- tempSelf:playSection(AactionName);
			cclog("------------------- a");
			-- self:movePlayer(listItem.uid,lx,ly);
		end

	-- else
		-- cclog("------------------- b");
	-- end


	-- if(tempOther ~= nil)then
	-- 	self:movePlayer(listItem.uid,lx,ly);
	-- else
	-- 	self:movePlayer(listItem.uid,lx,ly);
	-- end

	return true;
end
-- ---------------------------------- the beatch cut of line ------------------------------
-- 移动函数
function guild_war_view:_actionMovePlayer( uid, lx , ly )
	-- body
	cclog("------------ _actionMovePlayer " .. uid)
	self:movePlayer(uid,lx,ly);
	self:updataMsg(3,{uid = uid , x=lx , y = ly},"guild_little_war_pop");
end
-- 怪死亡函数
function guild_war_view:_actionDeathMonster( lx,ly )
	-- body
end
-- 玩家死亡函数
function guild_war_view:_actionDeathPlayer( uid )
	-- body
	self:updataMsg(4,{uid = uid},"guild_little_war_pop");
	cclog("----------- _actionDeathPlayer " .. uid)
	local tempNode = self.m_playerNode[uid];
	local acname = tempNode:getCurSectionName();
	acname = self:getNameHandle(acname);
	self:playSection(tempNode,acname .. "S");
end
-- 怪战斗
function guild_war_view:_actionFightMonster( lx,ly )
	-- body

end
-- 攻击函数
function guild_war_view:_actionAttackPlayer( uid,duid )
	-- body
	cclog("------------- _actionAttackPlayer " .. uid .. " " .. duid)
	local anode = self.m_playerNode[uid];
	local dnode = self.m_playerNode[duid];
	local ax,ay = anode:getPosition();
	local dx,dy = anode:getPosition();
	local lax,lay = self:getLogicPos(ax,ay);
	local ldx,ldy = self:getLogicPos(dx,dy);
	local aname,dname = self:judgmentDirection(lax,lay,ldx,ldy);
	self:playSection(anode,aname .. "G");
	self:playSection(dnode,aname .. "F");
end
-- 被攻击函数
function guild_war_view:_actionDefensePlayer( uid )
	-- body
end
-- 站着不动
function guild_war_view:_actionStop( uid )
	-- body
	cclog("------------- _actionStop " .. uid);
	local node = self.m_playerNode[uid];
	local name = node:getCurSectionName();
	name = self:getNameHandle(name);
	self:playSection(node,name .. "D");
end
-- 复活函数
function guild_war_view:_actionLife( uid,lx,ly )
	-- body
	self:updataMsg(5,{uid=uid , x=lx , y=ly },"guild_little_war_pop");
	cclog("-------------- _actionLife " .. uid)
	local anode = self.m_playerNode[uid];
	local vx,vy = self:getViewPos(lx,ly);
	anode:setPosition(ccp(vx,vy));
	anode:setVisible(true);
	self:carmWithUid(uid);
	self:playSection(anode,"fuhuo");
	
end
-- 更新血量
function guild_war_view:_actionChangedHp( uid,value )
	-- body
	local animNode = self.m_playerNode[uid];
	local hpBar = tolua.cast(animNode:getChildByTag(10),"ExtProgressTime");
	hpBar:setCurValue(value);
end

-- 攻击boss
function guild_war_view:_actionAttackBoss( uid,bossUid )
	-- body
	local bossData = self.m_control.m_data:getBossData(bossUid);
	local anode = self.m_playerNode[uid];
	local bnode = self.m_bossNode[bossUid];

	local vax,vay = anode:getPosition();
	local lax,lay = self:getLogicPos(vax,vay);

	local aname = anode:getCurSectionName();
	aname = self:getNameHandle(aname);

	self:playSection(anode,aname .. "G");
end

-- boss减血
function guild_war_view:_actionChangedBossHp( bossUid,value )
	-- body
	cclog("------- _actionChangedBossHp " .. bossUid);
	util.printf(self.m_bossNode);
	local bnode = self.m_bossNode[bossUid];
	bnode:setCurValue(value);
end

-- boss死亡
function guild_war_view:_actionDeathBoss( bossUid )
	-- body
	local bnode = self.m_bossNode[bossUid];
	bnode:setCurValue(0);
end

-- ========================================= the lovely cut of line ====================================

function guild_war_view:canPlay(  )
	-- body
	return self.m_canPlay;
end

function guild_war_view:getNameHandle( acname )
	-- body
	local tempName = "";
	if(string.find(acname,"shang"))then
		tempName = tempName .. "shang";
	else
		tempName = tempName .. "xia";
	end
	if(string.find(acname,"zuo"))then
		tempName = tempName .. "zuo";
	else
		tempName = tempName .. "you";
	end
	return tempName;
end

-- --------------------------------- a cut of line --------------------------------------

-- 判断方向
function guild_war_view:judgmentDirection( x1,y1,x2,y2 )
	-- body
	local ACname = "";
	local DCname = "";
	-- if(y2>y1)then
	-- 	ACname = ACname .. "shang";
	-- 	DCname = DCname .. "xia";
	-- else
	-- 	ACname = ACname .. "xia";
	-- 	DCname = DCname .. "shang";
	-- end
	-- if(x2>x1)then
	-- 	ACname = ACname .. "zuo";
	-- 	DCname = DCname .. "you";
	-- else
	-- 	ACname = ACname .. "you";
	-- 	DCname = DCname .. "zuo";
	-- end
	if(x2>x1)then
		ACname = "shangzuo";
		DCname = "xiayou";
	elseif(x2<x1)then
		ACname = "xiayou";
		DCname = "shangzuo";
	elseif(y2>y1)then
		ACname = "shangyou";
		DCname = "xiazuo";
	elseif(y2<y1)then
		ACname = "xiazuo";
		DCname = "shangyou";
	else
		ACname = "xiayou";
		DCname = "shangzuo";
	end

	return ACname,DCname;
	-- return ACname,DCname;
end

-- 记录动作，移动和待机不用
function guild_war_view:playSection( animNode,labelName )
	-- body
	animNode:playSection(labelName);
	if(string.find(labelName,"G") or string.find(labelName,"S") or string.find(labelName,"T") or string.find(labelName,"N"))then
		self.m_actionCount = self.m_actionCount+1;
	end
	
end

-- 关键动作完成后的回调函数
function guild_war_view:onAnimationNodeActionEnd( animNode,labelName )
	-- body
	self.m_actionCount = self.m_actionCount-1;
	if(string.find(labelName,"S"))then
		-- 死亡结束
		animNode:getParent():setVisible(false);
	elseif(string.find(labelName,"G"))then
		-- 攻击结束

	elseif(string.find(labelName,"T"))then
		-- 死亡2结束
		animNode:getParent():setVisible(false);
	elseif(string.find(labelName,"N"))then
		-- 死亡3结束
		animNode:getParent():setVisible(false);
	end

	if(self.m_func ~= nil)then
		local tempF = self.m_func;
		self.m_func = nil;
		tempF.func(tempF.params,animNode,labelName);
	end
	cclog("---------------- onAnimationNodeActionEnd " .. labelName .. "  " .. tostring(self.m_actionCount));
	if(self.m_actionCount<=0)then
		cclog("-------------- canPlay aa")
		self.m_canPlay = true;
	end
end

function guild_war_view:showMove( param )
	-- body
	self.m_canMoveLayer:removeAllChildrenWithCleanup(true);
	cclog("-------------- showMove ");
	util.printf(param);
	cclog(" ----------- showMove ");
	for k,v in pairs(param) do
		local tempRect = CCSprite:createWithSpriteFrameName("white_rect.png");
		if(v[3] == 'g')then 		-- 绿色块
			tempRect:setColor(ccc3(0,255,255));
		else 						-- 红色块
			tempRect:setColor(ccc3(255,0,0));
		end
		tempRect:setOpacity(150);
		local vx,vy = self:getViewPos(v[1],v[2]);
		tempRect:setPosition(ccp(vx,vy));
		self.m_canMoveLayer:addChild(tempRect);
	end
end

function guild_war_view:showMoveLayer( isShow )
	-- body
	self.m_canMoveLayer:setVisible(isShow);
end

function guild_war_view:createBuilding( imgName , lx , ly )
	-- body
	local build = CCSprite:create("building_img/" .. imgName);
	if(build)then
		build:setPosition(ccp(lx,ly));
		self.m_buildLayer:addChild(build);
	else
		cclog("--------- createBuilding error " .. imgName);
	end
end

function guild_war_view:createBoss( id )
	-- body
	local bossUid = ""
	if(id == 10)then
		bossUid = 'base_1';
	elseif(id == 20)then
		bossUid = 'base_2';
	end

	local bossData = self.m_control.m_data:getBossData(bossUid);

	util.printf(bossData);


	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_battle_res.plist");
	local barFile = "zd_bloodTroughOwn.png";
    if self.m_control.m_data:bossIsCampAsMe(bossUid) then
        barFile = "zd_bloodTroughEnemy.png";
    end

    local bar = ExtProgressTime:createWithFrameName("zd_bloodTrough.png",barFile);
    local vx,vy = self:getViewPos(bossData.m_x,bossData.m_y);
    bar:setAnchorPoint(ccp(0.5,0.5));
    bar:setPosition(ccp(vx,vy+80));
    bar:setMaxValue(bossData.m_maxhp);
    bar:setCurValue(bossData.m_hp);
    self.m_buildLayer:addChild(bar,10,100);

	self.m_bossNode[bossUid] = bar;
end

function guild_war_view:showRound(  )
	self.m_roundText:setString(tostring(self.m_control.m_data:getRoundNum()))
	self.m_ground:setString("第 " .. tostring(self.m_control.m_data:getRoundNum()) .. " 回合");
	self.m_ccb:runAnimations("round");
end

function guild_war_view:showWart(  )
	self.m_ccb:runAnimations("wait start");
end

function guild_war_view:removeWait(  )
	self.m_ccb:runAnimations("wait end");
end



return guild_war_view;



