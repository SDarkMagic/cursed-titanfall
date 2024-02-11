global function Init_BossTitanData
global function DEV_SpawnBossTitan
global function DEV_SpawnAllBossTitans
global function Spawn_Ash
global function Spawn_Slone
global function Spawn_Viper
global function Spawn_Richter
global function Spawn_Kane
global function Spawn_Blisk



global struct bossStageTracker {
    int currentStage = 0
    int maxStages = 3
    float regenTime = 15.0
}

global struct BossVoiceDiag {
    string intro
    string death
    string doomed
    array<string> changeTarget
    array<string> coreActivate
    array<string> retreat
    array<string> advance
}

global struct BossData {
    string name
    asset modelPath
    string title
    int skinIndex
    int camoIndex = -1
    int decalIndex
    string aiSettings
    int healthModifier
    string soulPassive4 = ""
    string soulPassive5 = ""
    string soulPassive6 = ""
    void functionref( entity ) loadoutSetter
    bossStageTracker &stageTracker
    bool warpfall
    string execution
    string theme
    string className
    BossVoiceDiag &diag
}
struct {
    table<string, bossStageTracker> bossStageTrackers
    table<string, BossData> bosses
    table<string, entity> bossEnts
} file

BossData &ash
BossData &viper
BossData &slone
BossData &richter
BossData &kane
BossData &blisk

void function Init_BossTitanData()
{
    ash = Init_Ash()
    viper = Init_Viper()
    slone = Init_Slone()
    richter = Init_Richter()
    kane = Init_Kane()
    blisk = Init_Blisk()
}

BossData function Init_Viper()
{
    BossData viper

    bossStageTracker stageData
    stageData.regenTime = 15.0
    stageData.maxStages = 3

    viper.stageTracker = stageData

    viper.name = "Viper"
    viper.className = "titan_stryder"
    viper.modelPath = $"models/titans/light/titan_light_raptor.mdl"
    viper.skinIndex = 6
    viper.decalIndex = 10
    viper.aiSettings = "npc_titan_stryder_sniper_boss_fd_viper"
    viper.healthModifier = 7500
    viper.soulPassive4 = "pas_northstar_cluster"
    viper.soulPassive5 = "pas_northstar_trap"
    viper.execution = "execution_northstar_prime"
    viper.warpfall = true
    viper.theme = "music_s2s_14_titancombat"
    viper.title = "#BOSSNAME_VIPER"
    viper.loadoutSetter = SetLoadout_Viper

    BossVoiceDiag voice
    voice.intro = "diag_sp_bossFight_STS673_01_01_mcor_viper"
    voice.death = "diag_sp_bossFight_STS676_43_01_imc_viper"
    voice.doomed = "diag_sp_bossFight_STS676_42_01_imc_viper"
    voice.retreat = [ "diag_sp_bossFight_STS676_23_01_imc_viper", "diag_sp_bossFight_STS676_22_01_imc_viper", "diag_sp_bossFight_STS676_21_01_imc_viper", "diag_sp_bossFight_STS676_20_01_imc_viper", "diag_sp_bossFight_STS676_19_01_imc_viper" ]
    voice.advance = [ "diag_sp_bossFight_STS676_24_01_imc_viper", "diag_sp_bossFight_STS676_25_01_imc_viper", "diag_sp_bossFight_STS676_26_01_imc_viper", "diag_sp_bossFight_STS676_27_01_imc_viper", ]
    voice.coreActivate = [ "diag_sp_bossFight_STS676_09_01_imc_viper", "diag_sp_bossFight_STS676_08_01_imc_viper", "diag_sp_bossFight_STS676_39_01_imc_viper", "diag_sp_bossFight_STS676_15_01_imc_viper", "diag_sp_bossFight_STS676_09_01_imc_viper", "diag_sp_bossFight_STS676_40_01_imc_viper" ]
    voice.changeTarget = [ "diag_sp_bossFight_STS676_19_01_imc_viper", "diag_sp_bossFight_STS676_33_01_imc_viper", "diag_sp_bossFight_STS676_41_01_imc_viper", "diag_sp_bossFight_STS676_35_01_imc_viper" ]
    viper.diag = voice
    return viper
}

