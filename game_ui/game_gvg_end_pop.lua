--- 公会战结束动画

local game_gvg_end_pop = {
    m_popUi = nil,
    m_chest_anim = nil,
    m_animLabelName = nil,
    m_godgiftTab = nil,
    callFunc = nil,
    animFile = nil,
    m_screenShoot = nil,
};
--[[--
    销毁
]]
function game_gvg_end_pop.destroy(self)
    -- body
    cclog("-----------------game_gvg_end_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_chest_anim = nil;
    self.m_animLabelName = nil;
    self.m_godgiftTab = nil;
    self.callFunc = nil;
    self.animFile = nil;
    self.m_screenShoot = nil;
end
--[[--
    返回
]]
function game_gvg_end_pop.back(self,type)
    -- if self.callFunc then
    --     self.callFunc()
    -- end
    -- game_scene:removePopByName("game_gvg_end_pop");
    local function responseMethod(tag,gameData)
        if gameData then
            local data = gameData:getNodeWithKey("data")
            local sort = data:getNodeWithKey("sort"):toInt()
            if sort == 1 then--外围战布阵开启
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 1});
            elseif sort == 2 then--外围战战争开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 2});
            elseif sort == 3 then--内城布阵开始
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = 3});
            elseif sort == 4 then--内城战开始
                game_scene:enterGameUi("game_gvg_war_half",{gameData = gameData,sort = 4});
            elseif sort == 5 then
                
            elseif sort == -1 then--公会战未开启
                local ready = data:getNodeWithKey("ready")
                if ready then
                    local timeLeft = ready:toInt()
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                    game_util:addMoveTips({text = string_helper.game_gvg_end_pop.text .. timeLeft .. string_helper.game_gvg_end_pop.text2});
                else
                    game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = -1});
                end
                -- game_scene:addPop("game_gvg_end_pop",{callFunc = nil,enterType = "win"})
            else
                game_scene:enterGameUi("game_gvg_show",{gameData = gameData,sort = sort});
            end
        else
            -- self.netFlag = false;
        end
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_index"), http_request_method.GET, nil,"guild_gvg_index",false,true)    
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_end_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_gvg_result_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    
    local lose_sprite1 = ccbNode:scale9SpriteForName("lose_sprite1")
    local lose_sprite2 = ccbNode:scale9SpriteForName("lose_sprite2")
    local win_sprite1 = ccbNode:scale9SpriteForName("win_sprite1")
    local win_sprite2 = ccbNode:scale9SpriteForName("win_sprite2")
    local anim_node = ccbNode:nodeForName("anim_node")

    if self.enterType == "win" then
        win_sprite1:setVisible(true)
        win_sprite2:setVisible(true)
        lose_sprite1:setVisible(false)
        lose_sprite2:setVisible(false)
    else    
        win_sprite1:setVisible(false)
        win_sprite2:setVisible(false)
        lose_sprite1:setVisible(true)
        lose_sprite2:setVisible(true)
    end
    local function animCallFunc(animNode, theId,theLabelName)
        if theLabelName == "shengli" then
            self.m_animLabelName = "daiji1"
            animNode:playSection("daiji1")
        elseif theLabelName == "shibai" then
            self.m_animLabelName = "daiji2"
            animNode:playSection("daiji2")
        elseif theLabelName == "daiji2" then
            animNode:playSection("daiji2")
        elseif theLabelName == "daiji1" then
            animNode:playSection("daiji1")
        end
    end
    if self.enterType == "win" then
        self.m_animLabelName = "shengli"
    else
        self.m_animLabelName = "shibai"
    end
    local m_chest_anim = game_util:createUniversalAnim({animFile = "anim_world_jiesuan",rhythm = 1.0,loopFlag = true,animCallFunc = animCallFunc,actionName = self.m_animLabelName});
    if m_chest_anim then
        anim_node:addChild(m_chest_anim)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if self.m_animLabelName == "daiji1" or self.m_animLabelName == "daiji2" then
                self:back();
            end
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,-1000000,true);
    m_root_layer:setTouchEnabled(true);
    if self.m_screenShoot then
        local tempSize = m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        m_root_layer:addChild(self.m_screenShoot,-1);
    end
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_gvg_end_pop.refreshUi(self)

end

--[[--
    初始化
]]
function game_gvg_end_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_godgiftTab = t_params.godgiftTab or {};
    self.callFunc = t_params.callFunc
    self.enterType = t_params.enterType
    self.m_animLabelName = "win"
    self.m_screenShoot = t_params.screenShoot
end

--[[--
    创建ui入口并初始化数据
]]
function game_gvg_end_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_gvg_end_pop;