--v3
--[[
ironman2
1
0
penxue
1
{default,gongji2,1,0,0,56,1.000000}
1
{default,0.000000,0.000000,-300.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

2
{1,ironman2,2,0,0.000000,0.000000,56,0}
1
{default,gongji2_1,1,0,0,56,1.000000}
1
{default,400.000000,250.000000,400.000000,250.000000,2,2,0,1,0.000000,0,0,0,0}
1
{default,1.000000,1.000000,1.000000,1.000000,0,0,1}
0

{2,ironman2,4,0,0.000000,0.000000,56,0}
1
{default,gongji2_2,1,0,0,56,1.000000}
1
{default,400.000000,250.000000,400.000000,250.000000,2,2,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,56,1}}, 
pos_sequence      = {{0.000000,0.000000,-300.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"ironman2",2,0,0.000000,0.000000,{{"gongji2_1",1.000000,0,56,1}},{{400.000000,250.000000,400.000000,250.000000,2,2,0,1,0.000000,0,0,0,0}},{{1.000000,1.000000,1.000000,1.000000,0,0,1}},{},0},
{"ironman2",4,0,0.000000,0.000000,{{"gongji2_2",1.000000,0,56,1}},{{400.000000,250.000000,400.000000,250.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 6,
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
