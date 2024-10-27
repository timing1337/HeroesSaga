--- 游戏公共方法集合
local tostring,os,type,pairs,math,tonumber = tostring,os,type,pairs,math,tonumber
local M = {};
require "shared.extern"

--[[--
    创建待机动画
]]
function M.createBattleIdelAnim(self,animFile,animId,cardData,cardCfg,equipData,animNode)
    return self:createIdelAnim(animFile,animId,cardData,cardCfg,equipData,animNode)
end

--[[--
    播放动作
]]
function M.playSection(self,animNode,name,state)

    local curSectionName = animNode:getCurSectionName();
    -- if(M:isPlayTheAction(name,anim_label_name_cfg.siwang))then
    --     cclog("----------game_util:playSection->siwang " .. curSectionName);
    -- else
    --     cclog("----------game_util:playSection->" .. name);
    -- end
    if(M:isPlayTheAction(curSectionName,anim_label_name_cfg.siwang))then
        if (string.find(name,"gongji")==nil and string.find(name,"mofa")==nil) then
            return;
        end
    end

    if(state == 1) then
        name = name.."_2"
    end

    animNode:playSection(name)
end

--[[--
    判断当前动作是否是哪个动作
]]
function M.isPlayTheAction(self,curLable,isLable)
    if(curLable == isLable) then
        return true
    elseif(curLable == (isLable.."_2")) then
        return true
    else
        return false
    end
end

--[[--
    创建待机动画
        animFile(string):动画名，无后缀名
        animId(int):动画id
        cardData(table):单张卡牌数据 
        cardCfg(json):单张卡牌的详情配置
        equipData(table):卡牌位置上的装备  可为nil
]]
function M.createIdelAnim(self,animFile,animId,cardData,cardCfg,equipData,animNode)
    if cardData and equipData == nil then
        equipData = game_data:getEquipDataByCardId(cardData.id);
    end

    animId = animId or 0;
    local m_iAnim = animNode;
    -- cclog("M.createIdelAnim() animFile =====" .. animFile .. " ; animId ==" .. animId)
    if(m_iAnim == nil) then
       -- cclog("m_iAnim == nil")
       m_iAnim = game_util:createSortNode(animFile .. ".swf.sam",animId,animFile .. ".plist");
    end
    if m_iAnim == nil then 
        m_iAnim = game_util:createUnknowIdelAnim(animFile,animId);
        animFile = "unknow";
    end
    if cardCfg then
        local rgb = 0;
        if tolua.type(cardCfg) == "util_json" then
            rgb = cardCfg:getNodeWithKey("rgb_sort")
            if rgb then
                rgb = rgb:toInt();
            else
                rgb = 0;
            end
        else
            rgb = cardCfg.rgb_sort or 0;
        end
        if rgb == 1 then
            m_iAnim:setColor(ccc3(47,255,118));
        elseif rgb == 2 then
            m_iAnim:setColor(ccc3(67,117,253));
        elseif rgb == 3 then
            m_iAnim:setColor(ccc3(171,65,255));
        end
    end
    m_iAnim:setScale(public_config.anim_scale)
    local function animEnd(animNode,theId,labelName)
        animNode:playSection(anim_label_name_cfg.daiji);
    end
    local function qualityEnd(animNode,theId,labelName)
        animNode:playSection(labelName);
    end
    local function equipEnd( animNode,theId,labelName )
        -- body
        animNode:playSection(labelName);
    end
    local function crystalEnd( animNode,theId,labelName )
        -- body
        animNode:playSection(labelName);
    end
    local function stepEnd( animNode,theId,labelName )
        -- body
        animNode:playSection(labelName);
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    local function componentFunc( node,theId,flag,x,y )
        -- cclog("theId = " .. tostring(theId) .. " ; flag = " .. tostring(flag) .. " ; x = " .. tostring(x) .. " ; y = " .. tostring(y));
        local parentNode = node:getParent();
        local sz = node:getContentSize();

        local effect = parentNode:getChildByTag(1);     -- 粒子
        if(effect ~= nil) then
            effect:setPosition(ccp(x,y));
        end
        local quality = parentNode:getChildByTag(2);    -- 背后火焰
        if(quality ~= nil)then
            quality:setPosition(ccp(x,y));
        end
        local equip = parentNode:getChildByTag(3);
        if(equip~=nil)then
            equip:setPosition(ccp(x,y+sz.height/2));
        end
        local crystal = parentNode:getChildByTag(4);
        if(crystal~=nil)then
            crystal:setPosition(ccp(x,y));
        end
        local stepAnim = parentNode:getChildByTag(5);
        if(stepAnim~=nil)then
            stepAnim:setPosition(ccp(x,y));
        end
    end

    m_iAnim:registerComponent(componentFunc);
    m_iAnim:setComponentId(animFile .. ".swf1.png");    -- 绑定影子
    m_iAnim:playSection(anim_label_name_cfg.daiji);
    --m_iAnim:setScale(1);

    if(cardData==nil)then
        return m_iAnim;
    end

    -- 添加特效

    local sz = m_iAnim:getContentSize();

    -- 添加进阶特效
    local stepAnim = nil;
    cardData.step = cardData.step or 0
    if(cardData.step>=20)then
        stepAnim = zcAnimNode:create("color_circle3.swf.sam",1,"color_circle3.plist");
        stepAnim:setColor(ccc3(248,0,0));
    elseif(cardData.step>=15)then
        stepAnim = zcAnimNode:create("color_circle3.swf.sam",1,"color_circle3.plist");
        stepAnim:setColor(ccc3(239,137,0));
    elseif(cardData.step>=10)then
        stepAnim = zcAnimNode:create("color_circle3.swf.sam",1,"color_circle3.plist");
        stepAnim:setColor(ccc3(233,104,213));
    end

    cclog("--------- step " .. tostring(cardData.step));

    if(stepAnim)then
        stepAnim:setPosition(ccp(sz.width/2,0));
        stepAnim:registerScriptTapHandler(stepEnd);
        stepAnim:playSection("impact");
        m_iAnim:addChild(stepAnim,-1,5);
    end

    
    -- 添加品阶
    -- local cardQuality = cardCfg:getNodeWithKey("quality"):toInt()
    -- if(cardQuality >= 3)then
    --     local iEffect = luaCCBNode:create();
    --     iEffect:openCCBFile("ccb/effect_fire.ccbi");
    --     iEffect:setPosition(ccp(sz.width/2,0));
    --     m_iAnim:addChild(iEffect,-2,1);

    --     local iQuality = zcAnimNode:create("color_fire" .. tostring(cardQuality) .. ".swf.sam",1,"color_fire" .. tostring(cardQuality) .. ".plist");
    --     iQuality:setPosition(ccp(sz.width/2,0));
    --     iQuality:playSection("impact");
    --     iQuality:registerScriptTapHandler(qualityEnd);
    --     m_iAnim:addChild(iQuality,-1,2);
    -- end
    -- 添加套装特效
    -- if(equipData~=nil)then
    --     local equipQuality = 0;
    --     local equip_config = getConfig(game_config_field.equip);
    --     local equipCount = 0;
    --     for k,v in pairs(equipData) do
    --         if(v==0)then
    --             break;
    --         end
    --         if(k==1)then
    --             equipQuality = equip_config:getNodeWithKey(tostring(v['c_id'])):getNodeWithKey("quality"):toInt();
    --         else
    --             if(equipQuality~=equip_config:getNodeWithKey(tostring(v['c_id'])):getNodeWithKey("quality"):toInt())then
    --                 break;
    --             end
    --         end
    --         equipCount=equipCount+1;
    --     end
    --     if(equipCount>=4)then
    --         local iEquip = zcAnimNode:create("color_light" .. tostring(equipQuality) .. ".swf.sam",1,"color_light" .. tostring(equipQuality) .. ".plist");
    --         if iEquip then
    --             iEquip:setPosition(ccp(sz.width/2,sz.height/2));
    --             iEquip:playSection("impact");
    --             iEquip:registerScriptTapHandler(equipEnd);
    --             m_iAnim:addChild(iEquip,1,3);
    --         end
    --     end
    -- end
    -- 添加能晶特效
    -- local cardCrystal={0,0,0,0,0};
    -- if(cardData["patk_crystal"]~=nil)then
    --     cardCrystal[1]=cardData["patk_crystal"];
    -- end
    -- if(cardData["matk_crystal"]~=nil)then
    --     cardCrystal[2]=cardData["matk_crystal"];
    -- end
    -- if(cardData["def_crystal"]~=nil)then
    --     cardCrystal[3]=cardData["def_crystal"];
    -- end
    -- if(cardData["speed_crystal"]~=nil)then
    --     cardCrystal[4]=cardData["speed_crystal"];
    -- end
    -- if(cardData["hp_crystal"]~=nil)then
    --     cardCrystal[5]=cardData["hp_crystal"];
    -- end
    -- local CrystalFlag = cardCrystal[1];
    -- for k,v in pairs(cardCrystal) do
    --     if(v<CrystalFlag)then
    --         CrystalFlag=v;
    --     end
    -- end
    -- CrystalFlag = math.floor(CrystalFlag/4);
    -- if(CrystalFlag>=0)then
    --     local iCrystal = zcAnimNode:create("color_circle3.swf.sam",1,"color_circle3.plist");
    --     iCrystal:setPosition(ccp(sz.width/2,0));
    --     iCrystal:playSection("impact");
    --     iCrystal:registerScriptTapHandler(crystalEnd);
    --     m_iAnim:addChild(iCrystal,-3,4);
    -- end
    return m_iAnim;
end
--[[--
    创建暂停的卡牌动画
]]
function M.createPauseAnim(self,animFile,animId,cardData,cardCfg)
    local m_iAnim = self:createIdelAnim(animFile,animId,cardData,cardCfg);
    if m_iAnim == nil then return nil end
    m_iAnim:pause();
    return m_iAnim;
end
--[[--
    创建卡牌动画序列
]]
function M.createAnimSequence(self,animFile,animId,cardData,cardCfg)
    local m_iAnim = self:createIdelAnim(animFile,animId,cardData,cardCfg);
    local function animEnd(animNode,theId,lableName)
        if lableName == anim_label_name_cfg.daiji then
            animNode:playSection(anim_label_name_cfg.gongji1);
        elseif lableName == anim_label_name_cfg.gongji1 then
            animNode:playSection(anim_label_name_cfg.gongji2);
        elseif lableName == anim_label_name_cfg.gongji2 then
            animNode:playSection(anim_label_name_cfg.daiji);
        end
    end
    if m_iAnim then
        m_iAnim:registerScriptTapHandler(animEnd);
        m_iAnim:playSection(anim_label_name_cfg.daiji);
        m_iAnim:setScale(1);
    end
    return m_iAnim;
end

--[[--
    创建未知卡牌动画
]]
function M.createUnknowIdelAnim(self,animFile,nanimId)
    animFile = "unknow";
    local animId = nanimId;
    if(animId == nil)then
        animId = 0;
    end
    local m_iAnim = game_util:createSortNode(animFile .. ".swf.sam",animId,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        animNode:playSection(lableName);
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("impact");
    m_iAnim:setScale(1);
    return m_iAnim;
end
--[[--
    判断id是否在table中
]]
function M.idInTableById(self,id,idTable)
    idTable = idTable or {};
    for k,v in pairs(idTable) do
        if v ~= 0 and tostring(v) == tostring(id) then
            return true,k;
        end
    end
    return false,nil;
end
--[[--
    判断卡牌id是否在table中
]]
function M.heroInTeamById(self,heroId,teamIdTable)
    teamIdTable = teamIdTable or {}
    for k,v in pairs(teamIdTable) do
        if v ~= "-1" and tostring(v) == tostring(heroId) then
            return true;
        end
    end
    return false;
end
--[[--
    判断只是否在table中
]]
function M.valueInTeam(self,value,tableValue)
    tableValue = tableValue or {};
    for k,v in pairs(tableValue) do
        if tostring(v) == tostring(value) then
            return true;
        end
    end
    return false;
end
--[[--
    从table中移除指定的值
]]
function M.removeValueInTeam(self,value,tableValue)
    tableValue = tableValue or {};
    local kTemp = nil;
    for k,v in pairs(tableValue) do
        if tostring(v) == tostring(value) then
            kTemp = k;
            break;
        end
    end
    table.remove(tableValue,kTemp);
end
--[[--
    创建提示文字
]]
function M.createTips(self,msg)
    local bgW,bgH = 120,80;
    local bgLayer = CCLayerColor:create(ccc4(155,155,155,255),bgW,bgH);
    local msgLabel = CCLabelTTF:create(msg,TYPE_FACE_TABLE.Arial_BoldMT,10,CCSizeMake(bgW,bgH),kCCTextAlignmentLeft);
    msgLabel:setPosition(bgW*0.5,bgH*0.5);
    bgLayer:addChild(msgLabel);
    return bgLayer;
end
--[[--
    创建移动的提示文字
]]
function M.addMoveTips(self,t_params)
    t_params = t_params or {};
    t_params.text = t_params.text or ""
    t_params.fontSize = t_params.fontSize or 14
    -- t_params.color = t_params.color or ccc3(250,180,0)
    local colorType = t_params.colorType or "";
    if colorType == "" then
        t_params.color = ccc3(250,230,0)
    elseif colorType == "red" then
        t_params.color = ccc3(250,0,0)
    end
    local winSize = CCDirector:sharedDirector():getWinSize();
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png");
    tempBg:setPreferredSize(CCSizeMake(winSize.width*0.5, winSize.height*0.1));
    tempBg:setPosition(ccp(winSize.width*0.5, winSize.height*0.5))
    local msgLabel = CCLabelTTF:create(t_params.text,TYPE_FACE_TABLE.Arial_BoldMT,t_params.fontSize);
    msgLabel:setDimensions( CCSizeMake( winSize.width * 0.9, 0 ) )
    msgLabel:setColor(t_params.color)
    msgLabel:setPosition(winSize.width*0.25,winSize.height*0.05);
    tempBg:addChild(msgLabel);
    local function remove_node( node )
        -- body
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(winSize.width*0.5,winSize.height*0.7)),5));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(remove);
    tempBg:runAction(CCSequence:create(arr));
    game_scene:getPopContainer():addChild(tempBg,100000);
end
--[[
    一连串的文字提示
]]
function M.addQueneMoveTips(self,t_params,delayTime)
    delayTime = delayTime or 0
    t_params = t_params or {};
    local winSize = CCDirector:sharedDirector():getWinSize();
    t_params.text = t_params.text or ""
    local colorType = t_params.colorType or "";
    if colorType == "" then
        t_params.color = ccc3(250,230,0)
    elseif colorType == "red" then
        t_params.color = ccc3(250,0,0)
    end
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_numBg.png");
    local function createTips()
        tempBg:setPreferredSize(CCSizeMake(winSize.width*0.5, winSize.height*0.1));
        tempBg:setPosition(ccp(winSize.width*0.5, winSize.height*0.5))
        local msgLabel = CCLabelTTF:create(t_params.text,TYPE_FACE_TABLE.Arial_BoldMT,16);
        msgLabel:setColor(t_params.color)
        msgLabel:setPosition(winSize.width*0.25,winSize.height*0.05);
        tempBg:addChild(msgLabel);
    end
    local function remove_node( node )
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    arr:addObject(CCDelayTime:create(delayTime));
    arr:addObject(CCCallFuncN:create(createTips));
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(winSize.width*0.5,winSize.height*0.7)),5));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(remove);
    tempBg:runAction(CCSequence:create(arr));
    game_scene:getPopContainer():addChild(tempBg,100000);
end
--[[
    提示新命运开启
]]
function M.addQueneOpenTips(self,t_params,delayTime)
    delayTime = delayTime or 0
    t_params = t_params or {};
    local winSize = CCDirector:sharedDirector():getWinSize();
    t_params.text = t_params.text or ""
    local colorType = t_params.colorType or "";
    t_params.color = ccc3(247,202,35)
    local tempBg = CCScale9Sprite:createWithSpriteFrameName("public_selectBg.png");
    local function createTips()
        tempBg:setPreferredSize(CCSizeMake(winSize.width*0.5, winSize.height*0.1));
        tempBg:setPosition(ccp(winSize.width*0.5, winSize.height*0.5))
        local msgLabel = CCLabelTTF:create(t_params.text,TYPE_FACE_TABLE.Arial_BoldMT,16);
        msgLabel:setColor(t_params.color)
        msgLabel:setPosition(winSize.width*0.25,winSize.height*0.05);
        tempBg:addChild(msgLabel);
    end
    tempBg:setScaleY(0)
    local function remove_node( node )
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    arr:addObject(CCDelayTime:create(delayTime));
    arr:addObject(CCCallFuncN:create(createTips));
    -- arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(winSize.width*0.5,winSize.height*0.7)),5));
    arr:addObject(CCScaleTo:create(0.3,1,1.2));
    arr:addObject(CCScaleTo:create(0.1,1,1));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCScaleTo:create(0.3,1,0));
    arr:addObject(remove);
    tempBg:runAction(CCSequence:create(arr));
    game_scene:getPopContainer():addChild(tempBg,100000);
end
--[[--
    创建native可移动的文字
]]
function M.addMoveTipsForNative(self,params)
    local function callback()
        game_util:addMoveTips(params)
    end
    performWithDelay(CCDirector:sharedDirector():getRunningScene(),callback,0)
end
--[[--
    创建移动的提示
]]
function M.addMoveTipsByNode(self,node,delayTime,callBackFunc)
    if node == nil then return end
    delayTime = delayTime or 0;
    local winSize = CCDirector:sharedDirector():getWinSize();
    node:ignoreAnchorPointForPosition(false);
    node:setAnchorPoint(ccp(0.5,0.5));
    node:setPosition(winSize.width*0.5,winSize.height*0.5);
    local function remove_node( node )
        -- body
        node:removeFromParentAndCleanup(true);
        if callBackFunc then
            callBackFunc();
        end
    end
    node:setVisible(false);
    local arr = CCArray:create();
    arr:addObject(CCDelayTime:create(delayTime));
    arr:addObject(CCShow:create());
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(winSize.width*0.5,winSize.height*0.7)),5));
    -- arr:addObject(CCDelayTime:create(1.0));
    arr:addObject(CCScaleTo:create(1.0,0));
    arr:addObject(CCCallFuncN:create(remove_node));
    node:runAction(CCSequence:create(arr));
    game_scene:getPopContainer():addChild(node,delayTime + 100000);
end
--[[--
    添加提示动画
]]
function M.addTipsAnimByType(self,parentNode,typeValue)
    if parentNode == nil then return end
    local rhythm = rhythm or 1.0;
    local loopFlag = true;
    local animFile = "tips_reward";
    if typeValue == 2 then
        animFile = "tips_reward2";
    elseif typeValue == 3 then
        animFile = "tips_reward3";
    elseif typeValue == 4 then
        animFile = "tips_reward4";
        loopFlag = false;
    elseif typeValue == 5 then
        animFile = "anim_ui_dingshilingjiang";
    elseif typeValue == 6 then
        animFile = "anim_ui_gonggao";
    elseif typeValue == 7 then
        animFile = "anim_ui_huodong";
    elseif typeValue == 8 then
        animFile = "anim_ui_qiandao";
    elseif typeValue == 17 then
        animFile = "anim_ui_tongyong";
    -- elseif typeValue == 10 then
    --     animFile = "anim_ui_new";
    elseif typeValue == 9 or typeValue == 10 then
        local tips_reward = CCSprite:createWithSpriteFrameName("public_new2.png");
        if tips_reward then
            local tempSize = parentNode:getContentSize();
            tips_reward:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
            parentNode:addChild(tips_reward,1000,1000);
        end
        return tips_reward;
    elseif typeValue == 11 then
        animFile = "anim_ui_xuanshang";
    elseif typeValue == 12 then
        animFile = "anim_ui_renwu";
    elseif typeValue == 13 then
        animFile = "anim_ui_baoxianglingjiang";
    elseif typeValue == 14 then
    	animFile = "anim_ui_gantanhao"
    elseif typeValue == 15 then
        animFile = "anim_ui_libaotixing"
    elseif typeValue == 16 then--热门活动
        animFile = "anim_ui_remenhuodong"
    elseif typeValue == 18 then
        animFile = "anim_ui_fuli"
    end
    local tips_reward = game_util:createTipsAnim(animFile,rhythm,loopFlag);
    if tips_reward then
        local tempSize = parentNode:getContentSize();
        tips_reward:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5))
        parentNode:addChild(tips_reward,1000,1000);
    end
    return tips_reward;
end
--[[--
    创建提示动画
]]
function M.createTipsAnim(self,animFile,rhythm,loopFlag)
    if loopFlag == nil then loopFlag = false end
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if loopFlag then
            animNode:playSection(theLabelName)
        else
            animNode:getParent():removeFromParentAndCleanup(true);
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if mAnimNode then
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection("impact");
        mAnimNode:setRhythm(rhythm);
    end
    return mAnimNode;
end

--[[--
    创建通用动画
    game_util:createUniversalAnim({animFile = "",rhythm = 1.0,loopFlag = true,animCallFunc = nil});
]]
function M.createUniversalAnim(self,params)
    params = params or {};
    local animFile = params.animFile or ""
    local rhythm = params.rhythm or 1.0
    local actionName = params.actionName or "impact";
    local loopFlag = params.loopFlag == nil and false or params.loopFlag;
    local onAnimSectionEnd = params.animCallFunc;
    if onAnimSectionEnd == nil then
        onAnimSectionEnd = function(animNode, theId,theLabelName)
            if loopFlag then
                animNode:playSection(theLabelName)
            else
                animNode:getParent():removeFromParentAndCleanup(true);
            end
        end
    end
    local mAnimNode = SortNode:create(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if mAnimNode then
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection(actionName);
        mAnimNode:setRhythm(rhythm);
    end
    return mAnimNode;
end
--[[--
    创建特效--公会站  延时
]]
function M.createEffectAnimGvg(self,animFile,rhythm,loopFlag,delayTime)
    delayTime = delayTime or 0
    if loopFlag == nil then loopFlag = false end
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if loopFlag then
            animNode:playSection(theLabelName)
        else
            animNode:getParent():removeFromParentAndCleanup(true);
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if(mAnimNode == nil) then
        cclog("lack of "..animFile)
        mAnimNode = game_util:createSortNode("shouji_2.swf.sam",0,"shouji_2.plist");
    end
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    if delayTime > 0 then
        local function delyFunc()
            mAnimNode:playSection("impact");
        end
        local animArr = CCArray:create()
        animArr:addObject(CCDelayTime:create(delayTime));
        animArr:addObject(CCCallFunc:create(delyFunc));
        mAnimNode:runAction(CCSequence:create(animArr));
    else
        mAnimNode:playSection("impact");
    end
    mAnimNode:setRhythm(rhythm);
    return mAnimNode;
end
--[[--
    创建特效
]]
function M.createEffectAnim(self,animFile,rhythm,loopFlag)
    if loopFlag == nil then loopFlag = false end
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if loopFlag then
            animNode:playSection(theLabelName)
        else
            animNode:getParent():removeFromParentAndCleanup(true);
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if(mAnimNode == nil) then
        cclog("lack of "..animFile)
        mAnimNode = game_util:createSortNode("shouji_2.swf.sam",0,"shouji_2.plist");
    end
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("impact");
    mAnimNode:setRhythm(rhythm);
    -- mAnimNode:setScale(0.5);
    return mAnimNode;
end

--[[--
    创建特效
]]
function M.createEffectAnimCallBack(self,animFile,rhythm,loopFlag,callBackFunc)
    if loopFlag == nil then loopFlag = false end
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if loopFlag then
            animNode:playSection(theLabelName)
        else
            animNode:getParent():removeFromParentAndCleanup(true);
        end
        if callBackFunc then
            callBackFunc();
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if mAnimNode then
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection("impact");
        mAnimNode:setRhythm(rhythm);
    else
        if callBackFunc then
            callBackFunc();
        end
    end
    return mAnimNode;
end

--[[--
    创建分解特效
]]
function M.createSplitEffectAnim(self,animFile,rhythm,loopFlag,callFunc,node)
    if loopFlag == nil then loopFlag = false end
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if loopFlag then
            animNode:playSection(theLabelName)
        else
            if node ~= nil then
                node:setVisible(false)
                callFunc(node);
            else
                callFunc();
            end
            animNode:getParent():removeFromParentAndCleanup(true);
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if(mAnimNode == nil) then
        cclog("lack of "..animFile)
        mAnimNode = game_util:createSortNode("shouji_2.swf.sam",0,"shouji_2.plist");
    end
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("impact");
    mAnimNode:setRhythm(rhythm);
    return mAnimNode;
end
--[[--
    创建特效并添加到节点上
]]
function M.createEffectAnimAddToParent(self,parentNode,animFile,rhythm)
    local mAnimNode = self:createEffectAnim(animFile,rhythm)
    if(mAnimNode == nil) then
        cclog("createEffectAnimAddToParent->"..animFile)
        mAnimNode = self:createEffectAnim("shouji_2",rhythm)
    end
    local size = parentNode:getContentSize();
    mAnimNode:setPosition(ccp(size.width*0.5,size.height*0.5));
    parentNode:addChild(mAnimNode,1000,1000);
end
--[[--
    创建资源特效
]]
function M.createResourcesEffectAnim(self,animFile,rhythm,onAnimEnd)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if theLabelName == "daiji" then
            animNode:playSection(theLabelName);
        else
            animNode:getParent():removeFromParentAndCleanup(true);
            if onAnimEnd ~= nil then
                onAnimEnd(animFile);
            end
        end
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    mAnimNode:setAnchorPoint(ccp(0.5,0.5));
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection("daiji");
    mAnimNode:setRhythm(rhythm);
    -- mAnimNode:setScale(0.5);
    return mAnimNode
end
--[[--
    创建建筑上移动的人物动画
]]
function M.createBuildingPersonAnim(self,animFile,rhythm)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
    local mAnimNode = zcAnimNode:create(animFile .. ".swf.sam", 0, animFile.. ".plist");
    mAnimNode:setAnchorPoint(ccp(0.5,0.5));
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    -- mAnimNode:playSection("daiji");
    mAnimNode:playSection("xiazuo");
    mAnimNode:setRhythm(rhythm);
    -- mAnimNode:setScale(0.5);
    return mAnimNode
end
--[[--
    创建玩家角色的动画
]]
function M.createPlayerMapAnim(self,animFile,rhythm)
    return self:createPlayerRoleAnim(animFile,rhythm);
end


--[[--
    xiazuo xiayou shangzuo shangyou xiazuoD xiayouD shangzuoD shangyouD
    建筑上动画的移动
]]
function M.createBuildingPersonAnimMove(self,mAnimNode,pos,callBackFunc)
    if mAnimNode == nil then 
        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
        return;
    end
    mAnimNode:stopAllActions();
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    local pX,pY = mAnimNode:getPosition();
    local offsetX,offsetY = pos.x - pX,pos.y - pY;
    if offsetX > 0 then
        if offsetY > 0 then--右上
            mAnimNode:playSection("shangyou");
        elseif offsetY < 0 then--右下
            mAnimNode:playSection("xiayou");
        else
            mAnimNode:playSection("xiayouD");
        end
    else
        if offsetY > 0 then--左上
            mAnimNode:playSection("shangzuo");
        elseif offsetY < 0 then--左下
            mAnimNode:playSection("xiazuo");
        else
            mAnimNode:playSection("xiazuo");
        end
    end
    local function animEndCallFunc()
        local curSectionName = mAnimNode:getCurSectionName()
        if curSectionName == "shangyou" then
             mAnimNode:playSection("shangyouD");
        elseif curSectionName == "xiayou" then
             mAnimNode:playSection("xiayouD");
        elseif curSectionName == "shangzuo" then
             mAnimNode:playSection("shangzuoD");
        elseif curSectionName == "xiazuo" then
             mAnimNode:playSection("xiazuoD");
        end

        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
    end
    local pix = math.sqrt(math.pow(pos.x - pX, 2) + math.pow(pos.y - pY, 2));
    local moveTime = pix / 200;
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(moveTime,pos));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    mAnimNode:runAction(CCSequence:create(animArr));
end
--[[--
    xiazuo xiayou shangzuo shangyou xiazuoD xiayouD shangzuoD shangyouD
    建筑上动画的移动   有名字的
]]
function M.createBuildingPersonWithNameAnimMove(self,mAnimNode,callBackFunc,nameLabel,posList)
    if mAnimNode == nil then 
        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
        return;
    end
    mAnimNode:stopAllActions();
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    
    local function animEndCallFunc()
        local curSectionName = mAnimNode:getCurSectionName()
        if curSectionName == "shangyou" then
             mAnimNode:playSection("shangyouD");
        elseif curSectionName == "xiayou" then
             mAnimNode:playSection("xiayouD");
        elseif curSectionName == "shangzuo" then
             mAnimNode:playSection("shangzuoD");
        elseif curSectionName == "xiazuo" then
             mAnimNode:playSection("xiazuoD");
        end
        if callBackFunc and type(callBackFunc) == "function" then
            callBackFunc();
        end
    end
    
    local animArr = CCArray:create();
    local moveLabelArr = CCArray:create();
    for i=1,#posList do
        local pos = posList[i];
        local pX,pY = 0,0;
        if i == 1 then
            pX,pY = mAnimNode:getPosition();
        else
            pX,pY = posList[i-1].x,posList[i-1].y;
        end
        local offsetX,offsetY = pos.x - pX,pos.y - pY;
        if offsetX > 0 then
            if offsetY > 0 then--右上
                mAnimNode:playSection("shangyou");
            elseif offsetY < 0 then--右下
                mAnimNode:playSection("xiayou");
            else
                mAnimNode:playSection("xiayouD");
            end
        else
            if offsetY > 0 then--左上
                mAnimNode:playSection("shangzuo");
            elseif offsetY < 0 then--左下
                mAnimNode:playSection("xiazuo");
            else
                mAnimNode:playSection("xiazuo");
            end
        end
        local pix = math.sqrt(math.pow(pos.x - pX, 2) + math.pow(pos.y - pY, 2));
        local moveTime = pix / 200;
        animArr:addObject(CCMoveTo:create(moveTime,pos));
        moveLabelArr:addObject(CCMoveTo:create(moveTime,ccp(pos.x,pos.y+60)))
    end
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    mAnimNode:runAction(CCSequence:create(animArr));
    nameLabel:runAction(CCSequence:create(moveLabelArr));
