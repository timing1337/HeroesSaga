--v3
--[[--
andy
1
2
penxue
0

0

0

0

1
{0,ls_lighting_lighting,2,0,0.000000,0.000000,32,1}
1
{default,impact,1,0,0,32,1.000000}
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
anim_sequence    = {}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"ls_lighting_lighting",2,0,0.000000,0.000000,{{"impact",1.000000,0,32,1}},{{760.000000,200.000000,760.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},1}}, 
--bloodNum          = 1,
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
   battleSkill:createGroupAttack({skills_table = self,hpValue = skillData.hurt,animEndCallFunc = attackEnd});
end, 
}
return skillTest