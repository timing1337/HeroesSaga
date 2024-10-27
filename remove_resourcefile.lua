file = require("game_download.downloadBackground");


function removefile( path )
	-- body
	local l = 0;
	for k,v in pairs(file) do
		print(k,v);
		l = string.find(v,'/');
		print(l);
		-- l = string.find(v,'/',l - string.len(v));
		local fname = string.sub(v,l+1);
		print("remove " .. fname);
		os.remove(path .. fname);
	end
end

