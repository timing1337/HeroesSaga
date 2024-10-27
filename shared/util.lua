--- util 工具类

local M = {};
--[[--
    复制table
]]
function M.table_copy( _table_ )
	if(type(_table_) ~= "table") then
		return _table_;
	end
	local new_table = {};
	for i,v in pairs(_table_) do
		if(type(v) == "table") then
			new_table[i] = M.table_copy(v);
		else
			new_table[i] = v;
		end
	end
	return new_table;
	-- body
end

function M.table_new( _table_)
    return M.table_copy(_table_)
end

function M.string_cut( str,cutflag )
    -- body
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, cutflag);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

function M.printf( _table_ , str)
	-- body
	if(type(_table_) ~= "table") then
        if(str~=nil)then
            print(str,_table_,"<",tolua.type(_table_),">");
        else
		    print(_table_,"<",tolua.type(_table_),">");
        end
		return;
	end
	
	for i,v in pairs(_table_) do
		if(type(v) == "table") then
            if(str==nil)then
			    print(i,"<",tolua.type(i),">",v,"<",tolua.type(v),">");
                M.printf(v,"    ");
            else
                print(str,i,"<",tolua.type(i),">",v,"<",tolua.type(v),">");
                M.printf(v,str .. "    ");
            end
		else
			if(str==nil)then
                print(i,"<",tolua.type(i),">",v,"<",tolua.type(v),">");
            else
                print(str,i,"<",tolua.type(i),">",v,"<",tolua.type(v),">");
            end
		end
	end
end

function M.my_ceil( num )
    -- body
    local temp = math.floor(num);
    if(num>0)then
        if(temp<num)then
            temp = temp+1;
        end
    else
        if(temp>num)then
            temp = temp-1;
        end
    end
    return temp;
end

function M.url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

function M.url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function M.fileIsExist(fileName)
    -- local f = io.open(fileName);
    -- if f == nil then
    --     return false;
    -- end
    -- f:close();
    -- return true;
    local f = util_file:new();
    local t = false;
    if(f:Open(fileName,1)<=0)then
        t = false;
        f:Close();
    else
        f:Close();
        t = true;
    end
    f:delete();
    return t;
end

function M.readFile(fileName)
    -- local rFile=io.open(fileName, "r"); --读取文件(r读取)  
 --    if rFile == nil then return "" end;
 --    local readData = rFile:read("*all"); --读取所有数据
 --    rFile:close();
 --    return readData;
    -- local rFile = util_file:new();
    -- local readData = "";
    -- if(rFile:Open(fileName,1)<=0)then
    --     readData = "";
    -- else
    --     readData = rFile:ReadAll();
    -- end
    -- rFile:delete();

    local readDataCCString = CCString:createWithContentsOfFile(fileName)
    local readData = nil;
    if readDataCCString then
        readData = readDataCCString:getCString();
    end
    return readData;
end

function M.readFileByBuff(fileName,buffSize)
	local BUFSIZE = 2^13 -- 8K
	if buffSize ~= nil and type(buffSize) == "number" then
    	BUFSIZE = buffSize;
    end
    local f = io.input(fileName) -- open input file
    if f == nil then return "" end
    local cc, lc, wc = 0, 0, 0 -- char, line, and word counts
    local readData = "";
    while true do
        local lines, rest = f:read(BUFSIZE, "*line")
        if not lines then break end
        -- print("lines = " .. lines);
        -- print("rest = " .. rest);
        cclog("string len string.len(lines) = " .. string.len(lines) .. " ; string.len(rest) = " .. string.len(rest));
        if rest then readData = readData .. lines .. rest .. '\n' end
        cc = cc + string.len(lines)
        -- count words in the chunk
        local _,t = string.gsub(lines, "%S+", "")
        wc = wc + t
        -- count newlines in the chunk
        _,t = string.gsub(lines, "\n", "\n")
        lc = lc + t
    end
    cclog("lc = " .. lc .. " ; wc = " .. wc .. " ; cc = " .. cc);
    return readData;
end

function M.writeFile(fileName,data,mode)
    if mode == nil then mode = "w" end
    local wfile = io.open(fileName,mode);--写入文件(w覆盖) 
    if wfile == nil then return false end
    wfile:write(data);
    wfile:close();
    return true;
end

function M.stringSplit(str, splitChar)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, splitChar);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end
    return sub_str_tab;
end

function M.reload( moduleName )  
    package.loaded[moduleName] = nil  
    return require(moduleName)  
end  

function M.saveStringTable( fname,ptable )
    -- body
    local wfile = util_file:new();
    local f = "local tempTable = {\n";
    local a = "}\n\nreturn tempTable;";
    if(wfile:Open(fname,16))then
        wfile:Write(f,string.len(f));
        local str = nil;
        for k,v in pairs(ptable) do
            str = "\"" .. v .. "\",\n";
            wfile:Write(str,string.len(str));
        end
        wfile:Write(a,string.len(a));
        wfile:Close();
    else
        cclog("--- saveStringTable can not open file");
    end
    wfile:delete();
end


function M.saveConfigTable( fname,ptable )
    -- body
    local wfile = util_file:new();
    local f = "{\n";
    local a = "}\n";
    if(wfile:Open(fname,16))then
        wfile:Write(f,string.len(f));
        local str = nil;
        for k,v in pairs(ptable) do
            str = "\"" .. v .. "\",\n";
            wfile:Write(str,string.len(str));
        end
        wfile:Write(a,string.len(a));
        wfile:Close();
    else
        cclog("--- saveStringTable can not open file");
    end
    wfile:delete();
end




return M;