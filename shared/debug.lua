--- debug


function print_lua_table (lua_table, indent)
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix .. k .." = "..szSuffix
        if type(v) == "table" then
            print(formatting)
            print_lua_table(v, indent + 1)
            print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(formatting..szValue..",")
        end
    end
end
--[[
    快速打印变量 var
]]
function cclog2(var,name)
    name = name or "var"
    name = name .. " : type == " .. type(var) .. ", value"
    if tolua.type(var) == "util_json" then
        cclog(name .. " === " .. var:getFormatBuffer())
    elseif tolua.type(var) == "table" then
        -- cclog(name .. " === " .. json.encode(var))
        cclog(name .. "===" .. dump_obj(var))
    else
        cclog(name .. " === " .. tostring(var))
    end
end

function cclog3( var, name )
    name = name or "var"
    name = name .. " : type == " .. type(var) .. ", value"
    print(name, " =========  ")
    if tolua.type(var) == "util_json" then
        cclog(var:getFormatBuffer())
    elseif tolua.type(var) == "table" then
        -- cclog(name .. " === " .. json.encode(var))
        cclog(dump_obj(var))
    else
        cclog(tostring(var))
    end
end


--[[--
    print log
]]
function cclog(...)
    -- print(string.format( ... ))
    print(...)
end
--[[--
    print log by tag
]]
function cclogbytag(tag , ... )
    -- print(tostring(tag) .. " : " .. string.format(...))
    print(tag, " : ", ...)
end



function print_rect( rect, msg )
    msg = msg or ""
    if rect then
        print( msg , string.format("( %f, %f, %f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height))
    else
        print( msg , "this rect is nil")
    end

end

--[[
    dump_obj(obj [, key ][, sp ][, lv ][, st])
    obj: object to dump
    key: a string identifying the name of the obj, optional.
    sp: space string used for indention, optional(default:'  ').
    lv: for internal use, leave it alone! levels of nested dump.
    st: for internal use, leave it alone! map of saved-table.
 
    it returns a string, which is simply formed just by calling
    'tostring' with any value or sub values of object obj, exc-
    -ept table!.

    eg:
    print(dump_obj(_G))
]]
function dump_obj(obj, key, sp, lv, st)
    sp = sp or '  '
 
    if type(obj) ~= 'table' then
        return sp..(key or '')..' = '..tostring(obj)..'\n'
    end
 
    local ks, vs, s= { mxl = 0 }, {}
    lv, st =  lv or 1, st or {}
 
    st[obj] = key or '.' -- map it!
    key = key or ''
    for k, v in pairs(obj) do
        if type(v)=='table' then
            if st[v] then -- a dumped table?
                table.insert(vs,'['.. st[v]..']')
                s = sp:rep(lv)..tostring(k)
                table.insert(ks, s)
                ks.mxl = math.max(#s, ks.mxl)
            else
                st[v] =key..'.'..k -- map it!
                table.insert(vs,
                    dump_obj(v, st[v], sp, lv+1, st)
                )
                s = sp:rep(lv)..tostring(k)
                table.insert(ks, s)
                ks.mxl = math.max(#s, ks.mxl)
            end
        else
            if type(v)=='string' then
                table.insert(vs,
                    (('%q'):format(v)
                        :gsub('\\\10','\\n')
                        :gsub('\\r\\n', '\\n')
                    )
                )
            elseif type(v)=='userdata' and tolua.type(v) == "util_json"  then
                table.insert(vs,
                    (('%q'):format( v:getFormatBuffer() )
                        :gsub('\\\10','\\n')
                        :gsub('\\r\\n', '\\n')
                    )
                )
            else
                table.insert(vs, tostring(v))
            end
            s = sp:rep(lv)..tostring(k)
            table.insert(ks, s)
            ks.mxl = math.max(#s, ks.mxl);
        end
    end
 
    s = ks.mxl
    for i, v in ipairs(ks) do
        vs[i] = v..(' '):rep(s-#v)..' = '..vs[i]..'\n'
    end
 
    return '{\n'..table.concat(vs)..sp:rep(lv-1)..'}'
end