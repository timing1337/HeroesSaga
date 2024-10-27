---  装备分解
local ui_equip_split = {
    m_table_view = nil,
    metal_label = nil,
    xilian_label = nil,
    m_sprite_backg = nil,
    btn_duihuan = nil,
    btn_fenjie = nil,
    btn_auto_add = nil,
    metal_value = nil,
    xilian_value = nil,
    m_btn_table = nil,
    m_selEquipDataTab = nil,
    m_equipIdTable = nil,
    m_select_id_table = nil,
    m_sprite_tag = nil,
    metal_min = nil,
    metal_max = nil,
    metal_core_min = nil,
    metal_core_max = nil,
    m_node_splitbtnboard = nil,  -- 分解种类选择按钮板
    m_control_btns = nil,  -- 控制按钮
}
--[[--
    销毁ui
]]
function ui_equip_split.destroy(self)
    -- body
    cclog("-----------------ui_equip_split destroy-----------------");
    self.m_table_view = nil;
    self.metal_label = nil;
    self.xilian_label = nil;
    self.m_sprite_backg = nil;
    self.btn_duihuan = nil;
    self.btn_fenjie = nil;
    self.btn_auto_add = nil;
    self.metal_value = nil;
    self.xilian_value = nil;
    self.m_btn_table = nil;
    self.m_selEquipDataTab = nil;
    self.m_equipIdTable = nil;
    self.m_select_id_table = nil;
    self.m_sprite_tag = nil;
    self.metal_min = nil;
    self.metal_max = nil;
    self.metal_core_min = nil;
    self.metal_core_max = nil;
    self.m_node_splitbtnboard = nil;
    self.m_control_btns = nil;