BossData function Init_Ash()
{
    BossData ash

    bossStageTracker stageData
    stageData.regenTime = 10.0
    stageData.maxStages = 4

    ash.stageTracker = stageData

    ash.name = "Ash"
    ash.className = "titan_stryder"
    ash.modelPath = $"models/titans/light/titan_light_locust.mdl"
    ash.skinIndex = 6
    ash.decalIndex = 10
    ash.aiSettings = "npc_titan_stryder_leadwall_boss_fd_ash"
    ash.healthModifier = 7500
    ash.soulPassive4 = "pas_ronin_swordcore"
    ash.soulPassive5 = "pas_ronin_weapon"
    ash.soulPassive6 = "pas_ronin_phase"
    ash.execution = "execution_ronin_prime"
    ash.warpfall = true
    ash.theme = "music_boomtown_23_ashintro"
    ash.title = "#BOSSNAME_ASH"
    ash.loadoutSetter = SetLoadout_Ash

    BossVoiceDiag voice
    voice.intro = "diag_sp_BossVdu_BM112_01_01_imc_ash"
    voice.death = "diag_sp_BossVdu_BM111_06_01_imc_ash"
    voice.doomed = "diag_sp_BossVdu_BM112_05_01_imc_ash"
    voice.retreat = [ "diag_sp_BossVdu_BM112_22_01_imc_ash", "diag_sp_BossVdu_BM112_21_01_imc_ash", "diag_sp_BossVdu_BM112_20_01_imc_ash", "diag_sp_BossVdu_BM112_19_01_imc_ash" ]
    voice.advance = [ "diag_sp_BossVdu_BM112_23_01_imc_ash", "diag_sp_BossVdu_BM112_24_01_imc_ash", "diag_sp_BossVdu_BM112_25_01_imc_ash", "diag_sp_BossVdu_BM112_26_01_imc_ash" ]
    voice.coreActivate = [ "diag_sp_BossVdu_BM112_15_01_imc_ash", "diag_sp_BossVdu_BM112_33_01_imc_ash", "diag_sp_BossVdu_BM112_34_01_imc_ash", "diag_sp_BossVdu_BM112_35_01_imc_ash" ] // Core used lines in addition to random_backup event lines
    voice.changeTarget = [ "diag_sp_BossVdu_BM112_10_01_imc_ash", "diag_sp_BossVdu_BM112_11_01_imc_ash", "diag_sp_BossVdu_BM112_12_01_imc_ash" ]
    ash.diag = voice
    return ash
}

BossData function Init_Slone()
{
    BossData slone

    bossStageTracker stageData
    stageData.regenTime = 20.0
    stageData.maxStages = 3

    slone.stageTracker = stageData

    slone.name = "Slone"
    slone.className = "titan_atlas"
    slone.modelPath = $"models/titans/medium/titan_medium_ajax.mdl"
    slone.skinIndex = 7
    slone.decalIndex = 11
    slone.aiSettings = "npc_titan_atlas_stickybomb_boss_fd_slone"
    slone.healthModifier = 10000
    slone.soulPassive4 = "pas_ion_lasercannon"
    slone.execution = "execution_ion"
    slone.warpfall = true
    slone.theme = "music_skyway_16_slonefight"
    slone.title = "#BOSSNAME_SLONE"
    slone.loadoutSetter = SetLoadout_Slone

    BossVoiceDiag voice
    voice.intro = "diag_sp_bossFight_SK676_02_01_imc_slone"
    voice.death = "diag_sp_bossFight_SK676_07_01_imc_slone"
    voice.doomed = "diag_sp_bossFight_SK676_06_01_imc_slone"
    voice.retreat = [ "diag_sp_bossFight_SK676_21_01_imc_slone", "diag_sp_bossFight_SK676_22_01_imc_slone", "diag_sp_bossFight_SK676_23_01_imc_slone" ]
    voice.advance = [ "diag_sp_bossFight_SK676_24_01_imc_slone", "diag_sp_bossFight_SK676_25_01_imc_slone", "diag_sp_bossFight_SK676_26_01_imc_slone", "diag_sp_bossFight_SK676_27_01_imc_slone" ]
    voice.coreActivate = [ "diag_sp_bossFight_SK676_35_01_imc_slone", "diag_sp_bossFight_SK676_37_01_imc_slone", "diag_sp_bossFight_SK676_40_01_imc_slone" ]
    voice.changeTarget = [ "diag_sp_bossFight_SK676_11_01_imc_slone", "diag_sp_bossFight_SK676_12_01_imc_slone", "diag_sp_bossFight_SK676_13_01_imc_slone" ]
    slone.diag = voice
    return slone
}

