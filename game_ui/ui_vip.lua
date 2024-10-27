---  VIP
local ui_vip = {
    m_vip_level = nil,
    m_need_money = nil,
    m_next_level = nil,
    m_table_view = nil,
    m_vip_node = nil,

    m_isOpen = nil,
    dimond_label = nil,

    vip_buy_step = nil,
    m_pay_btn = nil,
    anim_node = nil,
    vip_data = nil,
    month_award = nil,
    week_award = nil,
    m_item_pop = nil,
    m_index = nil,
    m_clickFlag = nil,
    m_recharge_tips2 = nil,
    m_clickActionNode = nil,
    m_notify_urls = nil,
};
--[[--
    销毁ui
]]
function ui_vip.destroy(self)
    cclog("-----------------ui_vip destroy-----------------");
    self.m_vip_level = nil;
    self.m_need_money = nil;
    self.m_next_level = nil;
    self.m_table_view = nil;
    self.m_vip_node = nil;
    self.dimond_label = nil;

    self.m_isOpen = false;

    self.vip_buy_step = nil;
    self.m_pay_btn = nil;

    self.anim_node = nil;
    self.vip_data = nil;
    self.month_award = nil;
    self.week_award = nil;
    self.m_item_pop = nil;
    self.m_index = nil;
    self.m_clickFlag = nil;
    self.m_recharge_tips2 = nil;
    self.m_clickActionNode = nil;
    self.m_notify_urls = nil;
end

local platform_channel = ""
if util_system.getPlatformChannel then
    platform_channel = tostring(util_system:getPlatformChannel()); -- 平台渠道号
end

local ios_charge_config = {
    platform_EAGAMEBOX = true,
    platform_haiwai = true,
    platform_en_internation = true;
}

local get_pay_notifyUrl_platform = 
{
    platform_youku = true,
    platform_haima = true,
    platform_en_internation = true,
    platform_internationalAndroid = true,
}


--[[--
    返回
]]

function ui_vip.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[
    更新vip数据
]]
function ui_vip.refreshVipData( self )
    if self.m_isOpen == false then
        return 
    end
    local vip_level = game_data:getVipLevel();
    -- vip_level = 10
    if vip_level < 10 then
        self.m_vip_level:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("vip_num_"..vip_level..".png"));
    else
        self.m_vip_level:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("vip_num_1.png"));
        local num_sprite = CCSprite:createWithSpriteFrameName("vip_num_0.png")

        local numPosX,numPosY = 76,30
        self.m_vip_level:setPosition(ccp(numPosX-10,numPosY))
        num_sprite:setAnchorPoint(ccp(0.5,0.5))
        num_sprite:setPosition(ccp(25,15))
        self.m_vip_level:addChild(num_sprite,10)
    end

    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local size_w = 180

    if visibleSize.width == 568 then
        size_w = 180 + 80;
    else
        size_w = visibleSize.width * 0.375
    end

    local vipLevel = game_data:getVipLevel()
    local vipExp = game_data:getVipExp()
    local vipCfg = getConfig(game_config_field.vip);
    
    local vip_exp = 1
    local next_exp = 1
    if vipLevel == 10 then
        local max = vipCfg:getNodeWithKey("10"):getNodeWithKey("need_exp"):toInt()
        vip_exp = max
        next_exp = max

        self.m_need_money:setString(0 .. string_helper.ui_vip.diamond)
        self.m_next_level:setString("VIP10")
    else
        local need_exp = vipCfg:getNodeWithKey(tostring(vipLevel)):getNodeWithKey("need_exp"):toInt()
        local last_exp = vipCfg:getNodeWithKey(tostring(vipLevel)):getNodeWithKey("need_exp"):toInt()

        vip_exp = vipExp
        next_exp = need_exp

        local need_more = need_exp - vipExp
        -- cclog("need_more == " .. need_more)

        self.m_need_money:setString(need_more .. string_helper.ui_vip.diamond)
        self.m_next_level:setString("VIP" .. (vipLevel + 1))
    end

    --设置钻石
    self.dimond_label:setString(tostring(game_data:getUserStatusDataByKey("coin")))

    local bar = ExtProgressBar:createWithFrameName("vip_icon_bar.png","vip_icon_progress.png",CCSizeMake(size_w,15));
    bar:setMaxValue(next_exp);
    local itemSize = self.m_vip_node:getContentSize();
    bar:setCurValue(vip_exp,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5+8))
    self.m_vip_node:addChild(bar,10)
    local barTTF = CCLabelTTF:create(vipExp.."/"..next_exp,TYPE_FACE_TABLE.Arial_BoldMT,12);
    barTTF:setAnchorPoint(ccp(0.5,0.5))
    barTTF:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5+7))
    self.m_vip_node:addChild(barTTF,10)

    local vipLevel = game_data:getVipLevel();
    -- cclog("self.vip_buy_step == " .. self.vip_buy_step)
    -- cclog("vipLevel == " .. vipLevel)
    if (vipLevel+1) > self.vip_buy_step then
        --买过了的不显示
        self.m_pay_btn:setOpacity(0);
        self.anim_node:removeAllChildrenWithCleanup(true)
        local animNode = game_util:createEffectAnim("anim_ui_viplibao",1.0,true)
        self.anim_node:addChild(animNode,10)
    else
        self.m_pay_btn:setOpacity(255);
        self.anim_node:removeAllChildrenWithCleanup(true)
    end

    -- 隐藏 vip 经验
    if game_data:isViewOpenByID(104) then
        self.m_vip_node:setVisible(true)
    else
        self.m_vip_node:setVisible(false)
    end

    -- vip 礼包
    if game_data:isViewOpenByID(105) then
        self.m_pay_btn:setVisible(true)
        self.anim_node:setVisible(true)
    else
        self.m_pay_btn:setVisible(false)
        self.anim_node:setVisible(false)
    end

    -- vip 特权
    if game_data:isViewOpenByID(106) then
        self.btn_privilege:setVisible(true)
    else
        self.btn_privilege:setVisible(false)
    end
