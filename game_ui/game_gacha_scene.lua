--- 抽取英雄

local game_gacha_scene = {
    m_list_view_bg = nil,
    m_gacha_table = nil,
    m_sel_gacha_id = nil,
    m_popUi = nil,
    m_cardIdTab = nil,
    m_point_label = nil,
    m_ccbNode = nil,
    m_root_layer = nil,
    m_anim_node = nil,
    m_selIndex = nil,
    m_goldItemCount = nil,
    m_silverItemCount = nil,
    m_back_btn = nil,
    m_cost_node_1 = nil,
    m_cost_label_1 = nil,
    m_cost_node_2 = nil,
    m_cost_label_2 = nil,
    m_curPage = nil,
    m_gachaAnimTab = nil,
    m_finish_btn_node = nil,
    m_again_btn = nil,
    m_detail_btn = nil,
    m_result_close_btn = nil,
    m_maxQualityCardId = nil,
    m_maxQuality = nil,
    m_gacha_expire_tab = nil,
    m_enterUiTime = nil,
    m_selGachaData = nil,
    m_mask_layer = nil,
    m_animStartPos = nil,
    m_delayTimeIndex = nil,
    m_gachaAnimEndFlag = nil,
    tips_label = nil,
    tip = nil,
    points_label = nil,
    points_node = nil,
    point_flag = nil,
    my_point = nil,
    pro_node = nil,
    left_gacha_label = nil,
    energy_slot = nil,
    more_num_label = nil,
    m_gacha_freetimes_tab = nil,
    guild_reward_sort = nil,--gvg专用   0 1 2 3 
    gvg_tips_label = nil,
    select_node = nil,
    show_hero_btn = nil,
};

