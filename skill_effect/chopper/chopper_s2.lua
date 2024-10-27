--v3
--[[
chopper
1
0
penxue
1
{default,gongji3,1,0,0,55,1.000000}
1
{default,0.000000,0.000000,515.479126,227.795410,0,2,0,1,0.000000,0,0,0,0}
0

0

2
{0,chopper_gongji23_tempHp,2,5,0.000000,0.000000,20,0}
1
{default,impact,1,0,0,20,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{0,chopper_gongji23_tempHp,2,25,0.000000,0.000000,20,0}
1
{default,impact,1,0,0,20,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji3",1.000000,0,55,1}}, 
pos_sequence      = {{0.000000,0.000000,515.479126,227.795410,0,2,0,1,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"chopper_gongji23_tempHp",2,5,0.000000,0.000000,{{"impact",1.000000,0,20,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"chopper_gongji23_tempHp",2,25,0.000000,0.000000,{{"impact",1.000000,0,20,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 1,
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