end
--[[--
    读取ccbi创建ui
]]
function ui_vip.createUi(self)
    self.m_isOpen = true;
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            self:back();
        elseif btnTag == 101 then--特权
            game_scene:addPop("ui_vip_show_pop")
        elseif btnTag == 102 then--神级伙伴
            -- chongzhiFunc(8)
            --跳转到vip活动里去购买
            --------------改成直接购买了------------
            -- local function responseMethod(tag,gameData)
            --     game_scene:enterGameUi("game_activity",{gameData = gameData,vip_index = 8})
            --     self:destroy()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        elseif btnTag == 103 then--月度好礼
            -- chongzhiFunc(9)
            --------------改成直接购买了------------
            -- local function responseMethod(tag,gameData)
            --     game_scene:enterGameUi("game_activity",{gameData = gameData,vip_index = 9})
            --     self:destroy()
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
        elseif btnTag == 500 then--特权礼包
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")

                -- cclog("shop_vip_buy -- " .. data:getFormatBuffer())
                local function endCallBackFunc(index)
                    self.vip_buy_step = index
                    cclog("index = " .. index)
                    self:refreshVipData()
                end
                game_scene:addPop("ui_vip_show_gift_pop",{gameData = json.decode(data:getNodeWithKey("vip_bought"):getFormatBuffer()),endCallBackFunc=endCallBackFunc,buy_index = self.vip_buy_step,vip_data = self.vip_data})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
        elseif btnTag == 200 then--刷新
            local function responseMethod(tag,gameData)
                self:refreshVipData()
            end
            network.sendHttpRequest( responseMethod , game_url.getUrlForKey("user_refresh") , http_request_method.GET , {} , "flush_user");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_vip_2.ccbi");

    self.m_clickActionNode = CCNode:create()
    ccbNode:addChild(self.m_clickActionNode)

    self.m_vip_level = ccbNode:spriteForName("vip_number_sprite");
    self.m_need_money = ccbNode:labelTTFForName("vip_need_money_label");
    self.m_next_level = ccbNode:labelTTFForName("next_vip_label");
    self.m_table_view = ccbNode:nodeForName("vip_table_node");
    self.m_vip_node = ccbNode:nodeForName("vip_node");
    self.dimond_label = ccbNode:labelBMFontForName("diomond_label")
    self.m_pay_btn = ccbNode:controlButtonForName("m_pay_btn")
    self.anim_node = ccbNode:nodeForName("anim_node")
    -- self.refresh_btn = ccbNode:controlButtonForName("")
    self.m_recharge_tips2 = ccbNode:labelTTFForName("m_recharge_tips2");
    self.m_recharge_tips2:setFontSize( 10 )
    self.m_recharge_tips2:setString(string_helper.ccb.file44);
    local title44 = ccbNode:labelTTFForName("title44");
    local title45 = ccbNode:labelTTFForName("title45");
    title45:setString(string_helper.ccb.title45);
    title44:setString(string_helper.ccb.title44);
    self.btn_privilege = ccbNode:controlButtonForName("btn_privilege")
    game_util:setCCControlButtonTitle(self.btn_privilege,string_helper.ccb.title43)
    -- game_util:setControlButtonTitleBMFont(self.btn_privilege)
    self:refreshVipData();
    return ccbNode;
