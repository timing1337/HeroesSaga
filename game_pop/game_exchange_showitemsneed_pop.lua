---  ui模版

local game_exchange_showitemsneed_pop = {
    m_root_layer = nil,
    m_sprite9_showboard = nil,
    m_node_itemsbg = nil,

    m_curPage = nil,
    t_rewards = nil,

    m_flag = nil,
    t_params = nil ,
    type_id = nil,
    m_gameData = nil,
    m_ownMaterialData = nil,
    m_ownMaterialConut = nil,
    lbtitlename = nil ,
    stepleve = nil ,
    breakleve =nil ,
    material_type = nil,
};
--[[--
    销毁ui
]]
function game_exchange_showitemsneed_pop.destroy(self)
    -- body
    self.m_root_layer = nil;
    self.m_sprite9_showboard = nil;
    self.m_node_itemsbg = nil;

    self.m_curPage = nil;
    self.t_rewards = nil;

    self.m_flag = nil;
    self.t_params = nil ;
    self.type_id = nil;
    self.m_gameData = nil;
    self.m_ownMaterialData = nil;
    self.m_ownMaterialConut = nil;
    self.lbtitlename = nil ;
    self.stepleve = nil ;
    self.breakleve =nil ;
    self.material_type = nil;
end
--[[--
    返回
]]
function game_exchange_showitemsneed_pop.back(self,backType)
    game_scene:removePopByName("game_exchange_showitemsneed_pop");
    self:destroy()
end
--[[--
    读取ccbi创建ui
]]
function game_exchange_showitemsneed_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCControlButton");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then -- 关闭
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick", onBtnClick);
    ccbNode:openCCBFile("ccb/game_exchange_showitemneed.ccbi")
    self.m_node_itemsbg = ccbNode:nodeForName("m_node_itemsbg")
    self.lbtitlename = ccbNode:labelBMFontForName("lbtitlename");
    self.lbtitlename:setVisible(false) ;
    -- 本层阻止触摸传导下一层
    local function onTouch(eventType, x, y)
        local rect = self.m_node_itemsbg:boundingBox()
        -- print_rect(rect, "rect is " )

        local flag = false
        if x >= rect.origin.x and x <= rect.origin.x + rect.size.width
            and y >= rect.origin.y and y <= rect.origin.y + rect.size.height then
            flag = true
        end

        if eventType == "began" then
            self.m_flag = not flag
            return true;--intercept event
        elseif eventType == "ended" and not flag and self.m_flag then
            self:back()
            return true
        elseif eventType == "ended" then
            self.m_flag = nil
        end 
    end
    self.m_root_layer = ccbNode:layerForName("m_root_layer")
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY - 3,true);
    self.m_root_layer:setTouchEnabled(true);
    -- -- 重置按钮出米优先级 防止被阻止
    self.m_close_btn = ccbNode:controlButtonForName("m_close_btn");
    self.m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 4);

    return ccbNode;
end

--[[--
    刷新ui
]]
function game_exchange_showitemsneed_pop.refreshUi(self)
    self.m_node_itemsbg:removeAllChildrenWithCleanup( true )
    local tableview = self:createItemsTabelViewByTypeID( self.m_node_itemsbg:getContentSize())
    if tableview == nil then return end
    tableview:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1 );
    self.m_node_itemsbg:addChild(tableview)

end
--[[--
    初始化
]]
function game_exchange_showitemsneed_pop.init(self,t_params)
    t_params = t_params or {};
    self.type_id = t_params.type_id;
    self.stepleve = t_params.stepleve;
    self.breakleve = t_params.breakleve;
    self.material_type = t_params.material_type;
    if self.type_id == 1 then
        self.m_gameData = t_params.gameData[1];
    else 
        self.m_gameData = t_params.gameData ;
    end

    cclog("self.stepleve ======== " .. self.stepleve .. "self.breakleve ======== " .. self.breakleve)
    self.m_ownMaterialData,self.m_ownMaterialConut = game_data:getMetalByTable(self.m_gameData,self.stepleve,self.breakleve,self.material_type);
    cclog("self.m_ownMaterialConut ======== ".. self.m_ownMaterialConut)
end

