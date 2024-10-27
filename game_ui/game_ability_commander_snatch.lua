---  ui
local game_ability_commander_snatch = {
    m_list_view_bg = nil,
    m_tGameData = nil,
    m_recipeId = nil,
    m_itemId = nil,
    m_vigor_total_label = nil,
    m_guildNode = nil,
    m_guideFlag = nil,
    m_clickActionNode = nil,
    m_clickFlag = nil,
};
--[[--
    销毁ui
]]
function game_ability_commander_snatch.destroy(self)
    -- body
    cclog("-----------------game_ability_commander_snatch destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_tGameData = nil;
    self.m_recipeId = nil;
    self.m_itemId = nil;
    self.m_vigor_total_label = nil;
    self.m_guildNode = nil;
    self.m_guideFlag = nil;
    self.m_clickActionNode = nil;
    self.m_clickFlag = nil;
end
--[[--
    返回
]]
function game_ability_commander_snatch.back(self,backType)
    if not game_button_open:checkButtonOpen(606) then
        return
    end
    local function responseMethod(tag,gameData)
        game_scene:enterGameUi("game_ability_commander",{gameData = gameData,recipeId = self.m_recipeId});
        self:destroy();
    end
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_index"), http_request_method.GET, nil,"commander_index")
end
--[[--
    读取ccbi创建ui
]]
function game_ability_commander_snatch.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 200 then--刷新
            local function responseMethod(tag,gameData)
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer())
                self:refreshTableView();
                game_util:addMoveTips({text = string_helper.game_ability_commander_snatch.text});
            end
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_search"), http_request_method.GET, {item_id=self.m_itemId},"commander_search")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_ability_commander_snatch.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_vigor_total_label = ccbNode:labelBMFontForName("m_vigor_total_label")
    self.m_clickActionNode = CCNode:create()
    ccbNode:addChild(self.m_clickActionNode)

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text30)

    local m_btn_refresh = ccbNode:controlButtonForName("m_btn_refresh")
    game_util:setCCControlButtonTitle(m_btn_refresh,string_helper.ccb.text31)

    return ccbNode;
end

