---  新公会战结算
local game_gvg_result = {
    att_label = nil,
    def_label = nil,
    guild_att_name = nil,
    guild_def_name = nil,
    def_outcome = nil,
    att_outcome = nil,
    def_mvp_node = nil,
    att_mvp_node = nil,
    def_reward_node = nil,
    att_reward_node = nil,
};
--[[--
    销毁ui
]]
function game_gvg_result.destroy(self)
    cclog("----------------- game_gvg_result destroy-----------------"); 
    self.att_label = nil;
    self.def_label = nil;
    self.guild_att_name = nil;
    self.guild_def_name = nil;
    self.def_outcome = nil;
    self.att_outcome = nil;
    self.def_mvp_node = nil;
    self.att_mvp_node = nil;
    self.def_reward_node = nil;
    self.att_reward_node = nil;
end
--[[--
    返回
]]
function game_gvg_result.back(self)
    local association_id = game_data:getUserStatusDataByKey("association_id");
    if association_id == 0 then
        require("like_oo.oo_controlBase"):openView("guild_join");
    else
        require("like_oo.oo_controlBase"):openView("guild");
    end
end
--[[--
    读取ccbi创建ui
]]
function game_gvg_result.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        -- print("press button tag is ", btnTag)
        if btnTag == 1 then--返回
            self:back()
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_result.ccbi");

    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name")--攻城联盟
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")--守城联盟

    for i=1,8 do
        self.att_label[i] = ccbNode:labelTTFForName("att_label" .. i)
        self.def_label[i] = ccbNode:labelTTFForName("def_label" .. i)
    end 
    self.def_outcome = ccbNode:spriteForName("def_outcome")
    self.att_outcome = ccbNode:spriteForName("att_outcome")

    self.def_mvp_node = ccbNode:nodeForName("def_mvp_node")
    self.att_mvp_node = ccbNode:nodeForName("att_mvp_node")

    self.def_reward_node = ccbNode:nodeForName("def_reward_node")
    self.att_reward_node = ccbNode:nodeForName("att_reward_node")
    return ccbNode;
end

--[[--
    刷新ui
]]
function game_gvg_result.refreshUi(self)
    self.guild_att_name:setString("")
    self.guild_def_name:setString("")
    
    local att_result_table = {"","","","","",string_helper.game_gvg_result.mvp_reward,"",""}
    local def_result_table = {"","","","","",string_helper.game_gvg_result.team_reward,"",""}
    for i=1,8 do
        self.att_label[i]:setString(att_result_table[i])
        self.def_label[i]:setString(def_result_table[i])
    end

    self.def_mvp_node:removeAllChildrenWithCleanup(true)
    self.att_mvp_node:removeAllChildrenWithCleanup(true)
    self.def_reward_node:removeAllChildrenWithCleanup(true)
    self.att_reward_node:removeAllChildrenWithCleanup(true)

    self.def_outcome:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_lose.png"));
    self.att_outcome:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_lose.png"));
end
--[[--
    初始化
]]
function game_gvg_result.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.att_label = {}
    self.def_label = {}
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_result.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_gvg_result
