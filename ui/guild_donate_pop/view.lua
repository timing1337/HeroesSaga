require "shared.extern"

local guild_donate_pop_view = class("guildDonatePopView",require("like_oo.oo_popBase"));

guild_donate_pop_view.m_ccb = nil;
guild_donate_pop_view.m_score = nil;
guild_donate_pop_view.m_editBox1 = nil;
guild_donate_pop_view.m_editBox2 = nil;

guild_donate_pop_view.food_label = nil;
guild_donate_pop_view.battle_flag_label = nil;
guild_donate_pop_view.lastScore = nil;

guild_donate_pop_view.m_board = {};

--场景创建函数
function guild_donate_pop_view:onCreate(  )

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点

	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2,{goods = self.m_editBox1:getText() , war_flag = self.m_editBox2:getText()});
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);

	self.m_ccb:openCCBFile("ccb/pop_guild_donate.ccbi");
	-- self.m_score = tolua.cast(self.m_ccb:objectForName("m_score"),"CCLabelTTF");
	self.m_score = tolua.cast(self.m_ccb:objectForName("m_score"),"CCLabelBMFont");
	
	local tempEditNode1 = tolua.cast(self.m_ccb:objectForName("m_editBox1"),"CCNode");
	local tempEditNode2 = tolua.cast(self.m_ccb:objectForName("m_editBox2"),"CCNode");

	self.battle_flag_label = tolua.cast(self.m_ccb:objectForName("battle_flag_label"),"CCLabelTTF")--捐献食物/金属等
	self.food_label = tolua.cast(self.m_ccb:objectForName("food_label"),"CCLabelTTF")--捐献战旗

	local text1 = self.m_ccb:labelTTFForName("text1")
	text1:setString(string_helper.ccb.text7)

	self:refreshLabel()

	for i=1,3 do
		self.m_board[i] = tolua.cast(self.m_ccb:objectForName("m_board" .. tostring(i)),"CCSprite");
	end
	self.m_board[1]:setVisible(true);
	self.m_board[2]:setVisible(false);
	self.m_board[3]:setVisible(false);

	local function editBoxTextEventHandle1(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_guildName = edit:getText();
        end
    end
    self.m_editBox1 = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle1,size = tempEditNode1:getContentSize(),placeHolder=""});
    self.m_editBox1:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    tempEditNode1:addChild(self.m_editBox1);

    local function editBoxTextEventHandle2(strEventName,pSender)
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt
        if strEventName == "changed" then
            -- strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
            -- print(strFmt)
            self.m_guildName = edit:getText();
        end
    end
    self.m_editBox2 = game_util:createEditBox({bgFileName = nil,scriptEditBoxHandler=editBoxTextEventHandle2,size = tempEditNode2:getContentSize(),placeHolder=""});
    self.m_editBox2:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    tempEditNode2:addChild(self.m_editBox2);


    self.m_score:setString(tostring(self.m_control.m_data:getScore()));
    self.lastScore = self.m_control.m_data:getScore()
    cclog("self.lastScore == " .. self.lastScore)

	self.m_rootView:addChild(self.m_ccb);
end
function guild_donate_pop_view.getLastScore()
	return self.lastScore
end
function guild_donate_pop_view:refreshLabel()
	self.food_label:setString(string_helper.guild_donate_pop.canDonate .. self.m_control.m_data:getMaxGoods())
	self.battle_flag_label:setString(string_helper.guild_donate_pop.todayCan.. self.m_control.m_data:getMaxShowFlag() .. string_helper.guild_donate_pop.have .. self.m_control.m_data:getMyFlagCount())
end

function guild_donate_pop_view:onEnter(  )

end

function guild_donate_pop_view:onCommand( command , data )
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end

function guild_donate_pop_view:setEdit1( str )
	self.m_editBox1:setText(str);
end

function guild_donate_pop_view:setEdit2( str )
	self.m_editBox2:setText(str);
end

function guild_donate_pop_view:setScore( score )
	self.m_score:setString(tostring(score));
end

function guild_donate_pop_view:setBoard( flag )
	if(flag == "food")then
		self.m_board[1]:setVisible(true);
		self.m_board[2]:setVisible(false);
		self.m_board[3]:setVisible(false);
	elseif(flag == "metal")then
		self.m_board[1]:setVisible(false);
		self.m_board[2]:setVisible(true);
		self.m_board[3]:setVisible(false);
	elseif(flag == "energy")then
		self.m_board[1]:setVisible(false);
		self.m_board[2]:setVisible(false);
		self.m_board[3]:setVisible(true);
	end
end

return guild_donate_pop_view;



