--v3
--[[
pudge
1
1
penxue
1
{default,gongji2,1,0,0,28,1.000000}
0

0

0

1
{gouzi,pudge_gouzi,1,18,0.000000,0.000000,6,0}
1
{default,impact,0,0,0,6,0.400000}
1
{delay,150.000000,-100.000000,-100.000000,-100.000000,0,1,0,5,0.000000,0,0,0,0}
1
{default,2.000000,2.000000,2.000000,2.000000,0,0,6}
0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,28,1}}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"pudge_gouzi",1,18,0.000000,0.000000,{{"impact",0.400000,0,6,0}},{{150.000000,-100.000000,-100.000000,-100.000000,0,1,0,5,0.000000,0,0,0,0}},{{2.000000,2.000000,2.000000,2.000000,0,0,6}},{},0}}, 
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
