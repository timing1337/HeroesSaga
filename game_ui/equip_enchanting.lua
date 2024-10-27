--- 装备进化
local equip_enchanting = {
    m_anim_node = nil,--动画节点
        
    is_enchant = nil,

    m_status = nil, -- 装备的类型状态

    m_selEquipId = nil,--选中的equipid
    m_selSortIndex = nil,

    m_root_layer = nil,
    m_ccbNode = nil,
    m_layer_property_cur = nil,
    m_layer_property_add = nil,
    m_node_property_add = nil,

    m_list_view_bg = nil,
    m_sel_btn = nil,
    m_btn_enchanting = nil,
    m_btn_save = nil,
    m_btn_cancel = nil,
    m_btn_instroction = nil,
   
    m_node_curProperty = nil, -- 当前属性 
    m_label_curProperty_nil_1 = nil,
    m_label_curProperty_nil_2 = nil,
    m_property_sprite_cur_1 = nil,
    m_property_sprite_cur_2 = nil,
    m_property_label_curcount_1 = nil,
    m_property_label_curcount_2 = nil,

    m_node_property_add = nil,
    m_sprite_instroction = nil,
    m_property_sprite_add_1 = nil,
    m_property_sprite_add_2 = nil,
    m_property_label_addcount_1 = nil,
    m_property_label_addcount_2 = nil,

    m_label_piece_total = nil,
    m_label_piece_cost = nil,
    m_tips_spr_1 = nil,

    m_tGameData = nil,
    m_selEquipDataTab = nil,

    m_label_add_anim_1 = nil,
    m_label_add_anim_2 = nil,

    m_tableView = nil,

    m_anim_tag = nil,
    m_btn_canel = nil,
};
--[[--
    销毁ui
]]
function equip_enchanting.destroy(self)
    -- body
    cclog("-----------------equip_enchanting destroy-----------------");
    self.m_anim_node = nil

    self.is_enchant = nil

    self.m_status = nil

    self.m_selEquipId = nil
    self.m_selSortIndex = nil

    self.m_root_layer = nil
    self.m_ccbNode = nil
    self.m_layer_property_cur = nil
    self.m_layer_property_add = nil
    self.m_node_property_add = nil

    self.m_list_view_bg = nil
    self.m_sel_btn = nil
    self.m_btn_enchanting = nil
    self.m_btn_save = nil
    self.m_btn_cancel = nil
    self.m_btn_instroction = nil

    self.m_node_curProperty = nil     
    self.m_label_curProperty_nil_1 = nil
    self.m_label_curProperty_nil_2 = nil
    self.m_property_sprite_cur_1 = nil
    self.m_property_sprite_cur_2 = nil
    self.m_property_label_curcount_1 = nil
    self.m_property_label_curcount_2 = nil

    self.m_node_property_add = nil
    self.m_sprite_instroction = nil
    self.m_property_sprite_add_1 = nil
    self.m_property_sprite_add_2 = nil
    self.m_property_label_addcount_1 = nil
    self.m_property_label_addcount_2 = nil

    self.m_label_piece_total = nil
    self.m_label_piece_cost = nil
    self.m_tips_spr_1 = nil

    self.m_tGameData = nil
    self.m_selEquipDataTab = nil

    self.m_label_add_anim_1 = nil
    self.m_label_add_anim_2 = nil
    self.m_tableView = nil

    self.m_anim_tag = nil
    self.m_btn_canel = nil

end

