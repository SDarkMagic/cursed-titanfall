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
}

struct {
    array<string> musicTracksPlaying
    table<string, bossStageTracker> bossStageTrackers
    table<string, BossData> bosses
    table<string, entity> bossEnts
} file

BossData ash

void function Init_BossTitanData()
{
    bossStageTracker ashStageData
    ashStageData.regenTime = 10.0
    ashStageData.maxStages = 2

    ash.stageTracker = ashStageData

    ash.name = "Ash"
    ash.className = "titan_stryder"
    ash.modelPath = $"models/titans/light/titan_light_locust.mdl"
    ash.skinIndex = 6
    ash.decalIndex = 10
    ash.aiSettings = "npc_titan_stryder_leadwall_boss_fd_elite"
    ash.healthModifier = 7500
    ash.soulPassive4 = "pas_ronin_swordcore"
    ash.soulPassive5 = "pas_ronin_weapon"
    ash.soulPassive6 = "pas_ronin_phase"
    ash.execution = "execution_ronin_prime"
    ash.warpfall = true
    ash.theme = "music_boomtown_23_ashintro"
    ash.title = "#BOSSNAME_ASH"
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
            Spawn_Viper( origin, angles )
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

void function PlayMusic( string track )
{
	printt( "#################################" )
	printt( "Playing Music" )
	printt( "  Track:", track )
	printt( "#################################" )
	file.musicTracksPlaying.append( track )

	foreach( entity player in GetPlayerArray() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, track )
	}
}

void function StopMusic( float fadeTime = 2.0 )
{
	array<string> tracks = clone file.musicTracksPlaying
	foreach( entity player in GetPlayerArray() )
	{
		foreach( string track in tracks )
		{
			StopMusicTrack( track, fadeTime )
		}
	}
}

bool function IsMusicTrackPlaying( string track )
{
	return file.musicTracksPlaying.contains( track )
}

void function StopMusicTrack( string track, float fadeTime = 2.0 )
{
	printt( "#################################" )
	printt( "Stopping music track:", track )
	printt( "#################################" )

	foreach( entity player in GetPlayerArray() )
	{
		//StopSoundOnEntity( player, file.lastMusicTrack )
		FadeOutSoundOnEntity( player, track, fadeTime )
	}

	file.musicTracksPlaying.fastremovebyvalue( track )
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
}

void function SetLoadout_Ash( entity npc )
{
    npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
    return
}

