---  商店

local game_shop_scene = {
    m_list_view_bg = nil,
    m_title_label = nil,
    m_num_label = nil,

    other_node = nil,--4合1
};

--[[--
    销毁ui
]]
function game_shop_scene.destroy(self)
    -- body
    cclog("-----------------game_shop_scene destroy-----------------");
    self.m_list_view_bg = nil;
    self.m_title_label = nil;
    self.m_num_label = nil;

    self.other_node = nil;
end
--[[--
    返回
]]
function game_shop_scene.back(self,backType)
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
function game_shop_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--返回
            self:back("back");
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/ui_game_shop2.ccbi");
    self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCNode");
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_num_label = ccbNode:labelTTFForName("m_num_label")

    self.other_node = ccbNode:nodeForName("other_node")
    self.m_title_label:setString(string_helper.game_shop_scene.diamond_buy)
    return ccbNode;
end


--[[--
    创建充值列表
]]
function game_shop_scene.createTableView(self,viewSize)
    local gameShopConfig = getConfig(game_config_field.charge);
    local shopCount = gameShopConfig:getNodeCount();
    local function payEnd( msg )
        -- body
        if(msg == "pay err")then
            -- iap不成功
        elseif(msg == "pay product err")then
            game_util:addMoveTips({text = string_helper.game_shop_scene.server_not});
        elseif(msg == "pay data ready")then
            -- 服务器验证成功
        elseif(msg == "pay data err")then
            -- 服务器验证单据错误
        else
            -- iap成功,msg为iap的boundle
            local tempNode = nil;
            for i=0,shopCount-1 do
                -- tempNode = gameShopConfig:getNodeAt(i);
                tempNode = gameShopConfig:getNodeWithKey(tostring(i))
                if(tempNode:getNodeWithKey("cost"):toStr()==msg)then
                    local tempCoin = tempNode:getNodeWithKey("coin"):toInt();
                    game_data.m_tUserStatusData.coin=game_data.m_tUserStatusData.coin+tempCoin;
                    game_scene:fillPropertyBarData();
                    self.m_num_label:setString(tostring(game_data:getUserStatusDataByKey("coin") or 0));
                end
            end
        end
        require("game_ui.game_loading").close();
    end
    registerCallBack(payEnd);
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行

    params.column = 4; --列
    -- params.direction = kCCScrollViewDirectionHorizontal;
    params.totalItem = shopCount;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()

            cell:autorelease()
            -- local spriteLand = CCLayerColor:create(ccc4(0, 0, 125, 125), 60, 30)
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/ui_game_recharge_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            -- local tempNode = gameShopConfig:getNodeAt(index);
            local tempNode = gameShopConfig:getNodeWithKey(tostring(index))
            if ccbNode then
                local price = tempNode:getNodeWithKey("price"):toInt();
                local m_bg_spr = ccbNode:spriteForName("m_bg_spr");
                local m_tips_label = ccbNode:labelTTFForName("m_tips_label")
                local m_gain_label = ccbNode:labelTTFForName("m_gain_label")
                local m_cost_label = ccbNode:labelTTFForName("m_cost_label")
                local m_node = ccbNode:nodeForName("m_node")
                m_tips_label:setString(tempNode:getNodeWithKey("name"):toStr())
                m_cost_label:setString("¥" .. price);
                m_gain_label:setString(tempNode:getNodeWithKey("coin"):toStr());
                local icon = game_util:createIconByName(tempNode:getNodeWithKey("icon"):toStr())
                m_node:removeAllChildrenWithCleanup(true);
                if icon then
                    m_node:addChild(icon);
                end
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
                local gameShopConfig = getConfig(game_config_field.charge);
                --     buy("zombiecoinTier1");
                --     require("game_ui.game_loading").show(); 
                local bundle = gameShopConfig:getNodeWithKey(tostring(index+1)):getNodeWithKey("cost"):toStr();
                buy(bundle);
                require("game_ui.game_loading").show(); 
        end
    end
    return TableViewHelper:createGallery2(params);
end

--[[--
    刷新ui
]]
function game_shop_scene.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    self.m_num_label:setString(tostring(game_data:getUserStatusDataByKey("coin") or 0));

    --刷新4合1接口
    -- self:refresh4In1()
end
--[[
    4合1
]]
function game_shop_scene.refresh4In1(self)
    self.select_node:removeAllChildrenWithCleanup(true)
    local tableView = game_util:setGachaSelect(self.select_node:getContentSize(),2)
    self.select_node:addChild(tableView)
end
--[[--
    初始化
]]
function game_shop_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
end

--[[--
    创建ui入口并初始化数据
]]
function game_shop_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_shop_scene;