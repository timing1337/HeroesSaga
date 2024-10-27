---  献祭

local game_offering_sacrifices = {
    m_tGameData = nil,
    m_point_label_1 = nil,
    m_point_label_2 = nil,
    m_fuwen_layer = nil,
    m_ccbNode = nil,
    m_tempFormation = nil,
    m_btn_node_1 = nil,
    m_btn_node_2 = nil,
    m_btn_node_3 = nil,
    m_count_node = nil,
    m_count_detail_label = nil,
    m_count_label = nil,
    m_have_buy_time = nil,
    m_cost_icon_3 = nil,
    m_costValue = nil,
    m_cost_label = nil,
    m_fuwen_bg = nil,
    m_offeringAnimTab = nil,
    m_isOpenFlag = nil,
};
--[[--
    销毁ui
]]
function game_offering_sacrifices.destroy(self)
    -- body
    cclog("-----------------game_offering_sacrifices destroy-----------------");
    self.m_tGameData = nil;
    self.m_point_label_1 = nil;
    self.m_point_label_2 = nil;
    self.m_fuwen_layer = nil;
    self.m_ccbNode = nil;
    self.m_tempFormation = nil;
    self.m_btn_node_1 = nil;
    self.m_btn_node_2 = nil;
    self.m_btn_node_3 = nil;
    self.m_count_node = nil;
    self.m_count_detail_label = nil;
    self.m_count_label = nil;
    self.m_have_buy_time = nil;
    self.m_cost_icon_3 = nil;
    self.m_costValue = nil;
    self.m_cost_label = nil;
    self.m_fuwen_bg = nil;
    self.m_offeringAnimTab = nil;
    self.m_isOpenFlag = nil;
end

local radius = 100;
local posTable = {
                      {-radius*0.9,-radius*0.35},{-radius*0.9,radius*0.35},{-radius*0.35,radius*0.9},{radius*0.35,radius*0.9},
                      {radius*0.9,radius*0.35},{radius*0.9,-radius*0.35},{radius*0.35,-radius*0.9},{-radius*0.35,-radius*0.9},
                 }

