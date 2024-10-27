-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
    require("game_ui.game_loading").close();
    game_util:writeErrorMessage(msg);
end

local function main()
    game = require("game");
    game:startup();
end

xpcall(main, __G__TRACKBACK__)
