---  新公会战
local game_gvg_new_main = {
    guild_att_name = nil,
    guild_def_name = nil,
    war_flag_count = nil,
    war_flag_rank = nil,
    m_editBox1 = nil,
    left_time_node = nil,
    rank_node = nil,
    donate_flag = nil,
    sprite_title = nil,
    sprite_end = nil,
};
--[[--
    销毁ui
]]
function game_gvg_new_main.destroy(self)
    cclog("----------------- game_gvg_new_main destroy-----------------"); 
    self.guild_att_name = nil;
    self.guild_def_name = nil;
    self.war_flag_count = nil;
    self.war_flag_rank = nil;
    self.m_editBox1 = nil;
    self.left_time_node = nil;
    self.rank_node = nil;
    self.donate_flag = nil;
    self.m_editBox1Node = nil;
    self.sprite_title = nil;
    self.sprite_end = nil;
end
--[[--
    返回
]]
function game_gvg_new_main.back(self)
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
function game_gvg_new_main.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog(btnTag)
        if btnTag == 1 then--返回
            self:back()
        elseif btnTag == 4 then--最大捐献
            if self.m_tGameData.max_flag > 0 then
                self.m_editBox1:setText(self.m_tGameData.max_flag);
            end
        elseif btnTag == 5 then--确定捐献
            if self.sort == 1 then
                local count = tonumber(self.m_editBox1:getText())
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data");
                    local start_before = data:getNodeWithKey("start_before")
                    self.m_tGameData = json.decode(start_before:getFormatBuffer()) or {};
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("guild_gvg_donate_flag"), http_request_method.GET, {count = count},"guild_gvg_donate_flag")
            else
                game_util:addMoveTips({text = string_helper.game_gvg_new_main.text})
            end
        elseif btnTag == 11 then--成员列表

        elseif btnTag == 12 then--活动详情
            game_scene:addPop("game_active_limit_detail_pop",{})
        end
    end

    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/ui_gvg_new_main.ccbi");

    self.guild_att_name = ccbNode:labelTTFForName("guild_att_name")--攻城联盟
    self.guild_def_name = ccbNode:labelTTFForName("guild_def_name")--守城联盟

    self.war_flag_count = ccbNode:labelTTFForName("war_flag_count")
    self.war_flag_rank = ccbNode:labelTTFForName("war_flag_rank")

    self.m_editBox1Node = ccbNode:nodeForName("m_editBox1")--战旗捐献输入框

    self.left_time_node = ccbNode:nodeForName("left_time_node")--倒计时
    self.rank_node = ccbNode:nodeForName("rank_node")

    self.sprite_title = ccbNode:spriteForName("sprite_title")
    self.sprite_end = ccbNode:spriteForName("sprite_end")
    return ccbNode;
end

--[[
    排行榜
]]
function game_gvg_new_main.createRankTable(self,viewSize)
    local rankTable = self.m_tGameData.ranks
    local tabCount = game_util:getTableLen(rankTable)
    local params = {};
    params.viewSize = viewSize;
    params.row = 8;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = tabCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_active_limit_rank_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local detail_label = ccbNode:labelTTFForName("detail_label");
            local detail_label_score = ccbNode:labelTTFForName("detail_label_score");

            local rankData = rankTable[index+1] or {}
            local name = rankData.name or ""
            local score = rankData.score or ""
            local rank = rankData.rank or ""

            detail_label:setString(tostring(rank) .. "." .. name )
            detail_label_score:setString(tostring(score))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            
        end
    end
    return TableViewHelper:create(params);
end
--[[
    label
]]

--[[--
    刷新ui
]]
function game_gvg_new_main.refreshUi(self)
    local attacker = self.m_tGameData.attacker
    if self.m_tGameData.attacker == "" then
        attacker = string_helper.game_gvg_new_main.attacker
    end
    local defender = self.m_tGameData.defender
    if self.m_tGameData.defender == "" then
        defender = string_helper.game_gvg_new_main.defender
    end
    self.guild_att_name:setString(attacker)
    self.guild_def_name:setString(defender)
    self.war_flag_count:setString(self.m_tGameData.score)
    if self.m_tGameData.rank == -1 then--为捐献
        self.war_flag_rank:setString(string_helper.game_gvg_new_main.mo_donate)
    else
        self.war_flag_rank:setString(self.m_tGameData.rank)
    end
    --输入框
    self.m_editBox1Node:removeAllChildrenWithCleanup(true)
    local function editBoxTextEventHandle1(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.donate_flag = edit:getText();
        end
    end
    self.m_editBox1 = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle1,size = self.m_editBox1Node:getContentSize(),placeHolder=""});
    self.m_editBox1Node:addChild(self.m_editBox1);
    --倒计时
    self.left_time_node:removeAllChildrenWithCleanup(true)
    local function timeEndFunc()

    end
    local left_time = self.m_tGameData.remaining_time
    local countdownLabel = game_util:createCountdownLabel(left_time,timeEndFunc,8,1);
    countdownLabel:setAnchorPoint(ccp(0.5,0.5))
    countdownLabel:setColor(ccc3(255,94,9))
    self.left_time_node:addChild(countdownLabel,10,10)
    --排行榜
    self.rank_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createRankTable(self.rank_node:getContentSize());
    self.rank_node:addChild(tableView,10,10);
    --改title
    if self.sort == 2 then
        self.sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_prepare.png"));
        self.sprite_end:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_beforewar.png"));
    else
        self.sprite_title:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_ing.png"));
        self.sprite_end:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("gvg_label_end.png"));
    end
end
--[[--
    初始化
]]
function game_gvg_new_main.init(self,t_params)
    t_params = t_params or {}
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data");
        local start_before = data:getNodeWithKey("start_before")
        self.m_tGameData = json.decode(start_before:getFormatBuffer()) or {};
    else
        self.m_tGameData = {};
    end
    self.sort = t_params.sort
end
--[[--
    创建ui入口并初始化数据
]]
function game_gvg_new_main.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_gvg_new_main