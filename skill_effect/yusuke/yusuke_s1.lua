--v3
--[[
yusuke
1
0
penxue
3
{delay,qianjin,0,0,0,4,0.000000}{default,impact,1,0,5,45,1.000000}{default,gongji3,1,0,46,88,1.000000}
1
{default,0.000000,0.000000,-300.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}
0

0

3
{1,yusuke_gongji3_1,1,0,0.000000,0.000000,40,0}
1
{default,impact,1,0,0,40,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
1
{default,1.000000,1.000000,1.000000,1.000000,0,0,1}
0

{2,yusuke_gongji3_2,4,0,0.000000,0.000000,40,0}
1
{default,impact,1,0,0,40,1.000000}
1
{default,0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}
1
{default,1.500000,1.500000,1.500000,1.500000,0,0,1}
0

{3,yusuke_gongji3_3,2,0,0.000000,0.000000,40,0}
1
{default,impact,1,0,0,40,1.000000}
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
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"impact",1.000000,5,45,1},{"gongji3",1.000000,46,88,1}}, 
pos_sequence      = {{0.000000,0.000000,-300.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"yusuke_gongji3_1",1,0,0.000000,0.000000,{{"impact",1.000000,0,40,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{{1.000000,1.000000,1.000000,1.000000,0,0,1}},{},0},
{"yusuke_gongji3_2",4,0,0.000000,0.000000,{{"impact",1.000000,0,40,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{{1.500000,1.500000,1.500000,1.500000,0,0,1}},{},0},
{"yusuke_gongji3_3",2,0,0.000000,0.000000,{{"impact",1.000000,0,40,1}},{{0.000000,0.000000,0.000000,0.000000,1,1,0,1,0.000000,0,0,0,0}},{},{},0}}, 
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
