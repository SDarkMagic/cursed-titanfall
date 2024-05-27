global function WaveSpawn_BossTitanSpawn_Random

global enum eFD_Bosses
{
    Kane,
    Ash,
    Richter,
    Viper,
    Slone,
    Blisk,
    None
}

/*
WaveEvent function CreateBossTitanEvent_Slone( vector origin, vector angles, string route, int nextEventIndex, int executeOnThisCall = 1, string entityGlobalKey = "", int titanType = FD_TitanType.TITAN_ELITE, float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL )
{
	WaveEvent event
	event.eventFunction = SpawnBossTitan_Slone
	event.executeOnThisCall = executeOnThisCall
	event.nextEventIndex = nextEventIndex
	event.shouldThread = true
	event.spawnEvent.spawnType= eFD_AITypeIDs.ION
	event.spawnEvent.spawnAmount = 1
	event.spawnorigin = origin
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
	event.spawnorigin = origin
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
	event.spawnorigin = origin
	event.spawnEvent.angles = angles
	event.spawnEvent.route = route
	event.spawnEvent.entityGlobalKey = entityGlobalKey
	event.spawnEvent.titanType = titanType
	event.spawnEvent.spawnradius = spawnradius
	event.spawnInDifficulty = spawnInDifficulty
	return event
}
*/
void function WaveSpawn_BossTitanSpawn_Random( array<WaveSpawnEvent> waveName, array<int> bossOptions = [ eFD_Bosses.Kane, eFD_Bosses.Slone, eFD_Bosses.Viper, eFD_Bosses.Ash, eFD_Bosses.Richter, eFD_Bosses.Blisk ], vector origin = < 0, 0, 0 >, float angle = 0.0, string route = "", float waitTime = 0.5, string soundEventName = "", float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL, int titanType = eFDTT.TITAN_COMMON, string subGroupName = "" )
{
    WaveSpawnEvent event

	event.shouldThread = true
	event.spawnAmount = 1
	event.origin = origin
	event.angles = < 0, angle, 0 >
	event.route = route
	event.titanType = titanType
	event.spawnradius = spawnradius
	event.spawnInDifficulty = spawnInDifficulty
	int bossIndex = 0
	if ( bossOptions.len() > 1 )
    	bossIndex = RandomInt( bossOptions.len() )

	int boss = bossOptions[ bossIndex ]

    switch ( boss )
    {
        case eFD_Bosses.Kane:
            event.spawnType = eFD_AITypeIDs.SCORCH
            event.eventFunction = SpawnBossTitan_Kane
            break
        case eFD_Bosses.Ash:
            event.spawnType = eFD_AITypeIDs.RONIN
            event.eventFunction = SpawnBossTitan_Ash
            break
        case eFD_Bosses.Richter:
            event.spawnType = eFD_AITypeIDs.TONE
            event.eventFunction = SpawnBossTitan_Richter
            break
        case eFD_Bosses.Viper:
            event.spawnType = eFD_AITypeIDs.NORTHSTAR
            event.eventFunction = SpawnBossTitan_Viper
            break
        case eFD_Bosses.Slone:
            event.spawnType = eFD_AITypeIDs.ION
            event.eventFunction = SpawnBossTitan_Slone
            break
        case eFD_Bosses.Blisk:
            event.spawnType = eFD_AITypeIDs.LEGION
            event.eventFunction = SpawnBossTitan_Blisk
    }

	event.origin = origin
	event.angles = < 0, angle, 0 >
	event.route = route
	event.spawnradius = spawnradius
	event.titanType = titanType
	event.spawnInDifficulty = spawnInDifficulty
	event.soundEventName = soundEventName
	event.waitTime = waitTime
	event.waveSubGroupName = subGroupName
	waveName.append(event)
}

void function SpawnBossTitan_Ash( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Ash at: " + spawnorigin )
	#endif

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Ash( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}

void function SpawnBossTitan_Slone( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Slone at: " + spawnorigin )
	#endif

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Slone( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}

void function SpawnBossTitan_Viper( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Viper at: " + spawnorigin )
	#endif

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Viper( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}

void function SpawnBossTitan_Kane( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Kane at: " + spawnorigin )
	#endif

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Kane( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}

void function SpawnBossTitan_Richter( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Richter at: " + spawnorigin )
	#endif

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Richter( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}

void function SpawnBossTitan_Blisk( WaveSpawnEvent ornull spawnEvent )
{
	if( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	#if SERVER && DEV
	printt( "Spawning Blisk at: " + spawnorigin )
	#endif


	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = Spawn_Blisk( spawnorigin, spawnEvent.angles, TEAM_IMC, spawnEvent.spawnType )
	spawnedNPCs.append( npc )

	AddMinimapForTitans( npc )
    npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	//GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}
