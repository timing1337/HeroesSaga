require "shared.extern"

local guild_view = class("guildView",require("like_oo.oo_sceneBase"));

-- guild level
guild_view.m_glv = nil;
-- guild name
guild_view.m_gname = nil;
-- guild be had money
guild_view.m_gmoney = nil;
-- guild be had flag with war
guild_view.m_gflag = nil;
-- guild's main button
guild_view.m_gbutton = {};
-- guild's button text
guild_view.m_gtext = {};
-- ccbNode
guild_view.m_gccb = nil;
-- layer that content war button 
guild_view.m_warBL = nil;

guild_view.m_button_7 = nil;
 
--boss
guild_view.m_button_8 = nil;

--新公会战
guild_view.m_button_9 = nil;

guild_view.m_ID = nil;

guild_view.m_reward_btn = nil;

function guild_view:create(  )
	local scene = self.sceneBase.create( self );
	local function onButtonClick( target,event )
		local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        self:updataMsg(btnTag+2);
	end

	local function onHome( target,event )
		self:updataMsg(2,nil);
	end
	self.m_gccb = luaCCBNode:create();
	self.m_gccb:registerFunctionWithFuncName( "onButtonClick",onButtonClick );
	self.m_gccb:registerFunctionWithFuncName( "onHome",onHome );
	self.m_gccb:openCCBFile("ccb/ui_new_guild_main.ccbi");
	for i=1,6 do
		self.m_gbutton[i] = tolua.cast(self.m_gccb:objectForName("m_button_" .. tostring(i)),"CCControlButton");
		self.m_gtext[i] = tolua.cast(self.m_gccb:objectForName("m_text_" .. tostring(i)),"CCSprite");
	end

	local openCfg = self.m_control.m_data:getOpenLevel()
	-- cclog("openCfg == " .. json.encode(openCfg))
	--重置建筑顺序
	local buildId = {4,6,2,5,1}
	local tempGuildData = self.m_control.m_data:getGuildData();
	for i=1,#buildId do
		-- cclog("buildId[i] = " .. buildId[i])
		local itemCfg = openCfg[tostring(i)]
		-- cclog("itemCfg == " .. json.encode(itemCfg))
		local open_level = itemCfg["open_level"]
		-- cclog2(open_level,"open_level")
		-- cclog2(i,"i")
		if open_level == -1 then
			self.m_gbutton[buildId[i]]:setEnabled(false)
			self.m_gbutton[buildId[i]]:setColor(ccc3(76,76,76))
			local label = game_util:createLabelBMFont({text = string_helper.guild.openDeny, color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));

			label:setPosition(ccp(self.m_gbutton[buildId[i]]:getContentSize().width*0.5,self.m_gbutton[buildId[i]]:getContentSize().height*0.5))

			self.m_gbutton[buildId[i]]:addChild(label)
		elseif open_level > tempGuildData.guild_lv then
			self.m_gbutton[buildId[i]]:setEnabled(false)
			self.m_gbutton[buildId[i]]:setColor(ccc3(76,76,76))
			local label = game_util:createLabelBMFont({text = open_level .. string_helper.guild.openLevel , color = ccc3(255,241,44)})
			label:setAnchorPoint(ccp(0.5,0.5));

			label:setPosition(ccp(self.m_gbutton[buildId[i]]:getContentSize().width*0.5,self.m_gbutton[buildId[i]]:getContentSize().height*0.5))

			self.m_gbutton[buildId[i]]:addChild(label)
		else
			self.m_gbutton[buildId[i]]:setEnabled(true)
		end
	end
	local guild_war_open = openCfg["6"].open_level
	self.m_button_7 = tolua.cast(self.m_gccb:objectForName("m_button_7"),"CCControlButton");
	local anmi_sprite = tolua.cast(self.m_gccb:objectForName("anmi_sprite"),"CCSprite");
	--公会boss
	self.m_button_8 = tolua.cast(self.m_gccb:objectForName("m_button_8"),"CCControlButton");
	self.m_button_8:setOpacity(0)

	--新公会战
	self.m_button_9 = tolua.cast(self.m_gccb:objectForName("m_button_9"),"CCControlButton");
	local pX,pY = self.m_button_9:getPosition();
    local animArr = CCArray:create();
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY+3)),CCTintTo:create(1,175,175,175)))
    animArr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(1,ccp(pX, pY-3)),CCTintTo:create(1,255,255,255)))
    self.m_button_9:runAction(CCRepeatForever:create(CCSequence:create(animArr)))
    local m_text_4 = tolua.cast(self.m_gccb:objectForName("m_text_4"),"CCSprite")
    --JIANGLI 
    self.m_reward_btn = tolua.cast(self.m_gccb:objectForName("m_reward_btn"),"CCControlButton");
	if tempGuildData.guild_lv >= guild_war_open then
		-- self.m_button_7:setEnabled(true)
		-- anmi_sprite:setVisible(true)
	else
		-- self.m_button_7:setEnabled(false)
		local label = game_util:createLabelBMFont({text = guild_war_open .. string_helper.guild.open , color = ccc3(255,241,44)})
		label:setAnchorPoint(ccp(0.5,0.5));
		label:setPosition(ccp(self.m_button_7:getContentSize().width*0.5,self.m_button_7:getContentSize().height*0.5))
		self.m_button_7:setColor(ccc3(76,76,76))
		self.m_button_7:addChild(label)
		-- anmi_sprite:setVisible(false)
	end

	self.m_warBL = tolua.cast(self.m_gccb:objectForName("m_warBL"),"CCLayer");

	self.m_gname = tolua.cast(self.m_gccb:objectForName("m_gname"),"CCLabelTTF");
	self.m_ID = tolua.cast(self.m_gccb:objectForName("m_ID"),"CCLabelTTF");
	self.m_glv = tolua.cast(self.m_gccb:objectForName("m_glv"),"CCLabelBMFont");
	self.m_gmoney = tolua.cast(self.m_gccb:objectForName("m_gmoney"),"CCLabelBMFont");
	self.m_gflag = tolua.cast(self.m_gccb:objectForName("m_gflag"),"CCLabelBMFont");
	local boss_node = tolua.cast(self.m_gccb:objectForName("boss_node"),"CCNode")

	local bossAnim = self:createBossAnim()
	boss_node:addChild(bossAnim,10,10)


	self:updataLabel()

    --根据开关开启    self.m_button_9   m_text_4    self.m_reward_btn
    -- if game_data:isViewOpenByID( 201 ) then
    --     self.m_button_9:setVisible(true)
    --     self.m_reward_btn:setVisible(true)
    --     m_text_4:setVisible(true)
    -- else
    --     self.m_button_9:setVisible(false)
    --     self.m_reward_btn:setVisible(false)
    --     m_text_4:setVisible(false)
    -- end
    self.m_button_9:setVisible(game_data:isViewOpenByID( 201 ))
    self.m_reward_btn:setVisible(game_data:isViewOpenByID( 201 ))
    m_text_4:setVisible(game_data:isViewOpenByID( 201 ))
	scene:addChild(self.m_gccb);
	return scene;
