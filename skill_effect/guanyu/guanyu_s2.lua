--v3
--[[
guanyu
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji3,1,0,5,109,1.000000}
1
{default,0.000000,0.000000,-200.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}
0

0

3
{1,guanyu_texiao,2,5,0.000000,0.000000,104,0}
1
{default,texiao,1,0,0,104,1.000000}
1
{default,0.000000,0.000000,-200.000000,0.000000,0,1,0,1,0.000000,0,0,0,0}
0

0

{2,guanyu_texiao,4,5,0.000000,0.000000,104,0}
1
{default,texiao2,1,0,0,104,1.000000}
1
{default,0.000000,0.000000,480.000000,220.000000,2,2,0,1,0.000000,0,0,0,0}
1
{default,1.500000,1.500000,1.500000,1.500000,0,0,1}
0

{3,guanyu_texiao,0,5,0.000000,0.000000,104,0}
1
{default,texiao3,1,0,0,104,1.000000}
0

0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji3",1.000000,5,109,1}}, 
pos_sequence      = {{0.000000,0.000000,-200.000000,0.000000,0,1,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"guanyu_texiao",2,5,0.000000,0.000000,{{"texiao",1.000000,0,104,1}},{{0.000000,0.000000,-200.000000,0.000000,0,1,0,1,0.000000,0,0,0,0}},{},{},0},
{"guanyu_texiao",4,5,0.000000,0.000000,{{"texiao2",1.000000,0,104,1}},{{0.000000,0.000000,480.000000,220.000000,2,2,0,1,0.000000,0,0,0,0}},{{1.500000,1.500000,1.500000,1.500000,0,0,1}},{},0},
{"guanyu_texiao",0,5,0.000000,0.000000,{{"texiao3",1.000000,0,104,1}},{},{},{},0}}, 
bloodNum          = 6,
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
