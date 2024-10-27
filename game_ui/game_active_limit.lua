---  限时活动
local game_active_limit = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_idTab = nil,

    rank_node = nil,
    left_time_node = nil,
    btn_gacha = nil,
    btn_gacha_10 = nil,
    free_one_node = nil,
    free_ten_node = nil,
    reward_table_node = nil,
    points_label = nil,
    points_rank_label = nil,
    left_dimond_label = nil,
    btn_recharge = nil,
    btn_detail = nil,
    anim_node = nil,

    m_cardIdTab = nil,
    m_gachaAnimEndFlag = nil,
    m_delayTimeIndex = nil,
    m_gachaAnimTab = nil,
    m_mask_layer = nil,
    m_maxQuality = nil,
    m_maxQualityCardId = nil,

    m_node_maskshowLeade = nil,
    m_node_maskshow_myscore = nil,
    m_node_maskshow_showmain = nil,
    m_node_maskshow_showreward = nil,
    open_type = nil,
    m_rank_data = nil,
};
--[[--
    销毁ui
]]
function game_active_limit.destroy(self)
    -- body
    cclog("----------------- game_active_limit destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;

    self.rank_node = nil;
    self.left_time_node = nil;
    self.btn_gacha = nil;
    self.btn_gacha_10 = nil;
    self.free_one_node = nil;
    self.free_ten_node = nil;
    self.reward_table_node = nil;
    self.points_label = nil;
    self.points_rank_label = nil;
    self.left_dimond_label = nil;
    self.btn_recharge = nil;
    self.btn_detail = nil;
    self.anim_node = nil;

    self.m_cardIdTab = nil;
    self.m_gachaAnimEndFlag = nil;
    self.m_delayTimeIndex = nil;
    self.m_gachaAnimTab = nil;
    self.m_mask_layer = nil;
    self.m_maxQuality = nil;
    self.m_maxQualityCardId = nil;

    self.m_node_maskshowLeade = nil;
    self.m_node_maskshow_myscore = nil;
    self.m_node_maskshow_showmain = nil;
    self.m_node_maskshow_showreward = nil;
    self.open_type = nil;
    self.m_rank_data = nil;
end
--[[--
    返回
]]
function game_active_limit.back(self,backType)
    -- game_scene:removePopByName("game_active_limit");
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_active_limit.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 11 then--充值
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 12 then--查看详情
            if self.open_type == 1 then
                local active_msg = ""
                local version = self.m_tGameData.version
                local limit_hero_score_cfg = getConfig(game_config_field.limit_hero_score)
                local tempCount = limit_hero_score_cfg and limit_hero_score_cfg:getNodeCount() or 0
                for i=1, tempCount do
                    local itemCfg = limit_hero_score_cfg:getNodeAt(i - 1)
                    if game_util:compareItemCfgVersion( itemCfg, version ) then
                        active_msg = itemCfg:getNodeWithKey("notice") and itemCfg:getNodeWithKey("notice"):toStr() or ""
                        if string.len(active_msg) > 0 then
                            break
                        end
                    end
                end
                game_scene:addPop("game_active_limit_detail_pop",{ openMsg = active_msg})
            else
                game_scene:addPop("game_active_limit_detail_pop",{cfgKey = "904"})
            end
        elseif btnTag == 101 then--钻石招募
            local gacha_coin = self.m_tGameData.gacha_coin
            local gacha_id = gacha_coin.gacha_id
            local params = {}
            params.reward_gacha_id = gacha_id

            function shopOpenResponseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                local new_card = data:getNodeWithKey("new_card")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                self.m_cardIdTab = json.decode(new_card:getFormatBuffer()) or {};
                local new_card_count = #self.m_cardIdTab
                if new_card_count == 1 then
                    local pX,pY = tagNode:getPosition();
                    local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX,pY))
                    self.m_animStartPos = {x = tempPos.x,y = tempPos.y}
                    self.m_mask_layer:setVisible(true);
                    self.m_mask_layer:setTouchEnabled(true);
                    self.m_maxQuality,self.m_maxQualityCardId = self:getGachaCardQuality();
                    self:createFirstHeroAnim(self.m_maxQualityCardId);
                    self.m_anim_node:setVisible(false);
                    self:addGachaAnim(self.m_maxQuality);
                end
            end
            if self.open_type == 1 then
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("do_reward_gacha"), http_request_method.GET, params,"do_reward_gacha")
            else
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_limit_hero_do"), http_request_method.GET, params,"server_limit_hero_do")
            end
        elseif btnTag == 102 then--钻石10抽
            local gacha_ten = self.m_tGameData.gacha_ten
            local gacha_id = gacha_ten.gacha_id

            local params = {}
            params.reward_gacha_id = gacha_id
            function shopOpenResponseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                --reward 得的碎片
                --newcard 是卡牌，要播放gacha动画
                local reward = data:getNodeWithKey("reward")
                game_util:rewardTipsByJsonData(reward);
                local new_card = data:getNodeWithKey("new_card")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshUi()
                self.m_cardIdTab = json.decode(new_card:getFormatBuffer()) or {};
                local new_card_count = #self.m_cardIdTab
                if new_card_count > 1 then
                    local pX,pY = tagNode:getPosition();
                    local tempPos = tagNode:getParent():convertToWorldSpace(ccp(pX,pY))
                    self.m_animStartPos = {x = tempPos.x,y = tempPos.y}
                    self.m_mask_layer:setVisible(true);
                    self.m_mask_layer:setTouchEnabled(true);
                    self:addGachaAnim2(1);
                end
            end
            if self.open_type == 1 then
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("do_reward_gacha"), http_request_method.GET, params,"do_reward_gacha")
            else
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("server_limit_hero_do"), http_request_method.GET, params,"server_limit_hero_do")
            end
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_active_limit.ccbi");
    -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    self.rank_node = ccbNode:nodeForName("rank_node");
    -- self.left_time_label_node = ccbNode:nodeForName("left_time_label_node");
    self.btn_gacha = ccbNode:controlButtonForName("btn_gacha");
    self.btn_gacha_10 = ccbNode:controlButtonForName("btn_gacha_10");
    self.free_one_node = ccbNode:nodeForName("free_one_node");--一次gacha免费倒计时
    self.free_ten_node = ccbNode:nodeForName("free_ten_node");--10次免费倒计时
    self.reward_table_node = ccbNode:nodeForName("reward_table_node");--奖励列表node
    self.points_label = ccbNode:labelTTFForName("points_label");--当前积分
    self.points_rank_label = ccbNode:labelTTFForName("points_rank_label");--当前积分排名
    self.left_dimond_label = ccbNode:labelTTFForName("left_dimond_label");--剩余钻石
    self.btn_recharge = ccbNode:controlButtonForName("btn_recharge");
    self.btn_detail = ccbNode:controlButtonForName("btn_detail");   
    self.anim_node = ccbNode:nodeForName("anim_node");
    self.left_time_node = ccbNode:nodeForName("left_time_node");


    self.m_node_maskshowLeade = ccbNode:nodeForName("m_node_maskshowLeade");
    self.m_node_maskshow_myscore = ccbNode:nodeForName("m_node_maskshow_myscore");
    self.m_node_maskshow_showmain = ccbNode:nodeForName("m_node_maskshow_showmain");
    self.m_node_maskshow_showreward = ccbNode:nodeForName("m_node_maskshow_showreward");

    self.m_mask_layer = ccbNode:layerForName("m_mask_layer");
    self.m_mask_layer:setVisible(false);
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then 
            return true;  
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);


    -- 本层阻止触摸传导下一层
    local function onTouch2(eventType, x, y)     
        if eventType == "began" then 
            if self.m_gachaAnimEndFlag == true then
                self.m_cardIdTab = {};
                self:removeGachaAnim();
                self.m_mask_layer:setVisible(false);
                self.m_anim_node:removeAllChildrenWithCleanup(true);
                self.m_mask_layer:setTouchEnabled(false);
            end
            return true;  
        end 
    end
    self.m_mask_layer:registerScriptTouchHandler(onTouch2,false,GLOBAL_TOUCH_PRIORITY-2,true);
    self.m_mask_layer:setTouchEnabled(false);

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    game_util:setControlButtonTitleBMFont(self.btn_gacha)
    game_util:setControlButtonTitleBMFont(self.btn_gacha_10)

    self.btn_gacha:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.btn_gacha_10:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.btn_recharge:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.btn_detail:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    --添加英雄
    local giftCfg = nil;
    if self.open_type == 1 then
        -- giftCfg = getConfig(game_config_field.gacha_gift);
        local itemData = self.m_rank_data[1] or {}
        if itemData.data then
            itemData = itemData.data
            local reward = itemData.reward or {}
            local itemData = reward[1] or {}
            local cardType = itemData[1]
            local cardId = itemData[2]
            self:createAnimNode(cardId,cardType)
        end
    else
        giftCfg = getConfig(game_config_field.server_hero);
        local itemCfg = giftCfg:getNodeWithKey(tostring(1))
        local reward = itemCfg:getNodeWithKey("reward")
        local itemData = reward:getNodeAt(0)
        local cardType = itemData:getNodeAt(0):toInt()
        local cardId = itemData:getNodeAt(1):toInt()
        self:createAnimNode(cardId,cardType)
    end

    local text1 = ccbNode:labelTTFForName("text1")
    local text2 = ccbNode:labelTTFForName("text2")
    local text3 = ccbNode:labelTTFForName("text3")
    local text4 = ccbNode:labelTTFForName("text4")
    local text5 = ccbNode:labelTTFForName("text5")
    local text6 = ccbNode:labelTTFForName("text6")
    local text7 = ccbNode:labelTTFForName("text7")
    text1:setString(string_helper.ccb.text35)
    text2:setString(string_helper.ccb.text36)
    text3:setString(string_helper.ccb.text37)
    text4:setString(string_helper.ccb.text38)
    text5:setString(string_helper.ccb.text39)
    text6:setString(string_helper.ccb.text40)
    text7:setString(string_helper.ccb.text41)
    return ccbNode;
