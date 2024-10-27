--- 抽取裝備
local game_gacha_equip = {
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
    select_node = nil,
    title_sprite = nil,
    gvg_tips_label = nil,
    goods_type = nil,
};

--[[--
    銷毀ui
]]
function game_gacha_equip.destroy(self)
    -- body
    cclog("-----------------game_gacha_equip destroy-----------------");
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
    self.select_node = nil;
    self.title_sprite = nil;
    self.gvg_tips_label = nil;
    self.goods_type = nil;
end
--[[--
    返回
]]
function game_gacha_equip.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    讀取ccbi創建ui
]]
function game_gacha_equip.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag >= 11 and btnTag <= 13 then--11:再來一次 12:查看詳情 13:關閉
            self:gachaFinishBtnCallBack(btnTag);
        elseif btnTag == 200 or btnTag == 102 then--進入vip
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

    self.pro_node:setVisible(false)
    self.title_sprite = ccbNode:spriteForName("title_sprite")


    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/equip_gacha_uion.plist")

    self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("equip_gacha_tip.png"))
    --4合1用的
    self.select_node = ccbNode:nodeForName("other_node")
    self.tips_label:setString(self.tip)
    self.gvg_tips_label = ccbNode:labelTTFForName("gvg_tips_label")--公會戰福利提示
    local welfareTxt = string_helper.game_gacha_equip.welfareTxt
    self.gvg_tips_label:setVisible(false)
    if self.guild_reward_sort > 0 then
        self.gvg_tips_label:setVisible(true)
        self.gvg_tips_label:setString(welfareTxt[self.guild_reward_sort])
    end

    self.point_flag = game_data:isViewOpenByID(108)
    if self.point_flag == true then
        self.points_node:setVisible(true)
    else
        self.points_node:setVisible(false)
    end
    self.points_label:setString(self.my_point)
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
    gacha完成後的操作
    11:再來一次 12:查看詳情 13:關閉
]]
function game_gacha_equip.gachaFinishBtnCallBack(self,btnTag)
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
            local itemData = self.m_cardIdTab[1];
            local goods_type = itemData[1]
            if goods_type == 7 then
                local equip_cid = itemData[3]
                game_util:lookItemDetal({7,equip_cid,1})
            else
                local itemId = itemData[3]
                local count = itemData[4]
                game_util:lookItemDetal({6,itemId,count})
            end
            -- game_util:lookItemDetal(cardId)
            -- game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(cardId)),openType=1,callBack = callBack})
        elseif new_card_count > 1 then
            self.m_popUi = self:createPop();
            game_scene:getPopContainer():addChild(self.m_popUi);
        end
    elseif btnTag == 13 then
        local id = game_guide_controller:getCurrentId();
        if id == 17 then
            game_guide_controller:gameGuide("show","1",17,{tempNode = self.m_back_btn})
        end
    end
end
--[[--
    抽取gacha
]]
function game_gacha_equip.getGacha(self)
    local gacha_all = game_data:getGachaData() or {};
    if gacha_all[tostring(self.m_sel_gacha_id)] == nil or gacha_all[tostring(self.m_sel_gacha_id)] == 0 then
        game_util:addMoveTips({text = string_helper.game_gacha_equip.text});
        return 
    end

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
                    self.m_maxQuality,self.m_maxQualityCardId,self.goods_type = self:getGachaCardQuality();
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
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_gacha_get_gacha"), http_request_method.GET, {gacha_type=self.m_sel_gacha_id},"equip_gacha_get_gacha",true,true)
    end
    self.m_root_layer:setTouchEnabled(true);
    sendRequest();
end

