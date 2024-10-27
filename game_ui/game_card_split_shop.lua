---  尘商店

local game_split_shop = {
    gameData = nil,

    m_silver_dir_label = nil,
    m_gold_dir_label = nil,
    m_time_label = nil,
    m_card_count_label = nil,

    m_hero_price_table = nil,
    m_hero_name_table = nil,
    m_dir_type_table = nil,
    m_icon_table = nil,
    m_btn_table = nil,
    m_shop_id_table = nil,

    look_hero_btn = nil,
    goods_info = nil,
    m_openType = nil,
--add
    black_bg = nil,
    black_bg_sellout = nil,
    equipment_tag = nil,

    m_gameData = nil,
    hero_count_label = nil,
    dir_type = nil,
    price_talble = nil,
    box_flag = nil,
    node_botton_info_board = nil,
};
--[[--
    销毁ui
]]
function game_split_shop.destroy(self)
    -- body
    cclog("-----------------game_split_shop destroy-----------------");
    self.m_silver_dir_label = nil;
    self.m_gold_dir_label = nil;
    self.m_time_label = nil;
    self.m_card_count_label = nil;

    self.m_hero_price_table = nil;
    self.m_hero_name_table = nil;
    self.m_dir_type_table = nil;
    self.m_icon_table = nil;
    self.m_btn_table = nil;
    self.m_shop_id_table = nil;
    self.look_hero_btn = nil;
    self.goods_info = nil;
    self.m_openType = nil;

--add
    self.black_bg = nil;
    self.black_bg_sellout = nil;
    self.equipment_tag = nil;
    if self.m_gameData then
        self.m_gameData:delete();
        self.m_gameData = nil;
    end
    self.hero_count_label = nil;
    self.dir_type = nil;
    self.price_talble = nil;
    self.box_flag = nil;
    self.node_botton_info_board = nil;
end
--[[--
    返回
]]
function game_split_shop.back(self,backType)
    -- if self.m_openType == "game_function_pop" then
    if self.m_openType == "game_card_split" then
        game_scene:enterGameUi("game_card_split",{gameData = nil});
        self:destroy();
    else 
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    -- elseif self.m_openType == 8 then--能晶
    --     game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData});
    --     self:destroy();
    -- elseif self.m_openType == 12 then--星灵
    --     local function responseMethod(tag,gameData)
    --         game_scene:enterGameUi("skills_practice_scene",{gameData = gameData});
    --         self:destroy();
    --     end
    --     network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_open"), http_request_method.GET, nil,"leader_skill_open")
    end
