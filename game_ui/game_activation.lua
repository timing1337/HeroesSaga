---  激活码

local game_activation = {
    btn_get_activation = nil,
    m_edit_bg_node = nil,
    m_close_btn = nil,
    m_edit_bg_node = nil,
    m_search_list_view_bg = nil,
    m_CodeId = nil,
    m_codeId = nil,
    m_tCodeData = nil,
};
--[[--
    销毁ui
]]
function game_activation.destroy(self)
    -- body
    cclog("-----------------game_activation destroy-----------------");
    self.btn_get_activation = nil;
    self.m_edit_bg_node = nil;
    self.m_close_btn = nil;
    self.m_edit_bg_node = nil;
    self.m_search_list_view_bg = nil;
    self.m_CodeId = nil;
    self.m_codeId = nil;
    self.m_tCodeData = nil;
end
--[[--
    返回
]]
function game_activation.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_activation.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local function onSearchBtnClick( target,event )
        if self.m_codeId and self.m_codeId ~= "" then
            -- cclog("self.m_codeId ========" .. self.m_codeId)
            local function responseMethod(tag,gameData)
                self.m_codeId = "";
                local data = gameData:getNodeWithKey("data");
                local codes = data:getNodeWithKey("codes");
                self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
                self:refreshTab4();
                self.m_editBox:setText("");
                game_util:addMoveTips({text = string_helper.game_activation.text});
            end
            local params = {};
            params.code = tostring(util.url_encode(self.m_codeId));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_use_code"), http_request_method.GET, params,"code_use_code")
        end
    end
    ccbNode:registerFunctionWithFuncName("onSearchBtnClick",onSearchBtnClick);
    ccbNode:openCCBFile("ccb/ui_activation.ccbi");
    
    self.btn_get_activation = ccbNode:controlButtonForName("m_search_btn");
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node")
    self.m_search_list_view_bg = ccbNode:layerForName("m_search_list_view_bg")
    cclog("m_search_list_view_bg = " .. tostring(m_search_list_view_bg))
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
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder=string_helper.game_activation.placeHolder,maxLength = 20});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_edit_bg_node:addChild(self.m_editBox);
    return ccbNode;
end
--[[--
    刷新
]]
function game_activation.refreshTab4(self)
    if self.m_tCodeData.init == false then
        local function responseMethod(tag,gameData)
            self.m_tCodeData.init = true;
            local data = gameData:getNodeWithKey("data");
            local codes = data:getNodeWithKey("codes");
            self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
            self:refreshTab4();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_index"), http_request_method.GET, nil,"code_index")
    else
        local tableViewTemp = self:createCodeTableView(self.m_search_list_view_bg:getContentSize());
        self.m_search_list_view_bg:addChild(tableViewTemp);
    end
end
--[[--
    创建激活码
]]
function game_activation.createCodeTableView(self,viewSize)
    local code_cfg = getConfig(game_config_field.code);
    local tGameData = self.m_tCodeData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_code_list_view.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            local itemCfg = code_cfg:getNodeWithKey(tostring(itemData));
            if ccbNode and itemCfg then
                local m_node = ccbNode:nodeForName("m_node")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr());
                local icon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr())
                if icon then
                    m_node:removeAllChildrenWithCleanup(true)
                    m_node:addChild(icon);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_activation.refreshUi(self)
    self:refreshTab4();
end
--[[--
    初始化
]]
function game_activation.init(self,t_params)
    t_params = t_params or {};
    self.m_tCodeData = {init = false,data = {}}
end

--[[--
    创建ui入口并初始化数据
]]
function game_activation.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_activation;