--- 活动

local game_activity_scene = {
    m_list_view_bg = nil,
    m_activity_intro_layer = nil,
    m_intro_label = nil,
    m_enter_btn = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_tab_btn_1 = nil,
    m_tab_btn_2 = nil,
    m_tab_btn_3 = nil,
};
--[[--
    销毁ui
]]
function game_activity_scene.destroy(self)
    -- body
    cclog("-----------------game_activity_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_activity_intro_layer = nil;
    self.m_intro_label = nil;
    self.m_enter_btn = nil;
    self.m_popUi = nil;
    self.m_tab_btn_1 = nil
    self.m_tab_btn_2 = nil;
    self.m_tab_btn_3 = nil;
end
--[[--
    返回
]]
function game_activity_scene.back(self,backType)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_activity_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then -- 每日
            -- game_scene:enterGameUi("game_daily_scene",{gameData = nil});
            require("game_ui.game_daily_scene"):addPop({gameData = nil})
            self:back();
        elseif btnTag == 3 then -- 活动

        elseif btnTag == 4 then -- 公告

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_activity.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_activity_intro_layer = tolua.cast(ccbNode:objectForName("m_activity_intro_layer"), "CCLayer");
    self.m_intro_label = tolua.cast(ccbNode:objectForName("m_intro_label"), "CCLabelTTF");
    self.m_enter_btn = tolua.cast(ccbNode:objectForName("m_enter_btn"), "CCControlButton");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_enter_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_tab_btn_1 = ccbNode:controlButtonForName("m_tab_btn_1");
    self.m_tab_btn_2 = ccbNode:controlButtonForName("m_tab_btn_2");
    self.m_tab_btn_3 = ccbNode:controlButtonForName("m_tab_btn_3");
    self.m_tab_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_tab_btn_2:setHighlighted(true);
    self.m_tab_btn_2:setEnabled(false);

    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY+1,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建活动列表
]]
function game_activity_scene.createTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.totalItem = 10;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 200, 50)
            -- local spriteLand = CCSprite:createWithSpriteFrameName("hd_huodongtubiao.png");
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local msgLabel = CCLabelTTF:create("",TYPE_FACE_TABLE.Arial_BoldMT,10);
            msgLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(msgLabel,10,10);
        end
        if cell then
            -- local bgSprTemp = tolua.cast(cell:getChildByTag(1),"CCSprite");
            -- if bgSpr then
            --     if index == 0 then
            --         bgSprTemp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("hd_dianji.png"));    
            --     else
            --         bgSprTemp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("hd_huodongtubiao.png"));
            --     end
            -- end
            local msgLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            if msgLabel then
                msgLabel:setString(string_helper.game_activity_scene.activity .. (index+1));
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_activity_scene.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
end
--[[--
    初始化
]]
function game_activity_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

--[[--
    创建并添加弹出框
]]
function game_activity_scene.addPop(self,t_params)
    -- body
    t_params = t_params or {};
    if self.m_popUi == nil then
        if t_params.parentNode == nil then
            t_params.parentNode = game_scene:getPopContainer()
            if t_params.parentNode == nil then
                return;
            end
        end
        self:init(t_params);
        self.m_popUi = self:createUi();
        self:refreshUi();
        t_params.parentNode:addChild(self.m_popUi);
    end    
end

return game_activity_scene;