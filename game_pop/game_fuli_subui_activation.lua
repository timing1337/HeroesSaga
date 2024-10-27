---  ui模版

local game_fuli_subui_activation = {

    m_editBox = nil,
    m_codeId = nil,
    m_edit_bg_node = nil,
    m_node_rewardListBoard = nil,
}

--[[--
    销毁ui
]]
function game_fuli_subui_activation.destroy(self)
    -- body
    cclog("----------------- game_fuli_subui_activation destroy-----------------"); 
    self.m_editBox = nil;
    self.m_codeId = nil;
    self.m_edit_bg_node = nil;
    self.m_node_rewardListBoard = nil;
end
--[[--
    返回
]]
function game_fuli_subui_activation.back(self,backType)
        self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_fuli_subui_activation.createUi(self)
   local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        if btnTag == 101 then -- 领取
            if self.m_codeId and self.m_codeId ~= "" then
            -- cclog("self.m_codeId ========" .. self.m_codeId)
            local function responseMethod(tag,gameData)
                self.m_codeId = "";
                local data = gameData:getNodeWithKey("data");
                local codes = data:getNodeWithKey("codes");
                self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
                self:refreshTab();
                self.m_editBox:setText("");
                game_util:addMoveTips({text = string_helper.game_fuli_subui_activation.get});
            end
            local params = {};
            params.code = tostring(util.url_encode(self.m_codeId));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_use_code"), 
                http_request_method.GET, params,"code_use_code")
        end
        end
    end

    ccbNode:registerFunctionWithFuncName("onSearchBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_fuli_content_activation.ccbi");

    local m_conbtn_get = ccbNode:controlButtonForName("m_conbtn_get");
    m_conbtn_get:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 16)

    game_util:setCCControlButtonTitle(m_conbtn_get,string_helper.ccb.text176)
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node");
    self.m_node_rewardListBoard = ccbNode:layerForName("m_node_rewardListBoard")
    self.m_edit_bg_node:setOpacity(0);

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_codeId = edit:getText();
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder=string_helper.ccb.file51,maxLength = 20});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_edit_bg_node:addChild(self.m_editBox);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text174)
    local text2 = ccbNode:labelTTFForName("text2")
    text2:setString(string_helper.ccb.text175)

    return ccbNode
end


--[[--
    刷新
]]
function game_fuli_subui_activation.refreshTab(self)
    if self.m_tCodeData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tCodeData.init = true;
            local data = gameData:getNodeWithKey("data");
            local codes = data:getNodeWithKey("codes");
            self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
            self:refreshTab();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_index"), http_request_method.GET, nil,"code_index")
    else
        self.m_node_rewardListBoard:removeAllChildrenWithCleanup(true)
        local tableViewTemp = self:createCodeTableView(self.m_node_rewardListBoard:getContentSize());
        self.m_node_rewardListBoard:addChild(tableViewTemp);
    end
end

--[[--
    创建激活码
]]
function game_fuli_subui_activation.createCodeTableView(self,viewSize)
    local code_cfg = getConfig(game_config_field.code);
    local tGameData = self.m_tCodeData.data;
    -- cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = math.max(#tGameData, 1);
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_fuli_activation_code_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_node_tips = ccbNode:nodeForName("m_node_tips")
            m_node_tips:setVisible(false)
            local m_node_allinfo = ccbNode:nodeForName("m_node_allinfo")
            m_node_allinfo:setVisible(false)

            local m_label_codename = ccbNode:labelTTFForName("m_label_codename")
            local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
            local m_icon_spr = ccbNode:spriteForName("m_icon_spr")
            local m_node_showRewardboard = ccbNode:nodeForName("m_node_showRewardboard")

            local m_node_icon = ccbNode:nodeForName("m_node_icon")

            local itemData = tGameData[index+1];
            -- cclog2(itemData, "itemData  ===  ")
            if itemData then
                m_node_allinfo:setVisible(true)
                local itemCfg = code_cfg:getNodeWithKey(tostring(itemData));
                if ccbNode and itemCfg then
                    -- cclog2(itemCfg, "itemCfg  ==   ")
                    local m_node = ccbNode:nodeForName("m_node")
                    m_label_codename:setString(itemCfg:getNodeWithKey("name"):toStr());
                    -- local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                    -- if icon then
                    --     m_node:removeAllChildrenWithCleanup(true)
                    --     m_node:addChild(icon);
                    -- end
                    local rewardList = json.decode(itemCfg:getNodeWithKey("reward"):getFormatBuffer())
                    -- cclog2(rewardList, "rewardList   ===   ")
                    m_node_showRewardboard:removeAllChildrenWithCleanup(true)
                    local tempTable = self:createRewardTable(m_node_showRewardboard:getContentSize(),#rewardList,rewardList)
                    m_node_showRewardboard:addChild(tempTable)

                    local tempIcon = game_util:createIconByName("icon_box4.png")
                    tempIcon:setPosition(m_node_icon:getContentSize().width * 0.5, m_node_icon:getContentSize().height * 0.5 )
                    m_node_icon:removeAllChildrenWithCleanup(true)
                    m_node_icon:addChild(tempIcon)
                end

            else
                m_node_tips:setVisible(true)
                local  file56 = ccbNode:labelTTFForName("file56");
                file56:setString(string_helper.ccb.file56);
            end
            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
        end
    end
    return TableViewHelper:create(params);
end


--[[
    奖励列表
]]
function game_fuli_subui_activation.createRewardTable(self,viewSize,count,rewardList)
    function onBtnClick( event, target )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        print("press button tag is ", btnTag)
        local itemData = rewardList[btnTag + 1]
        if itemData then
            game_util:lookItemDetal( itemData )
        end
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 4; --列
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionHorizontal;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local node = CCNode:create()
            node:setAnchorPoint(ccp(0.5,0.5))
            node:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            local itemGift = rewardList[index+1]
            local icon,name,count = game_util:getRewardByItemTable(itemGift)
            node:removeAllChildrenWithCleanup(true)
            if icon then
                icon:setScale(0.7)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,2))
                node:addChild(icon,10)
                local button = game_util:createCCControlButton("public_weapon.png","",onBtnClick)
                button:setAnchorPoint(ccp(0.5,0.5))
                button:setPosition( node:getContentSize().width * 0.5, node:getContentSize().height * 0.5 )
                button:setOpacity(0)
                node:addChild(button)
                button:setTag( index )
            end
            if count then
                local label_count = game_util:createLabelTTF({text = "×" .. count,color = ccc3(255,255,255),fontSize = 12})
                label_count:setAnchorPoint(ccp(0.5,0.5))
                label_count:setPosition(ccp(0,-20))
                node:addChild(label_count,20)
            end
            cell:addChild(node)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
    end
    return TableViewHelper:createGallery2(params);
end


--[[--
    刷新ui
]]
function game_fuli_subui_activation.refreshUi(self)
    self:refreshTab()
    -- self.m_node_rewardListBoard:removeAllChildrenWithCleanup(true)
    -- local tableView = self:createCodeTableView( self.m_node_rewardListBoard:getContentSize() )
    -- self.m_node_rewardListBoard:addChild( tableView )
end

--[[--
    初始化
]]
function game_fuli_subui_activation.init(self,t_params)
    t_params = t_params or {}
    self.m_tCodeData = {init = false,data = {}}
end
--[[--
    创建ui入口并初始化数据
]]
function game_fuli_subui_activation.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_fuli_subui_activation