---  卡牌分解
local game_card_split = {
    m_table_view = nil,--table
    m_back_btn = nil,--返回
    m_dirt_sliver_label = nil,--银尘
    m_dirt_gold_label = nil,--金尘

    m_sprite_background = nil,--显示英雄卡牌的背景

    m_for_shop_btn = nil,--兑换商店
    m_split_btn = nil,--分解
    m_auto_add_btn = nil,--自动添加

    m_select_flag = nil,
    test_count = nil,
    m_select_id_table = nil,--记录选择的

    m_text_label1 = nil,--
    m_text_label2 = nil,
    sliver_dir_value = nil,--超能之尘值
    sliver_dir_min = nil,
    sliver_dir_max = nil,
    gold_dir_value = nil,
    gold_dir_min = nil,
    gold_dir_max = nil,

    m_hero_id_table = nil,--存英雄Id的表
    m_btn_table = nil,--切换排序
    m_temp_table = nil,--裁剪的卡牌表

    m_real_list = nil,

    m_sprite_tag = nil,--sprite tag 的索引
    m_selHeroId = nil,

    split_flag = nil,--分解动画flag
    split_index = nil,--
    m_node_splitbtnboard = nil,  -- 分解种类选择按钮板
    m_control_btns = nil,  -- 控制按钮
}
--[[--
    销毁ui
]]
function game_card_split.destroy(self)
    -- body
    cclog("-----------------game_card_split destroy-----------------");
    self.m_table_view = nil;
    self.m_back_btn = nil;
    self.m_back_btn = nil;
    self.m_dirt_sliver_label = nil;
    self.m_dirt_gold_label = nil;

    self.m_sprite_background = nil;

    self.m_for_shop_btn = nil;
    self.m_split_btn = nil;
    self.m_auto_add_btn = nil;

    self.m_select_flag = nil;
    test_count = nil;
    self.m_select_id_table = nil;

    self.m_text_label1 = nil;
    self.m_text_label2 = nil;
    self.sliver_dir_value = nil;
    self.gold_dir_value = nil;

    self.m_hero_id_table = nil;
    self.m_btn_table = nil;
    self.m_temp_table = nil;

    self.m_real_list = nil;
    self.m_sprite_tag = nil;
    self.m_selHeroId = nil;

    self.sliver_dir_min = nil;
    self.sliver_dir_max = nil;
    self.gold_dir_min = nil;
    self.gold_dir_max = nil;
    self.split_flag = nil;
    self.split_index = nil;
    self.m_node_splitbtnboard = nil;
    self.m_control_btns = nil;
