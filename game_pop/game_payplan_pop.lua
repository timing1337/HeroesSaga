---  ui模版

local game_payplan_pop = {

    m_sprite_activename = nil,
    m_sprite_activebg = nil,
    m_label_acitvity_asktitle = nil,
    m_label_acitvity_askdetaile = nil,
    m_label_acitvity_tieminfo = nil,
    m_node_rewardIcon = nil,
    m_label_acitivity_rewqrdnum = nil,
    m_sprite_getRewardEnd = nil,
    m_conbtn_getReward = nil,
    m_tActivityData = nil,
    m_root_layer = nil,
    m_close_btn = nil,

    m_items = {},
    m_spriteIcons = {},
    m_labelInfo = {},
    m_conbtns = {},

    m_curSelectItemID = 1,

    m_ticonbtn = nil,


    m_onedataTemp = {
        title = "sss",
        reward = {
                {5,2200,1},{5,5800,1},{5,51,2}
        },
        need_gem = 2000,
    },
    m_layer_disableTitle = nil;
    m_parentCallFun = nil,  -- 父节点的事件
};

--- 提示等级不足
function tipLevelNotEnough(msg)
     local t_params = 
                    {
                        title = string_helper.game_payplan_pop.prompt,
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close(); 
                        end,   --可缺省
                        text = string_helper.game_payplan_pop.errMessage,      --可缺省
                        onlyOneBtn = true,          --可缺省
                    }
    -- require("game_ui.game_pop_up_box").show(t_params);
    require("game_ui.game_pop_up_box").showAlertView(msg or string_helper.game_payplan_pop.errMessage);
end

local errMessage = string_helper.game_payplan_pop.errMessage

