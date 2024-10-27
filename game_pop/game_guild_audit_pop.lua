---  公会申请审核

local game_guild_audit_pop = {
    m_tGameData = nil,
    m_anim_node = nil,
    m_player_name_label = nil,
    m_player_lv_label = nil,
    m_guild_name_label = nil,
    m_rank_label = nil,
    m_formation_layer = nil,
    m_selGuildId = nil,
    m_popUi = nil,
};
--[[--
    销毁ui
]]
function game_guild_audit_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_audit_pop destroy-----------------");
    self.m_tGameData = nil;
    self.m_anim_node = nil;
    self.m_player_name_label = nil;
    self.m_player_lv_label = nil;
    self.m_guild_name_label = nil;
    self.m_rank_label = nil;
    self.m_formation_layer = nil;
    self.m_selGuildId = nil;
    self.m_popUi = nil;
end
--[[--
    返回
]]
function game_guild_audit_pop.back(self,backType)
    -- if self.m_popUi then
    --     self.m_popUi:removeFromParentAndCleanup(true);
    --     self.m_popUi = nil;
    -- end
    -- self:destroy();
    game_scene:removePopByName("game_guild_audit_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_guild_audit_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then
            self:back();
        elseif btnTag == 2 then--同意
            if self.m_tGameData == nil then return end
            local function responseMethod(tag,gameData)
                local function responseMethod(tag,gameData)
                    game_data:setSelGuildDataByJsonData(gameData:getNodeWithKey("data"));
                    game_scene:refreshCurrentUi();
                    self:back();
                end
                --工会详情  guild_id = 工会id
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_detail"), http_request_method.GET, {guild_id=self.m_selGuildId},"association_guild_detail")
            end
            -- 同意申请    user_id ＝ 玩家id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_agree"), http_request_method.GET, {user_id=self.m_tGameData.player_uid},"association_guild_agree")
        elseif btnTag == 3 then--拒绝
            if self.m_tGameData == nil then return end
            local function responseMethod(tag,gameData)
                self:back();
            end
            -- 拒绝申请    user_id ＝ 玩家id
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_guild_not_agree"), http_request_method.GET, {user_id=self.m_tGameData.player_uid},"association_guild_not_agree")
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_guild_audit.ccbi");
    self.m_anim_node = tolua.cast(ccbNode:objectForName("m_anim_node"), "CCNode");
    self.m_player_name_label = tolua.cast(ccbNode:objectForName("m_player_name_label"), "CCLabelTTF");
    self.m_player_lv_label = tolua.cast(ccbNode:objectForName("m_player_lv_label"), "CCLabelTTF");
    self.m_guild_name_label = tolua.cast(ccbNode:objectForName("m_guild_name_label"), "CCLabelTTF");
    self.m_rank_label = tolua.cast(ccbNode:objectForName("m_rank_label"), "CCLabelTTF");
    self.m_formation_layer = tolua.cast(ccbNode:objectForName("m_formation_layer"), "CCLayer");
    return ccbNode;
end

--[[--
    初始化队伍信息
]]
function game_guild_audit_pop.initTeamFormation(self,formation_layer)
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
                headIconSpr = game_util:createIconByName(cardImage)
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
function game_guild_audit_pop.refreshUi(self)
    if self.m_tGameData then
        local data = self.m_tGameData;
        self.m_player_name_label:setString(data.player_name);
        self.m_player_lv_label:setString(data.level);
        self.m_guild_name_label:setString(data.guild_name);
        self.m_rank_label:setString(data.sort);
        self:initTeamFormation(self.m_formation_layer);
    end
end
--[[--
    初始化
]]
function game_guild_audit_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer());
    end
    self.m_selGuildId = t_params.guildId;
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_audit_pop.create(self,t_params)
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_guild_audit_pop;