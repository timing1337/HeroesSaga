--- 卡牌碎片
local game_item_card_pieces_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,
    m_look_flag = nil,
    maxCount = nil,
    alreadyCount = nil,
    tempId = nil,
    buy_call_back = nil,
    openType = nil,
};

--[[--
    销毁
]]
function game_item_card_pieces_pop.destroy(self)
    -- body
    cclog("-----------------game_item_card_pieces_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.m_look_flag = nil;
    self.maxCount = nil;
    self.alreadyCount = nil;
    self.tempId = nil;
    self.buy_call_back = nil;
    self.openType = nil;
end
--[[--
    返回
]]
function game_item_card_pieces_pop.back(self,type)
    game_scene:removePopByName("game_item_card_pieces_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_item_card_pieces_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--查看详情
            local change_sort = self.change_sort
            local cId = self.exchange_itemData.itemCfg:getKey();
            cclog("cId == " .. cId)
            if change_sort == 1 then
                game_scene:addPop("game_hero_info_pop",{cId = cId,openType = 4})
            elseif change_sort == 2 then
                local equipData = {lv = 1,c_id = cId,id = -1,pos = -1}
                game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
            elseif change_sort == 3 then
                
            end
        elseif btnTag == 3 then
            --批量使用   兑换
            self:addUsePop()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_items_card_pieces.ccbi");
    local m_title_label = tolua.cast(ccbNode:objectForName("m_title_label"),"CCLabelTTF");
    local m_story_label = tolua.cast(ccbNode:objectForName("m_story_label"),"CCLabelTTF");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_info_btn = ccbNode:controlButtonForName("m_info_btn")
    local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
    m_info_btn:setVisible(false)
    -- cclog2(self.exchange_itemData,"self.exchange_itemData")
    local icon = game_util:createItemIconByCfg(self.exchange_itemData.item_item_cfg)
    if icon then
        m_icon_spr:removeAllChildrenWithCleanup(true)
        icon:setAnchorPoint(ccp(0.5,0.5))
        local size = m_icon_spr:getContentSize();
        icon:setPosition(ccp(size.width*0.5,size.height*0.5));
        m_icon_spr:addChild(icon,10)
    end

    local function onTouch( eventType,x,y )
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    m_title_label:setString(self.exchange_itemData.itemName);
    -- local itemCfg = self.exchange_itemData.itemCfg
    -- local story = itemCfg:getNodeWithKey("story"):toStr()
    -- CCLuaLog(story)
    local item_item_cfg = self.exchange_itemData.item_item_cfg
    local story2 = item_item_cfg:getNodeWithKey("story"):toStr()
    m_story_label:setString(story2);
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");
    local m_left_btn = tolua.cast(ccbNode:objectForName("m_left_btn"),"CCControlButton");
    local m_right_btn = tolua.cast(ccbNode:objectForName("m_right_btn"),"CCControlButton");
    game_util:setCCControlButtonTitle(m_left_btn,string_helper.ccb.title193);
    game_util:setCCControlButtonTitle(m_right_btn,string_helper.ccb.title196);
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);
    m_info_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-11);

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
function game_item_card_pieces_pop.useFunc(self)
    
end
--[[
    兑换
]]
function game_item_card_pieces_pop.addUsePop(self)
    local haveCount = self.exchange_itemData.count
    local needCount = self.exchange_itemData.needCount
    local maxExchange = math.floor(haveCount / needCount)
    local t_params = 
    {
        okBtnCallBack = function(count)
            local function responseMethod(tag,gameData)
                -- cclog2(gameData,"gameData")
                local data = gameData:getNodeWithKey("data")
                local reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer())
                game_scene:enterGameUi("game_exchange_scene",{gameData = gameData,openType = self.openType})
                game_util:getRewardByItemTable(reward)
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_exchange"), http_request_method.GET, {change_id = self.exchange_itemData.key,count = count},"item_exchange");
        end,
        maxCount = maxExchange,
        itemData = self.exchange_itemData,
        touchPriority = GLOBAL_TOUCH_PRIORITY - 25,
    }
    game_scene:addPop("game_batch_exchange_pop",t_params)
end
function game_item_card_pieces_pop.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--
    刷新ui
]]
function game_item_card_pieces_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_item_card_pieces_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_callBackFunc = t_params.callBackFunc;
    self.exchange_itemData = t_params.itemData
    self.change_sort = t_params.change_sort
    self.openType = t_params.openType
end

--[[--
    创建ui入口并初始化数据
]]
function game_item_card_pieces_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_item_card_pieces_pop;