--v3
--[[--
xiaoxueguai
1
0
penxue
2
{delay,,0,0,0,2,0.000000}{default,mofa,0,0,3,64,1.000000}
1
{default,0.000000,0.000000,475.554321,212.824829,0,2,0,2,0.000000,0,0,0,0}
0

0

2
{1,kuzan_gongji4_1,2,44,0.000000,0.000000,60,0}
1
{default,impact,1,0,0,60,1.000000}
1
{default,830.000000,260.000000,830.000000,260.000000,2,2,0,1,0.000000,0,0,0,0}
0

0

{2,kuzan_gongji4_2,4,40,0.000000,0.000000,60,0}
1
{default,impact,1,0,0,60,1.000000}
1
{default,880.000000,180.000000,880.000000,180.000000,2,2,0,1,0.000000,0,0,0,0}
0

0


daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"",0.000000,0,2,0},{"mofa",1.000000,3,64,0}}, 
pos_sequence      = {{0.000000,0.000000,475.554321,212.824829,0,2,0,2,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"kuzan_gongji4_1",2,44,0.000000,0.000000,{{"impact",1.000000,0,60,1}},{{830.000000,260.000000,830.000000,260.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0},
{"kuzan_gongji4_2",4,40,0.000000,0.000000,{{"impact",1.000000,0,60,1}},{{880.000000,180.000000,880.000000,180.000000,2,2,0,1,0.000000,0,0,0,0}},{},{},0}}, 
bloodNum          = 0,
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
