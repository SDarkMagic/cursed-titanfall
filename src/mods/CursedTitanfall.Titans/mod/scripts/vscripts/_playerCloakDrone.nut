untyped
global function SpawnPlayerCloakDrone
global function Init_PlayerCloakDrone
const FX_DRONE_CLOAK_BEAM = $"P_drone_cloak_beam"

struct CloakDronePath
{
	vector start
	vector goal
	bool goalValid = false
	float lastHeight
}

void function Init_PlayerCloakDrone()
{
    PrecacheParticleSystem( FX_DRONE_CLOAK_BEAM )
}

// Modified variant of the function located at /ai/_ai_cloak_drone.gnut
entity function SpawnPlayerCloakDrone( int team, vector origin, vector angles, entity owner )
{
	int droneCount = GetNPCCloakedDrones().len()

	// add some minor randomness to the spawn location as well as an offset based on number of drones in the world.
	origin += < RandomIntRange( -64, 64 ), RandomIntRange( -64, 64 ), 300 + (droneCount * 128) >

	entity cloakedDrone = CreateGenericDrone( team, origin, angles )
	SetSpawnOption_AISettings( cloakedDrone, "npc_drone_cloaked" )

	//these enable global damage callbacks for the cloakedDrone
	cloakedDrone.s.isHidden <- false
	cloakedDrone.s.fx <- null

	DispatchSpawn( cloakedDrone )
	SetTeam( cloakedDrone, team )
	SetTargetName( cloakedDrone, "Cloak Drone" )
	cloakedDrone.SetTitle( "#NPC_CLOAK_DRONE" )
	cloakedDrone.SetMaxHealth( 250 )
	cloakedDrone.SetHealth( 250 )
	cloakedDrone.SetTakeDamageType( DAMAGE_YES )
	cloakedDrone.SetDamageNotifications( true )
	cloakedDrone.SetDeathNotifications( true )
	cloakedDrone.Solid()
	cloakedDrone.Show()
	cloakedDrone.EnableNPCFlag( NPC_IGNORE_ALL )

	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_IN_SFX )

	//cloakedDrone.s.fx = CreateDroneCloakBeam( cloakedDrone )

	SetVisibleEntitiesInConeQueriableEnabled( cloakedDrone, true )

    thread PlayerCloakedDronePathThink( cloakedDrone, owner )
	thread CloakedDroneCloakThink( cloakedDrone )

	#if R1_VGUI_MINIMAP
		cloakedDrone.Minimap_SetDefaultMaterial( $"vgui/hud/cloak_drone_minimap_orange" )
	#endif
	cloakedDrone.Minimap_SetAlignUpright( true )
	cloakedDrone.Minimap_AlwaysShow( TEAM_IMC, null )
	cloakedDrone.Minimap_AlwaysShow( TEAM_MILITIA, null )
	cloakedDrone.Minimap_SetObjectScale( MINIMAP_CLOAKED_DRONE_SCALE )
	cloakedDrone.Minimap_SetZOrder( MINIMAP_Z_NPC )

	ShowName( cloakedDrone )

	return cloakedDrone
}

// Modified variant of the function located at /ai/_ai_cloak_drone.gnut
void function CloakedDroneCloakThink( entity cloakedDrone )
{
    cloakedDrone.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "DroneCrashing" )

	wait 2	// wait a few seconds since it would start cloaking before picking an npc to follow
			// some npcs might not be picked since they where already cloaked by accident.

	CloakerThink( cloakedDrone, 400.0, [ "player" ], < 0, 0, -350 >, CloakDroneShouldCloakGuy, 1.5 )
}

// Modified variant of the function located at /ai/_ai_cloak_drone.gnut
function CloakDroneShouldCloakGuy( cloakedDrone, guy )
{
    expect entity( guy )
	if ( IsValid( GetRodeoPilot( guy ) ) )
		return false

	if ( cloakedDrone.s.isHidden )
		return false

	if ( StatusEffect_Get( guy, eStatusEffect.sonar_detected ) )
		return false

	return true
}

