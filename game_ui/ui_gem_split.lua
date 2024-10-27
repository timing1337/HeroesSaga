---  宝石分解
local ui_gem_split = {
    m_table_view = nil,
    metal_label = nil,
    xilian_label = nil,
    m_sprite_backg = nil,
    m_for_shop_btn = nil,
    m_split_btn = nil,
    m_auto_add_btn = nil,
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
    add_flag = nil,
    split_index = nil,
    count_node = nil,
    count_number = nil,
    itemData = nil,
    number_label = nil,
    tableViewTemp = nil,
    effect_flag = nil,
    m_node_splitbtnboard = nil,  -- 分解种类选择按钮板
    m_control_btns = nil,  -- 控制按钮
}
--[[--
    销毁ui
]]
function ui_gem_split.destroy(self)
    -- body
    cclog("-----------------ui_gem_split destroy-----------------");
    self.m_table_view = nil;
    self.metal_label = nil;
    self.xilian_label = nil;
    self.m_sprite_backg = nil;
    self.m_for_shop_btn = nil;
    self.m_split_btn = nil;
    self.m_auto_add_btn = nil;
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
    self.add_flag = nil;
    self.split_index = nil;
    self.count_node = nil;
    self.count_number = nil;
    self.itemData = nil;
    self.number_label = nil;
    self.tableViewTemp = nil;
    self.effect_flag = nil;
    self.m_node_splitbtnboard = nil;
    self.m_control_btns = nil;