--[[--
    獲得gacha卡牌的品質
]]
function game_gacha_equip.getGachaCardQuality(self)
    self.m_cardIdTab = self.m_cardIdTab or {};
    local goods_type = 7
    local maxQualityCardId = tostring(self.m_cardIdTab[1])
    local quality,tempQuality = 0;
    local cardData,cardCfg;
    for k,v in pairs(self.m_cardIdTab) do
        -- cardData,cardCfg = game_data:getCardDataById(v);
        goods_type = v[1]
        if goods_type == 7 then--裝備
            local id = v[2]
            cardData,cardCfg = game_data:getEquipDataById(id);
            tempQuality = cardCfg:getNodeWithKey("quality"):toInt()
            if tempQuality > quality then
                quality = tempQuality
                maxQualityCardId = v;
            end
        else--道具
            goods_type = 6
            quality = 2
            maxQualityCardId = v;
        end
    end
    return quality,maxQualityCardId,goods_type;
end

--[[--
    添加抽取好卡的動畫
gacha_anim_1    藍卡
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
function game_gacha_equip.addGachaAnim(self,quality)
    self:removeGachaAnim();
    quality = quality or 0;
    local animFile = "gacha_anim_1";
    if quality == 2 then
        animFile = "gacha_anim_2";
    elseif quality >= 3 then
        animFile = "gacha_anim_3";
        game_sound:playUiSound("gacha")
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
function game_gacha_equip.addGachaAnim2(self,index)
    local showIndex = index
    local ccbNode,quality = nil,2;
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
    -- local itemData,itemCfg = game_data:getCardDataById(self.m_cardIdTab[index]);
    if self.m_cardIdTab[index][1] == 7 then--装备
        local id = self.m_cardIdTab[index][2]
        local itemData,itemCfg = game_data:getEquipDataById(id);
        if itemCfg then
            quality = itemCfg:getNodeWithKey("quality"):toInt()
        end
    else--道具
        quality = 2;
        local id = self.m_cardIdTab[index][3]
        -- local item_type = self.m_cardIdTab[index][1] == 19 and 19 or 6
        local item_type = self.m_cardIdTab[index][1]
        local rewardTab = {item_type,id,1}--自己拼出道具格式
        rewardTab = {item_type,id, self.m_cardIdTab[index][4]}
        local icon,name,count,cfg_quality = game_util:getRewardByItemTable(rewardTab,false)
        -- quality = cfg_quality
        -- cclog2(quality,"quality ------------ ")
    end
    local animFile = "gacha_anim_1";
    if quality == 2 then
        animFile = "gacha_anim_2";
    elseif quality >= 3 then
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
            -- local ccbNode = game_util:createHeroListItemByCCB(itemData);
            -- local ccbNode = game_util:createEquipItemByCCB(itemData);
            local ccbNode2 = nil
            if self.m_cardIdTab[showIndex] then
                if self.m_cardIdTab[showIndex][1] == 7 then--装备
                    local id = self.m_cardIdTab[showIndex][2]
                    local itemData,itemCfg = game_data:getEquipDataById(id);
                    if itemCfg then
                        quality = itemCfg:getNodeWithKey("quality"):toInt()
                    end
                    ccbNode2 = game_util:createEquipItemByCCB(itemData);
                else--道具
                    quality = 3;
                    ccbNode2 = game_util:createItemsItem();
                    if ccbNode2 then
                        local m_user_btn = ccbNode2:controlButtonForName("m_user_btn")
                        m_user_btn:setVisible(false);
                        local iCountText = ccbNode2:labelBMFontForName("m_count");
                        local m_name = ccbNode2:labelTTFForName("m_name");
                        local m_imgNode = ccbNode2:nodeForName("m_imgNode")
                        local m_story_label = ccbNode2:labelTTFForName("m_story_label")
                        iCountText:setString(tostring("x1"));
                        m_imgNode:removeAllChildrenWithCleanup(true);
                        local id = self.m_cardIdTab[showIndex][3]
                        -- local item_type = self.m_cardIdTab[ showIndex ][1] == 19 and 19 or 6
                        local item_type = self.m_cardIdTab[ showIndex ][1] 
                        local rewardTab = { item_type,id,1}--自己拼出道具格式
                        rewardTab = { item_type,id, self.m_cardIdTab[ showIndex ][4]}
                        local icon,name,count,cfg_quality = game_util:getRewardByItemTable(rewardTab,false)
                        -- quality = cfg_quality
                        if icon then
                            m_imgNode:addChild(icon)
                        end
                        if name then
                            m_name:setString(name);
                        else
                            m_name:setString("");
                        end
                        if count then
                            iCountText:setString(tostring("x" .. tostring(count)));
                        end
                    end
                end
            end
            if ccbNode2 then
                tempNode:addChild(ccbNode2);
            end
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
    移除抽取好卡的動畫
]]
function game_gacha_equip.removeGachaAnim(self)
    self.m_mask_layer:removeAllChildrenWithCleanup(true);
    self.m_gachaAnimTab = {};
