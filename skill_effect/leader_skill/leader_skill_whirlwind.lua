-- 1、动作是连续播放普通攻击的动作
--    按顺序攻击三个目标（后端脚本通知的）

local skillTest = {
    attack_type       = "yuangong", --jingong  yuangong  用于当前attack属于那种攻击
    attack_equence    = {{"daiji",0.5},{"daiji",0.5}}, --动作序列 加在攻击者身上
	attack_equence2   = {{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1},{"mofa",1}}, --动作序列 加在攻击者身上
    flyAnim           = "xuanfeng", --移动动画  例如：火球
    flyAnim_equence   = {{"impact",1}}, --移动动画播放的动作序列
    par               = "",--粒子特效
    start_p           = {0,0,0},--相对起始点，点有三个信息（相对对象，x，y），相对对象（0，为施法者，1为受法者,2 位置坐标） 他的值将决定 动画出现在己方 还是对方 身上
    end_p             = {2,0,0},--相对结束点，同上
    fly_v             = 150, --移动动画飞行速度，单位（像素/帧）
    fly_h             = 0, --移动动画飞行最大相对高度，相对于飞行距离, 大于0为凸曲线，小于0为凹曲线
    hurtAnim          = "daoguang", --受伤效果
    hurtAnim_equence  = {{"impact",1}},--受伤效果动作序列
    skillCallFunc     = function(self,battleSkill,battleTable) -- 技能的入口方法
        local skillData = battleTable.m_currentFrameData;  -- 后端传的当前技能的数据
        local function attackEnd()
        end
        battleSkill:createNormalAttack({skills_table = self,hpValue = skillData.hurt,animEndCallFunc = attackEnd});--顺序攻击一个或者多个
    end,
}
return skillTest