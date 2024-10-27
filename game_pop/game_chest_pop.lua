--- 宝箱

local game_chest_pop = {
    m_popUi = nil,
    m_chest_anim = nil,
    m_animLabelName = nil,
    m_godgiftTab = nil,
    callFunc = nil,
    animFile = nil,
};
--[[--
    销毁
]]
function game_chest_pop.destroy(self)
    -- body
    cclog("-----------------game_chest_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_chest_anim = nil;
    self.m_animLabelName = nil;
    self.m_godgiftTab = nil;
    self.callFunc = nil;
    self.animFile = nil;
end
--[[--
    返回
]]
function game_chest_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    if self.callFunc then
        self.callFunc()
    end
    game_scene:removePopByName("game_chest_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_chest_pop.createUi(self)
     local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();

    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_chest_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    self.m_chest_btn = ccbNode:controlButtonForName("m_chest_btn")
    self.m_chest_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);
    local function animCallFunc(animNode, theId,theLabelName)
        if theLabelName == "dakai" then
            game_util:rewardTipsByDataTable(self.m_godgiftTab);
            self:back();
        elseif theLabelName == "kaishi" then
            self.m_animLabelName = "daiji1";
            animNode:playSection("daiji1")
        else
            self.m_animLabelName = theLabelName;
            animNode:playSection(theLabelName)
        end
    end
    self.m_animLabelName = "kaishi";
    local animFile = self.animFile or "anim_baoxiang"
    self.m_chest_anim = game_util:createUniversalAnim({animFile = animFile,rhythm = 1.0,loopFlag = true,animCallFunc = animCallFunc,actionName = "kaishi"});
    if self.m_chest_anim then
        -- self.m_chest_anim:setScale(1.5);
        local tempSize = self.m_chest_btn:getContentSize();
        self.m_chest_anim:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
        self.m_chest_btn:addChild(self.m_chest_anim)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            cclog("self.m_animLabelName == " .. self.m_animLabelName .. " ; self.m_chest_anim ==" .. tostring(self.m_chest_anim) .. "")
            if self.m_animLabelName == "daiji1" then
                if self.m_chest_anim then
                    self.m_animLabelName = "dakai";
                    self.m_chest_anim:playSection("dakai")
                else
                    self:back();
                end
            end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,-1000000,true);
    m_root_layer:setTouchEnabled(true);

    -- local function playAnimEnd(animName)
    --     if self.m_chest_anim then
    --         self.m_animLabelName = "daiji1";
    --         self.m_chest_anim:playSection("daiji1")
    --     end
    -- end
    -- ccbNode:registerAnimFunc(playAnimEnd);
    ccbNode:runAnimations("enter_anim");
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_chest_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_chest_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_godgiftTab = t_params.godgiftTab or {};
    self.callFunc = t_params.callFunc
    self.animFile = t_params.animFile
end

--[[--
    创建ui入口并初始化数据
]]
function game_chest_pop.create(self,t_params)
    self:init(t_params);
    self.openType = t_params.openType or 1
    if self.openType == 1 then
        if game_util:getTableLen(self.m_godgiftTab) == 0 then
            return nil;
        end
    else

    end
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_chest_pop;