end
--[[
    创建vip table
]]
function ui_vip.createVipTable(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");
    
    local function payEnd( msg )
        if(msg == "pay err")then
            -- iap不成功
        elseif(msg == "pay product err")then
            game_util:addMoveTips({text = string_helper.ui_vip.sky_error});
        elseif(msg == "pay data ready")then
            -- 服务器验证成功
        elseif(msg == "pay data err")then
            -- 服务器验证单据错误
        else
            -- iap成功,msg为iap的boundle
            -- local tempNode = nil;
            -- for i=0,shopCount-1 do
            --     tempNode = gameShopConfig:getNodeAt(i);
            --     if(tempNode:getNodeWithKey("cost"):toStr()==msg)then
            --         local tempCoin = tempNode:getNodeWithKey("coin"):toInt();
            --         game_data.m_tUserStatusData.coin=game_data.m_tUserStatusData.coin+tempCoin;
            --         game_scene:fillPropertyBarData();
            --         -- self.m_num_label:setString(tostring(game_data:getUserStatusDataByKey("coin") or 0));
            --     end
            -- end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                self.vip_buy_step = data:getNodeWithKey("step"):getNodeCount()
                temp = json.decode(data:getNodeWithKey("double_pay"):getFormatBuffer())
                for i=1,#temp do
                    local vipData = temp[i]
                    self.vip_data[vipData] = 1
                end
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(self.m_index) .. '-' .. tostring(os.time());
                if game_data_statistics then
                    game_data_statistics:paySuccess({order = orderIdCom})
                end
                game_util:addMoveTips({text = string_helper.ui_vip.cost_success})
                self:refreshVipData()
                self:refreshUi();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
        require("game_ui.game_loading").close();
    end
    if registerCallBack then
        registerCallBack(payEnd);
    end
    local function chongzhiFunc(index)
        self.m_index = index;
        -- local gameShopConfig = getConfig(game_config_field.charge);
        --这里分安卓和IOS取不同的配置
        local gameShopConfig = nil;
        if  ios_charge_config[tostring(getPlatFormExt())] == true then
            gameShopConfig = getConfig(game_config_field.charge);--ios
        else
            gameShopConfig = getConfig(game_config_field.buykubi_android);--android
        end
        local moneyConfig = gameShopConfig:getNodeWithKey(tostring(index))
        if moneyConfig ~= nil then
            local bundle = moneyConfig:getNodeWithKey("cost"):toStr();
            if getPlatForm() == "91" then
                -- if PLATFORM.isLogined()
                local userInfo = PLATFORM.getUserinfo()
                local selfUid = game_data:getUserStatusDataByKey('uid');
                --拼出91_加loginUin
                local loginUin = "91_"..tostring(selfUid).."_"
                local coin = moneyConfig:getNodeWithKey("price"):toStr()
                local cooOrderSerial = loginUin..tostring(os.time()).."_"..tostring(coin)
                cclog("------------- 91 buy " .. cooOrderSerial);
                local productId = tostring(index)
                local productName = moneyConfig:getNodeWithKey("name"):toStr();
                local productPrice = coin
                local productOrignalPrice = coin
                -- local productPrice = 0.01
                -- local productOrignalPrice = 0.01
                local productCount = 1
                --描述，uid和服务器号
                local server_data,sindex = game_data:getServer()
                local server = server_data.server
                local payDescription = user_token..","..tostring(server)
                local function onPaySuccess()
                    if game_data_statistics then
                        game_data_statistics:paySuccess({order = cooOrderSerial})
                    end
                    game_util:addMoveTips({text = string_helper.ui_vip.diamond_cost_sd})
                    -- local function responseMethod(tag,gameData)
                        -- require("game_ui.ui_vip"):refreshVipData();
                        -- require("game_ui.game_activity"):reEnter()
                        -- self:refreshVipData()
                    -- end
                    -- network.sendHttpRequest( responseMethod , game_url.getUrlForKey("user_refresh") , http_request_method.GET , {} , "flush_user");
                end
                if game_data_statistics then
                    game_data_statistics:payBegan({order = cooOrderSerial,productId=productId,productPrice=productPrice,currencyType = "CNY"})
                end
                PLATFORM.addCallback("SDKNDCOM_PAY_SUCCESS",onPaySuccess)
                local function onPayFailed()
                    if game_data_statistics then
                        game_data_statistics:payFailed({order = cooOrderSerial})
                    end
                end
                PLATFORM.addCallback("SDKNDCOM_PAY_FAIL",onPayFailed)
                PLATFORM.uniPayAsyn(cooOrderSerial,productId,productPrice,productName,productOrignalPrice,productCount,payDescription)
            elseif(getPlatForm() == "pp")then
                -- 用户uid
                -- serverid
                -- 商品配置id
                -- os.time();
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server

                local paramPrice = moneyConfig:getNodeWithKey("price"):toStr();
                local paramBillNo = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
                local paramBillTitle = moneyConfig:getNodeWithKey("name"):toStr();
                local paramRoleId = '0';
                local paramZoneId = 0;
                if game_data_statistics then
                    CCUserDefault:sharedUserDefault():setStringForKey("PP_BILL_NO",paramBillNo)
                    CCUserDefault:sharedUserDefault():flush()
                    game_data_statistics:payBegan({order = paramBillNo,productId=tostring(index),productPrice=paramPrice,currencyType = "CNY"})
                end

                PP_CLASS:sharedInstance():exchangeGoods(paramPrice , paramBillNo , paramBillTitle , paramRoleId , paramZoneId);
            elseif getPlatForm() == "itools" then
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
                local amount = moneyConfig:getNodeWithKey("price"):toStr();
                if game_data_statistics then
                    game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"})
                end
                local des = moneyConfig:getNodeWithKey("name") and moneyConfig:getNodeWithKey("name"):toStr() or string_helper.ui_vip.diamond_pack
                PLATFORM_ITOOLS.setPayViewAmount(orderIdCom,amount, des)
            elseif getPlatForm() == "cmge" then
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
                local amount = moneyConfig:getNodeWithKey("price"):toStr();
                local name = moneyConfig:getNodeWithKey("name"):toStr()
                local onCmgePaySuccess = function ()
                    if game_data_statistics then
                        game_data_statistics:paySuccess({order = orderIdCom})
                    end
                    game_util:addMoveTips({text = string_helper.ui_vip.diamond_cost_sd})
                end
                if game_data_statistics then
                    game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"})
                end
                -- amount = 0.01
                PLATFORM_CMGE.addCallback("CMGE_NOTIFICATION_PAY_SUCCESS",onCmgePaySuccess)
                PLATFORM_CMGE.enterRechargeCenterView("M1063",orderIdCom,amount,name)
            elseif getPlatForm() == "platformCommon" or getPlatForm() == "coolpay" then

                local bundle = moneyConfig:getNodeWithKey("cost"):toStr();
                print("---------------- pay with platformCommon coolpay --------------- ")

                local params = {}
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(game_data:getUserStatusDataByKey('uid')) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());


                params.product_app_id = tostring(bundle) or tostring(index)
                params.orderid = orderIdCom
                params.userId = game_data:getUserStatusDataByKey("uid")
                local price = moneyConfig:getNodeWithKey("price"):toStr()
                params.unit = string.format("%.2f",price)
                params.description = moneyConfig:getNodeWithKey("name"):toStr()
                params.pructId = tostring(index)
                params.count = 1
                params.extUrl = game_url.getUrlForKey("get_vivo_order_id") --为vivo使用
                params.queryUrl = game_url.getUrlForKey("get_query_order") --为vivo使用

                -- cclog2(self.m_notify_urls["youku"], "self.m_notify_urls[youku]  ====  ")
                params.youkuUrl = self.m_notify_urls["youku"] or "nil"
                params.allPayNotifyUrl = self.m_notify_urls
                -- params.platform = getPlatFormExt() or "nil"
                params.platform = "nil"
                params.roleName = game_data:getUserStatusDataByKey("show_name") or ""-- 兄弟玩 独家专享
                params.roleLevel = game_data:getUserStatusDataByKey("level") or 1--兄弟玩 独家专享

                params.jinliUrl = game_url.getUrlForKey("get_jinli_order") --金立独家专享
                params.tgameUrl = self.m_notify_urls["tigergame_android"] or nil
                params.pay_respon_url = game_url.getUrlForKey("pay_respon_url")--动态获得支付回调地址
                params.uservip = game_data:getUserStatusDataByKey("vip") or 0
                params.userOwnCoin = game_data:getUserStatusDataByKey("coin") or 0 
                params.serverId = serverId
                params.cost = moneyConfig:getNodeWithKey("cost"):toStr();
                -- local tempStr = "";
                -- if string.len(platform_channel) >= 3 then  -- 最开始的包写的channel为 "7ku", 后改为 "7ku_***"
                --     tempStr = string.sub(platform_channel,0,3)
                -- end


                local function refreshUi()
                    -- body
                    local function responseMethod(tag,gameData)
                        self:refreshVipData()
                    end
                    network.sendHttpRequest( responseMethod , game_url.getUrlForKey("user_refresh") , http_request_method.GET , {} , "flush_user");
                end
                
                local function buyResult(data)
                    if platform_channel == "xiaomi" then
                        self.m_clickFlag = false;
                    end
                    -- body
                    local result = data["result"]
                    -- cclog("--- buy result cod %d", result)
                    if result == 0 then 
                        if game_data_statistics then
                            game_data_statistics:paySuccess({order = orderIdCom})
                        end
                        if index == 1 then--提示月卡礼包
                            game_util:addMoveTipsForNative({text = string_helper.ui_vip.month_cost})
                            self.month_award = 0
                        elseif index == 2 then--提示周卡礼包
                            game_util:addMoveTipsForNative({text = string_helper.ui_vip.week_cost})
                            self.week_award = 0
                        else
                            game_util:addMoveTipsForNative({text = string_helper.ui_vip.diamond_cost})
                        end
                        refreshUi()
                    elseif result == 1 then
                        if game_data_statistics then
                            game_data_statistics:payFailed({order = orderIdCom})
                        end
                        if data["errmsg"] ~= nil then
                            game_util:addMoveTipsForNative({text = data["errmsg"]})
                        else
                            game_util:addMoveTipsForNative({text = string_helper.ui_vip.cost_faild})
                        end
                    elseif result == -1 then
                        if game_data_statistics then
                            game_data_statistics:payFailed({order = orderIdCom})
                        end
                        game_util:addMoveTipsForNative({text = string_helper.ui_vip.ct_fd})
                    else
                        if game_data_statistics then
                            game_data_statistics:payFailed({order = orderIdCom})
                        end
                        --不知道支付结果，刷新界面
                        refreshUi()
                    end
                end
                if game_data_statistics then
                    game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=moneyConfig:getNodeWithKey("price"):toStr(),currencyType = "CNY"})
                end
                require("shared.native_helper").buyProduct(params,buyResult)

            elseif getPlatForm() == "cmgeapp" or getPlatForm() == "appstore" then
                cclog("cmgeapp or appstore")
                cclog("bundle == " .. tostring(bundle))
                buy(bundle);
                require("game_ui.game_loading").show();
                local selfUid = game_data:getUserStatusDataByKey('uid');
                local server_data,sindex = game_data:getServer()
                local serverId = server_data.server
                local orderIdCom = tostring(selfUid) .. "-" .. tostring(serverId) .. '-' .. tostring(index) .. '-' .. tostring(os.time());
                local amount = moneyConfig:getNodeWithKey("price"):toStr();
                if game_data_statistics then
                    game_data_statistics:payBegan({order = orderIdCom,productId=tostring(index),productPrice=amount,currencyType = "CNY"})
                end
            end
        end
    end
    local function onCellBtnClick(index)
        local buysth = function( )
            if index == 1 then--月礼包
                --------------改成直接购买了------------
                -- local function responseMethod(tag,gameData)
                --     game_scene:enterGameUi("game_activity",{gameData = gameData,vip_index = 9})
                --     self:destroy()
                -- end
                -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
                
                --改--
                -- chongzhiFunc(index)
                if self.month_award == 2 then--可买
                    chongzhiFunc(index)
                else--买过了
                    game_util:addMoveTips({text = string_helper.ui_vip.award_cost})
                end
            elseif index == 2 then--周礼包
                --------------改成直接购买了------------
                -- local function responseMethod(tag,gameData)
                --     game_scene:enterGameUi("game_activity",{gameData = gameData,vip_index = 8})
                --     self:destroy()
                -- end
                -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
                --改--
                -- chongzhiFunc(index)
                if self.week_award == 2 then--可买
                    chongzhiFunc(index)
                else
                    game_util:addMoveTips({text = string_helper.ui_vip.week_cost_rd})
                end
            else
                chongzhiFunc(index)
            end
        end
        if  self:isNeedGetPayNotifyUrl( getPlatFormExt() ) then
            self:getPayCallURLS( buysth )
        else
            buysth()
        end
    end
    local function onOkBtnClick(target,event)
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        -- if btnTag == 1 then --月卡
        --     local t_params = {}
        --     game_scene:addPop("game_month_gift_pop",t_params)
        -- elseif btnTag == 2 then--周卡
            if self.m_item_pop then
                self.m_item_pop:removeAllChildrenWithCleanup(true);
                self.m_item_pop = nil;
            end
            self.m_item_pop = self:addRewardPop(btnTag)
            self.m_item_pop:setAnchorPoint(ccp(0,0.5));
            local pX,pY = tagNode:getPosition();
            local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX-60,pY-10))
            self.m_item_pop:setPosition(tempPos);
            game_scene:getPopContainer():addChild(self.m_item_pop)
        -- end
    end
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(4100));
    local banYeCfg = character_detail_cfg:getNodeWithKey(tostring(1900));

    -- local vipShopCfg = getConfig(game_config_field.charge);
    local vipShopCfg = nil;
    if ios_charge_config[tostring(getPlatFormExt())] == true then
        vipShopCfg = getConfig(game_config_field.charge);
    else
        vipShopCfg = getConfig(game_config_field.buykubi_android);
    end
    
    local vipCount = vipShopCfg:getNodeCount()
    local showTable = {}
    for i=1,vipCount do
        local itemCfg = vipShopCfg:getNodeWithKey(tostring(i))
        if itemCfg:getNodeWithKey("is_show") then
            local is_show = itemCfg:getNodeWithKey("is_show"):toInt()
            if true then
                table.insert(showTable,i)
                -- showTable.id = i
            end
        else
            -- table.insert(showTable,i)

        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 3;
    params.column = 2;
    params.totalItem = game_util:getTableLen(showTable);
    if getPlatForm() == "coolpay" then 
        params.totalItem = 9
    end
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    local money_table = {6,30,60,98,198,328,648};
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onOkBtnClick);
            ccbNode:openCCBFile("ccb/ui_vip_item_2.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
            local btn_accepted = ccbNode:controlButtonForName("btn_accepted")
            game_util:setCCControlButtonTitle(btn_accepted,string_helper.ccb.title42)
            btn_accepted:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
            -- game_util:setControlButtonTitleBMFont(btn_accepted)
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");

            local vip_box = ccbNode:spriteForName("vip_box_sprite");
            local vip_pay = ccbNode:spriteForName("vip_pay_sprite");
            local vip_money = ccbNode:labelBMFontForName("vip_money_label");
            -- local vip_buy = ccbNode:controlButtonForName("btn_buy");
            local double_sprite = ccbNode:spriteForName("double_sprite")
            local vip_icon_node = ccbNode:nodeForName("vip_icon_node")
            local extra_text = ccbNode:labelTTFForName("extra_text")
            local btn_accepted = ccbNode:controlButtonForName("btn_accepted")

            local id = showTable[index+1]
            local itemCfg = vipShopCfg:getNodeWithKey(tostring(id))
            local need_money = itemCfg:getNodeWithKey("price"):toStr()
            local iconName = itemCfg:getNodeWithKey("icon"):toStr()
            local des = itemCfg:getNodeWithKey("des"):toStr()
            -- vip_box:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("vip_money_" .. id .. ".png"));
            local payTempSpr = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring("vip_pay_" .. id .. ".png")))
            if payTempSpr then
                vip_pay:setDisplayFrame(payTempSpr:displayFrame());
            end
            need_money = string.format("%.2f",need_money)
            vip_money:setString( string_helper.ui_vip.yuan .. need_money );
            local is_double = itemCfg:getNodeWithKey("is_double"):toInt()
            if is_double == 0 then--无首冲双倍
                double_sprite:setVisible(false)
                extra_text:setString(des)
            else
                local coin = itemCfg:getNodeWithKey("coin"):toInt()
                extra_text:setString(string_helper.ui_vip.first_cost .. coin .. string_helper.ui_vip.diamond)
                -- for i=1,#self.vip_data do
                --     local double_flag = self.vip_data[i]
                --     if index + 1 == double_flag then--已经充过了
                --         double_sprite:setVisible(false)
                --         extra_text:setString(des)
                --         break
                --     else
                --         double_sprite:setVisible(true)
                --     end
                -- end

                if self.vip_data[id] == 1 then--已经充过了
                    double_sprite:setVisible(false)
                    extra_text:setString(des)
                else
                    double_sprite:setVisible(true)
                end
            end
            if id == 2 then
                vip_icon_node:removeAllChildrenWithCleanup(true)
                
                local cardNode = game_util:createCardImgByCfg(banYeCfg)
                cardNode:setScale(0.65)
                cardNode:setPosition(ccp(0,8))
                cardNode:setAnchorPoint(ccp(0.5,0.5))
                vip_icon_node:addChild(cardNode,10,10)
                btn_accepted:setVisible(true)
                btn_accepted:setTag(2)
            elseif id == 1 then
                vip_icon_node:removeAllChildrenWithCleanup(true)
                local cardNode = game_util:createCardImgByCfg(wuKongCfg)
                cardNode:setScale(0.65)
                cardNode:setPosition(ccp(0,8))
                cardNode:setAnchorPoint(ccp(0.5,0.5))
                vip_icon_node:addChild(cardNode,10,10)
                btn_accepted:setVisible(true)
                btn_accepted:setTag(1)
            else
                vip_icon_node:removeAllChildrenWithCleanup(true)
                local tempSpr = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(iconName)))
                if tempSpr then
                    -- vip_box:setDisplayFrame(tempSpr:displayFrame());
                    tempSpr:setAnchorPoint(ccp(0.5,0.5))
                    tempSpr:setPosition(ccp(0,0))
                    tempSpr:setScale(0.7)
                    vip_icon_node:addChild(tempSpr,10,10)
                end
                btn_accepted:setVisible(false)
            end
            cell:setTag(100+id)
        end
        -- cell:setTag(101 + index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode")
            -- if platform_channel == "xiaomi" then
            --     if self.m_clickFlag == true then
            --         return;
            --     end
            --     self.m_clickFlag = true;
            -- end
            if self.m_clickFlag == true then
                -- cclog2("等待上一次点击时间")
                return;
            end
            if self.m_clickActionNode then
                self.m_clickActionNode:stopAllActions()
                schedule(self.m_clickActionNode, function ()
                    self.m_clickFlag = false
                end, 1.5)
            end
            self.m_clickFlag = true;
            local id = showTable[index+1]
            onCellBtnClick(id)
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建显示奖励
]]
function ui_vip.addRewardPop(self,rewardType)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/gift_show_pop2.ccbi");
    local m_touch_layer = ccbNode:layerForName("m_touch_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then 
            if self.m_item_pop then
                self.m_item_pop:removeAllChildrenWithCleanup(true);
                self.m_item_pop = nil;
            end
            return true;
        end
    end
    --先根据type计算出总量
    local finalTable = {}
    if rewardType == 2 then
        local weekCfg = getConfig(game_config_field.week_award)
        local weekReward = weekCfg:getNodeAt(0):getNodeWithKey("award")
        finalTable = json.decode(weekReward:getFormatBuffer())
    else
        local testTab = {}
        local keyTab = {}
        local monthCfg = getConfig(game_config_field.month_award)
        for i=1,monthCfg:getNodeCount() do
            local itemCfg = monthCfg:getNodeAt(i-1)
            local itemReward = itemCfg:getNodeWithKey("award")
            for j=1,itemReward:getNodeCount() do
                local singleRew = itemReward:getNodeAt(j-1)

                local a_type = singleRew:getNodeAt(0):toInt()
                local a_det = singleRew:getNodeAt(1):toInt()
                local a_count = singleRew:getNodeAt(2):toInt()

                testTab[a_type] = testTab[a_type] or {}

                testTab[a_type][1] = testTab[a_type][1] or 0
                testTab[a_type][2] = testTab[a_type][2] or 0
                testTab[a_type][3] = testTab[a_type][3] or 0

                testTab[a_type][1] = a_type
                testTab[a_type][2] = testTab[a_type][2] + a_det
                testTab[a_type][3] = testTab[a_type][3] + a_count
            end
        end
        for k,v in pairs(testTab) do
            table.insert(finalTable,v)
        end
    end

    --把奖励显示出来
    local reward_node = ccbNode:nodeForName("reward_node")
    reward_node:removeAllChildrenWithCleanup(true)

    local dx = 0
    local ox = 0
    local scale = 1
    if #finalTable == 4 then
        dx = 55
        ox = -82
    else
        dx = 222 / #finalTable
        ox = -87
        scale = 0.7
    end
    for i=1,#finalTable do
        local itemData = finalTable[i]
        local icon,name,count = game_util:getRewardByItemTable(itemData);
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setScale(scale)
        icon:setPosition(ccp(ox + (i-1) * dx,0))
        local textLabel = game_util:createLabelBMFont({text = "×" .. count,color = ccc3(255,255,255)});
        textLabel:setPosition(ccp(ox + (i-1) * dx,-25))

        reward_node:addChild(icon)
        reward_node:addChild(textLabel)
    end

    local tips_sprite = ccbNode:spriteForName("tips_sprite")
    if rewardType == 1 then
        tips_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_month_text.png"));
    else
        tips_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_week_text.png"));
    end

    m_touch_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_touch_layer:setTouchEnabled(true)
    return ccbNode
end

--[[--
    刷新ui
]]
function ui_vip.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createVipTable(self.m_table_view:getContentSize());
    -- tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);
    local vipLevel = game_data:getUserStatusDataByKey("vip") or 0
    if vipLevel == 0 then
        self.m_recharge_tips2:setVisible(true);
    else
        self.m_recharge_tips2:setVisible(false);
    end
