require "shared.extern"

local guild_research_pop_view = class("guildResearchPopView",require("like_oo.oo_popBase"));

guild_research_pop_view.m_ccb = nil;
guild_research_pop_view.m_money = nil;
guild_research_pop_view.m_glv = {};

guild_research_pop_view.lv_sprite = {};
guild_research_pop_view.tech_btn = {};

--场景创建函数
function guild_research_pop_view:onCreate(  )
	-- body

	-- 此处添加自己的代码，创建ui
	-- m_rootView 为当前view的根显示节点
	self.m_ccb = luaCCBNode:create();
	local function onBack( target,event )
		-- body
		self:updataMsg(2);
	end
	local function onButtonClick( target,event )
		-- body
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2);
	end
	local function onMainBtnClick( target,event )
		
	end
	self.m_ccb:registerFunctionWithFuncName("onBack",onBack);
	self.m_ccb:registerFunctionWithFuncName("onButtonClick",onButtonClick);
	self.m_ccb:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	self.m_ccb:openCCBFile("ccb/pop_guild_research.ccbi");

	self.m_rootView:addChild(self.m_ccb);

	self.m_money = tolua.cast(self.m_ccb:objectForName("m_money"),"CCLabelTTF");

	self:resetData();
end

function guild_research_pop_view:resetData(  )
	local openCfg = self.m_control.m_data:getTechOpenCfg()

	self.m_money:setString(tostring(self.m_control.m_data:getMoney()));

	local tempGuildData = self.m_control.m_data:getGuildData();
	for i=1,8 do
		self.m_glv[i] = tolua.cast(self.m_ccb:objectForName("m_glv_" .. tostring(i)),"CCLabelTTF");

		self.m_glv[i]:setString(tostring(self.m_control.m_data:getLvWithIndex(i)));

		--开启条件
		self.lv_sprite[i] = tolua.cast(self.m_ccb:objectForName("lv_sprite_" .. tostring(i)),"CCSprite")
		self.tech_btn[i] = tolua.cast(self.m_ccb:objectForName("tech_btn_" .. tostring(i)),"CCControlButton")
		local itemCfg = openCfg[tostring(i)]
		local open_level = itemCfg["open_level"]
		if open_level == -1 then 
			self.lv_sprite[i]:setVisible(false)
			self.tech_btn[i]:setEnabled(false)
			self.m_glv[i]:setVisible(false)

			self.tech_btn[i]:setColor(ccc3(76,76,76))
			local label = game_util:createLabelBMFont({text = string_helper.guild_research_pop.openDeny, color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));
			label:setPosition(ccp(self.tech_btn[i]:getContentSize().width*0.5,-5))
			self.tech_btn[i]:addChild(label)
		elseif open_level > tempGuildData then
			self.lv_sprite[i]:setVisible(false)
			self.tech_btn[i]:setEnabled(false)
			self.m_glv[i]:setVisible(false)

			self.tech_btn[i]:setColor(ccc3(76,76,76))
			local label = game_util:createLabelBMFont({text = "Lv." .. open_level .. string_helper.guild_research_pop.openLevel, color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));
			label:setPosition(ccp(self.tech_btn[i]:getContentSize().width*0.5,-5))
			self.tech_btn[i]:addChild(label)
		else 
			self.lv_sprite[i]:setVisible(true)
			self.tech_btn[i]:setEnabled(true)
			self.m_glv[i]:setVisible(true)
		end
	end
end

function guild_research_pop_view:onEnter(  )
	-- body
end

function guild_research_pop_view:onCommand( command , data )
	-- body
	-- view内命令回调函数
	-- 发命令用updataCommand（参考oo_viewBase）;
end


return guild_research_pop_view;