--- json 与 table 互转
local json = {}
local cjson = require("cjson")
--[[--
    table转json文本
]]
function json.encode(var, isDebug)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    if isDebug then
        error(string.format("json encode failed: %s", tostring(result)))
    end
end
--[[--
    json文本转table
]]
function json.decode(text, isDebug)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    if isDebug then
        error(string.format("json decode failed: %s", tostring(result)))
    end
end

return json
