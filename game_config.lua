---游戏配置

-- 白 绿 蓝 紫 橙 红 黑 彩
HERO_QUALITY_COLOR_TABLE=
{
    {color = ccc3(112,112,112),img1 = "public_hui.png",img2 = "public_huikuang.png",card_img = "card_q_bgGrey.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[1],rgba = "ffff0000"},
    {color = ccc3(0,255,0),img1 = "public_lv.png",img2 = "public_lvkuang.png",card_img = "card_q_bgGreen.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[2],rgba = "ff00ff00"},
    {color = ccc3(0,0,255),img1 = "public_lan.png",img2 = "public_lankuang.png",card_img = "card_q_bgBlue.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[3],rgba = "ff0000ff"},
    {color = ccc3(128,0,128),img1 = "public_zi.png",img2 = "public_zikuang.png",card_img = "card_q_bgPurple.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[4],rgba = "ff9b0dc1"},
    {color = ccc3(251,168,0),img1 = "public_cheng.png",img2 = "public_chengkuang.png",card_img = "card_q_bgOrange.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[5],rgba = "fffba700"},
    {color = ccc3(255,0,0),img1 = "public_hong.png",img2 = "public_hongkuang.png",card_img = "card_q_bgRed.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[6],rgba = "ffff0000"},
    {color = ccc3(255,255,0),img1 = "public_jin.png",img2 = "public_jinkuang.png",card_img = "card_q_bgYellow.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[7],rgba = "ffffff00"},
    {color = ccc3(255,255,0),img1 = "public_jin.png",img2 = "public_caikuang.png",card_img = "card_q_bgYellow.png",name=string_helper.game_config.HERO_QUALITY_COLOR_TABLE[8],rgba = "ffffff00"},
}

CARD_SORT_TAB = {
    {sortName=string_helper.game_config.CARD_SORT_TAB[1],sortType="default"},
    {sortName=string_helper.game_config.CARD_SORT_TAB[2],sortType="quality"},
    {sortName=string_helper.game_config.CARD_SORT_TAB[3],sortType="lv"},
    {sortName=string_helper.game_config.CARD_SORT_TAB[4],sortType="profession"},
}

EQUIP_SORT_TAB = {
    {sortName=string_helper.game_config.EQUIP_SORT_TAB[1],sortType="default"},
    {sortName=string_helper.game_config.EQUIP_SORT_TAB[2],sortType="quality"},
    {sortName=string_helper.game_config.EQUIP_SORT_TAB[3],sortType="lv"},
    {sortName=string_helper.game_config.EQUIP_SORT_TAB[4],sortType="sort"},
}

GEM_SORT_TAB = 
{
    {sortName=string_helper.game_config.GEM_SORT_TAB[1],sortType="default"},
    {sortName=string_helper.game_config.GEM_SORT_TAB[2],sortType="quality"},
    {sortName=string_helper.game_config.GEM_SORT_TAB[3],sortType="count"},
    {sortName=string_helper.game_config.GEM_SORT_TAB[4],sortType="sort"},
}

HERO_QUALITY_BG_IMG=
{
    "yxlb_baidi.png",
    "yxlb_lvdi.png",
    "yxlb_landi.png",
    "yxlb_zidi.png",
    "yxlb_chengdi.png",
    "yxlb_hongdi.png",
    "yxlb_MAXdi.png",
}

LEADER_SKILL_TREE_TABLE = 
{
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[1],iconBg = "icon_bg_shandian.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[2],iconBg = "icon_bg_lieyan.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[3],iconBg = "icon_bg_hanbing.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[4],iconBg = "icon_bg_liren.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[5],iconBg = "icon_bg_guwu.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[6],iconBg = "icon_bg_zuzhou.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[7],iconBg = "icon_bg_fangyu.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[8],iconBg = "icon_bg_zhiliao.png"},
    {name = string_helper.game_config.LEADER_SKILL_TREE_TABLE[9],iconBg = "icon_bg_lieyan.png"},
}

EQUIP_TYPE_TABLE =
{
    weapon={1,string_helper.game_config.EQUIP_TYPE_TABLE[1]},
    accessories={2,string_helper.game_config.EQUIP_TYPE_TABLE[2]},
    armor={3,string_helper.game_config.EQUIP_TYPE_TABLE[3]},
    shoes={4,string_helper.game_config.EQUIP_TYPE_TABLE[4]},
    debris={0,string_helper.game_config.EQUIP_TYPE_TABLE[5]},
}

GEM_TYPE_TABLE = string_helper.game_config.GEM_TYPE_TABLE

TEAM_POS_OPEN_TAB = {open10 = {0,1,0,0,0,0,0,0,0},open11 = {0,1,0,0,0,0,1,0,0},open12 = {0,1,0,0,0,0,1,1,0},open13 = {0,1,0,0,0,0,1,1,1},
                        open20 = {0,1,1,0,0,0,0,0,0},open21 = {0,1,1,0,0,0,1,0,0},open22 = {0,1,1,0,0,0,1,1,0},open23 = {0,1,1,0,0,0,1,1,1},
                        open30 = {0,1,1,0,1,0,0,0,0},open31 = {0,1,1,0,1,0,1,0,0},open32 = {0,1,1,0,1,0,1,1,0},open33 = {0,1,1,0,1,0,1,1,1},
                        open40 = {0,1,1,0,1,1,0,0,0},open41 = {0,1,1,0,1,1,1,0,0},open42 = {0,1,1,0,1,1,1,1,0},open43 = {0,1,1,0,1,1,1,1,1},
                        open50 = {1,1,1,1,1,1,0,0,0},open51 = {1,1,1,1,1,1,1,0,0},open52 = {1,1,1,1,1,1,1,1,0},open53 = {1,1,1,1,1,1,1,1,1},
                        }
TEAM_LOCK_TIPS_TAB = {{lockImg = "dw_jiesuo_3.png",openLevel = 10},{lockImg = "dw_jiesuo_1.png",openLevel = 0},{lockImg = "dw_jiesuo_1.png",openLevel = 0},
                        {lockImg = "dw_jiesuo_3.png",openLevel = 10},{lockImg = "dw_jiesuo_1.png",openLevel = 5},{lockImg = "dw_jiesuo_2.png",openLevel = 10},
                        {lockImg = "dw_jiesuo_4.png",openLevel = 18},{lockImg = "dw_jiesuo_5.png",openLevel = 22},{lockImg = "dw_jiesuo_6.png",openLevel = 25}
                        }

-- 1：武器，2：饰品，3：防具，4：鞋子，0：杂物（不可装备）
EQUIP_TYPE_NAME_TABLE =
{
    type_1 = string_helper.game_config.EQUIP_TYPE_NAME_TABLE[1],
    type_2 = string_helper.game_config.EQUIP_TYPE_NAME_TABLE[2],
    type_3 = string_helper.game_config.EQUIP_TYPE_NAME_TABLE[3],
    type_4 = string_helper.game_config.EQUIP_TYPE_NAME_TABLE[4],
    type_0 = string_helper.game_config.EQUIP_TYPE_NAME_TABLE[5],
}

COMMANDER_ABILITY_TABLE = 
{
    {attrName = "patk",typeValue = 1},
    {attrName = "matk",typeValue = 2},
    {attrName = "def",typeValue = 3},
    {attrName = "speed",typeValue = 4},
    {attrName = "hp",typeValue = 5},
    {attrName = "hp2",typeValue = 5},
    {attrName = "hp3",typeValue = 5},
}

COMBAT_BASE_ABILITY_TABLE = 
{
    {attrName = "patk",typeValue = 1},
    {attrName = "matk",typeValue = 2},
    {attrName = "def",typeValue = 3},
    {attrName = "speed",typeValue = 4},
    {attrName = "hp",typeValue = 5},
}

COMBAT_ABILITY_TABLE = 
{
    gem = {"firedfs","waterdfs","winddfs","earthdfs"},
    card = {"fire","water","wind","earth","fire_dfs","water_dfs","wind_dfs","earth_dfs"},
    card_evo = {"201","202","203","204","301","302","303","304"},
    commander_attr_ext = {firedfs = "fire_dfs",waterdfs = "water_dfs",winddfs = "wind_dfs",earthdfs = "earth_dfs"},
}

-- 1物攻 2魔攻 3防御 4速度 5生命 6暴击 7命中 8减伤 9闪避 10施放战前技概率
-- 201火攻 202水攻 203风攻 204地攻 301火防 302水防 303风防 304地防
PUBLIC_ABILITY_TABLE = 
{
    ability_1   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[1],icon = "public_icon_phsc.png",attrName = "patk",typeValue = 1},
    ability_2   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[2],icon = "public_icon_mgc.png",attrName = "matk",typeValue = 2},
    ability_3   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[3],icon = "public_icon_dfs.png",attrName = "def",typeValue = 3},
    ability_4   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[4],icon = "public_icon_speed.png",attrName = "speed",typeValue = 4},
    ability_5   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[5],icon = "public_icon_hp.png",attrName = "hp",typeValue = 5},
    ability_6   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[6],icon = "public_icon_crit.png",attrName = "crit",typeValue = 6},
    ability_7   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[7],icon = "public_icon_hr.png",attrName = "hr",typeValue = 7},
    ability_8   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[8],icon = "public_icon_subhurt.png",attrName = "subhurt",typeValue = 8},
    ability_9   = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[9],icon = "public_icon_dr.png",attrName = "dr",typeValue = 9},
    ability_10  = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[10],icon = "public_icon_probability.png",attrName = "probability",typeValue = 10},
    ability_201 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[11],icon = "public_icon_hg.png",attrName = "fire",typeValue = 201},
    ability_202 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[12],icon = "public_icon_bg.png",attrName = "water",typeValue = 202},
    ability_203 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[13],icon = "public_icon_fg.png",attrName = "wind",typeValue = 203},
    ability_204 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[14],icon = "public_icon_dg.png",attrName = "earth",typeValue = 204},
    ability_301 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[15],icon = "public_icon_hf.png",attrName = "fire_dfs",typeValue = 301},
    ability_302 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[16],icon = "public_icon_bf.png",attrName = "water_dfs",typeValue = 302},
    ability_303 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[17],icon = "public_icon_ff.png",attrName = "wind_dfs",typeValue = 303},
    ability_304 = {name = string_helper.game_config.PUBLIC_ABILITY_TABLE[18],icon = "public_icon_df.png",attrName = "earth_dfs",typeValue = 304},
}

