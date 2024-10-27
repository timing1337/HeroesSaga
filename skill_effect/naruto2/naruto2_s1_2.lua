--v3
--[[
naruto2
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji2,1,0,5,45,1.000000}
1
{default,0.000000,0.000000,-300.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}
0

0

1
{0,naruto2_texiao,2,5,0.000000,0.000000,40,0}
1
{default,gongji2_1,1,0,0,40,1.000000}
1
{default,0.000000,0.000000,-300.000000,0.000000,0,1,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji2",1.000000,5,45,1}}, 
pos_sequence      = {{0.000000,0.000000,-300.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"naruto2_texiao",2,5,0.000000,0.000000,{{"gongji2_1",1.000000,0,40,1}},{{0.000000,0.000000,-300.000000,0.000000,0,1,0,1,0.000000,0,0,0,0}},{},{},0}}, 
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