--[[--
    返回
]]
function equip_enchanting.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function equip_enchanting.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back")
        -- elseif btnTag == 100 then -- 重新选择装备
        --     self:onSureFunc();
        elseif btnTag == 101 then -- 附魔
            -- game_util:addMoveTips({text = "开始附魔"})
            self:onSureEnchant()
        elseif btnTag == 102 then -- 说明
            -- game_util:addMoveTips({text = "说明"})
            game_scene:addPop("game_active_limit_detail_pop",{openType = "equip_enchanting"})
        elseif btnTag == 104 then -- 取消保存
            self:onSureCancel()
        elseif btnTag == 103 then
            -- game_util:addMoveTips({text = "开始保留"})
            self:onSureSaved()
        elseif btnTag >= 201 and btnTag <= 204 then--排序
            cclog("btnCallBack ===========btnTag===" .. btnTag)
            local selSort = tostring(EQUIP_SORT_TAB[btnTag-200].sortType);
            game_data:equipSortByTypeName(selSort)
            self:refreshSortTabBtn(btnTag-200);
        elseif btnTag == 9999 then--取消附魔，有附魔的装备才显示
            local function responseMethod(tag,gameData)
                if gameData == nil then
                    self.m_root_layer:setTouchEnabled(false);
                    return;
                else
                    local data = gameData:getNodeWithKey("data")
                    cclog2(data,"data")
                    local enchant = data:getNodeWithKey("enchant"):toInt()
                    local testReward = {enchant=enchant}
                    -- self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                    game_scene:enterGameUi("equip_enchanting",{selEquipId = self.m_selEquipId,m_anim_tag = true})
                    game_util:rewardTipsByDataTable(testReward);
                    -- game_util:addMoveTips({text = "清除附魔成功！"})
                end
                -- 成功响应
                -- self:responseEnchanted()
            end
            local params = {};
            params.equip_id = self.m_selEquipId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_remove_enchant"), http_request_method.GET, params,"equip_remove_enchant")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_equipment_enchanting.ccbi");
    --装备相关
    self.m_anim_node = ccbNode:nodeForName("m_anim_node")

    self.m_list_view_bg = ccbNode:nodeForName("m_list_view_bg")
    self.m_sel_btn = ccbNode:controlButtonForName("m_sel_btn")
    self.m_btn_enchanting = ccbNode:controlButtonForName("m_btn_enchanting")
    game_util:setCCControlButtonTitle(self.m_btn_enchanting,string_helper.ccb.text149)
    self.m_btn_save = ccbNode:controlButtonForName("m_btn_save")
    self.m_btn_instroction = ccbNode:controlButtonForName("m_btn_instroction")
    game_util:setCCControlButtonTitle(self.m_btn_instroction,string_helper.ccb.text151)
    self.m_btn_cancel = ccbNode:controlButtonForName("m_btn_cancel")

    self.m_label_piece_total = ccbNode:labelTTFForName("m_label_piece_total")
    self.m_label_piece_cost = ccbNode:labelTTFForName("m_label_piece_cost")
    self.m_tips_spr_1 = ccbNode:spriteForName("m_tips_spr_1")

    self.m_node_curProperty = ccbNode:nodeForName("m_node_curProperty")
    self.m_label_curProperty_nil_1 = ccbNode:labelTTFForName("m_label_curProperty_nil_1")
    self.m_label_curProperty_nil_2 = ccbNode:labelTTFForName("m_label_curProperty_nil_2")
    self.m_label_curProperty_nil_1:setString(string_helper.ccb.file62);
    self.m_label_curProperty_nil_2:setString(string_helper.ccb.file62);
    self.m_property_sprite_cur_1 = ccbNode:spriteForName("m_property_sprite_cur_1")
    self.m_property_sprite_cur_2 = ccbNode:spriteForName("m_property_sprite_cur_2")
    self.m_property_label_curcount_1 = ccbNode:labelTTFForName("m_property_label_curcount_1")
    self.m_property_label_curcount_2 = ccbNode:labelTTFForName("m_property_label_curcount_2")

    self.m_node_property_add = ccbNode:nodeForName("m_node_property_add")
    self.m_sprite_instroction = ccbNode:spriteForName("m_sprite_instroction")
    self.m_property_sprite_add_1 = ccbNode:spriteForName("m_property_sprite_add_1")
    self.m_property_sprite_add_2 = ccbNode:spriteForName("m_property_sprite_add_2")
    self.m_property_label_addcount_1 = ccbNode:labelTTFForName("m_property_label_addcount_1")
    self.m_property_label_addcount_2 = ccbNode:labelTTFForName("m_property_label_addcount_2")

    self.m_btn_canel = ccbNode:controlButtonForName("m_btn_canel")
    game_util:setCCControlButtonTitle(self.m_btn_canel,string_helper.ccb.text150)
    self.m_btn_canel:setVisible(false)
    
    self.m_label_add_anim_1 = ccbNode:labelTTFForName("m_label_add_anim_1")
    self.m_label_add_anim_2 = ccbNode:labelTTFForName("m_label_add_anim_2")
    self.m_label_add_anim_1:setVisible(false)
    self.m_label_add_anim_2:setVisible(false)

    self.m_label_curProperty_nil_1:setVisible(true)
    self.m_label_curProperty_nil_2:setVisible(true)
    -- self.m_property_sprite_cur_1:getParent():setVisible(false)
    -- self.m_property_sprite_cur_2:getParent():setVisible(false)
    self.m_property_sprite_cur_2:setVisible(false)
    self.m_property_sprite_cur_1:setVisible(false)
    self.m_property_label_curcount_1:setVisible(false)
    self.m_property_label_curcount_2:setVisible(false)

    self.m_node_property_add:setVisible(false)
    self.m_property_sprite_add_1:setVisible(false)
    self.m_property_sprite_add_2:setVisible(false)
    self.m_property_label_addcount_1:setVisible(false)
    self.m_property_label_addcount_2:setVisible(false)
    self.m_sprite_instroction:setVisible(true)

    self.m_btn_save:setVisible(false)
    self.m_btn_cancel:setVisible(false)
    self.m_btn_enchanting:setVisible(true)
    self.m_btn_instroction:setVisible(true)

    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-999,true);
    self.m_root_layer:setTouchEnabled(false);

    local m_table_tab_label_1 = ccbNode:labelBMFontForName("m_table_tab_label_1")
    m_table_tab_label_1:setString(string_helper.ccb.text137)
    local m_table_tab_label_2 = ccbNode:labelBMFontForName("m_table_tab_label_2")
    m_table_tab_label_2:setString(string_helper.ccb.text138)
    local m_table_tab_label_3 = ccbNode:labelBMFontForName("m_table_tab_label_3")
    m_table_tab_label_3:setString(string_helper.ccb.text139)
    local m_table_tab_label_4 = ccbNode:labelBMFontForName("m_table_tab_label_4")
    m_table_tab_label_4:setString(string_helper.ccb.text140)
    return ccbNode;