end
--[[--
    创建buff效果动画
]]
function M.createBuffAnim(self,parentNode,animFile,rhythm)
    local mAnimNode = self:createImpactAnim(animFile,rhythm)
    local size = parentNode:getContentSize();
    mAnimNode:setPosition(ccp(size.width,size.height));
    parentNode:addChild(mAnimNode,1000,1000);
    return mAnimNode;
end
--[[--
    创建特效动画
]]
function M.createImpactAnim(self,animFile,rhythm)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if(mAnimNode == nil) then
        cclog("lack of "..animFile)
        mAnimNode = game_util:createSortNode("shouji_2.swf.sam",0,"shouji_2.plist");
    end
    if mAnimNode then
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection("impact");
        mAnimNode:setRhythm(rhythm);
        -- mAnimNode:setScale(0.5);
    end
    return mAnimNode;
end
--[[--
    格式化数字
]]
function M.formatValueToString(self,value,combFlag)
    combFlag = combFlag == nil and true or combFlag;
    local tempValue = "0";
    local unit = "";
    if type(value) == "string" then
        value = tonumber(value);
    end
    if value == nil or type(value) ~= "number" then
        return tempValue,unit;
    end
    if value > 0 and value < 1000000 then
        tempValue = tostring(value)
    elseif value >= 1000000 and value < 1000000000 then
        --if value < 10000000 then
            tempValue,unit = string.format("%.1f",value * 0.000001),string_helper.game_util.baiwan
        --else
        --    tempValue,unit = string.format("%.0f",value * 0.0001),"万"
        --end
    elseif value >= 100000000 then
        tempValue,unit = string.format("%.2f",value * 0.000000001),string_helper.game_util.shiyi
    end
    if combFlag then
        tempValue = tempValue .. unit
        unit = "";
    end
    return tempValue,unit;
end
--[[--
    格式化数字
]]
function M.formatValueToString2(self,value,combFlag)
    combFlag = combFlag == nil and true or combFlag;
    local tempValue = "0";
    local unit = "";
    if type(value) == "string" then
        value = tonumber(value);
    end
    if value == nil or type(value) ~= "number" then
        return tempValue,unit;
    end
    if value > 0 and value < 1000 then
        tempValue = tostring(value)
    elseif value >= 1000 and value < 100000000 then
        if value < 10000000 then
            tempValue,unit = string.format("%.1f",value * 0.001),"k"
        else
            tempValue,unit = string.format("%.0f",value * 0.0001),"万"
        end
    elseif value >= 100000000 then
        tempValue,unit = string.format("%.2f",value * 0.00000001),"亿"
    end
    if combFlag then
        tempValue = tempValue .. unit
        unit = "";
    end
    return tempValue,unit;
end

--[[--
    设置玩家单个属性
]]
function M.setPlayerProperty(self,m_label,m_value)
    if m_label ~= nil and m_value ~= nil then
        local value,unit = self:formatValueToString(m_value);
        if m_value >= 10000 then
            m_label:setString(value .. unit);
        else
            m_label:setString(value);
        end
    end
end

--[[--
    设置玩家属性栏信息
]]
function M.setPlayerPropertyByCCBAndTableData(self,ccbNode,user_status)
    if ccbNode == nil or user_status == nil or user_status.uid == nil then
        return;
    end
    local m_lightning_label = ccbNode:labelBMFontForName("m_lightning_label")
    if m_lightning_label ~= nil then
        m_lightning_label:setString(user_status.action_point .. "/" .. user_status.action_point_max);
    end
    local m_gem_label = ccbNode:labelBMFontForName("m_gem_label")
    local m_money_label = ccbNode:labelBMFontForName("m_money_label")
    -- local m_material_label = ccbNode:labelBMFontForName("m_material_label")
    -- local m_energy_label = ccbNode:labelBMFontForName("m_energy_label")
    self:setPlayerProperty(m_gem_label,user_status.coin);
    self:setPlayerProperty(m_money_label,user_status.food);
    -- self:setPlayerProperty(m_material_label,user_status.metal);
    -- self:setPlayerProperty(m_energy_label,user_status.energy);
    local m_head_icon_node = tolua.cast(ccbNode:objectForName("m_head_icon_node"), "CCNode");
    local sb_list = {}
    
    local m_player_name = tolua.cast(ccbNode:objectForName("m_player_name"), "CCLabelTTF");
    local m_exp_bar_bg = tolua.cast(ccbNode:objectForName("m_exp_bar_bg"), "CCSprite");
    local m_exp_label = ccbNode:labelBMFontForName("m_exp_label")


    local m_vip_node = ccbNode:nodeForName("m_vip_node")
    if game_data:isViewOpenByID(101) then
        if user_status.vip > 0 then
            m_vip_node:setVisible(true)
            local m_vip_label = ccbNode:labelTTFForName("m_vip_label")
            m_vip_label:setString("VIP" .. tostring(user_status.vip))
        else
            m_vip_node:setVisible(false)
        end
    else
        m_vip_node:setVisible(false)
    end

    if m_head_icon_node and m_head_icon_node:getChildrenCount() == 0 then
        m_head_icon_node:removeAllChildrenWithCleanup(true);
        local role_detail_cfg = getConfig(game_config_field.role_detail);
        if user_status.role and role_detail_cfg then
            local itemCfg = role_detail_cfg:getNodeWithKey(tostring(user_status.role));
            local tempSpr = game_util:createPlayerIconByCfg(itemCfg)--game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
            if tempSpr then
                tempSpr:setScale(0.75);
                tempSpr:setPosition(ccp(31, 29));
                m_head_icon_node:addChild(tempSpr);
            end
        end
    end
    if m_player_name then
        m_player_name:setString(tostring(user_status.show_name))
        m_player_name:setFontSize(10)
        for i=1,4 do
            sb_list[i] = tolua.cast(ccbNode:objectForName("m_player_name_" .. i), "CCLabelTTF");
            sb_list[i]:setString(tostring(user_status.show_name))
            sb_list[i]:setFontSize(10)
        end
    end
    if m_exp_bar_bg ~= nil then
        local exp_max = user_status.exp_max;
        local exp = user_status.exp;
        m_exp_label:setString(exp .. "/" .. exp_max);
        local bar = m_exp_bar_bg:getChildByTag(10)
        if bar then
            bar = tolua.cast(bar,"CCProgressTimer");
        else
            local bar_bg_size = m_exp_bar_bg:getContentSize();
            bar = game_util:createProgressTimer({fileName = "public_jingyan.png",percentage = 0})
            bar:setPosition(ccp(bar_bg_size.width*0.5,bar_bg_size.height*0.5));
            m_exp_bar_bg:addChild(bar,10,10);
        end
        if exp_max ~= 0 then
            bar:setPercentage(100*exp/exp_max);
        end
        -- bar:setPercentage(100);
    end
    local m_lightning_bar_bg = tolua.cast(ccbNode:objectForName("m_lightning_bar_bg"), "CCSprite");
    if m_lightning_bar_bg then
        local bar = m_lightning_bar_bg:getChildByTag(10)
        if bar then
            bar = tolua.cast(bar,"CCProgressTimer");
        else
            local bar_bg_size = m_lightning_bar_bg:getContentSize();
            bar = game_util:createProgressTimer({fileName = "public_tili.png",percentage = 0})
            bar:setPosition(ccp(bar_bg_size.width*0.5,bar_bg_size.height*0.5));
            m_lightning_bar_bg:addChild(bar,10,10);
        end
        if user_status.action_point_max ~= 0 then
            bar:setPercentage(100*user_status.action_point/user_status.action_point_max);
        end
        -- bar:setPercentage(100);
    end
    local m_lv_label = tolua.cast(ccbNode:objectForName("m_lv_label"), "CCLabelTTF");
    if m_lv_label ~= nil then
        m_lv_label:setString(tostring(user_status.level));
    end
    local count_down_label = ccbNode:nodeForName("count_down_label")
    local timeOverLabel = count_down_label:getChildByTag(10)
    if user_status.action_point < user_status.action_point_max then
        local function timeOverFunc(label,type)
            user_status = game_data:getUserStatusData();
            if user_status.action_point == nil then return end
            -- cclog("userStatusData = " .. json.encode(user_status or {}))
            user_status.action_point = user_status.action_point + 1;
            -- cclog("user_status.action_point============ " .. user_status.action_point)
            m_lightning_label:setString((user_status.action_point) .. "/" .. user_status.action_point_max)
            local bar = m_lightning_bar_bg:getChildByTag(10)
            if bar then
                bar = tolua.cast(bar,"CCProgressTimer");
                if user_status.action_point_max ~= 0 then
                    bar:setPercentage(100*user_status.action_point/user_status.action_point_max);
                end
            end
            if user_status.action_point < user_status.action_point_max then
                label:setTime(user_status.action_point_rate);
            else
                label:setTime(0);
            end
        end
        if timeOverLabel then
            timeOverLabel = tolua.cast(timeOverLabel,"ExtCountdownLabel");
            timeOverLabel:setTime(user_status.action_point_update_left)
        else
            timeOverLabel = self:createCountdownLabel(user_status.action_point_update_left,timeOverFunc,8,2)
            timeOverLabel:setAnchorPoint(ccp(0.5,0.5))
            count_down_label:addChild(timeOverLabel,10,10)
        end
    else
        count_down_label:removeAllChildrenWithCleanup(true)
    end
end


--[[--
    设置玩家属性栏信息
]]
function M.setPlayerPropertyByCCBAndTableData2(self,ccbNode,user_status)

    print(" ------ setPlayerPropertyByCCBAndTableData2 ---- ")

    user_status = user_status or game_data:getUserStatusData();
    if ccbNode == nil or user_status == nil or user_status.uid == nil then
        return;
    end
    local m_lightning_label = ccbNode:labelBMFontForName("m_lightning_label")
    if m_lightning_label ~= nil then
        m_lightning_label:setString(user_status.action_point .. "/" .. user_status.action_point_max);
    end
    local m_exp_bar_bg = tolua.cast(ccbNode:objectForName("m_exp_bar_bg"), "CCSprite");
    local m_exp_label = ccbNode:labelBMFontForName("m_exp_label")
    if m_exp_bar_bg ~= nil then
        local exp_max = user_status.exp_max;
        local exp = user_status.exp;
        m_exp_label:setString(exp .. "/" .. exp_max);
        local bar = m_exp_bar_bg:getChildByTag(10)
        if bar then
            bar = tolua.cast(bar,"CCProgressTimer");
        else
            local bar_bg_size = m_exp_bar_bg:getContentSize();
            bar = game_util:createProgressTimer({fileName = "public_jingyan.png",percentage = 0})
            bar:setPosition(ccp(bar_bg_size.width*0.5,bar_bg_size.height*0.5));
            m_exp_bar_bg:addChild(bar,10,10);
        end
        if exp_max ~= 0 then
            bar:setPercentage(100*exp/exp_max);
        end
        -- bar:setPercentage(100);
    end
    local m_lightning_bar_bg = tolua.cast(ccbNode:objectForName("m_lightning_bar_bg"), "CCSprite");
    if m_lightning_bar_bg then
        local bar = m_lightning_bar_bg:getChildByTag(10)
        if bar then
            bar = tolua.cast(bar,"CCProgressTimer");
        else
            local bar_bg_size = m_lightning_bar_bg:getContentSize();
            bar = game_util:createProgressTimer({fileName = "public_tili.png",percentage = 0})
            bar:setPosition(ccp(bar_bg_size.width*0.5,bar_bg_size.height*0.5));
            m_lightning_bar_bg:addChild(bar,10,10);
        end
        if user_status.action_point_max ~= 0 then
            bar:setPercentage(100*user_status.action_point/user_status.action_point_max);
        end
        -- bar:setPercentage(100);
    end
end

--[[--
    格式化技能描述
]]
function M.formatSkillStory(self,skillCfgItem,skillLevel)
    if skillCfgItem == nil then return string_helper.game_util.none end
    local story = skillCfgItem:getNodeWithKey("story"):toStr();
    print("story ==============================" .. story);
    local base_effect1 = skillCfgItem:getNodeWithKey("base_effect1"):toInt();
    local base_effect2 = skillCfgItem:getNodeWithKey("base_effect2"):toInt();
    local add_effect1 = skillCfgItem:getNodeWithKey("add_effect1"):toInt();
    local add_effect2 = skillCfgItem:getNodeWithKey("add_effect2"):toInt();
    if skillLevel == nil or type(skillLevel) ~= "number" then
        skillLevel = 1;
    end
    local replace1 = ""
    local replace2 = ""
    local value1 = 0;
    local value2 = 0;
    if base_effect1 >= 10000 then--不加％
        value1 = base_effect1 - 10000 + add_effect1*skillLevel;
        replace1 = tostring(value1);
    else
        value1 = base_effect1 + add_effect1*skillLevel;
        if value1 > 0 then
            replace1 = tostring(value1) .. "%";
        end
    end
    if base_effect2 >= 10000 then--不加％
        value2 = base_effect2 - 10000 + add_effect2*skillLevel
        replace2 = tostring(value2);
    else
        value2 = base_effect2 + add_effect2*skillLevel;
        if value2 > 0 then
            replace2 = tostring(value2) .. "%";
        end
    end
    return string.format(story,replace1,replace2);
end
--[[--
    创建英雄技能解锁
]]
function M.heroSkillUnlockCCB(self,skillId)
    if skillId == nil then return nil end
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/anim_hero_skill_unlock.ccbi");
    return ccbNode;
end
--[[--
    玩家升级动画
]]
function M.playerLevelUpCCBAnim(self,backCallFunc)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/anim_player_level_up.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");

    local function playAnimEnd(animName)
        ccbNode:removeFromParentAndCleanup(true);
        if backCallFunc ~= nil then backCallFunc(); end
    end
    ccbNode:registerAnimFunc(playAnimEnd);
    ccbNode:runAnimations("player_level_up");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            ccbNode:removeFromParentAndCleanup(true);
            if backCallFunc ~= nil then backCallFunc(); end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    通用的成功动画
]]
function M.animSuccessCCBAnim(self,backCallFunc,typeName)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_feedback_text_res.plist");
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/anim_word.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_spr = tolua.cast(ccbNode:objectForName("m_spr"), "CCSprite");

    if typeName == "strengthen_success" then
        m_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fkxg_qianghuachenggong.png"));
    elseif typeName == "evolution_success" then
        m_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fkxg_jinhua.png"));
    elseif typeName == "synthesis_success" then
        m_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fkxg_hechengchenggong.png"));
    elseif typeName == "equip_production" then
        m_spr:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fkxg_newEffect.png"));
    end

    local function playAnimEnd(animName)
        ccbNode:removeFromParentAndCleanup(true);
        if backCallFunc ~= nil then backCallFunc(); end
    end
    ccbNode:registerAnimFunc(playAnimEnd);
    ccbNode:runAnimations("play_anim");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            ccbNode:removeFromParentAndCleanup(true);
            if backCallFunc ~= nil then backCallFunc(); end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--

]]
function M.setHeroBgByQuality(self,heroBg,quality)
    -- if heroBg == nil then return end;
    -- if quality < 1 or quality > 7 then
    --     quality = 1;
    -- end
    -- local typeName = tolua.type(heroBg);
    -- if typeName == "CCSprite" then
    --     heroBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_BG_IMG[quality]));
    -- elseif typeName == "CCControlButton" then
    --     heroBg:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrameName(HERO_QUALITY_BG_IMG[quality]),CCControlStateNormal);
    --     heroBg:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrameName(HERO_QUALITY_BG_IMG[quality]),CCControlStateHighlighted);
    -- end
end
--[[--
    设置英雄的颜色
]]
function M.setHeroNameColorByQuality(self,label,heroCfg)
    if label == nil then return end
    local quality = 1;
    if heroCfg then
        quality = heroCfg:getNodeWithKey("quality"):toInt()+1
    end
    self:setLabelColorByQuality(label,quality)
end

function M.setLabelColorByQuality(self,label,quality)
    -- if label == nil then return end
    -- if quality < 1 or quality > 7 then
    --     quality = 1;
    -- end
    -- label:setColor(HERO_QUALITY_COLOR_TABLE[quality].color);
end

function M.createHeroListItemByCCB(self,heroData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_hero_list_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and heroData ~= nil then
        self:setHeroListItemInfoByTable(ccbNode,heroData);
    end
    return ccbNode
end

function M.setHeroListItemInfoByTable(self,ccbNode,heroDataTable)
    local cardId = heroDataTable.c_id;
    -- cclog("cardId ===" .. tostring(cardId))
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    local wake_lv = heroDataTable.bre
    -- tolua.cast(ccbNode:objectForName("m_level_label"),"CCLabelBMFont"):setString("Lv." .. heroDataTable.lv .. "/" .. heroDataTable.level_max);
    tolua.cast(ccbNode:objectForName("m_level_label"),"CCLabelBMFont"):setString("Lv." .. heroDataTable.lv);
    local m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"),"CCNode");
    m_anim_node:removeAllChildrenWithCleanup(true);
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    -- self:setHeroNameColorByQuality(m_name_label,itemConfig);
    local quality = itemConfig:getNodeWithKey("quality"):toInt();
    if quality > -1 and quality < 7 then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality+1].card_img));
    end
    local name_after = self:getCardName(heroDataTable,itemConfig)
    m_name_label:setString(name_after);
    local animation = itemConfig:getNodeWithKey("animation"):toStr();
    local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();

    local animNode = self:createImgByName("image_" .. animation,rgb,nil,nil,wake_lv,itemConfig)
    -- local animNode = game_util:createPauseAnim(animation,0,heroDataTable,itemConfig);
    -- cclog("setHeroListItemInfoByTable animNode == " .. tostring(animNode))
    if animNode then
        local animNodeSize = animNode:getContentSize();
        -- local ccbNodeSize = ccbNode:getContentSize();
        -- local scale = math.min(1,animNodeSize.height~=0 and 70/animNodeSize.height or 1);
        -- animNode:setScale(scale);
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
        -- m_anim_node:getParent():reorderChild(m_anim_node,-1);
    end
    local m_sel_img = ccbNode:spriteForName("m_sel_img")
    m_sel_img:setVisible(false)
    local m_team_img = ccbNode:spriteForName("m_team_img")
    if game_data:heroInTeamById(heroDataTable.id) then
        m_team_img:setVisible(true);
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_played.png"));
    else
        if game_data:heroInAssistantById(heroDataTable.id) then
            m_team_img:setVisible(true);
            m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_zhuzhanzhong.png"));
        else
            m_team_img:setVisible(false);
        end
    end
    local lockFlag = game_util:getCardUserLockFlag(heroDataTable);
    ccbNode:spriteForName("m_lock_img"):setVisible(lockFlag);
    local m_perfect_img = ccbNode:spriteForName("m_perfect_img")
    m_perfect_img:setVisible(false);
    local bre = math.min(heroDataTable.bre or 0,10)
    local tempSpriteFrame = nil;
    if bre > 5 then
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_moon_icon.png")
        bre = bre - 5
    else
        tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_equip_star.png")
    end
    for i=1,5 do
        local m_star_icon = ccbNode:spriteForName("m_star_icon_" .. i)
        if tempSpriteFrame then
            m_star_icon:setDisplayFrame(tempSpriteFrame)
        end
        if i <= bre then
            m_star_icon:setVisible(true);
        else
            m_star_icon:setVisible(false);
        end
    end

    local m_occupation_icon = ccbNode:spriteForName("m_occupation_icon")
    local occupation_cfg = getConfig(game_config_field.occupation);
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(animation)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt();
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
        if spriteFrame then
            m_occupation_icon:setDisplayFrame(spriteFrame);
        else
            m_occupation_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation5.png"));
        end
    else
        m_occupation_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation5.png"));
    end
end

function M.createHeroListItemByCCB2(self,heroData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_card_split_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and heroData ~= nil then
        self:setHeroListItemInfoByTable2(ccbNode,heroData);
    end
    return ccbNode
end

function M.setHeroListItemInfoByTable2(self,ccbNode,heroDataTable)
    local cardId = heroDataTable.c_id;
    -- cclog("cardId ===" .. tostring(cardId))
    local m_level_label = ccbNode:labelBMFontForName("m_level_label");
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    local sprite_chuzhan = ccbNode:spriteForName("sprite_chuzhan");
    local sprite_back_alpha = ccbNode:spriteForName("sprite_back_alpha");
    local sprite_selected = ccbNode:spriteForName("sprite_selected");
    local sprite_perfect = ccbNode:spriteForName("sprite_perfect");
    local sprite_lock = ccbNode:spriteForName("sprite_lock");
    
    sprite_back_alpha:setVisible(false);
    sprite_selected:setVisible(false);

    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    -- m_level_label:setString(heroDataTable.lv .. "/" .. heroDataTable.level_max);
    m_level_label:setString(heroDataTable.lv);
    local head_node = ccbNode:nodeForName("head_node");
    head_node:removeAllChildrenWithCleanup(true);
    local tempIcon = game_util:createCardIconByCfg(itemConfig)
    if tempIcon then
        tempIcon:setScale(0.75);
        head_node:addChild(tempIcon)
    end
    local name_after = self:getCardName(heroDataTable,itemConfig)
    m_name_label:setString(name_after);
    --是否在阵型中
    if game_data:heroInTeamById(heroDataTable.id) then
        sprite_chuzhan:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_chuzhan.png"));
        sprite_chuzhan:setVisible(true);
    else
        if game_data:heroInAssistantById(heroDataTable.id) then--在助阵中
            sprite_chuzhan:setVisible(true);
            sprite_chuzhan:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_zhuzhanzhong.png"));
        else
            --是否在训练中
            local is_in_train = game_util:getCardTrainingFlag(heroDataTable)
            if is_in_train == true then
                sprite_chuzhan:setVisible(true)
                sprite_chuzhan:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_xunlian.png"));
            else
                sprite_chuzhan:setVisible(false);
            end
        end
    end
    --是否枷锁
    local lockFlag = game_util:getCardUserLockFlag(heroDataTable);
    sprite_lock:setVisible(lockFlag);
    sprite_perfect:setVisible(false);
    --判断是否完美
    -- local evolution_flag = heroDataTable.evolution_flag or 0
    -- local is_evolution = heroDataTable.is_evolution or 0;
    -- local quality = itemConfig:getNodeWithKey("quality"):toInt();
    -- if is_evolution == 1 and quality >= 3 and evolution_flag > 0 then--完美
    --     sprite_perfect:setVisible(true);
    -- end
end


--[[--
    获得卡牌的是否完美
]]
function M.getCardPerfectValue(self,heroDataTable)
    local perfectValue = 0;
    if heroDataTable == nil then return perfectValue end
    local cardId = heroDataTable.c_id;
    local itemConfig = getConfig(game_config_field.character_detail):getNodeWithKey(cardId);
    local quality = itemConfig:getNodeWithKey("quality"):toInt();
    local evolution_flag = heroDataTable.evolution_flag or 0
    local is_evolution = heroDataTable.is_evolution or 0;
    if is_evolution == 1 and quality >= 3 then
        perfectValue = evolution_flag;
    end
    return perfectValue;
end

--[[--
    
]]
function M.createListCardIconByData(self,heroDataTable)
    local cid = heroDataTable.c_id;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cid));
    local tempIcon = self:createCardIconByCfg(heroCfg)
    if tempIcon then
        local m_team_img = CCSprite:createWithSpriteFrameName("public_chuzhan.png")
        m_team_img:setAnchorPoint(ccp(0.5, 0));
        m_team_img:setPositionX(tempIcon:getContentSize().width*0.5);
        tempIcon:addChild(m_team_img);
        local evolution_flag = heroDataTable.evolution_flag or 0
        local is_evolution = heroDataTable.is_evolution or 0;
        local quality = heroCfg:getNodeWithKey("quality"):toInt();
        if is_evolution == 1 and quality >= 3 and evolution_flag > 0 then
            local public_perfect = CCSprite:createWithSpriteFrameName("public_perfect.png")
            public_perfect:setAnchorPoint(ccp(1, 0));
            public_perfect:setPositionX(tempIcon:getContentSize().height);
            tempIcon:addChild(public_perfect);
        end
    end
    return tempIcon;
end

function M.createEquipItemByCCB(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_equip_list_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setEquipItemInfoByTable(ccbNode,itemData);
    end
    return ccbNode
end

function M.setEquipItemInfoByTable(self,ccbNode,itemData)
    if ccbNode == nil or itemData == nil then return end
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(itemData.c_id);
    local level = itemData.lv;
    local attrName1,value1,attrName2,value2,icon1,icon2 = self:getEquipAttributeValue(itemCfg,level);

    local m_ability1_label = ccbNode:labelBMFontForName("m_ability1_label")
    local parentNode = m_ability1_label:getParent()
    local value1,unit1 = self:formatValueToString2(value1)
    local value2,unit2 = self:formatValueToString2(value2)
    ccbNode:labelBMFontForName("m_ability1_label"):setString(value1..unit1);
    ccbNode:labelBMFontForName("m_ability2_label"):setString(value2..unit2);
    ccbNode:spriteForName("m_ability1_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1));
    ccbNode:spriteForName("m_ability2_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2));
    local sort = itemCfg:getNodeWithKey("sort"):toInt();
    -- ccbNode:labelBMFontForName("m_type_label"):setString(tostring(EQUIP_TYPE_NAME_TABLE["type_" ..tostring(sort)]));
    ccbNode:spriteForName("m_type_icon"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. sort].icon))
    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
    if quality > 0 and quality < 8 then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality].card_img));
    end
    -- local equip_strongthen = getConfig(game_config_field.equip_strongthen);
    -- local userLevel = game_data:getUserStatusDataByKey("level") or 1;
    -- ccbNode:labelTTFForName("m_level_label"):setString("Lv." .. level .. "/" .. math.min(equip_strongthen:getNodeCount(),userLevel));
    --装备名称加等级
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "+" .. level);
    -- game_util:setEquipNameColorByQuality(m_name_label,itemCfg);

    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    -- local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    local m_team_name = ccbNode:labelTTFForName("m_team_name")
    --所属英雄
    local existFlag,cardName = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
    if existFlag then
        m_team_img:setVisible(true);
        m_team_name:setString(cardName);
    else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = self:createIconByName(itemCfg:getNodeWithKey("image"):toStr()) --self:createEquipIcon(itemCfg)
    if icon then
        m_anim_node:addChild(icon)
    end
    --英雄星级
    local refining_node = ccbNode:nodeForName("refining_node")
    local refining_level = ccbNode:labelBMFontForName("refining_level")
    local st_lv = itemData.st_lv
    if st_lv > 0 then
        refining_node:setVisible(true)
        refining_level:setString(tostring(st_lv))
    else
        refining_node:setVisible(false)
    end

    -- 英雄附魔信息
    ccbNode:spriteForName("m_icon_ability_1"):setVisible(false)
    ccbNode:spriteForName("m_icon_ability_2"):setVisible(false)
    ccbNode:labelBMFontForName("m_label_ability_1"):setVisible(false)
    ccbNode:labelBMFontForName("m_label_ability_2"):setVisible(false)
    local atts = itemData.atts
    local is_enchant = itemData.is_enchant
    if is_enchant then -- 已附魔
        ccbNode:spriteForName("m_ability2_icon"):getParent():setPosition(ccp(45,30))
        local tempSpr ={}
        -- local spriteTable = {self.m_property_sprite_add_1,self.m_property_sprite_add_2}
        local i = 0 -- 计数 表示sprite的编号 1 2 
        for k,v in pairs(atts) do
            tempSpr = PUBLIC_ABILITY_NAME_TABLE[k] or {}
            -- cclog2(tempSpr,"tempSpr")
            i = i + 1
            local m_icon_ability = ccbNode:spriteForName("m_icon_ability_"..i)
            local m_label_ability = ccbNode:labelBMFontForName("m_label_ability_"..i)
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tempSpr.icon))
            
            -- cclog2(tempSpriteFrame,"tempSpriteFrame")
            if tempSpriteFrame then
                m_icon_ability:setDisplayFrame(tempSpriteFrame)
                m_icon_ability:setVisible(true)
                local value,unit = self:formatValueToString2(v)
                m_label_ability:setString(value..unit)
                m_label_ability:setVisible(true)
            else

                m_icon_ability:setVisible(false)
                m_label_ability:setVisible(false)
            end
        end
    else
        -- 未附魔

        ccbNode:spriteForName("m_ability2_icon"):getParent():setPosition(ccp(45,23))
        ccbNode:spriteForName("m_icon_ability_1"):setVisible(false)
        ccbNode:spriteForName("m_icon_ability_2"):setVisible(false)
        ccbNode:labelBMFontForName("m_label_ability_1"):setVisible(false)
        ccbNode:labelBMFontForName("m_label_ability_2"):setVisible(false)
    end
end

