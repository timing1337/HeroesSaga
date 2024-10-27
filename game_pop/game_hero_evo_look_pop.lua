---  

local game_hero_evo_look_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,
    m_evo_label = nil,
    m_selHeroId = nil,
    m_skillTab = nil,
};
--[[--
    销毁
]]
function game_hero_evo_look_pop.destroy(self)
    -- body
    cclog("-----------------game_hero_evo_look_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.m_evo_label = nil;
    self.m_selHeroId = nil;
    self.m_skillTab = nil;
end
--[[--
    返回
]]
function game_hero_evo_look_pop.back(self,type)
    game_scene:removePopByName("game_hero_evo_look_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_hero_evo_look_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_hero_evo_look.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_evo_label = ccbNode:labelTTFForName("m_evo_label");
    self.m_evo_label:setString("+0");
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- self:back();
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    
]]
function game_hero_evo_look_pop.createTableView(self,viewSize)
    local cardData,heroCfg = game_data:getCardDataById(tostring(self.m_selHeroId));
    local quality = heroCfg:getNodeWithKey("quality"):toInt();
    local evolutionCfg = game_data:getEvolutionCfgByHeroCfg(heroCfg);--game_util:getEvolutionCfgByQuality(quality);
    if heroCfg == nil or evolutionCfg == nil then
        return nil;
    end
    local race = heroCfg:getNodeWithKey("race"):toInt();
    local currStep = cardData.step
    local currEvo = cardData.evo;
    local level_max = cardData.level_max;
    self.m_evo_label:setString("+" .. currStep);

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ============= " .. btnTag)
        local tempData = self.m_skillTab[btnTag];
        if tempData and tempData.s ~= nil then
            game_scene:addPop("skills_activation_pop",{skillData=tempData})
        end
    end

    local params = {};
    params.viewSize = viewSize;
    params.row = 4;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = 4;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_hero_evo_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            ccbNode:controlButtonForName("m_up_attr_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_up_attr_btn = ccbNode:controlButtonForName("m_up_attr_btn")
            m_up_attr_btn:setTag(index);
            local m_next_label = ccbNode:labelTTFForName("m_next_label");
            m_next_label:setString(string_helper.ccb.file73);
            local m_evo_label = ccbNode:labelTTFForName("m_evo_label");
            local m_skill_up_label = ccbNode:labelTTFForName("m_skill_up_label");
            m_skill_up_label:setString(string_helper.game_hero_evo_look_pop.none);
            local m_attr_label_1 = ccbNode:labelTTFForName("m_attr_label_1");
            local m_value_label_1 = ccbNode:labelTTFForName("m_value_label_1");
            local m_icon_node = ccbNode:nodeForName("m_icon_node");
            m_icon_node:removeAllChildrenWithCleanup(true);
            m_icon_node:setScale(0.75);
            m_next_label:setVisible(index == 0)
            local tempEvo = currEvo + index
            local evolutionItemCfg1 = evolutionCfg:getNodeWithKey(tostring(tempEvo))
            local evolutionItemCfg2 = evolutionCfg:getNodeWithKey(tostring(tempEvo + 1))
            if evolutionItemCfg1 and evolutionItemCfg2 then
                m_evo_label:setString(string.format(string_helper.game_hero_evo_look_pop.addBuff,evolutionItemCfg2:getNodeWithKey("step"):toInt()));

                local maxlv1 = evolutionItemCfg1:getNodeWithKey("maxlv"):toInt();
                local maxlv2 = evolutionItemCfg2:getNodeWithKey("maxlv"):toInt();
                cclog("maxlv2 =========== " .. maxlv2 .. " ; maxlv1 == " .. maxlv1)
                if maxlv2 > maxlv1 then
                    local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_dengji.png")
                    if tempIcon then
                        m_icon_node:addChild(tempIcon);
                    end
                    m_skill_up_label:setString(string_helper.game_hero_evo_look_pop.addLevel .. (maxlv2-maxlv1));
                end
                --技能
                local skill1 = evolutionItemCfg1:getNodeWithKey("skill")
                local skill2 = evolutionItemCfg2:getNodeWithKey("skill")
                local skillIndex = -1;
                local evoStep = -1;
                local evoStep1 = -1;
                for i=1,3 do
                    evoStep = skill2:getNodeAt(i-1):toInt()
                    evoStep1 = skill1:getNodeAt(i-1):toInt();
                    if evoStep ~= evoStep1 then
                        skillIndex = i;
                        break;
                    end
                end
                local skillItem = cardData["s_" .. skillIndex]
                if skillItem then
                    self.m_skillTab[index] = util.table_copy(skillItem);
                    if evoStep == 1 then
                        local tempIcon,skill_name = game_util:createSkillIconByCid(skillItem.s)
                        m_skill_up_label:setString(tostring(skill_name) .. string_helper.game_hero_evo_look_pop.skillOpen);
                        if tempIcon then
                            m_icon_node:addChild(tempIcon);
                        end
                    elseif evoStep > 1 then
                        local tempIcon,skillId,skill_name = self:getSkillEvoIcon(tostring(skillItem.s),evoStep,index,evoStep1)
                        m_skill_up_label:setString(tostring(skill_name) .. string_helper.game_hero_evo_look_pop.skillAdvance);
                        self.m_skillTab[index].s = skillId
                        if tempIcon then
                            m_icon_node:addChild(tempIcon);
                        end
                    end
                end
                --属性
                local attrValueTab = nil;
                local attrType1 = evolutionItemCfg1:getNodeWithKey("type" .. race)
                local attrType2 = evolutionItemCfg2:getNodeWithKey("type" .. race)
                if attrType1 and attrType2 then
                    local add_patk = attrType2:getNodeAt(0):toInt() - attrType1:getNodeAt(0):toInt()
                    local add_matk = attrType2:getNodeAt(1):toInt() - attrType1:getNodeAt(1):toInt() 
                    local add_def = attrType2:getNodeAt(2):toInt() - attrType1:getNodeAt(2):toInt()
                    local add_speed = attrType2:getNodeAt(3):toInt() - attrType1:getNodeAt(3):toInt()
                    local add_hp = attrType2:getNodeAt(4):toInt() - attrType1:getNodeAt(4):toInt()
                    attrValueTab = {add_patk,add_matk,add_def,add_speed,add_hp}
                else
                    attrValueTab = {0,0,0,0,0};
                end
                local attrValue,attrIndex = 0,1;
                local attrType11 = evolutionItemCfg1:getNodeWithKey("attr" .. race)
                local attrType22 = evolutionItemCfg2:getNodeWithKey("attr" .. race)
                if attrType11 and attrType22 then
                    for i=1,8 do
                        attrValue = attrType22:getNodeAt(i-1):toInt() - attrType11:getNodeAt(i-1):toInt()
                        if attrValue > 0 then
                            attrIndex = i;
                            break;
                        end
                    end
                end
                local all1 = evolutionItemCfg1:getNodeWithKey("all"):toFloat();
                local all2 = evolutionItemCfg2:getNodeWithKey("all"):toFloat();
                if all2 > all1 then
                    local tempIcon = CCSprite:createWithSpriteFrameName("hbjj_shuxing.png")
                    if tempIcon then
                        m_icon_node:addChild(tempIcon);
                    end
                    m_skill_up_label:setString(string_helper.game_hero_evo_look_pop.fullUp .. string.format("%.0f",(all2-all1)*100) .. "%");
                end
                local posIndex = 1;
                for i=1,5 do
                    local tempValue = attrValueTab[i]
                    if tempValue > 0 then
                        ccbNode:labelTTFForName("m_attr_label_" .. posIndex):setString(PUBLIC_ABILITY_TABLE["ability_" .. i].name .. ":");
                        ccbNode:labelTTFForName("m_value_label_" .. posIndex):setString("+" .. tempValue);
                        posIndex = posIndex + 1;
                    end
                    if posIndex >= 4 then
                        break;
                    end
                end
                if attrValue > 0 then
                    local attrTypeIndex = COMBAT_ABILITY_TABLE.card_evo[attrIndex]
                    local m_attr_label = ccbNode:labelTTFForName("m_attr_label_4")
                    m_attr_label:setString(PUBLIC_ABILITY_TABLE["ability_" .. attrTypeIndex].name .. ":");
                    local m_value_label = ccbNode:labelTTFForName("m_value_label_4")
                    m_value_label:setString("+" .. attrValue);
                    m_attr_label:setVisible(true)
                    m_value_label:setVisible(true)
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then
            cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    
]]
function game_hero_evo_look_pop.getSkillEvoIcon(self,skillId,evoStep,index,evoStep1)
    local tempIcon = nil;
    local skill_detail_cfg = getConfig(game_config_field.skill_detail);

    local function getIconById(tempId)
        local itemCfg = skill_detail_cfg:getNodeWithKey(tostring(tempId));
        if itemCfg then
            local is_evolution = itemCfg:getNodeWithKey("is_evolution"):toStr();
            local tempCfg = skill_detail_cfg:getNodeWithKey(tostring(is_evolution));
            local tempIcon2 = game_util:createSkillIconByCfg(tempCfg)
            return tempIcon2,is_evolution,itemCfg:getNodeWithKey("skill_name"):toStr()
        end
        return nil,nil;
    end
    local tempSkillId = skillId;
    local skill_name = "";
    for i=evoStep1,evoStep-1 do
        tempIcon,tempSkillId,skill_name = getIconById(tempSkillId)
    end
    return tempIcon,tempSkillId,skill_name;
end

--[[--
    刷新
]]
function game_hero_evo_look_pop.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    if self.m_tableView then
        self.m_tableView:setTouchEnabled(false)
        self.m_tableView:setScrollBarVisible(false);
        self.m_list_view_bg:addChild(self.m_tableView);
    end
end


--[[--
    刷新ui
]]
function game_hero_evo_look_pop.refreshUi(self)
    self:refreshTableView();
end

--[[--
    初始化
]]
function game_hero_evo_look_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_selHeroId = t_params.selHeroId;
    self.m_skillTab = {};
end

--[[--
    创建ui入口并初始化数据
]]
function game_hero_evo_look_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_hero_evo_look_pop;