end

--[[--
    创建装备列表
]]
function equip_enchanting.createEquipTableView(self,viewSize,tableData)
    self.m_selListItem = nil;
    local itemsCount = #tableData;
    local totalItem = math.max(itemsCount%4 == 0 and itemsCount or math.floor(itemsCount/4+1)*4,4)
    local equipCfg = getConfig(game_config_field.equip);
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = itemsCount--totalItem;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = game_util:createEquipItemByCCB2();
            -- local ccbNode = game_util:createEquipItemByCCB4()
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if index < itemsCount then
                local tempId = tableData[index+1]
                local itemData,itemCfg = game_data:getEquipDataById(tempId);
                game_util:setEquipItemInfoByTable2(ccbNode,itemData);
                -- game_util:setEquipItemInfoByTable4(ccbNode,itemData)

                if self.m_selEquipId and self.m_selEquipId == tempId then
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                    self.m_selListItem = cell;
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if index >= itemsCount then return end;
        if eventType == "ended" and cell then
            if self.m_anim_tag == true or self.m_anim_tag == nil then
                local tempId = tableData[index+1]
                if self.m_selEquipId == nil or self.m_selEquipId ~= tempId then
                    if self.m_selListItem then
                        local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                        local m_sel_img = ccbNode:spriteForName("m_sel_img")
                        m_sel_img:setVisible(false);
                    end
                    self.m_selListItem = cell;
                    self.m_selEquipId = tostring(tempId)
                    
                    self:refreshTableViewPropertyInfo(self.m_selEquipId);
                    
                    local ccbNode = tolua.cast(self.m_selListItem:getChildByTag(10),"luaCCBNode");
                    local m_sel_img = ccbNode:spriteForName("m_sel_img")
                    m_sel_img:setVisible(true);
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
        -- self.m_selListItem = nil;
    end
    local tempTableView = TableViewHelper:create(params);
    if self.m_selEquipId then
        local posIndex = -1
        for i=1,itemsCount do
            if tableData[i] == tostring(self.m_selEquipId) then
                posIndex = i-1;
                break;
            end
        end
        cclog("posIndex ===== " .. posIndex)
        if posIndex ~= -1 then
            local contentSize = tempTableView:getContentSize()
            if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
                tempTableView:setContentOffset(ccp(0,math.min(viewSize.height - contentSize.height + posIndex * itemSize.height,0)))
            end
        end
    end 
    return tempTableView 
end



--[[--
    装备附魔 请求
]]
function equip_enchanting.onSureEnchant(self)
    if self.m_selEquipId == nil then
        game_util:addMoveTips({text = string_helper.equip_enchanting.text1});
        return;
    end
    if self.m_status == 1 then
        game_util:addMoveTips({text = string_helper.equip_enchanting.text2});
        return;
    end
    if self.m_status == 2 then
        game_util:addMoveTips({text = string_helper.equip_enchanting.text3});
        return;
    end

    local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId)
    cclog2(itemData.is_enchant,"itemData.is_enchant")
    if itemData.is_enchant then 
        -- 一般附魔
        local function sendRequest()
            local function responseMethod(tag,gameData)
                if gameData == nil then
                    self.m_root_layer:setTouchEnabled(false);
                    return;
                else
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                end
                -- 成功响应
                self:responseEnchanted()
            end
            --equip_id = 
            local params = {};
            params.equip_id = self.m_selEquipId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_enchant"), http_request_method.GET, params,"equip_enchant")
        end
        sendRequest();
    else
        -- 初始附魔
        local function sendRequest()
            cclog("=======sendRequest init=======")
            local function responseMethod(tag,gameData)
                if gameData == nil then
                    self.m_root_layer:setTouchEnabled(false);
                    return;
                else
                    local data = gameData:getNodeWithKey("data")
                    self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                end
                -- 成功响应
                cclog2(gameData,"gameData=InitEnchant===")
                self:responseInitEnchant()
            end
            --equip_id = 
            local params = {};
            params.equip_id = self.m_selEquipId;
            -- cclog2(params.equip_id,"params.equip_id==")
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_enchant"), http_request_method.GET, params,"equip_enchant")
        end
        sendRequest()
    end
end
--[[--
    装备保留 请求
]]
function equip_enchanting.onSureSaved( self )
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            else
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
            end
            -- 成功响应
            cclog("=====equip_enchanting.onSureSaved======")
            self:responseSuccessSaved()
        end
        --equip_id = 
        local params = {};
        params.equip_id = self.m_selEquipId;
        params.is_save = 1
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_save_init_enchant"), http_request_method.GET, params,"equip_save_init_enchant")
    end
    sendRequest();
end