function M.createEquipItemByCCB2(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_equip_list_item2.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setEquipItemInfoByTable2(ccbNode,itemData);
    end
    return ccbNode
end

function M.setEquipItemInfoByTable2(self,ccbNode,itemData)
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(itemData.c_id));
    if itemCfg == nil then return end
    local level = itemData.lv;
    local attrName1,value1,attrName2,value2,icon1,icon2 = self:getEquipAttributeValue(itemCfg,level);
    -- ccbNode:labelTTFForName("m_ability1_name_label"):setString(attrName1);
    -- ccbNode:labelTTFForName("m_ability2_name_label"):setString(attrName2);
    ccbNode:spriteForName("m_icon_ability_2"):setVisible(true)
    ccbNode:spriteForName("m_label_ability_2"):setVisible(true)
    local value1,unit1 = self:formatValueToString2(value1)
    local value2,unit2 = self:formatValueToString2(value2)
    ccbNode:labelBMFontForName("m_label_ability_2"):setString(value1..unit1);
    ccbNode:labelBMFontForName("m_label_ability_1"):setString(value2..unit2);
    ccbNode:spriteForName("m_icon_ability_2"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1));
    ccbNode:spriteForName("m_icon_ability_1"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2));
    -- local equip_strongthen = getConfig(game_config_field.equip_strongthen);
    -- local userLevel = game_data:getUserStatusDataByKey("level") or 1;
    -- ccbNode:labelTTFForName("m_level_label"):setString(level .. "/" .. math.min(equip_strongthen:getNodeCount(),userLevel));
    -- local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");
    m_name_label:setString(itemCfg:getNodeWithKey("name"):toStr() .. "+" .. level);
    
    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    -- local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    local m_team_name = ccbNode:labelTTFForName("m_team_name")
    local existFlag,cardName = game_data:equipInEquipPos(itemCfg:getNodeWithKey("sort"):toInt(),itemData.id)
    if existFlag then
        m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_yizhuangbei.png"));
        m_team_img:setVisible(true);
        -- m_team_name:setString(cardName);
        m_team_name:setString("");
    else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = self:createEquipIcon(itemCfg)
    if icon then
        icon:setScale(0.75);
        m_anim_node:addChild(icon)
    end

    local refining_node = ccbNode:nodeForName("refining_node")
    local refining_level = ccbNode:labelBMFontForName("refining_level")
    local st_lv = itemData.st_lv
    if st_lv > 0 then
        refining_node:setVisible(true)
        refining_level:setString(tostring(st_lv))
    else
        refining_node:setVisible(false)
    end
    local m_max_evo_img = ccbNode:spriteForName("m_max_evo_img")
    local evolution = itemCfg:getNodeWithKey("evolution"):toInt();
    if evolution == 0 then
        m_max_evo_img:setVisible(true);
    else
        m_max_evo_img:setVisible(false);
    end

    local m_node_old = ccbNode:nodeForName("m_node_old")
    -- 英雄附魔信息
    local atts = itemData.atts
    local is_enchant = itemData.is_enchant
    if is_enchant then -- 已附魔
        m_node_old:stopAllActions();
        local function newFunc(node)

            ccbNode:spriteForName("m_icon_ability_1"):setVisible(true)
            ccbNode:spriteForName("m_label_ability_1"):setVisible(true)
            ccbNode:spriteForName("m_icon_ability_2"):setVisible(true)
            ccbNode:spriteForName("m_label_ability_2"):setVisible(true)
            ccbNode:labelBMFontForName("m_label_ability_2"):setString(value1..unit1);
            ccbNode:labelBMFontForName("m_label_ability_1"):setString(value2..unit2);
            ccbNode:spriteForName("m_icon_ability_2"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1));
            ccbNode:spriteForName("m_icon_ability_1"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon2));
        end
        local function oldFunc(node)
            ccbNode:spriteForName("m_icon_ability_1"):setVisible(false)
            ccbNode:spriteForName("m_label_ability_1"):setVisible(false)
            ccbNode:spriteForName("m_icon_ability_2"):setVisible(false)
            ccbNode:spriteForName("m_label_ability_2"):setVisible(false)
            -- ccbNode:spriteForName("m_label_ability_2"):removeAllChildrenWithCleanup(true)
            local tempSpr ={}
            -- local spriteTable = {self.m_property_sprite_add_1,self.m_property_sprite_add_2}
            local i = 0 -- 计数 表示sprite的编号 1 2 
            for k,v in pairs(atts) do
                tempSpr = PUBLIC_ABILITY_NAME_TABLE[k] or {}
                i = i + 1
                local m_icon_ability = ccbNode:spriteForName("m_icon_ability_"..i)
                local m_label_ability = ccbNode:labelBMFontForName("m_label_ability_"..i)
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(tempSpr.icon))
                if tempSpriteFrame then
                    m_icon_ability:setDisplayFrame(tempSpriteFrame)
                    m_icon_ability:setVisible(true)
                    local value,unit = self:formatValueToString2(v)
                    m_label_ability:setString(value..unit)
                    m_label_ability:setVisible(true)
                else
                    m_icon_ability:setVisible(false)
                    m_label_ability:setVisible(false)
                end
            end
        end
        local animArr = CCArray:create();
        animArr:addObject(CCFadeIn:create(1));
        animArr:addObject(CCDelayTime:create(1));
        animArr:addObject(CCFadeOut:create(1));
        animArr:addObject(CCCallFuncN:create(oldFunc));
        animArr:addObject(CCFadeIn:create(1));
        animArr:addObject(CCDelayTime:create(1));
        animArr:addObject(CCFadeOut:create(1));
        animArr:addObject(CCCallFuncN:create(newFunc));
        m_node_old:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    else
        m_node_old:stopAllActions();
        ccbNode:spriteForName("m_icon_ability_1"):setOpacity(255)
        ccbNode:spriteForName("m_label_ability_1"):setOpacity(255)
        ccbNode:spriteForName("m_icon_ability_2"):setOpacity(255)
        ccbNode:spriteForName("m_label_ability_2"):setOpacity(255)
        ccbNode:spriteForName("m_icon_ability_2"):setVisible(true)
        ccbNode:spriteForName("m_label_ability_2"):setVisible(true)
    end


end

function M.setEquipNameColorByQuality(self,label,equipCfg)
    local quality = 1;
    if equipCfg then
        quality = equipCfg:getNodeWithKey("quality"):toInt()+1
    end
    self:setLabelColorByQuality(label,quality)
end

function M.createCCControlButton(self,btnImgName,text,callFunc)
    local btnImg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(btnImgName);
    local btn = CCControlButton:create(CCLabelTTF:create(text,TYPE_FACE_TABLE.Arial_BoldMT,16),CCScale9Sprite:createWithSpriteFrame(btnImg));
    btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-2);
    btn:setPreferredSize(btnImg:getRect().size);
    btn:addHandleOfControlEvent(callFunc,CCControlEventTouchUpInside);
    return btn;
end

function M.createCCControlButtonByTable(self,params)
    local btn = CCControlButton:create(params.text,TYPE_FACE_TABLE.Arial_BoldMT,16);
    local btnImg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(params.btnImgName);
    btn:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrame(btnImg),CCControlStateNormal);
    btn:setTitleColorForState(ccc3(255,255,255),CCControlStateNormal)
    if params.btnImgNameSel ~= nil and params.btnImgNameSel ~= "" then
        local btnImgSel = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(params.btnImgNameSel);
        btn:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrame(btnImgSel),CCControlStateHighlighted);
        btn:setTitleColorForState(ccc3(255,255,255),CCControlStateHighlighted)
        btn:setZoomOnTouchDown(false);
    end
    if params.btnImgNameDis ~= nil and params.btnImgNameDis ~= "" then
        local btnImgDis = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(params.btnImgNameDis);
        btn:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrame(btnImgDis),CCControlStateDisabled);
        btn:setTitleColorForState(ccc3(255,255,255),CCControlStateDisabled)
        btn:setZoomOnTouchDown(false);
    end
    
    if params.touchPriority == nil then params.touchPriority = GLOBAL_TOUCH_PRIORITY-2 end
    btn:setTouchPriority(params.touchPriority);
    btn:setPreferredSize(btnImg:getRect().size);
    btn:addHandleOfControlEvent(params.callFunc,CCControlEventTouchUpInside);
    self:setControlButtonTitleBMFont(btn);
    return btn;
end
--[[
    设置按钮的可点击状态
]]
function M.setCCControlButtonEnabled(self,btn,enabled)
    if btn == nil then return end
    if enabled == true then
        btn:setColor(ccc3(255, 255, 255));
        btn:setEnabled(true);
    else
        btn:setColor(ccc3(155, 155, 155));
        btn:setEnabled(false);
    end
end

function M.createSkillNameTips(self,parentNode,skillId,callback,mtype)
    -- cclog("createSkillNameTips ===================================skillId==" .. tostring(skillId));
    local skill_detail_cfg = getConfig("skill_detail");
    local skill_name = string_helper.game_util.attack;
    local quality = 0;
    if(skillId) then
       local skill_detail_cfg_item = skill_detail_cfg:getNodeWithKey(tostring(skillId));
       if skill_detail_cfg_item then
          skill_name = skill_detail_cfg_item:getNodeWithKey("skill_name"):toStr();
          quality = skill_detail_cfg_item:getNodeWithKey("skill_quality"):toInt();
       end
    else
       if(mtype == 0) then
          skill_name = string_helper.game_util.pattack
       else
          skill_name = string_helper.game_util.mattack
       end
    end
    -- local bgW,bgH = 80,40;
    -- local bgNode = CCLayerColor:create(ccc4(155,155,155,255),bgW,bgH);
    local bgNode = CCSprite:createWithSpriteFrameName("zd_skill.png")
    local bgNodeSize = bgNode:getContentSize();
    local msgLabel = CCLabelTTF:create(skill_name,TYPE_FACE_TABLE.Arial_BoldMT,12);
    msgLabel:setPosition(bgNodeSize.width * 0.5,bgNodeSize.height * 0.5);
    bgNode:addChild(msgLabel);
    game_util:setLabelColorByQuality(msgLabel,quality)
    local parentNodeSize = parentNode:getContentSize();
    bgNode:setPosition(ccp(parentNodeSize.width * 0.5,parentNodeSize.height * 1.2));
    bgNode:setScale(1.5)
    parentNode:addChild(bgNode);
    local function show_end( node )
        -- body
        local remove_node = function()
           node:removeFromParentAndCleanup(true);
        end
        local arr = CCArray:create();
        arr:addObject(CCMoveBy:create(0.2,ccp(0,100)));
        arr:addObject(CCCallFuncN:create(remove_node));
        bgNode:runAction(CCSequence:create(arr));
        bgNode:runAction(CCFadeOut:create(0.2));
        callback();
    end
    local arr = CCArray:create();
    arr:addObject(CCDelayTime:create(0.3));
    arr:addObject(CCCallFuncN:create(show_end));
    bgNode:runAction(CCSequence:create(arr));
end
--[[
    创建静态倒计时
    依次显示剩余**天，剩余**小时，剩余**分，小于一分钟
]]
function M.createStaticCountDownLabel(self,needTime)
    local days = math.floor(needTime / 86400)
    local hours = math.floor((needTime - 86400 * days) / 3600)
    local minutes = math.floor((needTime - 86400 * days - 3600 * hours) / 60)
    local timeStr = ""
    if days > 0 then
        timeStr = string_helper.game_util.left .. days .. string_helper.game_util.day
    elseif hours > 0 then
        timeStr = string_helper.game_util.left .. hours .. string_helper.game_util.hour
    elseif minutes > 0 then
        timeStr = string_helper.game_util.left .. minutes .. string_helper.game_util.min
    else
        timeStr = string_helper.game_util.lessOneMinute
    end
    return self:createLabelTTF({text = timeStr,fontSize = 10}),timeStr
end
--[[
    创建倒计时label 
    #params 倒计时时间，回调，字体（未实现），是否需要显示小时（1是显示）
]]
function M.createCountdownLabel(self,needTime,timeLabelEndFunc,fontSize,shwoType,stroke)
    fontSize = fontSize or 12;
    shwoType = shwoType or 1;
    local countdownLabel = ExtCountdownLabel:create(needTime,1.0,shwoType);
    countdownLabel:ignoreAnchorPointForPosition(false);
    countdownLabel:setAnchorPoint(ccp(0.5,0.5));
    countdownLabel:registerScriptTapHandler(timeLabelEndFunc);
    return countdownLabel;
end

function M.getCurrentTime(self)
    return os.time();
end

function M.getTableLen(self,tableData)
    local tempLen = 0;
    if type(tableData) == "table" then
        table.foreach(tableData,function() tempLen = tempLen+1; end);
    end
    return tempLen;
end

function M.createEditBox(self,t_params)
    -- lua sample 输入框
    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "began" then
            -- strFmt = string.format("editBox %p DidBegin !", edit)
            -- print(strFmt)
        elseif strEventName == "ended" then
            -- strFmt = string.format("editBox %p DidEnd !", edit)
            -- print(strFmt)
        elseif strEventName == "return" then
            -- strFmt = string.format("editBox %p was returned !",edit)
            -- print(strFmt)
        elseif strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_palyer_name = edit:getText();
        end
    end
    if t_params.bgFileName == nil then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
        t_params.bgFileName = "public_talkBar.png";
    end
    if t_params.fontSize == nil then
        t_params.fontSize = 25;
    end
    if t_params.fontColor == nil then
        t_params.fontColor = ccc3(0,0,0);
    end
    if t_params.placeHolder == nil then
        t_params.placeHolder = string_helper.game_util.inputWord
    end
    if t_params.placeholderFontColor == nil then
        t_params.placeholderFontColor = ccc3(188,188,188)
    end
    if t_params.maxLength == nil then
        t_params.maxLength = 12;
    end
    if t_params.returnType == nil then
        t_params.returnType = kKeyboardReturnTypeDone;
    end
    if t_params.inputMode == nil then
        t_params.inputMode = kEditBoxInputModeSingleLine;
    end
    if t_params.scriptEditBoxHandler == nil then
        t_params.scriptEditBoxHandler = editBoxTextEventHandle;
    end

    local input_bg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(t_params.bgFileName);
    local editBoxSize = input_bg:getRect().size;
    if t_params.size then
        editBoxSize = t_params.size
    end
    local editBoxTemp = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrame(input_bg));
    editBoxTemp:setPreferredSize(editBoxSize);
    editBoxTemp:setPosition(ccp(editBoxSize.width*0.5, editBoxSize.height*0.5))
    editBoxTemp:setFontSize(t_params.fontSize)
    editBoxTemp:setFontColor(t_params.fontColor)
    editBoxTemp:setPlaceHolder(t_params.placeHolder)
    editBoxTemp:setPlaceholderFontColor(t_params.placeholderFontColor)
    editBoxTemp:setMaxLength(t_params.maxLength)
    editBoxTemp:setReturnType(t_params.returnType)
    editBoxTemp:setInputMode(t_params.inputMode);
    --Handler
    editBoxTemp:registerScriptEditBoxHandler(t_params.scriptEditBoxHandler)
    if t_params.text ~= nil then
        editBoxTemp:setText(t_params.text);
    end
    return editBoxTemp;
end
--[[--
    
]]
function M.spriteOnClickAnim(self,params)
    local listener = params.listener
    local tempSpr = params.tempSpr

    params.listener = function(tag)
        if params.prepare then
            params.prepare()
        end

        local function zoom1(offset, time, onComplete)
            local x, y = tempSpr:getPosition()
            local size = tempSpr:getContentSize()

            local scaleX = tempSpr:getScaleX() * (size.width + offset) / size.width
            local scaleY = tempSpr:getScaleY() * (size.height - offset) / size.height
            transition.moveTo(tempSpr, {x = x  , y = y - offset, time = time})
            transition.scaleTo(tempSpr, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                scale      = 0.9,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(offset, time, onComplete)
            local x, y = tempSpr:getPosition()
            local size = tempSpr:getContentSize()

            transition.moveTo(tempSpr, {x = x , y = y + offset, time = time / 2})
            transition.scaleTo(tempSpr, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end
        zoom1(10, 0.08, function()
            zoom2(10, 0.09, function()
                zoom1(5, 0.10, function()
                    zoom2(5, 0.11, function()
                        listener(tag)
                    end)
                end)
            end)
        end)
    end
    params.listener(params.tag);
end

function M.setAttributeLable(self,oldLable,arrowLabel,newLabel,oldValue,newValue)
    if oldLable and arrowLabel and newLabel then
        oldLable:setString(oldValue);
        newLabel:setString(newValue);
        if oldValue == newValue then
            arrowLabel:setRotation(0);
            arrowLabel:setColor(ccc3(222,152,40));
            newLabel:setColor(ccc3(222,152,40));
        elseif oldValue > newValue then
            arrowLabel:setRotation(45);
            arrowLabel:setColor(ccc3(16,255,0));
            newLabel:setColor(ccc3(16,255,0));
        else
            arrowLabel:setRotation(-45);
            arrowLabel:setColor(ccc3(16,255,0));
            newLabel:setColor(ccc3(16,255,0));
        end
    end
end

function M.resetAttributeLable(self,oldLable,arrowLabel,newLabel)
    if oldLable and arrowLabel and newLabel then
        oldLable:setString("---");
        newLabel:setString("---");
        arrowLabel:setRotation(0);
        arrowLabel:setColor(ccc3(222,152,40));
        newLabel:setColor(ccc3(222,152,40));
    end
end

function M.setAttributeLable2(self,lable,oldValue,newValue,str)
    if lable then
        if oldValue == newValue or newValue == 0 then
            lable:setColor(ccc3(255,255,255));
            if str then
                lable:setString(str .. newValue);
            else
                lable:setString(newValue);
            end
        elseif oldValue > newValue then
            lable:setColor(ccc3(255,0,0));
            if str then
                lable:setString(str .. newValue);
            else
                lable:setString("-" .. newValue);
            end
        else
            lable:setColor(ccc3(0,255,0));
            if str then
                lable:setString(str .. newValue);
            else
                lable:setString("+" .. newValue);
            end
        end
    end
end

function M.resetAttributeLable2(self,lable)
    if lable then
        lable:stopAllActions();
        lable:setString("---");
        lable:setColor(ccc3(255,255,255));
        lable:setOpacity(255);
    end
end

function M.setCostLable(self,lable,costValue,currentValue)
    costValue = tonumber(costValue)
    currentValue = tonumber(currentValue);
    lable:setString(tostring(costValue))
    if costValue == 0 then
        lable:setColor(ccc3(0,255,0))
    elseif costValue > currentValue then
        lable:setColor(ccc3(255,0,0))
    else
        lable:setColor(ccc3(0,255,0))
    end
end

function M.createItemsItem( self,itemData )
    -- body
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_items_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if(ccbNode~=nil and itemData~=itemData)then
    end
    return ccbNode;
end


function M.formatTime(self,timeValue)
    return string.format("%02d:%02d:%02d", math.floor(timeValue/3600), math.floor((timeValue%3600)/60), math.floor(timeValue%60))
end

function M.formatTime2(self,timeValue)
    local timeValue = timeValue or 0
    if timeValue <= 60 then
        timeValue = string.format("%02d秒", timeValue)
    elseif timeValue > 60 and timeValue <= 3600 then
        timeValue = string.format("%02d分%02d秒", math.floor(timeValue/60), math.floor(timeValue%60))
    else
        timeValue = string.format("%02d时%02d分%02d秒", math.floor(timeValue/3600), math.floor((timeValue%3600)/60), math.floor(timeValue%60))
    end
    return timeValue;
end

function M.setCCControlButtonTitle(self,btn,title)
    if btn == nil then return end
    local title = CCString:create(tostring(title));
    btn:setTitleForState(title,CCControlStateNormal);
    btn:setTitleForState(title,CCControlStateHighlighted);
    btn:setTitleForState(title,CCControlStateDisabled);
end

function M.setControlButtonTitleBMFont(self,btn)
    if btn == nil then return end
    btn:setTitleBMFontForState("btn_text_character.fnt",CCControlStateNormal)
    btn:setTitleBMFontForState("btn_text_character.fnt",CCControlStateHighlighted)
    btn:setTitleBMFontForState("btn_text_character.fnt",CCControlStateDisabled)
end

function M.setCCControlButtonBackground(self,btn,normalImgName,highlightedImgName,disabledImgName)
    if btn == nil or normalImgName == nil then return end
    local tempFrame = CCScale9Sprite:createWithSpriteFrameName(normalImgName)
    if tempFrame then btn:setBackgroundSpriteForState( tempFrame ,CCControlStateNormal); end
    highlightedImgName = highlightedImgName or normalImgName
    local tempFrame = CCScale9Sprite:createWithSpriteFrameName(highlightedImgName)
    if tempFrame then  btn:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrameName(highlightedImgName),CCControlStateHighlighted); end
    disabledImgName = disabledImgName or normalImgName
    local tempFrame = CCScale9Sprite:createWithSpriteFrameName(disabledImgName)
    if tempFrame then  btn:setBackgroundSpriteForState(CCScale9Sprite:createWithSpriteFrameName(disabledImgName),CCControlStateDisabled); end
end
--[[
    通过cid创建卡牌头像  小头像
]]
function M.createCardIconByCid(self,cid)
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local heroCfg = character_detail_cfg:getNodeWithKey(tostring(cid));
    if heroCfg == nil then return nil,nil end
    return self:createCardIconByCfg(heroCfg),heroCfg:getNodeWithKey("name"):toStr();
end

function M.createCardIconByCfg(self,itemCfg)--小头像
    if itemCfg == nil then
        return nil;
    end
    local rgb = itemCfg:getNodeWithKey("rgb_sort");
    if rgb then
        rgb = rgb:toInt();
    else
        rgb = 0;
    end
    local fileName = itemCfg:getNodeWithKey("img"):toStr();
    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;

    if quality < 1 or quality > 7 then
        quality = 1;
    end
    local tempIcon = self:createIconByName(fileName)
    if tempIcon then
        -- cclog("quality ==" .. quality)
        if rgb == 1 then
            tempIcon:setColor(ccc3(47,255,118));
        elseif rgb == 2 then
            tempIcon:setColor(ccc3(67,117,253));
        elseif rgb == 3 then
            tempIcon:setColor(ccc3(171,65,255));
        end
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality];
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,-1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,1)
        end
    end
    return tempIcon;
end
--[[
    通过CID创建装备图标
]]
function M.createEquipIconByCid(self,cid)
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(cid));
    if itemCfg == nil then return nil,nil end
    return self:createEquipIcon(itemCfg),itemCfg:getNodeWithKey("name"):toStr();
end
--[[
    通过Cfg创建装备图标
]]
function M.createEquipIcon(self,itemCfg)
    local tempIcon = nil;
    if itemCfg then
        local image = itemCfg:getNodeWithKey("image"):toStr();
        tempIcon = self:createIconByName(image)
        if tempIcon == nil then
            cclog(image .. " image is not found");
        end
    else
        cclog("equip config is not found");
    end
    if tempIcon then
        local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
        -- cclog("quality ==" .. quality)
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality];
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,2)
        end
    end
    return tempIcon;
end

function M.getEquipAttributeValue(self,itemCfg,level)
    local attrName1,value1,attrName2,value2,icon1,icon2 = string_helper.game_util.none,string_helper.game_util.none,string_helper.game_util.none,string_helper.game_util.none,"public_icon_phsc.png","public_icon_hp.png";
    if itemCfg:getNodeWithKey("sort"):toInt() ~= 0 then
        value1 = itemCfg:getNodeWithKey("value1"):toInt();
        value2 = itemCfg:getNodeWithKey("value2"):toInt();
        value1 = value1 + itemCfg:getNodeWithKey("level_add1"):toInt() * math.max(0,level-1)
        value2 = value2 + itemCfg:getNodeWithKey("level_add2"):toInt() * math.max(0,level-1)
        local ability1 = itemCfg:getNodeWithKey("ability1"):toInt();
        -- cclog("ability1 ====================" .. ability1)
        local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability1]
        attrName1 = attrTab.name;
        icon1 = attrTab.icon;
        local ability2 = itemCfg:getNodeWithKey("ability2"):toInt();
        -- cclog("ability2 ====================" .. ability2)
        local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability2]
        attrName2 = attrTab.name;
        icon2 = attrTab.icon;
    end
    return attrName1,value1,attrName2,value2,icon1,icon2;
end

--[[
    获取装备增加的血量
]]
function M.getEquipHPAttributeValue(self,itemCfg,level)
    local hp = 0
    if itemCfg:getNodeWithKey("sort"):toInt() ~= 0 then
        for i=1,2 do
            local ability = itemCfg:getNodeWithKey("ability" .. i)
            ability = ability and ability:toInt() or 1
            local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability] or {}
            if attrTab.typeValue == 5 then  -- hp
                local value = itemCfg:getNodeWithKey("value" .. i) 
                value = value and value:toInt() or 0
                local addVal = itemCfg:getNodeWithKey("level_add" .. i)
                addVal = addVal and addVal:toInt() or 0
                hp = value + addVal * math.max(0,level-1)
            end
        end
    end
    return hp
end

function M.createRepeatForeverFade(self,outValue,inValue)
    outValue = outValue or 1
    inValue = inValue or 1
    local animArr = CCArray:create();
    animArr:addObject(CCFadeTo:create(outValue,100));
    animArr:addObject(CCFadeTo:create(inValue,255));
    return CCRepeatForever:create(CCSequence:create(animArr));
end

function M.createRepeatForeverMove(self,startPos,endPos)
    startPos = startPos or ccp(0,0);
    endPos = endPos or ccp(0,0);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.5,startPos));
    animArr:addObject(CCMoveTo:create(0.5,endPos));
    return CCRepeatForever:create(CCSequence:create(animArr));
end

function M.createRepeatForeverMoveWithTime(self,startPos,endPos,startTime,endTime)
    startPos = startPos or ccp(0,0);
    endPos = endPos or ccp(0,0);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(startTime,startPos));
    animArr:addObject(CCMoveTo:create(endTime,endPos));
    return CCRepeatForever:create(CCSequence:create(animArr));
end
--[[
    创建文字变化
]]
function M.labelChangedRepeatForeverFade(self,label,valueOld,valueNew,outValue,inValue)
    if label == nil then return end
    label:stopAllActions();
    label:setString(tostring(valueOld));
    label:setColor(ccc3(255,255,255))
    if valueOld == valueNew then
        label:setOpacity(255);
        return 
    end
    outValue = outValue or 1
    inValue = inValue or 1
    local function newFunc(node)
        label:setString(tostring(valueNew))
        label:setColor(ccc3(0,255,0))
    end
    local function oldFunc(node)
        label:setString(tostring(valueOld))
        label:setColor(ccc3(255,255,255))
    end
    local animArr = CCArray:create();
    animArr:addObject(CCFadeIn:create(inValue));
    animArr:addObject(CCFadeOut:create(outValue));
    animArr:addObject(CCCallFuncN:create(oldFunc));
    animArr:addObject(CCFadeIn:create(inValue));
    animArr:addObject(CCFadeOut:create(outValue));
    animArr:addObject(CCCallFuncN:create(newFunc));
    label:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
end

--[[--
    滚动提示
]]
function M.createScrollViewTips(self,scroll_view_tips,tipsStrTab,loopFlag,openType, fontColor, fontSize)
    openType = openType or 1;
    fontSize = fontSize or 10
    if scroll_view_tips == nil or scroll_view_tips:getParent() == nil then
        return;
    end
    tipsStrTab = tipsStrTab or {};
    if #tipsStrTab == 0 then
        scroll_view_tips:getParent():setVisible(false);
        return;
    else
        scroll_view_tips:getParent():setVisible(true);
    end
    loopFlag = loopFlag == nil and true or loopFlag
    scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true);
    local showIndex = 1;
    local scroll_view_size = scroll_view_tips:getViewSize();
    local containerNode = CCNode:create();
    scroll_view_tips:addChild(containerNode)
    scroll_view_tips:setTouchEnabled(false);
    local function getMsg(showIndex)
        local msg = "";
        if type(tipsStrTab[showIndex]) == "string" then
            msg = tipsStrTab[showIndex];
        elseif type(tipsStrTab[showIndex]) == "table" then
            msg = tipsStrTab[showIndex].msg or "";
        end
        return msg;
    end
    local tempTipsLabel = CCLabelTTF:create(getMsg(showIndex),TYPE_FACE_TABLE.Arial_BoldMT, fontSize)
    if tempTipsLabel and fontColor then
        tempTipsLabel:setColor(fontColor)
    end
    tempTipsLabel:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
    containerNode:addChild(tempTipsLabel)
    local function backCallFunc( node )
        showIndex = showIndex + 1
        scroll_view_tips:getParent():setVisible(true);
        if showIndex > #tipsStrTab then
            if loopFlag == true then
                showIndex = 1;
            else
                tempTipsLabel:removeFromParentAndCleanup(true);
                scroll_view_tips:getParent():setVisible(false);
            end
        end
        tempTipsLabel:setString(getMsg(showIndex))
        tempTipsLabel:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
    end
    local function visibleCallFunc( node )
        scroll_view_tips:getParent():setVisible(false);
    end
    local animArr = CCArray:create();
    animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*0.5)),5));
    -- animArr:addObject(CCFadeOut:create(0.5));
    -- animArr:addObject(CCFadeIn:create(0.5));
    animArr:addObject(CCDelayTime:create(5));
    animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*2)),5));
    if openType == 2 then
        animArr:addObject(CCCallFuncN:create(visibleCallFunc));
        animArr:addObject(CCDelayTime:create(5));
    end
    animArr:addObject(CCCallFuncN:create(backCallFunc));
    tempTipsLabel:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
end

