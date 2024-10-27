--v3
--[[
ailisi
1
1
penxue
3
{1,mofa,0,0,0,20,1.000000}{2,qianjin,0,0,21,23,0.000000}{3,gongji4,1,0,24,54,1.000000}
2
{delay,0.000000,0.000000,0.000000,0.000000,0,0,0,20,0.000000,0,0,0,0}{default,0.000000,0.000000,-200.000000,0.000000,0,1,21,24,0.000000,0,0,0,0}
0

0

1
{23,shouji_2,2,23,0.000000,0.000000,30,0}
1
{default,impact,0,0,0,30,1.000000}
2
{default,0.000000,-50.000000,0.000000,0.000000,1,1,0,24,0.000000,0,0,0,0}{default,0.000000,0.000000,0.000000,-50.000000,1,1,25,30,0.000000,0,0,0,0}
1
{default,1.500000,1.500000,1.500000,1.500000,0,0,1}
0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"mofa",1.000000,0,20,0},{"qianjin",0.000000,21,23,0},{"gongji4",1.000000,24,54,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,20,0.000000,0,0,0,0},{0.000000,0.000000,-200.000000,0.000000,0,1,21,24,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"shouji_2",2,23,0.000000,0.000000,{{"impact",1.000000,0,30,0}},{{0.000000,-50.000000,0.000000,0.000000,1,1,0,24,0.000000,0,0,0,0},{0.000000,0.000000,0.000000,-50.000000,1,1,25,30,0.000000,0,0,0,0}},{{1.500000,1.500000,1.500000,1.500000,0,0,1}},{},0}}, 
bloodNum          = 7,
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
