--v3
--[[
andy
1
0
penxue
1
{default,gongji2,1,0,0,64,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,0,0,0,1,0.000000,0,0,0,0}
0

0

3
{feiji1,andy_copter,2,0,0.000000,0.000000,10,0}
1
{default,feixing,0,0,0,10,1.000000}
1
{default,-70.000000,650.000000,450.000000,251.000000,2,2,0,10,1.000000,0,0,0,0}
0

0

{feiji2,andy_copter,2,11,0.000000,0.000000,50,0}
1
{default,gongji,0,0,0,50,1.000000}
1
{default,450.000000,250.000000,600.000000,250.000000,2,2,0,50,0.000000,0,0,0,0}
0

0

{3,andy_copter,2,61,0.000000,0.000000,20,0}
1
{default,feixing,0,0,0,15,1.000000}
1
{default,600.000000,250.000000,1300.000000,607.023804,2,2,0,15,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,64,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,1,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"andy_copter",2,0,0.000000,0.000000,{{"feixing",1.000000,0,10,0}},{{-70.000000,650.000000,450.000000,251.000000,2,2,0,10,1.000000,0,0,0,0}},{},{},0},
{"andy_copter",2,11,0.000000,0.000000,{{"gongji",1.000000,0,50,0}},{{450.000000,250.000000,600.000000,250.000000,2,2,0,50,0.000000,0,0,0,0}},{},{},0},
{"andy_copter",2,61,0.000000,0.000000,{{"feixing",1.000000,0,15,0}},{{600.000000,250.000000,1300.000000,607.023804,2,2,0,15,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 12,
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
