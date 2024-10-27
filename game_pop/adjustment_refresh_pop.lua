--- 阵型属性刷新

local adjustment_refresh_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_left_btn = nil,
    m_right_btn = nil,
    m_attr_node_1 = nil,
    m_attr_node_2 = nil,
    m_tParams = nil,
    m_btnStatusTab = nil,
    m_ccbNode = nil,
    m_arrow_sprite = nil,
    m_posIndex = nil,
    m_attrValueTab = nil,
    m_newAttrValueTab = nil,
    m_status = nil,
    m_changeFlag = nil,
    m_ability2OpenFlag = nil,
    m_lock_tips_label = nil,
    m_refresh_cost_node = nil,
    m_refresh_cost_label = nil,
    m_active_cost_node = nil,
    m_refreshCost = nil,
    m_lockCost = nil,
    m_refreshFlag = nil,
};

local ATTR_LOCK_TAB = {status_11="ability1",status_12="card",status_13="ability2"}

--[[--
    销毁
]]
function adjustment_refresh_pop.destroy(self)
    -- body
    cclog("-----------------adjustment_refresh_pop destroy-----------------");
    self.m_popUi = nil
    self.m_root_layer = nil
    self.m_close_btn = nil
    self.m_left_btn = nil
    self.m_right_btn = nil
    self.m_attr_node_1 = nil
    self.m_attr_node_2 = nil
    self.m_tParams = nil
    self.m_btnStatusTab = nil
    self.m_ccbNode = nil
    self.m_arrow_sprite = nil
    self.m_posIndex = nil
    self.m_attrValueTab = nil
    self.m_newAttrValueTab = nil
    self.m_status = nil
    self.m_changeFlag = nil
    self.m_ability2OpenFlag = nil
    self.m_lock_tips_label = nil
    self.m_refresh_cost_node = nil
    self.m_refresh_cost_label = nil
    self.m_active_cost_node = nil
    self.m_refreshCost = nil
    self.m_lockCost = nil
    self.m_refreshFlag = nil
end
--[[--
    返回
]]
function adjustment_refresh_pop.back(self,type)
    if self.m_changeFlag == true then
        self:callBackFunc()
    end
    game_scene:removePopByName("adjustment_refresh_pop")