--[[--
    销毁ui
]]
function game_gacha_scene.destroy(self)
    -- body
    cclog("-----------------game_gacha_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_gacha_table = nil;
    self.m_sel_gacha_id = nil;
    self.m_popUi = nil;
    self.m_cardIdTab = nil;
    self.m_point_label = nil;
    self.m_ccbNode = nil;
    self.m_ccbNode = nil;
    self.m_root_layer = nil;
    self.m_anim_node = nil;
    self.m_selIndex = nil;
    self.m_goldItemCount = nil;
    self.m_silverItemCount = nil;
    self.m_back_btn = nil;
    self.m_cost_node_1 = nil;
    self.m_cost_label_1 = nil;
    self.m_cost_node_2 = nil;
    self.m_cost_label_2 = nil;
    self.m_curPage = nil;
    self.m_gachaAnimTab = nil;
    self.m_finish_btn_node = nil;
    self.m_again_btn = nil;
    self.m_detail_btn = nil;
    self.m_result_close_btn = nil;
    self.m_maxQualityCardId = nil;
    self.m_maxQuality = nil;
    self.m_gacha_expire_tab = nil;
    self.m_enterUiTime = nil;
    self.m_selGachaData = nil;
    self.m_mask_layer = nil;
    self.m_animStartPos = nil;
    self.m_delayTimeIndex = nil;
    self.m_gachaAnimEndFlag = nil;
    self.tips_label = nil;
    self.tip = nil;
    self.points_label = nil;
    self.points_node = nil;
    self.point_flag = nil;
    self.my_point = nil;
    self.pro_node = nil;
    self.left_gacha_label = nil;
    self.energy_slot = nil;
    self.more_num_label = nil;
    self.m_gacha_freetimes = nil;
    self.guild_reward_sort = nil;
    self.gvg_tips_label = nil;
    self.select_node = nil;
    self.m_gacha_freetimes_tab = nil;
    self.show_hero_btn = nil;
end
--[[--
    返回
]]
function game_gacha_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_gacha_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            if game_data.getGuideProcess and game_data:getGuideProcess() == "first_enter_main_scene" then
                if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(33) end -- 第一次点击招募后地 点击返回主页 步骤33
                if game_data.setGuideProcess then game_data:setGuideProcess("second_enter_main_scene") end
            end
            self:back("back");
        elseif btnTag >= 11 and btnTag <= 13 then--11:再来一次 12:查看详情 13:关闭
            self:gachaFinishBtnCallBack(btnTag);
        elseif btnTag == 200 or btnTag == 102 then--进入vip
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_scene:enterGameUi("ui_vip",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
        elseif btnTag == 500 then--排行榜
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_scene:enterGameUi("game_points_rank",{gameData = json.decode(data:getFormatBuffer())})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("top_gacha_score"), http_request_method.GET, {page = 0},"top_gacha_score")
        -- elseif btnTag == 12581 then--查看本周高概率
        --     game_scene:addPop("game_show_gacha_info",{})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_gacha2.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_point_label = ccbNode:labelTTFForName("m_point_label")
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_ccbNode = ccbNode;
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn");
    self.m_cost_node_1 = ccbNode:nodeForName("m_cost_node_1")
    self.m_cost_label_1 = ccbNode:labelTTFForName("m_cost_label_1")
    self.m_cost_node_2 = ccbNode:nodeForName("m_cost_node_2")
    self.m_cost_label_2 = ccbNode:labelTTFForName("m_cost_label_2")
    self.m_finish_btn_node = ccbNode:nodeForName("m_finish_btn_node")
    self.m_again_btn = ccbNode:controlButtonForName("m_again_btn");
    self.m_detail_btn = ccbNode:controlButtonForName("m_detail_btn");
    self.m_result_close_btn = ccbNode:controlButtonForName("m_result_close_btn");
    game_util:setCCControlButtonTitle(self.m_again_btn,string_helper.ccb.file45)
    game_util:setCCControlButtonTitle(self.m_detail_btn,string_helper.ccb.file46)
    game_util:setCCControlButtonTitle(self.m_result_close_btn,string_helper.ccb.file47)

    self.m_again_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_detail_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_result_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_mask_layer = ccbNode:layerForName("m_mask_layer");
    self.m_mask_layer:setVisible(false);
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.points_label = ccbNode:labelTTFForName("points_label")
    self.points_node = ccbNode:nodeForName("points_node")
    self.pro_node = ccbNode:nodeForName("pro_node")
    self.left_gacha_label = ccbNode:labelTTFForName("left_gacha_label")
    self.more_num_label = ccbNode:labelBMFontForName("more_num_label")  

    -- --显示本周哪些英雄概率激增的按钮
    -- self.show_hero_btn = ccbNode:controlButtonForName("show_hero_btn")
    -- self.show_hero_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 5)


    --4合1用的
    self.select_node = ccbNode:nodeForName("other_node")

    self.gvg_tips_label = ccbNode:labelTTFForName("gvg_tips_label")--公会战福利提示
    local welfareTxt = string_helper.game_gacha_scene.welfareTxt;
    self.gvg_tips_label:setVisible(false)
    if self.guild_reward_sort > 0 then
        self.gvg_tips_label:setVisible(true)
        self.gvg_tips_label:setString(welfareTxt[self.guild_reward_sort])
    end

    self.tips_label:setString(self.tip)

    self.point_flag = game_data:isViewOpenByID(108)
    if self.point_flag == true then
        self.points_node:setVisible(true)
    else
        self.points_node:setVisible(false)
    end
    self.points_label:setString(self.my_point)

    -- self.m_cost_node_1:removeAllChildrenWithCleanup(true);
    -- self.m_cost_node_2:removeAllChildrenWithCleanup(true);
    -- local icon_goldcard = game_util:createIconByName("icon_goldcard.png");
    -- if icon_goldcard then
    --     icon_goldcard:setScale(0.5)
    --     self.m_cost_node_1:addChild(icon_goldcard);
    -- end
    -- local icon_silvercard = game_util:createIconByName("icon_silvercard.png");
    -- if icon_silvercard then
    --     icon_silvercard:setScale(0.5)
    --     self.m_cost_node_2:addChild(icon_silvercard);
    -- end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local new_card_count = #self.m_cardIdTab
            if new_card_count > 1 and self.m_gachaAnimEndFlag == true then
                self.m_cardIdTab = {};
                self:removeGachaAnim();
                self.m_mask_layer:setVisible(false);
                self.m_root_layer:setTouchEnabled(false);
            end
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(false);
    return ccbNode;
end

--[[--
    gacha完成后的操作
    11:再来一次 12:查看详情 13:关闭
]]
function game_gacha_scene.gachaFinishBtnCallBack(self,btnTag)
    self:removeGachaAnim();
    self.m_mask_layer:setVisible(false);
    self.m_finish_btn_node:setVisible(false);
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    self.m_ccbNode:unregisterAnimFunc()
    self.m_ccbNode:runAnimations("default_anim")
    self.m_root_layer:setTouchEnabled(false);
    if btnTag == 11 then
        self:getGacha();
    elseif btnTag == 12 then
        local new_card_count = #self.m_cardIdTab
        if new_card_count == 1 then
            local function callBack()
                local id = game_guide_controller:getCurrentId();
                if id == 17 then
                    game_guide_controller:gameGuide("show","1",17,{tempNode = self.m_back_btn})
                end
            end
            local cardId = self.m_cardIdTab[1];
            game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(cardId)),openType=1,callBack = callBack})
        elseif new_card_count > 1 then
            self.m_popUi = self:createPop();
            game_scene:getPopContainer():addChild(self.m_popUi);
        end
    elseif btnTag == 13 then
        if game_data.getGuideProcess and game_data:getGuideProcess() == "first_enter_main_scene" then
            if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(32) end -- 第一次点击招募， 动画结束后店家关闭 步骤32
        end
        local id = game_guide_controller:getCurrentId();
        if id == 17 then
            game_guide_controller:gameGuide("show","1",17,{tempNode = self.m_back_btn})
        end
    end
