---  活动
local game_help_new_pop = {
    m_node_titlesboard = nil,
    m_node_infoboard = nil,
    m_node_leftboard = nil,
    m_node_rightboard = nil,
    m_node_showboard = nil,
    m_node_gotobtn = nil,

    m_showFunData = nil,
    m_cur_showTableView = nil,
    m_cur_select_index = nil,
    m_lastPosY = nil,
    m_lastSelectCell = nil,
    m_sprite_contenttitle = nil,
    m_entryBtnId = nil,
    m_needRefreshViewPos = nil,
    m_showend_button = nil,
};
--[[--
    销毁ui
]]
function game_help_new_pop.destroy(self)
    -- body
    cclog("-----------------game_help_new_pop destroy-----------------");
    self.m_node_titlesboard = nil;
    self.m_node_infoboard = nil;
    self.m_node_leftboard = nil;
    self.m_node_rightboard = nil;
    self.m_node_showboard = nil;

    self.m_showFunData = nil;
    self.m_cur_showTableView = nil;
    self.m_cur_select_index = nil;
    self.m_lastPosY = nil;
    self.m_lastSelectCell = nil;
    self.m_sprite_contenttitle = nil;
    self.m_entryBtnId = nil;
    self.m_needRefreshViewPos = nil;
    self.m_showend_button = nil;
end

--[[--
    返回
]]
function game_help_new_pop.back(self,backType)
    -- game_scene:enterGameUi("game_main_scene",{gameData = nil,  openPop = nil});
    -- self:destroy();
    -- for i,v in ipairs(self.m_showend_button or {}) do
    --     game_data:addOneNewButtonByBtnID( v )
    -- end
    game_data:resetOpenButtonList()
    game_scene:removePopByName("game_help_new_pop");
end

--[[--
    读取ccbi创建ui
]]
function game_help_new_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag, "game_help_new_pop click btn tag ==== ")
        if btnTag == 1 then--返回
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_help_new.ccbi");
    
    self.m_node_titlesboard = ccbNode:nodeForName("m_node_titlesboard");  
    self.m_node_infoboard =  ccbNode:nodeForName("m_node_infoboard");
    self.m_node_leftboard =  ccbNode:nodeForName("m_node_leftboard");
    self.m_node_rightboard =  ccbNode:nodeForName("m_node_rightboard");
    self.m_node_gotobtn = ccbNode:nodeForName("m_node_gotobtn")
    self.m_node_showboard =  ccbNode:nodeForName("m_node_showboard");
    self.m_sprite_contenttitle = ccbNode:spriteForName("m_sprite_contenttitle")
    self.m_sprite_contenttitle:setVisible(false)

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);

    local btn_back = ccbNode:controlButtonForName("m_close_btn")
    btn_back:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11)
    
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_help_new_pop.refreshUi(self)
    if not self.m_node_titlesboard then return end
    self.m_node_titlesboard:removeAllChildrenWithCleanup(true)
    self.m_cur_showTableView = nil      -- 重置
    local tempView = self:createTableViewLeft(self.m_node_titlesboard:getContentSize())
    if tempView then
        self.m_node_titlesboard:addChild(tempView)
        self.m_cur_showTableView = tempView
        if self.m_lastPosY then
            self.m_cur_showTableView:setContentOffset(ccp(0, self.m_lastPosY))
            self.m_lastPosY = nil
        end
        if self.m_needRefreshViewPos then
            self.m_needRefreshViewPos = false
            local bg_height = self.m_node_titlesboard:getContentSize().height
            local view_height = self.m_cur_showTableView:getContentSize().height
            if self.m_cur_select_index > 5 then 
                local offy = (self.m_cur_select_index + 3 ) / 6 * bg_height - view_height
                self.m_cur_showTableView:setContentOffset(ccp(0, math.min(offy, 0 ) ), true)
            end
        end
    else
        self.m_lastPosY = nil
    end
end

