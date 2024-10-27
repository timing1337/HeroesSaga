--- 学校-new
local game_school_new = {
    m_free_times = nil,
    m_food_label = nil,
    m_gold_label = nil,

    m_open_text = nil,
    m_btn_stop = nil,
    m_btn_accelera = nil,
    m_train_bit = nil,
    m_rest_time = nil,
    m_free_times = nil,
    m_food_label = nil,
    m_gold_label = nil,
    m_team_bg_table = nil,
    m_open_node = nil,
    m_select_btn = nil,
    m_ok_btn = nil,

    m_train_mode = nil,
    m_train_exp = nil,
    m_train_pos = nil,
    m_guildNode = nil,
    m_selHeroId = nil,
    m_selHeroDataBackup = nil,
    m_stoves_data = nil,

    open_flag = nil,
    showType = nil,
    time_index = nil,
    selHeroId = nil,
    train_type = nil,
};
--[[--
    销毁
]]
function game_school_new.destroy(self)
    -- body
    cclog("-----------------game_school_new destroy-----------------");
    self.m_free_times = nil;
    self.m_food_label = nil;
    self.m_gold_label = nil;
    self.m_open_text = nil;
    self.m_btn_stop = nil;
    self.m_btn_accelera = nil;
    self.m_train_bit = nil;
    self.m_rest_time = nil;
    self.m_free_times = nil;
    self.m_food_label = nil;
    self.m_gold_label = nil;
    self.m_team_bg_table = nil;
    self.m_open_node = nil;
    self.m_select_btn = nil;
    self.m_ok_btn = nil;

    self.m_train_mode = nil;
    self.m_train_exp = nil;
    self.m_train_pos = nil;
    self.m_guildNode = nil;
    self.m_selHeroId = nil;
    self.m_selHeroDataBackup = nil;
    self.m_stoves_data = nil;
    self.open_flag = nil;
    self.showType = nil;
    self.time_index = nil;
    self.selHeroId = nil;
    self.train_type = nil;
