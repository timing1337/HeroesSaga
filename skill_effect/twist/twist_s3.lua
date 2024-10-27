--v3
--[[
twist
1
0
penxue
2
{delay,qianjin,0,0,0,3,0.000000}{default,gongji3,1,0,4,64,1.000000}
1
{default,0.000000,0.000000,-270.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}
0

0

3
{1,twist_gongji_01,2,5,0.000000,0.000000,39,0}
1
{default,impact,1,0,0,36,0.800000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{2,twist_gongji_02,4,5,0.000000,0.000000,39,0}
1
{default,impact,1,0,0,36,0.800000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{3,twist_gongji_1,2,15,0.000000,0.000000,34,0}
1
{default,impact,1,0,0,34,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,0,0,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,3,0},{"gongji3",1.000000,4,64,1}}, 
pos_sequence      = {{0.000000,0.000000,-270.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"twist_gongji_01",2,5,0.000000,0.000000,{{"impact",0.800000,0,36,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"twist_gongji_02",4,5,0.000000,0.000000,{{"impact",0.800000,0,36,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"twist_gongji_1",2,15,0.000000,0.000000,{{"impact",1.000000,0,34,1}},{{0.000000,0.000000,0.000000,0.000000,0,0,0,1,0.000000,0,0,0,0}},{},{},0}}, 
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
