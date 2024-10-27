---  新服商店

local game_shop_new_scene = {
    m_root_layer = nil,
    m_node_table_list = nil,
    m_label_dialog = nil,
    m_idTab = nil,
    m_idTab_ = nil,
    reward_node = nil,
    left_label = nil,
    m_cost_label = nil,
    left_time_label = nil,
    m_sprite_sellOut = nil,
    m_selItemId = nil,
    m_showTag = nil,
    m_show_detail = nil,
    m_num_label = nil,
    m_screenShoot = nil,
    m_tableView = nil,
};

local dialog_item_1 = string_helper.game_shop_new_scene.dialog_item_1
local dialog_item_2 = string_helper.game_shop_new_scene.dialog_item_2

--[[--
    销毁ui
]]
function game_shop_new_scene.destroy(self)
    -- body
    cclog("-----------------game_shop_new_scene destroy-----------------");
    self.m_root_layer = nil
    self.m_node_table_list = nil
    self.m_label_dialog = nil
    self.m_idTab = nil
    self.m_idTab_ = nil
    self.reward_node = nil
    self.left_label = nil
    self.m_cost_label = nil
    self.left_time_label = nil
    self.m_sprite_sellOut = nil
    self.m_selItemId = nil
    self.m_showTag = nil
    self.m_show_detail = nil
    self.m_num_label = nil
    self.m_screenShoot = nil
    self.m_tableView = nil
end
--[[--
    返回
]]
function game_shop_new_scene.back(self,backType)
    if backType == "back" then
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
    end
end
--[[--
    读取ccbi创建ui
]]
function game_shop_new_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        elseif btnTag == 201 then
            local function responseMethod( tag,gameData )
                local data = gameData:getNodeWithKey("data")
                self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
                self.m_showTag = false
                self:refreshDiscountPrice()
                self:refreshTableView()
                self:refreshDialog()
                local reward = self.m_tGameData.reward
                game_util:rewardTipsByDataTable(reward);
            end
            local params = {}
            params.shop_id = self.m_selItemId
            network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_shop_buy"), http_request_method.GET, params,"server_shop_buy")
        elseif btnTag == 202 then

            local shop = self.m_tGameData.shop
            local itemData = shop[self.m_selItemId]
            local shop_reward = itemData.shop_reward
            cclog2(shop_reward,"shop_reward")
            if shop_reward then
                local info = shop_reward[1]
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                end
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_server_shop.ccbi");

    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    if self.m_screenShoot then
        local tempSize = self.m_root_layer:getContentSize();
        self.m_screenShoot:setPosition(ccp(tempSize.width*0.5, tempSize.height*0.5));
        self.m_root_layer:addChild(self.m_screenShoot,-1);
    end

    self.m_node_table_list = ccbNode:nodeForName("m_node_table_list")
    self.m_label_dialog = ccbNode:labelTTFForName("m_label_dialog")
    -- 今日特价
    self.reward_node = ccbNode:nodeForName("reward_node")
    self.left_label = ccbNode:labelTTFForName("left_label")
    self.m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
    self.left_time_label = ccbNode:labelTTFForName("left_time_label")
    self.m_sprite_sellOut = ccbNode:spriteForName("m_sprite_sellOut")
    self.m_show_detail = ccbNode:controlButtonForName("m_show_detail")
    self.m_num_label = ccbNode:labelBMFontForName("m_num_label")

    self.m_show_detail:setOpacity(0)
    return ccbNode;
end


