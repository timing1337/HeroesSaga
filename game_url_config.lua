--- 网络请求url

-- service_url = "http://dev.kaiqigu.net/genesis";--测试地址
-- battle_royale_service_url = "http://pub.kaiqigu.net/genesis";--测试地址

-- local domain ="http://pub.kaiqigu.net/genesis"
-- local service_url = domain.."/api";--测试地址
-- local login_service_url = domain.."/login";--测试地址
-- local battle_royale_service_url = domain.."/dataosha";--测试地址
-- local config_service_url = domain.."/config";

-- local service_url = "http://localhost:8888/api"
local device_mark = CCUserDefault:sharedUserDefault():getStringForKey("device_mark");
if device_mark == nil or device_mark == "" then
    device_mark   = tostring(util_system:macAddres()); -- mac 地址
end
local platform_channel = ""
if util_system.getPlatformChannel then
    platform_channel = tostring(util_system:getPlatformChannel()); -- 平台渠道号
end
user_token = ""; -- 测试用
mark_user_login_mk = "0";
device_platform = "";

-- local domain ="http://pub.kaiqigu.net/genesis"
-- local service_url = domain.."/api";--测试地址
-- local login_service_url = domain.."/login";--测试地址
-- local battle_royale_service_url = domain.."/dataosha";--测试地址
-- local config_service_url = domain.."/config";

--[[--
    game_url:
        游戏逻辑接口，访问的是各个应用服务器，没有固定域名和ip
    dataosha_url_config:
        访问团战服务器，没固定域名和ip
    login_url_config:
        用于登录的服务器，域名和ip基本不变（不保证
        sdk的登录和付费都放在login_url_config表中
]]