PUBLIC_ABILITY_NAME_TABLE = 
{
    patk        = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[1],icon = "public_icon_phsc.png",attrName = "patk",typeValue = 1},
    matk        = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[2],icon = "public_icon_mgc.png",attrName = "matk",typeValue = 2},
    def         = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[3],icon = "public_icon_dfs.png",attrName = "def",typeValue = 3},
    speed       = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[4],icon = "public_icon_speed.png",attrName = "speed",typeValue = 4},
    hp          = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[5],icon = "public_icon_hp.png",attrName = "hp",typeValue = 5},
    fire        = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[6],icon = "public_icon_hg.png",attrName = "fire",typeValue = 201},
    water       = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[7],icon = "public_icon_bg.png",attrName = "water",typeValue = 202},
    wind        = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[8],icon = "public_icon_fg.png",attrName = "wind",typeValue = 203},
    earth       = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[9],icon = "public_icon_dg.png",attrName = "earth",typeValue = 204},
    fire_dfs    = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[10],icon = "public_icon_hf.png",attrName = "fire_dfs",typeValue = 301},
    water_dfs   = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[11],icon = "public_icon_bf.png",attrName = "water_dfs",typeValue = 302},
    wind_dfs    = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[12],icon = "public_icon_ff.png",attrName = "wind_dfs",typeValue = 303},
    earth_dfs   = {name = string_helper.game_config.PUBLIC_ABILITY_NAME_TABLE[13],icon = "public_icon_df.png",attrName = "earth_dfs",typeValue = 304},
}

