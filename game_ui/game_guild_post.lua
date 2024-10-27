---  成员信息 职位调整

local game_guild_post = {
    m_tGameData = nil,
    m_anim_node = nil,
    m_player_name_label = nil,
    m_player_lv_label = nil,
    m_guild_name_label = nil,
    m_rank_label = nil,
    m_formation_layer = nil,
    m_menu_node = nil,
    m_selGuildId = nil,
    m_changeFlag = nil,
    m_jobType = nil,
    m_post_btn = nil,
    m_selPlayerJobType = nil,
};
--[[--
    销毁ui
]]
function game_guild_post.destroy(self)
    -- body
    cclog("-----------------game_guild_post destroy-----------------");
    self.m_tGameData = nil;
    self.m_anim_node = nil;
    self.m_player_name_label = nil;
    self.m_player_lv_label = nil;
    self.m_guild_name_label = nil;
    self.m_rank_label = nil;
    self.m_formation_layer = nil;
    self.m_menu_node = nil;
    self.m_selGuildId = nil;
    self.m_changeFlag = nil;
    self.m_jobType = nil;
    self.m_post_btn = nil;
    self.m_selPlayerJobType = nil;
end
--[[--
    返回
]]
function game_guild_post.back(self,backType)
    game_scene:enterGameUi("game_guild_main",{gameData = nil});
	self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_guild_post.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then
            self.m_menu_node:setVisible(not self.m_menu_node:isVisible());
        elseif btnTag == 11 then--会长
            if self.m_selPlayerJobType == 1 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_post.msg); return end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_guild_main",{gameData = gameData,guildId=self.m_selGuildId});
                self:destroy();
            end
            -- 任命职务   position ＝ 0,1,2（0,解除职务会长不能解除自己，1,任命为会长，2,任命为副会长最多两个）  user_id ＝ 玩家id
            local params = {};
            params.user_id=self.m_tGameData.player_uid;
            params.position=1
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_appoint_player"), http_request_method.GET, params,"association_appoint_player")
        elseif btnTag == 12 then--副会长
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_guild_main",{gameData = gameData,guildId=self.m_selGuildId});
                self:destroy();
            end
            -- 任命职务   position ＝ 0,1,2（0,解除职务会长不能解除自己，1,任命为会长，2,任命为副会长最多两个）  user_id ＝ 玩家id
            local params = {};
            params.user_id=self.m_tGameData.player_uid;
            params.position=2
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_appoint_player"), http_request_method.GET, params,"association_appoint_player")
        elseif btnTag == 13 then--会员
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_guild_main",{gameData = gameData,guildId=self.m_selGuildId});
                self:destroy();
            end
            -- 任命职务   position ＝ 0,1,2（0,解除职务会长不能解除自己，1,任命为会长，2,任命为副会长最多两个）  user_id ＝ 玩家id
            local params = {};
            params.user_id=self.m_tGameData.player_uid;
            params.position=0
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_appoint_player"), http_request_method.GET, params,"association_appoint_player")
        elseif btnTag == 14 then--移出公会
            if self.m_selPlayerJobType == 1 then require("game_ui.game_pop_up_box").showAlertView(string_helper.game_guild_post.msg2); return end
            local function responseMethod(tag,gameData)
                game_scene:enterGameUi("game_guild_main",{gameData = gameData,guildId=self.m_selGuildId});
                self:destroy();
            end
            -- 移除玩家    user_id ＝ 玩家id
            local params = {};
            params.user_id=self.m_tGameData.player_uid;
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_remove_player"), http_request_method.GET, params,"association_remove_player")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_post.ccbi");
    self.m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"), "CCNode");
    self.m_player_name_label = tolua.cast(ccbNode:objectForName("m_player_name_label"), "CCLabelTTF");
    self.m_player_lv_label = tolua.cast(ccbNode:objectForName("m_player_lv_label"), "CCLabelTTF");
    self.m_guild_name_label = tolua.cast(ccbNode:objectForName("m_guild_name_label"), "CCLabelTTF");
    self.m_rank_label = tolua.cast(ccbNode:objectForName("m_rank_label"), "CCLabelTTF");
    self.m_formation_layer = tolua.cast(ccbNode:objectForName("m_formation_layer"), "CCLayer");
    self.m_menu_node = tolua.cast(ccbNode:objectForName("m_menu_node"), "CCNode");
    self.m_post_btn = tolua.cast(ccbNode:objectForName("m_post_btn"), "CCControlButton");
    self.m_menu_node:setVisible(false);
    self.m_post_btn:setVisible(false);
    return ccbNode;
end


--[[--
    初始化队伍信息
]]
function game_guild_post.initTeamFormation(self,formation_layer)
    local data = self.m_tGameData;
    local cardsData = data.cards
    local alignment = data.alignment

    local itemId = nil;
    local itemData = nil;
    local itemIcon = nil;
    local headIconSpr = nil;
    local headIconBgSize = formation_layer:getChildByTag(1):getContentSize();
    local mPos = ccp(headIconBgSize.width*0.5,headIconBgSize.height*0.5);
    local character_detail_cfg = getConfig("character_detail");
    local heroId = nil;
    for i=1,10 do
        itemData,heroCfg = game_data:getTeamCardDataByPos(i);
        if i < 6 then
            heroId = tostring(alignment[1][i])
        else
            heroId = tostring(alignment[2][i-5])
        end
        itemData = cardsData[heroId];
        if heroId ~= "-1" and itemData then
            heroCfg = character_detail_cfg:getNodeWithKey(itemData.c_id);
            if itemData and heroCfg then
                local cardImage = heroCfg:getNodeWithKey("img"):toStr();
                itemIcon = tolua.cast(formation_layer:getChildByTag(i),"CCSprite");
                headIconSpr = game_util:createIconByName(cardImage);
                headIconSpr:setScale(0.85);
                headIconSpr:setPosition(mPos);
                itemIcon:addChild(headIconSpr,1,1);
            end
        end
    end
end

--[[--
    刷新ui
]]
function game_guild_post.refreshUi(self)
    if self.m_tGameData then
        local data = self.m_tGameData;
        self.m_player_name_label:setString(data.player_name);
        self.m_player_lv_label:setString(data.level);
        self.m_guild_name_label:setString(data.guild_name);
        self.m_rank_label:setString(data.sort);
        self:initTeamFormation(self.m_formation_layer);
        if self.m_jobType ~= 3 then
            self.m_post_btn:setVisible(true);
        end
    end
end
--[[--
    初始化
]]
function game_guild_post.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    self.m_selGuildId = t_params.guildId;
    self.m_jobType = t_params.jobType;
    self.m_selPlayerJobType = selPlayerJobType;
    self.m_changeFlag = false;
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_post.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_guild_post;