function game_exchange_showitemsneed_pop.createItemsTabelViewByTypeID(self, viewSize)
    local gameData = self.m_gameData or {};
    cclog("gameData ======== ".. json.encode(gameData))
    local typeid = gameData[1] or 1 ;
    local needcount = gameData[3] or 0 ;
    local totalItem = 1 ;

    if typeid == 5 or typeid == 7 then
        totalItem = gameData[3] or 0
    end
    local rowcount = 1 ;
    local columncount = 1 ;
    if totalItem > 4 then
        rowcount = 2 ;
        columncount = 4 ;
    else 
        columncount = totalItem ;
    end
    local itemSize = CCSizeMake( viewSize.width/columncount, viewSize.height/rowcount);
    local imgheight = itemSize.height*0.6 ;
    local nameheight = itemSize.height*0.3 ; --控制英雄名称的高度
    local leveltextheight = itemSize.height*0.4 ; --控制英雄等级的高度
    local blabelNameheight = itemSize.height*0.55 ; --控制装备所属英雄名称的高度
    if rowcount > 1 then
        imgheight = itemSize.height*0.65 ;
        nameheight = itemSize.height*0.2 ;
        leveltextheight = itemSize.height*0.35 ;
        blabelNameheight = itemSize.height*0.56 ;
    end
    if needcount > self.m_ownMaterialConut then --添加标题说明
        self.lbtitlename:setVisible(true) ;
    end
    local params = {};
    params.viewSize = viewSize;
    params.row = rowcount; -- 行
    params.column = columncount; -- 列
    params.totalItem = totalItem  -- 数量
    params.direction = kCCScrollViewDirectionVertical;
    params.showPageIndex = self.m_curPage; -- 分页
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-3;
    
    params.newCell = function ( tableView, index )
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog(" new index ===================  " .. index)
            cell = CCTableViewCell:new()
            cell:autorelease()
        -- body  local itemData,itemCfg = game_data:getEquipDataById(tempId);
        end
        if cell then  -- 更新cell的内容
            cell:removeAllChildrenWithCleanup(true)
            if typeid == 5  then
                local leveltext = nil ;
                local icon,name,count,rewardType = game_util:getRewardByItemTable(gameData);
                if icon then
                    icon:setPosition(ccp(itemSize.width*0.5,imgheight))
                    if (index + 1) > self.m_ownMaterialConut then
                        if self.m_ownMaterialConut ~= nil and self.m_ownMaterialConut > 0 then
                            -- local cardid = self.m_ownMaterialData[1] ;
                            -- local itemData1,configex= game_data:getCardDataById(cardid);
                            -- leveltext = "Lv." .. tostring(itemData1.lv) .. "/" .. tostring(itemData1.level_max) ;
                        -- else
                        --     local character_detail_cfg = getConfig(game_config_field.character_detail);
                        --     local itemCfg = character_detail_cfg:getNodeWithKey(tostring(gameData[2]));
                        --     leveltext = "Lv.1/" .. itemCfg:getNodeWithKey("level_max"):toInt();
                        end
                        icon:setColor(ccc3(71,71,71))
                        local bgSpri = tolua.cast(icon:getChildByTag(1),"CCSprite")
                        local bgSpri2 = tolua.cast(icon:getChildByTag(2),"CCSprite")
                        if bgSpri and bgSpri2 then
                            bgSpri:setColor(ccc3(71,71,71));
                            bgSpri2:setColor(ccc3(71,71,71));
                        end
                    else
                        if self.m_ownMaterialConut ~= nil and self.m_ownMaterialConut > 0 then
                            -- cclog("m_ownMaterialConut=" .. tostring(self.m_ownMaterialConut) .. "index==" .. tostring(index));
                            local cardid = self.m_ownMaterialData[index + 1] ;
                            --cclog("cardid===" .. tostring(cardid));
                            local itemData1,configex= game_data:getCardDataById(cardid);
                            -- cclog("itemData1==" .. json.encode(itemData1))
                            -- leveltext = "Lv." .. tostring(itemData1.lv) .. "/" .. tostring(itemData1.level_max) ;
                            leveltext = "Lv." .. tostring(itemData1.lv)-- .. "/" .. tostring(itemData1.level_max) ;
                            name = game_util:getCardName(itemData1,configex);
                        end
                        
                        -- 发光
                        local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                        --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                        if board then
                            board:setPosition(ccp(itemSize.width*0.5,imgheight))
                            cell:addChild(board)
                        end
                    end
                    if  name then
                        local blabelName = game_util:createLabelTTF({text = tostring(name)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(itemSize.width * 0.5,nameheight)
                        cell:addChild(blabelName,8)
                    end
                    if  leveltext then
                        local blabelName = game_util:createLabelTTF({text = tostring(leveltext)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(itemSize.width * 0.5, leveltextheight)
                        cell:addChild(blabelName,3)
                    end
                    cell:addChild(icon)
                end
            elseif typeid == 7 then
                local leveltext = nil ;
                local  stleve = nil ;
                local icon,name,count,rewardType = game_util:getRewardByItemTable(gameData);
                if icon then
                    icon:setPosition(ccp(itemSize.width*0.5,imgheight))
                    if (index + 1) > self.m_ownMaterialConut then
                        if self.m_ownMaterialConut ~= nil and self.m_ownMaterialConut > 0 then
                            local cardid = self.m_ownMaterialData[1] ;
                            local itemData1,configex= game_data:getEquipDataById(cardid);
                            name = name .. "+" .. tostring(itemData1.lv) ;
                        else
                            name = name .. "+1" ;
                        end
                        icon:setColor(ccc3(71,71,71))
                        local bgSpri = tolua.cast(icon:getChildByTag(1),"CCSprite")
                        local bgSpri2 = tolua.cast(icon:getChildByTag(2),"CCSprite")
                        if bgSpri and bgSpri2 then
                            bgSpri:setColor(ccc3(71,71,71));
                            bgSpri2:setColor(ccc3(71,71,71));
                        end
                    else
                        if self.m_ownMaterialConut ~= nil and self.m_ownMaterialConut > 0 then
                            local cardid = self.m_ownMaterialData[1] ;
                            local itemData1,configex= game_data:getEquipDataById(cardid);
                            name = name .. "+" .. tostring(itemData1.lv) ;
                            local existFlag,cardName = game_data:equipInEquipPos(configex:getNodeWithKey("sort"):toInt(),itemData1.id)
                            stleve = itemData1.st_lv;
                            if existFlag then
                                leveltext = cardName ;
                            end
                        end
                        
                        -- 发光
                        local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                        --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                        if board then
                            board:setPosition(ccp(itemSize.width*0.5,imgheight))
                            cell:addChild(board)
                        end
                    end
                    if  name then
                        local blabelName = game_util:createLabelTTF({text = tostring(name)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(itemSize.width * 0.5,  nameheight)
                        cell:addChild(blabelName,2)
                    end
                    if  leveltext then
                        local blabelName = game_util:createLabelTTF({text = tostring(leveltext),color = ccc3(255,255,0)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(itemSize.width * 0.5,  blabelNameheight)
                        cell:addChild(blabelName,3)
                    end
                    --装备星级
                    if  stleve and stleve > 0  then
                        --local  x1,y1 = icon:getPosition();
                        local board = CCSprite:createWithSpriteFrameName("public_equip_star.png");
                        --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                        local blabelName = game_util:createLabelTTF({text = tostring(stleve),color = ccc3(255,255,0)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))

                        blabelName:setPosition(itemSize.width * 0.47,  itemSize.height*0.73)
                        board:setPosition(ccp(itemSize.width*0.44,itemSize.height*0.71))
                        if rowcount > 1 then
                            board:setPosition(ccp(itemSize.width*0.24,itemSize.height*0.86))
                            blabelName:setPosition(itemSize.width * 0.36,  itemSize.height*0.91)
                        end
                        cell:addChild(board,3)
                        cell:addChild(blabelName,5)
                    end
                    cell:addChild(icon)
                end
            else
                local icon,name,count,rewardType = game_util:getRewardByItemTable(gameData);
                if icon then
                    icon:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.65))

                    if  name then
                        local blabelName = game_util:createLabelTTF({text = tostring(name)})
                        blabelName:setAnchorPoint(ccp(0.5, 1))
                        blabelName:setPosition(itemSize.width * 0.5,  itemSize.height*0.35)
                        cell:addChild(blabelName)
                    end
                    local strownorneed = 0 ;
                    if self.type_id == 1 then
                        strownorneed = tostring(needcount);
                    else
                        strownorneed = tostring(self.m_ownMaterialConut) .. "/" ..  tostring(needcount);
                    end
                     
                     if  strownorneed then
                        local blabelName = game_util:createLabelTTF({text = tostring(strownorneed)}) ;
                        blabelName:setAnchorPoint(ccp(0.5, 1));
                        blabelName:setPosition(itemSize.width * 0.5,  itemSize.height*0.45);
                        cell:addChild(blabelName,3);
                    end

                    if needcount > self.m_ownMaterialConut then
                        icon:setColor(ccc3(71,71,71))
                        local bgSpri = tolua.cast(icon:getChildByTag(1),"CCSprite")
                        local bgSpri2 = tolua.cast(icon:getChildByTag(2),"CCSprite")    
                        if bgSpri and bgSpri2 then
                            bgSpri:setColor(ccc3(71,71,71));
                            bgSpri2:setColor(ccc3(71,71,71));
                        end
                    else
                        -- 发光
                        local board = CCSprite:createWithSpriteFrameName("public_faguang.png");
                        --board = CCSprite:createWithSpriteFrameName("public_faguang_2.png");
                        if board then
                            board:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.65))
                            cell:addChild(board,2)
                        end
                    end
                    cell:addChild(icon)
                end
            end
            
        end
        return cell
    end
    params.itemOnClick = function ( eventType, index, item )
    
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        self.m_curPage = curPage;
    end
    return TableViewHelper:create(params);
end


--[[--
    创建ui入口并初始化数据
]]
function game_exchange_showitemsneed_pop.create(self,t_params)

            -- print(" start in opening -- 1")
    self:init(t_params);

    local scene = CCScene:create();
    scene:addChild(self:createUi());
    self:refreshUi();
    return scene;
end

return game_exchange_showitemsneed_pop;
