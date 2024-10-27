--- 显示下奖励

local game_do_something_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,
    m_goods_sprite = nil,
    m_goods_info_label = nil,
    m_btn_use = nil,
    m_close_btn = nil,
    m_icon_node = nil,
    dosth_type = nil,

    m_tShowInfo = nil,

    m_active_data = nil,
};
--[[--
    销毁
]]
function game_do_something_pop.destroy(self)
    -- body
    cclog("-----------------game_do_something_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_root_layer = nil;
    self.m_goods_sprite = nil;
    self.m_goods_info_label = nil;
    self.m_btn_use = nil;
    self.m_close_btn = nil;
    self.m_icon_node = nil;
    self.dosth_type = nil;
    self.m_tShowInfo = nil;
    self.m_active_data = nil;
end
--[[--
    返回
]]
function game_do_something_pop.back(self,type)
    game_scene:removePopByName("game_do_something_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_do_something_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 100 then--关闭
            self:back();
        elseif btnTag == 105 then--  前往
            if self.m_tShowInfo.dosth_dobuttonClicked then
                self.m_tShowInfo.dosth_dobuttonClicked()
            end
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    self:createOneTip(ccbNode)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;
        elseif eventType == "ended" then
            self:back()
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[
    创建一个的
]]
function game_do_something_pop.createOneTip(self,ccbNode)
    ccbNode:openCCBFile("ccb/ui_reward_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");
    self.m_icon_node = ccbNode:nodeForName("icon_node");
    self.m_goods_sprite = ccbNode:spriteForName("goods_sprite");
    self.m_goods_info_label = ccbNode:labelTTFForName("goods_info_label");
    self.m_btn_use = ccbNode:controlButtonForName("btn_use");
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.title_label = ccbNode:labelTTFForName("title_label")
    self.title_label:setString(self.m_tShowInfo["dosth_title"])
    title = CCString:create(self.m_tShowInfo["dosth_btnTitle"]);
    self.m_btn_use:setTitleForState(title,CCControlStateNormal)
    self.m_btn_use:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    game_util:setCCControlButtonTitle(self.m_btn_use,string_helper.ccb.title92);
    game_util:setControlButtonTitleBMFont(self.m_btn_use);
    self:refreshUi()  -- 更新UI
end

--[[--
    刷新ui
]]
function game_do_something_pop.refreshUi(self)
	local sprite = nil;
	local info = ""
    local temp = ""
    if self.m_tShowInfo.iconAndInfo.exchangeID ~= nil then  -- exchange card 通过 item_cfg id 得到名字， icon  用于卡片，装备合成提示
        local item_cfg = getConfig(game_config_field.item);
        local item_item_cfg = item_cfg:getNodeWithKey(tostring(self.m_tShowInfo.iconAndInfo.exchangeID));
        if item_item_cfg then
            info = item_item_cfg:getNodeWithKey("name"):toStr()
            sprite = game_util:createItemIconByCfg(item_item_cfg)
        end
    elseif self.m_tShowInfo.iconAndInfo.iconName then   -- 通过脚本指定的名称获得 名字， icon  用于
        sprite = game_util:createIconByName(self.m_tShowInfo.iconAndInfo.iconName)
        info = self.m_tShowInfo.iconAndInfo.info or info
    elseif self.m_tShowInfo.iconAndInfo.cardID then   -- 通过卡片的id 得到名字 ， icon 用于伙伴训练完成提示
        local _,itemCfg = game_data:getCardDataById(self.m_tShowInfo.iconAndInfo.cardID)
        sprite = game_util:createCardIconByCfg(itemCfg)
        info = itemCfg:getNodeWithKey("name"):toStr() or info;
    elseif self.m_tShowInfo.iconAndInfo.spriteName then
        if self.m_tShowInfo.iconAndInfo.resFramesName then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(self.m_tShowInfo.iconAndInfo.resFramesName)
        end
        sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.m_tShowInfo.iconAndInfo.spriteName.. ".png"))
        if sprite and self.m_tShowInfo.iconAndInfo.iconAnimateTag then
            game_util:addTipsAnimByType(sprite, self.m_tShowInfo.iconAndInfo.iconAnimateTag)
        end
        info = self.m_tShowInfo.iconAndInfo.info or "";
    elseif self.m_tShowInfo.iconAndInfo.info then
        info = self.m_tShowInfo.iconAndInfo.info or "";
	end
	-- 更新显示信息
    if info ~= "" then temp = "：" end
	self.m_goods_info_label:setString(string.format("%s%s %s",self.m_tShowInfo["dosth_info"], temp, tostring(info)))
	-- 更新图标
	if sprite then
		self.m_icon_node:addChild(sprite)
    end