end
--[[--
    返回
]]
function game_school_new.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
local train_mode_table = {"100%","120%","150%","200%","300%"};
--[[--
    读取ccbi创建ui
]]
function game_school_new.createUi(self)
    local ccbNode = luaCCBNode:create();
    
    local function getStoveIndex(posIndex)
        local stoves_name = self.m_train_pos[posIndex]
        return stoves_name
    end
    local function missionComplete(index,btnType)
        local function responseMethod(tag,gameData)
            game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
            self:initStovesFormation();
            cclog("school data == "..gameData:getNodeWithKey("data"):getFormatBuffer())
            game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(self.m_selHeroId)),heroDataBackup = self.m_selHeroDataBackup,openType=2})
        end

        self.m_selHeroId = self.m_stoves_data[index].card_id
        local posIndex = getStoveIndex(index)
        if btnType == 1 then
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    self.m_selHeroDataBackup = util.table_new(game_data:getCardDataById(tostring(self.m_selHeroId)));
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp"), http_request_method.GET, {stove_key = posIndex},"school_get_exp")
                    game_util:closeAlertView();
                end,   --可缺省
                okBtnText = string_config.m_stop_training,       --可缺省
                text = string_config.m_stop_training_tips,      --可缺省
            }
            game_util:openAlertView(t_params);
        else
            self.m_selHeroDataBackup = util.table_new(game_data:getCardDataById(tostring(self.m_selHeroId)));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp"), http_request_method.GET, {stove_key = posIndex},"school_get_exp")
        end
    end
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            self:back("back");
        elseif btnTag > 500 and btnTag < 510 then
            local index = btnTag - 500;
            local posIndex = getStoveIndex(index)
            cclog("self.open_flag[index] == " .. self.open_flag[index]);
            if self.open_flag[index] == 1 then--点击开启训练位置
                local openCfg = getConfig(game_config_field.character_train_position)
                cclog("posIndex == " .. posIndex)

                local itemCfg = openCfg:getNodeWithKey(tostring(posIndex))
                cclog("itemCfg = " .. itemCfg:getFormatBuffer())
                local value = itemCfg:getNodeWithKey("value"):getNodeAt(1):toInt()
                local function openRespond(tag,gameData)
                    game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
                    cclog("open data == "..gameData:getNodeWithKey("data"):getFormatBuffer())
                    self:initStovesFormation();
                end
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        network.sendHttpRequest(openRespond,game_url.getUrlForKey("vip_open_stove"), http_request_method.GET, {stove_key = posIndex},"vip_open_stove")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,
                    text = string.format(string_config.m_open_position,value)
                }
                game_util:openAlertView(t_params);
            else
                game_scene:enterGameUi("game_school_new_select",{gameData = nil,openType = "game_school_new_select",posIndex = posIndex});
                self:destroy();
            end
        elseif btnTag > 100 and btnTag < 110 then--停止
            local index = btnTag - 100;
            missionComplete(index,1)
        elseif btnTag > 110 and btnTag < 120 then--加速
            local index = btnTag - 110;
            self.m_selHeroId = self.m_stoves_data[index].card_id
            local function responseMethod(tag,gameData)
                game_data:setSchoolDataByJsonData(gameData:getNodeWithKey("data"));
                cclog("school data == "..gameData:getNodeWithKey("data"):getFormatBuffer())
                self:initStovesFormation();
                game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(self.m_selHeroId)),heroDataBackup = self.m_selHeroDataBackup,openType=2})
            end
            local posIndex = getStoveIndex(index)
            local tGameData = game_data:getSchoolData();
            local stoves = tGameData.stoves;
            stoveItem = stoves[posIndex];

            local times = tGameData.vip_train_times
            local payCfg = getConfig(game_config_field.pay)
            local trainCfg = payCfg:getNodeWithKey("4")
            local itemCfg = trainCfg:getNodeWithKey("coin")

            local function createTip(tip_text,posIndex)
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self.m_selHeroDataBackup = util.table_new(game_data:getCardDataById(tostring(self.m_selHeroId)));
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_get_exp_force"), http_request_method.GET, {stove_key=posIndex},"school_get_exp_force")
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_speed_training,
                    text = tip_text,
                }
                game_util:openAlertView(t_params);
            end

            if game_data:getFreeTrainTimes() == 0 and game_data:getVipLevel() == 0 then
                game_util:addMoveTips({text = string_helper.game_school_new.day_out});
            else
                local tip_text = ""
                if game_data:getFreeTrainTimes() > 0 then
                    tip_text = string.format(string_config.m_speed_training_free,game_data:getFreeTrainTimes())
                    createTip(tip_text,posIndex)
                else
                    if game_data:getVipLevel() > 0 then
                        if times < self:getVipFreeTime() then
                            local count = itemCfg:getNodeCount()
                            local coin = 0
                            if times < count then
                                coin = itemCfg:getNodeAt(tostring(times)):toInt()
                            else
                                coin = itemCfg:getNodeAt(tostring(count-1)):toInt()
                            end
                            tip_text = string_helper.game_school_new.speed_cost .. coin .. string_helper.game_school_new.diamond_y
                            createTip(tip_text,posIndex)
                        else
                            game_util:addMoveTips({text = string_helper.game_school_new.day_out});
                        end
                    end
                end
            end
            -- local time_need = math.floor(stoveItem.end_time - tGameData.now - game_data:getTimeDifference(tGameData.dataTime));

            -- local tip_text = string.format(string_config.m_speed_training_tips,math.ceil(time_need/60));
            -- if game_data:getFreeTrainTimes() > 0 then
            --     tip_text = string.format(string_config.m_speed_training_free,game_data:getFreeTrainTimes())
            -- end
        elseif btnTag > 600 and btnTag < 610 then--领奖
            local index = btnTag - 600;
            missionComplete(index,2)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_school.ccbi");

    self.m_open_text = {}
    self.m_btn_stop = {}
    self.m_btn_accelera = {}
    self.m_train_bit = {}
    self.m_rest_time = {}
    self.m_team_bg_table = {}
    self.m_open_node = {}
    self.m_select_btn = {}
    self.m_ok_btn = {}
    self.m_train_mode = {}
    self.m_train_exp = {}
    self.m_free_times = ccbNode:labelTTFForName("free_times_label")
    self.m_food_label = ccbNode:labelTTFForName("m_food_total_label")
    self.m_gold_label = ccbNode:labelTTFForName("m_money_total_label")
    for i=1,4 do
        self.m_open_text[i] = ccbNode:spriteForName("open_sprite_"..i)
        self.m_btn_stop[i] = ccbNode:controlButtonForName("btn_stop_"..i)
        self.m_btn_accelera[i] = ccbNode:controlButtonForName("btn_accelerate_"..i)
        self.m_train_bit[i] = ccbNode:spriteForName("bit_sprite_"..i)
        self.m_rest_time[i] = ccbNode:labelTTFForName("rest_time_label_"..i)
        self.m_team_bg_table[i] = ccbNode:spriteForName("m_team_bg_"..i)
        self.m_open_node[i] = ccbNode:nodeForName("open_node_"..i)
        self.m_select_btn[i] = ccbNode:controlButtonForName("btn_select_"..i)
        self.m_ok_btn[i] = ccbNode:controlButtonForName("btn_ok_"..i)
        self.m_train_mode[i] = ccbNode:labelTTFForName("train_mode_label_"..i)
        self.m_train_exp[i] = ccbNode:labelTTFForName("gain_exp_label_"..i)
        self.m_train_mode[i]:setString(string_helper.ccb.file59)
        self.m_rest_time[i]:setString(string_helper.ccb.file60)
        self.m_train_exp[i]:setString(string_helper.ccb.file61)

        self.m_select_btn[i]:setOpacity(0);
        game_util:setCCControlButtonTitle(self.m_ok_btn[i],string_helper.ccb.file7)
        game_util:setCCControlButtonTitle(self.m_btn_stop[i],string_helper.ccb.file6)
        game_util:setCCControlButtonTitle(self.m_btn_accelera[i],string_helper.ccb.file5)
        -- game_util:setControlButtonTitleBMFont(self.m_ok_btn[i])
        -- game_util:setControlButtonTitleBMFont(self.m_btn_stop[i])
        -- game_util:setControlButtonTitleBMFont(self.m_btn_accelera[i])
    end
    
    -- cclog("free times = " .. game_data:getFreeTrainTimes())
    -- self.m_free_times:setString(string.format(string_config.m_free_times,game_data:getFreeTrainTimes()))

    local function animCallFunc(animName)
        ccbNode:runAnimations("enter_anim")
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations("enter_anim")

    if self.showType == 2 then
        local params = {}
        params.time_index = self.time_index
        params.selHeroId = self.selHeroId
        params.train_type = self.train_type
        cclog("t_params = " .. json.encode(params))
        game_scene:addPop("game_school_pop",params)
    end
    return ccbNode;