void function CreateBossTitan_Generic( BossData boss, vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0)
{
    file.bossStageTrackers[ "ronin" ] <- boss.stageTracker

    file.bosses[ boss.name ] <- boss

    entity npc = CreateNPCTitan( boss.className, team, origin, angles )
    SetSpawnOption_AISettings( npc, boss.aiSettings )
    npc.SetScriptName( boss.name )
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

    SetTargetName( npc, GetTargetNameForID( spawnType ) )
    DispatchSpawn( npc )
    SetBossTitanPostSpawn( npc, boss )

    //boss.loadoutSetter( npc )

    npc.SetMaxHealth( ( npc.GetMaxHealth() + boss.healthModifier ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = boss.execution
    npc.ConnectOutput( "OnDeath", BossDefeated )

    npc.SetDangerousAreaReactionTime( 0 )
    spawnedNPCs.append( npc )
    file.bossEnts[ boss.name ] <- npc
    AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
    AddEntityCallback_OnDamaged( npc, BossTitan_TakesDamage_StageHandler )
    printt("finished titan setup")
    npc.WaitSignal( "TitanHotDropComplete" )
    //thread PlayMusic( boss.theme )

    printt("Succesfully dropped titan")
}

void function SpawnBossTitan_Generic( BossData boss, vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    printt("Called SpawnBossTitan_Generic")
    PlayMusic( boss.theme )
    CreateBossTitan_Generic( boss, origin, angles, team, spawnType )
    entity npc = file.bossEnts[ boss.name ]
    ShowName( npc )
    AddMinimapForTitans( npc )
    printt("Titan dropped successfully")
    // Set weapon mods here after the boss is loaded. This should allow for more generic factory functions
}

entity function Spawn_Ash( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "ronin" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_stryder", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd_elite" )

    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_ronin_swordcore" )
    SetSpawnOption_TitanSoulPassive5( npc, "pas_ronin_weapon" )
    SetSpawnOption_TitanSoulPassive6( npc, "pas_ronin_phase" )
    SetSpawnOption_Warpfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )
    npc.ConnectOutput( "OnDeath", BossDefeated )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/light/titan_light_locust.mdl" )
    npc.SetSkin( 6 )
    npc.SetDecal( 10 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_ASH" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 7500 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ronin_prime"

    npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
    npc.SetDangerousAreaReactionTime( 0 )
    PlayMusic( "music_boomtown_23_ashintro" )
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    return npc
}

entity function Spawn_Viper( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "northstar" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_stryder", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_boss_fd_elite" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_northstar_cluster" )
	SetSpawnOption_TitanSoulPassive5( npc, "pas_northstar_trap" )
    SetSpawnOption_Warpfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )
    AddEntityCallback_OnDamaged( npc, BossTitan_TakesDamage_StageHandler )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/light/titan_light_raptor.mdl" )
    npc.SetSkin( 6 )
    npc.SetDecal( 10 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_VIPER" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 7500 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_northstar_prime"

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

    npc.SetDangerousAreaReactionTime( 0 )
    PlayMusic( "music_s2s_14_titancombat" )
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    return npc
}

entity function Spawn_Slone( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "ion" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_atlas", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd_elite" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_ion_lasercannon" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/medium/titan_medium_ajax.mdl" )
    npc.SetSkin( 7 )
    npc.SetDecal( 11 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_SLONE" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 10000 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ion"
    npc.SetDangerousAreaReactionTime( 0 )

    PlayMusic( "music_skyway_16_slonefight" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    return npc
}

entity function Spawn_Richter( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "tone" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_atlas", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_atlas_tracker_fd_sniper_elite" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_tone_sonar" )
    SetSpawnOption_TitanSoulPassive5( npc, "pas_tone_wall" )
    SetSpawnOption_TitanSoulPassive6( npc, "pas_tone_rockets" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/medium/titan_medium_wraith.mdl" )
    npc.SetSkin( 4 )
    npc.SetDecal( 11 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_RICHTER" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 10000 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_random_4"

    entity tonesonar = npc.GetOffhandWeapon( OFFHAND_ANTIRODEO )
    tonesonar.AddMod( "fd_sonar_duration" )
    tonesonar.AddMod( "fd_sonar_damage_amp" )

    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity maingun = primaryWeapons[0]
    maingun.AddMod( "fast_reload" )
    maingun.AddMod( "extended_ammo" )

    npc.SetDangerousAreaReactionTime( 0 )

    PlayMusic( "Music_Beacon_28_BossArrivesAndBattle" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    return npc
}

entity function Spawn_Kane( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "scorch" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_ogre", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_ogre_meteor_boss_fd_elite" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_scorch_flamecore" )
	SetSpawnOption_TitanSoulPassive5( npc, "pas_scorch_selfdmg" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/heavy/titan_heavy_ogre.mdl" )
    npc.SetSkin( 3 )
    npc.SetDecal( 1 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_KANE" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 15000 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_scorch_prime"

    array<entity> primaryWeapons = npc.GetMainWeapons()
    entity weapon = primaryWeapons[0]
    weapon.AddMod( "fd_wpn_upgrade_2" )

    npc.SetDangerousAreaReactionTime( 0 )

    PlayMusic( "music_reclamation_21_kaneslamcam" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    return npc
}

entity function Spawn_Blisk( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    bossStageTracker stageCount
    file.bossStageTrackers[ "legion" ] <-stageCount

    entity npc = CreateNPCTitan( "titan_ogre", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_ogre_minigun_boss_fd_elite" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_legion_spinup" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/heavy/titan_heavy_deadbolt.mdl" )
    npc.SetSkin( 4 )
    npc.SetDecal( 9 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_BLISK" )
    ShowName( npc )
    npc.SetMaxHealth( ( npc.GetMaxHealth() + 15000 ) )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_legion_prime"

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

    npc.SetDangerousAreaReactionTime( 0 )

    PlayMusic( "music_skyway_18_backblast" ) // Need a better song for fighting him
    spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
    npc.WaitSignal( "TitanHotDropComplete" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    AddEntityCallback_OnDamaged( npc, BossTitan_TakesDamage_StageHandler )
    return npc
}

void function BossTitan_TakesDamage_StageHandler( entity titan, var damageInfo )
{
    if ( !IsValid( titan ) )
        return
    if ( !titan.IsTitan() )
        return
    string bossTitanName = GetTitanCharacterName( titan )
    string bossName = titan.GetScriptName()
    int currentHealth = titan.GetHealth()
    float damage = DamageInfo_GetDamage( damageInfo )
    bossStageTracker stageInfo = file.bosses[ bossName ].stageTracker
    printt(currentHealth, currentHealth - damage)
    printt("Mods")
    foreach ( string mod in titan.GetOffhandWeapon( OFFHAND_MELEE ).GetMods() )
    {
        printt(mod)
    }
    if ( currentHealth - damage <= 1 && stageInfo.currentStage < stageInfo.maxStages)
    {
        DamageInfo_SetDamage( damageInfo, 0 )
        titan.SetHealth( 1 )
        titan.SetInvulnerable( )
        // Do health regen stuff here
        thread ResetBossHealth( titan )
        file.bosses[ bossName ].stageTracker.currentStage++
    }
}

void function ResetBossHealth( entity boss )
{
    int maxHealth = boss.GetMaxHealth()
    int currentHealth = boss.GetHealth()
    int loopCount = int( ceil( maxHealth / 1000 ) )
    string bossName = boss.GetScriptName()
    float regenTime = file.bosses[ bossName ].stageTracker.regenTime
    float cycleWaitDuration = regenTime / loopCount
    string bossTheme = file.bosses[ bossName ].theme


    StopMusicTrack( bossTheme, regenTime )
    while ( true )
    {
        if ( currentHealth + 1000 < maxHealth )
            currentHealth += 1000
        else
            currentHealth = maxHealth
        boss.SetHealth( currentHealth )
        if ( currentHealth == maxHealth )
            break
        wait cycleWaitDuration
    }
    boss.ClearInvulnerable()
    PlayMusic( bossTheme )
    return
}

void function SetBossTitanPostSpawn( entity npc, BossData bossData )
{
	if( GetGameState() != eGameState.Playing )
		return

	Assert( IsValid( npc ) && npc.IsTitan(), "Entity is not a Titan to set as Elite: " + npc )
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
        npc.SetModel( bossData.modelPath )
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
