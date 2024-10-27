---  点击左上角玩家头像弹出玩家信息ui

local player_profile_pop = {
    m_popUi = nil,
};
--[[--
    销毁
]]
function player_profile_pop.destroy(self)
    -- body
    cclog("-----------------player_profile_pop destroy-----------------");
    self.m_popUi = nil;
end
--[[--
    返回
]]
function player_profile_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("player_profile_pop");
end
--[[--
    读取ccbi创建ui
]]
function player_profile_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        elseif btnTag == 103 then

        local ui_all_rank = require("game_ui.ui_all_rank")
        ui_all_rank.enterAllRankByRankName( "rank_level" )
            -- local function responseMethod(tag,gameData)
            --     local data = gameData:getNodeWithKey("data")
            --     -- cclog("data = " .. data:getFormatBuffer())
            --     game_scene:enterGameUi("ui_levelap_rank",{gameData = json.decode(data:getFormatBuffer())})
            -- end
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("rank_combat"), http_request_method.GET, {page = 0},"rank_combat")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_player_profile.ccbi");
    local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
    local m_food_label = ccbNode:labelBMFontForName("m_food_label")
    local m_material_label = ccbNode:labelBMFontForName("m_material_label")
    local m_crystal_label = ccbNode:labelBMFontForName("m_crystal_label")
    local m_star_label = ccbNode:labelBMFontForName("m_star_label")
    local m_dirt_gold_label = ccbNode:labelBMFontForName("m_dirt_gold_label")
    local m_dirt_silver_label = ccbNode:labelBMFontForName("m_dirt_silver_label")
    local m_rank_Integration_label = ccbNode:labelBMFontForName("m_rank_Integration_label")
    local m_blabel_gold = ccbNode:labelBMFontForName("m_blabel_gold")                         -- 显示金币





    local m_combat_label = ccbNode:labelBMFontForName("m_combat_label")
    -- local m_ranking_label = ccbNode:labelTTFForName("m_ranking_label")
    -- local m_union_name_label = ccbNode:labelTTFForName("m_union_name_label")
    
    local m_name_label = ccbNode:labelTTFForName("m_name_label")
    
    local m_uid_label = ccbNode:labelBMFontForName("m_uid_label")
    local m_level_label = ccbNode:labelBMFontForName("m_level_label")

    local resourceData = game_data:getResourceData()
    local userStatusData = game_data:getUserStatusData();
    m_name_label:setString(tostring(userStatusData.show_name));
    local sb_list = {}
    for i=1,4 do
        sb_list[i] = ccbNode:labelTTFForName("m_name_label_" .. i)
        sb_list[i]:setString(tostring(userStatusData.show_name));
    end
    m_uid_label:setString(tostring(userStatusData.uid));
    m_level_label:setString("Lv." .. tostring(userStatusData.level));
    local tempText,_ = game_util:formatValueToString(userStatusData.food)
    m_food_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(userStatusData.metal)
    m_material_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(userStatusData.crystal)
    m_crystal_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(userStatusData.star)
    m_star_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(userStatusData.dirt_gold)
    m_dirt_gold_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(userStatusData.dirt_silver)
    m_dirt_silver_label:setString(tostring(tempText));
    local tempText,_ = game_util:formatValueToString(game_data:getArenaPoint())
    m_rank_Integration_label:setString(tostring(tempText));
    local total_silver = game_data:getUserStatusDataByKey("silver") or 0;
    local tempText,_ = game_util:formatValueToString(total_silver)
    m_blabel_gold:setString(tostring(tempText));

    m_combat_label:setString(game_util:getCombatValue());
    -- m_union_name_label:setString("无")
    -- local arenaRank = game_data:getArenaRank();
    -- if arenaRank == 0 then
    --     m_ranking_label:setString("无排名")
    -- else
    --     m_ranking_label:setString(tostring(arenaRank))
    -- end
    local m_anim_node = ccbNode:nodeForName("m_anim_node")
    m_anim_node:removeAllChildrenWithCleanup(true);
    local role_detail_cfg = getConfig(game_config_field.role_detail);
    local role = userStatusData.role;
    if role and role_detail_cfg then
        local itemCfg = role_detail_cfg:getNodeWithKey(tostring(role));
        local temp_big_img = CCSprite:create("humen/" .. itemCfg:getNodeWithKey("img"):toStr() .. ".png");
        temp_big_img:setAnchorPoint(ccp(0.5, 0));
        temp_big_img:setScale(0.5);
        if temp_big_img then
            m_anim_node:addChild(temp_big_img)
        end
    end

    local m_close_btn = tolua.cast(ccbNode:objectForName("m_close_btn"), "CCControlButton");
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:back();
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    local m_conbtn_rank = ccbNode:controlButtonForName("m_conbtn_rank")
    m_conbtn_rank:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);

    return ccbNode;
end
--[[--
    刷新ui
]]
function player_profile_pop.refreshUi(self)

end

--[[--
    初始化
]]
function player_profile_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function player_profile_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return player_profile_pop;