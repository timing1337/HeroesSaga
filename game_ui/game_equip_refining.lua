--- 装备精炼
local game_equip_refining = {
    m_table_view = nil,
    m_sel_btn = nil,
    star_node = nil,
    m_metal_total_label = nil,
    m_refining_total_label = nil,
    m_cost_metal_label = nil,
    m_cost_refining_label = nil,
    m_ok_btn = nil,
    cur_property = nil,
    next_property = nil,
    rate_level_label = nil,
    false_level = nil,
    show_node = nil,

    m_select_id = nil,--选中的
    m_selEquipDataTab = nil,
    last_m_sel_img = nil,
    table_view_node = nil,
    m_anim_node = nil,
    m_tips_spr_1 = nil,
    m_cost_metal = nil,
    m_btn_table = nil,
    m_advanced_btn = nil,
    rate_level_label2 = nil,
    m_cost_metal_label2 = nil,
    m_cost_refining_label2 = nil,
    m_max_rate = nil,
};
--[[--
    销毁ui
]]
function game_equip_refining.destroy(self)
    -- body
    cclog("-----------------game_equip_refining destroy-----------------");
    self.m_table_view = nil;
    self.m_sel_btn = nil;
    self.star_node = nil;
    self.m_metal_total_label = nil;
    self.m_refining_total_label = nil;
    self.m_cost_metal_label = nil;
    self.m_cost_refining_label = nil;
    self.m_ok_btn = nil;
    self.cur_property = nil;
    self.next_property = nil;
    self.rate_level_label = nil;
    self.false_level = nil;
    self.show_node = nil;
    self.m_select_id = nil;
    self.m_selEquipDataTab = nil;
    self.last_m_sel_img = nil;
    self.table_view_node = nil;
    self.m_anim_node = nil;
    self.m_tips_spr_1 = nil;
    self.m_cost_core = nil;
    self.m_btn_table = nil;
    self.m_advanced_btn = nil;
    self.rate_level_label2 = nil;
    self.m_cost_metal_label2 = nil;
    self.m_cost_refining_label2 = nil;
    self.m_max_rate = nil;
end

--[[--
    返回
]]
function game_equip_refining.back(self,backType)
    if self.enterType == "ui_equip_split" then
        game_scene:enterGameUi("ui_equip_split");
        self:destroy();
    else
        game_scene:enterGameUi("game_main_scene",{gameData = nil});
        self:destroy();
    end
end
--[[--
    读取ccbi创建ui
]]
function game_equip_refining.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back();
        elseif btnTag == 101 or btnTag == 102 then--开始精炼
            self:onSureFunc(btnTag);
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            cclog("btnTag === " .. btnTag)
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
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equip_refining.ccbi");
    --装备相关
    self.table_view_node = ccbNode:nodeForName("table_view_node");
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn");
    self.star_node = ccbNode:nodeForName("star_node");
    self.m_metal_total_label = ccbNode:labelBMFontForName("m_metal_total_label");
    self.m_refining_total_label = ccbNode:labelBMFontForName("m_refining_total_label");
    self.m_cost_metal_label = ccbNode:labelBMFontForName("m_cost_metal_label");
    self.m_cost_refining_label = ccbNode:labelBMFontForName("m_cost_refining_label");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    self.cur_property = ccbNode:labelTTFForName("cur_property");
    self.next_property = ccbNode:labelTTFForName("next_property");
    self.rate_level_label = ccbNode:labelBMFontForName("rate_level_label");
    self.false_level = ccbNode:labelBMFontForName("false_level");
    self.show_node = ccbNode:nodeForName("show_node");
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")

    self.m_advanced_btn = ccbNode:controlButtonForName("m_advanced_btn");
    self.rate_level_label2 = ccbNode:labelBMFontForName("rate_level_label2");
    self.m_cost_metal_label2 = ccbNode:labelBMFontForName("m_cost_metal_label2");
    self.m_cost_refining_label2 = ccbNode:labelBMFontForName("m_cost_refining_label2");
    self.m_btn_table = {}
    for i=1,4 do
        self.m_btn_table[i] = ccbNode:controlButtonForName("m_table_tab_btn_"..i)
        self.m_btn_table[i]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_select.png"),CCControlStateNormal);
    end
    self.m_btn_table[1]:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("card_table_selected.png"),CCControlStateNormal);
    
    self.m_tips_spr_1:runAction(game_util:createRepeatForeverFade())
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.file18)
    game_util:setCCControlButtonTitle(self.m_advanced_btn,string_helper.ccb.file19)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_advanced_btn)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text137)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text138)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text139)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text140)

    local text1 = ccbNode:labelBMFontForName("text1")
    text1:setString(string_helper.ccb.text141)
    local text2 = ccbNode:labelBMFontForName("text2")
    text2:setString(string_helper.ccb.text142)
    local text3 = ccbNode:labelBMFontForName("text3")
    text3:setString(string_helper.ccb.text141)
    local text4 = ccbNode:labelTTFForName("text4")
    text4:setString(string_helper.ccb.text143)
    return ccbNode;