end
--[[--
    初始化训练的位置信息
]]
function game_school_new.initStovesFormation(self)
    self.m_training_table = {};
    local tGameData = game_data:getSchoolData();
    -- cclog("tGameData == " .. json.encode(tGameData))
    local stoves = tGameData.stoves;
    local stovesCount = game_util:getTableLen(stoves);
    
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local food = game_data:getUserStatusDataByKey("food") or 1;
    local coin = game_data:getUserStatusDataByKey("coin") or 1;

    local value,unit = game_util:formatValueToString(food)
    local value2,unit2 = game_util:formatValueToString(coin)
    self.m_food_label:setString(tostring(value .. unit));
    self.m_gold_label:setString(tostring(value2 .. unit2));

    --坑位需要排序，顺序显示，但仍保存原始的标识 即开启顺序永远是 1.2.3.4 但是实际坑位可能是 stove_1 和 stove_2 或 stove_1 和 stove_3
    --坑位1 默认开启  2 根据等级判断 3 根据是否是VIP1 4 根据是否是VIP4
    local flags = {0,0,0}
    local stoves_name = {}
    table.insert(stoves_name,"stove_1")
    if level >= 30 then
        table.insert(stoves_name,"stove_2")
    else
        flags[1] = 1
    end
    if game_data:getVipLevel() >= 1 then
        table.insert(stoves_name,"stove_3")
    else
        flags[2] = 1
    end
    if game_data:getVipLevel() >= 4 then
        table.insert(stoves_name,"stove_4")
    else
        flags[3] = 1
    end
    if flags[1] == 1 then
        table.insert(stoves_name,"stove_2")
    end
    if flags[2] == 1 then
        table.insert(stoves_name,"stove_3")
    end
    if flags[3] == 1 then
        table.insert(stoves_name,"stove_4")
    end
    self.m_train_pos = stoves_name
    cclog("stoves_name == "  .. json.encode(stoves_name))
    self.m_stoves_data = {}
    self.open_flag = {}
    for i=1,4 do
        local stoveItem = stoves[stoves_name[i]];
        self.m_stoves_data[i] = stoveItem
        self.open_flag[i] = 0
        self.m_select_btn[i]:setEnabled(false);

        self.m_train_mode[i]:removeAllChildrenWithCleanup(true);
        self.m_train_exp[i]:removeAllChildrenWithCleanup(true);
        self.m_rest_time[i]:removeAllChildrenWithCleanup(true);
        self.m_team_bg_table[i]:removeAllChildrenWithCleanup(true);

        local flag = false
        if stoves_name[i] == "stove_1" then
            flag = true
        end
        if stoves_name[i] == "stove_2" and level >= 30 then
            flag = true
        elseif stoves_name[i] == "stove_2" and level < 30 then
            self.m_open_text[i]:setVisible(true)
            self.m_open_text[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_open_20.png"))
        end
        if stoves_name[i] == "stove_3" and  game_data:getVipLevel() >= 1 then
            flag = true
        elseif stoves_name[i] == "stove_3" and  game_data:getVipLevel() < 1 then
            self.m_open_text[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_open_vip1.png"))
            if game_data:isViewOpenByID(102) then
                self.m_open_text[i]:setVisible(true)
            else
                self.m_open_text[i]:setVisible(false)
            end
        end
        if stoves_name[i] == "stove_4" and  game_data:getVipLevel() >= 4 then
            flag = true
        elseif stoves_name[i] == "stove_4" and  game_data:getVipLevel() < 4 then
            self.m_open_text[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_open_vip4.png"))
            if game_data:isViewOpenByID(102) then
                self.m_open_text[i]:setVisible(true)
            else
                self.m_open_text[i]:setVisible(false)
            end
        end
        if flag == true then
            if stoveItem.available == 0 then
                self.m_train_bit[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_bit_closed.png"))

                self.m_team_bg_table[i]:setVisible(false);
                self.m_open_text[i]:setVisible(true);
                self.m_open_text[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_train_open.png"))--点击开启
                self.m_select_btn[i]:setEnabled(true);

                self.m_ok_btn[i]:setVisible(false)
                self.m_open_node[i]:setVisible(false);
                --设置flag
                self.open_flag[i] = 1
            else
                self.m_train_bit[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_bit_open.png"))--开启
                self.m_open_node[i]:setVisible(true);
                if stoveItem.card_id ~= 0 then
                    self.m_team_bg_table[i]:setVisible(true);
                    self.m_open_text[i]:setVisible(false);
                    --添加英雄
                    local animNode = self:createCardAnimById(tostring(stoveItem.card_id));
                    if animNode and self.m_team_bg_table[i] then
                        local tempSize = self.m_team_bg_table[i]:getContentSize();
                        animNode:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.13));
                        self.m_team_bg_table[i]:addChild(animNode,1,1);
                    end
                    local function timeEndFunc(label,type)
                        self.m_ok_btn[i]:setVisible(true)
                        self.m_btn_stop[i]:setVisible(false)
                        self.m_btn_accelera[i]:setVisible(false)
                        --设置绿色
                        self.m_rest_time[i]:removeAllChildrenWithCleanup(true)
                        local text = game_util:createLabelTTF({text = string_helper.game_school_new.complate,color = ccc3(42,227,43),fontSize = 10})
                        text:setAnchorPoint(ccp(0,0.5))
                        text:setPosition(ccp(self.m_rest_time[i]:getContentSize().width + 3,self.m_rest_time[i]:getContentSize().height*0.5))
                        self.m_rest_time[i]:addChild(text)
                        -- 记录已经提示过的的训练完成的英雄
                        game_data.m_ttrainfinishCard[stoveItem.card_id] = true
                    end
                    local time_need = math.floor(stoveItem.end_time - tGameData.now - game_data:getTimeDifference(tGameData.dataTime));

                    local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
                    countdownLabel:setColor(ccc3(238,232,190))
                    countdownLabel:setAnchorPoint(ccp(0,0.5))
                    countdownLabel:setPosition(ccp(self.m_rest_time[i]:getContentSize().width + 3,self.m_rest_time[i]:getContentSize().height*0.5))
                    self.m_rest_time[i]:addChild(countdownLabel)
                    if time_need > 0 then
                        self.m_ok_btn[i]:setVisible(false)
                        self.m_btn_stop[i]:setVisible(true)
                        self.m_btn_accelera[i]:setVisible(true)

                        countdownLabel:setTime(time_need)
                    else
                        countdownLabel:setTime(0)
                        timeEndFunc()
                    end
                    --经验和模式
                    local gained_exp = stoveItem.exp   
                    local expLabel = game_util:createLabelTTF({text = gained_exp,color = ccc3(237,231,188),fontSize = 10});
                    expLabel:setAnchorPoint(ccp(0,0.5))
                    expLabel:setPosition(ccp(self.m_train_exp[i]:getContentSize().width + 3,self.m_train_exp[i]:getContentSize().height*0.5))
                    self.m_train_exp[i]:addChild(expLabel,10);

                    local mode = train_mode_table[stoveItem.train_type]
                    local modeLabel = game_util:createLabelTTF({text = mode,color = ccc3(251,152,5),fontSize = 10});
                    modeLabel:setAnchorPoint(ccp(0,0.5))
                    modeLabel:setPosition(ccp(self.m_train_mode[i]:getContentSize().width + 3,self.m_train_mode[i]:getContentSize().height*0.5))
                    self.m_train_mode[i]:addChild(modeLabel,10)
                else
                    self.m_team_bg_table[i]:setVisible(false);
                    self.m_open_text[i]:setVisible(true);
                    --设置可以训练
                    self.m_open_text[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_select.png"))
                    self.m_select_btn[i]:setEnabled(true);
                    --隐藏加速/减速/领取按钮
                    self.m_ok_btn[i]:setVisible(false)
                    self.m_open_node[i]:setVisible(false);
                    if self.m_guildNode == nil and i == 1 then
                        self.m_guildNode = self.m_open_text[i];
                    end
                end
            end
        else
            self.m_train_bit[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("train_bit_closed.png"))--未开启
            self.m_open_node[i]:setVisible(false);
            self.m_team_bg_table[i]:setVisible(false);
            self.m_ok_btn[i]:setVisible(false)
        end
    end
    if game_data:getFreeTrainTimes() > 0 then
        self.m_free_times:setString(string.format(string_config.m_free_times,game_data:getFreeTrainTimes()))
    else
        if game_data:getVipLevel() > 0 then
            local fast_train = self:getVipFreeTime()
            -- self.m_free_times:setString("今日可加速次数：" .. (fast_train-tGameData.vip_train_times) .. "/" .. fast_train)
            self.m_free_times:setString(string_helper.game_school_new.text .. (fast_train-tGameData.vip_train_times))
        else
            self.m_free_times:setString(string_helper.game_school_new.text2)
        end
    end
end
--[[
    得到免费次数
]]
function game_school_new.getVipFreeTime(self)
    local times = 0
    local vipCfg = getConfig(game_config_field.vip)
    local itemCfg = vipCfg:getNodeWithKey(tostring(game_data:getVipLevel()))
    local fast_train = itemCfg:getNodeWithKey("fast_train"):toInt()
    times = fast_train
    return times;
end
--[[--
    通过卡牌ID 来获得动画
]]
function game_school_new.createCardAnimById(self,cardId)
    local animNode = nil;
    local heroData,heroCfg = game_data:getCardDataById(cardId)
    if heroData and heroCfg then
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        animNode = game_util:createIdelAnim(ainmFile,0,heroData,heroCfg);
        if animNode then
            local itemSize = animNode:getContentSize();
            animNode:setAnchorPoint(ccp(0.5,0));
            local headBg = CCSprite:createWithSpriteFrameName("public_hengtiao.png");
            headBg:setOpacity(155);
            headBg:setPosition(ccp(itemSize.width*0.5,itemSize.height + 15));
            animNode:addChild(headBg)
            -- local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv .. "/" .. heroData.level_max,TYPE_FACE_TABLE.Arial_BoldMT,10);
            local tempLabel = CCLabelTTF:create("Lv." .. heroData.lv,TYPE_FACE_TABLE.Arial_BoldMT,10);
            tempLabel:setPosition(ccp(itemSize.width*0.5 - 40,itemSize.height + 15));
            tempLabel:setAnchorPoint(ccp(0,0.5));
            animNode:addChild(tempLabel,100,100)
            local occupation_cfg = getConfig(game_config_field.occupation);
            local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
            if occupation_item_cfg then
                local occupationType = occupation_item_cfg:toInt();
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
                if spriteFrame then
                    local occupation_icon = CCSprite:createWithSpriteFrame(spriteFrame)
                    occupation_icon:setPosition(ccp(itemSize.width*0.5 + 40,itemSize.height + 15));
                    occupation_icon:setAnchorPoint(ccp(1,0.5));
                    animNode:addChild(occupation_icon);
                end
            end
        end
    end
    return animNode;
end
--[[--
    刷新ui
]]
function game_school_new.refreshUi(self)
    self:initStovesFormation();
end
--[[--
    初始化
]]
function game_school_new.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        game_data:setSchoolDataByJsonData(t_params.gameData:getNodeWithKey("data"));
        self.showType = t_params.showType or 1
        self.time_index = t_params.time_index or 1
        self.selHeroId = t_params.selHeroId or nil
        self.train_type = t_params.train_type or 1
    end
end
--[[--
    创建入口
]]
function game_school_new.create(self,t_params)
    -- body
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    -- local id = game_guide_controller:getIdByTeam("4");
    -- if id == 43 then
    --     self:gameGuide("drama","4",43)
    -- elseif id == 45 then
    --     self:gameGuide("drama","4",46)
    -- end
    -- local id = game_guide_controller:getIdByTeam("10");
    -- if id == 1001 then
    --     game_guide_controller:gameGuide("drama","10",1001)
    -- end
    local id = game_guide_controller:getIdByTeam("10");
    if id == 1001 then
        self:gameGuide("drama","10",1001)
    end

    game_guide_controller:showEndForceGuide("10")
    -- game_data:resetForceGuideInfo("10")
    return scene;
end
--[[
    新手引导
]]
function game_school_new.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "10" and id == 1001 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","10",1002,{tempNode = self.m_guildNode})
                end
                game_guide_controller:gameGuide("send","10",1002);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
        -- if guide_team == "4" and id == 43 then
        --     local function endCallFunc()
        --         if self.m_guildNode then
        --             game_guide_controller:gameGuide("show","4",44,{tempNode = self.m_guildNode})
        --         end
        --     end
        --     t_params.guideType = "drama";
        --     t_params.endCallFunc = endCallFunc;
        --     game_guide_controller:showGuide(guide_team,guide_id,t_params)
        -- elseif guide_team == "4" and id == 46 then
        --     local function endCallFunc()
        --         game_guide_controller:gameGuide("send","4",47);
        --     end
        --     t_params.guideType = "drama";
        --     t_params.endCallFunc = endCallFunc;
        --     game_guide_controller:showGuide(guide_team,guide_id,t_params)
        -- end
    end
end

return game_school_new;
