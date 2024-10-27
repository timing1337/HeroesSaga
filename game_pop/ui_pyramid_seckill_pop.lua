--- 金字塔战胜提示  秒杀

local ui_pyramid_seckill_pop = {
    m_gameData = nil,
    m_showFlag = nil,
    m_ccbNode = nil,
    m_canTouch = nil,
};

--[[--
    销毁ui
]]
function ui_pyramid_seckill_pop.destroy(self)
    -- body
    cclog("-----------------ui_pyramid_seckill_pop destroy-----------------");
    self.m_gameData = nil;
    self.m_showFlag = nil;
    self.m_ccbNode = nil;
    self.m_canTouch = nil;
end
--[[--
    返回
]]
function ui_pyramid_seckill_pop.back(self,backType)
    game_scene:removePopByName("ui_pyramid_seckill_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_pyramid_seckill_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pyramid_seckill_pop.ccbi");

    self.m_node_winboard = ccbNode:nodeForName("m_node_winboard")
    self.m_node_titleboard = ccbNode:labelTTFForName("m_node_titleboard")
    self.m_node_titleboard:setVisible(false)

    self.m_node_secinfoboard = ccbNode:nodeForName("m_node_secinfoboard")


    


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if not self.m_canTouch then return true end
            if self.m_showFlag == true then return true end
            self.m_showFlag = true
            self.m_ccbNode:runAnimations("getoff")
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    m_root_layer:setTouchEnabled(true);


    local function animEndCallFunc(animName)
        if animName == "comein" then

            do 
                local viewSize = self.m_node_secinfoboard:getContentSize()
                local scrollView = CCScrollView:create(viewSize);
                scrollView:setDirection(kCCScrollViewDirectionHorizontal);
                self.m_node_secinfoboard:addChild(scrollView,2,2);

                local tempNode = CCNode:create()
                tempNode:setContentSize(viewSize)
                scrollView:getContainer():addChild(tempNode)
                scrollView:setTouchEnabled(false)

                local ccbNode = luaCCBNode:create();
                local function onMainBtnClick( target,event )
                end
                ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
                ccbNode:openCCBFile("ccb/ui_pyramid_seckill_msg_item.ccbi")
                ccbNode:setAnchorPoint(ccp(0.5, 0.5))
                ccbNode:setPosition(ccp( viewSize.width * 0.5 ,  viewSize.height * 0.5))
                tempNode:addChild(ccbNode,10,10)

                ccbNode:setPosition(ccp( viewSize.width * 1.3 ,  viewSize.height * 0.5))
                ccbNode:runAction( CCMoveTo:create(0.2, ccp( viewSize.width * 0.5 ,  viewSize.height * 0.5)) )

                scrollView:setPosition(ccp( viewSize.width * -0.8 , 0))
                scrollView:runAction( CCMoveTo:create(0.2, ccp( 0  ,  0)) )

                local m_blabel_levelname = ccbNode:labelBMFontForName("m_blabel_levelname")
                if m_blabel_levelname then
                    m_blabel_levelname:setString( tostring(game_util:convertNum2Chinese( self.m_gameData ))  )
                end

            end

            self.m_canTouch = true
        elseif animName == "getoff" then
            self:back()
        end
    end
    ccbNode:registerAnimFunc(animEndCallFunc)

    self.m_ccbNode = ccbNode
    return ccbNode;
end

--[[--
    刷新ui
]]
function ui_pyramid_seckill_pop.refreshUi(self)

end
--[[--
    初始化
]]
function ui_pyramid_seckill_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = t_params.enterFloor or 20
end

--[[--
    创建ui入口并初始化数据
]]
function ui_pyramid_seckill_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_pyramid_seckill_pop;