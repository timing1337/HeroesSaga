--v3
--[[--
andy
1
0
penxue
0

0

0

0

1
{0,ls_ice_blizzard,2,0,0.000000,0.000000,24,0}
1
{default,impact,1,0,0,24,1.000000}
1
{default,720.000000,230.000000,720.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"ls_ice_blizzard",2,0,0.000000,0.000000,{{"impact",1.000000,0,24,1}},{{720.000000,230.000000,720.000000,230.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0}}, 
--bloodNum          = 7,
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
