--兑换
local game_exchange_pop = 
{
	m_list_view_bg = nil,
	m_tableView = nil,
	m_curPage = nil,
	m_tGameData = nil,
	m_root_layer = nil ,
	m_node_itemsbg = nil ,
};

function game_exchange_pop:destroy()
	cclog("-----------------game_exchange_pop destroy------------------------------");
	self.m_list_view_bg = nil;
	self.m_tableView = nil ;
	self.m_curPage = nil ;
	self.m_tGameData = nil;
	self.m_root_layer = nil ;
	self.m_node_itemsbg = nil ;
end

function game_exchange_pop:back(backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:removePopByName("game_exchange_pop");
       -- game_scene:enterGameUi("game_exchange_scnen2",{gameData = nil},{endCallFunc = endCallFunc});
end

--[[--
	
]]

function game_exchange_pop:createUi()
	local size = CCDirector:sharedDirector():getWinSize();
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event)
		local tagNode = tolua.cast(target,"CCNode");
		local btnTag = tagNode:getTag();
		if btnTag == 1 then --关闭
			cclog("-----------------game_exchange_pop close------------------------------");
			self:back()
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/game_exchange_pop2.ccbi");
	self.m_node_itemsbg = ccbNode:nodeForName("m_node_itemsbg");
	self.m_root_layer = ccbNode:layerForName("m_root_layer");
	local m_close_btn = ccbNode:controlButtonForName("CCNode");
	m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
	local function onTouch( eventType, x , y )
		if eventType == "began"	then
			return true ;
		end-- body
	end
	self.m_root_layer:registerScriptTouchHandler(onTouch, false , GLOBAL_TOUCH_PRIORITY - 3, true); --registerFunctionWithFuncName
	self.m_root_layer:setTouchEnabled(true);
	
	return ccbNode;
	
end
function game_exchange_pop.createItemsTabelView(self, viewSize)
	if viewSize == nil then
    	return
    end
	local  itemCfg = self.m_tGameData ;
	local need_item_count = nil ;
	if itemCfg then
		-- cclog("-----------------itemCfg ------------------------------"  .. json.encode(itemCfg) );
		local need_item = itemCfg["need_item"] ;
		-- cclog("-----------------need_item ------------------------------"  .. json.encode(need_item));
		need_item_count = #need_item or 0 ;
		need_item_count = 5 - need_item_count ;
	end
    local totalItem = need_item_count or 0 ;
    local columncount = need_item_count ;
   
    local params = {};
    params.viewSize = viewSize;
    params.row = 1; -- 行
    params.column = columncount; -- 列
    params.totalItem = totalItem  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage; -- 分页
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-2;
    local itemSize = CCSizeMake( viewSize.width/params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog(" new index ===================  " .. index)
            cell = CCTableViewCell:new()
            cell:autorelease()
        -- body
        end
        if cell then  -- 更新cell的内容
            cell:removeAllChildrenWithCleanup(true)
            local  out_item = itemCfg["out_item" .. (index + 1)] ;
            -- cclog("-----------------out_item ------------------------------"  .. json.encode(out_item));
            local icon,name,count,rewardType = game_util:getRewardByItemTable(json.decode(out_item[1]));
             -- cclog("-----------------123122 ------------------------------");
            if icon then
                icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                -- 发光
                local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                if board then
                    board:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
                    cell:addChild(board)
                end
                if  name then
                    -- local blabelName = game_util:createLabelBMFont({text = tostring(name)})
                    local blabelName = game_util:createLabelTTF({text = tostring(name)})
                    blabelName:setAnchorPoint(ccp(0.5, 1))
                    blabelName:setPosition(itemSize.width * 0.5,  itemSize.height*0.2)
                    cell:addChild(blabelName)
                end
                cell:addChild(icon)
            else
            	cclog("meiyouzhiyuan ---- no icon")
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
    
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end
function game_exchange_pop.refreshUi(self)
    self.m_node_itemsbg:removeAllChildrenWithCleanup( true )
    cclog("-----------------self.m_node_itemsbg ------------------------------"  .. tostring(self.m_node_itemsbg));
    local tableview = self:createItemsTabelView( self.m_node_itemsbg:getContentSize())
    if tableview == nil then return end
    tableview:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1 );
    self.m_node_itemsbg:addChild(tableview)

end

function game_exchange_pop:init(t_params)
	self.m_tGameData = t_params or {};
	-- self.m_tGameData = json.encode(dataparams);
end
function game_exchange_pop:create(t_params)
	print("game_exchange_pop---create");
	self:init(t_params);
	local scene = CCScene:create();
	scene:addChild(self:createUi());
	--self:refreshUi();
	return scene;
end
return game_exchange_pop;