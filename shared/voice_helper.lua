module(..., package.seeall)
require "shared.json"

--通用平台接口
function sendMessage(name, table, callback)
    -- body
    local temp = table or {}
    local param = json.encode(temp)
    if callback ~= nil then
        local function response(str)
            -- cclog("-------- name:%s, respnse message:%s ---------", name , str)
            local data = json.decode(str, 0)
            callback(data)
        end
        cclog("EXTHelper == " .. tostring(EXTHelper))
        if EXTHelper then
            cclog("name == " .. name)
            EXTHelper:sendMessageToNative(name, param, response)
        else
            callback("none");
        end
    else
        if EXTHelper then
            EXTHelper:sendMessageToNative(name, param, nil)
        end
    end
end

--语音识别的功能
function voiceStart(callback)
    sendMessage("voiceStart", nil, callback)
end

