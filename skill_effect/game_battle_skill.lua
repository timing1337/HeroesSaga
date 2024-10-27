--- 战斗技能

local game_battle_skill = {
	  params = nil,
    m_battle_layer = nil,       --战斗层
    m_attack_object = nil,      --攻击对象
    m_aim_object_table = nil,   --所有被攻击对象（包括加血减血）table表
    m_enemy_object_table = nil, --被攻击减血对象table表
    m_add_object_table = nil,   --被攻击加血对象table表
    m_startPosTable = nil,      --起始位置
    m_endPosTable = nil,        --结束位置
    m_realPos = nil,            --攻击对象的原始位置
    m_attackPosTable = nil,     --攻击的位置
    m_uReference = nil,         --战斗标示计数
    m_tableAddHp = nil,          --加血  k:位置 value:加血量
    m_hurtValueTable = nil,
    m_addValueTable = nil,
    m_attackCenterPosTable = nil,
    m_skillName = nil,
    m_attack_effect = nil,
    m_anchor_index = nil,
    m_anchor_num = nil,
    m_isRealPlay = false,
    m_nstate = nil,
    m_card = nil,
    m_skill_type = nil,
    m_camp = nil,
    m_skillid = nil,
};
--[[--
    销毁
]]
function game_battle_skill.destroy(self)
    self.params = nil;
    self.m_battle_layer = nil;
    self.m_attack_object = nil;
    self.m_aim_object_table = nil
    self.m_enemy_object_table = nil;
    self.m_add_object_table = nil;
    self.m_startPosTable = nil;
    self.m_endPosTable = nil;
    self.m_realPos = nil;
    self.m_attackPosTable = nil;
    self.m_uReference = nil;
    self.m_tableAddHp = nil;
    self.m_hurtValueTable = nil;
    self.m_addValueTable = nil;
    self.m_attackCenterPosTable = nil;
    self.m_skillName = nil;
    self.m_attack_effect = nil;
    self.m_anchor_index = nil;
    self.m_anchor_num = nil;
    self.m_isRealPlay = false;
    self.m_nstate = nil;
    self.m_card = nil;
    self.m_skill_type = nil;
    self.m_camp = nil;
    self.m_skillid = nil;
end
--[[--
    计数加一
]]
function game_battle_skill.retain(self,fromStr)
    if self.m_uReference == nil then return end
    self.m_uReference = self.m_uReference + 1;
    --cclog("self.m_uReference =============retain==========" .. self.m_uReference .. " ; fromStr =" .. tostring(fromStr));
end
--[[--
    计数减一
]]
function game_battle_skill.release(self,fromStr)
    if self.m_uReference == nil then return end
    self.m_uReference = self.m_uReference - 1;
    --cclog("self.m_uReference ============release===========" .. self.m_uReference .. " ; fromStr =" .. tostring(fromStr));
    if self.m_uReference <= 0 then
        self:skillOver();
    end
end

function game_battle_skill.skillOvertest(self)
end
--[[--
    技能播放完
]]
function game_battle_skill.skillOver(self)
    cclog("function:------------------------skillOver");
    if self.m_uReference == nil then 
        return 
    end
    cclog("skill end ===============skillOver======================skill name = " .. tostring(self.m_skillName));
    if (self.m_skill_type == "skill_hero") then
      cclog("skill end ============== skill is hero skill " .. tostring(self.m_anchor_num) .. " index:" .. tostring(self.m_anchor_index));
        self.params.game_battle_table:useHeroSkill(self.m_skillid,self.m_camp)
    end
    if (self.m_anchor_num == nil or self.m_anchor_num == 0) then
        self:addHp();
    end
    cclog("---------yock skillOver ------" .. tostring(self.m_skillName) .. " " .. tostring(self.m_anchor_num));
    if (self.m_anchor_num == nil or self.m_anchor_num == 0) and self.m_enemy_object_table then
      cclog("-----------yock skillOver-----------1" .. tostring(self.m_skillName));
    --if self.m_enemy_object_table then
        table.foreach(self.m_enemy_object_table, function(i, v)
            --local i = 1
            --local v = self.m_enemy_object_table[1]
            local hpValue = self.m_hurtValueTable[i];
            if hpValue == nil or hpValue == 0 or ((self.m_skill_type=="skill_hero") and (self.m_anchor_index>0))then 
                cclog("-----------yock skillOver-----------2" .. tostring(self.m_skillName));
                hpValue = 0
                local currentHp = v.bloodBar:getCurValue();
                if(currentHp<=0)then
                  self.params.game_battle_table:playSection(v.index,anim_label_name_cfg.siwang);
                end
            else 
                local currentHp = v.bloodBar:getCurValue();
                local tempHp = currentHp - math.floor(hpValue);
                -- cclog("skill hpValue ======================" .. currentHp .. "-" .. hpValue .. "=" .. tempHp .. " ; id == " .. v.animNode:getId());
                v.bloodBar:setCurValue(tempHp,false);
                --[[--if v.animNode:getCurSectionName() ~= anim_label_name_cfg.daiji then
                   game_util:playSection(v.animNode,anim_label_name_cfg.daiji,v.aniState);
                end]]--
                cclog("-------- yock ---------" .. tostring(tempHp));
                if(tempHp <= 0) then
                    cclog("noanchorsiwang")
                    -- v.deathRef = 2;
                    -- game_util:playSection(v.animNode,anim_label_name_cfg.siwang,v.aniState); 
                    self.params.game_battle_table:playSection(v.index,anim_label_name_cfg.siwang);
                else
                    cclog("noanchorshoushang")
                    self.params.game_battle_table:hitEffectAnchorCall(v,1);
                end
                --game_util:createEffectAnimAddToParent(v.animNode,"shouji_1",1);
                
                self.params.game_battle_table:hurtLable(v.animNode,- math.floor(hpValue),1,0);
                -- self.params.game_battle_table:hurtLableAll(v.animNode, - math.floor(hpValue) , 1 , 1);
                --self.params.game_battle_table:hitEffectAnchorCall(v,1);
                v.animNode:setRhythm(public_config.action_rythm);
            end
       end);
    end
    if self.m_attack_object then
        if self.m_nstate ~= nil then
            self.m_attack_object.aniState = self.m_nstate
        end
        local animNode = self.m_attack_object.animNode
        animNode:stopAllActions();
        --animNode:setOpacity(0);
        --animNode:setPosition(self.m_realPos);
        local function moveEnd(  )
          -- body
          self.params.game_battle_table:setCanGo(true,"skillOver");
          self:destroy();
        end
        local tempActMove = CCMoveTo:create(0.2*public_config.action_rythm,self.m_realPos);
        local tempActScale = CCScaleTo:create(0.2,1 * public_config.anim_scale,1 * public_config.anim_scale);
        local tempActSpawn = CCSpawn:createWithTwoActions(tempActMove,tempActScale);
        local tempActCallFun = CCCallFunc:create(moveEnd);
        local tempActSequence = CCSequence:createWithTwoActions(tempActSpawn,tempActCallFun);
        -- animNode:runAction(CCMoveTo:create(0.2,self.m_realPos));
        -- animNode:runAction(CCScaleTo:create(0.2,1 * public_config.anim_scale,1 * public_config.anim_scale));
        animNode:runAction(tempActSequence);
        animNode:registerScriptTapHandler(self.params.game_battle_table.animEnd);
        animNode:registerScriptAnchor(self.params.game_battle_table.anchorCallFunc);
        animNode:setRhythm(public_config.action_rythm);
        game_util:playSection(animNode,anim_label_name_cfg.daiji,self.m_attack_object.aniState);
    else
        self.params.game_battle_table:setCanGo(true,"skillOver");
        self:destroy();
    end
    -- self.params.game_battle_table.m_battle_down_layer:removeAllChildrenWithCleanup(true);
    -- self.params.game_battle_table.m_battle_up_layer:removeAllChildrenWithCleanup(true);

    -- changed by yock in 2014.1.5 17:00
    -- local tempid = self.params.m_tempid;
    -- local tempdid = self.params.m_tempdid;
    -- local spc = self.params.m_spc;
    -- game_util:testShowSortInfo(tempid,tempdid,spc,"over")

    --self.params.game_battle_table:refreshSpeedTableAndUi(false,tempid,tempdid,spc);
    
    
    -- local function delayCallFunc()
    --   self.params.game_battle_table:setCanGo(true,"skillOver");
    --   self:destroy();
    -- end
    -- performWithDelay(self.m_battle_layer,delayCallFunc,1);
end

--[[--
    加血
]]
function game_battle_skill.addHp(self)
    cclog("function:------------------------addHp");
    if self.m_tableAddHp == nil then 
      cclog("----------------m_tableAddHp is nil");
        return 
    end
    for posIndex,addHpValue in pairs(self.m_tableAddHp) do
        local add_hp_object,_ = self.params.game_battle_table:getAnimTabAndPosByIndex(posIndex,0);
        if add_hp_object then
            cclog("---------------add_hp_object has node  hp:" .. tostring(addHpValue));
            add_hp_object.bloodBar:setCurValue(add_hp_object.bloodBar:getCurValue() + tonumber(addHpValue),false);
            self.params.game_battle_table:hurtLable(add_hp_object.animNode,tonumber(addHpValue),1,0);
            -- self.params.game_battle_table:hurtLableAll(add_hp_object.animNode , tonumber(addHpValue) , 1 , 1);
        end
    end
end
--[[--
    
]]
function game_battle_skill.moveAnimNodeToCenter(self,t_params)
    cclog("function:------------------------moveAnimNodeToCenter");
    local winSize = CCDirector:sharedDirector():getWinSize();
    local anim_table = t_params.anim_table;
    local posY = t_params.attackPos.y--anim_table.animNode:getPositionY();
    t_params.moveToPos = ccp(winSize.width*0.5,posY);
    self:moveAnimNode(t_params);
end

--复位
function game_battle_skill.animAttackerPositionReset(self)
    cclog("function:------------------------animAttackerPositionReset");
    self.m_attack_object.animNode:setPosition(self.m_realPos);
end
--[[--
    移动
]]
function game_battle_skill.moveAnimNode(self,t_params)
    cclog("function:------------------------moveAnimNode");
    local delay_time = t_params.delay_time;
    local anim_table = t_params.anim_table;
    local play_time = t_params.play_time;
    local function tickDelayFunc()
        anim_table.animNode:runAction(CCMoveTo:create(play_time*public_config.action_rythm,t_params.moveToPos));
        local function tickDelayFunc2()
            if t_params.animEndCallFunc ~= nil then
                t_params.animEndCallFunc();
            end
            self:release("moveAnimNode");
        end
        performWithDelay(self.m_battle_layer, tickDelayFunc2, play_time);
        self:release("moveAnimNode");
    end
    performWithDelay(self.m_battle_layer, tickDelayFunc, delay_time);
    self:retain("moveAnimNode");
    self:retain("moveAnimNode");
end

function game_battle_skill.moveToAnimNode(self,t_params)
    cclog("function:------------------------moveToAnimNode")
   local delay_time = t_params.delay_time;
   local anim_table = t_params.anim_table;
   local play_time = t_params.play_time;
   local animArr = CCArray:create();
   animArr:addObject(CCMoveTo:create(play_time*public_config.action_rythm,t_params.moveToPos));
   animArr:addObject(CCCallFunc:create(t_params.animEndCallFunc));
   anim_table.animNode:runAction(CCSequence:create(animArr));
end

