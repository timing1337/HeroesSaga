---按钮开启状态控制

local game_button_open = {
    m_button_open_new = {},
};


local game_button_ids = {
-- [[--
    -- 105,-- 马上有经验   17级开启   不引导
    -- 106,-- 资源争夺战   12级开启   不引导
    -- 107,-- 生存大考验   20级开启   不引导
    -- 108,-- 每日挑战   15级开启   不引导
    -- 109,-- 极限挑战 15级开启   不引导
    -- 200,-- 竞技场 完成 1-4 花园城市 后开启 第四关强制
    -- 507,-- 伙伴分解    16级开启   说一句话
    -- 307,-- 超能商店    16级开启   说一句话
    -- 501,-- 伙伴训练    5级开启    说一句话
    -- 502,-- 伙伴进阶    完成 1-4 花园城市 后开启 收复固定建筑（绿箭侠那个）
    -- 503,-- 技能升级    完成 1-3 神秘名胜 后开启 完成第三关强制
    -- 506,-- 伙伴传承    12级开启   不引导
    -- 509,-- 属性改造(连同战败)  13级开启   进入之后引导
    -- 601,-- 查看装备    完成 1-2 废区城市 后开启 不引导
    -- 602,-- 装备强化(连同战败)  完成 1-2 废区城市 后开启 完成第二关强制
    -- 603,-- 装备进阶    14级开启   不引导
    -- 605,-- 英雄技能    18级开启   说一句话
    -- 700,-- 公会  10级开启   不引导
    -- 800,-- 精英关卡    完成 1-4 花园城市 后开启 不引导
    -- 110,-- 无主之地    10级开启   不引导
    -- 606, -- 统率
    -- 607, -- 装备拆分
    -- 608, -- 装备精炼
    -- 801, -- 自动战斗  
    -- 111, -- 小秘书
    -- 112,  -- 伙伴转生
    -- 113, -- 进击的巨人

    -- 伙伴  lv.1开启  
    -- 伙伴招募    lv.2开启  
    -- 601,    --  装备  完成1-2废弃都市   601
    -- 602 ,   --  装备强化    完成“装备”引导    602
    -- 503,    --  技能升级    完成1-3神秘名胜   503
    -- 502,    --  伙伴进阶    收复1-4别墅     502
    -- 200,    --  竞技场 收复1-4花园城市   200
    -- 800,    --  精英关卡    收复2-4三角金块塔  800
    -- 603,    --  装备进阶    开启“精英关卡”    603
    -- 606,    --  统帅能力    lv.9开启      606
    -- 122,    --  融合  lv.10开启     122
    -- 700,    --  联盟  lv.10开启     700
    -- 110,    --  无主之地    lv.12开启     110
    -- 501,    --  伙伴训练    lv.14开启     501
    -- 109,    --  挑战  lv.15开启     109
    -- 105,    --  马上有经验   lv.17开启     105
    -- 605,    --  英雄技能    lv.18开启     605
    -- 506,    --  传承  lv.20开启     506
    -- 117,    --  重生  lv.20开启     117
    -- 509,    --  属性改造    lv.22开启     509
    -- 106,    --  物资争夺战   lv.24开启     106
    -- 608,    --  装备精炼    lv.26开启     608
    -- 107,    --  生存大考验   lv.28开启     107
    -- 112,    --  转生  lv.30开启     112
    -- 115,    --  献祭  lv.30开启     115
    -- 116,    --  分解  lv.26开启     116
    -- 114,    --  罗杰宝藏    lv.33开启     114
    -- 119,    --  宝石  lv.40开启     119
    -- 118,    --  宝石合成    lv.40开启     118
    -- 121,    --  宝石分解    lv.40开启     121
    -- 120,    --  装备附魔    lv.40开启     120
-- ]]
}


--[[
    初始化引导列表
]]


--[[--
    初始化
    @tab self
]]
function game_button_open.init(self)
    self:getButtonNewCfgTable()