void function CloakedDroneWarpOut( entity cloakedDrone, vector origin )
{
	if ( cloakedDrone.s.isHidden == false )
	{
		// only do this if we are not already hidden
		FadeOutSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX, 0.5 )
		FadeOutSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX, 0.5 )
		EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_OUT_SFX )

		cloakedDrone.s.fx.Fire( "StopPlayEndCap" )
		cloakedDrone.SetTitle( "" )
		cloakedDrone.s.isHidden = true
		cloakedDrone.NotSolid()
		cloakedDrone.Minimap_Hide( TEAM_IMC, null )
		cloakedDrone.Minimap_Hide( TEAM_MILITIA, null )
		cloakedDrone.SetNoTarget( true )
		// let the beam fx end

		if ( "smokeEffect" in cloakedDrone.s )
		{
			cloakedDrone.s.smokeEffect.Kill_Deprecated_UseDestroyInstead()
			delete cloakedDrone.s.smokeEffect
		}
		UntrackAllToneMarks( cloakedDrone )

		wait 0.3	// wait a bit before hidding the done so that the fx looks better
		cloakedDrone.Hide()
	}

	wait 2.0

	cloakedDrone.DisableBehavior( "Follow" )
	thread AssaultOrigin( cloakedDrone, origin )
	cloakedDrone.SetOrigin( origin )
}

void function CloakedDroneWarpIn( entity cloakedDrone, vector origin )
{
	cloakedDrone.DisableBehavior( "Follow" )
	cloakedDrone.SetOrigin( origin )
	PutEntityInSafeSpot( cloakedDrone, cloakedDrone, null, cloakedDrone.GetOrigin() + <0, 0, 32>, cloakedDrone.GetOrigin() )
	thread AssaultOrigin( cloakedDrone, origin )

	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_HOVER_LOOP_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_LOOPING_SFX )
	EmitSoundOnEntity( cloakedDrone, CLOAKED_DRONE_WARP_IN_SFX )

	cloakedDrone.Show()
	cloakedDrone.s.fx.Fire( "start" )
	cloakedDrone.SetTitle( "#NPC_CLOAK_DRONE" )
	cloakedDrone.s.isHidden = false
	cloakedDrone.Solid()
	cloakedDrone.Minimap_AlwaysShow( TEAM_IMC, null )
	cloakedDrone.Minimap_AlwaysShow( TEAM_MILITIA, null )
	cloakedDrone.SetNoTarget( false )
}

entity function CreateDroneCloakBeam( entity cloakedDrone )
{
	entity fx = PlayLoopFXOnEntity( FX_DRONE_CLOAK_BEAM, cloakedDrone, "", null, < 90, 0, 0 > )//, visibilityFlagOverride = null, visibilityFlagEntOverride = null )
	return fx
}

// Taken from /ai/_ai_cloak_drone.gnut and modified to work specifically on players
/************************************************************************************************\

########     ###    ######## ##     ## #### ##    ##  ######
##     ##   ## ##      ##    ##     ##  ##  ###   ## ##    ##
##     ##  ##   ##     ##    ##     ##  ##  ####  ## ##
########  ##     ##    ##    #########  ##  ## ## ## ##   ####
##        #########    ##    ##     ##  ##  ##  #### ##    ##
##        ##     ##    ##    ##     ##  ##  ##   ### ##    ##
##        ##     ##    ##    ##     ## #### ##    ##  ######

\************************************************************************************************/
//HACK -> this should probably move into code
const VALIDPATHFRAC = 0.99

void function PlayerCloakedDronePathThink( entity cloakedDrone, entity player )
{
	cloakedDrone.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "DroneCrashing" )

	vector spawnOrigin = cloakedDrone.GetOrigin()
	vector lastOrigin = cloakedDrone.GetOrigin()
	float stuckDistSqr = 64.0*64.0

	while( 1 )
	{
		waitthread CloakedDronePathFollowPlayer( cloakedDrone, player )

		float distSqr = DistanceSqr( lastOrigin, cloakedDrone.GetOrigin() )
		if ( distSqr < stuckDistSqr )
			CloakedDroneWarpOut( cloakedDrone, spawnOrigin )

		lastOrigin = cloakedDrone.GetOrigin()
	}
}

