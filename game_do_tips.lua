--[[--
    提醒消息列表    
]]                       
-- name = "功能",                                   -- 名称
-- isMultiValue = true,                            -- 是否具备多个值
-- key = "function",                               -- 提示关键字
-- isLocal = false,                                -- 是否存在本地
-- getDataFun = function ()  return data end,      -- 获取提示数据
-- isDataOKFun = function (data) return true end,  -- 检查提示数据是否符合提示条件
-- showTipsEvent = function (data) end,            -- 提示的行为 
-- showTipsEnd = function (data)  --[[  ]] end,    -- 提示完成后操作

local tips = {
    -- {
    --     name = "功能",                -- 名称
    --     isMultiValue = true,          -- 是否具备多个值
    --     key = "function",              -- 提示关键字
    --     isLocal = false,                -- 是否存在本地
    --     getDataFun = function ()        -- 获取提示数据
    --         local curOpen = game_button_open:getOpenButtonIdList()
    --         local perOpen = game_data:getOpenButtonList()
    --         for i,v in pairs(curOpen) do
    --             if v == true and perOpen[i] ~= true then
    --                 return i
    --             end  
    --         end
    --         return nil
    --     end,
    --     isDataOKFun = function (data)
    --         return data ~= nil
    --     end,
    --     showTipsEvent = function ( btnId )
    --         if game_data:isViewOpenByID( 36 ) then
    --             game_scene:addPop("game_help_new_pop", {entryBtnId = btnId})
    --         else
    --             game_data:resetOpenButtonList()
    --         end
    --     end,
    --     showTipsEnd = function ( data )
    --         -- game_data:addOneNewButtonByBtnID( data )
    --     end
    -- },
    -- {
    --     name = "金币招募",
    --     key = "gold_gacha",
    --     isMultiValue = true,
    --     isLocal = true,
    --     getDataFun = function ()
    --         return game_data:getUserStatusDataByKey("silver") or 0  -- 金币数量
    --     end,
    --     isDataOKFun = function (data)
    --         return game_data:isViewOpenByID(12) and data >= 300
    --     end,
    -- },
    {
        name = "新阵型",
        key = "formation",
        isMultiValue = true,
        isLocal = false,
        getDataFun = function ()
            local _, data = game_data:getOpenFormationAlertFlag() 
            return data
        end,
        isDataOKFun = function (data)
            return game_data:getOpenFormationAlertFlag()
        end,
    },
    {
        name = "卡牌碎片兑换",
        key = "exchange_card",
        isLocal = false,
        getDataFun = function ()
            return game_data:getAlertsDataByKey("exchange_card")
        end,
        isDataOKFun = function (data)

            local item_cfg = getConfig(game_config_field.item);
            local item_item_cfg = item_cfg:getNodeWithKey(tostring(data));
            if item_item_cfg then
                if item_item_cfg:getNodeWithKey("quality") and 
                    item_item_cfg:getNodeWithKey("quality"):toInt() == 4 then
                    return true
                end
            end
            return false
        end,
    },
    {
        name = "装备碎片兑换",
        key = "exchange_equip",
        isLocal = false,
        getDataFun = function ()
            return game_data:getAlertsDataByKey("exchange_equip")
        end,
        isDataOKFun = function (data)
            local item_cfg = getConfig(game_config_field.item);
            local item_item_cfg = item_cfg:getNodeWithKey(tostring(data));
            if item_item_cfg then
                if item_item_cfg:getNodeWithKey("quality") and 
                    item_item_cfg:getNodeWithKey("quality"):toInt() == 4 then
                    return true
                end
                return
            end
            return false
        end,
    },
    {
        name = "悬赏任务", 
        enable = false, 
    },
    {
        enable = true, -- 默认是可用的
        name = "训练",
        key = "train",
        isLocal = false,
        getDataFun = function ()
            return game_data:getAlertsDataByKey("train")
        end,
        isDataOKFun = function (data) 
            return data ~= "" 
        end,
    },
    -- {
    --     name = "竞技场排名下降",
    --     key = "rank_down",
    --     isLocal = false,
    --     getDataFun = function ()
    --         return game_data:getAlertsDataByKey("rank_down")
    --     end,
    --     isDataOKFun = function (data)
    --         return type(data) == "number" and data > 0 
    --     end,
    -- },
    {
        name = "生存大考验",
        key = "live_test",
        isMultiValue = true,
        isLocal = true,
        getDataFun = function ()
            -- local server_time = game_data:getUserStatusDataByKey("server_time")
            local curdate = os.date("*t", os.time())
            local hour = curdate.hour
            if hour > 21 then return 21 end
            if hour > 9 then return 9 end
        end,
        isDataOKFun = function (data)
            -- return  game_button_open:getOpenFlagByBtnId(107) 
            return  game_data:isViewOpenByID(6) and game_button_open:getOpenFlagByBtnId(107) 
        end,
    },
    {
        name = "VIP礼包",
        key = "vip_gift",
        isMultiValue = true,
        isOnlyOne = true,
        isLocal = true,
        getDataFun = function ()
            return game_data:getUserStatusDataByKey("vip") or 0
        end,
        isDataOKFun = function (data)
            local level = game_data:getUserStatusDataByKey("level") or 0
            local ldata = game_data:updateLocalData("VIPGUILD")
            if not game_data:isViewOpenByID(105) or level < 8 then
                return false
            end 
            return tostring(ldata) ~= tostring(data)
        end,
        showTipsEnd = function ( data )
            game_data:updateLocalData("VIPGUILD", tostring(data))
        end
    },
}


return tips