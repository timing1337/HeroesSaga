--- 罗杰宝藏结束界面
local game_pirate_result_pop = {
    m_popUi = nil,
    m_root_layer = nil, 
    m_tParams = nil,

    m_close_btn = nil,
    complete_label = nil,
    reward_node = nil,
    winType = nil,
};
--[[--
    销毁
]]
function game_pirate_result_pop.destroy(self)
    -- body
    cclog("-----------------game_pirate_result_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_tParams = nil;

    self.m_close_btn = nil;

    self.complete_label = nil;
    self.reward_node = nil;
    self.winType = nil;
end
--[[--
    返回
]]
function game_pirate_result_pop.back(self,type)
    -- local function responseMethod(tag,gameData)
    --     game_scene:removePopByName("game_pirate_result_pop");
    --     self:destroy();
    --     game_scene:enterGameUi("game_activity",{gameData = gameData});
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_pirate_result_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 101 then--求助
            local function responseMethod(tag,gameData)
                if gameData then
                    game_util:addMoveTips({text = string_helper.game_pirate_result_pop.helpInfo})
                    self.winBtn:setEnabled(false)
                end
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_help_treasure"), http_request_method.GET, nil,"search_treasure_help_treasure",true,true)
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_pirate_result_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer")

    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)
    
    self.complete_label = ccbNode:labelTTFForName("complete_label")
    self.reward_node = ccbNode:nodeForName("reward_node")
    local title108 = ccbNode:labelTTFForName("title108");
    local title109 = ccbNode:labelTTFForName("title109");
    local title110 = ccbNode:labelTTFForName("title110");
    local title111 = ccbNode:labelTTFForName("title111");
    local title112 = ccbNode:labelTTFForName("title112");
    title108:setString(string_helper.ccb.title108);
    title109:setString(string_helper.ccb.title109);
    title110:setString(string_helper.ccb.title110);
    title111:setString(string_helper.ccb.title111);
    title112:setString(string_helper.ccb.title112);
    self.winBtn = ccbNode:controlButtonForName("btn_win")
    game_util:setCCControlButtonTitle(self.winBtn,string_helper.ccb.title113)
    game_util:setControlButtonTitleBMFont(self.winBtn)
    self.winBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-1)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_pirate_result_pop.refreshUi(self)
    -- local rewardList = {{1,0,100},{1,0,100},{1,0,100},{1,0,100}}
    local rewardList = self.regain_reward
    local rewardCount = game_util:getTableLen(rewardList)
    local nodeSize = self.reward_node:getContentSize()
    local dw = nodeSize.width / rewardCount
    local dx = dw / 2
    for i=1,math.min(5,rewardCount) do
        itemData = rewardList[i];
        if itemData then
            local icon,name,count = game_util:getRewardByItemTable(itemData)
            if icon then
                icon:setScale(0.8)
                icon:setPosition(ccp(dx + (i-1)*dw,18));
                self.reward_node:addChild(icon,1,1);
            end
            if count then
                local blabelCount = game_util:createLabelBMFont({text = string.format("x%d", count)})
                blabelCount:setAnchorPoint(ccp(0.5, 0.5))
                blabelCount:setPosition(ccp(dx + (i-1)*dw,0))
                self.reward_node:addChild(blabelCount,1,2);
            end
        end
    end
    self.complete_label:setString(self.curt_regain .. "%")
    if self.winType == "win" then
        self.winBtn:setVisible(false)
    else
        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then
            self.winBtn:setVisible(false)
        else
            self.winBtn:setVisible(true)
        end
    end
end
--[[--
    初始化
]]
function game_pirate_result_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.regain_reward = t_params.regain_reward
    self.curt_regain = t_params.curt_regain
    self.winType = t_params.winType
end
--[[--
    创建ui入口并初始化数据
]]
function game_pirate_result_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_pirate_result_pop;