function game_battle_skill.scaleToAnimNode(self,t_params)
    cclog("function:------------------------scaleToAnimNode");
   local delay_time = t_params.delay_time;
   local anim_table = t_params.anim_table;
   local play_time = t_params.play_time;
   anim_table.animNode:setScaleX(t_params.sscaleX);
   anim_table.animNode:setScaleY(t_params.sscaleY);
   local animArr = CCArray:create();
   animArr:addObject(CCScaleTo:create(play_time,t_params.escaleX,t_params.escaleY));
   animArr:addObject(CCCallFunc:create(t_params.animEndCallFunc));
   anim_table.animNode:runAction(CCSequence:create(animArr));
end

function game_battle_skill.FadeAnimNode(self,t_params)
    cclog("function:------------------------FadeAnimNode");
   local delay_time = t_params.delay_time;
   local anim_table = t_params.anim_table;
   local play_time = t_params.play_time;
   local animArr = CCArray:create();
   if(t_params.type == 0) then
      animArr:addObject(CCFadeIn:create(play_time));
   else
      animArr:addObject(CCFadeOut:create(play_time)); 
   end
   animArr:addObject(CCCallFunc:create(t_params.animEndCallFunc));
   anim_table.animNode:runAction(CCSequence:create(animArr));
end

function game_battle_skill.setFlipX(self,isFlipX)
    cclog("function:------------------------setFlipX");
   self.m_attack_object.animNode:setFlipX(isFlipX)
end

function game_battle_skill.moveByAnimNode(self,t_params)
    cclog("function:------------------------moveByAnimNode")
   local delay_time = t_params.delay_time;
   local anim_table = t_params.anim_table;
   local play_time = t_params.play_time;
end

local function runFadeSequence(self,t_params,manimNode,mfade_sequence)
    cclog("function:------------------------runFadeSequence");
   local fadeindex  = 0;
   local fade_sequence  = mfade_sequence;
   local fadeCount  = table.getn(fade_sequence);
   local enemy_object_tab = t_params.enemy_object_tab;
   if fadeCount > 0 then
      local function changeAni(animNode)
         fadeindex = fadeindex + 1;
         if(fadeindex <= fadeCount) then
            if(fade_sequence[fadeindex][2] ~= 2) then
               animNode:setOpacity(fade_sequence[fadeindex][1] * 255);
            end
            local aniCircelPlay = function()
               changeAni(animNode);
            end
            performWithFade(animNode,aniCircelPlay,getActionPerformTime(fade_sequence[fadeindex][4] - fade_sequence[fadeindex][3]),fade_sequence[fadeindex][2])
         end
      end
      changeAni(manimNode);
   end
end

local function runScaleSequence(self,t_params,manimNode,mscale_sequence)
    cclog("function:------------------------runScaleSequence");
   local scaleindex  = 0;
   local scale_sequence  = mscale_sequence;
   local scaleCount  = table.getn(scale_sequence);
   local enemy_object_tab = t_params.enemy_object_tab;
   if scaleCount > 0 then
      local function changeAni(animNode)
         scaleindex = scaleindex + 1;
         if(scaleindex <= scaleCount) then
            local sscaleX = scale_sequence[scaleindex][1] * public_config.anim_scale;
            local sscaleY = scale_sequence[scaleindex][2] * public_config.anim_scale;
            local escaleX = scale_sequence[scaleindex][3] * public_config.anim_scale;
            local escaleY = scale_sequence[scaleindex][4] * public_config.anim_scale;
            animNode:setScaleX(sscaleX);
            animNode:setScaleY(sscaleY);
            local aniCircelPlay = function()
                changeAni(animNode);
            end
            performWithScale(animNode,aniCircelPlay,getActionPerformTime(scale_sequence[scaleindex][7] - scale_sequence[scaleindex][6]),escaleX,escaleY)
         end
      end
      changeAni(manimNode);
   end
end

local function runPosSequence(self,t_params,manimNode,mpos_sequence)
    cclog("function:------------------------runPosSequence");
   local posindex  = 0;
   local pos_sequence  = mpos_sequence;
   local posCount  = table.getn(pos_sequence);
   local enemy_object_tab = t_params.enemy_object_tab;
   local nodePos = ccp(0,0)
   local spX,spY
   if(self.m_attack_object) then
       spX,spY = self.m_attack_object.animNode:getPosition();
       nodePos = ccp(spX,spY);
   end
   if(enemy_object_tab ~= nil) then
      cclog("enemy_object_tab.posIndex ============== " .. tostring(enemy_object_tab.posIndex) .. " ; self.m_skillName == " .. self.m_skillName)
      pX,pY  = enemy_object_tab.animNode:getPosition();
   else
      cclog("enemy_object_tab == nil")
      pX = 300;
      pY = 300;
   end
   local enemyPos = ccp(pX,pY);
   local winSize = CCDirector:sharedDirector():getWinSize();
   local camp 
   if(self.m_attack_object) then
       camp = self.m_attack_object.camp 
   else
       camp = self.m_camp
   end
   if posCount > 0 then
      local function changeAni(animNode)
         posindex = posindex + 1;
         if(posindex <= posCount) then
            local spos = ccp(pos_sequence[posindex][1],pos_sequence[posindex][2]);
            local epos = ccp(pos_sequence[posindex][3],pos_sequence[posindex][4]);
            local spostype =  pos_sequence[posindex][5];
            local epostype =  pos_sequence[posindex][6];
            if(spostype == 0) then
               spos.x = spos.x / 960 * winSize.width * public_config.anim_scale * camp + nodePos.x
               spos.y = spos.y / 640 * winSize.height * public_config.anim_scale + nodePos.y - 2
            elseif(spostype == 1) then
               spos.x = spos.x / 960 * winSize.width * public_config.anim_scale * camp + enemyPos.x
               spos.y = spos.y / 640 * winSize.height * public_config.anim_scale + enemyPos.y - 2
            else
               if(camp == 1) then
                  spos.x = spos.x / 960 * winSize.width
               else
                  spos.x = -spos.x / 960 * winSize.width + winSize.width
               end
               spos.y = spos.y / 640 * winSize.height - 2
            end
            math.randomseed(os.time())
            local randomTemp
            if(pos_sequence[posindex][10] ~= nil and pos_sequence[posindex][10] ~= 0) then
               randomTemp = math.random(pos_sequence[posindex][10] * 2) / 960 * winSize.width
               spos.x = spos.x + randomTemp - pos_sequence[posindex][10] / 960 * winSize.width
            end
            if(pos_sequence[posindex][11] ~= nil and pos_sequence[posindex][11] ~= 0) then
               randomTemp = math.random(pos_sequence[posindex][11] * 2) / 640 * winSize.height
               spos.y = spos.y + randomTemp - pos_sequence[posindex][11] / 640 * winSize.height
            end
            animNode:setPosition(spos);
            if(epostype == 0) then
               epos.x = epos.x / 960 * winSize.width * public_config.anim_scale * camp  + nodePos.x
               epos.y = epos.y / 640 * winSize.height * public_config.anim_scale  + nodePos.y - 2
            elseif(epostype == 1) then
               epos.x = epos.x / 960 * winSize.width * public_config.anim_scale * camp  + enemyPos.x
               epos.y = epos.y / 640 * winSize.height * public_config.anim_scale  + enemyPos.y - 2
            else
               if(camp == 1) then
                  epos.x = epos.x / 960 * winSize.width
               else
                  epos.x = -epos.x / 960 * winSize.width + winSize.width
               end
               epos.y = epos.y / 640 * winSize.height - 2
            end
            local height = pos_sequence[posindex][9];
            local aniCircelPlay = function()
                changeAni(animNode);
            end
            if(pos_sequence[posindex][12] ~= nil and pos_sequence[posindex][12] ~= 0) then
               randomTemp = math.random(pos_sequence[posindex][12] * 2) / 960 * winSize.width
               epos.x = epos.x + randomTemp - pos_sequence[posindex][12] / 960 * winSize.width
            end
            if(pos_sequence[posindex][13] ~= nil and pos_sequence[posindex][13] ~= 0) then
               randomTemp = math.random(pos_sequence[posindex][13] * 2) / 640 * winSize.height
               epos.y = epos.y + randomTemp - pos_sequence[posindex][13] / 640 * winSize.height
            end
            --[[--cclog("spostype->"..spostype)
            cclog("epostype->"..epostype)
            cclog("spos x->"..spos.x.."spos y->"..spos.y)
            cclog("epos x->"..epos.x.."epos y->"..epos.y)]]--
            if(height == 0) then
               performWithMove(animNode,aniCircelPlay,getActionPerformTime(pos_sequence[posindex][8] - pos_sequence[posindex][7]),epos)
            else
               performWithJump(animNode,aniCircelPlay,getActionPerformTime(pos_sequence[posindex][8] - pos_sequence[posindex][7]),epos,height)
            end
         end
      end
      changeAni(manimNode);
   end
end