end
--[[--
    设置按钮是否显示
    @tab self
    @tparam button btn
    @number btnId
    @number showType
    @return bool 按钮开启状态
]]
function game_button_open.setButtonShow(self,btn,btnId,showType)
    local openFlag = self:getOpenFlagByBtnId(btnId)
    local lockStr = self:getOpenGuideLockStrByBtnId(btnId);
    return self:setButtonStatusByType(btn,openFlag,showType,lockStr);
end

--[[--
    通过btnId获得开启的新手引导步骤
    @tab self
    @number btnId
    @return number 开启按钮的新手引导步骤
]]
function game_button_open.getOpenGuideIndexByBtnId(self,btnId)

    btnId = btnId or -1;
    local openGuideTeam = 0;
    local openGuideIndex = 0;
    local guide_button_open_cfg = getConfig(game_config_field.guide_button_open);
    -- guide_button_open_new_cfg 这个配置的数据可能不全 兼容bug 所以客户端自己生成按钮相对应的 id 
    -- 以客户端的为准
    local buttonInfo = self.m_button_open_new[tostring(btnId)]
    if type(buttonInfo) == "table" and buttonInfo[1] and buttonInfo[2] then
        -- cclog2(buttonInfo, btnId .. "buttonInfo  =====  ")
        return tonumber(buttonInfo[1]), tonumber(buttonInfo[2])
    end

    local guide_button_open_new_cfg = getConfig(game_config_field.guide_button_open_new);
    -- print(" guide_button_open_cfg === ", guide_button_open_cfg:getFormatBuffer() )
    -- print(" guide_button_open_new_cfg === ", guide_button_open_new_cfg:getFormatBuffer() )
    if guide_button_open_new_cfg then
        local itemCfg = guide_button_open_new_cfg:getNodeWithKey(tostring(btnId));
        if itemCfg and itemCfg:getNodeCount() > 1 then
            openGuideTeam = itemCfg:getNodeAt(0):toInt();
            openGuideIndex = itemCfg:getNodeAt(1):toInt();
        end
    else
        local itemCfg = guide_button_open_cfg:getNodeWithKey(tostring(btnId));
        if itemCfg then
            openGuideIndex = itemCfg:toInt();
        end
    end
    return openGuideTeam,openGuideIndex;
end

--[[--
    通过btnId获得按钮未开启的提示信息
    @tab self
    @number btnId
    @return string 提示信息
]]
function game_button_open.getOpenGuideLockStrByBtnId(self,btnId)
    btnId = btnId or -1;
    local lockStr = "";
    local button_open_cfg = getConfig(game_config_field.button_open);
    local itemCfg = button_open_cfg:getNodeWithKey(tostring(btnId))
    if itemCfg then
        lockStr = itemCfg:toStr();
    end
    return lockStr;
end

--[[--
    通过btnId获得按钮开启状态
    @tab self
    @number btnId
    @return bool 开启状态
]]
function game_button_open.getOpenFlagByBtnId(self,btnId)
    local openGuideTeam,openGuideIndex = self:getOpenGuideIndexByBtnId(tostring(btnId))
    -- local maxGuideIndex = game_guide_controller:getMaxGuideIndex();
    local maxGuideIndex = game_guide_controller:getMaxGuideIdByTeam(tostring(openGuideTeam));    
    -- cclog("btnId === " .. btnId .. " ; openGuideIndex === " .. openGuideIndex .. " ; maxGuideIndex === " .. maxGuideIndex .. " ; openGuideTeam = " .. openGuideTeam)
    local openFlag = false;
    if maxGuideIndex >= openGuideIndex then
        openFlag = true;
    end
    if openFlag == true then return openFlag end
    -- 如果按钮没有开启 可能是某些新手引导的数据不全的问题， 继续检查
    local guide_team_cfg = getConfig(game_config_field.guide_team);
    -- cclog2(guide_team_cfg, "guide_team_cfg  ===  ")
    local item_info = guide_team_cfg and guide_team_cfg:getNodeWithKey( tostring(openGuideTeam) ) or nil
    if not item_info then return openFlag end
    local open_sort = item_info:getNodeWithKey("open_sort") and item_info:getNodeWithKey("open_sort"):toInt() or 0
        -- cclog2(open_sort, "open_sort === ")
    if open_sort == 2 then
        local open_value = item_info:getNodeWithKey("open_value") and item_info:getNodeWithKey("open_value"):toInt() or 200
        -- cclog2(open_value, "open_value === ")
        local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
        if  open_value <= playerLevel then
            return true
        end
    end
    return openFlag;
