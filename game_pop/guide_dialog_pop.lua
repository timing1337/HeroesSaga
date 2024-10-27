---  新手引导

local guide_dialog_pop = {
    m_popUi = nil,
    m_endCallFunc = nil,
    m_root_layer = nil,
    m_mask_node = nil,
    m_arrow_spri =nil,
    m_startPos = nil,
    m_size = nil,
    m_showArrowFlag = nil,
    m_tempNode = nil,
    m_skip_btn = nil,
    m_tempPos = nil,
    m_clickCallFunc = nil,
    m_skipFunc = nil,
};
--[[--
    销毁
]]
function guide_dialog_pop.destroy(self)
    -- body
    cclog("-----------------drama_dialog_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_endCallFunc = nil;
    self.m_root_layer = nil;
    self.m_mask_node = nil;
    self.m_arrow_spri =nil;
    self.m_startPos = nil;
    self.m_size = nil;
    self.m_showArrowFlag = nil;
    self.m_tempNode = nil;
    self.m_skip_btn = nil;
    self.m_clickFunc = nil;
    self.m_skipFunc = nil;
    -- self.m_tempPos = nil;
end
--[[--
    返回
]]
function guide_dialog_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    if self.m_endCallFunc and type(self.m_endCallFunc) == "function" then
        self.m_endCallFunc();
    end
	-- self:destroy();
    game_scene:removePopByName("guide_dialog_pop");
end
--[[--
    读取ccbi创建ui
]]
function guide_dialog_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--跳过
            game_util:closeAlertView();
            local t_params = 
            {
                title = string_config.m_title_prompt,
                okBtnCallBack = function(target,event)
                    game_util:closeAlertView();
                    game_scene:removeGuidePop();
                    if type(self.m_skipFunc) == "function" then
                        self.m_skipFunc()
                    else 
                        game_guide_controller:skipCurrentGameGuide();
                    end
                end,   --可缺省
                closeCallBack = function(target,event)
                    game_util:closeAlertView();
                end,
                okBtnText = string_config.m_btn_sure,       --可缺省
                text = string_helper.guide_dialog_pop.jumpOver,      --可缺省
                touchPriority = -10002,
            }
            game_util:openAlertView(t_params);
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guide_dialog.ccbi");
    self.m_skip_btn = ccbNode:controlButtonForName("m_skip_btn");
    self.m_mask_node = ccbNode:nodeForName("m_mask_node")
    self.m_arrow_spri = ccbNode:spriteForName("m_arrow_spri")
    if self.m_showArrowFlag then
        self.m_arrow_spri:setVisible(false);
        -- local m_arrow_spri_size = self.m_arrow_spri:getContentSize();
        -- local startPos = ccp(self.m_startPos.x + self.m_size.width*0.5,self.m_startPos.y + self.m_size.height + m_arrow_spri_size.height*0.5);
        -- local endPos = ccp(self.m_startPos.x + self.m_size.width*0.5,self.m_startPos.y + self.m_size.height + m_arrow_spri_size.height*1);
        -- self.m_arrow_spri:setPosition(startPos);
        -- self.m_arrow_spri:runAction(game_util:createRepeatForeverMove(startPos,endPos));  

        local yindao_shouzhi = game_util:createImpactAnim("yindao_shouzhi",1)  
        local pX,pY = self.m_startPos.x + self.m_size.width*0.5,self.m_startPos.y + self.m_size.height*0.5;
        yindao_shouzhi:setAnchorPoint(ccp(0.5,0.5));
        if self.m_tempPos == nil then
            yindao_shouzhi:setPosition(ccp(pX,pY));
            self.m_tempPos = {x = pX,y = pY};
        else
            yindao_shouzhi:setPosition(ccp(self.m_tempPos.x, self.m_tempPos.y));
            yindao_shouzhi:runAction(CCMoveTo:create(0.5,ccp(pX,pY)));
            self.m_tempPos = {x = pX,y = pY};
        end
        ccbNode:addChild(yindao_shouzhi,100,100);
    else
        self.m_arrow_spri:setVisible(false);
    end

    local rect = CCRectMake(self.m_startPos.x,self.m_startPos.y,self.m_size.width,self.m_size.height);
    self.m_mask_node:addChild(createMaskTexture(self.m_size.width,self.m_size.height,self.m_startPos));

    self.m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if rect:containsPoint(ccp(x,y)) then
                if self.m_clickCallFunc and type(self.m_clickCallFunc) == "function" then
                    self.m_clickCallFunc();
                end
                return false
            end
            return true;--intercept event
        end
    end
    local team = game_guide_controller:getGuideTeam();
    local id = game_guide_controller:getGuideId();
    if team == "1" and id < 8 then
        self.m_skip_btn:setVisible(false);
    end
    self.m_skip_btn:setTouchPriority(-10001);
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,-10000,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function guide_dialog_pop.refreshUi(self)
    self.m_skip_btn:setVisible(false)
end

--[[--
    初始化
]]
function guide_dialog_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_endCallFunc = t_params.endCallFunc;
    self.m_startPos = t_params.startPos;
    self.m_size = t_params.size;
    self.m_showArrowFlag = t_params.showArrowFlag or true;
    self.m_tempNode = t_params.tempNode;
    self.m_clickCallFunc = t_params.clickCallFunc
    self.m_skipFunc = t_params.skipFunc
    if self.m_tempNode then
        local boundingBox = self.m_tempNode:boundingBox();
        self.m_startPos = ccp(boundingBox:getMinX(),boundingBox:getMinY())
        self.m_startPos = self.m_tempNode:getParent():convertToWorldSpace(self.m_startPos);
        self.m_size = self.m_tempNode:getContentSize()
        local scaleX,scaleY = self.m_tempNode:getScaleX(),self.m_tempNode:getScaleY()
        self.m_size = CCSizeMake(self.m_size.width*scaleX, self.m_size.height*scaleY)
    end
end

--[[--
    创建ui入口并初始化数据
]]
function guide_dialog_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return guide_dialog_pop;