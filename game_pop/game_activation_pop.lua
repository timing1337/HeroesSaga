---  激活码

local game_activation_pop = {
    m_popUi = nil,
    m_search_btn = nil,
    m_edit_bg_node = nil,
    m_close_btn = nil,
    m_search_list_view_bg = nil,
    m_CodeId = nil,
    m_codeId = nil,
    m_tCodeData = nil,
    m_root_layer = nil,
};
--[[--
    销毁ui
]]
function game_activation_pop.destroy(self)
    -- body
    cclog("-----------------game_activation_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_search_btn = nil;
    self.m_edit_bg_node = nil;
    self.m_close_btn = nil;
    self.m_search_list_view_bg = nil;
    self.m_CodeId = nil;
    self.m_codeId = nil;
    self.m_tCodeData = nil;
    self.m_root_layer = nil;
end
--[[--
    返回
]]
function game_activation_pop.back(self,backType)
    game_scene:removePopByName("game_activation_pop");
end

-- local activeTab  = {'901D4TNZT9ERU', '901FJ3K7MYHYQ', '9016X6RW4RM6Q', '901CKEAJAQ9D3', '901E4UW4CKKJC', '901WRWWGCFZDC', '901DQRCR2AR7C', '90167FZ7VKH4T', '901WF62P37NJY', '901TP4Z4NTA2F', '901QZNXVYCVCC', '9016U2P2N46ZW', '901X9EVY9XHPQ', '901WZX2QA2HJA', '9014EH2QQHH9R', '901HFXJDY2AYT', '901NMXJM3FWKY', '901WPXWZK49F7', '901JGY7Y947FH', '901PW7UKVPKMY', '901VE4VCR722E', '9019DU66XNRTD', '901HP3EV7YD9J', '901H4G9H7K9R4', '901CRNE773ZW9', '901PD9WG3QKJH', '901JGZNGVQC37', '9017NKG9XD6YH', '901YGHNW62NN9', '9012XTDJ69M96', '901HMHKXF9PGR', '9012Q9GDHQ7Q6', '901FA2XPVH4NM', '9014G7JGHXNTJ', '9016XF6VRQYEQ', '9017DP44TQQG3', '901DNUKD7VJNX', '901NTGVCQ9E92', '901TRWCUVNHCM', '901WXUTWVX46C', '901HXTTQTFEWN', '9014F763P6JAT', '901VGF36YXEGE', '901KZZTDDQUTK', '901DDRD99TC77', '901WUYGKKRNRQ', '901KNM4AFRQC7', '901FKEHDWFZH6', '901AP29QP9QVY', '9017RC3MP3VDN', '901UY26JDXYPG'}
--[[--
    读取ccbi创建ui
]]
function game_activation_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    local tempIndex = 1;
    local function onSearchBtnClick( target,event )
        -- self.m_codeId = activeTab[tempIndex]
        -- cclog("self.m_codeId ============ " .. self.m_codeId)
        if self.m_codeId and self.m_codeId ~= "" then
            -- cclog("self.m_codeId ========" .. self.m_codeId)
            local function responseMethod(tag,gameData)
                self.m_codeId = "";
                local data = gameData:getNodeWithKey("data");
                local codes = data:getNodeWithKey("codes");
                self.m_tCodeData.data = json.decode(codes:getFormatBuffer()) or {}
                self:refreshTab4();
                self.m_editBox:setText("");
                game_util:addMoveTips({text = string_helper.game_activation_pop.getSuccess});
                tempIndex = tempIndex + 1;
            end
            local params = {};
            params.code = tostring(util.url_encode(self.m_codeId));
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("code_use_code"), http_request_method.GET, params,"code_use_code")
        end
    end
    ccbNode:registerFunctionWithFuncName("onSearchBtnClick",onSearchBtnClick);
    ccbNode:openCCBFile("ccb/ui_activation.ccbi");
    
    self.m_search_btn = ccbNode:controlButtonForName("m_search_btn");
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
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
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder="输入",maxLength = 20});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_editBox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters);
    self.m_edit_bg_node:addChild(self.m_editBox);

    self.m_search_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新
]]
function game_activation_pop.refreshTab4(self)
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
        self.m_search_list_view_bg:removeAllChildrenWithCleanup(true);
        local tableViewTemp = self:createCodeTableView(self.m_search_list_view_bg:getContentSize());
        self.m_search_list_view_bg:addChild(tableViewTemp);
    end
end
--[[--
    创建激活码
]]
function game_activation_pop.createCodeTableView(self,viewSize)
    local code_cfg = getConfig(game_config_field.code);
    local tGameData = self.m_tCodeData.data;
    cclog(" #tGameData ==============" ..  #tGameData)
    local selIndex = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.direction = kCCScrollViewDirectionVertical;
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
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
            selIndex = index;
            local itemData = tGameData[index+1];
            local itemCfg = code_cfg:getNodeWithKey(tostring(itemData));
            if itemCfg then
                game_util:addMoveTips({text = itemCfg:getNodeWithKey("reward_des"):toStr()});
            end
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_activation_pop.refreshUi(self)
    self:refreshTab4();
end
--[[--
    初始化
]]
function game_activation_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tCodeData = {init = false,data = {}}
end

--[[--
    创建ui入口并初始化数据
]]
function game_activation_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;

end

return game_activation_pop;