--- 开门活动

local open_door_activity = {
    m_popUi = nil,
    m_close_btn = nil,
    m_ok_btn = nil,
    m_scroll_view = nil,
    m_progress_label = nil,
    m_progress_bar = nil,
    m_tGameData = nil,
    m_ccbNode = nil,
    m_sel_index = nil,
    m_scroll_view_bg = nil,
    m_energy_btn = nil,
    m_firstShowFlag = true,
};
--[[--
    销毁
]]
function open_door_activity.destroy(self)
    -- body
    cclog("-----------------open_door_activity destroy-----------------");
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_ok_btn = nil;
    self.m_scroll_view = nil;
    self.m_progress_label = nil;
    self.m_progress_bar = nil;
    self.m_tGameData = nil;
    self.m_ccbNode = nil;
    self.m_sel_index = nil;
    self.m_scroll_view_bg = nil;
    self.m_energy_btn = nil;
end
--[[--
    返回
]]
function open_door_activity.back(self,type)
    game_scene:removePopByName("open_door_activity");
end
--[[--
    读取ccbi创建ui
]]
function open_door_activity.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                local reward = self.m_tGameData.reward or {}
                local function callBackFunc()
                    local fuel = self.m_tGameData.fuel or 0
                    if fuel > 0 then
                        game_util:addMoveTips({text = string_helper.open_door_activity.shipFuel .. tostring(fuel)})
                    end
                end
                game_util:rewardTipsByDataTable(reward,callBackFunc);
                self:refreshUi();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("open_door_open"), http_request_method.GET, nil,"open_door_open")
        elseif btnTag == 3 then
            self:refreshActivityDetail(0);
        elseif btnTag > 10 and btnTag < 14 then
            -- if btnTag == 11 then--跳转到银河舰队
            --     local function responseMethod(tag,gameData)
            --         game_scene:enterGameUi("game_dart_main",{gameData = gameData});
            --     end
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
            -- elseif btnTag == 13 then
            --     local function responseMethod(tag,gameData)
            --         game_scene:enterGameUi("open_door_cloister",{gameData = gameData});
            --     end
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_index"), http_request_method.GET, nil,"maze_index")
            -- else
            --     local function responseMethod(tag,gameData)
            --         if gameData then
            --             game_scene:enterGameUi("game_pyramid_scene",{gameData = gameData,screenShoot = screenShoot, openData = {}});
            --         end
            --     end
            --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pyramid_index"), http_request_method.GET, nil,"pyramid_index")  
            -- end
            self:refreshActivityDetail(btnTag - 10);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_open_door_activity.ccbi");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.m_energy_btn = ccbNode:controlButtonForName("m_energy_btn");
    self.m_scroll_view = ccbNode:scrollViewForName("m_scroll_view")
    self.m_progress_label = ccbNode:labelBMFontForName("m_progress_label")
    self.m_scroll_view_bg = ccbNode:scale9SpriteForName("m_scroll_view_bg")
    local m_progress_node = ccbNode:nodeForName("m_progress_node")
    --m_func_label_11
    local  title128 = ccbNode:labelTTFForName("m_func_label_11");
    local  title129 = ccbNode:labelTTFForName("m_func_label_12");
    local  title130 = ccbNode:labelTTFForName("m_func_label_13");
    title128:setString(string_helper.ccb.title128);
    title129:setString(string_helper.ccb.title129);
    title130:setString(string_helper.ccb.title130);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_energy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_scroll_view:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_scroll_view_bg:setVisible(false)
    self.m_scroll_view:setVisible(false)
    local barSize = m_progress_node:getContentSize();
    local bar = ExtProgressTime:createWithFrameName("kmhd_jindu1.png","kmhd_jindu2.png");
    bar:setCurValue(0,false);
    m_progress_node:addChild(bar);
    self.m_progress_bar = bar;
    local tempBtn = nil;
    for i=1,3 do
        tempBtn = ccbNode:controlButtonForName("m_func_btn_1" .. i);
        if tempBtn then
            tempBtn:setOpacity(0);
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
            local tempAnim = game_util:createEffectAnimCallBack("men-" .. i,1.0,true);
            if tempAnim then
                tempAnim:setAnchorPoint(ccp(0.5,0))
                local pX,pY = tempBtn:getPosition();
                tempAnim:setPosition(ccp(pX,pY+20));
                tempBtn:getParent():addChild(tempAnim)
            end
        end
    end
    local m_rotation_spr = ccbNode:spriteForName("m_rotation_spr")
    local animArr = CCArray:create();
    animArr:addObject(CCRotateBy:create(72,360));
    m_rotation_spr:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新
]]
function open_door_activity.refreshActivityDetail(self,index)
    if index == 0 then
        self.m_scroll_view_bg:setVisible(not self.m_scroll_view_bg:isVisible())
        self.m_scroll_view:setVisible(not self.m_scroll_view:isVisible())
    end
    if self.m_sel_index == index then
        return;
    end
    self.m_scroll_view_bg:setVisible(true)
    self.m_scroll_view:setVisible(true)
    self.m_scroll_view:getContainer():removeAllChildrenWithCleanup(true)
    self.m_scroll_view:getContainer():setPosition(ccp(0,0))
    local activeCfg = getConfig(game_config_field.notice_active)
    local itemCfg = nil;
    if index == 0 then
        itemCfg = activeCfg:getNodeWithKey( "138" )
    else
        itemCfg = activeCfg:getNodeWithKey( tostring(140+index-1) )
    end
    local contentText = itemCfg and itemCfg:getNodeWithKey("word") and itemCfg:getNodeWithKey("word"):toStr() or string_helper.open_door_activity.defaultText
    local viewSize = self.m_scroll_view:getViewSize();
    local tempLabel = game_util:createRichLabelTTF({text = contentText,dimensions = CCSizeMake(viewSize.width,0),textAlignment = kCCTextAlignmentLeft,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 12})
    local tempSize = tempLabel:getContentSize();
    local ext_label = ExtLabelTTF:create(contentText,TYPE_FACE_TABLE.Arial_BoldMT,11,tempSize,0.02)
    ext_label:setAnchorPoint(ccp(0,1))
    ext_label:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    self.m_scroll_view:setContentSize(CCSizeMake(viewSize.width,tempSize.height))
    self.m_scroll_view:setContentOffset(ccp(0, viewSize.height - tempSize.height), false)
    -- self.m_scroll_view:addChild(tempLabel)    
    self.m_scroll_view:addChild(ext_label,10,10)
    for i=1,3 do
        local m_func_spr_bg = self.m_ccbNode:spriteForName("m_func_spr_bg_1" .. i)
        if m_func_spr_bg then
            local spriteFrame = nil;
            if i == index then
                spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("kmhd_name_ban_sel.png")
            else
                spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("kmhd_name_ban.png")
            end
            if spriteFrame then
                m_func_spr_bg:setDisplayFrame(spriteFrame)
            end
        end
    end
    self.m_sel_index = index;
end

--[[--
    刷新ui
]]
function open_door_activity.refreshUi(self)
    if self.m_firstShowFlag == true then
        self:refreshActivityDetail(0);
    end
    local rate = self.m_tGameData.rate or 0;
    local progressValue = math.min(100,math.max(5,rate));
    self.m_progress_bar:setCurValue(progressValue,true);
    -- self.m_progress_label:setString(tostring(progressValue) .. "%");
    self.m_progress_label:setString("")
    self.m_firstShowFlag = false;
end

--[[--
    初始化
]]
function open_door_activity.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_activity.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return open_door_activity;