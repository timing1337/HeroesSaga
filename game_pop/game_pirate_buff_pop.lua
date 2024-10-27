--- 加buff的地方
local game_pirate_buff_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    m_itemId = nil,
    m_callBackFunc = nil,
    m_openType = nil,
    m_look_flag = nil,
    m_table_view = nil,
    m_isBeganIn = nil,
    whatsIn = nil,
    reward_node = nil,

    reward = nil,

    effect_label = nil,
    tip_label = nil,
    title_sprite = nil,
    buff_sprite = nil,
};

--[[--
    销毁
]]
function game_pirate_buff_pop.destroy(self)
    -- body
    cclog("-----------------game_pirate_buff_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    self.m_itemId = nil;
    self.m_callBackFunc = nil;
    self.m_openType = nil;
    self.m_look_flag = nil;
    self.m_table_view = nil;
    self.m_isBeganIn = nil;
    self.whatsIn = nil;
    self.reward_node = nil;

    self.reward = nil;

    self.effect_label = nil;
    self.tip_label = nil;
    self.title_sprite = nil;
    self.buff_sprite = nil;
end
--[[--
    返回
]]
function game_pirate_buff_pop.back(self,closeType)
    if closeType == "normal" then
        game_scene:removePopByName("game_pirate_buff_pop");
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_pirate_map",{gameData = gameData,reward = self.reward,tipText = self.tipText})
            -- game_scene:enterGameUi("game_pirate_map",{gameData = gameData,reward = self.reward})
            -- game_util:addMoveTips({text = string_config.pirate_buff_tip})
            self:destroy();
        end
        local params = {}
        params.treasure = self.treasure
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
    end
end
function game_pirate_buff_pop.backWithReward(self)
    local function responseMethod(tag,gameData)
        local testReward = self.reward or {}
        game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
        game_util:rewardTipsByDataTable(testReward);
        self:destroy();
    end
    local params = {}
    params.treasure = self.treasure
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
end
function game_pirate_buff_pop.backWithTips(self)
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
        game_util:addMoveTips({text = string_config.pirate_buff_tip})
        self:destroy();
    end
    local params = {}
    params.treasure = self.treasure
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
end
--[[
    开启宝箱后
]]
function game_pirate_buff_pop.openBox(self)
    
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_buff_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick(target,event)
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            if self.m_callFunc and type(self.m_callFunc) == "function" then
                self.m_callFunc("close");
            end
            self:back("normal")
        elseif btnTag == 101 then
            if self.m_openType == "BUFF" then
                local function responseMethod(tag,gameData)
                    if gameData then
                        -- game_util:addMoveTips({text = string_config.pirate_buff_tip})
                        self.tipText = string_config.pirate_buff_tip
                    end
                    -- self:back()
                    self:backWithTips()
                end
                local params = {}
                params.building = self.building
                params.city = self.city
                params.treasure = self.treasure
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_add_buff"), http_request_method.GET, params,"search_treasure_add_buff",true,true)
            else
                --播放动画
                -- local function animCallFunc(animNode, theId,theLabelName)
                --     if theLabelName == "dakai" then
                --         -- game_util:rewardTipsByJsonData(reward);
                --         -- self:back();
                --         --播放动画结束调用弹板或者获得奖励
                --         self:openBox()
                --     elseif theLabelName == "kaishi" then
                --         self.m_animLabelName = "daiji1";
                --         animNode:playSection("daiji1")
                --     else
                --         self.m_animLabelName = theLabelName;
                --         animNode:playSection(theLabelName)
                --     end
                -- end
                -- self.m_chest_anim = game_util:createUniversalAnim({animFile = "anim_baoxiang2",rhythm = 1.0,loopFlag = false,animCallFunc = animCallFunc,actionName = "kaishi"});
                -- if self.m_chest_anim then
                --     local tempSize = self.m_root_layer:getContentSize();
                --     self.m_chest_anim:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5))
                --     self.m_root_layer:addChild(self.m_chest_anim,100,100)
                -- end
                local function openBox()
                    if self.gameData.gifts_status == 1 then--直接开启宝箱
                        local function responseMethod(tag,gameData)
                            if gameData then
                                local data = gameData:getNodeWithKey("data");
                                self.reward = json.decode(data:getNodeWithKey("reward"):getFormatBuffer())
                                -- cclog2(self.reward,"self.reward")
                                -- self:back();
                                self:backWithReward()
                            end
                        end
                        local params = {};
                        params.building = self.building
                        params.city = self.city
                        params.treasure = self.treasure
                        params.gift_idx = "0"
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_add_gifts"), http_request_method.GET, params,"search_treasure_add_gifts",true,true)
                    else
                        game_scene:removePopByName("game_pirate_buff_pop");
                        game_scene:addPop("game_pirate_box_pop",{gameData = self.gameData,buildingId = self.building,city = self.city,treasure = self.treasure});
                    end
                end
                game_scene:addPop("game_chest_pop",{godgiftTab = nil,callFunc = openBox,openType = 2,animFile = "anim_baoxiang2"})
            end
        end
    end
    
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_pirate_buff.ccbi");
    self.m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-21)

    self.btn_continue = ccbNode:controlButtonForName("btn_continue")
    game_util:setCCControlButtonTitle(self.btn_continue,string_helper.ccb.title125)
    self.btn_continue:setTouchPriority(GLOBAL_TOUCH_PRIORITY-21)
    game_util:setControlButtonTitleBMFont(self.btn_continue)

    if self.landItemOpenType == 1 then--打过了隐藏
        self.btn_continue:setVisible(false)
    else
        self.btn_continue:setVisible(true)
    end

    self.effect_label = ccbNode:labelTTFForName("effect_label")
    self.tip_label = ccbNode:labelTTFForName("tip_label")
    self.title_sprite = ccbNode:spriteForName("title_sprite")
    self.buff_sprite = ccbNode:spriteForName("buff_sprite")
    self.reward_node = ccbNode:nodeForName("reward_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- cclog("self.m_animLabelName == " .. self.m_animLabelName .. " ; self.m_chest_anim ==" .. tostring(self.m_chest_anim) .. "")
            -- if self.m_animLabelName == "daiji1" then
            --     if self.m_chest_anim then
            --         self.m_animLabelName = "dakai";
            --         self.m_chest_anim:playSection("dakai")
            --     else
                    
            --     end
            -- end
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-20,true);
    self.m_root_layer:setTouchEnabled(true);
    
    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
