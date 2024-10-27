--- 竞技场战报
local __notice = {}
--[[--

]]
function __notice:create( t_params )
	-- body
	self.m_gameData = t_params.gameData;
	self.m_parent = t_params.parent;
	self.m_ccbNode = luaCCBNode:create();
	local layer = CCLayer:create();
	local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return true;
        end
    end

    layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    layer:setTouchEnabled(true)
	
	local function onMainBtnClick( target,event )
		-- body
		self.m_ccbNode:removeFromParentAndCleanup(true);
		self.m_ccbNode = nil;
	end

	self.m_ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	self.m_ccbNode:openCCBFile("ccb/ui_pk_detail.ccbi");
	local tempCloseBt = tolua.cast(self.m_ccbNode:objectForName("m_close_btn"),"CCControlButton");
	tempCloseBt:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
	local tempTableView = tolua.cast(self.m_ccbNode:objectForName("m_ListLayer"),"CCLayer");
	self.m_listLayer = self:createTableView(tempTableView:getContentSize());
	tempTableView:addChild(self.m_listLayer);


	layer:addChild(self.m_ccbNode);
	return layer;
end

function __notice:destroy(  )
    cclog("-----------------__notice destroy-----------------");
	-- body
	-- self.m_parent:destroy();
end

-- log
function __notice:createTableView( viewSize )
	-- body
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = #self.m_gameData.log;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            cclog("----------------------------- 1");
            local function onRelook( target,event )
            	-- body
            	cclog("---------------- onRelook be click --------------" .. tostring(self.m_curtIndex));
            	local function responseMethod(tag,gameData)
				    -- body
					game_data:setBattleType("game_pk");
        			game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
        			self:destroy();
        		end
        		local tempkey = self.m_gameData.log[self.m_curtIndex+1].battle_log;
        		network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_replay"), http_request_method.GET, {key = tempkey},"arena_replay");
            end
            local function onWeibo( target,event )
            	-- body
            	cclog("---------------- onWeibo be click ---------------");
            end
            ccbNode:registerFunctionWithFuncName("onRelook",onRelook);
            ccbNode:registerFunctionWithFuncName("onWeibo",onWeibo);
            ccbNode:openCCBFile("ccb/ui_pk_detailItem.ccbi");
            local tempRelook = tolua.cast(ccbNode:objectForName("m_relook"),"CCControlButton");
            local tempWeibo = tolua.cast(ccbNode:objectForName("m_weibo"),"CCControlButton");
            tempRelook:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);
            tempWeibo:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1);

            cclog("----------------------------- 2");
            ccbNode:setPosition(ccp(0,0));
            cell:addChild(ccbNode,10,10);
            cclog("----------------------------- 3");
        end
        if cell~=nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            cclog("----------------------------- 4");
            if ccbNode then
                local tempPlayerIcon = tolua.cast(ccbNode:objectForName("m_player_icon"),"CCSprite");
                cclog("----------------------------- 5");
                local tempBattleInfor = tolua.cast(ccbNode:objectForName("m_battle_information"),"CCLabelTTF");
                cclog("----------------------------- 6");
                tempBattleInfor:setString(tostring(self.m_gameData.log[index+1].tp));
                cclog("----------------------------- 7");
            end
        else
        	cclog("---------------new table cell have error ----" .. tostring(index));
        end
        cclog("----------------------------- 8");
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            self.m_curtIndex = index;
        end
    end
    return TableViewHelper:createGallery2(params);
end


return __notice;