end

-- --[[--
--     抽取gacha
-- ]]
-- function game_gacha_scene.getGacha(self)
--     local gacha_all = game_data:getGachaData() or {};
--     if gacha_all[tostring(self.m_sel_gacha_id)] == nil or gacha_all[tostring(self.m_sel_gacha_id)] == 0 then
--         game_util:addMoveTips({text = "抽卡次數已經用完，明天在來吧!"});
--         return 
--     end
--     if self.m_selGachaData and self.m_selGachaData.canFlag == false then
--         local consume_sort = self.m_selGachaData.itemCfg:getNodeWithKey("consume_sort"):toInt();
--         if consume_sort == 1 then
--             game_util:addMoveTips({text = "銀卡道具不足!"});
--         elseif consume_sort == 2 then
--             game_util:addMoveTips({text = "金卡道具不足!"});
--         elseif consume_sort == 3 then
--             game_util:addMoveTips({text = "鑽石不足，快去充值吧!"});
--         end
--         return
--     end
--     local requestCode = 0;
--     local animOverFlag = false;
--     local function sendRequest()
--         local function responseMethod(tag,gameData)
--             if gameData then
--                 local data = gameData:getNodeWithKey("data");
--                 game_data:setGachaDataByJsonData(data:getNodeWithKey("gacha_all"));
--                 local new_card = data:getNodeWithKey("new_card");
--                 self.m_cardIdTab = json.decode(new_card:getFormatBuffer()) or {};
--                 game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));

--                 self:refreshUi();
--                 requestCode = 1;
--                     local id = game_guide_controller:getCurrentId();
--                     if id == 16 then
--                         local function endCallFunc(successFlag)
--                             cclog("endCallFunc =================== successFlag = " .. tostring(successFlag))
--                             if successFlag == false then
--                                 game_guide_controller:gameGuide("send","1",16,{endCallFunc = endCallFunc,showLoading = true})
--                             end
--                         end
--                         game_guide_controller:gameGuide("send","1",16,{endCallFunc = endCallFunc,showLoading = true})
--                     end
--             else
--                 requestCode = -1;
--                 -- self.m_ccbNode:runAnimations("default_anim")
--                 -- self.m_root_layer:setTouchEnabled(false);
--                 -- self.m_ccbNode:unregisterAnimFunc()
--             end
--         end
--         --  gacha_type=gacha_id
--         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_gacha"), http_request_method.GET, {gacha_type=self.m_sel_gacha_id},"gacha_get_gacha",false,true)
--     end
--     local function animEndCallFunc(animName)
--         if animName == "use_1_anim" then
--             self.m_ccbNode:runAnimations("use_2_anim")
--         elseif animName == "use_2_anim" then
--             if requestCode == 1 then
--                 game_sound:playUiSound("gacha")
--                 self.m_ccbNode:runAnimations("over_anim")
--                 self.m_maxQuality,self.m_maxQualityCardId = self:getGachaCardQuality();
--                 self:createFirstHeroAnim(self.m_maxQualityCardId);
--             elseif requestCode == -1 then
--                 self.m_ccbNode:runAnimations("default_anim")
--                 self.m_root_layer:setTouchEnabled(false);
--                 self.m_ccbNode:unregisterAnimFunc()
--             else
--                 self.m_ccbNode:runAnimations("use_2_anim")
--             end
--         elseif animName == "over_anim" then
--             self:addGachaAnim(self.m_maxQuality);
--             self.m_finish_btn_node:setVisible(true);
--             animOverFlag = true;
--             self.m_ccbNode:runAnimations("over_loop_anim")
--             local id = game_guide_controller:getCurrentId();
--             if id == 16 then
--                 game_guide_controller:gameGuide("show","1",16,{tempNode = self.m_detail_btn})
--             end
--         elseif animName ==  "over_loop_anim" then
--             self.m_ccbNode:runAnimations("over_loop_anim")
--         end
--     end
--     self.m_ccbNode:registerAnimFunc(animEndCallFunc)
--     self.m_ccbNode:runAnimations("use_1_anim")
--     sendRequest();
--     local function onTouch(eventType, x, y)
--         if eventType == "began" then
--             if requestCode == 1 and animOverFlag == true then

--             end
--             return true;--intercept event
--         end
--     end
--     self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
--     self.m_root_layer:setTouchEnabled(true);
-- end