local rewardPos = {
    {ccp(115,27)},
    {ccp(69,27),ccp(161,27)},
    {ccp(46,27),ccp(115,27),ccp(184,27)},
    {ccp(29,27),ccp(86,27),ccp(144,27),ccp(201,27)}
}
function game_pirate_buff_pop.refreshUi(self)
    if self.m_openType == "BUFF" then--BUFF
        local buff = self.gameData.buff
        local effect = buff
        local effectStr = ""
        if effect.hp then
            effectStr = effect.hp .. string_config.pirate_hp
        end
        if effect.patk then
            effectStr = effect.patk .. string_config.pirate_patk
        end
        if effect.matk then
            effectStr = effect.matk .. string_config.pirate_matk
        end
        if effect.def then
            effectStr = effect.def .. string_config.pirate_def
        end
        if effect.speed then
            effectStr = effect.speed .. string_config.pirate_speed
        end
        self.effect_label:setString(string_config.pirate_text_increase .. effectStr)
        self.tip_label:setString(string_config.pirate_text_1)
        self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pirate_title4.png"));
        self.buff_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pirate_life_water.png"));
        game_util:setCCControlButtonTitle(self.btn_continue,string_config.m_btn_use)
        self.reward_node:setVisible(false)
    else--宝箱
        self.effect_label:setString("")
        self.title_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pirate_title5.png"));
        self.buff_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pirate_box.png"));
        game_util:setCCControlButtonTitle(self.btn_continue,string_config.m_btn_open)
        self.tip_label:setString(string_config.pirate_text_2)
        self.reward_node:setVisible(true)

        --添加奖励
        self.reward_node:removeAllChildrenWithCleanup(true)
        local rewardCount = math.min(game_util:getTableLen(self.gameData.show),4) 
        for i=1,rewardCount do
             local itemData = self.gameData.show[i]
             local icon,name,count = game_util:getRewardByItemTable(itemData)
             if icon then
                icon:setScale(0.8);
                icon:setPosition(rewardPos[rewardCount][i]);
                self.reward_node:addChild(icon,10,10);

                if count > 1 then
                    local countLabel = game_util:createLabelTTF({text = "×" .. count,color = ccc3(250,180,0),fontSize = 12});
                    countLabel:setPosition(ccp(rewardPos[rewardCount][i].x,3));
                    self.reward_node:addChild(countLabel,10,11);
                end
             end
         end 
    end
end

--[[--
    初始化
]]
function game_pirate_buff_pop.init(self,t_params)
    t_params = t_params or {};
    -- cclog2(t_params.gameData,"t_params")
    self.m_openType = t_params.openType
    self.gameData = t_params.gameData
    self.building = t_params.buildingId
    self.city = t_params.city
    self.treasure = t_params.treasure
    self.landItemOpenType = t_params.landItemOpenType or 1
    self.m_animLabelName = "kaishi";
end

--[[--
    创建ui入口并初始化数据
]]
function game_pirate_buff_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_buff_pop;