end
--[[--
    返回
]]
function ui_equip_split.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function ui_equip_split.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--装备精炼
            -- game_scene:enterGameUi("game_equip_refining",{enterType = "ui_equip_split"})
            function shopOpenResponseMethod(tag,gameData)
                game_scene:enterGameUi("game_metal_shop_scene",{gameData = gameData});
            end
            network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open_metal_shop"), http_request_method.GET, {},"shop_open_metal_shop")
        elseif btnTag == 101 then--分解
            local function equip_split(card_list)
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("reward")
                    cclog("reward = " .. reward:getFormatBuffer())
                    game_util:rewardTipsByJsonData(reward);
                    local function remove_node( node )--回调隐藏，回归原位
                        node:removeFromParentAndCleanup(true)
                        self.metal_min = 0
                        self.metal_max = 0
                        self.metal_core_min = 0
                        self.metal_core_max = 0
                        self.metal_label:setString("0")
                        self.xilian_label:setString("0")
                    end
                    local function anim_call_function(sprite)
                        local anim_node = game_util:createSplitEffectAnim("animi_card_split1",1,false,remove_node,sprite)
                        local anima_size = sprite:getContentSize()
                        local pX,pY = sprite:getPosition();
                        anim_node:setAnchorPoint(ccp(0.5,0.5))
                        anim_node:setPosition(ccp(pX,pY));
                        self.m_sprite_background:addChild(anim_node,10)
                        game_sound:playUiSound("zhakai2")
                    end
                    --特效动画 animi_hero_inherit    animi_card_split
                    for i=1,#self.m_equipIdTable do
                        local equip_id = self.m_equipIdTable[i];
                        local sprite_tag = self.m_select_id_table[tostring(equip_id)];
                        local sprite = tolua.cast(self.m_sprite_background:getChildByTag(sprite_tag),"CCSprite");
                        local function callback(sprite)
                            local anim_node = game_util:createSplitEffectAnim("animi_card_split",1,false,anim_call_function,sprite)
                            local anima_size = sprite:getContentSize()
                            local pX,pY = sprite:getPosition();
                            anim_node:setAnchorPoint(ccp(0.5,0.5))
                            anim_node:setPosition(ccp(pX,pY));
                            local count = #self.m_equipIdTable
                            self.m_sprite_background:addChild(anim_node,30-(count-i))
                            game_sound:playUiSound("qian1")
                        end
                        local animArr = CCArray:create();
                        animArr:addObject(CCDelayTime:create(0.2 * (#self.m_equipIdTable-i)));
                        animArr:addObject(CCCallFuncN:create(callback));
                        local sequence = CCSequence:create(animArr);
                        sprite:runAction(sequence); 
                    end
                    self.m_select_id_table = {}
                    self.m_equipIdTable = {}
                    self:refreshUi();
                end
                local params = "";
                for i=1,#self.m_equipIdTable do
                    params = params .. "equip_id="..self.m_equipIdTable[i].."&";
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_exchange"), http_request_method.GET, params,"equip_exchange")
            end
            if #self.m_equipIdTable > 0 then
                ------精炼等级高的分解需要提示   暂时没有
                -- local userful_id = ""
                -- local tip_flag = false
                -- local tip_type = 0
                -- for i=1,#self.m_equipIdTable do
                --     local split_id = self.m_equipIdTable[i]
                    
                -- end
                equip_split()
            else
                game_util:addMoveTips({text = string_helper.ui_equip_split.text})
            end
        elseif btnTag == 102 then--自动添加
            local equipCount = #self.m_selEquipDataTab
            local autoItemData = nil
            local autoSortId = nil
            local autoQuality = nil
            local autoExchange_id = nil
            for i=1,#self.m_selEquipDataTab do
                local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - i + 1]);
                local sortId = itemCfg:getNodeWithKey("sort"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local exchange_id = itemCfg:getNodeWithKey("exchange_id") and itemCfg:getNodeWithKey("exchange_id"):toInt() or nil
                local existFlag,cardName = game_data:equipInEquipPos(sortId,itemData.id)
                if existFlag then
                else
                    local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_equipIdTable);
                    if flag and k ~= nil then
                    else
                        autoItemData = itemData
                        autoSortId = sortId 
                        autoQuality = quality
                        autoExchange_id = exchange_id 
                        break;
                    end
                end
            end
            if autoItemData then
                if #self.m_equipIdTable <= 10 then
                    self:addEquipFromById(autoItemData,autoSortId,autoQuality, autoExchange_id)
                    self:refreshUi()
                else
                    game_util:addMoveTips({text = string_helper.ui_equip_split.text2});
                end
            else
                game_util:addMoveTips({text = string_helper.ui_equip_split.text3});
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
            local typeTable = {"default","quality","lv","sort",};
            game_data:equipSortByTypeName(typeTable[index]);
            self:refreshUi();
        elseif btnTag == 1001 then--卡牌分解
            if not game_button_open:checkButtonOpen(507) then
                return;
            end
            game_scene:enterGameUi("game_card_split");
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
    ccbNode:openCCBFile("ccb/ui_equip_split.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node");
    self.metal_label = ccbNode:labelBMFontForName("metal_label");
    self.xilian_label = ccbNode:labelBMFontForName("xilian_label");

    self.m_sprite_background = ccbNode:spriteForName("sprite_background");

    self.btn_duihuan = ccbNode:controlButtonForName("btn_duihuan");
    game_util:setCCControlButtonTitle(self.btn_duihuan,string_helper.ccb.text145)
    self.btn_fenjie = ccbNode:controlButtonForName("btn_fenjie");
    game_util:setCCControlButtonTitle(self.btn_fenjie,string_helper.ccb.text146)
    self.btn_auto_add = ccbNode:controlButtonForName("btn_auto_add");
    game_util:setCCControlButtonTitle(self.btn_auto_add,string_helper.ccb.text147)

    -- game_util:setControlButtonTitleBMFont(self.btn_duihuan)
    -- game_util:setControlButtonTitleBMFont(self.btn_fenjie)
    -- game_util:setControlButtonTitleBMFont(self.btn_auto_add)
    
    self.m_back_btn = ccbNode:controlButtonForName("btn_back");
    
    self.m_btn_table = {}
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
    --将装备信息加入
    self.metal_value = 0
    self.xilian_value = 0

    self.metal_label:setString(tostring(self.metal_value))
    self.xilian_label:setString(tostring(self.xilian_value))
    -- 选择分解种类三按钮
    self.m_node_splitbtnboard = ccbNode:nodeForName("m_node_splitbtnboard")
    local m_card_split = ccbNode:controlButtonForName("m_card_split")
    local m_equip_split = ccbNode:controlButtonForName("m_equip_split")
    local m_gem_split = ccbNode:controlButtonForName("m_gem_split")
    self.m_control_btns =   {btn1 = m_card_split, btn2 = m_equip_split, btn3 = m_gem_split}

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text137)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text138)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text139)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text140)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text144)

    if game_data:isViewOpenByID( 203 ) then
        self.btn_duihuan:setVisible(true)
        self.btn_duihuan:setPosition(ccp(240,32))
        self.btn_fenjie:setPosition(ccp(325,32))
        self.btn_auto_add:setPosition(ccp(410,32))
    else
        self.btn_duihuan:setVisible(false)
        self.btn_fenjie:setPosition(ccp(265,32))
        self.btn_auto_add:setPosition(ccp(382,32))
    end
    return ccbNode;
