--- gvg分配奖励   选人
local game_gvg_allot_people_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    
    att_btn = nil,
    def_btn = nil,
    m_open_btn = nil,
    rank_node = nil,
    log_node = nil,

    btn_back = nil,
    reward_node = nil,
    log_node = nil,

    players = nil,
    itemKey = nil,
};
--[[--
    销毁
]]
function game_gvg_allot_people_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_allot_people_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    
    self.att_btn = nil;
    self.def_btn = nil;
    self.m_open_btn = nil;
    self.rank_node = nil;
    self.log_node = nil;

    self.btn_back = nil;
    self.reward_node = nil;
    self.log_node = nil;

    self.players = nil;
    self.itemKey = nil;
end
--[[--
    返回
]]
function game_gvg_allot_people_pop.back(self,type)
    game_scene:removePopByName("game_gvg_allot_people_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_allot_people_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_allot_people.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")

    self.content_node = ccbNode:nodeForName("content_node")

    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-14)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-13,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[
    
]]
function game_gvg_allot_people_pop.createLogTable(self,viewSize)
    local players = self.players
    local idTable = {}
    for k,v in pairs(players) do
        table.insert( idTable, k )
    end
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " ..btnTag)

    end
    local tabCount = game_util:getTableLen(players)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 3; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = tabCount
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-14;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_gvg_allot_people_item.ccbi");
            -- ccbNode:controlButtonForName("m_ok_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-15)
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local m_anim_node = ccbNode:nodeForName("m_anim_node")
            local name_label = ccbNode:labelTTFForName("name_label")
            local m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
            game_util:setCCControlButtonTitle(m_ok_btn,string_helper.ccb.text211)

            m_ok_btn:setTag(index)

            m_anim_node:removeAllChildrenWithCleanup(true)

            local key = idTable[index+1]
            local itemData = players[tostring(key)]

            local name = itemData.name
            name_label:setString(name)
            local role = itemData.role or 1
            local icon = game_util:createPlayerIconByRoleId(tostring(role));
            local icon_alpha = game_util:createPlayerIconByRoleId(tostring(role));
            if icon then
                m_anim_node:removeAllChildrenWithCleanup(true);
                icon_alpha:setAnchorPoint(ccp(0.5,0.5))
                icon_alpha:setPosition(ccp(7,4))
                icon_alpha:setOpacity(100)
                icon_alpha:setColor(ccc3(0,0,0))
                icon_alpha:setScale(0.9)
                m_anim_node:addChild(icon_alpha)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(5,5))
                icon:setScale(0.9)
                m_anim_node:addChild(icon);
            else
                cclog("tempFrontUser.role " .. role .. " not found !")
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            cclog2(index,"index")
        local uid = idTable[index+1]
        local function responseMethod(tag,gameData)
            game_scene:addPop("game_gvg_allot_pop",{gameData = gameData,players = self.players})
            self:back()
            game_util:addMoveTips({text = string_helper.game_gvg_allot_people_pop.allot})
        end
        local params = {}
        params.reward_id = self.itemKey
        params.target_uid = uid
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_reward_distribution"), http_request_method.GET, params,"association_reward_distribution")
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end
--[[--
    刷新ui
]]
function game_gvg_allot_people_pop.refreshUi(self)
    --即时信息
    self.content_node:removeAllChildrenWithCleanup(true)
    local contentTableView = self:createLogTable(self.content_node:getContentSize());
    self.content_node:addChild(contentTableView,10,10);
end

--[[--
    初始化
]]
function game_gvg_allot_people_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.players = t_params.players
    self.itemKey = t_params.itemKey
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_allot_people_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_gvg_allot_people_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return game_gvg_allot_people_pop;