---  图鉴列表

local game_superillustration_scene = {
    m_list_view_bg = nil,
    m_back_btn = nil,
    m_equipInfoExchange = nil,

    m_cur_showtype = nil,

    m_characterExData = nil,
    m_equipExData = nil,

    m_equipInfo = nil,

    m_selEquipPage = nil,
    m_selCharacterPage = nil,
};
--[[--
    销毁ui
]]
function game_superillustration_scene.destroy(self)
    -- body
    cclog("-----------------game_superillustration_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_back_btn = nil;
    self.m_equipInfoExchange = nil

    self.m_characterExData = nil;
    self.m_equipExData = nil;

    self.m_equipBooks = nil;
    self.m_chacterBooks = nil;

    self.m_cur_showtype = nil;
    self.m_equipInfo = nil;


    self.m_selEquipPage = nil;
    self.m_selCharacterPage = nil;
end
--[[--
    返回
]]
function game_superillustration_scene.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_superillustration_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("game_superillustration_scene ", " click btn and tag == ", btnTag)
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then

        elseif btnTag == 11 then
            self.m_cur_showType = "character"
            self:refreshUi()
        elseif btnTag == 12 then
            self.m_cur_showType = "equip"
            self:refreshUi()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_exchange_reward_scene.ccbi");
    self.m_list_view_bg = ccbNode:nodeForName("m_node_lishboard");--
    self.m_back_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_back_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6);

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 5,true);
    self.m_root_layer:setTouchEnabled(true);

    self.m_conbtn_switchCha = ccbNode:controlButtonForName("m_tab_btn_1")  -- 伙伴图鉴
    game_util:setControlButtonTitleBMFont(self.m_conbtn_switchCha)
    self.m_conbtn_switchCha:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    game_util:setCCControlButtonTitle(self.m_conbtn_switchCha,string_helper.ccb.text164)

    self.m_conbtn_switchEqu = ccbNode:controlButtonForName("m_tab_btn_2")  -- 装备图鉴
    game_util:setControlButtonTitleBMFont(self.m_conbtn_switchEqu)
    self.m_conbtn_switchEqu:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
    game_util:setCCControlButtonTitle(self.m_conbtn_switchEqu,string_helper.ccb.text165)
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_superillustration_scene.refreshUi(self)


    local flag1 = self.m_cur_showType == "character" and true or false
    local flag2 = self.m_cur_showType == "equip" and true or false

    self.m_conbtn_switchCha :setHighlighted(flag1);
    self.m_conbtn_switchCha:setEnabled(not flag1);
    self.m_conbtn_switchEqu:setHighlighted(flag2);
    self.m_conbtn_switchEqu:setEnabled(not flag2);

    if self.m_cur_showType == "character" and self.m_characterInfo.init then   -- 显示伙伴图鉴
        self.m_tableView = self:createCharacterExchangeTableView(self.m_list_view_bg:getContentSize(), self.m_characterExData);
    elseif self.m_cur_showType == "character" then  -- 显示伙伴图鉴 但是没有请求数据
        local function responseMethod(tag,gameData)
            if gameData then
                local data = gameData:getNodeWithKey("data");
                self.m_characterInfo.books = data:getNodeWithKey("books") and json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
                self.m_characterInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
                self.m_characterInfo.init = true
                self:refreshUi()
            end
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("show_character_options"), http_request_method.GET, nil,"show_character_options")
    -- elseif self.m_cur_showType == "equip" and self.m_isInitEquip then
    elseif self.m_cur_showType == "equip" and self.m_equipInfo.init then  -- 显示装备图鉴
        self.m_tableView = self:createEquipExchangeTableView(self.m_list_view_bg:getContentSize(), self.m_equipExData);

    elseif self.m_cur_showType == "equip" and not self.m_myOwnEquipBooks then
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data");
            self.m_equipInfo.books = data:getNodeWithKey("books") and json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
            self.m_equipInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
            self.m_equipInfo.init = true
            self:refreshUi()
        end
        -- show_equip_options
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("show_equip_options"), http_request_method.GET, nil,"show_equip_options")
    end
    if self.m_tableView then 
        self.m_list_view_bg:removeAllChildrenWithCleanup(true);
        self.m_list_view_bg:addChild(self.m_tableView);
        self.m_tableView = nil
    end
end


