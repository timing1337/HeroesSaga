--- 章节弹出列表

local game_chapter_pop = {
    m_popUi = nil,
    m_fromUi = nil,
    m_callBackFunc = nil,
    m_list_view_bg = nil,
    m_chapterTypeName = nil,
    m_title_label = nil,
};
--[[--
    销毁
]]
function game_chapter_pop.destroy(self)
    -- body
    cclog("-----------------game_chapter_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_fromUi = nil;
    self.m_callBackFunc = nil;
    self.m_list_view_bg = nil;
    self.m_chapterTypeName = nil;
    self.m_title_label = nil;
end
--[[--
    返回
]]
function game_chapter_pop.back(self,type)
 --    if self.m_popUi then
 --        self.m_popUi:removeFromParentAndCleanup(true);
 --        self.m_popUi = nil;
 --    end
	-- self:destroy();
    game_scene:removePopByName("game_chapter_pop");
end
--[[--
    读取ccbi创建ui
]]
function game_chapter_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        if btnTag == 1 then--关闭
            self:back();
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_game_chapter_pop.ccbi");
    local m_root_layer = ccbNode:layerForName("m_root_layer")
    local m_close_btn = ccbNode:controlButtonForName("m_close_btn")
    self.m_title_label = ccbNode:labelTTFForName("m_title_label")
    self.m_list_view_bg = ccbNode:layerForName("m_list_view_bg")
    m_close_btn:setTouchPriority(GLOBAL_TOUCH_PRIORITY - 1);
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true;--intercept event
        end
    end
    m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    m_root_layer:setTouchEnabled(true);
    return ccbNode;
end

--[[--
    创建章节列表
]]
function game_chapter_pop.createChapterTableView(self,viewSize)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ccbResources/ui_city_banner_res.plist");
    local chapter = getConfig(game_config_field.chapter);
    local middle_map_count = chapter:getNodeCount();
    local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
    local normalTab = game_data:getChapterTabByKey(self.m_chapterTypeName);
    local params = {};
    params.viewSize = viewSize;
    params.row = 2;--行
    params.column = 3; --列
    params.totalItem = #normalTab;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY;
    params.itemActionFlag = false;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            -- cclog("new index ================================" .. index);
            cell = CCTableViewCell:new()
            cell:autorelease()
            local spriteLand = CCSprite:createWithSpriteFrameName("actAiqinhaizhimi.png")
            spriteLand:ignoreAnchorPointForPosition(false);
            spriteLand:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(spriteLand,1,1)
            local lockMask = CCSprite:createWithSpriteFrameName("sjdt_lock_img.png")
            lockMask:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(lockMask,2,2)
            local temp9Sprite = CCScale9Sprite:createWithSpriteFrameName("public_numBg.png")
            temp9Sprite:ignoreAnchorPointForPosition(false);
            temp9Sprite:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            temp9Sprite:setPreferredSize(CCSizeMake(100, 20));
            -- temp9Sprite:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(temp9Sprite,3,3);
            local msgLabel = game_util:createLabel({text = "",lableType = "ttf",color = ccc3(0,255,0),fontSize = 14})
            msgLabel:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            -- msgLabel:setColor(ccc3(200,120,0));
            cell:addChild(msgLabel,10,10);
        end
        local itemCfg = chapter:getNodeWithKey(normalTab[index+1])
        if cell and itemCfg then
            local spriteLand = tolua.cast(cell:getChildByTag(1),"CCSprite"); 
            local lockMask = tolua.cast(cell:getChildByTag(2),"CCSprite"); 
            local temp9Sprite = tolua.cast(cell:getChildByTag(3),"CCScale9Sprite"); 
            local tempLabel = tolua.cast(cell:getChildByTag(10),"CCLabelTTF");
            local open_level = itemCfg:getNodeWithKey("open_level"):toInt();
            local chapter_name = itemCfg:getNodeWithKey("chapter_name"):toStr();
            if playerLevel >= open_level then--开启
                -- spriteLand:setColor(ccc3(255,255,255));
                lockMask:setVisible(false);
                -- temp9Sprite:setVisible(false);
                tempLabel:setString(chapter_name);
            else
                -- spriteLand:setColor(ccc3(54,54,54));
                lockMask:setVisible(true);
                -- temp9Sprite:setVisible(true);
                -- tempLabel:setString(chapter_name .. "\n" .. open_level .. "级解锁")
                tempLabel:setString(open_level .. string_helper.game_chapter_pop.openLevel)
            end
            local banner = itemCfg:getNodeWithKey("banner");
            if banner then
                banner = game_util:getResName(banner:toStr());
                local tempSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(banner .. ".png");
                if tempSpriteFrame then
                    spriteLand:setDisplayFrame(tempSpriteFrame);
                end
            end
        end
        cell:setTag(index);
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            -- cclog("eventType = " .. eventType .. ";index = " .. index .. " ;  item = " .. tolua.type(item));
            local itemCfg = chapter:getNodeAt(index)
            local open_level = itemCfg:getNodeWithKey("open_level"):toInt();
            if self.m_callBackFunc and type(self.m_callBackFunc) == "function" and playerLevel >= open_level then
                self.m_callBackFunc(itemCfg:getKey());
                self:back();
            end
        end
    end
    return TableViewHelper:createGallery3(params);
end

--[[--
    刷新ui
]]
function game_chapter_pop.refreshUi(self)
    self.m_list_view_bg:removeAllChildrenWithCleanup(true);
    local tableViewTemp = self:createChapterTableView(self.m_list_view_bg:getContentSize());
    self.m_list_view_bg:addChild(tableViewTemp);
    if self.m_chapterTypeName == "normal" then
        self.m_title_label:setString(string_config.m_normal_chapter);
    elseif self.m_chapterTypeName == "difficult" then
        self.m_title_label:setString(string_config.m_difficult_chapter);
    end
end

--[[--
    初始化
]]
function game_chapter_pop.init(self,t_params)
    t_params = t_params or {};
    -- body
    self.m_fromUi = t_params.fromUi;
    self.m_callBackFunc = t_params.callBackFunc;
    self.m_chapterTypeName = t_params.chapterTypeName or "normal";
end

--[[--
    创建ui入口并初始化数据
]]
function game_chapter_pop.create(self,t_params)
    -- if self.m_popUi then return end
    self:init(t_params);
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

return game_chapter_pop;