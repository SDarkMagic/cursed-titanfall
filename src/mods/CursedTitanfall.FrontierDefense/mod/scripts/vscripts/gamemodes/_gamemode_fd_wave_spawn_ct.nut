global function WaveSpawn_EliteArcSpawn

void function WaveSpawn_EliteArcSpawn( array<WaveSpawnEvent> waveName, vector origin = < 0, 0, 0 >, float angle = 0.0, string route = "", float waitTime = 0.5, string soundEventName = "", float spawnradius = 0.0, int spawnInDifficulty = eFDSD.ALL, int titanType = eFDTT.TITAN_ELITE, string subGroupName = "" )
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

    event.spawnType = eFD_AITypeIDs.RONIN
    event.eventFunction = SpawnArcEliteTitan

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

void function SpawnArcEliteTitan( WaveSpawnEvent ornull spawnEvent )
{
	if ( !spawnEvent )
		return

	expect WaveSpawnEvent( spawnEvent )
	vector spawnorigin = spawnEvent.origin
	if ( spawnEvent.spawnradius > 0 )
	{
		spawnorigin.x += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.y += RandomFloatRange( -spawnEvent.spawnradius, spawnEvent.spawnradius )
		spawnorigin.z += 128 //Ensure we're above all playable geometry
		spawnorigin = OriginToGround( spawnorigin )
	}

	thread Drop_Spawnpoint( spawnorigin, TEAM_IMC, 5 )

	PingMinimap( spawnorigin.x, spawnorigin.y, 4, 600, 150, 0 )

	entity npc = CreateArcTitan( TEAM_IMC, spawnorigin, spawnEvent.angles )
	SetSpawnOption_Titanfall( npc )
	npc.kv.reactChance = 60
	if ( spawnEvent.titanType == 1 && EliteTitansEnabled() )
	{
		SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd_elite" )
		SetTitanAsElite( npc )
		SetSpawnOption_TitanSoulPassive4( npc, "pas_ronin_swordcore" )
		SetSpawnOption_TitanSoulPassive5( npc, "pas_ronin_weapon" )
		SetSpawnOption_TitanSoulPassive6( npc, "pas_ronin_phase" )
	}
	else
	{
		if ( FD_GetDifficultyLevel() == eFDDifficultyLevel.EASY || FD_GetDifficultyLevel() == eFDDifficultyLevel.NORMAL )
			SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall" )
		else
			SetSpawnOption_AISettings( npc, "npc_titan_stryder_leadwall_boss_fd" )
	}
	SetTargetName( npc, GetTargetNameForID( spawnEvent.spawnType ) ) // required for client to create icons
	DispatchSpawn( npc )
	npc.SetDangerousAreaReactionTime( 3.0 )
    if ( GetArcTitanWeaponOption() )
    {
        TakeWeaponsForArray( npc, npc.GetMainWeapons() )
		npc.GiveWeapon( "mp_titanweapon_arc_cannon" )
		npc.kv.AccuracyMultiplier = 0.5
		npc.kv.WeaponProficiency = eWeaponProficiency.POOR
    }

	if ( EliteTitansEnabled() )
	{
		SetEliteTitanPostSpawn( npc )
		npc.SetMaxHealth( npc.GetMaxHealth() + GetCurrentPlaylistVarInt( "fd_elitetitan_hpbonus_ronin", 7500 ) )
		npc.SetHealth( npc.GetMaxHealth() )
		npc.GetTitanSoul().soul.titanLoadout.titanExecution = "execution_ronin"

		npc.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "fd_sword_upgrade" )
		npc.SetDangerousAreaReactionTime( 0 )
	}
	else
	{
		if ( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() < 4 )
		{
			npc.EnableNPCMoveFlag( NPCMF_WALK_ALWAYS | NPCMF_WALK_NONCOMBAT )
			npc.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
		}
	}
	spawnedNPCs.append( npc )
	AddMinimapForTitans( npc )
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	WaitTillHotDropComplete( npc )

    thread EMPTitanThinkConstant( npc )
	npc.GetTitanSoul().SetTitanSoulNetBool( "showOverheadIcon", true )
	GiveShieldByDifficulty( npc )
	thread NPCNav_FD( npc, spawnEvent.route )
}