BossData function Init_Richter()
{
    BossData richter

    bossStageTracker stageData
    stageData.regenTime = 20.0
    stageData.maxStages = 3

    richter.stageTracker = stageData

    richter.name = "Richter"
    richter.className = "titan_atlas"
    richter.modelPath = $"models/titans/medium/titan_medium_wraith.mdl"
    richter.skinIndex = 4
    richter.decalIndex = 11
    richter.aiSettings = "npc_titan_atlas_tracker_boss_fd_richter"
    richter.healthModifier = 10000
    richter.soulPassive4 = "pas_tone_sonar"
    richter.soulPassive5 = "pas_tone_wall"
    richter.soulPassive6 = "pas_tone_rockets"
    richter.execution = "execution_random_4"
    richter.warpfall = false
    richter.theme = "Music_Beacon_28_BossArrivesAndBattle"
    richter.title = "#BOSSNAME_RICHTER"
    richter.loadoutSetter = SetLoadout_Richter

    BossVoiceDiag voice
    voice.intro = "diag_sp_bossFight_BN676_01_01_imc_richter"
    voice.death = "diag_sp_bossFight_BN676_06_01_imc_richter"
    voice.doomed = "diag_sp_bossFight_BN676_05_01_imc_richter"
    voice.retreat = [ "diag_sp_bossFight_BN676_16_01_imc_richter", "diag_sp_bossFight_BN676_17_01_imc_richter", "diag_sp_bossFight_BN676_18_01_imc_richter" ]
    voice.advance = [ "diag_sp_bossFight_BN676_23_01_imc_richter", "diag_sp_bossFight_BN676_24_01_imc_richter", "diag_sp_bossFight_BN676_25_01_imc_richter", "diag_sp_bossFight_BN676_26_01_imc_richter" ]
    voice.coreActivate = [ "diag_sp_bossFight_BN676_09_01_imc_richter", "diag_sp_bossFight_BN676_35_01_imc_richter" ]
    voice.changeTarget = [ "diag_sp_bossFight_BN676_10_01_imc_richter", "diag_sp_bossFight_BN676_11_01_imc_richter", "diag_sp_bossFight_BN676_12_01_imc_richter" ]
    richter.diag = voice
    return richter
}

