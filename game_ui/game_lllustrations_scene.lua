---  图鉴列表

local game_lllustrations_scene = {
    m_title_label = nil,
    m_list_view_bg = nil,
    m_back_btn = nil,
    m_sort_btn = nil,
    m_tableView = nil,
    m_curPage = nil,
    m_ownBookTab = nil,
    m_num_label = nil,

    m_isInitCharacter = nil,
    m_isInitEquip = nil,
    m_regain_city = nil,
    m_sprite_showNums = nil, -- 显示数量
    m_myOwnEquipBooks = nil,
    m_equipInfo = nil,
};
--[[--
    销毁ui
]]
function game_lllustrations_scene.destroy(self)
    -- body
    cclog("-----------------game_lllustrations_scene destroy-----------------");
    self.m_title_label = nil;
    self.m_list_view_bg = nil;
    self.m_back_btn = nil;
    self.m_sort_btn = nil;
    self.m_tableView = nil;
    self.m_curPage = nil;
    self.m_ownBookTab = nil;
    self.m_num_label = nil;
    self.m_sprite_showNums = nil;
    self.m_isInitCharacter = nil;
    self.m_regain_city = nil;
    self.m_isInitEquip = nil;
    self.m_equipInfo = nil;
    self.m_myOwnEquipBooks = nil;
end
--[[--
    返回
]]
function game_lllustrations_scene.back(self,backType)
    if self.isPop == true then
        game_scene:removePopByName("game_lllustrations_scene");
        return
    end
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_lllustrations_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("game_lllustrations_scene ", " click btn and tag == ", btnTag)
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then

        elseif btnTag == 101 then
            self.m_cur_showType = "character"
            self:refreshUi()
        elseif btnTag == 102 then
            self.m_cur_showType = "equip"
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_lllustrations.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");--
    self.m_back_btn = ccbNode:controlButtonForName("m_back_btn")
    -- self.m_sort_btn = ccbNode:controlButtonForName("m_sort_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);
    self.m_num_label = ccbNode:labelBMFontForName("m_num_label")
    self.m_sprite_showNums = ccbNode:spriteForName("m_sprite_showNums")


    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_conbtn_switchCha = ccbNode:controlButtonForName("m_conbtn_switch1")  -- 伙伴图鉴
    game_util:setControlButtonTitleBMFont(self.m_conbtn_switchCha)
    self.m_conbtn_switchCha:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    game_util:setCCControlButtonTitle(self.m_conbtn_switchCha,string_helper.ccb.text164)


    self.m_conbtn_switchEqu = ccbNode:controlButtonForName("m_conbtn_switch2")  -- 装备图鉴
    game_util:setControlButtonTitleBMFont(self.m_conbtn_switchEqu)
    self.m_conbtn_switchEqu:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    game_util:setCCControlButtonTitle(self.m_conbtn_switchEqu,string_helper.ccb.text165)
    return ccbNode;
end

--[[--
    创建伙伴列表
]]
function game_lllustrations_scene.createCharacterTableView(self,viewSize)
    -- local showDataTable = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    self.m_sprite_showNums:setVisible(true)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_lllustrations_res.plist")
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local character_book_cfg = getConfig(game_config_field.character_book);

    local itemsCount = character_book_cfg:getNodeCount()--#showDataTable
    self.m_num_label:setString(game_util:getTableLen(self.m_ownBookTab) .. "/" .. itemsCount)
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 6; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local itemBg = CCSprite:createWithSpriteFrameName("tujian_diban.png");
            itemBg:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(itemBg,10,10);
            local noLable = game_util:createLabelBMFont({text = "NO.1",color = ccc3(186, 70, 21)})
            noLable:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.25))
            cell:addChild(noLable,11,11)
        end
        if cell then
            local itemBg = tolua.cast(cell:getChildByTag(10),"CCSprite");
            local noLable = tolua.cast(cell:getChildByTag(11),"CCLabelBMFont");
            itemBg:removeAllChildrenWithCleanup(true);
            local tempSize = itemBg:getContentSize();
            local character_book_item_cfg = character_book_cfg:getNodeAt(index)
            noLable:setString("NO." .. character_book_item_cfg:getKey())
            local character_id = character_book_item_cfg:getNodeWithKey("character_id"):toStr()
            local itemCfg = character_detail_cfg:getNodeWithKey(character_id)
            if itemCfg then
                local is_see = character_book_item_cfg:getNodeWithKey("is_see"):toInt();
                if is_see == 1 then
                    local tempIcon = game_util:createCardIconByCfg(itemCfg)
                    if tempIcon then
                        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.65))
                        itemBg:addChild(tempIcon)
                        if self.m_ownBookTab[character_id] == nil then
                            tempIcon:setColor(ccc3(81,81,81))
                        end
                    end
                else
                    local tempIcon = CCSprite:createWithSpriteFrameName("tujian_kongwei.png");
                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.65))
                    itemBg:addChild(tempIcon)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            local character_book_item_cfg = character_book_cfg:getNodeAt(index)
            local character_id = character_book_item_cfg:getNodeWithKey("character_id"):toStr()
            local itemCfg = character_detail_cfg:getNodeWithKey(character_id)
            if itemCfg then
                local is_see = character_book_item_cfg:getNodeWithKey("is_see"):toInt();
                if is_see == 1 then
                    cclog("c_id ================ " .. itemCfg:getKey())
                    game_scene:addPop("game_hero_info_pop",{cId = itemCfg:getKey(),openType = 4,lllustrationsOpenFlag = (self.m_ownBookTab[character_id] ~= nil)})
                else
                    game_util:addMoveTips({text = string_helper.game_lllustrations_scene.text});
                end
            end
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    弹框
]]