--[[--
    滚动提示
]]
function M.createScrollViewTips2(self,scroll_view_tips,nameTab)
    if nameTab == nil or #nameTab == 0 then return end
    scroll_view_tips:getContainer():removeAllChildrenWithCleanup(true);
    local showIndex = 1;
    local scroll_view_size = scroll_view_tips:getViewSize();
    local containerNode = CCNode:create();
    scroll_view_tips:addChild(containerNode)
    scroll_view_tips:setTouchEnabled(false);
    local function getSpriteFrameByIndex(showIndex)
        local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(nameTab[showIndex]));
        return tempSpriteFrame;
    end
    local function showTips()
        local tempDisplayFrame = getSpriteFrameByIndex(showIndex);
        if tempDisplayFrame == nil then return end
        local tempSprite = CCSprite:createWithSpriteFrame(tempDisplayFrame);
        if tempSprite == nil then return end
        tempSprite:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
        containerNode:addChild(tempSprite)

        local function backCallFunc( node )
            showIndex = showIndex + 1
            if showIndex > #nameTab then
                showIndex = 1;
            end
            local tempDisplayFrame = getSpriteFrameByIndex(showIndex);
            if tempDisplayFrame == nil then return end
            tempSprite:setDisplayFrame(tempDisplayFrame)
            tempSprite:setPosition(ccp(scroll_view_size.width*0.5,-scroll_view_size.height))
        end
        local animArr = CCArray:create();
        animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*0.5)),5));
        -- animArr:addObject(CCFadeOut:create(0.5));
        -- animArr:addObject(CCFadeIn:create(0.5));
        animArr:addObject(CCDelayTime:create(5));
        animArr:addObject(CCEaseIn:create(CCMoveTo:create(0.5,ccp(scroll_view_size.width*0.5,scroll_view_size.height*2)),5));
        animArr:addObject(CCCallFuncN:create(backCallFunc));
        tempSprite:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    end
    showTips();
end
--[[
    推送
]]
function M.registerScriptApplication(self)
    local function addApplicationCallFunc(typeName)
        cclog("---------------------addApplicationCallFunc---------------------typeName= " .. tostring(typeName))
        if typeName == "didFinishLaunching" then
            if game_data_statistics then
                game_data_statistics:enterGame()
            end
            util_system:removeAllNotification();
        elseif typeName == "didEnterBackground" then
            local actionPointTime = game_data:getActionPointTime();
            if actionPointTime > 0 then
                util_system:addNotification(1,string_config.action_point_push_text,actionPointTime,false)
            end
            local server_time = math.floor(game_data:getUserStatusDataByKey("server_time") or 0)
            -- cclog("server_time == " .. server_time)
            --每天推送13：00   和   20：00两次   进击的巨人
            local today = os.date("*t")
            local oneHour = os.time({day=today.day, month=today.month,year=today.year, hour=13, minute=0, second=0})
            -- cclog("secondOfToday == " .. oneHour)
            local sub = oneHour - 300 - server_time
            if sub > 0 then
                util_system:addNotification(2,string_config.world_boss_push_text,sub,false)
            end
            local eightHour = os.time({day=today.day, month=today.month,year=today.year, hour=20, minute=0, second=0})
            -- cclog("eightHour == " .. eightHour)
            local sub2 = eightHour - 300 - server_time
            if sub2 > 0 then
                util_system:addNotification(2,string_config.world_boss_push_text,sub2,false)
            end
            game_data:didEnterBackground();
            if game_data_statistics then
                game_data_statistics:quitGame()
            end

            --推送生存大考验
            local nineHour = os.time({day=today.day, month=today.month,year=today.year, hour=9, minute=0, second=0})
            local live_sub = nineHour - server_time
            if live_sub > 0 then
                util_system:addNotification(3,string_config.active_live,live_sub,false)
            end
            local twenty_one = os.time({day=today.day, month=today.month,year=today.year, hour=21, minute=0, second=0})
            local live_sub2 = twenty_one - server_time
            if live_sub2 then
                --如果是周六，则不提示
                local wday = today.wday
                if wday ~= 7 then--不是周六
                    util_system:addNotification(3,string_config.active_live,live_sub2,false)
                end
            end

            --只显示一次的推送   --->第二天推送
            local uid = game_data:getUserStatusDataByKey("uid")
            if uid then
                local rewardSign = CCUserDefault:sharedUserDefault():getStringForKey(uid .. "rewardSign");
                -- cclog(uid .. "rewardSign = " .. tostring(rewardSign))
                if rewardSign == "first" then--为空说明第一天，推送，否则不推送
                    -- cclog("tuisong~~~~~~~~~~~~~~~~~")
                    CCUserDefault:sharedUserDefault():setStringForKey(uid .. "rewardSign","already");
                    CCUserDefault:sharedUserDefault():flush();
                    util_system:addNotification(4,string_helper.game_util.tomorowReward,1,false)
                end
            end
        elseif typeName == "willEnterForeground" then
            if game_data_statistics then
                game_data_statistics:enterGame()
            end
            if device.platform == "ios" then
                util_system:removeAllNotification();
            elseif device.platform == "android" then
                for i=1,4 do
                    util_system:removeNotificationById(i);
                end
            end
            game_data:willEnterForeground();
            game_scene:fillPropertyBarData();
        end
    end
    util_system:registerScriptApplicationHandler(addApplicationCallFunc);
end

function M.createBattleHeroLevelUpByCCB(self,backCallFunc,cardId,lv)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_battle_hero_levelup.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    local m_name_label = ccbNode:labelTTFForName("m_name_label")
    local m_level_label = ccbNode:labelTTFForName("m_level_label")
    local m_life_label = ccbNode:labelTTFForName("m_life_label")
    local m_physical_atk_label = ccbNode:labelTTFForName("m_physical_atk_label")
    local m_magic_atk_label = ccbNode:labelTTFForName("m_magic_atk_label")
    local m_def_label = ccbNode:labelTTFForName("m_def_label")
    local m_speed_label = ccbNode:labelTTFForName("m_speed_label")

    local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
    if cardData and heroCfg then
        -- m_level_label:setString(cardData.lv .. "/" .. cardData.level_max);
        m_level_label:setString(cardData.lv);
        m_name_label:setString(heroCfg:getNodeWithKey("name"):toStr());
        game_util:setHeroNameColorByQuality(m_name_label,heroCfg);
        m_life_label:setString(cardData.hp);
        m_physical_atk_label:setString(cardData.patk);
        m_magic_atk_label:setString(cardData.matk);
        m_def_label:setString(cardData.def);
        m_speed_label:setString(cardData.speed);
        local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
        local animNode = game_util:createIdelAnim(ainmFile,0,cardData,heroCfg);
        animNode:setAnchorPoint(ccp(0.5,0));
        m_anim_node:addChild(animNode);
    end
    -- local animNode = game_util:createIdelAnim("ailisi",0,nil,nil);
    -- animNode:setAnchorPoint(ccp(0.5,0));
    -- m_anim_node:addChild(animNode);
    local function animEnd(animName)
        ccbNode:removeFromParentAndCleanup(true);
        if backCallFunc ~= nil then backCallFunc(); end
    end
    ccbNode:registerAnimFunc(animEnd);
    ccbNode:runAnimations("level_up_anim");
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            ccbNode:removeFromParentAndCleanup(true);
            if backCallFunc ~= nil then backCallFunc(); end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    local text2 = ccbNode:labelTTFForName("text2")
    local text3 = ccbNode:labelTTFForName("text3")
    local text4 = ccbNode:labelTTFForName("text4")
    local text5 = ccbNode:labelTTFForName("text5")
    local text6 = ccbNode:labelTTFForName("text6")
    local text7 = ccbNode:labelTTFForName("text7")

    text1:setString(string_helper.ccb.text61)
    text2:setString(string_helper.ccb.text62)
    text3:setString(string_helper.ccb.text63)
    text4:setString(string_helper.ccb.text64)
    text5:setString(string_helper.ccb.text65)
    text6:setString(string_helper.ccb.text66)
    text7:setString(string_helper.ccb.text67)
    return ccbNode;
end

function M.getBuildingRewardId(self,tempId,count)
    count = count or 1;
    local icon,name = nil,nil;
    local building_mine = getConfig(game_config_field.building_mine);
    local reward_building_cfg = building_mine:getNodeWithKey(tostring(tempId))
    if reward_building_cfg then
        iconName = reward_building_cfg:getNodeWithKey("icon"):toStr();
        iconName = self:getResName(iconName);
        icon = CCSprite:createWithSpriteFrameName(iconName .. ".png")
        name = reward_building_cfg:getNodeWithKey("building_name"):toStr()-- .. "×" .. count;
    end
    return icon,name,count;
end

function M.getCardRewardId(self,tempId,count)
    local icon,name,quality = nil,nil,0;
    local character_detail_cfg = getConfig(game_config_field.character_detail);
    local itemCfg = character_detail_cfg:getNodeWithKey(tostring(tempId));
    if itemCfg then
        -- cclog("getCardRewardId tempId ============== " .. tostring(tempId) .. " ; count ===========" .. tostring(count));
        name = itemCfg:getNodeWithKey("name"):toStr()-- .. (count ~= nil and "×" .. count or "");
        icon = self:createCardIconByCfg(itemCfg);
        quality = itemCfg:getNodeWithKey("quality"):toInt();
    end
    return icon,name,count,quality;
end

function M.getItemRewardId(self,tempId,count)
    -- cclog(tostring(tempId) .. " ; count ===========" .. tostring(count))
    local icon,name,quality = nil,nil,0;
    local item = getConfig(game_config_field.item);
    local itemCfg = item:getNodeWithKey(tostring(tempId));
    if itemCfg then
        -- cclog("getItemRewardId tempId ============== " .. tostring(tempId) .. " ; count ===========" .. tostring(count));
        name = itemCfg:getNodeWithKey("name"):toStr()-- .. (count ~= nil and "×" .. count or "");
        icon = self:createItemIconByCfg(itemCfg);
        quality = itemCfg:getNodeWithKey("quality"):toInt();
    else
        cclog("item cfg not found == " .. tostring(tempId))
    end
    return icon,name,count,quality;
end

function M.getEquipRewardId(self,tempId,count)
    local icon,name,quality = nil,nil,0;
    local equipCfg = getConfig(game_config_field.equip);
    local itemCfg = equipCfg:getNodeWithKey(tostring(tempId));
    if itemCfg then
        -- cclog("getEquipRewardId tempId ============== " .. tostring(tempId) .. " ; count ===========" .. tostring(count));
        name = itemCfg:getNodeWithKey("name"):toStr()-- .. (count ~= nil and "×" .. count or "");
        icon = self:createEquipIcon(itemCfg);
        quality = itemCfg:getNodeWithKey("quality"):toInt();
    end
    return icon,name,count,quality;
end
--[[--
    通用奖励
]]
function M.getRewardByItem(self,itemJsonData,flag)
    if itemJsonData == nil then return nil,nil,nil end
    return self:getRewardByItemTable(json.decode(itemJsonData:getFormatBuffer()),flag);
end

--[[--
    通用奖励
]]
function M.getRewardByItemTable(self,dataTable,flag)
    if flag == nil then
        flag = false;
    end
    local icon,name,count,rewardType,quality = nil,nil,0,0,0
    if dataTable and #dataTable > 2 then
        rewardType = dataTable[1]
        local tempId = dataTable[2];
        local tempCount = dataTable[3];
        if rewardType == 1 then--食品，占位，参数数量；[1,0,100]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_food2.png"),string_helper.game_util.food,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 2 then--金属，占位，参数数量；[2,0,100]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_metal2.png"),string_helper.game_util.metal,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 3 then--能源，占位，能源数量；[3,0,100]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_energy2.png"),string_helper.game_util.energy,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 4 then--能晶，占位，能晶数量；[4,0,100]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_crystal2.png"),string_helper.game_util.crystal,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 5 then--卡牌，卡牌ID,数量；[5,4,1]
            icon,name,count,quality = self:getCardRewardId(tempId,tempCount);
        elseif rewardType == 6 then--道具，ID,数量；[6,4,1]
            icon,name,count,quality = self:getItemRewardId(tempId,tempCount);
        elseif rewardType == 7 then--装备,ID，数量；[7,4,1]
            icon,name,count,quality = self:getEquipRewardId(tempId,tempCount);
        elseif rewardType == 8 then--玩家经验，占位，数值;[8,0,100]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_add_exp.png"),string_helper.game_util.exp,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 9 then--钻石,占位，数量;[9,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_gold2.png"),string_helper.game_util.dimond,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 10 then--强能之尘,占位，数量;[10,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_chen_2.png"),string_helper.game_util.sliverDirt,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 11 then--超能之尘,占位，数量;[11,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_chen_1.png"),string_helper.game_util.goldDirt,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 12 then--阵石,占位，数量;[12,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_gold2.png"),string_helper.game_util.zhenshi,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 13 then--行动力,占位，数量;[13,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_action_point2.png"),string_helper.game_util.point,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 14 then--星灵,占位，数量;[14,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_xingxing2.png"),string_helper.game_util.star,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 15 then--金币,占位，数量;[15,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_silver2.png"),string_helper.game_util.gold,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 16 then--精炼石
            icon,name,count = CCSprite:createWithSpriteFrameName("public_xilian2.png"),string_helper.game_util.refining,tempCount 
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 17 then--神恩
            icon,name,count = CCSprite:createWithSpriteFrameName("public_shenen_d2.png"),string_helper.game_util.divine,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 18 then--高级神恩
            icon,name,count = CCSprite:createWithSpriteFrameName("public_shenen_g2.png"),string_helper.game_util.divineer,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 19 then--宝石
            icon,name,count,quality = self:getGemRewardId(tempId,tempCount);
        elseif rewardType == 20 then--高级能晶
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_gaojinengjing2.png"),string_helper.game_util.crystaler,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 21 then--魔光碎片
            icon,name,count = CCSprite:createWithSpriteFrameName("public_icon_piece2.png"),string_helper.game_util.pieces,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        elseif rewardType == 100 then--功勋,占位,数量；[100,0,1]
            icon,name,count = CCSprite:createWithSpriteFrameName("public_medal2.png"),string_helper.game_util.gongxun,tempCount
            quality = self:setQualityIcon(icon,rewardType,tempCount)
        end
    end
    if flag == true then
        name = tostring(name) .. (count ~= nil and "×" .. count or "");
    end
    return icon,name,count,rewardType,quality
end
--[[
    根据rewardType得到颜色
]]
function M.setQualityIcon(self,tempIcon,rewardType,rewardCount)
    -- resoucequality
    if tempIcon then
        local quality = 0;
        rewardType = rewardType or 0;
        rewardCount = rewardCount or 0;
        local resoucequality_cfg = getConfig(game_config_field.resoucequality)
        if resoucequality_cfg then
            local itemCfg = resoucequality_cfg:getNodeWithKey(rewardType)
            if itemCfg then
                for i=0,6 do
                    local tempItemCfg = itemCfg:getNodeWithKey("quailty" .. i)
                    if tempItemCfg and tempItemCfg:getNodeCount() > 1 then
                        if rewardCount >= tempItemCfg:getNodeAt(0):toInt() and rewardCount <= tempItemCfg:getNodeAt(1):toInt() then
                            quality = i;
                            break;
                        end
                    end
                end
            end
        end
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
        if tempIcon and qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,-1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,1)
        end
        return quality
    end
    return 0;
end

--[[
    查看通用奖励方法  [5,6,7]
]]
function M.lookItemDetal(self,tempTable)
    cclog2(tempTable,"tempTable")
    local itemDataType = tempTable[1]
    local itemId = tempTable[2]
    local itemCount = tempTable[3]
    if itemDataType == 6 then--道具
        if itemId >= 1000 and itemId < 2000 then--卡牌碎片
            local itemCfg = getConfig(game_config_field.item)
            local exchageCfg = getConfig(game_config_field.exchange)
            local heroId = itemId
            local sortId = itemCfg:getNodeWithKey(heroId):getNodeWithKey("sort"):toStr()
            local changeId = exchageCfg:getNodeWithKey(sortId):getNodeWithKey("change_id"):getNodeAt(0):getNodeAt(1):toStr()
            game_scene:addPop("game_hero_info_pop",{cId = tostring(changeId),openType = 4})
        elseif itemId >= 2000 and itemId < 3000 then--装备碎片
            local itemCfg = getConfig(game_config_field.item)
            local exchageCfg = getConfig(game_config_field.exchange)
            local equipId = itemId
            local sortId = itemCfg:getNodeWithKey(equipId):getNodeWithKey("sort"):toStr()
            local changeId = exchageCfg:getNodeWithKey(sortId):getNodeWithKey("change_id"):getNodeAt(0):getNodeAt(1):toStr()
            local equipData = {lv = 1,c_id = changeId,id = -1,pos = -1}
            game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
        else--道具
            game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
        end
    elseif itemDataType == 7 then--装备
        local equipData = {lv = 1,c_id = itemId,id = -1,pos = -1}
        game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
    elseif itemDataType == 5 then--卡牌
        game_scene:addPop("game_hero_info_pop",{cId = tostring(itemId),openType = 4})
    elseif itemDataType == 19 then--宝石
        game_scene:addPop("gem_system_info_pop",{tGameData = {count = itemCount,c_id = itemId},callBack = nil, openType=1});
    else--查看食物等等
        game_scene:addPop("game_food_info_pop",{itemData = tempTable})
    end
end
--[[--
    通用奖励
]]
function M.rewardTipsByJsonData(self,jsonData,callBackFunc)
    if jsonData == nil then return end
    return self:rewardTipsByDataTable(json.decode(jsonData:getFormatBuffer()),callBackFunc);
end

--[[--
    通用奖励
]]
function M.rewardTipsByDataTable(self,dataTable,callBackFunc)
    if dataTable == nil then return end
    cclog("rewardTipsByDataTable ---------------" .. json.encode(dataTable))

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res_add.plist");    
    local rewardCount = 0;
    local function removeCallFunc()
        rewardCount = rewardCount - 1;
        if rewardCount <= 0 then
            if callBackFunc then
                callBackFunc();
            end
        end
    end
    local function createRewardItem(icon,name)
        local bgSpr = CCSprite:createWithSpriteFrameName("public_reward_item_bg.png")
        local bgSprSize = bgSpr:getContentSize();
        if icon then
            icon:setPosition(ccp(bgSprSize.width*0.4,bgSprSize.height*0.5));
            icon:setScale(0.75);
            bgSpr:addChild(icon);
        end
        if name then
            local tempLabel = self:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 16});
            tempLabel:setPosition(ccp(bgSprSize.width*0.6,bgSprSize.height*0.5));
            bgSpr:addChild(tempLabel);
        end
        rewardCount = rewardCount + 1;
        self:addMoveTipsByNode(bgSpr,0.5*(rewardCount-1),removeCallFunc);
    end
    local icon,name;
    local food = dataTable.food or 0;
    if food ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_food2.png"),string_helper.game_util.food .. "×" .. food;
        createRewardItem(icon,name);
    end
    local metal = dataTable.metal or 0
    if metal ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_metal2.png"),string_helper.game_util.metal .. "×" .. metal;
        createRewardItem(icon,name);
    end
    local energy = dataTable.energy or 0
    if energy ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_energy2.png"),string_helper.game_util.energy .. "×" .. energy;
        createRewardItem(icon,name);
    end
    local crystal = dataTable.crystal or 0
    if crystal ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_crystal2.png"),string_helper.game_util.crystal .. "×" .. crystal;
        createRewardItem(icon,name);
    end
    local adv_crystal = dataTable.adv_crystal or 0
    if adv_crystal ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_gaojinengjing2.png"),string_helper.game_util.crystaler .. "×" .. adv_crystal;
        createRewardItem(icon,name);
    end
    local coin = dataTable.coin or 0;
    if coin ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_gold2.png"),string_helper.game_util.dimond .. "×" .. coin;
        createRewardItem(icon,name);
    end
    local dirt_silver = dataTable.dirt_silver or 0;
    if dirt_silver ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_chen_2.png"),string_helper.game_util.goldDirt .. "×" .. dirt_silver;
        createRewardItem(icon,name);
    end
    local dirt_gold = dataTable.dirt_gold or 0;
    if dirt_gold ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_chen_1.png"),string_helper.game_util.sliverDirt .. "×" .. dirt_gold;
        createRewardItem(icon,name);
    end
    local action_point = dataTable.action_point or 0;
    if action_point ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_action_point2.png"),string_helper.game_util.hp .. "×" .. action_point;
        createRewardItem(icon,name);
    end
    local arena_point = dataTable.arena_point or 0;
    if arena_point ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_medal2.png"),string_helper.game_util.gongxun .. "×" .. arena_point;
        createRewardItem(icon,name);
    end
    local star = dataTable.star or 0;
    if star ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_xingxing2.png"),string_helper.game_util.star .. "×" .. star;
        createRewardItem(icon,name);
    end
    local silver = dataTable.silver or 0;
    if silver ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_silver2.png"),string_helper.game_util.gold .. "×" .. silver;
        createRewardItem(icon,name);
    end
    local cards = dataTable.cards or {};
    local tempId,tempQuality = "-1",-1;
    for k,cardId in pairs(cards) do
        local cardData,heroCfg = game_data:getCardDataById(tostring(cardId));
        if heroCfg then
            name = heroCfg:getNodeWithKey("name"):toStr() .. (count ~= nil and "×" .. count or "×1")
            icon = self:createCardIconByCfg(heroCfg);
            createRewardItem(icon,name);
            local quality = heroCfg:getNodeWithKey("quality"):toInt();
            if quality > tempQuality then
                tempQuality = quality
                tempId = tostring(cardId);
            end
        end 
    end
    local animFlag = self:addRewardCardAnim(tempId);
    local equip = dataTable.equip or {};
    tempId,tempQuality = "-1",-1;
    for k,equipId in pairs(equip) do
        local itemData,itemCfg = game_data:getEquipDataById(tostring(equipId));
        if itemCfg then
            name = itemCfg:getNodeWithKey("name"):toStr() .. (count ~= nil and "×" .. count or "×1")
            icon = self:createEquipIcon(itemCfg);
            createRewardItem(icon,name);
            local quality = itemCfg:getNodeWithKey("quality"):toInt();
            if quality > tempQuality then
                tempQuality = quality
                tempId = tostring(equipId);
            end
        end
    end
    if animFlag == false and tempId ~= "-1" then
        self:addRewardEquipAnim(tempId);
    end
    local item = dataTable.item or {};
    local tempIdTab = {};
    for k,itemCid in pairs(item) do
        if tempIdTab[itemCid] == nil then
            tempIdTab[itemCid] = 1;
        else
            tempIdTab[itemCid] = tempIdTab[itemCid] + 1;
        end
    end
    for itemCid,count in pairs(tempIdTab) do
        icon,name,count = self:getItemRewardId(itemCid,count);
        createRewardItem(icon,name .. (count ~= nil and "×" .. count or "×1"))
    end
    local metalcore = dataTable.metalcore or 0
    if metalcore ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_xilian2.png"), string_helper.game_util.refining .. "×" .. metalcore;
        createRewardItem(icon,name);
    end
    local grace = dataTable.grace or 0;
    if grace ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_shenen_d2.png"), string_helper.game_util.divine .. "×" .. grace;
        createRewardItem(icon,name);
    end
    local grace_high = dataTable.grace_high or 0;
    if grace_high ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_shenen_g2.png"), string_helper.game_util.divineer .. "×" .. grace_high;
        createRewardItem(icon,name);
    end
    local enchant = dataTable.enchant or 0;
    if enchant ~= 0 then
        icon,name = CCSprite:createWithSpriteFrameName("public_icon_piece2.png"), string_helper.game_util.pieces .. "×" .. enchant;
        createRewardItem(icon,name)
    end
    local gem = dataTable.gem or {}
    local tempIdTab = {};
    for k,itemCid in pairs(gem) do
        if tempIdTab[itemCid] == nil then
            tempIdTab[itemCid] = 1;
        else
            tempIdTab[itemCid] = tempIdTab[itemCid] + 1;
        end
    end
    for itemCid,count in pairs(tempIdTab) do
        icon,name,count = self:getGemRewardId(itemCid,count);
        createRewardItem(icon,name .. (count ~= nil and "×" .. count or "×1"))
    end
    if rewardCount == 0 then
        if callBackFunc then
            callBackFunc();
        end
    end
    return rewardCount;
