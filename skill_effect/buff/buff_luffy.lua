--v1
--[[--
2
luffy
0
0
penxue
0

0

0

0

1
{0,zhengqi,0,0,0.000000,0.000000,7}
1
{default,impact,1,0,0,7,1.000000}
0

0

0


daiji
]]--
local skillTest = {
attack_type       = "jingong",
start_p           = {2,0,0},
end_p             = {2,0,0},
anim_sequence    = {}, 
pos_sequence      = {}, 
scale_sequence     = {}, 
fade_sequence      = {}, 
other_sequence      = {{"zhengqi",0,0,0.000000,0.000000,{{"impact",1.000000,0,7,1}},{},{},{}}}, 
flyAnim           = "ladeng",
flyAnim_equence   = {{"impact",1}}, 
par               = "",
fly_v             = 100,
fly_h             = 0,
hurtAnim_equence  = {{"impact",1}},
skillCallFunc     = function(self,battleSkill,battleTable,skillData) 
   table.foreach(skillData,function(k,v) 
   end); 
   local hpValue = 1;
   local function attackEnd()
   end
   battleSkill:addBuffCircel({skills_table = self,hpValue = skillData.hurt,animEndCallFunc = attackEnd,skill_data = skillData});
   battleSkill.m_attack_object.animNode:setColor(ccc3(255,95,95))
end, 
}
return skillTest
