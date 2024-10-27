--- 新卡牌加入牌库提示

local ui_gacha_1or10_newtip_pop = {
    m_gameData = nil,
    m_list_view_bg = nil,
    m_mask_layer = nil,
    m_gachaAnimTab = nil,
    m_curPage = nil,
    m_animStartPos = nil,
    m_addCard = nil,
    m_spr_playername = nil,
};

--[[--
    销毁ui
]]
function ui_gacha_1or10_newtip_pop.destroy(self)
    -- body
    cclog("-----------------ui_gacha_1or10_newtip_pop destroy-----------------");
    self.m_gameData = nil;
    self.m_list_view_bg = nil;
    self.m_mask_layer = nil
    self.m_gachaAnimTab = nil
    self.m_curPage = nil;
    self.m_animStartPos = nil;
    self.m_addCard = nil;
    self.m_spr_playername = nil;
end
--[[--
    返回
]]
function ui_gacha_1or10_newtip_pop.back(self,backType)
    game_scene:removePopByName("ui_gacha_1or10_newtip_pop");
end

--[[--
    读取ccbi创建ui
]]
function ui_gacha_1or10_newtip_pop.createUi(self)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_gacha_1or10_res.plist")
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_gacha_newcard_tip_pop.ccbi");
    self.m_node_anim = ccbNode:nodeForName("m_node_anim")
    self.m_mask_layer = ccbNode:layerColorForName("m_mask_layer");
    self.m_spr_playername = ccbNode:spriteForName("m_spr_playername")


    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back()
            cclog2("self   back    --------------------- ")
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 13,true);
    m_root_layer:setTouchEnabled(true);


    return ccbNode;
end



function ui_gacha_1or10_newtip_pop.addGachaAnim(self,quality)
    self:removeGachaAnim();
    self:createTipHeroAnim( 4800 )
    local quality = 4 
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
    end
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then

        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            self.m_node_anim:setVisible(true);
            animNode:playSection("xunhuan");
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    m_iAnim:setPosition(ccp(self.m_animStartPos.x, self.m_animStartPos.y))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    cclog("addGachaAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    -- m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
    -- game_scene:getPopContainer():addChild(m_iAnim,10,10);
    self.m_mask_layer:addChild(m_iAnim,10,10);
    self.m_gachaAnimTab[#self.m_gachaAnimTab+1] = m_iAnim
end


--[[--
    创建
]]
function ui_gacha_1or10_newtip_pop.createTipHeroAnim(self)

    -- [5,7700,1]
    -- cardId = 7700
    local cardId  = nil
    if self.m_addCard then
        cardId = self.m_addCard:getNodeAt(1):toInt()
        cclog2("will show new card  tips   and card id   ======   ", cardId)
    end

    local card_spr_name = "ui_ga_ncard_" .. tostring(cardId) .. ".png"
    local card_name = "ui_ga_ncard_name_" .. tostring(cardId) .. ".png"
    self.m_node_anim:removeAllChildrenWithCleanup(true);
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(card_spr_name)
    if frame then
        local spr = CCSprite:createWithSpriteFrame(frame)
        spr:setScale(1.2)
        spr:setAnchorPoint(ccp(0.5, 0))
        self.m_node_anim:addChild(spr);
    end
    self.m_node_anim:setVisible(false)

    local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(card_name)
    if self.m_spr_playername and tempFrame then
        self.m_spr_playername:setDisplayFrame(tempFrame)

    end
end


function ui_gacha_1or10_newtip_pop.removeGachaAnim( self )
    -- body
end


--[[--
    刷新ui
]]
function ui_gacha_1or10_newtip_pop.refreshUi(self)
    self:addGachaAnim()
end
--[[--
    初始化
]]
function ui_gacha_1or10_newtip_pop.init(self,t_params)
    t_params = t_params or {};

    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    self.m_animStartPos = t_params.animStartPos or ccp(visibleSize.width*0.8, visibleSize.height*0.5)

    self.m_gachaAnimTab = {}
    self.m_addCard = t_params.addCard

end

--[[--
    创建ui入口并初始化数据
]]
function ui_gacha_1or10_newtip_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi()
    self:refreshUi();
    return self.m_popUi;
end

return ui_gacha_1or10_newtip_pop;