local function runAnimSequence(self,t_params,manimNode,manim_sequence,state)
    cclog("function:------------------------runAnimSequence");
    --处理动画序列
    local animIndex  = 0;
    local anim_sequence  = manim_sequence;
    local animCount  = table.getn(anim_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local m_state = state
    if animCount > 0 then
       cclog("runAnimSequence")
       local function changeAni(animNode)
          --cclog("changeAni")
          animIndex = animIndex + 1;
          if(animIndex <= animCount) then
             --cclog("changeAni animIndex->"..animIndex)
             game_util:playSection(animNode,anim_sequence[animIndex][1],m_state);
             animNode:setRhythm(anim_sequence[animIndex][2] * public_config.action_rythm);
             if(anim_sequence[animIndex][5] == 0) then
                local aniCircelPlay = function()
                   changeAni(animNode);
                end
                performWithDelay(animNode,aniCircelPlay,getActionPerformTime(anim_sequence[animIndex][4] - anim_sequence[animIndex][3]))
             end
          else
             cclog("changeAni animCount->"..animIndex)
             animNode:stopAllActions()
             animNode:registerScriptTapHandler(self.params.game_battle_table.animEnd);
             animNode:registerScriptAnchor(self.params.game_battle_table.anchorCallFunc);
             animNode:setRhythm(public_config.action_rythm);
             game_util:playSection(animNode,anim_label_name_cfg.daiji,m_state);
             if enemy_object_tab then
                --game_util:playSection(enemy_object_tab.animNode,anim_label_name_cfg.daiji,enemy_object_tab.aniState);
             end
             if t_params.animEndCallFunc ~= nil then  
                t_params.animEndCallFunc(); 
             end
             self:release("runAnimSequence");
          end
       end
       local function animListenter(animNode,theid,labelname)
          if(anim_sequence[animIndex][5] == 0) then
             game_util:playSection(animNode,anim_sequence[animIndex][1],m_state);
             animNode:setRhythm(anim_sequence[animIndex][2] * public_config.action_rythm);
          else
             changeAni(animNode)
          end
       end
       if attack_type == "jingong" then
          self.m_attack_object.animNode:setPosition(attackPos);
          self.m_battle_layer:reorderChild(self.m_attack_object.animNode,- attackPos.y + 10);
       end
       self.m_attack_object.animNode:registerScriptTapHandler(animListenter);
       changeAni(manimNode);
    else
       local animNode = manimNode;
       animNode:stopAllActions()
       animNode:registerScriptTapHandler(self.params.game_battle_table.animEnd);
       animNode:registerScriptAnchor(self.params.game_battle_table.anchorCallFunc);
       animNode:setRhythm(public_config.action_rythm);
       game_util:playSection(animNode,anim_label_name_cfg.daiji,m_state);
       if enemy_object_tab then
          --game_util:playSection(enemy_object_tab.animNode,anim_label_name_cfg.daiji,enemy_object_tab.aniState);
       end
       if t_params.animEndCallFunc ~= nil then  
          t_params.animEndCallFunc(); 
       end
       self:release("runAnimSequence");
    end
end

local function runOtherAnimSequence(self,t_params,manimNode,manim_sequence,callback)
    cclog("function:------------------------runOtherAnimSequence");
    --处理动画序列
    local animIndex  = 0;
    local anim_sequence  = manim_sequence;
    local animCount  = table.getn(anim_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local winSize = CCDirector:sharedDirector():getWinSize();
    if animCount > 0 then
       local function changeAni(animNode)
          animIndex = animIndex + 1;
          if(animIndex <= animCount) then
             animNode:playSection(anim_sequence[animIndex][1]);
             animNode:setRhythm(anim_sequence[animIndex][2]*public_config.action_rythm);
             if(anim_sequence[animIndex][5] == 0) then
                local aniCircelPlay = function()
                   changeAni(animNode);
                end
                performWithDelay(animNode,aniCircelPlay,getActionPerformTime(anim_sequence[animIndex][4] - anim_sequence[animIndex][3]))
             end
          else
             callback(manimNode)
          end
       end
       local function animListenter(animNode,theid,labelname)
          if(anim_sequence[animIndex][5] == 0) then
             animNode:playSection(anim_sequence[animIndex][1]);
             animNode:setRhythm(anim_sequence[animIndex][2]*public_config.action_rythm);
          else
             changeAni(animNode)
          end
       end
       if attack_type == "jingong" then
          self.m_attack_object.animNode:setPosition(attackPos);
          self.m_battle_layer:reorderChild(self.m_attack_object.animNode,- attackPos.y + 10);
       end
       manimNode:registerScriptTapHandler(animListenter);
       changeAni(manimNode);
    end
end

local function runOtherCircelAnimSequence(self,t_params,manimNode,manim_sequence,callback)
    cclog("function:------------------------runOtherCircelAnimSequence");
    --处理动画序列
    local animIndex  = 0;
    local anim_sequence  = manim_sequence;
    local animCount  = table.getn(anim_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local isend = true
    if animCount > 0 then
       local function changeAni(animNode)
          cclog("runOtherCircelAnimSequence sub function:-----------------changeAni");
          if self.params.game_battle_table.m_curtentAnimLabelName == "winer" then return end
          animIndex = animIndex + 1;
          -- cclog("runOtherCircelAnimSequence"..animIndex)
          if(animIndex <= animCount) then
             animNode:playSection(anim_sequence[animIndex][1]);
             animNode:setRhythm(anim_sequence[animIndex][2]*public_config.action_rythm);
             if(anim_sequence[animIndex][5] == 0) then
                local aniCircelPlay = function()
                  cclog("runOtherCircelAnimSequence sub function:-----------------aniCircelPlay");
                   changeAni(animNode);
                end
                performWithDelay(animNode,aniCircelPlay,getActionPerformTime(anim_sequence[animIndex][4] - anim_sequence[animIndex][3]))
             end
          else
             -- cclog("runOtherCircelAnimSequencechangeAnichangeAnichangeAni"..animIndex)
             if(isend) then
                callback()
                isend = false
             end
             animIndex = animCount
             animNode:playSection(anim_sequence[animCount][1]);
             animNode:setRhythm(anim_sequence[animCount][2]*public_config.action_rythm);
          end
       end
       local function animListenter(animNode,theid,labelname)
          if(anim_sequence[animIndex][5] == 0) then
             animNode:playSection(anim_sequence[animIndex][1]);
             animNode:setRhythm(anim_sequence[animIndex][2]*public_config.action_rythm);
          else
             changeAni(animNode)
          end
       end
       if attack_type == "jingong" then
          self.m_attack_object.animNode:setPosition(attackPos);
          self.m_battle_layer:reorderChild(self.m_attack_object.animNode,- attackPos.y + 10);
       end
       manimNode:registerScriptTapHandler(animListenter);
       changeAni(manimNode);
    end
end

local function addOtherNode(self,t_params,manimNode,mother_sequence,i)
    cclog("function:------------------------addOtherNode");
   local other_sequence  = mother_sequence;
   local otherCount  = table.getn(other_sequence);
   local enemy_object_tab = t_params.enemy_object_tab;
   local info = self;
   local infoparams = t_params;
   local winSize = CCDirector:sharedDirector():getWinSize();
   local camp 
   if(self.m_attack_object) then
        camp = self.m_attack_object.camp 
   else
        camp = self.m_camp
   end
   local dataTable = other_sequence[i]
   local animName = other_sequence[i][1]
   cclog("animName->"..animName)
   local mAnimNode = game_util:createEffectAnim(animName,1.0,true);
   if mAnimNode == nil then
      return;
    end
   mAnimNode:setAnchorPoint(ccp(0.5,0));
   --[[--if(camp == -1) then
      mAnimNode:setFlipX(true)
   end]]--
   local anchorCallFunc = function()
   end
   mAnimNode:registerScriptAnchor(anchorCallFunc);
   local nodeSize = CCSizeMake(0,0);
   local nodePos = ccp(0,0);
   if(self.m_attack_object) then
       local spX,spY = self.m_attack_object.animNode:getPosition();
       nodeSize = self.m_attack_object.animNode:getContentSize();
       nodePos = ccp(spX,spY);
   end
   if(other_sequence[i][2] == 1) then
      nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp 
      nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
      mAnimNode:setPosition(nodePos);
      self.params.game_battle_table.m_battle_layer:addChild(mAnimNode)
   elseif(other_sequence[i][2] == 2) then
      nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp 
      nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
      mAnimNode:setPosition(nodePos);
      self.params.game_battle_table.m_battle_up_layer:addChild(mAnimNode)
   elseif(other_sequence[i][2] == 4) then
      nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp
      nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height  * public_config.anim_scale
      mAnimNode:setPosition(nodePos);
      self.params.game_battle_table.m_battle_down_layer:addChild(mAnimNode)
   elseif(other_sequence[i][2] == 0) then
      nodePos.x = other_sequence[i][4] / 960 * winSize.width  * public_config.anim_scale * camp + nodeSize.width / 2 * public_config.anim_scale
      nodePos.y = other_sequence[i][5] / 640 * winSize.height  * public_config.anim_scale
      manimNode:addChild(mAnimNode)
      mAnimNode:setPosition(nodePos);
      manimNode:reorderChild(mAnimNode,1)
   elseif(other_sequence[i][2] == 3) then
      nodePos.x = other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp + nodeSize.width / 2 * public_config.anim_scale
      nodePos.y = other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
      manimNode:addChild(mAnimNode)
      mAnimNode:setPosition(nodePos);
      manimNode:reorderChild(mAnimNode,-1)
   end
   return mAnimNode
end

local function runBuffCircelOtherSequence(self,t_params,manimNode,mother_sequence)
    cclog("function:------------------------runBuffCircelOtherSequence");
    --处理动画序列
    local other_sequence  = mother_sequence;
    local otherCount  = table.getn(other_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local info = self;
    local infoparams = t_params;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local nodetable = {}
    local overCount = otherCount
    local iscango = self.params.game_battle_table.m_canGo
    --[[--if(iscango == nil) then
        cclog("runBuffCircelOtherSequenceiscango == nil")
    else
        cclog("runBuffCircelOtherSequenceiscango ~= nil")
    end]]--
    for i = 1,otherCount do
       local mAnimNode = addOtherNode(self,t_params,manimNode,other_sequence,i)
       if mAnimNode then
           mAnimNode:setVisible(false)
           local function realPlayAni()
              local function anchorCallFunc(animNode , mId , strValue)
              end
              mAnimNode:setVisible(true)
              if(other_sequence[i][2] == 1 or other_sequence[i][2] == 2 or other_sequence[i][2] == 4) then
                 local runPos = function()
                    runPosSequence(info,infoparams,mAnimNode,other_sequence[i][7])
                 end
                 runPos()
                 local runScale = function()
                    runScaleSequence(info,infoparams,mAnimNode,other_sequence[i][8])
                 end
                 runScale()
                 local runFade = function()
                    runFadeSequence(info,infoparams,mAnimNode,other_sequence[i][9])
                 end
                 runFade()
              end
              local endcallback = function()
                    cclog("runBuffCircelOtherSequence sub function------------endcallback");
                 -- cclog("mAnimNodemAnimNodemAnimNodemAnimNode")
                 -- if(not iscango) then
                    overCount = overCount - 1
                    if(overCount == 0) then
                      -- changed by yock on 2013/12/26
                      -- buff animation sequence is over
                        -- self.params.game_battle_table:setCanGo(true,"runBuffCircelOtherSequence");
                    end
                 -- end
                 --mAnimNode:removeFromParentAndCleanup(true)
                 --self:release("runOtherSequence");
              end
              local runAni = function()
                 runOtherCircelAnimSequence(info,infoparams,mAnimNode,other_sequence[i][6],endcallback)
              end
              runAni()
           end
           if(mAnimNode == nil) then
              -- cclog("mAnimNode->"..other_sequence[i][1])
           end
           -- cclog("runOtherSequence->"..other_sequence[i][3])
           performWithDelay(mAnimNode,realPlayAni,getActionPerformTime(other_sequence[i][3]))
           --self:retain("runOtherSequence");
           nodetable[i] = mAnimNode
      end
    end
    return nodetable
end

local function runBuffOnceOtherSequence(self,t_params,manimNode,mother_sequence)
    cclog("function:------------------------runBuffOnceOtherSequence");
    --处理动画序列
    local other_sequence  = mother_sequence;
    local otherCount  = table.getn(other_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local info = self;
    local infoparams = t_params;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local overCount = otherCount
    -- local iscango = self.params.game_battle_table.m_canGo
    --[[--if(iscango == nil) then
        cclog("runBuffOnceOtherSequenceiscango == nil")
    else
        cclog("runBuffOnceOtherSequenceiscango ~= nil")
    end
    cclog("runBuffOnceOtherSequenceiscango->"..tostring(iscango))]]--
    for i = 1,otherCount do
       local mAnimNode = addOtherNode(self,t_params,manimNode,other_sequence,i)
       if mAnimNode then
           mAnimNode:setVisible(false)
           local function realPlayAni()
              local function anchorCallFunc(animNode , mId , strValue)
              end
              mAnimNode:setVisible(true)
              if(other_sequence[i][2] == 1 or other_sequence[i][2] == 2 or other_sequence[i][2] == 4) then
                 local runPos = function()
                    runPosSequence(info,infoparams,mAnimNode,other_sequence[i][7])
                 end
                 runPos()
                 local runScale = function()
                    runScaleSequence(info,infoparams,mAnimNode,other_sequence[i][8])
                 end
                 runScale()
                 local runFade = function()
                    runFadeSequence(info,infoparams,mAnimNode,other_sequence[i][9])
                 end
                 runFade()
              end
              local endcallback = function(mAnimNode)
                 mAnimNode:removeFromParentAndCleanup(true)
                 -- if(not iscango) then
                    overCount = overCount - 1
                    if(overCount == 0) then
                      -- changed by yock on 2013/12/26
                      -- buff animation is over
                        -- self.params.game_battle_table:setCanGo(true,"runBuffOnceOtherSequence");
                    end
                 -- end
                 --self:release("runOtherSequence");
              end
              local runAni = function()
                 runOtherAnimSequence(info,infoparams,mAnimNode,other_sequence[i][6],endcallback)
              end
              runAni()
           end
           -- cclog("runOtherSequence->"..other_sequence[i][3])
           performWithDelay(mAnimNode,realPlayAni,getActionPerformTime(other_sequence[i][3]))
           --self:retain("runOtherSequence");
        end
    end
end

local function runHeroSkillOtherSequence(self,t_params,node,mother_sequence)
    --处理动画序列
    cclog("function:------------------------runHeroSkillOtherSequence");
    local other_sequence  = mother_sequence;
    local otherCount  = table.getn(other_sequence);
    local enemy_object_tab = t_params.enemy_object_tab;
    local info = self;
    local infoparams = t_params;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local overCount = otherCount
    -- local iscango = self.params.game_battle_table.m_canGo
    for i = 1,otherCount do
       local mAnimNode = addOtherNode(self,t_params,nil,other_sequence,i)
       if mAnimNode then
           -- mAnimNode:registerScriptAnchor()
           mAnimNode:setVisible(false)
           local function realPlayAni()
              local function anchorCallFunc(animNode , mId , strValue)
                cclog("--------------- hero skill anchor ----------- " .. strValue);
                self.m_anchor_index = self.params.game_battle_table:anchorAllCall(strValue,self.m_enemy_object_table,self.m_hurtValueTable,self.m_attack_effect,self.m_anchor_num,self.m_anchor_index,self.m_add_object_table,self.m_addValueTable,true,self.params.currentFrameData);
              end
              mAnimNode:registerScriptAnchor(anchorCallFunc);
              mAnimNode:setVisible(true)
              if(other_sequence[i][2] == 1 or other_sequence[i][2] == 2 or other_sequence[i][2] == 4) then
                 local runPos = function()
                    runPosSequence(info,infoparams,mAnimNode,other_sequence[i][7])
                 end
                 runPos()
                 local runScale = function()
                    runScaleSequence(info,infoparams,mAnimNode,other_sequence[i][8])
                 end
                 runScale()
                 local runFade = function()
                    runFadeSequence(info,infoparams,mAnimNode,other_sequence[i][9])
                 end
                 runFade()
              end
              local endcallback = function(mAnimNode)
                 mAnimNode:removeFromParentAndCleanup(true)
                 -- if(not iscango) then
                    overCount = overCount - 1
                    if(overCount == 0) then
                        cclog("runHeroSkillOtherSequenceskillOver")
                        self:skillOver()
                    end
                 -- end
                 --self:release("runOtherSequence");
              end
              local runAni = function()
                 runOtherAnimSequence(info,infoparams,mAnimNode,other_sequence[i][6],endcallback)
              end
              runAni()
           end
           -- cclog("runOtherSequence->"..other_sequence[i][3])
           performWithDelay(mAnimNode,realPlayAni,getActionPerformTime(other_sequence[i][3]))
           --self:retain("runOtherSequence");
       end
    end
end


local function runOtherSequence(self,t_params,manimNode,mother_sequence)
    cclog("function:------------------------runOtherSequence");
    -- util.printf(mother_sequence);
    cclog("   t_params:type=" .. type(t_params) .. "  manimNode:type=" .. type(manimNode) .. "  mother_sequence:type=" .. type(mother_sequence));
    cclog("                            -----runOtherSequence");
    --处理动画序列
    local other_sequence  = mother_sequence;
    local otherCount  = table.getn(other_sequence);
    local local_enemy_object_tab = t_params.enemy_object_tab;
    local info = self;
    local infoparams = t_params;
    local winSize = CCDirector:sharedDirector():getWinSize();
    local camp 
    if(self.m_attack_object) then
        camp = self.m_attack_object.camp 
    else
        camp = self.m_camp
    end
    for i = 1,otherCount do
       local function realPlayAni(enemy_object_tab)
          local function anchorCallFunc(animNode , mId , strValue)
          end
          t_params.enemy_object_tab = enemy_object_tab
          local dataTable = other_sequence[i]
          local animName = other_sequence[i][1]
          cclog("runOtherSequence  animName->"..animName)
          --赌圣技能需要释放不同的动画时调用 
          if(self.m_card ~= nil and other_sequence[i][11] ~= nil and other_sequence[i][11] == 1) then
              local len = string.len(animName)
              animName = string.sub(animName,1,len - 1)
              animName = animName..self.m_card
          end
          --------------------------------------------------------------------------------------------
          local mAnimNode = game_util:createEffectAnim(animName,1.0,true);
          mAnimNode:setAnchorPoint(ccp(0.5,0));
          mAnimNode:registerScriptAnchor(anchorCallFunc);
          if(string.find(animName,"twist_gongji"))then
            camp = 1;
          end
          if(self.params.skill_type == "buff_skill")then
            camp = 1;
          end
          if(camp == -1) then
             mAnimNode:setFlipX(true)
          end
          local nodeSize = CCSizeMake(0,0);
          local nodePos = ccp(0,0);
          if(self.m_attack_object) then
             local spX,spY = self.m_attack_object.animNode:getPosition();
             nodeSize = self.m_attack_object.animNode:getContentSize();
             nodePos = ccp(spX,spY);
          end
          if(other_sequence[i][2] == 1) then
             nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp
             nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
             self.params.game_battle_table.m_battle_layer:addChild(mAnimNode)
             mAnimNode:setPosition(nodePos);
          elseif(other_sequence[i][2] == 2) then
             nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp
             nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
             self.params.game_battle_table.m_battle_up_layer:addChild(mAnimNode)
             mAnimNode:setPosition(nodePos);
          elseif(other_sequence[i][2] == 4) then
             nodePos.x = nodePos.x + other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp
             nodePos.y = nodePos.y + other_sequence[i][5] / 640 * winSize.height  * public_config.anim_scale
             self.params.game_battle_table.m_battle_down_layer:addChild(mAnimNode)
             mAnimNode:setPosition(nodePos);
          elseif(other_sequence[i][2] == 0) then
             nodePos.x = other_sequence[i][4] / 960 * winSize.width  * public_config.anim_scale * camp + nodeSize.width / 2 * public_config.anim_scale
             nodePos.y = other_sequence[i][5] / 640 * winSize.height  * public_config.anim_scale
             manimNode:addChild(mAnimNode)
             mAnimNode:setPosition(nodePos);
             manimNode:reorderChild(mAnimNode,1)
          elseif(other_sequence[i][2] == 3) then
             nodePos.x = other_sequence[i][4] / 960 * winSize.width * public_config.anim_scale * camp + nodeSize.width / 2 * public_config.anim_scale
             nodePos.y = other_sequence[i][5] / 640 * winSize.height * public_config.anim_scale
             manimNode:addChild(mAnimNode)
             mAnimNode:setPosition(nodePos);
             manimNode:reorderChild(mAnimNode,-1)
          end
          if(other_sequence[i][2] == 1 or other_sequence[i][2] == 2 or other_sequence[i][2] == 4) then
             local runPos = function()
                runPosSequence(info,infoparams,mAnimNode,other_sequence[i][7])
             end
             runPos()
             local runScale = function()
                runScaleSequence(info,infoparams,mAnimNode,other_sequence[i][8])
             end
             runScale()
             local runFade = function()
                runFadeSequence(info,infoparams,mAnimNode,other_sequence[i][9])
             end
             runFade()
          end
          local endcallback = function(mAnimNode)
             -- cclog("runOtherSequenceendcallback->"..other_sequence[i][3])
             mAnimNode:removeFromParentAndCleanup(true)
             --self:release("runOtherSequence");
          end
          local runAni = function()
             runOtherAnimSequence(info,infoparams,mAnimNode,other_sequence[i][6],endcallback)
          end
          runAni()
       end
       -- cclog("runOtherSequencerunOtherSequence->"..other_sequence[i][3])
       local enemy_object_count = #self.m_aim_object_table;
       cclog("enemy_object_countenemy_object_countenemy_object_count->"..enemy_object_count)
       for j = 1,enemy_object_count do
           local delayEndPlay = function()
              cclog("-----------------delayEndPlay is run");
               realPlayAni(self.m_aim_object_table[j])
           end
           if(manimNode == nil) then
              cclog("----------------manimNode is nil");
               delayEndPlay()
           else
              cclog("----------------has manimNode"..getActionPerformTime(other_sequence[i][3]));
               -- performWithDelay(manimNode,delayEndPlay,getActionPerformTime(other_sequence[i][3]))
               if other_sequence[i][3] < 0.0000001 then
                   delayEndPlay()
               else
                   performWithDelay(self.m_battle_layer,delayEndPlay,getActionPerformTime(other_sequence[i][3]));
               end
           end
       end
       --[[--if(other_sequence[i][10] ~= nil and other_sequence[i][10] == 1) then
           local enemy_object_count = #self.m_aim_object_table;
           cclog("enemy_object_countenemy_object_countenemy_object_count->"..enemy_object_count)
           for j = 1,enemy_object_count do
               local delayEndPlay = function()
                   realPlayAni(self.m_aim_object_table[j])
               end
               performWithDelay(manimNode,delayEndPlay,getActionPerformTime(other_sequence[i][3]))
           end
       else
           local delayEndPlay = function()
               realPlayAni(local_enemy_object_tab)
           end
           performWithDelay(manimNode,delayEndPlay,getActionPerformTime(other_sequence[i][3]))  
       end]]--
       --self:retain("runOtherSequence");
    end
end

-- 攻击者的攻击动作
function game_battle_skill.createAttackerAnim(self,t_params)
    cclog("function:------------------------createAttackerAnim");
    --cclog("self.params.game_battle_table->"..self.m_attack_object.camp)
    local delay_time = t_params.delay_time;
    local attack_type = t_params.attack_type;
    local anim_equence = t_params.anim_equence;
    local enemy_object_tab = t_params.enemy_object_tab;
    local attackPos = ccp(0,0) 
    if self.m_attack_object then
        local pX,pY = self.m_attack_object.animNode:getPosition();
        attackPos = ccp(pX,pY);
    end
    local anim_sequence  = t_params.anim_sequence;
    local pos_sequence   = t_params.pos_sequence;
    local scale_sequence = t_params.scale_sequence;
    local fade_sequence  = t_params.fade_sequence;
    local other_sequence = t_params.other_sequence;
    if t_params.attackPos then
        cclog("game_battle_skill.createAttackerAnim->t_params.attackPos")
        attackPos = t_params.attackPos;
    end
    local hpValue = t_params.hpValue;
    local function delayCallFunc()
        local animCount = table.getn(anim_equence);
        if animCount > 0 then 
            local animIndex = 1;
            local function animListenter( animNode , theid , labelname )    -- 中动画结束响应事件
                -- cclog("yock------------this is a action call back " .. labelname .. "  the id:" .. tostring(theid));
                if animIndex > animCount then
                    animNode:registerScriptTapHandler(self.params.game_battle_table.animEnd);
                    animNode:registerScriptAnchor(self.params.game_battle_table.anchorCallFunc);
                    animNode:setRhythm(public_config.action_rythm);
                    animNode:playSection(anim_label_name_cfg.daiji);
                    --[[--if enemy_object_tab then
                        enemy_object_tab.animNode:playSection(anim_label_name_cfg.daiji);
                    end]]--
                    if t_params.animEndCallFunc ~= nil then  t_params.animEndCallFunc(); end
                    self:release("createAttackerAnim 2");
                else
                    if labelname == anim_label_name_cfg.qianjin then
                        -- animNode:getParent():setPosition(attackPos)
                        animNode:playSection(anim_label_name_cfg.qianjin);
                    else
                        -- cclog("animListenter    anim_equence[" .. animIndex .. "][1] = " .. anim_equence[animIndex][1] .. " ; anim_equence[" .. animIndex .. "][2] ===" .. anim_equence[animIndex][2]);
                        animNode:playSection(anim_equence[animIndex][1])
                        animNode:setRhythm(anim_equence[animIndex][2]);
                        animIndex = animIndex + 1;
                    end
                end
            end
            if t_params.anchorCallFunc == nil then
                t_params.anchorCallFunc = function(animNode , mId , strValue)
                    --cclog("self.m_attack_object animFile = " .. self.m_attack_object.animFile)
                    --cclog("-----------------createAttackerAnim anchorCallFunc strValue ==" .. tostring(strValue) .. " ; $$$$$ enemy_object_tab.animFile = " .. enemy_object_tab.animFile)
                    self.params.game_battle_table:anchorCall(strValue,enemy_object_tab,hpValue);
                end
            end
            self.m_attack_object.animNode:registerScriptAnchor(t_params.anchorCallFunc);
            -- self.m_attack_object.animNode:registerScriptTapHandler(animListenter);


            local function moveEndCallFunc()
                if attack_type == "jingong" then
                    self.m_attack_object.animNode:setPosition(attackPos);
                    self.m_battle_layer:reorderChild(self.m_attack_object.animNode,- attackPos.y + 100);
                end
                -- cclog("moveEndCallFunc    anim_equence[" .. animIndex .. "][1] = " .. anim_equence[animIndex][1] .. " ; anim_equence[" .. animIndex .. "][2] ===" .. anim_equence[animIndex][2]);
                self.m_attack_object.animNode:playSection(anim_equence[animIndex][1]);
                self.m_attack_object.animNode:registerScriptTapHandler(animListenter);
                self.m_attack_object.animNode:setRhythm(anim_equence[animIndex][2]);
                animIndex = animIndex + 1;
            end
            if attack_type == "yuangong" then
                moveEndCallFunc();
            elseif attack_type == "jingong" then
                local animArr = CCArray:create();
                animArr:addObject(CCMoveTo:create(0.2*public_config.action_rythm,attackPos));
                animArr:addObject(CCCallFunc:create(moveEndCallFunc));
                self.m_attack_object.animNode:runAction(CCSequence:create(animArr));
                self.m_attack_object.animNode:playSection(anim_label_name_cfg.qianjin);
            end
        end
        self:release("createAttackerAnim 1");
    end
    --配合编辑器新攻击序列
    local function runCallFunc()
        --cclog("runCallFunc")
        local function runRealAction()
           --cclog("runRealAction")
           self.m_anchor_index = 0
           self.m_anchor_num = t_params.bloodNum
           if t_params.anchorCallFunc == nil then
              t_params.anchorCallFunc = function(animNode , mId , strValue)
                  --cclog("t_params.anchorCallFunc")
                  --[[--local enemy_object_count = #self.m_enemy_object_table
                  for k = 1, enemy_object_count do--攻击多个
                      self.params.game_battle_table:anchorCall(strValue,self.m_enemy_object_table[k],self.m_hurtValueTable[k]);
                  end]]--
                  --self.m_anchor_index = self.m_anchor_index + 1
                  --cclog("self.m_anchor_index->"..self.m_anchor_index)
                  --cclog("self.m_anchor_num->"..self.m_anchor_num)
                  -- cclog("------- card skill --- " .. strValue);
                  self.m_anchor_index = self.params.game_battle_table:anchorAllCall(strValue,self.m_enemy_object_table,self.m_hurtValueTable,self.m_attack_effect,self.m_anchor_num,self.m_anchor_index,self.m_add_object_table,self.m_addValueTable,false,self.params.currentFrameData);
              end
           end
           if(self.m_skill_type == "skill_hero") then
               runHeroSkillOtherSequence(self,t_params,nil,other_sequence)
           else
               self.m_attack_object.animNode:registerScriptAnchor(t_params.anchorCallFunc);
               runAnimSequence(self,t_params,self.m_attack_object.animNode,anim_sequence,self.m_attack_object.aniState)
               runPosSequence(self,t_params,self.m_attack_object.animNode,pos_sequence)
               runScaleSequence(self,t_params,self.m_attack_object.animNode,scale_sequence)
               runFadeSequence(self,t_params,self.m_attack_object.animNode,fade_sequence)
               runOtherSequence(self,t_params,self.m_attack_object.animNode,other_sequence)
           end
        end
        local function animqianjin(animNode,theid,labelname)
           self.m_attack_object.animNode:registerScriptTapHandler(animqianjin);
           game_util:playSection(self.m_attack_object.animNode,anim_label_name_cfg.qianjin,self.m_attack_object.aniState);
        end
        cclog("mmm_attack_type->"..attack_type)
        if attack_type == "yuangong" then
           runRealAction();
        elseif attack_type == "jingong" then
           local movetime = 0.2;
           local animArr = CCArray:create();
           animArr:addObject(CCMoveTo:create(movetime*public_config.action_rythm,ccp(attackPos.x,attackPos.y - 2)));
           animArr:addObject(CCCallFunc:create(runRealAction));
           self.m_attack_object.animNode:runAction(CCSequence:create(animArr));
           self.m_attack_object.animNode:registerScriptTapHandler(animqianjin);
           game_util:playSection(self.m_attack_object.animNode,anim_label_name_cfg.qianjin,self.m_attack_object.aniState);
        end
        self:release("createAttackerAnim");
    end
    if(anim_sequence == nil) then
       performWithDelay(self.m_battle_layer,delayCallFunc,delay_time);
    else
       performWithDelay(self.m_battle_layer,runCallFunc,delay_time);
    end
    self:retain("createAttackerAnim 1");--动画序列播完的retain
    self:retain("createAttackerAnim 2");
end


-- Remote attackers

-- Into the body attacks

--伤害动画特效
function game_battle_skill.createHurtAnim(self,t_params)
    cclog("function:------------------------createHurtAnim");
    local hurtAnim = t_params.hurtAnim;
    local hurtAnim_equence = t_params.hurtAnim_equence;
    local enemy_object_tab = t_params.enemy_object_tab;
    local hpValue = t_params.hpValue
    self:retain("createHurtAnim");
    if hurtAnim == nil or hurtAnim == "" then
        self:release("createHurtAnim");
        return;
    end
    local animCount = table.getn(hurtAnim_equence);
    if animCount == 0 then
        self:release("createHurtAnim");
        return;
    end
    local mAnimNode = nil;
    local animIndex = 1;
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        -- cclog("onAnimSectionEnd createHurtAnim ==" .. animIndex .. " ;theLabelName ==" .. theLabelName);
        if animIndex > animCount then
            mAnimNode:removeFromParentAndCleanup(true);
            if t_params.animEndCallFunc ~= nil then  t_params.animEndCallFunc(); end
            self:release("createHurtAnim");
        else
            mAnimNode:playSection(hurtAnim_equence[animIndex][1])
            mAnimNode:setRhythm(hurtAnim_equence[animIndex][2]);
            animIndex = animIndex + 1;
        end
    end
    mAnimNode = game_util:createEffectAnim(hurtAnim,1.0,true);
    cclog("hurtAnim"..hurtAnim)
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection(hurtAnim_equence[animIndex][1]);
    mAnimNode:setRhythm(hurtAnim_equence[animIndex][2]);
    animIndex = animIndex + 1;
    -- mAnimNode:setScale(0.5);
    -- local px,py = enemy_object_tab.animNode:getPosition();
    -- mAnimNode:setPosition(ccp(px,py));
    -- self.m_battle_layer:addChild(mAnimNode);
    local animNodeSize = enemy_object_tab.animNode:getContentSize();
    mAnimNode:setPosition(ccp(animNodeSize.width*0.5,animNodeSize.height*0.5));
    enemy_object_tab.animNode:addChild(mAnimNode,100,100);
    -- self.params.game_battle_table:anchorCall("{\"type\":\"bao\"}",enemy_object_tab,hpValue);
    -- self.params.game_battle_table:hurtLable(enemy_object_tab.animNode,- math.floor(hpValue),1,0);
end
--[[--
    得到攻击的起始位置和结束位置
]]
function game_battle_skill.getStartAndEndPos(self,t_params)
        cclog("function:------------------------getStartAndEndPos");
        local v = t_params.skills_table;
        local enemy_object_tab = t_params.enemy_object_tab;
        local attackPos = t_params.attackPos;
        local start_pos = v.start_p; 
        local mAnimStartPos = ccp(0,0);
        if start_pos[1] == 0 then-- 代表己方  坐标直接是附加到该对象上
            local m,n = self.m_attack_object.animNode:getPosition();
            mAnimStartPos = ccp(m + start_pos[2], n + start_pos[3]);
        elseif start_pos[1] == 1 then -- 代表对方 -- 对方的对象
            local m,n = enemy_object_tab.animNode:getPosition();
            if enemy_object_tab.animNode:getFlipX() then
                mAnimStartPos = ccp(m - start_pos[2], n + start_pos[3]);
            else
                mAnimStartPos = ccp(m + start_pos[2], n + start_pos[3]);
            end
        elseif start_pos[1] == 2 then
            mAnimStartPos = ccp(start_pos[2],start_pos[3]);
        end

        local end_pos = v.end_p; 
        local mAnimEndPos = ccp(0,0);
        if end_pos[1] == 0 then
            local m,n = self.m_attack_object.animNode:getPosition();
            mAnimEndPos = ccp(m + end_pos[2], n + end_pos[3]);
        elseif end_pos[1] == 1 then
            local m,n = enemy_object_tab.animNode:getPosition();
            mAnimEndPos = ccp(m + end_pos[2], n + end_pos[3]);
        elseif end_pos[1] == 2 then
            mAnimEndPos = ccp(end_pos[2],end_pos[3]);
        end
        return mAnimStartPos,mAnimEndPos;
end

--召唤动画特效
function game_battle_skill.createCallAnim(self,t_params)
    cclog("function:------------------------createCallAnim");
    local ext_call = t_params.ext_call or {}
    local enemy_object_tab_all = {}
    local des = ext_call.des
    if type(des) == "number" then
        local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(des,70);
        if enemy_object and attackPos then
            enemy_object.attackPos = attackPos;
            table.insert(enemy_object_tab_all,enemy_object)
        end
    elseif type(des) == "table" then
        for k,v in pairs(des) do
            local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(v,70);
            if enemy_object and attackPos then
                enemy_object.attackPos = attackPos;
                table.insert(enemy_object_tab_all,enemy_object)
            end
        end
    end
    if #enemy_object_tab_all == 0 then
      return;
    end
    local function delayCallFunc()
        local attack_type = t_params.attack_type;
        local callAnim = t_params.callAnim or "";
        local callAnim_equence = t_params.callAnim_equence or {};
        local animCount = table.getn(callAnim_equence);
        if animCount == 0 or callAnim == "" then
            self:release("createCallAnim");
            self:release("createCallAnim");
            return;
        end
        -- local mAnimStartPos,mAnimEndPos = self:getStartAndEndPos(t_params);
        -- cclog("mAnimStartPos x , y = " .. mAnimStartPos.x .. " ; " .. mAnimStartPos.y);
        local enemy_object_tab = enemy_object_tab_all[1];
        -- local pX,pY = enemy_object_tab.animNode:getPosition();
        local pX,pY = self.m_attack_object.animNode:getPosition();
        local mAnimStartPos = ccp(pX,pY)
        local mAnimEndPos = enemy_object_tab.attackPos--t_params.attackPos
        local hpValue = t_params.hpValue
        local mAnimNode = nil;
        local animIndex = 1;
        local function onAnimSectionEnd(animNode, theId,theLabelName)
            if animIndex > animCount then
                animNode:removeFromParentAndCleanup(true);
                if t_params.animEndCallFunc ~= nil then
                    t_params.animEndCallFunc();
                end
                self:release("createCallAnim");
            else
                if theLabelName == anim_label_name_cfg.qianjin then
                    -- mAnimNode:setPosition(mAnimEndPos);
                    animNode:playSection(theLabelName);
                else
                    animNode:playSection(callAnim_equence[animIndex][1])
                    animNode:setRhythm(callAnim_equence[animIndex][2]);
                    animIndex = animIndex + 1;
                end
            end
        end
        attack_type = ext_call.attack_type or attack_type
        local anchor_index = 0;
        local anchor_num = ext_call.anchor_num or 1;
        local attack_effect = "";
        local addValueTable = {};
        local add_object_table = {};
        local hurtValueTable = {};
        local hurt = ext_call.hurt or 0
        if type(hurt) == "number" then
            table.insert(hurtValueTable,hurt)
        elseif type(hurt) == "table" then
            hurtValueTable = hurt;
        end
        local function anchorCallFunc(animNode , mId , strValue)
            -- self.params.game_battle_table:anchorCall(strValue,enemy_object_tab,hpValue);
            anchor_index = self.params.game_battle_table:anchorAllCall(strValue,enemy_object_tab_all,hurtValueTable,attack_effect,anchor_num,anchor_index,add_object_table,addValueTable,false,ext_call);
        end
        mAnimNode = game_util:createEffectAnim(callAnim , 1.0 , true);
        if mAnimNode == nil then
            self:release("createCallAnim");
            self:release("createCallAnim");
            return;
        end
        mAnimNode:setAnchorPoint(ccp(0.5,0));
        mAnimNode:registerScriptAnchor(anchorCallFunc);
        -- mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
        mAnimNode:setScale(public_config.anim_scale);
        mAnimNode:setFlipX(self.m_attack_object.animNode:getFlipX());
        mAnimNode:setPosition(mAnimStartPos);
        -- if attack_type == "jingong" then
        --     if callAnim_equence[animIndex][1] ~= anim_label_name_cfg.qianjin then
        --         mAnimNode:playSection(anim_label_name_cfg.qianjin);
        --     else
        --         mAnimNode:playSection(callAnim_equence[animIndex][1]);
        --         mAnimNode:setRhythm(callAnim_equence[animIndex][2]);
        --         animIndex = animIndex + 1; 
        --     end
        -- else
        --     mAnimNode:playSection(callAnim_equence[animIndex][1]);
        --     mAnimNode:setRhythm(callAnim_equence[animIndex][2]);
        --     animIndex = animIndex + 1; 
        -- end
        local function moveEndCallFunc()
            if attack_type == "jingong" then
                mAnimNode:setPosition(mAnimEndPos);
                self.m_battle_layer:reorderChild(mAnimNode,- mAnimEndPos.y + 10);
            end
            mAnimNode:playSection(callAnim_equence[animIndex][1]);
            mAnimNode:registerScriptTapHandler(onAnimSectionEnd);
            mAnimNode:setRhythm(callAnim_equence[animIndex][2]);
            animIndex = animIndex + 1;
        end
        if attack_type == "yuangong" then
            moveEndCallFunc();
        elseif attack_type == "jingong" then
            local animArr = CCArray:create();
            animArr:addObject(CCMoveTo:create(0.2*public_config.action_rythm,mAnimEndPos));
            animArr:addObject(CCCallFunc:create(moveEndCallFunc));
            mAnimNode:runAction(CCSequence:create(animArr));
            mAnimNode:playSection(anim_label_name_cfg.qianjin);
        end
        
        self.m_battle_layer:addChild(mAnimNode);
        self:release("createCallAnim");
    end
    performWithDelay(self.m_battle_layer,delayCallFunc,t_params.delay_time);
    self:retain("createCallAnim");--延迟的retain
    self:retain("createCallAnim");
end

--显示一次，但效果确持续
function game_battle_skill.addBuffOnceCircel(self,t_params)
    cclog("function:------------------------addBuffOnceCircel");
   t_params.enemy_object_tab = self.m_attack_object;
   t_params.other_sequence = t_params.skills_table.other_sequence;
   cclog("game_battle_skill.addBuffOnceCircel")
   local other_sequence = t_params.skills_table.other_sequence;
    runBuffOnceOtherSequence(self,t_params,self.m_attack_object.animNode,other_sequence)
   local nodeTable = {}
   local passref = t_params.skill_data.src
   if(passref == nil) then
      passref = t_params.skill_data.des
   end
   if(t_params.skills_table.aniState ~= nil) then
       self.m_attack_object.aniState = t_params.skills_table.aniState
   end
   -- self.m_attack_object.animNode:setColor(ccc3(255,95,95))
   cclog("game_battle_skill.addBuffOnceCircel")
   self.params.game_battle_table:addBuff(passref,t_params.skill_data.name,nodeTable,self.m_attack_object)
end

function game_battle_skill.addBuffOnce(self,t_params)
    cclog("function:------------------------addBuffOnce");
   t_params.enemy_object_tab = self.m_attack_object;
   t_params.other_sequence = t_params.skills_table.other_sequence;
   cclog("game_battle_skill.addBuffOnce")
   local other_sequence = t_params.skills_table.other_sequence;
   if(t_params.skills_table.aniState ~= nil) then
       self.m_attack_object.aniState = t_params.skills_table.aniState
   end
   runBuffOnceOtherSequence(self,t_params,self.m_attack_object.animNode,other_sequence)
   --self.m_attack_object.animNode:setColor(ccc3(255,95,95))
end

function game_battle_skill.addBuffCircel(self,t_params)
    cclog("function:------------------------addBuffCircel");
   t_params.enemy_object_tab = self.m_attack_object;
   t_params.other_sequence = t_params.skills_table.other_sequence;
   cclog("game_battle_skill.addBuffCircel")
   local other_sequence = t_params.skills_table.other_sequence;
   local nodeTable = runBuffCircelOtherSequence(self,t_params,self.m_attack_object.animNode,other_sequence)
   local passref = t_params.skill_data.src
   if(passref == nil) then
      passref = t_params.skill_data.des
   end
   if(t_params.skills_table.aniState ~= nil) then
       self.m_attack_object.aniState = t_params.skills_table.aniState
   end
   -- self.m_attack_object.animNode:setColor(ccc3(255,95,95))
   cclog("game_battle_skill.addBuffCircel")
   self.params.game_battle_table:addBuff(passref,t_params.skill_data.name,nodeTable,self.m_attack_object)
end

--创建buff动画
function game_battle_skill.createBuffAnim(self,t_params)
    cclog("function:------------------------createBuffAnim");
    local function delayCallFunc()
      local buffAnim = t_params.buffAnim
      local buffAnim_equence = t_params.buffAnim_equence;
      local enemy_object_tab = t_params.enemy_object_tab;
      if buffAnim == nil or buffAnim == "" then
          self:release("createBuffAnim");
          return;
      end
      local animCount = table.getn(buffAnim_equence);
      if animCount == 0 then
          self:release("createBuffAnim");
          return;
      end
      local mAnimNode = nil;
      local animIndex = 1;
      local function onAnimSectionEnd(animNode, theId,theLabelName)
        if animIndex > animCount then
            animIndex = 1;
        end
        animNode:playSection(buffAnim_equence[animIndex][1])
        animNode:setRhythm(buffAnim_equence[animIndex][2]);
        animIndex = animIndex + 1;
      end
      mAnimNode = game_util:createEffectAnim(buffAnim , 1.0 , true);
      mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
      mAnimNode:playSection(buffAnim_equence[animIndex][1]);
      mAnimNode:setRhythm(buffAnim_equence[animIndex][2]);
      animIndex = animIndex + 1;
      -- mAnimNode:setScale(0.5);
      local animNodeSize = enemy_object_tab.animNode:getContentSize();
      mAnimNode:setPosition(ccp(animNodeSize.width,animNodeSize.height));
      enemy_object_tab.animNode:addChild(mAnimNode);
      if t_params.buff_play_time ~= nil then
        local function playEndCallFunc()
            mAnimNode:removeFromParentAndCleanup(true);
        end
        -- changed by yock on 2014.4.10
        -- mAnimNode:setFlipX(true);
        performWithDelay(enemy_object_tab.animNode,playEndCallFunc,t_params.buff_play_time);
        -- changed by yock on 2014.4.10
        -- mAnimNode:setFlipX(true);
      end
      self:release("createBuffAnim");
    end
    performWithDelay(self.m_battle_layer,delayCallFunc,t_params.delay_time);
    self:retain("createBuffAnim");--延迟的retain
end

--正常的攻击(同时攻击，进攻多个攻击目标的话一个人同时分身多个人打，远攻打多个目标)
function game_battle_skill.createNormalAttack(self,t_params)
    cclog("function:------------------------createNormalAttack");
    if t_params.delay_time == nil then t_params.delay_time = 0 end
    local skills_table = t_params.skills_table;
    local attackEndRef = 1;
    local enemy_object_count = #self.m_enemy_object_table;--攻击的敌人数量

    cclog("createNormalAttack->"..enemy_object_count)

    if skills_table.attack_type == "yuangong" then
        attackEndRef = attackEndRef + enemy_object_count;
    end
    local function normalAttackEnd()
        attackEndRef = attackEndRef - 1;
        if attackEndRef < 1 and t_params.animEndCallFunc ~= nil then  
            t_params.animEndCallFunc();
        end
    end
    self.m_nstate = skills_table.aniState
    local params = {  --攻击者动画的参数
        delay_time          = t_params.delay_time, --播放动画的延迟时间 策划设置
        skills_table        = skills_table,--不需要改变
        enemy_object_tab    = self.m_aim_object_table[1],--攻击的对象
        attackPos           = self.m_attackPosTable[1],  --攻击的位置
        hpValue             = self.m_hurtValueTable[1],    --掉血或加血
        attack_type         = skills_table.attack_type, --当前攻击者攻击的类型
        anim_equence        = skills_table.attack_equence,  --当前攻击者攻击的动画序列
        anim_sequence       = skills_table.anim_sequence,
        pos_sequence        = skills_table.pos_sequence,
        scale_sequence      = skills_table.scale_sequence,
        fade_sequence       = skills_table.fade_sequence,
        other_sequence      = skills_table.other_sequence,
        bloodNum            = skills_table.bloodNum,
        aniState            = skills_table.aniState,
        animEndCallFunc     = normalAttackEnd,    --动画播放完成之后的方法回调，用于顺序播放
    }
    self:createAttackerAnim(params);--攻击者动画接口

    local skillData = self.params.game_battle_table.m_currentFrameData or {};
    local ext_call = skillData.ext_call or {}
    local anim = ext_call.anim or ""
    if anim ~= "" then
        local function delayCallFunc()
            self:release("createNormalAttack");
            local params = {
                delay_time          = 0,--播放动画的延迟时间 策划设置
                skills_table        = skills_table,--不需要改变
                ext_call            = ext_call,--不需要改变
                enemy_object_tab    = self.m_aim_object_table[1],--攻击的对象
                attackPos           = self.m_attackPosTable[1],--攻击的位置
                hpValue             = 0,--掉血或加血
                attack_type         = "jingong",--skills_table.attack_type,--攻击类型
                callAnim            = anim,--召唤动画资源
                callAnim_equence    = {{ext_call.action,1}}--skills_table.attack_equence, --动作序列 anim为空就把动画序列加在攻击者身上
            }
            self:createCallAnim(params);--召唤动画接口
        end    
        if t_params.play_delay_time ~= nil then
            performWithDelay(self.m_battle_layer,delayCallFunc,t_params.play_delay_time*k);
        else
            delayCallFunc();
        end
        self:retain("createNormalAttack");--延迟的retain
    end

    --[[--if skills_table.attack_type == "yuangong" then
        for k = 1,enemy_object_count do--攻击多个
            local function hurtAnimFunc()
                local params = {
                    enemy_object_tab    = self.m_aim_object_table[k],
                    hpValue             = self.m_hurtValueTable[k],
                    hurtAnim            = skills_table.hurtAnim, --受伤效果
                    hurtAnim_equence    = skills_table.hurtAnim_equence,--受伤效果动作序列
                    animEndCallFunc     = normalAttackEnd,
                }
                self:createHurtAnim(params);--伤害特效
            end
            
            local params = {
                delay_time          = t_params.delay_time,
                skills_table        = skills_table,
                enemy_object_tab    = self.m_aim_object_table[k],
                attackPos           = self.m_attackPosTable[k],
                hpValue             = self.m_hurtValueTable[k],
                animEndCallFunc     = hurtAnimFunc,
            }
            self:createMoveAnim(params);--移动动画接口
        end
    elseif skills_table.attack_type == "jingong" then
        for k = 2,enemy_object_count do--攻击多个
            local function delayCallFunc()
                self:release("createNormalAttack");
            local params = {
                delay_time          = 0,--播放动画的延迟时间 策划设置
                skills_table        = skills_table,--不需要改变
                enemy_object_tab    = self.m_aim_object_table[k],--攻击的对象
                attackPos           = self.m_attackPosTable[k],--攻击的位置
                hpValue             = self.m_hurtValueTable[k],--掉血或加血
                attack_type         = skills_table.attack_type,--攻击类型
                callAnim            = self.m_attack_object.animFile,--召唤动画资源
                callAnim_equence    = skills_table.attack_equence, --动作序列 anim为空就把动画序列加在攻击者身上
            }
            self:createCallAnim(params);--召唤动画接口

            end    
            if t_params.play_delay_time ~= nil then
                performWithDelay(self.m_battle_layer,delayCallFunc,t_params.play_delay_time*k);
            else
                delayCallFunc();
            end
            self:retain("createNormalAttack");--延迟的retain
        end
    end]]--
end


--[[--
    同时群体攻击
]]
function game_battle_skill.createGroupAttack(self,t_params)
    cclog("function:------------------------createGroupAttack");
    -- cclog("createGroupAttack =================================================");
    if t_params.delay_time == nil then t_params.delay_time = 0 end
    local skills_table = t_params.skills_table;
    local attackEndRef = 1;
    local enemy_object_count = #self.m_enemy_object_table;--攻击的敌人数量

    if skills_table.attack_type == "yuangong" then
        attackEndRef = attackEndRef + enemy_object_count;
    else

    end
    local anchorCallFunc = function(animNode , mId , strValue)
            for k=1,enemy_object_count do--攻击多个
                self.params.game_battle_table:anchorCall(strValue,self.m_enemy_object_table[k],self.m_hurtValueTable[k]);
            end
        end
    local function normalAttackEnd()
        attackEndRef = attackEndRef - 1;
        if attackEndRef < 1 and t_params.animEndCallFunc ~= nil then  
            t_params.animEndCallFunc(); 
        end
    end

    local params = {  --攻击者动画的参数
        delay_time          = t_params.delay_time, --播放动画的延迟时间 策划设置
        skills_table        = skills_table,--不需要改变
        enemy_object_tab    = nil,--攻击的对象
        attackPos           = self.m_attackCenterPosTable[3],  --攻击的位置
        hpValue             = self.m_hurtValueTable[1],    --掉血或加血
        attack_type         = skills_table.attack_type, --当前攻击者攻击的类型
        anim_equence        = skills_table.attack_equence,  --当前攻击者攻击的动画序列
        anim_sequence       = skills_table.anim_sequence,
        pos_sequence        = skills_table.pos_sequence,
        scale_sequence      = skills_table.scale_sequence,
        fade_sequence       = skills_table.fade_sequence,
        other_sequence      = skills_table.other_sequence,
        animEndCallFunc     = normalAttackEnd,    --动画播放完成之后的方法回调，用于顺序播放
        anchorCallFunc      = anchorCallFunc,
    }
    self:createAttackerAnim(params);--攻击者动画接口

    if skills_table.attack_type == "yuangong" then
            -- local function hurtAnim()
            --     local params = {
            --         enemy_object_tab    = self.m_enemy_object_table[k],
            --         hpValue             = self.m_hurtValueTable[k],
            --         hurtAnim            = skills_table.hurtAnim, --受伤效果
            --         hurtAnim_equence    = skills_table.hurtAnim_equence,--受伤效果动作序列
            --         animEndCallFunc     = nil,
            --     }
            --     self:createHurtAnim(params);--伤害特效
            -- end

        local params = {
            delay_time          = t_params.delay_time,
            skills_table        = skills_table,
            enemy_object_tab    = self.m_enemy_object_table[1],
            attackPos           = self.m_attackPosTable[1],
            hpValue             = self.m_hurtValueTable[k],
            animEndCallFunc     = normalAttackEnd,
        }
        self:createMoveAnim(params);--移动动画接口
    end
end

--创建近身的顺序攻击
function game_battle_skill.createOrderOfAttack(self,t_params)
    cclog("function:------------------------createOrderOfAttack");
    if t_params.delay_time == nil then t_params.delay_time = 0.5 end
    local skills_table = t_params.skills_table;
    if skills_table.attack_type ~= "jingong" then
        return;
    end
    local attackEndRef = 0;
    local enemy_object_count = #self.m_enemy_object_table;--攻击的敌人数量
    local function attackSeq()
        local function normalAttackEnd()
            attackEndRef = attackEndRef + 1;
            if attackEndRef >= enemy_object_count and t_params.animEndCallFunc ~= nil then  
                t_params.animEndCallFunc(); 
            else
                self:animAttackerPositionReset();
                attackSeq();
            end
        end
        local params = {  --攻击者动画的参数
            delay_time          = t_params.delay_time, --播放动画的延迟时间 策划设置
            skills_table        = skills_table,--不需要改变
            enemy_object_tab    = self.m_enemy_object_table[attackEndRef+1],--攻击的对象
            attackPos           = self.m_attackPosTable[attackEndRef+1],  --攻击的位置
            hpValue             = self.m_hurtValueTable[attackEndRef+1],    --掉血或加血
            attack_type         = skills_table.attack_type, --当前攻击者攻击的类型
            anim_equence        = skills_table.attack_equence,  --当前攻击者攻击的动画序列
            anim_sequence       = skills_table.anim_sequence,
            pos_sequence        = skills_table.pos_sequence,
            scale_sequence      = skills_table.scale_sequence,
            fade_sequence       = skills_table.fade_sequence,
            other_sequence      = skills_table.other_sequence,
            animEndCallFunc     = normalAttackEnd,    --动画播放完成之后的方法回调，用于顺序播放
        }
        self:createAttackerAnim(params);--攻击者动画接口
    end
    attackSeq();
end
--[[--
    入口
]]
function game_battle_skill.create(self,t_params)
    cclog("function:------------------------create");
    self.params = nil;
    self.m_battle_layer = nil;
    self.m_attack_object = nil;
    self.m_aim_object_table = {};
    self.m_enemy_object_table = {};
    self.m_add_object_table = {};
    self.m_startPosTable = {};
    self.m_endPosTable = {};
    self.m_attackPosTable = {};
    self.m_uReference = 0;
    self.m_tableAddHp = {};
    self.m_hurtValueTable = {};
    self.m_addValueTable = {};
    self.m_attackCenterPosTable = {};
	  self.params = t_params;
    if self.params == nil then
        return;
    end
    self.m_battle_layer = self.params.game_battle_table.m_battle_layer;
    local skillData = self.params.game_battle_table.m_currentFrameData;
    if t_params.skill_type == "add_buff" and t_params.currentFrameData then
        skillData = t_params.currentFrameData;
    end
    self.m_skill_type = t_params.skill_type
    --解析攻击者的对象
    --[[--local passValue = skillData.src
    if(passValue == nil) then
       passValue = skillData.des
    end]]--
    local tempid = tonumber(skillData.src);
    cclog("attack index ======================" .. tempid .. " ; skill_type = " .. tostring(self.params.skill_type) .. " ; name = " .. tostring(skillData.name));
    local winSize = CCDirector:sharedDirector():getWinSize();
    if tempid < 10 then
        self.m_attackCenterPosTable[1] = self.params.game_battle_table:getPosByIndex(2);
        self.m_attackCenterPosTable[2] = self.params.game_battle_table:getPosByIndex(102);
        self.m_attackCenterPosTable[3] = ccp(winSize.width * 0.65,winSize.height * 0.3);
        self.m_attackCenterPosTable[4] = ccp(winSize.width * 0.8,winSize.height * 0.4);
    else
        self.m_attackCenterPosTable[1] = self.params.game_battle_table:getPosByIndex(102);
        self.m_attackCenterPosTable[2] = self.params.game_battle_table:getPosByIndex(2);
        self.m_attackCenterPosTable[3] = ccp(winSize.width * 0.35,winSize.height * 0.3);
        self.m_attackCenterPosTable[4] = ccp(winSize.width * 0.8,winSize.height * 0.4);
    end
    self.m_attackCenterPosTable[5] = ccp(winSize.width * 0.5,winSize.height * 0.3);
    if t_params.skill_type == "skill_hero" then
        --self.m_attack_object = t_params.attack_object;
        --self.m_realPos = t_params.realPos;
    elseif t_params.skill_type == "buff_skill" then
        self.m_attack_object, self.m_realPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempid,0);
    else
        self.m_attack_object, self.m_realPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempid,0);
    end
    --攻击者不存在直接返回
    if t_params.skill_type ~= "skill_hero" and self.m_attack_object == nil then
        cclog("no attack target --------------------------------");
        self.params.game_battle_table:setCanGo(true,"m_attack_object is nil");
        self:destroy();
        return;
    end
    --判断技能文件是否存在,不存在直接返回
    local skill_name = nil;
    local fileFullPath = nil;
    if t_params.skill_type == "skill_hero" then
        skill_name = "leader_skill." .. skillData.name;
        fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("skill_effect/leader_skill/" .. skillData.name ..".lua");
    elseif t_params.skill_type == "buff_skill" then
        skill_name = "buff." .. skillData.name;
        fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("skill_effect/buff/" .. skillData.name ..".lua");
    elseif t_params.skill_type == "add_buff" then
        local tempName = skillData.name
        local firstValue,_ = string.find(tempName,",");
        if firstValue then
          local tab = util.stringSplit(tempName,",")
          skillData.name = tab[1];
        end
        skill_name = "buff." .. skillData.name;
        fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("skill_effect/buff/" .. skillData.name ..".lua");
    else
        skill_name = self.m_attack_object.animFile .. "." .. skillData.name;
        fileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("skill_effect/" .. self.m_attack_object.animFile .. "/" .. skillData.name ..".lua");
    end
    local existFlag = util.fileIsExist(fileFullPath)
    if existFlag == false then
        cclog("no file ------" .. fileFullPath);
        -- require("game_ui.game_pop_up_box").showAlertView(tostring(skillData.name));
        self.params.game_battle_table:setCanGo(true,"no skill file");
        self:destroy();
        return;
    end

    -- 解析需要攻击的对象
    local tempdid = nil;
    --cclog("findfind")
    if type(skillData.des) == "number" then
        tempdid = tonumber(skillData.des);
        local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempdid,70);
        if enemy_object ~= nil and attackPos ~= nil  then
            --cclog("enemy_object ~= nil")
            table.insert(self.m_aim_object_table,enemy_object);
            table.insert(self.m_enemy_object_table,enemy_object);
            table.insert(self.m_attackPosTable,attackPos);
        end
        --cclog("killData.des is number ------------------------" .. skillData.des);
    elseif type(skillData.des) == "table" then
        --cclog("killData.des is table ------------------------count = " .. #skillData.des);
        for index,tempdid in pairs(skillData.des) do
            local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempdid,70);
            if enemy_object ~= nil and attackPos ~= nil  then
                table.insert(self.m_aim_object_table,enemy_object);
                table.insert(self.m_enemy_object_table,enemy_object);
                table.insert(self.m_attackPosTable,attackPos);
            end
        end
    end
    if skillData.desh ~= nil and skillData.health ~= nil then
        if type(skillData.desh) == "number" then
            tempdid = tonumber(skillData.desh);
            local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempdid,70);
            if enemy_object ~= nil and attackPos ~= nil  then
                table.insert(self.m_aim_object_table,enemy_object);
                table.insert(self.m_add_object_table,enemy_object);
                --table.insert(self.m_attackPosTable,attackPos);
            end
            -- cclog("killData.des is number ------------------------" .. skillData.des);
        elseif type(skillData.desh) == "table" then
            -- cclog("killData.des is table ------------------------count = " .. #skillData.des);
            for index,tempdid in pairs(skillData.desh) do
                local enemy_object,attackPos = self.params.game_battle_table:getAnimTabAndPosByIndex(tempdid,70);
                if enemy_object ~= nil and attackPos ~= nil  then
                    table.insert(self.m_aim_object_table,enemy_object);
                    table.insert(self.m_add_object_table,enemy_object);
                    --table.insert(self.m_attackPosTable,attackPos);
                end
            end
        end
    end
    --cclog("aaaaaaa-----------------")
    if skillData.desh ~= nil then
        if skillData.health ~= nil then
            --cclog("skillData.desh--------------------------------");
            if type(skillData.health) == "number" then
                table.insert(self.m_addValueTable,skillData.health);
            elseif type(skillData.health) == "table" then
                self.m_addValueTable = skillData.health;
            end
            if type(skillData.desh) == "number" and type(skillData.health) == "number" then
                self.m_tableAddHp[skillData.desh] = skillData.health;
            elseif type(skillData.desh) == "table" and type(skillData.health) == "table" then
                for k,v in pairs(skillData.desh) do
                    if skillData.health[k] ~= nil then
                        self.m_tableAddHp[v] = skillData.health[k];
                    end 
                end
            end
        end
    elseif skillData.desh == nil and skillData.des == nil then
    elseif t_params.skill_type ~= "add_buff" and #self.m_enemy_object_table == 0 then
        self.params.game_battle_table:setCanGo(true,"no enemy target");
        self:destroy();
        return;
    end
    self.m_card = skillData.card
    --cclog("bbbbbbb-----------------")
    local hurt = skillData.hurt;
    if hurt ~= nil then
        if type(hurt) == "number" then
            table.insert(self.m_hurtValueTable,hurt);
        elseif type(hurt) == "table" then
            self.m_hurtValueTable = hurt;
        end
    else
        self.m_hurtValueTable[1] = 0;
    end
    local enemy_object_count = #self.m_enemy_object_table;--攻击的敌人数量
    for i=(#self.m_hurtValueTable + 1),enemy_object_count do
        table.insert(self.m_hurtValueTable,0);
    end
    local skill_detail_cfg = getConfig("skill_detail");
    local skill_detail_cfg_item = skill_detail_cfg:getNodeWithKey(tostring(skillData.skillid));
    if skill_detail_cfg_item then
       self.m_attack_effect = skill_detail_cfg_item:getNodeWithKey("attack_effect"):toStr();
    end
    self.m_skillName = skill_name;
    local function nameOverStartSkill()
        local skills_table = require ("skill_effect.".. self.m_skillName);
        cclog("skill name ================" .. self.m_skillName);
        cclog("skill type ================" .. self.params.skill_type);
        if skillData.desh ~= nil then
            skills_table:skillCallFunc(self,self.params.game_battle_table,self.params.currentFrameData);
        elseif(self.params.skill_type == "add_buff") or (skills_table ~= nil and type(skills_table) == "table" and table.getn(self.m_enemy_object_table) > 0 )then
            skills_table:skillCallFunc(self,self.params.game_battle_table,self.params.currentFrameData);
        else
            self:skillOver();
        end
        return
    end
    if t_params.skill_type == "skill_hero" then
       self.m_camp = t_params.camp
       self.m_skillid = skillData.skillid
       cclog("skill_hero---------skillData.skillid---------->"..tostring(skillData.skillid))
       local skills_table = require ("skill_effect.".. self.m_skillName);
       skills_table:skillCallFunc(self,self.params.game_battle_table,self.params.currentFrameData);
    elseif skillData.skillid then
       game_util:createSkillNameTips(self.m_attack_object.animNode,skillData.skillid,nameOverStartSkill);
    elseif self.params.skill_type == "add_buff" then
       nameOverStartSkill()
    else
       --game_util:createSkillNameTips(self.m_attack_object.animNode,nil,nameOverSkill,skillData.type);
       performWithDelay(self.m_attack_object.animNode,nameOverStartSkill,0.1);
    end
    -- local skill_name = "attack.ailisi_attack1";
end
function delayRealSkillStart(node,callback,time)
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(time * public_config.action_rythm));
    animArr:addObject(CCCallFunc:create(callback));
    node:runAction(CCSequence:create(animArr));
end
--[[--
    打印参数
]]
function game_battle_skill.print(self)
	cclog("self.params ===" .. tostring(self.params));
end
--[[--
    创建新表
]]
function game_battle_skill.new(self)
	  local tab = {};
	  setmetatable(tab,self);
	  self.__index = self;
	  return tab;
end

--移动动画特效
function game_battle_skill.createMoveAnim(self,t_params)
    cclog("function:------------------------createMoveAnim");
    --[[--local function delayCallFunc()
       local v = t_params.skills_table;
       local animCount = table.getn(v.flyAnim_equence);
       if animCount == 0 or v.flyAnim == nil or v.flyAnim == "" then
          self:release("createMoveAnim");
          self:release("createMoveAnim");
          return;
       end
       local mAnimStartPos,mAnimEndPos = self:getStartAndEndPos(t_params);
       local pix = math.sqrt(math.pow(mAnimStartPos.x - mAnimEndPos.x, 2) + math.pow(mAnimStartPos.y - mAnimEndPos.y, 2));
       if v.fly_v == 0 then
          v.fly_v = 100;
       end
       local play_time = pix / v.fly_v;
       local mAnimNode = nil;
       local animIndex = 1;
       local function onAnimSectionEnd(animNode, theId,theLabelName)
          if animIndex > animCount then
             animNode:playSection(theLabelName);
          else
             animNode:playSection(v.flyAnim_equence[animIndex][1])
             animNode:setRhythm(v.flyAnim_equence[animIndex][2]);
             animIndex = animIndex + 1;
          end
       end
       mAnimNode = SortNode:create(v.flyAnim .. ".swf.sam", 0, v.flyAnim.. ".plist");
       mAnimNode:setAnchorPoint(ccp(0.5,0));
       mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
       mAnimNode:playSection(v.flyAnim_equence[animIndex][1]);
       mAnimNode:setRhythm(v.flyAnim_equence[animIndex][2]*public_config.action_rythm);
       animIndex = animIndex + 1;
       mAnimNode:setPosition(mAnimStartPos);
       if mAnimStartPos.x < mAnimEndPos.x then
          mAnimNode:setFlipX(false);
       else
          mAnimNode:setFlipX(true);
       end
       self.m_battle_layer:addChild(mAnimNode);
       local function playAnimEnd()
          -- cclog("playAnimEnd -------------");
          mAnimNode:removeFromParentAndCleanup(true);
          -- self:createHurtAnim({enemy_object_tab=t_params.enemy_object_tab,hpValue=t_params.hpValue,hurtAnim=v.hurtAnim,hurtAnim_equence=v.hurtAnim_equence});
          if t_params.animEndCallFunc ~= nil then
             t_params.animEndCallFunc();
          end
          self:release("createMoveAnim");
       end
       mAnimNode:runAction(CCMoveTo:create(play_time,mAnimEndPos));
       local animArr = CCArray:create();
       animArr:addObject(CCDelayTime:create(play_time*public_config.action_rythm));
       animArr:addObject(CCCallFunc:create(playAnimEnd));
       self.m_battle_layer:runAction(CCSequence:create(animArr));
       self:release("createMoveAnim");
    end
    performWithDelay(self.m_battle_layer,delayCallFunc,t_params.delay_time);
    self:retain("createMoveAnim");--延迟的retain
    self:retain("createMoveAnim");]]--
end


--创建特效 
function game_battle_skill.createEffectsAnim(self,t_params)
    cclog("function:------------------------createEffectsAnim");
    --[[--local parentNdoe = t_params.parentNdoe;
    local function delayCallFunc()

    local anim_equence = t_params.anim_equence;
    local anim_file_name = t_params.anim_file_name;
    local animCount = table.getn(anim_equence);
    if animCount == 0 or anim_file_name == nil or anim_file_name == "" then
        self:release("createEffectsAnim");
        self:release("createEffectsAnim");
        return;
    end
    local mAnimStartPos = t_params.attackPos;
    local posOffset = battle_effect_offset[anim_file_name];
    if posOffset ~= nil then
        mAnimStartPos = ccp(t_params.attackPos.x + posOffset.x,t_params.attackPos.y + posOffset.y);
    end
    
    local play_time = t_params.play_time;
    local mAnimNode = nil;
    local animIndex = 1;
    local function onAnimSectionEnd(animNode, theId,theLabelName)
        if animIndex > animCount then
            animNode:playSection(theLabelName);
        else
            animNode:playSection(anim_equence[animIndex][1])
            animNode:setRhythm(anim_equence[animIndex][2]);
            animIndex = animIndex + 1;
        end
    end
    mAnimNode = SortNode:create(anim_file_name .. ".swf.sam", 0, anim_file_name .. ".plist");
    mAnimNode:setAnchorPoint(ccp(0.5,0));
    mAnimNode:registerScriptTapHandler(onAnimSectionEnd)
    mAnimNode:playSection(anim_equence[animIndex][1]);
    mAnimNode:setRhythm(anim_equence[animIndex][2]*public_config.action_rythm);
    animIndex = animIndex + 1;
    -- mAnimNode:setScale(self.params.game_battle_table.m_scale);
    mAnimNode:setPosition(mAnimStartPos);
    parentNdoe:addChild(mAnimNode);
    local function playAnimEnd()
        -- cclog("playAnimEnd -------------");
        mAnimNode:removeFromParentAndCleanup(true);
        if t_params.animEndCallFunc ~= nil then
            t_params.animEndCallFunc();
        end
        self:release("createEffectsAnim");
    end
    local animArr = CCArray:create();
    animArr:addObject(CCDelayTime:create(play_time*public_config.action_rythm));
    animArr:addObject(CCCallFunc:create(playAnimEnd));
    parentNdoe:runAction(CCSequence:create(animArr));
    self:release("createEffectsAnim");
    end
    performWithDelay(parentNdoe,delayCallFunc,t_params.delay_time);
    self:retain("createEffectsAnim");--延迟的retain
    self:retain("createEffectsAnim");]]--
end

return game_battle_skill;