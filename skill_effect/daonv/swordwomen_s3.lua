--v3
--[[
daonv
1
0
penxue
2
{delay,qianjin,0,0,0,4,0.000000}{default,gongji4,1,0,5,75,1.000000}
6
{1,0.000000,0.000000,600.000000,200.000000,0,2,0,4,0.000000,0,0,0,0}{2,600.000000,200.000000,700.000000,250.000000,2,2,5,15,0.000000,0,0,0,0}{3,700.000000,250.000000,800.000000,150.000000,2,2,16,35,0.000000,0,0,0,0}{4,800.000000,150.000000,800.000000,250.000000,2,2,36,50,0.000000,0,0,0,0}{5,800.000000,250.000000,800.000000,180.000000,2,2,51,61,0.000000,0,0,0,0}{6,880.000000,180.000000,820.000000,210.000000,2,2,62,71,0.000000,0,0,0,0}
0

0

0

daiji
]]--
local skillTest = {
attack_type       = "yuangong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {{"qianjin",0.000000,0,4,0},{"gongji4",1.000000,5,75,1}}, 
pos_sequence      = {{0.000000,0.000000,600.000000,200.000000,0,2,0,4,0.000000,0,0,0,0},{600.000000,200.000000,700.000000,250.000000,2,2,5,15,0.000000,0,0,0,0},{700.000000,250.000000,800.000000,150.000000,2,2,16,35,0.000000,0,0,0,0},{800.000000,150.000000,800.000000,250.000000,2,2,36,50,0.000000,0,0,0,0},{800.000000,250.000000,800.000000,180.000000,2,2,51,61,0.000000,0,0,0,0},{880.000000,180.000000,820.000000,210.000000,2,2,62,71,0.000000,0,0,0,0}}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {}, 
bloodNum          = 10,
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
