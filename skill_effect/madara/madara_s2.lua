--v3
--[[
madara
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji3,1,0,5,61,1.000000}
1
{default,0.000000,0.000000,400.000000,231.000000,0,2,0,1,0.000000,0,0,0,0}
0

0

1
{2,madara_gongji3,4,0,0.000000,0.000000,63,0}
1
{default,impact,1,0,0,63,1.000000}
1
{default,480.000000,320.000000,480.000000,320.000000,2,2,0,1,0.000000,0,0,0,0}
1
{default,1.500000,1.000000,1.500000,1.000000,0,0,1}
0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji3",1.000000,5,61,1}}, 
pos_sequence      = {{0.000000,0.000000,400.000000,231.000000,0,2,0,1,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"madara_gongji3",4,0,0.000000,0.000000,{{"impact",1.000000,0,63,1}},{{480.000000,320.000000,480.000000,320.000000,2,2,0,1,0.000000,0,0,0,0}},{{1.500000,1.000000,1.500000,1.000000,0,0,1}},{},0}}, 
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