end

--[[--
    检验按钮
    @tab self
    @number btnId
]]
function game_button_open.checkButtonOpen(self,btnId)
    local openFlag = self:getOpenFlagByBtnId(btnId)
    if openFlag == false then
        local lockStr = self:getOpenGuideLockStrByBtnId(btnId);
        game_util:addMoveTips({text = lockStr});
    end
    return openFlag;
end

--[[--
    设置锁定按钮提示文字的动画
    @tab self
    @tparam CCLableTTF label
    @string str
    @number outValue 
    @number inValue 
]]
function game_button_open.labelRepeatForeverFade(self,label,str,outValue,inValue)
    if label == nil then return end
    label:stopAllActions();
    outValue = outValue or 1
    inValue = inValue or 1
    local function newFunc(node)
        label:setColor(ccc3(0,255,0))
    end
    local function oldFunc(node)
        label:setColor(ccc3(255,255,255))
    end
    local animArr = CCArray:create();
    animArr:addObject(CCFadeIn:create(inValue));
    animArr:addObject(CCFadeOut:create(outValue));
    animArr:addObject(CCCallFuncN:create(newFunc));
    animArr:addObject(CCFadeIn:create(inValue));
    animArr:addObject(CCFadeOut:create(outValue));
    animArr:addObject(CCCallFuncN:create(oldFunc));
    label:runAction(CCRepeatForever:create(CCSequence:create(animArr)));
end

--[[--
    添加按钮未开启提示信息
    @tab self
    @tparam button btn
    @string lockStr 提示信息
]]
function game_button_open.addButtonLockLabel(self,btn,lockStr)
    local tempLabel = game_util:createLabelTTF({text = lockStr,color = ccc3(255,255,255),fontSize = 12});
    local tempSize = btn:getContentSize();
    tempLabel:setPosition(ccp(tempSize.width*0.5,tempSize.height*0.5));
    btn:addChild(tempLabel,10,10);
    game_button_open:labelRepeatForeverFade(tempLabel,lockStr);
end

--[[--
    设置按钮的状态
    @tab self
    @tparam button btn
    @bool openFlag 开启状态
    @number showType 显示状态
    @string lockStr 提示信息
    @return bool 开启状态
]]
function game_button_open.setButtonStatusByType(self,btn,openFlag,showType,lockStr)
    if btn == nil then return openFlag end
    showType = showType or 1;
    if showType == 1 then--按钮变灰不能点击
        if openFlag then
            -- btn:setEnabled(true);
            btn:setColor(ccc3(255,255,255));
        else
            -- btn:setEnabled(false);
            btn:setColor(ccc3(81,81,81));
            -- self:addButtonLockLabel(btn,lockStr);
        end
    elseif showType == 2 then--隐藏按钮
        if openFlag then
            -- btn:setEnabled(true);
            btn:setVisible(true);
        else
            -- btn:setEnabled(false);
            btn:setVisible(false);
        end
    end
    return openFlag;
end