--[[--
    创建卡牌列表
]]
function game_superillustration_scene.createCharacterExchangeTableView(self,viewSize, data)
    print("game_superillustration_scene ", " -- createEquipTableView -- ")
    -- local showDataTable = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_lllustrations_res.plist")
    if data.init ~= true then return end
    local tInfoData = data.data
    local onCellBtnClick = function ( target, event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
            self.m_characterInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or self.m_characterInfo.exchange_log
            self:refreshUi()
            cclog2(gameData, " gameData ")
        end
        local itemdata = self.m_characterExData.data[btnTag]
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("book_character_exchange"), http_request_method.GET, {id = itemdata.id},"book_character_exchange")
        -- body
    end

    local itemsCount = #tInfoData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_selCharacterPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_exchange_reward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            cell:addChild(ccbNode, 10, 10)

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            self:initCellUi(ccbNode, index, tInfoData, self.m_characterInfo)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_selCharacterPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end


--[[--
    创建装备列表
]]
function game_superillustration_scene.createEquipExchangeTableView(self,viewSize, data)
    print("game_superillustration_scene ", " -- createEquipTableView -- ")
    -- local showDataTable = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_lllustrations_res.plist")

    if data.init ~= true then return end
    local tInfoData = data.data
    local onCellBtnClick = function ( target, event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local function responseMethod(tag,gameData)
            local data = gameData:getNodeWithKey("data")
            game_util:rewardTipsByJsonData(data:getNodeWithKey("reward"));
            self.m_equipInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or self.m_equipInfo.exchange_log
            self:refreshUi()
        end
        local itemdata = self.m_equipExData.data[btnTag]
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("book_equip_exchange"), http_request_method.GET, {id = itemdata.id  },"book_equip_exchange")
        -- body
    end

    local itemsCount = #tInfoData
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-6;
    params.totalItem = itemsCount;
    params.showPageIndex = self.m_selEquipPage;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()

            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_exchange_reward_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
            cell:addChild(ccbNode, 10, 10)

        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10), "luaCCBNode")
            self:initCellUi(ccbNode, index, tInfoData, self.m_equipInfo)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_selEquipPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end



