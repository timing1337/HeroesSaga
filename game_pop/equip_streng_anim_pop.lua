--- 装备一键强化动画
local equip_streng_anim_pop = {
    m_popUi = nil,
    m_tParams = nil,
    m_root_layer = nil,

    table_node = nil,
    equipData = nil,
    onrush_flag = nil,
};
--[[--
    销毁
]]
function equip_streng_anim_pop.destroy(self)
    -- body
    cclog("-----------------equip_streng_anim_pop destroy-----------------");
    self.m_popUi = nil;
    self.m_tParams = nil;
    self.m_root_layer = nil;

    self.table_node = nil;
    self.equipData = nil;
    self.onrush_flag = nil;
end
--[[--
    返回
]]
function equip_streng_anim_pop.back(self,type)
    game_scene:removePopByName("equip_streng_anim_pop");
end
--[[--
    读取ccbi创建ui
]]
function equip_streng_anim_pop.createUi(self)
    local ccbNode = luaCCBNode:create();
    local function onMainBtnClick( target,event )
        local tagNode = tolua.cast(target, "CCNode");
        local btnTag = tagNode:getTag();
        
        if btnTag == 100 then
            -- self:receiveAwards(btnTag);
            self.m_tParams.okBtnCallBack()
        elseif btnTag == 101 then
            self:back()
        end
    end
    ccbNode:registerFunctionWithFuncName("onMainBtnClick",onMainBtnClick);--bind button on click event
    ccbNode:openCCBFile("ccb/ui_equip_streng_pop.ccbi");
    self.m_root_layer = ccbNode:layerForName("m_root_layer");

    self.table_node = ccbNode:nodeForName("table_node")

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            -- if self.onrush_flag == true then
                -- game_util:addMoveTips({text = "装备正在强化中"})
            -- else
                self:back()
            -- end
            return true;
        elseif eventType == "ended" then
        end
    end
    self.m_root_layer:registerScriptTouchHandler(onTouch,false,GLOBAL_TOUCH_PRIORITY,true);
    self.m_root_layer:setTouchEnabled(true);

    local text1 = ccbNode:labelTTFForName("text1")
    text1:setString(string_helper.ccb.text148)
    return ccbNode;
end
--[[
    装备升级动画
]]
function equip_streng_anim_pop.createAnimTable(self,viewSize)
    local params = {};
    params.viewSize = viewSize;
    params.row = 4;
    params.column = 5; --列
    local count = game_util:getTableLen(self.equipData)
    params.totalItem = count;
    params.touchPriority = GLOBAL_TOUCH_PRIORITY-1;
    params.showPoint = false
    params.itemActionFlag = false;
    params.direction = kCCScrollViewDirectionVertical;
    local itemSize = CCSizeMake(viewSize.width/params.column,viewSize.height/params.row);
    params.newCell = function(tableView,index) 
        local cell = tableView:dequeueCell()
        if cell == nil then
            cell = CCTableViewCell:new();
            cell:autorelease();
            local ccbNode = luaCCBNode:create()            
            ccbNode:openCCBFile("ccb/ui_equip_anim_item.ccbi")
            ccbNode:setAnchorPoint(ccp(0.5,0.5))
            ccbNode:setPosition(ccp(itemSize.width*0.5,itemSize.height*0.5));
            cell:addChild(ccbNode,10,10);
        end
        if cell then
            local ccbNode = tolua.cast(cell:getChildByTag(10),"luaCCBNode");
            local equip_node = ccbNode:nodeForName("equip_node")
            local anim_sprite = ccbNode:spriteForName("anim_sprite")
            local level_label = ccbNode:labelBMFontForName("level_label")

            local equipItem = self.equipData[index+1]
            local equipLevel = equipItem.lv
            local equipId = equipItem.c_id
            -- level_label:setString("lv:" .. equipLevel)
            level_label:setVisible(false)
            --创建装备图标
            local icon,name = game_util:createEquipIconByCid(equipId)
            if icon then
                equip_node:removeAllChildrenWithCleanup(true)
                icon:setScale(0.8)
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(0,0))
                equip_node:addChild(icon,10)
                if name then
                    local nameLabel = game_util:createLabelTTF({text = name,color = ccc3(102,67,35),fontSize = 10});
                    nameLabel:setPosition(ccp(0,-25))
                    equip_node:addChild(nameLabel,10)
                end
            end
            self:onRushAnim(index,anim_sprite,icon,tableView,level_label,equipLevel)
        end
        return cell;
    end
    params.itemOnClick = function(eventType,index,item)
        if eventType == "ended" and item then
            
        end
    end
    params.pageChangedCallFunc = function(totalPage,curPage)
        
    end
    return TableViewHelper:create(params);
end
--[[
    装备动画
]]
function equip_streng_anim_pop.onRushAnim(self,index,anim_sprite,icon,tableView,level_label,lv)
    local tempTable = tableView
    local contentSize = tempTable:getContentSize()
    local viewSize = tempTable:getViewSize()
    local size = self.table_node:getContentSize()
    local scaleTime = 0.5
    local function setScrollPos()
        tableView:setContentOffset(ccp(0,viewSize.height - contentSize.height + size.height),true);
    end 
    local function setOver(node)
        level_label:setVisible(true)
        level_label:setString("lv:" .. lv)
        game_sound:playUiSound("stamp")
        icon:setColor(ccc3(151,151,151))
        if index + 1 < game_util:getTableLen(self.equipData) then 
            self.onrush_flag = true
        else
            self.onrush_flag = false
        end
    end
    local function setSpiteVisible(sprite)
        anim_sprite:setVisible(true)
    end
    local setOver = CCCallFuncN:create(setOver)
    local setSpiteVisible = CCCallFuncN:create(setSpiteVisible)
    local setScrollPos = CCCallFuncN:create(setScrollPos)
    anim_sprite:setScale(4)
    anim_sprite:setVisible(false)
    local showIndex = index + 1
    local arr = CCArray:create();
    local delayIndex = index % 25
    arr:addObject(CCDelayTime:create(0.5 + delayIndex*scaleTime));
    arr:addObject(setSpiteVisible)
    arr:addObject(CCScaleBy:create(scaleTime,0.25));
    arr:addObject(setOver);
    if showIndex % 20 == 0 and index > 0 then
        arr:addObject(setScrollPos);
    end
    anim_sprite:runAction(CCSequence:create(arr));
end

--[[--
    刷新ui
]]
function equip_streng_anim_pop.refreshUi(self)
    self.table_node:removeAllChildrenWithCleanup(true)
    local tableView = self:createAnimTable(self.table_node:getContentSize())
    -- textTableTemp:setScrollBarVisible(false)
    tableView:setTouchEnabled(false)
    self.table_node:addChild(tableView,10,10);
end
--[[--
    初始化
]]
function equip_streng_anim_pop.init(self,t_params)
    self.onrush_flag = true
    self.m_tParams = t_params or {};
    local tempData = t_params.equipData or {}
    self.equipData = {}
    for k,v in pairs(tempData) do
        table.insert(self.equipData,v)
    end
end
--[[--
    创建ui入口并初始化数据
]]
function equip_streng_anim_pop.create(self,t_params)
    self:init(t_params);
    self.m_tParams = t_params;
    self.m_popUi = self:createUi();
    self:refreshUi();
    return self.m_popUi;
end

--[[--
    回调方法
]]
function equip_streng_anim_pop.callBackFunc(self,typeName,t_params)
    local callBackFunc = self.m_tParams.callBackFunc;
    if callBackFunc and type(callBackFunc) == "function" then
        callBackFunc(typeName,t_params);
    end
end

return equip_streng_anim_pop;