--- 

local game_activity_pop_mine_jingbiao = {
    m_root_layer = nil,
    m_btn_close = nil,
    m_btn_add_1 = nil,
    m_btn_add_2 = nil,
    m_btn_buy = nil,
    m_node_editbox = nil,
    m_tGameData = nil,
    m_label_price = nil,    -- 出价
    m_curPrice = nil,

    m_mineId = nil,
    m_callBackFunc = nil,
};
--[[--
    销毁
]]
function game_activity_pop_mine_jingbiao.destroy(self)
    -- body
    cclog("-----------------game_activity_pop_mine_jingbiao destroy-----------------");
    self.m_root_layer = nil
    self.m_btn_close = nil
    self.m_btn_add_1 = nil
    self.m_btn_add_2 = nil
    self.m_btn_buy = nil
    selfm_node_editbox = nil
    self.m_tGameData = nil
    self.m_label_price = nil
    self.m_curPrice = nil

    self.m_mineId = nil
    self.m_callBackFunc = nil
end
--[[--
    返回
]]
function game_activity_pop_mine_jingbiao.back(self,type)
    game_scene:removePopByName("game_activity_pop_mine_jingbiao")
end
--[[--
    读取ccbi创建ui
]]
function game_activity_pop_mine_jingbiao.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        if btnTag == 100 then   -- 关闭
            if self.m_callBackFunc then
                self.m_callBackFunc(nil);
            end
            self:back()

        elseif btnTag == 101 then -- 出价
            self:onSureBidding()
            self:refreshUi()
        elseif btnTag == 102 then -- +1000
            local curPrice = self.m_curPrice
            self.m_curPrice = curPrice + 1000
            self:refreshUi()
        elseif btnTag == 103 then -- +100
            self.m_curPrice = self.m_curPrice + 100
            self:refreshUi()
        end
        -- self:refreshUi()
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_activity_pop_mine_jingbiao.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_btn_close = ccbNode:controlButtonForName("m_btn_close")
    self.m_btn_add_1 = ccbNode:controlButtonForName("m_btn_add_1")
    self.m_btn_add_2 = ccbNode:controlButtonForName("m_btn_add_2")
    self.m_btn_buy  = ccbNode:controlButtonForName("m_btn_buy")
    self.m_label_price = ccbNode:labelTTFForName("m_label_price")
    self.m_label_price:setVisible(false)

    local m_editNode = ccbNode:nodeForName("m_editNode")
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            self.m_curPrice = edit:getText()
            -- print(self.m_curPrice)

        end
    end
    m_editNode:removeAllChildrenWithCleanup(true);
    self.m_node_editbox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = m_editNode:getContentSize(),placeHolder="",maxLength = 10,inputMode = kEditBoxInputModeDecimal});
    self.m_node_editbox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_node_editbox:setOpacity(255)
    m_editNode:addChild(self.m_node_editbox);

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_btn_close:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_btn_add_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_btn_add_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_btn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)

    return ccbNode;
end

--[[--
    出价 发送请求 关闭ui 进入 活动页面
]]
function  game_activity_pop_mine_jingbiao.onSureBidding( self )
    -- 请求
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if self.m_callBackFunc then
                self.m_callBackFunc(gameData);
            end
            self:back()
        end

        local params = {}
        params.mid = self.m_mineId
        params.price = self.m_curPrice
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("mine_bidding"), http_request_method.GET, params,"mine_bidding")
    end
    sendRequest()
end

--[[--
    刷新ui
]]
function game_activity_pop_mine_jingbiao.refreshUi(self)

    self.m_node_editbox:setText(tostring(self.m_curPrice))
    self.m_label_price:setString(tostring(self.m_curPrice))
end

--[[--
    初始化
]]
function game_activity_pop_mine_jingbiao.init(self,t_params)
    t_params = t_params or {};

    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = t_params.gameData or {};
    end
    local bidding = self.m_tGameData.bidding or {}
    local m_mineId = t_params.mineId or 1;
    local biddingItem = bidding[tostring(m_mineId)] or {}
    if biddingItem.coin == "" or biddingItem.coin == 0 then
        self.m_curPrice = 1000
    else
        self.m_curPrice = biddingItem.coin + 100
    end
    -- self.m_curPrice = (biddingItem.coin or 900 )+100 
    self.m_callBackFunc = t_params.callBackFunc

    self.m_mineId = m_mineId

end

--[[--
    创建ui入口并初始化数据
]]
function game_activity_pop_mine_jingbiao.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_activity_pop_mine_jingbiao;