--v3
--[[
rojer
1
0
penxue
2
{default,gongji4,1,0,0,24,1.000000}{default,gongji4_1,1,0,25,75,1.000000}
2
{delay,0.000000,0.000000,0.000000,0.000000,0,0,0,24,0.000000,0,0,0,0}{default,0.000000,0.000000,380.000000,222.805176,0,2,25,27,0.000000,0,0,0,0}
0

0

0

daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji4",1.000000,0,24,1},{"gongji4_1",1.000000,25,75,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,24,0.000000,0,0,0,0},{0.000000,0.000000,380.000000,222.805176,0,2,25,27,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {}, 
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
