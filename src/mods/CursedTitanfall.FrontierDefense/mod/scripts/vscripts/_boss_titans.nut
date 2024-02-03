global function DEV_SpawnBossTitan
global function Spawn_Ash
global function Spawn_Slone
global function Spawn_Viper

struct {
    array<string> musicTracksPlaying
} file

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

void function BossListener( entity titan, string musicTrack )
{

}

void function BossDefeated( entity trigger, entity activator, entity caller, var value )
{
    if ( !IsValid( trigger ) )
        return
    if ( !trigger.IsTitan() )
        return
    string bossTitanName = GetTitanCharacterName( trigger )
    switch ( bossTitanName )
    {
        case "ronin":
            StopMusicTrack( "music_boomtown_23_ashintro" )
            return
        case "northstar":
            StopMusicTrack( "music_s2s_14_titancombat" )
            return
        case "ion":
            StopMusicTrack( "music_skyway_16_slonefight" )
            return
        default:
            return

    }
}

entity function Spawn_Ash( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    entity npc = CreateNPCTitan( "titan_stryder", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd_elite" )

    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_ronin_swordcore" )
    SetSpawnOption_TitanSoulPassive5( npc, "pas_ronin_weapon" )
    SetSpawnOption_TitanSoulPassive6( npc, "pas_ronin_phase" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    DispatchSpawn( npc )

    npc.SetModel( $"models/titans/light/titan_light_locust.mdl" )
    npc.SetSkin( 6 )
    npc.SetDecal( 10 )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "#BOSSNAME_ASH" )
    ShowName( npc )
    npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ronin"

    npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
    npc.SetDangerousAreaReactionTime( 0 )
    PlayMusic( "music_boomtown_23_ashintro" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    return npc
}

entity function Spawn_Viper( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    entity npc = CreateNPCTitan( "titan_stryder", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_stryder_sniper_boss_fd" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_northstar_cluster" )
	SetSpawnOption_TitanSoulPassive5( npc, "pas_northstar_trap" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    npc.kv.titanCamoIndex = -1
    npc.kv.titanDecalIndex = 10
    npc.kv.titanSkinIndex = 6
    npc.SetBehaviorSelector( "behavior_titan_sniper_elite" )


    DispatchSpawn( npc )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "Viper" )
    ShowName( npc )
    npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_random_2"

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
    npc.ConnectOutput( "OnDeath", BossDefeated )
    return npc
}

entity function Spawn_Slone( vector origin, vector angles, int team = TEAM_IMC, int spawnType = 0 )
{
    entity npc = CreateNPCTitan( "titan_stryder", team, origin, angles )
    SetSpawnOption_AISettings( npc, "npc_titan_atlas_stickybomb_boss_fd" )
    SetTitanAsElite( npc )
    SetSpawnOption_TitanSoulPassive4( npc, "pas_ion_lasercannon" )
    SetSpawnOption_Titanfall( npc )
    SetTargetName( npc, GetTargetNameForID( spawnType ) )

    npc.kv.titanCamoIndex = -1
    npc.kv.titanDecalIndex = 11
    npc.kv.titanSkinIndex = 7
    npc.SetBehaviorSelector( "behavior_titan_elite" )

    DispatchSpawn( npc )

    SetEliteTitanPostSpawn( npc )
    npc.SetTitle( "Slone" )
    ShowName( npc )
    npc.SetMaxHealth( npc.GetMaxHealth() + 7500 )
    npc.SetHealth( npc.GetMaxHealth() )
    npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ion"
    npc.SetDangerousAreaReactionTime( 0 )

    PlayMusic( "music_skyway_16_slonefight" )
    npc.ConnectOutput( "OnDeath", BossDefeated )
    return npc
}