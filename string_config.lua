--- 游戏文字配置
--
local string_config = {
    m_name_err = "The name is already in use",      --姓名已被使用
    m_btn_cancel = "cancel", 
    m_btn_sure = "Confirm", 
    m_btn_think = "Let me think",
    m_btn_agree = "Agree",
    m_btn_reject = "Reject",
    m_btn_use = "use",
    m_btn_open = "Open",
    m_title_prompt = "Tips",
    m_btn_close = "close",
    m_operating_success = "operate succesful!",
    m_sel_hero = "Please select a hero!",
    m_hero_comp_success = "Hero synthetic success!",
    m_hero_comp_alert_msg = "Hero is in batte now, cannot use as material!", 
    m_equip_decom_success = "Splitting Gear success!",
    m_equip_decom_alert_msg = "Gear is in use, cannot be splitted!",
    m_hero_evo_success = "Hero evolution success!",
    m_hero_evo_alert_msg = "The hero cannot be evolved!",
    m_hero_decom_alert_msg = "Hero is battling, unable to split",
    m_hero_decom_success = "Hero splitting success!",
    m_hero_sell_success = "Hero selling success!",
    m_hero_sell_alert_msg = "Hero is in battle, cannot be sold!",
    m_e_cooling_alert_msg = "Gear Strengthening is cooling down now, cannot be strengthened!",
    m_e_level_alert_msg = "Level is insufficient for strengthening!",
    m_e_evo_success = "Gear Strengthening success!",
    m_net_req_failed = "Network request failed, please try again!",
    m_net_no_data = "No network data!",
    m_data_error = "The current network is unstable, unable to connect to the server, please try again later.~",
    m_hero_played_in = "battling",
    m_equip_use = "using",
    m_equip_merge_alert_msg = "Material is insufficient for synthesis!",
    m_equip_merge_success = "Gear synthetic success!",
    m_career_success = "Change Job success",
    m_career_buyitems_success = "Purchase Job Changing Goods success",
    m_equip_decomposition_auto = "Are you confirm you want to split 1,2 stars gear automatically？",
    m_again_http_request = "Re-request",
    m_clear_cooling_time_success = "Clear cool down time success!",
    m_change_ratio_equip_success = "Gear Strengthening success rate changed!",
    m_notselect_partsid = "Please select part needs to be strengthened",
    m_energy_stone = "Crystal",
    m_gold_card_item = "Gold Card",
    m_silver_card_item = "Silver Card",

    m_input_role_name = "Enter the character name",
    m_re_input = "Re-enter",
    m_no_input_name = "Sorry, please enter your name!",
    m_random = "random",
    m_firts_opening_story = "公元2055年，平行宇宙发现的30年后\n力量宇宙的发现带来极其恐怖的病毒——灰雾\n灰雾导致大量人类变为丧尸，社会秩序一片混乱\n为了寻找解决问题的办法，各个宇宙都派出超级英雄进入\n力量宇宙，发现病毒背后的秘密，争夺更多的治疗资源\n新的大冒险篇章由此开启……",
    m_re_donwload = "Re-download",
    m_download_failed = "Data download failed",
    m_re_conn = "reconnect",
    m_download_cfg = "Download Configuration",
    m_download_res = "Loading Resource",
    m_fight_cost_tips = "Total %d battle, each battle consumes %d",
    m_no_msg = "None",
    m_map_title_battle_over = "Map has finished",
    m_re_battle_lock_msg = "level 10 unlock",
    m_explore = "Explore",
    m_re_explore = "Raids",
    m_action_point_tips = "Total %d battle needed to acquire current building , total SP points consumption %d. Your current SP is insufficient to acquire this building, confirm you want to continue?",
    m_map_title_step = "%d/%d completed",
    m_warning = "warning",
    m_add_training_card = "Add training partner",
    m_no_open = "Not Open Yet",
    m_open_condition = "Open when reach level %d",
    m_stop_training = "Stop Training",
    m_stop_training_tips = "Stop training can only get partial experience, do not return the excess money consumed.",
    m_speed_training = "Completed immediately",
    m_speed_training_tips = "Completion of the training will instantly get all the experience but will consume %d Diamond ×. Are you confirm?",
    m_speed_training_free = "Today the remaining number of free acceleration remains: %d times. Are you confirm to use it?",
    m_free_times = "Today free acceleration times: %d",
    m_retreat_warning = "Require to raid agian after retreat. Confirm retreat?",
    m_activity_retreat_warning = "After retreat you will need to re-battle. Confrim retreat?",
    m_auto_battle_finish = "Raids completed!",
    m_action_point_not_enough = "Insufficient SP!",
    m_sel_strengthen_equip = "Please select gear needs to be strengthened!",
    m_auto_battle_failed = "Raids Challenge failed!",
    m_equip_lv_is_max = "Gear reached the maximum level!",
    m_combat_is_not_enough = "Raids require %d combat",
    m_low_probability = "Low probability",
    m_rebattle_count = "No.：%d/%d",
    m_normal_chapter = "Select chapter",
    m_difficult_chapter = "Elite Checkpoint",
    m_error_tips_title = "Wrong Tips",
    m_lock_str = "lock",
    m_unlock_str = "unlock",
    m_metal_not_enough = "Insufficient Metal,needs %d Metal",
    m_food_not_enough = "Insufficient food, needs %d Food",
    m_crystal_not_enough = "Insuffiient Crystal, needs %d Crystal",
    m_lv_is_max = "reached maximum level!",
    m_master_is_max = "Number of main battle partners reached the max !",
    m_substitute_is_max = "reached the maximum number of substitute partner!",
    m_onclick_team_pos = "Please click on position to select partner within formation.",
    m_equip_pos_no_open = "Gear position is not open yet!",
    m_master_at_least_one = "At least must has a main battle partner!",

    m_vip_1 = "",

    m_team_pos_no_open = "Fleet position is not open yet",

    m_add_arena_time = "Confirm to purchase Arena chanllenge quota?",
    m_open_position = "Do you confirm to use%dDiamond× to open a training slot?",
    m_exit_info = "logout to exit the game, please re-open the game",
    m_session_invalid = "login problem, please re-open the game",

    world_boss_push_text = "Titan siege will begin in 5 minute!luxury rewards, prepare for battle",
    action_point_push_text = "SP had been restored completely, continue to fight, beware!",
    live_push_text = "Survival Supplies is begining to release! login to claim for free,limited time, don't miss it",
    tomorow_push_text = "Good news——Login now to claim a free orange card「Goku」",
    active_live = "Survival Test began, let's check it out!",

    m_open_text = "以虫洞旅行为标志的科技爆炸带来了新的黄金年代，\n人类终于在多维层面发现了平行宇宙的存在，\n还有栖居在万千宇宙中的文明多样性。\n但危机接踵而来，一种发源于宇宙301的僵尸病毒肆虐，\n突破了平行宇宙的界限，在多维空间蔓延。\n全部文明面临灭顶之灾。\n这一病毒被命名为“灰雾”。\n你，是第二批前往宇宙301探寻拯救之道的英雄。",

    --[[
        排序：进阶过的，等级大于10的，蓝色以上的
        1-3     出售卡牌
        4-6     技能升级
        7-8     伙伴进阶    只考虑进阶了和等级大于10的
        9-10    伙伴分解    只考虑进阶了和等级大于10的
    ]]
    m_seecial_tips_1 = "%s(LV.%d) is an Advanced +%d senior partner, can be obtain through the fusion of high-order card, are you sure wanna sell it?",
    m_seecial_tips_2 = "%s(LV.%d)is a high level partner,prior to the sale,you can use it to inherit the experience to other partner in partner inherit to reduce losses.",
    m_seecial_tips_3 = "%s(LV.%d) are a %s colors quality card,  can be use to obtain high order card  through the fusion, you are sure to continue to sell it?",

    m_seecial_tips_4 = "%s(LV.%d)is an advanced+%d senior partner,as the upgrade material,the effect is same with the non-advanced partner,can be use to obtain high order card through the fusion. Are you sure you use it?",
    m_seecial_tips_5 = "%s(LV.%d)is a high level partner,prior to skill upgrade,you can use it to inherit the experience to other partner to reduce losses in partner inherit.",
    m_seecial_tips_6 = "%s(LV.%d) are a %s colors quality card,  can be use to obtain high order card  through the fusion or as a valuable  partner advanced materials, you are sure to continue as an upgrade to the material it?",

    m_seecial_tips_7 = "%s(LV.%d)is an advanced+%d senior partner,as the advance material,the effect is same with the non-advanced partner, but you can get extra super dust and strong dust. Do you confirm to use it?",
    m_seecial_tips_8 = "%s(LV.%d)is a high level partner,prior to partner advancing,you can use it to inherit the experience to other partner to reduce losses in partner inherit",

    m_seecial_tips_9 = "%s(LV.%d)is an advanced+%d senior partner,can provide a lot of battle rating for you, do you confirm to split it?",
    m_seecial_tips_10 = "   %s(LV.%d)is a high level partner,prior to partner spliting,you can use it to inherit the experience to other partner to reduce losses in partner inherit",
    m_remove_apprentice = "Confirm to kick the disciple?",

    pirate_enter_tip = "\t\t formation can not be modifie when treasure hunt started\n\t\t HP will not resume after the battle",
    pirate_buff_tip = "increase BUFF successful",
    pirate_box_tip = "Please choose ur treasure!",
    pirate_text_1 = "effect",
    pirate_text_2 = "Probability of obtaining",
    pirate_text_increase = "increase",
    pirate_hp = "%'s HP",
    pirate_patk = "%'sPhysical Attack",
    pirate_matk = "%'s Magic Attack",
    pirate_def = "%'s Defense",
    pirate_speed = "%'s Speed",

    topplayer_info1 = "After an arduous struggle, WINER defeated LOSER",
    topplayer_info2 = "LOSER was trounced by WINNER",
    topplayer_info3 = "WINNER resorted a Black Tiger Steals Heart and defeated the LOSER.",
    topplayer_info4 = "WINER laughed out loud, followed by a roundhouse kick and knocked out the LOSER",
    topplayer_info5 = "Loser shouted\"I will be back!\"and flied away",

    m_topplayer_unnowname = "Mystery player",
    m_topplayer_noguild = "None",


    friend_recive_add_friedn_tips = "PLAYER sent you friend request",
    friend_send_add_friedn_tips = "Sent friend request to PLAYER success",
    friend_send_hadadd_friedn_tips = "You have sent PLAYER friend request.",
    friend_beAdd_friend = "PLAYER has accepted your friend request. You're now friend. Private Chat with him now ?",
    friend_hadbeen_friedn_tips = "Added PLAYER as friend successfully",


    guild_hadjoined__tips = "You have joined Guild Alliance",
    guild_send_invite_tips = "Send PLAYER Alliance invitation successfully",

    -- friend_send_add_friedn_tips = "成功向PLAYER发送好友申请",
    -- friend_send_add_friedn_tips = "成功向PLAYER发送好友申请",
    game_ability_commander_snatch_001 = "You have opened protective function. The protection function will fail after launch snatch. Continue snatch?",
    game_lucky_turntable_001 = "Remains:%d times",
    game_lucky_turntable_002 = "%d Diamond",
    game_lucky_turntable_003 = "Refresh success!",
    game_lucky_turntable_004 = "Remains:%d",
    game_challange_active1 = "Stay Tuned",
    game_challange_active2 = "Fortress Gurdian is opening end of August",

    m_forceGuide_10 = "You've unlocked a training partner,do you need guidance?",
    m_forceGuide_13 = "You have unlocked the hero skills, do you need guidance?",
    m_forceGuide_14 = "You have unlocked the advanced gear, do you need guidance?",
    m_forceGuide_15 = "You have unlocked the Ability transformation, do you need guidance?",
    m_forceGuide_17 = "You have unlocked the elite levels, do you need guidance?",
    m_forceGuide_18 = "You have unlocked the command ability  , do you need guidance?",
}

function string_config.getTextByKey(self,key)
    return self[tostring(key)] or "";
end

function string_config.getTextByKeyAndReplaceOne(self,key, rkey, rvalue)
    local text = self[tostring(key)] or ""
    if  type(rkey) == "string" and type(rvalue) =="string" then
        text = string.gsub(text, rkey, rvalue)
    end
    return text 
end

function string_config.getTextByKeyAndReplace(self,key, ...)
    local args = {...}
    if #args <=2 then return self:getTextByKeyAndReplaceOne(key,args[1], args[2]) end
    local text = self[tostring(key)] or ""
    local patt = nil
    local info = {}
    for i=1, #args - 1, 2 do
        if  type(args[i]) == "string" and type(args[i + 1]) == "string" then
            if not patt then patt = "[" else patt = patt .. "," end
            info[args[i]] = args[i+1]
            patt = patt .. args[i]
        end
    end
    patt = patt and patt .. "]+" 
    if patt then
        text = string.gsub(text, patt, function ( key )
            return info[key] or key
        end)
    end
    return text
end

return string_config;