local m_showData = {
                    {  
                        icon = {{name = "s_w_huojianpao3"}, {name = "e_w_ak47"}, {name = "icon_metal1"}},
                        info1 = string_helper.game_payplan_pop.info1,
                        info2 = string_helper.game_payplan_pop.info2, 
                        info3 = string_helper.game_payplan_pop.info3,
                        icondown = {"ui_payplan_zhuangbeiqianghua", "ui_payplan_zhangbeijinjie", ""},
                        button1 = {name = string_helper.game_payplan_pop.goStrengthen, dosthFun = function ()
                            if game_button_open :checkButtonOpen( 602 ) then
                                game_scene:enterGameUi("equipment_strengthen",{gameData = nil});
                            else
                                -- tipLevelNotEnough("完成 1-2 废区城市 后开启")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(602) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                        end},
                        button2 = {name = string_helper.game_payplan_pop.goAdvance, dosthFun = function ()
                            if game_button_open :checkButtonOpen( 603 ) then
                                game_scene:enterGameUi("equip_evolution",{gameData = nil});
                            else
                                -- tipLevelNotEnough("等级不足，14级开启装备季节")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(603) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                        end},
                        button3 = {name = string_helper.game_payplan_pop.goBuy, dosthFun = function ()
                            function shopOpenResponseMethod(tag,gameData)
                                game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
                     
                            end
                            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
                        end}
                    },--装备
                   {  
                        icon = {{name = "icon_ling2"}, {name = "icon_ling1"}},
                        info1 = string_helper.game_payplan_pop.info4, 
                        info2 =  string_helper.game_payplan_pop.info5,
                        -- info3 = string_helper.game_payplan_pop.info6,
                        info3 = "",
                        icondown = {"", "", "ui_payplan_ronghe"},
                        -- button3 = { name = string_helper.game_payplan_pop.goRonghe, dosthFun = function()
                        --     if game_button_open :checkButtonOpen( 122 ) then
                        --         game_scene:enterGameUi("game_card_melting",{})
                        --         -- self:destroy()
                        --     else
                        --         -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(307) or errMessage
                        --         -- tipLevelNotEnough(tipText)
                        --     end
                        -- end},
                        button4 = { name = string_helper.game_payplan_pop.goAdvance, dosthFun = function()
                            if game_button_open:checkButtonOpen( 502 ) then
                                game_scene:enterGameUi("game_hero_advanced_sure",{gameData = nil});
                            else
                                -- tipLevelNotEnough("完成 1-4 花园城市 后开启 ")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(502) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                        end},
                    },--伙伴   改为融合
                    {  
                        icon = {{name = "icon_zhanqi"}, {name = "icon_ling3"}},
                        info1 = string_helper.game_payplan_pop.info7, 
                        info2 = string_helper.game_payplan_pop.info8,
                        info3 = string_helper.game_payplan_pop.info9,
                        icondown = {"", "", "ui_payplan_zhaomu"},
                        -- button1 = {name = "去联盟", dosthFun = function ()
                        --     if not game_button_open:checkButtonOpen(700) then
                        --         return;
                        --     end
                        --     local association_id = game_data:getUserStatusDataByKey("association_id");
                        --     if association_id == 0 then
                        --         require("like_oo.oo_controlBase"):openView("guild_join");
                        --     else
                        --         require("like_oo.oo_controlBase"):openView("guild");
                        --     end
                        -- end},
                        button2 = {name = string_helper.game_payplan_pop.goAdvance, dosthFun = function ()
                            if game_button_open:checkButtonOpen( 502 ) then
                                game_scene:enterGameUi("game_hero_advanced_sure",{gameData = nil});
                            -- else
                            -- if not game_button_open:checkButtonOpen(606) then
                            --     return
                            -- end
                            -- local function responseMethod(tag,gameData)
                            --     game_scene:enterGameUi("game_ability_commander",{gameData = gameData});
                            --     -- self:destroy();
                            end
                            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index")
                        end},
                        button3 = {name = string_helper.game_payplan_pop.goGacha, dosthFun = function ()
                            -- local function responseMethod(tag,gameData)
                            --     game_scene:addPop("game_limit_shop",{gameData = gameData});
                            -- end
                            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_outlets_open"), http_request_method.GET, {},"shop_outlets_open");
                            if type(game_data.getGuideProcess) == "function" and game_data:getGuideProcess() == "first_enter_main_scene" then
                                if type(game_util.statisticsSendUserStep) == "function" then game_util:statisticsSendUserStep(30)  --[[第一次点击伙伴招募 步骤30]] end
                            end
                            local function responseMethod(tag,gameData)
                                game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
                                -- self:destroy();
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
                            -- local function responseMethod(tag,gameData)
                            --     game_scene:enterGameUi("ui_vip",{gameData = gameData});
                            --     -- self:destroy();
                            -- end
                            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_buy_step"), http_request_method.GET, nil,"vip_buy_step")
                        end}
                    },--争霸   改为进阶
                    {  
                        icon = {{name = "public_xingxing2"}, {name = "s_baozha"}},
                        info1 = string_helper.game_payplan_pop.info10,
                        info2 = string_helper.game_payplan_pop.info11,
                        info3 = string_helper.game_payplan_pop.info12, 
                        icondown = {"", "", "ui_payplan_chaonengshangdian"},
                        button3 = {name = string_helper.game_payplan_pop.goBuy, dosthFun = function ()
                            if game_button_open :checkButtonOpen( 307 ) then
                                local function responseMethod(tag,gameData)
                                    game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_function_pop"})
                                    -- self:destroy()
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")  
                            else
                                -- tipLevelNotEnough("等级不足，2级开启超能商店")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(307) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                        end},
                        button4 = {name = string_helper.game_payplan_pop.goLook, dosthFun = function ()
                            if not game_button_open:checkButtonOpen(605) then
                                return;
                            end
                            local function responseMethod(tag,gameData)
                                game_scene:enterGameUi("skills_practice_scene",{gameData = gameData});
                     
                            end
                            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_open"), http_request_method.GET, nil,"leader_skill_open")
                        end}
                    },--英雄
                    {  
                        icon = {{name = "public_icon_crystal2"}, {name = "icon_food1"}},
                        info1 = string_helper.game_payplan_pop.info13,
                        info2 = string_helper.game_payplan_pop.info14,
                        info3 = string_helper.game_payplan_pop.info15, 
                        icondown = {"", "", "ui_payplan_chaonengshangdian"},
                        button1 = {name = string_helper.game_payplan_pop.goChange, dosthFun = function ()
                            if game_button_open :checkButtonOpen( 509 ) then
                                game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData});
                            else
                                -- tipLevelNotEnough("等级不足，13级开启属性改造")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(509) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                        end},
                        button2 = {name = string_helper.game_payplan_pop.goBuy, dosthFun = function ()
                            function shopOpenResponseMethod(tag,gameData)
                                game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
                     
                            end
                            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
                        end},
                        button3 = {name = string_helper.game_payplan_pop.goBuy, dosthFun = function ()
                            if game_button_open :checkButtonOpen( 307 ) then
                                local function responseMethod(tag,gameData)
                                game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_function_pop"})
                                -- self:destroy()
                                end
                                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")  
                            else
                                -- tipLevelNotEnough("等级不足，2级开启超能商店")
                                -- local tipText = game_button_open:getOpenGuideLockStrByBtnId(307) or errMessage
                                -- tipLevelNotEnough(tipText)
                            end
                         end}
                    },--改造
                }

