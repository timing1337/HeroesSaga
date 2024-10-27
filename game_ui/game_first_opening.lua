--- 第一次进游戏的开场 

local game_first_opening = {
    m_root_layer = nil,
    m_animEndFlag = nil,
    m_anim_node = nil,
    m_animIndex = nil,
    m_openingAnim = nil,
    m_speedFlag = nil,

    m_anim_falg = nil,
    m_last_anim = nil,
};
--[[--
    销毁ui
]]
function game_first_opening.destroy(self)
    -- body
    cclog("-----------------game_first_opening destroy-----------------");
    self.m_root_layer = nil;
    self.m_animEndFlag = nil; 
    self.m_anim_node = nil;
    self.m_animIndex = nil;
    self.m_openingAnim = nil;
    self.m_speedFlag = nil;
    self.m_anim_falg = nil;
    self.m_last_anim = nil;
end
--[[--
    返回
]]
function game_first_opening.back(self,type)

end
--[[--
    读取ccbi创建ui
]]
function game_first_opening.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--名字随机
        elseif btnTag == 2 then--进入游戏

        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);

    ccbNode:openCCBFile("ccb/ui_opening_anim.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    local ext_label_node = ccbNode:nodeForName("ext_label_node")
    local open_text = ccbNode:labelTTFForName("open_text")
    open_text:setVisible(false)

    -- local sprite_continue = ccbNode:spriteForName("sprite_continue")
    local sprite_continue = CCSprite:createWithSpriteFrameName("opening_text_continue.png")
    local visibleSize = CCDirector:sharedDirector():getVisibleSize();
    sprite_continue:setPosition(ccp(visibleSize.width*0.84,visibleSize.height*0.11))
    ccbNode:addChild(sprite_continue)
    sprite_continue:runAction(game_util:createRepeatForeverFade());

    sprite_continue:setVisible(false)
    -- self.m_anim_node = ccbNode:nodeForName("m_anim_node")

    self:enterFirstBattle();--開始戰鬥2
    --[[
        1.4個動畫和一個繼續的動畫，4個動畫播放完或者繼續動畫播放完，轉到繼續動畫
        2.播繼續動畫的時候，點擊則跳轉到下一個動畫
    ]]
--[[
    local function textEndFunc()
        sprite_continue:setVisible(true)
    end
    --改為播放完文字直接進入戰鬥
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        elseif eventType == "ended" then
            if sprite_continue:isVisible() == true then
            -- if self.m_anim_falg == "continue_anim" then
                sprite_continue:setVisible(false)
                if self.m_last_anim == "continue_anim" then
                    -- ccbNode:runAnimations("opening_anim")
                    -- self.m_last_anim = "opening_anim"
                    open_text:setVisible(false)
                    ext_label_node:removeAllChildrenWithCleanup(true)
                    -- self:gameGuide("send","1",1)--完成1
                    game_guide_controller:setGuideData("1",1)--完成1
                    -- self:gameGuide("drama","1",2)--開始2
                    self:enterFirstBattle();--開始戰鬥2
                    self.m_animEndFlag = true;
                elseif self.m_last_anim == "opening_anim" then
                    
                --     ccbNode:runAnimations("opening_anim_2")
                --     self.m_last_anim = "opening_anim_2"
                -- elseif self.m_last_anim == "opening_anim_2" then
                --     ccbNode:runAnimations("opening_anim_3")
                --     self.m_last_anim = "opening_anim_3"
                -- elseif self.m_last_anim == "opening_anim_3" then
                --     ccbNode:runAnimations("opening_anim_4")
                --     self.m_last_anim = "opening_anim_4"
                -- elseif self.m_last_anim == "opening_anim_4" and self.m_animEndFlag == false then--播放完成
                --     -- self:gameGuide("send","1",1)--完成1
                --     game_guide_controller:setGuideData("1",1)--完成1
                --     -- self:gameGuide("drama","1",2)--開始2
                --     self:enterFirstBattle();--開始戰鬥2
                --     self.m_animEndFlag = true;
                end
            else
                if self.m_last_anim == "continue_anim" then
                    --刪除播放Label 加載label
                    ext_label_node:removeAllChildrenWithCleanup(true)
                    open_text:setVisible(true)
                    textEndFunc()
                end
            end
        end
    end

    local function openAnmiCallFunc(animName)
        -- ccbNode:runAnimations("continue_anim")
        -- self.m_anim_falg = "continue_anim"
        if self.m_last_anim == "continue_anim" then--播完文字自动进入
            -- ccbNode:runAnimations("opening_anim")
            -- self.m_last_anim = "opening_anim"
            -- ext_label_node:removeAllChildrenWithCleanup(true)
            textEndFunc()
        else
            cclog("truetruetruetruetruetrue")
            sprite_continue:setVisible(true)
        end
    end

    ccbNode:registerAnimFunc(openAnmiCallFunc)

    -- ccbNode:runAnimations("opening_anim")
    -- self.m_last_anim = "opening_anim"

    ccbNode:runAnimations("continue_anim")
    -- self.m_last_anim = "continue_anim"

    local ext_label = ExtLabelTTF:create(string_config.m_open_text,TYPE_FACE_TABLE.Arial_BoldMT,14,CCSizeMake(350,160),0.07)

    ext_label:registerScriptHandler(textEndFunc)

    ext_label:setAnchorPoint(ccp(0.5,0.5))
    ext_label:setPosition(ccp(0,0))
    ext_label_node:removeAllChildrenWithCleanup(true)
    ext_label_node:addChild(ext_label,10,10)
    self.m_last_anim = "continue_anim"

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,1);
    self.m_root_layer:setTouchEnabled(true);
]]  
    ccbNode:runAnimations("continue_anim")
    return ccbNode;
