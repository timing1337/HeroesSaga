--v3
--[[
ichigo
1
0
penxue
2
{default,gongji4,1,0,0,44,1.000000}{default,gongji1_2,1,0,45,73,1.000000}
2
{delay,0.000000,0.000000,0.000000,0.000000,0,0,0,44,0.000000,0,0,0,0}{default,0.000000,0.000000,-250.000000,0.000000,0,1,45,46,0.000000,0,0,0,0}
0

0

0

daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji4",1.000000,0,44,1},{"gongji1_2",1.000000,45,73,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,44,0.000000,0,0,0,0},{0.000000,0.000000,-250.000000,0.000000,0,1,45,46,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {}, 
--------------------------------------
aniState          = 1,
--------------------------------------
bloodNum          = 3,
flyAnim           = "ladeng",
flyAnim_equence   = {{"impact",1}}, 
par               = "",
fly_v             = 100,
fly_h             = 0,
hurtAnim          = "penxue",
hurtAnim_equence  = {{"impact",1}},
skillCallFunc     = function(self,battleSkill,battleTable) 
   local skillData = battleTable.m_currentFrameData; 
   table.foreach(skillData,function(k,v) 
   end); 
   local hpValue = 1;
   local function attackEnd()
   end
   battleSkill:createNormalAttack({skills_table = self,hpValue = skillData.hurt,animEndCallFunc = attackEnd});
end, 
}
return skillTest
