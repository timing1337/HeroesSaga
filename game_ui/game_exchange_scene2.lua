local game_exchange_scnen2 = 
{
	m_list_view_bg = nil,
	m_tableView = nil,
	m_curPage = nil,
	m_tGameData = nil,
	CCNodeq = nil ,
	m_points_layer = nil,
	m_showExchangeIdTab = nil,
	m_ccnode =nil ,
	lbtitlename = nil ,
	typeid = nil ,
	m_testTab = {}
};

function game_exchange_scnen2:destroy()
	cclog("-----------------game_exchange_scnen2 destroy------------------------------");
	self.m_list_view_bg = nil;
	self.m_tableView = nil ;
	self.m_curPage = nil ;
	self.m_tGameData = nil;
	self.CCNodeq = nil ;
	self.m_points_layer = nil;
	self.m_showExchangeIdTab = nil;
	self.m_ccnode =nil ;
	self.lbtitlename = nil ;
	self.typeid = nil ;
end

function game_exchange_scnen2:back(backType)
        local function endCallFunc()
            self:destroy();
        end
        game_scene:enterGameUi("game_main_scene",{gameData = nil},{endCallFunc = endCallFunc});
end

--[[--
	
]]

function game_exchange_scnen2:createUi()
	local size = CCDirector:sharedDirector():getWinSize();
	local ccbNode = luaCCBNode:create();
	local function onMainBtnClick( target,event)
		local tagNode = tolua.cast(target,"CCControlButton");
		local btnTag = tagNode:getTag();
		if btnTag == 1 then
			self:back()
		end
	end
	ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);
	ccbNode:openCCBFile("ccb/game_exchange_pop.ccbi");
	self.m_list_view_bg = tolua.cast(ccbNode:objectForName("m_list_view_bg"), "CCLayerColor");
	local m_root_layer = tolua.cast(ccbNode:objectForName("m_root_layer"), "CCLayer");
	self.lbtitlename = ccbNode:labelBMFontForName("lbtitlename");
    self.lbtitlename:setVisible(false) ;
	-- local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
	-- m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
	-- local function onTouch(eventType, x, y)
 --        if eventType == "began" then
 --            return true;--intercept event
 --        end
 --    end
 --    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
 --    m_root_layer:setTouchEnabled(true);
 	self.CCNodeq = ccbNode;
	return ccbNode;
	
end