BossData function Init_Kane()
{
    BossData kane

    bossStageTracker stageData
    stageData.regenTime = 15.0
    stageData.maxStages = 2

    kane.stageTracker = stageData

    kane.name = "Kane"
    kane.className = "titan_ogre"
    kane.modelPath = $"models/titans/heavy/titan_heavy_ogre.mdl"
    kane.skinIndex = 3
    kane.decalIndex = 1
    kane.aiSettings = "npc_titan_ogre_meteor_boss_fd_kane"
    kane.healthModifier = 15000
    kane.soulPassive4 = "pas_scorch_flamecore"
    kane.soulPassive5 = "pas_scorch_selfdmg"
    kane.execution = "execution_scorch_prime"
    kane.warpfall = false
    kane.theme = "music_reclamation_21_kaneslamcam"
    kane.title = "#BOSSNAME_KANE"
    kane.loadoutSetter = SetLoadout_Kane

    BossVoiceDiag voice
    voice.intro = "diag_sp_bossFight_SE676_02_01_imc_kane"
    voice.death = "diag_sp_bossFight_SE676_06_01_imc_kane"
    voice.doomed = "diag_sp_bossFight_SE676_05_01_imc_kane"
    voice.retreat = [ "diag_sp_bossFight_SE676_16_01_imc_kane", "diag_sp_bossFight_SE676_17_01_imc_kane", "diag_sp_bossFight_SE676_17_01_imc_kane", "diag_sp_bossFight_SE676_04_01_imc_kane" ]
    voice.advance = [ "diag_sp_bossFight_SE676_23_01_imc_kane", "diag_sp_bossFight_SE676_24_01_imc_kane", "diag_sp_bossFight_SE676_25_01_imc_kane", "diag_sp_bossFight_SE676_26_01_imc_kane" ]
    voice.coreActivate = [ "diag_sp_bossFight_SE676_34_01_imc_kane", "diag_sp_bossFight_SE676_36_01_imc_kane" ]
    voice.changeTarget = [ "diag_sp_bossFight_SE676_35_01_imc_kane", "diag_sp_bossFight_SE676_10_01_imc_kane", "diag_sp_bossFight_SE676_11_01_imc_kane", "diag_sp_bossFight_SE676_12_01_imc_kane" ]
    kane.diag = voice
    return kane
}

BossData function Init_Blisk()
{
    BossData blisk

    bossStageTracker stageData
    stageData.regenTime = 30.0
    stageData.maxStages = 5

    blisk.stageTracker = stageData

    blisk.name = "Blisk"
    blisk.className = "titan_ogre"
    blisk.modelPath = $"models/titans/heavy/titan_heavy_deadbolt.mdl"
    blisk.skinIndex = 4
    blisk.decalIndex = 9
    blisk.aiSettings = "npc_titan_ogre_minigun_boss_fd_blisk"
    blisk.healthModifier = 15000
    blisk.soulPassive4 = "pas_legion_spinup"
    blisk.execution = "execution_legion_prime"
    blisk.warpfall = false
    blisk.theme = "music_skyway_13_enroutetobliskandslone"
    blisk.title = "#BOSSNAME_BLISK"
    blisk.loadoutSetter = SetLoadout_Blisk

    BossVoiceDiag voice
    voice.intro = "diag_sp_torture_SK101_02_01_imc_blisk"
    voice.death = "diag_imc_pilot5_hc_death"
    voice.doomed = "diag_imc_pilot5_hc_death"
    voice.retreat = [ "diag_sp_injectorRoom_SK161_07_01_imc_blisk", "diag_sp_injectorRoom_SK161_07_01_imc_blisk" ]
    voice.advance = [ "diag_imc_pilot5_hc_battleStart", "diag_imc_pilot5_hc_battleStart" ]
    voice.coreActivate = [ "diag_sp_torture_SK101_03_01_imc_blisk", "diag_sp_torture_SK101_03_01_imc_blisk" ]
    voice.changeTarget = [ "diag_sp_torture_SK101_08_01_imc_blisk", "diag_sp_torture_SK101_08_01_imc_blisk" ]
    blisk.diag = voice
    return blisk
}

void function DEV_SpawnAllBossTitans( )
{
    entity player = GetPlayerArray()[ 0 ]
	if ( !IsValid( player ) )
		return

	vector origin = GetPlayerCrosshairOrigin( player )
	vector angles = Vector( 0, 0, 0 )

    Spawn_Ash( origin, angles )
    origin.x += 500
    Spawn_Blisk( origin, angles )
    origin.x += 500
    Spawn_Kane( origin, angles )
    origin.x += 500
    Spawn_Richter( origin, angles )
    origin.x += 500
    Spawn_Slone( origin, angles )
    origin.x += 500
    Spawn_Viper( origin, angles )
}