--[[--
    更新cell信息
]]
function game_superillustration_scene.initCellUi( self, ccbNode, index, showInfoData, dataInfo )
    local onBtnCilck = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local cellIndex = math.floor(btnTag / 10)
        local itemIndex = math.floor(btnTag % 10) 
        local info = showInfoData[cellIndex + 1].need_item[itemIndex]
        game_util:lookItemDetal(info)
    end
    local onRewardBtnCilck = function ( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local index = math.floor(btnTag / 10000)
        local count = math.floor(btnTag % 10000)
        if count > 1 then
            game_scene:addPop("game_superillustration_showreward_pop", {reward_data = showInfoData[index + 1].out_item })
        end
    end
    -- body 
    local dx = 0
    if ccbNode then
        local btnexchange = ccbNode:controlButtonForName("btnexchange")
        btnexchange:setVisible(true)
        btnexchange:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
        btnexchange:setTag( index + 1)
        local m_node_rewardboard = ccbNode:nodeForName("m_node_rewardboard")
        local m_node_showInfo = ccbNode:nodeForName("m_node_showInfo")
        local sarrow = ccbNode:spriteForName("sarrow")
        local m_sprite_alredygot = ccbNode:spriteForName("m_sprite_alredygot")
        m_sprite_alredygot:setVisible(false)
        m_node_showInfo:removeAllChildrenWithCleanup(true)
        m_node_rewardboard:removeAllChildrenWithCleanup(true)
        sarrow:removeAllChildrenWithCleanup(true)
        local itemData  = showInfoData[index + 1]
        local canExchange = "can_get"
        local book_id = itemData.id
        if dataInfo.exchange_log[tostring(book_id)] then
            canExchange = "have_got"
        end
        local isHave = false
        -- need_item
        local tempSize = m_node_showInfo:getContentSize()
        local count = #itemData.need_item or 0
        dx = (5 - count) * 0.205 * 0.5 * tempSize.width
        for i=1, count do
            local equipID = itemData.need_item[i][2]
            -- local equioInfo = self.m_equipInfo.data[tostring(equipID)]
            local isSee = 1
            -- if equioInfo then
            --     isSee = equioInfo.is_see
            -- end

            isHave = false
            if dataInfo.books[tostring(equipID)] then 
                isHave = true
            elseif canExchange == "can_get" then
                isHave = false
                canExchange = "cannot_get"
            end

            if isSee == 1 then
                local isButton = true
                local icon, name ,icount = game_util:getRewardByItemTable(itemData.need_item[i])
                if not icon then isButton = false end 
                icon = icon or CCSprite:createWithSpriteFrameName("tujian_kongwei.png")
                if icon then
                    icon:setAnchorPoint(ccp(0.5, 0.5))
                    icon:setPosition(tempSize.width * (0.205 * (i - 1) + 0.08) + dx, tempSize.height * 0.6)
                    icon:setScale(33.0 / icon:getContentSize().width)
                    m_node_showInfo:addChild(icon)
                    if not isHave then
                        icon:setColor(ccc3(155, 155, 155)) 
                        local tempnode = icon:getChildByTag(1)
                        if tempnode and tempnode.setColor then 
                            tempnode:setColor(ccc3(155, 155, 155)) 
                        end
                        tempnode = icon:getChildByTag(2)
                        if tempnode and tempnode.setColor  then 
                            tempnode:setColor(ccc3(155, 155, 155)) 
                        end
                    end
                    if name then
                        local blabelName = game_util:createLabelTTF({text = name, scale = 1.2})
                        blabelName:setAnchorPoint(ccp(0.5, 0))
                        blabelName:setPosition(icon:getContentSize().width * 0.5, -15)
                        -- icon:addChild(blabelName, 11)
                    end

                    local iconSize = icon:getContentSize()
                    if i < count then
                        local addSpr = CCSprite:createWithSpriteFrameName("dhzx_fuhao.png")
                        if addSpr then
                            addSpr:setAnchorPoint(ccp(0.5, 0.5))
                            addSpr:setPosition(tempSize.width * (0.205 * (i - 1) + 0.18)  + dx, tempSize.height * 0.55)
                            m_node_showInfo:addChild(addSpr, 20)
                        end
                    else
                    end
                    if isButton then self:createButtonCenter(icon, onBtnCilck, index*10 + i ) end
                end
            else
                local tempIcon = CCSprite:createWithSpriteFrameName("tujian_kongwei.png");
                tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.65))
                tempIcon:setPosition(tempSize.width * (0.205 * (i - 1) + 0.08), tempSize.height * 0.6)
                tempIcon:setScale(33.0 / tempIcon:getContentSize().width)
                m_node_showInfo:addChild(tempIcon)
            end
        end
            -- 兑换按钮
        if canExchange == "can_get" then
            -- game_util:setCCControlButtonBackground(btnexchange,"award_btn_get.png")
            game_util:createPulseAnmi("award_btn_get.png",btnexchange)
        elseif canExchange == "cannot_get" then
            game_util:setCCControlButtonEnabled( btnexchange, false)
        elseif canExchange == "have_got" then
            btnexchange:setVisible(false)
            m_sprite_alredygot:setVisible(true)
        end

        -- reward
        local tempSize = m_node_rewardboard:getContentSize()
        local count = #itemData.out_item or 0
        if count > 0 then 
            local icon, name ,count = game_util:getRewardByItemTable(itemData.out_item[1])
            if count > 1 then
                if icon then
                    local tempIcon = game_util:createIconByName("icon_piecebox4.png")
                    if icon then
                        local size = tempIcon:getContentSize()
                        local frame = CCSpriteFrame:createWithTexture(tempIcon:getTexture(), CCRectMake(0,0, size.width, size.height))
                        if frame then 
                            icon:setDisplayFrame(frame)
                        end
                    end
                end
            end
            local isButton = true
            if not icon then isButton = false end
            icon = icon or CCSprite:createWithSpriteFrameName("tujian_kongwei.png")
            if icon then
                icon:setAnchorPoint(ccp(0.5, 0.5))
                icon:setPosition(tempSize.width * 0.5, tempSize.height * 0.6)
                icon:setScale(33.0 / icon:getContentSize().width)
                m_node_rewardboard:addChild(icon, 20)
                if name then
                    if count > 1 then name = string_config:getTextByKey("reward") end
                    local blabelName = game_util:createLabelTTF({text = name , scale = 1.2})
                    blabelName:setAnchorPoint(ccp(0.5, 0))
                    blabelName:setPosition(icon:getContentSize().width * 0.5, -15)
                    icon:addChild(blabelName, 11)
                end
                if canExchange == "can_get" then
                    game_util:addTipsAnimByType(icon,2);
                else
                    icon:setColor(ccc3(155, 155, 155))
                    icon:setColor(ccc3(155, 155, 155)) 
                    local tempnode = icon:getChildByTag(1)
                    if tempnode and tempnode.setColor then 
                        tempnode:setColor(ccc3(155, 155, 155)) 
                    end
                    tempnode = icon:getChildByTag(2)
                    if tempnode and tempnode.setColor  then 
                        tempnode:setColor(ccc3(155, 155, 155)) 
                    end
                end
                if isButton then self:createButtonCenter(m_node_rewardboard, onRewardBtnCilck, index * 10000 + count ) end
            end
        end
    end