--[[--
    返回
]]
function game_offering_sacrifices.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"});
end
--[[--
    读取ccbi创建ui
]]
function game_offering_sacrifices.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 2 then--一键全满
            self:request_offering_sacrifices("sacrifice_one_key_full");
        elseif btnTag == 3 then--高级献祭
            self:request_offering_sacrifices("sacrifice_high_sacrifice");
        elseif btnTag == 4 then--继续献祭
            self:request_offering_sacrifices("sacrifice_con_sacrifice");
        elseif btnTag == 5 then--收取
            self:request_offering_sacrifices("sacrifice_harvest_grace");
        elseif btnTag == 6 then--神恩兑换
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_offering_sacrifices_shop",{gameData = gameData,openType = "game_offering_sacrifices"});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("sacrifice_open_shop"), http_request_method.GET, nil,"sacrifice_open_shop")
        elseif btnTag == 201 then--开始献祭
            local times = self.m_tGameData.times or 0
            if times > 0 then
                local ownFood = game_data:getUserStatusDataByKey("food") or 0
                if self.m_costValue > ownFood then
                    game_util:addMoveTips({text = string_helper.game_offering_sacrifices.text})
                    return;
                end
            else
                local ownCoin = game_data:getUserStatusDataByKey("coin") or 0
                if self.m_costValue > ownCoin then
                    game_util:addMoveTips({text = string_helper.game_offering_sacrifices.text2})
                    return;
                end
            end

            if self.m_have_buy_time > 0 then
                self:request_offering_sacrifices("sacrifice_open_sacrifice")
            else
                game_util:addMoveTips({text = string_helper.game_offering_sacrifices.text3})
            end
        elseif btnTag == 301 then--快速献祭
            local function callBackFunc(typeName,t_params)
                if typeName == "fast" then
                    self:request_offering_sacrifices("sacrifice_one_key_sacrifice",t_params)
                end
            end
            game_scene:addPop("offering_sacrifices_fast_pop",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
        elseif btnTag == 302 then--详情
            game_scene:addPop("game_active_limit_detail_pop",{openType = "game_offering_sacrifices"})
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_offering_sacrifices.ccbi");
    self.m_point_label_1 = ccbNode:labelTTFForName("m_point_label_1")
    self.m_point_label_2 = ccbNode:labelTTFForName("m_point_label_2")
    self.m_fuwen_layer = ccbNode:layerForName("m_fuwen_layer")
    self.m_fuwen_layer:setVisible(false);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);
    self.m_btn_node_1 = ccbNode:nodeForName("m_btn_node_1")
    self.m_btn_node_2 = ccbNode:nodeForName("m_btn_node_2")
    self.m_btn_node_3 = ccbNode:nodeForName("m_btn_node_3")
    self.m_count_node = ccbNode:nodeForName("m_count_node")
    self.m_count_detail_label = ccbNode:labelTTFForName("m_count_detail_label")
    self.m_count_label = ccbNode:labelTTFForName("m_count_label")
    self.m_cost_label = ccbNode:labelTTFForName("m_cost_label")
    self.m_btn_node_1:setVisible(false)
    self.m_btn_node_2:setVisible(true)
    self.m_btn_node_3:setVisible(true)
    self.m_cost_icon_3 = ccbNode:spriteForName("m_cost_icon_3")
    self.m_fuwen_bg = ccbNode:spriteForName("m_fuwen_bg")
    local animArr = CCArray:create();
    -- animArr:addObject(CCRotateBy:create(120,360));
    animArr:addObject(CCTintTo:create(1,175,175,175))
    animArr:addObject(CCTintTo:create(1,255,255,255))
    self.m_fuwen_bg:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    -- local tempSize = self.m_fuwen_bg:getContentSize();
    -- for i=1,8 do
    --     local m_item_img = ccbNode:spriteForName("m_item_img_" .. i)
    --     local tempPos = posTable[i]
    --     m_item_img:setPosition(ccp(tempSize.width*0.5+tempPos[1], tempSize.height*0.5+tempPos[2]))
    -- end
    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    
]]
function game_offering_sacrifices.responseSuccess(self)
    local function responseEndFunc()
        self.m_root_layer:setTouchEnabled(false);
        game_sound:playUiSound("up_success")
        self:refreshUi();
        game_util:rewardTipsByDataTable(self.m_tGameData.reward);
    end
    local rempveIndex = 0;
    local animFile = "anim_icon_disappear"
    local function particleMoveEndCallFunc()
        rempveIndex = rempveIndex - 1;
        if rempveIndex == 0 then
            responseEndFunc();
        end
    end
    for i=1,8 do
        local m_item_img = self.m_ccbNode:spriteForName("m_item_img_" .. i)
        local itemData = self.m_tempFormation[i]
        if self.m_offeringAnimTab[i] ~= nil and itemData then 
            local tempParticle = game_util:createParticleSystemQuad({fileName = "particle_fly_up"});
            if tempParticle then
                local typeValue = itemData[1]
                if typeValue == 1 then
                    rempveIndex = rempveIndex + 1;
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_item_img,endNode = self.m_point_label_1,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                elseif typeValue == 2 then
                    rempveIndex = rempveIndex + 1;
                    game_util:addMoveAndRemoveAction({node = tempParticle,startNode = m_item_img,endNode = self.m_point_label_2,endCallFunc = particleMoveEndCallFunc,moveTime = 0.5,delayTime = 0.5})
                end
                game_scene:getPopContainer():addChild(tempParticle)
            end
        end
    end
    if rempveIndex == 0 then
        responseEndFunc();
    end
end