end
--[[--
    初始化
]]
function game_do_something_pop.init(self,t_params)
    self.activityData = t_params.activityData 
    self:initShowData( t_params.gameData )				-- 初始化显示信息
end
--[[--
    创建ui入口并初始化数据
]]
function game_do_something_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function game_do_something_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tShowInfo.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

--[[--
    分析并生成显示所需要的内容
]]
function game_do_something_pop.initShowData(self, params)
    -- print("---------- all alert data is -----------")
    -- print_lua_table(game_data:getAllAlertsData())
	local pfun = params.callFun or function ()	end;
    local t_params = {}                                     -- 提示消息内容 参数
    t_params.dosth_dobuttonClicked = function ()    end     -- 前往按钮按下事件
    t_params.dosth_btnTitle = string_helper.game_do_something_pop.go							-- 按钮显示文字

    if params.showType == "formation" then           -- 解锁新阵型
        t_params.dosth_type = 1;
        t_params.dosth_title = string_helper.game_do_something_pop.new_team
        t_params.dosth_info = string_helper.game_do_something_pop.lock_seat
        t_params.iconAndInfo = { info = params.data, iconName = "icon_tips_zhenxing"}
        t_params.dosth_dobuttonClicked = function () 
        	game_scene:enterGameUi("game_adjustment_formation",{gameData = nil,openType="game_main_scene"});
        	pfun();
	    end
    elseif params.showType == "exchange_card" then    -- 伙伴兑换
        t_params.dosth_type = 2;
        t_params.dosth_title = string_helper.game_do_something_pop.side_charge
        t_params.dosth_info = string_helper.game_do_something_pop.charge_hero
        t_params.iconAndInfo = { exchangeID = params.data }
        t_params.dosth_dobuttonClicked = function ()
	        local function responseMethod(tag,gameData)
	            game_scene:enterGameUi("game_exchange_scene",{gameData = gameData,openType = 1})
	        	pfun();
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_view"), http_request_method.GET, {},"item_view");
        end
    elseif params.showType == "exchange_equip" then    -- 装备兑换
		t_params.dosth_type = 2;
        t_params.dosth_title = string_helper.game_do_something_pop.side_charge
        t_params.dosth_info = string_helper.game_do_something_pop.charge_equip
        t_params.iconAndInfo = { exchangeID = params.data}
        t_params.dosth_dobuttonClicked = function ()
	        local function responseMethod(tag,gameData)
	            game_scene:enterGameUi("game_exchange_scene",{gameData = gameData,openType = 2})
	        	pfun();
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("item_view"), http_request_method.GET, {},"item_view");
        end
    elseif params.showType == "function" then            --  新功能解锁
        -- mark do 
        t_params.dosth_type = 3;
        t_params.dosth_title = string_helper.game_do_something_pop.new_function
        t_params.dosth_info = string_helper.game_do_something_pop.lock_function
        -- mark do
        local btnInfo = self:getGongNengInfo(tostring(params.data))
        t_params.iconAndInfo = { info = btnInfo.name }
        t_params.iconAndInfo.spriteName = btnInfo.spriteName
        t_params.iconAndInfo.resFramesName = btnInfo.resFramesName
        t_params.dosth_dobuttonClicked = function () 
            if btnInfo.goToCallFun then
                btnInfo.goToCallFun( btnInfo.itemIndex, btnInfo.chapterID)
            end
        	pfun();
	    end
        --还需新功能图标和name
    elseif params.showType == "task" then      --  悬赏任务完成
    	-- mark do
        t_params.dosth_type = 4;
        t_params.dosth_title = string_helper.game_do_something_pop.out
        t_params.dosth_info = string_helper.game_do_something_pop.out_customs
        -- mark do
        t_params.iconAndInfo = { info = params.showType.data, iconName = "icon_tips_xuanshang"  }
        t_params.dosth_dobuttonClicked = function () 
        	pfun();
	    end
        --需要悬赏任务id
    elseif params.showType == "train" then    ---   伙伴训练完成
        t_params.dosth_type = 6;
        t_params.dosth_title = string_helper.game_do_something_pop.hero_sch
        t_params.dosth_info = string_helper.game_do_something_pop.out_hero
        t_params.iconAndInfo = { cardID = params.data  }
        t_params.dosth_dobuttonClicked = function (  )
	        local function responseMethod(tag,gameData)
	        	game_scene:enterGameUi("game_school_new",{gameData = gameData});
	        	pfun();
	        end
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
        end
        --需要伙伴id和name
    elseif params.showType == "rank_down" then    ---   竞技场排名下降
        t_params.dosth_type = 7;
        t_params.dosth_title = string_helper.game_do_something_pop.challage
        t_params.dosth_info = string_helper.game_do_something_pop.rank_down
        t_params.iconAndInfo = { info = params.showType.data, spriteName = "mbutton_m_fight"  }
	    t_params.dosth_dobuttonClicked = function ()
		    if not game_button_open:checkButtonOpen(200) then
	            return;
	        end
	        local function responseMethod(tag,gameData)
	            game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
	        	pfun();
	        end
	        --  nil
	        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index");
        end
        --需要后台提供
    elseif params.showType == "guanqia" then    ---   新关卡解锁
        t_params.dosth_type = 8;
        t_params.dosth_title = string_helper.game_do_something_pop.customs_lock
        t_params.dosth_info = string_helper.game_do_something_pop.new_customs
        local cityid_cityorderid_cfg = getConfig(game_config_field.cityid_cityorderid);
	    local map_main_story = getConfig(game_config_field.map_main_story);
	    local cityOrderId = cityid_cityorderid_cfg:getNodeWithKey(tostring(params.data)):toStr();
	    local map_main_story_cfg_item = map_main_story:getNodeWithKey(cityOrderId);
	    local chapter = map_main_story_cfg_item:getNodeWithKey("stage_name"):toInt()
	    local name = map_main_story_cfg_item:getNodeWithKey("stage_name"):toStr()
   		t_params.iconAndInfo = { info = name, iconName = "icon_tips_zhangjie"  }
        t_params.dosth_dobuttonClicked = function () 
        	-- 前往地图所在章节
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData, assign_city = params.data, assign_normal_chapter = chapter});
                pfun();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
        end
    elseif params.showType == "live_test" then
        t_params.dosth_type = 9;
        t_params.dosth_title = string_helper.game_do_something_pop.live_challage
        t_params.dosth_info = string_helper.game_do_something_pop.live_challage

        local btnInfo = self:getGongNengInfo(tostring(107))
        t_params.iconAndInfo = { info = "" }
        t_params.iconAndInfo.spriteName = btnInfo.spriteName
        t_params.iconAndInfo.resFramesName = btnInfo.resFramesName
        t_params.dosth_dobuttonClicked = function () 
            if btnInfo.goToCallFun then
                btnInfo.goToCallFun( btnInfo.itemIndex, btnInfo.chapterID)
            end
            pfun();
        end
    elseif params.showType == "vip_gift" then    ---   伙伴训练完成
        t_params.dosth_type = 10;
        t_params.dosth_title = string_helper.game_do_something_pop.vip_package
        t_params.dosth_info = string_helper.game_do_something_pop.vip_get
        t_params.iconAndInfo = { info = "", spriteName = "mbutton_m_gift2" }
        t_params.dosth_dobuttonClicked = function () 
            --vip特权礼包
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                game_scene:addPop("ui_vip_show_gift_pop",{gameData = json.decode(data:getNodeWithKey("vip_bought"):getFormatBuffer()),openType = 2})
                pfun();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("shop_open"), http_request_method.GET, {},"shop_open")
        end
    elseif params.showType == "main_reward" then
        -- print("params.showType = main_reward")
        t_params.dosth_type = 11;
        t_params.dosth_title = params.showTitle
        t_params.dosth_info = params.showInfo
        t_params.iconAndInfo = { info = "", spriteName = params.iconData.spriteName, iconAnimateTag = params.iconData.iconAnimateTag }
        t_params.dosth_dobuttonClicked = function () 
            -- print("params.showType = ", params.endCallFun)
            -- game_scene:enterGameUi("game_main_scene",{gameData = nil}, {endCallFunc = params.endCallFun});
            game_scene:enterGameUi("game_main_scene",{gameData = nil});
        end
    elseif params.showType == "gold_gacha" then
        t_params.dosth_type = 12;
        t_params.dosth_title = string_helper.game_do_something_pop.hero_recruit
        t_params.dosth_info = string_helper.game_do_something_pop.coin_recruit
        t_params.iconAndInfo = { info = "", spriteName = "mbutton_5_1" }
        t_params.dosth_dobuttonClicked = function () 
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_gacha_scene",{gameData = gameData});
                self:destroy();
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("gacha_get_all_gacha"), http_request_method.GET, nil,"gacha_get_all_gacha")
            pfun();
        end
    end
    if t_params.dosth_type ~= nil then
        self.m_tShowInfo = t_params
    end
