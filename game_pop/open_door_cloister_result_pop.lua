---  回廊  结算
local open_door_cloister_result_pop = {
    win_sprite = nil,
    spriteTips = nil,
    tips_label = nil,
    win_node = nil,
    lose_node = nil,
    last_value = nil,
    now_value = nil,
    maze = nil,
    winFlag = nil,
};
--[[--
    销毁ui
]]
function open_door_cloister_result_pop.destroy(self)
    -- body
    cclog("-----------------open_door_cloister_result_pop destroy-----------------");
    self.win_sprite = nil;
    self.spriteTips = nil;
    self.tips_label = nil;
    self.win_node = nil;
    self.lose_node = nil;
    self.last_value = nil;
    self.now_value = nil;
    self.maze = nil;
    self.winFlag = nil;
end
--[[--
    返回
]]
function open_door_cloister_result_pop.back(self,backType)
    if self.winFlag == "win" then
        game_scene:removePopByName("open_door_cloister_result_pop");
    else
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("open_door_cloister",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("maze_index"), http_request_method.GET, nil,"maze_index")
    end
end
--[[--
    读取ccbi创建ui
]]
function open_door_cloister_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    ccbNode:openCCBFile("ccb/ui_open_door_cloister_resultpop.ccbi");
    
    self.win_sprite = ccbNode:spriteForName("win_sprite")
    self.spriteTips = {}
    self.spriteTips[1] = ccbNode:spriteForName("result_sprite1")
    self.spriteTips[2] = ccbNode:scale9SpriteForName("result_sprite2")
    self.spriteTips[3] = ccbNode:scale9SpriteForName("result_sprite3")
    self.spriteTips[4] = ccbNode:spriteForName("result_sprite4")
    self.spriteTips[5] = ccbNode:scale9SpriteForName("result_sprite5")
    self.spriteTips[6] = ccbNode:scale9SpriteForName("result_sprite6")
    -- for i=1,3 do
    --     self.spriteTips[i] = ccbNode:spriteForName("result_sprite" .. i)
    -- end
    self.tips_label = ccbNode:labelTTFForName("tips_label")
    self.win_node = ccbNode:nodeForName("win_node")
    self.lose_node = ccbNode:nodeForName("lose_node")
    self.last_value = ccbNode:labelTTFForName("last_value")
    self.now_value = ccbNode:labelTTFForName("now_value")


    local m_root_layer = ccbNode:layerColorForName("m_root_layer")
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
           self:back()
        end
    end

    local animName = "Default Timeline"
    local function animCallFunc(animName)
        
    end
    ccbNode:registerAnimFunc(animCallFunc);
    ccbNode:runAnimations(animName)

    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    刷新ui
]]
function open_door_cloister_result_pop.refreshUi(self)
    local tempSprite = {}
    local winFlag = true
    if self.winFlag == "win" then
        tempSprite = winSprite
        winFlag = true
        self.win_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_win.png"));
        for i=1,3 do
            self.spriteTips[i]:setVisible(true)
            self.spriteTips[i+3]:setVisible(false)
        end
        self.tips_label:setString(string.format(string_helper.open_door_cloister_result_pop,(self.maze.layer - 1)))
    else
        tempSprite = loseSprite
        winFlag = false
        self.win_sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("huilang_lose.png"));
        for i=1,3 do
            self.spriteTips[i]:setVisible(false)
            self.spriteTips[i+3]:setVisible(true)
        end
        self.tips_label:setString(string_helper.open_door_cloister_result_pop.pity)
        self.tips_label:setColor(ccc3(149,149,149))
        local bar = ExtProgressTime:createWithFrameName("huilang_liehen2.png","huilang_liehen.png");
        bar:setMaxValue(100);
        local itemSize = self.lose_node:getContentSize();
        bar:setCurValue(0,false);
        bar:setCurValue(100,true,1.5);
        bar:setAnchorPoint(ccp(0.5,0.5))
        bar:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5-5))
        self.lose_node:addChild(bar,10)
    end
    self.win_node:setVisible(winFlag)
    self.lose_node:setVisible(not winFlag)
    self.last_value:setString(tostring(self.lastScore))
    self.now_value:setString(tostring(self.maze.score))
    --一个提示动画
    local score = self.maze.score or 0
    local moveTips = game_util:createLabelTTF({text = "+" .. (score - self.lastScore),color = ccc3(142,251,74),fontSize = 10});
    moveTips:setPosition(ccp(10,0))
    local function remove_node( node )
        node:removeFromParentAndCleanup(true);
    end
    local remove = CCCallFuncN:create(remove_node);
    local arr = CCArray:create();
    arr:addObject(CCEaseIn:create(CCMoveTo:create(1,ccp(10,20)),5));
    arr:addObject(CCDelayTime:create(1));
    arr:addObject(remove);
    moveTips:runAction(CCSequence:create(arr));
    self.now_value:addChild(moveTips)
end
--[[--
    初始化
]]
function open_door_cloister_result_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_tGameData = t_params.gameData or {}
    self.m_stageId = t_params.stageId;
    self.m_callBackFunc = t_params.callBackFunc;
    self.winFlag = t_params.winFlag
    self.maze = t_params.maze or {}
    self.lastScore = t_params.lastScore or 0
end

--[[--
    创建ui入口并初始化数据
]]
function open_door_cloister_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return open_door_cloister_result_pop;