end


local errorTab = {
    error_500 = "服务器出错了，请稍后再试！",
    error_502 = "服务器出问题了，请稍后再试！",
}

--[[
   -- 获取回调地址 
]]
function ui_vip.getPayCallURLS( self, getUrlsCallBack )
    cclog2("getPayCallURLS =======  ")
    local method = 0
    local url = game_url.getUrlForKey("pay_respon_url");
    local httpReq = CCHttpRequest:new()
        httpReq:setUrl(url)
    local callback = function ( tag,response,contentLength )
        require("game_ui.game_loading").close();
        contentLength = contentLength or 0;
        cclog("responseMethod --------tag=%s,code=%d  ; callbackTab == %s",tag,response:getResponseCode(),tostring(callbackTab),contentLength);
        if response:isSucceed()==false then
            local responseCode = response:getResponseCode()
            local errorMsg = errorTab["error_" .. tostring(responseCode)];
            if errorMsg then
                require("game_ui.game_pop_up_box").showAlertView(errorMsg);
            else
                require("game_ui.game_pop_up_box").showAlertView(string_config.m_net_req_failed);
            end
            retrunFlag = true;
        else
            local buffer = response:getResponseDataBuffer();
            local gameData = util_json:new(buffer);
            
            if gameData and (not gameData:isEmpty()) then 
                cclog2(gameData, "gameData ===  ")
                self.m_notify_urls = gameData:getNodeWithKey("notify_urls") and json.decode(gameData:getNodeWithKey("notify_urls"):getFormatBuffer()) or {}
            end
            if type(getUrlsCallBack) == "function" then
                getUrlsCallBack()
            end
        end
    end
    httpReq:registerScriptTapHandler(callback)
    httpReq:setRequestType(method)
    httpReq:setTag("pay_respon_url")
    CCHttpClient:getInstance():send(httpReq)
    httpReq:release()
    -- game_util:addMoveTips({text = "正在支付"})
    -- cclog("get http start ----- tag = " .. "pay_respon_url " .. ";url = " .. url);
    require("game_ui.game_loading").show();