end
--[[--
    返回
]]
function game_card_split.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_card_split.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--兑换商城
            local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_card_split"})
                self:destroy()
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")
        elseif btnTag == 101 then--分解
            self.split_index = 0
            local function card_split(card_list)
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local cards_remove = data:getNodeWithKey("_client_cache_update"):getNodeWithKey("cards"):getNodeWithKey("cards"):getNodeWithKey("remove")
                    local cards_remove_count = cards_remove:getNodeCount();
                    -- cclog("game_card_split data == "..data:getFormatBuffer())
                    -- local dirt_silver_value = data:getNodeWithKey("reward"):getNodeWithKey("dirt_silver"):toInt()
                    -- local dirt_gold_value = data:getNodeWithKey("reward"):getNodeWithKey("dirt_gold"):toInt()
                    local reward = data:getNodeWithKey("reward")
                    game_util:rewardTipsByJsonData(reward);
                    
                    -- cclog("items == "..items:getFormatBuffer())
                    -- local function get_item_name()
                    --     local name = "";
                    --     local item = getConfig(game_config_field.item);
                    --     for i=1,items:getNodeCount() do
                    --         local tempId = items:getNodeAt(i-1)
                    --         local itemCfg = item:getNodeWithKey(tempId:toStr());
                    --         if itemCfg then
                    --             name = name .. itemCfg:getNodeWithKey("name"):toStr() .. "  "
                    --         end
                    --     end
                    --     return name;
                    -- end
                    -- local t_params = 
                    -- {
                    --     title = string_config.m_warning,
                    --     okBtnCallBack = function(target,event)
                    --         game_util:closeAlertView();
                    --     end,   --可缺省
                    --     okBtnText = string_config.m_btn_close,       --可缺省
                        
                    --     text = "超能之尘：" .. dirt_silver_value .. " 超超能之尘：" .. dirt_gold_value .. " 物品：" .. get_item_name();
                    -- }
                    -- game_util:openAlertView(t_params);
                    -- cclog("dirt_silver = "..dirt_silver .. "dirt_gold = " ..dirt_gold .. "items = " .. items:getFormatBuffer());

                    -- for i=1,cards_remove_count do
                    --     local temp_id = cards_remove:getNodeAt(i-1)
                    --     cclog("temp_id= "..temp_id:toStr());
                    --     cclog("self.m_hero_id_table=="..json.encode(self.m_hero_id_table));
                    --     local flag,k = game_util:idInTableById(tostring(temp_id),self.m_hero_id_table);
                    --     if flag and k ~= nil then
                    --         local index = self.m_select_id_table[k];
                    --         cclog("self.m_select_id_table=="..json.encode(self.m_select_id_table));
                    --         cclog("index="..index);
                    --         if self.m_sprite_background:getChildByTag(index) ~= nil then
                    --             self.m_sprite_background:removeChildByTag(index,true);
                    --         end
                    --         table.remove(self.m_select_id_table,k);
                    --         table.remove(self.gold_dir_value,k);
                    --         table.remove(self.m_hero_id_table,k);
                    --     end
                    -- end

                    local function remove_node( node )--回调隐藏，回归原位
                        cclog("remove_node")
                        self.split_index = self.split_index + 1
                        if self.split_index > #self.m_hero_id_table then
                            node:removeFromParentAndCleanup(true)
                            self.sliver_dir_value = 0;
                            self.sliver_dir_min = 0;
                            self.sliver_dir_max = 0;
                            self.gold_dir_min = 0;
                            self.gold_dir_max = 0;

                            self.m_dirt_sliver_label:setString(tostring(self.sliver_dir_value))
                            
                            self.gold_dir_value = 0;
                            self.m_dirt_gold_label:setString(self.gold_dir_value);

                            --
                            self.split_index = 0
                            self.split_flag = false
                        end
                    end
                    local function anim_call_function(sprite)
                        cclog("anim_call_function")
                        local anim_node = game_util:createSplitEffectAnim("animi_card_split1",1,false,remove_node,sprite)
                        local anima_size = sprite:getContentSize()
                        local pX,pY = sprite:getPosition();
                        anim_node:setAnchorPoint(ccp(0.5,0.5))
                        anim_node:setPosition(ccp(pX,pY));
                        self.m_sprite_background:addChild(anim_node,10)
                        game_sound:playUiSound("zhakai2")
                    end

                    self.split_flag = true
                    --特效动画 animi_hero_inherit    animi_card_split
                    for i=1,#self.m_hero_id_table do
                        cclog("i----------------"..i)
                        local hero_id = self.m_hero_id_table[i];
                        local sprite_tag = self.m_select_id_table[tostring(hero_id)];
                        local sprite = tolua.cast(self.m_sprite_background:getChildByTag(sprite_tag),"CCSprite");
                        local function callback(sprite)
                            cclog("callback")
                            local anim_node = game_util:createSplitEffectAnim("animi_card_split",1,false,anim_call_function,sprite)
                            local anima_size = sprite:getContentSize()
                            local pX,pY = sprite:getPosition();
                            anim_node:setAnchorPoint(ccp(0.5,0.5))
                            anim_node:setPosition(ccp(pX,pY));
                            local count = #self.m_hero_id_table
                            self.m_sprite_background:addChild(anim_node,30-(count-i))
                            --音效
                            game_sound:playUiSound("qian1")
                        end
                        local animArr = CCArray:create();
                        animArr:addObject(CCDelayTime:create(0.2 * (#self.m_hero_id_table-i)));
                        animArr:addObject(CCCallFuncN:create(callback));
                        local sequence = CCSequence:create(animArr);
                        sprite:runAction(sequence); 
                    end
                    self.m_select_id_table = {}
                    -- self.gold_dir_value = {}
                    self.m_hero_id_table = {}
                    self.m_real_list = {}
                    -- self.split_flag = false
                    --必须重新加载卡牌数据，否则会报错
                    self.m_temp_table = game_data:getCardsDataByQuality(2);
                    game_data:cardsSortByTypeNameWithTable("default",self.m_temp_table);
                    self:refreshUi();
                end
                local params = "";
                for i=1,#self.m_hero_id_table do
                    params = params .. "card_id="..self.m_hero_id_table[i].."&";
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_exchange"), http_request_method.GET, params,"cards_exchange")
            end
            if #self.m_hero_id_table > 0 then
                local userful_id = ""
                local tip_flag = false
                local tip_type = 0
                for i=1,#self.m_hero_id_table do
                    local split_id = self.m_hero_id_table[i]
                    local itemData,hero_config = game_data:getCardDataById(split_id)
                    local advance_step = itemData.step -- 进阶层数
                    local lv = itemData.lv  --等级
                    local quality = itemData.quality --品质
                    --进阶>=1 lv >= 10 品质>= 2 的提示
                    if advance_step > 0 then
                        userful_id = split_id
                        tip_flag = true
                        tip_type = 1
                        break;
                    elseif lv >= 10 then
                        userful_id = itemData.id
                        tip_flag = true
                        tip_type = 2
                        break;
                    end
                end
                if tip_flag == true then
                    if tip_type == 1 then
                        local sliver_min,gold_min,sliver_max,gold_max = self:get_dirt_from_index(1,userful_id)
                        local params = {}
                        params.m_openType = 9
                        params.hero_id = userful_id
                        params.sliver_dir_basis = sliver_min .. "-" .. sliver_max
                        params.gold_dir_basis = gold_min .. "-" .. gold_max
                        params.okBtnCallBack = function()
                            game_scene:removePopByName("game_special_tips_pop")
                            card_split();
                        end
                        game_scene:addPop("game_special_tips_pop",params)
                    elseif tip_type == 2 then
                        local params = {}
                        params.m_openType = 10
                        params.hero_id = userful_id
                        params.okBtnCallBack = function()
                            game_scene:removePopByName("game_special_tips_pop")
                            card_split();
                        end
                        game_scene:addPop("game_special_tips_pop",params)
                    end
                else
                    card_split();
                end
            else
                game_util:addMoveTips({text = string_helper.game_card_split.add_partner_split})
            end
        elseif btnTag == 102 then--自动添加
        --[[    local function callBackFunc(showHeroTable)
                cclog("showHeroTable == " .. json.encode(showHeroTable));
                --三个表都得更新
                self.m_hero_id_table = {}
                self.m_select_id_table = {}
                self.gold_dir_value = {}
                self.sliver_dir_value = 0

                --添加英雄全身像
                self.m_sprite_background:removeAllChildrenWithCleanup(true)
                for i=1,#showHeroTable do
                    local card_id = showHeroTable[i]
                    local index = game_data:getIndexByCardId(card_id)
                    cclog("index == "..index)

                    table.insert(self.m_select_id_table,100+index);
                    table.insert(self.m_hero_id_table,card_id);
                    --得到尘的数量
                    local sliver,gold = self:get_dirt_from_index(index-1)
                    self.sliver_dir_value = self.sliver_dir_value + sliver;
                    table.insert(self.gold_dir_value,gold);

                    local itemData,hero_config = game_data:getCardDataByIndex(index)
                    local hero_node = game_util:createHeroListItemByCCB(itemData);
                    hero_node:setAnchorPoint(ccp(0.5,0.5))
                    local node_size = hero_node:getContentSize();
                    self.m_sprite_background:addChild(hero_node,10,100+index);
                end
                self.m_dirt_sliver_label:setString(self.sliver_dir_value);
                for key, value in pairs(self.gold_dir_value) do  
                    if value == 2 then
                        self.m_dirt_gold_label:setString("低概率");
                        break;
                    else
                        self.m_dirt_gold_label:setString("无");
                    end
                end
                self:refresh_select_list();
                --刷新列表
                self:refreshUi();

            end
            game_scene:addPop("game_split_pop",{showType = 1,callBackFunc = callBackFunc})
        ]]--
            local function get_last_hero()
                local index = 0
                local itemData = nil
                local tempIdTable = self.m_temp_table
                for i=#tempIdTable,1,-1 do
                    --得到最后一个，去排除  quality < 2 出战和 加锁，训练的，和没有选择过的 返回符合条件的第一个
                    -- local hero_data,hero_config = game_data:getCardDataByIndex(i)
                    local hero_data,hero_config = game_data:getCardDataById(tempIdTable[i]);
                    local quality = hero_data.quality
                    local is_in_team = game_data:heroInTeamById(hero_data.id);
                    local is_lock = game_util:getCardUserLockFlag(hero_data);
                    local is_in_train = game_util:getCardTrainingFlag(hero_data)
                    local can_select = is_in_team or is_lock or is_in_train;
                    if can_select == false and quality >= 2 then
                        --exchage_id > 0 才让添加
                        if not hero_data.step or hero_data.step < 4 then  --"进阶4次的伙伴重生后才能分解！
                            local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
                            if exchange_id > 0 then
                                local flag,k = game_util:idInTableById(tostring(hero_data.id),self.m_hero_id_table);
                                if flag and k ~= nil then
                                else
                                    index = i;
                                    itemData = hero_data;
                                    break;
                                end
                            end
                        end
                    end
                end
                return index,itemData
            end
            if self.split_flag == true then
                game_util:addMoveTips({text = string_helper.game_card_split.spliting});
            else
                local index,itemData = get_last_hero()
                if itemData then
                    if #self.m_real_list <= 10 then
                        self:addHeroFromCellIndex(index-1,itemData)
                        self:refreshUi()
                    else
                        game_util:addMoveTips({text = string_helper.game_card_split.split_numtop});
                    end
                else
                    game_util:addMoveTips({text = string_helper.game_card_split.notcard});
                end
            end
        elseif btnTag == 105 then--返回
            self:back();
        elseif btnTag > 200 and btnTag < 205 then
            local index = btnTag - 200;
            for i=1,4 do
                self.m_btn_table[i]:setEnabled(true)
                self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
            end
            self.m_btn_table[index]:setEnabled(false)
            self.m_btn_table[index]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateDisabled);
            --切换table
            local typeTable = {"default","quality","lv","profession",};
            game_data:cardsSortByTypeNameWithTable(typeTable[index],self.m_temp_table);
            self:refreshUi();
        elseif btnTag == 1002 then--装备分解
            if not game_button_open:checkButtonOpen(607) then
                return;
            end
            game_scene:enterGameUi("ui_equip_split");
            self:destroy();
        elseif btnTag == 1003 then--宝石分解
            if not game_button_open:checkButtonOpen(121) then
                return;
            end
            game_scene:enterGameUi("ui_gem_split");
            self:destroy();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_card_split.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node");
    self.m_dirt_sliver_label = ccbNode:labelBMFontForName("dirt_sliver_label");
    self.m_dirt_gold_label = ccbNode:labelBMFontForName("dirt_gold_label");

    self.m_sprite_background = ccbNode:spriteForName("sprite_background");

    self.m_for_shop_btn = ccbNode:controlButtonForName("btn_duihuan");
    self.m_split_btn = ccbNode:controlButtonForName("btn_fenjie");
    self.m_auto_add_btn = ccbNode:controlButtonForName("btn_auto_add");

    game_util:setCCControlButtonTitle(self.m_for_shop_btn,string_helper.ccb.text87)
    game_util:setCCControlButtonTitle(self.m_split_btn,string_helper.ccb.text88)
    game_util:setCCControlButtonTitle(self.m_auto_add_btn,string_helper.ccb.text89)

    -- game_util:setControlButtonTitleBMFont(self.m_for_shop_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_split_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    
    self.m_back_btn = ccbNode:controlButtonForName("btn_back");
    --播放动画
    self.m_text_label1 = ccbNode:spriteForName("text_label1");
    self.m_text_label2 = ccbNode:spriteForName("text_label2");
    self.m_btn_table = {}
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);

    -- local anmiTimeLine = "Label Timeline"
    local anmiTimeLine = "Default Timeline"
    local function animCallFunc(animName)
        ccbNode:runAnimations(anmiTimeLine)
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(anmiTimeLine)
    self.test_count = 0;
    --将英雄信息加入
    self.m_select_id_table = {};
    self.m_hero_id_table = {};
    self.sliver_dir_value = 0;
    self.sliver_dir_min = 0
    self.sliver_dir_max = 0
    self.gold_dir_min = 0
    self.gold_dir_max = 0
    self.gold_dir_value = 0;
    self.m_dirt_sliver_label:setString(tostring(self.sliver_dir_value))
    self.m_dirt_gold_label:setString(tostring(self.gold_dir_value))
    -- 选择分解种类三按钮
    self.m_node_splitbtnboard = ccbNode:nodeForName("m_node_splitbtnboard")
    local m_card_split = ccbNode:controlButtonForName("m_card_split")
    local m_equip_split = ccbNode:controlButtonForName("m_equip_split")
    local m_gem_split = ccbNode:controlButtonForName("m_gem_split")
    self.m_control_btns =   {btn1 = m_card_split, btn2 = m_equip_split, btn3 = m_gem_split}

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text83)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text84)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text85)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text86)

    return ccbNode;