BUFF_SORT_IMG = {
    {name = string_helper.game_config.BUFF_SORT_IMG[1],title = "dart_ship_title1.png",icon = "dart_moto_icon_1.png",ship = "dart_moto_1.png",spoiler= "dart_moto_spoiler1.png",scale = 1,des = string_helper.game_config.BUFF_SORT_IMG_DES[1]},
    {name = string_helper.game_config.BUFF_SORT_IMG[2],title = "dart_ship_title2.png",icon = "dart_moto_icon_2.png",ship = "dart_moto_2.png",spoiler= "dart_moto_spoiler2.png",scale = 1,des = string_helper.game_config.BUFF_SORT_IMG_DES[2]},
    {name = string_helper.game_config.BUFF_SORT_IMG[3],title = "dart_ship_title3.png",icon = "dart_moto_icon_3.png",ship = "dart_moto_3.png",spoiler= "dart_moto_spoiler2.png",scale = 1,des = string_helper.game_config.BUFF_SORT_IMG_DES[3]},
    {name = string_helper.game_config.BUFF_SORT_IMG[4],title = "dart_ship_title4.png",icon = "dart_moto_icon_4.png",ship = "dart_moto_4.png",spoiler= "dart_moto_spoiler3.png",scale = 1,des = string_helper.game_config.BUFF_SORT_IMG_DES[4]},
    {name = string_helper.game_config.BUFF_SORT_IMG[5],title = "dart_ship_title5.png",icon = "dart_moto_icon_5.png",ship = "dart_moto_5.png",spoiler= "dart_moto_spoiler2.png",scale = 1,des = string_helper.game_config.BUFF_SORT_IMG_DES[5]},
}