--[[--
    取消保存
]]
function equip_enchanting.onSureCancel( self )
    local function sendRequest()
        local function responseMethod(tag,gameData)
            if gameData == nil then
                self.m_root_layer:setTouchEnabled(false);
                return;
            else
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
            end
            -- 成功响应
            cclog("=====equip_enchanting.onSureCancel======")
            self:responseSuccessCancel()
        end
        --equip_id = 
        local params = {};
        params.equip_id = self.m_selEquipId;
        params.is_save = 0
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_save_init_enchant"), http_request_method.GET, params,"equip_save_init_enchant")
    end
    sendRequest();
end


--[[--
    装备附魔 
    一般附魔：获得随机数 add_node:show 闪一下再加上
]]
function equip_enchanting.responseEnchanted(self)
    local cur_atts = self.m_tGameData["cur_atts"]
    local enchant_attrs = self.m_tGameData["enchant_attrs"]
    self.m_btn_save:setVisible(false)
    self.m_btn_enchanting:setVisible(true)
    self.m_btn_cancel:setVisible(false)
    self.m_btn_instroction:setVisible(true)
    self.m_label_add_anim_1:setVisible(false)
    self.m_label_add_anim_2:setVisible(false)
    --
    local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId)
    local enchantCfg = getConfig(game_config_field.enchant);
    -- cclog2(enchantCfg,"enchantCfg===-=====")
    local equip_enchant_cfg = enchantCfg:getNodeWithKey(tostring(itemCfg:getNodeWithKey("quality"):toInt()))
    local word_png = {  fire    = "word_fire_att",fire_dfs = "word_fire_def",
                            water   = "word_water_att",water_dfs = "word_water_def",
                            wind    = "word_wind_att",wind_dfs = "word_wind_def",
                            earth   = "word_soil_att",earth_dfs = "word_soil_def"
                         }
    
    local function delayTimeCallFunc()
        cclog("delayTimeCallFunc --------------------------")
        self:refreshTotalPiece()
        self:refreshEquipIcon()
        self:refreshSortTabBtn()

        self.m_label_add_anim_1:setVisible(false)
        self.m_label_add_anim_2:setVisible(false)

        local tempSpr_ ={}
        local i = 0 -- 计数 表示sprite的编号 1 2 
        for k,v in pairs(cur_atts) do
            tempSpr_ = word_png[k]
            i = i + 1
            local m_property_sprite_cur = self.m_ccbNode:spriteForName("m_property_sprite_cur_"..i)
            local m_property_label_curcount = self.m_ccbNode:labelTTFForName("m_property_label_curcount_"..i)
            local m_property_sprite_add = self.m_ccbNode:spriteForName("m_property_sprite_add_"..i)
            local m_property_label_addcount = self.m_ccbNode:spriteForName("m_property_label_addcount_"..i)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr_ .. ".png")
            if tempSpriteFrame then
                m_property_sprite_cur:setDisplayFrame( tempSpriteFrame )
                m_property_sprite_cur:setVisible(true)
                m_property_label_curcount:setString(tostring(v))
                m_property_label_curcount:setVisible(true)

                m_property_sprite_add:setDisplayFrame(tempSpriteFrame)
                m_property_sprite_add:setVisible(true)

                local equip_sort = itemCfg:getNodeWithKey("sort"):toInt()
                local rate_addcount = 0
                local atk_rate = equip_enchant_cfg:getNodeWithKey("atk_rate")
                local def_rate = equip_enchant_cfg:getNodeWithKey("def_rate")
                if equip_sort == 1 or equip_sort == 2 then
                    rate_addcount = atk_rate:getNodeAt(1):toInt()
                elseif equip_sort == 3 or equip_sort == 4 then
                    rate_addcount = def_rate:getNodeAt(1):toInt()
                end
                
                m_property_label_addcount:setString(tostring("+1~"..rate_addcount))
                m_property_label_addcount:setVisible(true)
                m_property_label_addcount:setColor(ccc3(255,255,255))


            else
                m_property_sprite_cur:setVisible(false)
                m_property_label_curcount:setVisible(false)
                m_property_sprite_add:setVisible(false)
                m_property_label_addcount:setVisible(false)
            end
        end
        self.m_anim_tag = true
    end

    self.m_anim_tag = false
    local tempSpr ={}
    local i = 0 -- 计数 表示sprite的编号 1 2 
    for k,v in pairs(enchant_attrs) do
        tempSpr = word_png[k]
        i = i + 1
        local m_label_add_anim = self.m_ccbNode:labelTTFForName("m_label_add_anim_"..i)
        
        local m_property_sprite_add = self.m_ccbNode:spriteForName("m_property_sprite_add_"..i)
        local m_property_label_addcount = self.m_ccbNode:labelTTFForName("m_property_label_addcount_"..i)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr .. ".png")
        if tempSpriteFrame then
            m_label_add_anim:setString(tostring("+"..v))
            m_label_add_anim:setVisible(true)
            m_property_sprite_add:setDisplayFrame(tempSpriteFrame)
            m_property_sprite_add:setVisible(true)
            m_property_label_addcount:setString(tostring("+"..v))
            m_property_label_addcount:setVisible(true)
            m_property_label_addcount:setColor(ccc3(65,255,34))
        
            local tempSize = m_label_add_anim:getParent():getContentSize()
            local function remove_node(node)
                node:removeAllChildrenWithCleanup(true);
                -- node:removeFromParentAndCleanup(true)
                m_label_add_anim:setPosition(ccp(tempSize.width*0.8,tempSize.height*0.5))
            end
            local arr = CCArray:create();
            arr:addObject(CCMoveTo:create(0.2,ccp(tempSize.width*0.8,tempSize.height*0.5+10)));
            arr:addObject(CCDelayTime:create(0.5));
            arr:addObject(CCCallFuncN:create(remove_node));
            m_label_add_anim:runAction(CCSequence:create(arr));

        else
            m_label_add_anim:setVisible(false)
            m_property_sprite_add:setVisible(false)
            m_property_label_addcount:setVisible(false)
        end
    end

    local animArr = CCArray:create()
    animArr:addObject(CCDelayTime:create(0.7))
    animArr:addObject(CCCallFuncN:create(delayTimeCallFunc))
    self.m_node_curProperty:runAction(CCSequence:create(animArr))
