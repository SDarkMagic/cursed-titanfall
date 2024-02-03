global function CreateBossTitanEvent_Slone
global function CreateBossTitanEvent_Ash
global function CreateBossTitanEvent_Viper

global enum eFD_Bosses
{
    Kane,
    Ash,
    Richter,
    Viper,
    Slone,
    Blisk
}

WaveEvent function CreateBossTitanEvent_Slone( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_ELITE, float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL )
{
	WaveEvent event
	event.eventFunction = SpawnBossTitan_Slone
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.ION
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	event.spawnInDifficulty = spawnInDifficulty
	return event
}

WaveEvent function CreateBossTitanEvent_Ash( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_ELITE, float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL )
{
	WaveEvent event
	event.eventFunction = SpawnBossTitan_Ash
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.RONIN
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	event.spawnInDifficulty = spawnInDifficulty
	return event
}

WaveEvent function CreateBossTitanEvent_Viper( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_ELITE, float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL )
{
	WaveEvent event
	event.eventFunction = SpawnBossTitan_Viper
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.NORTHSTAR
	event.spawnEvent.spawnAmount = 1
	event.spawnEvent.origin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	event.spawnInDifficulty = spawnInDifficulty
	return event
}

void function SpawnBossTitan_Ash( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	#if SERVER && DEV
	printt( "Spawning Ash at: " + spawnEvent.origin )
	#endif
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = Spawn_Ash( spawnEvent.origin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )

	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnBossTitan_Slone( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	#if SERVER && DEV
	printt( "Spawning Slone at: " + spawnEvent.origin )
	#endif
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = Spawn_Slone( spawnEvent.origin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )

	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread singleNav_thread( npc, spawnEvent.route )
}

void function SpawnBossTitan_Viper( SmokeEvent smokeEvent, SpawnEvent spawnEvent, FlowControlEvent flowControlEvent, SoundEvent soundEvent )
{
	#if SERVER && DEV
	printt( "Spawning Viper at: " + spawnEvent.origin )
	#endif
	if ( GetConVarBool( "ns_fd_show_drop_points" ) )
		thread Drop_Spawnpoint( spawnEvent.origin, TEAM_IMC, 5 )
	PingMinimap( spawnEvent.origin.x, spawnEvent.origin.y, 4, 600, 150, 0 )
	entity npc = Spawn_Viper( spawnEvent.origin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )

	if( spawnEvent.entityGlobalKey != "" )
		GlobalEventEntitys[spawnEvent.entityGlobalKey] <- npc
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.WaitSignal( "TitanHotDropComplete" )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread singleNav_thread( npc, spawnEvent.route )
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

void function Drop_Spawnpoint( vector origin, int team, float impactTime )
{
	vector surfaceNormal = < 0, 0, 1 >

	int index = GetParticleSystemIndex( $"P_ar_titan_droppoint" )

	entity effectEnemy = StartParticleEffectInWorld_ReturnEntity( index, origin, surfaceNormal )
	SetTeam( effectEnemy, team )
	EffectSetControlPointVector( effectEnemy, 1, < 255, 64, 16 > )
	effectEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	wait impactTime

	EffectStop( effectEnemy )
}

void function PingMinimap( float x, float y, float duration, float spreadRadius, float ringRadius, int colorIndex )
{
	if( GetCurrentPlaylistVarFloat( "riff_minimap_state", 0 ) == 0 )
	{
		foreach( entity player in GetPlayerArrayOfTeam( TEAM_MILITIA ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_FD_PingMinimap", x, y, duration, spreadRadius, ringRadius, colorIndex )
			EmitSoundOnEntityOnlyToPlayer( player, player, "coop_minimap_ping" )
		}
	}
}