end

----------------------------------------------------------------------------------------------------------------------------------------------


--[[--
    获得gacha卡牌的品质
]]
function game_active_limit.getGachaCardQuality(self)
    self.m_cardIdTab = self.m_cardIdTab or {};
    local maxQualityCardId = tostring(self.m_cardIdTab[1])
    local quality,tempQuality = 0;
    local cardData,cardCfg;
    for k,v in pairs(self.m_cardIdTab) do
        cardData,cardCfg = game_data:getCardDataById(v);
        tempQuality = cardCfg:getNodeWithKey("quality"):toInt()
        if tempQuality > quality then
            quality = tempQuality
            maxQualityCardId = v;
        end
    end
    return quality,maxQualityCardId;
end

--[[--
    添加抽取好卡的动画
gacha_anim_1    蓝卡
daiji
fanpai
xunhuan

gacha_anim_2    紫卡
daiji
daiji2
fanpai
xunhuan

gacha_anim_3    橙卡
daiji
daiji2
fanpai
xunhuan
    
    一抽
]]
function game_active_limit.addGachaAnim(self,quality)
    self.m_gachaAnimEndFlag = false;
    self:removeGachaAnim();
    quality = quality or 0;
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
    end
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            self.m_anim_node:setVisible(true);
            animNode:playSection("xunhuan");
            self.m_gachaAnimEndFlag = true;
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(self.m_animStartPos.x, self.m_animStartPos.y))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    -- m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
    -- game_scene:getPopContainer():addChild(m_iAnim,10,10);
    self.m_mask_layer:addChild(m_iAnim,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = m_iAnim
end
--[[
    十连抽
]]
function game_active_limit.addGachaAnim2(self,index)
    if index == 1 then
        self.m_gachaAnimEndFlag = false;
        self.m_delayTimeIndex = 0;
        self:removeGachaAnim();
    end
    local tempIndex = (index - 1) % 10 + 1
    if index > 1 and tempIndex == 1 then
        self.m_delayTimeIndex = 0;
        self:removeGachaAnim();
    end
    self.m_delayTimeIndex = self.m_delayTimeIndex + 1;
    local new_card_count = #self.m_cardIdTab
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local itemData,itemCfg = game_data:getCardDataById(self.m_cardIdTab[index]);
    local quality =itemCfg:getNodeWithKey("quality"):toInt()
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
        game_sound:playUiSound("gacha")
    end
    local tempNode = CCNode:create();
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local xunhuanCount = 1;
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            xunhuanCount = xunhuanCount + 1;
            if xunhuanCount == 3 then
                animNode:playSection("daiji2");
                if tempIndex < 6 then
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75)))
                else
                    tempNode:runAction(CCMoveTo:create(0.1,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25)))
                end
                index = index + 1;
                self.m_delayTimeIndex = 0;
                if index <= new_card_count then
                    if index > 10 and tempIndex == 10 then
                        local function callback()
                            self:addGachaAnim2(index);
                        end
                        local animArr = CCArray:create();
                        animArr:addObject(CCDelayTime:create(2));
                        animArr:addObject(CCCallFunc:create(callback));
                        self.m_root_layer:runAction(CCSequence:create(animArr));
                    else
                        self:addGachaAnim2(index);
                    end
                else
                    self.m_gachaAnimEndFlag = true;
                end
            else
                animNode:playSection("xunhuan");
            end
        elseif lableName == "fanpai2" then
            local ccbNode = game_util:createHeroListItemByCCB(itemData);
            tempNode:addChild(ccbNode);
            if quality > 3 then
                animNode:playSection("xunhuan");
            else
                animNode:playSection("daiji");
                if tempIndex < 6 then
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*tempIndex - 0.1), visibleSize.height*0.75))))
                else
                    tempNode:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,0.8),CCMoveTo:create(0.05,ccp(visibleSize.width*(0.2*(tempIndex-5) - 0.1), visibleSize.height*0.25))))
                end
                -- index = index + 1;
                -- if index <= new_card_count then
                --     self:addGachaAnim2(index);
                -- end
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    tempNode:setPosition(ccp(self.m_animStartPos.x, self.m_animStartPos.y))
    local function animEndCallFunc()
        if quality > 3 then
        else
            index = index + 1;
            if index <= new_card_count then
                if index > 10 and tempIndex == 10 then
                    local function callback()
                        self:addGachaAnim2(index);
                    end
                    local animArr = CCArray:create();
                    animArr:addObject(CCDelayTime:create(2));
                    animArr:addObject(CCCallFunc:create(callback));
                    self.m_root_layer:runAction(CCSequence:create(animArr));
                else
                    self:addGachaAnim2(index);
                end
            else
                self.m_gachaAnimEndFlag = true;
            end
        end
        m_iAnim:playSection("fanpai2");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(0.01*self.m_delayTimeIndex));
    tempNode:setScale(0.8);
    animArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.05,1),CCMoveTo:create(0.05,ccp(visibleSize.width*0.5, visibleSize.height*0.5))));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    tempNode:runAction(CCSequence:create(animArr));
    tempNode:addChild(m_iAnim);
    self.m_mask_layer:addChild(tempNode,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = tempNode
end

--[[--
    移除抽取好卡的动画
]]
function game_active_limit.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end

--[[--
    创建
]]
function game_active_limit.createFirstHeroAnim(self,cardId)
    local new_card_count = #self.m_cardIdTab
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    if new_card_count > 0 then
        local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
        if heroCfg == nil then return end
        -- local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        -- local rgb = heroCfg:getNodeWithKey("rgb_sort"):toInt();
        -- -- local animNode = game_util:createImgByName("image_" .. ainmFile,rgb)
        -- local animNode = game_util:createAnimSequence(ainmFile,0,cardData,heroCfg);
        -- if animNode then
        --     self.m_anim_node:addChild(animNode);
        -- end
        local animNode = game_util:createHeroListItemByCCB(cardData);
        if animNode then
            self.m_anim_node:addChild(animNode);
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

--[[
    招募后刷新
]]
function game_active_limit.refreshLabel(self)
    --倒计时
    self.left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()
       self.left_time_node:removeAllChildrenWithCleanup(true)
       local tipsLabel = game_util:createLabelTTF({text = string_helper.game_active_limit.text,color = ccc3(255,255,255),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        tipsLabel:setPosition(ccp(0,0))
        self.left_time_node:addChild(tipsLabel,10,12)
    end
    local countdownLabel = game_util:createCountdownLabel(tonumber(self.m_tGameData.delta_time),timeEndFunc,8, 3);
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setPosition(ccp(0,0))
    self.left_time_node:addChild(countdownLabel,10,10)

    if tonumber(self.m_tGameData.delta_time) <= 0 then
        countdownLabel:setTime(1)
    end
    --免费倒计时
    self.free_one_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc2()
        self.free_one_node:removeAllChildrenWithCleanup(true)
        local tipsLabel = game_util:createLabelTTF({text = string_helper.game_active_limit.text2,color = ccc3(255,255,255),fontSize = 10});
        tipsLabel:setAnchorPoint(ccp(0.5,0.5))
        tipsLabel:setPosition(ccp(0,0))
        self.free_one_node:addChild(tipsLabel,10,12)
    end
    local gacha_coin = self.m_tGameData.gacha_coin
    local free_time = gacha_coin.free_time
    local countdownLabel2 = game_util:createCountdownLabel(tonumber(free_time),timeEndFunc2,8);
    countdownLabel2:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel2:setPosition(ccp(0,5))
    self.free_one_node:addChild(countdownLabel2,10,10)

    local freeLabel = game_util:createLabelTTF({text = string_helper.game_active_limit.text3,color = ccc3(255,255,255),fontSize = 10});
    freeLabel:setAnchorPoint(ccp(0.5,0.5))
    freeLabel:setPosition(ccp(0,-5))
    self.free_one_node:addChild(freeLabel,10,11)

    if free_time == 0 then
        countdownLabel2:setTime(1)
    end
    if free_time < 0 then
        local freeLabel = self.free_one_node:getChildByTag(11)
        local countdownLabel2 = self.free_one_node:getChildByTag(10)
        if freeLabel then
            freeLabel:removeFromParentAndCleanup(true)
        end
        if countdownLabel2 then
            countdownLabel2:removeFromParentAndCleanup(true)
        end
    end
    self.points_label:setString(self.m_tGameData.score);
    self.points_rank_label:setString(self.m_tGameData.rank);
    self.left_dimond_label:setString(tostring(game_data:getUserStatusDataByKey("coin")));
end
--[[
    添加英雄动画 ---- 或者装备图片
]]
function game_active_limit.createAnimNode(self,cardId,cardType)
    if cardType == 5 then--卡牌
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cardId));
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = nil
        animNode = game_util:createIdelAnim(ainmFile,0,cardData,heroCfg);
        if animNode then
            animNode:setRhythm(1);
            animNode:setAnchorPoint(ccp(0.5,0));
            animNode:setScale(1.1);
            self.anim_node:addChild(animNode);
        end
    elseif cardType == 7 then--装备
        -- cclog("cardId = " .. cardId)
        local itemData = {lv=1,id=-1,c_id=cardId,pos=-1,st_lv=0}
        local ccbNode = game_util:createEquipItemByCCB(itemData);
        ccbNode:setAnchorPoint(ccp(0.5,0))
        ccbNode:runAction(game_util:createRepeatForeverMoveWithTime(ccp(0,0),ccp(0,5),1,1.5))
        self.anim_node:addChild(ccbNode);
    end
end
--[[--
    创建列表 积分排行榜
]]
function game_active_limit.createTableView(self,viewSize)
    local rankTable = self.m_tGameData.score_ranks
    -- local function sortfunction( data1,data2 )
    --     return tonumber(data1.rank) < tonumber(data2.rank)
    -- end
    -- table.sort( rankTable, sortfunction )
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rankData = rankTable[tostring(index+1)]
            local name = rankData.name
            local score = rankData.score

            detail_label:setString(tostring(index+1) .. "." .. name )
            detail_label_score:setString(tostring(score))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end
--[[
    创建奖励列表
]]
function game_active_limit.createRewardTabelView(self,viewSize)
    local rewardPos = {
        {0},
        {-30,30},
        {-42,0,42},
    }
    local giftCfg = nil;
    if self.open_type == 1 then
        giftCfg = getConfig(game_config_field.gacha_gift);
    else
        giftCfg = getConfig(game_config_field.server_hero);
    end
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local btnType = math.floor(btnTag / 10)
        local index = math.floor(btnTag % 10)
        cclog("btnTag == " .. btnTag)
        cclog("btnType = " .. btnType)
        cclog("index == " .. index)
        local itemCfg = giftCfg:getNodeWithKey(tostring(btnType+1))
        local reward = itemCfg:getNodeWithKey("reward")--奖励
        local rewardItem = reward:getNodeAt(index-1)
        local itemData = json.decode(rewardItem:getFormatBuffer())
        game_util:lookItemDetal(itemData)
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = giftCfg:getNodeCount();
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:openCCBFile("ccb/ui_active_limit_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local reward_label = ccbNode:labelTTFForName("reward_label");
            local reward_node = ccbNode:nodeForName("reward_node");

            local itemCfg = giftCfg:getNodeWithKey(tostring(index+1))
            local rank = nil;
            local rank_low = nil;
            local reward = itemCfg:getNodeWithKey("reward")--奖励
            if itemCfg:getNodeWithKey("rank_low") then
                rank = itemCfg:getNodeWithKey("rank"):toInt()--上限
                rank_low = itemCfg:getNodeWithKey("rank_low"):toInt()--下限
            else
                local rankCfg = itemCfg:getNodeWithKey("rank")
                rank = rankCfg:getNodeAt(0):toInt()
                if rankCfg:getNodeCount() > 1 then
                    rank_low = rankCfg:getNodeAt(1):toInt()
                else
                    rank_low = rankCfg:getNodeAt(0):toInt()
                end
            end
             
            if rank ~= rank_low then
                reward_label:setString(string_helper.game_active_limit.di .. rank .. "-" .. rank_low .. string_helper.game_active_limit.ming)
            else
                if rank_low == 0 then
                    reward_label:setString(string_helper.game_active_limit.text4)
                else
                    reward_label:setString(string_helper.game_active_limit.di .. rank .. string_helper.game_active_limit.ming)
                end
            end
            reward_node:removeAllChildrenWithCleanup(true)
            for i=1,reward:getNodeCount() do
                local rewardItem = reward:getNodeAt(i-1)
                local reward_icon,name,count = game_util:getRewardByItem(rewardItem,true);
                local posTable = rewardPos[reward:getNodeCount()]
                if reward_icon then
                    reward_icon:setAnchorPoint(ccp(0.5,0.5))
                    reward_icon:setScale(0.8)
                    reward_icon:setPosition(ccp(posTable[i],0))

                    reward_node:addChild(reward_icon,10,10)

                    if count then
                        local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count)})
                        blabelCount:setAnchorPoint(ccp(0.5, 0))
                        blabelCount:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                        reward_icon:addChild(blabelCount, 11)
                    end
                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    button:setPosition(ccp(posTable[i],0))
                    button:setOpacity(0)
                    reward_node:addChild(button)
                    button:setTag(index*10 + i)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end