--[[--
    抽取gacha
]]
function game_gacha_scene.getGacha(self)
    local gacha_all = game_data:getGachaData() or {};
    -- if gacha_all[tostring(self.m_sel_gacha_id)] == nil or gacha_all[tostring(self.m_sel_gacha_id)] == 0 then
    --     game_util:addMoveTips({text = string_helper.game_gacha_scene.text});
    --     return 
    -- end

    local freetimes = self.m_gacha_freetimes_tab[tostring(self.m_sel_gacha_id)] or -1;
    if freetimes == -1 or (freetimes - (os.time() - self.m_enterUiTime)) > 0 then
        if self.m_selGachaData and self.m_selGachaData.canFlag == false then
            local consume_sort = self.m_selGachaData.itemCfg:getNodeWithKey("consume_sort"):toInt();
            if consume_sort == 1 then
                -- game_util:addMoveTips({text = "銀卡道具不足!"});
            elseif consume_sort == 2 then
                -- game_util:addMoveTips({text = "金幣不足!"});
                --換成統一的提示
                local t_params = 
                {
                    m_openType = 13,--金幣不足
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            elseif consume_sort == 3 then
                -- game_util:addMoveTips({text = "鑽石不足，快去充值吧!"});
                --換成統一的提示
                local t_params = 
                {
                    m_openType = 4,--鑽石不足
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            end
            return
        end
    end
    local requestCode = 0;
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData then
                self.m_mask_layer:setVisible(true);
                game_scene:removeGuidePop();
                local data = gameData:getNodeWithKey("data");
                game_data:setGachaDataByJsonData(data:getNodeWithKey("gacha_all"));
                local new_card = data:getNodeWithKey("new_card");
                self.m_cardIdTab = json.decode(new_card:getFormatBuffer()) or {};
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                self.my_point = data:getNodeWithKey("score"):toInt();
                if data:getNodeWithKey("gacha_freetimes") then
                    self.m_gacha_freetimes_tab = json.decode(data:getNodeWithKey("gacha_freetimes"):getFormatBuffer());
                end
                self.energy_slot = data:getNodeWithKey("energy_slot"):toInt();
                self.m_enterUiTime = os.time();
                self.points_label:setString(self.my_point)
                self:refreshUi();
                requestCode = 1;
                -- local id = game_guide_controller:getCurrentId();
                -- if id == 16 then
                --     game_guide_controller:gameGuide("show","1",16,{tempNode = self.m_detail_btn})
                -- end
                local new_card_count = #self.m_cardIdTab
                if new_card_count == 1 then
                    -- self.m_finish_btn_node:setVisible(true);
                    self.m_maxQuality,self.m_maxQualityCardId = self:getGachaCardQuality();
                    self:createFirstHeroAnim(self.m_maxQualityCardId);
                    self.m_anim_node:setVisible(false);
                    self:addGachaAnim(self.m_maxQuality);
                elseif new_card_count > 1 then
                    self:addGachaAnim2(1);
                end
            else
                requestCode = -1;
                self.m_root_layer:setTouchEnabled(false);
            end
        end
        --  gacha_type=gacha_id
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_gacha"), http_request_method.GET, {gacha_type=self.m_sel_gacha_id},"gacha_get_gacha",true,true)
    end
    self.m_root_layer:setTouchEnabled(true);
    sendRequest();
end



--[[--
    获得gacha卡牌的品质
]]
function game_gacha_scene.getGachaCardQuality(self)
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
function game_gacha_scene.addGachaAnim(self,quality)
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
            self.m_finish_btn_node:setVisible(true);
            local id = game_guide_controller:getCurrentId();
            if id == 16 then
                -- game_guide_controller:gameGuide("show","1",16,{tempNode = self.m_detail_btn})
                game_guide_controller:gameGuide("show","1",17,{tempNode = self.m_result_close_btn})
                game_guide_controller:gameGuide("send","1",17);
            end
            animNode:playSection("xunhuan");
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
function game_gacha_scene.addGachaAnim2(self,index)
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
function game_gacha_scene.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end

--[[--
    创建
]]
function game_gacha_scene.createFirstHeroAnim(self,cardId)
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

--[[--
    创建列表
]]
function game_gacha_scene.createTableView(self,viewSize)
    local gachaCfg = getConfig(game_config_field.gacha);
    local function timeEndFunc(label,type)
    end
    local column = 3;
    if #self.m_gacha_table >= 3 then
        column = 3;
    else 
        column = #self.m_gacha_table
    end

    function onCellButtonClick(target, event)
        local wh_inside_cfg = getConfig( game_config_field.whats_inside )
        if not wh_inside_cfg then return end

        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("btn click btnTag == ", btnTag)
        game_scene:addPop("game_gacha_showitems_pop", {gameData = nil, infoTag = btnTag } )
    end


    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = column; --列
    params.showPoint = false
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #self.m_gacha_table;
    params.showPageIndex = self.m_curPage;
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onCellButtonClick);
            ccbNode:openCCBFile("ccb/ui_game_gacha_list_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = self.m_gacha_table[index+1];
            local itemCfg = itemData.itemCfg;
            if ccbNode then
                local m_bg_spr = ccbNode:spriteForName("m_bg_spr");
                local m_cost_label = ccbNode:labelTTFForName("m_cost_label")
                local m_tips_spr = ccbNode:spriteForName("m_tips_spr");
                local m_title_spr = ccbNode:spriteForName("m_title_spr");
                local m_word_spr = ccbNode:spriteForName("m_word_spr");
                local m_cost_node = ccbNode:nodeForName("m_cost_node");
                local m_free_time_bg = ccbNode:nodeForName("m_free_time_bg");
                local m_free_time_node = ccbNode:nodeForName("m_free_time_node");
                local m_cost_node_2 = ccbNode:nodeForName("m_cost_node_2");
                local m_free_label = ccbNode:labelTTFForName("m_free_label");
                m_free_label:setString(string_helper.ccb.file71);
                local file1 = ccbNode:labelTTFForName("file1");
                file1:setString(string_helper.ccb.file40);

                local gvg_node = ccbNode:nodeForName("gvg_node")--公会战福利显示
                local m_gvg_cost_label = ccbNode:labelTTFForName("m_gvg_cost_label")
                gvg_node:setVisible(false)

                m_cost_node:removeAllChildrenWithCleanup(true);
                m_free_time_node:removeAllChildrenWithCleanup(true);
                local consume_sort = itemCfg:getNodeWithKey("consume_sort"):toInt();
                if consume_sort == 1 then
                    m_cost_label:setString("×" .. itemCfg:getNodeWithKey("value"):toStr())
                    local icon_silvercard = game_util:createIconByName("icon_silvercard.png");
                    if icon_silvercard then
                        icon_silvercard:setScale(0.33)
                        m_cost_node:addChild(icon_silvercard);
                    end
                elseif consume_sort == 2 then
                    m_cost_label:setString("×" .. itemCfg:getNodeWithKey("value"):toStr())
                    local icon_goldcard = CCSprite:createWithSpriteFrameName("public_icon_silver.png");
                    if icon_goldcard then
                        m_cost_node:addChild(icon_goldcard);
                    end
                elseif consume_sort == 3 then
                    m_cost_label:setString(itemCfg:getNodeWithKey("value"):toStr())
                    local icon_gold = CCSprite:createWithSpriteFrameName("public_icon_gold.png")
                    if icon_gold then
                        m_cost_node:addChild(icon_gold);
                    end
                end
                if self.guild_reward_sort == 0 then
                    gvg_node:setVisible(false)
                elseif self.guild_reward_sort == 1 then
                    gvg_node:setVisible(true)
                    m_gvg_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.9))
                elseif self.guild_reward_sort == 2 then
                    gvg_node:setVisible(true)
                    m_gvg_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.95))
                elseif self.guild_reward_sort == 3 then
                    gvg_node:setVisible(true)
                    m_gvg_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.9))
                end
                local image_active = itemCfg:getNodeWithKey("image_active"):toStr();
                image_active = game_util:getResName(image_active);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image_active .. ".png")
                if spriteFrame then
                    m_tips_spr:setVisible(true);
                    m_tips_spr:setDisplayFrame(spriteFrame);
                else
                    m_tips_spr:setVisible(false);
                end
                local image_word = itemCfg:getNodeWithKey("image_word"):toStr();
                image_word = game_util:getResName(image_word);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image_word .. ".png")
                if spriteFrame then
                    m_word_spr:setVisible(true);
                    m_word_spr:setDisplayFrame(spriteFrame);
                else
                    m_word_spr:setVisible(false);
                end
                local image = itemCfg:getNodeWithKey("image"):toStr();
                image = game_util:getResName(image);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image .. ".png")
                if spriteFrame then
                    m_bg_spr:setDisplayFrame(spriteFrame);
                end
                local gacha_name = itemCfg:getNodeWithKey("gacha_name")
                if gacha_name then
                    gacha_name = game_util:getResName(gacha_name:toStr());
                    cclog("gacha_name ================== " .. tostring(gacha_name))
                    local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(gacha_name .. ".png")
                    if spriteFrame then
                        m_title_spr:setVisible(true);
                        m_title_spr:setDisplayFrame(spriteFrame);
                    else
                        m_title_spr:setVisible(false);
                    end
                end
                local m_limit_node = ccbNode:nodeForName("m_limit_node");
                local m_count_str_label = ccbNode:labelTTFForName("m_count_str_label");
                local m_count_label = ccbNode:labelTTFForName("m_count_label");
                local m_time_str_label = ccbNode:labelTTFForName("m_time_str_label");
                local m_time_node = ccbNode:labelTTFForName("m_time_node");

                local freetimes = self.m_gacha_freetimes_tab[itemCfg:getKey()]
                if freetimes and freetimes > -1 then
                    m_free_time_bg:setVisible(true);
                    if freetimes == 0 then
                        m_free_label:setVisible(true);
                        -- m_cost_node_2:setVisible(false);
                    else
                        local function timeEndFunc2(label,type)
                            m_free_label:setVisible(true);
                            -- m_cost_node_2:setVisible(false);
                            m_free_time_node:removeAllChildrenWithCleanup(true);
                        end

                        -- print("freetimes === ", freetimes)
                        -- print("os.time() - self.m_enterUiTime === ", os.time() - self.m_enterUiTime)
                        -- print("freetimes - (os.time() - self.m_enterUiTime) === ", freetimes - (os.time() - self.m_enterUiTime))


                        local tempLabelfree = game_util:createLabelTTF({text = string_helper.game_gacha_scene.free,color = ccc3(255,255,255),fontSize = 10});
                        tempLabelfree:setPosition(ccp(35,10));
                        m_free_time_node:addChild(tempLabelfree);


                        local tempLabel = game_util:createLabelTTF({text = "",color = ccc3(0,250,0),fontSize = 10});
                        tempLabel:setAnchorPoint(ccp(0, 0.5))
                        tempLabel:setPosition(ccp(tempLabelfree:getContentSize().width ,10));
                        m_free_time_node:addChild(tempLabel);

                        m_free_label:setVisible(false);
                        function coutdown( time )
                            time = time or 0
                            local timeText = ""
                            local hour = math.floor(time/3600)
                            if hour > 0 then timeText = timeText .. hour .. " : " end
                            local m = math.floor(math.floor(time%3600)/ 60)
                            -- if m >0 then timeText = timeText .. string.format("%2d",m) .. ":" end
                            local s = math.floor(time % 60)
                            -- timeText = timeText .. string.format("%2d",s) .. "  "
                            timeText = timeText .. string.format("%02d ", m, s)
                            tempLabel:setString(timeText or "")
                        end

                        local time = freetimes - (os.time() - self.m_enterUiTime)
                        if time > 1 then 
                            coutdown(time)
                            -- tempLabel:setString(timeText or "")
                        else
                            timeEndFunc2()
                            countnode:stopAllActions()
                        end

                        local countnode = CCNode:create()
                        m_free_time_node:addChild(countnode)
                        schedule(countnode, function ()
                            local time = freetimes - (os.time() - self.m_enterUiTime)
                            if time > 1 then 
                                coutdown(time)
                                -- tempLabel:setString(timeText or "")
                            else
                                timeEndFunc2()
                                countnode:stopAllActions()
                            end
                        end, 1)



                        -- local countdownLabel = game_util:createCountdownLabel(freetimes - (os.time() - self.m_enterUiTime),timeEndFunc2,8,1);
                        -- countdownLabel:setColor(ccc3(0,250,0))
                        -- countdownLabel:setPosition(ccp(35,10));
                        -- m_free_time_node:addChild(countdownLabel);
                        -- -- m_cost_node_2:setVisible(true);
                        -- local tempLabel = game_util:createLabelTTF({text = "後免費",color = ccc3(0,250,0),fontSize = 10});
                        -- tempLabel:setPosition(ccp(75,10));
                        -- m_free_time_node:addChild(tempLabel);
                        -- m_free_label:setVisible(false);
                    end
                else
                    m_free_time_bg:setVisible(false);
                    m_free_label:setVisible(false);
                    -- m_cost_node_2:setVisible(true);
                    if itemData.num == 0 then -- 
                        local expire = self.m_gacha_expire_tab[itemCfg:getKey()]
                        if expire and expire > 0 then
                            m_limit_node:setVisible(true);
                            m_time_str_label:setVisible(true);
                            m_time_node:setVisible(true);
                            m_time_node:removeAllChildrenWithCleanup(true);
                            local countdownLabel = game_util:createCountdownLabel(expire - (os.time() - self.m_enterUiTime),timeEndFunc,8);
                            m_time_node:addChild(countdownLabel);
                        end
                    elseif itemData.num > 0 then
                        m_limit_node:setVisible(true);
                        m_count_str_label:setVisible(true);
                        m_count_label:setVisible(true);
                        m_count_label:setString(itemData.num);
                    end
                end
                local gacha_sort = itemCfg:getNodeWithKey("gacha_sort"):toInt();
                cclog("gacha_sort = " .. gacha_sort .. "index = " .. index)
                if gacha_sort == 1 then
                    m_limit_node:setVisible(true)
                    m_count_str_label:setVisible(true)
                else
                    m_limit_node:setVisible(false)
                end
                -- m_limit_node:setVisible(false);
                local btn = ccbNode:controlButtonForName("m_back_btn")  -- 設置cell btn tag
                btn:setTag( index + 4)

                --  新手引導提示時隱藏掉歎號
                local id = game_guide_controller:getCurrentId();
                print("getCurrentId  is   ", id)
                if id == 14 then 
                    btn:setVisible(false)
                    btn:setTouchEnabled(false)
                end

            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            if game_data.getGuideProcess and game_data:getGuideProcess() == "first_enter_main_scene" then
               if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(31) end  -- 第一次点击招募 步骤31
            end
            local pX,pY = item:getPosition();
            local tempPos = item:getParent():convertToWorldSpace(ccp(pX + itemSize.width*0.5,pY + itemSize.height*0.5));
            self.m_animStartPos = {x = tempPos.x,y = tempPos.y}
            self.m_selIndex = index+1;
            self.m_selGachaData = self.m_gacha_table[index+1];
            self.m_sel_gacha_id = self.m_selGachaData.itemCfg:getKey();
            cclog("self.m_sel_gacha_id ==============" .. self.m_sel_gacha_id)
            self:getGacha();
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    创建英雄列表
]]
function game_gacha_scene.createCardTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = #self.m_cardIdTab
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createHeroListItemByCCB();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            
            local itemData,_ = game_data:getCardDataById(self.m_cardIdTab[index+1]);
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode and itemData then
                game_util:setHeroListItemInfoByTable(ccbNode,itemData);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if eventType == "ended" and item then

        end
    end
    return TableViewHelper:createGallery2(params);