end
--[[--
    读取ccbi创建ui
]]
function game_split_shop.createUi(self)
    local ccbNode = luaCCBNode:create();
    --网络回调，进入和刷新用的同一个
    local function responseMethod(tag,gameData)
        --创建全身像
        local function get_hero_big_img(itemConfig)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/card_split_shop_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            local sprite_back = ccbNode:spriteForName("m_spr_bg")
            local icon_node = ccbNode:nodeForName("icon_node")
            local hero_name = ccbNode:labelBMFontForName("name_label")

            local animation = itemConfig:getNodeWithKey("animation"):toStr();
            local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();
            local quality = itemConfig:getNodeWithKey("quality"):toInt();
            local name = itemConfig:getNodeWithKey("name"):toStr()

            hero_name:setString(tostring(name))
            if quality > -1 and quality < 7 then
                sprite_back:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality+1].card_img));
            end
            local animNode = game_util:createImgByName("image_" .. animation,rgb)
            if animNode then
                local animNodeSize = animNode:getContentSize();
                local scale = math.min(1,animNodeSize.height~=0 and 70/animNodeSize.height or 1);
                animNode:setScale(scale);
                animNode:setAnchorPoint(ccp(0.5,0.5));
                icon_node:addChild(animNode)
                -- ccbNode:addChild(animNode)
            end
            return ccbNode
        end
        local data = gameData:getNodeWithKey("data")
        cclog("shop data = " .. data:getFormatBuffer())
        self.goods_info = json.decode(data:getFormatBuffer()) or {}
        local reward = data:getNodeWithKey("reward")
        if reward then
            game_util:rewardTipsByJsonData(reward);
        end
        local shop_data = data:getNodeWithKey("shops")
        local shop_config = getConfig(game_config_field.dirt_shop)
        local character_config = getConfig(game_config_field.character_detail)
        local sortTable = {}
        for i=1,shop_data:getNodeCount() do
            local shopItem = shop_data:getNodeAt(i-1)
            local shopKey = tonumber(shopItem:getKey())
            table.insert(sortTable,shopKey)
        end
        local function sortFunc(data1,data2)
            return tonumber(data1) < tonumber(data2)
        end
        table.sort(sortTable,sortFunc)
        self.m_shop_id_table = {}
        self.dir_type = {}
        self.price_talble = {}
        local shopCfgCount = shop_data:getNodeCount();
        for i=1,shopCfgCount do
            -- local itemData = shop_data:getNodeAt(i-1)
            local itemData = shop_data:getNodeWithKey(tostring(sortTable[i]))
            local is_buy_enabled = itemData:toInt()--value
            local config_id = itemData:getKey()--key
            self.m_shop_id_table[i] = config_id;
            cclog("config_id = " .. config_id)
            local shop_detail = shop_config:getNodeWithKey(tostring(config_id))
            local dir_type = shop_detail:getNodeWithKey("dirt_sort"):toInt()
            self.dir_type[i] = dir_type
            local value = shop_detail:getNodeWithKey("value"):toInt()
            if dir_type == 1 then
                self.m_dir_type_table[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_2.png"));
            else
                self.m_dir_type_table[i]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chen_1.png"));
            end
            self.m_hero_price_table[i]:setString(tostring(value))
            self.price_talble[i] = value
            --name
            -- local character_id = shop_detail:getNodeWithKey("item"):toInt()
            local character_id = shop_detail:getNodeWithKey("item"):getNodeAt(0);
            -- local character_detail = character_config:getNodeWithKey(tostring(character_id))
            --头像
            -- if character_detail then
                -- local img_url = character_detail:getNodeWithKey("img")
                -- local hero_icon = get_hero_big_img(character_detail)
                local hero_icon,name,count = game_util:getRewardByItem(character_id,false);
                
                if  self.m_icon_table[i] ~= nil and hero_icon then
                    self.m_icon_table[i]:removeAllChildrenWithCleanup(true)
                    self.m_icon_table[i]:addChild(hero_icon)
                end
                if  self.m_hero_name_table[i] ~= nil and name then
                    self.m_hero_name_table[i]:removeAllChildrenWithCleanup(true)
                    -- self.m_hero_name_table[i]:setString(name.."(" .. count .. ")")
                    self.m_hero_name_table[i]:setString(name)
                    if count > 1 then
                        self.hero_count_label[i]:setString("×" .. count)
                    else
                        self.hero_count_label[i]:setString("")
                    end
                end

                local rewardType = character_id:getNodeAt(0):toInt();
                if rewardType == 5 then
                    local cardId = character_id:getNodeAt(1):toInt();
                    local character_detail = character_config:getNodeWithKey(tostring(cardId))
                    local quality = character_detail:getNodeWithKey("quality"):toInt();
                    if quality > 3 then
                        self.equipment_tag[i]:setVisible(true) 
                    end  
                end  
                if rewardType == 6 then
                    local itemId = character_id:getNodeAt(1):toStr();
                    local itemCfg = getConfig(game_config_field.item);
                    local tempItemCfg = itemCfg:getNodeWithKey(itemId);
                    local quality = tempItemCfg:getNodeWithKey("quality"):toInt();
                    if quality > 3 then
                        self.equipment_tag[i]:setVisible(true) 
                    end     
                end
            -- end
            if is_buy_enabled == 0 then
                self.m_btn_table[i]:setEnabled(true)
            else
                self.m_btn_table[i]:setTitleForState(CCString:create(tostring(string_helper.game_split_shop.buyed)),CCControlStateDisabled)
                self.m_btn_table[i]:setEnabled(false)
                --设置可见
                self.black_bg_sellout[i]:setVisible(true)
                self.black_bg[i]:setVisible(true)
            end       
            -- if self.box_flag == true then
            --     game_util:closeAlertView();
            --     self.box_flag = false
            -- end
        end
        self.m_silver_dir_label:setString(game_data:getUserStatusDataByKey("dirt_silver"))
        self.m_gold_dir_label:setString(game_data:getUserStatusDataByKey("dirt_gold"))
        --倒计时回调函数
        local function timeEndFunc(label,type)
            --倒计时到了调进入尘商店接口
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")
        end
        --取时间去倒计时
        local time_need = data:getNodeWithKey("expire"):toInt()
        self.m_time_label:setString("")
        local countdownLabel = game_util:createCountdownLabel(0,timeEndFunc,8);
        -- self.m_time_label = game_util:createCountdownLabel(0,timeEndFunc,8);
        countdownLabel:setPosition(ccp(countdownLabel:getContentSize().width*0.5,self.m_time_label:getContentSize().height*0.5))
        if self.m_time_label ~= nil then
            self.m_time_label:removeAllChildrenWithCleanup(true)
        end
        self.m_time_label:addChild(countdownLabel)
        countdownLabel:setTime(time_need);
        -- countdownLabel:setTime(10);
        local card_count = data:getNodeWithKey("refresh_card"):toInt()
        -- self.m_card_count_label:setString(tostring(card_count))

        local node_botton_info_board = ccbNode:nodeForName("node_botton_info_board")
        node_botton_info_board:removeAllChildrenWithCleanup( true )

        local addYellowColor = function ( text )
            return "[color=ffeeba00]" .. tostring(text) .. "[/color]"
        end
        local format = tostring(string_helper.ccb.text91)
        local msg = string.format( format, addYellowColor( string_helper.ccb.text92 ), addYellowColor( string_helper.ccb.text93 ), addYellowColor(card_count) )
        local richLabel = game_util:createRichLabelTTF({text = msg,textAlignment = kCCTextAlignmentCenter,
        verticalTextAlignment = kCCVerticalTextAlignmentCenter,color = ccc3(221,221,192),fontSize = 10})
        node_botton_info_board:addChild( richLabel )


    end
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 201 then--返回
            self:back()
        elseif btnTag == 200 then--刷新
            local function refreshTime()
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_refresh_dirt_shop"), http_request_method.GET, nil,"cards_refresh_dirt_shop")
                for i=1,8 do
                    self.black_bg_sellout[i]:setVisible(false)
                    self.black_bg[i]:setVisible(false)
                    self.equipment_tag[i]:setVisible(false) 
                end
            end
            refreshTime()
        elseif btnTag > 100 and btnTag < 110 then--8个购买按钮
            local index = btnTag - 100
            local shop_id = self.m_shop_id_table[index]
            local params = {};
            params.shop_id = shop_id
            if self.dir_type[index] == 1 then
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_dirt_shop_buy"), http_request_method.GET, params,"cards_dirt_shop_buy")
            else
                -- local payValue = self.price_talble[index]
                -- local t_params = 
                -- {
                --     title = string_config.m_title_prompt,
                    -- okBtnCallBack = function(target,event)
                        self.box_flag = true
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_dirt_shop_buy"), http_request_method.GET, params,"cards_dirt_shop_buy")
                    -- end   --可缺省
                --     okBtnText = string_config.m_btn_sure,       --可缺省
                --     cancelBtnText = string_config.m_btn_cancel,
                --     text = "确定花费" .. payValue .. "超能之尘兑换？",      --可缺省
                --     onlyOneBtn = false,
                --     touchPriority = GLOBAL_TOUCH_PRIORITY-20,
                -- }
                -- game_util:openAlertView(t_params)
            end
        elseif btnTag > 500 and btnTag < 510 then--查看英雄
            local index = btnTag - 500
            cclog(index)
            local shop_id = self.m_shop_id_table[index]
            local shop_config = getConfig(game_config_field.dirt_shop)
            local shop_detail = shop_config:getNodeWithKey(tostring(shop_id))
            local character_id = shop_detail:getNodeWithKey("item"):getNodeAt(0);
            local shop_type = character_id:getNodeAt(0):toInt()
            local function callBack(typeName)

            end
            game_util:lookItemDetal(json.decode(character_id:getFormatBuffer()))
            cclog("character_id:getFormatBuffer() = " .. character_id:getFormatBuffer())
            -- if shop_type == 5 then 
            --     local hero_cid = character_id:getNodeAt(1):toStr()
            --     game_scene:addPop("game_hero_info_pop",{cId = tostring(hero_cid),openType = 4})
            --     -- game_scene:addPop("game_hero_info_pop",{tGameData = game_data:getCardDataById(tostring(hero_id)),openType=1,callBack = callBack})
            -- elseif shop_type == 6 then
            --     local itemCfg = getConfig(game_config_field.item)
            --     local exchageCfg = getConfig(game_config_field.exchange)
            --     local itemId = character_id:getNodeAt(1):toStr()
            --     cclog("itemId == " .. itemId)
            --     local sortId = itemCfg:getNodeWithKey(itemId):getNodeWithKey("sort"):toStr()
            --     local changeId = exchageCfg:getNodeWithKey(sortId):getNodeWithKey("change_id"):getNodeAt(0):getNodeAt(1):toStr()
            --     cclog("changeId == " .. changeId)  
            --     -- local hero_cid = character_config:getNodeWithKey(changeId):getNodeWithKey
            --     game_scene:addPop("game_hero_info_pop",{cId = tostring(changeId),openType = 4})
            -- end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_card_split_shop.ccbi");
    self.m_time_label = ccbNode:labelTTFForName("time_label");
    self.m_card_count_label = ccbNode:labelTTFForName("card_count_label");
    self.m_silver_dir_label = ccbNode:labelBMFontForName("silver_dir_label");
    self.m_gold_dir_label = ccbNode:labelBMFontForName("gold_dir_label");
    self.m_hero_price_table = {}
    self.m_hero_name_table = {}
    self.m_dir_type_table = {}
    self.m_icon_table = {}
    self.m_btn_table = {}
    --add
    self.black_bg = {}
    self.black_bg_sellout = {}
    self.equipment_tag={}
    self.look_hero_btn = {}
    self.hero_count_label = {}
    for i=1,8 do
        self.m_hero_price_table[i] = ccbNode:labelBMFontForName("hero_price_label"..i)
        self.m_hero_name_table[i] = ccbNode:labelTTFForName("hero_name_label"..i)
        self.m_dir_type_table[i] = ccbNode:spriteForName("dir_type_sprite_"..i)
        self.m_icon_table[i] = ccbNode:nodeForName("icon_node_"..i)
        self.m_btn_table[i] = ccbNode:controlButtonForName("buy_btn_"..i)
         ----add 加入一层使画面变暗
        self.black_bg[i] = ccbNode:layerColorForName("black_bg_"..i)
        self.black_bg_sellout[i] = ccbNode:spriteForName("black_bg_sellout_"..i)
        self.equipment_tag[i] = ccbNode:spriteForName("equipment_tag_"..i)
        -- game_util:setControlButtonTitleBMFont(self.m_btn_table[i])
        self.look_hero_btn[i] = ccbNode:controlButtonForName("btn_select_" .. i)
        self.look_hero_btn[i]:setOpacity(0)
        self.hero_count_label[i] = ccbNode:labelBMFontForName("hero_count_label" .. i)

        game_util:setCCControlButtonTitle(self.m_btn_table[i],string_helper.ccb.text90)
    end
    self.m_silver_dir_label:setString(game_data:getUserStatusDataByKey("dirt_silver"))
    self.m_gold_dir_label:setString(game_data:getUserStatusDataByKey("dirt_gold"))
    
    --联网取数据
    local function load_ui()
        -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")
        responseMethod("cards_open_dirt_shop",self.m_gameData)
    end
    load_ui()
    local function animCallFunc(animName)
        ccbNode:runAnimations("Default Timeline")
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations("Default Timeline")

    -- local text1 = ccbNode:labelTTFForName("text1")
    -- text1:setString(string_helper.ccb.text91)
    -- local text2 = ccbNode:labelTTFForName("text2")
    -- text2:setString(string_helper.ccb.text92)
    -- local text3 = ccbNode:labelTTFForName("text3")
    -- text3:setString(string_helper.ccb.text93)

   

    return ccbNode;
end
--[[--
    刷新ui
]]
function game_split_shop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_split_shop.init(self,t_params)
    t_params = t_params or {};
    self.m_openType = t_params.openType or "";
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_gameData = util_json:new(t_params.gameData:getFormatBuffer());--json.decode(t_params.gameData:getFormatBuffer()) or {};
    end
    self.box_flag = false
end

--[[--
    创建ui入口并初始化数据
]]
function game_split_shop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_split_shop;