end



--[[--
    创建按钮
]]
function game_superillustration_scene.createButtonCenter( self, parent, callFun, tag, touchPriority )
    local tempSize = parent:getContentSize()
    local button = game_util:createCCControlButton("public_weapon.png","",callFun or function () end)
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(tempSize.width * 0.5, tempSize.height * 0.5)
    button:setOpacity(0)
    parent:addChild(button)
    button:setTag(tag or 0)
    button:setTouchPriority(touchPriority or GLOBAL_TOUCH_PRIORITY - 6)
end

--[[
    初始化装备兑换数据
]]
function game_superillustration_scene.initEquipExData( self )
        self.m_equipExData = {}
        local book_equip_cfg = getConfig(game_config_field.book_equip)
        if not book_equip_cfg then return end
        local itemCount = book_equip_cfg:getNodeCount()
        local tempData = {}
        for i=1, itemCount do
            local info = book_equip_cfg:getNodeWithKey(tostring(i))
            if info then 
                tempData[#tempData + 1] = json.decode(info:getFormatBuffer())
                tempData[#tempData].id = info:getKey()
            end
        end
        local sortFun = function ( data1, data2)
            return data1.book_id < data2.book_id
        end
        table.sort(tempData, sortFun)
        self.m_equipExData.init = true
        self.m_equipExData.data = tempData
        self.m_equipInfo = {}
        -- local equip_book_cfg = getConfig(game_config_field.equip_book);
        -- self.m_equipInfo.data = equip_book_cfg and json.decode(equip_book_cfg:getFormatBuffer()) or {}
end

--[[
    初始化卡牌兑换数据
]]
function game_superillustration_scene.initcharacterExData( self )
        self.m_characterExData = {}
       local book_character_cfg = getConfig(game_config_field.book_character)
        if not book_character_cfg then return end
        local itemCount = book_character_cfg:getNodeCount()
        local tempData = {}
        for i=1, itemCount do
            local info = book_character_cfg:getNodeWithKey(tostring(i))
            if info then 
                tempData[#tempData + 1] = json.decode(info:getFormatBuffer())
                tempData[#tempData].id = info:getKey()
            end
        end
        local sortFun = function ( data1, data2)
            return data1.book_id < data2.book_id
        end
        table.sort(tempData, sortFun)
        self.m_characterExData.init = true
        self.m_characterExData.data = tempData
        self.m_characterInfo = {data = {}}

        self.m_characterInfo = {}
        -- local character_book_cfg = getConfig(game_config_field.character_book);
        -- self.m_characterInfo.data = character_book_cfg and json.decode(character_book_cfg:getFormatBuffer()) or {}

        -- cclog2(tempData, "tempData   ====    ")
end






--[[--
    初始化
]]
function game_superillustration_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_cur_showType = t_params.showType or "equip"
    self:initEquipExData()
    self:initcharacterExData()
    self.m_equipInfo.books = {}
    self.m_characterInfo.books = {}
    if self.m_cur_showType == "equip" then
        self.m_equipInfo.init = true
        if t_params.gameData then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_equipInfo.books = json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
            self.m_equipInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
        end
    elseif self.m_cur_showType == "character" then
        self.m_characterInfo.init = true
        if t_params.gameData then
            local data = t_params.gameData:getNodeWithKey("data");
            self.m_characterInfo.books = data:getNodeWithKey("books") and json.decode(data:getNodeWithKey("books"):getFormatBuffer()) or {};
            self.m_characterInfo.exchange_log = data:getNodeWithKey("exchange_log") and json.decode(data:getNodeWithKey("exchange_log"):getFormatBuffer()) or {};
        end
    end



end

--[[--
    创建ui入口并初始化数据
]]
function game_superillustration_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_superillustration_scene;