end

--[[--
    初始化
]]
function ui_vip.init(self,t_params)
    t_params = t_params or {};
    self.vip_data = {0,0,0,0,0,0,0}
    local temp = {}
    -- cclog("m_tUserStatusData = " .. json.encode(game_data:getUserStatusData()))
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.vip_buy_step = t_params.gameData:getNodeWithKey("data"):getNodeWithKey("step"):getNodeCount()
        temp = json.decode(t_params.gameData:getNodeWithKey("data"):getNodeWithKey("double_pay"):getFormatBuffer())
        if t_params.gameData:getNodeWithKey("data"):getNodeWithKey("month_award") then
            self.month_award = t_params.gameData:getNodeWithKey("data"):getNodeWithKey("month_award"):toInt()
            self.week_award = t_params.gameData:getNodeWithKey("data"):getNodeWithKey("week_award"):toInt()
        end
    end
    for i=1,#temp do
        local vipData = temp[i]
        self.vip_data[vipData] = 1
    end
    self.m_item_pop = nil;
    -- cclog("self.vip_data == " .. json.encode(self.vip_data))
    self.m_clickFlag = false;
    self.m_notify_urls = {}
end

--[[
    支付之前是否需要请求支付回调地址
]]
function ui_vip.isNeedGetPayNotifyUrl( self, platform )
    if get_pay_notifyUrl_platform[tostring(platform)] == true then
        cclog2(platform, " vi vip ,this platform need get pay  notify_urls ")
        return true
    end
    return false
end

--[[--
    创建ui入口并初始化数据
]]
function ui_vip.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_vip;