end
--[[--
    读取ccbi创建ui
]]
function adjustment_refresh_pop.createUi(self)
    local ccbNode = luaCCBNode:create()
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton")
        local btnTag = tagNode:getTag()
        if btnTag == 1 then--关闭
            self:back()
        elseif btnTag == 2 then--2保留 
            self:refreshAttr(1)
            self.m_changeFlag = true
        elseif btnTag == 3 then--刷新
            if self.m_status == 0 then
                self:refreshAttr(0)
            else
                local t_params = 
                {
                    title = string_config.m_title_prompt,
                    okBtnCallBack = function(target,event)
                        self:refreshAttr(0)
                        game_util:closeAlertView();
                    end,   --可缺省
                    okBtnText = string_config.m_btn_sure,       --可缺省
                    text = string_helper.adjustment_refresh_pop.refreshTip,      --可缺省
                    onlyOneBtn = false,
                }
                game_util:openAlertView(t_params);
            end
        elseif btnTag > 10 and btnTag < 24 then
            -- local tempValue1 = math.floor(btnTag/10)
            local tempValue2 = btnTag%10
            btnTag = btnTag - 10
            local status_1 = self.m_btnStatusTab["status_1" .. tempValue2]
            if status_1 == -1 then
                local function responseMethod(tag,gameData)
                    -- self.m_btnStatusTab["status_1" .. tempValue2] = 1
                    self.m_changeFlag = true
                    self:refreshUi();
                    game_util:addMoveTips({text = string_helper.adjustment_refresh_pop.active});
                end
                --助威升级接口  参数: pos: 0-9
                local params = {pos = self.m_posIndex - 1}
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_assistant_effect_uplevel"), http_request_method.GET, params,"cards_assistant_effect_uplevel")
            else
                local tempCount = self:getBtnLockCount()
                if status_1 == 1 and tempCount > 0 then
                    game_util:addMoveTips({text = string_helper.adjustment_refresh_pop.lockLimit});
                    return
                end
                status_1 = status_1 == 0 and 1 or 0
                local pX,pY = tagNode:getParent():getPosition()
                self.m_lock_tips_label:setVisible(status_1 == 0 and not self.m_refreshFlag)
                self.m_lock_tips_label:setPositionY(pY)
                if status_1 == 0 then
                    self.m_refresh_cost_label:setString(self.m_refreshCost + self.m_lockCost)
                else
                    self.m_refresh_cost_label:setString(self.m_refreshCost)
                end
                self.m_btnStatusTab["status_1" .. tempValue2] = status_1
            end
            self.m_status = 0
            self:setBtnStatus(1,tempValue2)
            self:setBtnStatus(2,tempValue2)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick)--bind button on click event
    ccbNode:openCCBFile("ccb/ui_adjustment_refresh_pop.ccbi")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_left_btn = ccbNode:controlButtonForName("m_left_btn")
    self.m_right_btn = ccbNode:controlButtonForName("m_right_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_left_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_right_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    self.m_attr_node_1 = ccbNode:nodeForName("m_attr_node_1")
    self.m_attr_node_2 = ccbNode:nodeForName("m_attr_node_2")
    self.m_arrow_sprite = ccbNode:spriteForName("m_arrow_sprite")
    self.m_lock_tips_label = ccbNode:labelTTFForName("m_lock_tips_label")
    self.m_refresh_cost_node = ccbNode:nodeForName("m_refresh_cost_node")
    self.m_refresh_cost_label = ccbNode:labelBMFontForName("m_refresh_cost_label")
    self.m_active_cost_node = ccbNode:nodeForName("m_active_cost_node")
    local assistant_cfg = getConfig(game_config_field.assistant)
    local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(self.m_posIndex))
    local refreshCost,lockCost = 0,0
    if assistant_cfg_item then
        refreshCost = assistant_cfg_item:getNodeWithKey("refresh")
        refreshCost = refreshCost and refreshCost:toInt() or 0
        lockCost = assistant_cfg_item:getNodeWithKey("lock")
        lockCost = lockCost and lockCost:toInt() or 0
        local activation = assistant_cfg_item:getNodeWithKey("level_up")
        if activation and self.m_ability2OpenFlag == true then
            local costMetalTab = json.decode(activation:getFormatBuffer()) or {}
            if #costMetalTab > 0 then
                local icon,name,count = game_util:getRewardByItemTable(costMetalTab[1],true)
                local _,ownCount = game_data:getMetalByTable(costMetalTab[1],0,0);
                if icon then
                    icon:setScale(0.3)
                    icon:setPositionX(25)
                    if count > ownCount then
                        icon:setColor(ccc3(77,77,77))
                    end
                    self.m_active_cost_node:addChild(icon)
                end
                if name then
                    local color = count > ownCount and ccc3(155,155,155) or ccc3(0,255,0)
                    local tempLabel = game_util:createLabelTTF({text = name,color = color,fontSize = 8});
                    tempLabel:setPositionX(-10)
                    self.m_active_cost_node:addChild(tempLabel)
                end
            end
        end
    end
    self.m_refreshCost = refreshCost
    self.m_lockCost = lockCost
    self.m_refresh_cost_label:setString(refreshCost)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true)
    self.m_root_layer:setTouchEnabled(true)
    self.m_ccbNode = ccbNode

    game_util:setCCControlButtonTitle(self.m_left_btn,string_helper.ccb.text55)
    game_util:setCCControlButtonTitle(self.m_right_btn,string_helper.ccb.text56)
    return ccbNode;
end

--[[

]]
function adjustment_refresh_pop.refreshAttr(self,retain)
    local function responseMethod(tag,gameData)
        self:refreshUi()
        if retain == 1 then
            game_util:addMoveTips({text = string_helper.adjustment_refresh_pop.saveProperty});
        else
            game_util:addMoveTips({text = string_helper.adjustment_refresh_pop.refreshProperty});
        end
    end
    --参数: lock值为'ability1'基础, 'ability2'升级后, 'card'卡牌     pos位置0,1,2    retain保存为1 刷新为0
    local lock = nil
    for k,v in pairs(self.m_btnStatusTab) do
        if v == 0 then
            lock = ATTR_LOCK_TAB[k]
            break
        end
    end
    local params = {lock = lock,pos = self.m_posIndex - 1, retain = retain} 
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_refresh_assistant_effect"), http_request_method.GET, params,"cards_refresh_assistant_effect")
end