--[[
    创建左侧活动滑动列表
]]--
function game_help_new_pop.createTableViewLeft( self,viewSize )
    local showData = self.m_showFunData

    function onBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- cclog2(btnTag, " game_help_  createTable click btn btnTag  === ")
        self:back()
        self:goToFunction(showData[btnTag + 1])
    end

    local allCount = #showData
    local params = {};
    params.viewSize = viewSize;
    params.row = 6;
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 11; --列
    params.totalItem = allCount;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);

    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_help_title_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end

        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = showData[index + 1] or {}
            local itemCfg = itemData.itemCfg
            local key = itemCfg:getKey();

            local m_spr_title = ccbNode:spriteForName("m_spr_title")
            local m_word_spr = ccbNode:spriteForName("m_word_spr")
            local m_label_needinfo = ccbNode:labelTTFForName("m_label_needinfo")
            local m_scale9sprite_select = ccbNode:nodeForName("m_scale9sprite_select")

            local word_image = "word_image_" .. key .. ".png"
            local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(word_image)
            if tempFrame then
                m_word_spr:setDisplayFrame(tempFrame)
            end
            -- 标题显示
            local titleSprName = itemCfg:getNodeWithKey("icon"):toStr();
            local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( tostring(titleSprName))
            if tempFrame then
                m_spr_title:setDisplayFrame(tempFrame)
            end
            -- 选中状态
            if self.m_cur_select_index == index and m_scale9sprite_select then
                m_scale9sprite_select:setVisible(true)
                self.m_lastSelectCell = cell
                self:refreshContent( showData[index + 1], index, onBtnClick)
            else
                m_scale9sprite_select:setVisible(false)
            end
            -- 标签提示
            local btnId = itemCfg:getNodeWithKey("button") and itemCfg:getNodeWithKey("button"):toInt()
            if game_button_open:getIsNewOpenButton(btnId) and not ccbNode:getChildByTag(987) then
               local node = game_util:addTipsAnimByType(ccbNode, 1);
               node:setScale(1.23)
               node:setTag(987)
            else
                ccbNode:removeChildByTag(987, true)
            end
            -- 标题提醒文字
            local msg = ""
            msg = itemCfg:getNodeWithKey("manual"):toStr();
            if itemData.openFlag == false then
                m_word_spr:setColor(ccc3(100,100,100))
                m_spr_title:setColor(ccc3(100,100,100))
            else
                m_word_spr:setColor(ccc3(255,255,255))
                m_spr_title:setColor(ccc3(255,255,255))
            end
            m_label_needinfo:setString(tostring(msg))
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local itemData = showData[index + 1]
            if itemData.openFlag == false then
                local msg = itemData.itemCfg:getNodeWithKey("manual"):toStr();
                game_util:addMoveTips({text = msg});
                return;
            end
            -- cclog2(index, "click table cell index === ")
            if self.m_lastSelectCell then
                local ccbNode = tolua.cast(self.m_lastSelectCell:getChildByTag(10),"luaCCBNode");
                local m_scale9sprite_select = ccbNode:nodeForName("m_scale9sprite_select")
                m_scale9sprite_select:setVisible(false)
            end
            if item then
                local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
                local m_scale9sprite_select = ccbNode:nodeForName("m_scale9sprite_select")
                m_scale9sprite_select:setVisible(true)
            end
            self:refreshContent( itemData, index, onBtnClick)
            self.m_lastPosY = self.m_cur_showTableView:getContentOffset().y
            self.m_lastSelectCell = item;
            self.m_cur_select_index = index
        end
    end
    return TableViewHelper:create(params);
end

--[[
    刷新 显示查看的功能
]]
function game_help_new_pop.refreshContent( self, showData, cellIndex, onBtnClick )
    if not showData then return end
    local itemCfg = showData.itemCfg
    local key = itemCfg:getKey();
    -- 标题
    local contentSprName = "help_image_" .. key
    local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( tostring(contentSprName) .. "_1.png")
    if tempFrame then
        self.m_sprite_contenttitle:setDisplayFrame(tempFrame)
        self.m_sprite_contenttitle:setVisible(true)
    end
    self.m_node_showboard:removeAllChildrenWithCleanup(true);
    -- 内容
    local tempSpr = CCSprite:create(tostring("ccbResources/".. tostring(contentSprName) .. ".jpg"));
    if tempSpr then  
        local tempSize = self.m_node_showboard:getContentSize()
        tempSpr:setPosition(tempSize.width * 0.5, tempSize.height * 0.5)
        self.m_node_showboard:addChild(tempSpr)
    end

    -- 按钮
    self.m_node_gotobtn:removeAllChildrenWithCleanup(true)
    local tempBtnSize = self.m_node_gotobtn:getContentSize()
    local btnId = "";
    if key == "1" then
        btnId = "1000001";
    elseif key == "2" then
        btnId = "1000002";
    else
        btnId = itemCfg:getNodeWithKey("button"):toStr();
    end
    local funInfo = showData.btnInfo  or  self:getButtonInfByBtnId( btnId )
    -- cclog2(funInfo  ,  "funInfo   ====   " .. btnId)
    showData.btnInfo  = funInfo
    if funInfo then
        local spriteName = funInfo.spriteName
        local firstValue,_ = string.find(spriteName,".png");
        if not firstValue then
            spriteName = spriteName .. ".png"
        end
        local resFramesName = funInfo.resFramesName
        if resFramesName then CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(resFramesName); end  -- 添加按钮所在图片的资源
        local button = game_util:createCCControlButton(spriteName,"",onBtnClick)
        if button then
            if game_button_open:getIsNewOpenButton( tonumber(btnId) ) then
                local node = game_util:addTipsAnimByType(self.m_node_gotobtn, 17);
                table.insert(self.m_showend_button, btnId)
            end
            button:setAnchorPoint(ccp(0.5,0.5))
            button:setPosition(tempBtnSize.width * 0.5, tempBtnSize.height * 0.5)
            self.m_node_gotobtn:addChild(button)
            button:setTag( cellIndex )
            button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
        end
    end
    CCTextureCache:sharedTextureCache():removeUnusedTextures();
