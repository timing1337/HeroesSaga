--v3
--[[
hadisi
1
0
penxue
2
{default,gongji2,1,0,0,26,1.000000}{default,gongji2_2,1,0,27,74,1.000000}
0

0

0

3
{1,hadisi,2,35,0.000000,0.000000,38,0}
1
{default,gongji2_1,1,0,0,38,1.000000}
1
{default,300.000000,200.000000,300.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}
1
{default,1.200000,1.200000,1.200000,1.200000,0,0,1}
0

{2,hadisi,0,69,0.000000,0.000000,14,0}
1
{default,mofa,1,0,0,14,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{3,hadisi,4,35,0.000000,0.000000,47,0}
1
{default,gongji2_3,1,0,0,47,1.000000}
1
{default,296.000000,200.000000,296.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}
1
{default,1.200000,1.200000,1.200000,1.200000,0,0,1}
0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"gongji2",1.000000,0,26,1},{"gongji2_2",1.000000,27,74,1}}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"hadisi",2,35,0.000000,0.000000,{{"gongji2_1",1.000000,0,38,1}},{{300.000000,200.000000,300.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}},{{1.200000,1.200000,1.200000,1.200000,0,0,1}},{},0},
{"hadisi",0,69,0.000000,0.000000,{{"mofa",1.000000,0,14,1}},{{0.000000,0.000000,0.000000,0.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"hadisi",4,35,0.000000,0.000000,{{"gongji2_3",1.000000,0,47,1}},{{296.000000,200.000000,296.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}},{{1.200000,1.200000,1.200000,1.200000,0,0,1}},{},0}}, 
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