--复活技能
RELIFE_SKILL_NAME = 
{
    "dracula_s3",
}

public_config = {
    anim_scale = 0.8,
    anim_durition = 1/24,
    action_durition = 0.07,
    action_durition_temp = 0.07,
    action_rythm = 0.5,
    battleTickPause = false,
}

-- 排行榜
rank_type_name =
{
    rank_level = "rank_level",  -- 等级排行榜
    rank_combat = "rank_combat",  -- 战力排行榜
    rank_boss = "rank_boss",  -- boss战排行榜
    rank_activity = "active_top",  -- 活动排行榜
    rank_search = "city",  -- 探索排行榜
    rank_elite_level = "city",  -- 探索排行榜
    arena_top = "arena_top",  -- 竞技场排行榜
    active_top = "active_top", -- 生存大考验排行榜
    rank_guide = "association_guild_all", -- lian
}

anim_label_name_cfg = 
{
    dengchang = "dengchang",        -- 登场
    daiji = "daiji",
    qianjin = "qianjin",            -- 前进
    qianjin2 = "qianjin2",
    gongji1 = "gongji1",
    gongji2 = "gongji2",
    gongji3 = "gongji3",
    gongji4 = "gongji4",
    mofa = "mofa",
    beiji = "beiji1",
    siwang = "siwang",
    tibu = "tibu",                  -- 替补
    houtui = "houtui",              -- 后退
    qishoumofa = "qishoumofa",      -- 起手魔法
    beiji2 = "beiji2",
    shuaidao = "shuaidao",          -- 摔倒
    zhaohuan = "zhaohuan",          -- 召唤
    shengli = "shengli",            -- 胜利
    dafei1 = "dafei1",              -- 打飞
    dafei2 = "dafei2",    
}

DEBUG = 0

http_request_method =
{
    GET = "GET",
    POST = "POST",
}

