---  邀请码

local game_invitation_code_pop = {
    m_root_layer = nil,
    m_popUi = nil,
    m_close_btn = nil,
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_idTab = nil,
    m_name_label = nil,
    m_level_label = nil,
    m_input_node = nil,
    m_edit_bg_node = nil,
    m_ok_btn = nil,
    m_inputUid = nil,
    m_info_node = nil,
    m_reward_btn = nil,
    m_role_img_node = nil,
    m_look_master_btn = nil,
    m_no_reward_label = nil,
};
--[[--
    销毁ui
]]
function game_invitation_code_pop.destroy(self)
    -- body
    cclog("----------------- game_invitation_code_pop destroy-----------------"); 
    self.m_root_layer = nil;
    self.m_popUi = nil;
    self.m_close_btn = nil;
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_idTab = nil;
    self.m_name_label = nil;
    self.m_level_label = nil;
    self.m_input_node = nil;
    self.m_edit_bg_node = nil;
    self.m_ok_btn = nil;
    self.m_inputUid = nil;
    self.m_info_node = nil;
    self.m_reward_btn = nil;
    self.m_role_img_node = nil;
    self.m_look_master_btn = nil;
    self.m_no_reward_label = nil;
end
--[[--
    返回
]]
function game_invitation_code_pop.back(self,backType)
    game_scene:removePopByName("game_invitation_code_pop");
end
--[[--
    读取ccbi创建ui
    h12201030 h16653393
]]
function game_invitation_code_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        elseif btnTag == 2 then--拜师
            cclog("self.m_inputUid ===== " .. tostring(self.m_inputUid))
            if self.m_inputUid == nil or  self.m_inputUid == "" then
                game_util:addMoveTips({text = string_helper.game_invitation_code_pop.inputMaster});
                return;
            end
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                self:refreshData();
                self:refreshUi();
            end
            local params = {}
            params.master = tostring(util.url_encode(self.m_inputUid))
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_search_master"), http_request_method.GET, params,"user_search_master")
        elseif btnTag == 3 then--查看奖励
            local request_code = self.m_tGameData.request_code or {}
            local master = request_code.master or {}
            local masterFlag = false;
            for k,v in pairs(master) do
                v.uid = k;
                local function callBackFunc(request_code)
                    self.m_tGameData.request_code = request_code
                    self:refreshData();
                    self:refreshUi();
                end
                game_scene:addPop("game_invitation_code_reward_pop",{gameData = v,openType = 1,callBackFunc = callBackFunc});
                masterFlag = true;
                break;
            end
        elseif btnTag == 4 then--查看导师
            local request_code = self.m_tGameData.request_code or {}
            local master = request_code.master or {}
            local masterFlag = false;
            for k,v in pairs(master) do
                cclog("look master =========");
                masterFlag = true;
                break;
            end
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_invitation_code.ccbi");
    -- 光效 显示
    local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")

    self.m_name_label = ccbNode:labelTTFForName("m_name_label")
    self.m_level_label = ccbNode:labelTTFForName("m_level_label")
    self.m_no_reward_label = ccbNode:labelBMFontForName("m_no_reward_label")
    self.m_no_reward_label:setVisible(false);
    self.m_input_node = ccbNode:nodeForName("m_input_node");
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn");
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title198);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_edit_bg_node = ccbNode:scale9SpriteForName("m_edit_bg_node");
    self.m_edit_bg_node:setOpacity(0);

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_inputUid = edit:getText();
        end
    end
    self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = self.m_edit_bg_node:getContentSize(),placeHolder=string_helper.game_invitation_code_pop.put,maxLength = 20,fontSize = 12});
    self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_editBox:setInputFlag(kEditBoxInputFlagInitialCapsAllCharacters);
    self.m_edit_bg_node:addChild(self.m_editBox);

    self.m_info_node = ccbNode:nodeForName("m_info_node");
    self.m_reward_btn = ccbNode:controlButtonForName("m_reward_btn");
    self.m_reward_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_look_master_btn = ccbNode:controlButtonForName("m_look_master_btn");
    -- self.m_look_master_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    self.m_role_img_node = ccbNode:scrollViewForName("m_role_img_node")
    return ccbNode;
end