function tipNotEnough(isEliteOpen, goto)
    local text = ""

    local chaT = ""
    if goto then
        local chapter_cfg = getConfig(game_config_field.chapter)
        for i=1,#goto do
            local itemCfg = chapter_cfg:getNodeWithKey(tostring(goto[i]))
            print(" itemCfg  info is == ", itemCfg:getFormatBuffer())
            local name = itemCfg:getNodeWithKey("chapter_name"):toStr()
            local space = i==1 and "" or " "
            chaT = chaT .. space .. name
        end
    end

    if isEliteOpen then
        text = "" .. chaT .. string_helper.game_lllustrations_scene.not_open .. chaT .. string_helper.game_lllustrations_scene.dw
    else
        text = string_helper.game_lllustrations_scene.sp_equip .. chaT .. string_helper.game_lllustrations_scene.dw
    end
    local t_params = 
                    {
                        title = string_helper.game_lllustrations_scene.sd,
                        okBtnCallBack = function(target,event)
                            require("game_ui.game_pop_up_box").close(); 
                        end,   --可缺省
                        text = text,
                        onlyOneBtn = true,          --可缺省
                    }
    require("game_ui.game_pop_up_box").show(t_params);
    -- require("game_ui.game_pop_up_box").showAlertView(msg or "等级不足，升级后解锁新功能");
end