--[[--
    创建 新服商店 物品列表
]]
function game_shop_new_scene.createTableView(self,viewSize)
    -- cclog("===createTableView===")
    local shop = self.m_tGameData.shop or {};
    local function onCellBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        local shopId = self.m_idTab_[btnTag + 1];
        local function responseMethod( tag,gameData )
            local data = gameData:getNodeWithKey("data")
            -- cclog2(data,"data=================")

            self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
            self.m_showTag = false
            self:refreshTableView();
            self:refreshDiscountPrice()
            self:refreshDialog()
            local reward = self.m_tGameData.reward
            -- cclog2(reward,"reward==========")
            game_util:rewardTipsByDataTable(reward);
        end
        local params = {}
        params.shop_id = shopId
        network.sendHttpRequest(responseMethod,game_url.getUrlForKey("server_shop_buy"), http_request_method.GET, params,"server_shop_buy")

    end

    local params = {}
    params.viewSize = viewSize
    params.row = 1 
    params.column = 4
    params.direction = kCCScrollViewDirectionHorizontal
    params.totalItem = #self.m_idTab_
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row)
    params.newCell = function ( tableView,index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create()
            ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick)
            ccbNode:openCCBFile("ccb/ui_server_shop_item.ccbi")
            ccbNode:controlButtonForName("m_buy_btn"):setTouchPriority(GLOBAL_TOUCH_PRIORITY-2)
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
            cell:addChild(ccbNode,10,10)
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode")
            local m_buy_btn = ccbNode:controlButtonForName("m_buy_btn")
            m_buy_btn:setTag(index)
            local m_label_left_time = ccbNode:labelTTFForName("m_label_left_time")
            local m_imgNode = ccbNode:nodeForName("m_imgNode")
            local m_num_label = ccbNode:labelBMFontForName("m_num_label")
            local m_cost_label = ccbNode:labelBMFontForName("m_cost_label")
            local m_label_buy_leftTimes = ccbNode:labelTTFForName("m_label_buy_leftTimes")
            local m_sprite_sellOut = ccbNode:spriteForName("m_sprite_sellOut")
            m_imgNode:removeAllChildrenWithCleanup(true)
            m_label_buy_leftTimes:getParent():setVisible(false)
            m_sprite_sellOut:setVisible(false)
            -- 获取数据
            -- local shop = self.m_tGameData.shop
            -- local itemData = shop[self.m_idTab[index+1]]
            
            local itemData = shop[self.m_idTab_[index+1]]
            local shop_reward = itemData.shop_reward
            -- cclog2(itemData,"itemData=")
            if itemData then
                if shop_reward then
                    local icon,name,count = game_util:getRewardByItemTable(shop_reward[1])
                    -- cclog2(count,"count")
                    -- cclog2(icon,"icon")
                    if icon then
                        m_imgNode:addChild(icon)
                    end

                    if count then
                        m_num_label:setString(tostring("x"..count))
                    end
                end

                local time_remain = itemData.time_remain
                -- cclog2(time_remain,"time_remain")
                if time_remain > 0 then
                    local minutes = math.floor(time_remain/60)
                    local hours = math.floor(minutes/60)
                    local days = math.floor(hours/24)

                    local days_text,hours_text,minutes_text = "","",""

                    if 99 > days and days > 0 then
                        days_text = days
                        m_label_left_time:setString(tostring(days_text..string_helper.game_shop_new_scene.day .. string_helper.game_shop_new_scene.dl))
                    else
                        m_label_left_time:setString(tostring(string_helper.game_shop_new_scene.dl_day))
                    end
                    if 24 > hours and hours > 0 then
                        hours_text = hours
                        m_label_left_time:setString(tostring(hours_text..string_helper.game_shop_new_scene.hour .. string_helper.game_shop_new_scene.dl))

                    end
                    if 60 > minutes and minutes > 0 then
                        minutes_text =  minutes
                        m_label_left_time:setString(minutes_text..string_helper.game_shop_new_scene.minate .. tostring(string_helper.game_shop_new_scene.dl))
                    end
                else
                    -- 道具时间到
                    m_label_left_time:setString(string_helper.game_shop_new_scene.stop_buy)
                end

                local sell_remain = itemData.sell_remain
                -- cclog2(sell_remain,"sell_remain")
                if sell_remain > 0 then 
                    m_label_buy_leftTimes:getParent():setVisible(true)
                    m_label_buy_leftTimes:setString(sell_remain..string_helper.game_shop_new_scene.ci .. tostring(string_helper.game_shop_new_scene.dl))
                elseif sell_remain == 0 then -- 售罄
                    m_sprite_sellOut:setVisible(true)
                    self.m_show_detail:setTouchEnabled(false)
                elseif sell_remain < 0 then  -- 无数量限制
                    m_label_buy_leftTimes:getParent():setVisible(false)
                end

                local need_coin = itemData.need_coin
                -- cclog2(need_coin,"need_coin")
                if need_coin then
                    m_cost_label:setString(tostring(need_coin))
                end

            else
                -- 没有任何物品在售
                self.m_node_table_list:setVisible(false)
            end
        end
        return cell
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- game_util:addMoveTips({text = "物品弹框"})
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local shop = self.m_tGameData.shop
            local itemData = shop[self.m_idTab_[index + 1]]
            -- cclog2(itemData,"itemData===")
            local shop_reward = itemData.shop_reward or {}
            if #shop_reward > 0 then
                local info = shop_reward[1]
                local tempType = info[1]
                if tempType == 6 then--道具
                    local itemId = info[2]
                    game_scene:addPop("game_item_info_pop",{itemId = itemId,openType = 2})
                elseif tempType == 7 then--装备
                    local equipId = info[2]
                    local equipData = {lv = 1,c_id = equipId,id = -1,pos = -1}
                    game_scene:addPop("game_equip_info_pop",{tGameData = equipData});
                elseif tempType == 5 then--卡牌
                    local cId = info[2]
                    game_scene:addPop("game_hero_info_pop",{cId = tostring(cId),openType = 4})
                else                   -- 食品
                    game_scene:addPop("game_food_info_pop",{itemData = info})
                end
            end
        end
    end
    return TableViewHelper:create(params);