end

--[[
    前往工具体功能
]]
function game_help_new_pop.goToFunction( self, funData )
    -- cclog2(funData, "go fun funData  ===  ")
    local btnInfo = funData.btnInfo or {}
    if btnInfo.goToCallFun then  -- 前往方法
        btnInfo.goToCallFun(btnInfo.itemIndex)
    end
end

--[[
    检查按钮功能是否被 关闭
]]
function game_help_new_pop.checkButtonOpen( self )
    -- body
end

--[[
    检查新功能开启
]]
function game_help_new_pop.cheekkNewButton( self )
    local curOpenButtonIds = game_button_open:getOpenButtonIdList()
end

local gtactivity = function(itemIndex , chapterID)
    self:goToActivity(itemIndex, chapterID)
end

--[[
    -- 初始化要显示的数据
]]
function game_help_new_pop.formatData( self )
    self.m_showend_button = {}
    self.m_showFunData = {}
    local guide_manual_cfg = getConfig(game_config_field.guide_manual)
    -- if not guide_manual_cfg then return end
    local tempCount = guide_manual_cfg:getNodeCount();
    for i=1,tempCount do
        local itemCfg = guide_manual_cfg:getNodeAt(i-1);
        local inreview = itemCfg:getNodeWithKey("inreview") and itemCfg:getNodeWithKey("inreview"):toStr() or "-1";
        local btnId = itemCfg:getNodeWithKey("button"):toStr();
        if inreview == "-1" then
            table.insert(self.m_showFunData, {itemCfg = itemCfg,openFlag = true, sortId = tonumber(itemCfg:getKey())})
        else
            if game_data:isViewOpenByID( inreview ) then
                local openFlag = game_button_open:getOpenFlagByBtnId(btnId)
                local sortId = tonumber(itemCfg:getKey())
                if openFlag == false then sortId = sortId + 1000 end
                table.insert(self.m_showFunData, {itemCfg = itemCfg,openFlag = openFlag, sortId = sortId})
            end
        end
    end
    table.sort(self.m_showFunData,function(data1,data2) return tonumber(data1.sortId) < tonumber(data2.sortId)  end);
    -- cclog2(self.m_showFunData, "self.m_showFunData   ====   ")

    -- 定位进入的帮助id
    if self.m_entryBtnId then
        for i,v in ipairs( self.m_showFunData ) do
            if v and v.itemCfg then
                local key = v.itemCfg:getNodeWithKey("button") and v.itemCfg:getNodeWithKey("button"):toStr() or nil
                if key == tostring(self.m_entryBtnId) then
                    self.m_cur_select_index = math.max(0, tonumber(i) - 1)
                    -- cclog2(i, " buttonId " .. self.m_entryBtnId .. " index == ")
                    self.m_needRefreshViewPos = true
                    break
                end
            end
        end
    end
end

--[[
    获取按钮信息
]]
function game_help_new_pop.getButtonInfByBtnId( self, btnId )
    local quick_entery = require("game_qucik_entry.lua")
    return quick_entery:getQucikEnteryFunByBtnId( btnId )
end

--[[
    根据btnId 获取 inreveiw 
]]
function game_help_new_pop.getInreviewByBtnId( self, btnId )
    return 11111
end

--[[--
    初始化
]]
function game_help_new_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_cur_select_index = 0
    self.m_entryBtnId = t_params.entryBtnId
    self.m_needRefreshViewPos = nil
    self:formatData()
end

--[[--
    创建ui入口并初始化数据
]]
function game_help_new_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi()
    return scene;
end

return game_help_new_pop;