--- 玩家升级弹出框

local player_level_up_pop = {
    m_popUi = nil,
    m_callBackFunc = nil,
    m_lv = nil,
    m_root_layer = nil,
    m_role_img_node = nil,
    m_level_label = nil,
    m_level_label_2 = nil,
    m_action_point_label = nil,
    m_action_point_label_2 = nil,
    m_card_max_label = nil,
    m_card_max_label_2 = nil,
    m_equip_max_label = nil,
    m_equip_max_label_2 = nil,
    m_unlock_label_1 = nil,
    m_unlock_label_2 = nil,
    m_ccbNode = nil,
};
--[[--
    销毁
]]
function player_level_up_pop.destroy(self)
    -- body
    cclog("-----------------player_level_up_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_callBackFunc = nil;
    self.m_lv = nil;
    self.m_root_layer = nil;
    self.m_role_img_node = nil;
    self.m_level_label = nil;
    self.m_level_label_2 = nil;
    self.m_action_point_label = nil;
    self.m_action_point_label_2 = nil;
    self.m_card_max_label = nil;
    self.m_card_max_label_2 = nil;
    self.m_equip_max_label = nil;
    self.m_equip_max_label_2 = nil;
    self.m_unlock_label_1 = nil;
    self.m_unlock_label_2 = nil;
    self.m_ccbNode = nil;
end
--[[--
    返回
]]
function player_level_up_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("player_level_up_pop");
end
--[[--
    读取ccbi创建ui
]]
function player_level_up_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/anim_player_level_up.ccbi");
    self.m_ccbNode = ccbNode
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_role_img_node = ccbNode:scrollViewForName("m_role_img_node")
    self.m_level_label = ccbNode:labelBMFontForName("m_level_label")
    self.m_level_label_2 = ccbNode:labelBMFontForName("m_level_label_2")
    self.m_action_point_label = ccbNode:labelBMFontForName("m_action_point_label")
    self.m_action_point_label_2 = ccbNode:labelBMFontForName("m_action_point_label_2")
    self.m_card_max_label = ccbNode:labelBMFontForName("m_card_max_label")
    self.m_card_max_label_2 = ccbNode:labelBMFontForName("m_card_max_label_2")
    self.m_equip_max_label = ccbNode:labelBMFontForName("m_equip_max_label")
    self.m_equip_max_label_2 = ccbNode:labelBMFontForName("m_equip_max_label_2")
    self.m_unlock_label_1 = ccbNode:labelTTFForName("m_unlock_label_1")
    self.m_unlock_label_2 = ccbNode:labelTTFForName("m_unlock_label_2")
    self.m_unlock_label_1:setString(string_helper.player_level_up_pop.none);
    local ownBigImg = game_util:createOwnBigImg()
    self.m_role_img_node:setTouchEnabled(false)
    if ownBigImg then
        ownBigImg:setScale(0.65);
        local ownBigImgSize = ownBigImg:getContentSize();
        ownBigImg:setPositionY(-ownBigImgSize.height*0.2);
        self.m_role_img_node:addChild(ownBigImg)
    end
    local user_data_backup = game_data:getUserStatusDataBackup();
    local user_data = game_data:getUserStatusData()
    self.m_level_label:setString(tostring(user_data_backup.level))
    self.m_level_label_2:setString(user_data.level)
    -- if game_data_statistics then
    --     game_data_statistics:userLevelChanged({level = user_data.level});
    -- end
    self.m_action_point_label:setString(tostring(user_data_backup.action_point));
    self.m_action_point_label_2:setString(user_data.action_point);
    self.m_card_max_label:setString(tostring(user_data_backup.card_max));
    self.m_card_max_label_2:setString(user_data.card_max);
    self.m_equip_max_label:setString(tostring(user_data_backup.equip_max));
    self.m_equip_max_label_2:setString(user_data.equip_max);
    game_data:judgeCityOpenChanged(false);

    -- local function playAnimEnd(animName)
    --     self:callBackFunc();
    --     self:back();
    -- end
    -- ccbNode:registerAnimFunc(playAnimEnd);
    -- ccbNode:runAnimations("player_level_up");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- cclog2("eventType == then  === ", self:guideHelper())
            if self:guideHelper() then
                self.m_ccbNode:setVisible(false)
            else
                if game_data.getGuideProcess and game_data:getGuideProcess() == "first_battle_mine" then
                   if game_util.statisticsSendUserStep then game_util:statisticsSendUserStep(25) end -- 关闭升级界面 步骤25
                end
                self:callBackFunc();
                self:back();
            end
            return true;--intercept event
        end
    end

    local function callBackFunc()

    end
    local tempAnim = game_util:createEffectAnimCallBack("anim_ui_shengji",1.0,false,callBackFunc);
    if tempAnim then
        local tempSize = self.m_root_layer:getContentSize();
        tempAnim:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.75))
        self.m_root_layer:addChild(tempAnim,100,100)
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    
]]
function player_level_up_pop.refreshOpenFuncTips(self)

    -- print("get level == kkk123" , self.m_lv)

    local role_cfg = getConfig(game_config_field.role)
    if self.m_lv > 1 then
        local role_item_cfg = role_cfg:getNodeWithKey(tostring(self.m_lv + 1))
        if role_item_cfg then
            self.m_unlock_label_1:setString(role_item_cfg:getNodeWithKey("news"):toStr());
        end
    end
    self.m_unlock_label_2:setString("")
end

--[[--
    刷新ui
]]
function player_level_up_pop.refreshUi(self)
    self:refreshOpenFuncTips();
end

--[[--
    初始化
]]
function player_level_up_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_lv = t_params.lv or 1;
end

--[[--
    创建ui入口并初始化数据
]]
function player_level_up_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end


--[[--
    回调方法
]]
function player_level_up_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

--[[
    -- 本场景新手引导入口
]]
function player_level_up_pop.forceGuideFun( self, forceInfo )
    if forceInfo and forceInfo.player_level_up_pop then
        game_data:setForceGuideInfo( forceInfo )
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end

--[[
    检查时候需要新手引导
]]
function player_level_up_pop.guideHelper( self )
    -- cclog2("player_level_up_pop  guideHelper  ======  ")
    local force_guide = game_data:getForceGuideInfo()
    -- cclog2(force_guide, "force_guide   ======  ")
    if type(force_guide) == "table" and force_guide.player_level_up_pop then
        self:forceGuideFun( force_guide )
        return true
    else
        local  guidfun = function (  forceInfo )
            self:forceGuideFun( forceInfo )
        end
        local skipfun = function (  )
            self:back()
        end
        local flag = game_guide_controller:guideHelper( guidfun , "player_level_up_pop", skipfun)
        return flag
    end
    return false
end


return player_level_up_pop;