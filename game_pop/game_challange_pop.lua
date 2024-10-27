---  ui模版

local game_challange_pop = {
    m_node_listbg = nil,
    m_tGameData = nil,
    search_treasure = nil,
};
--[[--
    销毁ui
]]
function game_challange_pop.destroy(self)
    -- body
    cclog("----------------- game_challange_pop destroy-----------------"); 
    self.m_node_listbg = nil;
    self.m_tGameData = nil;
    self.search_treasure = nil;
end
--[[--
    返回
]]
function game_challange_pop.back(self,backType)
    local function endCallFunc()
        self:destroy();
    end
    game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_challange_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_challange_pop.ccbi");

    self.m_node_listbg = ccbNode:nodeForName("m_node_listbg")

    -- -- 光效 显示
    -- local falsh_blindness = ccbNode:spriteForName("falsh_blindness")
    -- falsh_blindness:runAction(game_util:createRepeatForeverFade());

    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)     
        if eventType == "began" then return true;  end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    return ccbNode;
end

--[[--
    创建列表
]]
function game_challange_pop.createChallangeList( self, viewSize )
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        --详细信息
        local key = ""
        if btnTag == 0 then
            key = "119"
        elseif btnTag == 1 then
            key = "117"
        elseif btnTag == 2 then

        end
        local function endFunc()
            game_scene:removePopByName("game_tips_info_pop");
        end
        game_scene:addPop("game_tips_info_pop",{notice_key = key, endFunc = endFunc})
    end
    local itemCount = 3
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;
    params.column = 3;
    params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = itemCount;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-5;
    local itemSize = CCSizeMake(viewSize.width / params.column, viewSize.height/params.row);
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell();
        if cell == nil then 
            cell = CCTableViewCell:new()
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_challange_item.ccbi")       
            ccbNode:setAnchorPoint(ccp(0.5, 0.5))
            ccbNode:setPosition(ccp(itemSize.width * 0.5, itemSize.height * 0.5));
            ccbNode:controlButtonForName("m_info_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY - 6)
            cell:addChild(ccbNode, 10, 10)
        end
        if cell then  
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")    
            local m_sprie_wait = ccbNode:spriteForName("m_sprie_wait")
            local m_sprite_show = ccbNode:spriteForName("m_sprite_show")
            local m_info_btn = ccbNode:controlButtonForName("m_info_btn")
            m_info_btn:setTag(index)
            if m_sprie_wait and index == 0 and game_data:isViewOpenByID(46) then
                m_sprie_wait:setVisible(false)
                m_info_btn:setVisible(true)
            elseif m_sprie_wait and index == 1 and game_data:isViewOpenByID(47) then
                m_sprie_wait:setVisible(false)
                m_info_btn:setVisible(true)
            -- elseif m_sprite_show and index == 2 and game_data:isViewOpenByID(48) then
            --     m_sprie_wait:setVisible(false)
            --     m_info_btn:setVisible(true)
            else
                m_info_btn:setVisible(false)
                m_sprite_show:setColor(ccc3(155, 155, 155))
            end

            local tempFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui_challange_banner_" .. (index + 1) ..".png")
            if m_sprite_show and tempFrame then
                m_sprite_show:setDisplayFrame(tempFrame)
            end
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, cell )
        if eventType == "ended" and cell then
            if index == 0 and game_data:isViewOpenByID(46) then
                -- 最牛玩家
                function shopOpenResponseMethod(tag,gameData)
                    game_scene:enterGameUi("game_topplayer_scene",{gameData = gameData})
                end
                network.sendHttpRequest(shopOpenResponseMethod,game_url.getUrlForKey("playerboss_index"), http_request_method.GET, {},"playerboss_index")
            elseif index == 1 and game_data:isViewOpenByID(47) then--罗杰的宝藏
                -- local text = string_config:getTextByKey("game_challange_active1")
                -- game_util:addMoveTips({text = text})   

                -----暂定写成33开启
                -- local activeCfg = getConfig(game_config_field.active_cfg)
                -- local itemCfg = activeCfg:getNodeWithKey("90")
                -- local level = itemCfg:getNodeWithKey("level")
                -- local downLimit = level:getNodeAt(0):toInt()
                -- local upLimit = level:getNodeAt(1):toInt()
                local downLimit = 33
                if game_data:getUserStatusDataByKey("level") >= downLimit then
                    self:enterPrecious()
                else
                    game_util:addMoveTips({text = downLimit .. string_helper.game_challange_pop.openLevel})
                end
            elseif index == 2 then
                local text = string_config:getTextByKey("game_challange_active2")
                game_util:addMoveTips({text = text})   
            else
                game_util:addMoveTips({text = string_helper.game_challange_pop.openTips})
            end
        end
    end
    return TableViewHelper:create(params)
