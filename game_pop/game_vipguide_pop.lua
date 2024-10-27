---  ui模版

local game_vipguide_pop = {
    m_node_reward = nil,
    m_rewardInfo = nil,
};
--[[--
    销毁ui
]]
function game_vipguide_pop.destroy(self)
    -- body
    cclog("----------------- game_vipguide_pop destroy-----------------"); 
    self.m_node_reward = nil;
    self.m_rewardInfo = nil;
end
--[[--
    返回
]]
function game_vipguide_pop.back(self,backType)
    game_scene:removePopByName("game_vipguide_pop");
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_vipguide_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        elseif ( btnTag >= 51 and btnTag <= 55 ) or (btnTag >= 251 and btnTag <= 255) then
                local info = self.m_rewardInfo[btnTag - 50]
                if info then
                    local tempType = info[1]
                    if tempType == 6 then--道具
                        local itemId = info[2]
                        game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                    elseif tempType == 7 then--装备
                        local equipId = info[2]
                        local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                        game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                    elseif tempType == 5 then--卡牌
                        local cId = info[2]
                        cclog("cId == " .. cId)
                        game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                    else                   -- 食品
                        game_scene:addPop("game_food_info_pop",{itemData = info})
                    end
                end
        elseif  btnTag == 101 then
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_vipguide_pop.ccbi");

    -- -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_conbtn_getReward = ccbNode:controlButtonForName("m_conbtn_getReward")    -- 购买按钮
    self.m_conbtn_getReward:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonTitle(self.m_conbtn_getReward,string_helper.ccb.title33)
    -- game_util:setControlButtonTitleBMFont(self.m_conbtn_getReward)


    self.m_scrollv_showInfo = ccbNode:scrollViewForName("m_scrollv_showInfo");
    -- 重置 scrollview 触摸优先级  防止被吞
    self.m_scrollv_showInfo:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    local nodeSprite = ccbNode:nodeForName("m_node_sprite")


    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local wuKongCfg = character_detail_cfg:getNodeWithKey(tostring(4600));
    local animation = wuKongCfg:getNodeWithKey("animation"):toStr();
    local rgb = wuKongCfg:getNodeWithKey("rgb_sort"):toInt();
    local tempIcon = game_util:createImgByName("image_" .. animation,rgb, true, true)
    -- tempIcon:setFlipX(true)
    tempIcon:setScale(1.4)
    tempIcon:setAnchorPoint(ccp(0.55, 0))

    nodeSprite:addChild(tempIcon)

    do
        local size = self.m_scrollv_showInfo:getContentSize()

        local ccbNode = luaCCBNode:create();
        ccbNode:registerFunctionWithFuncName("onMainBtnClick",onBtnClick);
        ccbNode:openCCBFile("ccb/ui_vipguide_shownode.ccbi");
        local m_label_vipinfo = ccbNode:labelTTFForName("m_label_vipinfo");
        m_label_vipinfo:setString(string_helper.ccb.file48);
        local title10 = ccbNode:labelTTFForName("title10");
        title10:setString(string_helper.ccb.title10);
        local title11 = ccbNode:labelTTFForName("title11");
        title11:setString(string_helper.ccb.title11);
        local title12 = ccbNode:labelTTFForName("title12");
        title12:setString(string_helper.ccb.title12);
        local title13 = ccbNode:labelTTFForName("title13");
        title13:setString(string_helper.ccb.title13);
        local title14 = ccbNode:labelTTFForName("title14");
        title14:setString(string_helper.ccb.title14);
        local title15 = ccbNode:labelTTFForName("title15");
        title15:setString(string_helper.ccb.title15);
        local title16 = ccbNode:labelTTFForName("title16");
        title16:setString(string_helper.ccb.title16);
        local title17 = ccbNode:labelTTFForName("title17");
        title17:setString(string_helper.ccb.title17);
        local title18 = ccbNode:labelTTFForName("title18");
        title18:setString(string_helper.ccb.title18);
        local title19 = ccbNode:labelTTFForName("title19");
        title19:setString(string_helper.ccb.title19);
        local title20 = ccbNode:labelTTFForName("title20");
        title20:setString(string_helper.ccb.title20);
        local title21 = ccbNode:labelTTFForName("title21");
        title21:setString(string_helper.ccb.title27);
        local title22 = ccbNode:labelTTFForName("title22");
        title22:setString(string_helper.ccb.title22);
        local title23 = ccbNode:labelTTFForName("title23");
        title23:setString(string_helper.ccb.title23);
        local title24 = ccbNode:labelTTFForName("title24");
        title24:setString(string_helper.ccb.title24);
        local title25 = ccbNode:labelTTFForName("title25");
        title25:setString(string_helper.ccb.title25);
        local title26 = ccbNode:labelTTFForName("title26");
        title26:setString(string_helper.ccb.title26);
        local title27 = ccbNode:labelTTFForName("title27");
        title27:setString(string_helper.ccb.title27);
        local title28 = ccbNode:labelTTFForName("title28");
        title28:setString(string_helper.ccb.title29);
        local title29 = ccbNode:labelTTFForName("title29");
        title29:setString(string_helper.ccb.title29);
        local title30 = ccbNode:labelTTFForName("title30");
        title30:setString(string_helper.ccb.title30);
        local title31 = ccbNode:labelTTFForName("title31");
        title31:setString(string_helper.ccb.title31);
        local title32 = ccbNode:labelTTFForName("title32");
        title32:setString(string_helper.ccb.title32);


        -- local showNode = CCNode:create()
        -- showNode:setContentSize(ccbNode:getContentSize())
        -- ccbNode:setAnchorPoint(ccp(0, 0))
        -- ccbNode:setPositionY(ccbNode:getContentSize().height)
        -- showNode:addChild(ccbNode)

        self.m_scrollv_showInfo:getContainer():removeAllChildrenWithCleanup(true);
        self.m_scrollv_showInfo:getContainer():addChild(ccbNode)
        self.m_scrollv_showInfo:setContentSize(ccbNode:getContentSize())
        self.m_scrollv_showInfo:setDirection(kCCScrollViewDirectionVertical)

        -- -- scroll 出现的时候显示成顶端
        local offsetY = ccbNode:getContentSize().height - self.m_scrollv_showInfo:getViewSize().height
        -- print("offsetY = ", offsetY)
        self.m_scrollv_showInfo:setContentOffset(ccp(0, -offsetY), false)

                  -- 图标按钮
        self.m_ticonbuttons = {}
        for i=1,5 do
            self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon" .. i)
            self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
            -- self.m_ticonbuttons[i]:setVisible(false);
        end


        local vipshop_cfg = getConfig(game_config_field.vip_shop)
        local gifts = vipshop_cfg:getNodeWithKey(tostring( 2 ))
        local need_cost = gifts:getNodeWithKey("need_coin"):toInt()  or 48
        local m_label_showcost = ccbNode:labelTTFForName("m_label_showcost")
        m_label_showcost:setString(tostring(need_cost))

        local reward = gifts:getNodeWithKey("reward")
        self.m_rewardInfo = {}
        local rewardCount = reward:getNodeCount();

        -- 卡片按钮设置
        for i=1, rewardCount do
            local icon,name,count = game_util:getRewardByItem(reward:getNodeAt(i-1),false);
            local iin = reward:getNodeAt(i-1)
            self.m_rewardInfo[i] = json.decode(iin:getFormatBuffer())
            if icon then
                icon:setAnchorPoint(ccp(0.5, 1))
                icon:setPosition(self.m_ticonbuttons[i]:getPosition())
                self.m_ticonbuttons[i]:getParent():addChild(icon, -1, 20)
                
                if name then
                    local blabelName = game_util:createLabelTTF({text = name, fontSize  = 7})
                    blabelName:setAnchorPoint(ccp(0.5, 1))
                    blabelName:setPosition(icon:getContentSize().width * 0.5, -2)
                    blabelName:setDimensions(CCSizeMake( icon:getContentSize().width * 1.4 , 0 ))
                    icon:addChild(blabelName, 10)
                    if count then
                        local blabelCount = game_util:createLabelTTF({text = string.format("x%d", count), fontSize  = 7})
                        blabelCount:setAnchorPoint(ccp(0.5, 1))
                        blabelCount:setPosition(icon:getContentSize().width * 0.5, blabelName:getPositionY() - blabelName:getContentSize().height)
                        icon:addChild(blabelCount, 11)
                    end
                end
            end
        end

        do
              -- 图标按钮
            self.m_ticonbuttons = {}
            for i=1,5 do
                self.m_ticonbuttons[i] =  ccbNode:controlButtonForName("m_conbtn_icon2" .. i)
                self.m_ticonbuttons[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
                -- self.m_ticonbuttons[i]:setVisible(false);
            end

            local info = {{7, 11501, 1}, {5, 4600, 1}, {9, 0, 168}}

            for i=1, #info do
                local icon,name,count = game_util:getRewardByItemTable(info[i]);
                local iin = reward:getNodeAt(i-1)
                self.m_rewardInfo[200 + i] = info[i]
                if icon then
                    icon:setAnchorPoint(ccp(0.5, 1))
                    icon:setPosition(self.m_ticonbuttons[i]:getPosition())
                    self.m_ticonbuttons[i]:getParent():addChild(icon, -1, 20)
                    
                    if name then
                        local blabelName = game_util:createLabelTTF({text = name, fontSize = 7})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(icon:getContentSize().width * 0.5, -2)
                        blabelName:setDimensions(CCSizeMake( icon:getContentSize().width * 1.4 , 0 ))
                        icon:addChild(blabelName, 10)
                        if count then
                            local blabelCount = game_util:createLabelTTF({text = string.format("x%d", count), fontSize = 7})
                            blabelCount:setAnchorPoint(ccp(0.5, 1))
                            blabelCount:setPosition(icon:getContentSize().width * 0.5, blabelName:getPositionY() - blabelName:getContentSize().height)
                            icon:addChild(blabelCount, 11)
                        end
                    end
                end
                end

            end

    end



   

    return ccbNode;
end
--[[--
    刷新ui
]]
function game_vipguide_pop.refreshUi(self)
    -- local level_giftCfg = getConfig(game_config_field.level_gift)
    -- local level = game_data:getUserStatusDataByKey("level")
    -- local levelGift = level_giftCfg:getNodeWithKey(tostring( self.m_tData.level ))
    -- local reward = levelGift:getNodeWithKey("reward")
    -- local cost = levelGift:getNodeWithKey("coin"):toInt()
    -- local des = levelGift:getNodeWithKey("des")
end
--[[--
    初始化
]]
function game_vipguide_pop.init(self,t_params)
    t_params = t_params or {}
end
--[[--
    创建ui入口并初始化数据
]]
function game_vipguide_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_vipguide_pop;