void function DEV_SpawnBossTitan( string bossName )
{
    entity player = GetPlayerArray()[ 0 ]
	if ( !IsValid( player ) )
		return

	vector origin = GetPlayerCrosshairOrigin( player )
	vector angles = Vector( 0, 0, 0 )
    switch ( bossName )
    {
        case "ash":
            Spawn_Ash( origin, angles )
            return
        case "viper":
            CreateBossTitan_Generic( viper, origin, angles )
            return
        case "slone":
            Spawn_Slone( origin, angles )
            return
        case "richter":
            Spawn_Richter( origin, angles )
            return
        case "kane":
            Spawn_Kane( origin, angles )
            return
        case "blisk":
            Spawn_Blisk( origin, angles )
            return
        case "test":
            CreateBossTitan_Generic( ash, origin, angles )
        default:
            printt("Please supply a valid option")
            return
    }
}


entity function Spawn_Ash( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( ash, origin, angles, team, spawnType )
}

entity function Spawn_Viper( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( viper, origin, angles, team, spawnType )
}

entity function Spawn_Slone( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( slone, origin, angles, team, spawnType )
}

entity function Spawn_Richter( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( richter, origin, angles, team, spawnType )
}

entity function Spawn_Kane( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( kane, origin, angles, team, spawnType )
}

entity function Spawn_Blisk( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    return CreateBossTitan_Generic( blisk, origin, angles, team, spawnType )
}

void function BossDefeated( entity trigger, entity activator, entity caller, var value )
{
    if ( !IsValid( trigger ) )
        return
    if ( !trigger.IsTitan() )
        return
    RemoveEntityCallback_OnDamaged( trigger, BossTitan_TakesDamage_StageHandler )
    string bossTitanName = trigger.GetScriptName()
    file.bosses[ bossTitanName ].stageTracker.currentStage = 0
    StopMusicTrack( file.bosses[ bossTitanName ].theme )
    PlayBossCommsForAllPlayers( file.bosses[ bossTitanName ].diag.death )
}

void function SetLoadout_Ash( entity npc )
{
    npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
    return
}

void function SetLoadout_Viper( entity npc )
{
    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity maingun = primaryWeapons[0]
    maingun.AddMod( "quick_shot" )
    maingun.AddMod( "fast_reload" )
    maingun.AddMod( "pas_northstar_weapon" )
    maingun.AddMod( "burn_mod_titan_sniper" )

    entity tethertrap = npc.GetOffhandWeapon( OFFHAND_SPECIAL )
    tethertrap.AddMod( "fd_trap_charges" )
    tethertrap.AddMod( "fd_explosive_trap" )
    tethertrap.AddMod( "pas_northstar_trap" )

    entity clustermissile = npc.GetOffhandWeapon( OFFHAND_ORDNANCE )
    clustermissile.AddMod( "fd_twin_cluster" )
    clustermissile.AddMod( "dev_mod_low_recharge" )
    clustermissile.AddMod( "burn_mod_titan_dumbfire_rockets" )
}

void function SetLoadout_Slone( entity npc )
{
    //entity offHandWeapon = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
    npc.TakeOffhandWeapon(OFFHAND_ANTIRODEO )
    npc.GiveOffhandWeapon( "mp_titanability_phase_dash", OFFHAND_ANTIRODEO )
    //array<entity> utilityWeapon = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
}

void function SetLoadout_Richter( entity npc )
{
    entity tonesonar = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
    tonesonar.AddMod( "fd_sonar_duration" )
    tonesonar.AddMod( "fd_sonar_damage_amp" )

    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity maingun = primaryWeapons[0]
    maingun.AddMod( "fast_reload" )
    maingun.AddMod( "extended_ammo" )
}

void function SetLoadout_Kane( entity npc )
{
    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity weapon = primaryWeapons[0]
    weapon.AddMod( "fd_wpn_upgrade_2" )
}

