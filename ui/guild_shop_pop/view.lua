require "shared.extern"

local guild_shop_pop_view = class("guildShopPopView",require("like_oo.oo_popBase"));

guild_shop_pop_view.m_ccb = nil;
guild_shop_pop_view.m_score = nil;
guild_shop_pop_view.m_listNode = nil;
guild_shop_pop_view.m_table = nil;

function guild_shop_pop_view:onCreate(  )
	local function onButtonClick( target,event )
		-- 筛选
		self:updataMsg(3);		-- 筛选消息
	end
	local function onBack( target,event )
		self:updataMsg(2);		-- 关闭消息
	end

	cclog("------------ guild_join_pop_view:create");
	self.m_ccb = luaCCBNode:create();

	self.m_ccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_ccb:registerFunctionWithFuncName( "onBack",onBack );
	self.m_ccb:openCCBFile("ccb/pop_guild_shop.ccbi");

	self.m_score = tolua.cast(self.m_ccb:objectForName("m_score"),"CCLabelTTF");
	self.m_listNode = tolua.cast(self.m_ccb:objectForName("m_listNode"),"CCNode");

    self.m_score:setString(tostring(self.m_control.m_data:getScore()));

	local tempTable = self:createTableView(self.m_listNode:getContentSize());
	self.m_listNode:addChild(tempTable);
    self.m_table = tempTable;

	self.m_rootView:addChild(self.m_ccb);
end

function guild_shop_pop_view:setScore( score )
    self.m_score:setString(tostring(score));
end

function guild_shop_pop_view:updataItem(  )
    self.m_listNode:removeAllChildrenWithCleanup(true);
    local tempTable = self:createTableView(self.m_listNode:getContentSize());
    self.m_listNode:addChild(tempTable);
    self.m_table = tempTable;
end

function guild_shop_pop_view:onLookFunc(index)
    local itemData = self.m_control.m_data:getItem(index)
    if itemData == nil then
        game_util:addMoveTips({text = string_helper.guild_shop_pop.dataError});
        return;
    end
    -- local shop_reward = itemData.shop_reward[1]
    -- local change_sort = shop_reward[1];
    -- local cId = shop_reward[2];
    -- if change_sort == 5 then
    --     game_scene:addPop("game_hero_info_pop",{cId = cId,openType = 4})
    -- elseif change_sort == 6 then
    --     if cId >= 1000 and cId < 3000 then--碎片
    --         local itemCfg = getConfig(game_config_field.item)
    --         local exchageCfg = getConfig(game_config_field.exchange)
    --         local itemId = cId
    --         local sortId = itemCfg:getNodeWithKey(itemId):getNodeWithKey("sort"):toStr()
    --         local changeId = exchageCfg:getNodeWithKey(sortId):getNodeWithKey("change_id"):getNodeAt(0):getNodeAt(1):toStr()
    --         game_scene:addPop("game_hero_info_pop",{cId = tostring(changeId),openType = 4})
    --     else--道具
    --         local tempIcon,tempName,tempCount = self.m_control.m_data:getItemIcon(index);
    --         if tempName == nil then
    --             tempName = ""
    --         end
    --         game_util:addMoveTips({text = tempName .. "×" .. tempCount})
    --     end
    -- elseif change_sort == 7 then--装备
    --     local equipData = {lv = 1,c_id = cId,id = -1,pos = -1}
    --     game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
    -- else
    --     local tempIcon,tempName,tempCount = self.m_control.m_data:getItemIcon(index);
    --     if tempName == nil then
    --         tempName = ""
    --     end
    --     game_util:addMoveTips({text = tempName .. "×" .. tempCount})
    -- end
    local shop_reward = itemData.shop_reward[1]
    game_util:lookItemDetal(shop_reward)
end

