---  领奖
local game_guild_message_pop = {
    message_node = nil,
    m_leave_message_btn = nil,
    m_ok_btn = nil,
    edit_node = nil,
    m_close_btn = nil,
    m_root_layer = nil,
    m_notices = nil,
    guild_msg = nil,
    m_msgText = nil,
    m_gameData = nil,
    m_editBox = nil,

    edit_text = nil,
};
--[[--
    销毁ui
]]
function game_guild_message_pop.destroy(self)
    -- body
    cclog("-----------------game_guild_message_pop destroy-----------------");

    self.message_node = nil;
    self.m_leave_message_btn = nil;
    self.m_ok_btn = nil;
    self.edit_node = nil;
    self.m_close_btn = nil;
    self.m_root_layer = nil;
    self.m_notices = nil;
    self.guild_msg = nil;
    self.m_msgText = nil;
    self.m_gameData = nil;
    self.m_editBox = nil;

    self.edit_text = nil;
end
--[[--
    返回
]]
function game_guild_message_pop.back(self,backType)
    local association_id = game_data:getUserStatusDataByKey("association_id");
    require("like_oo.oo_controlBase"):openView("guild");
    -- game_scene:removePopByName("game_guild_message_pop");
    -- self:destroy();
end
--[[--
    读取ccbi创建ui
]]
function game_guild_message_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        cclog2(btnTag,"btnTag")
        if btnTag == 1 then
            self:back()
        elseif btnTag == 100 then--留言
            local strLen = string.len(self.edit_text)
            if strLen > 0 then
                local params = {}
                params.msg = util.url_encode(self.edit_text)
                local function responseMethod(tag,gameData)
                    local data = gameData:getNodeWithKey("data")
                    cclog2(data,"data")
                    local player_msg = data:getNodeWithKey("player_msg")
                    self.guild_msg = json.decode(player_msg:getFormatBuffer())
                    game_util:addMoveTips({text = string_helper.game_guild_message_pop.text})
                    self.m_editBox:setText("")
                    self.edit_text = ""
                    self:refreshUi()
                end
                network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_add_msg"), http_request_method.GET, params,"association_add_msg")
            else
                game_util:addMoveTips({text = string_helper.game_guild_message_pop.text2})
            end
        elseif btnTag == 101 then--确定
            local guild_data = self.m_gameData
            local guild_player = guild_data.data.player
            local myUid = game_data:getUserStatusDataByKey("uid");
            local user_post = guild_player[tostring(myUid)].title
        
            if user_post == "owner" or user_post == "vp" then
                local strLen = string.len(self.edit_text)
                if strLen > 0 then
                    -- self:updataMsg( 1234 , self.m_data:getGuildData() , "guild" )
                    local params = {}
                    params.notice = util.url_encode(self.edit_text)
                    local function responseMethod(tag,gameData)
                        self.m_notices = self.edit_text
                        self.m_msgText:setString(tostring(self.m_notices))
                        self.m_editBox:setText("")
                        self.edit_text = ""
                        game_util:addMoveTips({text = string_helper.game_guild_message_pop.text3})
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("association_add_notice"), http_request_method.GET, params,"association_add_notice")
                else
                    game_util:addMoveTips({text = string_helper.game_guild_message_pop.text4})
                end
            else
                game_util:addMoveTips({text = string_helper.game_guild_message_pop.text5})
            end
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
    ccbNode:openCCBFile("ccb/pop_guild_message.ccbi");

    self.message_node = ccbNode:nodeForName("message_node")
    self.m_leave_message_btn = ccbNode:controlButtonForName("m_leave_message_btn")
    self.m_ok_btn = ccbNode:controlButtonForName("m_ok_btn")
    local edit_node = ccbNode:layerForName("edit_node")
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_msgText = ccbNode:labelTTFForName("m_msgText")

    -- game_util:setControlButtonTitleBMFont(self.m_leave_message_btn)
    -- game_util:setControlButtonTitleBMFont(self.m_ok_btn)
    game_util:setCCControlButtonTitle(self.m_leave_message_btn,string_helper.ccb.text8)
    game_util:setCCControlButtonTitle(self.m_ok_btn,string_helper.ccb.text9)

    self.m_leave_message_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_ok_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text10)
    --公告内容
    local notice_text = self.m_notices
    self.m_msgText:setString(tostring(notice_text))

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- self.m_guildName = edit:getText();
            -- self.edit_flag = true
            -- self.notice_text = edit:getText()
            -- self.m_msgText:setString(tostring(edit:getText()))
            self.edit_text = tostring(edit:getText())
        end
    end

    -- if user_post == "owner" or user_post == "vp" then
        local editSize = edit_node:getContentSize()
        self.m_editBox = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle,size = edit_node:getContentSize(),placeHolder=""});
        self.m_editBox:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 11);
        self.m_editBox:setMaxLength(140)
        edit_node:addChild(self.m_editBox);
    -- end

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end

    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 10,true);
    self.m_root_layer:setTouchEnabled(true);

    return ccbNode;
end

--[[
    
]]
function game_guild_message_pop.createContentTableView(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 5;
    params.column = 1; --列
    params.totalItem = #self.guild_msg;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-11;
    params.direction = kCCScrollViewDirectionVertical;--纵向
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create();
            ccbNode:openCCBFile("ccb/pop_guild_message_item.ccbi");
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell ~= nil then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            --
            
            local name_label = ccbNode:labelTTFForName("name_label")
            local time_label = ccbNode:labelTTFForName("time_label")
            local message_label = ccbNode:labelTTFForName("message_label")

            local itemMsg = self.guild_msg[#self.guild_msg-index]
            local name = itemMsg.name
            local text = itemMsg.text
            local time = itemMsg.time

            name_label:setString(tostring(name))
            message_label:setString(tostring(text))
            time_label:setString(tostring(time))
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    return TableViewHelper:create(params);
end
--[[--
    刷新ui
]]
function game_guild_message_pop.refreshUi(self)
    self.message_node:removeAllChildrenWithCleanup(true)
    local textTableTemp = self:createContentTableView(self.message_node:getContentSize())
    self.message_node:addChild(textTableTemp,10,10);
end
--[[--
    初始化
]]
function game_guild_message_pop.init(self,t_params)
    t_params = t_params or {};
    self.m_gameData = t_params.m_gameData
    self.m_notices = t_params.m_gameData.data.guild_notice
    self.guild_msg = t_params.m_gameData.data.guild_msg
    self.edit_text = ""
    -- cclog2(self.m_notices,"self.m_notices")
    -- cclog2(self.guild_msg,"self.guild_msg")
end

--[[--
    创建ui入口并初始化数据
]]
function game_guild_message_pop.create(self,t_params)
    self:init(t_params);
    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();

    return scene;
end

return game_guild_message_pop;