end
--[[
    进入罗杰的宝藏
]]
function game_challange_pop.enterPrecious(self)
    local cur_time = self.search_treasure["cur_times"]
    local times = self.search_treasure["times"]
    local treasure = tonumber(self.search_treasure["treasure"])
    -- cclog2(game_data:getTreasure(),"treasure    ===  ")
    game_data:setTreasure(treasure)
    if cur_time < times or treasure > 0 then--当前可打小于总的或有正在进行的可以打
        if treasure > 0 then--有正在进行的直接进入
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_pirate_map",{gameData = gameData})
                self:destroy();
            end
            local params = {}
            params.treasure = treasure
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_st_open"), http_request_method.GET, params,"search_treasure_st_open")
        else
            game_scene:enterGameUi("game_pirate_precious",{})
            self:destroy();
        end
    else--不可打，判断是否可以买
        local vipCfg = getConfig(game_config_field.vip);
        local vipLevel = game_data:getVipLevel()
        local vipItemCfg = vipCfg:getNodeWithKey(tostring(vipLevel))
        local treasure_time = vipItemCfg:getNodeWithKey("treasure_time"):toInt()--1是可以购买一次
        if treasure_time == 0 then--活动次数等于0并且step也为0
            game_util:addMoveTips({text = string_helper.game_challange_pop.fightLimit})
        else
            --以后加vip
            local cur_buy_times = self.search_treasure["cur_buy_times"]
            if cur_buy_times < treasure_time then
                local function responseMethod(tag,gameData)
                    game_scene:enterGameUi("game_pirate_precious",{});
                    self:destroy();
                end
                --钱从pay config id 21
                local payCfg = getConfig(game_config_field.pay)
                local itemCfg = payCfg:getNodeWithKey("21")
                cclog2(itemCfg,"itemCfg")
                cclog2(cur_buy_times,"cur_buy_times")
                cclog2(treasure_time,"treasure_time")
                local coin = itemCfg:getNodeWithKey("coin"):getNodeAt(cur_buy_times):toInt()
                --换成统一的提示
                local t_params = 
                {
                    m_openType = 10,
                    coin = coin,
                    m_ok_func = function()
                        game_scene:removePopByName("game_normal_tips_pop");
                        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("search_treasure_recover_times"), http_request_method.GET, {},"search_treasure_recover_times")
                    end
                }
                game_scene:addPop("game_normal_tips_pop",t_params)
            else
                game_util:addMoveTips({text = string_helper.game_challange_pop.fightLimit})
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_challange_pop.refreshUi(self)
    self.m_node_listbg:removeAllChildrenWithCleanup(true)
    local view = self:createChallangeList(self.m_node_listbg:getContentSize())
    self.m_node_listbg:addChild(view)
end
--[[--
    初始化
]]
function game_challange_pop.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        local search_treasure = data:getNodeWithKey("search_treasure") 
        if search_treasure then
            self.search_treasure = json.decode(search_treasure:getFormatBuffer())
        end
    end
end
--[[--
    创建ui入口并初始化数据
]]
function game_challange_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_challange_pop