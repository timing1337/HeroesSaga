--- 游戏声音

local audio = require("shared.audio");

local game_sound = {};

game_sound.music = {
	-- background_home = "sound/music/background_home.mp3",
	-- background_egypt = "sound/music/background_egypt.mp3",
	-- background_germany = "sound/music/background_germany.mp3",
	-- background_russia = "sound/music/background_russia.mp3",
	-- background_singapo = "sound/music/background_singapo.mp3",
	-- background_battle1 = "sound/music/background_battle1.mp3",
	-- background_battle2 = "sound/music/background_battle2.mp3",
};
game_sound.effect = {
	button_onclick                     = "sound/effect/button_onclick.wav",
};

--[[--
	loading all game sound 
]]
function game_sound.loadAllSound(self)
    for k,v in pairs(game_sound.music) do
        audio.preloadMusic(v);
    end
    for k,v in pairs(game_sound.effect) do
        audio.preloadSound(v);
    end
end
--[[--
	播放音效
]]
function game_sound.playSound(self,fileName,loop)
	local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
	soundFlag = soundFlag == nil and true or soundFlag;
	if self.effect[fileName] and soundFlag == true then
		audio.playSound(self.effect[fileName],false);
	end
end
--[[--
	 播放ui音效
]]
function game_sound.playUiSound(self,fileName,loop)
	local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
	soundFlag = soundFlag == nil and true or soundFlag;
	if soundFlag == true then
        local effectFileFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("sound/effect/" .. tostring(fileName)..".wav");
        local existFlag = util.fileIsExist(effectFileFullPath)
        if existFlag == true then
            audio.playSound(effectFileFullPath,false);
        end
	end
end
--[[--
	 播放攻击音效
]]
function game_sound.playAttackSound(self,fileName,loop)
	local soundFlag = CCUserDefault:sharedUserDefault():getBoolForKey("soundFlag")
	soundFlag = soundFlag == nil and true or soundFlag;
	if soundFlag == true then
		audio.playSound(fileName,false);
	end
end
--[[--
	 播放音乐
]]
function game_sound.playMusic(self,fileName,loop)
	if fileName == nil then return end
	local musicFlag = CCUserDefault:sharedUserDefault():getBoolForKey("musicFlag")
	musicFlag = musicFlag == nil and true or musicFlag;
	fileName = tostring(fileName);
	-- self.music[fileName] and
	if musicFlag == true and fileName ~= "" and game_data:getBackgroundMusicName() ~= fileName then
        if audio.isMusicPlaying() then
            audio.stopMusic(false);
        end
		game_data:setBackgroundMusicName(fileName);
		-- audio.playMusic(self.music[fileName],loop);
		audio.playMusic("sound/music/" .. fileName .. ".mp3",loop);
	end
end


return game_sound;