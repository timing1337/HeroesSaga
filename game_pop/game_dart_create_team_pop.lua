--- 押镖创建队伍
local game_dart_create_team_pop = {
    m_popUi = nil,
    m_root_layer = nil,
    m_ccbNode = nil,
    
    goods_id = nil,
};

--[[--
    销毁
]]
function game_dart_create_team_pop.destroy(self)
    -- body
    cclog("-----------------game_dart_create_team_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_ccbNode = nil;
    
    self.goods_id = nil;
end
--[[--
    返回
]]
function game_dart_create_team_pop.back(self,type)
    -- game_scene:removePopByName("game_dart_create_team_pop");
    -- self:destroy()
    local function responseMethod(tag,gameData)
        local is_sail = gameData:getNodeWithKey("data"):getNodeWithKey("is_sail"):toInt()--是否开始运送货物了
        if is_sail == 1 then
            game_scene:enterGameUi("game_dart_route",{gameData = gameData})
        else
            local identity = gameData:getNodeWithKey("data"):getNodeWithKey("identity"):toInt()--0是无对1是队长2是队员
            if identity == 0 then
                game_scene:enterGameUi("game_dart_main",{gameData = gameData});
            else
                game_scene:enterGameUi("game_dart_my_team",{gameData = gameData,identity = identity})
            end
        end
        self:destroy()
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_index"), http_request_method.GET, nil,"escort_index")
end
--[[--
    读取ccbi创建ui
]]
function game_dart_create_team_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--招募队员
            if self.goods_id then--可以创建
                local function responseMethod(tag,gameData)
                    game_scene:addPop("game_dart_team_info",{gameData = gameData})
                end
                local params = {}
                params.goods_id = self.goods_id
                params.buff_sort = 0
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_create_goods_team"), http_request_method.GET, params,"escort_create_goods_team")
            else
                game_util:addMoveTips({text = string_helper.game_dart_create_team_pop.addPartnerTips})
            end
        elseif btnTag == 3 then--添加货物
            -- game_util:addMoveTips({text = "需要先招募队员才能加持！"})
            local function responseMethod(tag,gameData)
                game_scene:addPop("game_dart_goods",{gameData = gameData})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_my_goods"), http_request_method.GET, nil,"escort_my_goods")
        elseif btnTag == 4 then--加持  买buff
            game_util:addMoveTips({text = string_helper.game_dart_create_team_pop.buffTips})
            -- local function responseMethod(tag,gameData)
            --     cclog2(gameData:getNodeWithKey("data"))
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("escort_refresh_vehicle_buff"), http_request_method.GET, nil,"escort_refresh_vehicle_buff")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_dart_create_team_pop.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"),"CCLayer");
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    local refresh_btn = ccbNode:controlButtonForName("refresh_btn")
    local zhaomu_btn = ccbNode:controlButtonForName("zhaomu_btn")
    local add_goods_btn = ccbNode:controlButtonForName("add_goods_btn")
    self.m_spr_bg = ccbNode:spriteForName("m_spr_bg")
    self.goods_node = ccbNode:nodeForName("goods_node")

    refresh_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    zhaomu_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)
    add_goods_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY-6)

    self.ship_type_spr = ccbNode:spriteForName("ship_type_spr")
    self.tips_label = ccbNode:labelTTFForName("tips_label")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY-5,true);
    m_root_layer:setTouchEnabled(true);
    
    if self.goods_id then
        self.m_spr_bg:setVisible(false)
        self.goods_node:removeAllChildrenWithCleanup(true)
        local goods = self.goods_info.goods[1]
        local icon,name,count = game_util:getRewardByItemTable(goods)
        if icon then
            self.goods_node:addChild(icon)
            if count then
                local countLabel = game_util:createLabelBMFont({text = "×" .. count});
                countLabel:setPosition(ccp(0,-15))
                self.goods_node:addChild(countLabel,10)
            end
        end
        add_goods_btn:setEnabled(false)
    end

    self.m_ccbNode = ccbNode;
    return ccbNode;
end
--[[--
    刷新ui
]]
function game_dart_create_team_pop.refreshUi(self)
    
end
--[[--
    初始化
]]
function game_dart_create_team_pop.init(self,t_params)
    t_params = t_params or {};
    self.goods_id = t_params.goods_id
    self.goods_info = t_params.goods_info
end

--[[--
    创建ui入口并初始化数据
]]
function game_dart_create_team_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_dart_create_team_pop;