end

function game_shop_new_scene.refreshTableView(self)
    local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
    self.m_node_table_list:removeAllChildrenWithCleanup(true);
    self.m_tableView = nil
    self.m_tableView = self:createTableView(self.m_node_table_list:getContentSize());
    if self.m_tableView then
        self.m_node_table_list:addChild(self.m_tableView)
    end
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
    
end
--[[--
    刷新今日特价
]]
function game_shop_new_scene.refreshDiscountPrice( self )
    self.left_label:setVisible(true)
    self.m_sprite_sellOut:setVisible(false)
    -- cclog2(self.m_tGameData,"self.m_tGameData====")
    -- local m_showid_sort = {}
    -- if #self.m_idTab == 0 then return end
    -- for i=1,#self.m_idTab do
    --     -- cclog2(self.m_idTab[i],"self.m_idTab[i]==")
    --     local shop = self.m_tGameData.shop
    --     local itemData = shop[self.m_idTab[i]]
    --     -- cclog2(itemData,"itemData==")
    --     local show_id = itemData.show_id
    --     table.insert(m_showid_sort,show_id)
    -- end
    -- cclog2(m_showid_sort,"m_showid_sort=====")
    -- table.sort(m_showid_sort,function(data1,data2) return data1 < data2 end)
    -- local table_id = {} -- 对应的id表
    -- local table_reward_minShowid = {}
    -- local m_min_showid = m_showid_sort[1] -- 获得最小的show_id
    local shop = self.m_tGameData.shop
    -- for k,v in pairs(shop) do -- 将他们的shop_reward 放入一个表 table_reward_minShowid 中
    --     if v and v.show_id == m_min_showid then
    --         table.insert(table_id,k)
    --         table.insert(table_reward_minShowid, v.shop_reward)
    --     end
    -- end
    -- cclog2(table_reward_minShowid,"table_reward_minShowid")
    -- local tempTableLen = game_util:getTableLen(table_reward_minShowid)
    -- cclog2(tempTableLen,"tempTableLen=")
    -- local random = math.random(1,tempTableLen)
    -- cclog2(random,"random=")
    if #self.m_idTab > 0 then
        local itemData = shop[self.m_idTab[1]]
        -- cclog2(itemData,"itemData-=-==")
        local shop_reward = itemData.shop_reward or {}
        -- cclog2("shop_reward")
        local icon,name,count = game_util:getRewardByItemTable(shop_reward[1])
        -- cclog2(count,"count")
        -- cclog2(name,"name")
        -- cclog2(icon,"icon")
        if icon then
            self.reward_node:addChild(icon)
        end
        if count then
            self.m_num_label:setString(tostring("x"..count))
        end
        self.m_selItemId = self.m_idTab[1]
        -- self.m_selItemId = table_id[random]
        -- local shop = self.m_tGameData.shop
        -- local itemData = shop[table_id[random]]
        -- cclog2(itemData,"==itemData==")
        local sell_remain = itemData.sell_remain
        if sell_remain > 0 then 
            self.left_label:setString(tostring(sell_remain))
        elseif sell_remain == 0 then
            self.left_label:setString(tostring(sell_remain))
            self.m_sprite_sellOut:setVisible(true)
            self.m_show_detail:setTouchEnabled(false)
        elseif sell_remain < 0 then  -- 无数量限制
            self.left_label:setString("∞")
        end

        local time_remain = itemData.time_remain
        if time_remain > 0 then
            local minutes = math.floor(time_remain/60)
            local hours = math.floor(minutes/60)
            local days = math.floor(hours/24)

            local days_text,hours_text,minutes_text = " "," "," "

            if 99 > days and days > 0 then
                days_text = days
                self.left_time_label:setString(tostring(days_text..string_helper.game_shop_new_scene.day))
            else
                self.left_time_label:setString(tostring(string_helper.game_shop_new_scene.da_day))
            end
            if 24 > hours and hours > 0 then
                hours_text = hours
                self.left_time_label:setString(tostring(hours_text..string_helper.game_shop_new_scene.hour))

            end
            if 60 > minutes and minutes > 0 then
                minutes_text =  minutes
                self.left_time_label:setString(tostring(minutes_text..string_helper.game_shop_new_scene.minate))
            end
        else
            -- 道具时间到
            self.left_time_label:setString(string_helper.game_shop_new_scene.stop_buy)
        end

        local need_coin = itemData.need_coin
        if need_coin then
            self.m_cost_label:setString(tostring(need_coin))
        end
    else
        self.left_label:setVisible(false)
        self.m_cost_label:setVisible(false)
        self.left_time_label:setVisible(false)
        self.m_sprite_sellOut:setVisible(false)
        self.m_num_label:setVisible(false)
        self.m_show_detail:setTouchEnabled(false)
    end
