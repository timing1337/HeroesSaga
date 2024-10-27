--v3
--[[
jean
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji3,1,0,5,52,1.000000}
1
{default,0.000000,0.000000,480.000000,230.000000,0,2,0,4,0.000000,0,0,0,0}
0

0

2
{0,jean_gongji3_1,2,0,0.000000,0.000000,47,0}
1
{default,impact,1,0,0,47,1.000000}
1
{default,730.000000,230.000000,730.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{1,jean_gongji3_2,4,0,0.000000,0.000000,47,0}
1
{default,impact,1,0,0,47,1.000000}
1
{default,730.000000,230.000000,730.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji3",1.000000,5,52,1}}, 
pos_sequence      = {{0.000000,0.000000,480.000000,230.000000,0,2,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"jean_gongji3_1",2,0,0.000000,0.000000,{{"impact",1.000000,0,47,1}},{{730.000000,230.000000,730.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"jean_gongji3_2",4,0,0.000000,0.000000,{{"impact",1.000000,0,47,1}},{{730.000000,230.000000,730.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 9,
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