--[[

]]
function game_offering_sacrifices.request_offering_sacrifices(self,urlKey,t_params)
    local formation = self.m_tGameData.formation or {}
    self.m_tempFormation = util.table_copy(formation);
    local function responseMethod(tag,gameData)
        game_scene:removePopByName("offering_sacrifices_start_pop")
        game_scene:removePopByName("offering_sacrifices_fast_pop")
        local data = gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
        if urlKey == "sacrifice_harvest_grace" then
            for k,v in pairs(self.m_offeringAnimTab) do
                v:removeFromParentAndCleanup(true);
            end
            self.m_offeringAnimTab = {}
            self.m_root_layer:setTouchEnabled(true);
            self:responseSuccess();
        else
            if urlKey == "sacrifice_open_sacrifice" then
                self.m_isOpenFlag = true;
            end
            cclog("urlKey === " .. urlKey .. " ; self.m_isOpenFlag === " .. tostring(self.m_isOpenFlag))
            game_util:rewardTipsByDataTable(self.m_tGameData.reward);
            self:refreshUi();
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey(urlKey), http_request_method.GET, t_params,urlKey)
end
--[[
    
]]
function game_offering_sacrifices.open_offering_sacrifices(self)
    local function callBackFunc(typeName,t_params)
        if typeName == "start" then
            self:request_offering_sacrifices("sacrifice_open_sacrifice")
        elseif typeName == "fast" then
            self:request_offering_sacrifices("sacrifice_one_key_sacrifice",t_params)
        end
    end
    game_scene:addPop("offering_sacrifices_start_pop",{gameData = self.m_tGameData,callBackFunc = callBackFunc})
end

