---  对话 

local drama_dialog_pop = {
    m_popUi = nil,
    m_callFunc = nil,
    m_dramaId = nil,
    m_endCallFunc = nil,
    m_root_layer = nil,
    m_skip_btn = nil,
    m_next_btn = nil,

    m_tempNode = nil,
    m_isShowMask =nil,
    m_colorlayer_black = nil,
};
--[[--
    销毁
]]
function drama_dialog_pop.destroy(self)
    -- body
    cclog("-----------------drama_dialog_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_callFunc = nil;
    self.m_dramaId = nil;
    self.m_endCallFunc = nil;
    self.m_root_layer = nil;
    self.m_skip_btn = nil;
    self.m_next_btn = nil;

    self.m_tempNode = nil;
    self.m_isShowMask = nil;
    self.m_colorlayer_black = nil;
end
--[[--
    返回
]]
function drama_dialog_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end

    cclog("type(self.m_endCallFunc) =================== " .. tostring(type(self.m_endCallFunc)))
    if self.m_endCallFunc and type(self.m_endCallFunc) == "function" then
        self.m_endCallFunc();
    end

    game_scene:removePopByName("drama_dialog_pop");
	-- self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function drama_dialog_pop.createUi(self)
    local drama_config = getConfig(game_config_field.drama):getNodeWithKey(tostring(self.m_dramaId));
    local dialogDetail = drama_config:getNodeWithKey("drama_detail");
    local nodeCount = dialogDetail:getNodeCount();
    local nodeIndex = 0;
    local dialogCCBNode = luaCCBNode:create();
    local m_node1,m_node2,m_name,m_detail;
    
     function dialog_tick()
        -- body
        if(nodeIndex>=nodeCount) then--完成
            self:back();
            return;
        end
        m_node1:removeAllChildrenWithCleanup(true);
        m_node2:removeAllChildrenWithCleanup(true);
        local tempNode = dialogDetail:getNodeAt(nodeIndex);
        local imgName = tempNode:getNodeAt(2):toStr()
        local sprite = nil;
        if imgName == "-1" then
            sprite = game_util:createOwnBigImgHalf()
            local playerName = game_data:getUserStatusDataByKey("show_name") or "";
            m_name:setString(tostring(playerName));
            if sprite then
                -- sprite:setScale(0.65);
                sprite:setScale(1.5);
            end
        else
            m_name:setString(tempNode:getNodeAt(1):toStr());
            sprite = CCSprite:create("humen/" .. imgName .. "_half.png");
            if sprite == nil then
                sprite = game_util:createImgByName(imgName,nil,false)
                if sprite then
                    sprite:setScale(1.5)
                end
            end
        end
        cclog("---------------------dialog image------------------" .. imgName .. " ; self.m_dramaId ==" .. self.m_dramaId);
        if sprite then
            if(tempNode:getNodeAt(3):toInt()==0)then
                m_node1:addChild(sprite);
            else
                sprite:setFlipX(true);
                m_node2:addChild(sprite);
            end
        end
        m_detail:setString(tempNode:getNodeAt(0):toStr());
        nodeIndex = nodeIndex+1;
    end

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--跳过
            nodeIndex = nodeCount;
            dialog_tick();
        elseif btnTag == 2 then--next
            -- dialog_tick();
        end
    end
    dialogCCBNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    dialogCCBNode:openCCBFile("ccb/ui_drama_dialog.ccbi");
    m_node1 = tolua.cast(dialogCCBNode:objectForName("m_node1"),"CCNode");
    m_node2 = tolua.cast(dialogCCBNode:objectForName("m_node2"),"CCNode");
    m_name =  tolua.cast(dialogCCBNode:objectForName("m_name"),"CCLabelTTF");
    m_detail = tolua.cast(dialogCCBNode:objectForName("m_detail"),"CCLabelTTF");
    self.m_root_layer = dialogCCBNode:layerForName("m_root_layer");
    self.m_skip_btn = dialogCCBNode:controlButtonForName("m_skip_btn");
    self.m_skip_btn:setVisible(false);
    self.m_next_btn = dialogCCBNode:controlButtonForName("m_next_btn");

    self.m_colorlayer_black = dialogCCBNode:layerForName("m_colorlayer_black")
    self.m_mask_node = dialogCCBNode:nodeForName("m_mask_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            cclog2(" onTouch  ")
            dialog_tick();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 99,true);
    self.m_root_layer:setTouchEnabled(true);
    self.m_skip_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 100);
    -- self.m_next_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    dialog_tick();

    cclog2(self.m_tempNode ,  "   self.m_tempNode    ====   ")

    if self.m_isShowMask and self.m_tempNode then
        local size , point = self:getMaskInfo( self.m_tempNode )
        if size and point then
            self.m_colorlayer_black:setVisible(false)
            self.m_mask_node:addChild(game_util:createMask(size.width, size.height, point))
        end
    else
        self.m_colorlayer_black:setVisible(true)
    end


    return dialogCCBNode;
end



--[[--
    刷新ui
]]
function drama_dialog_pop.refreshUi(self)

end

--[[--
    初始化
]]
function drama_dialog_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_callFunc = t_params.callFunc;
    self.m_dramaId = t_params.dramaId;
    self.m_endCallFunc = t_params.endCallFunc;

    if t_params.isShowMask == true then
        self.m_isShowMask = true
        self.m_tempNode = t_params.tempNode;
    end
end

function drama_dialog_pop.getMaskInfo( self, maskNodeBoard )
    if maskNodeBoard then
        local boundingBox = maskNodeBoard:boundingBox();
        m_startPos = ccp(boundingBox:getMinX(),boundingBox:getMinY())
        m_startPos = maskNodeBoard:getParent():convertToWorldSpace(m_startPos);
        local size = maskNodeBoard:getContentSize()
        local scaleX,scaleY = maskNodeBoard:getScaleX(),maskNodeBoard:getScaleY()
        size = CCSizeMake(size.width*scaleX, size.height*scaleY)
        return size , m_startPos
    end
    return nil
end

--[[--
    创建ui入口并初始化数据
]]
function drama_dialog_pop.create(self,t_params)
    self:init(t_params);
    local drama_config = getConfig(game_config_field.drama):getNodeWithKey(tostring(self.m_dramaId));
    if drama_config == nil then
        cclog("drama_config ============ " .. tostring(drama_config) .. " ;  self.m_dramaId = " .. tostring(self.m_dramaId))
        self:back();
        return nil;
    end
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return drama_dialog_pop;