--[[--
    创建装备列表
]]
function game_lllustrations_scene.createEquipTableView(self,viewSize)
    print("game_lllustrations_scene ", " -- createEquipTableView -- ")
    -- local showDataTable = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    self.m_sprite_showNums:setVisible(true) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_lllustrations_res.plist")
    local equip_detail_cfg = getConfig(game_config_field.equip);
    if not self.m_equipInfo then
        local equip_book_cfg = getConfig(game_config_field.equip_book);
        local tempTabel = {}
        local tt = equip_book_cfg and json.decode(equip_book_cfg:getFormatBuffer()) or {}
        -- print("temp Table is ", json.encode(tt))
        local count = equip_book_cfg:getNodeCount() 
        for i=1,count do
            local temp = equip_book_cfg:getNodeAt(i - 1)
            tempTabel[#tempTabel + 1] = json.decode(temp:getFormatBuffer())
        end

        local sortFun = function ( data1, data2 )
            return  data1.sort < data2.sort
        end
        table.sort( tempTabel, sortFun )
        -- print("temp Table is ", json.encode(tempTabel))
        self.m_equipInfo = tempTabel
    end  

    -- print("self.m_myOwnEquipBooks  === ", json.encode(self.m_myOwnEquipBooks), "num == ", game_util:getTableLen(self.m_myOwnEquipBooks))
    self.m_num_label:setString(game_util:getTableLen(self.m_myOwnEquipBooks) .. "/" .. #self.m_equipInfo)
    -- local itemsCount = equip_book_cfg:getNodeCount()--#showDataTable
    local itemsCount = #self.m_equipInfo
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 6; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_curPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 

        local info = self.m_equipInfo[index + 1]
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local itemBg = CCSprite:createWithSpriteFrameName("tujian_diban.png");
            itemBg:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.5))
            cell:addChild(itemBg,10,10);
            local noLable = game_util:createLabelBMFont({text = "NO.1",color = ccc3(186, 70, 21)})
            noLable:setPosition(ccp(itemSize.width*0.5, itemSize.height*0.25))
            cell:addChild(noLable,11,11)
        end
        if cell then
            local itemBg = tolua.cast(cell:getChildByTag(10),"CCSprite");
            local noLable = tolua.cast(cell:getChildByTag(11),"CCLabelBMFont");
            itemBg:removeAllChildrenWithCleanup(true);
            local tempSize = itemBg:getContentSize();
            -- local equip_book_item_cfg = equip_book_cfg:getNodeAt(index)
            -- noLable:setString("NO." .. equip_book_item_cfg:getNodeWithKey("sort"):toInt())
            -- local equip_id = equip_book_item_cfg:getNodeWithKey("equip_id"):toStr()

            noLable:setString("NO." .. tostring(info.sort))
            local equip_id = info.equip_id

            -- local itemCfg = equip_detail_cfg:getNodeWithKey(equip_id)
            -- if itemCfg then
                -- local is_see = equip_book_item_cfg:getNodeWithKey("is_see"):toInt();
                local is_see = info.is_see;

                if is_see == 1 then
                    -- local icon = game_util:createEquipIcon(itemCfg)
                    -- local icon = game_util:createEquipIcon(itemCfg)
                    local icon = game_util:createEquipIconByCid(info.equip_id)
                    if icon then
                        icon:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.65));
                        -- self.m_icon_spr:addChild(icon)
                        itemBg:addChild(icon)
                        if self.m_myOwnEquipBooks[tostring(info.equip_id)] == nil then
                            icon:setColor(ccc3(81,81,81))
                            local tempBg = tolua.cast(icon:getChildByTag(1),"CCSprite")
                            if tempBg then
                                tempBg:setColor(ccc3(81,81,81))
                            end
                        end
                    end
                else
                    local tempIcon = CCSprite:createWithSpriteFrameName("tujian_kongwei.png");
                    tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.65))
                    itemBg:addChild(tempIcon)
                end
            -- end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
        if index >= itemsCount then return end;
        if eventType == "ended" and item then
            -- local equip_book_item_cfg = equip_book_cfg:getNodeAt(index)
            -- local equip_id = equip_book_item_cfg:getNodeWithKey("equip_id"):toStr()
            -- local itemCfg = equip_detail_cfg:getNodeWithKey(equip_id)
            local equipData = {lv = 1,c_id = self.m_equipInfo[index + 1].equip_id or 10101,id = -1,pos = -1}
            -- if itemCfg:getKey() then
            --     equipData.c_id = tonumber( itemCfg:getKey() ) 
            -- end
            game_scene:addPop("game_equip_info_pop",{tGameData = equipData,openType = 11})
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    刷新ui
]]
function game_lllustrations_scene.refreshUi(self)


    local flag1 = self.m_cur_showType == "character" and true or false
    local flag2 = self.m_cur_showType == "equip" and true or false

    self.m_conbtn_switchCha :setHighlighted(flag1);
    self.m_conbtn_switchCha:setEnabled(not flag1);
    self.m_conbtn_switchEqu:setHighlighted(flag2);
    self.m_conbtn_switchEqu:setEnabled(not flag2);

    if self.m_cur_showType == "character" and self.m_isInitCharacter then   -- 显示伙伴图鉴
        self.m_tableView = self:createCharacterTableView(self.m_list_view_bg:getContentSize());
    elseif self.m_cur_showType == "character" then  -- 显示伙伴图鉴 但是没有请求数据
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data");
                self.m_ownBookTab = json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
                self.m_isInitCharacter = true
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_books"), http_request_method.GET, nil,"cards_books")
    -- elseif self.m_cur_showType == "equip" and self.m_isInitEquip then
    elseif self.m_cur_showType == "equip" and self.m_myOwnEquipBooks then  -- 显示装备图鉴
        self.m_tableView = self:createEquipTableView(self.m_list_view_bg:getContentSize());

    elseif self.m_cur_showType == "equip" and self.m_isInitEquip then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self.m_myOwnEquipBooks = data:getNodeWithKey("books") and json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
            self:refreshUi()
            self.m_isInitEquip = true
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_books"), http_request_method.GET, nil,"equip_books")
    end
    if self.m_tableView then 
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        self.m_list_view_bg:addChild(self.m_tableView);
    end
end

--[[--
    初始化
]]
function game_lllustrations_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_ownBookTab = {};
    self.m_cur_showType = t_params.showType or "character"

    if self.m_cur_showType == "character" then
        if t_params.gameData then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_ownBookTab = json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
        end
    elseif self.m_cur_showType == "equip" then
        if t_params.gameData then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_myOwnEquipBooks = data:getNodeWithKey("books") and json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
        end
        self.m_isInitEquip = true
    end

    if t_params.showType == "character" then
        self.m_isInitCharacter = true
    elseif t_params.showType == "equip" then
        self.m_isInitEquip = true
    end
    self.isPop = t_params.isPop
    local dat = game_data:getChapterTabByKey("openDifficult")
    print("  ----- openDifficult character is ", json.encode(dat))
end

--[[--
    创建ui入口并初始化数据
]]
function game_lllustrations_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_lllustrations_scene;