--[[

]]
function adjustment_refresh_pop.getBtnLockCount(self)
    local tempCount = 0
    for i=1,3 do
        local tempValue = self.m_btnStatusTab["status_1" .. i] or 1
        if tempValue == 0 then
            tempCount = tempCount + 1
        end
    end
    return tempCount
end

--[[
    
]]
function adjustment_refresh_pop.setBtnStatus(self,index1,index2)
    local extName = tostring(index1) .. tostring(index2)
    local btn = self.m_ccbNode:controlButtonForName("m_btn_" .. extName)
    if btn == nil then return end
    btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1)
    local status = self.m_btnStatusTab["status_1" .. index2] or -1
    local btn_img = "dw_jihuo_btn.png"
    local bg_img = "dw_jihuo_bg.png"
    if status == 0 then
        btn_img = "dw_suo_btn.png"
        bg_img = "dw_kuang_bg.png"
    elseif status == 1 then
        btn_img = "dw_suo_btn2.png"
        bg_img = "dw_kuang_bg.png"
    end
    local m_attr_bg = self.m_ccbNode:spriteForName("m_attr_bg_" .. extName)
    if m_attr_bg then
        local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bg_img)
        if tempFrame then
            m_attr_bg:setDisplayFrame(tempFrame);
        end
    end
    local m_attr_label = self.m_ccbNode:labelTTFForName("m_attr_label_" .. extName)
    local m_attr_lock_img = self.m_ccbNode:spriteForName("m_attr_lock_img_" .. extName)
    local m_attr_icon = self.m_ccbNode:spriteForName("m_attr_icon_" .. extName)
    if index2 ~= 3 or (index2 == 3 and self.m_ability2OpenFlag) then
        if m_attr_label then
            m_attr_label:setVisible(status ~= -1)
        end
        if m_attr_icon then
            m_attr_icon:setVisible(status ~= -1)
        end
        if m_attr_lock_img then
            m_attr_lock_img:setVisible(status == -1)
        end
    end
    local attrValueItem = nil
    if index1 == 1 then
        attrValueItem = self.m_attrValueTab[index2] or {}
    else
        attrValueItem = self.m_newAttrValueTab[index2] or {}
        if status ~= -1 then
            local attrValueItem1 = self.m_attrValueTab[index2] or {}
            local att_value1 = attrValueItem1.att_value or 0
            local att_value = attrValueItem.att_value or 0
            if att_value > att_value1 then
                btn_img = "dw_up_img.png"
            elseif att_value < att_value1 then
                btn_img = "dw_down_img.png"
            else
                btn_img = "dw_equal_img.png"
            end
            local character_id1 = attrValueItem1.character_id or 0
            local character_id = attrValueItem.character_id or 0
            if att_value > att_value1 or (attrValueItem.att_name == "card" and character_id1 ~= character_id) then
                local quality = attrValueItem.quality or 0
                if status == 1 and quality > 3 then
                    self.m_status = 1
                end
            end
        end
    end
    game_util:setCCControlButtonBackground(btn,btn_img)
    local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. (attrValueItem.att_type or 0)]
    if abilityItem then
        if attrValueItem.att_name == "card" then
            m_attr_label:setString("+" .. tostring(attrValueItem.att_value) .. "%" .. "\n(" .. tostring(attrValueItem.character_name) .. ")")
        else
            m_attr_label:setString("+" .. tostring(attrValueItem.att_value) .. "%\n(" .. string_helper.adjustment_refresh_pop.maxVlue .. tostring(attrValueItem.max_value) .. "%)")
        end
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(abilityItem.icon))
        if tempSpriteFrame and m_attr_icon then
            m_attr_icon:setDisplayFrame(tempSpriteFrame)
        end
    end
