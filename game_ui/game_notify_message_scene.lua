---  消息
local game_notify_message_scene = {
    m_tGameData = nil,
    m_root_layer = nil,
    m_list_view_bg = nil,

    icon_node = nil,
};


--[[--
    销毁
]]
function game_notify_message_scene.destroy(self)
    -- body
    cclog("-----------------game_notify_message_scene destroy-----------------");
    self.m_tGameData = nil;
    self.m_root_layer = nil;
    self.m_list_view_bg = nil;
    self.icon_node = nil;
end
--[[--
    返回
]]
function game_notify_message_scene.back(self,type)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end
--[[--
    读取ccbi创建ui
]]
function game_notify_message_scene.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_notify_message.ccbi");
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    return ccbNode;
end

function game_notify_message_scene.receiveAwards(self,index)
    local tGameData = self.m_tGameData.messages or {};
    local itemData = tGameData[index+1]
    function responseMethod(tag,gameData)
        local data = gameData:getNodeWithKey("data");
        self.m_tGameData = json.decode(data:getFormatBuffer()) or {}
        game_util:rewardTipsByDataTable(self.m_tGameData.reward);
        self:refreshUi();
    end
    local params = {};
    params.message_id = itemData.id;
    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("notify_read"), http_request_method.GET, params,"notify_read")
end

--[[--
    创建消息列表
]]
function game_notify_message_scene.createMessageTableView(self,viewSize)
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog("btnTag ================= " .. btnTag)
        -- self:receiveAwards(btnTag);
        local t_params = {}
        t_params.messages = self.m_tGameData.messages[btnTag+1]
        t_params.okBtnCallBack = function()
            game_scene:removePopByName("game_message_pop")
            self:receiveAwards(btnTag);
            -- network.sendHttpRequest(responseMethod,game_url.getUrlForKey("user_online_award"), http_request_method.GET, nil,"user_online_award")
        end
        --打开消息详细
        game_scene:addPop("game_message_pop",t_params)
    end

    local tGameData = self.m_tGameData.messages or {};
    local params = {};
    params.viewSize = viewSize;
    params.row = 3;--行
    params.column = 1; --列
    params.direction = kCCScrollViewDirectionVertical;
    params.totalItem = #tGameData;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY+1;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new()
            cell:autorelease()
            local ccbNode = luaCCBNode:create();
            ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
            ccbNode:openCCBFile("ccb/ui_notify_message_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5));
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local itemData = tGameData[index+1];
            if ccbNode then
                local m_name_label = ccbNode:labelTTFForName("m_name_label")
                local m_detail_label = ccbNode:labelTTFForName("m_detail_label")
                local m_reward_btn = ccbNode:controlButtonForName("m_reward_btn")
                game_util:setCCControlButtonTitle(m_reward_btn,string_helper.ccb.title136)
                local icon_node = ccbNode:nodeForName("icon_node")
                local yincang_label = ccbNode:labelTTFForName("yincang_label")

                if itemData.send_name == "sys" then
                    m_name_label:setString(string_helper.game_notify_message_scene.sys_msg)
                else
                    m_name_label:setString(itemData.send_name)
                end
                local contentTab = util.stringSplit(itemData.content,"\n")
                local content = contentTab[1]
                local length = string.len(content)
                if length > 60 then
                    -- content = string.sub(itemData.content,1,60)
                    -- cclog("content 111 == " ..content )
                    -- content = content .. "..."
                    -- local lastLabel = game_util:createLabelTTF({text = "...",color = ccc3(153,102,51),fontSize = 12});
                    -- lastLabel:setAnchorPoint(ccp(0,0.5))
                    -- lastLabel:setPosition(ccp(270,0))
                    -- m_detail_label:removeAllChildrenWithCleanup(true)
                    -- m_detail_label:addChild(lastLabel)
                    yincang_label:setVisible(true)
                else
                    yincang_label:setVisible(false)
                end
                m_detail_label:setString(content);
                -- if #itemData.gift > 0 then
                    m_reward_btn:setVisible(true);
                -- else
                    -- m_reward_btn:setVisible(false);
                -- end
                m_reward_btn:setTag(index);
            end
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,cell)
        if eventType == "ended" and cell then

        end
    end
    return TableViewHelper:create(params);
end

--[[--
    刷新ui
]]
function game_notify_message_scene.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tempTableView = self:createMessageTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tempTableView);
end

--[[--
    初始化
]]
function game_notify_message_scene.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_tGameData = {};
    if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
        self.m_tGameData = json.decode(t_params.gameData:getNodeWithKey("data"):getFormatBuffer()) or {}
    end
    -- cclog("self.m_tGameData == " .. json.encode(self.m_tGameData))
end

--[[--
    创建ui入口并初始化数据
]]
function game_notify_message_scene.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi())
    self:refreshUi();
    return scene;
end

return game_notify_message_scene;