function guild_shop_pop_view:createTableView( viewSize )
    local shopLevel = self.m_control.m_data:getShopLevel()
    cclog("shopLevel == " .. shopLevel)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/public_res.plist");
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/other_public_res.plist");

    -- local daily_award_cfg = getConfig(game_config_field.daily_award)
    -- local tGameData = game_data:getDailyAwardData();
    -- local score = tGameData.score;
    -- local reward = tGameData.reward;
    local params = {};
    params.viewSize = viewSize;
    params.row = 2; -- 行
    params.column = 4; -- 列
    -- params.totalItem = self.m_control.m_data:getGuildCount();
    params.totalItem = self.m_control.m_data:getItemCount();
    -- params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.touchPriority = 1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local tempItem = luaCCBNode:create();
            local function onButtonClick( target,event )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                self:updataMsg(4,btnTag);       -- 指定对象购买
            end
            local function onItemClick( target,event )
                local tagNode = tolua.cast(target, "CCNode");
                local btnTag = tagNode:getTag();
                self:updataMsg(5,btnTag);       -- 制定对象的详情
            end
            tempItem:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
            tempItem:registerFunctionWithFuncName( "onItemClick",onItemClick );
            tempItem:openCCBFile("ccb/pop_guild_shop_item.ccbi");
            cell:addChild(tempItem,10,10);
        end
        
        if cell then
            local tempItem = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local tempData = self.m_control.m_data:getItem(index+1);
            -- cclog("tempData == " .. json.encode(tempData))
            cclog("------------------shop item-------------------1");
            -- 兑换需要的贡献度
            local m_needScare = tolua.cast(tempItem:objectForName("m_needScare"),"CCLabelTTF");
            m_needScare:setString(tostring(tempData.need_gongxian));
            cclog("------------------shop item -------------------2");
            -- 图标代替节点
            local m_iconNode = tolua.cast(tempItem:objectForName("m_iconNode"),"CCNode");
            local tempIcon,tempName,tempCount = self.m_control.m_data:getItemIcon(index+1);
            if tempName == nil then
                tempName = ""
            end
            if tempIcon then
                m_iconNode:removeAllChildrenWithCleanup(true)
                m_iconNode:addChild(tempIcon);
            end
            cclog("-------------------shop item------------------3");
            -- 剩余物品数量
            local m_itemCount_label = tolua.cast(tempItem:objectForName("m_itemCount_label"),"CCLabelTTF");
            if(tempData.total_num == -1)then
                m_itemCount_label:setString(tempName)
            else
                m_itemCount_label:setString(tempName .. "(" .. tempData.remain_amount ..")")
            end

            --个数
            local count_label = tolua.cast(tempItem:objectForName("count_label"),"CCLabelBMFont");
            local shop_reward = tempData.shop_reward
            local shop_count = shop_reward[1][3]
            if shop_count == 1 then
                count_label:setVisible(false)
            else
                count_label:setVisible(true)
                count_label:setString("×" .. shop_count)
            end

            cclog("-------------------shop item------------------4");
            -- 购买按钮
            local m_button = tolua.cast(tempItem:objectForName("m_button"),"CCControlButton");
            m_button:setTag(index+1);
            game_util:setControlButtonTitleBMFont(self.m_button)
            -- 详情按钮
            local m_buttonItem = tolua.cast(tempItem:objectForName("m_buttonItem"),"CCControlButton");
            m_buttonItem:setTag(index+1);
            cclog("-------------------shop item------------------6");
            local open_text = tolua.cast(tempItem:objectForName("open_text"),"CCLabelTTF")
            --售空
            local black_bg_sellout = tolua.cast(tempItem:objectForName("black_bg_sellout"),"CCSprite");
            if tempData.remain_amount == 0 then
                black_bg_sellout:setVisible(true)
            else
                black_bg_sellout:setVisible(false)
            end
            --刷新的东西
            local cd_node = tempItem:nodeForName("cd_node")
            local m_cdTime = tempItem:labelTTFForName("m_cdTime")
            local cd_node_2 = tempItem:nodeForName("cd_node_2")
            local refresh_time = tempData.refresh_time
            local need_shoplevel = tempData.need_shoplevel
            
            local open_text = tempItem:labelTTFForName("open_text")
            if open_text then open_text:setString(string_helper.ccb.file77) end

            local text1 = tempItem:labelTTFForName("text1")
            text1:setString(string_helper.ccb.text13)

            game_util:setCCControlButtonTitle(m_button,string_helper.ccb.text14)
            local function timeOverCallFun(label,type)
                cd_node:setVisible(false)
                m_button:setEnabled(true)
            end
            if tempData.remain_amount ~= 0 then
                cd_node:setVisible(false)
                m_button:setEnabled(true)
            else
                if refresh_time == -1 then
                    cd_node:setVisible(false)
                    m_button:setEnabled(true)
                else
                    open_text:setString(string_helper.guild_shop_pop.refreshTime)
                    m_button:setEnabled(false)
                    cd_node:setVisible(true)

                    local timeLabel = game_util:createCountdownLabel(refresh_time,timeOverCallFun,8)
                    timeLabel:setColor(ccc3(253,92,5))
                    timeLabel:setAnchorPoint(ccp(0.5,0.5))
                    timeLabel:setPosition(ccp(0,0))
                    m_cdTime:setString("")
                    cd_node_2:removeAllChildrenWithCleanup(true)
                    if timeLabel then
                        cd_node_2:addChild(timeLabel,10,10)
                    end
                end
            end
            if need_shoplevel <= shopLevel then
                cd_node:setVisible(false)
                m_button:setEnabled(true)
            else
                m_button:setEnabled(false)
                m_cdTime:setString("")   
                open_text:setString(string_helper.guild_shop_pop.open)
                cd_node:setVisible(true)
                cd_node_2:removeAllChildrenWithCleanup(true)
                local nextLevel = game_util:createLabelTTF({text = need_shoplevel .. string_helper.guild_shop_pop.openLevel,color = ccc3(253,92,5),fontSize = 9});
                nextLevel:setAnchorPoint(ccp(0.5,0.5))
                nextLevel:setPosition(ccp(0,0))
                if nextLevel then
                    cd_node_2:addChild(nextLevel,10,10)
                end
            end
            cclog("-------------------shop item------------------7");
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            -- self:refreshRewardDetail(item);
            self:updataMsg( 3,index,'this');
        end
    end
    return TableViewHelper:createGallery2(params);
end


return guild_shop_pop_view;