end

local ButtonInfoTable = 
{
    btn1 = {name = string_helper.game_card_split.split_card, Inreview = 32, btnId = 507, openFlag = true, btnIndex = 1},
    btn2 = {name = string_helper.game_card_split.split_equip, Inreview = 25, btnId = 607, openFlag = true, btnIndex = 2 },
    btn3 = {name = string_helper.game_card_split.split_gem, Inreview = 130, btnId = 121, openFlag = true, btnIndex = 3 },
}
local TablePosX = {
    {0.5},
    {0.35, 0.65},
    {0.15, 0.5, 0.85},
}

--[[
    刷新按钮状态 分解卡牌 分解装备 分解宝石
]]
function game_card_split.refreshBtnStutas( self )
    local newBtnState = {}
    local len = game_util:getTableLen(ButtonInfoTable)
    for i=1, len do
        local curBtn = ButtonInfoTable["btn" .. tostring(i)] or {}
        local btn = self.m_control_btns["btn" .. tostring(curBtn.btnIndex)] or nil
        if btn and  game_data:isViewOpenByID( curBtn.Inreview ) then
            table.insert(newBtnState, curBtn)
            btn:setVisible(true)
        elseif btn  then
            btn:setVisible(false)
        end
    end
    -- cclog2(newBtnState, "newBtnState  ====  ")
    local posx = TablePosX[#newBtnState]
    local tempSize = self.m_node_splitbtnboard:getContentSize()
    for i,v in ipairs(newBtnState) do
        local btn = self.m_control_btns["btn" .. tostring(v.btnIndex)] or nil
        if btn then
            btn:setPositionX(tempSize.width * posx[i])
            game_button_open:setButtonShow(btn, v.btnId, 1);
        end
    end
end

--[[
    刷新选中英雄
]]--
function game_card_split.refresh_select_list(self)
    -- cclog("count == " .. #self.m_hero_id_table)
    -- cclog("self.m_hero_id_table == " .. json.encode(self.m_hero_id_table))
    -- cclog("self.m_select_id_table == " .. json.encode(self.m_select_id_table))
    self.m_real_list = {}
    for i=1,#self.m_hero_id_table do
        local hero_id = self.m_hero_id_table[i];
        if tostring(hero_id) ~= tostring(0) then
            table.insert(self.m_real_list,hero_id)
        end
    end
    local count = #self.m_real_list
    local length = 10;
    if count <= 10 then
        length = 10;
    else
        length = 100 / count;
    end
    for i=1,#self.m_real_list do
        local hero_id = self.m_real_list[i];
        local sprite_tag = self.m_select_id_table[tostring(hero_id)];
        cclog("sprite_tag == " .. sprite_tag)
        local hero_node = self.m_sprite_background:getChildByTag(sprite_tag);
        local node_size = hero_node:getContentSize();
        hero_node:setPosition(ccp(node_size.width*0.5+10+(count-i)*length,node_size.height*0.5+8));
    end
end

--[[
    创建分解列表
]]--
function game_card_split.createTableView( self,viewSize )
    -- local cardsCount = game_data:getCardsCount();
    local tempIdTable = self.m_temp_table
    local cardsCount = #tempIdTable;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = cardsCount;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
--[[
    cell
]]--
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createHeroListItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData,itemCfg = game_data:getCardDataById(tempIdTable[cardsCount - index]);
            if itemData and itemCfg then
                local heroId = itemData.id;
                game_util:setHeroListItemInfoByTable2(ccbNode,itemData);

                local sprite_selected = ccbNode:spriteForName("sprite_selected");
                local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
                
                local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_hero_id_table);
                if flag then
                    sprite_selected:setVisible(true);
                    sprite_back_alpha:setVisible(true);
                else
                    sprite_selected:setVisible(false);
                    sprite_back_alpha:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item) .. " ; item:getUserData() = " .. tolua.type(item:getUserData()));
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
            local sprite_selected = ccbNode:spriteForName("sprite_selected");
            -- local itemData,hero_config = game_data:getCardDataByIndex(cardsCount - index);
            local itemData,hero_config = game_data:getCardDataById(tempIdTable[cardsCount - index]);

            -- cclog("itemData == " .. json.encode(itemData))
            -- cclog("hero_config = " .. hero_config:getFormatBuffer())

            -- local flag,k = game_util:idInTableById(tostring(100+cardsCount - index),self.m_select_id_table);
            local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_hero_id_table);
            if flag and k ~= nil then
                -- table.remove(self.gold_dir_value,k);
                table.remove(self.m_hero_id_table,k);
                -- self.gold_dir_value[k] = 0
                -- self.m_hero_id_table[k] = 0

                sprite_selected:setVisible(false);
                sprite_back_alpha:setVisible(false);
                for key,value in pairs(self.m_select_id_table) do
                    if tostring(key) == tostring(itemData.id) then
                        if self.m_sprite_background:getChildByTag(value) ~= nil then
                            self.m_sprite_background:removeChildByTag(value,true);
                        end
                        --删除select_table 的该项
                        -- self.m_select_id_table[key] = nil;
                    end
                end

                self:refresh_select_list();
                local sliver_min,gold_min,sliver_max,gold_max = self:get_dirt_from_index(index,itemData.id)
                self.sliver_dir_min = self.sliver_dir_min - sliver_min
                self.sliver_dir_max = self.sliver_dir_max - sliver_max

                self.sliver_dir_value = self.sliver_dir_min .. "-" .. self.sliver_dir_max
                --
                self.m_dirt_sliver_label:setString(self.sliver_dir_value);
                
                self.gold_dir_min = self.gold_dir_min - gold_min
                self.gold_dir_max = self.gold_dir_max - gold_max
        
                self.gold_dir_value = self.gold_dir_min .. "-" .. self.gold_dir_max
                self.m_dirt_gold_label:setString(self.gold_dir_value);
            else
                if self.split_flag == true then
                    game_util:addMoveTips({text = string_helper.game_card_split.spliting});
                else
                    local is_in_team = game_data:heroInTeamById(itemData.id);
                    local is_lock = game_util:getCardUserLockFlag(itemData);
                    local is_in_train = game_util:getCardTrainingFlag(itemData);
                    local is_in_cheer = game_data:heroInAssistantById(itemData.id)
                    local can_select = is_in_team or is_lock or is_in_train or is_in_cheer;
                    if can_select == true then
                        if is_in_team then
                            game_util:addMoveTips({text = string_helper.game_card_split.text1});
                        elseif is_in_train then
                            game_util:addMoveTips({text = string_helper.game_card_split.text2});
                        elseif is_lock then
                            game_util:addMoveTips({text = string_helper.game_card_split.text3});
                        elseif is_in_cheer then
                            game_util:addMoveTips({text = string_helper.game_card_split.text4});
                        end
                    else
                        local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
                        if itemData.step and itemData.step >= 4 then
                            game_util:addMoveTips({text = string_helper.game_card_split.text5});
                        elseif exchange_id > 0 then
                            if #self.m_real_list <= 10 then
                                sprite_selected:setVisible(true);
                                sprite_back_alpha:setVisible(true);
                                self:addHeroFromCellIndex(index,itemData)
                                -- self:refreshUi()
                            else
                                game_util:addMoveTips({text = string_helper.game_card_split.split_numtop});
                            end
                        else--exchange_id=0 的伙伴不能分解
                            game_util:addMoveTips({text = string_helper.game_card_split.text6});
                        end
                    end
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加英雄全身像
]]--
function game_card_split.addHeroFromCellIndex(self,index,itemData)
    local is_in_team = game_data:heroInTeamById(itemData.id);
    local is_lock = game_util:getCardUserLockFlag(itemData);
    local is_in_train = game_util:getCardTrainingFlag(itemData)
    local is_in_cheer = game_data:heroInAssistantById(itemData.id)
    local can_select = is_in_team or is_lock or is_in_train or is_in_cheer;
    if can_select == true then
    else
        table.insert(self.m_hero_id_table,itemData.id);
        local hero_node = game_util:createHeroListItemByCCB(itemData);
        hero_node:setAnchorPoint(ccp(0.5,0.5))
        local node_size = hero_node:getContentSize();
        -- self.m_select_id_table[tostring(itemData.id)] = 100+#self.m_hero_id_table;--修改tag 的索引
        self.m_select_id_table[tostring(itemData.id)] = self.m_sprite_tag
        -- self.m_sprite_background:addChild(hero_node,10,100+#self.m_hero_id_table);
        self.m_sprite_background:addChild(hero_node,10,self.m_sprite_tag);
        self:refresh_select_list();

        local sliver_min,gold_min,sliver_max,gold_max = self:get_dirt_from_index(index,itemData.id)
        self.sliver_dir_min = self.sliver_dir_min + sliver_min
        self.sliver_dir_max = self.sliver_dir_max + sliver_max
        -- self.sliver_dir_value = self.sliver_dir_value + sliver;
        self.sliver_dir_value = self.sliver_dir_min .. "-" .. self.sliver_dir_max

        self.m_dirt_sliver_label:setString(self.sliver_dir_value);

        -- table.insert(self.gold_dir_value,gold);
        self.gold_dir_min = self.gold_dir_min + gold_min
        self.gold_dir_max = self.gold_dir_max + gold_max
        
        self.gold_dir_value = self.gold_dir_min .. "-" .. self.gold_dir_max
        self.m_dirt_gold_label:setString(self.gold_dir_value);

        self.m_sprite_tag = self.m_sprite_tag + 1
    end
end
--[[
    得到sivler gold dirt 的值
]]--
function game_card_split.get_dirt_from_index(self,index,id)
    local sliver_value = 0;
    local itemData,hero_config = game_data:getCardDataById(id)

    local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
    -- cclog("quality == " .. itemData.quality)
    -- cclog("exchange_id == " .. exchange_id);
    local character_exchange_cfg = getConfig(game_config_field.character_exchange)
    local data_config = character_exchange_cfg:getNodeWithKey(tostring(exchange_id))
    -- cclog("data_config = " .. data_config:getFormatBuffer())
    local dirt_gold = data_config:getNodeWithKey("dirt_gold")
    local dirt_silver = data_config:getNodeWithKey("dirt_silver")
    local dirt_silver0 = dirt_silver:getNodeAt(0);
    -- local evo = (itemData.evo + 1);
    cclog2(itemData.evo,"itemData.evo")
    cclog2(itemData.quality,"itemData.quality")
    --获得进阶到evo的卡牌需要多少张卡牌
    local costCard = self:getAdvancedCount(itemData.evo,itemData.quality,hero_config)
    local evo = costCard + 1;--分解能获得的为消耗的卡牌+1（本身）

    sliver_value = dirt_silver0:getNodeAt(0):toInt()*evo;

    local sliver_max = dirt_silver0:getNodeAt(1):toInt()*evo;
    local gold_min = 1*evo
    local gold_max = 1*evo
    for i=1,dirt_gold:getNodeCount() do
        local gold_1 = dirt_gold:getNodeAt(i-1):getNodeAt(0):toInt()
        local gold_2 = dirt_gold:getNodeAt(i-1):getNodeAt(1):toInt()

        if gold_1 < gold_min then
            gold_min = gold_1*evo
        end
        if gold_2 > gold_max then
            gold_max = gold_2*evo
        end
    end
    -- cclog("dirt_gold_count == " .. dirt_gold_count)
    -- local dirt_gold_count = dirt_gold:getNodeCount();
    return sliver_value,gold_min,sliver_max,gold_max;
end
--[[
    获得进阶到N的卡牌消耗的卡牌
]]
function game_card_split.getAdvancedCount(self,evo,quality,heroCfg)
    local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg);--game_util:getEvolutionCfgByQuality(quality);
    local totalExp = 0
    for i=1,evo + 1 do
        local itemCfg = evolutionCfg:getNodeWithKey(tostring(i-1))
        local evo_exp = itemCfg:getNodeWithKey("exp"):toInt()
        totalExp = totalExp + evo_exp
    end
    local costCard = math.floor(totalExp / 10)
    return costCard
end
--[[--
    刷新ui
]]
function game_card_split.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    -- self.m_temp_table = game_data:getCardsDataByQuality(2);
    -- game_data:cardsSortByTypeNameWithTable("default",self.m_temp_table);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);
    self:refreshBtnStutas()
end
--[[--
    初始化
]]
function game_card_split.init(self,t_params)
    t_params = t_params or {};
    self.m_temp_table = game_data:getCardsDataByQuality(2);
    game_data:cardsSortByTypeNameWithTable("default",self.m_temp_table);
    self.m_sprite_tag = 101;
    self.m_selHeroId = t_params.selHeroId
    self.m_real_list = {}
    self.split_flag = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_card_split.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("12");
    if id == 1201 then
        game_guide_controller:gameGuide("drama","12",1201)
    end
    return scene;
end

return game_card_split;