function game_exchange_scnen2:createTableView(viewSize)
	-- local lastcount =  {};
	-- local function responseMethod(tag,gameData)
 --        gameData = gameData:getNodeWithKey("data");
 --        lastcount = gameData:getNodeWithKey("exchange_log");
 --        cclog("selectliwen = " .. lastcount:getFormatBuffer());
 --    end
 --    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("omni_exchange_lastcount"), http_request_method.GET, nil,"omni_exchange_lastcount")
	


	lastcount = self.m_tGameData.exchange_log;
	cclog("lastcount== " .. json.encode(lastcount));

	self.m_showExchangeIdTab = {};
	local server_time = game_data:getUserStatusDataByKey("server_time")
	local timedatetext = "14.07-14.20" ;
	local exchangcount = 1 ;
	local exchangestate = 1 ;
	--判断是兑换活动还是万物兑换 1表示兑换活动 0 表示万物兑换
	local omni_exchange_cfg  = getConfig(game_config_field.omni_exchange); 
	-- if self.typeid == 1 then
	-- 	omni_exchange_cfg = getConfig(game_config_field.omni_exchange);
	-- end
	if omni_exchange_cfg  then
		local tempCount = omni_exchange_cfg:getNodeCount();
		for i=1,tempCount do
			local itemCfg = omni_exchange_cfg:getNodeAt(i - 1)
			local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
			local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
			end_time = end_time == "" and "0" or end_time
			local exchange_time =  itemCfg:getNodeWithKey("exchange_time"):toInt();
			exchangestate = itemCfg:getNodeWithKey("exchange_type"):toInt();
			exchangcount = itemCfg:getNodeWithKey("exchange_num"):toInt();
			if self.typeid == itemCfg:getNodeWithKey("type"):toInt() then
				if exchangestate == 0 then
					if exchange_time == 0 then
						table.insert(self.m_showExchangeIdTab,itemCfg:getKey())
					else
						print( tonumber(end_time), "   ", server_time, "  end_time", end_time)
						-- end_time = os.date("*t", end_time)
						-- -- end_time = os.time(end_time) 
						-- cclog("end_time11 = ", end_time)
						if tonumber(end_time) > server_time and  tonumber(start_time) < server_time then
							table.insert(self.m_showExchangeIdTab,itemCfg:getKey());
						end
					end
				else
					 if exchangcount > 0 then
					 	local show_idcount = itemCfg:getNodeWithKey("show_id"):toStr();
                        local owncountnum = lastcount[show_idcount] or 0;
                        local tempOwnCount = exchangcount  - owncountnum ;
                        if tempOwnCount > 0 then
                            if exchange_time == 0 then
                                table.insert(self.m_showExchangeIdTab,itemCfg:getKey())
                            else
                                if tonumber(end_time) > server_time  and  tonumber(start_time) < server_time then
                                    table.insert(self.m_showExchangeIdTab,itemCfg:getKey());
                                end
                            end
                        end
                    end
				end
			end
		end

		local function onCellBtnClick( target,event )
	        local tagNode = tolua.cast(target, "CCControlButton");
	        local btnTag =  tagNode:getTag();
	        local index = btnTag ; --math.floor(btnTag / 1000);
	        --local indexRew = math.floor(btnTag % 1000);
			local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
			local sendmesage = {};
			sendmesage.id = index + 1 ;
			local card = {} ;
			local equip = {} ;
			if itemCfg then
				local need_item = itemCfg:getNodeWithKey("need_item")
				local need_item_count = need_item:getNodeCount();
				local stepleve1 = itemCfg:getNodeWithKey("step"):toInt();
				local breakleve1 = itemCfg:getNodeWithKey("break"):toInt();
				for i=1,need_item_count do
					local itemCfgData = json.decode(need_item:getNodeAt(i-1):getFormatBuffer())
					if itemCfgData[1] == 7 then
						stepleve1 = itemCfg:getNodeWithKey("strengthen"):toInt();
						breakleve1 = itemCfg:getNodeWithKey("equip_st"):toInt();
					end
					local senddatalist,ownCount = game_data:getMetalByTable(itemCfgData,stepleve1,breakleve1);
					local icon,name,count,rewardType = game_util:getRewardByItemTable(itemCfgData,true);
					local typeValue = itemCfgData[1];
					cclog("index==" .. index  .. "typeValue==" .. typeValue .. "count==" .. count .. "typeValue== " .. tostring(itemCfgData[2]))
					if typeValue == 5 then
						if count > 0 then
							for i=1,count do
								table.insert(card,senddatalist[i])
								cclog("senddatalist[i] == " .. json.encode(senddatalist[i]))
							end
						end
					elseif typeValue == 7 then
						if count > 0 then
							for i=1,count do
								table.insert(equip,senddatalist[i])
								cclog("equip[i] == " .. json.encode(senddatalist[i]))
							end
						end
					end
					
				end	
				sendmesage.card = card ;
	      		sendmesage.equip = equip ;
				senddata = json.encode(sendmesage);
				cclog("senddata" .. tostring(senddata));
		        local params = "";
		        table.foreach(card,function(k,v)
		            params = params .. "card=" .. v .. "&";
		        end)
		        table.foreach(equip,function(k,v)
		            params = params .. "equip=" .. v .. "&";
		        end)
		        -------添加提示
                local cardTipsFlag = false
                local equipTipsFlag = false
                for k,v in pairs(card) do
                    local cardId = v
                    local cardData,heroCfg = game_data:getCardDataById(cardId)
                    local cardLevel = cardData.lv
                    local evo = cardData.evo
                    if cardLevel > 10 or evo > 0 then--提示高级卡牌
                        cardTipsFlag = true
                    end
                end
                for k,v in pairs(equip) do
                    local equipId = v
                    local equipData,equipCfg = game_data:getEquipDataById(equipId)
                    local equipLv = equipData.lv
                    local st_lv = equipData.st_lv
                    if equipLv > 10 or st_lv > 5 then--提示高级装备
                        equipTipsFlag = true
                    end
                end
                --兑换的接口
                local function exchageItem()
                    local id = itemCfg:getNodeWithKey("show_id"):toInt(); 
                    params = params .. "id=" .. id ;
                    local function responseMethod(tag,gameData)
                        local data = gameData:getNodeWithKey("data");
                        self.exchangeData = json.decode(data:getFormatBuffer());
                        game_util:rewardTipsByJsonData(gameData:getNodeWithKey("data"):getNodeWithKey("reward"));
                        self:refreshUi()
                    end
                    network.sendHttpRequest(responseMethod,game_url.getUrlForKey("omni_exchange"), http_request_method.GET, params,"omni_exchange")
                end
                if cardTipsFlag == true then
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            exchageItem()
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string_helper.game_exchange_scnen2.text,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                elseif equipTipsFlag == true then
                    local t_params = 
                    {
                        title = string_config.m_title_prompt,
                        okBtnCallBack = function(target,event)
                            game_util:closeAlertView();
                            exchageItem()
                        end,   --可缺省
                        okBtnText = string_config.m_btn_sure,       --可缺省
                        cancelBtnText = string_config.m_btn_cancel,
                        text = string_helper.game_exchange_scnen2.text2,      --可缺省
                        onlyOneBtn = false,
                        touchPriority = GLOBAL_TOUCH_PRIORITY-2,
                    }
                    game_util:openAlertView(t_params)
                else
                    exchageItem()
                end
            end
    	end
		local function onBtnCilck( event,target )
	        local tagNode = tolua.cast(target, "CCNode");
	        local btnTag = tagNode:getTag();
	        -- cclog("btnTag == " .. btnTag)

	        local index = math.floor(btnTag / 1000)
	        local indexRew = math.floor(btnTag % 1000)

			local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
			if itemCfg then
				local need_item = itemCfg:getNodeWithKey("need_item")
				local need_item_count = need_item:getNodeCount();
				local senddata = nil ;
				local stepleve1 = itemCfg:getNodeWithKey("step"):toInt();
				local breakleve1 = itemCfg:getNodeWithKey("break"):toInt();
				if indexRew > need_item_count then
					local numid = indexRew - need_item_count;
					senddata = json.decode(itemCfg:getNodeWithKey("out_item" .. numid):getFormatBuffer());
					game_util:lookItemDetal(senddata[1])

				else
					senddata = json.decode(need_item:getNodeAt(indexRew-1):getFormatBuffer());
					if senddata[1] == 7 then
						stepleve1 = itemCfg:getNodeWithKey("strengthen"):toInt();
						breakleve1 = itemCfg:getNodeWithKey("equip_st"):toInt();
					end
					game_scene:addPop("game_exchange_showitemsneed_pop",{gameData = senddata,type_id = 0,stepleve = stepleve1 ,breakleve = breakleve1});
				end

				--cclog2("liwenxue indexRew==" .. tostring() indexRew);
				-- local need_item = itemCfg:getNodeWithKey("need_item");
				-- cclog2( need_item and need_item:getNodeAt(indexRew - 1), "reward ===== ");
			end
	    end
	    local function onBtnrandomCilck( event,target )
	        local tagNode = tolua.cast(target, "CCNode");
	        local btnTag = tagNode:getTag();
	        -- cclog("btnTag == " .. btnTag)

	        local index = math.floor(btnTag / 1000)
	        local indexRew = math.floor(btnTag % 1000)
			local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index + 1]);
			if itemCfg then
				local need_item = itemCfg:getNodeWithKey("need_item");
				-- local need_item_count = need_item:getNodeCount();
				local numid = indexRew ;

				local senddata = json.decode(itemCfg:getNodeWithKey("out_item" .. numid):getFormatBuffer());
				-- cclog2( senddata , "reward ===== ");
	        	game_scene:addPop("game_exchange_showitems_pop",senddata);
			end
	    end

    	local allcount = #self.m_showExchangeIdTab
    	if allcount < 1 then
    		self.lbtitlename:setVisible(true) ;
    	end
		local params = {};
		params.viewSize = viewSize;
		params.row = 3 ;
		params.column = 1 ;
		params.totalItem = allcount;
		params.touchPriority = GLOBAL_TOUCH_PRIORITY + 1;
		params.showPageIndex = self.m_curPage;
		params.itemActionFlag = false;
		--params.direction = kCCScrollViewDirectionVertical;
		local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
		params.newCell =function( tableView,index )
			local cell = tableView:dequeueCell();
			if cell == nil then
				cell = CCTableViewCell:new();
				cell:autorelease();
				local ccbNode = luaCCBNode:create();
				ccbNode:registerFunctionWithFuncName("onCellBtnClick",onCellBtnClick);
				ccbNode:openCCBFile("ccb/game_ui_exchange_item.ccbi");
				self.m_points_layer = ccbNode:layerForName("m_points_layer"); 
				self.m_ccnode = ccbNode:nodeForName("m_ccnode"); 
				-- self:initLayerTouch(self.m_points_layer);
				ccbNode:setAnchorPoint(ccp(0.5,0.5));
				ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5))
				cell:addChild(ccbNode,20,20)
			end
			if cell then
				local ccbNode = tolua.cast(cell:getChildByTag(20),"luaCCBNode");
				local stime = ccbNode:spriteForName("stime");
				local scount = ccbNode:spriteForName("scount");
				local sarrow = ccbNode:spriteForName("sarrow");
				local tbndh = ccbNode:controlButtonForName("btnexchange");
				tbndh:setTag(index);
	            local lbtime = ccbNode:labelTTFForName("lbtime");
	            local lbcount = ccbNode:labelTTFForName("lbcount");
	            local m_ccnodeitem = ccbNode:nodeForName("m_ccnode"); 

	          
	            
				--local itemData = self.
				--tbndh:setTouchEnabled(false);
				--加载动画
				-- game_util:addTipsAnimByType(tbndh,2);
				-- game_util:addTipsAnimByType(spriteName1,2);
				-- game_util:addTipsAnimByType(lbname1,2);
				local itemCfg = omni_exchange_cfg:getNodeWithKey(self.m_showExchangeIdTab[index+1]);
				local cellnumcount = 0 ;
				--取出需要的物品
				-- local exchange_type = itemCfg:getNodeWithKey("exchange_type"):toStr();
				-- local exchange_num = itemCfg:getNodeWithKey("exchange_num"):toStr();
				-- local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
				-- local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
				-- if exchange_type == 0 then
				-- 	lbcount:setVisible(false);
				-- 	lbtime:setVisible(false);
				-- 	scount:setVisible(false);
				-- 	stime:setVisible(false);
				-- else
				-- 	lbcount:setString(exchange_num);
				-- 	lbtime:setString(start_time);
				-- end
				cclog("index== " .. index);
				exchangestate = itemCfg:getNodeWithKey("exchange_type"):toInt();
				exchangcount = itemCfg:getNodeWithKey("exchange_num"):toInt();
	            exchange_time =  itemCfg:getNodeWithKey("exchange_time"):toInt();
	            local start_time = itemCfg:getNodeWithKey("start_time"):toStr();
				local end_time = itemCfg:getNodeWithKey("end_time"):toStr();
				end_time = end_time == "" and "0" or end_time
				local show_idcount = itemCfg:getNodeWithKey("show_id"):toStr();

				local server_left_time = 1
	            if exchangestate == 0 then
	            	scount:setVisible(false);
	            	lbcount:setVisible(false);
	            else
	            	scount:setVisible(true);
	            	lbcount:setVisible(true);
	            	cclog("show_idcount==" .. show_idcount)
	            	local owncountnum = lastcount[show_idcount] or 0;
	            	
	            	cclog("exchangcount==" .. exchangcount ..  "  owncountnum==" .. owncountnum)
	            	exchangcount = exchangcount  - owncountnum ;
	            	lbcount:setString(exchangcount);
	            end
	            if exchange_time == 0 then
	            	lbtime:setVisible(false);
	            	stime:setVisible(false);
	            	local pX,pY = stime:getPosition();
	            	scount:setPosition(ccp(pX + 15 ,pY));
	            	pX,pY = scount:getPosition();
	            	local tempSize = scount:getContentSize();
	            	lbcount:setPosition(ccp(pX + tempSize.width/2 + 5,pY));
	            	
	            else
	            	lbtime:setVisible(true);
	            	stime:setVisible(true);
	            	local dateTemp = os.date("*t", start_time)
					timedatetext = dateTemp.month .. "-" .. dateTemp.day .. " " .. dateTemp.hour .. ":" .. dateTemp.min ;
                    -- cclog(dateTemp.year, dateTemp.month, dateTemp.day, dateTemp.hour, dateTemp.min, dateTemp.sec);
                    dateTemp = os.date("*t", end_time)
                    timedatetext =  timedatetext .. " ~ " .. dateTemp.month .. "-" .. dateTemp.day .. " " .. dateTemp.hour .. ":" .. dateTemp.min ;
	            	lbtime:setString(timedatetext);
	            end
	            m_ccnodeitem:removeAllChildrenWithCleanup(true);
				local need_item = itemCfg:getNodeWithKey("need_item")
				local need_item_count = need_item:getNodeCount();
				local countNum = 1 ;
				cellnumcount = cellnumcount + need_item_count ;
				for i = cellnumcount + 1, 5 do
					local out_item = itemCfg:getNodeWithKey("out_item" .. countNum);
					if out_item and out_item:getNodeCount() > 0 then
						cellnumcount = i
						countNum = countNum + 1 ;
					end
				end

				local cellwidth = m_ccnodeitem:getContentSize();
				local jianju = cellwidth.width/(cellnumcount + 1);
				-- cclog("jianju == " .. tostring(jianju))
				local exwidth = jianju/2;
				local isall = 1 ;
				for i=1,need_item_count do
					local itemCfgData = json.decode(need_item:getNodeAt(i-1):getFormatBuffer())
					local stepleve = 0 ;
					local breakleve = 0 ;
					local ownCount = 0 ;
					local icon,name,count,rewardType = game_util:getRewardByItemTable(itemCfgData,true);
					if itemCfgData[1] == 5 then
						stepleve = itemCfg:getNodeWithKey("step"):toInt();
						breakleve = itemCfg:getNodeWithKey("break"):toInt();
						local _,ownCount1 = game_data:getMetalByTable(itemCfgData,stepleve,breakleve);
						-- cclog("ownCount1 == " .. ownCount1);
						ownCount = ownCount1 ;
						count = stepleve ;
					elseif  itemCfgData[1] ==  7 then
						-- cclog("index== "  .. index )

						stepleve = itemCfg:getNodeWithKey("strengthen"):toInt();
						breakleve = itemCfg:getNodeWithKey("equip_st"):toInt();
						-- cclog("stepleve == " .. stepleve .. "breakleve == " .. breakleve);
						local _,ownCount1 = game_data:getMetalByTable(itemCfgData,stepleve,breakleve);
						ownCount = ownCount1 ;
						count = stepleve ;
					else
						local _,ownCount1 = game_data:getMetalByTable(itemCfgData);
						ownCount = ownCount1 ;
					end
					
					

					
					if icon then
	                    if i ~= 1 then
	                    	local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_fuhao.png");
	                		bgSpr:setPosition(ccp(exwidth + jianju*(i - 1) - jianju/2, 35))
	                		m_ccnodeitem:addChild(bgSpr)
	                    end
	                    icon:setScale(0.70);
	                    icon:setPosition(ccp(exwidth + jianju*(i - 1), 35))
	                    m_ccnodeitem:addChild(icon)
	                    local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck)
	                    button:setAnchorPoint(ccp(0.5,0.5))
	                    button:setPosition(icon:getPosition())
	                    button:setOpacity(0)
	                    m_ccnodeitem:addChild(button)
	                    -- button:setScaleY(1.5)
	                    button:setTag(1000 * index + i)
	                    if ownCount < itemCfgData[3] then
	                    	icon:setColor(ccc3(71,71,71))
	                    	local bgSpri = tolua.cast(icon:getChildByTag(1),"CCSprite")
	                    	local bgSpri2 = tolua.cast(icon:getChildByTag(2),"CCSprite")
	                    	if bgSpri and bgSpri2 then
	                    		bgSpri:setColor(ccc3(71,71,71));
	                    		bgSpri2:setColor(ccc3(71,71,71));
	                    	end
	                    end
	                else
	                	cclog("----icon======" .. tostring(icon))
	                end
	                if ownCount < itemCfgData[3] then
	                	isall = 0 ;
	                end
	                if name then
	                	
	                    local showTempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
	                    showTempLabel:setPosition(ccp(exwidth + jianju*(i - 1),  7));
	                    m_ccnodeitem:addChild(showTempLabel);
	                    showTempLabel:setScale(0.7)
	                    -- breakleve = 3 
	                    -- stepleve = 3
	                    if breakleve > 0  and stepleve > 0 then
	                		local board = CCSprite:createWithSpriteFrameName("public_equip_star.png");
	                		board:setScale(0.5);
	                		board:setPosition(ccp(exwidth + jianju*(i - 1) + 8,  14));
	                		m_ccnodeitem:addChild(board);

	                		tempLabel = game_util:createLabelTTF({text = breakleve,color = ccc3(250,180,0),fontSize = 10});
		                    tempLabel:setPosition(ccp(exwidth + jianju*(i - 1),  14));
		                    m_ccnodeitem:addChild(tempLabel);
		                    tempLabel:setScale(0.7)

		                    stepleve = "+" .. stepleve ;
	                		tempLabel = game_util:createLabelTTF({text = stepleve,color = ccc3(250,180,0),fontSize = 10});
		                    tempLabel:setPosition(ccp(exwidth + jianju*(i - 1) - 10,  14));
		                    m_ccnodeitem:addChild(tempLabel);
		                    tempLabel:setScale(0.7)
		                elseif breakleve > 0 then 
		                	local board = CCSprite:createWithSpriteFrameName("public_equip_star.png");
	                		board:setScale(0.5);
	                		board:setPosition(ccp(exwidth + jianju*(i - 1) + 4,  14));
	                		m_ccnodeitem:addChild(board);

	                		tempLabel = game_util:createLabelTTF({text = breakleve,color = ccc3(250,180,0),fontSize = 10});
		                    tempLabel:setPosition(ccp(exwidth + jianju*(i - 1)-4,  14));
		                    m_ccnodeitem:addChild(tempLabel);
		                    tempLabel:setScale(0.7)
		                elseif stepleve > 0 then 
		                	stepleve = "+" .. stepleve ;
	                		tempLabel = game_util:createLabelTTF({text = stepleve,color = ccc3(250,180,0),fontSize = 10});
		                    tempLabel:setPosition(ccp(exwidth + jianju*(i - 1) ,  14));
		                    m_ccnodeitem:addChild(tempLabel);
		                    tempLabel:setScale(0.7)
		                else
		                	if showTempLabel then showTempLabel:setPosition(ccp(exwidth + jianju*(i - 1),  10)); end
	                	end
	                end
	                
				end
				tbndh:removeAllChildrenWithCleanup(true);
				if isall == 0 then
	                tbndh:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dhzx_enniu_2.png"),CCControlStateNormal);
	                tbndh:setColor(ccc3(71,71,71));
	                tbndh:setTouchEnabled(false);
	             else
	             	tbndh:setBackgroundSpriteFrameForState(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dhzx_enniu_1.png"),CCControlStateNormal);
	             	tbndh:setTouchEnabled(true);
	             	game_util:addTipsAnimByType(tbndh,2);
	             end
				--local isadd = 0 ; --判断是否需要添加“+”号 ，如果为0就不添加，否则就添加
				exwidth = need_item_count*jianju + jianju/3 ;
				sarrow:setPosition(ccp(exwidth, 35));
				exwidth = (need_item_count + 1)*jianju + jianju/3 ;
				local cou = cellnumcount - need_item_count

				for i=1,cou do
					local out_item = itemCfg:getNodeWithKey("out_item" .. i);
					-- cclog2(out_item, " ===  out_item")
					local rewCount = out_item:getNodeCount()
					if rewCount == 1 then
						local icon,name,count,rewardType = game_util:getRewardByItem(out_item:getNodeAt(0));
						if icon then
							icon:setScale(0.7);
							icon:setPosition(ccp(exwidth, 35));
	                    	m_ccnodeitem:addChild(icon);
	                    	if name then
	                    		if count then
	                    			name = name .. "  " ..  string.format("x %d", count) ;
	                    		end
		                    	local tempLabel = game_util:createLabelTTF({text = name,color = ccc3(250,180,0),fontSize = 10});
		                    	tempLabel:setPosition(ccp(exwidth,  10));
		                    	m_ccnodeitem:addChild(tempLabel);
			                    tempLabel:setScale(0.7)
		                    end
						else
							--setBackgroundSpriteFrameForState --设置图片
							-- local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_kongwei.png");
			    --         	bgSpr:setPosition(ccp(exwidth, 40))
			    --         	m_ccnodeitem:addChild(bgSpr)
							-- local bgSpr = CCSprite:createWithSpriteFrameName("tujian_kongwei.png");
							-- bgSpr:setPosition(ccp(exwidth, 40));
		     --            	m_ccnodeitem:addChild(bgSpr);
						end
						 local button = game_util:createCCControlButton("public_weapon.png","",onBtnCilck);
	                    button:setAnchorPoint(ccp(0.5,0.5));
	                    button:setPosition(icon:getPosition());
	                    button:setOpacity(0);
	                    m_ccnodeitem:addChild(button);
	                    -- button:setScaleY(1.5);
	                    button:setTag(1000 * index + i + need_item_count);
					else
						local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_kongwei.png");
	                	bgSpr:setPosition(ccp(exwidth, 35))
	                	bgSpr:setScale(0.7)
	                	m_ccnodeitem:addChild(bgSpr)
	                	-- if isall == 0  then
	                	-- 	bgSpr:setColor(ccc3(71,71,71))
	                	-- end
						-- local bgSpr = CCSprite:createWithSpriteFrameName("dhzx_kongwei.png");
						-- bgSpr:setPosition(ccp(exwidth, 40));
	     --            	m_ccnodeitem:addChild(bgSpr);
	     				local button = game_util:createCCControlButton("public_weapon.png","",onBtnrandomCilck)
	                    button:setAnchorPoint(ccp(0.5,0.5))
	                    button:setPosition(bgSpr:getPosition())
	                    button:setOpacity(0)
	                    m_ccnodeitem:addChild(button)
	                    -- button:setScaleY(1.5)
	                    button:setTag(1000 * index + i)

	                    local tempLabel = game_util:createLabelTTF({text = string_helper.game_exchange_scnen2.random_package,color = ccc3(250,180,0),fontSize = 10});
                        tempLabel:setPosition(ccp(exwidth,10));
                        m_ccnodeitem:addChild(tempLabel,10,10);
	                    tempLabel:setScale(0.7)
					end
	               	exwidth = exwidth + jianju ;
				end
			end
		return cell ;
		
		end
		params.itemOnClick = function( eventType,index,item )

		-- print(" eventType,index,item === ",  eventType,index,item )
		end
		params.pageChangedCallFunc = function( totalPage,curPage )
			self.m_curPage = curPage;
		-- body
		end
		return TableViewHelper:create(params);
	else
		self.lbtitlename:setVisible(true) ;
	end
	return nil;
end
local XPOINT = 0
local YPOINT = 0 ;
--在一个cell里添加触摸事件
function game_exchange_scnen2:initLayerTouch(formation_layer)
    local function onTouch(eventType, x, y)
      	if eventType == "began" then
         --    local  = self.m_reward_node:convertToNodeSpace(ccp(x,y));
        	-- for i = 1,5 do
         --    	tempItem = self.m_rewardNodeTab[i].reward_icon
         --    	if tempItem:boundingBox():containsPoint(realPos) and self.m_rewardNodeTab[i].tipsText then
         --         	game_scene:addPop("game_enemy_info_pop",{itemCfg = v.itemCfg,pos = ccp(x,y)})
         --    	end
         --    end
         XPOINT = x ;
         YPOINT = y ;
         print("------------cell-------x=" .. tostring(x) .. "----y=" .. tostring(y) )
        end
       
    	return false;
    end
    formation_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY + 2,true)
    formation_layer:setTouchEnabled(true)
end
function game_exchange_scnen2:refreshUi()
	local pX,pY;
    if self.m_tableView then
        pX,pY = self.m_tableView:getContainer():getPosition();
    end
	self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    self.m_tableView = self:createTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(self.m_tableView,33,33);
    if pX and pY then
        self.m_tableView:setContentOffset(ccp(pX,pY), false);
    end
end	

--[[

]]
function game_exchange_scnen2:init(t_params)
	t_params = t_params or {};
	self.typeid = t_params.typeid or 1 ;
	if t_params.gameData ~= nil and tolua.type(t_params.gameData) == "util_json" then
		local data = t_params.gameData:getNodeWithKey("data");
		self.m_tGameData = json.decode(data:getFormatBuffer());
	end

end
function game_exchange_scnen2:create(t_params)
	self:init(t_params);
	local scene = CCScene:create();
	scene:addChild(self:createUi());
	self:refreshUi();
	return scene;
end
return game_exchange_scnen2;