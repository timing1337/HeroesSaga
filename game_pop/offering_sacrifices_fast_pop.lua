--- 快速献祭

local offering_sacrifices_fast_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_close_btn = nil,
    m_tParams = nil,
    m_ok_btn = nil,
    m_cost_food_label = nil,
    m_cost_coin_label = nil,
    m_sel_spri_1 = nil,
    m_sel_spri_2 = nil,
    m_sel_count = nil,
    m_sel_type = nil,
    m_sacrifices_times = nil,
    m_costFood = nil,
    m_costCoin = nil,
    m_tGameData = nil,
};
--[[--
    销毁
]]
function offering_sacrifices_fast_pop.destroy(self)
    -- body
    cclog("-----------------offering_sacrifices_fast_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_close_btn = nil;
    self.m_tParams = nil;
    self.m_ok_btn = nil;
    self.m_cost_food_label = nil;
    self.m_cost_coin_label = nil;
    self.m_sel_spri_1 = nil;
    self.m_sel_spri_2 = nil;
    self.m_sel_count = nil;
    self.m_sel_type = nil;
    self.m_sacrifices_times = nil;
    self.m_costFood = nil;
    self.m_costCoin = nil;
    self.m_tGameData = nil;
end

--[[--
    返回
]]
function offering_sacrifices_fast_pop.back(self,type)
    -- game_scene:addPop("offering_sacrifices_start_pop",{callBackFunc = self.m_tParams.callBackFunc})
    game_scene:removePopByName("offering_sacrifices_fast_pop");
end
--[[--
    读取ccbi创建ui
]]
function offering_sacrifices_fast_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag > 10 and btnTag < 20 then--选择方式
            local pX,pY = tagNode:getPosition();
            local tempSize = tagNode:getContentSize();
            self.m_sel_spri_2:setPosition(ccp(pX - tempSize.width*0.4,pY))
            self.m_sel_type = btnTag - 10;
            self:refreshUi();
        elseif btnTag > 20 and btnTag < 30 then--选择次数
            local pX,pY = tagNode:getPosition();
            self.m_sel_spri_1:setPosition(ccp(pX,pY))
            local tempTag = btnTag - 20;
            self.m_sacrifices_times = 3;
            if tempTag == 2 then
                self.m_sacrifices_times = 5;
            elseif tempTag == 3 then
                self.m_sacrifices_times = 10;
            end
            self:refreshUi();
        elseif btnTag == 101 then--开始
            local ownCoin = game_data:getUserStatusDataByKey("coin") or 0
            local ownFood = game_data:getUserStatusDataByKey("food") or 0
            if self.m_costFood > ownFood then
                game_util:addMoveTips({text = string_helper.offering_sacrifices_fast_pop.lackFood})
                return;
            end
            if self.m_costCoin > ownCoin then
                game_util:addMoveTips({text = string_helper.offering_sacrifices_fast_pop.lackDimond})
                return;
            end
            self:callBackFunc("fast",{times = self.m_sacrifices_times,mode = self.m_sel_type});
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_offering_sacrifices_fast_pop.ccbi");
    -- local  title131 = ccbNode:layerForName("title131");
    -- title131:setString(string_helper.ccb.title131);
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.title132)
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    for i=1,4 do
        local tempBtn = ccbNode:controlButtonForName("m_btn_" .. i)
        if tempBtn then
            tempBtn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        end
        local tempBtn2 = ccbNode:controlButtonForName("m_auto_btn_" .. i)
        if tempBtn2 then
            tempBtn2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
        end
    end
    self.m_cost_food_label = ccbNode:labelTTFForName("m_cost_food_label")
    self.m_cost_coin_label = ccbNode:labelTTFForName("m_cost_coin_label")
    self.m_sel_spri_1 = ccbNode:spriteForName("m_sel_spri_1")
    self.m_sel_spri_2 = ccbNode:spriteForName("m_sel_spri_2")

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
function offering_sacrifices_fast_pop.refreshUi(self)
    local ownCoin = game_data:getUserStatusDataByKey("coin") or 0
    local ownFood = game_data:getUserStatusDataByKey("food") or 0
    self.m_costCoin = 0;
    if self.m_sel_type == 4 then
        self.m_costCoin = 50*self.m_sacrifices_times;
    end
    local sacrifices_times = self.m_sacrifices_times--选择的次数
    local tempTimes = 0;
    local times = self.m_tGameData.times or 0--免费剩余次数
    cclog("sacrifices_times === " .. sacrifices_times .. " ; times == " .. times)
    if times > 0 then--消耗肉
        tempTimes = sacrifices_times - times
        if tempTimes > 0 then--不够用
            self.m_costFood = (self.m_tGameData.need_food or 10000)*times;
        else
            self.m_costFood = (self.m_tGameData.need_food or 10000)*sacrifices_times;
        end
    else
        tempTimes = sacrifices_times;
    end
    if tempTimes > 0 then--消耗钻石
        local buy_times = math.max(0,self.m_tGameData.buy_times or 0);
        local buy_times_cfg = getConfig(game_config_field.pay):getNodeWithKey("17")
        local vipLevel = game_data:getVipLevel()
        local vipLevel_cfg = getConfig(game_config_field.vip):getNodeWithKey(tostring(vipLevel))
        if buy_times_cfg and vipLevel_cfg then
            local PayCfg = buy_times_cfg:getNodeWithKey("coin")
            local tempCount = PayCfg:getNodeCount();
            local buyLimit = vipLevel_cfg:getNodeWithKey("buy_godlike"):toInt()
            local payValue = 0
            for i=buy_times+1,buy_times+tempTimes do
                if i < tempCount then
                    payValue = payValue + PayCfg:getNodeAt(i-1):toInt()
                else
                    payValue = payValue + PayCfg:getNodeAt(tempCount - 1):toInt()
                end
            end
            self.m_costCoin = self.m_costCoin + payValue;
            local have_times = buyLimit - buy_times
            if have_times >= tempTimes then--次数够用
                cclog("**************** no times ****************")
            else

            end
        end
    end
    game_util:setCostLable(self.m_cost_food_label,self.m_costFood,ownFood);
    game_util:setCostLable(self.m_cost_coin_label,self.m_costCoin,ownCoin);
end

--[[--
    初始化
]]
function offering_sacrifices_fast_pop.init(self,t_params)
    self.m_tParams = t_params or {};
    self.m_tGameData = t_params.gameData or {}
    self.m_sel_count = 1;
    self.m_sel_type = 1;
    self.m_sacrifices_times = 3;
    self.m_costFood = 0;
    self.m_costCoin = 0;
end

--[[--
    创建ui入口并初始化数据
]]
function offering_sacrifices_fast_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function offering_sacrifices_fast_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return offering_sacrifices_fast_pop;