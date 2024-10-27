---  鼓舞log

local game_gvg_inspire_pop = {
    m_root_layer = nil,
    content_node = nil,
    gameData = nil,
    m_close_btn = nil,
    callBackFunc = nil,
    btn_all = nil,
    btn_self = nil,
    log_index = nil,
    selfGameData = nil,
};
--[[--
    销毁ui
]]
function game_gvg_inspire_pop.destroy(self)
    -- body
    cclog("----------------- game_gvg_inspire_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.content_node = nil;
    self.gameData = nil;
    self.m_close_btn = nil;
    self.callBackFunc = nil;
    self.btn_all = nil;
    self.btn_self = nil;
    self.log_index = nil;
    self.selfGameData = nil;
end
--[[--
    返回
]]
function game_gvg_inspire_pop.back(self,backType)
    if self.callBackFunc then
        self:callBackFunc()
    end
    game_scene:removePopByName("game_gvg_inspire_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_inspire_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 100 then -- 关闭
            self:back()
        elseif btnTag == 3 or btnTag == 4 then--所有战报    && 个人战报
            self.log_index = btnTag - 2
            self:refreshUi()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_perpare_pop.ccbi");

    self.content_node = ccbNode:nodeForName("content_node")
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-12,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.btn_all = ccbNode:controlButtonForName("btn_all")
    self.btn_self = ccbNode:controlButtonForName("btn_self")
    self.btn_all:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.btn_self:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 13);

    game_util:setCCControlButtonTitle(self.btn_all,string_helper.ccb.text219)
    game_util:setCCControlButtonTitle(self.btn_self,string_helper.ccb.text220)
    return ccbNode;
end

--[[--
    创建列表
]]
function game_gvg_inspire_pop.createTabelView( self, viewSize )
    local tabCount = game_util:getTableLen(self.gameData)
    cclog2(self.gameData,"self.gameData")
    local params = {};
    params.viewSize = viewSize;
    params.row = 8;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_perpare_pop_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")    
            local text_label = ccbNode:labelTTFForName("text_label")

            local itemData = self.gameData[index+1]
            local name = itemData.name
            local score = itemData.score
            text_label:setString(name .. string_helper.game_gvg_inspire_pop.inspire .. score)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    log 列表
]]
function game_gvg_inspire_pop.createLogTabelView( self, viewSize )
    --[[
        BATTLE_TYPE_2 = 2           # 战斗类型: 2. 防守方 攻打 资源点成功捣毁
        BATTLE_TYPE_3 = 3           # 战斗类型: 3. 防守方连续X次防守住阵地, 完成连胜
        BATTLE_TYPE_4 = 4           # 战斗类型: 4. 攻击方 攻打 防守方成功 | 防守方 攻打 攻击方成功
        BATTLE_TYPE_5 = 5           # 战斗类型: 5. 攻击方 攻打 防守方失败 | 防守方 攻打 攻击方失败
        BATTLE_TYPE_6 = 6           # 战斗类型: 6. 防守方 攻打 资源点成功
        BATTLE_TYPE_7 = 7           # 战斗类型: 7. 防守方 攻打 资源点失败
    ]]
    local log_type_table = string_helper.game_gvg_inspire_pop.log_type_table
    local attColor = "[color=ffff2628]"
    local defColor = "[color=ff1e87fd]"
    local logTable = self.gameData
    if self.log_index == 2 then
        logTable = self.selfGameData
    end
    local tabCount = game_util:getTableLen(logTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 8;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-13;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_perpare_pop_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")    
            local label_node = ccbNode:nodeForName("label_node")    
            local text_label = ccbNode:labelTTFForName("text_label")
            text_label:setString("")

            local richLabel = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(280,27),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192)});
            local logData = logTable[tabCount-index] or {}

            local color1 = ""
            local color2 = ""
            local logStr = ""
            local battType = logData.battle_type
            local ais_def = logData.ais_def
            local dguild_name = logData.dguild_name or ""
            local aguild_name = logData.aguild_name or ""
            if ais_def then
                color1 = defColor
                color2 = attColor
            else
                color2 = defColor
                color1 = attColor
            end
            if battType == 4 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. "战胜了" .. color2 .. logData.dname .. "(" .. dguild_name .. ")" .. "[/color],占领了该地块!"
            elseif battType == 3 then
                logStr =  " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. "完成了" .. "[color=ffff0b03]" .. logData.times .. "连胜" .. "[/color]"
            elseif battType == 6 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. "战胜了" .. color2 .. logData.dname .. "[/color]"
            elseif battType == 5 or battType == 7 then
                logStr =  " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. "被" .. color2 .. logData.dname .. "(" .. dguild_name .. ")" .. "[/color]击败了"
            elseif battType == 2 then
                logStr = " " .. color1 .. logData.aname .. "(" .. aguild_name .. ")" .. "[/color]" .. "战胜了" .. color2 .. logData.dname .. "[/color],摧毁了该位置"
            end
            richLabel:setString(logStr)
            label_node:removeAllChildrenWithCleanup(true)
            label_node:addChild(richLabel)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_gvg_inspire_pop.refreshUi(self)
    if self.enterType == 1 then
        self.btn_all:setVisible(false)
        self.btn_self:setVisible(false)
        self.content_node:removeAllChildrenWithCleanup(true)
        local tableview = self:createTabelView(self.content_node:getContentSize())
        self.content_node:addChild(tableview)
    else
        self.content_node:removeAllChildrenWithCleanup(true)
        local tableview = self:createLogTabelView(self.content_node:getContentSize())
        self.content_node:addChild(tableview)
    end
end
--[[--
    初始化
]]
function game_gvg_inspire_pop.init(self,t_params)
    t_params = t_params or {}
    self.gameData = t_params.gameData
    self.enterType = t_params.enterType or 1
    self.callBackFunc = t_params.callBackFunc
    self.selfGameData = t_params.selfGameData
    self.log_index = 1
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_inspire_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end
--[[--
    回调方法
]]
function game_gvg_inspire_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end
return game_gvg_inspire_pop