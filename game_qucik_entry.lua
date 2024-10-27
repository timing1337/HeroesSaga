-- 某些地方用到前往功能 
local M = {}


function gtactivity( itemIndex, chapterID )
    -- if itemIndex == 50 or itemIndex == 20 then
    --     game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
    --                 game_data:setLeatestActivityIndex( tostring(itemIndex) )
    --             end});
    -- end
    local function responseMethod(tag,gameData)
        game_scene:removePopByName("game_help_new_pop");
        game_data:setLeatestActivityIndex( tostring(itemIndex) )
        game_scene:addPop("game_activity_new_pop",{gameData = gameData})
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end

local game_button_ids = {}
-- 卡牌分解
-- 装备精炼
-- 装备分解
game_button_ids["btn105"] = { name = "马上有经验" , btnId = 105, resFramesName = "ccbResources/activity.plist", spriteName = "button_active_exp", goToCallFun = gtactivity, itemIndex = 70};    -- 马上有经验   17级开启   不引导
game_button_ids["btn106"] = { name = "资源争夺战", btnId = 106, resFramesName = "ccbResources/activity.plist",spriteName = "button_active_resource", goToCallFun = gtactivity, itemIndex = 40 };-- 资源争夺战   12级开启   不引导
game_button_ids["btn107"] = { name = "生存大考验", btnId = 107, resFramesName = "ccbResources/activity.plist",spriteName = "button_active_live",  goToCallFun = gtactivity , itemIndex = 80 };-- 生存大考验   20级开启   不引导
game_button_ids["btn108"] = { name = "每日挑战" , btnId = 108,  resFramesName = "ccbResources/activity.plist", spriteName = "mbutton_m_activity", goToCallFun = gtactivity, itemIndex = 50};-- 每日挑战   15级开启   不引导
game_button_ids["btn109"] = { name = "极限挑战" , btnId = 109,  resFramesName = "ccbResources/activity.plist", spriteName = "mbutton_m_activity" , goToCallFun = gtactivity, itemIndex = 20};-- 极限挑战 15级开启   不引导
game_button_ids["btn110"] = { name = "无主之地", resFramesName = "ccbResources/activity.plist", spriteName = "button_active_middle",  goToCallFun = gtactivity, itemIndex = 30  };-- 无主之地    10级开启   不引导
game_button_ids["btn115"] = { name = "献祭", btnId = 115,  resFramesName = "ccbResources/activity.plist",spriteName = "button_active_god.png", goToCallFun = gtactivity , itemIndex = 90};
game_button_ids["btn114"] = { name = "罗杰宝藏", btnId = 114,  resFramesName = "ccbResources/activity.plist",spriteName = "mbutton_m_activity.png", goToCallFun = gtactivity , itemIndex = 100};