local game_url = {
    private_city_open = "/api/?method=private_city.open",--city=101
    test_battle = "/api/?method=battle.start",          -- 测试
    config_all_config = "/api/?method=config.all_config", --配置接口 config_name=map  参数config_name可缺省
    private_city_recapture = "/api/?method=private_city.recapture", -- 收复建筑接口 &city=101&buiding=101004&step_n=1
    user_loading = "/api/?method=user.loading",--
    cards_open = "/api/?method=cards.open",--背包
    cards_set_alignment = "/api/?method=cards.set_alignment",--更改阵型  align_1=1_2&align_2=3_4
    user_main_page = "/api/?method=user.main_page",--主界面接口
    cards_set_formation = "/api/?method=cards.set_formation",--改变阵型&formation=1

    leader_skill_open = "/api/?method=leader_skill.open",--避难所技能
    leader_skill_train = "/api/?method=leader_skill.train",--避难所技能学习skill=101   接口满级：is_max=1
    leader_skill_add_tree_point = "/api/?method=leader_skill.add_tree_point", --技能树加点儿 tree=1
    leader_skill_wash_down = "/api/?method=leader_skill.wash_down", --主角技洗白 tree=1
    harbor_set_skill = "/api/?method=leader_skill.set_skill",--避难所技能替换skill_1=101&skill_2=102&skill_3=103
    harbor_train_force = "/api/?method=leader_skill.train_force",--技能升级加速 -- harbor.train_force&stove_name=stove_1

    user_havest = "/api/?method=user.havest",--资源收取
    cards_card_skill_levelup = "/api/?method=cards.card_skill_levelup",--技能强化 -- major=100&metal=101&
    laboratory_open = "/api/?method=laboratory.open",--研究所
    laboratory_finish = "/api/?method=laboratory.finish",--研究所  领取 stove_key=stove_1
    laboratory_level_up_force = "/api/?method=laboratory.level_up_force",--研究所   加速 stove_key=stove_1
    laboratory_level_up = "/api/?method=laboratory.level_up",--研究所  card_id=1&type=def
    laboratory_cancle = "/api/?method=laboratory.cancle",--研究所  取消培养 stove_key=stove_1
    laboratory_wash_down = "/api/?method=laboratory.wash_down",--研究所  能晶摘除 card_id=1
    school_open = "/api/?method=school.open",--学校
    school_train = "/api/?method=school.train",--学校训练  stove_key=stove_1&train_type=1&train_time=1&card_id=2
    school_get_exp = "/api/?method=school.get_exp",--学校领取经验  stove_key=stove_1
    school_get_exp_force = "/api/?method=school.get_exp_force",--学校加速领取经验  stove_key=stove_1
    gift_curt_city_gift = "/api/?method=gift.curt_city_gift",--宝箱 city=
    gift_receiving_gift = "/api/?method=gift.receiving_gift",--领取宝箱gift=101
    school_eat_card = "/api/?method=school.eat_card",-- 技能传承 majoy=1&food=2&skill=s_1  majoy: 主卡id  food: 被吃卡id  skill: 要进化的技能id（s_1, s_2, s_3)
    cards_card_strong = "/api/?method=cards.card_strong",--卡牌进阶(升星)  major=主卡id&metal=材料卡id
    cards_active_skill = "/api/?method=cards.active_skill",--卡牌技能激活 skill_key=s_2&card_id=1
    cards_wash_skill = "/api/?method=cards.wash_skill",--卡牌技能重置 skill_1=1&skill_2=1&skill_3=1&card_id=1&eat_card_id_1=2&eat_card_id_2=3
    equip_all_equip = "/api/?method=equip.all_equip",--装备背包
    factory_factory_all = "/api/?method=factory.factory_all",--工厂
    factory_equip_make = "/api/?method=factory.equip_make",--装备制造  & metal_1=背包id & metal_2=背包id & metal_3=背包id & site=格子id & magor = 要制造装备的配置id
    factory_equip_levelup = "/api/?method=factory.equip_levelup",--升级装备 factory.equip_levelup&magor=升级装备背包id
    factory_completion_equip = "/api/?method=factory.completion_equip",--收取已经制造好的装备 site=制造位id

    factory_cancel_make = "/api/?method=factory.cancel_make",--装备撤销 site=制造位id
    factory_quick_make = "/api/?method=factory.quick_make",--装备加速 site=制造位id

    gacha_get_gacha = "/api/?method=gacha.get_gacha",--gacha  gacha_type=gacha_id
    gacha_get_all_gacha = "/api/?method=gacha.get_all_gacha",--gacha

    equip_gacha_get_all_gacha = "/api/?method=equip_gacha.get_all_gacha",--抽装备
    equip_gacha_get_gacha = "/api/?method=equip_gacha.get_gacha",-- 抽    gacha_type=gacha_id
    public_city_open = "/api/?method=public_city.open",--公共地图，打开城市 city_id=10001
    public_city_building_info = "/api/?method=public_city.building_info",--建筑信息 city_id=10001&building_id=1001
    public_city_attack = "/api/?method=public_city.attack",--攻击接口 city_id=10001&building_id=1001

    association_guild_all = "/api/?method=association.guild_all",--公会列表
    association_guild_create = "/api/?method=association.guild_create",--创建公会  name = 工会名&icon ＝ 图标
    association_guild_detail = "/api/?method=association.guild_detail",--工会详情  guild_id = 工会id
    association_add_notice = "/api/?method=association.add_notice",--编辑公会公告  notice=hihihi
    association_get_player_detail = "/api/?method=association.get_player_detail",-- 工会中的玩家信息  user_id＝玩家id
    association_guild_join = "/api/?method=association.guild_join",-- 申请加入工会  guild_id ＝ 工会id
    association_guild_agree = "/api/?method=association.guild_agree",-- 同意申请    user_id ＝ 玩家id
    association_guild_not_agree = "/api/?method=association.guild_not_agree",-- 拒绝申请    user_id ＝ 玩家id
    association_appoint_player = "/api/?method=association.appoint_player",-- 任命职务   position ＝ 0,1,2（0,解除职务会长不能解除自己，1,任命为会长，2,任命为副会长最多两个）  user_id ＝ 玩家id
    association_remove_player = "/api/?method=association.remove_player",-- 移除玩家    user_id ＝ 玩家id
    association_guild_destroy = "/api/?method=association.guild_destroy",-- 移除公会
    association_set_default = "/api/?method=association.set_default",-- 设置默认科技 science_id＝科技名
    association_develop_science = "/api/?method=association.develop_science",-- 开发科技 food＝钻石数
    association_buy_commodity = "/api/?method=association.buy_commodity",-- 兑换物品 commodity_id＝商品id
    association_shop = "/api/?method=association.shop",     -- 公会商店
    association_dedicate = "/api/?method=association.dedicate",     -- 公会捐献 &type=捐献类型（food, energy, metal, war_flag）&amount=100
    association_levelup = "/api/?method=association.levelup",       -- 公会科技升级 &flag=(guild_lv,shop_lv,map_lv,boss_lv,gvg_player_lv,gvg_monster_lv,gvg_home_lv)
    association_guild_quit = "/api/?method=association.guild_quit",--退出公会

    association_add_msg = "/api/?method=association.add_msg", --添加留言   msg = “消息”
    association_flush_msg = "/api/?method=association.flush_msg", --刷新留言

    guild_fight_reward = "/api/?method=association.guild_fight_reward",--公会战捐献奖励   reward_id

    association_game_list = "/dataosha/?method=game_list",          -- 公会战列表
    association_join_war = "/dataosha/?method=join_game",           -- 加入一个公会战 &game_id=(1,2,3,4)
    association_war_active = "/dataosha/?method=attack",            -- 公会战中行动消息 round_id=回合数 x=坐标x y=坐标y game_id=战场id
    association_flag_rank = "/dataosha/?method=rank",               -- 获得捐旗子排名 game_id=(1,2,3,4)
    association_con_flag = "/dataosha/?method=donate",              -- 公会长捐献旗子 game_id=(1,2,3,4) flag=要捐献的数量
    association_start_battle = "/dataosha/?method=open_battle_test",-- 临时接口开始公会战 game_id


    daily_award_all_reward = "/api/?method=daily_award.all_reward",-- 全部礼包
    daily_award_get_reward = "/api/?method=daily_award.get_reward",-- 获得礼包  reward＝礼包id（可多个）


    all_config = "/config/?method=all_config",--

    item_view = "/api/?method=item.view",
    item_exchange = "/api/?method=item.exchange",--碎片弹出框  change_id =  count = 1默认是1
    item_use = "/api/?method=item.use",
    item_sell = "/api/?method=item.sell",
    private_city_world_map = "/api/?method=private_city.world_map",

    arena_index = "/api/?method=arena.index", --竞技场数据
    arena_exchange = "/api/?method=arena.exchange", -- 竞技场兑换物品
    arena_battle = "/api/?method=arena.battle",  --竞技场挑战     target=uid&rank=100
    arena_log = "/api/?method=arena.log",    -- 战报
    arena_replay = "/api/?method=arena.replay",   -- 战报回放
    arena_top = "/api/?method=arena.top", -- 竞技场排行榜     page=1

    shop_buy = "/api/?method=shop.buy", -- shop_id=1
    shop_open = "/api/?method=shop.open", --
    user_guide = "/api/?method=user.guide", -- guide_team=1&guide_id=5
    user_rename = "/api/?method=user.rename", -- show_name=名字

    friend_send_message = "/api/?method=friend.send_message", -- 给好友发消息 target_id=test1&content=dddd
    friend_del_message = "/api/?method=friend.del_message", -- 删除消息 message_id=43
    friend_battle = "/api/?method=friend.battle", -- 向好友发起挑战 target_id=test1
    friend_search = "/api/?method=friend.search", -- 搜索 target_id=test1
    pay_kubi = "/api/?method=payment.pay",
    qiku_pay = "/api/?method=payment.qiku_pay",
    get_qiku_balance = "/api/?method=payment.get_qiku_balance",

    reward_index = "/api/?method=reward.index",--任务列表
    reward_daily_award = "/api/?method=reward.daily_award",--每日任务奖励 award_id = 1
    reward_once_award = "/api/?method=reward.once_award",--主线任务奖励  award_id = 1     ---现在变成领奖接口了
    reward_once_index = "/api/?method=reward.once_index", --进入成就
    code_index = "/api/?method=code.index",--激活码
    code_use_code = "/api/?method=code.use_code",--激活码使用 code = ssdsda
    user_info = "/api/?method=user.info", -- 玩家信息 uid=test
    cards_release_card = "/api/?method=cards.release_card", -- card_id= 释放锁
    cards_lock_card = "/api/?method=cards.lock_card", -- card_id= 锁卡
    cards_butcher = "/api/?method=cards.butcher", -- card_id= 卖卡

    active_index = "/api/?method=active.index", --active首页
    active_fight = "/api/?method=active.fight", --做活动 chapter=1&active_id=1&step_n=1
    active_kfhd_index = "/api/?method=reward.opening_index",  -- 开服活动首页
    active_kfhd_getreward = "/api/?method=reward.opening_award", -- 开服奖励领取奖励
    clear_fight_log = "/api/?method=active.clear_fight_log",--放弃当前活动
    equip_sell = "/api/?method=equip.sell", --卖装备 equip=1
    private_city_auto_recapture = "/api/?method=private_city.auto_recapture", --自动扫荡 city=101&building=101002

    vip_guide_isbuy = "/api/?method=shop.vip_guide_step", -- 消费计划 物品项被购买多少次
    vip_guide_buy = "/api/?method=shop.vip_guide_buy",  -- 消费项目
    level_gift_buy = "/api/?method=user.level_award", -- 等级礼包购买

    buy_cmdr_energy = "/api/?method=vip.buy_cmdr_energy",--购买精力
    buy_commbander_protect = "/api/?method=vip.buy_commbander_protect",--买保护罩

    cards_exchange = "/api/?method=cards.exchange", --卡牌分解 card_id=3801-1390744710-sBcv5T
    cards_inherit = "/api/?method=cards.inherit",--伙伴传承 master=901-1390745387-RdIyhh&student=70300-1392366806-kWk7CI  加了参数use_exp_ball=1    传承和被传承的英雄Id
    cards_open_dirt_shop = "/api/?method=cards.open_dirt_shop",--卡牌商店
    cards_refresh_dirt_shop = "/api/?method=cards.refresh_dirt_shop",--卡牌商店刷新
    cards_dirt_shop_buy = "/api/?method=cards.dirt_shop_buy",--购买卡牌   shop_id=3
    world_boss_index = "/api/?method=world_boss.index",--世界Boss
    public_city_index = "/api/?method=public_city.index",--中立地图列表
    world_boss_fight = "/api/?method=world_boss.fight",--打世界Boss    boss_id = 1
    pay_award_index = "/api/?method=pay_award.index",--周充值、月充值奖励  nil

    guildboss_index = "/api/?method=association.guildboss_index",--公会boss
    guildboss_fight = "/api/?method=association.guildboss_fight",--打公会boss
    guildboss_revive = "/api/?method=association.guildboss_revive",--公会boss复活

    user_online_award = "/api/?method=user.online_award",--领取在线奖励 nil
    reward_gift_award = "/api/?method=reward.gift_award",--领取物资  award_id = 1
    equip_evolution = "/api/?method=equip.evolution",--装备进阶  equip_id=22
    notify_messages = "/api/?method=notify.messages",--获取消息
    notify_read = "/api/?method=notify.read",--阅读消息  message_id=1392972040_0

    rank_combat = "/api/?method=user.top_combat",  -- 战力排行榜
    rank_level = "/api/?method=user.top_level",   -- 等级排行榜
    rank_boss = "/api/?method=user.top_world_boss_hurt",   -- boss排行

    reward_index = "/api/?method=reward.index",--查看wantend
    wanted_award = "/api/?method=reward.wanted_award",--领取wanted奖励  arard_id = 1

    inactivate_daily_task = "/api/?method=reward.inactivate_daily_task",--放弃每日悬赏任务 award_id = 9
    refresh_daily_task = "/api/?method=reward.refresh_daily_task",--刷新每日悬赏
    activate_daily_task = "/api/?method=reward.activate_daily_task",--激活（接受）每日悬赏 award_id = 9
    daily_score_award = "/api/?method=reward.daily_score_award",--领取daily score     score=50    5,10,15,25

    get_award = "/api/?method=pay_award.get_award",--领取周/月礼包

    forever_fight = "/api/?method=active.forever_fight",--生存大挑战 战斗   level=1
    auto_forever_fight = "/api/?method=active.auto_forever_fight",--生存大挑战 突进
    cards_melting = "/api/?method=cards.cards_exchange",--卡牌合成 参数  exchange_id=1&card_ids='51'&card_ids='51'&card_ids='51'&card_ids='51'&card_ids='51'

    --Vip相关接口
    buy_fight_times = "/api/?method=active.buy_fight_times",--购买活动次数        chapter=1
    clear_sweep_log = "/api/?method=private_city.clear_sweep_log",--重置 扫荡记录  city=101&building=101002
    world_boss_revive = "/api/?method=world_boss.revive",--world_boss 快速复活
    fast_finish_daily_award = "/api/?method=reward.fast_finish_daily_award",--快速完成每日任务
    vip_open_stove = "/api/?method=school.vip_open_stove",--vip 开启 训练位置      stove_key=stove_3
    arena_buy_count = "/api/?method=arena.buy_count",--购买竞技场战斗次数
    shop_vip_buy = "/api/?method=shop.vip_buy",--vip特权礼包    shop_id=4   nil 是进入的
    cards_card_evolution = "/api/?method=cards.card_evolution",  --卡牌进阶 major=主卡id&metal=材料卡id
    buy_point = "/api/?method=vip.buy_point",--购买行动力

    vip_buy_step = "/api/?method=shop.vip_buy_step", --查看vip礼包买到第几个了
    -- 刷新用户基础信息请求
    user_refresh = "/api/?method=user.refresh",
    reward_diary_index = "/api/?method=reward.diary_index",--每日任务
    reward_diary_score_award = "/api/?method=reward.diary_score_award",--每日领奖 score=

    -- 小伙伴
    cards_activate_assistant = "/api/?method=cards.activate_assistant",     -- 小伙伴开格子 {position=0}

    commander_index = "/api/?method=commander.index",--统帅首页
    commander_synthesis = "/api/?method=commander.synthesis",--配方合成  recipe=1
    commander_search = "/api/?method=commander.search",--查看可抢夺的对手  item_id=6531
    commander_rob = "/api/?method=commander.rob",--抢夺 target_uid=robot_100&item_id=6101
    commander_protect = "/api/?method=commander.protect",--保护

    active_top = "/api/?method=active.top",--生存大考验 排行榜
    equip_st_levelup = "/api/?method=equip.st_levelup",--装备精炼 equip_id=1  sort=0 0或不传默认普通精炼，1高级精炼
    equip_exchange = "/api/?method=equip.exchange",--装备分解 equip_id=193&equip_id=193&

    shop_outlets_open = "/api/?method=shop.outlets_open",--限量商城
    shop_outlets_buy = "/api/?method=shop.outlets_buy",--shop_id=1
    daily_award_coin_award = "/api/?method=daily_award.coin_award",--充值领奖

    user_watch_pay_award = "/api/?method=user.watch_pay_award",--内测充值查看
    user_get_pay_award = "/api/?method=user.get_pay_award",--内测充值领取奖励
    public_city_rob_log = "/api/?method=public_city.rob_log",--中立地图战报

    all_equip_levelup_auto = "/api/?method=equip.all_equip_levelup_auto",--装备一键强化
    search_treasure_st_open = "/api/?method=search_treasure.st_open",--开启罗杰的宝藏地图  treasure = 1
    search_treasure_recapture = "/api/?method=search_treasure.recapture",--罗杰的宝藏打NPC 打人也是   treasure=1&city=1&building=1&step_n=1
    search_treasure_open_building = "/api/?method=search_treasure.open_building",--打开人物信息   building=510006&city=1&treasure=1
    search_treasure_open_building_gifts = "/api/?method=search_treasure.open_building_gifts",--打开宝物信息 treasure=1&city=10001&building=510024
    search_treasure_open_building_buff = "/api/?method=search_treasure.open_building_buff",--打开buff信息 treasure=1&city=10001&building=510024
    search_treasure_add_gifts = "/api/?method=search_treasure.add_gifts",--获得宝物  treasure=1&city=10001&building=510024&gift_idx=0&gift_idx=2
    search_treasure_add_buff = "/api/?method=search_treasure.add_buff",--增加buff  treasure=1&city=10001&building=510024
    search_treasure_recover_hp = "/api/?method=search_treasure.recover_hp",--罗杰恢复血量 treasure=1
    search_treasure_map_fight_and_enemy = "/api/?method=search_treasure.map_fight_and_enemy",--查看NPC的 building=510006&city=1&treasure=1
    search_treasure_recover_times = "/api/?method=search_treasure.recover_times",--罗杰的宝藏购买次数
    association_rescue_index = "/api/?method=association.rescue_index",--救援界面
    search_treasure_help_treasure = "/api/?method=search_treasure.help_treasure",--死亡后求助
    search_treasure_help_recapture = "/api/?method=search_treasure.help_recapture",--救援进入战斗 help_uid=h17247506&help_time=help_time&step_n=0
    battle_challenge_info = "/api/?method=battle.challenge_info",--宝藏入口

    new_user = "/login/?method=new_user",--用户注册 role=1  account ＝
    mark_user_login = "/login/?method=mark_user_login",--

    user_request_code_index = "/api/?method=user.request_code_index",--邀请码 首页
    user_search_master = "/api/?method=user.search_master",-- 拜师  master=h19709641
    user_request_code_gift = "/api/?method=user.request_code_gift",-- 领取奖励 tp=master&slave=h1993  tp :  master/slave  # 师傅奖励/徒弟奖励  slave: 如果tp为slave  需传递徒弟uid
    top_gacha_score = "/api/?method=user.top_gacha_score",--gacha 排行 page=0
    top_world_boss_hurt = "/api/?method=user.top_world_boss_hurt",--boss排行榜 page=0
    get_reward_gacha = "/api/?method=gacha.get_reward_gacha",--限时神卡 进入
    do_reward_gacha = "/api/?method=gacha.do_reward_gacha",--限时神卡   抽卡    reward_gacha_id=1
    integration_index = "/api/?method=active.integration_index",--限时积分   进入
    private_city_hard_open = "/api/?method=private_city.hard_open",  -- 精英关卡进入接口
    city_hard_recapture = "/api/?method=private_city.hard_recapture",  -- 精英关卡收复接口
    integration_shop = "/api/?method=active.integration_shop", -- 积分商城入口
    integration_exchange = "/api/?method=active.integration_exchange", -- 积分商城入口  &shop_id=1     # 积分兑换
    private_city_get_world_reward = "/api/?method=private_city.get_world_reward", -- 世界积分领奖 level=1
    private_city_world_score = "/api/?method=private_city.world_score",-- 世界积分

    active_active_show = "/api/?method=active.active_show",--充值活动
    active_consume_receive = "/api/?method=active.active_consume_receive",--消耗活动  active_id = 1
    active_recharge_receive = "/api/?method=active.active_recharge_receive",--充值活动领取奖励 active_id = 1
    super_active_index = "/api/?method=super_active.index",--超级赛亚人归来
    super_active_get_all_reward = "/api/?method=super_active.get_all_reward",--赛亚人阶段奖励 step = 1
    super_active_get_rich_reward = "/api/?method=super_active.get_rich_reward",--tp: 类型  reward_12|reward_21|reward_24 赛亚人奖励

    private_city_auto_sweep_building ="/api/?method=private_city.auto_sweep_building", --获取可自动战斗的建筑列表
    guildboss_open = "/api/?method=association.guildboss_open",--开启公会boss  try_open=0   1是开启，0是查看
    private_city_get_world_reward = "/api/?method=private_city.get_world_reward", -- 世界积分领奖
    hard_giveup = "/api/?method=private_city.hard_giveup", -- 重新开始
    equip_books = "/api/?method=equip.books",  -- 装备信息
    cards_books = "/api/?method=cards.books",--图鉴
    cards_card_break = "/api/?method=cards.card_break", -- 伙伴突破  card_id=2100-1400929451-jw1JSL
    buy_done_times = "/api/?method=private_city.buy_done_times",
    user_remove_slave = "/api/?method=user.remove_slave",-- 移除徒弟 uid =

    association_guild_one = "/api/?method=association.guild_one",--搜索公会     ass_id=1
    loading = "/login/?method=loading",--
    loading_for_test = "/login/?method=loading_for_test",
    get_exchangecenter_list = "/api？method=omni_exchange.transform",
    omni_exchange_lastcount = "/api/?method=omni_exchange.show_omni_exchange_options",
    omni_exchange = "/api/?method=omni_exchange.omni_exchange",
    private_city_map_fight_and_enemy = "/api/?method=private_city.map_fight_and_enemy",--获取战斗相关配置 city = ,building =
    active_map_fight_and_enemy = "/api/?method=active.map_fight_and_enemy",--获取战斗相关配置 chapter = ,active_id = step_n =


    playerboss_index = "/api/?method=arena.playerboss_index",  --             玩家BOSS 页面
    playerboss_fight = "/api/?method=arena.playerboss_fight",  --             玩家BOSS 战斗
    playerboss_award = "/api/?method=arena.playerboss_award",  -- &award_id=1    玩家BOSS 领奖
    playerboss_log ="/api/?method=arena.playerboss_log", -- 挑战日志
    commander_enemies = "/api/?method=commander.enemies",  -- 仇人列表
    server_limit_hero_index = "/api/?method=server_limit_hero.get_reward_gacha",--开服活动-----限时伙伴 index
    server_limit_hero_do = "/api/?method=server_limit_hero.do_reward_gacha",--开服 限时伙伴抽卡  reward_gacha_id=18

    friend_friends = "/api/?method=friend.friends", -- 好友列表friend_add_friend
    friend_add_friend = "/api/?method=friend.apply_friend", -- 添加好友 target_id=test1  message_id=111
    friend_remove_friend = "/api/?method=friend.remove_friend", -- 删除好友 target_id=test1 , message_all: bool值， 删除全部信息时传递
    friend_messages = "/api/?method=friend.messages", -- 好友消息列表
    friend_send_gift = "/api/?method=friend.send_gift", --好友赠送体力
    friend_apply_friend = "/api/?method=friend.apply_friend", --好友赠送体力
    friend_read_message = "/api/?method=friend.read_message",

    guild_invite = "/api/?method=friend.guild_invite", -- &target_id=xxx  -- 公会邀请
    roulette_index = "/api/?method=roulette.index", -- 转盘入口
    roulette_refresh = "/api/?method=roulette.refresh", -- 转盘刷新
    roulette_open_roulette = "/api/?method=roulette.open_roulette", -- 开启转盘
    roulette_open_roulette10 = "/api/?method=roulette.open_roulette10", -- 开启十次转盘
    server_roulette_index = "/api/?method=server_roulette.index", -- 转盘入口
    server_roulette_refresh = "/api/?method=server_roulette.refresh", -- 转盘刷新
    server_roulette_open_roulette = "/api/?method=server_roulette.open_roulette", -- 开启转盘
    server_roulette_open_roulette10 = "/api/?method=server_roulette.open_roulette10", -- 开启十次转盘

    book_equip_exchange = "/api/?method=book_exchange.equip_exchange",  -- 图鉴兑换
    show_equip_options = "/api/?method=book_exchange.show_equip_options", -- 装备兑换入口 装备兑换信息

    sacrifice_index = "/api/?method=sacrifice.index",--献祭入口
    sacrifice_open_sacrifice = "/api/?method=sacrifice.open_sacrifice",--献祭开启
    sacrifice_con_sacrifice = "/api/?method=sacrifice.con_sacrifice",--献祭继续
    sacrifice_high_sacrifice = "/api/?method=sacrifice.high_sacrifice",--高级献祭
    sacrifice_one_key_full = "/api/?method=sacrifice.one_key_full",--献祭一键全满
    sacrifice_harvest_grace = "/api/?method=sacrifice.harvest_grace",--收取
    sacrifice_one_key_sacrifice = "/api/?method=sacrifice.one_key_sacrifice",--一键献祭  times: 献祭次数  mode: 献祭方式 1 2 3 4
    sacrifice_open_shop = "/api/?method=sacrifice.open_shop",--兑换入口
    sacrifice_grace_exchange = "/api/?method=sacrifice.grace_exchange",--神恩兑换  shop_id 商店id  count  购买数量

    book_character_exchange = "/api/?method=book_exchange.character_exchange",  -- 卡牌图鉴兑换
    show_character_options = "/api/?method=book_exchange.show_character_options", -- 卡牌兑换入口 卡牌兑换信息
    super_active_index = "/api/?method=super_active.index", -- 神龙
    super_active_get_all_reward = "/api/?method=super_active.get_all_reward", -- 神龙领奖 step=1

    user_top_rank = "/api/?method=user.top_rank",--新排行榜  sort=purple_card&page=0   --紫/橙卡、收复度、统率、点赞、装备
    user_open_like = "/api/?method=user.open_like",--点赞 sort= rank_key=
    user_rank_one_cards_info = "/api/?method=user.rank_one_cards_info",-- 查看卡牌 sort= rank_key= uid=
    active_hero_star_reward = "/api/?method=active.hero_star_reward", --reward_id 英雄之路领奖
    bandit_index = "/api/?method=bandit.index", --满天星
    bandit_get_reward = "/api/?method=bandit.get_reward", --满天星 reward_id
    server_bandit_index = "/api/?method=server_bandit.index", --满天星
    server_bandit_get_reward = "/api/?method=server_bandit.get_reward", --满天星 reward_id

    --公会战接口
    guild_gvg_index = "/api/?method=guild_gvg.index",--进入公会战 根据返回的sort来判断进入哪个阶段
    guild_gvg_donate_flag = "/api/?method=guild_gvg.donate_flag",--战前捐献战旗 count=100
    guild_gvg_join_battle = "/api/?method=guild_gvg.join_battle",--其他公会加入公会战
    guild_gvg_battle_info = "/api/?method=guild_gvg.battle_info",--工会战斗详情
    guild_gvg_attack = "/api/?method=guild_gvg.attack",--公会战，战斗  building_id=2006
    guild_gvg_open_building = "/api/?method=guild_gvg.open_building",--建筑详细 building_id=2006
    guild_gvg_embattle_doing = "/api/?method=guild_gvg.embattle_doing",--战前准备布阵阶段
    guild_gvg_select_building = "/api/?method=guild_gvg.select_building",--公会布阵选择地块 building_id: 1 建筑物id force: 0  是否强制, 0不强制, 1强制
    guild_gvg_remove_building = "/api/?method=guild_gvg.remove_building",--会长踢人  building_id = 1
    guild_gvg_attack = "/api/?method=guild_gvg.attack",--公会战战斗building_id: 1    建筑物id
    guild_gvg_buy_time = "/api/?method=guild_gvg.buy_time",--购买时间
    guild_gvg_buy_times = "/api/?method=guild_gvg.buy_times",--购买次数
    guild_gvg_show_log = "/api/?method=guild_gvg.show_log",--战争中显示log
    guild_gvg_buy_player_morale = "/api/?method=guild_gvg.buy_player_morale",--购买玩家的士气
    guild_gvg_buy_guild_morale = "/api/?method=guild_gvg.buy_guild_morale",--购买联盟士气
    association_reward_index = "/api/?method=association.reward_index",--公会战分配奖励  index
    association_reward_distribution = "/api/?method=association.reward_distribution",--分配奖励  参数: reward_id=1, target_uid=1
    guild_gvg_top_rank = "/api/?method=guild_gvg.top_rank",--参数:sort类型, page页数   sort =attacker | defender
    guild_gvg_give_up_building = "/api/?method=guild_gvg.give_up_building",--building_id = 1 放弃
    card_shop_open = "/api/?method=shop.card_shop_open", -- 月卡商店首页
    card_shop_buy = "/api/?method=shop.card_shop_buy", -- 月卡商店购买  -- 参数 shop_id=14 购买项

    active_group_index = "/api/?method=active.group_index",--团购首页
    active_group_active_index = "/api/?method=active.group_active_index",--团购活动接口
    active_group_active_buy = "/api/?method=active.group_active_buy",--购买接口  count=
    active_group_rank = "/api/?method=active.group_rank",--排名接口

    statistics_add_step = "/api/?method=user.add_step", -- 统计用户的步数   user_token=h11234567&step=1
    mine_index = "/api/?method=mine.index",-- 矿山
    mine_bidding = "/api/?method=mine.bidding", -- 出价   --参数 mid=1 & price=2101
    mine_mining =  "/api/?method=mine.mining", -- 采矿  -- 参数 mid=1
    mine_mining_quick = "/api/?method=mine.mining_quick", -- 加速 花钻石
    mine_miner_add_coin = "/api/?method=mine.miner_add_coin", -- 追加投资 参数 mid = 1

    get_xmw2_order = "/api/?method=payment.get_xmw2_order",  --熊猫玩支付数据请求接口
    statistics_add_step = "/api/?method=user.add_step", -- 统计用户的步数   user_token=h11234567&step=1

    foundation_show_available_funds = "/api/?method=foundation.show_available_funds",--看可够买基金
    foundation_activate = "/api/?method=foundation.activate",--激活基金  id=
    foundation_withdraw = "/api/?method=foundation.withdraw",--提取基金   id=

    server_active_recharge_index = "/api/?method=active.server_active_recharge_index",--开服充值活动
    server_active_recharge_receive = "/api/?method=active.server_active_recharge_receive",  --主动充值领取      参数 active_id         和active.active_recharge_receive一样
    server_foundation_show_available_funds = "/api/?method=server_foundation.show_available_funds",--看可够买基金
    server_foundation_activate = "/api/?method=server_foundation.activate",--激活基金  id=
    server_foundation_withdraw = "/api/?method=server_foundation.withdraw",--提取基金   id=

    wanted_wanted_ui = "/api/?method=wanted.wanted_ui",  -- 通缉进入接口
    wanted_wanted_fight = "/api/?method=wanted.wanted_fight",  -- 通缉战斗接口 Enemy_id
    wanted_help_fight = "/api/?method=wanted.help_fight",  -- 通缉协助战斗接口 'uid': 'enemy_id' 'help_time'
    wanted_wanted_award = "/api/?method=wanted.wanted_award",  -- 通缉领奖接口 'award_id' = 1
    wanted_wanted_help = "/api/?method=wanted.wanted_help",  -- 通缉领奖接口 'award_id' = 1
    gem_synthesis = "/api/?method=gem.synthesis", -- 宝石合成  参数 gem_id= gem_num=
    gem_upgrade = "/api/?method=gem.upgrade", -- 宝石升级  参数 gem_id    element_id=&element_id=&element_id=
    gem_resolve = "/api/?method=gem.resolve",--宝石分解 参数 gems  格式 gems=101_10&gems=102_20&gems=103_30    101是配置id   10为数量
    equip_enchant = "/api/?method=equip.enchant", -- 装备附魔接口， 参数： equip_id ，temp
    equip_save_init_enchant = "/api/?method=equip.save_init_enchant", -- 装备附魔保留接口，参数：equip_id ，is_enchant
    equip_remove_enchant = "/api/?method=equip.remove_enchant",--移除附魔 equip_id
    card_rebirth = "/api/?method=cards.card_rebirth",  -- 卡牌重生  -card_id  卡牌id
    server_shop_show = "/api/?method=shop.server_shop_show", -- 新服商城进入接口
    server_shop_buy = "/api/?method=shop.server_shop_buy",    -- 新服商城购买接口 参数 shop_id
    server_exchange = "/api/?method=server_exchange.server_exchange",  -- 新服兑换活动进入接口
    show_server_exchange_options = "/api/?method=server_exchange.show_server_exchange_options", -- 新服兑换活动兑换接口
    -- 擂台战
    serverpk_team_battle = "/api/?method=servers_fight.team_battle",               -- 小组赛日界面
    serverpk_check_enemy_list = "/api/?method=servers_fight.check_enemy_list",           -- 查看对手列表
    serverpk_group_combat_log = "/api/?method=servers_fight.group_combat_log",          -- 小组赛查看战斗记录
    serverpk_group_replay = "/api/?method=servers_fight.group_replay",               -- 小组赛战斗记录回放
    serverpk_team_battle_rank = "/api/?method=servers_fight.team_battle_rank",           -- 小组赛排行榜
    serverpk_team_final_battle_rank = "/api/?method=servers_fight.final_battle_rank",            -- 决赛服务器排行榜
    serverpk_team_final_combat_log =  "/api/?method=servers_fight.final_combat_log",            -- 决赛查看战斗记录
    serverpk_team_final_replay = "/api/?method=servers_fight.final_replay",                 -- 决赛战斗回放

    --押镖
    escort_index = "/api/?method=escort.index",--押镖入口
    escort_shop_index = "/api/?method=escort.shop_index",--镖局商店
    escort_my_goods = "/api/?method=escort.my_goods",--货仓
    escort_shop_fresh = "/api/?method=escort.shop_fresh",--刷新商店  免费
    escort_coin_shop_fresh = "/api/?method=escort.coin_shop_fresh",--钻石刷新
    escort_team_index = "/api/?method=escort.team_index",--队伍列表
    escort_join_goods_team = "/api/?method=escort.join_goods_team",--加入队伍    goods_id= &captain_uid=
    escort_employ = "/api/?method=escort.employ",--雇佣NPC
    escort_create_goods_team = "/api/?method=escort.create_goods_team",--创建队伍   goods_id=    buff_sort=
    escort_quit_goods_team = "/api/?method=escort.quit_goods_team",--队员退出队伍
    escort_disband_goods_team = "/api/?method=escort.disband_goods_team",--队长解散队伍
    escort_buy_goods = "/api/?method=escort.buy_goods",--买物品     goods_id=
    escort_check_other_team = "/api/?method=escort.check_other_team",--查看其他队伍  captain_uid=
    escort_check_my_team = "/api/?method=escort.check_my_team",--查看我的队伍
    escort_kick_goods_team = "/api/?method=escort.kick_goods_team",--队长踢人  team_uid=
    escort_start_sail = "/api/?method=escort.start_sail",--开始运货
    escort_map_index = "/api/?method=escort.map_index",--开始运货
    escort_point_shop = "/api/?method=escort.point_shop",--押镖积分商店
    escort_point_buy = "/api/?method=escort.point_buy",--积分商店购买
    escort_upgrade_vehicle_buff = "/api/?method=escort.upgrade_vehicle_buff",--升级货船 item_id=
    escort_open_map = "/api/?method=escort.open_map",--打开地图  map_id
    escort_auto_start_sail = "/api/?method=escort.auto_start_sail",--自动起航 auto_start_sail= 自动1，不自动 0
    escort_rob_index = "/api/?method=escort.rob_index",--抢劫界面
    escort_create_rob_team = "/api/?method=escort.create_rob_team",--创建抢劫队伍
    escort_join_rob_team = "/api/?method=escort.join_rob_team",--加入抢劫队伍    captain_uid =
    escort_kick_rob_team = "/api/?method=escort.kick_rob_team",--队长T人        team_uid =
    escort_quit_rob_team = "/api/?method=escort.quit_rob_team",--退出抢劫队伍
    escort_disband_rob_team = "/api/?method=escort.disband_rob_team",--解散抢劫队伍
    escort_check_my_rob_team = "/api/?method=escort.check_my_rob_team",--查看我的打劫队伍
    escort_rob = "/api/?method=escort.rob",--抢劫  vehicle_captain_uid =
    escort_world_message = "/api/?method=escort.world_message",--消息
    escort_battle_message = "/api/?method=escort.battle_message",--战报消息
    escort_battle_log = "/api/?method=escort.battle_log",--3v3战报列表 key=
    escort_battle_replay = "/api/?method=escort.battle_replay",--战斗回放  battle_log=

    escort_quick_join = "/api/?method=escort.quick_join",--快速加入     goods_id =
    escort_refresh_buff = "/api/?method=escort.refresh_buff",--刷新镖车      captain_uid=
    escort_refresh_vehicle_buff = "/api/?method=escort.refresh_vehicle_buff",--刷新镖车属性
    escort_arrive = "/api/?method=escort.arrive",--货物到达
    escort_vehicle_ready = "/api/?method=escort.vehicle_ready",--准备
    escort_cancel_vehicle_ready = "/api/?method=escort.cancel_vehicle_ready",--取消准备


    one_piece_index = "/api/?method=one_piece.index", -- 海贼王首页
    one_piece_open_roulette = "/api/?method=one_piece.open_roulette", -- 海贼王探索一次
    one_piece_open_roulette10 = "/api/?method=one_piece.open_roulette10", -- 海贼王探索十次
    one_piece_info = "/api/?method=one_piece.info", -- 海贼王擂台信息
    one_piece_exchange = "/api/?method=one_piece.exchange", -- 海贼王兑换接口  id=1
    one_piece_exchange_index = "/api/?method=one_piece.exchange_index", -- 海贼王兑换首页
    one_piece_step_reward = "/api/?method=one_piece.step_reward", -- 海贼王阶段领奖  step=1

    active_hero_road_buy_times = "/api/?method=active.hero_road_buy_times", -- 英雄之路购买次数  chapter=
    open_door_index = "/api/?method=open_door.index", --开门活动
    open_door_open = "/api/?method=open_door.open", --开门活动
    maze_index = "/api/?method=maze.index", --回廊活动
    maze_start = "/api/?method=maze.start", -- 回廊开始接口
    maze_open_next_layer = "/api/?method=maze.open_next_layer", -- sort == 1  进入下一层 参数: stage_id
    maze_open_stage = "/api/?method=maze.open_stage", -- sort == 2  攻打stage  参数: stage_id
    maze_open_shop = "/api/?method=maze.open_shop", -- sort == 3  获取shop   参数: stage_id  pos: 0, 第一个奖励, 1, 第二个, 2, 第三个
    maze_use_item = "/api/?method=maze.use_item", --使用道具  参数: item_id
    maze_map_fight_and_enemy = "/api/?method=maze.map_fight_and_enemy",--获取怪物  参数: stage_id
    maze_battle_replay = "/api/?method=maze.battle_replay",--回廊回放  layer = index =
    maze_get_user_info = "/api/?method=maze.get_user_info",--查看回廊玩家信息 uid = layer =

    magic_school_index = "/api/?method=magic_school.index",  --  火焰杯 主页
    magic_school_open_contract = "/api/?method=magic_school.open_contract",    -- 签订契约 contract_id = 1
    magic_school_point_reward = "/api/?method=magic_school.point_reward",   -- 契约积分领奖  reward_id = 1-4

    pyramid_index = "/api/?method=pyramid.index",   -- 金字塔主页
    pyramid_get_up_morale = "/api/?method=pyramid.get_up_morale",   -- 鼓舞士气
    pyramid_buy_challenge_times = "/api/?method=pyramid.buy_challenge_times",  -- 购买攻击次数
    pyramid_go_fight = "/api/?method=pyramid.go_fight",  -- 去战斗  floor 层数
    pyramid_pyramid_battle = "/api/?method=pyramid.pyramid_battle",  -- 去战斗  floor 层数  pos 位置
    pyramid_user_info = "/api/?method=pyramid.user_info", -- 查看玩家信息
    pyramid_battle_log = "/api/?method=pyramid.pyramid_battle_log", -- 查看金字塔日志
    pyramid_battle_replay = "/api/?method=pyramid.pyramid_battle_replay", -- 查看金字塔日志回放  key ==
    pyramid_quick_floor =  "/api/?method=pyramid.pyramid_quick_floor", -- 查看金字塔日志回放  key ==
    pyramid_wanted_index = "/api/?method=pyramid.pyramid_wanted_index",   -- 金字塔悬赏主页
    refresh_pyramid_wanted = "/api/?method=pyramid.refresh_pyramid_wanted",   -- 金字塔悬赏 任务刷新
    get_wanted_reward = "/api/?method=pyramid.get_wanted_reward",   -- 金字塔悬赏 领奖的接口 参数为wanted_id

    enemy_show_enemys = "/api/?method=enemy.show_enemys", -- 仇人列表
    enemy_give_up_enemy = "/api/?method=enemy.give_up_enemy", -- 删除仇人  enemy_id=h19092412
    enemy_care_enemy = "/api/?method=enemy.care_enemy", -- 关注仇人  enemy_id=h19092412

    magic_school_lucky_contract = "/api/?method=magic_school.lucky_contract", -- 幸运契约信息
    magic_school_get_back_sort_num = "/api/?method=magic_school.get_back_sort_num", -- 我的契约信息 (前100条)
    magic_school_get_page_num = "/api/?method=magic_school.get_page_num", -- 获取契约信息 (前100条)

    open_door_rank = "/api/?method=open_door.rank",--参数sort 值为combat: 战斗力, pyramid:金字塔, escort: 运镖, maze:回廊     参数page
    open_door_battle = "/api/?method=open_door.battle",--星际穿越的第一场战斗
    king_find_caller = "/api/?method=king.find_caller", -- 查找邀请人信息  tid =
    king_add_caller = "/api/?method=king.add_caller", -- 添加邀请人信息  tid =
    king_get_king_reward = "/api/?method=king.get_king_reward", -- 接受自己的老玩家回归奖励
    king_show_reward_interface = "/api/?method=king.show_reward_interface", -- 邀请者的所有奖励
    king_show_reward_single = "/api/?method=king.show_reward_single", -- 查询我邀请的某个老玩家可领的奖励
    king_get_reward_single = "/api/?method=king.get_reward_single", -- 领我邀请的某个老玩家可领的奖励
    king_show_reward_total = "/api/?method=king.show_reward_total", -- 总积分奖励列表
    king_get_reward_total = "/api/?method=king.get_reward_total", -- 领总积分奖励

    shop_open_metal_shop = "/api/?method=shop.open_metal_shop", -- 精炼石
    shop_buy_metal_shop = "/api/?method=shop.buy_metal_shop", -- 精炼石  shop_id=1&count=1
    cards_activate_destiny = "/api/?method=cards.activate_destiny",--阵型命运解锁  position
    cards_activate_assistant_effect = "/api/?method=cards.activate_assistant_effect",--阵型助威激活  position
    cards_refresh_assistant_effect = "/api/?method=cards.refresh_assistant_effect",--阵型助威属性刷新 参数: lock值为'ability1'基础, 'ability2'升级后, 'card'卡牌     pos位置    retain保存为1 刷新为0
    cards_assistant_effect_uplevel = "/api/?method=cards.assistant_effect_uplevel",--助威升级接口  参数: pos: 0-9
    public_land_index = "/api/?method=public_land.index",-- 新无主之地首页
    public_land_sow_seed = "/api/?method=public_land.sow_seed",-- 种植的接口 map_id=3&seed_id=1，参数map_id是地块的id
    public_land_refresh_worker = "/api/?method=public_land.refresh_worker",-- 刷新工人的接口 map_id=1
    public_land_cancel_sow_seed = "/api/?method=public_land.cancel_sow_seed",-- 取消种植 map_id=1
    public_land_get_harvest_reward = "/api/?method=public_land.get_harvest_reward",-- 收获接口 map_id=1
    public_land_visit_one_friend = "/api/?method=public_land.visit_one_friend",-- 去拜访的接口 uid=
    public_land_visit_friend_list = "/api/?method=public_land.visit_friend_list",-- 去拜访的接口 uid=
    public_land_send_blessing = "/api/?method=public_land.send_blessing",-- 送祝福 uid=&map_id=
    public_land_go_rob_index = "/api/?method=public_land.go_rob_index",-- 掠夺
    public_land_go_steal_rob = "/api/?method=public_land.go_steal_rob",-- 掠夺 uid&map_id&type=1  1 偷取 2 抢夺
    public_land_go_revenge = "/api/?method=public_land.go_revenge",-- 复仇 uid&index
    public_land_get_battle_log = "/api/?method=public_land.get_battle_log",-- log
};
--[[--
    game_url:
        游戏逻辑接口，访问的是各个应用服务器，没有固定域名和ip
    dataosha_url_config:
        访问团战服务器，没固定域名和ip
    login_url_config:
        用于登录的服务器，域名和ip基本不变（不保证
        sdk的登录和付费都放在login_url_config表中
]]
local dataosha_url_config = {
    battle_royale_join_game = "/?method=join_game", -- 大逃杀报名
    battle_royale_attack = "/?method=attack", -- 大逃杀 game_id=1001&round_id=2&forward=3
    battle_royale_start = "/?method=start", -- 大逃杀
}
--[[--
    game_url:
        游戏逻辑接口，访问的是各个应用服务器，没有固定域名和ip
    dataosha_url_config:
        访问团战服务器，没固定域名和ip
    login_url_config:
        用于登录的服务器，域名和ip基本不变（不保证
        sdk的登录和付费都放在login_url_config表中
]]
local login_url_config = {  -- 走master服务器的配置
    new_account = "/login/?method=new_account", -- 如果用户没有账户，给他一个临时的
    user_login = "/login/?method=login",--用户注册 user_name=ddd&password=123
    user_server_list = "/login/?method=get_user_server_list",--前端通过保存的account，获得用户的server_list数据
    user_server_list_huawei = "/login/?method=get_user_server_list_huawei",--前端通过保存的account，获得用户的server_list数据
    user_register = "/login/?method=register",--用户注册 role=1&show_name=
    -- loading = "/login/?method=loading",--
    -- loading_for_test = "/login/?method=loading_for_test",

    --一下url只能放在login_url_config里
    get_vivo_order_id = "/pay/?method=get_vivo_order",--为vivo使用，去服务端取订单号的接口
    get_query_order = "/pay/?method=query_vivo_order",--为vivo使用，去服务端查询订单是否成功的接口
    get_jinli_order = "/pay/?method=get_jinli_order",--金立独家专享
    get_user_id = "/login/?method=platform_access",--通过code取userID，app_type 0:1 channel:cmge
    pay_respon_url = "/pay/?method=get_notify_urls",
}