GLOBAL_TOUCH_PRIORITY = -130;

TYPE_FACE_TABLE = {
    Arial_BoldMT = "Arial-BoldMT";
}

--------------------------------------  config data start --------------------------------------
game_config_field = 
{
    --海外独有
    gacha_active = "gacha_active",--概率激增
    updating = "updating",
    updating_tips = "updating_tips",
    buykubi_android = "buykubi_android",
    ---------
    map = "map",
    map_title_detail = "map_title_detail",
    map_random_event = "map_random_event",
    map_main_story = "map_main_story",
    map_fight = "map_fight",
    enemy_detail = "enemy_detail",
    cityid_cityorderid = "cityid_cityorderid",
    formation = "formation",
    leader_skill = "leader_skill",
    character_detail = "character_detail",
    skill_detail = "skill_detail",
    leader_skill_tree = "leader_skill_tree",
    leader_skill_develop = "leader_skill_develop",
    character_base = "character_base",
    character_base_rate = "character_base_rate",
    character_train = "character_train",
    school_train_time_config = "school_train_time_config",
    school_train_type_config = "school_train_type_config",
    building_base_school = "building_base_school",
    building_mine = "building_mine",
    character_strengthen = "character_strengthen",
    equip = "equip",
    equip_evolution = "equip_evolution",
    equip_max_strongthen = "equip_max_strongthen",
    equip_strongthen = "equip_strongthen",
    building_base_harbor = "building_base_harbor",
    building_base_laboratory = "building_base_laboratory",
    building_factory = "building_factory",
    building_harbor = "building_harbor",
    building_hospital = "building_hospital",
    building_laboratory = "building_laboratory",
    building_school = "building_school",
    enemy_mine = "enemy_mine",
    food_mine = "food_mine",
    metal_mine = "metal_mine",
    middle_resource = "middle_resource",
    role = "role",
    skill_learn = "skill_learn",
    skill_levelup = "skill_levelup",
    gacha = "gacha",
    middle_map = "middle_map",
    middle_mine = "middle_mine",
    middle_building_mine = "middle_building_mine",
    middle_boss = "middle_boss",
    guild = "guild",
    guild_client = "guild_client",
    guild_shop = "guild_shop",
    daily_award = "daily_award",
    daily_award_loop = "daily_award_loop",--循环签到
    guild_funtion = "guild_funtion",--公会建筑
    guild_tech = "guild_tech",--公会科技
    drama = "drama",
    item = "item",
    role_detail = "role_detail",
    role_skill = "role_skill",
    chapter = "chapter",
    resource_detail = "resource_detail",
    building = "building",
    arena_shop = "arena_shop",
    arena_award = "arena_award",
    shop = "shop",
    vipguide = "vip_guide",  -- 消费计划
    guide = "guide",
    loading = "loading",
    loadingtips = "loadingtips",
    charge = "charge",
    reward_daily = "reward_daily",
    reward_once = "reward_once",
    code = "code",
    exchange = "exchange",
    combat_base = "combat_base",
    combat_skill = "combat_skill",
    active_chapter = "active_chapter",
    active_detail = "active_detail",
    guide_team = "guide_team",
    race = "race",
    random_last_name = "random_last_name",
    random_first_name = "random_first_name",
    occupation = "occupation",
    guide_button_open = "guide_button_open",
    guide_button_open_new = "guide_button_open_new",
    button_open = "button_open",
    character_exchange = "character_exchange",
    dirt_shop = "dirt_shop",
    error_cfg = "error",
    active_cfg = "active",
    world_boss = "world_boss",
    suit = "suit",
    world_boss_reward = "world_boss_reward",
    vip = "vip",
    chain = "chain",
    wanted = "wanted",
    month_award = "month_award",
    dailyscore = "dailyscore",
    active_fight_forever = "active_fight_forever",
    character_train_position = "character_train_position",
    pay = "pay",
    vip_shop = "vip_shop",
    online_award = "online_award",
    evolution = "evolution",
    evolution_3 = "evolution_3",
    evolution_4 = "evolution_4",
    evolution_5 = "evolution_5",
    character_book = "character_book",
    arena_award_milestone = "arena_award_milestone",
    character_train_rate = "character_train_rate",
    character_train_time = "character_train_time",
    exchange_card = "exchange_card",
    reward_diary = "reward_diary",
    diaryscore = "diaryscore",
    commander_recipe = "commander_recipe",
    commander_type = "commander_type",
    opening = "opening",
    assistant = "assistant",
    adver = "adver",
    server_adver = "server_adver",
    level_gift = "level_gift",
    equip_exchange = "equip_exchange",
    equip_st = "equip_st",
    month_award_coin = "month_award_coin",--充值签到
    month_award_coin_loop = "month_award_coin_loop",--循环豪华签到
    commander_level = "commander_level",
    resoucequality = "resoucequality",
    request_code = "request_code",
    whats_inside = "whats_inside",
    equip_book = "equip_book",
    gacha_gift = "gacha_gift",
    server_hero = "server_hero",--新服限时神将
    Integration_shop = "integration_shop",
    ranking = "ranking",
    inreview = "inreview",
    server_inreview = "server_inreview",
    notice_active = "notice_active",
    integration_world = "integration_world",
    auto_sweep = "auto_sweep",
    guild_boss = "guild_boss",--公会boss
    week_award = "week_award",
    character_break = "character_break",
    character_break_new = "character_break_new",
    break_control = "break_control",
    omni_exchange = "omni_exchange",
    treasure = "treasure",--罗杰的宝藏
    item_recipe = "item_recipe",
    item_recipe_show = "item_recipe_show",
    map_treasure_detail_battle = "map_treasure_detail_battle",--宝藏NPC战斗配置
    fight_treasure = "fight_treasure",--宝藏战斗配置
    player_boss = "player_boss",
    roulette = "roulette",--转盘
    roulette_rank_reward = "roulette_rank_reward",--转盘
    roulette_reward = "roulette_reward",--转盘
    book_character = "book_character", -- 卡牌图鉴
    book_equip = "book_equip", -- 装备图鉴
    tree_shop = "tree_shop",
    active_recharge = "active_recharge",--充值活动
    active_show = "active_show",
    super_active = "super_active",
    super_all = "super_all",
    super_rich = "super_rich",
    face_icon = "face_icon",
    hero_chapter = "hero_chapter",
    star_reward = "star_reward",
    bandit = "bandit",
    gvg_mine = "gvg_mine",--公会战地图配置
    guild_fight_buy = "guild_fight_buy",
    guild_fight = "guild_fight",--gvg新建筑数据
    adver_guild = "adver_guild",--gvg玩法说明
    equip_gacha = "equip_gacha",--装备gacha
    adver_inheritance = "adver_inheritance",--传承页说明
    group_rank = "group_rank",
    group_score = "group_score",
    group_shop = "group_shop",
    group_show = "group_show",
    foundation = "foundation",
    deadandalive = "deadandalive",
    server_active_recharge = "server_active_recharge",
    gem = "gem", -- 宝石
    gem_base = "gem_base", -- 宝石
    enchant = "enchant", -- 装备附魔配置
    server_shop_show = "server_shop_show", -- 新服商城 
    server_exchange = "server_exchange", -- 新服兑换
    server_roulette = "server_roulette",
    server_roulette_rank_reward = "server_roulette_rank_reward",
    server_roulette_reward = "server_roulette_reward",
    server_bandit = "server_bandit",
    server_foundation = "server_foundation",
    one_piece = "one_piece",
    one_piece_exchange = "one_piece_exchange",
    one_piece_rate = "one_piece_rate",
    one_piece_rank_reward = "one_piece_rank_reward",
    guide_manual = "guide_manual",     -- 帮助表
    escort = "escort",--押镖配置
    escort_opentime = "escort_opentime",
    escort_shop_charged = "escort_shop_charged",
    escort_buff = "escort_buff",
    escort_exchange = "escort_exchange",
    escort_shop_charged = "escort_shop_charged",
    escort_shop_free = "escort_shop_free",
    maze_mine = "maze_mine",
    maze_stage = "maze_stage",
    maze_buff = "maze_buff",
    maze_item = "maze_item",
    maze_reward = "maze_reward",
    maze_top_reward = "maze_top_reward",
    contract = "contract",  -- 火焰杯
    contract_detail = "contract_detail", -- 
    contract_score_reward = "contract_score_reward",    -- 火焰杯积分奖励
    contract_reward = "contract_reward",    -- 幸运大奖
    pyramid = "pyramid", -- 金字塔
    pyramid_level = "pyramid_level", -- 金字塔信息
    pyramid_wanted = "pyramid_wanted",  -- 金字塔悬赏
    pyramid_lucky = "pyramid_lucky", -- 幸运契约
    recall_reward = "recall_reward",  -- 王者归来充值奖励
    player_recall = "player_recall",  -- 老玩家奖励
    recall_charge_reward = "recall_charge_reward", -- 王者回归返利
    metal_core_shop = "metal_core_shop", -- 王者回归返利
    group_version = "group_version",
    destiny = "destiny",
    active_consume = "active_consume",--累计消耗
    assistant_random = "assistant_random",--助威属性随机表
    limit_hero_score = "limit_hero_score",  -- 限时神将
    farm_open = "farm_open",
    seed = "seed",
    worker = "worker",
}