end

function game_do_something_pop.getGongNengInfo( self, bid )
    bid = tonumber(bid) or 1
    if bid == 108 or bid == 109 then
        local myChapterId = self:getActivityChapterID(bid - 103, self.activityData)
        local chapterCfg = getConfig(game_config_field.active_chapter)
        local itemCfg = chapterCfg:getNodeWithKey(tostring(myChapterId))
        active_btn = itemCfg:getNodeWithKey("button"):toStr()
        return self:getOpenButtonInfoByID(bid, active_btn, myChapterId)
    else
        return self:getOpenButtonInfoByID(bid)
    end
end


function game_do_something_pop.getOpenButtonInfoByID(self, bid , spriteName, chapterID)
    
    local gtactivity = function(itemIndex , chapterID)
        self:goToActivity(itemIndex, chapterID)
    end
    local game_button_ids = {}
    -- 卡牌分解
    -- 装备精炼
    -- 装备分解

    game_button_ids["105"] = { name = string_helper.game_do_something_pop.exping , resFramesName = "ccbResources/activity.plist", spriteName = "button_active_exp", goToCallFun = gtactivity, itemIndex = 70};    -- 马上有经验   17级开启   不引导
    game_button_ids["106"] = { name = string_helper.game_do_something_pop.zy_zt, resFramesName = "ccbResources/activity.plist",spriteName = "button_active_resource", goToCallFun = gtactivity, itemIndex = 40 };-- 资源争夺战   12级开启   不引导
    game_button_ids["107"] = { name = string_helper.game_do_something_pop.live_challage, resFramesName = "ccbResources/activity.plist",spriteName = "button_active_live",  goToCallFun = gtactivity , itemIndex = 80 };-- 生存大考验   20级开启   不引导
    game_button_ids["108"] = { name = string_helper.game_do_something_pop.day_challage ,  resFramesName = "ccbResources/activity.plist", spriteName = spriteName, goToCallFun = gtactivity, itemIndex = 50};-- 每日挑战   15级开启   不引导
    game_button_ids["109"] = { name = string_helper.game_do_something_pop.jx_chanllage ,  resFramesName = "ccbResources/activity.plist", spriteName = spriteName , goToCallFun = gtactivity, itemIndex = 60};-- 极限挑战 15级开启   不引导
    game_button_ids["113"] = { name = string_helper.game_do_something_pop.attack_jr, resFramesName = "ccbResources/activity.plist", spriteName = "button_active_boss", goToCallFun = gtactivity, itemIndex = 20 };-- 世界boss  18级开启
    game_button_ids["200"] = { name = string_helper.game_do_something_pop.jjc,  spriteName = "mbutton_m_fight" , goToCallFun = function ()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_arena",{pk_flag = "pk",gameData = json.decode(gameData:getNodeWithKey("data"):getFormatBuffer())});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("arena_index"), http_request_method.GET, {},"arena_index"); end };-- 竞技场 完成 1-4 花园城市 后开启 第四关强制
    game_button_ids["307"] = { name = string_helper.game_do_something_pop.live_shop, spriteName = "mbutton_5_3",  goToCallFun = function ()
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_card_split_shop",{gameData = gameData,openType = "game_function_pop"})
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("cards_open_dirt_shop"), http_request_method.GET, nil,"cards_open_dirt_shop")  
                           
        end};-- 超能商店    16级开启   说一句话
    game_button_ids["501"] = { name = string_helper.game_do_something_pop.hero_xl, spriteName = "mbutton_2_1", goToCallFun = function ()
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_school_new",{gameData = gameData});
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("school_open"), http_request_method.GET, nil,"school_open")
    end };-- 伙伴训练    5级开启    说一句话

    -- game_button_ids["801"] = { name = "自动战斗", spriteName = "sjdt_saodang",  resFramesName = "ccbResources/ui_map_world_res.plist", goToCallFun = function ()  
    --         local function responseMethod(tag,gameData)
    --             game_scene:enterGameUi("map_world_scene",{gameData = gameData});
    --         end
    --         network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    --      end };-- 自动战斗
    game_button_ids["112"] = { name = string_helper.game_do_something_pop.zs, spriteName = "mbutton_c_tubo", goToCallFun = function ()  game_scene:enterGameUi("game_hero_breakthrough",{gameData = nil});   end };-- 伙伴转生  30级开启
   
    game_button_ids["502"] = { name = string_helper.game_do_something_pop.jj, spriteName = "mbutton_2_3", goToCallFun = function ()  game_scene:enterGameUi("skills_inheritance_scene",{gameData = nil}); end };-- 伙伴进阶    完成 1-4 花园城市 后开启 收复固定建筑（绿箭侠那个）
    game_button_ids["503"] = { name = string_helper.game_do_something_pop.sj, spriteName = "mbutton_2_2", goToCallFun = function ()  game_scene:enterGameUi("skills_strengthen_scene",{gameData = nil}); end};-- 技能升级    完成 1-3 神秘名胜 后开启 完成第三关强制
    game_button_ids["506"] = { name = string_helper.game_do_something_pop.cc, spriteName = "mbutton_5_5", goToCallFun = function ()  game_scene:enterGameUi("game_hero_inherit"); end };-- 伙伴传承    12级开启   不引导
    game_button_ids["507"] = { name = string_helper.game_do_something_pop.split, spriteName = "mbutton_5_4", goToCallFun = function ()  game_scene:enterGameUi("game_card_split"); end};-- 伙伴分解    16级开启   说一句话
    game_button_ids["509"] = { name = string_helper.game_do_something_pop.sx_gz, spriteName = "mbutton_2_4", goToCallFun = function ()  game_scene:enterGameUi("game_hero_culture_scene",{gameData = gameData}); end };-- 属性改造(连同战败)  13级开启   进入之后引导
    game_button_ids["601"] = { name = string_helper.game_do_something_pop.look_equip, spriteName = "mbutton_3_4", goToCallFun = function ()  game_scene:enterGameUi("equipment_list",{gameData = nil,openType = "game_function_pop"}); end };-- 查看装备    完成 1-2 废区城市 后开启 不引导
    game_button_ids["602"] = { name = string_helper.game_do_something_pop.equip_add, spriteName = "mbutton_3_1", goToCallFun = function ()  game_scene:enterGameUi("equipment_strengthen",{gameData = nil}) end };-- 装备强化(连同战败)  完成 1-2 废区城市 后开启 完成第二关强制
    game_button_ids["603"] = { name = string_helper.game_do_something_pop.equip_jj, spriteName = "mbutton_3_2", goToCallFun = function ()  game_scene:enterGameUi("equip_evolution",{gameData = nil}); end };-- 装备进阶    14级开启   不引导
    game_button_ids["605"] = { name = string_helper.game_do_something_pop.hero_skill, spriteName = "mbutton_6_1", goToCallFun = function ()  
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("skills_practice_scene",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("leader_skill_open"), http_request_method.GET, nil,"leader_skill_open")
     end  };-- 英雄技能    18级开启   说一句话
    game_button_ids["700"] = { name = string_helper.game_do_something_pop.gvg, spriteName = "mbutton_4_2", goToCallFun = function ()
            game_scene:setVisibleBroadcastNode(false);
            local association_id = game_data:getUserStatusDataByKey("association_id");
            if association_id == 0 then
                require("like_oo.oo_controlBase"):openView("guild_join");
            else
                require("like_oo.oo_controlBase"):openView("guild");
            end
    end};-- 公会  10级开启   不引导
    game_button_ids["800"] = { name = string_helper.game_do_something_pop.hr_cstm , resFramesName = "ccbResources/ui_map_world_res.plist", spriteName = "sjdt_elite_levels_btn" , goToCallFun = function ()     
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("map_world_scene",{gameData = gameData, chapterSwitchTo = "hard", assign_chapter = 1});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("private_city_world_map"), http_request_method.GET, nil,"private_city_world_map")
    end};-- 精英关卡    完成 1-4 花园城市 后开启 不引导
    game_button_ids["110"] = { name = string_helper.game_do_something_pop.nobody, resFramesName = "ccbResources/activity.plist", spriteName = "button_active_middle",  goToCallFun = gtactivity, itemIndex = 30  };-- 无主之地    10级开启   不引导
        

    game_button_ids["606"] = { name = string_helper.game_do_something_pop.ts_nl, spriteName = "mbutton_tsnl", goToCallFun = function ()  
        local function responseMethod(tag,gameData)
            game_scene:enterGameUi("game_ability_commander",{gameData = gameData});
            self:destroy();
        end
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index") 
    end };-- 装备拆分 
    game_button_ids["607"] = { name = string_helper.game_do_something_pop.equip_cf, spriteName = "mbutton_2_split", goToCallFun = function ()  game_scene:enterGameUi("ui_equip_split"); end };-- 装备拆分 
    game_button_ids["608"] = { name = string_helper.game_do_something_pop.equip_jl, spriteName = "mbutton_2_st", goToCallFun = function ()  game_scene:enterGameUi("game_equip_refining"); end };-- 装备精炼





    return game_button_ids[tostring(bid)]