end

function game_first_opening.createOpeningAnim(self,endAnim)
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if theLabelName == "impact1" then
            animNode:setRhythm(1);
            animNode:playSection("impact2")
            self.m_animIndex = 2;
            self.m_speedFlag = false;
        elseif theLabelName == "impact2" then
            animNode:setRhythm(1);
            self.m_speedFlag = false;
            animNode:playSection("impact3")
            self.m_animIndex = 3;
            self.m_speedFlag = false;
        elseif theLabelName == "impact3" then
            animNode:setRhythm(1);
            animNode:playSection("impact4")
            self.m_animIndex = 4;
            self.m_speedFlag = false;
        elseif theLabelName == "impact4" then
            animNode:setRhythm(1);
            animNode:playSection("impact5")
            self.m_speedFlag = false;
            self.m_animIndex = 5;
        elseif theLabelName == "impact5" then
            animNode:setRhythm(1);
            animNode:playSection("impact6")
            self.m_animIndex = 6;
            self.m_speedFlag = false;
        elseif theLabelName == "impact6" then
            endAnim();
        end
    end
    local animFile = "kaichang";
    local mAnimNode = game_util:createSortNode(animFile .. ".swf.sam", 0, animFile.. ".plist");
    local function anchorCallFunc(animNode , mId , strValue)
        cclog("strValue ===== " .. tostring(strValue))
        if strValue == nil or strValue == "" then return end
        local firstValue = string.sub(strValue,0,1)
        if firstValue == "{" then
            local strTable = json.decode(strValue);
            if strTable.type == "wav" then--
                local effectFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sound/attack_effect/" .. tostring(strTable.res)..".wav");
                local existFlag = util.fileIsExist(effectFileFullPath)
                if existFlag == true then
                    game_sound:playAttackSound(effectFileFullPath,false);
                end
            end
        end
    end
    if mAnimNode then
        if audio.isMusicPlaying() then
            audio.stopMusic(false);
        end
        mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:registerScriptAnchor(anchorCallFunc);
        mAnimNode:playSection("impact1");
        mAnimNode:setRhythm(1);
        mAnimNode:setAnchorPoint(ccp(0.5,0.5));
        self.m_animIndex = 1;
    end
    return mAnimNode;
end

--[[--
    刷新ui
]]
function game_first_opening.enterFirstBattle(self)
    local function enterFunc()
        local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("battleData.temp");
        cclog("battleData fullPath ==" .. tostring(fullPath))
        local readData = util.readFile(fullPath);
        if readData then
            game_data:setBattleType("game_first_opening");
            local gameData = util_json:new(readData);
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData});
            self:destroy();
            gameData:delete();
        else
            local function endCallFunc()
                self:destroy();
            end
            game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
        end
    end
    enterFunc();
end

--[[--
    刷新ui
]]
function game_first_opening.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_first_opening.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_animEndFlag = false;
    game_guide_controller:setGuideData("1",1);
    self.m_animIndex = 0;
    self.m_speedFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_first_opening.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

function game_first_opening.gameGuide(self,guideType,guide_team,guide_id,t_params)
    -- if not game_guide_controller:getGuideCompareFlag(guide_team,guide_id) then return end
    local id = game_guide_controller:getId(guide_team,guide_id);
    t_params = t_params or {};
    if guideType == "show" then

    elseif guideType == "send" then
        game_guide_controller:sendGuideData(guide_team,guide_id)
    elseif guideType == "drama" then
        -- if guide_team == "1" and id == 2 then
        --     local function endCallFunc()
        --         self:gameGuide("send","1",2)
        --         self:enterFirstBattle();
        --     end
        --     t_params.guideType = "drama";
        --     t_params.endCallFunc = endCallFunc;
        --     game_guide_controller:showGuide(guide_team,guide_id,t_params)
        -- end
    end
end

return game_first_opening;