--[[--
    销毁uißß
]]
function game_payplan_pop.destroy(self)
    -- body
    cclog("----------------- game_payplan_pop destroy-----------------");  

    self.m_parentCallFun = nil;
    self.m_sprite_activename = nil;
    self.m_sprite_activebg = nil;
    self.m_label_acitvity_asktitle = nil;
    self.m_label_acitvity_askdetaile = nil;
    self.m_label_acitvity_tieminfo = nil;
    self.m_node_rewardIcon = nil;
    self.m_label_acitivity_rewqrdnum = nil;
    self.m_sprite_getRewardEnd = nil;
    self.m_conbtn_getReward = nil;
    self.m_tActivityData = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_ticonbtn = nil;

    self.m_layer_disableTitle = nil;

end
--[[--
    返回
]]
function game_payplan_pop.back(self,backType)
    game_scene:removePopByName("game_payplan_pop")
end


--[[--
    读取ccbi创建ui
]]
function game_payplan_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 11 then
            -- 购买

            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data");
                game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
                    local function responseMethod(tag,gameData)
                        self.m_tActivityData.data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())
                        self:refreshDetailInfo(self.m_curSelectItemID)
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_guide_isbuy"), http_request_method.GET, {},"vip_guide_isbuy")
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("vip_guide_buy"), http_request_method.GET, {shop_id = self.m_curSelectItemID},"vip_guide_buy")
        elseif btnTag == 1 then -- 关闭
            self:back()
        elseif  btnTag >=101 and btnTag <=104 then
            if m_showData[self.m_curSelectItemID]["button" .. btnTag - 100] then
                m_showData[self.m_curSelectItemID]["button" .. btnTag - 100].dosthFun()
            end
            -- self:back()
        elseif  btnTag >=111 and btnTag <=115 then
            self:refreshDetailInfo(btnTag - 110)
        elseif  btnTag >=401 and btnTag <=403 then
                local info = self.m_onedataTemp.reward[btnTag - 400]
                local shopdata = getConfig(game_config_field.vipguide)
                local item_cfg = shopdata:getNodeWithKey(tostring(self.m_curSelectItemID))
                local rewards = item_cfg:getNodeWithKey("reward")
                local info = json.decode(rewards:getNodeAt(btnTag - 401):getFormatBuffer())
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
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                 end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_payplan_pop.ccbi");
    -- icon 
    self.m_sprite_infoicon1 = ccbNode:spriteForName("m_sprite_infoicon1")
    self.m_sprite_infoicon2 = ccbNode:spriteForName("m_sprite_infoicon2")
    self.m_sprite_infoicon3 = ccbNode:spriteForName("m_sprite_infoicon3")

    self.m_layer_disableTitle = ccbNode:layerForName("m_layer_disableTitle")

    self.m_node_titleicon3 = ccbNode:nodeForName("m_node_titleicon3")
    self.m_node_titleicon2 = ccbNode:nodeForName("m_node_titleicon2")
    self.m_conbtn_buy = ccbNode:controlButtonForName("m_conbtn_buy")
    self.m_sprite_buyselect = ccbNode:spriteForName("m_sprite_buyselect")
    self.m_blabel_buycost = ccbNode:labelBMFontForName("m_blabel_buycost")
    -- self.m_blabel_buycost:setString("8978")
    for i=1,3 do
        self.m_spriteIcons[i] = ccbNode:spriteForName("m_sprite_infoicon" .. i)
    end
    for i=1,3 do
        local label = ccbNode:labelTTFForName("m_label_infoicon" .. i)
        label:setVisible(false)
        local rlabel = game_util:createRichLabelTTF({text = "",dimensions = CCSizeMake(180, 0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment = nil,fontSize = 9})
        rlabel:setAnchorPoint( label:getAnchorPoint() )
        rlabel:setPositionX( label:getPositionX() )
        rlabel:setPositionY( label:getPositionY() )
        label:getParent():addChild(rlabel)
        -- self.m_labelInfo[i] = ccbNode:labelTTFForName("m_label_infoicon" .. i)
        self.m_labelInfo[i] = rlabel
    end
    self.m_node_itemxuanzhong = ccbNode:nodeForName("m_node_itemxuanzhong")   -- 选框
     -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    for i=1,4 do
        self.m_conbtns[i] = ccbNode:controlButtonForName("m_conbtn_dosth" .. i)
        self.m_conbtns[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    end
    for i = 1, 5 do 
        local button = ccbNode:controlButtonForName("m_conbtn_item" .. i)
        button:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    end
    self.m_conbtn_buy:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ticonbtn = {}
    for i=1,3 do
        self.m_ticonbtn[i] = ccbNode:controlButtonForName("m_conbtn_topicon" .. i)
        self.m_ticonbtn[i]:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    end
    local shopdata = getConfig(game_config_field.vipguide)
    local curlevel = game_data:getUserStatusDataByKey("level") or 1
    for i = 1, 5 do 
        local item_cfg = shopdata:getNodeWithKey(tostring(i))
        local needLevel = item_cfg:getNodeWithKey("lv"):toInt() or 1
        local item = ccbNode:spriteForName("m_sprite_item" .. i)
        local blabel = item:getChildByTag(2)
        local sprite = item:getChildByTag(1)
        sprite:setPosition(sprite:getPositionX(), sprite:getParent():getContentSize().height * 0.7)
        if needLevel <= curlevel then
            blabel:setVisible(false)
            sprite:setPosition(sprite:getPositionX(), sprite:getParent():getContentSize().height * 0.5)
        else
            blabel:setVisible( true )
            tolua.cast(blabel, "CCLabelBMFont"):setString(needLevel .. string_helper.game_payplan_pop.unlock)
            tolua.cast(blabel, "CCLabelBMFont"):setColor(ccc3(155, 155, 155))
            tolua.cast(sprite, "CCSprite"):setColor(ccc3(155, 155, 155))
            item:setColor(ccc3(155, 155, 155))
        end
    end

    -- print_lua_table(self.m_tActivityData.data, 10)
    for i=1,5 do
        if self.m_tActivityData.data.step[tostring(i)] ~= 1 then
            self:refreshDetailInfo(i)
            break
        end
        if i == 5 then
            self:refreshDetailInfo(1)
        end
    end
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_payplan_pop.refreshDetailInfo(self, selectedID)

    self.m_curSelectItemID = selectedID
    
    local infoData = m_showData[selectedID]

    local shopdata = getConfig(game_config_field.vipguide)
    local item_cfg = shopdata:getNodeWithKey(tostring(selectedID))
    local needLevel = item_cfg:getNodeWithKey("lv"):toInt()
    local curlevel = game_data:getUserStatusDataByKey("level") or 1

    local cost = item_cfg:getNodeWithKey("coin"):toInt()

    -- -- 购买按钮开关 by 等级
    self.m_blabel_buycost:setString(tostring(cost))  -- 更新购买花费
    if curlevel >= needLevel and self.m_tActivityData.data.step[tostring(selectedID)] ~= 1 then   --  解锁购买选项
        self.m_sprite_buyselect:stopAllActions()
        self.m_sprite_buyselect:runAction(game_util:createRepeatForeverFade())
        self.m_conbtn_buy:setColor(ccc3(255, 255, 255))
        self.m_conbtn_buy:setEnabled(true)
        self.m_sprite_buyselect:setVisible(true)
        self.m_layer_disableTitle:setVisible(false)
    else
        self.m_conbtn_buy:setEnabled(false)
        self.m_sprite_buyselect:stopAllActions()
        self.m_conbtn_buy:setColor(ccc3(155, 155, 155))
        self.m_sprite_buyselect:setVisible(false)
        self.m_layer_disableTitle:setVisible(true)
    end

    --  前往按钮解锁
    if curlevel >= needLevel and self.m_tActivityData.data.step[tostring(selectedID)] == 1 then  -- 已经购买过
        for i=1,4 do
            -- print("button is ", i, infoData["button" .. i] and infoData["button" .. i].name, self.m_conbtns[i])
            if infoData["button" .. i] == nil then
                self.m_conbtns[i]:setVisible(false)
            else
                self.m_conbtns[i]:setVisible( true )
                game_util:setCCControlButtonTitle( self.m_conbtns[i], infoData["button" .. i].name)
            end
        end
    else
        for i=1,4 do
            self.m_conbtns[i]:setVisible(false)
        end
    end


    -- -- print_lua_table(self.m_tActivityData.data.step, 8)
    -- -- 购买按钮开关 by 是否已经购买
    -- if self.m_tActivityData.data.step[tostring(selectedID)] == 1 then
    --     -- game_util:setCCControlButtonTitle(self.m_conbtn_buy, "已购买")
    --     self.m_conbtn_buy:setEnabled(false)
    --     self.m_sprite_buyselect:stopAllActions()
    --     self.m_conbtn_buy:setColor(ccc3(155, 155, 155))
    --     self.m_sprite_buyselect:setVisible(false)
    -- else
    --     -- game_util:setCCControlButtonTitle(self.m_conbtn_buy, "购买")
    --     self.m_sprite_buyselect:setVisible( true )
    --     self.m_sprite_buyselect:stopAllActions()
    --     self.m_sprite_buyselect:runAction(game_util:createRepeatForeverFade())
    --     self.m_conbtn_buy:setColor(ccc3(255, 255, 255))
    --     self.m_conbtn_buy:setEnabled(true)
    -- end

    -- print_lua_table(m_showData[selectedID], 5)
    for i=1,3 do
        local sprite = nil
        if infoData.icondown[i] == "" then
            sprite = game_util:createIconByName(infoData.icon[i].name)
            if sprite == nil then 
                sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(infoData.icon[i].name .. ".png"))
            end
            if sprite then 
                sprite:setScale(0.7)
            end
        else
            sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(infoData.icondown[i] .. ".png"))
        end
        -- print(" down icon is ", infoData.icondown[i])
        self.m_spriteIcons[i]:setVisible(false)
        if sprite then
            self.m_spriteIcons[i]:getParent():removeChildByTag(1121 + i, true)
            sprite:setPosition(self.m_spriteIcons[i]:getPosition())
            self.m_spriteIcons[i]:getParent():addChild(sprite, 10, 1121 + i)
        end
    end



    local rewards = item_cfg:getNodeWithKey("reward")

    local count = rewards:getNodeCount()
     -- print("count is === ", count)
    if count == 2 then
        self.m_node_titleicon3:setVisible(false)
        self.m_node_titleicon2:setVisible(true)
    else
        self.m_node_titleicon3:setVisible(true)
        self.m_node_titleicon2:setVisible(false)
    end
    -- print("count is ", count)

    for i=1,3 do
        self.m_ticonbtn[i]:setVisible(false)
    end

    if count > 1 then
        for i=1,count do
            local icon,name, icount = game_util:getRewardByItem(rewards:getNodeAt(i - 1) , false);
            -- print("icon is -- ", icon , name , icount)
            -- print("sprite is m_node_titleicon",count, self["m_node_titleicon" .. count])
            local sprite = self["m_node_titleicon" .. count]:getChildByTag(i)
            sprite:setVisible(true)
            sprite:getChildByTag(11):removeAllChildrenWithCleanup(true)
            if icon then 
                sprite:getChildByTag(11):addChild(icon)
            end
            icount = icount or ""
            name = name or ""
            tolua.cast(sprite:getChildByTag(15), "CCLabelBMFont"):setString(name)
            tolua.cast(sprite:getChildByTag(12), "CCLabelBMFont"):setString("x" .. tostring(icount))
            -- tolua.cast(sprite:getChildByTag(14), "CCLabelTTF"):setString("好名字啊\nx" .. tostring(icount))

            self.m_ticonbtn[i]:setVisible(true)
            self.m_ticonbtn[i]:setPositionX(sprite:getPositionX())
        end
    end
    if count == 1 then
            local i = 2
            local icon,name, icount = game_util:getRewardByItem(rewards:getNodeAt(0) , false);
            -- print("icon is -- ", icon , name , icount)
            -- print("sprite is m_node_titleicon",count, self["m_node_titleicon" .. 3])
            local sprite = self["m_node_titleicon" .. 3]:getChildByTag(2)
            sprite:getChildByTag(11):removeAllChildrenWithCleanup(true)
            if icon then 
                sprite:getChildByTag(11):addChild(icon)
            end
            icount = icount or ""
            name = name or ""
            tolua.cast(sprite:getChildByTag(15), "CCLabelBMFont"):setString(name)
            tolua.cast(sprite:getChildByTag(12), "CCLabelBMFont"):setString("x" .. tostring(icount))

            self.m_ticonbtn[1]:setVisible(true)
            self.m_ticonbtn[1]:setPositionX(sprite:getPositionX())
            self["m_node_titleicon" .. 3]:getChildByTag(1):setVisible(false)
            self["m_node_titleicon" .. 3]:getChildByTag(3):setVisible(false)
    end

 
    -- game_util:setControlButtonTitleBMFont(m_conbtn_getReward)
    -- for i=1,3 do
    --     -- print(self.m_spriteIcons[i])
    -- end
    for i=1,3 do
        self.m_labelInfo[i]:setString(tostring(infoData["info" .. i]))
    end
    self.m_node_itemxuanzhong:setPosition(0, self.m_node_itemxuanzhong:getParent():getContentSize().height * (0.88 - (selectedID - 1) * 0.19))
end
--[[--
    刷新ui
]]
function game_payplan_pop.createOpeningTabelView(self)
    if self.m_tableView == nil then
        self.m_tableView = self:createActivityTableView(self.m_list_view_bg:getContentSize());
        self.m_list_view_bg:addChild(self.m_tableView)
    end
end
--[[--
    刷新ui
]]
function game_payplan_pop.refreshUi(self)
   
end
--[[--
    初始化
]]
function game_payplan_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tActivityData = {init = false, data = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()), turnUICallFun = t_params.turnUICallFun}
end

--[[--
    创建ui入口并初始化数据
]]
function game_payplan_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_payplan_pop;
