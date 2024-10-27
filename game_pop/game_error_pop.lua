--- 报错提示引导

local game_error_pop = {
    m_popUi = nil,
    m_title_label = nil,
    m_text_label = nil,
    m_close_btn = nil,
    m_btn_1 = nil,
    m_btn_2 = nil,
    m_btn_3 = nil,
    m_callBackFunc = nil,
    m_errorStatus = nil,
};
--[[--
    销毁
]]
function game_error_pop.destroy(self)
    -- body
    cclog("-----------------game_error_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_title_label = nil;
    self.m_text_label = nil;
    self.m_close_btn = nil;
    self.m_btn_1 = nil;
    self.m_btn_2 = nil;
    self.m_btn_3 = nil;
    self.m_callBackFunc = nil;
    self.m_errorStatus = nil;
end
--[[--
    返回
]]
function game_error_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_error_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_error_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag >= 11 and btnTag <= 13 then
            self:onBtnClickFunc(btnTag - 10);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_tips_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");

    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_text_label = ccbNode:labelTTFForName("m_text_label")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_btn_1 = ccbNode:controlButtonForName("m_btn_1")
    self.m_btn_2 = ccbNode:controlButtonForName("m_btn_2")
    self.m_btn_3 = ccbNode:controlButtonForName("m_btn_3")
    game_util:setCCControlButtonTitle(self.m_btn_1,string_helper.ccb.title53);
    game_util:setCCControlButtonTitle(self.m_btn_2,string_helper.ccb.title54);
    game_util:setCCControlButtonTitle(self.m_btn_3,string_helper.ccb.title55);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    self.m_btn_3:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);

    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    local shop_cfg = getConfig(game_config_field.shop)
    local itemCfg = getConfig(game_config_field.item);
    local error_cfg = getConfig(game_config_field.error_cfg)
    local error_item_cfg = error_cfg:getNodeWithKey(tostring(self.m_errorStatus));
    local btn_item,btn_item_count,button_text,funcId,shopId,needVipLevel
    local showBtnTab = {};
    local tempBtn = nil;
    for i=1,3 do
        tempBtn = self["m_btn_" .. i]
        tempBtn:setVisible(false);
        btn_item = error_item_cfg:getNodeWithKey("button" .. i)
        btn_item_count = btn_item:getNodeCount();
        button_text = error_item_cfg:getNodeWithKey("button" .. i .. "_text"):toStr();
        if btn_item_count == 3 then
            funcId = btn_item:getNodeAt(0):toInt();
            shopId = btn_item:getNodeAt(1):toInt();
            needVipLevel = btn_item:getNodeAt(2):toInt();
            if vipLevel >= needVipLevel then
                if funcId == 1 then
                    local shop_item_cfg = shop_cfg:getNodeWithKey(tostring(shopId));
                    if shop_item_cfg then
                        local shop_reward = shop_item_cfg:getNodeWithKey("shop_reward")
                        local shop_reward_count = shop_reward:getNodeCount();
                        if shop_reward_count > 0 then
                            local shop_reward_item = shop_reward:getNodeAt(0)
                            local tempType = shop_reward_item:getNodeAt(0):toInt();
                            local itemId = shop_reward_item:getNodeAt(1):toInt();
                            if tempType == 6 then--是道具
                                local item_item_cfg = itemCfg:getNodeWithKey(itemId)
                                if item_item_cfg then
                                    local count = game_data:getItemCountByCid(itemId);
                                    if count > 0 then
                                        game_util:setCCControlButtonTitle(tempBtn,string_helper.game_error_pop.use .. item_item_cfg:getNodeWithKey("name"):toStr())
                                        showBtnTab[#showBtnTab + 1] = tempBtn;
                                        tempBtn:setVisible(true);
                                    else
                                        game_util:setCCControlButtonTitle(tempBtn,string_helper.game_error_pop.buyAndUse .. item_item_cfg:getNodeWithKey("name"):toStr())
                                        showBtnTab[#showBtnTab + 1] = tempBtn;
                                        tempBtn:setVisible(true);
                                    end
                                end
                            end
                        end
                    end
                else
                    game_util:setCCControlButtonTitle(tempBtn,button_text)
                    showBtnTab[#showBtnTab + 1] = tempBtn;
                    tempBtn:setVisible(true);
                end
            end
        end
    end
    local tempSize = self.m_btn_1:getParent():getContentSize();
    if #showBtnTab ~= 3 then
        local itemWidth = tempSize.width/(#showBtnTab+1)
        for k,v in pairs(showBtnTab) do
            v:setPositionX(itemWidth*k);
        end
    end
    self.m_title_label:setString(string_config.m_title_prompt);
    self.m_text_label:setString(error_item_cfg:getNodeWithKey("error_info"):toStr());
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-3,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_error_pop.onBtnClickFunc(self,btnTag)
    local shop_cfg = getConfig(game_config_field.shop)
    local error_cfg = getConfig(game_config_field.error_cfg)
    local error_item_cfg = error_cfg:getNodeWithKey(tostring(self.m_errorStatus));
    local btn_item = error_item_cfg:getNodeWithKey("button" .. btnTag)
    local value1 = btn_item:getNodeAt(0):toInt();
    local value2 = btn_item:getNodeAt(1):toInt();
    local value3 = btn_item:getNodeAt(2):toInt();
    cclog("value1 === " .. value1 .. " ; value2 === " .. value2 .. " ; value3 == " .. value3)
    if value1 == 1 then--1-购买并使用道具 中间填shopID,如果填的是不能use的道具，则点击后变为直接购买并放在背包里
        local shop_item_cfg = shop_cfg:getNodeWithKey(tostring(value2));
        if shop_item_cfg then
            local shop_reward = shop_item_cfg:getNodeWithKey("shop_reward")
            local shop_reward_count = shop_reward:getNodeCount();
            if shop_reward_count > 0 then
                local tempType = shop_reward:getNodeAt(0):toInt();
                local itemId = shop_reward:getNodeAt(1):toInt();
                if tempType == 6 then--是道具
                    local item_count = game_data:getItemCountByCid(itemId)
                    local function responseMethod(tag,gameData)
                        if item_count > 0 then
                            game_util:addMoveTips({text = string_helper.game_error_pop.useing});
                        else
                            game_util:addMoveTips({text = string_helper.game_error_pop.buying});
                        end
                    end
                    local function responseBuyMethod(tag,gameData)
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = itemId,num = 1},"item_use")
                    end
                    if item_count > 0 then
                        --使用道具
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_use"), http_request_method.GET, {item_id = itemId,num = 1},"item_use")
                    else
                        local params = {};
                        params.shop_id = value2;--购买用的是 shop id 使用道具用的是道具 id 
                        params.count = "1";
                        network.sendHttpRequest(responseBuyMethod,game_url.getUrlForKey("shop_buy"), http_request_method.GET, params,"shop_buy")
                    end
                end
            end
        else

        end
    elseif value1 == 2 then--2-进入伙伴出售页面
        game_scene:enterGameUi("game_hero_list",{showIndex = 2});
        self:destroy();
    elseif value1 == 3 then--3-进入技能强化页面
        game_scene:enterGameUi("skills_strengthen_scene",{});
        self:destroy();
    elseif value1 == 4 then--4-进入装备出售页面
        game_scene:enterGameUi("equipment_list",{showIndex = 2});
        self:destroy();
    elseif value1 == 5 then--5-进入充值页面
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            game_scene:enterGameUi("ui_vip",{gameData = gameData});
            self:destroy()
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
    elseif value1 == 6 then--6-返回主界面并领取资源存货
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    elseif value1 == 7 then--7-进入斗技场兑换页面
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_pk",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            self:destroy();
        end
        --  nil
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
    elseif value1 == 8 then--8-特殊，进入购买该系英雄技能点数的二次确认页面

    elseif value1 == 9 then--9-进入技能进阶页面
        game_scene:enterGameUi("skills_inheritance_scene",{gameData = nil});
        self:destroy();
    elseif value1 == 10 then--10-如果有ID的道具则使用道具，中间填道具ID

    elseif value1 == 11 then--11-进入道具商城页面
        function shopOpenResponseMethod(tag,gameData)
            game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
    elseif value1 == 12 then--12-进入章节选择页面
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    end

end

--[[--
    刷新ui
]]
function game_error_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_error_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_errorStatus = t_params.errorStatus;
end

--[[--
    创建ui入口并初始化数据
]]
function game_error_pop.create(self,t_params)
    self:init(t_params);
    local error_cfg = getConfig(game_config_field.error_cfg)
    local game_pop_up_box = require("game_ui.game_pop_up_box");
    local urltag = t_params.tag
    if self.m_errorStatus == "-1" and urltag == "arena_battle" then--竞技场重刷
        local errorMsg = t_params.errorMsg or "";
        local t_params = 
        {
            title = string_config.m_title_prompt,
            okBtnCallBack = function(target,event)
                local function responseMethod(tag,gameData)
                    game_util:closeAlertView();
                    game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
            end,   --可缺省
            closeCallBack = function(target,event)
                game_util:closeAlertView();
            end,
            okBtnText = string_helper.game_error_pop.confirm,       --可缺省
            text = errorMsg,      --可缺省
        }
        game_util:openAlertView(t_params);
        return
    end
    if error_cfg:getNodeWithKey(tostring(self.m_errorStatus)) == nil then
    -- if true then
        local errorMsg = t_params.errorMsg or "";
        cclog("self.m_errorStatus key is not found ===== " .. tostring(self.m_errorStatus));
        game_pop_up_box.close();
        game_pop_up_box.showAlertView((errorMsg ~= "" and errorMsg or string_config.m_data_error .. ";status=" .. tostring(self.m_errorStatus)));
        return nil;
    else
        cclog("self.m_errorStatus = " .. self.m_errorStatus)
        game_pop_up_box.close();
        if self.m_errorStatus == "error_4"  then
            game_scene:addPop("game_normal_tips_pop",{m_openType = 4})--钻石不足
        elseif self.m_errorStatus == "error_13"  then
            game_scene:addPop("game_normal_tips_pop",{m_openType = 13})--金币不足
        elseif self.m_errorStatus == "error_1"  then--伙伴满
            game_scene:addPop("game_normal_tips_pop",{m_openType = 1})--
        elseif self.m_errorStatus == "error_2"  then--装备满
            game_scene:addPop("game_normal_tips_pop",{m_openType = 2})--
        elseif self.m_errorStatus == "error_18"  then--尘不足
            game_scene:addPop("game_normal_tips_pop",{m_openType = 18})--
        elseif self.m_errorStatus == "error_19"  then--尘不足
            game_scene:addPop("game_normal_tips_pop",{m_openType = 19})--
        elseif self.m_errorStatus == "error_15"  then--战旗不足
            game_scene:addPop("game_normal_tips_pop",{m_openType = 15})--
        elseif self.m_errorStatus == "error_12"  then--
            game_scene:addPop("game_normal_tips_pop",{m_openType = 12})--
        elseif self.m_errorStatus == "error_20"  then--
            game_scene:addPop("game_normal_tips_pop",{m_openType = 20})--
        elseif self.m_errorStatus == "error_3"  then--行动力不足
            game_scene:addPop("game_normal_tips_pop",{m_openType = 3})--
        else
            local errorMsg = t_params.errorMsg or "";
            game_pop_up_box.showAlertView((errorMsg ~= "" and errorMsg or string_config.m_data_error .. ";status=" .. tostring(self.m_errorStatus)));
        end
        return nil;
    end
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_error_pop;