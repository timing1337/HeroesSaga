--v3
--[[
sangshigou
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji2,1,0,5,41,1.000000}
4
{default,0.000000,0.000000,0.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}{default,0.000000,0.000000,100.000000,0.000000,1,1,5,15,0.000000,0,0,0,0}{default,100.000000,0.000000,100.000000,0.000000,1,1,16,26,0.000000,0,0,0,0}{default,100.000000,0.000000,0.000000,0.000000,1,1,27,41,0.000000,0,0,0,0}
3
{delay,1.000000,1.000000,1.500000,1.500000,0,0,5}{default,1.500000,1.500000,1.500000,1.500000,0,6,38}{delay,1.000000,1.000000,1.000000,1.000000,0,39,55}
0

0

daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji2",1.000000,5,41,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,1,0,4,0.000000,0,0,0,0},{0.000000,0.000000,100.000000,0.000000,1,1,5,15,0.000000,0,0,0,0},{100.000000,0.000000,100.000000,0.000000,1,1,16,26,0.000000,0,0,0,0},{100.000000,0.000000,0.000000,0.000000,1,1,27,41,0.000000,0,0,0,0}}, 
scale_sequence     = {{1.000000,1.000000,1.500000,1.500000,0,0,5},{1.500000,1.500000,1.500000,1.500000,0,6,38},{1.000000,1.000000,1.000000,1.000000,0,39,55}}, 
fade_sequence      = {}, 
other_sequence      = {}, 
bloodNum          = 4,
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