--[[--
    创建列表
]]
function game_ability_commander_snatch.createTableView(self,viewSize)
    local commander_recipe_cfg = getConfig(game_config_field.commander_recipe);
    local users = self.m_tGameData.users or {}
    local showCount = #users
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag == " .. btnTag)
        local itemData = users[btnTag + 1]
        local function responseMethod(tag,gameData)
            game_guide_controller:gameGuide("send","18",1803);
            game_data:setBattleType("game_ability_commander_snatch");
            local stageTableData = {name = string_helper.game_ability_commander_snatch.name,step = 1,totalStep = 1}
            game_scene:enterGameUi("game_battle_scene",{gameData = gameData,stageTableData=stageTableData,backGroundName="back_landscapeart"});
            self:destroy();
        end
        if self.m_guideFlag == true then
            local params = {};
            params.test_robot = "robot_1000"
            params.item_id = self.m_itemId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_rob"), http_request_method.GET, params,"commander_rob")
            return;
        end
        local cmdr_energy = game_data:getUserStatusDataByKey("cmdr_energy") or 0
        if cmdr_energy < 2 then
            --统一提示
            local t_params = 
            {
                m_openType = 17,
                m_ok_func = function()
                    self:refreshUi()
                end,
                time = self.m_tGameData.buy_cmdr_times
            }
            game_scene:addPop("game_normal_tips_pop",t_params)
        else
            --抢夺 target_uid=robot_100&item_id=6101
            if self.m_clickFlag == true then return end
            self.m_clickActionNode:stopAllActions()
            schedule(self.m_clickActionNode, function ()
                self.m_clickFlag = false
            end, 0.8)
            self.m_clickFlag = true
            local params = {};
            params.target_uid = itemData.uid;
            params.item_id = self.m_itemId;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("commander_rob"), http_request_method.GET, params,"commander_rob")
        end
    end
    self.m_selListItem = nil;
    local params = {};
    params.viewSize = viewSize;
    params.row = 1;--行
    params.column = 4; --列
    params.totalItem = 4
    params.showPageIndex = self.m_curPage;
    params.showPoint = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    self.m_guildNode = nil;
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_ability_commander_snatch_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local m_spr_bg_up = ccbNode:nodeForName("m_spr_bg_up")
            local m_snatch_btn = ccbNode:controlButtonForName("m_snatch_btn")
            game_util:setCCControlButtonTitle(m_snatch_btn,string_helper.ccb.text34)
            m_snatch_btn:setTag(index);
            if index < showCount then
                if self.m_guildNode == nil then
                    self.m_guildNode = m_snatch_btn;
                end
                m_spr_bg_up:setVisible(false)
                m_snatch_btn:setVisible(true)
                local m_node = ccbNode:scrollViewForName("m_node")
                m_node:getContainer():removeAllChildrenWithCleanup(true);
                local m_type_icon = ccbNode:spriteForName("m_type_icon")
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_guild_label = ccbNode:labelTTFForName("m_guild_label")
                m_guild_label:setString(string_helper.ccb.file72)
                local m_probability_label = ccbNode:labelBMFontForName("m_probability_label")
                local m_lv_label = ccbNode:labelBMFontForName("m_lv_label")

                local text1 = ccbNode:labelTTFForName("text1")
                local text2 = ccbNode:labelTTFForName("text2")
                text1:setString(string_helper.ccb.text32)
                text2:setString(string_helper.ccb.text33)
                local itemData = users[index + 1]
                local tempImg = game_util:createPlayerBigImgByRoleId(itemData.role)
                if tempImg then
                    m_node:setTouchEnabled(false);
                    tempImg:setScale(0.5);
                    local tempSize = tempImg:getContentSize()
                    tempImg:setPosition(ccp(- tempSize.width*0.25 + itemSize.width*0.5, -10))
                    -- tempImg:setAnchorPoint(ccp(0.5, 0.2))
                    m_node:addChild(tempImg)
                end
                m_name_label:setString(tostring(itemData.name))
                -- m_name_label:setVisible(false);
                local firstValue,_ = string.find(tostring(itemData.uid),"robot_");
                if firstValue then
                    m_type_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tsnl_NPC.png"))
                else
                    m_type_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("tsnl_ren.png"))
                end
                m_lv_label:setString("Lv." .. itemData.level)
                -- m_lv_label:setVisible(false);
                local itemCfg = commander_recipe_cfg:getNodeWithKey(tostring(self.m_recipeId))
                if itemCfg then
                    local rate = 0;
                    if firstValue then
                        rate = itemCfg:getNodeWithKey("pve_rate"):toFloat();
                    else
                        rate = itemCfg:getNodeWithKey("pvp_rate"):toFloat();
                    end
                    if rate <= 0.4 then
                        m_probability_label:setString(string_helper.game_ability_commander_snatch.string1)
                        m_probability_label:setColor(ccc3(0,255,0))
                    elseif rate >= 0.8 then
                        m_probability_label:setString(string_helper.game_ability_commander_snatch.string3)
                        m_probability_label:setColor(ccc3(160,32,240))
                    else
                        m_probability_label:setString(string_helper.game_ability_commander_snatch.string2)
                        m_probability_label:setColor(ccc3(0,0,255))
                    end
                else
                    m_probability_label:setString(string_helper.game_ability_commander_snatch.string1)
                    m_probability_label:setColor(ccc3(0,255,0))
                end
            else
                m_spr_bg_up:setVisible(true)
                m_snatch_btn:setVisible(false)
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  cell = " .. tolua.type(cell));
        if eventType == "ended" and cell then

        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        -- self.m_selListItem = nil;
        self.m_curPage = curPage;
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    刷新
]]
function game_ability_commander_snatch.refreshTableView(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_tableView:setTouchEnabled(false);
    self.m_list_view_bg:addChild(self.m_tableView);
end


--[[--
    刷新ui
]]
function game_ability_commander_snatch.refreshUi(self)
    self:refreshTableView();
    local cmdr_energy = game_data:getUserStatusDataByKey("cmdr_energy") or 0
    local value,unit = game_util:formatValueToString(cmdr_energy);
    self.m_vigor_total_label:setString(value .. unit .. "/30");
end
--[[--
    初始化
]]
function game_ability_commander_snatch.init(self,t_params)
    t_params = t_params or {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    end
    self.m_recipeId = t_params.recipeId
    self.m_itemId = t_params.itemId
    game_data:setCommanderRecipeData("recipeId",self.m_recipeId);
    game_data:setCommanderRecipeData("itemId",self.m_itemId);
    self.m_guideFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_ability_commander_snatch.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    local id = game_guide_controller:getIdByTeam("18");
    if self.m_guildNode and id == 1802 then
        self.m_guideFlag = true;
        game_guide_controller:gameGuide("show","18",1803,{tempNode = self.m_guildNode})
    end
    return scene;
end

return game_ability_commander_snatch;