end
--[[--
    装备附魔 
    初始附魔：获得随机数 add_node,btn_save:show 
]]
function equip_enchanting.responseInitEnchant( self )
    local enchant_attrs = self.m_tGameData["enchant_attrs"]
    -- cclog2(enchant_attrs,"enchant_attrs")
    -- 初始附魔
    self.m_btn_save:setVisible(true)
    self.m_btn_enchanting:setVisible(false)
    self.m_btn_cancel:setVisible(true)
    self.m_btn_instroction:setVisible(false)

    self.m_property_sprite_add_1:setVisible(false)
    self.m_property_sprite_add_2:setVisible(false)
    self.m_property_label_addcount_1:setVisible(false)
    self.m_property_label_addcount_2:setVisible(false)

    local word_png = {  fire    = "word_fire_att",fire_dfs = "word_fire_def",
                            water   = "word_water_att",water_dfs = "word_water_def",
                            wind    = "word_wind_att",wind_dfs = "word_wind_def",
                            earth   = "word_soil_att",earth_dfs = "word_soil_def"
                         }
    local tempSpr ={}
    -- local spriteTable = {self.m_property_sprite_add_1,self.m_property_sprite_add_2}
    local i = 0 -- 计数 表示sprite的编号 1 2 
    for k,v in pairs(enchant_attrs) do
        tempSpr = word_png[k] 
        cclog2(tempSpr,"tempSpr")
        i = i + 1
        -- local m_property_sprite_cur = self.m_ccbNode:spriteForName("m_property_sprite_cur_"..i)
        -- local m_property_label_curcount = self.m_ccbNode:labelTTFForName("m_property_label_curcount_"..i)
        local m_property_sprite_add = self.m_ccbNode:spriteForName("m_property_sprite_add_"..i)
        -- local m_property_sprite_add = spriteTable[i]
        cclog2(m_property_sprite_add,"m_property_sprite_add")
        local m_property_label_addcount = self.m_ccbNode:spriteForName("m_property_label_addcount_"..i)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr .. ".png")
        
        cclog2(tempSpriteFrame,"tempSpriteFrame")
        if tempSpriteFrame then
            self.m_sprite_instroction:setVisible(false)
            self.m_node_property_add:setVisible(true)
            m_property_sprite_add:setVisible(true)
            m_property_sprite_add:setDisplayFrame(tempSpriteFrame)
            m_property_label_addcount:setString(tostring("+"..v))
            m_property_label_addcount:setVisible(true)
        else
            m_property_sprite_add:setVisible(false)
            m_property_label_addcount:setVisible(false)

        end
    end
    self:refreshTotalPiece()
end