end
--[[--
    返回
]]
function ui_gem_split.back(self,backType)
    game_scene:enterGameUi("game_main_scene",{gameData = nil});
    -- self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function ui_gem_split.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        if btnTag == 100 then--装备精炼
            -- game_scene:enterGameUi("game_equip_refining",{enterType = "ui_gem_split"})
            game_scene:enterGameUi("gem_system_synthesis",{})
        elseif btnTag == 101 then--分解
            local function equip_split(card_list)
                local function responseMethod(tag,gameData)
                    self.effect_flag = true
                    local data = gameData:getNodeWithKey("data")
                    local reward = data:getNodeWithKey("reward")
                    if reward then
                        cclog("reward = " .. reward:getFormatBuffer())
                        game_util:rewardTipsByJsonData(reward);
                    end
                    local function remove_node( node )--回调隐藏，回归原位
                        node:removeFromParentAndCleanup(true)
                        self.metal_min = 0
                        self.metal_max = 0
                        self.metal_core_min = 0
                        self.metal_core_max = 0
                        self.metal_label:setString("0")
                        self.xilian_label:setString("0")
                        self.effect_flag = false
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
                        -- local sprite_tag = self.m_select_id_table[tostring(equip_id)];
                        local sprite = tolua.cast(self.m_sprite_background:getChildByTag(10),"CCSprite");
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
                    self.count_node:setVisible(false)
                    self.add_flag = false
                    self.split_index = nil;
                    self:refreshUi(1);
                end
                local params = "";
                cclog2(self.m_equipIdTable,"self.m_equipIdTable")
                for i=1,#self.m_equipIdTable do
                    local id = self.m_equipIdTable[i]
                    -- local itemData,itemCfg = game_data:getGemDataById(id)
                    local key = "gems=" .. id .."_" .. self.count_number
                    params = params .. key .."&";
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gem_resolve"), http_request_method.GET, params,"gem_resolve")
            end
            if #self.m_equipIdTable > 0 then
                equip_split()
            else
                game_util:addMoveTips({text = string_helper.ui_gem_split.add_split_gem})
            end
        elseif btnTag == 102 then--自动添加
            local equipCount = #self.m_selEquipDataTab
            local autoItemData = nil
            local autoSortId = nil
            local autoQuality = nil
            for i=1,#self.m_selEquipDataTab do
                -- local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - i + 1]);
                local id = self.m_selEquipDataTab[equipCount - i + 1]
                local itemData,itemCfg = game_data:getGemDataById(id)
                local sortId = itemCfg:getNodeWithKey("career"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                local existFlag,cardName = game_data:gemInGemPos(sortId,id)
                if existFlag then
                else
                    local flag,k = game_util:idInTableById(tostring(id),self.m_equipIdTable);
                    if flag and k ~= nil then
                    else
                        autoItemData = {count = itemData,c_id = id,id = id}
                        autoSortId = sortId 
                        autoQuality = quality
                        break;
                    end
                end
            end
            if autoItemData then
                if #self.m_equipIdTable <= 10 then
                    self:addEquipFromById(autoItemData,autoSortId,autoQuality)
                    self:refreshUi()
                else
                    game_util:addMoveTips({text = string_helper.ui_gem_split.split_top});
                end
            else
                game_util:addMoveTips({text = string_helper.ui_gem_split.not_equip});
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
        elseif btnTag == 1002 then--装备分解
            if not game_button_open:checkButtonOpen(607) then
                return;
            end
            game_scene:enterGameUi("ui_equip_split");
            self:destroy();
        elseif btnTag == 999 then--减个数
            self.count_number = self.count_number - 1
            if self.count_number < 1 then
                self.count_number = 1
            end
            self.itemData.count = self.count_number
            self:addEquipFromById(self.itemData)
        elseif btnTag == 998 then--加个数
            local id = self.itemData.id
            local maxCount,itemCfg = game_data:getGemDataById(id);
            self.count_number = self.count_number + 1
            if self.count_number > maxCount then 
                self.count_number = maxCount 
            end
            self.itemData.count = self.count_number
            self:addEquipFromById(self.itemData)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_jewel_split.ccbi");

    self.m_table_view = ccbNode:nodeForName("table_view_node");
    self.metal_label = ccbNode:labelBMFontForName("metal_label");
    self.xilian_label = ccbNode:labelBMFontForName("xilian_label");

    self.m_sprite_background = ccbNode:spriteForName("sprite_background");

    self.m_for_shop_btn = ccbNode:controlButtonForName("btn_duihuan");
    self.m_split_btn = ccbNode:controlButtonForName("btn_fenjie");
    game_util:setCCControlButtonTitle(self.m_for_shop_btn,string_helper.ccb.title190);
    game_util:setCCControlButtonTitle(self.m_split_btn,string_helper.ccb.title191);
    self.m_auto_add_btn = ccbNode:controlButtonForName("btn_auto_add");
    local title189 = ccbNode:labelTTFForName("title189");
    title189:setString(string_helper.ccb.title189)

    -- game_util:setControlButtonTitleBMFont(self.m_for_shop_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_split_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_auto_add_btn)
    
    self.m_back_btn = ccbNode:controlButtonForName("btn_back");
    self.count_node = ccbNode:nodeForName("count_node")
    self.number_label = ccbNode:labelBMFontForName("number_label")

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
    return ccbNode;
end

local ButtonInfoTable = 
{
    btn1 = {name = string_helper.ui_gem_split.split_card, Inreview = 32, btnId = 507, openFlag = true, btnIndex = 1},
    btn2 = {name = string_helper.ui_gem_split.split_equip, Inreview = 25, btnId = 607, openFlag = true, btnIndex = 2 },
    btn3 = {name = string_helper.ui_gem_split.split_gem, Inreview = 130, btnId = 121, openFlag = true, btnIndex = 3 },
}
local TablePosX = {
    {0.5},
    {0.35, 0.65},
    {0.15, 0.5, 0.85},
}

--[[
    刷新按钮状态 分解卡牌 分解装备 分解宝石
]]
function ui_gem_split.refreshBtnStutas( self )
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
function ui_gem_split.refresh_select_list(self)
    local count = #self.m_equipIdTable
    local length = 10;
    if count <= 10 then
        length = 10;
    else
        length = 100 / count;
    end
    for i=1,#self.m_equipIdTable do
        local equip_id = self.m_equipIdTable[i];
        -- local sprite_tag = self.m_select_id_table[tostring(equip_id)];
        local sprite_tag = 10
        cclog("sprite_tag == " .. sprite_tag)
        local equip_node = self.m_sprite_background:getChildByTag(sprite_tag);
        local node_size = equip_node:getContentSize();
        equip_node:setPosition(ccp(node_size.width*0.5,node_size.height*0.5));
    end
    if self.add_flag == true then
        self.count_node:setVisible(true)
    else
        self.count_node:setVisible(false)
    end
end
--[[
    创建分解列表
]]--
function ui_gem_split.createTableView( self,viewSize )
    self.m_selEquipDataTab = game_data:getGemIdTable();
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
            local ccbNode = game_util:createGemItemByCCB2();
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < equipCount then
                -- local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[equipCount - index]);
                local itemData,itemCfg = game_data:getGemDataById(self.m_selEquipDataTab[equipCount - index]);
                game_util:setGemItemInfoByTable2(ccbNode,{count = itemData,c_id = self.m_selEquipDataTab[equipCount - index]});
                -- cclog("itemData = " .. json.encode(itemData))
                -- cclog("itemCfg == " .. itemCfg:getFormatBuffer())
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                if self.m_selEquipDataTab[equipCount - index] == self.split_index then
                    m_sel_img:setVisible(true);
                else
                    m_sel_img:setVisible(false);
                end
                -- local flag,k = game_util:idInTableById(tostring(self.m_selEquipDataTab[equipCount - index]),self.m_equipIdTable);
                -- if flag then
                --     m_sel_img:setVisible(true);
                -- else
                --     m_sel_img:setVisible(false);
                -- end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item and (self.effect_flag == false) then
            local ccbNode = tolua.cast(item:getChildByTag(10),"luaCCBNode");
            local m_sel_img = ccbNode:spriteForName("m_sel_img")
            local id = self.m_selEquipDataTab[equipCount - index]
            local itemData,itemCfg = game_data:getGemDataById(id);
            if self.m_sprite_background:getChildByTag(10) ~= nil then
                self.m_sprite_background:removeChildByTag(10,true);
            end
            cclog2(itemData,"itemData")
            cclog2(itemCfg,"itemCfg")
            cclog("id === " .. id)
            cclog2(self.split_index,"self.split_index")
            if id == self.split_index then
                self.split_index = nil;
                self.add_flag = false;
                self.m_equipIdTable = {};
                m_sel_img:setVisible(false);
                local sortId = itemCfg:getNodeWithKey("career"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                self:setCostLabel({count = itemData,c_id = id,id = id},quality,2)
                self:refresh_select_list();
            else
                self.split_index = id;
                m_sel_img:setVisible(true);
                self.add_flag = true;
                local sortId = itemCfg:getNodeWithKey("career"):toInt()
                local quality = itemCfg:getNodeWithKey("quality"):toInt()
                -- local existFlag,cardName = game_data:gemInGemPos(sortId,id)
                -- if existFlag then
                --     game_util:addMoveTips({text = "该宝石已经装在" .. cardName .. "身上!"});
                -- else
                    m_sel_img:setVisible(true);
                    self.itemData = {count = 1,c_id = id,id = id,sortId = sortId,quality = quality}
                    self.count_number = 1
                    self:addEquipFromById(self.itemData)
                    -- self:addEquipFromById({count = itemData,c_id = id,id = id},sortId,quality)
                -- end
            end
            self:refreshUi()
            -- local flag,k = game_util:idInTableById(tostring(id),self.m_equipIdTable);
            -- if flag and k ~= nil then
            --     table.remove(self.m_equipIdTable,k);
            --     m_sel_img:setVisible(false);
            --     for key,value in pairs(self.m_select_id_table) do
            --         if tostring(key) == tostring(id) then
            --             if self.m_sprite_background:getChildByTag(value) ~= nil then
            --                 self.m_sprite_background:removeChildByTag(value,true);
            --             end
            --         end
            --     end
            --     local sortId = itemCfg:getNodeWithKey("career"):toInt()
            --     local quality = itemCfg:getNodeWithKey("quality"):toInt()
            --     self:setCostLabel({count = itemData,c_id = id,id = id},quality,2)
            --     self:refresh_select_list();
            -- else
            --     local sortId = itemCfg:getNodeWithKey("career"):toInt()
            --     local quality = itemCfg:getNodeWithKey("quality"):toInt()
            --     local existFlag,cardName = game_data:gemInGemPos(sortId,id)
            --     if existFlag then
            --         game_util:addMoveTips({text = "该装备已经装在" .. cardName .. "身上!"});
            --     else
            --         if #self.m_equipIdTable <= 10 then
            --             m_sel_img:setVisible(true);
            --             self:addEquipFromById({count = itemData,c_id = id,id = id},sortId,quality)
            --         else
            --             game_util:addMoveTips({text = "分解个数已达上限!"});
            --         end
            --     end
            -- end
        end
    end
    return TableViewHelper:create(params);
end
--[[
    添加装备全身像
]]--
function ui_gem_split.addEquipFromById(self,itemData)
    if self.m_sprite_background:getChildByTag(10) ~= nil then
        self.m_sprite_background:removeChildByTag(10,true);
    end
    -- local existFlag,cardName = game_data:equipInEquipPos(itemData.sortId,itemData.id)
    -- if existFlag then

    -- else
        -- table.insert(self.m_equipIdTable,itemData.id)
        self.m_equipIdTable[1] = itemData.id
        -- self.m_select_id_table[tostring(itemData.id)] = self.m_sprite_tag
        local equip_node = game_util:createGemItemByCCB(itemData);
        local node_size = equip_node:getContentSize();
        self.m_sprite_background:addChild(equip_node,10,10)
        -- self.m_sprite_background:addChild(equip_node,10,self.m_sprite_tag)
        self:refresh_select_list();
        -- self.m_sprite_tag = self.m_sprite_tag + 1
        self:setCostLabel(itemData,itemData.quality)
    -- end
    self.number_label:setString(self.count_number)
end
--[[
    设置label 值
]]
function ui_gem_split.setCostLabel(self,itemData,quality,setType)
    setType = setType or 1
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(tostring(itemData.id))
    local count,gemItemCfg = game_data:getGemDataById(itemData.id)
    local exchange = itemCfg:getNodeWithKey("exchange")
    local down_exchange = exchange:getNodeAt(0):toInt()
    local up_exchange = exchange:getNodeAt(1):toInt()

    local single_piece_min = down_exchange * self.count_number
    local single_piece_max = up_exchange * self.count_number
    if setType == 1 then
        -- self.metal_min = self.metal_min + totalMetalMin
        -- self.metal_max = self.metal_max + totalMetalMax
        -- self.metal_core_min = self.metal_core_min + single_piece_min
        -- self.metal_core_max = self.metal_core_max + single_piece_max
    else
        -- self.metal_min = self.metal_min - totalMetalMin
        -- self.metal_max = self.metal_max - totalMetalMax
        -- self.metal_core_min = self.metal_core_min - single_piece_min
        -- self.metal_core_max = self.metal_core_max - single_piece_max
        single_piece_min = 0
        single_piece_max = 0
    end
    self.xilian_label:setString(single_piece_min .. "-" .. single_piece_max)
    -- self.xilian_label:setString(self.metal_core_min .. "-" .. self.metal_core_max)
end
--[[--
    刷新ui
]]
function ui_gem_split.refreshUi(self,ref_flag)
    ref_flag = ref_flag or 0
    local pX,pY;
    if self.tableViewTemp then
        pX,pY = self.tableViewTemp:getContainer():getPosition();
    end
    self.m_table_view:removeAllChildrenWithCleanup(true);
    self.tableViewTemp = self:createTableView(self.m_table_view:getContentSize());
    self.tableViewTemp:setScrollBarVisible(false);
    self.m_table_view:addChild(self.tableViewTemp);
    if pX and pY and (ref_flag == 0) then
        self.tableViewTemp:setContentOffset(ccp(pX,pY), false);
    end
    self:refreshBtnStutas()
end
--[[--
    初始化
]]
function ui_gem_split.init(self,t_params)
    t_params = t_params or {};
    game_data:equipSortByTypeName("default");
    self.m_sprite_tag = 101;
    self.m_equipIdTable = {}
    self.m_select_id_table = {}
    self.metal_min = 0
    self.metal_max = 0
    self.metal_core_min = 0
    self.metal_core_max = 0
    self.add_flag = false
    self.count_number = 1
    self.effect_flag = false
end

--[[--
    创建ui入口并初始化数据
]]
function ui_gem_split.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return ui_gem_split;