game_button_ids["btn200"] = { name = "竞技场", btnId = 200, resFramesName = "ccbResources/ui_main_new_res.plist",  spriteName = "mbutton_m_fight" , goToCallFun = function ()
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index"); end };-- 竞技场 完成 1-4 花园城市 后开启 第四关强制
game_button_ids["btn307"] = { name = "超能商店", btnId = 307, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_5_3",  goToCallFun = function ( callBack )
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_function_pop"})
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")                 
    end};-- 超能商店    16级开启   说一句话
game_button_ids["btn501"] = { name = "伙伴训练", btnId = 501, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_2_1", goToCallFun = function ()
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_school_new",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
end };-- 伙伴训练    5级开启    说一句话    
game_button_ids["btn502"] = { name = "伙伴进阶", btnId =  502, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_2_3.png", goToCallFun = function ()  game_scene:enterGameUi("game_hero_advanced_sure",{gameData = nil}); end };-- 伙伴进阶    完成 1-4 花园城市 后开启 收复固定建筑（绿箭侠那个）
game_button_ids["btn503"] = { name = "技能升级", btnId =  503, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_2_2.png", goToCallFun = function ()  game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil}); end};-- 技能升级    完成 1-3 神秘名胜 后开启 完成第三关强制
game_button_ids["btn506"] = { name = "伙伴传承", btnId =  506, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_5_5.png", goToCallFun = function ()  game_scene:enterGameUi("game_hero_inherit"); end };-- 伙伴传承    12级开启   不引导
game_button_ids["btn507"] = { name = "伙伴分解", btnId =  507, resFramesName = "ccbResources/ui_main_new_res.plist",  spriteName = "mbutton_5_4.png", goToCallFun = function ()  game_scene:enterGameUi("game_card_split"); end};-- 伙伴分解    16级开启   说一句话
game_button_ids["btn509"] = { name = "属性改造", btnId =  509, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_2_4.png", goToCallFun = function ()  game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData}); end };-- 属性改造(连同战败)  13级开启   进入之后引导
game_button_ids["btn601"] = { name = "查看装备", btnId =  601, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_3_4.png", goToCallFun = function ()  game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_function_pop"}); end };-- 查看装备    完成 1-2 废区城市 后开启 不引导
game_button_ids["btn602"] = { name = "装备强化", btnId =  602, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_3_1.png", goToCallFun = function ()  game_scene:enterGameUi("equipment_strengthen",{gameData = nil}) end };-- 装备强化(连同战败)  完成 1-2 废区城市 后开启 完成第二关强制
game_button_ids["btn603"] = { name = "装备进阶", btnId =  603, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_3_2.png", goToCallFun = function ()  game_scene:enterGameUi("equip_evolution",{gameData = nil}); end };-- 装备进阶    14级开启   不引导
game_button_ids["btn116"] = { name = "分解中心", btnId =  116, resFramesName = "ccbResources/new_main_add_res.plist", spriteName = "mbutton_5_4.png", goToCallFun = function ()  game_scene:enterGameUi("game_card_split"); end};-- 伙伴分解    16级开启   说一句话
game_button_ids["btn605"] = { name = "英雄技能", btnId =  605, resFramesName = "ccbResources/ui_main_new_res.plist", spriteName = "mbutton_6_1.png", goToCallFun = function ()  
   local function responseMethod(tag,gameData)
        game_scene:enterGameUi("skills_practice_scene",{gameData = gameData});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_open"), http_request_method.GET, nil,"leader_skill_open")
 end  };-- 英雄技能    18级开启   说一句话

game_button_ids["btn700"] = { name = "联盟", btnId = 700, resFramesName = "ccbResources/ui_main_new_res.plist",   spriteName = "mbutton_4_2", goToCallFun = function ()
        game_scene:setVisibleBroadcastNode(false);
        local association_id = game_data:getUserStatusDataByKey("association_id");
        if association_id == 0 then
            require("like_oo.oo_controlBase"):openView("guild_join");
        else
            require("like_oo.oo_controlBase"):openView("guild");
        end
end};-- 公会  10级开启   不引导

game_button_ids["btn800"] = { name = "精英关卡" , btnId = 800, resFramesName = "ccbResources/ui_map_world_res.plist", spriteName = "sjdt_elite_levels_btn" , goToCallFun = function ()        
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("map_world_scene",{gameData = gameData, chapterSwitchTo = "hard", assign_chapter = 1});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
end};-- 精英关卡    完成 1-4 花园城市 后开启 不引导
game_button_ids["btn606"] = { name = "统帅能力", btnId = 606, resFramesName = "ccbResources/ui_main_new_res.plist",  spriteName = "mbutton_tsnl", goToCallFun = function ()  
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_ability_commander",{gameData = gameData});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index") 
end };-- 装备拆分 
game_button_ids["btn607"] = { name = "装备拆分", btnId = 607, resFramesName = "ccbResources/ui_main_new_res.plist",  spriteName = "mbutton_2_split", goToCallFun = function ()  game_scene:enterGameUi("ui_equip_split"); end };-- 装备拆分 
game_button_ids["btn608"] = { name = "装备精炼", btnId = 608, resFramesName = "ccbResources/ui_main_new_res.plist",  spriteName = "mbutton_2_st", goToCallFun = function ()  game_scene:enterGameUi("game_equip_refining"); end };-- 装备精炼
game_button_ids["btn117"] = { name = "伙伴重生", btnId = 117, resFramesName = "ccbResources/new_main_add_res.plist",   spriteName = "mbutton_c_chongsheng.png", goToCallFun = function ()
    game_scene:enterGameUi("ui_chongsheng_scene",{gameData = nil});
end};
game_button_ids["btn118"] = { name = "宝石合成", btnId = 118, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "mbutton_baoshihecheng.png", goToCallFun = function ()
    game_scene:enterGameUi("gem_system_synthesis",{})
end};
game_button_ids["btn119"] = { name = "宝石列表", btnId = 119, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "mbutton_chakanbaoshi.png", goToCallFun = function ()
    game_scene:enterGameUi("gem_system_list",{})
end};

game_button_ids["btn121"] = { name = "宝石分解", btnId =  121, resFramesName = "ccbResources/new_main_add_res.plist", spriteName = "mbutton_c_baoshifenjie.png", goToCallFun = function ()  game_scene:enterGameUi("game_card_split"); end};

game_button_ids["btn120"] = { name = "装备附魔", btnId = 120, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "mbutton_c_enchant.png", goToCallFun = function ()
    game_scene:enterGameUi("equip_enchanting",{gameData = nil})
end};

game_button_ids["btn122"] = { name = "伙伴融合", btnId = 1000001, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "m_button_melting.png", goToCallFun = function ()
        game_scene:enterGameUi("game_card_melting",{})
end};


game_button_ids["btn112"] = { name = "伙伴转生", btnId = 112, resFramesName = "ccbResources/new_main_add_res.plist",  spriteName = "mbutton_c_tubo.png", goToCallFun = function ()
    game_scene:enterGameUi("game_hero_breakthrough",{gameData = nil});
end};

game_button_ids["btn1000001"] = { name = "伙伴", btnId = 1000001,  spriteName = "mbutton_m_1.png", goToCallFun = function ()
    game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
end};

game_button_ids["btn1000002"] = { name = "伙伴招募", btnId = 1000002,  spriteName = "mbutton_5_1.png", goToCallFun = function ()
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
end};

function M.getQuickEntryFun( name, isNet, startFun, endFun )
    startFun = startFun or function ()    end
    endFun = endFun or function ()    end

end

function M.getQucikEnteryFunByBtnId( self, btnId )
    return game_button_ids["btn" .. tostring(btnId)]
end

function M.gtactivity( self, chapterID )
    -- body
end


function M.checkButtonOpenInfo( self, activityInfo )
    -- body
end

return M