game_config_data = {}
writablePath = CCFileUtils:sharedFileUtils():getWritablePath();
--[[--
    获得配置
    @return util_json 数据
]]
function getConfig(configFileName)
    if configFileName ~= nil or type(configFileName) == "string" then
        if game_config_data[configFileName] == nil then
            -- local readData = util.readFile(writablePath .. configFileName .. ".config");
            -- -- cclog("read config configFileName == " .. configFileName)
            -- if readData ~= nil and readData ~= "" then
            --     game_config_data[configFileName] = util_json:new(readData);
            --     -- cclog("read config data and return --------------------" .. configFileName);
            --     return game_config_data[configFileName];
            -- end
            local config_json = getConfigByName("config/" .. configFileName .. ".config",false)
            if config_json then
                game_config_data[configFileName] = config_json;
                -- cclog("return configFileName ==== " .. tostring(configFileName) .. ".config")
                return game_config_data[configFileName];
            else
                local config_json = getConfigByName("config/" .. configFileName .. ".configtea",true)
                if config_json then
                    game_config_data[configFileName] = config_json;
                    -- cclog("return configFileName ==== " .. tostring(configFileName) .. ".configtea")
                    return game_config_data[configFileName];
                end
            end
        else
            -- cclog("return --------------------" .. configFileName);
            return game_config_data[configFileName];
        end
    end
    cclog("configFileName ===is nill == " .. tostring(configFileName))
    return nil;
end

function deleteConfigData(configFileName)
    if configFileName then
        local tempCfg = game_config_data[configFileName]
        if tempCfg then
            tempCfg:delete();
            game_config_data[configFileName] = nil;
        end
    else
        for k,v in pairs(game_config_data) do
            v:delete();
        end
        game_config_data = {};
    end
end



-- ============================= cut of line ----------------------------

DOWNLOAD_BACKGROUND = false;
-- print("will search RESOURCE_ISNOHD  -------------------  ")

-- if RESOURCE_ISNOHD then
--     print("find RESOURCE_ISNOHD  -------------------  ", RESOURCE_ISNOHD)
--     DOWNLOAD_BACKGROUND = true
-- else
--     print("not find RESOURCE_ISNOHD  -------------------  ")
-- end

--------------------------------------  config data end --------------------------------------
