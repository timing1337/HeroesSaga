--- 数据统计
local M = {

};

function M.init(self)

end

--[[
    进入游戏
]]
function M.enterGame(self,params)

end

--[[
    退出游戏
]]
function M.quitGame(self,params)

end

--[[
    创建角色
    {username = ""}
]]
function M.createRole(self,params)
    if MobClickCpp then
        MobClickCpp:setRegister(params.username);
    end
end

--[[
    登陆游戏
    {username = ""}
]]
function M.loginGame(self,params)
    if device_platform == "android" then
        require("shared.native_helper").onLogin(params.username)
    else
        if DATA_EYE then
            DATA_EYE.login(params.username)
        end
    end
    if MobClickCpp then
        MobClickCpp:setUserInfo(params.username,0,0,getPlatForm());
    end
end

--[[
    登出游戏
    game_data_statistics
]]
function M.logoutGame(self,params)
    if device_platform == "android" then
        require("shared.native_helper").onLogout()
    else
        if DATA_EYE then
            DATA_EYE.logout()
        end
    end
    if getPlatForm() == "itools" then
        -- PLATFORM_ITOOLS.logout()
    elseif getPlatForm() == "cmge" then
        PLATFORM_CMGE.logout()
    end
end

--[[
    游戏平台
]]
function M.gamePlatform(self,params)
    return getPlatForm();
end

--[[
    玩家等级改变
    {level=1}
]]
function M.userLevelChanged(self,params)
    -- if device_platform == "android" then
        require("shared.native_helper").onUserLevelChanged(params.level)
    -- else
        if DATA_EYE then
            DATA_EYE.setLevel(params.level)
        end
    -- end
    if MobClickCpp then
        MobClickCpp:setUserLevel(tostring(params.level));
    end
end

--[[
    进入城市
    {cityId = }
]]
function M.enterCity(self,params)
    if MobClickCpp then
        MobClickCpp:startLevel("cityId_" .. tostring(params.cityId));
    end
end

--[[
    收复城市
    {cityId = }
]]
function M.recoverCity(self,params)
    if MobClickCpp then
        MobClickCpp:finishLevel("cityId_" .. tostring(params.cityId));
    end
end

--[[
    进入活动
    {activeId = }
]]
function M.enterActive(self,params)
    if MobClickCpp then
        MobClickCpp:startLevel("active_" .. tostring(params.activeId));
    end
end

--[[
    完成活动
    {activeId = }
]]
function M.finishActive(self,params)
    if MobClickCpp then
        MobClickCpp:finishLevel("active_" .. tostring(params.activeId));
    end
end

--[[
    支付开始
    {order = "",productId=1,productPrice=1,currencyType = "CNY"}
]]
globla_price = {};
function M.payBegan(self,params)
    if device_platform == "android" then
        local paymentType = getPlatForm()
        require("shared.native_helper").onCharge(params,paymentType)
    else
        if DATA_EYE then
            local paymentType = getPlatForm()
            DATA_EYE.onCharge(params.order,params.productId,params.productPrice,params.currencyType,paymentType)
        end
    end
    local gameShopConfig = getConfig(game_config_field.charge);
    local moneyConfig = gameShopConfig:getNodeWithKey(tostring(params.productId));
    local tempCoin = moneyConfig:getNodeWithKey("coin"):toInt()

    globla_price[params.order] = {price = params.productPrice,coin = tempCoin}
end

--[[
    支付失败
    {order = ""}
]]
function M.payFailed(self,params)
    globla_price[params.order] = nil;
end

--[[
    支付成功
    {order = ""}
]]
function M.paySuccess(self,params)
    if device_platform == "android" then
        local paymentType = getPlatForm()
        require("shared.native_helper").paySuccess(params.order)
    else
        if DATA_EYE then
            DATA_EYE.onChargeSuccess(params.order)
        end
    end
    if MobClickCpp then
        if(globla_price[params.order]~=nil)then
            local price = globla_price[params.order].price;
            local coin = globla_price[params.order].coin;
            MobClickCpp:pay(price,1,coin);
            globla_price[params.order] = nil;
        end
    end
end

--[[
    购买
    {shopId = ,count = }
]]
function M.buyItem(self,params)
    -- MobClickCpp:buy(道具名,数量,价格)
end

--[[
    使用道具
    {itemId = 1,count = 1}
]]
function M.useItem(self,params)
    -- MobClickCpp:use(道具名,数量,价格)

end

--[[
    选择服务器
    {server = ""}
]]
function M.selectServer(self,params)
    if device_platform == "android" then
        require("shared.native_helper").setGameServer(params.server)
    else
        if DATA_EYE then
            DATA_EYE.setGameServer(params.server)
        end
    end
end

--[[
    引导
    {guideTeam = "",guideId = 1}
]]
function M.guide(self,params)
    if MobClickCpp then
        local tempGuideId = "newPlayer_" .. tostring(params.guideTeam) .. "_" .. tostring(params.guideId);
        cclog("-----guide----" .. tempGuideId);
        MobClickCpp:startLevel(tempGuideId);
        MobClickCpp:finishLevel(tempGuideId);
    end
end

--[[
    eventId
    label
]]
function M.beginEvent(self,params)
    -- if MobClickCpp then
    --     local eventId = params.eventId
    --     local label = params.label
    --     if eventId then
    --         cclog("beginEvent eventId == " .. tostring(eventId) .. " ; label == " .. tostring(label))
    --         if label then
    --             MobClickCpp:beginEventWithLabel(eventId,label)
    --         else
    --             MobClickCpp:beginEvent(eventId)
    --         end
    --     end
    -- end
end
--[[
    eventId
    label
]]
function M.endEvent(self,params)
--     if MobClickCpp then
--         local eventId = params.eventId
--         local label = params.label
--         if eventId then
--             cclog("endEvent eventId == " .. tostring(eventId) .. " ; label == " .. tostring(label))
--             if label then
--                 MobClickCpp:endEventWithLabel(eventId,label)
--             else
--                 MobClickCpp:endEvent(eventId)
--             end
--         end
--     end
end

--[[
    eventId
    label
]]
function M.event(self,params)
    if MobClickCpp then
        local eventId = params.eventId
        local label = params.label
        if eventId and label then
            cclog("event eventId == " .. tostring(eventId) .. " ; label == " .. tostring(label))
            MobClickCpp:event(eventId,label)
        end
    end
end

return M