end

--[[--
    刷新 对话框
]]
function game_shop_new_scene.refreshDialog( self,showTag )
    self.m_label_dialog:removeAllChildrenWithCleanup(true)
    self.m_label_dialog:stopAllActions();
    local lengh_1 = #dialog_item_1
    local lengh_2 = #dialog_item_2
    local i = 0
    local function callFunc( )
        if self.m_showTag then
            self.m_label_dialog:setString(tostring(dialog_item_1[math.random(lengh_1)]))
        else

            self.m_label_dialog:setString(tostring(dialog_item_2[math.random(lengh_2)]))
            i = i + 1
            if i == 2 then
                self.m_showTag = true
            end

        end
    end
    local animArr = CCArray:create();
    animArr:addObject(CCFadeIn:create(0.8));
    animArr:addObject(CCDelayTime:create(10));
    animArr:addObject(CCFadeOut:create(0.8));
    animArr:addObject(CCCallFuncN:create(callFunc));
    animArr:addObject(CCFadeIn:create(0.8));
    animArr:addObject(CCDelayTime:create(10));
    animArr:addObject(CCFadeOut:create(0.8));
    animArr:addObject(CCCallFuncN:create(callFunc));
    self.m_label_dialog:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
    callFunc();
end


--[[--
    刷新ui
]]
function game_shop_new_scene.refreshUi(self)
    self:refreshTableView()
    self:refreshDialog()
    self:refreshDiscountPrice()
end


--[[--
    初始化
]]
function game_shop_new_scene.init(self,t_params)
    t_params = t_params or {};
    self.m_screenShoot = t_params.screenShoot
    if t_params.gameData and tolua.type(t_params.gameData) == "util_json" then
        local data = t_params.gameData:getNodeWithKey("data")
        self.m_tGameData = json.decode(data:getFormatBuffer())
    else
        self.m_tGameData = {};
    end
    self.m_selItemId = nil
    self.m_showTag = true
    self.m_tableView = nil

    -- cclog2(self.m_tGameData,"self.m_tGameData111111====")
    self.m_idTab = {}
    self.m_idTab_ = {}
    local shop = self.m_tGameData.shop or {}
    -- cclog2(shop,"shop")
    for k,v in pairs(shop) do
        table.insert(self.m_idTab,k) 
    end
    local function sortfunc( data1,data2 )
        local itemData1 = shop[data1]
        local itemData2 = shop[data2]
        return itemData1.show_id < itemData2.show_id
    end
    table.sort( self.m_idTab, sortfunc )
    self.m_idTab_ = util.table_copy(self.m_idTab);
    -- cclog2(self.m_idTab_,"self.m_idTab_")
    table.remove(self.m_idTab_,1)
    -- cclog2(self.m_idTab_,"self.m_idTab_11")
end

--[[--
    创建ui入口并初始化数据
]]
function game_shop_new_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_shop_new_scene;