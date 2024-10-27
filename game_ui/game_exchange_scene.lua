--game exchange scene  兑换

local game_exchange_scene = {
    m_popUi = nil,
    m_root_layer = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_title_label = nil,
    m_list_view_bg = nil,
    m_curPage = nil,
    m_exchangeData = nil,
    m_openType = nil,
    m_guildNode = nil,
    m_ccbNode = nil,
    m_itemActionFlag = nil,
    icon_sprite = nil,
    m_fromUi = nil,
};

local menuTab = {{title = "兑换",type=1},{title = "查看",type=1}}

--[[--
    销毁
]]
function game_exchange_scene.destroy(self)
    -- body
    cclog("-----------------game_exchange_scene destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_title_label = nil;
    self.m_list_view_bg = nil;
    self.m_curPage = nil;
    self.m_exchangeData = nil;
    self.m_openType = nil;
    self.m_guildNode = nil;
    self.m_ccbNode = nil;
    self.m_itemActionFlag = nil;
    self.icon_sprite = nil;
    self.m_fromUi = nil;
end
--[[--
    返回
]]
function game_exchange_scene.back(self,type)
    if self.m_fromUi == "map_world_scene" then
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    else
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_exchange_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 11 or btnTag == 12 then
            self:refreshSortTabBtn(btnTag - 10);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_exchange_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn");
    -- self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn");
    -- self.m_title_label = ccbNode:labelBMFontForName("m_title_label");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg");
    -- game_util:setCCControlButtonBackground(self.m_back_btn,"public_backNormal2.png","public_backDown2.png","public_backDown2.png");
    -- self.m_sort_btn:setVisible(false);
    -- if self.m_openType == 1 then
    --     self.m_title_label:setString("伙伴碎片")
    -- else
    --     self.m_title_label:setString("装备碎片")
    -- end
    -- self.m_title_label:setString("碎片兑换")
    self.m_ccbNode = ccbNode
    local text = {string_helper.ccb.text164,string_helper.ccb.text165}
    for i=1,2 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        game_util:setControlButtonTitleBMFont(tempBtn);
        game_util:setCCControlButtonTitle(tempBtn,text[i])
    end
    return ccbNode;
end

--[[--

]]
function game_exchange_scene.refreshSortTabBtn(self,sortIndex)
    self.m_openType = sortIndex
    for i=1,2 do
        local tempBtn = self.m_ccbNode:controlButtonForName("m_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_openType == i);
        tempBtn:setEnabled(self.m_openType ~= i);
    end
    self:refreshTab1();
end

--[[--
    归类兑换种类
]]
function game_exchange_scene.backData(self,gameData)
        self.m_exchangeData = {init = true,data = {},data2 = {}}

        local exchange_cfg = getConfig(game_config_field.exchange);
        local card_cfg = getConfig(game_config_field.character_detail);
        local equip_cfg = getConfig(game_config_field.equip);
        local item_cfg = getConfig(game_config_field.item);

        self.m_exchange_data = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer()) or {};
        game_util:rewardTipsByDataTable(self.m_exchange_data.reward);
        local items = self.m_exchange_data.items or {};

        local cfgCount = exchange_cfg:getNodeCount();
        local key,exchSort,need_item_id,ownCount,needCount = nil,nil,nil,nil,nil;
        local change_id,itemCfg,itemName,item_item_cfg,quality = nil,nil,nil,nil,nil;
        for i=1,cfgCount do
            ownCount = 0;
            local tempExch = exchange_cfg:getNodeAt(i-1);
            key = tempExch:getKey();
            exchSort = tempExch:getNodeWithKey("change_sort"):toInt();
            need_item_id = tempExch:getNodeWithKey("need_item"):toInt();
            if items[tostring(need_item_id)] then
                for k,v in pairs(items[tostring(need_item_id)]) do
                    ownCount = ownCount + v;
                end
            end
            if ownCount > 0 then
            -- 所需道具数量
                needCount = 0;
                local need_num = tempExch:getNodeWithKey("need_num")
                local need_num_count = need_num:getNodeCount();
                if need_num_count > 0 then
                    local tempTimes = self.m_exchange_data.exchange_log[key]
                    if(tempTimes~=nil)then
                        needCount = need_num:getNodeAt(math.min(tempTimes,need_num_count-1)):toInt();
                    else
                        needCount = need_num:getNodeAt(0):toInt();
                    end
                end
                change_id = tempExch:getNodeWithKey("change_id")
                if change_id:getNodeCount() > 0 then
                    local tempItem = change_id:getNodeAt(0)
                    change_id = tempItem:getNodeAt(1):toInt();
                end
                item_item_cfg = item_cfg:getNodeWithKey(tostring(tempExch:getNodeWithKey("need_item"):toInt()));
                itemName = item_item_cfg:getNodeWithKey("name"):toStr();
                cclog("key ====" .. key .. " ; exchSort =======" .. exchSort .. " ; need_item_id ====" .. need_item_id .. " ; ownCount ==" .. ownCount)
                local exchangeFlag = (ownCount >= needCount)
                if(exchSort == 1) then--卡牌   and self.m_openType == 1 
                    itemCfg = card_cfg:getNodeWithKey(tostring(change_id));
                    local quality = itemCfg:getNodeWithKey("quality"):toInt()
                    self.m_exchangeData.data[#self.m_exchangeData.data+1] = {key = key,count = ownCount,needCount = needCount,itemCfg = itemCfg,itemName = itemName,item_item_cfg=item_item_cfg,change_sort = exchSort,exchangeFlag = exchangeFlag, need_item_id = need_item_id,quality = quality}
                    game_data.m_texchangedCardEquip[tostring(need_item_id)] = exchangeFlag or nil  -- 记录已经提醒的可兑换卡片
                elseif(exchSort == 2)then--装备    and self.m_openType == 2 
                    itemCfg = equip_cfg:getNodeWithKey(tostring(change_id));
                    local quality = itemCfg:getNodeWithKey("quality"):toInt()
                    self.m_exchangeData.data2[#self.m_exchangeData.data2+1] = {key = key,count = ownCount,needCount = needCount,itemCfg = itemCfg,itemName = itemName,item_item_cfg=item_item_cfg,change_sort = exchSort,exchangeFlag = exchangeFlag, need_item_id = need_item_id,quality = quality}
                	game_data.m_texchangedCardEquip[tostring(need_item_id)] = exchangeFlag or nil -- 记录已经提醒的可兑换装备
                elseif(exchSort == 3)then--道具
                    -- itemCfg = item_cfg:getNodeWithKey(tostring(change_id));
                else
                    -- itemCfg = nil;
                end
            end
        end
    local function sortFunc(itemOne,itemTwo)
        local id1 = itemOne.item_item_cfg:getKey()
        local id2 = itemTwo.item_item_cfg:getKey()
        local quality1 = itemOne.quality
        local quality2 = itemTwo.quality
        if itemOne.exchangeFlag == true and itemTwo.exchangeFlag == false then
            return true;
        elseif itemOne.exchangeFlag == false and itemTwo.exchangeFlag == true then
            return false;
        else
            if id1 == "1038" then
                return true
            elseif id2 == "1038" then
                return false
            else
                if quality1 == quality2 then
                    return id1 > id2;
                else
                    return quality1 > quality2
                end
            end
        end
    end
    -- cclog("self.m_exchangeData.data == " .. json.encode(self.m_exchangeData.data))
    table.sort(self.m_exchangeData.data,sortFunc)
    table.sort(self.m_exchangeData.data2,sortFunc)
end

--[[--

]]
function game_exchange_scene.removePop(self)
    if self.m_popUi then
        self.m_popUi:removeFromParentAndCleanup(true);
        self.m_popUi = nil;
    end
end

--[[--

]]
function game_exchange_scene.onSureFunc(self,index)
    local itemData = nil;
    if self.m_openType == 1 then
        itemData = self.m_exchangeData.data[index+1];
    elseif self.m_openType == 2 then
        itemData = self.m_exchangeData.data2[index+1];
    end
    local name = "";
    if itemData and itemData.itemCfg then
        name = itemData.itemCfg:getNodeWithKey("name"):toStr();
    else
        itemData = nil;
    end
    if itemData == nil then
        game_util:addMoveTips({text = string_helper.game_exchange_scene.data_error});
        return;
    end
    if itemData.needCount > itemData.count then
        game_util:addMoveTips({text = string_helper.game_exchange_scene.chip_no});
        return;
    end
    local function sendRequest()
        local function responseMethod(tag,gameData)
            self:backData(gameData);
            self:refreshTab1();
            game_guide_controller:gameGuide("send","5",503);
            local allAlertsData = game_data:getAllAlertsData() or {}
            allAlertsData.exchange_card = "";
            -- game_util:addMoveTips({text = "兑换成功!"});
        end
        local params = {};
        params.change_id = itemData.key
        print("need_item_id  ==  ", itemData.need_item_id )
        game_data.m_texchangedCardEquip[tostring(itemData.need_item_id)] = nil
        --碎片弹出框  change_id = 
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_exchange"), http_request_method.GET, params,"item_exchange");
    end

    local exchange_cfg = getConfig(game_config_field.exchange);
    local exc_item_cfg = exchange_cfg:getNodeWithKey(itemData.key);
    local need_food = exc_item_cfg:getNodeWithKey("need_food"):toInt();
    local need_metal = exc_item_cfg:getNodeWithKey("need_metal"):toInt()

    local totalFood = game_data:getUserStatusDataByKey("food") or 0
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0

    local game_pop_up_box = require("game_ui.game_pop_up_box")
    if self.m_openType == 1 then
        if need_food > totalFood then
            --换成统一的提示
            local t_params = 
            {
                m_openType = 5,
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        else
            local text = string_helper.game_exchange_scene.expend_not .. itemData.needCount .. string_helper.game_exchange_scene.ge .. itemData.itemName .. string_helper.game_exchange_scene.he .. need_food .. string_helper.game_exchange_scene.food_exchange .. name .. "?";
            local t_params = 
            {
                title = string_helper.game_exchange_scene.exchange,
                okBtnCallBack = function(target,event)
                    self:removePop();
                    sendRequest();
                end,   --可缺省
                closeCallBack = function(target,event)
                    self:removePop();
                end,
                okBtnText = string_helper.game_exchange_scene.sure_exchange,       --可缺省
                text = text,      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            self.m_popUi = game_pop_up_box.create(t_params)
            game_scene:getPopContainer():addChild(self.m_popUi);
        end
    else
        if need_metal > totalMetal then
            --换成统一的提示
            local t_params = 
            {
                m_openType = 6,
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        else
            local text = string_helper.game_exchange_scene.expend_not .. itemData.needCount .. string_helper.game_exchange_scene.ge .. itemData.itemName .. string_helper.game_exchange_scene.he .. need_metal .. string_helper.game_exchange_scene.metal_exchange .. name .. "?";
            local t_params = 
            {
                title = string_helper.game_exchange_scene.exchange,
                okBtnCallBack = function(target,event)
                    self:removePop();
                    sendRequest();
                end,   --可缺省
                closeCallBack = function(target,event)
                    self:removePop();
                end,
                okBtnText = string_helper.game_exchange_scene.sure_exchange,       --可缺省
                text = text,      --可缺省
                touchPriority = GLOBAL_TOUCH_PRIORITY-2,
            }
            self.m_popUi = game_pop_up_box.create(t_params)
            game_scene:getPopContainer():addChild(self.m_popUi);
        end
    end

    local id = game_guide_controller:getIdByTeam("5");
    if id == 502 then
        game_guide_controller:gameGuide("show","5",503,{tempNode = game_pop_up_box.m_ok_btn})
    end
end

--[[
    和道具一样，显示查看还是批量兑换    
]]
function game_exchange_scene.showCardIcon(self,index)
    local function callBackFunc()
        self:refreshUi();
    end
    local itemData = nil;
    if self.m_openType == 1 then
        itemData = self.m_exchangeData.data[index+1];
    elseif self.m_openType == 2 then
        itemData = self.m_exchangeData.data2[index+1];
    end
    local change_sort = itemData.change_sort
    local params = {
        callBackFunc = callBackFunc,
        itemData = itemData,
        change_sort = change_sort,
        openType = self.m_openType,
    }
    game_scene:addPop("game_item_card_pieces_pop",params)
end

--[[--
    查看碎片合成后的卡牌信息
]]
function game_exchange_scene.onLookFunc(self,index)
    local itemData = nil;
    if self.m_openType == 1 then
        itemData = self.m_exchangeData.data[index+1];
    elseif self.m_openType == 2 then
        itemData = self.m_exchangeData.data2[index+1];
    end
    if itemData == nil then
        game_util:addMoveTips({text = string_helper.game_exchange_scene.data_error});
        return;
    end
    cclog("itemData == " .. itemData.change_sort)
    local change_sort = itemData.change_sort;
    local cId = itemData.itemCfg:getKey();
    cclog("cId == " .. cId)
    if change_sort == 1 then
        game_scene:addPop("game_hero_info_pop",{cId = cId,openType = 4})
    elseif change_sort == 2 then
        local equipData = {lv = 1,c_id = cId,id = -1,pos = -1}
        game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
    elseif change_sort == 3 then
        
    end
end

--[[--

]]
function game_exchange_scene.refreshTab1(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local id = game_guide_controller:getIdByTeam("5");
    if id == 502 then
        self.m_itemActionFlag = false;
    end
    local tempTableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
    
    if id == 502 then -- 碎片兑换
        tempTableView:setTouchEnabled(false);
        self:gameGuide("drama","5",502);
    elseif id == 503 then
        game_guide_controller:gameGuide("send","5",505);
        game_guide_controller:gameGuide("show","5",505,{tempNode = self.m_back_btn})
    end
end

-- 兑换
function game_exchange_scene:createTableView( viewSize )
    local showData = {}
    if self.m_openType == 1 then
        showData = self.m_exchangeData.data;
    elseif self.m_openType == 2 then
        showData = self.m_exchangeData.data2;
    end
    local selIndex = nil;
    local function menuPopCallFunc(tag)
        cclog("menuPopCallFunc ============= tag = " .. tag .. " ; selIndex = " .. selIndex)
        if tag == 1 then -- 兑换
            self:onSureFunc(selIndex);
        elseif tag == 2 then --查看
            self:onLookFunc(selIndex);
        end
        game_scene:removePopByName("game_menu_pop");
    end

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target,"CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag = " .. btnTag)
        local index = btnTag - 101;
        self:onSureFunc(index);
    end
    local exchange_cfg = getConfig(game_config_field.exchange);
    local itemsCount = #showData;
    local totalItem = math.max(itemsCount%8 == 0 and itemsCount or math.floor(itemsCount/8+1)*8,8)
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 4; --列
    params.totalItem = totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+2;
    params.showPageIndex = self.m_curPage;
    params.itemActionFlag = self.m_itemActionFlag;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_exchange_item.ccbi");
            local m_btn = ccbNode:controlButtonForName("m_button")
            m_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY+1);
            game_util:setControlButtonTitleBMFont(m_btn)
            cell:addChild(ccbNode,10,10);
        end
        if cell~=nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:spriteForName("m_spr_bg_up");
            local m_button = ccbNode:controlButtonForName("m_button")
            game_util:setCCControlButtonTitle(m_button,string_helper.ccb.text163)
            if index < itemsCount then
                m_spr_bg_up:setVisible(false);
                local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");   -- 图标位置
                m_anim_node:removeAllChildrenWithCleanup(true);
                local m_name = tolua.cast(ccbNode:objectForName("m_name"),"CCLabelTTF");
                local m_item_count = tolua.cast(ccbNode:objectForName("m_item_count"),"CCLabelTTF");
                local m_spr_bg = tolua.cast(ccbNode:objectForName("m_spr_bg"),"CCSprite");
                local m_cost_food_label = ccbNode:labelBMFontForName("m_cost_food_label")
                local tempData = showData[index+1];
                cclog("-------------------------------------- 1  " .. tostring(index) .. "  " .. tostring(tempData.key));
                local exc_item_cfg = exchange_cfg:getNodeWithKey(tempData.key);
                local item_sort = exc_item_cfg:getNodeWithKey("change_sort"):toInt();
                local need_food = exc_item_cfg:getNodeWithKey("need_food"):toInt()
                local need_metal = exc_item_cfg:getNodeWithKey("need_metal"):toInt()
                if self.m_openType == 1 then--兑换卡牌
                    m_cost_food_label:setString(tostring(need_food));
                else--兑换装备
                    m_cost_food_label:setString(tostring(need_metal));
                end
                local shade = exc_item_cfg:getNodeWithKey("shade"):toStr();
                if tempData.itemCfg then
                    m_name:setString(tempData.itemCfg:getNodeWithKey("name"):toStr());
                end
                local item_item_cfg = tempData.item_item_cfg;
                if item_item_cfg then
                    local sprite = game_util:createItemIconByCfg(item_item_cfg)
                    if(sprite~=nil)then
                        m_anim_node:addChild(sprite);
                    end
                end
                -- 所需道具数量
                local add_numAll = tempData.needCount
                local item_name = tempData.itemName;
                -- 已有道具数量
                local has_numAll = tempData.count;
                m_item_count:setString(item_name .. " " .. tostring(has_numAll) .. "/" .. tostring(add_numAll));
                if has_numAll >= add_numAll then
                    game_util:addTipsAnimByType(m_anim_node,2);
                    if self.m_guildNode == nil then
                        local item_id = item_item_cfg:getKey()
                        local totalFood = game_data:getUserStatusDataByKey("food") or 0
                        if item_id == "1038" and totalFood >= need_food then
                            self.m_guildNode = ccbNode:controlButtonForName("m_button");
                        end
                    end
                end
                local icon_sprite = ccbNode:spriteForName("icon_sprite")
                if self.m_openType == 1 then
                    icon_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_food.png"))
                elseif self.m_openType == 2 then
                    icon_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_icon_metal.png"))
                end
                m_button:setVisible(true)
                m_button:setTag(101 + index)
            else
                m_button:setVisible(false)
                m_spr_bg_up:setVisible(true);
            end
        else
            cclog("---------------new table cell have error ----" .. tostring(index));
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            -- local px,py = cell:getPosition();
            -- local pos = cell:getParent():convertToWorldSpace(ccp(px+itemSize.width*0.5,py+itemSize.height*0.5));
            -- cclog("pos x ,y = " .. pos.x .. " ; " .. pos.y);
            selIndex = index;
            -- game_scene:addPop("game_menu_pop",{menuTab = menuTab,pos = pos,callFunc = menuPopCallFunc});
            -- self:onLookFunc(selIndex);
            self:showCardIcon(selIndex)
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
function game_exchange_scene.refreshUi(self)
    self:refreshSortTabBtn(self.m_openType);
end

--[[--
    初始化
]]
function game_exchange_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_openType = t_params.openType or 1;
    self.m_exchangeData = {init = false,data = {},data2 = {}}
    self:backData(t_params.gameData);
    self.m_itemActionFlag = true;
    self.m_fromUi = t_params.fromUi or "";
end

--[[--
    创建ui入口并初始化数据
]]
function game_exchange_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end


--[[
    新手引导
]]
function game_exchange_scene.gameGuide(self,guideType,guide_team,guide_id,t_params)
    if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "drama" then
        if guide_team == "5" and id == 502 then
            local function endCallFunc()
                if self.m_guildNode then
                    game_guide_controller:gameGuide("show","5",502,{tempNode = self.m_guildNode})
                else
                    game_guide_controller:gameGuide("send","5",505);
                end
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        elseif guide_team == "5" and id == 307 then
            local function endCallFunc()
                game_guide_controller:gameGuide("send","5",307);
            end
            t_params.guideType = "drama";
            t_params.endCallFunc = endCallFunc;
            game_guide_controller:showGuide(guide_team,guide_id,t_params)
        end
    end
end


return game_exchange_scene;