end

local ButtonInfoTable = 
{
    btn1 = {name = string_helper.ui_equip_split.split_card, Inreview = 32, btnId = 507, openFlag = true, btnIndex = 1},
    btn2 = {name = string_helper.ui_equip_split.split_equip, Inreview = 25, btnId = 607, openFlag = true, btnIndex = 2 },
    btn3 = {name = string_helper.ui_equip_split.split_gem, Inreview = 130, btnId = 121, openFlag = true, btnIndex = 3 },
}
local TablePosX = {
    {0.5},
    {0.35, 0.65},
    {0.15, 0.5, 0.85},
}

--[[
    刷新按钮状态 分解卡牌 分解装备 分解宝石
]]
function ui_equip_split.refreshBtnStutas( self )
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
function ui_equip_split.refresh_select_list(self)
    local count = #self.m_equipIdTable
    local length = 10;
    if count <= 10 then
        length = 10;
    else
        length = 100 / count;
    end
    for i=1,#self.m_equipIdTable do
        local equip_id = self.m_equipIdTable[i];
        local sprite_tag = self.m_select_id_table[tostring(equip_id)];
        cclog("sprite_tag == " .. sprite_tag)
        local equip_node = self.m_sprite_background:getChildByTag(sprite_tag);
        local node_size = equip_node:getContentSize();
        equip_node:setPosition(ccp(node_size.width*0.5+10+(count-i)*length,node_size.height*0.5+8));
    end
end
--[[
    创建分解列表
]]--
function ui_equip_split.createTableView( self,viewSize )
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    local equipCount = #self.m_selEquipDataTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = equipCount;
    params.itemActionFlag = true;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = game_util:createEquipItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < equipCount then
                local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - index]);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                -- cclog("itemData = " .. json.encode(itemData))
                -- cclog("itemCfg == " .. itemCfg:getFormatBuffer())
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_equipIdTable);
                if flag then
                    m_sel_img:setVisible(true);
                else
                    m_sel_img:setVisible(false);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - index]);

            local flag,k = game_util:idInTableById(tostring(itemData.id),self.m_equipIdTable);
            if flag and k ~= nil then
                table.remove(self.m_equipIdTable,k);
                m_sel_img:setVisible(false);
                for key,value in pairs(self.m_select_id_table) do
                    if tostring(key) == tostring(itemData.id) then
                        if self.m_sprite_background:getChildByTag(value) ~= nil then
                            self.m_sprite_background:removeChildByTag(value,true);
                        end
                    end
                end
                local sortId = itemCfg:getNodeWithKey("sort"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local exchange_id = itemCfg:getNodeWithKey("exchange_id") and itemCfg:getNodeWithKey("exchange_id"):toInt() or nil
                self:setCostLabel(itemData,quality, exchange_id, 2)
                self:refresh_select_list();
            else
                local sortId = itemCfg:getNodeWithKey("sort"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local exchange_id = itemCfg:getNodeWithKey("exchange_id") and itemCfg:getNodeWithKey("exchange_id"):toInt() or nil
                local existFlag,cardName = game_data:equipInEquipPos(sortId,itemData.id)
                if existFlag then
                    game_util:addMoveTips({text = string_helper.ui_equip_split.text4 .. cardName .. string_helper.ui_equip_split.text5});
                else
                    if #self.m_equipIdTable <= 10 then
                        m_sel_img:setVisible(true);
                        self:addEquipFromById(itemData,sortId,quality, exchange_id)
                    else
                        game_util:addMoveTips({text = string_helper.ui_equip_split.top});
                    end
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加装备全身像
]]--
function ui_equip_split.addEquipFromById(self,itemData,sortId,quality, exchange_id)
    local existFlag,cardName = game_data:equipInEquipPos(sortId,itemData.id)
    if existFlag then

    else
        table.insert(self.m_equipIdTable,itemData.id)
        self.m_select_id_table[tostring(itemData.id)] = self.m_sprite_tag
        local equip_node = game_util:createEquipItemByCCB(itemData);
        local node_size = equip_node:getContentSize();
        self.m_sprite_background:addChild(equip_node,10,self.m_sprite_tag)
        self:refresh_select_list();
        self.m_sprite_tag = self.m_sprite_tag + 1
        self:setCostLabel(itemData,quality, exchange_id)
    end