void function SetLoadout_Blisk( entity npc )
{
    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity maingun = primaryWeapons[0]
    maingun.AddMod( "fd_closerange_helper" )
    maingun.AddMod( "fd_longrange_helper" )
    maingun.AddMod( "fd_piercing_shots" )
    maingun.AddMod( "fd_gun_shield_redirect" )
    maingun.AddMod( "SiegeMode" )

    entity gunshield = npc.GetOffhandWeapon( OFFHAND_SPECIAL )
    gunshield.AddMod( "npc_more_shield" )
    gunshield.AddMod( "npc_infinite_shield" )
    gunshield.AddMod( "fd_gun_shield" )
    gunshield.AddMod( "fd_gun_shield_redirect" )
    gunshield.AddMod( "SiegeMode" )
}

entity function CreateBossTitan_Generic( BossData boss, vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0)
{
    bossStageTracker stageTracker = boss.stageTracker
    stageTracker.currentStage = 0 // Reset the boss' stage to zero on spawn in case something weird happened to a previous instance
    file.bosses[ boss.name ] <- boss
    //AddBossTitan( boss.name )

    entity npc = CreateNPCTitan( boss.className, team, origin, angles )
    SetSpawnOption_AISettings( npc, boss.aiSettings )
    npc.SetScriptName( boss.name )
    npc.ai.bossCharacterName = boss.name
    SetTitanAsElite( npc )
    if ( boss.soulPassive4 != "" )
        SetSpawnOption_TitanSoulPassive4( npc, boss.soulPassive4 )
    if ( boss.soulPassive5 != "" )
        SetSpawnOption_TitanSoulPassive5( npc, boss.soulPassive5 )
    if ( boss.soulPassive6 != "" )
        SetSpawnOption_TitanSoulPassive6( npc, boss.soulPassive6 )

    if ( boss.warpfall == true )
        SetSpawnOption_Warpfall( npc )
    else
        SetSpawnOption_Titanfall( npc )
    AddEntityCallback_OnDamaged( npc, BossTitan_TakesDamage_StageHandler )

    SetTargetName( npc, GetTargetNameForID( spawnType ) )
    DispatchSpawn( npc )
    SetBossTitanPostSpawn( npc, boss )

    boss.loadoutSetter( npc )
    DisableTitanRodeo( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + boss.healthModifier ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = boss.execution
    npc.ConnectOutput( "OnFoundPlayer", BossChangedTarget )
    npc.ConnectOutput( "OnDeath", BossDefeated )

    printt("Connected outputs")
    npc.SetDangerousAreaReactionTime( 0 )

    file.bossEnts[ boss.name ] <- npc
    //RegisterBossTitan( npc )

    printt("Finished titan setup")
    string introLine = boss.diag.intro
    PlayBossCommsForAllPlayers( boss.diag.intro )
    PlayMusic( boss.theme )
    WarnAllPlayers_BossMechanics()
    printt("Succesfully dropped titan")
    return npc
}

void function BossTitan_TakesDamage_StageHandler( entity titan, var damageInfo )
{
    if ( !IsValid( titan ) || !titan.IsTitan() )
        return
    entity soul = titan.GetTitanSoul()
    string bossTitanName = GetTitanCharacterName( titan )
    string bossName = titan.GetScriptName()
    int currentHealth = titan.GetHealth()
    float damage = DamageInfo_GetDamage( damageInfo )
    bool shouldReset = false
    bossStageTracker stageInfo = file.bosses[ bossName ].stageTracker
    if ( currentHealth - damage <= 1 && stageInfo.currentStage < stageInfo.maxStages) //Run this check when the boss has one cell or less of health remaining to hopefully avoid boss being doomed before entering health regen
    {
        array<string> retreatLines = file.bosses[ bossName ].diag.retreat
        string comm = retreatLines[ RandomInt( retreatLines.len() - 1 ) ]
        titan.SetInvulnerable( )
        DamageInfo_SetDamage( damageInfo, 0 )
        titan.SetHealth( 1 )
        PlayBossCommsForAllPlayers( comm )
        // Do health regen stuff here
        file.bosses[ bossName ].stageTracker.currentStage++
        thread ResetBossHealth( titan )
    }
}

void function ResetBossHealth( entity boss )
{
    entity soul = boss.GetTitanSoul()
    int maxHealth = boss.GetMaxHealth()
    int currentHealth = boss.GetHealth()
    int loopCount = int( ceil( maxHealth / 1000 ) )
    string bossName = boss.GetScriptName()
    float regenTime = file.bosses[ bossName ].stageTracker.regenTime
    bossStageTracker stageInfo = file.bosses[ bossName ].stageTracker
    float cycleWaitDuration = regenTime / loopCount
    string bossTheme = file.bosses[ bossName ].theme

    array<string> advanceLines = file.bosses[ bossName ].diag.advance
    string comm = advanceLines[ RandomInt( advanceLines.len() - 1 ) ]

    if ( stageInfo.currentStage >= stageInfo.maxStages )
    {
        boss.SetHealth( boss.GetMaxHealth() )
        boss.ClearInvulnerable()
        soul.EnableDoomed()
        return
        //titan.SetMaxHealth( 5000 )
    }
    //if ( boss.ContextAction_IsActive() || boss.ContextAction_IsActive() )
    //    boss.ContextAction_ClearBusy()
    StopMusicTrack( bossTheme, regenTime )
    //SetStanceKneel( boss.GetTitanSoul() )
    UndoomBossTitan( boss )
    while ( currentHealth < maxHealth)
    {
        if ( !IsValid( boss ) || !IsAlive( boss ) )
            return
        currentHealth += 1000
        if ( currentHealth <= boss.GetMaxHealth( ) )
            boss.SetHealth( currentHealth )
        else
            boss.SetHealth( boss.GetMaxHealth() )
        wait regenTime / loopCount
    }

    boss.SetHealth( boss.GetMaxHealth() )
    boss.ClearInvulnerable()
    //TitanCanStand( boss )
    PlayBossCommsForAllPlayers( comm )
    PlayMusic( bossTheme )
    return
}

void function UndoomBossTitan( entity titan )
{
    if ( !IsValid( titan ) || !titan.IsTitan() )
        return
    string bossName = titan.GetScriptName()
    entity soul = titan.GetTitanSoul()
    int segmentHealth = GetSegmentHealthForTitan( titan )
    BossData boss = file.bosses[ bossName ]
    titan.SetMaxHealth( ( titan.GetMaxHealth() ) )
    titan.SetHealth( segmentHealth * 1 )
	SetSoulBatteryCount( soul, 1 )

	titan.Signal( "TitanUnDoomed" )
	UndoomTitan_Body( titan )
}

void function WarnAllPlayers_BossMechanics()
{
    foreach ( entity player in GetPlayerArray() )
    {
        NSSendInfoMessageToPlayer( player, "WARNING: Boss titans have multiple phases and will regenerate HP when low. While regenerating health, the titan will be invulnerable to all damage.")
    }
}

void function BossChangedTarget( entity trigger, entity activator, entity caller, var value )
{
    expect entity( value );
    if ( !IsValid( value ) || !value.IsPlayer() )
        return
    printt("Boss target changed; ", trigger, activator, caller, value)
    array<string> targetLines = file.bosses[ trigger.GetScriptName() ].diag.changeTarget
    string line = targetLines[ RandomInt( targetLines.len() - 1 ) ]
    if ( RandomInt( 100 ) > 70 )
        EmitSoundOnEntityOnlyToPlayer( value, value, line )
}

void function SetBossTitanPostSpawn( entity npc, BossData bossData )
{
	if( GetGameState() != eGameState.Playing )
		return

	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Boss: " + npc )
	if ( npc.IsTitan() )
	{
		npc.EnableNPCFlag( NPC_NO_PAIN | NPC_NO_GESTURE_PAIN | NPC_NEW_ENEMY_FROM_SOUND | NPC_DIRECTIONAL_MELEE | NPC_IGNORE_FRIENDLY_SOUND ) //NPC_AIM_DIRECT_AT_ENEMY
		npc.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT | NPCMF_DISABLE_MOVE_TRANSITIONS )
		npc.DisableNPCFlag( NPC_PAIN_IN_SCRIPTED_ANIM | NPC_ALLOW_FLEE | NPC_USE_SHOOTING_COVER )
		npc.DisableNPCMoveFlag( NPCMF_WALK_NONCOMBAT )
		npc.SetCapabilityFlag( bits_CAP_NO_HIT_SQUADMATES, false )
		npc.SetDefaultSchedule( "SCHED_COMBAT_WALK" )
		npc.kv.AccuracyMultiplier = 5.0
		npc.kv.WeaponProficiency = eWeaponProficiency.PERFECT
		npc.SetTargetInfoIcon( GetTitanCoreIcon( GetTitanCharacterName( npc ) ) )
		npc.AssaultSetFightRadius( 2000 )
		npc.SetEngagementDistVsWeak( 0, 800 )
		npc.SetEngagementDistVsStrong( 0, 800 )
		SetTitanWeaponSkin( npc )
        //Rodeo_Disallow( npc )
        npc.SetSkin( bossData.skinIndex )
        npc.SetDecal( bossData.decalIndex )
		HideCrit( npc )
		npc.SetTitle( bossData.title )
		ShowName( npc )

		entity soul = npc.GetTitanSoul()
		if( IsValid( soul ) )
		{
			soul.SetPreventCrits( true )
			soul.SetShieldHealthMax( 8000 )
			soul.SetShieldHealth( soul.GetShieldHealthMax() )
            soul.DisableDoomed()
		}

		if( GetTitanCharacterName( npc ) == "vanguard" ) //Monarchs never use their core, but can track their shields to simulate a player-like behavior
			return
		else
			thread MonitorBossTitanCore( npc )
	}
}

