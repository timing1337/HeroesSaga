--v3
--[[
ailisi
1
1
penxue
2
{move,qianjin,0,0,0,3,1.000000}{atk,gongji3,1,0,4,34,1.000000}
1
{default,0.000000,0.000000,480.000000,220.000000,0,2,0,3,0.000000,0,0,0,0}
0

0

1
{0,shouji_2,2,5,0.000000,0.000000,30,0}
1
{default,impact,0,0,0,30,1.000000}
1
{default,0.000000,-50.000000,0.000000,-50.000000,1,1,0,1,0.000000,0,0,0,0}
1
{default,1.500000,1.500000,1.500000,1.500000,0,0,1}
0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",1.000000,0,3,0},{"gongji3",1.000000,4,34,1}}, 
pos_sequence      = {{0.000000,0.000000,480.000000,220.000000,0,2,0,3,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"shouji_2",2,5,0.000000,0.000000,{{"impact",1.000000,0,30,0}},{{0.000000,-50.000000,0.000000,-50.000000,1,1,0,1,0.000000,0,0,0,0}},{{1.500000,1.500000,1.500000,1.500000,0,0,1}},{},0}}, 
bloodNum          = 5,
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