--[[--
    
]]
function equip_enchanting.responseSuccessSaved( self )
    -- 先加一个粒子效果
    -- 后端 返回该装备总的属性及值
    
    local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId)
    -- cclog2(itemData,"itemData===")
    -- cclog2(itemCfg,"======itemCfg======")
    local enchantCfg = getConfig(game_config_field.enchant);
    -- cclog2(enchantCfg,"enchantCfg=====")
    local equip_enchant_cfg = enchantCfg:getNodeWithKey(tostring(itemCfg:getNodeWithKey("quality"):toInt()))

    local cur_atts = self.m_tGameData["cur_atts"]
    cclog2(cur_atts,"cur_atts===========")
    -- local enchant_attrs = self.m_tGameData["enchant_attrs"]
    -- cclog2(enchant_attrs,"enchant_attrs=====")
    
    self.m_label_add_anim_1:setVisible(false)
    self.m_label_add_anim_2:setVisible(false)


    local word_png = {  fire    = "word_fire_att",fire_dfs = "word_fire_def",
                        water   = "word_water_att",water_dfs = "word_water_def",
                        wind    = "word_wind_att",wind_dfs = "word_wind_def",
                        earth   = "word_soil_att",earth_dfs = "word_soil_def"
                     }
    
    local function delayTimeCallFunc( )
        self:refreshTotalPiece()
        self:refreshEquipTableView()
        self:refreshEquipIcon()

        self.m_btn_save:setVisible(false)
        self.m_btn_enchanting:setVisible(true)
        self.m_btn_cancel:setVisible(false)
        self.m_btn_instroction:setVisible(true)

        self.m_node_property_add:setVisible(true)
        self.m_property_sprite_cur_2:setVisible(false)
        self.m_property_sprite_cur_1:setVisible(false)
        self.m_property_label_curcount_1:setVisible(false)
        self.m_property_label_curcount_2:setVisible(false)
        self.m_label_curProperty_nil_1:setVisible(false)
        self.m_label_curProperty_nil_2:setVisible(false)

        self.m_property_sprite_add_1:setVisible(false)
        self.m_property_sprite_add_2:setVisible(false)
        self.m_property_label_addcount_1:setVisible(false)
        self.m_property_label_addcount_2:setVisible(false)
        self.m_sprite_instroction:setVisible(false)

        self.m_label_add_anim_1:setVisible(false)
        self.m_label_add_anim_2:setVisible(false)

        local tempSpr ={}
        local i = 0 -- 计数 表示sprite的编号 1 2 
        for k,v in pairs(cur_atts) do
            tempSpr = word_png[k] 
            i = i + 1
            local m_property_sprite_cur = self.m_ccbNode:spriteForName("m_property_sprite_cur_"..i)
            local m_property_label_curcount = self.m_ccbNode:labelTTFForName("m_property_label_curcount_"..i)
            local m_property_sprite_add = self.m_ccbNode:spriteForName("m_property_sprite_add_"..i)
            local m_property_label_addcount = self.m_ccbNode:spriteForName("m_property_label_addcount_"..i)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr .. ".png")
            if tempSpriteFrame then
                cclog2(tempSpriteFrame,"if tempSpriteFrame then")
                m_property_sprite_cur:setDisplayFrame( tempSpriteFrame )
                m_property_sprite_cur:setVisible(true)
                m_property_label_curcount:setString(tostring(v))
                m_property_label_curcount:setVisible(true)

                m_property_sprite_add:setDisplayFrame(tempSpriteFrame)
                m_property_sprite_add:setVisible(true)

                local equip_sort = itemCfg:getNodeWithKey("sort"):toInt()
                local rate_addcount = 0
                local atk_rate = equip_enchant_cfg:getNodeWithKey("atk_rate")
                local def_rate = equip_enchant_cfg:getNodeWithKey("def_rate")
                if equip_sort == 1 or equip_sort == 2 then
                    rate_addcount = atk_rate:getNodeAt(1):toInt()
                elseif equip_sort == 3 or equip_sort == 4 then
                    rate_addcount = def_rate:getNodeAt(1):toInt()
                end
                
                m_property_label_addcount:setString(tostring("+1~"..rate_addcount))
                m_property_label_addcount:setVisible(true)

            else
                m_property_sprite_cur:setVisible(false)
                m_property_label_curcount:setVisible(false)
                m_property_sprite_add:setVisible(false)
                m_property_label_addcount:setVisible(false)
            end
        end
        self.m_anim_tag = true
    end 

    self.m_anim_tag = false
    local tempSpr ={}
    local i = 0 -- 计数 表示sprite的编号 1 2 
    for k,v in pairs(cur_atts) do
        tempSpr = word_png[k] 
        i = i + 1
        local m_label_add_anim = self.m_ccbNode:labelTTFForName("m_label_add_anim_"..i)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr .. ".png")
        if tempSpriteFrame then
            m_label_add_anim:setString(tostring("+"..v))
            m_label_add_anim:setVisible(true)

            local tempSize = m_label_add_anim:getParent():getContentSize()
            local function remove_node(node)
                node:removeAllChildrenWithCleanup(true);
                -- node:removeFromParentAndCleanup(true)
                m_label_add_anim:setPosition(ccp(tempSize.width*0.8,tempSize.height*0.5))
            end
            local arr = CCArray:create();
            arr:addObject(CCMoveTo:create(0.2,ccp(tempSize.width*0.8,tempSize.height*0.5+10)));
            arr:addObject(CCDelayTime:create(0.5));
            arr:addObject(CCCallFuncN:create(remove_node));
            m_label_add_anim:runAction(CCSequence:create(arr));
        else
            m_label_add_anim:setVisible(false)
        end
    end
    local animArr = CCArray:create()
    animArr:addObject(CCDelayTime:create(0.7))
    animArr:addObject(CCCallFuncN:create(delayTimeCallFunc))
    self.m_node_curProperty:runAction(CCSequence:create(animArr))
end