--[[--
    创建列表
]]
function game_invitation_code_pop.createTableView(self,viewSize)
    local request_code = self.m_tGameData.request_code or {}
    local slave = request_code.slave or {};

    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag < 100 then
            local itemData = slave[self.m_idTab[btnTag+1]]
            if itemData then
                itemData.uid = self.m_idTab[btnTag+1]
                local function callBackFunc(request_code)
                    self.m_tGameData.request_code = request_code
                    self:refreshData();
                    self:refreshUi();
                end
                game_scene:addPop("game_invitation_code_reward_pop",{gameData = itemData,openType = 2,callBackFunc = callBackFunc});
            end
        else
            btnTag = btnTag - 100;
            cclog("remove index === " .. btnTag)
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    local uid = self.m_idTab[btnTag+1];
                    if uid then
                        local function responseMethod(tag,gameData)
                            game_util:addMoveTips({text = string_helper.game_invitation_code_pop.kickStudent});
                            local data = gameData:getNodeWithKey("data")
                            self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
                            self:refreshData();
                            self:refreshUi();
                        end
                        local params = {}
                        params.uid = tostring(uid);
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_remove_slave"), http_request_method.GET, params,"user_remove_slave")
                    end
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_config:getTextByKey("m_btn_sure"),       --可缺省
                text = string_config:getTextByKey("m_remove_apprentice"),      --可缺省
            }
            game_util:openAlertView(t_params);

        end
    end
    local showCount = #self.m_idTab;
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 2; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 4;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
            ccbNode:openCCBFile("ccb/ui_invitation_code_item.ccbi");
            ccbNode:controlButtonForName("m_reward_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            ccbNode:controlButtonForName("m_remove_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_reward_btn = ccbNode:controlButtonForName("m_reward_btn");
            m_reward_btn:setTag(index);
            local m_remove_btn = ccbNode:controlButtonForName("m_remove_btn")
            m_remove_btn:setTag(index + 100)
            local m_icon_spri_bg = ccbNode:spriteForName("m_icon_spri_bg") 
            local m_invitation_spri = ccbNode:spriteForName("m_invitation_spri") 
            local m_name_label = ccbNode:labelTTFForName("m_name_label")
            local m_level_label = ccbNode:labelTTFForName("m_level_label")
            local m_no_reward_label = ccbNode:labelBMFontForName("m_no_reward_label")
            m_no_reward_label:setVisible(false);
            m_icon_spri_bg:removeAllChildrenWithCleanup(true);
            if index < showCount then
                local itemData = slave[self.m_idTab[index+1]]
                if itemData then
                    m_icon_spri_bg:setOpacity(0)
                    m_reward_btn:setVisible(true);
                    m_invitation_spri:setVisible(false);
                    m_name_label:setString(tostring(itemData.name));
                    m_level_label:setString(string.format(string_helper.game_invitation_code_pop.level,tostring(itemData.level)));
                    local tempIcon = game_util:createPlayerIconByRoleId(itemData.role);
                    if tempIcon then
                        tempIcon:setScale(0.85);
                        local tempSize = m_icon_spri_bg:getContentSize();
                        tempIcon:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
                        m_icon_spri_bg:addChild(tempIcon)
                    end
                    local rewardFlag = self:getRewardFlag(itemData);
                    if rewardFlag == false then
                        m_no_reward_label:setVisible(true);
                        m_reward_btn:setVisible(false);
                    end
                end
                m_remove_btn:setVisible(true);
            else
                m_reward_btn:setVisible(false);
                m_invitation_spri:setVisible(true);
                m_name_label:setString("");
                m_level_label:setString("");
                m_remove_btn:setVisible(false);
            end
            
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemData = slave[self.m_idTab[index+1]]
            if itemData then
                cclog("look slave ==========" .. self.m_idTab[index+1]);
            end
        end
    end
    return TableViewHelper:create(params);
end


--[[--
    
]]
function game_invitation_code_pop.getRewardFlag(self,itemData)
    local request_code_cfg = getConfig(game_config_field.request_code)
    -- cclog("request_code_cfg ==" .. request_code_cfg:getFormatBuffer())
    local level = itemData.level or 1;
    local gift = itemData.gift or {}
    local rewardFlag = true;
    if #gift > 0 then

    else
        local requestId = "-1"
        local tempCount = request_code_cfg:getNodeCount();
        for i=1,tempCount do
            local tempItem = request_code_cfg:getNodeAt(i - 1);
            local tempLevel = tempItem:getNodeWithKey("level")
            local level1 = tempLevel:getNodeAt(0):toInt();
            local level2 = tempLevel:getNodeAt(1):toInt();
            if level >= level1 and level <= level2 then
                requestId = tostring(tonumber(tempItem:getKey()) + 1)
                break;
            end
        end
        local request_item_cfg = request_code_cfg:getNodeWithKey(requestId)
        cclog("requestId ========== " .. requestId .. " ;request_item_cfg = " .. tostring(request_item_cfg))
        if request_item_cfg then
        else--奖励已领完
            rewardFlag = false;
        end
    end
    return rewardFlag;
end

--[[--
    刷新
]]
function game_invitation_code_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView);
    self.m_tableView:setMoveFlag(false)
    self.m_tableView:setScrollBarVisible(false)
end


--[[--

]]
function game_invitation_code_pop.refreshData(self)
    self.m_idTab = {};
    local request_code = self.m_tGameData.request_code or {}
    local slave = request_code.slave or {};
    for k,v in pairs(slave) do
        table.insert(self.m_idTab,k) 
    end
end

--[[--
    刷新ui
]]
function game_invitation_code_pop.refreshUi(self)
    self.m_role_img_node:getContainer():removeAllChildrenWithCleanup(true);
    self:refreshTableView();
    local request_code = self.m_tGameData.request_code or {}
    local master = request_code.master or {}
    local masterFlag = false;
    for k,v in pairs(master) do
        self.m_name_label:setString(tostring(v.name));
        self.m_level_label:setString(string.format(string_helper.game_invitation_code_pop.level,tostring(v.level)));
        local tempImg = game_util:createPlayerBigImgByRoleId(v.role)
        if tempImg then
            local itemSize = self.m_role_img_node:getViewSize();
            self.m_role_img_node:setTouchEnabled(false);
            tempImg:setScale(0.5);
            local tempSize = tempImg:getContentSize();
            tempImg:setPosition(ccp(- tempSize.width*0.25 + itemSize.width*0.5, -itemSize.height*0.5))
            -- tempImg:setAnchorPoint(ccp(0.5, 0.2))
            self.m_role_img_node:addChild(tempImg)
        end
        local rewardFlag = self:getRewardFlag(v);
        if rewardFlag == false then
            self.m_no_reward_label:setVisible(true);
            self.m_reward_btn:setVisible(false);
        end
        masterFlag = true;
        break;
    end
    if masterFlag == true then
        self.m_info_node:setVisible(true);
        self.m_input_node:setVisible(false);
    else
        self.m_info_node:setVisible(false);
        self.m_input_node:setVisible(true);
    end
end
--[[--
    初始化
]]
function game_invitation_code_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self:refreshData();
end
--[[--
    创建ui入口并初始化数据
]]
function game_invitation_code_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_invitation_code_pop;