end

function game_do_something_pop.getActivityChapterID( self , index, chapterID_index )
    local m_active_cfg = {}
    local activeCfg = getConfig(game_config_field.active_cfg)
    for i=1,activeCfg:getNodeCount() do
        local itemCfg = activeCfg:getNodeWithKey(tostring(10*i))
        local is_see = itemCfg:getNodeWithKey("is_see"):toInt()
        if is_see == 1 then
            table.insert(m_active_cfg,json.decode(itemCfg:getFormatBuffer()))
        end
    end

    local active_cfg = m_active_cfg[index]

    local chapter_id = active_cfg.active_chapterID[1]
    local myChapterId = -1
    --比较服务器开启的活动ID 和 配置里对应位置的ID
    if tolua.type(chapter_id) == "table" then
        for i=1,#chapter_id do
            local cfgChapterId = chapter_id[i]
            for i=1,#chapterID_index do
                local serverChapterId = chapterID_index[i]
                if serverChapterId == cfgChapterId then
                    myChapterId = serverChapterId
                    break;
                end
            end
        end
    else
        myChapterId = chapter_id or -1
    end
    return myChapterId
end

function game_do_something_pop.goToActivity( self, itemIndex, chapterID )
    game_scene:enterGameUi("game_main_scene",{gameData = nil, openPop = "game_activity_new_pop"},{endCallFunc = function (  )
                game_data:setLeatestActivityIndex( tostring(itemIndex) )
                self:destroy();
            end});
    -- local function responseMethod(tag,gameData)
    -- self:back()
    --     game_scene:enterGameUi("game_activity",{gameData = gameData, chapterID = chapterID, itemIndex = itemIndex});
    -- end
    -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("active_index"), http_request_method.GET, nil,"active_index")
end

-- function game_do_something_pop.getEverydayActIcon( self )
--     local names = {"button_active_jianyu", "banner_active_rich", "button_active_beast", "button_active_beauty", "button_active_hell", "button_active_wu", "button_active_immune"}
--     local server_time = game_data:getUserStatusDataByKey("server_time")
--     local curdate = tonumber(os.date("%w", server_time))
--     return names[curdate] or "button_active_jianyu"
-- end


-- function game_do_something_pop.getEveryLimitActIcon( self )
--     local names = {"button_active_fuhuo", "banner_active_kongzhi", "button_active_qungong", "button_active_fuhuo", "banner_active_kongzhi", "button_active_qungong", "button_active_daluandou"}
--     local server_time = game_data:getUserStatusDataByKey("server_time")
--     local curdate = tonumber(os.date("%w", server_time))

--     print(" 极限挑战   name is", names[curdate])

--     return names[curdate] or "button_active_fuhuo"
-- end

function game_do_something_pop.dosth( info )
    -- body
end




return game_do_something_pop;
