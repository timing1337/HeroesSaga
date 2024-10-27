---  查看敌人了信息
local game_enemy_info_pop = {
    m_popUi = nil,
    m_root_layer = nil,

    m_life_label = nil,
    m_def_label = nil,
    m_physical_atk_label = nil,
    m_speed_label = nil,
    m_magic_atk_label = nil,
    m_skill_layer = nil,
    m_btn_node = nil,
    itemCfg = nil,
    pos = nil,
    name_label = nil,
    openType = nil,
};

--[[--
    销毁
]]
function game_enemy_info_pop.destroy(self)
    cclog("-----------------game_enemy_info_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;

    self.m_life_label = nil;
    self.m_def_label = nil;
    self.m_physical_atk_label = nil;
    self.m_speed_label = nil;
    self.m_btn_node = nil;  
    self.m_magic_atk_label = nil;
    self.m_skill_layer = nil;
    self.itemCfg = nil;
    self.pos = nil;
    self.name_label = nil;
    self.openType = nil;
end
--[[--
    返回
]]
function game_enemy_info_pop.back(self,type)
    game_scene:removePopByName("game_enemy_info_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_enemy_info_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( event,target )
        
    end
    ccbNode:openCCBFile("ccb/ui_game_enemy_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer") 


    self.m_life_label = ccbNode:labelTTFForName("m_life_label")
    self.m_def_label = ccbNode:labelTTFForName("m_def_label")
    self.m_physical_atk_label = ccbNode:labelTTFForName("m_physical_atk_label")
    self.m_speed_label = ccbNode:labelTTFForName("m_speed_label")
    self.m_magic_atk_label = ccbNode:labelTTFForName("m_magic_atk_label")
    self.m_skill_layer = ccbNode:nodeForName("m_skill_layer")
    self.m_btn_node = ccbNode:nodeForName("m_btn_node")
    self.name_label = ccbNode:labelTTFForName("name_label")

    local m_arrow_spr = ccbNode:spriteForName("m_arrow_spr")
    if self.openType == 2 then
        m_arrow_spr:setPosition(ccp(0,15))
    end
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local nodeSize = self.m_btn_node:getContentSize();
    if self.pos.x+20+nodeSize.width > visibleSize.width then
        self.m_btn_node:setPosition(ccp(self.pos.x-20-nodeSize.width ,self.pos.y))
        m_arrow_spr:setPositionX(nodeSize.width+5)
        m_arrow_spr:setFlipX(true)
    else
        self.m_btn_node:setPosition(ccp(self.pos.x+20,self.pos.y))
    end

    self.name_label:setString(self.itemCfg.enemy_name .. " lv." .. self.itemCfg.lv)
    self.m_physical_atk_label:setString(self.itemCfg.patk)
    self.m_magic_atk_label:setString(self.itemCfg.matk)
    self.m_life_label:setString(self.itemCfg.hp)
    self.m_speed_label:setString(self.itemCfg.speed)
    self.m_def_label:setString(self.itemCfg.def)

    local skllCfg = getConfig(game_config_field.skill_detail)
    for i=1,3 do
        local skillData = self.itemCfg[tostring("skill" .. i)]
        local skill_icon_spr_bg = self.m_skill_layer:getChildByTag(i)
        local icon_size = skill_icon_spr_bg:getContentSize();
        if #skillData > 0 then
            local skillId = skillData[1]
            local skillLv = skillData[2]

            local skillItemCfg = skllCfg:getNodeWithKey(tostring(skillId))
            local skill_icon_spr = game_util:createSkillIconByCfg(skillItemCfg);
            if skill_icon_spr then
                skill_icon_spr:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.5));
                skill_icon_spr_bg:addChild(skill_icon_spr);
            end
            local lvLabel = game_util:createLabel({text = "Lv." .. skillLv,color = ccc3(255, 255, 0)})
            lvLabel:setPosition(ccp(icon_size.width*0.5,icon_size.height*0.15));
            skill_icon_spr_bg:addChild(lvLabel,10,10);
            local tempLabel = game_util:createLabel({text = skillItemCfg:getNodeWithKey("skill_name"):toStr()})
            tempLabel:setPosition(ccp(icon_size.width*0.5,-icon_size.height*0.1));
            skill_icon_spr_bg:addChild(tempLabel,10,11);
            game_util:setLabelColorByQuality(tempLabel,skillItemCfg:getNodeWithKey("skill_quality"):toInt())
        end
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            self.m_isBeganIn = self.m_btn_node:boundingBox():containsPoint(realPos)
            return true;--intercept event
        elseif eventType == "ended" then
            local realPos = self.m_root_layer:convertToNodeSpace(ccp(x,y));   
            local isEndIn = self.m_btn_node:boundingBox():containsPoint(realPos)
            if isEndIn == false and self.m_isBeganIn == false then
                self:back();
                return
            end
            for i=1,3 do
                local skillIcon = self.m_skill_layer:getChildByTag(i)
                local realPos = self.m_skill_layer:convertToNodeSpace(ccp(x,y));
                if skillIcon:boundingBox():containsPoint(realPos) then
                    cclog("i == " .. i)
                    local skillData = self.itemCfg[tostring("skill" .. i)]
                    local skillId = skillData[1]
                    local skillLv = skillData[2]
                    if skillId  then
                        game_scene:addPop("skills_activation_pop",{openType="lookSkillByCid",skillId = skillId,skillLevel = skillLv})
                    end
                end
            end
            
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 15,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_enemy_info_pop.refreshUi(self)
    
end

--[[--
    初始化
]]
function game_enemy_info_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_menuTab = t_params.menuTab or {};
    self.m_callFunc = t_params.callFunc;
    if tolua.type(t_params.itemCfg) == "util_json"  then
        self.itemCfg = json.decode(t_params.itemCfg:getFormatBuffer())
    else
        self.itemCfg = t_params.itemCfg
    end
    self.openType = t_params.openType or 1
    self.pos = t_params.pos
    -- cclog("self.itemCfg == " .. json.encode(self.itemCfg))
end

--[[--
    创建ui入口并初始化数据
]]
function game_enemy_info_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_enemy_info_pop;