void function CloakedDronePathFollowPlayer( entity cloakedDrone, entity player )
{
	cloakedDrone.EndSignal( "OnDestroy" )
	cloakedDrone.EndSignal( "OnDeath" )
	cloakedDrone.EndSignal( "DroneCrashing" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	if ( !( "cloakedDrone" in player.s ) )
		player.s.cloakedDrone <- null
	player.s.cloakedDrone = cloakedDrone

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsAlive( player ) )
				player.s.cloakedDrone = null
		}
	)

	int droneTeam = cloakedDrone.GetTeam()

	vector maxs = < 32, 32, 32 >//bigger than model to compensate for large effect
	vector mins = < -32, -32, -32 >

	int mask = cloakedDrone.GetPhysicsSolidMask()

	float defaultHeight 					= 300
	array<float> traceHeightsLow			= [ -75.0, -150.0, -250.0 ]
	array<float> traceHeightsHigh			= [ 150.0, 300.0, 800.0, 1500.0 ]

	float waitTime 	= 0.25

	CloakDronePath path
	path.goalValid = false
	path.lastHeight = defaultHeight

	while( player.GetTeam() == droneTeam )
	{
		if ( IsValid( GetRodeoPilot( player ) ) )
			return

		//If our target npc gets revealed by a sonar pulse, ditch that chump.
		if ( StatusEffect_Get( player, eStatusEffect.sonar_detected ) )
			return

		float startTime = Time()
		path.goalValid 	= false

		CloakedDroneFindPathDefault( path, defaultHeight, mins, maxs, cloakedDrone, player, mask )

		//find a new path if necessary
		if ( !path.goalValid )
		{
			//lets check some heights and see if any are valid
			CloakedDroneFindPathHorizontal( path, traceHeightsLow, defaultHeight, mins, maxs, cloakedDrone, player, mask )

			if ( !path.goalValid )
			{
				//OK so no way to directly go to those heights - lets see if we can move vertically down,
				CloakedDroneFindPathVertical( path, traceHeightsLow, defaultHeight, mins, maxs, cloakedDrone, player, mask )

				if ( !path.goalValid )
				{
					//still no good...lets check up
					CloakedDroneFindPathHorizontal( path, traceHeightsHigh, defaultHeight, mins, maxs, cloakedDrone, player, mask )

					if ( !path.goalValid )
					{
						//no direct shots up - lets try moving vertically up first
						CloakedDroneFindPathVertical( path, traceHeightsHigh, defaultHeight, mins, maxs, cloakedDrone, player, mask )
					}
				}
			}
		}

		// if we can't find a valid path find a new goal
		if ( !path.goalValid )
		{
			waitthread CloakedDroneWarpOut( cloakedDrone, player.GetOrigin() + < 0, 0, defaultHeight > )
			CloakedDroneWarpIn( cloakedDrone, player.GetOrigin() + < 0, 0, defaultHeight > )
			continue
		}

		if ( cloakedDrone.s.isHidden == true )
			CloakedDroneWarpIn( cloakedDrone, cloakedDrone.GetOrigin() )

		thread AssaultOrigin( cloakedDrone, path.goal )

		float endTime = Time()
		float elapsedTime = endTime - startTime
		if ( elapsedTime < waitTime )
			wait waitTime - elapsedTime
	}
}