end


--[[--
    创建弹出框
]]
function game_gacha_scene.createPop(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then--关闭
            if self.m_popUi then
                self.m_popUi:removeFromParentAndCleanup(true);
                self.m_popUi = nil;
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_gacha_reward_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    m_list_view_bg:addChild(self:createCardTableView(m_list_view_bg:getContentSize()))
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
    刷新ui
]]
function game_gacha_scene.refreshUi(self)
    self.m_selGachaData = nil;
    local total_coin = game_data:getUserStatusDataByKey("coin") or 0;
    local total_silver = game_data:getUserStatusDataByKey("silver") or 0;
    -- local itemsData = game_data:getItemsData() or {};
    -- local goldItem = itemsData["1"] or {};--用于金卡招募伙伴
    -- self.m_goldItemCount = 0;
    -- local silverItem = itemsData["2"] or {};--用于银卡招募伙伴
    -- self.m_silverItemCount = 0;
    -- for k,v in pairs(goldItem) do
    --     self.m_goldItemCount = self.m_goldItemCount + v;
    -- end
    -- for k,v in pairs(silverItem) do
    --     self.m_silverItemCount = self.m_silverItemCount + v;
    -- end
    -- cclog("self.m_goldItemCount ==========" .. self.m_goldItemCount .. " ; self.m_silverItemCount ==========" .. self.m_silverItemCount)

    self.m_gacha_table = {};
    local gacha_all = game_data:getGachaData() or {};
    local gachaCfg = getConfig(game_config_field.gacha);
    local gachaCfgCount = gachaCfg:getNodeCount();
    local gachaCfgItem = nil;
    for k,v in pairs(gacha_all) do
        gachaCfgItem = gachaCfg:getNodeWithKey(tostring(k));
        if gachaCfgItem then
            local consume_sort = gachaCfgItem:getNodeWithKey("consume_sort"):toInt();
            local value = gachaCfgItem:getNodeWithKey("value"):toInt();
            if self.guild_reward_sort > 0 then
                if self.guild_reward_sort == 1 then
                    value = value * 0.9
                elseif self.guild_reward_sort == 2 then
                    value = value * 0.95
                elseif self.guild_reward_sort == 3 then
                    value = value * 0.9
                end
            end
            value = value == 0 and 1 or value;
            -- if consume_sort == 1 then--银卡
            --     self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = self.m_silverItemCount >= value}
            -- elseif consume_sort == 2 then--金卡
            --     self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = self.m_goldItemCount >= value}
            -- elseif consume_sort == 3 then--钻石
            --     self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = total_coin >= value}
            -- end
            if consume_sort == 2 then--金币
                self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = total_silver >= value}
            elseif consume_sort == 3 then--钻石
                self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = total_coin >= value}
            end
            if tostring(self.m_sel_gacha_id) == tostring(k) then
                self.m_selGachaData = self.m_gacha_table[#self.m_gacha_table]
            end
        else
            cclog("k is not found  ================= " .. k)
        end
    end
    local function sortFunc(dataOne,dataTwo)
        return dataOne.sortValue < dataTwo.sortValue
    end
    table.sort( self.m_gacha_table, sortFunc )

    -- self.m_cost_label_1:setString(tostring(self.m_goldItemCount))
    self.m_cost_label_2:setString(tostring(total_silver))
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempSize = self.m_list_view_bg:getContentSize();
    local tableViewTemp = self:createTableView(tempSize);
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_point_label:setString(total_coin);
    local id = game_guide_controller:getCurrentId();
    local tempSize = self.m_list_view_bg:getContentSize();
    if #self.m_gacha_table > 0 and (total_silver >= 250) and id == 14 then
        local cx,cy = self.m_list_view_bg:getPosition();
        local startPos = self.m_list_view_bg:getParent():convertToWorldSpace(ccp(cx - tempSize.width*0.5,cy - tempSize.height*0.5));
        local itemSize = CCSizeMake(tempSize.width/#self.m_gacha_table,tempSize.height);
        game_guide_controller:gameGuide("show","1",16,{startPos = startPos,size = itemSize})
         -- tableViewTemp:setMoveFlag(false);
        tableViewTemp:setTouchEnabled(false);
    end

    --显示再抽几次出橙卡
    self.left_gacha_label:setString("")
    -- self.pro_node:removeAllChildrenWithCleanup(true)
    local ex_bar = self.pro_node:getChildByTag(11)
    if ex_bar then
        ex_bar:removeFromParentAndCleanup(true)
    end
    local ex_text = self.pro_node:getChildByTag(10)
    if ex_text then
        ex_text:removeFromParentAndCleanup(true)
    end
    local numCount = math.floor((200 - self.energy_slot) / 10)
    if numCount <= 0 then
        numCount = 0
    end
    self.more_num_label:setString(numCount)
    local max_value = 200
    local now_value = self.energy_slot

    -- local bar = ExtProgressBar:createWithFrameName("gacha_loding_back.png","gacha_loding.png",CCSizeMake(320,22));
    local bar = ExtProgressTime:createWithFrameName("gacha_loding_back.png","gacha_loding.png")
    bar:setMaxValue(max_value);
    bar:setCurValue(now_value,false);
    bar:setAnchorPoint(ccp(0.5,0.5))
    bar:setPosition(ccp(0,-1))
    self.pro_node:addChild(bar,-1,11)
    -- local barTTF = CCLabelTTF:create(now_value.."/"..max_value,TYPE_FACE_TABLE.Arial_BoldMT,12);
    -- barTTF:setAnchorPoint(ccp(0.5,0.5))
    -- barTTF:setPosition(ccp(0,-3))
    -- self.pro_node:addChild(barTTF,10,10)

    --刷新4合1接口
    self:refresh4In1()
end
--[[
    4合1
]]
function game_gacha_scene.refresh4In1(self)
    self.select_node:removeAllChildrenWithCleanup(true)
    local tableView = game_util:setGachaSelect(self.select_node:getContentSize(),1)
    self.select_node:addChild(tableView)
end
--[[--
    初始化
]]
function game_gacha_scene.init(self,t_params)
    t_params = t_params or {};
    self.tip = ""
    self.my_point = 0
    self.guild_reward_sort = 0
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        game_data:setGachaDataByJsonData(data:getNodeWithKey("gacha_all"));
        if data:getNodeWithKey("gacha_expire") then
            self.m_gacha_expire_tab = json.decode(data:getNodeWithKey("gacha_expire"):getFormatBuffer());
        end
        if data:getNodeWithKey("gacha_freetimes") then
            self.m_gacha_freetimes_tab = json.decode(data:getNodeWithKey("gacha_freetimes"):getFormatBuffer());
        end
        if data:getNodeWithKey("msg") then
            self.tip = data:getNodeWithKey("msg"):toStr() or ""
        end
        if data:getNodeWithKey("score") then
            self.my_point = data:getNodeWithKey("score"):toInt() or 0
        end
        if data:getNodeWithKey("energy_slot") then
            self.energy_slot = data:getNodeWithKey("energy_slot"):toInt() or 0
        end
        if data:getNodeWithKey("guild_reward_sort") then
            self.guild_reward_sort = data:getNodeWithKey("guild_reward_sort"):toInt() or 0
        end
    end
    self.m_gacha_expire_tab = self.m_gacha_expire_tab or {};
    self.m_gacha_freetimes_tab = self.m_gacha_freetimes_tab or {};
    self.m_sel_gacha_id = -1;
    self.m_enterUiTime = os.time();
    self.m_gachaAnimTab = {};
    self.m_gachaAnimEndFlag = false;
    -- self.getInfoBy()
end

function game_gacha_scene.getInfoBy()
    -- local wh_inside_cfg = getConfig( game_config_field.whats_inside )
    -- if wh_inside_cfg then return end
    -- print("wh_inside_cfg cfg == ", wh_inside_cfg:getFormatBuffer())
    -- local goldGacha = wh_inside_cfg:getNodeWithKey("10")
    -- print("goldGacha cfg == ", goldGacha:getFormatBuffer())
end

--[[--
    创建ui入口并初始化数据
]]
function game_gacha_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_gacha_scene;