--[[--
    刷新ui
]]
function game_offering_sacrifices.refreshUi(self)
    local grace = game_data:getUserStatusDataByKey("grace") or 0
    local grace_high = game_data:getUserStatusDataByKey("grace_high") or 0
    self.m_point_label_1:setString(grace)
    self.m_point_label_2:setString(grace_high)

    local formation = self.m_tGameData.formation or {}
    local tempCount = #formation
    -- cclog("json.encode(formation) = " .. json.encode(formation))
    if tempCount > 0 then
        self.m_btn_node_1:setVisible(true)
        self.m_btn_node_2:setVisible(false)
        self.m_btn_node_3:setVisible(false)
        self.m_fuwen_layer:setVisible(true);
        for i=1,8 do
            local m_item_img = self.m_ccbNode:spriteForName("m_item_img_" .. i)
            m_item_img:setOpacity(0);
            local m_item_label = self.m_ccbNode:labelBMFontForName("m_item_label_" .. i)
            local itemData = formation[i]
            if itemData then
                m_item_img:setVisible(true)
                local typeValue = itemData[1]
                local countValue = itemData[2]
                m_item_label:setString("×" .. countValue)
                local mAnimNode = nil;
                local actionName = "daiji1";
                if countValue > 10 and countValue < 16 then
                    actionName = "daiji2"
                elseif countValue >= 16 then
                    actionName = "daiji3"
                end
                if typeValue == 0 then--爆掉了
                    local tempNode = self.m_offeringAnimTab[i]
                    cclog("************** baozha ************" .. tostring(tempNode))
                    if tempNode then
                        tempNode:playSection("baozha")
                    else
                        m_item_img:setVisible(false);
                    end
                elseif typeValue == 1 then--低级神恩
                    if self.m_offeringAnimTab[i] == nil then
                        mAnimNode = game_util:createUniversalAnim({animFile = "anim_shenenqiu2",actionName = actionName,loopFlag = true});
                    end
                elseif typeValue == 2 then--高级神恩
                    if self.m_offeringAnimTab[i] == nil then
                        mAnimNode = game_util:createUniversalAnim({animFile = "anim_shenenqiu1",actionName = actionName,loopFlag = true});
                    end
                end
                -- cclog("actionName =============== " .. actionName)
                if mAnimNode then
                    if self.m_offeringAnimTab[i] == nil then
                        -- mAnimNode:setScale(1.5);
                        local function onAnimSectionEnd(animNode, theId,theLabelName)
                            if theLabelName == "kaishi" then
                                animNode:playSection(actionName)
                            elseif theLabelName == "baozha" then
                                m_item_img:setVisible(false);
                                local tag = animNode:getParent():getTag();
                                local tempNode = self.m_offeringAnimTab[tag]
                                if tempNode then
                                    tempNode:removeFromParentAndCleanup(true)
                                end
                                self.m_offeringAnimTab[tag] = nil;
                            else
                                animNode:playSection(theLabelName)
                            end
                        end
                        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
                        local tempSize = m_item_img:getContentSize();
                        mAnimNode:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                        mAnimNode:setTag(i);
                        m_item_img:addChild(mAnimNode)
                        self.m_offeringAnimTab[i] = mAnimNode
                        if self.m_isOpenFlag == true then
                            mAnimNode:playSection("kaishi")
                        end
                    else
                        if self.m_isOpenFlag == true then
                            self.m_offeringAnimTab[i]:playSection("kaishi")
                        else
                            self.m_offeringAnimTab[i]:playSection(actionName)
                        end
                    end
                else
                    if self.m_offeringAnimTab[i] and typeValue ~= 0 then
                        if self.m_isOpenFlag == true then
                            self.m_offeringAnimTab[i]:playSection("kaishi")
                        else
                            self.m_offeringAnimTab[i]:playSection(actionName)
                        end
                    end
                end
            else
                m_item_img:setVisible(false)
            end
        end
    else
        self.m_btn_node_1:setVisible(false)
        self.m_btn_node_2:setVisible(true)
        self.m_btn_node_3:setVisible(true)
        self.m_fuwen_layer:setVisible(false);
        -- self:open_offering_sacrifices();
        -- self.m_count_detail_label:setString("今日剩余次数:")
        -- self.m_count_label:setString("0");
    end
    self.m_isOpenFlag = false;
    local times = self.m_tGameData.times or 0
    if times > 0 then
        local ownFood = game_data:getUserStatusDataByKey("food") or 0
        self.m_have_buy_time = times;
        self.m_count_detail_label:setString(string_helper.game_offering_sacrifices.day_side)
        self.m_count_label:setString(tostring(times));
        -- self.m_cost_label:setString("10000");
        self.m_costValue = self.m_tGameData.need_food or 10000;
        game_util:setCostLable(self.m_cost_label,self.m_costValue,ownFood);
        self.m_cost_icon_3:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_food.png"))
    else
        self.m_cost_icon_3:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_gold.png"))
        self.m_have_buy_time = 0;
        self.m_costValue = 0;
        self.m_count_detail_label:setString(string_helper.game_offering_sacrifices.day_buy_side)
        local buy_times = self.m_tGameData.buy_times or 0
        local buy_times_cfg = getConfig(game_config_field.pay):getNodeWithKey("17")
        local vipLevel = game_data:getVipLevel()
        local vipLevel_cfg = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel))
        if buy_times_cfg and vipLevel_cfg then
            local PayCfg = buy_times_cfg:getNodeWithKey("coin")
            local buyLimit = vipLevel_cfg:getNodeWithKey("buy_godlike"):toInt()
            if buy_times < buyLimit then
                local payValue = 0
                local tempCount = PayCfg:getNodeCount();
                if buy_times >= tempCount then
                    payValue = PayCfg:getNodeAt(tempCount-1):toInt()
                else
                    payValue = PayCfg:getNodeAt(buy_times):toInt()
                end
                self.m_costValue = payValue;
                local ownCoin = game_data:getUserStatusDataByKey("coin") or 0
                game_util:setCostLable(self.m_cost_label,self.m_costValue,ownCoin);
                if ownCoin >= payValue then--

                else
                    -- game_util:addMoveTips({text = "您的钻石不足~"})
                end
                self.m_have_buy_time = buyLimit - buy_times;
                self.m_count_label:setString(tostring(self.m_have_buy_time));
            else
                self.m_count_label:setString("0");
                -- game_util:addMoveTips({text = "购买次数已用完~"})
            end
        else
            game_util:addMoveTips({text = string_helper.game_offering_sacrifices.config_error})
            self.m_count_detail_label:setString(string_helper.game_offering_sacrifices.day_side)
            self.m_count_label:setString("0");
        end
    end
end
--[[--
    初始化
]]
function game_offering_sacrifices.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_have_buy_time = 0;
    self.m_costValue = 0;
    self.m_offeringAnimTab = {};
    self.m_isOpenFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_offering_sacrifices.create(self,t_params)
    if luaCCBNode.addPublicResource then
        luaCCBNode:addPublicResource("ccbResources/public_res_add.plist");
    end
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_offering_sacrifices;