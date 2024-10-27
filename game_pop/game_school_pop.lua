--- game_school_pop信息

local game_school_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,

    itemData = nil,
    time_index = nil,
    selHeroId = nil,
    train_type = nil,
};

--[[--
    销毁
]]
function game_school_pop.destroy(self)
    -- body
    cclog("-----------------game_school_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.itemData = nil;

    self.time_index = nil;
    self.selHeroId = nil;
    self.train_type = nil;
end
--[[--
    返回
]]
function game_school_pop.back(self,type)
    game_scene:removePopByName("game_school_pop");
end

local multiple_times_table = {"100%","120%","150%","200%","300%"};
local train_time_table = {"01:00:00","02:00:00","04:00:00","08:00:00","12:00:00"}
local hour_table = {1,2,4,8,12}
--[[--
    读取ccbi创建ui
]]
function game_school_pop.createUi(self)
    local config_date = getConfig(game_config_field.item):getNodeWithKey(tostring(self.m_itemId));
    local ccbNode = luaCCBNode:create();

    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_school_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local train_mode_label_1 = ccbNode:labelTTFForName("train_mode_label_1");
    local rest_time_label_1 = ccbNode:labelTTFForName("rest_time_label_1");
    local gain_exp_label_1 = ccbNode:labelTTFForName("gain_exp_label_1");
    local des_label = ccbNode:labelTTFForName("des_label");
    --
    local m_race_label = ccbNode:labelTTFForName("m_race_label");
    local m_occupation_icon = ccbNode:spriteForName("m_occupation_icon");
    local m_anim_node = ccbNode:nodeForName("m_anim_node");
    local m_level_label = ccbNode:labelTTFForName("m_level_label");
    local m_name_label = ccbNode:labelTTFForName("m_name_label");

    local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
    local title80 = ccbNode:labelTTFForName("title80")
    local title81 = ccbNode:labelTTFForName("title81")
    local title82 = ccbNode:labelTTFForName("title82")
    local title83 = ccbNode:labelTTFForName("title83")
    local title84 = ccbNode:labelTTFForName("title84")
    title80:setString(string_helper.ccb.title80);
    title81:setString(string_helper.ccb.title81);
    title82:setString(string_helper.ccb.title82);
    title83:setString(string_helper.ccb.title83);
    title84:setString(string_helper.ccb.title84);
    game_util:setCCControlButtonTitle(m_buy_btn,string_helper.ccb.title85)
    game_util:setControlButtonTitleBMFont(m_buy_btn)
    m_buy_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    -- local character_detail_cfg = getConfig(game_config_field.character_detail);
    local cardData,heroCfg = game_data:getCardDataById(self.selHeroId);

    local race_cfg = getConfig(game_config_field.race);
    --种族
    local race_item_cfg = race_cfg:getNodeWithKey(heroCfg:getNodeWithKey("race"):toStr());
    if race_item_cfg then
        m_race_label:setString(race_item_cfg:getNodeWithKey("name"):toStr());
    else
        m_race_label:setString(string_helper.game_school_pop.noRace);
    end
    --名称
    local name_after = cardData.step < 1 and "" or ("+" .. cardData.step);
    m_name_label:setString(heroCfg:getNodeWithKey("name"):toStr() .. name_after);
    --级别
    -- m_level_label:setString(cardData.lv .. "/" .. cardData.level_max);
    m_level_label:setString(cardData.lv);
    --人物图
    local ainmFile = heroCfg:getNodeWithKey("animation"):toStr();
    local animNode = game_util:createAnimSequence(ainmFile,0,cardData,heroCfg);
    if animNode then
        animNode:setRhythm(1);
        animNode:setAnchorPoint(ccp(0.5,0));
        animNode:setScale(0.7);
        m_anim_node:addChild(animNode);
    end
    --职业
    local occupation_cfg = getConfig(game_config_field.occupation);
    local occupation_item_cfg = occupation_cfg:getNodeWithKey(ainmFile)
    if occupation_item_cfg then
        local occupationType = occupation_item_cfg:toInt();
        local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("public_ocupation" .. occupationType .. ".png")
        if spriteFrame then
            m_occupation_icon:setDisplayFrame(spriteFrame);
        end
    end

    train_mode_label_1:setString(multiple_times_table[self.train_type])
    rest_time_label_1:setString(train_time_table[self.time_index])

    --计算可获得经验
    local character_train_time_config = getConfig("character_train_time");
    local character_train_rate_config = getConfig("character_train_rate");

    local timeItem = character_train_time_config:getNodeWithKey(tostring(self.time_index));
    local time_need = 0
    if timeItem then
        time_need = timeItem:getNodeWithKey("time"):toInt()*60;
    end
    local percent = 0
    local typeItem = character_train_rate_config:getNodeWithKey(tostring(self.train_type));
    if typeItem then
        percent = typeItem:getNodeWithKey("exp_rate"):toInt();
    end

    local building_base_school = getConfig(game_config_field.role);
    local level = game_data:getUserStatusDataByKey("level") or 1;
    local schoolItem = building_base_school:getNodeWithKey(tostring(level));
    local gainExp = 0;
    if schoolItem then
        local get_exp_min = schoolItem:getNodeWithKey("get_exp_min");
        if get_exp_min then
            gainExp = time_need*get_exp_min:toInt()*percent*0.01
        end
    end
    gain_exp_label_1:setString(gainExp)
    --完成时间
    local today = os.date("*t")
    local hour = today.hour
    local min = today.min
    local com_hour = hour + hour_table[self.time_index]

    local hourStr = ""
    local minStr = ""
    if com_hour >= 24 then
        hourStr = (com_hour-24)
        minStr = min
        if (com_hour-24) < 10 then
            hourStr = "0" .. (com_hour-24)
        end
        if min < 10 then
            minStr = "0" .. min
        end
        des_label:setString(string_helper.game_school_pop.tomorow .. hourStr .. ":" .. minStr);
    else
        hourStr = com_hour
        minStr = min
        if com_hour < 10 then
            hourStr = "0" .. com_hour
        end
        if min < 10 then
            minStr = "0" .. min
        end
        des_label:setString(string_helper.game_school_pop.today .. hourStr .. ":" .. minStr);
    end

    local function onTouch( eventType,x,y )
        -- body
        if(eventType == "began")then
            self:back();
            return true;
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-10,true);
    m_root_layer:setTouchEnabled(true);
    
    
    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"),"CCControlButton");

    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    self.m_ccbNode = ccbNode;
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_school_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_school_pop.init(self,t_params)
    t_params = t_params or {};
    -- cclog("t_params = " .. json.encode(t_params))
    self.time_index = t_params.time_index;
    self.selHeroId = t_params.selHeroId;
    self.train_type = t_params.train_type;
    self.itemData = t_params.itemData
end

--[[--
    创建ui入口并初始化数据
]]
function game_school_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_school_pop;