end
--[[--
    刷新ui
]]
function adjustment_refresh_pop.refreshUi(self)
    local assistantEffect = game_data:getAssistantEffect()
    local assistantEffectItem = assistantEffect[self.m_posIndex] or {}
    local refreshFlag = false
    if assistantEffectItem then
        local active_status = assistantEffectItem.active_status or "-1"--是否激活助威属性
        self.m_attrValueTab,self.m_newAttrValueTab,refreshFlag = game_util:getAssistantAttrTab(self.m_posIndex, assistantEffectItem, nil, true)
    end
    local attrValueItem = self.m_attrValueTab[3] or {}
    local open = attrValueItem.open or 0
    if open > 0 and self.m_btnStatusTab.status_13 == -1 then
        self.m_btnStatusTab.status_13 = 1
    end
    self.m_active_cost_node:setVisible(self.m_btnStatusTab.status_13 == -1)
    -- cclog(json.encode(self.m_attrValueTab))
    self.m_status = 0
    for i=1,3 do
        self:setBtnStatus(1,i)
        self:setBtnStatus(2,i)
    end
    local m_attr_node_1 = self.m_ccbNode:nodeForName("m_attr_node_1")
    local m_attr_node_2 = self.m_ccbNode:nodeForName("m_attr_node_2")
    local tempSize = m_attr_node_1:getParent():getContentSize()
    local _,pY = m_attr_node_1:getPosition()
    if not refreshFlag then
        local pX = tempSize.width*0.5
        m_attr_node_1:setPositionX(pX)
        m_attr_node_2:setVisible(false)
        self.m_left_btn:setVisible(false)
        self.m_right_btn:setPositionX(pX)
        self.m_refresh_cost_node:setPositionX(pX)
        self.m_status = 0
        local tempCount = self:getBtnLockCount()
        if tempCount > 0 then
            self.m_lock_tips_label:setVisible(true)
        end
    else
        -- m_attr_node_1:setPositionX(tempSize.width*0.27)
        m_attr_node_1:runAction(CCMoveTo:create(0.2,ccp(tempSize.width*0.266,pY)))
        local tempWidth = m_attr_node_2:getContentSize().width
        for i=1,3 do
            if i ~= 3 or (i == 3 and self.m_ability2OpenFlag == true) then
                local m_attr_bg = self.m_ccbNode:spriteForName("m_attr_bg_2" .. i)
                local _,pY = m_attr_bg:getPosition()
                m_attr_bg:setPosition(ccp(tempWidth*1.5,pY))
                m_attr_bg:setVisible(false)
                local arr = CCArray:create()
                arr:addObject(CCDelayTime:create(0.2*i))
                arr:addObject(CCShow:create())
                arr:addObject(CCEaseIn:create(CCMoveTo:create(0.1,ccp(tempWidth*0.5,pY)),5))
                m_attr_bg:runAction(CCSequence:create(arr))
            end
        end
        m_attr_node_2:setVisible(true)
        self.m_left_btn:setVisible(true)
        self.m_right_btn:setPositionX(tempSize.width*0.7)
        self.m_refresh_cost_node:setPositionX(tempSize.width*0.7)
        self.m_lock_tips_label:setVisible(false)
    end
    self.m_refreshFlag = refreshFlag
    if self.m_ability2OpenFlag == false then
        for i=1,2 do
            local m_attr_bg_13 = self.m_ccbNode:spriteForName("m_attr_bg_" .. i .. "3")
            m_attr_bg_13:setVisible(false)
        end
        m_attr_node_1:setPositionY(tempSize.height*0.44)
        m_attr_node_2:setPositionY(tempSize.height*0.44)
    end
    self.m_arrow_sprite:setVisible(refreshFlag)
end

--[[--
    初始化
]]
function adjustment_refresh_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tParams.m_showType = t_params.showType or 1;
    self.m_btnStatusTab = {status_11=1,status_12=1,status_13=-1}
    self.m_posIndex = t_params.posIndex or 1
    self.m_attrValueTab = {}
    self.m_newAttrValueTab = {}
    self.m_status = 0
    self.m_changeFlag = false
    self.m_ability2OpenFlag = game_data:isViewShowByID(145)
    self.m_refreshCost = 0
    self.m_lockCost = 0
    self.m_refreshFlag = false
end

--[[--
    创建ui入口并初始化数据
]]
function adjustment_refresh_pop.create(self,t_params)
    self:init(t_params)
    self.m_popUi = self:createUi()
    self:refreshUi()
    return self.m_popUi
end

--[[--
    回调方法
]]
function adjustment_refresh_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params)
    end
end

return adjustment_refresh_pop;