-- 添加强制更新请求参数
-- require("game_version_config");
util.reload("game_version_config")
--[[--
    获得完整的url
]]
function game_url.getUrlForKey(key)
    --每个请求后加一个随机数
    local random = math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local randomNum = math.random(1,99999)--从里面随机取一个
    local url = nil;
    print( game_url[key], key)
    if game_url[key] then
        url = service_url .. game_url[key];
    elseif login_url_config[key] then
        url = master_url .. login_url_config[key];
    elseif dataosha_url_config[key] then
        url = dataosha_url .. dataosha_url_config[key];
    end
    if url ~= nil then
        url = url .. "&user_token=" .. user_token .. "&mk=" .. mark_user_login_mk .. "&rand=" .. randomNum;
        -- url = url .. "&user_token=" .. "ena13798042" .. "&backdoor=52996"
        url = url .. "&version=" .. CLIENT_VERSION;
        url = url .. "&pt=" .. device_platform .. "&device_mark=" .. device_mark .. "&platform_channel=" .. platform_channel
        if util_system.getTotalMemory then
            url = url .. "&device_mem=" .. tostring(util_system:getTotalMemory())
        end
        if m_id_7ku then
            url = url .. "&m_id_7ku=" .. tostring(m_id_7ku)
        end

    end
    return url;
end

return game_url;
