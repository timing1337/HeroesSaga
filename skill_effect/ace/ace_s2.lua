--v3
--[[
ace
1
0
penxue
3
{default,shengli,0,0,0,12,1.000000}{default,qianjin,0,0,13,14,1.000000}{default,gongji1,1,0,15,36,1.000000}
2
{delay,0.000000,0.000000,0.000000,0.000000,0,0,0,12,0.000000,0,0,0,0}{default,0.000000,0.000000,-200.000000,0.000000,0,1,13,14,0.000000,0,0,0,0}
0

0

2
{1,ace_gongji3_1,0,0,0.000000,0.000000,22,0}
1
{default,impact,1,0,0,22,1.000000}
0

0

0

{0,ace_gongji3_2,3,0,0.000000,0.000000,22,0}
1
{default,impact,1,0,0,22,1.000000}
0

0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"shengli",1.000000,0,12,0},{"qianjin",1.000000,13,14,0},{"gongji1",1.000000,15,36,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,12,0.000000,0,0,0,0},{0.000000,0.000000,-200.000000,0.000000,0,1,13,14,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"ace_gongji3_1",0,0,0.000000,0.000000,{{"impact",1.000000,0,22,1}},{},{},{},0},
{"ace_gongji3_2",3,0,0.000000,0.000000,{{"impact",1.000000,0,22,1}},{},{},{},0}}, 
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