--[[--
    取消保存 响应
]]
function equip_enchanting.responseSuccessCancel( self )
    
    self.m_btn_save:setVisible(false)
    self.m_btn_enchanting:setVisible(true)
    self.m_btn_instroction:setVisible(true)
    self.m_btn_cancel:setVisible(false)

    self.m_sprite_instroction:setVisible(true)
    self.m_property_sprite_add_1:setVisible(false)
    self.m_property_sprite_add_2:setVisible(false)
    self.m_property_label_addcount_1:setVisible(false)
    self.m_property_label_addcount_2:setVisible(false)
end

--[[--
    按下btn tableview refresh:property,EquipIcon
]]
function equip_enchanting.refreshTableViewPropertyInfo( self,equipId )
    
    self:refreshEquipIcon()

    self.m_selEquipId = equipId 
    if equipId ~= nil and equipId ~= "-1" then

        local itemData,itemCfg = game_data:getEquipDataById(self.m_selEquipId)
        -- cclog2(itemData,"itemData===")
        -- cclog2(itemCfg,"itemCfg======")
        local enchantCfg = getConfig(game_config_field.enchant);
        -- cclog2(enchantCfg,"enchantCfg=====")
        local equip_enchant_cfg = enchantCfg:getNodeWithKey(tostring(itemCfg:getNodeWithKey("quality"):toInt()))
        -- cclog2(equip_enchant_cfg,"equip_enchant_cfg======")
        
        local need_piece = equip_enchant_cfg:getNodeWithKey("piece"):toInt()
        cclog2(need_piece,"need_piece")
        self.m_label_piece_cost:setString(tostring(need_piece))

        local is_enchant = itemData.is_enchant
        local atts = itemData.atts
        cclog2(is_enchant,"is_enchant===")
        -- cclog2(atts,"atts===")
        if is_enchant then -- 已附魔
            --换按钮显示
            self.m_btn_canel:setVisible(true)
            self.m_btn_instroction:setVisible(false)

            self.m_property_sprite_cur_2:setVisible(false)
            self.m_property_sprite_cur_1:setVisible(false)
            self.m_property_label_curcount_1:setVisible(false)
            self.m_property_label_curcount_2:setVisible(false)
            self.m_property_sprite_add_1:setVisible(false)
            self.m_property_sprite_add_2:setVisible(false)
            self.m_property_label_addcount_1:setVisible(false)
            self.m_property_label_addcount_2:setVisible(false)
            
            self.m_node_property_add:setVisible(true)
            self.m_label_curProperty_nil_1:setVisible(false)
            self.m_label_curProperty_nil_2:setVisible(false)
            self.m_sprite_instroction:setVisible(false)

            local word_png = {  fire    = "word_fire_att",fire_dfs = "word_fire_def",
                                water   = "word_water_att",water_dfs = "word_water_def",
                                wind    = "word_wind_att",wind_dfs = "word_wind_def",
                                earth   = "word_soil_att",earth_dfs = "word_soil_def"
                             }
            local tempSpr ={}
            local i = 0 -- 计数 表示sprite的编号 1 2 
            for k,v in pairs(atts) do
                tempSpr = word_png[k]
                i = i + 1
                local m_property_sprite_cur = self.m_ccbNode:spriteForName("m_property_sprite_cur_"..i)
                local m_property_label_curcount = self.m_ccbNode:labelTTFForName("m_property_label_curcount_"..i)
                local m_property_sprite_add = self.m_ccbNode:spriteForName("m_property_sprite_add_"..i)
                local m_property_label_addcount = self.m_ccbNode:spriteForName("m_property_label_addcount_"..i)
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tempSpr .. ".png")
                if tempSpriteFrame then
                    m_property_sprite_cur:setDisplayFrame( tempSpriteFrame )
                    m_property_sprite_cur:setVisible(true)
                    m_property_label_curcount:setString(tostring(v))
                    m_property_label_curcount:setVisible(true)

                    m_property_sprite_add:setDisplayFrame(tempSpriteFrame)
                    m_property_sprite_add:setVisible(true)
                    -- m_property_label_addcount:setString(tostring(v))
                    local equip_sort = itemCfg:getNodeWithKey("sort"):toInt()
                    local rate_addcount = 0
                    -- if equip_sort == 1 or equip_sort == 2 then
                    --     rate_addcount = equip_enchant_cfg:getNodeWithKey("atk_rate"):toInt()
                    -- elseif equip_sort == 3 or equip_sort == 4 then
                    --     rate_addcount = equip_enchant_cfg:getNodeWithKey("def_rate"):toInt()
                    -- end
                    local atk_rate = equip_enchant_cfg:getNodeWithKey("atk_rate")
                    local def_rate = equip_enchant_cfg:getNodeWithKey("def_rate")
                    cclog2(atk_rate,"atk_rate")
                    cclog2(def_rate,"def_rate")
                    if equip_sort == 1 or equip_sort == 2 then
                        rate_addcount = atk_rate:getNodeAt(1):toInt()
                    elseif equip_sort == 3 or equip_sort == 4 then
                        rate_addcount = def_rate:getNodeAt(1):toInt()
                    end

                    m_property_label_addcount:setString(tostring("+1~"..rate_addcount))
                    m_property_label_addcount:setVisible(true)

                else
                    m_property_sprite_cur:setVisible(false)
                    m_property_label_curcount:setVisible(false)
                    m_property_sprite_add:setVisible(false)
                    m_property_label_addcount:setVisible(false)
                end
            end
        else  -- 未附魔 刷新
            self.m_btn_canel:setVisible(false)
            self.m_btn_instroction:setVisible(true)
            cclog("====is_enchant == false====")
            self.m_label_curProperty_nil_1:setVisible(true)
            self.m_label_curProperty_nil_2:setVisible(true)
            self.m_sprite_instroction:setVisible(true)
            -- self.m_property_sprite_cur_1:getParent():setVisible(false)
            -- self.m_property_sprite_cur_2:getParent():setVisible(false)
            self.m_property_sprite_cur_2:setVisible(false)
            self.m_property_sprite_cur_1:setVisible(false)
            self.m_property_label_curcount_1:setVisible(false)
            self.m_property_label_curcount_2:setVisible(false)

            self.m_node_property_add:setVisible(false)
            self.m_btn_save:setVisible(false)
            self.m_btn_enchanting:setVisible(true)
        end
    else
        -- 没有选择装备
        self.m_label_curProperty_nil_1:setVisible(true)
        self.m_label_curProperty_nil_2:setVisible(true)
        -- self.m_property_sprite_cur_1:getParent():setVisible(false)
        -- self.m_property_sprite_cur_2:getParent():setVisible(false)
        self.m_property_sprite_cur_2:setVisible(false)
        self.m_property_sprite_cur_1:setVisible(false)
        self.m_property_label_curcount_1:setVisible(false)
        self.m_property_label_curcount_2:setVisible(false)

        self.m_node_property_add:setVisible(false)
        self.m_sprite_instroction:setVisible(true)

        self.m_btn_canel:setVisible(false)
        self.m_btn_instroction:setVisible(true)
    end
