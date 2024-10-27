--v3
--[[
matt
0
0
penxue
1
{default,gongji2,1,0,0,39,1.000000}
0

0

0

1
{0,siwangbaoxue,2,10,0.000000,0.000000,10,0}
1
{default,impact,1,0,0,10,1.000000}
1
{default,0.000000,-200.000000,0.000000,-200.000000,1,1,0,1,0.000000,0,0,0,0}
1
{default,1.500000,1.500000,1.500000,1.500000,0,0,1}
0


daiji
]]--
local skillTest = {
attack_type       = "jingong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,39,1}}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"siwangbaoxue",2,10,0.000000,0.000000,{{"impact",1.000000,0,10,1}},{{0.000000,-200.000000,0.000000,-200.000000,1,1,0,1,0.000000,0,0,0,0}},{{1.500000,1.500000,1.500000,1.500000,0,0,1}},{},0}}, 
bloodNum          = 2,
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