void function MonitorBossTitanCore( entity npc )
{
	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
    BossData boss = file.bosses[ npc.GetScriptName() ]
    array<string> coreLines = boss.diag.coreActivate
    string voiceLine;
	entity soul = npc.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnDeath" )

	while( true )
	{
		SoulTitanCore_SetNextAvailableTime( soul, 1.0 )

		npc.WaitSignal( "CoreBegin" )
		wait 0.1

		soul.SetShieldHealth( soul.GetShieldHealthMax() / 2 )


        voiceLine = coreLines[ RandomInt( coreLines.len() - 1 ) ]
        PlayBossCommsForAllPlayers( voiceLine )

		entity meleeWeapon = npc.GetMeleeWeapon()
		if( meleeWeapon.HasMod( "super_charged" ) || meleeWeapon.HasMod( "super_charged_SP" ) ) //Hack for Elite Ronin
			npc.SetAISettings( "npc_titan_stryder_leadwall_shift_core_elite" )

		npc.WaitSignal( "CoreEnd" )

		switch ( difficultyLevel )
		{
			case eFDDifficultyLevel.EASY:
			case eFDDifficultyLevel.NORMAL:
			case eFDDifficultyLevel.HARD:
				wait RandomFloatRange( 20.0, 40.0 )
				break
			case eFDDifficultyLevel.MASTER:
			case eFDDifficultyLevel.INSANE:
				wait RandomFloatRange( 40.0, 60.0 )
				break
		}
	}
}

/*
void function AddMinimapForTitans( entity titan )
{
	if( !IsValid( titan ) )
		return

	titan.Minimap_SetAlignUpright( true )
	titan.Minimap_AlwaysShow( TEAM_IMC, null )
	titan.Minimap_AlwaysShow( TEAM_MILITIA, null )
	titan.Minimap_SetHeightTracking( true )
	titan.Minimap_SetZOrder( MINIMAP_Z_NPC )
	titan.Minimap_SetCustomState( eMinimapObject_npc_titan.AT_BOUNTY_BOSS )
}
*/