end

--[[--
    創建
]]
function game_gacha_equip.createFirstHeroAnim(self,cardId)
    local new_card_count = #self.m_cardIdTab
    self.m_anim_node:removeAllChildrenWithCleanup(true);
    if new_card_count > 0 then
        -- local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
        local goods_type = cardId[1]
        if goods_type == 7 then
            local id = cardId[2]
            local cardData,heroCfg = game_data:getEquipDataById(tostring(id));
            if heroCfg == nil then return end
            -- local animNode = game_util:createHeroListItemByCCB(cardData);
            local animNode = game_util:createEquipItemByCCB(cardData);
            if animNode then
                self.m_anim_node:addChild(animNode);
            end
        else--道具
            quality = 3;
            ccbNode = game_util:createItemsItem();
            if ccbNode then
                local m_user_btn = ccbNode:controlButtonForName("m_user_btn")
                m_user_btn:setVisible(false);
                local iCountText = ccbNode:labelBMFontForName("m_count");
                local m_name = ccbNode:labelTTFForName("m_name");
                local m_imgNode = ccbNode:nodeForName("m_imgNode")
                local m_story_label = ccbNode:labelTTFForName("m_story_label")
                iCountText:setString(tostring("x1"));
                m_imgNode:removeAllChildrenWithCleanup(true);
                local id = cardId[3]
                local count = cardId[4]
                local rewardTab = {6,id,count}--自己拼出道具格式
                local icon,name,count,cfg_quality = game_util:getRewardByItemTable(rewardTab,false)
                -- quality = cfg_quality
                if icon then
                    m_imgNode:addChild(icon)
                end
                if name then
                    m_name:setString(name);
                else
                    m_name:setString("");
                end
                if count then
                    iCountText:setString(tostring("x" .. tostring(count)));
                end
                self.m_anim_node:addChild(ccbNode);
            end
        end
    end
end