--[[
    创建奖励列表  根据服务器数据
]]
function game_active_limit.createRewardTabelView2(self,viewSize)
    local rewardPos = {
        {0},
        {-30,30},
        {-42,0,42},
    }
    local showData = self.m_rank_data or {}
    local function onBtnCilck( event,target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local btnType = math.floor(btnTag / 10)
        local index = math.floor(btnTag % 10)
        -- cclog("btnTag == " .. btnTag)
        -- cclog("btnType = " .. btnType)
        -- cclog("index == " .. index)
        local itemData = showData[btnType + 1] or {}
        if itemData.data then
            itemData = itemData.data or {}
            local reward = itemData.reward or {}
            game_util:lookItemDetal(reward[index])
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #showData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:openCCBFile("ccb/ui_active_limit_item.ccbi");
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local reward_label = ccbNode:labelTTFForName("reward_label");
            local reward_node = ccbNode:nodeForName("reward_node");
            local itemData = showData[index + 1] or {}
            if itemData.data then
                itemData = itemData.data
                -- local itemCfg = giftCfg:getNodeWithKey(tostring(index+1))
                local reward = itemData.reward or {}
                local ranInfo = itemData.rank or {}
                local rank = ranInfo[1]
                local rank_low = ranInfo[2] 

                if rank and not rank_low then
                    reward_label:setString(string_helper.game_active_limit.di .. tostring(rank) .. string_helper.game_active_limit.ming)
                elseif rank ~= rank_low then
                    reward_label:setString(string_helper.game_active_limit.di .. tostring(rank) .. "-" .. tostring(rank_low) .. string_helper.game_active_limit.ming)
                else
                    if rank_low == 0 then
                        reward_label:setString(string_helper.game_active_limit.text4)
                    else
                        reward_label:setString(string_helper.game_active_limit.di .. tostring(rank) .. string_helper.game_active_limit.ming)
                    end
                end

                reward_node:removeAllChildrenWithCleanup(true)
                for i=1,#reward do
                    local rewardItem = reward[i]
                    local reward_icon,name,count = game_util:getRewardByItemTable(rewardItem,true);
                    local posTable = rewardPos[ #reward ]
                    if reward_icon then
                        reward_icon:setAnchorPoint(ccp(0.5,0.5))
                        reward_icon:setScale(0.8)
                        reward_icon:setPosition(ccp(posTable[i],0))

                        reward_node:addChild(reward_icon,10,10)

                        if count then
                            local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count)})
                            blabelCount:setAnchorPoint(ccp(0.5, 0))
                            blabelCount:setPosition(reward_icon:getContentSize().width * 0.5, -10)
                            reward_icon:addChild(blabelCount, 11)
                        end
                        local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
                        button:setAnchorPoint(ccp(0.5,0.5))
                        button:setPosition(ccp(posTable[i],0))
                        button:setOpacity(0)
                        reward_node:addChild(button)
                        button:setTag(index*10 + i)
                    end
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新
]]
function game_active_limit.refreshTableView(self)
    self.rank_node:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.rank_node:getContentSize());
    self.rank_node:addChild(self.m_tableView,10,10);