end
--[[
	哥斯拉动画
]]
function guild_view:createBossAnim()
	local anim_node = game_util:createEffectAnim("anim_gonghuiboss",1,true)
    anim_node:setAnchorPoint(ccp(0.5,0.5))
    anim_node:setPosition(ccp(0,0));
    return anim_node
end
--[[
	
]]
function guild_view:updataLabel()
	local tempGuildData = self.m_control.m_data:getGuildData();
	self.m_gname:setString(tempGuildData.name);
	-- 更新联盟名称
	game_data:updateGuildName(tempGuildData.name)
	cclog("------------------- yock guild 1 ");
	self.m_glv:setString(tostring(tempGuildData.guild_lv));
	cclog("------------------- yock guild 2 ");
	self.m_gmoney:setString(tostring(tempGuildData.goods));
	-- local value,unit = game_util:formatValueToString(tempGuildData.goods)
	-- self.m_gmoney:setString(tostring(value .. unit));
	cclog("------------------- yock guild 3 ");
	self.m_gflag:setString(tostring(tempGuildData.war_flag));
	cclog("------------------- yock guild 4 ");
	local association_id = game_data:getUserStatusDataByKey("association_id");
	self.m_ID:setString("ID:" .. association_id)
end
function guild_view:onCommand( command , data )
	-- body
	self.sceneBase.onCommand( self , command , data );
end

return guild_view;