bool function CloakedDroneFindPathDefault( CloakDronePath path, float defaultHeight, vector mins, vector maxs, entity cloakedDrone, entity  player, int mask )
{
	vector offset 	= < 0, 0, defaultHeight >
	path.start 		= ( cloakedDrone.GetOrigin() ) + < 0, 0, 32 > //Offset so path start is just above drone instead at bottom of drone.
	path.goal 		= player.GetOrigin() + offset

	//find out if we can get there using the default height
	TraceResults result = TraceHull( path.start, path.goal, mins, maxs, [ cloakedDrone, player ] , mask, TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( path.start, path.goal, 50, 0, 0, true, 1.0 )
	if ( result.fraction >= VALIDPATHFRAC )
	{
		path.lastHeight = defaultHeight
		path.goalValid 	= true
	}

	return path.goalValid
}

bool function CloakedDroneFindPathHorizontal( CloakDronePath path, array<float> traceHeights, float defaultHeight, vector mins, vector maxs, entity cloakedDrone, entity  player, int mask )
{
	wait 0.1

	vector offset
	float testHeight

	//slight optimization... recheck if the last time was also not the default height
	if ( path.lastHeight != defaultHeight )
	{
		offset 			= < 0, 0, defaultHeight + path.lastHeight >
		path.start 		= ( cloakedDrone.GetOrigin() )
		path.goal 		= player.GetOrigin() + offset

		TraceResults result = TraceHull( path.start, path.goal, mins, maxs, [ cloakedDrone, player ], mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 0, 255, 0, true, 1.0 )
		if ( result.fraction >= VALIDPATHFRAC )
		{
			path.goalValid = true
			return path.goalValid
		}
	}

	for ( int i = 0; i < traceHeights.len(); i++ )
	{
		testHeight = traceHeights[ i ]
		if ( path.lastHeight == testHeight )
			continue

//		wait 0.1

		offset 			= < 0, 0, defaultHeight + testHeight >
		path.start 		= ( cloakedDrone.GetOrigin() ) + ( testHeight > 0 ? < 0, 0, 0 > : < 0, 0, 32 > ) //Check from the top or bottom of the drone depending on if the drone is going up or down
		path.goal 		= player.GetOrigin() + offset

		TraceResults result = TraceHull( path.start, path.goal, mins, maxs, [ cloakedDrone, player ], mask, TRACE_COLLISION_GROUP_NONE )
		if ( result.fraction < VALIDPATHFRAC )
		{
			//DebugDrawLine( path.start, path.goal, 200, 0, 0, true, 3.0 )
			continue
		}

		//DebugDrawLine( path.start, path.goal, 0, 255, 0, true, 3.0 )

		path.lastHeight = testHeight
		path.goalValid = true
		break
	}

	return path.goalValid
}

bool function CloakedDroneFindPathVertical( CloakDronePath path, array<float> traceHeights, float defaultHeight, vector mins, vector maxs, entity cloakedDrone, entity  player, int mask )
{
	vector offset
	vector origin
	float testHeight

	for ( int i = 0; i < traceHeights.len(); i++ )
	{
		wait 0.1

		testHeight 		= traceHeights[ i ]
		origin 			= cloakedDrone.GetOrigin()
		offset 			= < 0, 0, defaultHeight + testHeight >
		path.start 		= < origin.x, origin.y, defaultHeight + testHeight >
		path.goal 		= player.GetOrigin() + offset

		TraceResults result = TraceHull( path.start, path.goal, mins, maxs, [ cloakedDrone, player ], mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 50, 50, 100, true, 1.0 )
		if ( result.fraction < VALIDPATHFRAC )
			continue

		//ok so it's valid - lets see if we can move to it from where we are
//		wait 0.1

		path.goal 	= < path.start.x, path.start.y, path.start.z >
		path.start 	= cloakedDrone.GetOrigin()

		result = TraceHull( path.start, path.goal, mins, maxs, [ cloakedDrone, player ], mask, TRACE_COLLISION_GROUP_NONE )
		//DebugDrawLine( path.start, path.goal, 255, 255, 0, true, 1.0 )
		if ( result.fraction < VALIDPATHFRAC )
			continue

		path.lastHeight = testHeight
		path.goalValid = true
		break
	}

	return path.goalValid
}