end
--[[
    
]]
function game_equip_refining.onSureFunc(self,btnTag)
    if self.m_select_id == nil then
        game_util:addMoveTips({text = string_helper.game_equip_refining.text});
    else
        local itemData,itemCfg = game_data:getEquipDataById(self.m_select_id);
        if itemData.st_lv == 10 then
            game_util:addMoveTips({text = string_helper.game_equip_refining.text2});    
            return
        end
        local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
        local totalMetalCore = game_data:getUserStatusDataByKey("metalcore") or 0

        local function sendHttpRequest()
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                cclog("data == " .. data:getFormatBuffer())
                local success = data:getNodeWithKey("success"):toStr()
                if success == "true" then
                    game_util:addMoveTips({text = string_helper.game_equip_refining.refining_success});
                else
                    game_util:addMoveTips({text = string_helper.game_equip_refining.refining_failed});
                end
                self:refreshUi()
            end
            local params = {};
            params.equip_id = self.m_select_id;
            if btnTag == 101 then
                params.sort = 0
            else
                params.sort = 1
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_st_levelup"), http_request_method.GET, params,"equip_st_levelup")
        end
        if self.m_cost_metal > totalMetal then--铁不足
            local t_params = 
            {
                m_openType = 6,
                m_call_func = function()
                    self:refreshUi()
                end
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        elseif (btnTag == 101 and self.m_cost_core > totalMetalCore) or (btnTag == 102 and self.m_max_rate > totalMetalCore) then--精炼石不足
            local t_params = 
            {
                m_openType = 20,
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
            -- game_util:addMoveTips({text = "精炼石不足!"});
        else
            sendHttpRequest()
        end

    end
end
--[[
    设置精炼变化属性
]]
function game_equip_refining.setPropertyChange(self,sort,st_lv)
    local stCfg = getConfig(game_config_field.equip_st)
    local next_lv = st_lv + 1

    local show_now = ""
    local show_next = ""
    local cost_metal = 0
    local cost_core,max_rate = 0,0
    local rate = nil
    local false_back = nil

    cclog("st_lv == " .. st_lv)
    local itemCfg = stCfg:getNodeWithKey(tostring(st_lv))
    local nextCfg = stCfg:getNodeWithKey(tostring(next_lv))
    local change_type = {"patk","matk","def","speed"}
    local pro_name = string_helper.game_equip_refining.pro_name
    if st_lv == 0 then
        --0
        show_now = string_helper.game_equip_refining.show_now
        rate = nextCfg:getNodeWithKey("rate"):toInt()--1
        false_back = 0;--2

        local pro_next = nextCfg:getNodeWithKey(change_type[sort])
        local next_type = pro_next:getNodeAt(0):toInt()
        local next_rate = pro_next:getNodeAt(1):toInt()
        --3
        show_next = string_helper.game_equip_refining.show_next .. pro_name[next_type] .. "+" .. next_rate .. "%"

        cost_metal = nextCfg:getNodeWithKey("metal"):toInt()--消耗的铁
        cost_core = nextCfg:getNodeWithKey("metalcore"):toInt()--消耗的精炼石
        max_rate = nextCfg:getNodeWithKey("max_rate")--消耗的精炼石
        max_rate = max_rate and max_rate:toInt() or 0
    elseif st_lv == 10 then
        show_next = string_helper.game_equip_refining.show_next2
        local pro_change = itemCfg:getNodeWithKey(change_type[sort])
        local pro_type = pro_change:getNodeAt(0):toInt()
        local pro_rate = pro_change:getNodeAt(1):toInt()
        show_now = string_helper.game_equip_refining.show_now2 .. pro_name[pro_type] .. "+" .. pro_rate .. "%"
    else
        rate = nextCfg:getNodeWithKey("rate"):toInt()--概率
        false_back = itemCfg:getNodeWithKey("false_back"):toInt()--失败

        cost_metal = nextCfg:getNodeWithKey("metal"):toInt()--消耗的铁
        cost_core = nextCfg:getNodeWithKey("metalcore"):toInt()--消耗的精炼石
        max_rate = nextCfg:getNodeWithKey("max_rate")--消耗的精炼石
        max_rate = max_rate and max_rate:toInt() or 0
        
        local pro_change = itemCfg:getNodeWithKey(change_type[sort])
        local pro_type = pro_change:getNodeAt(0):toInt()
        local pro_rate = pro_change:getNodeAt(1):toInt()

        local pro_next = nextCfg:getNodeWithKey(change_type[sort])
        local next_type = pro_next:getNodeAt(0):toInt()
        local next_rate = pro_next:getNodeAt(1):toInt()
        --增加的属性
        show_now = string_helper.game_equip_refining.show_now2 .. pro_name[pro_type] .. "+" .. pro_rate .. "%"
        show_next = string_helper.game_equip_refining.show_next .. pro_name[next_type] .. "+" .. next_rate .. "%"
    end
    self.cur_property:setString(show_now)
    self.next_property:setString(show_next)

    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local totalMetalCore = game_data:getUserStatusDataByKey("metalcore") or 0
    self.m_cost_metal_label:setString(tostring(cost_metal))
    self.m_cost_metal_label2:setString(tostring(cost_metal))
    self.m_cost_refining_label:setString(tostring(cost_core))
    self.m_cost_refining_label2:setString(tostring(max_rate))

    self.m_cost_metal = cost_metal
    self.m_cost_core = cost_core
    self.m_max_rate = max_rate

    game_util:setCostLable(self.m_cost_metal_label,cost_metal,totalMetal);
    game_util:setCostLable(self.m_cost_metal_label2,cost_metal,totalMetal);
    game_util:setCostLable(self.m_cost_refining_label,cost_core,totalMetalCore);
    game_util:setCostLable(self.m_cost_refining_label2,max_rate,totalMetalCore);

    if rate then
        if rate <= 40 then
            self.rate_level_label:setString(string_helper.game_equip_refining.low_probability)
            self.rate_level_label:setColor(ccc3(0,255,0))
        elseif rate >= 80 then
            self.rate_level_label:setString(string_helper.game_equip_refining.top_probability)
            self.rate_level_label:setColor(ccc3(160,32,240))
        else
            self.rate_level_label:setString(string_helper.game_equip_refining.middle_probability)
            self.rate_level_label:setColor(ccc3(0,0,255))
        end
    else
        self.rate_level_label:setString(string_helper.game_equip_refining.wu)
        self.rate_level_label:setColor(ccc3(0,255,0))
    end
    if false_back then
        self.false_level:setString(tostring(false_back))
    else
        self.false_level:setString(string_helper.game_equip_refining.wu)
    end
end
--[[--
    创建装备列表
]]
function game_equip_refining.createEquipTableView(self,viewSize,tableData)
    self.last_m_sel_img = nil;
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
                local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                local m_sel_img = ccbNode:spriteForName("m_sel_img")
                if itemData.id == self.m_select_id then
                    m_sel_img:setVisible(true);
                    self.last_m_sel_img = m_sel_img
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
            local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipDataTab[index+1]);
                
            if itemData.id ~= self.m_select_id then
                if self.last_m_sel_img then
                    self.last_m_sel_img:setVisible(false)
                end
                m_sel_img:setVisible(true)
                self.m_select_id = itemData.id
                self.last_m_sel_img = m_sel_img
            else
                m_sel_img:setVisible(false)
                self.last_m_sel_img = nil
                self.m_select_id = nil
            end
            self:refreshTips()
        end
    end
    return TableViewHelper:create(params);
end
--[[
    设置星星
]]
function game_equip_refining.setStarPos(self,index)
    self.star_node:removeAllChildrenWithCleanup(true)
    for i=1,10 do
        local star = nil
        if i < index + 1 then
            star = CCSprite:createWithSpriteFrameName("equip_star_2.png");
        elseif i == index + 1 then
            star = CCSprite:createWithSpriteFrameName("equip_star_2.png");
            star:runAction(game_util:createRepeatForeverFade());
        else
            star = CCSprite:createWithSpriteFrameName("equip_star_1.png");
        end
        if star then
            star:setAnchorPoint(ccp(0.5,0.5))
            star:setPosition(ccp(20 * ( (i-1) % 5),32 - 20 * math.floor( (i-1) / 5)))
            self.star_node:addChild(star,10,i)
        end
    end
end
--[[--
    刷新列表
]]
function game_equip_refining.refreshEquipTableView(self)
    self.table_view_node:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    self.m_tableView = self:createEquipTableView(self.table_view_node:getContentSize(),self.m_selEquipDataTab);
    self.table_view_node:addChild(self.m_tableView);
end
--[[--
    刷新tips
]]
function game_equip_refining.refreshTips(self)
    if self.m_select_id then
        local itemData,itemCfg = game_data:getEquipDataById(tostring(self.m_select_id));
        local st_lv = itemData.st_lv
        local sort = itemCfg:getNodeWithKey("sort"):toInt()
        self:setStarPos(st_lv)
        self:setPropertyChange(sort,st_lv)

        self.show_node:setVisible(true)

        local ccbNode = game_util:createEquipItemByCCB(itemData);
        cclog("itemData = " .. json.encode(itemData))
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.m_anim_node:addChild(ccbNode,10,10);
        self.m_tips_spr_1:setVisible(false);
    else
        self.m_tips_spr_1:setVisible(true);
        self.m_anim_node:removeAllChildrenWithCleanup(true)
        self.show_node:setVisible(false)
    end
end

--[[--
    刷新ui
]]
function game_equip_refining.refreshUi(self)
    local totalMetal = game_data:getUserStatusDataByKey("metal") or 0
    local value,unit = game_util:formatValueToString(totalMetal);
    self.m_metal_total_label:setString(tostring(value .. unit));

    local totalMetalCore = game_data:getUserStatusDataByKey("metalcore") or 0
    local value2,unit2 = game_util:formatValueToString(totalMetalCore);
    self.m_refining_total_label:setString(tostring(value2 .. unit2))

    self:refreshEquipTableView()
    self:refreshTips()
end
--[[--
    初始化
]]
function game_equip_refining.init(self,t_params)
    t_params = t_params or {};
    self.enterType = t_params.enterType or 0
    self.m_select_id = nil;
    self.last_m_sel_img = nil;
end

--[[--
    创建ui入口并初始化数据
]]
function game_equip_refining.create(self,t_params)
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();

      local id = game_guide_controller:getIdByTeam("19");
        print("game_guide_controller:getIdByTeam(19)", id)
        if id == 1901 then
            game_guide_controller:gameGuide("drama","19",1901)
        end


    return uiNode;
end

return game_equip_refining;
