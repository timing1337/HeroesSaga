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

4
{1,ls_ice_icespear,2,0,0.000000,0.000000,26,0}
1
{default,impact,0,0,0,26,1.000000}
1
{default,10.000000,10.000000,10.000000,10.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{2,ls_ice_icespear,2,4,0.000000,0.000000,26,0}
1
{default,impact,0,0,0,26,1.000000}
1
{default,-10.000000,-10.000000,-10.000000,-10.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{3,ls_ice_icespear,2,8,0.000000,0.000000,26,0}
1
{default,impact,0,0,0,26,1.000000}
1
{default,-10.000000,10.000000,-10.000000,10.000000,1,1,0,1,0.000000,0,0,0,0}
0

0

{4,ls_ice_icespear,2,12,0.000000,0.000000,12,0}
1
{default,impact,0,0,0,12,1.000000}
1
{default,10.000000,-10.000000,10.000000,-10.000000,1,1,0,1,0.000000,0,0,0,0}
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
other_sequence      = {{"ls_ice_icespear",2,0,0.000000,0.000000,{{"impact",1.000000,0,26,0}},{{10.000000,10.000000,10.000000,10.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"ls_ice_icespear",2,4,0.000000,0.000000,{{"impact",1.000000,0,26,0}},{{-10.000000,-10.000000,-10.000000,-10.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"ls_ice_icespear",2,8,0.000000,0.000000,{{"impact",1.000000,0,26,0}},{{-10.000000,10.000000,-10.000000,10.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"ls_ice_icespear",2,12,0.000000,0.000000,{{"impact",1.000000,0,12,0}},{{10.000000,-10.000000,10.000000,-10.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0}}, 
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