--[[--
    創建列表
]]
function game_gacha_equip.createTableView(self,viewSize)
    local gachaCfg = getConfig(game_config_field.equip_gacha);
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

    local testImage = {"equip_gacha_cu_box","equip_gacha_ag_box","equip_gacha_au_box"}
    local titleImage = {"equip_gacha_title1","equip_gacha_title2","equip_gacha_title3"}
    local wordImage = {"equip_gacha_tips1","equip_gacha_tips2","equip_gacha_tips3"}
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = column; --列
    params.showPoint = false
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = math.min(#self.m_gacha_table,3);
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
            ccbNode:openCCBFile("ccb/ui_game_gacha_equip_item.ccbi");
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
                local file1 = ccbNode:labelTTFForName("file1");
                file1:setString(string_helper.ccb.file40);
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
                -- local image_word = wordImage[index+1]
                image_word = game_util:getResName(image_word);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image_word .. ".png")
                if spriteFrame then
                    m_word_spr:setVisible(true);
                    m_word_spr:setDisplayFrame(spriteFrame);
                else
                    m_word_spr:setVisible(false);
                end
                local image = itemCfg:getNodeWithKey("image"):toStr();
                -- local image = testImage[index+1]

                image = game_util:getResName(image);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image .. ".png")
                if spriteFrame then
                    m_bg_spr:setDisplayFrame(spriteFrame);
                end
                local gacha_name = itemCfg:getNodeWithKey("gacha_name"):toStr();
                -- local gacha_name = titleImage[index+1]
                if gacha_name then
                    gacha_name = game_util:getResName(gacha_name);
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
                    m_free_time_bg:setVisible(false);
                    if freetimes == 0 then
                        m_free_label:setVisible(true);
                    else
                        local function timeEndFunc2(label,type)
                            m_free_label:setVisible(true);
                            m_free_time_node:removeAllChildrenWithCleanup(true);
                        end
                        
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
    創建英雄列表
]]
function game_gacha_equip.createCardTableView(self,viewSize)
    local ccbNode,quality = nil,3
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
            -- local ccbNode = game_util:createHeroListItemByCCB();
            if self.m_cardIdTab[index+1][1] == 7 then--裝備
                ccbNode = game_util:createEquipItemByCCB(itemData);
            else--道具
                ccbNode = game_util:createItemsItem();
            end
            cclog2(ccbNode,"ccbNode")
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            -- local itemData,_ = game_data:getCardDataById(self.m_cardIdTab[index+1]);
            if self.m_cardIdTab[index+1][1] == 7 then--裝備
                local id = self.m_cardIdTab[index+1][2]
                local itemData,itemCfg = game_data:getEquipDataById(id);
                if itemCfg then
                    quality = itemCfg:getNodeWithKey("quality"):toInt()
                end
                if ccbNode and itemData then
                    -- game_util:setHeroListItemInfoByTable(ccbNode,itemData);
                    game_util:setEquipItemInfoByTable(ccbNode,itemData);
                end
            else
                if ccbNode then
                    quality = 3;
                    local m_user_btn = ccbNode:controlButtonForName("m_user_btn")
                    m_user_btn:setVisible(false);
                    local iCountText = ccbNode:labelBMFontForName("m_count");
                    local m_name = ccbNode:labelTTFForName("m_name");
                    local m_imgNode = ccbNode:nodeForName("m_imgNode")
                    local m_story_label = ccbNode:labelTTFForName("m_story_label")
                    iCountText:setString(tostring("x1"));
                    m_imgNode:removeAllChildrenWithCleanup(true);
                    local id = self.m_cardIdTab[index+1][3]
                    local rewardTab = {6,id,1}--自己拼出道具格式
                    local icon,name,count,cfg_quality = game_util:getRewardByItemTable(rewardTab,false)
                    -- quality = cfg_quality
                    if icon then
                        m_imgNode:addChild(icon)
                    end
                    if name then
                        m_name:setString(name);
                    else
                        m_name:setString("");
                    end
                    if count then
                        iCountText:setString(tostring("x" .. tostring(count)));
                    end
                end
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
    創建彈出框
]]
function game_gacha_equip.createPop(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag ==1 then--關閉
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
function game_gacha_equip.refreshUi(self)
    self.m_selGachaData = nil;
    local total_coin = game_data:getUserStatusDataByKey("coin") or 0;
    local total_silver = game_data:getUserStatusDataByKey("silver") or 0;
    self.m_gacha_table = {};
    local gacha_all = game_data:getGachaData() or {};
    local gachaCfg = getConfig(game_config_field.equip_gacha);
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
            if consume_sort == 2 then--金幣
                self.m_gacha_table[#self.m_gacha_table+1] ={itemCfg = gachaCfgItem,num = v,sortValue = tonumber(gachaCfgItem:getKey()),canFlag = total_silver >= value}
            elseif consume_sort == 3 then--鑽石
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

    --顯示再抽幾次出橙卡
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

    --刷新4合1接口
    self:refresh4In1()--不更新？？
end
--[[
    4合1
]]
function game_gacha_equip.refresh4In1(self)
    self.select_node:removeAllChildrenWithCleanup(true)
    local tableView = game_util:setGachaSelect(self.select_node:getContentSize(),2)
    self.select_node:addChild(tableView)
end
--[[--
    初始化
]]
function game_gacha_equip.init(self,t_params)
    t_params = t_params or {};
    self.tip = "  "
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
end
--[[--
    創建ui入口並初始化數據
]]
function game_gacha_equip.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_gacha_equip;