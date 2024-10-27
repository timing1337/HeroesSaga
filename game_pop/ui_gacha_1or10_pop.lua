--- 金字塔战胜提示  秒杀

local ui_gacha_1or10_pop = {
    m_gameData = nil,
    m_list_view_bg = nil,

    m_curPage = nil,
    pro_node = nil,
    smore_num_label = nil,

};

--[[--
    销毁ui
]]
function ui_gacha_1or10_pop.destroy(self)
    -- body
    cclog("-----------------ui_gacha_1or10_pop destroy-----------------");
    self.m_gameData = nil;
    self.m_list_view_bg = nil;
    self.m_curPage = nil;
    self.pro_node = nil;
    self.smore_num_label = nil;

end
--[[--
    返回
]]
function ui_gacha_1or10_pop.back(self,backType)
    game_scene:removePopByName("ui_gacha_1or10_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_gacha_1or10_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gacha_1or10card_pop.ccbi");
    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")



    self.pro_node = ccbNode:nodeForName("pro_node")
    self.more_num_label = ccbNode:labelBMFontForName("more_num_label")

   


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);

    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    return ccbNode;
end


--[[--
    创建列表
]]
function ui_gacha_1or10_pop.createTableView(self,viewSize)
    local gachaCfg = getConfig(game_config_field.gacha);
    local function timeEndFunc(label,type)
    end
    local column = 2;
    if #self.m_gameData >= 2 then
        column = 2;
    else 
        column = #self.m_gameData
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
    params.totalItem = #self.m_gameData;
    params.showPageIndex = self.m_curPage;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY - 10;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index)
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onCellButtonClick);
            ccbNode:openCCBFile("ccb/ui_game_gacha_card_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            -- local itemData = self.m_gacha_table[index+1];
            local itemData = self.m_gameData[index + 1 ]
            local itemCfg = itemData.itemCfg;
            if ccbNode then
                local m_bg_spr = ccbNode:spriteForName("m_bg_spr");
                local m_cost_label = ccbNode:labelTTFForName("m_cost_label")
                local m_tips_spr = ccbNode:spriteForName("m_tips_spr");
                local m_cost_node = ccbNode:nodeForName("m_cost_node");
                local m_free_time_bg = ccbNode:nodeForName("m_free_time_bg");
                local m_free_time_node = ccbNode:nodeForName("m_free_time_node");
                local m_cost_node_2 = ccbNode:nodeForName("m_cost_node_2");
                local m_free_label = ccbNode:labelTTFForName("m_free_label");

                local m_spr_buytimes_orign_tip = ccbNode:spriteForName("m_spr_buytimes_orign_tip")
                m_spr_buytimes_orign_tip:setVisible(false)

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
                if self.m_allData.guild_reward_sort == 0 then
                    gvg_node:setVisible(false)
                elseif self.m_allData.guild_reward_sort == 1 then
                    gvg_node:setVisible(true)
                    m_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.9))
                    m_gvg_cost_label:setString(itemCfg:getNodeWithKey("value"):toStr())
                elseif self.m_allData.guild_reward_sort == 2 then
                    gvg_node:setVisible(true)
                    m_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.95))
                    m_gvg_cost_label:setString(itemCfg:getNodeWithKey("value"):toStr())
                elseif self.m_allData.guild_reward_sort == 3 then
                    gvg_node:setVisible(true)
                    m_cost_label:setString("×" .. (itemCfg:getNodeWithKey("value"):toInt()*0.9))
                    m_gvg_cost_label:setString(itemCfg:getNodeWithKey("value"):toStr())
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

                local image = itemCfg:getNodeWithKey("image"):toStr();
                image = game_util:getResName(image);
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(image .. ".png")
                if spriteFrame then
                    m_bg_spr:setDisplayFrame(spriteFrame);
                end

                -- 几连抽
                local get_num = itemCfg:getNodeWithKey("get_num"):toInt()
                if get_num == 10 then
                    m_spr_buytimes_orign_tip:setVisible(true)
                end
                local m_spr_buytimes_tip = ccbNode:spriteForName("m_spr_buytimes_tip")
                local tips_names = { buy1 = "ui_gacha_1or10_buy1.png", buy10 = "ui_gacha_1or10_buy10.png"}
                local tip_name = tips_names["buy" .. tostring(get_num)] or ""
                -- cclog2(m_spr_buytimes_tip, "m_spr_buytimes_tip   =====   ")
                -- cclog2(tip_name, "tip_name   =====   ")
                if m_spr_buytimes_tip then
                    local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( tip_name )
                    if tempFrame then
                        m_spr_buytimes_tip:setDisplayFrame(tempFrame)
                    end
                end



                local m_limit_node = ccbNode:nodeForName("m_limit_node");
                local m_count_str_label = ccbNode:labelTTFForName("m_count_str_label");
                local m_count_label = ccbNode:labelTTFForName("m_count_label");
                local m_time_str_label = ccbNode:labelTTFForName("m_time_str_label");
                local m_time_node = ccbNode:labelTTFForName("m_time_node");


                local freetimes = self.m_allData.m_gacha_freetimes_tab[itemCfg:getKey()]
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
                        local coutdown = function( time )
                            time = time or 0
                            local timeText = ""
                            local hour = math.floor(time/3600)
                            if hour > 0 then timeText = timeText .. hour .. " : " end
                            if hour == 0 then timeText = timeText .. "00 : " end
                            local m = math.floor(math.floor(time%3600)/ 60)
                            -- if m >0 then timeText = timeText .. string.format("%2d",m) .. ":" end
                            local s = math.floor(time % 60)
                            -- timeText = timeText .. string.format("%2d",s) .. "  "
                            timeText = timeText .. string.format("%02d ", m, s)
                            tempLabel:setString(timeText or "")
                        end

                        local time = freetimes - (os.time() - self.m_allData.m_enterUiTime)
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
                            local time = freetimes - (os.time() - self.m_allData.m_enterUiTime)
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
                        -- local tempLabel = game_util:createLabelTTF({text = "后免费",color = ccc3(0,250,0),fontSize = 10});
                        -- tempLabel:setPosition(ccp(75,10));
                        -- m_free_time_node:addChild(tempLabel);
                        -- m_free_label:setVisible(false);
                    end
                else
                    m_free_time_bg:setVisible(false);
                    m_free_label:setVisible(false);
                    -- m_cost_node_2:setVisible(true);
                    if itemData.num == 0 then -- 
                        local expire = self.m_allData.m_gacha_expire_tab[itemCfg:getKey()]
                        if expire and expire > 0 then
                            m_limit_node:setVisible(true);
                            m_time_str_label:setVisible(true);
                            m_time_node:setVisible(true);
                            m_time_node:removeAllChildrenWithCleanup(true);
                            local countdownLabel = game_util:createCountdownLabel(expire - (os.time() - self.m_allData.m_enterUiTime),timeEndFunc,8);
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
                local btn = ccbNode:controlButtonForName("m_back_btn")  -- 设置cell btn tag
                if btn then
                    btn:setVisible(false)
                    btn:setTag( index + 4)
                    btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 10)
                end

                --  新手引导提示时隐藏掉叹号
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

            if type(self.m_callFun) == "function" then

                self.m_callFun(item, self.m_gameData[index + 1], function (  )
                    self:back()
                end)
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery2(params);
end


--[[--
    刷新ui
]]
function ui_gacha_1or10_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true)
    local tableView = self:createTableView(self.m_list_view_bg:getContentSize())
    self.m_list_view_bg:addChild(tableView)

     -- self.pro_node:removeAllChildrenWithCleanup(true)
    local ex_bar = self.pro_node:getChildByTag(11)
    if ex_bar then
        ex_bar:removeFromParentAndCleanup(true)
    end
    local ex_text = self.pro_node:getChildByTag(10)
    if ex_text then
        ex_text:removeFromParentAndCleanup(true)
    end
    local numCount = math.floor((200 - self.m_allData.energy_slot) / 10)
    if numCount <= 0 then
        numCount = 0
    end
    self.more_num_label:setString(numCount)
    local max_value = 200
    local now_value = self.m_allData.energy_slot

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

end
--[[--
    初始化
]]
function ui_gacha_1or10_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = t_params.gachaData or {}
    self.m_allData = t_params.gameData

    self.m_callFun = t_params.callFun
end

--[[--
    创建ui入口并初始化数据
]]
function ui_gacha_1or10_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_gacha_1or10_pop;