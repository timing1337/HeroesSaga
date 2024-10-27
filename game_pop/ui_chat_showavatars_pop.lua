---  ui模版

local ui_chat_showavatars_pop = {
    m_root_layer = nil,
    m_sprite9_showboard = nil,
    m_node_itemsbg = nil,

    m_curPage = nil,
    t_rewards = nil,

    m_flag = nil,
    m_gameData = nil ,

    m_endCallFun = nil,

};
--[[--
    销毁ui
]]
function ui_chat_showavatars_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_sprite9_showboard = nil;
    self.m_node_itemsbg = nil;

    self.m_curPage = nil;
    self.t_rewards = nil;

    self.m_flag = nil;
    self.m_gameData = nil ;

    self.m_endCallFun = nil;
end
--[[--
    返回
]]
function ui_chat_showavatars_pop.back(self,backType)

    if type(self.m_endCallFun) == "function" then 
        self.m_endCallFun()
    end
    game_scene:removePopByName("ui_chat_showavatars_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function ui_chat_showavatars_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_chat_select_avatar_pop.ccbi")
    self.m_node_itemsbg = ccbNode:nodeForName("m_node_itemsbg")
    local m_label_showtips = ccbNode:labelTTFForName("m_label_showtips")
    m_label_showtips:setString(string_helper.ccb.file42);

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-23,true);
    self.m_root_layer:setTouchEnabled(true);
    -- -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_closeBtn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 24);



    local vip = game_data:getUserStatusDataByKey("vip") or 0
    if not game_data:isViewOpenByID(101) or vip > 0 then
        local m_label_showtips = ccbNode:labelTTFForName("m_label_showtips")
        if m_label_showtips then 
            m_label_showtips:setVisible(false)
        end
    end


    return ccbNode;
end

--[[--
    刷新ui
]]
function ui_chat_showavatars_pop.refreshUi(self)
    self.m_node_itemsbg:removeAllChildrenWithCleanup( true )
    local tableview = self:createItemsTabelViewByTypeID( self.m_node_itemsbg:getContentSize())
    if tableview == nil then return end
    tableview:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5 );
    self.m_node_itemsbg:addChild(tableview)

end
--[[--
    初始化
]]
function ui_chat_showavatars_pop.init(self,t_params)

     self.m_gameData = t_params or {};
     self.m_endCallFun = t_params.endCallFun

end

function ui_chat_showavatars_pop.createItemsTabelViewByTypeID(self, viewSize)


    local face_cfg = getConfig(game_config_field.face_icon)


    local vip = game_data:getUserStatusDataByKey("vip")
    local tempData = {};
    local opening_cfg_count = face_cfg:getNodeCount();
    for i=1,opening_cfg_count do
        local itemCfg = face_cfg:getNodeAt(i-1)
        local needVIP = itemCfg:getNodeWithKey("vip") and itemCfg:getNodeWithKey("vip"):toInt() or 0
        if vip >= needVIP  then
            tempData[#tempData + 1] = itemCfg:getKey();
        end
    end

    local totalItem = #tempData
    local numcount = 1 ;
    local params = {};
    params.viewSize = viewSize;
    params.row = 3; -- 行
    params.column = 5; -- 列
    params.totalItem = totalItem  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage; -- 分页
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-25;
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
            local avatarInfo =  face_cfg:getNodeWithKey( tostring(tempData[index + 1]) )
            local avatarName = avatarInfo and avatarInfo:getNodeWithKey("icon") and avatarInfo:getNodeWithKey("icon"):toStr() 
            local icon = game_util:createIconByName(avatarName or "icon_sangshigou.png")
            numcount = numcount + 1 ;
            if icon then
                local qualityTab = HERO_QUALITY_COLOR_TABLE[4]
                local tempIconSize = icon:getContentSize();
                local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                icon:addChild(img1,-1,1)
                local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
                img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                icon:addChild(img2,1,2)
                icon:setPositionX(icon:getContentSize().width * 0.5)
                icon:setPositionY(icon:getContentSize().height * 0.5)
                cell:addChild(icon)
            else
                cclog("pop ========   no  Data")
            end

        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
        if eventType == "ended" then
            print("avatar", tostring(index + 1), true)
            game_data:updateLocalData("avatar_id", tostring(tempData[index + 1]), true)
            self:back()
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建ui入口并初始化数据
]]
function ui_chat_showavatars_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_chat_showavatars_pop;