end



--[[--
    刷新装备列表
]]
function equip_enchanting.refreshEquipTableView(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_selEquipDataTab = game_data:getEquipIdTable();
    -- cclog2(self.m_selEquipDataTab,"self.m_selEquipDataTab=============")
    self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize(),self.m_selEquipDataTab);
    self.m_list_view_bg:addChild(self.m_tableView);

    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
end


--[[--

]]
function equip_enchanting.refreshSortTabBtn(self,sortIndex)
    self.m_selSortIndex = sortIndex;
    local tempBtn = nil;
    for i=1,4 do
        tempBtn = self.m_ccbNode:controlButtonForName("m_table_tab_btn_" .. i)
        tempBtn:setHighlighted(self.m_selSortIndex == i);
        tempBtn:setEnabled(self.m_selSortIndex ~= i);
    end
    self:refreshEquipTableView()
end


--[[--
    刷新 equip_icon_
]]
function equip_enchanting.refreshEquipIcon(self)
    self.m_anim_node:removeAllChildrenWithCleanup(true)
    if self.m_selEquipId ~= nil then
        local itemData,equip_item_cfg = game_data:getEquipDataById(self.m_selEquipId)
        self.m_tips_spr_1:setVisible(false);
        -- 装备icon tips
        local animNode = game_util:createEquipItemByCCB(itemData)  -- 自己写一个
        -- local animNode = game_util:createEquipItemByCCB3(itemData)

        self.m_anim_node:addChild(animNode,20,20) 
    else
        self.m_tips_spr_1:setVisible(true);
    end
    -- if #self.m_selEquipDataTab == 0 then
    -- else
    -- end
end

--[[--
    refresh total_piece
]]
function equip_enchanting.refreshTotalPiece( self )
    local piece_total = game_data:getUserStatusDataByKey("enchant") or 0 -- 从后端获取
    local value,unit = game_util:formatValueToString(piece_total)
    self.m_label_piece_total:setString(value..unit)
end

--[[--
    刷新ui
]]
function equip_enchanting.refreshUi(self)

    self:refreshSortTabBtn()
    self:refreshTotalPiece()
    self:refreshTableViewPropertyInfo(self.m_selEquipId)
end
--[[--
    初始化
]]
function equip_enchanting.init(self,t_params)
    t_params = t_params or {};
    cclog2(t_params,"t_params===")

    self.is_enchant = false
    self.m_tGameData = {}
    self.m_selEquipId = t_params.selEquipId;

    -- self.m_curPage = 1;
    -- self.m_material_node_tab = {};
    -- self.m_materialDataTable = {};
    self.m_selEquipDataTab = {};
    local selSort = game_data:getEquipSortType();
    for k,v in pairs(EQUIP_SORT_TAB) do
        if v.sortType == selSort then
            self.m_selSortIndex = k;
            break;
        end
    end
    self.m_selSortIndex = self.m_selSortIndex or 1;

    self.m_anim_tag = t_params.m_anim_tag or true
end

--[[--
    创建ui入口并初始化数据
]]
function equip_enchanting.create(self,t_params)
    -- body
    self:init(t_params);
    local uiNode = self:createUi();
    self:refreshUi();

    return uiNode;
end

return equip_enchanting;