end
--[[
    设置label 值
    exchange_id 取值  -- 根据新的 equip.exchange_id 来确定equip_exchange
]]
function ui_equip_split.setCostLabel(self,itemData,quality, exchange_id, setType)
    setType = setType or 1
    -- cclog2(exchange_id, "ui_equip_split setCostLabel exchange_id ========= ")
    exchange_id = exchange_id or quality
    local exchangeCfg = getConfig(game_config_field.equip_exchange)
    local itemCfg = exchangeCfg:getNodeWithKey(tostring(exchange_id))
    local metal = itemCfg:getNodeWithKey("metal"):getNodeAt(0)
    local metalcore = itemCfg:getNodeWithKey("metalcore"):getNodeAt(0)

    local metal_down = metal:getNodeAt(0):toInt()
    local metal_up = metal:getNodeAt(1):toInt()

    local metalcore_down = metalcore:getNodeAt(0):toInt()
    local metalcore_up = metalcore:getNodeAt(1):toInt()

    --取强化等级 来计算消耗的铁
    local strengLv = itemData.lv
    local strengCfg = getConfig(game_config_field.equip_strongthen)
    local strengCostMetal = 0
    for i=1,strengLv-1 do
        local metalCfg = strengCfg:getNodeWithKey(tostring(i))
        local metalBase = metalCfg:getNodeWithKey("metal"):toInt()
        local metalRate = metalCfg:getNodeWithKey("quality" .. quality):toInt()
        strengCostMetal = strengCostMetal + math.ceil(metalRate * 0.01 * metalBase)
    end

    --取精炼等级来计算消耗的铁 和 精炼石
    local st_lv = itemData.st_lv
    local stCfg = getConfig(game_config_field.equip_st)
    local stCostMetal = 0
    local stCostCore = 0
    for i=1,st_lv do
        local stItemCfg = stCfg:getNodeWithKey(tostring(i))
        local metalcore = stItemCfg:getNodeWithKey("metalcore"):toInt()
        local metal = stItemCfg:getNodeWithKey("metal"):toInt()
        stCostMetal = stCostMetal + metal
        stCostCore = stCostCore + metalcore
    end

    --将三者都加起来
    local totalMetalMin = metal_down + strengCostMetal + stCostMetal
    local totalMetalMax = metal_up + strengCostMetal + stCostMetal

    local totalCoreMin = metalcore_down + stCostCore
    local totalCoreMax = metalcore_up + stCostCore

    if setType == 1 then
        self.metal_min = self.metal_min + totalMetalMin
        self.metal_max = self.metal_max + totalMetalMax
        self.metal_core_min = self.metal_core_min + totalCoreMin
        self.metal_core_max = self.metal_core_max + totalCoreMax
    else
        self.metal_min = self.metal_min - totalMetalMin
        self.metal_max = self.metal_max - totalMetalMax
        self.metal_core_min = self.metal_core_min - totalCoreMin
        self.metal_core_max = self.metal_core_max - totalCoreMax
    end
    self.metal_label:setString(self.metal_min .. "-" .. self.metal_max)
    self.xilian_label:setString(self.metal_core_min .. "-" .. self.metal_core_max)
end
--[[--
    刷新ui
]]
function ui_equip_split.refreshUi(self)
    self.m_table_view:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(tableViewTemp);
    self:refreshBtnStutas()
end
--[[--
    初始化
]]
function ui_equip_split.init(self,t_params)
    t_params = t_params or {};
    game_data:equipSortByTypeName("default");
    self.m_sprite_tag = 101;
    self.m_equipIdTable = {}
    self.m_select_id_table = {}
    self.metal_min = 0
    self.metal_max = 0
    self.metal_core_min = 0
    self.metal_core_max = 0
end

--[[--
    创建ui入口并初始化数据
]]
function ui_equip_split.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_equip_split;