end

--[[
    刷新奖励
]]
function game_active_limit.refreshRewardTableView(self)
   self.reward_table_node:removeAllChildrenWithCleanup(true)
   local tempRewardTable = nil
   if self.open_type == 1 then
        tempRewardTable = self:createRewardTabelView2(self.reward_table_node:getContentSize());
   else
        tempRewardTable = self:createRewardTabelView(self.reward_table_node:getContentSize());
   end
   self.reward_table_node:addChild(tempRewardTable,10,10)
end
--[[--
    刷新ui
]]
function game_active_limit.refreshUi(self)
    self:refreshTableView();
    self:refreshRewardTableView();
    self:refreshLabel();
end
--[[--
    初始化
]]
function game_active_limit.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end

    self.m_cardIdTab = {}
    self.m_gachaAnimEndFlag = false;
    self.m_gachaAnimTab = {};
    self.open_type = t_params.open_type or 1

    self.m_rank_data = {}
    local show_rank = self.m_tGameData.config or {}
    local rank_keys = {}
    for k,v in pairs(show_rank) do
        -- print(k,v)
        table.insert(self.m_rank_data, {key = k, data = v})
    end
    local sortFun = function ( data1, data2 )
        return (tonumber(data1.key)) < (tonumber(data2.key))
    end
    table.sort(self.m_rank_data, sortFun)
    -- cclog2(self.m_rank_data)
end
--[[--
    创建ui入口并初始化数据
]]
function game_active_limit.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    
    local id = game_guide_controller:getIdByTeam("67");
    -- id = 6701
    self:gameGuide("drama","67",id, t_params)
    return self.m_popUi;
end

function game_active_limit.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "67" and id == 6701 then
            -- print("guide_team   =====   id   =====  ", guide_team, " ", id)
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "67" and id == 6702 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_maskshowLeade
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "67" and id == 6703 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_maskshow_myscore 
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "67" and id == 6704 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_maskshow_showmain
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "67" and id == 6705 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team, id , {endCallFunc = function ()
                    self:gameGuide("drama", guide_team, id + 1)
                end})
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            t_params.isShowMask = true   
            t_params.tempNode = self.m_node_maskshow_showreward
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "67" and id == 6706 then
            local function endCallFunc()
                game_guide_controller:sendGuideData(guide_team,id + 1)
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end

return game_active_limit;
