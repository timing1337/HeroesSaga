--v3
--[[
wolverine
1
0
penxue
5
{skill1,gongji2,0,0,0,28,1.000000}{delay,,2,0,29,30,0.000000}{daiji,daiji,0,0,31,33,1.000000}{qianjin,qianjin,0,0,34,37,1.000000}{gongji,gongji1,1,0,38,72,1.000000}
2
{delay,0.000000,0.000000,0.000000,0.000000,0,0,0,33,0.000000,0,0,0,0}{default,0.000000,0.000000,-150.000000,0.000000,0,1,34,37,0.000000,0,0,0,0}
0

0

0

daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,28,0},{"",0.000000,29,30,2},{"daiji",1.000000,31,33,0},{"qianjin",1.000000,34,37,0},{"gongji1",1.000000,38,72,1}}, 
pos_sequence      = {{0.000000,0.000000,0.000000,0.000000,0,0,0,33,0.000000,0,0,0,0},{0.000000,0.000000,-150.000000,0.000000,0,1,34,37,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {}, 
bloodNum          = 3,
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