--[[
    查看按钮开启等级 如果是等级开启返回需要等级，否则返回nil
]]
function game_button_open.getOpenButtonNeedLevel( self, btnId )
    local openGuideTeam,openGuideIndex = self:getOpenGuideIndexByBtnId(tostring(btnId))
    -- local maxGuideIndex = game_guide_controller:getMaxGuideIndex();
    -- local maxGuideIndex = game_guide_controller:getMaxGuideIdByTeam(tostring(openGuideTeam)); 
    local guide_team_cfg = getConfig(game_config_field.guide_team);
    -- cclog2(guide_team_cfg, "guide_team_cfg  ===  ")
    local item_info = guide_team_cfg and guide_team_cfg:getNodeWithKey( tostring(openGuideTeam) ) or nil
    if not item_info then return nil end
    local open_sort = item_info:getNodeWithKey("open_sort") and item_info:getNodeWithKey("open_sort"):toInt() or 0
        -- cclog2(open_sort, "open_sort === ")
    if open_sort == 2 then
        local open_value = item_info:getNodeWithKey("open_value") and item_info:getNodeWithKey("open_value"):toInt() or 200
        cclog2(open_value, "open_value === ")
        local playerLevel = game_data:getUserStatusDataByKey("level") or 1;
        if  open_value > playerLevel then
            return open_value
        end
    end
    return nil
end


--[[--
    查看当前开启的功能
    @tab self
    @tparam button btn
    @bool openFlag 开启状态
    @number showType 显示状态
    @string lockStr 提示信息
    @return bool 开启状态
]]

function game_button_open.getOpenButtonIdList(self)
    game_button_ids = {}
    local guide_manual_cfg = getConfig(game_config_field.guide_manual)
    if guide_manual_cfg then
        local nodeCount = guide_manual_cfg:getNodeCount()
        for i=1, nodeCount do
            local itemCfg = guide_manual_cfg:getNodeAt( i - 1)
            local inreviewCfg = itemCfg and itemCfg:getNodeWithKey("inreview")
            local inreview = inreviewCfg and inreviewCfg:toInt() or -1
            if game_data:isViewOpenByID(inreview) then
                local isGuide = itemCfg and itemCfg:getNodeWithKey("is_guide") or nil
                local isGuideValue = isGuide and isGuide:toInt() or 0
                if isGuideValue == 1 then
                    local buttonId = itemCfg:getNodeWithKey("button") and itemCfg:getNodeWithKey("button"):toInt() or nil
                    table.insert(game_button_ids, tostring(buttonId) )
                end
            end
        end
    end
    local openIds = {}
    for _, buttonID in pairs(game_button_ids) do
        openIds[tostring(buttonID)] = self:getOpenFlagByBtnId(buttonID)
    end
    return openIds
end

--[[ 
    新开启功能
]]
function game_button_open.getIsNewOpenButton( self, btnId )
     -- 检查现在开启的功能 现在开启功能列表
    btnId = tostring(btnId) or 0
    local curOpen = game_button_open:getOpenButtonIdList()
    local perOpen = game_data:getOpenButtonList()
    -- print("  per open is")
    -- print_lua_table(perOpen, 5)
    if curOpen[btnId] == true and perOpen[btnId] ~= true then
        return true
    end
    return false
end

--[[
    guide_button_open_new_cfg  新的获取配置方法，服务器返回的配置不准确了
]]
function game_button_open.getButtonNewCfgTable( self )
    local guide_cfg = getConfig(game_config_field.guide);
    local guide_table = guide_cfg and json.decode( guide_cfg:getFormatBuffer() ) or {}
    -- cclog2(guide_table, "guide_table ===== ")
    for k,v in pairs( guide_table ) do
        if type(v) == "table" then
            -- print("guide_table  ===  ", k, v)
            for kk,vv in pairs(v) do
                if type(vv) == "table" then
                    -- print(k .. "  ===  ", kk, vv)
                    for index, buttonID in pairs(vv.open_button or {}) do
                        -- print(kk .. "  ===  ", index, "buttonID  == ", buttonID)
                        self.m_button_open_new[ tostring(buttonID) ] = {}
                        self.m_button_open_new[ tostring(buttonID) ][1] = k
                        self.m_button_open_new[ tostring(buttonID) ][2] = kk
                    end
                end
            end
        end
    end
    -- cclog2(self.m_button_open_new, "self.m_button_open_new  =====  ")
end







return game_button_open;