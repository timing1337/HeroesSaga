--v3
--[[
bosaidong
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji3,1,0,5,56,1.000000}
1
{default,0.000000,0.000000,400.000000,200.000000,0,2,0,4,0.000000,0,0,0,0}
0

0

5
{lang2,bosaidong,1,5,0.000000,0.000000,51,0}
1
{default,gongji3_1,1,0,0,51,1.000000}
1
{default,600.000000,200.000000,600.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{lang1,bosaidong,2,5,0.000000,0.000000,51,0}
1
{default,gongji3_1,1,0,0,51,1.000000}
1
{default,550.000000,100.000000,550.000000,100.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{lang3,bosaidong,1,5,0.000000,0.000000,51,0}
1
{default,gongji3_1,1,0,0,51,1.000000}
1
{default,600.000000,300.000000,600.000000,300.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{lang4,bosaidong,1,5,0.000000,0.000000,51,0}
1
{default,gongji3_1,1,0,0,51,1.000000}
1
{default,550.000000,400.000000,550.000000,400.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{di,bosaidong,4,5,0.000000,0.000000,51,0}
1
{default,gongji3_2,1,0,0,51,1.000000}
1
{default,450.000000,200.000000,450.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji3",1.000000,5,56,1}}, 
pos_sequence      = {{0.000000,0.000000,400.000000,200.000000,0,2,0,4,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"bosaidong",1,5,0.000000,0.000000,{{"gongji3_1",1.000000,0,51,1}},{{600.000000,200.000000,600.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"bosaidong",2,5,0.000000,0.000000,{{"gongji3_1",1.000000,0,51,1}},{{550.000000,100.000000,550.000000,100.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"bosaidong",1,5,0.000000,0.000000,{{"gongji3_1",1.000000,0,51,1}},{{600.000000,300.000000,600.000000,300.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"bosaidong",1,5,0.000000,0.000000,{{"gongji3_1",1.000000,0,51,1}},{{550.000000,400.000000,550.000000,400.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"bosaidong",4,5,0.000000,0.000000,{{"gongji3_2",1.000000,0,51,1}},{{450.000000,200.000000,450.000000,200.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 5,
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