end
--[[
    添加技能
]]
function M.setSkillInfo(self,skillItemData,skillItemCfg,iconNode,namePosType)
    if skillItemData and skillItemCfg and iconNode then
        -- 'avail': 1   # 0表示未解锁，1表示解锁未激活，2表示激活
        local avail = skillItemData.avail;
        local icon_size = iconNode:getContentSize();
        local skill_icon_spr = game_util:createSkillIconByCfg(skillItemCfg,avail);
        if skill_icon_spr then
            skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
            iconNode:addChild(skill_icon_spr);
        end
        local lvLabel = nil;
        local tempLabel = nil;
        if avail ~= 2 then
            local lock_icon_spr = CCSprite:createWithSpriteFrameName("public_lock_icon.png");
            -- lock_icon_spr:setOpacity(150);
            lock_icon_spr:setPosition(icon_size.width*0.5,icon_size.height*0.5);
            iconNode:addChild(lock_icon_spr,5,5);
            -- skill_icon_spr:setColor(ccc3(155,155,155));
            -- local lockLabel = CCLabelTTF:create("未解锁",TYPE_FACE_TABLE.Arial_BoldMT,8);
            -- lockLabel:setColor(ccc3(155,155,155));
            -- lockLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
            -- bottomNode:addChild(lockLabel);
        -- elseif avail == 1 then
        --     skill_icon_spr:setColor(ccc3(155,155,155));
        --     tempLabel:setString("未激活")`
        else
        end
        lvLabel = self:createLabel({text = "Lv." .. skillItemData.lv,color = ccc3(255, 255, 0), fontSize = 8})
        lvLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.15));
        iconNode:addChild(lvLabel,10,10);
        -- tempLabel = self:createLabel({text = skillItemCfg:getNodeWithKey("skill_name"):toStr()})
        tempLabel = self:createLabelTTF({text = skillItemCfg:getNodeWithKey("skill_name"):toStr(), fontSize = 8})
        if namePosType == nil or namePosType == 1 then
            tempLabel:setPosition(ccp(icon_size.width*0.5,-icon_size.height*0.15));
        else
            tempLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*1.15));
        end
        if skill_icon_spr then
            tempLabel:setDimensions(CCSizeMake( skill_icon_spr:getContentSize().width * 2, 0 ))
        end
        iconNode:addChild(tempLabel,10,11);
        return skill_icon_spr,lvLabel,tempLabel
    end
end
--[[--
    写错误信息
]]
function M.writeErrorMessage(self,msg)
    local writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
    local fullpath = writablePath .. "errorMsg.temp";
    util.writeFile(fullpath,"\ntime=" .. os.date() .. " : " .. msg,"a");
end

--[[--
    写战斗数据
]]
function M.writeBattleData(self,msg)
    -- local writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
    -- util.writeFile(writablePath .. "battleData" .. os.date() ..".temp",msg);
end

function M.createItemIconByCid(self,cid,showImg1)
    local config_date = getConfig(game_config_field.item);
    local itemCfg = config_date:getNodeWithKey(tostring(cid));
    if itemCfg == nil then return nil,nil end
    return self:createItemIconByCfg(itemCfg,showImg1),itemCfg:getNodeWithKey("name"):toStr();
end

--创建物品图标
function M.createItemIconByCfg(self,itemCfg,showImg1)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_public_iconcer.plist")
    local tempIcon = nil;
    if itemCfg then
        showImg1 = showImg1 == nil and true or showImg1;
        tempIcon = self:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
        local shade = itemCfg:getNodeWithKey("shade"):toStr();
        local quality = itemCfg:getNodeWithKey("quality"):toInt();
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
        if tempIcon and qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            if showImg1 == true then
                local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
                img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
                tempIcon:addChild(img1,-1,-1)
            end
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,1)
        end
        if tempIcon and shade ~= "" then
            shade = game_util:getResName(shade);
            local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tostring(shade) .. ".png");
            if tempSpriteFrame then
                local shadeSpr = CCSprite:createWithSpriteFrame(tempSpriteFrame);
                local tempSize = tempIcon:getContentSize();
                shadeSpr:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                tempIcon:addChild(shadeSpr,10);
            end
        end
    end
    return tempIcon;
end

function M.createLeaderSkillIconByCid(self,cid,treeId,openFlag)
    local leader_skill_cfg = getConfig(game_config_field.leader_skill)
    local itemCfg = leader_skill_cfg:getNodeWithKey(tostring(cid));
    return self:createLeaderSkillIconByCfg(itemCfg,treeId,openFlag);
end

function M.createLeaderSkillIconByCfg(self,itemCfg,treeId,openFlag)
    local tempIcon = nil;
    if treeId == nil then
        local skillIdTreeTab = game_data:getSkillIdTreeTab() or {};
        treeId = skillIdTreeTab[tostring(cid)] or 1;
    end
    if openFlag == nil then
        openFlag = false;
    end
    local is_positive = 0;
    if itemCfg then
        tempIcon = game_util:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
        if tempIcon then
            local tempSize = tempIcon:getContentSize();
            local treeBg = game_util:createIconByName(LEADER_SKILL_TREE_TABLE[tonumber(treeId)].iconBg);
            if treeBg then
                treeBg:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                tempIcon:addChild(treeBg,-1,-1);
            end
            is_positive = itemCfg:getNodeWithKey("is_positive"):toInt()--0被动技能  1主动技能 
            local skillIconUp = nil;
            if not openFlag then--未开启
                tempIcon:setColor(ccc3(54,54,54));
                if is_positive == 1 then
                    skillIconUp = CCSprite:createWithSpriteFrameName("public_skillActionDark.png")
                else
                    skillIconUp = CCSprite:createWithSpriteFrameName("public_skillNormalDark.png")
                end
            else--开启
                if is_positive == 1 then
                    skillIconUp = CCSprite:createWithSpriteFrameName("public_skillAction.png")
                else
                    skillIconUp = CCSprite:createWithSpriteFrameName("public_skillNormal.png")
                end
            end
            if skillIconUp then
                skillIconUp:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
                tempIcon:addChild(skillIconUp,1,1);
            end
        end
    end
    return tempIcon,is_positive;
end

function M.createIconByName(self,iconName,quality)
    iconName = self:getResName(iconName);
    local tempIcon = CCSprite:create("icon/" .. iconName .. ".png");
    if tempIcon == nil then
        tempIcon = CCSprite:create("icon/" .. iconName .. ".jpg");
    end
    if quality and tempIcon then
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality]
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,2)
        end
    end
    return tempIcon;
end

function M.addIconQualityBgByQuality(self,tempIcon,quality)
    quality = quality or 1;
    local qualityTab = HERO_QUALITY_COLOR_TABLE[quality];
    if tempIcon and qualityTab then
        local tempIconSize = tempIcon:getContentSize();
        local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
        img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        tempIcon:addChild(img1,-1,1)
        local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
        img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
        tempIcon:addChild(img2,1,2)
    end
end

function M.getResName(self,iconName)
    iconName = tostring(iconName);
    local firstValue,_ = string.find(iconName,".png");
    if firstValue then
        iconName = string.sub(iconName,0,firstValue-1);
    end
    local firstValue,_ = string.find(iconName,".jpg");
    if firstValue then
        iconName = string.sub(iconName,0,firstValue-1);
    end
    return iconName;
end

function M.createSkillIconByCid(self,cid,avail)
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);
    local itemCfg = skill_detail_cfg:getNodeWithKey(tostring(cid));
    if itemCfg == nil then 
        return nil,nil 
    end
    return self:createSkillIconByCfg(itemCfg,avail),itemCfg:getNodeWithKey("skill_name"):toStr();
end

function M.createSkillIconByCfg(self,itemCfg,avail)
    avail = avail or 2;
    local tempIcon = nil;
    if itemCfg then
        local skill_icon = itemCfg:getNodeWithKey("skill_icon"):toStr();
        -- cclog(skill_icon)
        tempIcon = self:createIconByName(skill_icon);
    end
    if tempIcon then
        local skill_quality = itemCfg:getNodeWithKey("skill_quality"):toInt()+1;
        cclog("skill_quality ==================" .. skill_quality)
        local qualityTab = HERO_QUALITY_COLOR_TABLE[skill_quality];
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,2)
            if avail ~= 2 then
                img1:setColor(ccc3(151, 151, 151))
                img2:setColor(ccc3(151, 151, 151))
                tempIcon:setColor(ccc3(151, 151, 151))
            end
        end
    end
    return tempIcon;
end


function M.openAlertView(self,t_params)
    require("game_ui.game_pop_up_box").show(t_params);
end

function M.closeAlertView(self)
    require("game_ui.game_pop_up_box").close(); 
end

function M.setLabelTTFStroke(self,label,tintColor,strokeColor,strokeSize)
    if label == nil then return end
    tintColor = tintColor or ccc3(255, 255, 255);
    strokeColor = strokeColor or ccc3(0, 0, 0);
    strokeSize = strokeSize or 0.5;
    setLabelTTFStroke(label,tintColor,strokeColor,strokeSize);
end

function M.createProgressTimer(self,t_params)
    t_params = t_params or {};
    t_params.fileName = t_params.fileName or "o_public_skillExpAdd.png";
    t_params.percentage = t_params.percentage or 0;
    t_params.midpoint = t_params.midpoint or ccp(0,0);
    t_params.barChangeRate = t_params.barChangeRate or ccp(1, 0);
    t_params.type = t_params.type or kCCProgressTimerTypeBar;
    local tempSprite = CCSprite:createWithSpriteFrameName(t_params.fileName)
    local bar = nil;
    if tempSprite then
        bar = CCProgressTimer:create(tempSprite);
        bar:setMidpoint(t_params.midpoint);
        bar:setBarChangeRate(t_params.barChangeRate);
        bar:setType(t_params.type);
        bar:setPercentage(t_params.percentage);
    end
    return bar;
end

function M.createLabel(self,t_params)
    t_params = t_params or {};
    if t_params.lableType == nil or t_params.lableType == "bmfont" then
        return self:createLabelBMFont(t_params);
    else
        return self:createLabelTTF(t_params);
    end
end

function M.createLabelBMFont(self,t_params)
    t_params = t_params or {};
    t_params.fnt = t_params.fnt or "chinese_character.fnt";
    t_params.text = t_params.text or "";
    t_params.color = t_params.color or ccc3(255,255,255)
    t_params.scale = t_params.scale or 1
    local tempLabel = CCLabelBMFont:create(t_params.text,t_params.fnt);
    tempLabel:setColor(t_params.color);
    tempLabel:setScale(t_params.scale);
    return tempLabel;
end

function M.createLabelTTF(self,t_params)
    t_params = t_params or {};
    t_params.text = t_params.text or "";
    t_params.color = t_params.color or ccc3(255,255,255)
    t_params.scale = t_params.scale or 1;
    t_params.fontSize = t_params.fontSize or 10;
    local tempLabel = CCLabelTTF:create(t_params.text,TYPE_FACE_TABLE.Arial_BoldMT,t_params.fontSize);
    tempLabel:setColor(t_params.color);
    tempLabel:setScale(t_params.scale);
    return tempLabel;
end


function M.createRichLabelTTF(self,params)
    params = params or {};
    params.text = params.text or "";
    params.fontSize = params.fontSize or 10;
    params.fontName = params.fontName or "Arial-BoldMT";
    params.color = params.color or ccc3(255,255,255)
    local richLabelTTF = nil;
    if params.textAlignment and params.verticalTextAlignment and params.dimensions then
        richLabelTTF = CCRichLabelTTF:create(params.text,params.fontName,params.fontSize,params.dimensions,params.textAlignment,params.verticalTextAlignment);
    elseif params.textAlignment and params.verticalTextAlignment == nil and params.dimensions then
        richLabelTTF = CCRichLabelTTF:create(params.text,params.fontName,params.fontSize,params.dimensions,params.textAlignment);
    else
        richLabelTTF = CCRichLabelTTF:create(params.text,params.fontName,params.fontSize);
    end
    richLabelTTF:setColor(params.color);
    return richLabelTTF;
end

function M.setNpcImg(self,npcSpr,flipX)
    if npcSpr == nil then return end
    flipX = flipX == nil and false or true;
    local bigImg = self:createOwnBigImg();
    if bigImg then
        npcSpr:setDisplayFrame(bigImg:displayFrame());
        npcSpr:setFlipX(flipX)
        npcSpr:setScale(0.75);
    end
end

function M.createPlayerRoleAnim(self,animFile,rhythm)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        animNode:playSection(theLabelName);
    end
    local mAnimNode = zcAnimNode:create(animFile .. ".swf.sam", 0, animFile.. ".plist");
    if mAnimNode == nil then
        animFile = "role_soldier";
        mAnimNode = zcAnimNode:create(animFile .. ".swf.sam", 0, animFile.. ".plist");
    end
    if mAnimNode then
        mAnimNode:setAnchorPoint(ccp(0.5,0.5));
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:playSection("xiazuoD");
        mAnimNode:setRhythm(rhythm);
        -- mAnimNode:setScale(0.5);
    end
    return mAnimNode
end

function M.createOwnRoleAnim(self)
    local tempAnim = nil;
    local animName = nil;
    local roleId = game_data:getUserStatusDataByKey("role")
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    if itemCfg then
        animName = itemCfg:getNodeWithKey("animation"):toStr();
    else
        animName = "role_soldier";
    end
    return self:createPlayerRoleAnim(animName,1);
end

function M.createOwnBigImg(self)
    local roleId = game_data:getUserStatusDataByKey("role")
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerBigImgByCfg(itemCfg);
end

function M.createOwnBigImgHalf(self)
    local roleId = game_data:getUserStatusDataByKey("role")
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerBigImgByCfg(itemCfg,"_half");
end

function M.createRoleBigImgHalf( self, roleId )
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerBigImgByCfg(itemCfg,"_half");
end


function M.createPlayerBigImgByRoleId(self,roleId,extStr)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. tostring(roleId));
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerBigImgByCfg(itemCfg,extStr);
end

function M.createPlayerBigImgByCfg(self,itemCfg,extStr)
    local temp_big_img = nil;
    if itemCfg then
        extStr = extStr or "";
        local img = itemCfg:getNodeWithKey("img"):toStr();
        img = self:getResName(img);
        cclog("img ========================" .. img);
        temp_big_img = CCSprite:create("humen/" .. img .. extStr .. ".png");
    end
    return temp_big_img;
end

function M.createPlayerBattleImgRoleId(self,roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    cclog("roleId ========================" .. roleId);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerBattleImgByCfg(itemCfg);
end

function M.createPlayerBattleImgByCfg(self,itemCfg)
    local temp_img = nil;
    if itemCfg then
        local battle_icon = itemCfg:getNodeWithKey("battle_icon"):toStr()
        battle_icon = self:getResName(battle_icon);
        temp_img = CCSprite:create("humen/" .. battle_icon .. ".png");
    end
    return temp_img;
end

function M.createPlayerIconByRoleId(self,roleId)
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    -- cclog("roleId ========================" .. roleId);
    local itemCfg = role_detail_cfg:getNodeWithKey(tostring(roleId))
    return self:createPlayerIconByCfg(itemCfg);
end

function M.createPlayerIconByCfg(self,itemCfg)
    local temp_icon = nil;
    if itemCfg then
        local icon = self:getResName(itemCfg:getNodeWithKey("icon"):toStr());
        temp_icon = CCSprite:create("humen/" .. icon .. "_b.png")
    end
    return temp_icon;
end

--[[--
    通过卡牌配置创建卡牌全身像
]]
function M.createCardImgByCfg(self,itemConfig)
    if itemConfig == nil then return nil end
    local animation = itemConfig:getNodeWithKey("animation"):toStr();
    local rgb = itemConfig:getNodeWithKey("rgb_sort"):toInt();
    return self:createImgByName("image_" .. animation,rgb,nil,nil,1,itemConfig)
end
--[[--
    通过通过名字创建卡牌全身像
]]
function M.createImgByName(self,fileName,rgb_sort,anim_flag,bFlipX,wake_lv,heroCfg)
    wake_lv = wake_lv or 0
    heroCfg = heroCfg or nil
    rgb_sort = rgb_sort or 0;
    fileName = self:getResName(fileName);
    local tempImg = CCSprite:create("img/" .. fileName .. ".png");
    if tempImg then
        if bFlipX ~= nil then
            tempImg:setFlipX(bFlipX);
        end
        if rgb_sort == 1 then
            tempImg:setColor(ccc3(47,255,118));
        elseif rgb_sort == 2 then
            tempImg:setColor(ccc3(67,117,253));
        elseif rgb_sort == 3 then
            tempImg:setColor(ccc3(171,65,255));
        end

        local effectFileName = string.sub(fileName,7)
        -- cclog("effectFileName ========= " .. effectFileName)
        local tempSize = tempImg:getContentSize();
        anim_flag = anim_flag == nil and true or anim_flag;
        -- cclog("fileName == " .. fileName)
        -- cclog("anim_flag = " .. tostring(anim_flag))

        if anim_flag == true then
            -- local effectNode = self:createUniversalAnim({animFile = effectFileName .. "_action1",loopFlag = true});
            -- if effectNode then
            --     effectNode:setRhythm(1);
            --     effectNode:setPosition(ccp(tempSize.width*0.5, 20))
            --     if bFlipX ~= nil then
            --         effectNode:setFlipX(bFlipX);
            --     end
            --     tempImg:addChild(effectNode,1)
            -- end
            -- local effectNode = self:createUniversalAnim({animFile = effectFileName .. "_action2",loopFlag = true});
            -- if effectNode then
            --     effectNode:setRhythm(1);
            --     effectNode:setPosition(ccp(tempSize.width*0.5, 20))
            --     if bFlipX ~= nil then
            --         effectNode:setFlipX(bFlipX);
            --     end
            --     tempImg:addChild(effectNode,-1)
            -- end

            --总共有7层
            local wake_table = {"wake1","wake2","wake3","wake4","wake5","wake6","wake6","wake6","wake6","wake6","wake6"}
            local layer_table = {4,3,2,1,-1,-2,-3,-4,-5}--层级关系表
            if heroCfg and wake_table[wake_lv+1] then
                local itemWakeCfg = heroCfg:getNodeWithKey(wake_table[wake_lv+1])
                if itemWakeCfg then
                    local effectImg = itemWakeCfg:getNodeAt(0)
                    if effectImg then
                        for i=1,effectImg:getNodeCount() do
                            local fileName = effectImg:getNodeAt(i-1):toStr()
                            local splitTab = util.stringSplit(fileName,"_");
                            local lastStr = splitTab[#splitTab]
                            local layer = layer_table[tonumber(lastStr)]
                            local effectNode = self:createUniversalAnim({animFile = fileName,loopFlag = true});
                            if effectNode then
                                effectNode:setRhythm(1);
                                effectNode:setPosition(ccp(tempSize.width*0.5, 20))
                                if bFlipX ~= nil then
                                    effectNode:setFlipX(bFlipX);
                                end
                                tempImg:addChild(effectNode,layer)
                            end
                        end
                    end
                end
            end
        end
    end
    return tempImg;
end

function M.getCardUserLockFlag(self,itemData)
    local lockFlag = false;
    if itemData and itemData.remove_avail then
        for k,v in pairs(itemData.remove_avail) do
            if tostring(v) == "user" then
                lockFlag = true;
                break;
            end
        end
    end
    return lockFlag;
end
--[[
    判断是否在训练中
]]
function M.getCardTrainingFlag(self,itemData)
    local trainingFlag = false;
    if itemData and itemData.remove_avail then
        for k,v in pairs(itemData.remove_avail) do
            if tostring(v) == "train" then
                trainingFlag = true;
                break;
            end
        end
    end
    return trainingFlag;
end

function M.getCardLockFlag(self,itemData)
    local lockFlag = false;
    if itemData and itemData.remove_avail and #itemData.remove_avail > 0 then
        lockFlag = true;
    end
    return lockFlag;
end
--[[
    通过id获取自己伙伴的扩展属性
]]
function M.getOwnCardAttrValueByCardId(self,cardId)
    local heroData,_ = game_data:getCardDataById(cardId)
    local commanderData = game_data:getCommanderAttrsData();
    local posIndex = game_data:getHeroInTeamIndexById(cardId);
    local posGemData,posEquipData = {},{};
    if posIndex > 0 then
        local equipPosData = game_data:getEquipPosData() or {};
        local gemPosData = game_data:getGemPosData() or {};
        posGemData = gemPosData[tostring(posIndex-1)] or {}
        posEquipData = equipPosData[tostring(posIndex-1)] or {}
    end
    return self:getCardAttrValueByData(heroData,posEquipData,posGemData,commanderData) or {}
end

--[[
    
]]
function M.getOtherCardAttrValueByCardId(self, posIndex, heroData,  playerData)

    local commanderData = nil

    local posGemData,posEquipData = {},{};
    if posIndex > 0 then
        local equipPosData = playerData:getEquipPosData() or {};
        local gemPosData = playerData:getGemPosData() or {};
        posGemData = gemPosData[tostring(posIndex-1)] or {}
        posEquipData = equipPosData[tostring(posIndex-1)] or {}
    end
    local equipData = playerData:getEquipData()
    return self:getCardAttrValueByData(heroData,posEquipData,posGemData,commanderData, equipData) or {}
end

--[[
    获取卡牌的扩展属性
]]
function M.getCardAttrValueByData(self,cardData,posEquipData,posGemData,commanderData,equipDataAll)
    local attrValueTab = {fire = 0,water = 0,wind = 0,earth = 0,fire_dfs = 0,water_dfs = 0,wind_dfs = 0,earth_dfs = 0}
    --装备扩展属性
    local attrValueTabExt = {};
    local equipCfg = getConfig(game_config_field.equip);
    local equipPosItemData = posEquipData or {}
    local suitTab = {};
    for k,v in pairs(equipPosItemData) do
        v = tostring(v)
        if v ~= "0" then
            equipData,equipCfg = game_data:getEquipDataById(v);
            if equipData and equipCfg then
                local suit = equipCfg:getNodeWithKey("suit"):toInt();
                if suitTab[suit] == nil then
                    suitTab[suit] = 0;
                    local _,_,_,tempAttrValueTabExt = self:getEquipSuit(suit,equipPosItemData,equipDataAll);
                    attrValueTabExt = tempAttrValueTabExt or {};
                end
                if equipData.is_enchant == true then--装备的八种新属性
                    local atts = equipData.atts or {}
                    for k,v in pairs(atts) do
                        if attrValueTab[k] then
                            attrValueTab[k] = attrValueTab[k] + v;
                        end
                    end
                end
            end
        end
    end
    --宝石扩展属性
    local gemCfg = getConfig(game_config_field.gem);
    local gemPosItemData = posGemData or {}
    for k,v in pairs(gemPosItemData) do
        local itemCfg = gemCfg:getNodeWithKey(tostring(v))
        if itemCfg then
            local ability = itemCfg:getNodeWithKey("ability"):toInt();
            local value = itemCfg:getNodeWithKey("value"):toInt();
            local tempItemData = PUBLIC_ABILITY_TABLE["ability_" .. ability];
            if ability > 6 and tempItemData then
                attrValueTab[tempItemData.attrName] = attrValueTab[tempItemData.attrName] + value
            end
            local ability2 = itemCfg:getNodeWithKey("ability2")
            if ability2 then
                ability2 = ability2:toInt();
                local value2 = itemCfg:getNodeWithKey("value2"):toInt();
                local tempItemData = PUBLIC_ABILITY_TABLE["ability_" .. ability2];
                if ability2 > 6 and tempItemData then
                    attrValueTab[tempItemData.attrName] = attrValueTab[tempItemData.attrName] + value2
                end
            end
        end
    end
    --统帅能力扩展属性
    local commander_attrs = commanderData or {}
    local commander_type_cfg = getConfig(game_config_field.commander_type);
    for k,v in pairs(COMBAT_ABILITY_TABLE.commander_attr_ext) do
        local commander_attrs_item = commander_attrs[k]
        if commander_attrs_item then
            local tempItemCfg = commander_type_cfg:getNodeWithKey(tostring(commander_attrs_item.lv))
            local tempValue = tempItemCfg:getNodeWithKey("add_" .. v)
            if tempValue then
                attrValueTab[v] = attrValueTab[v] + tempValue:toInt();
            end
        end
    end
    --卡牌扩展属性
    cardData = cardData or {}
    for k,v in pairs(attrValueTab) do
        if attrValueTabExt[k] then
            attrValueTab[k] = attrValueTab[k] + attrValueTabExt[k];
        end
        if cardData[k] then
            attrValueTab[k] = attrValueTab[k] + cardData[k];
        end
    end
    return attrValueTab
end

--[[
    统帅能力属性加成
]]
function M.getCommanderCombatValue(self)
    local attrValueTab = {0,0,0,0,0}
    local commander_type_cfg = getConfig(game_config_field.commander_type);
    local commander_attrs = game_data:getCommanderAttrsData();
    for k,v in pairs(COMMANDER_ABILITY_TABLE) do
        local commander_attrs_item = commander_attrs[v.attrName]
        if commander_attrs_item then
            local tempItemCfg = commander_type_cfg:getNodeWithKey(tostring(commander_attrs_item.lv))
            if tempItemCfg and attrValueTab[v.typeValue] then
                local tempValue = tempItemCfg:getNodeWithKey("add_" .. v.attrName)
                if tempValue then
                    attrValueTab[v.typeValue] = attrValueTab[v.typeValue] + tempValue:toInt();
                else
                    cclog("v.attrName not found cfg ===== " .. tostring(v.attrName))
                end
            end
        end
    end
    cclog("json.encode(attrValueTab) ======== " .. json.encode(attrValueTab))
    return attrValueTab
end

--[[
    宝石能力属性加成
]]
function M.getGemCombatValue(self, posIndex)
    local attrValueTab = {0,0,0,0,0}
    local combatValue = 0;
    local gemCfg = getConfig(game_config_field.gem);
    local gemPosData = game_data:getGemPosData() or {};
    local gemPosItemData = gemPosData[tostring(posIndex-1)] or {}
    for k,v in pairs(gemPosItemData) do
        local itemCfg = gemCfg:getNodeWithKey(tostring(v))
        if itemCfg then
            local ability = itemCfg:getNodeWithKey("ability"):toInt();
            local value = itemCfg:getNodeWithKey("value"):toInt();
            if ability > 0 and ability < 6 then
                attrValueTab[ability] = attrValueTab[ability] + value
            else
                combatValue = combatValue + value;
            end
            local ability2 = itemCfg:getNodeWithKey("ability2")
            if ability2 then
                ability2 = ability2:toInt();
                local value2 = itemCfg:getNodeWithKey("value2"):toInt();
                if ability2 > 0 and ability2 < 6 then
                    attrValueTab[ability2] = attrValueTab[ability2] + value2
                else
                    combatValue = combatValue + value2;
                end
            end
        end
    end
    local commander_attrs = game_data:getCommanderAttrsData();
    local commander_type_cfg = getConfig(game_config_field.commander_type);
    for k,v in pairs(COMBAT_ABILITY_TABLE.gem) do
        local commander_attrs_item = commander_attrs[v]
        if commander_attrs_item then
            local tempItemCfg = commander_type_cfg:getNodeWithKey(tostring(commander_attrs_item.lv))
            local tempValue = tempItemCfg:getNodeWithKey("add_" .. v)
            if tempValue then
                combatValue = combatValue + tempValue:toInt();
            end
        end
    end
    return combatValue,attrValueTab;
end

--[[
    助威单个卡牌的属性加成
]]
function M.getAssistantCardAttrValue(self, heroData, heroCfg, att_type, cardlimit)
    local temp_value = 0
    att_type = att_type or 0
    cardlimit = cardlimit or 0
    local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. att_type]
    if heroData and heroCfg and abilityItem then
        local break_control_cfg = getConfig(game_config_field.break_control)
        local character_strengthen = getConfig(game_config_field.character_strengthen)
        local cbmTab = self:getCombatBonusMultiplierByCfg(heroCfg,heroData.id)
        local attrName = tostring(abilityItem.attrName)
        local evo = heroData.evo or 0--进阶
        temp_value = heroData[attrName] or 0
        if att_type < 6 and evo > cardlimit then--需要重新计算
            local attr_base_value = heroCfg:getNodeWithKey("base_" .. attrName):toInt()
            local attr_growth_value = heroCfg:getNodeWithKey("growth_" .. attrName):toInt()
            local race = heroCfg:getNodeWithKey("race"):toInt()
            local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg)
            local tempItemCfg1 = evolutionCfg:getNodeWithKey(tostring(cardlimit))
            local evo_attr_value = 0
            local all_value = 0
            if tempItemCfg1 then
                all_value = tempItemCfg1:getNodeWithKey("all"):toFloat()
                local attrType1 = tempItemCfg1:getNodeWithKey("type" .. race)
                evo_attr_value = attrType1:getNodeAt(att_type-1):toInt()
            end
            local hp_add = 0
            if att_type == 5 then
                local bre = heroData.bre or 0--转生  只和基本血量有关  hp_add
                local break_control_cfg_item = break_control_cfg:getNodeWithKey(tostring(bre))
                if break_control_cfg_item then
                    hp_add = break_control_cfg_item:getNodeWithKey("hp_add"):toFloat()
                end
            end
            attr_base_value = (attr_base_value + evo_attr_value)*(1+all_value+hp_add)
            -- attr_base_value = (attr_base_value + evo_attr_value)*(1+all_value)*(1+hp_add)
            -- attr_growth_value = attr_growth_value*(1+all_value)*(1+hp_add)
            local crystal_value = 0;
            local item_cfg = character_strengthen:getNodeWithKey(tostring(heroData[attrName .. "_crystal"] or 0));
            if item_cfg then
                crystal_value = item_cfg:getNodeWithKey("add_" .. attrName)
                crystal_value = crystal_value and crystal_value:toInt() or 0
            end
            temp_value = (attr_base_value + attr_growth_value*((heroData.lv or 1) - 1)) + crystal_value
        end
        temp_value = temp_value*(1+cbmTab[att_type])
    end
    return temp_value
end

--[[
    助威属性加成
]]
function M.getAssistantCombatValue(self)
    local attrValueTab = {0,0,0,0,0}
    local friendData = game_data:getAssistant()
    local assistantEffect = game_data:getAssistantEffect()
    local equipPosData = game_data:getAssEquipPosData()
    local assistant_cfg = getConfig(game_config_field.assistant)
    for k,v in pairs(friendData) do
        local assistantEffectItem = assistantEffect[k] or {}
        local active_status = assistantEffectItem.active_status or "-1" -- "-1"未激活 "0" 激活
        local assistant_cfg_item = assistant_cfg:getNodeWithKey(tostring(k))
        if active_status ~= "-1" and assistant_cfg_item then
            local att_type = assistant_cfg_item:getNodeWithKey("att_type")
            att_type = att_type and att_type:toInt() or 0--加成的属性
            local cardlimit = assistant_cfg_item:getNodeWithKey("cardlimit")--进阶的限制
            cardlimit = cardlimit and cardlimit:toInt() or 0
            if attrValueTab[att_type] then
                -- local att_value = assistant_cfg_item:getNodeWithKey("att_value")
                -- att_value = att_value and att_value:toInt() or 0
                local heroData,heroCfg = game_data:getCardDataById(tostring(v))--heroData 属性值包括进阶 转生 属性改造
                if heroData then
                    local equipAttrValueTab = {0,0,0,0,0}
                    --计算助威装备属性值
                    local suitTab = {}
                    local equipPosItemData = equipPosData[tostring(k+99)] or {}
                    for k,v in pairs(equipPosItemData) do
                        v = tostring(v)
                        if v ~= "0" then
                            local equipData,equipCfg = game_data:getEquipDataById(v);
                            if equipData and equipCfg then
                                local value1 = equipCfg:getNodeWithKey("value1"):toInt();
                                local value2 = equipCfg:getNodeWithKey("value2"):toInt();
                                local lv = math.max(0,equipData.lv-1)
                                value1 = value1 + equipCfg:getNodeWithKey("level_add1"):toInt()*lv
                                value2 = value2 + equipCfg:getNodeWithKey("level_add2"):toInt()*lv
                                local ability1,ability2 = equipCfg:getNodeWithKey("ability1"):toInt(),equipCfg:getNodeWithKey("ability2"):toInt();
                                if equipAttrValueTab[ability1] then
                                    equipAttrValueTab[ability1] = equipAttrValueTab[ability1] + value1
                                end
                                if equipAttrValueTab[ability2] then
                                    equipAttrValueTab[ability2] = equipAttrValueTab[ability2] + value2;
                                end
                                local suit = equipCfg:getNodeWithKey("suit"):toInt();
                                if suitTab[suit] == nil then
                                    suitTab[suit] = 0;
                                    local suitCount,_,tempAttrValueTab = self:getEquipSuit(suit,equipPosItemData);
                                    if suitCount > 0 then
                                        for i=1,5 do
                                            equipAttrValueTab[i] = equipAttrValueTab[i] + tempAttrValueTab[i]
                                        end
                                    end
                                end
                            end
                        end
                    end
                    --计算伙伴本身属性
                    local tempAssistantCardAttrValueTab = {}
                    local assAttrValueTab,_,_ = self:getAssistantAttrTab(k, assistantEffectItem, assistant_cfg_item, false)
                    for i=1,#assAttrValueTab do
                        local attrValueItem = assAttrValueTab[i]
                        local temp_att_type = attrValueItem.att_type or 0
                        local abilityItem = PUBLIC_ABILITY_TABLE["ability_" .. temp_att_type]
                        local active = attrValueItem.active or 1--没值为激活
                        if abilityItem and attrValueItem.open > 0 and active > 0 then
                            local temp_value,temp_att_value = tempAssistantCardAttrValueTab[att_type],attrValueItem.att_value or 0
                            if temp_value == nil then
                                temp_value = self:getAssistantCardAttrValue(heroData, heroCfg, att_type, cardlimit)
                                tempAssistantCardAttrValueTab[att_type] = temp_value
                            end
                            attrValueTab[att_type] = attrValueTab[att_type] + (temp_value+equipAttrValueTab[att_type])*temp_att_value*0.01
                        end
                    end
                end
            end
        end
    end
    return attrValueTab
end

--[[--
计算总战斗力
]]
function M.getCombatValue(self)
    local combat_base_cfg = getConfig(game_config_field.combat_base)
    local combat_skill_cfg = getConfig(game_config_field.combat_skill)
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);

    local combat = 0;
    local teamTable = game_data:getTeamData() or {};
    local cardData,heroCfg;
    local hp,patk,matk,def,speed;
    local attrValueTab = {0,0,0,0,0}
    local skill_detail_cfg_item,combat_skill_cfg_item;
    local skillItem,skill_quality,total_factor;

    local attrValueTab2 = self:getCommanderCombatValue();
    local attrValueTab3 = self:getAssistantCombatValue();
    local equipPosData = game_data:getEquipPosData() or {};
    local equipPosItemData;
    local equipData,equipCfg;
    local value1,value2;
    local ability1,ability2;
    for k,v in pairs(teamTable) do
        cardData,heroCfg = game_data:getCardDataById(tostring(v));
        if cardData and heroCfg then
            total_factor = 1;
            for i=1,3 do
                skillItem = cardData["s_" .. i]
                if skillItem and skillItem.s ~= 0 and skillItem.avail == 2 then
                    skill_detail_cfg_item = skill_detail_cfg:getNodeWithKey(tostring(skillItem.s));
                    if skill_detail_cfg_item and skillItem.lv > 0 then
                        combat_skill_cfg_item = combat_skill_cfg:getNodeWithKey(tostring(skillItem.lv))
                        skill_quality = skill_detail_cfg_item:getNodeWithKey("skill_quality"):toInt();
                        if combat_skill_cfg_item and skill_quality > -1 and skill_quality <= 7 then
                            total_factor = total_factor + combat_skill_cfg_item:getNodeWithKey(tostring(skill_quality)):toFloat();
                        end
                    end
                end
            end
            -- hp,patk,matk,def,speed = cardData.hp,cardData.patk,cardData.matk,cardData.def,cardData.speed
            local cbmTab = self:getCombatBonusMultiplierByCfg(heroCfg,v);
            attrValueTab = {cardData.patk*(1 + cbmTab[1]),cardData.matk*(1 + cbmTab[2]),cardData.def*(1 + cbmTab[3]),cardData.speed*(1 + cbmTab[4]),cardData.hp*(1 + cbmTab[5])};-- 1物攻 2魔攻 3防御 4速度 5生命
            value1,value2 = 0,0;
            ability1,ability2 = 0,0;
            local gemCombatValue,gemAttrValueTab = self:getGemCombatValue(k);--宝石的八种新属性和基本属性
            local suitTab = {};
            equipPosItemData = equipPosData[tostring(k-1)]
            if equipPosItemData then
                for k,v in pairs(equipPosItemData) do
                    v = tostring(v)
                    if v ~= "0" then
                        equipData,equipCfg = game_data:getEquipDataById(v);
                        if equipData and equipCfg then
                            value1 = equipCfg:getNodeWithKey("value1"):toInt();
                            value2 = equipCfg:getNodeWithKey("value2"):toInt();
                            local lv = math.max(0,equipData.lv-1)
                            value1 = value1 + equipCfg:getNodeWithKey("level_add1"):toInt()*lv
                            value2 = value2 + equipCfg:getNodeWithKey("level_add2"):toInt()*lv
                            ability1,ability2 = equipCfg:getNodeWithKey("ability1"):toInt(),equipCfg:getNodeWithKey("ability2"):toInt();
                            -- cclog("total_factor =====================" .. total_factor .. " ; ability1 = " .. ability1 .. " ; value1 = " .. value1 .. " ; ability2 = " .. ability2 .. " ;value2 = " .. value2)
                            if attrValueTab[ability1] then
                                attrValueTab[ability1] = attrValueTab[ability1] + value1
                            end
                            if attrValueTab[ability2] then
                                attrValueTab[ability2] = attrValueTab[ability2] + value2;
                            end
                            local suit = equipCfg:getNodeWithKey("suit"):toInt();
                            if suitTab[suit] == nil then
                                suitTab[suit] = 0;
                                local suitCount,_,tempAttrValueTab = self:getEquipSuit(suit,equipPosItemData);
                                if suitCount > 0 then
                                    for i=1,5 do
                                        attrValueTab[i] = attrValueTab[i] + tempAttrValueTab[i]
                                    end
                                end
                                gemCombatValue = gemCombatValue + tempAttrValueTab[6]--套装的八种新属性
                            end
                            if equipData.is_enchant == true then--装备的八种新属性
                                local atts = equipData.atts or {}
                                for k,v in pairs(atts) do
                                    gemCombatValue = gemCombatValue + v;
                                end
                            end
                        end
                    end
                end
            end
            hp = (attrValueTab[5] + attrValueTab2[5] + attrValueTab3[5] + gemAttrValueTab[5]) * combat_base_cfg:getNodeWithKey("hp"):toFloat();
            patk = (attrValueTab[1] + attrValueTab2[1] + attrValueTab3[1] + gemAttrValueTab[1]) * combat_base_cfg:getNodeWithKey("patk"):toFloat();
            matk = (attrValueTab[2] + attrValueTab2[2] + attrValueTab3[2] + gemAttrValueTab[2]) * combat_base_cfg:getNodeWithKey("matk"):toFloat();
            def = (attrValueTab[3] + attrValueTab2[3] + attrValueTab3[3] + gemAttrValueTab[3]) * combat_base_cfg:getNodeWithKey("def"):toFloat();
            speed = (attrValueTab[4] + attrValueTab2[4] + attrValueTab3[4] + gemAttrValueTab[4]) * combat_base_cfg:getNodeWithKey("speed"):toFloat();
            combat = combat + (hp + patk + matk + def + speed)*total_factor + gemCombatValue;
            for k,v in pairs(COMBAT_ABILITY_TABLE.card) do--卡牌的八种新属性
                combat = combat + (cardData[v] or 0)
            end
        end
    end
    cclog("combat =====================" .. combat)
    return math.floor(combat);
end

function M.createSortNode(self,swfname,id,plistname)
    local node = SortNode:create(swfname,id,plistname)
    if(node == nil) then
        -- game_util:addMoveTips({text = "缺少动画"..swfname})
    else
        node:setRhythm(public_config.action_rythm);
    end
    return node
end

function M.testShowSortInfo(self,tempid,tempdid,spc,str)
    --[[--cclog("info->"..str)
    cclog("tempid->"..tempid)
    cclog("--tempdid--")
    if type(tempdid) == "number" then
        cclog(tempdid)
    elseif type(tempdid) == "table" then
        for i = 1,#tempdid do
            cclog("number->"..tempdid[i])
        end
    end
    if(spc ~= nil) then
        cclog("spc->"..spc)
    else
        cclog("spcnil")
    end
    cclog("-----------")]]--
end
--[[
    改变sprite的纹理
]]
function M.changeSpriteTexture(self,sprite,textureName,mode)
    if sprite == nil then return end
    mode = mode or 1;
    if mode == 1 then
        local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(textureName)
        if tempFrame then
            sprite:setDisplayFrame(tempFrame);
        end
    else
        local tempSprite = CCSprite:create(textureName);
        sprite:setDisplayFrame(tempSprite:displayFrame());
    end
end

--[[--
    获取装备套装
]]
function M.getEquipSuit(self,suitValue,posEquipData, equipData)
    local suitCount = 0;
    local tempEquipData = {};
    local attrValueTab = {0,0,0,0,0,0};
    local attrValueTabExt = {fire = 0,water = 0,wind = 0,earth = 0,fire_dfs = 0,water_dfs = 0,wind_dfs = 0,earth_dfs = 0}
    posEquipData = posEquipData or {"0","0","0","0"};
    local equipCfg = getConfig(game_config_field.equip);
    local suitCfg = getConfig(game_config_field.suit);
    local suitItemCfg = suitCfg:getNodeWithKey(tostring(suitValue));
    if suitItemCfg then
        local part = suitItemCfg:getNodeWithKey("part")
        local partCount = part:getNodeCount();
        if partCount == 4 then
            for i=1,4 do
                local tempEquipCfg = equipCfg:getNodeWithKey(tostring(part:getNodeAt(i-1):toStr()))
                tempEquipData[i] = {itemCfg = tempEquipCfg,itemData = nil}
                if tempEquipCfg then
                    local tempEquipId = tempEquipCfg:getNodeWithKey("equip_id"):toInt();
                    local tempSort = tempEquipCfg:getNodeWithKey("sort"):toInt();
                    local tempId = tostring(posEquipData[tempSort])
                    if tempId and tempId ~= "0" then
                        local equipItemData,equipItemCfg = nil, nil
                        if not equipData then
                            equipItemData,equipItemCfg = game_data:getEquipDataById(tempId);
                        else
                            equipItemData,equipItemCfg = game_data:getEquipDataByIdFromPool(tempId, equipData);
                        end
                        if equipItemCfg:getNodeWithKey("equip_id"):toInt() == tempEquipId then
                            suitCount = suitCount + 1;
                            tempEquipData[i] = {itemData = equipItemData,itemCfg = equipItemCfg}
                        end
                    end
                end
            end
        end
        local effectItem = nil;
        for i=2,4 do
            effectItem = suitItemCfg:getNodeWithKey("effect_" .. i)
            local tempCount = effectItem:getNodeCount();
            local len = (i == 4 and 4 or 2);
            for j=1,len do
                if j <= tempCount then
                    local tempItem = effectItem:getNodeAt(j-1);
                    local attType = tempItem:getNodeAt(0):toInt();
                    local attValue = tempItem:getNodeAt(1):toInt();
                    -- cclog("attType ========== " .. attType .. " ; attValue =========== " .. attValue)
                    if i <= suitCount then
                        if attType > 5 then
                            attrValueTab[6] = attrValueTab[6] + attValue;
                            local tempItemData = PUBLIC_ABILITY_TABLE["ability_" .. attType];
                            if tempItemData then
                                attrValueTabExt[tempItemData.attrName] = attrValueTabExt[tempItemData.attrName] + attValue
                            end
                        else
                            attrValueTab[attType] = attrValueTab[attType] + attValue;
                        end
                    end
                end
            end
        end
    end
    cclog("suitCount ================== " .. suitCount)
    -- table.foreach(attrValueTab,print)
    -- cclog("getEquipSuit json.encode(attrValueTab) ======== " .. json.encode(attrValueTab))
    return suitCount,tempEquipData,attrValueTab,attrValueTabExt;
end

--[[--
    联协
]]
function M.getCardAndEquipChainTab(self,cardId)
    local teamTable = game_data:getTeamData() or {};
    local teamCharacterIdTab = {};
    local posIndex = -1;
    local chainTeamType = 1;
    for k,v in pairs(teamTable) do
        local _,heroCfg = game_data:getCardDataById(tostring(v));
        if heroCfg then
            teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
        end
        if v == cardId then
            posIndex = k;
        end
    end
    local friendData = game_data:getAssistant() or {};
    for k,v in pairs(friendData) do
        local _,heroCfg = game_data:getCardDataById(tostring(v));
        if heroCfg then
            teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
        end
        if v == cardId then
            posIndex = k;
            chainTeamType = 2;
        end
    end
    local destinyData = game_data:getDestiny() or {};--命运小伙伴
    for k,v in pairs(destinyData) do
        local _,heroCfg = game_data:getCardDataById(tostring(v));
        if heroCfg then
            teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
        end
    end
    if posIndex == -1 then
        teamCharacterIdTab = {};
    end
    local teamEquipIdTab = {};
    if chainTeamType == 1 then
        local equipPosData = game_data:getEquipPosData() or {};
        local tempPosEquip = equipPosData[tostring(posIndex-1)] or {};
        for k,v in pairs(tempPosEquip) do
            local _,equipCfg = game_data:getEquipDataById(v);
            if equipCfg then
                local chain_id = equipCfg:getNodeWithKey("chain_id")
                chain_id = chain_id and chain_id:toInt() or equipCfg:getNodeWithKey("equip_id"):toInt()
                teamEquipIdTab[chain_id] = k;
            end
        end
    else
        local equipPosData = game_data:getAssEquipPosData()
        local tempPosEquip = equipPosData[tostring(posIndex+99)] or {};
        for k,v in pairs(tempPosEquip) do
            local _,equipCfg = game_data:getEquipDataById(v);
            if equipCfg then
                local chain_id = equipCfg:getNodeWithKey("chain_id")
                chain_id = chain_id and chain_id:toInt() or equipCfg:getNodeWithKey("equip_id"):toInt()
                teamEquipIdTab[chain_id] = k;
            end
        end  
    end
    return teamCharacterIdTab,teamEquipIdTab;
end

--[[--
    联协
]]
function M.getPlayerCardAndEquipChainTab(self,cardId, playerData)
    local teamTable = playerData:getTeamData() or {};
    local equipPosData = playerData:getEquipPosData() or {};
    local teamCharacterIdTab = {};
    local posIndex = -1;
    for k,v in pairs(teamTable) do
        local _,heroCfg = playerData:getCardDataById(tostring(v));
        if heroCfg then
            teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
        end
        if v == cardId then
            posIndex = k;
        end
    end
    local friendData = playerData:getAssistant() or {};
    for k,v in pairs(friendData) do
        if v ~= "-1" and v ~= "0" then
            local _,heroCfg = playerData:getCardDataById(tostring(v));
            if heroCfg then
                teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
            end
        end
    end
    if posIndex == -1 then
        teamCharacterIdTab = {};
    end
    local teamEquipIdTab = {};
    local tempPosEquip = equipPosData[tostring(posIndex-1)] or {};
    for k,v in pairs(tempPosEquip) do
        local _,equipCfg = playerData:getEquipDataById(v);
        if equipCfg then
            local chain_id = equipCfg:getNodeWithKey("chain_id")
            chain_id = chain_id and chain_id:toInt() or equipCfg:getNodeWithKey("equip_id"):toInt()
            teamEquipIdTab[chain_id] = k;
        end
    end
    return teamCharacterIdTab,teamEquipIdTab;
end

--[[--
    联协
]]
function M.cardChainByCfg(self,heroCfg,cardId, playerData)
    local chainTab, openChainCount = {},0;
    if heroCfg == nil then return chainTab end
    local chain = heroCfg:getNodeWithKey("chain")
    local chainCount = chain:getNodeCount();
    -- cclog("chainCount ======================= " .. chainCount)
    local teamCharacterIdTab, teamEquipIdTab = nil, nil
    if chainCount > 0 then
        if playerData then
            teamCharacterIdTab, teamEquipIdTab = self:getPlayerCardAndEquipChainTab(cardId, playerData);
        else
            teamCharacterIdTab, teamEquipIdTab = self:getCardAndEquipChainTab(cardId);
        end

        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local chain_cfg = getConfig(game_config_field.chain);
        local equip_cfg = getConfig(game_config_field.equip);
        for i=1,chainCount do
            local chainId = chain:getNodeAt(i-1):toStr();
            local chainItemCfg = chain_cfg:getNodeWithKey(chainId);
            if chainItemCfg then
                local name = chainItemCfg:getNodeWithKey("name"):toStr();
                local des = chainItemCfg:getNodeWithKey("des"):toStr();
                local effect = chainItemCfg:getNodeWithKey("effect")
                local data = chainItemCfg:getNodeWithKey("data")
                local dataCount = data:getNodeCount();
                local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
                if dataCount > 0 then
                    local tempCount = 0;
                    if condition_sort == 0 then--卡牌联协
                        for i=1,dataCount do
                            local itemCfg = character_detail_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                if teamCharacterIdTab[itemCfg:getNodeWithKey("character_ID"):toInt()] then
                                    des = string.gsub(des,"card" .. i,"[color=ffffdc00]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                    tempCount = tempCount + 1;
                                else
                                    des = string.gsub(des,"card" .. i,"[color=ff8A8A8A]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                end
                            end
                        end
                        if tempCount >= dataCount then--联协开启
                            openChainCount = openChainCount + 1;
                            chainTab[#chainTab + 1] = {name = "[color=ffffdc00]" .. name .. "[/color]",detail = "[color=ffffdc00]" .. name .. "[/color] : " .. des,openFlag = true,count = dataCount ,t = "c" , chain = chainId , nameExt = name}
                        else
                            chainTab[#chainTab + 1] = {name = "[color=ff8A8A8A]" .. name .. "[/color]",detail = "[color=ff8A8A8A]" .. name .. "[/color] : " .. des,openFlag = false,count = tempCount ,t = "c" , chain = chainId , nameExt = name}
                        end
                    elseif condition_sort == 1 then--装备联协
                        for i=1,dataCount do
                            local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                -- cclog("itemCfg:getNodeWithKey(\"equip_id\"):toInt() == " .. itemCfg:getNodeWithKey("equip_id"):toInt())
                                local sort = itemCfg:getNodeWithKey("sort"):toInt();
                                local chain_id = itemCfg:getNodeWithKey("chain_id")
                                chain_id = chain_id and chain_id:toInt() or itemCfg:getNodeWithKey("equip_id"):toInt()
                                if teamEquipIdTab[chain_id] or teamEquipIdTab[sort] then
                                    des = string.gsub(des,"equip" .. i,"[color=ffC636F8]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                    tempCount = tempCount + 1;
                                else
                                    des = string.gsub(des,"equip" .. i,"[color=ff8A8A8A]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                end
                            end
                        end
                        if tempCount >= dataCount then--联协开启
                            openChainCount = openChainCount + 1;
                            chainTab[#chainTab + 1] = {name = "[color=ffC636F8]" .. name .. "[/color]",detail = "[color=ffC636F8]" .. name .. "[/color] : " .. des,openFlag = true, count = dataCount , t = "e" , chain = chainId , nameExt = name}
                        else
                            chainTab[#chainTab + 1] = {name = "[color=ff8A8A8A]" .. name .. "[/color]",detail = "[color=ff8A8A8A]" .. name .. "[/color] : " .. des,openFlag = false, count = tempCount , t = "e" , chain = chainId , nameExt = name}
                        end
                    end
                else
                    chainTab[#chainTab + 1] = {name = name,detail = name .. " : "}
                end
            end
        end
    end
    return chainTab,chainCount,openChainCount
end

--[[--
    获取装备联协
]]
function M.cardEquipChainByCfg(self,heroCfg,cardId, playerData)
    local chainTab = {};
    if heroCfg == nil then return chainTab end
    local chain = heroCfg:getNodeWithKey("chain")
    local chainCount = chain:getNodeCount();
    cclog("chainCount ======================= " .. chainCount)
    local chainEquipDataTab = {}
    if chainCount > 0 then
        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local chain_cfg = getConfig(game_config_field.chain);
        local equip_cfg = getConfig(game_config_field.equip);
        for i=1,chainCount do
            local chainId = chain:getNodeAt(i-1):toStr();
            local chainItemCfg = chain_cfg:getNodeWithKey(chainId);
            if chainItemCfg then
                local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
                local data = chainItemCfg:getNodeWithKey("data")
                local dataCount = data:getNodeCount();
                    if condition_sort == 1 then--装备联协
                        for i=1,dataCount do
                            local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            -- cclog2(itemCfg , "equip chain  itemCfg =======  ")
                            if itemCfg then
                                chainEquipDataTab[#chainEquipDataTab+1] = json.decode(itemCfg:getFormatBuffer())
                            end
                        end
                    end
                end
            end
        end
    return chainEquipDataTab
end

--[[
    -- 检查此装备是否是这张卡牌的连协
    -- equipCfg 装备信息cfg
    -- chainEquipTab 连协装备表
]]
function M.isCardChainEquip( self, equipCfg, chainEquipTab )
    if not equipCfg or not chainEquipTab then return false end  -- 传的数据不对
    for i,v in ipairs(chainEquipTab) do
        if v.equip_id == (equipCfg:getNodeWithKey("equip_id") and equipCfg:getNodeWithKey("equip_id"):toInt() or -1) then
            return true
        end
    end
    return false
end

--[[--
    敌方联协
]]
function M.dfdCardChainByCfg(self,heroCfg,cardId,dfdAll,dfdFriend )
    local chainTab = {};
    if heroCfg == nil then return chainTab end
    local chain = heroCfg:getNodeWithKey("chain")
    local chainCount = chain:getNodeCount();
    cclog("chainCount ======================= " .. chainCount)
    if chainCount > 0 then
        -- cclog(json.encode(dfdAll));
        local teamTable = dfdAll or {};
        local equipPosData = {};
        local teamCharacterIdTab = {};
        local posIndex = 1;
        local character_detail_cfg = getConfig(game_config_field.character_detail);

        for k,v in pairs(teamTable) do
            -- cclog("  ----------- card_id : " .. tostring(v.card_id));
            local heroCfg = character_detail_cfg:getNodeWithKey(tostring(v.card_id));

            -- local _,heroCfg = game_data:getCardDataById(tostring(cId));
            if heroCfg then
                teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
            else
                -- cclog("----------- v.card_id " .. tostring(v.card_id));
            end
            if v.card_id == cardId then
                posIndex = k;
            end
        end


        local friendData = dfdFriend or {};
        for k,v in pairs(friendData) do
            if v ~= "-1" and v ~= "0" then
                local valueTab = util.stringSplit(tostring(v),"-");
                local heroCfg = character_detail_cfg:getNodeWithKey(tostring(valueTab[1]));
                if heroCfg then
                    teamCharacterIdTab[heroCfg:getNodeWithKey("character_ID"):toInt()] = k;
                end
            end
        end

        if posIndex == -1 then
            teamCharacterIdTab = {};
        end
        local teamEquipIdTab = {};
        local tempPosEquip = equipPosData[tostring(posIndex-1)] or {};
        for k,v in pairs(tempPosEquip) do
            local _,equipCfg = game_data:getEquipDataById(v);
            if equipCfg then
                teamEquipIdTab[equipCfg:getNodeWithKey("equip_id"):toInt()] = k;
            end
        end

        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local chain_cfg = getConfig(game_config_field.chain);
        local equip_cfg = getConfig(game_config_field.equip);
        for i=1,chainCount do
            local chainId = chain:getNodeAt(i-1):toStr();
            local chainItemCfg = chain_cfg:getNodeWithKey(chainId);
            if chainItemCfg then
                local name = chainItemCfg:getNodeWithKey("name"):toStr();
                local des = chainItemCfg:getNodeWithKey("des"):toStr();
                local effect = chainItemCfg:getNodeWithKey("effect")
                local data = chainItemCfg:getNodeWithKey("data")
                local dataCount = data:getNodeCount();
                local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
                if dataCount > 0 then
                    local tempCount = 0;
                    if condition_sort == 0 then--卡牌联协
                        for i=1,dataCount do
                            local itemCfg = character_detail_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                if teamCharacterIdTab[itemCfg:getNodeWithKey("character_ID"):toInt()] then
                                    des = string.gsub(des,"card" .. i,"[color=ffffdc00]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                    tempCount = tempCount + 1;
                                else
                                    des = string.gsub(des,"card" .. i,"[color=ff8A8A8A]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                end
                            end
                        end
                        if tempCount >= dataCount then--联协开启
                            chainTab[#chainTab + 1] = {name = "[color=ffffdc00]" .. name .. "[/color]",detail = "[color=ffffdc00]" .. name .. "[/color] : " .. des,openFlag = true,count = dataCount ,t = "c" , chain = chainId , nameExt = name}
                        else
                            -- cclog("-------------- tempCount : " .. tostring(tempCount) .. "  dataCount : " .. tostring(dataCount) .. " name:" .. name);
                            chainTab[#chainTab + 1] = {name = "[color=ff8A8A8A]" .. name .. "[/color]",detail = "[color=ff8A8A8A]" .. name .. "[/color] : " .. des,openFlag = false,count = tempCount ,t = "c" , chain = chainId , nameExt = name}
                        end
                    elseif condition_sort == 1 then--装备联协
                        for i=1,dataCount do
                            local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                -- cclog("itemCfg:getNodeWithKey(\"equip_id\"):toInt() == " .. itemCfg:getNodeWithKey("equip_id"):toInt())
                                local sort = itemCfg:getNodeWithKey("sort"):toInt();
                                local chain_id = itemCfg:getNodeWithKey("chain_id")
                                chain_id = chain_id and chain_id:toInt() or itemCfg:getNodeWithKey("equip_id"):toInt()
                                if teamEquipIdTab[chain_id] or teamEquipIdTab[sort] then
                                    des = string.gsub(des,"equip" .. i,"[color=ffC636F8]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                    tempCount = tempCount + 1;
                                else
                                    des = string.gsub(des,"equip" .. i,"[color=ff8A8A8A]" .. itemCfg:getNodeWithKey("name"):toStr() .. "[/color]");
                                end
                            end
                        end
                        if tempCount >= dataCount then--联协开启
                            chainTab[#chainTab + 1] = {name = "[color=ffC636F8]" .. name .. "[/color]",detail = "[color=ffC636F8]" .. name .. "[/color] : " .. des,openFlag = true, count = dataCount , t = "e" , chain = chainId , nameExt = name}
                        else
                            chainTab[#chainTab + 1] = {name = "[color=ff8A8A8A]" .. name .. "[/color]",detail = "[color=ff8A8A8A]" .. name .. "[/color] : " .. des,openFlag = false, count = tempCount , t = "e" , chain = chainId , nameExt = name}
                        end
                    end
                else
                    chainTab[#chainTab + 1] = {name = name,detail = name .. " : "}
                end
            end
        end
    end
    return chainTab
end

--[[--
    联协属性加成
]]
function M.getChainCombat(self)

end


--[[--
    联协属性加成倍数
]]
function M.getCombatBonusMultiplierByCfg(self,heroCfg,cardId)
    local attrValueTab = {0,0,0,0,0};
    if heroCfg == nil then return attrValueTab end
    local chain = heroCfg:getNodeWithKey("chain")
    local chainCount = chain:getNodeCount();
    cclog("chainCount ======================= " .. chainCount)
    if chainCount > 0 then
        local teamCharacterIdTab, teamEquipIdTab = self:getCardAndEquipChainTab(cardId);

        local character_detail_cfg = getConfig(game_config_field.character_detail);
        local chain_cfg = getConfig(game_config_field.chain);
        local equip_cfg = getConfig(game_config_field.equip);
        for i=1,chainCount do
            local chainItemCfg = chain_cfg:getNodeWithKey(chain:getNodeAt(i-1):toStr());
            if chainItemCfg then
                local name = chainItemCfg:getNodeWithKey("name"):toStr();
                local data = chainItemCfg:getNodeWithKey("data")
                local dataCount = data:getNodeCount();
                local condition_sort = chainItemCfg:getNodeWithKey("condition_sort"):toInt();
                if dataCount > 0 then
                    local tempCount = 0;
                    if condition_sort == 0 then--卡牌联协
                        for i=1,dataCount do
                            local itemCfg = character_detail_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                if teamCharacterIdTab[itemCfg:getNodeWithKey("character_ID"):toInt()] then
                                    tempCount = tempCount + 1;
                                end
                            end
                        end
                    elseif condition_sort == 1 then--装备联协
                        for i=1,dataCount do
                            local itemCfg = equip_cfg:getNodeWithKey(data:getNodeAt(i-1):toStr())
                            if itemCfg then
                                local sort = itemCfg:getNodeWithKey("sort"):toInt();
                                local chain_id = itemCfg:getNodeWithKey("chain_id")
                                chain_id = chain_id and chain_id:toInt() or itemCfg:getNodeWithKey("equip_id"):toInt()
                                if teamEquipIdTab[chain_id] or teamEquipIdTab[sort] then
                                    tempCount = tempCount + 1;
                                end
                            end
                        end
                    end
                    if tempCount >= dataCount then--激活
                        local effectTab = json.decode(chainItemCfg:getNodeWithKey("effect"):getFormatBuffer()) or {}
                        for k,v in pairs(effectTab) do
                            if #v == 2 then
                                attrValueTab[v[1] + 1] = attrValueTab[v[1] + 1]  + v[2]*0.001;
                            end
                        end
                    end
                end
            end
        end
    end
    cclog("getCombatBonusMultiplierByCfg json.encode(attrValueTab) ======== " .. json.encode(attrValueTab))
    return attrValueTab
end

--[[
    设置table view 的 index
    index 索引 table view 父节点 tag , 一页显示几个cell
]]
function M.setTableViewIndex(self,index,tableNode,tag,cellCount)
    if type(index) ~= "number" or type(cellCount) ~= "number" then return end
    if index < cellCount - 1 then
        return
    end
    local tempTable = tolua.cast(tableNode:getChildByTag(tag),"TableView")
    local contentSize = tempTable:getContentSize()
    local viewSize = tempTable:getViewSize()
    local size = tableNode:getContentSize()
    -- cclog("contentSize = " .. contentSize.height .. "size = " .. size.height)
    local cellHeight = size.height  / cellCount;--一个cell的高度


    if viewSize.height <= contentSize.height then--如果contentSize 大于 viewSize 则不需要设置偏移
        tempTable:setContentOffset(ccp(0, math.min(viewSize.height - contentSize.height + index * cellHeight, 0)))
    end
end

function M.removeFile(self,fileName)
    os.remove(fileName);
end

--[[
    脉冲动画
]]
function M.createPulseAnmi(self,frameName,parentNode)
    local scale_time = 0.4
    local wait_time = 0.7
    local action_sprite = CCSprite:createWithSpriteFrameName(frameName)
    local action_sprite_2 = CCSprite:createWithSpriteFrameName(frameName)

    local actionArr = CCArray:create()
    local actionArr2 = CCArray:create()

    local function newFunc(node)    
        action_sprite:setScale(1)
        action_sprite:setOpacity(255)
    end
    local function newFunc2(node)    
        action_sprite_2:setScale(1)
        action_sprite_2:setOpacity(255)
    end
    actionArr:addObject(CCDelayTime:create(scale_time))
    actionArr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(scale_time/2),CCScaleBy:create(scale_time/2,1.5)))
    actionArr:addObject(CCCallFuncN:create(newFunc))
    actionArr:addObject(CCDelayTime:create(wait_time))

    -- actionArr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(scale_time),CCScaleBy:create(scale_time,0.5)))
    local timeInterval = 0.15
    actionArr2:addObject(CCDelayTime:create(scale_time+timeInterval))
    actionArr2:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(scale_time/2),CCScaleBy:create(scale_time/2,1.5)))
    actionArr2:addObject(CCCallFuncN:create(newFunc2))
    actionArr2:addObject(CCDelayTime:create(wait_time-timeInterval))

    local animArr = CCArray:create();
    animArr:addObject(CCScaleBy:create(scale_time,1.2));
    animArr:addObject(CCScaleBy:create(scale_time/2,1/1.2))
    animArr:addObject(CCDelayTime:create(wait_time))

    action_sprite:setAnchorPoint(ccp(0.5,0.5))
    action_sprite:setPosition(ccp(action_sprite:getContentSize().width*0.5,action_sprite:getContentSize().height*0.5))
    parentNode:addChild(action_sprite,-1,10)

    action_sprite_2:setAnchorPoint(ccp(0.5,0.5))
    action_sprite_2:setPosition(ccp(action_sprite:getContentSize().width*0.5,action_sprite:getContentSize().height*0.5))
    parentNode:addChild(action_sprite_2,-2,11)

    parentNode:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    action_sprite:runAction(CCRepeatForever:create(CCSequence:create(actionArr)))
    action_sprite_2:runAction(CCRepeatForever:create(CCSequence:create(actionArr2)))
end


--[[
    脉冲动画
]]
function M.createPulseAnmi2(self,frameName,parentNode)
    local scale_time = 0.4
    local wait_time = 0.7
    local action_sprite = CCSprite:createWithSpriteFrameName(frameName)
    local action_sprite_2 = CCSprite:createWithSpriteFrameName(frameName)

    local actionArr = CCArray:create()
    local actionArr2 = CCArray:create()

    local function newFunc(node)    
        action_sprite:setScale(1)
        action_sprite:setOpacity(255)
    end
    local function newFunc2(node)    
        action_sprite_2:setScale(1)
        action_sprite_2:setOpacity(255)
    end
    actionArr:addObject(CCDelayTime:create(scale_time))
    actionArr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(scale_time/2),CCScaleBy:create(scale_time/2,1.2)))
    actionArr:addObject(CCCallFuncN:create(newFunc))
    actionArr:addObject(CCDelayTime:create(wait_time))

    -- actionArr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(scale_time),CCScaleBy:create(scale_time,0.5)))
    local timeInterval = 0.15
    actionArr2:addObject(CCDelayTime:create(scale_time+timeInterval))
    actionArr2:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(scale_time/2),CCScaleBy:create(scale_time/2,1.2)))
    actionArr2:addObject(CCCallFuncN:create(newFunc2))
    actionArr2:addObject(CCDelayTime:create(wait_time-timeInterval))

    local animArr = CCArray:create();
    animArr:addObject(CCScaleBy:create(scale_time,1.1));
    animArr:addObject(CCScaleBy:create(scale_time/2,1/1.1))
    animArr:addObject(CCDelayTime:create(wait_time))

    -- action_sprite:setAnchorPoint(ccp(0.5,0.5))
    -- action_sprite:setPosition(ccp(action_sprite:getContentSize().width*0.5,action_sprite:getContentSize().height*0.5))
    -- parentNode:addChild(action_sprite,-1,10)

    -- action_sprite_2:setAnchorPoint(ccp(0.5,0.5))
    -- action_sprite_2:setPosition(ccp(action_sprite:getContentSize().width*0.5,action_sprite:getContentSize().height*0.5))
    -- parentNode:addChild(action_sprite_2,-2,11)

    parentNode:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    action_sprite:runAction(CCRepeatForever:create(CCSequence:create(actionArr)))
    action_sprite_2:runAction(CCRepeatForever:create(CCSequence:create(actionArr2)))
end

--[[--

]]
function M.getEvolutionCfgByQuality(self,quality)
    return game_data:getEvolutionCfgByQuality(quality);
end

--[[--

]]
function M.getEnemyCfgByStageIdAndEnemyId(self,stageId,enemyId)
    local enemy_detail_cfg,enemyCfg = nil,nil;
    -- stageId = stageId or game_data:getSelCityId();
    -- enemy_detail_cfg = getConfig("enemy_soldier_" .. stageId);
    -- if enemy_detail_cfg then
    --     enemyCfg = enemy_detail_cfg:getNodeWithKey(tostring(enemyId))
    -- end
    -- if enemyCfg == nil then
    --     local enemy_detail_cfg = getConfig(game_config_field.enemy_detail);
    --     enemyCfg = enemy_detail_cfg:getNodeWithKey(tostring(enemyId))
    -- end
    return enemyCfg;
end
--[[
    创建粒子
    game_util:createParticleSystemQuad({fileName = "particle_fly_up"})
]]
function M.createParticleSystemQuad(self,params)
    local fileName = params.fileName or "particle_fly_up"
    local tempParticle = CCParticleSystemQuad:create(fileName .. ".plist")
    if tempParticle then
        if params.pos then
            tempParticle:setPosition(params.pos);
        end
        tempParticle:setAutoRemoveOnFinish(false);
    end
    return tempParticle
end

--[[
    game_util:addMoveAndRemoveAction({node = node,startPos = ccp(),endPos = ccp(),endCallFunc = nil,moveTime = 1.0})
]]
function M.addMoveAndRemoveAction(self,params)
    local node = params.node
    local startPos = params.startPos or ccp(0, 0)
    local endPos = params.endPos or ccp(0, 0)
    local endCallFunc = params.endCallFunc;
    local moveTime = params.moveTime or 1
    local delayTime = params.delayTime or 0
    local startNode = params.startNode
    if startNode then
        local pX,pY = startNode:getPosition();
        startPos = startNode:getParent():convertToWorldSpace(ccp(pX,pY));
    end
    local endNode = params.endNode
    if endNode then
        local pX,pY = endNode:getPosition();
        endPos = endNode:getParent():convertToWorldSpace(ccp(pX,pY));
    end
    local function callback(tempNode)
        local tag = tempNode:getTag();
        tempNode:removeFromParentAndCleanup(true);
        if endCallFunc then
            endCallFunc(tag);
        end
    end
    local animArr = CCArray:create();
    if delayTime > 0 then
        animArr:addObject(CCDelayTime:create(delayTime));
    end
    animArr:addObject(CCMoveTo:create(moveTime,endPos));
    animArr:addObject(CCCallFuncN:create(callback));
    local sequence = CCSequence:create(animArr)
    node:setPosition(startPos)
    node:runAction(sequence);
end
--[[
    获得卡牌分解的尘数量
]]
function M.getDirValueById(self,cardId)
    local sliver_value = 0;
    local itemData,hero_config = game_data:getCardDataById(cardId)

    local exchange_id = hero_config:getNodeWithKey("exchange_id"):toInt()
    local character_exchange_cfg = getConfig(game_config_field.character_exchange)
    local data_config = character_exchange_cfg:getNodeWithKey(tostring(exchange_id))
    local dirt_gold = data_config:getNodeWithKey("dirt_gold")
    local dirt_silver = data_config:getNodeWithKey("dirt_silver")
    local dirt_silver0 = dirt_silver:getNodeAt(0);
    local evo = (itemData.evo + 1);
    sliver_value = dirt_silver0:getNodeAt(0):toInt()*evo;

    local sliver_max = dirt_silver0:getNodeAt(1):toInt()*evo
    local gold_min = 1*evo
    local gold_max = 1*evo
    for i=1,dirt_gold:getNodeCount() do
        local gold_1 = dirt_gold:getNodeAt(i-1):getNodeAt(0):toInt()
        local gold_2 = dirt_gold:getNodeAt(i-1):getNodeAt(1):toInt()

        if gold_1 < gold_min then
            gold_min = gold_1*evo
        end
        if gold_2 > gold_max then
            gold_max = gold_2*evo
        end
    end
    return sliver_value,gold_min,sliver_max,gold_max;
end

--[[
    
]]
function M.setSelectServerGameUrl(self)
    local server = game_data:getServer();

    --master_url路径
    local len = string.len(server.master_url);
    local endStr = string.sub(server.master_url,len,len);
    if endStr == "/" then
        master_url = string.sub(server.master_url,0,len-1);
    else
        master_url = server.master_url;
    end
    cclog("endStr===============" .. endStr .. " ; master_url = " .. master_url)


    --lua_resource文件的下载路径
    len = string.len(server.lua_url);
    endStr = string.sub(server.lua_url,len,len);
    if endStr == "/" then
        lua_url = string.sub(server.lua_url,0,len-1);
    else
        lua_url = server.lua_url;
    end
    cclog("endStr===============" .. endStr .. " ; lua_url = " .. lua_url)

    --lua_resource文件的版本路径
    len = string.len(server.lua_ver_url);
    endStr = string.sub(server.lua_ver_url,len,len);
    if endStr == "/" then
        lua_ver_url = string.sub(server.lua_ver_url,0,len-1);
    else
        lua_ver_url = server.lua_ver_url;
    end
    cclog("endStr===============" .. endStr .. " ; lua_ver_url = " .. lua_ver_url)


    -- api 服务路径
    len = string.len(server.domain);
    endStr = string.sub(server.domain,len,len);
    if endStr == "/" then
        service_url = string.sub(server.domain,0,len-1);
    else
        service_url = server.domain;
    end
    cclog("endStr===============" .. endStr .. " ; service_url = " .. service_url)


    -- 大逃杀 服务路径
    len = string.len(server.dataosha_url);
    endStr = string.sub(server.dataosha_url,len,len);
    if endStr == "/" then
        dataosha_url = string.sub(server.dataosha_url,0,len-1);
    else
        dataosha_url = server.dataosha_url;
    end
    cclog("endStr===============" .. endStr .. " ; dataosha_url = " .. dataosha_url)

    -- 聊天 服务路ip
    len = string.len(server.chat_ip);
    endStr = string.sub(server.chat_ip,len,len);
    if endStr == "/" then
        chat_ip = string.sub(server.chat_ip,0,len-1);
    else
        chat_ip = server.chat_ip;
    end
    cclog("endStr===============" .. endStr .. " ; chat_ip = " .. chat_ip)
    -- 聊天 服务路 port
    chat_port = tonumber(server.chat_port);
    cclog("endStr===============" .. endStr .. " ; chat_port = " .. chat_port)
end

--[[
    
]]
function M.createExtNumberChangeNode(self,t_params)
    t_params = t_params or {};
    local numberChangeNode
    t_params.labelType = t_params.labelType or 1;
    t_params.value = t_params.value or 0;
    if t_params.labelType == 1 then
        t_params.fontSize = t_params.fontSize or 12
        numberChangeNode = ExtNumberChangeNode:createTTF(t_params.value,TYPE_FACE_TABLE.Arial_BoldMT,t_params.fontSize);
    else
        t_params.fnt = t_params.fnt or "yellow_image_text.fnt"
        numberChangeNode = ExtNumberChangeNode:createBMFont(t_params.value,t_params.fnt)
    end
    if t_params.callBackFunc then
        numberChangeNode:registerScriptHandler(t_params.callBackFunc)
    end
    return numberChangeNode;
end

--[[
    
]]
function M.combatChangedValue(self,t_params)
    local combatNode = t_params.combatNode;
    local value = t_params.value or 0
    if combatNode == nil or value == 0 then
        return;
    end
    local tempLabel = nil;
    if value > 0 then
        tempLabel = self:createLabelBMFont({text = "+" .. value,fnt = "yellow_image_text.fnt",color = ccc3(0, 255, 0)});    
    else
        tempLabel = self:createLabelBMFont({text = value,fnt = "yellow_image_text.fnt",color = ccc3(255, 0, 0)});
    end
    local function remove_node( node )
        node:removeFromParentAndCleanup(true);
    end
    local arr = CCArray:create();
    arr:addObject(CCMoveTo:create(0.2,ccp(0, 15)));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(CCCallFuncN:create(remove_node));
    tempLabel:runAction(CCSequence:create(arr));
    if t_params.anchorPoint then
        tempLabel:setAnchorPoint(t_params.anchorPoint);
    end
    combatNode:addChild(tempLabel)
end

function M.getPayInfoUrl(self)
    
    local function responseMethod(tag,gameData)

    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("pay_respon_url"), http_request_method.GET, nil,"pay_respon_url")

end

--[[
    
]]
function M.combatChangedValueAnim(self,t_params)
    local combatNode = t_params.combatNode;
    if combatNode == nil then return end;
    local currentValue = t_params.currentValue or self:getCombatValue()
    local changeValue = t_params.changeValue or 0;
    combatNode:registerScriptHandler(function()
        self:combatChangedValue({combatNode = combatNode,value = changeValue,anchorPoint = ccp(0, 0.5)});
    end)
    if changeValue > 0 then
        combatNode:setCurValue(currentValue-100,false);
        combatNode:setCurValue(currentValue,true,200);
    elseif changeValue < 0 then
        combatNode:setCurValue(currentValue+100,false);
        combatNode:setCurValue(currentValue,true,200);
    end
    -- local tempChangeValue = math.abs(changeValue)
    -- if tempChangeValue < 1000 then
    --     combatNode:setCurValue(currentValue,true,200);
    -- elseif tempChangeValue < 10000 then
    --     combatNode:setCurValue(currentValue,true,1000);
    -- else
    --     combatNode:setCurValue(currentValue,true,5000);
    -- end
end

--[[
    奖励卡牌动画
]]
function M.addRewardCardAnim(self,tempId)
    local cardData,heroCfg = game_data:getCardDataById(tostring(tempId));
    local currentUiName = game_scene:getCurrentUiName();
    local game_active_limit_pop = game_scene:getPopByName("game_active_limit_pop")
    if cardData == nil or heroCfg == nil or currentUiName == "game_gacha_scene" or game_active_limit_pop ~= nil then return false end
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local animFile = "gacha_anim_1";
    if quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
    else
        return false;
    end
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local m_root_layer = CCLayerColor:create(ccc4(0, 0, 0, 100), visibleSize.width, visibleSize.height)
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then
        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            animNode:playSection("xunhuan");
            local animNode = game_util:createHeroListItemByCCB(cardData);
            if animNode then
                animNode:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
                m_root_layer:addChild(animNode,20,20)
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.width*0.5))
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
    m_root_layer:addChild(m_iAnim,10,10);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            m_root_layer:removeFromParentAndCleanup(true);
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 100,true);
    m_root_layer:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(m_root_layer,1000,1000);
    return true;
end

--[[
    奖励装备动画  品质大于等于3
]]
function M.addRewardEquipAnim(self,tempId)
    local itemData,itemCfg = game_data:getEquipDataById(tostring(tempId));
    if itemData == nil or itemCfg == nil then return end
    local quality = itemCfg:getNodeWithKey("quality"):toInt();
    local animFile = "gacha_anim_1";
    if quality == 2 then
    elseif quality == 3 then
        animFile = "gacha_anim_2";
    elseif quality > 3 then
        animFile = "gacha_anim_3";
    else
        return;
    end
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    local m_root_layer = CCLayerColor:create(ccc4(0, 0, 0, 100), visibleSize.width, visibleSize.height)
    local m_iAnim = zcAnimNode:create(animFile .. ".swf.sam",0,animFile .. ".plist");
    local function animEnd(animNode,theId,lableName)
        if lableName == "daiji" then
        elseif lableName == "xunhuan" then
            animNode:playSection("xunhuan");
        elseif lableName == "fanpai" then
            game_sound:playUiSound("gacha")
            animNode:playSection("xunhuan");
            local animNode = game_util:createEquipItemByCCB(itemData);
            if animNode then
                animNode:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
                m_root_layer:addChild(animNode,20,20)
            end
        end
    end
    m_iAnim:registerScriptTapHandler(animEnd);
    m_iAnim:playSection("daiji");
    m_iAnim:setScale(1);
    m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.width*0.5))
    local function animEndCallFunc()
        m_iAnim:playSection("fanpai");
    end
    cclog("addAnim ======================== " .. animFile);
    local animArr = CCArray:create();
    animArr:addObject(CCMoveTo:create(0.1,ccp(visibleSize.width*0.5, visibleSize.height*0.5)));
    animArr:addObject(CCCallFunc:create(animEndCallFunc));
    m_iAnim:runAction(CCSequence:create(animArr));
    -- m_iAnim:setPosition(ccp(visibleSize.width*0.5, visibleSize.height*0.5))
    -- game_scene:getPopContainer():addChild(m_iAnim,10,10);
    m_root_layer:addChild(m_iAnim,10,10);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            m_root_layer:removeFromParentAndCleanup(true);
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 100,true);
    m_root_layer:setTouchEnabled(true);
    game_scene:getPopContainer():addChild(m_root_layer,1000,1000);
end


function M.isEqual(self, valueLeft, ...)
    local args = {...}
    for k,v in pairs(args) do
        if valueLeft == v then
            return true
        end
    end
    return false
end

function M.setWordAchieve(self,achieve_btn ,expBar ,world_level ,world_score)
    cclog("world_level ======== " .. tostring(world_level) .. " ; world_score === " .. tostring(world_score))
    world_level = world_level or 1;
    world_score = world_score or 0;
    local integration_world_cfg = getConfig(game_config_field.integration_world)
    local item_cfg = integration_world_cfg:getNodeWithKey(tostring(world_level));
    if item_cfg then
        local maxScore = item_cfg:getNodeWithKey("top"):toInt();
        maxScore = maxScore == 0 and 100 or maxScore;
        expBar:setMaxValue(maxScore);
        expBar:setCurValue(world_score,false);
        local bgSprSize = expBar:getContentSize();
        local tempLabel = self:createLabelTTF({text = string.format("%0.0f",math.floor(100*math.min(maxScore,world_score)/maxScore)) .. "%",color = ccc3(255,255,255),fontSize = 16});
        tempLabel:setPosition(ccp(bgSprSize.width*0.5,bgSprSize.height*0.5));
        expBar:addChild(tempLabel);
    end
end
--[[
    获得卡牌的名称
]]
function M.getCardName(self,itemData,itemCfg)
    if itemData == nil or itemCfg == nil then return "" end
    local bk_value = itemData.bre or 0;
    local character_break_cfg = getConfig(game_config_field.character_break_new)
    local character_ID = itemCfg:getKey()--itemCfg:getNodeWithKey("character_ID"):toStr();
    local character_break_item = character_break_cfg:getNodeWithKey(character_ID)
    local name_after = itemData.step < 1 and "" or ("+" .. itemData.step);
    if character_break_item then
        local name_str = character_break_item:getNodeWithKey("name" .. bk_value)
        if name_str then
            name_after = name_str:toStr() .. name_after
        else
            name_after = itemCfg:getNodeWithKey("name"):toStr() .. name_after
        end
    else
        name_after = itemCfg:getNodeWithKey("name"):toStr() .. name_after
    end
    return name_after;
end

function M.invitePlayerJoinGuild( self, uid, responseMethod )
    local params = {};
    params.target_id = uid
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_invite"), http_request_method.GET, params,"guild_invite")
end

function M.invitePlayerBeFriend( self, uid, responseMethod )
    local params = {};
    params.target_id = uid
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("friend_apply_friend"), http_request_method.GET, params,"friend_apply_friend")
end

function M.createMask( self, width, height, point)
    print(width, height, "createMask ============= ")
    local m_layer = CCLayerColor:create(ccc4(0, 0, 0, 255), width, height);
    local ccb = ccBlendFunc:new_local()
    ccb.src = GL_ZERO;
    ccb.dst = GL_ONE_MINUS_SRC_ALPHA;

    m_layer:setBlendFunc(ccb);
    m_layer:setPosition(point);
    local s = CCDirector:sharedDirector():getWinSize();
    
    local rt = CCRenderTexture:create(s.width, s.height);
    local ccb1 = ccBlendFunc:new_local()
    ccb1.src = GL_SRC_ALPHA;
    ccb1.dst = GL_ONE_MINUS_SRC_ALPHA;
    rt:getSprite():setBlendFunc(ccb1);
    rt:clear(0.0, 0.0, 0.0, 0.8);
    -- rt->clear(0.0f, 0.0f, 0.0f, 0.0f);
    
    rt:setPosition(s.width/2,s.height/2);
    
    rt:begin();
    m_layer:visit();
    rt:endToLua();
    return rt
end

--[[
    创建截屏
]]
function M.createScreenShoot(self)
    local pCurScene = CCDirector:sharedDirector():getRunningScene();
    local screenShoot = nil;
    if pCurScene then
        local tempSize = CCDirector:sharedDirector():getWinSize();  
        screenShoot = CCRenderTexture:create(tempSize.width,tempSize.height, kCCTexture2DPixelFormat_RGB565);
        screenShoot:begin();  
        pCurScene:visit();  
        screenShoot:endToLua();
    end
    return screenShoot;
end

--[[
    创建
    game_util:createCustomLabel({text = "",title = "",labelWidth = size})
]]
function M.createCustomLabel(self,params)
    params = params or {};
    local text = params.text
    if text == nil or text == "" then
        text = string_helper.game_util.none
    end
    local title = params.title or string_helper.game_util.none
    local nineBg = params.nineBg or "public_mianshukuang.png"
    local bianqianBg = params.bianqianBg or "public_bianqian.png"
    local labelWidth = params.labelWidth or 100
    local msgLabel = self:createRichLabelTTF({text = text,dimensions = CCSizeMake(labelWidth - 10, 0),textAlignment = kCCTextAlignmentLeft,verticalTextAlignment,color = ccc3(221,221,192)})
    local tempSize = msgLabel:getContentSize()
    local realSize = CCSizeMake(tempSize.width, tempSize.height+30)
    local tempBg = CCScale9Sprite:createWithSpriteFrameName(nineBg);
    tempBg:setPreferredSize(CCSizeMake(labelWidth, tempSize.height + 10))
    tempBg:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5 + 5))
    msgLabel:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5 + 5))
    local tempNode = CCNode:create();
    tempNode:setContentSize(realSize)
    tempNode:addChild(tempBg);
    tempNode:addChild(msgLabel);
    local bianqian = CCSprite:createWithSpriteFrameName(bianqianBg)
    local titleLabel = self:createLabelTTF({text = title,color = ccc3(246,221,154),fontSize = 10});
    local bianqianSize = bianqian:getContentSize();
    bianqian:setPosition(ccp(bianqianSize.width*0.5 -5,realSize.height - bianqianSize.height*0.5 -5));
    titleLabel:setPosition(ccp(bianqianSize.width*0.5 -5,realSize.height-bianqianSize.height*0.5 - 5));
    if params.pos then
        titleLabel:setPosition(ccp(bianqianSize.width*0.5 -5 + params.pos,realSize.height-bianqianSize.height*0.5 - 5));
    end
    tempNode:addChild(bianqian)
    tempNode:addChild(titleLabel)
    tempNode:setAnchorPoint(ccp(0.5, 0.5))
    tempNode:ignoreAnchorPointForPosition(false);
    return tempNode;
end


--[[--
    Gallery Page
]]
function M.createGalleryPage(self,params)
    if params == nil or type(params) ~= "table" then
        params = {};
    end
    local m_nTotalPage = 1;
    local m_nCurPage = 1;
    if params.totalItem ~= nil then
        m_nTotalPage = tonumber(params.totalItem);
    end
    if params.showPageIndex and m_nTotalPage > 0 then
        m_nCurPage = math.min(params.showPageIndex,m_nTotalPage)
    end
    local galleryLayer = CCLayer:create();
    local pageIndexNode = CCNode:create();
    local tableViewSize = params.viewSize;
    galleryLayer:setContentSize(tableViewSize)
    pageIndexNode:setPosition(ccp(tableViewSize.width*0.5,-visibleSize.height*0.025));
    galleryLayer:addChild(pageIndexNode,20,20);

    local pageLable = CCLabelTTF:create("0/0",TYPE_FACE_TABLE.Arial_BoldMT,10);
    pageLable:setVisible(false);
    pageLable:setAnchorPoint(ccp(1,0));
    pageLable:setPositionX(tableViewSize.width);
    galleryLayer:addChild(pageLable,100,100);
    if m_nTotalPage == 0 then
        pageLable:setVisible(false);
    end
    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.25)
    leftArrow:setPosition(ccp(-10,tableViewSize.height*0.5));
    galleryLayer:addChild(leftArrow)
    local rightArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    rightArrow:setFlipX(true)
    rightArrow:setScale(0.25)
    rightArrow:setPosition(ccp(tableViewSize.width + 10,tableViewSize.height*0.5));
    galleryLayer:addChild(rightArrow)
    if params.showPoint ~= nil and params.showPoint == false then
        pageIndexNode:setVisible(false);
        leftArrow:setVisible(false);
        rightArrow:setVisible(false);
        pageLable:setVisible(false);
    end
    local posX,posY;
    local direction = 0;
    local function refreshTableView()
        if params.pageChangedCallFunc and m_nTotalPage ~= 0 then
            params.pageChangedCallFunc(m_nTotalPage,m_nCurPage,galleryLayer)
        end
        pageLable:setString(m_nCurPage .. "/" .. m_nTotalPage);
        if m_nTotalPage > 1 then
            if m_nCurPage == 1 then
                leftArrow:setOpacity(0);
                rightArrow:setOpacity(255);
            elseif m_nCurPage == m_nTotalPage then
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(0);
            else
                leftArrow:setOpacity(255);
                rightArrow:setOpacity(255);
            end
        else
            leftArrow:setOpacity(0);
            rightArrow:setOpacity(0);
        end
    end
    refreshTableView();

    local function adjustScrollView(offset)
        -- cclog("adjustScrollView offset =====================" .. tostring(offset));
        local refreshPageIndexFlag = true;
        if offset < -200 then
            m_nCurPage = m_nCurPage + 1;
            direction = 1;
        elseif offset > 200 then
            m_nCurPage = m_nCurPage - 1;
            direction = -1;
        else
            refreshPageIndexFlag = false;
        end
        if m_nCurPage < 1 then
            m_nCurPage = 1;
            refreshPageIndexFlag = false;
        elseif m_nCurPage > m_nTotalPage then
            m_nCurPage = m_nTotalPage;
            refreshPageIndexFlag = false;
        end
        if refreshPageIndexFlag and m_nTotalPage > 1 then
            refreshTableView();
        end
    end
    -- handing touch events
    local touchBeginPoint = nil
    local touchPoint = nil
    local beganTime = nil
    local moveFlag = nil
    local function onTouchBegan(x, y)
        -- cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        -- CCTOUCHBEGAN event must return true
        beganTime = os.time();
        moveFlag = false;
        longClick = false;
        if not galleryLayer:boundingBox():containsPoint(galleryLayer:getParent():convertToNodeSpace(ccp(x,y))) then
            return false;
        end
        return true
    end

    local function onTouchMoved(x, y)
        -- cclog("onTouchMoved: %0.2f, %0.2f", x, y)
        if touchPoint then
            local cx, cy = 0,0;
            local offsetX = cx + x - touchPoint.x;
            if offsetX < 100 and offsetX > -100 then
                touchPoint = {x = x, y = y}
            end
        end
        if moveFlag == false then
        end
        moveFlag = true;
    end

    local function onTouchEnded(x, y)
        -- cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        local distance = x - touchBeginPoint.x;
        if distance > 1 or distance < -1 then
            adjustScrollView(distance/math.max(0.1,(os.time() - beganTime)));
        end
        touchBeginPoint = nil
        touchPoint = nil
        beganTime = nil
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end
    
    galleryLayer:registerScriptTouchHandler(onTouch,false,params.touchPriority and params.touchPriority-1 or -128,false)
    galleryLayer:setTouchEnabled(true)
    return galleryLayer;
end
--[[
    各种抽卡
]]
function M.setGachaSelect( self,viewSize,in_index )
    local spriteFrameTable = {"equip_title_hero.png","equip_title_equip.png","equip_title_shop.png","equip_title_limit.png"}
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = 4;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_4in1_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            if ccbNode then
                local back_sprite = ccbNode:spriteForName("back_sprite");
                local light_add = ccbNode:scale9SpriteForName("light_add")

                back_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameTable[index+1]));
                if (index + 1) == in_index then
                    light_add:setVisible(true)
                else
                    light_add:setVisible(false)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            if (index + 1) ~= in_index then--跳转界面
                if index == 0 then--伙伴gacha
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
                elseif index == 1 then--装备gacha
                    -- self:addMoveTips({text = "暂未开放！"})
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_gacha_equip",{gameData = gameData});
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("equip_gacha_get_all_gacha"), http_request_method.GET, nil,"equip_gacha_get_all_gacha")
                elseif index == 2 then--钻石商城
                    function shopOpenResponseMethod(tag,gameData)
                        game_scene:enterGameUi("game_buy_item_scene",{gameData = gameData});
                    end
                    network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
                elseif index == 3 then--限购商城
                    local function responseMethod(tag,gameData)
                        game_scene:enterGameUi("game_limit_shop",{gameData = gameData});
                     end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_outlets_open"), http_request_method.GET, {},"shop_outlets_open");
                end
            end
        end
    end
    return TableViewHelper:create(params);
end
--
function M.createGachaSelect( self,index )
    
end

--[[
    统计：发送用户步数
]]
function M.statisticsSendUserStep( self, newstep )

    -- cclog2(newstep," user step statisticsSendUserStep  =====  ")
    local url = ""

    local device_mark = CCUserDefault:sharedUserDefault():getStringForKey("device_mark");
    if device_mark == nil or device_mark == "" then
        device_mark   = tostring(util_system:macAddres()); -- mac 地址
    end

    local platform_channel = ""
    if util_system.getPlatformChannel then
        platform_channel = tostring(util_system:getPlatformChannel()); -- 平台渠道号
    end
    local user_name = CCUserDefault:sharedUserDefault():getStringForKey("username")
    if user_name == "" then user_name = "nil" end
    url = "http://119.81.219.41/en_pub/crash/?method=statistics&newstep=" .. tostring(newstep) .. "&user_name=".. tostring(user_name) .. "&"

    url = url .. "&user_token=" .. tostring(user_token) .. "&mk=" .. tostring(mark_user_login_mk);
    -- url = url .. "&user_token=" .. "g651119638" .. "&backdoor=12581"
    url = url .. "&version=" .. CLIENT_VERSION;
    url = url .. "&pt=" .. device_platform .. "&device_mark=" .. tostring(device_mark) .. "&platform_channel=" .. tostring(platform_channel) 
    if util_system.getTotalMemory then
        url = url .. "&device_mem=" .. tostring(util_system:getTotalMemory())
    end
    if newstep < 7 then
        network.sendHttpRequestNoLoading(nil,url, http_request_method.GET, {step = newstep},"statistics_add_step")
        return
    elseif newstep == 7 then
        network.sendHttpRequestNoLoading(nil,url, http_request_method.GET, {step = newstep},"statistics_add_step")
        url = game_url.getUrlForKey("statistics_add_step")
    else
        url = game_url.getUrlForKey("statistics_add_step")
    end
    -- self.m_netWork.sendHttpRequest( function() end , game_url.getUrlForKey("statistics_add_step") , http_request_method.GET , params_ , "statistics_add_step" ,false );
    network.sendHttpRequestNoLoading(nil,url, http_request_method.GET, {step = newstep},"statistics_add_step")
end

--[[
    通过CID创建宝石图标
]]
function M.createGemIconByCid(self,cid)
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(tostring(cid));
    if itemCfg == nil then return nil,nil end
    return self:createGemIconByCfg(itemCfg),itemCfg:getNodeWithKey("last_name"):toStr()
end
--[[
    通过Cfg创建宝石图标
]]
function M.createGemIconByCfg(self,itemCfg)
    local tempIcon = nil;
    if itemCfg then
        local icon = itemCfg:getNodeWithKey("icon"):toStr();
        tempIcon = self:createIconByName(icon)
        if tempIcon == nil then
            cclog(icon .. " image is not found");
        end
    else
        cclog("gem config is not found");
    end
    if tempIcon then
        local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
        -- cclog("quality ==" .. quality)
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality];
        if qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,2)
        end
    end
    return tempIcon;
end

--[[
    
]]
function M.getGemAttributeValue(self,itemCfg,level)
    local attrName1,value1,icon1 = string_helper.game_util.none,string_helper.game_util.none,"";
    local attrName2,value2,icon2 = string_helper.game_util.none,0,"";
    value1 = itemCfg:getNodeWithKey("value"):toInt();
    local ability = itemCfg:getNodeWithKey("ability"):toInt();
    -- cclog("ability ====================" .. ability)
    local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability]
    if attrTab then
        attrName1 = attrTab.name;
        icon1 = attrTab.icon;
    end
    value2 = itemCfg:getNodeWithKey("value2");
    if value2 then
        value2 = value2:toInt();
        local ability2 = itemCfg:getNodeWithKey("ability2"):toInt();
        local attrTab = PUBLIC_ABILITY_TABLE["ability_" .. ability2]
        if attrTab then
            attrName2 = attrTab.name;
            icon2 = attrTab.icon;
        end
    else
        value2 = 0
    end
    return attrName1,value1,icon1,attrName2,value2,icon2;
end
--[[

]]
function M.createGemItemByCCB(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_gem_system_list_item.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setGemItemInfoByTable(ccbNode,itemData);
    end
    return ccbNode
end

function M.setGemItemInfoByTable(self,ccbNode,itemData)
    if ccbNode == nil or itemData == nil then return end
    ccbNode:nodeForName("m_info_node"):setVisible(true);
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(itemData.c_id);
    local attrName1,value1,icon1,attrName2,value2,icon2 = self:getGemAttributeValue(itemCfg);
    ccbNode:labelBMFontForName("m_ability1_name_label"):setString(attrName1);
    ccbNode:labelBMFontForName("m_ability1_label"):setString("+" .. value1);
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1)
    if tempSpriteFrame then
        ccbNode:spriteForName("m_ability1_icon"):setDisplayFrame(tempSpriteFrame);
    end
    local career = itemCfg:getNodeWithKey("career"):toInt();
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(PUBLIC_ABILITY_TABLE["ability_" .. career].icon)
    if tempSpriteFrame then
        ccbNode:spriteForName("m_type_icon"):setDisplayFrame(tempSpriteFrame)
    end
    local quality = itemCfg:getNodeWithKey("quality"):toInt()+1;
    if quality > 0 and quality < 8 then
        ccbNode:spriteForName("m_spr_bg"):setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(HERO_QUALITY_COLOR_TABLE[quality].card_img));
    end
    local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local last_name = itemCfg:getNodeWithKey("last_name"):toStr()
    local first_name = itemCfg:getNodeWithKey("first_name"):toStr()
    m_name_label:setString(last_name .. first_name .. " x" .. tostring(itemData.count));

    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    --防御新增
    local m_ability2_label = ccbNode:labelBMFontForName("m_ability2_label")
    local fangyu_node = ccbNode:nodeForName("fangyu_node")
    if value2 > 0 then
        fangyu_node:setVisible(true)
        m_ability2_label:setString("+" .. tostring(value2))
    else
        fangyu_node:setVisible(false)
    end
    -- local existFlag,cardName = game_data:gemInGemPos(career,itemData.c_id)
    -- if existFlag then
    --     m_team_img:setVisible(true);
    --     m_team_name:setString(cardName);
    -- else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    -- end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = self:createIconByName(itemCfg:getNodeWithKey("icon"):toStr()) --self:createGemIconByCfg(itemCfg)
    if icon then
        m_anim_node:addChild(icon)
    end
end

function M.createGemItemByCCB2(self,itemData)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_gem_system_list_item2.ccbi");
    ccbNode:setAnchorPoint(ccp(0.5,0.5));
    if ccbNode ~= nil and itemData ~= nil then
        self:setGemItemInfoByTable2(ccbNode,itemData);
    end
    return ccbNode
end

function M.setGemItemInfoByTable2(self,ccbNode,itemData)
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(tostring(itemData.c_id));
    if itemCfg == nil then return end
    local level = itemData.lv;
    local attrName1,value1,icon1 = self:getGemAttributeValue(itemCfg,level);
    ccbNode:labelBMFontForName("m_ability1_label"):setString("+" .. value1);
    local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon1)
    if tempSpriteFrame then
        ccbNode:spriteForName("m_ability1_icon"):setDisplayFrame(tempSpriteFrame);
    end
    local m_name_label = ccbNode:labelBMFontForName("m_name_label");
    local last_name = itemCfg:getNodeWithKey("last_name"):toStr()
    local first_name = itemCfg:getNodeWithKey("first_name"):toStr()
    m_name_label:setString(last_name .. first_name .. " x" .. tostring(itemData.count));
    ccbNode:labelBMFontForName("m_ability1_name_label"):setString(attrName1);
    
    ccbNode:spriteForName("m_sel_img"):setVisible(false);
    local m_team_img = ccbNode:spriteForName("m_team_img")
    local m_team_name = ccbNode:labelBMFontForName("m_team_name")
    local existFlag,cardName = game_data:gemInGemPos(itemCfg:getNodeWithKey("career"):toInt(),itemData.c_id)
    -- if existFlag then
    --     m_team_img:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_yizhuangbei.png"));
    --     m_team_img:setVisible(true);
    --     -- m_team_name:setString(cardName);
    --     m_team_name:setString("");
    -- else
        m_team_img:setVisible(false);
        m_team_name:setString("");
    -- end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local icon = self:createGemIconByCfg(itemCfg)
    if icon then
        icon:setScale(0.75);
        m_anim_node:addChild(icon)
    end
    local m_max_evo_img = ccbNode:spriteForName("m_max_evo_img")
end

function M.getGemRewardId(self,tempId,count)
    -- cclog(tostring(tempId) .. " ; count ===========" .. tostring(count))
    local icon,name,quality = nil,"",0;
    local gemCfg = getConfig(game_config_field.gem);
    local itemCfg = gemCfg:getNodeWithKey(tostring(tempId));
    if itemCfg then
        local last_name = itemCfg:getNodeWithKey("last_name"):toStr()
        local first_name = itemCfg:getNodeWithKey("first_name"):toStr()
        name = last_name .. first_name
        icon = self:createGemIconByCfg(itemCfg);
        quality = itemCfg:getNodeWithKey("quality"):toInt();
    else
        cclog("gemCfg cfg not found == " .. tostring(tempId))
    end
    return icon,name,count,quality;
end

--[[
    解析时间  dd hh-mm
    结束时时间戳
]]
function M.parseDDHHMMTime1( self, timeStr )
    local prTime = util.string_cut(timeStr, " ")
    local addDay = tonumber(prTime[1]) or 0
    local serTime = game_data:getServerOpenTime() or 0
    local endTime = serTime + (addDay - 1) * 86400   -- 结束时间 = 服务器时间 + （开服天数 - 1）秒数
    local endTimeTable = os.date("*t",endTime)
    local hourMinStr = prTime[2]
    local hourMinStrTable = util.string_cut(hourMinStr, ":")
    local hour = tonumber(hourMinStrTable[1]) or 0   
    local min = tonumber(hourMinStrTable[2]) or 0 
    local sec = tonumber(hourMinStrTable[3]) or 0
    endTimeTable.hour = hour                            -- 替换成配置时间 时
    endTimeTable.min = min                              -- 替换成配置时间 分
    endTimeTable.sec = 0
    local endtime = os.time(endTimeTable)
    return endtime
end

--[[
    根据服务器时间判断是否在开服规定的时间内
    openServerDay  开服活动第几天内
    isRightDay     是否是精确的时间
]]
function M.isInServertimeInServerday( self, openServerDay, isRightDay )
    local serTime = tonumber(game_data:getUserStatusDataByKey("server_time")) or 0
    local serOpen = game_data:getServerOpenTime()
    local serOpenTime = tonumber(serOpen) or 0

    local rightDayTime = serOpenTime + (openServerDay) * 86400
    local rightDayTable = os.date("*t", rightDayTime)
    rightDayTable.hour = 0
    rightDayTable.min = 0
    rightDayTable.sec = 0
    -- local tab = {year=2005, month=11, day=6, hour=22,min=18,sec=30,isdst=false}
    local rightTime = os.time(rightDayTable)
    local flag = false
    if serTime > 0 and serTime < rightTime then 
        flag = true
    end
    -- cclog2(openServerDay, "openServerDay  ===  ")
    -- cclog2(flag, "flag  ===  ")
    return flag
end


--[[--
    查看用户
]]
function M.lookPlayerInfo(self,uid, isFriend, enterType)
    local function responseMethod(tag,gameData)
        game_scene:addPop("game_player_info_pop",{gameData = gameData, isFriend = isFriend, enterType = enterType})
    end
    local params = {};
    params.uid = uid;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_info"), http_request_method.GET, params,"user_info")
end

--[[
    获取花费的钻石数
]]
function M.getCostCoinBuyTimes(self,key,buyTimes)
    buyTimes = buyTimes or 0;
    local canBuy = false;
    local payValue = 0
    local vipLevel = game_data:getVipLevel()
    local vipCfg = getConfig(game_config_field.vip)
    local vipItemCfg = vipCfg:getNodeWithKey(tostring(vipLevel))
    if vipItemCfg then
        local buyLimit = vipItemCfg:getNodeWithKey("buy_point"):toInt()
        if buyTimes < buyLimit then
            local PayCfg = getConfig(game_config_field.pay)
            local itemCfg = PayCfg:getNodeWithKey(tostring(key))
            if itemCfg then
                local coin = itemCfg:getNodeWithKey("coin")
                local tempCount = coin:getNodeCount()
                if buyTimes >= tempCount then
                    payValue = coin:getNodeAt(tempCount-1):toInt()
                else
                    payValue = coin:getNodeAt(buyTimes):toInt()
                end
                canBuy = true;
            else
                self:addMoveTips({text = string_helper.game_util.payCfg .. tostring(key)})
            end
        end
    else
        self:addMoveTips({text = string_helper.game_util.vipCfg .. vipLevel})
    end
    return canBuy,payValue;
end

--创建物品图标
function M.createMazeItemIconByCfg(self,itemCfg)
    local tempIcon = nil;
    if itemCfg then
        tempIcon = self:createIconByName(itemCfg:getNodeWithKey("icon"):toStr());
        local quality = itemCfg:getNodeWithKey("quality"):toInt();
        local qualityTab = HERO_QUALITY_COLOR_TABLE[quality+1];
        if tempIcon and qualityTab then
            local tempIconSize = tempIcon:getContentSize();
            local img1 = CCSprite:createWithSpriteFrameName(qualityTab.img1)
            img1:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img1,-1,1)
            local img2 = CCSprite:createWithSpriteFrameName(qualityTab.img2)
            img2:setPosition(ccp(tempIconSize.width*0.5,tempIconSize.height*0.5));
            tempIcon:addChild(img2,1,2)
        end
    end
    return tempIcon;
end
--[[
    回廊获得奖励
]]
function M.createMazeRewardTips(self,stageId,shopIndex)
    local maze_item_cfg = getConfig(game_config_field.maze_item)
    local maze_buff_cfg = getConfig(game_config_field.maze_buff)
    local maze_stage_cfg = getConfig(game_config_field.maze_stage)
    local maze_stage_cfg_item = maze_stage_cfg:getNodeWithKey(tostring(stageId));
    if maze_stage_cfg_item then
        local rewardCount = 0;
        local function createRewardItem(icon,name)
            local bgSpr = CCSprite:createWithSpriteFrameName("public_reward_item_bg.png")
            local bgSprSize = bgSpr:getContentSize();
            if icon then
                icon:setPosition(ccp(bgSprSize.width*0.4,bgSprSize.height*0.5));
                icon:setScale(0.75);
                bgSpr:addChild(icon);
            end
            if name then
                local tempLabel = self:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 16});
                tempLabel:setPosition(ccp(bgSprSize.width*0.5,bgSprSize.height*0.5));
                bgSpr:addChild(tempLabel);
            end
            rewardCount = rewardCount + 1;
            self:addMoveTipsByNode(bgSpr,0.5*(rewardCount-1),removeCallFunc);
        end

        local buff = maze_stage_cfg_item:getNodeWithKey("buff")
        local buffCount = buff:getNodeCount();
        if buffCount > 0 then
            for i=1,buffCount do
                local buffId = buff:getNodeAt(i - 1):toStr()
                local maze_buff_cfg_item = maze_buff_cfg:getNodeWithKey(buffId)
                if maze_buff_cfg_item then
                    createRewardItem(nil,string_helper.game_util.getBuff .. maze_buff_cfg_item:getNodeWithKey("name"):toStr())
                end
            end
        end
        local item = maze_stage_cfg_item:getNodeWithKey("item")
        local itemCount = item:getNodeCount();
        if itemCount > 0 then
            for i=1,itemCount do
                local buffId = item:getNodeAt(i - 1):toStr()
                local maze_item_cfg_item = maze_item_cfg:getNodeWithKey(buffId)
                if maze_item_cfg_item then
                    createRewardItem(nil,string_helper.game_util.getItem .. maze_item_cfg_item:getNodeWithKey("name"):toStr())
                end
            end
        end
        local shop = maze_stage_cfg_item:getNodeWithKey("shop")
        local shopCount = shop:getNodeCount();
        local startIndex,endIndex = 1,shopCount;
        if shopIndex then
            startIndex = math.max(1,math.min(shopIndex+1,shopCount));
            endIndex = startIndex;
        end
        for i=startIndex,endIndex do
            local itemCfg = shop:getNodeAt(i-1)
            local value1 = itemCfg:getNodeAt(0):toInt();
            local value2 = itemCfg:getNodeAt(1):toInt();
            if value1 == 1 then--buff
                local maze_buff_cfg_item = maze_buff_cfg:getNodeWithKey(tostring(value2))
                if maze_buff_cfg_item then
                    createRewardItem(nil,string_helper.game_util.getBuff .. maze_buff_cfg_item:getNodeWithKey("name"):toStr())
                end
            elseif value1 == 2 then--道具
                local maze_item_cfg_item = maze_item_cfg:getNodeWithKey(tostring(value2))
                if maze_item_cfg_item then
                    createRewardItem(nil,string_helper.game_util.getItem .. maze_item_cfg_item:getNodeWithKey("name"):toStr())
                end
            elseif value1 == 3 then
                createRewardItem(nil,string_helper.game_util.hp .. value2 .. "%")
            elseif value1 == 4 then
                createRewardItem(nil,string_helper.game_util.hp .. value2)
            end
        end
    end
end

--[[
    更改精灵显示
]]
function M.setSpriteDisplayBySpriteFrameName( self, spr, sprFrameName )
    if not spr or not sprFrameName then return end
    local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(sprFrameName)
    if tempFrame then
        spr:setDisplayFrame(tempFrame)
    end
end


--[[
    数字转换成中文数字
]]
function M.convertNum2Chinese( self, num )
    if num == 0 then return string_helper.game_util.zero end     -- 直接返回
    local chineseCodes = string_helper.game_util.chineseCodes
    local chineseUnit = string_helper.game_util.chineseUnit
    local strnum = tostring(num)
    local conv = function( pos, cur )
        if cur == "0" then return string_helper.game_util.zero end
        return chineseCodes[tonumber(cur)] .. chineseUnit[tonumber(pos)]
    end
    local fore_word  = ""
    local perstrnum = strnum
    for i=1, string.len(strnum) do
         local cur = string.sub(perstrnum, -1, -1)
         perstrnum = string.sub(perstrnum, 1, -2)
         if cur then
            local oneWord = conv(i , cur )
            if oneWord ~= string_helper.game_util.zero or fore_word ~= "" then  -- 最后一位不会为零
                fore_word = oneWord .. fore_word 
            end
         end
    end
    srtt = string.gsub(fore_word, "零零", string_helper.game_util.zero)  -- 两个零 替换成一个零
    if num > 9 and num < 20 then
        srtt = string.gsub(fore_word, "一", "", 1)  -- 一十二 替换成 十二，只替换掉第一个一
    end
    return srtt
end

--[[
    获取转生等级描述
]]
function M.getBreakLevelDes( self, level )
    local level_des = {"I","II","III","IV","V","VI","VII","VIII","IX","X"}
    return level_des[level] or ""
end

--[[
    设置上下移动动作
]]
function M.setNodeUpAndDownMoveAction( self, tempSprite)
    if tempSprite then
        local pX,pY = tempSprite:getPosition();
        local animArr = CCArray:create();
        animArr:addObject(CCMoveTo:create(1,ccp(pX,pY+1)));
        animArr:addObject(CCMoveTo:create(1,ccp(pX,pY-1)));
        tempSprite:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    end
end

--[[
    助威属性加成属性计算
]]
function M.getAssistantAttrTab( self, posIndex, assistantEffectItem, assistant_cfg_item, newAttrFlag)
    local attrValueTab,newAttrValueTab = {},{}
    local refreshFlag = false
    local assistant_cfg = getConfig(game_config_field.assistant)
    assistant_cfg_item = assistant_cfg_item or assistant_cfg:getNodeWithKey(tostring(posIndex))
    if assistant_cfg_item then
        local assistant_random_cfg = getConfig(game_config_field.assistant_random)
        assistantEffectItem = assistantEffectItem or {}
        local active_status = assistantEffectItem.active_status or "-1"--是否激活助威属性
        local ass_random_id = assistantEffectItem.ass_random_id or 0 --第一属性刷新后的值，刷新之前取att_value
        local limit_character_id = assistantEffectItem.limit_character_id or 0 --缘助威刷新后的值
        local two_switch = assistantEffectItem.two_switch or 0 --第二属性是否开启 0为未开启
        local two_value = assistantEffectItem.two_value or 0 --第二属性刷新后的值

        local max_ability1 = assistant_cfg_item:getNodeWithKey("max_ability1")--第一属性最大值
        max_ability1 = max_ability1 and max_ability1:toInt() or 0
        local max_ability2 = assistant_cfg_item:getNodeWithKey("max_ability2")--第二属性最大值
        max_ability2 = max_ability2 and max_ability2:toInt() or 0
        local att_type = assistant_cfg_item:getNodeWithKey("att_type")--第一属性
        att_type = att_type and att_type:toInt() or 0
        local att_value,quality = 0,0
        if ass_random_id == 0 then
            att_value = assistant_cfg_item:getNodeWithKey("att_value")--第一属性加成值
            att_value = att_value and att_value:toInt() or 0
        else
            local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(ass_random_id))
            if assistant_random_cfg_item then
                att_value = assistant_random_cfg_item:getNodeWithKey("ability")
                att_value = att_value and att_value:toFloat() or 0
                att_value = tonumber(string.format("%.1f",att_value))
                quality = assistant_random_cfg_item:getNodeWithKey("quality")
                quality = quality and quality:toInt() or 0
            end
        end
        table.insert(attrValueTab,{att_type = att_type,att_value = att_value,open = 1,quality = quality,att_name = "ability1",max_value = max_ability1})
        local card_ability = assistant_cfg_item:getNodeWithKey("card_ability")--阵缘属性
        card_ability = card_ability and card_ability:toInt() or 0
        local card_value = assistant_cfg_item:getNodeWithKey("card_value")--阵缘属性加成值
        card_value = card_value and card_value:toInt() or 0
        local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(limit_character_id))
        local _,itemCfg = game_data:getAssTeamCardDataByPos(posIndex)
        local character_detail_cfg = getConfig(game_config_field.character_detail)
        local character_id,quality = 0,0
        local character_name,active = string_helper.game_util.noCfg,0
        if assistant_random_cfg_item then
            character_id = assistant_random_cfg_item:getNodeWithKey("ability")
            character_id = character_id and character_id:toInt() or 0
            quality = assistant_random_cfg_item:getNodeWithKey("quality")
            quality = quality and quality:toInt() or 0
            local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id))
            if heroCfg then
                character_name = heroCfg:getNodeWithKey("name"):toStr()
                if itemCfg then
                    local character_ID1 = itemCfg:getNodeWithKey("character_ID"):toInt()
                    local character_ID2 = heroCfg:getNodeWithKey("character_ID"):toInt()
                    if character_ID1 == character_ID2 then
                        active = 1
                    end 
                end
            end
        end
        table.insert(attrValueTab,{att_type = card_ability,att_value = card_value,open = limit_character_id,quality = quality,att_name = "card",character_id = character_id,character_name = character_name,active = active,max_value = 0})
        local att_type2 = assistant_cfg_item:getNodeWithKey("att_type2")--第二属性
        att_type2 = att_type2 and att_type2:toInt() or 0
        local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(two_value))
        local ability,quality = 0,0
        if assistant_random_cfg_item then
            ability = assistant_random_cfg_item:getNodeWithKey("ability")
            ability = ability and ability:toFloat() or 0
            ability = tonumber(string.format("%.1f",ability))
            quality = assistant_random_cfg_item:getNodeWithKey("quality")
            quality = quality and quality:toInt() or 0
        end
        table.insert(attrValueTab,{att_type = att_type2,att_value = ability,open = two_switch,quality = quality,att_name = "ability2",max_value = max_ability2})

        newAttrFlag = newAttrFlag == nil and false or newAttrFlag--是否计算刷新的属性值
        if newAttrFlag then
            local refresh = assistantEffectItem.refresh or {}--刷新的临时属性值
            local ability1 = refresh.ability1 or 0
            local card = refresh.card or 0
            local ability2 = refresh.ability2 or 0
            if (ability1 + card + ability2) > 0 then
                refreshFlag = true
            end
            local att_value,quality = 0,0
            local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(ability1))
            if assistant_random_cfg_item then
                att_value = assistant_random_cfg_item:getNodeWithKey("ability")
                att_value = att_value and att_value:toFloat() or 0
                att_value = tonumber(string.format("%.1f",att_value))
                quality = assistant_random_cfg_item:getNodeWithKey("quality")
                quality = quality and quality:toInt() or 0
            end
            table.insert(newAttrValueTab,{att_type = att_type,att_value = att_value,open = 1,quality = quality,att_name = "ability1",max_value = max_ability1})

            local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(card))
            local character_id,quality = 0,0
            local character_name,active = string_helper.game_util.noCfg,0
            if assistant_random_cfg_item then
                character_id = assistant_random_cfg_item:getNodeWithKey("ability")
                character_id = character_id and character_id:toInt() or 0
                quality = assistant_random_cfg_item:getNodeWithKey("quality")
                quality = quality and quality:toInt() or 0
                local heroCfg = character_detail_cfg:getNodeWithKey(tostring(character_id))
                if heroCfg then
                    character_name = heroCfg:getNodeWithKey("name"):toStr()
                    if itemCfg then
                        local character_ID1 = itemCfg:getNodeWithKey("character_ID"):toInt()
                        local character_ID2 = heroCfg:getNodeWithKey("character_ID"):toInt()
                        if character_ID1 == character_ID2 then
                            active = 1
                        end 
                    end
                end
            end
            table.insert(newAttrValueTab,{att_type = card_ability,att_value = card_value,open = limit_character_id,quality = quality,att_name = "card",character_id = character_id,character_name = character_name,active = active,max_value = 0})
            local assistant_random_cfg_item = assistant_random_cfg:getNodeWithKey(tostring(ability2))
            local ability,quality = 0,0
            if assistant_random_cfg_item then
                ability = assistant_random_cfg_item:getNodeWithKey("ability")
                ability = ability and ability:toFloat() or 0
                ability = tonumber(string.format("%.1f",ability))
                quality = assistant_random_cfg_item:getNodeWithKey("quality")
                quality = quality and quality:toInt() or 0
            end
            table.insert(newAttrValueTab,{att_type = att_type2,att_value = ability,open = two_switch,quality = 0,att_name = "ability2",max_value = max_ability2})
        end
    end
    return attrValueTab,newAttrValueTab,refreshFlag
end
function M.createMulitLabel( self, boardNode, params, labelType, touchPriority  )
    if not boardNode then
        cclog2(" will add a scroll label ,but parent Node is nil")
        return
    end
    touchPriority = touchPriority or -128
    local boardSize = boardNode:getContentSize()
    cclog2(boardSize.width, "boardSize.width  ======     ")
    cclog2(boardSize.height, "boardSize.width  ======     ")
    params = params or {}
    if not boardSize then return end
    local text = params.text or ""
    local fontSize = params.fontSize or 12
    local verticalTextAlignment = params.verticalTextAlignment or kCCVerticalTextAlignmentTop
    local textAlignment = params.textAlignment or kCCTextAlignmentCenter
    local color = params.color or ccc3(221,221,192)
    local tempLabel = nil
    if labelType == "labelBMFont" then
        tempLabel = game_util:createRichLabelTTF({text = text,dimensions = CCSizeMake(boardSize.width  ,0),textAlignment = textAlignment,
            verticalTextAlignment = verticalTextAlignment,color = color,fontSize = fontSize})
    else 
        tempLabel = game_util:createLabelTTF({text = text, textAlignment = textAlignment,
            verticalTextAlignment = verticalTextAlignment,color = color,fontSize = fontSize})
        tempLabel:setDimensions(CCSizeMake(boardSize.width, 0))
    end
    if not tempLabel then return end
    local tempSize = tempLabel:getContentSize();
    if tempSize.height < boardSize.height then
        cclog2(" not scroll text ")
        tempLabel:setAnchorPoint(ccp(0.5,0.5))
        tempLabel:setPosition(ccp(boardSize.width * 0.5, boardSize.height * 0.5 ))
        boardNode:addChild(tempLabel)
        return nil, tempLabel
    end
    cclog2(" is scroll text ")
    local scrollView = CCScrollView:create(boardSize)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:getContainer():removeAllChildrenWithCleanup(true)
    tempLabel:setAnchorPoint(ccp(0,0.99))
    tempLabel:setPosition(ccp(0, 0))
    scrollView:setContentSize(CCSizeMake(boardSize.width + 15, tempSize.height))
    scrollView:setContentOffset(ccp(0, boardSize.height - tempSize.height), false)
    scrollView:addChild(tempLabel, 0, 998)
    boardNode:addChild(scrollView)
    scrollView:setTouchEnabled(false)




    local leftArrow = CCSprite:createWithSpriteFrameName("o_public_leftArrow.png")
    leftArrow:setScale(0.2)
    local signSize = leftArrow:getContentSize()
    leftArrow:setRotation(270)
    leftArrow:setAnchorPoint(ccp(1,0))
    leftArrow:setPosition(boardSize.width - 5, signSize.height * 0.2);
    boardNode:addChild(leftArrow)

    -- self.setNodeUpAndDownMoveAction(leftArrow)

    local animArr = CCArray:create();
    animArr:addObject(CCMoveBy:create( 1, ccp(0, 3)));
    animArr:addObject(CCMoveBy:create( 1, ccp(0, -3)));
    leftArrow:runAction(CCRepeatForever:create(CCSequence:create(animArr)));


    local touchLayer = CCLayer:create()
    boardNode:addChild(touchLayer)
    local touchBeginPoint = nil
    local touchPoint = nil
    local beginTime = nil
    local lastTime = nil
    local maxY = boardSize.height * 0.33
    local minY = boardSize.height - tempSize.height
    local mminY = minY * 1.33
    local function resetScrollViewOffset( offx, offy, draging, withAnimate )
        withAnimate = withAnimate or false
        local cx, cy = scrollView:getContainer():getPosition();
        local offsetY = math.min(cy + offy, maxY )
        offsetY = math.max(offsetY, mminY )
        if not draging then
            withAnimate = true
            if offsetY >= 0 then
                offsetY = 0
                leftArrow:setVisible(false)
            elseif offsetY <= minY then
                offsetY = minY
                leftArrow:setVisible(true)
            else
                leftArrow:setVisible(true)
            end
        end
        -- local offsetY = math.min(cy + offy, boardSize.height * 0.33 )
        scrollView:setContentOffset(ccp(cx, offsetY ), withAnimate)
    end


    local function onTouchBegan(x, y)
        local realPos = boardNode:getParent():convertToNodeSpace(ccp(x,y));
        if not boardNode:boundingBox():containsPoint(realPos) then  -- 
            return false
        end
        -- cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        touchBeginPoint = {x = x, y = y}
        touchPoint = {x = x, y = y}
        lastTime = os.time()
        return true
    end

    local function onTouchMoved(x, y)
        -- cclog("onTouchMoved: %0.2f, %0.2f", x, y)
        if touchBeginPoint then
            -- cclog("offsetX ==========================" .. offsetX)
            -- tableView:getContainer():setPositionX(offsetX);
            resetScrollViewOffset(0, y - touchPoint.y, true, false)
            touchPoint = {x = x, y = y}
            lastTime = os.time()
        end
    end

    local function onTouchEnded(x, y)
        -- cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        -- galleryLayer:stopAllActions();
        -- local distance = x - touchBeginPoint.x;
        -- if distance > 1 or distance < -1 then
        --     adjustScrollView(distance/math.max(0.1,(os.time() - beganTime)));
        -- end

        local dt = os.time() - lastTime
        local dy = touchPoint.y - y
        cclog2(dy, "move end and dy ====  ")
        -- if dy < 0.1 then return end
        local s = dy / dt * 2
        resetScrollViewOffset(0, 0, false, true)
        touchBeginPoint = nil
        touchPoint = nil
        beganTime = nil
    end
    
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end

    local function refreshScrollView( dis_move )



    end

    
    touchLayer:registerScriptTouchHandler(onTouch,false, touchPriority-1 or -128,false)
    touchLayer:setTouchEnabled(true)
    return scrollView, tempLabel
end

--[[
    判断配置里面的版本号是否和 指定的版本号一致
    itemCfg  配置
    version  指定的版本号
    versionKey  配置里面的版本号字段名称
]]
function M.compareItemCfgVersion( self, itemCfg, version, versionKey )
    if not version then return false end
    if not itemCfg then return false end
    versionKey = versionKey and tostring( versionKey ) or "version"
    if itemCfg:getNodeWithKey( versionKey ) and itemCfg:getNodeWithKey( versionKey ):toStr() == tostring(version) then
        return true
    end
    return false
end

return M;
    